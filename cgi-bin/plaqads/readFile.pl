#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/readFile.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/07/27 18:27:16 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: readFile.pl,v $
# Revision 1.1  2004/07/27 18:27:16  atchleyb
# Initial revision
#
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
