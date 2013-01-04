#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/project.pl,v $
#
# $Revision: 1.9 $
#
# $Date: 2003/02/12 16:35:49 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: project.pl,v $
# Revision 1.9  2003/02/12 16:35:49  atchleyb
# added session management
#
# Revision 1.8  2003/02/03 21:56:35  atchleyb
# remved refs to SCM
#
# Revision 1.7  2002/11/27 01:36:36  starkeyj
# modified create and update project functions to include sccbid
#
# Revision 1.6  2002/11/07 16:12:41  starkeyj
# modified to pass the CGI reference instead of the username, userid, and schema variables to checkLogin
#
# Revision 1.5  2002/11/05 17:06:39  johnsonc
# Changed error log messages to style consistent with other files.
#
# Revision 1.4  2002/11/01 00:22:09  johnsonc
# Included function calls to activity log.
#
# Revision 1.3  2002/10/31 19:23:59  johnsonc
# Modified script to seperate business logic, user interface, and database functionality
#
# Revision 1.2  2002/10/24 18:26:45  starkeyj
# modified to fix javascript error on project creation
#
# Revision 1.1  2002/09/17 20:39:39  starkeyj
# Initial revision
#
#
#
#

use strict;
use SharedHeader qw(:Constants);
use UIShared qw(:Functions);
use UIProject qw(:Functions);
use DBShared qw(:Functions);
use DBProject qw(:Functions);
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
my $error = "";
my $cgi = new CGI;

&checkLogin(cgi => $cgi);
if ($SYSUseSessions eq 'T') {
    &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$settings{sessionID});
}

#########
if ($command eq 'create_project') {
	print &doHeader(schema => $schema, title => 'Software Configuration Management', 
	              	 settings => \%settings, form => $form, path => $path);
	eval {
		print &createProjectBody(schema => $schema, dbh => $dbh, form => $form);
	};
	if ($@) {
    	print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Create Project in $form", $@));
	}
	print &doStandardFooter;
}
#########
elsif ($command eq 'db_create_project') {
	print &doStandardHeader(schema => $schema, title => 'Software Configuration Management', 
	              				settings => \%settings, form => $form, path => $path, includeJSUtilities => 'F',
	              				includeJSWidgets => 'F');

	eval {
		&createProject(dbh => $dbh, schema => $schema, acronym => $settings{acronym}, 
							name => $settings{projectname}, description => $settings{desc}, userId => $userid, 
							projectManagerId => $settings{projectManagerID}, configurationManagerId => $settings{configurationManagerID},
							requirementsManagerId => $settings{requirementsManagerID}, form => $form, sccbid => $settings{sccbid});
    	print doAlertBox(text => "$settings{projectname} successfully created");
    	my @javaScript = ("<script language=javascript>\n<!--\n", "submitForm('utilities','');\n", "//-->\n</script>\n");
    	print &doBody(text => \@javaScript);
	};
	if ($@) {
    	print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "DB Create Project in $form", $@));
   }
   print &doStandardFooter;
}
#########
elsif ($command eq 'db_update_project') {
	print &doStandardHeader(schema => $schema, title => 'Software Configuration Management', 
		              			settings => \%settings, form => $form, path => $path, includeJSUtilities => 'F',
		              			includeJSWidgets => 'F');
	eval {
		&updateProject(dbh => $dbh, schema => $schema, name => $settings{projectname}, 
		               description => $settings{desc}, projectManagerId => $settings{projectManagerID}, 
		               requirementsManagerId => $settings{requirementsManagerID}, 
		               configurationManagerId => $settings{configurationManagerID}, 
		               projectId => $settings{projectID}, userId => $userid, sccbid => $settings{sccbid});
    	print &doAlertBox(text => "$settings{projectname} successfully updated");
    	my @javaScript = ("<script language=javascript>\n<!--\n", "submitForm('utilities','');\n", "//-->\n</script>\n");
    	print &doBody(text => \@javaScript);
	};
	if ($@) {
    	print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "DB Update Project in $form", $@));
   }
   print &doStandardFooter;
}
#########
elsif ($command eq 'update_project') {
	print &doHeader(schema => $schema, title => 'Software Configuration Management', 
	              	 settings => \%settings, form => $form, path => $path);
	eval {
   	print &updateProjectBody(dbh => $dbh, schema => $schema, projectID => $settings{projectID}, form => $form);
   };
	if ($@) {
    	print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Update Project in $form", $@));
   }   
   print &doStandardFooter;
}
#########
else {
	print &doStandardHeader(schema => $schema, title => 'Software Configuration Management', 
		              			settings => \%settings, form => $form, path => $path, includeJSUtilities => 'F',
		              			includeJSWidgets => 'F');
	my @bodyText = ("<br><center>Command $command not known</center>\n");
   print &doBody(text => \@bodyText);
	print &doStandardFooter;
}
&db_disconnect($dbh);   
exit();
