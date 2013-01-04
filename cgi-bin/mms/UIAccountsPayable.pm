# UI Accounts Payable
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UIAccountsPayable.pm,v $
#
# $Revision: 1.16 $
#
# $Date: 2009/08/14 15:08:21 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIAccountsPayable.pm,v $
# Revision 1.16  2009/08/14 15:08:21  atchleyb
# ACR0908_003 - Report chargenumber selection fix, missing quotes around chargenumber on accounts payable form
#
# Revision 1.15  2008/12/04 21:23:34  atchleyb
# ACR0812_003 - Fix form validation for entering invoice credits
#
# Revision 1.14  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.13  2006/05/17 23:04:33  atchleyb
# CR 0026 - added options to invoice entry to save and enter a new invoice
# CR 0026 - added options to APFinalize to save and select the next invoice to update
# CR 0026 - changed doebilled to clientbilled
#
# Revision 1.12  2006/03/23 18:39:08  atchleyb
# CR 0023 - Altered so that past comments are no longer editable and new comments are prepended with user name, date, and time
#
# Revision 1.11  2005/08/30 21:45:26  atchleyb
# CR0017 Updated dollar form field lengths to 12
#
# Revision 1.10  2005/08/19 20:58:12  atchleyb
# CR00015 - Added display of S/H and Tax on invoice entry & approval
#
# Revision 1.9  2005/06/15 15:36:21  atchleyb
# removed change from CR 11 that made the tax paid field display only
#
# Revision 1.8  2005/06/10 22:35:50  atchleyb
# CR0011
# updated to make taxpaid readonly
#
# Revision 1.7  2005/03/30 23:31:45  atchleyb
# updated to get arround a javascript rounding bug by adding a $0.05 buffer for the max invoice amount/tax to be entered.
# fixed log message for closing po's
#
# Revision 1.6  2005/02/10 00:51:56  atchleyb
# updated for CR004, added readonly list of past invoices on invoice entry screen
#
# Revision 1.5  2004/12/07 18:40:52  atchleyb
# updated formatting
#
# Revision 1.4  2004/05/05 23:21:39  atchleyb
# updated display labels and added status sort
#
# Revision 1.3  2004/04/02 00:01:06  atchleyb
# changed name of charge distribution list hash
#
# Revision 1.2  2004/03/01 17:31:11  atchleyb
# updated to added sort and selection options
#
# Revision 1.1  2004/01/08 17:32:57  atchleyb
# Initial revision
#
#
#
#
#
#

package UIAccountsPayable;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBAccountsPayable qw(:Functions);
use DBPurchaseDocuments qw(getPDInfo);
use DBBusinessRules qw (getRuleInfo);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Sessions qw(:Functions);
use Tie::IxHash;
use Tables;
use PDF;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw (@apStatus);
#use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getInitialValues       &doHeader             
      &doFooter               &getTitle             &doBrowse
      &doAPForm               &doAPSave             &doClosePO
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             
      &doFooter               &getTitle             &doBrowse
      &doAPForm               &doAPSave             &doClosePO
    )]
);

@apStatus = ("", "Initial", "Approval Pending", "Approved", "Closed");

