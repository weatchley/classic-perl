# UI Purchase Documents functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UIPurchaseDocuments.pm,v $
#
# $Revision: 1.58 $
#
# $Date: 2010/02/22 22:44:05 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIPurchaseDocuments.pm,v $
# Revision 1.58  2010/02/22 22:44:05  atchleyb
# ACR0911_002 - fixed issue with vhange winning vendor utility
#
# Revision 1.57  2010/01/26 18:24:44  atchleyb
# ACR1001_002 - Fix title prob in tax report
#
# Revision 1.56  2009/12/10 18:15:13  atchleyb
# ACR0912_004 - added vendor column to tax report
#
# Revision 1.55  2009/10/13 21:24:36  atchleyb
# ACR0910_007 - Add taxable amount column to tax report
#
# Revision 1.54  2009/10/08 21:44:57  atchleyb
# ACR0910_006 - Fix prob with report selection
#
# Revision 1.53  2009/09/14 16:37:38  atchleyb
# ACR0909_003 - Add a pretax total column to the tax report
#
# Revision 1.52  2009/09/04 16:55:30  atchleyb
# ACR0908_007 - Changes to implement new Tax Report
#
# Revision 1.51  2009/08/14 15:08:21  atchleyb
# ACR0908_003 - Report chargenumber selection fix, missing quotes around chargenumber on accounts payable form
#
# Revision 1.50  2009/07/31 22:43:26  atchleyb
# Updates related to ACR0907_004-SWR0149   New intermediate buyer role, minor bug fixes
#
# Revision 1.49  2009/06/26 21:57:40  atchleyb
# ACR0906_001 - List of changes
#
# Revision 1.48  2009/06/10 17:03:30  atchleyb
# ACR0905_001 - user change request, multiple changes
#
# Revision 1.47  2008/12/22 22:15:36  atchleyb
# ACR0812_004 - fixed issue with RFP attachments and question validation durring PO processing
#
# Revision 1.46  2008/12/03 17:05:29  atchleyb
# ACR0811_001 - Added PO Reference number
#
# Revision 1.45  2008/10/21 23:54:19  atchleyb
# Fixed question issue for copying an old PR
#
# Revision 1.44  2008/10/21 18:06:05  atchleyb
# ACR0810_002 - Updated to allow for routing questions
#
# Revision 1.43  2008/09/29 17:37:55  atchleyb
# ACR0809_004 - fixed bug with bid remarks being deleted when the bid abstract is generated from the browse form
#
# Revision 1.42  2008/08/29 15:50:29  atchleyb
# ACR0808_013 - Fix problems with clauses and PO's, fix problem with shipping costs on bids not transfering to PO
#
# Revision 1.41  2008/07/25 19:44:47  atchleyb
# Added button link to the java servlet for generating the XLS bid quote sheet
#
# Revision 1.40  2008/07/15 20:55:13  atchleyb
# ACR0807_003 - Fixed number of columns for Quantity on RFP report to allow 4 characters
#
# Revision 1.39  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.38  2007/10/11 18:54:35  atchleyb
# CREQ00036 - Updated to get list of taxable element codes from the db
#
# Revision 1.37  2007/08/09 20:35:53  atchleyb
# CR 0034 Fixed defect that kept requesters from being able to cancel thier own PRs that were in initial or updating status
#
# Revision 1.36  2007/08/03 22:09:50  atchleyb
# CR 0033 - Changed e-mail address seperator from ';' to '.'
#
# Revision 1.35  2007/04/11 16:49:24  atchleyb
# SCR00031 - changed to generate the archive pdf after the approvals are stored
#
# Revision 1.34  2007/02/07 17:28:29  atchleyb
# CR 0030 - Updated to handle default PO clauses
#
# Revision 1.33  2007/01/24 17:55:26  atchleyb
# CR00028 - updated the attachment section of browse PD to not display PO durring RFP
# altered Print PR Form button to only display before RFP
#
# Revision 1.32  2006/05/17 23:20:42  atchleyb
# CR0026 - added new function doPOAPPOpenToRec, replace e-mail helptext with var from SharedHeader.pm
# CR0026 - added paymentterms and shipvia to form, replaced doebilled with clientbilled
#
# Revision 1.31  2006/03/25 00:36:33  atchleyb
# Altered to have on form sales tax to be zero when purchase document is set to tax exempt
#
# Revision 1.30  2006/03/16 16:50:14  atchleyb
# CR 0023 - Updated to allow the removeal/restoration of line items
# CR 0023 - Updated to allow multiple attachments at one time
#
# Revision 1.29  2006/02/14 23:42:17  atchleyb
# CR 0022 - Help text for e-mail categorization was updated and commented out pending text approval so that CR could be closed out.
#
# Revision 1.28  2006/02/02 19:20:49  atchleyb
# CR 0022 - Added code for doPOPendingToRFP, cancelinitpr, display current buyer on pr/po utility selections screens
# CR 0022 - Added select by buyer in browse puchase document, contact information for winning vendor on browse purchase document
# CR 0022 - Changed to allow a credit card to be used for Blanket or maintenance contracts
#
# Revision 1.27  2006/01/10 15:21:02  atchleyb
# CREQ00021 - fixed option for 'edit pr' from RFP screen
#
# Revision 1.26  2005/11/18 19:17:11  atchleyb
# CR0020 - Updated to allow input of negative dollar amounts
#
# Revision 1.25  2005/10/04 21:42:24  atchleyb
# CR00019 - fixed defect in item number check code
#
# Revision 1.24  2005/08/30 21:34:31  atchleyb
# CR0017 Updated dollar form field lengths to 12
#
# Revision 1.23  2005/08/30 17:45:02  atchleyb
# CR0016 Updated to allow a delta of the amount of shipping (including tax) for comparing the EC totals.
# Fixed missing double quote in javascript for items.
#
# Revision 1.22  2005/08/18 19:30:27  atchleyb
# CR00015 - merged the copyprform into the browse form,  added site and vendor filters to browse,
# added new multi-status option to browse filter, added button to browse and approve po screens,
# added code to force EC totals to match between line items and charge distribution, changed text for PO type,
# added internal use only display of use tax
#
# Revision 1.21  2005/07/13 20:52:58  atchleyb
# updated doPrintInvoiceLog to handel when a PO has invoice(s) against some but not all Charge #/EC combinations, the combinations with no invoices do not show on the report.
#
# Revision 1.20  2005/06/10 22:45:40  atchleyb
# CR0011
# added dept selection for coping old PR's
# added e-mail notifications for pending approvals
# added reassign buyer code
# added PD form validations
#
# Revision 1.19  2005/03/30 23:11:28  atchleyb
# Fixed misspelling, added part number to RFP, added EC to chargenumber on PO reports
#
# Revision 1.18  2005/02/17 20:33:32  atchleyb
# updated for CR0009 - fix a javascript rounding error in charge distribution list.
#
# Revision 1.17  2005/02/01 00:11:48  atchleyb
# Updated for CR005 fixed bug where tax displayed on PO report & PO Info report for vendors with no tax ID.
#
# Revision 1.16  2004/12/16 15:50:25  atchleyb
# Updated javascript code for generating inserted item numbers
#
# Revision 1.15  2004/12/14 00:27:45  atchleyb
# fixed bug in javascript to add new clause, was adding wrong precidence number
#
# Revision 1.14  2004/12/07 18:45:57  atchleyb
# added new reports
#
# Revision 1.13  2004/05/05 23:23:00  atchleyb
# updated sorting in browse
#
# Revision 1.12  2004/04/22 21:39:52  atchleyb
# Updates related to SCR 1 (add field briefdescription)
#
# Revision 1.11  2004/04/21 21:29:21  atchleyb
# allow buyers to select CN's from other than current FY
#
# Revision 1.10  2004/04/16 17:57:33  atchleyb
# updated to add RFP amendment
#
# Revision 1.9  2004/04/05 23:33:19  atchleyb
# added code for dev cycle 11
#
# Revision 1.8  2004/04/02 00:06:48  atchleyb
# updated for po processing
#
# Revision 1.7  2004/03/15 22:04:29  atchleyb
# updated for dev cycle 9, added blanket release info at PR stage
#
# Revision 1.6  2004/02/27 00:21:48  atchleyb
# added code to allow selections on browse
#
# Revision 1.5  2004/01/08 17:08:59  atchleyb
# added code for accounts payable
#
# Revision 1.4  2003/12/15 19:26:04  atchleyb
# updated display of receiving to show delivery info
#
# Revision 1.3  2003/12/15 18:47:57  atchleyb
# added code for receiving
#
# Revision 1.2  2003/11/13 17:25:08  atchleyb
# fix spelling on submit button
# added PD status to browse
#
# Revision 1.1  2003/11/12 20:34:11  atchleyb
# Initial revision
#
#
#
#
#

package UIPurchaseDocuments;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBPurchaseDocuments qw(:Functions);
use DBUsers qw(getUserArray getUserInfo);
use DBVendors qw(getVendorList getVendorInfo);
use DBSites qw(getSiteInfo);
use DBClauses qw(getClauseArray);
use DBReceiving qw(getReceiving);
use DBAccountsPayable qw(getAP getAPInfo);
use DBRoles qw(getUserRoleInfoArray getCurrentDelegate);
use DBBusinessRules qw(getRuleInfo);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Sessions qw(:Functions);
use Mail_Utilities_Lib;
use Tie::IxHash;
use Tables;
use PDF;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
#use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getInitialValues       &doHeader             
      &doFooter               &getTitle             &doPDEntryForm
      &doPDEntry              &doBrowse             &doDisplayPD
      &doPDApproval           &doDisplayAttachment  &doPrintPR
      &doCopyPRForm           &doCopyPR             &doAcceptPRForRFP
      &doAddClauseText        &doRFPUpdate          &doPrintRFP
      &doPlacePO              &doPrintPO            &doAmendPO
      &doPrintArchive         &doReopenPO           &doCancelPR
      &doCancelRFP            &doCancelPO           &doAmendRFP
      &doPrintPOInfo          &doPrintPOActivity    &doPrintPOSocioEconomic
      &doPrintPOAging
      &doPrintInvoiceLog      &doPrintCommitted     &doPrintObligatedNotInvoiced
      &doAssignBuyerForm      &doAssignBuyer        &doSendApprovalNotification
      &formatXLSRow           &doPOPendingToRFP     &doPOAPOpenToRec
      &doSavePDRemark         &doChangeVendor       &doPrintTaxReport
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             
      &doFooter               &getTitle             &doPDEntryForm
      &doPDEntry              &doBrowse             &doDisplayPD
      &doPDApproval           &doDisplayAttachment  &doPrintPR
      &doCopyPRForm           &doCopyPR             &doAcceptPRForRFP
      &doAddClauseText        &doRFPUpdate          &doPrintRFP
      &doPlacePO              &doPrintPO            &doAmendPO
      &doPrintArchive         &doReopenPO           &doCancelPR
      &doCancelRFP            &doCancelPO           &doAmendRFP
      &doPrintPOInfo          &doPrintPOActivity    &doPrintPOSocioEconomic
      &doPrintPOAging
      &doPrintInvoiceLog      &doPrintCommitted     &doPrintObligatedNotInvoiced
      &doAssignBuyerForm      &doAssignBuyer        &doSendApprovalNotification
      &formatXLSRow           &doPOPendingToRFP     &doPOAPOpenToRec
      &doSavePDRemark         &doChangeVendor       &doPrintTaxReport
    )]
);

my $mycgi = new CGI;


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "";
   if (($args{command} eq "addpr") || ($args{command} eq "addprform")) {
      $title = "New PR";
   } elsif (($args{command} eq "updatepr") || ($args{command} eq "updateprform") || ($args{command} eq "updateprselect")) {
      $title = "Update PR";
   } elsif (($args{command} eq "updatepo") || ($args{command} eq "updatepoform") || ($args{command} eq "updateposelect") ||
            ($args{command} eq "acceptpo")) {
      $title = "Update PO";
   } elsif (($args{command} eq "updatepd") || ($args{command} eq "updatepdform") || ($args{command} eq "updatepdselect")) {
      $title = "Update PD";
   } elsif (($args{command} eq "browse") || (($args{command} eq "displaypd")) || ($args{command} eq "displaypdform")) {
      $title = "Browse Purchase Document";
   } elsif (($args{command} eq "browsehistory")) {
      $title = "Browse Purchase Document History";
   } elsif (($args{command} eq "approvepdform") || ($args{command} eq "prapproved") || ($args{command} eq "prdisapproved") ||
            ($args{command} eq "pdapproved") || ($args{command} eq "pddisapproved")) {
      $title = "Approve Purchase Document";
   } elsif (($args{command} eq "copyprform") || ($args{command} eq "copypr")) {
      $title = "Copy Purchase Document";
   } elsif (($args{command} eq "acceptprforrfp") || ($args{command} eq "updaterfpform") || ($args{command} eq "updaterfp")) {
      $title = "RFP";
   } elsif (($args{command} eq "placepoform") || ($args{command} eq "placepo")) {
      $title = "Place PO";
   } elsif (($args{command} eq "amendposelect") || ($args{command} eq "doamendpo")) {
      $title = "Amend PO";
   } elsif (($args{command} eq "amendrfpselect") || ($args{command} eq "doamendrfp")) {
      $title = "Amend RFP";
   } elsif (($args{command} eq "reopenposelect") || ($args{command} eq "doreopenpo")) {
      $title = "Reopen Closed PO";
   } elsif (($args{command} eq "cancelinitprselect") || ($args{command} eq "cancelinitpr") || 
            ($args{command} eq "cancelprselect") || ($args{command} eq "docancelpr") || 
            ($args{command} eq "cancelrfpselect") || ($args{command} eq "docancelrfp") || 
            ($args{command} eq "cancelposelect") || ($args{command} eq "docancelpo")) {
      $title = "Cancel Purchase Document";
   } elsif (($args{command} eq "assignbuyerselect") || ($args{command} eq "assignbuyer") || ($args{command} eq "assignbuyerform")) {
      $title = "Reassign Buyer";
   } elsif (($args{command} eq "popendtorfpselect") || ($args{command} eq "popendtorfp")) {
      $title = "PO Pending To RFP";
   } elsif (($args{command} eq "pushpofromaptorecselect") || ($args{command} eq "pushpofromaptorec")) {
      $title = "Accounting Open To Receiving";
   } elsif (($args{command} eq "dochangevendor") || ($args{command} eq "changevendorselect")) {
      $title = "Change Winning Vendor";
   } elsif (($args{command} eq "printtaxrep")) {
      $title = "Tax Report";
   } else {
      $title = "$args{command}";
   }
   return ($title);
}


###################################################################################################################################
sub getInitialValues {  # routine to get initial CGI values and return in a hash
###################################################################################################################################
    my %args = (
        dbh => "",
        @_,
    );
    
    my %valueHash = (
       &getStandardValues, (
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "browse",
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
       pdid => (defined($mycgi->param("pdid"))) ? $mycgi->param("pdid") : 0,
       p_pdid => (defined($mycgi->param("p_pdid"))) ? $mycgi->param("p_pdid") : 0,
       prnumber => (defined($mycgi->param("prnumber"))) ? $mycgi->param("prnumber") : 0,
       author => (defined($mycgi->param("author"))) ? $mycgi->param("author") : 0,
       requester => (defined($mycgi->param("requester"))) ? $mycgi->param("requester") : 0,
       requester2 => (defined($mycgi->param("requester2"))) ? $mycgi->param("requester2") : -1,
       deptid => (defined($mycgi->param("deptid"))) ? $mycgi->param("deptid") : 0,
       chargenumber => (defined($mycgi->param("chargenumber"))) ? $mycgi->param("chargenumber") : "",
       priority => (defined($mycgi->param("priority"))) ? $mycgi->param("priority") : "F",
       daterequired => (defined($mycgi->param("daterequired"))) ? $mycgi->param("daterequired") : "",
       duedate => (defined($mycgi->param("duedate"))) ? $mycgi->param("duedate") : "",
       briefdescription => (defined($mycgi->param("briefdescription"))) ? $mycgi->param("briefdescription") : "",
       justification => (defined($mycgi->param("justification"))) ? $mycgi->param("justification") : "",
       itemcount => (defined($mycgi->param("itemcount"))) ? $mycgi->param("itemcount") : 0,
       solesource => (defined($mycgi->param("solesource"))) ? $mycgi->param("solesource") : "F",
       ssjustification => (defined($mycgi->param("ssjustification"))) ? $mycgi->param("ssjustification") : "",
       remarks => (defined($mycgi->param("remarks"))) ? $mycgi->param("remarks") : "",
       attachment => (defined($mycgi->param("attachment"))) ? $mycgi->param("attachment") : "",
       entrytype => (defined($mycgi->param("entrytype"))) ? $mycgi->param("entrytype") : 0,
       status => (defined($mycgi->param("status"))) ? $mycgi->param("status") : 0,
       oldstatus => (defined($mycgi->param("oldstatus"))) ? $mycgi->param("oldstatus") : 0,
       shipping => (defined($mycgi->param("shipping"))) ? $mycgi->param("shipping") : 0,
       tax => (defined($mycgi->param("tax"))) ? $mycgi->param("tax") : 0,
       taxexempt => (defined($mycgi->param("taxexempt"))) ? $mycgi->param("taxexempt") : "F",
       sortby => (defined($mycgi->param("sortby"))) ? $mycgi->param("sortby") : "prnumber",
       clausecount => (defined($mycgi->param("clausecount"))) ? $mycgi->param("clausecount") : "0",
       clauseselect => (defined($mycgi->param("clauseselect"))) ? $mycgi->param("clauseselect") : "0",
       fob => (defined($mycgi->param("fob"))) ? $mycgi->param("fob") : "2",
       rfpdeliverdays => (defined($mycgi->param("rfpdeliverdays"))) ? $mycgi->param("rfpdeliverdays") : "0",
       rfpdaysvalid => (defined($mycgi->param("rfpdaysvalid"))) ? $mycgi->param("rfpdaysvalid") : "0",
       rfpduedate => (defined($mycgi->param("rfpduedate"))) ? $mycgi->param("rfpduedate") : "",
       attachmentcount => (defined($mycgi->param("attachmentcount"))) ? $mycgi->param("attachmentcount") : "0",
       newattachmentcount => (defined($mycgi->param("newattachmentcount"))) ? $mycgi->param("newattachmentcount") : "0",
       brapprovalcount => (defined($mycgi->param("brapprovalcount"))) ? $mycgi->param("brapprovalcount") : "0",
       chargedistcount => (defined($mycgi->param("chargedistcount"))) ? $mycgi->param("chargedistcount") : "0",
       viewfy => (defined($mycgi->param("viewfy"))) ? $mycgi->param("viewfy") : &getFY,
       viewstatus => (defined($mycgi->param("viewstatus"))) ? $mycgi->param("viewstatus") : "0",
       blanketrelease => (defined($mycgi->param("blanketrelease"))) ? $mycgi->param("blanketrelease") : "0",
       potype => (defined($mycgi->param("potype"))) ? $mycgi->param("potype") : "1",
       startdate => (defined($mycgi->param("startdate"))) ? $mycgi->param("startdate") : "",
       enddate => (defined($mycgi->param("enddate"))) ? $mycgi->param("enddate") : "",
       creditcardholder => (defined($mycgi->param("creditcardholder"))) ? $mycgi->param("creditcardholder") : "0",
       selectionmemo => (defined($mycgi->param("selectionmemo"))) ? $mycgi->param("selectionmemo") : "",
       enclosures => (defined($mycgi->param("enclosures"))) ? $mycgi->param("enclosures") : "",
       datetest => (defined($mycgi->param("datetest"))) ? $mycgi->param("datetest") : "",
       site => (defined($mycgi->param("site"))) ? $mycgi->param("site") : 0,
       sesite => (defined($mycgi->param("sesite"))) ? $mycgi->param("sesite") : 0,
       onisite => (defined($mycgi->param("onisite"))) ? $mycgi->param("onisite") : 0,
       comsite => (defined($mycgi->param("comsite"))) ? $mycgi->param("comsite") : 0,
       invlsite => (defined($mycgi->param("invlsite"))) ? $mycgi->param("invlsite") : 0,
       poactformat => (defined($mycgi->param("poactformat"))) ? $mycgi->param("poactformat") : 'pdf',
       poseformat => (defined($mycgi->param("poseformat"))) ? $mycgi->param("poseformat") : 'pdf',
       oniformat => (defined($mycgi->param("oniformat"))) ? $mycgi->param("oniformat") : 'pdf',
       comformat => (defined($mycgi->param("comformat"))) ? $mycgi->param("comformat") : 'pdf',
       invlformat => (defined($mycgi->param("invlformat"))) ? $mycgi->param("invlformat") : 'pdf',
       sestartdate => (defined($mycgi->param("sestartdate"))) ? $mycgi->param("sestartdate") : "",
       comstartdate => (defined($mycgi->param("comstartdate"))) ? $mycgi->param("comstartdate") : "",
       invlstartdate => (defined($mycgi->param("invlstartdate"))) ? $mycgi->param("invlstartdate") : "",
       seenddate => (defined($mycgi->param("seenddate"))) ? $mycgi->param("seenddate") : "",
       comenddate => (defined($mycgi->param("comenddate"))) ? $mycgi->param("comenddate") : "",
       invlenddate => (defined($mycgi->param("invlenddate"))) ? $mycgi->param("invlenddate") : "",
       actsortby => (defined($mycgi->param("actsortby"))) ? $mycgi->param("actsortby") : "prnumber",
       sesortby => (defined($mycgi->param("sesortby"))) ? $mycgi->param("sesortby") : "vendorName",
       onisortby => (defined($mycgi->param("onisortby"))) ? $mycgi->param("onisortby") : "podate",
       comsortby => (defined($mycgi->param("comsortby"))) ? $mycgi->param("comsortby") : "podate",
       startpo => (defined($mycgi->param("startpo"))) ? $mycgi->param("startpo") : " ",
       invlsortby => (defined($mycgi->param("invlsortby"))) ? $mycgi->param("invlsortby") : "ponumber",
       buyer => (defined($mycgi->param("buyer"))) ? $mycgi->param("buyer") : "0",
       buyer2 => (defined($mycgi->param("buyer2"))) ? $mycgi->param("buyer2") : "0",
       oldbuyer => (defined($mycgi->param("oldbuyer"))) ? $mycgi->param("oldbuyer") : "0",
       siteid => (defined($mycgi->param("siteid"))) ? $mycgi->param("siteid") : "0",
       vendorid => (defined($mycgi->param("vendorid"))) ? $mycgi->param("vendorid") : "0",
       itemquantitychanged => (defined($mycgi->param("itemquantitychanged"))) ? $mycgi->param("itemquantitychanged") : "F",
       shipvia => (defined($mycgi->param("shipvia"))) ? $mycgi->param("shipvia") : "",
       paymentterms => (defined($mycgi->param("paymentterms"))) ? $mycgi->param("paymentterms") : "",
       pdtotal => (defined($mycgi->param("pdtotal"))) ? $mycgi->param("pdtotal") : 0,
       refnumber => (defined($mycgi->param("refnumber"))) ? $mycgi->param("refnumber") : "",
       poactmaintonly => (defined($mycgi->param("poactmaintonly"))) ? $mycgi->param("poactmaintonly") : "F",
       agesite => (defined($mycgi->param("agesite"))) ? $mycgi->param("agesite") : 0,
       agesortby => (defined($mycgi->param("agesortby"))) ? $mycgi->param("agesortby") : "prnumber",
       agehowold => (defined($mycgi->param("agehowold"))) ? $mycgi->param("agehowold") : "0-30",
       agetype => (defined($mycgi->param("agetype"))) ? $mycgi->param("agetype") : "initial",
       poageformat => (defined($mycgi->param("poageformat"))) ? $mycgi->param("poageformat") : 'pdf',
       questioncount => (defined($mycgi->param("questioncount"))) ? $mycgi->param("questioncount") : "0",
       onichargenumber => (defined($mycgi->param("onichargenumber"))) ? $mycgi->param("onichargenumber") : "0",
       trsite => (defined($mycgi->param("trsite"))) ? $mycgi->param("trsite") : "0",
       trchargenumber => (defined($mycgi->param("trchargenumber"))) ? $mycgi->param("trchargenumber") : "0",
       trsortby => (defined($mycgi->param("trsortby"))) ? $mycgi->param("trsortby") : "",
       trstartdate => (defined($mycgi->param("trstartdate"))) ? $mycgi->param("trstartdate") : "",
       trenddate => (defined($mycgi->param("trenddate"))) ? $mycgi->param("trenddate") : "",
       trformat => (defined($mycgi->param("trformat"))) ? $mycgi->param("trformat") : "",
       taxtype => (defined($mycgi->param("taxtype"))) ? $mycgi->param("taxtype") : "all",
       items => [],
       clauses => [],
       attachments => [],
       brapprovallist => [],
       chargedist => [],
       questions => [],
    ));

    $valueHash{title} = &getTitle(command => $valueHash{command});
    my @vendorList = $mycgi->param("vendorlist");
    $valueHash{vendorList} = \@vendorList;
    
    for (my $i=0; $i<=$valueHash{itemcount}; $i++) {
        $valueHash{items}[$i]{"itemnumber"} = (defined($mycgi->param("itemnumber$i"))) ? $mycgi->param("itemnumber$i") : 0;
        $valueHash{items}[$i]{"olditemnumber"} = (defined($mycgi->param("olditemnumber$i"))) ? $mycgi->param("olditemnumber$i") : 0;
        $valueHash{items}[$i]{"partnumber"} = (defined($mycgi->param("partnumber$i"))) ? $mycgi->param("partnumber$i") : "";
        $valueHash{items}[$i]{"description"} = (defined($mycgi->param("description$i"))) ? $mycgi->param("description$i") : "";
        $valueHash{items}[$i]{"quantity"} = (defined($mycgi->param("quantity$i"))) ? $mycgi->param("quantity$i") : 0;
        $valueHash{items}[$i]{"quantitysave"} = (defined($mycgi->param("quantitysave$i"))) ? $mycgi->param("quantitysave$i") : 0;
        $valueHash{items}[$i]{"unitofissue"} = (defined($mycgi->param("unitofissue$i"))) ? $mycgi->param("unitofissue$i") : 0;
        $valueHash{items}[$i]{"unitprice"} = (defined($mycgi->param("unitprice$i"))) ? $mycgi->param("unitprice$i") : 0;
        $valueHash{items}[$i]{"substituteok"} = (defined($mycgi->param("substituteok$i"))) ? $mycgi->param("substituteok$i") : "F";
        $valueHash{items}[$i]{"techinspection"} = (defined($mycgi->param("techinspection$i"))) ? $mycgi->param("techinspection$i") : "F";
        $valueHash{items}[$i]{"ishazmat"} = (defined($mycgi->param("ishazmat$i"))) ? $mycgi->param("ishazmat$i") : "F";
        $valueHash{items}[$i]{"ec"} = (defined($mycgi->param("ec$i"))) ? $mycgi->param("ec$i") : "";
        $valueHash{items}[$i]{"type"} = (defined($mycgi->param("type$i"))) ? $mycgi->param("type$i") : "";
        $valueHash{items}[$i]{"removeFlag"} = (defined($mycgi->param("removeFlag$i"))) ? $mycgi->param("removeFlag$i") : "F";
    }
    
    for (my $i=0; $i<=$valueHash{clausecount}; $i++) {
        $valueHash{clauses}[$i]{"precedence"} = (defined($mycgi->param("precedence$i"))) ? $mycgi->param("precedence$i") : 0;
        $valueHash{clauses}[$i]{"oldprecedence"} = (defined($mycgi->param("oldprecedence$i"))) ? $mycgi->param("oldprecedence$i") : 0;
        $valueHash{clauses}[$i]{"removeflag"} = (defined($mycgi->param("removeflag$i"))) ? $mycgi->param("removeflag$i") : "";
        $valueHash{clauses}[$i]{"type"} = (defined($mycgi->param("clausetype$i"))) ? $mycgi->param("clausetype$i") : "F";
        $valueHash{clauses}[$i]{"rfp"} = (defined($mycgi->param("clauserfp$i"))) ? $mycgi->param("clauserfp$i") : "F";
        $valueHash{clauses}[$i]{"po"} = (defined($mycgi->param("clausepo$i"))) ? $mycgi->param("clausepo$i") : "F";
        $valueHash{clauses}[$i]{"clause"} = (defined($mycgi->param("clause$i"))) ? $mycgi->param("clause$i") : "";
    }
    
    for (my $i=0; $i<=$valueHash{attachmentcount}; $i++) {
        $valueHash{attachments}[$i]{"id"} = (defined($mycgi->param("attachmentid$i"))) ? $mycgi->param("attachmentid$i") : 0;
        $valueHash{attachments}[$i]{"rfp"} = (defined($mycgi->param("attachmentrfp$i"))) ? $mycgi->param("attachmentrfp$i") : 'F';
        $valueHash{attachments}[$i]{"po"} = (defined($mycgi->param("attachmentpo$i"))) ? $mycgi->param("attachmentpo$i") : 'F';
        $valueHash{attachments}[$i]{"removeFlag"} = (defined($mycgi->param("attachRemoveFlag$i"))) ? $mycgi->param("attachRemoveFlag$i") : 'F';
    }
    
    for (my $i=0; $i<=$valueHash{brapprovalcount}; $i++) {
        $valueHash{brapprovallist}[$i]{"precedence"} = (defined($mycgi->param("brprecedence$i"))) ? $mycgi->param("brprecedence$i") : 0;
        $valueHash{brapprovallist}[$i]{"userid"} = (defined($mycgi->param("bruserid$i"))) ? $mycgi->param("bruserid$i") : 0;
    }
    
    for (my $i=0; $i<=$valueHash{chargedistcount}; $i++) {
        $valueHash{chargedist}[$i]{"chargenumber"} = (defined($mycgi->param("cdchargenumber$i"))) ? $mycgi->param("cdchargenumber$i") : "";
        $valueHash{chargedist}[$i]{"ec"} = (defined($mycgi->param("cdec$i"))) ? $mycgi->param("cdec$i") : '';
        $valueHash{chargedist}[$i]{"amount"} = (defined($mycgi->param("cdamount$i"))) ? $mycgi->param("cdamount$i") : 0;
        $valueHash{chargedist}[$i]{"invoiced"} = (defined($mycgi->param("cdinvoiced$i"))) ? $mycgi->param("cdinvoiced$i") : 0;
        $valueHash{chargedist}[$i]{"cddelete"} = (defined($mycgi->param("cddelete$i"))) ? $mycgi->param("cddelete$i") : "F";
    }
    
    for (my $i=0; $i<=$valueHash{newattachmentcount}; $i++) {
        $valueHash{attachmentList}[$i]{"attachment"} = (defined($mycgi->param("attachment$i"))) ? $mycgi->param("attachment$i") : "";
    }
    
    for (my $i=0; $i<=$valueHash{questioncount}; $i++) {
        $valueHash{questions}[$i]{"text"} = (defined($mycgi->param("questiontext$i"))) ? $mycgi->param("questiontext$i") : "";
        $valueHash{questions}[$i]{"text"} =~ s/<br>/\n/g;
        $valueHash{questions}[$i]{"text"} =~ s/''/"/g;
        $valueHash{questions}[$i]{"answer"} = (defined($mycgi->param("questionanswer$i"))) ? $mycgi->param("questionanswer$i") : "";
        $valueHash{questions}[$i]{"precedence"} = (defined($mycgi->param("questionprecedence$i"))) ? $mycgi->param("questionprecedence$i") : "";
        $valueHash{questions}[$i]{"role"} = (defined($mycgi->param("questionrole$i"))) ? $mycgi->param("questionrole$i") : "";
    }
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => $ENV{SCHEMA},
        title => "$SYSType User Functions",
        displayTitle => 'T',
        includeJSUtilities => 'T',
        includeJSWidgets => 'F',
        includeJSCalendar => 'F',
        useFileUpload => 'F',
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $form = $args{form};
    my $path = $args{path};
    my $username = $settings{username};
    my $userid = $settings{userid};
    my $Server = $settings{server};
    
    my $extraJS = "";
    $extraJS .= <<END_OF_BLOCK;
       function displayAttachment(id) {
          var myDate = new Date();
          var winName = myDate.getTime();
          document.$form.id.value = id;
          document.$args{form}.action = '$args{path}' + 'purchaseDocuments.pl';
          document.$form.command.value = 'displayattachment';
          document.$form.target = winName;
          var newwin = window.open('',winName);
          newwin.creator = self;
          document.$form.submit();
       }


END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              includeJSCalendar => $args{includeJSCalendar}, useFileUpload => $args{useFileUpload}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS,includeJSUtilities => $args{includeJSUtilities}, 
              includeJSWidgets => $args{includeJSWidgets});
#              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, onSubmit => "return verify_$form(this)");
    
    $output .= "<table border=0 width=750 align=center><tr><td>\n";

    return($output);
}


###################################################################################################################################
sub doFooter {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my $form = $args{form};
    my $path = $args{path};
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $username = $settings{username};
    my $userid = $settings{userid};
    my $Server = $settings{server};
    my $schema = $settings{schema};
    my $sessionID = $settings{sessionID};
    my $extraHTML = "";
    
    $output .= "<br><br>\n</td></tr></table>\n";
    
    $output .= &doStandardFooter(form => $form, extraHTML => $extraHTML);

    return($output);
}


