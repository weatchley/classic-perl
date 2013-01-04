#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# New Issue script for CMS - part of the final product
#
# $Source: /data/dev/cirs/perl/RCS/newissue.pl,v $
# $Revision: 1.28 $
# $Date: 2001/05/04 19:21:26 $
# $Author: naydenoa $
# $Locker:  $
# $Log: newissue.pl,v $
# Revision 1.28  2001/05/04 19:21:26  naydenoa
# Updated evals
#
# Revision 1.27  2000/11/07 23:17:17  naydenoa
# Added mail notification
#
# Revision 1.26  2000/10/26 17:01:45  naydenoa
# Added remark addition, resized tables to 650 for print.
#
# Revision 1.25  2000/10/24 22:55:54  atchleyb
# fixed netscape/javascript bug with meltdates
#
# Revision 1.24  2000/10/24 15:30:34  naydenoa
# Took out issue type assignment
#
# Revision 1.23  2000/10/18 21:33:00  munroeb
# modified activity log message
#
# Revision 1.22  2000/10/17 23:19:21  naydenoa
# A slight interface tweak.
#
# Revision 1.21  2000/10/17 16:00:32  munroeb
# removed log_history perm.
#
# Revision 1.20  2000/10/16 18:09:23  munroeb
# removed log_history function
#
# Revision 1.19  2000/10/06 18:01:54  munroeb
# added log_activity feature to the script
#
# Revision 1.18  2000/10/03 20:42:24  naydenoa
# Changed keyword arrows (add - top, remove - bottom).
#
# Revision 1.17  2000/09/29 15:56:05  atchleyb
# fixed javascript validation for netscape
#
# Revision 1.16  2000/09/29 15:48:12  naydenoa
# Took out Suggested Resolution field, checkpoint after 2nd release
#
# Revision 1.15  2000/09/27 16:41:36  atchleyb
# fixed inser code
#
# Revision 1.14  2000/09/26 00:54:34  atchleyb
# changed inserts to specify column names
#
# Revision 1.13  2000/09/25 17:37:51  naydenoa
# More interface update
#
# Revision 1.12  2000/09/18 15:08:51  naydenoa
# Interface update
#
# Revision 1.11  2000/09/08 23:45:42  naydenoa
# Interface change, added use of Edit_Screens.pm
#
# Revision 1.10  2000/08/31 23:22:02  atchleyb
# check point
#
# Revision 1.9  2000/08/21 20:30:12  atchleyb
# fixed var name bug
#
# Revision 1.8  2000/08/21 18:54:19  atchleyb
# added check schema line
# changed testout to cmscgi
#
# Revision 1.7  2000/07/24 15:58:33  johnsonc
# Inserted GIF file for display.
#
# Revision 1.6  2000/07/10 23:29:32  munroeb
# centered table and forced 70px width
# -- 750px width
#
# Revision 1.5  2000/07/06 23:42:51  munroeb
# finished making mods to to html and javascripts.
#
# Revision 1.4  2000/07/05 23:06:42  munroeb
# made minor changes to html and javascripts
#
# Revision 1.3  2000/06/12 23:34:46  zepedaj
# Added code to bypass the screening board.
#
# Revision 1.2  2000/05/18 23:14:04  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/11 23:55:06  zepedaj
# Initial revision
#
#

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);
use Edit_Screens;

use strict;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

# print content type header
print $cmscgi->header('text/html');

my $pagetitle = "Issue/Condition Entry";
my $cgiaction = $cmscgi->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = "issue";
my $activity;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

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
<script src="$ONCSJavaScriptPath/oncs-utilities.js"></script>
<script type="text/javascript">
<!--
var dosubmit = true;
if (parent == self) {  // not in frames
   location = '$ONCSCGIDir/login.pl'
}
function validatedata() {
    var msg = "";
    var tmpmsg = "";
    var returnvalue = true;
    var validateform = document.issueentry;
    msg += (validateform.issuetext.value=="") ? "You must enter the issue text.\\n" : "";
    msg += ((tmpmsg = validate_date(validateform.dateoccurred_year.value, validateform.dateoccurred_month[validateform.dateoccurred_month.selectedIndex].value, validateform.dateoccurred_day[validateform.dateoccurred_day.selectedIndex].value, 0, 0, 0, 0, true, false, false)) == "") ? "" : tmpmsg + "\\n";
    validateform.dateoccurred.value = Melt_Date_Parts_Together(validateform.dateoccurred_month[validateform.dateoccurred_month.selectedIndex].value, validateform.dateoccurred_day[validateform.dateoccurred_day.selectedIndex].value, validateform.dateoccurred_year.value);
    msg += (validateform.category[validateform.category.selectedIndex].value=='') ? "You must select the category for this issue.\\n" : "";
    if (msg != "") {
        alert(msg);
        returnvalue = false;
        }
    return (returnvalue);
}
//-->
</script>
<script language="JavaScript" type="text/javascript">
<!--
    doSetTextImageLabel('Issue/Condition Entry');