my $mycgi = new CGI;


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "";
   if (($args{command} eq "apform") || ($args{command} eq "printissuedoc") 
            || ($args{command} eq "saveprintissuedoc")) {
      $title = "Accounts Payable";
   } elsif (($args{command} eq "browse") || ($args{command} eq "browseap")) {
      $title = "Browse Accounts Payable";
   } elsif (($args{command} eq "apentry") || ($args{command} eq "saveap")
            || ($args{command} eq "updateapform") || ($args{command} eq "newap")) {
      $title = "Accounts Payable Entry";
   } elsif (($args{command} eq "approveapform")) {
      $title = "Accounts Payable Approval";
   } elsif (($args{command} eq "finalizeapform")) {
      $title = "Accounts Payable Completion";
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
       prnumber => (defined($mycgi->param("prnumber"))) ? $mycgi->param("prnumber") : "0",
       apid => (defined($mycgi->param("apid"))) ? $mycgi->param("apid") : "0",
       status => (defined($mycgi->param("status"))) ? $mycgi->param("status") : "0",
       entrystatus => (defined($mycgi->param("entrystatus"))) ? $mycgi->param("entrystatus") : "0",
       invoicenumber => (defined($mycgi->param("invoicenumber"))) ? $mycgi->param("invoicenumber") : "0",
       datereceived => (defined($mycgi->param("datereceived"))) ? $mycgi->param("datereceived") : "",
       invoicedate => (defined($mycgi->param("invoicedate"))) ? $mycgi->param("invoicedate") : "",
       taxpaid => (defined($mycgi->param("taxpaid"))) ? $mycgi->param("taxpaid") : "",
       clientbilled => (defined($mycgi->param("clientbilled"))) ? $mycgi->param("clientbilled") : "",
       comments => (defined($mycgi->param("comments"))) ? $mycgi->param("comments") : "",
       oldcomments => (defined($mycgi->param("oldcomments"))) ? $mycgi->param("oldcomments") : "",
       enteredby => (defined($mycgi->param("enteredby"))) ? $mycgi->param("enteredby") : "",
       approvedby => (defined($mycgi->param("approvedby"))) ? $mycgi->param("approvedby") : "",
       approveddate => (defined($mycgi->param("approveddate"))) ? $mycgi->param("approveddate") : "",
       datepaid => (defined($mycgi->param("datepaid"))) ? $mycgi->param("datepaid") : "",
       clientbilled => (defined($mycgi->param("clientbilled"))) ? $mycgi->param("clientbilled") : "",
       itemcount => (defined($mycgi->param("itemcount"))) ? $mycgi->param("itemcount") : "0",
       sortby => (defined($mycgi->param("sortby"))) ? $mycgi->param("sortby") : "",
       viewfy => (defined($mycgi->param("viewfy"))) ? $mycgi->param("viewfy") : &getFY,
       viewstatus => (defined($mycgi->param("viewstatus"))) ? $mycgi->param("viewstatus") : '0',
       sitecode => (defined($mycgi->param("sitecode"))) ? $mycgi->param("sitecode") : 'xx',
    ));

    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    for (my $i=0; $i<=$valueHash{itemcount}; $i++) {
        $valueHash{items}[$i]{"chargenumber"} = (defined($mycgi->param("chargenumber$i"))) ? $mycgi->param("chargenumber$i") : 0;
        $valueHash{items}[$i]{"ec"} = (defined($mycgi->param("ec$i"))) ? $mycgi->param("ec$i") : "";
        $valueHash{items}[$i]{"tax"} = (defined($mycgi->param("tax$i"))) ? $mycgi->param("tax$i") : 0;
        $valueHash{items}[$i]{"amount"} = (defined($mycgi->param("amount$i"))) ? $mycgi->param("amount$i") : "";
    }
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => $ENV{SCHEMA},
        title => "$SYSType Receiving Functions",
        displayTitle => 'T',
        includeJSUtilities => 'T',
        includeJSWidgets => 'F',
        includeJSCalendar => 'F',
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
              includeJSCalendar => $args{includeJSCalendar},
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS,includeJSUtilities => $args{includeJSUtilities}, 
              includeJSWidgets => $args{includeJSWidgets});
    
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
sub doBrowse {  # routine to generate a table of AP for browse
###################################################################################################################################
    my %args = (
        sortBy => 'id',
        statusList => '0',
        siteCode => 'xx',
        @_,
    );
    my $output = "";
    my $fy = &getFY;
    my @ap = getAP(dbh => $args{dbh}, schema => $args{schema}, orderBy=>'id', fy=> $args{fy}, noItems=>'T', statusList=>$args{statusList},
          siteList=> [$args{siteCode}]);

    $output .= "<input type=hidden name=sortby value='id'>\n";
    $output .= "<table align=center border=0><tr>";
    $output .= "<td>Display Fiscal Year <select name=viewfy size=1>\n";
    for (my $i=1999; $i<=$fy; $i++) {
        $output .= "<option value=$i" . (($i == $args{fy}) ? " selected" : "") . ">$i</option>\n";
    }
    $output .= "</select></td>";
    $output .= "<td> &nbsp; Status <select name=viewstatus size=1>\n";
    my @statusArray;
    $statusArray[0][0] = ('1, 2, 3');
    $statusArray[0][1] = ('Open');
    $statusArray[1][0] = ('1');
    $statusArray[1][1] = ('Initial');
    $statusArray[2][0] = ('2');
    $statusArray[2][1] = ('Approval');
    $statusArray[3][0] = ('3');
    $statusArray[3][1] = ('Approved');
    $statusArray[4][0] = ('4');
    $statusArray[4][1] = ('Closed');
    $output .= "<option value='0'>All</option>\n";
    for (my $i=0; $i<=$#statusArray; $i++) {
        $output .= "<option value='$statusArray[$i][0]'" . (($statusArray[$i][0] eq $args{statusList}) ? " selected" : "") . ">$statusArray[$i][1]</option>\n";
    }
    $output .= "</select></td>\n";
    $output .= "<td> &nbsp; Site <select name=sitecode size=1><option value='xx'>All</option>\n";
    my @siteList = &getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});
    my %tempSite;
    for (my $i=1; $i<=$#siteList; $i++) {
        $tempSite{$siteList[$i]{sitecode}} = $siteList[$i]{sitecode};
    }
    foreach my $key (sort keys %tempSite) {
        $output .= "<option value=$key" . (($key eq $args{siteCode}) ? " selected" : "") . ">$key</option>\n";
    }
    $output .= "</select></td>";
    $output .= "<td> &nbsp; <input type=button name=refresh value='Refresh' onClick=submitForm('$args{form}','browse')></td>\n";
    $output .= "</tr></table>\n";
    $output .= "<table align=center cellpadding=1 cellspacing=0 border=1>\n";
    $output .= "<tr bgcolor=#a0e0c0><td><b><a href=\"javascript:reSort('id');\">AP ID</a></b></td>";
    $output .= "<td><b><a href=\"javascript:reSort('prnumber');\">PR Number</a></b></td>";
    $output .= "<td><b><a href=\"javascript:reSort('ponumber');\">PO Number</a></b></td>";
    $output .= "<td><b><a href=\"javascript:reSort('datereceived');\">Date Received</a></b></td>";
    $output .= "<td><b><a href=\"javascript:reSort('invoicedate');\">Invoice Date</a></b></td>";
    $output .= "<td><b><a href=\"javascript:reSort('vendor');\">Vendor</a></b></td>";
    $output .= "<td><b><a href=\"javascript:reSort('status');\">Status</a></b></td></tr>\n";
    my $sortField = ((defined($args{sortBy}) && $args{sortBy} gt ' ') ? $args{sortBy} : "id");
    @ap = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @ap;
    for (my $i=1; $i<=$#ap; $i++) {
        #my %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$ap[$i]{prnumber});
        $output .= "<tr bgcolor=#ffffff><td><a href=\"javascript:browseAP('$ap[$i]{id}');\">$ap[$i]{id}</a></td>";
        $output .= "<td>$ap[$i]{prnumber}</a></td>";
        #$output .= "<td>$pd{ponumber}</td>";
        $output .= "<td>$ap[$i]{ponumber}</td>";
        $output .= "<td>$ap[$i]{datereceived}</td>";
        $output .= "<td>$ap[$i]{invoicedate}</td>";
        #$output .= "<td>$pd{vendorname}</td>";
        $output .= "<td>$ap[$i]{vendor}</td>";
        $output .= "<td>$apStatus[$ap[$i]{status}]</td>";
        $output .= "</tr>\n";
    }
    $output .= "</table>\n";
    
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function browseAP (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'browseap');
}

