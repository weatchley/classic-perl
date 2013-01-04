#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/prp/perl/RCS/readFile.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/04/22 20:49:42 $
#
# $Author: naydenoa $
#
# $Locker:  $
#
# $Log: readFile.pl,v $
# Revision 1.1  2004/04/22 20:49:42  naydenoa
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
