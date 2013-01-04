#!/usr/local/bin/perl -w

# User functions
#
# $Source: /data/dev/rcs/prp/perl/RCS/users.pl,v $
# $Revision: 1.1 $
# $Date: 2004/04/22 20:57:42 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: users.pl,v $
# Revision 1.1  2004/04/22 20:57:42  naydenoa
# Initial revision
#
#

# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Tie::IxHash;
use UIUsers qw(:Functions);
use DBUsers qw(:Functions);
use CGI;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
$dbh = db_connect();

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

###########################
if ($command eq "browse") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowse(dbh => $dbh, schema => $schema, title => $title, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
} 
###################################
elsif ($command eq "displayuser") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doDisplayUser(dbh => $dbh, schema => $schema, title => $title, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
} 
########################################
elsif ($command eq "updateuserselect") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateUserSelect(dbh => $dbh, schema => $schema, title => $title, form => $form, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
} 
###################################################################
elsif ($command eq "adduserform" || $command eq "updateuserform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUserEntryForm(dbh => $dbh, schema => $schema, type => (($command eq "adduserform") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
} 
###########################################################
elsif ($command eq "adduser" || $command eq "updateuser") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUserEntry(dbh => $dbh, schema => $schema, type => (($command eq "adduser") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
} 
##########################################
elsif ($command eq "changepasswordform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doChangePasswordForm(dbh => $dbh, schema => $schema, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
} 
######################################
elsif ($command eq "changepassword") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doChangePassword(dbh => $dbh, schema => $schema, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
} 
#####################################
elsif ($command eq "resetpassword") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doResetPassword(dbh => $dbh, schema => $schema, userID => $settings{u_id}, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
} 
###################################
elsif ($command eq "disableuser") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doEnableDisableUser(dbh => $dbh, schema => $schema, type => "Disable", userID => $settings{u_id}, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
} 
##################################
elsif ($command eq "enableuser") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doEnableDisableUser(dbh => $dbh, schema => $schema, type => "Enable", userID => $settings{u_id}, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
} 
##########################################
elsif ($command eq "becomeusernameform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBecomeUsernameForm(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
} 
######################################
elsif ($command eq "becomeusername") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBecomeUsername(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
} 
######
else {
    print &doHeader(dbh => $dbh, title => 'Bad Command', settings => \%settings, form => $form, path => $path);
    print "<br><center>Command $command not known</center>\n";
    print &doFooter(form => $form, path => $path, settings => \%settings);
}

#####################
&db_disconnect($dbh);
exit();
