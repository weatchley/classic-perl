#!/usr/local/bin/perl -w

# User functions for the SCM
#
# $Source: /data/dev/rcs/pcl/perl/RCS/users.pl,v $
#
# $Revision: 1.9 $
#
# $Date: 2003/02/12 16:40:37 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: users.pl,v $
# Revision 1.9  2003/02/12 16:40:37  atchleyb
# added session management
#
# Revision 1.8  2003/02/03 20:24:30  atchleyb
# removed refs to SCM
#
# Revision 1.7  2002/11/07 16:20:00  starkeyj
#  modified to pass the CGI reference instead of the username, userid, and schema variables to checkLogin
#
# Revision 1.6  2002/10/31 17:51:47  atchleyb
# reenabled checkLogin
#
# Revision 1.5  2002/10/24 22:12:06  atchleyb
# seperated logic into BL, DB, and UI
#
# Revision 1.4  2002/09/20 21:31:23  atchleyb
# updated to use new Tables.pl
#
# Revision 1.3  2002/09/19 03:02:27  mccartym
# added function to display user information based on unix userid
#
# Revision 1.2  2002/09/18 21:37:48  atchleyb
# updated to no longer use db_Utilities_Lib.pm
#
# Revision 1.1  2002/09/17 20:02:37  atchleyb
# Initial revision
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
if ($SYSUseSessions eq 'T') {
    &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$settings{sessionID});
}



###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "browse") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowse(dbh => $dbh, schema => $schema, title => $title, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "displayuser" || $command eq "displayuser_by_unixid") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doDisplayUser(dbh => $dbh, schema => $schema, title => $title, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "updateuserselect") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateUserSelect(dbh => $dbh, schema => $schema, title => $title, form => $form, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "adduserform" || $command eq "updateuserform") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUserEntryForm(dbh => $dbh, schema => $schema, type => (($command eq "adduserform") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "adduser" || $command eq "updateuser") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUserEntry(dbh => $dbh, schema => $schema, type => (($command eq "adduser") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "changepasswordform") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doChangePasswordForm(dbh => $dbh, schema => $schema, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "changepassword") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doChangePassword(dbh => $dbh, schema => $schema, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "resetpassword") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doResetPassword(dbh => $dbh, schema => $schema, userID => $settings{u_id}, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "disableuser") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doEnableDisableUser(dbh => $dbh, schema => $schema, type => "Disable", userID => $settings{u_id}, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "enableuser") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doEnableDisableUser(dbh => $dbh, schema => $schema, type => "Enable", userID => $settings{u_id}, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "becomeusernameform") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBecomeUsernameForm(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "becomeusername") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBecomeUsername(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} else {
    print &doHeader(title => 'Bad Command', settings => \%settings, form => $form, path => $path);
    print "<br><center>Command $command not known</center>\n";
    print &doFooter(form => $form, path => $path, settings => \%settings);
}


&db_disconnect($dbh);
exit();
