#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# CMS Commitment Coordinator Review script
#
# $Source: /data/dev/rcs/cms/perl/RCS/MOCC_review.pl,v $
# $Revision: 1.60 $
# $Date: 2003/01/11 00:34:20 $
# $Author: naydenoa $
# $Locker:  $
# $Log: MOCC_review.pl,v $
# Revision 1.60  2003/01/11 00:34:20  naydenoa
# Made DOE Manager optional - CREQ00023 - rework
#
# Revision 1.59  2003/01/03 00:27:42  naydenoa
# Added display and processing of mandatory DOE manager for commitments
# CREQ00023
#
# Revision 1.58  2002/04/09 22:08:36  naydenoa
# Removed userid restriction on role insert - was interfering with
# role assignments.
#
# Revision 1.57  2001/12/10 22:49:35  naydenoa
# Changed BSCLL to BSCDL
#
# Revision 1.56  2001/11/15 23:03:04  naydenoa
# Added Licensing Lead, Responsible Manager, and external ID entry,
# updated role handling, notifications, etc... to accommodate actions.
#
# Revision 1.55  2001/06/01 23:07:51  naydenoa
# Added some Licensing Lead processing; checkpoint
#
# Revision 1.54  2001/05/04 21:31:49  naydenoa
# Update evals
#
# Revision 1.53  2001/05/02 22:13:20  naydenoa
# Modified evals, calls to Edit_Screens
#
# Revision 1.52  2001/03/12 18:11:30  naydenoa
# Added DL assignment
#
# Revision 1.51  2001/02/22 17:58:26  naydenoa
# Added insert of actual CC in issuerole table
#
# Revision 1.50  2001/01/31 22:09:32  naydenoa
# Took out secondary discipline
#
# Revision 1.49  2001/01/02 17:34:13  naydenoa
# Code clean-up
#
# Revision 1.48  2000/12/07 19:01:52  naydenoa
# Removed entry to commitmentrole table (default MODL assignment)
#
# Revision 1.47  2000/11/20 21:57:38  naydenoa
# Minor page number tweaks
#
# Revision 1.46  2000/11/20 19:38:59  naydenoa
# Moved some redundant code to Edit_Screens module
#
# Revision 1.45  2000/11/07 23:26:23  naydenoa
# Added email notification
#
# Revision 1.44  2000/10/26 18:12:07  naydenoa
# Resized tables to 650
# Resized textareas to 75
# Took out commitment rationale
# Added issue remarks display on query screen
# Added commitment remarks display
#
# Revision 1.43  2000/10/24 16:06:05  naydenoa
# Took out issueclassify and issuetype references
#
# Revision 1.42  2000/10/18 20:55:22  munroeb
# fixed activity log message
#
# Revision 1.41  2000/10/18 20:20:04  munroeb
# formatted activity log message
#
# Revision 1.40  2000/10/17 17:05:46  naydenoa
# Took out log_history, checkpoint.
#
# Revision 1.39  2000/10/06 20:37:58  munroeb
# added log-activity feature to script
#
# Revision 1.38  2000/10/06 19:09:24  naydenoa
# Added Date Due to Commitment Maker
# Moved WBS entry to MODL estimate
# Added info display when existing source doc selected
#
# Revision 1.37  2000/10/03 20:41:39  naydenoa
# Updates status id's and references.
#
# Revision 1.36  2000/09/29 17:10:29  naydenoa
# Took out llokups by name for roles, statuses; checkpoint after
# Version 2 release
#
# Revision 1.35  2000/09/26 18:07:49  atchleyb
# modified to allow blank accesion numbers
#
# Revision 1.34  2000/09/26 00:55:05  atchleyb
# changed inserts to specify column names
#
# Revision 1.33  2000/09/25 17:39:40  naydenoa
# Fixed input bug, source doc processing bug
#
# Revision 1.32  2000/09/08 23:46:13  naydenoa
# More interface updates.
#
# Revision 1.31  2000/09/06 20:42:38  atchleyb
# removed double click event from display only field
#
# Revision 1.30  2000/09/06 17:01:26  naydenoa
# Interface rewrite, added use of Edit_Screens module.
#
# Revision 1.29  2000/08/31 23:16:23  atchleyb
# check point
#
# Revision 1.28  2000/07/24 15:08:14  johnsonc
# Inserted GIF file for display.
#
# Revision 1.27  2000/07/17 17:39:33  atchleyb
# placed forms in a table of width 750
#
# Revision 1.26  2000/07/10 23:42:41  munroeb
# generalized formatting of html
#
# Revision 1.25  2000/07/06 23:30:02  munroeb
# finished mods to html and javascripts.
#
# Revision 1.24  2000/07/05 22:42:43  munroeb
# made minor changes to html and javascript
#
# Revision 1.23  2000/06/21 20:43:31  johnsonc
# Editted opening page select object to support double click event.
#
# Revision 1.22  2000/06/15 21:36:37  zepedaj
# Changed WBS selection box in the edit commitment routine to display the first 80 characters of the WBS description
#
# Revision 1.21  2000/06/15 18:28:30  johnsonc
# Revise table columns to be uniform in width
# Added 'Not Available' as a WBS picklist item
#
# Revision 1.20  2000/06/13 21:39:12  zepedaj
# Fixed width of tables so the columns would be the same
# Limited WBS detail to the first 80 characters
#
# Revision 1.19  2000/06/13 15:34:08  johnsonc
# Editted commitments select object to a fixed width.
#
# Revision 1.18  2000/06/12 15:46:39  johnsonc
# Add 'C' in front of commitment ID and 'I' in front of issue ID.
# Add 'proposed' to edit and view commitment page titles.
#
# Revision 1.17  2000/06/09 20:18:15  johnsonc
# Edit secondary discipline text area to display only when it contains data
#
# Revision 1.16  2000/06/08 19:58:30  zepedaj
# Fixed javascript error when checking primary discipline in the edit commitment routine.
#
# Revision 1.15  2000/06/06 23:24:32  zepedaj
# Fixed bug in saving new source document, date wasn't being retrieved.
#
# Revision 1.14  2000/06/02 23:40:05  johnsonc
# Insert comment text areas.
#
# Revision 1.13  2000/05/30 21:19:15  zepedaj
# Fixed javascript testing errors for new source document information
#
# Revision 1.12  2000/05/19 23:45:54  zepedaj
# Changed code for the final WBS structure
#
# Revision 1.11  2000/05/18 23:11:21  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.10  2000/05/10 21:17:51  zepedaj
# Removed spurious access of commitment ID sequence.
#
# Revision 1.9  2000/05/09 20:51:40  zepedaj
# Added form enctype for submitting files
#
# Revision 1.8  2000/05/04 21:44:40  zepedaj
# testing pass, fixed bug in retrieving user id for M&O Functional Lead.
# Script passes test, done
#
# Revision 1.7  2000/04/20 20:49:12  zepedaj
# Removed extra quote substitution for clobs
#
# Revision 1.6  2000/04/18 17:20:04  zepedaj
# Added updated by information to the commitment
#
# Revision 1.5  2000/04/17 17:47:54  zepedaj
# Picklists now limited to values that are "active"
#
# Revision 1.4  2000/04/13 23:24:16  zepedaj
# Fixed bug getting new ID number for commitment
#
# Revision 1.3  2000/04/13 20:43:11  zepedaj
# Fixed bug in assigning default commitment role in pass_on section
#
# Revision 1.2  2000/04/13 20:22:58  zepedaj
# Pre Release, awaiting WBS info
# All functions done except pass on.
#
# Revision 1.1  2000/04/11 22:51:39  zepedaj
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
    location = '$ONCSCGIDir/login.pl';
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
# find the Role ID for the M&O Commitment Coordinator
my $MOCC_Roleid = 1; # Commitment Coordinator
my $MOCC_statusid = 1; # Commitment Coordinator Review

#####################################
if ($cgiaction eq "fillout_letter") {
#####################################
    #control variables
    my $sourcedocid = $cmscgi->param('sourcedocid');
    my %sourcedocinfo;	
    
    #sourcedoc variables
    eval {
	%sourcedocinfo = get_sourcedoc_info ($dbh, $sourcedocid);
    };
    if ($@) {
	my $alertstring = errorMessage($dbh, $username, $usersid, $SCHEMA,"read source doc info",$@);
	$alertstring =~ s/\n/\\n/g;
	$alertstring =~ s/\'/\'\'/g;
        print "<script language=javascript><!--\n";
        print "   alert('$alertstring');\n";
        print "//--></script>\n";
    }
    my $accessionnum = $sourcedocinfo{'accessionnum'};
    my $title = $sourcedocinfo{'title'};
    my $signer = $sourcedocinfo{'signer'};
    my $emailaddress = $sourcedocinfo{'email'};
    my $areacode = $sourcedocinfo{'areacode'};
    my $phone = $sourcedocinfo{'phonenumber'};
    my $organizationid = $sourcedocinfo{'organizationid'};
    my $docdate = $sourcedocinfo{'documentdate'};
    my $docmonth;
    my $docday;
    my $docyear;
    ($docmonth, $docday, $docyear) = split /\//, $docdate;
    
    print "<script language=\"JavaScript\" type=\"text/javascript\"><!--\n";
    print "parent.workspace.newcommitment.accessionnum.value='$accessionnum';\n";
    print "parent.workspace.newcommitment.title.value='$title';\n";
    print "parent.workspace.newcommitment.signer.value='$signer';\n";
    print "parent.workspace.newcommitment.emailaddress.value='$emailaddress';\n";
    print "parent.workspace.newcommitment.areacode.value='$areacode';\n";
    print "parent.workspace.newcommitment.phonenumber.value='$phone';\n";
    print "parent.workspace.newcommitment.documentdate_month.value=$docmonth;\n";
    print "parent.workspace.newcommitment.documentdate_day.value=$docday;\n";
    print "parent.workspace.newcommitment.documentdate_year.value=$docyear;\n";
    print "parent.workspace.newcommitment.organizationid.value=$organizationid;\n";
    print "\n//-->\n";
    print "</script>\n";
    
    print "</head>\n<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n</body>\n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
} ####### endif fillout_letter  ###################