###################################################################################################################################
sub doBrowse {  # routine to generate a table of Purchase documents for browse
###################################################################################################################################
    my %args = (
        statusList => '0', # 0 = any
        sortBy => 'prnumber',
        fy => 0,
        requester => -1,
        buyer => -1,
        siteID => 0,
        vendorID => 0,
        type => 'browse', # browse, amendment, reopen, cancelpr, 
        command => 'browse',
        deptID => 0,
        @_,
    );
    my $output = "";
    my $siteList = "0";
    my $statusList = "0";
    my $selectItem = "displaypd";
    my $resort = "browse";
    my $submitType = "submitForm";
    my $amended = "n/a";
    my $quantOfZero = 'F';
    my $noReceiving = 'F';
    if ($args{type} eq 'amendment') {
        $siteList = &sitesUserHasRole(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, roleList=>[6, 7]);
        $statusList = "15, 17, 18";
        $selectItem = "doamendpo";
        $resort = "amendposelect";
    } elsif ($args{type} eq 'changevendor') {
        $siteList = &sitesUserHasRole(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, roleList=>[6, 7]);
        $statusList = "15, 16, 17, 18";
        $selectItem = "dochangevendor";
        $resort = "changevendorselect";
    } elsif ($args{type} eq 'reopen') {
        $siteList = &sitesUserHasRole(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, roleList=>[6]);
        $statusList = "19";
        $selectItem = "doreopenpo";
        $resort = "reopenposelect";
        $submitType = "submitFormCGIResults";
    } elsif ($args{type} eq 'copyprform') {
        $statusList = "0";
        $selectItem = "copypr";
        $resort = "copyprform";
        #$submitType = "submitFormCGIResults";
    } elsif ($args{type} eq 'cancelinitpr') {
        #$siteList = &sitesUserHasRole(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, roleList=>[6, 7]);
        $statusList = "1, 2";
        $selectItem = "docancelpr";
        $resort = "cancelinitprselect";
        $submitType = "submitFormCGIResults";
        $args{requester} = $args{userID};
    } elsif ($args{type} eq 'cancelpr') {
        $siteList = &sitesUserHasRole(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, roleList=>[6, 7]);
        $statusList = "1, 2, 3, 4, 5, 6, 7, 8, 9";
        $selectItem = "docancelpr";
        $resort = "cancelprselect";
        $submitType = "submitFormCGIResults";
    } elsif ($args{type} eq 'cancelrfp') {
        $siteList = &sitesUserHasRole(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, roleList=>[6, 7]);
        $statusList = "10, 11, 14, 15";
        $selectItem = "docancelrfp";
        $resort = "cancelrfpselect";
        $submitType = "submitFormCGIResults";
        $amended = "F";
        $noReceiving = 'T';
    } elsif ($args{type} eq 'cancelpo') {
        $siteList = &sitesUserHasRole(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, roleList=>[6, 7]);
        $statusList = "13, 15, 16, 17";
        $selectItem = "docancelpo";
        $resort = "cancelposelect";
        $submitType = "submitFormCGIResults";
        #$amended = "T";
        #$quantOfZero = "F";
        $noReceiving = 'T';
    } elsif ($args{type} eq 'amendrfp') {
        $siteList = &sitesUserHasRole(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, roleList=>[6, 7]);
        $statusList = "10";
        $selectItem = "doamendrfp";
        $resort = "amendrfpselect";
        $submitType = "submitFormCGIResults";
    } elsif ($args{type} eq 'assignbuyerselect') {
        $siteList = &sitesUserHasRole(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, roleList=>[6]);
        $statusList = "5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16";
        $selectItem = "assignbuyerform";
        $resort = "assignbuyerselect";
        $submitType = "submitForm";
    } elsif ($args{type} eq 'popendtorfp') {
        $siteList = &sitesUserHasRole(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, roleList=>[6]);
        $statusList = "11";
        $selectItem = "dopopendtorfp";
        $resort = "popendtorfpselect";
        $submitType = "submitFormCGIResults";
    } elsif ($args{type} eq 'pushpofromaptorec') {
        $siteList = &sitesUserHasRole(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, roleList=>[6]);
        $statusList = "18";
        $selectItem = "pushpofromaptorec";
        $resort = "pushpofromaptorecselect";
        $submitType = "submitFormCGIResults";
    }
    if ($args{statusList} ne '0') {
        $statusList = $args{statusList};
    }
    if ($args{siteID} != 0) {
        if ($siteList eq '0') {
            $siteList = $args{siteID};
        } else {
            my $test = ", $args{siteID},";
            if ($siteList =~ /$test/) {
                $siteList = $args{siteID};
            } else {
                $siteList = "-1";
            }
        }
    }
    #my @PDs = getPDByStatus(dbh => $args{dbh}, schema => $args{schema}, fy => $args{fy}, orderBy => $args{sortBy}, requester=>$args{requester},
    my @PDs = getPDByStatus(dbh => $args{dbh}, schema => $args{schema}, fy => $args{fy}, orderBy => 'ponumber', requester=>$args{requester},
            statusList=> $statusList, siteList=>$siteList, amended=>$amended, quantOfZero=>$quantOfZero, getVendor=>'T', 
            receivingCount => $noReceiving, vendor=>$args{vendorID}, buyer => $args{buyer});
    my $fy = &getFY;

    if ($args{type} ne 'browse' && $args{type} ne 'assignbuyerselect' && $args{type} ne 'copyprform') {
        $output .= "<table align=center border=0>\n";
        $output .= "<tr><td><b>Justification:<br><textarea name=remarks cols=70 rows=4></textarea></td></tr>\n";
        $output .= "</table>\n";
    }
    $output .= "<input type=hidden name=sortby value='$args{sortBy}'>\n";
    $output .= "<table align=center border=0><tr>";
    $output .= "<td>Fiscal&nbsp;Year:&nbsp;&nbsp;&nbsp;<br><select name=viewfy size=1>\n";
    $output .= "<option value=0" . ((0 == $args{fy}) ? " selected" : "") . ">All</option>\n";
    for (my $i=1999; $i<=$fy; $i++) {
        $output .= "<option value=$i" . (($i == $args{fy}) ? " selected" : "") . ">$i</option>\n";
    }
    $output .= "</select></td>";
    $output .= "<td>Requester:<br><select name=requester2 size=1>\n";
    my @requesters = &getRequesterArray(dbh => $args{dbh}, schema => $args{schema});
    $output .= "<option value=-1" . ((-1 == $args{requester}) ? " selected" : "") . ">All</option>\n";
    for (my $i=0; $i<=$#requesters; $i++) {
        $output .= "<option value=$requesters[$i]{id}" . (($requesters[$i]{id} == $args{requester}) ? " selected" : "") . ">$requesters[$i]{lastname}, $requesters[$i]{firstname}</option>\n";
    }
    $output .= "</select>&nbsp;&nbsp;</td>";
    $output .= "<td>Status:<br><select name=viewstatus size=1><option value='0'>All</option>\n";
    my $testStatus = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18";
    $output .= "<option value='$testStatus'" . (($args{statusList} eq $testStatus) ? " selected" : "") . ">Open</option>\n";
    $testStatus = "1,2,3,4,5,6,7,8,9,10";
    $output .= "<option value='$testStatus'" . (($args{statusList} eq $testStatus) ? " selected" : "") . ">All Open PR's</option>\n";
    $testStatus = "7,8,9,10";
    $output .= "<option value='$testStatus'" . (($args{statusList} eq $testStatus) ? " selected" : "") . ">All RFP's</option>\n";
    $testStatus = "11,12,13,14,15,16,17,18";
    $output .= "<option value='$testStatus'" . (($args{statusList} eq $testStatus) ? " selected" : "") . ">All Open PO's</option>\n";
    my @statusList = &getStatusList(dbh => $args{dbh}, schema => $args{schema});
    for (my $i=0; $i<$#statusList; $i++) {
        $output .= "<option value=$statusList[$i]{id}" . (($statusList[$i]{id} eq $args{statusList}) ? " selected" : "") . ">$statusList[$i]{name}</option>\n";
    }
    $output .= "</select>&nbsp;</td>\n";
    $output .= "<td>Site:<br><select name=siteid size=1><option value='0'>All</option>\n";
    my @siteList = &getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});
    for (my $i=1; $i<=$#siteList; $i++) {
        $output .= "<option value=$siteList[$i]{id}" . (($siteList[$i]{id} eq $args{siteID}) ? " selected" : "") . ">$siteList[$i]{name}</option>\n";
    }
    $output .= "</select></td></tr>";
    $output .= "<tr><td colspan=2>Vendor:<br><select name=vendorid size=1><option value='0'>All</option>\n";
    my @vendList = &getVendorList(dbh => $args{dbh}, schema => $args{schema});
    for (my $i=0; $i<$#vendList; $i++) {
        $output .= "<option value=$vendList[$i]{id}" . (($vendList[$i]{id} eq $args{vendorID}) ? " selected" : "") . ">$vendList[$i]{name}</option>\n";
    }
    $output .= "</select>&nbsp;</td>\n";
    $output .= "<td>Buyer:<br><select name=buyer2 size=1>\n";
    #my @buyers = &getBuyerArray(dbh => $args{dbh}, schema => $args{schema}, fy => $args{fy});
    my @buyers = &getBuyerArray(dbh => $args{dbh}, schema => $args{schema});
    $output .= "<option value=-1" . ((-1 == $args{buyer}) ? " selected" : "") . ">All</option>\n";
    for (my $i=0; $i<=$#buyers; $i++) {
        $output .= "<option value=$buyers[$i]{id}" . (($buyers[$i]{id} == $args{buyer}) ? " selected" : "") . ">$buyers[$i]{lastname}, $buyers[$i]{firstname}</option>\n";
    }
    $output .= "</select>&nbsp;&nbsp;</td>";
    $output .= "<td align=center valign=bottom><input type=button name=refresh value='Refresh' onClick=submitForm('$args{form}','$args{command}')></td>\n";
    $output .= "</tr>\n";
    if ($args{type} eq 'copyprform') {
        my @depts = &getDeptArray(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, role=>11, activeOnly => 'T');
        my $selectedDept = 0;
        if ($args{deptID} == 0) {
            my %pd = createBlankPD(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID});
            $selectedDept = $pd{deptid};
        } else {
            $selectedDept = $args{deptID};
        }
        $output .= "<tr><td align=center colspan=4>Use Department: <select name=deptid size=1><option value=0></option>\n";
        for (my $i=0; $i<$#depts; $i++) {
            $output .= "<option value=$depts[$i]{id}" . (($depts[$i]{id} == $selectedDept) ? " selected" : "") . ">$depts[$i]{sitename} - $depts[$i]{name}</option>\n";
        }
        $output .= "</select></td></tr>\n";
    }
    $output .= "<tr><td> &nbsp; </td></tr>\n";
    $output .= "</table>\n";
    $output .= "<table align=center cellpadding=1 cellspacing=0 border=1>\n";
    $output .= "<tr bgcolor=#a0e0c0><td><b><a href=\"javascript:reSort('prnumber');\">PR Number/<br>Ref Number</a></b></td>";
    $output .= "<td><b><a href=\"javascript:reSort('ponumber');\">PO Number</a></b></td>";
    $output .= "<td><b><a href=\"javascript:reSort('vendorName');\">Vendor</a></b></td>";
    $output .= "<td><b>Requester/<br>Buyer</b></td><td><b><a href=\"javascript:reSort('statusname');\">Status</a></b></td>";
    $output .= "<td><b><a href=\"javascript:reSort('briefdescription');\">Description</a></b></td></tr>\n";
    my $sortField = ((defined($args{sortBy})) ? $args{sortBy} : "prnumber");
    if ($args{sortBy} ne 'ponumber') {
        @PDs = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @PDs;
    }
    my $rangeMod = ((defined$PDs[0]{prnumber}) ? 0 : 1);
    for (my $i=$rangeMod; $i<($#PDs+$rangeMod); $i++) {
        my $isProcSpec = &doesUserHaveRole(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, roleList=>[6], site=>$PDs[$i]{site});
        my $threshold = 0;
        if ($args{type} eq 'amendment' || $args{type} eq 'amendrfp') {
            $isProcSpec = &doesUserHaveRole(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, roleList=>[6], site=>$PDs[$i]{site});
            if (!$isProcSpec) {
                my %br = &getRuleInfo(dbh => $args{dbh}, schema => $args{schema}, type=>1, site=> $PDs[$i]{site});
                $threshold = $br{nvalue1};
            }
        }
#print STDERR "\n$PDs[$i]{prnumber} site: $PDs[$i]{site}, ProcSpec: $isProcSpec, type: $args{type}, threshold: $threshold, total: $PDs[$i]{total}\n\n";
        #if (($args{type} eq 'browse' || $args{type} eq 'copyprform' || $isProcSpec >= 1 || $threshold >= $PDs[$i]{total})) {
        if (($args{type} eq 'browse' || $args{type} eq 'copyprform' || $isProcSpec >= 1 || $threshold >= $PDs[$i]{total}) || ($args{type} eq 'cancelinitpr' && ($PDs[$i]{status} == 1 || $PDs[$i]{status} == 2))) {
#        if (($args{type} eq 'browse' || $isProcSpec >= 1 || $threshold >= $PDs[$i]{total}) && ($noReceiving ne 'T' || ($noReceiving eq 'T' && $PDs[$i]{receivingCount} == 0))) {
            $output .= "<tr bgcolor=#ffffff><td valign=top><a href=\"javascript:browsePD('$PDs[$i]{prnumber}');\">$PDs[$i]{prnumber}</a><br>$PDs[$i]{refnumber}</td>";
            $output .= "<td valign=top>" . ((defined($PDs[$i]{ponumber})) ? "<a href=\"javascript:browsePD('$PDs[$i]{prnumber}');\">$PDs[$i]{ponumber}" . ((defined($PDs[$i]{amendment})) ? $PDs[$i]{amendment} : "") . "</a>" : "&nbsp;");
            $output .= ((defined($PDs[$i]{podate})) ? "<br>$PDs[$i]{podate2}" : "") . "</td>";
            $output .= "<td valign=top>" . ((defined($PDs[$i]{vendorName})) ? $PDs[$i]{vendorName} : "&nbsp;") . "</td>";
            my $fullName = ((defined($PDs[$i]{requester})) ? &getFullName(dbh => $args{dbh}, schema => $args{schema}, userID=>$PDs[$i]{requester}) : "Error");
            #my $fullName = "test";
            $fullName =~ s/ /&nbsp;/g;
            my $buyerName = ((defined($PDs[$i]{buyer})) ? &getFullName(dbh => $args{dbh}, schema => $args{schema}, userID=>$PDs[$i]{buyer}) : "");
            #my $buyerName = "test";
            $buyerName =~ s/ /&nbsp;/g;
            $output .= "<td valign=top>$fullName" . ((defined($buyerName) && $buyerName gt "  ") ? "<br>$buyerName" : "") . "</td>";
            $output .= "<td valign=top>$PDs[$i]{statusname}</td>";
            $output .= "<td valign=top>$PDs[$i]{briefdescription}</td>";
            $output .= "</tr>\n";
        }
    }
    $output .= "</table>\n";
    
    
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function browsePD (id) {
    var msg = '';
    $args{form}.id.value=id;
END_OF_BLOCK
    if ($args{type} ne 'browse' && $args{type} ne 'copyprform' && $args{type} ne 'assignbuyerselect') {
    $output .= <<END_OF_BLOCK;
    if (isblank($args{form}.remarks.value)) {
        msg += 'Justification must be entered\\n';
    }
END_OF_BLOCK
    }
    if ($args{type} eq 'copyprform') {
    $output .= <<END_OF_BLOCK;
    if (document.$args{form}.deptid[0].selected) {
        msg += "Department must be selected.\\n";
    }
END_OF_BLOCK
    }
    $output .= <<END_OF_BLOCK;
    if (msg != "") {
      alert (msg);
    } else {
        $submitType('$args{form}', '$selectItem');
    }
}

function reSort (by) {
    $args{form}.sortby.value=by;
    submitForm('$args{form}', '$resort');
}

function reFresh (by) {
    submitForm('$args{form}', '$resort');
}

//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doDisplayPD {  # routine to display a purchase document
###################################################################################################################################
    my %args = (
        history => 'F',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$settings{id});
    
    $output .= &doPDEntryForm(dbh => $args{dbh}, schema => $args{schema}, type => 'browse', history=>$args{history},
              title => $args{title}, form => $args{form},  userID => $args{userID}, settings => \%settings);
    

    return($output);
}


###################################################################################################################################
sub doPDEntryForm {  # routine to generate a PD data entry/update form
###################################################################################################################################
    my %args = (
        type => 'new',
        history => 'F',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %pd;
    my $form = $args{form};
    my $id = $settings{id};
    my $path = $args{path};
    my $text = '';
    my $pdStatus = 0;
    my ($displayed, $editable) = (0, 0);
    if ($args{type} eq 'update' || $args{type} eq 'browse') {
        %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, date=>(($args{history} eq 'T') ? $settings{datetest} : ''), 
            history=>$args{history}, id=>$settings{id});
    } else {
        %pd = createBlankPD(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID});
    }
    $pdStatus = $pd{status};
    my $browseOnly = (($args{type} ne 'browse') ? 'F' : 'T');

    $output .= <<END_OF_BLOCK;
<!-- *************************** Begin Floating Window Section *************************** -->
<style type="text/css">
div.float1 {
    position:absolute; width:400px;
    padding-bottom:1px;
    padding-left: 3px;
    background-color:#FFF;
    border:1px solid #317082;
    left:125px;
    top:50px;
    z-index:1000;
    filter:alpha(Opacity=100);
}

</style>

<!-- **** description edit window *** -->
<div id="descEditWindow" class="float1" style="display:'none';">
<table border=0 cellpadding=0 cellspacing=0>
<tr bgcolor=#eeeeee><td align=center><b>Update Item Description</b></td></tr>
<tr><td>
<textarea name=desctextedit cols=80 rows=6></textarea><br>
<input type=hidden name=desctextid value=0>
<a href="javascript:doUpdateItemDesc(document.$form.desctextid.value);">Accept</a> &nbsp;
<a href="javascript:updateItemDesc(document.$form.desctextid.value)">Reset</a> &nbsp;
<a href="javascript:cancelItemDescEdit(document.$form.desctextid.value);">Cancel</a>
</td></tr></table>
</div>

<!-- *************************** End Floating Window Section *************************** -->

END_OF_BLOCK

    $output .= "<table border=0 align=center>\n";

## top
    $output .= "<tr><td><b>PR#: </b></td><td>$pd{prnumber}</td></tr>" if ($args{type} ne 'new');
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'ponumber', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        $output .= "<tr><td><b>PO#: </b></td><td>$pd{ponumber}";
        $output .= ((defined($pd{amendment}) && $pd{amendment} gt ' ') ? "$pd{amendment}" : "");
        $output .= "</td></tr>";
    }
    if ($args{history} eq 'T') {
        $output .= "<tr><td><b>Change Date</b></td><td>$pd{changedate}</td></tr>\n";
        $output .= "<tr><td><b>Changes</b></td><td>$pd{changes}</td></tr>\n";
    }
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'refnumber', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        if ($editable) {
            $output .= "<tr><td><b>Reference #: </b></td><td><input type=text name=refnumber size=10 maxlength=10 value=\"" . ((defined($pd{refnumber})) ? $pd{refnumber} : "") . "\">";
            $output .= "</td></tr>";
        } else {
            $output .= "<tr><td><b>Reference #: </b></td><td>" . ((defined($pd{refnumber})) ? $pd{refnumber} : "");
            $output .= "</td></tr>";
            $output .= "<input type=hidden name=refnumber value=\"" . ((defined($pd{refnumber})) ? $pd{refnumber} : "") . "\">\n";
        }
    } else {
        $output .= "<input type=hidden name=refnumber value=\"" . ((defined($pd{refnumber})) ? $pd{refnumber} : "") . "\">\n";
    }
    if ($args{history} eq 'T') {
        $output .= "<tr><td><b>Change Date</b></td><td>$pd{changedate}</td></tr>\n";
        $output .= "<tr><td><b>Changes</b></td><td>$pd{changes}</td></tr>\n";
    }
    $output .= "<input type=hidden name=entrytype value='$args{type}'>\n";
    $output .= "<input type=hidden name=status value=$pd{status}>\n";
    $output .= "<input type=hidden name=oldstatus value=$pd{status}>\n";
    $output .= "<input type=hidden name=prnumber value='$pd{prnumber}'>\n";
    $output .= "<input type=hidden name=datetest value=''>\n";
    $output .= "<input type=hidden name=pdtotal value='0'>\n";
    $output .= "<tr><td><b>Status: </b></td><td>" . &getPDStatusText(dbh=>$args{dbh}, schema=>$args{schema}, status=>$pd{status}) . "</td></tr>\n";
    $output .= "<tr><td><b>Author: </b></td><td>" . &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$pd{author}) . "</td></tr>\n";
    $output .= "<input type=hidden name=author value=$pd{author}>\n";
# requester
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'requester', status=>$pdStatus, browseOnly=>$browseOnly);
    $output .= "<tr><td><b>Requester: </b></td><td>";
    if ($editable) {
        my @users = &getUserArray(dbh=>$args{dbh}, schema=>$args{schema}, onlyActive=>'T');
        $output .= "<select name=requester size=1>\n";
        my $userFound = 'F';
        for (my $i=0; $i<$#users; $i++) {
            $output .= "<option value=$users[$i]{id}" . (($users[$i]{id} == $pd{requester}) ? " selected" : "") . ">$users[$i]{firstname} $users[$i]{lastname}</option>\n";
            if ($users[$i]{id} == $pd{requester}) {$userFound = 'T';}
        }
        if ($userFound eq 'F') {
            $output .= "<option value=$pd{requester} selected>" . &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$pd{requester}) . "</option>\n";
        }
        $output .= "</select>\n";
    } else {
        $output .= &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$pd{requester});
        $output .= "<input type=hidden name=requester value=$pd{requester}>\n";
    }
    $output .= "</td></tr>\n";

# buyer
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'buyer', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        $output .= "<tr><td><b>Buyer: </b></td><td>" . &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>((defined($pd{buyer})) ? $pd{buyer} : 0));
        $output .= ((defined($pd{amendedby})) ? &nbspaces(20) . "(Last amended by: " . &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$pd{amendedby}) . ")" : "");
        $output .= "</td></tr>\n";
    }
    
    $output .= "<tr><td><b>Department: </b></td><td>";
# dept
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'department', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable) {
        my @depts = &getDeptArray(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, role=>11, activeOnly => 'T');
        $output .= "<select name=deptid size=1><option value=0></option>\n";
        my $foundit = 'F';
        for (my $i=0; $i<$#depts; $i++) {
            $output .= "<option value=$depts[$i]{id}" . (($depts[$i]{id} == $pd{deptid}) ? " selected" : "") . ">$depts[$i]{sitename} - $depts[$i]{name}</option>\n";
            if ($depts[$i]{id} == $pd{deptid}) {
                $foundit = 'T';
            }
        }
        if ($foundit eq 'F') {
            my %deptInfo = getDeptInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$pd{deptid});
            $output .= "<option value=$pd{deptid}>$deptInfo{sitename} - $deptInfo{name} - disabled</option>\n";
        }
        $output .= "</select>\n";
    } else {
        my @depts = &getDeptArray(dbh=>$args{dbh}, schema=>$args{schema}, id=>$pd{deptid});
        $output .= "$depts[0]{sitename} - $depts[0]{name}";
        $output .= "<input type=hidden name=deptid value=$pd{deptid}>\n";
    }
    $output .= "</td></tr>\n";

# charge number    
    $output .= "<tr><td><b>Charge Number: </b></td><td>";
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'chargenumber', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable) {
        my @CNs = &getChargeNumberArray(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, role=>11);
        $output .= "<select name=chargenumber size=1><option value=0></option>\n";
        my $foundMatch = 'F';
        for (my $i=0; $i<$#CNs; $i++) {
            $output .= "<option value='$CNs[$i]{chargenumber}'";
            if ($CNs[$i]{chargenumber} eq $pd{chargenumber}) {
                $foundMatch = 'T';
                $output .= " selected"
            }
            $output .= ">$CNs[$i]{sitename} - $CNs[$i]{chargenumber} - $CNs[$i]{fyscalyear} - $CNs[$i]{description}</option>\n";
        }
        if ($foundMatch eq 'F') {
            @CNs = &getChargeNumberArray(dbh=>$args{dbh}, schema=>$args{schema}, onlyFY=>'F', id=>$pd{chargenumber});
            $output .= "<option value='" . ((defined($pd{chargenumber})) ? $pd{chargenumber} : "") . "' selected>" .
                ((defined($CNs[0]{sitename})) ? $CNs[0]{sitename} : "") . " - " . ((defined($CNs[0]{chargenumber})) ? $CNs[0]{chargenumber} : "") . 
                " - " . ((defined($CNs[0]{fyscalyear})) ? $CNs[0]{fyscalyear} : "") . " - " . ((defined($CNs[0]{description})) ? $CNs[0]{description} : "") . "</option>\n";
        }
        $output .= "</select>\n";
    } else {
        my @CNs = &getChargeNumberArray(dbh=>$args{dbh}, schema=>$args{schema}, onlyFY=>'F', id=>$pd{chargenumber});
        if (defined($CNs[0]{sitename}) && $CNs[0]{sitename} gt ' ') {
            $output .= "$CNs[0]{sitename} - $CNs[0]{chargenumber} - $CNs[0]{fyscalyear} - $CNs[0]{description}";
        } else {
            $output .= "$pd{chargenumber}";
        }
        $output .= "<input type=hidden name=chargenumber value=$pd{chargenumber}>\n";
    }
    $output .= "</td></tr>\n";

## briefdescription
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'briefdescription', status=>$pdStatus, browseOnly=>$browseOnly);
    $output .= "<tr><td><b>Brief Description: </b></td><td>";
    if ($editable) {
        $output .= "<input type=text name=briefdescription size=50 maxlength=50 value=\"$pd{briefdescription}\">";
    } else {
        $output .= "$pd{briefdescription}\n";
        $output .= "<input type=hidden name=briefdescription value=\"$pd{briefdescription}\">\n";
    }
    $output .= "</td></tr>\n";

## Vendor Name
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'winningvendor', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        $output .= "<tr><td><b>Vendor: &nbsp;</b></td><td>$pd{vendorname}</td></tr>\n";
    }

## po type
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'potype', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        $output .= "<tr><td><b>PO Type: </b></td><td>";
        my @types = ("", "Normal", "Blanket", "PO Maintenance/Partial Maintenance");
        if ($editable) {
            $output .= "<select name=potype size=1>\n";
            for (my $i=1; $i<=$#types; $i++) {
                $output .= "<option value=$i" . (($i==$pd{potype}) ? " selected" : "") . ">$types[$i]</option>\n";
            }
            $output .= "</select>\n";
        } else {
            $output .= "$types[$pd{potype}]";
        }
        $output .= "</td></tr>\n";
        $output .= "<tr><td><b>PO Date: </b></td><td>$pd{podate}</td></tr>\n";
    } else {
        $output .= "<input type=hidden name=potype value=$pd{potype}>\n";
    }

## blanket release info
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'blanketrelease', status=>$pdStatus, browseOnly=>$browseOnly);
    $output .= "<tr><td><b>Blanket&nbsp;Release&nbsp;PO: </b></td><td>";
    if ($editable) {
        my @blankets = &getBlanketContracts(dbh=>$args{dbh}, schema=>$args{schema});
        $output .= "<select name=blanketrelease size=1><option value=0>Not a blanket release</option>\n";
        for (my $i=0; $i<=$#blankets; $i++) {
            $output .= "<option value=$blankets[$i]{prnumber}" . ((defined($pd{relatedpr}) && $pd{relatedpr} eq $blankets[$i]{prnumber}) ? " selected" : "") . ">$blankets[$i]{ponumber} - $blankets[$i]{vendorname}</option>\n";
        }
        $output .= "</select>";
    } else {
        $output .= "<input type=hidden name=blanketrelease value=" . ((defined($pd{relatedpr}) && $pd{relatedpr} gt " ") ? $pd{relatedpr} : "0") . ">\n";
        if ($pd{contracttype} != 2) {
            $output .= "Not a blanket release\n";
        } else {
            $output .= "Release on blanket $pd{relatedprinfo}{ponumber}\n";
        }
    }
    $output .= "</td></tr>\n";

# Priority    
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'priority', status=>$pdStatus, browseOnly=>$browseOnly);
    $output .= "<tr><td><b>Priority: </b>";
    my %rule = &getRuleInfo(dbh=>$args{dbh}, schema=>$args{schema}, type=>10, site=>$pd{site});
    $rule{nvalue1} = ((defined($rule{nvalue1}) && $rule{nvalue1} > 1) ? $rule{nvalue1} : 90);
    $rule{nvalue2} = ((defined($rule{nvalue2}) && $rule{nvalue2} > 1) ? $rule{nvalue2} : 30);
    my $due30 = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, type=>'days', offset => $rule{nvalue2});
    my $due90 = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, type=>'days', offset => $rule{nvalue1});
    if ($editable) {
        $output .= "<input type=checkbox name=priority value='T'" . (($pd{priority} eq 'T') ? " checked" : "") . " onClick=\"setDateRequired(this)\">";
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--
function setDateRequired(what) {
// update daterequired based on priority
    if (what.checked == true) {
        $args{form}.daterequired.value = '$due30';
    } else {
        $args{form}.daterequired.value = '$due90';
    }
    
}
//--></script>

END_OF_BLOCK
    } else {
        $output .= (($pd{priority} eq 'T') ? "T" : "F");
        $output .= "<input type=hidden name=priority value=$pd{priority}>\n";
    }
# daterequired
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'daterequired', status=>$pdStatus, browseOnly=>$browseOnly);
    $output .= "</td><td><b>Date Required: </b>";
    if ($editable) {
        $output .= "<input type=text name=daterequired size=10 maxlength=10 value='$pd{daterequired}' onfocus=\"this.blur(); showCal('caldaterequired')\">";
        $output .= "<span id=\"daterequiredid\" style=\"position:relative;\">&nbsp;</span>";
    } else {
        $output .= $pd{daterequired};
        $output .= "<input type=hidden name=daterequired value='$pd{daterequired}'>\n";
    }
# duedate (delivery date)
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'duedate', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        $output .= &nbspaces(10) . "<b>Due/Delivery Date: </b>";
        if ($editable) {
            $output .= "<input type=text name=duedate size=10 maxlength=10 value='" . ((defined($pd{duedate})) ? $pd{duedate} : "") . "' onfocus=\"this.blur(); showCal('calduedate')\">";
            $output .= "<span id=\"duedateid\" style=\"position:relative;\">&nbsp;</span>";
        } else {
            $output .= $pd{duedate};
            $output .= "<input type=hidden name=duedate value='" . ((defined($pd{duedate})) ? $pd{duedate} : "") . "'>\n";
        }
    } else {
        $output .= "<input type=hidden name=duedate value='" . ((defined($pd{duedate})) ? $pd{duedate} : "") . "'>\n";
    }
    $output .= "</td></tr>\n";

## start end date
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'startenddates', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        $text = "<table border=0>\n";
        if ($editable) {
            $text .= "<tr><td><b>Start Date: </b>\n";
            $text .= "<input type=text name=startdate size=10 maxlength=10 value='" . ((defined($pd{startdate})) ? $pd{startdate} : "") . "' onfocus=\"this.blur(); showCal('calstartdate')\">";
            $text .= "<span id=\"startdateid\" style=\"position:relative;\">&nbsp;</span>";
            $text .= "</td><td><b>End Date: </b>\n";
            $text .= "<input type=text name=enddate size=10 maxlength=10 value='" . ((defined($pd{enddate})) ? $pd{enddate} : "") . "' onfocus=\"this.blur(); showCal('calenddate')\">";
            $text .= "<span id=\"enddateid\" style=\"position:relative;\">&nbsp;</span>";
            $text .= "</td></tr>\n";
        } else {
            $text .= "<tr><td><b>Start Date: </b>\n";
            $text .= ((defined($pd{startdate})) ? $pd{startdate} : "N/A &nbsp; ");
            $text .= "</td><td><b>End Date: </b>\n";
            $text .= ((defined($pd{enddate})) ? $pd{enddate} : "N/A");
            $text .= "</td></tr>\n";
        }
        $text .= "</table>\n";
        $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Start & End Dates (Blanket & Maintenance Contracts Only)</b>", contents=>$text) . "</td></tr>\n";
    }

## blanket approval list
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'brapprovallist', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        $text = "<table border=0><tr><td>\n";
        my @userList = &getUserArray(dbh=>$args{dbh}, schema=>$args{schema});
        $text .= "<table border=1 cellpadding=1 cellspacing=0>\n";
        $text .= "<tr bgcolor=#a0e0c0><td align=center width=100><b>Precedence</b></td><td width=200><b>Approver</b></td></tr>\n";
        if ($editable) {
            $text .= "<input type=hidden name=brapprovalcount value=$pd{brapprovallistCount}>\n";
            for (my $i=0; $i<$pd{brapprovallistCount}; $i++) {
                $text .= "<tr bgcolor=#ffffff><td align=center><input type=text size=2 maxlength=2 name=brprecedence$i value=$pd{brapprovallist}[$i]{precedence}></td><td><select size=1 name=bruserid$i><option value=0>None</option>\n";
                for (my $j=0; $j<$#userList; $j++) {
                    $text .= "<option value=$userList[$j]{id}" . (($userList[$j]{id} == $pd{brapprovallist}[$i]{userid}) ? " selected" : "") . ">";
                    $text .= "$userList[$j]{lastname}, $userList[$j]{firstname}</option>\n";
                }
                $text .= "</select></td></tr>\n";
            }
            $text .= "</table>\n";
            $text .= "<table cellpadding=0 cellspacing=0 border=0 id=postBRApprovalTable width=100%>";
            $text .= "<tr><td><a href=\"javascript:addBRApproval()\">Add Blanket Approval</a></td></tr>\n";
            my $userOptionList = "";
            for (my $i=0; $i<$#userList; $i++) {
                $userOptionList .= "<option value=$userList[$i]{id}>$userList[$i]{lastname}, $userList[$i]{firstname}</option>";
            }
            $text .= <<END_OF_BLOCK;

<script language=javascript><!--

function addBRApproval() {
// add an entry to the br approval table
    var brapps = document.$args{form}.brapprovalcount.value;
    var brapps2 = brapps;
    brapps2++;
    document.$args{form}.brapprovalcount.value = brapps2;
    var newBRAppRow = "";
    newBRAppRow += "<table border=1 cellpadding=1 cellspacing=0>\\n";
    newBRAppRow += "<tr bgcolor=#ffffff><td align=center width=100><input name=brprecedence" + brapps + " type=text size=2 maxlength=2 value='" + brapps + "' ></td>";
    newBRAppRow += "<td width=200><select size=1 name=bruserid" + brapps + "><option value=0>None</option>";
    newBRAppRow += "$userOptionList</select></td></tr>\\n";
    newBRAppRow += "</table>\\n";
    document.all.postBRApprovalTable.insertAdjacentHTML("BeforeBegin", "" + newBRAppRow + "");
}


//--></script>

END_OF_BLOCK
            
            $text .= "</td></tr></table>\n";
        } else {
            for (my $i=0; $i<$pd{brapprovallistCount}; $i++) {
                $text .= "<tr><td align=center>$pd{brapprovallist}[$i]{precedence}</td><td>";
                $text .= &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$pd{brapprovallist}[$i]{userid});
                $text .= "</td></tr>\n";
            }
            $text .= "</table>\n";
        }
        $text .= "</table>\n";
        $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Approval List (Blanket Contracts Only)</b>", contents=>$text) . "</td></tr>\n";
    }

