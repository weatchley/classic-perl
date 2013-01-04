#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# M&O Discipline Lead Fulfillment screen
#
# $Source: /data/dev/rcs/cms/perl/RCS/MOFL_fulfillment.pl,v $
# $Revision: 1.43 $
# $Date: 2001/11/15 23:12:13 $
# $Author: naydenoa $
# $Locker:  $
# $Log: MOFL_fulfillment.pl,v $
# Revision 1.43  2001/11/15 23:12:13  naydenoa
# Added action display to commitment info.
#
# Revision 1.42  2001/05/07 15:58:07  naydenoa
# Updated evals
#
# Revision 1.41  2001/05/02 22:33:08  naydenoa
# Modified evals, calls to Edit_Screens
#
# Revision 1.40  2001/01/02 17:35:40  naydenoa
# More code clean-up
#
# Revision 1.39  2000/12/19 18:58:14  naydenoa
# Code cleanup
#
# Revision 1.38  2000/11/07 23:30:02  naydenoa
# Added email notification
# Added issue source display
# Took out rationales (except rework)
#
# Revision 1.37  2000/10/27 19:05:54  naydenoa
# Added remark display
# Changed table width to 650, textare width to 75
#
# Revision 1.36  2000/10/26 19:44:58  naydenoa
# Added remark display
# Changed table width to 650, textarea width to 75
#
# Revision 1.35  2000/10/24 19:35:22  naydenoa
# Updated call to Edit_Screens (commitment info table)
#
# Revision 1.34  2000/10/18 22:58:24  naydenoa
# Fixed status bug at update.
#
# Revision 1.33  2000/10/18 20:05:55  munroeb
# finished formatting activity log messages
#
# Revision 1.32  2000/10/17 15:58:24  munroeb
# removed log_history perm.
#
# Revision 1.31  2000/10/16 17:59:13  munroeb
# removed log_history function
#
# Revision 1.30  2000/10/06 17:58:06  munroeb
# added log_activity feature to script
#
# Revision 1.29  2000/10/03 20:41:59  naydenoa
# Updates status id's and references.
#
# Revision 1.28  2000/09/29 21:15:04  naydenoa
# Changed references to statuses and roles (now by ID)
#
# Revision 1.27  2000/09/28 20:07:37  naydenoa
# *** empty log message ***
#
# Revision 1.26  2000/09/18 15:06:47  naydenoa
# More interface updates
#
# Revision 1.25  2000/09/08 23:48:52  naydenoa
# More interface modifications.
#
# Revision 1.24  2000/08/25 16:26:10  atchleyb
# changed Technical Lead to Discipline Lead
#
# Revision 1.23  2000/08/21 22:26:01  atchleyb
# fixed var name bug
#
# Revision 1.22  2000/08/21 20:29:02  atchleyb
# fixed var name bug
#
# Revision 1.21  2000/08/21 18:44:17  atchleyb
# added check schema line
# changed cirscgi to cmscgi
#
# Revision 1.20  2000/07/17 20:46:27  atchleyb
# fixed table bugs
#
# Revision 1.19  2000/07/17 16:36:31  atchleyb
# placed forms in a table of width 750
#
# Revision 1.18  2000/07/11 15:02:21  munroeb
# finished modifying html formatting
#
# Revision 1.17  2000/07/06 23:30:51  munroeb
# finished mods to html and javascripts
#
# Revision 1.16  2000/06/21 22:02:12  johnsonc
#  Editted opening page select object to support double click event.
#
# Revision 1.15  2000/06/16 15:48:44  johnsonc
# Revise WSB table entry to be optional display in edit and query screens
#
# Revision 1.14  2000/06/15 21:32:42  zepedaj
# Changed code to allow Commitment Maker Approval Rationale optional,
# while keeping Rejection Rationale Mandatory
#
# Revision 1.13  2000/06/14 18:37:53  zepedaj
# Changed Functional To Technical per DOE request
#
# Revision 1.12  2000/06/13 21:41:48  zepedaj
# Fixed width of tables so the columns would be the same
#
# Revision 1.11  2000/06/13 19:27:12  johnsonc
# Change 'Rationale For Commitment' field to display only when data is present
#
# Revision 1.10  2000/06/13 15:29:46  johnsonc
# Editted commitments select object to a fixed width.
#
# Revision 1.9  2000/06/12 15:48:02  johnsonc
# Add 'C' in front of commitment ID and 'I' in front of issue ID.
# Add 'proposed' to edit and view commitment page titles.
#
# Revision 1.8  2000/06/09 20:19:42  johnsonc
# Edit secondary discipline text area to display only when it contains data
#
# Revision 1.7  2000/06/08 18:39:38  johnsonc
# Install commitment comment text box.
#
# Revision 1.6  2000/05/19 23:46:17  zepedaj
# Changed code for the final WBS structure
#
# Revision 1.5  2000/05/18 23:11:42  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.4  2000/05/16 18:56:15  zepedaj
# Updated comments to reflect the purpose of this script
#
# Revision 1.3  2000/05/15 22:03:22  zepedaj
# Replaced popup text on pass-on button to reflect the current status of the commitment.
#
# Revision 1.2  2000/05/15 21:32:37  zepedaj
# Removed unnecessary code block "fillout_letter" which would never execute from within this script.
#
# Revision 1.1  2000/05/15 21:15:33  zepedaj
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

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

