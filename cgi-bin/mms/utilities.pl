#!/usr/local/bin/perl -w

# Utilities page
#
# $Source: /home/atchleyb/rcs/mms/perl/RCS/utilities.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2003/11/12 20:42:52 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: utilities.pl,v $
# Revision 1.1  2003/11/12 20:42:52  atchleyb
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
use UIUtilities qw(:Functions);
use DBUtilities qw(:Functions);
use UI_Widgets qw(:Functions);
use UIShared qw(:Functions);
use CGI;

my $cgi = new CGI;


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
&checkLogin(cgi => $cgi);
#&checkLogin ($username, $userid, $schema);
my $errorstr = "";

#! test for invalid or timed out session
&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "view_errors" || $command eq "view_activity") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doViewLogs(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "View Error/Acrivity Log in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} else {  # display menu as default
    print &doHeader(dbh => $dbh, title => "$title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doMenu(dbh => $dbh, schema => $schema, title => $title, userID => $userid, settings => \%settings, form => $form);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Utilities Menu in $form", $@));
    }
    print &doFooter;
}


&db_disconnect($dbh);
exit();
