#!/usr/local/bin/perl -w
#
# $Source: /usr/local/homes/patelr/www/gov.doe.ocrwm.ydappdev/rcs/qa/perl/RCS/surveillance2.pl,v $
#
# $Revision: 1.7 $
#
# $Date: 2009/03/24 20:48:42 $
#
# $Author: patelr $
#
# $Locker:  $
#
# $Log: surveillance2.pl,v $
# Revision 1.7  2009/03/24 20:48:42  patelr
# added delete attachment function
#
# Revision 1.6  2007/04/12 22:02:12  dattam
# Added control for deleting a surveillance incorrectly entered into the system
#
# Revision 1.5  2004/08/26 14:30:17  starkeyj
# modified editReportLink and processEditReportLink to add dbname
#
# Revision 1.4  2004/05/30 22:16:31  starkeyj
# modified viewSurveillance command to send $settings{selection}
#
# Revision 1.3  2004/03/12 20:08:06  starkeyj
# added editReportlink and processEditReportlink
#
# Revision 1.2  2004/01/25 23:46:12  starkeyj
# added control for cancelling a surveillance (SCR 59)
#
# Revision 1.1  2004/01/13 13:46:06  starkeyj
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
        print &doProcessDeleteSurveillance(dbh => $dbh, schema => $schema, userID => $userid, survID => $settings{survID}, displayid => $settings{displayid},fiscalyear => $fiscalyear,settings => \%settings);
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
} elsif ($command eq "deleteAttachment") {
    print &doHeader(title => 'Edit Report Link', settings => \%settings, form => $form, path => $path);
    eval {
        print &doDeleteAttachment(dbh => $dbh, schema => $schema, userID => $userid, survID => $settings{survID},fiscalyear => $fiscalyear,reportlink => $settings{reportlink},dbname => $settings{dbname});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process edit surveillance reportlink in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
}
 else {
    print &doHeader(title => 'Bad Command', settings => \%settings, form => $form, path => $path);
    print "<br><center>Command -- $command -- not known</center>\n";
    print &doFooter;
}
&NQS_disconnect($dbh);
#&db_disconnect($dbh);
exit();
