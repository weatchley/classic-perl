#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# Maintenance for standard lookups
#
# $Source: /data/dev/rcs/cms/perl/RCS/dcmm_maint.pl,v $
# $Revision: 1.22 $
# $Date: 2002/10/04 21:12:44 $
# $Author: naydenoa $
# $Locker:  $
# $Log: dcmm_maint.pl,v $
# Revision 1.22  2002/10/04 21:12:44  naydenoa
# Added "use strict"
#
# Revision 1.21  2001/11/15 23:26:44  naydenoa
# Updated discipline entry to reflect changed roles.
#
# Revision 1.20  2001/03/14 22:39:53  naydenoa
# Added mandatory lead assignment for discipline. This time it works!
#
# Revision 1.19  2001/01/30 23:08:14  naydenoa
# Took out discipline lead assignment. Handled by role_maint scripts
#
# Revision 1.18  2000/12/19 19:42:45  naydenoa
# Changed wording of lead assignment
#
# Revision 1.17  2000/12/18 19:18:33  naydenoa
# Modified sql queries for DL selection to include all active users
#
# Revision 1.16  2000/11/06 18:03:33  naydenoa
# Interface rewrite
# Added features: new category automatically assigned to CC's,
# mandatory DL fields for disciplines
# Limited aditions to one item at a time
# Deactivated active/inactive select fields, display only
#
# Revision 1.15  2000/10/17 17:08:27  naydenoa
# Checkpoint
#
# Revision 1.14  2000/09/26 16:35:31  atchleyb
# fixed insert, added names
#
# Revision 1.13  2000/09/21 21:57:30  atchleyb
# updated title
#
# Revision 1.12  2000/08/23 22:18:17  atchleyb
# removed test print
#
# Revision 1.11  2000/08/23 22:16:54  atchleyb
# added test to handle the fact that the role table has an extra column
#
# Revision 1.10  2000/08/21 23:22:35  atchleyb
# fixed var name bug
#
# Revision 1.9  2000/08/21 20:14:46  atchleyb
# fixec var name bug
#
# Revision 1.8  2000/08/21 18:11:55  atchleyb
# added check schema line
#
# Revision 1.7  2000/07/24 15:49:16  johnsonc
# Inserted GIF file for display.
#
# Revision 1.6  2000/07/11 16:33:25  munroeb
# finished modifying html formatting.
#
# Revision 1.5  2000/07/06 23:41:35  munroeb
# finished mods to html and javascripts.
#
# Revision 1.4  2000/07/05 23:05:09  munroeb
# made minor changes to html and javascripts
#
# Revision 1.3  2000/05/18 23:13:41  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.2  2000/05/16 17:53:00  zepedaj
# Widened the data entry field to 80 characters (standard for the tables this script supports)
# Added Eval block for error handling when submitting
#
# Revision 1.1  2000/04/11 23:54:07  zepedaj
# Initial revision
#
#

use strict;
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;


my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

# print content type header
print $cmscgi->header('text/html');

my $pagetitle = $cmscgi->param('pagetitle');
my $pagetitleplural = ((substr($pagetitle, length($pagetitle) - 1, 1) =~ /y/i) ? (substr($pagetitle, 0, length($pagetitle) - 1)) . "ies" : ((substr($pagetitle, length($pagetitle) - 1, 1) =~ /s/i) ? $pagetitle . "es" : $pagetitle . "s"));
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = $cmscgi->param('updatetable');
my $activity;
my %picklisthash;
my $key;
my $nextvalue;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "") || (!defined($pagetitle)) || ($pagetitle eq "") || (!defined($updatetable)) || ($updatetable eq "")) {
    print <<openloginpage;
    <script type="text/javascript">
    <!--
    parent.location='$ONCSCGIDir/login.pl';
    //-->
    </script>
openloginpage
    exit 1;
}

#print html
print "<html>\n";
print "<head>\n";
print "<meta http-equiv=\"expires\" content=\"Fri, 12 May 1996 14:35:02 EST\">\n";
print "<title>$pagetitle Maintenance</title>\n";

