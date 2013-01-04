#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/prp/perl/RCS/requirement.pl,v $
# $Revision: 1.8 $
# $Date: 2006/06/14 20:36:48 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: requirement.pl,v $
# Revision 1.8  2006/06/14 20:36:48  naydenoa
# Modified to get criterion id from DB module for log entry on matrix process.
#
# Revision 1.7  2006/06/13 23:40:47  naydenoa
# CREQ00078 - process added activity log detail.
#
# Revision 1.6  2006/01/06 17:45:13  naydenoa
# Added new redirect after matrix processing.
#
# Revision 1.5  2005/09/29 15:29:25  naydenoa
# Phase 3 implementation
# Added options for separate processing of criteria and matrices
#
# Revision 1.4  2005/03/22 18:37:31  naydenoa
# Added optional table width to header calls
#
# Revision 1.3  2004/06/18 21:28:48  naydenoa
# Redirect to select source on requirement update - bug, CR00006
#
# Revision 1.2  2004/06/16 21:37:09  naydenoa
# Added undelete, QARD assignment - P1C2
#
# Revision 1.1  2004/04/22 20:51:29  naydenoa
# Initial revision
#
#

$| = 1;

use strict;
use integer;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UIRequirement qw(:Functions);
use DBRequirement qw(:Functions);
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
my $sourceid = ($settings{sourceid}) ? $settings{sourceid} : $settings{sid};
my $qrsectionid = $settings{qrsectionid};
my $qracceptancecriterion = $settings{qracceptancecriterion};
my $qractext = $settings{qractext};
my $qrsubsection = $settings{qrsubsection};
my $qrtext = $settings{qrtext};
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
#############################
elsif ($command eq "enter") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        if ($settings{matrix}) {
            print &doSourceRequirementEntryMatrix (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, isupdate => $settings{isupdate});
        }
	else {
            print &doSourceRequirementEntry (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, isupdate => $settings{isupdate});
	}
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Requirement entry form in $form", $@));
    }
    print &doFooter;
}
#####################################
elsif ($command eq "enter_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my ($docnum) = &getSingleRow (dbh => $dbh, schema => $schema, table => "source", what => "designation", where => "id = $settings{sourceid}");
    eval {
        print &processSourceRequirementEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process QARD Requirement entry/update in $form", $@));
    }
    else {
    my $logstr = "";
        if ($settings{isupdate} == 1) {
            my $isdeleted = ($settings{isdeleted} eq 'T') ? "/deleted" : "";
	    my $logstr = "QARD Requirement $settings{requirementid} from source document $docnum, section $settings{qrsectionid} updated$isdeleted";
	    &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", 11);
            print "<input type=hidden name=rid value=$settings{rid}>\n";
            print "<input type=hidden name=sid value=$settings{sid}>\n";
            print "<input type=hidden name=sourceid value=$settings{sid}>\n";
            print "<input type=hidden name=isupdate value=1>\n";
	    print "<script language=javascript><!--\n";
	    print "   alert(\"$logstr\");\n";
	    print "   submitForm('home','');\n";
#	    print "   submitForm('source','browse');\n";
#	    print "   submitForm('requirement','update_select');\n";
#	    print "   submitFormUpdate('requirement','browse',1);\n";
	}
        else {
	    my $logstr = "QARD Requirement $settings{requirementid} from source document $docnum, section $settings{qrsectionid} added to the system";
	    &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", 10);
	    print "<script language=javascript><!--\n";
	    print "   alert(\"$logstr\");\n";
#	    print "   submitForm('requirement','enter');\n";
	    print "   submitForm('home','');\n";
	}
	print "//--></script>\n";
    }
    print &doFooter;
}
####################################
elsif ($command eq "enter_matrix") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSourceRequirementEntryMatrix(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Requirement entry form in $form", $@));
    }
    print &doFooter;
}
#########################################
elsif ($command eq "enter_matrix_aqap") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSourceRequirementEntryMatrix(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, qardtypeid => 2);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Requirement entry form in $form", $@));
    }
    print &doFooter;
}
############################################
elsif ($command eq "enter_matrix_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my ($docnum) = &getSingleRow (dbh => $dbh, schema => $schema, table => "source", what => "designation", where => "id = $settings{sourceid}");
    my $matrixid = 0;
    my $qardtypeid = 0;
    my $oldsections = "";
    my $newsections = "";
    my $criterion = "";
    eval {
        ($matrixid, $qardtypeid, $oldsections, $newsections, $criterion) =  &processSourceMatrixEntry (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process matrix assignments by criterion in $form", $@));
    }
    else {
        my $isdeleted = ($settings{isdeleted} eq 'T') ? "/deleted" : "";
        my $logstr = "Matrix assignment for criterion $criterion from source document $docnum. $oldsections $newsections";
	&updateActivityLog ($dbh, $schema, $userid, $logstr, "F", 11);
        print "<input type=hidden name=rid value=$settings{rid}>\n";
        print "<input type=hidden name=sid value=$settings{sid}>\n";
        print "<input type=hidden name=sourceid value=$settings{sid}>\n";
        print "<input type=hidden name=matrixid value=$matrixid>\n";
        print "<input type=hidden name=qardtypeid value=$qardtypeid>\n";
        print "<input type=hidden name=isupdate value=1>\n";
	print "<script language=javascript><!--\n";
	print "   alert(\"$logstr\");\n";
	print "   submitFormMatrix('requirement','browse_matrix',$matrixid);\n";
#	print "   submitForm('home','');\n";
#	 print "   submitForm('source','browse');\n";
#	 print "   submitForm('requirement','update_select');\n";
#	print "   submitFormUpdate('requirement','browse',1,$settings{sourceid});\n";
	print "//--></script>\n";
    }
    print &doFooter;
}
######################################
elsif ($command eq "approve_matrix") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doApproveMatrix(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Requirement entry form in $form", $@));
    }
    print &doFooter;
}
##############################################
elsif ($command eq "approve_matrix_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my ($mname) = &getSingleRow (dbh => $dbh, schema => $schema, table => "matrix", what => "title", where => "id = $settings{approvalmatrixid}");
    eval {
        print &processApproveMatrix (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process matrix approval in $form", $@));
    }
    else {
        my $logstr = "Matrix $mname approved";
	&updateActivityLog ($dbh, $schema, $userid, $logstr, "F", 11);
	print "<script language=javascript><!--\n";
	print "   alert(\"$logstr\");\n";
	print "   submitForm('home','');\n";
	print "//--></script>\n";
    }
    print &doFooter;
}
##############################################
elsif ($command eq "disapprove_matrix_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my ($mname) = &getSingleRow (dbh => $dbh, schema => $schema, table => "matrix", what => "title", where => "id = $settings{approvalmatrixid}");
    eval {
        print &processApproveMatrix (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, approve => 0);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process matrix approval in $form", $@));
    }
    else {
        my $logstr = "Matrix $mname disapproved";
	&updateActivityLog ($dbh, $schema, $userid, $logstr, "F", 11);
	print "<script language=javascript><!--\n";
	print "   alert(\"$logstr\");\n";
	print "   submitForm('home','');\n";
	print "//--></script>\n";
    }
    print &doFooter;
}
#####################################
elsif ($command eq "update_select") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSourceUpdateSelect (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, what => "requirement");
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Source Document select for update in $form", $@));
    }
    print &doFooter;
}
##############################
elsif ($command eq "browse") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSourceRequirementBrowse (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Requirements browse in $form", $@));
    }
    print &doFooter;
}
#####################################
elsif ($command eq "browse_matrix") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSourceRequirementBrowse (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, matrix => 1);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Requirements browse in $form", $@));
    }
    print &doFooter;
}
#####################################
elsif ($command eq "browse_detail") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        if (($settings{sourceid} == -1 && $settings{qardtypeid} == 1) || ($settings{aqapsourceid} == -1 && $settings{qardtypeid} == 2)) {
            print &doSourceBrowse (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
        }
        else {
            print &doSourceBrowseDetail (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
        }
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Source Document Requirements table in $form", $@));
    }
    print &doFooter;
}
##################################
elsif ($command eq "pop_qard") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path, width => 610);
    eval {
        print &doPopQARD (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display QARD Sections related to specific source requirement from browse form in $form", $@));
    }
    print &doFooter;
}
################################################################
elsif ($command eq "undelete") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUndeleteSelect (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display undelete selections for source requirement in $form", $@));
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
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process source requirement undelete in $form", $@));
    }
    else {
        my $logstr = "";
	my ($sourcerequirement) = &getSingleRow (dbh => $dbh, schema => $schema, what => "'Source document ' || s.designation || ', Requirement ' || r.sectionid || ' - ' || r.requirementid", table => "sourcerequirement r, $schema.source s", where => "r.id = $settings{qrid} and r.sourceid = s.id");
	$logstr = "$sourcerequirement undeleted";
	&updateActivityLog ($dbh, $schema, $userid, $logstr, "F", 21);
	print "<script language=javascript><!--\n";
	print "   alert(\"$logstr\");\n";
	print "   submitForm('requirement','undelete');\n";
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
