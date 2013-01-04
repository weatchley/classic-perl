#!/usr/local/bin/newperl
#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
#
#
use integer;
use strict;
use DBI;
use CRD_Header qw(:Constants);
use DB_Utilities_Lib qw(:Functions);
use DBD::Oracle qw(:ora_types);
use Carp;
#
$| = 1;

my $dbh;
my $csr;
my $status;
my $sqlquery = "";
my $outputfile = "responses.txt";
my @values;
my $commentList = '';
my $lastID = 0;
my $count = 0;
my $len = 0;
my $scrcount = 0;
my $scrlen = 0;
my $idlist = '';
my $ID=0;

print "Content-type: text/html\n\n";
print "<html><head><title>Data Extraction</title></head><body>\n";
print "<h3>Working</h3><br><br>\n";

$dbh = &db_connect(server => 'ydoraprd.ymp.gov');
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
$dbh->{LongReadLen} = 10000000;


$sqlquery = "SELECT rv.lastsubmittedtext ";
$sqlquery .= "FROM eis.response_version rv ";
$sqlquery .= "WHERE rv.status < 10 AND rv.lastsubmittedtext IS NOT NULL";

$csr = $dbh->prepare($sqlquery);
$status = $csr->execute;

print "Count Responses<br>\n";
while (@values = $csr->fetchrow_array) {
    $count++;
    $len += length($values[0]);
}
close FH1;
$csr->finish;
print "Average length of responses is ($len/$count) " . ($len/$count) . "<br><br>\n";

$sqlquery = "SELECT responsetext ";
$sqlquery .= "FROM eis.summary_comment ";
$sqlquery .= "WHERE responsetext IS NOT NULL";

$csr = $dbh->prepare($sqlquery);
print stderr "\n$sqlquery\n\n";
$status = $csr->execute;

print "Count SCR's<br>\n";
while (@values = $csr->fetchrow_array) {
    $scrcount++;
    $scrlen += length($values[0]);
    $count++;
    $len += length($values[0]);
}
close FH1;
$csr->finish;

print "Average length of SCR responses is ($scrlen/$scrcount) " . ($scrlen/$scrcount) . "<br><br>\n";

print "Average length of all responses is ($len/$count) " . ($len/$count) . "<br>\n";


&db_disconnect($dbh);

print "<br><br><h3>Done</h3>\n";
print "</body></html>\n";