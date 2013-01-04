#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/qa/perl/RCS/conditionReports.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2004/01/25 23:53:34 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: conditionReports.pl,v $
# Revision 1.2  2004/01/25 23:53:34  starkeyj
# added logic to edit Best Practice, CR and Followup to CR
#
# Revision 1.1  2004/01/13 13:55:41  starkeyj
# Initial revision
#
#
#
use strict;
#use SharedHeader qw(:Constants);
#use DBShared qw(:Functions);
use OQA_specific qw(:Functions);
use OQA_Utilities_Lib qw(:Functions);
use OQA_Widgets qw(:Functions);
use NQS_Header qw(:Constants);
use UIShared qw(:Functions);
use UIConditionReports qw(:Functions);
use DBConditionReports qw(:Functions);
#use UI_Widgets qw(:Functions);
use CGI;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
#$dbh = &db_connect();
$dbh = &NQS_connect();
my %settings = getInitialValues(dbh => $dbh);

my $schema = $settings{schema};
my $command = $settings{command};
my $username = $settings{username};
my $userid = $settings{userid};
my $type = $settings{type};
my $CRid = $settings{CRid};
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
    print &doHeader(title => 'Browse Project Risks', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseCondition(dbh => $dbh, schema => $schema, title => $title, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "editCondition") {
    print &doHeader(title => 'Edit Condition Report', settings => \%settings, form => $form, path => $path);
    eval {
        print &doEditCondition(dbh => $dbh, schema => $schema, userID => $userid, CRid => $settings{CRid});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Edit condition report in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "createCondition") {
    print &doHeader(title => 'Create Condition Report', settings => \%settings, form => $form, path => $path);
    eval {
        print &doCreateCondition(dbh => $dbh, schema => $schema, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Create condition report in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processCreateCondition") {
    print &doHeader(title => 'Create Condition Report', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessCreateCondition(dbh => $dbh, schema => $schema, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process create condition report in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processUpdateCondition") {
    print &doHeader(title => 'Update Condition Report', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessUpdateCondition(dbh => $dbh, schema => $schema, userID => $userid, CRid => $CRid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process update condition report in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processDeleteCondition") {
    print &doHeader(title => 'Update Condition Report', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessDeleteCondition(dbh => $dbh, schema => $schema, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process delete condition report in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "browseConditions") {
    print &doHeader(title => 'Browse Condition Reports', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseConditions(dbh => $dbh, schema => $schema, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse Conditions in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "createFollowup") {
    print &doHeader(title => 'Create Follow-Up to Condition Report', settings => \%settings, form => $form, path => $path);
    eval {
        print &doCreateFollowup(dbh => $dbh, schema => $schema, userID => $userid, CRid => $CRid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process create follow-up to condition report in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "editFollowup") {
    print &doHeader(title => 'Edit Follow-Up to Condition Report', settings => \%settings, form => $form, path => $path);
    eval {
        print &doEditFollowup(dbh => $dbh, schema => $schema, userID => $userid, CRid => $CRid, funum => $settings{funum}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process create follow-up to condition report in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processCreateFollowup") {
    print &doHeader(title => 'Create Follow-Up to Condition Report', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessCreateFollowup(dbh => $dbh, schema => $schema, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process create follow-up to condition report in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processUpdateFollowup") {
    print &doHeader(title => 'Update Follow-Up to Condition Report', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessUpdateFollowup(dbh => $dbh, schema => $schema, userID => $userid, CRid => $CRid, funum => $settings{funum}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process update follow-up to condition report in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processDeleteFollowup") {
    print &doHeader(title => 'Delete Follow-Up to Condition Report', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessDeleteFollowup(dbh => $dbh, schema => $schema, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process delete follow-up to condition report in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "createBestPractice") {
    print &doHeader(title => 'Create Best Practice', settings => \%settings, form => $form, path => $path);
    eval {
        print &doCreateBestPractice(dbh => $dbh, schema => $schema, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process create Best Practice in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processCreateBestPractice") {
    print &doHeader(title => 'Create Best Practice', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessCreateBestPractice(dbh => $dbh, schema => $schema, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process create Best Practice in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "editBestPractice") {
    print &doHeader(title => 'Create Best Practice', settings => \%settings, form => $form, path => $path);
    eval {
        print &doEditBestPractice(dbh => $dbh, schema => $schema, userID => $userid, bpnum => $settings{bpnum}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process create Best Practice in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processUpdateBestPractice") {
    print &doHeader(title => 'Create Best Practice', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessUpdateBestPractice(dbh => $dbh, schema => $schema, userID => $userid, bpnum => $settings{bpnum}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process create Best Practice in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} else {
    print &doHeader(title => 'Bad Command', settings => \%settings, form => $form, path => $path);
    print "<br><center>Command $command not known</center>\n";
    print &doFooter;
}

#&db_disconnect($dbh);
&NQS_disconnect($dbh);
exit();
