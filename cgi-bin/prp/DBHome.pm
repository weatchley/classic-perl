# DB Home functions
#
# $Source: /data/dev/rcs/prp/perl/RCS/DBHome.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/04/22 20:27:29 $
#
# $Author: naydenoa $
#
# $Locker:  $
#
# $Log: DBHome.pm,v $
# Revision 1.1  2004/04/22 20:27:29  naydenoa
# Initial revision
#
#
#
#
#

package DBHome;
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
