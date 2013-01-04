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
<title>Commitments Main Menu</title>
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
<h1>Please select an option from the list below</h1>
</center>
bodystart

my $maintenancelink = does_user_have_named_priv($dbh, $usersid, 'Maintenance');
my $sysadminlink = does_user_have_named_priv($dbh, $usersid, 'System Administration');
#my $oldcommitmentlink = does_user_have_named_priv($dbh, $usersid, 'Enter Old Commitment Data');
&oncs_disconnect($dbh);

print "<ul>\n";
print "<lh><b>Basic Functions</b></lh>\n";
if ($maintenancelink == 1)
  {
  print "<li><a href=\"/cgi-bin/oncs/oncs_maintenance.pl?loginusersid=$usersid&loginusername=$username\">Picklist Maintenance</a></li>\n";
  }
if ($usersid != 0)
  {
  print "<li><a href=\"/cgi-bin/oncs/changepassword.pl?loginusersid=$usersid&loginusername=$username\">Change Your Password</a>\n";
  }
print "<li><a href=\"/cgi-bin/oncs/oncs_user_login.pl\" target=\"_top\">Re-Login</a></li>\n";
print "</ul>\n";

print "<ul>\n";
print "<lh><b>Modules</b></lh>\n";
print "<li><a href=\"javascript:alert('Not Integrated Yet')\">Issue Entry</a></li>\n";
print "<li><a target=menu href=\"/cgi-bin/oncs/commitment_module_menu.pl?loginusersid=$usersid&loginusername=$username\">Commitment Management</a></li>\n";
print "<li><a href=\"javascript:alert('Not Integrated Yet')\">Corrective Actions</a></li>\n";
print "<li><a href=\"javascript:alert('Not Integrated Yet')\">Deficiency Reports</a></li>\n";
print "<li><a href=\"javascript:alert('Not Integrated Yet')\">Lessons Learned</a></li>\n";
print "<li><a href=\"javascript:alert('Not Integrated Yet')\">Decision Documentation</a></li>\n";
print "</ul>\n";

if ($sysadminlink == 1)
  {
#   print "<a href=\"/cgi-bin/oncs/dyer_report.pl?loginusersid=$usersid&loginusername=$username\">Test Dyer Report</a><BR>\n";
#  print "<a href=\"/cgi-bin/oncs/readcommitments.pl?loginusersid=$usersid&loginusername=$username\">Test Read Commitment</a><BR>\n";
#  print "<a href=\"/cgi-bin/oncs/readoldissues.pl?loginusersid=$usersid&loginusername=$username&cgiaction=editissue&issueid=20\">Test Edit Issue</a><BR>\n";  
#  print "<a href=\"/cgi-bin/oncs/readoldissues.pl?loginusersid=$usersid&loginusername=$username&cgiaction=editissue&issueid=23\">Test Edit Issue 2</a><BR>\n";  
  }

print <<bodyend;
<form name=params>
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
</form>
</body>
</html>
bodyend

