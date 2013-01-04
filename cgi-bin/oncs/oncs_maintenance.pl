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
<title>Picklist Maintenance</title>
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
$idstr = "&loginusername=$username&loginusersid=$usersid";

print <<maintmenustart;
<body>
<center><h1>Select a picklist to modify</h1></center>
maintmenustart

$haspicklistmaintenance = does_user_have_named_priv($dbh, $usersid, 'Modify Picklists');
if ($haspicklistmaintenance == 1)
  {
  print <<picklistmaintmenu;
  <ul title="Maintenance Options">
  <lh>Maintenance Options
  <li><a href="/cgi-bin/oncs/dcmm_maint.pl?action=query&updatetable=category&pagetitle=Category$idstr">Categories (NWTRB, NRC, etc)</a></li>
  <li><a href="/cgi-bin/oncs/dcmm_maint.pl?action=query&updatetable=discipline&pagetitle=Discipline$idstr">Disciplines</a></li>
  <li><a href="/cgi-bin/oncs/dcmm_maint.pl?action=query&updatetable=keyword&pagetitle=Keyword$idstr">Keywords</a></li>
  <li><a href="/cgi-bin/oncs/organization_maint.pl?action=query&updatetable=organization&pagetitle=Organization$idstr">Organizations</a></li>
  <li><a href="/cgi-bin/oncs/dcmm_maint.pl?action=query&updatetable=product&pagetitle=Product$idstr">Products</a></li>
  <li><a href="/cgi-bin/oncs/wbs_maint.pl?action=query&updatetable=workbreakdownstructure&pagetitle=Work%20Breakdown%20Structure$idstr">WBSes</a></li>
  <li><a href="/cgi-bin/oncs/commitmentlevel_maint.pl?action=query&updatetable=commitmentlevel&pagetitle=Level%20of%20Commitment$idstr">Levels of Commitment</a></li>
<!--   <li><a href="/cgi-bin/oncs/dcmm_maint.pl?action=query&updatetable=reportingorg&pagetitle=Reporting%20Organization$idstr">Reporting Organization</a> (i.e. DOE, USGS, LANL, etc.)</li>
  <li><a href="/cgi-bin/oncs/dcmm_maint.pl?action=query&updatetable=actionstaken&pagetitle=Actions%20Taken$idstr">Actions Taken</a> (i.e. Stopped Work, Called 911, etc.)</li>
  <li><a href="/cgi-bin/oncs/dcmm_maint.pl?action=query&updatetable=generallocation&pagetitle=General%20Location$idstr">General Location</a> (i.e. Site, Las Vegas, Vienna, USGS, etc.)</li>
  <li><a href="/cgi-bin/oncs/dcmm_maint.pl?action=query&updatetable=specificlocation&pagetitle=Specific%20Location$idstr">Specific Location</a> (i.e. 1551 Hillshire Blue Room, Forrestal GH-071, etc.)</li> -->
  </ul>
picklistmaintmenu
  }

$hassystemmaintenance = does_user_have_named_priv($dbh, $usersid, 'System Administration');
if ($hassystemmaintenance == 1)
  {
  print <<systemmaintmenu;
  <ul title="System Maintenance">
  <lh>System Maintenance
  <li><a href="/cgi-bin/oncs/dcmm_maint.pl?action=query&updatetable=issuetype&pagetitle=Issue%20Type$idstr">Issue Types</a></li>
  <li><a href="/cgi-bin/oncs/dcmm_maint.pl?action=query&updatetable=privilege&pagetitle=Privilege$idstr">Privileges</a></li>
  <li><a href="/cgi-bin/oncs/dcmm_maint.pl?action=query&updatetable=role&pagetitle=Role$idstr">Roles</a></li>
  <li><a href="/cgi-bin/oncs/site_maint.pl?action=query&updatetable=site&pagetitle=Site$idstr">Sites</a></li>
  <li><a href="/cgi-bin/oncs/dcmm_maint.pl?action=query&updatetable=status&pagetitle=Status$idstr">Statuses</a></li>
  <li><a href="/cgi-bin/oncs/role_maint.pl?action=query$idstr">Default Roles</a></li>
  </ul>
systemmaintmenu
  }

$hasusermaintenance = does_user_have_named_priv($dbh, $usersid, 'Modify Users');
if ($hasusermaintenance == 1)
  {
  print <<usermaintmenu;
  <ul title="User Maintenance">
  <lh>User Maintenance
  <li><a href="/cgi-bin/oncs/users_maint.pl?action=query&updatetable=users&pagetitle=Users$idstr">Users</a></li>
  </ul>
usermaintmenu
  }

print <<maintmenuend;
</ul>
<form name=params>
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
</form>
</body>
</html>
maintmenuend
