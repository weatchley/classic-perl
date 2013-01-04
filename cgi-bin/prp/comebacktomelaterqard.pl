#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/prp/perl/RCS/qard.pl,v $
# $Revision: 1.9 $
# $Date: 2005/09/29 15:28:01 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: qard.pl,v $
# Revision 1.9  2005/09/29 15:28:01  naydenoa
# Phase 3 implementation
# Options for AQAP processing added
#
# Revision 1.8  2005/07/08 22:17:39  naydenoa
# CREQ00058 - add AQAP matrix
#
# Revision 1.7  2005/04/15 17:49:10  naydenoa
# Removed call to file utilities - CREQ00052
#
# Revision 1.6  2005/04/07 18:12:47  naydenoa
# Incorporate commands/activities for QAMP - CREQ00047
#
# Revision 1.5  2005/03/28 17:35:17  naydenoa
# Added pop-table option for Table 1 pop-up on browse QARD - CREQ00045
#
# Revision 1.4  2005/02/17 16:42:59  naydenoa
# CREQ00038 - updates to logging for all qard components.
#
# Revision 1.3  2004/12/16 16:32:13  naydenoa
# Added options for table 1a, AQAP handling - phase 2 requirements
#
# Revision 1.2  2004/08/30 21:18:20  naydenoa
# CREQ00010-related modification, add browse_reference option
#
# Revision 1.1  2004/06/16 21:54:49  naydenoa
# Initial revision
#
#

$| = 1;

use strict;
use integer;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UIQARD qw(:Functions);
use DBQARD qw(:Functions);
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
my $sid = $settings{sid};
my $sectionid = $settings{sectionid};
my $sectiontitle = $settings{sectiontitle};
my $parentsectionid = $settings{parentsectionid};
my $sectiontext = $settings{sectiontext};
my $sectionstatusid = $settings{sectionstatusid};
my $error = "";
my $cgi = new CGI;
&checkLogin(cgi => $cgi);
my $errorstr = "";

#! test for invalid or timed out session
&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});

