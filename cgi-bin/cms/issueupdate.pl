#!/usr/local/bin/newperl
#
# CMS Issue Update Screen
#
# $Source: /data/dev/rcs/cms/perl/RCS/issueupdate.pl,v $
# $Revision: 1.20 $
# $Date: 2003/11/21 21:31:08 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: issueupdate.pl,v $
# Revision 1.20  2003/11/21 21:31:08  naydenoa
# Removed CIRS interface code - CIRS is retired.
#
# Revision 1.19  2002/09/25 19:41:37  naydenoa
# Cleaned up CIRS code - uses CIRS_procs module
#
# Revision 1.18  2002/08/24 00:56:57  naydenoa
# CIRS interface processing added - preliminary.
#
# Revision 1.17  2001/05/04 19:22:01  naydenoa
# Updated evals
#
# Revision 1.16  2001/01/31 00:24:36  naydenoa
# Fixed bug in source doc processing
#
# Revision 1.14  2000/12/11 21:46:09  naydenoa
# Updated log message
#
# Revision 1.13  2000/11/20 21:30:05  naydenoa
# Minor tweak
#
# Revision 1.12  2000/11/18 00:53:57  naydenoa
# Made source doc entry optional
#
# Revision 1.11  2000/11/09 00:58:06  naydenoa
# Added separate category for source
#
# Revision 1.10  2000/11/01 22:52:13  naydenoa
# Fixed signer display bug in source doc
#
# Revision 1.9  2000/10/31 17:02:41  naydenoa
# Added remark display and made remarks mandatory
# Made sure issue cannot be closed if it has commitments
# in Commitment Coordinator review
# Changed table width to 650, textarea width to 75
#
# Revision 1.8  2000/10/26 23:09:32  naydenoa
# Added remark entry and display
# Changed table with to 650, textarea width to 75
#
# Revision 1.7  2000/10/23 18:13:37  naydenoa
# Split issue into open and closed on query screen, updated
# log message
#
# Revision 1.6  2000/10/20 15:07:00  naydenoa
# Changed wording on issue close
#
# Revision 1.5  2000/10/19 23:32:35  naydenoa
# Added issue closure/reopening capabilities.
#
# Revision 1.4  2000/10/18 23:53:18  munroeb
# fixed syntax error in function formatID2 call
#
# Revision 1.3  2000/10/18 21:31:24  munroeb
# modified activity log message
#
# Revision 1.2  2000/10/17 17:11:47  naydenoa
# Cleaned up code, fixed html bug, took out log_history call.
#
# Revision 1.1  2000/10/10 20:53:06  naydenoa
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
tie my %lookup_values_open, "Tie::IxHash";
tie my %lookup_values_closed, "Tie::IxHash";

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

# print content type header
print $cmscgi->header('text/html');

my $cgiaction = $cmscgi->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = "issue";

my $issueid = ((defined($cmscgi->param("issueid"))) ? $cmscgi->param("issueid") : "");
my $message = '';

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
print "<title></title>\n";

print <<testlabel1;
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
function submitFormCGIResults(script, command) {
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'control';
    document.$form.submit();
}
function submitFormWorkspace(script, command) {
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'workspace';
    document.$form.submit();
    }
function processQuery() {
    if ((document.$form.issueidopen.options[document.$form.issueidopen.options.length - 1].selected == 1) || (document.$form.issueidclosed.options[document.$form.issueidclosed.options.length - 1].selected == 1)) {
	alert ('You must first select an issue');
    }
    else if (document.$form.issueidopen.selectedIndex >= 0) { 
	document.$form.issueid.value = document.$form.issueidopen[document.$form.issueidopen.selectedIndex].value;
	submitForm('$form','issueupdate');
    }
    else if (document.$form.issueidclosed.selectedIndex >= 0) {
	document.$form.issueid.value = document.$form.issueidclosed[document.$form.issueidclosed.selectedIndex].value;
	submitForm('$form','issueupdate');
    }
    else  {
	alert ('You must first select an issue');
    }
}
//-->
</script>
<script language="JavaScript" type="text/javascript">
<!--
    doSetTextImageLabel('Issue Update');
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

    print<<testlabel1;
    <table border=0 align=center width=650><tr><td><center>
    <form name=$form enctype="multipart/form-data" method=post target="control">
    <input name=cgiaction type=hidden value="query">
    <input name=loginusersid type=hidden value=$usersid>
    <input name=loginusername type=hidden value=$username>
    <input name=issueid type=hidden value=$issueid>
    <input type=hidden name=schema value=$SCHEMA>
