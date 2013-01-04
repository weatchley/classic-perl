#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/viewdoc.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2003/03/11 23:51:54 $
#
# $Author: munroeb $
#
# $Locker:  $

use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use Carp;
use CGI;

my $q = new CGI;
my $proc_id = $q->param('id');

if (!$proc_id) {
	$proc_id = 2;
}

my $dbh = db_connect();

$dbh->{LongReadLen} = 100000000;

my $sql = "select id, signed_image from pcl.procedure_version where procedureid = $proc_id ".
"and signed_image is not NULL ".
"and major_version = (select max(major_version) from pcl.procedure_version where procedureid = $proc_id) ".
"and minor_version = (select max(minor_version) from pcl.procedure_version where major_version = ".
"(select max(major_version) from pcl.procedure_version where procedureid = $proc_id))";

my $sth = $dbh->prepare($sql);
$sth->execute();
my ($id,$signed_image) = $sth->fetchrow_array();

if ($signed_image) {
	my $output = "Content-type: application/pdf\n\n".$signed_image;
	print $output;
} else {
	print "Content-type: text/html\n\n";
	print "Sorry, PDF document for procedure id = $proc_id not available\n";
}

$sth->finish();
$dbh->disconnect();