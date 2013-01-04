#!/usr/local/bin/newperl -w

# title bar for Commitment Management System
#
# $Source: /data/dev/rcs/cms/perl/RCS/title_bar.pl,v $
# $Revision: 1.4 $
# $Date: 2006/06/27 16:49:37 $
# $Author: naydenoa $
# $Locker:  $
# $Log: title_bar.pl,v $
# Revision 1.4  2006/06/27 16:49:37  naydenoa
# CREQ00030 - fix security issue - force https (see top of script).
#
# Revision 1.3  2000/09/27 20:00:56  atchleyb
# forced display of schema to uppercase
#
# Revision 1.2  2000/09/25 21:14:09  atchleyb
# changed default font and size
#
# Revision 1.1  2000/08/31 23:24:06  atchleyb
# Initial revision
#
#
#

# get all required libraries and modules
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $oncscgi = new CGI;

# tell the browser that this is an html page using the header method
print $oncscgi->header('text/html');

$SCHEMA = (defined($oncscgi->param("schema"))) ? $oncscgi->param("schema") : $SCHEMA;

# connect to the oracle database and generate a database handle
# $dbh = oncs_connect();

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

if (!(defined($ENV{HTTPS}) && $ENV{HTTPS} eq 'on')) {
    print "Location: https://$ENV{SERVER_NAME}$1/" . "login.pl\n\n";
}

my $username = $oncscgi->param('loginusername');
my $usersid = $oncscgi->param('loginusersid');
if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq ""))
  {
  print <<openloginpage;
  <script type="text/javascript">
  <!--
  parent.location='$ONCSCGIDir/login.pl';
  //-->
  </script>
openloginpage
  exit 1;
  }

my $dispuser = (($username ne "ZEPEDAJE00") ? $username : "TESTUSER");
my $DBSCHEMA = uc((($SCHEMA ne "zepedaj") ? $SCHEMA : "CMS-Dev"));

# output page header
print <<pageheader;
<html>
<head>
<title>CMS Title</title>
<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) // not in frames
  {
  location = '$ONCSCGIDir/login.pl';
  }

function SetImageLabel(name) {
    var name2 = name;
    var name3 = name2.replace(/_/g,"+");
    name2 = name3.replace(/ /g,"+");
    //alert(name2);
    var temp = name.replace(/\\//g,"_");
    var temp2 = temp.replace(/ /g,"_");
    var file = temp2.toLowerCase();
    //document.imagelabel.src= '$ONCSImagesDir/' + file + '.gif';
    document.imagelabel.src= '$ONCSCGIDir/text_labels.pl?width=450&text=' + name2;
    //document.imagelabel.src= '$ONCSCGIDir/text_labels.pl?width=450&text=Commitment+Fulfillment+Resubmitted+for+Rework';
}
//-->
</script>
</head>
<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<table border=0 cellspacing=0 cellpadding=0 width=750 align=center>
<tr><td align=center colspan=3><hr></td></tr>
<tr>
<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=1><tr><td align=center><font size=2>User:&nbsp;$dispuser</font></td></tr></table></td>
<td align=center valign=center width=60%><img name=imagelabel src=$ONCSImagesDir/labels.gif border=0 width=450 height=25></td>
<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=1><tr><td align=center><font size=2>DB:&nbsp;$DBSCHEMA</font></td></tr></table></td>
</tr>
<tr><td align=center colspan=3><hr></td></tr>
</table>
</body>
</html>
pageheader
