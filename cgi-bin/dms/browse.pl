#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/dms/perl/RCS/browse.pl,v $
#
# $Revision: 1.4 $
#
# $Date: 2002/07/17 20:44:43 $
#
# $Author: munroeb $
#
# $Locker:  $
#
# $Log: browse.pl,v $
# Revision 1.4  2002/07/17 20:44:43  munroeb
# added contact information to browse screen
#
# Revision 1.3  2002/04/04 16:29:50  atchleyb
# removed non DMS code, removed  code that forced user guest to decisions
# added code to browse organizations
#
# Revision 1.2  2002/03/13 17:44:05  atchleyb
# removed mockup code and added links to browse decisions and users
#
# Revision 1.1  2002/03/08 21:06:13  atchleyb
# Initial revision
#
#
#

use integer;
use strict;
use DMS_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

$| = 1;
my $dmscgi = new CGI;
my $userid = $dmscgi->param("userid");
my $username = $dmscgi->param("username");
my $schema = $dmscgi->param("schema");
my $command = defined($dmscgi->param("command")) ? $dmscgi->param("command") : "";

&checkLogin ($username, $userid, $schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $dbh;
my $errorstr = "";

$dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;

# tell the browser that this is an html page using the header method
print $dmscgi->header('text/html');

# build page
print <<END_OF_BLOCK;

<html>
<head>
   <base target=main>
   <title>Business Management System</title>
</head>

<script language=javascript><!--

function submitForm(script, command) {
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'main';
    document.$form.submit();
}

function submitFormCGIResults(script, command) {
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'cgiresults';
    document.$form.submit();
}
function doBrowse(script) {
    $form.command.value = 'browse';
    $form.action = '$path' + script + '.pl';
    $form.submit();
}

//-->
</script>

<body background=$DMSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
END_OF_BLOCK

print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Browse");
print "<form name=$form target=main action=\"" . $path . "$form.pl\" method=post>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=command value=0>\n";

if ($command eq 'somecommand') {
    eval {
        print "<br><br><center><h3>Do Some Command</h3></center>\n";
    };
    if ($@) {
        my $message = errorMessage($dbh,$username,$userid,$schema,"browse - $command.",$@);
        print doAlertBox( text => $message);
    }
} else {
    print "<table border=0 align=center>\n";
    print "<tr><td><font size=4><br><ul>\n";
    print "<li><a href=javascript:doBrowse('decisions')>Decisions</a><br><br>\n";
    print "<li><a href=javascript:doBrowse('organizations')>Organizations</a><br><br>\n";
    print "<li><a href=javascript:doBrowse('keywords')>Keywords</a><br><br>\n";
    print "<li><a href=javascript:doBrowse('user_functions')>Users</a><br><br>\n";
    print "</ul></font>\n";
    print "</td></tr></table>\n";

	if ($userid eq '0') {
	    print "<center><table border=0 width=400><tr><td align=center><i>To enter a new decision into the system, please login with your assigned username and password, <br><br>To obtain a new username and password, you will need to contact Sheryl Morris at (702) 794-5487 </i></td></tr></table></center>";
	}


}


print "</form>\n";
print <<END_OF_BLOCK;

</body>
</html>
END_OF_BLOCK


&db_disconnect($dbh);
exit();
