#!/usr/local/bin/perl -w

# Department functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/departments.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2009/06/26 21:57:40 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: departments.pl,v $
# Revision 1.2  2009/06/26 21:57:40  atchleyb
# ACR0906_001 - List of changes
#
# Revision 1.1  2004/01/09 18:57:56  atchleyb
# Initial revision
#
#
#
#

# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Tie::IxHash;
use UIDepartments qw(:Functions);
use DBDepartments qw(:Functions);
use CGI;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
$dbh = db_connect();
#$dbh = db_connect(server => 'ydoracle');
my %settings = getInitialValues(dbh => $dbh);
my $username = $settings{"username"};
my $userid = $settings{"userid"};
my $schema = $settings{"schema"};
# Set server parameter
my $Server = $settings{"server"};
if (!(defined($Server))) {$Server=$SYSServer;}
my $command = $settings{"command"};
my $title = $settings{title};
my $error = "";
my $errorstr = "";
my $cgi = new CGI;

&checkLogin(cgi => $cgi);
#! test for invalid or timed out session
&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "browse") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateDepartmentSelect(dbh => $dbh, schema => $schema, title => $title, form => $form, userID => $userid, 
              browseOnly=>'T', settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "displaydept") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doDepartmentEntryForm(dbh => $dbh, schema => $schema, browseOnly=>'T', 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Department in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "updatedeptselect") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateDepartmentSelect(dbh => $dbh, schema => $schema, title => $title, form => $form, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Department in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "adddeptform" || $command eq "updatedeptform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doDepartmentEntryForm(dbh => $dbh, schema => $schema, type => (($command eq "adddeptform") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Add/Update Department form in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "adddept" || $command eq "updatedept") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doDepartmentEntry(dbh => $dbh, schema => $schema, type => (($command eq "adddept") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Add/Update Department in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "deletedept") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doDepartmentDelete(dbh => $dbh, schema => $schema, id => $settings{id}, 
              form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Delete Department in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
###################################################################################################################################
} else {
    print &doHeader(dbh => $dbh, title => 'Bad Command', settings => \%settings, form => $form, path => $path);
    print "<br><center>Command $command not known</center>\n";
    print &doFooter(form => $form, path => $path, settings => \%settings);
}


&db_disconnect($dbh);
exit();
