# DB Bids functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBBids.pm,v $
#
# $Revision: 1.10 $
#
# $Date: 2009/07/31 22:43:26 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBBids.pm,v $
# Revision 1.10  2009/07/31 22:43:26  atchleyb
# Updates related to ACR0907_004-SWR0149   New intermediate buyer role, minor bug fixes
#
# Revision 1.9  2009/06/26 21:57:40  atchleyb
# ACR0906_001 - List of changes
#
# Revision 1.8  2008/08/29 15:50:29  atchleyb
# ACR0808_013 - Fix problems with clauses and PO's, fix problem with shipping costs on bids not transfering to PO
#
# Revision 1.7  2006/05/17 22:46:03  atchleyb
# CR0026 - added response field and updated to insert additional items on pd from winning bid
#
# Revision 1.6  2006/01/31 23:25:09  atchleyb
# CR 0022 - Updated to reuse PO number if puchase document has already been assigned one (i.e. status was moved back)
#
# Revision 1.5  2004/12/07 17:22:55  atchleyb
# added new funciton doProcessBidAwardItemUpdate
#
# Revision 1.4  2004/04/01 23:46:48  atchleyb
# updated to ask for due date
#
# Revision 1.3  2004/02/27 00:00:03  atchleyb
# added qualification on sql statement
#
# Revision 1.2  2003/12/09 22:12:49  atchleyb
# fixed sql problem with the addition of terms
#
# Revision 1.1  2003/12/02 16:55:15  atchleyb
# Initial revision
#
#
#
#
#
#

package DBBids;
#
# get all required libraries and modules
use strict;
use DBPurchaseDocuments qw(getPDInfo getNextPOSeq);
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UI_Widgets qw(lpadzero);
use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
#use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
        &getBids            &getBidInfo                   &genNewBid
        &doProcessBidSave   &doProcessAddVendor           &doProcessSaveBidRemarks
        &doProcessBidAward  &doProcessBidAwardItemUpdate  &doProcessBidDelete
    );
%EXPORT_TAGS =( 
    Functions => [qw(
        &getBids            &getBidInfo                   &genNewBid
        &doProcessBidSave   &doProcessAddVendor           &doProcessSaveBidRemarks
        &doProcessBidAward  &doProcessBidAwardItemUpdate  &doProcessBidDelete
    )]
);


my %displayControl = (loaded => 'F');


###################################################################################################################################
sub getBids {  # routine to get all bids for a pr
###################################################################################################################################
    my %args = (
        id => 0,
        bidID => 0,
        getMostRecent => 'F',
        @_,
    );
    $args{dbh}->{LongReadLen} = 1000000;
    $args{dbh}->{LongTruncOk} = 0;
    my @bids;
    my $where = (($args{bidID} != 0) ? " AND b.id=$args{bidID} " : "");
    my $orderBy = "";
    if ($args{getMostRecent} eq 'T') {
        $orderBy = "b.vendor,b.datebidreceived DESC,";
    }
    
    my $sqlcode = "SELECT b.id, b.prnumber, b.vendor, v.name, TO_CHAR(b.duedate, 'MM/DD/YYYY'), TO_CHAR(b.datebidreceived, 'MM/DD/YYYY'), ";
    $sqlcode .= "TO_CHAR(b.datebidreceived, 'HH24:MI'), b.shipping, b.fob, b.shipvia, b.terms, b.response ";
    $sqlcode .= "FROM $args{schema}.bids b, $args{schema}.vendors v ";
    $sqlcode .= "WHERE b.prnumber='$args{id}' AND b.vendor=v.id $where ORDER BY v.name, $orderBy b.datebidreceived";
#print STDERR "\n$sqlcode\n\n";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    my $i = 0;
    my $lastVendor = 0;
    while (my ($id, $prnumber, $vendor, $vendorname, $duedate, $datebidreceived, $timebidreceived, $shipping, $fob, $shipvia, $terms, $response) = $csr->fetchrow_array) {
        if ($lastVendor != $vendor || $args{getMostRecent} eq 'F') {
            ($bids[$i]{id},$bids[$i]{prnumber},$bids[$i]{vendor},$bids[$i]{vendorname},$bids[$i]{duedate},$bids[$i]{datebidreceived},
                $bids[$i]{timebidreceived}, $bids[$i]{shipping}, $bids[$i]{fob}, $bids[$i]{shipvia}, $bids[$i]{terms}, $bids[$i]{response}) = 
                      ($id, $prnumber, $vendor, $vendorname, $duedate, $datebidreceived, $timebidreceived, $shipping, $fob, $shipvia, $terms, $response);
            my $sqlcode = "SELECT bidid, itemnumber, description, partnumber, quantity, unitofissue, unitprice ";
            $sqlcode .= "FROM $args{schema}.bid_items WHERE bidid=$bids[$i]{id} ORDER BY itemnumber";
            my $csr = $args{dbh}->prepare($sqlcode);
            $csr->execute;
            my $j = 0;
            my $total = 0.0;
            while (($bids[$i]{items}[$j]{bidid},$bids[$i]{items}[$j]{itemnumber},$bids[$i]{items}[$j]{description},$bids[$i]{items}[$j]{partnumber},
                     $bids[$i]{items}[$j]{quantity},$bids[$i]{items}[$j]{unitofissue},$bids[$i]{items}[$j]{unitprice}) = $csr->fetchrow_array) {
                $total += ($bids[$i]{items}[$j]{quantity} * $bids[$i]{items}[$j]{unitprice});
                $j++;
            }
            $csr->finish;
            $bids[$i]{itemCount} = $j;
            $bids[$i]{total} = $total + $bids[$i]{shipping};
            
            $i++;
        }
        $lastVendor = $vendor;
    }
    $csr->finish;

    return (@bids);
}


