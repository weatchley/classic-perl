#!/usr/local/bin/perl -w

# CGI utilities for writing files to the server
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/dms/perl/RCS/oracle_dms_connect.pl,v $
#
# $Revision: 1.3 $
#
# $Date: 2007/11/23 19:23:27 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: oracle_dms_connect.pl,v $
# Revision 1.3  2007/11/23 19:23:27  atchleyb
# CR 5 - changed so that path to root is not hard coded
#
# Revision 1.2  2002/10/04 20:00:52  atchleyb
# updated to use strict
#
# Revision 1.1  2002/03/08 21:09:15  atchleyb
# Initial revision
#
#

use strict;
use vars qw($EGID $GID);
my $username = "";
my $password = "";
my $lineIn = "";
my $DMSProductionStatus = ($ENV{'SERVER_STATE'} ne "PRODUCTION") ? 0 : 1;
my $SYSPathRoot = $ENV{PATH_TO_ROOT};
#my $filepath = (($DMSProductionStatus) ? "/usr/local/www/gov.ymp.intranet/data/apps/dms/.init" : "/usr/local/www/gov.ymp.intradev/data/apps/dms/.init");
my $filepath = (($DMSProductionStatus) ? "$SYSPathRoot/data/apps/dms/.init" : "$SYSPathRoot/data/apps/dms/.init");
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