##########################
if ($command eq "stuff") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        #print &doSomeReport(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Run Stuff Command in $form", $@));
    }
    print &doFooter;
}
#####################################
elsif ($command eq "enter_section") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSectionEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Section entry form in $form", $@));
    }
    print &doFooter;
}
#################################
elsif ($command eq "enter_toc") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doTOCEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD TOC Section entry form in $form", $@));
    }
    print &doFooter;
}
##################################
elsif ($command eq "enter_qard") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doRevisionEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, qardtypeid => 1);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Revision entry form in $form", $@));
    }
    print &doFooter;
}
###################################
elsif ($command eq "enter_table") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doTableEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Table 1A entry form in $form", $@));
    }
    print &doFooter;
}
##################################
elsif ($command eq "enter_aqap") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAQAPEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display AQAP entry form in $form", $@));
    }
    print &doFooter;
}
##########################################
elsif ($command eq "enter_section_aqap") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAQAPSectionEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Section entry form in $form", $@));
    }
    print &doFooter;
}
##################################
elsif ($command eq "enter_qamp") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doQAMPEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QAMP entry form in $form", $@));
    }
    print &doFooter;
}
####################################
elsif ($command eq "add_approver") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAddThing (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, what => "Approver");
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display approver entry form in $form", $@));
    }
    print &doFooter;
}
################################
elsif ($command eq "add_type") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAddThing (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, what => "Type");
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display approver entry form in $form", $@));
    }
    print &doFooter;
}
#####################################
elsif ($command eq "enter_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my $logstr = "";
    my $newsectionid = "";
    my $revid = "";
    eval {
        ($newsectionid, $revid) = &processSectionEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process QARD Section entry form in $form", $@));
    }
    else {
        my ($revision) = &getSingleRow (dbh => $dbh, schema => $schema, what => "revid", table => "qard", where => "id = $revid");
        my $isdeleted = ($settings{isdeleted} eq 'T') ? "/deleted" : "";
        my $activity = ($settings{isupdate}) ? 17 : 16;
#        print "<input type=hidden name=rid value=$settings{revisionid}>\n";
        $logstr = ($settings{isupdate}) ? "QARD $revision, Section $newsectionid $sectiontitle updated$isdeleted" : "QARD $revision, Section $newsectionid $sectiontitle added to the system";
        &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", $activity);
	print "<script language=javascript><!--\n";
	print "   alert(\"$logstr\");\n";
#        print "   submitFormA('qard','update_section_select',$revid,'');\n";
#        print "   submitFormSelect('qard','update_select','section');\n";
        print "   submitForm('home','');\n";
	print "//--></script>\n";
    }
    print &doFooter;
}
#########################################
elsif ($command eq "enter_toc_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my $logstr = "";
    my $newtocid = "";
    my $revid = "";
    eval {
        ($newtocid, $revid) = &processTOCEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process QARD TOC Section entry form in $form", $@));
    }
    else {
        my ($revision) = &getSingleRow (dbh => $dbh, schema => $schema, what => "revid", table => "qard", where => "id = $revid");
        my $isdeleted = ($settings{isdeleted} eq 'T') ? "/deleted" : "";
        my $activity = ($settings{isupdate}) ? 15 : 14;
        $logstr = ($settings{isupdate}) ? "QARD $revision, TOC Section $newtocid updated$isdeleted" : "QARD $revision, TOC Section $newtocid added to the system";
        &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", $activity);
	print "<script language=javascript><!--\n";
	print "   alert(\"$logstr\");\n";
	print "   submitForm('home','');\n";
	print "//--></script>\n";
    }
    print &doFooter;
}
##########################################
elsif ($command eq "enter_qard_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my $logstr = "";
    my $newqardid = "";
    my $type = "";
    eval {
        my ($name, $fileContents) = ("","");#&getFile;#("","");
        ($newqardid, $type) = &processRevisionEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, fileName => $name, file => $fileContents, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process QARD Revision entry form in $form", $@));
    }
    else {
        my $isdeleted = ($settings{isdeleted} eq 'T') ? "/deleted" : "";
        my $activity = ($settings{isupdate}) ? 13 : 12;
        my $whichone = "QARD";
        if ($type == 2) {
            $whichone = "AQAP";
        }
        elsif ($type == 3) {
            $whichone = "QAMP";
        }
        $logstr = ($settings{isupdate}) ? "$whichone $newqardid updated$isdeleted" : "$whichone $newqardid added to the system";
        &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", $activity);
	print "<script language=javascript><!--\n";
	print "   alert(\"$logstr\");\n";
	print "   submitForm('home','');\n";
	print "//--></script>\n";
    }
    print &doFooter;
}
###########################################
elsif ($command eq "enter_table_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my $logstr = "";
    my $newrowid = "";
    eval {
        $newrowid = &processTableEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process QARD Table 1A row entry form in $form", $@));
    }
    else {
        my ($revision, $item, $subid) = &getSingleRow (dbh => $dbh, schema => $schema, what => "q.revid, t.item, t.subid", table => "qardtable1a t, $schema.qard q", where => "t.id = '$newrowid' and t.revisionid = q.id");
        $subid = ($subid) ? " - $subid" : "";
        my $isdeleted = ($settings{isdeleted} eq 'T') ? "/deleted" : "";
        my $activity = ($settings{isupdate}) ? 27 : 26;
        $logstr = ($settings{isupdate}) ? "QARD $revision, Table 1A row $item$subid updated$isdeleted" : "QARD $revision, Table 1A row $item$subid added to the system";
        &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", $activity);
	print "<script language=javascript><!--\n";
	print "   alert(\"$logstr\");\n";
	print "   submitForm('home','');\n";
	print "//--></script>\n";
    }
    print &doFooter;
}
###########################################
elsif ($command eq "enter_aqap_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my $logstr = "";
    my $revision = "";
    eval {
        $revision = &processAQAPEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process AQAP entry form in $form", $@));
    }
    else {
        my $isdeleted = ($settings{isdeleted} eq 'T') ? "/deleted" : "";
        my $activity = ($settings{isupdate}) ? 30 : 29;
        $logstr = ($settings{isupdate}) ? "AQAP $revision updated$isdeleted" : "AQAP $revision added to the system";
        &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", $activity);
	print "<script language=javascript><!--\n";
	print "   alert(\"$logstr\");\n";
	print "   submitForm('home','');\n";
	print "//--></script>\n";
    }
    print &doFooter;
}
##########################################
elsif ($command eq "enter_qamp_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my $logstr = "";
    my $revision = "";
    eval {
        $revision = &processQAMPEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process QAMP entry form in $form", $@));
    }
    else {
        my $isdeleted = ($settings{isdeleted} eq 'T') ? "/deleted" : "";
        my $activity = ($settings{isupdate}) ? 34 : 33;
        $logstr = ($settings{isupdate}) ? "QAMP $revision updated$isdeleted" : "QAMP $revision added to the system";
        &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", $activity);
	print "<script language=javascript><!--\n";
	print "   alert(\"$logstr\");\n";
	print "   submitForm('home','');\n";
	print "//--></script>\n";
    }
    print &doFooter;
}
############################################
elsif ($command eq "add_Approver_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my $logstr = "";
    my $name = "";
    eval {
        $name = &processAddApprover (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process approver entry form in $form", $@));
    }
    else {
        my $activity = 32;
        $logstr = "Approver $name added to the system";
        &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", $activity);
	print "<script language=javascript><!--\n";
	print "   alert(\"$logstr\");\n";
	print "   submitForm('utilities','');\n";
	print "//--></script>\n";
    }
    print &doFooter;
}
#####################################
elsif ($command eq "update_matrix") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doMatrixEntryStoQ (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Section browse form in $form", $@));
    }
    print &doFooter;
}
#############################################
elsif ($command eq "enter_matrix_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my $logstr = "";
    my $name = "";
    eval {
        $name = &processMatrixEntryStoQ (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process Source to QARD matrix entry form in $form", $@));
    }
    else {
        my $activity = 32;
        $logstr = "Matrix $name information updated";
        &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", $activity);
	print "<script language=javascript><!--\n";
	print "   alert(\"$logstr\");\n";
	print "   submitForm('home','');\n";
	print "//--></script>\n";
    }
    print &doFooter;
}
##################################
elsif ($command eq "view_image") {
    eval {
        print &doQARDImage (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Revision image in $form", $@));
    }
}
########################################
elsif ($command eq "view_other_image") {
    eval {
        print &doOtherImage (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Revision image in $form", $@));
    }
}
##############################
elsif ($command eq "browse") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSectionBrowse (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Section browse form in $form", $@));
    }
    print &doFooter;
}
#####################################
elsif ($command eq "browse_matrix") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doMatrixSelectStoQ (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Section browse form in $form", $@));
    }
    print &doFooter;
}
####################################
elsif ($command eq "browse_color") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSectionBrowse (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, color => 1);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Section browse form in $form", $@));
    }
    print &doFooter;
}
########################################
elsif ($command eq "browse_reference") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseQARDReference (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD reference browse form in $form", $@));
    }
    print &doFooter;
}
###################################
elsif ($command eq "browse_aqap") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseAQAP (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD reference browse form in $form", $@));
    }
    print &doFooter;
}
###################################
elsif ($command eq "browse_qamp") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseQAMP (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD reference browse form in $form", $@));
    }
    print &doFooter;
}
#####################################
elsif ($command eq "update_select") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateSelect (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Select QARD to update in $form", $@));
    }
    print &doFooter;
}
##########################################
elsif ($command eq "update_select_aqap") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
#        print &doBrowseAQAP (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, isupdate => 1);
#        print &doUpdateSelectAQAP (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
        print &doUpdateSelect (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Select AQAP to update in $form", $@));
    }
    print &doFooter;
}
##########################################
elsif ($command eq "update_select_qamp") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseQAMP (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, isupdate => 1);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Select QAMP to update in $form", $@));
    }
    print &doFooter;
}
###########################################
elsif ($command eq "update_select_table") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateSelectTable (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Select QARD Table 1A row to update in $form", $@));
    }
    print &doFooter;
}
#########################################
elsif ($command eq "update_toc_select") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateSelect (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Select QARD TOC Section for update in $form", $@));
    }
    print &doFooter;
}
#############################################
elsif ($command eq "update_section_select") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateSelect (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Select QARD Section for update in $form", $@));
    }
    print &doFooter;
}
######################################
elsif ($command eq "update_section") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSectionBrowse (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update QARD Section in $form", $@));
    }
    print &doFooter;
}
##################################
elsif ($command eq "update_toc") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSectionBrowse (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update QARD TOC Section in $form", $@));
    }
    print &doFooter;
}
#######################################
elsif ($command eq "update_revision") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSectionBrowse (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update QARD revision in $form", $@));
    }
    print &doFooter;
}
#############################################################
elsif ($command eq "pop_source" || $command eq "pop_table") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path, width => 610);
    eval {
        print &doPopSource (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display source docs relater to QARD Section from browse form in $form", $@));
    }
    print &doFooter;
}
################################################################
elsif ($command eq "undelete_revision" || $command eq "undelete_toc" || $command eq "undelete_section" || $command eq "undelete_table1a" || $command eq "undelete_aqap" || $command eq "undelete_qamp") {
    my $what = "";
    if ($command eq "undelete_revision") {
        $what = "qard";
    }
    elsif ($command eq "undelete_toc") {
        $what = "toc";
    }
    elsif ($command eq "undelete_table1a") {
        $what = "table1a";
    }
    elsif ($command eq "undelete_aqap") {
        $what = "aqap";
    }
    elsif ($command eq "undelete_qamp") {
        $what = "qamp";
    }
    else {
        $what = "section";
    }
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUndeleteSelect (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, what => $what);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display updelete selections for qard/toc/section in $form", $@));
    }
    print &doFooter;
    
}
########################################
elsif ($command eq "undelete_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        print &processUndelete(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process" . $settings{what} . "undelete in $form", $@));
    }
    else {
        my $logstr = "";
        my $activity = 0;
        my $command = "undelete_$settings{what}";
        if ($settings{what} eq "qard" || $settings{what} eq "aqap" || $settings{what} eq "qamp") {
            $command = "undelete_revision" if $settings{what} eq "qard";
            my ($revision) = &getSingleRow (dbh => $dbh, schema => $schema, what => "revid", table => "qard", where => "id = $settings{rid}");
            $logstr = uc($settings{what});
            $logstr .= " $revision undeleted";
            if ($settings{what} eq "qard") {
                $activity = 22;
            }
            elsif ($settings{what} eq "aqap") {
                $activity = 31;
            }
            elsif ($settings{what} eq "qamp") {
                $activity = 35;
            }
        }
        elsif ($settings{what} eq "toc") {
            my ($toc) = &getSingleRow (dbh => $dbh, schema => $schema, what => "'QARD Revision ' ||  q.revid || ', TOC ' || t.tocid", table => "qardtoc t, $schema.qard q", where => "t.id = $settings{tid} and t.revisionid = q.id");
            $logstr = "$toc undeleted";
            $activity = 23;
        }
        elsif ($settings{what} eq "table1a") {
            my ($t1a) = &getSingleRow (dbh => $dbh, schema => $schema, what => "'QARD ' ||  q.revid || ', Table 1A Row ' || t.item || ' - ' || t.subid", table => "qardtable1a t, $schema.qard q", where => "t.id = $settings{rowid} and t.revisionid = q.id");
            $logstr = "$t1a undeleted";
            $activity = 28;
        }
        else { 
            my ($section) = &getSingleRow (dbh => $dbh, schema => $schema, what => "'QARD Revision ' ||  q.revid || ', Section ' || t.sectionid", table => "qardsection t, $schema.qard q", where => "t.id = $settings{sid} and t.qardrevid = q.id");
            $logstr = "$section undeleted";
            $activity = 24;
        }
        &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", $activity);
        print "<script language=javascript><!--\n";
        print "   alert(\"$logstr\");\n";
	print "   submitForm('qard','$command');\n";
	print "//--></script>\n";
    }
    print &doFooter;
}
######################################
else {  # display main menu as default
    print &doHeader(dbh => $dbh, title => "$title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doMainMenu(dbh => $dbh, schema => $schema, title => $title, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Home Main Menu in $form", $@));
    }
    print &doFooter;
}


&db_disconnect($dbh);
exit();
