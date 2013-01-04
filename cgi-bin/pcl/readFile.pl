#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/scm/perl/RCS/readFile.pl,v $
#
# $Revision: 1.1 $
#
# $Date: 2002/09/18 01:21:04 $
#
# $Author: mccartym $
#
# $Locker:  $
#
# $Log: readFile.pl,v $
# Revision 1.1  2002/09/18 01:21:04  mccartym
# Initial revision
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
