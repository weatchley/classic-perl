# DB Report functions for the SCM
#
# $Source: /data/dev/rcs/pcl/perl/RCS/DBReports.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2003/02/03 20:03:40 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBReports.pm,v $
# Revision 1.2  2003/02/03 20:03:40  atchleyb
# removed refs to SCM
#
# Revision 1.1  2002/10/31 17:02:42  atchleyb
# Initial revision
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
