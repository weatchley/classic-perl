#!/usr/local/bin/newperl -w
#
# Home Screen for Commitment Management System
#
# $Source: /data/dev/rcs/cms/perl/RCS/home.pl,v $
# $Revision: 1.20 $
# $Date: 2002/03/08 20:51:57 $
# $Author: naydenoa $
# $Locker:  $
# $Log: home.pl,v $
# Revision 1.20  2002/03/08 20:51:57  naydenoa
# Fixed bug in site retrieval.
#
# Revision 1.19  2001/12/10 23:22:31  naydenoa
# Updated section roles for commitments (BSCLL to BSCDL)
#
# Revision 1.18  2001/11/15 23:32:09  naydenoa
# Added new sections for actions, updated sections to reflect role
# changes, added function to handle commitment action entry and
# notification of appropriate leads.
#
# Revision 1.17  2001/07/30 20:40:37  naydenoa
# Initial setup for actions. Checkpoint
#
# Revision 1.16  2001/05/17 17:05:41  naydenoa
# Incorporated the Sys Admin role as superuser
#
# Revision 1.15  2001/05/11 22:01:38  naydenoa
# Removed references to privileges
#
# Revision 1.14  2001/03/06 21:51:50  naydenoa
# Changed M&O to BSC
#
# Revision 1.13  2000/11/06 18:06:20  naydenoa
# Changed due date to commit date in tables past CMaker decision,
# changed due date to close date for Final Response table,
# changed date formatting form DD-MON-YY to MM/DD/YYYY
#
# Revision 1.12  2000/10/23 18:12:54  naydenoa
# Table formatting, log message update
#
# Revision 1.11  2000/10/20 15:07:19  naydenoa
# Changed issue table so that issues with commitments in CC review
# cannot be closed
#
# Revision 1.10  2000/10/19 23:32:03  naydenoa
# Added table column to CC -- allows issue closure
#
# Revision 1.9  2000/10/17 17:09:32  naydenoa
# Fixed column widths. Checkpoint.
#
# Revision 1.8  2000/10/04 19:10:51  atchleyb
# commented out code for updating historical data
#
# Revision 1.7  2000/10/03 20:44:42  naydenoa
# Updates status id's and references.
#
# Revision 1.6  2000/09/29 18:49:52  naydenoa
# Changed references to roles and statuses from names to numbers,
# reversed issue order in Commitment Coordinator table,
# checkpoint after release of Version 2
#
# Revision 1.5  2000/09/08 23:45:09  naydenoa
# Some modifications to table columns displayed.
#
# Revision 1.4  2000/09/02 00:00:59  naydenoa
# Checking it in for the holiday weekend.
#
# Revision 1.3  2000/08/26 00:06:30  naydenoa
# Added table columns for open sections
#
# Revision 1.2  2000/08/25 18:46:21  naydenoa
# Cleaned up code, added javascript functions bypassing view
# screens, color-coded section tables.
#
#

use integer;
use strict;
use ONCS_Header qw(:Constants);
use ONCS_specific;
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use Edit_Screens;
use CGI qw(param);
use Tie::IxHash;
use Sections;
use DBI;
use DBD::Oracle qw(:ora_types);

$| = 1;
my $oncscgi = new CGI;
my $userid = $oncscgi->param("loginusersid");
my $username = $oncscgi->param("loginusername");
$SCHEMA = (defined ($oncscgi->param("schema"))) ? $oncscgi->param("schema") : $SCHEMA;
my $cgiaction = (defined($oncscgi -> param ('cgiaction'))) ? ($oncscgi -> param ('cgiaction')) : "anything";

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $errorstr = "";

my $dateFormat = 'DD-MON-YYYY HH24:MI:SS';
my $process = $oncscgi->param("process");
my %counts;
my $statusid;
my $pageNum = 1;

tie my %sections, "Tie::IxHash"; 
%sections = (
    'issue_entry' => {
	'role' => [1, 2, 3, 4, 5, 6], 
	'enabled' => 1, 
	'all' => 1,
	'defaultOpen' => 1, 
	'title' => 'Issue Entry' 
    },
    'cc_review' => {
	'role' => [1, 6], 
	'enabled' => 1, 
	'all' => 0,
	'defaultOpen' => 0, 
	'title' => 'Commitment Coordinator Issue Review'
    },
    'action_entry' => {
        'role' => [1, 6],
        'enabled' => 1,
        'all' => 0,
        'defaultOpen' => 0,
        'title' => 'Commitment Coordinator Action Entry'
    },
    'mo_tl_estimate' => {
	'role' => [2, 6], 
	'enabled' => 1, 
	'all' => 0,
	'defaultOpen' => 0, 
	'title' => 'BSC Discipline Lead Estimate'
    },
    'doe_tl_det' => {
	'role' => [3, 6], 
	'enabled' => 1, 
	'all' => 0,
	'defaultOpen' => 0, 
	'title' => 'DOE Discipline Lead Determination'
    },
    'doe_cm_det' => {
	'role' => [4, 6], 
	'enabled' => 1, 
	'all' => 0,
	'defaultOpen' => 0, 
	'title' => 'DOE Commitment Manager Determination'
    },
    'comm_mkr_decision' => {
	'role' => [5, 6], 
	'enabled' => 1, 
	'all' => 0,
	'defaultOpen' => 0, 
	'title' => 'Commitment Maker Decision'
    },
    'doe_cm_first_response' => {
	'role' => [4, 6], 
	'enabled' => 1, 
	'all' => 0,
	'defaultOpen' => 0, 
	'title' => 'DOE Commitment Manager First Response'
    },
    'action_fulfil' => {
        'role' => [2, 6],
        'enabled' => 1,
        'all' => 0,
        'defaultOpen' => 0,
        'title' => 'BSC Discipline Lead Action Fulfillment'
    },
    'action_fulfil_review' => {
        'role' => [7, 6],
        'enabled' => 1,
        'all' => 0,
        'defaultOpen' => 0,
        'title' => 'BSC Licensing Lead Action Fulfillment Review'
    },
    'mo_tl_fulfil' => {
	'role' => [2, 6], 
	'enabled' => 1, 
	'all' => 0,
	'defaultOpen' => 0, 
	'title' => 'BSC Discipline Lead Commitment Fulfillment'
    },
    'doe_tl_fulfil_review' => {
	'role' => [3, 6], 
	'enabled' => 1, 
	'all' => 0,
	'defaultOpen' => 0, 
	'title' => 'DOE Discipline Lead Commitment Fulfillment Review'
    },
    'doe_cmgr_closure_review' => {
	'role' => [4, 6], 
	'enabled' => 1, 
	'all' => 0,
	'defaultOpen' => 0, 
	'title' => 'DOE Commitment Manager Closure Review'
    },
    'cm_closure_review' => {
	'role' => [5, 6], 
	'enabled' => 1, 
	'all' => 0,
	'defaultOpen' => 0, 
	'title' => 'Commitment Maker Closure Review'
    },
    'doe_cmgr_final_resp' => {
	'role' => [4, 6], 
	'enabled' => 1, 
	'all' => 0,
	'defaultOpen' => 0, 
	'title' => 'DOE Commitment Manager Final Response'
    }
);

