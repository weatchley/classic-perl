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
# $dbh = oncs_connect();

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
<title>CMS Header</title>
<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) // not in frames
  {
  location = '/cgi-bin/oncs/oncs_user_login.pl';
  }
//-->
</script>
</head>
<body>
<center>
<font size=5><b>Historical Commitment Data</b></font><br>
</center>
</body>
</html>
pageheader
