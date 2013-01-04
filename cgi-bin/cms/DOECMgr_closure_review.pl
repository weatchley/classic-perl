#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# DOE Commitment Manager review of the suggested closure of the commitment.
#
# $Source: /data/dev/rcs/cms/perl/RCS/DOECMgr_closure_review.pl,v $
# $Revision: 1.41 $
# $Date: 2001/11/15 20:22:33 $
# $Author: naydenoa $
# $Locker:  $
# $Log: DOECMgr_closure_review.pl,v $
# Revision 1.41  2001/11/15 20:22:33  naydenoa
# Added action display to commitment info.
#
# Revision 1.40  2001/05/07 16:25:58  naydenoa
# Updated evals
#
# Revision 1.39  2001/05/02 22:34:48  naydenoa
# Modified evals, calls to Edit_Screens
#
# Revision 1.38  2001/01/02 17:23:44  naydenoa
# More code clean-up
#
# Revision 1.37  2000/12/19 17:52:13  naydenoa
# Code cleanup
#
# Revision 1.36  2000/11/07 23:19:58  naydenoa
# Added mail notification
# Added issue source display
# Took out rationales
#
# Revision 1.35  2000/10/31 16:59:33  naydenoa
# Added remarks dispay
# Changed table width to 650, textarea width to 75
#
# Revision 1.34  2000/10/24 19:52:27  naydenoa
# Updated call to Edit_Screens (commitment info table)
#
# Revision 1.33  2000/10/18 23:30:19  munroeb
# modified activity log message
#
# Revision 1.32  2000/10/18 23:27:02  munroeb
# fixed activity log message
#
# Revision 1.31  2000/10/18 20:24:38  munroeb
# formatted activity log message
#
# Revision 1.30  2000/10/17 15:53:27  munroeb
# removed log_history perm
#
# Revision 1.29  2000/10/16 17:10:46  munroeb
# removed log_history functionality
#
# Revision 1.28  2000/10/06 17:08:39  munroeb
# added log_activity feature to script
#
# Revision 1.27  2000/10/03 20:40:23  naydenoa
# Updates status id's and references.
#
# Revision 1.26  2000/09/29 21:24:11  naydenoa
# Changed references to statuses and roles (now by ID)
#
# Revision 1.25  2000/09/28 20:04:02  naydenoa
# Checkpoint after Version 2 release
#
# Revision 1.24  2000/09/18 15:04:40  naydenoa
# More interface updates
#
# Revision 1.23  2000/09/08 23:49:47  naydenoa
# More interface modifications.
#
# Revision 1.22  2000/08/25 16:14:37  atchleyb
# changed Technical Lead to Discipline Lead
#
# Revision 1.21  2000/08/21 22:30:55  atchleyb
# fixed var name bug
#
# Revision 1.20  2000/08/21 20:17:13  atchleyb
# fixed var name bug
#
# Revision 1.19  2000/08/21 18:15:28  atchleyb
# added check schema line
#
# Revision 1.18  2000/07/24 14:59:55  johnsonc
# Inserted GIF file for display.
#
# Revision 1.17  2000/07/17 17:14:58  atchleyb
# placed forms in a table of width 750
#
# Revision 1.16  2000/07/11 15:06:09  munroeb
# finished modifying html formatting
#
# Revision 1.15  2000/07/06 23:20:28  munroeb
# finished mods to javascripts and html
#
# Revision 1.14  2000/07/05 22:34:17  munroeb
# made minor tweaks to javascript and html
#
# Revision 1.13  2000/06/21 21:53:26  johnsonc
# Editted opening page select object to support double click event.
#
# Revision 1.12  2000/06/16 15:46:07  johnsonc
# Revise WSB table entry to be optional display in edit and query screens
#
# Revision 1.11  2000/06/15 21:32:13  zepedaj
# Changed code to allow Commitment Maker Approval Rationale optional,
# while keeping Rejection Rationale Mandatory
#
# Revision 1.10  2000/06/14 18:40:09  zepedaj
# Changed Functional To Technical per DOE request
#
# Revision 1.9  2000/06/13 21:40:48  zepedaj
# Fixed width of tables so the columns would be the same
#
# Revision 1.8  2000/06/13 19:23:33  johnsonc
# Change 'Rationale For Commitment' field to display only when data is present
#
# Revision 1.7  2000/06/13 15:26:06  johnsonc
# Editted commitments select object to a fixed width.
#
# Revision 1.6  2000/06/12 15:41:53  johnsonc
# Add 'C' in front of commitment ID and 'I' in front of issue ID.
#  Add 'proposed' to edit and view commitment page titles.
#
# Revision 1.5  2000/06/09 20:12:49  johnsonc
# Edit secondary discipline text area to display only when it contains data
#
# Revision 1.4  2000/06/08 18:36:39  johnsonc
# Install commitment comment text box.
#
# Revision 1.3  2000/05/19 23:44:11  zepedaj
# Changed code for the final WBS structure
#
# Revision 1.2  2000/05/18 23:10:24  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/05/16 21:46:54  zepedaj
# Initial revision
#
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

