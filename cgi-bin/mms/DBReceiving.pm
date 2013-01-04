# DB Receiving functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBReceiving.pm,v $
#
# $Revision: 1.7 $
#
# $Date: 2009/05/29 21:35:51 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBReceiving.pm,v $
# Revision 1.7  2009/05/29 21:35:51  atchleyb
# ACR0905_001 - user change request, multiple changes
#
# Revision 1.6  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.5  2006/05/17 22:52:46  atchleyb
# CR 0026 - added function getDeliveredtoLIst
#
# Revision 1.4  2004/04/01 23:40:11  atchleyb
# minor display updates
# update to handle receiving delivery orders
#
# Revision 1.3  2004/02/27 00:10:04  atchleyb
# added code to improve lookup time
#
# Revision 1.2  2003/12/16 21:43:01  atchleyb
# fixed typo in bind statement
#
# Revision 1.1  2003/12/15 18:52:27  atchleyb
# Initial revision
#
#
#
#
#
#
#

package DBReceiving;
#
# get all required libraries and modules
use strict;
use DBPurchaseDocuments qw(getPDInfo);
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
        &getReceiving            &getReceivingInfo           &genNewReceiving
        &doProcessReceivingSave  &getDeliveredtoList
    );
%EXPORT_TAGS =( 
    Functions => [qw(
        &getReceiving            &getReceivingInfo           &genNewReceiving
        &doProcessReceivingSave  &getDeliveredtoList
    )]
);


my %displayControl = (loaded => 'F');


###################################################################################################################################
sub getReceiving {  # routine to get all open receiving
###################################################################################################################################
    my %args = (
        id => 0,
        pd => 0,
        isOpen => 'F',
        orderBy => '',
        siteList => ['xx'],
        fy => 0,
        firstItemOnly => 'F',
        deliveredto => 'all',
        pdStatusList => '0',
        @_,
    );
    $args{dbh}->{LongReadLen} = 1000000;
    $args{dbh}->{LongTruncOk} = 0;
    my $where = "";
    $where .= (($args{isOpen} eq 'T') ? " AND datedelivered IS NULL" : "");
    $where .= (($args{id} ne 0) ? " AND id='$args{id}'" : "");
    $where .= (($args{pd} ne 0) ? " AND prnumber='$args{pd}'" : "");
    $where .= (($args{fy} ne 0) ? " AND datereceived>=TO_DATE('10/01/" . ($args{fy} - 1) ."', 'MM/DD/YYYY') AND datereceived<TO_DATE('10/01/" . ($args{fy}) ."', 'MM/DD/YYYY')" : "");
    $where .= ((defined($args{deliveredto}) && $args{deliveredto} gt '  ' && $args{deliveredto} ne 'all') ? " AND deliveredto=" . $args{dbh}->quote($args{deliveredto}) : "");
    $where .= (($args{pdStatusList} ne '0') ? " AND prnumber IN (SELECT prnumber FROM $args{schema}.purchase_documents WHERE status IN ($args{pdStatusList}))" : "");
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
    my @rLog;
    my $sqlcode = "SELECT id,prnumber, TO_CHAR(datereceived,'MM/DD/YYYY'), deliveredto, TO_CHAR(datedelivered,'MM/DD/YYYY'), ";
    $sqlcode .= "shipmentnumber, shipvia, receivedby, vendor, comments ";
    $sqlcode .= "FROM $args{schema}.receiving_log ";
    $sqlcode .= "WHERE 1=1 $where ORDER BY $orderBy id";
#print STDERR "\n$sqlcode\n\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    my $i = 0;
    while (($rLog[$i]{id},$rLog[$i]{prnumber},$rLog[$i]{datereceived},$rLog[$i]{deliveredto},$rLog[$i]{datedelivered},
            $rLog[$i]{shipmentnumber},$rLog[$i]{shipvia},$rLog[$i]{receivedby},$rLog[$i]{vendor},$rLog[$i]{comments}) = $csr->fetchrow_array) {
        if (defined($rLog[$i]{prnumber}) && substr($rLog[$i]{prnumber},2,4) ne 'NOPR') {
            ($rLog[$i]{ponumber}, $rLog[$i]{amendment}) = $args{dbh}->selectrow_array("SELECT ponumber, amendment FROM $args{schema}.purchase_documents WHERE prnumber='$rLog[$i]{prnumber}'");
        } else {
            $rLog[$i]{ponumber} = "No PO";
        }
        $sqlcode = "SELECT logid,itemnumber,quantityreceived,qualitycode,description FROM $args{schema}.receiving_items ";
        $sqlcode .= "WHERE logid='$rLog[$i]{id}' ORDER BY itemnumber";
        my $csr2 = $args{dbh}->prepare($sqlcode);
        $csr2->execute;
        my $j = 0;
        while (($rLog[$i]{items}[$j]{logid},$rLog[$i]{items}[$j]{itemnumber},$rLog[$i]{items}[$j]{quantityreceived},
                  $rLog[$i]{items}[$j]{qualitycode},$rLog[$i]{items}[$j]{description}) = $csr2->fetchrow_array) {
            if ($args{firstItemOnly} eq 'T') {last;}
            $j++;
        }
        $csr2->finish;
        $rLog[$i]{itemCount} = $j;
        $rLog[$i]{status} = 'old';
        $i++;
    }
    $csr->finish;
    

    return (@rLog);
}


