#!/usr/local/bin/newperl
#
# CMS Standard Report Frame 2
#
# $Source: /data/dev/rcs/cms/perl/RCS/stdrep2.pl,v $
# $Revision: 1.3 $
# $Date: 2001/11/15 23:40:25 $
# $Author: naydenoa $
# $Locker:  $
# $Log: stdrep2.pl,v $
# Revision 1.3  2001/11/15 23:40:25  naydenoa
# Updated licensing lead handling.
#
# Revision 1.2  2001/06/01 23:11:26  naydenoa
# Added LL to display
#
# Revision 1.1  2001/03/21 18:44:46  naydenoa
# Initial revision
#

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
my $dbh = oncs_connect();

# print content type header
print $cmscgi->header('text/html');

my $username = $cmscgi->param('loginusername');
my $usersid = $cmscgi->param('loginusersid');

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "")) {
    print "<script type=\"text/javascript\">\n<!--\n";
    print "parent.location=\'$ONCSCGIDir/login.pl\';\n";
    print "//-->\n</script>\n";
    exit 1;
}

print "<html>\n<head>\n";
print "<meta name=\"pragma\" content=\"no-cache\">\n";
print "<meta name=\"expires\" content=\"0\">\n";
print "<meta http-equiv=\"expires\" content=\"0\">\n";
print "<meta http-equiv=\"pragma\" content=\"no-cache\">\n";
print "<title>Standard Report Frame 2</title>\n\n";
print "<script src=\"$ONCSJavaScriptPath/oncs-utilities.js\"></script>\n";
print "<script type=\"text/javascript\">\n<!--\n";
print "var dosubmit = true;\n";
print "if (parent == self) {\n";
print "      location = \'$ONCSCGIDir/login.pl\'\n";
print "};\n\n";
print "function newWin(location,name) {\n";
print "    var myDate = new Date();\n";
print "    var winName = myDate.getTime();\n";
print "    popup = window.open(location,name + winName);\n";
print "}\n\n";
print "function DisplayIssue (id) {\n";
print "    var loc;\n";
print "    loc = '$ONCSCGIDir/browse.pl?schema=$SCHEMA&loginusersid=$usersid&loginusername=$username&id=' + id + '&option=details&theinterface=issues&interfaceLevel=issueid';\n";
print "    newWin(loc,'issue_popup');\n";
print "};\n";
print "function DisplayCommitment (id) {\n";
print "    var loc;\n";
print "    loc = '$ONCSCGIDir/browse.pl?schema=$SCHEMA&loginusersid=$usersid&loginusername=$username&id=' + id + '&option=details&theinterface=commitments&interfaceLevel=commitmentid';\n";
print "    newWin(loc,'commitment_popup');\n";
print "};\n";
print "//-->\n</script>\n";
print "</head>\n";

$dbh->{LongTruncOk} = 1;
$dbh->{LongReadLen} = 1000;

my $defaultfiltervalue = 4; #regulatory

my $filtervalue = $cmscgi->param('commitmentlevel');
$filtervalue = ($filtervalue) ? $filtervalue : $defaultfiltervalue;
my $filter = ($filtervalue == -1) ?"":"c.commitmentlevelid=$filtervalue and"; 

