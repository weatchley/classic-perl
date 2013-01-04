#!/usr/local/bin/newperl -w
#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
#
#
use integer;
use strict;
use BMS_Header qw(:Constants);
use DB_Utilities_Lib qw(:Functions);
use UI_Widgets qw(:Functions);
use CGI;
my $bmscgi = new CGI;
my $username = defined($bmscgi->param("username")) ? $bmscgi->param("username") : "None";
my $userid = defined($bmscgi->param("userid")) ? $bmscgi->param("userid") : "None";
my $schema = defined($bmscgi->param("schema")) ? $bmscgi->param("schema") : "None";
my $Server = defined($bmscgi->param("server")) ? $bmscgi->param("server") : $BMSServer;
my $title = defined($bmscgi->param("title")) ? $bmscgi->param("title") : "None";
my $command = $bmscgi->param("command");
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

print $bmscgi->header('text/html');
print "<html>\n";
my ($head, $body) = ("<head>\n", "<body background=$BMSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n");
if ($command eq "title") {
   $head .= "<script src=$BMSJavaScriptPath/utilities.js></script>\n";
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
   #my $loggedIn = (($username ne "None") && ($userid ne "None") && ($schema ne "None"));
   my $loggedIn = 1;
   my $logoRowSpan = ($loggedIn) ? 2 : 1;
   my @buttons;
   if ($username eq 'GUEST') {
       @buttons = ("login", "browse", "search", "reports");
       #@buttons = ("login", "browse");
   } else {
       @buttons = ("home", "browse", "search", "reports", "utilities");
       #@buttons = ("home", "browse", "utilities");
   }
   my %buttonCommand =(
       home => "",
       login => "login",
       browse => "",
       search => "",
       reports => "",
       utilities => ""
   );
   $head .= "<script language=javascript><!--\n";
   $head .= "if (document.images) {\n";
   foreach my $button (@buttons) {
      $head .= "   var $button" . "off = new Image();\n";
      $head .= "   $button" . "off.src = \"$BMSImagePath/buttons/$button" . ".gif\"\n";
      $head .= "   var $button" . "on = new Image();\n";
      $head .= "   $button" . "on.src = \"$BMSImagePath/buttons/$button" . "_ovr.gif\"\n";
      $head .= "   var $button" . "press = new Image();\n";
      $head .= "   $button" . "press.src = \"$BMSImagePath/buttons/$button" . "_dwn.gif\"\n";
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
   $body .= "<input type=hidden name=sessionid value=" . (defined($bmscgi->param("sessionid")) ? $bmscgi->param("sessionid") : "None") . ">\n";
   $body .= "<input type=hidden name=schema value=$schema>\n";
   $body .= "<input type=hidden name=command value=0>\n";
   $body .= "<input type=hidden name=server value=$Server>\n";
   $body .= "<table border=0><tr><td rowspan=$logoRowSpan><img src=$BMSImagePath/logo.gif width=127 height=108 border=0></td>\n";
   $body .= "<td align=center><img src=$BMSImagePath/title.gif width=425 height=63 border=0></td></tr>\n";
   if ($loggedIn) {
      $body .= "<tr><td align=center><table cellspacing=0 cellpadding=0 border=0><tr>\n";
      foreach my $button (@buttons) {
         $body .= "<td><a href=javascript:submitForm('$button','$buttonCommand{$button}') ";
         $body .= "onMouseOver=show('$button','on') onMouseOut=show('$button','off') onMouseDown=show('$button','press') onMouseUp=show('$button','on')>";
         $body .= "<img src=$BMSImagePath/buttons/$button" . ".gif name=$button border=0></a>&nbsp;</td>\n";
      }
      $body .= "</tr></table></td></tr>";
   }
   $body .= "</table>\n</center>\n";
   $body .= "</form>\n";
   $body .= "</body>\n";
}
print "$head$body</html>\n";
exit();
