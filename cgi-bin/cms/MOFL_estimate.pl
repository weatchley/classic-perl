#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# BSC Discipline Lead commitment determination screen.
#
# $Source: /data/dev/rcs/cms/perl/RCS/MOFL_estimate.pl,v $
# $Revision: 1.55 $
# $Date: 2001/12/10 22:50:58 $
# $Author: naydenoa $
# $Locker:  $
# $Log: MOFL_estimate.pl,v $
# Revision 1.55  2001/12/10 22:50:58  naydenoa
# Changed BSCLL to BSCDL
#
# Revision 1.54  2001/11/15 23:11:03  naydenoa
# Added action display to commitment info.
#
# Revision 1.53  2001/05/04 21:54:05  naydenoa
# Update evals
#
# Revision 1.52  2001/05/02 22:14:17  naydenoa
# Modified evals, calls to Edit_Screens
#
# Revision 1.51  2001/02/21 22:22:24  naydenoa
# Added RSS processing
#
# Revision 1.50  2001/01/02 17:35:08  naydenoa
# More code clean-up
#
# Revision 1.49  2000/12/19 18:58:03  naydenoa
# Code cleanup
#
# Revision 1.48  2000/12/07 19:03:01  naydenoa
# Changed entry to commitmentrole table to reflect actual MO lead
# who worked on the commitment
#
# Revision 1.47  2000/11/20 19:40:00  naydenoa
# Moved some redundant code to Edit_Screens module
#
# Revision 1.46  2000/11/07 23:28:34  naydenoa
# Added email notification
# Added issue source display
# Took out rationales
#
# Revision 1.45  2000/10/31 19:43:20  naydenoa
# Took out commitment rationale, updated function calls
# to Edit_Screens
#
# Revision 1.44  2000/10/26 18:42:30  naydenoa
# Added commitment remarks display
# Changed table width to 650, textareawidth to 75
#
# Revision 1.43  2000/10/24 21:46:58  naydenoa
# Took out test prints
#
# Revision 1.42  2000/10/24 21:32:18  naydenoa
# Implemented commitment keyword addition.
#
# Revision 1.41  2000/10/18 21:02:40  munroeb
# fixed activity log message
#
# Revision 1.40  2000/10/18 20:10:24  munroeb
# updated log activity messages
#
# Revision 1.39  2000/10/17 15:57:14  munroeb
# removed log_history perm.
#
# Revision 1.38  2000/10/16 17:55:07  munroeb
# removed log_history function
#
# Revision 1.37  2000/10/06 20:46:40  munroeb
# added log_activity feature to script
#
# Revision 1.36  2000/10/06 19:18:18  naydenoa
# Added WBS selection
#
# Revision 1.35  2000/10/03 20:41:51  naydenoa
# Updates status id's and references.
#
# Revision 1.34  2000/09/29 19:14:39  naydenoa
# Changed references to roles and statuses (now by ID)
#
# Revision 1.33  2000/09/28 20:07:54  naydenoa
# Checkpoint after Version 2 release
#
# Revision 1.32  2000/09/11 16:02:57  naydenoa
# Took out dead code, changed buttons to point to new home screen.
#
# Revision 1.31  2000/09/08 23:46:35  naydenoa
# More interface modifications.
#
# Revision 1.30  2000/09/05 18:48:18  naydenoa
# Interface revision/update
#
# Revision 1.29  2000/09/01 23:56:18  naydenoa
# Major interface rewrite. Added use of module Edit_Screens (does
# details).
#
# Revision 1.28  2000/08/25 23:03:15  atchleyb
# added debug code
#
# Revision 1.27  2000/08/25 17:40:29  atchleyb
# made requested text changes
#
# Revision 1.26  2000/08/25 17:17:51  atchleyb
# made requested text changes
#
# Revision 1.25  2000/08/25 16:25:48  atchleyb
# changed Technical Lead to Discipline Lead
#
# Revision 1.24  2000/08/21 20:55:50  atchleyb
# fixed var name bug
#
# Revision 1.23  2000/08/21 20:27:55  atchleyb
# fixed var name bug
#
# Revision 1.22  2000/08/21 18:42:33  atchleyb
# added check schema line
# changes cirscgi cmscgi
#
# Revision 1.21  2000/07/24 15:08:52  johnsonc
# Inserted GIF file for display.
#
# Revision 1.20  2000/07/17 20:43:08  atchleyb
# placed forms in table with a width of 750
#
# Revision 1.19  2000/07/11 14:43:44  munroeb
# finished modifying html formatting
#
# Revision 1.18  2000/07/06 23:30:20  munroeb
# finished mods to html and javascripts.
#
# Revision 1.17  2000/07/05 22:44:33  munroeb
# made minor changes to html and javascripts
#
# Revision 1.16  2000/06/21 20:49:25  johnsonc
# Editted opening page select object to support double click event.
#
# Revision 1.15  2000/06/15 22:56:04  johnsonc
# Revise WSB table entry to be optional display in edit and query screens
#
# Revision 1.14  2000/06/14 18:37:40  zepedaj
# *** empty log message ***
#
# Revision 1.13  2000/06/13 21:41:39  zepedaj
# Fixed width of tables so the columns would be the same
#
# Revision 1.12  2000/06/13 19:26:39  johnsonc
# Change 'Rationale For Commitment' field to display only when data is present
#
# Revision 1.11  2000/06/13 15:28:59  johnsonc
# Editted commitments select object to a fixed width.
#
# Revision 1.10  2000/06/12 15:47:17  johnsonc
# Add 'C' in front of commitment ID and 'I' in front of issue ID.
#  Add 'proposed' to edit and view commitment page titles.
#
# Revision 1.9  2000/06/09 20:19:08  johnsonc
# Edit secondary discipline text area to display only when it contains data
#
# Revision 1.8  2000/06/02 23:40:56  johnsonc
#  Insert comment text areas.
#
# Revision 1.7  2000/05/19 23:46:01  zepedaj
# Changed code for the final WBS structure
#
# Revision 1.6  2000/05/18 23:11:28  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.5  2000/05/04 23:54:20  zepedaj
# debug pass, testing completed, code works.
#
# Revision 1.4  2000/05/03 22:58:40  zepedaj
# fixed sql string bugs to read M&O Estimate Status and the commitment list.
#
# Revision 1.3  2000/05/03 22:25:21  zepedaj
# Added estimate field
#
# Revision 1.2  2000/05/03 21:48:22  zepedaj
# First edit, fixed compilation bugs
#
# Revision 1.1  2000/05/03 21:38:30  zepedaj
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

