# DB Purchase Documents functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBPurchaseDocuments.pm,v $
#
# $Revision: 1.47 $
#
# $Date: 2009/10/13 21:24:36 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBPurchaseDocuments.pm,v $
# Revision 1.47  2009/10/13 21:24:36  atchleyb
# ACR0910_007 - Add taxable amount column to tax report
#
# Revision 1.46  2009/10/08 21:44:57  atchleyb
# ACR0910_006 - Fix prob with report selection
#
# Revision 1.45  2009/09/04 16:55:30  atchleyb
# ACR0908_007 - Changes to implement new Tax Report
#
# Revision 1.44  2009/08/24 17:52:19  atchleyb
# ACR0908_005 - Fixed so that charge number selection can display future years
#
# Revision 1.43  2009/08/14 15:08:21  atchleyb
# ACR0908_003 - Report chargenumber selection fix, missing quotes around chargenumber on accounts payable form
#
# Revision 1.42  2009/07/31 22:43:26  atchleyb
# Updates related to ACR0907_004-SWR0149   New intermediate buyer role, minor bug fixes
#
# Revision 1.41  2009/06/26 21:57:40  atchleyb
# ACR0906_001 - List of changes
#
# Revision 1.40  2009/05/29 21:35:51  atchleyb
# ACR0905_001 - user change request, multiple changes
#
# Revision 1.39  2008/12/23 00:26:36  atchleyb
# ACR0812_004 - minor fix
#
# Revision 1.38  2008/12/22 22:15:36  atchleyb
# ACR0812_004 - fixed issue with RFP attachments and question validation durring PO processing
#
# Revision 1.37  2008/12/04 22:57:29  atchleyb
# fixed missing quotes
#
# Revision 1.36  2008/12/03 17:05:29  atchleyb
# ACR0811_001 - Added PO Reference number
#
# Revision 1.35  2008/10/21 23:54:19  atchleyb
# Fixed question issue for copying an old PR
#
# Revision 1.34  2008/10/21 18:06:05  atchleyb
# ACR0810_002 - Updated to allow for routing questions
#
# Revision 1.33  2008/08/29 15:50:29  atchleyb
# ACR0808_013 - Fix problems with clauses and PO's, fix problem with shipping costs on bids not transfering to PO
#
# Revision 1.32  2008/04/21 20:45:48  atchleyb
# SCR00039 - Fixed defect in getPDInfo when no PR number is passed in.
#
# Revision 1.31  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.30  2007/10/11 18:54:35  atchleyb
# CREQ00036 - Updated to get list of taxable element codes from the db
#
# Revision 1.29  2007/08/02 16:40:38  atchleyb
# CREQ00032 - Fixed defect on time stamps
#
# Revision 1.28  2007/04/17 19:02:29  atchleyb
# CR00031 - fixed bug with auto approvals
#
# Revision 1.27  2007/04/11 16:49:24  atchleyb
# SCR00031 - changed to generate the archive pdf after the approvals are stored
#
# Revision 1.26  2007/02/07 17:28:29  atchleyb
# CR 0030 - Updated to handle default PO clauses
#
# Revision 1.25  2007/02/06 00:10:19  atchleyb
# CR 00029 - continued
#
# Revision 1.24  2007/01/31 17:53:59  atchleyb
# CR00029 - updated doProcessAcceptPRforRFP to select the correct clause
#
# Revision 1.23  2006/07/27 17:13:24  atchleyb
# CR00027 - Fixed problem where copy pd was not coping the new department id to create pd
#
# Revision 1.22  2006/05/17 22:48:47  atchleyb
# CR0026 - added code to make shipvia and paymentterms updateable and attachments deleteable
#
# Revision 1.21  2006/03/16 16:50:14  atchleyb
# CR 0023 - Updated to allow the removeal/restoration of line items
# CR 0023 - Updated to allow multiple attachments at one time
#
# Revision 1.20  2006/01/31 23:22:37  atchleyb
# CR 0022 - Added getBuyerArray and doRemovePOChargeNumbers functions
#
# Revision 1.19  2006/01/10 15:21:02  atchleyb
# CREQ00021 - fixed option for 'edit pr' from RFP screen
#
# Revision 1.18  2005/08/18 18:24:18  atchleyb
# CR00015 - updated to recalculate invoiced totals everytime PO is saved, added vendor filter for lookup of PD's
#
# Revision 1.17  2005/06/10 22:21:21  atchleyb
# Updates for CR0011
# added functions doclearApprovals and doProcessAssignbuyer
# misc updates
#
# Revision 1.16  2005/02/16 20:15:21  atchleyb
# Updated to fix defect in rejecting an ammended PO (CR00008)
#
# Revision 1.15  2005/02/09 21:23:09  atchleyb
# Updated with changes as outlined in CR0007, changed initial value for cn history changeamount
# and changed the lookupfunciton getCNCommittedList to only give history items with status of 15 or higher
#
# Revision 1.14  2005/02/07 19:59:01  atchleyb
# fixed bug that put the wrong sign on item history price change when a item was added or deleted.
#
# Revision 1.13  2004/12/07 18:31:59  atchleyb
# added new functions
#
# Revision 1.12  2004/05/05 23:13:32  atchleyb
# added function get statuslist
#
# Revision 1.11  2004/04/22 21:39:52  atchleyb
# Updates related to SCR 1 (add field briefdescription)
#
# Revision 1.10  2004/04/16 17:57:33  atchleyb
# updated to add RFP amendment
#
# Revision 1.9  2004/04/05 23:33:19  atchleyb
# added code for dev cycle 11
#
# Revision 1.8  2004/04/02 00:04:03  atchleyb
# updated for po processing
#
# Revision 1.7  2004/03/15 22:04:29  atchleyb
# updated for dev cycle 9, added blanket release info at PR stage
#
# Revision 1.6  2004/02/27 00:19:09  atchleyb
# made updates to improve lookup times
# added function getRequesterArray
#
# Revision 1.5  2004/01/08 17:24:11  atchleyb
# added code for accounts payable
# added new options on lookup functions
#
# Revision 1.4  2003/12/15 18:46:54  atchleyb
# added code for receiving
#
# Revision 1.3  2003/12/02 16:47:48  atchleyb
# added code for bids
#
# Revision 1.2  2003/11/13 17:54:30  atchleyb
# Fixed workflow status problem for submitting an RFP for approval
#
# Revision 1.1  2003/11/12 20:26:55  atchleyb
# Initial revision
#
#
#
#
#

package DBPurchaseDocuments;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use UI_Widgets qw(lpadzero);
use DBReceiving qw (getReceiving);
use DBAccountsPayable qw (getAP);
use DBChargeNumbers qw (getApprovedAmount getCNInfo);
use DBSites qw (getSiteInfo);
use DBBusinessRules qw (getRuleInfo);
use DBQuestions qw(:Functions);
#use UIPurchaseDocumentsPrint qw (doPrintPR);
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
      &doProcessPDEntry     &getPDInfo                &createBlankPD
      &doDisplayControl     &getECArray               &getUnitIssue
      &getNextPRSeq         &getChargeNumberArray     &getPDByStatus
      &getApprovalList      &getPDApprovals           &getPDStatusText
      &doProcessPDApproval  &getMimeType              &getAttachmentInfo
      &doProcessPRCopy      &doProcessAcceptPRforRFP  &doProcessRFPUpdate
      &addPDHistory         &getNextPOSeq             &getRequesterArray
      &getBlanketContracts  &getNextBRSeq             &doProcessAcceptPO
      &doProcessPlacePO     &doProcessAmendPO         &getArchiveList
      &getArchiveInfo       &doUpdatePDStatus         &addArchive
      &addClause            &doProcessAmendRFP        &getStatusList
      &genPDApprovalList    &getCNCommittedList       &doProcessCancelPO
      &doClearApprovals     &doProcessAssignBuyer     &getBuyerArray
      &doProcessPDApprovalPart2
      &doRemovePOChargeNumbers
      &getSiteTaxableEC
      &doProcessSavePDRemark
      &doProcessChangeVendor
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doProcessPDEntry     &getPDInfo                &createBlankPD
      &doDisplayControl     &getECArray               &getUnitIssue
      &getNextPRSeq         &getChargeNumberArray     &getPDByStatus
      &getApprovalList      &getPDApprovals           &getPDStatusText
      &doProcessPDApproval  &getMimeType              &getAttachmentInfo
      &doProcessPRCopy      &doProcessAcceptPRforRFP  &doProcessRFPUpdate
      &addPDHistory         &getNextPOSeq             &getRequesterArray
      &getBlanketContracts  &getNextBRSeq             &doProcessAcceptPO
      &doProcessPlacePO     &doProcessAmendPO         &getArchiveList
      &getArchiveInfo       &doUpdatePDStatus         &addArchive
      &addClause            &doProcessAmendRFP        &getStatusList
      &genPDApprovalList    &getCNCommittedList       &doProcessCancelPO
      &doClearApprovals     &doProcessAssignBuyer     &getBuyerArray
      &doProcessPDApprovalPart2
      &doRemovePOChargeNumbers
      &getSiteTaxableEC
      &doProcessSavePDRemark
      &doProcessChangeVendor
    )]
);


my %displayControl = (loaded => 'F');
my %pdStatus =  (loaded => 'F');


###################################################################################################################################
sub doProcessPDEntry {  # routine to enter a new pd or update a pd
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "",  # new or update
        fileName=>"none",
        fileContents=>"",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $arrayRef = $args{attachmentSet};
    my @fileSet = @$arrayRef;
    my $sqlcode;
    my $status = 0;
    my $resultStatus = 1;
    my $id;
    my $underFunded = "F";
    my $dateFormat = "DD/MM/YYYY-HH24:MI:SS";
    my ($changeDate) = $args{dbh}->selectrow_array ("SELECT TO_CHAR(SYSDATE, '$dateFormat') FROM dual");
    my %blanket = (($settings{blanketrelease} eq '0') ? () : getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$settings{blanketrelease}));
    my $csr;
    my ($displayed, $editable);
    my ($site, $taxExempt) = $args{dbh}->selectrow_array("SELECT d.site, si.taxexempt FROM $args{schema}.departments d, $args{schema}.site_info si " .
          "WHERE d.id=" . ((defined($settings{deptid})) ? $settings{deptid} : 0) . " AND d.site=si.id");
    my %cn = &getCNInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$settings{chargenumber});
    my %cnSite = &getSiteInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$cn{site});
    my $trackFunding = $cnSite{trackfunding};
    eval {
        if ($args{type} eq 'new') {
            $id = &getNextPRSeq(dbh => $args{dbh}, schema => $args{schema}, dept => $settings{deptid});
        } else {
            $id = $settings{prnumber};
            my ($oldDept,$oldTaxExempt) = $args{dbh}->selectrow_array("SELECT deptid, taxexempt FROM $args{schema}.purchase_documents WHERE prnumber='$id'");
            if ($oldDept == $settings{deptid}) {
                $taxExempt = $oldTaxExempt;
            }
        }
##
        if ($args{type} eq 'new') {
            $sqlcode = "INSERT INTO $args{schema}.purchase_documents (prnumber,priority,daterequired,author,requester,briefdescription,justification, ";
            $sqlcode .= "solesource,ssjustification,status,deptid,chargenumber,shipping,taxexempt,tax,potype,relatedpr,contracttype,vendor, pdtotal, refnumber) ";
            $sqlcode .= "VALUES ('$id','$settings{priority}',TO_DATE('$settings{daterequired}', 'MM/DD/YYYY'), $settings{author}, ";
            $sqlcode .= "$settings{requester}, " . $args{dbh}->quote($settings{briefdescription}) . ", :justification, '$settings{solesource}', ";
            $sqlcode .= (($settings{solesource} eq 'T') ? ":ssjustification, " : "NULL, ");
            $sqlcode .= "1, $settings{deptid}, ";
            $sqlcode .= "'" . (($settings{blanketrelease} eq '0') ? "$settings{chargenumber}" : $blanket{chargenumber}) . "', ";
            $sqlcode .= "$settings{shipping}, '$taxExempt', $settings{tax}, ";
            $sqlcode .= "$settings{potype}, " . (($settings{blanketrelease} eq '0') ? "NULL" : "'$settings{blanketrelease}'") . ", ";
            $sqlcode .= (($settings{blanketrelease} eq '0') ? "1" : "2") . ", ";
            $sqlcode .= (($settings{blanketrelease} eq '0') ? "NULL" : $blanket{vendor}) . ",";
            $sqlcode .= "$settings{pdtotal}, " . ((defined($settings{refnumber})) ? "'$settings{refnumber}'" : "NULL") . " )";
            
#print STDERR "\n$sqlcode\n\n";
            my $csr = $args{dbh}->prepare($sqlcode);
            $settings{justification} =~ s/\n\s*\n/\n\n/g;
            $settings{justification} =~ s/\n*\Z//g;
            $csr -> bind_param (":justification", $settings{justification}, {ora_type => ORA_CLOB, ora_field => 'justification'});
            if ($settings{solesource} eq 'T') {
                $settings{ssjustification} =~ s/\n\s*\n/\n\n/g;
                $settings{ssjustification} =~ s/\n*\Z//g;
                $csr -> bind_param (":ssjustification", $settings{ssjustification}, {ora_type => ORA_CLOB, ora_field => 'ssjustification'});
            }
            $status = $csr->execute;
            $csr->finish;

#print STDERR "\nitem count: $settings{itemcount}\n";
# items
            for (my $i=1; $i <= $settings{itemcount}; $i++) {
                if (defined($settings{items}[$i]{description}) && $settings{items}[$i]{description} gt " " 
                        && $settings{items}[$i]{removeFlag} ne 'T') {
                    $sqlcode = "INSERT INTO $args{schema}.items (prnumber, itemnumber, description, partnumber, quantity, ";
                    $sqlcode .= "unitofissue, unitprice, substituteok, techinspection, ishazmat, type, ec) VALUES ('$id', $settings{items}[$i]{itemnumber}, ";
                    $sqlcode .= ":description, " . (($settings{items}[$i]{partnumber} gt " ") ? "'$settings{items}[$i]{partnumber}'" : "NULL") . ", ";
                    $sqlcode .= "$settings{items}[$i]{quantity}, '$settings{items}[$i]{unitofissue}', $settings{items}[$i]{unitprice}, ";
                    $sqlcode .= "'$settings{items}[$i]{substituteok}', '$settings{items}[$i]{techinspection}', '$settings{items}[$i]{ishazmat}', ";
                    $sqlcode .= "$settings{items}[$i]{type}, '$settings{items}[$i]{ec}')";
#print STDERR "\n$sqlcode\n\n";
                    $csr = $args{dbh}->prepare($sqlcode);
                    $csr -> bind_param (":description", $settings{items}[$i]{description}, {ora_type => ORA_CLOB, ora_field => 'description'});
                    $status = $csr->execute;
                    $csr->finish;
                }
            }
            my $vendRef = $settings{vendorList};
            my @vendors = @$vendRef;
#print STDERR "\nNumber of vendors: $#vendors\n";
# vendors
            if ($settings{blanketrelease} eq '0') {
                for (my $i=0; $i<=$#vendors; $i++) {
                    $sqlcode = "INSERT INTO $args{schema}.vendor_list (prnumber, vendor) VALUES ('$id', $vendors[$i])";
                    $status = $args{dbh}->do($sqlcode);
                }
            } else {
                $sqlcode = "INSERT INTO $args{schema}.vendor_list (prnumber, vendor) VALUES ('$id', $blanket{vendor})";
                $status = $args{dbh}->do($sqlcode);
            }
            
### update
        } else {
            $sqlcode = "UPDATE $args{schema}.purchase_documents SET ";
            $sqlcode .= "requester = $settings{requester}, ";
            $sqlcode .= "briefdescription = " . $args{dbh}->quote($settings{briefdescription}) . ", ";
            $sqlcode .= "priority = '$settings{priority}', ";
            $sqlcode .= "daterequired = TO_DATE('$settings{daterequired}', 'MM/DD/YYYY'), ";
            $sqlcode .= "duedate = " . ((defined($settings{duedate}) && $settings{duedate} gt ' ') ? "TO_DATE('$settings{duedate}', 'MM/DD/YYYY')" : "NULL") . ", ";
            $sqlcode .= "deptid = $settings{deptid}, ";
            $sqlcode .= "chargenumber = '" . (($settings{blanketrelease} eq '0') ? "$settings{chargenumber}" : $blanket{chargenumber}) . "', ";
            $sqlcode .= "justification = :justification, ";
            $sqlcode .= "solesource = '$settings{solesource}', ";
            $sqlcode .= "ssjustification = " . (($settings{solesource} eq 'T') ?  ":ssjustification, " : "NULL, ");
            $sqlcode .= "shipping = '$settings{shipping}', ";
            $sqlcode .= "tax = $settings{tax}, ";
            $sqlcode .= "taxexempt = '$taxExempt', ";
            $sqlcode .= "status = $settings{status}, ";
            $sqlcode .= "potype = $settings{potype}, ";
            $sqlcode .= "fob = $settings{fob}, ";
            $sqlcode .= "rfpdeliverdays = " . ((defined($settings{rfpdeliverdays}) &&  $settings{rfpdeliverdays} gt '0') ? "$settings{rfpdeliverdays}" : "NULL") . ", ";
            $sqlcode .= "rfpdaysvalid = " . ((defined($settings{rfpdaysvalid}) &&  $settings{rfpdaysvalid} gt '0') ? "$settings{rfpdaysvalid}" : "NULL") . ", ";
            $sqlcode .= "rfpduedate = " . ((defined($settings{rfpduedate}) &&  $settings{rfpduedate} gt ' ') ? "TO_DATE('$settings{rfpduedate}', 'MM/DD/YYYY')" : "NULL") . ", ";
            $sqlcode .= "relatedpr = " . (($settings{blanketrelease} ne '0') ?  "'$settings{blanketrelease}', " : "NULL, ");
            $sqlcode .= "shipvia = " . ((defined($settings{shipvia}) &&  $settings{shipvia} gt ' ') ? $args{dbh}->quote($settings{shipvia}) : "NULL") . ", ";
            $sqlcode .= "paymentterms = " . ((defined($settings{paymentterms}) &&  $settings{paymentterms} gt ' ') ? $args{dbh}->quote($settings{paymentterms}) : "NULL") . ", ";
            $sqlcode .= "contracttype = " . (($settings{blanketrelease} eq '0') ? "1" : "2") . ", ";
            $sqlcode .= "pdtotal = $settings{pdtotal}, refnumber=" . ((defined($settings{refnumber})) ? "'$settings{refnumber}'" : "NULL") . ",";
            if ($settings{blanketrelease} ne '0') {
                $sqlcode .= "vendor = $blanket{vendor}, ";
            }
            $sqlcode .= "startdate = " . ((defined($settings{startdate}) && $settings{startdate} gt ' ') ? "TO_DATE('$settings{startdate}', 'MM/DD/YYYY')" : "NULL") . ", ";
            $sqlcode .= "enddate = " . ((defined($settings{enddate}) && $settings{enddate} gt ' ') ? "TO_DATE('$settings{enddate}', 'MM/DD/YYYY')" : "NULL") . ", ";
            $sqlcode .= "creditcardholder = " . ((defined($settings{creditcardholder}) && $settings{creditcardholder} > 0) ? $settings{creditcardholder} : "NULL") . ", ";
            $sqlcode .= "selectionmemo = " . ((defined($settings{selectionmemo}) && $settings{selectionmemo} gt ' ') ?  ":selectionmemo " : "NULL ") . ", ";
            $sqlcode .= "enclosures = " . ((defined($settings{enclosures}) && $settings{enclosures} gt ' ') ?  ":enclosures " : "NULL ");
#            $sqlcode .= " = '$settings{}', ";
            $sqlcode .= " WHERE prnumber = '$id'";
#print STDERR "\n$sqlcode\n\n";
            $csr = $args{dbh}->prepare($sqlcode);
            $settings{justification} =~ s/\n\s*\n/\n\n/g;
            $settings{justification} =~ s/\n*\Z//g;
            $csr -> bind_param (":justification", $settings{justification}, {ora_type => ORA_CLOB, ora_field => 'justification'});
            if ($settings{solesource} eq 'T') {
                $settings{ssjustification} =~ s/\n\s*\n/\n\n/g;
                $settings{ssjustification} =~ s/\n*\Z//g;
                $csr -> bind_param (":ssjustification", $settings{ssjustification}, {ora_type => ORA_CLOB, ora_field => 'ssjustification'});
            }
            if (defined($settings{selectionmemo}) && $settings{selectionmemo} gt ' ') {
                $csr -> bind_param (":selectionmemo", $settings{selectionmemo}, {ora_type => ORA_CLOB, ora_field => 'selectionmemo'});
            }
            if (defined($settings{enclosures}) && $settings{enclosures} gt ' ') {
                $csr -> bind_param (":enclosures", $settings{enclosures}, {ora_type => ORA_CLOB, ora_field => 'enclosures'});
            }
            $status = $csr->execute;
            $csr->finish;
            for (my $i=1; $i <= $settings{itemcount}; $i++) {
#print STDERR "\nitem count: $settings{itemcount}, I: $i, olditemnumber: $settings{items}[$i]{olditemnumber}\n";
#print STDERR "$settings{items}[$i]{description}\n";
# Items
                my $testDesrciption = $settings{items}[$i]{description};
                $testDesrciption =~ s/  //g;
                $testDesrciption =~ s/\n//g;
                $testDesrciption =~ s/\t//g;
                $testDesrciption =~ s/\r//g;
                if (defined($settings{items}[$i]{description}) && $testDesrciption gt " " 
                        && $settings{items}[$i]{removeFlag} ne 'T') {
                    if (!defined($settings{items}[$i]{olditemnumber}) || $settings{items}[$i]{olditemnumber} == 0) {
                        # insert new items
                        $sqlcode = "INSERT INTO $args{schema}.items (prnumber, itemnumber, description, partnumber, quantity, ";
                        $sqlcode .= "unitofissue, unitprice, substituteok, techinspection, ishazmat, type, ec) VALUES ('$id', $settings{items}[$i]{itemnumber}, ";
                        $sqlcode .= ":description, " . (($settings{items}[$i]{partnumber} gt " ") ? "'$settings{items}[$i]{partnumber}'" : "NULL") . ", ";
                        $sqlcode .= "$settings{items}[$i]{quantity}, '$settings{items}[$i]{unitofissue}', $settings{items}[$i]{unitprice}, ";
                        $sqlcode .= "'$settings{items}[$i]{substituteok}', '$settings{items}[$i]{techinspection}', '$settings{items}[$i]{ishazmat}', ";
                        $sqlcode .= "$settings{items}[$i]{type}, '$settings{items}[$i]{ec}')";
#print STDERR "\n$sqlcode\n\n";
                        $csr = $args{dbh}->prepare($sqlcode);
                        $csr -> bind_param (":description", $settings{items}[$i]{description}, {ora_type => ORA_CLOB, ora_field => 'description'});
                        $status = $csr->execute;
                        $csr->finish;
                    } else {
                        # update old items
                        $sqlcode = "UPDATE $args{schema}.items SET ";
                        $sqlcode .= "itemnumber=$settings{items}[$i]{itemnumber}, ";
                        $sqlcode .= "description=:description, ";
                        $sqlcode .= "partnumber=" . ((defined($settings{items}[$i]{partnumber}) && $settings{items}[$i]{partnumber} gt " ") ? "'$settings{items}[$i]{partnumber}', " : "NULL, ");
                        $sqlcode .= "quantity=$settings{items}[$i]{quantity}, ";
                        $sqlcode .= "unitofissue='$settings{items}[$i]{unitofissue}', ";
                        $sqlcode .= "unitprice=$settings{items}[$i]{unitprice}, ";
                        $sqlcode .= "substituteok='$settings{items}[$i]{substituteok}', ";
                        $sqlcode .= "techinspection='$settings{items}[$i]{techinspection}', ";
                        $sqlcode .= "ishazmat='$settings{items}[$i]{ishazmat}', ";
                        $sqlcode .= "type=$settings{items}[$i]{type}, ";
                        $sqlcode .= "ec='$settings{items}[$i]{ec}' ";
                        #$sqlcode .= "=$settings{items}[$i]{}, ";
                        $sqlcode .= "WHERE prnumber='$id' AND itemnumber='$settings{items}[$i]{olditemnumber}'";
#print STDERR "\n$sqlcode\n\n";
                        $csr = $args{dbh}->prepare($sqlcode);
                        $csr -> bind_param (":description", $settings{items}[$i]{description}, {ora_type => ORA_CLOB, ora_field => 'description'});
                        $status = $csr->execute;
                        $csr->finish;
                    }
                } elsif ($settings{items}[$i]{olditemnumber} > 0) {
                    # delete removed items
                    $args{dbh}->do("DELETE FROM $args{schema}.items WHERE prnumber='$id' AND itemnumber=$settings{items}[$i]{olditemnumber}");
                }
            }

# vendors
            if ($settings{status} < 11) {
                my $vendRef = $settings{vendorList};
                my @vendors = @$vendRef;
#print STDERR "\nNumber of vendors: $#vendors\n";
                $args{dbh}->do("DELETE FROM $args{schema}.vendor_list WHERE prnumber='$id'");
                if ($settings{blanketrelease} eq '0') {
                    for (my $i=0; $i<=$#vendors; $i++) {
                        $sqlcode = "INSERT INTO $args{schema}.vendor_list (prnumber, vendor) VALUES ('$id', $vendors[$i])";
                        $status = $args{dbh}->do($sqlcode);
                    }
                } else {
                    $sqlcode = "INSERT INTO $args{schema}.vendor_list (prnumber, vendor) VALUES ('$id', $blanket{vendor})";
                    $status = $args{dbh}->do($sqlcode);
                }
            }
        }

# blanket approval list
        ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'brapprovallist', status=>$settings{oldstatus});
        if ($editable) {
            my $brappRef = $settings{brapprovallist};
            my @brapprovallist = @$brappRef;
            $args{dbh}->do("DELETE FROM $args{schema}.blanket_approvals WHERE prnumber='$id'");
            for (my $i=0; $i<=$settings{brapprovalcount}; $i++) {
                if ($brapprovallist[$i]{userid} > 0) {
                    $sqlcode = "INSERT INTO $args{schema}.blanket_approvals (prnumber, precedence, userid) ";
                    $sqlcode .= "VALUES ('$id', $brapprovallist[$i]{precedence}, $brapprovallist[$i]{userid})";
#print STDERR "\n$sqlcode\n\n";
                    $status = $args{dbh}->do($sqlcode);
                }
            }
        }

