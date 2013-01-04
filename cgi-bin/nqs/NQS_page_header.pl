#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/qa/perl/RCS/NQS_page_header.pl,v $
# $Revision: 1.5 $
# $Date: 2004/03/10 21:49:00 $
# $Author: starkeyj $
# $Locker:  $
# $Log: NQS_page_header.pl,v $
# Revision 1.5  2004/03/10 21:49:00  starkeyj
# added popup text for buttons, briefly describing the button's function
#
# Revision 1.4  2002/03/28 22:59:00  starkeyj
# added new button labeled 'search' for added search capability (SCR 8)
#
# Revision 1.3  2001/11/05 16:21:56  starkeyj
# changed path for background image
#
# Revision 1.2  2001/11/02 23:04:43  starkeyj
# no change - user error with RCS
#
#
use integer;
use strict;
use NQS_Header qw(:Constants);
use OQA_Utilities_Lib qw(:Functions);
use OQA_Widgets qw(:Functions);
use CGI;

my $NQScgi = new CGI;
my $username = defined($NQScgi->param("username")) ? $NQScgi->param("username") : "GUEST";
my $userid = defined($NQScgi->param("userid")) ? $NQScgi->param("userid") : "None";
my $schema = defined($NQScgi->param("schema")) ? $NQScgi->param("schema") : "None";
my $Server = defined($NQScgi->param("server")) ? $NQScgi->param("server") : $NQSServer;
my $title = defined($NQScgi->param("title")) ? $NQScgi->param("title") : "None";
my $command = $NQScgi->param("command");
my $cgiaction = $NQScgi->param("cgiaction");
my $prompt;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;


print $NQScgi->header('text/html');
print "<html>\n";
my ($head, $body) = ("<head>\n", "<body background=$NQSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n");

   my $loggedIn = (($username ne "GUEST") && ($userid ne "None") && ($schema ne "None"));
   my $buttonFileType = "gif";
   my $buttonSize = "rounded";
   my $buttonHeight = ($buttonSize eq "large") ? 28 : 25;
   my $buttonWidth = ($buttonSize eq "large") ? 100 : 90;
   my $logoRowSpan = ($loggedIn) ? 2 : 1;
   my @buttons;
   if ($userid) {
      	@buttons = ("home", "browse",  "search", "reports", "utilities");
   }
   else {
      	@buttons = ("login", "home", "search", "browse", "reports");
   }
   $head .= "<script language=javascript><!--\n";
   #$head .= "if (document.images) {\n";
   $head .= "if (1) {\n";
   foreach my $button (@buttons) {
      $head .= "   var $button" . "off = new Image();\n";
      $head .= "   $button" . "off.src = \"$NQSImagesDir/buttons/$button/$buttonSize/" . "off.$buttonFileType\"\n";
      $head .= "   var $button" . "on = new Image();\n";
      $head .= "   $button" . "on.src = \"$NQSImagesDir/buttons/$button/$buttonSize/" . "on.$buttonFileType\"\n";
      $head .= "   var $button" . "press = new Image();\n";
      $head .= "   $button" . "press.src = \"$NQSImagesDir/buttons/$button/$buttonSize/" . "press.$buttonFileType\"\n";
   }
   $head .= "}\n";
   $head .= "function show(button, state) {\n";
   $head .= "   document[button].src = eval(button + state + '.src');\n";
   $head .= "}\n";
   $head .= "function submitForm(script,command) {\n";
   $head .= "var undefined;\n";
   $head .= "   document.$form.command.value = command;\n";
  # $head .= "   document.$form.cgiaction.value = null;\n";
   $head .= "   document.$form.target = 'workspace';\n";
   $head .= "   document.$form.action = '$path' + script + '.pl';\n";
   $head .= "   document.$form.submit();\n";
   $head .= "}\n";
   $head .= "function SetImageLabel(name) {\n";
   $head .= "   parent.header.imagelabel.src= '$NQSImagesDir/' + name + '.gif';\n";
   $head .= "}\n";
   $head .= "function submitHelp() {\n";
   $head .= "   var myDate = new Date();\n";
   $head .= "   var winName = myDate.getTime();\n";
   $head .= "   document.$form.target = winName;\n";
   $head .= "   var newwin = window.open(\"\",winName);\n";
   $head .= "   newwin.creator = self;\n";
   #$head .= "   document.$form.cgiaction.value = '';\n";
   $head .= "   document.$form.action = 'help.pl';\n";
   $head .= "   $form.submit();\n";
   $head .= "}\n";
   $head .= "//-->\n</script>\n</head>\n";
   $body .= "<form name=$form target=workspace method=post>\n";
   $body .= "<input type=hidden name=username value=$username>\n";
   $body .= "<input type=hidden name=userid value=$userid>\n";
   $body .= "<input type=hidden name=schema value=$schema>\n";
   $body .= "<input type=hidden name=server value=$Server>\n";
   $body .= "<input type=hidden name=command>\n";
   #$body .= "<input type=hidden name=cgiaction value=$cgiaction>\n";
   
   $logoRowSpan = 2;
   $body .= "<table border=0><tr><td rowspan=$logoRowSpan><img src=$NQSImagePath/qa.gif width=112 height=58 border=0></td>\n";
   $body .= "<td align=center><img src=$NQSImagePath/NQS_title2.gif width=425 height=43 border=0></td></tr>\n";
   #if ($loggedIn) {
      $body .= "<tr><td align=center><table cellspacing=0 cellpadding=0 border=0><tr>\n";
      foreach my $button (@buttons) {
      	$prompt = ($button eq "login" ? "Log in to the Audit and Surveillance Schedule Management System" : 
      	$button eq "home" ? "View the audit schedule, surveillance schedule, or surveillance requests" : 
      	$button eq "search" ? "Search for records containing specific text in selected audit or surveillance form fields" :
      	$button eq "browse" ? "Generate a report containing the audits or surveillances that meet some selected criteria" : 
      	$button eq "login" ? "Login screen for the ASSM System" : 
      	$button eq "utilities" ? "Administrative utilities" : 
      	$button eq "reports" ? "Generate a standard report for an audit or surveillance" : "");
      	
      	 if ($button eq "login"){
      	 	$body .= "<td><a href=javascript:submitForm('$button','newlogin') ";
      	 }
      	 else {
         	$body .= "<td><a href=javascript:submitForm('$button') ";
         }
         $body .= "title='$prompt' onMouseOver=show('$button','on') onMouseOut=show('$button','off') onMouseDown=show('$button','press') onMouseUp=show('$button','on')>";
         $body .= "<img src=$NQSImagesDir/buttons/$button/$buttonSize/" . "off.$buttonFileType name=$button width=$buttonWidth height=$buttonHeight border=0></a></td>\n";
      }
      $body .= "<td>&nbsp;&nbsp;<input type=button onClick=javascript:submitHelp(); value=? target=new title='Help'></td>\n";
      $body .= "</tr></table></td></tr>";
   #}
   $body .= "</table>\n</center>\n";
   $body .= "</form>\n";
   $body .= "</body>\n";

print "$head$body</html>\n";
exit();