# tell the browser that this is an html page using the header method
print $oncscgi->header('text/html');

my $dbh = oncs_connect();

if ((!defined($userid)) || ($userid eq "") || (!defined($username)) || ($username eq "")){
    print "    <script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "    <!--\n";
    print "    parent.location='$ONCSCGIDir/login.pl';\n";
    print "    //-->\n";
    print "    </script>\n";
    exit 1;
}
print <<pageheader;
<html>
<head>
<meta name="pragma" content="no-cache">
<meta name="expires" content="0">
<meta http-equiv="expires" content="0">
<meta http-equiv="pragma" content="no-cache">
<title>Commitment Module Home Page</title>
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>
<script language="JavaScript" type="text/javascript">
<!--
doSetTextImageLabel('Home');
//-->
</script>
<script language=javascript><!--
function submitForm (script, command, id) {
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'workspace';
    document.$form.submit();
}
function ccreview (id, command) {                          //2without
    document.$form.issueid.value=id;
    submitForm('MOCC_review', command, id);
}
function ccreviewwithcommit (id, command) {                //2with
    document.$form.committedissueselect.value=id;
    document.$form.issueid.value=id;
    submitForm('MOCC_review', command, id);
}
function submitcommitment (id, command, script) {
    document.$form.commitmentid.value=id;
    submitForm(script, command, id);
}
function submitaction (cid, aid, command, script) {
    document.$form.commitmentid.value=cid;
    document.$form.actionid.value=aid;
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'workspace';
    document.$form.submit();
}
function closeissue (id) {
    document.$form.issueid.value=id;
    submitForm('home', 'closeissue', id);
}
function closecommitment (id) {
    document.$form.commitmentid.value=id;
    submitForm('home', 'closecommitment', id);
}
function issue (id) {
    var temptarget = document.$form.target;
    var tempaction = document.$form.action;
    var script = 'browse';
    window.open ("", "issuewin", "height=350, width=750, status=no, scrollbars=yes");
    document.$form.target = 'issuewin';
    document.$form.action = '$path' + script + '.pl';
    document.$form.option.value = 'details';
    document.$form.theinterface.value = 'issues';
    document.$form.interfaceLevel.value = 'issueid';
    document.$form.id.value = id;
    document.$form.submit();
    document.$form.target = temptarget;
    document.$form.action = tempaction;
}
function commitment (id) {
    var temptarget = document.$form.target;
    var tempaction = document.$form.action;
    var script = 'browse';
    window.open ("", "issuewin", "height=350, width=750, status=no, toolbar=yes, scrollbars=yes");
    document.$form.target = 'issuewin';
    document.$form.action = '$path' + script + '.pl';
    document.$form.option.value = 'details';
    document.$form.theinterface.value = 'commitments';
    document.$form.interfaceLevel.value = 'commitmentid';
    document.$form.id.value = id;
    document.$form.submit();
    document.$form.target = temptarget;
    document.$form.action = tempaction;
}
function viewaction (id) {
    var temptarget = document.$form.target;
    var tempaction = document.$form.action;
    var script = 'browse'; 
    window.open ("", "issuewin", "height=350, width=750, status=no, toolbar=yes, scrollbars=yes");
    document.$form.target = 'issuewin';
    document.$form.action = '$path' + script + '.pl';
    document.$form.cgiaction.value = 'viewactions';
    document.$form.commitmentid.value = id;
    document.$form.submit();
    document.$form.target = temptarget;
    document.$form.action = tempaction;
}
//-->
</script>
pageheader
print &sectionHeadTags($form);
print "</head>\n\n";

my ($siteid) = $dbh -> selectrow_array ("select siteid from $SCHEMA.users where usersid = $userid");

# Build a list of disciplines in which the user specializes
###########################################################
my $disclist = "";
if (does_user_have_role (dbh => $dbh, uid => $userid, rid => 6)) {
    $disclist = "(";
    my $alldisc = $dbh->prepare("select disciplineid from $SCHEMA.discipline");
    $alldisc -> execute;
    while (my ($did) = $alldisc -> fetchrow_array) {
	$disclist .= "$did, ";
    }
    chop ($disclist);
    chop ($disclist);
    $disclist .= ")";
    $alldisc -> finish;
}
else {
    my $userdiscroles = "select distinct disciplineid from $SCHEMA.defaultdisciplinerole where usersid=$userid";
    my $csrdisc = $dbh -> prepare ($userdiscroles);
    $csrdisc -> execute;
    my @disciplines;
    my $k = 0;
    while (my @vals = $csrdisc -> fetchrow_array) {
	($disciplines[$k]) = @vals;
	$k++;
    }
    $disclist .= "(";
    if ($k>0) {
	my $j;
	for ($j=0; $j<$k; $j++) {
	    $disclist .= "$disciplines[$j], ";
	}
	chop ($disclist);
	chop ($disclist);
    }
    $disclist .= ")";
    if ($disclist eq "()"){
	$disclist = "(1000)";
    }
    $csrdisc -> finish;
}

# Setup check for issues with and without commitments
#####################################################
my $withcomm = "select distinct issueid from $SCHEMA.commitment where siteid=$siteid";
my $csrwithcomm = $dbh -> prepare ($withcomm);
$csrwithcomm -> execute;
my @issues;
my $i=0;
while (my @val = $csrwithcomm -> fetchrow_array){
    ($issues[$i]) = @val;
    $i++;
}
my $list .= "(";
if ($i>0) {
    my $j;
    for ($j=0; $j<$i; $j++){
	$list .= "$issues[$j], ";
    }
    chop ($list);
    chop ($list);
}
$list .= ")";
$csrwithcomm -> finish;

##################
sub processError {
##################
    my %args = (
		@_,
		);
    my $error = &errorMessage($dbh, $username, $userid, $SCHEMA, $args{activity}, $@);
    $error =  ('_' x 100) . "\n\n" . $error if ($errorstr ne "");
    $error =~ s/\n/\\n/g;
    $error =~ s/'/%27/g;
    $errorstr .= $error;
}

