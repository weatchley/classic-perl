#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/prp/perl/RCS/source.pl,v $
# $Revision: 1.5 $
# $Date: 2005/09/29 15:32:03 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: source.pl,v $
# Revision 1.5  2005/09/29 15:32:03  naydenoa
# Phase 3 implementation
# Added options for matrix processing and separation of source types
#
# Revision 1.4  2004/07/19 23:33:16  naydenoa
# CREQ00013 fulfillment
#
# Revision 1.3  2004/06/16 21:38:30  naydenoa
# Added matrix, update, undelete processing - P1C2
#
# Revision 1.2  2004/04/23 23:41:57  naydenoa
# Removed extraneous if statement
#
# Revision 1.1  2004/04/22 20:53:29  naydenoa
# Initial revision
#
#

$| = 1;

use strict;
use integer;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UISource qw(:Functions);
use DBSource qw(:Functions);
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
my $sourceid = $settings{sourceid};
my $sourcetitle = $settings{sourcetitle};
my $sourcedesignation = $settings{sourcedesignation};
my $sourcetypeid = $settings{sourcetypeid};
my $matrixtitle = $settings{matrixtitle};
my $error = "";
my $cgi = new CGI;
&checkLogin(cgi => $cgi);
my $errorstr = "";

#! test for invalid or timed out session
&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});

##########################
if ($command eq "enter") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSourceEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Source Document entry form in $form", $@));
    }
    print &doFooter;
}
#####################################
elsif ($command eq "enter_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my $logstr = "Source document $sourcedesignation added to the system";
    eval {
        my ($name, $fileContents) = &getFile;
        print &processSourceEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, fileName => $name, file => $fileContents, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Source Document entry form in $form", $@));
    }
    else {
        if ($settings{isupdate} == 1) {
            my $isdeleted = ($settings{isdeleted} eq 'T') ? "/deleted" : "";
            $logstr = "Source document $sourcedesignation updated$isdeleted";
            &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", 9);
	    print "<script language=javascript><!--\n";
	    print "   alert(\"$logstr\");\n";
#	    print "   submitForm('source','browse');\n";
	    print "   submitForm('home','');\n";
	    print "//--></script>\n";
        }
        else { 
            &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", 8);
	    print "<script language=javascript><!--\n";
	    print "   alert(\"$logstr\");\n";
	    print "   submitForm('home','');\n";
	    print "//--></script>\n";
        }
    }
    print &doFooter;
}
#################################
elsif ($command eq "enter_matrix") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doMatrixEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Source Document entry form in $form", $@));
    }
    print &doFooter;
}
############################################
elsif ($command eq "enter_matrix_process") {
    print &doHeader(dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        print &processMatrixEntry(dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Source Document entry form in $form", $@));
    }
    else {
        my $logstr = "";
        if ($settings{isupdate} == 1) {
            my $isdeleted = ($settings{isdeleted} eq 'T') ? "/deleted" : "";
            $logstr = "Matrix $matrixtitle updated$isdeleted";
            &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", 19);
	    print "<script language=javascript><!--\n";
	    print "   alert(\"$logstr\");\n";
	    print "   submitForm('home','');\n";
	    print "//--></script>\n";
        }
        else { 
            $logstr = "Matrix $matrixtitle added to the system";
            &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", 18);
	    print "<script language=javascript><!--\n";
	    print "   alert(\"$logstr\");\n";
	    print "   submitForm('home','');\n";
	    print "//--></script>\n";
        }
    }
    print &doFooter;
}
#####################################
elsif ($command eq "update_select") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSourceUpdateSelect (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, what => "source", from => "source");
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Source Document select for update in $form", $@));
    }
    print &doFooter;
}
############################################
elsif ($command eq "update_matrix_select") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doMatrixUpdateSelect (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display compliance matrix select for update in $form", $@));
    }
    print &doFooter;
}
#############################
elsif ($command eq "browse") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doSourceBrowse (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Source Document entry form in $form", $@));
    }
    print &doFooter;
}
#####################################
elsif ($command eq "browse_detail") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
#        if ($settings{sourceid} == -1) {
            print &doSourceBrowse (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
#	}
#        else {
#            print &doSourceBrowseDetail (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
#        }
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Source Document entry form in $form", $@));
    }
    print &doFooter;
}
##################################
elsif ($command eq "view_image") {
    eval {
        print &doSourceImage (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Source Document image in $form", $@));
    }
}
################################################################
elsif ($command eq "undelete" || $command eq "undelete_matrix") {
    my $what = ($command eq "undelete") ? "source" : "matrix";
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doUndeleteSelect (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings, what => $what);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display updelete selections for source/matrix in $form", $@));
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
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Process Source/Matrix undelete in $form", $@));
    }
    else {
        my $logstr = "";
        if ($settings{what} eq "source") {
            my ($source) = &getSingleRow (dbh => $dbh, schema => $schema, what => "designation", table => "source", where => "id = $settings{sid}");
            $logstr = "Source $source undeleted";
            &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", 20);
	    print "<script language=javascript><!--\n";
	    print "   alert(\"$logstr\");\n";
	    print "   submitForm('source','undelete');\n";
	    print "//--></script>\n";
        }
        else { 
            $logstr = "Matrix $settings{matrixid} undeleted";
            &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", 25);
	    print "<script language=javascript><!--\n";
	    print "   alert(\"$logstr\");\n";
	    print "   submitForm('source','undelete_matrix');\n";
	    print "//--></script>\n";
        }
    }
    print &doFooter;
}
#############################
elsif ($command eq "add_type") {
    print &doHeader(dbh => $dbh, title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doAddSourceType (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox (text => errorMessage($dbh, $username, $userid, $schema, "Display Source Document entry form in $form", $@));
    }
    print &doFooter;
}
########################################
elsif ($command eq "add_type_process") {
    print &doHeader (dbh => $dbh, displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    my $logstr = "Source document type $settings{sourcetype} added to the system";
    eval {
        print &processAddSourceType (dbh => $dbh, schema => $schema, title => $title, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display Source Document type entry form in $form", $@));
    }
    else {
        &updateActivityLog ($dbh, $schema, $userid, $logstr, "F", 8);
        print "<script language=javascript><!--\n";
	print "   alert(\"$logstr\");\n";
	print "   submitForm('utilities','');\n";
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
