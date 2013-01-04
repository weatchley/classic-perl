#!/usr/local/bin/newperl -w
#
# BSC Report format for CMS
#
# $Source: /data/dev/rcs/cms/perl/RCS/BSC_report.pl,v $
# $Revision: 1.3 $
# $Date: 2002/02/21 16:15:16 $
# $Author: naydenoa $
# $Locker:  $
# $Log: BSC_report.pl,v $
# Revision 1.3  2002/02/21 16:15:16  naydenoa
# Fixed sort
#
# Revision 1.2  2002/02/21 00:35:02  naydenoa
# Allowed for retrieval of commitments without assigned managers and
# BSC discipline leads.
#
# Revision 1.1  2001/12/18 21:20:45  naydenoa
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

print $cmscgi->header('text/html');
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

print <<pageheader;
<html>
<head>
<meta name="pragma" content="no-cache">
<meta name="expires" content="0">
<meta http-equiv="expires" content="0">
<meta http-equiv="pragma" content="no-cache">
<title>CMS Manager Report</title>
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>
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
function DisplayCommitment (id) {
    var loc;
    loc = '$ONCSCGIDir/browse.pl?schema=$SCHEMA&loginusersid=$usersid&loginusername=$username&id=' + id + '&option=details&theinterface=commitments&interfaceLevel=commitmentid';
    newWin(loc,'commitment_popup');
};
function DisplayAction (cid,aid) {
    var loc;
    loc = '$ONCSCGIDir/browse.pl?schema=$SCHEMA&loginusersid=$usersid&loginusername=$username&id=' + cid + '&actionid=' + aid + '&option=details&theinterface=actions&interfaceLevel=commitmentid';
    newWin(loc,'commitment_popup');
};
function DisplayDefinitions () {
    var loc;
    loc = '$ONCSCGIDir/commit_level_definitions.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA'
    PopIt(loc, 'oncs_popup');
};
function submitsort (sortvalue) {
    document.reportfilter.sortval.value = sortvalue;
    document.reportfilter.submit ();
};

//-->
</script>
<script language="JavaScript" type="text/javascript">
<!--
    doSetTextImageLabel('BSC Responsible Manager/Supervisor Report');
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
<br><table border=0 align=center width=750><tr><td>
<form name=reportfilter method=post action="$ONCSCGIDir/BSC_report.pl">
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
<br>
bodystart2

$dbh->{LongTruncOk} = 1;
$dbh->{LongReadLen} = 1000;

# determine sort to use
$filterstring = "";
if ($filtervalue > 0) {
    $filterstring = " AND com.commitmentlevelid = $filtervalue";
}
my $orderby;    # = 'ORDER BY com.commitdate DESC, cat.description';
my $sortorder = $cmscgi->param('sortval');
$sortorder = (defined($sortorder)) ? $sortorder : 'issuedesc';
my $catsort='category';
my $leadsort='lead';
my $comsort='commitment';
my $issort='issue';
my $statsort='status';
my $fullsort='fulfill';
my $duesort ='due';
my $cmgrsort = 'cmgr';
my $amgrsort = 'amgr';
my $alleadsort = 'allead';
my $adleadsort = 'adlead';
my $actionsort = 'action';
my $actiondatesort = 'actiondate';
my $astatussort = 'astatus';