##############
sub formatID {
##############
    return (sprintf("$_[0]%0$_[1]d", $_[2]));
}

##############
sub getCount {
##############
    my @row = $dbh->selectrow_array ("select count(*) from $_[0] where $_[1]");
    return ($row[0]);
}

################
sub printCount {
################
    print "<td bgcolor=#f3f3f3 align=center width=160><font face=arial color=#000060 size=-1><b>$_[0]</b></font></td>\n";
}

##############
sub doHeader {
##############
    my $section = $_[0];
    print "<tr><td><table width=100% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellspacing=0 cellpadding=0><tr>\n";
    print "<td align=center bgcolor=#f3f3f3 width=22>" . &sectionImageTag($section, $CMSImagesDir) . "</td>\n";
    print "<td height=23 bgcolor=#f3f3f3><font face=arial color='#000060'><b>&nbsp;&nbsp;${$sections{$section}}{'title'}" . "</b></font></td>\n";
    
    eval{
        ####  2  ####################
	if ($section eq 'cc_review'){  
	    if ($list ne "()"){
		$counts{nocommitments} = &getCount("$SCHEMA.issue", "siteid=$siteid and issueid not in $list and isclosed='F'");
		$counts{commitments} = &getCount ("$SCHEMA.issue", "siteid=$siteid and issueid in $list and isclosed='F'");
	    }
	    else {
		$counts{nocommitments} = &getCount ("$SCHEMA.issue", "siteid=$siteid and isclosed='F'"); 
		$counts{commitments} = 0;
	    }
	    if (!sectionIsOpen($section)){
		printCount("$counts{nocommitments} w/o commitments");
		printCount("$counts{commitments} w/ commitments");
	    }
	}
        ####  2a  ##########################
	elsif ($section eq 'action_entry') {
	    $counts{newact} = &getCount("$SCHEMA.commitment", "statusid=17 and isclosed='F'");
	    if (!sectionIsOpen($section)) {
		printCount("$counts{newact} open for action entry");
	    }
	}
	####  3  ############################
	elsif ($section eq 'mo_tl_estimate'){  
	    $statusid = 2; # MODL Estimate
	    $counts{newmotle} = &getCount("$SCHEMA.commitment", "statusid=$statusid and siteid=$siteid and lleadid=$userid"); 
	    if (!sectionIsOpen($section)){
		printCount("$counts{newmotle} to process");
	    }
	}
	####  4  ########################
	elsif ($section eq 'doe_tl_det'){
	    $statusid = 3; # DOEDL Review
	    $counts{newdoetld} = &getCount("$SCHEMA.commitment", "statusid=$statusid and siteid=$siteid and primarydiscipline in $disclist"); 
	    if (!sectionIsOpen($section)){
		printCount("$counts{newdoetld} to process");
	    }
	}
	####  5  ########################
	elsif ($section eq 'doe_cm_det'){
	    $statusid = 4; # DOECMgr Review
	    $counts{newdoecmd} = &getCount("$SCHEMA.commitment", "statusid=$statusid and siteid=$siteid");
	    if (!sectionIsOpen($section)){
		printCount("$counts{newdoecmd} to process");
	    }
	}
	####  6  ###############################
	elsif ($section eq 'comm_mkr_decision'){
	    $statusid = 5; # CMaker Review
	    $counts{newcmd} = &getCount("$SCHEMA.commitment", "statusid=$statusid and siteid=$siteid and approver=$userid");
	    if (!sectionIsOpen($section)){
		printCount("$counts{newcmd} to process");
	    }
	}
	####  7  ###################################
	elsif ($section eq 'doe_cm_first_response'){
	    $statusid = 6; # Approval Letter
	    $counts{approvedfirst} = &getCount("$SCHEMA.commitment", "statusid=$statusid and siteid=$siteid");
	    $statusid = 7; # Disapproval Letter
	    $counts{rejectedfirst} = &getCount("$SCHEMA.commitment", "statusid=$statusid and siteid=$siteid");
	    if (!sectionIsOpen($section)){
		printCount("$counts{approvedfirst} approved");
		printCount("$counts{rejectedfirst} rejected");
	    }
	}
        #### 7a #############################
	elsif ($section eq 'action_fulfil') {
	    $statusid = 18; # Action fulfillment (DL)
	    $counts{actful} = &getCount("$SCHEMA.action a, $SCHEMA.commitment c", "c.statusid=$statusid and c.siteid=$siteid and a.dleadid=$userid and a.status='OO' and c.commitmentid=a.commitmentid");
	    $counts{actrework} = &getCount("$SCHEMA.action a, $SCHEMA.commitment c", "c.statusid=$statusid and c.siteid=$siteid and a.dleadid=$userid and a.status='RO' and c.commitmentid=a.commitmentid");
	    if (!sectionIsOpen($section)) {
		printCount("$counts{actful} pending");
		printCount("$counts{actrework} to rework");
	    }
	}
	####  7b  ##################################
	elsif ($section eq 'action_fulfil_review') {
	    $statusid = 18; # Action fulfillment (DL)
	    $counts{actreview} = &getCount("$SCHEMA.action a, $SCHEMA.commitment c", "c.statusid=$statusid and c.siteid=$siteid and a.lleadid=$userid and a.status='FO' and c.commitmentid=a.commitmentid");
	    if (!sectionIsOpen($section)) {
		printCount("$counts{actreview} pending");
	    }
	}
	####  8  ##########################
	elsif ($section eq 'mo_tl_fulfil'){
	    $statusid = 9; # Pending
	    $counts{pendingfulfil} = &getCount("$SCHEMA.commitment", "statusid=$statusid and siteid=$siteid and lleadid=$userid"); #primarydiscipline in $disclist");
	    $statusid = 10; # Rework
	    $counts{reworkfulfil} = &getCount("$SCHEMA.commitment", "statusid=$statusid and siteid=$siteid and lleadid=$userid"); #primarydiscipline in $disclist");
	    $statusid = 18; #pending actions
	    $counts{pendact} = &getCount ("$SCHEMA.commitment", "statusid=$statusid and siteid=$siteid and lleadid=$userid");
	    if (!sectionIsOpen($section)){
		printCount ("$counts{pendingfulfil} pending");
		printCount ("$counts{reworkfulfil} to rework");
#		printCount ("$counts{pendact} w/ pending actions");
	    }
	}
	####  9  ##################################
	elsif ($section eq 'doe_tl_fulfil_review'){
	    $statusid = 11; # DOEDL Fulfillment Review
	    $counts{newdoetlfulrev} = &getCount("$SCHEMA.commitment", "statusid=$statusid and siteid=$siteid and primarydiscipline in $disclist");
	    $counts{returneddoetlfulrev} = &getCount("$SCHEMA.commitment", "statusid=12 and siteid=$siteid and primarydiscipline in $disclist");
	    if (!sectionIsOpen($section)){
		printCount("$counts{newdoetlfulrev} to process");
		printCount("$counts{returneddoetlfulrev} to revise");
	    }
	}
	####  10  ####################################
	elsif ($section eq 'doe_cmgr_closure_review'){
	    $statusid = 13; # DOECMgr Closure Review
	    $counts{newdoeclosure} = &getCount("$SCHEMA.commitment", "statusid=$statusid and siteid=$siteid");
	    if (!sectionIsOpen($section)){
		printCount("$counts{newdoeclosure} to process");
	    }
	}
	####  11  ##############################
	elsif ($section eq 'cm_closure_review'){
	    $statusid = 14; # CMaker Closure Review
	    $counts{newcmclosure} = &getCount("$SCHEMA.commitment", "statusid=$statusid and siteid=$siteid and approver=$userid");
	    if (!sectionIsOpen($section)){
		printCount("$counts{newcmclosure} to process");
	    }
	}
	####  12  ################################
	elsif ($section eq 'doe_cmgr_final_resp'){
	    $statusid = 15; # Closure Letter
	    $counts{newfinal} = &getCount("$SCHEMA.commitment", "statusid=$statusid and siteid=$siteid");
	    if (!sectionIsOpen($section)){
		printCount("$counts{newfinal} to process");
	    }
	}
    };
    &processError(activity => "display $section header") if ($@);
    print "</tr></table>\n</td></tr>\n";
    print "<tr><td height=15> </td></tr>\n";
}

