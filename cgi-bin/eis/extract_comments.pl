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
my $outputfile = "comments.txt";
my @values;
my $commentList = '';
my $lastID = 0;

print "Content-type: text/html\n\n";
print "<html><head><title>Data Extraction</title></head><body>\n";
print "<h3>Working</h3><br><br>\n";

#$dbh = DBI->connect('dbi:Oracle:ydoracle','scott','5happy5', { RaiseError => 1, AutoCommit => 0 });
$dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
$dbh->{LongReadLen} = 10000000;


$sqlquery = "SELECT com.document,com.commentnum,com.text, rm.text FROM eis.comments com, eis.comments_remark rm WHERE (com.document=rm.document AND com.commentnum=rm.commentnum) AND com.dupsimstatus=1 ORDER BY document,commentnum";
#print stderr "\n$sqlquery\n\n";
if (!(open (FH1, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$CRDFullTempReportPath/$outputfile --protection=0777"))) {
    die "Unable to open file $CRDFullTempReportPath/$outputfile\n";
}
#open (FH1, ">$outputfile");

$csr = $dbh->prepare($sqlquery);
$status = $csr->execute;

while (@values = $csr->fetchrow_array) {
    if ($lastID != $values[0]*10000 + $values[1]) {
        $lastID = $values[0]*10000 + $values[1];
        if ($values[3] =~ /COMXREF:/) {
            $values[2] =~ s/\n/  /g;
            $values[2] =~ s/\r/  /g;
            $values[2] =~ s/\t/  /g;
            print ". ";
            print FH1 $values[0] . "\t" . $values[1] . "\t" . $values[2] . "\n";
        }
    }
}
close FH1;
$csr->finish;
&db_disconnect($dbh);

print "<br><br><h3>Done</h3>\n";
print "</body></html>\n";