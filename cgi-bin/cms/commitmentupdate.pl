#!/usr/local/bin/newperl
#
# CMS Commitment Update Screen
#
# $Source: /data/dev/rcs/cms/perl/RCS/commitmentupdate.pl,v $
# $Revision: 1.32 $
# $Date: 2003/11/21 21:30:47 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: commitmentupdate.pl,v $
# Revision 1.32  2003/11/21 21:30:47  naydenoa
# Removed CIRS interface code - CIRS is retired.
#
# Revision 1.31  2003/01/17 23:03:39  naydenoa
# Renamed "Date Due To NRC" to "Date Due To Originator"
# Made date due to originator optional
# Updated fulfillment date validation so it does not require approval
# when there is no prior fulfillment date.
# CREQ00024, CREQ00028
#
# Revision 1.30  2003/01/11 00:35:27  naydenoa
# Made DOE Manager optional - CREQ00023 - rework
#
# Revision 1.29  2003/01/03 00:36:34  naydenoa
# Added display and processing of NRC due date and DOE manager
# CREQ00023, CREQ00024
#
# Revision 1.28  2002/11/05 17:22:09  naydenoa
# Updated condition for CIRS text xhange capture.
#
# Revision 1.27  2002/09/25 19:40:15  naydenoa
# Cleaned up CIRS code - uses CIRS_procs module
#
# Revision 1.26  2002/08/24 00:55:51  naydenoa
# CIRS interface processing added - preliminary.
#
# Revision 1.25  2002/07/15 21:50:21  naydenoa
# Added fulfillment date update.
#
# Revision 1.24  2001/12/10 23:13:33  naydenoa
# Changed BSCLL to BSCDL
#
# Revision 1.23  2001/11/15 23:18:06  naydenoa
# Updated to reflect role changes, added LL and RM.
#
# Revision 1.22  2001/06/01 23:09:44  naydenoa
# Added some Licensing Lead processing; checkpoint
#
# Revision 1.21  2001/05/08 17:05:23  naydenoa
# Updated evals
#
# Revision 1.20  2001/05/03 15:46:40  naydenoa
# Modified evals, calls to Edit_Screens
#
# Revision 1.19  2001/03/14 00:09:44  naydenoa
# Fixd bug on role update
#
# Revision 1.18  2001/03/12 23:30:58  naydenoa
# Made sure it changes roles when statusid<3 and keeps same
# roles if statusid>3 (work has already been performed)
#
# Revision 1.17  2001/03/12 23:04:39  naydenoa
# Added discipline lead update (commitmentrole table)
#
# Revision 1.16  2001/02/21 22:36:14  naydenoa
# Added RSS processing.
#
# Revision 1.15  2001/01/31 22:10:27  naydenoa
# Took out secondary discipline
#
# Revision 1.14  2000/12/19 21:48:45  naydenoa
# Code cleanup
#
# Revision 1.13  2000/12/13 17:05:09  naydenoa
# Slight revision of fulfillment date validation
#
# Revision 1.12  2000/12/07 23:23:30  naydenoa
# Fixed bug in var declaration at validation
#
# Revision 1.11  2000/12/07 19:06:32  naydenoa
# Added fulfillment date update.
#
# Revision 1.10  2000/11/20 19:40:30  naydenoa
# Moved some redundant code to Edit_Screens module
#
# Revision 1.9  2000/11/16 18:37:27  naydenoa
# Added features to due date change - info recorded in
# duedatehistory table
#
# Revision 1.8  2000/11/06 18:01:26  naydenoa
# Made date fields updatable, added issue image to issue source display
#
# Revision 1.7  2000/10/31 19:44:26  naydenoa
# Updated function calls, took out rationales (except reject & rework)
#
# Revision 1.6  2000/10/31 17:00:30  naydenoa
# Fixed committedto validation
# Added keyword selection
# Made remark mandatory and added old remarks display
# Changed table width to 650, textarea width to 75
#
# Revision 1.5  2000/10/18 21:29:46  munroeb
# modified activity log message
#
# Revision 1.4  2000/10/17 18:53:20  naydenoa
# Code clean up
#
# Revision 1.3  2000/10/17 18:33:52  naydenoa
# Took out comments
#
# Revision 1.2  2000/10/17 18:27:44  naydenoa
# Took out response and letter info
#
# Revision 1.1  2000/10/17 18:24:33  naydenoa
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
my $updatetable = "commitment";

my $commitmentid = ((defined($cmscgi->param("commitmentid"))) ? $cmscgi->param("commitmentid") : "");
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
print <<testlabel1;
<html>
<head>
<meta name=pragma content=no-cache>
<meta name=expires content=0>
<meta http-equiv=expires content=0>
<meta http-equiv=pragma content=no-cache>
<title>Commitment Management System: Commitment Update</title>

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
    if (document.$form.selectedcommitmentid.selectedIndex == -1 || document.$form.selectedcommitmentid.options[document.$form.selectedcommitmentid.options.length - 1].selected == 1) {
	alert ('You must first select a commitment');
    }
    else {
	document.$form.commitmentid.value = document.$form.selectedcommitmentid[document.$form.selectedcommitmentid.selectedIndex].value;
	submitForm('$form','commitmentupdate');
    }
}
doSetTextImageLabel('Commitment Update');
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
    print "<input name=commitmentid type=hidden value=$commitmentid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    eval {
        print "<br><br><b>Commitments:</b><br><br>\n";
        print "<select size=10 name=selectedcommitmentid onDblClick=\"processQuery();\">\n";
        %lookup_values = get_lookup_values($dbh, "commitment", 'commitmentid', "text", "1=1 order by commitmentid");
        foreach my $key (keys %lookup_values) {
            print "<option value=$key>C" . lpadzero($key,5) . " - " . getDisplayString($lookup_values{$key},60) . "</option>\n";
        }
        print "<option value=blank>" . &nbspaces(60) . "\n";
        print "</select><br><br><br>\n";
        print "<input type=button name=querysubmit value='Update Commitment' onClick=\"processQuery();\">\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"commitment update - query page",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/\'/\'\'/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }
    print "</form>";
    &oncs_disconnect($dbh);
}