my $CIRSCgi = new CGI;

$SCHEMA = (defined($CIRSCgi->param("schema"))) ? $CIRSCgi->param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

# print content type header
print $CIRSCgi->header('text/html');

my $pagetitle = "DOE Commitment Manager Closure Review";
my $cgiaction = $CIRSCgi->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $CIRSCgi->param('loginusersid');
my $username = $CIRSCgi->param('loginusername');
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
     doSetTextImageLabel('Commitment Closure Review');
//-->
</script>
testlabel1

my $dbh = oncs_connect();

my $DOECMgr_Roleid = 4; # DOE Commitment Manager
my $DOECMgr_closure_review_statusid = 13; # DOECMgr Closure Review

#####################################
if ($cgiaction eq "editcommitment") {
#####################################
    my $activity;
    my $commitmentid = $CIRSCgi->param('commitmentid');
    my $textareawidth = 75;
    my $commitmentidstring = substr("0000$commitmentid", -5);
    my %commitmenthash;
    my %responseinfo;
    eval {
	$activity = "Get info for commitment $commitmentid and associated response(s)";
	%commitmenthash = get_commitment_info($dbh, $commitmentid);
	%responseinfo = lookup_response_information($dbh, $commitmentid);
    };
    if ($@) {
	my $logmessage = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$logmessage =~ s/\n/\\n/g;
	$logmessage =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$logmessage');\n";
        print "//--></script>\n";
    }
    my $statusid = $commitmenthash{'statusid'};
    my $resubmitrationale = $commitmenthash{'resubmitrationale'};

    my $responseid = $responseinfo{'responseid'};
    my $responsetext = $responseinfo{'text'};
    my $responsewrittendate = $responseinfo{'writtendate'};
    my $letteraccessionnum = $responseinfo{'accessionnum'};

    my $commitmentisrework = (defined ($resubmitrationale) && ($resubmitrationale ne ""));

    my $key;

    $dbh->{LongTruncOk} = 0;

    print <<committable;
    <script language="JavaScript" type="text/javascript">
    <!--
    function validate_commitment_data() {
	var msg = "";
	var tmpmsg = "";
	var returnvalue = true;
	var validateform = document.editcommitment;
	if (msg != "") {
	    alert(msg);
	    returnvalue = false;
        }
	return (returnvalue);
    }
    function resubmit_commitment() {
	var tempcgiaction;
	var msg = "";
	var returnvalue = true;
	var validateform = document.editcommitment;
	msg += (validateform.resubmitrationale.value=="") ? "You must enter the resubmission rationale for this commitment if you are rejecting the closure.\\n" : "";
	if (msg != "") {
	    alert(msg);
	    returnvalue = false;
        }
	if (returnvalue) {
	    document.editcommitment.submit();
        }
	return (returnvalue);
    }
    function pass_on() {
	var tempcgiaction;
	var returnvalue = true;
	if (validate_commitment_data()) {
	    tempcgiaction = document.editcommitment.cgiaction.value;
	    document.editcommitment.cgiaction.value = "pass_on";
	    document.editcommitment.submit();
	    document.editcommitment.cgiaction.value = tempcgiaction;
        }
	else {
	    returnvalue = false;
        }
	return (returnvalue);
    }
    //-->
    </script>
    </head>
    <body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
    <table border=0 align=center width=650><tr><td>
    <form name=editcommitment enctype="multipart/form-data" method=post target="control" action="$ONCSCGIDir/DOECMgr_closure_review.pl">
    <input name=cgiaction type=hidden value="resubmit_commitment">
    <input name=loginusersid type=hidden value=$usersid>
    <input name=loginusername type=hidden value=$username>
    <input name=commitmentid type=hidden value=$commitmentid>
    <input name=statusid type=hidden value=$statusid>
    <input type=hidden name=schema value=$SCHEMA>
committable

    print "<p><table summary=\"Enter Commitment Table\" width=100% align=center border=0 cellspacing=10>\n";
    eval {
	$activity = "Do processing tables for commitment $commitmentid";
	print &doIssueTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
	print &doIssueSourceTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
	print &doHeadTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA, cidstring => $commitmentidstring);
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
	print &doResponseTable (cid => $commitmentid, dbh => $dbh);
	print "<tr><td><hr width=50%></td></tr>\n";
	print "<tr><td align=left><b><li>Rationale for Rework:</b><br>\n";
	print "(If there is a deficiency in the work performed, fill in a description of the deficiency and click \"Resubmit for Rework\" below)<br>\n";
	print "<textarea name=resubmitrationale cols=$textareawidth rows=5>$resubmitrationale</textarea></td></tr>\n";
	
	print "<tr><td><hr width=50%></td></tr>\n";
	$activity = "Do remarks for commitment $commitmentid";
	print &writeComment ();
	print doRemarksTable (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid);
    };
    if ($@) {
	my $logmessage = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$logmessage =~ s/\n/\\n/g;
	$logmessage =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$logmessage');\n";
        print "//--></script>\n";
    }
    print "<tr><td><center>\n";
    print "<input type=button name=resubmitcommitment value=\"Resubmit for Rework\" title=\"Resubmit Commitment to the DOE Discipline Lead for further review.\" onclick=\"return(resubmit_commitment())\">\n";
    print "<input type=button name=saveandcomplete value=\"Recommend Closure\" title=\"Save Commitment and pass it on to the Commitment Maker for closure.\" onclick=\"return(pass_on())\">\n";
    print "</form>\n</td></tr></table>\n<br><br><br><br>\n";
    print "</body>\n</html>\n";

    &oncs_disconnect($dbh);
    exit 1;
}  ################# endif editcommitment  ######################