#######################################
if ($cgiaction eq "createcommitment") {
#######################################
    my $activity;
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "doSetTextImageLabel(\'Create Potential Commitment\');\n";
    print "//-->\n";
    print "</script>\n";
    
    my $issueid = $cmscgi->param('issueid');
    my $issueidstring = substr("0000$issueid", -5);
    my $page;
    my $issueentrydate;
    my $issuehasimage;
    my $issuehassourcedoc;
    my $imageextension;
    my $key;
    
    eval {
	$activity = "Retrieve issue page";
	$page = lookup_single_value($dbh, 'issue', 'page', $issueid);
	
	####  boolean variables  ####
	$activity = "Does issue has image and/or sourcedoc";
	($issuehasimage) = $dbh -> selectrow_array ("select count (*) from $SCHEMA.issue where issueid = $issueid and imageextension is not null");
	$issuehassourcedoc =  $dbh -> selectrow_array ("select count (*) from $SCHEMA.issue where issueid = $issueid and sourcedocid is not null");
	
	####  data variables  ####
	$dbh->{LongReadLen} = 1000000; #$TitleLength;
	$dbh->{LongTruncOk} = 0; #1;
	$imageextension = lookup_single_value($dbh, 'issue', 'imageextension', $issueid);
	$dbh->{LongTruncOk} = 0;
    };
    if ($@) {
	my $message = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$message =~ s/\n/\\n/g;
	$message =~ s/\'/\'\'/g;
	print "<script language=javascript><!--\n";
	print "   alert('$message');\n";
	print "//--></script>\n"; 
    }
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "function validate_commitment_data() {\n";
    print "    var msg = \"\";\n";
    print "    var tmpmsg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.newcommitment;\n";
    print "    if (validateform.issuehasimage.value == 0) {\n";
    print "        msg += (validateform.image.value==\"\") ? \"You must enter a scanned image of the issue.\\n\" : \"\";\n";
    print "        msg += (validateform.page.value==\"\") ? \"You must enter the page number of the issue.\\n\" : \"\";\n";
    print "    }\n";
    print "    msg += (validateform.text.value==\"\") ? \"You must enter the potential commitment text.\\n\" : \"\";\n";
    print "    msg += ((validateform.discipline.value==\'\') || (validateform.discipline.value==0)) ? \"You must select the primary discipline for this commitment.\\n\" : \"\";\n";
    print "    msg += (validateform.disciplinelead.value==\'\' || validateform.disciplinelead.value==\'NULL\') ? \"You must select a BSC discipline lead for this commitment.\\n\" : \"\";\n";
    print "    msg += (validateform.BSCresponsiblemanager.value==\'\' || validateform.BSCresponsiblemanager.value==\'NULL\') ? \"You must select a BSC responsible manager for this commitment.\\n\" : \"\";\n";
#    print "    msg += (validateform.DOEresponsiblemanager.value==\'\' || validateform.DOEresponsiblemanager.value==\'NULL\') ? \"You must select a DOE responsible manager for this commitment.\\n\" : \"\";\n";
    print "    msg += (validateform.commitmentlevelid.value==\"\") ? \"You must select a commitment level.\\n\" : \"\";\n";
    print "    msg += ((tmpmsg = validate_date(validateform.duedate_year.value, validateform.duedate_month.value, validateform.duedate_day.value, 0, 0, 0, 0, false, true, false)) == \"\") ? \"\" : \"Date Due - \" + tmpmsg + \"\\n\";\n";
    print "    if (validateform.issuehassourcedoc.value == 0) {\n";
    print "        msg += (validateform.sourcedocid.value ==\'\') ? \"You must select the source document or enter data for it.\\n\" : \"\";\n";
    print "        if (validateform.sourcedocid.value==\"NEW\") {\n";
    print "            msg += ((tmpmsg = validate_accession_number(validateform.accessionnum.value,true)) == \"\") ? \"\" : tmpmsg + \"\\n\";\n";
    print "            msg += (validateform.title.value==\"\") ? \"You must enter the title of the source document.\\n\" : \"\";\n";
    print "            msg += (validateform.signer.value==\"\") ? \"You must enter the signer of the source document.\\n\" : \"\";\n";
    print "            msg += ((validateform.areacode.value != \"\") && (validateform.areacode.value.length < 3)) ? \"You have enterd an invalid area code.\\n\" : \"\";\n";
    print "            msg += ((validateform.phonenumber.value != \"\") && (validateform.phonenumber.value.length < 7)) ? \"You have enterd an invalid phone number.\\n\" : \"\";\n";
    print "            msg += ((tmpmsg = validate_date(validateform.documentdate_year.value, validateform.documentdate_month.value, validateform.documentdate_day.value, 0, 0, 0, 0, true, false, false)) == \"\") ? \"\" : tmpmsg + \"\\n\";\n";
    print "            msg += (validateform.organizationid.value==\'\') ? \"You must select the organization the source document came from.\\n\" : \"\";\n";
    print "        }\n";
    print "    }\n";
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
    print "    var validateform = document.newcommitment;\n\n";
    
    print "    if (validateform.issuehasimage.value == 0) {\n";
    print "        if ((validateform.image.value != \"\") && (validateform.page.value == \"\")) {\n";
    print "            msg += \"You must enter the page number of the issue.\\n\";\n";
    print "        }\n";
    print "        if ((validateform.image.value == \"\") && (validateform.page.value != \"\")) {\n";
    print "             msg += \"You must enter the scanned image of the issue.\\n\";\n";
    print "        }\n";
    print "        if ((validateform.image.value == \"\") && (validateform.page.value == \"\")) {\n";
    print "            msg += \"You must enter the page number and the scanned image for the issue\";\n";
    print "        }\n";
    print "    }\n";
    print "    msg += (validateform.text.value==\"\") ? \"You must enter the potential commitment text.\\n\" : \"\";\n";
    print "    msg += (validateform.discipline.value==\'\' || validateform.discipline.value == \'NULL\') ? \"You must select the primary discipline for this commitment.\\n\" : \"\";\n";
    print "    msg += (validateform.disciplinelead.value==\'\' || validateform.disciplinelead.value==\'NULL\') ? \"You must select a BSC discipline lead for this commitment.\\n\" : \"\";\n";
    print "    msg += (validateform.BSCresponsiblemanager.value==\'\' || validateform.BSCresponsiblemanager.value==\'NULL\') ? \"You must select a BSC responsible manager for this commitment.\\n\" : \"\";\n";
#    print "    msg += (validateform.DOEresponsiblemanager.value==\'\' || validateform.DOEresponsiblemanager.value==\'NULL\') ? \"You must select a DOE responsible manager for this commitment.\\n\" : \"\";\n";
    print "    msg += (validateform.commitmentlevelid.value==\'\') ? \"You must select a commitment level or 'Not Available'.\\n\" : \"\";\n";
    print "    msg += ((tmpmsg = validate_date(validateform.duedate_year.value, validateform.duedate_month.value, validateform.duedate_day.value, 0, 0, 0, 0, false, true, false)) == \"\") ? \"\" : \"Date Due - \" + tmpmsg + \"\\n\";\n\n";
    
    print "    if (validateform.issuehassourcedoc.value == 0) {\n";
    print "        if (validateform.sourcedocid.value==\"NEW\") {\n";
    print "            msg += ((tmpmsg = validate_accession_number(validateform.accessionnum.value,true)) == \"\") ? \"\" : tmpmsg + \"\\n\";\n";
    print "            msg += (validateform.title.value==\"\") ? \"You must enter the title of the source document.\\n\" : \"\";\n";
    print "            msg += (validateform.signer.value==\"\") ? \"You must enter the signer of the source document.\\n\" : \"\";\n";
    print "            msg += ((validateform.areacode.value != \"\") && (validateform.areacode.value.length < 3)) ? \"You have enterd an invalid area code.\\n\" : \"\";\n";
    print "            msg += ((validateform.phonenumber.value != \"\") && (validateform.phonenumber.value.length < 7)) ? \"You have enterd an invalid phone number.\\n\" : \"\";\n";
    print "            msg += ((tmpmsg = validate_date(validateform.documentdate_year.value, validateform.documentdate_month.value, validateform.documentdate_day.value, 0, 0, 0, 0, true, false, false)) == \"\") ? \"\" : tmpmsg + \"\\n\";\n";
    print "            msg += (validateform.organizationid.value==\'\') ? \"You must select the organization the source document came from.\\n\" : \"\";\n";
    print "        }\n";
    print "    }\n";
    print "    if (msg != \"\") {\n"; 
    print "        alert(msg);\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    if (returnvalue) {\n";
    print "        document.newcommitment.submit();\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "}\n\n";
    
    print "function pass_on() {\n";
    print "    var tempcgiaction;\n";
    print "    var returnvalue = true;\n\n";
    
    print "    if (validate_commitment_data()) {\n";
    print "        tempcgiaction = document.newcommitment.cgiaction.value;\n";
    print "        document.newcommitment.cgiaction.value = \"pass_on\";\n";
    print "        document.newcommitment.submit();\n";
    print "        document.newcommitment.cgiaction.value = tempcgiaction;\n";
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
    print "<form name=newcommitment enctype=\'multipart/form-data\' method=post target=\"control\" action=\"$ONCSCGIDir/MOCC_review.pl\">\n";
    print "<table border=0 align=center width=650><tr><td>\n";
    print "<input name=cgiaction type=hidden value=\"save_commitment\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=issueid type=hidden value=$issueid>\n";
    print "<input name=isnewcommitment type=hidden value=-1>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    print "<table summary=\"Changes To Issue\" width=650 border=0 cellspacing=10 align=center>\n";
    eval {
	$activity = "Get info for issue $issueid from Edit_Screens";
	print &doIssueTable (iid => $issueid, dbh => $dbh, schema => $SCHEMA);
	if ($issuehasimage && !($issuehassourcedoc)) {
	    # issue image exists on server from previous screen, no reread
	    print "<tr><td><b><li>Available Issue Source Information:</b>\n";
	    print "<br><table border=1 width=650 align=center>\n";
	    print "<tr><td><table width=100% border=0 cellpadding=0 cellspacing=0>\n";
	    print "<tr bgcolor=#ffffff><td align=left width=40%><b>Issue Source Image File:</b></td><td>\n";
	    print "<a href=\'$CMSImagePath/issueimage$issueid$imageextension\' target=imagewin>Click for the image source file</a>\n";
	    print "<input name=issuehasimage type=hidden value=-1></td></tr>\n";
	    print "<tr bgcolor=#eeeeee><td align=left><b>Source Document Page Number:</b></td>\n";
	    print "<td>$page</td></tr>\n";
	    print "<input type=hidden name=page value=\"$page\">\n";
	    print "</table>\n</td></tr></table></td></tr>\n";
	}
	if (!($issuehasimage)) {
	    print "<tr><td align=left><b><li>Issue Source Image File:</b>\n";
	    print "&nbsp; &nbsp;<input type=file name=image size=50 maxlength=256>\n";
	    print "<input name=issuehasimage type=hidden value=0></td></tr>\n";
	    print "<tr><td align=left><b><li>Source Document Page Number:</b>&nbsp;&nbsp;\n";
	    print "<input name=page type=text maxlength=5 size=5 value=\"$page\"></td></tr>\n";
	}
	if ($issuehassourcedoc && $issuehasimage) {
	    print &doIssueSourceTable (iid => $issueid, dbh => $dbh, schema => $SCHEMA, page => $page, imagepath => $CMSImagePath, imageextension => $imageextension);
	}
	elsif ($issuehassourcedoc && !($issuehasimage)){
	    print &doIssueSourceTable (iid => $issueid, dbh => $dbh, schema => $SCHEMA, page => $page);
	}
	else {
	    print selectSource (dbh => $dbh);
	}
	print "</table>\n"; #end of issue table
###################### start of commitment table
	$activity = "Get commitment fields from Edit_Screens";
	print "</td></tr><tr><td>\n";
	print "<hr width=60%></td></tr><tr><td>\n";
	print "<table summary=\"Enter Commitment Table\" align=center width=650 border=0 cellspacing=10>\n";
	print "<tr><td align=left><b><li>Potential Commitment Text:</b><br>\n";
	print "<textarea name=text cols=75 rows=5></textarea></td></tr>\n";
	print "<tr><td><b><li>External ID:</b>&nbsp;&nbsp;\n";
	print "<input type=text name=externalid length=20 maxlength=20>&nbsp;&nbsp;(optional)</td></tr>\n";
	print selectDiscipline (dbh => $dbh, schema => $SCHEMA); 
	print selectRM (dbh => $dbh, schema => $SCHEMA, mgrtype => 2);
#	print selectDL (dbh => $dbh, schema => $SCHEMA);
	print "<tr><td align=left><b><li>BSC Discipline Lead:</b>&nbsp;&nbsp;\n";
	print "<select name=disciplinelead>";
	print "<option value='' selected>Select Discipline Lead";
	my $dlquery = "select distinct u.firstname || ' ' || u.lastname, u.usersid, u.lastname from $SCHEMA.users u, $SCHEMA.defaultsiterole dr where dr.roleid=2 and u.usersid=dr.usersid order by u.lastname";
	my $csr = $dbh -> prepare ($dlquery);
	$csr -> execute;
	while (my ($name, $uid) = $csr -> fetchrow_array) {
	    print "<option value=$uid>$name\n";
	}
	print "</select></td></tr>\n";
	print selectRM (dbh => $dbh, schema => $SCHEMA, mgrtype => 1);
	print selectLevel (dbh => $dbh, schema => $SCHEMA);
	print "<tr><td align=left><b><li>Date Due to Commitment Maker:</b>&nbsp;&nbsp;\n";
	print build_date_selection('duedate', 'newcommitment');
	print "</td></tr>\n";
	print "<tr><td><hr width=70%></td></tr>\n";
	print &writeComment (active => 1);
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
####################  end commitment table
    
    print "<script language=\"JavaScript\" type=\"text/javascript\"><!--\n\n";
    print "function clearletter() {\n";
    print "    document.newcommitment.accessionnum.value = \"\";\n";
    print "    document.newcommitment.title.value = \"\";\n";
    print "    document.newcommitment.signer.value = \"\";\n";
    print "    document.newcommitment.emailaddress.value = \"\";\n";
    print "    document.newcommitment.areacode.value = \"\";\n";
    print "    document.newcommitment.phonenumber.value = \"\";\n";
    print "    document.newcommitment.organizationid.value = \"\";\n";
    print "}\n";
    print "function disableletter() {\n";
    print "    document.newcommitment.accessionnum.disabled = true;\n";
    print "    document.newcommitment.title.disabled = true;\n";
    print "    document.newcommitment.signer.disabled = true;\n";
    print "    document.newcommitment.emailaddress.disabled = true;\n";
    print "    document.newcommitment.areacode.disabled = true;\n";
    print "    document.newcommitment.phonenumber.disabled = true;\n";
    print "    document.newcommitment.documentdate_month.disabled = true;\n";
    print "    document.newcommitment.documentdate_day.disabled = true;\n";
    print "    document.newcommitment.documentdate_year.disabled = true;\n";
    print "    document.newcommitment.organizationid.disabled = true;\n";
    print "}\n";
    print "function enableletter() {\n";
    print "    document.newcommitment.accessionnum.disabled = false;\n";
    print "    document.newcommitment.title.disabled = false;\n";
    print "    document.newcommitment.signer.disabled = false;\n";
    print "    document.newcommitment.emailaddress.disabled = false;\n";
    print "    document.newcommitment.areacode.disabled = false;\n";
    print "    document.newcommitment.phonenumber.disabled = false;\n";
    print "    document.newcommitment.documentdate_month.disabled = false;\n";
    print "    document.newcommitment.documentdate_day.disabled = false;\n";
    print "    document.newcommitment.documentdate_year.disabled = false;\n";
    print "    document.newcommitment.organizationid.disabled = false;\n";
    print "}\n";
    print "function fillout_letter() {\n";
    print "    var validateform = document.newcommitment;\n";
    print "    var tempcgiaction;\n\n";
    
    print "    tempcgiaction = document.newcommitment.cgiaction.value;\n";
    print "    document.newcommitment.cgiaction.value = \"fillout_letter\";\n";
    print "    document.newcommitment.submit();\n";
    print "    document.newcommitment.cgiaction.value = tempcgiaction;\n";
    print "    return (true);\n";
    print "}\n";
    print "function checkletter(letterselection) {\n";
    print "    if (letterselection.value!=\"NEW\") {\n";
    print "        if (letterselection.value != \'\'){\n";
    print "            clearletter();\n";
    print "            disableletter();\n";
    print "            fillout_letter();\n";
    print "        }\n";
    print "        else {\n";
    print "            clearletter();\n";
    print "            disableletter();\n";
    print "        }\n";
    print "    }\n";
    print "    else {\n";
    print "        clearletter();\n";
    print "        enableletter();\n";
    print "    }\n";
    print "}\n";
    print "checkletter(document.newcommitment.sourcedocid);\n";
    
    print "//-->\n";
    print "</script>\n";
    
    print "<br><center>\n";
    print "<input type=button name=savecommitment value=\"Save Draft Work\" title=\"Save Draft Work, can be edited later\" onclick=\"return(save_commitment())\">\n";
    print "<input type=button name=saveandcomplete value=\"Save and Pass On\" title=\"Save Commitment and pass it on to the Discipline Lead\" onclick=\"return(pass_on())\">\n";
    print "</td></tr></table>\n</form>\n";
    print "<br><br><br>\n</body>\n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
}  ##############  endif create_commitment  ##################

