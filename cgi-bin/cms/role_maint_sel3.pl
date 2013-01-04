#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# CMS Role Maintenance Script #3, User Selection
#
# $Source: /data/dev/cirs/perl/RCS/role_maint_sel3.pl,v $
# $Revision: 1.10 $
# $Date: 2001/03/15 17:39:26 $
# $Author: naydenoa $
# $Locker:  $
# $Log: role_maint_sel3.pl,v $
# Revision 1.10  2001/03/15 17:39:26  naydenoa
# All categories assigned automatically when a new CC is added
#
# Revision 1.9  2000/12/21 21:29:35  naydenoa
# Complete rewrite to insert multiple users per role and
# preserve/delete existing assignments
#
# Revision 1.8  2000/09/27 23:47:05  atchleyb
# fixed insert to use names
#
# Revision 1.7  2000/08/22 15:45:46  atchleyb
# added check schema line
#
# Revision 1.6  2000/07/17 21:12:04  atchleyb
# placed forms in table with a width of 750
#
# Revision 1.5  2000/07/14 20:27:47  atchleyb
# removed text image label code
#
# Revision 1.4  2000/07/06 23:46:49  munroeb
# finished making mods to html and javascripts.
#
# Revision 1.3  2000/07/05 23:11:58  munroeb
# made minor changes to html and javascripts.
#
# Revision 1.2  2000/05/18 23:16:22  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/12 00:01:25  zepedaj
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

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

# print content type header
print $cmscgi->header('text/html');

my $username = $cmscgi->param('loginusername');
my $usersid = $cmscgi->param('loginusersid');
my $cgiaction = $cmscgi->param('cgiaction');
my $dependson = $cmscgi->param('dependson');
my $dependid = $cmscgi->param('dependselection');
my $siteid = $cmscgi->param('siteid');
my $roleid = $cmscgi->param('roleid');

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

print "</head>\n";

my $dbh = oncs_connect();

