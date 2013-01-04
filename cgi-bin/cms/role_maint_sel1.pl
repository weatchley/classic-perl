#!/usr/local/bin/newperl
# - !/usr/bin/perl

#
# CIRS Role Maintenance Script Selection 1 - Role and Site Selection
#
# $Source: /data/dev/rcs/cms/perl/RCS/role_maint_sel1.pl,v $
# $Revision: 1.11 $
# $Date: 2001/11/15 23:34:29 $
# $Author: naydenoa $
# $Locker:  $
# $Log: role_maint_sel1.pl,v $
# Revision 1.11  2001/11/15 23:34:29  naydenoa
# Changed BSC Discipline lead processing, added Licensing lead assignment.
#
# Revision 1.10  2001/06/01 23:10:20  naydenoa
# Took out Sys Admin from available roles - manual assignment only
#
# Revision 1.9  2001/03/15 17:27:04  naydenoa
# All categories assigned automatically when a new CC is added
#
# Revision 1.8  2000/12/21 21:28:59  naydenoa
# Minimal interface rewrite
#
# Revision 1.7  2000/08/22 15:42:13  atchleyb
# added check schema line
#
# Revision 1.6  2000/07/17 21:07:29  atchleyb
# placed forms in table with a width of 750
#
# Revision 1.5  2000/07/14 20:26:39  atchleyb
# removed text image label code
#
# Revision 1.4  2000/07/06 23:45:53  munroeb
# finished making mods to html and javascripts.
#
# Revision 1.3  2000/07/05 23:10:42  munroeb
# made minor changes to html and javascripts.
#
# Revision 1.2  2000/05/18 23:16:09  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/12 00:00:55  zepedaj
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
    my $selectedrole = $cirscgi->param('roleselection');
    my $selectedsite = $cirscgi->param('siteselection');
    
    my %rolehash = get_role_info($dbh, $selectedrole);
    my $dependson = $rolehash{'dependson'};
    
    print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<table border=0 align=center width=750><tr><td>\n";
    
    if ($dependson) {
	# There is a dependent table, so frame rolesel2 will be used.
	print "<form name=sel1proc action=$ONCSCGIDir/role_maint_sel2.pl target=rolesel2>\n";
	print "<input type=hidden name=dependson value=$dependson>\n";
	print "<input type=hidden name=schema value=$SCHEMA>\n";
	#rolesel3 should be made blank
	print <<blankrolesel3;
	<script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.rolesel3.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
blankrolesel3
    }
    else {
	# There is not a dependent table, so frame rolesel2 will be blank.
	# We will go directly to frame rolesel3.
	print "<form name=sel1proc action=$ONCSCGIDir/role_maint_sel3.pl target=rolesel3>\n";
	print <<blankrolesel2;
        <script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.rolesel2.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
blankrolesel2
    }

    print <<sel1procform1;
    <input type=hidden name=cgiaction value=query>
    <input type=hidden name=loginusersid value=$usersid>
    <input type=hidden name=loginusername value=$username>
    <input type=hidden name=roleid value=$selectedrole>
    <input type=hidden name=siteid value=$selectedsite>
    <input type=hidden name=schema value=$SCHEMA>
    </form>
    <script language="JavaScript" type="text/javascript">
    <!--
    document.sel1proc.submit();

    parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
    //-->
    </script>
sel1procform1
    &oncs_disconnect($dbh);
    exit 1;
}

my %rolehash = get_lookup_values($dbh, "role", "description", "roleid", "roleid <> 6 and isactive = 'T'");
my %sitehash = get_lookup_values($dbh, "site", "name || ' - ' || city || ', ' || state", "siteid");

#This is the role/Site picklist section. It contains two selects and targets the role_maint_sel2.pl to interpret its results.
print <<rolebody1;
<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
<table border=0 align=center width=750><tr><td><br>
<form name=role_maint_sel1 action=$ONCSCGIDir/role_maint_sel1.pl method=post target=control>
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
<input type=hidden name=cgiaction value="process">
<input type=hidden name=schema value=$SCHEMA>
<table summary="Role/Site Selection" width=250 align=center border=0>
<tr><td width=20% align=center><b>Role:</b></td>
<td width=70% align=left>
<select name=roleselection onchange="checkandsubmit();">
<option value=0>Select the Role to edit
rolebody1
foreach my $key (sort keys %rolehash) {
    print "  <option value=$rolehash{$key}>$key\n";
}
print <<rolebody2;
</select></td></tr>
<tr><td align=center><b>Site:</b></td>
<td align=left>
<select name=siteselection onchange="checkandsubmit();">
<option value=0>Select the Site for this role
rolebody2
foreach my $key (sort keys %sitehash) {
    print "  <option value=$sitehash{$key}>$key\n";
}
print <<rolebody3;
</select></td></tr>
</table>
</form>
</td></tr></table>
</body>
<script language="JavaScript" type="text/javascript">
    <!--
    function checkandsubmit() {
	var isfilledout;
	var roleselec = document.role_maint_sel1.roleselection;
	var siteselec = document.role_maint_sel1.siteselection
	    
	    isfilledout = ((roleselec.options[roleselec.selectedIndex].value != 0) && (siteselec.options[siteselec.selectedIndex].value != 0));
	if (isfilledout) {
	    document.role_maint_sel1.submit();
	}
    }
    //-->
</script>
rolebody3
print "</html>\n";
&oncs_disconnect($dbh);