# charge distribution list
        ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'chargedistribution', status=>$settings{oldstatus});
        if ($editable) {
            my $cdRef = $settings{chargedist};
            my @chargedistlist = @$cdRef;
            $args{dbh}->do("DELETE FROM $args{schema}.po_chargenumbers WHERE prnumber='$id'");
            for (my $i=0; $i<=$settings{chargedistcount}; $i++) {
                if ($chargedistlist[$i]{chargenumber} gt '0' && $chargedistlist[$i]{cddelete} eq 'F') {
                    my ($totalInv) = $args{dbh}->selectrow_array("SELECT NVL(SUM(d.tax) + SUM(d.amount), 0) FROM $args{schema}.invoice_detail d," .
                                  "$args{schema}.invoices i WHERE d.invoiceid=i.id AND " .
                                  "i.prnumber='$id' AND d.chargenumber='$chargedistlist[$i]{chargenumber}' " .
                                  "AND d.ec=$chargedistlist[$i]{ec}");
                    $sqlcode = "INSERT INTO $args{schema}.po_chargenumbers (prnumber, chargenumber, ec, amount, invoiced) ";
                    $sqlcode .= "VALUES ('$id', '$chargedistlist[$i]{chargenumber}', '$chargedistlist[$i]{ec}', ";
                    $sqlcode .= "$chargedistlist[$i]{amount}, $totalInv)";
#print STDERR "\n$sqlcode\n\n";
                    $status = $args{dbh}->do($sqlcode);
                }
            }
        }
        
# questions
        ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'questions', status=>$settings{oldstatus});
        if ($editable) {
            $args{dbh}->do("DELETE FROM $args{schema}.question_list WHERE prnumber='$id'");
            for (my $i=0; $i < $settings{questioncount}; $i++) {
                # insert
                $sqlcode = "INSERT INTO $args{schema}.question_list (prnumber, precedence, answer, role, text) ";
                $sqlcode .= "VALUES ('$id', $settings{questions}[$i]{precedence}, $settings{questions}[$i]{answer}, ";
                $sqlcode .= "$settings{questions}[$i]{role}, :text)";
#print STDERR "\n$sqlcode\n\n";
                $csr = $args{dbh}->prepare($sqlcode);
                $csr -> bind_param (":text", $settings{questions}[$i]{text});
                $status = $csr->execute;
                $csr->finish;
            }
        }

## clauses
        ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'clauses', status=>$settings{oldstatus});
        if ($editable) {
            $args{dbh}->do("DELETE FROM $args{schema}.clause_list WHERE prnumber='$id'");
            for (my $i=1; $i <= $settings{clausecount}; $i++) {
                if ($settings{clauses}[$i]{removeflag} eq 'F') {
                    # insert
                    $sqlcode = "INSERT INTO $args{schema}.clause_list (prnumber, precedence, type, rfp, po, clause) ";
                    $sqlcode .= "VALUES ('$id', $settings{clauses}[$i]{precedence}, '$settings{clauses}[$i]{type}', ";
                    $sqlcode .= "'$settings{clauses}[$i]{rfp}', '$settings{clauses}[$i]{po}', :clause)";
#print STDERR "\n$sqlcode\n\n";
                    $csr = $args{dbh}->prepare($sqlcode);
                    $csr -> bind_param (":clause", $settings{clauses}[$i]{clause}, {ora_type => ORA_CLOB, ora_field => 'clause'});
                    $status = $csr->execute;
                    $csr->finish;
                }
            }
        }

# attachments
        if (defined($args{fileName}) && $args{fileName} ne 'none' && $args{fileName} gt ' ') {
            my ($displayedpo, $editablepo) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'attachmentpoflag', status=>$settings{oldstatus});
            my $name = $args{fileName};
            $name =~ s/\\/\//g;
            $name = substr($name, (rindex($name, '/') + 1));
            $sqlcode = "INSERT INTO $args{schema}.attachments (id, prnumber, filename, data, pr, rfp, po) VALUES ($args{schema}.attachments_id.NEXTVAL, ";
            $sqlcode .= "'$id', '$name', :data, ";
#print STDERR "\nEditablepo: $editablepo, Status: $settings{status}, OldStatus: $settings{oldstatus}\n\n";
            if ($editablepo) {
                $sqlcode .= "'F', 'F', 'T')";
            } else {
                #$sqlcode .= "'T', 'F', 'F')";
                $sqlcode .= "'T', 'T', 'T')";
            }
            $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":data", $args{fileContents}, {ora_type => ORA_BLOB, ora_field => 'data'});
            $status = $csr->execute;
            $csr->finish;
        }
        for (my $i=0; $i <= $settings{newattachmentcount}; $i++) {
#print STDERR "\n2 - $i, $fileSet[$i]{fileName}\n";
            if (defined($fileSet[$i]{fileName}) && $fileSet[$i]{fileName} ne 'none' && $fileSet[$i]{fileName} gt ' ') {
                my ($displayedpo, $editablepo) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'attachmentpoflag', status=>$settings{oldstatus});
                my $name = $fileSet[$i]{fileName};
                $name =~ s/\\/\//g;
                $name = substr($name, (rindex($name, '/') + 1));
                $sqlcode = "INSERT INTO $args{schema}.attachments (id, prnumber, filename, data, pr, rfp, po) VALUES ($args{schema}.attachments_id.NEXTVAL, ";
                $sqlcode .= "'$id', '$name', :data, ";
#print STDERR "\nEditablepo: $editablepo, Status: $settings{status}, OldStatus: $settings{oldstatus}\n\n";
                if ($editablepo) {
                    $sqlcode .= "'F', 'F', 'T')";
                } else {
                    #$sqlcode .= "'T', 'F', 'F')";
                    $sqlcode .= "'T', 'T', 'T')";
                }
                $csr = $args{dbh}->prepare($sqlcode);
                $csr -> bind_param (":data", $fileSet[$i]{fileContents}, {ora_type => ORA_BLOB, ora_field => 'data'});
                $status = $csr->execute;
                $csr->finish;
            }
        }
        for (my $i=0; $i <= $settings{attachmentcount}; $i++) {
            if ($settings{attachments}[$i]{removeFlag} eq 'T') {
                $sqlcode = "DELETE FROM $args{schema}.attachments WHERE id=$settings{attachments}[$i]{id}";
            } else {
                $sqlcode = "UPDATE $args{schema}.attachments SET rfp='$settings{attachments}[$i]{rfp}', po='$settings{attachments}[$i]{po}'";
                $sqlcode .= " WHERE id=$settings{attachments}[$i]{id}";
            }
            $args{dbh}->do($sqlcode);
        }
            
# remarks
        if ($settings{remarks} gt ' ') {
            #$sqlcode = "INSERT INTO $args{schema}.remarks (prnumber, userid, dateentered, text) VALUES ('$id', $args{userID}, TO_DATE('$changeDate', '$dateFormat'), ";
            $sqlcode = "INSERT INTO $args{schema}.remarks (prnumber, userid, dateentered, text) VALUES ('$id', $args{userID}, SYSDATE, ";
            $sqlcode .= ":text)";
#print STDERR "\n$sqlcode\n\n";
            $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":text", $settings{remarks}, {ora_type => ORA_CLOB, ora_field => 'text'});
            $status = $csr->execute;
            $csr->finish;
        }
# check funding
#print STDERR "\n-----TrackFunding=$trackFunding\n";
        if ($trackFunding eq 'T' && $settings{status} == 3) {
            my $approvedAmount = &getApprovedAmount(dbh=>$args{dbh}, schema=>$args{schema}, id=>$settings{chargenumber});
#print STDERR "\n-----Approved Amount=$approvedAmount, PDTotal=$settings{pdtotal}, Funding=$cn{funding} \n";
            if (($approvedAmount + $settings{pdtotal}) > $cn{funding}) {
                $underFunded = 'T';
                $args{dbh}->do("UPDATE $args{schema}.purchase_documents SET status=$settings{oldstatus} WHERE prnumber='$id'");
                $resultStatus = -2;
            }
        }

# create approval list
        if ($settings{status} != $settings{oldstatus} && $underFunded ne 'T') {
            &genPDApprovalList(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, pd=>$id, status=>$settings{status}, settings => \%settings);
        }


        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return ($resultStatus,$id);
}