function reSort (by) {
    $args{form}.sortby.value=by;
    submitForm('$args{form}', 'browse');
}

//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doAPForm {  # routine to generate a form for AP
###################################################################################################################################
    my %args = (
        id => 0,
        userID => 0,
        browseOnly => 'F',
        command => "",
        site => 0,
        @_,
    );
    my $output = "";
    my $form = $args{form};
    my %pd;
    my %ap;
    if ($args{command} eq "updateapform" || $args{command} eq "browseap" || $args{command} eq "approveapform"
             || $args{command} eq "finalizeapform") {
        %ap = &getAPInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id});
    } elsif ($args{command} eq "newap") {
        %ap = &genNewAP(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, pd=>$args{id});
    }
    %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$ap{prnumber});

    my %rule = &getRuleInfo(dbh=>$args{dbh}, schema=>$args{schema}, type=>5, site=>$pd{site});

    $output .= "<input type=hidden name=apid value='$ap{id}'>\n";
    $output .= "<input type=hidden name=prnumber value='$pd{prnumber}'>\n";
    $output .= "<input type=hidden name=status value='$ap{status}'>\n";
    $output .= "<input type=hidden name=entrystatus value='$ap{entrystatus}'>\n";
    $output .= "<table align=center border=0><tr><td>\n";
    $output .= "<table align=center border=0>\n";
    $output .= "<tr><td><b>AP ID:</b><br>$ap{id} &nbsp; </td>";
    $output .= "<td><b>Purchase Order Number:</b><br><a href=\"javascript:printPO('$pd{prnumber}')\">$pd{ponumber}" . ((defined($pd{amendment})) ? $pd{amendment} : "") . "</a></td></tr>\n";
    $output .= "<tr><td><b>Vendor:</b></td><td>$pd{vendorname}</td></tr>\n";
    $output .= "<tr><td><b>Invoice Number:</b></td>";
    if ($args{browseOnly} eq 'F' && $ap{status} == 1) {
        $output .= "<td><input type=text name=invoicenumber size=20 maxlength=30 value='$ap{invoicenumber}'>";
    } else {
        $output .= "<td>$ap{invoicenumber}</td></tr>\n";
    }
    $output .= "<tr><td><b>Date Invoice Received: </b></td>";
    if ($args{browseOnly} eq 'F' && $ap{status} == 1) {
        $output .= "<td><input type=text name=datereceived size=10 maxlength=10 value='$ap{datereceived}' onfocus=\"this.blur(); showCal('caldatereceived')\">";
        $output .= "<span id=\"datereceivedid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n\n";
    } else {
        $output .= "<td>$ap{datereceived}</td></tr>\n";
    }
    $output .= "<tr><td><b>Invoice Date: </b></td>";
    if ($args{browseOnly} eq 'F' && $ap{status} == 1) {
        $output .= "<td><input type=text name=invoicedate size=10 maxlength=10 value='$ap{invoicedate}' onfocus=\"this.blur(); showCal('calinvoicedate')\">";
        $output .= "<span id=\"invoicedateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n\n";
    } else {
        $output .= "<td>$ap{invoicedate}</td></tr>\n";
    }
    $output .= "<tr><td><b>Tax Paid?</b></td>";
    #my %taxPaidVals = ('F'=>'No (Use Tax)', 'T'=>'Yes', 'NA'=>'N/A');
    my %taxPaidVals = ('F'=>'Use Tax', 'T'=>'Sales Tax', 'NA'=>'N/A');
    if ($args{browseOnly} eq 'F' && $ap{status} == 1) {
    #if ($args{browseOnly} eq 'F' && $ap{status} == 1 && 1==2) { # changed to never be true to disable changes to the taxpaid value.
        #$output .= "<td><select name=taxpaid size=1>\n";
        $output .= "<td>\n";
#print STDERR "\ntax paid: '$ap{taxpaid}'\n\n";
        foreach my $key (sort keys %taxPaidVals) {
            #$output .= "<option value='$key'" . (($ap{taxpaid} eq $key) ? " selected" : "") .">$taxPaidVals{$key}</option>\n";
            $output .= "<input type=radio name=taxpaid value='$key'" . (($ap{taxpaid} eq $key) ? " checked" : "") .">$taxPaidVals{$key} &nbsp; \n";
        }
        #$output .= "</select></td></tr>\n";
        $output .= "</select></td></tr>\n";
    } else {
        $output .= "<td>$taxPaidVals{$ap{taxpaid}}</td></tr>\n";
        $output .= "<input type=hidden name=taxpaid value=$ap{taxpaid}>\n";
    }
    if ($ap{status} >= 3) {
        $output .= "<tr><td><b>Date Paid: </b></td>";
        if ($args{browseOnly} eq 'F') {
            $output .= "<td><input type=text name=datepaid size=10 maxlength=10 value='" . ((defined($ap{datepaid})) ? $ap{datepaid} : "") . "' onfocus=\"this.blur(); showCal('caldatepaid')\">";
            $output .= "<span id=\"datepaidid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n\n";
        } else {
            $output .= "<td>" . ((defined($ap{datepaid})) ? $ap{datepaid} : "") . "</td></tr>\n";
        }
        $output .= "<tr><td><b>$SYSClient Billed: </b></td>";
        if ($args{browseOnly} eq 'F') {
            $output .= "<td><input type=text name=clientbilled size=10 maxlength=10 value='" . ((defined($ap{clientbilled})) ? $ap{clientbilled} : "") . "' onfocus=\"this.blur(); showCal('calclientbilled')\">";
            $output .= "<span id=\"clientbilledid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n\n";
        } else {
            $output .= "<td>" . ((defined($ap{clientbilled})) ? $ap{clientbilled} : "") . "</td></tr>\n";
        }
    }
    $output .= "<tr><td><b>PO:</b></td><td><b>Shipping:</b> " . dollarFormat($pd{shipping}) . ", <b>Tax:</b> " . dollarFormat($pd{tax}) . "</td></tr>\n";
    $output .= "<tr><td colspan=2><b>Comments:</b><br>";
    my $comments = ((defined($ap{comments})) ? $ap{comments} : "");
    $comments =~ s/\n/<br>\n/g;
    $comments =~ s/  / &nbps;/g;
    if ($args{browseOnly} eq 'F' && $ap{status} <= 3) {
#        $output .= "<textarea name=comments rows=3 cols=60>" . ((defined($ap{comments})) ? $ap{comments} : "") . "</textarea>\n";
        $output .= "<textarea name=comments rows=3 cols=60></textarea>\n";
        $output .= "<input type=hidden name=oldcomments value=\"" . ((defined($ap{comments})) ? $ap{comments} : "") . "\">\n";
        if ($comments gt "   ") {
            $output .= "<br><b>Past Comments:</b><br>$comments";
        }
    } else {
        $output .= "$comments";
    }
    $output .= "</td></tr>\n";
    $output .= "";
    $output .= "</table></td></tr>\n";
    
