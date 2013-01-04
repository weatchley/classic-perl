#!/usr/local/bin/newperl -w

# blank output file cgi
#
# $Source: /home/atchleyb/eisrcs/perl/RCS/blank.pl,v $
#
# $Revision: 1.3 $
#
# $Date: 2000/01/14 23:31:30 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: blank.pl,v $
# Revision 1.3  2000/01/14 23:31:30  atchleyb
# replaced all references to EIS with $crdtype
#
# Revision 1.2  1999/07/30 20:22:07  atchleyb
# got rid of hard coded paths
#
# Revision 1.1  1999/07/14 18:28:01  atchleyb
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
use CRD_Header qw(:Constants);

# create cgi object for processing
my $crdcgi = new CGI;

# tell the browser that this is an html page using the header method
print $crdcgi->header('text/html');

# print page
print <<END_OF_BLOCK;

<html>
<head>
   <base target=main>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <title>Comment Response Database</title>
</head>

<body background=$CRDImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>

</body>
</html>

END_OF_BLOCK

#