###################################################################################################################################
sub getPDInfo {  # routine to get PD info
###################################################################################################################################
    my %args = (
        id => 0,
        history => 'F',
        date =>'',
        historyStatus => 0,
        ecCode => 0,
        chargeNumber => '0',
        @_,
    );

    my $i = 0;
    my %pd;
    $args{dbh}->{LongReadLen} = 100000000;
    $args{dbh}->{LongTruncOk} = 0;
    my $dateFormat = "MM/DD/YYYY HH24:MI:SS";
    my $itemWhere = (($args{ecCode} > 0) ? "AND ec=$args{ecCode} " : "");
    
# PD info
    my $sqlcode = "SELECT prnumber,ponumber,amendment,priority,TO_CHAR(daterequested,'MM/DD/YYYY'),TO_CHAR(duedate,'MM/DD/YYYY'),author,requester,justification,";
    $sqlcode .= "solesource,ssjustification,status,TO_CHAR(daterequired,'MM/DD/YYYY'),deptid,chargenumber,awardtype,contracttype,taxexempt,tax,";
    $sqlcode .= "shipping,potype,fob,shipvia,paymentterms,buyer,amendedby,vendor,rfpdeliverdays,rfpdaysvalid,TO_CHAR(rfpduedate,'MM/DD/YYYY'),";
    $sqlcode .= "relatedpr,TO_CHAR(prdate,'MM/DD/YYYY'),TO_CHAR(podate,'MM/DD/YYYY'), bidremarks, selectionmemo, enclosures, ";
    $sqlcode .= "TO_CHAR(startdate,'MM/DD/YYYY'), TO_CHAR(enddate,'MM/DD/YYYY'), creditcardholder, briefdescription, pdtotal, refnumber, ";
    $sqlcode .= "TO_CHAR(duedate,'YYYY/MM/DD'), TO_CHAR(dateRequested,'YYYY/MM/DD'), TO_CHAR(rfpduedate,'YYYY/MM/DD'), TO_CHAR(prdate,'YYYY/MM/DD') ";
    if ($args{history} eq 'T') {
        if ($args{historyStatus} == 0) {
            $sqlcode .= ", TO_CHAR(changedate,'$dateFormat'), changes, changedby, shippingchange, taxchange ";
            $sqlcode .= "FROM $args{schema}.pd_history WHERE prnumber='$args{id}' AND changedate=TO_DATE('$args{date}','$dateFormat')";
        } else {
            $sqlcode .= ", TO_CHAR(changedate,'$dateFormat'), changes, changedby, shippingchange, taxchange ";
            $sqlcode .= "FROM $args{schema}.pd_history WHERE prnumber='$args{id}' AND status=$args{historyStatus} ORDER BY changedate DESC";
        }
    } else {
        $sqlcode .= ", NULL, NULL, NULL, NULL, NULL ";
        $sqlcode .= "FROM $args{schema}.purchase_documents WHERE prnumber='$args{id}'";
    }

#print STDERR "\n$sqlcode\n\n";
    
    ($pd{prnumber},$pd{ponumber},$pd{amendment},$pd{priority},$pd{daterequested},$pd{duedate},$pd{author},$pd{requester},$pd{justification},
          $pd{solesource},$pd{ssjustification},$pd{status},$pd{daterequired},$pd{deptid},$pd{chargenumber},$pd{awardtype},
          $pd{contracttype},$pd{taxexempt},$pd{tax},$pd{shipping},$pd{potype},$pd{fob},$pd{shipvia},$pd{paymentterms},$pd{buyer},$pd{amendedby},
          $pd{vendor},$pd{rfpdeliverdays},$pd{rfpdaysvalid},$pd{rfpduedate},$pd{relatedpr},$pd{prdate},$pd{podate},$pd{bidremarks},
          $pd{selectionmemo}, $pd{enclosures}, $pd{startdate}, $pd{enddate}, $pd{creditcardholder}, $pd{briefdescription}, $pd{pdtotal}, $pd{refnumber}, 
          $pd{duedatetest}, $pd{daterequestedtest}, $pd{rfpduedatetest}, $pd{prdatetest}, 
          $pd{changedate},$pd{changes},$pd{changedby},$pd{shippingchange},$pd{taxchange}) 
          = $args{dbh}->selectrow_array($sqlcode);
    
    ($pd{deptname}, $pd{site}) = $args{dbh}->selectrow_array("SELECT name, site FROM $args{schema}.departments WHERE id=" . ((defined($pd{deptid})) ? $pd{deptid} : 0));
    if (defined($pd{status}) and $pd{status} >= 0) {
        ($pd{statusname}) = $args{dbh}->selectrow_array("SELECT name FROM $args{schema}.pd_status WHERE id=" . $pd{status});
    } else {
        ($pd{statusname}) = "n/a";
    }

# related PR info
    if (defined($pd{relatedpr}) && $pd{relatedpr} gt '0') {
        my %blanket = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$pd{relatedpr});
        $pd{relatedprinfo} = \%blanket;
    } else {
        #$pd{relatedprinfo} = (none=>'none',);
        $pd{relatedprinfo} = ();
    }

    my $total = ((defined($pd{tax})) ? $pd{tax} : 0) + ((defined($pd{shipping})) ? $pd{shipping} : 0);
    my $totalChange = ((defined($pd{taxchange})) ? $pd{taxchange} : 0) + ((defined($pd{shippingchange})) ? $pd{shippingchange} : 0);

# charge number info
    if (defined($pd{chargenumber}) && $pd{chargenumber} gt '  ') {
        my $sqlcode = "SELECT fyscalyear,site,description FROM $args{schema}.charge_numbers WHERE chargenumber='$pd{chargenumber}'";
        ($pd{cnFY}, $pd{cnSite}, $pd{cnDescription}) = $args{dbh}->selectrow_array($sqlcode);
    } else {
        $pd{cnFY} = 'n/a';
        $pd{cnSite} = 0;
        $pd{cnDescription} = 'n/a';
    }
# question info
    my @questions = &getQuestionList(dbh=>$args{dbh}, schema=>$args{schema}, prnumber => $pd{prnumber});
    my $questionCount = $#questions;
    $pd{questionList} = \@questions;
    $pd{questionCount} = $questionCount;
# item info
    my @taxECs = &getSiteTaxableEC(dbh=>$args{dbh}, schema=>$args{schema}, deptID=>$pd{deptid});
    $sqlcode = "SELECT prnumber,itemnumber,description,partnumber,quantity,unitofissue,unitprice,ishazmat,type,ec,";
    $sqlcode .= "quantityreceived,substituteok, techinspection ";
    if ($args{history} eq 'T') {
        if ($args{historyStatus} == 0) {
            $sqlcode .= ", TO_CHAR(changedate,'$dateFormat'), pricechange, changes ";
            $sqlcode .= "FROM $args{schema}.item_history WHERE prnumber='$args{id}' AND changedate=TO_DATE('$args{date}','$dateFormat') $itemWhere ORDER BY itemnumber";
        } else {
            $sqlcode .= ", TO_CHAR(changedate,'$dateFormat'), pricechange, changes ";
            $sqlcode .= "FROM $args{schema}.item_history WHERE prnumber='$args{id}' AND changedate=TO_DATE('$pd{changedate}','$dateFormat') $itemWhere ORDER BY itemnumber";
        }
    } else {
        $sqlcode .= ", NULL, NULL, NULL ";
        $sqlcode .= "FROM $args{schema}.items WHERE prnumber='$args{id}' $itemWhere ORDER BY itemnumber";
    }
#print STDERR "\n$sqlcode\n\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    $pd{totalTaxable} = 0;
    $pd{totOrdered} = 0;
    $pd{totReceived} = 0;
    while (($pd{items}[$i]{prnumber},$pd{items}[$i]{itemnumber},$pd{items}[$i]{description},$pd{items}[$i]{partnumber},
              $pd{items}[$i]{quantity},$pd{items}[$i]{unitofissue},$pd{items}[$i]{unitprice},$pd{items}[$i]{ishazmat},
              $pd{items}[$i]{type},$pd{items}[$i]{ec},
              $pd{items}[$i]{quantityreceived},$pd{items}[$i]{substituteok},$pd{items}[$i]{techinspection},
              $pd{items}[$i]{changedate},$pd{items}[$i]{pricechange},$pd{items}[$i]{changes}) = $csr->fetchrow_array) {
        my $tempCost = $pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice};
        $pd{ecTotals}{$pd{items}[$i]{ec}} = ((!defined($pd{ecTotals}{$pd{items}[$i]{ec}})) ? $tempCost : ($pd{ecTotals}{$pd{items}[$i]{ec}} + $tempCost));
        $total += $pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice};
        $totalChange += ((defined($pd{items}[$i]{pricechange})) ? $pd{items}[$i]{pricechange} : 0);
        my $isTaxableEC = 'F';
        for (my $j=0; $j<$#taxECs; $j++) {
            if($taxECs[$j]{ec} == $pd{items}[$i]{ec}) { $isTaxableEC = 'T';}
        }
        #$pd{totalTaxable} += ((($pd{items}[$i]{ec} >= 47 && $pd{items}[$i]{ec} <= 49) || $pd{items}[$i]{ec} == 61) ? ($pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice}) : 0);
        $pd{totalTaxable} += (($isTaxableEC eq 'T') ? ($pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice}) : 0);
        $pd{totOrdered} += $pd{items}[$i]{quantity};
        $pd{totReceived} += $pd{items}[$i]{quantityreceived};
        $i++;
    }
    $csr->finish;
    if ($pd{totalTaxable} != 0) {
        for (my $j=0; $j<$#taxECs; $j++) {
            $pd{ecTotals}{$taxECs[$j]{ec}} += ((defined($pd{ecTotals}{$taxECs[$j]{ec}})) ? ($pd{ecTotals}{$taxECs[$j]{ec}}/$pd{totalTaxable}*($pd{tax} + $pd{shipping})) : 0);
        }
        #$pd{ecTotals}{47} += ((defined($pd{ecTotals}{47})) ? ($pd{ecTotals}{47}/$pd{totalTaxable}*($pd{tax} + $pd{shipping})) : 0);
        #$pd{ecTotals}{48} += ((defined($pd{ecTotals}{48})) ? ($pd{ecTotals}{48}/$pd{totalTaxable}*($pd{tax} + $pd{shipping})) : 0);
        #$pd{ecTotals}{49} += ((defined($pd{ecTotals}{49})) ? ($pd{ecTotals}{49}/$pd{totalTaxable}*($pd{tax} + $pd{shipping})) : 0);
    }
    $pd{itemCount} = $i;
    $pd{total} = $total;
    $pd{totalChange} = $totalChange;
    
