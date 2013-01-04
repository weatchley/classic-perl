#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# CMS Commitment Maker decision screen.
#
# $Source: /data/dev/rcs/cms/perl/RCS/CMaker_decision.pl,v $
# $Revision: 1.49 $
# $Date: 2003/11/21 21:29:51 $
# $Author: naydenoa $
# $Locker:  $
# $Log: CMaker_decision.pl,v $
# Revision 1.49  2003/11/21 21:29:51  naydenoa
# Removed CIRS interface code - CIRS is retired.
#
# Revision 1.48  2002/09/25 19:37:32  naydenoa
# Cleaned up CIRS code - uses CIRS_procs module
#
# Revision 1.47  2002/08/27 15:20:12  naydenoa
# Added string formatting for clevel, discipline, status for CIRS
#
# Revision 1.46  2002/08/24 00:57:31  naydenoa
# CIRS interface processing added - preliminary.
#
# Revision 1.45  2001/11/15 19:24:45  naydenoa
# Added actions to commitment info display.
#
# Revision 1.44  2001/05/04 23:46:31  naydenoa
# Updated evals
#
# Revision 1.43  2001/05/02 22:17:31  naydenoa
# Modified evals, calls to Edit_Screens
#
# Revision 1.42  2001/01/02 17:20:18  naydenoa
# More code clean-up
#
# Revision 1.41  2000/12/19 17:47:10  naydenoa
# Code cleanup
#
# Revision 1.40  2000/11/07 23:16:21  naydenoa
# Added mail notofication, added issue source display, took
# out rationales
#
# Revision 1.39  2000/10/31 19:39:32  naydenoa
# Took out stray due date
# Updated function calls to Edit_Screens
# Got rid of approval rationale (kept rejection rat mandatory)
#
# Revision 1.38  2000/10/26 19:17:27  naydenoa
# Added remark display
# Changed table width to 650, textarea width to 75
#
# Revision 1.37  2000/10/24 19:25:59  naydenoa
# Updated call to Edit_Screens
#
# Revision 1.36  2000/10/17 23:45:59  munroeb
# modifed log message
#
# Revision 1.35  2000/10/17 15:48:53  munroeb
# removed log_history perm
# ,
#
# Revision 1.34  2000/10/16 16:48:19  munroeb
# removed log_history functionality
#
# Revision 1.33  2000/10/06 16:52:24  munroeb
# added log_activity feature to script
#
# Revision 1.32  2000/10/03 20:38:38  naydenoa
# Updates status id's and references.
#
# Revision 1.31  2000/09/29 19:38:25  naydenoa
# Changed references to roles and statuses (now by ID)
#
# Revision 1.30  2000/09/29 16:10:29  atchleyb
# fixed javascript validation for netscape
#
# Revision 1.29  2000/09/28 20:08:58  naydenoa
# Checkpoint after Version 2 release
#
# Revision 1.28  2000/09/11 22:38:00  naydenoa
# Changed links to point to new home.
#
# Revision 1.27  2000/09/08 23:48:29  naydenoa
# More interface modifications.
#
# Revision 1.26  2000/09/05 18:45:17  naydenoa
# More interface revisions, more functions through Edit_Screens
#
# Revision 1.25  2000/09/02 00:00:07  naydenoa
# Major interface rewrite. Added use of module Edit_Screens.
#
# Revision 1.24  2000/08/25 18:52:02  atchleyb
# made requested text changes
#
# Revision 1.23  2000/08/21 22:17:37  atchleyb
# fixed var name bug
#
# Revision 1.22  2000/08/21 17:45:35  atchleyb
# added check schema line
#
# Revision 1.21  2000/07/24 15:01:54  johnsonc
# Inserted GIF file for display.
#
# Revision 1.20  2000/07/17 16:53:04  atchleyb
# placed forms in a table of width 750
#
# Revision 1.19  2000/07/11 14:52:38  munroeb
# finished modifying html formatting
#
# Revision 1.18  2000/07/06 23:18:41  munroeb
# finished mods to html and javascripts.
#
# Revision 1.17  2000/07/05 21:52:51  munroeb
# made minor tweaks to javascripts and html
#
# Revision 1.16  2000/06/21 20:47:39  johnsonc
# Editted opening page select object to support double click event.
#
# Revision 1.15  2000/06/15 22:54:23  johnsonc
# Revise WSB table entry to be optional display in edit and query screens
#
# Revision 1.14  2000/06/15 17:18:25  zepedaj
# Made the rationale for commitment optional for approved commitments
# and required for rejected commitments
#
# Revision 1.13  2000/06/14 18:37:19  zepedaj
# Changed Functional To Technical per DOE request
#
# Revision 1.12  2000/06/13 21:40:23  zepedaj
# Fixed width of tables so the columns would be the same
#
# Revision 1.11  2000/06/13 19:22:29  johnsonc
#  Change 'Rationale For Commitment' field to display only when data is present
#
# Revision 1.10  2000/06/13 15:24:38  johnsonc
# Editted commitments select object to a fixed width.
#
# Revision 1.9  2000/06/12 15:39:54  johnsonc
# Add 'C' in front of commitment ID and 'I' in front of issue ID.
# Add 'proposed' to edit and view commitment page titles.
#
# Revision 1.8  2000/06/09 20:10:22  johnsonc
# Edit secondary discipline text area to display only when it contains data
#
# Revision 1.7  2000/05/19 23:43:54  zepedaj
# Changed code for the final WBS structure
#
# Revision 1.6  2000/05/18 23:04:59  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.5  2000/05/15 22:02:13  zepedaj
# Replaced popup text on pass-on button to reflect the current status of the commitment.
#
# Revision 1.4  2000/05/11 20:57:51  zepedaj
# Added insertion of the commit date in the pass_on section
#
# Revision 1.3  2000/05/08 21:59:12  zepedaj
# Added prompt to clarify the use of the commitment text field.
#
# Revision 1.2  2000/05/05 17:57:23  zepedaj
# functional test finished - passed
#
# Revision 1.1  2000/05/03 21:39:34  zepedaj
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

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

