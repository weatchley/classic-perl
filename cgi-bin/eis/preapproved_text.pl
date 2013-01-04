#!/usr/local/bin/newperl -w

## Preapproved Text Entry, Proofread##
#
# $Source: /usr/local/homes/atchleyb/rcs/crd/perl/RCS/preapproved_text.pl,v $
#
# $Revision: 1.12 $
#
# $Date: 2007/03/15 23:24:43 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: preapproved_text.pl,v $
# Revision 1.12  2007/03/15 23:24:43  atchleyb
# CR0049 - Updated to use local per module rather than Oracle stored procedure
#
# Revision 1.11  2000/12/07 23:59:56  atchleyb
# added code to handle multiple oracle servers
#
# Revision 1.10  2000/02/10 17:40:21  atchleyb
# removed form-verify.js
#
# Revision 1.9  1999/10/27 17:34:26  mccartym
# changed headerBar() call to writeTitleBar()
#
# Revision 1.8  1999/10/07 23:29:26  mccartym
# add revision history tag
#
#

use strict;
use integer;

use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use StoredProcedures qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $crdcgi = new CGI;
my $userid = $crdcgi->param("userid");
my $username = $crdcgi->param("username");
my $schema = $crdcgi->param("schema");
# Set server parameter
my $Server = $crdcgi->param("server");
if (!(defined($Server))) {$Server=$CRDServer;}

my $command = $crdcgi->param("command");
my $title = "";

&checkLogin($username, $userid, $schema);

my $dbh = db_connect();

print $crdcgi->header('text/html');

print <<end;
<html>
<head>
   <meta http-equiv=expires content=now>
   <script src=$CRDJavaScriptPath/utilities.js></script>
   <script src=$CRDJavaScriptPath/widgets.js></script>
   <script language=javascript><!--
   function submitForm(script, command) {
      document.$form.command.value = command;
      document.$form.action = '$path' + script + '.pl';
      document.$form.submit();
   }
   function verifyEntry(command) {
      if (document.$form.preapprovedtext.value == '') { 
         alert('Please enter text before submitting.'); 
      } else {  
         submitForm('$form', command); 
      } 
   }  
   function popit(txt) { 
      alert(txt);
   } 
   function browseText(id) { 
      document.$form.id.value=id; 
      submitForm('$form', 'view_text'); 
   } 
   function displayUser(id) { 
      document.$form.id.value = id; 
      submitForm('user_functions', 'displayuser'); 
   } 
   //-->
   </script> 
</head>
end

# default body and font tags
print "<body background=$CRDImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
print "<font face=\"$CRDFontFace\" color=$CRDFontColor>\n\n";