# vendor info
    $sqlcode = "SELECT prnumber,vendor FROM $args{schema}.vendor_list WHERE prnumber='$args{id}' ORDER BY vendor";
    
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    $i = 0;
    while (($pd{vendorList}[$i]{prnumber},$pd{vendorList}[$i]{vendor}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;
    $pd{vendorCount} = $i;
    if (defined($pd{vendor}) && $pd{vendor} > 0) {
        ($pd{vendorname}) = $args{dbh}->selectrow_array("SELECT name FROM $args{schema}.vendors WHERE id=$pd{vendor}");
    } else {
        $pd{vendorname} = '';
    }
    
# attachments
    $sqlcode = "SELECT id,prnumber,filename,pr,rfp,po FROM $args{schema}.attachments WHERE prnumber='$args{id}' ORDER BY id";
#print STDERR "\n$sqlcode\n";
    
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    $i = 0;
    while (($pd{attachments}[$i]{id},$pd{attachments}[$i]{prnumber},$pd{attachments}[$i]{filename},
              $pd{attachments}[$i]{pr},$pd{attachments}[$i]{rfp},$pd{attachments}[$i]{po}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;
    $pd{attachmentCount} = $i;
#print STDERR "\nAttachment Count: $pd{attachmentCount}\n\n";
    
# remarks
    $sqlcode = "SELECT prnumber,userid,TO_CHAR(dateentered, 'MM/DD/YYYY HH24:MI'),text FROM $args{schema}.remarks ";
    $sqlcode .= "WHERE prnumber='$args{id}' ORDER BY dateentered DESC";

    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    $i = 0;
    while (my ($prnumber, $userid, $dateentered, $text) = $csr->fetchrow_array) {
        $pd{remarks}[$i]{prnumber} = $prnumber;
        $pd{remarks}[$i]{userid} = $userid;
        $pd{remarks}[$i]{dateentered} = $dateentered;
        $pd{remarks}[$i]{text} = $text;
        $i++;
    }
    $csr->finish;
    $pd{remarkCount} = $i;

## brapprovallist
    $sqlcode = "SELECT prnumber, precedence, userid FROM $args{schema}.blanket_approvals WHERE prnumber='$args{id}' ";
    $sqlcode .= "ORDER BY precedence";
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    $i = 0;
    while (my ($prnumber, $precedence, $userid) = $csr->fetchrow_array) {
        $pd{brapprovallist}[$i]{prnumber} = $prnumber;
        $pd{brapprovallist}[$i]{precedence} = $precedence;
        $pd{brapprovallist}[$i]{userid} = $userid;
        $i++;
    }
    $csr->finish;
    $pd{brapprovallistCount} = $i;
    

## clauses
    $sqlcode = "SELECT prnumber, precedence, type, rfp,po,clause FROM $args{schema}.clause_list WHERE prnumber='$args{id}' ";
    $sqlcode .= "ORDER BY type DESC, precedence";
    
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    $i = 0;
    while (my ($prnumber, $precedence, $type, $rfp,$po,$text) = $csr->fetchrow_array) {
        $pd{clause}[$i]{prnumber} = $prnumber;
        $pd{clause}[$i]{precedence} = $precedence;
        $pd{clause}[$i]{type} = $type;
        $pd{clause}[$i]{rfp} = $rfp;
        $pd{clause}[$i]{po} = $po;
        $pd{clause}[$i]{text} = $text;
        $i++;
    }
    $csr->finish;
    $pd{clauseCount} = $i;

    my ($site) = $args{dbh}->selectrow_array("SELECT site FROM $args{schema}.departments WHERE id=" . ((defined($pd{deptid})) ? $pd{deptid} : 0));
    my ($salestax) = $args{dbh}->selectrow_array("SELECT NVL(salestax, 0.0) FROM $args{schema}.site_info WHERE id=" . ((defined($site)) ? $site : 0));
    $pd{salestax} = $salestax;

## charge distribution
    $sqlcode = "SELECT prnumber, chargenumber, ec, amount, invoiced, ";
    $sqlcode .= (($args{history} eq 'T') ? "TO_CHAR(changedate,'$dateFormat'), changeamount" : "'00/00/0000 00:00:00', 0");
    $sqlcode .= " FROM $args{schema}.". (($args{history} eq 'T') ? "po_cn_history" : "po_chargenumbers") . " WHERE prnumber='$args{id}' ";
    $sqlcode .= (($args{history} eq 'T') ? "AND changedate=TO_DATE('$args{date}','$dateFormat') " : "");
    $sqlcode .= "ORDER BY chargenumber, ec";
    
#print STDERR "\n$sqlcode\n\n";
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    $i = 0;
    $pd{chargedistAmount} = 0.0;
    $pd{chargedistInvoiced} = 0.0;
    while (my ($prnumber, $chargenumber, $ec, $amount,$invoiced, $changedate, $changeamount) = $csr->fetchrow_array) {
        if ($args{chargeNumber} eq '0' || $args{chargeNumber} eq $chargenumber) {
            $pd{chargedistlist}[$i]{prnumber} = $prnumber;
            $pd{chargedistlist}[$i]{chargenumber} = $chargenumber;
            $pd{chargedistlist}[$i]{ec} = $ec;
            $pd{chargedistlist}[$i]{amount} = $amount;
            $pd{chargedistlist}[$i]{invoiced} = $invoiced;
            $pd{chargedistlist}[$i]{changedate} = $changedate;
            $pd{chargedistlist}[$i]{changeamount} = $changeamount;
            $pd{chargedisthash}{"$chargenumber - $ec"}{amount} = $amount;
            $pd{chargedisthash}{"$chargenumber - $ec"}{invoiced} = $invoiced;
            $pd{chargedistAmount} += $amount;
            $pd{chargedistInvoiced} += $invoiced;
            $i++;
        }
    }
    $csr->finish;
    $pd{chargedistlistCount} = $i;

## receiving log
    #my @rLogTemp = &getReceiving(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pd{prnumber});
    #$pd{rLog} = \@rLogTemp;
    #$pd{rLogCount} = $#rLogTemp;

## ap log
    #my @apTemp = &getAP(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pd{prnumber});
    #$pd{ap} = \@apTemp;
    #$pd{apCount} = $#apTemp;
    #$pd{apTax} = 0;
    #$pd{apAmount} = 0;
    #for (my $i=0; $i<$#apTemp; $i++) {
    #    $pd{apTax} += $apTemp[$i]{tax};
    #    $pd{apAmount} += $apTemp[$i]{amount};
    #}
    

    return (%pd);
}


###################################################################################################################################
sub createBlankPD {  # routine to create a blank PD
###################################################################################################################################
    my %args = (
        userID => 0,
        deptID => 0,
        @_,
    );
    my %pd;
    my $sqlcode = "";
    
    if ($args{deptID} == 0) {
        $sqlcode = "SELECT NVL(id,0),NVL(name,''),NVL(chargenumber,''), NVL(site,0) FROM $args{schema}.departments WHERE id IN ";
        $sqlcode .= "(SELECT dept FROM $args{schema}.user_dept WHERE userid=$args{userID})";
    } else {
        $sqlcode = "SELECT NVL(id,0),NVL(name,''),NVL(chargenumber,''), NVL(site,0) FROM $args{schema}.departments WHERE id = " . $args{deptID};
    }

    my ($dept, $name, $chargenumber, $site) = $args{dbh}->selectrow_array($sqlcode);
    my ($taxexempt, $salestax) = $args{dbh}->selectrow_array("SELECT NVL(taxexempt, 'F'), NVL(salestax, 0.0) FROM $args{schema}.site_info WHERE id=$site");
    my %rule = &getRuleInfo(dbh=>$args{dbh}, schema=>$args{schema}, type=>10, site=>$site);
    $rule{nvalue1} = ((defined($rule{nvalue1}) && $rule{nvalue1} > 1) ? $rule{nvalue1} : 90);
    my $due90 = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, type=>'days', offset => $rule{nvalue1});
    my @questions = &createQuestionList(dbh=>$args{dbh}, schema=>$args{schema}, site=>$site);
    my $questionCount = $#questions;
    $questionCount++;
    my %relatedprinfo = (na=>'N/A',);

    %pd = (
        prnumber => "",
        ponumber => "",
        amendment => "",
        priority => 'F',
        duedate => "$due90",
        author => $args{userID},
        requester => $args{userID},
        briefdescription => '',
        justification => "",
        solesource => 'F',
        ssjustification => '',
        status => 1,
        daterequested => '',
        daterequired => "$due90",
        deptid => $dept,
        deptname => $name,
        chargenumber => $chargenumber,
        site => $site,
        awardtype => 1,
        contracttype => 1,
        taxexempt => $taxexempt,
        salestax => $salestax,
        tax => 0.0,
        shipping => 0.0,
        potype => 1,
        fob => 2,
        shipvia => '',
        paymentterms => '',
        buyer => 0,
        amendedby => 0,
        vendor => 0,
        vendorname => '',
        vendorList => [],
        vendorCount => 0,
        rfpdeliverdays => 0,
        rfpdaysvalid => 0,
        rfpduedate => '',
        questionList => \@questions,
        questionCount => $questionCount,
        relatedpr => '',
        relatedprinfo => \%relatedprinfo,
        prdate => '',
        podate => '',
        items => [],
        itemCount => 0,
        attachments => [],
        attachmentCount => 0,
        remarks => [],
        remarkCount => 0,
        total => 0,
        clauseList => [],
        clauseCount => 0,
        bidremarks => '',
        rLog => [],
        rLogCount => 0,
        startdate => '',
        enddate => '',
        selectionmemo => '',
        enclosuers => '',
        creditcardholder => 0,
        brapprovallist => [],
        brapprovallistCount => 0,
        chargedistlist => [],
        chargedistlistCount => 0,
        pdtotal => 0,
        refnumber => '',
    );
    return (%pd);
}


###################################################################################################################################
sub doDisplayControl {  # routine to determine if a field is displayed and editable
###################################################################################################################################
    my %args = (
        field => '',
        status => 0,
        browseOnly => 'F',
        @_,
    );
    
    my $sqlcode = '';
    
    if ($displayControl{loaded} eq 'F') {
        $sqlcode = "SELECT field, status, displayed, editable FROM $args{schema}.display_control";
        my $csr = $args{dbh}->prepare($sqlcode);
        $csr->execute;
        
        while (my ($field, $status, $displayed, $editable) = $csr->fetchrow_array) {
            $displayControl{"$field - $status"}{displayed} = $displayed;
            $displayControl{"$field - $status"}{editable} = $editable;
#print STDERR "$field - $status, " . $displayControl{"$field - $status"}{displayed} . ", " . $displayControl{"$field - $status"}{editable} . "\n";
        }
        $displayControl{loaded} = 'T';
    }
    
#print STDERR "\n$args{field}, $args{status}\n\n";
    #my ($display, $editable) = (($args{browseOnly} eq 'T' || $args{status} == 0) ? (1, 0) : (1, 1));
    my $display = ((defined($displayControl{"$args{field} - $args{status}"}{displayed})) ? $displayControl{"$args{field} - $args{status}"}{displayed} : "F");
    my $editable = (($args{browseOnly} eq 'F' && defined($displayControl{"$args{field} - $args{status}"}{editable}) && $args{status} > 0) ? $displayControl{"$args{field} - $args{status}"}{editable} : "F");
    
    $display = (($display eq 'T') ? 1 : 0);
    $editable = (($editable eq 'T') ? 1 : 0);
    
    return ($display, $editable);
}


###################################################################################################################################
sub getECArray {  # routine to get an array of ECs
###################################################################################################################################
    my %args = (
        @_,
    );

    my $i = 0;
    my @ec;
    #$args{dbh}->{LongReadLen} = 100000000;
    #$args{dbh}->{LongTruncOk} = 0;
    my $sqlcode = "SELECT ec, description FROM $args{schema}.element_code ";
    $sqlcode .= "ORDER BY ec";
#print STDERR "\n$sqlcode\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($ec[$i]{ec}, $ec[$i]{description}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;

    return (@ec);
}


###################################################################################################################################
sub getUnitIssue {  # routine to get an array of Units of Issue
###################################################################################################################################
    my %args = (
        @_,
    );

    my $i = 0;
    my @units;
    #$args{dbh}->{LongReadLen} = 100000000;
    #$args{dbh}->{LongTruncOk} = 0;
    my $sqlcode = "SELECT unit, description FROM $args{schema}.unit_issue ";
    $sqlcode .= "ORDER BY unit";
#print STDERR "\n$sqlcode\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($units[$i]{unit}, $units[$i]{description}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;

    return (@units);
}


###################################################################################################################################
sub getNextPRSeq {  # routine to get the next available PR number
###################################################################################################################################
    my %args = (
        dept => 0,
        @_,
    );

    my ($site, $group, $sitecode) = $args{dbh}->selectrow_array("SELECT d.site, d.groupcode,si.sitecode FROM $args{schema}.departments d, " .
                         "$args{schema}.site_info si WHERE d.site=si.id AND d.id=$args{dept}");
    my $fy = &getFY();
    my $prnumber = '';
    my $seqName = $sitecode . "_PRSEQ_" . $fy;
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
    $prnumber = $sitecode . $group . $fy . lpadzero($seqNumber, 4);
    $prnumber =~ s/ //g;

    return ($prnumber);
}


###################################################################################################################################
sub getChargeNumberArray {
###################################################################################################################################
    my %args = (
        id => ' ',
        userID =>0,
        role =>0,
        onlyFY => 'T',
        fy => &getFY(),
        site => 0,
        statusList => "",
        @_,
    );
    my @CNs;
    my $i=0;
    my $from = (($args{userID} == 0 || $args{role} == 0) ? "" : ", $args{schema}.user_roles ur ");
    my $where = (($args{userID} == 0 || $args{role} == 0) ? "" : " AND si.id=ur.site AND ur.userid=$args{userID} AND ur.role=$args{role} ");
    $where .= (($args{onlyFY} ne 'T') ? "" : " AND cn.fyscalyear>=$args{fy} ");
    $where .= (($args{id} le ' ') ? "" : " AND cn.chargenumber='$args{id}' ");
    $where .= (($args{site} == 0) ? "" : " AND cn.site='$args{site}' ");
    #$where .= (($args{statusList} gt ' ') ? " AND (status IN ($args{statusList})) " : "");
    $where .= (($args{statusList} gt ' ') ? " AND (cn.chargenumber IN (SELECT pocn.chargenumber FROM $args{schema}.po_chargenumbers pocn, $args{schema}.purchase_documents pd WHERE pocn.prnumber=pd.prnumber AND pd.status IN ($args{statusList})) ) " : "");
    my $sqlcode = "SELECT cn.chargenumber, cn.fyscalyear, cn.site, cn.description, cn.wbs, cn.funding, si.sitecode, si.name, si.trackfunding, si.companycode ";
    $sqlcode .= "FROM $args{schema}.charge_numbers cn, $args{schema}.site_info si $from ";
    $sqlcode .= "WHERE cn.site = si.id $where ORDER BY si.sitecode, cn.fyscalyear, cn.chargenumber";
#print STDERR "\n$sqlcode\n\n";
    my $lookup = $args{dbh}->prepare($sqlcode);
    $lookup->execute;
    while (($CNs[$i]{chargenumber}, $CNs[$i]{fyscalyear}, $CNs[$i]{site}, $CNs[$i]{description}, $CNs[$i]{wbs}, $CNs[$i]{funding}, $CNs[$i]{sitecode}, 
            $CNs[$i]{sitename}, $CNs[$i]{trackfunding}, $CNs[$i]{companycode})= $lookup->fetchrow_array) {
        $i++;
    }
    $lookup->finish;
    return (@CNs);
}


###################################################################################################################################
sub getPDByStatus {
###################################################################################################################################
    my %args = (
        statusList => '0', # 0 = any
        author => 0,
        requester => -1,
        authorOrRequester => 0,
        buyer => 0,
        noBuyer => 'F',
        siteList => 0,
        orderBy => 'prnumber',
        fy => 0,
        getVendor => 'F',
        vendor => 0,
        getTotal => 'T',
        pd => 0,
        isHistory => 'F',
        hStartDate => '',
        hEndDate => '',
        ipStartDate => '',
        ipEndDate => '',
        poStartDate => '',
        poEndDate => '',
        startingPO => '',
        amended => 'n/a', # T, F, or n/a
        quantOfZero => 'F',
        notRequesterAuthorMatch => 'F',
        receivingCount => 'F',
        orderCount => 'F',
        ecCode => 0,
        chargeNumber => "0",
        cnFromPOCN => 'F',
        hasTaxOnly => 'F',
        @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    $args{dbh}->{LongTruncOk} = 0;
    if ($pdStatus{loaded} eq 'F') {
        %pdStatus =  %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, table=>'pd_status', idColumn=>'id', nameColumn=>'name', orderBy=>'name')};
        $pdStatus{loaded} = 'T';
    }
    #my @depts = &getDeptArray(dbh => $args{dbh}, schema => $args{schema});
    my @PDList;
    my $i = 0;
    my $where = (($args{author} > 0) ? "AND pd.author=$args{author} " : "");
    $where .= (($args{requester} > -1) ? "AND pd.requester=$args{requester} " : "");
    $where .= (($args{authorOrRequester} > 0) ? "AND (pd.author=$args{authorOrRequester} OR pd.requester=$args{authorOrRequester})" : "");
    $where .= (($args{buyer} > 0) ? "AND (pd.buyer=$args{buyer} OR pd.amendedby=$args{buyer}) " : "");
    $where .= (($args{noBuyer} eq 'T') ? "AND pd.buyer IS NULL " : "");
    $where .= (($args{pd} ne 0) ? "AND pd.prnumber='$args{pd}' " : "");
    $where .= (($args{vendor} ne 0) ? "AND pd.vendor='$args{vendor}' " : "");
    $where .= (($args{startingPO} gt ' ') ? "AND pd.ponumber>='$args{startingPO}' " : "");
    $where .= (($args{amended} eq 'F') ? "AND pd.amendment IS NULL " : "");
    $where .= (($args{amended} eq 'T') ? "AND pd.amendment IS NOT NULL " : "");
    $where .= (($args{notRequesterAuthorMatch} eq 'T') ? "AND pd.author <> pd.requester " : "");
    $where .= (($args{siteList} ne 0) ? "AND d.site IN ($args{siteList}) " : "");
    $where .= (($args{fy} ne 0) ? " AND ((pd.daterequested>=TO_DATE('10/01/" . ($args{fy} - 1) ."', 'MM/DD/YYYY') AND pd.daterequested<TO_DATE('10/01/" . ($args{fy}) ."', 'MM/DD/YYYY'))"
           .  " OR (pd.podate>=TO_DATE('10/01/" . ($args{fy} - 1) ."', 'MM/DD/YYYY') AND pd.podate<TO_DATE('10/01/" . ($args{fy}) ."', 'MM/DD/YYYY')))" : "");
    $where .= (($args{quantOfZero} eq 'T') ? "AND pd.prnumber IN (SELECT prnumber FROM $args{schema}.items WHERE quantity=0) " : "");
    $where .= (($args{hStartDate} gt ' ') ? "AND pd.changedate >= TO_DATE('$args{hStartDate}', 'MM/DD/YYYY') " : "");
    $where .= (($args{hEndDate} gt ' ') ? "AND pd.changedate <= TO_DATE('$args{hEndDate}-23:59:59', 'MM/DD/YYYY-HH24:MI:SS') " : "");
    $where .= (($args{ipStartDate} gt ' ') ? "AND pd.prnumber IN (SELECT prnumber FROM $args{schema}.invoices " .
          "WHERE datepaid >= TO_DATE('$args{ipStartDate}', 'MM/DD/YYYY') AND datepaid <= TO_DATE('$args{ipEndDate}-23:59:59', 'MM/DD/YYYY-HH24:MI:SS')) " : "");
    $where .= (($args{ecCode} > 0) ? "AND pd.prnumber IN (SELECT prnumber FROM $args{schema}.items WHERE EC=$args{ecCode}) " : "");
    $where .= (($args{chargeNumber} gt '0' && $args{cnFromPOCN} eq 'F') ? "AND pd.chargenumber='$args{chargeNumber}' " : "");
    $where .= (($args{chargeNumber} gt '0' && $args{cnFromPOCN} eq 'T') ? "AND pd.prnumber IN (SELECT prnumber FROM $args{schema}.po_chargenumbers WHERE chargenumber='$args{chargeNumber}') " : "");
    $where .= (($args{poStartDate} gt ' ') ? "AND pd.podate >= TO_DATE('$args{poStartDate}', 'MM/DD/YYYY') " : "");
    $where .= (($args{poEndDate} gt ' ') ? "AND pd.podate <= TO_DATE('$args{poEndDate}-23:59:59', 'MM/DD/YYYY-HH24:MI:SS') " : "");
    $where .= (($args{hasTaxOnly} eq 'T') ? "AND pd.tax<>0 " : "");
    
    my $statusList = (($args{statusList} ne '0') ? "AND pd.status IN ($args{statusList})" : "");
    my $sqlcode = "SELECT pd.prnumber, pd.ponumber, pd.amendment, pd.refnumber, pd.priority, pd.author, pd.requester, pd.status, TO_CHAR(pd.podate, 'YYYY-MM-DD'), ";
    $sqlcode .= "pd.buyer, pd.amendedby, pd.tax, pd.shipping, pd.vendor, pd.deptid, pd.briefdescription, ";
    $sqlcode .= "d.name, d.site, TO_CHAR(podate,'MM/DD/YYYY'), ";
    $sqlcode .= (($args{isHistory} eq 'T') ? "TO_CHAR(pd.changedate, 'MM/DD/YYYY HH24:MI:SS'), changes " : "'00/00/0000 00:00:00', 'N/A' ");
    $sqlcode .= "FROM $args{schema}." . (($args{isHistory} ne 'T') ? "purchase_documents" : "pd_history") . " pd, $args{schema}.departments d ";
    $sqlcode .= "WHERE pd.deptid=d.id $where $statusList ";
    $sqlcode .= "ORDER BY pd.$args{orderBy}, pd.prnumber";
    
#print STDERR "\n$sqlcode\n\n";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($PDList[$i]{prnumber}, $PDList[$i]{ponumber}, $PDList[$i]{amendment}, $PDList[$i]{refnumber}, $PDList[$i]{priority}, $PDList[$i]{author}, $PDList[$i]{requester}, 
             $PDList[$i]{status}, $PDList[$i]{podate}, $PDList[$i]{buyer}, $PDList[$i]{amendedby}, $PDList[$i]{tax}, $PDList[$i]{shipping}, 
             $PDList[$i]{vendor}, $PDList[$i]{deptid}, $PDList[$i]{briefdescription}, $PDList[$i]{deptname}, $PDList[$i]{site}, $PDList[$i]{podate2}, 
             $PDList[$i]{changedate}, $PDList[$i]{changes}) = $csr->fetchrow_array) {
        $PDList[$i]{statusname} = $pdStatus{$PDList[$i]{status}};
        if (defined($PDList[$i]{vendor}) && $PDList[$i]{vendor}>0 && $args{getVendor} eq 'T') {
            ($PDList[$i]{vendorName}) = $args{dbh}->selectrow_array("SELECT name FROM $args{schema}.vendors WHERE id=$PDList[$i]{vendor}");
        } else {
            $PDList[$i]{vendorName}= 'N/A';
        }
        $PDList[$i]{povendor} = $PDList[$i]{ponumber} . " - " . $PDList[$i]{vendorName};
        $PDList[$i]{vendorpo} = ((defined($PDList[$i]{vendorName})) ? $PDList[$i]{vendorName} : "") . " - " . ((defined($PDList[$i]{ponumber})) ? $PDList[$i]{ponumber} : "");
        $PDList[$i]{refnumbpo} = ((defined($PDList[$i]{refnumber})) ? $PDList[$i]{refnumber} : "") . " - " . ((defined($PDList[$i]{ponumber})) ? $PDList[$i]{ponumber} : "");
        $PDList[$i]{ectotal} = 0;
        if ($args{getTotal} eq 'T') {
            ($PDList[$i]{total}) = $args{dbh}->selectrow_array("SELECT SUM(quantity*unitprice) FROM $args{schema}.items WHERE prnumber='$PDList[$i]{prnumber}'");
            if ($args{ecCode} != 0) {
                ($PDList[$i]{ectotal}) = $args{dbh}->selectrow_array("SELECT SUM(quantity*unitprice) FROM $args{schema}.items WHERE prnumber='$PDList[$i]{prnumber}' AND EC=$args{ecCode}");
            }
        } else {
            $PDList[$i]{total} = 0;
        }
        $PDList[$i]{total} += $PDList[$i]{shipping} + $PDList[$i]{tax};
        if ($args{ecCode} != 0) {
            $PDList[$i]{ectotal} += $PDList[$i]{shipping} + $PDList[$i]{tax};
        }
        if ($args{receivingCount} eq 'T') {
            ($PDList[$i]{receivingCount}) = $args{dbh}->selectrow_array("SELECT NVL(SUM(ri.quantityreceived),0) " .
                  "FROM $args{schema}.receiving_items ri, $args{schema}.receiving_log rl " .
                  "WHERE ri.logid = rl.id and rl.prnumber='$PDList[$i]{prnumber}'");
        } else {
            $PDList[$i]{receivingCount} = 0;
        }
        if ($args{orderCount} eq 'T') {
            ($PDList[$i]{orderCount}) = $args{dbh}->selectrow_array("SELECT NVL(SUM(i.quantity),0) " .
                  "FROM $args{schema}.items i WHERE i.prnumber='$PDList[$i]{prnumber}'");
        } else {
            $PDList[$i]{orderCount} = 0;
        }
        
        $i++;
    }
    $csr->finish;
    
    return (@PDList);
}


