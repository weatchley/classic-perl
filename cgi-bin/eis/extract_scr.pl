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
my $outputfile = "scrs.txt";
my @values;
my $commentList = '';
my $lastID = 0;
my $count = 0;
my $idlist = '';
my $ID=0;

print "Content-type: text/html\n\n";
print "<html><head><title>Data Extraction</title></head><body>\n";
print "<h3>Working</h3><br><br>\n";

$dbh = &db_connect(server => 'ydoraprd.ymp.gov');
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
$dbh->{LongReadLen} = 10000000;


$sqlquery = "SELECT scr.id, rm.text ";
$sqlquery .= "FROM eis.summary_comment scr,eis.summary_remark rm ";
$sqlquery .= "WHERE scr.id = rm.summarycomment ";
$sqlquery .= "ORDER BY scr.id";

$csr = $dbh->prepare($sqlquery);
$status = $csr->execute;

print "Search Remarks<br>\n";
while (@values = $csr->fetchrow_array) {
        if ($values[1] =~ /RESXREF:/) {
            $ID = $values[0];
            $idlist .= (($count>0)? ',' : '') . "$ID";
            $count++;
            print ". ";
        }
}
close FH1;
$csr->finish;
print "Found $count<br>\n";

$sqlquery = "SELECT 0, scr.id,scr.commenttext,scr.responsetext ";
$sqlquery .= "FROM eis.summary_comment scr ";
$sqlquery .= "WHERE (scr.id IN ($idlist)) ";
$sqlquery .= "ORDER BY scr.id";
#print stderr "\n$sqlquery\n\n";
if (!(open (FH1, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$CRDFullTempReportPath/$outputfile --protection=0777"))) {
    die "Unable to open file $CRDFullTempReportPath/$outputfile\n";
}
###open (FH1, ">$outputfile");

$csr = $dbh->prepare($sqlquery);
$status = $csr->execute;

$count=0;
print "Build output<br>\n";
while (@values = $csr->fetchrow_array) {
    if ($lastID != $values[1]) {
            $values[2] =~ s/\n/  /g;
            $values[2] =~ s/\r/  /g;
            $values[2] =~ s/\t/  /g;
            $values[3] =~ s/\n/  /g;
            $values[3] =~ s/\r/  /g;
            $values[3] =~ s/\t/  /g;
            print ". ";
            print FH1 $values[0] . "\t" . $values[1] . "\t" . $values[2] . "\t" . $values[3] . "\n";
            $count++;
    }
    $lastID = $values[1];
}
close FH1;
$csr->finish;
print "Found $count<br>\n";
&db_disconnect($dbh);

print "<br><br><h3>Done</h3>\n";
print "</body></html>\n";