if ($sortorder eq 'category') {
    $orderby = 'ORDER BY c.description, i.issueid';#com.commitdate';
    $catsort='categorydesc';
}
if ($sortorder eq 'categorydesc') {
    $orderby = 'ORDER BY c.description DESC, i.issueid';  #com.commitdate';
    $catsort='category';
}
if ($sortorder eq 'lead') {
    $orderby = 'ORDER BY com.lleadid, c.description, com.commitmentid';
    $leadsort='leaddesc';
}
if ($sortorder eq 'leaddesc') {
    $orderby = 'ORDER BY com.lleadid desc, c.description, com.commitmentid';
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
    $orderby = 'order by stat.description, com.issueid, com.commitmentid'; 
    $statsort='statusdesc';
}
if ($sortorder eq 'statusdesc') {
    $orderby = 'order by stat.description desc, com.issueid, com.commitmentid';
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
if ($sortorder eq 'due') {
    $orderby = 'order by com.duedate, com.issueid, com.commitmentid'; 
    $duesort='duedesc';
}
if ($sortorder eq 'duedesc') {
    $orderby = 'order by com.duedate desc, com.issueid, com.commitmentid'; 
    $duesort='due';
}
if ($sortorder eq 'cmgr') {
    $orderby = 'order by com.managerid, com.issueid, com.commitmentid'; 
    $cmgrsort='cmgrdesc';
}
if ($sortorder eq 'cmgrdesc') {
    $orderby = 'order by com.managerid desc, com.issueid, com.commitmentid'; 
    $cmgrsort='cmgr';
}
if ($sortorder eq 'adlead') {
    $orderby = 'order by a.dleadid, com.issueid, com.commitmentid'; 
    $adleadsort='adleaddesc';
}
if ($sortorder eq 'adleaddesc') {
    $orderby = 'order by a.dleadid desc, com.issueid, com.commitmentid'; 
    $adleadsort='adlead';
}
if ($sortorder eq 'amgr') {
    $orderby = 'order by a.managerid, com.issueid, com.commitmentid'; 
    $amgrsort='amgrdesc';
}
if ($sortorder eq 'amgrdesc') {
    $orderby = 'order by a.managerid desc, com.issueid, com.commitmentid'; 
    $amgrsort='amgr';
}
if ($sortorder eq 'action') {
    $orderby = 'order by com.commitmentid, a.actionid, com.issueid'; 
    $actionsort='actiondesc';
}
if ($sortorder eq 'actiondesc') {
    $orderby = 'order by com.commitmentid desc, a.actionid desc, com.issueid'; 
    $actionsort='action';
}
if ($sortorder eq 'actiondate') {
    $orderby = 'order by a.duedate, com.commitmentid, a.actionid, com.issueid';
    $actiondatesort='actiondatedesc';
}
if ($sortorder eq 'actiondatedesc') {
    $orderby = 'order by a.duedate desc, com.commitmentid desc, a.actionid desc, com.issueid'; 
    $actiondatesort='actiondate';
}
if ($sortorder eq 'astatus') {
    $orderby = 'order by a.status, com.commitmentid, a.actionid, com.issueid'; 
    $astatussort='astatusdesc';
}
if ($sortorder eq 'astatusdesc') {
    $orderby = 'order by a.status desc, com.commitmentid desc, a.actionid desc, com.issueid'; 
    $astatussort='astatus';
}
########################
print "<table width=1000 border=1 cellpadding=2 cellspacing=0 bgcolor=#ffffff>\n";
print "<tr bgcolor=#adefbc><td colspan=16><b>BSC Responsible Manager/Supervisor Report</b></td></tr>\n";
print "<tr bgcolor=#dddddd><td width=50><font size=2><b><a href=\"javascript:submitsort('$catsort');\">Category</a></td>\n";
print "<td nowrap><font size=2><b><a href=\"javascript:submitsort('$issort');\">IID</a></td>\n";
print "<td width=150><font size=2><b>Issue Text</td>\n";
print "<td><font size=2><b>Source Document</td>\n";
print "<td nowrap><font size=2><b><a href=\"javascript:submitsort('$comsort')\">CID</a></td>\n";
print "<td width=150><font size=2><b>Commitment Text</td>\n";
print "<td><font size=2><b>External ID</td>\n";
print "<td nowrap><font size=2><b><a href=\"javascript:submitsort('$cmgrsort');\">RM</a>/<a href=\"javascript:submitsort('$leadsort');\">BSCDL</a></td>\n";
print "<td><font size=2><b><a href=\"javascript:submitsort('$fullsort');\">Fulfillment Date</a></td>\n";
print "<td><font size=2><b><a href=\"javascript:submitsort('$duesort');\">Date&nbsp;Due&nbsp;to<br>Comm&nbsp;Maker</a></td>\n";
print "<td><font size=2><b><a href=\"javascript:submitsort('$statsort');\">Status</td>\n";
print "<td nowrap><font size=2><b><a href=\"javascript:submitsort('$actionsort');\">Action ID</a></td>\n";
print "<td width=150><font size=2><b>Action Text</td>\n";
print "<td><font size=2><b><a href=\"javascript:submitsort('$amgrsort');\">RM</a>/<a href=\"javascript:submitsort('$alleadsort');\">LL</a>/<a href=\"javascript:submitsort('$adleadsort');\">DL</a></td>\n";
print "<td><font size=2><b><a href=\"javascript:submitsort('$actiondatesort');\">Action Due&nbsp;Date</a></td>\n";
print "<td><font size=2><b><a href=\"javascript:submitsort('$astatussort')\">Action Status</a></td></tr>\n";
my $issueinfo = "select c.description, i.issueid, i.text, s.accessionnum, 
                        com.commitmentid, com.text, com.externalid,
                        com.lleadid, com.managerid, 
                        to_char(com.fulfilldate, 'MM/DD/YYYY'), 
                        to_char(com.duedate, 'MM/DD/YYYY'), stat.description,
	                a.actionid, a.text, 
                        a.lleadid, a.dleadid, a.managerid, 
                        to_char (a.duedate, 'MM/DD/YYYY'), a.status 
                 from $SCHEMA.issue i, $SCHEMA.category c, 
                      $SCHEMA.sourcedoc s, $SCHEMA.commitment com, 
                      $SCHEMA.status stat, $SCHEMA.action a 
                 where  c.categoryid = i.categoryid and
                        i.sourcedocid(+) = s.sourcedocid and 
                        i.issueid = com.issueid(+) and
                        com.statusid = stat.statusid and
                        a.commitmentid(+) = com.commitmentid
                        $filterstring 
                 $orderby";
#                        com.managerid = m.responsiblemanagerid and
#                        com.lleadid = u.usersid and
#                        m.firstname, m.lastname, u.firstname, u.lastname, 
#                      $SCHEMA.responsiblemanager m, $SCHEMA.users u,

eval {
    $csr = $dbh -> prepare ($issueinfo);
    $csr -> execute;
    my $commitmentinfo;
    my $actioninfo;
    my $acsr;
    
    while (my ($category, $iid, $itext, $accnum, $cid, $ctext, $extid, $llid, $rmid, $fulfil, $due, $stat, $aid, $atext, $allead, $adlead, $amgr, $adue, $astat) = $csr -> fetchrow_array) {
	
	$extid = "&nbsp;" if (!$extid);
	$fulfil = "&nbsp;" if (!$fulfil);
	print "<tr valign=top><td><font size=1>$category</td>\n";
	print "<td><font size=1><a href=\"javascript:DisplayIssue($iid);\">" . formatID2($iid, 'I') . "</a></td>\n";
	print "<td><font size=1>" . getDisplayString($itext, 60) . "</td>\n";
	print "<td><font size=1>$accnum&nbsp;</td>";
	if ($cid) {
	    print "<td><font size=1><a href=\"javascript:DisplayCommitment($cid);\">" . formatID2($cid, 'C') . "</a></td>\n";
	    print "<td><font size=1>" . getDisplayString ($ctext, 60) . "</td>\n";
	    print "<td><font size=1>$extid&nbsp;</td>\n";

	    my ($cmgrfirst, $cmgrlast, $cleadfirst, $cleadlast); 
	    if ($llid) {
		($cleadfirst, $cleadlast) = $dbh -> selectrow_array ("select firstname, lastname from $SCHEMA.users where usersid = $llid");
	    }
	    else {
		$cleadfirst = "Not";
		$cleadlast = "Assigned";
	    }
	    if ($rmid) {
		($cmgrfirst, $cmgrlast) = $dbh -> selectrow_array ("select firstname, lastname from $SCHEMA.responsiblemanager where responsiblemanagerid = $rmid");
	    }
	    else {
		$cmgrfirst = "Not";
		$cmgrlast = "Assigned";
	    }
	    print "<td><font size=1>$cmgrfirst&nbsp;$cmgrlast<br>$cleadfirst&nbsp;$cleadlast</td>\n";
	    print "<td><font size=1>$fulfil&nbsp;</td>\n";
	    print "<td><font size=1>$due&nbsp;</td>\n";
	    print "<td><font size=1>$stat</td>\n";
	    if ($aid) {
		my ($amgrfirst, $amgrlast) = $dbh -> selectrow_array ("select firstname, lastname from $SCHEMA.responsiblemanager where responsiblemanagerid=$amgr");
		my ($allfirst, $alllast) = $dbh -> selectrow_array ("select firstname, lastname from $SCHEMA.users where usersid=$allead");
		my ($adlfirst, $adllast) = $dbh -> selectrow_array ("select firstname, lastname from $SCHEMA.users where usersid=$adlead");
		print "<td><font size=1><a href=\"javascript:DisplayAction($cid,$aid);\">" . formatID2($cid, 'CA') . "/" . substr("00$aid", -3) . "</a></td>\n";
		print "<td><font size=1>" . getDisplayString ($atext, 60) . "</td>\n";
		print "<td><font size=1>$amgrfirst&nbsp;$amgrlast<br>$allfirst&nbsp;$alllast<br>$adlfirst&nbsp;$adllast</td>\n";
		print "<td><font size=1>$adue</td>\n";
		print "<td><font size=1>$astat</td></tr>\n";
	    }
	    else {
		print "<td colspan=5><font size=1>There are no actions associated with this commitment</td></tr>\n";
	    }
	}
	else {
	    print "<td colspan=12><fint size=1>There are no commitments for this issue</td></tr>\n";
	}
    }
    print "</table>\n";
    $csr->finish;
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



