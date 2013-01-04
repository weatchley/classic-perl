#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/search.pl,v $
#
# $Revision: 1.12 $
#
# $Date: 2003/02/12 16:39:50 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: search.pl,v $
# Revision 1.12  2003/02/12 16:39:50  atchleyb
# added session management
#
# Revision 1.11  2003/02/03 20:08:52  atchleyb
# removed refs to SCM
#
# Revision 1.10  2002/11/27 21:05:03  atchleyb
# updated to seperate BL, UI, and DB functions into different scripts
#
# Revision 1.9  2002/11/07 21:59:19  atchleyb
# updated to include UI_scm
#
# Revision 1.8  2002/11/07 16:18:08  starkeyj
#   modified to pass the CGI reference instead of the username, userid, and schema variables to checkLogin
#
# Revision 1.7  2002/10/31 17:51:32  atchleyb
# reenabled checkLogin
#
# Revision 1.6  2002/10/22 22:51:36  naydenoa
# Changed one occurrence of table 'SCRPRODUCT' with 'PRODUCT'
#
# Revision 1.4  2002/09/23 21:13:32  atchleyb
# changed Training Logs to Trainaing Records
#
# Revision 1.3  2002/09/20 20:49:13  atchleyb
# updated to use new Tables.pm
#
# Revision 1.2  2002/09/18 21:40:16  atchleyb
# rearanged options on screen
#
# Revision 1.1  2002/09/17 20:09:44  atchleyb
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
use UISearch qw(:Functions);
use DBSearch qw(:Functions);
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
if ($command eq "dosearch") {
    print &doHeader(displayTitle => 'T', settings => \%settings, form => $form, path => $path);
    eval {
        print &doSearch(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Perform a Search", $@));
    }
    print &doFooter(dbh=>$dbh, schema=>$schema, form => $form, username => $username, userID => $userid, sessionID => $settings{sessionID});
###################################################################################################################################
} else {  # display main menu as default
    print &doHeader(title => "$title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doSearchForm(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Search Form", $@));
    }
    print &doFooter(dbh=>$dbh, schema=>$schema, form => $form, username => $username, userID => $userid, sessionID => $settings{sessionID});
}


&db_disconnect($dbh);
exit();
