#!/usr/local/bin/perl -w

# bid functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/receiving.pl,v $
#
# $Revision: 1.5 $
#
# $Date: 2009/05/29 21:35:51 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: receiving.pl,v $
# Revision 1.5  2009/05/29 21:35:51  atchleyb
# ACR0905_001 - user change request, multiple changes
#
# Revision 1.4  2006/05/17 22:59:26  atchleyb
# CR0026 - added filter by deliveredto option to browse
#
# Revision 1.3  2005/08/18 18:56:34  atchleyb
# CR00015 - updated to have site filter for browse
#
# Revision 1.2  2004/02/27 00:14:39  atchleyb
# added parameter to browse for fyscal year
#
# Revision 1.1  2003/12/15 18:53:12  atchleyb
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
use UIReceiving qw(:Functions);
use DBReceiving qw(:Functions);
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
            fy => $settings{viewfy}, siteCode => $settings{sitecode}, deliveredto => $settings{deliveredto}, pd=>$settings{prnumber});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "amend") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowse(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, sortBy=> $settings{sortby},
            fy => $settings{viewfy}, siteCode => $settings{sitecode}, deliveredto => $settings{deliveredto}, pd=>$settings{prnumber},
            amendment=>'T', pdStatusList => '7, 11, 16, 18');
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Amend in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "browsereceiving") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doReceivingForm(dbh => $dbh, schema => $schema, title => $title, userID => $userid, path => $path, form => $form, 
              id=>$settings{id}, command=>$command, browseOnly=>'T', site=>$settings{receivingsite});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Receiving brwose in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "receivingform" || $command eq "updaterlogform" || $command eq "newrlogpo" || $command eq "newrlognopo"
        || $command eq "amendreceiving") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path, includeJSCalendar=>'T');
    eval {
        print &doReceivingForm(dbh => $dbh, schema => $schema, title => $title, userID => $userid, path => $path, form => $form, 
              id=>$settings{id}, command=>$command, site=>$settings{receivingsite});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Receiving Entry in $form (command: $command) ", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "savereceiving") {
    print &doHeader(displayTitle => 'F', dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doReceivingSave(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, id=>$settings{rlogid},
              settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Receiving Save in $form", $@));
    }
    print &doFooter(form => $form, path => $path, settings => \%settings);
###################################################################################################################################
} elsif ($command eq "printissuedoc" || $command eq "saveprintissuedoc") {
    eval {
        if ($command eq "saveprintissuedoc") {
        $status = &doProcessReceivingSave(dbh => $dbh, schema => $schema, userID => $settings{userid}, id =>  $settings{rlogid},
              settings => \%settings);
        }
        print &doIssueDocument(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, id=>$settings{rlogid},
              settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Print Issue Document in $form", $@));
        print &doFooter(form => $form, path => $path, settings => \%settings);
    }
###################################################################################################################################
###################################################################################################################################
} else {
    print &doHeader(dbh => $dbh, title => 'Bad Command', settings => \%settings, form => $form, path => $path);
    print "<br><center>Command $command not known</center>\n";
    print &doFooter(form => $form, path => $path, settings => \%settings);
}


&db_disconnect($dbh);
exit();
