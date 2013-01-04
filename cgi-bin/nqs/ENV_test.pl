#!/usr/local/bin/newperl -w

# blank output file cgi
#
# $Source: /data/dev/rcs/nqs/perl/RCS/ENV_test.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2001/07/26 15:52:11 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: ENV_test.pl,v $
# Revision 1.2  2001/07/26 15:52:11  starkeyj
# modified include file - changed TEST_Header to NQS_Header
#
# Revision 1.1  2001/07/06 23:04:03  starkeyj
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
use NQS_Header qw(:Constants);
# create cgi object for processing
my $NQScgi = new CGI;

# tell the browser that this is an html page using the header method
print $NQScgi->header('text/html');

# print page
print <<END_OF_BLOCK;

<html>
<head>
   <base target=main>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <title>NQS</title>
</head>

<body text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
END_OF_BLOCK
foreach my $key (sort keys %ENV) {
    print "$key:\t$ENV{$key}<br>\n";
}

my $temp = substr($ENV{'SCRIPT_FILENAME'},0,(rindex($ENV{'SCRIPT_FILENAME'},'/')));
print "\n<br>\nDir:\t$temp\n";
$temp = substr($temp,(rindex($temp,'/') + 1));
print "\n<br>\nDir:\t$temp\n";

print <<END_OF_BLOCK;
</body>
</html>

END_OF_BLOCK

#