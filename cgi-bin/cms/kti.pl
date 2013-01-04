#!/usr/local/bin/newperl -w
#
# Report for KTI Issues/Commitments in CMS
#
# $Source: /data/dev/cirs/perl/RCS/kti.pl,v $
# $Revision: 1.3 $
# $Date: 2001/05/10 16:41:02 $
# $Author: naydenoa $
# $Locker:  $
# $Log: kti.pl,v $
# Revision 1.3  2001/05/10 16:41:02  naydenoa
# Updated code to handle new categories and lead assignments
#
# Revision 1.2  2000/12/08 18:05:02  naydenoa
# Took out old, useless code.
#
# Revision 1.1  2000/12/08 16:59:57  naydenoa
# Initial revision
#
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

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;


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
<title>CMS KTI Report</title>
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>

<!-- page specific javascript code -->
<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) {     // not in frames
    location = '$ONCSCGIDir/login.pl';
};

//-->
</script>
<script language="JavaScript" type="text/javascript">
<!--
    doSetTextImageLabel('KTI Report');
//-->
</script>
</head>
pageheader

print <<bodystart1;
<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
<br><br><table border=0 align=center width=750><tr><td>
<form name=ktireport method=post action="$ONCSCGIDir/ktireport.pl">
<input type=hidden name=schema value=$SCHEMA>
<input type=hidden name=option value=''>
<input type=hidden name=theinterface value=''>
<input type=hidden name=interfaceLevel value=''>
<input type=hidden name=id value=''>
bodystart1
$dbh->{LongTruncOk} = 0;
$dbh->{LongReadLen} = 10000000;

my ($reportdate) = $dbh ->selectrow_array ("select to_char(SYSDATE, 'DD Month YYYY') from dual");

print "<P><h2 align=center>YMSCO Status Report on the NRC KTI Agreements</h2>\n";
print "<h3 align=center>$reportdate</h3>\n";
print "<table width=600 align=center><tr><td>\n";

my $issuesql = "select i.issueid, i.text, c.description 
                from $SCHEMA.issue i, $SCHEMA.category c
                where c.description like 'KTI%'
                      and i.categoryid = c.categoryid
                order by i.issueid";#i.categoryid in (24, 25, 26, 27) 

my $issues = $dbh -> prepare ($issuesql);
$issues -> execute ();
while (my @values = $issues -> fetchrow_array) {
    my ($issueid, $issuetext, $issuecat) = @values;
    my $issueidstr = substr ("0000$issueid",-5);
    print "<br><b><li>Issue ID: I$issueidstr</b>\n";
    print "<b><li>Issue Category: </b>$issuecat\n";
    print "<b><li>Issue Text: </b>$issuetext\n";
    print "<p><b>Associated Commitments:</b> \n";

    my $rows = 0;
    my $commitmentsql = "select c.commitmentid, c.text, s.description, 
                                to_char (c.fulfilldate, 'MM/DD/YYYY'),
                                c.primarydiscipline, c.siteid, c.statusid
                         from $SCHEMA.commitment c, $SCHEMA.status s
                         where c.issueid = $issueid and c.statusid = s.statusid
                         order by c.commitmentid";
    my $commitments = $dbh -> prepare ($commitmentsql);
    $commitments -> execute ();
    while (my @values2 = $commitments -> fetchrow_array) {
        $rows++;
        my ($commitmentid, $commitmenttext, $commitmentstatus, $commitmentfulfilldate, $commitmentprimary, $commitmentsite, $status) = @values2;

        my $commitmentidstr = substr ("0000$commitmentid",-5);
	my $fulfill = ($commitmentfulfilldate) ? $commitmentfulfilldate : "To Be Determined";
        print "<p><b><li>Commitment ID: C$commitmentidstr</b>\n";
	print "<br><li><b>Commitment Text: </b>$commitmenttext\n";
	print "<br><li><b>Commitment Status:</b> $commitmentstatus";
	print "<br><li><b>Estimated Fulfillment Date:</b> $fulfill\n";
	print "<br><li><b>DOE Lead:</b> ";
        if ($commitmentid) { #&& $status > 3) {
            my $doeleadsql = "select u.firstname || ' ' || u.lastname 
                              from $SCHEMA.users u, 
                                   $SCHEMA.commitmentrole cr
                              where u.usersid = cr.usersid 
                                    and cr.roleid = 3
                                    and commitmentid = $commitmentid";
            my $leads = $dbh -> prepare ($doeleadsql);
            $leads -> execute ();
            while (my @values3 = $leads -> fetchrow_array) {
                my ($doelead) = @values3;
                print "$doelead";
	    }
            $leads -> finish;
	}
=pod
        elsif ($commitmentid) {
	    print "Assignment pending. Possible lead(s):&nbsp;&nbsp; \n";
            my $possiblesql = "select u.firstname || '&nbsp' || u.lastname 
                               from $SCHEMA.users u, 
                                    $SCHEMA.defaultdisciplinerole dr
                               where dr.disciplineid = $commitmentprimary
                                     and dr.roleid = 3 
                                     and u.siteid = $commitmentsite
                                     and u.usersid = dr.usersid";
            my $possibles = $dbh -> prepare ($possiblesql);
	    $possibles -> execute ();
	    while (my @values4 = $possibles -> fetchrow_array) {
		my ($possiblelead) = @values4;
                print "$possiblelead &nbsp; &nbsp; &nbsp;";
	    }
	    $possibles -> finish;
	}
=cut
    }
    $commitments -> finish;
    if ($rows == 0) {
	print "None\n";
    }
    print "<br><br><hr width=400>\n";
}
$issues -> finish;
print "</td></tr><table>\n";
&oncs_disconnect($dbh);
print "</form></td></tr></table><br><br>\n</body>\n</html>\n";

