#!/usr/local/bin/newperl -w


use strict;
use integer;
use CRD_Header qw(:Constants);
use DB_Utilities_Lib qw(:Functions);
use DBI;
use Time::Local;
use DBD::Oracle qw(:ora_types);
use Carp;

my $userid;
my $error = "";
my $dbh;
my $total_docs = 0;
my $total_comments = 0;
my $doc_cnt = 0;
my $cmt_cnt = 0;
my $week_counter = 40;
my $commentnum = 0;
my $interval = 60*60*24*7;
my $display_week = timelocal(0,0,0,26,6,1999);
my $lastID = 0;
my $year = 1999;
my ($s,$min,$h,$d,$m,$y,$wd,$yd,$isdat,$week,$ID,$doc_yr,@get_dates,$sth,$strSQL);

#$ENV{'CRDServer'} = "ydoracle";
$dbh = &db_connect();

$strSQL = "select to_char(datereceived,'IW'), d.ID, commentnum, to_char(datereceived, 'YYYY')
from eis.document d, eis.comments c
where d.id = c.document(+) order by d.datereceived asc, d.ID, c.document, commentnum";

print "Content-type: text/html\n\n";

print "<table border=0 width=300 cellpadding=0 cellspacing=0 align=left>\n";
print "<tr><td colspan=3><H4 align=center>EIS Documents and Comments<BR>Received by Week</H4></td></tr>\n";
print "<tr><td width=100 align=right>Week Of</td><td width=100 align=right># Documents</td><td width=100 align=right># Comments</td></tr>\n";
print "<tr><td colspan=3 align=right>---------------------------------------------</td></tr>\n";

$sth = $dbh->prepare($strSQL);

$sth->execute();

while (@get_dates = $sth->fetchrow_array) {
	$week = $get_dates[0] + 10;
	$ID = $get_dates[1];
	$commentnum = $get_dates[2];
	$doc_yr = $get_dates[3];
	

	if ($week ne $week_counter) {
		($s,$min,$h,$d,$m,$y,$wd,$yd,$isdat) = localtime($display_week);
		$y = $y + 1900;
		$m = $m + 1;
		printf "<tr><td align=right>%2s/%2d/%2s</td><td align=right>%10s</td><td align=right>%10s</td></tr>\n", $m,$d,$y,$doc_cnt,$cmt_cnt;
		while ($week_counter lt $week) {
			$week_counter ++;
			$display_week += $interval;
		}
		
		if ($year ne $doc_yr) {
			$week_counter = 11;
			$year = 2000;
			$display_week += $interval;
		}
		
		$cmt_cnt = 0;
		$doc_cnt = 0;
	}
	
	if ($ID != $lastID) {
		$doc_cnt ++;
		$total_docs ++;
		$lastID = $ID;
	}
	
	if ($commentnum) {
		$cmt_cnt ++;
		$total_comments ++;
	}
}

($s,$min,$h,$d,$m,$y,$wd,$yd,$isdat) = localtime($display_week);
$y = $y + 1900;
$m = $m + 1;
printf "<tr><td align=right>%2s/%2d/%2s</td><td align=right>%10s</td><td align=right>%10s</td>\n</tr>\n", $m,$d,$y,$doc_cnt,$cmt_cnt;

$sth->finish; 
$dbh->disconnect();

printf "<tr><td align=right>Totals:</td><td align=right>%10s</td><td align=right>%15s</td></tr>\n",$total_docs,$total_comments;
printf "</table>\n";


