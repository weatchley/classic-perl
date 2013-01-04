#!/usr/local/bin/perl -w
#
#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/training.pl,v $
#
# $Revision: 1.7 $
#
# $Date: 2003/02/12 16:40:03 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: training.pl,v $
# Revision 1.7  2003/02/12 16:40:03  atchleyb
# added session management
#
# Revision 1.6  2003/02/03 20:16:04  atchleyb
# removed refs to SCM
#
# Revision 1.5  2002/11/07 21:59:33  atchleyb
# updated to include UI_scm
#
# Revision 1.4  2002/11/07 16:29:26  starkeyj
#  modified to pass the CGI reference instead of the username, userid, and schema variables to checkLogin
#
# Revision 1.3  2002/10/31 17:05:56  atchleyb
# seperated logic into BL, DB, and UI
#
# Revision 1.2  2002/10/01 18:08:12  mccartym
# added initial table layout for browse of training records by developer and by training program element
#
# Revision 1.1  2002/09/17 20:16:51  atchleyb
# Initial revision
#
#
#

use strict;
#use integer;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UITraining qw(:Functions);
use DBTraining qw(:Functions);
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
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseSample(dbh => $dbh, schema => $schema, title => $title, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "browsesample") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseSample(dbh => $dbh, schema => $schema, title => $title, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "browseusertraining") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseUserTraining(dbh => $dbh, schema => $schema, userID => $settings{id});
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "browseproceduretraining") {
    print &doHeader(title => $title, settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseProcedureTraining(dbh => $dbh, schema => $schema, document => $settings{document}, settings => \%settings);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "displaytrainingcertificate") {
    eval {
        print &doDisplayTrainingCertificate(dbh => $dbh, schema => $schema, itemID => $settings{'itemid'}, userID => $settings{'id'},
                document => $settings{'document'});
#                majorVersion => $settings{'majorversion'}, minorVersion => $settings{'minorversion'});
    };
    if ($@) {
        print &doHeader(displayTitle => 'F', settings => \%settings, form => $form, path => $path);
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Display document in $form", $@));
        print &doFooter;
    }
###################################################################################################################################
} elsif ($command eq "addtrainingrecord") {
    print &doHeader(title => "Add Training Record", settings => \%settings, form => $form, path => $path);
    eval {
        print &doAddTrainingRecordForm(dbh => $dbh, schema => $schema, 
              title => $title, form => $form, userID => $userid, useFileUpload => 'T');
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Add in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "addtrainingrecordprocess") {
    print &doHeader(DisplayTitle => 'F', settings => \%settings, form => $form, path => $path);
    eval {
        my ($name, $fileContents) = &getFile;
        print &doProcessAddTrainingRecord(dbh => $dbh, schema => $schema, 
              traininguserid => $settings{'traininguserid'}, procedureid => $settings{'procedureid'}, trainingdate => $settings{'trainingdate'},
              form => $form, file => $fileContents, fileName => $name, majorVersion => $settings{'major'}, minorVersion => $settings{'minor'}, 
              userID => $userid, userName => $username);
        
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Add processing in $form", $@));
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
