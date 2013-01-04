#!/usr/local/bin/newperl -w


use DB_scm qw(:Functions);
use strict;

my $sql = "SELECT * FROM johnsonc.revisions";
my $dbh = &db_test_connect(server => "ydoradev");
$dbh->{LongTruncOk} = 1;
my $sth = $dbh->prepare($sql);
$sth->execute;

while (my @row = $sth->fetchrow_array) {
	my $sql1 = "INSERT INTO johnsonc.item_version (item_id, major_version, minor_version, revision_date, status, responsible_developer_id, approval_date, change_description, locker_id, scr_id) VALUES ($row[0], $row[1], $row[2], '$row[3]', $row[4], $row[5], '$row[6]', '$row[7]', NULL, $row[9])";
	print "$sql1\n";
	my $sth1 = $dbh->prepare($sql1);
	$sth1->execute;
}
$dbh->{LongTruncOk} = 0;
db_disconnect($dbh);