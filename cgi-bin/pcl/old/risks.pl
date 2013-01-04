#!/usr/local/bin/perl -w
#
# $Source: $
#
# $Revision:  $
#
# $Date:  $
#
# $Author:  $
#
# $Locker:  $
#
# $Log:  $
#
#
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UIRisks qw(:Functions);
use DBRisks qw(:Functions);
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
my $risk = $settings{risk};
my $title = $settings{title};
my $error = "";
my $cgi = new CGI;
&checkLogin(cgi => $cgi);
if ($SYSUseSessions eq 'T') {
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
    print &doHeader(title => 'Browse Project Risks', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseRisks(dbh => $dbh, schema => $schema, project => $project, title => $title, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "editRisk") {
    print &doHeader(title => 'Edit Risk', settings => \%settings, form => $form, path => $path);
    eval {
        print &doEditRisk(dbh => $dbh, schema => $schema, userID => $userid, risk => $settings{risk});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Edit risk in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "createRisk") {
    print &doHeader(title => 'Create Risk', settings => \%settings, form => $form, path => $path);
    eval {
        print &doCreateRisk(dbh => $dbh, schema => $schema, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Create risk in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processCreateRisk") {
    print &doHeader(title => 'Create Risk', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessCreateRisk(dbh => $dbh, schema => $schema, userID => $userid, project => $project, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process create risk in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processUpdateRisk") {
    print &doHeader(title => 'Update Risk', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessUpdateRisk(dbh => $dbh, schema => $schema, userID => $userid, risk => $risk, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process update risk in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "riskHistory") {
    print &doHeader(title => 'Risk History', settings => \%settings, form => $form, path => $path);
    eval {
        print &doRiskHistory(dbh => $dbh, schema => $schema, userID => $userid, risk => $risk, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display risk history in $form", $@));
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
