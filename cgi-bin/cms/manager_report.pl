#!/usr/local/bin/newperl -w

# Manager's Report for CIRS
#
# $Source: /data/dev/cirs/perl/RCS/manager_report.pl,v $
# $Revision: 1.17 $
# $Date: 2000/12/19 17:49:00 $
# $Author: naydenoa $
# $Locker:  $
# $Log: manager_report.pl,v $
# Revision 1.17  2000/12/19 17:49:00  naydenoa
# Some code re-write, more sorting functionality, changed column order
#
# Revision 1.16  2000/11/20 19:41:07  naydenoa
# Updated interface
#
# Revision 1.15  2000/10/04 22:21:07  atchleyb
# changed title, column headings allowed issues with no commitments to be viewed
#
# Revision 1.14  2000/09/26 00:56:11  atchleyb
# changed popups to use browse
#
# Revision 1.13  2000/09/21 21:54:24  atchleyb
# updated title
#
# Revision 1.12  2000/08/25 16:26:35  atchleyb
# changed Technical Lead to Discipline Lead
#
# Revision 1.11  2000/08/21 20:26:42  atchleyb
# fixed var name bug
#
# Revision 1.10  2000/08/21 18:40:53  atchleyb
# added check schema line
# changed oncscgi cmscgi
#
# Revision 1.9  2000/07/17 17:35:28  atchleyb
# placed form in a table of width 750
#
# Revision 1.8  2000/07/14 20:02:39  atchleyb
# remove title on page, set the image name in doSetTextImageLable
#
# Revision 1.7  2000/07/06 23:42:29  munroeb
# finished making mods to html and javascripts.
#
# Revision 1.6  2000/07/05 23:06:14  munroeb
# made minor changes to html and javascripts
#
# Revision 1.5  2000/06/21 22:25:35  zepedaj
# Changed "Functional" To "Technical"
#
# Revision 1.4  2000/05/30 16:28:26  zepedaj
# Removed "Under Construction" heading
#
# Revision 1.3  2000/05/23 18:00:22  atchleyb
# removed local getDisplayString function
# fixed print block errors
#
# Revision 1.2  2000/05/18 23:13:58  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/11 23:54:54  zepedaj
# Initial revision
#
#

# get all required libraries and modules
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

my $sqlcommand;
my $sqlcommand2;
my $cgiaction;
my $csr;
my $csr2;
my $status;
my @values;
my @values2;
my $displayval;
my $displayval2;
my $roleid;
my %commitmentlevelhash;
my $filtervalue;
my $defaultfiltervalue;
my $filterstring;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

#=========================================
#=========================================

# tell the browser that this is an html page using the header method
print $cmscgi->header('text/html');

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

my $username = $cmscgi->param('loginusername');
my $usersid = $cmscgi->param('loginusersid');
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

# output page header
print <<pageheader;
<html>
<head>
<meta name="pragma" content="no-cache">
<meta name="expires" content="0">
<meta http-equiv="expires" content="0">
<meta http-equiv="pragma" content="no-cache">
<title>CMS Manager Report</title>
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>

<!-- page specific javascript code -->
<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) {     // not in frames
    location = '$ONCSCGIDir/login.pl';
};

function newWin(location,name) {
    var myDate = new Date();
    var winName = myDate.getTime();
    popup = window.open(location,name + winName);
}

function DisplayIssue (id) {
    // function to popup a window with an issue's information
    var loc;
    loc = '$ONCSCGIDir/browse.pl?schema=$SCHEMA&loginusersid=$usersid&loginusername=$username&id=' + id + '&option=details&theinterface=issues&interfaceLevel=issueid';
    newWin(loc,'issue_popup');
};


//function DisplayCommitment (id,message) {
function DisplayCommitment (id) {
    // function to popup a window with a commitment's information
    var loc;
    loc = '$ONCSCGIDir/browse.pl?schema=$SCHEMA&loginusersid=$usersid&loginusername=$username&id=' + id + '&option=details&theinterface=commitments&interfaceLevel=commitmentid';
    newWin(loc,'commitment_popup');
    //alert(message);
};

function DisplayDefinitions () {
    var loc;
    loc = '$ONCSCGIDir/commit_level_definitions.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA'
    PopIt(loc, 'oncs_popup');
};

function submitsort (sortvalue) {
    // function changes the sort field and submits the form.
    document.reportfilter.sortval.value = sortvalue;
    document.reportfilter.submit ();
};