print <<testlabel1;
<!-- include external javascript code -->
<script src="$ONCSJavaScriptPath/oncs-utilities.js"></script>
<script type="text/javascript">
<!--
if (parent == self) {   // not in frames
    location = '$ONCSCGIDir/login.pl'
}
function validatedata(selectobj, activeobj, inactiveobj, updatetable) {
    var msg = "";
    var tempval = "";
    var temptext = "";
    msg += (document.maintenance.newtype.value=="") ? "You must enter a new item.\\n" : "";
    tempval = document.maintenance.newtype.value;
    if (updatetable == "discipline") {
	selectemall(document.maintenance.does);
	msg += (document.maintenance.does.selectedIndex == -1) ? "You must select the DOE Lead(s) for the new discipline.\\n" : "";
    }
    for (var j = 0; j < ((activeobj.length) - 1); j++) {
        temptext = activeobj.options[j].text;
        if (tempval.toUpperCase() == temptext.toUpperCase()) {
            msg = msg + tempval + " is a duplicate entry.\\n";
	}
    }
    for (var j = 0; j < ((inactiveobj.options[j].length) - 1); j++) {
        temptext = inactiveobj.options[j].text;
        if (tempval.toUpperCase() == temptext.toUpperCase()) {
      	    msg = msg + tempval + " is a duplicate entry.\\n";
	}	    
    }
    if (msg != "") {
        alert(msg);
        return false;
    }
    return true;
}
//-->
</script>

<script language="JavaScript" type="text/javascript">
<!--
    doSetTextImageLabel('$pagetitle Maintenance');
//-->
</script>
testlabel1

print "</head>\n\n";
print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";   #onload=\"document.maintenance.newtype.focus()\">\n";

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

##########################################
if ($cmscgi->param('action') ne "query") {
##########################################
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
    eval {

	my $newitem = $cmscgi -> param ('newtype');
	$newitem =~ s/\'/\'\'/g; 
	$nextvalue = get_next_id($dbh, $updatetable);
	my $insertnew = $dbh -> prepare ("insert into $SCHEMA.$updatetable (" . $updatetable  . "id, description, isactive) values ($nextvalue,'$newitem','T')");
	$insertnew -> execute;
	$insertnew -> finish;
	
	####### if category added, assign CC's to it automatically #######
	if ($updatetable eq "category") {
	    my $coordinators = "select distinct usersid, siteid from $SCHEMA.defaultcategoryrole";
	    my $csr = $dbh -> prepare ($coordinators);
	    $csr -> execute;
	    while (my ($coord, $site) = $csr -> fetchrow_array) {
		my $catrole = $dbh -> prepare ("insert into $SCHEMA.defaultcategoryrole (categoryid, roleid, siteid, usersid) values ($nextvalue, 1, $site, $coord)");
		$catrole -> execute;
		$catrole -> finish;
	    }
	    $csr -> finish;
	}
	
	####### if discipline added, add assigned leads, as well ######
	if ($updatetable eq "discipline") {
	    my $csr;
            #### add does ####
	    my $doe;
	    foreach $doe ($cmscgi->param('does')) {
		if ($doe ne '') {
		    $activity="Insert DOE lead $doe for discipline $nextvalue";
		    my ($doesite) = $dbh -> selectrow_array ("select siteid from $SCHEMA.users where usersid=$doe");
		    my $doeinsert = "insert into $SCHEMA.defaultdisciplinerole (disciplineid, roleid, usersid, siteid) values ($nextvalue, 3, $doe, $doesite)";
		    $csr = $dbh -> prepare ($doeinsert);
		    $csr->execute;
		}
	    }
	}
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, $updatetable, "n/a", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print <<seqpageerror;
	<script language="JavaScript" type="text/javascript">
        <!--
        alert("$alertstring");
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
seqpageerror
    }
    else {
	&log_activity($dbh, 'F', $usersid, "New " . $updatetable . " added by user " . $username);
    }
    $dbh->commit;
    $dbh->{AutoCommit} = 1;
    $dbh->{RaiseError} = 0;
}
##########  end if not query  ###############

