#!/usr/local/bin/perl -w


use DB_scm qw(:Functions);
use strict;
use DBI;
use DBD::Oracle qw(:ora_types);


my $dbh;
$dbh = &db_connect();
$dbh->{LongReadLen} = 1000000000;

my $sth = $dbh->prepare("SELECT * FROM SCM.meetings");
$sth->execute;
#my ($sccb, $date, $time, $room, $board, $alt, $guests, $attend, $absent, $agenda, $minutes, $id);
while (my ($sccb, $date, $time, $room, $board, $alt, $guests, $attend, $absent, $agenda, $minutes, $id) = $sth->fetchrow_array) {
	$time =~ /(\d{1,2}\:[3|0]0\s[a|p]?m?)\s?\-?\s?(\d{1,2}\:[3|0]0\s[a|p]m)?/;
	my $start = $1;
	my $end = defined($2) ? $2 : "";
	
	my $invitees = "Board: $board";
	$invitees .= " Alternates: $alt" if (defined($alt) && $alt gt "");
	$invitees .= " Guests: $guests" if (defined($guests) && $guests gt "");
	$invitees = $dbh->quote($invitees);
	$agenda = $dbh->quote($agenda);
	$attend = $dbh->quote($attend);
	$room = $dbh->quote($room);
	my $sql = "INSERT INTO SCM.temp_meetings (room, projectid, mtgdate, mtgtype, start_time, end_time, invitees, attendees, agenda"; #, agenda";
    my $val = " VALUES ($room, $id, '$date', 1, '$start', '$end', $invitees, $attend, :agenda"; #, :agenda";
	if (defined($minutes) && $minutes gt "") {
		$minutes = $dbh->quote($minutes);
		$sql .= ", minutes";
		$val .= ", :minutes";
	}
	$sql = $sql . ")" . $val . ")";
	my $sth1 = $dbh->prepare($sql);
	print "$sql\n";
	$sth1->bind_param(":minutes", $minutes, { ora_type => ORA_CLOB, ora_field => 'minutes' }) if (defined($minutes) && $minutes gt "");
	$sth1->bind_param(":agenda", $agenda, { ora_type => ORA_CLOB, ora_field => 'agenda' });	
	$sth1->execute;
}

&db_disconnect($dbh);
exit();
