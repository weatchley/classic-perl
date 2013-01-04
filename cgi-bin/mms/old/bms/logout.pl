#!/usr/local/bin/newperl -w
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
use BMS_Header qw(:Constants);
use DB_Utilities_Lib qw(:Functions);
use CGI qw(param);
use DBI;
use DBD::Oracle qw(:ora_types);
use Sessions qw(:Functions);

$| = 1;
my $bmscgi = new CGI;
my $userid = $bmscgi->param("userid");
my $username = $bmscgi->param("username");
my $sessionID = $bmscgi->param("sessionid");
my $schema = $bmscgi->param("schema");
&checkLogin ($username, $userid, $schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $dbh;

$dbh = &db_connect();

# tell the browser that this is an html page using the header method
print $bmscgi->header('text/html');

my $status = &sessionClose(dbh=>$dbh, schema=>$schema, sessionID=>$sessionID);
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