# items
    $output .= "<tr><td colspan=2>\n";
    my $itemStyle = "font-family: verdana; font-size: 7pt;";
    my $text = "";
    $text .= "<table border=1 cellpadding=1 cellspacing=0 style=\"$itemStyle\">\n";
    $text .= "<tr bgcolor=#a0e0c0><td align=center valign=top width=100><b>Charge Number</b></td>";
    $text .= "<td align=center valign=top width=20><b>EC</b></td>";
    $text .= "<td align=center valign=top width=80><b>Expected</b></td><td align=center valign=top width=80><b>Invoiced</b></td>";
    $text .= "<td align=center valign=top width=80><b>Balance</b></td>";
    $text .= "<td align=center valign=top width=80><b>Amount</b>\n";
    $text .= "<td align=center valign=top width=80><b>Tax</b></td>";
    $text .= "<td align=center valign=top width=80><b>Total</b></tr>\n";
    $text .= "<input type=hidden name=itemcount value=$pd{chargedistlistCount}>\n";
    for (my $i=0; $i<$pd{chargedistlistCount}; $i++) {
        my $k = $i + 1;
        $text .= "<tr bgcolor=ffffff><td align=center>$pd{chargedistlist}[$i]{chargenumber}<input type=hidden name=chargenumber$k value=\"$pd{chargedistlist}[$i]{chargenumber}\"></td>\n";
        $text .= "<td align=center>$pd{chargedistlist}[$i]{ec}<input type=hidden name=ec$k value=$pd{chargedistlist}[$i]{ec}></td>\n";
        $text .= "<td align=center>" . dollarFormat($pd{chargedistlist}[$i]{amount}) . "</td>\n";
        $text .= "<input type=hidden name=expected$k value=$pd{chargedistlist}[$i]{amount}>\n";
        my $key = $pd{chargedistlist}[$i]{chargenumber} . "-" . $pd{chargedistlist}[$i]{ec};
        my $invoiced = ((defined($pd{chargedistlist}[$i]{invoiced})) ? $pd{chargedistlist}[$i]{invoiced} : 0);
        my $currVal = ((defined($ap{$key}{tax})) ? $ap{$key}{tax} : 0) + ((defined($ap{$key}{amount})) ? $ap{$key}{amount} : 0);
        $text .= "<td align=center><div id=invoiced$k>" . dollarFormat($invoiced) . "</div></td>\n";
        $text .= "<input type=hidden name=invoicedsave$k value=" . ($invoiced - $currVal) . ">\n";
        my $balance = $pd{chargedistlist}[$i]{amount} - ((defined($pd{chargedistlist}[$i]{invoiced})) ? $pd{chargedistlist}[$i]{invoiced} : 0);
        $text .= "<td align=center><div id=balance$k>" . dollarFormat($balance) . "</div></td>\n";
        $text .= "<input type=hidden name=balancesave$k value=" . ($balance + $currVal) . ">\n";
        if ($args{browseOnly} eq 'F' && $ap{status} == 1) {
            $text .= "<td align=center><input name=amount$k type=text size=6 maxlength=12 value='" . ((defined($ap{$key}{amount})) ? dFormat($ap{$key}{amount})  : "0.00") . "' style=\"$itemStyle\" onChange=\"updateInvBal($k);\"></td>\n";
            $text .= "<td align=center><input name=tax$k type=text size=5 maxlength=11 value='" . ((defined($ap{$key}{tax})) ? dFormat($ap{$key}{tax})  : "0.00") . "' style=\"$itemStyle\" onChange=\"updateInvBal($k);\"></td>";
            $text .= "<input type=hidden name=taxsave$k value=" . ((defined($ap{$key}{tax})) ? dFormat($ap{$key}{tax})  : "0.00") . ">\n";
            my $invTotal = ((defined($ap{$key}{tax})) ?$ap{$key}{tax}  : 0.00) + ((defined($ap{$key}{amount})) ?$ap{$key}{amount}  : 0.00);
            $text .= "<td align=center><div id=invTotal$k>" . dollarFormat($invTotal) . "</div></td></tr>";
            $text .= "<input type=hidden name=amountsave$k value=" . ((defined($ap{$key}{amount})) ? dFormat($ap{$key}{amount})  : "0.00") . ">\n";
        } else {
            $text .= "<td align=center>" . dollarFormat((defined($ap{$key}{amount})) ?$ap{$key}{amount}  : "0.00") . "</td>\n";
            $text .= "<td align=center>" . dollarFormat((defined($ap{$key}{tax})) ?$ap{$key}{tax}  : "0.00") . "</td>\n";
            my $invTotal = ((defined($ap{$key}{tax})) ?$ap{$key}{tax}  : 0.00) + ((defined($ap{$key}{amount})) ?$ap{$key}{amount}  : 0.00);
            $text .= "<td align=center>" . dollarFormat($invTotal) . "</td>\n";
            $text .= "</tr>\n";
        }
    }
    $text .= "</table>\n";

    $output .= &buildSectionBlock(title=> "<b>Charge List</b>", contents=>$text);

