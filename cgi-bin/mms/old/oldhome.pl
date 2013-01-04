#!/usr/local/bin/perl -w
#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
#
#
#
#
use integer;
use strict;
use CGI;
use Tie::IxHash;
use SharedHeader ('$SYSImagePath');
use UIShared ('writeHTTPHeader', 'checkLogin', :Functions);
use UI_Widgets ('writeTitleBar');
use UIDocuments ('displayNonCodeCheckedOutItemsTable');
use DBShared ('db_connect', 'db_disconnect');

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
$dbh = &db_connect();
my %settings = &getValueHash(valueList => ['userid','username','schema',])
my $schema = $settings{schema};
my $command = $settings{command};
my $username = $settings{username};
my $userid = $settings{userid};
my $title = $settings{title};
my $error = "";


###################################################################################################################################
my $cgi = new CGI;
&checkLogin (cgi => $cgi);
my $output = &doStandardHeader(dbh=>$dbh,schema=>includeJSUtilities => 'F', includeJSWidgets => 'F');
$output .= &doStandardFooter;
print $output;
exit();