my $pagetitle = "M&amp;O Discipline Lead Estimate";
my $cgiaction = $cmscgi->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = "issue";

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "")){
    print <<openloginpage;
    <script type="text/javascript">
    <!--
    parent.location='$ONCSCGIDir/login.pl';
    //-->
    </script>
openloginpage
    exit 1;
}

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
if (parent == self) {
    location = '$ONCSCGIDir/login.pl'
}
//-->
</script>
<script language="JavaScript" type="text/javascript">
<!--
    doSetTextImageLabel('Commitment Estimate');
//-->
</script>
testlabel1

my $dbh = oncs_connect();

# find the Role ID and Status ID for the DOE Discipline Lead Review
my $MOFL_Roleid = 2; # M&O Discipline Lead
my $MOFL_estimate_statusid = 2; # M&O Estimate

####################################
if ($cgiaction eq "editcommitment"){
####################################
    my $activity;
    my $commitmentid = $cmscgi->param('commitmentid');
    my $textareawidth = 75;
    my %commitmenthash;
    my %issuehash;
    my $issueid;
    
    my $commitmentidstring = substr("0000$commitmentid", -5);
    eval {
	$activity = "Get info for commitment $commitmentid";
	%commitmenthash = get_commitment_info($dbh, $commitmentid);
	$issueid = $commitmenthash{'issueid'};
	$activity = "Get info for issue $issueid";
	%issuehash = get_issue_info ($dbh, $issueid);
    };
    if ($@) {
	my $logmessage = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$logmessage =~ s/\n/\\n/g;
	$logmessage =~ s/\'/\'\'/g;
	print "<script language=javascript><!--\n";
	print "   alert('$logmessage');\n";
	print "//--></script>\n";
    }
    my $text = $commitmenthash{'text'};
    my $primarydiscipline = $commitmenthash{'primarydiscipline'};
    my $duedate = $commitmenthash{'duedate'};
    my ($duemonth, $dueday, $dueyear) = split /\//, $duedate;
    my $fulfilldate = $commitmenthash{'fulfilldate'};
    my $rssid = $commitmenthash{'rssfactor'};
    
    my $page = $issuehash{'page'};
    my $imageextension = $issuehash{'imageextension'}; 
    
    # the following commitment variables may not be available
    my $estimate = $commitmenthash{'estimate'};
    my $actionplan = $commitmenthash{'actionplan'};
    
    #booleans
    my $commitmenthasestimate = (defined($estimate) && ($estimate ne ""));
    my $commitmenthasactionplan =(defined($actionplan) && ($actionplan ne ""));
    my $key;
    
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "function validate_commitment_data(){\n";
    print "    var msg = \"\";\n";
    print "    var tmpmsg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.editcommitment;\n";
    print "    var fulfillmonth = validateform.fulfilldate_month.options[validateform.fulfilldate_month.selectedIndex].value;\n";
    print "    var fulfillday = validateform.fulfilldate_day.options[validateform.fulfilldate_day.selectedIndex].value;\n";
    print "    var fulfillyear = validateform.fulfilldate_year.value;\n";
    print "    fulfilldate = new Date (fulfillyear, fulfillmonth - 1, fulfillday);\n";
    print "    duedate = new Date (validateform.duedate_year.value, validateform.duedate_month.value - 1, validateform.duedate_day.value);\n\n";
    
    print "    msg += (validateform.text.value==\"\") ? \"You must enter the potential commitment text.\\n\" : \"\";\n";
    print "    msg += (validateform.workbreakdownstructure.value == \'\') ? \"You must select a Work Breakdown Structure or 'Not Available'.\\n\" : \"\";\n";
# 	print "    msg =+ (validateform.rssfactor.value == \'\') ? \"You must select an RSS factor or 'Not Available'.\\n\" : \"\"\n";
    print "    msg += (validateform.actionplan.value==\"\") ? \"You must enter the action plan.\\n\" : \"\";\n";
    print "    msg += (validateform.estimate.value==\"\") ? \"You must enter an estimate for the work to be performed.\\n\" : \"\";\n";
    print "    msg += ((tmpmsg = validate_date(fulfillyear, fulfillmonth, fulfillday, 0, 0, 0, 0, false, true, false)) == \"\") ? \"\" : \"Fulfillment Date - \" + tmpmsg + \"\\n\";\n";
    print "    if (Date.parse(fulfilldate) <= Date.parse(duedate)) {\n";
    print "    msg += \"Fulfillment date cannot precede or be the same as the date due to the Commitment Maker.\\n\";\n";
    print "    }\n\n";
    
    print "    if (msg != \"\"){\n";
    print "        alert(msg);\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "}\n\n";
    
    print "function save_commitment(){\n";
    print "    var tempcgiaction;\n";
    print "    var msg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.editcommitment;\n\n";
    print "    msg += (validateform.text.value==\"\") ? \"You must enter the potential commitment text.\\n\" : \"\";\n";
    print "    if (msg != \"\"){\n";
    print "        alert(msg);\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    if (returnvalue){\n";
    print "        selectemall(document.editcommitment.keywords);\n";
    print "        document.editcommitment.submit();\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "    }\n\n";
    print "function pass_on(){\n";
    print "    var tempcgiaction;\n";
    print "    var returnvalue = true;\n\n";
    print "    if (validate_commitment_data()){\n";
    print "        tempcgiaction = document.editcommitment.cgiaction.value;\n";
    print "        document.editcommitment.cgiaction.value = \"pass_on\";\n";
    print "        selectemall(document.editcommitment.keywords);\n";
    print "        document.editcommitment.submit();\n";
    print "        document.editcommitment.cgiaction.value = tempcgiaction;\n";
    print "    }\n";
    print "    else {\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "}\n";
    print "//-->\n";
    print "</script>\n";
    print "</head>\n";
    print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><br>\n";
    print "<table border=0 align=center width=650><tr><td>\n";
    print "<form name=editcommitment method=post target=\"control\" action=\"$ONCSCGIDir/MOFL_estimate.pl\">\n";
    print "<input name=cgiaction type=hidden value=\"save_commitment\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=commitmentid type=hidden value=$commitmentid>\n";
    print "<input name=primarydiscipline type=hidden value=$primarydiscipline>\n";
    print "<input type=hidden name=duedate_month value=$duemonth>\n";
    print "<input type=hidden name=duedate_day value=$dueday>\n";
    print "<input type=hidden name=duedate_year value=$dueyear>\n";
    print "<table width=650 align=center cellspacing=10>\n";
    my $outstring;
    eval {
	$activity = "Get info for commitment $commitmentid";
	print &doIssueTable (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid);
	print &doIssueSourceTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA, page => $page, imagepath => $CMSImagePath, imageextension => $imageextension);
	print &doHeadTable(dbh => $dbh, schema => $SCHEMA, cid => $commitmentid, cidstring => $commitmentidstring);


	my ($actcount) = $dbh -> selectrow_array ("select count (*) from $SCHEMA.action where commitmentid = $commitmentid");
	if ($actcount) {
            my $count = 0;
	    my $header;
	    my $curracts = $dbh -> prepare ("select actionid from $SCHEMA.action where commitmentid=$commitmentid order by actionid");
	    $curracts -> execute;
	    while (my ($curractid) = $curracts -> fetchrow_array) {
		$header = ($count) ? 0 : 1;
		print doActionsTable (cid => $commitmentid, aid => $curractid, dbh => $dbh, schema => $SCHEMA, header => $header);
		$count++;
	    }
	    $curracts -> finish;
	}
	else {
	    print "<tr><td><b><li>Actions:</b>&nbsp;&nbsp;None\n</td></tr>"
	}
	print "<tr><td><hr width=50%></td></tr>\n";



	print &writeCommitmentText (text => $text, active => 1);
	print selectWBS (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid);
