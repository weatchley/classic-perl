#!/usr/local/bin/perl -w

# blank output file cgi
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
#
#
use strict;
use integer;
#
$| = 1;
#
# get all required libraries and modules
use CGI;

use strict;
use MMS_Header qw(:Constants);

# create cgi object for processing
my $mmscgi = new CGI;

# tell the browser that this is an html page using the header method
print $mmscgi->header('text/html');

# print page
print <<END_OF_BLOCK;

<html>
<head>
   <base target=main>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <title>Business Management System</title>
</head>

<body background=$MMSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>

</body>
</html>

END_OF_BLOCK

#