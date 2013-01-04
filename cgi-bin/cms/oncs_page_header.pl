#!/usr/local/bin/newperl -w

# Page header for Commitment Management System
#
# $Source: /data/dev/rcs/cms/perl/RCS/oncs_page_header.pl,v $
# $Revision: 1.9 $
# $Date: 2002/10/25 16:52:39 $
# $Author: naydenoa $
# $Locker:  $
# $Log: oncs_page_header.pl,v $
# Revision 1.9  2002/10/25 16:52:39  naydenoa
# Removed pop-up for data notification as directed by Sheryl Morris
#
# Revision 1.8  2002/03/08 21:20:49  naydenoa
# Added pop-up for data notification on initial load.
#
# Revision 1.7  2001/05/11 21:41:46  naydenoa
# Removed outdated reference to privileges
#
# Revision 1.6  2000/10/04 19:30:38  atchleyb
# fixed javascript bug in logout
#
# Revision 1.5  2000/10/04 15:59:32  atchleyb
# changed title to an image
# added function to logout when double click on title
#
# Revision 1.4  2000/09/25 21:15:41  atchleyb
# changed buttons
# checkpoint
#
# Revision 1.3  2000/08/31 23:22:55  atchleyb
# check point
#
# Revision 1.2  2000/05/18 23:14:53  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/11 23:56:48  zepedaj
# Initial revision
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
my $dbh = oncs_connect();

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

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

# output page header
print <<pageheader;
<html>
<head>
<title>CMS Header</title>
<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) { // not in frames
    location = '$ONCSCGIDir/login.pl';
}
function submitForm(script, command) {
    document.$form.command.value = command;
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'workspace';
    document.$form.submit();
}
function submitFormTop(script, command) {
    document.$form.command.value = command;
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = '_top';
    document.$form.submit();
}
function submitFormCGIResults(script, command) {
    document.$form.command.value = command;
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'control';
    document.$form.submit();
}
function SetImageLabel(name) {
    parent.header.imagelabel.src= '$ONCSImagesDir/' + name + '.gif';
}
function SetImage(button,name) {
    document[button].src='$ONCSImagesDir/buttons/' + name + '.gif';
}
function doResetUser() {
    if (document.$form.oldusersid.value != 0) {
        document.$form.newuserid.value=document.$form.oldusersid.value;
        submitFormCGIResults('utilities', 'changeuser2');
    }
}
function doLogOut() {
    if (document.$form.loginusersid.value != 0) {
        parent.location='$path' + 'login.pl';
    }
}
//-->
</script>
</head>
pageheader

print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>\n";
print "<center><table border=0 cellspacing=0 cellpadding=1><tr>\n";
print "<td align=center valign=top><img src=$ONCSImagesDir/cms_logo.gif name=logo border=0 onDblclick=\"doResetUser();\">&nbsp;&nbsp;</td>\n";
print "<td align=center valign=top>\n";
print "<img name=banner src=$CMSImagesDir/CMS-title.gif width=400 height=70 border=0 onDblclick=\"doLogOut();\">\n";
print "<table border=0 cellspacing=0 cellpadding=0 width=100%><tr><td align=center>\n";

print <<menustart;
<form name=$form method=post>
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
<input type=hidden name=schema value=$SCHEMA>
<input type=hidden name=command value=''>
<input type=hidden name=cgiaction value=''>
<input type=hidden name=oldusersid value=0>
<input type=hidden name=newuserid value=0>
<table summary="Main Menu Table" align=center cellspacing=0 cellpadding=3 border=0><tr align=center>
menustart

if ($username eq "GUEST") {
    print <<menuend;
    <td><a href="javascript:submitForm('login','newlogin');" 
    onMouseOver=SetImage('btn_login','login_ovr') onMouseOut=SetImage('btn_login','login') 
    onMouseUp=SetImage('btn_login','login_ovr') onMouseDown=SetImage('btn_login','login_dwn')>
    <img name=btn_login src=$ONCSImagesDir/buttons/login.gif border=0 width=90 height=27></a></td>
menuend
}
if ($username ne "GUEST") {
    print <<endofblock;
    <td><a href="javascript:submitForm('home','');" 
    onMouseOver=SetImage('btn_home','home_ovr') onMouseOut=SetImage('btn_home','home') 
    onMouseUp=SetImage('btn_home','home_ovr') onMouseDown=SetImage('btn_home','home_dwn')>
    <img name=btn_home src=$ONCSImagesDir/buttons/home.gif border=0 width=90 height=27></a></td>
endofblock
}
print <<endofblock;
    <td><a href="javascript:submitForm('browse','');" 
    onMouseOver=SetImage('btn_browse','browse_ovr') onMouseOut=SetImage('btn_browse','browse') 
    onMouseUp=SetImage('btn_browse','browse_ovr') onMouseDown=SetImage('btn_browse','browse_dwn')>
    <img name=btn_browse src=$ONCSImagesDir/buttons/browse.gif border=0 width=90 height=27></a></td>
endofblock

print <<endofblock;
    <td><a href="javascript:submitForm('search','');" 
    onMouseOver=SetImage('btn_search','search_ovr') onMouseOut=SetImage('btn_search','search') 
    onMouseUp=SetImage('btn_search','search_ovr') onMouseDown=SetImage('btn_search','search_dwn')>
    <img name=btn_search src=$ONCSImagesDir/buttons/search.gif border=0 width=90 height=27></a></td>
endofblock

print <<endofblock;
    <td><a href="javascript:submitForm('reports_module_main','');" 
    onMouseOver=SetImage('btn_reports','reports_ovr') onMouseOut=SetImage('btn_reports','reports') 
    onMouseUp=SetImage('btn_reports','reports_ovr') onMouseDown=SetImage('btn_reports','reports_dwn')>
    <img name=btn_reports src=$ONCSImagesDir/buttons/reports.gif border=0 width=90 height=27></a></td>
endofblock

if ($username ne "GUEST") {
    print <<endofblock;
    <td><a href="javascript:submitForm('utilities','');" 
    onMouseOver=SetImage('btn_utilities','utilities_ovr') onMouseOut=SetImage('btn_utilities','utilities') 
    onMouseUp=SetImage('btn_utilities','utilities_ovr') onMouseDown=SetImage('btn_utilities','utilities_dwn')>
    <img name=btn_utilities src=$ONCSImagesDir/buttons/utilities.gif border=0 width=90 height=27></a></td>
endofblock
}
if ($usersid >= 1000) {

}
print <<menuend;
</tr></table></form>
</tr></table>
</tr></table>
</center>
</body>
</html>
menuend

&oncs_disconnect($dbh);
