#!/usr/local/bin/perl -w
#
# $Source: /home/atchleyb/rcs/plaqads/perl/RCS/search.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/11/09 19:09:51 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: search.pl,v $
# Revision 1.1  2004/11/09 19:09:51  atchleyb
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
my $errorstr = "";

#! test for invalid or timed out session
&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "dosearch") {
    print &doHeader(dbh => $dbh, displayTitle => 'T', settings => \%settings, form => $form, path => $path);
    eval {
        print &doSearch(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Perform a Search", $@));
    }
    print &doFooter(dbh=>$dbh, schema=>$schema, form => $form, username => $username, userID => $userid);
###################################################################################################################################
} else {  # display main menu as default
    print &doHeader(dbh => $dbh, title => "$title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doSearchForm(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Search Form", $@));
    }
    print &doFooter(dbh=>$dbh, schema=>$schema, form => $form, username => $username, userID => $userid);
}


&db_disconnect($dbh);
exit();
