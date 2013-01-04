#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/crd/perl/RCS/messages.pl,v $
#
# $Revision: 1.9 $
#
# $Date: 2002/02/20 16:49:15 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: messages.pl,v $
# Revision 1.9  2002/02/20 16:49:15  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.8  2001/08/18 01:14:57  mccartym
# add text box expanders
#
# Revision 1.7  2000/12/08 19:13:37  atchleyb
# removed changes made for using Miscellaneous.pm and reverted back to same code as 1.4
#
# Revision 1.4  2000/05/17 23:36:54  mccartym
# remove debug info
#
# Revision 1.3  2000/02/10 17:34:34  atchleyb
# removed form-verify.ps
#
# Revision 1.2  1999/11/04 15:46:43  mccartym
# title changes
#
# Revision 1.1  1999/08/02 03:03:58  mccartym
# Initial revision
#
#

use integer;
use strict;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use Sections;
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
my $dbh;
my $command = $crdcgi->param("command");
my $process = $crdcgi->param("process");
my $messageID = $crdcgi->param("id");
my $output = '';
my $instructionsColor = $CRDFontColor;
my $textRows = 4;
my $textColumns = 90;
my $errorstr = "";
my $dateFormat = 'DD-MON-YY HH24:MI:SS';

my %commands = (
   'sentbydisplay' => {
      'header' => 'Read Sent Message'
   },
   'senttodisplay' => {
      'header' => 'Read Message'
   },
   'compose' => {
      'header' => 'Send Message'
   },
   'reply' => {
      'header' => 'Send Reply'
   },
   'send' => {
   },
   'sentbydelete' => {
   },
   'senttodelete' => {
   }
);

sub writeControl {
   my %args = (
      name => 'button',
      useLinks => 1,
      @_,
   );
   return ($args{useLinks}) ? "<b><a href=javascript:$args{callback}>$args{label}</a></b>" : "<input type=button name=$args{name} value='$args{label}' onClick=javascript:$args{callback}>";
}

sub writeTextBox {
   my %args = (
      name => 'textBox',
      rows => $textRows,
      cols => $textColumns,
      text => "",
      left => "",
      right => "",
      readOnly => 0,
      drawBoxIfTextNull => 1,
      align => "",
      @_,
   );
   my $output = "<tr><td $args{align}>";
   if (($args{text} ne "") || $args{drawBoxIfTextNull}) {
      my $readOnly = ($args{readOnly}) ? "readonly" : "";
      my $expand = "<a href=\"javascript:expandTextBox(document.$form.$args{name},document.$args{name}_button,'force',5);\">\n";
      $expand .= "<img name=$args{name}_button border=0 src=$CRDImagePath/expand_button.gif></a>\n";
      $output .= "<table border=0 cellpadding=0 cellspacing=0>\n";
      $output .= "<td align=left valign=bottom><b>$args{left}</b></td><td align=right valign=bottom>$args{right}" . &nbspaces(3) . " $expand</td></tr>\n";
      $output .= "<tr><td colspan=2><textarea name=$args{name} rows=$args{rows} cols=$args{cols} wrap=physical $readOnly ";
      $output .= "onKeyPress=\"expandTextBox(this,document.$args{name}_button,'dynamic');\">$args{text}</textarea></td></tr></table>\n";
   } else {
      $output .= "<table cellpadding=0 cellspacing=0 border=0 width=100%><tr><td>$args{left}</td><td align=right>$args{right}</td></tr></table>";
   }
   $output .= '</td></tr>';
   return ($output);
}

sub processError {
   my %args = (
      @_,
   );
   $dbh->rollback;
   my $error = &errorMessage($dbh, $username, $userid, $schema, $args{activity}, $@);
   $error =  ('_' x 100) . "\n\n" . $error if ($errorstr ne "");
   $error =~ s/\n/\\n/g;
   $error =~ s/'/%27/g;
   $errorstr .= $error;
}

