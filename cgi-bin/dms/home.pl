#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/dms/perl/RCS/home.pl,v $
#
# $Revision: 1.7 $
#
# $Date: 2002/08/27 20:46:01 $
#
# $Author: munroeb $
#
# $Locker:  $
#
# $Log: home.pl,v $
# Revision 1.7  2002/08/27 20:46:01  munroeb
# fixed sort order on home screen
#
# Revision 1.6  2002/08/08 15:55:54  munroeb
# changed background color to white on home screen
#
# Revision 1.5  2002/06/26 22:46:08  munroeb
# fixed sorting errors and viewprint window toolbars
#
# Revision 1.4  2002/06/25 21:40:07  munroeb
# fixed Decision and Executive summary popup windows
#
# Revision 1.2  2002/05/24 19:46:06  munroeb
# First major check-in since March 20th
#
# Revision 1.1  2002/03/08 21:08:11  atchleyb
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
   <title>Decision Management System</title>
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

//-->
</script>

<body background=$DMSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
END_OF_BLOCK

print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Home");
print "<form name=$form target=cgiresults action=\"" . $path . "$form.pl\" method=post>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=command value=0>\n";
print "<input type=hidden name=decisionid value=0>\n";

eval {
    #print "<center><a href='/dms/dataentry.html'>Create new decision</a>";
    #print "<center><a href=javascript:submitForm('decisions','new')>Create new decision</a>";
    #print "<h3>Edit Pending Decision Packages</h3>\n";
    #print "<h3>Enter Accession Number for Approved Decisions</h3>\n";

print <<EO_BLOCK;

<center>

<script language="JavaScript">

function openWindow(image) {
     window.open(image,"image_window","height=500,width=700,scrollbars=yes,resizable=yes,toolbars=yes");
}

function editDecision(decisionid, command) {
	document.$form.action = '$path' + 'decisions.pl';
	document.$form.command.value = command;
	document.$form.target = 'main';
	document.$form.decisionid.value = decisionid;
	document.$form.submit();

}

function createNewEntry(command) {
	document.$form.action = '$path' + 'decisions.pl';
	document.$form.command.value = command;
	document.$form.target = 'main';
	document.$form.submit();

}

function viewprint(command,decisionid) {
	document.$form.action = '$path' + 'decisions.pl';
	document.$form.command.value = command;
	window.open(document.$form.action,"print_window");
	document.$form.target = 'print_window';
	document.$form.decisionid.value = decisionid;
	document.$form.submit();

}

</script>


<table border="1" cellpadding="3" cellspacing="0" width="780" bgcolor="#ffffff">
<tr><td colspan="8">
<br>
<ul>
<li><a href="javascript:createNewEntry(\'createNewEntry\');">Create a new Decision Package</a></li>
</ul>
</td></tr>

<!-- End of static code -->

EO_BLOCK

my $sql2 = "select firstname, lastname from users where id = $userid";
my $sth2 = $dbh->prepare($sql2);
$sth2->execute();

my @userArray = $sth2->fetchrow_array();

my $sql = "select a.decisionstatus, a.decisionid, b.description, a.decisiontitle,".
          "a.decisiondate, a.accession from $schema.decisions a, $schema.decision_types b ".
          "where a.preparer = $userid and a.decisiontype = b.id(+) and (a.decisionstatus = 1 or a.decisionstatus = 2) order by a.decisiondate, a.decisionid";

my $sth = $dbh->prepare($sql);
$sth->execute();

my @record = ();
my $record = "";
my $decisionstatus = "";
my $decisioncolor = "";

print <<EO_BLOCK;

	<tr><td colspan="8" bgcolor="#eeeeee"><font size="4"><b>Decision Packages for $userArray[0] $userArray[1]</b></font>
	<br><br>
	<table width="600" cellpadding="2" cellspacing="3" border="0">
	<tr><td colspan="2"><b>Legend:</b></td></tr>
	<tr><td width="10" align="center" bgcolor="#FFFF00"><font size="2"><b>A</b></font></td><td>Approved - Waiting for Accession Number</td></tr>
	<tr><td width="10" align="center" bgcolor="#FF9900"><font size="2"><b>P</b></font></td><td>Pending - Incomplete Decision Package</td></tr>
	</table>
	<br>

	</td></tr>
	<tr><td width="15" bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>S</b></font></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>Executive<br>Summary</b></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>Decision<br>Analysis</b></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>ID</b></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>Type</b></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>Title</b></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>Decision<br>Date</b></td><td bgcolor="#00CCFF" align="center" valign="bottom"><font size="2"><b>Accession</b></td></tr>

EO_BLOCK

while ((@record) = $sth->fetchrow_array()) {

	if ($record[0]) {
		$decisionstatus = 'P' if $record[0] eq 1;
		$decisioncolor = '#FF9900' if $record[0] eq 1;
		$command = 'updatePending' if $record[0] eq 1;
		$decisionstatus = 'A' if $record[0] eq 2;
		$decisioncolor = '#FFFF00' if $record[0] eq 2;
		$command = 'updateApproved' if $record[0] eq 2;
	}

    my $decisionid = $record[1]; $decisionid = '&nbsp;' if !($decisionid);
    my $decisiontype = $record[2]; $decisiontype = '&nbsp;' if !($decisiontype);
    my $decisiontitle = $record[3]; $decisiontitle = '&nbsp;' if !($decisiontitle);
    my $decisiondate = $record[4]; $decisiondate = '&nbsp;' if !($decisiondate);
    my $accession = $record[5]; $accession = '&nbsp;' if !($accession);

    if ($accession ne '&nbsp;') {
		$accession = '<a href="javascript:openWindow(\'http://rms.ymp.gov/cgi-bin/get_record.com?'.$accession.'\');">'.$accession.'</a>';
	}

	print '<tr><td width="15" align="center" bgcolor="'.$decisioncolor.'"><font size="2"><b>'.$decisionstatus.'</b></font></td>';

	print '<td align="center"><a href="javascript:viewprint(\'printable_es\',\''.$decisionid.'\');"><img src="/dms/icons/16/printer.gif" border="0" alt="click here to generate a printable Executive Summary"></a></td>';
	print '<td align="center"><a href="javascript:viewprint(\'printable_da\',\''.$decisionid.'\');"><img src="/dms/icons/16/printer.gif" border="0" alt="click here to generate a printable Decision Analysis"></a></td>';

	print '<td align="center" nowrap><font size="2"><a href="javascript:editDecision(\''.$decisionid.'\',\''.$command.'\');">'.$decisionid.'</a></font></td>';
	print '<td><font size="2">'.$decisiontype.'</font></td>';
	print '<td><font size="2">'.$decisiontitle.'</font></td>';
	print '<td nowrap><font size="2">'.$decisiondate.'</font></td>';
	print '<td nowrap><font size="2">'.$accession.'</font></td>';
}

print "</table></center>\n";

};
if ($@) {
    my $message = errorMessage($dbh,$username,$userid,$schema,"home screen.",$@);
    print doAlertBox( text => $message);
}


print "</form>\n";
print <<END_OF_BLOCK;

</body>
</html>
END_OF_BLOCK


&db_disconnect($dbh);
exit();
