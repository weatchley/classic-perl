#!/usr/local/bin/newperl -w
# $Source: /data/dev/rcs/nqs/perl/RCS/title_bar2.pl,v $
# $Revision: 1.3 $
# $Date: 2002/02/21 21:26:11 $
# $Author: starkeyj $
# $Locker:  $
# $Log: title_bar2.pl,v $
# Revision 1.3  2002/02/21 21:26:11  starkeyj
# modified imagelabel height from 21 to 25 to accomodate new fonts on intranet upgrade
#
# Revision 1.2  2001/11/02 22:51:56  starkeyj
# hardcoded QA as database name so BSC people wouldn't get upset at db named NQS in title
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
#my $Server = "QA";
my $title = defined($NQScgi->param("title")) ? $NQScgi->param("title") : "None";
my $command = $NQScgi->param("command");

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

print "Content-type: text/html\n\n";
print <<pageheader;
<html>
<head>
<title>DDT Title</title>
<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) // not in frames
  {
  location = '$NQSCGIDir/login.pl';
  }

function SetImageLabel(name) {
    var name2 = name;
    var name3 = name2.replace(/_/g,"+");
    name2 = name3.replace(/ /g,"+");
    //alert(name2);
    var temp = name.replace(/\\//g,"_");
    var temp2 = temp.replace(/ /g,"_");
    var file = temp2.toLowerCase();

    document.imagelabel.src= '$NQSCGIDir/text_labels.pl?width=450&text=' + name2;
    
}
//-->
</script>
</head>
<body background=$NQSImagePath/background.gif text=$NQSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<table border=0 cellspacing=0 cellpadding=0 width=750 align=center>
<tr><td align=center colspan=3><hr></td></tr>
<tr>
<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=0><tr><td align=center><font size=2>User:&nbsp;$username</font></td></tr></table></td>
<td align=center valign=center width=60%><B><img name=imagelabel src=$NQSImagesDir/labels.gif border=0 width=450 height=25></B></td>
<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=0><tr><td align=center><font size=2>DB:&nbsp;QA</font></td></tr></table></td>
</tr>
<tr><td align=center colspan=3><hr></td></tr>
</table>
</center></body>
</html>
pageheader

exit();