print "<form action=\"$ONCSCGIDir/dcmm_maint.pl\" method=post name=maintenance onsubmit=return validatedata(document.maintenance.newtype, document.maintenance.activedata, document.maintenance.inactivedata, \'$updatetable\')\">\n";
print "<input type=hidden name=schema value=$SCHEMA>";
print "<TABLE BORDER=0 WIDTH=650 align=center><TR><TD ALIGN=CENTER>\n";

print "<br><b><li>Enter new $pagetitle:</b><br>\n";
print "<input name=action type=hidden value=update>\n";
print "<input name=newtype type=text maxlength=80 size=40 value=\"\"><br>\n";
###################

if ($updatetable eq "discipline") {
    print "<font color=red><b><li>You must select a DOE lead for the new discipline:</b></font><br><br>";
    my %usershash = get_lookup_values($dbh, 'users', "lastname || ', ' || firstname", 'usersid', "isactive='T'");

    print<<doe;
<table border=0 summary="DOEDL Selection" align=center>
<tr align=Center><td><b>All Users</b></td>
<td>&nbsp;</td>
<td><b>Selected DOE Lead(s)</b></td></tr>
<tr><td>
<select name=alluserstoo size=5 multiple ondblclick="process_multiple_dual_select_option(document.maintenance.alluserstoo, document.maintenance.does, 'move')">
doe
foreach $key (sort keys %usershash) {
    print "<option value=\"$usershash{$key}\">$key\n";
}
print <<doe2;
<option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
</select></td>
<td>
<input name=doerightarrow title="Click to select DOE Lead(s)" value="-->" type=button onclick="process_multiple_dual_select_option(document.maintenance.alluserstoo, document.maintenance.does, 'move')">
<br>
<input name=doeleftarrow title="Click to remove the selected DOE Lead(s)" value="<--" type=button onclick="process_multiple_dual_select_option(document.maintenance.does, document.maintenance.alluserstoo, 'move')"></td>
<td>
<select name=does size=5 multiple ondblclick="process_multiple_dual_select_option(document.maintenance.does, document.maintenance.alluserstoo, 'move')">
<option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
</select></td></tr>
</table>
</td></tr>
doe2
}

###################
print<<testlabeltoo;
<tr><td><br><br><center><input type=submit title="Click here to submit your changes" value=Submit onClick="return(validatedata(document.maintenance.newtype, document.maintenance.activedata, document.maintenance.inactivedata, \'$updatetable\'))"></td></tr>
<tr><td><br><br><hr width=70%><br>
testlabeltoo

print "<table align=center border=0 summary=\"Current Data\">\n";
print "<tr align=Center><td><b>Active $pagetitleplural</b>\n";
print "</td><td>&nbsp&nbsp</td><td><b>Inactive $pagetitleplural</b>\n";
print "</td></tr>\n";
print "<tr><td><select name=activedata size=5>\n";
$nextvalue = 0;

%picklisthash = get_lookup_values($dbh, $updatetable, "description", $updatetable . "id", "isactive='T'");
foreach $key (sort keys %picklisthash) {
    print "<option value=\"$picklisthash{$key}\">$key\n";
}
print "<option value=\"\">" . nbspaces(50) . "\n";
print "</select></td>\n";
print "<td><br></td>\n";
print "<td><select name=\"inactivedata\" size=5>\n";

%picklisthash = get_lookup_values($dbh, $updatetable, "description", $updatetable . "id", "isactive='F'");
foreach $key (sort keys %picklisthash) {
    print "<option value=\"$picklisthash{$key}\">$key\n";
}
print "<option value=\"\">" . nbspaces(50) . "\n";
print "</select></td></tr>\n";
print "<tr><td align=center>\n";

# history input holds changes from active to inactive status for keywords.
print "<input type=hidden name=history>\n";

$nextvalue = get_maximum_id($dbh, $updatetable) + 1;
print "<input name=nextvalue type=hidden value=$nextvalue>\n";
print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=loginusername type=hidden value=$username>\n";
print "<input name=loginusersid type=hidden value=$usersid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";

#disconnect from the database
&oncs_disconnect($dbh);

print "</td></tr></table>\n";
print "</TD></TR></TABLE>\n";
print "<br><br></form></body>\n";
print "</html>\n";