## Credit card purchases
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'creditcardholder', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        $text = "<table border=0>\n";
        $text .= "<tr><td><b>Credit Card Holder: \n";
        if ($editable) {
            my @userList = &getUserArray(dbh=>$args{dbh}, schema=>$args{schema}, role=>19, roleSite=>0);
            $text .= "<select name=creditcardholder size=1><option value=0>None</option>\n";
            for (my $i=0; $i<$#userList; $i++) {
                $text .= "<option value=$userList[$i]{id}" . ((defined($pd{creditcardholder}) && $userList[$i]{id} == $pd{creditcardholder}) ? " selected" : "") .">$userList[$i]{lastname}, $userList[$i]{firstname}</option>\n";
            }
            $text .= "</select>\n";
        } else {
            if (defined($pd{creditcardholder}) && $pd{creditcardholder} > 0) {
                $text .= &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$pd{creditcardholder});
            } else {
                $text .= "None";
            }
        }
        $text .= "</td></tr>\n";
        $text .= "</table>\n";
        $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Credit Card Purchases</b>", contents=>$text) . "</td></tr>\n";
    }

## questions
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'questions', status=>$pdStatus, browseOnly=>$browseOnly);
    $text = "<table border=0>\n";
    $text .= "<input type=hidden name=questioncount value=$pd{questionCount}>\n";
    if ($pd{questionCount} > 0) {
        if ($editable) {
            for (my $i=0; $i<$pd{questionCount}; $i++) {
                my $tempText = $pd{questionList}[$i]{text};
                $tempText =~ s/\n/<br>/g;
                $tempText =~ s/"/''/g;
                $text .= "<tr><td>$tempText &nbsp; </td><td valign=top>";
                $text .= "<input type=radio name=questionanswer$i value=1" . (($pd{questionList}[$i]{answer} == 1) ? " checked" : "") . ">Yes &nbsp; ";
                $text .= "<input type=radio name=questionanswer$i value=2" . (($pd{questionList}[$i]{answer} == 2) ? " checked" : "") . ">No &nbsp; ";
                $text .= "<input type=radio name=questionanswer$i value=3" . (($pd{questionList}[$i]{answer} == 3) ? " checked" : "") . ">I Do Not Know</td></tr>\n";
                $text .= "<input type=hidden name=questiontext$i value=\"$tempText\">\n";
                $text .= "<input type=hidden name=questionprecedence$i value=$pd{questionList}[$i]{precedence}>\n";
                $text .= "<input type=hidden name=questionrole$i value=$pd{questionList}[$i]{role}>\n";
            }
        } else {
            for (my $i=0; $i<$pd{questionCount}; $i++) {
                my $answer = "Yes";
                if ($pd{questionList}[$i]{answer} == 2) {
                    $answer = "No";
                } elsif ($pd{quetionsList}[$i]{answer} == 3) {
                    $answer = "I Do Not Know";
                }
                $text .= "<tr><td>$pd{questionList}[$i]{text} &nbsp; </td><td valign=top>$answer</td></tr>\n";
                $text .= "<input type=hidden name=questionprecedence$i value=$pd{questionList}[$i]{precedence}>\n";
                $text .= "<input type=hidden name=questionanswer$i value=$pd{questionList}[$i]{answer}>\n";
           }
        }
    } else {
        $text .= "<tr><td>No questions found for Purchase Document</td></tr>\n";
    }
    $text .= "</table>\n";
    $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Oversite Routing Questions</b>", contents=>$text) . "</td></tr>\n";

## justification
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'justification', status=>$pdStatus, browseOnly=>$browseOnly);
    $text = "<table border=0>\n";
    if ($editable) {
        $text .= "<tr><td>";
        $text .= "<a href=\"javascript:expandTextBox(document.$args{form}.justification,document.justification_button,'force',5);\">";
        $text .= "<img name=justification_button border=0 src=$SYSImagePath/expand_button.gif align=top></a>";
        $text .= "<textarea name=justification cols=70 rows=4>$pd{justification}</textarea></td></tr>\n";
    } else {
        my $temp = $pd{justification};
        $temp =~ s/\n/<br>\n/g;
        $text .= "<tr><td>$temp</td></tr>\n";
        $temp =~ s/\n//g;
        $temp =~ s/"/&quot;/g; #"
        $text .= "<input type=hidden name=justification value=\"$temp\">\n";
    }
    $text .= "</table>\n";
    $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Justification</b>", contents=>$text) . "</td></tr>\n";
    
## Items
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'items', status=>$pdStatus, browseOnly=>$browseOnly);
    my @itemType = ('', 'Tangible Goods', 'Software', 'Service');
    my @ecArray = &getECArray(dbh=>$args{dbh}, schema=>$args{schema});
    my @unitArray = &getUnitIssue(dbh=>$args{dbh}, schema=>$args{schema});
    my $itemStyle = "font-family: verdana; font-size: 7pt;";
    my $helpStyle = "text-decoration:none; color:$SYSFontColor; cursor: help";
    $text = "<div style=\"$itemStyle\" id=items1>\n";
    $text .= "<table cellpadding=1 cellspacing=0 border=1 style=\"$itemStyle\">\n";
    my $itemCols = 11;
    $text .= "<tr bgcolor=#a0e0c0>";
    $text .= "<td valign=bottom width=70><b><a href=\"javascript:alert('Item Number (must be unique)');\" title='Item Number (must be unique)' style=\"$helpStyle\">#</a>/</b><br>\n";
    $text .= "<b><a href=\"javascript:alert('Part Number');\" title='Part Number' style=\"$helpStyle\">Part #</a></b></td>\n";
    $text .= "<td valign=bottom width=130><b><a href=\"javascript:alert('Product Description');\" title='Product Description' style=\"$helpStyle\">Description</a></b></td>\n";
    $text .= "<td valign=bottom width=40><b><a href=\"javascript:alert('Item Quantity');\" title='Item Quantity' style=\"$helpStyle\">Qty</a></b></td>\n";
    if ($pd{status} >= 17) {
        $text .= "<td valign=bottom width=40><b><a href=\"javascript:alert('Received');\" title='Received' style=\"$helpStyle\">Received</a></b></td>\n";
    }
    $text .= "<td valign=bottom width=60><b><a href=\"javascript:alert('Unit of Issue');\" title='Unit of Issue' style=\"$helpStyle\">Unit</a></b></td>\n";
    $text .= "<td valign=bottom width=45><b><a href=\"javascript:alert('Price per unit');\" title='Price per unit' style=\"$helpStyle\">Price</a></b></td>\n";
    $text .= "<td valign=bottom width=30><b><a href=\"javascript:alert('Substitution OK');\" title='Substitution OK' style=\"$helpStyle\">Sub</a>/</b><br>\n";
    $text .= "<b><a href=\"javascript:alert('Hazardous Material (Powder Paste or Liquid)');\" title='Hazardous Material (Powder paste or Liquid)' style=\"$helpStyle\">Haz</a></b></td>\n";
    $text .= "<td valign=bottom width=210><b><a href=\"javascript:alert('Element Code');\" title='Element Code' style=\"$helpStyle\">EC</a>/</b><br>\n";
    $text .= "<b><a href=\"javascript:alert('Type of item to be purchased');\" title='Type of item to be purchased' style=\"$helpStyle\">Type</a></b>\n";
    my $tiText = "<b><a href=\"javascript:alert('Technical Inspection Required');\" title='Technical Inspection Required' style=\"$helpStyle\">Technical Inspection</a></b>";
    #my $tiText = "<b><a href=\"javascript:alert('Technical Inspection Required');\" title='Technical Inspection Required' style=\"$helpStyle\">TI</a></b>";
    $text .= " &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;$tiText</td>\n";
    $text .= "<td valign=bottom width=60><b><a href=\"javascript:alert('Extended Price');\" title='Extended Price' style=\"$helpStyle\">Ext</a></b></td>\n";
    $text .= "</tr>\n";
    $text .= "<input type=hidden name=itemquantitychanged value='F'>\n";
    if ($editable) {
        my $subTotal = 0;
        my $tempItemCount = ((defined($pd{itemCount})) ? $pd{itemCount} : 0);
        $text .= "<input type=hidden name=itemcount value=$tempItemCount>\n";
        for (my $i=0; $i<$tempItemCount; $i++) {
            my ($q, $up) = (($pd{items}[$i]{quantity}*1.0), $pd{items}[$i]{unitprice});
            my $extPrice = ($q * $up);
            my $k = $i + 1;
            $subTotal += $extPrice;
            $text .= "<tr bgcolor=#ffffff id=itemRow$k><td valign=top><input name=itemnumber$k type=text size=2 maxlength=4 value=$pd{items}[$i]{itemnumber} style=\"$itemStyle\" onChange=\"checkItemNumber(this, $k);\" onBlur=\"checkItemNumber(this, $k);\">";
            $text .= " &nbsp; &nbsp; &nbsp; <a href=javascript:updateItemDesc($k)><img src=$SYSImagePath/expand_button.gif border=0 align=top></a><br>";
            $text .= "<input type=hidden name=olditemnumber$k value=$pd{items}[$i]{itemnumber}>\n";
            $text .= "<input name=partnumber$k type=text size=10 maxlength=30 value='" . ((defined($pd{items}[$i]{partnumber})) ? $pd{items}[$i]{partnumber} : "") . "' style=\"$itemStyle\"></td>";
            my $temp = $pd{items}[$i]{description};
            $text .= "<td valign=top><textarea name=description$k cols=20 rows=3 style=\"$itemStyle\">$temp</textarea></td>";
            $text .= "<td valign=top><input name=quantity$k type=text size=4 maxlength=4 value=$pd{items}[$i]{quantity} style=\"$itemStyle\" onChange=\"updatePrice(this, $form.unitprice$k, itemExt$k, $form.quantityreceived$k);\" onBlur=\"updatePrice(this, $form.unitprice$k, itemExt$k, $form.quantityreceived$k);\"></td>";
            $text .= "<input type=hidden name=quantitysave$k value=$pd{items}[$i]{quantity}>\n";
            $text .= "<input type=hidden name=quantityreceived$k value=$pd{items}[$i]{quantityreceived}>\n";
            $text .= "<td valign=top><select name=unitofissue$k size=1 style=\"$itemStyle\"><option value='0'></option>";
            for (my $j=0; $j<$#unitArray; $j++) {
                $text .= "<option value=$unitArray[$j]{unit}" . (($pd{items}[$i]{unitofissue} eq $unitArray[$j]{unit}) ? " selected" : "") . ">$unitArray[$j]{unit}</option>\n";
            }
            $text .= "</select></td>";
            $text .= "<td valign=top><input name=unitprice$k type=text size=5 maxlength=12 value='" . dFormat($pd{items}[$i]{unitprice}) . "' style=\"$itemStyle\" onChange=\"updatePrice($form.quantity$k, this, itemExt$k, $form.quantityreceived$k);\"></td>";
            $text .= "<td valign=top><input type=checkbox name=substituteok$k" . (($pd{items}[$i]{substituteok} eq 'T') ? " checked" : "") . " value='T' style=\"$itemStyle\"><br>";
            $text .= "<input type=checkbox name=ishazmat$k" . (($pd{items}[$i]{ishazmat} eq 'T') ? " checked" : "") . " value='T' style=\"$itemStyle\"></td>";
            $text .= "<td valign=top><select name=ec$k size=1 style=\"$itemStyle\" onChange=\"updateTotals();\"><option value='0'></option>\n";
            for (my $j=0; $j<$#ecArray; $j++) {
                $text .= "<option value=$ecArray[$j]{ec}" . (($pd{items}[$i]{ec} eq $ecArray[$j]{ec}) ? " selected" : "") . ">$ecArray[$j]{ec} - $ecArray[$j]{description}</option>\n";
            }
            $text .= "</select><br>\n";
            $text .= "<select name=type$k size=1 style=\"$itemStyle\">\n";
            for (my $j=1; $j<=$#itemType; $j++) {
                $text .= "<option value=$j" . (($pd{items}[$i]{type} == $j) ? " selected" : "") . ">$itemType[$j]</option>\n";
            }
            $text .= "</select>\n";
            $text .= " &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<input type=checkbox name=techinspection$k value='T' " . (($pd{items}[$i]{techinspection} eq 'T') ? " checked" : "") . ">";
            $text .= "</td>";
            $text .= "<td valign=top align=right><div id=itemExt" . ($i + 1) . ">" . dFormat($extPrice) . "</div>";
            $text .= "<br><a href=\"javascript:itemRemoveRestore($k);\"><div id=removeRestore" . $k . ">Remove</div></a></td></tr>\n";
            $text .= "<input type=hidden name=removeFlag$k value='F'>\n";
            $text .= "<input type=hidden name=itemTax$k value=0>\n";
        }
        $text .= "</table>\n";
        $text .= "<table cellpadding=0 cellspacing=0 border=0 id=postItemTable style=\\\"$itemStyle\\\" width=100%>";
        $text .= "<tr><td style=\\\"$itemStyle\\\"><table cellpadding=1 cellspacing=0 border=1 style=\\\"$itemStyle\\\"><tr bgcolor=#a0e0c0>";
        my $fontSize = "-2";
        $text .= "<td style=\\\"$itemStyle\\\" align=center width=100><font size=$fontSize><b>Sub Total</b></font></td>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center width=100><font size=$fontSize><b>Shipping</b></font></td>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center width=100><font size=$fontSize><b>Tax</b></font></td>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center width=100><font size=$fontSize><b>Total</b></font></td></tr><tr bgcolor=#ffffff>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center><font size=$fontSize><div id=subTotal>" . dFormat($subTotal) . "</div></font></td>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center><input name=shipping type=text size=5 maxlength=8 value='" . dFormat($pd{shipping}) . "' style=\"$itemStyle\" onChange=\"updateTotals();\"></td>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center><font size=$fontSize><div id=tax>" . dFormat($pd{tax}) . "</div></font></td>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center><font size=$fontSize><div id=total>" . dFormat($subTotal + $pd{shipping} + $pd{tax}) . "</div></font></td>\n";
        $text .= "</tr></table></td></tr>\n";
        $text .= "<tr><td style=\\\"$itemStyle\\\"><a href=javascript:addItem()><font size=-1>Add Item</font></a></td></tr></table>\n";
        $text .= <<END_OF_BLOCK;

<script language=javascript><!--
// function that returns true if a string contains only numbers
function isFloat(s) {
    if (s.length == 0) return false;
    var d=0;
    var m=0;
    for(var i = 0; i < s.length; i++) {
        var c = s.charAt(i);
        if (c == '.') d++;
        if (c == '-') m++;
        if (c == '-' && i > 0) m++;
        if (((c != '.') && (c != '-') && ((c < '0') || (c > '9'))) ||  d > 1 || m > 1) return false;
    }

    return true;
}
// function to remove/restore an item entry
function itemRemoveRestore(i) {
    myControl = document.getElementById('removeRestore' + i);
    myRow = document.getElementById('itemRow' + i);
    var code = "";
    var status = true;
    if (myControl.innerText == 'Remove') {
        myControl.innerText = 'Restore';
        code = "$form.removeFlag" + i + ".value = 'T';\\n";
        eval(code);
        status = true;
        myRow.bgColor='#dddddd';
    } else {
        myControl.innerText = 'Remove';
        code = "$form.removeFlag" + i + ".value = 'F';\\n";
        eval(code);
        status = false;
        myRow.bgColor='#ffffff';
    }
    code = ""
        +"$form.itemnumber"+i+".disabled = " + status + ";\\n$form.itemnumber"+i+".readonly = " + status + ";\\n"
        +"$form.partnumber"+i+".disabled = " + status + ";\\n$form.partnumber"+i+".readonly = " + status + ";\\n"
        +"$form.description"+i+".disabled = " + status + ";\\n$form.description"+i+".readonly = " + status + ";\\n"
        +"$form.quantity"+i+".disabled = " + status + ";\\n$form.quantity"+i+".readonly = " + status + ";\\n"
        +"$form.unitofissue"+i+".disabled = " + status + ";\\n$form.unitofissue"+i+".readonly = " + status + ";\\n"
        +"$form.unitprice"+i+".disabled = " + status + ";\\n$form.unitprice"+i+".readonly = " + status + ";\\n"
        +"$form.substituteok"+i+".disabled = " + status + ";\\n$form.substituteok"+i+".readonly = " + status + ";\\n"
        +"$form.ishazmat"+i+".disabled = " + status + ";\\n$form.ishazmat"+i+".readonly = " + status + ";\\n"
        +"$form.ec"+i+".disabled = " + status + ";\\n$form.ec"+i+".readonly = " + status + ";\\n"
        +"$form.type"+i+".disabled = " + status + ";\\n$form.type"+i+".readonly = " + status + ";\\n"
        +"";
    eval(code);
    var status = updateTotals();

}
function checkItemNumber(what, old) {
    var msg = "";
    var largest = 0;
    if (!isnumeric(what.value)) {
        msg += 'Item Number must be a positive number\\n';
        what.value = 0;
    }
    for (i=1; i <= $form.itemcount.value; i++) {
        var code = ""
            +"if (old != i && $form.itemnumber"+i+".value == what.value) {\\n"
            +"    msg = 'Item number must be unique';\\n"
            +"}\\n"
            +"if (($form.itemnumber"+i+".value - 0) > largest) {largest = $form.itemnumber"+i+".value;}\\n"
        + "";
        
        eval(code);
    }
    if (msg != "") {
        alert (msg);
        what.value = largest - 0 + 1;
    }
}
function updatePrice(qnty, prc, ext, rec) {
    var msg = "";
    if (isblank(qnty.value) || isblank(prc.value)) {
        ext.innerText = '0.00';
    }
    if (!isblank(qnty.value) && !isnumeric(qnty.value)) {
        msg +='Quantity must be a positive number';
        qnty.value = '';
        ext.innerText = '0.00';
    }
    if ((isblank(qnty.value) && rec.value > 0) || (qnty.value - 0) < (rec.value - 0)) {
        alert ('Quantity of ' + qnty.value + ' is less than amount received of ' + rec.value);
        qnty.value = rec.value;
    }
    if (!isblank(prc.value) && !isFloat(prc.value)) {
        msg +='Price must be a number';
        qnty.value = '';
        ext.innerText = '0.00';
    }
    if (msg != "") {
        alert (msg);
    } else {
        var price = (Math.round((qnty.value * prc.value) * 100.)/100.0);
        ext.innerText = dFormat(price);
    }
    var status = updateTotals();
    return 1;
}

function updateTotals() {
    var subTotalv = 0.0;
    var subTotalTaxable = 0.0;
    var taxv = 0.0;
    var totalv = 0.0;
    var shippingv = ($form.shipping.value - 0);
    var salesTax = ($form.salestax.value - 0) / 100.0;
    var iTax = 0.0;
    $form.itemquantitychanged.value='F';
    for (i=1; i <= $form.itemcount.value; i++) {
        var code = ""
            +"if ($form.removeFlag" + i + ".value != 'T') {\\n"
            +"    subTotalv += (itemExt" + i + ".innerText - 0);\\n"
END_OF_BLOCK
        my $ecTestCode = "";
        my @taxECs = &getSiteTaxableEC(dbh=>$args{dbh}, schema=>$args{schema}, deptID=>$pd{deptid});
        for (my $i=0; $i<$#taxECs; $i++) {
            $ecTestCode .= (($i > 0) ? " || " : "") . "$form.ec\" + i + \".value =='$taxECs[$i]{ec}'";
        }
        $text .= <<END_OF_BLOCK;
            +"    if ($ecTestCode) {\\n"
            +"        iTax = (itemExt" + i + ".innerText - 0);\\n"
            +"        subTotalTaxable += iTax;\\n"
            +"        iTax = (Math.round(iTax * salesTax * 100.0) / 100.0);\\n"
            +"        $form.itemTax" + i + ".value = iTax;\\n"
            +"    }\\n"
            +"    if ($form.quantity" + i + ".value != $form.quantitysave" + i + ".value) {\\n"
            +"        $form.itemquantitychanged.value='T';\\n"
            +"    }\\n"
            +"}\\n"
        + "";
        
        eval(code);
    }
    subTotalv = (Math.round(subTotalv * 100.0) / 100.0);
    if ($form.taxexempt.value == 'F') {
        taxv = (subTotalTaxable + shippingv) * salesTax;
        taxv = (Math.round(taxv * 100.0) / 100.0);
    }
    totalv = subTotalv + taxv + (shippingv - 0);
    totalv = (Math.round(totalv * 100.0) / 100.0);
    subTotal.innerText = dFormat(subTotalv);
    tax.innerText = dFormat(taxv);
    total.innerText = dFormat(totalv);
    $form.tax.value = dFormat(taxv);
    $form.pdtotal.value = totalv;
    return 1;
}

function dFormat (val) {
    var text = "";
    text += val;
    if (text.search(/\\.\\d\\d/) > 0) {
    } else if (text.search(/\\.\\d/) > 0) {
        text += '0';
    } else if (text.search(/\\./) > 0) {
        text += '00';
    } else {
        text += '.00';
    }
    return(text);
}

function addItem() {
// add an entry to the item table
    var largest = 0;
    var items = document.$args{form}.itemcount.value;
    items++;
    for (i=1; i <= $form.itemcount.value; i++) {
        var code = ""
            +"if (($form.itemnumber"+i+".value - 0) > largest) {largest = $form.itemnumber"+i+".value;}\\n"
        + "";
        
        eval(code);
    }
    largest++;
    document.$args{form}.itemcount.value = items;
    var newItemRow = "";
    newItemRow += "<table border=1 cellpadding=1 cellspacing=0 style=\\\"$itemStyle\\\">\\n";
    newItemRow += "<tr bgcolor=#ffffff id=itemRow" + items +"><td valign=top width=70><input name=itemnumber" + items + " type=text size=2 maxlength=4 value='" + largest + "' style=\\\"$itemStyle\\\" onChange=\\\"checkItemNumber(this, " + items + ");\\\">";
    newItemRow += " &nbsp; &nbsp; &nbsp; <a href=javascript:updateItemDesc(" + items + ")><img src=$SYSImagePath/expand_button.gif border=0 align=top></a><br>";
    newItemRow += "<input type=hidden name=olditemnumber"+ items + " value='0'>";
    newItemRow += "<input name=partnumber" + items + " type=text size=10 maxlength=30 value='' style=\\\"$itemStyle\\\"></td>";
    newItemRow += "<td valign=top width=130><textarea name=description" + items + " cols=20 rows=3 style=\\\"$itemStyle\\\"></textarea></td>";
    newItemRow += "<td valign=top width=40><input name=quantity" + items + " type=text size=4 maxlength=4 value='' style=\\\"$itemStyle\\\" onChange=\\\"updatePrice(this, $form.unitprice" + items + ", itemExt" + items + ", $form.quantityreceived" + items + ");\\\" onBlur=\\\"updatePrice(this, $form.unitprice" + items + ", itemExt" + items + ", $form.quantityreceived" + items + ");\\\"></td>";
    newItemRow += "<input type=hidden name=quantitysave" + items + " value='0'>\\n";
    newItemRow += "<input type=hidden name=quantityreceived" + items + " value='0'>\\n";
    newItemRow += "<td valign=top width=60><select name=unitofissue" + items + " size=1 style=\\\"$itemStyle\\\"><option value='0'></option>";
END_OF_BLOCK
    for (my $j=0; $j<$#unitArray; $j++) {
        $text .= "    newItemRow += \"<option value=$unitArray[$j]{unit}>$unitArray[$j]{unit}</option>\";";
    }
    $text .= <<END_OF_BLOCK;
    newItemRow += "</select></td>";
    newItemRow += "<td valign=top width=45><input name=unitprice" + items + " type=text size=5 maxlength=12 value='' style=\\\"$itemStyle\\\" onChange=\\\"updatePrice($form.quantity" + items + ", this, itemExt" + items + ", $form.quantityreceived" + items + ");\\\" onBlur=\\\"updatePrice($form.quantity" + items + ", this, itemExt" + items + ", $form.quantityreceived" + items + ");\\\"></td>";
    newItemRow += "<td valign=top width=30><input type=checkbox name=substituteok" + items + " value='T' checked style=\\\"$itemStyle\\\"><br>";
    newItemRow += "<input type=checkbox name=ishazmat" + items + " value='T' style=\\\"$itemStyle\\\"></td>";
    newItemRow += "<td valign=top width=210><select name=ec" + items + " value='T' size=1 style=\\\"$itemStyle\\\" onChange=\\\"updateTotals();\\\"><option value='0'></option>";
END_OF_BLOCK
    for (my $j=0; $j<$#ecArray; $j++) {
        $text .= "    newItemRow += \"<option value=$ecArray[$j]{ec}>$ecArray[$j]{ec} - $ecArray[$j]{description}</option>\";";
    }
    $text .= <<END_OF_BLOCK;
    newItemRow += "</select><br>\\n";
    newItemRow += "<select name=type" + items + " size=1 style=\\\"$itemStyle\\\">";
END_OF_BLOCK
    for (my $j=1; $j<=$#itemType; $j++) {
        $text .= "    newItemRow += \"<option value=$j>$itemType[$j]</option>\";";
    }
    $text .= <<END_OF_BLOCK;
    newItemRow += "</select>";
    newItemRow += " &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<input type=checkbox name=techinspection" + items + " value='T' checked>";
    newItemRow += "</td>\\n";
    newItemRow += "<td valign=top width=60 align=right><div id=itemExt" + items + ">0.00</div>";
    newItemRow += "<br><a href=\\\"javascript:itemRemoveRestore(" + items + ");\\\"><div id=removeRestore" + items + ">Remove</div></a></td></tr>\\n";
    newItemRow += "<input type=hidden name=removeFlag" + items + " value='F'>\\n";
    newItemRow += "<input type=hidden name=itemTax" + items + " value=0>\\n";
    newItemRow += "</table>\\n";
    document.all.postItemTable.insertAdjacentHTML("BeforeBegin", "" + newItemRow + "");
    
}

// **** JS to support foating item edit window


    function doUpdateItemDesc(id) {
        closeAllFloatingWindows();
        code = "$form.description" + id + ".value = $form.desctextedit.value;\\n" +
               "$form.description" + id + ".focus();\\n";
        eval (code);
        
        //var testText = main.notetextedit.value;
        //if (isblank(testText)) {
        //    alert('Please enter the note text');
        //} else {
        //    document.main.id.value = id;
        //    //document.main.nextscript.value='<%= scriptRoot %><%= request.getServletPath() %>?startscreen=tree';
        //    document.main.nextscript.value='<%= nextScript %>';
        //    //alert('rename ' + id);
        //    if (id == 0) {
        //        document.main.notetext.value = document.main.notetextedit.value;
        //        submitFormResults('<%= scriptRoot %>/doResources', 'addnote');
        //    } else {
        //        submitFormResults('<%= scriptRoot %>/doResources', 'updatenote');
        //    }
        //}
    }

    function cancelItemDescEdit(id) {
      	closeAllFloatingWindows();
        code = "$form.description" + id + ".focus();\\n";
        eval (code);
    }

    function updateItemDesc(id) {
      	closeAllFloatingWindows();
        code = "$form.desctextedit.value = $form.description" + id + ".value;\\n";
        eval (code);
        $form.desctextid.value = id;
        //alert($form.requester.style.visibility);
        $form.requester.style.visibility = "hidden"
        $form.deptid.style.visibility = "hidden"
        $form.chargenumber.style.visibility = "hidden"
        $form.briefdescription.style.visibility = "hidden"
        section = document.getElementById('descEditWindow');
        section.style.display='';
        $form.desctextedit.focus();
      	//document.main.id.value = id;
        //if (id != 0) {
        //    loadTextItem(id,'renameNote2');
        //} else {
        //    renameNote2();
        //}
    }

    function closeAllFloatingWindows() {
        section = document.getElementById('descEditWindow');
        section.style.display='none';
        $form.requester.style.visibility = "visible";
        $form.deptid.style.visibility = "visible";
        $form.chargenumber.style.visibility = "visible";
        $form.briefdescription.style.visibility = "visible";
    }

    closeAllFloatingWindows();

//--></script>

END_OF_BLOCK

    } else {
        my $subTotal = 0;
        for (my $i=0; $i<$pd{itemCount}; $i++) {
            my $temp = $pd{items}[$i]{description};
            $temp =~ s/\n/<br>\n/g;
            my $partNumber = ((defined($pd{items}[$i]{partnumber})) ? $pd{items}[$i]{partnumber} : "");
            $text .= "<tr bgcolor=#ffffff><td valign=top>$pd{items}[$i]{itemnumber}<br>$partNumber</td><td valign=top>$temp</td>";
            $text .= "<td valign=top>$pd{items}[$i]{quantity}</td>";
            if ($pd{status} >= 17) {
                $text .= "<td valign=top>$pd{items}[$i]{quantityreceived}</td>";
            }
            $text .= "<td valign=top>$pd{items}[$i]{unitofissue}</td><td valign=top>" . dollarFormat($pd{items}[$i]{unitprice}) . "</td>";
            $text .= "<td valign=top>$pd{items}[$i]{substituteok}<br>$pd{items}[$i]{ishazmat}</td><td valign=top>$pd{items}[$i]{ec}<br>";
            $text .= "$itemType[$pd{items}[$i]{type}] &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; $pd{items}[$i]{techinspection}</td>";
            my $extPrice = ($pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice});
            $text .= "<td valign=top>" . dollarFormat($extPrice) . "</td></tr>\n";
            $subTotal += $extPrice;
        }
        $text .= "</table>\n";
        my $fontSize = "-2";
        $text .= "<table cellpadding=1 cellspacing=0 border=1 style=\\\"$itemStyle\\\"><tr bgcolor=#a0e0c0>";
        $text .= "<td style=\\\"$itemStyle\\\" align=center width=100><font size=$fontSize><b>Sub Total</b></font></td>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center width=100><font size=$fontSize><b>Shipping</b></font></td>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center width=100><font size=$fontSize><b>Tax</b></font></td>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center width=100><font size=$fontSize><b>Total</b></font></td></tr><tr bgcolor=#ffffff>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center><font size=$fontSize><div id=subTotal>" . dollarFormat($subTotal) . "</div></font></td>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center><font size=$fontSize><div id=shipping>" . dollarFormat($pd{shipping}) . "</div></td>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center><font size=$fontSize><div id=tax>" . dollarFormat($pd{tax}) . "</div></font></td>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center><font size=$fontSize><div id=total>" . dollarFormat($subTotal + $pd{shipping} + $pd{tax}) . "</div></font></td>\n";
        $text .= "</tr></table>\n";
    }
    $text .= "</div>\n";
    $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Item List</b>", contents=>$text) . "</td></tr>\n";
    
## Sole Source
    $text = "<table border=0>\n";
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'solesource', status=>$pdStatus, browseOnly=>$browseOnly);
    $text .= "<tr><td><b>Is Sole Source: </b>";
    if ($editable) {
        $text .= "<input type=checkbox name=solesource value='T'" . (($pd{solesource} eq 'T') ? " checked" : "") . ">";
    } else {
        $text .= (($pd{solesource} eq 'T') ? "T" : "F");
        $text .= "<input type=hidden name=solesource value=$pd{priority}>\n";
    }
    $text .= "</td></tr>\n";
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'ssjustification', status=>$pdStatus, browseOnly=>$browseOnly);
    $text .= "<tr><td><b>Sole Source Justification: </b><br>";
    if ($editable) {
        $text .= "<tr><td>\n";
        $text .= "<a href=\"javascript:expandTextBox(document.$args{form}.ssjustification,document.ssjustification_button,'force',5);\">";
        $text .= "<img name=ssjustification_button border=0 src=$SYSImagePath/expand_button.gif align=top></a>";
        $text .= "<textarea name=ssjustification cols=70 rows=4>" . ((defined($pd{ssjustification})) ? $pd{ssjustification} : "") . "</textarea></td></tr>\n";
    } else {
        my $temp = ((defined($pd{ssjustification})) ? $pd{ssjustification} : "");
        $temp =~ s/\n/<br>\n/g;
        $text .= "<tr><td>$temp</td></tr>\n";
        $temp =~ s/\n//g;
        $temp =~ s/"/&quot;/g; #"
        $text .= "<input type=hidden name=ssjustification value=\"$temp\">\n";
    }
    $text .= "</td></tr>\n";
    $text .= "</table>\n";
    $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Sole Source</b>", contents=>$text) . "</td></tr>\n";
    
## Vendor List
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'vendorlist', status=>$pdStatus, browseOnly=>$browseOnly);
    $text = "<table border=0>\n";
    tie my %availVendors, "Tie::IxHash";
    my @vendorList = &getVendorList(dbh=>$args{dbh}, schema=>$args{schema});
    for (my $i=0; $i<$#vendorList; $i++) {
        $availVendors{$vendorList[$i]{id}} = "$vendorList[$i]{name} - " . ((defined($vendorList[$i]{city})) ? $vendorList[$i]{city} : "") . ", " . 
            ((defined($vendorList[$i]{state})) ? $vendorList[$i]{state} : "");
    }
    $text .= "<tr><td>\n";
    if ($editable) {
        tie my %currVendors, "Tie::IxHash";
        %currVendors = ();
        for (my $i=0; $i<$pd{vendorCount}; $i++) {
            $currVendors{$pd{vendorList}[$i]{vendor}} = "$availVendors{$pd{vendorList}[$i]{vendor}}";
        }
        $text .= build_dual_select ('vendorlist', "$args{form}", \%availVendors, \%currVendors, "<b>Available Vendors</b>", "<b>Selected Vendors</b>", 0);
    } else {
        for (my $i=0; $i<$pd{vendorCount}; $i++) {
            $text .= "$availVendors{$pd{vendorList}[$i]{vendor}}<br>";
        }
    }
    $text .= "</td></tr>\n";
##     Winning Vendor
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'winningvendor', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        $text .= "<tr><td>--------------</td></tr><tr><td>Winning Vendor: &nbsp; $pd{vendorname}\n";
        my %vendor = &getVendorInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$pd{vendor});
        $text .= "<br>" . &nbspaces(20) . "Point of Contact:  $vendor{pointofcontact}";
        $text .= ((defined($vendor{phone})) ? "<br>" . &nbspaces(20) . "Phone: $vendor{phone}" : "") . ((defined($vendor{extension})) ? " - $vendor{extension}" : "");
        $text .= ((defined($vendor{fax})) ? "<br>" . &nbspaces(20) . "FAX: $vendor{fax}" : "");
        $text .= ((defined($vendor{email})) ? "<br>" . &nbspaces(20) . "$vendor{email}" : "");
        $text .= "</td></tr>\n";
    }
    $text .= "</table>\n";
    $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Vendor List</b>", contents=>$text) . "</td></tr>\n";


