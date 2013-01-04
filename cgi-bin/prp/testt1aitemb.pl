#!/usr/local/bin/newperl -w

use strict;
use integer;
use DBShared;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

    my $warn = $^W;
    $^W=0;
my $scrcgi = new CGI;
    $^W=$warn;
my $schema = (defined($scrcgi->param("schema"))) ? $scrcgi->param("schema") : $ENV{'SCHEMA'};
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $urllocation;
my $command = (defined ($scrcgi -> param("command"))) ? $scrcgi -> param("command") : "write_request";
my $username = (defined($scrcgi->param("loginusername"))) ? $scrcgi->param("loginusername") : "";
my $password = (defined($scrcgi->param("password"))) ? $scrcgi->param("password") : "";
my $userid = (defined($scrcgi->param("loginusersid"))) ? $scrcgi->param("loginusersid") : "";
my $error = "";
my $dbh = db_connect();

print $scrcgi->header('text/html');
print "<html>\n<head>\n";
print "<meta http-equiv=expires content=now>\n";
print "<title>Data dump</title>\n";
print "</head>\n";

print "<body background=#eeeeee text=#002299 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

$dbh->{LongTruncOk} = 0;
$dbh->{LongReadLen} = 10000;


my $select = $dbh -> prepare ("select id, table1aid, ocrwmposition, ocrwmjustification from sourcerequirement where ocrwmposition like '%Item B%' and id not in (348, 2193) order by id");
$select -> execute;

my $count = 0;
while (my ($id, $t1aid, $pos, $just) = $select -> fetchrow_array) {
    $count++;
    $t1aid = 3;
    my $update = "update sourcerequirement set table1aid = 3, ocrwmposition = NULL, ocrwmjustification = NULL where id = $id";
    my $insert = "insert into requirementtable1a (requirementid, table1aid) values ($id, $t1aid)";
    print "$count<br>$id<br>Position: $pos<br>Justification: $just<br>$insert<br>$update<br><br>\n";
    my $doinsert = $dbh -> do ($insert);
    my $doupdate = $dbh -> do ($update);
}
$select -> finish;

print "</body>\n</html>\n";
my $stat = db_disconnect($dbh);



