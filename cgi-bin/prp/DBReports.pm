# DB Report functions
#
# $Source: /data/dev/rcs/prp/perl/RCS/DBReports.pm,v $
# $Revision: 1.1 $
# $Date: 2004/04/22 20:28:23 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: DBReports.pm,v $
# Revision 1.1  2004/04/22 20:28:23  naydenoa
# Initial revision
#
#

package DBReports;

# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
    );
%EXPORT_TAGS =( 
    Functions => [qw(
    )]
);

###############
1; #return true