# print content type header
print $cmscgi->header('text/html');

my $pagetitle = "Commitment Maker Determination";
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

print "<html>\n";
print "<head>\n";
print "<meta name=pragma content=no-cache>\n";
print "<meta name=expires content=0>\n";
print "<meta http-equiv=expires content=0>\n";
print "<meta http-equiv=pragma content=no-cache>\n";
print "<title>$pagetitle</title>\n";

print "<!-- include external javascript code -->\n";
print "<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>\n";
print "<script type=\"text/javascript\">\n";
print "<!--\n";
print "var dosubmit = true;\n";
print "if (parent == self) { // not in frames\n";
print "    location = \'$ONCSCGIDir/login.pl\'\n";
print "}\n";
print "doSetTextImageLabel(\'Decision on Commitment\');\n";
print "//-->\n";
print "</script>\n";

my $dbh = oncs_connect();
# find the Role ID and Status ID for the Commitment Maker Review
my $CMaker_Roleid = 5; # Commitment Maker
my $CMaker_decision_statusid = 5; # Commitment Maker Decision

#####################################
if ($cgiaction eq "editcommitment") {
#####################################
    my $activity;
    my $commitmentid = $cmscgi->param('commitmentid');
    my $textareawidth = 75;
    my $commitmentidstring = substr("0000$commitmentid", -5);
    my %commitmenthash;
    
    eval {
	$activity = "Get info for commitment $commitmentid";
	%commitmenthash = get_commitment_info($dbh, $commitmentid);
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
    my $approvedby = $commitmenthash{'approver'};
    
    # the following commitment variables may not be available
    my $rejectionrationale = $commitmenthash{'rejectionrationale'};
    my $commitmentisnotapproved = (defined($rejectionrationale) && ($rejectionrationale ne ""));
    
    my $rationale;
    my $approvedcheckedstring;
    my $rejectedcheckedstring;
    if ($commitmentisnotapproved) {
	$rationale = $rejectionrationale;
	$approvedcheckedstring = "";
	$rejectedcheckedstring = "checked";
    }
    else {
	$approvedcheckedstring = "checked";
	$rejectedcheckedstring = "";
    }
    my $key;
    
    $dbh->{LongTruncOk} = 0;
    
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "function validate_commitment_data() {\n";
    print "    var msg = \"\";\n";
    print "    var tmpmsg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.editcommitment;\n";
    print "    msg += (validateform.text.value==\"\") ? \"You must enter the potential commitment text.\\n\" : \"\";\n";
    print "    msg += ((validateform.rationale.value==\"\") && (validateform.commitmentapproved[1].checked)) ? \"You must enter your rationale for rejecting this commitment.\\n\" : \"\";\n";
    print "    if (msg != \"\") {\n";
    print "        alert(msg);\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "}\n";
    print "function save_commitment() {\n";
    print "    var tempcgiaction;\n";
    print "var msg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.editcommitment;\n";
    print "    msg += (validateform.text.value==\"\") ? \"You must enter the potential commitment text.\\n\" : \"\";\n";
    print "    if (msg != \"\") {\n";
    print "        alert(msg);\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    if (returnvalue) {\n";
    print "        document.editcommitment.submit();\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "}\n";
    print "function pass_on() {\n";
    print "    var tempcgiaction;\n";
    print "    var returnvalue = true;\n";
    print "    if (validate_commitment_data()) {\n";
    print "        tempcgiaction = document.editcommitment.cgiaction.value;\n";
    print "        document.editcommitment.cgiaction.value = \"pass_on\";\n";
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
    print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<table border=0 align=center width=650><tr><td>\n";
    print "<form name=editcommitment method=post target=\"control\" action=\"$ONCSCGIDir/CMaker_decision.pl\">\n";
    print "<input name=cgiaction type=hidden value=\"save_commitment\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=commitmentid type=hidden value=$commitmentid>\n";
    print "<input type=hidden name=schema value=$SCHEMA> \n<br>\n";
    
    print "<table summary=\"Enter Commitment Table\" width=650 border=0 align=center cellspacing=10>\n";
    my $outstring;
    eval {
	$activity = "Draw tables for commitment $commitmentid";
	print &doIssueTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
	print &doIssueSourceTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
	print &doHeadTable (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid, cidstring => $commitmentidstring);
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
	print &doProcessingTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
	print "<tr><td><hr width=50%></td></tr>\n";

	$activity = "Do fields for commitment $commitmentid";
	print &writeCommitmentText (text => $text, active => 1, decision => 1);
	print "<tr><td align=left><b><li>Commitment Approval / Rejection</b>\n";
	print "<ul><input type=radio name=commitmentapproved value=-1 $approvedcheckedstring>Make Commitment<br>\n";
	print "<input type=radio name=commitmentapproved value=0 $rejectedcheckedstring>Reject Commitment</ul></td></tr>\n";
	print "<tr><td align=left><b><li>Commitment Rejection Rationale:</b> &nbsp; &nbsp; (If commitment is rejected, you must enter rationale.)\n";
	print "<textarea name=rationale cols=$textareawidth rows=5>$rationale</textarea></td></tr>\n";
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
    print "</table> \n<center>\n";
    print "<input type=button name=savecommitment value=\"Save Draft Work\" title=\"Save Draft Work, can be edited later.\" onclick=\"return(save_commitment())\">\n";
    print "<input type=button name=saveandcomplete value=\"Save and Pass On\" title=\"Save Commitment and pass it on for fulfillment.\" onclick=\"return(pass_on())\">\n";
    print "</center> \n</form> \n</td></tr></table> \n<br><br><br>\n";
    print "</body> \n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
}  ####  endif editcommitment  ####

