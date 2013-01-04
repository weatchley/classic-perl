#!/usr/local/bin/newperl -w

# CGI user login for the CRD
#
# $Source: /data/dev/rcs/crd/perl/RCS/login.pl,v $
#
# $Revision: 1.7 $
#
# $Date: 2004/05/26 22:06:17 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: login.pl,v $
# Revision 1.7  2004/05/26 22:06:17  atchleyb
# updated to use newer password security
#
# Revision 1.6  2004/02/26 16:17:27  atchleyb
# added check to force secure login (CR042)
#
# Revision 1.5  2001/06/27 01:26:29  mccartym
# checkpoint
#
# Revision 1.4  1999/08/12 15:48:06  atchleyb
# took care of quotes in input fields
#
# Revision 1.3  1999/07/28 22:23:43  atchleyb
# got rid hard coded paths
#
# Revision 1.2  1999/07/14 18:28:56  atchleyb
# updated to force password change on initial login along with some other minor changes
#
# Revision 1.1  1999/07/06 18:01:10  atchleyb
# Initial revision
#

use strict;
use integer;
use CRD_Header qw(:Constants);
use CGI;
use DB_Utilities_Lib qw(:Functions);
use DBI;

my $crdcgi = new CGI;
my $schema = (defined($crdcgi->param("schema"))) ? $crdcgi->param("schema") : $ENV{'SCHEMA'};
my $command = $crdcgi->param("command");
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $urllocation;
my $username = (defined($crdcgi->param("username"))) ? uc($crdcgi->param("username")) : "";
my $password = (defined($crdcgi->param("password"))) ? $crdcgi->param("password") : "";
my $userid;
my $error = "";
my $dbh;
if (!(defined($ENV{HTTPS}) && $ENV{HTTPS} eq 'on')) {
    print "Location: https://$ENV{SERVER_NAME}$1" . "login.pl\n\n";
}

print $crdcgi->header('text/html');
print <<end;
<html>
<head>
   <meta http-equiv=expires content=now>
   <title>$CRDType Comment Response Database</title>
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
   print "<frameset rows=115,60,*,1 border=0 framespacing=0>\n";
   print "   <frame src=" . $path . "header.pl?command=header name=header frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
   #print "   <frame src=" . $path . "header.pl?command=title&title=Login name=status frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
   print "   <frame src=" . $path . "title_bar.pl?title=Login name=status frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
   print "   <frame src=" . $path . "login.pl?command=makeform&schema=$schema name=main frameborder=no noresize marginwidth=0 marginheight=0>\n";
   print "   <frame src=" . $path . "blank.pl name=cgiresults frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
   print "</frameset>\n";
} else {
   # my $message = "The $CRDType Comment/Response Database will be unavailable between 5:00 and 7:00 PM on Friday, July 21 for maintenance";
   my $message = "";
   my $onload = (($command eq 'makeform') && $message) ? "onload=\"alert('$message')\"" : "" ;
   print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0 $onload>\n";
   print "<font face=$CRDFontFace color=$CRDFontColor><center>\n";
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
      $dbh = db_connect();
      eval {
         my $status = &validate_user($dbh, $schema, $username, $password);
         if ($status != 1) {
             $error = "Invalid username or password";
         } else {
            $userid = &get_userid($dbh, $schema, $username);
            my ($PEdateTime, $dateTime, $daysRemaining) = &getPasswordExpiration(dbh => $dbh, schema => $schema, userID => $userid);
            $urllocation = $path . "home.pl?username=$username&userid=$userid";
            if ($dateTime lt $PEdateTime) {
                if (db_encrypt_password($password) ne db_encrypt_password($DefPassword)) {
                   $urllocation = $path . "home.pl?username=$username&userid=$userid&schema=$schema";
                    if ($daysRemaining < $SYSPasswordExpireWarn) {
                        my $expMessage = "in $daysRemaining day" . (($daysRemaining != 1) ? "s" : "");
                        if ($daysRemaining == 0) {$expMessage = "today";}
                        print "<script language=javascript><!--\n";
                        print "alert('Your password will expire $expMessage!\\n Please change it.');\n";
                        print "//--></script>\n";
                    }
                } else { # must change password from default password
                   $urllocation = $path . "user_functions.pl?command=changepasswordform&username=$username&userid=$userid&schema=$schema&passwordflag=T";
                   $changePassword = 1;
                }
            } else { # must change password
                print "<script language=javascript><!--\n";
                print "alert('Your password has expired!\\n Please change it.');\n";
                print "//--></script>\n";
                $urllocation = $path . "user_functions.pl?command=changepasswordform&username=$username&userid=$userid&schema=$schema&passwordflag=T";
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
      db_disconnect($dbh);
   }
   print "</form>\n</center>\n</font>\n</body>\n";
}
print "</html>\n";
exit();
