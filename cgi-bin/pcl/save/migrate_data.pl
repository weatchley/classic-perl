#!/usr/local/bin/newperl -w

use DBI;
use DBD::Oracle qw(:ora_types);
use strict;

my $dbh = DBI->connect("dbi:Oracle:ydoradev","johnsonc","", { RaiseError => 1, AutoCommit => 0 });
$dbh->{LongReadLen}=1000000;
my $sql = "SELECT * FROM scm.users";

my $sth = $dbh->prepare($sql);
$sth->execute;
while (my @vals = $sth->fetchrow_array) {
	my $sql1 = "INSERT INTO johnsonc.users (id, username, firstname, lastname, organization, areacode, "
	           . "phonenumber, password, email, isactive) VALUES ($vals[0], '$vals[2]', '$vals[3]', "
              . "'$vals[4]', '$vals[5]', $vals[6], $vals[7], '$vals[9]', '$vals[10]', 'T')";
   print "$sql1\n";
	$dbh->do($sql1);
}
$sql = "SELECT * FROM scm.user_privilege";
$sth = $dbh->prepare($sql);
$sth->execute;

while (my @vals = $sth->fetchrow_array) {
	my $sql1 = "INSERT INTO johnsonc.user_privilege (userid, privilege) VALUES ($vals[0], $vals[1])";
	$dbh->do($sql1);
}
my $buffer;
my $rationale;
my $desc;
$sql = "SELECT * FROM scm.scrrequest";
my $sth = $dbh->prepare($sql);
$sth->execute;
while (my @vals = $sth->fetchrow_array) {
	$sql = "INSERT INTO johnsonc.scrrequest (id, datesubmitted, description, rationale, submittedby, status, priority, "
	       . "product) VALUES ($vals[0], '$vals[1]', :description_clob, :rationale_clob, $vals[4], $vals[5], $vals[6], "
	       . "$vals[7])";
	print "$sql\n";
	my $sth1 = $dbh->prepare($sql);
	while (read($vals[3], $buffer, 16536)) {
			$rationale .= $buffer;
   }
   while (read($vals[2], $buffer, 16536)) {
			$desc .= $buffer;
   }
	$sth1->bind_param(":description_clob", $vals[2], {ora_type => ORA_CLOB, ora_field => 'description' });
	$sth1->bind_param(":rationale_clob", $vals[3], {ora_type => ORA_CLOB, ora_field => 'rationale' });
	$sth1->execute;
}
$dbh->disconnect;
