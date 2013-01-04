# DB Accounts Payable functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBAccountsPayable.pm,v $
#
# $Revision: 1.7 $
#
# $Date: 2009/08/14 15:08:21 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBAccountsPayable.pm,v $
# Revision 1.7  2009/08/14 15:08:21  atchleyb
# ACR0908_003 - Report chargenumber selection fix, missing quotes around chargenumber on accounts payable form
#
# Revision 1.6  2006/05/17 22:43:45  atchleyb
# CR0026 - replaced doebilled with clientbilled
#
# Revision 1.5  2005/03/30 23:37:04  atchleyb
# updated to not save zero value invoice items to the DB
#
# Revision 1.4  2004/12/07 17:20:59  atchleyb
# updated totals calculation
#
# Revision 1.3  2004/04/01 23:49:06  atchleyb
# added amendment to retreive
#
# Revision 1.2  2004/03/01 17:27:39  atchleyb
# Updated to improve lookup spped and add selection options
#
# Revision 1.1  2004/01/08 17:32:21  atchleyb
# Initial revision
#
#
#
#
#
#
#

package DBAccountsPayable;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use DBPurchaseDocuments qw(getPDInfo);
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
        &getAP            &getAPInfo               &getAPTotals              &genNewAP
        &doProcessAPSave  &doProcessAPApproveSave  &doProcessAPfinalizeSave  &doProcessPOClose
    );
%EXPORT_TAGS =( 
    Functions => [qw(
        &getAP            &getAPInfo               &getAPTotals              &genNewAP
        &doProcessAPSave  &doProcessAPApproveSave  &doProcessAPfinalizeSave  &doProcessPOClose
    )]
);


my %displayControl = (loaded => 'F');


###################################################################################################################################
sub getAP {  # routine to get all open accounts payable
###################################################################################################################################
    my %args = (
        id => 0,
        pd => 0,
        userID => 0,
        isOpen => 'F',
        isInitial => 'F',
        statusList => '0',
        siteList => ['xx'],
        orderBy => 'pd.ponumber',
        fy => 0,
        noItems => 'F',
        getVendor => 'F',
        chargeNumber => '0',
        @_,
    );
    $args{dbh}->{LongReadLen} = 1000000;
    $args{dbh}->{LongTruncOk} = 0;
    my $where = "";
    $where .= (($args{userID} > 0) ? " AND i.enteredby=$args{userID}" : "");
    $where .= (($args{isInitial} eq 'T') ? " AND i.status=1" : "");
    $where .= (($args{isOpen} eq 'T') ? " AND i.status<4" : "");
    $where .= (($args{statusList} gt '0') ? " AND i.status IN ($args{statusList})" : "");
    $where .= (($args{id} ne 0) ? " AND i.id='$args{id}'" : "");
    $where .= (($args{pd} ne 0) ? " AND i.prnumber='$args{pd}'" : "");
    $where .= (($args{fy} ne 0) ? " AND i.datereceived>=TO_DATE('10/01/" . ($args{fy} - 1) ."', 'MM/DD/YYYY') AND i.datereceived<TO_DATE('10/01/" . ($args{fy}) ."', 'MM/DD/YYYY')" : "");
    if ($args{siteList}[0] ne 'xx') {
        my $arrayRef = $args{siteList};
        my @siteList = @$arrayRef;
        $where .= " AND (";
        for (my $i=0; $i<=$#siteList; $i++) {
            $where .= " (id LIKE '$siteList[$i]\%') OR";
        }
        $where =~ s/ OR$//;
        $where .= ")";
    }
    my $orderBy = (($args{orderBy} gt ' ') ? "$args{orderBy}," : "");
    my @ap;
    my $sqlcode = "SELECT i.id,i.prnumber, i.invoicenumber, TO_CHAR(i.datereceived,'MM/DD/YYYY'), TO_CHAR(i.invoicedate,'MM/DD/YYYY'), ";
    $sqlcode .= "i.taxpaid, TO_CHAR(i.datepaid,'MM/DD/YYYY'), TO_CHAR(i.doebilled,'MM/DD/YYYY'), i.comments, i.status, i.enteredby, ";
    $sqlcode .= "i.approvedby, TO_CHAR(i.dateapproved,'MM/DD/YYYY'),pd.vendor ";
    $sqlcode .= "FROM $args{schema}.invoices i, $args{schema}.purchase_documents pd ";
    $sqlcode .= "WHERE i.prnumber=pd.prnumber AND 1=1 $where ORDER BY $orderBy i.id";
#print STDERR "\n$sqlcode\n\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    my $i = 0;
    while (($ap[$i]{id},$ap[$i]{prnumber},$ap[$i]{invoicenumber},$ap[$i]{datereceived},$ap[$i]{invoicedate},
            $ap[$i]{taxpaid},$ap[$i]{datepaid},$ap[$i]{clientbilled},$ap[$i]{comments},$ap[$i]{status},
            $ap[$i]{enteredby},$ap[$i]{approvedby},$ap[$i]{dateapproved},$ap[$i]{vendor}) = $csr->fetchrow_array) {
        ($ap[$i]{ponumber},$ap[$i]{amendment}, $ap[$i]{vendor}) = $args{dbh}->selectrow_array("SELECT pd.ponumber,pd.amendment,v.name "
              . "FROM $args{schema}.purchase_documents pd,$args{schema}.vendors v WHERE v.id=pd.vendor AND pd.prnumber='$ap[$i]{prnumber}'");
        $ap[$i]{vendorName} = $ap[$i]{vendor};
        $ap[$i]{totalAmount} = 0.0;
        $ap[$i]{totalTax} = 0.0;
        if ($args{noItems} ne 'T') {
            $sqlcode = "SELECT invoiceid, chargenumber, ec, tax, amount FROM $args{schema}.invoice_detail ";
            $sqlcode .= "WHERE invoiceid='$ap[$i]{id}' ORDER BY chargenumber, ec";
            my $csr2 = $args{dbh}->prepare($sqlcode);
            $csr2->execute;
            my $j = 0;
            while (($ap[$i]{items}[$j]{invoiceid},$ap[$i]{items}[$j]{chargenumber},$ap[$i]{items}[$j]{ec},
                      $ap[$i]{items}[$j]{tax},$ap[$i]{items}[$j]{amount}) = $csr2->fetchrow_array) {
                if ($args{chargeNumber} eq '0' || $args{chargeNumber} eq $ap[$i]{items}[$j]{chargenumber}) {
                    my $key = "$ap[$i]{items}[$j]{chargenumber}-$ap[$i]{items}[$j]{ec}";
                    $ap[$i]{$key}{tax} += $ap[$i]{items}[$j]{tax};
                    $ap[$i]{$key}{amount} += $ap[$i]{items}[$j]{amount};
                    $ap[$i]{totalAmount} += $ap[$i]{items}[$j]{amount};
                    $ap[$i]{totalTax} += $ap[$i]{items}[$j]{tax};
                    $j++;
                }
            }
            $csr2->finish;
            $ap[$i]{itemCount} = $j;
            $ap[$i]{entrystatus} = 'old';
        }
        $i++;
    }
    $csr->finish;
    
    

    return (@ap);
}


