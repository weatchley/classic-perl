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
use MMS_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

$| = 1;
my $mmscgi = new CGI;
my $userid = $mmscgi->param("userid");
my $username = $mmscgi->param("username");
my $sessionID = defined($mmscgi->param("sessionid")) ? $mmscgi->param("sessionid") : "none";
my $schema = $mmscgi->param("schema");
my $command = defined($mmscgi->param("command")) ? $mmscgi->param("command") : "";
&checkLogin ($username, $userid, $schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $dbh;
my $errorstr = "";

$dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;

#! test for invalid or timed out session, allow for guest access
if ($userid != 0) {
    &validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $sessionID);
}

# tell the browser that this is an html page using the header method
print $mmscgi->header('text/html');

# build page
print <<END_OF_BLOCK;

<html>
<head>
   <base target=main>
   <title>Business Management System</title>
</head>

<body background=$MMSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
END_OF_BLOCK

print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Browse");
print "<form name=$form method=post>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=sessionid value=$sessionID>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=command value=0>\n";

print "<br><br><center><h3>Browse Page Goes Here</h3></center>\n";


print "</form>\n";
print <<END_OF_BLOCK;

</body>
</html>
END_OF_BLOCK


&db_disconnect($dbh);
exit();
