#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# CMS DOE Commitment Manager first response entry (commitment letter)
#
# $Source: /data/dev/rcs/cms/perl/RCS/DOECMgr_firstresponse.pl,v $
# $Revision: 1.52 $
# $Date: 2003/01/21 20:20:15 $
# $Author: naydenoa $
# $Locker:  $
# $Log: DOECMgr_firstresponse.pl,v $
# Revision 1.52  2003/01/21 20:20:15  naydenoa
# Renamed date due to NRC to date due to originator
# Made date due to originator optional
# CREQ00024 - rework
#
# Revision 1.51  2003/01/02 22:42:46  naydenoa
# Added "Date Due To NRC" to display and processing
#
# Revision 1.50  2001/11/15 21:23:53  naydenoa
# Added action display to commitment info; updated email notification
# and status to reflect actions.
#
# Revision 1.49  2001/05/05 00:08:16  naydenoa
# Updated evals
#
# Revision 1.48  2001/05/02 22:18:21  naydenoa
# Modified evals, calls to Edit_Screens
#
# Revision 1.47  2001/01/02 17:25:47  naydenoa
# More code clean-up
# Moved letter fill-out to Edit_Screens module
#
# Revision 1.46  2000/12/19 18:54:20  naydenoa
# Code cleanup
#
# Revision 1.45  2000/12/07 18:54:22  naydenoa
# Code cleanup, moved response handling to Edit_Screens.pm
#
# Revision 1.44  2000/11/20 19:38:25  naydenoa
# Moved some redundant code to Edit_Screens module
#
# Revision 1.43  2000/11/07 23:22:48  naydenoa
# Added email notification
# Added issue source display
# Took out rationales (except for rejection rationale)
#
# Revision 1.42  2000/10/31 19:40:32  naydenoa
# Updated function calls to Edit_Screens
# Took out commitment and approval rationales
#
# Revision 1.41  2000/10/26 19:31:43  naydenoa
# Added remark display
# Changed table width to 650, textarea width to 75
#
# Revision 1.40  2000/10/24 19:30:03  naydenoa
# Updated call to Edit_Screens
#
# Revision 1.39  2000/10/18 21:27:13  munroeb
# modified activity log message
#
# Revision 1.38  2000/10/17 17:00:30  naydenoa
# Took out log_history call, fixed rejection image bug, checkpoint.
#
# Revision 1.37  2000/10/06 17:13:36  munroeb
# added log_activity feature to script
#
# Revision 1.36  2000/10/03 20:40:56  naydenoa
# Updates status id's and references.
#
# Revision 1.35  2000/09/29 21:09:17  naydenoa
# Updated pick lists to include/exclude developers in dev/prod schema;
# changed references to roles and statuses (now by ID)
#
# Revision 1.34  2000/09/28 22:13:08  atchleyb
# added names to insert
#
# Revision 1.33  2000/09/28 20:05:30  naydenoa
# Checkpoint after Version 2 release
#
# Revision 1.32  2000/09/11 22:40:05  naydenoa
# Changed links to point to new home.
#
# Revision 1.31  2000/09/08 23:47:46  naydenoa
#  More interface modifications.
#
# Revision 1.30  2000/09/05 18:33:12  naydenoa
# Corrected read-only/writable conditions for text areas.
#
# Revision 1.29  2000/09/01 23:49:25  naydenoa
# Major update of interface. Added use of module Edit_Screens, which
# draws most fields.
#
# Revision 1.28  2000/08/25 16:18:57  atchleyb
# changed Technical Lead to Discipline Lead
#
# Revision 1.27  2000/08/22 20:22:09  atchleyb
# replaced $ONCSimagepath with $CMSImagePath and $CMSFullImagePath
#
# Revision 1.26  2000/08/21 22:21:10  atchleyb
# fixed var name bug
#
# Revision 1.25  2000/08/21 20:21:25  atchleyb
# fixed var name bug
#
# Revision 1.24  2000/08/21 18:19:07  atchleyb
# added check schema line
# changed cirscgi to cmscgi
#
# Revision 1.23  2000/07/24 15:04:44  johnsonc
# Inserted GIF file for display.
#
# Revision 1.22  2000/07/17 17:21:38  atchleyb
# placed forms in a table of width 750
#
# Revision 1.21  2000/07/11 15:00:33  munroeb
# finished modifying html formatting
#
# Revision 1.20  2000/07/06 23:21:53  munroeb
# finished mods to html and javascripts.
#
# Revision 1.19  2000/07/05 22:36:05  munroeb
# made minor tweaks to html and javascripts
#
# Revision 1.18  2000/06/21 22:00:32  johnsonc
# Editted opening page select object to support double click event.
#
# Revision 1.17  2000/06/16 15:46:44  johnsonc
#  Revise WSB table entry to be optional display in edit and query screens
#
# Revision 1.16  2000/06/15 21:32:24  zepedaj
# Changed code to allow Commitment Maker Approval Rationale optional,
# while keeping Rejection Rationale Mandatory
#
# Revision 1.15  2000/06/15 18:31:58  johnsonc
# Revise table columns to be uniform in width
#
# Revision 1.14  2000/06/13 21:41:04  zepedaj
# Fixed width of tables so the columns would be the same
#
# Revision 1.13  2000/06/13 19:24:55  johnsonc
# Change 'Rationale For Commitment' field to display only when data is present
#
# Revision 1.12  2000/06/13 15:27:35  johnsonc
# Editted commitments select object to a fixed width.
#
# Revision 1.11  2000/06/12 15:44:38  johnsonc
#  Add 'C' in front of commitment ID and 'I' in front of issue ID.
# Add 'proposed' to edit and view commitment page titles.
#
# Revision 1.10  2000/06/09 20:13:52  johnsonc
# Edit secondary discipline text area to display only when it contains data
#
# Revision 1.9  2000/06/08 18:37:51  johnsonc
# Install commitment comment text box.
#
# Revision 1.8  2000/05/19 23:45:30  zepedaj
# Changed code for the final WBS structure
#
# Revision 1.7  2000/05/18 23:10:48  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.6  2000/05/17 22:10:01  zepedaj
# Modified code so that it wouldn't try to obtain a new letter id number if the letter already existed.
#
# Revision 1.5  2000/05/17 18:29:30  zepedaj
# Added a command to clear the letter entries before allowing entry if "New Letter" is selected.
#
# Revision 1.4  2000/05/16 18:55:54  zepedaj
# Updated comments to reflect the purpose of this script
#
# Revision 1.3  2000/05/15 22:03:05  zepedaj
# Replaced popup text on pass-on button to reflect the current status of the commitment.
#
# Revision 1.2  2000/05/12 19:03:02  zepedaj
# Added Organzations Committed to on display and edit screens
#
# Revision 1.1  2000/05/11 20:54:28  zepedaj
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

