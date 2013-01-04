# DB Departments functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBChargeNumbers.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2008/02/11 18:20:29 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBChargeNumbers.pm,v $
# Revision 1.2  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.1  2004/01/09 23:33:30  atchleyb
# Initial revision
#
#
#
#
#
#
#

package DBChargeNumbers;
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
      &getCNInfo     &doProcessChargeNumberEntry    &getApprovedAmount   &doProcessChargeNumberCopy
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getCNInfo     &doProcessChargeNumberEntry    &getApprovedAmount   &doProcessChargeNumberCopy
    )]
);


###################################################################################################################################
sub getCNInfo {  # routine to get a hash of cn info
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );

    my $i = 0;
    my %cnInfo;
    my $sqlcode = "SELECT chargenumber, fyscalyear, site, description, wbs, funding FROM $args{schema}.charge_numbers WHERE chargenumber='$args{id}'";

#print STDERR "\n$sqlcode\n\n";
    ($cnInfo{chargenumber}, $cnInfo{fyscalyear}, $cnInfo{site}, $cnInfo{description}, $cnInfo{wbs}, $cnInfo{funding}) = 
        $args{dbh}->selectrow_array($sqlcode);
    ($cnInfo{sitecode}, $cnInfo{sitename}, $cnInfo{companycode}, $cnInfo{trackfunding}) = $args{dbh}->selectrow_array("SELECT sitecode, name, companycode, trackfunding FROM $args{schema}.site_info WHERE id=$cnInfo{site}");

    return (%cnInfo);
}


###################################################################################################################################
sub doProcessChargeNumberEntry {  # routine to enter a new charge number or update a charge number
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "",  # new or update
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    my $id;
    
    eval {
        if ($args{type} eq 'new') {
            $sqlcode = "INSERT INTO $args{schema}.charge_numbers (chargenumber, fyscalyear, site, description, wbs, funding) VALUES ";
            $sqlcode .= "('$settings{chargenumber}', $settings{fyscalyear}, $settings{site}, " . $args{dbh}->quote($settings{description}) . ", ";
            $sqlcode .= ((defined($settings{wbs}) && $settings{wbs} > ' ') ? $args{dbh}->quote($settings{wbs}) : "NULL") . ", ";
            $sqlcode .= "$settings{funding})";
            
#print STDERR "\n$sqlcode\n\n";
            $args{dbh}->do($sqlcode);
        } else {
            $sqlcode = "UPDATE $args{schema}.charge_numbers SET chargenumber = '$settings{chargenumber}', fyscalyear = $settings{fyscalyear},";
            $args{dbh}->quote($settings{name}) . ", ";
            $sqlcode .= "description=" . $args{dbh}->quote($settings{description});
            $sqlcode .= ", wbs=" . ((defined($settings{wbs}) && $settings{wbs} > ' ') ? $args{dbh}->quote($settings{wbs}) : "NULL") . " ";
            $sqlcode .= ", funding=" . ((defined($settings{funding}) && $settings{funding} > ' ') ? $args{dbh}->quote($settings{funding}) : "0") . " ";
            $sqlcode .= "WHERE chargenumber = '$settings{oldchargenumber}'";
#print STDERR "\n$sqlcode\n\n";
            $args{dbh}->do($sqlcode);
        }

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$settings{chargenumber});
}


###################################################################################################################################
sub doProcessChargeNumberCopy {  # routine to copy charge numbers for a site from one year to another
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    my $id;
    
    eval {
        $sqlcode = "INSERT INTO $args{schema}.charge_numbers (chargenumber, fyscalyear, site, description, wbs, funding) ";
        $sqlcode .= "(SELECT chargenumber||'-'||$settings{toyear}, $settings{toyear}, site, description, wbs, funding FROM $args{schema}.charge_numbers ";
        $sqlcode .= "WHERE site=$settings{site} AND fyscalyear=$settings{fromyear})";
#print STDERR "\n$sqlcode\n\n";
        $args{dbh}->do($sqlcode);
        $status = 1;

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return ($status);
}


###################################################################################################################################
sub getApprovedAmount {  # routine to get dollars that have been approved or in approval for a given cn
###################################################################################################################################
    my %args = (
        id => "0",
        @_,
    );

    my $i = 0;
    my $pdamount = 0;
    my $amount = 0;
    my $sqlcode = "SELECT SUM(pd.pdtotal) FROM $args{schema}.purchase_documents pd WHERE pd.chargenumber='$args{id}' AND pd.status > 2 AND pd.status <= 11";
    ($pdamount) = $args{dbh}->selectrow_array($sqlcode);

    $sqlcode = "SELECT SUM(pocn.amount) FROM $args{schema}.po_chargenumbers pocn, $args{schema}.purchase_documents pd WHERE pd.prnumber=pocn.prnumber AND pocn.chargenumber='$args{id}' AND pd.status > 11";

#print STDERR "\n$sqlcode\n\n";
    ($amount) = $args{dbh}->selectrow_array($sqlcode);

    return ($pdamount + $amount);
}


1; #return true
