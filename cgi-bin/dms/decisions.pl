#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/dms/perl/RCS/decisions.pl,v $
#
# $Revision: 1.21 $
#
# $Date: 2004/06/14 16:36:00 $
#
# $Author: munroeb $
#
# $Locker:  $
#
# $Log: decisions.pl,v $
# Revision 1.21  2004/06/14 16:36:00  munroeb
# Moved QA status to page header for printed decision analysis and executive summary pages.
#
# Revision 1.20  2002/11/22 23:49:31  munroeb
# added missing semicolon to line 369
#
# Revision 1.19  2002/09/09 23:33:36  munroeb
# fixed sorting error in browse by id
#
# Revision 1.18  2002/08/08 21:11:49  munroeb
# added activity log monitoring
#
# Revision 1.17  2002/08/08 15:56:29  munroeb
# changed browse bgcolor to white, fixed sorting issues on browse
#
# Revision 1.16  2002/08/07 22:22:07  munroeb
# working on selection and option criteria empty textarea removals
#
# Revision 1.15  2002/08/07 15:14:58  munroeb
# fixed errors with the accession number validation.
#
# Revision 1.14  2002/08/06 15:47:00  munroeb
# added accession id checking and fixed selection criteria number entry
#
# Revision 1.13  2002/07/17 20:48:50  munroeb
# changed names to developed by and decision preparer fields, added info to confirmation popup, changed table backgrounds to
# white, added verbage to browse window.
#
# Revision 1.12  2002/07/12 20:11:07  munroeb
# removed expando boxes and fixed colors
#
# Revision 1.11  2002/07/12 17:11:27  munroeb
# fixed issues with browse save state
#
# Revision 1.10  2002/07/11 22:56:07  munroeb
# fixed several browse bugs
#
# Revision 1.9  2002/06/28 21:40:09  munroeb
# fixed browse errors and added attachments to the detail view
#
# Revision 1.8  2002/06/27 22:34:08  munroeb
# fixed browse errors
#
# Revision 1.7  2002/06/26 22:46:44  munroeb
# fixed attachment data error, viewprint windows, slash n - br
#
# Revision 1.6  2002/06/26 19:41:44  munroeb
# fixed uninitialized variable warnings
#
# Revision 1.5  2002/06/25 21:39:03  munroeb
# fixed bugs in browse and createNewEntry
#
# Revision 1.4  2002/06/03 22:26:23  munroeb
# first major release
#
# Revision 1.3  2002/05/24 19:44:11  munroeb
# First major check-in since March 20th - large changes in the data entry, create new entry and browse areas of the code
#
# Revision 1.2  2002/03/13 17:38:44  atchleyb
# added browse section and pasted in the mocup browse code.
#
# Revision 1.1  2002/03/08 21:06:40  atchleyb
# Initial revision
#
#
#

use integer;
use strict;
use DMS_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

$| = 1;
my $dmscgi = new CGI;
my $userid = $dmscgi->param("userid");
my $username = $dmscgi->param("username");
my $schema = $dmscgi->param("schema");
my $command = defined($dmscgi->param("command")) ? $dmscgi->param("command") : "";



my $decisionid = $dmscgi->param("decisionid");

&checkLogin ($username, $userid, $schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $dbh;
my $errorstr = "";
my %titles = (
    new => "Enter Decision",
    updatePending => "Update Pending Decision",
    browse => "Browse Decision",
    updateApproved => "Update Approved Decision",
    createNewEntry => "Create New Decision Package"
);

$dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;

# tell the browser that this is an html page using the header method
print $dmscgi->header('text/html');

# build page
print <<END_OF_BLOCK;

<html>
<head>
   <base target=main>
   <title>Decision Management System</title>
</head>

<script src=/dms/javascript/utilities.js></script>
<script src=/dms/javascript/widgets.js></script>

<script language=javascript>
<!--

function verify_$form (f){
// javascript form verification routine
  var msg = "";
  if (msg != "") {
    alert (msg);
    return false;
  }
  return true;
}

function submitForm(script, command) {
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'main';
    document.$form.submit();
}

//-->
</script>

<!--  topmargin=0 leftmargin=0 -->

<body background=$DMSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff>
END_OF_BLOCK

print "<form name=$form target=cgiresults onSubmit=\"return verify_$form(this)\" action=\"" . $path . "$form.pl\" method=post enctype='multipart/form-data'>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=command value=0>\n";
print "<input type=hidden name=decisionid value=$decisionid>\n";

######################################################################################################################
#
if ($command eq 'updateApproved') {
    eval {
        print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $titles{$command});

        ## Get Decision Maker Info
        #

        my $sql = "select decisionmaker, developedby from $schema.decisions where decisionid = \'$decisionid\'";

        my $sth = $dbh->prepare($sql);
        $sth->execute();

        my $decisionmaker = "";
        my $developedby = "";

        ($decisionmaker, $developedby) = $sth->fetchrow_array();

        $decisionmaker = 'NULL' if !($decisionmaker);
        $developedby = 'NULL' if !($developedby);

        $sql = "select a.firstname, a.lastname, b.description from $schema.users a, $schema.organization b ".
               "where a.organization = b.organizationid and a.id = $decisionmaker";

        my @dmArray = ();
        $sth = $dbh->prepare($sql);
        $sth->execute();
        @dmArray = $sth->fetchrow_array();

        ## Get Decision Developer Info
        #
        $sql = "select a.firstname, a.lastname, b.description from $schema.users a, $schema.organization b ".
               "where a.organization = b.organizationid and a.id = $developedby";

        my @dpArray = ();
        $sth = $dbh->prepare($sql);
        $sth->execute();
        @dpArray = $sth->fetchrow_array();

        ## Get Keywords Info
        #
        $sql = "select a.keyword from $schema.keywords a, $schema.decision_keywords b ".
               "where b.decisionid = \'$decisionid\' and a.keywordid = b.keywordid(+)";

        my @keywordArray = ();
        my $keywordString = '';
        $sth = $dbh->prepare($sql);
        $sth->execute();
        while (@keywordArray = $sth->fetchrow_array()) {
            $keywordString = $keywordString.'<li>'.$keywordArray[0].'</li>';
        }

        $keywordString = $keywordString.'&nbsp;';

        ## Main SQL statement
        #
        $sql = "select a.decisiontitle, a.accession, b.description, a.qa, a.decisiondate ".
               "from $schema.decisions a, $schema.decision_types b where a.decisiontype = b.id(+) ".
               "and a.decisionid = \'$decisionid\'";

        $sth = $dbh->prepare($sql);
        $sth->execute();

        my ($decisiontitle, $accession, $decisiontype, $qa, $decisiondate);
        ($decisiontitle, $accession, $decisiontype, $qa, $decisiondate) = $sth->fetchrow_array();

        $decisiontitle = '&nbsp;' if !($decisiontitle);
        $accession = "" if !($accession);
        $decisiontype = '&nbsp;' if !($decisiontype);
        $decisiondate = '&nbsp;' if !($decisiondate);

        $qa = 'Non QA' if $qa  eq 'F';
        $qa = 'QA' if $qa  eq 'T';

print <<EOB_HERE;

<center>

<script language="JavaScript">
<!--

    function validate_accession(num) {
        var msgString = "";
        if (num == "") {
            return true;
        } else if (num.length != 17) {
            alert("Accession Number has an invalid length");
            return false;
        } else if (num.length == 17) {
            var prefix = num.substr(0,3);
            var dot1 = num.substr(3,1);
            var dot2 = num.substr(12,1);
            var datepart = num.substr(4,8);
            var sequence = num.substr(13,4);

            if (dot1 != "." && dot2 != ".") {
                alert("The Accession Number must be in the format: 'ORG.YYYYMMDD.####'.");
                return false;
            }

            if (datepart.length != 8) {
                alert("The Accession Number must be in the format: 'ORG.YYYYMMDD.####'.");
                return false;
            }

            if (! isnumeric(sequence) || (sequence < 1)) {
                alert("Sequence portion of the accession number must be a positive 4 digit number '####'.");
                return false;
            }
        }
        return true;
    }

    function completeApproved(decisionid) {
        document.decisions.command.value = "completeApproved";
        document.decisions.action = '/cgi-bin/dms/decisions.pl';
        document.decisions.target = 'main';

        var returnvalue = validate_accession(document.decisions.accession.value);
        if (returnvalue == false) {
            document.decisions.accession.select();
            return false;
        }

        document.decisions.submit();
    }

//-->
</script>

<!-- Meta Data for Decision Package -->
<table width="700" cellpadding="3" cellspacing="0" border="1">
<tr><td bgcolor="#eeeeee"><font size="4"><b>Decision Package Status</b></font></td></tr>
<tr><td bgcolor="#ffffff"><font color="#005500">Approved, Waiting for Accession #</font></td></tr>
</table>

<br><br>

<!-- Meta Data for Decision Package -->
<table width="700" cellpadding="3" cellspacing="0" border="1" bgcolor="#ffffff">
<tr><td colspan="2" bgcolor="#eeeeee"><font size="4"><b>Primary Decision Information</b></font></td></tr>
<tr><td width="150" align="right"><b>Decision ID:</b></td><td>$decisionid</td></tr>
<tr><td width="150" align="right"><b>Title:</b></td><td>$decisiontitle</td></tr>
<tr><td width="150" align="right"><b>Accession #:</b></td><td><input type="text" size="25" name="accession" value="$accession"></td></tr>
<tr><td width="150" align="right"><b>Decision Type:</b></td><td>$decisiontype</td></tr>
<tr><td width="150" align="right"><b>QA:</b></td><td>$qa</td></tr>

<!-- Keywords Layout region -->

<tr><td width="150" align="right" valign="top"><b>Keywords:</b></td><td>$keywordString</td></tr>

<!-- End of Keywords Layout region -->

<tr><td width="150" align="right"><b>Decision Analysis Developed By:</b></td><td>$dpArray[0] $dpArray[1], $dpArray[2]</td></tr>
<tr><td width="150" align="right"><b>Decision Maker:</b></td><td>$dmArray[0] $dmArray[1], $dmArray[2]</td></tr>
<tr><td width="150" align="right"><b>Decision Date:</b></td><td>$decisiondate</td></tr>
</table>

<br>
<input type="button" value="Complete Decision Package" onclick='javascript:completeApproved("$decisionid");'>&nbsp;<input type="button" value="Cancel" onclick='javascript:submitForm("home","");'>
<br>

</td></tr></table>
</center>
</form>
</body>
</html>

EOB_HERE

    };
    if ($@) {
        my $message = errorMessage($dbh,$username,$userid,$schema,"generate entry/update screen.",$@);
            print doAlertBox(text => $message);
    }

######################################################################################################################
#
} elsif ($command eq 'updatePending') {
    eval {

        my ($decisiondate, $decisioncode, $qacode, $darecommendation, $dareferences, $developedby, $decisionmaker, $isdecisionapproved) = "";

        print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $titles{$command});

        my $sql = "select decisiontitle, accession, decisiontype, qa, to_char(decisiondate, \'MM/DD/YYYY\'), developedby, decisionmaker, darecommendation, dareferences, decisionapproved from $schema.decisions where decisionid = \'$decisionid\'";

        my $sth = $dbh->prepare($sql);
        $sth->execute();

        my @array = $sth->fetchrow_array();

        $developedby = $array[5];
        $decisionmaker = $array[6];
        $darecommendation = $array[7];
        $dareferences = $array[8];

        ## Decision Type Status
        #
        if ($array[2] eq "1") {
            $decisioncode = "<select name=optDecisionType><option value=1 selected>Key</option><option value=2>Supporting</option></select>";
        }

        if ($array[2] eq "2") {
            $decisioncode = "<select name=optDecisionType><option value=1>Key</option><option value=2 selected>Supporting</option></select>";
        }

        ## QA Status
        #
        if ($array[3] eq "T") {
            $qacode = "<select name=optQA><option value=F>Non QA</option><option value=T selected>QA</option></select>";
        }

        if ($array[3] eq "F") {
            $qacode = "<select name=optQA><option value=F selected>Non QA</option><option value=T>QA</option></select>";
        }

        ## Decision Approved Status
        #
        if ($array[9] eq 'T') {
            $isdecisionapproved = "<input type=checkbox name=chkDecisionApproved checked>";
        } else {
            $isdecisionapproved = "<input type=checkbox name=chkDecisionApproved>";
        }

        ## Get Keywords list from the Database
        #
        $sql = "select keywordid, keyword from $schema.keywords";
        my @array1 = ();
        my %keywordHash = ();

        $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@array1 = $sth->fetchrow_array()) {
            $keywordHash{$array1[0]} = $array1[1];
        }

        ## Get Pre-selected Keywords Array
        #
        $sql = "select a.keywordid, a.keyword from $schema.keywords a, $schema.decision_keywords b ".
               "where b.decisionid = \'$decisionid\' and a.keywordid = b.keywordid(+)";

        @array1 = ();
        my %keywordHash2 = ();

        $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@array1 = $sth->fetchrow_array()) {
            $keywordHash2{$array1[0]} = $array1[1];
        }

        my $keywordString = &build_dual_select("availkeywords","decisions", \%keywordHash, \%keywordHash2, "<b>Available Keywords</b>", "<b>Selected Keywords</b>");

        ## Get Developed By Information
        #
        my $developedbyString = "";
        my @developerArray = ();

        $sql = "select a.id, a.firstname, a.lastname, c.description from $schema.users a, $schema.organization c where a.organization = c.organizationid(+) and a.id in (select b.userid from $schema.user_roles b where b.role = 2)";
        $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@developerArray = $sth->fetchrow_array()) {
            ## figure out who needs to be selected in the picklist
            if ($developerArray[0] eq $developedby) {
                $developedbyString = $developedbyString."<option value=$developerArray[0] selected>$developerArray[1] $developerArray[2], $developerArray[3]</option>";
            } else {
                $developedbyString = $developedbyString."<option value=$developerArray[0]>$developerArray[1] $developerArray[2], $developerArray[3]</option>";
            }
        }

        ## Get Decision Maker Information
        #
        my $decisionMakerString = "";
        my @decisionMakerArray = ();

        $sql = "select a.id, a.firstname, a.lastname, c.description from $schema.users a, $schema.organization c where a.organization = c.organizationid(+) and a.id in (select b.userid from $schema.user_roles b where b.role = 3)";
        $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@decisionMakerArray = $sth->fetchrow_array()) {
            ## figure out who needs to be selected in the picklist
            if ($decisionMakerArray[0] eq $decisionmaker) {
                $decisionMakerString = $decisionMakerString."<option value=$decisionMakerArray[0] selected>$decisionMakerArray[1] $decisionMakerArray[2], $decisionMakerArray[3]</option>";
            } else {
                $decisionMakerString = $decisionMakerString."<option value=$decisionMakerArray[0]>$decisionMakerArray[1] $decisionMakerArray[2], $decisionMakerArray[3]</option>";
            }
        }

        my $dateString = &build_date_selection("decisiondate", "decisions", $array[4]);

        ## Get Executive Summary Information
        #
        $sql = "select statementofconsideration, esrecommendation, esdecision from $schema.decisions where decisionid = \'$decisionid\'";
        $sth = $dbh->prepare($sql);
        $sth->execute();

        my @esArray = $sth->fetchrow_array();

        ## Get Selection Criteria Information and build the tables
        #
        my @selectionArray = ();
        my $selectionString = "";
        my $i = 0;

            $sql = "select selectionid, title, description from $schema.selection_criteria where decisionid = \'$decisionid\' order by selectionid";
            $sth = $dbh->prepare($sql);
            $sth->execute();

            while (@selectionArray = $sth->fetchrow_array()) {
                $i++;
                $selectionString = $selectionString.'<table width="100%" cellspacing="0" cellpadding="3" border="0"><tr><td><b>#</b></td><td><b>Criteria</b></td></tr><tr><td><input type="text" size="2" name=sc1_'.$i.' value="'.$selectionArray[0].'"></td><td><input type="text" size="70" name=sc2_'.$i.' value="'.$selectionArray[1].'"></td></tr><tr><td colspan="2"><br><b>Selection Criteria Details:</b><br><textarea name=sc3_'.$i.' rows="3" cols="70">'.$selectionArray[2].'</textarea></td></tr></table><br>';
            }

            my $curSelectionCriteria = "<input type=hidden name=hidCurSelectionCriteria value=".$i.">";
            my $orgSelectionCriteria = "<input type=hidden name=hidOrgSelectionCriteria value=".$i.">";

        ## Get Option Rationale information and build the tables
        #
        $sql = "select optionid, description, optionrationale from $schema.options where decisionid = \'$decisionid\' order by optionid";

        my @optionArray = ();
        my $optionString = "";
        $i = 0;

        $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@optionArray = $sth->fetchrow_array()) {
            $i++;
            $optionString = $optionString.'<table width="100%" cellspacing="0" cellpadding="3" border="0"><tr><td><b>#</b></td><td><b>Option Description</b></td></tr><tr><td><input type="text" name=or1_'.$i.' size="2" value="'.$optionArray[0].'"></td><td><input type="text" size="70" name=or2_'.$i.' value="'.$optionArray[1].'"></td></tr><tr><td colspan="2"><br><b>Option Selection Rationale:</b><br><textarea name=or3_'.$i.' rows="3" cols="70">'.$optionArray[2].'</textarea></td></tr></table><br>';
        }

        my $curOptionRationale = "<input type=hidden name=hidCurOptionRationale value=".$i.">";
        my $orgOptionRationale = "<input type=hidden name=hidOrgOptionRationale value=".$i.">";

        ## Now get existing attachments
        #

        $sql = "select attachmentid, filename from $schema.attachments where decisionid = \'$decisionid\'";
        $sth = $dbh->prepare($sql);
        $sth->execute();

        my @attachmentArray = ();
        my $attachmentString = "";
        my $k = 1;

        while (@attachmentArray = $sth->fetchrow_array()) {
            $attachmentString = $attachmentString."<input type=checkbox name=attachmentDelete_$k value=$attachmentArray[0]> <a href=javascript:submitFormCGIResults($attachmentArray[0])>$attachmentArray[1]</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
            $k++;
        }

        my $j = $k - 1;
        my $curAttachment = "<input type=hidden name=hidCurAttachmentCount value=$j>";
        my $orgAttachment = "<input type=hidden name=hidOrgAttachmentCount value=$j>";

        print <<EOB_updatePending;
        <center>
        <br>

        <script language="JavaScript">
        <!--

        function validate_accession(num) {
            var msgString = "";
            if (num == "") {
                return true;
            } else if (num.length != 17) {
                alert("Accession Number has an invalid length");
                return false;
            } else if (num.length == 17) {
                var prefix = num.substr(0,3);
                var dot1 = num.substr(3,1)
                var dot2 = num.substr(12,1)
                var datepart = num.substr(4,8);
                var sequence = num.substr(13,4)

                if (dot1 != "." && dot2 != ".") {
                    alert("The Accession Number must be in the format: 'ORG.YYYYMMDD.####'.");
                    return false;
                }

                if (datepart.length != 8) {
                    alert("The Accession Number must be in the format: 'ORG.YYYYMMDD.####'.");
                    return false;
                }

                if (! isnumeric(sequence) || (sequence < 1)) {
                    alert("Sequence portion of the accession number must be a positive 4 digit number '####'.");
                    return false;
                }
            }
            return true;
        }

        function saveChanges() {
            var script = 'decisions';
            document.decisions.command.value = 'saveChanges';
            document.decisions.action = '/cgi-bin/dms/' + script + '.pl';

            for (index=0;index < document.decisions.availkeywords.length - 1;index++) {
                document.decisions.availkeywords.options[index].selected = true;
            }

            if (document.decisions.decisiondate_month.value == "" || document.decisions.decisiondate_day.value == "" || document.decisions.decisiondate_year.value == "") {
                document.decisions.decisionDate.value = "NULL";
            } else {
                document.decisions.decisionDate.value = document.decisions.decisiondate_month.value + "-" + document.decisions.decisiondate_day.value + "-" + document.decisions.decisiondate_year.value;
            }

            document.decisions.target = 'main';

            var returnvalue = validate_accession(document.decisions.decisionaccession.value);

            if (returnvalue == false) {
                document.decisions.decisionaccession.select();
                return false;
            }


            if (document.decisions.chkDecisionApproved.checked == true && document.decisions.chkDoneWithDataEntry.checked == true) {
                var msg = "You have checked that the Decision has been approved by the Decision Maker, and you are done with Data Entry.\\n\\nOnce you do this, you will not be able to make any more changes to the document.\\n\\nIs this correct?";
                if (confirm(msg)) {
                    document.decisions.submit();
                } else {

                }
            } else {
                document.decisions.submit();
            }
        }

        function addNewDeveloper() {
            var decisionid = "$decisionid";
            alert(decisionid);

            //document.decisions.target = 'main';
            //document.decisions.submit();
        }

        function addNewSelectionCriteria(curSelectionCriteria) {
            curSelectionCriteria = (curSelectionCriteria - 0) + 1;
            document.decisions.hidCurSelectionCriteria.value = curSelectionCriteria;
            document.all.selections.style.height = document.all.selections.clientHeight / 2;
            document.all.selections.innerHTML = document.all.selections.innerHTML + "<table width=100% cellspacing=0 cellpadding=3 border=0><tr><td><b>#</b></td><td><b>Criteria</b></td></tr><tr><td><input type=text size=2 name=sc1_" + curSelectionCriteria + " value=" + curSelectionCriteria + "></td><td><input type=text size=70 name=sc2_" + curSelectionCriteria + " value=></td></tr><tr><td colspan=2><br><b>Selection Criteria Details:</b><br><textarea name=sc3_" + curSelectionCriteria + " rows=3 cols=70></textarea></td></tr></table><br>";
        }

        function addNewOptionRationale(curOptionRationale) {
            curOptionRationale = (curOptionRationale - 0) + 1;
            document.decisions.hidCurOptionRationale.value = curOptionRationale;
            document.all.options.style.height = document.all.options.clientHeight / 2;
            document.all.options.innerHTML = document.all.options.innerHTML + "<table width=100% cellspacing=0 cellpadding=3 border=0><tr><td><b>#</b></td><td><b>Option Description</b></td></tr><tr><td><input type=text name=or1_" + curOptionRationale + " size=2 value=" + curOptionRationale + "></td><td><input type=text name=or2_" + curOptionRationale + " size=70 value=></td></tr><tr><td colspan=2><br><b>Option Selection Rationale:</b><br><textarea name=or3_" + curOptionRationale + " rows=3 cols=70></textarea></td></tr></table>";
        }

        function addNewAttachmentWidget(curAttachmentCount) {
            curAttachmentCount = (curAttachmentCount - 0) + 1;
            document.decisions.hidCurAttachmentCount.value = curAttachmentCount;
            document.all.attachments.style.height = document.all.attachments.clientHeight / 2;
            document.all.attachments.innerHTML = document.all.attachments.innerHTML + "<input type=file name=attachment><br>";
            //alert("<input type=file name=attachment_" + curAttachmentCount + "><br>");
        }

        function submitFormCGIResults(attachmentid) {
            document.viewattachment.action = '/cgi-bin/dms/display_image.pl';
            document.viewattachment.target = 'cgiresults';
            document.viewattachment.attachmentid.value = attachmentid;
            document.viewattachment.submit();
        }

        //-->
        </script>

