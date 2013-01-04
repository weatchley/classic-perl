# DB Keyword functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/DBKeywords.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/12/02 18:43:17 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBKeywords.pm,v $
# Revision 1.1  2004/12/02 18:43:17  atchleyb
# Initial revision
#
#
#
#
#
#

package DBKeywords;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getKeywordList             &getKeyword          &doProcessKeywordEntry
      &doProcessKeywordDelete
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getKeywordList             &getKeyword          &doProcessKeywordEntry
      &doProcessKeywordDelete
    )]
);


###################################################################################################################################
sub getKeywordList {  # routine to get an array of keywords
###################################################################################################################################
    my %args = (
        ID => 0,
        getCount => 'F',
        @_,
    );

    my $i = 0;
    my @keywords;
    my $sqlcode = "SELECT id, text ";
    $sqlcode .= "FROM $args{schema}.keywords WHERE id>0 ";
    $sqlcode .= (($args{ID} ne 0) ? "AND (id = $args{ID}) ": "");
    $sqlcode .= "ORDER BY text";
#print STDERR "\n$sqlcode\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($keywords[$i]{id}, $keywords[$i]{text}) = $csr->fetchrow_array) {
        if ($args{getCount} eq 'T') {
            ($keywords[$i]{count}) = $args{dbh}->selectrow_array("SELECT COUNT(*) FROM $args{schema}.extraction_keywords WHERE keyword=$keywords[$i]{id}");
        } else {
            $keywords[$i]{count} = 0;
        }
        $i++;
    }
    $csr->finish;

    return (@keywords);
}


###################################################################################################################################
sub getKeyword { # routine to get a keyword
###################################################################################################################################
    my %args = (
        ID => 0,
        @_,
    );
    my %keyword;
    my @keywords = getKeywordList(dbh => $args{dbh}, schema => $args{schema}, ID => $args{ID});
    
    my $hashref = $keywords[0];
    %keyword = %$hashref;
    
    return (%keyword);
}


###################################################################################################################################
sub doProcessKeywordEntry {  # routine to enter a new keyword or update a keyword
###################################################################################################################################
    my %args = (
        type => "",  # new or update
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    
    eval {
        if ($args{type} eq 'new') {
            $sqlcode = "INSERT INTO $args{schema}.keywords (id, text) VALUES ($args{schema}.keywords_id.NEXTVAL, ";
            $sqlcode .= $args{dbh}->quote($settings{text}) . ")";
#print STDERR "\n$sqlcode\n\n";
            $status = $args{dbh}->do($sqlcode);
        } else {
            $sqlcode = "UPDATE $args{schema}.keywords SET text = " .$args{dbh}->quote($settings{text}) . " ";
            $sqlcode .= "WHERE id = $settings{keywordid}";
#print STDERR "\n$sqlcode\n\n";
            $status = $args{dbh}->do($sqlcode);
        }

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
sub doProcessKeywordDelete {  # routine to delete a keyword
###################################################################################################################################
    my %args = (
        type => "",  # new or update
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    
    eval {
        $sqlcode = "DELETE FROM $args{schema}.keywords WHERE id = $settings{id}";
#print STDERR "\n$sqlcode\n\n";
        $status = $args{dbh}->do($sqlcode);

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
###################################################################################################################################


1; #return true
