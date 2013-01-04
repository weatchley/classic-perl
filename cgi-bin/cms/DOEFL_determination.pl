#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# CMS DOE Discipline Lead determination screen
#
# $Source: /data/dev/rcs/cms/perl/RCS/DOEFL_determination.pl,v $
# $Revision: 1.45 $
# $Date: 2001/11/15 22:57:26 $
# $Author: naydenoa $
# $Locker:  $
# $Log: DOEFL_determination.pl,v $
# Revision 1.45  2001/11/15 22:57:26  naydenoa
# Added action display to commitment info.
#
# Revision 1.44  2001/05/04 22:22:32  naydenoa
# Update evals
#
# Revision 1.43  2001/05/02 22:15:10  naydenoa
# Modified evals, calls to Edit_Screens
#
# Revision 1.42  2001/01/02 17:27:20  naydenoa
# More code clean-up
#
# Revision 1.41  2000/12/19 18:55:05  naydenoa
# Code cleanup
#
# Revision 1.40  2000/12/07 18:56:07  naydenoa
# Updated entry to commitmentrole table to reflect the actual
# lead who performed work on the commitment
#
# Revision 1.39  2000/11/20 19:39:32  naydenoa
# Moved some redundant code to Edit_Screens module
#
# Revision 1.38  2000/11/07 23:23:57  naydenoa
# Added email notification
# Added issue source display
# Took out rationales
#
# Revision 1.37  2000/10/26 18:30:33  naydenoa
# Added commitment remark display
# Changed table width to 650, textarea width to 75
#
# Revision 1.36  2000/10/24 19:16:43  naydenoa
# Updated call to Edit_Screens, added keywords
#
# Revision 1.35  2000/10/18 21:00:31  munroeb
# fixed activity log error message
#
# Revision 1.34  2000/10/17 17:03:25  naydenoa
# Took out log_history call, checkpoint.
#
# Revision 1.33  2000/10/06 20:27:06  munroeb
# added log_activity feature to script
#
# Revision 1.32  2000/10/06 19:16:02  naydenoa
# Took out Date Due to Commitment Maker (now assigned by
# the Commitment Coordinator)
#
# Revision 1.31  2000/10/03 20:41:12  naydenoa
# Updates status id's and references.
#
# Revision 1.30  2000/09/29 19:25:01  naydenoa
# Changed references to statuses and roles -- now referenced by ID
#
# Revision 1.29  2000/09/28 22:13:25  atchleyb
# added names to insert
#
# Revision 1.28  2000/09/28 20:06:01  naydenoa
# Checkpoint after Version 2 release
#
# Revision 1.27  2000/09/11 22:40:51  naydenoa
#  Changed links to point to new home.
#
# Revision 1.26  2000/09/08 23:46:59  naydenoa
# More interface modifications.
#
# Revision 1.25  2000/09/05 18:47:38  naydenoa
# Interface update
#
# Revision 1.24  2000/09/01 23:53:42  naydenoa
# Major interface rewrite. Added use of module Edit_Screens (takes
# care of most text and other fields for the screen.
#
# Revision 1.23  2000/08/25 17:38:27  atchleyb
# made requested text changes
#
# Revision 1.22  2000/08/25 16:25:14  atchleyb
# changed Technical Lead to Discipline Lead
#
# Revision 1.21  2000/08/21 20:58:52  atchleyb
# fixed var name bug
#
# Revision 1.20  2000/08/21 20:23:02  atchleyb
# fixed var name bug
#
# Revision 1.19  2000/08/21 18:20:40  atchleyb
# added check schema line
# changed cirscgi to cmscgi
#
# Revision 1.18  2000/07/24 15:06:12  johnsonc
# Inserted GIF file for display.
#
# Revision 1.17  2000/07/17 17:24:42  atchleyb
# placed forms in a table of width 750
#
# Revision 1.16  2000/07/11 14:46:29  munroeb
# finished modifying html formatting
#
# Revision 1.15  2000/07/06 23:22:12  munroeb
# finished making mods to html and javascripts
#
# Revision 1.14  2000/07/05 22:37:59  munroeb
# made minor changes to html and javascripts
#
# Revision 1.13  2000/06/21 20:48:52  johnsonc
# Editted opening page select object to support double click event.
#
# Revision 1.12  2000/06/15 22:55:40  johnsonc
# Revise WSB table entry to be optional display in edit and query screens
#
# Revision 1.11  2000/06/14 18:37:31  zepedaj
# Changed Functional To Technical per DOE request
#
# Revision 1.10  2000/06/13 21:41:16  zepedaj
# Fixed width of tables so the columns would be the same
#
# Revision 1.9  2000/06/13 19:25:38  johnsonc
# Change 'Rationale For Commitment' field to display only when data is present
#
# Revision 1.8  2000/06/13 15:28:09  johnsonc
# Editted commitments select object to a fixed width.
#
# Revision 1.7  2000/06/12 15:45:17  johnsonc
# Add 'C' in front of commitment ID and 'I' in front of issue ID.
# Add 'proposed' to edit and view commitment page titles.
#
# Revision 1.6  2000/06/09 20:16:15  johnsonc
# Edit secondary discipline text area to display only when it contains data
#
# Revision 1.5  2000/06/08 18:38:32  johnsonc
# Install commitment comment text box.
#
# Revision 1.4  2000/05/19 23:44:18  zepedaj
# Changed code for the final WBS structure
#
# Revision 1.3  2000/05/18 23:11:02  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.2  2000/05/05 16:58:42  zepedaj
# functional testing completed
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

