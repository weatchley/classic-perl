#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# CMS Commitment Coordinator Action Entry script
#
# $Source: /data/dev/rcs/cms/perl/RCS/CC_actionentry.pl,v $
# $Revision: 1.2 $
# $Date: 2003/01/16 23:44:19 $
# $Author: naydenoa $
# $Locker:  $
# $Log: CC_actionentry.pl,v $
# Revision 1.2  2003/01/16 23:44:19  naydenoa
# Added use of manager type - CREQ00023
#
# Revision 1.1  2001/11/15 19:25:48  naydenoa
# Initial revision
#
#

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);
use Edit_Screens;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use Tie::IxHash;
use strict;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

# print content type header
print $cmscgi->header('text/html');

my $pagetitle = "Commitment Coordinator Review";
my $cgiaction = $cmscgi->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = "issue";

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "")) {
    print "<script type=\"text/javascript\">\n";
    print "<!--\n";
    print "parent.location=\'$ONCSCGIDir/login.pl\';\n";
    print "//-->\n";
    print "</script>\n";
    exit 1;
}

#print html
print "<html>\n";
print "<head>\n";
print "<meta name=pragma content=no-cache>\n";
print "<meta name=expires content=0>\n";
print "<meta http-equiv=expires content=0>\n";
print "<meta http-equiv=pragma content=no-cache>\n";
print "<title>$pagetitle</title>\n";

print <<testlabel1;
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>
<script type="text/javascript">
<!--
var dosubmit = true;
if (parent == self) {  // not in frames
    location = '$ONCSCGIDir/login.pl'
}
//-->
</script>
testlabel1

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();
my $nodevelopers = "";
if ($CMSProductionStatus) {
    $nodevelopers = "usersid < 1000 and";
}
# find the Role ID for the M&O Commitment Coordinator
my $MOCC_Roleid = 1; # Commitment Coordinator
my $MOCC_statusid = 1; # Commitment Coordinator Review

###################################
if ($cgiaction eq "createaction") {
###################################
    my $activity;
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "doSetTextImageLabel(\'Enter Action for Potential Commitment\');\n";
    print "//-->\n";
    print "</script>\n";
    
    my $cid = $cmscgi->param('commitmentid');
    my ($iid) = $dbh -> selectrow_array ("select issueid from $SCHEMA.commitment where commitmentid = $cid");
    my $key;
    
    $dbh->{LongReadLen} = 1000000; #$TitleLength;
    $dbh->{LongTruncOk} = 0; #1;
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "function validate_action_data() {\n";
    print "    var msg = \"\";\n";
    print "    var tmpmsg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.newaction;\n";
    print "    msg += (validateform.text.value==\"\") ? \"You must enter the description of the action.\\n\" : \"\";\n";
    print "    msg += ((validateform.disclead.value==\'\') || (validateform.disclead.value==0)) ? \"You must select the discipline lead for this action.\\n\" : \"\";\n";
    print "    msg += ((validateform.liclead.value==\'\') || (validateform.liclead.value==0)) ? \"You must select the licensing lead for this action.\\n\" : \"\";\n";
    print "    msg += ((validateform.BSCresponsiblemanager.value==\'\') || (validateform.BSCresponsiblemanager.value==0)) ? \"You must select the BSC manager for this action.\\n\" : \"\";\n";
    print "    msg += ((tmpmsg = validate_date(validateform.duedate_year.value, validateform.duedate_month.value, validateform.duedate_day.value, 0, 0, 0, 0, false, true, false)) == \"\") ? \"\" : \"Date Due - \" + tmpmsg + \"\\n\";\n";
    print "    if (msg != \"\") {\n";
    print "        alert(msg);\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "}\n";
    print "function save_action() {\n";
    print "    var tempcgiaction;\n";
    print "    var msg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.newaction;\n\n";
    print "    msg += (validateform.text.value==\"\") ? \"You must enter the potential commitment text.\\n\" : \"\";\n";
    print "    msg += (validateform.discipline.value==\'\' || validateform.discipline.value == \'NULL\') ? \"You must select the discipline lead for this commitment.\\n\" : \"\";\n";
    print "    msg += ((tmpmsg = validate_date(validateform.duedate_year.value, validateform.duedate_month.value, validateform.duedate_day.value, 0, 0, 0, 0, false, true, false)) == \"\") ? \"\" : \"Date Due - \" + tmpmsg + \"\\n\";\n\n";
    print "    if (msg != \"\") {\n"; 
    print "        alert(msg);\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    if (returnvalue) {\n";
    print "        document.newaction.submit();\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "}\n\n";
    
    print "function pass_on() {\n";
    print "    var tempcgiaction;\n";
    print "    var returnvalue = true;\n\n";
    
    print "    if (validate_action_data()) {\n";
    print "        tempcgiaction = document.newaction.cgiaction.value;\n";
    print "        document.newaction.cgiaction.value = \"pass_on\";\n";
    print "        document.newaction.submit();\n";
    print "        document.newaction.cgiaction.value = tempcgiaction;\n";
    print "    }\n";
    print "    else {\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "}\n\n";
    print "//-->\n";
    print "</script>\n";
    print "</head>\n\n";