####	    print selectRSS (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid); #### not needed right now...
	print selectKeywords (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid);
	print &writeWorkEstimate (estimate => $estimate, active => 1);
	print "<tr><td><b><li>Estimated Fulfillment Date: </b>&nbsp;&nbsp;\n";
	print build_date_selection('fulfilldate', 'editcommitment', ($fulfilldate) ? $fulfilldate : 'today');
	print "</td></tr>\n";
	print &writeActionPlan (actionplan => $actionplan, active => 1);
	print "<tr><td><hr width=70%></td></tr>\n";
	print &writeComment (active => 1);
	print doRemarksTable (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid);
    };
    if ($@) {
	my $logmessage = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$logmessage =~ s/\n/\\n/g;
	$logmessage =~ s/\'/\'\'/g;
	print "<script language=javascript><!--\n";
	print "   alert('$logmessage');\n";
	print "//--></script>\n";
    }
    print "</table>\n<center>\n";
    print "<input type=button name=savecommitment value=\"Save Draft Work\" title=\"Save Draft Work, can be edited later\" onclick=\"return(save_commitment())\">\n";
    print "<input type=button name=saveandcomplete value=\"Save and Pass On\" title=\"Save Commitment and pass it on to the DOE Discipline Lead\" onclick=\"return(pass_on())\">\n";
    print "</form>\n</td></tr></table>\n<br><br><br>\n</body>\n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
}  ################  endif editcommitment  ########################