###################################################################################################################################
sub genPDApprovalList {
###################################################################################################################################
    my %args = (
        pd => '',
        status => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $sqlcode = '';
    my %pd = getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$args{pd});
    my ($site, $manager) = $args{dbh}->selectrow_array("SELECT site, manager FROM $args{schema}.departments WHERE id=$pd{deptid}");
    
    eval {
        $args{dbh}->do("DELETE FROM $args{schema}.approval_list WHERE prnumber='$args{pd}' AND pdstatus=$args{status}");
    
        if ($args{status} == 3 && $pd{contracttype} != 2) {
            # PR Approvals
            $sqlcode = "INSERT INTO $args{schema}.approval_list (prnumber, role, userid, pdstatus) (";
            $sqlcode .= "SELECT '$args{pd}', ur.role, ur.userid, $args{status} FROM $args{schema}.pd_status_roles psr, ";
            $sqlcode .= "$args{schema}.user_roles ur WHERE psr.role=ur.role AND ur.site=$site AND psr.status=$args{status})";
            $args{dbh}->do($sqlcode);
            $sqlcode = "INSERT INTO $args{schema}.approval_list (prnumber, role, userid, pdstatus) VALUES (";
            $sqlcode .= "'$args{pd}', 16, $manager, $args{status})";
            $args{dbh}->do($sqlcode);
            my ($isSoftware, $isHazMat) = ('F', 'F');
            for (my $i=0; $i<$pd{itemCount}; $i++) {
                if ($pd{items}[$i]{ishazmat} eq 'T') {
                    $isHazMat = 'T';
                }
                if ($pd{items}[$i]{type} == 2) {
                    $isSoftware = 'T';
                }
            }
            if ($isHazMat eq 'T') {
                $sqlcode = "INSERT INTO $args{schema}.approval_list (prnumber, role, userid, pdstatus) (";
                $sqlcode .= "SELECT '$args{pd}', 18, ur.userid, $args{status} FROM ";
                $sqlcode .= "$args{schema}.user_roles ur WHERE ur.role=18 AND ur.site=$site)";
                $args{dbh}->do($sqlcode);
            }
            if ($isSoftware eq 'T') {
                $sqlcode = "INSERT INTO $args{schema}.approval_list (prnumber, role, userid, pdstatus) (";
                $sqlcode .= "SELECT '$args{pd}', ur.role, ur.userid, $args{status} FROM ";
                $sqlcode .= "$args{schema}.user_roles ur WHERE ur.role IN (2, 14) AND ur.site=$site)";
                $args{dbh}->do($sqlcode);
            }
            # questions
            for (my $i=0; $i<$pd{questionCount}; $i++) {
                if ($pd{questionList}[$i]{answer} != 2) {
                    $sqlcode = "SELECT count(*) FROM $args{schema}.approval_list WHERE prnumber='$pd{prnumber}' AND pdstatus=$args{status} AND role=$pd{questionList}[$i]{role}";
#print STDERR "\n$sqlcode\n\n";
                    my ($roleCount) = $args{dbh}->selectrow_array($sqlcode);
                    if ($roleCount == 0) {
                        $sqlcode = "INSERT INTO $args{schema}.approval_list (prnumber, role, userid, pdstatus) (";
                        $sqlcode .= "SELECT '$pd{prnumber}', $pd{questionList}[$i]{role}, ur.userid, $args{status} FROM ";
                        $sqlcode .= "$args{schema}.user_roles ur WHERE ur.role=$pd{questionList}[$i]{role} AND ur.site=$site)";
#print STDERR "\n$sqlcode\n\n";
                        $args{dbh}->do($sqlcode);
                    }
                }
            }
    
        } elsif (($args{status} == 3 || $args{status} == 13) && $pd{contracttype} == 2) {
            # Blanket Relase Approvals
            $args{dbh}->do("DELETE FROM $args{schema}.approval_list WHERE prnumber='$args{pd}' AND pdstatus=$args{status}");
            $sqlcode = "INSERT INTO $args{schema}.approval_list (prnumber, role, userid, pdstatus) (";
            $sqlcode .= "SELECT '$args{pd}', (100 + precedence), userid, $args{status} FROM $args{schema}.blanket_approvals ";
            $sqlcode .= "WHERE prnumber='$pd{relatedpr}')";
#print STDERR "\n$sqlcode\n\n";
            $args{dbh}->do($sqlcode);
        } elsif ($args{status} == 6) {
            # PR Change approvals
            $args{dbh}->do("DELETE FROM $args{schema}.approval_list WHERE prnumber='$args{pd}' AND pdstatus=$args{status}");
            $sqlcode = "INSERT INTO $args{schema}.approval_list (prnumber, role, userid, pdstatus) ";
            $sqlcode .= " VALUES ('$args{pd}', 11, $pd{requester}, $args{status})";
            $args{dbh}->do($sqlcode);
            my ($siteManagerThreshold) = $args{dbh}->selectrow_array("SELECT nvalue1 FROM $args{schema}.rules WHERE type=3 AND site=$site");
            if ($pd{total} >= $siteManagerThreshold) {
                $sqlcode = "INSERT INTO $args{schema}.approval_list (prnumber, role, userid, pdstatus) (";
                $sqlcode .= "SELECT '$args{pd}', 6, ur.userid, $args{status} FROM ";
                $sqlcode .= "$args{schema}.user_roles ur WHERE ur.role=6 AND ur.site=$site)";
                $args{dbh}->do($sqlcode);
            }
        } elsif ($args{status} == 8) {
            # RFP approvals
            $args{dbh}->do("DELETE FROM $args{schema}.approval_list WHERE prnumber='$args{pd}' AND pdstatus=$args{status}");
            $sqlcode = "INSERT INTO $args{schema}.approval_list (prnumber, role, userid, pdstatus) (";
            $sqlcode .= "SELECT '$args{pd}', ur.role, ur.userid, $args{status} FROM $args{schema}.pd_status_roles psr, ";
            $sqlcode .= "$args{schema}.user_roles ur WHERE psr.role=ur.role AND ur.site=$site AND psr.status=$args{status})";
            $args{dbh}->do($sqlcode);
            my ($siteManagerThreshold) = $args{dbh}->selectrow_array("SELECT nvalue1 FROM $args{schema}.rules WHERE type=3 AND site=$site");
            if ($pd{total} >= $siteManagerThreshold) {
                $sqlcode = "INSERT INTO $args{schema}.approval_list (prnumber, role, userid, pdstatus) (";
                $sqlcode .= "SELECT '$args{pd}', 13, ur.userid, $args{status} FROM ";
                $sqlcode .= "$args{schema}.user_roles ur WHERE ur.role=13 AND ur.site=$site)";
#print STDERR "\n$sqlcode\n\n";
                $args{dbh}->do($sqlcode);
            }
            $settings{remarks} = '';
            my (%retVals) = &doProcessPDApproval(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, type=>'approve', settings => \%settings); 
            $settings{retVals}{contracttype} = $retVals{contracttype};
            $settings{retVals}{relatedpr} = $retVals{relatedpr};
            $settings{retVals}{nextStatus} = $retVals{nextStatus};
            $settings{retVals}{logText} = $retVals{logText};
            &doProcessPDApprovalPart2(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
                type => 'approve', settings => \%settings);
        } elsif (($args{status} == 14 || $args{status} == 13) && $settings{creditcardholder} == 0) {
            # PO approvals
            $args{dbh}->do("DELETE FROM $args{schema}.approval_list WHERE prnumber='$args{pd}' AND pdstatus=$args{status}");
            $sqlcode = "INSERT INTO $args{schema}.approval_list (prnumber, role, userid, pdstatus) (";
            $sqlcode .= "SELECT '$args{pd}', ur.role, ur.userid, $args{status} FROM $args{schema}.pd_status_roles psr, ";
            $sqlcode .= "$args{schema}.user_roles ur WHERE psr.role=ur.role AND ur.site=$site AND psr.status=$args{status})";
            $args{dbh}->do($sqlcode);
            my ($siteManagerThreshold) = $args{dbh}->selectrow_array("SELECT nvalue1 FROM $args{schema}.rules WHERE type=7 AND site=$site");
            if ($pd{total} >= $siteManagerThreshold) {
                $sqlcode = "INSERT INTO $args{schema}.approval_list (prnumber, role, userid, pdstatus) (";
                $sqlcode .= "SELECT '$args{pd}', 13, ur.userid, $args{status} FROM ";
                $sqlcode .= "$args{schema}.user_roles ur WHERE ur.role=13 AND ur.site=$site)";
#print STDERR "\n$sqlcode\n\n";
                $args{dbh}->do($sqlcode);
            }
            $settings{remarks} = '';
            my (%retVals) = &doProcessPDApproval(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, type=>'approve', settings => \%settings);
            $settings{retVals}{contracttype} = $retVals{contracttype};
            $settings{retVals}{relatedpr} = $retVals{relatedpr};
            $settings{retVals}{nextStatus} = $retVals{nextStatus};
            $settings{retVals}{logText} = $retVals{logText};
            &doProcessPDApprovalPart2(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
                type => 'approve', settings => \%settings);
        } elsif (($args{status} == 14 || $args{status} == 13) && $settings{creditcardholder} > 0) {
            # PO/Credit Card Approvals
            $args{dbh}->do("DELETE FROM $args{schema}.approval_list WHERE prnumber='$args{pd}' AND pdstatus=$args{status}");
            $sqlcode = "INSERT INTO $args{schema}.approval_list (prnumber, role, userid, pdstatus) ";
            $sqlcode .= "VALUES ('$args{pd}', 19, $settings{creditcardholder}, $args{status})";
            $args{dbh}->do($sqlcode);
            $settings{remarks} = '';
            my (%retVals) = &doProcessPDApproval(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, type=>'approve', settings => \%settings);
            $settings{retVals}{contracttype} = $retVals{contracttype};
            $settings{retVals}{relatedpr} = $retVals{relatedpr};
            $settings{retVals}{nextStatus} = $retVals{nextStatus};
            $settings{retVals}{logText} = $retVals{logText};
            &doProcessPDApprovalPart2(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
                type => 'approve', settings => \%settings);
        }
        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }
    
    return ();
}


###################################################################################################################################
sub getApprovalList {
###################################################################################################################################
    my %args = (
        userID => 0,
        addDelegated => 'T',
        pd => '0',
        @_,
    );
    
    my $sqlcode = '';
    my @list;
    my $addDelegated = "OR al.userid ||'-'||d.site||'-'||al.role IN (SELECT userid||'-'||site||'-'||role FROM $args{schema}.user_roles ";
    $addDelegated .= "WHERE delegatedto=$args{userID} AND delegationstart<=SYSDATE AND (delegationstop+1)>= SYSDATE)";
    my $userTest = (($args{userID} > 0) ? "AND (al.userid=$args{userID} $addDelegated) " : "");
    my $pdTest = (($args{pd} gt '0') ? "AND (al.prnumber='$args{pd}')" : "");
    
    $sqlcode = "SELECT al.prnumber,al.role,al.userid,al.pdstatus,NVL(al.approvedby,0),r.precedence, pd.ponumber, pd.amendment, pd.briefdescription ";
    $sqlcode .= "FROM $args{schema}.approval_list al, $args{schema}.roles r, $args{schema}.purchase_documents pd, $args{schema}.departments d ";
    $sqlcode .= "WHERE al.role=r.id AND al.prnumber=pd.prnumber AND pd.deptid=d.id AND al.dateapproved IS NULL $userTest $pdTest ";
    $sqlcode .= "AND (al.prnumber, al.pdstatus, r.precedence) IN (SELECT al.prnumber,al.pdstatus,min(r.precedence) ";
    $sqlcode .= "FROM $args{schema}.approval_list al, $args{schema}.roles r ";
    $sqlcode .= "WHERE r.id=al.role AND al.dateapproved IS NULL GROUP BY al.prnumber,al.pdstatus) ";
    $sqlcode .= "ORDER BY al.prnumber";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    my $i=0;
    while (($list[$i]{prnumber},$list[$i]{role},$list[$i]{userid},$list[$i]{pdstatus},$list[$i]{approvedby},$list[$i]{precedence},
            $list[$i]{ponumber},$list[$i]{amendment},$list[$i]{briefdescription}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;
    
    return (@list);
}


###################################################################################################################################
sub getPDApprovals {
###################################################################################################################################
    my %args = (
        pd => 0,
        status => 0,
        @_,
    );
    
    my $sqlcode = '';
    my @list;
    
    $sqlcode = "SELECT al.prnumber,al.role,r.name,al.userid,NVL(al.approvedby,0),u.lastname,u.firstname,al.pdstatus,pds.name,";
    $sqlcode .= "TO_CHAR(al.dateapproved,'MM/DD/YYYY HH24:MI:SS'),r.precedence ";
    $sqlcode .= "FROM $args{schema}.approval_list al, $args{schema}.users u, $args{schema}.pd_status pds, $args{schema}.roles r ";
    $sqlcode .= "WHERE al.role=r.id AND al.userid=u.id AND al.pdstatus=pds.id AND al.prnumber='$args{pd}' AND al.pdstatus <= $args{status} ";
    $sqlcode .= "ORDER BY al.pdstatus,r.precedence, u.lastname, u.firstname";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    my $i=0;
    while (($list[$i]{prnumber},$list[$i]{role},$list[$i]{roleName},$list[$i]{userid},$list[$i]{approvedby},$list[$i]{lastname},$list[$i]{firstname},
            $list[$i]{status},$list[$i]{statusName},$list[$i]{dateapproved},$list[$i]{precedence}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;
    
    return (@list);
}


###################################################################################################################################
sub getPDStatusText {
###################################################################################################################################
    my %args = (
        status => 0,
        @_,
    );
    
    my $sqlcode = "SELECT name FROM $args{schema}.pd_status WHERE id=$args{status}";
    my ($text) = $args{dbh}->selectrow_array($sqlcode);
    
    return ($text);
}


###################################################################################################################################
sub doProcessPDApproval {
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "",
        pdf => "",
        fileName=>"none",
        fileContents=>"",
        @_,
    );
    
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $arrayRef = $args{attachmentSet};
    my @fileSet = ();
    if (defined($arrayRef)) { @fileSet = @$arrayRef; }
    my $sqlcode;
    my $csr;
    my $id = $settings{prnumber};
    my $status = $settings{status};
    my $pdstatus = $settings{status};
    my ($contracttype,$relatedpr,$dept) = $args{dbh}->selectrow_array("SELECT contracttype,relatedpr,deptid FROM $args{schema}.purchase_documents WHERE prnumber='$id'");
    my %retVals;
    $retVals{contracttype} = $contracttype;
    $retVals{relatedpr} = $relatedpr;
    
    eval {
        if ($args{type} eq "approve") {
            my $where = "";
            my $nextStatus = 0;
            my $logText = "";
            if ($pdstatus == 3) {
                my ($isTeamLead) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.approval_list WHERE prnumber='$id' AND " .
                               "pdstatus=$pdstatus AND dateapproved IS NULL AND role=16");
                $where = (($isTeamLead) ? "AND role NOT IN (12, 13)" : "");
                $nextStatus = 4;
                $logText = "PR";
#                $args{pdf} = &doPrintPR(dbh => $args{dbh}, schema => $args{schema}, id => $settings{prnumber}, forDisplay=>'F');
                if ($contracttype == 2) {
                    $nextStatus = 15;
                    $logText = "Blanket Release";
                }
            } elsif ($pdstatus == 6) {
                $nextStatus = 7;
                $logText = "PR Change";
            } elsif ($pdstatus == 8) {
                $nextStatus = 9;
                $logText = "RFP";
            } elsif ($pdstatus == 14) {
                $nextStatus = 15;
                $logText = "PO";
            } elsif ($pdstatus == 13) {
                $nextStatus = 15;
                my %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$id);
                my $allReceived = 'T';
                for (my $i=0; $i<$pd{itemCount}; $i++) {
                    if ($pd{items}[$i]{quantity} != $pd{items}[$i]{quantityreceived}) {$allReceived = 'F';}
                }
                if ($allReceived eq 'T') {
                    $nextStatus = 18;
                }
                $logText = "PO Amendment";
            }
            my $purchaserOveride = "1=2";
            if (($pdstatus == 8 || $pdstatus == 13 || $pdstatus == 14) && &doesUserHaveRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[6, 21])) {
                $purchaserOveride = "1=1";
            }
            $sqlcode = "UPDATE $args{schema}.approval_list SET dateapproved=SYSDATE, approvedby=$args{userID} WHERE prnumber='$id' AND pdstatus=$pdstatus AND ";
            $sqlcode .= "dateapproved IS NULL AND ";
            $sqlcode .= "(userid=$args{userID} OR userid||'-'||role IN (SELECT ur.userid||'-'||ur.role FROM $args{schema}.user_roles ur, $args{schema}.departments d ";
            $sqlcode .= "WHERE ur.site=d.site AND delegatedto=$args{userID} AND delegationstart<=SYSDATE AND (delegationstop+1) >=SYSDATE) OR $purchaserOveride) $where";
#print STDERR "\n$sqlcode\n\n";
            $args{dbh}->do($sqlcode);
            
            $retVals{nextStatus} = $nextStatus;
            $retVals{logText} = $logText;
            
#            $sqlcode = "SELECT count(*) FROM $args{schema}.approval_list WHERE prnumber='$id' AND pdstatus=$pdstatus AND dateapproved IS NULL";
#            my ($remaining) = $args{dbh}->selectrow_array($sqlcode);
#            if ($remaining == 0) {
#                $sqlcode = "UPDATE $args{schema}.purchase_documents SET status=$nextStatus ";
#                if ($pdstatus == 3) {
#                    $sqlcode .= ", prdate=SYSDATE ";
#                }
#                if ($pdstatus == 14 || $contracttype == 2) {
#                    $sqlcode .= ", podate=SYSDATE ";
#                }
#                if ($contracttype == 2) {
#                    my %rPD = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$relatedpr);
#                    my $blanketRelease = &getNextBRSeq(dbh=>$args{dbh}, schema=>$args{schema}, ponumber=>$rPD{ponumber});
#                    $sqlcode .= ", ponumber = '$blanketRelease', fob=$rPD{fob}, paymentterms='$rPD{paymentterms}' ";
#                }
#                $sqlcode .= "WHERE prnumber='$id'";
##print STDERR "\n$sqlcode\n\n";
#                $args{dbh}->do($sqlcode);
#                if ($args{pdf} gt "") {
#                    $sqlcode = "INSERT INTO $args{schema}.archive (prnumber, pdf, datearchived, description) VALUES ('$id', :pdf, SYSDATE, '$logText approved')";
#                    my $csr = $args{dbh}->prepare($sqlcode);
#                    $csr -> bind_param (":pdf", $args{pdf}, {ora_type => ORA_BLOB, ora_field => 'pdf'});
#                    $csr->execute;
#                }
#                if ($pdstatus == 14 || $pdstatus == 13) {
#                    my $change = 'PO ' . (($pdstatus == 13) ? "Amendment " : "") . 'Approved';
#                    &addPDHistory(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, pd => $id,
#                          archiveDescription => $change, changes => $change);
#                }
#                if ($pdstatus == 3) {
#                    my $change = 'PR ' . (($contracttype == 2) ? "/ Blanket Release " : "") . 'Approved';
#                    &addPDHistory(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, pd => $id,
#                          archiveDescription => $change, changes => $change);
#                }
#            }
        } else {
            my $prevStatus = 0;
            if ($pdstatus == 3) {
                $prevStatus = 2;
            } elsif ($pdstatus == 6) {
                $prevStatus = 5;
            } elsif ($pdstatus == 8) {
                $prevStatus = 7;
            } elsif ($pdstatus == 14) {
                $prevStatus = 11;
            } elsif ($pdstatus == 13) {
                $prevStatus = 16;
            }
            $sqlcode = "DELETE FROM $args{schema}.approval_list WHERE prnumber='$id' AND pdstatus=$pdstatus";
            $args{dbh}->do($sqlcode);
            $sqlcode = "UPDATE $args{schema}.purchase_documents SET status=$prevStatus WHERE prnumber='$id'";
            $args{dbh}->do($sqlcode);
        }
        
        if ($pdstatus ==3) {
# Update chargenumber, justification, attachments
            $sqlcode = "UPDATE $args{schema}.purchase_documents SET ";
            $sqlcode .= "chargenumber = '$settings{chargenumber}', ";
            $sqlcode .= "justification = :justification ";
            $sqlcode .= " WHERE prnumber = '$id'";
            $csr = $args{dbh}->prepare($sqlcode);
            $settings{justification} =~ s/\n\s*\n/\n\n/g;
            $settings{justification} =~ s/\n*\Z//g;
            $csr -> bind_param (":justification", $settings{justification}, {ora_type => ORA_CLOB, ora_field => 'justification'});
            $status = $csr->execute;
            $csr->finish;

# attachments
            if (defined($args{fileName}) && $args{fileName} ne 'none' && $args{fileName} gt ' ') {
                my ($displayedpo, $editablepo) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'attachmentpoflag', status=>$settings{oldstatus});
                my $name = $args{fileName};
                $name =~ s/\\/\//g;
                $name = substr($name, (rindex($name, '/') + 1));
                $sqlcode = "INSERT INTO $args{schema}.attachments (id, prnumber, filename, data, pr, rfp, po) VALUES ($args{schema}.attachments_id.NEXTVAL, ";
                $sqlcode .= "'$id', '$name', :data, ";
#print STDERR "\nEditablepo: $editablepo, Status: $settings{status}, OldStatus: $settings{oldstatus}\n\n";
                if ($editablepo) {
                    $sqlcode .= "'F', 'F', 'T')";
                } else {
                    #$sqlcode .= "'T', 'F', 'F')";
                    $sqlcode .= "'T', 'T', 'T')";
                }
                $csr = $args{dbh}->prepare($sqlcode);
                $csr -> bind_param (":data", $args{fileContents}, {ora_type => ORA_BLOB, ora_field => 'data'});
                $status = $csr->execute;
                $csr->finish;
            }
            for (my $i=0; $i <= $settings{newattachmentcount}; $i++) {
#print STDERR "\n2 - $i, $fileSet[$i]{fileName}\n";
                if (defined($fileSet[$i]{fileName}) && $fileSet[$i]{fileName} ne 'none' && $fileSet[$i]{fileName} gt ' ') {
                    my ($displayedpo, $editablepo) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'attachmentpoflag', status=>$settings{oldstatus});
                    my $name = $fileSet[$i]{fileName};
                    $name =~ s/\\/\//g;
                    $name = substr($name, (rindex($name, '/') + 1));
                    $sqlcode = "INSERT INTO $args{schema}.attachments (id, prnumber, filename, data, pr, rfp, po) VALUES ($args{schema}.attachments_id.NEXTVAL, ";
                    $sqlcode .= "'$id', '$name', :data, ";
#print STDERR "\nEditablepo: $editablepo, Status: $settings{status}, OldStatus: $settings{oldstatus}\n\n";
                    if ($editablepo) {
                        $sqlcode .= "'F', 'F', 'T')";
                    } else {
                        #$sqlcode .= "'T', 'F', 'F')";
                        $sqlcode .= "'T', 'T', 'T')";
                    }
                    $csr = $args{dbh}->prepare($sqlcode);
                    $csr -> bind_param (":data", $fileSet[$i]{fileContents}, {ora_type => ORA_BLOB, ora_field => 'data'});
                    $status = $csr->execute;
                    $csr->finish;
                }
            }
            for (my $i=0; $i <= $settings{attachmentcount}; $i++) {
                if ($settings{attachments}[$i]{removeFlag} eq 'T') {
                    $sqlcode = "DELETE FROM $args{schema}.attachments WHERE id=$settings{attachments}[$i]{id}";
                } else {
                    $sqlcode = "UPDATE $args{schema}.attachments SET rfp='$settings{attachments}[$i]{rfp}', po='$settings{attachments}[$i]{po}'";
                    $sqlcode .= " WHERE id=$settings{attachments}[$i]{id}";
                }
                $args{dbh}->do($sqlcode);
            }
        }

        if ($settings{remarks} gt ' ') {
            $sqlcode = "INSERT INTO $args{schema}.remarks (prnumber, userid, dateentered, text) VALUES ('$id', $args{userID}, SYSDATE, ";
            $sqlcode .= ":text)";
#print STDERR "\n$sqlcode\n\n";
            my $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":text", $settings{remarks}, {ora_type => ORA_CLOB, ora_field => 'text'});
            $csr->execute;
            $csr->finish;
        }
        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }
    
    
    #return (1);
    return (%retVals);
}