###############
sub writeBody {
###############
    print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n<center>\n";
    print "<form name=$form method=post>\n";
    print "<input type=hidden name=loginusername value=$username>\n";
    print "<input type=hidden name=loginusersid value=$userid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    print "<input type=hidden name=cgiaction value=0>\n";
    print "<input type=hidden name=actionid value=0>\n";
    print "<input type=hidden name=commitmentid value=0>\n";
    print "<input type=hidden name=issueid value=0>\n";
    print "<input type=hidden name=committedissueselect value=0>\n";
    print "<input type=hidden name=option value=>\n";
    print "<input type=hidden name=theinterface value=>\n";
    print "<input type=hidden name=interfaceLevel value=>\n";
    print "<input type=hidden name=id value=>\n";
    print &sectionBodyTags;
    print "<table width=775 cellpadding=0 cellspacing=0 border=0>\n";
    print "<tr><td height=15> </td></tr>\n";
    foreach my $section (keys (%sections)) {
	if (&sectionIsActive($section)) {
	    doHeader($section);
            doSection($section) if &sectionIsOpen ($section);
	}
    }
    print "</table>\n</form>\n</center>\n</font>\n\n";
    print "<script language=javascript><!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n" if ($errorstr);
    print "<br><br><br><br>\n</body>\n</html>\n";
}

###################
sub doTableHeader {
###################
    my %args = (
	        status => 0,
                @_,
		);
    my $outstring .= &add_header_row();
    $outstring .= &add_col() . 'ID';
    if ($args{status} > 5 && $args{status} < 15) {
	$outstring .= &add_col().'Commit&nbsp;Date';
    }
    elsif ($args{status} > 14) {
	$outstring .= &add_col().'Close&nbsp;Date';
    }
    else {
	$outstring .= &add_col() . 'Due&nbsp;Date';
    }
    $outstring .= &add_col() . 'Discipline';
    $outstring .= &add_col() . 'Commitment&nbsp;Text';
    $outstring .= &add_col() . 'Issue&nbsp;ID';
    return ($outstring);
}

################
sub doTableBody{
################
    my %args = (
	     @_,
	     );
    my $outstring .= &add_row();
    $outstring .= &add_col_link("javascript:submitcommitment($args{cid},'editcommitment','$args{script}')") . "C" . substr("0000$args{cid}",-5);
    $outstring .= &add_col() . $args{date};
    $outstring .= &add_col() . $args{discipline};
    $outstring .= &add_col() . &getDisplayString ($args{text}, 70);
    $outstring .= &add_col_link("javascript:issue($args{iid})") . "I" . substr("0000$args{iid}",-5);
    return ($outstring);
}

