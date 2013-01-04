#!/usr/local/bin/perl -w
#
# blank output file cgi
#
# $Source: /data/dev/rcs/pcl/perl/RCS/blank.pl,v $
#
# $Revision: 1.3 $
#
# $Date: 2003/02/03 19:56:38 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: blank.pl,v $
# Revision 1.3  2003/02/03 19:56:38  atchleyb
# fixed misnamed global variable
#
# Revision 1.2  2003/02/03 19:21:42  atchleyb
# removed refs to PCL
#
# Revision 1.1  2002/09/17 20:11:27  atchleyb
# Initial revision
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
use SharedHeader qw(:Constants);

# create cgi object for processing
my $mycgi = new CGI;

# tell the browser that this is an html page using the header method
print $mycgi->header('text/html');

# print page
print <<END_OF_BLOCK;

<html>
<head>
   <base target=main>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <title>Comment Response Database</title>
</head>

<body background=$SYSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>

</body>
</html>

END_OF_BLOCK

#
