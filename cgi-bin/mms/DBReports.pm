# DB Report functions
#
# $Source: /data/dev/rcs/mms/perl/RCS/DBReports.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/12/07 18:49:21 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBReports.pm,v $
# Revision 1.1  2004/12/07 18:49:21  atchleyb
# Initial revision
#
#
#
#
#

package DBReports;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
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


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
###################################################################################################################################




1; #return true
