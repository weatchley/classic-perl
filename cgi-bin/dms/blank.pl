#!/usr/local/bin/newperl -w

# blank output file cgi
#
# $Source: /home/atchleyb/rcs/dms/perl/RCS/blank.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2002/03/08 21:05:48 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: blank.pl,v $
# Revision 1.1  2002/03/08 21:05:48  atchleyb
# Initial revision
#
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
use DMS_Header qw(:Constants);

# create cgi object for processing
my $dmscgi = new CGI;

# tell the browser that this is an html page using the header method
print $dmscgi->header('text/html');

# print page
print <<END_OF_BLOCK;

<html>
<head>
   <base target=main>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <title>Business Management System</title>
</head>

<body background=$DMSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>

</body>
</html>

END_OF_BLOCK

#