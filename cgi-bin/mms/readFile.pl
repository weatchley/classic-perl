#!/usr/local/bin/perl -w
#
# $Source: /home/atchleyb/rcs/mms/perl/RCS/readFile.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2003/11/12 20:41:33 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: readFile.pl,v $
# Revision 1.1  2003/11/12 20:41:33  atchleyb
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
