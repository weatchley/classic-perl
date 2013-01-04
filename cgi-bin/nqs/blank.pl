#!/usr/local/bin/newperl -w

# This is a script for a blank screen
# $Source $
#
# $Revision: 1.1 $
#
# $Date: 2001/07/06 23:04:03 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: blank.pl,v $
# Revision 1.1  2001/07/06 23:04:03  starkeyj
# Initial revision
#
# 

use NQS_Header qw(:Constants);
#use UI_Widgets qw(:Functions);
use NQS_Utilities_Lib qw(:Functions);
#use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $DDTcgi = new CGI;

# tell the browser that this is an html page using the header method
print $DDTcgi->header('text/html');

my $username = $DDTcgi->param('loginusername');
my $usersid = $DDTcgi->param('loginuserid');


print <<documentbody;
<html>
<head>

<!-- include external javascript code -->
<script src="$NQSJavaScriptPath/utilities.js"></script>

<script type="text/javascript">
  <!--
  if (parent == self)  // not in frames, go to login screen.
    {
    location = '$NQSCGIDir/trend_login.pl'
    }
  //-->
</script>

<title>Blank</title>
</head>
<body background=$NQSImagePath/background.gif text=$NQSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
<H2>***This is BLANK***</H2>
</body>
</html>
documentbody

1;