###################################################################################################################################
sub getDeliveredtoList {  # routine to get list of people that received items
###################################################################################################################################
    my %args = (
        siteList => ['xx'],
        fy => 0,
        @_,
    );
    my @dList;
    my $where = "";

    $where .= (($args{fy} ne 0) ? " AND datereceived>=TO_DATE('10/01/" . ($args{fy} - 1) ."', 'MM/DD/YYYY') AND datereceived<TO_DATE('10/01/" . ($args{fy}) ."', 'MM/DD/YYYY')" : "");
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
    
    my$sqlcode ="SELECT UNIQUE deliveredto FROM $args{schema}.receiving_log WHERE 1=1 $where ORDER BY deliveredto";
#print STDERR "\n$sqlcode\n\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    my $i = 0;
    while (($dList[$i]) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;

    return (@dList);
}


###################################################################################################################################
sub getReceivingInfo {  # routine to get receiving info
###################################################################################################################################
    my %args = (
        pd => 0,
        id => 0,
        @_,
    );

    my @rLog = &getReceiving(dbh => $args{dbh}, schema => $args{schema}, pd=>$args{pd}, id=>$args{id});
    my $hashRef = $rLog[0];
    my %rLog = %$hashRef;
    

    return (%rLog);
}



###################################################################################################################################
sub genNewReceiving {  # routine to gen a new blank receiving
###################################################################################################################################
    my %args = (
        pd => '',
        userID => 0,
        site => 0,
        @_,
    );

    my $deptid = 0;
    my $site = $args{site};
    if ($args{pd} gt ' ') {
        my %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{pd});
        $deptid = $pd{deptid};
    } else {
    }
    my ($date) = $args{dbh}->selectrow_array("SELECT TO_CHAR(SYSDATE, 'MM/DD/YYYY') FROM dual");
    my $rLogID = &getNextRLogSeq(dbh => $args{dbh}, schema => $args{schema}, dept=>$deptid, site=>$site);
    my %rLog = (
        id => $rLogID,
        prnumber => $args{pd},
        datereceived => $date,
        deliveredto => '',
        datedelivered => '',
        shipmentnumber => '',
        vendor => '',
        receivedby => $args{userID},
        comments => "",
        shipvia => "",
        items => [],
        itemCount => 0,
        status => 'new',
    );

    return (%rLog);
}


