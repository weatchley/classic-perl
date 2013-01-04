#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/baseline.pl,v $
#
# $Revision: 1.8 $
#
# $Date: 2003/03/09 17:08:37 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: baseline.pl,v $
# Revision 1.8  2003/03/09 17:08:37  starkeyj
# modified to include session id parameters
#
# Revision 1.7  2002/11/08 18:03:55  starkeyj
# added 'use UI_scm.pm'
#
# Revision 1.6  2002/11/07 15:52:46  starkeyj
# modified to pass the CGI reference instead of the username, userid, and schema variables to checkLogin
#
# Revision 1.5  2002/11/06 22:29:53  starkeyj
# modified to handle baseline version numbers
#
# Revision 1.4  2002/10/31 17:54:49  atchleyb
# reenabled checkLogin
#
# Revision 1.3  2002/10/31 17:03:26  starkeyj
# modified functions to display project info on baseline headers
#
# Revision 1.1  2002/09/27 00:14:08  starkeyj
# Initial revision
#
#
#
#

use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UIBaseline qw(:Functions);
use DBBaseline qw(:Functions);
use UI_Widgets qw(:Functions);
use CGI;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
$dbh = &db_connect();
$dbh -> {LongReadLen} = 1000000;

my %settings = getInitialValues(dbh => $dbh);

my $schema = $settings{schema};
my $command = $settings{command};
my $username = $settings{username};
my $userid = $settings{userid};
my $project = $settings{project};
my $select1 = $settings{select1};
my $baselinedate = $settings{baselinedate};
my $baselineversion = $settings{baselineversion};
my $baselineid = $settings{baselineid};
my $title = $settings{title};
my $sessionID = $settings{sessionID};
my $error = "";
my $cgi = new CGI;
#print STDERR "\n-- $command -- $select1 -- \n";
&checkLogin(cgi => $cgi);
if ($SYSUseSessions eq 'T') {
    &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$settings{sessionID});
}
my $errorstr = "";

#$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
#$dbh->{LongReadLen} = 10000000;


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "browse") {
    print &doHeader(title => 'Browse Software Baselines', settings => \%settings, form => $form, path => $path, sessionID => $sessionID);
    eval {
        print &doBrowseBaselineTable(dbh => $dbh, schema => $schema, userID => $userid, project => $select1, sessionID => $sessionID);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
 ###################################################################################################################################
 } elsif ($command eq "create") {
	  print &doHeader(title => 'Create ' . $title , settings => \%settings, form => $form, path => $path, sessionID => $sessionID);
	  eval {
			print &createBaselineBody(dbh => $dbh, schema => $schema,  userID => $userid, project => $settings{nonLNproject}, sessionID => $sessionID);
	  };
	  if ($@) {
			print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Create Baseline in $form", $@));
	  }
 print &doFooter; 
 ###################################################################################################################################
 } elsif ($command eq "update") {
     print &doHeader(title => 'Update ' . $title , settings => \%settings, form => $form, path => $path, sessionID => $sessionID);
     eval {
         print &updateBaselineBody(dbh => $dbh, schema => $schema,  userID => $userid, baselineversion => $baselineversion, baselineid => $baselineid, select1 => $select1, project => $project, sessionID => $sessionID);
     };
     if ($@) {
         print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Baseline in $form", $@));
     }
    print &doFooter; 
###################################################################################################################################
} elsif ($command eq "browseversions") {
    print &doHeader(title => 'Browse ' . $title . 's', settings => \%settings, form => $form, path => $path, sessionID => $sessionID);
    eval {
        print &doBrowseBaselineItems(dbh => $dbh, schema => $schema,  userID => $userid, selecteddate => $baselinedate, sessionID => $sessionID);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse Version in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "browseitems") {
    print &doHeader(title => 'Browse ' . $title . 's', settings => \%settings, form => $form, path => $path, sessionID => $sessionID);
    eval {
        print &doBrowseSelectedBaselineItems(dbh => $dbh, schema => $schema,  userID => $userid, baselineversion => $baselineversion, baselinedate => $baselinedate, select1 => $select1, project => $project, sessionID => $sessionID);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse Version in $form", $@));
    }
    print &doFooter; 
 ###################################################################################################################################
 } elsif ($command eq "db_create") {
	 print &doHeader(title => 'Create ' . $title , settings => \%settings, form => $form, path => $path, sessionID => $sessionID);
	 eval {
	 	  print &doCreateBaseline(dbh => $dbh, schema => $schema,  userID => $userid, baselineversion => $baselineversion, baselineid => $baselineid, select1 => $select1, project => $project, sessionID => $sessionID);
	 };
	 if ($@) {
		  print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "DB Create Baseline in $form", $@));
	 }
 	 print &doFooter; 
 ###################################################################################################################################
 } elsif ($command eq "db_update") {
  	 print &doHeader(title => 'Update ' . $title , settings => \%settings, form => $form, path => $path, sessionID => $sessionID);
  	 eval {
		  print &doUpdateBaseline(dbh => $dbh, schema => $schema,  userID => $userid, baselineversion => $baselineversion, baselineid => $baselineid, select1 => $select1, project => $project, sessionID => $sessionID);
  	 };
  	 if ($@) {
		  print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "DB Update Baseline in $form", $@));
  	 }
	 print &doFooter; 
###################################################################################################################################
} 

&db_disconnect($dbh);
exit();
