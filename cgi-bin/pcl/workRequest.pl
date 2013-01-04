#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/workRequest.pl,v $
#
# $Revision: 1.4 $
#
# $Date: 2004/02/25 17:37:32 $
#
# $Author: munroeb $
#
# $Locker:  $
#
# $Log: workRequest.pl,v $
# Revision 1.4  2004/02/25 17:37:32  munroeb
# Added binary attachment functionality to work request form.
#
# Revision 1.3  2003/11/28 21:28:29  starkeyj
# modified the validateSession criteria so it doesn't validate for users not logged in (SCR14)
#
# Revision 1.2  2003/11/26 22:18:31  higashis
# Modified to finish workrequest logic for SCR14
#
# Revision 1.1  2003/11/13 20:46:04  starkeyj
# Initial revision
#
#
#
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UIWorkRequest qw(:Functions);
use DBWorkRequest qw(:Functions);
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
my $project = $settings{project};
my $request = $settings{request};
my $title = $settings{title};
my $error = "";
my $cgi = new CGI;
#&checkLogin(cgi => $cgi);
if ($SYSUseSessions eq 'T' && $userid != 0) {
    &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$settings{sessionID});
}
my $errorstr = "";

#$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
#$dbh->{LongReadLen} = 10000000;


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "browse") {
    print &doHeader(title => 'Browse Software Work Requests', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseRequests(dbh => $dbh, schema => $schema, project => $project, title => $title, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "createRequest" || $command eq "editRequest") {
    print &doHeader(title => 'Software Work Request', settings => \%settings, form => $form, path => $path);
    eval {
        print &doRequestForm(dbh => $dbh, schema => $schema, userID => $userid, request => $settings{request});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Create or Edit request in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "createReview") {
    print &doHeader(title => 'Edit Review Form', settings => \%settings, form => $form, path => $path);
    eval {
        print &doReviewForm(dbh => $dbh, schema => $schema, userID => $userid, request => $settings{request}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Create or Edit review in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "displayRequest") {
    print &doHeader(title => 'Display Request', settings => \%settings, form => $form, path => $path);
    eval {
        print &doDisplayRequest(dbh => $dbh, schema => $schema, userID => $userid, request => $settings{request});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display request in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processCreateRequest") {
    print &doHeader(title => 'Create Request', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessCreateWR(dbh => $dbh, schema => $schema, userID => $userid, project => $project, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process create work request in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processUpdateRequest") {
    print &doHeader(title => 'Update Request', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessUpdateWR(dbh => $dbh, schema => $schema, userID => $userid, request => $request, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process update request in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processCreateReview") {
    print &doHeader(title => 'Process Create Request', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessCreateReview(dbh => $dbh, schema => $schema, userID => $userid, project => $project, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process create review in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processUpdateReview") {
    print &doHeader(title => 'Update Review', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessUpdateReview(dbh => $dbh, schema => $schema, userID => $userid, request => $request, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process update review in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processAttachments") {
    eval {
        print &doProcessAttachments(dbh => $dbh, schema => $schema, userID => $userid, request => $request, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process view attachments in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} else {
    print &doHeader(title => 'Bad Command', settings => \%settings, form => $form, path => $path);
    print "<br><center>Command $command not known</center>\n";
    print &doFooter;
}

&db_disconnect($dbh);
exit();
