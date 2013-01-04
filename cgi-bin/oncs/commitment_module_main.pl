#!/usr/local/bin/newperl -w

# CGI user login for the CRD
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
# get all required libraries and modules
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $oncscgi = new CGI;

# tell the browser that this is an html page using the header method
print $oncscgi->header('text/html');

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

my $username = $oncscgi->param('loginusername');
my $usersid = $oncscgi->param('loginusersid');
if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq ""))
  {
  print <<openloginpage;
  <script type="text/javascript">
  <!--
  parent.location='/cgi-bin/oncs/oncs_user_login.pl';
  //-->
  </script>
openloginpage
  exit 1;
  }

# output page header
print <<pageheader;
<html>
<head>
<meta name="pragma" content="no-cache">
<meta name="expires" content="0">
<meta http-equiv="expires" content="0">
<meta http-equiv="pragma" content="no-cache">
<title>Commitment Module Menu</title>
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>

<!-- page specific javascript code -->
<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) // not in frames
  {
  location = '/cgi-bin/oncs/oncs_user_login.pl';
  }
//-->
</script>
</head>
pageheader

print <<bodystart;
<body>
<center>
<h2>Please select an option from the list below</h2>
</center>
bodystart

my $oldcommitmentlink = does_user_have_named_priv($dbh, $usersid, 'Enter Old Commitment Data');
&oncs_disconnect($dbh);

print "<ul>\n";
print "<lh><b>Commitment Functions</b></lh>\n";
if ($oldcommitmentlink == 1)
  {
  print "<li><a href=\"/cgi-bin/oncs/oldissues.pl?loginusersid=$usersid&loginusername=$username\">Enter Old Issues</a></li>\n";
  print "<li><a href=\"/cgi-bin/oncs/readoldissues.pl?loginusersid=$usersid&loginusername=$username\">View Old Issues/Enter Old Commitments</a>\n";
  }
print "<li><a href=\"/cgi-bin/oncs/readcommitments.pl?loginusersid=$usersid&loginusername=$username\">View Old Commitments</a>\n";
print "</ul>\n";

print "<ul>\n";
print "<lh><b>Commitment Reports</b></lh>\n";
print "<li><a href=\"/cgi-bin/oncs/oncs_report01.pl?loginusersid=$usersid&loginusername=$username\">Executive Commitment Report</a></li>\n";
print "<li><a href=\"/cgi-bin/oncs/manager_report.pl?loginusersid=$usersid&loginusername=$username\">Managers Report</a><BR>\n";
print "</ul>\n";

print <<bodyend;
<form name=params>
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
</form>
</body>
</html>
bodyend

