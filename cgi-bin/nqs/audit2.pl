#!/usr/local/bin/perl -w
#
# $Source: /usr/local/homes/patelr/www/gov.doe.ocrwm.ydappdev/rcs/qa/perl/RCS/audit2.pl,v $
#
# $Revision: 1.6 $
#
# $Date: 2009/03/24 20:48:08 $
#
# $Author: patelr $
#
# $Locker:  $
#
# $Log: audit2.pl,v $
# Revision 1.6  2009/03/24 20:48:08  patelr
# added delete attachment function
#
# Revision 1.5  2005/10/31 20:15:53  dattam
# Modified viewAudit command to send $settings{qardstring}, new command
# editAuditOther added
#
# Revision 1.4  2004/08/18 19:15:00  starkeyj
# modified fiscal year parameter for processCreateAudit
#
# Revision 1.3  2004/08/18 17:46:18  starkeyj
# modified to add database selection parameter for report links
#
# Revision 1.2  2004/05/30 22:15:19  starkeyj
# modified viewAudit command to send $settings{selection}
#
# Revision 1.1  2004/04/07 15:08:05  starkeyj
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
use UIAudit qw(:Functions);
use DBAudit qw(:Functions);
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
my $table = $settings{table};
my $tag = $settings{tag};

my $title = $settings{title};
my $error = "";
my $cgi = new CGI;
print("** $command **");
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
        print &doBrowseAudit(dbh => $dbh, schema => $schema, title => $title, settings => \%settings, fiscalyear => $settings{fy}, table => $table,selection => $settings{selection});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "editAudit") {
    print &doHeader(title => 'Edit Audit', settings => \%settings, form => $form, path => $path);
    eval {
        print &doEditAudit(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID}, fiscalyear => $fiscalyear, table => $table, tag => $settings{tag},selection=>$settings{selection});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Edit audit in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
 } elsif ($command eq "editAuditOther") {
    print &doHeader(title => 'Edit Audit', settings => \%settings, form => $form, path => $path);
    eval {
        print &doEditAuditOther(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID}, fiscalyear => $fiscalyear, table => $table, tag => $settings{tag},selection=>$settings{selection},int_ext => $settings{int_ext});
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
        print &doViewAudit(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID}, fiscalyear => $fiscalyear, table => $table,selection=>$settings{selection},qardstring=>$settings{qardstring});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "View audit in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processCreateAudit") {
    print &doHeader(title => 'Create Audit', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessCreateAudit(dbh => $dbh, schema => $schema, userID => $userid, fiscalyear => $settings{fy}, settings => \%settings);
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
        print &doProcessDeleteAudit(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID},fiscalyear => $fiscalyear,table=>$table,displayid => $settings{displayid});
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
        print &doEditReportlink(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID},reportlink => $settings{reportlink}, fiscalyear => $fiscalyear, displayid => $settings{displayid},table=>$table,dbname => $settings{dbname});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Edit $table audit reportlink in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processEditReportlink") {
    print &doHeader(title => 'Edit Report Link', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessEditReportlink(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID},fiscalyear => $fiscalyear,reportlink => $settings{reportlink},table=>$table,dbname => $settings{dbname});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process edit $table audit reportlink in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processMetricReport") {
    print &doHeader(title => 'Metric Report', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessMetricReport(dbh => $dbh, schema => $schema, userID => $userid,fiscalyear => $fiscalyear);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process edit $table audit reportlink in $form", $@));
    }
    print &doFooter;
################################################################################################################################### 
} elsif ($command eq "deleteAuditAttachment") {
    print &doHeader(title => 'Delete Attachment', settings => \%settings, form => $form, path => $path);
    eval {
        print &doDeleteAuditAttachment(dbh => $dbh, schema => $schema, userID => $userid, auditID => $settings{auditID},fiscalyear => $fiscalyear,reportlink => $settings{reportlink},table=>$table,dbname => $settings{dbname});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process edit $table audit reportlink in $form", $@));
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
