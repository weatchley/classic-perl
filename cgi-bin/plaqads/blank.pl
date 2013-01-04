#!/usr/local/bin/perl -w
#
# blank output file cgi
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/blank.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/07/27 18:27:16 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: blank.pl,v $
# Revision 1.1  2004/07/27 18:27:16  atchleyb
# Initial revision
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
   <title>Blank</title>
</head>

<body background=$SYSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>

</body>
</html>

END_OF_BLOCK

#
