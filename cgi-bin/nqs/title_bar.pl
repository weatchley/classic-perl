#!/usr/local/bin/newperl -w
#
# $Source $
#
# $Revision: 1.1 $
#
# $Date: 2001/07/06 23:04:03 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: title_bar.pl,v $
# Revision 1.1  2001/07/06 23:04:03  starkeyj
# Initial revision
#
# 

use integer;
use strict;
use NQS_Header qw(:Constants);
use NQS_Utilities_Lib qw(:Functions);
#use UI_Widgets qw(:Functions);
use CGI;

my $DDTcgi = new CGI;
my $username = defined($DDTcgi->param("username")) ? $DDTcgi->param("username") : "GUEST";
my $userid = defined($DDTcgi->param("userid")) ? $DDTcgi->param("userid") : "None";
my $schema = defined($DDTcgi->param("schema")) ? $DDTcgi->param("schema") : "NQS";
my $Server = defined($DDTcgi->param("server")) ? $DDTcgi->param("server") : $NQSServer;
my $title = defined($DDTcgi->param("title")) ? $DDTcgi->param("title") : "None";
my $command = $DDTcgi->param("command");

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

print "Content-type: text/html\n\n";
print <<pageheader;
<html>

<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) // not in frames
  {
  location = '$NQSCGIDir/trend_frame.pl';
  }

function SetImageLabel(name) {
    var name2 = name;
    var name3 = name2.replace(/_/g,"+");
    name2 = name3.replace(/ /g,"+");
    var temp = name.replace(/\\//g,"_");
    var temp2 = temp.replace(/ /g,"_");
    var file = temp2.toLowerCase();
    document.imagelabel.src= '$NQSImagePath/' + file + '.gif';
}

//-->
</script>

<head>
<title>DDT Title</title>

</head>
<body background=$NQSImagePath/background.gif text=$NQSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<table border=0 cellspacing=0 cellpadding=0 width=750 align=center>
<tr><td align=center colspan=3><hr></td></tr>
<tr>
<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=1><tr><td align=center><font size=2>User:&nbsp;$username</font></td></tr></table></td>
<td align=center valign=center width=60%><B><img name=imagelabel src=$NQSImagePath/labels.gif border=0 width=450 height=25></B></td>
<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=1><tr><td align=center><font size=2>DB:&nbsp;$SCHEMA</font></td></tr></table></td>
</tr>
<tr><td align=center colspan=3><hr></td></tr>
</table>
</center></body>
</html>
pageheader

exit();