# List of past invoices
    my @apStatus = ("", "Initial", "Approval Pending", "Approved", "Closed");
    my @apList = &getAP(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pd{prnumber}, orderBy=>'i.datereceived');
    $text = "";
    my $invCount = 0;
    $text .= "<table border=1 cellpadding=1 cellspacing=0 style=\"$itemStyle\">\n";
    my $noDate = "-";
    for (my $i=0; $i<$#apList; $i++) {
        if ($apList[$i]{id} ne $ap{id}) {
            $invCount++;
            if ($invCount == 1) {
                $text .= "<tr bgcolor=#a0e0c0><td align=center valign=bottom><b>Invoice</b></td>";
                $text .= "<td align=center valign=bottom><b>Input by</b></td>";
                $text .= "<td align=center valign=bottom><b>Charge #</b></td>";
                $text .= "<td align=center valign=bottom><b>EC</b></td>";
                $text .= "<td align=center valign=bottom><b>Subtotal</b></td><td align=center valign=bottom><b>Tax</b></td>";
                $text .= "<td align=center valign=bottom><b>Total</b></td><td align=center valign=bottom><b>Paid / ";
                $text .= "Billed</b></td><td align=center valign=bottom><b>Status</b></td>";
                $text .= "</tr>\n";

            }
            my $name = (($apList[$i]{enteredby} > 0) ? &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$apList[$i]{enteredby}) : "n/a");
            $text .= "<tr bgcolor=#ffffff><td rowspan=$apList[$i]{itemCount}>$apList[$i]{invoicenumber}</td>";
            $text .= "<td rowspan=$apList[$i]{itemCount}>$name</td>";
            $text .= "<td>$apList[$i]{items}[0]{chargenumber}</td><td>$apList[$i]{items}[0]{ec}</td>";
            my $tax = ((defined($apList[$i]{items}[0]{tax})) ? $apList[$i]{items}[0]{tax} : 0);
            $text .= "<td align=right>" . dollarFormat($apList[$i]{items}[0]{amount}) . "</td><td align=right>" . dollarFormat($tax) . "</td>";
            $text .= "<td align=right>" . dollarFormat($apList[$i]{items}[0]{amount} + $tax) . "</td>";
            $noDate = (($args{browseOnly} eq 'F' && $apList[$i]{status} == 3) ? "<a href=\"javascript:verifyFinalSaveSubmit(document.$args{form}, '$apList[$i]{id}')\">Enter</a>" : "-");
            #$text .= "<td align=center rowspan=$apList[$i]{itemCount}>" . ((defined($apList[$i]{datepaid})) ? $apList[$i]{datepaid} : "-") . " / ";
            $text .= "<td align=center rowspan=$apList[$i]{itemCount}>" . ((defined($apList[$i]{datepaid})) ? $apList[$i]{datepaid} : $noDate) . " / ";
            #$text .= ((defined($apList[$i]{clientbilled})) ? $apList[$i]{clientbilled} : "-") . "</td>";
            $text .= ((defined($apList[$i]{clientbilled})) ? $apList[$i]{clientbilled} : $noDate) . "</td>";
            $text .= "<td rowspan=$apList[$i]{itemCount}>$apStatus[$apList[$i]{status}]</td></tr>\n";
            for (my $j=1; $j<$apList[$i]{itemCount}; $j++) {
                $text .= "<tr bgcolor=#ffffff><td>$apList[$i]{items}[$j]{chargenumber}</td><td>$apList[$i]{items}[$j]{ec}</td>";
                my $tax = ((defined($apList[$i]{items}[$j]{tax})) ? $apList[$i]{items}[$j]{tax} : 0);
                $text .= "<td align=right>" . dollarFormat($apList[$i]{items}[$j]{amount}) . "</td><td align=right>" . dollarFormat($tax) . "</td>";
                $text .= "<td align=right>" . dollarFormat($apList[$i]{items}[$j]{amount} + $tax) . "</td></tr>";
            }
        }
    }
    $text .= "</table>\n";
    if ($invCount < 1) {
        $text .= "No Prior Invoices\n";
    }
    
    $output .= &buildSectionBlock(title=> "<b>Other Invoices for $pd{ponumber}" . ((defined($pd{amendment})) ? $pd{amendment} : "") . "</b>", contents=>$text);

