#!/usr/local/bin/newperl -w


use strict;
use integer;
use CRD_Header qw(:Constants);
use DB_Utilities_Lib qw(:Functions);
use UI_Widgets qw(:Functions);

my $dbh;
my $total_docs = 0;
my $total_comments = 0;
my $doc_cnt = 0;
my $cmt_cnt = 0;
my $dupID;
my $ID;
my $formatID;
my $nameID;
my $dupName;
my $name;
my $commentorname;
my $org;
my $affiliation;
my $strSQL;
my $strSQL2;
my $strSQL3;
my $sth;
my $sth2;
my $sth3;
my @get_dups;
my @get_originals;
my @get_commentor;

#$dbh = &db_connect();
$dbh = &db_connect('server' =>"ydoraprd.ymp.gov");

$strSQL = "select d.id, d.dupsimid, t.name from eis.document d, eis.document_type t ";
$strSQL .= "where dupsimstatus = 2 and d.documenttype = t.id ";
$strSQL .= "order by id asc, dupsimid";

print "Content-type: text/html\n\n";

print "<HTML>\n<body>\n";
print "<table border=0 cellpadding=0 cellspacing=0 align=left>\n";
print "<tr><td colspan=4><H4 align=center>DEIS Duplicate Documents</H4></td></tr>\n";
print "<tr><td align=left>Duplicate<BR>Document&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=left>Document Type<BR>and Original Document/Commentor Information</td><td colspan=2>&nbsp;</td></tr>\n";
print "<tr><td colspan=4 align=left>----------------------------------------";
print "----------------------------------------------------------------------------------</td></tr>\n";

$sth = $dbh->prepare($strSQL);

$sth->execute();

while (@get_dups = $sth->fetchrow_array) {
	$dupID = $get_dups[0];
	$ID = $get_dups[1];
	$dupName = $get_dups[2];
	$total_docs++;

	$formatID = &formatID("EIS", 6, $dupID);
	print "<tr><td>$formatID</td><td colspan=3 align=left>$dupName</td></tr>\n";
	
	$strSQL2 = "select t.name, d.commentor from eis.document d, eis.document_type t, ";
	$strSQL2 .= "eis.comments c where d.id = $ID and d.documenttype = t.id and d.id = c.document";
	
	$sth2 = $dbh->prepare($strSQL2);
	
	$sth2->execute();
	while (@get_originals = $sth2->fetchrow_array) {
		$name = $get_originals[0];
		$nameID = $get_originals[1];
		$cmt_cnt++;
		$total_comments++;
	}
	
	
	$formatID = &formatID("EIS", 6, $ID);
	print "<tr><td>&nbsp;</td><td>Original: $formatID</td><td>$name</td><td>$cmt_cnt &nbsp comment(s)</td></tr>\n";
	$cmt_cnt = 0;
	$sth2->finish;
	
	$strSQL3 = "select distinct firstname || ' ' || lastname as fullname, organization, ca.name ";
	$strSQL3 .= "from eis.comments c, eis.commentor co, eis.commentor_affiliation ca ";
	$strSQL3 .= "where $ID = c.document and $nameID = co.id and co.affiliation = ca.id";

	$sth3 = $dbh->prepare($strSQL3);

	$sth3->execute();
	while (@get_commentor = $sth3->fetchrow_array) {
		$commentorname = $get_commentor[0];
		$org = $get_commentor[1];
		$affiliation = $get_commentor[2];

		print "<tr><td>&nbsp;</td><td colspan=3 align=left>Commentor:&nbsp;$commentorname</td></tr>\n";
		print "<tr><td>&nbsp;</td><td colspan=3 align=left>Organization:&nbsp;$org</td></tr>\n";
		print "<tr><td>&nbsp;</td><td colspan=3 align=left>Affiliation:&nbsp;$affiliation</td></tr>\n";
	}
	$sth3->finish;
	print "<tr><td colspan=4>&nbsp;</td></tr>\n";
}

print "<tr><td colspan=4>&nbsp;</td></tr>\n";	
print "<tr><td colspan=4 align = left><b>Total duplicate documents: &nbsp; $total_docs</b></td></tr>\n";
print "<tr><td colspan=4 align = left><b>Total comments from originals of the duplicate documents: &nbsp; $total_comments</b></td></tr>\n";
print "</table>\n";
print "</body>\n</HTML>";

$sth->finish; 
$dbh->disconnect();