#######################################
if ($cgiaction eq "commitmentupdate") {
#######################################
    my $activity;
    my $key = '';
    my %commitmenthash;
    my $siteid;
    my %usershash;
    my %approvedbyhash;
    my $issuehasimage;
    my $issueid;
    eval {  
	$activity = "Get commitment info";
	%commitmenthash = get_commitment_info ($dbh, $commitmentid);
	$siteid = $commitmenthash{'siteid'};
        $issueid = $commitmenthash{'issueid'};
	%usershash = get_lookup_values($dbh, 'users', "lastname || ', ' || firstname || ';' || usersid", 'usersid', "siteid=$siteid $nodevelopers");
	if ($CMSProductionStatus) {
	    $nodevelopers = ' and srole.usersid < 1000';
	}
	%approvedbyhash = get_lookup_values ($dbh, "users, $SCHEMA.defaultsiterole srole", "users.lastname || ', ' || users.firstname || ';' || users.usersid", 'users.usersid', "srole.usersid=users.usersid and srole.roleid=5 and users.isactive='T' and srole.siteid=$siteid $nodevelopers");
	($issuehasimage) = $dbh -> selectrow_array ("select count (*) from $SCHEMA.issue where issueid=$issueid and imageextension is not null");
    };
    if ($@) {
	my $logmessage = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$logmessage =~ s/\n/\\n/g;
	$logmessage =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$logmessage');\n";
        print "//--></script>\n";
    }
    my $ctext = $commitmenthash{'text'};
    my $duedate = $commitmenthash{'duedate'};
    my $statusid = $commitmenthash{'statusid'};
    my $commitdate = $commitmenthash{'commitdate'};
    my $estimate = $commitmenthash{'estimate'};
    my $dlrecommend = $commitmenthash{'functionalrecommend'};
    my $closingdocimage = $commitmenthash{'closingdocimage'};
    my $rejectionrationale = $commitmenthash{'rejectionrationale'};
    my $resubmitrationale = $commitmenthash{'resubmitrationale'};
    my $actionstaken = $commitmenthash{'actionstaken'};
    my $actionsummary = $commitmenthash{'actionsummary'};
    my $actionplan = $commitmenthash{'actionplan'};
    my $cmrecommend = $commitmenthash{'cmrecommendation'};
    my $closedate = $commitmenthash {'closeddate'};
    my $cmaker = $commitmenthash{'approver'};
    my $commitmentlevelid = $commitmenthash{'commitmentlevelid'};
    my $cimagecontenttype = $commitmenthash{'imagecontenttype'};
    my $cimageextension = $commitmenthash{'imageextension'};
    my $commitmenthasimage = ($cimageextension) ? 1 : 0;
    my $fulfilldate = $commitmenthash{'fulfilldate'};
    my $externalid = $commitmenthash{'externalid'}; 
    my $lleadid = $commitmenthash{'lleadid'};
    my $managerid = $commitmenthash{'managerid'};
    my $doemanagerid = $commitmenthash{'doemanagerid'};
    my $dateduetonrc = $commitmenthash{'dateduetonrc'};
    
    my $issuehassourcedoc = $cmscgi -> param ('issuehassourcedoc');
    
    print<<somejavascripts;
    <script language="JavaScript" type="text/javascript"><!--
    function update_commitment_table(statusid) {
        var tempcgiaction;
        var returnvalue = true;
	if (statusid > 8) {
	    selectemall (document.commitmentupdate.committedto);
	}
	if (validate_commitment_data(statusid)) {
	    document.commitmentupdate.cgiaction.value="updatecommitmenttable";
	    if (statusid > 2) {
		selectemall (document.commitmentupdate.keywords);
	    }
            submitForm ('commitmentupdate', 'updatecommitmenttable');
	}
	else {
	    returnvalue = false;
	}
	return (returnvalue);
    }
    function validate_commitment_data(statusid) {
	var msg = "";
	var tmpmsg = "";
	var returnvalue = true;
	var validateform = document.commitmentupdate;
	msg += (validateform.commitmenttext.value=="") ? "You must enter the text of the commitment.\\n" : "";
	if (statusid > 1) {
	    msg += (validateform.discipline.value=="") ? "You must enter the primary discipline for the commitment.\\n" : "";
            msg += (validateform.disciplinelead.value==\'\' || validateform.disciplinelead.value==\'NULL\') ? \"You must select a BSC discipline lead for this commitment.\\n\" : \"\";
            msg += (validateform.BSCresponsiblemanager.value==\'\' || validateform.BSCresponsiblemanager.value==\'NULL\') ? \"You must select a BSC responsiblemanager for this commitment.\\n\" : \"\";
//            msg += (validateform.DOEresponsiblemanager.value==\'\' || validateform.DOEresponsiblemanager.value==\'NULL\') ? \"You must select a DOE responsiblemanager for this commitment.\\n\" : \"\";
 	    msg += (validateform.commitmentlevelid.value=="") ? "You must enter the level of commitment (or Not Available).\\n" : "";
	    msg += ((tmpmsg = validate_date(validateform.duedate_year.value, validateform.duedate_month.value, validateform.duedate_day.value, 0, 0, 0, 0, true, true, false)) == "") ? "" : "Date Due - " + tmpmsg + "\\n";
	    if (validateform.olddate.value != validateform.duedate.value) {
		msg += (validateform.dateapprover.value=="") ? "You must enter the approver of the due date change.\\n" : "";
		msg += (validateform.datereason.value=="") ? "You must enter the reason for the due date change.\\n" : "";
	    }
	    if (statusid > 2) {
		var fulfillmonth = validateform.fulfilldate_month.value;
		var fulfillday = validateform.fulfilldate_day.value;
		var fulfillyear = validateform.fulfilldate_year.value;
		fulfilldate = new Date (fulfillyear, fulfillmonth - 1, fulfillday);
		duedate = new Date (validateform.duedate_year.value, validateform.duedate_month.value - 1, validateform.duedate_day.value);
		
		msg += ((tmpmsg = validate_date(fulfillyear, fulfillmonth, fulfillday, 0, 0, 0, 0, true, true, false)) == "") ? "" : "Fulfillment Date - " + tmpmsg + "\\n";
		if (Date.parse(fulfilldate) <= Date.parse(duedate)) {
		    msg += "Fulfillment date cannot precede or be the same as the date due to the Commitment Maker.\\n";
		}
	        if (validateform.oldfuldate.value != "" && validateform.oldfuldate.value != validateform.fulfilldate.value) {
		    msg += (validateform.fuldateapprover.value=="") ? "You must enter the approver of the fulfillment date change.\\n" : "";
		    msg += (validateform.fuldatereason.value=="") ? "You must enter the reason for the fulfillment date change.\\n" : "";
                }
		msg += (validateform.workbreakdownstructure.value=="") ? "You must enter the WBS (or Not Available) for the commitment.\\n" : "";
		msg += (validateform.estimate.value=="") ? "You must enter the work estimate for the commitment.\\n" : "";
		msg += (validateform.actionplan.value=="") ? "You must enter the action plan for the commitment.\\n" : "";
		if (statusid > 3) {
		    msg += (validateform.actionsummary.value=="") ? "You must enter the action summary for the commitment.\\n" : "";
		    msg += (validateform.functionalrecommend.value=="") ? "You must enter the Discipline Lead recommendation for the commitment.\\n" : "";
		    if (statusid > 4) {
			msg += (validateform.cmrecommendation.value=="") ? "You must enter the Commitment Manager recommendation for the commitment.\\n" : "";
			msg += (validateform.approvedby.value == "NULL") ? "You must enter the Commitment Maker for the commitment.\\n" : "";
			if (statusid > 5) {
			    msg += ((tmpmsg = validate_date(validateform.commitdate_year.value, validateform.commitdate_month.value, validateform.commitdate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Commit Date - " + tmpmsg + "\\n";
			    if (statusid == 8) {
				msg += (validateform.rejectionrationale.value=="") ? "You must enter the rejection rationale for the commitment.\\n" : "";
			    }
			    if (statusid > 8){
                                if (validateform.nrcdate_year.value != "" || validateform.nrcdate_month.value != "" || validateform.nrcdate_day.value != "") {
                                    msg += ((tmpmsg = validate_date(validateform.nrcdate_year.value, validateform.nrcdate_month.value, validateform.nrcdate_day.value, 0, 0, 0, 0, true, true, false)) == "") ? "" : "Date Due To NRC - " + tmpmsg + "\\n";
                    	            if (validateform.oldnrcdate.value != "" && validateform.oldnrcdate.value != validateform.nrcdate.value) {
		                        msg += (validateform.nrcdateapprover.value=="") ? "You must enter the approver of the date due to originator change.\\n" : "";
		                        msg += (validateform.nrcdatereason.value=="") ? "You must enter the reason for the date due to originator change.\\n" : "";
                                    }
                                }
				msg += (validateform.committedto.selectedIndex == -1) ? "You must select the organization(s) the commitment was made to.\\n" : "";
				if (statusid > 10 && statusid < 17) {
				    msg += (validateform.actionstaken.value=="") ? "You must enter the actions taken to fulfill the commitment.\\n" : "";
				    if (statusid > 14) {
					msg += ((tmpmsg = validate_date(validateform.closedate_year.value, validateform.closedate_month.value, validateform.closedate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Close Date - " + tmpmsg + "\\n";
				    }
				}
			    }
			}
		    }
		}
	    }
	}
	if (statusid == 8 || statusid == 16) {
	    if (validateform.commitmenthasimage.value == 0 && validateform.oldimage.value == 0) {
		msg += (validateform.image.value=="") ? "You must enter a scanned image of the commitment.\\n" : "";
	    }
	}
        msg += (validateform.commenttext.value == "") ? "You must enter a description of the update in the remarks field.\\n" : "";
	if (msg != "") {
	    alert(msg);
	    returnvalue = false;
        }
	return (returnvalue);
    }
    //-->
    </script>
somejavascripts
    print "<form target=control action=$ONCSCGIDir/commitmentupdate.pl enctype=multipart/form-data method=post name=commitmentupdate>\n";
    print "<input name=cgiaction type=hidden value=updatecommitmenttable>\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=commitmentid type=hidden value=$commitmentid>\n";
    print "<input name=statusid type=hidden value=$statusid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    print "<center>\n";
    print "<table summary=\"update commitment table\" width=650 align=center cellspacing=10 border=0>\n";
    print "<tr><td><table width=650 align=center cellspacing=10>\n";
print "<tr><td><b><li>Commitment ID: &nbsp;&nbsp;" . formatID2($commitmentid,'C') ."</td></tr>\n";
    print "<tr><td><b><li>Date Due To Commitment Maker:</b>&nbsp;&nbsp;$duedate\n";
    my $closedatestr = ($closedate) ? $closedate : "Open Commitment";
    my $commitdatestr = ($commitdate) ? $commitdate : "Approval Pending";
    my $fulfilldatestr = ($fulfilldate) ? $fulfilldate : "To Be Determined";
    my $nrcdatestr = ($dateduetonrc) ? $dateduetonrc : "To Be Determined";
    if ($statusid == 8) {
	$closedatestr = $closedate . " (Rejected)";
	$commitdatestr = $commitdate ." (Rejected)";
    }
    print "<b><li>Date of Commitment Maker Approval:</b>&nbsp;&nbsp;$commitdatestr\n";
    print "<b><li>Estimated Date of Fulfillment:</b>&nbsp;&nbsp;$fulfilldatestr\n";
    print "<b><li>Date Due To Originator:</b>&nbsp;&nbsp;$nrcdatestr\n";
    print "<b><li>Closure Date:</b>&nbsp;&nbsp;$closedatestr</td></tr>\n";
    eval {
        $activity = "Display issue info";
	print doIssueTable(iid => $issueid, dbh => $dbh, schema => $SCHEMA);
	print doIssueSourceTable(iid => $issueid, dbh => $dbh, schema => $SCHEMA);
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
            print "<tr><td><b><li>Actions:</b>&nbsp;&nbsp;None\n</td></tr>\n"
        }
        print "<tr><td><hr width=50%></td></tr>\n";
	print "<tr><td align=left><b><li>Commitment Text:&nbsp;&nbsp;</b>\n";
	print "<br><textarea name=commitmenttext cols=75 rows=5>$ctext</textarea></td></tr>\n";
        $activity = "Display commitment fields";
	if ($statusid > 1) {
            print "<tr><td><b><li>External ID:</b>&nbsp;&nbsp;\n";
            print "<input type=text name=externalid length=20 maxlength=20 value=$externalid>&nbsp;&nbsp;(optional)</td></tr>";
	    print selectDiscipline (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA, update => 1);
            print selectBSCDL (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA, update => 1);
            print selectRM (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid, mgrtype => 1, update => 1);
            print selectRM (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid, mgrtype => 2, update => 1);
	    print selectLevel (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA, update => 1); 
	    print "<input type=hidden name=olddate value=$duedate>\n";
	    print "<tr><td><b><li>Date Due to Commitment Maker: &nbsp&nbsp</b>\n";
	    print build_date_selection('duedate', 'commitmentupdate', $duedate); 
	    print "<ul><b>Due Date Change Approval Letter Accession Number:</b>&nbsp;&nbsp;\n";
	    print "<input type=text name=dateaccnum size=17 max=17><p>\n";
	    print "<b>Approved By: &nbsp &nbsp\n";
	    print "<select name=dateapprover>\n";
	    print "<option value='' selected>Select Date Change Aprrover\n";
	    my $app;
	    foreach $key (sort keys %usershash) {
		$app =$key;
		$app =~ s/;$usershash{$key}//g;
		print "<option value=\"$usershash{$key}\">$app\n";
	    }
	    print "</select><p>\n";
	    print "<b>Reason for Due Date Change:</b><br>\n";
	    print "<textarea name=datereason cols=65 rows=3></textarea><br><br>\n";
	    print "</td></tr>\n";
	    if ($statusid > 2){
		print selectWBS (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA, update => 1);
		print selectKeywords (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA, update => 1);
		print &writeWorkEstimate (estimate => $estimate, active => 1);
		print "<tr><td><b><li>Estimated Fulfillment Date: </b>&nbsp;&nbsp;\n";
	        print "<input type=hidden name=oldfuldate value=$fulfilldate>\n";
		print build_date_selection('fulfilldate', 'commitmentupdate', $fulfilldate);
	    print "<ul><b>Fulfillment Date Change Approval Letter Accession Number:</b>&nbsp;&nbsp;\n";
	    print "<input type=text name=fuldateaccnum size=17 max=17><p>\n";
	    print "<b>Approved By: &nbsp &nbsp\n";
	    print "<select name=fuldateapprover>\n";
	    print "<option value='' selected>Select Date Change Aprrover\n";
	    my $fulapp;
	    foreach $key (sort keys %usershash) {
		$fulapp =$key;
		$fulapp =~ s/;$usershash{$key}//g;
		print "<option value=\"$usershash{$key}\">$fulapp\n";
	    }
	    print "</select><p>\n";
	    print "<b>Reason for Fulfillment Date Change:</b><br>\n";
	    print "<textarea name=fuldatereason cols=65 rows=3></textarea><br><br>\n";
		print "</td></tr>\n";
		print &writeActionPlan (actionplan => $actionplan, active => 1);
		if ($statusid > 3){
		    print &writeActionSummary (actionsummary => $actionsummary, active => 1);
		    print &writeDLRecommend (dlrecommend => $dlrecommend, active => 1);
		    print selectProducts (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA, update => 1);
		    if ($statusid > 4) {
			print &writeCMgrRecommend (recommend => $cmrecommend, active => 1);
			print selectCMaker (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
			if ($statusid > 5) {
			    print "<tr><td><b><li>Date of Commitment Maker Approval:&nbsp&nbsp</b>\n";
			    print build_date_selection('commitdate', 'commitmentupdate', $commitdate);
			    
			    print "</td></tr>\n";
			    if ($statusid > 7) {
				if ($commitmenthasimage) {
				    my $cimage = $CMSFullImagePath . "/commitmentfinalimage$commitmentid$cimageextension";
				    if (open (OUTFILE, "| ./File_Utilities.pl --command writeFile --protection 0664 --fullFilePath $cimage")) {
					print OUTFILE get_final_image($dbh, $commitmentid);
					close OUTFILE;
				    }
				    else {
					print "could not open file $cimage<br>\n";
				    }
				}
				if ($statusid == 8) {
				    print "<tr><td><b><li>Rejection Rationale:</b><br>\n";
				    print "<textarea name=rejectionrationale rows=5 cols=75>$rejectionrationale</textarea></td></tr>\n";
				    # if there is an image, retrieve it for display;
				    print "<tr><td><b><li>Closing Document Image:</b>&nbsp&nbsp\n";
				    if ($commitmenthasimage) {
					print "<a href=$CMSImagePath/commitmentfinalimage$commitmentid$cimageextension target=imagewin>Click here for document image</a>. Select a different image if necessary.<br>\n";
					print "<input type=hidden name=oldimage value=-1>\n";
				    }
				    else {
					print "<input type=hidden name=oldimage value=0>\n";
				    }
				    print "<input type=file name=image size=50 maxlength=256></td></tr>\n";
				    print "<input name=commitmenthasimage type=hidden value=0>\n";
				}
				if ($statusid > 8) {
		                    print "<tr><td><b><li>Date Due To Originator: </b>&nbsp;&nbsp;\n";
	                            print "<input type=hidden name=oldnrcdate value=$dateduetonrc>\n";
                                    my $defaultnrcdate = ($dateduetonrc) ? $dateduetonrc : 'blank';
		                    print build_date_selection('nrcdate', 'commitmentupdate', $defaultnrcdate);
	                            print "<ul><b>Date Due To Originator Change Approval Letter Accession Number:</b>&nbsp;&nbsp;\n";
	                            print "<input type=text name=nrcdateaccnum size=17 max=17><p>\n";
	                            print "<b>Approved By: &nbsp &nbsp\n";
	                            print "<select name=nrcdateapprover>\n";
	                            print "<option value='' selected>Select Date Change Aprrover\n";
	                            my $nrcapp;
	                            foreach $key (sort keys %usershash) {
		                        $nrcapp = $key;
		                        $nrcapp =~ s/;$usershash{$key}//g;
		                        print "<option value=\"$usershash{$key}\">$nrcapp\n";
	                            }
                         	    print "</select><p>\n";
	                            print "<b>Reason for Date Due To Originator Change:</b><br>\n";
	                            print "<textarea name=nrcdatereason cols=65 rows=3></textarea><br><br>\n";
		                    print "</td></tr>\n";

				    print selectOrganizations (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA, update => 1);
				    if ($statusid > 10 && $statusid < 17) {
					print "<tr><td><b><li>Actions Taken:</b><br>\n";
					print "<textarea name=actionstaken cols=75 rows=5>$actionstaken</textarea></td></tr>\n";
					if ($statusid > 14) {
					    print "<tr><td><b><li>Closure Date:&nbsp&nbsp</b>\n";
					    print build_date_selection('closedate', 'commitmentupdate', $closedate);
					    
					    print "</td></tr>\n";
					    if ($statusid > 15) {
						print "<tr><td><b><li>Closing Document Image:</b>&nbsp&nbsp\n";
						if ($commitmenthasimage) {
						    print "<a href=$CMSImagePath/commitmentfinalimage$commitmentid$cimageextension target=imagewin>Click here for document image</a>. Select a different image if necessary.<br>\n";
						    print "<input type=hidden name=oldimage value=-1>\n";
						}
						else {
						    print "<input type=hidden name=oldimage value=0>\n";
						}
						print "<input type=file name=image size=50 maxlength=256></td></tr>\n";
						print "<input name=commitmenthasimage type=hidden value=0>\n";
					    }
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
	print "<tr><td><hr width=70%></td></tr>\n";
        $activity = "Display remarks";
	print writeComment (active => 1);
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
    print "</table><center>\n";
    print "<input type=button name=submitupdate value=\"Submit Update\" title=\"Post Commitment Update\" onClick=\"update_commitment_table($statusid);\">\n";
    print "</center></td></tr></table></form><br><br><br><br></body></html>\n";    &oncs_disconnect ($dbh);
    exit 1;
}  #### endif commitmentupdate  ####

############################################
if ($cgiaction eq "updatecommitmenttable") {
############################################
    no strict 'refs';
    
    my $commitmentid = $cmscgi -> param ('commitmentid');
    my $statusid = $cmscgi -> param ('statusid');
    my $ctext = $cmscgi -> param ('commitmenttext');
    my $stext = ($ctext) ? ":ctext" : "NULL";
    my $estimate = $cmscgi -> param ('estimate');
    my $sestimate = ($estimate) ? ":est" : "NULL";
    my $dlrecommend = $cmscgi -> param ('functionalrecommend');
    my $sdlrecommend = ($dlrecommend) ? ":dlrec" : "NULL";
    my $comments = $cmscgi -> param ('commenttext');
    my $scomments = ($comments) ? ":remark" : "NULL";
    my $actionsummary = $cmscgi -> param ('actionsummary');
    my $sactionsummary = ($actionsummary) ? ":asummary" : "NULL";
    my $actionplan = $cmscgi -> param ('actionplan');
    my $sactionplan = ($actionplan) ? ":aplan" : "NULL";
    my $cmrecommend = $cmscgi -> param ('cmrecommendation');
    my $scmrecommend = ($cmrecommend) ? ":cmrec" : "NULL";
    my $wbs = $cmscgi -> param ('workbreakdownstructure');
    my $wbstr = (($wbs ne "NULL") && (defined($wbs))) ? "'$wbs'" : "NULL";
    my $issueid = $cmscgi -> param ('issueid');
    my $cmaker = $cmscgi -> param ('approvedby');
    $cmaker = (defined($cmaker)) ? $cmaker : "NULL";
    my $commitmentlevelid = $cmscgi -> param ('commitmentlevelid');
    my $primarydiscipline = $cmscgi -> param ('discipline');
    my $actionstaken = $cmscgi -> param ('actionstaken');
    my $sataken = ($actionstaken) ? ":ataken" : "NULL";
    my $rejectionrationale = $cmscgi -> param ('rejectionrationale');
    my $srejrat = ($rejectionrationale) ? ":rejrat" : "NULL";
    my $olddate = $cmscgi -> param ('olddate');
    my $dateaccnum = $cmscgi -> param ('dateaccnum');
    my $datereason = $cmscgi -> param ('datereason');
    my $dateapprover = $cmscgi -> param ('dateapprover');
    my $duedate = $cmscgi -> param ('duedate');
    my $commitdate = $cmscgi -> param ('commitdate');
    my $closedate = $cmscgi -> param ('closedate');
    my $fulfilldate = $cmscgi -> param ('fulfilldate');
    my $oldfuldate = $cmscgi -> param ('oldfuldate');
    my $fuldateaccnum = $cmscgi -> param ('fuldateaccnum');
    my $fuldatereason = $cmscgi -> param ('fuldatereason');
    my $fuldateapprover = $cmscgi -> param ('fuldateapprover');
    my $dl = $cmscgi -> param ('disciplinelead');
    my $externalid = $cmscgi -> param ('externalid');
    my $rm = $cmscgi -> param ('BSCresponsiblemanager');
    my $doerm = $cmscgi -> param ('DOEresponsiblemanager');
    my $nrcdate = $cmscgi -> param ('nrcdate');
    my $oldnrcdate = $cmscgi -> param ('oldnrcdate');
    my $nrcdateaccnum = $cmscgi -> param ('nrcdateaccnum');
    my $nrcdatereason = $cmscgi -> param ('nrcdatereason');
    my $nrcdateapprover = $cmscgi -> param ('nrcdateapprover');

    my $commitmenthasimage = $cmscgi -> param ('commitmenthasimage');
    my $imagefile = $cmscgi -> param ('image');
    my $imageextension = '';
    my $imagemimetype = '';
    my $imageinsertstring;
    my $isnewimage = 0;  # false
    my $imagesize = 0;
    my $imagedata = '';

    ####  process image file
    if (($imagefile) && ($commitmenthasimage == 0)) {
	my $bytesread = 0;
	my $buffer = '';
	####  read a 16 K chunk and append the data to the variable $filedata
	while ($bytesread = read($imagefile, $buffer, 16384)) {
	    $imagedata .= $buffer;
	    $imagesize += $bytesread;
	}
	$imagemimetype = $cmscgi->uploadInfo($imagefile)->{'Content-Type'};
	$imagemimetype =~ s/\'/\'\'/g;
	$imagemimetype = "'$imagemimetype'";
	$imagefile =~ /.*\\.*(\..*)/;
	$imageextension = "'" . $1 . "'";
	$imageinsertstring = ":imgblob";
    }
    else {
	$imagemimetype = 'NULL';
	$imageextension = 'NULL';
	$imageinsertstring = 'NULL';
    }
    my $imageupdate = "update $SCHEMA.commitment set closingdocimage = :imgblob, imageextension = $imageextension, imagecontenttype = $imagemimetype where commitmentid = $commitmentid";
    
    my $dueupdate = "insert into $SCHEMA.duedatehistory (oldduedate, newduedate, commitmentid, approvalletteraccession, reason, approver, datetype) values (to_date('$olddate', 'MM/DD/YYYY'), to_date ('$duedate', 'MM/DD/YYYY'), $commitmentid, '$dateaccnum', :reason, $dateapprover, 1)";
    my $fulfillupdate = "insert into $SCHEMA.duedatehistory (oldduedate, newduedate, commitmentid, approvalletteraccession, reason, approver, datetype) values (to_date('$oldfuldate', 'MM/DD/YYYY'), to_date ('$fulfilldate', 'MM/DD/YYYY'), $commitmentid, '$fuldateaccnum', :fulreason, $fuldateapprover, 2)";
    my $nrcupdate = "insert into $SCHEMA.duedatehistory (oldduedate, newduedate, commitmentid, approvalletteraccession, reason, approver, datetype) values (to_date('$oldnrcdate', 'MM/DD/YYYY'), to_date ('$nrcdate', 'MM/DD/YYYY'), $commitmentid, '$nrcdateaccnum', :nrcreason, $nrcdateapprover, 2)";
    my $sqlupdate = "update $SCHEMA.commitment  set text = $stext, ";
    if ($statusid > 1) {
	$doerm = ($doerm) ? $doerm : "NULL";
	$sqlupdate .= "externalid = '$externalid', primarydiscipline = $primarydiscipline, commitmentlevelid = $commitmentlevelid, duedate = to_date ('$duedate', 'MM/DD/YYYY'), lleadid=$dl, managerid = $rm, doemanagerid = $doerm, ";
	if ($statusid > 2) {
	    $sqlupdate .= "controlaccountid = $wbstr, estimate = $sestimate, actionplan = $sactionplan, fulfilldate = to_date('$fulfilldate','MM/DD/YYYY'), ";
	    if ($statusid > 3) {
		$sqlupdate .= "functionalrecommend = $sdlrecommend, actionsummary = $sactionsummary, ";
		if ($statusid > 4) {
		    $sqlupdate .= "cmrecommendation = $scmrecommend, approver = $cmaker, ";
		    if ($statusid > 5) {
			$sqlupdate .= "commitdate = to_date ('$commitdate', 'MM/DD/YYYY'), ";
			if ($statusid == 8) {
			    $sqlupdate .= "rejectionrationale = $srejrat, ";
			}
			if ($statusid > 8) {
                            if ($nrcdate ne "00/00/0000") {
                                $sqlupdate .= "dateduetonrc = to_date ('$nrcdate','MM/DD/YYYY'), ";
			    }
			    if ($statusid > 10 && $statusid < 17) {
				$sqlupdate .= "actionstaken = $sataken, ";
				if ($statusid > 14) {
				    $sqlupdate .= "closeddate = to_date ('$closedate', 'MM/DD/YYYY'), ";
				}
			    }
			}
		    }
		}
	    }
	}
    }
    $sqlupdate .= "updatedby = $usersid where commitmentid = $commitmentid";
#    print STDERR "$sqlupdate\n";
    my $activity;
    eval {
	$activity = "Update Commitment Information: $commitmentid";
	my $csr = $dbh->prepare($sqlupdate);
	if ($ctext) {
	    $csr->bind_param(":ctext", $ctext, {ora_type => ORA_CLOB, ora_field => 'text' });
	}
	if ($estimate) {
	    $csr->bind_param(":est", $estimate, {ora_type => ORA_CLOB, ora_field => 'estimate' });
	}
	if ($dlrecommend) {
	    $csr->bind_param(":dlrec", $dlrecommend, {ora_type => ORA_CLOB, ora_field => 'functionalrecommend' });
	}
	if ($actionsummary) {
	    $csr->bind_param(":asummary", $actionsummary, {ora_type => ORA_CLOB, ora_field => 'actionsummary' });
	}
	if ($actionplan) {
	    $csr->bind_param(":aplan", $actionplan, {ora_type => ORA_CLOB, ora_field => 'actionplan' });
	}
	if ($cmrecommend) {
	    $csr->bind_param(":cmrec", $cmrecommend, {ora_type => ORA_CLOB, ora_field => 'cmrecommendation' });
	}
	if ($actionstaken) {
	    $csr -> bind_param (":ataken", $actionstaken, {ora_type => ORA_CLOB, ora_field => 'actionstaken'});
	}
	if ($rejectionrationale) {
	    $csr -> bind_param (":rejrat", $rejectionrationale, {ora_type => ORA_CLOB, ora_field => 'rejectionrationale'});
	}
	$csr->execute;
	
	if ($imagefile) {
	    $activity = "Insert image in commitment record for commitment $commitmentid";
	    $csr = $dbh->prepare($imageupdate);
	    $csr->bind_param(":imgblob", $imagedata, {ora_type => ORA_BLOB, ora_field => 'closingdocimage' });
	    $csr->execute;
	}
	if ($statusid < 3) {
	    $activity = "Update Commitment Leads";
	    my ($newdoe) = $dbh -> selectrow_array ("select usersid from $SCHEMA.defaultdisciplinerole where disciplineid=$primarydiscipline and roleid=3 $nodevelopers"); 
	    my $moupdate = "update $SCHEMA.commitmentrole set usersid=$dl where commitmentid=$commitmentid and roleid=2";
	    $csr = $dbh -> prepare ($moupdate);
	    $csr -> execute;
	    my $doeupdate = "update $SCHEMA.commitmentrole set usersid=$newdoe where commitmentid=$commitmentid and roleid=3";
	    $csr = $dbh -> prepare ($doeupdate);
	    $csr -> execute;
	}
	my $remarkupdate = "insert into $SCHEMA.commitment_remarks (usersid, text, dateentered, commitmentid) values ($usersid, :remarks, SYSDATE, $commitmentid)";
        # update commitment remarks
	if ($comments) {
	    $activity = "Update remarks for commitment $commitmentid";
	    $csr = $dbh -> prepare ($remarkupdate);
	    $csr -> bind_param (":remarks", $comments, {ora_type => ORA_CLOB, ora_field => 'text'});
	    $csr -> execute;
	}	
        # update committed to records.
	if ($statusid > 6) {
	    my $dualhistory = $cmscgi->param('orghist');
	    $dualhistory =~ s/\s+//;
	    $activity = "Update organizations committed to for commitment: $commitmentid";
	    while (my $histitem = substr($dualhistory, 0, index($dualhistory, ';'))) {
		my $committedorgsqlstring;
		$dualhistory = substr($dualhistory, (index($dualhistory, ';') + 1));
		if ($histitem =~ /committedto/i) {
		    $activity .= " adding organization: " . substr($histitem, 0, index($histitem, '-->')) . ".";
		    $committedorgsqlstring = "INSERT INTO $SCHEMA.committedorg (commitmentid,organizationid) VALUES ($commitmentid, " . substr($histitem, 0, index($histitem, '-->')) . ")";
		}
		else {
		    $activity .= " removing organization: " . substr($histitem, 0, index($histitem, '-->')) . ".";
		    $committedorgsqlstring = "DELETE $SCHEMA.committedorg WHERE (commitmentid = $commitmentid) AND (organizationid = " . substr($histitem, 0, index($histitem, '-->')) . ")";
		}
		#print "$committedorgsqlstring<br>\n";
		$csr = $dbh->prepare($committedorgsqlstring);
		$csr->execute;
	    }
	}
	if ($statusid > 3) {
	    # update products affected records.
	    my $dualhistory = $cmscgi->param('prodhist');
	    $dualhistory =~ s/\s+//;
	    $activity = "Update products affected for commitment: $commitmentid";
	    while (my $histitem = substr($dualhistory, 0, index($dualhistory, ';'))) {
		my $prodsqlstring;
		$dualhistory = substr($dualhistory, (index($dualhistory, ';') + 1));
		if ($histitem =~ /productsaffected/i) {
		    $activity .= " adding affected product: " . substr($histitem, 0, index($histitem, '-->')) . ".";
		    $prodsqlstring = "INSERT INTO $SCHEMA.productaffected (commitmentid, productid) VALUES ($commitmentid, " . substr($histitem, 0, index($histitem, '-->')) . ")";
		}
		else {
		    $activity .= " removing affected product: " . substr($histitem, 0, index($histitem, '-->')) . ".";
		    $prodsqlstring = "DELETE $SCHEMA.productaffected WHERE (commitmentid = $commitmentid) AND (productid = " . substr($histitem, 0, index($histitem, '-->')) . ")";
		}
		#print "$prodsqlstring<br>\n";
		$csr = $dbh->prepare($prodsqlstring);
		$csr->execute;
	    }
	}
	#add keywords to record(s)
        my $oldkeywords = "delete from $SCHEMA.commitmentkeyword where commitmentid=$commitmentid";
	my $oldcsr = $dbh -> prepare ($oldkeywords);
	$oldcsr -> execute;
	my $keywordid;
	foreach $keywordid ($cmscgi->param('keywords')) {
	    if (($keywordid ne '')) {
		$activity = "Insert keyword $keywordid for commitment $commitmentid.";
		my $keywordstring = "INSERT INTO $SCHEMA.commitmentkeyword (commitmentid, keywordid) VALUES($commitmentid, $keywordid)";
		$csr = $dbh->prepare($keywordstring);
		$csr->execute;
	    }
	}	
        #update due date history
	if ($olddate && ($olddate ne $duedate)) {
	    $activity = "Insert new due date for commitment $commitmentid in table DUEDATEHISTORY.";
	    $csr = $dbh -> prepare ($dueupdate);
	    $csr -> bind_param (":reason", $datereason, {ora_type => ORA_CLOB, ora_field => 'reason'});
	    $csr -> execute;
	}
	if ($oldfuldate && ($oldfuldate ne $fulfilldate)) {
	    $activity = "Insert new fulfillment date for commitment $commitmentid in table DUEDATEHISTORY.";
	    $csr = $dbh -> prepare ($fulfillupdate);
	    $csr -> bind_param (":fulreason", $fuldatereason, {ora_type => ORA_CLOB, ora_field => 'reason'});
	    $csr -> execute;
	}
	if ($oldnrcdate && ($oldnrcdate ne $nrcdate)) {
	    $activity = "Insert new date due to NRC for commitment $commitmentid in table DUEDATEHISTORY.";
	    $csr = $dbh -> prepare ($nrcupdate);
	    $csr -> bind_param (":nrcreason", $nrcdatereason, {ora_type => ORA_CLOB, ora_field => 'reason'});
	    $csr -> execute;
	}
	$csr -> finish;
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
	&log_activity ($dbh, 'F', $usersid, "Commitment ".&formatID2($commitmentid, 'C')." updated by user $username");
	print <<pageresults;
	<script language="JavaScript" type="text/javascript">
	<!--
        parent.workspace.location="$ONCSCGIDir/commitmentupdate.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
    }
    &oncs_disconnect($dbh);
    exit 1;
} ####  endif updatecommitmenttable  ####

print "<br><br><br><br></body></html>\n";
&oncs_disconnect($dbh);
