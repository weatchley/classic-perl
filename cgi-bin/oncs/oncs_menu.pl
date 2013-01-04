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
#require "oncs_header.pl";
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
#require "oncs_lib.pl";

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
#use strict;

my $oncscgi = new CGI;

# tell the browser that this is an html page using the header method
print $oncscgi->header('text/html');

# connect to the oracle database and generate a database handle
$dbh = oncs_connect();

$username = $oncscgi->param('loginusername');
$usersid = $oncscgi->param('loginusersid');
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
<title>ONCS Header</title>
<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) // not in frames
  {
  location = '/cgi-bin/oncs/oncs_user_login.pl';
  }

parent.header.location = '/cgi-bin/oncs/oncs_page_header.pl?loginusername=$username&loginusersid=$usersid';
parent.workspace.location = '/cgi-bin/oncs/oncs_home.pl?loginusersid=$usersid&loginusername=$username';
//-->
</script>
</head>
<body>
pageheader

$maintenancelink = does_user_have_named_priv($dbh, $usersid, 'Maintenance');
$numberofcolumns = 2 + (($maintenancelink == 1) ? 1 : 0);
$widthpercentage = 100.00 / $numberofcolumns;

print <<menustart;
<form name=params>
<table summary="Main Menu Table" width="100%">
  <tr align=center>
  <td width="${widthpercentage}%">
    <a href="/cgi-bin/oncs/oncs_home.pl?loginusersid=$usersid&loginusername=$username" target="workspace">Main Menu</a>
    <input type=hidden name=loginusersid value=$usersid>
    <input type=hidden name=loginusername value=$username>
  </td>
menustart

if ($maintenancelink == 1)
  {
  print <<maintmenu;
  <td width="${widthpercentage}%">
    <a href="/cgi-bin/oncs/oncs_maintenance.pl?loginusersid=$usersid&loginusername=$username" target="workspace">Maintenance</a>
  </td>
maintmenu
  }

print <<menuend;
  <td width="${widthpercentage}%">
    <a href="/cgi-bin/oncs/oncs_user_login.pl" target="_top">Log Out</a>
  </td>
  </tr>
</table>
</form>
</body>
</html>
menuend

# close connection to the oracle database
&oncs_disconnect($dbh);
