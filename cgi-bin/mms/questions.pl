#!/usr/local/bin/perl -w

# question functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/questions.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2008/10/21 18:09:06 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: questions.pl,v $
# Revision 1.1  2008/10/21 18:09:06  atchleyb
# Initial revision
#
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
use UIQuestions qw(:Functions);
use DBQuestions qw(:Functions);
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
} elsif ($command eq "displayquestion") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doDisplayQuestion(dbh => $dbh, schema => $schema, title => $title, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Question in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "updatequestionselect") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateQuestionSelect(dbh => $dbh, schema => $schema, title => $title, form => $form, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Question in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "addquestionform" || $command eq "updatequestionform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doQuestionEntryForm(dbh => $dbh, schema => $schema, type => (($command eq "addquestionform") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Add/Update Question form in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "addquestion" || $command eq "updatequestion") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doQuestionEntry(dbh => $dbh, schema => $schema, type => (($command eq "addquestion") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Add/Update Question in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "deletequestion") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doQuestionDelete(dbh => $dbh, schema => $schema, type => (($command eq "addquestion") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Delete Question in $form", $@));
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