###################################################################################################################################
sub getBidInfo {  # routine to get bid info
###################################################################################################################################
    my %args = (
        pd => 0,
        id => 0,
        @_,
    );

    my @bids = &getBids(dbh => $args{dbh}, schema => $args{schema}, id=>$args{pd}, bidID=>$args{id});
    my $hashRef = $bids[0];
    my %bid = %$hashRef;
    $bid{status} = 'old';
    

    return (%bid);
}



###################################################################################################################################
sub genNewBid {  # routine to gen anew blank bid
###################################################################################################################################
    my %args = (
        pd => 0,
        @_,
    );

    my %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{pd});
    my ($bidID, $date, $time) = $args{dbh}->selectrow_array("SELECT $args{schema}.bids_id.NEXTVAL, TO_CHAR(SYSDATE, 'MM/DD/YYYY'), " .
                      "TO_CHAR(SYSDATE, 'HH24:MI') FROM dual");
    my %bid = (
        id => $bidID,
        prnumber => $args{pd},
        vendor => 0,
        vendorname => "",
        datebidreceived => $date,
        timebidreceived => $time,
        duedate => "",
        shipping => 0.00,
        fob => 2,
        shipvia => "",
        terms => "",
        response => 1,
        items => [],
        itemCount => $pd{itemCount},
        total => 0.00,
        status => 'new',
    );
    for (my $i=0; $i<$pd{itemCount}; $i++) {
        $bid{items}[$i]{bidid} = $bidID;
        $bid{items}[$i]{itemnumber} = $pd{items}[$i]{itemnumber};
        $bid{items}[$i]{description} = $pd{items}[$i]{description};
        $bid{items}[$i]{partnumber} = $pd{items}[$i]{partnumber};
        $bid{items}[$i]{quantity} = $pd{items}[$i]{quantity};
        $bid{items}[$i]{unitofissue} = $pd{items}[$i]{unitofissue};
        $bid{items}[$i]{unitprice} = 0;
    }

    return (%bid);
}