##################
    print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<form name=newaction enctype=\'multipart/form-data\' method=post target=\"control\" action=\"$ONCSCGIDir/CC_actionentry.pl\">\n";
    print "<table border=0 align=center width=650><tr><td>\n";
    print "<input name=cgiaction type=hidden value=\"save_action\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=cid type=hidden value=$cid>\n";
    print "<input name=iid type=hidden value=$iid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    print "<table summary=\"Changes To Commitment/Action\" width=650 border=0 cellspacing=10 align=center>\n";
    $activity = "Action screen";
    print "<tr><td>\n";
    print "<table summary=\"Enter Action Table\" align=center width=650 border=0 cellspacing=10>\n";
    print doIssueTable (iid => $iid, dbh => $dbh, schema => $SCHEMA);
    print doHeadTable (cid => $cid, dbh => $dbh, schema => $SCHEMA);
    print "<tr><td><hr width=50%></td></tr>\n";
    print "<tr><td><b><li>Current Actions:</b>";
    my ($actcount) = $dbh -> selectrow_array ("select count (*) from $SCHEMA.action where commitmentid = $cid");
    if ($actcount) {
	print "</td></tr>\n";
	my $curracts = $dbh -> prepare ("select actionid from $SCHEMA.action where commitmentid=$cid order by actionid");
	$curracts -> execute;
	while (my ($curractid) = $curracts -> fetchrow_array) {
	    print doActionsTable (cid => $cid, aid => $curractid, dbh => $dbh, schema => $SCHEMA);
	}
	$curracts -> finish;
    }
    else {
	print "&nbsp;&nbsp;None</td></tr>\n";
    }
    print "<tr><td><hr width=50%></td></tr>\n";

    print "<tr><td align=left><b><li>Action Description:</b><br>\n";
    print "<textarea name=text cols=75 rows=5></textarea></td></tr>\n";

    print "<tr><td align=left><b><li>BSC Discipline Lead:</b>&nbsp;&nbsp;\n";
    print "<select name=disclead>";
    print "<option value='' selected>Select Discipline Lead";
    my $dlquery = "select distinct u.firstname || ' ' || u.lastname, u.usersid, u.lastname from $SCHEMA.users u, $SCHEMA.defaultsiterole dr where dr.roleid=2 and u.usersid=dr.usersid order by u.lastname";
    my $csr = $dbh -> prepare ($dlquery);
    $csr -> execute;
    while (my ($name, $uid) = $csr -> fetchrow_array) {
	print "<option value=$uid>$name\n";
    }
    print "</select></td></tr>\n";
    print "<tr><td align=left><b><li>BSC Licensing Lead:</b>&nbsp;&nbsp;\n";
    print "<select name=liclead>";
    print "<option value='' selected>Select Licensing Lead";
    my $llquery = "select u.firstname || ' ' || u.lastname, u.usersid, u.lastname from $SCHEMA.users u, $SCHEMA.defaultsiterole sr where sr.roleid=7 and u.usersid=sr.usersid order by u.lastname";
    $csr = $dbh -> prepare ($llquery);
    $csr -> execute;
    while (my ($name, $uid) = $csr -> fetchrow_array) {
	print "<option value=$uid>$name\n";
    }
    print "</select></td></tr>\n";
    print selectRM (dbh => $dbh, schema => $SCHEMA, mgrtype => 1);
    print "</td></tr>\n";
    $csr -> finish;
    print "<tr><td align=left><b><li>Date Due:</b>&nbsp;&nbsp;\n";
    print build_date_selection('duedate', 'newaction');
    print "</td></tr>\n";
    print "<tr><td><hr width=70%></td></tr>\n";
    print &writeComment (active => 1);
    print "</table>\n"; 
