#!/usr/local/bin/perl -w

# Role functions
#
# $Source: /data/dev/rcs/mms/perl/RCS/roles.pl,v $
#
# $Revision: 1.3 $
#
# $Date: 2006/03/27 19:15:18 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: roles.pl,v $
# Revision 1.3  2006/03/27 19:15:18  atchleyb
# CR 0023 - Updated to add a new function/utility for transfering pending approvals to a new role holder.
#
# Revision 1.2  2005/08/18 18:58:42  atchleyb
# CR00015 - added delegations report
#
# Revision 1.1  2003/11/12 20:41:52  atchleyb
# Initial revision
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
use UIRoles qw(:Functions);
use DBRoles qw(:Functions);
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
        print &doBrowse(dbh => $dbh, schema => $schema, title => $title, userID => $userid, site=>$settings{rolesite});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "updateusersiteselect") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateUserSiteSelect(dbh => $dbh, schema => $schema, title => $title, form => $form, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User/Site selection in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "updateusersiteform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUserSiteEntryForm(dbh => $dbh, schema => $schema, type => (($command eq "adduserform") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User/Roles in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "updateusersite") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUserSiteEntry(dbh => $dbh, schema => $schema, type => (($command eq "adduser") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update User/Site/Roles in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "userroledelegationreview") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUserRoleDelegationReview(dbh => $dbh, schema => $schema,  
              title => $title, form => $form,  userID => $userid, rUserID=>$settings{id}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User/Roles/Delegation in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "userroledelegationform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path, includeJSCalendar=>'T');
    eval {
        print &doUserRoleDelegationForm(dbh => $dbh, schema => $schema, role=>$settings{role}, site=>$settings{site},
              title => $title, form => $form,  userID => $userid, rUserID=>$settings{ruserid}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User/Roles/Delegation in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "userroledelegation") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUserRoleDelegation(dbh => $dbh, schema => $schema, role=>$settings{role}, site=>$settings{site},
              title => $title, form => $form,  userID => $userid, rUserID=>$settings{ruserid}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display User/Roles/Delegation in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "reassignapprovals") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doReassignApprovalsSelect(dbh => $dbh, schema => $schema, role=>$settings{role},
              form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Reassign Approvals Select in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "reassignapprovalsform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doReassignApprovalsForm(dbh => $dbh, schema => $schema, role=>$settings{role},
              form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Reassign Approvals Form in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "processreassignapprovals") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doReassignApprovals(dbh => $dbh, schema => $schema, role=>$settings{role},
              form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process Reassign Approvals in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "printdelegations") {
    eval {
        print &doPrintDelegations(dbh => $dbh, schema => $schema, role=>$settings{role}, site=>$settings{urdsite},
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Print Role Delegations in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} else {
    print &doHeader(dbh => $dbh, title => 'Bad Command', settings => \%settings, form => $form, path => $path);
    print "<br><center>Command $command not known</center>\n";
    print &doFooter(form => $form, path => $path, settings => \%settings);
}


&db_disconnect($dbh);
exit();