testlabel1
    eval {
        print "<br><b>Open Issues:</b><br><br>\n";
        print "<select size=10 name=issueidopen onDblClick=\"processQuery();\">\n";
        %lookup_values_open = get_lookup_values($dbh, "issue", 'issueid', "text", "isclosed='F' order by issueid");
        foreach my $key (keys %lookup_values_open) {
            print "<option value=$key>I" . lpadzero($key,5) . " - " . getDisplayString($lookup_values_open{$key},60) . "</option>\n";
        }
        print "<option value=blank>" . &nbspaces(60) . "\n";
        print "</select>\n";
        print "<br><br><br><b>Closed Issues:</b><br><br>\n";
        print "<select size=10 name=issueidclosed onDblClick=\"processQuery();\">\n";
        %lookup_values_closed = get_lookup_values($dbh, "issue", 'issueid', "text", "isclosed='T' order by issueid");
        foreach my $key (keys %lookup_values_closed) {
            print "<option value=$key>I" . lpadzero($key,5) . " - " . getDisplayString($lookup_values_closed{$key},60) . "</option>\n";
        }
        print "<option value=blank>" . &nbspaces (60) . "\n";
        print "</select><br><br><br>\n";
        print "<input type=button name=querysubmit value='Update Issue' onClick=\"processQuery();\">\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"issue update -- query page",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/\'/\'\'/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }
    print "</form></body></html>\n";
    &oncs_disconnect($dbh);
}