my $pagetitle = "DOE Discipline Lead Determination";
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

# find the Role ID and Status ID for the DOE Discipline Lead Review
my $DOEFL_Roleid = 3; # DOE Discipline Lead
my $DOEFL_determination_statusid = 3; # DOE Discipline Lead Review

#####################################
if ($cgiaction eq "editcommitment") {
#####################################
    my $commitmentid = $cmscgi->param('commitmentid');
    my $textareawidth = 75;
    my $activity;
    my %commitmenthash;
    
    # commitment variables
    my $commitmentidstring = substr("0000$commitmentid", -5);
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
    
    # the following commitment variables may not be available
    my $actionsummary = $commitmenthash{'actionsummary'};
    my $functionalrecommend = $commitmenthash{'functionalrecommend'};
    
    #booleans
    my $commitmenthasactionsummary = (defined($actionsummary) && ($actionsummary ne ""));
    my $commitmenthasfunctionalrecommend = (defined($functionalrecommend) && ($functionalrecommend ne ""));
    my $key;
    
    $dbh->{LongTruncOk} = 0;
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "function validate_commitment_data() {\n";
    print "    var msg = \"\";\n";
    print "    var tmpmsg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.editcommitment;\n\n";
    print "msg += (validateform.text.value==\"\") ? \"You must enter the potential commitment text.\\n\" : \"\";\n";
    print "msg += (validateform.actionsummary.value==\"\") ? \"You must enter the action summary.\\n\" : \"\";\n";
    print "msg += (validateform.functionalrecommend.value==\"\") ? \"You must enter your recommendation.\\n\" : \"\";\n";
    print "    if (msg != \"\") {\n";
    print "        alert(msg);\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "}\n";
    print "function save_commitment() {\n";
    print "    var tempcgiaction;\n";
    print "    var msg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.editcommitment;\n\n";
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
    print "    var returnvalue = true;\n\n";
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
    print "<table border=0 align=center width=650><tr><td>\n<CENTER>\n";
    print "<form name=editcommitment method=post target=\"control\" action=\"$ONCSCGIDir/DOEFL_determination.pl\">\n";
    print "<input name=cgiaction type=hidden value=\"save_commitment\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=commitmentid type=hidden value=$commitmentid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    print "<P><table width=650 align=center cellspacing=10>\n";
    eval {
	$activity = "Do past work tables for commitment $commitmentid";
	print &doIssueTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
	print doIssueSourceTable (cid => $commitmentid, imagepath => $CMSImagePath, dbh => $dbh, schema => $SCHEMA);
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
	print doProcessingTable (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid);
	print "<tr><td><hr width=50%></td></tr>\n";

	$activity = "Do fields for commitment $commitmentid";
	print &writeCommitmentText (text => $text, active =>1);
	print &writeActionSummary (actionsummary => $actionsummary, active => 1);
	print &writeDLRecommend (dlrecommend => $functionalrecommend, active => 1);
	print selectProducts (cid => $commitmentid, dbh => $dbh);
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
    print "</table>\n";
    print "<input type=button name=savecommitment value=\"Save Draft Work\" title=\"Save Draft Work, can be edited later\" onclick=\"return(save_commitment())\">\n";
    print "<input type=button name=saveandcomplete value=\"Save and Pass On\" title=\"Save Commitment and pass it on to the DOE Commitment Manager\" onclick=\"return(pass_on())\">\n";
    print "</form> \n</td></tr></table> \n<br><br><br>\n";
    print "</body> \n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
}  ####  endif editcommitment  ####


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
    my $actionsummary = $cmscgi->param('actionsummary');
    my $actionsummarysql = ($actionsummary) ? ":actionsummaryclob" : "NULL";
    my $functionalrecommend = $cmscgi->param('functionalrecommend');
    my $functionalrecommendsql = ($functionalrecommend) ? ":functionalrecommendclob" : "NULL";
    my $comments = $cmscgi->param('commenttext');
    
    #sql strings
    my $commitmentupdatesql = "UPDATE $SCHEMA.commitment SET text = $textsql, actionsummary = $actionsummarysql, functionalrecommend = $functionalrecommendsql, updatedby = $usersid WHERE commitmentid = $commitmentid";
    eval {
	$activity = "Update Commitment";
	my $csr = $dbh->prepare($commitmentupdatesql);
	$csr->bind_param(":textclob", $text, {ora_type => ORA_CLOB, ora_field => 'text' });
	if ($actionsummary) {
	    $csr->bind_param(":actionsummaryclob", $actionsummary, {ora_type => ORA_CLOB, ora_field => 'actionsummary' });
	}
	if ($functionalrecommend) {
	    $csr->bind_param(":functionalrecommendclob", $functionalrecommend, {ora_type => ORA_CLOB, ora_field => 'functionalrecommend' });
	}
	$csr->execute;
	
	my $productid;
	# we have written the commitment to the database, now we must write the products affected table
	my $dualhistory = $cmscgi->param('prodhist');
	$dualhistory =~ s/\s+//;
	while (my $histitem = substr($dualhistory, 0, index($dualhistory, ';'))) {
	    my $productsqlstring;
	    $dualhistory = substr($dualhistory, (index($dualhistory, ';') + 1));
	    $activity = "Update products for commitment: $commitmentid";
	    if ($histitem =~ /productsaffected/i) {
		$activity .= " adding product: " . substr($histitem, 0, index($histitem, '-->')) . ".";
		$productsqlstring = "INSERT INTO $SCHEMA.productaffected (productid,commitmentid) VALUES (" . substr($histitem, 0, index($histitem, '-->')) . ", $commitmentid)";
	    }
	    else {
		$activity .= " removing product: " . substr($histitem, 0, index($histitem, '-->')) . ".";
		$productsqlstring = "DELETE $SCHEMA.productaffected WHERE (commitmentid = $commitmentid) AND (productid = " . substr($histitem, 0, index($histitem, '-->')) . ")";
	    }
	    $csr = $dbh->prepare($productsqlstring);
	    $csr->execute;
	}
	
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
	&log_activity($dbh, 'F', $usersid, "Commitment ".&formatID2($commitmentid, 'C')." updated by the DOE Lead");
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
}  ##################  endif save_commitment  ##################

