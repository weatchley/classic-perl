#!/usr/local/bin/perl -w
#
# $Source: /usr/local/homes/gilmored/rcs/prp/perl/RCS/search.pl,v $
# $Revision: 1.4 $
# $Date: 2009/02/06 19:58:40 $
# $Author: gilmored $
# $Locker: gilmored $
# $Log: search.pl,v $
# Revision 1.4  2009/02/06 19:58:40  gilmored
# Added check for GUEST user
#
# Revision 1.3  2005/09/29 15:31:26  naydenoa
# Phase 3 implementation
# Minor tweaks - remove comments
#
# Revision 1.2  2004/06/16 21:37:56  naydenoa
# Enabled for P1C2
#
# Revision 1.1  2004/04/22 20:52:16  naydenoa
# Initial revision
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
if($username ne "" && $username ne "GUEST") { &checkLogin(cgi => $cgi); }
my $errorstr = "";

#! test for invalid or timed out session
&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});


#############################
if ($command eq "dosearch") {
    print &doHeader(dbh => $dbh, displayTitle => 'T', settings => \%settings, form => $form, path => $path);
    eval {
        print &doSearch(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Perform a Search", $@));
    }
    print &doFooter(dbh=>$dbh, schema=>$schema, form => $form, username => $username, userID => $userid);
} 
######################################
else {  # display main menu as default
    print &doHeader(dbh => $dbh, title => "$title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doSearchForm(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Search Form", $@));
    }
    print &doFooter(dbh=>$dbh, schema=>$schema, form => $form, username => $username, userID => $userid);
}

#####################
&db_disconnect($dbh);
exit();
