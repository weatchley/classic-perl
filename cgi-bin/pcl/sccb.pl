#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/sccb.pl,v $
#
# $Revision: 1.3 $ 
#
# $Date: 2003/02/12 16:37:48 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: sccb.pl,v $
# Revision 1.3  2003/02/12 16:37:48  atchleyb
# added session management
#
# Revision 1.2  2003/02/07 20:49:20  starkeyj
# modified 'use DB_scm' to 'use DBShared', 'use UI_scm' to 'use UIShared'
# and 'use SCM_Header' to 'use SharedHeader'
#
# Revision 1.1  2002/12/12 00:08:26  starkeyj
# Initial revision
#
#
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UISCCB qw(:Functions);
use DBSCCB qw(:Functions);
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
my $project = $settings{project};
my $select1 = $settings{select1};
my $sccb = $settings{sccbselect} ? $settings{sccbselect} : $settings{sccb};
my $title = $settings{title};
my $sccbname = $settings{sccbname};
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
    print &doHeader(title => 'Browse SCCB ', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseSCCBTable(dbh => $dbh, schema => $schema, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse in $form", $@));
    }
    print &doFooter;
###################################################################################################################################
} elsif ($command eq "create") {
    print &doHeader(title => 'Create ' . $title , settings => \%settings, form => $form, path => $path);
    eval {
        print &createSCCBBody(dbh => $dbh, schema => $schema,  userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "UI Create SCCB in $form", $@));
    }
    print &doFooter; 
###################################################################################################################################
} elsif ($command eq "update") {
	 print &doHeader(title => 'Update ' . $title , settings => \%settings, form => $form, path => $path);
	 eval {
		  print &updateSCCBBody(dbh => $dbh, schema => $schema,  userID => $userid, sccb => $sccb, roles => $settings{roles});
	 };
	 if ($@) {
		  print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "UI Update SCCB in $form", $@));
	 }
 	 print &doFooter; 
###################################################################################################################################
} elsif ($command eq "db_create") {
	 print &doHeader(title => 'Create ' . $title , settings => \%settings, form => $form, path => $path);
	 eval {
		  print &doCreateSCCB(dbh => $dbh, schema => $schema,  userID => $userid, sccbname => $sccbname, project => $project, roles => $settings{roles},settings => \%settings);
	 };
	 if ($@) {
		  print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "DB Create SCCB in $form", $@));
	 }
    print &doFooter; 
###################################################################################################################################
} elsif ($command eq "db_update") {
	 print &doHeader(title => 'Update ' . $title , settings => \%settings, form => $form, path => $path);
	 eval {
		  print &doUpdateSCCB(dbh => $dbh, schema => $schema,  userID => $userid, sccb => $sccb, sccbname => $sccbname, roles => $settings{roles},settings => \%settings);
	 };
	 if ($@) {
		  print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "DB Update SCCB in $form", $@));
	 }
    print &doFooter; 
###################################################################################################################################
} elsif ($command eq "browsemembers") {
    print &doHeader(title => 'Browse ' . $title . 's', settings => \%settings, form => $form, path => $path);
    eval {
        print &doBrowseSCCBmembers(dbh => $dbh, schema => $schema,  userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Browse Version in $form", $@));
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