######################################
if ($cgiaction eq "save_commitment") {  
######################################
    no strict 'refs';
    
    #control variables
    my $commitmentid = $cmscgi->param('commitmentid');
    my $activity;
    
    # boolean variables, should be 0 or -1 (true/false)
    my $commitmentapproved = $cmscgi->param('commitmentapproved');
    
    # commitment variables
    my $text = $cmscgi->param('text');
    my $textsql = ($text) ? ":textclob" : "NULL";
    my $rationale = $cmscgi->param('rationale');
    my $rationalesql = ($rationale) ? ":rationaleclob" : "NULL";
    my $comments = $cmscgi->param('commenttext');
    
    my $commitmentupdatesql = "UPDATE $SCHEMA.commitment
                               SET text = $textsql,
                                   rejectionrationale = $rationalesql,
                                   updatedby = $usersid
                               WHERE commitmentid = $commitmentid";
    eval {
	$activity = "Update Commitment";
	my $csr = $dbh->prepare($commitmentupdatesql);
	$csr->bind_param(":textclob", $text, {ora_type => ORA_CLOB, ora_field => 'text' });
	if ($rationale) {
	    $csr->bind_param(":rationaleclob", $rationale, {ora_type => ORA_CLOB, ora_field => "rejectionrationale" });
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
	$csr->finish;
	$dbh->commit;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'commitment', "$commitmentid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
	print "alert(\"$alertstring\");\n";
	print "parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	print "//-->\n";
	print "</script>\n";
    }
    else {
	&log_activity($dbh, 'F', $usersid, "Commitment ".formatID2($commitmentid, 'C')." updated by the Commitment Maker");
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
}  ####  endif save_commitment  ####

##############################
if ($cgiaction eq "pass_on") {
##############################
    no strict 'refs';
    
    #control variables
    my $commitmentid =  $cmscgi->param('commitmentid');
    my $activity;
    
    # boolean variables, should be 0 or -1 (true/false)
    my $commitmentapproved = $cmscgi->param('commitmentapproved');
    
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);
    
    # commitment variables
    my $text = $cmscgi->param('text');
    my $textsql = ($text) ? ":textclob" : "NULL";
    my $rationale = $cmscgi->param('rationale');
    my $rationalesql = ($rationale) ? ":rationaleclob" : "NULL";
    my $comments = $cmscgi->param('commenttext');
    
    # status variable depends on choice
    my $nextstatusid;
    if ($commitmentapproved) {
	$nextstatusid = 6; # Approval Letter
    }
    else {
	$nextstatusid = 7; # Rejection Letter
    }

    # sql strings
    my $commitmentupdatesql = "UPDATE $SCHEMA.commitment
                               SET text = $textsql,
                                   rejectionrationale = $rationalesql,
                                   commitdate = SYSDATE,
                                   statusid = $nextstatusid,
                                   updatedby = $usersid
                               WHERE commitmentid = $commitmentid";
    eval {
	$activity = "Update Commitment";
	my $csr = $dbh->prepare($commitmentupdatesql);
	$csr->bind_param(":textclob", $text, {ora_type => ORA_CLOB, ora_field => 'text' });
	if ($rationale) {
	    $csr->bind_param(":rationaleclob", $rationale, {ora_type => ORA_CLOB, ora_field => "rejectionrationale" });
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
	$csr->finish;
	$dbh->commit;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'commitment', "$commitmentid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
	print "alert(\"$alertstring\");\n";
	print "parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	print "//-->\n";
	print "</script>\n";
    }
    else {
	my $logmessage = ($commitmentapproved) ? "Commitment ".formatID2($commitmentid, 'C')." updated and approved" : "Commitment ".formatID2($commitmentid, 'C')." updated and rejected";
	my $logtitle = ($commitmentapproved) ? "Commitment Approved" : "Commitment Rejected";
	&log_activity($dbh, 'F', $usersid, $logmessage);
	my $cmgrs = $dbh -> prepare ("select distinct usersid from $SCHEMA.defaultsiterole where roleid = 4 and siteid = $siteid");
	$cmgrs -> execute;
	while (my ($cmgrid) = $cmgrs -> fetchrow_array) {
	    my $notification = &notifyUser(dbh => $dbh, schema => $SCHEMA, userID => $cmgrid);
	}	
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
} ####  endif pass_on  ####
