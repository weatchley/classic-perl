#!/usr/local/bin/newperl
# - !/usr/bin/perl

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $cirscgi = new CGI;

# print content type header
print $cirscgi->header('text/html');

my $username = $cirscgi->param('loginusername');
my $usersid = $cirscgi->param('loginusersid');

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

#print top of page
print <<topofpage1;
<html>
<head>
<meta name="pragma" content="no-cache">
<meta name="expires" content="0">
<meta http-equiv="expires" content="0">
<meta http-equiv="pragma" content="no-cache">
<title>Role Maintenance</title>
topofpage1

print <<scriptlabel1;
<!-- include external javascript code -->
<script src="$ONCSJavaScriptPath/oncs-utilities.js"></script>

    <script type="text/javascript">
    <!--

    var dosubmit = true;
    if (parent == self)  // not in frames
      {
      location = '/cgi-bin/oncs/oncs_user_login.pl'
      }

    //-->
  </script>
scriptlabel1

print <<endofhead;
</head>
endofhead

#Build Frameset for modifying roles with multiple picklists.
print <<frameset1;
<frameset rows=70,110,80,* frameborder=no frameborder=0 framespacing=0>
<frame src="/cgi-bin/oncs/role_maint_title.pl?loginusersid=$usersid&loginusername=$username" name=rolehead noresize scrolling=no frameborder=no frameborder=0>
<frame src="/cgi-bin/oncs/role_maint_sel1.pl?loginusersid=$usersid&loginusername=$username" name=rolesel1 noresize frameborder=no frameborder=0>
<frame src="/cgi-bin/oncs/role_maint_selblank.pl?loginusersid=$usersid&loginusername=$username" name=rolesel2 noresize frameborder=no frameborder=0>
<frame src="/cgi-bin/oncs/role_maint_selblank.pl?loginusersid=$usersid&loginusername=$username" name=rolesel3 noresize frameborder=no frameborder=0>
</frameset>
frameset1
print "</html>\n";