//-->
</script>
testlabel1

my $dbh = oncs_connect();

# process the input issue
###################################
if ($cgiaction eq "submit_issue") {
###################################
    my $nextissueid;
    $activity = "Get Next Issue Sequence";
    eval {
        $nextissueid = get_next_id($dbh, $updatetable);
	$dbh -> commit;
    };
    if ($@) {
	$dbh -> rollback;
        my $alertstring = errorMessage($dbh, $username, $usersid, 'issueid_seq', "", $activity, $@);
        print <<issueseqerror;
        <script language="JavaScript" type="text/javascript">
        <!--
        alert("$alertstring");
        //-->
        </script>
issueseqerror
        &oncs_disconnect($dbh);
        exit 1;
    }
    my $issuetext = $cmscgi->param('issuetext');
    my $dateoccurred = $cmscgi->param('dateoccurred');
    my $entered_date = get_formatted_date('DD-MON-YYYY');
    my $page = $cmscgi->param('page');
    my $categoryid = $cmscgi->param('category');
    $categoryid = ($categoryid) ? $categoryid : 'NULL';
    my $enteredby = $usersid;
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);
    my $suggestedresolution = $cmscgi->param('suggestedresolution');
    my $remarks = $cmscgi -> param ('commenttext');

    my $sqlstring = "INSERT INTO $SCHEMA.$updatetable
                            (issueid, text, entereddate, page, enteredby, 
                             categoryid, dateoccurred, siteid)
                     VALUES ($nextissueid, :textclob,
                             TO_DATE('$entered_date', 'DD-MON-YYYY'), 
                             '$page', $enteredby, $categoryid, 
                             TO_DATE('$dateoccurred', 'MM/DD/YYYY'), $siteid)";
    eval {
        $activity = "Insert Historical Issue Information $nextissueid";
        my $csr = $dbh->prepare($sqlstring);
        $csr->bind_param(":textclob", $issuetext, {ora_type => ORA_CLOB, ora_field => 'text' });
        $csr->execute;

        #add keywords to record(s)
        my $keywordid;
        foreach $keywordid ($cmscgi->param('keywords')) {
            if ($keywordid ne '') {
                $activity = "Insert keyword: $keywordid for issue: $nextissueid.";
                my $keywordsqlstring = "INSERT INTO $SCHEMA.issuekeyword (issueid,keywordid) VALUES($nextissueid, $keywordid)";
                $csr = $dbh->prepare($keywordsqlstring);
                $csr->execute;
            }
        }
	if ($remarks) {
	    my $insertremark = "insert into $SCHEMA.issue_remarks (issueid, text, dateentered, usersid) values ($nextissueid, :remark, SYSDATE, $usersid)";
	    $csr = $dbh -> prepare ($insertremark);
	    $csr -> bind_param (":remark", $remarks, {ora_type => ORA_CLOB, ora_field => 'text'});
	    $csr -> execute;
	}
        $activity = "Set Issue Roles for default Commitment Coordinator";
        my $MOCC_roleid = 1;
        my $MOCC_usersid;
        ($MOCC_usersid) = lookup_column_values($dbh, 'defaultcategoryrole', 'usersid', "roleid = $MOCC_roleid AND categoryid = $categoryid AND siteid = $siteid");
        #delete any existing commitment Coordinator (shouldn't be needed but included for completeness)
        my $issueroledelsql = "DELETE FROM $SCHEMA.issuerole WHERE issueid = $nextissueid AND roleid = $MOCC_roleid";
        $csr = $dbh->prepare($issueroledelsql);
        $csr->execute;

        #add new role
        my $issuerolesqlstring = "INSERT INTO $SCHEMA.issuerole (issueid, roleid, usersid) VALUES ($nextissueid, $MOCC_roleid, $MOCC_usersid)";
        $csr = $dbh->prepare($issuerolesqlstring);
        $csr->execute;
        #  end of screening board bypass.

        $csr->finish;
	$dbh->commit;
    };
    if ($@) {
        $dbh->rollback;
        my $alertstring = errorMessage($dbh, $username, $usersid, 'issue', "$nextissueid", $activity, $@);
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
        &log_activity($dbh, 'F', $usersid, "Issue ".&formatID2($nextissueid, 'I')." added to the system");
	my $coords = $dbh -> prepare ("select distinct usersid from $SCHEMA.defaultcategoryrole where siteid = $siteid");
	$coords -> execute;
	while (my ($coordid) = $coords -> fetchrow_array) {
	    my $notification = &notifyUser(dbh => $dbh, schema => $SCHEMA, userID => $coordid);
	}
        print <<pageresults;
        <script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
    }
    &oncs_disconnect($dbh);
    print "</head><body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0></body></html>\n";
    exit 1;
}  ######### endif submit_issue #############

