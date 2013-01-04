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
# $dbh = oncs_connect();

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
<title>ONCS Header</title>
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
<center><h1>OCRWM Nuclear Culture System</h1></center>
</body>
</html>
pageheader
