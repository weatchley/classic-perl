#!/usr/local/bin/newperl -w

# title bar for BMS
#
# $Source$
# $Revision$
# $Date$
# $Author$
# $Locker$
# $Log$
#

#
#

# get all required libraries and modules
use BMS_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $bmscgi = new CGI;

# tell the browser that this is an html page using the header method
print $bmscgi->header('text/html');

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $schema = (defined($bmscgi->param("schema"))) ? $bmscgi->param("schema") : $SCHEMA;

# connect to the oracle database and generate a database handle
# $dbh = bms_connect();

my $title = ((defined($bmscgi->param('title'))) ? $bmscgi->param('title') : "++");

my $username = ((defined($bmscgi->param('username'))) ? $bmscgi->param('username') : "None");
my $userid = ((defined($bmscgi->param('userid'))) ? $bmscgi->param('userid') : "None");
#if ((!defined($userid)) || ($userid eq "") || (!defined($username)) || ($username eq ""))
#  {
#  print <<openloginpage;
#  <script type="text/javascript">
#  <!--
#  parent.location='$BMSCGIDir/login.pl';
#  //-->
#  </script>
#openloginpage
#  exit 1;
#  }

my $DBSCHEMA = (($username eq 'None') ? 'None' : uc($schema));

my $SchemaColor = (($DBSCHEMA ne 'None') ? (($BMSProductionStatus == 1) ? $BMSFontColor : "#990000") : "#ff0000");
my $UserColor = (($username ne 'None') ? $BMSFontColor : "#ff0000");

# output page header
my $titlepath = $path . "text_labels.pl?width=390&size=15&parsetitle=T";
print <<pageheader;
<html>
<head>
<title>BMS Title</title>
<script language="JavaScript" type="text/javascript">
<!--
//if (parent == self) // not in frames
//  {
//  location = '$path/login.pl';
//  }

function SetImageLabel(name) {
    var name2 = name;
    var name3 = name2.replace(/_/g,"+");
    name2 = name3.replace(/ /g,"+");
    //alert(name2);
    var temp = name.replace(/\\//g,"_");
    var temp2 = temp.replace(/ /g,"_");
    var file = temp2.toLowerCase();
    //document.imagelabel.src= '$BMSImagePath/' + file + '.gif';
    document.titleimage.src= '$titlepath&text=' + name2;
}
//-->
</script>
</head>

<body background=$BMSImagePath/background.gif text=$BMSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>
<table border=0 cellspacing=0 cellpadding=0 width=750><tr>
<td align=center colspan=3><img src=$BMSImagePath/separator.gif width=750 height=14 border=0></td></tr>
<tr><td width=24% align=left><table cellpadding=3 cellspacing=0 border=1><tr><td><b><font size=2 color=#003000>User/ID:&nbsp;&nbsp;</font>
<font size=2 color=$UserColor>$username</font>
<font size=2 color=#003000> / </font>
<font size=2 color=$UserColor>$userid</font>
</b></td></tr></table></td>
<td align=center><img src='$titlepath&text=$title' name=titleimage width=390 height=25></td>
<!-- <td align=center><img src=/eis/images/titles/home.gif name=titleimage width=390 height=20></td> -->
<td width=24% align=right><table cellpadding=3 cellspacing=0 border=1><tr><td><b>
<font size=2 color=#003000>Database:&nbsp&nbsp;</font>
<font size=2 color=$SchemaColor>$DBSCHEMA</font>
</b></td></tr></table></td></tr>
<tr><td align=center colspan=3><img src=$BMSImagePath/separator.gif width=750 height=14 border=0></td>
</tr></table></center>
</body>
</html>
pageheader
