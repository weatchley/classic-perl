#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# Role Maintenance Selection script for the second frame
# Used when role depends on something beyond site and role
# such as category id.
#
# $Source: /data/dev/cirs/perl/RCS/role_maint_sel2.pl,v $
# $Revision: 1.9 $
# $Date: 2001/03/15 17:38:27 $
# $Author: naydenoa $
# $Locker:  $
# $Log: role_maint_sel2.pl,v $
# Revision 1.9  2001/03/15 17:38:27  naydenoa
# Bypass this frame on category
#
# Revision 1.8  2000/12/21 21:29:20  naydenoa
# Minimal interface rewrite
#
# Revision 1.7  2000/08/22 15:43:32  atchleyb
# added check schema line
#
# Revision 1.6  2000/07/17 21:10:08  atchleyb
# placed forms in table with a width of 750
#
# Revision 1.5  2000/07/14 20:27:05  atchleyb
# removed text image label code
#
# Revision 1.4  2000/07/06 23:46:17  munroeb
# finished making mods to html and javascripts.
#
# Revision 1.3  2000/07/05 23:11:05  munroeb
# made minor changes to html and javascripts
#
# Revision 1.2  2000/05/18 23:16:15  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/11 22:13:32  zepedaj
# Initial revision
#
#

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $cirscgi = new CGI;

$SCHEMA = (defined($cirscgi->param("schema"))) ? $cirscgi->param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

# print content type header
print $cirscgi->header('text/html');

my $username = $cirscgi->param('loginusername');
my $usersid = $cirscgi->param('loginusersid');
my $cgiaction = $cirscgi->param('cgiaction');
my $dependson = $cirscgi->param('dependson');
$dependson = "\u\L$dependson";
my $roleid = $cirscgi->param('roleid');
my $siteid = $cirscgi->param('siteid');

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "")) {
    print <<openloginpage;
    <script type="text/javascript">
    <!--
    _top.location='$ONCSCGIDir/login.pl';
    //-->
    </script>
openloginpage
    exit 1;
}

#print top of page
print <<topofpage1;
<html>
<head>
<meta name="pragma" content="no-cache">
<meta name="expires" content="0">
<meta http-equiv="expires" content="0">
<meta http-equiv="pragma" content="no-cache">
topofpage1

print <<scriptlabel1;
<!-- include external javascript code -->
<script src="$ONCSJavaScriptPath/oncs-utilities.js"></script>
scriptlabel1

print <<endofhead;
</head>
endofhead

my $dbh = oncs_connect();

if ($cgiaction eq "process") {
    my $dependid = $cirscgi->param('dependselection');
    
    print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<table border=0 align=center width=750><tr><td>\n";
    
    print <<sel1procform1;
    <input type=hidden name=cgiaction value=query>
    <input type=hidden name=loginusersid value=$usersid>
    <input type=hidden name=loginusername value=$username>
    <input type=hidden name=roleid value=$roleid>
    <input type=hidden name=siteid value=$siteid>
    <input type=hidden name=dependson value=$dependson>
    <input type=hidden name=dependid value=$dependid>
    <input type=hidden name=schema value=$SCHEMA>
    </form>
    <script language="JavaScript" type="text/javascript">
    <!--
    document.sel1proc.submit();
    //parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
    //-->
    </script>
sel1procform1
    &oncs_disconnect($dbh);
    exit 1;
}
my %dependsonhash;
%dependsonhash = get_lookup_values($dbh, $dependson, "description", $dependson . "id", "isactive = 'T'");
#This is the role/Site picklist section. It contains two selects and targets the role_maint_sel2.pl to interpret its results.
print <<dependbody1;
<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
<table border=0 align=center width=750><tr><td>
<form name=role_maint_sel2 action=$ONCSCGIDir/role_maint_sel3.pl method=post target=rolesel3>
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
<input type=hidden name=dependson value=$dependson>
<input type=hidden name=roleid value=$roleid>
<input type=hidden name=siteid value=$siteid>
<input type=hidden name=schema value=$SCHEMA>
<table summary="Dependent Table Selection" width=300 border=0 align=center> 
dependbody1
print "<tr width=100%><td width=20% align=center><b>$dependson:</b></td>\n";
print "<td width=70% align=left>\n";
print "<select name=dependselection onchange=\"checkandsubmit();\">\n";
print "<option value=0>Select the $dependson to edit&nbsp;\n";
foreach my $key (sort keys %dependsonhash) {
    print "  <option value=$dependsonhash{$key}>$key\n";
}
print <<dependbody2;
</select></td></tr>
</table>
</form>
</td></tr></table>
</body>
<script language="JavaScript" type="text/javascript">
    <!--
    function checkandsubmit() {
	var isfilledout;
	var dependselec = document.role_maint_sel2.dependselection;
	
	isfilledout = (dependselec.options[dependselec.selectedIndex].value != 0);
	if (isfilledout) {
	    document.role_maint_sel2.submit();
	}
    }
    //-->
    </script>
dependbody2
print "</html>\n";
&oncs_disconnect($dbh);