## RFP
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'rfp', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        $text = "<table border=0>\n";
        if ($editable) {
            $text .= "<tr><td><b>FOB: <input type=radio name=fob value=1" . (($pd{fob} == 1) ? " checked" : "") . ">Origin &nbsp; ";
            $text .= "<input type=radio name=fob value=2" . (($pd{fob} == 2) ? " checked" : "") . ">Destination &nbsp; ";
            $text .= "<input type=radio name=fob value=3" . (($pd{fob} == 3) ? " checked" : "") . ">N/A</b></td></tr>\n";
            $text .= "<tr><td><b>Delivery Date <input type=text name=rfpdeliverdays size=3 maxlength=3 value=" . ((defined($pd{rfpdeliverdays}) && $pd{rfpdeliverdays} > 0) ? $pd{rfpdeliverdays} : "") . "> Days</b></td></tr>\n";
            $text .= "<tr><td><b>Offer Valid For <input type=text name=rfpdaysvalid size=3 maxlength=3 value=" . ((defined($pd{rfpdaysvalid}) && $pd{rfpdaysvalid} > 0) ? $pd{rfpdaysvalid} : "") . "> Days</b></td></tr>\n";
            $text .= "<tr><td><b>RFP Due On or Before <input type=text name=rfpduedate size=10 maxlength=10 value='" . ((defined($pd{rfpduedate})) ? $pd{rfpduedate} : "") . "' onfocus=\"this.blur(); showCal('calrfpduedate')\">";
            $text .= "<span id=\"rfpduedateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
        } else {
            $text .= "<tr><td><b>FOB: </b>" . ("","Origin","Destination","N/A")[$pd{fob}] . "</td></tr>\n";
            $text .= "<input type=hidden name=fob value=$pd{fob}>\n";
            $text .= "<tr><td>Delivery Date " . ((defined($pd{rfpdeliverdays})) ? $pd{rfpdeliverdays} : "N/A") . " Days</b></td></tr>\n";
            $text .= "<input type=hidden name=rfpdeliverdays value=" . ((defined($pd{rfpdeliverdays})) ? $pd{rfpdeliverdays} : "''") . ">\n";
            $text .= "<tr><td>Offer Valid For " . ((defined($pd{rfpdaysvalid})) ? $pd{rfpdaysvalid} : "N/A") . " Days</b></td></tr>\n";
            $text .= "<input type=hidden name=rfpdaysvalid value=" . ((defined($pd{rfpdaysvalid})) ? $pd{rfpdaysvalid} : "''") . ">\n";
            $text .= "<tr><td>RFP Due On or Before " . ((defined($pd{rfpduedate})) ? $pd{rfpduedate} : "N/A");
            $text .= "<input type=hidden name=rfpduedate value=" . ((defined($pd{rfpduedate})) ? $pd{rfpduedate} : "''") . ">\n";
        }
#
        ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'rfp2', status=>$pdStatus, browseOnly=>$browseOnly);
        if ($displayed) {
            if ($editable) {
                $text .= "<tr><td><b>Ship Via: </b><input type=text name=shipvia size=20 maxlength=50 value=\"" . ((defined($pd{shipvia})) ? $pd{shipvia} : "") . "\"></td></tr>\n";
                $text .= "\n";
                $text .= "<tr><td><b>Terms: </b><input type=text name=paymentterms size=20 maxlength=50 value=\"" . ((defined($pd{paymentterms})) ? $pd{paymentterms} : "") . "\"></td></tr>\n";
                $text .= "\n";
            } else {
                $text .= "<tr><td><b>Ship Via: </b>$pd{shipvia}</td></tr>\n";
                $text .= "<input type=hidden name=shipvia value=\"" . ((defined($pd{shipvia})) ? $pd{shipvia} : "") . "\">\n";
                $text .= "<tr><td><b>Terms: </b>$pd{paymentterms}</td></tr>\n";
                $text .= "<input type=hidden name=paymentterms value=\"" . ((defined($pd{paymentterms})) ? $pd{paymentterms} : "") . "\">\n";
            }
        }
        $text .= "</table>\n";
        $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>RFP</b>", contents=>$text) . "</td></tr>\n";
    }

## Clauses
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'clauses', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        my ($displayedpo, $editablepo) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'clausespoflag', status=>$pdStatus, browseOnly=>$browseOnly);
        $text = "<table border=0>\n";
        if ($editable) {
            $text .= "<input type=hidden name=clausecount value=$pd{clauseCount}>\n";
            my $spaces20 = nbspaces(20);
            for (my $i=0; $i<$pd{clauseCount}; $i++) {
                my $k = $i + 1;
                $text .= "<input type=hidden name=oldprecedence$k value=$pd{clause}[$i]{precedence}>\n";
                $text .= "<input type=hidden name=removeflag$k value='F'>\n";
                $text .= "<tr><td><b>Precedence: </b><input type=text name=precedence$k size=2 maxlength=3 value=$pd{clause}[$i]{precedence} onChange=\"checkClauseNumber(this, $k);\">";
                $text .= "$spaces20<b>Type: </b><select name=clausetype$k size=1><option value='H'" . (($pd{clause}[$i]{type} eq 'H') ? " selected" : "") . ">Header</option>";
                $text .= "<option value='F'" . (($pd{clause}[$i]{type} eq 'F') ? " selected" : "") . ">Footer</option></select>\n";
                $text .= "$spaces20<b>";
                $text .= "<input type=hidden name=clauserfp$k value='$pd{clause}[$i]{rfp}'>\n";
                if ($editablepo) {
                    $text .= "RFP: </b>$pd{clause}[$i]{rfp} &nbsp; <b>PO: <input type=checkbox name=clausepo$k value='T' " . (($pd{clause}[$i]{po} eq 'T') ? " checked" : "") . "></b></td></tr>\n";
                } else {
                    $text .= "<a href=\"javascript:removeClause($k);\">Remove</a></b></td></tr>\n";
                    $text .= "<input type=hidden name=clausepo$k value='$pd{clause}[$i]{po}'>\n";
                }
                $text .= "<tr><td><textarea name=clause$k cols=80 rows=5>$pd{clause}[$i]{text}</textarea><br>&nbsp;</td></tr>\n";
            }
            $text .= "<table cellpadding=0 cellspacing=0 border=0 id=postClauseTable width=100%>";
            $text .= "<tr><td><select name=clauseselect size=1><option value=0>Blank</option>\n";
            my @clauses = &getClauseArray(dbh=>$args{dbh}, schema => $args{schema});
            for (my $i=0; $i<$#clauses; $i++) {
                $text .= "<option value=$clauses[$i]{id}>" . &getDisplayString($clauses[$i]{description}, 100) . "</option>\n";
            }
            $text .= "</select> &nbsp; <input type=button name=clausebutton value='Add Clause' onClick=\"addClause();\"></td></tr>\n";
            $text .= <<END_OF_BLOCK;

<script language=javascript><!--

function checkClauseNumber(what, old) {
    var msg = "";
    var largest = 0;
    if (!isnumeric(what.value)) {
        msg += 'Clause Precedence  must be a positive number\\n';
        what.value = 0;
    }
    for (i=1; i <= $form.clausecount.value; i++) {
        var code = ""
            +"if (old != i && $form.precedence"+i+".value == what.value) {\\n"
            +"    msg = 'Clause Precedence must be unique';\\n"
            +"}\\n"
            +"if ($form.precedence"+i+".value > largest) {largest = $form.precedence"+i+".value;}\\n"
        + "";
        
        eval(code);
    }
    if (msg != "") {
        alert (msg);
        what.value = largest - 0 + 1;
    }
}

function removeClause(id) {
// flag a clause as removed and dim the elements
    var code = ""
            +"var disabled = $form.removeflag"+id+".value == 'T' ? false : true;\\n"
            +"$form.precedence"+id+".disabled=disabled;\\n"
            +"$form.clausetype"+id+".disabled=disabled;\\n"
            +"$form.clause"+id+".disabled=disabled;\\n"
            +"$form.removeflag"+id+".value=$form.removeflag"+id+".value == 'T' ? 'F' : 'T';\\n"
        + "";
        
    eval(code);
}

function addClause() {
// add an entry to the clause table
    var largest = 0;
    var clauses = document.$args{form}.clausecount.value;
    clauses++;
    for (i=1; i <= $form.clausecount.value; i++) {
        var code = ""
            +"if (($form.precedence"+i+".value - 0) > largest) {largest = $form.precedence"+i+".value;}\\n"
        + "";
        
        eval(code);
    }
    largest++;
    document.$args{form}.clausecount.value = clauses;
    var newClauseRow = "";
    newClauseRow += "<input type=hidden name=oldprecedence"+ clauses + " value='0'>";
    newClauseRow += "<input type=hidden name=removeflag"+ clauses + " value='F'>";
    newClauseRow += "<table border=0>\\n";
    newClauseRow += "<tr><td><b>Precedence: </b><input name=precedence" + clauses + " type=text size=2 maxlength=3 value='" + largest + "' onChange=\\\"checkClauseNumber(this, " + largest + ");\\\">";
    newClauseRow += "$spaces20<b>Type: </b><select name=clausetype" + clauses + " size=1><option value='H'>Header</option><option value='F' selected>Footer</option></select>\\n";
    newClauseRow += "$spaces20<b>\\n";
END_OF_BLOCK
            if ($editablepo) {
                $text .= <<END_OF_BLOCK;
    newClauseRow += "RFP: F &nbsp; PO: <input type=checkbox name=clausepo" + clauses + " value='T'  checked> &nbsp; &nbsp;\\n";
    newClauseRow += "<input type=hidden name=clauserfp" + clauses + " value='F'>\\n";
END_OF_BLOCK
            } else {
            $text .= <<END_OF_BLOCK;
    newClauseRow += "<input type=hidden name=clauserfp" + clauses + " value='T'>\\n";
    newClauseRow += "<input type=hidden name=clausepo" + clauses + " value='F'>\\n";
END_OF_BLOCK
            }
            $text .= <<END_OF_BLOCK;
    newClauseRow += "<a href=\\\"javascript:removeClause(" + clauses + ");\\\">Remove</a></b></td></tr>\\n";
    newClauseRow += "<tr><td><textarea name=clause" + clauses + " cols=80 rows=5></textarea><br>&nbsp;</td></tr>\\n";
    newClauseRow += "</table>\\n";
    document.all.postClauseTable.insertAdjacentHTML("BeforeBegin", "" + newClauseRow + "");
    if (!$form.clauseselect[0].selected) {
        $form.id.value=clauses;
        submitFormCGIResults('purchaseDocuments', 'addclausetext');
    }
}

//--></script>

END_OF_BLOCK

        } else {
            my $spaces20 = nbspaces(20);
            for (my $i=0; $i<$pd{clauseCount}; $i++) {
                my $k = $i + 1;
                $text .= "<tr><td><b>Precedence: </b>$pd{clause}[$i]{precedence}";
                my %clauseType = (H=>"Header", F=>"Footer");
                $text .= "$spaces20<b>Type: </b>$clauseType{$pd{clause}[$i]{type}}";
                $text .= "$spaces20<b>RFP: </b>$pd{clause}[$i]{rfp}$spaces20<b>PO: </b>$pd{clause}[$i]{po}";
                $text .= "</td></tr>\n";
                # parse clase text
                my $clause = $pd{clause}[$i]{text};
                $clause =~ s/<RFPDaysValid>/$pd{rfpdaysvalid}/g;
                $clause =~ s/<RFPDueDate>/$pd{rfpduedate}/g;
                $clause =~ s/<RFPDeliverDays>/$pd{rfpdeliverdays}/g;
                $clause =~ s/\n/<br>/g;
                $text .= "<tr><td>$clause<br>&nbsp;</td></tr>\n";
            }
        }
        $text .= "</table>\n";
        $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Clauses</b>", contents=>$text) . "</td></tr>\n";
    }

## selcetion and summary memo
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'selectionsummemo', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        $text = "<table border=0 width=100%>\n";
        if ($editable) {
            $text .= "<tr><td><a href=\"javascript:expandTextBox(document.$args{form}.selectionsummemo,document.selectionsummemo_button,'force',5);\">";
            $text .= "<img name=selectionsummemo_button border=0 src=$SYSImagePath/expand_button.gif align=top></a>";
            $text .= "<textarea name=selectionmemo cols=70 rows=4>" . ((defined($pd{selectionmemo})) ? $pd{selectionmemo} : "") . "</textarea>\n";
        } else {
            my $memo = ((defined($pd{selectionmemo})) ? $pd{selectionmemo} : "");
            $memo =~ s/\n/<br>/g;
            $memo =~ s/  / &nbsp;/g;
            $text .= "<tr><td>$memo\n";
        }
        $text .= "</table>\n";
    $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Selection and Summary Memo</b>", contents=>$text) . "</td></tr>\n";
    }

## enclosures
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'enclosures', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        $text = "<table border=0 width=100%>\n";
        if ($editable) {
            $text .= "<tr><td><a href=\"javascript:expandTextBox(document.$args{form}.enclosures,document.enclosures_button,'force',5);\">";
            $text .= "<img name=enclosures_button border=0 src=$SYSImagePath/expand_button.gif align=top></a>";
            $text .= "<textarea name=enclosures cols=70 rows=4>" . ((defined($pd{enclosures})) ? $pd{enclosures} : "") . "</textarea>\n";
        } else {
            my $enclosures = ((defined($pd{enclosures})) ? $pd{enclosures} : "");
            $enclosures =~ s/\n/<br>/g;
            $enclosures =~ s/  / &nbsp;/g;
            $text .= "<tr><td>$enclosures\n";
        }
        $text .= "</table>\n";
    $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Enclosures</b>", contents=>$text) . "</td></tr>\n";
    }

## Receiving Log
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'rlog', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        my @rLog = &getReceiving(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pd{prnumber});
        $text = "<table border=0>\n";
        for (my $i=0; $i<$#rLog; $i++) {
            $text .= "<tr><td><b>Date Received: </b></td><td>$rLog[$i]{datereceived}</td></tr>\n";
            $text .= "<tr><td><b>Shipped Via: </b></td><td>$rLog[$i]{shipvia}</td></tr>\n";
            $text .= "<tr><td><b>Shiment Number: </b></td><td>" . ((defined($rLog[$i]{shipmentnumber})) ? $rLog[$i]{shipmentnumber} : "") . "</td></tr>\n";
            $text .= "<tr><td><b>Delivered To: </b></td><td>" . ((defined($rLog[$i]{deliveredto})) ? $rLog[$i]{deliveredto} : "") . "</td></tr>\n";
            $text .= "<tr><td><b>Date Delivered: </b></td><td>" . ((defined($rLog[$i]{datedelivered})) ? $rLog[$i]{datedelivered} : "") . "</td></tr>\n";
            my $rLogComments = ((defined($rLog[$i]{comments})&& $rLog[$i]{comments} gt "") ? $rLog[$i]{comments} : "");
            $rLogComments =~ s/\n/<br>/g;
            $rLogComments =~ s/  / &nbsp;/g;
            $text .= "<tr><td><b>Comments: </b></td><td>" . ((defined($rLogComments) && $rLogComments gt " ") ? $rLogComments : "") . "</td></tr>\n";
            $text .= "<tr><td colspan=2><table border=0 cellpadding=1 cellspacing=0><tr><td> &nbsp; &nbsp;</td><td><table cellpadding=1 cellspacing=0 border=1>\n";
            $text .= "<tr bgcolor=#a0e0c0><td align=center><b>Item Number</b></td><td align=center><b>Quantity Received</b></td>";
            $text .= "<td align=center><b>Quality Code</b></td></tr>\n";
            for (my $j=0; $j<$rLog[$i]{itemCount}; $j++) {
                $text .= "<tr bgcolor=#ffffff><td align=center>$rLog[$i]{items}[$j]{itemnumber}</td>";
                $text .= "<td align=center>$rLog[$i]{items}[$j]{quantityreceived}</td>";
                $text .= "<td align=center>" . ((defined($rLog[$i]{items}[$j]{qualitycode})) ? $rLog[$i]{items}[$j]{qualitycode} : "") . "</td></tr>\n";
            }
            $text .= "</table></td></tr>\n";
            $text .= "</table>\n";
            $text .= "<hr width=75%>\n";
        }
        
        $text .= "</table>\n";
        $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Receiving Log</b>", contents=>$text) . "</td></tr>\n";
    }
## charge distribution list
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'chargedistribution', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        my $cdStyle = "font-family: verdana; font-size: 7pt;";
        $text = "<div style=\"$cdStyle\" id=cd1>\n";
        $text = "<table border=0 style=\"$cdStyle\"><tr><td>\n";
        my @CNs = &getChargeNumberArray(dbh=>$args{dbh}, schema=>$args{schema}, site=>$pd{site}, onlyFY=>'F');
        my $CNOptions = "";
        for (my $i=0; $i<$#CNs; $i++) {
            $CNOptions .= "<option value='$CNs[$i]{chargenumber}'>$CNs[$i]{sitename} - $CNs[$i]{chargenumber} - $CNs[$i]{fyscalyear} - ";
            $CNOptions .= &getDisplayString($CNs[$i]{description},35) . "</option>";
        }
        my @ecArray = &getECArray(dbh=>$args{dbh}, schema=>$args{schema});
        my $ecOptions = "";
        for (my $i=0; $i<$#ecArray; $i++) {
            $ecOptions .= "<option value=$ecArray[$i]{ec}>$ecArray[$i]{ec} - $ecArray[$i]{description}</option>";
        }
        $text .= "<table border=1 cellpadding=1 cellspacing=0 style=\"$cdStyle\">\n";
        $text .= "<tr bgcolor=#a0e0c0><td" . (($editable) ? " width=400" : "") . "><b>Charge Number</b></td>";
        $text .= "<td" . (($editable) ? " width=200" : "") . "><b>EC</b></td>";
        $text .= "<td" . (($editable) ? " width=50" : "") . " align=center><b>Amount</b></td>";
        $text .= "<td" . (($editable) ? " width=50" : "") . " align=center><b>Invoiced</b></td>";
        $text .= ((!$editable) ? "<td align=center><b>Balance</b></td>\n" : "<td>&nbsp;</td>");
        $text .= "</tr>\n";
        if ($editable) {
            $text .= "<input type=hidden name=chargedistcount value=$pd{chargedistlistCount}>\n";
            my $cdTotalAmount = 0;
            my $cdTotalInvoiced = 0;
            for (my $i=0; $i<$pd{chargedistlistCount}; $i++) {
                $text .= "<tr bgcolor=#ffffff><td><select size=1 name=cdchargenumber$i style=\"$cdStyle\"><option value=0></option>\n";
                my $foundMatch = 'F';
                for (my $j=0; $j<$#CNs; $j++) {
                    $text .= "<option value='$CNs[$j]{chargenumber}'";
                    if ($CNs[$j]{chargenumber} eq $pd{chargedistlist}[$i]{chargenumber}) {
                        $foundMatch = 'T';
                        $text .= " selected"
                    }
                    $text .= ">$CNs[$j]{sitename} - $CNs[$j]{chargenumber} - $CNs[$j]{fyscalyear} - ";
                    $text .= &getDisplayString($CNs[$j]{description},35) . "</option>\n";
                }
                if ($foundMatch eq 'F') {
                    my @CNs2 = &getChargeNumberArray(dbh=>$args{dbh}, schema=>$args{schema}, onlyFY=>'F', id=>$pd{chargedistlist}[$i]{chargenumber});
                    $text .= "<option value='" . ((defined($pd{chargedistlist}[$i]{chargenumber})) ? $pd{chargedistlist}[$i]{chargenumber} : "") . "' selected>" .
                        ((defined($CNs2[0]{sitename})) ? $CNs2[0]{sitename} : "") . " - " . ((defined($CNs2[0]{chargenumber})) ? $CNs2[0]{chargenumber} : "") . 
                        " - " . ((defined($CNs2[0]{fyscalyear})) ? $CNs2[0]{fyscalyear} : "") . " - " . ((defined($CNs2[0]{description})) ? $CNs2[0]{description} : "") . "</option>\n";
                }
                $text .= "</select></td>\n";
                $text .= "<td><select size=1 name=cdec$i style=\"$cdStyle\"><option value=0></option>\n";
                for (my $j=0; $j<$#ecArray; $j++) {
                    $text .= "<option value=$ecArray[$j]{ec}" . (($pd{chargedistlist}[$i]{ec} eq $ecArray[$j]{ec}) ? " selected" : "") . ">$ecArray[$j]{ec} - $ecArray[$j]{description}</option>\n";
                }
                $text .= "</select></td>\n";
                $text .= "<td><input type=text name=cdamount$i size=7 maxlength=12 value='" . dFormat($pd{chargedistlist}[$i]{amount}) . "' style=\"$cdStyle\" onChange=\"updateCDTotals();\"></td>";
                $text .= "<td align=right>" . dFormat($pd{chargedistlist}[$i]{invoiced}) . "</td>\n";
                $text .= "<input type=hidden name=cddelete$i value='F'>\n";
                $text .= (($editable && $pd{chargedistlist}[$i]{invoiced} == 0.0) ? "<td><a href=javascript:deleteCD($i)>delete</a></td>" : "");
                $text .= "</tr>\n";
                $cdTotalAmount += $pd{chargedistlist}[$i]{amount};
                $cdTotalInvoiced += $pd{chargedistlist}[$i]{invoiced};
                $text .= "<input type=hidden name=cdinvoiced$i value='$pd{chargedistlist}[$i]{invoiced}'>\n";
            }
            $text .= "</table>\n";
            $text .= "<table cellpadding=0 cellspacing=0 border=0 id=postChargeDistributionTable width=100%>";
            $text .= "<tr><td>\n";
            $text .= "<table border=1 cellpadding=1 cellspacing=0 style=\"$cdStyle\">\n";
            $text .= "<tr bgcolor=#a0e0c0><td><b>Total Amount</b></td><td><b>Total Invoiced</b></td></tr>";
            $text .= "<tr bgcolor=#ffffff><td align=right><div id=cdTotal>" . dFormat($cdTotalAmount) . "</div></td><td align=right>" . dFormat($cdTotalInvoiced) . "</td></tr>\n";
            $text .= "</table>\n";
            $text .= "</td></tr>\n";
            $text .= "<tr><td><a href=\"javascript:addChargedistribution()\" style=\"$cdStyle\">Add Charge Distribution</a></td></tr>\n";
            $text .= "</table>\n";
            $text .= <<END_OF_BLOCK;

<script language=javascript><!--

function addChargedistribution() {
// add an entry to the charge distribution table
    var cds = document.$args{form}.chargedistcount.value;
    var cds2 = cds;
    cds2++;
    document.$args{form}.chargedistcount.value = cds2;
    var newCDRow = "";
    newCDRow += "<table border=1 cellpadding=1 cellspacing=0 style=\\\"$cdStyle\\\">";
    newCDRow += "<tr bgcolor=#ffffff><td width=400><select size=1 name=cdchargenumber" + cds + " style=\\\"$cdStyle\\\"><option value=0></option>";
    newCDRow += "$CNOptions</select></td>\\n";
    newCDRow += "<td width=200><select size=1 name=cdec" + cds + " style=\\\"$cdStyle\\\"><option value=0></option>";
    newCDRow += "$ecOptions</select></td>\\n";
    newCDRow += "<td width=50><input type=text name=cdamount" + cds + " size=7 maxlength=12 value='' style=\\\"$cdStyle\\\" onChange=\\\"updateCDTotals();\\\"></td>";
    newCDRow += "<td align=right width=50>0.00</td>\\n";
    newCDRow += "<input type=hidden name=cddelete" + cds + " value='F'>\\n";
    newCDRow += "<td><a href=javascript:deleteCD(" + cds + ")>delete</a></td>";
    newCDRow += "</tr>\\n";
    newCDRow += "<input type=hidden name=cdinvoiced" + cds + " value='0'>\\n";
    newCDRow += "</table>\\n";
    document.all.postChargeDistributionTable.insertAdjacentHTML("BeforeBegin", "" + newCDRow + "");
}

function updateCDTotals() {
    var cdtotal = 0;
    for (i=0; i < document.$form.chargedistcount.value; i++) {
        var code = ""
            +"if (document.$form.cddelete" + i + ".value != 'T') {"
            +"    cdtotal = cdtotal + (document.$form.cdamount" + i + ".value - 0);"
            +"}";
        eval(code);
    }
    cdtotal = (Math.round(cdtotal * 100.0) / 100.0);
    cdTotal.innerText = dFormat(cdtotal);
}

function deleteCD(item){
    var code = ""
        +"var disable = (($args{form}.cddelete" + item + ".value == 'F') ? true : false);\\n"
        +"$args{form}.cdchargenumber" + item + ".disabled=disable;\\n"
        +"$args{form}.cdec" + item + ".disabled=disable;\\n"
        +"$args{form}.cdamount" + item + ".disabled=disable;\\n"
        +"$args{form}.cddelete" + item + ".value=((disable) ? 'T' : 'F');\\n"
        + "";
    eval(code);
    updateCDTotals();
}
//--></script>

END_OF_BLOCK
        } else {
            for (my $i=0; $i<$pd{chargedistlistCount}; $i++) {
                $text .= "<tr bgcolor=#ffffff><td>$pd{chargedistlist}[$i]{chargenumber}</td><td>$pd{chargedistlist}[$i]{ec}</td>";
                $text .= "<td>" . dollarFormat($pd{chargedistlist}[$i]{amount}) . "</td>";
                $text .= "<td>" . dollarFormat($pd{chargedistlist}[$i]{invoiced}) . "</td>\n";
                $text .= "<td>" . dollarFormat($pd{chargedistlist}[$i]{amount} - $pd{chargedistlist}[$i]{invoiced}) . "</td></tr>\n";
            }
            $text .= "</table>\n";
        }
        $text .= "</td></tr></table>\n";
        $text .= "</div>\n";
    $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Charge Distribution List</b>", contents=>$text) . "</td></tr>\n";
    }

## Accounts Payable
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'ap', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        my @apStatus = ("", "Initial", "Approval Pending", "Approved", "Closed");
        my @ap = &getAP(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pd{prnumber});
        $text = "<table border=0>\n";
        for (my $i=0; $i<$#ap; $i++) {
            $text .= "<tr><td><b>AP ID: </b></td><td>$ap[$i]{id}</td></tr>\n";
            $text .= "<tr><td><b>Invoice Number: </b></td><td>$ap[$i]{invoicenumber}</td></tr>\n";
            $text .= "<tr><td><b>Date Received: </b></td><td>$ap[$i]{datereceived}</td></tr>\n";
            $text .= "<tr><td><b>Invoice Date: </b></td><td>$ap[$i]{invoicedate}</td></tr>\n";
            $text .= "<tr><td><b>Tax Paid: </b></td><td>" . (($ap[$i]{taxpaid} eq 'T') ? "Yes" : "No") . "</td></tr>\n";
            $text .= "<tr><td><b>Date Paid: </b></td><td>" . ((defined($ap[$i]{datepaid})) ? $ap[$i]{datepaid} : "") . "</td></tr>\n";
            $text .= "<tr><td><b>$SYSClient Billed: </b></td><td>" . ((defined($ap[$i]{clientbilled})) ? $ap[$i]{clientbilled} : "") . "</td></tr>\n";
            $text .= "<tr><td><b>Status: </b></td><td>$apStatus[$ap[$i]{status}]</td></tr>\n";
            my $apComments = ((defined($ap[$i]{comments})) ? $ap[$i]{comments} : "");
            $apComments =~ s/\n/<br>/g;
            $apComments =~ s/  / &nbsp;/g;
            $text .= "<tr><td><b>Comments: </b></td><td>$apComments</td></tr>\n";
            $text .= "<tr><td colspan=2><table border=0 cellpadding=1 cellspacing=0><tr><td> &nbsp; &nbsp;</td><td><table cellpadding=1 cellspacing=0 border=1>\n";
            $text .= "<tr bgcolor=#a0e0c0><td align=center><b>Charge Number</b></td><td align=center><b>Element Code</b></td>";
            $text .= "<td align=center><b>Amount</b></td><td align=center><b>Tax</b></td><td align=center><b>Total</b></td></tr>\n";
            for (my $j=0; $j<$ap[$i]{itemCount}; $j++) {
                $text .= "<tr bgcolor=#ffffff><td align=center>$ap[$i]{items}[$j]{chargenumber}</td>";
                $text .= "<td align=center>$ap[$i]{items}[$j]{ec}</td>";
                $text .= "<td align=center>" . dollarFormat(((defined($ap[$i]{items}[$j]{amount})) ? $ap[$i]{items}[$j]{amount} : "0.00")) . "</td>\n";
                $text .= "<td align=center>" . dollarFormat(((defined($ap[$i]{items}[$j]{tax})) ? $ap[$i]{items}[$j]{tax} : "0.00")) . "</td>";
                my $invTotal = ((defined($ap[$i]{items}[$j]{tax})) ? $ap[$i]{items}[$j]{tax} : 0.00) + ((defined($ap[$i]{items}[$j]{amount})) ? $ap[$i]{items}[$j]{amount} : 0.00);
                $text .= "<td align=center>" . dollarFormat($invTotal) . "</td></tr>\n";
            }
            $text .= "</table></td></tr>\n";
            $text .= "</table>\n";
            $text .= "<hr width=75%>\n";
        }
        
        $text .= "</table>\n";
        $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Accounts Payable</b>", contents=>$text) . "</td></tr>\n";
    }
    
## Attachments
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'attachments', status=>$pdStatus, browseOnly=>$browseOnly);
    my ($displayedrfp, $editablerfp) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'attachmentrfpflag', status=>$pdStatus, browseOnly=>$browseOnly);
    my ($displayedpo, $editablepo) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'attachmentpoflag', status=>$pdStatus, browseOnly=>$browseOnly);
    $text = "<table border=0>\n";
    if ($editable) {
        $text .= "<tr><td><input type=file name=attachment size=50>\n";
        $text .= "<input type=hidden name=newattachmentcount value=0>\n";
        $text .= "<table cellpadding=0 cellspacing=0 border=0 id=postAttachmentTable width=100%>";
        $text .= "<tr><td><a href=\"javascript:addAttachment()\">Add Attachment</a></td></tr>\n";
        $text .= "</table>\n";
        $text .= "</td></tr>\n";
        $text .= <<END_OF_BLOCK;

<script language=javascript><!--

function addAttachment() {
// add an entry to the list of attachments
    var atts = document.$args{form}.newattachmentcount.value;
    var atts2 = atts;
    atts2++;
    document.$args{form}.newattachmentcount.value = atts2;
    var newATTRow = "";
    newATTRow += "<table border=0 cellpadding=0 cellspacing=0>";
    newATTRow += "<tr><td width=400><input type=file name=attachment" + atts + " size=50></td></tr>\\n";
    newATTRow += "</table>\\n";
    document.all.postAttachmentTable.insertAdjacentHTML("BeforeBegin", "" + newATTRow + "");
}

//function updateCDTotals() {
//    var cdtotal = 0;
//    for (i=0; i < document.$form.chargedistcount.value; i++) {
//        var code = ""
//            +"cdtotal = cdtotal + (document.$form.cdamount" + i + ".value - 0);";
//        eval(code);
//    }
//    cdtotal = (Math.round(cdtotal * 100.0) / 100.0);
//    cdTotal.innerText = dFormat(cdtotal);
//}
//--></script>

END_OF_BLOCK
    }
    if ($args{type} ne 'new') {
        if ($pd{attachmentCount} == 0) {
            $text .= "<tr><td>No " . (($editable) ? "prior " : "") . "attachments</td></tr>\n";
        } else {
            $text .= "<tr bgcolor=#a0e0c0><td>\n";
            $text .= "<table border=1 cellpadding=0 cellspacing=0 width=100%><tr>\n";
            if ($displayedrfp) {
                $text .= "<td>PR</td><td>RFP</td>";    
            }
            if ($displayedpo) {
                $text .= "<td>PO</td>";    
            }
            $text .= "<td>Name</td></tr>\n";
            $text .= "<input type=hidden name=attachmentcount value=$pd{attachmentCount}>\n";
            for (my $i=0; $i<$pd{attachmentCount}; $i++) {
                $text .= "<input type=hidden name=attachmentid$i value=$pd{attachments}[$i]{id}>\n";
                $text .= "<tr bgcolor=#ffffff id=attachRow$i>";
                if ($displayedrfp) {
                    $text .= "<td>$pd{attachments}[$i]{pr}</td><td>";
                    if ($editablerfp) {
                        $text .= "<input type=checkbox name=attachmentrfp$i value='T'" . (($pd{attachments}[$i]{rfp} eq 'T') ? " checked" : "") .">";
                    } else {
                        $text .= "<input type=hidden name=attachmentrfp$i value='$pd{attachments}[$i]{rfp}'>$pd{attachments}[$i]{rfp}\n";
                    }
                    $text .= "</td>";
                }
                if ($displayedpo) {
                    $text .= "<td>";
                    if ($editablepo) {
                        $text .= "<input type=checkbox name=attachmentpo$i value='T'" . (($pd{attachments}[$i]{po} eq 'T') ? " checked" : "") .">";
                    } else {
                        $text .= "<input type=hidden name=attachmentpo$i value='$pd{attachments}[$i]{po}'>$pd{attachments}[$i]{po}\n";
                    }
                    $text .= "</td>";
                }
                $text .= "<td><a href=javascript:displayAttachment($pd{attachments}[$i]{id})>$pd{attachments}[$i]{filename}</a>";
                $text .= "<a href=\"javascript:attachRemoveRestore($i);\"><div id=attachRemoveRestore" . $i . " align=right style=\"font-size: 8pt;\">Remove</div></a></td></tr>\n";
                $text .= "<input type=hidden name=attachRemoveFlag$i value='F'>\n";
            }
            $text .= "</table>\n";
            $text .= "</td></tr>\n";
        }
        $text .= <<END_OF_BLOCK;

<script language=javascript><!--

// function to remove/restore an item entry
function attachRemoveRestore(i) {
    myControl = document.getElementById('attachRemoveRestore' + i);
    myRow = document.getElementById('attachRow' + i);
    var code = "";
    var status = true;
    if (myControl.innerText == 'Remove') {
        myControl.innerText = 'Restore';
        code = "$form.attachRemoveFlag" + i + ".value = 'T';\\n";
        eval(code);
        status = true;
        myRow.bgColor='#dddddd';
    } else {
        myControl.innerText = 'Remove';
        code = "$form.attachRemoveFlag" + i + ".value = 'F';\\n";
        eval(code);
        status = false;
        myRow.bgColor='#ffffff';
    }
    code = ""
        +"$form.attachmentrfp"+i+".disabled = " + status + ";\\n$form.attachmentrfp"+i+".readonly = " + status + ";\\n"
        +"$form.attachmentpo"+i+".disabled = " + status + ";\\n$form.attachmentpo"+i+".readonly = " + status + ";\\n"
        +"";
    eval(code);
    var status = updateTotals();

}

//--></script>

END_OF_BLOCK
    }
    $text .= "</table>\n";
    $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Attachments</b>", contents=>$text) . "</td></tr>\n";

