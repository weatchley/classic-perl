#!/usr/local/bin/perl -w
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

use strict;
use integer;
use Getopt::Long;

my $file = "";
GetOptions("file=s" => \$file);
if (open (FH, "<$file")) {
   print <FH>; 
   close (FH);
}
exit();
