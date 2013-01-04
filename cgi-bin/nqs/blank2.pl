#!/usr/local/bin/newperl -w

# This is a script for a blank screen
#
# 
#
#

use NQS_Header qw(:Constants);
#use UI_Widgets qw(:Functions);
use OQA_Utilities_Lib qw(:Functions);
#use NQS_specific qw(:Functions);

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

my $username = $DDTcgi->param('username');
my $usersid = $DDTcgi->param('userid');


print <<documentbody;
<html>
<head>

<!-- include external javascript code -->
<script src="$NQSJavaScriptPath/utilities.js"></script>

<script type="text/javascript">
  <!--
  if (parent == self)  // not in frames, go to login screen.
    {
    location = '$NQSCGIDir/login.pl'
    }
  //-->
</script>

<title>Blank</title>
</head>
<body background=$NQSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
<H2>***This is BLANK***</H2>
</body>
</html>
documentbody

1;
