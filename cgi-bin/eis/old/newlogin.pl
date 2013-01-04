#!/usr/local/bin/newperl -w

# CGI user login for the CRD
#
# $Source: /data/dev/eis/perl/RCS/login.pl,v $
#
# $Revision: 1.4 $
#
# $Date: 1999/08/12 15:48:06 $
#
# $Author: atchleyb $
#
# $Locker: mccartym $
#
# $Log: login.pl,v $
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
use UI_Widgets qw(:Functions);
use DBI;

my $crdcgi = new CGI;
my $schema = (defined($crdcgi->param("schema"))) ? $crdcgi->param("schema") : $ENV{'SCHEMA'};
my $command = $crdcgi->param("command");
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $username = (defined($crdcgi->param("username"))) ? uc($crdcgi->param("username")) : "";
my $password = (defined($crdcgi->param("password"))) ? $crdcgi->param("password") : "";
my $userid;
my $error = "";
my $process = defined($crdcgi->param("process")) ? $crdcgi->param("process") : 0;

sub writeHTTPHeader {
   print $crdcgi->header('text/html');
}

sub processSubmittedData {
   if ($command eq "frameset") {
      print "<frameset rows=115,60,*,1 border=0 framespacing=0>\n";
      print "   <frame src=" . $path . "header.pl?command=header name=header frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
      print "   <frame src=" . $path . "header.pl?command=status&title=Login name=status frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
      print "   <frame src=" . $path . "login.pl?command=makeform&schema=$schema name=main frameborder=no noresize marginwidth=0 marginheight=0>\n";
      print "   <frame src=" . $path . "blank.pl name=cgiresults frameborder=no scrolling=no noresize marginwidth=0 marginheight=0>\n";
      print "</frameset>\n";
   } elsif ($comand eq "authenticate") {
      my $dbh = db_connect();
      my $changePassword = 0;
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
      } else {
         &log_activity ($dbh, $schema, $userid, "user $username logged in");
         print "<script language=javascript><!--\n";
         print "   var newurl ='$urllocation';\n";
         print "   parent.main.location=newurl;\n";
         if (!$changePassword) { # redraw the header if password doesn't need to be changed
            print "   newurl = '" . $path . "header.pl?username=$username&userid=$userid&schema=$schema&command=header';";
            print "   parent.header.location = newurl;\n";
         }
         print "//--></script>\n";
      }
      db_disconnect($dbh);
   }
}

sub writeHead {
   print <<end;
<html>
<head>
   <meta http-equiv=expires content=now>
   <title>$CRDType Comment Response Database</title>
   <script language=javascript><!--
      function submitForm(command) {
         document.$form.command.value = 'authenticate';
         document.$form.action = "$path$form.pl";
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
}

sub writeBody {
   print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
   print "<img src=$CRDImagePath/title.jpg width=700 height=75 border=0>\n";
   print "<font face=$CRDFontFace color=$CRDFontColor><center>\n";
   print "<form name=$form method=post>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=process value=1>\n";
   print "<table border=0 cellpadding=6 cellspacing=3><tr><td><font size=4>Username:</font></td><td><input type=text name=get_username size=8 maxlength=8></td></tr>\n";
   print "<tr><td><font size=4>Password:</font></td><td><input type=password name=get_password size=15 maxlength=15></td></tr>\n";
   print "<tr><td align=center colspan=2><input type=button name=login value=Login onClick=javascript:submitForm()></td></tr></table>\n";
   print "<script language=javascript><!--\ndocument.$form.username.focus();\n//--></script>\n";
   print "</form>\n</center>\n</font>\n</body>\n</html>\n";
}

if ($process) {
   &processSubmittedData();
} else {
   &writeHTTPHeader();
   &writeHead();
   &writeBody();
}
exit();