my $pagetitle = "First Response to the Commitment";
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
print "<title>$pagetitle</title>\n\n";

print "<!-- include external javascript code -->\n";
print "<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>\n";
print "<script type=\"text/javascript\">\n";
print "<!--\n";
print "var dosubmit = true;\n";
print "if (parent == self) {  // not in frames\n";
print "    location = \'$ONCSCGIDir/login.pl\'\n";
print "}\n";
print "//-->\n";
print "</script>\n";

my $dbh = oncs_connect(); # connect to the oracle DB and generate a DB handle
# find the Role ID and Status ID for the Commitment Maker Review
my $DOECMgr_Roleid = 4; # DOE Commitment Manager
my $DOECMgr_approved_statusid = 6; # Approval Letter/First Response
my $DOECMgr_rejected_statusid = 7; # Disapproval/Rejection Letter

#####################################
if ($cgiaction eq "fillout_letter") {
#####################################
    #control variables
    my $letterid = $cmscgi->param('letterid');
    
    print fillLetter(dbh => $dbh, letterid => $letterid);
    &oncs_disconnect($dbh);
    exit 1;
}  ################  endif fillout_letter  ##################

#####################################
if ($cgiaction eq "editcommitment") {
#####################################
    my $activity;
    my $commitmentid = $cmscgi->param('commitmentid');
    my $textareawidth = 75;
    my $commitmentidstring = substr("0000$commitmentid", -5);
    my %commitmenthash;
    my %letterinfo;
    
    eval {
	$activity = "Get info for commitment $commitmentid and associated response letter";
	%commitmenthash = get_commitment_info($dbh, $commitmentid);
	%letterinfo = lookup_response_information($dbh, $commitmentid);
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
    my $statusid = $commitmenthash{'statusid'};
    my $nrcdate = $commitmenthash{'dateduetonrc'};
    
    # the following commitment variables may not be available (they are added by this script)
    my $imagecontenttype = $commitmenthash{'imagecontenttype'};
    my $imageextension = $commitmenthash{'imageextension'};
    
    # the following response/letter variables may not be available (they are added by this script)
    my $responseid = $letterinfo{'responseid'};
    my $responsetext = $letterinfo{'text'};
    my $responsewrittendate = $letterinfo{'writtendate'};
    my $letterid = $letterinfo{'letterid'};
    my $letteraccessionnum = $letterinfo{'accessionnum'};
    my $lettersentdate = $letterinfo{'sentdate'};
    my $letteraddressee = $letterinfo{'addressee'};
    my $lettersigneddate = $letterinfo{'signeddate'};
    my $letterorganizationid = $letterinfo{'organizationid'};
    my $lettersigner = $letterinfo{'signer'};
    
    #booleans
    my $commitmentisrejected = ($statusid == $DOECMgr_rejected_statusid);
    my $commitmenthasfinalimage = (defined($imageextension) && ($imageextension ne ""));
    my $commitmenthasresponse = (defined($responseid) && ($responseid ne ""));
    
    if (! $commitmenthasresponse) {
	$responsetext = $text;
    }
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    if ($commitmentisrejected){
	print "doSetTextImageLabel(\'Response to Rejected Commitment\');\n";
    }
    else {
	print "doSetTextImageLabel(\'First Response to Commitment\');\n";
    }
    print "//-->\n";
    print "</script>\n";
    
    my $key;
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);
    
    my $flag = 0; # approved(0) or rejected(-1)
    
    $dbh->{LongTruncOk} = 0;
    
    print <<committable;
    <script language="JavaScript" type="text/javascript">
    <!--
    function clearletter() {
	document.editcommitment.letteraccessionnum.value = "";
	document.editcommitment.lettersigner.value = "";
	document.editcommitment.letteraddressee.value = "";
	document.editcommitment.letterorganizationid.value = "";
    }
    function disableletter() {
	document.editcommitment.letteraccessionnum.disabled = true;
	document.editcommitment.lettersigner.disabled = true;
	document.editcommitment.lettersigneddate_month.disabled = true;
	document.editcommitment.lettersigneddate_day.disabled = true;
	document.editcommitment.lettersigneddate_year.disabled = true;
	document.editcommitment.lettersentdate_month.disabled = true;
	document.editcommitment.lettersentdate_day.disabled = true;
	document.editcommitment.lettersentdate_year.disabled = true;
	document.editcommitment.letteraddressee.disabled = true;
	document.editcommitment.letterorganizationid.disabled = true;
    }
    function enableletter() {
	document.editcommitment.letteraccessionnum.disabled = false;
	document.editcommitment.lettersigner.disabled = false;
	document.editcommitment.lettersigneddate_month.disabled = false;
	document.editcommitment.lettersigneddate_day.disabled = false;
	document.editcommitment.lettersigneddate_year.disabled = false;
	document.editcommitment.lettersentdate_month.disabled = false;
	document.editcommitment.lettersentdate_day.disabled = false;
	document.editcommitment.lettersentdate_year.disabled = false;
	document.editcommitment.letteraddressee.disabled = false;
	document.editcommitment.letterorganizationid.disabled = false;
    }
    function checkletter (letterselection) {
	if (letterselection.value!="NEW") {
	    if (letterselection.value != '') {
		clearletter();
		disableletter();
		fillout_letter();
	    }
	    else {
		clearletter();
		disableletter();
	    }
	}
	else {
	    clearletter();
	    enableletter();
	}
    }
    function validate_commitment_data(flag) {
	var msg = "";
	var tmpmsg = "";
	var returnvalue = true;
	var validateform = document.editcommitment;
	if (validateform.commitmentisrejected.value != 0) {
	    msg += (validateform.finaldocumentimage.value=="") ? "You must enter the image for the rejection letter.\\n" : "";
        }
	if (flag != -1) {
	    msg += (validateform.committedto.selectedIndex == -1) ? "You must select the organization(s) the commitment was made to.\\n" : "";
	    if (validateform.nrcdate_year.value != "" || validateform.nrcdate_month.value != "" || validateform.nrcdate_day.value != "") {
		msg += ((tmpmsg = validate_date(validateform.nrcdate_year.value, validateform.nrcdate_month.value, validateform.nrcdate_day.value, 0, 0, 0, 0, true, true, false)) == "") ? "" : "Date Due To NRC - " + tmpmsg + "\\n";
	    }
 	}
	msg += (validateform.responsetext.value=="") ? "You must enter the text of the letter that makes the commitment.\\n" : "";
	msg += ((tmpmsg = validate_date(validateform.responsewrittendate_year.value, validateform.responsewrittendate_month.value, validateform.responsewrittendate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Date Response Was Written - " + tmpmsg + "\\n";
	if (validateform.letterid.value=="NEW") {
	    msg += ((tmpmsg = validate_accession_number(validateform.letteraccessionnum.value,true)) == "") ? "" : "Letter Accession Number - " + tmpmsg + "\\n";
	    msg += ((tmpmsg = validate_date(validateform.lettersentdate_year.value, validateform.lettersentdate_month.value, validateform.lettersentdate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Letter Sent Date - " + tmpmsg + "\\n";
	    msg += (validateform.letteraddressee.value=="") ? "You must enter the addressee of the letter.\\n" : "";
	    msg += ((tmpmsg = validate_date(validateform.lettersigneddate_year.value, validateform.lettersigneddate_month.value, validateform.lettersigneddate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Letter Signed Date - " + tmpmsg + "\\n";
	    msg += (validateform.lettersigner.value=="") ? "You must select the signer of the letter.\\n" : "";
        msg += (validateform.letterorganizationid.value=='') ? "You must select the organization the letter was sent to.\\n" : "";
	}
	else if(validateform.letterid.value=='') {
	    msg += "You must enter the letter information for this response.\\n";
    }
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
	msg += (validateform.responsetext.value=="") ? "You must enter the text of the letter that makes the commitment.\\n" : "";
    msg += ((tmpmsg = validate_date(validateform.responsewrittendate_year.value, validateform.responsewrittendate_month.value, validateform.responsewrittendate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Date Response Was Written - " + tmpmsg + "\\n";
	if (validateform.letterid.value=="NEW") {
	    msg += ((tmpmsg = validate_accession_number(validateform.letteraccessionnum.value,true)) == "") ? "" : "Letter Accession Number - " + tmpmsg + "\\n";
	    msg += ((tmpmsg = validate_date(validateform.lettersentdate_year.value, validateform.lettersentdate_month.value, validateform.lettersentdate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Letter Sent Date - " + tmpmsg + "\\n";
	    msg += (validateform.letteraddressee.value=="") ? "You must enter the addressee of the letter.\\n" : "";
	    msg += ((tmpmsg = validate_date(validateform.lettersigneddate_year.value, validateform.lettersigneddate_month.value, validateform.lettersigneddate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Letter Signed Date - " + tmpmsg + "\\n";
	    msg += (validateform.lettersigner.value=="") ? "You must select the signer of the letter.\\n" : "";
	    msg += (validateform.letterorganizationid.value=='') ? "You must select the organization the letter was sent to.\\n" : "";
        }
	else if(validateform.letterid.value=='') {
	    msg += "You must enter the letter information for this response.\\n";
        }
	if (msg != "") {
	    alert(msg);
	    returnvalue = false;
        }
	if (returnvalue) {
	    document.editcommitment.submit();
	}
	return (returnvalue);
    }
committable
    print "function pass_on(flag) {\n";
    print "    var tempcgiaction;\n";
    print "    var returnvalue = true;\n";
    print "    if (flag != -1) {\n";
    print "        selectemall(document.editcommitment.committedto);\n";
    print "    }\n";
    print "    if (validate_commitment_data(flag)) {\n";
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
    print "function fillout_letter() {\n";
    print "    var validateform = document.editcommitment;\n";
    print "    var tempcgiaction;\n";
    print "    tempcgiaction = document.editcommitment.cgiaction.value;\n";
    print "    document.editcommitment.cgiaction.value = \"fillout_letter\";\n";
    print "    document.editcommitment.submit();\n";
    print "    document.editcommitment.cgiaction.value = tempcgiaction;\n";
    print "    return (true);\n";
    print "}\n";
    print "//-->\n";
    print "</script>\n";
    print "</head>\n";
    print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<table border=0 align=center width=650><tr><td>\n";
    print "<form name=editcommitment enctype=\"multipart/form-data\" method=post target=\"control\" action=\"$ONCSCGIDir/DOECMgr_firstresponse.pl\">\n";
    print "<input name=cgiaction type=hidden value=\"save_commitment\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=commitmentid type=hidden value=$commitmentid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    print "<table summary=\"Enter Commitment Table\" width=650 border=0 align=center cellspacing=10>\n";
    eval {
	$activity = "Do prior work tables for commitment $commitmentid";
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

	# if there is an image, retrieve it for display;
	if ($commitmenthasfinalimage) {
	    my $image = $CMSFullImagePath . "/commitmentfinalimage$commitmentid$imageextension";
	    if (open (OUTFILE, "| ./File_Utilities.pl --command writeFile --protection 0664 --fullFilePath $image")) {
		print OUTFILE get_final_image($dbh, $commitmentid);
		close OUTFILE;
	    }
	    else {
		print "could not open file $image<br>\n";
	    }
	}
	if ($commitmenthasfinalimage && $commitmentisrejected) {
	    $flag = -1;
	    print "<tr><td align=left><b><li>Closure Document Image</b>&nbsp;&nbsp;\n";
	    print "<a href='$CMSImagePath/commitmentfinalimage$commitmentid$imageextension' target=imagewin>Click for the image file</a>\n";
	    if ($commitmentisrejected) {
		print "<input type=hidden name=commitmentisrejected value=1>\n";
		print "<input type=file name=finaldocumentimage size=50 maxlength=256>\n";
		print "<br>\n";
		print "(Select a different image if necessary)\n";
	    }
	    else {
		print "<input type=hidden name=commitmentisrejected value=0>\n";
		print "<input type=hidden name=finaldocumentimage value=''>\n";
	    }
	    print "</td>\n";
	    print "</tr>\n";
	}
	elsif ($commitmentisrejected) {
	    $flag = -1;
	    print "<tr><td align=left><b><li>Rejection Document Image:</b><br>\n";
	    print "<input type=hidden name=commitmentisrejected value=1>\n";
	    print "<input type=file name=finaldocumentimage size=50 maxlength=256></td></tr>\n";
	}
	else { # No image, not rejected
	    print "<tr><td><li><b>Date Due To Originator:&nbsp;&nbsp;</b>";
	    my $defaultdate = ($nrcdate) ? $nrcdate : 'blank';
	    print build_date_selection('nrcdate', 'editcommitment', $defaultdate);
	    print "&nbsp;&nbsp;(optional)</td></tr>\n";
	    print selectOrganizations (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
	    print "    <input type=hidden name=commitmentisrejected value=0>\n";
	    print "    <input type=hidden name=finaldocumentimage value=''>\n";
	}
	print "</table><hr width=70% align=center>\n";
	
	#### Response Table ####
	my $rtype = ($commitmentisrejected) ? "Rejection" : "First Response";
	print "<br><h3 align=center>Response Letter Information</h3>\n";
	$activity = "Display response fields";
	print writeResponse (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA, rtype => $rtype, responseid => $responseid, statusid => $statusid, siteid => $siteid);
	print "</td></tr>\n";
	print "</table></td></tr>\n";
	print "<tr><td><hr width=70%></td></tr>\n";
	print "</table></td></tr>\n";
	print "<tr><td>\n";
	print "<script language=\"JavaScript\" type=\"text/javascript\"><!--\n";
	print "disableletter();\n";
	print "//-->\n";
	print "</script>\n";
	print "<table width=650 align=center>\n";
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
    print "<br><center>\n";
    print "<input type=button name=savecommitment value=\"Save Draft Work\" title=\"Save Commitment, can be edited later\" onclick=\"return(save_commitment())\">\n";
    print "<input type=button name=saveandcomplete value=\"Save and Pass On\" title=\"Save Commitment and pass on to BSC Lead for Fulfillment or submit rejection letter\" onclick=\"return(pass_on($flag))\"></center>\n";
    print "</form> \n</td></tr></table> \n<br><br><br>\n";
    print "</body> \n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
}  ####  endif editcommitment  ####

#####################################
if ($cgiaction eq "save_commitment"){
#####################################
    no strict 'refs';
	
    my $commitmentid = $cmscgi->param('commitmentid');
    my $nrcdate = $cmscgi -> param ('nrcdate');
    my $activity;
    my $commitmentcomment;
    
    # boolean variables, should be 0 or -1 (false/true)
    my $commitmenthasresponse = ($cmscgi->param('commitmenthasresponse') == 1) ? -1 : 0;
    my $commitmentisrejected = ($cmscgi->param('commitmentisrejected') == 1) ? -1 : 0;
    my $commitmenthascomment = (defined($commitmentcomment) && ($commitmentcomment ne ""));
    
    # commitment variables
    my $finaldocumentimagefile;
    my $imagecontenttype;
    my $imageextension;
    my $imagesize;
    my $imagedata;
    my $imageinsertstring;
    if ($commitmentisrejected) {
	$finaldocumentimagefile = $cmscgi->param('finaldocumentimage');
    }
    my $comments = $cmscgi->param('commenttext');
    
    #boolean based on final document image
    my $hasfinaldocument = ($finaldocumentimagefile) ? -1 : 0;
    
    # response variables
    my $responseid = ($commitmenthasresponse) ? $cmscgi->param('responseid') : get_next_id($dbh, 'response');
    my $responsetext = $cmscgi->param('responsetext');
    my $responsetextsql = ($responsetext) ? ":responsetextclob" : "NULL";
    my $responsewrittendate = $cmscgi->param('responsewrittendate');
    $responsewrittendate = ($responsewrittendate eq "") ? "NULL" : "TO_DATE('$responsewrittendate', 'MM/DD/YYYY')";
    
    # letter variables
    my $letterid;
    my $letteraccessionnum;
    my $lettersentdate;
    my $letteraddressee;
    my $lettersigneddate;
    my $lettersigner;
    my $letterorganizationid;
    my $letterisnew;
    $letterid = $cmscgi->param('letterid');
    if (! $commitmenthasresponse) {
	$letterisnew = ($letterid eq 'NEW');
	$letterid = ($letterisnew) ? get_next_id($dbh, 'letter') : $letterid;
	$letteraccessionnum = $cmscgi->param('letteraccessionnum');
	$letteraccessionnum =~ s/\'/\'\'/g;
	$lettersentdate = $cmscgi->param('lettersentdate');
	$lettersentdate = ($lettersentdate eq "") ? "NULL" : "TO_DATE('$lettersentdate', 'MM/DD/YYYY')";
	$letteraddressee = $cmscgi->param('letteraddressee');
	$letteraddressee =~ s/\'/\'\'/g;
	$lettersigneddate = $cmscgi->param('lettersigneddate');
	$lettersigneddate = ($lettersigneddate eq "") ? "NULL" : "TO_DATE('$lettersigneddate', 'MM/DD/YYYY')";
	$lettersigner = $cmscgi->param('lettersigner');
	$letterorganizationid = $cmscgi->param('letterorganizationid');
    }
    
    #process image file
    if (($finaldocumentimagefile) && ($commitmentisrejected)) {
	my $bytesread = 0;
	my $buffer = '';
	# read a 16 K chunk and append the data to the variable $filedata
	while ($bytesread = read($finaldocumentimagefile, $buffer, 16384)) {
	    $imagedata .= $buffer;
	    $imagesize += $bytesread;
	}
	$imagecontenttype = $cmscgi->uploadInfo($finaldocumentimagefile)->{'Content-Type'};
	$imagecontenttype =~ s/\'/\'\'/g;
	$imagecontenttype = "'$imagecontenttype'";
	$finaldocumentimagefile =~ /.*\\.*(\..*)/;
	$imageextension = "'" . $1 . "'";
	$imageinsertstring = ":imgblob";
    }
    
    #sql strings
    my $lettersqlstring;
    my $responsesqlstring;
    my $commitmentupdatesql;
    
    if (($hasfinaldocument) && ($commitmentisrejected)) {
	$commitmentupdatesql = "UPDATE $SCHEMA.commitment
                                SET closingdocimage = $imageinsertstring,
                                    imagecontenttype = $imagecontenttype,
                                    imageextension = $imageextension,
                                    updatedby = $usersid
                                WHERE commitmentid = $commitmentid";
    }
    else {
	$nrcdate = ($nrcdate ne "00/00/0000") ? ", dateduetonrc = to_date('$nrcdate','MM/DD/YYYY') " : "";
	$commitmentupdatesql = "UPDATE $SCHEMA.commitment 
                                SET updatedby = $usersid
                                    $nrcdate
                                WHERE commitmentid = $commitmentid";
    }
    if ($commitmenthasresponse) {
	$responsesqlstring = "UPDATE $SCHEMA.response
                              SET text = $responsetextsql,
                                  writtendate = $responsewrittendate
                              WHERE responseid = $responseid";
    }
    else {
	$lettersqlstring = "INSERT INTO $SCHEMA.letter
                                   (letterid, accessionnum, sentdate, 
                                    addressee, signeddate,
                                    organizationid,signer)
                            VALUES ($letterid, '$letteraccessionnum',
                                    $lettersentdate, '$letteraddressee',
                                    $lettersigneddate, 
                                    $letterorganizationid,
                                    $lettersigner)";
	$responsesqlstring = "INSERT INTO $SCHEMA.response
                                     (responseid, text, writtendate,
                                      commitmentid,letterid)
                              VALUES ($responseid, $responsetextsql,
                                      $responsewrittendate,
                                      $commitmentid, $letterid)";
    }
    eval {
	my $csr;
	if (! $commitmenthasresponse) {
	    if ($letterisnew) {
		# Letter must be entered before response can be saved
		$activity = "Insert Letter";
		$csr = $dbh->prepare($lettersqlstring);
		print "<br><!-- $lettersqlstring --><br>\n";
		$csr->execute;
	    }
	    $activity = "Insert Response";
	}
	else {
	    $activity = "Update Response";
	}
	$csr = $dbh->prepare($responsesqlstring);
	$csr->bind_param(":responsetextclob", $responsetext, {ora_type => ORA_CLOB, ora_field => 'text'});
	print "<br><!-- $responsesqlstring --><br>\n";
	$csr->execute;
	
	if (($hasfinaldocument) && ($commitmentisrejected)) {
	    # If no image file is specified, this process won't run.
	    $activity = "Insert closing document image in commitment: $commitmentid";
	    $csr = $dbh->prepare($commitmentupdatesql);
	    $csr->bind_param(":imgblob", $imagedata, {ora_type => ORA_BLOB, ora_field => 'closingdocimage' });
	    $csr->execute;
	}
	else {
	    $activity = "Update Commitment";
	    $csr = $dbh->prepare($commitmentupdatesql);
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
	
	# update committed to records.
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
	    $csr = $dbh->prepare($committedorgsqlstring);
	    $csr->execute;
	}
	$csr->finish;
	$dbh->commit;
    };
    if ($@){
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'commitment', "$commitmentid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print <<pageerror;
	<script language="JavaScript" type="text/javascript">
        <!--
	alert("$alertstring");
	parent.control.location="$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageerror
    }
    else {
	&log_activity($dbh, 'F', $usersid, "Commitment ".&formatID2($commitmentid, 'C')." updated by the Commitment Manager, response ".formatID2($responseid, 'R')." and letter ".formatID2($letterid, 'L')." added/updated");
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
}  ################  endif commitment  ###################3

##############################
if ($cgiaction eq "pass_on") {
##############################
    no strict 'refs';
    
    #control variables
    my $commitmentid =  $cmscgi->param('commitmentid');
    my $nrcdate = $cmscgi -> param ('nrcdate');
    my $activity;
    
    # boolean variables, should be 0 or -1 (true/false)
    my $commitmenthasresponse = ($cmscgi->param('commitmenthasresponse') == 1) ? -1 : 0;
    my $commitmentisrejected = ($cmscgi->param('commitmentisrejected') == 1) ? -1 : 0;
    
    # Find pertinent user information
    # Site id of the user is the same for the commitment
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);
    
    # commitment variables
    my $finaldocumentimagefile;
    my $imagecontenttype;
    my $imageextension;
    my $imagesize;
    my $imagedata;
    my $imageinsertstring;
    if ($commitmentisrejected) {
	$finaldocumentimagefile = $cmscgi->param('finaldocumentimage');
    }
    my $comments = $cmscgi->param('commenttext');
    
    # response variables
    my $responseid = ($commitmenthasresponse) ? $cmscgi->param('responseid') : get_next_id($dbh, 'response');
    my $responsetext = $cmscgi->param('responsetext');
    my $responsetextsql = ($responsetext) ? ":responsetextclob" : "NULL";
    my $responsewrittendate = $cmscgi->param('responsewrittendate');
    $responsewrittendate = ($responsewrittendate eq "") ? "NULL" : "TO_DATE('$responsewrittendate', 'MM/DD/YYYY')";
    
    # letter variables
    my $letterid;
    my $letteraccessionnum;
    my $lettersentdate;
    my $letteraddressee;
    my $lettersigneddate;
    my $lettersigner;
    my $letterorganizationid;
    my $letterisnew;
    if (! $commitmenthasresponse) {
	$letterid = $cmscgi->param('letterid');
	$letterisnew = ($letterid eq 'NEW');
	$letterid = ($letterisnew) ? get_next_id($dbh, 'letter') : $letterid;
	$letteraccessionnum = $cmscgi->param('letteraccessionnum');
	$letteraccessionnum =~ s/\'/\'\'/g;
	$lettersentdate = $cmscgi->param('lettersentdate');
	$lettersentdate = ($lettersentdate eq "") ? "NULL" : "TO_DATE('$lettersentdate', 'MM/DD/YYYY')";
	$letteraddressee = $cmscgi->param('letteraddressee');
	$letteraddressee =~ s/\'/\'\'/g;
	$lettersigneddate = $cmscgi->param('lettersigneddate');
	$lettersigneddate = ($lettersigneddate eq "") ? "NULL" : "TO_DATE('$lettersigneddate', 'MM/DD/YYYY')";
	$lettersigner = $cmscgi->param('lettersigner');
	$letterorganizationid = $cmscgi->param('letterorganizationid');
    }
    
    #process image file
    if (($finaldocumentimagefile) && ($commitmentisrejected)) {
	my $bytesread = 0;
	my $buffer = '';
	# read a 16 K chunk and append the data to the variable $filedata
	while ($bytesread = read($finaldocumentimagefile, $buffer, 16384)){
	    $imagedata .= $buffer;
	    $imagesize += $bytesread;
	}
	$imagecontenttype = $cmscgi->uploadInfo($finaldocumentimagefile)->{'Content-Type'};
	$imagecontenttype =~ s/\'/\'\'/g;
	$imagecontenttype = "'$imagecontenttype'";
	$finaldocumentimagefile =~ /.*\\.*(\..*)/;
	$imageextension = "'" . $1 . "'";
	$imageinsertstring = ":imgblob";
    }
    
    #status variable depends on choice
    my $nextstatusid;
    if ($commitmentisrejected) {
	$nextstatusid = 8; # Rejected
    }
    else {
        my $hasacts = "select count (*) from $SCHEMA.action where commitmentid = $commitmentid";
	my ($acts) = $dbh -> selectrow_array ($hasacts);
	if ($acts > 0) {
	    $nextstatusid = 18; # Action entry 
	}
	else {
	    $nextstatusid = 9; # Pending
	}
    }
    
    #sql strings
    my $lettersqlstring;
    my $responsesqlstring;
    my $commitmentupdatesql;
    if (($finaldocumentimagefile) && ($commitmentisrejected)) {
	$commitmentupdatesql = "UPDATE $SCHEMA.commitment
                                SET closingdocimage = :imgblob,
                                    imagecontenttype = $imagecontenttype,
                                    imageextension = $imageextension,
                                    statusid = $nextstatusid,
                                    updatedby = $usersid
                                WHERE commitmentid = $commitmentid";
    }
    elsif ($commitmentisrejected) {
	$commitmentupdatesql = "UPDATE $SCHEMA.commitment
                                SET statusid = $nextstatusid,
                                    updatedby = $usersid,
                                    closeddate = SYSDATE
                                WHERE commitmentid = $commitmentid";
    }
    else {
	$nrcdate = ($nrcdate ne "00/00/0000") ? ", dateduetonrc = to_date('$nrcdate','MM/DD/YYYY') " : "";
	$commitmentupdatesql = "UPDATE $SCHEMA.commitment
                                SET statusid = $nextstatusid,
                                    updatedby = $usersid
                                    $nrcdate
                                WHERE commitmentid = $commitmentid";
    }
    if ($commitmenthasresponse) {
	$responsesqlstring = "UPDATE $SCHEMA.response
                              SET text = $responsetextsql,
                                  writtendate = $responsewrittendate
                              WHERE responseid = $responseid";
    }
    else {
	$lettersqlstring = "INSERT INTO $SCHEMA.letter
                                   (letterid, accessionnum, sentdate,
                                    addressee, signeddate,
                                    organizationid, signer)
                            VALUES ($letterid, '$letteraccessionnum',
                                    $lettersentdate, '$letteraddressee',
                                    $lettersigneddate, 
                                    $letterorganizationid,
                                    $lettersigner)";
	$responsesqlstring = "INSERT INTO $SCHEMA.response
                                     (responseid, text, writtendate,
                                      commitmentid, letterid)
                              VALUES ($responseid, $responsetextsql,
                                      $responsewrittendate,
                                      $commitmentid, $letterid)";
    }
    eval {
	my $csr;
	if (! $commitmenthasresponse) {
	    if ($letterisnew) {
		# Letter must be entered before the response can be saved
		$activity = "Insert Letter";
		$csr = $dbh->prepare($lettersqlstring);
		$csr->execute;
	    }
	    $activity = "Insert Response";
	}
	else {
	    $activity = "Update Response";
	}
	$csr = $dbh->prepare($responsesqlstring);
	$csr->bind_param(":responsetextclob", $responsetext, {ora_type => ORA_CLOB, ora_field => 'text'});
	$csr->execute;
	
	$activity = "Update Commitment";
	my $csr = $dbh->prepare($commitmentupdatesql);
	
	if (($finaldocumentimagefile) && ($commitmentisrejected)) {
	    $csr->bind_param(":imgblob", $imagedata, {ora_type => ORA_BLOB, ora_field => 'closingdocimage' });
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
	
	# update committed to records.
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
	    $csr = $dbh->prepare($committedorgsqlstring);
	    $csr->execute;
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
        parent.control.location="$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageerror
    }
    else {
	my $logmessage = ($commitmentisrejected) ? "Commitment ".&formatID2($commitmentid, 'C')." updated and moved to its final (Rejected) status" : "Commitment ".&formatID2($commitmentid, 'C')." updated and passed to BSC Lead for fulfillment; response " . &formatID2($responseid, 'R') . " and letter " . &formatID2($letterid, 'L') . " added/updated";
	&log_activity($dbh, 'F', $usersid, $logmessage);
	if ($nextstatusid == 18) {  #9) {
#	    my ($primarydiscipline) = $dbh -> selectrow_array ("select primarydiscipline from $SCHEMA.commitment where commitmentid = $commitmentid");
#	    my $modls = $dbh -> prepare ("select distinct usersid from $SCHEMA.defaultdisciplinerole where disciplineid = $primarydiscipline and roleid = 2 and siteid = $siteid");
	    my $modls = $dbh -> prepare ("select distinct dleadid from $SCHEMA.action where commitmentid=$commitmentid");
	    $modls -> execute;
	    while (my ($modlid) = $modls -> fetchrow_array) {
		my $notification = &notifyUser(dbh => $dbh, schema => $SCHEMA, userID => $modlid);
	    }   
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
}  ####################  endif pass_on  #########################