#####################################
if ($cgiaction eq "editcommitment") {
#####################################
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!-- \n";
    print "doSetTextImageLabel(\'Edit Potential Commitment\'); \n";
    print "//-->\n";
    print "</script>\n";
    
    my $issueid = $cmscgi->param('issueid');
    my $commitmentid = $cmscgi->param('commitmentselect');
    my $issuehasimage = $cmscgi->param('issuehasimage');
    my $issuehassourcedoc = $cmscgi->param('issuehassourcedoc');
    my $activity;
    my $imageextension;
    my $page;
    my %commitmentinfohash;
    my $key;
    
    eval {
	$activity = "Get information for issue $issueid";
	$imageextension = lookup_single_value($dbh, 'issue', 'imageextension', $issueid);
	$page = lookup_single_value($dbh, 'issue', 'page', $issueid);
	
	$activity = "Get info for commitment $commitmentid";
	%commitmentinfohash = get_commitment_info($dbh, $commitmentid);
    };
    if ($@) {
	my $logmessage = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$logmessage =~ s/\n/\\n/g;
	$logmessage =~ s/\'/\'\'/g;
	print "<script language=javascript><!--\n";
	print "   alert('$logmessage');\n";
	print "//--></script>\n";
    }
    
    my $text = $commitmentinfohash{'text'};
    my $primarydiscipline = $commitmentinfohash{'primarydiscipline'};
    my $commitmentlevelid = $commitmentinfohash{'commitmentlevelid'};
    my $commitmentcomment = $commitmentinfohash{'comments'};
    my $duedate = $commitmentinfohash{'duedate'};
    my $externalid = $commitmentinfohash{'externalid'};
    
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "function validate_commitment_data() {\n";
    print "    var msg = \"\";\n";
    print "    var tmpmsg = \"\";\n";
    print "    var returnvalue = true;\n";
    print "    var validateform = document.newcommitment;\n";
    print "    if (validateform.issuehasimage.value == 0) {\n";
    print "        msg += (validateform.image.value==\"\") ? \"You must enter a scanned image of the issue.\\n\" : \"\";\n";
    print "        msg += (validateform.page.value==\"\") ? \"You must enter the page number of the issue.\\n\" : \"\";\n";
    print "    }\n";
    print "    msg += (validateform.text.value==\"\") ? \"You must enter the potential commitment text.\\n\" : \"\";\n";
    print "    msg += ((validateform.discipline.value==\'\') || (validateform.discipline.value==\'NULL\')) ? \"You must select the primary discipline for this commitment.\\n\" : \"\";\n";
    print "    msg += (validateform.disciplinelead.value==\'\' || validateform.disciplinelead.value==\'NULL\') ? \"You must select a BSC discipline lead for this commitment.\\n\" : \"\";\n";
    print "    msg += (validateform.BSCresponsiblemanager.value==\'\' || validateform.BSCresponsiblemanager.value==\'NULL\') ? \"You must select a BSC responsible manager for this commitment.\\n\" : \"\";\n";
#    print "    msg += (validateform.DOEresponsiblemanager.value==\'\' || validateform.DOEresponsiblemanager.value==\'NULL\') ? \"You must select a DOE responsible manager for this commitment.\\n\" : \"\";\n";
    print "    msg += ((tmpmsg = validate_date(validateform.duedate_year.value, validateform.duedate_month.value, validateform.duedate_day.value, 0, 0, 0, 0, false, true, false)) == \"\") ? \"\" : \"Date Due - \" + tmpmsg + \"\\n\";\n";
    print "    msg += (validateform.commitmentlevelid.value==\"\") ? \"You must select a commitment level.\\n\" : \"\";\n";
    print "    if (validateform.issuehassourcedoc.value == 0) {\n";
    print "        msg += (validateform.sourcedocid.value==\'\') ? \"You must select the source document or enter data for it.\\n\" : \"\";\n";
    print "        if (validateform.sourcedocid.value==\"NEW\") {\n";
    print "            msg += ((tmpmsg = validate_accession_number(validateform.accessionnum.value,true)) == \"\") ? \"\" : tmpmsg + \"\\n\";\n";
    print "            msg += (validateform.title.value==\"\") ? \"You must enter the title of the source document.\\n\" : \"\";\n";
    print "            msg += (validateform.signer.value==\"\") ? \"You must enter the signer of the source document.\\n\" : \"\";\n";
    print "            msg += ((validateform.areacode.value != \"\") && (validateform.areacode.value.length < 3)) ? \"You have enterd an invalid area code.\\n\" : \"\";\n";
    print "            msg += ((validateform.phonenumber.value != \"\") && (validateform.phonenumber.value.length < 7)) ? \"You have enterd an invalid phone number.\\n\" : \"\";\n";
    print "            msg += ((tmpmsg = validate_date(validateform.documentdate_year.value, validateform.documentdate_month.value, validateform.documentdate_day.value, 0, 0, 0, 0, true, false, false)) == \"\") ? \"\" : tmpmsg + \"\\n\";\n";
    print "            msg += (validateform.organizationid.value==\'\') ? \"You must select the originating organization for the source document.\\n\" : \"\";\n";
    print "         }\n";
    print "    }\n";
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
    print "    var validateform = document.newcommitment;\n";
    print "    if (validateform.issuehasimage.value == 0) {\n";
    print "        if ((validateform.image.value != \"\") && (validateform.page.value == \"\")) {\n";
    print "            msg += \"You must enter the page number of the issue.\\n\";\n";
    print "        }\n";
    print "        if ((validateform.image.value == \"\") && (validateform.page.value != \"\")) {\n";
    print "            msg += \"You must enter the scanned image of the issue.\\n\";\n";
    print "        }\n";
    print "    }\n";
    print "    msg += (validateform.text.value==\"\") ? \"You must enter the potential commitment text.\\n\" : \"\";\n";
    print "    msg += (validateform.discipline.value==\'\' || validateform.discipline.value==\'NULL\') ? \"You must select the primary discipline for this commitment.\\n\" : \"\";\n";
    print "    msg += (validateform.disciplinelead.value==\'\' || validateform.disciplinelead.value==\'NULL\') ? \"You must select a BSC discipline lead for this commitment.\\n\" : \"\";\n";
    print "    msg += (validateform.BSCresponsiblemanager.value==\'\' || validateform.BSCresponsiblemanager.value==\'NULL\') ? \"You must select a BSC responsible manager for this commitment.\\n\" : \"\";\n";
#    print "    msg += (validateform.DOEresponsiblemanager.value==\'\' || validateform.DOEresponsiblemanager.value==\'NULL\') ? \"You must select a DOE responsible manager for this commitment.\\n\" : \"\";\n";
    print "    msg += ((tmpmsg = validate_date(validateform.duedate_year.value, validateform.duedate_month.value, validateform.duedate_day.value, 0, 0, 0, 0, false, true, false)) == \"\") ? \"\" : \"Date Due - \" + tmpmsg + \"\\n\";\n";
    print "    msg += (validateform.commitmentlevelid.value==\'\') ? \"You must select a commitment level or 'Not Available'.\\n\" : \"\";\n";
    print "    if (validateform.issuehassourcedoc.value == 0) {\n";
    print "        if (validateform.sourcedocid.value==\"NEW\") {\n";
    print "            msg += ((tmpmsg = validate_accession_number(validateform.accessionnum.value,true)) == \"\") ? \"\" : tmpmsg + \"\\n\";\n";
    print "            msg += (validateform.title.value==\"\") ? \"You must enter the title of the source document.\\n\" : \"\";\n";
    print "            msg += (validateform.signer.value==\"\") ? \"You must enter the signer of the source document.\\n\" : \"\";\n";
    print "            msg += ((validateform.areacode.value != \"\") && (validateform.areacode.value.length < 3)) ? \"You have enterd an invalid area code.\\n\" : \"\";\n";
    print "            msg += ((validateform.phonenumber.value != \"\") && (validateform.phonenumber.value.length < 7)) ? \"You have enterd an invalid phone number.\\n\" : \"\";\n";
    print "            msg += ((tmpmsg = validate_date(validateform.documentdate_year.value, validateform.documentdate_month.value, validateform.documentdate_day.value, 0, 0, 0, 0, true, false, false)) == \"\") ? \"\" : tmpmsg + \"\\n\";\n";
    print "            msg += (validateform.organizationid.value==\'\') ? \"You must select the originating organization for the source document.\\n\" : \"\";\n";
    print "        }\n";
    print "    }\n";
    print "    if (msg != \"\") {\n";
    print "        alert(msg);\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    if (returnvalue) {\n";
    print "        document.newcommitment.submit();\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "}\n";
    print "function pass_on() {\n";
    print "    var tempcgiaction;\n";
    print "    var returnvalue = true;\n\n";
    
    print "    if (validate_commitment_data()) {\n";
    print "        tempcgiaction = document.newcommitment.cgiaction.value;\n";
    print "        document.newcommitment.cgiaction.value = \"pass_on\";\n";
    print "        document.newcommitment.submit();\n";
    print "        document.newcommitment.cgiaction.value = tempcgiaction;\n";
    print "    }\n";
    print "    else {\n";
    print "        returnvalue = false;\n";
    print "    }\n";
    print "    return (returnvalue);\n";
    print "}\n";
    print "//-->\n";
    print "</script>\n";
    print "</head>\n\n";
    
    print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<form name=newcommitment enctype=\'multipart/form-data\' method=post target=\"control\" action=\"$ONCSCGIDir/MOCC_review.pl\">\n";
    print "<table border=0 align=center width=650><tr><td>\n";
    print "<input name=cgiaction type=hidden value=\"save_commitment\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=issueid type=hidden value=$issueid>\n";
    print "<input name=isnewcommitment type=hidden value=0>\n";
    print "<input name=commitmentid type=hidden value=$commitmentid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    print "<table summary=\"Changes To Issue\" width=650 border=0 cellspacing=10 align=center>\n";
    print "<tr><td align=left><b><li>Commitment ID:&nbsp;&nbsp; " . formatID2($commitmentid,'C') . " </b></td></tr>\n";
    print &doIssueTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
    if ($issuehasimage && !$issuehassourcedoc) {
	# the issue image exists on the server from the previous screen, no nead to reread it.
	if (!$page) {
	    $page = "Not Entered";
	}
	print "<tr><td><b><li>Available Issue Source Information:</b><br>\n";
	print "<table align=center border=1 width=650>\n";
	print "<tr><td><table border=0 cellpadding=0 cellspacing=0 width=100%>\n";
	print "<tr bgcolor=#ffffff><td width=40%><b>Issue Source Image File:</b></td>\n";
	print "<td><a href=\'$CMSImagePath/issueimage$issueid$imageextension\' target=imagewin>Click for the image source file</a>\n";
	print "<input name=issuehasimage type=hidden value=-1></td></tr>\n";
	print "<tr bgcolor=#eeeeee><td><b>Source Document Page Number:</b></td>\n";
	print "<td>$page</td></tr> \n</table></td></tr> \n</table></td></tr>\n";
    }
    if (!$issuehasimage) {
	print "<tr><td align=left><b><li>Issue Source Image File:</b></td>\n";
	print "<td align=left> \n<input type=file name=image size=50 maxlength=256>\n";
	print "<input name=issuehasimage type=hidden value=0></td></tr>\n";
	print "<tr><td align=left><b><li>Source Document Page Number: &nbsp;&nbsp;</b>\n";
	print "<input name=page type=text maxlength=5 size=5 value=\"$page\"></td></tr>\n";
    }
    eval {
	$activity = "Get source info for issue $issueid from Edit_Screens";
	if ($issuehassourcedoc) {
	    print &doIssueSourceTable (iid => $issueid, dbh => $dbh, schema => $SCHEMA, page => $page, imagepath => $CMSImagePath, imageextension => $imageextension);
	}
	else {
	    print selectSource (dbh => $dbh);
	}
###########################################
	print "</table><hr width=70%>\n";
	$activity = "Get info for commitment $commitmentid from Edit_Screens";
	print "<table summary=\"Enter Commitment Table\" width=650 border=0 align=center cellspacing=10>\n";
	print &writeCommitmentText (active => 1, potential => 1, text => $text);
	print "<tr><td><b><li>External ID:</b>&nbsp;&nbsp;\n";
	print "<input type=text name=externalid length=20 maxlength=20 value=\"$externalid\">&nbsp;&nbsp;(optional)</td></tr>\n";
	print selectDiscipline (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid);
	print selectRM (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid, mgrtype => 2);
#	print selectLL (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid);
my ($curdl) = $dbh -> selectrow_array ("select lleadid from $SCHEMA.commitment where commitmentid = $commitmentid"); 
	print "<tr><td align=left><b><li>BSC Discipline Lead:</b>&nbsp;&nbsp;\n";
	print "<select name=disciplinelead>";
	print "<option value='' selected>Select Discipline Lead";
	my $dlquery = "select distinct u.firstname || ' ' || u.lastname, u.usersid, u.lastname from $SCHEMA.users u, $SCHEMA.defaultsiterole dr where dr.roleid=2 and u.usersid=dr.usersid order by u.lastname";
	my $csr = $dbh -> prepare ($dlquery);
	$csr -> execute;
	while (my ($name, $uid) = $csr -> fetchrow_array) {
	    if ($uid == $curdl){
		print "<option value=$uid selected>$name\n";
	    }
	    else {
		print "<option value=$uid>$name\n";
	    }
	}
	print "</select></td></tr>\n";

	print selectRM (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid, mgrtype => 1);
	print selectLevel (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid);
	print "<tr><td align=left><b><li>Date Due to Commitment Maker:</b>&nbsp;&nbsp;\n";
	print build_date_selection('duedate', 'newcommitment', $duedate);
	print "</td></tr>\n";
	print "<tr><td><hr width=70%></td></tr>\n";
	print &writeComment (active => 1);
	print doRemarksTable (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid);
	print "</table></td></tr> \n</table>\n\n";
    };
    if ($@) {
	my $logmessage = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$logmessage =~ s/\n/\\n/g;
	$logmessage =~ s/\'/\'\'/g;
	print "<script language=javascript><!--\n";
	print "   alert('$logmessage');\n";
	print "//--></script>\n";
    }
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "function disableletter() {\n";
    print "    document.newcommitment.accessionnum.disabled = true;\n";
    print "    document.newcommitment.accessionnum.value = \"\";\n";
    print "    document.newcommitment.title.disabled = true;\n";
    print "    document.newcommitment.title.value = \"\";\n";
    print "    document.newcommitment.signer.disabled = true;\n";
    print "    document.newcommitment.signer.value = \"\";\n";
    print "    document.newcommitment.emailaddress.disabled = true;\n";
    print "    document.newcommitment.emailaddress.value = \"\";\n";
    print "    document.newcommitment.areacode.disabled = true;\n";
    print "    document.newcommitment.areacode.value = \"\";\n";
    print "    document.newcommitment.phonenumber.disabled = true;\n";
    print "    document.newcommitment.phonenumber.value = \"\";\n";
    print "    document.newcommitment.documentdate_month.disabled = true;\n";
    print "    document.newcommitment.documentdate_day.disabled = true;\n";
    print "    document.newcommitment.documentdate_year.disabled = true;\n";
    print "    document.newcommitment.organizationid.disabled = true;\n";
    print "    document.newcommitment.organizationid.value = \"\";\n";
    print "}\n";
    print "function enableletter() {\n";
    print "    document.newcommitment.accessionnum.disabled = false;\n";
    print "    document.newcommitment.title.disabled = false;\n";
    print "    document.newcommitment.signer.disabled = false;\n";
    print "    document.newcommitment.emailaddress.disabled = false;\n";
    print "    document.newcommitment.areacode.disabled = false;\n";
    print "    document.newcommitment.phonenumber.disabled = false;\n";
    print "    document.newcommitment.documentdate_month.disabled = false;\n";
    print "    document.newcommitment.documentdate_day.disabled = false;\n";
    print "    document.newcommitment.documentdate_year.disabled = false;\n";
    print "    document.newcommitment.organizationid.disabled = false;\n";
    print "}\n";
    
    print "function checkletter(letterselection) {\n";
    print "    if (letterselection.value!=\"NEW\") {\n";
    print "        disableletter();\n";
    print "    }\n";
    print "    else {\n";
    print "        enableletter();\n";
    print "    }\n";
    print "}\n";
    print "checkletter(document.newcommitment.sourcedocid);\n";
    print "//-->\n";
    print "</script>\n\n";
    
    print "<center>\n";
    print "<input type=button name=savecommitment value=\"Save Draft Work\" title=\"Save Draft Work, can be edited later\" onclick=\"return(save_commitment())\">\n";
    print "<input type=button name=saveandcomplete value=\"Save and Pass On\" title=\"Save Commitment and pass it on to the Discipline Lead\" onclick=\"return(pass_on())\">\n";
    print "</td></tr></table>\n";
    print "</form> \n<br><br><br> \n</body> \n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
} ################  endif editcommitment  ##################

