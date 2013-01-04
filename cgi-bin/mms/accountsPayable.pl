#!/usr/local/bin/perl -w

# accounts payable functions
#
# $Source: /data/dev/rcs/mms/perl/RCS/accountsPayable.pl,v $
#
# $Revision: 1.5 $
#
# $Date: 2006/05/17 22:41:05 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: accountsPayable.pl,v $
# Revision 1.5  2006/05/17 22:41:05  atchleyb
# CR0026 - added commands saveapnew, approvesavenew, and finalizesaveupdate
#
# Revision 1.4  2005/08/18 18:20:24  atchleyb
# CR00015 - changed option for browse seletion to filter by site
#
# Revision 1.3  2004/05/05 23:12:01  atchleyb
# added calling parameters
#
# Revision 1.2  2004/02/27 00:26:45  atchleyb
# added fy to browse call
#
# Revision 1.1  2004/01/08 17:31:57  atchleyb
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
use UIShared qw(:Functions);
use DBShared qw(:Functions);
use Tie::IxHash;
use UIAccountsPayable qw(:Functions);
use DBAccountsPayable qw(:Functions);
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
my $status;

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
        print &doBrowse(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, sortBy=> $settings{sortby},
            fy=> $settings{viewfy}, statusList => $settings{viewstatus}, siteCode => $settings{sitecode});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "browseap") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAPForm(dbh => $dbh, schema => $schema, title => $title, userID => $userid, path => $path, form => $form, 
              id=>$settings{id}, command=>$command, browseOnly=>'T', site=>$settings{receivingsite});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "AP brwose in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "apform" || $command eq "updateapform" || $command eq "newap" 
        || $command eq "approveapform" || $command eq "finalizeapform") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path, includeJSCalendar=>'T');
    eval {
        print &doAPForm(dbh => $dbh, schema => $schema, title => $title, userID => $userid, path => $path, form => $form, 
              id=>$settings{id}, command=>$command);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "AP Entry in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "saveap" || $command eq "saveapnew" || $command eq "approvesave" || $command eq "approvesavenew" 
        || $command eq "finalizesave" || $command eq "finalizesaveupdate") {
    print &doHeader(displayTitle => 'F', dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAPSave(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, id=>$settings{apid},
              command=>$command, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "AP Save in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "closepo") {
    print &doHeader(displayTitle => 'F', dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doClosePO(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, id=>$settings{id},
              settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "PO Close in $form", $@));
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