##############################
if ($cgiaction eq "pass_on") { #### pass to next user (DOE Commitment Manager)
##############################
    no strict 'refs';
    
    #control variables
    my $commitmentid =  $cmscgi->param('commitmentid');
    my $activity;
    my $nextstatusid = 4;
    
    # Find pertinent user info; Site id of user is same for commitment
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);
    
    # commitment variables
    my $text = $cmscgi->param('text');
    my $textsql = ($text) ? ":textclob" : "NULL";
    my $actionsummary = $cmscgi->param('actionsummary');
    my $actionsummarysql = ($actionsummary) ? ":actionsummaryclob" : "NULL";
    my $functionalrecommend = $cmscgi->param('functionalrecommend');
    my $functionalrecommendsql = ($functionalrecommend) ? ":functionalrecommendclob" : "NULL";
    my $comments = $cmscgi->param('commenttext');
    
    #role variables
    my $DOECMgr_roleid = 4;
    my $DOECMgr_usersid;
    ($DOECMgr_usersid) = lookup_column_values($dbh, 'defaultsiterole', 'usersid', "roleid = $DOECMgr_roleid AND siteid = $siteid");
    
    #sql strings
    my $commitmentupdatesql = "UPDATE $SCHEMA.commitment SET text = $textsql, actionsummary = $actionsummarysql, functionalrecommend = $functionalrecommendsql, statusid = $nextstatusid, updatedby = $usersid WHERE commitmentid = $commitmentid";
    eval {
	$activity = "Update Commitment";
	my $csr = $dbh->prepare($commitmentupdatesql);
	$csr->bind_param(":textclob", $text, {ora_type => ORA_CLOB, ora_field => 'text' });
	$csr->bind_param(":actionsummaryclob", $actionsummary, {ora_type => ORA_CLOB, ora_field => 'actionsummary' });
	$csr->bind_param(":functionalrecommendclob", $functionalrecommend, {ora_type => ORA_CLOB, ora_field => 'functionalrecommend' });
	#print "$commitmentupdatesql <br>\n";
	$csr->execute;
	
	# update product affected information
	my $dualhistory = $cmscgi->param('prodhist');
	$dualhistory =~ s/\s+//;
	while (my $histitem = substr($dualhistory, 0, index($dualhistory, ';'))) {
	    my $productsqlstring;
	    $dualhistory = substr($dualhistory, (index($dualhistory, ';') + 1));
	    $activity = "Update products for commitment: $commitmentid";
	    if ($histitem =~ /productsaffected/i) {
		$activity .= " adding product: " . substr($histitem, 0, index($histitem, '-->')) . ".";
		$productsqlstring = "INSERT INTO $SCHEMA.productaffected (productid,commitmentid) VALUES (" . substr($histitem, 0, index($histitem, '-->')) . ", $commitmentid)";
	    }
	    else {
		$activity .= " removing product: " . substr($histitem, 0, index($histitem, '-->')) . ".";
		$productsqlstring = "DELETE $SCHEMA.productaffected WHERE (commitmentid = $commitmentid) AND (productid = " . substr($histitem, 0, index($histitem, '-->')) . ")";
	    }
	    $csr = $dbh->prepare($productsqlstring);
	    $csr->execute;
	}
	
	$activity = "Store Actual DOE Lead";
	#delete any old roles
	my $commitmentroledelsql = "DELETE FROM $SCHEMA.commitmentrole WHERE commitmentid = $commitmentid AND roleid = 3";
	$csr = $dbh->prepare($commitmentroledelsql);
	$csr->execute;
	
	#add new role
	my $commitmentrolesqlstring = "INSERT INTO $SCHEMA.commitmentrole (commitmentid, roleid, usersid) VALUES ($commitmentid, 3, $usersid)";
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
	print "parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username\";\n";
	print "//-->\n";
	print "</script>\n";
    }
    else {
	&log_activity($dbh, 'F', $usersid, "Commitment ".&formatID2($commitmentid, 'C')." updated and passed on to the Commitment Manager");
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
}   ####  endif pass_on  ####