//-->
</script>
<script language="JavaScript" type="text/javascript">
<!--
    doSetTextImageLabel('Standard Report');
//-->
</script>
</head>
pageheader

# fill the hash of commitment levels and descriptions for use in the picklist
%commitmentlevelhash = get_lookup_values($dbh, 'commitmentlevel', 'description', 'commitmentlevelid');

$defaultfiltervalue = $commitmentlevelhash{"Regulatory Commitment"};

$filtervalue = $cmscgi->param('commitmentlevel');
$filtervalue = ($filtervalue) ? $filtervalue : $defaultfiltervalue;
print <<bodystart1;
<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
<br><br><table border=0 align=center width=750><tr><td>
<form name=reportfilter method=post action="$ONCSCGIDir/manager_report.pl">
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
<input type=hidden name=sortval value=''>
<input type=hidden name=schema value=$SCHEMA>
<input type=hidden name=option value=''>
<input type=hidden name=theinterface value=''>
<input type=hidden name=interfaceLevel value=''>
<input type=hidden name=id value=''>
<center>
<input type=button value=Definitions name=btndefinitions onclick="DisplayDefinitions()">
&nbsp;
<select name=commitmentlevel>
<option value='-1'>All Commitments
bodystart1
foreach my $key (sort keys %commitmentlevelhash) {
    my $selectedtext = ($commitmentlevelhash{$key} == $filtervalue) ? " selected" : "";
    print "<option value=\"$commitmentlevelhash{$key}\"$selectedtext>$key\n";
}
print <<bodystart2;
</select>
<input type=submit value=Go name=submit_reportfilter>
</center>
<br><br>
bodystart2

$dbh->{LongTruncOk} = 1;
$dbh->{LongReadLen} = 1000;

# determine sort to use
$filterstring = "";
if ($filtervalue > 0) {
    $filterstring = " AND com.commitmentlevelid = $filtervalue";
}
#my $orderby = 'ORDER BY cat.description,com.commitdate';
my $orderby = 'ORDER BY com.commitdate DESC,cat.description';
my $sortorder = $cmscgi->param('sortval');
$sortorder = (defined($sortorder)) ? $sortorder : 'commitment_datedesc';
my $catsort='category';
my $cdatesort='commitment_date';
my $leadsort='lead';
my $comsort='commitment';
my $issort='issue';
my $statsort='status';
my $fullsort='fulfill';

if ($sortorder eq 'category') {
    $orderby = 'ORDER BY cat.description,com.commitdate';
    $catsort='categorydesc';
}
if ($sortorder eq 'categorydesc') {
    $orderby = 'ORDER BY cat.description DESC,com.commitdate';
    $catsort='category';
}
if ($sortorder eq 'commitment_date') {
    $orderby = 'ORDER BY com.commitdate,cat.description';
    $cdatesort='commitment_datedesc';
}
if ($sortorder eq 'commitment_datedesc') {
    $orderby = 'ORDER BY com.commitdate DESC,cat.description';
    $cdatesort='commitment_date';
}
if ($sortorder eq 'lead') {
    $orderby = 'ORDER BY lname,fname,cat.description,com.commitdate';
    $leadsort='leaddesc';
}
if ($sortorder eq 'leaddesc') {
    $orderby = 'ORDER BY lname DESC,fname desc,cat.description,com.commitdate';
    $leadsort='lead';
}
if ($sortorder eq 'commitment') {
    $orderby = 'order by com.commitmentid'; 
    $comsort='commitmentdesc';
}
if ($sortorder eq 'commitmentdesc') {
    $orderby = 'order by com.commitmentid desc'; 
    $comsort='commitment';
}
if ($sortorder eq 'issue') {
    $orderby = 'order by com.issueid, com.commitmentid';
    $issort='issuedesc';
}
if ($sortorder eq 'issuedesc') {
    $orderby = 'order by com.issueid desc, com.commitmentid';
    $issort='issue';
}
if ($sortorder eq 'status') {
    $orderby = 'order by com.statusid, com.issueid, com.commitmentid'; 
    $statsort='statusdesc';
}
if ($sortorder eq 'statusdesc') {
    $orderby = 'order by com.statusid desc, com.issueid, com.commitmentid'; 
    $statsort='status';
}
if ($sortorder eq 'fulfill') {
    $orderby = 'order by com.fulfilldate, com.issueid, com.commitmentid'; 
    $fullsort='fulfilldesc';
}
if ($sortorder eq 'fulfilldesc') {
    $orderby = 'order by com.fulfilldate desc, com.issueid, com.commitmentid'; 
    $fullsort='fulfill';
}

