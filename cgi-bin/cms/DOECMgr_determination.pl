#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# CMS DOE Commitment Manager determination screen.
#
# $Source: /data/dev/rcs/cms/perl/RCS/DOECMgr_determination.pl,v $
# $Revision: 1.51 $
# $Date: 2001/11/15 21:18:27 $
# $Author: naydenoa $
# $Locker:  $
# $Log: DOECMgr_determination.pl,v $
# Revision 1.51  2001/11/15 21:18:27  naydenoa
# Added action display to commitment info.
# ,
#
# Revision 1.50  2001/05/11 21:42:51  naydenoa
# Removed outdated reference to privileges
#
# Revision 1.49  2001/05/04 22:45:31  naydenoa
# Update evals
#
# Revision 1.48  2001/05/02 22:16:44  naydenoa
# Modified evals, calls to Edit_Screens
#
# Revision 1.47  2001/01/02 17:24:48  naydenoa
# More code clean-up
#
# Revision 1.46  2000/12/19 18:53:23  naydenoa
# Code cleanup
#
# Revision 1.45  2000/12/07 18:52:38  naydenoa
# Updated entry to commitmentrole table to reflect the
# actual DOE lead who handled the commitment.
#
# Revision 1.44  2000/11/20 19:37:46  naydenoa
# Moved some redundant code to Edit_Screens module
#
# Revision 1.43  2000/11/07 23:18:57  naydenoa
# Added mail notification
# Added issue source display
# Took out rationales
#
# Revision 1.42  2000/10/26 18:56:12  naydenoa
# Added remarks display
# Changed table width to 650, textareawidth to 75
#
# Revision 1.41  2000/10/24 19:21:34  naydenoa
# Updated call to Edit_screens
#
# Revision 1.40  2000/10/18 20:58:08  munroeb
# fixed activity log message
#
# Revision 1.39  2000/10/18 18:10:28  munroeb
# modifed log_activity message
#
# Revision 1.38  2000/10/17 15:54:43  munroeb
# removed log_history
#
# Revision 1.37  2000/10/16 17:38:51  munroeb
# removed log_history feature
#
# Revision 1.35  2000/10/06 19:51:45  munroeb
# added log_history feature to script
#
# Revision 1.34  2000/10/06 19:12:47  naydenoa
# Moved Date Due to Commitment Maker to MOCC_review.pl
#
# Revision 1.33  2000/10/03 20:40:41  naydenoa
# Updates status id's and references.
#
# Revision 1.32  2000/09/29 19:30:08  naydenoa
# Updated picklists to include developers on development schema
# and exclude them on production schema; changed references
# to statuses and roles (by ID)
#
# Revision 1.31  2000/09/28 20:04:35  naydenoa
#  Checkpoint after Version 2 release
#
# Revision 1.30  2000/09/18 15:05:11  naydenoa
# More interface updates
#
# Revision 1.29  2000/09/11 22:39:20  naydenoa
# Changel links to point to new home.
#
# Revision 1.28  2000/09/08 23:50:40  naydenoa
# More interface modifications.
#
# Revision 1.27  2000/09/05 18:46:43  naydenoa
# More interface revision, text area read-only/writable corrections
#
# Revision 1.26  2000/09/01 23:58:57  naydenoa
# Major interface rewrite. Added use of module Edit_Screens (draws most
# details for commitment edit screens).
#
# Revision 1.25  2000/08/25 23:04:42  atchleyb
# fixed typo
#
# Revision 1.24  2000/08/25 18:38:09  atchleyb
# made requested text changes
#
# Revision 1.23  2000/08/25 16:17:34  atchleyb
# changed Technical Lead to Discipline Lead
#
# Revision 1.22  2000/08/21 22:11:27  atchleyb
# fixed var name bug
#
# Revision 1.21  2000/08/21 20:19:18  atchleyb
# fixed var name bug
#
# Revision 1.20  2000/08/21 18:17:15  atchleyb
# added check schema line
# change cirscgi to cmscgi
# /
#
# Revision 1.19  2000/07/24 15:03:50  johnsonc
# Inserted GIF file for display.
#
# Revision 1.18  2000/07/17 17:18:28  atchleyb
# placed forms in a table of width 750
#
# Revision 1.17  2000/07/11 14:49:13  munroeb
# finished modifying html formatting
#
# Revision 1.16  2000/07/06 23:21:09  munroeb
# finished making mods to javascript and html.
#
# Revision 1.15  2000/07/05 22:34:47  munroeb
# made minor tweaks to javascript and html
#
# Revision 1.14  2000/06/21 20:48:13  johnsonc
# Editted opening page select object to support double click event.
#
# Revision 1.13  2000/06/15 22:55:15  johnsonc
# Revise WSB table entry to be optional display in edit and query screens
#
# Revision 1.12  2000/06/14 18:36:47  zepedaj
# Changed Functional To Technical per DOE request
#
# Revision 1.11  2000/06/13 21:40:56  zepedaj
# Fixed width of tables so the columns would be the same
#
# Revision 1.10  2000/06/13 19:24:14  johnsonc
# Change 'Rationale For Commitment' field to display only when data is present
#
# Revision 1.9  2000/06/13 15:26:34  johnsonc
# Editted commitments select object to a fixed width.
#
# Revision 1.8  2000/06/12 15:42:45  johnsonc
# Add 'C' in front of commitment ID and 'I' in front of issue ID.
# Add 'proposed' to edit and view commitment page titles.
#
# Revision 1.7  2000/06/09 20:15:16  johnsonc
# Edit secondary discipline text area to display only when it contains data
#
# Revision 1.6  2000/06/08 18:37:30  johnsonc
# Install commitment comment text box.
#
# Revision 1.5  2000/06/02 23:38:25  johnsonc
# Insert comment text areas
#
# Revision 1.4  2000/05/19 23:44:39  zepedaj
# Changed code for the final WBS structure
#
# Revision 1.3  2000/05/18 23:10:35  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.2  2000/05/05 17:42:37  zepedaj
# functional testing completed - passed
#
# Revision 1.1  2000/05/03 21:38:56  zepedaj
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

