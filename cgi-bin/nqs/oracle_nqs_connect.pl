#!/usr/local/bin/perl -w

# CGI utilities for writing files to the server
#
# $Source: /usr/local/homes/atchleyb/rcs/qa/perl/RCS/oracle_nqs_connect.pl,v $
#
# $Revision: 1.3 $
#
# $Date: 2007/11/21 21:27:29 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: oracle_nqs_connect.pl,v $
# Revision 1.3  2007/11/21 21:27:29  atchleyb
# CREQ000112 - removed hardcoded path to root info
#
# Revision 1.2  2002/10/23 23:39:18  starkeyj
# modified to add 'use strict' pragma
#
# Revision 1.1  2001/07/26 16:32:06  starkeyj
# Initial revision
#
#
use strict;
use vars qw($EGID $GID);
my $username = "";
my $password = "";
my $lineIn = "";
my $NQSProductionStatus = ($ENV{SERVER_STATE} ne "PRODUCTION") ? 0 : 1;
#my $SYSPathRoot = ($NQSProductionStatus) ? "/usr/local/www/gov.ymp.intranet" : "/usr/local/www/gov.ymp.intradev";
my $SYSPathRoot = $ENV{PATH_TO_ROOT};
my $filepath = "$SYSPathRoot/data/apps/nqs/.init";
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
