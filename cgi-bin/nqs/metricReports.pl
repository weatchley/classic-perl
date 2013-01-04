#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/qa/perl/RCS/metricReports.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/05/30 22:21:47 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: metricReports.pl,v $
# Revision 1.1  2004/05/30 22:21:47  starkeyj
# Initial revision
#
#
#
use strict;
use OQA_specific qw(:Functions);
use NQS_Header qw(:Constants);
use OQA_Utilities_Lib qw(:Functions);
use OQA_Widgets qw(:Functions);
use UIShared qw(:Functions);
use UIMetricReports qw(:Functions);
#use DBMetricReports qw(:Functions);
#use SharedHeader qw(:Constants);
#use DBShared qw(:Functions);
#use UI_Widgets qw(:Functions);

use CGI;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;

$dbh = &NQS_connect();
#$dbh = &db_connect();
my %settings = getInitialValues(dbh => $dbh);

my $schema = $settings{schema};
my $command = $settings{command};
my $username = $settings{username};
my $userid = $settings{userid};
my $fiscalyear = $settings{fiscalyear};
my $auditID = $settings{auditID};
my $survID = $settings{survID};
my $table = $settings{table};
print STDERR "\n--> $table -- $command -- $settings{fiscalyear} <--\n";
my $title = $settings{title};
my $error = "";
my $cgi = new CGI;
#&checkLogin(cgi => $cgi);
#if ($SYSUseSessions eq 'T') {
#    &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$settings{sessionID});
#}
my $errorstr = "";

#$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
#$dbh->{LongReadLen} = 10000000;


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "browse") {
    print &doHeader(title => 'Browse Audit Schedule', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseAudit(dbh => $dbh, schema => $schema, title => $title, settings => \%settings, fiscalyear => $settings{fiscalyear}, table => $table);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "editAudit") {
    print &doHeader(title => 'Edit Audit', settings => \%settings, form => $form, path => $path);
    eval {
        print &doEditAudit(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID}, fiscalyear => $fiscalyear, table => $table, tag => $settings{tag});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Edit audit in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "editResults") {
    print &doHeader(title => 'Edit Audit', settings => \%settings, form => $form, path => $path);
    eval {
        print &doEditResults(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID}, fiscalyear => $fiscalyear);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Edit audit results in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "viewAudit") {
    print &doHeader(title => 'View Audit', settings => \%settings, form => $form, path => $path);
    eval {
        print &doViewAudit(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID}, fiscalyear => $fiscalyear, table => $table);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "View audit in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processCreateAudit") {
    print &doHeader(title => 'Create Audit', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessCreateAudit(dbh => $dbh, schema => $schema, userID => $userid, fiscalyear => $fiscalyear, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Create audit in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processUpdateAudit") {
    print &doHeader(title => 'Update Audit', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessUpdateAudit(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID},fiscalyear => $fiscalyear,table => $table,settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process update audit in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processCancelAudit") {
    print &doHeader(title => 'Cancel Audit', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessCancelAudit(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID},fiscalyear => $fiscalyear,table=>$table);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process cancel audit in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processDeleteAudit") {
    print &doHeader(title => 'Cancel Audit', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessDeleteAudit(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID},fiscalyear => $fiscalyear,table=>$table);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process delete audit in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "getSequence") {
    print &doHeader(title => 'Available Sequence Numbers', settings => \%settings, form => $form, path => $path);
    eval {
        print &doGetAvailableSequence(dbh => $dbh, schema => $schema, userID => $userid, fiscalyear => $fiscalyear, table=>$table, type=>$settings{type},issuedby=>$settings{issuedby});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Get sequence for audit in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "editReportlink") {
    print &doHeader(title => 'Edit Report Link', settings => \%settings, form => $form, path => $path);
    eval {
        print &doEditReportlink(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID},reportlink => $settings{reportlink}, fiscalyear => $fiscalyear, displayid => $settings{displayid},table=>$table);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Edit $table audit reportlink in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processEditReportlink") {
    print &doHeader(title => 'Edit Report Link', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessEditReportlink(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID},fiscalyear => $fiscalyear,reportlink => $settings{reportlink},table=>$table);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process edit $table audit reportlink in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} else {
    print &doHeader(title => 'Bad Command', settings => \%settings, form => $form, path => $path);
    print "<br><center>Command -- $command -- not known</center>\n";
    print &doFooter;
}
&NQS_disconnect($dbh);
#&db_disconnect($dbh);
exit();