###############
sub doSection {
###############
    my $entryBackground = '#ffc0ff';
    my $entryForeground = '#000099';
    my $section = $_[0];
    eval {
	####  1  #######################
	if ($section eq 'issue_entry') {  
	    print "<tr><td align=right>\n";
	    print "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    print "<tr><td><b><li><a href=\"$ONCSCGIDir/newissue.pl?loginusersid=$userid&loginusername=$username&schema=$SCHEMA\">Enter</a>" . &nbspaces(2) . "New Issue</b></td></tr>\n";
	    print "</ul></table>\n</td></tr>\n<tr><td height=30> </td></tr>\n";
	}
	####  2  #######################
	elsif ($section eq 'cc_review'){
	    my $iwc;
	    if ("$list" ne "()") {
		$iwc = "select i.issueid, to_char(i.dateoccurred, 'MM/DD/YYYY'), c.description, i.text from $SCHEMA.issue i, $SCHEMA.category c where i.categoryid=c.categoryid and i.siteid=$siteid and (i.issueid not in $list) and isclosed='F' order by i.issueid desc";
	    }
	    else {
		$iwc = "select i.issueid, i.dateoccurred, c.description, i.text from $SCHEMA.issue i, $SCHEMA.category c where i.categoryid=c.categoryid and i.siteid=$siteid and isclosed='F' order by issueid"; 
	    }
	    my $csr = $dbh -> prepare ($iwc);
	    $csr -> execute;
	    my $output .= "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 46, 72, 130, 465, 35);
	    $output .= &title_row("$entryBackground", "$entryForeground", "<font>Issues without commitments ($counts{nocommitments}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view issue and enter commitment</i></font>)");
	    $output .= &add_header_row();
	    $output .= &add_col() . 'Issue ID';
	    $output .= &add_col() . 'Date Occurred';
	    $output .= &add_col() . 'Category';
	    $output .= &add_col() . 'Text';
	    $output .= &add_col() . 'Close';
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($iid, $date, $category, $text) = @values;
		$output .= &add_row();
		$output .= &add_col_link("javascript:ccreview($iid,'createcommitment')") . "I" . substr("0000$iid",-5);
		$output .= &add_col() . $date;
		$output .= &add_col() . $category;
		$output .= &add_col() . &getDisplayString ($text, 70);
		$output .= &add_col_link("javascript:closeissue($iid)") . 'close';
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);
	    #############################
	    my $csr2;
	    if ("$list" ne "()"){
		$csr2 = $dbh -> prepare ("select i.issueid, to_char(i.dateoccurred, 'MM/DD/YYYY'), c.description, i.text from $SCHEMA.issue i, $SCHEMA.category c where i.categoryid=c.categoryid and i.siteid=$siteid and i.issueid in $list and isclosed='F' order by i.issueid desc");
		$csr2 -> execute;
		my $output2 .= "<tr><td align=right>\n";
		$output2 .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
		$output2 .= &start_table(6, 'center', 46, 72, 130, 415, 55, 35);
		$output2 .= &title_row("$entryBackground", "$entryForeground", "<font>Issues with commitments ($counts{commitments}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view issue and its commitments<i></font>)");
		$output2 .= &add_header_row();
		$output2 .= &add_col() . 'Issue ID';
		$output2 .= &add_col() . 'Date Occurred';
		$output2 .= &add_col() . 'Category';
		$output2 .= &add_col() . 'Text';
		$output2 .= &add_col() . 'Commitments<br>in Review';
		$output2 .= &add_col() . 'Close';
		my $rows2 =0;
		while (my @values = $csr2 -> fetchrow_array){
		    $rows2++;
		    my ($iid, $date, $category, $text) = @values;
		    my $nocomm = &getCount("$SCHEMA.commitment", "issueid=$iid and statusid=1 and siteid=$siteid");
		    $output2 .= &add_row();
		    $output2 .= &add_col_link("javascript:ccreviewwithcommit($iid,'query_issue')") . "I" . substr("0000$iid",-5);
		    $output2 .= &add_col() . $date;
		    $output2 .= &add_col() . $category;
		    $output2 .= &add_col() . &getDisplayString ($text, 60);
		    $output2 .= &add_col() . $nocomm;
		    if ($nocomm == 0) {
			$output2 .= &add_col_link("javascript:closeissue($iid)") . 'close';
		    }
		    else {
			$output2 .= &add_col() . '&nbsp';
		    }
		}
		
		$csr2 -> finish;
		$output2 .= &end_table();
		$output2 .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
		print $output2 if ($rows2 > 0);
	    }
	}
        ####  2a  ##########################
	elsif ($section eq 'action_entry') {
	    my $csr = $dbh -> prepare ("select commitmentid, to_char(duedate, 'MM/DD/YYYY'), text, issueid from $SCHEMA.commitment where statusid=17 and isclosed='F' order by commitmentid desc");
	    $csr -> execute;
	    my $output .= "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(6, 'center', 50, 70, 400, 50, 50, 80);
	    $output .= &title_row("$entryBackground", "$entryForeground", "<font>Commitments open for action entry ($counts{newact}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view commitment and enter action<i></font>)");
	    $output .= &add_header_row();
	    $output .= &add_col() . 'ID';
	    $output .= &add_col() . 'Due Date';
	    $output .= &add_col() . 'Text';
	    $output .= &add_col() . 'Actions';
	    $output .= &add_col() . 'Issue ID';
	    $output .= &add_col() . 'Action Entry';
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $date, $text, $iid) = @values;
		my ($noacts) = $dbh -> selectrow_array ("select count (*) from $SCHEMA.action where commitmentid = $cid");
		$output .= &add_row();
		$output .= &add_col_link("javascript:submitcommitment($cid,'createaction','CC_actionentry')") . "C" . substr("0000$cid",-5);
		$output .= &add_col() . $date;
		$output .= &add_col() . &getDisplayString ($text, 65);
		$output .= &add_col() . $noacts;
		$output .= &add_col_link("javascript:issue($iid)") . "I" . substr("0000$iid",-5);
		$output .= &add_col_link("javascript:closecommitment($cid)") . 'completed';
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);
	}
	####  3  ############################
	elsif ($section eq 'mo_tl_estimate'){
	    $statusid = 2; # M&O Estimate
	    my $csr = $dbh -> prepare ("select c.commitmentid, to_char(c.duedate, 'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.statusid=$statusid and c.lleadid=$userid and c.primarydiscipline=d.disciplineid order by c.commitmentid");
	    $csr -> execute;
	    my $output .= "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 40, 74, 95, 450, 41);
	    $output .= &title_row("#c0c0ff", "$entryForeground", "<font>Commitments to evaluate ($counts{newmotle}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view commitment<i></font>)");
	    $output .= &doTableHeader(status => $statusid);
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $date, $discipline, $text, $iid) = @values;
		$output .= &doTableBody(cid => $cid, date => $date, discipline => $discipline, text => $text, iid => $iid, script => 'MOFL_estimate');
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);
	}
	####  4  ########################
	elsif ($section eq 'doe_tl_det'){
	    $statusid = 3; # DOEDL Review
	    my $csr = $dbh -> prepare ("select c.commitmentid, to_char(c.duedate,'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.primarydiscipline=d.disciplineid and c.statusid=$statusid and c.siteid=$siteid and c.primarydiscipline in $disclist order by c.commitmentid");
	    $csr -> execute;
	    my $output .= "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 40, 74, 95, 450, 41);
	    $output .= &title_row("#c0c0ff", "$entryForeground", "<font>Commitments to review for determination ($counts{newdoetld}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view commitment<i></font>)");
	    $output .= &doTableHeader(status => $statusid);
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $date, $discipline, $text, $iid) = @values;
		$output .= &doTableBody(cid => $cid, date => $date, discipline => $discipline, text => $text, iid => $iid, script => 'DOEFL_determination');
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);
	}
	####  5  ########################
	elsif ($section eq 'doe_cm_det'){
	    $statusid = 4; # DOECMgr Review
	    my $csr = $dbh -> prepare ("select c.commitmentid, to_char(c.duedate,'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.primarydiscipline=d.disciplineid and c.statusid=$statusid and c.siteid=$siteid order by c.commitmentid");
	    $csr -> execute;
	    my $output .= "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 40, 74, 95, 450, 41);
	    $output .= &title_row("#ffffc0", "$entryForeground", "<font>Commitments to review ($counts{newdoecmd}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to review commitment<i></font>)");
	    $output .= &doTableHeader(status => $statusid);
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $date, $discipline, $text, $iid) = @values;
		$output .= &doTableBody(cid => $cid, date => $date, discipline => $discipline, text => $text, iid => $iid, script => 'DOECMgr_determination');
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);
	}
	####  6  ###############################
	elsif ($section eq 'comm_mkr_decision'){
	    $statusid = 5; # CMaker Review
	    my $csr = $dbh -> prepare ("select c.commitmentid, to_char(c.duedate,'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.primarydiscipline=d.disciplineid and c.statusid=$statusid and c.siteid=$siteid and c.approver=$userid order by c.commitmentid");
	    $csr -> execute;
	    my $output .= "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 40, 74, 95, 450, 41);
	    $output .= &title_row("#c0ffc0", "$entryForeground", "<font>Commitments to review ($counts{newcmd}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to review commitment<i></font>)");
	    $output .= &doTableHeader(status => $statusid);
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $date, $discipline, $text, $iid) = @values;
		$output .= &doTableBody(cid => $cid, date => $date, discipline => $discipline, text => $text, iid => $iid, script => 'CMaker_decision');
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);
	}
	####  7  ###################################
	elsif ($section eq 'doe_cm_first_response'){
	    $statusid = 6; # Approval Letter
	    my $csr = $dbh -> prepare ("select c.commitmentid, to_char(c.commitdate,'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.primarydiscipline=d.disciplineid and c.statusid=$statusid and c.siteid=$siteid order by c.commitmentid");
	    $csr -> execute;
	    my $output .= "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 40, 74, 95, 450, 41);
	    $output .= &title_row("#ffffc0", "$entryForeground", "<font>Commitments approved by Commitment Maker ($counts{approvedfirst}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view commitment<i></font>)");
	    $output .= &doTableHeader(status => $statusid);
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $date, $discipline, $text, $iid) = @values;
		$output .= &doTableBody(cid => $cid, date => $date, discipline => $discipline, text => $text, iid => $iid, script => 'DOECMgr_firstresponse');
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);
	    
	    $statusid = 7; # Disapproval Letter
	    my $csr2 = $dbh -> prepare ("select c.commitmentid, to_char(c.commitdate,'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.primarydiscipline=d.disciplineid and c.statusid=$statusid and c.siteid=$siteid order by c.commitmentid");
	    $csr2 -> execute;
	    my $output2 .= "<tr><td align=right>\n";
	    $output2 .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output2 .= &start_table(5, 'center', 40, 74, 95, 450, 41);
	    $output2 .= &title_row("#ffffc0", "$entryForeground", "<font>Commitments rejected by Commitment Maker ($counts{rejectedfirst}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view commitment<i></font>)");
	    $output2 .= &doTableHeader(status => $statusid);
	    my $rows2 = 0;
	    while (my @values2 = $csr2 -> fetchrow_array){
		$rows2++;
		my ($cid, $date, $discipline, $text, $iid) = @values2;
		$output2 .= &doTableBody(cid => $cid, date => $date, discipline => $discipline, text => $text, iid => $iid, script => 'DOECMgr_firstresponse');
	    }
	    $csr2 -> finish;
	    $output2 .= &end_table();	    
	    $output2 .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output2 if ($rows2 > 0);
	}
        ####  7a  ###########################
	elsif ($section eq 'action_fulfil') {
	    $statusid = 18;
	    my $csr = $dbh -> prepare ("select a.commitmentid, a.actionid, a.text, to_char(a.duedate,'MM/DD/YYYY'), c.issueid from $SCHEMA.action a, $SCHEMA.commitment c where c.statusid=$statusid and a.status='OO' and a.dleadid=$userid and a.commitmentid=c.commitmentid order by c.commitmentid");
	    $csr -> execute;
	    my $output = "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 70, 74, 515, 50, 41);
	    $output .= &title_row("#fabaaa", "$entryForeground", "<font>Pending actions ($counts{actful}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view action<i></font>)");
	    $output .= &add_header_row();
	    $output .= &add_col() . 'ID';
	    $output .= &add_col() . 'Due&nbsp;Date';
	    $output .= &add_col() . 'Action Text';
	    $output .= &add_col() . 'Commitment&nbsp;ID';
	    $output .= &add_col() . 'Issue&nbsp;ID';
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $aid, $text, $date, $iid) = @values;
		$output .= &add_row();
		$output .= &add_col_link("javascript:submitaction($cid,$aid,'fulfillment','MO_action_fulfillment')") . "CA" . substr("0000$cid",-5) . "/" . substr("00$aid",-3);
		$output .= &add_col() . $date;
		$output .= &add_col() . &getDisplayString ($text, 70);
		$output .= &add_col_link("javascript:commitment($cid)") . "C" . substr("0000$cid",-5);
		$output .= &add_col_link("javascript:issue($iid)") . "I" . substr("0000$iid",-5);
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);	    

	    $csr = $dbh -> prepare ("select a.commitmentid, a.actionid, a.text, to_char(a.duedate,'MM/DD/YYYY'), c.issueid from $SCHEMA.action a, $SCHEMA.commitment c where c.statusid=$statusid and a.status='RO' and a.dleadid=$userid and a.commitmentid=c.commitmentid order by c.commitmentid");
	    $csr -> execute;
	    $output = "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 70, 74, 515, 50, 41);
	    $output .= &title_row("#fabaaa", "$entryForeground", "<font>Actions to rework ($counts{actrework}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view action<i></font>)");
	    $output .= &add_header_row();
	    $output .= &add_col() . 'ID';
	    $output .= &add_col() . 'Due&nbsp;Date';
	    $output .= &add_col() . 'Action Text';
	    $output .= &add_col() . 'Commitment&nbsp;ID';
	    $output .= &add_col() . 'Issue&nbsp;ID';
	    $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $aid, $text, $date, $iid) = @values;
		$output .= &add_row();
		$output .= &add_col_link("javascript:submitaction($cid,$aid,'fulfillment','MO_action_fulfillment')") . "CA" . substr("0000$cid",-5) . "/" . substr("00$aid",-3);
		$output .= &add_col() . $date;
		$output .= &add_col() . &getDisplayString ($text, 70);
		$output .= &add_col_link("javascript:commitment($cid)") . "C" . substr("0000$cid",-5);
		$output .= &add_col_link("javascript:issue($iid)") . "I" . substr("0000$iid",-5);
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);	    
	}
        ####  7b  ################################## 
	elsif ($section eq 'action_fulfil_review') {
	    $statusid = 18;
	    my $csr = $dbh -> prepare ("select a.commitmentid, a.actionid, a.text, to_char(a.duedate,'MM/DD/YYYY'), c.issueid from $SCHEMA.action a, $SCHEMA.commitment c where c.statusid=$statusid and a.status='FO' and a.lleadid=$userid and a.commitmentid=c.commitmentid order by c.commitmentid");
	    $csr -> execute;
	    my $output .= "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 70, 74, 515, 50, 41);
	    $output .= &title_row("#fabaaa  ", "$entryForeground", "<font>Pending Actions ($counts{actreview}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view action<i></font>)");
	    $output .= &add_header_row();
	    $output .= &add_col() . 'ID';
	    $output .= &add_col() . 'Due&nbsp;Date';
	    $output .= &add_col() . 'Action Text';
	    $output .= &add_col() . 'Commitment&nbsp;ID';
	    $output .= &add_col() . 'Issue&nbsp;ID';
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $aid, $text, $date, $iid) = @values;
		$output .= &add_row();
		$output .= &add_col_link("javascript:submitaction($cid,$aid,'review','LL_action_review')") . "CA" . substr("0000$cid",-5) . "/" . substr("00$aid",-3);
		$output .= &add_col() . $date;
		$output .= &add_col() . &getDisplayString ($text, 70);
		$output .= &add_col_link("javascript:commitment($cid)") . "C" . substr("0000$cid",-5);
		$output .= &add_col_link("javascript:issue($iid)") . "I" . substr("0000$iid",-5);
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);	    
	}
	####  8  ##########################
	elsif ($section eq 'mo_tl_fulfil'){
	    $statusid = 9; # Pending
	    my $csr = $dbh -> prepare ("select c.commitmentid, to_char(c.commitdate,'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.primarydiscipline=d.disciplineid and c.statusid=$statusid and c.siteid=$siteid and c.lleadid=$userid order by c.commitmentid");#primarydiscipline in $disclist order by c.commitmentid");
	    $csr -> execute;
	    my $output .= "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 40, 74, 95, 450, 41);
	    $output .= &title_row("c0c0ff", "$entryForeground", "<font>Commitments to review ($counts{pendingfulfil}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to review commitment<i></font>)");
	    $output .= &doTableHeader(status => $statusid);
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $date, $discipline, $text, $iid) = @values;
		$output .= &doTableBody(cid => $cid, date => $date, discipline => $discipline, text => $text, iid => $iid, script => 'MOFL_fulfillment');
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);
	    
	    $statusid = 10; # Rework
	    my $csr2 = $dbh -> prepare ("select c.commitmentid, to_char(c.commitdate,'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.primarydiscipline=d.disciplineid and c.statusid=$statusid and c.siteid=$siteid and c.lleadid=$userid order by c.commitmentid"); #primarydiscipline in $disclist order by c.commitmentid");
	    $csr2 -> execute;
	    my $output2 .= "<tr><td align=right>\n";
	    $output2 .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output2 .= &start_table(5, 'center', 40, 74, 95, 450, 41);
	    $output2 .= &title_row("#c0c0ff", "$entryForeground", "<font>Commitments to rework ($counts{reworkfulfil}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view commitment<i></font>)");
	    $output2 .= &doTableHeader(status => $statusid);
	    my $rows2 =0;
	    while (my @values2 = $csr2 -> fetchrow_array){
		$rows2++;
		my ($cid, $date, $discipline, $text, $iid) = @values2;
		$output2 .= &doTableBody(cid => $cid, date => $date, discipline => $discipline, text => $text, iid => $iid, script => 'MOFL_fulfillment');
	    }
	    $csr2 -> finish;
	    $output2 .= &end_table();
	    $output2 .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output2 if ($rows2 > 0);
