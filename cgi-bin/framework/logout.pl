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

use integer;
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use CGI qw(param);
#use DBI;
#use DBD::Oracle qw(:ora_types);
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
&logActivity (dbh => $dbh, schema => $schema, userID => $userid, logMessage => "user $username logged out", type => 7);
print "<html><header></header><body>\n";
print "<form name=$form action=login.pl target=_top method=post>\n";
print "<input type=hidden name=test value=test>\n</form>\n";
print "<script language=javascript>\n<!--\n";
print "document.$form.submit();\n";
print "//-->\n</script>\n";
print "</body>\n";
print "</html>\n";


&db_disconnect($dbh);
exit();