## remarks
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'remarks', status=>$pdStatus, browseOnly=>$browseOnly);
    $text = "<table border=0>\n";
    if ($editable) {
        $text .= "<tr><td><textarea name=remarks cols=70 rows=4></textarea></td></tr>\n";
    }
    if ($args{type} ne 'new') {
        my $text2 = "<table border=1 cellspacing=0 cellpadding=0>\n";
        for (my $i=0; $i<$pd{remarkCount}; $i++) {
            $text2 .= "<tr><td>$pd{remarks}[$i]{dateentered} - " . &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$pd{remarks}[$i]{userid}) . "<br>\n";
            $pd{remarks}[$i]{text} =~ s/\n/<br>\n/g;
            $text2 .= "$pd{remarks}[$i]{text}</td></tr>\n";
        }
        $text2 .= "</table>\n";
        $text .= "<tr><td colspan=2>" . (($editable) ? &buildSectionBlock(title=> "<b>Past Remarks</b> ($pd{remarkCount})", contents=>$text2, isOpen=>'T') : $text2) . "</td></tr>\n";
    }
    $text .= "</table>\n";
    $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Remarks</b>", contents=>$text, isOpen=>'T') . "</td></tr>\n";

## approval list
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'approvallist', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed) {
        $text = "<table border=1 cellspacing=0 cellpadding=0>\n";
        my @aList = &getPDApprovals(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pd{prnumber}, status=>$pdStatus);
        my $lastStatus = 0;
        for (my $i=0; $i<$#aList; $i++) {
            if ($lastStatus != $aList[$i]{status}) {
                $lastStatus = $aList[$i]{status};
                $text .= "<tr bgcolor=#ffffff><td valign=top colspan=3>$aList[$i]{statusName}</td>";
            }
            $text .= "<tr bgcolor=#ffffff><td valign=top>$aList[$i]{roleName}</td>";
            $text .= "<td>$aList[$i]{firstname} $aList[$i]{lastname}";
            if ($aList[$i]{userid} != $aList[$i]{approvedby} && $aList[$i]{approvedby} > 0) {
                $text .= "<br>(by " . &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$aList[$i]{approvedby}) . ")";
            }
            $text .= "</td>";
            $text .= "<td>" . ((defined($aList[$i]{dateapproved})) ? $aList[$i]{dateapproved} : &nbspaces(30)) . "</td></tr>\n";
        }
        $text .= "</table>\n";
        $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Approval List</b>", contents=>$text) . "</td></tr>\n";
    }

## history/archive
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'history', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($displayed && $args{type} eq 'browse') {
        $text = "<table border=0 cellspacing=0 cellpadding=0>\n";
        my @pdHist = &getPDByStatus(dbh=>$args{dbh}, schema=>$args{schema}, isHistory=>'T', pd=>$pd{prnumber}, orderBy=>'changedate');
        $text .= "<tr><td><b>History</b></td></tr>\n";
        for (my $i=0; $i<$#pdHist; $i++) {
            $text .= "<tr><td><a href=\"javascript:browseHistory('$pd{prnumber}','$pdHist[$i]{changedate}')\">$pdHist[$i]{changedate}</a> - $pdHist[$i]{changes}</td></tr>\n";
        }
        my @pdArch = &getArchiveList(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pd{prnumber});
        $text .= "<tr><td><b>Archive</b></td></tr>\n";
        for (my $i=0; $i<$#pdArch; $i++) {
            $text .= "<tr><td><a href=\"javascript:printArchive('$pd{prnumber}','$pdArch[$i]{datearchived}')\">$pdArch[$i]{datearchived}</a> - $pdArch[$i]{description}</td></tr>\n";
        }
        $text .= "</table>\n";
        $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>History/Archive</b>", contents=>$text) . "</td></tr>\n";
    }


## tax
    $output .= "<input type=hidden name=taxexempt value='$pd{taxexempt}'>\n";
    $output .= "<input type=hidden name=tax value='$pd{tax}'>\n";
    $output .= "<input type=hidden name=salestax value='" . (($pd{taxexempt} ne 'T') ? $pd{salestax} : 0) . "'>\n";

## submit
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'prsavebutton', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable) {
        $output .= "<tr><td colspan=2 align=center><br><input type=button name=savebutton value=\"Save PR Information\" onClick=\"verifyPRSubmit(document.$args{form}, 'save');\"> &nbsp;</td></tr>\n";
    }
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'prapprovebutton', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable && $args{type} ne 'new') {
        $output .= "<tr><td colspan=2 align=center><br><input type=button name=approvebutton value=\"Submit PR for Approval\" onClick=\"verifyPRSubmit(document.$args{form}, 'approval');\"> &nbsp;</td></tr>\n";
    }
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'prapprovalbuttons', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable) {
        $output .= "<tr><td align=center><br><input type=button name=approvebutton value=\"Approve PR\" onClick=\"approvePDSubmit(document.$args{form}, 'approve')\"> &nbsp;</td>\n";
        $output .= "<td align=center><br><input type=button name=disapprovebutton value=\"Disapprove PR\" onClick=\"approvePDSubmit(document.$args{form}, 'disapprove')\"> &nbsp;</td></tr>\n";
    }
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'rfpsavebutton', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable) {
        $output .= "<tr><td colspan=2 align=center><br><input type=button name=savebutton value=\"Save RFP Information\" onClick=\"verifyRFPSubmit(document.$args{form}, 'save')\"> &nbsp;</td></tr>\n";
    }
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'rfpeditprbutton', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable) {
        $output .= "<tr><td colspan=2 align=center><br><input type=button name=editprbutton value=\"Edit PR Information\" onClick=\"verifyRFPSubmit(document.$args{form}, 'editpr')\"> &nbsp;</td></tr>\n";
    }
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'rfpapprovebutton', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable && $args{type} ne 'new') {
        $output .= "<tr><td colspan=2 align=center><br><input type=button name=approvebutton value=\"Submit RFP for Approval\" onClick=\"verifyRFPSubmit(document.$args{form}, 'approval')\"> &nbsp;</td></tr>\n";
    }
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'rfpapprovalbuttons', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable) {
        $output .= "<tr><td align=center><br><input type=button name=approvebutton value=\"Approve RFP\" onClick=\"approvePDSubmit(document.$args{form}, 'approve')\"> &nbsp;</td>\n";
        $output .= "<td align=center><br><input type=button name=disapprovebutton value=\"Disapprove RFP\" onClick=\"approvePDSubmit(document.$args{form}, 'disapprove')\"> &nbsp;</td></tr>\n";
    }
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'vendsavebutton', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable) {
        $output .= "<tr><td colspan=2 align=center><br><input type=button name=savebutton value=\"Save RFP Vendor Information\" onClick=\"verifyRFPSubmit(document.$args{form}, 'save')\"> &nbsp;</td></tr>\n";
    }
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'pubrfpbutton', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable) {
        $output .= "<tr><td colspan=2 align=center><br><input type=button name=publishbutton value=\"Publish RFP\" onClick=\"verifyRFPSubmit(document.$args{form}, 'publish')\"> &nbsp;</td></tr>\n";
        $output .= "<tr><td colspan=2 align=center><br><input type=button name=printrfpbutton value=\"Print RFP\" onClick=\"printRFP('$id')\"> &nbsp;</td></tr>\n";
    }
    $output .= "<input type=hidden name=dobidsaveremark value='F'>\n";
    if ($args{type} eq 'browse' && $args{history} eq 'F') {
        #if ($pd{status} < 7) {
            $output .= "<tr><td colspan=2 align=center><br><input type=button name=printprbutton value=\"Print PR Form\" onClick=\"printPR('$id')\"></td></tr>\n";
        #}
        if ($pd{status} >= 7 && $pd{contracttype} != 2) {
            $output .= "<tr><td colspan=2 align=center><br><input type=button name=printrfpbutton value=\"Print RFP\" onClick=\"printRFP('$id')\"> &nbsp;</td></tr>\n";
        }
        #if ($pd{status} >= 11 && $pd{contracttype} != 2) {
        if ($pd{status} >= 11) {
            $output .= "<tr><td colspan=2 align=center><br><input type=button name=printpobutton value=\"Print PO\" onClick=\"printPO('$id')\"> &nbsp;</td></tr>\n";
            $output .= "<tr><td colspan=2 align=center><br><input type=button name=printpoinfobutton value=\"Print PO Info\" onClick=\"printPOInfo('$id')\"> &nbsp;</td></tr>\n";
            $output .= "<tr><td colspan=2 align=center><br><input type=button name=printbidabsbutton value=\"Print Bid Abstract\" onClick=\"bidAbstract('$id')\"> &nbsp;</td></tr>\n";
            $output .= "<tr><td colspan=2 align=center><br><input type=button name=printbidquotebutton value=\"Print Bid Quote Sheet\" onClick=\"bidQuote('$id')\"> &nbsp;</td></tr>\n";
        }
    }
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'posavebutton', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable) {
        $output .= "<tr><td colspan=2 align=center><br><input type=button name=savebutton value=\"Save PO Information\" onClick=\"verifyPRSubmit(document.$args{form}, 'save');\"> &nbsp;</td></tr>\n";
    }
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'poapprovebutton', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable) {
        $output .= "<tr><td colspan=2 align=center><br><input type=button name=approvebutton value=\"Submit PO for Approval\" onClick=\"verifyPRSubmit(document.$args{form}, 'approval');\"> &nbsp;</td></tr>\n";
    }
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'poapprovalbuttons', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable) {
        $output .= "<tr><td align=center colspan=2><br><input type=button name=approvebutton value=\"Approve PO\" onClick=\"approvePDSubmit(document.$args{form}, 'approve')\"> &nbsp; &nbsp; \n";
        $output .= "<input type=button name=disapprovebutton value=\"Disapprove PO\" onClick=\"approvePDSubmit(document.$args{form}, 'disapprove')\"> &nbsp; &nbsp; \n";
        $output .= "<input type=button name=printbidabsbutton value=\"Print Bid Abstract\" onClick=\"bidAbstract('$id')\"> &nbsp; &nbsp; \n";
        $output .= "<input type=button name=printbidquotebutton value=\"Print Bid Quote Sheet\" onClick=\"bidQuote('$id')\"> &nbsp;</td></tr>\n";
    }
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'placepobutton', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($editable) {
        $output .= "<tr><td colspan=2 align=center><br><input type=button name=placebutton value=\"Place PO\" onClick=\"placePOSubmit(document.$args{form})\"> &nbsp;</td></tr>\n";
        $output .= "<tr><td colspan=2 align=center><br><input type=button name=printpobutton value=\"Print PO\" onClick=\"printPO('$id')\"> &nbsp;</td></tr>\n";
    }


    $output .= "</table>\n";
    
    my $nextCommand = (($args{type} eq 'new') ? "addpr" : "updatepd");
    $nextCommand = (($pd{status} == 7) ? "updaterfp" : $nextCommand);
    $nextCommand = (($pd{status} == 9) ? "updaterfp" : $nextCommand);
    $nextCommand = (($pd{status} == 15) ? "placepo" : $nextCommand);

#############

# update item totals and tax when screen loads
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'items', status=>$pdStatus, browseOnly=>$browseOnly);
    if($editable) {
        $output .= "<script language=javascript><!--\n";
        $output .= "updateTotals();\n";
        $output .= "//--></script>\n";
    }

    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifyPRSubmit (f, type){
// javascript form verification routine
    var msg = "";
    if (f.deptid.selectedIndex == 0) {
      msg += "Department must be selected.\\n";
    }
    if (f.chargenumber.selectedIndex == 0) {
      msg += "Charge Number must be selected.\\n";
    }
    if (isblank(f.daterequired.value)) {
      msg += "Date Required must be entered.\\n";
    }
    if (isblank(f.briefdescription.value)) {
      msg += "Brief Description must be entered.\\n";
    }
    if (isblank(f.justification.value)) {
      msg += "Justification must be entered.\\n";
    }
END_OF_BLOCK
    ($displayed, $editable) = &doDisplayControl(dbh=>$args{dbh}, schema=>$args{schema}, field=>'questions', status=>$pdStatus, browseOnly=>$browseOnly);
    if ($pd{questionCount} > 0 && $editable) {
        $output .= "if(";
        for (my $i=0; $i<$pd{questionCount}; $i++) {
            if ($i > 0) {$output .= " || ";}
            $output .= "!f.questionanswer" . $i . "[0].checked && !f.questionanswer" . $i . "[1].checked && !f.questionanswer" . $i . "[2].checked";
        }
        $output .= ") {\n";
        $output .= <<END_OF_BLOCK;
            msg += "All Oversite Routing Questions must be answered.\\n";
        }
END_OF_BLOCK
    }
    $output .= <<END_OF_BLOCK;
    // test justification size
    var lines = 0;
    var maxLines = 40;
    var testText = f.justification.value;
    var len = testText.length;
    var count = 0;
    var cols = 95;
    for (var i=0; i<len; i++) {
        count++;
        if (testText.slice(i,(i+1)) == '\\n' || count > cols) {
            lines++;
            count = 0;
        }
    }
    if (lines > maxLines) {
        msg += "Justification is too long. It must be " + maxLines + " lines or less.\\n      -If a longer justification is needed, please attach it as a document with a reference in the Justification field.\\n";
    }
    if (f.solesource.checked && isblank(f.ssjustification.value)) {
      msg += "Sole SourceJustification must be entered.\\n";
    }
    var itemErrors = 0;
    var goodItems = 0;
    var itemTotal = 0;
    var itemECTotals = new Object();
END_OF_BLOCK
    for (my $i=0; $i<$#ecArray; $i++) {
        $output .= "    itemECTotals[\"$ecArray[$i]{ec}\"] = 0;\n";
    }
    $output .= <<END_OF_BLOCK;
    for (i=1; i <= f.itemcount.value; i++) {
        var code = ""
            +"if (!isblank(f.partnumber"+i+".value) || !isblank(f.description"+i+".value) || "
            +"      !isblank(f.quantity"+i+".value) || !isblank(f.unitprice"+i+".value) || "
            +"      f.ishazmat"+i+".checked || "
            +"      f.unitofissue"+i+".selectedIndex != 0 || f.ec"+i+".selectedIndex != 0 "
            +") {"
            +"    if (isblank(f.itemnumber"+i+".value) || isblank(f.description"+i+".value) || "
            +"          isblank(f.quantity"+i+".value) || isblank(f.unitprice"+i+".value) || "
            +"          f.unitofissue"+i+".selectedIndex == 0 || f.ec"+i+".selectedIndex == 0 "
            +"    ) {"
            +"       itemErrors++;"
            +"    } else {"
            +"       goodItems++;"
            +"    }"
            +"}"
            +"itemTotal = itemTotal + (Math.round((f.quantity"+i+".value * f.unitprice"+i+".value) * 100.)/100.0);"
            +"itemECTotals[f.ec"+i+"[f.ec"+i+".selectedIndex].value] += ((Math.round((f.quantity"+i+".value * f.unitprice"+i+".value) * 100.)/100.0) + (f.itemTax"+i+".value - 0));"
        + "";
        
        eval(code);
    }
    itemTotal = itemTotal + (Math.round(((f.shipping.value * 1.0) + (f.tax.value * 1.0)) * 100.)/100.0);
    if (itemErrors > 0) {
        msg += 'Item Number, Description, Unit of Issue, Unit Price, and Element Code are all required for each item.\\n';
    }
    if (type == "approval" && goodItems == 0) {
        msg += 'One or more items must be entered for a valid PR.\\n';
    }
    if (f.oldstatus.value >= 11) {
        if (!f.potype.options[0].selected && !f.blanketrelease.options[0].selected) {
            msg += 'Blanket release must be a PO type of Normal.\\n';
        }
        if (isblank(f.duedate.value)) {
            msg += 'Due / Delivery Date must be entered.\\n';
        }
        var brapps = 0;
        for (i=0; i < f.brapprovalcount.value; i++) {
            var code = ""
                +"if (f.bruserid" + i +".value > 0) { brapps++; }";
            eval(code);
        }
        if (f.potype.options[1].selected && brapps == 0 && type == "approval") {
            msg += 'Blanket contract must have approval list.\\n';
        }
        if (f.potype.options[2].selected && brapps != 0) {
            msg += 'Maintenance contract can not have approval list.\\n';
        }
        if (f.potype.options[0].selected && brapps != 0) {
            msg += 'Normal contract can not have approval list.\\n';
        }
        if (!f.potype.options[0].selected && (isblank(f.startdate.value) || isblank(f.enddate.value))) {
            msg += 'Blanket & Maintenance contracts require a Start and End dates.\\n';
        }
        if (f.potype.options[0].selected && (!isblank(f.startdate.value) || !isblank(f.enddate.value))) {
            msg += 'Start and End dates are only used for Blanket & Maintenance contracts.\\n';
        }
        var cdcount = 0;
        var cdtotal = 0;
        itemTotal = (Math.round(itemTotal * 100.)/100.0);
        var cdECTotals = new Object();
END_OF_BLOCK
        for (my $i=0; $i<$#ecArray; $i++) {
            $output .= "    cdECTotals[\"$ecArray[$i]{ec}\"] = 0;\n";
        }
    $output .= <<END_OF_BLOCK;
        for (i=0; i < f.chargedistcount.value; i++) {
            var code = ""
                +"if (f.cddelete" + i + ".value != 'T') {"
                +"    if (f.cdchargenumber" + i +".value > ' ') { cdcount++; cdtotal += (Math.round(f.cdamount" + i +".value* 100.)/100.0);}"
                +"    cdECTotals[f.cdec"+i+"[f.cdec"+i+".selectedIndex].value] += (Math.round(f.cdamount"+i+".value * 100.)/100.0);"
                +"}";
            eval(code);
        }
        cdtotal = (Math.round(cdtotal * 100.0) / 100.0);
        if (f.blanketrelease.options[0].selected && cdcount == 0 && type == "approval") {
            msg += 'Charge distribution list must be entered.\\n';
        }
        if (f.blanketrelease.options[0].selected && cdtotal != itemTotal && type == "approval") {
            msg += 'Charge distribution total (' + dFormat(cdtotal) + ') does not equal item total(' + dFormat(itemTotal) + ').\\n';
        }
        if (!f.blanketrelease.options[0].selected && cdcount > 0 && type == "approval") {
            msg += 'Charge distribution list not entered for Blanket releases.\\n';
        }
        var compEC = 0;
        var totShipping = 0.0;
        var shipp = f.shipping.value - 0;
        var shippTax = shipp * (f.salestax.value / 100.0);
        totShipping = (Math.round((shipp + shippTax) * 100.)/100.0);
        if (type == "approval") {
            for (ec in cdECTotals) {
                if (cdECTotals[ec] >  (itemECTotals[ec] + 0.10) || cdECTotals[ec] <  (itemECTotals[ec] - 0.10)) {
                    if (cdECTotals[ec] >  ((itemECTotals[ec] + totShipping) + 0.10) || cdECTotals[ec] <  (itemECTotals[ec] - 0.10)) {
                        compEC++;
                    }
                }
            }
            if (compEC > 0) {
                msg += 'Charge distribution for element codes do not match.\\n';
            }
        }
    }
    if (msg != "") {
      alert (msg);
    } else {
END_OF_BLOCK
    if ($pd{status} < 11) {
        $output .= <<END_OF_BLOCK;
        for (index=0; index < f.vendorlist.length-1;index++) {
            f.vendorlist.options[index].selected = true;
        }
END_OF_BLOCK
    }
    $output .= <<END_OF_BLOCK;
        if (type == "approval") {
            if ($form.status.value == 1 || $form.status.value == 2 ) {
                $form.status.value = 3;
            } else if ($form.status.value == 5) {
                $form.status.value = 6;
            } else if ($form.status.value == 11) {
                $form.status.value = 14;
            } else if ($form.status.value == 16) {
                $form.status.value = 13;
            }
        }
        submitFormCGIResults('$args{form}', '$nextCommand');
    }
}

function approvePDSubmit (f, type){
// javascript form verification routine
    var msg = "";
    var nextCommand = "pdapproved";
    if (f.status.value == 3) {
        if (f.chargenumber.selectedIndex == 0) {
            msg += "Charge Number must be selected.\\n";
        }
        if (isblank(f.justification.value)) {
            msg += "Justification must be entered.\\n";
        }
    }
    if (type == 'disapprove' && isblank(f.remarks.value)) {
        msg += 'A remark must be entered for a Disapproval';
    }
    if (msg != "") {
      alert (msg);
    } else {
        if (type == "disapprove") {
            nextCommand = "pddisapproved";
        }
        submitFormCGIResults('$args{form}', nextCommand);
    }
}

function verifyRFPSubmit (f, type){
// javascript form verification routine
    var msg = "";
    if (f.status.value==7 && type != 'editpr'){
        if (isblank(f.rfpdeliverdays.value) || !isnumeric(f.rfpdeliverdays.value)) {
          msg += "Delivery Days must be set to a number.\\n";
        }
        if (isblank(f.rfpdaysvalid.value) || !isnumeric(f.rfpdaysvalid.value)) {
          msg += "Days Offer Valid For must be set to a number.\\n";
        }
        if (isblank(f.rfpduedate.value)) {
          msg += "RFP Due Date must be input.\\n";
        }
        var clauseErrors = 0;
        var goodClauses = 0;
        for (i=1; i <= f.clausecount.value; i++) {
            var code = ""
                +"if (f.removeflag"+i+".value=='F' && isblank(f.clause"+i+".value)) {"
                +"   clauseErrors++;"
                +"} else {"
                +"   goodClauses++;"
                +"}"
            + "";
            
            eval(code);
        }
        if (clauseErrors > 0) {
            msg += 'Text is required for each clause.\\n';
        }
        if (type == "approval" && goodClauses == 0) {
            msg += 'One or more clauses must be entered for a valid RFP.\\n';
        }
    }
    if (msg != "") {
      alert (msg);
    } else {
        if (type == "editpr") {
            f.status.value = 5;
        }
        if (type == "approval") {
            f.status.value = 8;
        }
        if (type == "publish") {
            f.status.value = 10;
        }
        if (f.status.value == 9 || f.status.value == 10) {
            for (index=0; index < f.vendorlist.length-1;index++) {
                f.vendorlist.options[index].selected = true;
            }
        }
END_OF_BLOCK
        if ($pd{status} < 11) {
            $output .= <<END_OF_BLOCK;
            for (index=0; index < f.vendorlist.length-1;index++) {
                f.vendorlist.options[index].selected = true;
            }
END_OF_BLOCK
        }
            $output .= <<END_OF_BLOCK;
        submitFormCGIResults('$args{form}', '$nextCommand');
    }
}

function placePOSubmit (f, type){
// javascript form verification routine
    var msg = "";
    if (msg != "") {
      alert (msg);
    } else {
        f.status.value = 17;
        submitFormCGIResults('$args{form}', '$nextCommand');
    }
}

function printPR(id) {
    var myDate = new Date();
    var winName = myDate.getTime();
    document.$form.id.value = id;
    document.$args{form}.action = '$args{path}' + 'purchaseDocuments.pl';
    document.$form.command.value = 'printpr';
    document.$form.target = winName;
    var newwin = window.open('',winName);
    newwin.creator = self;
    document.$form.submit();
}

function printRFP(id) {
    var myDate = new Date();
    var winName = myDate.getTime();
    document.$form.id.value = id;
    document.$args{form}.action = '$args{path}' + 'purchaseDocuments.pl';
    document.$form.command.value = 'printrfp';
    document.$form.target = winName;
    var newwin = window.open('',winName);
    newwin.creator = self;
    document.$form.submit();
}

function printPO(id) {
    var myDate = new Date();
    var winName = myDate.getTime();
    document.$form.id.value = id;
    document.$args{form}.action = '$args{path}' + 'purchaseDocuments.pl';
    document.$form.command.value = 'printpo';
    document.$form.target = winName;
    var newwin = window.open('',winName);
    newwin.creator = self;
    document.$form.submit();
}

function printPOInfo(id) {
    var myDate = new Date();
    var winName = myDate.getTime();
    document.$form.id.value = id;
    document.$args{form}.action = '$args{path}' + 'purchaseDocuments.pl';
    document.$form.command.value = 'printpoinfo';
    document.$form.target = winName;
    var newwin = window.open('',winName);
    newwin.creator = self;
    document.$form.submit();
}

function printArchive(pd,date) {
    var myDate = new Date();
    var winName = myDate.getTime();
    document.$form.id.value = pd;
    document.$form.datetest.value = date;
    document.$args{form}.action = '$args{path}' + 'purchaseDocuments.pl';
    document.$form.command.value = 'printarchive';
    document.$form.target = winName;
    var newwin = window.open('',winName);
    newwin.creator = self;
    document.$form.submit();
}

function bidAbstract (id) {
    var myDate = new Date();
    var winName = myDate.getTime();
    document.$args{form}.id.value = id;
    document.$args{form}.action = '$args{path}' + 'bids.pl';
    document.$args{form}.command.value = 'bidabstract';
    document.$args{form}.target = winName;
    var newwin = window.open('',winName);
    newwin.creator = self;
    document.$args{form}.submit();
}

function bidQuote (id) {
    var myDate = new Date();
    document.$args{form}.id.value = id;
    document.$args{form}.action = '/mm/doBidAbstractXLS';
    document.$args{form}.target = 'cgiresults';
    document.$args{form}.submit();
}

function browseHistory (pd,date){
// javascript form verification routine
    document.$form.id.value = pd;
    document.$form.datetest.value = date;
    submitForm('$args{form}', 'browsehistory');
}

END_OF_BLOCK
    if ($args{type} eq 'new') {
        $output .= "    addItem();\n";
        $output .= "    addItem();\n";
        $output .= "    addItem();\n";
    }
    $output .= <<END_OF_BLOCK;

//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doPDEntry {  # routine to get pd entry/update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my ($name, $fileContents) = &getFile(fileParam=>'attachment');
    my @fileSet;
    for (my $i=0; $i<$settings{newattachmentcount}; $i++) {
        my ($fname, $fcontents) = &getFile(fileParam=>"attachment$i");
#print STDERR "\n$i, $fname\n";
        $fileSet[$i]{fileName} = $fname;
        $fileSet[$i]{fileContents} = $fcontents;
    }
    
#    my ($status, $id) = &doProcessPDEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
#          type => $args{type}, fileName=>$args{fileName}, fileContents=>$args{fileContents}, settings => \%settings);
    my ($status, $id) = &doProcessPDEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, fileName=>$name, fileContents=>$fileContents, settings => \%settings, attachmentSet => \@fileSet);

#    $message = "PD '$id' has been " . (($args{type} eq 'new') ? "added " : "updated");
#    $output .= doAlertBox(text => "$message");
    if ($args{type} eq 'new') {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "PD $id inserted", type => 20);
    } else {
        my $message = "PD $id updated" . (($settings{status} == $settings{oldstatus} || ($settings{status} != $settings{oldstatus} && $status <= 0)) ? "" : " - Submitted for Approval");
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 21);
        if ($settings{status} != $settings{oldstatus} && $status > 0) {
            my $pdf = &doPrintPR(dbh => $args{dbh}, schema => $args{schema}, id => $settings{prnumber}, forDisplay=>'F');
            &doSendApprovalNotification(dbh => $args{dbh}, schema => $args{schema}, pd => $id, pdf => $pdf);
        }
        if ($status == -2) {
            $output .= "<script language=javascript><!--\n";
            $output .= "   alert('Funding Insufficiant!\\nPlease Contact Your Finance Department.\\n\\nPR Changes have Been Saved.');\n";
            $output .= "//--></script>\n";
        }
    }
    #if ($status > 0) {
        $output .= "<script language=javascript><!--\n";
        $output .= "   submitForm('home','home');\n";
        $output .= "//--></script>\n";
    #}

    return($output);
}


###################################################################################################################################
sub doPDApproval {  # routine to process PR approvals and disapprovals
###################################################################################################################################
    my %args = (
        type => 'approve',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $id = $settings{prnumber};
    my $pdf = '';
    
    my $logText = "";
    my $logType = 0;
    
    if ($settings{status} == 3) {
        $logText = "PR";
        $logType = 22;
    } elsif ($settings{status} == 8) {
        $logText = "RFP";
        $logType = 33;
    } elsif ($settings{status} == 14) {
        $logText = "PO";
        $logType = 22;
    } elsif ($settings{status} == 13) {
        $logText = "PO Amendment";
        $logType = 22;
    }
    
    my ($name, $fileContents) = &getFile(fileParam=>'attachment');
    my @fileSet;
    for (my $i=0; $i<$settings{newattachmentcount}; $i++) {
        my ($fname, $fcontents) = &getFile(fileParam=>"attachment$i");
#print STDERR "\n$i, $fname\n";
        $fileSet[$i]{fileName} = $fname;
        $fileSet[$i]{fileContents} = $fcontents;
    }
    
    #if ($args{type} eq 'approve') {
    #    if ($settings{status} ==3) {
    #        $pdf = &doPrintPR(dbh => $args{dbh}, schema => $args{schema}, id => $settings{prnumber}, forDisplay=>'F');
    #    } elsif ($settings{status} ==8) {
    #        $pdf = &doPrintRFP(dbh => $args{dbh}, schema => $args{schema}, id => $settings{prnumber}, forDisplay=>'F');
    #    } elsif ($settings{status} ==14 || $settings{status} == 13) {
    #        $pdf = &doPrintPO(dbh => $args{dbh}, schema => $args{schema}, id => $settings{prnumber}, forDisplay=>'F');
    #    }
    #}
    my (%retVals) = &doProcessPDApproval(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, settings => \%settings, pdf => $pdf, fileName=>$name, fileContents=>$fileContents, attachmentSet => \@fileSet);

    $settings{retVals}{contracttype} = $retVals{contracttype};
    $settings{retVals}{relatedpr} = $retVals{relatedpr};
    $settings{retVals}{nextStatus} = $retVals{nextStatus};
    $settings{retVals}{logText} = $retVals{logText};
    
    if ($args{type} eq 'approve') {
        if ($settings{status} ==3) {
            $pdf = &doPrintPR(dbh => $args{dbh}, schema => $args{schema}, id => $settings{prnumber}, forDisplay=>'F');
        } elsif ($settings{status} ==8) {
            $pdf = &doPrintRFP(dbh => $args{dbh}, schema => $args{schema}, id => $settings{prnumber}, forDisplay=>'F');
        } elsif ($settings{status} ==14 || $settings{status} == 13) {
            $pdf = &doPrintPO(dbh => $args{dbh}, schema => $args{schema}, id => $settings{prnumber}, forDisplay=>'F');
        }
        my ($status) = &doProcessPDApprovalPart2(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
              type => $args{type}, settings => \%settings, pdf => $pdf);
    }


    if ($args{type} eq 'approve') {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "$logText $id signoff", type => $logType);
        &doSendApprovalNotification(dbh => $args{dbh}, schema => $args{schema}, pd => $settings{prnumber}, pdf => $pdf);
    } else {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "$logText $id disapproved and returned", type => $logType);
        if ($settings{status} == 3) {
            &doSendPRDisapprovalNotification (dbh => $args{dbh}, schema => $args{schema}, pd => $settings{prnumber});
        }
    }
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('home','home');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doDisplayAttachment {  # routine to display an attachment
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %at = &getAttachmentInfo(dbh => $args{dbh}, schema => $args{schema}, id=> $args{id});

    $output .= "Content-type: $at{mimeType}\n\n";
#print STDERR "\nFile: $at{filename}, mime type: $at{mimeType}\n\n";
    $output .= $at{data};

    return($output);
}


###################################################################################################################################
sub doPrintPR {  # routine to generate a PDF of a PR
###################################################################################################################################
    my %args = (
        id => 0,
        forDisplay => 'T',
        @_,
    );
    #my $hashRef = $args{settings};
    #my %settings = %$hashRef;
    my $output = "";
    my %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id});
    if ($pd{status} > 6) {
        %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id}, history=>'T', historyStatus => 4);
    }
    my $formWidth = 570;
    
    my %siteInfo = &getSiteInfo(dbh => $args{dbh}, schema => $args{schema}, id => $pd{site});
    my $pdf = new PDF;
    $pdf->setup(orientation => 'portrait', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
        cellPadding => 4);

#######

## Headers
    #$pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    #open FH1, "<$SYSFullImagePath/" . lc($siteInfo{shortname}) . "-logo-sm.png";
    #my $data = "";
    #my $rc = read(FH1, $data, 100000000);
    #close FH1;
    #my $logo = $pdf->addImage(source=>'memory', data=>$data);
    my $logo = $pdf->addImage(source=>'file', type=>'png', fileName=>"$SYSFullImagePath/" . lc($siteInfo{shortname}) . "-logo-sm.png");
    $pdf->placeHeaderImage(image=>$logo, alignment => 'left', scale=> .35, xOffset=>-20, yOffset=>30);    
    
    my $colCount = 3;
    my @colWidths = (312, 122, 112);
    my @colAlign = ("left", "left", "left");
    my @colData = ("" . uc($siteInfo{shortname}) . " SUPPORT SERVICES", "PR Number", "Department ID. No.");
    
    my $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    @colAlign = ("left", "center", "center");
    if ($pd{contracttype} == 2 && defined($pd{relatedpr}) && $pd{relatedpr} gt "0") {
#print STDERR "\nPURCHASE REQUEST (PR) - Blanket Release\nContract: $pd{relatedprinfo}{ponumber}\n\n";
        @colData = ("PURCHASE REQUEST (PR) - Blanket Release\nContract: $pd{relatedprinfo}{ponumber}", "$pd{prnumber}", "$pd{deptname}");
        #@colData = ("$pd{relatedpr}", "$pd{prnumber}", "$pd{deptname}");
    } else {
        @colData = ("PURCHASE REQUEST (PR)", "$pd{prnumber}", "$pd{deptname}");
    }
    $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    $colCount = 5;
    @colWidths = (106,108,108,106,102);
    @colAlign = ("center", "center", "center", "center", "center");
    @colData = ("Requestor", "Date Requested", "Date Required", "Charge No.", "EC");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    @colAlign = ("center", "center", "center", "center", "center");
    my $fullName = &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=> $pd{requester});
    @colData = ("$fullName", "$pd{daterequested}", "$pd{daterequired}", "$pd{chargenumber}", "$pd{items}[0]{ec}");
    $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    $colCount = 8;
    @colWidths = (22,76,224,17,22,32,52,61);
    @colAlign = ("center", "center", "center", "center", "center", "center", "center", "center");
    @colData = ("No.", "Part No.", "Description", "Sub", "Qty","Unit of Issue", "Estimated Unit Price", "Estimated Cost");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    my $subTotal = 0;
    for (my $i=0; $i<$pd{itemCount}; $i++) {
        my $lineTotal = $pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice};
        $subTotal += $lineTotal;
    }

