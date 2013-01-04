#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# CMS BSC Discipline Lead Action Fulfillment script
#
# $Source: /data/dev/rcs/cms/perl/RCS/MO_action_fulfillment.pl,v $
# $Revision: 1.1 $
# $Date: 2001/11/15 19:27:21 $
# $Author: naydenoa $
# $Locker:  $
# $Log: MO_action_fulfillment.pl,v $
# Revision 1.1  2001/11/15 19:27:21  naydenoa
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
$cgiaction = ($cgiaction eq "") ? "fulfillment" : $cgiaction;
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

##################################
if ($cgiaction eq "fulfillment") {
##################################
    my $activity;
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "doSetTextImageLabel(\'Action Fulfillment\');\n";
    print "//-->\n";
    print "</script>\n";
    
    my $aid = $cmscgi -> param ('actionid');
    my $cid = $cmscgi -> param('commitmentid');
    my ($status, $actionstaken, $reworkrationale) = $dbh -> selectrow_array ("select status, actionstaken, reworkrationale from $SCHEMA.action where commitmentid = $cid and actionid = $aid");
    my ($iid) = $dbh -> selectrow_array ("select issueid from $SCHEMA.commitment where commitmentid=$cid");
    my $key;
    
    $dbh->{LongReadLen} = 1000000; #$TitleLength;
    $dbh->{LongTruncOk} = 0; #1;
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "function validate_action_data() {\n";
    print "    var msg = \"\";\n";
    print "    var tmpmsg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.editaction;\n";
    print "    msg += (validateform.actionstaken.value==\"\") ? \"You must enter the steps taken to fulfill the action.\\n\" : \"\";\n";
    print "    if (msg != \"\") {\n";
    print "        alert(msg);\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "}\n\n";

    print "function save_action() {\n";
    print "	var tempcgiaction;\n";
    print "	var msg = \"\";\n";
    print " 	var returnvalue = true;\n";
    print "	var validateform = document.editaction;\n";
    print "	msg += (validateform.actionstaken.value==\"\") ? \"You must enter fulfillment information for this action.\\n\" : \"\";\n";
    print "	if (msg != \"\") {\n";
    print "	    alert(msg);\n";
    print "	    returnvalue = false;\n";
    print "     }\n";
    print "	if (returnvalue) {\n";
    print "	    document.editaction.submit();\n";
    print "	}\n";
    print "	return (returnvalue);\n";
    print "    }\n\n";

    print "function pass_on() {\n";
    print "    var tempcgiaction;\n";
    print "    var returnvalue = true;\n\n";
    
    print "    if (validate_action_data()) {\n";
    print "        tempcgiaction = document.editaction.cgiaction.value;\n";
    print "        document.editaction.cgiaction.value = \"pass_on\";\n";
    print "        document.editaction.submit();\n";
    print "        document.editaction.cgiaction.value = tempcgiaction;\n";
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
    print "<form name=editaction enctype=\'multipart/form-data\' method=post target=\"control\" action=\"$ONCSCGIDir/MO_action_fulfillment.pl\">\n";
    print "<table border=0 align=center width=650><tr><td>\n";
    print "<input name=cgiaction type=hidden value=\"save_action\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=aid type=hidden value=$aid>\n";
    print "<input name=cid type=hidden value=$cid>\n";
    print "<input name=iid type=hidden value=$iid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    print "<table summary=\"Changes To Commitment/Action\" width=650 border=0 cellspacing=10 align=center>\n";
    $activity = "Action screen";
    print "<tr><td>\n";
    print "<table summary=\"Enter Action Table\" align=center width=650 border=0 cellspacing=10>\n";
    print doIssueTable (cid => $cid, dbh => $dbh, schema => $SCHEMA);
    print doHeadTable (cid => $cid, dbh => $dbh, schema => $SCHEMA);
    print doActionsTable (cid => $cid, aid => $aid, dbh => $dbh, schema => $SCHEMA, header => 1);
    print "<tr><td><hr width=50%></td></tr>\n";
    if ($status eq "RO") {
	print "<tr><td><b><li>Rationale for rework:</b><br>\n";
	print "<table border=1 width=100% bgcolor=#eeeeee bordercolor=#ff0000>\n";
	print "<tr><td>$reworkrationale</td></tr></table>\n";
	print "</td></tr>\n";
	print "\n";
	print "\n";
    }
    print "<tr><td align=left><b><li>Fulfillment information:</b><br>\n";
    print "<textarea name=actionstaken cols=75 rows=5>$actionstaken</textarea></td></tr>\n";

    print "<tr><td><hr width=70%></td></tr>\n";
    print &writeComment (active => 1);
    print doRemarksTable (dbh => $dbh, schema => $SCHEMA, aid => $aid, cid => $cid);
    print "</table>\n"; 
####################  end commitment table
    
    print "<br><center>\n";
    print "<input type=button name=saveaction value=\"Save Draft Work\" title=\"Save Action, can be edited later\" onclick=\"return(save_action())\">\n";
    print "<input type=button name=saveandcomplete value=\"Save and Pass on\" title=\"Save Action\" onclick=\"return(pass_on())\">\n";
    print "</td></tr></table>\n</form>\n";
    print "<br><br><br>\n</body>\n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
}  ####  endif create_action  ####

##################################
if ($cgiaction eq "save_action") {
##################################
    no strict 'refs';
    
    my $actionid = $cmscgi -> param ('aid');
    my $commitmentid = $cmscgi -> param ('cid');
    my $issueid = $cmscgi -> param ('iid');
    my $text = $cmscgi -> param ('actionstaken');
    my $textsql = ($text) ? ":textclob" : "NULL";
    my $activity;
    my $siteid = 1;
    my $remarks = $cmscgi -> param('commenttext');

    my $actionstr = "update $SCHEMA.action 
                     set actionstaken=$textsql,
                         closedate=SYSDATE,
                         updatedby=$usersid
                     where actionid=$actionid and commitmentid=$commitmentid";

    eval {
	$activity = "Insert action fulfillment info";
	my $csr = $dbh -> prepare ($actionstr);
	$csr -> bind_param (":textclob", $text, {ora_type => ORA_CLOB, ora_field => 'actionstaken'});
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
	&log_activity($dbh, 'F', $usersid, "Action " . &formatID2($commitmentid, 'CA') . "\/" . substr("00$actionid", -3) . " fulfillment information updated by BSC Discipline Lead");
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
}  ####  endif save_action  ####

##############################
if ($cgiaction eq "pass_on") {
##############################
    no strict 'refs';
    
    my $actionid = $cmscgi -> param ('aid');
    my $commitmentid = $cmscgi -> param ('cid');
    my $issueid = $cmscgi -> param ('iid');
    my $text = $cmscgi -> param ('actionstaken');
    my $textsql = ($text) ? ":textclob" : "NULL";
    my $activity;
    my $siteid = 1;
    my $remarks = $cmscgi -> param('commenttext');
    my $status = "FO";    

    my $actionstr = "update $SCHEMA.action 
                     set status='$status',
                         actionstaken=$textsql,
                         closedate=SYSDATE,
                         updatedby=$usersid
                     where actionid=$actionid and commitmentid=$commitmentid";

    eval {
	$activity = "Insert action fulfillment info";
	my $csr = $dbh -> prepare ($actionstr);
	$csr -> bind_param (":textclob", $text, {ora_type => ORA_CLOB, ora_field => 'actionstaken'});
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
	&log_activity($dbh, 'F', $usersid, "Action " . &formatID2($commitmentid, 'CA') . "\/" . substr("00$actionid", -3) . " fulfilled and passed on to BSC Licensing Lead for review");
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