my $pagetitle = "DOE Commitment Manager Determination";
my $cgiaction = $cmscgi->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = "issue";

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
    <script language="JavaScript" type="text/javascript">
    <!--
        doSetTextImageLabel('Commitment Recommendation');
    //-->
    </script>
testlabel1

my $dbh = oncs_connect();
# find the Role ID and Status ID for the DOE Commitment Manager Review
my $DOECMgr_Roleid = 4; # DOE Commitment Manager
my $DOECMgr_determination_statusid = 4; # DOE Commitment Manager Review

#####################################
if ($cgiaction eq "editcommitment") {
#####################################
    my $activity;
    my $commitmentid = $cmscgi->param('commitmentid');
    my $commitmentidstring = substr("0000$commitmentid", -5);
    my $textareawidth = 75;
    my $CMaker_roleid;
    my $CMaker_usersid;
    my %commitmenthash;
    my $text;
    my $siteid;
    my $cmrecommendation;
    my $approvedby;
    my %usershash;
    my %approvedbyhash;
    
    eval {
	$activity = "Get info for commitment $commitmentid";
	%commitmenthash = get_commitment_info($dbh, $commitmentid);
	$text = $commitmenthash{'text'};
	$siteid = $commitmenthash{'siteid'};
	$activity = "Role retrieval for commitment $commitmentid";
	#default commitment maker, if approver not available, use default 
	($CMaker_roleid) = lookup_column_values($dbh, 'role', 'roleid', "description = 'Commitment Maker'");
	($CMaker_usersid) = lookup_column_values($dbh, 'defaultsiterole', 'usersid', "roleid = $CMaker_roleid AND siteid = $siteid");
	
	# the following commitment variables may not be available
	$cmrecommendation = $commitmenthash{'cmrecommendation'};
	$approvedby = $commitmenthash{'approver'};
	$approvedby = ($approvedby) ? $approvedby : $CMaker_usersid;
	
	# text hashes
	$activity = "Building user hashes";
	%usershash = get_lookup_values($dbh, 'users', "lastname || ', ' || firstname || ';' || usersid", 'usersid');
	my $nodevelopers = '';
	if ($CMSProductionStatus) {
	    $nodevelopers = ' and srole.usersid < 1000';
	}
	%approvedbyhash = get_lookup_values ($dbh, "users, $SCHEMA.defaultsiterole srole", "users.lastname || ', ' || users.firstname || ';' || users.usersid", 'users.usersid', "srole.usersid=users.usersid and srole.roleid=5 and users.isactive='T' and srole.siteid=$siteid $nodevelopers");
    };
    if ($@) {
	my $logmessage = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$logmessage =~ s/\n/\\n/g;
	$logmessage =~ s/\'/\'\'/g;
	print "<script language=javascript><!--\n";
	print "   alert('$logmessage');\n";
	print "//--></script>\n";
    }
    my $key;
    
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "function validate_commitment_data() {\n";
    print "    var msg = \"\";\n";
    print "    var tmpmsg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.editcommitment;\n";
    print "    msg += (validateform.text.value==\"\") ? \"You must enter the potential commitment text.\\n\" : \"\";\n";
    print "    msg += (validateform.cmrecommendation.value==\"\") ? \"You must enter your recommendation for this commitment.\\n\" : \"\";\n";
    print "    msg += (validateform.approvedby.value==\"NULL\") ? \"You must select a commitment maker for this commitment.\\n\" : \"\";\n";
    print "    if (msg != \"\") {\n";
    print "        alert(msg);\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print"    return (returnvalue);\n";
    print "}\n";
    print "function save_commitment() {\n";
    print "    var tempcgiaction;\n";
    print "    var msg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.editcommitment;\n";
    print "    msg += (validateform.text.value==\"\") ? \"You must enter the potential commitment text.\\n\" : \"\";\n";
    print "    msg += (validateform.approvedby.value==\"NULL\") ? \"You must select a commitment maker for this commitment.\\n\" : \"\";\n";
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
    print "<form name=editcommitment method=post target=\"control\" action=\"$ONCSCGIDir/DOECMgr_determination.pl\">\n";
    print "<input name=cgiaction type=hidden value=\"save_commitment\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=commitmentid type=hidden value=$commitmentid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n\n";
    
    print "<table summary=\"Enter Commitment Table\" width=650 align=center border=0 cellspacing=10>\n";
    my $outstring;
    eval {
	$activity = "Draw prior work tables for commitment $commitmentid";
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
	print doProcessingTable(dbh => $dbh, schema => $SCHEMA, cid => $commitmentid); 
	print "<tr><td><hr width=70%></td></tr>\n";
	$activity = "Draw fields for commitment $commitmentid";
	print &writeCommitmentText (text => $text, active => 1);
	print &writeCMgrRecommend (recommend => $cmrecommendation, active => 1);
	print selectCMaker (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
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
    print "<input type=button name=savecommitment value=\"Save Draft Work\" title=\"Save Draft Work, can be edited later\" onclick=\"return(save_commitment())\">\n";
    print "<input type=button name=saveandcomplete value=\"Save and Pass On\" title=\"Save Commitment and pass it on to the Commitment Maker\" onclick=\"return(pass_on())\">\n";
    print "</center> \n</form> \n</td></tr></table> \n<br><br><br>\n";
    print "</body> \n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
} ##################  endif editcommitment  ######################

######################################
if ($cgiaction eq "save_commitment") {  #### save commitment
######################################
    no strict 'refs';
	
    #control variables
    my $commitmentid = $cmscgi->param('commitmentid');
    my $activity;
    
    # commitment variables
    my $text = $cmscgi->param('text');
    my $textsql = ($text) ? ":textclob" : "NULL";
    my $cmrecommendation = $cmscgi->param('cmrecommendation');
    my $cmrecommendationsql = ($cmrecommendation) ? ":cmrecommendationclob" : "NULL";
    my $approvedby = $cmscgi->param('approvedby');
    my $comments = $cmscgi->param('commenttext');
    
    #sql strings
    my $commitmentupdatesql = "UPDATE $SCHEMA.commitment SET text = $textsql, cmrecommendation = $cmrecommendationsql, approver = $approvedby, updatedby = $usersid WHERE commitmentid = $commitmentid";
    eval {
	$activity = "Update Commitment";
	my $csr = $dbh->prepare($commitmentupdatesql);
	$csr->bind_param(":textclob", $text, {ora_type => ORA_CLOB, ora_field => 'text' });
	if ($cmrecommendation) {
	    $csr->bind_param(":cmrecommendationclob", $cmrecommendation, {ora_type => ORA_CLOB, ora_field => 'cmrecommendation' });
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
	&log_activity($dbh, 'F', $usersid, "Commitment ".formatID2($commitmentid, 'C')." updated by the Commitment Manager");
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
}  #################  endif save_commitment  ########################

##############################
if ($cgiaction eq "pass_on") {  #### pass to next user (Commitment Maker)
##############################
    no strict 'refs';
    
    #control variables
    my $commitmentid =  $cmscgi->param('commitmentid');
    my $activity;
    my $nextstatusid = 5; # Commitment Maker Review
    
    # Find user info; site id of user is same for commitment
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);
    
    # commitment variables
    my $text = $cmscgi->param('text');
    my $textsql = ($text) ? ":textclob" : "NULL";
    my $cmrecommendation = $cmscgi->param('cmrecommendation');
    my $cmrecommendationsql = ($cmrecommendation) ? ":cmrecommendationclob" : "NULL";
    my $approvedby = $cmscgi->param('approvedby');
    my $comments = $cmscgi->param('commenttext');
    
    #role variables
    my $CMaker_roleid = 5; # Commitment Maker
    
    #sql strings
    my $commitmentupdatesql = "UPDATE $SCHEMA.commitment SET text = $textsql, cmrecommendation = $cmrecommendationsql, statusid = $nextstatusid, approver = $approvedby, updatedby = $usersid WHERE commitmentid = $commitmentid";
    
    # now execute the SQL strings
    eval {
	$activity = "Update Commitment";
	my $csr = $dbh->prepare($commitmentupdatesql);
	$csr->bind_param(":textclob", $text, {ora_type => ORA_CLOB, ora_field => 'text' });
	$csr->bind_param(":cmrecommendationclob", $cmrecommendation, {ora_type => ORA_CLOB, ora_field => 'cmrecommendation' });
	$csr->execute;
	
	$activity = "Insert actual CMgr into COMMITMENTROLE";
	my $oldcmgr = "delete from $SCHEMA.commitmentrole 
                           where commitmentid = $commitmentid and roleid = 4";
	$csr = $dbh -> prepare ($oldcmgr);
	$csr -> execute;
	my $realcmgr = "insert into $SCHEMA.commitmentrole
                               (commitmentid, roleid, usersid)
                        values ($commitmentid, 4, $usersid)";
	$csr = $dbh -> prepare ($realcmgr);
	$csr -> execute;
	
	$activity = "Set Commitment Roles for selected Commitment Maker";
	#delete any old roles
	my $commitmentroledelsql = "DELETE FROM $SCHEMA.commitmentrole WHERE commitmentid = $commitmentid AND roleid = $CMaker_roleid";
	$csr = $dbh->prepare($commitmentroledelsql);
	$csr->execute;
	
	#add new role
	my $commitmentrolesqlstring = "INSERT INTO $SCHEMA.commitmentrole (commitmentid, roleid, usersid) VALUES ($commitmentid, $CMaker_roleid, $approvedby)";
	$csr = $dbh->prepare($commitmentrolesqlstring);
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
	&log_activity($dbh, 'F', $usersid, "Commitment ".formatID2($commitmentid, 'C')." updated and passed on to the Commitment Maker for decision");
	my $notification = &notifyUser(dbh => $dbh, schema => $SCHEMA, userID => $approvedby);
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
}  ###################  endif pass_on  ##############