## Footers
# justification & totals
    $colCount = 3;
    @colWidths = (406,80,60);
    @colAlign = ("left", "right", "right");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    @colData = ("\n\n", " ", " ");
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    my $total = $subTotal + $pd{shipping} + $pd{tax};
    @colData = ($pd{justification}, "Subtotal\nShipping & Handling\nSalesTax\nEstimated Total Cost", 
          &dollarFormat($subTotal) . "\n" . &dollarFormat($pd{shipping}) . "\n" . &dollarFormat($pd{tax}) . "\n" . &dollarFormat($total));
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

# Vendor info
    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("center");
    $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    @colData = ("VENDOR INFORMATION");
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    
    $colCount = $pd{vendorCount};
    for (my $i=0; $i<$colCount; $i++) {
        my %vendor = &getVendorInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$pd{vendorList}[$i]{vendor});
        $colData[$i] = "Name: $vendor{name}\nContact: $vendor{pointofcontact}\nPhone: " . ((defined($vendor{phone})) ? $vendor{phone} : "");
        $colData[$i] .= ((defined($vendor{extension}) && $vendor{extension} gt " ") ? " - $vendor{extension}" : "") . "\n";
        $colData[$i] .= "Fax: " . ((defined($vendor{fax})) ? $vendor{fax} : "");
        $colWidths[$i] = ($formWidth / $colCount) - 8;
        $colAlign[$i] = "left";
    }
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

# Approval info
    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("center");
    @colData = ("AUTHORIZATION");
    $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    $colCount = 3;
    @colWidths = (182,182,182);
    @colAlign = ("center","center","center");
    @colData = ("Title", "Name", "Approval Date");
    $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    @colAlign = ("left","left","left");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my @approvals = &getPDApprovals(dbh => $args{dbh}, schema => $args{schema}, pd => $pd{prnumber}, status => 4);
    for (my $i=0; $i<$#approvals; $i++) {
        @colData = ($approvals[$i]{roleName}, "$approvals[$i]{lastname}, $approvals[$i]{firstname}", 
              ((defined($approvals[$i]{dateapproved})) ? $approvals[$i]{dateapproved} : ""));
        $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    }
    @colData = (" ", " ", " ");
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);


    $pdf->addFooter(fontSize => 8.0, text => "Page <page>", alignment => "center");

    $pdf->newPage(orientation => 'portrait', useGrid => 'F');

# page contents

    $colCount = 8;
    @colWidths = (22,76,224,17,22,32,52,61);
    @colAlign = ("center", "left", "left", "center", "center", "center", "right", "right");
    for (my $i=0; $i<$pd{itemCount}; $i++) {
        my $lineTotal = $pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice};
        @colData = ("$pd{items}[$i]{itemnumber}", ((defined($pd{items}[$i]{partnumber})) ? $pd{items}[$i]{partnumber} : ""), 
                    "$pd{items}[$i]{description}", (($pd{items}[$i]{substituteok} eq 'T') ? "Yes" : "No"), "$pd{items}[$i]{quantity}",
                    "$pd{items}[$i]{unitofissue}", &dollarFormat($pd{items}[$i]{unitprice}), &dollarFormat($lineTotal));
        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    }

## finish pdf
    my $pdfBuff = $pdf->finish;
########    
    
    if ($args{forDisplay} eq 'T') {
        my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>'.pdf');
        $output .= "Content-type: $mimeType\n\n";
        $output .= "Content-disposition: inline; filename=$args{id}.pdf\n";
        $output .= "\n";
    }
    $output .= $pdfBuff;
    

    return($output);
}


###################################################################################################################################
sub dollarFormat {  # routine to format dollars
###################################################################################################################################
    my $text = reverse (sprintf "%20.2f", (((defined($_[0])) ? $_[0] : 0)));
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    $text = scalar reverse $text;
    $text =~ s/ //g;
    return '$' . $text;
}


###################################################################################################################################
sub dollarFormat2 {  # routine to format dollars, negs in ()
###################################################################################################################################
    my $text = reverse (sprintf "%20.2f", (((defined($_[0])) ? $_[0] : 0)));
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    $text = scalar reverse $text;
    $text =~ s/ //g;
    $text = '$' . $text;
    if (index($text, '-') >= 0) {
        $text =~ s/-//;
        $text = "($text)";
    }
    return $text;
}


###################################################################################################################################
sub dFormat {  # routine to format dollars
###################################################################################################################################
    my $text = sprintf "%20.2f", ($_[0]);
    $text =~ s/ //g;
    return $text;
}


###################################################################################################################################
sub doCopyPR {  # routine to an old pr into a new pr
###################################################################################################################################
    my %args = (
        id => 0,
        deptID => 0,
        @_,
    );
    my $output = "";
    my $message = "";
    
    my ($status, $id) = &doProcessPRCopy(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          oldPR => $args{id}, deptID=>$args{deptID});

    $message = "PR '$id' has been created from old PR '$args{id}'";
    $output .= doAlertBox(text => "$message");
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "PD $id inserted, copied from $args{id}", type => 20);
    $output .= "<script language=javascript><!--\n";
    $output .= "   $args{form}.id.value='$id';\n";
    $output .= "   submitForm('$args{form}','updateprform');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doAcceptPRForRFP {  # routine to accept a pr for rfp and assign buyer
###################################################################################################################################
    my %args = (
        id => 0,
        userID => 0,
        @_,
    );
    my $output = "";
    my $message = "";
    
    my $status = &doProcessAcceptPRforRFP(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, pd => $args{id}); 

    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "PR $args{id} accepted by " . 
                 &getFullName(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}) . " for RFP", type => 31);
    $output .= "<script language=javascript><!--\n";
    $output .= "   $args{form}.id.value='$args{id}';\n";
    $output .= "   submitForm('$args{form}','updaterfpform');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doAddClauseText {  # routine to add text to an newly inserted clause
###################################################################################################################################
    my %args = (
        id => 0,
        clause => 0,
        @_,
    );
    my $output = "";
    
    my @clauses = &getClauseArray(dbh=>$args{dbh}, schema => $args{schema}, id=>$args{clause});
    my $clause = $clauses[0]{description} . "\n" . $clauses[0]{text};
    $clause =~ s/\n/<newline>/g;
    $clause =~ s/\r//g;
    $clause =~ s/"/<doublequote>/g;
    
    $output .= "<script language=javascript><!--\n";
    $output .= "   var text = \"$clause\";\n";
    $output .= "   text = text.replace(/<doublequote>/g, \"\\\"\");\n";
    $output .= "   text = text.replace(/<newline>/g, \"\\n\");\n";
    $output .= "   parent.main.$args{form}.clause" . $args{id} . ".value=text;\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doRFPUpdate {  # routine to get rfp update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    
    if ($settings{status} == 5 || $settings{status} == 7 || $settings{status} == 8) {
        my ($name, $fileContents) = &getFile(fileParam=>'attachment');
        my @fileSet;
        for (my $i=0; $i<$settings{newattachmentcount}; $i++) {
            my ($fname, $fcontents) = &getFile(fileParam=>"attachment$i");
#print STDERR "\n$i, $fname\n";
            $fileSet[$i]{fileName} = $fname;
            $fileSet[$i]{fileContents} = $fcontents;
        }
        my $status = &doProcessRFPUpdate(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
              fileName=>$name, fileContents=>$fileContents, settings => \%settings, attachmentSet => \@fileSet);
    } elsif ($settings{status} == 9 || $settings{status} == 10) {
        my $pdf = "";
        if ($settings{status} == 10) {
            $pdf = &doPrintRFP(dbh => $args{dbh}, schema => $args{schema}, id => $settings{prnumber}, forDisplay=>'F');
        }
        my $status = &doProcessRFPUpdate(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
              pdf=>$pdf, settings => \%settings);
    }

    $message = "RFP $settings{prnumber} updated" . (($settings{status} == $settings{oldstatus}) ? "" : " - Submitted for Approval");
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 32);
    
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('home','home');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doPrintRFP {  # routine to generate a PDF of an RFP
###################################################################################################################################
    my %args = (
        id => 0,
        forDisplay => 'T',
        @_,
    );
    #my $hashRef = $args{settings};
    #my %settings = %$hashRef;
    my $output = "";
    my %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id});
    my $formWidth = 570;
    
    my %siteInfo = &getSiteInfo(dbh => $args{dbh}, schema => $args{schema}, id => $pd{site});
    my $pdf = new PDF;
    $pdf->setup(orientation => 'portrait', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
        cellPadding => 4);

#######

    my $logo = $pdf->addImage(source=>'file', type=>'png', fileName=>"$SYSFullImagePath/" . lc($siteInfo{shortname}) . "-logo-sm.png");
    $pdf->placeHeaderImage(image=>$logo, alignment => 'right', scale=> .35, xOffset=>-20, yOffset=>30);    
    
    my $colCount = 1;
    my @colWidths = (562);
    my @colAlign = ("center");
    my @colData = (" ");
    
    my $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);

## Headers


## Footers

# blank line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (""); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    #$pdf->addFooterRow(fontSize => 0.0001, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>.1);
#
    $pdf->addFooter(fontSize => 10.0, text => "Page <page>", alignment => "center");

## start page
    $pdf->newPage(orientation => 'portrait', useGrid => 'F');

# page contents

    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("center");
    @colData = ("Request For Proposal\nPurchase Requisition - $pd{prnumber}\n ");
    
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->tableRow(fontSize => 12, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);

# parse clauses
    for (my $i=0; $i<$pd{clauseCount}; $i++) {
        if ($pd{clause}[$i]{rfp} eq 'T') {
            $pd{clause}[$i]{text} =~ s/<RFPDaysValid>/$pd{rfpdaysvalid}/g;
            $pd{clause}[$i]{text} =~ s/<RFPDueDate>/$pd{rfpduedate}/g;
            $pd{clause}[$i]{text} =~ s/<RFPDeliverDays>/$pd{rfpdeliverdays}/g;
            $pd{clause}[$i]{text} =~ s/<br>/\n/g;
        }
    }

# header clauses
    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("left");
    for (my $i=0; $i<$pd{clauseCount}; $i++) {
        if ($pd{clause}[$i]{rfp} eq 'T' && $pd{clause}[$i]{type} eq 'H') {
            @colData = ("$pd{clause}[$i]{text}\n ");
            $pdf->tableRow(fontSize => 10, fontID => $fontID,
                       colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
        }
    }

# blank line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (""); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->tableRow(fontSize => 0.0001, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>.5);
#

# Item header
    $colCount = 6;
    @colWidths = (27,72,249,62,52,60);
    @colAlign = ("center", "left", "left", "center", "center", "center");
    @colData = ("ITEM", "PART #", "DESCRIPTION", "QTY", "UNIT PRICE", "EXTENDED PRICE");
    $pdf->tableRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);


# blank line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (""); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->tableRow(fontSize => 0.0001, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>1);
#

# Items
    $colCount = 7;
    @colWidths = (27,72,249,32,22,52,60);
    @colAlign = ("center", "left", "left", "center", "center", "right", "right");
    for (my $i=0; $i<$pd{itemCount}; $i++) {
        @colData = ("$pd{items}[$i]{itemnumber}", "$pd{items}[$i]{partnumber}", "$pd{items}[$i]{description}", "$pd{items}[$i]{quantity}",
                    "$pd{items}[$i]{unitofissue}", " ", " ");
        $pdf->tableRow(fontSize => 10, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    }

# blank line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = ("\n "); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->tableRow(fontSize => 2, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    @colData = ("");
    $pdf->tableRow(fontSize => 0.0001, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>.5);
#

# totals
    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("right");
    @colData = ("Shipping Costs __________\nSub Total __________\nTax (if applicable) @ _____% __________\nTotal __________\n ");
    $pdf->tableRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);


# footer clauses
    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("left");
    for (my $i=0; $i<$pd{clauseCount}; $i++) {
        if ($pd{clause}[$i]{rfp} eq 'T' && $pd{clause}[$i]{type} eq 'F') {
            @colData = ("$pd{clause}[$i]{text}\n ");
            $pdf->tableRow(fontSize => 10, fontID => $fontID,
                       colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
        }
    }

# signatures
    $colCount = 2;
    @colWidths = (277,277);
    @colAlign = ("left", "left");
    @colData = (
        "________________________________________\n" .
        "Print Name\n\n" .
        "________________________________________\n" .
        "Signature\n\n" .
        "________________________________________\n" .
        "Telephone Number/FAX\n\n",
        "________________________________________\n" .
        "Company Name\n\n" .
        "________________________________________\n" .
        "Title\n\n" .
        "________________________________________\n" .
        "Date\n\n"
        
    );
    $pdf->tableRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);

    my @deptInfo = &getDeptArray(dbh=>$args{dbh}, schema=>$args{schema}, id=>$pd{deptid});
    my $site = $deptInfo[0]{site};
    my @siteInfo = &getSiteInfoArray(dbh=>$args{dbh}, schema=>$args{schema});
    my $buyerName = ((defined($pd{buyer}) && $pd{buyer} > 0) ? &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$pd{buyer}) : "N/A");
    my %userInfo = &getUserInfo(dbh=>$args{dbh}, schema=>$args{schema}, ID=>((defined($pd{buyer})) ? $pd{buyer} : "0"));
    my $phoneNumber = "($userInfo{areacode}) " . substr($userInfo{phonenumber}, 0, 3) . "-" . substr($userInfo{phonenumber}, 3, 4);
    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("left");
    @colData = ("All questions should be directed to $buyerName at $phoneNumber.");
    $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    $pdf->tableRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $phoneNumber = "(" . substr($siteInfo[$site]{fax}, 0, 3) . ") " . substr($siteInfo[$site]{fax}, 3, 3) . "-" . substr($siteInfo[$site]{fax}, 6, 4);
    @colData = ("$siteInfo[$site]{shortname} Fax Number is $phoneNumber");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->tableRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $colCount = 2;
    @colWidths = (277,277);
    @colAlign = ("left", "left");
    @colData = (
        "\n\n" .
        "________________________________________\n" .
        "$siteInfo[$site]{longname}\n\n",
        "\n\n" .
        "________________________________________\n" .
        "Date\n\n"
        
    );
    $pdf->tableRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    

    
## finish pdf
    my $pdfBuff = $pdf->finish;
########    
    
    if ($args{forDisplay} eq 'T') {
        my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>'.pdf');
        $output .= "Content-type: $mimeType\n\n";
        $output .= "Content-disposition: inline; filename=$args{id}.pdf\n";
        $output .= "\n";
    }
    $output .= $pdfBuff;
    

    return($output);
}


###################################################################################################################################
sub doPlacePO {  # routine to get place PO data
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my $pdf = &doPrintPR(dbh => $args{dbh}, schema => $args{schema}, id => $settings{prnumber}, forDisplay=>'F');
    my $status = &doProcessPlacePO(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, pdf=>$pdf, settings => \%settings);

    $message = "PO $settings{prnumber} / $settings{ponumber} placed";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 36);
    
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('home','home');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doPrintPO {  # routine to generate a PDF of a PO
###################################################################################################################################
    my %args = (
        id => 0,
        forDisplay => 'T',
        @_,
    );
    #my $hashRef = $args{settings};
    #my %settings = %$hashRef;
    my $output = "";
    my %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id});
    my %rPD = ((defined($pd{relatedpr}) && $pd{relatedpr} gt ' ') ? getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$pd{relatedpr}) : ());
    my %siteInfo = getSiteInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$pd{site});
    my $formWidth = 570;
    
    my $pdf = new PDF;
    $pdf->setup(orientation => 'portrait', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
        cellPadding => 4);

#######

## Headers
    my $logo = $pdf->addImage(source=>'file', type=>'png', fileName=>"$SYSFullImagePath/" . lc($siteInfo{shortname}) . "-logo-sm.png");
    $pdf->placeHeaderImage(image=>$logo, alignment => 'left', scale=> .35, xOffset=>-20, yOffset=>30);    
    
    my $colCount = 4;
    my @colWidths = (289, 75, 112, 62);
    my @colAlign = ("left", "left", "left", "left");
    my @colData = ("" . uc($siteInfo{shortname}) . " SUPPORT SERVICES", "Reference No.", (($pd{contracttype} == 2) ? "Blanket " : "") . "Purchase Order No.", "Order Date");
    
    my $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    @colAlign = ("left", "center", "center", "center");
    if ($pd{contracttype} == 1) {
        @colData = ("PURCHASE ORDER (PO)", ((defined($pd{refnumber})) ? $pd{refnumber} : ""), 
              "$pd{ponumber}" . ((defined($pd{amendment}) && $pd{amendment} gt ' ') ? $pd{amendment} : ""), 
              ((defined($pd{podate}) && $pd{podate} gt ' ') ? "$pd{podate}" : ""));
    } else {
        @colData = ("DELIVERY ORDER No.: $pd{ponumber}", ((defined($pd{refnumber})) ? $pd{refnumber} : ""), 
              "$rPD{ponumber}" . ((defined($rPD{amendment}) && $rPD{amendment} gt ' ') ? $rPD{amendment} : ""), 
              ((defined($pd{podate}) && $pd{podate} gt ' ') ? "$pd{podate}" : ""));
    }
    $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("center");
    @colData = ("IMPORTANT: Mark all packages, paperwork, and invoices with Contract, Reference, and Order Numbers.");
    $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    $colCount = 5;
    @colWidths = (81,83,97, 89,180);
    @colAlign = ("center", "center", "center", "center", "center");
    @colData = ("Contract Number", "Purchase Request No.", "Requestor", "Buyer", "Charge Number(s)");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    @colAlign = ("center", "center", "center", "center", "center");
    my $fullName = &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=> $pd{requester});
    my $fullNameB = &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=> $pd{buyer});
    my $chargelist = "";
    my $lastcharge = "";
    if ($pd{contracttype} == 1) {
        for (my $i=0; $i<$pd{chargedistlistCount}; $i++) {
#            if ($pd{chargedistlist}[$i]{chargenumber} ne $lastcharge) {
                #$chargelist .= (($lastcharge ne "") ? ", " : "") . $pd{chargedistlist}[$i]{chargenumber} . "-" . $pd{chargedistlist}[$i]{ec};
                $chargelist .= (($i > 0) ? ", " : "") . $pd{chargedistlist}[$i]{chargenumber} . "-" . $pd{chargedistlist}[$i]{ec};
#                $lastcharge = $pd{chargedistlist}[$i]{chargenumber};
#            }
        }
    } else {
        for (my $i=0; $i<$rPD{chargedistlistCount}; $i++) {
            if ($rPD{chargedistlist}[$i]{chargenumber} ne $lastcharge) {
                $chargelist .= (($lastcharge ne "") ? ", " : "") . $rPD{chargedistlist}[$i]{chargenumber} . "-" . $pd{chargedistlist}[$i]{ec};
                $lastcharge = $rPD{chargedistlist}[$i]{chargenumber};
            }
        }
    }
    @colData = ("$siteInfo{contractnumber}", "$pd{prnumber}", "$fullName", "$fullNameB", "$chargelist");
    $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

#vendor/order type info
    $colCount = 2;
    @colWidths = (277,277);
    @colAlign = ("left", "left");
    @colData = ("Vendor", "Type of Order");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    $colCount = 2;
    @colWidths = (277,277);
    @colAlign = ("left", "left");
    my %vendor;
    my $vendorText = "";
    if (defined($pd{vendor}) && $pd{vendor}>0) {
        %vendor = &getVendorInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$pd{vendor});
        $vendorText = "$vendor{name}\n$vendor{address}\n$vendor{city}, $vendor{state} $vendor{zip}\n";
        $vendorText .= "Phone: $vendor{phone} " . ((defined($vendor{extension}) && $vendor{extension} gt ' ') ? "Ext: $vendor{extension} " : "");
        $vendorText .= "Fax: " . ((defined($vendor{fax})) ? $vendor{fax} : "");
    } else {
        $vendorText = "N/A";
    }
    my $poTypeText = "";
    if ($pd{contracttype} == 1) {
        $poTypeText = "PURCHASE ORDER -- Reference the following work authorization agreement and associated terms and conditions.";
    } elsif ($pd{contracttype} == 2) {
        $poTypeText = "DELIVERY ORDER -- Issued subject to the terms and conditions of contract '$rPD{ponumber}"  . 
              ((defined($rPD{amendment}) && $rPD{amendment} > ' ') ? $rPD{amendment} : "") . "'.";
    }
    if ($pd{potype} !=1) {
        $poTypeText .= "\n\n" . (($pd{potype} == 2) ? "Blanket" : "PO Maintenance/Partial Maintenance") . " Contract Duration:\n";
        $poTypeText .= "$pd{startdate} - $pd{enddate}";
    }
    @colData = ("$vendorText", "$poTypeText");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

# 
    $colCount = 4;
    @colWidths = (277, 87, 87, 87);
    @colAlign = ("center", "center", "center", "center");
    my $busClass = "";
    for (my $i=0; $i<$vendor{classificationCount}; $i++) {
        $busClass .= (($i>0) ? ", " : "") . "$vendor{classifications}[$i]{name}";
    }
    @colData = ("Business Classification(s)\n$busClass",
                   "F.O.B.\n" . ("","Origin","Destination", "N/A")[$pd{fob}],
                   (($pd{contracttype} == 1) ? "Delivery Date\n$pd{duedate}" : "Expiration Date\n$rPD{enddate}"),
                   (($pd{contracttype} == 1) ? "Payment Terms\n$pd{paymentterms}" : "Payment Terms\n$rPD{paymentterms}"));
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

# deliver/bill to
    $colCount = 2;
    @colWidths = (277, 277);
    @colAlign = ("left", "left");
    my $deliverTo = "Deliver To (Unless otherwise noted in PO or attachments)\n";
    $deliverTo .= "$siteInfo{longname}\n$siteInfo{daddress}\n$siteInfo{dcity}, $siteInfo{dstate} $siteInfo{dzip}";
    my $billTo = "Bill To\n";
    $billTo .= "$siteInfo{longname}\n$siteInfo{address}\n$siteInfo{city}, $siteInfo{state} $siteInfo{zip}";
    @colData = ("$deliverTo", "$billTo");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    $colCount = 7;
    @colWidths = (22,76,249,22,32,52,61);
    @colAlign = ("center", "center", "center", "center", "center", "center", "center");
    @colData = ("No.", "Part No.", "Description", "Qty","Unit of Issue", "Unit Price", "Total Amount");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    my $subTotal = 0;
    for (my $i=0; $i<$pd{itemCount}; $i++) {
        my $lineTotal = $pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice};
        $subTotal += $lineTotal;
    }

## Footers
# justification & totals
    $colCount = 3;
    @colWidths = (406,80,60);
    @colAlign = ("left", "right", "right");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    @colData = ("\n\n", " ", " ");
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    my $total = $subTotal + $pd{shipping} + (($pd{taxexempt} eq 'F' && (!defined($vendor{taxpermits}[$pd{site}]{hastaxid}) || $vendor{taxpermits}[$pd{site}]{hastaxid} eq 'T')) ? $pd{tax} : 0);
    @colData = ($pd{justification}, "Subtotal\nShipping & Handling\nSalesTax\nTotal Cost", 
          &dollarFormat($subTotal) . "\n" . &dollarFormat($pd{shipping}) . "\n" . 
          &dollarFormat((($pd{taxexempt} eq 'F' && (!defined($vendor{taxpermits}[$pd{site}]{hastaxid}) || $vendor{taxpermits}[$pd{site}]{hastaxid} eq 'T')) ? $pd{tax} : 0)) . "\n" . &dollarFormat($total));
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
# display use tax when needed
    if ($pd{taxexempt} eq 'F' && (defined($vendor{taxpermits}[$pd{site}]{hastaxid}) && $vendor{taxpermits}[$pd{site}]{hastaxid} eq 'F')) {
        $colCount = 1;
        @colWidths = (562);
        @colAlign = ("left");
        my $total2 = $subTotal + $pd{shipping} + $pd{tax};
        @colData = ("Internal Use Only -   Use Tax: " . &dollarFormat($pd{tax}) . ",  Total (with use tax): " . &dollarFormat($total2));
        $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01,
                   rowColor => 0.8);
    }

    if ($pd{contracttype} == 1) {
# Approval info
        $colCount = 1;
        @colWidths = (562);
        @colAlign = ("center");
        @colData = ("APPROVAL");
        $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
        $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
        $colCount = 2;
        @colWidths = (277, 277);
        @colAlign = ("center","center");
        my @roleInfo = &getUserRoleInfoArray(dbh=>$args{dbh}, schema=>$args{schema}, site=>$pd{site}, role=>12);
        my $pmSignInfo = "Name/Title of Individual Authorized to Sign on Behalf of $siteInfo{shortname}\n\n";
        $pmSignInfo .= &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$roleInfo[0]{userid}) . ", $roleInfo[0]{rolename}";
        @colData = ("$pmSignInfo", "Signature/Date of Individual authorized to sign on Behalf of $siteInfo{shortname}\n\n\n\n");
        $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
        $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

# Acceptance info
        $colCount = 1;
        @colWidths = (562);
        @colAlign = ("center");
        @colData = ("ACCEPTANCE");
        $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
        $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
        $colCount = 2;
        @colWidths = (277, 277);
        @colAlign = ("center","center");
        @colData = ("Type Name/Title of Individual Authorized to Sign on Behalf of Vendor", 
                    "Signature/Date of Individual authorized to sign on Behalf of Vendor\n\n\n\n");
        $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
        $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

        $colCount = 1;
        @colWidths = (562);
        @colAlign = ("center");
        @colData = ("Terms & Conditions in Accordance with Attached FAR and DEAR Clauses");
        $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
        $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    
        $pdf->addFooter(fontSize => 8.0, text => "Page <page>", alignment => "center");
    } else {
# Approval info
        $colCount = 1;
        @colWidths = (562);
        @colAlign = ("center");
        @colData = ("AUTHORIZATION");
        $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
        $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
        $colCount = 2;
        @colWidths = (277, 277);
        @colAlign = ("center","center");
        @colData = ("Name", "Approval Date");
        $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
        $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
        @colAlign = ("left","left");
        $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
        my @approvals = &getPDApprovals(dbh => $args{dbh}, schema => $args{schema}, pd => $pd{prnumber}, status => 4);
        for (my $i=0; $i<$#approvals; $i++) {
            @colData = ("$approvals[$i]{lastname}, $approvals[$i]{firstname}", 
                  ((defined($approvals[$i]{dateapproved})) ? $approvals[$i]{dateapproved} : ""));
            $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
                       colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
        }
        @colData = (" ", " ", " ");
    }

    $pdf->newPage(orientation => 'portrait', useGrid => 'F');

# page contents

# parse clauses
    for (my $i=0; $i<$pd{clauseCount}; $i++) {
        if ($pd{clause}[$i]{po} eq 'T') {
            $pd{clause}[$i]{text} =~ s/<br>/\n/g;
        }
    }

# header clauses
    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("left");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    for (my $i=0; $i<$pd{clauseCount}; $i++) {
        if ($pd{clause}[$i]{po} eq 'T' && $pd{clause}[$i]{type} eq 'H') {
            @colData = ("$pd{clause}[$i]{text}\n ");
            $pdf->tableRow(fontSize => 8, fontID => $fontID,
                       colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
        }
    }

# line items
    $colCount = 7;
    @colWidths = (22,76,249,22,32,52,61);
    @colAlign = ("center", "left", "left", "center", "center", "right", "right");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    for (my $i=0; $i<$pd{itemCount}; $i++) {
        my $lineTotal = $pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice};
        @colData = ("$pd{items}[$i]{itemnumber}", ((defined($pd{items}[$i]{partnumber})) ? $pd{items}[$i]{partnumber} : ""), 
                    "$pd{items}[$i]{description}", "$pd{items}[$i]{quantity}",
                    "$pd{items}[$i]{unitofissue}", &dollarFormat($pd{items}[$i]{unitprice}), &dollarFormat($lineTotal));
        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    }

# enclosures
    if (defined($pd{enclosures}) && $pd{enclosures} gt " ") {
        $colCount = 1;
        @colWidths = (562);
        @colAlign = ("left");
        $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
        @colData = ("\n\nEnclosures:\n$pd{enclosures}");
        $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
        
    }

# blank line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = ("\n "); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->tableRow(fontSize => 2, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    @colData = ("");
    $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);

# footer clauses
    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("left");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    for (my $i=0; $i<$pd{clauseCount}; $i++) {
        if ($pd{clause}[$i]{po} eq 'T' && $pd{clause}[$i]{type} eq 'F') {
            @colData = ("$pd{clause}[$i]{text}\n ");
            $pdf->tableRow(fontSize => 8, fontID => $fontID,
                       colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
        }
    }

## finish pdf
    my $pdfBuff = $pdf->finish;
########    
    
    if ($args{forDisplay} eq 'T') {
        my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>'.pdf');
        $output .= "Content-type: $mimeType\n\n";
        $output .= "Content-disposition: inline; filename=$args{id}.pdf\n";
        $output .= "\n";
    }
    $output .= $pdfBuff;
    

    return($output);
}


###################################################################################################################################
sub doAmendPO {  # routine to amend a PO
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$settings{id});
    if (defined($pd{amendment}) && $pd{amendment} ge 'A') {
        my $letter = ord($pd{amendment});
        $letter++;
        $pd{amendment} = chr($letter);
    } else {
        $pd{amendment} = 'A';
    }
    my $status = &doProcessAmendPO(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, amendment=>$pd{amendment}, 
              settings => \%settings);
    
    $message = "PO $pd{prnumber} / $pd{ponumber} Amended ($pd{amendment})";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 38);
    
    $output .= "<script language=javascript><!--\n";
    $output .= "   $args{form}.id.value='$settings{id}';\n";
    $output .= "   submitForm('$args{form}','updatepoform');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doChangeVendor {  # routine to amend a PO
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$settings{id});
    if ($pd{status} ne 16) {
        if (defined($pd{amendment}) && $pd{amendment} ge 'A') {
            my $letter = ord($pd{amendment});
            $letter++;
            $pd{amendment} = chr($letter);
        } else {
            $pd{amendment} = 'A';
        }
    }
    my $status = &doProcessChangeVendor(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, amendment=>$pd{amendment}, 
              settings => \%settings);
    
    $message = "PO $pd{prnumber} / $pd{ponumber} Amended ($pd{amendment}) for vendor change";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 38);
    
    $output .= "<script language=javascript><!--\n";
    $output .= "   $args{form}.id.value='$settings{id}';\n";
    $output .= "   submitForm('bids','bidsform');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doAmendRFP {  # routine to amend an RFP
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my $status = &doProcessAmendRFP(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
              settings => \%settings);
    
    $message = "RFP $settings{id} Amended";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 41);
    
    $output .= "<script language=javascript><!--\n";
    $output .= "   $args{form}.id.value='$settings{id}';\n";
    $output .= "   submitForm('$args{form}','updaterfpform');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doReopenPO {  # routine to reopen a PO
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$settings{id});
    my $status = &doUpdatePDStatus(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, status=> 18,
              remarks => "Reopen PO - \n" . $settings{remarks}, settings => \%settings);
    
    $message = "PO $pd{prnumber} / $pd{ponumber}" . ((defined($pd{amendment})) ? $pd{amendment} : "") . " Reopened";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 39);
    
    $output .= doAlertBox(text => "$message");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('home','home');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doCancelPR {  # routine to cancel a PR
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$settings{id});
    my $status = &doUpdatePDStatus(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, status=> 20, 
              remarks => "Cancel PR - \n" . $settings{remarks}, settings => \%settings);
    $status = &doClearApprovals(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$settings{id});
    
    $message = "PD $pd{prnumber}" . ((defined($pd{ponumber})) ? " / $pd{ponumber}" . ((defined($pd{amendment})) ? $pd{amendment} : "") : "") . " Canceled";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 40);
    
    $output .= doAlertBox(text => "$message");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('home','home');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doCancelRFP {  # routine to cancel an RFP / Init PR
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    my $pdf = '';
    
    my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$settings{id});
    my $status = &doUpdatePDStatus(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, status=> 20, 
              remarks => "Cancel PD - \n" . $settings{remarks}, settings => \%settings);
    $status = &addClause(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$settings{id}, clause=>$settings{remarks});
    $status = &doClearApprovals(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$settings{id});
    $pdf = &doPrintRFP(dbh => $args{dbh}, schema => $args{schema}, id => $settings{id}, forDisplay=>'F');
    if ($pd{status} >= 11) {
        $status = &addArchive(dbh => $args{dbh}, schema => $args{schema}, pd => $settings{id}, pdf=>$pdf, description=> 'RFP PD Canceled');
        $pdf = &doPrintPO(dbh => $args{dbh}, schema => $args{schema}, id => $settings{id}, forDisplay=>'F');
        sleep 2; # required to have unique archive times (1 may work as well as 2)
    }
    &addPDHistory(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, pd => $settings{id},
                 archiveDescription => 'RFP / PO Canceled', changes => 'RFP / PO Canceled', pdf=> $pdf);
    $message = "PD $pd{prnumber}" . ((defined($pd{ponumber})) ? " / $pd{ponumber}" . ((defined($pd{amendment})) ? $pd{amendment} : "") : "") . " Canceled";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 40);
    $message .= ",\\nPlease browse to document and print";
    
    $output .= doAlertBox(text => "$message");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('home','home');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doCancelPO {  # routine to cancel a placed/ammended PO
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    my $pdf = '';
    
    my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$settings{id});
    my $status = &doUpdatePDStatus(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, status=> 20, 
              remarks => "Cancel PD - \n" . $settings{remarks}, settings => \%settings);
    $status = &addClause(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$settings{id}, clause=>$settings{remarks});
    $status = &doClearApprovals(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$settings{id});
#    my @clause = &getClauseArray(dbh=>$args{dbh}, schema=>$args{schema}, id=15);
#    $status = &addClause(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$settings{id}, clause=>$clause[0]{text}, precedence=>-2);
    &doProcessCancelPO(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$settings{id});
    $pdf = &doPrintPO(dbh => $args{dbh}, schema => $args{schema}, id => $settings{id}, forDisplay=>'F');
    &addPDHistory(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, pd => $settings{id},
                 archiveDescription => 'PO Canceled', changes => 'PO Canceled', pdf=> $pdf);
    $message = "PD $pd{prnumber}" . ((defined($pd{ponumber})) ? " / $pd{ponumber}" . ((defined($pd{amendment})) ? $pd{amendment} : "") : "") . " Canceled";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 40);
    $message .= ",\\nPlease browse to document and print";
    
    $output .= doAlertBox(text => "$message");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('home','home');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doPrintArchive {  # routine to display an archive PDF of a PD
###################################################################################################################################
    my %args = (
        id => 0,
        date => 0,
        @_,
    );
    my $output = "";
    my %arch = &getArchiveInfo(dbh => $args{dbh}, schema => $args{schema}, pd=>$args{id}, date=>$args{date});

    my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>'.pdf');
    $output .= "Content-type: $mimeType\n\n";
    $output .= "Content-disposition: inline; filename=$args{id}.pdf\n";
    $output .= "\n";

    $output .= $arch{pdf};
    
    return($output);
}
    

