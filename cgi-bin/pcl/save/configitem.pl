#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/scm/perl/RCS/configitem.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2002/11/05 18:21:26 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: configitem.pl,v $
# Revision 1.2  2002/11/05 18:21:26  starkeyj
# deprecated
#
# Revision 1.1  2002/09/17 20:33:17  starkeyj
# Initial revision
#
#
#
#


use strict;
use integer;
use SCM_Header qw(:Constants);
use CGI qw(param);
use DB_scm qw(:Functions);
use UI_Widgets qw(:Functions);
use UI_Configitem qw(:Functions);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

my $scmcgi = new CGI;
my $schema = (defined($scmcgi->param("schema"))) ? $scmcgi->param("schema") : $ENV{'SCHEMA'};
#print STDERR "$schema\n";
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $urllocation;
my $command = (defined ($scmcgi -> param("command"))) ? $scmcgi -> param("command") : "";
my $username = (defined($scmcgi->param("username"))) ? $scmcgi->param("username") : "";
my $password = (defined($scmcgi->param("password"))) ? $scmcgi->param("password") : "";
my $userid = (defined($scmcgi->param("userid"))) ? $scmcgi->param("userid") : "";
my $error = "";
my $origschema = (defined($scmcgi->param("origschema"))) ? $scmcgi->param("origschema") : "SCM"; 

my $projectID = defined($scmcgi->param("projectID")) ? $scmcgi->param("projectID") : 0;
#my ($projectID,$projectName,$managerName,$acronym,$projectDesc) = split /,/, $project;
#&checkLogin ($username, $userid, $schema);
my $dbh = &db_connect(server => "ydoradev");
my %projectlist = &getProjects(schema => "SCM", dbh => $dbh);
my $projectName = $projectlist{$projectID}{'name'};
my $managerID = $projectlist{$projectID}{'managerID'};
my $acronym = $projectlist{$projectID}{'acronym'};

#########
if ($command eq 'checkin_item') {
	print &itemFormHeader($userid,$username,$schema,$projectID,$projectName);
	print &checkinBody($dbh,$projectID,$projectName,$userid,$username);
}
#########
elsif ($command eq 'checkout_item') {
	print &itemFormHeader($userid,$username,$schema,$projectID,$projectName);
	print &checkoutBody($dbh,$projectID);
}
#########
elsif ($command eq 'create_item') {
	print &itemFormHeader($userid,$username,$schema,$projectID,$projectName);
	print &createItemBody($dbh);
}
#########
elsif ($command eq 'db_create_item') {
	my $sourceId = (defined ($scmcgi -> param("source"))) ? $scmcgi -> param("source") : "";
	my $typeId = (defined ($scmcgi -> param("type"))) ? $scmcgi -> param("type") : "";
	my $itemName = defined($scmcgi->param("itemname")) ? $scmcgi->param("itemname") : "";
	my $scrID = defined($scmcgi->param("scrID")) ? $scmcgi->param("scrID") : 0 ;
	my $projectID = defined($scmcgi->param("projectID")) ? $scmcgi->param("projectID") : 0;
	&createConfigItem(dbh => $dbh, sourceId => $sourceId, typeId => $typeId, schema => 'SCM', name => $itemName, developerId => $userid, projectId => $projectID, scrId => $scrID);
}
#########
elsif ($command eq 'db_checkout_item') {
	my $scrID = defined($scmcgi->param("scrlist")) ? $scmcgi->param("scrlist") : 0 ;
	my $databaseFileid = defined($scmcgi->param("databasefile")) ? $scmcgi->param("databasefile") : 0 ;
	my @checkoutfiles = (defined ($scmcgi -> param("checkoutfiles"))) ? $scmcgi -> param("checkoutfiles") : "";
	my $checkoutdate = getSysdate(dbh => $dbh);
	foreach my $fileid (@checkoutfiles) {
		&checkOutConfigItem(dbh => $dbh, schema => 'SCM', configId => $fileid, scrId => $scrID, userId => $userid);
	}
	if ($databaseFileid) {
		&checkOutConfigItem(dbh => $dbh, schema => 'SCM', configId => $databaseFileid, scrId => $scrID, userId => $userid);
	}
	print &redirect('checkout');
}
#########
elsif ($command eq 'db_checkin_item') {
	my $projectID = defined($scmcgi->param("projectID")) ? $scmcgi->param("projectID") : 0;
	my $fileid = defined($scmcgi->param("fileid")) ? $scmcgi->param("fileid") : 0 ;
	my $desc = defined($scmcgi->param("changes")) ? $scmcgi->param("changes") : 0 ;
	&checkInConfigItem(dbh => $dbh, schema => 'SCM', configId => $fileid, userId => $userid, description => $desc);
	print &redirect('checkin');
}

&db_disconnect($dbh);
