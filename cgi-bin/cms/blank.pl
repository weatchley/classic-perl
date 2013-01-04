#!/usr/local/bin/newperl -w

# This is a script for a blank screen
#
# $Source: /data/dev/cirs/perl/RCS/blank.pl,v $
# $Revision: 1.4 $
# $Date: 2000/07/06 23:32:21 $
# $Author: munroeb $
# $Locker:  $
# $Log: blank.pl,v $
# Revision 1.4  2000/07/06 23:32:21  munroeb
# finished mods to javascripts and html
#
# Revision 1.3  2000/07/05 23:01:18  munroeb
# made minor changes to html and javascripts.
#
# Revision 1.2  2000/05/18 23:11:48  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/11 21:39:31  zepedaj
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

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $oncscgi = new CGI;

# tell the browser that this is an html page using the header method
print $oncscgi->header('text/html');

my $username = $oncscgi->param('loginusername');
my $usersid = $oncscgi->param('loginusersid');
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

print <<documentbody;
<html>
<head>

<!-- include external javascript code -->
<script src="$ONCSJavaScriptPath/oncs-utilities.js"></script>

<script type="text/javascript">
  <!--
  if (parent == self)  // not in frames, go to login screen.
    {
    location = '$ONCSCGIDir/login.pl'
    }
  //-->
</script>

<title>Blank</title>
</head>
<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>

</body>
</html>
documentbody

1;
