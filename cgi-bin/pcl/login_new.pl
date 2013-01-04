#!/usr/local/bin/perl -w

# CGI user login for the SCM
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/pcl/perl/RCS/login_new.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2009/01/14 22:43:06 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: login_new.pl,v $
# Revision 1.1  2009/01/14 22:43:06  atchleyb
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

my $errorstr = "";


###################################################################################################################################
###################################################################################################################################

###################################################################################################################################
#
print &testHTTPS;

###################################################################################################################################
if ($command eq "makeform") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    print &doLoginForm(form => $form);
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "login_action") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doValidateLogin(dbh => $dbh, schema => $schema, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process user login in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "login") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    print &doLoginForm(form => $form);
    print &doFooter;    
###################################################################################################################################
} else {  # frame set
    print &doFrameSet(title => $title, path => $path, form => $form, settings => \%settings);
}


&db_disconnect($dbh);
exit();