###################################################################################################################################
sub doProcessPDApprovalPart2 {
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "",
        pdf => "",
        @_,
    );
    
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $id = $settings{prnumber};
    my $status = $settings{status};
    my $pdstatus = $settings{status};
    #my ($contracttype,$relatedpr,$dept) = $args{dbh}->selectrow_array("SELECT contracttype,relatedpr,deptid FROM $args{schema}.purchase_documents WHERE prnumber='$id'");
    my $contracttype = $settings{retVals}{contracttype};
    my $relatedpr = $settings{retVals}{relatedpr};
    my $nextStatus = $settings{retVals}{nextStatus};
    my $logText = $settings{retVals}{logText};
    
    eval {
            $sqlcode = "SELECT count(*) FROM $args{schema}.approval_list WHERE prnumber='$id' AND pdstatus=$pdstatus AND dateapproved IS NULL";
            my ($remaining) = $args{dbh}->selectrow_array($sqlcode);
            if ($remaining == 0) {
                $sqlcode = "UPDATE $args{schema}.purchase_documents SET status=$nextStatus ";
                if ($pdstatus == 3) {
                    $sqlcode .= ", prdate=SYSDATE ";
                }
                if ($pdstatus == 14 || $contracttype == 2) {
                    $sqlcode .= ", podate=SYSDATE ";
                }
                if ($contracttype == 2) {
                    my %rPD = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$relatedpr);
                    my $blanketRelease = &getNextBRSeq(dbh=>$args{dbh}, schema=>$args{schema}, ponumber=>$rPD{ponumber});
                    $sqlcode .= ", ponumber = '$blanketRelease', fob=$rPD{fob}, paymentterms='$rPD{paymentterms}' ";
                }
                $sqlcode .= "WHERE prnumber='$id'";
#print STDERR "\n$sqlcode\n\n";
                $args{dbh}->do($sqlcode);
                if ($args{pdf} gt "") {
                    $sqlcode = "INSERT INTO $args{schema}.archive (prnumber, pdf, datearchived, description) VALUES ('$id', :pdf, SYSDATE, '$logText approved')";
                    my $csr = $args{dbh}->prepare($sqlcode);
                    $csr -> bind_param (":pdf", $args{pdf}, {ora_type => ORA_BLOB, ora_field => 'pdf'});
                    $csr->execute;
                }
                if ($pdstatus == 14 || $pdstatus == 13) {
                    my $change = 'PO ' . (($pdstatus == 13) ? "Amendment " : "") . 'Approved';
                    &addPDHistory(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, pd => $id,
                          archiveDescription => $change, changes => $change);
                }
                if ($pdstatus == 3) {
                    my $change = 'PR ' . (($contracttype == 2) ? "/ Blanket Release " : "") . 'Approved';
                    &addPDHistory(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, pd => $id,
                          archiveDescription => $change, changes => $change);
                }
            }
        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }
    
    
    return (1);
}


###################################################################################################################################
sub getMimeType {  # routine to get a mime type from a file name
###################################################################################################################################
    my %args = (
        name => 'test.txt',
        @_,
    );
    my $mimeType = "";
    my $fileType = lc(substr($args{name}, (rindex($args{name}, '.') + 1)));
    ($mimeType) = $args{dbh}->selectrow_array("SELECT mimetype FROM $args{schema}.mimetypes WHERE filetype='$fileType'");

    return ($mimeType);
}


###################################################################################################################################
sub getAttachmentInfo {  # routine to get attachment info
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    $args{dbh}->{LongTruncOk} = 0;
    my %at = ();
    my $sqlcode = "SELECT id, prnumber, filename, data, pr, rfp, po FROM $args{schema}.attachments WHERE id=$args{id}";
    ($at{id}, $at{prnumber}, $at{filename}, $at{data}, $at{pr}, $at{rfp}, $at{po}) = $args{dbh}->selectrow_array($sqlcode);
    $at{mimeType} = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>$at{filename});

    return (%at);
}


###################################################################################################################################
sub doProcessPRCopy {
###################################################################################################################################
    my %args = (
        userID => 0,
        oldPR => "",
        deptID => 0,
        @_,
    );
    my $sqlcode;
    my $status = 0;
    my $id;
    my $dateFormat = "DD/MM/YYYY-HH24:MI:SS";
    my ($changeDate) = $args{dbh}->selectrow_array ("SELECT TO_CHAR(SYSDATE, '$dateFormat') FROM dual");
    my $csr;
    
    eval {
        my %oldPD = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$args{oldPR});
        my %newPD = &createBlankPD(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, deptID => $args{deptID});
        
        $id = &getNextPRSeq(dbh => $args{dbh}, schema => $args{schema}, dept => $args{deptID});
        
        $newPD{briefdescription} = $oldPD{briefdescription};
        $newPD{justification} = $oldPD{justification};
        $newPD{solesource} = $oldPD{solesource};
        $newPD{ssjustification} = $oldPD{ssjustification};

        $sqlcode = "INSERT INTO $args{schema}.purchase_documents (prnumber,priority,daterequired,author,requester,briefdescription,justification, ";
        $sqlcode .= "solesource,ssjustification,status,deptid,chargenumber,shipping,taxexempt,tax) ";
        $sqlcode .= "VALUES ('$id','$newPD{priority}',TO_DATE('$newPD{daterequired}', 'MM/DD/YYYY'), $newPD{author}, ";
        $sqlcode .= "$newPD{requester}, " . $args{dbh}->quote($newPD{briefdescription}) . ", :justification, '$newPD{solesource}', ";
        $sqlcode .= (($newPD{solesource} eq 'T') ? ":ssjustification, " : "NULL, ");
        $sqlcode .= "1, $newPD{deptid}, '$newPD{chargenumber}', $newPD{shipping}, '$newPD{taxexempt}', $newPD{tax})";
            
#print STDERR "\n$sqlcode\n\n";
        my $csr = $args{dbh}->prepare($sqlcode);
        $csr -> bind_param (":justification", $newPD{justification}, {ora_type => ORA_CLOB, ora_field => 'justification'});
        if ($newPD{solesource} eq 'T') {
            $csr -> bind_param (":ssjustification", $newPD{ssjustification}, {ora_type => ORA_CLOB, ora_field => 'ssjustification'});
        }
        $status = $csr->execute;
        $csr->finish;
        
        $sqlcode = "INSERT INTO $args{schema}.items (prnumber, itemnumber, description, partnumber, quantity, unitofissue, ";
        $sqlcode .= "unitprice, ishazmat, type, ec, substituteok, techinspection) (SELECT '$id', itemnumber, description, partnumber, quantity, ";
        $sqlcode .= "unitofissue, unitprice, ishazmat, type, ec, substituteok, techinspection FROM $args{schema}.items WHERE prnumber='$oldPD{prnumber}')";
        
#print STDERR "\n$sqlcode\n\n";
        $args{dbh}->do($sqlcode);
        
        $sqlcode = "INSERT INTO $args{schema}.vendor_list (prnumber, vendor) (SELECT '$id', vendor ";
        $sqlcode .= "FROM $args{schema}.vendor_list WHERE prnumber='$oldPD{prnumber}')";
        
        $args{dbh}->do($sqlcode);
        
        $sqlcode = "INSERT INTO $args{schema}.attachments (id, prnumber, filename, data, pr) (SELECT $args{schema}.attachments_id.NEXTVAL, ";
        $sqlcode .= "'$id', filename, data, pr FROM $args{schema}.attachments WHERE prnumber='$oldPD{prnumber}')";
        
        $args{dbh}->do($sqlcode);
        
# questions
        $args{dbh}->do("DELETE FROM $args{schema}.question_list WHERE prnumber='$id'");
        for (my $i=0; $i < $newPD{questionCount}; $i++) {
            # insert
            $sqlcode = "INSERT INTO $args{schema}.question_list (prnumber, precedence, answer, role, text) ";
            $sqlcode .= "VALUES ('$id', $newPD{questionList}[$i]{precedence}, $newPD{questionList}[$i]{answer}, ";
            $sqlcode .= "$newPD{questionList}[$i]{role}, :text)";
print STDERR "\n$sqlcode\n\n";
            $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":text", $newPD{questionList}[$i]{text});
            $status = $csr->execute;
            $csr->finish;
        }
        

        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$id);
}


