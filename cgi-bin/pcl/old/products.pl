#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/scm/perl/RCS/products.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2002/10/09 18:35:09 $
#
# $Author: starkeyj $
#
# $Locker: starkeyj $
#
# $Log: products.pl,v $
# Revision 1.2  2002/10/09 18:35:09  starkeyj
# functions to browse products, product versions, and configuration items for a product version
#
# Revision 1.1  2002/09/27 00:14:08  starkeyj
# Initial revision
#
#
#
#

use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIProducts qw(:Functions);
use DBProducts qw(:Functions);
use UI_Widgets qw(:Functions);

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
my $projectID = $settings{projectID};
my $productID = $settings{productID};
my $minorversion = $settings{minorversion};
my $itemType = $settings{itemType};
my $title = $settings{title};
my $error = "";

&checkLogin ($username, $userid, $schema);
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
    print &doHeader(title => 'Browse Products', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseProductTable(dbh => $dbh, schema => $schema, itemType => $itemType, title => $title, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "browseversions") {
    print &doHeader(title => 'Browse ' . $title . 's', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseProductVersions(dbh => $dbh, schema => $schema, product => $productID, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse Version in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "browseitems") {
    print &doHeader(title => 'Browse ' . $title . 's', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseProductItems(dbh => $dbh, schema => $schema, product => $productID, minorversion => $minorversion, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse Version in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "updateselect") {
    print &doHeader(title => "Update $title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateSelect(dbh => $dbh, schema => $schema, userID => $userid, form => $form);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Select in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "update") {
    print &doHeader(title => "Update $title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseDocumentTable(dbh => $dbh, schema => $schema, itemType => $itemType, title => $title, update => 'T', userID => $userid, 
              project => $settings{'project'});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "updateinformation") {
    print &doHeader(title => "Update $title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateDocumentInfoForm(dbh => $dbh, schema => $schema, document => $settings{'document'}, 
              title => $title, form => $form, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Information in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "updateinformationprocess") {
    print &doHeader(DisplayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessUpdateDocumentInfo(dbh => $dbh, schema => $schema, document => $settings{'itemid'}, 
              name => $settings{'name'}, description => $settings{'description'}, title => $title, form => $form, userID => $userid, 
              project => $settings{'project'});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Information processing in $form", $@));
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