####################
my %categoryhash = get_lookup_values($dbh, 'category', 'description', 'categoryid', "isactive='T'");
my %sourcedochash = get_lookup_values($dbh, 'sourcedoc', "accessionnum || ' - ' || title || ' - ' || to_char(documentdate, 'MM/DD/YYYY') || ';' || sourcedocid", 'sourcedocid');
my %keywordhash = get_lookup_values($dbh, 'keyword', 'description', 'keywordid', "isactive='T'");
my $key = '';

print "</head>\n\n";
print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
print "<form target=control action=\"$ONCSCGIDir/newissue.pl\" enctype=\"multipart/form-data\" method=post name=issueentry onsubmit=\"return(validatedata())\">\n";

print "<input name=cgiaction type=hidden value=\"submit_issue\">\n";
print "<input type=hidden name=schema value=$SCHEMA><CENTER>\n";
print "<table summary=\"enter issue table\" width=750 align=center cellspacing=10 border=0>\n";
print "<tr><td><table width=650 align=center cellspacing=10>\n";
print "<tr><td align=left><b><li>Issue Text:&nbsp;&nbsp;</b>\n";
print "(be as clear and complete as possible)<br>\n";
print "<textarea name=issuetext cols=75 rows=5></textarea>\n";
print "<input name=usersid type=hidden value=$usersid>\n";
print "<input name=username type=hidden value=$username></td></tr>\n";
print "<tr><td align=left><b><li>Date of Occurence:&nbsp;&nbsp;</b>\n";
print build_date_selection('dateoccurred', 'issueentry');
print "<br>(Use date of letter or date entered if issue does not have a specific date)</td></tr>\n";
print "<tr><td align=left><b><li>Source Document Page Number:&nbsp;&nbsp;</b>\n";
print "<input name=page type=text maxlength=5 size=5>\n";
print "&nbsp;&nbsp;(Leave blank if not available)</td></tr>\n";
print "<tr><td align=left><b><li>Source Category:&nbsp;&nbsp;</b>\n";
print "<select name=category>\n";
print "<option value='' selected>Select A Category\n";
foreach $key (sort keys %categoryhash) {
    print "<option value=\"$categoryhash{$key}\">$key\n";
}
print "</select>\n</td></tr>\n";
print "<tr><td align=left><b><li>Keywords:&nbsp;&nbsp;</b>\n";
print "(optional, do not select any if not available)<br>\n";
print "<table border=0 summary=\"Keyword Selection\" align=center>\n";
print "<tr align=Center><td><b>Keyword List</b></td>\n";
print "<td>&nbsp;</td>\n";
print "<td><b>Keywords Selected</b></td></tr>\n";
print "<tr><td>\n";
print "<select name=allkeywordlist size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.issueentry.allkeywordlist, document.issueentry.keywords, 'move')\">\n";
foreach $key (sort keys %keywordhash) {
    print "<option value=\"$keywordhash{$key}\">$key\n";
}
print "<option value=''>" . &nbspaces(50) . "\n</select></td>\n";
print "<td><input name=keywordrightarrow title=\"Click to select the keyword(s)\" value=\"-->\" type=button onclick=\"process_multiple_dual_select_option(document.issueentry.allkeywordlist, document.issueentry.keywords, 'move')\">\n";
print "<br><input name=keywordleftarrow title=\"Click to remove the selected keyword(s)\" value=\"<--\" type=button onclick=\"process_multiple_dual_select_option(document.issueentry.keywords, document.issueentry.allkeywordlist, 'move')\"></td>\n";
print "<td><select name=keywords size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.issueentry.keywords, document.issueentry.allkeywordlist, 'move')\">\n";
print "<option value=''>" . &nbspaces(50) . "\n</select></td></tr></table>\n";
print "</td></tr>\n";
print "<tr><td><hr width=70%></td></tr>\n";
print writeComment (active => 1);
print "</table></td></tr></table>\n";
print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=loginusername type=hidden value=$username>\n";
print "<input name=loginusersid type=hidden value=$usersid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";
print "<input type=hidden name=schema value=$SCHEMA>\n";

&oncs_disconnect($dbh);

print "<input name=submit type=submit value=\"Submit Issue\" onclick=\"selectemall(document.issueentry.keywords)\">\n";
print "</form><br><br><br>\n";
print "</body>\n</html>\n";
