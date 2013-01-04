#!/usr/local/bin/newperl -w
#
# Component Description
#
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/qa/perl/RCS/integrated_surveillance.pl,v $
# $Revision: 1.1 $
# $Date $
# $Author: higashis $
# $Locker: higashis $
# $Log: integrated_surveillance.pl,v $
# Revision 1.1  2008/10/20 17:50:08  higashis
# Initial revision
#

####################################################################################
#
# Parameters:
# 		
#
####################################################################################
use strict;
use OQA_specific qw(:Functions);
use NQS_Header qw(:Constants);
use OQA_Utilities_Lib qw(:Functions);
use OQA_Widgets qw(:Functions);
use UIShared qw(:Functions);
use UISurveillance qw(:Functions);
use DBSurveillance qw(:Functions);
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
my $survID = $settings{survID};
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
    print &doHeader(title => 'Browse Surveillance Schedule', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseSurveillance(dbh => $dbh, schema => $schema, title => $title, settings => \%settings, fiscalyear => $fiscalyear, selection => $settings{selection});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
#
} elsif ($command eq "browseXsl") {
    print &doHeaderXsl(title => 'Browse Surveillance Schedule', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseSurveillanceXsl(dbh => $dbh, schema => $schema, title => $title, settings => \%settings, fiscalyear => $fiscalyear, selection => $settings{selection});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;    
###################################################################################################################################
} elsif ($command eq "editSurveillance") {
    print &doHeader(title => 'Edit Surveillance', settings => \%settings, form => $form, path => $path);
    eval {
        print &doEditSurveillance(dbh => $dbh, schema => $schema, userID => $userid, survID => $settings{survID}, fiscalyear => $fiscalyear, int_ext => $settings{int_ext});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Edit surveillance in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "editResults") {
    print &doHeader(title => 'Edit Surveillance', settings => \%settings, form => $form, path => $path);
    eval {
        print &doEditResults(dbh => $dbh, schema => $schema, userID => $userid, survID => $settings{survID}, fiscalyear => $fiscalyear);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Edit surveillance results in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "viewSurveillance") {
    print &doHeader(title => 'View Surveillance', settings => \%settings, form => $form, path => $path);
    eval {
        print &doViewSurveillance(dbh => $dbh, schema => $schema, userID => $userid, survID => $settings{survID}, fiscalyear => $fiscalyear,selection => $settings{selection});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "View surveillance in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processCreateSurveillance") {
    print &doHeader(title => 'Create Surveillance', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessCreateSurveillance(dbh => $dbh, schema => $schema, userID => $userid, , fiscalyear => $settings{newfyselect}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Create surveillance in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processUpdateSurveillance") {
    print &doHeader(title => 'Update Surveillance', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessUpdateSurveillance(dbh => $dbh, schema => $schema, userID => $userid, survID => $settings{survID},fiscalyear => $fiscalyear,settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process update surveillance in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processCancelSurveillance") {
    print &doHeader(title => 'Cancel Surveillance', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessCancelSurveillance(dbh => $dbh, schema => $schema, userID => $userid, survID => $settings{survID},fiscalyear => $fiscalyear,settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process update surveillance in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processDeleteSurveillance") {
    print &doHeader(title => 'Delete Surveillance', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessDeleteSurveillance(dbh => $dbh, schema => $schema, userID => $userid, survID => $settings{survID},fiscalyear => $fiscalyear,settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process delete surveillance in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "editReportlink") {
    print &doHeader(title => 'Edit Report Link', settings => \%settings, form => $form, path => $path);
    eval {
        print &doEditReportlink(dbh => $dbh, schema => $schema, userID => $userid, survID => $settings{survID},reportlink => $settings{reportlink}, fiscalyear => $fiscalyear, displayid => $settings{displayid},dbname => $settings{dbname});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Edit surveillance reportlink in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processEditReportlink") {
    print &doHeader(title => 'Edit Report Link', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessEditReportlink(dbh => $dbh, schema => $schema, userID => $userid, survID => $settings{survID},fiscalyear => $fiscalyear,reportlink => $settings{reportlink},dbname => $settings{dbname});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process edit surveillance reportlink in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} else {
    print &doHeader(title => 'Bad Command', settings => \%settings, form => $form, path => $path);
    print "<br><center>Command -- $command -- not known</center>\n";
    print &doFooter;
}
&NQS_disconnect($dbh);
exit();