####
	    $statusid = 18;
	    $csr = $dbh -> prepare ("select c.commitmentid, to_char(c.commitdate,'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.primarydiscipline=d.disciplineid and c.statusid=$statusid and c.siteid=$siteid and c.lleadid=$userid order by c.commitmentid");
	    $csr -> execute;
	    $output = "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(6, 'center', 40, 74, 95, 400, 50, 41);
	    $output .= &title_row("#fabaaa  ", "$entryForeground", "<font>Commitments with pending actions ($counts{pendact}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view action<i></font>)");
	    $output .= &add_header_row();
	    $output .= &add_col() . 'ID';
	    $output .= &add_col() . 'Due&nbsp;Date';
	    $output .= &add_col() . 'Discipline';
	    $output .= &add_col() . 'Text';
	    $output .= &add_col() . 'Actions';
	    $output .= &add_col() . 'Issue&nbsp;ID';
	    $rows = 0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $date, $disc, $text, $iid) = @values;
		$output .= &add_row();
		$output .= &add_col_link("javascript:commitment($cid)") . "C" . substr("0000$cid",-5);
		$output .= &add_col() . $date;
		$output .= &add_col() . $disc;
		$output .= &add_col() . &getDisplayString ($text, 70);
		$output .= &add_col_link("javascript:viewaction($cid)") . 'review';
		$output .= &add_col_link("javascript:issue($iid)") . "I" . substr("0000$iid",-5);
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);
	}
	####  9  ##################################
	elsif ($section eq 'doe_tl_fulfil_review'){
	    $statusid = 11; # DOEDL Fulfillment Review
	    my $csr = $dbh -> prepare ("select c.commitmentid, to_char(c.commitdate,'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.primarydiscipline=d.disciplineid and c.statusid=$statusid and c.siteid=$siteid and c.primarydiscipline in $disclist order by c.commitmentid");
	    $csr -> execute;
	    my $output .= "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 40, 74, 95, 450, 41);
	    $output .= &title_row("#c0c0ff", "$entryForeground", "<font>Commitments to review ($counts{newdoetlfulrev}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view commitment<i></font>)");
	    $output .= &doTableHeader(status => $statusid);
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $date, $discipline, $text, $iid) = @values;
		$output .= &doTableBody(cid => $cid, date => $date, discipline => $discipline, text => $text, iid => $iid, script => 'DOEFL_fulfill_review');
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);

	    $statusid = 12;
	    my $csr2 = $dbh -> prepare ("select c.commitmentid, to_char(c.commitdate,'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.primarydiscipline=d.disciplineid and c.statusid=$statusid and c.siteid=$siteid and c.primarydiscipline in $disclist order by c.commitmentid");
	    $csr2 -> execute;
	    my $output2 .= "<tr><td align=right>\n";
	    $output2 .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output2 .= &start_table(5, 'center', 40, 74, 95, 450, 41);
	    $output2 .= &title_row("#c0c0ff", "$entryForeground", "<font>Resubmitted commitments ($counts{returneddoetlfulrev}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view commitment<i></font>)");
	    $output2 .= &doTableHeader(status => $statusid);
	    my $rows2 =0;
	    while (my @values2 = $csr2 -> fetchrow_array){
		$rows2++;
		my ($cid, $date, $discipline, $text, $iid) = @values2;
		$output2 .= &doTableBody(cid => $cid, date => $date, discipline => $discipline, text => $text, iid => $iid, script => 'DOEFL_fulfill_review');
	    }
	    $csr2 -> finish;
	    $output2 .= &end_table();
	    $output2 .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output2 if ($rows2 > 0);
	}
	####  10  ####################################
	elsif ($section eq 'doe_cmgr_closure_review'){
	    $statusid = 13; # DOECMgr Closure Review
	    my $csr = $dbh -> prepare ("select c.commitmentid, to_char(c.commitdate,'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.primarydiscipline=d.disciplineid and c.statusid=$statusid and c.siteid=$siteid order by c.commitmentid");
	    $csr -> execute;
	    my $output .= "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 40, 74, 95, 450, 41);
	    $output .= &title_row("#ffffc0", "$entryForeground", "<font>Commitments to review ($counts{newdoeclosure}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view commitment<i></font>)");
	    $output .= &doTableHeader(status => $statusid);
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $date, $discipline, $text, $iid) = @values;
		$output .= &doTableBody(cid => $cid, date => $date, discipline => $discipline, text => $text, iid => $iid, script => 'DOECMgr_closure_review');
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);
	}
	####  11  ##############################
	elsif ($section eq 'cm_closure_review'){
	    $statusid = 14; # CMaker Closure Review
	    my $csr = $dbh -> prepare ("select c.commitmentid, to_char(c.commitdate,'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.primarydiscipline=d.disciplineid and c.statusid=$statusid and c.siteid=$siteid and c.approver=$userid order by c.commitmentid");
	    $csr -> execute;
	    my $output .= "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 40, 74, 95, 450, 41);
	    $output .= &title_row("c0ffc0", "$entryForeground", "<font>Commitments to review ($counts{newcmclosure}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view commitment<i></font>)");
	    $output .= &doTableHeader(status => $statusid);
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $date, $discipline, $text, $iid) = @values;
		$output .= &doTableBody(cid => $cid, date => $date, discipline => $discipline, text => $text, iid => $iid, script => 'CMaker_closure_review');
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);
	}
	####  12  ################################
	elsif ($section eq 'doe_cmgr_final_resp'){
	    $statusid = 15; # Closure Letter
	    my $csr = $dbh -> prepare ("select c.commitmentid, to_char(c.closeddate,'MM/DD/YYYY'), d.description, c.text, c.issueid from $SCHEMA.commitment c, $SCHEMA.discipline d where c.primarydiscipline=d.disciplineid and c.statusid=$statusid and c.siteid=$siteid order by c.commitmentid");
	    $csr -> execute;
       	    my $output .= "<tr><td align=right>\n";
	    $output .= "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
	    $output .= &start_table(5, 'center', 40, 74, 95, 450, 41);
	    $output .= &title_row("#ffffc0", "$entryForeground", "<font>Commitments to review ($counts{newfinal}): </font>&nbsp;&nbsp;&nbsp;(<font size=-1><i>Click on ID to view commitment<i></font>)");
	    $output .= &doTableHeader(status => $statusid);
	    my $rows =0;
	    while (my @values = $csr -> fetchrow_array){
		$rows++;
		my ($cid, $date, $discipline, $text, $iid) = @values;
		$output .= &doTableBody(cid => $cid, date => $date, discipline => $discipline, text => $text, iid => $iid, script => 'DOECMgr_closeresponse');
	    }
	    $csr -> finish;
	    $output .= &end_table();
	    $output .= "</td></tr>\n<tr><td height=15> </td></tr>\n";
	    print $output if ($rows > 0);
	}
    };
    &processError(activity => "display $section section") if ($@);
}

