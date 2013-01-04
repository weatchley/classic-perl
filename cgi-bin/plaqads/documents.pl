#!/usr/local/bin/perl -w

# Document functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/documents.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2004/11/16 19:34:25 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: documents.pl,v $
# Revision 1.2  2004/11/16 19:34:25  atchleyb
# added new browse filters
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
use UIDocuments qw(:Functions);
use DBDocuments qw(:Functions);
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
        print &doBrowse(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form=>$form, sortBy=>$settings{sortby}, 
            settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "displaydocument") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doDisplayDocument(dbh => $dbh, schema => $schema, title => $title, ID => $settings{id}, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Document in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "updatedocumentselect") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateDocumentSelect(dbh => $dbh, schema => $schema, title => $title, form => $form, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Document Select in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "adddocumentform" || $command eq "updatedocumentform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path, includeJSCalendar=>'T', useFileUpload=>'T');
    eval {
        print &doDocumentEntryForm(dbh => $dbh, schema => $schema, type => (($command eq "adddocumentform") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, includeJSCalendar=>'T',
              includeJSWidgets=>'T', useFileUpload=>'T', settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Document Form in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "adddocument" || $command eq "updatedocument") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doDocumentEntry(dbh => $dbh, schema => $schema, type => (($command eq "adddocument") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Document in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "displaydocumentversion") {
    eval {
        print &doDisplayDocumentVersion(dbh => $dbh, schema => $schema, id=>$settings{id}, version=>$settings{version}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display document version in $form", $@));
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
