#!/usr/local/bin/perl -w

# Utilities page for the SCM
#
# $Source: /data/dev/rcs/scm/perl/RCS/utilities.pl,v $
#
# $Revision: 1.7 $
#
# $Date: 2002/10/31 16:58:49 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: utilities.pl,v $
# Revision 1.7  2002/10/31 16:58:49  atchleyb
# seperated logic into BL, DB, and UI
#
# Revision 1.6  2002/09/27 00:00:01  starkeyj
# modified screen layout
#
# Revision 1.5  2002/09/24 19:51:26  atchleyb
# updated to removed documents.pl
#
# Revision 1.4  2002/09/20 21:08:45  atchleyb
# updated to use new Tables.pm
#
# Revision 1.3  2002/09/19 23:09:51  atchleyb
# added update to configuration items menu
# changed procedures, templates and training to use documents.pl
#
# Revision 1.2  2002/09/19 01:32:57  starkeyj
# modified display and links as needed as SCM developmentt progresses
#
# Revision 1.1  2002/09/17 21:11:33  starkeyj
# Initial revision
#
#
#
#

$| = 1;

use strict;
use integer;
use SCM_Header qw(:Constants);
use DB_scm qw(:Functions);
use UIUtilities qw(:Functions);
use DBUtilities qw(:Functions);
use UI_Widgets qw(:Functions);
#use UI_scm qw(:Functions);

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

&checkLogin ($username, $userid, $schema);
my $errorstr = "";


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "view_errors" || $command eq "view_activity") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doViewLogs(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "View Error/Acrivity Log in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} else {  # display menu as default
    print &doHeader(title => "$title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doMenu(dbh => $dbh, schema => $schema, title => $title, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Utilities Menu in $form", $@));
    }
    print &doFooter;
}


&db_disconnect($dbh);
exit();