# control buttons
    if ($args{browseOnly} eq 'F' && $ap{status} == 1) {
        $output .= "<tr><td colspan=2 align=center>";
        $output .= "<input type=button name=submitsavebutton value='Save Only' onClick=\"verifySaveSubmit(document.$args{form},'save', 'n/a')\"> &nbsp; <br><br>";
        $output .= "<input type=button name=submitsavenewbutton value='Save and Enter new Invoice' onClick=\"verifySaveSubmit(document.$args{form},'save', 'new')\"> &nbsp; <br><br>";
        $output .= "<input type=button name=submitreqapprovalbutton value='Request Approval Only' onClick=\"verifySaveSubmit(document.$args{form},'approval', 'n/a')\"> &nbsp; <br><br>";
        $output .= "<input type=button name=submitreqapprovalbutton value='Request Approval and Enter new Invoice' onClick=\"verifySaveSubmit(document.$args{form},'approval', 'new')\"> &nbsp; ";
        $output .= "</td></tr>\n";
    } elsif ($args{browseOnly} eq 'F' && $ap{status} == 2) {
        $output .= "<tr><td colspan=2 align=center>";
        $output .= "<input type=button name=submitapprovebutton value='Approve' onClick=\"verifyApprovalSubmit(document.$args{form},'approve')\"> &nbsp; ";
        $output .= "<input type=button name=submitrejectbutton value='Reject' onClick=\"verifyApprovalSubmit(document.$args{form},'reject')\"> &nbsp; ";
        $output .= "</td></tr>\n";
    } elsif ($args{browseOnly} eq 'F' && $ap{status} >= 3) {
        $output .= "<tr><td colspan=2 align=center>";
        $output .= "<input type=button name=submitsavebutton value='Save' onClick=\"verifyFinalSaveSubmit(document.$args{form}, '0')\"> &nbsp; ";
        $output .= "</td></tr>\n";
    } else {
        $output .= "<tr><td colspan=2 align=center>";
        #$output .= " ";
        $output .= "</td></tr>\n";
    }
    
    $output .= "</td></tr>\n";
    
    
    $output .= "</table>\n";


    $output .= <<END_OF_BLOCK;