##################################
if ($cgiaction eq "issueupdate") {
##################################
    my $activity;
    my $issuehassourcedoc = $cmscgi -> param ('issuehassourcedoc');
    
    my %categoryhash;
    my %sourcedochash;
    my %keywordhash;
    my %issuekeyword;
    my %orghash;
    my %ihash;
    my %issuehash;
    my $issuehasimage;
    my $imageextension;
    my $closed;
    my $sourcedocid;
    my %sourceinfohash;
    my $sourceaccnum;
    my $sourcetitle;
    my $sourcesigner;
    my $sourceemail;
    my $sourcearea;
    my $sourcephone;
    my $sourcedate;
    my $sourceorgid;

    eval {
	$activity = "Retrieve info from lokup tables";
        %categoryhash = get_lookup_values($dbh, 'category', 'description', 'categoryid', "isactive='T'");
        %sourcedochash = get_lookup_values($dbh, 'sourcedoc', "accessionnum || ' - ' || title || ' - ' || to_char(documentdate, 'MM/DD/YYYY') || ';' || sourcedocid", 'sourcedocid');
        %keywordhash = get_lookup_values($dbh, 'keyword', 'description', 'keywordid', "isactive='T'");
        %issuekeyword = get_lookup_values($dbh, "issuekeyword", "keywordid", "'True'", "issueid=$issueid");
        %orghash = get_lookup_values($dbh, 'organization', "name || ';' || organizationid", 'organizationid');
        %ihash = get_lookup_values ($dbh, 'issue', "TO_CHAR(dateoccurred, 'MM/DD/YYYY') || ';' || issueid", 'issueid');
	$activity = "Get issue info";
        %issuehash = get_issue_info ($dbh, $issueid);
	($issuehasimage) = $dbh -> selectrow_array ("select count (*) from $SCHEMA.issue where issueid=$issueid and imageextension is not null");
	$imageextension = lookup_single_value($dbh, 'issue', 'imageextension', $issueid);
	$sourcedocid = $issuehash{'sourcedocid'};
	($closed) =  $dbh -> selectrow_array ("select isclosed from $SCHEMA.issue where issueid = $issueid");
	if ($sourcedocid) {
	    %sourceinfohash = get_sourcedoc_info ($dbh, $sourcedocid);
	    $sourceaccnum = $sourceinfohash{'accessionnum'};
	    $sourcetitle = $sourceinfohash{'title'};
	    $sourcesigner = $sourceinfohash{'signer'};
	    $sourceemail = $sourceinfohash{'email'};
	    $sourcearea = $sourceinfohash{'areacode'};
	    $sourcephone = $sourceinfohash{'phonenumber'};
	    $sourcedate = $sourceinfohash{'documentdate'};
	    $sourceorgid = $sourceinfohash{'organizationid'};
	}
    };
    if ($@) {
	my $logmessage = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$logmessage =~ s/\n/\\n/g;
	$logmessage =~ s/\'/\'\'/g;
        print "<script language=javascript><!--\n";
        print "   alert('$logmessage');\n";
        print "//--></script>\n";
    }
    my $issuetext = $issuehash{'text'};
    my $dateoccurred = $issuehash{'dateoccurred'};
    my $page = $issuehash{'page'};
    my $categoryid = $issuehash{'categoryid'};
    my $issuestr = substr('0000'.$issueid, -5);
    
    my $key = '';
    my $value = '';
    
    # if there is an image, retrieve it for display;
    if ($issuehasimage) {
        my $image = $CMSFullImagePath . "/issueimage$issueid$imageextension";
        if (open (OUTFILE, "| ./File_Utilities.pl --command writeFile --protection 0664 --fullFilePath $image")) {
            print OUTFILE get_issue_image($dbh, $issueid);
            close OUTFILE;
        }
        else {
            print "could not open file $image<br>\n";
        }
    }
    print<<somejavascripts;
    <script language="JavaScript" type="text/javascript"><!--
    function update_issue_table() {
        var tempcgiaction;
        var returnvalue = true;
        if (validate_issue_data()) {
            document.issueupdate.cgiaction.value = "updateissuetable";
            selectemall(document.issueupdate.keywords);
            submitForm ('issueupdate', 'updateissuetable');
        }
        else {
            returnvalue = false;
        }
        return (returnvalue);
    }
    function validate_issue_data() {
        var msg = "";
        var tmpmsg = "";
        var returnvalue = true;
        var validateform = document.issueupdate;
        msg += (validateform.issuetext.value=="") ? "You must enter the issue text.\\n" : "";
        msg += ((tmpmsg = validate_date(validateform.dateoccurred_year.value, validateform.dateoccurred_month[validateform.dateoccurred_month.selectedIndex].value, validateform.dateoccurred_day[validateform.dateoccurred_day.selectedIndex].value, 0, 0, 0, 0, true, false, false)) == "") ? "" : tmpmsg + "\\n";
        if (validateform.issuehasimage.value == 0 && validateform.oldimage.value == 0 && validateform.sourcedocid.value != '') {
            msg += (validateform.image.value=="") ? "You must enter a scanned image of the issue.\\n" : "";
            msg += (validateform.page.value=="") ? "You must enter the page number of the issue.\\n" : "";
        }
        if (validateform.issuehassourcedoc.value == 0) {
//            msg += (validateform.sourcedocid.value =='') ? "You must select the source document or enter data for it.\\n" : "";
            if (validateform.sourcedocid.value=="NEW") {
                msg += ((tmpmsg = validate_accession_number(validateform.accessionnum.value,true)) == "") ? "" : tmpmsg + "\\n";
                msg += (validateform.title.value=="") ? "You must enter the title of the source document.\\n" : "";
                msg += (validateform.signer.value=="") ? "You must enter the signer of the source document.\\n" : "";
                msg += ((validateform.areacode.value != "") && (validateform.areacode.value.length < 3)) ? "You have enterd an invalid area code.\\n" : "";
                msg += ((validateform.phonenumber.value != "") && (validateform.phonenumber.value.length < 7)) ? "You have enterd an invalid phone number.\\n" : "";
                msg += ((tmpmsg = validate_date(validateform.documentdate_year.value, validateform.documentdate_month.value, validateform.documentdate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : tmpmsg + "\\n";
                msg += (validateform.organizationid.value=='') ? "You must select the organization the source document came from.\\n" : "";
            }
        }
        msg += (validateform.category[validateform.category.selectedIndex].value=='') ? "You must select the category for this issue.\\n" : "";
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

    print "<form target=control action=\"$ONCSCGIDir/issueupdate.pl\" enctype=\"multipart/form-data\" method=post name=issueupdate>\n";
    print "<input name=cgiaction type=hidden value=\"updateissuetable\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=issueid type=hidden value=$issueid>\n";
    print "<input type=hidden name=schema value=$SCHEMA><center>\n";
    print "<table summary=\"enter issue table\" width=650 align=center cellspacing=10 border=0>\n";
    print "<tr><td><table width=650 align=center cellspacing=10>\n";
    print "<tr><td><b><li>Issue ID: &nbsp;&nbsp; I$issuestr</td></tr>\n";
    print "<tr><td align=left><b><li>Issue Text:&nbsp;&nbsp;</b>\n";
    print "(be as clear and complete as possible)<br>\n";
    print "<textarea name=issuetext cols=75 rows=5>$issuetext</textarea></td></tr>\n";
    print "<tr><td align=left><b><li>Date of Occurence:&nbsp;&nbsp;</b>\n";
    print build_date_selection('dateoccurred', 'issueupdate', $dateoccurred);
    print "<br>(Use date of letter or date entered if issue does not have a specific date)</td></tr>\n";
    print "<tr><td align=left><b><li>Issue Category:&nbsp;&nbsp;</b>\n";
    print "<select name=category>\n";
    print "<option value=''>Select An Issue Category\n";
    foreach $key (sort keys %categoryhash) {
        if ($categoryid == $categoryhash{$key}){
	    print "<option value=\"$categoryhash{$key}\" selected>$key\n";
        }
        else {
	    print "<option value=\"$categoryhash{$key}\">$key\n";
        }
    }
    print"</select>\n";
    print <<issueform5;
</td></tr>
<tr><td align=left><b><li>Keywords:&nbsp;&nbsp;</b>
(optional, do not select any if not available)<br>
<table border=0 summary="Keyword Selection" align=center>
<tr align=Center><td><b>Keyword List</b></td>
<td>&nbsp;</td>
<td><b>Keywords Selected</b></td></tr>
<tr><td>
<select name=allkeywordlist size=5 multiple ondblclick="process_multiple_dual_select_option(document.issueupdate.allkeywordlist, document.issueupdate.keywords, 'move')">
issueform5
    my $word;
    my $value='';
    foreach $key (sort keys %keywordhash) {
        if ($issuekeyword{$keywordhash{$key}} ne 'True') {
	    $word=$key;
	    $word =~ s/;$keywordhash{$key}//g;
	    print "<option value=\"$keywordhash{$key}\">$word\n";
        }
    }
print "<option value=''>" .  &nbspaces(50) . "\n";
    print<<issueform6;
</select></td>
<td>
<input name=keywordrightarrow title="Click to select the keyword(s)" value="-->" type=button onclick="process_multiple_dual_select_option(document.issueupdate.allkeywordlist, document.issueupdate.keywords, 'move')">
<br>
<input name=keywordleftarrow title="Click to remove the selected keyword(s)" value="<--" type=button onclick="process_multiple_dual_select_option(document.issueupdate.keywords, document.issueupdate.allkeywordlist, 'move')"></td>
<td>
<select name=keywords size=5 multiple ondblclick="process_multiple_dual_select_option(document.issueupdate.keywords, document.issueupdate.allkeywordlist, 'move')">
issueform6

    foreach $key (sort keys %keywordhash) {
	if ($issuekeyword{$keywordhash{$key}} eq 'True') {
	    my $word=$key;
	    $word =~ s/;$keywordhash{$key}//g;
	    print "<option value=\"$keywordhash{$key}\">$word\n";
	}
    }
    print "<option value=''>" . nbspaces(50) . "</select></td></tr></table></td></tr>\n";
    my ($inreview) = $dbh -> selectrow_array ("select count (*) from $SCHEMA.commitment where issueid = $issueid and statusid = 1");
    if ($inreview > 0) {
        print "<tr><td><li><b>Issue cannot be closed because it has commitments in Commitment Coordinator Review</b></td></tr>\n";
    }
    else {
	print "<tr><td><b><li>Issue is closed: &nbsp&nbsp</b>\n";
	if ($closed eq 'T') {
	    print "<input type=checkbox name=isclosed value=\"T\" checked>\n";
	}
	elsif ($closed eq 'F') {
	    print "<input type=checkbox name=isclosed value=\"T\">\n";
        }
	print "</td></tr>\n";
    }
    print "<tr><td><hr width=70%></td></tr>\n";

    print "<tr><td align=left><b><li>Issue Source Image File:</b>&nbsp; &nbsp;\n";
    if ($issuehasimage){
        print "<a href='$CMSImagePath/issueimage$issueid$imageextension' target=imagewin>Click for the image source file</a>\n. Select a different image if necessary.\n";
        print "<input name=oldimage type=hidden value=-1>\n";
    }
    else {
        print "<input name=oldimage type=hidden value=0>\n";
    }
    print"<input type=file name=image size=50 maxlength=256></td></tr>\n";
    print "<input name=issuehasimage type=hidden value=0>\n";
    print<<issueform3;
<tr><td align=left><b><li>Source Document Page Number:&nbsp;&nbsp;</b>
<input name=page type=text maxlength=5 size=5 value="$page">
</td></tr>
issueform3
    print <<source1;
<tr><td align=left><b><li>Source Document: &nbsp; &nbsp;</b>
<select name=sourcedocid onChange="checkletter(document.issueupdate.sourcedocid)">
<option value=''>Select A Source Document
<option value=NEW>New Source Document
source1
    foreach $key (sort keys %sourcedochash) {
        my $sourcedocdescription = $key;
	$sourcedocdescription =~ s/;$sourcedochash{$key}//g;
	if (length($sourcedocdescription) > 60) {
	    $sourcedocdescription = substr($sourcedocdescription, 0, 60) . '...';
	}
	if ($sourcedochash{$key} == $sourcedocid){
	    print "<option value=\"$sourcedochash{$key}\" selected>$sourcedocdescription\n";
	}
	else {
	    print "<option value=\"$sourcedochash{$key}\">$sourcedocdescription\n";
	}
    }
    print <<source2;
</select>
<input name=issuehassourcedoc type=hidden value=0>
</td></tr>
<tr><td align=left><b><li>Accession Number:</b>&nbsp;&nbsp;
<input type=text name=accessionnum size=17 maxlength=17 value=$sourceaccnum> &nbsp; &nbsp; (optional)</td></tr>
<tr><td align=left><b><li>Document Title: &nbsp; &nbsp;</b>
<textarea name=title cols=60 rows=1 onblur="if(document.issueupdate.title.value.length > 1000){alert('Only 1000 characters allowed in a title');document.issueupdate.title.focus();}">$sourcetitle</textarea></td></tr>
<tr><td align=left><b><li>Signer:&nbsp;&nbsp;</b>
<input type=text name=signer size=30 maxlength=30 value="$sourcesigner"></td></tr>
<tr><td align=left><b><li>Signer's Email Address:&nbsp;&nbsp;</b>
<input type=text name=emailaddress size=50 maxlength=50 value=$sourceemail>
&nbsp; &nbsp; (optional)</td></tr>
<tr><td align=left><b><li>Area Code:</b>&nbsp;&nbsp;
(<input type=text name=areacode size=3 maxlength=3 value=$sourcearea>)
&nbsp;&nbsp;&nbsp;<b>Phone Number:&nbsp;&nbsp;</b>
<input type=text name=phonenumber size=7 maxlength=7 value=$sourcephone>  (no hyphens)
&nbsp; &nbsp; (optional)</td></tr>
<tr><td align=left><b><li>Document Date:&nbsp;&nbsp;</b>
source2

    print build_date_selection('documentdate', 'issueupdate', $sourcedate);
    print <<source3;
&nbsp; &nbsp; (Enter 1st if not available)</td></tr>
<tr><td align=left><b><li>Originator Organization:&nbsp;&nbsp;</b>
<select name=organizationid>
<option value=''>Select An Organization
source3
    foreach $key (sort keys %orghash) {
	my $orgdescription = $key;
	$orgdescription =~ s/;$orghash{$key}//g;
	if ($sourceorgid == $orghash{$key}) {
	    print "<option value=\"$orghash{$key}\" selected>$orgdescription\n";
	}
	else {
	    print "<option value=\"$orghash{$key}\">$orgdescription\n";
	}
    }
    print "</select></td></tr>\n";
    ###########
    print "<tr><td><hr width=70%></td></tr>\n";
    print writeComment (active => 1);
    print doRemarksTable (dbh => $dbh, schema => $SCHEMA, iid => $issueid);
    print "</table>\n";

    print<<javacheck;
    <script language="JavaScript" type="text/javascript"><!--
    function clearletter() {
        document.issueupdate.accessionnum.value = "";
        document.issueupdate.title.value = "";
        document.issueupdate.signer.value = "";
        document.issueupdate.emailaddress.value = "";
        document.issueupdate.areacode.value = "";
        document.issueupdate.phonenumber.value = "";
        document.issueupdate.organizationid.value = ""; 
   }
    function enableletter() {
        document.issueupdate.accessionnum.disabled = false;
        document.issueupdate.title.disabled = false;
        document.issueupdate.signer.disabled = false;
        document.issueupdate.emailaddress.disabled = false;
        document.issueupdate.areacode.disabled = false;
        document.issueupdate.phonenumber.disabled = false;
        document.issueupdate.documentdate_month.disabled = false;
        document.issueupdate.documentdate_day.disabled = false;
        document.issueupdate.documentdate_year.disabled = false;
        document.issueupdate.organizationid.disabled = false;
    }
    function fillout_letter() {
	var validateform = document.issueupdate;
	var tempcgiaction;
	tempcgiaction = document.issueupdate.cgiaction.value;
	document.issueupdate.cgiaction.value = "fillout_letter";
	document.issueupdate.submit();
	document.issueupdate.cgiaction.value = tempcgiaction;
	return (true);
    }
    function checkletter(letterselection) {
        if (letterselection.value!="NEW" && letterselection.value != ''){
	    clearletter();
	    enableletter();
	    fillout_letter();
        }
	else {
	    clearletter();
	    enableletter();
	}
    }
    //-->
    </script>
javacheck
    print<<issueform6tootoo;
<center>
<input type=button name=submitupdate value="Submit Update" title="Post Issue Update" onClick="update_issue_table();">
</center></td></tr></table></form><br><br><br><br></body></html>
issueform6tootoo

    &oncs_disconnect ($dbh);
    exit 1;
}  ###############  endif issueupdate  ################

#####################################
if ($cgiaction eq "fillout_letter") {
#####################################

    my $sourcedocid = $cmscgi->param('sourcedocid');
    my %sourcedocinfo = get_sourcedoc_info ($dbh, $sourcedocid);
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

    print <<letterupdate1;
    <script language="JavaScript" type="text/javascript"><!--
        parent.workspace.issueupdate.accessionnum.value='$accessionnum';
        parent.workspace.issueupdate.title.value='$title';
        parent.workspace.issueupdate.signer.value='$signer';
        parent.workspace.issueupdate.emailaddress.value='$emailaddress';
        parent.workspace.issueupdate.areacode.value='$areacode';
        parent.workspace.issueupdate.phonenumber.value='$phone';
        parent.workspace.issueupdate.documentdate_month.value=$docmonth;
        parent.workspace.issueupdate.documentdate_day.value=$docday;
        parent.workspace.issueupdate.documentdate_year.value=$docyear;
        parent.workspace.issueupdate.organizationid.value=$organizationid;
    //-->
    </script>
letterupdate1
    &oncs_disconnect($dbh);
    exit 1;
} ####### endif fillout_letter  ###################

#######################################
if ($cgiaction eq "updateissuetable") {
#######################################
    no strict 'refs';

    my $issueid = $cmscgi -> param ('issueid');
    my $sourcedocid = $cmscgi -> param ('sourcedocid');
    $sourcedocid = ($sourcedocid) ? $sourcedocid : 'NULL';
    my $newsource = ($sourcedocid eq "NEW");
    my $issuetext = $cmscgi->param('issuetext');
    my $dateoccurred = $cmscgi->param('dateoccurred');
    my $page = $cmscgi->param('page');
    $page = ($page) ? $page : 'NULL';
    my $categoryid = $cmscgi->param('category');
    $categoryid = ($categoryid) ? $categoryid : 'NULL';
    my $enteredby = $usersid;
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);
    my $isclosed = (defined($cmscgi -> param ('isclosed'))) ? $cmscgi -> param ('isclosed') : "F";
    my $remarks = $cmscgi -> param ('commenttext');
    my $issuehassourcedoc = ($sourcedocid ne "NULL"); #$cmscgi -> param ('issuehassourcedoc');

    ### issue image stuff
    my $issuehasimage = $cmscgi -> param ('issuehasimage');
    my $imagefile = $cmscgi -> param ('image');
    my $imageextension = '';
    my $imagemimetype = '';
    my $imageinsertstring;
    my $isnewimage = 0;  # false
    my $imagesize = 0;
    my $imagedata = '';

    ### process image file
    if (($imagefile) && ($issuehasimage == 0)) {
	my $bytesread = 0;
	my $buffer = '';
	# read a 16 K chunk and append the data to the variable $filedata
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
    # source document variables
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

############
    my $sourcesqlstring;
    my $processsourcedoc = 0;
    my $activity;
    if ($newsource) {
	# we've got to post the new source document information first
	$processsourcedoc = -1;  #true
	$activity = "Get Next Sourcedoc Sequence";
	$dbh->{RaiseError} = 1;
	$dbh->{AutoCommit} = 0;
	eval {
	    $sourcedocid = get_next_id($dbh, 'sourcedoc');
	};
	if ($@) {
	    my $alertstring = errorMessage($dbh, $username, $usersid, 'sourcedocid_seq', "", $activity, $@);
	    print <<sourcedocseqerror;
	    <script language="JavaScript" type="text/javascript">
	    <!--
	    alert("$alertstring");
            parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
            //-->
	    </script>
sourcedocseqerror
            $dbh->commit;
	    &oncs_disconnect($dbh);
	    exit 1;
	}
	$dbh->{RaiseError} = 0;
	$dbh->{AutoCommit} = 1;
	$email = ($email) ? "'$email'" : 'NULL';
	$areacode = ($areacode) ? "'$areacode'" : 'NULL';
	$phonenumber = ($phonenumber) ? "'$phonenumber'" : 'NULL';
	
	$sourcesqlstring = "INSERT INTO $SCHEMA.sourcedoc
                               (sourcedocid,accessionnum,title,signer,
                                    email,areacode,phonenumber,documentdate,
                                    organizationid)
                            VALUES ($sourcedocid, '$accessionnum',
                                   '$title', '$signer',
                                    $email, $areacode, $phonenumber,
                                    TO_DATE('$documentdate', 'MM/DD/YYYY'),
                                    $sourceorganizationid)";
	
    }
    else {
	$email = ($email) ? "'$email'" : 'NULL';
	$areacode = ($areacode) ? "'$areacode'" : 'NULL';
	$phonenumber = ($phonenumber) ? "'$phonenumber'" : 'NULL';
    
	$sourcesqlstring = "update $SCHEMA.sourcedoc
                          set accessionnum = '$accessionnum',
                          title = '$title',
                          signer = '$signer',
                          email = $email,
                          areacode = $areacode,
                          phonenumber = $phonenumber,
                          documentdate = to_date('$documentdate','MM/DD/YYYY'),
                          organizationid = $sourceorganizationid
                          where sourcedocid=$sourcedocid";
    }
    my $sqlstr = "update $SCHEMA.issue
                  set text = :textclob,
                      page = '$page',
                      categoryid = $categoryid,
                      dateoccurred = TO_DATE('$dateoccurred', 'MM/DD/YYYY'),
                      sourcedocid = $sourcedocid,
                      isclosed = '$isclosed'
                  where issueid = $issueid";
    my $issuefileupdatesqlstring = "UPDATE $SCHEMA.issue
                                    SET image = :imgblob,
                                        imageextension = $imageextension,
                                        imagecontenttype = $imagemimetype
                                     WHERE issueid = $issueid";
    my $remarkinsert = "insert into $SCHEMA.issue_remarks (usersid, text, dateentered, issueid) values ($usersid, :remark, SYSDATE, $issueid)";
    my $activity;
    eval {
	if ($issuehassourcedoc) {   
	    if ($processsourcedoc) {
		$activity = "Insert Source Document Information: $sourcedocid";
	    }
	    else {
		$activity = "Update Source Document Information: $sourcedocid";
	    }
	    my $sourcecsr = $dbh->prepare($sourcesqlstring);
	    $sourcecsr->execute;
	    $sourcecsr->finish;
	}
	$activity = "Update Issue Information: $issueid";
	my $csr = $dbh->prepare($sqlstr);
	$csr->bind_param(":textclob", $issuetext, {ora_type => ORA_CLOB, ora_field => 'text' });
	$csr->execute;
	if ($imagefile) {
	    $activity = "Insert image in issue record for issue $issueid";
	    $csr = $dbh->prepare($issuefileupdatesqlstring);
	    $csr->bind_param(":imgblob", $imagedata, {ora_type => ORA_BLOB, ora_field => 'image' });
	    #print "$issuefileupdatesqlstring <br>\n";
	    $csr->execute;
	}
	if ($remarks) {
	    $activity = "Add remarks for issue $issueid";
	    $csr = $dbh -> prepare ($remarkinsert);
	    $csr -> bind_param (":remark", $remarks, {ora_type => ORA_CLOB, ora_field => 'text'});
	    $csr -> execute;
	}
	#add keywords to record(s)
        my $oldkeywords = "delete from $SCHEMA.issuekeyword where issueid=$issueid";
	my $oldcsr = $dbh -> prepare ($oldkeywords);
	$oldcsr -> execute;
	my $keywordid;
	foreach $keywordid ($cmscgi->param('keywords')) {
	    if (($keywordid ne '')) {
		$activity = "Insert keyword: $keywordid for issue: $issueid.";
		my $keywordsqlstring = "INSERT INTO $SCHEMA.issuekeyword (issueid,keywordid) VALUES($issueid, $keywordid)";
		$csr = $dbh->prepare($keywordsqlstring);
		$csr->execute;
	    }
	}
	$dbh->commit;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'issue', "$issueid", $activity, $@);
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
	if ($issuehassourcedoc){
	    &log_activity($dbh, 'F', $usersid, "Issue " . &formatID2($issueid, 'I') . " and source document " . &formatID2($sourcedocid, 'S') . " updated by user $username");
	}
	else {
	    &log_activity($dbh, 'F', $usersid, "Issue " . &formatID2($issueid, 'I') . " updated by user $username");
	}
	print <<pageresults;
	<script language="JavaScript" type="text/javascript">
	<!--
        parent.workspace.location="$ONCSCGIDir/issueupdate.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
    }
    &oncs_disconnect($dbh);
    exit 1;
} ################  endif update_issue_table  ###############

print "<br><br><br><br></body></html>\n";
&oncs_disconnect($dbh);