####################  end commitment table
    
    print "<br><center>\n";
    print "<input type=button name=saveandcomplete value=\"Save Action\" title=\"Save Action\" onclick=\"return(pass_on())\">\n";
    print "</td></tr></table>\n</form>\n";
    print "<br><br><br>\n</body>\n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
}  ####  endif create_action  ####

##############################
if ($cgiaction eq "pass_on") {
##############################
    no strict 'refs';
    
    my $commitmentid = $cmscgi -> param('cid');
    my $issueid = $cmscgi -> param ('iid');
    my $ll = $cmscgi -> param ('liclead');
    $ll = ($ll) ? $ll : "NULL";
    my $rm = $cmscgi -> param ('BSCresponsiblemanager');
    my $dl = $cmscgi -> param ('disclead');
    my $text = $cmscgi->param('text');
    my $textsql = ($text) ? ":textclob" : "NULL";
    my $duedate = $cmscgi->param('duedate');
    $duedate = ($duedate eq "") ? "NULL" : "TO_DATE('$duedate', 'MM/DD/YYYY')";
    my $activity;
    
    my $siteid = 1;
    
    ####  commitment variables  ####
    my $actionid;
    eval {
	$activity = "Get next action ID";
	my ($lastactionid) = $dbh -> selectrow_array ("select max(actionid) from $SCHEMA.action where commitmentid = $commitmentid");
                        #### get_next_id($dbh, 'Action');
	$actionid = ($lastactionid) ? ($lastactionid + 1) : 1;
#	$dbh -> commit;

    };
    if ($@) {
	$dbh -> rollback;
	my $alertstring = errorMessage ($dbh, $username, $usersid, 'actionid_seq', "", $activity, $@);
	    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	    print "<!--\n";
	    print "alert(\"$alertstring\");\n";
	    print "parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	    print "//-->\n";
	    print "</script>\n";
	    &oncs_disconnect($dbh);
	    exit 1;
    }
    
    my $remarks = $cmscgi->param('commenttext');
    
    my $actionsqlstring;
    $actionsqlstring = "INSERT INTO $SCHEMA.action
                                       (actionid, status,
                                        siteid, commitmentid, text, 
                                        dleadid, lleadid, managerid,
                                        updatedby, duedate)
                                VALUES ($actionid,
                                        'OO', $siteid, $commitmentid,
                                        $textsql, $dl, $ll, $rm, 
                                        $usersid, $duedate)";

    eval {
	$activity = "Insert new action";
	my $csr = $dbh -> prepare ($actionsqlstring);
	$csr -> bind_param (":textclob", $text, {ora_type => ORA_CLOB, ora_field => 'text'});
	$csr -> execute;

	if ($remarks) {
	    $activity = "Insert remark for action $actionid";
	    my $insertremark = "insert into $SCHEMA.action_remarks (actionid, usersid, text, dateentered, commitmentid) values ($actionid, $usersid, :remark, SYSDATE, $commitmentid)";
	    $csr = $dbh -> prepare ($insertremark);
	    $csr -> bind_param (":remark", $remarks, {ora_type => ORA_CLOB, ora_field => 'text'});
	    $csr -> execute;
	}
	$csr -> finish;
	$dbh -> commit;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'action', "$actionid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
	print "alert(\"$alertstring\");\n";
	print "//-->\n";
	print "</script>\n";
    }
    else {
	&log_activity($dbh, 'F', $usersid, "Action " . &formatID2($commitmentid, 'CA') . "\/" . substr("00$actionid", -3) . " added to the system");
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
	print "parent.workspace.location=\"$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	print "parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
        print "//-->\n";
	print "</script>\n";
    }
    &oncs_disconnect($dbh);
    print "</head><body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0></body></html>\n";
    exit 1;
}  ####  endif pass_on  ####