# print content type header
print $cmscgi->header('text/html');

my $pagetitle = "M&amp;O Discipline Lead Commitment Fulfillment";
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
if (parent == self) { // not in frames
    location = '$ONCSCGIDir/login.pl'
}
//-->
</script>
testlabel1

my $dbh = oncs_connect();

my $MOFL_Roleid = 2; # M&O Discipline Lead
my $MOFL_pending_statusid = 9; # Pending/MODL Fulfillment
my $MOFL_rework_statusid = 10; # MODL Rework

#####################################
if ($cgiaction eq "editcommitment") {
#####################################
    my $activity;
    my $commitmentid = $cmscgi->param('commitmentid');
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
    my $actionstaken = $commitmenthash{'actionstaken'};
    my $resubmitrationale = $commitmenthash{'resubmitrationale'};

    my $responseid = $responseinfo{'responseid'};
    my $responsetext = $responseinfo{'text'};
    my $responsewrittendate = $responseinfo{'writtendate'};
    my $letteraccessionnum = $responseinfo{'accessionnum'};

    my $commitmenthasactionstaken = (defined($actionstaken) && ($actionstaken ne ""));
    my $commitmentisrework = ($statusid == $MOFL_rework_statusid);

    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    if ($resubmitrationale) {
        print "<!--\ndoSetTextImageLabel('Rework Fulfilled Commitment');\n";
    }
    else {
        print "<!--\ndoSetTextImageLabel('Commitment Fulfillment');\n";
    }
    print "//-->\n</script>\n";

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
	msg += (validateform.actionstaken.value=="") ? "You must enter the actions taken for this commitment.\\n" : "";
	if (msg != "") {
	    alert(msg);
	    returnvalue = false;
        }
	return (returnvalue);
    }
    function save_commitment() {
	var tempcgiaction;
	var msg = "";
	var returnvalue = true;
	var validateform = document.editcommitment;
	msg += (validateform.actionstaken.value=="") ? "You must enter the actions taken for this commitment.\\n" : "";
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
    <table border=0 align=center width=650><tr><td><CENTER>
    <form name=editcommitment enctype="multipart/form-data" method=post target="control" action="$ONCSCGIDir/MOFL_fulfillment.pl">
    <input name=cgiaction type=hidden value="save_commitment">
    <input name=loginusersid type=hidden value=$usersid>
    <input name=loginusername type=hidden value=$username>
    <input name=commitmentid type=hidden value=$commitmentid>
    <input name=statusid type=hidden value=$statusid>
    <input type=hidden name=schema value=$SCHEMA>
committable
    print "<p><table summary=\"Enter Commitment Table\" width=650 align=center border=0 cellspacing=10>\n";
    eval {
        $activity = "Do prior work tables";
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
        $activity = "Do active fields";
	print writeActionsTaken (cid => $commitmentid, dbh => $dbh);
	if ($commitmentisrework) {
	    print "<tr><td align=left><b><li>Resubmit Rationale:</b>\n";
	    print "<br><table border=1 width=100%><tr><td bgcolor=#eeeeee>$resubmitrationale</td></tr></table>\n";
	}
	print "<tr><td><hr width=50%></td></tr>\n";
	print &writeComment (active => 1);
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
    print "</table>\n";
    print "<center>\n";
    print "<input type=button name=savecommitment value=\"Save Draft Work\" title=\"Save Commitment, can be edited later\" onclick=\"return(save_commitment())\">\n";
    print "<input type=button name=saveandcomplete value=\"Save and Pass On\" title=\"Save Commitment and pass it on to the DOE Discipline Lead for review\" onclick=\"return(pass_on())\">\n";
    print "</form>\n</td></tr></table>\n<br><br><br>\n";
    print "</body>\n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
}  ####  endif editcommitment ####

######################################
if ($cgiaction eq "save_commitment") {
######################################
    no strict 'refs';
    my $commitmentid = $cmscgi->param('commitmentid');
    my $activity;

    my $actionstaken = $cmscgi->param('actionstaken');
    my $actionstakensql = ($actionstaken) ? ":actionstakenclob" : "NULL";
    my $comments = $cmscgi->param('commenttext');

    my $commitmentupdatesql = "UPDATE $SCHEMA.commitment
                             SET actionstaken = $actionstakensql,
                             updatedby = $usersid
                             WHERE commitmentid = $commitmentid";
    eval {
	my $csr;
	$activity = "Update Commitment";
	$csr = $dbh->prepare($commitmentupdatesql);
	if ($actionstaken) {
	    $csr->bind_param(":actionstakenclob", $actionstaken, {ora_type => ORA_CLOB, ora_field => "actionstaken" });
	}
	$csr->execute;
        ####  update commitment remarks  ####
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
        //parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username";
        //-->
        </script>
pageerror
    }
    else {
	&log_activity($dbh, 'F', $usersid, "Commitment ".&formatID2($commitmentid, 'C')." updated by the BSC Lead");
	print <<pageresults;
	<script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username";
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username";
        //-->
        </script>
pageresults
    }
    &oncs_disconnect($dbh);
    print "</head><body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0></body></html>\n";
    exit 1;
}  ####  endif save_commitment  ####

# pass the commitment to the next user (DOE Discipline Lead)
##############################
if ($cgiaction eq "pass_on") {
##############################
    no strict 'refs';

    my $commitmentid =  $cmscgi->param('commitmentid');
    my $activity;
    my $statusid = $cmscgi -> param ('statusid');

    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);

    my $actionstaken = $cmscgi->param('actionstaken');
    my $actionstakensql = ":actionstakenclob";
    my $statusid = $cmscgi->param('statusid');
    my $comments = $cmscgi->param('commenttext');

    # boolean variables, should be 0 or -1 (true/false)
    my $commitmentisrework = ($statusid == $MOFL_rework_statusid);

    #status variable depends on choice
    my $nextstatusid;
    if ($statusid == 10) {
	$nextstatusid = 12; # DOEDL Rework/Revise
    }
    else {
	$nextstatusid = 11; # DOE Discipline Lead Fulfillment Review
    }
    my $commitmentupdatesql ="UPDATE $SCHEMA.commitment
                            SET actionstaken = $actionstakensql,
                            statusid = $nextstatusid,
                            updatedby = $usersid
                            WHERE commitmentid = $commitmentid";
    eval {
	my $csr;
	$activity = "Update Commitment";
	my $csr = $dbh->prepare($commitmentupdatesql);
	$csr->bind_param(":actionstakenclob", $actionstaken, {ora_type => ORA_CLOB, ora_field => 'actionstaken' });
	$csr->execute;

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
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username";
        //-->
        </script>
pageerror
    }
    else {
	my $logmessage = "Commitment ".&formatID2($commitmentid, 'C')." updated and passed on to the DOE Discipline Lead";
	my $logtitle = "Commitment Updated";
	&log_activity($dbh, 'F', $usersid, $logmessage);
	my ($primarydiscipline) = $dbh -> selectrow_array ("select primarydiscipline from $SCHEMA.commitment where commitmentid = $commitmentid");
	my $doedls = $dbh -> prepare ("select distinct usersid from $SCHEMA.defaultdisciplinerole where disciplineid = $primarydiscipline and roleid = 3 and siteid = $siteid");
	$doedls -> execute;
	while (my ($doedlid) = $doedls -> fetchrow_array) {
	    my $notification = &notifyUser(dbh => $dbh, schema => $SCHEMA, userID => $doedlid);
	}	
	print <<pageresults;
	<script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username";
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username";
        //-->
        </script>
pageresults
    }
    &oncs_disconnect($dbh);
    print "</head><body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0></body></html>\n";
    exit 1;
}  ####  endif pass_on  ####
