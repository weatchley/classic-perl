# DB Browse functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/DBBrowse.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/07/27 18:27:16 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBBrowse.pm,v $
# Revision 1.1  2004/07/27 18:27:16  atchleyb
# Initial revision
#
#
#
#
#

package DBBrowse;
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