###################################################################################################################################
sub doPrintPOInfo {  # routine to generate a PDF of PO Info
###################################################################################################################################
    my %args = (
        id => 0,
        forDisplay => 'T',
        @_,
    );
    #my $hashRef = $args{settings};
    #my %settings = %$hashRef;
    my $output = "";
    my %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id});
    my %rPD = ((defined($pd{relatedpr}) && $pd{relatedpr} gt ' ') ? getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$pd{relatedpr}) : ());
    my %siteInfo = getSiteInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$pd{site});
    my $formWidth = 570;
    
    my $pdf = new PDF;
    $pdf->setup(orientation => 'portrait', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
        cellPadding => 4);

#######

## Headers
    #my $logo = $pdf->addImage(source=>'file', type=>'png', fileName=>"$SYSFullImagePath/" . lc($siteInfo{shortname}) . "-logo-sm.png");
    #$pdf->placeHeaderImage(image=>$logo, alignment => 'left', scale=> .35, xOffset=>-20, yOffset=>30);    
    
    my $colCount = 4;
    my @colWidths = (289, 75, 112, 62);
    my @colAlign = ("left", "left", "left", "left");
    my @colData = ("" . uc($siteInfo{shortname}) . " SUPPORT SERVICES", "Reference No.", (($pd{contracttype} == 2) ? "Blanket " : "") . "Purchase Order No.", "Order Date");
    
    my $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    @colAlign = ("left", "center", "center", "center");
    if ($pd{contracttype} == 1) {
        @colData = ("PURCHASE ORDER INFORMATION", ((defined($pd{refnumber})) ? $pd{refnumber} : ""), 
              "$pd{ponumber}" . ((defined($pd{amendment}) && $pd{amendment} gt ' ') ? $pd{amendment} : ""), 
              ((defined($pd{podate}) && $pd{podate} gt ' ') ? "$pd{podate}" : ""));
    } else {
        @colData = ("DELIVERY ORDER No.: $pd{ponumber}", ((defined($pd{refnumber})) ? $pd{refnumber} : ""), 
              "$rPD{ponumber}" . ((defined($rPD{amendment}) && $rPD{amendment} gt ' ') ? $rPD{amendment} : ""), 
              ((defined($pd{podate}) && $pd{podate} gt ' ') ? "$pd{podate}" : ""));
    }
    $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("center");
    @colData = ("$pd{briefdescription}");
    $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    $colCount = 5;
    @colWidths = (81,83,97, 89,180);
    @colAlign = ("center", "center", "center", "center", "center");
    @colData = ("Contract Number", "Purchase Request No.", "Requestor", "Buyer", "Charge Number(s)");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    @colAlign = ("center", "center", "center", "center", "center");
    my $fullName = &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=> $pd{requester});
    my $fullNameB = &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=> $pd{buyer});
    my $chargelist = "";
    my $lastcharge = "";
    if ($pd{contracttype} == 1) {
        for (my $i=0; $i<$pd{chargedistlistCount}; $i++) {
#            if ($pd{chargedistlist}[$i]{chargenumber} ne $lastcharge) {
#                $chargelist .= (($lastcharge ne "") ? ", " : "") . $pd{chargedistlist}[$i]{chargenumber} . "-" . $pd{chargedistlist}[$i]{ec};
                $chargelist .= (($i > 0) ? ", " : "") . $pd{chargedistlist}[$i]{chargenumber} . "-" . $pd{chargedistlist}[$i]{ec};
#                $lastcharge = $pd{chargedistlist}[$i]{chargenumber};
#            }
        }
    } else {
        for (my $i=0; $i<$rPD{chargedistlistCount}; $i++) {
#            if ($rPD{chargedistlist}[$i]{chargenumber} ne $lastcharge) {
                #$chargelist .= (($lastcharge ne "") ? ", " : "") . $rPD{chargedistlist}[$i]{chargenumber} . "-" . $pd{chargedistlist}[$i]{ec};
                $chargelist .= (($i > 0) ? ", " : "") . $rPD{chargedistlist}[$i]{chargenumber} . "-" . $pd{chargedistlist}[$i]{ec};
#                $lastcharge = $rPD{chargedistlist}[$i]{chargenumber};
#            }
        }
    }
    @colData = ("$siteInfo{contractnumber}", "$pd{prnumber}", "$fullName", "$fullNameB", "$chargelist");
    $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

#vendor/order type info
    $colCount = 2;
    @colWidths = (277,277);
    @colAlign = ("left", "left");
    @colData = ("Vendor", "Type of Order");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    $colCount = 2;
    @colWidths = (277,277);
    @colAlign = ("left", "left");
    my $vendorText = "";
    my %vendor;
    if (defined($pd{vendor}) && $pd{vendor}>0) {
        %vendor = &getVendorInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$pd{vendor});
        $vendorText = "$vendor{name}\n$vendor{address}\n$vendor{city}, $vendor{state} $vendor{zip}\n";
        $vendorText .= "Phone: $vendor{phone} " . ((defined($vendor{extension}) && $vendor{extension} gt ' ') ? "Ext: $vendor{extension} " : "");
        $vendorText .= "Fax: " . ((defined($vendor{fax})) ? $vendor{fax} : "");
    } else {
        $vendorText = "N/A";
    }
    my $poTypeText = "";
    if ($pd{contracttype} == 1) {
        $poTypeText = "PURCHASE ORDER -- Reference the following work authorization agreement and associated terms and conditions.";
    } elsif ($pd{contracttype} == 2) {
        $poTypeText = "DELIVERY ORDER -- Issued subject to the terms and conditions of contract '$rPD{ponumber}"  . 
              ((defined($rPD{amendment}) && $rPD{amendment} > ' ') ? $rPD{amendment} : "") . "'.";
    }
    if ($pd{potype} !=1) {
        $poTypeText .= "\n\n" . (($pd{potype} == 2) ? "Blanket" : "PO Maintenance/Partial Maintenance") . " Contract Duration:\n";
        $poTypeText .= "$pd{startdate} - $pd{enddate}";
    }
    @colData = ("$vendorText", "$poTypeText");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

# 
    $colCount = 5;
    @colWidths = (182, 87, 87, 87, 87);
    @colAlign = ("center", "center", "center", "center", "center");
    my $busClass = "";
    for (my $i=0; $i<$vendor{classificationCount}; $i++) {
        $busClass .= (($i>0) ? ", " : "") . "$vendor{classifications}[$i]{name}";
    }
    @colData = ("Business Classification(s)\n$busClass", 
                   "Status\n" . &getPDStatusText(dbh=>$args{dbh}, schema=>$args{schema}, status=>$pd{status}),
                   "F.O.B.\n" . ("","Origin","Destination", "N/A")[$pd{fob}],
                   (($pd{contracttype} == 1) ? "Delivery Date\n$pd{duedate}" : "Expiration Date\n$rPD{enddate}"),
                   (($pd{contracttype} == 1) ? "Payment Terms\n$pd{paymentterms}" : "Payment Terms\n$rPD{paymentterms}"));
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    $colCount = 7;
    @colWidths = (22,76,249,22,32,52,61);
    @colAlign = ("center", "center", "center", "center", "center", "center", "center");
    @colData = ("No.", "Part No.", "Description", "Qty","Unit of Issue", "Unit Price", "Total Amount");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);

    my $subTotal = 0;
    for (my $i=0; $i<$pd{itemCount}; $i++) {
        my $lineTotal = $pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice};
        $subTotal += $lineTotal;
    }

## Footers
# justification & totals
    $colCount = 3;
    @colWidths = (406,80,60);
    @colAlign = ("left", "right", "right");
    @colData = ("\n\n", " ", " ");
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.00);
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my $total = $subTotal + $pd{shipping} + (($pd{taxexempt} eq 'F' && (!defined($vendor{taxpermits}[$pd{site}]{hastaxid}) || $vendor{taxpermits}[$pd{site}]{hastaxid} eq 'T')) ? $pd{tax} : 0);
    @colData = ($pd{justification}, "Subtotal\nShipping & Handling\nSalesTax\nTotal Cost", 
          &dollarFormat($subTotal) . "\n" . &dollarFormat($pd{shipping}) . "\n" . 
          &dollarFormat((($pd{taxexempt} eq 'F' && (!defined($vendor{taxpermits}[$pd{site}]{hastaxid}) || $vendor{taxpermits}[$pd{site}]{hastaxid} eq 'T')) ? $pd{tax} : 0)) . "\n" . &dollarFormat($total));
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
# display use tax when needed
    if ($pd{taxexempt} eq 'F' && (defined($vendor{taxpermits}[$pd{site}]{hastaxid}) && $vendor{taxpermits}[$pd{site}]{hastaxid} eq 'F')) {
        $colCount = 1;
        @colWidths = (562);
        @colAlign = ("left");
        my $total2 = $subTotal + $pd{shipping} + $pd{tax};
        @colData = ("Internal Use Only -   Use Tax: " . &dollarFormat($pd{tax}) . ",  Total (with use tax): " . &dollarFormat($total2));
        $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01,
                   rowColor => 0.8);
    }


    $pdf->newPage(orientation => 'portrait', useGrid => 'F');

# page contents

# parse clauses
#    for (my $i=0; $i<$pd{clauseCount}; $i++) {
#        if ($pd{clause}[$i]{po} eq 'T') {
#            $pd{clause}[$i]{text} =~ s/<br>/\n/g;
#        }
#    }


# line items
    $colCount = 7;
    @colWidths = (22,76,249,22,32,52,61);
    @colAlign = ("center", "left", "left", "center", "center", "right", "right");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    for (my $i=0; $i<$pd{itemCount}; $i++) {
        my $lineTotal = $pd{items}[$i]{quantity} * $pd{items}[$i]{unitprice};
        @colData = ("$pd{items}[$i]{itemnumber}", ((defined($pd{items}[$i]{partnumber})) ? $pd{items}[$i]{partnumber} : ""), 
                    "$pd{items}[$i]{description}", "$pd{items}[$i]{quantity}",
                    "$pd{items}[$i]{unitofissue}", &dollarFormat($pd{items}[$i]{unitprice}), &dollarFormat($lineTotal));
        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    }

# blank line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = ("\n "); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->tableRow(fontSize => 2, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    @colData = ("");
    $pdf->tableRow(fontSize => 6, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);

# Receiving
    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("left");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    @colData = ("Receive Information");
    $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    my @rLog = &getReceiving(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pd{prnumber}, orderBy=>'datereceived');
    $colCount = 5;
    @colWidths = (60,100,20,40,310);
    @colAlign = ("center", "left", "center", "center", "left");
    @colData = ("Date Received", "Delivered To", "Item", "Quantity", "Comments");
    $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    for (my $i=0; $i<$#rLog; $i++) {
        for (my $j=0; $j<$rLog[$i]{itemCount}; $j++) {
            @colData = ("$rLog[$i]{datereceived}", ((defined($rLog[$i]{deliveredto})) ? $rLog[$i]{deliveredto} : ""), 
                  "$rLog[$i]{items}[$j]{itemnumber}", "$rLog[$i]{items}[$j]{quantityreceived}",
                  ((defined($rLog[$i]{items}[$j]{comments})) ? $rLog[$i]{items}[$j]{comments} : ""));
            $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
        }
    }

# blank line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = ("\n "); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->tableRow(fontSize => 2, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    @colData = ("");
    $pdf->tableRow(fontSize => 6, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);

# Invoicing
    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("left");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    @colData = ("Invoice Information");
    $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    my @ap = &getAP(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pd{prnumber}, orderBy=>'i.datereceived');
    $colCount = 11;
    @colWidths = (60,10,40,50,40,65,50,60,27,40,40);
    @colAlign = ("center", "center", "center", "center", "center", "center", "center", "center", "center", "center", "center");
    @colData = ("Charge #", "EC", "Invoice #", "Inv Rec Date", "Inv Date", "Amount (less tax)","Tax Amount","Invoiced Amount","Tax","Paid Date","$SYSClient Billed");
    $pdf->tableRow(fontSize => 7, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    my %taxPaid = (
        'N' => 'Use', 'Y' => 'Sales', 'NA' => 'N/A',
    );
    for (my $i=0; $i<$#ap; $i++) {
        for (my $j=0; $j<$ap[$i]{itemCount}; $j++) {
            @colData = ($ap[$i]{items}[$j]{chargenumber},$ap[$i]{items}[$j]{ec},$ap[$i]{invoicenumber},$ap[$i]{datereceived},$ap[$i]{invoicedate},
                &dollarFormat($ap[$i]{items}[$j]{amount}),&dollarFormat($ap[$i]{items}[$j]{tax}),
                &dollarFormat($ap[$i]{items}[$j]{amount} + $ap[$i]{items}[$j]{tax}), $taxPaid{$ap[$i]{taxpaid}},
                $ap[$i]{datepaid},$ap[$i]{clientbilled});
            $pdf->tableRow(fontSize => 7, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
        }
    }

# blank line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = ("\n "); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->tableRow(fontSize => 2, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    @colData = ("");
    $pdf->tableRow(fontSize => 6, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);

# Charge number info
    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("left");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    @colData = ("Charge Number Information");
    $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $colCount = 5;
    @colWidths = (100,20,100,100, 210);
    @colAlign = ("center", "center", "center", "center", "center");
    @colData = ("Charge #", "EC", "Amount", "Balance", " ");
    $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    for (my $i=0; $i<$pd{chargedistlistCount}; $i++) {
        @colData =($pd{chargedistlist}[$i]{chargenumber},$pd{chargedistlist}[$i]{ec},&dollarFormat($pd{chargedistlist}[$i]{amount}),
        &dollarFormat($pd{chargedistlist}[$i]{amount} - $pd{chargedistlist}[$i]{invoiced}), " ");
        $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    }

# blank line
#    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = ("\n "); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
#    $pdf->tableRow(fontSize => 2, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
#    @colData = ("");
#    $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);

## finish pdf
    my $pdfBuff = $pdf->finish;
########    
    
    if ($args{forDisplay} eq 'T') {
        my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>'.pdf');
        $output .= "Content-type: $mimeType\n\n";
        $output .= "Content-disposition: inline; filename=$args{id}.pdf\n";
        $output .= "\n";
    }
    $output .= $pdfBuff;
    

    return($output);
}
    

###################################################################################################################################
sub doPrintPOActivity {  # routine to generate a PDF of PO Activity
###################################################################################################################################
    my %args = (
        id => 0,
        forDisplay => 'T',
        site => 0,
        startDate => '',
        endDate => '',
        format => 'pdf',
        sortBy => 'prnumber',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $xlsBuff = '';
    my $output = "";
    my $ecCode = (($settings{poactmaintonly} eq 'T') ? 51 : 0);
    my @pdList = getPDByStatus(dbh => $args{dbh}, schema => $args{schema}, siteList=>$args{site}, isHistory=>'T',
#          #hStartDate=>$args{startDate}, hEndDate=>$args{endDate});
#          #hStartDate=>$args{startDate}, hEndDate=>$args{endDate}, statusList=>'15,16,17,18,19', getVendor=>'T');
          hStartDate=>$args{startDate}, hEndDate=>$args{endDate}, statusList=>'15,18', getVendor=>'T', ecCode => $ecCode);
    my $sortField = ((defined($args{sortBy})) ? $args{sortBy} : "vendorName");
    @pdList = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @pdList;
    my $formWidth = 770;
    
    my $pdf = new PDF;
    $pdf->setup(orientation => 'landscape', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
        cellPadding => 4);

#######

## Headers

    my $colCount = 1;
    my @colWidths = (762);
    my @colAlign = ("center");
    my $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my @colData = ("PO Activity Report");
    $pdf->addHeaderRow(fontSize => 12, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    my @siteInfo = &getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});
    @colData = ("From: $args{startDate}  To: $args{endDate}\nSite: " . (($args{site} == 0) ? "All" : $siteInfo[$args{site}]{name}) . (($settings{poactmaintonly} eq 'T') ? "\nMaintenance/Partial Maintenance Only" : ""));
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


    $colCount = 10;
    @colWidths = (60,70,75,75,50,70,60,75,50,111);
    @colAlign = ("center", "center", "center", "center", "center", "center", "center", "center", "center", "center");
    @colData = ("PO Number", "PR Number", "Vendor", "Charge Number", "Requestor", "Department", "Total Cost/\nChange in Cost", "Activity Date", "Buyer", "Description");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


## Footers
#
    $colCount = 1;
    @colWidths = (762);
    @colAlign = ("center");
    my $reportDate = &getSysdate(dbh=>$args{dbh});
    @colData = ("\nReport generated on: $reportDate" . (($settings{poactmaintonly} eq 'T') ? "\n* Indicates partial mainenance" : "")  . "\nPage <page>");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);


    $pdf->newPage(orientation => 'landscape', useGrid => 'F');

# page contents


# line items
    $colCount = 10;
    @colWidths = (60,70,75,75,50,70,60,75,50,111);
    @colAlign = ("left", "left", "left", "left", "left", "left", "right", "center", "left", "left");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my $changeTotal = 0;
    for (my $i=1; $i<=$#pdList; $i++) {
        my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$pdList[$i]{prnumber}, history=>'T', date=>$pdList[$i]{changedate}, ecCode => $ecCode);
        my $changeAmount = ((defined($pd{shippingchange})) ? $pd{shippingchange} : 0) + ((defined($pd{taxchange})) ? $pd{taxchange} : 0);
        for (my $j=0; $j<$pd{itemCount}; $j++) {
            $changeAmount += $pd{items}[$j]{pricechange};
        }
        $changeTotal += $changeAmount;
        @colData = (((defined($pd{ponumber})) ? $pd{ponumber} : "") . ((defined($pd{amendment})) ? $pd{amendment} : '') . (($settings{poactmaintonly} eq 'T' && $pdList[$i]{total} != $pdList[$i]{ectotal}) ? "*" : ""),
              $pd{prnumber},$pd{vendorname}, $pd{chargenumber}, &getFullName(dbh=>$args{dbh},schema=>$args{schema},userID=>$pd{requester}),$pd{deptname},
              dollarFormat($changeAmount) . "   ",$pd{changedate},
#              $pd{chargenumber},dollarFormat($pd{totalChange}) . "   ",$pd{changedate} . "\n$pd{status}," . getPDStatusText(dbh=>$args{dbh},schema=>$args{schema},status=>$pd{status}),
              ((defined($pd{buyer})) ? &getFullName(dbh=>$args{dbh},schema=>$args{schema},userID=>$pd{buyer}) : "n/a"),
              $pd{briefdescription});
        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
        $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    }

# totals
    @colData = ("","","","","","","__________   ","","","");
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    @colData = ("","","","","","",dollarFormat($changeTotal) . "   ","","","");
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


# blank line
#    $colCount = 1; @colWidths = (762); @colAlign = ("center"); @colData = ("\n "); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
#    $pdf->tableRow(fontSize => 2, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
#    @colData = ("");
#    $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);


## finish report
    my $repBuff = '';
    if ($args{format} eq 'pdf') {
        $repBuff = $pdf->finish;
    } elsif ($args{format} eq 'xls') {
        $repBuff = $xlsBuff;
    }
########    
    
    if ($args{forDisplay} eq 'T') {
        my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>".$args{format}");
        $output .= "Content-type: $mimeType\n\n";
        #$output .= "Content-disposition: inline; filename=$args{id}.$args{format}\n";
        $output .= "\n";
    }
    $output .= $repBuff;
    

    return($output);
}
    

###################################################################################################################################
sub doPrintPOSocioEconomic {  # routine to generate a PDF of PO socio economic monitoring
###################################################################################################################################
    my %args = (
        id => 0,
        forDisplay => 'T',
        site => 0,
        startDate => '',
        endDate => '',
        format => 'pdf',
        sortBy => 'vendorpo',
        @_,
    );
    #my $hashRef = $args{settings};
    #my %settings = %$hashRef;
    my $xlsBuff = '';
    my $output = "";
    my $startDate = substr($args{startDate},6,4) . substr($args{startDate},0,2) . substr($args{startDate},3,2);
    my $endDate = substr($args{endDate},6,4) . substr($args{endDate},0,2) . substr($args{endDate},3,2);
    my @pdList = getPDByStatus(dbh => $args{dbh}, schema => $args{schema}, siteList=>$args{site},
          ipStartDate=>$args{startDate}, ipEndDate=>$args{endDate}, getVendor=>'T');
    my $sortField = ((defined($args{sortBy})) ? $args{sortBy} : "vendorpo");
    @pdList = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @pdList;
    my $formWidth = 770;
    
    my $pdf = new PDF;
    $pdf->setup(orientation => 'landscape', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
        cellPadding => 4);

#######

## Headers

    my $colCount = 1;
    my @colWidths = (762);
    my @colAlign = ("center");
    my $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my @colData = ("SocioEconomic Monitoring Program");
    $pdf->addHeaderRow(fontSize => 12, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    my @siteInfo = &getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});
    @colData = ("From: $args{startDate}  To: $args{endDate}\nSite: " . (($args{site} == 0) ? "All" : $siteInfo[$args{site}]{name}));
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


    $colCount = 8;
    @colWidths = (165,50,50,65,50,75,30,231);
    @colAlign = ("center", "center", "center", "center", "center", "center", "center", "center");
    @colData = ("Vendor", "Remit Zip", "Zip", "PO Number", "Paid Date", "Invoiced\nAmount", "Element\nCode", "Description");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


## Footers
# 
    $colCount = 1;
    @colWidths = (762);
    @colAlign = ("center");
    my $reportDate = &getSysdate(dbh=>$args{dbh});
    @colData = ("\n\nReport generated on: $reportDate\nPage <page>");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);


    $pdf->newPage(orientation => 'landscape', useGrid => 'F');

# page contents


# line items
    $colCount = 8;
    @colWidths = (165,50,50,65,50,75,30,231);
    @colAlign = ("left", "left", "left", "left", "center", "right", "center", "left");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my $total = 0;
    for (my $i=1; $i<=$#pdList; $i++) {
        my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$pdList[$i]{prnumber});
        my %vend = &getVendorInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$pd{vendor});
        my @ap = &getAP(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pdList[$i]{prnumber}, orderBy=>'i.datepaid');
        for (my $k=0; $k<$#ap; $k++) {
            if (defined($ap[$k]{datepaid}) && $ap[$k]{datepaid} gt ' ') {
                my $datePaid = substr($ap[$k]{datepaid},6,4) . substr($ap[$k]{datepaid},0,2) . substr($ap[$k]{datepaid},3,2);
                if ($datePaid ge $startDate && $datePaid le $endDate) {
                    for (my $j=0; $j<$ap[$k]{itemCount}; $j++) {
                        my $amount = $ap[$k]{items}[$j]{tax} + $ap[$k]{items}[$j]{amount};
                        @colData = ($vend{name}, $vend{remitzip}, $vend{zip}, $pd{ponumber} . ((defined($pd{amendment})) ? $pd{amendment} : ''), 
                              $ap[$k]{datepaid}, dollarFormat($amount) . "     ", $ap[$k]{items}[$j]{ec}, $pd{briefdescription});
                        $total += $amount;
                        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
                        $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
                    }
                }
            }
        }
    }

# totals
    @colData = ("","","","","","____________     ","","");
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    @colData = ("","","","","",dollarFormat($total) . "     ","","");
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


## finish report
    my $repBuff = '';
    if ($args{format} eq 'pdf') {
        $repBuff = $pdf->finish;
    } elsif ($args{format} eq 'xls') {
        $repBuff = $xlsBuff;
    }
########    
    
    if ($args{forDisplay} eq 'T') {
        my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>".$args{format}");
        $output .= "Content-type: $mimeType\n\n";
        #$output .= "Content-disposition: inline; filename=$args{id}.$args{format}\n";
        $output .= "\n";
    }
    $output .= $repBuff;
    

    return($output);
}
    

###################################################################################################################################
sub doPrintPOAging {  # routine to generate a PDF of PO Aging
###################################################################################################################################
    my %args = (
        id => 0,
        forDisplay => 'T',
        site => 0,
        howOld => '',
        type => '',
        format => 'pdf',
        sortBy => 'prnumber',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my %howOld = (
        '0-30' => ['0 to 30 Days', &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => -30, format=>'yyyy/mm/dd', type=>'days'), &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => 0, format=>'yyyy/mm/dd', type=>'days')],
        '31-60' => ['31 to 60 Days', &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => -60, format=>'yyyy/mm/dd', type=>'days'), &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => -31, format=>'yyyy/mm/dd', type=>'days')],
        '61-120' => ['61 to 120 Days', &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => -120, format=>'yyyy/mm/dd', type=>'days'), &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => -61, format=>'yyyy/mm/dd', type=>'days')],
        '>120' => ['Greater Than 120 Days', &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => -120, format=>'yyyy/mm/dd', type=>'months'), &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => -120, format=>'yyyy/mm/dd', type=>'days')],
    );
#print STDERR "howOld0:$howOld{$args{howOld}}[0]\n";
    my %statusList = (
        initial => ['1,2,3', "Initial PR to PR Approval", "Requested Date"],
        pending => ['4,5,6,7,8,9,10,11,14', "PR Approved to PO Approval", "PR/RFP Date"],
        receiving => ['13,15,16,17,18', "PO's with Pending Receiving", "Due Date"],
    );
#print STDERR "Site:$args{site}, howOld:$args{howOld}, type:$args{type}, howOld2:$howOld{$args{howOld}}, statusList:$statusList{$args{type}}\n";
    my $xlsBuff = '';
    my $output = "";
    my @pdList = getPDByStatus(dbh => $args{dbh}, schema => $args{schema}, siteList=>$args{site},
          statusList=>$statusList{$args{type}}[0], getVendor=>'T');
    my $sortField = ((defined($args{sortBy})) ? $args{sortBy} : "vendorName");
    @pdList = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @pdList;
    my $formWidth = 770;
    
    my $pdf = new PDF;
    $pdf->setup(orientation => 'landscape', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
        cellPadding => 4);

#######

## Headers

    my $colCount = 1;
    my @colWidths = (762);
    my @colAlign = ("center");
    my $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my @colData = ("PO Aging Report");
    $pdf->addHeaderRow(fontSize => 12, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    my @siteInfo = &getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});
    @colData = ($howOld{$args{howOld}}[0] . "\n" . $statusList{$args{type}}[1]);
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


    $colCount = 9;
    #@colWidths = (75,75,75,75,75,75,75,181);
    @colWidths = (60,70,75,75,75,41,54,75,181);
    @colAlign = ("center", "center", "center", "center", "center", "center", "center", "center", "center");
#    @colData = ("PO Number", "PR Number", "Vendor", "Requestor", "Total Cost", "Date", "Status", "Buyer", "Description");
    @colData = ("PO Number", "PR Number", "Vendor", "Requestor", "Total Cost", $statusList{$args{type}}[2], "Status", "Buyer", "Description");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


## Footers
#
    $colCount = 1;
    @colWidths = (762);
    @colAlign = ("center");
    my $reportDate = &getSysdate(dbh=>$args{dbh});
    @colData = ("\nReport generated on: $reportDate\nPage <page>");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);


    $pdf->newPage(orientation => 'landscape', useGrid => 'F');

# page contents


# line items
    $colCount = 9;
    @colWidths = (60,70,75,75,75,41,54,75,181);
    @colAlign = ("left", "left", "left", "left", "right", "center", "center", "left", "left");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my $reportTotal = 0;
    for (my $i=1; $i<=$#pdList; $i++) {
        if (defined($pdList[$i]{prnumber}) && $pdList[$i]{prnumber} gt ' ') {
            my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$pdList[$i]{prnumber});
            if (($args{type} eq 'initial' && $pd{daterequestedtest} ge $howOld{$args{howOld}}[1] && $pd{daterequestedtest} le $howOld{$args{howOld}}[2]) ||
                    ($args{type} eq 'pending' && $pd{status} < 7 && $pd{prdatetest} ge $howOld{$args{howOld}}[1] && $pd{prdatetest} le $howOld{$args{howOld}}[2]) ||
                    ($args{type} eq 'pending' && $pd{rfpduedatetest} ge $howOld{$args{howOld}}[1] && $pd{rfpduedatetest} le $howOld{$args{howOld}}[2]) ||
                    ($args{type} eq 'receiving' && $pd{duedatetest} ge $howOld{$args{howOld}}[1] && $pd{duedatetest} le $howOld{$args{howOld}}[2] && $pd{totOrdered} != $pd{totReceived})) {
                my $dispDate = "";
                if ($args{type} eq 'initial') {
                    $dispDate = $pd{daterequested};
                } elsif ($args{type} eq 'pending' && $pd{status} < 7) {
                    $dispDate = $pd{prdate};
                } elsif ($args{type} eq 'pending') {
                    $dispDate = $pd{rfpduedate};
                } else {
                    $dispDate = $pd{duedate};
                }
#                $dispDate .= "\n$howOld{$args{howOld}}[1]\n$howOld{$args{howOld}}[2]";
#                $dispDate .= "\n$pd{totOrdered}\n$pd{totReceived}";
                @colData = (((defined($pd{ponumber})) ? $pd{ponumber} : "") . ((defined($pd{amendment})) ? $pd{amendment} : ''),
                      $pd{prnumber},$pd{vendorname}, 
                      ((defined($pd{requester})) ? &getFullName(dbh=>$args{dbh},schema=>$args{schema},userID=>$pd{requester}) : "n/a"),
#                      dollarFormat($pd{total}) . "   ", $pd{duedate}, 
                      dollarFormat($pd{total}) . "   ", $dispDate, 
                      $pd{statusname}, ((defined($pd{buyer})) ? &getFullName(dbh=>$args{dbh},schema=>$args{schema},userID=>$pd{buyer}) : "n/a"),
                      $pd{briefdescription});
                $pdf->tableRow(fontSize => 8, fontID => $fontID,
                           colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
                $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
                $reportTotal += $pd{total};
            }
        }
    }

# totals
    @colData = ("","","","","__________   ","","","","");
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    @colData = ("","","","",dollarFormat($reportTotal) . "   ","","","","");
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


# blank line
#    $colCount = 1; @colWidths = (762); @colAlign = ("center"); @colData = ("\n "); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
#    $pdf->tableRow(fontSize => 2, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
#    @colData = ("");
#    $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);


## finish report
    my $repBuff = '';
    if ($args{format} eq 'pdf') {
        $repBuff = $pdf->finish;
    } elsif ($args{format} eq 'xls') {
        $repBuff = $xlsBuff;
    }
########    
    
    if ($args{forDisplay} eq 'T') {
        my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>".$args{format}");
        $output .= "Content-type: $mimeType\n\n";
        #$output .= "Content-disposition: inline; filename=$args{id}.$args{format}\n";
        $output .= "\n";
    }
    $output .= $repBuff;
    

    return($output);
}
    

###################################################################################################################################
sub doPrintObligatedNotInvoiced {  # routine to generate a PDF of Obligated Not Invoiced report
###################################################################################################################################
    my %args = (
        id => 0,
        forDisplay => 'T',
        site => 0,
        format => 'pdf',
        sortBy => 'podate',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $xlsBuff = '';
    my $output = "";
#    my @pdList = getPDByStatus(dbh => $args{dbh}, schema => $args{schema}, siteList=>$args{site},statusList => '15, 16, 17, 18',
#          ipStartDate=>$args{startDate}, ipEndDate=>$args{endDate}, getVendor=>'T');
    my @pdList = getPDByStatus(dbh => $args{dbh}, schema => $args{schema}, siteList=>$args{site},statusList => '15, 16, 17, 18',
          vendor=>$settings{vendorid}, chargeNumber=>$settings{onichargenumber}, getVendor=>'T', cnFromPOCN => 'T');
    my $sortField = ((defined($args{sortBy})) ? $args{sortBy} : "vendorName");
    @pdList = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @pdList;
    my $formWidth = 770;
    
    my $pdf = new PDF;
    #$pdf->setup(orientation => 'landscape', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5);
    $pdf->setup(orientation => 'portrait', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
        cellPadding => 4);

#######

## Headers

    my $colCount = 1;
    my $colCount2 = 7;
    my @colWidths = (762);
    my @colAlign = ("center");
    my $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my @colData = ("Obligated Not Yet Billed to $SYSClient");
    my @colData2 = ("");
    $pdf->addHeaderRow(fontSize => 12, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    my @siteInfo = &getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});
    my %vendorInfo;
    if ($settings{vendorid} != 0) {
        %vendorInfo = getVendorInfo(dbh => $args{dbh}, schema => $args{schema}, id => $settings{vendorid});
    }
    @colData = ("Site: " . (($args{site} == 0) ? "All" : $siteInfo[$args{site}]{name}) . 
          "\nVendor: " . (($settings{vendorid} == 0) ? "All" : $vendorInfo{name}) . 
          "\nCharge Number: " . (($settings{onichargenumber} == '0') ? "All" : $settings{onichargenumber}));
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


    $colCount = 6;
    #@colWidths = (60,65,265,120,80, 60);
    @colWidths = (50,65,165,100,80, 40);
    @colAlign = ("center", "center", "center", "center", "center", "center");
    @colData = ("Date", "PO Number", "Vendor", "Invoice", "Amount", "Tax");
    @colData2 = ("Date", "PO Number", "Vendor", (($settings{onichargenumber} eq '0') ? "PO" : "CN") . " Total", "Invoiced", "Invoiced, Not Billed", "Not Invoiced");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    $xlsBuff .= formatXLSRow(cols=>$colCount2, row=>\@colData2);


## Footers
# 
    $colCount = 1;
    @colWidths = (762);
    @colAlign = ("center");
    my $reportDate = &getSysdate(dbh=>$args{dbh});
    @colData = ("\n\n\nReport generated on: $reportDate\nPage <page>");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);


    #$pdf->newPage(orientation => 'landscape', useGrid => 'F');
    $pdf->newPage(orientation => 'portrait', useGrid => 'F');

# page contents


# line items
    $colCount = 6;
    #@colWidths = (60,65,265,120,80, 60);
    @colWidths = (50,65,165,100,80, 40);
    @colAlign = ("center", "center", "left", "left", "right", "center");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my $total = 0;
    my $totalUnbilled = 0;
    my %taxPaidVals = ('F'=>'Use Tax', 'T'=>'Sales Tax', 'NA'=>'N/A');
    for (my $i=0; $i<=$#pdList; $i++) {
        my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$pdList[$i]{prnumber}, chargeNumber=>$settings{onichargenumber});
