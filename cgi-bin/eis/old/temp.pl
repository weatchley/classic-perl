#!/usr/local/bin/newperl -w

# CGI utilities for writing files to the server
#
# $Source: /data/dev/eis/perl/RCS/oracle_crd_connect.pl,v $
#
# $Revision: 1.5 $
#
# $Date: 2000/11/28 23:19:49 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: oracle_crd_connect.pl,v $
# Revision 1.5  2000/11/28 23:19:49  atchleyb
# fixed bug in username/password parse
#
# Revision 1.4  2000/11/24 21:28:18  atchleyb
# Switched order of password and username
#
# Revision 1.3  2000/11/22 21:29:02  atchleyb
# updated to allow for .init file to have both password and username
# or only password
#
# Revision 1.2  2000/01/14 16:54:24  atchleyb
# modified to only have password in file
#

use vars qw($EGID $GID);
my $username = "";
my $password = "";
my $lineIn = "";
my $filepath = "/data/crd/" . lc($ENV{'CRDType'}) . "/.init";
my $temp = $EGID;
$EGID = $GID;
if (open (FH, "<$filepath")) {
    $lineIn = <FH>;
    chop($lineIn);
    close (FH);
}
$EGID = $temp;

if (index($lineIn,'//') > 1) {
    ($username, $password) = split('//', $lineIn);
    print "$password//$username\n";
} else {
    print "$lineIn//tail\n";
}