<script language=javascript><!--


function printPO(id) {
    var myDate = new Date();
    var winName = myDate.getTime();
    document.$args{form}.id.value = id;
    document.$args{form}.action = '$args{path}' + 'purchaseDocuments.pl';
    document.$args{form}.command.value = 'printpo';
    document.$args{form}.target = winName;
    var newwin = window.open('',winName);
    newwin.creator = self;
    document.$args{form}.submit();
}

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

function updateInvBal(id) {
    var totalv = 0.0;
    var msg = "";
    var code = ""
        +"if (isblank($form.tax" + id + ".value) || !isFloat($form.tax" + id + ".value)) {\\n"
        +"    msg +='Tax must be a number\\\\n';\\n"
        +"    $form.tax" + id + ".value = $form.taxsave" + id + ".value;\\n"
        +"}\\n"
        +"if (isblank($form.amount" + id + ".value) || !isFloat($form.amount" + id + ".value)) {\\n"
        +"    msg +='Amount must be a number\\\\n';\\n"
        +"    $form.amount" + id + ".value = $form.amountsave" + id + ".value;\\n"
        +"}\\n"
        +"var sum = ($form.tax" + id + ".value - 0) + ($form.amount" + id + ".value - 0);\\n"
        +"var invoiced = (Math.round((($form.invoicedsave" + id + ".value - 0) + (sum - 0)) * 100.0) / 100.0);\\n"
        +"var balance = (Math.round((($form.balancesave" + id + ".value - 0) - (sum - 0)) * 100.0) / 100.0);\\n"
        +"var maxValue = ($form.expected" + id + ".value - 0) + (($form.expected" + id + ".value - 0)*$rule{nvalue2}/100.0) + 0.05;\\n"
        +"if ((($form.expected" + id + ".value - 0)>= 0 && invoiced > maxValue) || (($form.expected" + id + ".value - 0)< 0 && invoiced < maxValue)) {\\n"
        +"    msg +='Tax and/or amount values are too large\\\\n';\\n"
        +"    $form.amount" + id + ".value = $form.amountsave" + id + ".value;\\n"
        +"    $form.tax" + id + ".value = $form.taxsave" + id + ".value;\\n"
        +"    invoiced" + id + ".innerText = '\$' + dFormat(($form.invoicedsave" + id + ".value - 0));\\n"
        +"    balance" + id + ".innerText = '\$' + dFormat(($form.balancesave" + id + ".value - 0));\\n"
        +"} else {\\n"
        +"    invoiced" + id + ".innerText = '\$' + dFormat(invoiced);\\n"
        +"    balance" + id + ".innerText = '\$' + dFormat(balance);\\n"
        +"}\\n"
        +"totalv += ($form.tax" + id + ".value - 0) + ($form.amount" + id + ".value - 0);\\n"
        +"totalv = (Math.round(totalv * 100.0) / 100.0);\\n"
        +"invTotal" + id + ".innerText = '\$' + dFormat(totalv);\\n"
        +"";
    eval(code);
    if (msg != "") {
        alert (msg);
    }
}

function verifySaveSubmit (f,type, type2){
// javascript form verification routine
    var msg = "";
    if (isblank(f.datereceived.value)) {
        msg += "Date Received must be entered.\\n";
    }
    if (isblank(f.invoicedate.value)) {
        msg += "Invoice Date must be entered.\\n";
    }
    if (isblank(f.invoicenumber.value)) {
        msg += "Invoice Number must be entered.\\n";
    }
    var dollarErr = false;
    for (i=1; i <= f.itemcount.value; i++) {
        var code = ""
            +"if (!isFloat(f.tax" + i + ".value) || !isFloat(f.amount" + i + ".value)) {\\n"
            +"    dollarErr = true;\\n"
            +"}\\n"
        + "";
        
        eval(code);
    }
    if (dollarErr) {
        msg += "Tax and Amount must be entered as numbers.\\n";
    }
    if (msg != "") {
      alert (msg);
    } else {
        if (type == 'approval') {
            f.status.value = 2;
        }
        if (type2 == 'new') {
            submitFormCGIResults('$args{form}', 'saveapnew');
        } else {
            submitFormCGIResults('$args{form}', 'saveap');
        }
    }
}