###################################################################################################################################
sub doProcessAcceptPRforRFP {
###################################################################################################################################
    my %args = (
        userID => 0,
        pd => '',
        @_,
    );
    my $sqlcode;
    
    eval {
        my %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{pd});
        my ($site) = $args{dbh}->selectrow_array("SELECT site FROM $args{schema}.departments WHERE id=$pd{deptid}");
        
        $sqlcode = "UPDATE $args{schema}.purchase_documents SET buyer=$args{userID}, status=7 WHERE prnumber='$args{pd}'";
        $args{dbh}->do($sqlcode);
        
        $sqlcode = "INSERT INTO $args{schema}.clause_list (prnumber, precedence, type, rfp, po, clause) (SELECT '$args{pd}', ";
        $sqlcode .= "r.nvalue1, r.cvalue1, 'T', NVL(r.cvalue2,'F'), c.description||'\n'||c.text FROM $args{schema}.rules r, $args{schema}.clauses c WHERE r.type=4 AND ";
        $sqlcode .= "r.site=$site AND c.id=r.nvalue2)";
#print STDERR "\n$sqlcode\n\n";
        $args{dbh}->do($sqlcode);
        
        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
sub doProcessAcceptPO {
###################################################################################################################################
    my %args = (
        userID => 0,
        pd => '',
        @_,
    );
    my $sqlcode;
    
    eval {
        my %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{pd});
        my ($site) = $args{dbh}->selectrow_array("SELECT site FROM $args{schema}.departments WHERE id=$pd{deptid}");
        my ($lastClause) = $args{dbh}->selectrow_array("SELECT MAX(precedence)+100 FROM $args{schema}.clause_list WHERE prnumber='$args{pd}'");
        
        $sqlcode = "UPDATE $args{schema}.purchase_documents SET buyer=$args{userID}WHERE prnumber='$args{pd}'";
        $args{dbh}->do($sqlcode);
        
#print STDERR "########## Got here 3\n";
        if (!defined($pd{amendment}) || $pd{amendment} eq "") {
            if ($pd{contracttype} == 1) {
                $sqlcode = "INSERT INTO $args{schema}.clause_list (prnumber, precedence, type, po, clause) (SELECT '$args{pd}', ";
                $sqlcode .= "r.nvalue1+$lastClause, r.cvalue1, 'T', c.description||'\n'||c.text FROM $args{schema}.rules r, $args{schema}.clauses c WHERE r.type=9 AND ";
                $sqlcode .= "r.site=$site AND c.id=r.nvalue2)";
#print STDERR "\n$sqlcode\n\n";
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

    return (1);
}


###################################################################################################################################
sub doProcessRFPUpdate {  # routine to update an rfp
###################################################################################################################################
    my %args = (
        userID => 0,
        fileName=>"none",
        fileContents=>"",
        pdf=>"",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $arrayRef = $args{attachmentSet};
    my @fileSet = (defined($arrayRef)) ? @$arrayRef : ({"test" => "test"});
    my $sqlcode;
    my $status = 0;
    my $id;
    my $dateFormat = "DD/MM/YYYY-HH24:MI:SS";
    my ($changeDate) = $args{dbh}->selectrow_array ("SELECT TO_CHAR(SYSDATE, '$dateFormat') FROM dual");
    my $csr;
    
    eval {
        $id = $settings{prnumber};
## top
        if ($settings{status} == 7 || $settings{status} == 8) {
            $sqlcode = "UPDATE $args{schema}.purchase_documents SET ";
            $sqlcode .= "status = $settings{status}, ";
            $sqlcode .= "fob = $settings{fob}, ";
            $sqlcode .= "rfpdeliverdays = $settings{rfpdeliverdays}, ";
            $sqlcode .= "rfpdaysvalid = $settings{rfpdaysvalid}, ";
            $sqlcode .= "rfpduedate = TO_DATE('$settings{rfpduedate}', 'MM/DD/YYYY') ";
#            $sqlcode .= " = '$settings{}', ";
            $sqlcode .= "WHERE prnumber = '$id'";
#print STDERR "\n$sqlcode\n\n";
            $csr = $args{dbh}->prepare($sqlcode);
            $status = $csr->execute;
            $csr->finish;

## clauses
            $args{dbh}->do("DELETE FROM $args{schema}.clause_list WHERE prnumber='$id'");
            for (my $i=1; $i <= $settings{clausecount}; $i++) {
                if ($settings{clauses}[$i]{removeflag} eq 'F') {
                    # insert
                    $sqlcode = "INSERT INTO $args{schema}.clause_list (prnumber, precedence, type, rfp, clause) ";
                    $sqlcode .= "VALUES ('$id', $settings{clauses}[$i]{precedence}, '$settings{clauses}[$i]{type}', 'T', :clause)";
#print STDERR "\n$sqlcode\n\n";
                    $csr = $args{dbh}->prepare($sqlcode);
                    $csr -> bind_param (":clause", $settings{clauses}[$i]{clause}, {ora_type => ORA_CLOB, ora_field => 'clause'});
                    $status = $csr->execute;
                    $csr->finish;
                }
            }

## attachments
            if (defined($args{fileName}) && $args{fileName} ne 'none' && $args{fileName} gt ' ') {
                my $name = $args{fileName};
                $name =~ s/\\/\//g;
                $name = substr($name, (rindex($name, '/') + 1));
                $sqlcode = "INSERT INTO $args{schema}.attachments (id, prnumber, filename, data, pr, rfp, po) VALUES ($args{schema}.attachments_id.NEXTVAL, ";
                $sqlcode .= "'$id', '$name', :data, 'F', 'T', 'T')";
                $csr = $args{dbh}->prepare($sqlcode);
#print STDERR "\nName: $name, Len: " . length($args{fileContents}) . ", Cont: " . substr($args{fileContents}, 0,50) . "\n\n";
                $csr -> bind_param (":data", $args{fileContents}, {ora_type => ORA_BLOB, ora_field => 'data'});
                $status = $csr->execute;
                $csr->finish;
            }
            for (my $i=0; $i <= $settings{newattachmentcount}; $i++) {
#print STDERR "\n2 - $i, $fileSet[$i]{fileName}\n";
                if (defined($fileSet[$i]{fileName}) && $fileSet[$i]{fileName} ne 'none' && $fileSet[$i]{fileName} gt ' ') {
                    my ($displayedpo, $editablepo) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'attachmentpoflag', status=>$settings{oldstatus});
                    my $name = $fileSet[$i]{fileName};
                    $name =~ s/\\/\//g;
                    $name = substr($name, (rindex($name, '/') + 1));
                    $sqlcode = "INSERT INTO $args{schema}.attachments (id, prnumber, filename, data, pr, rfp, po) VALUES ($args{schema}.attachments_id.NEXTVAL, ";
                    $sqlcode .= "'$id', '$name', :data, 'F', 'T', 'T')";
                    $csr = $args{dbh}->prepare($sqlcode);
                    $csr -> bind_param (":data", $fileSet[$i]{fileContents}, {ora_type => ORA_BLOB, ora_field => 'data'});
                    $status = $csr->execute;
                    $csr->finish;
                }
            }
            for (my $i=0; $i<$settings{attachmentcount}; $i++) {
                $sqlcode = "UPDATE $args{schema}.attachments SET rfp='$settings{attachments}[$i]{rfp}' ";
                $sqlcode .= "WHERE id=$settings{attachments}[$i]{id}";
                $args{dbh}->do($sqlcode);
            }
        }
        if ($settings{status} == 9 || $settings{status} == 10) {
            if ($settings{status}== 10) {
                $args{dbh}->do("UPDATE $args{schema}.purchase_documents SET status=10 WHERE prnumber='$id'");
            }
                my $vendRef = $settings{vendorList};
                my @vendors = @$vendRef;
#print STDERR "\nNumber of vendors: $#vendors\n";
                $args{dbh}->do("DELETE FROM $args{schema}.vendor_list WHERE prnumber='$id'");
                for (my $i=0; $i<=$#vendors; $i++) {
                    $sqlcode = "INSERT INTO $args{schema}.vendor_list (prnumber, vendor) VALUES ('$id', $vendors[$i])";
                    $status = $args{dbh}->do($sqlcode);
                }
        } elsif ($settings{status} == 5) {
            $args{dbh}->do("UPDATE $args{schema}.purchase_documents SET status=5 WHERE prnumber='$id'");
        }

## remarks
        if ($settings{remarks} gt ' ') {
            #$sqlcode = "INSERT INTO $args{schema}.remarks (prnumber, userid, dateentered, text) VALUES ('$id', $args{userID}, TO_DATE('$changeDate', '$dateFormat'), ";
            $sqlcode = "INSERT INTO $args{schema}.remarks (prnumber, userid, dateentered, text) VALUES ('$id', $args{userID}, SYSDATE, ";
            $sqlcode .= ":text)";
#print STDERR "\n$sqlcode\n\n";
            $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":text", $settings{remarks}, {ora_type => ORA_CLOB, ora_field => 'text'});
            $status = $csr->execute;
            $csr->finish;
        }
        
        # create approval list
        &genPDApprovalList(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, pd=>$id, status=>$settings{status}, settings => \%settings);
        
        # archive pdf of rfp
        if ($settings{status} == 10) {
            $sqlcode = "INSERT INTO $args{schema}.archive (prnumber, pdf, datearchived, description) VALUES ('$id', :pdf, SYSDATE, 'RFP Published')";
            $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":pdf", $args{pdf}, {ora_type => ORA_BLOB, ora_field => 'pdf'});
            $status = $csr->execute;
        }


        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$id);
}


###################################################################################################################################
sub addPDHistory {
###################################################################################################################################
    my %args = (
        userID => 0,
        pd => '',
        changes => '',
        archiveDescription => '',
        pdf => '',
        changeDate => '',
        @_,
    );
    my $dateFormat = "MM/DD/YYYY-HH24:MI:SS";
    #my $dateFormat = "YYYYMMDDHH24MISS";
    #my $dateFormat = "MM/DD/YYYY";
    my ($changeDate) = ((defined($args{changeDate}) && $args{changeDate} gt ' ') ? $args{changeDate} : $args{dbh}->selectrow_array ("SELECT TO_CHAR(SYSDATE, '$dateFormat') FROM dual"));
    my ($lastChangeDate) = $args{dbh}->selectrow_array ("SELECT TO_CHAR(MAX(changedate), '$dateFormat') FROM $args{schema}.pd_history WHERE prnumber='$args{pd}'");
    my $initialHistory = ((defined($lastChangeDate) && $lastChangeDate gt ' ') ? 'F' : 'T');
    my $sqlcode = "";
    my $csr;
    
    eval {
        my %pd;
        my %oldPD;
        my $shippingChange = 0.00;
        my $taxChange = 0.00;
        %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$args{pd});
        $shippingChange = ((defined($pd{shipping})) ? $pd{shipping} : 0);
        $taxChange = ((defined($pd{tax})) ? $pd{tax} : 0);
        if ($initialHistory eq 'F') {
            %oldPD = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$args{pd}, history=>'T', date=>$lastChangeDate);
            if ($oldPD{status} >= 15) {
                $shippingChange = ((defined($pd{shipping})) ? $pd{shipping} : 0) - ((defined($oldPD{shipping})) ? $oldPD{shipping} : 0);
                $taxChange = ((defined($pd{tax})) ? $pd{tax} : 0) - ((defined($oldPD{tax})) ? $oldPD{tax} : 0);
            } else {
                $initialHistory = 'T';
            }
        }
        
# pd
        $sqlcode = "INSERT INTO $args{schema}.pd_history (prnumber,ponumber,amendment,priority,daterequested,duedate,author,requester,briefdescription,";
        $sqlcode .= "justification,solesource,ssjustification,status,daterequired,deptid,chargenumber,awardtype,contracttype,taxexempt,tax,";
        $sqlcode .= "shipping,potype,fob,shipvia,paymentterms,buyer,amendedby,vendor,rfpdeliverdays,rfpdaysvalid,rfpduedate,";
        $sqlcode .= "relatedpr,prdate,podate, bidremarks, selectionmemo,enclosures,startdate,enddate,creditcardholder,pdtotal,refnumber,";
        $sqlcode .= "changedate,changes,changedby,shippingchange,taxchange) VALUES ";
        $sqlcode .= "('$pd{prnumber}','$pd{ponumber}'," . ((defined($pd{amendment})) ? "'$pd{amendment}'" : "NULL") . ",";
        $sqlcode .= "'$pd{priority}',TO_DATE('$pd{daterequested}','MM/DD/YYYY'),";
        $sqlcode .= ((defined($pd{dudate}) && $pd{duedate} gt ' ') ? "TO_DATE('$pd{duedate}','MM/DD/YYYY')" : "NULL") . ",";
        $sqlcode .= "$pd{author},$pd{requester},";
        $sqlcode .= $args{dbh}->quote($pd{briefdescription}) . ",";
        $sqlcode .= ":justification,'$pd{solesource}'," . ((defined($pd{ssjustification})) ? ":ssjustification" : "NULL") . ",";
        $sqlcode .= "$pd{status}," . ((defined($pd{daterequired})) ? "TO_DATE('$pd{daterequired}','MM/DD/YYYY')" : "NULL") . ",$pd{deptid},";
        $sqlcode .= "'$pd{chargenumber}',$pd{awardtype},$pd{contracttype},'$pd{taxexempt}',$pd{tax},";
        $sqlcode .= "$pd{shipping},$pd{potype},$pd{fob},". ((defined($pd{shipvia})) ? $args{dbh}->quote($pd{shipvia}) : "NULL") . ",";
        $sqlcode .= ((defined($pd{paymentterms})) ? $args{dbh}->quote($pd{paymentterms}) : "NULL") . ",";
        $sqlcode .= ((defined($pd{buyer})) ? $pd{buyer} : "NULL") . ",";
        $sqlcode .= ((defined($pd{amendedby})) ? $pd{amendedby} : "NULL") . ",";
        $sqlcode .= ((defined($pd{vendor})) ? $pd{vendor} : "NULL") . ",";
        $sqlcode .= ((defined($pd{rfpdeliverdays})) ? "$pd{rfpdeliverdays}" : "NULL") . ",";
        $sqlcode .= ((defined($pd{rfpdaysvalid})) ? "$pd{rfpdaysvalid}" : "NULL") . ",";
        $sqlcode .= ((defined($pd{rfpduedate})) ? "TO_DATE('$pd{rfpduedate}','MM/DD/YYYY')" : "NULL") . ",";
        $sqlcode .= ((defined($pd{relatedpr})) ? "'$pd{relatedpr}'" : "NULL") . ",TO_DATE('$pd{prdate}','MM/DD/YYYY'),";
        $sqlcode .= ((defined($pd{podate})) ? "TO_DATE('$pd{podate}','MM/DD/YYYY')" : "NULL") . ", :bidremarks, ";
        $sqlcode .= ((defined($pd{selectionmemo})) ? ":selectionmemo" : "NULL") . ",";
        $sqlcode .= ((defined($pd{enclosures})) ? ":enclosures" : "NULL") . ",";
        $sqlcode .= ((defined($pd{startdate})) ? "TO_DATE('$pd{startdate}','MM/DD/YYYY')" : "NULL") . ",";
        $sqlcode .= ((defined($pd{enddate})) ? "TO_DATE('$pd{enddate}','MM/DD/YYYY')" : "NULL") . ",";
        $sqlcode .= ((defined($pd{creditcardholder})) ? $pd{creditcardholder} : "NULL") . ", ";
        $sqlcode .= "$pd{pdtotal},";
        $sqlcode .= ((defined($pd{refnumber})) ? "'$pd{refnumber}'" : "NULL") . ", ";
        $sqlcode .= "TO_DATE('$changeDate', '$dateFormat'), ";
        $sqlcode .= $args{dbh}->quote($args{changes}) . ", $args{userID}, $shippingChange, $taxChange)";
        
#print STDERR "$sqlcode\n";
        $csr = $args{dbh}->prepare($sqlcode);
        $csr -> bind_param (":justification", $pd{justification}, {ora_type => ORA_CLOB, ora_field => 'justification'});
        if (defined($pd{ssjustification})) {
            $csr -> bind_param (":ssjustification", $pd{ssjustification}, {ora_type => ORA_CLOB, ora_field => 'ssjustification'});
        }
        $csr -> bind_param (":bidremarks", $pd{bidremarks}, {ora_type => ORA_CLOB, ora_field => 'bidremarks'});
        if (defined($pd{selectionmemo})) {
            $csr -> bind_param (":selectionmemo", $pd{selectionmemo}, {ora_type => ORA_CLOB, ora_field => 'selectionmemo'});
        }
        if (defined($pd{enclosures})) {
            $csr -> bind_param (":enclosures", $pd{enclosures}, {ora_type => ORA_CLOB, ora_field => 'enclosures'});
        }
        my $status = $csr->execute;
        
# items
        my $oldItemCount = (($initialHistory eq 'F') ? ((defined($oldPD{itemCount})) ? $oldPD{itemCount} : 0) : 0);
        my $newItemCount = $pd{itemCount};
        my $itemCount = (($newItemCount >= $oldItemCount) ? $newItemCount : $oldItemCount);
        for (my $i=0; $i<$itemCount; $i++) {
            my $priceChange = 0.00;
            my $description = " ";
            $sqlcode = "INSERT INTO $args{schema}.item_history (prnumber, itemnumber, description, partnumber, quantity, ";
            $sqlcode .= "unitofissue, unitprice, substituteok, techinspection, ishazmat, type, ec, quantityreceived, changedate,pricechange,changes) VALUES ";
            if ($initialHistory eq 'F' && $i < $newItemCount && $i < $oldItemCount) {
                $priceChange = ($pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice}) - ($oldPD{items}[$i]{quantity} * $oldPD{items}[$i]{unitprice});
                $description = $pd{items}[$i]{description};
                $sqlcode .= "('$args{pd}', $pd{items}[$i]{itemnumber},:description, '";
                $sqlcode .= ((defined($pd{items}[$i]{partnumber})) ? $pd{items}[$i]{partnumber} : "");
                $sqlcode .= "',$pd{items}[$i]{quantity},";
                $sqlcode .= "'" . ((defined($pd{items}[$i]{unitofissue})) ? $pd{items}[$i]{unitofissue} : "") . "',$pd{items}[$i]{unitprice},'$pd{items}[$i]{substituteok}','$pd{items}[$i]{techinspection}','$pd{items}[$i]{ishazmat}',";
                $sqlcode .= "$pd{items}[$i]{type},'" . ((defined($pd{items}[$i]{ec})) ? $pd{items}[$i]{ec} : "") . "',$pd{items}[$i]{quantityreceived}, TO_DATE('$changeDate','$dateFormat'),";
                $sqlcode .= "$priceChange, " . $args{dbh}->quote($args{changes}) . ")";
            } elsif ($initialHistory eq 'F' && $i < $newItemCount && $i >= $oldItemCount) {
                $priceChange = ($pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice});
                $description = $pd{items}[$i]{description};
                $sqlcode .= "('$args{pd}', $pd{items}[$i]{itemnumber},:description, '$pd{items}[$i]{partnumber}',$pd{items}[$i]{quantity},";
                $sqlcode .= "'$pd{items}[$i]{unitofissue}',$pd{items}[$i]{unitprice},'$pd{items}[$i]{substituteok}','$pd{items}[$i]{techinspection}','$pd{items}[$i]{ishazmat}',";
                $sqlcode .= "$pd{items}[$i]{type},'$pd{items}[$i]{ec}',$pd{items}[$i]{quantityreceived}, TO_DATE('$changeDate','$dateFormat'),";
                $sqlcode .= "$priceChange, " . $args{dbh}->quote($args{changes}) . ")";
            } elsif ($initialHistory eq 'F' && $i >= $newItemCount && $i < $oldItemCount) {
                $priceChange = 0.00 - ($oldPD{items}[$i]{quantity} * $oldPD{items}[$i]{unitprice});
                $description = "Removed";
                my $newItemExists = 'F';
                for (my $k=0; $k<$newItemCount; $k++) {
                    if ($oldPD{items}[$i]{itemnumber} eq $pd{items}[$k]{itemnumber}) {$newItemExists = 'T';}
                }
                my $itemNumber = (($newItemExists eq 'T') ? ($oldPD{items}[$i]{itemnumber} + 5000) : $oldPD{items}[$i]{itemnumber});
                $sqlcode .= "('$args{pd}', $itemNumber,:description, NULL,0,";
                $sqlcode .= "'" . ((defined($oldPD{items}[$i]{unitofissue})) ? $oldPD{items}[$i]{unitofissue} : "") . "',0,'$oldPD{items}[$i]{substituteok}','$oldPD{items}[$i]{techinspection}','$oldPD{items}[$i]{ishazmat}',";
                $sqlcode .= "$oldPD{items}[$i]{type},'" . ((defined($oldPD{items}[$i]{ec})) ? $oldPD{items}[$i]{ec} : "") . "',0, TO_DATE('$changeDate','$dateFormat'),";
                $sqlcode .= "$priceChange, " . $args{dbh}->quote($args{changes}) . ")";
            } else {
                $priceChange = ($pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice});
                $description = $pd{items}[$i]{description};
                $sqlcode .= "('$args{pd}', $pd{items}[$i]{itemnumber},:description, '$pd{items}[$i]{partnumber}',$pd{items}[$i]{quantity},";
                $sqlcode .= "'$pd{items}[$i]{unitofissue}',$pd{items}[$i]{unitprice},'$pd{items}[$i]{substituteok}','$pd{items}[$i]{techinspection}','$pd{items}[$i]{ishazmat}',";
                $sqlcode .= "$pd{items}[$i]{type},'$pd{items}[$i]{ec}',$pd{items}[$i]{quantityreceived}, TO_DATE('$changeDate','$dateFormat'),";
                $sqlcode .= "$priceChange, " . $args{dbh}->quote($args{changes}) . ")";
            }
#print STDERR "$sqlcode\n";
            $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":description", $description, {ora_type => ORA_CLOB, ora_field => 'description'});
            my $status = $csr->execute;
            $csr->finish;
        }
        
# charge distribution
        my $oldCDCount = ((defined($oldPD{chargedistlistCount})) ? $oldPD{chargedistlistCount} : 0);
        my $newCDCount = $pd{chargedistlistCount};
        for (my $i=0; $i<$newCDCount; $i++) {
            #my $amountChange = 0.00;
            my $amountChange = $pd{chargedistlist}[$i]{amount};
            $sqlcode = "INSERT INTO $args{schema}.po_cn_history (prnumber, chargenumber, ec, amount, invoiced, changedate, changeamount) VALUES ";
            if ($initialHistory eq 'F') {
                my $key = "$pd{chargedistlist}[$i]{chargenumber} - $pd{chargedistlist}[$i]{ec}";
                $amountChange = $pd{chargedistlist}[$i]{amount} - ((defined($oldPD{chargedisthash}{"$key"}{amount})) ? $oldPD{chargedisthash}{"$key"}{amount} : 0);
                $sqlcode .= "('$args{pd}', '$pd{chargedistlist}[$i]{chargenumber}', '$pd{chargedistlist}[$i]{ec}', $pd{chargedistlist}[$i]{amount}, ";
                $sqlcode .= "$pd{chargedistlist}[$i]{invoiced}, TO_DATE('$changeDate', '$dateFormat'), $amountChange)";
            } else {
                $sqlcode .= "('$args{pd}', '$pd{chargedistlist}[$i]{chargenumber}', '$pd{chargedistlist}[$i]{ec}', $pd{chargedistlist}[$i]{amount}, ";
                $sqlcode .= "$pd{chargedistlist}[$i]{invoiced}, TO_DATE('$changeDate', '$dateFormat'), $amountChange)";
            }
#print STDERR "\n $sqlcode\n\n";
            $args{dbh}->do($sqlcode);
        }
        for (my $i=0; $i<$oldCDCount; $i++) {
            my $amountChange = 0.00;
            $sqlcode = "INSERT INTO $args{schema}.po_cn_history (prnumber, chargenumber, ec, amount, invoiced, changedate, changeamount) VALUES ";
            my $key = "$oldPD{chargedistlist}[$i]{chargenumber} - $oldPD{chargedistlist}[$i]{ec}";
            if (!defined($pd{chargedisthash}{"$key"})) {
                $amountChange = 0.0 - $oldPD{chargedistlist}[$i]{amount};
                $sqlcode .= "('$args{pd}', '$oldPD{chargedistlist}[$i]{chargenumber}', '$oldPD{chargedistlist}[$i]{ec}', 0.0, ";
                $sqlcode .= "$oldPD{chargedistlist}[$i]{invoiced}, TO_DATE('$changeDate', '$dateFormat'), $amountChange)";
#print STDERR "\n $sqlcode\n\n";
                $args{dbh}->do($sqlcode);
            }
        }

# archive
        if ($args{archiveDescription} gt ' ' && $args{pdf} gt ' ') {
            $sqlcode = "INSERT INTO $args{schema}.archive (prnumber, pdf, datearchived, description) VALUES ('$args{pd}', :pdf, SYSDATE, '$args{archiveDescription}')";
            $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":pdf", $args{pdf}, {ora_type => ORA_BLOB, ora_field => 'pdf'});
            my $status = $csr->execute;
            $csr->finish;
        }

        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
sub getNextPOSeq {  # routine to get the next available PO number
###################################################################################################################################
    my %args = (
        dept => 0,
        @_,
    );

#print STDERR "\nSELECT d.site, d.groupcode,si.sitecode,si.companycode  FROM $args{schema}.departments d, $args{schema}.site_info si WHERE d.site=si.id AND d.id=$args{dept}\n\n";
    my ($site, $group, $sitecode, $companycode) = $args{dbh}->selectrow_array("SELECT d.site, d.groupcode,si.sitecode,si.companycode " .
                         "FROM $args{schema}.departments d, $args{schema}.site_info si WHERE d.site=si.id AND d.id=$args{dept}");
    my $fy = &getFY();
    my $prnumber = '';
    my $seqName = $sitecode . "_POSEQ_" . $fy;
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
    my $ponumber = $fy . $companycode . $sitecode . lpadzero($seqNumber, 3);
    $ponumber =~ s/ //g;

    return ($ponumber);
}


