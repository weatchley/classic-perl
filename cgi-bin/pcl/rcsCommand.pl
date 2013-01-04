#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/scm/perl/RCS/rcsCommand.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2002/11/27 00:09:13 $
#
# $Author: mccartym $
#
# $Locker:  $
#
# $Log: rcsCommand.pl,v $
# Revision 1.2  2002/11/27 00:09:13  mccartym
# added support for several rcs and file (move, copy, diff, edit) commands
#
# Revision 1.1  2002/09/15 20:40:29  mccartym
# Initial revision
#
#

use strict;
use integer;
use English;
use Getopt::Long;

$ENV{PATH} = '';
my $commandPath = "/usr/bin";
my $rcsCommandPath = "/pub/solaris8/client/bin";
my ($fullCommand, $command, $options, $file, $file1, $file2, $from, $to) = ("", "", "", "", "", "", "", "");
GetOptions(
   "command=s" => \$command,
   "options:s" => \$options,
   "file:s"    => \$file,
   "file1:s"   => \$file1,
   "file2:s"   => \$file2,
   "from:s"    => \$from,
   "to:s"      => \$to,
);
$command =~ m/([a-z]+)/;
$command = $1;

if ($options) {
   $options =~ m/(.*)/;
   $options = $1;
}

if ($file) {
#   $file =~ m/([\*_\-\w]+\.[\*,\w]+)/;
#   $file =~ m/([\/\.\*_\-\w]+)/;
   $file =~ m/(.*)/;
   $file = $1;
}

if ($file1) {
#   $file1 =~ m/([\*_\-\w]+\.[\*,\w]+)/;
#   $file1 =~ m/([\/\.\*_\-\w]+)/;
   $file1 =~ m/(.*)/;
   $file1 = $1;
}
if ($file2) {
#   $file2 =~ m/([\*_\-\w]+\.[\*,\w]+)/;
#   $file2 =~ m/([\/\.\*_\-\w]+)/;
   $file2 =~ m/(.*)/;
   $file2 = $1;
}
if ($from) {
   $from =~ m/(.*)/;
   $from = $1;
}
if ($to) {
   $to =~ m/(.*)/;
   $to = $1;
}

if ($command eq 'deletefile') {
   $fullCommand = "$commandPath/rm -f $file";
} elsif ($command eq 'renamefile') {
   $fullCommand = "$commandPath/mv $from $to";
} elsif ($command eq 'copyfile') {
   $fullCommand = "$commandPath/cp $from $to";
} elsif ($command eq 'comparefiles') {
   $fullCommand = "$commandPath/diff $file1 $file2 > $to";
} elsif ($command eq 'editfile') {
   $fullCommand = "$commandPath/sed $options $file > $to";
} elsif ($command eq 'setfilepermissions') {
   $fullCommand = "$commandPath/chmod $options $file";
} else {
   $fullCommand = "$rcsCommandPath/$command $options $file";
   $fullCommand .= " > $to" if $to;
}
#print STDERR "***$fullCommand***\n";
my $rc = system $fullCommand;
print $rc;
exit();