# generate sql lookup statement
$roleid = lookup_role_by_name($dbh, "DOE Discipline Lead");
$sqlcommand = "SELECT cat.description, issue.issueid, issue.text,
                      TO_CHAR(issue.entereddate,'MM/DD/YYYY'),
                      NVL(com.commitmentid,0),
                      TO_CHAR(com.commitdate,'MM/DD/YYYY'), com.text, 
                      NVL(uncr.lastname, '') fname, 
                      NVL(uncr.firstname, '') lname, 
                      NVL(TO_CHAR(com.duedate, 'MM/DD/YYYY'), ' '), 
                      to_char(com.fulfilldate, 'MM/DD/YYYY'),
                      stat.description ";
$sqlcommand .= "FROM $SCHEMA.category cat, $SCHEMA.issue issue, 
                     $SCHEMA.commitment com, 
                     $SCHEMA.usernamecommitmentroles uncr, 
                     $SCHEMA.status stat ";
$sqlcommand .= "WHERE ((issue.categoryid=cat.categoryid(+)) 
                      AND (com.issueid(+)=issue.issueid) 
                      AND ((com.commitmentid = uncr.commitmentid(+)) 
                      AND uncr.roleid(+) = $roleid) 
                      AND (com.statusid = stat.statusid(+))) 
                      $filterstring $orderby";
print "<!-- $sqlcommand -->\n";
#print STDERR "$sqlcommand\n";
eval {
    $dbh->{RaiseError} = 1;
    $csr = $dbh->prepare($sqlcommand);
    $status = $csr->execute;

    print start_table (7, 'center', 80, 195, 195, 80, 70, 70, 60);
    print title_row ("#daaada", "#000000", "Standard Report");
    print add_header_row ();
    print add_col_link("javascript:submitsort('$catsort');") . 'Category';
    print add_col_link("javascript:submitsort('$issort');") . 'Issue';
    print add_col_link("javascript:submitsort('$comsort');") . 'Commitment';
    print add_col_link("javascript:submitsort('$statsort');") . 'Status';
    print add_col_link("javascript:submitsort('$cdatesort');") . 'Commitment Date';
    print add_col_link("javascript:submitsort('$fullsort');") . 'Fulfillment Date&nbspEstimate';
    print add_col_link("javascript:submitsort('$leadsort')") . 'DOE Lead';

    my $savewarn = $^W;
    #$^W =0;
    while (@values = $csr->fetchrow_array) {
        for (my $i=0; $i<=11; $i++) {
            if (!(defined($values[$i]))) {$values[$i]='&nbsp;';}
            #if (!(defined($values[$i]))) {$values[$i]='';}
        }
	my ($category, $iid, $itext, $idate, $cid, $commitdate, $ctext, $last, $first, $duedate, $fulfilldate, $status) = @values;
	my $displaycommitment = "No current commitments";

	print add_row();
	print add_col() . $category;
	print add_col_link("javascript:DisplayIssue($iid);") . "I" . substr("0000$iid",-5) . " - " . getDisplayString($itext, 70);
	if ($cid) {
	    $displaycommitment = "C" . substr("0000$cid",-5) . " - " . getDisplayString($ctext, 70);
	    print add_col_link("javascript:DisplayCommitment($cid);") . $displaycommitment;
	}
	else {
	    print add_col() . $displaycommitment;
	}
	print add_col() . $status;
	print add_col() . $commitdate;
	print add_col() . $fulfilldate;
	print add_col() . $first . " " . $last;
    }
    $csr->finish;
    print end_table();

    $^W = $savewarn;
};

$dbh->{RaiseError} = 0;
if ($@) {
    # handle error
    my $alertstring = errorMessage($dbh, $username, $usersid, 'issues/commitments', "", "Error retreiving data for standard report", $@);
    $alertstring =~ s/"/'/g;
    print <<erroralert;
      <script language=javascript>
        <!--
        alert("$alertstring");
        //-->
      </script>
erroralert
}

&oncs_disconnect($dbh);

print <<bodyend;
</form>
</td></tr></table><br><br>
</body>
</html>
bodyend

