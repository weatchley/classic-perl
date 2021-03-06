#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/mms/perl/RCS/reports.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/12/07 18:49:21 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: reports.pl,v $
# Revision 1.1  2004/12/07 18:49:21  atchleyb
# Initial revision
#
#
#
#
#

$| = 1;

use strict;
use integer;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UIReports qw(:Functions);
use DBReports qw(:Functions);
use UI_Widgets qw(:Functions);
use CGI;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
$dbh = &db_connect();
my %settings = getInitialValues(dbh => $dbh);

my $schema = $settings{schema};
my $command = $settings{command};
my $username = $settings{username};
my $userid = $settings{userid};
my $title = $settings{title};
my $error = "";
my $cgi = new CGI;
&checkLogin(cgi => $cgi);
my $errorstr = "";

#! test for invalid or timed out session
&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "report" || $command eq "view_activity") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        #print &doSomeReport(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Run Some Report in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} else {  # display main menu as default
    print &doHeader(dbh => $dbh, title => "$title", settings => \%settings, form => $form, path => $path, includeJSCalendar=>'T');
    eval {
        print &doMainMenu(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, path => $path);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Reports Main Menu in $form", $@));
    }
    print &doFooter;
}


&db_disconnect($dbh);
exit();
