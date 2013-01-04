#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/mms/perl/RCS/home.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2004/04/21 23:06:01 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: home.pl,v $
# Revision 1.2  2004/04/21 23:06:01  atchleyb
# Updated look and feel and added sorting
#
# Revision 1.1  2003/11/12 20:40:08  atchleyb
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
use UIHome qw(:Functions);
use DBHome qw(:Functions);
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
if ($command eq "stuff") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        #print &doSomeReport(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Run Stuff Command in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} else {  # display main menu as default
    print &doHeader(dbh => $dbh, title => "$title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doMainMenu(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Home Main Menu in $form", $@));
    }
    print &doFooter;
}


&db_disconnect($dbh);
exit();
