# DB Browse functions
#
# $Source: /home/atchleyb/rcs/mms/perl/RCS/DBBrowse.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2003/11/12 20:25:27 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBBrowse.pm,v $
# Revision 1.1  2003/11/12 20:25:27  atchleyb
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