# save the commitment
######################################
if ($cgiaction eq "save_commitment") {
######################################
    no strict 'refs';
    
    #control variables
    my $commitmentid = $cmscgi->param('commitmentid');
    my $activity;
    
    # commitment variables
    my $text = $cmscgi->param('text');
    my $textsql = ($text) ? ":textclob" : "NULL";
    my $estimate = $cmscgi->param('estimate');
    my $estimatesql = ($estimate) ? ":estimateclob" : "NULL";
    my $actionplan = $cmscgi->param('actionplan');
    my $actionplansql = ($actionplan) ? ":actionplanclob" : "NULL";
    my $fulfilldate = $cmscgi -> param ('fulfilldate');
#    my $rssid = $cmscgi -> param ('rssfactor');
#    $rssid = ($rssid) ? $rssid : "NULL";
    my $controlaccountid = $cmscgi->param('workbreakdownstructure');
    if (($controlaccountid eq "") || ($controlaccountid eq "NULL")) {
	$controlaccountid = "NULL";
    }
    else {
	$controlaccountid = "'$controlaccountid'";
    }
    my $comments = $cmscgi->param('commenttext');
    
    #sql strings
    my $commitmentupdatesql = "UPDATE $SCHEMA.commitment SET text = $textsql, estimate = $estimatesql, actionplan = $actionplansql, updatedby = $usersid, controlaccountid = $controlaccountid, fulfilldate = to_date('$fulfilldate','MM/DD/YYYY') WHERE commitmentid = $commitmentid"; #rssfactorid = $rssid,
    eval {
	$activity = "Update Commitment";
	my $csr = $dbh->prepare($commitmentupdatesql);
	$csr->bind_param(":textclob", $text, {ora_type => ORA_CLOB, ora_field => 'text' });
	if ($estimate) {
	    $csr->bind_param(":estimateclob", $estimate, {ora_type => ORA_CLOB, ora_field => 'estimate' });
	}
	if ($actionplan) {
	    $csr->bind_param(":actionplanclob", $actionplan, {ora_type => ORA_CLOB, ora_field => 'actionplan' });
	}
	$csr->execute;
	
	# update commitment remarks
	if ($comments) {
	    my $remarkupdate = "insert into $SCHEMA.commitment_remarks (usersid, text, dateentered, commitmentid) values ($usersid, :remarks, SYSDATE, $commitmentid)";
	    $activity = "Update remarks for commitment $commitmentid";
	    $csr = $dbh -> prepare ($remarkupdate);
	    $csr -> bind_param (":remarks", $comments, {ora_type => ORA_CLOB, ora_field => 'text'});
	    $csr -> execute;
	}	
	
	#add keywords to record(s)
	my $oldkeywords = "delete from $SCHEMA.commitmentkeyword where commitmentid=$commitmentid";
	my $oldcsr = $dbh -> prepare ($oldkeywords);
	$oldcsr -> execute;
	my $keywordid;
	foreach $keywordid ($cmscgi->param('keywords')) {
	    if (($keywordid ne '')) {
		$activity = "Insert keyword: $keywordid for commitment: $commitmentid.";
		my $keywordsqlstring = "INSERT INTO $SCHEMA.commitmentkeyword (commitmentid, keywordid) VALUES($commitmentid, $keywordid)";
		$csr = $dbh->prepare($keywordsqlstring);
		$csr->execute;
	    }
	}
	$csr->finish;
	$dbh->commit;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'commitment', "$commitmentid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print <<pageerror;
	<script language="JavaScript" type="text/javascript">
	<!--
	alert("$alertstring");
        //-->
        </script>
pageerror
    }
    else {
	&log_activity($dbh, 'F', $usersid, "Commitment ".&formatID2($commitmentid, 'C')." updated by the BSC Discipline Lead");
	print <<pageresults;
	<script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
    }
    &oncs_disconnect($dbh);
    print "</head><body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0></body></html>\n";
    exit 1;
}  ##############  endif save_commitment  ####################