<!--
        <table width="750" cellpadding="3" cellspacing="0" border="1">
        <tr><td bgcolor="#eeeeee"><font size="4"><b>Decision Package Status</b></font></td></tr>
        <tr><td bgcolor="#ffffcc">
        &nbsp;
        </td></tr>
        </table>

        <br>
        <br>

-->
        <table width="750" cellpadding="3" cellspacing="0" border="1" bgcolor="#ffffff">
        <tr><td colspan="2" bgcolor="#eeeeee"><font size="4"><b>Primary Decision Information</b></font></td></tr>
        <tr><td width="150" align="right"><b>Decision ID:</b></td><td>$decisionid</td></tr>
        <tr><td width="150" align="right"><b>Title:</b></td><td><input type="text" name="decisiontitle" size="50" value="$array[0]"></td></tr>
        <tr><td width="150" align="right"><b>Accession #:</b></td><td><input type="text" name="decisionaccession" size="50" value="$array[1]"></td></tr>

        <tr><td width="150" align="right"><b>Decision Type:</b></td><td>$decisioncode</td></tr>
        <tr><td width="150" align="right"><b>QA:</b></td><td>$qacode</td></tr>
        <tr><td width="150" align="right" valign="top"><b>Keywords:</b></td><td>

        <!-- Begin of Keywords Layout region -->

        $keywordString

        <!-- End of Keywords Layout region -->

        </td></tr>

        <tr><td width="150" align="right"><b>Decision Analysis Developed By:</b></td><td><select name=optDevelopedBy> $developedbyString </select> &nbsp; <!-- <a href="javascript:addNewDeveloper();"> Add Person to List</a> --> </td></tr>
        <tr><td width="150" align="right"><b>Decision Maker:</b></td><td><select name=optDecisionMaker>$decisionMakerString</select></td></tr>
        <tr><td width="150" align="right"><b>Decision Date:</b></td><td>$dateString&nbsp; $isdecisionapproved <b>Decision Approved?</b></td></tr>

        <input type=hidden name=decisionDate value="">

        </table>

        <br><br>
        <!-- Executive Summary Information -->
        <table width="750" cellpadding="6" cellspacing="0" border="1" bgcolor="#ffffff">
        <tr><td bgcolor="#eeeeee"><font size="4"><b>Executive Summary Information</b></font></td></tr>
        <tr><td>

        <br>
        <a name="soc">
        <font size="4">Statement for Consideration:</font>
        <!-- <a href="javascript:expandTextBox(document.decisions.soc, document.entryRemarks_button,'force',5);"><img name=entryRemarks_button border=0 src=/dms/images/expand_button.gif></a> -->
        <br>
        <textarea rows="5" cols="80" name="soc">$esArray[0]</textarea>

        <br>
        <br>
        <hr>
        <br>

        <font size="4">Recommendation:</font>
        <!-- <a href="javascript:expandTextBox(document.decisions.r, document.entryRecommend_button,'force',5);"><img name=entryRecommend_button border=0 src=/dms/images/expand_button.gif></a> -->
        <br>
        <textarea rows="5" cols="80" name="r">$esArray[1]</textarea>

        <br>
        <hr>
        <br>
        <font size="4">Decision:</font>
        <!-- <a href="javascript:expandTextBox(document.decisions.esdecision, document.entryesDecision_button,'force',5);"><img name=entryRemarks_button border=0 src=/dms/images/expand_button.gif></a> -->
        <br>
        <textarea rows="2" cols="80" name="esdecision">$esArray[2]</textarea>
        </td></tr>
        </table>

        <br><br>

        <!-- Decision Analysis Information -->
        <table width="750" cellpadding="6" cellspacing="0" border="1" bgcolor="#ffffff">
        <tr><td bgcolor="#eeeeee"><font size="4"><b>Decision Analysis Information</b></font></td></tr>
        <tr><td>
        <br>
        <font size="4"><b>Selection Criteria:</b></font>
        <br>
        <br>

        $selectionString
        $curSelectionCriteria
        $orgSelectionCriteria

        <div id=selections></div>
        <br>
        <a href="javascript:addNewSelectionCriteria(document.decisions.hidCurSelectionCriteria.value);">Add Additional Selection Criteria</a>

        <br>
        <br>
        <hr>
        <br>
        <font size="4"><b>Option Description:</b></font>

        <br>
        <br>

        $optionString
        $curOptionRationale
        $orgOptionRationale
        <div id=options></div>
        <br>
        <a href="javascript:addNewOptionRationale(document.decisions.hidCurOptionRationale.value);">Add Additional Option Rationale</a>

        <br>
        <br>
        <hr>
        <br>
        <font size="4"><b>Decision Analysis Recommendation:</b></font>
        <br>
        <textarea rows="3" cols="70" name=darecommendation>$darecommendation</textarea>

        <br>
        <br>
        <hr>
        <br>
        <font size="4"><b>References:</b></font>
        <br>
        <textarea rows="3" cols="70" name="dareferences">$dareferences</textarea>

        <br>
        <br>
        <hr>
        <br>
        <font size="4"><b>Attachments:</b></font>
        <br>
        <i>To View an attachment, click on the document name.</i><br>
        <i>To Remove an attachment, check its checkbox and it will be removed when you save your changes to the document.</i><br><br>

        $attachmentString
        $orgAttachment
        $curAttachment
        <br>
        <br>
        <i>To add an attachment, click the <b>Browse</b> button and select the file.</i><br><br>

        <input type=file name=attachment>
        <div id=attachments></div>
        <br>
        <input type=button value="Add Additional Attachments" onClick="javascript:addNewAttachmentWidget(document.decisions.hidCurAttachmentCount.value);">

        <hr>
        <br>
        <input type="checkbox" name="chkDoneWithDataEntry"><b>Done with Data Entry?</b>
        <br>

        <br>
        <input type="button" value="Save Changes" onClick="javascript:saveChanges();">
        <br>

