#!/usr/local/bin/newperl -w
#
# CGI entry page for SCR's
#
# $Source:$
# $Revision:$
# $Date:$
# $Author:$
# $Locker:$
# $Log:$
#
#

use strict;
use DB_scm qw(:Functions);


my $dbh = &db_connect(server => "ydoradev");
#&createProject(schema => "JOHNSONC", dbh => $dbh, name => "Test", acronym => "TST", description => "This is a test entry.", projectManagerId => 1008);
#&createSequence(schema => "JOHNSONC", dbh => $dbh, acronym => "TST");
#my %hash = &getUsersByPrivilege(schema => "JOHNSONC", dbh => $dbh, privilegeId => 10);
#&updateProject(schema => "JOHNSONC", dbh => $dbh, projectId => 1, name => "Test4", acronym => "TST^&", description => "Test the update functionality", projectManagerId => 1002);
#my %hash = &getItemSource(schema => "JOHNSONC", dbh => $dbh);
#foreach my $key (keys %hash) {
#	print "$hash{$key}{source}\n";
#}
#my %hash = &getProjects(schema => "JOHNSONC", dbh => $dbh);
#my %hash = &getProjects(schema => "JOHNSONC", dbh => $dbh);
#foreach my $key (keys %hash) {
#	print "This is the entry for: $key\n"; 
#	print "$hash{$key}{'name'}\n";
#	print "$hash{$key}{'acronym'}\n";	
#	print "$hash{$key}{'description'}\n";
#	print "$hash{$key}{'creationDate'}\n";
#	print "$hash{$key}{'managername'}\n";
#}
my %hash = &getUsers("JOHNSONC", $dbh, 8);
foreach my $key (keys %hash) {
	print "This is the entry for: $key\n"; 
	print "$hash{$key}{'firstname'}\n";
	print "$hash{$key}{'lastname'}\n";
	print "$hash{$key}{'username'}\n";	
	print "$hash{$key}{'email'}\n";
	print "$hash{$key}{'areacode'}\n";
	print "$hash{$key}{'phone'}\n";
	print "$hash{$key}{'company'}\n";
	print "$hash{$key}{'location'}\n";
}
#print "$$hashRef{$key}{'name'}\n";
#for (my $i = 1; $i <= 3; $i++) {
#	&createConfigItem(schema => "JOHNSONC", dbh => $dbh, scrId => 0, name => "test4.pl", sourceId => 1, typeId => 1, 
#	changeDescription => "This is a test 4 description for this configuration item",
#	projectId => 2, developerId => 1008);
#}
#&checkOutConfigItem(schema => "JOHNSONC", dbh => $dbh, configId => 1, userId => 1007);
#&checkInConfigItem(schema => "JOHNSONC", dbh => $dbh, configId => 1, userId => 1008, scrId => 55, 
#description => "This is to test the checkin functionality");

my %items = ( 
				1 => {
							'majorRev' => 4,
							'minorRev' => 1,
					  },
#			   2 => {
#							'majorRev' => 2,
#							'minorRev' => 2,
#					  },
#				3 => {
#							'majorRev' => 2,
#							'minorRev' => 3,
#					  },
				6 => {
							'majorRev' => 1,
							'minorRev' => 2,
					  },
			);
#eval {
#&createSequence(dbh => $dbh, acronym => 'TST');
#&createProduct(schema => "JOHNSONC", dbh => $dbh, userId => 8, acronym => "TST", name => "Test Product", projectId => 1, approveDate => "06/25/2002", description => "This is to test the creating of a"
#. " product", items => \%items);
#};
#if ($@) {
#	$errorString = &errorMessage($dbh, "JOHNSONC", 8, "JOHNSONC", "Testing create product", "$@");
#}
#print "$errorString\n";
#print &getSysdate(schema => "JOHNSONC", dbh => $dbh) . "\n";
#my %hash = &getApprovedConfigItems(dbh => $dbh, schema => "JOHNSONC", projectId => 2);
#foreach my $key (sort {((($hash{$a}{scr} <=> $hash{$b}{scr} || $hash{$a}{majorRev} <=> $hash{$b}{majorRev}) || lc($hash{$a}{name}) cmp lc($hash{$b}{name})) || $hash{$a}{minorRev} <=> $hash{$b}{minorRev})} keys %hash) {
#	print $key . "\n";
#	print "SCR Id = $hash{$key}{scr}\n";
#	print "Name = $hash{$key}{name}\n";
#	print "Desc = $hash{$key}{description}\n";
#	print "Major Rev = $hash{$key}{majorRev}\n";
#	print "Minor Rev = $hash{$key}{minorRev}\n";
#	print "status = $hash{$key}{status}\n";
#	if (defined($hash{$key}{revDate})) {
#		print "$hash{$key}{revDate}\n";
#	}
#	if (defined($hash{$key}{approvalDate})) {
#		print " $hash{$key}{approvalDate}\n";
#	}
#	print "\n##########################################\n";
#}
#&updateBaseline(schema => "JOHNSONC", dbh => $dbh, config => \%items);
#my %hash = &getConfigItems(dbh => $dbh, schema => "JOHNSONC", projectId => 2, option => "IN_BASELINE", userId => 1008);

#my %hash = &getBaselineItems(dbh => $dbh, schema => "SCM", projectId => 2, userId => 1008, option => "OLD_PRODUCT_ITEMS");
 
#foreach my $key (sort {((($hash{$a}{scr} <=> $hash{$b}{scr} || $hash{$a}{majorVersion} <=> $hash{$b}{majorVersion}) || lc($hash{$a}{name}) cmp lc($hash{$b}{name})) || $hash{$a}{minorVersion} <=> $hash{$b}{minorVersion})} keys %hash) {
#		print "ID = $key\n";
#		print "SCR Id = $hash{$key}{scr}\n";
#		print "Name = $hash{$key}{name}\n";
#		print "Desc = $hash{$key}{description}\n";
#		print "Major Rev = $hash{$key}{majorVersion}\n";
#		print "Minor Rev = $hash{$key}{minorVersion}\n";
#		print "status = $hash{$key}{status}\n";
#		print "Baseline Date = $hash{$key}{baselineDate}\n";
#		print "Is new = $hash{$key}{'isnew'}\n\n";		
#	if (defined($hash{$key}{revDate})) {
#		print "$hash{$key}{revDate}\n";
#	}
#	if (defined($hash{$key}{approvalDate})) {
#		print " $hash{$key}{approvalDate}\n";
#	}
}
#my %hash = &getSCR(schema => "JOHNSONC", dbh => $dbh, projectId => 2, option => "ACCEPTED");
#foreach my $key (keys %hash) {
#	print "ID = $key\n";
#	print "SCR Id = $hash{$key}{scr}\n";
#	print "Name = $hash{$key}{name}\n";
#	print "Desc = $hash{$key}{description}\n";
#}
&db_disconnect($dbh);
exit;
#($schema, $dbh, $projectId, $name, $acronym, $desc, $userid, $projectManagerId)