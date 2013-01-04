#!/usr/local/bin/newperl
#
# CMS Action Update Screen
#
# $Source: /data/dev/rcs/cms/perl/RCS/actionupdate.pl,v $
# $Revision: 1.1 $
# $Date: 2001/11/15 19:28:00 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: actionupdate.pl,v $
# Revision 1.1  2001/11/15 19:28:00  naydenoa
# Initial revision
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
tie my %lookup_values, "Tie::IxHash";

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

# print content type header
print $cmscgi->header('text/html');

my $cgiaction = $cmscgi->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = "action";

my $fullid = ((defined($cmscgi->param("fullid"))) ? $cmscgi->param("fullid") : "");
my ($commitmentid, $actionid) = split ("/", $fullid);
my $message = '';

my $nodevelopers = '';
if ($CMSProductionStatus) {
    $nodevelopers = ' and usersid < 1000';
}

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "")) {
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
print "<meta name=pragma content=no-cache>\n";
print "<meta name=expires content=0>\n";
print "<meta http-equiv=expires content=0>\n";
print "<meta http-equiv=pragma content=no-cache>\n";
print "<title>Commitment Management System: Action Update</title>\n";

print <<testlabel1;
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>
<script type="text/javascript">
<!--
var dosubmit = true;
if (parent == self) { // not in frames
    location = '$ONCSCGIDir/login.pl'
}
function submitForm(script, command) {
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'workspace';
    document.$form.submit();
}
function processQuery() {
    if (document.$form.selectedfullid.selectedIndex == -1 || document.$form.selectedfullid.options[document.$form.selectedfullid.options.length - 1].selected == 1) {
	alert ('You must first select an action');
    }
    else {
	document.$form.fullid.value = document.$form.selectedfullid[document.$form.selectedfullid.selectedIndex].value;
	submitForm('$form','actionupdate');
    }
}
doSetTextImageLabel('Action Update');
//-->
</script>
testlabel1

my $dbh = oncs_connect();
$dbh->{LongTruncOk} = 1;   # specify whole text or truncated fraction
$dbh->{LongReadLen} = 1000;
print "</head>\n<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

############################
if ($cgiaction eq "query") {
############################
    print "<table border=0 align=center width=650><tr><td>\n";
    print "<center>\n";
    print "<form name=$form enctype=\"multipart/form-data\" method=post target=\"control\">\n";
    print "<input name=cgiaction type=hidden value=\"query\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=fullid type=hidden value=$fullid>\n";
    print "<input name=commitmentid type=hidden value=$commitmentid>\n";
    print "<input name=actionid type=hidden value=$actionid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    eval {
        print "<b>Actions:</b><br><br>\n";
        print "<select size=10 name=selectedfullid onDblClick=\"processQuery();\">\n";
	my $actions = $dbh -> prepare ("select commitmentid, actionid, text from $SCHEMA.action order by commitmentid, actionid");
	$actions -> execute;
	my $fullid;
	while (my ($cid, $aid, $atext) = $actions -> fetchrow_array) {
	    $fullid = $cid . "/" . substr("00$aid",-3);
	    print "<option value=$fullid>CA" . lpadzero($fullid,9) . " - " . getDisplayString($atext,60) . "</option>\n";
	}
        print "<option value=blank>" . &nbspaces(60) . "\n";
        print "</select><br><br>\n";
        print "<input type=button name=querysubmit value='Update Action' onClick=\"processQuery();\">\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"action update - query page",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/\'/\'\'/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }
    print "</form>";
    &oncs_disconnect($dbh);
}

###################################
if ($cgiaction eq "actionupdate") {
###################################
    my $activity;
#    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
#    print "<!--\n";
#    print "doSetTextImageLabel(\'Enter Action for Potential Commitment\');\n";
#    print "//-->\n";
#    print "</script>\n";
    
#    my $cid = $cmscgi->param('commitmentid');
#    my ($iid) = $dbh -> selectrow_array ("select issueid from $SCHEMA.commitment where commitmentid = $cid");
    my $key;
    
    $dbh->{LongReadLen} = 1000000; #$TitleLength;
    $dbh->{LongTruncOk} = 0; #1;
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "function validate_action_data(status) {\n";
    print "    var msg = \"\";\n";
    print "    var tmpmsg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.actionupdate;\n";
    print "    msg += (validateform.text.value==\"\") ? \"You must enter the description of the action.\\n\" : \"\";\n";
    print "    msg += ((validateform.disclead.value==\'\') || (validateform.disclead.value==0)) ? \"You must select the discipline lead for this action.\\n\" : \"\";\n";
    print "    msg += ((validateform.liclead.value==\'\') || (validateform.liclead.value==0)) ? \"You must select the licensing lead for this action.\\n\" : \"\";\n";
    print "    msg += ((validateform.respmgr.value==\'\') || (validateform.respmgr.value==0)) ? \"You must select the manager for this action.\\n\" : \"\";\n";
    print "    msg += ((tmpmsg = validate_date(validateform.duedate_year.value, validateform.duedate_month.value, validateform.duedate_day.value, 0, 0, 0, 0, false, true, false)) == \"\") ? \"\" : \"Date Due - \" + tmpmsg + \"\\n\";\n";
    print "    if (status == \"CO\") {\n";
    print "        msg += (validateform.actionstaken.value==\'\') ? \"You must enter fulfillment information for this action.\\n\" : \"\";\n";
    print "    }\n";
    print "    msg += (validateform.commenttext.value==\'\') ? \"You must enter the nature of the update in the remarks field.\\n\" : \"\";\n";
    print "    if (msg != \"\") {\n";
    print "        alert(msg);\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "}\n";

    print "function pass_on(status) {\n";
    print "    var tempcgiaction;\n";
    print "    var returnvalue = true;\n\n";
    
    print "    if (validate_action_data(status)) {\n";
    print "        tempcgiaction = document.actionupdate.cgiaction.value;\n";
    print "        document.actionupdate.cgiaction.value = \"updateactiontable\";\n";
    print "        document.actionupdate.submit();\n";
    print "        document.actionupdate.cgiaction.value = tempcgiaction;\n";
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
    my ($atext, $adue, $fulfil, $aclose, $dlid, $llid, $rmid, $status) = $dbh -> selectrow_array ("select text, to_char(duedate,'MM/DD/YYYY'), actionstaken, closedate, dleadid, lleadid, managerid, status from $SCHEMA.action where commitmentid = $commitmentid and actionid = $actionid");

    print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<form name=actionupdate enctype=\'multipart/form-data\' method=post target=\"control\" action=\"$ONCSCGIDir/actionupdate.pl\">\n";
    print "<table border=0 align=center width=650><tr><td>\n";
    print "<input name=cgiaction type=hidden value=\"save_action\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=fullid type=hidden value=$fullid>\n";
    print "<input name=commitmentid type=hidden value=$commitmentid>\n";
    print "<input name=actionid type=hidden value=$actionid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    print "<table summary=\"Changes To Commitment/Action\" width=650 border=0 cellspacing=10 align=center>\n";
    $activity = "Action screen";
    print "<tr><td>\n";
    print "<table summary=\"Enter Action Table\" align=center width=650 border=0 cellspacing=10>\n";
    print "<tr><td><b><li>Action ID:&nbsp;&nbsp;CA" . lpadzero($fullid, 9) . "</b></td></tr>";
    print doIssueTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
    print doHeadTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
    print "<tr><td><hr width=50%></td></tr>\n";

    print "<tr><td align=left><b><li>Action Description:</b><br>\n";
    print "<textarea name=text cols=75 rows=5>$atext</textarea></td></tr>\n";

    print "<tr><td align=left><b><li>Discipline Lead:</b>&nbsp;&nbsp;\n";
    print "<select name=disclead>";
    print "<option value='' selected>Select Discipline Lead";
    my $dlquery = "select distinct u.firstname || ' ' || u.lastname, u.usersid, u.lastname from $SCHEMA.users u, $SCHEMA.defaultsiterole dr where dr.roleid=2 and u.usersid=dr.usersid order by u.lastname";
    my $csr = $dbh -> prepare ($dlquery);
    $csr -> execute;
    my $selected = "";
    while (my ($name, $uid) = $csr -> fetchrow_array) {
	$selected = ($uid == $dlid) ? " selected" : "";
	print "<option value=$uid$selected>$name\n";
    }
    print "</select></td></tr>\n";
    print "<tr><td align=left><b><li>Licensing Lead:</b>&nbsp;&nbsp;\n";
    print "<select name=liclead>";
    print "<option value='' selected>Select Licensing Lead";
    my $llquery = "select u.firstname || ' ' || u.lastname, u.usersid, u.lastname from $SCHEMA.users u, $SCHEMA.defaultsiterole sr where sr.roleid=7 and u.usersid=sr.usersid order by u.lastname";
    $csr = $dbh -> prepare ($llquery);
    $csr -> execute;
    while (my ($name, $uid) = $csr -> fetchrow_array) {
	$selected = ($uid == $llid) ? " selected" : "";
	print "<option value=$uid$selected>$name\n";
    }
    print "</select></td></tr>\n";
    print "<tr><td align=left><b><li>Responsible Manager:</b>&nbsp;&nbsp;\n";
    print "<select name=respmgr>";
    print "<option value='' selected>Select Responsible Manager";
    my $rmquery = "select firstname || ' ' || lastname, responsiblemanagerid from $SCHEMA.responsiblemanager order by lastname";
    $csr = $dbh -> prepare ($rmquery);
    $csr -> execute;
    while (my ($name, $uid) = $csr -> fetchrow_array) {
	$selected = ($uid == $rmid) ? " selected" : "";
	print "<option value=$uid$selected>$name\n";
    }
    print "</select></td></tr>\n";
    $csr -> finish;
    print "<tr><td align=left><b><li>Date Due:</b>&nbsp;&nbsp;\n";

    print build_date_selection('duedate', 'actionupdate', $adue); 
    print "</td></tr>\n";
    if ($status eq "CO") {
	print "<tr><td align=left><b><li>Action Fulfillment:</b><br>\n";
	print "<textarea name=actionstaken cols=75 rows=5>$fulfil</textarea></td></tr>\n";
    }
    print "<tr><td><hr width=70%></td></tr>\n";
    print &writeComment (active => 1);
    print doRemarksTable (cid => $commitmentid, aid => $actionid, dbh => $dbh, schema => $SCHEMA);
    print "</table>\n"; 
####################  end commitment table
    
    print "<br><center>\n";
    print "<input type=button name=updateaction value=\"Update Action\" title=\"Save Action\" onclick=\"return(pass_on('$status'))\">\n";
    print "</td></tr></table>\n</form>\n";
    print "<br><br>\n</body>\n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
}  #### endif actionupdate  ####

