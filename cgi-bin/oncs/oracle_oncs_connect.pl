#!/usr/local/bin/newperl -w
#
# CGI utilities for writing files to the server
#
# $Source:$
# $Revision:$
# $Date:$
# $Author:$
# $Locker:$
# $Log:$
#

use vars qw($EGID $GID);
my $username = "";
my $password = "";
my $lineIn = "";
my $CMSProductionStatus = ($ENV{SERVER_STATE} ne "PRODUCTION") ? 0 : 1;
#my $SYSPathRoot = ($CMSProductionStatus) ? "/usr/local/www/gov.ymp.intranet" : "/usr/local/www/gov.ymp.intradev";
my $SYSPathRoot = $ENV{PATH_TO_ROOT};
my $filepath = "$SYSPathRoot/data/apps/cms_historical/.init";
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
} 
else {
    print "$lineIn//tail\n";
}
