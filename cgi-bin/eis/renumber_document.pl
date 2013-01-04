#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/crd/perl/RCS/renumber_document.pl,v $
#
# $Revision: 1.4 $
#
# $Date: 2002/02/21 00:27:37 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: renumber_document.pl,v $
# Revision 1.4  2002/02/21 00:27:37  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.3  2001/11/10 03:14:44  mccartym
# move comment copying functions to new Comments.pm module
#
# Revision 1.2  2001/11/08 19:34:38  mccartym
# write no log message when old doc not found or new doc already exists error occurs
#
# Revision 1.1  2001/11/08 01:34:12  mccartym
# Initial revision
#

use integer;
use strict;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use Comments qw(:Functions);
use CGI qw(param);
use DBI;
use DBD::Oracle qw(:ora_types);

$| = 1;
my $crdcgi = new CGI;
my $userid = $crdcgi->param("userid");
my $username = $crdcgi->param("username");
my $schema = $crdcgi->param("schema");
&checkLogin ($username, $userid, $schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $command = defined($crdcgi->param("command")) ? $crdcgi->param("command") : "";
my $process = defined($crdcgi->param("process")) ? $crdcgi->param("process") : "";
my $output = "";
my $dbh;

###################################################################################################################################
sub copyDocument {                                                                                                                #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $columns = "documenttype, datereceived, enteredby1, entrydate1, enteredby2, entrydate2, proofreadby, proofreaddate, dupsimstatus, ";
   $columns .= "dupsimid, hassrcomments, haslacomments, has960comments, hasenclosures, isillegible, commentsentered, pagecount, ";
   $columns .= "addressee, signercount, namestatus, commentor, wasrescanned, enclosurepagecount, evaluationfactor";
   my $sql = "insert into $schema.document (id, $columns) select $args{new}, $columns from $schema.document where id = $args{old}";
   $dbh->do($sql);
}

###################################################################################################################################
sub copyReviewer {                                                                                                                #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $sql = "insert into $schema.technical_reviewer (document, commentnum, reviewer, dateassigned) select $args{new}, commentnum, ";
   $sql .= "reviewer, dateassigned from $schema.technical_reviewer where document = $args{old} and commentnum = $args{comment} and ";
   $sql .= "reviewer = $args{reviewer}";
   $dbh->do($sql);
}

###################################################################################################################################
sub copyDocumentReviewers {                                                                                                       #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $csr = $dbh->prepare("select commentnum, reviewer from $schema.technical_reviewer where document = $args{old}");
   $csr->execute;
   while (my ($comment, $reviewer) = $csr->fetchrow_array) {
      &copyReviewer(old => $args{old}, new => $args{new}, comment => $comment, reviewer => $reviewer);
   }
   $csr->finish;
}

###################################################################################################################################
sub copyResponseVersion {                                                                                                         #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $columns = "commentnum, version, status, originaltext, reviewedtext, techeditedtext, redlinedtext, coordeditedtext, ";
   $columns .= "nepaeditedtext, doeeditedtext, lastsubmittedtext, enteredby, entrydate, proofreadby, proofreaddate, responsewriter, ";
   $columns .= "techeditor, dateupdated, summary, dupsimstatus, dupsimdocumentid, dupsimcommentid, approvedtext";
   my $sql = "insert into $schema.response_version (document, $columns) select $args{new}, $columns from $schema.response_version ";
   $sql .= "where document = $args{old} and commentnum = $args{comment} and version = $args{version}";
   $dbh->do($sql);
}

###################################################################################################################################
sub copyDocumentResponseVersions {                                                                                                #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $csr = $dbh->prepare("select commentnum, version from $schema.response_version where document = $args{old}");
   $csr->execute;
   while (my ($comment, $version) = $csr->fetchrow_array) {
      &copyResponseVersion(old => $args{old}, new => $args{new}, comment => $comment, version => $version);
   }
   $csr->finish;
}

###################################################################################################################################
sub getIDs {                                                                                                                      #
###################################################################################################################################
   my %args = (
      @_,
   );
   $output .= "<tr><td align=center><b>Renumber";
   $output .= &nbspaces(2) . "$CRDType<input type=text size=6 maxlength=6 name=oldid>\n";
   $output .= &nbspaces(1) . "To";
   $output .= &nbspaces(2) . "$CRDType<input type=text size=6 maxlength=6 name=newid>\n";
   $output .= &nbspaces(2) . "<input type=button name=go value='Go' onClick=javascript:validate()></b></td></tr>\n";
}

###################################################################################################################################
sub processSubmittedData {                                                                                                        #
###################################################################################################################################
   $dbh = &db_connect();
   $dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
   $dbh->{LongReadLen} = 10000000;
   print "<html>\n<head>\n</head>\n<body>\n";
   my $activity = "";
   my $logActivity = 0;
   my $error = "";
   eval {
      #############################################################################################################################
      if ($process eq 'renumber_document') {                                                                                      #
      #############################################################################################################################
         my $oldid = $crdcgi->param("oldid") - 0;
         my $newid = $crdcgi->param("newid") - 0;
         my $formattedOldID = &formatID($CRDType, 6, $oldid);
         my $formattedNewID = &formatID($CRDType, 6, $newid);
         $activity = "Renumber $formattedOldID to $formattedNewID";
         my $documentRemark = "Renumbered from $formattedOldID to $formattedNewID";
         my ($countOld) = $dbh->selectrow_array ("select count(*) from $schema.document where id = $oldid");
         $error .= "$formattedOldID does not exist\n" if (!$countOld);
         my ($countNew) = $dbh->selectrow_array ("select count(*) from $schema.document where id = $newid");
         $error .= "$formattedNewID already exists\n" if ($countNew);
         if (!$error) {
            $logActivity = 1;
            &copyDocument(old => $oldid, new => $newid);
            $dbh->do ("update $schema.document set dupsimid = $newid where dupsimid = $oldid");
            $dbh->do ("update $schema.document_remark set document = $newid where document = $oldid");
            $dbh->do ("update $schema.comments_entry set document = $newid where document = $oldid");
            $dbh->do ("update $schema.document_entry set dupsimid = $newid where dupsimid = $oldid");
            &copyDocumentComments(dbh => $dbh, schema => $schema, old => $oldid, new => $newid);
            $dbh->do ("update $schema.comments set dupsimdocumentid = $newid where dupsimdocumentid = $oldid");
            $dbh->do ("update $schema.concurrence set document = $newid where document = $oldid");
            $dbh->do ("update $schema.comments_entry set dupsimdocumentid = $newid where dupsimdocumentid = $oldid");
            $dbh->do ("update $schema.response_version set dupsimdocumentid = $newid where dupsimdocumentid = $oldid");
            $dbh->do ("update $schema.comments_remark set document = $newid where document = $oldid");
            $dbh->do ("update $schema.response_version_entry set document = $newid where document = $oldid");
            &copyDocumentReviewers(old => $oldid, new => $newid);
            &copyDocumentResponseVersions(old => $oldid, new => $newid);
            $dbh->do ("update $schema.technical_review set document = $newid where document = $oldid");
            $dbh->do ("delete from $schema.response_version where document = $oldid");
            $dbh->do ("delete from $schema.technical_reviewer where document = $oldid");
            $dbh->do ("delete from $schema.comments where document = $oldid");
            $dbh->do ("delete from $schema.document where id = $oldid");
            $dbh->do ("insert into $schema.document_remark (document, remarker, dateentered, text) values ($newid, $userid, SYSDATE, '$documentRemark')");
            $dbh->commit;
         }
      }
   };
   ################################################################################################################################
   if ($@) {
      $dbh->rollback;
      $error = &errorMessage($dbh, $username, $userid, $schema, $activity, $@);
   } elsif ($logActivity) {
      &log_activity ($dbh, $schema, $userid, $activity);
   }
   if ($error) { # display the error message
      $error =~ s/\n/\\n/g;
      $error =~ s/'/%27/g;
      print "<script language=javascript>\n<!--\nvar mytext ='$error';\nalert(unescape(mytext));\n//-->\n</script>\n";
   } else { # submit a form to run the required script and produce output in the main window
      print "<form name=$form method=post target=main action=$path$form.pl>\n";
      if ($form eq 'renumber_document') {
         my @paramlist = $crdcgi->param();
         foreach my $param (@paramlist) {
            my $val = ($param eq 'process') ? 0 : $crdcgi->param($param);
            $val =~ s/'/%27/g;
            print "<input type=hidden name='$param' value='$val'>\n";
         }
      } else {
         print "<input type=hidden name=username value=$username>\n";
         print "<input type=hidden name=userid value=$userid>\n";
         print "<input type=hidden name=schema value=$schema>\n";
      }
      print "</form>\n";
      print "<script language=javascript>\n<!--\n$form.submit();\n//-->\n</script>\n";
   }
   print "</body>\n</html>\n";
   &db_disconnect($dbh);
}

###################################################################################################################################
sub writeHTTPHeader {                                                                                                             #
###################################################################################################################################
   print $crdcgi->header('text/html');
}

###################################################################################################################################
sub writeHead {                                                                                                                   #
###################################################################################################################################
   print "<html>\n";
   print "<head>\n";
   print "<meta http-equiv=expires content=now>\n";
   print "<script src=$CRDJavaScriptPath/utilities.js></script>\n";
   print "<script src=$CRDJavaScriptPath/widgets.js></script>\n";
   print "<script language=javascript><!--\n";
   print <<end;
      function validate () {
         var msg = "";
         if ((isNaN($form.oldid.value - 0) || ($form.oldid.value <= 0) || ($form.oldid.value > 999999))) {
            msg += "Old document ID is invalid.\\n";
         }
         if ((isNaN($form.newid.value - 0) || ($form.newid.value <= 0) || ($form.newid.value > 999999))) {
            msg += "New document ID is invalid.\\n";
         }
         if ($form.oldid.value == $form.newid.value) {
            msg += "Old and new document IDs must be different.\\n";
         }
         if (msg != "") {
            alert(msg);
         } else {
            $form.action = '$path' + 'renumber_document' + '.pl';
            $form.command.value = 'renumber_document';
            $form.process.value = 'renumber_document';
            $form.target = 'cgiresults';
            $form.submit();
         }
      }
end
   print "//-->\n";
   print "</script>\n";
   print "</head>\n\n";
}

###################################################################################################################################
sub writeBody {                                                                                                                   #
###################################################################################################################################
   print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n<center>\n";
   print "<font face=$CRDFontFace color=$CRDFontColor>\n";
   print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Renumber Comment Document");
   print "<form name=$form method=post>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=command value=$command>\n";
   print "<input type=hidden name=process value=0>\n";
   print "<table width=775 cellpadding=0 cellspacing=0 border=0>\n$output</table>\n";
   print "</form>\n</font>\n</center>\n</body>\n</html>\n";
}

###################################################################################################################################
&writeHTTPHeader();
if ($process) {
   &processSubmittedData();
} else {
   if ($command eq 'renumber_document') {
      $output = &getIDs();
   }
   &writeHead();
   &writeBody();
}
exit();