########################################
if ($cgiaction eq "updateactiontable") {
########################################
    no strict 'refs';
    
    my $commitmentid = $cmscgi -> param('commitmentid');
    my $actionid = $cmscgi -> param ('actionid');
    my $ll = $cmscgi -> param ('liclead');
    $ll = ($ll) ? $ll : "NULL";
    my $rm = $cmscgi -> param ('respmgr');
    my $dl = $cmscgi -> param ('disclead');
    my $text = $cmscgi->param('text');
    my $textsql = ($text) ? ":textclob" : "NULL";
    my $fulfil = $cmscgi->param('actionstaken');
    my $fulfilsql = ($fulfil) ? ":fulclob" : "NULL";
    my $duedate = $cmscgi->param('duedate');
    $duedate = ($duedate eq "") ? "NULL" : "TO_DATE('$duedate', 'MM/DD/YYYY')";
    my $activity;
    
    my $remarks = $cmscgi->param('commenttext');
    
    my $actionsqlstring;
    $actionsqlstring = "update $SCHEMA.action 
                        set text = $textsql, dleadid = $dl, lleadid = $ll, 
                            managerid = $rm, duedate = $duedate, 
                            actionstaken = $fulfilsql, updatedby = $usersid 
                        where commitmentid = $commitmentid and 
                              actionid = $actionid";
    eval {
	$activity = "Update action";
	my $csr = $dbh -> prepare ($actionsqlstring);
	$csr -> bind_param (":textclob", $text, {ora_type => ORA_CLOB, ora_field => 'text'});
	if ($fulfil) {
	    $csr -> bind_param (":fulclob", $fulfil, {ora_type => ORA_CLOB, ora_field => 'actionstaken'});
	}
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
	&log_activity($dbh, 'F', $usersid, "Action " . &formatID2($commitmentid, 'CA') . "\/" . substr("00$actionid", -3) . " updated");
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
	print "parent.workspace.location=\"$ONCSCGIDir/actionupdate.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	print "parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
        print "//-->\n";
	print "</script>\n";
    }
    &oncs_disconnect($dbh);
    print "</head><body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0></body></html>\n";
    exit 1;
} ####  endif updateactiontable  ####

print "<br><br></body></html>\n";
&oncs_disconnect($dbh);