# resubmit the commitment
##########################################
if ($cgiaction eq "resubmit_commitment") {
##########################################
    no strict 'refs';

    #control variables
    my $commitmentid = $CIRSCgi->param('commitmentid');
    my $activity;

    # boolean variables, should be 0 or -1 (false/true)

    # commitment variables
    my $resubmitrationale = $CIRSCgi->param('resubmitrationale');
    my $resubmitrationalesql = ($resubmitrationale) ? ":resubmitrationaleclob" : "NULL";
    my $comments = $CIRSCgi->param('commenttext');

    #status variable depends on choice
    my $nextstatusid = 12; # DOE Discipline Lead Rework

    #sql strings
    my $commitmentupdatesql = "UPDATE $SCHEMA.commitment
                             SET resubmitrationale = $resubmitrationalesql,
                             statusid = $nextstatusid,
                             updatedby = $usersid
                             WHERE commitmentid = $commitmentid";
    eval {
	my $csr;
	$activity = "Update Commitment";
	$csr = $dbh->prepare($commitmentupdatesql);
	if ($resubmitrationale) {
	    $csr->bind_param(":resubmitrationaleclob", $resubmitrationale, {ora_type => ORA_CLOB, ora_field => "resubmitrationale" });
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
	print <<pageerror;
	<script language="JavaScript" type="text/javascript">
        <!--
	    alert("$alertstring");
        //-->
        </script>
pageerror
    }
    else {
	&log_activity($dbh, 'F', $usersid, "Commitment ".&formatID2($commitmentid, 'C')." updated and sent back to the DOE Discipline Lead for further work");
	my ($primarydiscipline, $siteid) = $dbh -> selectrow_array ("select primarydiscipline, siteid from $SCHEMA.commitment where commitmentid = $commitmentid");
	my $modls = $dbh -> prepare ("select distinct usersid from $SCHEMA.defaultdisciplinerole where disciplineid = $primarydiscipline and roleid = 2 and siteid = $siteid");
	$modls -> execute;
	while (my ($modlid) = $modls -> fetchrow_array) {
	    my $notification = &notifyUser(dbh => $dbh, schema => $SCHEMA, userID => $modlid);
	}   
	print <<pageresults;
	<script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
    }
    &oncs_disconnect($dbh);
    print "</head><body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0></body></html>\n";
    exit 1;
}  ################  endif resubmit_commitment  ######################

# pass the commitment to the next user
##############################
if ($cgiaction eq "pass_on") {
##############################
    no strict 'refs';

    #control variables
    my $commitmentid =  $CIRSCgi->param('commitmentid');
    my $activity;

    # Find pertinent user information
    # Site id of the user is the same for the commitment
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);

    # commitment variables
    my $comments = $CIRSCgi->param('commenttext');

    #status variable depends on choice
    my $nextstatusid = 14; # Commitment Maker Closure Review

    #sql strings
    my $commitmentupdatesql ="UPDATE $SCHEMA.commitment
                            SET resubmitrationale = NULL,
                            statusid = $nextstatusid,
                            updatedby = $usersid
                            WHERE commitmentid = $commitmentid";
    eval {
	my $csr;
	$activity = "Update Commitment";
	my $csr = $dbh->prepare($commitmentupdatesql);
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
	print <<pageerror;
	<script language="JavaScript" type="text/javascript">
        <!--
        alert("$alertstring");
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
	</script>
pageerror
    }
    else {
	my $logmessage = "Commitment ".&formatID2($commitmentid, 'C')." updated and passed on to the Commitment Maker for closure review";
	my $logtitle = "Commitment Updated";
	&log_activity($dbh, 'F', $usersid, $logmessage);
	my ($approvedby) = $dbh -> selectrow_array ("select approver from $SCHEMA.commitment where commitmentid = $commitmentid");
	my $notification = &notifyUser(dbh => $dbh, schema => $SCHEMA, userID => $approvedby);
	print <<pageresults;
	<script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
    }
    &oncs_disconnect($dbh);
    print "</head><body background=$ONCSBackground></body></html>\n";
    exit 1;
}  #######################  endif pass_on  ##############
