#!/usr/local/bin/perl -w

# business rules functions
#
# $Source: /data/dev/rcs/mms/perl/RCS/businessRules.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/04/21 17:04:10 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: businessRules.pl,v $
# Revision 1.1  2004/04/21 17:04:10  atchleyb
# Initial revision
#
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
use UIBusinessRules qw(:Functions);
use DBBusinessRules qw(:Functions);
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
        print &doUpdateRuleSelect(dbh => $dbh, schema => $schema, title => $title, form => $form, userID => $userid, 
              browseOnly=>'T', settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "displayrule") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doRuleEntryForm(dbh => $dbh, schema => $schema, browseOnly=>'T', 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Rule in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "updateruleselect") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateRuleSelect(dbh => $dbh, schema => $schema, title => $title, form => $form, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Rule in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "addruleform" || $command eq "updateruleform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doRuleEntryForm(dbh => $dbh, schema => $schema, type => (($command eq "addruleform") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Add/Update Rule form in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "addrule" || $command eq "updaterule") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doRuleEntry(dbh => $dbh, schema => $schema, type => (($command eq "addrule") ? 'new' : 'update'), 
              title => $title, form => $form,  userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Add/Update Rule in $form", $@));
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
