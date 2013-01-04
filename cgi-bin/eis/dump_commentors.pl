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

my $dbh;
my $csr;
my $status;
my $schema = $SCHEMA;
my $sqlquery = "SELECT * FROM $CRDType.commentor ORDER BY lastname,firstname";
#my $sqlquery = "SELECT * FROM $CRDType.commentor WHERE id IN (SELECT commentor FROM $CRDType.document WHERE namestatus=1 AND TO_CHAR(datereceived, 'YYYYMMDD') >= '20020124') ORDER BY lastname,firstname";
my $outputfile = "commentors.txt";
my @values;
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

#$dbh = DBI->connect('dbi:Oracle:ydoracle','scott','5happy5', { RaiseError => 1, AutoCommit => 0 });
$dbh = &db_connect(server => 'ydoraprd.ymp.gov');
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
$dbh->{LongReadLen} = 10000000;

if (!(open (FH1, "| ./File_Utilities.pl --command=writeFile --fullFilePath=$CRDFullTempReportPath/$outputfile --protection=0777"))) {
    die "Unable to open file $CRDFullTempReportPath/$outputfile\n";
}
#open (FH1, ">$outputfile");

print "content-type: text/html\n\n";
print "<html><body>\n";
print "<h2>Working</h2><br>$schema - $form\n";

$csr = $dbh->prepare($sqlquery);
$status = $csr->execute;

while (@values = $csr->fetchrow_array) {
    for my $key (0 .. 20) {
        if ($key < 20) {
            print FH1 $values[$key] . "\t";
        } else {
            print FH1 get_value($dbh, "$CRDType", 'commentor_affiliation', 'name', "id = $values[$key]");
        }
    }
    print FH1 "\n";
}
close FH1;
$csr->finish;
&db_disconnect($dbh);

print "<br><br><h2>Done</h2>\n";
print "</body></html>\n";