###################################################################################################################################
sub getAPInfo {  # routine to get AP info
###################################################################################################################################
    my %args = (
        pd => 0,
        id => 0,
        @_,
    );

    my @ap = &getAP(dbh => $args{dbh}, schema => $args{schema}, pd=>$args{pd}, id=>$args{id});
    my $hashRef = $ap[0];
    my %ap = %$hashRef;
    

    return (%ap);
}


###################################################################################################################################
sub getAPTotals {  # routine to get AP totals
###################################################################################################################################
    my %args = (
        pd => '',
        id => '',
        status => 0,
        @_,
    );
    
    my $sqlcode = "SELECT SUM(d.tax), SUM(d.amount) FROM $args{schema}.invoice_detail d, $args{schema}.invoices i WHERE i.id=d.invoiceid";
    $sqlcode .= (($args{pd} gt ' ') ? " AND i.prnumber='$args{pd}'" : "");
    $sqlcode .= (($args{id} gt ' ') ? " AND i.id='$args{id}'" : "");
    $sqlcode .= (($args{status} > 0) ? " AND i.status=$args{status}" : "");

    my ($tax, $amount) = $args{dbh}->selectrow_array($sqlcode);
    
    $sqlcode = "SELECT count(*) FROM $args{schema}.invoices WHERE status<4";
    $sqlcode .= (($args{pd} gt ' ') ? " AND prnumber='$args{pd}'" : "");
    $sqlcode .= (($args{id} gt ' ') ? " AND id='$args{id}'" : "");
    
    my ($notClosed) = $args{dbh}->selectrow_array($sqlcode);
    my $allClosed = (($notClosed == 0) ? 'T' : 'F');

    return ($tax, $amount, $allClosed);
}



