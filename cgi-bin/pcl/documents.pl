#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/documents.pl,v $
#
# $Revision: 1.16 $
#
# $Date: 2003/02/12 16:33:05 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: documents.pl,v $
# Revision 1.16  2003/02/12 16:33:05  atchleyb
# added session management
#
# Revision 1.15  2003/02/10 18:16:21  atchleyb
# removed refs to PCL
#
# Revision 1.14  2002/11/15 17:38:58  atchleyb
# updated to remove refferences to RCS code
#
# Revision 1.13  2002/11/07 23:45:36  atchleyb
# updated updateselect title to use nonLNproject param
#
# Revision 1.12  2002/11/07 23:17:08  starkeyj
# modified parameter name returned from html form
#
# Revision 1.11  2002/11/07 16:19:50  starkeyj
#  modified to pass the CGI reference instead of the username, userid, and schema variables to checkLogin
#
# Revision 1.10  2002/11/06 21:35:52  atchleyb
# updated titles and passing project into add document
#
# Revision 1.9  2002/10/31 17:51:11  atchleyb
# reenabled checkLogin
#
# Revision 1.8  2002/10/24 21:55:30  atchleyb
# updated to handle policies
#
# Revision 1.7  2002/10/18 17:02:36  atchleyb
# updated to allow procedures and templates to be in different table sets
#
# Revision 1.6  2002/10/03 16:39:12  atchleyb
# added function to display signed documents (PDF's)
#
# Revision 1.5  2002/09/26 21:03:48  atchleyb
# renamed script
# updated to only contain business logic
#
# Revision 1.4  2002/09/20 21:41:08  atchleyb
# updated to make generic and get rid of type specific scripts
#
# Revision 1.3  2002/09/19 01:27:34  starkeyj
# modified 'add function' to include a project drop down for docuements associated with a project
#
# Revision 1.2  2002/09/17 22:18:43  atchleyb
# changed function name for browse documents
#
# Revision 1.1  2002/09/17 21:08:49  starkeyj
# Initial revision
#
#
use strict;
#use integer;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UIDocuments qw(:Functions);
use DBDocuments qw(:Functions);
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
my $nonLNprojectID = $settings{nonLNprojectID};
my $itemType = $settings{itemType};
my $title = $settings{title};
my $title2 = $title;
if ($title2 =~ m/y$/) {
    $title2 =~ s/y$/ies/;
} else {
    $title2 .= 's';
}
my $error = "";
my $cgi = new CGI;
&checkLogin(cgi => $cgi);
if ($SYSUseSessions eq 'T') {
    &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$settings{sessionID});
}
my $errorstr = "";


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "browse") {
    print &doHeader(title => 'Browse ' . $title2, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseDocumentTable(dbh => $dbh, schema => $schema, itemType => $itemType, title => $title, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "browseversion") {
    print &doHeader(title => 'Browse ' . $title2, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseDocumentVersions(dbh => $dbh, schema => $schema, itemType => $itemType, document => $settings{'document'}, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse Version in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "displaydocument") {
    eval {
        print &doDisplayDocument(dbh => $dbh, schema => $schema, itemType => $itemType, document => $settings{'document'},
                majorVersion => $settings{'majorversion'}, minorVersion => $settings{'minorversion'}, settings => \%settings);
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display document in $form", $@));
        print &doFooter;
    }
###################################################################################################################################
} elsif ($command eq "displaysigneddocument") {
    eval {
        print &doDisplaySignedDocument(dbh => $dbh, schema => $schema, itemType => $itemType, document => $settings{'document'},
                majorVersion => $settings{'majorversion'}, minorVersion => $settings{'minorversion'}, settings => \%settings);
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
        print &doAddDocumentForm(dbh => $dbh, schema => $schema, itemType => $itemType, title => $title, form => $form, 
                                 project => $settings{nonLNproject}, userID => $userid, settings => \%settings);
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
        print &doAddDocument(dbh => $dbh, schema => $schema, itemType => $settings{'itemTypeEntry'}, 
              project => $settings{'project'}, title => $title, 
              form => $form, file => $fileContents, fileName => $name, majorVersion => $settings{'major'}, minorVersion => $settings{'minor'}, 
              description => $settings{'description'}, userID => $userid, userName => $username, settings => \%settings);
        
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Add processing in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "updateselect") {
    eval {
        my @items = &getProjectArray(dbh => $dbh, schema => $schema, project => $settings{nonLNproject});
        my $tempTitle = $items[0]{acronym} . " Configuration Item Update";
        print &doHeader(title => $tempTitle, settings => \%settings, form => $form, path => $path);
        print &doUpdateSelect(dbh => $dbh, schema => $schema, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Select in $form", $@));
    }
    print &doFooter(dbh=>$dbh, schema=>$schema, username => $username, userID => $userid);
###################################################################################################################################
} elsif ($command eq "update") {
    print &doHeader(title => "Update $title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseDocumentTable(dbh => $dbh, schema => $schema, itemType => $itemType, title => $title, update => 'T', userID => $userid, 
              project => $settings{'project'}, settings => \%settings);
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
              title => $title, form => $form, userID => $userid, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Information in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "updateinformationprocess") {
    print &doHeader(DisplayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateDocumentInfo(dbh => $dbh, schema => $schema, document => $settings{'itemid'}, 
              name => $settings{'name'}, description => $settings{'description'}, title => $title, form => $form, userID => $userid, 
              project => $settings{'project'}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Information processing in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "checkoutdocument") {
    print &doHeader(DisplayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        print &doCheckOutDocument(dbh => $dbh, schema => $schema, itemType => $itemType, document => $settings{'document'},
                majorVersion => $settings{'majorversion'}, minorVersion => $settings{'minorversion'}, userID => $userid, form => $form, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Check Out Document in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "updatedocument") {
    print &doHeader(title => "Update $title", settings => \%settings, form => $form, path => $path);
    eval {
        print &doUpdateDocumentForm(dbh => $dbh, schema => $schema, document => $settings{'document'}, 
              itemType => $itemType, title => $title, form => $form, userID => $userid, settings => \%settings);
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
        print &doUpdateDocument(dbh => $dbh, schema => $schema, itemID => $settings{'itemid'}, title => $title, form => $form, 
              file => $fileContents, fileName => $name, majorVersion => $settings{'major'}, minorVersion => $settings{'minor'}, 
              description => $settings{'description'}, userID => $userid, userName => $username, settings => \%settings);
        
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update processing in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "checkinnochange") {
    print &doHeader(DisplayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        my $fileContents = '';
        my $name = $settings{'documentfile'};
        print &doCheckInNoChange(dbh => $dbh, schema => $schema, itemID => $settings{'itemid'}, title => $title, form => $form, 
              userID => $userid, userName => $username, settings => \%settings);
        
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Checkin no change processing in $form", $@));
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

