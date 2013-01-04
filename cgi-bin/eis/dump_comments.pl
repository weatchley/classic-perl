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
use UI_Widgets qw(:Functions);
use DBD::Oracle qw(:ora_types);
use Carp;

my $dbh;
my $csr;
my $status;
my $schema = $SCHEMA;
my $sqlquery = "SELECT c.document,c.commentnum,c.dupsimstatus,c.dupsimdocumentid,c.dupsimcommentid,c.summary,b.name,d.namestatus,cmtr.lastname,cmtr.firstname,cmtr.organization,cmtr.affiliation ";
$sqlquery .= "FROM $schema.comments c, $schema.document d, $schema.commentor cmtr, $schema.bin b ";
$sqlquery .= "WHERE c.document = d.id AND d.commentor=cmtr.id(+) AND c.bin=b.id ";
#$sqlquery .= "c.document >= 550000 AND c.document <= 559999";
$sqlquery .= "ORDER BY cmtr.lastname,cmtr.firstname,c.document,c.commentnum";
my $outputfile = "comments.txt";
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
print "<!-- $sqlquery -->\n";

$csr = $dbh->prepare($sqlquery);
$status = $csr->execute;

while (my($document,$commentnum,$dupsimstatus,$dupsimdocumentid,$dupsimcommentid,$summary,$binname,$namestatus,$lastname,$firstname,$organization,$affiliation) = $csr->fetchrow_array) {

    my $affiliationName = "";
    if ($namestatus == 2) {
        $lastname = "ANONYMOUS";
        $firstname = "";
    } elsif ($namestatus == 3) {
        $lastname = "ILLEGIBLE";
        $firstname = "";
    } else {
        $affiliationName = get_value($dbh,$schema,"commentor_affiliation","name","id=$affiliation");
    }
    print FH1 $lastname . "\t";
    print FH1 $firstname . "\t";
    print FH1 $organization . "\t";
    print FH1 $affiliationName . "\t";
    print FH1 $CRDType . lpadzero($document,6) . " / " . lpadzero($commentnum,4) . "\t";
    print FH1 $binname . "\t";
    print FH1 get_value($dbh, $schema, 'duplication_status', 'name', "id = $dupsimstatus") . "\t";
    print FH1 (($dupsimstatus != 1) ? $CRDType . lpadzero($dupsimdocumentid,6) . " / " . lpadzero($dupsimcommentid,4) : "") . "\t";
    print FH1 ((defined($summary)) ? "SCR" . lpadzero($summary,4) : "") . "\t";
    print FH1 " \n";
}
close FH1;
$csr->finish;
&db_disconnect($dbh);

print "<br><br><h2>Done</h2>\n";
print "</body></html>\n";
