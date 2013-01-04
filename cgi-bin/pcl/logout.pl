#!/usr/local/bin/perl -w
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/pcl/perl/RCS/logout.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2009/01/14 22:41:58 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: logout.pl,v $
# Revision 1.2  2009/01/14 22:41:58  atchleyb
# ACR0901_007 - Updated to create new path to system (login_new.pl) and to redirect login.pl to the new system (PCLWR)
#
# Revision 1.1  2003/02/12 18:44:32  atchleyb
# Initial revision
#
#
#

use integer;
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use CGI qw(param);
use Sessions qw(:Functions);

$| = 1;
my $mycgi = new CGI;
my $userid = $mycgi->param("userid");
my $username = $mycgi->param("username");
my $sessionID = $mycgi->param("sessionid");
my $schema = $mycgi->param("schema");
&checkLogin(cgi => $mycgi);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $dbh;

$dbh = &db_connect();

# tell the browser that this is an html page using the header method
print $mycgi->header('text/html');

my $status = &sessionClose(dbh=>$dbh, schema=>$schema, sessionID=>$sessionID);
print "<html><header></header><body>\n";
print "<form name=$form action=login_new.pl target=_top method=post>\n";
print "<input type=hidden name=test value=test>\n</form>\n";
print "<script language=javascript>\n<!--\n";
print "document.$form.submit();\n";
print "//-->\n</script>\n";
print "</body>\n";
print "</html>\n";


&db_disconnect($dbh);
exit();