</td></tr></table></form>

EOB_updatePending

    };
    if ($@) {
        my $message = errorMessage($dbh,$username,$userid,$schema,"process entry/update screen.",$@);
        print doAlertBox(text => $message);
    }

######################################################################################################################
#
} elsif ($command eq 'browse') {
    eval {
    print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $titles{$command});

    my $command2 = $dmscgi->param("command2");

    $command2 = 'interface' if not defined($command2);

    if ($command2 eq 'interface') {

        ## Get the Developed By list
        #
        my $developedbyString = "";
        my @developerArray = ();

        my $sql = "select a.id, a.firstname, a.lastname, c.description from $schema.users a, $schema.organization c where a.organization = c.organizationid(+) and a.id in (select b.userid from $schema.user_roles b where b.role = 2)";
        my $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@developerArray = $sth->fetchrow_array()) {
            $developedbyString = $developedbyString."<option value=$developerArray[0]>$developerArray[1] $developerArray[2], $developerArray[3]</option>";
        }

        ## Get the Decision Maker List
        #
        my $decisionMakerString = "";
        my @decisionMakerArray = ();

        $sql = "select a.id, a.firstname, a.lastname, c.description from $schema.users a, $schema.organization c where a.organization = c.organizationid(+) and a.id in (select b.userid from $schema.user_roles b where b.role = 3)";
        $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@decisionMakerArray = $sth->fetchrow_array()) {
            $decisionMakerString = $decisionMakerString."<option value=$decisionMakerArray[0]>$decisionMakerArray[1] $decisionMakerArray[2], $decisionMakerArray[3]</option>";
        }

        print <<EO_INTERFACE;
        <center>

        <script language="JavaScript">
        <!--
        function setRadio(i) {
            document.decisions.chkOption[i].checked = true;
        }

        function submitBrowse() {
            document.decisions.command2.value = 'recordview';
            //alert(document.decisions.command2.value);
            document.decisions.command.value = 'browse';
            document.decisions.action = '/cgi-bin/dms/decisions.pl';
            document.decisions.target = 'main';
            document.decisions.submit();
        }

        //-->
        </script>

        <input type=hidden name=command2 value="">

        <table width="600" cellpadding="3" cellspacing="0" border="1" bgcolor="#ffffff">
        <tr><td colspan="3" bgcolor="#eeeeee"><font size="4"><b>Browse By:</b></font></td></tr>
        <tr><td width="10"><input type="radio" name=chkOption value=0 checked></td><td width="120" align="right"><b>Decision Type:</b></td><td><select name=decisionType onFocus="javascript:setRadio(0);"><option value=1>Key</option><option value=2>Supporting</option></select></td></tr>
        <tr><td width="10"><input type="radio" name=chkOption value=1></td><td width="120" align="right"><b>Decision ID:</b></td><td><input type="text" size="15" name=decisionID onFocus="javascript:setRadio(1);"></td></tr>
        <tr><td width="10"><input type="radio" name=chkOption value=2></td><td width="120" align="right"><b>QA:</b></td><td><select name=qa onFocus="javascript:setRadio(2);"><option value=F>Non QA</option><option value=T>QA</option></select></td></tr>
        <tr><td width="10"><input type="radio" name=chkOption value=3></td><td width="120" align="right"><b>Decision Maker:</b></td><td><select name=decisionMaker onFocus="javascript:setRadio(3);">$decisionMakerString</select></td></tr>
        <tr><td width="10"><input type="radio" name=chkOption value=4></td><td width="120" align="right"><b>Decision Analysis Developed By:</b></td><td><select name=developedBy onFocus="javascript:setRadio(4);">$developedbyString</select></td></tr>
        <tr><td width="10" valign="top"><input type="radio" name=chkOption value=5></td><td width="120" align="right" valign="top"><b>Decision Status:</b></td><td>

        <table border="0" cellpadding="3" cellspacing="0">
        <tr><td><input type="checkbox" name=chkCompleted onFocus="javascript:setRadio(5);" value=3></td><td>Completed</td></tr>
        <tr><td><input type="checkbox" name=chkApproved onFocus="javascript:setRadio(5);" value=2></td><td>Approved (waiting for Accession #)</td></tr>
        <tr><td><input type="checkbox" name=chkPending onFocus="javascript:setRadio(5);" value=1></td><td>Pending</td></tr>
        </table>

        </td></tr>
        </table>
        <br>
        <input type="button" value="Submit" onClick="javascript:submitBrowse();">

        <br>
        <br>
        </center>

EO_INTERFACE

    } ## end of interface command

    if ($command2 eq 'recordview') {

        ## Save the top half of the browse screen's state
        #

        my ($chkCompleted, $chkApproved, $chkPending, $decisionType, $decisionID, $qa, $decisionMaker, $developedBy, $sqlString, $title, $decisionTypeString,$qaString) = "";

        my $option = $dmscgi->param("chkOption");

        if ($option eq '0') {
            $decisionType = $dmscgi->param("decisionType");
            $sqlString = "select decisionid, decisiontitle, creationdate, accession, decisionstatus, decisiontype, decisiondate, decisiontitle from $schema.decisions where decisiontype = $decisionType order by decisionid";
            $title = "All Key Decisions" if $decisionType eq '1';
            $title = "All Supporting Decisions" if $decisionType eq '2';
        }

        if ($option eq '1') {
            $decisionID = $dmscgi->param("decisionID");
            $decisionID = uc($decisionID);
            $sqlString = "select decisionid, decisiontitle, creationdate, accession, decisionstatus, decisiontype, decisiondate from $schema.decisions where decisionid = \'$decisionID\' order by decisionid";
            $title = "Decision $decisionID";
        }

        if ($option eq '2') {
            $qa = $dmscgi->param("qa");
            $sqlString = "select decisionid, decisiontitle, creationdate, accession, decisionstatus, decisiontype, decisiondate from $schema.decisions where qa = \'$qa\' order by decisionid";
            $title = "All QA Decisions" if $qa eq 'T';
            $title = "All Non QA Decisions" if $qa eq 'F';
        }

        if ($option eq '3') {
            $decisionMaker = $dmscgi->param("decisionMaker");
            $sqlString = "select decisionid, decisiontitle, creationdate, accession, decisionstatus, decisiontype, decisiondate from $schema.decisions where decisionmaker = $decisionMaker order by decisionid";

            my $sth = $dbh->prepare("select firstname, lastname from $schema.users where id = $decisionMaker");
            $sth->execute();
            my @decisionMakerArray = $sth->fetchrow_array();
            $title = "All Decisions Made by $decisionMakerArray[0] $decisionMakerArray[1]";
        }

        if ($option eq '4') {
            $developedBy = $dmscgi->param("developedBy");
            $sqlString = "select decisionid, decisiontitle, creationdate, accession, decisionstatus, decisiontype, decisiondate from $schema.decisions where developedby = $developedBy order by decisionid";
            my $sth = $dbh->prepare("select firstname, lastname from $schema.users where id = $developedBy");
            $sth->execute();
            my @developedByArray = $sth->fetchrow_array();
            $title = "All Decisions Developed by $developedByArray[0] $developedByArray[1]";
        }

        my ($check1, $check2, $check3);

        if ($option eq '5') {
            $chkCompleted = $dmscgi->param("chkCompleted");
            $chkApproved = $dmscgi->param("chkApproved");
            $chkPending = $dmscgi->param("chkPending");

            my $strCompleted = " or decisionstatus = 3 " if $chkCompleted;
            my $strApproved = " or decisionstatus = 2 " if $chkApproved;
            my $strPending = " or decisionstatus = 1" if $chkPending;
            $sqlString = "select decisionid, decisiontitle, creationdate, accession, decisionstatus, decisiontype, decisiondate from $schema.decisions where 1 = 0".$strCompleted.$strApproved.$strPending." order by decisionid";

            my $strCompleted2 = "Completed " if $chkCompleted;
            my $strApproved2 = "Approved " if $chkApproved;
            my $strPending2 = "Pending" if $chkPending;
            $title = "All Decisions with Status of ".$strCompleted2.$strApproved2.$strPending2;

            $check1 = 'CHECKED' if defined($chkCompleted);
            $check2 = 'CHECKED' if defined($chkApproved);
            $check3 = 'CHECKED' if defined($chkPending);
        }

        if ($decisionType == 2) {
            $decisionTypeString = '<select name=decisionType onFocus="javascript:setRadio(0);"><option value=1>Key</option><option value=2 SELECTED>Supporting</option>';
        } else {
            $decisionTypeString = '<select name=decisionType onFocus="javascript:setRadio(0);"><option value=1 SELECTED>Key</option><option value=2>Supporting</option>';
        }

        if ($qa eq 'T') {
            $qaString = '<select name=qa onFocus="javascript:setRadio(2);"><option VALUE=F>Non QA</option><option VALUE=T SELECTED>QA</option></select>';
        } else {
            $qaString = '<select name=qa onFocus="javascript:setRadio(2);"><option VALUE=F SELECTED>Non QA</option><option VALUE=T>QA</option></select>';
        }

        ## Get the Developed By list
        #
        my $developedbyString = "";
        my @developerArray = ();

        my $sql = "select a.id, a.firstname, a.lastname, c.description from $schema.users a, $schema.organization c where a.organization = c.organizationid(+) and a.id in (select b.userid from $schema.user_roles b where b.role = 2)";
        my $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@developerArray = $sth->fetchrow_array()) {
            if ($option eq '4') {
                if ($developedBy eq $developerArray[0]) {
                    $developedbyString = $developedbyString."<option value=$developerArray[0] SELECTED>$developerArray[1] $developerArray[2],$developerArray[3]</option>";
                } else {
                    $developedbyString = $developedbyString."<option value=$developerArray[0]>$developerArray[1] $developerArray[2],$developerArray[3]</option>";
                }
            } else {
                $developedbyString = $developedbyString."<option value=$developerArray[0]>$developerArray[1] $developerArray[2],$developerArray[3]</option>";
            }
        }

        ## Get the Decision Maker List
        #
        my $decisionMakerString = "";
        my @decisionMakerArray = ();

        $sql = "select a.id, a.firstname, a.lastname, c.description from $schema.users a, $schema.organization c where a.organization = c.organizationid(+) and a.id in (select b.userid from $schema.user_roles b where b.role = 3)";
        $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@decisionMakerArray = $sth->fetchrow_array()) {
            if ($option eq '3') {
                if ($decisionMaker eq $decisionMakerArray[0]) {
                    $decisionMakerString = $decisionMakerString."<option value=$decisionMakerArray[0] SELECTED>$decisionMakerArray[1] $decisionMakerArray[2], $decisionMakerArray[3]</option>";
                } else {
                    $decisionMakerString = $decisionMakerString."<option value=$decisionMakerArray[0]>$decisionMakerArray[1] $decisionMakerArray[2], $decisionMakerArray[3]</option>";
                }
            } else {
                $decisionMakerString = $decisionMakerString."<option value=$decisionMakerArray[0]>$decisionMakerArray[1] $decisionMakerArray[2], $decisionMakerArray[3]</option>";
            }

        }

        print <<EO_INTERFACE;

        <center>
        <script language="JavaScript">
        <!--
        function setRadio(i) {
            document.decisions.chkOption[i].checked = true;
        }

        function submitBrowse() {
            document.decisions.command2.value = 'recordview';
            document.decisions.command.value = 'browse';
            document.decisions.action = '/cgi-bin/dms/decisions.pl';
            document.decisions.target = 'main';
            document.decisions.submit();
        }

        function browseDetail(decisionid) {
            document.decisions.command2.value = 'detailview';
            //alert(document.decisions.command2.value);
            document.decisions.command.value = 'browse';
            document.decisions.decisionid.value = decisionid;
            document.decisions.action = '/cgi-bin/dms/decisions.pl';
            document.decisions.target = 'main';
            document.decisions.submit();
        }

        function viewprint(command,decisionid) {
            document.decisions.action = '/cgi-bin/dms/' + 'decisions.pl';
            document.decisions.command.value = command;
            window.open(document.decisions.action,"print_window");
            document.decisions.target = 'print_window';
            document.decisions.decisionid.value = decisionid;
            document.decisions.submit();
        }

        function openWindow(image) {
             window.open(image,"image_window","height=500,width=700,scrollbars=yes,resizable=yes");
        }

        //-->
        </script>

        <input type=hidden name=command2 value="">

        <table width="600" cellpadding="3" cellspacing="0" border="1" bgcolor="#ffffff">
        <tr><td colspan="3" bgcolor="#eeeeee"><font size="4"><b>Browse By:</b></font></td></tr>
        <tr><td width="10"><input type="radio" name=chkOption value=0></td><td width="120" align="right"><b>Decision Type:</b></td><td>$decisionTypeString</select></td></tr>
        <tr><td width="10"><input type="radio" name=chkOption value=1></td><td width="120" align="right"><b>Decision ID:</b></td><td><input type="text" size="15" name=decisionID onFocus="javascript:setRadio(1);" value="$decisionID"></td></tr>
        <tr><td width="10"><input type="radio" name=chkOption value=2></td><td width="120" align="right"><b>QA:</b></td><td>$qaString</td></tr>
        <tr><td width="10"><input type="radio" name=chkOption value=3></td><td width="120" align="right"><b>Decision Maker:</b></td><td><select name=decisionMaker onFocus="javascript:setRadio(3);">$decisionMakerString</select></td></tr>
        <tr><td width="10"><input type="radio" name=chkOption value=4></td><td width="120" align="right"><b>Decision Analysis Developed By:</b></td><td><select name=developedBy onFocus="javascript:setRadio(4);">$developedbyString</select></td></tr>
        <tr><td width="10" valign="top"><input type="radio" name=chkOption value=5></td><td width="120" align="right" valign="top"><b>Decision Status:</b></td><td>

        <table border="0" cellpadding="3" cellspacing="0">
        <tr><td><input type="checkbox" name=chkCompleted onFocus="javascript:setRadio(5);" value=3 $check1></td><td>Completed</td></tr>
        <tr><td><input type="checkbox" name=chkApproved  onFocus="javascript:setRadio(5);" value=2 $check2></td><td>Approved (waiting for Accession #)</td></tr>
        <tr><td><input type="checkbox" name=chkPending   onFocus="javascript:setRadio(5);" value=1 $check3></td><td>Pending</td></tr>
        </table>

        </td></tr>
        </table>
        <br>
        <input type="button" value="Submit" onClick="javascript:submitBrowse();">

        <br>
        <br>

        <script language="JavaScript">
        <!--
            document.decisions.chkOption[$option].checked = true;
        //-->
        </script>

EO_INTERFACE

        ## Now we need to actually run the SQL query and grab the information
        #

        $sth = $dbh->prepare($sqlString);
        $sth->execute();

        my @tableArray = ();
        my @tableDataArray = ();
        my $i = 0;

        my ($statusColor, $statusString, $dataString, $stringDecisionType, $accessionid, $creationdate, $decisiondate, $decisiontitle) = "";

        while (@tableDataArray = $sth->fetchrow_array()) {

            $statusColor = "#FF9900" if ($tableDataArray[4] == 1); # Pending
            $statusColor = "#FFFF00" if ($tableDataArray[4] == 2); # Approved
            $statusColor = "#00FF00" if ($tableDataArray[4] == 3); # Completed

            $statusString = "P" if ($tableDataArray[4] == 1); # Pending
            $statusString = "A" if ($tableDataArray[4] == 2); # Approved
            $statusString = "C" if ($tableDataArray[4] == 3); # Completed

            $stringDecisionType = "Key" if ($tableDataArray[5] == 1);
            $stringDecisionType = "Supporting" if ($tableDataArray[5] == 2);

            $creationdate = "&nbsp;" if not defined($tableDataArray[2]);
            $creationdate = "$tableDataArray[2]" if defined($tableDataArray[2]);

            $decisionid = "&nbsp;" if not defined($tableDataArray[0]);
            $decisionid = "$tableDataArray[0]" if defined($tableDataArray[0]);

            $decisiondate = "&nbsp;" if not defined($tableDataArray[6]);
            $decisiondate = "$tableDataArray[6]" if defined($tableDataArray[6]);

            $decisiontitle = "&nbsp;" if not defined($tableDataArray[1]);
            $decisiontitle = "$tableDataArray[1]" if defined($tableDataArray[1]);

            $accessionid = "&nbsp;" if not defined($tableDataArray[3]);
            $accessionid = "<a href=\"javascript:openWindow('http://rms.ymp.gov/cgi-bin/get_record.com?$tableDataArray[3]');\">$tableDataArray[3]</a>" if defined($tableDataArray[3]);

            $dataString = "<tr><td width=15 align=center bgcolor=$statusColor><font size=2><b>$statusString</b></font></td><td align=center><a href=\"javascript:viewprint('printable_es','$decisionid');\"><img src=/dms/icons/16/printer.gif border=0 alt=\"click here to generate a printable Executive Summary\"></a></td><td align=center><a href=\"javascript:viewprint('printable_da','$decisionid');\"><img src=/dms/icons/16/printer.gif border=0 alt=\"click here to generate a printable Decision Analysis\"></a></td><td align=center nowrap><font size=2><a href=\"javascript:browseDetail('$decisionid');\">$decisionid</a></font></td><td><font size=2>$stringDecisionType</font></td><td><font size=2>$decisiontitle</font></td><td nowrap><font size=2>$decisiondate</font></td><td nowrap><font size=2>$accessionid</font></td></tr>";
            push(@tableArray, $dataString);
            $i++;
        }

print <<EO_INTERFACE;

        <table border="1" cellpadding="3" cellspacing="0" width="740" bgcolor="#ffffff">

        <tr><td colspan="8" bgcolor="#eeeeee"><font size="4"><b>$title ($i total)</b></font>
        <br>
        <br>
        <table width="600" cellpadding="2" cellspacing="3" border="0">
        <tr><td colspan="2"><b>Legend:</b></td></tr>
        <tr><td width="10" align="center" bgcolor="#00FF00">C</td><td>Completed</td></tr>
        <tr><td width="10" align="center" bgcolor="#FFFF00">A</td><td>Approved - Waiting for Accession Number</td></tr>
        <tr><td width="10" align="center" bgcolor="#FF9900">P</td><td>Pending - Incomplete Decision Package</td></tr>
        </table>
        <br>

        </td></tr>
        <tr><td width="15" bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>S</b></font></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>Executive<br>Summary</b></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>Decision<br>Analysis</b></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>ID</b></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>Type</b></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>Title</b></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>Decision<br>Date</b></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>Accession</b></td></tr>

EO_INTERFACE

        my $index = "";

        foreach $index (@tableArray) {
            print $index."\n";
        }

        &log_activity($dbh, $schema, $userid, "Browse - Record View");


    } ## End of Record View


    if ($command2 eq 'detailview') {

        # decision table

        my ($sql, $decisionid, $sth, @array);

        $decisionid = $dmscgi->param("decisionid");

        $sql = "select decisionid, decisiontitle, decisionstatus, decisiontype, qa, accession, creationdate, lastmodified, decisiondate, preparer, developedby, decisionmaker, preparerfinal, developedbyfinal, decisionmakerfinal, statementofconsideration, esrecommendation, esdecision, darecommendation, dareferences, decisionapproved from $schema.decisions where decisionid = \'$decisionid\'";

        $sth = $dbh->prepare($sql);
        $sth->execute();

        @array = $sth->fetchrow_array();

        ## transform the decision status
        #
        $array[2] = "Pending" if $array[2] eq "1";
        $array[2] = "Approved" if $array[2] eq "2";
        $array[2] = "Completed" if $array[2] eq "3";

        ## transform the decision type
        #
        $array[3] = "Key" if $array[3] eq "1";
        $array[3] = "Supporting" if $array[3] eq "2";

        ## transform the QA Status
        #
        $array[4] = "QA" if $array[4] eq "T";
        $array[4] = "Non QA" if $array[4] eq "F";

        ## Get the document preparer
        #
        my @array2;

        if ($array[9]) {
            $sql = "select a.firstname, a.lastname, b.description from $schema.users a, $schema.organization b where a.id = $array[9] and a.organization = b.organizationid(+)";

            $sth = $dbh->prepare($sql);
            $sth->execute();

            @array2 = $sth->fetchrow_array();
            $array[9] = "$array2[0] $array2[1], $array2[2]";
        } else {
            $array[9] = "N/A";
        }

        ## Developed By
        if ($array[10]) {
            $sql = "select a.firstname, a.lastname, b.description from $schema.users a, $schema.organization b where a.id = $array[10] and a.organization = b.organizationid(+)";

            $sth = $dbh->prepare($sql);
            $sth->execute();

            @array2 = $sth->fetchrow_array();
            $array[10] = "$array2[0] $array2[1], $array2[2]";
        } else {
            $array[10] = "N/A";
        }

        ## Decision Maker
        if ($array[11]) {
            $sql = "select a.firstname, a.lastname, b.description from $schema.users a, $schema.organization b where a.id = $array[11] and a.organization = b.organizationid(+)";

            $sth = $dbh->prepare($sql);
            $sth->execute();

            @array2 = $sth->fetchrow_array();
            $array[11] = "$array2[0] $array2[1], $array2[2]";
        } else {
            $array[11] = "N/A";
        }

        ## Now get existing attachments
        #
        $sql = "select attachmentid, filename from $schema.attachments where decisionid = \'$decisionid\'";
        $sth = $dbh->prepare($sql);
        $sth->execute();

        my @attachmentArray = ();
        my $attachmentString = "";
        my $k = 1;

        while (@attachmentArray = $sth->fetchrow_array()) {
            $attachmentString = $attachmentString."<li><a href=javascript:viewAttachments($attachmentArray[0])>$attachmentArray[1]</a></li>";
            $k++;
        }

        ## Clean up all the HTML whitespace
        #
        my $index = "";
        my $BR = '<br>';

        foreach $index (@array) {
            $index = "&nbsp;" if not defined($index);
            $index =~ s/\n/$BR/g;
        }

        ## These are CLOBs, and for some reason, when you check for 'not defined()', they return
        ## a defined() status, eventhough they may not be.  Thus the hex() equality hackerware
        #
        #{
        #   local $^W = 0;
        #   $array[15] = '&nbsp;' if (sprintf("%lx",$array[15]) eq '0');
        #   $array[16] = '&nbsp;' if (hex($array[16]) == 0);
        #   $array[17] = '&nbsp;' if (hex($array[17]) == 0);
        #   $array[18] = '&nbsp;' if (hex($array[18]) == 0);
        #}

        print <<EO_DETAIL_VIEW;

    <script language="JavaScript">
    <!--

        function viewAttachments(attachmentid) {
            document.viewattachment.action = '/cgi-bin/dms/display_image.pl';
            document.viewattachment.target = 'cgiresults';
            document.viewattachment.attachmentid.value = attachmentid;
            document.viewattachment.submit();
        }

    //-->
    </script>

    <center>
    <table border=1 cellpadding=3 cellspacing=0 width=750 bgcolor="#ffffff">
    <!-- <tr><td colspan=2><br><li><a href=#selection>Selection Criteria</a></li><li><a href=#options>Option Rationale</a></li><li><a href=#attachments>Attachments</a></li><br><br></td></tr> -->
    <tr><td colspan=2 bgcolor=#c0ffff><font size=5><b>Decision $array[0]</b></font></td></tr>
    <tr><td align=right bgcolor="#ffffff" width=150><font size=2><b>Decision Title</b></font></td><td bgcolor="#ffffff"><font size=2>$array[1]</font></td></tr>
    <tr><td align=right bgcolor="#eeeeee" width=150><font size=2><b>Decision Status</b></font></td><td bgcolor="#eeeeee"><font size=2>$array[2]</font></td></tr>
    <tr><td align=right bgcolor="#ffffff" width=150><font size=2><b>Decision Type</b></font></td><td bgcolor="#ffffff"><font size=2>$array[3]</font></td></tr>
    <tr><td align=right bgcolor="#eeeeee" width=150><font size=2><b>QA</b></font></td><td bgcolor="#eeeeee"><font size=2>$array[4]</font></td></tr>
    <tr><td align=right bgcolor="#ffffff" width=150><font size=2><b>Accession</b></font></td><td bgcolor="#ffffff"><font size=2>$array[5]</font></td></tr>
    <tr><td align=right bgcolor="#eeeeee" width=150><font size=2><b>Creation Date</b></font></td><td bgcolor="#eeeeee"><font size=2>$array[6]</font></td></tr>
    <tr><td align=right bgcolor="#ffffff" width=150><font size=2><b>Last Modified</b></font></td><td bgcolor="#ffffff"><font size=2>$array[7]</font></td></tr>
    <tr><td align=right bgcolor="#eeeeee" width=150><font size=2><b>Decision Date</b></font></td><td bgcolor="#eeeeee"><font size=2>$array[8]</font></td></tr>
    <tr><td align=right bgcolor="#ffffff" width=150><font size=2><b>Data Entry By</b></font></td><td bgcolor="#ffffff"><font size=2>$array[9]</font></td></tr>
    <tr><td align=right bgcolor="#eeeeee" width=150><font size=2><b>Decision Analysis Developed By</b></font></td><td bgcolor="#eeeeee"><font size=2>$array[10]</font></td></tr>
    <tr><td align=right bgcolor="#ffffff" width=150><font size=2><b>Decision Maker</b></font></td><td bgcolor="#ffffff"><font size=2>$array[11]</font></td></tr>
    <tr><td align=right bgcolor="#eeeeee" width=150><font size=2><b>Statement of Consideration</b></font></td><td bgcolor="#eeeeee"><font size=2>$array[15]</font></td></tr>
    <tr><td align=right bgcolor="#ffffff" width=150><font size=2><b>Recommendation (ES)</b></font></td><td bgcolor="#ffffff"><font size=2>$array[16]</font></td></tr>
    <tr><td align=right bgcolor="#eeeeee" width=150><font size=2><b>Decision (ES)</b></font></td><td bgcolor="#eeeeee"><font size=2>$array[17]</font></td></tr>
    <tr><td align=right bgcolor="#ffffff" width=150><font size=2><b>Recommendation (DA)</b></font></td><td bgcolor="#ffffff"><font size=2>$array[18]</font></td></tr>
    <tr><td align=right bgcolor="#eeeeee" width=150><font size=2><b>References</b></font></td><td bgcolor="#eeeeee"><font size=2>$array[19]</font></td></tr>
    </table>
    <br>
    <br>
    <br>

EO_DETAIL_VIEW

        ## selection criteria table
        #
        $sql = "select * from $schema.selection_criteria where decisionid = \'$decisionid\' order by selectionid";

        $sth = $dbh->prepare($sql);
        $sth->execute();

        print "<a name=selection><table border=1 cellpadding=3 cellspacing=0 width=750>\n";
        print "<tr><td bgcolor=#c0ffff><font size=5><b>Selection Criteria</b></font></td></tr></table><br>\n";
        @array = undef;

        while (@array = $sth->fetchrow_array()) {

            $array[0] = '&nbsp;' if not defined($array[0]);
            $array[1] = '&nbsp;' if not defined($array[1]);
            $array[2] = '&nbsp;' if not defined($array[2]);

            #{
            #   local $^W = 0;
            #   $array[3] = '&nbsp;' if (hex($array[3]) == 0);
            #}

            my $BR = '<br>';
            $array[0] =~ s/\n/$BR/g;
            $array[1] =~ s/\n/$BR/g;
            $array[2] =~ s/\n/$BR/g;
            $array[3] =~ s/\n/$BR/g;

            print "<table border=1 cellpadding=3 cellspacing=0 width=750 bgcolor=#ffffff>\n";
            print "<tr><td width=20><font size=2><b>$array[0]</b></font></td><td width=730 valign=top><font size=2><b>$array[2]</b></td></tr>\n";
            print "<tr><td colspan=2 valign=top><font size=2>$array[3]</font></td></tr>\n";
            print "</table><br>\n";
        }

        ## option rationale table
        #
        $sql = "select * from $schema.options where decisionid = \'$decisionid\' order by optionid";

        $sth = $dbh->prepare($sql);
        $sth->execute();

        print "<br><br><a name=options><table border=1 cellpadding=3 cellspacing=0 width=750>\n";
        print "<tr><td colspan=3 bgcolor=#c0ffff><font size=5><b>Option Rationale</b></font></td></tr></table><br>\n";
        print "<table border=1 cellpadding=3 cellspacing=0 width=750 bgcolor=#ffffff>\n";
        @array = undef;

        while (@array = $sth->fetchrow_array()) {

            $array[0] = '&nbsp;' if not defined($array[0]);
            $array[1] = '&nbsp;' if not defined($array[1]);

            #{
            #   $^W = 0;
            #   $array[2] = '&nbsp;' if (hex($array[2]) == 0);
            #   $array[3] = '&nbsp;' if (hex($array[3]) == 0);
            #}

            my $BR = '<br>';
            $array[0] =~ s/\n/$BR/g;
            $array[1] =~ s/\n/$BR/g;
            $array[2] =~ s/\n/$BR/g;
            $array[3] =~ s/\n/$BR/g;

            print "<tr><td width=20 valign=top><font size=2><b>$array[0]</b></td><td valign=top><font size=2>$array[2]</td><td valign=top><font size=2>$array[3]</td>\n";
        }

        print "</table>";

        if (defined($attachmentString)) {
            print "<br><br><a name=attachments><table border=1 cellpadding=3 cellspacing=0 width=750>\n";
            print "<tr><td colspan=3 bgcolor=#c0ffff><font size=5><b>Attachments</b></font></td></tr></table><br>\n";
            print "<table border=1 cellpadding=3 cellspacing=0 width=750 bgcolor=#ffffff><tr><td><br><ul>$attachmentString</ul></td></tr></table>\n";
        }

        &log_activity($dbh, $schema, $userid, "$decisionid - Browse Detail View");


    } ## End of Detail View

    };
    if ($@) {
        my $message = errorMessage($dbh,$username,$userid,$schema,"browse decisions.",$@);
        print doAlertBox(text => $message);
    }

