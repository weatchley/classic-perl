#
# $Source: /usr/local/homes/atchleyb/rcs/crd/perl/RCS/Comments.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2008/01/18 00:50:00 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: Comments.pm,v $
# Revision 1.2  2008/01/18 00:50:00  atchleyb
# CREQ00052 - fix problem with change of copyComments
#
# Revision 1.1  2001/11/10 03:12:49  mccartym
# Initial revision
#
#

package Comments;
use strict;
use integer;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use CGI qw(param);
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $AUTOLOAD);
use Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(
   &createDupCommentsForSimilarDocument   &copyDocumentComments
);
@EXPORT_OK = qw(
   &createDupCommentsForSimilarDocument   &copyDocumentComments
);
%EXPORT_TAGS = (Functions => [qw(
   &createDupCommentsForSimilarDocument   &copyDocumentComments
)]);

my ($crdcgi, $path, $form);
BEGIN {
   $crdcgi = new CGI;
   $ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
   $path = $1;
   $form = $2;
}

###################################################################################################################################
sub copyComment {                                                                                                                 #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $columns = "commentnum, text, startpage, dateassigned, datedue, dateapproved, hascommitments, changeimpact, changecontrolnum, ";
   $columns .= "createdby, datecreated, proofreadby, proofreaddate, bin, doereviewer, summary, dupsimstatus, dupsimdocumentid, ";
   $columns .= "dupsimcommentid, hasissues, summaryapproved, uniqueid";
   my $sql = "insert into $args{schema}.comments (document, $columns) select $args{new}, $columns from $args{schema}.comments ";
   $sql .= "where document = $args{old} and commentnum = $args{comment}";
   $args{dbh}->do($sql);
}

###################################################################################################################################
sub copyDocumentComments {                                                                                                        #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $csr = $args{dbh}->prepare("select commentnum from $args{schema}.comments where document = $args{old}");
   $csr->execute;
   while (my ($comment) = $csr->fetchrow_array) {
      &copyComment(dbh => $args{dbh}, schema => $args{schema}, old => $args{old}, new => $args{new}, comment => $comment);
   }
   $csr->finish;
}

###################################################################################################################################
sub createDupCommentsForSimilarDocument {                                                                                         #
###################################################################################################################################
   my %args = (
      @_,
   );
   &copyDocumentComments (dbh => $args{dbh}, schema => $args{schema}, old => $args{parentDocument}, new => $args{duplicateDocument});
#               &copyComments(dbh => $dbh, schema => $schema, userId => $userid, duplicateDocument => $dupDocId, parentDocument => $document);
}

1;