function verifyApprovalSubmit (f,type){
// javascript form verification routine
    var msg = "";
    if (type == 'reject' && (isblank(f.comments.value) || f.comments.value == f.oldcomments.value)) {
        msg += "Comment must be entered.\\n";
    }
    if (msg != "") {
      alert (msg);
    } else {
        if (type == 'approve') {
            f.status.value = 3;
        } else {
            f.status.value = 1;
        }
        submitFormCGIResults('$args{form}', 'approvesave');
    }
}

function verifyFinalSaveSubmit (f, apid){
// javascript form verification routine
    var msg = "";
    if (msg != "") {
      alert (msg);
    } else {
        if (!isblank(f.datepaid.value) && !isblank(f.clientbilled.value)) {
            f.status.value = 4;
        }
        if (apid == '0') {
            submitFormCGIResults('$args{form}', 'finalizesave');
        } else {
            document.$args{form}.id.value = apid;
            submitFormCGIResults('$args{form}', 'finalizesaveupdate');
        }
    }
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


//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doAPSave {  # routine to save ap data
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    my $logType = 0;

    my $status;
    $settings{comments} = &commentFormat(dbh => $args{dbh}, schema => $args{schema}, settings => \%settings);
    if ($args{command} eq "saveap" || $args{command} eq "saveapnew") {
        $status = &doProcessAPSave(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, id => $args{id}, 
                  settings => \%settings);
        $message = "Invoive $settings{apid} for $settings{prnumber} entered/updated";
        $logType = (($settings{entrystatus} eq 'new') ? 27 : 28)
    } elsif ($args{command} eq "approvesave" ||$args{command} eq "approvesavenew") {
        $status = &doProcessAPApproveSave(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, id => $args{id}, 
                  settings => \%settings);
        $message = "Invoice $settings{apid} for $settings{prnumber} ";
        if ($settings{status} == 1) {
            $message .= "Rejected";
            $logType = 28;
        } else {
            $message .= "Approved";
            $logType = 29;
        }
    } elsif ($args{command} eq "finalizesave" || $args{command} eq "finalizesaveupdate") {
        $status = &doProcessAPfinalizeSave(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, id => $args{id}, 
                  settings => \%settings);
        $message = "Invoice $settings{apid} for $settings{prnumber} ";
        if ($settings{status} == 3) {
            $message .= "Updated";
            $logType = 28;
        } else {
            $message .= "Closed";
            $logType = 30;
        }
    }

    
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, logMessage => $message, 
                 type => $logType);
    
    $output .= "<script language=javascript><!--\n";
    if ($args{command} eq "saveapnew" ||$args{command} eq "approvesavenew") {
        $output .= "   document.$args{form}.id.value='$settings{prnumber}';\n";
        $output .= "   submitForm('$args{form}','newap');\n";
    } elsif ($args{command} eq "finalizesaveupdate") {
        $output .= "   document.$args{form}.id.value='$settings{id}';\n";
        $output .= "   submitForm('$args{form}','finalizeapform');\n";
    } else {
        $output .= "   submitForm('home','home');\n";
    }
    $output .= "//--></script>\n";


    return($output);
}


###################################################################################################################################
sub doClosePO {  # routine to close a po
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$args{id});

    my $status = &doProcessPOClose(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, id => $args{id}, 
                  settings => \%settings);
    
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, logMessage => "PO $pd{ponumber} (PR $args{id}) closed", 
                 type => 21);
    
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('home','home');\n";
    $output .= "//--></script>\n";


    return($output);
}


###################################################################################################################################
sub dollarFormat {  # routine to format dollars
###################################################################################################################################
    my $text = reverse (sprintf "%20.2f", ($_[0]));
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    $text = scalar reverse $text;
    $text =~ s/ //g;
    return '$' . $text;
}


###################################################################################################################################
sub dFormat {  # routine to format dollars
###################################################################################################################################
    my $text = sprintf "%20.2f", ($_[0]);
    $text =~ s/ //g;
    return $text;
}


###################################################################################################################################
sub commentFormat {  # routine to format comments
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $comment = ((defined($settings{oldcomments}) && $settings{oldcomments} gt "   ") ? $settings{oldcomments} : "");
    my $name = &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$settings{userid});
    my $date = &getSysdate(dbh=>$args{dbh}, schema=>$args{schema});
    $comment = ((defined($settings{comments}) && $settings{comments} gt "   ") ? "$name $date - $settings{comments}\n" : "") . $comment;
    return $comment;
}




###################################################################################################################################
###################################################################################################################################



1; #return true