#*******************************************************************************
## Start Enter Preapproved Text ##
if ( ($command eq 'enter_preapproved') || ($command eq 'enter_messagepoint')) {
   $title = "Enter Preapproved Text";
   print "<form name=$form method=post target='cgiresults'>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=server value=$Server>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=command value=$command>\n\n";
   print "<center><table border=0 width=680 align=center>\n\n";
   print "<tr><td><hr width=100% height=30></td></tr>\n\n";
   print "<tr><td align=center><table border=0>\n";
   if ($command eq "enter_preapproved") {
      print "<input type=hidden name=texttype value=1 >\n"; 
      print "<tr><td align=left><b>Text Type:</b>&nbsp;&nbsp;&nbsp;</td><td align=left><b>Preapproved Response</b></i></font></td></tr>\n";
   }   elsif ($command eq "enter_messagepoint") {
      print "<input type=hidden name=texttype value=2 >\n"; 
      print "<tr><td align=left><b>Text Type:</b>&nbsp;&nbsp;&nbsp;</td><td align=left><b>Message Point</b></i></font></td></tr>\n";
   }
   print "</table></td></tr>\n\n";
   print "<tr><td><hr width=100% height=30></td></tr> \n";
   print "<tr><td>&nbsp;<br></td></tr> \n\n";
   print "<tr><td><b>Enter Text:&nbsp;&nbsp;</b></td></tr> \n";
   print "<tr><td><textarea name=preapprovedtext rows=10 cols=80></textarea></td></tr>\n\n";
   print "<tr><td align=center><br><b><i>Press the button below after all data entry is complete.  ";
   print "This will enter the preapproved text <br>record into the database and add it to the list of records awaiting proofreading.</i></b><br><br>\n";
   print "<tr><td align=center><input type=button name=entertext value=Submit onClick=verifyEntry('enter_text')> </td></tr>\n\n";
   print "</table></center> \n\n";
}
##End Enter Preapproved Text ##
#**************************************************************************************
# Process Enter Preapproved Text form
if ($command eq 'enter_text') { 
   (my $id) = $dbh->selectrow_array("SELECT $schema.preapproved_text_id.NEXTVAL from DUAL");
   my $text = $crdcgi->param("preapprovedtext");   
   my $texttype = $crdcgi->param("texttype");
   my $enteredby = &get_userid($dbh, $schema, $username);   
   my $entrydate = &get_date();
   my $sqlinsert = "insert into $schema.preapproved_text_entry (id, text, texttype, enteredby, entrydate) values ($id, :text, $texttype, $enteredby, '$entrydate')";
   my $csr = $dbh->prepare($sqlinsert);
   $csr->bind_param(":text", $text, { ora_type => ORA_CLOB, ora_field=>'text' });
   $csr->execute;
   my $message="Should not ever see this...";
   my $status = 0;
   if ($dbh->err) {
      $message = ($dbh->errstr);
      $message=~ s/"//g;
      $status = &log_error($dbh, $schema, $userid, $message);
      $status = 1;
   } else {
      my $formatid = &formatID('PAT', 4, $id);
      $message = "Preapproved Text ID: " . $formatid; 
      $status = 0;
      $dbh->commit;
   }
   $csr->finish;
   print "<form name=$form method=post target='main'>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=server value=$Server>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=username value=$username>\n\n";
   print "<input type=hidden name=command value=$command>\n\n";

   print " <script language=javascript><!-- \n";
   print " popit('$message'); \n";
   if ($status eq 0) {
      #print " goHome('home'); \n";
      print " submitForm('home', ''); \n";
   }
   print " //--> \n";
   print " </script> \n\n";
}
#**************************************************************************************
##Start Proofread Text##
if ($command eq 'proofread') {
   $title = "Proofread Preapproved Text";
   my $id=$crdcgi->param("id");
   my $sqlquery = "select id, enteredby, entrydate, texttype, text from $schema.preapproved_text_entry where id=$id";
   #$dbh->{LongTruncOk}=1;
   $dbh->{LongReadLen} = 100000000;
   my $csr = $dbh->prepare($sqlquery);
   $csr->execute;
   my $enteredby;
   my $entrydate;
   my $texttype;
   my $text;
   while (my @values = $csr->fetchrow_array) {
      ($id, $enteredby, $entrydate, $texttype, $text) = @values;
   }
   $csr->finish;
   my $enteredbyname = &get_username($dbh, $schema, $enteredby);   
   my $formatid = &formatID('PAT', 4, $id);
   my $oldtext = $text;
   print "<form name=$form method=post target='cgiresults'>\n";
   print "<input type=hidden name=command value=$command> \n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=server value=$Server>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=id value=$id>\n";
   print "<input type=hidden name=texttype value=$texttype>\n";
   print "<input type=hidden name=enteredby value=$enteredby>\n";
   print "<input type=hidden name=entrydate value=$entrydate>\n";
   print "<input type=hidden name=proofreadby value=$username>\n";
   print " <center><table border=0 width=680 align=center>\n\n";
   print "<tr><td><hr width=100% height=30></td></tr>\n\n";
   print "<tr><td align=center><table border=0>\n";
   print "<tr><td><b>ID:</b>&nbsp;&nbsp;&nbsp;</td><td align=left><b>$formatid</b></i></font></td></tr>\n";
   if ($id eq '1') {
      print "<tr><td align=left><b>Text Type:</b>&nbsp;&nbsp;&nbsp;</td><td align=left><b>Preapproved Response</b></i></font></td></tr>\n";
   }   elsif ($id eq '2') {
      print "<tr><td align=left><b>Text Type:</b>&nbsp;&nbsp;&nbsp;</td><td align=left><b>Message Point</b></i></font></td></tr>\n";
   }
   print "<tr><td><b>Entered by:</b>&nbsp;&nbsp;&nbsp;</td><td align=left><b>$enteredbyname</b></i></font></td></tr>\n";
   print "<tr><td><b>Entry Date:</b>&nbsp;&nbsp;&nbsp;</td><td align=left><b>$entrydate</b></i></font></td></tr>\n";
   print "</table></td></tr>\n\n";
   print "<tr><td><hr width=100% height=30></td></tr> \n";
   print "<tr><td>&nbsp;<br></td></tr> \n\n";
   print "<tr><td><b>Enter Text:&nbsp;&nbsp;</b></td></tr> \n";
   print "<tr><td><textarea name=preapprovedtext rows=10 cols=80>$text</textarea></td></tr> \n\n";
   print "<tr><td align=center><br><b><i>Press the button below after making all required additions and corrections.<br> ";
   print "This updates the record, marks it as having been verified for correctness,<br>and releases it for use by system users.</i></b><br><br>\n\n";
   print "<tr><td align=center><input type=button value=Submit name=proofreadtext onClick=verifyEntry('verify_text')> </td></tr>\n\n";
   print "</table></center> \n\n";
}
##End Proofread Text
#***********************************************************************************
# Process 'Proofread Preapproved Text' form
if ($command eq 'verify_text') { 
   my $id = $crdcgi->param("id");   
   my $proofreadby = &get_userid($dbh, $schema, $crdcgi->param("proofreadby"));
   my $proofreaddate=&get_date();
   my $newtext=$crdcgi->param("preapprovedtext");
   my $message="Should not ever see this...";
   my $status;
   my $sqlquery = "select text from $schema.preapproved_text_entry where id=$id";
   #$dbh->{LongTruncOk}=1;
   $dbh->{LongReadLen} = 100000000;
   my $csr = $dbh->prepare($sqlquery);
   $csr->execute;
   my $oldtext;
   while (my @values = $csr->fetchrow_array) {
      ($oldtext) = @values;
   }
   
   $csr->finish;
   if ($newtext ne $oldtext) {
      my $sqlupdate = "update $schema.preapproved_text_entry set text = :newtext where id=$id";
      my $csr = $dbh->prepare($sqlupdate);
      $csr->bind_param(":newtext", $newtext, { type => ORA_CLOB });
      $csr->execute; 
      $dbh->commit;
   }  
   
   $csr = $dbh->prepare(qq{
   $status = &process_document_entry(dbh=>$dbh, schema=>$schema, id=>$newid, proofreadby=>$proofreadby, proofreaddate=>$proofreaddate);
   
   if ($status eq 0) {
      $message .= sprintf("PAT%04d", $id);
      $dbh->commit;
   } else {
      $message = 'Proofread Failed - Note Error';
   }
   print "<form name=$form method=post target='main'>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=server value=$Server>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=command value=$command>\n";
   print " <script language=javascript><!-- \n";
   print " popit('$message'); \n";
   print " submitForm('home', ''); \n";
   #print " goHome('home'); \n";
   print " //--> \n";
   print " </script> \n\n";
}
#*************************************************************************
##Start Browse Preapproved Text ##
if ($command eq "browse") {
   $title = "Browse Preapproved Text";
   print "<form name=$form method=post target='main'>\n";
   print "<input type=hidden name=command value='view_text'> \n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=server value=$Server>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=username value=$username>\n\n";
   print "<input type=hidden name=id value='0'> \n";
   print "<center><table border=0 width=750 align=center>\n\n";
   print "<tr><td><br></td></tr>\n";
   my $sqlquery = "select id, proofreadby, proofreaddate, text from $schema.preapproved_text where texttype=1 order by id";
   $dbh->{LongTruncOk}=1;
   #$dbh->{LongReadLen} = 100000000;
   my $csr = $dbh->prepare($sqlquery);
   $csr->execute;
   print &start_table(4, 'center', 30,120,90,320);
   print &title_row('#000099', '#ffffff', "Preapproved Responses");
   print &add_header_row;
   print &add_col . "ID";
   print &add_col . "Proofread by";
   print &add_col . "Date Proofread";
   print &add_col . "Text";
   while (my @values = $csr->fetchrow_array) {
      (my $id, my $proofreadby, my $proofreaddate, my $text) = @values;
      print &add_row;
      my $formatid = &formatID('PAT', 4, $id);
      print &add_col_link ("javascript:browseText($id)").$formatid;  
      print &add_col_link("javascript:displayUser($proofreadby)").&get_fullname($dbh, $schema, $proofreadby);
      print &add_col . "$proofreaddate";
      $text = &getDisplayString($text, 45);
      print &add_col . "$text";
   }
   $csr->finish;
   print &end_table;
   print "<br>\n";
   print "<tr><td><br></td></tr>\n";
   $sqlquery = "select id, proofreadby, proofreaddate, text from $schema.preapproved_text where texttype=2 order by id";
   $dbh->{LongTruncOk}=1;
   #$dbh->{LongReadLen} = 100000000;
   $csr = $dbh->prepare($sqlquery);
   $csr->execute;
   print &start_table(4, 'center', 30,120,90,320);
   print &title_row('#000099', '#ffffff', "Message Points");
   print &add_header_row;
   print &add_col . "ID";
   print &add_col . "Proofread by";
   print &add_col . "Date Proofread";
   print &add_col . "Text";
   while (my @values = $csr->fetchrow_array) {
      (my $id, my $proofreadby, my $proofreaddate, my $text) = @values;
      print &add_row;
      my $formatid = &formatID('PAT', 4, $id);
      print &add_col_link ("javascript:browseText($id)").$formatid;  
      print &add_col_link("javascript:displayUser($proofreadby)").&get_fullname($dbh, $schema, $proofreadby);
      print &add_col . "$proofreaddate";
      $text = &getDisplayString($text, 45);
      print &add_col . "$text";
   }
   $csr->finish;
   print &end_table;
}
#************************************************************************
if ($command eq "view_text") {
   $title = "Browse Preapproved Text";
   my $id=$crdcgi->param("id");
   my $formatid = &formatID('PAT', 4, $id);   
   my $sqlquery = "select id, enteredby, entrydate, texttype, text from $schema.preapproved_text where id=$id";
   #$dbh->{LongTruncOk}=1;
   $dbh->{LongReadLen} = 100000000;
   my $csr = $dbh->prepare($sqlquery);
   $csr->execute;
   my $enteredby;
   my $entrydate;
   my $text;
   my $texttype;
   while (my @values = $csr->fetchrow_array) {
      ($id, $enteredby, $entrydate, $texttype, $text) = @values;
   }
   $csr->finish;
   $enteredby = &get_username($dbh, $schema, $enteredby);
   print "<form name=$form method=post target='cgiresults'>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=server value=$Server>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=command value=$command> \n\n";
   print "<center><table border=0 width=600 align=center>\n\n";
   print "<tr><td><hr width=100% height=30></td></tr>\n\n";
   print "<tr><td align=center><table border=0>\n";
   print "<tr><td><b>ID:</b>&nbsp;&nbsp;&nbsp;</td><td align=left><b>$formatid</b></i></font></td></tr>\n";
   if ($texttype eq 1) {
      print "<tr><td align=left><b>Text Type:</b>&nbsp;&nbsp;&nbsp;</td><td align=left><b>Preapproved Response</b></i></font></td></tr>\n";
      }   elsif ($texttype eq 2) {
          print "<tr><td align=left><b>Text Type:</b>&nbsp;&nbsp;&nbsp;</td><td align=left><b>Message Point</b></i></font></td></tr>\n";
        }
   print "<tr><td><b>Entered by:</b>&nbsp;&nbsp;&nbsp;</td><td align=left><b>$enteredby</b></i></font></td></tr>\n";
   print "<tr><td><b>Entry Date:</b>&nbsp;&nbsp;&nbsp;</td><td align=left><b>$entrydate</b></i></font></td></tr>\n";
   print "</table></td></tr>\n\n";
   print "<tr><td><hr width=100% height=30></td></tr>\n\n";
   print "<tr><td>&nbsp;</td></tr>\n";
   print "<tr><td><b>Text:</b></td></tr>\n";
   print "<tr><td><textarea name=preapprovedtext rows=10 cols=80>$text</textarea></td></tr>\n";
   print "<tr><td>&nbsp;</td></tr>\n";
   print "<tr><td align=center><input type=button name=backbrowse value=' Back ' onClick=\"submitForm('$form', 'browse')\"></td></tr>\n"; 
   print "</table></center>\n\n";
}
##End Browse Preapproved Text ##
#*********************************************************************
# default footer
print "</font> \n";
print "</form>\n";
print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $title) if ($title ne "");
print $crdcgi->end_html;
db_disconnect($dbh);
exit();