##############################
if ($cgiaction eq "pass_on") { #### pass to next user (DOE Disc Lead)
##############################
    no strict 'refs';
    
    #control variables
    my $commitmentid =  $cmscgi->param('commitmentid');
    my $activity;
    my $nextstatusid = 3; # DOEDL determination
    
    # Find user info; Site id of user same as commitment
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);
    
    # commitment variables
    my $text = $cmscgi->param('text');
    my $textsql = ($text) ? ":textclob" : "NULL";
    my $estimate = $cmscgi->param('estimate');
    my $estimatesql = ($estimate) ? ":estimateclob" : "NULL";
    my $actionplan = $cmscgi->param('actionplan');
    my $actionplansql = ($actionplan) ? ":actionplanclob" : "NULL";
    my $fulfilldate = $cmscgi -> param ('fulfilldate');
#    my $rssid = $cmscgi -> param ('rssfactor');
    my $controlaccountid = $cmscgi->param('workbreakdownstructure');
    if (($controlaccountid eq "") || ($controlaccountid eq "NULL")) {
	$controlaccountid = "NULL";
    }
    else {
	$controlaccountid = "'$controlaccountid'";
    }
    my $comments = $cmscgi->param('commenttext');
    
    #role variables
    my $primarydiscipline = $cmscgi->param('primarydiscipline');
    my $DOEFL_roleid = 3; # DOE Discipline Lead
    my $DOEFL_usersid;
    ($DOEFL_usersid) = lookup_column_values($dbh, 'defaultdisciplinerole', 'usersid', "roleid = $DOEFL_roleid AND disciplineid = $primarydiscipline AND siteid = $siteid");
    
    #sql strings
    my $commitmentupdatesql = "UPDATE $SCHEMA.commitment SET text = $textsql, estimate = $estimatesql, actionplan = $actionplansql, statusid = $nextstatusid, controlaccountid = $controlaccountid, updatedby = $usersid, fulfilldate = to_date('$fulfilldate','MM/DD/YYYY') WHERE commitmentid = $commitmentid"; # rssfactorid = $rssid,
    eval {
	$activity = "Update Commitment";
	my $csr = $dbh->prepare($commitmentupdatesql);
	$csr->bind_param(":textclob", $text, {ora_type => ORA_CLOB, ora_field => 'text' });
	$csr->bind_param(":estimateclob", $estimate, {ora_type => ORA_CLOB, ora_field => 'estimate' });
	$csr->bind_param(":actionplanclob", $actionplan, {ora_type => ORA_CLOB, ora_field => 'actionplan' });
	$csr->execute;
	
=pod
	$activity = "Enter actual BSC Lead in table COMMITMENTROLE";
	my $oldmodl = "delete from $SCHEMA.commitmentrole 
                           where commitmentid = $commitmentid and roleid = 2";
	$csr = $dbh -> prepare ($oldmodl);
	$csr -> execute ();
	my $realmodl = "insert into $SCHEMA.commitmentrole (commitmentid, 
                                    roleid, usersid)
                            values ($commitmentid, 2, $usersid)";
	$csr = $dbh -> prepare ($realmodl);
	$csr -> execute;
