#!/usr/local/bin/perl -w

# Utilities page for the SCM
#
# $Source: /data/dev/rcs/pcl/perl/RCS/utilities.pl,v $
#
# $Revision: 1.11 $
#
# $Date: 2003/02/12 16:40:47 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: utilities.pl,v $
# Revision 1.11  2003/02/12 16:40:47  atchleyb
# added session management
#
# Revision 1.10  2003/02/03 21:04:08  atchleyb
# removed refs to SCM
#
# Revision 1.9  2002/11/08 17:07:53  starkeyj
# added 'use UI_scm.pm'
#
# Revision 1.8  2002/11/07 16:03:49  starkeyj
# modified to pass the CGI reference instead of the username, userid, and schema variables to checkLogin
#
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
if ($SYSUseSessions eq 'T') {
    &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$settings{sessionID});
}
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
