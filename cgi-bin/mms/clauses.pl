#!/usr/local/bin/perl -w

# Clause functions
#
# $Source: /home/atchleyb/rcs/mms/perl/RCS/clauses.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2003/11/12 20:38:25 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: clauses.pl,v $
# Revision 1.1  2003/11/12 20:38:25  atchleyb
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
use UIClauses qw(:Functions);
use DBClauses qw(:Functions);
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
        print &doBrowse(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "displayclause") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doDisplayClause(dbh => $dbh, schema => $schema, title => $title, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Clause in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "updateclauseselect") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateClauseSelect(dbh => $dbh, schema => $schema, title => $title, form => $form, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Clause in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "addclauseform" || $command eq "updateclauseform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doClauseEntryForm(dbh => $dbh, schema => $schema, type => (($command eq "addclauseform") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Add/Update Clause form in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "addclause" || $command eq "updateclause") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doClauseEntry(dbh => $dbh, schema => $schema, type => (($command eq "addclause") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Add/Update Clause in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
###################################################################################################################################
} else {
    print &doHeader(dbh => $dbh, title => 'Bad Command', settings => \%settings, form => $form, path => $path);
    print "<br><center>Command $command not known</center>\n";
    print &doFooter(form => $form, path => $path, settings => \%settings);
}


&db_disconnect($dbh);
exit();
