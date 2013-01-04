#!/usr/local/bin/newperl -w
#
# $Source:$
# $Revision:$
# $Date:$
# $Author:$
# $Locker:$
#
# $Log:$
#

use integer;
use strict;
use SCM_Header qw(:Constants);
use DB_Utilities_Lib qw(:Functions);
use UI_Widgets qw(:Functions);
use CGI;
my $scmcgi = new CGI;
my $username = defined($scmcgi->param("username")) ? $scmcgi->param("username") : "None";
my $userid = defined($scmcgi->param("userid")) ? $scmcgi->param("userid") : "None";
my $schema = defined($scmcgi->param("schema")) ? $scmcgi->param("schema") : "None";
my $Server = defined($scmcgi->param("server")) ? $scmcgi->param("server") : $SCMServer;
my $title = defined($scmcgi->param("title")) ? $scmcgi->param("title") : "None";
my $command = $scmcgi->param("command");
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

print $scmcgi->header('text/html');
print "<html>\n";
my ($head, $body) = ("<head>\n", "<body background=$SCMImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n");
if ($command eq "title") {
   $head .= "<script src=$SCMJavaScriptPath/utilities.js></script>\n";
   $head .= "<script language=javascript><!--\n";
   $head .= "   var o_username = \"\";\n";
   $head .= "   var o_userid = \"\";\n";
   $head .= "   var o_schema = \"\";\n";
   $head .= "//-->\n";
   $head .= "</script>\n";
   $head .= "</head>\n";
   $body .= &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $title);
   $body .= "</center></body>\n";
} elsif ($command eq "header") {
   my $loggedIn = (($username ne "None") && ($userid ne "None") && ($schema ne "None"));
   my $buttonFileType = "jpg";
   my $buttonSize = "rounded";
   my $buttonHeight = ($buttonSize eq "large") ? 30 : 27;
   my $buttonWidth = ($buttonSize eq "large") ? 100 : 90;
   my $logoRowSpan = ($loggedIn) ? 2 : 1;
   my @buttons = ("home", "browse", "search", "reports", "utilities");
   $head .= "<script language=javascript><!--\n";
   $head .= "if (document.images) {\n";
   foreach my $button (@buttons) {
      $head .= "   var $button" . "off = new Image();\n";
      $head .= "   $button" . "off.src = \"$SCMImagePath/buttons/$button/$buttonSize/" . "off.$buttonFileType\"\n";
      $head .= "   var $button" . "on = new Image();\n";
      $head .= "   $button" . "on.src = \"$SCMImagePath/buttons/$button/$buttonSize/" . "on.$buttonFileType\"\n";
      $head .= "   var $button" . "press = new Image();\n";
      $head .= "   $button" . "press.src = \"$SCMImagePath/buttons/$button/$buttonSize/" . "press.$buttonFileType\"\n";
   }
   $head .= "}\n";
   $head .= "function show(button, state) {\n";
   $head .= "   document[button].src = eval(button + state + '.src');\n";
   $head .= "}\n";
   $head .= "function submitForm(script) {\n";
   $head .= "   document.$form.action = '$path' + 'scr' + script + '.pl';\n";
   $head .= "   document.$form.submit();\n";
   $head .= "}\n";
   $head .= "//-->\n</script>\n</head>\n";
   $body .= "<form name=$form target=main method=post>\n";
   $body .= "<input type=hidden name=username value=$username>\n";
   $body .= "<input type=hidden name=userid value=$userid>\n";
   $body .= "<input type=hidden name=schema value=$schema>\n";
   $body .= "<input type=hidden name=server value=$Server>\n";
   $body .= "<table border=0><tr><td rowspan=$logoRowSpan><img src=$SCMImagePath/logo.gif width=127 height=108 border=0></td>\n";
   $body .= "<td align=center><img src=$SCMImagePath/title.gif width=425 height=63 border=0></td></tr>\n";
   if ($loggedIn) {
      $body .= "<tr><td align=center><table cellspacing=0 cellpadding=0 border=0><tr>\n";
      foreach my $button (@buttons) {
         $body .= "<td><a href=javascript:submitForm('$button') ";
         $body .= "onMouseOver=show('$button','on') onMouseOut=show('$button','off') onMouseDown=show('$button','press') onMouseUp=show('$button','on')>";
         $body .= "<img src=$SCMImagePath/buttons/$button/$buttonSize/" . "off.$buttonFileType name=$button width=$buttonWidth height=$buttonHeight border=0></a></td>\n";
      }
      $body .= "</tr></table></td></tr>";
   }
   $body .= "</table>\n</center>\n";
   $body .= "</form>\n";
   $body .= "</body>\n";
}
print "$head$body</html>\n";
exit();