if ($cgiaction eq "process") {
    my $roletablename;
    if ($dependson) { 
	$roletablename = 'default' . $dependson . 'role';
    }
    elsif ($roleid == 1) {
	$roletablename = 'defaultcategoryrole';
    }
    else {
	$roletablename = 'defaultsiterole';
    }
    $dependid = $cmscgi->param('dependid');
    # e.g. if modifying discipline, that would be the discipline id... 
    
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
    my $activity;
    eval {
	#add role assignments
	if ($roletablename eq 'defaultcategoryrole') {
	    my $oldcats = $dbh -> prepare ("delete from $SCHEMA.$roletablename where siteid = $siteid");
	    $oldcats -> execute;
	    $oldcats -> finish;
	    my ($cats) = $dbh -> selectrow_array ("select max(categoryid) from category");
	    my $userid;
	    foreach $userid ($cmscgi->param('selectedusers')) {
		if ($userid ne '') {
		    my $csr;
		    $activity = "Insert user $userid as Commitment Coordinator.";
		    for (my $i=1; $i<=$cats; $i++) {
			$csr = $dbh -> prepare ("insert into $SCHEMA.$roletablename (categoryid, usersid, roleid, siteid) values ($i, $userid, 1, $siteid)");
			$csr -> execute;
		    }
		}
	    }
	}
	else {
	    my $oldroles = "delete from $SCHEMA.$roletablename where roleid=$roleid and siteid = $siteid" . (($dependson) ? " AND " . $dependson . "id = $dependid" : '');
	    my $oldcsr = $dbh -> prepare ($oldroles);
	    $oldcsr -> execute;
	    my $userid;
	    foreach $userid ($cmscgi->param('selectedusers')) {
		if ($userid ne '') {
		    my $csr;
		    $activity = "Insert user $userid for role $roleid.";
		    my $rolesqlstring = "INSERT INTO $SCHEMA.$roletablename 
                                     (" . (($dependson) ? 
	                             lc(substr ($roletablename, 7, 
				     (index(lc($roletablename),'role')-7)))
				     . "id, " : "") . "usersid, roleid, siteid)
                                     VALUES(" .
				     (($dependson) ? "$dependid, " : "") .
                                     "$userid, $roleid, $siteid)";
		    $csr = $dbh->prepare($rolesqlstring);
		    $csr->execute;
		}
	    }
	}
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, $roletablename, "$roleid, $siteid, $dependid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
        print <<pageerror;
        <script language="JavaScript" type="text/javascript">
        <!--
        alert("$alertstring");
        //parent.parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageerror
    }
    else {
	my ($sitename) = $dbh -> selectrow_array ("select name from $SCHEMA.site where siteid = $siteid");
	$dependson = ($dependson) ? $dependson : "Commitment Coordinator/Maker/Manager";
	&log_activity($dbh, 'F', $usersid, "Role assignments for $dependson, site $sitename");
	print <<pageresults;
	<script language="JavaScript" type="text/javascript">
	<!--
	parent.parent.workspace.location="$ONCSCGIDir/role_maint.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
    }
    $dbh->commit;
    $dbh->{AutoCommit} = 1;
    $dbh->{RaiseError} = 0;
    &oncs_disconnect($dbh);
    print "</html>\n";
    exit 1;
}

my %usershash = get_lookup_values($dbh, "users", "lastname || ', ' || firstname || ';' || usersid", "usersid", "isactive = 'T' and siteid=$siteid");
my $roletype;
if ($dependson) {
    $roletype = $dependson;
}
elsif ($roleid == 1) {
    $roletype = "category";
}
else {
    $roletype = "site";
}
my $roletypeid = ($dependson && $dependson ne "CATEGORY") ? " and " . $roletype . "id = $dependid" : "";
my $table = "default" . $roletype . "role"; 
my %rolehash = get_lookup_values($dbh, $table, "usersid", "'True'", "roleid=$roleid and siteid=$siteid $roletypeid");
my $key;
#This is the role/Site picklist section. It contains two selects and targets the role_maint_sel2.pl to interpret its results.
print <<userrolebody1;
<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
<table border=0 align=center width=750><tr><td>
<form name=role_maint_sel3 action=$ONCSCGIDir/role_maint_sel3.pl target=control method=post onsubmit="return(verify_input());">
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
<input type=hidden name=siteid value=$siteid>
<input type=hidden name=roleid value=$roleid>
<input type=hidden name=dependson value=$dependson>
<input type=hidden name=dependid value=$dependid>
<input type=hidden name=cgiaction value="process">
<input type=hidden name=schema value=$SCHEMA>
<table summary="Role Assignee Selection" width=100% border=0>
userrolebody1

print "<tr><td align=center><b>Assign users to role:</b>\n";
print "<table border=0 summary=\"User Selection\" align=center>\n";
print "<tr align=Center><td><b>All Users</b></td>\n";
print "<td>&nbsp;</td>\n";
print "<td><b>Selected Users</b></td></tr><tr><td>\n";
print "<select name=alluserslist size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.role_maint_sel3.alluserslist, document.role_maint_sel3.selectedusers, 'move')\">\n";
my $word;
foreach $key (sort keys %usershash) {
    if ($rolehash{$usershash{$key}} ne 'True') {
	$word=$key;
        $word =~ s/;$usershash{$key}//g;
	print "<option value=\"$usershash{$key}\">$word\n";
    }
}
print "<option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp</select></td><td>\n";
print "<input name=rolerightarrow title=\"Click to select the user(s) for this role\" value=\"-->\" type=button onclick=\"process_multiple_dual_select_option(document.role_maint_sel3.alluserslist, document.role_maint_sel3.selectedusers, 'move')\"><br>\n";
print "<input name=roleleftarrow title=\"Click to remove the selected user(s)\" value=\"<--\" type=button onclick=\"process_multiple_dual_select_option(document.role_maint_sel3.selectedusers, document.role_maint_sel3.alluserslist, 'move')\"></td><td>\n";
print "<select name=selectedusers size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.role_maint_sel3.selectedusers, document.role_maint_sel3.alluserslist, 'move')\">\n";
foreach $key (sort keys %usershash) {
    if ($rolehash{$usershash{$key}} eq 'True') {
	my $word=$key;
	$word =~ s/;$usershash{$key}//g;
	print "<option value=\"$usershash{$key}\">$word\n";
    }
}
print "<option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp</select></td></tr></table></td></tr>\n";

print <<userrolebody2;
<tr><td align=center><br><input type=submit name=role_save value="Save Changes" onClick="selectemall(document.role_maint_sel3.selectedusers);"></td></tr>
</table>
</form>
</td></tr></table>
</body>

<script language="JavaScript" type="text/javascript">
    <!--
    function verify_input() {
	var isfilledout;
	var userselec = document.role_maint_sel3.selectedusers;
	
	isfilledout = (userselec.options[userselec.selectedIndex].value != 0);
	if (! isfilledout) {
	    alert ("You must select a valid user for this role.");
	}
	return(isfilledout);
    }
    //-->
</script>
userrolebody2

print "</html>\n";
&oncs_disconnect($dbh);
