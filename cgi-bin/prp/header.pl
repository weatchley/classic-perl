#!/usr/local/bin/perl -w
#
# $Source: /usr/local/homes/gilmored/rcs/prp/perl/RCS/header.pl,v $
# $Revision: 1.4 $
# $Date: 2009/02/06 19:57:26 $
# $Author: gilmored $
# $Locker: gilmored $
#
# $Log: header.pl,v $
# Revision 1.4  2009/02/06 19:57:26  gilmored
# Change default form type to makeform
#
# Revision 1.3  2005/09/29 15:15:46  naydenoa
# Phase 3 implementation
#
# Revision 1.2  2004/06/16 21:30:11  naydenoa
# Updated buttons depending on privilege
#
# Revision 1.1  2004/04/22 20:47:53  naydenoa
# Initial revision
#
#

use integer;
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UI_Widgets qw(:Functions);
use CGI;

my $dbh;
$dbh = &db_connect();

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
my ($head, $body) = ("<head>\n", "<body bgcolor=#eeeeee text=#000000 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n");

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
} 
elsif ($command eq "header") {
    my $loggedIn = (($username ne "None") && ($userid ne "None") && ($schema ne "None"));
    #my $loggedIn = 0;
    my $logoRowSpan = ($loggedIn) ? 2 : 1;
    my @buttons;
    if ($username eq 'GUEST') {
        @buttons = ("login", "browse", "search", "reports","help");
    }
    elsif ($loggedIn && &doesUserHavePriv (dbh => $dbh, schema => $schema, userid => $userid, privList => [3, 4, 5, 6, -1])) {
        @buttons = ("home", "browse", "search", "reports", "utilities", "help");
    } 
    else {
        @buttons = ("browse", "search", "reports", "utilities", "help");
    }
    my %buttonCommand =(
       home => "",
#       login => "login",
       login => "makeform",
       browse => "",
       search => "",
       reports => "",
       utilities => "",
       help => "view_help"
    );
    my %buttonText = (
        home => "Home",
        login => "login",
        browse => "Browse",
        search => "Search",
        reports => "Reports",
        utilities => "Utilities",
        help => "Help"
    );
    my %buttonTitle = (
        home => "Home",
        login => "Login",
        browse => "Browse - Click to view system data",
        search => "Search - Click to search text fields for words or phrases",
        reports => "Reports - Click to view Compliance Matrices",
        utilities => "Utilities",
        help => "Help - Click to view the Guidance Manual for Users"
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
    $head .= "    document.$form.action = '$path' + script + '.pl';\n";
    $head .= "    document.$form.command.value = command;\n";
    $head .= "    document.$form.target = 'main';\n";
    $head .= "    document.$form.submit();\n";
    $head .= "}\n";
   $head .= "function displayHelp (script,command) {\n";
    $head .= "    var myDate = new Date();\n";
   $head .= "    var winName = myDate.getTime();\n";
    $head .= "    document.$form.command.value = command;\n";
   $head .= "    document.$form.action = '$path' + script + '.pl';\n";
    $head .= "    document.$form.target = winName;\n";
   $head .= "    var newwin = window.open('',winName);\n";
    $head .= "    newwin.creator = self;\n";
   $head .= "    document.$form.submit();\n";
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
#
    $body .= "<table border=0><tr><td rowspan=$logoRowSpan><img src=$SYSImagePath/logo.gif border=0></td>\n";
    $body .= "<td align=center><img src=$SYSImagePath/title.gif border=0></td></tr>\n";
    if ($loggedIn) {
        $body .= "<tr><td align=center><table cellspacing=0 cellpadding=0 border=0><tr>\n";
        foreach my $button (@buttons) {
            if ($button eq "help") {
                $body .= "<td><a href=javascript:displayHelp('$button','$buttonCommand{$button}') ";
            }
            else {
                $body .= "<td><a href=javascript:submitForm('$button','$buttonCommand{$button}') ";
  	    }
            $body .= "onMouseOver=show('$button','on') onMouseOut=show('$button','off') onMouseDown=show('$button','press') onMouseUp=show('$button','on') title='$buttonTitle{$button}'>";
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
&db_disconnect($dbh);
exit();

