#!/usr/local/bin/perl -w
#
# $Source: /usr/local/homes/gilmored/rcs/prp/perl/RCS/reports.pl,v $
# $Revision: 1.7 $
# $Date: 2009/02/06 19:58:14 $
# $Author: gilmored $
# $Locker: gilmored $
#
# $Log: reports.pl,v $
# Revision 1.7  2009/02/06 19:58:14  gilmored
# Added check for GUEST user
#
# Revision 1.6  2005/09/29 15:28:37  naydenoa
# Phase 3 implementation
# Added options for AQAP reports generation
#
# Revision 1.5  2005/02/17 16:43:43  naydenoa
# CREQ00040 - added qard to source options
#
# Revision 1.4  2004/12/16 17:08:22  naydenoa
# Added table 1a pdf report option - phase 2, CREQ00024
#
# Revision 1.3  2004/09/13 20:30:28  naydenoa
# Added settings to arguments passed to UIReports module calls - CREQ00005
#
# Revision 1.2  2004/06/16 21:36:16  naydenoa
# Enabled for P1C2
#
# Revision 1.1  2004/04/22 20:50:20  naydenoa
# Initial revision
#
#

$| = 1;

use strict;
use integer;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UIReports qw(:Functions);
use DBReports qw(:Functions);
use UI_Widgets qw(:Functions);
use CGI;

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
my $title = $settings{title};
my $matrixid = $settings{matrixid};
my $matrixtitle = $settings{matrixtitle};

my $error = "";
my $cgi = new CGI;
if($username ne "" && $username ne "GUEST") { &checkLogin(cgi => $cgi); }
my $errorstr = "";

#! test for invalid or timed out session
&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});

##########################################################
if ($command eq "report" || $command eq "view_activity") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        #print &doSomeReport(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
        print &underConstruction ();
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Run Some Report in $form", $@));
    }
    print &doFooter;
} 
##############################
elsif ($command eq "main_qard") {
    print &doHeader (dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
	print &doMainQARDReport (dbh => $dbh, schema => $schema, matrixid => $matrixid, matrixtitle => $matrixtitle, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate QARD-Requirements matrix $matrixid HTML in $form", $@));
    }
    print &doFooter;
}
##############################
elsif ($command eq "main_aqap") {
    print &doHeader (dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
	print &doMainAQAPReport (dbh => $dbh, schema => $schema, matrixid => $matrixid, matrixtitle => $matrixtitle, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate QARD-Requirements matrix $matrixid HTML in $form", $@));
    }
    print &doFooter;
}
################################
elsif ($command eq "html_report") {
    print &doHeader (dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
	print &doDisplayHTMLReport (dbh => $dbh, schema => $schema, matrixid => $matrixid, matrixtitle => $matrixtitle, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate QARD-Requirements matrix $matrixid HTML in $form", $@));
    }
    print &doFooter;
}
##################################
elsif ($command eq "pdf_report") {
    eval {
	print &doDisplayPDFReport (dbh => $dbh, schema => $schema, matrixid => $matrixid, matrixtitle => $matrixtitle, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate QARD-Requirements matrix $matrixid PDF in $form", $@));
    }
}
#######################################
elsif ($command eq "pdf_report_aqap") {
    eval {
	print &doDisplayPDFAQAP (dbh => $dbh, schema => $schema, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate AQAP-Requirements matrix PDF in $form", $@));
    }
}
#####################################
elsif ($command eq "html_report_qtos") {
    print &doHeader (dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
	print &doDisplayQtoSHTMLReport (dbh => $dbh, schema => $schema, matrixid => $matrixid, matrixtitle => $matrixtitle, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate QARD-Requirements matrix $matrixid HTML in $form", $@));
    }
    print &doFooter;
}
#######################################
elsif ($command eq "pdf_report_qtos") {
    eval {
	print &doDisplayQtoSPDFReport (dbh => $dbh, schema => $schema, matrixid => $matrixid, matrixtitle => $matrixtitle, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate QARD-Requirements matrix $matrixid PDF in $form", $@));
    }
}
#################################
elsif ($command eq "pdf_table") {
    eval {
	print &doDisplayPDFTable1A (dbh => $dbh, schema => $schema, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Generate QARD-Requirements matrix $matrixid PDF in $form", $@));
    }
}
######################################
else {  # display main menu as default
    print &doHeader(dbh => $dbh, title => "$title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doRealMainMenu(dbh => $dbh, schema => $schema, title => $title, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Reports Main Menu in $form", $@));
    }
    print &doFooter;
}

#####################
&db_disconnect($dbh);
exit();
