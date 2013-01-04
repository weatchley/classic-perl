#!/usr/local/bin/perl -w
#
# $Source: /home/atchleyb/rcs/plaqads/perl/RCS/header.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2004/11/09 19:08:13 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: header.pl,v $
# Revision 1.2  2004/11/09 19:08:13  atchleyb
# updated to add search button
#
# Revision 1.1  2004/07/27 18:27:16  atchleyb
# Initial revision
#
#
#
#
#
use integer;
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UI_Widgets qw(:Functions);
use CGI;
my $mycgi = new CGI;
my $username = defined($mycgi->param("username")) ? $mycgi->param("username") : "None";
my $userid = defined($mycgi->param("userid")) ? $mycgi->param("userid") : "None";
my $schema = defined($mycgi->param("schema")) ? $mycgi->param("schema") : "None";
my $Server = defined($mycgi->param("server")) ? $mycgi->param("server") : $SYSServer;
my $title = defined($mycgi->param("title")) ? $mycgi->param("title") : "None";
my $sessionID = defined($mycgi->param("sessionid")) ? $mycgi->param("sessionid") : "0";
my $command = $mycgi->param("command");
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

print $mycgi->header('text/html');
print "<html>\n";
my ($head, $body) = ("<head>\n", "<body background=$SYSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n");
if ($command eq "title") {
   $head .= "<script src=$SYSJavaScriptPath/utilities.js></script>\n";
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
   #my $loggedIn = 0;
   my $logoRowSpan = ($loggedIn) ? 2 : 1;
   my @buttons;
   if ($username eq 'GUEST') {
       #@buttons = ("login", "browse", "search", "reports");
       @buttons = ("login", "search", "browse");
   } else {
       #@buttons = ("home", "browse", "search", "reports", "utilities");
       @buttons = ("home", "browse", "search", "utilities");
   }
   my %buttonCommand =(
       home => "",
       login => "login",
       browse => "",
       search => "",
       reports => "",
       utilities => ""
   );
   my %buttonText = (
       home => "Home",
       login => "login",
       browse => "Browse",
       search => "Search",
       reports => "Reports",
       utilities => "Utilities"
   );
   $head .= "<script language=javascript><!--\n";
   $head .= "if (document.images) {\n";
   foreach my $button (@buttons) {
      $head .= "   var $button" . "off = new Image();\n";
      $head .= "   $button" . "off.src = \"$SYSImagePath/buttons/$button" . ".gif\"\n";
      $head .= "   var $button" . "on = new Image();\n";
      $head .= "   $button" . "on.src = \"$SYSImagePath/buttons/$button" . "_ovr.gif\"\n";
      $head .= "   var $button" . "press = new Image();\n";
      $head .= "   $button" . "press.src = \"$SYSImagePath/buttons/$button" . "_dwn.gif\"\n";
   }
   $head .= "}\n";
   $head .= "function show(button, state) {\n";
   $head .= "   document[button].src = eval(button + state + '.src');\n";
   $head .= "}\n";
   $head .= "function submitForm(script,command) {\n";
   $head .= "   document.$form.action = '$path' + script + '.pl';\n";
   $head .= "   document.$form.command.value = command;\n";
   $head .= "   document.$form.submit();\n";
   $head .= "}\n";
   $head .= "//-->\n</script>\n</head>\n";
   $body .= "<form name=$form target=main method=post>\n";
   $body .= "<input type=hidden name=username value=$username>\n";
   $body .= "<input type=hidden name=userid value=$userid>\n";
   $body .= "<input type=hidden name=schema value=$schema>\n";
   $body .= "<input type=hidden name=command value=0>\n";
   $body .= "<input type=hidden name=server value=$Server>\n";
   $body .= "<input type=hidden name=sessionid value=$sessionID>\n";
#
   #$body .= "<table border=0 cellspacing=0 cellpadding=0 width=750>\n";
   #$body .= "<tr><td rowspan=3 valign=top width=2><img src=$SYSImagePath/logo.gif width=127 height=108 border=0></td>\n";
   #$body .= "<td valign=top align=center><font size=+3><b>$SYSTitle</b></font></td></tr>\n";
   #if ($loggedIn) {
   #   $body .= "<tr><td valign=top><table border=0 cellpadding=0 cellspacing=1 align=center><tr>\n";
   #   foreach my $button (@buttons) {
   #      $body .= "<td bgcolor=00ff00><a href=javascript:submitForm('$button','$buttonCommand{$button}')>";
   #      $body .= "<b>$buttonText{$button}</b></a></td>\n";
   #   }
   #   $body .= "</tr></table></td></tr>";
   #}
   #my $titlepath = $path . "text_labels.pl?width=390&size=15&parsetitle=T";
   #$body .= "<tr><td valign=top align=center><img src='$titlepath&text=Login' name=titleimage width=390 height=25></td></tr>\n";
   #$body .= "<tr><td colspan=2><hr></td></tr>\n";
   #$body .= "</table>\n";
#
   $body .= "<table border=0><tr><td rowspan=$logoRowSpan><img src=$SYSImagePath/logo.gif width=127 height=108 border=0></td>\n";
   $body .= "<td align=center><img src=$SYSImagePath/title.gif width=425 height=63 border=0></td></tr>\n";
   if ($loggedIn) {
      $body .= "<tr><td align=center><table cellspacing=0 cellpadding=0 border=0><tr>\n";
      foreach my $button (@buttons) {
         $body .= "<td><a href=javascript:submitForm('$button','$buttonCommand{$button}') ";
         $body .= "onMouseOver=show('$button','on') onMouseOut=show('$button','off') onMouseDown=show('$button','press') onMouseUp=show('$button','on')>";
         $body .= "<img src=$SYSImagePath/buttons/$button" . ".gif name=$button border=0></a>&nbsp;</td>\n";
      }
      $body .= "</tr></table></td></tr>";
   }
#
   $body .= "</table>\n</center>\n";
   $body .= "</form>\n";
   $body .= "</body>\n";
}
print "$head$body</html>\n";
exit();