######################################################################################################################
#
} elsif ($command eq 'createNewEntry') {
    eval {

        print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $titles{$command});

        ## Get Decision Types from the database
        #

        my $sql = "select id, description from $schema.decision_types";
        my @array = ();
        my $decisionTypeString ="";

        my $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@array = $sth->fetchrow_array()) {
            $decisionTypeString = $decisionTypeString."<option value=$array[0]>$array[1]</option>";
        }

        ## Get the Keywords list
        #

        $sql = "select keywordid, keyword from $schema.keywords";
        @array = ();
        my %keywordHash = ();
        my %emptyHash = ();

        $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@array = $sth->fetchrow_array()) {
            $keywordHash{$array[0]} = $array[1];
        }

        my $keywordString = &build_dual_select("availkeywords","decisions", \%keywordHash, \%emptyHash, "<b>Available Keywords</b>", "<b>Selected Keywords</b>");


        ## Get the Developed By list
        #

        my $developedbyString = "";
        my @developerArray = ();

        $sql = "select a.id, a.firstname, a.lastname from $schema.users a where a.id in (select b.userid from $schema.user_roles b where b.role = 2)";
        $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@developerArray = $sth->fetchrow_array()) {
            $developedbyString = $developedbyString."<option value=$developerArray[0]>$developerArray[1] $developerArray[2]</option>";
        }

        ## Get the Decision Maker List
        #

        my $decisionMakerString = "";
        my @decisionMakerArray = ();

        $sql = "select a.id, a.firstname, a.lastname, b.description from $schema.users a, $schema.organization b where a.organization = b.organizationid(+) and a.id in (select b.userid from $schema.user_roles b where b.role = 3)";
        $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@decisionMakerArray = $sth->fetchrow_array()) {
            $decisionMakerString = $decisionMakerString."<option value=$decisionMakerArray[0]>$decisionMakerArray[1] $decisionMakerArray[2], $decisionMakerArray[3]</option>";
        }

        my $dateString = &build_date_selection("decisiondate","decisions","today");

        my $curAttachment = "<input type=hidden name=hidCurAttachmentCount value=0>";
        my $orgAttachment = "<input type=hidden name=hidOrgAttachmentCount value=0>";

        print <<EOB_createNewEntry;

        <script language="JavaScript">
        <!--

        function validate_accession(num) {
            var msgString = "";
            if (num == "") {
                return true;
            } else if (num.length != 17) {
                alert("Accession Number has an invalid length");
                return false;
            } else if (num.length == 17) {
                var prefix = num.substr(0,3);
                var dot1 = num.substr(3,1);
                var dot2 = num.substr(12,1);
                var datepart = num.substr(4,8);
                var sequence = num.substr(13,4);

                if (dot1 != "." && dot2 != ".") {
                    alert("The Accession Number must be in the format: 'ORG.YYYYMMDD.####'.");
                    return false;
                }

                if (datepart.length != 8) {
                    alert("The Accession Number must be in the format: 'ORG.YYYYMMDD.####'.");
                    return false;
                }

                if (! isnumeric(sequence) || (sequence < 1)) {
                    alert("Sequence portion of the accession number must be a positive 4 digit number '####'.");
                    return false;
                }
            }
            return true;
        }

        function saveChangesNewEntry() {
            var script = 'decisions';
            document.decisions.command.value = 'saveChanges';
            document.decisions.action = '/cgi-bin/dms/' + script + '.pl';

            for (index=0;index < document.decisions.availkeywords.length - 1;index++) {
                document.decisions.availkeywords.options[index].selected = true;
            }

            if (document.decisions.decisiondate_month.value == "" || document.decisions.decisiondate_day.value == "" || document.decisions.decisiondate_year.value == "") {
                document.decisions.decisionDate.value = "NULL";
            } else {
                document.decisions.decisionDate.value = document.decisions.decisiondate_month.value + "-" + document.decisions.decisiondate_day.value + "-" + document.decisions.decisiondate_year.value;
            }

            var returnvalue = validate_accession(document.decisions.decisionaccession.value);
            if (returnvalue == false) {
                document.decisions.decisionaccession.select();
                return false;
            }

            document.decisions.target = 'main';

            if (document.decisions.chkDecisionApproved.checked == true && document.decisions.chkDoneWithDataEntry.checked == true) {
                if (confirm("You have checked that the Decision has been approved by the Decision Maker, and you are done with Data Entry.  Is this correct?")) {
                    document.decisions.submit();
                } else {
                    return;
                }
            } else {
                document.decisions.submit();
            }
        }

        function addNewSelectionCriteria(curSelectionCriteria) {
            curSelectionCriteria = (curSelectionCriteria - 0) + 1;
            document.decisions.hidCurSelectionCriteria.value = curSelectionCriteria;
            document.all.selections.style.height = document.all.selections.clientHeight / 2;
            document.all.selections.innerHTML = document.all.selections.innerHTML + "<table width=100% cellspacing=0 cellpadding=3 border=0><tr><td><b>#</b></td><td><b>Criteria</b></td></tr><tr><td><input type=text size=2 name=sc1_" + curSelectionCriteria + " value=" + curSelectionCriteria + "></td><td><input type=text size=70 name=sc2_" + curSelectionCriteria + " value=></td></tr><tr><td colspan=2><br><b>Selection Criteria Details:</b><br><textarea name=sc3_" + curSelectionCriteria + " rows=3 cols=70></textarea></td></tr></table><br>";
        }

        function addNewOptionRationale(curOptionRationale) {
            curOptionRationale = (curOptionRationale - 0) + 1;
            document.decisions.hidCurOptionRationale.value = curOptionRationale;
            document.all.options.style.height = document.all.options.clientHeight / 2;
            document.all.options.innerHTML = document.all.options.innerHTML + "<table width=100% cellspacing=0 cellpadding=3 border=0><tr><td><b>#</b></td><td><b>Option Description</b></td></tr><tr><td><input type=text name=or1_" + curOptionRationale + " size=2 value=" + curOptionRationale + "></td><td><input type=text name=or2_" + curOptionRationale + " size=70 value=></td></tr><tr><td colspan=2><br><b>Option Selection Rationale:</b><br><textarea name=or3_" + curOptionRationale + " rows=3 cols=70></textarea></td></tr></table>";
        }

        function addNewAttachmentWidget(curAttachmentCount) {
            curAttachmentCount = (curAttachmentCount - 0) + 1;
            document.decisions.hidCurAttachmentCount.value = curAttachmentCount;
            document.all.attachments.style.height = document.all.attachments.clientHeight / 2;
            document.all.attachments.innerHTML = document.all.attachments.innerHTML + "<input type=file name=attachment><br>";
        }

        //-->
        </script>

        <center>

        <input type=hidden name=hidCreateNewEntryFlag value=1>
        <input type=hidden name=decisionDate value="">

