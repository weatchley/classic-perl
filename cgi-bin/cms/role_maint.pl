#!/usr/local/bin/newperl
# - !/usr/bin/perl

#
# CIRS Role Maintenance Frameset Script
#
# $Source: /data/dev/cirs/perl/RCS/role_maint.pl,v $
# $Revision: 1.8 $
# $Date: 2000/12/21 21:28:33 $
# $Author: naydenoa $
# $Locker:  $
# $Log: role_maint.pl,v $
# Revision 1.8  2000/12/21 21:28:33  naydenoa
# Some interface rewrite
#
# Revision 1.7  2000/09/21 21:53:03  atchleyb
# updated title
#
# Revision 1.6  2000/08/22 15:40:08  atchleyb
# added check schema line
#
# Revision 1.5  2000/07/14 20:25:17  atchleyb
# Changed frame structure
# change text for image text label
#
# Revision 1.4  2000/07/06 23:45:17  munroeb
# finished making mods to html and javascripts.
#
# Revision 1.3  2000/07/05 23:10:14  munroeb
# made minor changes to html and javascripts.
#
# Revision 1.2  2000/05/18 23:16:02  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/12 00:00:33  zepedaj
# Initial revision
#
#

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $cirscgi = new CGI;

$SCHEMA = (defined($cirscgi->param("schema"))) ? $cirscgi->param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

# print content type header
print $cirscgi->header('text/html');

my $username = $cirscgi->param('loginusername');
my $usersid = $cirscgi->param('loginusersid');

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq ""))

  {
  print <<openloginpage;
  <script type="text/javascript">
  <!--
  parent.location='$ONCSCGIDir/login.pl';
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
      location = '$ONCSCGIDir/login.pl'
      }

    //-->
  </script>
  <script language="JavaScript" type="text/javascript">
  <!--
      doSetTextImageLabel('Role Maintenance');
  //-->
</script>
scriptlabel1

print <<endofhead;
</head>
endofhead

#Build Frameset for modifying roles with multiple picklists.
print <<frameset1;
<frameset rows=100,60,* frameborder=no frameborder=0 framespacing=0>
<frame src="$ONCSCGIDir/role_maint_sel1.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA" name=rolesel1 noresize frameborder=no frameborder=0>
<frame src="$ONCSCGIDir/role_maint_selblank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA" name=rolesel2 noresize frameborder=no frameborder=0>
<frame src="$ONCSCGIDir/role_maint_selblank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA" name=rolesel3 noresize frameborder=no frameborder=0>
</frameset>
frameset1
print "</html>\n";
