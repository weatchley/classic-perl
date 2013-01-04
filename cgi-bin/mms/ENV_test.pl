#!/usr/local/bin/perl -w

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
#use eis/CRD_Header qw(:Constants);

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
   <title>Environment Variables</title>
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

use Cwd;
print "\n<br>\nCurrent Working Directory:\t" . cwd() . "\n";

print <<END_OF_BLOCK;
</body>
</html>

END_OF_BLOCK

#