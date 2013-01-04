#!/usr/local/bin/perl -w

# CGI user login for the SCM
#
# $Source: /data/dev/rcs/scm/perl/RCS/login.pl,v $
#
# $Revision: 1.5 $
#
# $Date: 2002/10/21 22:22:26 $
#
# $Author: atchleyb $
#
# $Locker: atchleyb $
#
# $Log: login.pl,v $
# Revision 1.5  2002/10/21 22:22:26  atchleyb
# changed user_functions.pl to user.pl
#
# Revision 1.4  2002/10/01 16:18:38  atchleyb
# updated to reset cgiresults to blank after login
#
# Revision 1.3  2002/09/18 21:34:48  atchleyb
# fixed bug in calling the log activity funciton
#
# Revision 1.2  2002/09/18 01:15:03  mccartym
# changed system name in title
#
# Revision 1.1  2002/09/17 21:27:00  starkeyj
# Initial revision
#
#
#

use strict;
use integer;
use SCM_Header qw(:Constants);
use CGI;
use DB_scm qw(:Functions);
use UI_Widgets;
use DBI;

my $scmcgi = new CGI;
my $schema = (defined($scmcgi->param("schema"))) ? $scmcgi->param("schema") : $ENV{'SCHEMA'};
my $command = $scmcgi->param("command");
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $urllocation;
my $username = (defined($scmcgi->param("username"))) ? uc($scmcgi->param("username")) : "None";
my $password = (defined($scmcgi->param("password"))) ? $scmcgi->param("password") : "None";
my $userid = 0;
my $error = "";
my $dbh;

print $scmcgi->header('text/html');
print <<end;
<html>
<head>
   <meta http-equiv=expires content=now>
   <title>Software Configuration Management System</title>
   <script language=javascript><!--
      function submitForm(script, command) {
         document.$form.command.value = command;
         document.$form.action = '$path' + script + '.pl';
         document.$form.submit();
      }
      function submitFormStatus(script, command) {
         document.$form.command.value = command;
         document.$form.target = 'status';
         document.$form.action = '$path' + script + '.pl';
         document.$form.submit();
      }
      function browserNotExplorer() {
         return(navigator.appName.indexOf('Internet Explorer') == -1);
      }
      function browserLessThanFour() {
         var mozilla = "Mozilla/";
         return((navigator.userAgent.charAt(navigator.userAgent.indexOf(mozilla) + mozilla.length)) < 4);
      }
      if (browserNotExplorer() || browserLessThanFour()) {
         alert('Internet Explorer version 4.0 or greater is required to access the database.');
         window.location.href = (document.referrer != "") ? document.referrer : '/default.htm';        
     };
   //-->
   </script>
</head>
end

if (!(defined($command))) {
# make cgiresults size 0 on prod
   print "<frameset rows=115,60,*," . (($SCMDebug) ? "55" : "51") ." border=0 framespacing=0>\n";
   print "   <frame src=" . $path . "header.pl?command=header&username=$username&userid=$userid&schema=$schema name=header frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
   #print "   <frame src=" . $path . "header.pl?command=title&title=Login name=status frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
   print "   <frame src=" . $path . "title_bar.pl?title=Login&username=$username&userid=$userid&schema=$schema name=status frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
   print "   <frame src=" . $path . "login.pl?command=makeform&schema=$schema name=main frameborder=no noresize marginwidth=0 marginheight=0>\n";
   #print "   <frame src=" . $path . "browse.pl?schema=$schema&username=$username&userid=$userid name=main frameborder=no noresize marginwidth=0 marginheight=0>\n";
   print "   <frame src=" . $path . "blank.pl name=cgiresults frameborder=no scrolling=yes noresize marginwidth=0 marginheight=0>\n";
   print "</frameset>\n";
} else {
   # my $message = "The $SCMType Comment/Response Database will be unavailable between 5:00 and 7:00 PM on Friday, July 21 for maintenance";
   my $message = "";
   my $onload = (($command eq 'makeform') && $message) ? "onload=\"alert('$message')\"" : "" ;
   print "<body background=$SCMImagePath/background.gif text=$SCMFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0 $onload>\n";
   print &writeTitleBar(userName => 'None', userID => 'None', schema => 'None', title => "Login");
   print "<font face=$SCMFontFace color=$SCMFontColor><center>\n";
   print "<form name=$form target=cgiresults action=$ENV{SCRIPT_NAME} method=post>\n";
   print "<input type=hidden name=command value=login_action>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   if ($command ne "login_action") {
      print "<table border=0 cellpadding=6 cellspacing=3><tr><td><font size=4>Username:</font></td><td><input type=text name=username size=8 maxlength=8></td></tr>\n";
      print "<tr><td><font size=4>Password:</font></td><td><input type=password name=password size=15 maxlength=15></td></tr>\n";
      print "<tr><td align=center colspan=2><input type=submit name=submit value=Login></td></tr></table>\n";
      print "<script language=javascript><!--\ndocument.$form.username.focus();\n//--></script>\n";
   } else {
      my $changePassword = 0;
      $dbh = &db_connect;
      eval {
         my $status = &validate_user($dbh, $schema, $username, $password);
         if ($status != 1) {
             $error = "Invalid username or password";
         } else {
            $userid = &get_userid($dbh, $schema, $username);
            $urllocation = $path . "home.pl?username=$username&userid=$userid";
            if (db_encrypt_password($password) ne db_encrypt_password($DefPassword)) {
               $urllocation = $path . "home.pl?username=$username&userid=$userid&schema=$schema";
            } else { # must change password from default password
               $urllocation = $path . "users.pl?command=changepasswordform&username=$username&userid=$userid&schema=$schema&passwordflag=T";
               $changePassword = 1;
            }
         }
      };
      if ($@) {
         $dbh->rollback;
         $error = &errorMessage($dbh, $username, 0, $schema, "process login for $username", $@);
      }
      if ($error) {
         $error =~ s/\n/\\n/g;
         $error =~ s/'/%27/g;
         print "<script language=javascript>\n<!--\nvar mytext ='$error';\nalert(unescape(mytext));\n//-->\n</script>\n";     
      } elsif (defined($urllocation) && $urllocation ne "") {
         #&updateActivityLog($dbh, $schema, $userid, "user $username logged in", "F");
         &log_activity ($dbh, $schema, $userid, "user $username logged in");
         print "<script language=javascript><!--\n";
         print "   var newurl ='$urllocation';\n";
         print "   parent.main.location=newurl;\n";
         
         if (!$changePassword) { # redraw the header if password doesn't need to be changed
            print "   newurl = '" . $path . "header.pl?username=$username&userid=$userid&schema=$schema&command=header';\n";
            print "   parent.header.location = newurl;\n";
         }
         
         print "//--></script>\n";
         print "<input type=hidden name=username value=$username>\n";
         print "<input type=hidden name=userid value=$userid>\n";
         print "<input type=hidden name=title value=home>\n";
         print "<script language=javascript><!--\n";
         print "   submitFormStatus('title_bar','none');\n";
         print "//--></script>\n";
      }
      print "<script language=javascript><!--\n";
      print "   document.location = 'blank.pl';\n";
      print "//--></script>\n";
      db_disconnect($dbh);
   }
   print "</form>\n</center>\n</font>\n</body>\n";
}
print "</html>\n";
exit();