###################################################################################################################################
sub doProcessBidSave {  # routine to process bid data
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $csr;

    eval {
        if ($settings{bidstatus} eq 'new') {
            my $sqlcode = "INSERT INTO $args{schema}.bids (id, prnumber, vendor, datebidreceived, duedate, shipping, fob, shipvia, terms, response) VALUES ";
            $sqlcode .= "($args{id}, '$settings{prnumber}', $settings{vendor}, ";
            $sqlcode .= "TO_DATE('$settings{datebidreceived} $settings{timebidreceived}', 'MM/DD/YYYY HH24:MI'), ";
            $sqlcode .= "TO_DATE('$settings{duedate}', 'MM/DD/YYYY HH24:MI'), $settings{shipping},";
            $sqlcode .= $args{dbh}->quote($settings{fob}) . "," . $args{dbh}->quote($settings{shipvia}) . ",";
            $sqlcode .= $args{dbh}->quote($settings{terms}) . ", $settings{response})";
#print STDERR "\n$sqlcode\n\n";
            $args{dbh}->do($sqlcode);
        } else {
            my $sqlcode = "UPDATE $args{schema}.bids SET vendor=$settings{vendor}, datebidreceived=";
            $sqlcode .= "TO_DATE('$settings{datebidreceived} $settings{timebidreceived}', 'MM/DD/YYYY HH24:MI'), ";
            $sqlcode .= "duedate=TO_DATE('$settings{duedate}', 'MM/DD/YYYY HH24:MI'), ";
            $sqlcode .= "shipping=$settings{shipping}, ";
            $sqlcode .= "fob=" . $args{dbh}->quote($settings{fob}) . ", ";
            $sqlcode .= "shipvia=" . $args{dbh}->quote($settings{shipvia}) . ", ";
            $sqlcode .= "terms=" . $args{dbh}->quote($settings{terms}) . ", ";
            $sqlcode .= "response=$settings{response} ";
            $sqlcode .= "WHERE id=$args{id}";
            $args{dbh}->do($sqlcode);
        }
        for (my $i=0; $i<=$settings{itemcount}; $i++) {
            if ($settings{items}[$i]{description} gt ' ') {
                $settings{items}[$i]{unitprice} = ((defined($settings{items}[$i]{unitprice}) && !$settings{items}[$i]{unitprice} le ' ') ? $settings{items}[$i]{unitprice} : 0);
                if ($settings{items}[$i]{olditemnumber} == 0 || $settings{bidstatus} eq 'new') {
                    my $sqlcode = "INSERT INTO $args{schema}.bid_items (bidid, itemnumber, description, partnumber, quantity, unitofissue, unitprice) ";
                    $sqlcode .= "VALUES ($args{id}, $settings{items}[$i]{itemnumber}, :description, '$settings{items}[$i]{partnumber}', ";
                    $sqlcode .= "$settings{items}[$i]{quantity}, '$settings{items}[$i]{unitofissue}', $settings{items}[$i]{unitprice})";
#print STDERR "\n$sqlcode\n\n";
                    $csr = $args{dbh}->prepare($sqlcode);
                    $csr -> bind_param (":description", $settings{items}[$i]{description}, {ora_type => ORA_CLOB, ora_field => 'description'});
                    $csr->execute;
                } else {
                    my $sqlcode = "UPDATE $args{schema}.bid_items SET itemnumber=$settings{items}[$i]{itemnumber}, description=:description, ";
                    $sqlcode .= "partnumber='$settings{items}[$i]{partnumber}', quantity=$settings{items}[$i]{quantity}, ";
                    $sqlcode .= "unitofissue='$settings{items}[$i]{unitofissue}', unitprice=$settings{items}[$i]{unitprice} ";
                    $sqlcode .= "WHERE bidid=$args{id} AND itemnumber=$settings{items}[$i]{olditemnumber}";
                    $csr = $args{dbh}->prepare($sqlcode);
                    $csr -> bind_param (":description", $settings{items}[$i]{description}, {ora_type => ORA_CLOB, ora_field => 'description'});
                    $csr->execute;
                }
            }
        }
        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }
    
    return($output);
}


###################################################################################################################################
sub doProcessAddVendor {  # routine to process add a vendor to bid (purchase document)
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $vendor = $settings{v_vendorid};
    my $prnumber = $settings{prnumber};

    eval {
        my $sqlcode = "INSERT INTO $args{schema}.vendor_list (prnumber, vendor) VALUES ('$prnumber', $vendor)";
        $args{dbh}->do($sqlcode);
        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }
    
    return($output);
}


###################################################################################################################################
sub doProcessSaveBidRemarks {  # routine to process save remarks to the bids form
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";

    eval {
        my $sqlcode = "UPDATE $args{schema}.purchase_documents SET bidremarks=";
        $sqlcode .= ((defined($settings{bidremarks})) ? ":bidremarks" : "NULL") . " WHERE prnumber='$settings{prnumber}'";
        my $csr = $args{dbh}->prepare($sqlcode);
#print STDERR "\n$sqlcode\n";
        if (defined($settings{bidremarks})) {
            $csr -> bind_param (":bidremarks", $settings{bidremarks}, {ora_type => ORA_CLOB, ora_field => 'bidremarks'});
        }
        $csr->execute;
        $csr->finish;
        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }
    
    return($output);
}


