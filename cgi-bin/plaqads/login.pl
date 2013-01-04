#!/usr/local/bin/perl -w

# CGI user login
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/login.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/07/27 18:27:16 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: login.pl,v $
# Revision 1.1  2004/07/27 18:27:16  atchleyb
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
use UILogin qw(:Functions);
#use DBLogin qw(:Functions);
use UI_Widgets qw(:Functions);
#use UIShared qw(:Functions);

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

my $errorstr = "";


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
print &testHTTPS;

###################################################################################################################################
if ($command eq "makeform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    print &doLoginForm(form => $form);
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "login_action") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doValidateLogin(dbh => $dbh, schema => $schema, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process user login in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} else {  # frame set
    print &doFrameSet(title => $title, path => $path, form => $form, settings => \%settings);
}


&db_disconnect($dbh);
exit();