my $reverse = 0;
my $orderby = 'ORDER BY c.fulfilldate DESC, cat.description';
my $sortorder = $cmscgi->param('sortval');
$sortorder = (defined($sortorder)) ? $sortorder : 'issuedesc'; 
if ($sortorder eq 'category') {
    $orderby = 'ORDER BY cat.description,c.commitdate';
}
if ($sortorder eq 'commitment') {
    $orderby = 'order by c.commitmentid'; 
}
if ($sortorder eq 'issue') {
    $orderby = 'order by c.issueid, c.commitmentid';
}
if ($sortorder eq 'status') {
    $orderby = 'order by c.statusid, c.issueid, c.commitmentid'; 
}
if ($sortorder eq 'fulfill') {
    $orderby = 'order by c.fulfilldate, c.issueid, c.commitmentid'; 
}
if ($sortorder eq 'doelead') {
    $orderby = 'order by u.lastname, u.firstname, c.issueid, c.commitmentid';
}
if ($sortorder eq 'molead') {
    $orderby = 'order by ur.lastname, ur.firstname, c.issueid, c.commitmentid';
}
if ($sortorder eq 'lllead') {
    $reverse = 1;
}
print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
print "<table width=750 align=center cellpadding=3 cellspacing=0 border=1>\n";
if ($reverse) {
    my $noll = "(";
    my $count = 0;
    my $getll = $dbh -> prepare ("select distinct u.usersid, u.firstname || ' ' || u.lastname, u.lastname from $SCHEMA.users u, $SCHEMA.commitment c where c.lleadid=u.usersid order by u.lastname");
    $getll -> execute;
    while (my ($lid, $ll) = $getll -> fetchrow_array) {
	my $what = "select i.issueid, i.text, c.commitmentid, c.text, to_char(c.fulfilldate, 'MM/DD/YYYY'), cat.description, s.description, u.firstname || ' ' || u.lastname, ur.firstname || ' ' || ur.lastname from $SCHEMA.issue i, $SCHEMA.commitment c, $SCHEMA.category cat, $SCHEMA.status s, $SCHEMA.users u, $SCHEMA.commitmentrole cr, $SCHEMA.usernamecommitmentroles ur where $filter c.lleadid = $lid and cr.roleid=3 and ur.roleid=2 and ur.commitmentid=c.commitmentid and cr.usersid=u.usersid and c.commitmentid(+)=cr.commitmentid and c.issueid=i.issueid(+) and i.categoryid=cat.categoryid and c.statusid=s.statusid order by c.commitmentid";
	my $getinfo = $dbh -> prepare ($what);
	$getinfo -> execute;
	while (my @values = $getinfo -> fetchrow_array) {
	    my ($iid, $itext, $cid, $ctext, $ful, $cat, $stat, $doel, $mol) = @values;
	    $ful = ($ful) ? $ful : "&nbsp;";
	    print "<tr bgcolor=white><td width=70><font size=-1>$cat</td>\n";
	    print "<td width=125><font size=-1><a href=\"javascript:DisplayIssue($iid);\">" . formatID2($iid, 'I') . "</a> - " . getDisplayString ($itext,45) . "</td>\n";
	    print "<td width=125><font size=-1><a href=\"javascript:DisplayCommitment($cid);\">" . formatID2($cid, 'C') . "</a> - " . getDisplayString ($ctext, 45) . "</td>\n";
	    print "<td width=80><font size=-1>$stat</td>\n";
	    print "<td width=80><font size=-1>$ful</td>\n";
	    print "<td width=90><font size=-1>$doel&nbsp;</td>\n";
	    print "<td width=90><font size=-1>$mol&nbsp;</td>\n";
	    print "<td width=90><font size=-1>$ll&nbsp;</td></tr>\n";
	    $noll .= "$cid, ";
	    $count++;
	}
	$getinfo -> finish;
    }
    if ($count) {
	chop ($noll);
	chop ($noll);
    }
    else {
	$noll .= "0";
    }
    $noll .= ")";
    my $what = "select i.issueid, i.text, c.commitmentid, c.text, to_char(c.fulfilldate, 'MM/DD/YYYY'), cat.description, s.description, u.firstname || ' ' || u.lastname, ur.firstname || ' ' || ur.lastname from $SCHEMA.issue i, $SCHEMA.commitment c, $SCHEMA.category cat, $SCHEMA.status s, $SCHEMA.users u, $SCHEMA.commitmentrole cr, $SCHEMA.usernamecommitmentroles ur where $filter c.commitmentid not in $noll and cr.roleid=3 and ur.roleid=2 and ur.commitmentid=c.commitmentid and cr.usersid=u.usersid and c.commitmentid(+)=cr.commitmentid and c.issueid=i.issueid(+) and i.categoryid=cat.categoryid and c.statusid=s.statusid order by c.commitmentid";
    $getll = $dbh -> prepare ($what);
    $getll -> execute;
    while (my @values = $getll -> fetchrow_array) {
	my ($iid, $itext, $cid, $ctext, $ful, $cat, $stat, $doel, $mol) = @values;
	$ful = ($ful) ? $ful : "&nbsp;";
	print "<tr bgcolor=white><td width=70><font size=-1>$cat</td>\n";
	print "<td width=125><font size=-1><a href=\"javascript:DisplayIssue($iid);\">" . formatID2($iid, 'I') . "</a> - " . getDisplayString ($itext,45) . "</td>\n";
	print "<td width=125><font size=-1><a href=\"javascript:DisplayCommitment($cid);\">" . formatID2($cid, 'C') . "</a> - " . getDisplayString ($ctext, 45) . "</td>\n";
	print "<td width=80><font size=-1>$stat</td>\n";
	print "<td width=80><font size=-1>$ful</td>\n";
	print "<td width=90><font size=-1>$doel&nbsp;</td>\n";
	print "<td width=90><font size=-1>$mol&nbsp;</td>\n";
	print "<td width=90><font size=-1>&nbsp;</td></tr>\n";
    }

    $getll -> finish;
}
else {
    my $what = "select i.issueid, i.text, c.commitmentid, c.text, 
                       to_char(c.fulfilldate, 'MM/DD/YYYY'), cat.description, 
                       s.description, u.firstname || ' ' || u.lastname, 
                       ur.firstname || ' ' || ur.lastname 
                from $SCHEMA.issue i, $SCHEMA.commitment c, 
                     $SCHEMA.category cat, $SCHEMA.status s, 
                     $SCHEMA.users u, $SCHEMA.commitmentrole cr, 
                     $SCHEMA.usernamecommitmentroles ur 
                where $filter cr.roleid=3 and ur.roleid=2 and 
                      ur.commitmentid=c.commitmentid and 
                      cr.usersid=u.usersid and 
                      c.commitmentid(+)=cr.commitmentid and 
                      c.issueid=i.issueid(+) and 
                      i.categoryid=cat.categoryid and c.statusid=s.statusid 
                $orderby";

    my $str = $dbh -> prepare ($what);
    $str -> execute;
    while (my @values = $str -> fetchrow_array) {
	my ($iid, $itext, $cid, $ctext, $ful, $cat, $stat, $doel, $mol) = @values;
	$ful = ($ful) ? $ful : "&nbsp;";
	my ($ll) = $dbh -> selectrow_array ("select u.firstname || ' ' || u.lastname from $SCHEMA.users u, $SCHEMA.commitment c where c.commitmentid = $cid and u.usersid=c.lleadid");
	print "<tr bgcolor=white><td width=70><font size=-1>$cat</td>\n";
	print "<td width=125><font size=-1><a href=\"javascript:DisplayIssue($iid);\">" . formatID2($iid, 'I') . "</a> - " . getDisplayString ($itext,45) . "</td>\n";
	print "<td width=125><font size=-1><a href=\"javascript:DisplayCommitment($cid);\">" . formatID2($cid, 'C') . "</a> - " . getDisplayString ($ctext, 45) . "</td>\n";
	print "<td width=80><font size=-1>$stat</td>\n";
	print "<td width=80><font size=-1>$ful</td>\n";
	print "<td width=90><font size=-1>$doel&nbsp;</td>\n";
	print "<td width=90><font size=-1>$mol&nbsp;</td>\n";
	print "<td width=90><font size=-1>$ll&nbsp;</td></tr>\n";
    }
    $str -> finish;
}
print "</table><br><br>\n";
print "</body>\n";
print "</html>\n";
&oncs_disconnect($dbh);

=pod
if ($sortorder eq 'categorydesc') {
    $orderby = 'ORDER BY cat.description DESC,c.commitdate';
}
if ($sortorder eq 'commitmentdesc') {
    $orderby = 'order by c.commitmentid desc'; 
}
if ($sortorder eq 'issuedesc') {
    $orderby = 'order by c.issueid desc, c.commitmentid';
}
if ($sortorder eq 'statusdesc') {
    $orderby = 'order by c.statusid desc, c.issueid, c.commitmentid'; 
}
if ($sortorder eq 'fulfilldesc') {
    $orderby = 'order by c.fulfilldate desc, c.issueid, c.commitmentid'; 
}
=cut