###################################################################################################################################
sub doProcessBidAward {  # routine to process Bid Award
###################################################################################################################################
    my %args = (
        pd => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";

    eval {
        my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$args{pd});
        my %bid = &getBidInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$settings{bidselect}, pd=>$args{pd});
        my $ponumber = ((defined($pd{ponumber}) && $pd{ponumber} gt " ") ? $pd{ponumber} : &getNextPOSeq(dbh=>$args{dbh}, schema=>$args{schema}, dept => $pd{deptid}));
# update purchase_documents
        my $sqlcode = "UPDATE $args{schema}.purchase_documents SET ponumber='$ponumber', vendor=$bid{vendor}, status=11, bidremarks=";
        $sqlcode .= ((defined($settings{bidremarks})) ? ":bidremarks" : "NULL") . ", ";
        $sqlcode .= "paymentterms='$bid{terms}', duedate=TO_DATE('$bid{duedate}', 'MM/DD/YYYY'), fob=$bid{fob}, shipvia=" . $args{dbh}->quote($bid{shipvia}) . ", shipping=$bid{shipping}";
        $sqlcode .= " WHERE prnumber='$args{pd}'";
        my $csr = $args{dbh}->prepare($sqlcode);
#print STDERR "\n$sqlcode\n\n";
        if (defined($settings{bidremarks})) {
            $csr -> bind_param (":bidremarks", $settings{bidremarks}, {ora_type => ORA_CLOB, ora_field => 'bidremarks'});
        }
        $csr->execute;
        $csr->finish;

# init po_chargenumbers
        if (!defined($pd{amendment}) || $pd{amendment} eq "") {
            $sqlcode = "INSERT INTO $args{schema}.po_chargenumbers (prnumber, chargenumber, ec, amount) (SELECT UNIQUE '$args{pd}', '$pd{chargenumber}',";
            $sqlcode .= "ec, 0.0 FROM $args{schema}.items WHERE prnumber='$args{pd}')";
            $args{dbh}->do($sqlcode);
        }
# update PD items
        for (my $i=0; $i<$bid{itemCount}; $i++) {
            $sqlcode = "UPDATE $args{schema}.items SET unitofissue='$bid{items}[$i]{unitofissue}', ";
            $sqlcode .= "quantity=$bid{items}[$i]{quantity}, unitprice=$bid{items}[$i]{unitprice} ";
            $sqlcode .= "WHERE prnumber='$args{pd}' AND itemnumber=$bid{items}[$i]{itemnumber}";
            $args{dbh}->do($sqlcode);
        }

# vendor update
        $sqlcode = "UPDATE $args{schema}.vendors SET lastpo='$ponumber', lastused=SYSDATE, status=2 WHERE id=$bid{vendor}";
        $args{dbh}->do($sqlcode);
        
        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }
    
    return($output);
}


###################################################################################################################################
sub doProcessBidAwardItemUpdate {  # routine to process Bid Award
###################################################################################################################################
    my %args = (
        pd => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $sqlcode;

    eval {
        my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$args{pd});
        my %bid = &getBidInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$settings{bidselect}, pd=>$args{pd});
# update PD items
        for (my $i=0; $i<$bid{itemCount}; $i++) {
            my ($itemTest) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.items " .
                  "WHERE prnumber='$args{pd}' AND itemnumber=$bid{items}[$i]{itemnumber}");
            if ($itemTest != 0) {
                $sqlcode = "UPDATE $args{schema}.items SET unitofissue='$bid{items}[$i]{unitofissue}', ";
                $sqlcode .= "description=:description, partnumber=";
                $sqlcode .= ((defined($bid{items}[$i]{partnumber}) && $bid{items}[$i]{partnumber} gt " ") ? "'$bid{items}[$i]{partnumber}'" : "NULL") . ", ";
                $sqlcode .= "quantity=$bid{items}[$i]{quantity}, unitprice=$bid{items}[$i]{unitprice} ";
                $sqlcode .= "WHERE prnumber='$args{pd}' AND itemnumber=$bid{items}[$i]{itemnumber}";
            } else {
                $sqlcode = "INSERT INTO $args{schema}.items (prnumber, itemnumber, description, partnumber, quantity, ";
                $sqlcode .= "unitofissue, unitprice, substituteok, ishazmat, type, ec) VALUES ('$args{pd}',$bid{items}[$i]{itemnumber},";
                $sqlcode .= ":description, " . (($bid{items}[$i]{partnumber} gt " ") ? "'$bid{items}[$i]{partnumber}'" : "NULL") . ", ";
                $sqlcode .= "$bid{items}[$i]{quantity}, '$bid{items}[$i]{unitofissue}', $bid{items}[$i]{unitprice}, ";
                $sqlcode .= "'T', 'F', 1, '47')";
            }
            my $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":description", $bid{items}[$i]{description}, {ora_type => ORA_CLOB, ora_field => 'description'});
            $csr->execute;
            $csr->finish;
        }

# vendor update
        $sqlcode = "UPDATE $args{schema}.vendors SET lastpo='$pd{ponumber}', lastused=SYSDATE, status=2 WHERE id=$bid{vendor}";
        $args{dbh}->do($sqlcode);
        
        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }
    
    return($output);
}


###################################################################################################################################
sub doProcessBidDelete {  # routine to delete bid data
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $csr;

    eval {
        my $sqlcode = "DELETE FROM $args{schema}.bid_items WHERE bidid=$args{id}";
        $args{dbh}->do($sqlcode);
        $sqlcode = "DELETE FROM $args{schema}.bids WHERE id=$args{id}";
        $args{dbh}->do($sqlcode);
        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }
    
    return($output);
}


###################################################################################################################################
###################################################################################################################################


1; #return true