###################################################################################################################################
sub doProcessReceivingSave {  # routine to process receiving data
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
        if ($settings{rlogstatus} eq 'new') {
            $sqlcode = "INSERT INTO $args{schema}.receiving_log (id,prnumber,datereceived,deliveredto,datedelivered,shipmentnumber,";
            $sqlcode .= "shipvia,vendor,comments) VALUES ('$args{id}',";
            $sqlcode .= ((defined($settings{prnumber}) && $settings{prnumber} gt ' ') ? "'$settings{prnumber}'" : "NULL") . ",";
            $sqlcode .= "TO_DATE('$settings{datereceived}', 'MM/DD/YYYY'),";
            $sqlcode .= ((defined($settings{deliveredto}) && $settings{deliveredto} gt ' ') ? $args{dbh}->quote($settings{deliveredto}) : "NULL") . ",";
            $sqlcode .= ((defined($settings{datedelivered}) && $settings{datedelivered} gt ' ') ? "TO_DATE('$settings{datedelivered}','MM/DD/YYYY')" : "NULL") . ",";
            $sqlcode .= ((defined($settings{shipmentnumber})) ? $args{dbh}->quote($settings{shipmentnumber}) : "NULL") . ",";
            $sqlcode .= ((defined($settings{shipvia})) ? $args{dbh}->quote($settings{shipvia}) : "NULL") . ",";
            $sqlcode .= ((defined($settings{vendor})) ? $args{dbh}->quote($settings{vendor}) : "NULL") . ",";
            $sqlcode .= ((defined($settings{comments})) ? ":comments" : "NULL") . ")";
            $csr = $args{dbh}->prepare($sqlcode);
            if (defined($settings{comments})) {
                $csr->bind_param (":comments", $settings{comments}, {ora_type => ORA_CLOB, ora_field => 'comments'});
            }
            $csr->execute;
            $csr->finish;
        } else {
            $sqlcode = "UPDATE $args{schema}.receiving_log SET datereceived=TO_DATE('$settings{datereceived}', 'MM/DD/YYYY'),";
            $sqlcode .= "deliveredto=" . ((defined($settings{deliveredto}) && $settings{deliveredto} gt ' ') ? $args{dbh}->quote($settings{deliveredto}) : "NULL") . ",";
            $sqlcode .= "datedelivered=" . ((defined($settings{datedelivered}) && $settings{datedelivered} gt ' ') ? "TO_DATE('$settings{datedelivered}','MM/DD/YYYY')" : "NULL") . ",";
            $sqlcode .= "shipmentnumber=" . ((defined($settings{shipmentnumber})) ? $args{dbh}->quote($settings{shipmentnumber}) : "NULL") . ",";
            $sqlcode .= "shipvia=" . ((defined($settings{shipvia})) ? $args{dbh}->quote($settings{shipvia}) : "NULL") . ",";
            $sqlcode .= "vendor=" . ((defined($settings{vendor})) ? $args{dbh}->quote($settings{vendor}) : "NULL") . ",";
            $sqlcode .= "comments=" . ((defined($settings{comments}) && $settings{comments} gt ' ') ? ":comments" : "NULL");
            $sqlcode .= " WHERE id='$args{id}'";
            $csr = $args{dbh}->prepare($sqlcode);
            if (defined($settings{comments}) && $settings{comments} gt ' ') {
                $csr->bind_param (":comments", $settings{comments}, {ora_type => ORA_CLOB, ora_field => 'comments'});
            }
            $csr->execute;
            $csr->finish;
        }
        
# items
        $sqlcode = "DELETE FROM $args{schema}.receiving_items WHERE logid='$args{id}'";
        $args{dbh}->do($sqlcode);
        for (my $i=0; $i<=$settings{itemcount}; $i++) {
            if (defined($settings{items}[$i]{quantityreceived}) && $settings{items}[$i]{quantityreceived} != 0) {
                $sqlcode = "INSERT INTO $args{schema}.receiving_items (logid,itemnumber,quantityreceived,qualitycode,description) VALUES (";
                $sqlcode .= "'$args{id}',$settings{items}[$i]{itemnumber},$settings{items}[$i]{quantityreceived},'$settings{items}[$i]{qualitycode}',";
                $sqlcode .= ((defined($settings{items}[$i]{description})) ? ":description" : "NULL") . ")";
                $csr = $args{dbh}->prepare($sqlcode);
                if (defined($settings{items}[$i]{description})) {
                    $csr->bind_param (":description", $settings{items}[$i]{description}, {ora_type => ORA_CLOB, ora_field => 'description'});
                }
                $csr->execute;
                $csr->finish;
            }
        }
        
# update total received
        if (defined($settings{prnumber}) && $settings{prnumber} gt ' ') {
            my @rLogs = &getReceiving(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$settings{prnumber});
            $sqlcode = "UPDATE $args{schema}.items SET quantityreceived=0 WHERE prnumber='$settings{prnumber}'";
            $args{dbh}->do($sqlcode);
            my @itemTotals;
            my $allClosed = 'T';
            for (my $i=0; $i<$#rLogs; $i++) {
                for (my $j=0; $j<$rLogs[$i]{itemCount}; $j++) {
                    $itemTotals[$rLogs[$i]{items}[$j]{itemnumber}] = 
                        ((!defined($itemTotals[$rLogs[$i]{items}[$j]{itemnumber}])) ? $rLogs[$i]{items}[$j]{quantityreceived} : 
                             $itemTotals[$rLogs[$i]{items}[$j]{itemnumber}] + $rLogs[$i]{items}[$j]{quantityreceived});
                }
                if (!defined($rLogs[$i]{datedelivered}) || $rLogs[$i]{datedelivered} le ' ') {
                    $allClosed = 'F';
                }
            }
            for (my $i=0; $i<=$#itemTotals; $i++) {
                if (defined($itemTotals[$i])) {
                    $sqlcode = "UPDATE $args{schema}.items SET quantityreceived=$itemTotals[$i] WHERE prnumber='$settings{prnumber}' AND itemnumber=$i";
                    $args{dbh}->do($sqlcode);
                }
            }
            my $allReceived = 'T';
            my %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$settings{prnumber});
            for (my $i=0; $i<$pd{itemCount}; $i++) {
                if ($pd{items}[$i]{quantityreceived} != $pd{items}[$i]{quantity}) {
                    $allReceived = 'F';
                }
            }
            if ($allReceived eq 'T' && $allClosed eq 'T' && $pd{status} == 17) {
                my $newStatus = (($pd{contracttype} == 2) ? 19 : 18);
                $args{dbh}->do("UPDATE $args{schema}.purchase_documents SET status=$newStatus WHERE prnumber='$settings{prnumber}'");
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
sub getNextRLogSeq {  # routine to get the next available receiving log number
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
    my $seqName = $sitecode . "_RLOGSEQ_" . $fy;
    my $seqNumber = '';
    my $sqlcode = "SELECT $args{schema}.$seqName.NEXTVAL FROM dual";
    eval {
        ($seqNumber) = $args{dbh}->selectrow_array($sqlcode);
    };
    if ($@) {
        eval {
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
    $rLogID = $sitecode . $fy . lpadzero($seqNumber, 4);
    $rLogID =~ s/ //g;

    return ($rLogID);
}




###################################################################################################################################
###################################################################################################################################


1; #return true
