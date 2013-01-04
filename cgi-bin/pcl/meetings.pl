#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/scm/perl/RCS/meetings.pl,v $
#
# $Revision: 1.7 $
#
# $Date: 2002/12/11 22:51:29 $
#
# $Author: johnsonc $
#
# $Locker:  $
#
# $Log: meetings.pl,v $
# Revision 1.7  2002/12/11 22:51:29  johnsonc
# Added create SCCB meeting functionality
#
# Revision 1.6  2002/11/07 21:58:50  atchleyb
# updated to include UI_scm
#
# Revision 1.5  2002/11/07 16:15:44  starkeyj
#  modified to pass the CGI reference instead of the username, userid, and schema variables to checkLogin
#
# Revision 1.4  2002/10/31 17:55:05  atchleyb
# reenabled checkLogin
#
# Revision 1.3  2002/10/11 20:01:18  starkeyj
# modified browse subroutine to pass the project id as selected from the browse screen
#
# Revision 1.2  2002/10/09 22:13:04  starkeyj
#  added functions to get meeting agenda and meeting minutes
#
# Revision 1.1  2002/09/27 00:13:30  starkeyj
# Initial revision
#

use strict;
use SCM_Header qw(:Constants);
use DB_scm qw(:Functions);
use UI_scm qw(:Functions);
use UIMeetings qw(:Functions);
use DBMeetings qw(:Functions);
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
my $projectID = $settings{projectID};
my $project = $settings{project};
my $sccbID = $settings{sccbID};
my $mtgdate = $settings{mtgdate};
my $attachmentnum = $settings{attachmentnum};
my $itemType = $settings{itemType};
my $title = $settings{title};
my $error = "";
my $cgi = new CGI;
&checkLogin(cgi => $cgi);
my $errorstr = "";

#$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
#$dbh->{LongReadLen} = 10000000;


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "browse") {
    print &doHeader(title => 'Browse SCCB Meetings', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseMeetingTable(dbh => $dbh, schema => $schema, project => $project, title => $title);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "browseagenda") {
    print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseAgenda(dbh => $dbh, schema => $schema, mtgdate => $mtgdate, sccbid => $sccbID, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse Version in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "browseminutes") {
  	 print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
  	 eval {
		  print &doBrowseMinutes(dbh => $dbh, schema => $schema, mtgdate => $mtgdate, sccbid => $sccbID, userID => $userid);
  };
  if ($@) {
		  print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse Version in $form", $@));
  }
  print &doFooter;
###################################################################################################################################
} elsif ($command eq "displaydocument") {
    eval {
        print &doDisplayDocument(dbh => $dbh, schema => $schema, itemType => $itemType, sccbid => $sccbID, mtgdate => $mtgdate, attachmentnum => $attachmentnum);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display document in $form", $@));
        print &doFooter;
    }
###################################################################################################################################
} elsif ($command eq "add") {
    print &doHeader(title => "Add $title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doAddDocumentForm(dbh => $dbh, schema => $schema, itemType => $itemType, title => $title, form => $form, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Add in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "addprocess") {
    print &doHeader(DisplayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        my ($name, $fileContents) = &getFile;
        print &doProcessAddDocument(dbh => $dbh, schema => $schema, itemType => $settings{'itemtype'}, 
              project => $settings{'project'}, title => $title, 
              form => $form, file => $fileContents, fileName => $name, majorVersion => $settings{'major'}, minorVersion => $settings{'minor'}, 
              description => $settings{'description'}, userID => $userid, userName => $username);
        
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Add processing in $form", $@));
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
} elsif ($command eq "updatedocument") {
    print &doHeader(title => "Update $title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateDocumentForm(dbh => $dbh, schema => $schema, document => $settings{'document'}, 
              itemType => $itemType, title => $title, form => $form, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Document in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "updatedocumentprocess") {
    print &doHeader(DisplayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        my ($name, $fileContents) = &getFile;
        print &doProcessUpdateDocument(dbh => $dbh, schema => $schema, itemID => $settings{'itemid'}, title => $title, form => $form, 
              file => $fileContents, fileName => $name, majorVersion => $settings{'major'}, minorVersion => $settings{'minor'}, 
              description => $settings{'description'}, userID => $userid, userName => $username);
        
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update processing in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "createmeeting") {
	$settings{sccbID} = $settings{sccbIDMeeting};
    print &doHeader(title => 'Create SCCB Meeting', includeJSUtilities => 'T', settings => \%settings, form => $form, path => $path);
    eval {
        print &doCreateMeeting(dbh => $dbh, schema => $schema, projectID => $projectID, sccbID => $settings{sccbIDMeeting}, form => $form);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Create Meeting in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "processcreatemeeting") {
    print &doHeader(DisplayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        print &doProcessCreateMeeting(dbh => $dbh, schema => $schema, projectID => $projectID, sccbID => $settings{sccbID},
        							  settings => \%settings, form => $form);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Create Meeting processing in $form", $@));
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