=cut
	
	# update commitment remarks
	if ($comments) {
	    my $remarkupdate = "insert into $SCHEMA.commitment_remarks (usersid, text, dateentered, commitmentid) values ($usersid, :remarks, SYSDATE, $commitmentid)";
	    $activity = "Update remarks for commitment $commitmentid";
	    $csr = $dbh -> prepare ($remarkupdate);
	    $csr -> bind_param (":remarks", $comments, {ora_type => ORA_CLOB, ora_field => 'text'});
	    $csr -> execute;
	}	
	
	#add keywords to record(s)
	my $oldkeywords = "delete from $SCHEMA.commitmentkeyword where commitmentid=$commitmentid";
	my $oldcsr = $dbh -> prepare ($oldkeywords);
	$oldcsr -> execute;
	my $keywordid;
	foreach $keywordid ($cmscgi->param('keywords')) {
	    if (($keywordid ne '')) {
		$activity = "Insert keyword: $keywordid for commitment: $commitmentid.";
		my $keywordsqlstring = "INSERT INTO $SCHEMA.commitmentkeyword (commitmentid, keywordid) VALUES($commitmentid, $keywordid)";
		$csr = $dbh->prepare($keywordsqlstring);
		$csr->execute;
	    }
	}
	$csr->finish;
	$dbh->commit;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'commitment', "$commitmentid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print <<pageerror;
	<script language="JavaScript" type="text/javascript">
	<!--
        alert("$alertstring");
        //-->
        </script>
pageerror
    }
    else {
	&log_activity($dbh, 'F', $usersid, "Commitment ".formatID2($commitmentid, 'C')." updated and passed on to DOE Discipline Lead for determination");
	my $doedls = $dbh -> prepare ("select distinct usersid from $SCHEMA.defaultdisciplinerole where disciplineid = $primarydiscipline and roleid = 3 and siteid = $siteid");
	$doedls -> execute;
	while (my ($doedlid) = $doedls -> fetchrow_array) {
	    my $notification = &notifyUser(dbh => $dbh, schema => $SCHEMA, userID => $doedlid);
	}	
	print <<pageresults;
	<script language="JavaScript" type="text/javascript">
	<!--
	parent.workspace.location="$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
    }
    &oncs_disconnect($dbh);
    print "</head><body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0></body></html>\n";
    exit 1;
}  #################  endif pass_on  ##########################
