#!/usr/local/bin/newperl
# - !/usr/bin/perl

#
# CIRS Role Maintenance Selection - blank page for frames
#
# $Source: /data/dev/cirs/perl/RCS/role_maint_selblank.pl,v $
# $Revision: 1.6 $
# $Date: 2000/08/22 15:47:20 $
# $Author: atchleyb $
# $Locker:  $
# $Log: role_maint_selblank.pl,v $
# Revision 1.6  2000/08/22 15:47:20  atchleyb
# added check schema line
#
# Revision 1.5  2000/07/14 20:28:11  atchleyb
# removed text image label code
#
# Revision 1.4  2000/07/06 23:49:06  munroeb
# finished mods to html and javascripts.
#
# Revision 1.3  2000/07/05 23:12:22  munroeb
# made minor changes to html and javascripts
#
# Revision 1.2  2000/05/18 23:16:32  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/12 00:01:43  zepedaj
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
topofpage1

print <<scriptlabel1;
<!-- include external javascript code -->
<script src="$ONCSJavaScriptPath/oncs-utilities.js"></script>
scriptlabel1

print <<endofhead;
</head>
endofhead

#Blank section of the page. This will be replaced by information as the picklists are processed based on options selected
print <<blankbody1;
<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
</body>
blankbody1
print "</html>\n";