###################################################################################################################################
sub getNextBRSeq {  # routine to get the next available blanket release sequence number
###################################################################################################################################
    my %args = (
        ponumber => '',
        @_,
    );

    my $seqName = "BR_" . $args{ponumber} . "_SEQ";
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
    my $br = $args{ponumber} . "-" . lpadzero($seqNumber, 3);
    $br =~ s/ //g;

    return ($br);
}


###################################################################################################################################
sub getRequesterArray {  # routine to get a list of all requesters for purchase documents
###################################################################################################################################
    my %args = (
        @_,
    );
    my @users;
    my $i=0;
    my $sqlcode = "SELECT id,firstname, lastname FROM $args{schema}.users WHERE id IN (SELECT requester FROM $args{schema}.purchase_documents)";
    $sqlcode .= " ORDER BY lastname, firstname";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (my ($id, $firstname, $lastname) = $csr->fetchrow_array) {
        $users[$i]{id} = $id;
        $users[$i]{firstname} = $firstname;
        $users[$i]{lastname} = $lastname;
        $i++;
    }
    $csr->finish;


    return (@users);
}


###################################################################################################################################
sub getBuyerArray {  # routine to get a list of all buyers for purchase documents
###################################################################################################################################
    my %args = (
        fy => 0,
        @_,
    );
    my @users;
    my $i=0;
    my $where = "";
    $where .= (($args{fy} ne 0) ? " AND ((daterequested>=TO_DATE('10/01/" . ($args{fy} - 1) ."', 'MM/DD/YYYY') AND daterequested<TO_DATE('10/01/" . ($args{fy}) ."', 'MM/DD/YYYY'))"
           .  " OR (podate>=TO_DATE('10/01/" . ($args{fy} - 1) ."', 'MM/DD/YYYY') AND podate<TO_DATE('10/01/" . ($args{fy}) ."', 'MM/DD/YYYY')))" : "");
    my $sqlcode = "SELECT id,firstname, lastname FROM $args{schema}.users WHERE id IN (SELECT buyer FROM $args{schema}.purchase_documents ";
    $sqlcode .= "WHERE id > 0 $where)";
    $sqlcode .= " ORDER BY lastname, firstname";
#print STDERR "\n$sqlcode\n\n";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (my ($id, $firstname, $lastname) = $csr->fetchrow_array) {
        $users[$i]{id} = $id;
        $users[$i]{firstname} = $firstname;
        $users[$i]{lastname} = $lastname;
        $i++;
    }
    $csr->finish;


    return (@users);
}

###################################################################################################################################
sub getBlanketContracts {  # routine to get a list of all blanket contracts
###################################################################################################################################
    my %args = (
        site => 0,
        fy => &getFY(),
        @_,
    );
    my @blankets;
    my $i=0;
    my $where .= (($args{fy} ne 0) ? " AND pd.ponumber LIKE '$args{fy}%'" : "");
    my $sqlcode = "SELECT pd.prnumber,pd.ponumber,pd.vendor,v.name FROM $args{schema}.purchase_documents pd, $args{schema}.vendors v";
    $sqlcode .= " WHERE pd.potype=2 AND (pd.status BETWEEN 16 AND 18) AND pd.vendor=v.id $where";
    $sqlcode .= " ORDER BY pd.ponumber";
#print STDERR "\n$sqlcode\n\n";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (my ($prnumber, $ponumber, $vendor, $vendorname) = $csr->fetchrow_array) {
        $blankets[$i]{prnumber} = $prnumber;
        $blankets[$i]{ponumber} = $ponumber;
        $blankets[$i]{vendor} = $vendor;
        $blankets[$i]{vendorname} = $vendorname;
        $i++;
    }
    $csr->finish;


    return (@blankets);
}


###################################################################################################################################
sub doProcessPlacePO {  # routine to place a PO
###################################################################################################################################
    my %args = (
        userID => 0,
        pdf => '',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    my $id;
    my $csr;
    
    eval {
        $id = $settings{prnumber};
## top
        $sqlcode = "UPDATE $args{schema}.purchase_documents SET status=17 WHERE prnumber='$id'";
        $args{dbh}->do($sqlcode);
## remarks
        if ($settings{remarks} gt ' ') {
            $sqlcode = "INSERT INTO $args{schema}.remarks (prnumber, userid, dateentered, text) VALUES ('$id', $args{userID}, SYSDATE, ";
            $sqlcode .= ":text)";
#print STDERR "\n$sqlcode\n\n";
            $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":text", $settings{remarks}, {ora_type => ORA_CLOB, ora_field => 'text'});
            $status = $csr->execute;
            $csr->finish;
        }

        $status = &addPDHistory(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, pd => $id,
                          archiveDescription => 'PO Placed', changes => 'PO Placed', pdf => $args{pdf});


        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$id);
}


###################################################################################################################################
sub doProcessAmendPO {  # routine to amend a PO
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
    my $csr;
    
    eval {
        $id = $settings{id};

        $sqlcode = "UPDATE $args{schema}.purchase_documents SET status=16, amendment='$args{amendment}', amendedby=$args{userID} WHERE prnumber='$id'";
        $args{dbh}->do($sqlcode);
        if (defined($settings{remarks}) && $settings{remarks} gt ' ') {
            $sqlcode = "INSERT INTO $args{schema}.remarks (prnumber, userid, dateentered, text) VALUES ('$id', $args{userID}, SYSDATE, ";
            $sqlcode .= ":text)";
            $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":text", "Amend PO - \n" . $settings{remarks}, {ora_type => ORA_CLOB, ora_field => 'text'});
            $status = $csr->execute;
            $csr->finish;
        }

        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
sub doProcessChangeVendor {  # routine to amend a PO
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
    my $csr;
    
    eval {
        $id = $settings{id};

        $sqlcode = "UPDATE $args{schema}.purchase_documents SET status=10, amendment='$args{amendment}', amendedby=$args{userID} WHERE prnumber='$id'";
        $args{dbh}->do($sqlcode);
        if (defined($settings{remarks}) && $settings{remarks} gt ' ') {
            $sqlcode = "INSERT INTO $args{schema}.remarks (prnumber, userid, dateentered, text) VALUES ('$id', $args{userID}, SYSDATE, ";
            $sqlcode .= ":text)";
            $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":text", "Amend PO/Change Vendor - \n" . $settings{remarks}, {ora_type => ORA_CLOB, ora_field => 'text'});
            $status = $csr->execute;
            $csr->finish;
        }

        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
sub doProcessAmendRFP {  # routine to amend an RFP
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
    my $csr;
    
    eval {
        $id = $settings{id};

        $sqlcode = "UPDATE $args{schema}.purchase_documents SET status=7 WHERE prnumber='$id'";
        $args{dbh}->do($sqlcode);
        if (defined($settings{remarks}) && $settings{remarks} gt ' ') {
            $sqlcode = "INSERT INTO $args{schema}.remarks (prnumber, userid, dateentered, text) VALUES ('$id', $args{userID}, SYSDATE, ";
            $sqlcode .= ":text)";
            $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":text", "Amend PO - \n" . $settings{remarks}, {ora_type => ORA_CLOB, ora_field => 'text'});
            $status = $csr->execute;
            $csr->finish;
        }

        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
sub doUpdatePDStatus {  # routine to change the status of a PD
###################################################################################################################################
    my %args = (
        userID => 0,
        status => 0,
        remarks => '',
        amendment => '',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    my $id;
    my $csr;
    
    eval {
        $id = $settings{id};

        $sqlcode = "UPDATE $args{schema}.purchase_documents SET status=$args{status}" . 
              ((defined($args{amendment}) && $args{amendment} gt ' ') ? ", amendment='$args{amendment}'" : "") . " WHERE prnumber='$id'";
        $args{dbh}->do($sqlcode);
        
## remarks
        if (defined($args{remarks}) && $args{remarks} gt ' ') {
            $sqlcode = "INSERT INTO $args{schema}.remarks (prnumber, userid, dateentered, text) VALUES ('$id', $args{userID}, SYSDATE, ";
            $sqlcode .= ":text)";
            $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":text", $args{remarks}, {ora_type => ORA_CLOB, ora_field => 'text'});
            $status = $csr->execute;
            $csr->finish;
        }

        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
sub addClause {  # routine to add a clause
###################################################################################################################################
    my %args = (
        pd => 0,
        clause => '',
        precedence => -1,
        @_,
    );
    my $sqlcode;
    my $status = 0;
    my $csr;
    
    eval {
        $sqlcode = "INSERT INTO $args{schema}.clause_list (prnumber, precedence, type, rfp, po, clause) VALUES ('$args{pd}', $args{precedence}, 'H', 'T', 'T', :clause)";
        $csr = $args{dbh}->prepare($sqlcode);
        $csr-> bind_param (":clause", $args{clause}, {ora_type => ORA_CLOB, ora_field => 'clause'});
        my $status = $csr->execute;
        $csr->finish;

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
sub getArchiveList {  # routine to get a list of the archive for a PD
###################################################################################################################################
    my %args = (
        pd => 0,
        @_,
    );
    my $sqlcode;
    my $status = 0;
    my $csr;
    my @pdList;
    my $i = 0;
    
    $sqlcode = "SELECT prnumber, TO_CHAR(datearchived, 'MM/DD/YYYY HH24:MI:SS'), description FROM $args{schema}.archive ";
    $sqlcode .= "WHERE prnumber='$args{pd}' ORDER BY datearchived";
    
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (($pdList[$i]{prnumber}, $pdList[$i]{datearchived}, $pdList[$i]{description}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;

    return (@pdList);
}


###################################################################################################################################
sub addArchive {  # routine to add an archive entry
###################################################################################################################################
    my %args = (
        pd => 0,
        description => '',
        pdf => '',
        @_,
    );
    my $sqlcode;
    my $status = 0;
    my $csr;
    
    eval {
        $sqlcode = "INSERT INTO $args{schema}.archive (prnumber, pdf, datearchived, description) VALUES ('$args{pd}', :pdf, SYSDATE, ";
        $sqlcode .= $args{dbh}->quote($args{description}) . ")";
        $csr = $args{dbh}->prepare($sqlcode);
        $csr -> bind_param (":pdf", $args{pdf}, {ora_type => ORA_BLOB, ora_field => 'pdf'});
        my $status = $csr->execute;
        $csr->finish;

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
sub getArchiveInfo {  # routine to get an archive record
###################################################################################################################################
    my %args = (
        pd => 0,
        date => 0,
        @_,
    );
    my $sqlcode;
    my %arch;
    $args{dbh}->{LongReadLen} = 100000000;
    $args{dbh}->{LongTruncOk} = 0;
    
    $sqlcode = "SELECT prnumber, pdf, TO_CHAR(datearchived, 'MM/DD/YYYY HH24:MI:SS'), description FROM $args{schema}.archive ";
    $sqlcode .= "WHERE prnumber='$args{pd}' AND datearchived=TO_DATE('$args{date}', 'MM/DD/YYYY HH24:MI:SS')";

    ($arch{prnumber}, $arch{pdf}, $arch{datearchived}, $arch{description}) = $args{dbh}->selectrow_array($sqlcode);

    return (%arch);
}


###################################################################################################################################
sub getStatusList {  # routine to get a list of PD status
###################################################################################################################################
    my %args = (
        pd => 0,
        @_,
    );
    my $sqlcode;
    my $status = 0;
    my $csr;
    my @statusList;
    my $i = 0;
    
    $sqlcode = "SELECT id, name FROM $args{schema}.pd_status WHERE name <> 'N/A' ORDER BY name";
    
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (($statusList[$i]{id}, $statusList[$i]{name}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;

    return (@statusList);
}


###################################################################################################################################
sub getCNCommittedList {  # routine to get a list of charge number commited info for selected dates
###################################################################################################################################
    my %args = (
        startDate => '',
        endDate => '',
        siteList => 0,
        @_,
    );
    my $sqlcode;
    my $status = 0;
    my $csr;
    my @cnList;
    my $i = 0;
    
    $sqlcode = "SELECT cnh.prnumber,cnh.chargenumber,cnh.ec,cnh.amount,cnh.invoiced,TO_CHAR(cnh.changedate, 'MM/DD/YYYY-HH24:MI:SS'),";
    $sqlcode .= "cnh.changeamount,pd.ponumber,pd.amendment,pd.vendor,pd.briefdescription,pd.requester,pd.potype,TO_CHAR(pd.podate, 'MM/DD/YYYY'), ";
    $sqlcode .= "pd.deptid, d.name ";
    $sqlcode .= "FROM $args{schema}.po_cn_history cnh, $args{schema}.purchase_documents pd, $args{schema}.departments d, $args{schema}.pd_history pdh ";
    $sqlcode .= "WHERE cnh.prnumber=pd.prnumber AND pd.deptid=d.id AND pd.podate IS NOT NULL AND ";
    $sqlcode .= "cnh.prnumber=pdh.prnumber AND cnh.changedate=pdh.changedate AND pdh.status>=15 AND ";
    $sqlcode .= "cnh.changedate >= TO_DATE('$args{startDate}', 'MM/DD/YYYY') AND cnh.changedate <= TO_DATE('$args{endDate}-23:59:59', 'MM/DD/YYYY-HH24:MI:SS') ";
    $sqlcode .= "AND cnh.changeamount <> 0 ";
    $sqlcode .= (($args{siteList} ne 0) ? "AND d.site IN ($args{siteList}) " : "");
    $sqlcode .= "ORDER BY cnh.chargenumber,pd.ponumber,cnh.ec,cnh.changedate";
    
#print STDERR "\n$sqlcode\n\n";
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (($cnList[$i]{prnumber}, $cnList[$i]{chargenumber}, $cnList[$i]{ec}, $cnList[$i]{amount}, $cnList[$i]{invoiced}, $cnList[$i]{changedate}, 
            $cnList[$i]{changeamount}, $cnList[$i]{ponumber}, $cnList[$i]{amendment}, $cnList[$i]{vendor}, $cnList[$i]{briefdescription}, 
            $cnList[$i]{requester}, $cnList[$i]{potype}, $cnList[$i]{podate}, $cnList[$i]{deptid}, $cnList[$i]{deptname}) = $csr->fetchrow_array) {
        ($cnList[$i]{vendorName}) = $args{dbh}->selectrow_array("SELECT name FROM $args{schema}.vendors WHERE id=$cnList[$i]{vendor}");
        $i++;
    }
    $csr->finish;

    return (@cnList);
}


###################################################################################################################################
sub doProcessCancelPO {  # routine to process data changes for canceling a PO
###################################################################################################################################
    my %args = (
        pd => '',
        @_,
    );
    my $sqlcode;
    my $status = 0;
    
    my %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{pd});
    my ($site) = $args{dbh}->selectrow_array("SELECT site FROM $args{schema}.departments WHERE id=$pd{deptid}");
    
    $sqlcode = "UPDATE $args{schema}.purchase_documents SET tax=0.0, shipping=0.0 WHERE prnumber='$args{pd}'";
    $args{dbh}->do($sqlcode);
    $sqlcode = "UPDATE $args{schema}.items SET quantity=0, unitprice=0.0 WHERE prnumber='$args{pd}'";
    $args{dbh}->do($sqlcode);
    $sqlcode = "UPDATE $args{schema}.po_chargenumbers SET amount=0.0 WHERE prnumber='$args{pd}'";
    $args{dbh}->do($sqlcode);
    $sqlcode = "INSERT INTO $args{schema}.clause_list (prnumber, precedence, type, rfp, po, clause) (SELECT '$args{pd}', ";
    $sqlcode .= "r.nvalue2, r.cvalue1, 'T', 'T', c.description||'\n'||c.text FROM $args{schema}.rules r, $args{schema}.clauses c WHERE r.type=8 AND ";
    $sqlcode .= "r.site=$site AND c.id=r.nvalue1)";

    $args{dbh}->commit;
    
    return (1);
}


###################################################################################################################################
sub doClearApprovals {  # routine to clear approvals for canceling a PD
###################################################################################################################################
    my %args = (
        pd => '',
        @_,
    );
    my $sqlcode;
    my $status = 0;
    
    $sqlcode = "UPDATE $args{schema}.approval_list SET dateapproved=TO_DATE('01/01/1900','mm/dd/yyyy'), approvedby=0 ";
    $sqlcode .= "WHERE prnumber='$args{pd}' AND DATEAPPROVED IS NULL";
    $args{dbh}->do($sqlcode);

    $args{dbh}->commit;
    
    return (1);
}


###################################################################################################################################
sub doProcessAssignBuyer {  # routine to reset the buyer assigned to a PD
###################################################################################################################################
    my %args = (
        pd => '',
        buyer => 0,
        @_,
    );
    my $sqlcode;
    my $status = 0;
    
    $sqlcode = "UPDATE $args{schema}.purchase_documents SET buyer=$args{buyer} WHERE prnumber='$args{pd}'";
    $args{dbh}->do($sqlcode);

    $args{dbh}->commit;
    
    return (1);
}


###################################################################################################################################
sub doRemovePOChargeNumbers {  # routine to return a pending PO to RFP
###################################################################################################################################
    my %args = (
        pd => '',
        @_,
    );
    my $sqlcode;
    my $status = 0;
    
    $sqlcode = "DELETE FROM $args{schema}.po_chargenumbers WHERE prnumber='$args{pd}'";
    $args{dbh}->do($sqlcode);

    $args{dbh}->commit;
    
    return (1);
}


###################################################################################################################################
sub getSiteTaxableEC {  # routine to retriev the EC's that are taxable for a site
###################################################################################################################################
    my %args = (
        deptID => 0,
        @_,
    );
    my $sqlcode;
    my $status = 0;
    my $csr;
    my @ecList;
    
    $sqlcode = "SELECT ec.ec, ec.site, ec.taxable FROM $args{schema}.ec_site ec, $args{schema}.departments d WHERE ec.site=d.site AND d.id='$args{deptID}' AND ec.taxable='T'";
#print STDERR "\n$sqlcode\n\n";
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    my $i = 0;
    while (($ecList[$i]{ec}, $ecList[$i]{site}, $ecList[$i]{taxable}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;

    return (@ecList);

}


###################################################################################################################################
sub doProcessSavePDRemark {  # routine to enter a new pd remark
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    my $csr;
    
    eval {
# remarks

        if ($settings{remarks} gt ' ') {
            $sqlcode = "INSERT INTO $args{schema}.remarks (prnumber, userid, dateentered, text) VALUES ('$settings{id}', $args{userID}, SYSDATE, ";
            $sqlcode .= ":text)";
#print STDERR "\n$sqlcode\n\n";
            $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":text", $settings{remarks}, {ora_type => ORA_CLOB, ora_field => 'text'});
            $status = $csr->execute;
            $csr->finish;
            $args{dbh}->commit;
        }

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }


    return (1);
}


###################################################################################################################################
###################################################################################################################################


1; #return true
