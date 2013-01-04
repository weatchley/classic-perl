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
#$dbh = oncs_connect();

my $username = $oncscgi->param('loginusername');
my $usersid = $oncscgi->param('loginusersid');
my $loadworkspace = $oncscgi->param('loadworkspace');
$loadworkspace = ($loadworkspace eq "F") ? 0 : -1;
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
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>

<script language="JavaScript" type="text/javascript">
<!--
// Check to see if the page is loaded properly
if (parent == self) // not in frames
  {
  location = '/cgi-bin/oncs/oncs_user_login.pl';
  }

//Reload Header and Workspace Pages
parent.header.location = '/cgi-bin/oncs/commitment_module_header.pl?loginusersid=$usersid&loginusername=$username';
if ($loadworkspace)
  {
  parent.workspace.location = '/cgi-bin/oncs/commitment_module_main.pl?loginusersid=$usersid&loginusername=$username';
  }
//-->
</script>
</head>
<body>
pageheader

#create connection to the oracle database
my $dbh = oncs_connect();

my $maintenancelink = does_user_have_named_priv($dbh, $usersid, 'Maintenance');

# close connection to the oracle database
&oncs_disconnect($dbh);

my $userisguest = ($usersid == 0);

my $widthpercentage;
my $numberofcolumns;
if ($userisguest)
  {
  $numberofcolumns = 1;   #Only Log Out
  $widthpercentage = 100.00 / $numberofcolumns;
  }
else
  {
  $numberofcolumns = 2 + (($maintenancelink == 1) ? 1 : 0);
  $widthpercentage = 100.00 / $numberofcolumns;
  }

print <<commitmenustart;
<form name=params>
<table summary="Main Menu Table" width="100%">
  <tr align=center>
commitmenustart

if (!$userisguest)
  {
  print <<commitmenunotguest;
<!--  <td width="${widthpercentage}%">
    <a href="/cgi-bin/oncs/oncs_menu.pl?loginusersid=$usersid&loginusername=$username" target=menu>Main Menu</a>
    <input type=hidden name=loginusersid value=$usersid>
    <input type=hidden name=loginusername value=$username>
  </td>  -->
  <td width="${widthpercentage}%">
    <a href="/cgi-bin/oncs/commitment_module_main.pl?loginusersid=$usersid&loginusername=$username" target=workspace>Commitments Menu</a>
  </td>
commitmenunotguest
  }

if ($maintenancelink == 1)
  {
  print <<maintmenuend;
  <td width=${widthpercentage}%>
    <a href="/cgi-bin/oncs/oncs_maintenance.pl?loginusersid=$usersid&loginusername=$username" target="workspace">Maintenance</a>
  </td>
maintmenuend
  }

if ($userisguest)
  {
  print <<guestmenuend;
    <td width="${widthpercentage}%">
      <a href="/cgi-bin/oncs/oncs_user_login.pl" target="_top">Home</a>
    </td>
    </tr>
  </table>
  </form>
  </body>
  </html>
guestmenuend
  }
else
  {
  print <<commitmenuend;
    <td width="${widthpercentage}%">
      <a href="/cgi-bin/oncs/oncs_user_login.pl" target="_top">Log Out</a>
    </td>
    </tr>
  </table>
  </form>
  </body>
  </html>
commitmenuend
  }