###################################################################################################################################
sub genNewAP {  # routine to gen a new blank AP
###################################################################################################################################
    my %args = (
        pd => '',
        userID => 0,
        @_,
    );

    my ($date) = $args{dbh}->selectrow_array("SELECT TO_CHAR(SYSDATE, 'MM/DD/YYYY') FROM dual");
    my %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{pd});
    my $APID = &getNextAPSeq(dbh => $args{dbh}, schema => $args{schema}, dept=>$pd{deptid});
    my %ap = (
        id => $APID,
        prnumber => $args{pd},
        invoicenumber => '',
        datereceived => $date,
        invoicedate => $date,
        taxpaid => 'F',
        datepaid => '',
        clientbilled => '',
        comment => '',
        status => 1,
        enteredby => $args{userID},
        approvedby => '',
        dateapproved => '',
        items => [],
        itemCount => 0,
        entrystatus => 'new',
    );
    if ($pd{taxexempt} eq 'T') {
        $ap{taxpaid} = 'NA';
    } elsif ($pd{tax} > 0) {
        $ap{taxpaid} = 'T';
    }

    return (%ap);
}


###################################################################################################################################
sub doProcessAPSave {  # routine to process AP data
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $sqlcode;
    my $csr;

#print STDERR "\nPRNumber: $settings{prnumber}, Entry Status: $settings{entrystatus}\n";
    eval {
        if ($settings{entrystatus} eq 'new') {
            $sqlcode = "INSERT INTO $args{schema}.invoices (id,prnumber,invoicenumber,datereceived,invoicedate,taxpaid, datepaid, doebilled,";
            $sqlcode .= "comments,status,enteredby,approvedby,dateapproved) VALUES ('$args{id}',";
            $sqlcode .= "'$settings{prnumber}','$settings{invoicenumber}',";
            $sqlcode .= "TO_DATE('$settings{datereceived}', 'MM/DD/YYYY'),";
            $sqlcode .= "TO_DATE('$settings{invoicedate}', 'MM/DD/YYYY'),";
            $sqlcode .= "'$settings{taxpaid}',";
            $sqlcode .= "NULL, NULL, " . ((defined($settings{comments}) && $settings{comments} gt ' ') ? ":comments" : "NULL") . ",";
            $sqlcode .= "$settings{status}, $args{userID}, NULL, NULL)";
#print STDERR "\n$sqlcode\n\n";
            $csr = $args{dbh}->prepare($sqlcode);
            if (defined($settings{comments}) && $settings{comments} gt ' ') {
                $csr->bind_param (":comments", $settings{comments}, {ora_type => ORA_CLOB, ora_field => 'comments'});
            }
            $csr->execute;
            $csr->finish;
        } else {
            $sqlcode = "UPDATE $args{schema}.invoices SET invoicenumber='$settings{invoicenumber}',";
            $sqlcode .= "datereceived=TO_DATE('$settings{datereceived}', 'MM/DD/YYYY'),";
            $sqlcode .= "invoicedate=TO_DATE('$settings{invoicedate}', 'MM/DD/YYYY'),";
            $sqlcode .= "taxpaid='$settings{taxpaid}',";
            $sqlcode .= "status=$settings{status},";
            $sqlcode .= "comments=" . ((defined($settings{comments}) && $settings{comments} gt ' ') ? ":comments" : "NULL") . " ";
            $sqlcode .= "WHERE id='$args{id}'";
#print STDERR "\n$sqlcode\n\n";
            $csr = $args{dbh}->prepare($sqlcode);
            if (defined($settings{comments}) && $settings{comments} gt ' ') {
                $csr->bind_param (":comments", $settings{comments}, {ora_type => ORA_CLOB, ora_field => 'comments'});
            }
            $csr->execute;
            $csr->finish;
        }
        
# items
        $sqlcode = "DELETE FROM $args{schema}.invoice_detail WHERE invoiceid='$args{id}'";
        $args{dbh}->do($sqlcode);
        for (my $i=1; $i<=$settings{itemcount}; $i++) {
            if (defined($settings{items}[$i]{chargenumber}) && $settings{items}[$i]{chargenumber} gt ' ' && 
                    ($settings{items}[$i]{tax} != 0 || $settings{items}[$i]{amount} != 0)) {
                $sqlcode = "INSERT INTO $args{schema}.invoice_detail (invoiceid, chargenumber, ec, tax, amount) VALUES (";
                $sqlcode .= "'$args{id}','$settings{items}[$i]{chargenumber}',$settings{items}[$i]{ec},$settings{items}[$i]{tax}, ";
                $sqlcode .= "$settings{items}[$i]{amount})";
#print STDERR "\n$sqlcode\n\n";
                $args{dbh}->do($sqlcode);
                my ($total) = $args{dbh}->selectrow_array("SELECT SUM(d.tax) + SUM(d.amount) FROM $args{schema}.invoice_detail d," .
                                  "$args{schema}.invoices i WHERE d.invoiceid=i.id AND " .
                                  "i.prnumber='$settings{prnumber}' AND d.chargenumber='$settings{items}[$i]{chargenumber}' " .
                                  "AND d.ec=$settings{items}[$i]{ec}");
                $sqlcode = "UPDATE $args{schema}.po_chargenumbers SET invoiced = $total WHERE prnumber='$settings{prnumber}' " .
                               "AND chargenumber='$settings{items}[$i]{chargenumber}' AND ec=$settings{items}[$i]{ec}";
                $args{dbh}->do($sqlcode);
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
sub doProcessAPApproveSave {  # routine to process AP data
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $sqlcode;
    my $csr;

    eval {
        $sqlcode = "UPDATE $args{schema}.invoices SET status='$settings{status}',";
        if ($settings{status} == 3) {
            $sqlcode .= "approvedby=$args{userID},dateapproved=SYSDATE,";
        }
        $sqlcode .= "comments=" . ((defined($settings{comments}) && $settings{comments} gt ' ') ? ":comments" : "NULL") . " ";
        $sqlcode .= "WHERE id='$args{id}'";
#print STDERR "\n$sqlcode\n\n";
        $csr = $args{dbh}->prepare($sqlcode);
        if (defined($settings{comments}) && $settings{comments} gt ' ') {
            $csr->bind_param (":comments", $settings{comments}, {ora_type => ORA_CLOB, ora_field => 'comments'});
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
sub doProcessAPfinalizeSave {  # routine to process AP data
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $sqlcode;
    my $csr;

    eval {
        $sqlcode = "UPDATE $args{schema}.invoices SET status=$settings{status},";
        $sqlcode .= "datepaid=" . ((defined($settings{datepaid}) &&  $settings{datepaid} gt ' ') ?"TO_DATE('$settings{datepaid}', 'MM/DD/YYYY')" : "NULL") . ",";
        $sqlcode .= "doebilled=" . ((defined($settings{clientbilled}) &&  $settings{clientbilled} gt ' ') ?"TO_DATE('$settings{clientbilled}', 'MM/DD/YYYY')" : "NULL") . ",";
        $sqlcode .= "comments=" . ((defined($settings{comments}) && $settings{comments} gt ' ') ? ":comments" : "NULL") . " ";
        $sqlcode .= "WHERE id='$args{id}'";
#print STDERR "\n$sqlcode\n\n";
        $csr = $args{dbh}->prepare($sqlcode);
        if (defined($settings{comments}) && $settings{comments} gt ' ') {
            $csr->bind_param (":comments", $settings{comments}, {ora_type => ORA_CLOB, ora_field => 'comments'});
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
sub doProcessPOClose {  # routine to close a PO
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $sqlcode;
    my $csr;

    eval {
        $sqlcode = "UPDATE $args{schema}.purchase_documents SET status=19 WHERE prnumber='$args{id}'";
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
sub getNextAPSeq {  # routine to get the next available receiving log number
###################################################################################################################################
    my %args = (
        dept => 0,
        site => 0,
        @_,
    );

    my ($site, $sitecode) = (0, '');
    if ($args{dept} > 0) {
        ($site, $sitecode) = $args{dbh}->selectrow_array("SELECT d.site, si.sitecode FROM $args{schema}.departments d, " .
                         "$args{schema}.site_info si WHERE d.site=si.id AND d.id=$args{dept}");
    } else {
        ($site, $sitecode) = $args{dbh}->selectrow_array("SELECT id,sitecode FROM $args{schema}.site_info si WHERE id=$args{site}");
    }
    my $fy = &getFY();
    my $rLogID = '';
    my $seqName = $sitecode . "_APSEQ_" . $fy;
    my $seqNumber = '';
    my $sqlcode = "SELECT $args{schema}.$seqName.NEXTVAL FROM dual";
    eval {
        ($seqNumber) = $args{dbh}->selectrow_array($sqlcode);
    };
    if ($@) {
        eval {
#print STDERR "\n$seqName\n\n";
            &createSequence(dbh=>$args{dbh}, schema=>$args{schema}, seqName=>$seqName);
            ($seqNumber) = $args{dbh}->selectrow_array($sqlcode);
            $args{dbh}->commit;
        };
        if ($@) {
            my $errMessage = $@;
            $args{dbh}->rollback;
            die $errMessage;
        }
    }
    $rLogID = $sitecode . $fy . "INV" . lpadzero($seqNumber, 4);
    $rLogID =~ s/ //g;

    return ($rLogID);
}




###################################################################################################################################
###################################################################################################################################


1; #return true