<!--
        <table width="750" cellpadding="3" cellspacing="0" border="1">
        <tr><td bgcolor="#eeeeee"><font size="4"><b>Decision Package Status</b></font></td></tr>
        <tr><td bgcolor="#ffffcc">
        &nbsp;
        </td></tr>
        </table>

        <br><br>
-->
        <table width="750" cellpadding="3" cellspacing="0" border="1" bgcolor="#ffffff">
          <tr><td colspan="2" bgcolor="#eeeeee"><font size="4"><b>Primary Decision Information</b></font></td></tr>
          <tr><td width="150" align="right"><b>Decision ID:</b></td><td>Pending...</td></tr>
          <tr><td width="150" align="right"><b>Title:</b></td><td><input type="text" name="decisiontitle" size="50" value=""></td></tr>
          <tr><td width="150" align="right"><b>Accession #:</b></td><td><input type="text" name="decisionaccession" size="50" value=""></td></tr>

          <tr><td width="150" align="right"><b>Decision Type:</b></td><td><select name=optDecisionType>$decisionTypeString</select></td></tr>
          <tr><td width="150" align="right"><b>QA:</b></td><td><select name=optQA><option value=T>QA</option><option value=F>Non-QA</option></td></tr>
          <tr><td width="150" align="right" valign="top"><b>Keywords:</b></td><td>

        <!-- Begin of Keywords Layout region -->

        $keywordString

        <!-- End of Keywords Layout region -->

        </td></tr>

        <tr><td width="150" align="right"><b>Decision Analysis Developed By:</b></td><td><select name=optDevelopedBy>$developedbyString</select>&nbsp;</td></tr>
        <tr><td width="150" align="right"><b>Decision Maker:</b></td><td><select name=optDecisionMaker>$decisionMakerString</select></td></tr>
        <tr><td width="150" align="right"><b>Decision Date:</b></td><td>$dateString &nbsp;<input type="checkbox" name=chkDecisionApproved><b>Decision Approved?</b></td></tr>

        </table>

        <br><br>
        <!-- Executive Summary Information -->
        <table width="750" cellpadding="6" cellspacing="0" border="1" bgcolor="#ffffff">
        <tr><td bgcolor="#eeeeee"><font size="4"><b>Executive Summary Information</b></font></td></tr>
        <tr><td>

        <br>
        <a name="soc">
        <font size="4">Statement for Consideration:</font>
        <br>
        <textarea rows="5" cols="80" name="soc"></textarea>

        <br>
        <br>
        <hr>
        <br>

        <font size="4">Recommendation:</font>
        <br>
        <textarea rows="5" cols="80" name="r"></textarea>

        <br>
        <hr>
        <br>
        <font size="4">Decision:</font>
        <br>
        <textarea rows="2" cols="80" name="esdecision"></textarea>
        </td></tr>
        </table>

        <br><br>

        <!-- Decision Analysis Information -->
        <table width="750" cellpadding="6" cellspacing="0" border="1" bgcolor="#ffffff">
        <tr><td bgcolor="#eeeeee"><font size="4"><b>Decision Analysis Information</b></font></td></tr>
        <tr><td>
        <br>
        <font size="4"><b>Selection Criteria:</b></font>
        <br>
        <br>

        <input type=hidden name=hidCurSelectionCriteria value="3">
        <input type=hidden name=hidOrgSelectionCriteria value="3">

        <table width="100%" cellspacing="0" cellpadding="3" border="0"><tr><td><b>#</b></td><td><b>Criteria</b></td></tr><tr><td><input type="text" size="2" name=sc1_1 value="1"></td><td><input type="text" size="70" name=sc2_1 value=""></td></tr><tr><td colspan="2"><br><b>Selection Criteria Details:</b><br><textarea name=sc3_1 rows="3" cols="70"></textarea></td></tr></table><br>
        <table width="100%" cellspacing="0" cellpadding="3" border="0"><tr><td><b>#</b></td><td><b>Criteria</b></td></tr><tr><td><input type="text" size="2" name=sc1_2 value="2"></td><td><input type="text" size="70" name=sc2_2 value=""></td></tr><tr><td colspan="2"><br><b>Selection Criteria Details:</b><br><textarea name=sc3_2 rows="3" cols="70"></textarea></td></tr></table><br>
        <table width="100%" cellspacing="0" cellpadding="3" border="0"><tr><td><b>#</b></td><td><b>Criteria</b></td></tr><tr><td><input type="text" size="2" name=sc1_3 value="3"></td><td><input type="text" size="70" name=sc2_3 value=""></td></tr><tr><td colspan="2"><br><b>Selection Criteria Details:</b><br><textarea name=sc3_3 rows="3" cols="70"></textarea></td></tr></table><br>

        <div id=selections></div>
        <br>
        <a href="javascript:addNewSelectionCriteria(document.decisions.hidCurSelectionCriteria.value);">Add Additional Selection Criteria</a>
        <br>
        <br>
        <hr>
        <br>
        <font size="4"><b>Option Description:</b></font>

        <br>
        <br>

        <input type=hidden name=hidCurOptionRationale value="3">
        <input type=hidden name=hidOrgOptionRationale value="3">

        <table width="100%" cellspacing="0" cellpadding="3" border="0"><tr><td><b>#</b></td><td><b>Option Description</b></td></tr><tr><td><input type="text" name=or1_1 size="2" value="1"></td><td><input type="text" name=or2_1 size="70" value=""></td></tr><tr><td colspan="2"><br><b>Option Selection Rationale:</b><br><textarea name=or3_1 rows="3" cols="70"></textarea></td></tr></table><br>
        <table width="100%" cellspacing="0" cellpadding="3" border="0"><tr><td><b>#</b></td><td><b>Option Description</b></td></tr><tr><td><input type="text" name=or1_2 size="2" value="2"></td><td><input type="text" name=or2_2 size="70" value=""></td></tr><tr><td colspan="2"><br><b>Option Selection Rationale:</b><br><textarea name=or3_2 rows="3" cols="70"></textarea></td></tr></table><br>
        <table width="100%" cellspacing="0" cellpadding="3" border="0"><tr><td><b>#</b></td><td><b>Option Description</b></td></tr><tr><td><input type="text" name=or1_3 size="2" value="3"></td><td><input type="text" name=or2_3 size="70" value=""></td></tr><tr><td colspan="2"><br><b>Option Selection Rationale:</b><br><textarea name=or3_3 rows="3" cols="70"></textarea></td></tr></table><br>

        <div id=options></div>
        <br>
        <a href="javascript:addNewOptionRationale(document.decisions.hidCurOptionRationale.value);">Add Additional Option Rationale</a>

        <br>
        <br>
        <hr>
        <br>

        <font size="4"><b>Decision Analysis Recommendation:</b></font>
        <br>
        <textarea rows="3" cols="70" name=darecommendation></textarea>

        <br>
        <br>
        <hr>
        <br>
        <font size="4"><b>References:</b></font>
        <br>
        <textarea rows="3" cols="70" name="dareferences"></textarea>

        <br>
        <br>
        <hr>
        <br>
        <font size="4"><b>Attachments:</b></font>
        <br>
        <i>To View an attachment, click on the document name.</i><br>
        <i>To Remove an attachment, check its checkbox and it will be removed when you save your changes to the document.</i><br><br>
        $orgAttachment
        $curAttachment

        <i>To add an attachment, click the <b>Browse</b> button and select the file.</i><br><br>

        <input type=file name=attachment>
        <div id=attachments></div>
        <br>
        <input type=button value="Add Additional Attachments" onClick="javascript:addNewAttachmentWidget(document.decisions.hidCurAttachmentCount.value);">

        <hr>
        <br>
        <input type="checkbox" name="chkDoneWithDataEntry"><b>Done with Data Entry?</b>
        <br>

        <br>
        <input type="button" value="Save Changes" onClick="javascript:saveChangesNewEntry();">
        <br>

