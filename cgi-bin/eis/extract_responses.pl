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
my $idlist = '';
my $ID=0;

print "Content-type: text/html\n\n";
print "<html><head><title>Data Extraction</title></head><body>\n";
print "<h3>Working</h3><br><br>\n";

#$dbh = DBI->connect('dbi:Oracle:ydoraprd.ymp.gov','scott','5happy5', { RaiseError => 1, AutoCommit => 0 });
$dbh = &db_connect(server => 'ydoraprd.ymp.gov');
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
$dbh->{LongReadLen} = 10000000;


$sqlquery = "SELECT rm.document, rm.commentnum,rm.text ";
$sqlquery .= "FROM eis.comments_remark rm ";
$sqlquery .= "ORDER BY rm.document,rm.commentnum";

$csr = $dbh->prepare($sqlquery);
$status = $csr->execute;

print "Search Remarks<br>\n";
while (@values = $csr->fetchrow_array) {
        if ($values[2] =~ /RESXREF:/) {
            $ID = $values[0]*10000 + $values[1];
            $idlist .= (($count>0)? ',' : '') . "$ID";
            $count++;
            print ". ";
        }
}
close FH1;
$csr->finish;
print "Found $count<br>\n";

$sqlquery = "SELECT rv.document, rv.commentnum, rv.version, rv.status, rv.originaltext,rv.lastsubmittedtext,com.text ";
$sqlquery .= "FROM eis.response_version rv, eis.comments com ";
$sqlquery .= "WHERE (rv.document=com.document AND rv.commentnum=com.commentnum) AND ((com.document*10000 + com.commentnum) IN ($idlist)) ";
$sqlquery .= "AND rv.status IN (1,2,3,4,5,6,7,8,9,14,15)  ORDER BY com.document,com.commentnum";
#print stderr "\n$sqlquery\n\n";
if (!(open (FH1, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$CRDFullTempReportPath/$outputfile --protection=0777"))) {
    die "Unable to open file $CRDFullTempReportPath/$outputfile\n";
}
#open (FH1, ">$outputfile");

$csr = $dbh->prepare($sqlquery);
$status = $csr->execute;

$count=0;
print "Build output<br>\n";
while (@values = $csr->fetchrow_array) {
    if ($lastID != $values[0]*10000 + $values[1]) {
            $values[5] =~ s/\n/  /g;
            $values[5] =~ s/\r/  /g;
            $values[5] =~ s/\t/  /g;
            $values[6] =~ s/\n/  /g;
            $values[6] =~ s/\r/  /g;
            $values[6] =~ s/\t/  /g;
            print ". ";
            print FH1 $values[0] . "\t" . $values[1] . "\t" . $values[6] . "\t" . $values[5] . "\n";
            $count++;
    }
    $lastID = $values[0]*10000 + $values[1];
}
close FH1;
$csr->finish;
print "Found $count<br>\n";
&db_disconnect($dbh);

print "<br><br><h3>Done</h3>\n";
print "</body></html>\n";