#print STDERR "PO: $pdList[$i]{ponumber}, $pd{chargedistAmount}, $pd{chargedistInvoiced}\n";
        my @apList = &getAP(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pdList[$i]{prnumber}, chargeNumber=>$settings{onichargenumber});
        my $hasUnbilled = 'F';
        for (my $j=0; $j<$#apList; $j++) {
            if (!defined($apList[$j]{clientbilled}) || $apList[$j]{clientbilled} le ' ') {
                $hasUnbilled = 'T';
            }
        
        }
        if ($pd{chargedistAmount} != $pd{chargedistInvoiced} || $hasUnbilled eq 'T') {
            @colData = ($pd{podate}, $pd{ponumber} . ((defined($pd{amendment})) ? $pd{amendment} : ''), 
                  $pd{vendorname}, "","", "");
            @colData2 = ($pd{podate}, $pd{ponumber} . ((defined($pd{amendment})) ? $pd{amendment} : ''), 
                  $pd{vendorname}, "","", "");
            my $apTotal = 0;
            my $apCount = 0;
            my $apNotBilled = 0;
            my $pdTotalAmmount = (($settings{onichargenumber} eq '0') ? $pd{total} : $pd{chargedistAmount});
            #my $pdTotalAmmount = $pd{total};
            for (my $j=0; $j<$#apList; $j++) {
                $apTotal += $apList[$j]{totalAmount} + $apList[$j]{totalTax};
                if (!defined($apList[$j]{clientbilled}) || $apList[$j]{clientbilled} le ' ') {
                    $colData[3] .= (($apCount>0) ? "\n" : "") . "$apList[$j]{invoicenumber}";
                    $colData[4] .= (($apCount>0) ? "\n" : "") . dollarFormat2($apList[$j]{totalAmount} + $apList[$j]{totalTax}) . "     ";
                    $colData[5] .= (($apCount>0) ? "\n" : "") . $taxPaidVals{$apList[$j]{taxpaid}};
                    $apNotBilled += $apList[$j]{totalAmount} + $apList[$j]{totalTax};
                    $apCount++;
                }
            }
            if ($apNotBilled != 0) {
                $colData[3] .= (($apCount > 0) ? "\n\n" : "") . "Invoiced, Not Billed";
                $colData[4] .= (($apCount > 0) ? "\n\n" : "") . dollarFormat2($apNotBilled) . "     ";
                $apCount++;
            }
            $colData[3] .= (($apCount > 0) ? "\n\n" : "") . "Not Invoiced";
            $colData[4] .= (($apCount > 0) ? "\n\n" : "") . dollarFormat2($pdTotalAmmount - $apTotal) . "     ";
            $colData[4] =~ s/\) /\)/g;
            $totalUnbilled += $apNotBilled;
            $total += ($pdTotalAmmount - $apTotal);
            $pdf->tableRow(fontSize => 8, fontID => $fontID, 
                       colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
            $colData[3] =~ s/\n/ \/ /g;
            $colData[4] =~ s/\n/ \/ /g;
            $colData2[3] = dollarFormat2($pdTotalAmmount);
            $colData2[4] = dollarFormat2($apTotal);
            $colData2[5] = dollarFormat2($apNotBilled);
            $colData2[6] = dollarFormat2($pdTotalAmmount - $apTotal);
            $xlsBuff .= formatXLSRow(cols=>$colCount2, row=>\@colData2);
        }
    }

# totals
    #$xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    @colData = ("","","","Total Invoiced, Not Billed",dollarFormat($totalUnbilled) . "     ", " ");
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    @colData = ("","","","Total Not Invoiced",dollarFormat($total) . "     ", " ");
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    @colData = ("","","","Total Not Billed",dollarFormat($total + $totalUnbilled) . "     ", " ");
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


## finish report
    my $repBuff = '';
    if ($args{format} eq 'pdf') {
        $repBuff = $pdf->finish;
    } elsif ($args{format} eq 'xls') {
        $repBuff = $xlsBuff;
    }
########    
    
    if ($args{forDisplay} eq 'T') {
        my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>".$args{format}");
        $output .= "Content-type: $mimeType\n\n";
        #$output .= "Content-disposition: inline; filename=$args{id}.$args{format}\n";
        $output .= "\n";
    }
    $output .= $repBuff;
    

    return($output);
}
    

###################################################################################################################################
sub doPrintTaxReport {  # routine to generate a PDF of Tax report
###################################################################################################################################
    my %args = (
        id => 0,
        forDisplay => 'T',
        site => 0,
        format => 'pdf',
        sortBy => 'ponumber',
        taxType => 'all',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $xlsBuff = '';
    my $output = "";
    my @pdList = getPDByStatus(dbh => $args{dbh}, schema => $args{schema}, siteList=>$args{site},statusList => '15, 16, 17, 18, 19',
          chargeNumber=>$settings{trchargenumber}, poStartDate=>$args{startDate}, poEndDate=>$args{endDate}, cnFromPOCN => 'T', hasTaxOnly=>'T');
    my $sortField = ((defined($args{sortBy})) ? $args{sortBy} : "ponumber");
    @pdList = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @pdList;
    my $formWidth = 770;
    
    my $pdf = new PDF;
    #$pdf->setup(orientation => 'landscape', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5);
    $pdf->setup(orientation => 'portrait', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
        cellPadding => 4);

#######
#print STDERR "Got Here - doPrintTaxReport";

## Headers

    my $colCount = 1;
    my @colWidths = (762);
    my @colAlign = ("center");
    my $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my @colData = ("Tax Report");
    $pdf->addHeaderRow(fontSize => 12, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    my @siteInfo = &getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});
    @colData = ("Site: " . (($args{site} == 0) ? "All" : $siteInfo[$args{site}]{name}) . 
          "\nTax Type: " . (($args{taxType} eq 'all') ? "All" : (($args{taxType} eq 'sales') ? "Sales" : "Use")) . 
          "\nDate Range: " . $args{startDate} . " to " . $args{endDate} . 
          "\nCharge Number: " . (($settings{chargenumber} == '') ? "All" : $settings{chargenumber}));
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


    $colCount = 9;
    @colWidths = (50,65,50,180,65,80,40, 45, 60);
    @colAlign = ("center", "center", "center", "center", "center", "center", "center", "center", "center");
    @colData = ("PO Date", "PO Number", "Ref Number", "Charge Number / Vendor", "PO Amount (B/T)", "Taxable Amount (B/T)", "Type", "Tax", "Total");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


## Footers
# 
    $colCount = 1;
    @colWidths = (762);
    @colAlign = ("center");
    my $reportDate = &getSysdate(dbh=>$args{dbh});
    @colData = ("\n\n\nReport generated on: $reportDate\nPage <page>");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);


    $pdf->newPage(orientation => 'landscape', useGrid => 'F');
    #$pdf->newPage(orientation => 'portrait', useGrid => 'F');

# page contents


# line items
    $colCount = 9;
    @colWidths = (50,65,50,180,65, 80,40, 45, 60);
    @colAlign = ("center", "center", "center", "left", "right", "right", "center", "right", "right");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my $total = 0;
    my $totalTaxable = 0;
    my $totalTax = 0;
    my %taxPaidVals = ('F'=>'Use Tax', 'T'=>'Sales Tax', 'NA'=>'N/A');
    for (my $i=0; $i<=$#pdList; $i++) {
        my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$pdList[$i]{prnumber}, chargeNumber=>$settings{chargenumber});
        my %vendor = &getVendorInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$pd{vendor});
        my $hasTaxID = $vendor{taxpermits}[$pd{site}]{hastaxid};
#print STDERR "PO: $pdList[$i]{ponumber}, $pd{chargedistAmount}, $pd{chargedistInvoiced}\n";
        my @apList = &getAP(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pdList[$i]{prnumber}, chargeNumber=>$settings{chargenumber});
        if ($pd{tax} != 0 && (($args{taxType} eq 'all') || ($args{taxType} eq 'sales' && $hasTaxID eq 'T') || ($args{taxType} eq 'use' && $hasTaxID eq 'F'))) {
            @colData = ($pd{podate}, $pd{ponumber} . ((defined($pd{amendment})) ? $pd{amendment} : ''), 
                  $pd{refnumber}, $pd{chargenumber} . " / \n" . $pd{vendorname}, "","", "");
            my $pdTotalAmmount = (($settings{chargenumber} eq '') ? $pd{total} : $pd{chargedistAmount});
            $colData[4] = dollarFormat2($pd{pdtotal}-$pd{tax});
            $colData[5] = dollarFormat2($pd{totalTaxable});
            $colData[6] = $taxPaidVals{$hasTaxID};
            $colData[7] = dollarFormat2($pd{tax});
            $colData[8] = dollarFormat2($pd{pdtotal});
            $total += $pd{pdtotal};
            $totalTaxable += $pd{totalTaxable};
            $totalTax += $pd{tax};
            $pdf->tableRow(fontSize => 8, fontID => $fontID, 
                       colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
            $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
        }
    }

# totals
    @colAlign = ("center", "center", "center", "right", "right", "right", "center", "right", "right");
    @colData = ("","",""," ", " ", " ", " ", " ");
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    @colData = ("","","","Totals:", dollarFormat2($total-$totalTax), dollarFormat2($totalTaxable), " ", dollarFormat2($totalTax), dollarFormat2($total));
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


## finish report
    my $repBuff = '';
    if ($args{format} eq 'pdf') {
        $repBuff = $pdf->finish;
    } elsif ($args{format} eq 'xls') {
        $repBuff = $xlsBuff;
    }
########    
    
    if ($args{forDisplay} eq 'T') {
        my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>".$args{format}");
        $output .= "Content-type: $mimeType\n\n";
        #$output .= "Content-disposition: inline; filename=$args{id}.$args{format}\n";
        $output .= "\n";
    }
    $output .= $repBuff;
    

    return($output);
}
    

###################################################################################################################################
sub doPrintInvoiceLog {  # routine to generate a PDF of Invoice Log report (now called PO Log)
###################################################################################################################################
    my %args = (
        id => 0,
        forDisplay => 'T',
        site => 0,
        format => 'pdf',
        sortBy => 'povendor',
        startingPO => '',
        @_,
    );
    #my $hashRef = $args{settings};
    #my %settings = %$hashRef;
    my $xlsBuff = '';
    my $output = "";
    my @pdList;
    #@pdList = getPDByStatus(dbh => $args{dbh}, schema => $args{schema}, siteList=>$args{site},statusList => '13, 14, 15, 16, 17, 18, 19, 20',
    #      hStartDate=>$args{startDate}, hEndDate=>$args{endDate}, getVendor=>'T', isHistory=>'T');
    if ($args{startingPO} gt "   ") {
        $args{startingPO} = uc ($args{startingPO});
        @pdList = getPDByStatus(dbh => $args{dbh}, schema => $args{schema}, siteList=>$args{site},statusList => '13, 14, 15, 16, 17, 18, 19, 20',
              startingPO=>$args{startingPO}, getVendor=>'T', isHistory=>'F');
    } else {
        @pdList = getPDByStatus(dbh => $args{dbh}, schema => $args{schema}, siteList=>$args{site},statusList => '13, 14, 15, 16, 17, 18, 19, 20',
              poStartDate=>$args{startDate}, poEndDate=>$args{endDate}, getVendor=>'T', isHistory=>'F');
    }
    my $sortField = ((defined($args{sortBy})) ? $args{sortBy} : "ponumber");
    @pdList = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @pdList;
    my $formWidth = 770;
    
    my $pdf = new PDF;
    $pdf->setup(orientation => 'landscape', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
        cellPadding => 1);
    #$pdf->setup(orientation => 'portrait', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5);

#######

## Headers

    my $colCount = 1;
    my @colWidths = (762);
    my @colAlign = ("center");
    my $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my @colData = ("Purchase Order Log");
    $pdf->addHeaderRow(fontSize => 12, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    my @siteInfo = &getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});
    @colData = ("Site: " . (($args{site} == 0) ? "All" : $siteInfo[$args{site}]{name}) . 
        (($args{startingPO} gt "   ") ? "\nStarting With PO # $args{startingPO}" : "\nFrom: $args{startDate}  To: $args{endDate}") );
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


    $colCount = 15;
    @colWidths = (50, 90, 90, 60, 50, 10, 45, 35, 60, 35, 45, 35, 30, 45, 35);
    @colAlign = ("center", "center", "center", "center", "center", "center", "center", "center", "center", "center", "center", "center", "center", "center", "center");
    @colData = ("PONumber", "Vendor", "Description","Requester","Charge #", "EC", "PO \$", "Commit", "Invoice #", "Inv Date", "Inv Amount", "Paid Date", "Tax Type", "Tax", "$SYSClient Billed");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 6, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


## Footers
# 
    $colCount = 1;
    @colWidths = (762);
    @colAlign = ("center");
    my $reportDate = &getSysdate(dbh=>$args{dbh});
    @colData = ("\n\n\nReport generated on: $reportDate\nPage <page>");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addFooterRow(fontSize => 6, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);


    $pdf->newPage(orientation => 'landscape', useGrid => 'F');
    #$pdf->newPage(orientation => 'portrait', useGrid => 'F');

# page contents


# line items
    $colCount = 15;
    @colWidths = (50, 90, 90, 60, 50, 10, 45, 35, 60, 35, 45, 35, 30, 45, 35);
    @colAlign = ("center", "left", "left", "center", "center", "center", "right", "center", "center", "center", "right", "center", "center", "right", "center");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    my $totalPO = 0;
    my $totalInv = 0;
    my $totalUseTax = 0;
    my $totalSalesTax = 0;
    my $totalTax = 0;
    my %taxPaidVals = ('F'=>'Use Tax', 'T'=>'Sales Tax', 'NA'=>'N/A');
    my $lastPR = "###";
    for (my $i=1; $i<=$#pdList; $i++) {
        my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$pdList[$i]{prnumber});
        #my @apList = &getAP(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pdList[$i]{prnumber}, orderBy=>'i.invoicedate');
        my @apList = &getAP(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pdList[$i]{prnumber}, orderBy=>'i.datereceived');
        if ($#apList > 0 && $lastPR ne $pd{prnumber}) {
            my $apTotal = 0;
            my $apCount = 0;
            my $apNotBilled = 0;
            $lastPR = $pd{prnumber};
            my $lastEC = "";
            my $lastCN = "";
            my %testChargeList;
            for (my $j=0; $j<$pd{chargedistlistCount}; $j++) {
                $testChargeList{$pd{chargedistlist}[$j]{chargenumber} . " - " . $pd{chargedistlist}[$j]{ec}} = 'F';
            }
            my $apTax = 0;
            for (my $j=0; $j<$#apList; $j++) {
                for (my $k=0; $k<$apList[$j]{itemCount}; $k++) {
                    @colData = (
                        $pd{ponumber} . ((defined($pd{amendment})) ? $pd{amendment} : ''), $pd{vendorname}, $pd{briefdescription}, 
                        &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$pd{requester}), $apList[$j]{items}[$k]{chargenumber},
#                        $apList[$j]{items}[$k]{ec}, (($apCount == 0) ? dollarFormat2($pd{total}) : " "), 
                        $apList[$j]{items}[$k]{ec}, 
#                        (($lastEC ne $apList[$j]{items}[$k]{ec}) ? dollarFormat2($pd{ecTotals}{$apList[$j]{items}[$k]{ec}}) : " "), 
                        (($lastEC ne $apList[$j]{items}[$k]{ec} || $lastCN ne $apList[$j]{items}[$k]{chargenumber}) ? 
                            dollarFormat2($pd{chargedisthash}{"$apList[$j]{items}[$k]{chargenumber} - $apList[$j]{items}[$k]{ec}"}{amount}) : " "), 
                        $pd{podate}, $apList[$j]{invoicenumber}, 
                        $apList[$j]{invoicedate}, dollarFormat2($apList[$j]{items}[$k]{tax} + $apList[$j]{items}[$k]{amount}),
                        ((defined($apList[$j]{datepaid})) ? $apList[$j]{datepaid} : " "), $taxPaidVals{$apList[$j]{taxpaid}},
                        dollarFormat2($apList[$j]{items}[$k]{tax}), ((defined($apList[$j]{clientbilled})) ? $apList[$j]{clientbilled} : " ")
                    );
                    $pdf->tableRow(fontSize => 6, fontID => $fontID, 
                               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01,
                               rowColor => (($pd{status} >= 19) ? 0.8 : 1.0));
                    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
                    $totalInv += $apList[$j]{items}[$k]{tax} + $apList[$j]{items}[$k]{amount};
                    $totalTax += $apList[$j]{items}[$k]{tax};
                    $totalUseTax += (($apList[$j]{taxpaid} eq 'F') ? $apList[$j]{items}[$k]{tax} : 0.0);
                    $totalSalesTax += (($apList[$j]{taxpaid} eq 'T') ? $apList[$j]{items}[$k]{tax} : 0.0);
                    $apCount++;
                    $lastEC = $apList[$j]{items}[$k]{ec};
                    $lastCN = $apList[$j]{items}[$k]{chargenumber};
                    $apTax += $apList[$j]{items}[$k]{tax};
                    
                    $testChargeList{$lastCN . " - " . $lastEC} = 'T';
                }
            }
            my $testCNEC = 'F';
            for (my $j=0; $j<$pd{chargedistlistCount}; $j++) {
                if ($testChargeList{$pd{chargedistlist}[$j]{chargenumber} . " - " . $pd{chargedistlist}[$j]{ec}} eq 'F') {
                    $testCNEC = 'T';
                }
            }
            if ($testCNEC eq 'T') {
                my $remainingTax = (($apTax <= $pd{tax}) ? ($pd{tax} - $apTax) : 0);
                $totalTax += $remainingTax;
                my $chargeCount = 0;
                for (my $j=0; $j<$pd{chargedistlistCount}; $j++) {
                    if ($testChargeList{$pd{chargedistlist}[$j]{chargenumber} . " - " . $pd{chargedistlist}[$j]{ec}} eq 'F') {
                        @colData = (
                            $pd{ponumber} . ((defined($pd{amendment})) ? $pd{amendment} : ''), $pd{vendorname}, $pd{briefdescription}, 
                            &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$pd{requester}), $pd{chargedistlist}[$j]{chargenumber},
                            $pd{chargedistlist}[$j]{ec}, dollarFormat2($pd{chargedistlist}[$j]{amount}), 
                            ((defined($pd{podate})) ? $pd{podate} : " "), " ", 
                            " ", " ", " ", " ",
                            (($chargeCount == 0) ? dollarFormat2($remainingTax) : " "), " "
                        );
                        $pdf->tableRow(fontSize => 6, fontID => $fontID, 
                                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01,
                                   rowColor => (($pd{status} >= 19) ? 0.8 : 1.0));
                        $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
                        $chargeCount++;
                    }
                }
            }
        } else {
            my $chargeCount = 0;
            for (my $j=0; $j<$pd{chargedistlistCount}; $j++) {
                @colData = (
                    $pd{ponumber} . ((defined($pd{amendment})) ? $pd{amendment} : ''), $pd{vendorname}, $pd{briefdescription}, 
                    &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$pd{requester}), $pd{chargedistlist}[$j]{chargenumber},
                    #$pd{chargedistlist}[$j]{ec}, (($chargeCount == 0) ? dollarFormat2($pd{ecTotals}{$pd{chargedistlist}[$j]{ec}}) : " "), 
                    #$pd{chargedistlist}[$j]{ec}, dollarFormat2($pd{ecTotals}{$pd{chargedistlist}[$j]{ec}}), 
                    $pd{chargedistlist}[$j]{ec}, dollarFormat2($pd{chargedistlist}[$j]{amount}), 
                    ((defined($pd{podate})) ? $pd{podate} : " "), " ", 
                    " ", " ", " ", " ",
                    (($chargeCount == 0) ? dollarFormat2($pd{tax}) : " "), " "
                );
                $pdf->tableRow(fontSize => 6, fontID => $fontID, 
                           colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01,
                           rowColor => (($pd{status} >= 19) ? 0.8 : 1.0));
                $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
                $chargeCount++;
            }
            $totalTax += $pd{tax};
        }
        $totalPO += $pd{total};
    }

# totals
    @colData = (" ","Totals"," "," "," "," ",dollarFormat2($totalPO), " "," "," ",dollarFormat2($totalInv)," "," ",dollarFormat2($totalTax));
    $pdf->tableRow(fontSize => 6, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.00);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    @colData = (" "," "," "," "," "," "," ", " "," "," "," "," ",$taxPaidVals{'F'},dollarFormat2($totalUseTax));
    $pdf->tableRow(fontSize => 6, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.00);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    @colData = (" "," "," "," "," "," "," ", " "," "," "," "," ",$taxPaidVals{'T'},dollarFormat2($totalSalesTax));
    $pdf->tableRow(fontSize => 6, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.00);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


## finish report
    my $repBuff = '';
    if ($args{format} eq 'pdf') {
        $repBuff = $pdf->finish;
    } elsif ($args{format} eq 'xls') {
        $repBuff = $xlsBuff;
    }
########    
    
    if ($args{forDisplay} eq 'T') {
        my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>".$args{format}");
        $output .= "Content-type: $mimeType\n\n";
        #$output .= "Content-disposition: inline; filename=$args{id}.$args{format}\n";
        $output .= "\n";
    }
    $output .= $repBuff;
    

    return($output);
}
    

###################################################################################################################################
sub doPrintCommitted {  # routine to generate a PDF of Committed report
###################################################################################################################################
    my %args = (
        id => 0,
        forDisplay => 'T',
        site => 0,
        format => 'pdf',
        sortBy => 'ponumber',
        @_,
    );
    #my $hashRef = $args{settings};
    #my %settings = %$hashRef;
    my $xlsBuff = '';
    my $output = "";
    my @cnList = getCNCommittedList(dbh => $args{dbh}, schema => $args{schema}, siteList=>$args{site},
          startDate=>$args{startDate}, endDate=>$args{endDate});
    my $formWidth = 770;
    my $fontSize = 8;
    
    my $pdf = new PDF;
    $pdf->setup(orientation => 'landscape', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
        cellPadding => 2);

#######

## Headers

    my $colCount = 1;
    my @colWidths = (762);
    my @colAlign = ("center");
    my $fontID = $pdf->setFont(font => "helvetica-bold", fontSize => 10.0);
    my @colData = ("Committed Report");
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    my @siteInfo = &getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});
    @colData = ("Site: " . (($args{site} == 0) ? "All" : $siteInfo[$args{site}]{name}) . "\nFrom: $args{startDate}, To: $args{endDate}" );
    #$colData[0] .= "\nTesting\nTesting";
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


    $colCount = 9;
    @colWidths = (80, 100, 110, 70, 80, 50, 60, 100, 70);
    @colAlign = ("center", "center", "center", "center", "center", "center", "center", "center", "center");
    @colData = ("PONumber", "Vendor", "Description","Requester", "Department", "POType", "Approved", "Charge # EC", "PO \$");
    $fontID = $pdf->setFont(font => "helvetica-bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => $fontSize, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


## Footers
# 
    $colCount = 1;
    @colWidths = (762);
    @colAlign = ("center");
    my $reportDate = &getSysdate(dbh=>$args{dbh});
    @colData = ("\n\n\nReport generated on: $reportDate\nPage <page>");
    $fontID = $pdf->setFont(font => "helvetica-bold", fontSize => 10.0);
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);


    $pdf->newPage(orientation => 'landscape', useGrid => 'F', cellPadding => 2);

# page contents


# line items
    $colCount = 9;
    @colWidths = (80, 100, 110, 70, 80, 50, 60, 100, 70);
    @colAlign = ("center", "left", "left", "center", "center", "center", "center", "center", "right");
    $fontID = $pdf->setFont(font => "helvetica", fontSize => 10.0);
    my $grandTotal = 0;
    my @poTypeList = ('', 'Normal', 'Blanket', 'PO Maintenance/Partial Maintenance', 'Delivery');
    my $lastCN = "##";
    my $cnTotal = 0;
    for (my $i=0; $i<$#cnList; $i++) {
        if ($lastCN ne '##' && $lastCN ne $cnList[$i]{chargenumber}) {
            @colData = ("","Charge Number Total","","","","","","$lastCN",dollarFormat($cnTotal));
            $pdf->tableRow(fontSize => $fontSize, fontID => $fontID,
                       colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.00);
            $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
            $pdf->newPage(orientation => 'landscape', useGrid => 'F', cellPadding => 2);
            $fontID = $pdf->setFont(font => "helvetica", fontSize => 10.0);
            $lastCN = $cnList[$i]{chargenumber};
            $cnTotal = 0;
        } elsif ($lastCN eq '##') {
            $lastCN = $cnList[$i]{chargenumber};
        }
        @colData = (
            $cnList[$i]{ponumber} . ((defined($cnList[$i]{amendment})) ? $cnList[$i]{amendment} : ''), $cnList[$i]{vendorName}, 
            $cnList[$i]{briefdescription}, &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$cnList[$i]{requester}), $cnList[$i]{deptname},
            $poTypeList[$cnList[$i]{potype}], $cnList[$i]{podate}, $cnList[$i]{chargenumber} . ' ' . $cnList[$i]{ec}, 
            dollarFormat($cnList[$i]{changeamount})
        );
        $pdf->tableRow(fontSize => $fontSize, fontID => $fontID, 
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
        $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
        $grandTotal += $cnList[$i]{changeamount};
        $cnTotal += $cnList[$i]{changeamount};
    }

# totals
    @colData = ("","Charge Number Total","","","","","","$lastCN",dollarFormat($cnTotal));
    $pdf->tableRow(fontSize => $fontSize, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.00);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    @colData = ("","Total","","","","","","",dollarFormat($grandTotal));
    $pdf->tableRow(fontSize => $fontSize, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.00);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);


## finish report
    my $repBuff = '';
    if ($args{format} eq 'pdf') {
        $repBuff = $pdf->finish;
    } elsif ($args{format} eq 'xls') {
        $repBuff = $xlsBuff;
    }
########    
    
    if ($args{forDisplay} eq 'T') {
        my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>".$args{format}");
        $output .= "Content-type: $mimeType\n\n";
        #$output .= "Content-disposition: inline; filename=$args{id}.$args{format}\n";
        $output .= "\n";
    }
    $output .= $repBuff;
    

    return($output);
}
    

###################################################################################################################################
sub formatXLSRow {  # routine to generate a row for spreed sheet output
###################################################################################################################################
    my %args = (
        cols => 0,
        row => "",
        @_,
    );
    
    my $output = '';
    for (my $i=0; $i<$args{cols}; $i++) {
        $args{row}[$i] = ((defined($args{row}[$i])) ? $args{row}[$i] : "");
        $args{row}[$i] =~ s/\n//g;
        $output .= "$args{row}[$i]" . (($i<($args{cols}-1)) ? "\t" : "\n");
#print STDERR "$args{row}[$i], ";
    }
#print STDERR "\n\n";
    return($output);
}


###################################################################################################################################
sub doAssignBuyerForm {  # Form for reasigning a buyer for a PO
###################################################################################################################################
    my %args = (
        PD => '',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id => $args{PD});
    my @buyers = getUserArray(dbh => $args{dbh}, schema => $args{schema}, role => 7, site => $pd{site});

    $output .= "<input type=hidden name=prnumber value='$args{PD}'>\n";
    $output .= "<input type=hidden name=oldbuyer value='$pd{buyer}'>\n";
    $output .= "<table align=center cellpadding=1 cellspacing=0 border=0>\n";
    $output .= "<tr><td><b>PR / PO:</b></td><td>$pd{prnumber}" . 
          ((defined($pd{ponumber})) ? " / $pd{ponumber}" . ((defined($pd{amendment})) ? $pd{amendment} : "") : "") . "</td></tr>\n";
    $output .= "<tr><td><b>Description:</b></td><td>$pd{briefdescription}</td></tr>\n";
    $output .= "<tr><td><b>Current Buyer:</b> &nbsp; </td><td>" . 
        &getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $pd{buyer}) . "</td></tr>\n";
    $output .= "<tr><td><b>New Buyer:</b></td><td><select name=buyer size=1>\n";
    for (my $i=0; $i<$#buyers; $i++) {
        $output .= "<option value=$buyers[$i]{id}" . (($buyers[$i]{id}==$pd{buyer}) ? " selected" : "") . ">" . 
            &getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $buyers[$i]{id}) . "</option>\n";
    }
    $output .= "</select></td></tr>\n";
    $output .= "<tr><td valign=top><b>Justification:</b></td><td><textarea name=remarks cols=70 rows=4>$settings{remarks}</textarea></td></tr>\n";
    $output .= "<tr><td colspan=2 align=center><input type=button name=submit1 value=Submit onClick=\"verifyForm(document.$args{form})\"></td></tr>\n";
    $output .= "</table>\n";
    
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifyForm (f) {
    var msg = "";
    if (isblank(f.remarks.value)) {
        msg += "Justification must be entered.\\n";
    }
    if (msg != "") {
        alert (msg);
    } else {
        submitFormCGIResults('$args{form}', 'doassignbuyer');
    }
}

//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doAssignBuyer {  # routine to reasign a buyer
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my $status = &doProcessAssignBuyer(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID},
        pd=>$settings{prnumber}, buyer=>$settings{buyer});

    $message = "PD '$settings{prnumber}' has had ". 
        &getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{oldbuyer}) . " replaced with " . 
        &getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{buyer}) . " as buyer.";
    $output .= doAlertBox(text => "$message");
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 21);
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('home','home');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doPOPendingToRFP {  # routine to return a PO from pending to RFP
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    #$settings{id}=$settings{prnumber};
    my $status = &doUpdatePDStatus(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, status=> 7, 
              remarks => "Move pending PO back to RFP - \n" . $settings{remarks}, settings => \%settings);
    $status = &doRemovePOChargeNumbers(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID},
        pd=>$settings{id});

    $message = "PD '$settings{id}' has been returned to RFP from PO Pending ";
    $output .= doAlertBox(text => "$message");
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 21);
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('home','home');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doPOAPOpenToRec {  # routine to return a PO from Accounts Payable Open to Receiving
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    #$settings{id}=$settings{prnumber};
    my $status = &doUpdatePDStatus(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, status=> 17, 
              remarks => "Move pending PO back to RFP - \n" . $settings{remarks}, settings => \%settings);

    $message = "PD '$settings{id}' has been returned to Receiving From Accounts Payable Open";
    $output .= doAlertBox(text => "$message");
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 21);
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('home','home');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doSendApprovalNotification {  # routine to send an e-mail notification to the next approver
###################################################################################################################################
    my %args = (
        pd => '',
        pdf => '',
        @_,
    );
    #my $hashRef = $args{settings};
    #my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    my $subject = "";
    my $sender = "intranetwebmaster\@ymp.gov";
    my $sendTo = "";
    my $status;
    
    my %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id => $args{pd});
    my @list = &getApprovalList(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, pd=>$args{pd});
    if (defined($list[0]{userid}) && $list[0]{userid} > 0) {
        my %primary = &getUserInfo(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, ID => $list[0]{userid});
        my $delegateID = &getCurrentDelegate(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, userID => $list[0]{userid},
              role => $list[0]{role}, site => $pd{site});
        my %delegate;
        if ($delegateID > 0) {
            %delegate = &getUserInfo(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, ID => $delegateID);
        }
    
        my $pdName = $pd{prnumber} . ((defined($pd{ponumber})) ? " / $pd{ponumber}" . ((defined($pd{amendment})) ? $pd{amendment} : "") : "");
        my $pdName2 = $pd{prnumber} . ((defined($pd{ponumber})) ? "-$pd{ponumber}" . ((defined($pd{amendment})) ? $pd{amendment} : "") : "");
    
        $sendTo = $primary{email};
        $subject = "Pending approval on Purchase Document $pdName" . (($SYSProductionStatus) ? "" : " THIS IS ONLY A TEST!");
        $message .= "The Materials Management System has a pending approval that requires your (or your delegate's) action\n";
        $message .= "Purchase Document: $pdName\n";
        $message .= "Description: $pd{briefdescription}\n";
        $message .= "Primary Approver: $primary{lastname}, $primary{firstname}\n";
        $message .= "Delegated Approver: ";
        if ($delegateID > 0) {
            $message .= "$delegate{lastname}, $delegate{firstname}\n";
            $sendTo .= ", $delegate{email}";
        } else {
            $message .= "No delegation currently assigned\n";
        }
        $message .= "Link to MMS: https://$ENV{'HTTP_HOST'}$CGIDIR/login.pl\n";
        $message .= $emailHelpText;

        $status = &SendMailMessage(sendTo => $sendTo, sender => $sender, subject => $subject, message => $message, attachmentCount => 1, 
                attachmentFileName1 => "$pdName2.pdf", attachmentContents1 => $args{pdf});
    }
    
    return(1);
}


###################################################################################################################################
sub doSendPRDisapprovalNotification {  # routine to send an e-mail notification to the requestor/author of PR disapproval
###################################################################################################################################
    my %args = (
        pd => '',
        @_,
    );
    #my $hashRef = $args{settings};
    #my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    my $subject = "";
    my $sender = "intranetwebmaster\@ymp.gov";
    my $sendTo = "";
    my $status;
    
    my %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id => $args{pd});
    my %author = &getUserInfo(dbh => $args{dbh}, schema => $args{schema}, ID => $pd{author});
    my %requestor = &getUserInfo(dbh => $args{dbh}, schema => $args{schema}, ID => $pd{requester});
    $sendTo = $author{email} . (($pd{author} != $pd{requestor}) ? ", $requestor{email}" : "");
    $subject = "Purchase Request $pd{prnumber} was disapproved"  . (($SYSProductionStatus) ? "" : " THIS IS ONLY A TEST!");
    $message .= "The following Purchase Request in the Materials Management System has been disapproved:\n";
    $message .= "Purchase Request: $pd{prnumber}\n";
    $message .= "Description: $pd{briefdescription}\n";
    $message .= "Disapproval Remarks: \n    $pd{remarks}[0]{text}\n";
    $message .= "\n   ---   ---\n";
    $message .= "Link to MMS: https://$ENV{'HTTP_HOST'}$CGIDIR/login.pl\n";
    $message .= $emailHelpText;

    $status = &SendMailMessage(sendTo => $sendTo, sender => $sender, subject => $subject, message => $message);
    
    return(1);
}


###################################################################################################################################
sub doSavePDRemark {  # routine to save a remark for a Purchase Document
###################################################################################################################################
    my %args = (
        type => 'new',
        refresh => 'T',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my $status = &doProcessSavePDRemark(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, settings => \%settings);
    my %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id => "$settings{id}");

    $message = "Remark added to PD '$settings{id}" . ((defined($pd{ponumber})) ? " / $pd{ponumber}" : "") . "'.";
    $output .= doAlertBox(text => "$message");
    if ($args{refresh} eq 'T') {
        $output .= "<script language=javascript><!--\n";
        $output .= "   submitForm('home','home');\n";
        $output .= "//--></script>\n";
    }

    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