##################################
if ($cgiaction eq "query_issue") {
##################################
    my $activity;
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n" .
          "<!--\n" .
	  "doSetTextImageLabel(\'Issue Review\');\n" .
	  "//-->\n" .
	  "</script>\n";
    my $textareawidth = 80;
    my $showexistingcommitments = 0;  #false
    tie my %commitmentusedhash, "Tie::IxHash";
    tie my %commitmenthash, "Tie::IxHash";
    my %commitmenttexthash;
    
    my $thisissueid = $cmscgi->param('issueselect');
    if ((!defined($thisissueid)) || ($thisissueid eq "")) {
	$thisissueid = $cmscgi->param('committedissueselect');
	$showexistingcommitments = -1;  #true
	%commitmentusedhash = get_lookup_values($dbh, "commitment", "commitmentid", "statusid", "issueid = $thisissueid");
	%commitmenthash = get_lookup_values($dbh, "commitment", "commitmentid", "SUBSTR('0000' || commitmentid, -5) || ' - ' || TO_CHAR(duedate, 'MM/DD/YYYY')", "issueid = $thisissueid ORDER BY commitmentid"); ## was commitdate
	$dbh->{LongReadLen} = 1000000;      # $TitleLength;
	$dbh->{LongTruncOk} = 0;     #    -1;  #True
	%commitmenttexthash = get_lookup_values($dbh, "commitment", "commitmentid", "text", "issueid = $thisissueid");
	$dbh->{LongTruncOk} = 0;   #False
    }
    my $key;
    
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "function create_new_commitment() {\n";
    print "    document.screening.submit();\n";
    print "    return (true);\n";
    print "}\n";
    print "function delegate_issue() {\n";
    print "    var tempcgiaction;\n";
    print "    tempcgiaction = document.screening.cgiaction.value;\n";
    print "    document.screening.cgiaction.value = \"delegate\";\n";
    print "    document.screening.submit();\n";
    print "    document.screening.cgiaction.value = tempcgiaction;\n";
    print "    return(true);\n";
    print "}\n";
    print "function edit_selected_commitment() {\n";
    print "    var tempcgiaction;\n";
    print "    var msg = \"\";\n";

    print "    // determine if a commitment is selected\n";
    print "    msg += (document.screening.commitmentselect.selectedIndex == -1 || document.screening.commitmentselect.options[document.screening.commitmentselect.options.length - 1].selected == 1) ? \"You must select a commitment to edit.\" : \"\";\n";
    print "    if (msg != \"\") {\n";
    print "        alert (msg);\n";
    print "        return (false);\n";
    print "    }\n ";
    print "    else {\n";
    print "        tempcgiaction = document.screening.cgiaction.value;\n";
    print "        document.screening.cgiaction.value = \"editcommitment\";\n";
    print "        document.screening.submit();\n";
    print "        document.screening.cgiaction.value = tempcgiaction;\n";
    print "        return (true);\n";
    print "    }\n";
    print "}\n";
    print "//-->\n";
    print "</script>\n";
    print "</head>\n";
    print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<form name=screening enctype=\'multipart/form-data\' method=post action=\"$ONCSCGIDir/MOCC_review.pl\">\n";
    print "<table border=0 align=center width=650><tr><td>\n";
    print "<input name=cgiaction type=hidden value=\"createcommitment\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=issueid type=hidden value=$thisissueid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    print "<table border=0 width=650 cellspacing=10 align=center>\n";
    eval {
	$activity = "Retrieving info for issue $thisissueid from Edit_Screens";
	print doIssueTable (iid => $thisissueid, dbh => $dbh, schema => $SCHEMA);
	print doIssueSourceTable (iid => $thisissueid, dbh => $dbh, schema => $SCHEMA);
	print doRemarksTable (dbh => $dbh, schema => $SCHEMA, iid => $thisissueid);
    };
    if ($@) {
	my $logmessage = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$logmessage =~ s/\n/\\n/g;
	$logmessage =~ s/\'/\'\'/g;
	print "<script language=javascript><!--\n";
	print "   alert('$logmessage');\n";
	print "//--></script>\n";
    }
    if ($showexistingcommitments) {
	print "<tr><td><hr width=70%></td></tr>\n";
	print "<tr><td colspan=2><b><li>Commitments based on this issue:</b><br>\n";
	print "<table width=90% align=center cellspacing=10><tr><td align=left><b>In Process:</b><br>\n";
	my $color = "#eeeeee";
	my $cflag = 1;
	print "<table border=1 width=600 cellspacing=0 cellpadding=0><tr><td>";
	print "<table align=left width=100% bgcolor=#ffffff cellpadding=0 cellspacing=0>\n";
	my $comms;
	foreach $key (keys %commitmenthash) {
	    if ($commitmentusedhash{$key} ne $MOCC_statusid) {
		$comms++;
		my $ctext = &getDisplayString ($commitmenttexthash{$key}, 70);
		print "<tr bgcolor=$color><td><font face=arial size=-1 color=#000000>C$commitmenthash{$key} - $ctext</font></tr></td>\n";
		$color = ($color eq "#ffffff") ? "#eeeeee" : "#ffffff";
	    }
	}
	if ($comms == 0) {
	    print "<tr bgcolor=#ffffff><td>None</td></tr>\n";
	}
	print "</table></td></tr></table>\n";
	print "</td></tr>\n";
	print "<tr><td align=left><b>In Commitment Coordinator Review:</b><br>\n";
	print "<table width=600 border=0><tr><td>\n";
	print "<select name=commitmentselect size=5 ondblclick=\"return(edit_selected_commitment());\">\n";
	foreach $key (keys %commitmenthash) {
	    if ($commitmentusedhash{$key} eq $MOCC_statusid) {
		    my $ctext = &getDisplayString ($commitmenttexthash{$key}, 80);
		    print "<option value=$key>C$commitmenthash{$key} - $ctext\n";
		}
	}
	my $spaces = &nbspaces (100);
	print "<option value=blank>$spaces\n";
	print "</select></td></tr></table></td></tr>\n";
	print "</table></td></tr></table></td></tr>\n";
	print "</table><center>\n";
	print "<input type=button name=editcommitment value=\"Edit Selected Commitment\" onclick=\"return(edit_selected_commitment())\">\n";
    }
    else {
	print "</table>\n";
    }
    print "<input type=button name=newcommitment value=\"Create Potential Commitment from this Issue\" onclick=\"return(create_new_commitment())\">\n";
    print "</td></tr></table> \n</form> \n<br><br><br>\n";
    print "</body> \n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
}   ###################  endif queryissue  #######################

