#!/usr/local/bin/perl -w

# bid functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/bids.pl,v $
#
# $Revision: 1.4 $
#
# $Date: 2009/06/26 21:57:40 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: bids.pl,v $
# Revision 1.4  2009/06/26 21:57:40  atchleyb
# ACR0906_001 - List of changes
#
# Revision 1.3  2008/09/29 17:37:55  atchleyb
# ACR0809_004 - fixed bug with bid remarks being deleted when the bid abstract is generated from the browse form
#
# Revision 1.2  2006/03/15 17:36:15  atchleyb
# CR 0023 - updated to allow generate bid abstract to save bid comments first
#
# Revision 1.1  2003/12/02 16:49:31  atchleyb
# Initial revision
#
#
#
#

# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use UIShared qw(:Functions);
use DBShared qw(:Functions);
use Tie::IxHash;
use UIBids qw(:Functions);
use DBBids qw(:Functions);
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
} elsif ($command eq "browsebid") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBidEntryForm(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, id=>$settings{id},
              browseOnly=>'T', settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Bid Select in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "bidsform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBidsForm(dbh => $dbh, schema => $schema, title => $title, userID => $userid, path => $path, form => $form, 
              id=>$settings{id});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Bid Select in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "bidentry") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path, includeJSCalendar=>'T');
    eval {
        print &doBidEntryForm(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, id=>$settings{id},
              settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Bid Entry in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "savebid") {
    print &doHeader(displayTitle => 'F', dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBidSave(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, id=>$settings{bidid},
              settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Bid Save in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "addvendor") {
    print &doHeader(displayTitle => 'F', dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAddVendor(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form,
              settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Bid Save in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "bidabstract") {
    eval {
        if ($settings{'dobidsaveremark'} eq "T") {
            print &doSaveBidRemarks(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
                  reload => 'F', id => $settings{id}, settings => \%settings);
        }
        print &doBidAbstract(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form,
              id => $settings{id});
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate a PDF for a bid abstract in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
} elsif ($command eq "bidsaveremarks") {
    print &doHeader(displayTitle => 'F', dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSaveBidRemarks(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, 
              reload => $settings{reload}, id => $settings{id}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Save remarks for a bid in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "bidaward") {
    print &doHeader(displayTitle => 'F', dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBidAward(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form,
              pd => $settings{prnumber}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Bid award in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "deletebid") {
    print &doHeader(displayTitle => 'F', dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBidDelete(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, id=>$settings{bidid},
              settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Bid Save in $form", $@));
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
