# DB Home functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBHome.pm,v $
#
# $Revision: 1.6 $
#
# $Date: 2009/07/31 22:43:26 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBHome.pm,v $
# Revision 1.6  2009/07/31 22:43:26  atchleyb
# Updates related to ACR0907_004-SWR0149   New intermediate buyer role, minor bug fixes
#
# Revision 1.5  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.4  2006/03/27 19:10:09  atchleyb
# CR 0023 - updated to have new, simpler design for the purchaseing and receiving menues, simular to the accounts payable menu.
#
# Revision 1.3  2005/01/21 00:12:30  atchleyb
# Updated per CREQ00003 to add check for site specific roles in getPRsForRFP
#
# Revision 1.2  2004/04/22 21:39:52  atchleyb
# Updates related to SCR 1 (add field briefdescription)
#
# Revision 1.1  2003/11/12 20:26:21  atchleyb
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
use DBPurchaseDocuments qw(getPDByStatus);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getPRsForRFP
);
%EXPORT_TAGS =( 
    Functions => [qw(
      &getPRsForRFP
    )]
);


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getPRsForRFP {
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my $where = "";
    my $threshold = 0;
    my @PRList = ();
    my ($site) = $args{dbh}->selectrow_array("SELECT d.site FROM $args{schema}.departments d, $args{schema}.user_dept up " .
                     "WHERE d.id=up.dept AND up.userid=$args{userID}");
    if (&doesUserHaveRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[6])) {
        $threshold = 0;
    } elsif (&doesUserHaveRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[21])) {
        ($threshold) = $args{dbh}->selectrow_array("SELECT nvalue1 FROM $args{schema}.rules WHERE type=13 AND site=$site");
    } elsif (&doesUserHaveRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[22])) {
        ($threshold) = $args{dbh}->selectrow_array("SELECT nvalue1 FROM $args{schema}.rules WHERE type=12 AND site=$site");
    } elsif (&doesUserHaveRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[7])) {
        ($threshold) = $args{dbh}->selectrow_array("SELECT nvalue1 FROM $args{schema}.rules WHERE type=1 AND site=$site");
    }
    my @PDList = &getPDByStatus(dbh=>$args{dbh}, schema=>$args{schema}, statusList=>(4));
    my $prCount=0;
    for (my $i=0; $i<$#PDList; $i++) {
      if (&doesUserHaveRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[6, 7, 21, 22], site => $PDList[$i]{site})) {
        my $sqlcode = "SELECT SUM(quantity * unitprice) FROM $args{schema}.items WHERE prnumber='$PDList[$i]{prnumber}'";
        my ($subtotal) = $args{dbh}->selectrow_array($sqlcode);
        if ($threshold == 0) {
            $PRList[$prCount]{prnumber} = $PDList[$i]{prnumber};
            $PRList[$prCount]{priority} = $PDList[$i]{priority};
            $PRList[$prCount]{briefdescription} = $PDList[$i]{briefdescription};
            $PRList[$prCount]{dollarvalue} = $subtotal + $PDList[$i]{shipping} + $PDList[$i]{tax};
            $prCount++;
        } else {
            if (($subtotal + $PDList[$i]{shipping} + $PDList[$i]{tax}) < $threshold) {
                $PRList[$prCount]{prnumber} = $PDList[$i]{prnumber};
                $PRList[$prCount]{priority} = $PDList[$i]{priority};
                $PRList[$prCount]{briefdescription} = $PDList[$i]{briefdescription};
                $PRList[$prCount]{dollarvalue} = $subtotal + $PDList[$i]{shipping} + $PDList[$i]{tax};
                $prCount++;
            }
        }
      }
    }
    
    return (@PRList);
}


###################################################################################################################################
###################################################################################################################################




1; #return true