#################################
if ($cgiaction eq 'closeissue') {
#################################
    no strict 'refs';
    my $issueid = $oncscgi -> param ('issueid');
    my $closeupdate = "update $SCHEMA.issue set isclosed = 'T' where issueid = $issueid";

    my $activity;
    my $csr;

    eval {
	$activity = "Close Issue";
	my $csr = $dbh->prepare($closeupdate);
	$csr->execute;
        $csr->finish;
	$dbh -> commit;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $userid, 'issue', "$issueid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print <<pageerror;
	<script language="JavaScript" type="text/javascript">
        <!--
        alert("$alertstring");
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$userid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageerror
    }
    else {
	my $logmessage = "Issue ".formatID2($issueid, 'I')." was closed by user $username";
	&log_activity($dbh, 'F', $userid, $logmessage);
       	print <<pageresults;
        <script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="$ONCSCGIDir/home.pl?loginusersid=$userid&loginusername=$username&schema=$SCHEMA";
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$userid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
    }
    &oncs_disconnect($dbh);
    exit 1;    
}

######################################
if ($cgiaction eq 'closecommitment') {
######################################
    no strict 'refs';
    my $commitmentid = $oncscgi -> param ('commitmentid');
    my $closeupdate = "update $SCHEMA.commitment set statusid=2, isclosed = 'T' where commitmentid = $commitmentid";

    my $activity;
    my $csr;

    eval {
	$activity = "Close Commitment";
	my $csr = $dbh->prepare($closeupdate);
	$csr->execute;
        $csr->finish;
	$dbh -> commit;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $userid, 'commitment', "$commitmentid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print <<pageerror;
	<script language="JavaScript" type="text/javascript">
        <!--
        alert("$alertstring");
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$userid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageerror
    }
    else {
	my $logmessage = "Commitment " . formatID2($commitmentid, 'C'). " closed for action entry by user $username";
	&log_activity($dbh, 'F', $userid, $logmessage);

	my $modls = $dbh -> prepare ("select lleadid from $SCHEMA.commitment where commitmentid=$commitmentid");
	$modls -> execute;
	while (my ($modlid) = $modls -> fetchrow_array) {
	    my $notification = &notifyUser(dbh => $dbh, schema => $SCHEMA, userID => $modlid);
	}

       	print <<pageresults;
        <script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="$ONCSCGIDir/home.pl?loginusersid=$userid&loginusername=$username&schema=$SCHEMA";
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$userid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
    }
    &oncs_disconnect($dbh);
    exit 1;    
}

$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
$dbh->{LongReadLen} = 80;
if ($process) {
} 
else {
    eval {
	&setupSections ($dbh, \%sections, $userid, $SCHEMA, $pageNum, $oncscgi->param("arrowPressed"));
    };
    &processError(activity => 'setup home sections') if ($@);
    &writeBody();
}
&oncs_disconnect($dbh);
exit();

