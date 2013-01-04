#!/usr/local/bin/perl -w

# Extraction functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/extractions.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2004/11/16 19:34:57 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: extractions.pl,v $
# Revision 1.2  2004/11/16 19:34:57  atchleyb
# added new brwose filters
#
# Revision 1.1  2004/07/27 18:27:16  atchleyb
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
use UIExtractions qw(:Functions);
use DBExtractions qw(:Functions);
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
#print STDERR "\n$command, $settings{sessionID}, $userid, $settings{userid}, " . $cgi->param("userid") . "\n\n";
#&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});


###################################################################################################################################
###################################################################################################################################

###################################################################################################################################
#
if ($command eq "browse") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowse(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form=>$form, sortBy=>$settings{sortby},
              settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "displayextraction") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doDisplayExtraction(dbh => $dbh, schema => $schema, title => $title, ID => $settings{id}, form => $form, 
              settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Extraction in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "updateextractionselect") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateExtractionSelect(dbh => $dbh, schema => $schema, title => $title, form => $form, userID => $userid, 
              docID=>$settings{id}, type=>$settings{extrtype}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Extraction Select in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "addextractionform" || $command eq "updateextractionform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path, useFileUpload=>'T');
    eval {
        print &doExtractionEntryForm(dbh => $dbh, schema => $schema, type => (($command eq "addextractionform") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, includeJSCalendar=>'T',
              includeJSWidgets=>'T', useFileUpload=>'T', settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Extraction Form in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "addextraction" || $command eq "updateextraction") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doExtractionEntry(dbh => $dbh, schema => $schema, type => (($command eq "addextraction") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Extraction in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "displayextractionversion") {
    eval {
        print &doDisplayExtractionVersion(dbh => $dbh, schema => $schema, id=>$settings{id}, version=>$settings{version}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display extraction version in $form", $@));
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