</td></tr></table></form>


EOB_createNewEntry

    };
    if ($@) {
        my $message = errorMessage($dbh,$username,$userid,$schema,"process $command.",$@);
        print doAlertBox( text => $message);
    }
######################################################################################################################
#
} elsif ($command eq 'saveChanges') {
    eval {
        my $q = new CGI;

        my $decisionid = $q->param("decisionid");

        my $decisiontype = $q->param("optDecisionType");
        my $qa = $q->param("optQA");
        my $developedby = $q->param("optDevelopedBy");
        my $decisionmaker = $q->param("optDecisionMaker");
        my $preparer = $q->param("userid");

        my $title = $q->param("decisiontitle");
        $title = $dbh->quote($title);

        my $accession = $q->param("decisionaccession");
        $accession = $dbh->quote($accession);

        my $statementofconsideration = $q->param("soc");
        #$statementofconsideration = $dbh->quote($statementofconsideration);

        my $esrecommendation = $q->param("r");
        #$esrecommendation = $dbh->quote($esrecommendation);

        my $esdecision = $q->param("esdecision");
        #$esdecision = $dbh->quote($esdecision);

        my $darecommendation = $q->param("darecommendation");
        #$darecommendation = $dbh->quote($darecommendation);

        my $dareferences = $q->param("dareferences");
        $dareferences = $dbh->quote($dareferences);

        my $decisiondate = $q->param("decisionDate");
        $decisiondate = "TO_DATE('$decisiondate', 'MM/DD/YYYY')" if $decisiondate ne "NULL";

        my $isDecisionApproved = $q->param("chkDecisionApproved");

        if ($isDecisionApproved eq "on") {
            $isDecisionApproved = 'T';
        } else {
            $isDecisionApproved = 'F';
        }

        my $isDoneWithDataEntry = $q->param("chkDoneWithDataEntry");

        ## Create a new Decision in the system
        #
        my $createNewEntryFlag = $q->param("hidCreateNewEntryFlag");
        if ($createNewEntryFlag) {
            my $sql = "select DECISION_ID.NEXTVAL from DUAL";
            my $sth = $dbh->prepare($sql);
            $sth->execute();
            my $sequence = $sth->fetchrow_array();
            my $year = &getFiscalYear();
            $sequence = "YD-$year".('0' x (5 - length($sequence))).$sequence;
            $sql = "insert into $schema.decisions (decisionid, preparer, decisionstatus, creationdate) values (\'$sequence\', $preparer, 1, sysdate)";
            $decisionid = $sequence;
            $sth = $dbh->prepare($sql);
            $sth->execute();
            $sth->finish();

            &log_activity($dbh, $schema, $userid, "$decisionid - Create New Decision Package");
        }

        ## insert large text objects into the database.
        #
        my $sql = "update $schema.decisions set statementofconsideration = ?, esrecommendation = ?, esdecision = ?, darecommendation = ? where decisionid = \'$decisionid\'";
        my $csr = $dbh->prepare($sql);
        $csr->bind_param(1, $statementofconsideration, { ora_type=>ORA_CLOB, ora_field=>'statementofconsideration'});
        $csr->bind_param(2, $esrecommendation, { ora_type=>ORA_CLOB, ora_field=>'esrecommendation'});
        $csr->bind_param(3, $esdecision, { ora_type=>ORA_CLOB, ora_field=>'esdecision'});
        $csr->bind_param(4, $darecommendation, { ora_type=>ORA_CLOB, ora_field=>'darecommendation'});
        $csr->execute;
        $dbh->commit;
        $csr->finish;

        $sql = "update $schema.decisions set decisiontitle=$title, accession=$accession, decisiontype=$decisiontype, qa=\'$qa\', ".
               "developedby=$developedby, decisionmaker=$decisionmaker, decisiondate=$decisiondate, ".
               "dareferences=$dareferences, decisionapproved=\'$isDecisionApproved\', lastmodified = SYSDATE where ".
               "decisionid = \'$decisionid\'";

        my $sth = $dbh->prepare($sql);
        $sth->execute();

        ## Delete, Insert the keywords
        #

        $sql = "delete from $schema.decision_keywords where decisionid = \'$decisionid\'";
        $sth = $dbh->prepare($sql);
        $sth->execute();

        my $index = "";

        my @keywords = $q->param("availkeywords");

        foreach $index (@keywords) {
            $sql = "insert into $schema.decision_keywords (decisionid, keywordid) values (\'$decisionid\', \'$index\')";
            $sth = $dbh->prepare($sql);
            $sth->execute();
        }

        ## Selection Criteria
        #

        my $orgSelectionCriteria = $q->param("hidOrgSelectionCriteria");
        my $curSelectionCriteria = $q->param("hidCurSelectionCriteria");

        $orgSelectionCriteria = $orgSelectionCriteria * 1;
        $curSelectionCriteria = $curSelectionCriteria * 1;

        my $j = 0;
        for ($j = 1; $j <= $curSelectionCriteria; $j++) {
            my $selectionid = $j;

            my $title = $q->param("sc2_$j");
            $title = $dbh->quote($title);

            my $description = $q->param("sc3_$j");

            if ($createNewEntryFlag) {
                $sql = "insert into $schema.selection_criteria (decisionid, selectionid, title, description) values (\'$decisionid\', $selectionid, $title, ?)";
                $csr = $dbh->prepare($sql);
                $csr->bind_param(1, $description, {ora_type=>ORA_CLOB, ora_field=>'description'});
                $csr->execute;
                $dbh->commit;
                $csr->finish;
            } else {
                if ($j <= $orgSelectionCriteria) {
                    $sql = "update $schema.selection_criteria set title=$title, description=? where decisionid = \'$decisionid\' and selectionid=$selectionid";
                    $csr = $dbh->prepare($sql);
                    $csr->bind_param(1, $description, {ora_type=>ORA_CLOB, ora_field=>'description'});
                    $csr->execute;
                    $dbh->commit;
                    $csr->finish;
                } else {
                    $sql = "insert into $schema.selection_criteria (decisionid, selectionid, title, description) values (\'$decisionid\', $selectionid, $title, ?)";
                    $csr = $dbh->prepare($sql);
                    $csr->bind_param(1, $description, {ora_type=>ORA_CLOB, ora_field=>'description'});
                    $csr->execute;
                    $dbh->commit;
                    $csr->finish;
                }
            }
        }

        ## Option Rationale
        #
        my $orgOptionRationale = $q->param("hidOrgOptionRationale");
        my $curOptionRationale = $q->param("hidCurOptionRationale");

        $orgOptionRationale = $orgOptionRationale * 1;
        $curOptionRationale = $curOptionRationale * 1;

        $j = 0;

        for ($j = 1; $j <= $curOptionRationale; $j++) {
            my $optionid = $j; #$q->param("or1_$j");

            my $description = $q->param("or2_$j");
            #$description = $dbh->quote($description);

            my $optionrationale = $q->param("or3_$j");
            #$optionrationale = $dbh->quote($optionrationale);

            if ($createNewEntryFlag) {
                    my $sql = "insert into $schema.options (decisionid, optionid, description, optionrationale) values (\'$decisionid\', $optionid, ?, ?)";
                    $csr = $dbh->prepare($sql);
                    $csr->bind_param(1, $description, { ora_type=>ORA_CLOB, ora_field=>'description'});
                    $csr->bind_param(2, $optionrationale, { ora_type=>ORA_CLOB, ora_field=>'optionrationale'});
                    $csr->execute;
                    $dbh->commit;
                    $csr->finish;
            } else {
                if ($j <= $orgOptionRationale) {
                    my $sql = "update $schema.options set description=?, optionrationale=? where decisionid = \'$decisionid\' and optionid=$optionid";
                    $csr = $dbh->prepare($sql);
                    $csr->bind_param(1, $description, { ora_type=>ORA_CLOB, ora_field=>'description'});
                    $csr->bind_param(2, $optionrationale, { ora_type=>ORA_CLOB, ora_field=>'optionrationale'});
                    $csr->execute;
                    $dbh->commit;
                    $csr->finish;
                } else {
                    my $sql = "insert into $schema.options (decisionid, optionid, description, optionrationale) values (\'$decisionid\', $optionid, ?, ?)";
                    $csr = $dbh->prepare($sql);
                    $csr->bind_param(1, $description, { ora_type=>ORA_CLOB, ora_field=>'description'});
                    $csr->bind_param(2, $optionrationale, { ora_type=>ORA_CLOB, ora_field=>'optionrationale'});
                    $csr->execute;
                    $dbh->commit;
                    $csr->finish;
                }
            }
        }

        ## Code to delete selected attachments from the system
        #
        if ($createNewEntryFlag eq "") {
            my $orgAttachmentCount = $dmscgi->param("hidOrgAttachmentCount");
            my $i = 0;

            for ($i = 1; $i <= $orgAttachmentCount; $i++) {
                my $deleteAttachment = $dmscgi->param("attachmentDelete_$i");
                if ($deleteAttachment) {
                    my $sql = "delete from attachments where attachmentid = $deleteAttachment";
                    my $sth = $dbh->prepare($sql);
                    $sth->execute();
                    #print "$sql";
                }
            }
        }

        ## Attachment Code
        #
        my @filenames = $dmscgi->param("attachment");
        $index = "";

        foreach $index (@filenames) {
            if ($index) {
                my $newFilename = $index;

                $newFilename =~ s/\\/\//g;
                $newFilename =~ s!^.*/!!;  # return only the filename, remove the file path
                $newFilename =~ s/&//g;
                $newFilename =~ s/ /_/g;

                my %mimeTypes = (
                    'doc' => "application/msword",
                    'dot' => "application/msword",
                    'rtf' => "application/msword",
                    'xls' => "application/vnd.ms-excel",
                    'txt' => "text/plain",
                    'ppt' => "application/vnd.ms-powerpoint",
                    'pdf' => "application/pdf",
                );

                my $mimetype = undef;

                (undef,$mimetype) = split(/\./,$index);
                $mimetype = $mimeTypes{$mimetype};

                $mimetype = "text/plain" if $mimetype eq "";

                my $bytesread = undef;
                my $buffer = undef;
                my $attachmentData = undef;

                while ($bytesread=read($index,$buffer,1024000)) {
                    $attachmentData = $attachmentData.$buffer;
                }
                close $index;

                ## load attachment data into database
                #
                my $sql = "insert into $schema.attachments (attachmentid, decisionid, mimetype, attachment, filename) values (attachment_id.NEXTVAL, \'$decisionid\', \'$mimetype\', ?, \'$newFilename\')";
                my $csr = $dbh->prepare($sql);
                $csr->bind_param(1, $attachmentData, {ora_type=>ORA_BLOB, ora_field=>'attachment'});
                $csr->execute;
                $dbh->commit;
                $csr->finish;
                undef $attachmentData;
            }
        }


        ## If both the 'Done with Data Entry' and 'Decision Approved' checkboxes are checked, then run
        ## some updates on the database.
        #
        if ($isDoneWithDataEntry && $isDecisionApproved eq 'T') {

            my ($sql, $sth, $rc, @preparerArray, @developerArray, @decisionMakerArray);

            $sql = "update $schema.decisions set decisionstatus = 2 where decisionid = \'$decisionid\'";
            $rc = $dbh->do($sql);

            ## Preparer final
            #
            $sql = "select a.firstname, a.lastname, b.description from $schema.users a, $schema.organization b where id = $userid and a.organization = b.organizationid(+)";
            $sth = $dbh->prepare($sql);
            $sth->execute();
            @preparerArray = $sth->fetchrow_array();

            ## Developed By final
            #
            $sql = "select firstname, lastname, title from $schema.users a, $schema.organization b where id = $developedby and a.organization = b.organizationid(+)";
            $sth = $dbh->prepare($sql);
            $sth->execute();
            @developerArray = $sth->fetchrow_array();

            ## Decision Maker final
            #
            $sql = "select a.firstname, a.lastname, b.description from $schema.users a, $schema.organization b where id = $decisionmaker and a.organization = b.organizationid(+)";

            $sth = $dbh->prepare($sql);
            $sth->execute();
            @decisionMakerArray = $sth->fetchrow_array();

            ## Now update these in the Decisions table
            #
            $sql = "update $schema.decisions set preparerfinal = \'$preparerArray[0] $preparerArray[1], $preparerArray[2]\', developedbyfinal = \'$developerArray[0] $developerArray[1], $developerArray[2]\', decisionmakerfinal = \'$decisionMakerArray[0] $decisionMakerArray[1], $decisionMakerArray[2]\' where decisionid = \'$decisionid\'";
            $rc = $dbh->do($sql);

            &log_activity($dbh, $schema, $userid, "$decisionid - Approve Decision");
        }

        if ((! defined($createNewEntryFlag)) && (! defined($isDoneWithDataEntry))) {
            &log_activity($dbh, $schema, $userid, "$decisionid - Update Pending Decision");
        }


        ## Redirect back to the home screen.
        #
        print <<EO_saveChanges;

        <form name=decisions>

        <script language="JavaScript">
            //alert(document.decisions.userid.value);
            document.decisions.action = '/cgi-bin/dms/home.pl';
            document.decisions.target = 'main';
            document.decisions.decisionid.value = '$decisionid';
            document.decisions.submit();
        </script>

EO_saveChanges

    };

    if ($@) {
        my $message = errorMessage($dbh,$username,$userid,$schema,"process $command.",$@);
        print doAlertBox( text => $message);
    }

######################################################################################################################
#
} elsif ($command eq 'printable_es') {
    eval {

        my ($sql, $decisionid, $sth, @array);

        $decisionid = $dmscgi->param("decisionid");


        $sql = "select * from $schema.decisions where decisionid = \'$decisionid\'";

        $sth = $dbh->prepare($sql);
        $sth->execute();

        @array = $sth->fetchrow_array();

        ## transform the QA Status
        #
        $array[4] = "QA" if $array[4] eq "T";
        $array[4] = "Non QA" if $array[4] eq "F";

        ## Insert html line breaks.
        #
        my $BR = '<br>';
        $array[15] =~ s/\n/$BR/g;
        $array[16] =~ s/\n/$BR/g;
        $array[17] =~ s/\n/$BR/g;

        ## Decision Maker
        #
        if ($array[11]) {
            $sql = "select a.firstname, a.lastname, b.description from $schema.users a, $schema.organization b where id = $array[11] and a.organization = b.organizationid(+)";

            $sth = $dbh->prepare($sql);
            $sth->execute();

            my @array2 = $sth->fetchrow_array();
            $array[11] = "$array2[0] $array2[1], $array2[2]";
        } else {
            $array[11] = "N/A";
        }

        ## Clean up all the HTML whitespace
        #
        my $index = "";
        foreach $index (@array) {
            $index = "&nbsp;" if $index eq "";
        }

    print <<EO_PRINTABLE_ES;

    <BODY BGCOLOR=#ffffff LINK=#0000ff ALINK=#0000ff VLINK=#0000ff>
    <!-- Main Header Table - Static -->
    <center>


    <TABLE CELLSPACING=0 CELLPADDING=3 WIDTH=660 BORDER=0>
    <TR><TD COLSPAN=2 align="right"><FONT FACE=ARIAL SIZE=2 COLOR="#000000">QA: $array[4]</FONT></TD></TR>
    <TR><TD COLSPAN=2 BGCOLOR=#eeeeee><FONT FACE=ARIAL SIZE=5 COLOR=#000000><B>Decision Package Executive Summary</B></FONT></TD></TR>
    <TR><TD COLSPAN=2><IMG SRC=/dms/images/clear.gif WIDTH=50 HEIGHT=20></TD></TR>
    <!-- Main Header Table - Dynamic -->

    <TR><TD NOWRAP WIDTH=120><FONT FACE=ARIAL COLOR=#000000><B>Decision #:</B></FONT></TD><TD WIDTH=630><FONT FACE=ARIAL COLOR=#000000>$array[0]</FONT></TD></TR>
    <TR><TD><FONT FACE=ARIAL COLOR=#000000><B>Title:</B></FONT></TD><TD><FONT FACE=ARIAL COLOR=#000000>$array[1]</FONT></TD></TR>
    <TR><TD><FONT FACE=ARIAL COLOR=#000000><B>Accession No:</B></FONT></TD><TD> <FONT FACE=ARIAL COLOR=#000000>$array[5]</FONT> </TD></TR>
    <TR><TD><FONT FACE=ARIAL COLOR=#000000><B>Keywords:</B></FONT></TD><TD><FONT FACE=ARIAL COLOR=#000000></FONT></TD></TR>

    </TABLE>

    <IMG SRC=/dms/images/clear.gif WIDTH=50 HEIGHT=30>

    <!-- Body Table -->

    <TABLE CELLSPACING=0 CELLPADDING=3 WIDTH=660 BORDER=0>
    <TR><TD><FONT FACE=ARIAL SIZE=3 COLOR=#000000><B>Statement for Consideration:</B></FONT></TD><td align="right"><a href=#></a></td></TR>
    <TR><TD VALIGN=TOP COLSPAN=2>
    <FONT FACE=ARIAL COLOR=#000000>
    $array[15]
    </FONT>
    </TD></TR>

    <TR><TD COLSPAN=2><IMG SRC=/dms/images/clear.gif WIDTH=20 HEIGHT=30></TD></TR>

    <TR><TD><FONT FACE=ARIAL SIZE=3 COLOR=#000000><B>Recommendation:</B></FONT></TD></TR>
    <TR><TD VALIGN=TOP COLSPAN=2> <FONT FACE=ARIAL COLOR=#000000>
    $array[16]
    </FONT>
    </TD></TR>

    <TR><TD><IMG SRC=/dms/images/clear.gif WIDTH=20 HEIGHT=30></TD></TR>

    <TR><TD><FONT FACE=ARIAL SIZE=3 COLOR=#000000><B>Decision:</B></FONT></TD></TR>
    <TR><TD VALIGN=TOP> <FONT FACE=ARIAL COLOR=#000000>
    $array[17]
    </FONT>
    </TD></TR>

    <TR><TD><IMG SRC=/dms/images/clear.gif WIDTH=20 HEIGHT=30></TD></TR>

    <TR><TD><FONT FACE=ARIAL SIZE=3 COLOR=#000000><B>Attachments:</B></FONT></TD></TR>
    <TR><TD VALIGN=TOP> <FONT FACE=ARIAL COLOR=#000000>
    <P>
    <LI>Decision Analysis</LI>
    </P>
    </TD></TR>
    </TABLE>

    <TR><TD><IMG SRC=/dms/images/clear.gif WIDTH=20 HEIGHT=30></TD></TR>

    <!-- Footer Table -->

    <TABLE CELLSPACING=0 CELLPADDING=3 WIDTH=660 BORDER=0>
    <TR><TD COLSPAN=2><FONT FACE=ARIAL COLOR=#000000><B>Approved By:</B></FONT></TD></TR>
    <TR><TD COLSPAN=2><IMG SRC=/dms/images/clear.gif WIDTH=20 HEIGHT=20></TD></TR>
    <TR><TD><IMG SRC=/dms/images/hr01.gif WIDTH=500 HEIGHT=2></TD><TD WIDTH=180><IMG SRC=/dms/images/hr01.gif WIDTH=100 HEIGHT=2></TD></TR>
    <TR><TD><FONT FACE=ARIAL COLOR=#000000><B>$array[11]</B></FONT></TD><TD WIDTH=180><FONT FACE=ARIAL COLOR=#000000><B>Date</B></FONT></TD></TR>

    </TD></TR>
    </TABLE>

EO_PRINTABLE_ES

    &log_activity($dbh, $schema, $userid, "$decisionid - View Printable Executive Summary");



    };
    if ($@) {
        my $message = errorMessage($dbh,$username,$userid,$schema,"process $command.",$@);
        print doAlertBox( text => $message);
    }

######################################################################################################################
#
} elsif ($command eq 'printable_da') {
    eval {

        my ($sql, $decisionid, $sth, @array);

        $decisionid = $dmscgi->param("decisionid");


        $sql = "select * from $schema.decisions where decisionid = \'$decisionid\'";

        $sth = $dbh->prepare($sql);
        $sth->execute();

        @array = $sth->fetchrow_array();

        ## transform the QA Status
        #

        $array[4] = "QA" if $array[4] eq "T";
        $array[4] = "Non QA" if $array[4] eq "F";

        ## Keywords
        #

        $sql = "select a.keywordid, a.keyword from $schema.keywords a, $schema.decision_keywords b ".
               "where b.decisionid = \'$decisionid\' and a.keywordid = b.keywordid(+)";

        my @array1 = ();
        my $keywordString = "";

        $sth = $dbh->prepare($sql);
        $sth->execute();

        while (@array1 = $sth->fetchrow_array()) {
            $keywordString = $keywordString.$array1[1].", ";
        }

        ## Get rid of the space and the extra comma.
        chop($keywordString);
        chop($keywordString);

        my @array2 = ();

        ## Developed By
        if ($array[10]) {
            $sql = "select a.firstname, a.lastname, b.description from $schema.users a, $schema.organization b where id = $array[10] and a.organization = b.organizationid(+)";

            $sth = $dbh->prepare($sql);
            $sth->execute();

            @array2 = $sth->fetchrow_array();
            $array[10] = "$array2[0] $array2[1], $array2[2]";
        } else {
            $array[10] = "N/A";
        }

        ## Decision Maker
        if ($array[11]) {
            $sql = "select a.firstname, a.lastname, b.description from $schema.users a, $schema.organization b where id = $array[11] and a.organization = b.organizationid(+)";

            $sth = $dbh->prepare($sql);
            $sth->execute();

            @array2 = $sth->fetchrow_array();
            $array[11] = "$array2[0] $array2[1], $array2[2]";
        } else {
            $array[11] = "N/A";
        }

        ## Clean up all the HTML whitespace
        #
        my $index = "";
        foreach $index (@array) {
            $index = "&nbsp;" if not defined($index);
        }

        # selection criteria table

        my @array3 = ();

        $sql = "select * from $schema.selection_criteria where decisionid = \'$decisionid\' order by selectionid";

        $sth = $dbh->prepare($sql);
        $sth->execute();

        my $selectionString = "<table cellspacing=0 cellpadding=2 width=660 border=1 bordercolor=c0c0c0><tr><td bgcolor=#eeeeee><font face=arial size=3 COLOR=#000000><b>Selection Criteria</b></font></td></tr></table>";

        $selectionString = $selectionString."<table cellspacing=0 cellpadding=2 width=660 border=0>";

        while (@array3 = $sth->fetchrow_array()) {

            my $BR = '<br>';

            $array3[3] =~ s/\n/$BR/g;

            $selectionString = $selectionString."<tr><td><img src=/dms/images/clear.gif width=50 height=10></td></tr>\n";
            $selectionString = $selectionString."<tr><td><font face=arial COLOR=#000000><b>$array3[0] - $array3[2]</b></td></tr>\n";
            $selectionString = $selectionString."<tr><td><font face=arial COLOR=#000000>$array3[3]</td></tr>\n";
        }

        $selectionString = $selectionString."</table>";

        # option rationale table

        my @array4 = ();

        $sql = "select * from $schema.options where decisionid = \'$decisionid\' order by optionid";

        $sth = $dbh->prepare($sql);
        $sth->execute();

        my $optionString = "<table cellspacing=0 cellpadding=3 width=660 border=1 bordercolor=#c0c0c0><tr><td bgcolor=#eeeeee colspan=3><font face=arial size=3 COLOR=#000000><b>Option Description</b></font></td></tr><tr><td><img src=/dms/images/clear.gif width=20 height=1></td><td><font face=arial COLOR=#000000><b>Description</b></font></td><td><font face=arial COLOR=#000000><b>Selection Rationale</b></font></td></tr>";

        while (@array4 = $sth->fetchrow_array()) {
            my $BR = '<br>';
            my $index = undef;
            foreach $index (@array4) {
                $index = '&nbsp;' if $index eq "";
            }
            $array4[3] =~ s/\n/$BR/g;

            $optionString = $optionString."<tr><td valign=top><font face=arial COLOR=#000000><b>$array4[0]</td><td valign=top><font face=arial COLOR=#000000>$array4[2]</td><td valign=top><font face=arial COLOR=#000000>$array4[3]</td></td></tr>\n";
        }

        $optionString = $optionString."</table>";

        ## Attachments
        #
        my @array5 = ();
        $sql = "select filename from $schema.attachments where decisionid = \'$decisionid\'";

        $sth = $dbh->prepare($sql);
        $sth->execute();

        my $attachmentTableString = "<TABLE CELLSPACING=0 CELLPADDING=3 WIDTH=660 BORDER=1 BORDERCOLOR=#c0c0c0><TR><TD BGCOLOR=#eeeeee><FONT FACE=ARIAL SIZE=3 COLOR=#000000><B>Attachment(s)</B></FONT></TD></TR><TR><TD align=left>";
        my $attachmentIconString = "<table border=0><tr>";
        my $attachmentNameString = "<tr>";

        while (@array5 = $sth->fetchrow_array()) {
            my ($filename, $ext);

            ($filename, $ext) = split(/\./,$array5[0]);

            my %extensions = (
                'doc' => "doc.gif",
                'dot' => "doc.gif",
                'rtf' => "doc.gif",
                'xls' => "xls.gif",
                'txt' => "txt.gif",
                'ppt' => "ppt.gif",
                'pdf' => "pdf.gif",
                'htm' => "htm.gif",
                'html' => "htm.gif",
                'zip' => "zip.gif"
            );

            my $iconExt = "";
            $iconExt = $extensions{$ext};

            $iconExt = 'misc.gif' if not defined($iconExt);

            $attachmentIconString = $attachmentIconString."<td align=center><img src=/dms/icons/32/$iconExt> &nbsp;&nbsp;</td>";
            $attachmentNameString = $attachmentNameString."<td align=center><font face=arial COLOR=#000000>$array5[0]</font> &nbsp;&nbsp;</td>";
        }

        $attachmentIconString = $attachmentIconString."</tr>";
        $attachmentNameString = $attachmentNameString."</tr></table>";


    ## Pad /n with <br>s in Recommendation
    #
    my $BR = '<br>';
    $array[18] =~ s/\n/$BR/g;

    print <<EO_PRINTABLE_DA;

    <center>
    <TABLE CELLSPACING=0 CELLPADDING=3 WIDTH=660 BORDER=0>
    <TR><TD COLSPAN=2 align="right"><FONT FACE=ARIAL SIZE=2 COLOR="#000000">QA: $array[4]</FONT></TD></TR>
    <TR><TD COLSPAN=2 BGCOLOR=#eeeeee><FONT FACE=ARIAL SIZE=5 COLOR=#000000><B>Decision Analysis</B></FONT></TD></TR>
    <TR><TD COLSPAN=2><IMG SRC=/dms/images/clear.gif WIDTH=50 HEIGHT=20></TD></TR>
    <!-- Main Header Table - Dynamic -->

    <TR><TD NOWRAP WIDTH=120><FONT FACE=ARIAL COLOR=#000000><B>Decision No:</B></FONT></TD><TD WIDTH=630><FONT FACE=ARIAL COLOR=#000000>$array[0]</FONT></TD></TR>
    <TR><TD><FONT FACE=ARIAL COLOR=#000000><B>Title:</B></FONT></TD><TD><FONT FACE=ARIAL COLOR=#000000>$array[1]</FONT></TD></TR>
    <TR><TD><FONT FACE=ARIAL COLOR=#000000><B>Accession No:</B></FONT></TD><TD> <FONT FACE=ARIAL COLOR=#000000>$array[5]</A></FONT> </TD></TR>
    <TR><TD><FONT FACE=ARIAL COLOR=#000000><B>Keywords:</B></FONT></TD><TD><FONT FACE=ARIAL COLOR=#000000>$keywordString</FONT></TD></TR>
    </TABLE>

    <IMG SRC=/dms/images/clear.gif WIDTH=50 HEIGHT=30>

    <!-- Selection Criteria Table -->

    $selectionString
    <IMG SRC=/dms/images/clear.gif WIDTH=50 HEIGHT=30>

    <!-- Option Description Table -->

    $optionString

    <IMG SRC=/dms/images/clear.gif WIDTH=50 HEIGHT=30>

    <!-- Recommendation Table -->

    <TABLE CELLSPACING=0 CELLPADDING=3 WIDTH=660 BORDER=1 BORDERCOLOR="#c0c0c0">
    <TR><TD BGCOLOR="#eeeeee"><FONT FACE=ARIAL SIZE=3 COLOR=#000000><B>Recommendation</B></FONT></TD></TR>
    <TR><TD><FONT FACE=ARIAL COLOR=#000000>
    $array[18]
    </FONT></TD></TR>
    </TABLE>

    <IMG SRC=/dms/images/clear.gif WIDTH=50 HEIGHT=30>

    <!-- References Table -->

    <TABLE CELLSPACING=0 CELLPADDING=3 WIDTH=660 BORDER=1 BORDERCOLOR="#c0c0c0">
    <TR><TD BGCOLOR="#eeeeee"><FONT FACE=ARIAL SIZE=3 COLOR=#000000><B>References</B></FONT></TD></TR>
    <TR><TD><FONT FACE=ARIAL SIZE=3 COLOR=#000000>
    $array[19]
    </FONT></TD></TR>
    </TABLE>

    <IMG SRC=/dms/images/clear.gif WIDTH=50 HEIGHT=30>

    <!-- Attachements Table -->

    $attachmentTableString
    $attachmentIconString
    $attachmentNameString
    </td></tr></table>

    <IMG SRC=/dms/images/clear.gif WIDTH=50 HEIGHT=30>

    <!-- Prepared By Table -->

    <TABLE CELLSPACING=0 CELLPADDING=3 WIDTH=660 BORDER=0>
    <TR><TD COLSPAN=2><FONT FACE=ARIAL SIZE=3 COLOR=#000000><B>Prepared By:</B></FONT></TD></TR>
    <TR><TD COLSPAN=2><IMG SRC=/dms/images/clear.gif WIDTH=20 HEIGHT=20></TD></TR>
    <TR><TD><IMG SRC=/dms/images/hr01.gif WIDTH=500 HEIGHT=2></TD><TD WIDTH=180><IMG SRC=/dms/images/hr01.gif WIDTH=140 HEIGHT=2></TD></TR>
    <TR><TD><FONT FACE=ARIAL COLOR=#000000><B>$array[10]</B></FONT></TD><TD WIDTH=180><FONT FACE=ARIAL COLOR=#000000><B>Date</B></FONT></TD></TR>
    </TD></TR>
    </TABLE>

    <IMG SRC=/dms/images/clear.gif WIDTH=50 HEIGHT=30>

    <!-- Approved By Table -->

    <TABLE CELLSPACING=0 CELLPADDING=3 WIDTH=660 BORDER=0>
    <TR><TD COLSPAN=2><FONT FACE=ARIAL COLOR=#000000><B>Approved By:</B></FONT></TD></TR>
    <TR><TD COLSPAN=2><IMG SRC=/dms/images/clear.gif WIDTH=20 HEIGHT=20></TD></TR>
    <TR><TD><IMG SRC=/dms/images/hr01.gif WIDTH=500 HEIGHT=2></TD><TD WIDTH=180><IMG SRC=/dms/images/hr01.gif WIDTH=140 HEIGHT=2></TD></TR>
    <TR><TD><FONT FACE=ARIAL COLOR=#000000><B>$array[11]</B></FONT></TD><TD WIDTH=180><FONT FACE=ARIAL COLOR=#000000><B>Date</B></FONT></TD></TR>
    </TD></TR>
    </TABLE>

    </BODY>
    </HTML>


EO_PRINTABLE_DA

    &log_activity($dbh, $schema, $userid, "$decisionid - View Printable Decision Analysis");

    };
    if ($@) {
        my $message = errorMessage($dbh,$username,$userid,$schema,"process $command.",$@);
        print doAlertBox( text => $message);
    }

######################################################################################################################
#
} elsif ($command eq 'completeApproved') {
    eval {

        my $decisionid = $dmscgi->param("decisionid");
        my $accession = $dmscgi->param("accession");

        ## Set the Decision Status to Completed and insert the Accession ID into the system
        #

        my $sql = "update $schema.decisions set decisionstatus = 3, accession = \'$accession\' where decisionid = \'$decisionid\'";

        my $sth = $dbh->prepare($sql);
        $sth->execute();

        &log_activity($dbh, $schema, $userid, "$decisionid - Complete Decision Package");


        ## redirect back to the home page
        #

        print <<EO_completeApproved;

        <form name=decisions>

        <script language="JavaScript">
            //alert(document.decisions.userid.value);
            document.decisions.action = '/cgi-bin/dms/home.pl';
            document.decisions.target = 'main';
            document.decisions.decisionid.value = '$decisionid';
            document.decisions.submit();
        </script>

EO_completeApproved

    };

    if ($@) {
        my $message = errorMessage($dbh,$username,$userid,$schema,"process $command.",$@);
        print doAlertBox( text => $message);
    }
} elsif ($command eq "saveChanges_test") {
    eval {


    };

    if ($@) {
        my $message = errorMessage($dbh,$username,$userid,$schema,"process $command.",$@);
        print doAlertBox( text => $message);
    }
}

print "</form>\n";

print <<END_OF_BLOCK;

<form name=viewattachment>
<input type=hidden name=userid value=$userid>
<input type=hidden name=username value=$username>
<input type=hidden name=schema value=$schema>
<input type=hidden name=attachmentid value=0>
<input type=hidden name=command value="">
</form>

</body>
</html>
END_OF_BLOCK

&db_disconnect($dbh);
exit();