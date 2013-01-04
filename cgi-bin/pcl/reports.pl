#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/reports.pl,v $
#
# $Revision: 1.8 $
#
# $Date: 2003/02/12 16:37:33 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: reports.pl,v $
# Revision 1.8  2003/02/12 16:37:33  atchleyb
# added session management
#
# Revision 1.7  2003/02/03 20:03:29  atchleyb
# removed refs to SCM
#
# Revision 1.6  2002/11/07 21:59:06  atchleyb
# updated to include UI_scm
#
# Revision 1.5  2002/11/07 16:17:54  starkeyj
#   modified to pass the CGI reference instead of the username, userid, and schema variables to checkLogin
#
# Revision 1.4  2002/10/31 17:02:19  atchleyb
# seperated logic into BL, DB, and UI
#
# Revision 1.3  2002/10/24 22:15:32  johnsonc
# Added report titles to the menus
#
# Revision 1.2  2002/09/18 21:21:53  atchleyb
# updated to change the text decoration type for the main menu so that it looks more like a link
#
# Revision 1.1  2002/09/17 20:05:49  atchleyb
# Initial revision
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
if ($SYSUseSessions eq 'T') {
    &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$settings{sessionID});
}
my $errorstr = "";


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "report" || $command eq "view_activity") {
    print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        #print &doSomeReport(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Run Some Report in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} else {  # display main menu as default
    print &doHeader(title => "$title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doMainMenu(dbh => $dbh, schema => $schema, title => $title, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Reports Main Menu in $form", $@));
    }
    print &doFooter;
}


&db_disconnect($dbh);
exit();