sub processSubmittedData {
   print $crdcgi->header('text/html');
   print "<html>\n<head>\n</head>\n<body>\n";
   my $activity = "";
   my $logActivity = 0;
   my $error = "";
   eval {
      if ($command eq 'send') {
         $activity = "send message - get a message id";
         my @row = $dbh->selectrow_array("select $schema.message_id.nextval from dual");
         my $messageID = $row[0];
         $activity = "send message - read parameters";
         my $subject = $crdcgi->param("subjectText");
         $subject =~ s/'/''/g;
         my $text = $crdcgi->param("messageText");
         my $sentTo = $crdcgi->param("sentTo");
         my $toUsername = &get_username($dbh, $schema, $sentTo);
         $activity = "send message $messageID from $username to $toUsername";
         my $csr = $dbh->prepare("insert into $schema.message (id, sentby, sentto, datesent, subject, text) values ($messageID, $userid, $sentTo, SYSDATE, '$subject', :param1)");
         $csr->bind_param(":param1", $text, {ora_type => ORA_CLOB, ora_field => 'text'});
         $csr->execute;
      } elsif ($command eq 'senttodelete') {
         my $messageID = $crdcgi->param("id");
         $activity = "delete received message $messageID";
         my $rc = $dbh->do("update $schema.message set senttodeleted = 'T' where id = $messageID");
      } elsif ($command eq 'sentbydelete') {
         my $messageID = $crdcgi->param("id");
         $activity = "delete sent message $messageID";
         my $rc = $dbh->do("update $schema.message set sentbydeleted = 'T' where id = $messageID");
      }
      $dbh->commit;
      $logActivity = 1;
      $form = 'home';
   };
   ###################################################################################################################################
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
      if ($form eq 'messages') {
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
}

sub displayMessage {
   my %args = (
      textName => 'messageText',
      subjectName => 'subjectText',
      @_,
   );
   my $left = "<b>Sent $args{sentText}:" . &nbspaces(2) . "<a href=javascript:display_user($args{user})>" . &get_fullname($dbh, $schema, $args{user}) . "</a></b>";
   my $right = "<b>Date:"  . &nbspaces(2) . "$args{date}</b>";
   my $length = length $args{subject};
   $args{subject} =~ s/'/%27/g;
   my $output = "<tr><td align=center><table>\n";
   $output .= "<tr><td height=40><b>Subject:</b>" . &nbspaces(3) . "<input type=text name='$args{subjectName}' size=$length readonly></td></tr>\n";
   $output .= "<script language=javascript>\nvar mytext ='$args{subject}';\ndocument.$form.$args{subjectName}.value = unescape(mytext);\n</script>\n";
   $output .= &writeTextBox(name => $args{textName}, text => $args{text}, left => $left, right => $right, readOnly => 'true');
   $output .= "</table></td></tr>\n";
   return ($output);
}

sub enterMessage {
   my %args = (
      textName => 'messageText',
      subjectName => 'subjectText',
      subjectSize => 60,
      subjectMaxLength => 100,
      subject => '',
      left => '<b>Message text:</b>',
      right => '',
      @_,
   );
   $args{subject} =~ s/'/%27/g;
   my $output = "<tr><td align=center><table>\n";
   $output .= "<tr><td><b>To:</b>" . &nbspaces(3) . "$args{to}</td></tr>\n";
   $output .= "<tr><td height=40><b>Subject:</b>" . &nbspaces(3) . "<input type=text name='$args{subjectName}' size=$args{subjectSize} maxlength=args{subjectMaxLength}></td></tr>\n";
   $output .= "<script language=javascript>\nvar mytext ='$args{subject}';\ndocument.$form.$args{subjectName}.value = unescape(mytext);\n</script>\n";
   $output .= &writeTextBox(name => $args{textName}, left => $args{left}, right => $args{right});
   $output .= "<tr><td align=center height=40>$args{submit}</td></tr>\n";
   $output .= "</table></td></tr>\n";
   return ($output);
}

sub processCommand {
   my $activity;
   $output .= "<tr><td align=center>\n";
   eval {
      if ($command eq 'senttodisplay') {
         $activity = 'read a message';
         my ($subject, $text, $sentBy, $date, $hasBeenRead) = $dbh->selectrow_array("select subject, text, sentby, to_char(datesent, '$dateFormat'), hasbeenread from $schema.message where id = $messageID");
         $dbh->do("update $schema.message set hasbeenread = 'T' where id = $messageID") if ($hasBeenRead eq 'F');
         $output .= &displayMessage (subject => $subject, text => $text, date => $date, user => $sentBy, sentText => 'by');
         my $home = &writeControl(label => 'Home', callback => "submitForm('home',0)");
         my $reply = &writeControl(label => 'Reply', callback => "message('reply',$messageID)");
         my $delete = &writeControl(label => 'Delete', callback => "message('senttodelete',$messageID)");
         $output .= "<tr><td align=center height=40><b>[" . &nbspaces(1) . "$home" . &nbspaces(2) . "|" . &nbspaces(2) . "$reply" . &nbspaces(2) . "|" . &nbspaces(2) . "$delete" . &nbspaces(1) . "]</b></td></tr>\n";
      } elsif ($command eq 'sentbydisplay') {
         $activity = 'view a sent message';
         my ($subject, $text, $sentTo, $date) = $dbh->selectrow_array("select subject, text, sentto, to_char(datesent, '$dateFormat') from $schema.message where id = $messageID");
         $output .= &displayMessage (subject => $subject, text => $text, date => $date, user => $sentTo, sentText => 'to');
         my $home = &writeControl(label => 'Home', callback => "submitForm('home',0)");
         my $delete = &writeControl(label => 'Delete', callback => "message('senttodelete',$messageID)");
         $output .= "<tr><td align=center height=40><b>[" . &nbspaces(1) . "$home" . &nbspaces(2) . "|" . &nbspaces(2) . "$delete" . &nbspaces(1) . "]</b></td></tr>\n";
      } elsif ($command eq 'reply') {
         my $messageID = $crdcgi->param("id");
         $activity = "send a reply to message $messageID";
         my ($subject, $text, $sentBy, $date) = $dbh->selectrow_array("select subject, text, sentby, to_char(datesent, '$dateFormat') from $schema.message where id = $messageID");
         my $to = "<b><a href=javascript:display_user($sentBy)>" . &get_fullname($dbh, $schema, $sentBy) . "</a></b>";
         my $submit = &writeControl(label => 'Send', callback => "message('send',$sentBy)", useLinks => 0);
         $output .= "<input type=hidden name=sentTo value=$sentBy>\n";
         $output .= &enterMessage(to => $to, subject => "Re: $subject", submit => $submit);
         $output .= "<tr><td align=center><br><hr width=90%><br><font size=+1>Original Message</font></td></tr>\n";
         $output .= &displayMessage(subject => $subject, text => $text, date => $date, user => $sentBy, sentText => 'by', textName => 'displayText', subjectName => 'displaySubject');
      } elsif ($command eq 'compose') {
         tie my %users, "Tie::IxHash";
         $activity = 'compose a message';
         my $csr = $dbh->prepare("select firstname, lastname, id from $schema.users where isactive = 'T' order by lastname, firstname");
         $csr->execute;
         while (my @values = $csr->fetchrow_array) {
            $users{$values[2]} = "$values[0] $values[1]";
         }
         my $to = &build_drop_box('sentTo', \%users, 0);
         my $submit = &writeControl(label => 'Send', callback => "message('send')", useLinks => 0);
         $output .= &enterMessage(to => $to, submit => $submit);
      }
   };
   &processError(activity => $activity) if ($@);
   $output .= "</td></tr>\n";
}

sub writeHTTPHeader {
   print $crdcgi->header('text/html');
}

sub writeHead {
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
      function display_user(userid) {
         document.dummy.id.value = userid;
         document.dummy.command.value = 'displayuser';
         document.dummy.action = '$path' + 'user_functions' + '.pl';
         document.dummy.submit();
      }
      function message(command, id) {
         var doit = 1;
         if (command == 'send') {
            if (isblank(document.$form.subjectText.value)) {
               doit = 0;
               alert("No text has been entered in subject field.");
            } else if (isblank(document.$form.messageText.value)) {
               doit = 0;
               alert("No text has been entered in the message field.");
            }
         }
         if (doit) {
            if (message.arguments.length > 1) {
               if (command == 'send') {
                  document.$form.sentTo.value = id;
               } else {
                  document.$form.id.value = id;
               }
            }
            document.$form.process.value = ((command == 'send') || (command == 'sentbydelete') || (command == 'senttodelete')) ? 1 : 0;
            document.$form.target = ((command == 'send') || (command == 'sentbydelete') || (command == 'senttodelete'))  ? 'cgiresults' : 'main';
            submitForm('messages', command);
         }
      }
end
   print "   //-->\n";
   print "   </script>\n";
   print &sectionHeadTags($form);
   print "</head>\n\n";
}

sub writeBody {
   print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n<center>\n";
   print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => ${$commands{$command}}{'header'});
   print "<form name=$form method=post>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=command value=$command>\n";
   print "<input type=hidden name=process value=0>\n";
   print "<input type=hidden name=id value=0>\n";
   print "<table width=775 cellpadding=0 cellspacing=0 border=0>\n";
   print $output;
   print "</table>\n</form>\n";
   print "<form name=dummy method=post>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=command value=0>\n";
   print "<input type=hidden name=id value=0>\n";
   print "</form>\n</center>\n</font>\n";
   print "<script language=javascript>\n<!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n" if ($errorstr);
   print "</body>\n</html>\n";
}

$dbh = db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;
if ($process) {
   &processSubmittedData();
} else {
   &processCommand();
   &writeHTTPHeader();
   &writeHead();
   &writeBody();
}
db_disconnect($dbh);
exit();