# save the commitment
######################################
if ($cgiaction eq "save_commitment") {
######################################
    no strict 'refs';
    
    #control variables
    my $issueid = $cmscgi->param('issueid');
    my $sourcedocid = $cmscgi->param('sourcedocid');
    my $issuesourcedocsql;
    my $isnewsourcedocument = ($sourcedocid eq 'NEW');
    my $duedate = $cmscgi->param('duedate');
    $duedate = ($duedate eq "") ? "NULL" : "TO_DATE('$duedate', 'MM/DD/YYYY')";
    my $ll = $cmscgi -> param ('disciplinelead');
    my $doerespmgr = $cmscgi -> param ('DOEresponsiblemanager');
    $doerespmgr = ($doerespmgr) ? $doerespmgr : "";
    my $respmgr = $cmscgi -> param ('BSCresponsiblemanager');
    $respmgr = ($respmgr) ? $respmgr : "NULL";
    my $externalid = $cmscgi -> param ('externalid');
#    my $externalidsql = ($externalid) ? '$externalid' : "NULL";
    my $activity;
    my $nextstatusid = 1; # Commitment Coordinator Review
    
    # Find pertinent user information
    # Site id of the user is the same for the commitment
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);
    
    # boolean variables, should be 0 or -1 (true/false)
    my $issuehasimage = $cmscgi->param('issuehasimage');
    my $issuehassourcedoc = $cmscgi->param('issuehassourcedoc');
    my $processsourcedoc = 0;
    my $isnewcommitment = $cmscgi->param('isnewcommitment');
    
    #issue variables
    my $imagefile = $cmscgi->param('image');
    my $imageextension = '';
    my $imagemimetype = '';
    my $imageinsertstring;
    my $isnewimage = 0;  # false
    my $imagesize = 0;
    my $imagedata = '';
    my $pagenumber = $cmscgi->param('page');
    my $categoryid = lookup_single_value($dbh, 'issue', 'categoryid', $issueid);
    
    # commitment variables
    my $commitmentid;
    eval {
	$activity = "Get next commitment ID from sequence";
	$commitmentid = ($isnewcommitment) ? get_next_id($dbh, 'Commitment') : $cmscgi->param('commitmentid');
	$dbh -> commit;
    };
    if ($@) {
	$dbh -> rollback;
	my $alertstring = errorMessage ($dbh, $username, $usersid, 'sourcedocid_seq', "", $activity, $@);
	    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	    print "<!--\n";
	    print "alert(\"$alertstring\");\n";
	    print "parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	    print "//-->\n";
	    print "</script>\n";
	    &oncs_disconnect($dbh);
	    exit 1;
    }
    my $commitmenttext = $cmscgi->param('text');
    my $commitmenttextsql = ($commitmenttext) ? ":textclob" : "NULL";
    my $primarydiscipline = $cmscgi->param('discipline');
    my $commitmentlevelid = $cmscgi->param('commitmentlevelid');;
    my $commitmentcomment = $cmscgi->param('commenttext');
    my $commitmentcommentsql = ($commitmentcomment) ? ":commitmentcommentclob" : "NULL";
    
    #source document variables
    my $accessionnum = $cmscgi->param('accessionnum');
    my $title = $cmscgi->param('title');
    $title =~ s/\'/\'\'/g;
    my $signer = $cmscgi->param('signer');
    $signer =~ s/\'/\'\'/g;
    my $email = $cmscgi->param('emailaddress');
    $email =~ s/\'/\'\'/g;
    my $areacode = $cmscgi->param('areacode');
    my $phonenumber = $cmscgi->param('phonenumber');
    my $documentdate = $cmscgi->param('documentdate');
    my $sourceorganizationid = $cmscgi->param('organizationid');
    
    #process image file
    if (($imagefile) && ($issuehasimage == 0)) {
	my $bytesread = 0;
	my $buffer = '';
	# read a 16 K chunk and append the data to the variable $filedata
	while ($bytesread = read($imagefile, $buffer, 16384)) {
	    $imagedata .= $buffer;
	    $imagesize += $bytesread;
	}
	$imagemimetype = $cmscgi->uploadInfo($imagefile)->{'Content-Type'};
	#$imagemimetype = 'NULL';
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
    
    #sql strings
    my $sourcesqlstring;
    if (($isnewsourcedocument) && ($issuehassourcedoc == 0)) {
	# we've got to post the new source document information first
	$processsourcedoc = -1;  #true
	$activity = "Get Next Sourcedoc Sequence";
	eval {
	    $sourcedocid = get_next_id($dbh, 'sourcedoc');
	    $dbh -> commit;
	};
	if ($@) {
	    $dbh -> rollback;
	    my $alertstring = errorMessage($dbh, $username, $usersid, 'sourcedocid_seq', "", $activity, $@);
	    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	    print "<!--\n";
	    print "alert(\"$alertstring\");\n";
	    print "parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	    print "//-->\n";
	    print "</script>\n";
	    &oncs_disconnect($dbh);
	    exit 1;
	}
	$email = ($email) ? "'$email'" : 'NULL';
	$areacode = ($areacode) ? "'$areacode'" : 'NULL';
	$phonenumber = ($phonenumber) ? "'$phonenumber'" : 'NULL';
	
	$sourcesqlstring = "INSERT INTO $SCHEMA.sourcedoc
                                   (sourcedocid,accessionnum,title,signer,
                                    email,areacode,phonenumber,documentdate,
                                    organizationid,categoryid)
                                VALUES ($sourcedocid, '$accessionnum',
                                   '$title', '$signer',
                                    $email, $areacode, $phonenumber,
                                    TO_DATE('$documentdate', 'MM/DD/YYYY'),
                                    $sourceorganizationid, $categoryid)";

    }
    my $issueupdatesqlstring = "UPDATE $SCHEMA.issue
                                SET page = '$pagenumber',
                                    sourcedocid = $sourcedocid
                                WHERE issueid = $issueid";
    my $issuefileupdatesqlstring = "UPDATE $SCHEMA.issue
                                    SET image=$imageinsertstring,
                                        imageextension=$imageextension,
                                        imagecontenttype=$imagemimetype
                                    WHERE issueid=$issueid";
    my $commitmentsqlstring;
    if ($isnewcommitment) {
	$doerespmgr = ($doerespmgr) ? ", $doerespmgr" : ", NULL";
	$commitmentsqlstring = "INSERT INTO $SCHEMA.commitment
                                       (commitmentid, text, statusid,
                                        siteid, issueid,
                                        primarydiscipline,
                                        commitmentlevelid,
                                        updatedby, duedate, externalid,
                                        lleadid, managerid, doemanagerid)
                                    VALUES ($commitmentid, $commitmenttextsql,
                                        $nextstatusid, $siteid, $issueid,
                                        $primarydiscipline,
                                        $commitmentlevelid,
                                        $usersid, $duedate, '$externalid',
                                        $ll, $respmgr $doerespmgr)";
    }
    else {
	$doerespmgr = ($doerespmgr) ? ", doemanagerid = $doerespmgr" : "";
	$commitmentsqlstring = "UPDATE $SCHEMA.commitment
                                SET text = $commitmenttextsql,
                                    primarydiscipline = $primarydiscipline,
                                    commitmentlevelid = $commitmentlevelid,
                                    statusid = $nextstatusid,
                                    siteid = $siteid,
                                    updatedby = $usersid,
                                    duedate = $duedate,
                                    externalid = '$externalid',
                                    lleadid = $ll,
                                    managerid = $respmgr
                                    $doerespmgr
                                WHERE commitmentid = $commitmentid";
    }
    eval {
	if ($processsourcedoc) {
	    $activity = "Insert Source Document Information: $sourcedocid";
	    my $sourcecsr = $dbh->prepare($sourcesqlstring);
	    #print "$sourcesqlstring<br>\n";
	    $sourcecsr->execute;
	    $sourcecsr->finish;
	}
	$activity = "Update Issue Information: $issueid";
	my $csr = $dbh->prepare($issueupdatesqlstring);
	$csr->execute;
	if ($imagefile) {
	    $activity = "Insert image in issue record for issue: $issueid";
	    $csr = $dbh->prepare($issuefileupdatesqlstring);
	    $csr->bind_param(":imgblob", $imagedata, {ora_type => ORA_BLOB, ora_field => 'image' });
	    #print "$issuefileupdatesqlstring <br>\n";
	    $csr->execute;
	}
	$activity = ($isnewcommitment) ? "Insert Commitment $commitmentid" : "Update Commitment: $commitmentid";
	$csr = $dbh -> prepare ($commitmentsqlstring);
#	print STDERR "$commitmentsqlstring\n";
	$csr -> bind_param (":textclob", $commitmenttext, {ora_type => ORA_CLOB, ora_field => 'text' });
	$csr -> execute;
	if ($commitmentcomment) {
	    my $insertremark = "insert into $SCHEMA.commitment_remarks (commitmentid, usersid, text, dateentered) values ($commitmentid, $usersid, :remark, SYSDATE)";
	    $csr = $dbh -> prepare ($insertremark);
	    $csr -> bind_param (":remark", $commitmentcomment, {ora_type => ORA_CLOB, ora_field => 'text'});
	    $csr -> execute;
	}
	$csr->finish;
	$dbh->commit;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'commitment/issue/sourcedoc', "$commitmentid . $issueid . $sourcedocid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
	print "alert(\"$alertstring\");\n";
	print "parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	print "//-->\n";
	print "</script>\n";
    }
    else {
	if ($isnewcommitment) {
	    &log_activity($dbh, 'F', $usersid, "Commitment ".&formatID2($commitmentid, 'C')." added to the system");
	}
	else {
	    &log_activity($dbh, 'F', $usersid, "Commitment ".&formatID2($commitmentid, 'C')." updated by the Commitment Coordinator");
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
}  ####  endif save_commitment  ####

# pass the commitment to the next user (M&O Discipline Lead)
##############################
if ($cgiaction eq "pass_on") {
##############################
    no strict 'refs';
    
    ####  control variables  ####
    my $issueid = $cmscgi->param('issueid');
    my $sourcedocid = $cmscgi->param('sourcedocid');
    my $issuesourcedocsql;
    my $isnewsourcedocument = ($sourcedocid eq 'NEW');
    my $ll = $cmscgi -> param ('disciplinelead');
    my $doerespmgr = $cmscgi -> param ('DOEresponsiblemanager');
    my $respmgr = $cmscgi -> param ('BSCresponsiblemanager');
    my $externalid = $cmscgi -> param ('externalid');
    my $activity;
    my $nextstatusid = 17;
    
    ####  Find user info - same site id for user & commitment  ####
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);
    
    ####  boolean variables, should be 0 or -1 (true/false)  ####
    my $issuehasimage = $cmscgi->param('issuehasimage');
    my $issuehassourcedoc = $cmscgi->param('issuehassourcedoc');
    my $processsourcedoc = 0;
    
    ####  issue variables  ####
    my $imagefile = $cmscgi->param('image');
    my $imageextension = '';
    my $imagemimetype = '';
    my $imageinsertstring;
    my $isnewimage = 0;  # false
    my $imagesize = 0;
    my $imagedata = '';
    my $pagenumber = $cmscgi->param('page');
    my $categoryid = lookup_single_value($dbh, 'issue', 'categoryid',$issueid);
    
    ####  commitment variables  ####
    my $isnewcommitment = $cmscgi->param('isnewcommitment');
    my $commitmentid;
    eval {
	$activity = "Get next commitment ID from sequence";
	$commitmentid = ($isnewcommitment) ? get_next_id($dbh, 'Commitment') : $cmscgi->param('commitmentid');
	$dbh -> commit;
    };
    if ($@) {
	$dbh -> rollback;
	my $alertstring = errorMessage ($dbh, $username, $usersid, 'sourcedocid_seq', "", $activity, $@);
	    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	    print "<!--\n";
	    print "alert(\"$alertstring\");\n";
	    print "parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	    print "//-->\n";
	    print "</script>\n";
	    &oncs_disconnect($dbh);
	    exit 1;
    }
    my $commitmenttext = $cmscgi->param('text');
    my $commitmenttextsql = ($commitmenttext) ? ":textclob" : "NULL";
    my $primarydiscipline = $cmscgi->param('discipline');
    my $duedate = $cmscgi->param('duedate');
    $duedate = ($duedate eq "") ? "NULL" : "TO_DATE('$duedate', 'MM/DD/YYYY')";
    my $commitmentlevelid = $cmscgi->param('commitmentlevelid');
    
    ####  role variables  ####
    my $MOFL_roleid = 2; # MODL
    my $MOFL_usersid;
    ($MOFL_usersid) = lookup_column_values($dbh, 'defaultdisciplinerole', 'usersid', "roleid = $MOFL_roleid AND disciplineid = $primarydiscipline AND siteid = $siteid");
    
    my $commitmentcomment = $cmscgi->param('commenttext');
    
    ####  source document variables  ####
    my $accessionnum = $cmscgi->param('accessionnum');
    my $title = $cmscgi->param('title');
    $title =~ s/\'/\'\'/g;
    my $signer = $cmscgi->param('signer');
    $signer =~ s/\'/\'\'/g;
    my $email = $cmscgi->param('emailaddress');
    $email =~ s/\'/\'\'/g;
    my $areacode = $cmscgi->param('areacode');
    my $phonenumber = $cmscgi->param('phonenumber');
    my $documentdate = $cmscgi->param('documentdate');
    my $sourceorganizationid = $cmscgi->param('organizationid');
    
    ####  process image file  ####
    my $imagefilename = $imagefile;
    if (defined($imagefile) && ($issuehasimage == 0)) {
	my $bytesread = 0;
	my $buffer = '';
	$imagedata ='';
	while (<$imagefilename>) {
	    $imagedata .= $_;
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
    #sql strings
    my $sourcesqlstring;
    if (($isnewsourcedocument) && ($issuehassourcedoc == 0)) {
	# we've got to post the new source document information first
	$processsourcedoc = -1;  #true
	$activity = "Get Next Sourcedoc Sequence";
	eval {
	    $sourcedocid = get_next_id($dbh, 'sourcedoc');
	    $dbh -> commit;
	};
	if ($@) {
	    $dbh -> rollback;
	    my $alertstring = errorMessage($dbh, $username, $usersid, 'sourcedocid_seq', "", $activity, $@);
	    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	    print "<!--\n";
	    print "alert(\"$alertstring\");\n";
	    print "parent.control.location=\"$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	    print "//-->\n";
	    print "</script>\n";
	    &oncs_disconnect($dbh);
	    exit 1;
	}
	$issuesourcedocsql = ", sourcedocid = $sourcedocid";
	$email = ($email) ? "'$email'" : 'NULL';
	$areacode = ($areacode) ? "'$areacode'" : 'NULL';
	$phonenumber = ($phonenumber) ? "'$phonenumber'" : 'NULL';
	
	$sourcesqlstring = "INSERT INTO $SCHEMA.sourcedoc
                                   (sourcedocid,accessionnum,title,signer,
                                    email,areacode,phonenumber,documentdate,
                                    organizationid,categoryid)
                            VALUES ($sourcedocid, '$accessionnum',
                                    '$title', '$signer',
                                    $email, $areacode, $phonenumber,
                                    TO_DATE('$documentdate', 'MM/DD/YYYY'),
                                    $sourceorganizationid, $categoryid)";
    }
    my $issueupdatesqlstring = "UPDATE $SCHEMA.issue
                                SET page = '$pagenumber',
                                    sourcedocid = $sourcedocid
                                WHERE issueid = $issueid";
    my $issuefileupdatesqlstring = "UPDATE $SCHEMA.issue
                                    SET image=$imageinsertstring,
                                        imageextension=$imageextension,
                                        imagecontenttype=$imagemimetype
                                    WHERE issueid=$issueid";
    my $commitmentsqlstring;
    if ($isnewcommitment) {
	$doerespmgr = ($doerespmgr) ? ", $doerespmgr" : ", NULL";
	$commitmentsqlstring = "INSERT INTO $SCHEMA.commitment
                                       (commitmentid, statusid,
                                        siteid, issueid, text, 
                                        primarydiscipline, commitmentlevelid,
                                        updatedby, duedate, externalid, 
                                        lleadid, managerid, doemanagerid)
                                VALUES ($commitmentid,
                                        $nextstatusid, $siteid, $issueid,
                                        $commitmenttextsql, $primarydiscipline,
                                        $commitmentlevelid, $usersid, 
                                        $duedate, '$externalid',
                                        $ll, $respmgr $doerespmgr)";
    }
    else {
	$doerespmgr = ($doerespmgr) ? ", doemgrid = $doerespmgr" : "";
	$commitmentsqlstring = "UPDATE $SCHEMA.commitment
                                SET text = $commitmenttextsql,
                                    primarydiscipline = $primarydiscipline,
                                    commitmentlevelid = $commitmentlevelid,
                                    statusid = $nextstatusid,
                                    siteid = $siteid,
                                    updatedby = $usersid,
                                    duedate = $duedate,
                                    externalid = '$externalid',
                                    lleadid = $ll,
                                    managerid = $respmgr
                                    $doerespmgr
                                WHERE commitmentid = $commitmentid";
    }
    my $coordinator = "update $SCHEMA.issuerole set usersid=$usersid where issueid=$issueid";
    
    eval {
	my $cmo = "insert into $SCHEMA.commitmentrole (commitmentid, roleid, usersid) values ($commitmentid, 2, $ll)";
	my ($doeid) = $dbh -> selectrow_array ("select usersid from $SCHEMA.defaultdisciplinerole where $nodevelopers disciplineid = $primarydiscipline and roleid = 3"); 
	my $cdoe = "insert into $SCHEMA.commitmentrole (commitmentid, roleid, usersid) values ($commitmentid, 3, $doeid)";	

	if ($processsourcedoc) {
	    $activity = "Insert Source Document Information: $sourcedocid";
	    my $sourcecsr = $dbh->prepare($sourcesqlstring);
	    $sourcecsr->execute;
	    $sourcecsr->finish;
	}
	$activity = "Update Commitment Coordinator for issue $issueid";
	my $csr = $dbh -> prepare ($coordinator);
	$csr -> execute;
	
	$activity = "Update information for issue $issueid";
	my $csr = $dbh->prepare($issueupdatesqlstring);
	$csr->execute;
	
	if ($imagefile) {
	    $activity = "Insert image in issue record for issue $issueid";
	    $csr = $dbh->prepare($issuefileupdatesqlstring);
	    print "\n---> $imagedata <---\n\n";
	    $csr->bind_param(":imgblob", $imagedata, { ora_type => ORA_BLOB, ora_field => 'image' });
	    print "$issuefileupdatesqlstring <br>\n";
	    $csr->execute;
	}
	$activity = ($isnewcommitment) ? "Insert Commitment $commitmentid" : "Update Commitment $commitmentid";
#	print STDERR "$commitmentsqlstring\n";
	$csr = $dbh->prepare($commitmentsqlstring);
	$csr->bind_param(":textclob", $commitmenttext, {ora_type => ORA_CLOB, ora_field => 'text' });
	$csr->execute;
	
	if ($commitmentcomment) {
	    $activity = "Insert remark for commitment $commitmentid";
	    my $insertremark = "insert into $SCHEMA.commitment_remarks (commitmentid, usersid, text, dateentered) values ($commitmentid, $usersid, :remark, SYSDATE)";
	    $csr = $dbh -> prepare ($insertremark);
	    $csr -> bind_param (":remark", $commitmentcomment, {ora_type => ORA_CLOB, ora_field => 'text'});
	    $csr -> execute;
	}
	$activity = "Insert commitment roles for commitment $commitmentid";
	$csr = $dbh -> prepare ($cmo);
	$csr -> execute;
	$csr = $dbh -> prepare ($cdoe);
	$csr -> execute;
	$csr->finish;
	$dbh->commit;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'commitment/issue/sourcedoc', "$commitmentid . $issueid . $sourcedocid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
	print "alert(\"$alertstring\");\n";
	print "//-->\n";
	print "</script>\n";
    }
    else {
	if ($isnewcommitment) {
	    &log_activity($dbh, 'F', $usersid, "Commitment " . &formatID2($commitmentid, 'C') . " added to the system and passed to BSC Lead for estimate");
	}
	else {
	    &log_activity($dbh, 'F', $usersid, "Commitment " . &formatID2($commitmentid, 'C') . " updated and passed on to BSC Lead for estimate");
	}
	my $modls = $dbh -> prepare ("select distinct usersid from $SCHEMA.defaultdisciplinerole where disciplineid = $primarydiscipline and roleid = 2 and siteid = $siteid");
	$modls -> execute;
	while (my ($modlid) = $modls -> fetchrow_array) {
	    my $notification = &notifyUser(dbh => $dbh, schema => $SCHEMA, userID => $modlid);
	}
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
	print "parent.workspace.location=\"$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
	print "//-->\n";
	print "</script>\n";
    }
    &oncs_disconnect($dbh);
    print "</head><body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0></body></html>\n";
    exit 1;
}  ####  endif pass_on  ####

