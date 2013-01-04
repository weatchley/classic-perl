# UI Bids functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UIBids.pm,v $
#
# $Revision: 1.20 $
#
# $Date: 2009/07/31 22:43:26 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIBids.pm,v $
# Revision 1.20  2009/07/31 22:43:26  atchleyb
# Updates related to ACR0907_004-SWR0149   New intermediate buyer role, minor bug fixes
#
# Revision 1.19  2009/06/26 21:57:40  atchleyb
# ACR0906_001 - List of changes
#
# Revision 1.18  2009/06/19 17:03:54  atchleyb
# ACR0906_007 - Set award PO button to diable on submit to prevent double clicking.
#
# Revision 1.17  2008/09/29 17:37:55  atchleyb
# ACR0809_004 - fixed bug with bid remarks being deleted when the bid abstract is generated from the browse form
#
# Revision 1.16  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.15  2007/02/07 17:28:29  atchleyb
# CR 0030 - Updated to handle default PO clauses
#
# Revision 1.14  2006/05/17 23:14:45  atchleyb
# CR0026 - added options for entering/displaying bid response
#
# Revision 1.13  2006/03/15 17:37:04  atchleyb
# CR 0023 - updated to allow generate bid abstract to save bid comments first
# CR 0023 - updated to display $0.00 on bid abstract for entries with 0 dollars
#
# Revision 1.12  2006/01/31 23:10:21  atchleyb
# CR 0022 - Updated to allow vendor to be changed for sole source PR's
#
# Revision 1.11  2005/11/18 19:17:11  atchleyb
# CR0020 - Updated to allow input of negative dollar amounts
#
# Revision 1.10  2005/08/30 21:34:31  atchleyb
# CR0017 Updated dollar form field lengths to 12
#
# Revision 1.9  2005/08/18 19:01:35  atchleyb
# CR00015 - fixed misspelling
#
# Revision 1.8  2005/02/01 00:10:26  atchleyb
# Updated for CR005, fixed tax calculation on Bid Abstract report and minor formvalidation bug on bid entry.
#
# Revision 1.7  2004/12/16 15:50:25  atchleyb
# Updated javascript code for generating inserted item numbers
#
# Revision 1.6  2004/12/07 18:42:35  atchleyb
# updated to allow dynamic selection of logo for report
#
# Revision 1.5  2004/04/22 21:39:52  atchleyb
# Updates related to SCR 1 (add field briefdescription)
#
# Revision 1.4  2004/04/01 23:57:13  atchleyb
# updated to ask for due date
#
# Revision 1.3  2004/02/27 00:07:05  atchleyb
# fixed problem with subtotal calc
# removed some log warnings
#
# Revision 1.2  2003/12/09 22:12:24  atchleyb
# fixed javascript validation problem
#
# Revision 1.1  2003/12/02 16:55:36  atchleyb
# Initial revision
#
#
#
#
#
#

package UIBids;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBBids qw(:Functions);
use DBPurchaseDocuments qw(getPDInfo getUnitIssue getMimeType addPDHistory doProcessAcceptPO);
use DBVendors qw(getVendorInfo getVendorList);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Sessions qw(:Functions);
use DBSites qw(getSiteInfo);
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
      &doFooter               &getTitle             &doBrowse
      &doBidsForm             &doBidEntryForm       &doBidSave
      &doAddVendor            &doBidAbstract        &doSaveBidRemarks
      &doBidAward             &doBidDelete
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             
      &doFooter               &getTitle             &doBrowse
      &doBidsForm             &doBidEntryForm       &doBidSave
      &doAddVendor            &doBidAbstract        &doSaveBidRemarks
      &doBidAward             &doBidDelete
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
   if (($args{command} eq "bidsform") || ($args{command} eq "bidsaveremarks") || ($args{command} eq "bidaward")) {
      $title = "Bids";
   } elsif (($args{command} eq "browse") || ($args{command} eq "browsebid")) {
      $title = "Browse Bid";
   } elsif (($args{command} eq "bidentry") || ($args{command} eq "savebid") || ($args{command} eq "deletebid")) {
      $title = "Bid Entry";
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
       bidid => (defined($mycgi->param("bidid"))) ? $mycgi->param("bidid") : "0",
       bidstatus => (defined($mycgi->param("bidstatus"))) ? $mycgi->param("bidstatus") : "old",
       vendor => (defined($mycgi->param("vendor"))) ? $mycgi->param("vendor") : "0",
       datebidreceived => (defined($mycgi->param("datebidreceived"))) ? $mycgi->param("datebidreceived") : "",
       timebidreceived => (defined($mycgi->param("timebidreceived"))) ? $mycgi->param("timebidreceived") : "",
       duedate => (defined($mycgi->param("duedate"))) ? $mycgi->param("duedate") : "",
       shipping => (defined($mycgi->param("shipping"))) ? $mycgi->param("shipping") : "0",
       fob => (defined($mycgi->param("fob"))) ? $mycgi->param("fob") : "",
       shipvia => (defined($mycgi->param("shipvia"))) ? $mycgi->param("shipvia") : "",
       terms => (defined($mycgi->param("terms"))) ? $mycgi->param("terms") : "",
       itemcount => (defined($mycgi->param("itemcount"))) ? $mycgi->param("itemcount") : "0",
       v_vendorid => (defined($mycgi->param("v_vendorid"))) ? $mycgi->param("v_vendorid") : "0",
       bidremarks => (defined($mycgi->param("bidremarks"))) ? $mycgi->param("bidremarks") : "",
       vendorselect => (defined($mycgi->param("vendorselect"))) ? $mycgi->param("vendorselect") : "",
       bidselect => (defined($mycgi->param("bidselect"))) ? $mycgi->param("bidselect") : "",
       response => (defined($mycgi->param("response"))) ? $mycgi->param("response") : "1",
       dobidsaveremark => (defined($mycgi->param("dobidsaveremark"))) ? $mycgi->param("dobidsaveremark") : "F",
       reload => (defined($mycgi->param("reload"))) ? $mycgi->param("reload") : "T",
    ));

    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    for (my $i=0; $i<=$valueHash{itemcount}; $i++) {
        $valueHash{items}[$i]{"itemnumber"} = (defined($mycgi->param("itemnumber$i"))) ? $mycgi->param("itemnumber$i") : 0;
        $valueHash{items}[$i]{"olditemnumber"} = (defined($mycgi->param("olditemnumber$i"))) ? $mycgi->param("olditemnumber$i") : 0;
        $valueHash{items}[$i]{"partnumber"} = (defined($mycgi->param("partnumber$i"))) ? $mycgi->param("partnumber$i") : "";
        $valueHash{items}[$i]{"description"} = (defined($mycgi->param("description$i"))) ? $mycgi->param("description$i") : "";
        $valueHash{items}[$i]{"quantity"} = (defined($mycgi->param("quantity$i"))) ? $mycgi->param("quantity$i") : 0;
        $valueHash{items}[$i]{"unitofissue"} = (defined($mycgi->param("unitofissue$i"))) ? $mycgi->param("unitofissue$i") : 0;
        $valueHash{items}[$i]{"unitprice"} = (defined($mycgi->param("unitprice$i"))) ? $mycgi->param("unitprice$i") : 0.00;
    }
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => $ENV{SCHEMA},
        title => "$SYSType Bid Functions",
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
sub doBrowse {  # routine to generate a table of Bids for browse
###################################################################################################################################
    my %args = (
        sortBy => 'prnumber',
        @_,
    );
    my $output = "";
    my @PDs = getPDByStatus(dbh => $args{dbh}, schema => $args{schema});

    $output .= "<input type=hidden name=sortby value='prnumber'>\n";
    $output .= "<table align=center cellpadding=1 cellspacing=0 border=1>\n";
    $output .= "<tr bgcolor=#a0e0c0><td><b><a href=\"javascript:reSort('prnumber');\">PR Number</a></b></td>";
    $output .= "<td><b><a href=\"javascript:reSort('ponumber');\">PO Number</a></b></td>";
    $output .= "<td><b>Requester</b></td><td><b>Status</b></td><td><b>Description</b> (from item 1)</td></tr>\n";
    for (my $i=0; $i<$#PDs; $i++) {
        $output .= "<tr bgcolor=#ffffff><td><a href=\"javascript:browsePD('$PDs[$i]{prnumber}');\">$PDs[$i]{prnumber}</a></td>";
        $output .= "<td>" . ((defined($PDs[$i]{ponumber})) ? $PDs[$i]{ponumber} : "&nbsp;") . "</td>";
        my $fullName = &getFullName(dbh => $args{dbh}, schema => $args{schema}, userID=>$PDs[$i]{requester});
        $output .= "<td>$fullName</td>";
        $output .= "<td>$PDs[$i]{statusname}</td>";
        $output .= "<td>" . ((defined($PDs[$i]{briefdescription}) && $PDs[$i]{briefdescription} gt ' ') ? $PDs[$i]{briefdescription} : "&nbsp;") . "</td>";
        $output .= "</tr>\n";
    }
    $output .= "</table>\n";
    
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function browsePD (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'displaypd');
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
sub doBidsForm {  # routine to generate a form for bids
###################################################################################################################################
    my %args = (
        id => 0,
        browseOnly => 'F',
        @_,
    );
    my $output = "";
    my %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id});
    my @bids = &getBids(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id});

    $output .= "<input type=hidden name=prnumber value='$args{id}'>\n";
    $output .= "<input type=hidden name=reload value='T'>\n";
    $output .= "<input type=hidden name=dobidsaveremark value='T'>\n";
    $output .= "<p align=center><b>RFP $args{id}</b><br><br>\n";
    $output .= "<p align=center><b>Bids</b>\n";
    $output .= "<table align=center cellpadding=1 cellspacing=0 border=1>\n";
    $output .= "<tr bgcolor=#a0e0c0><td><b>Vendor</b></td><td><b>Date Received</b></td><td><b>Total</b></tr>\n";
    my $lastVendor = 0;
    my $rowSpan = 0;
    my $bidCount = 0;
# bid list
    for (my $i=0; $i<=$#bids; $i++) {
        $output .= "<tr bgcolor=#ffffff>";
        if ($lastVendor != $bids[$i]{vendor}) {
            $output =~ s/<--dorospan-->/$rowSpan/;
            $output .= "<td valign=top rowspan=<--dorospan-->>";
            if ($args{browseOnly} ne 'T') {
                $output .= "<input type=radio name=bidselect value=$bids[$i]{id}" . (($bids[$i]{response} == 1) ? "" : " readonly disabled") . "> &nbsp;";
            }
            $output .= "<a href=javascript:browseVendor($bids[$i]{vendor})>$bids[$i]{vendorname}</a></td>";
            $rowSpan = 0;
            $lastVendor = $bids[$i]{vendor};
        }
        $rowSpan++;
        $output .= "<td><a href=javascript:bidBrowse($bids[$i]{id})>$bids[$i]{datebidreceived} $bids[$i]{timebidreceived}</a>";
        if ($args{browseOnly} ne 'T') {
            $output .= " &nbsp; <a href=javascript:bidEntry($bids[$i]{id})>Edit</a>";
        }
        $output .= "</td>";
        $output .= "<td>\$" . (&dFormat($bids[$i]{total})) . "</td></tr>\n";
        $bidCount++;
    }
    $output .= "<input type=hidden name=bidcount value=$bidCount>\n";
    $output =~ s/<--dorospan-->/$rowSpan/;
    if ($args{browseOnly} ne 'T') {
        $output .= "<tr bgcolor=#eeeeee><td align=center colspan=3><b><a href=javascript:bidEntry(0)>New Bid</a></b></td></tr>\n";
    }
    $output .= "</table>\n";
    
# vendor list    
    $output .= "<br><p align=center><b>Vendor List</b>\n";
    $output .= "<table align=center cellpadding=1 cellspacing=0 border=1>\n";
    $output .= "<tr bgcolor=#a0e0c0><td><b>Vendor</b></td><td><b>Contact</b></td><td><b>Phone</b></tr>\n";
    for (my $i=0; $i<$pd{vendorCount}; $i++) {
        my %vendor = &getVendorInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$pd{vendorList}[$i]{vendor});
        $output .= "<tr bgcolor=#ffffff><td>";
        $output .= "<a href=javascript:browseVendor($pd{vendorList}[$i]{vendor})>$vendor{name}</a></td><td>$vendor{pointofcontact}</td><td>$vendor{phone}</td></tr>\n";
    }
    $output .= "<input type=hidden name=vendorcount value=$pd{vendorCount}>\n";
    #if ($pd{solesource} ne 'T' && $args{browseOnly} ne 'T') {
    if ($args{browseOnly} ne 'T') {
        my $exclude = "0";
        for (my $i=0; $i<$pd{vendorCount}; $i++) {
            $exclude .= ", $pd{vendorList}[$i]{vendor}";
        }
        my @vendors = getVendorList(dbh => $args{dbh}, schema => $args{schema}, excludeList=>$exclude);
        $output .= "<tr bgcolor=#eeeeee><td align=center colspan=3><b><a href=javascript:addVendor(document.$args{form})>Add Vendor</a></b> &nbsp; <select name=v_vendorid size=1>\n";
        $output .= "<option value=0></option>\n";
        for (my $i=0; $i < $#vendors; $i++) {
            my ($id, $name, $city, $state, $mainproduct) = ($vendors[$i]{id},$vendors[$i]{name},$vendors[$i]{city},$vendors[$i]{state},$vendors[$i]{mainproduct});
            $output .= "<option value='$id'>$name - " . ((defined($city)) ? $city : "") . ", " . ((defined($state)) ? $state : "") . "</option>\n";
        }
        $output .= "</select>\n";
        $output .= "</td></tr>\n";
    } else {
        $output .= "<tr bgcolor=#eeeeee><td align=center colspan=3><b>Sole Source</b></td></tr>\n";
    }
    $output .= "</table>\n";
    $output .= "<br><p align=center><b>Remarks</b>\n";
    $output .= "<table align=center cellpadding=1 cellspacing=0 border=1>\n";
    if ($args{browseOnly} ne 'T') {
        $output .= "<tr bgcolor=#ffffff><td><textarea name=bidremarks rows=4 cols=60>" . ((defined($pd{bidremarks})) ? $pd{bidremarks} : "") . "</textarea></td></tr>";
        $output .= "<tr bgcolor=#eeeeee><td align=center><b><a href=javascript:saveRemarks()>Save Remarks</a></b></td></tr>\n";
    } else {
        my $textString = $pd{bidremarks};
        $textString =~ s/\n/<br>\n/g;
        $output .= "<tr bgcolor=#ffffff><td>$textString</td></tr>\n";
    }
    $output .= "</table>\n";
# buttons
    if ($args{browseOnly} ne 'T') {
        my $currFY = &getFY();
        $output .= "<center><br><input type=button name=bidAbstractButton value='Create Bid Abstract' onClick=bidAbstract()></center>\n";
        if ($#bids >= 0) {
            if ($currFY >= $pd{cnFY}) {
                $output .= "<center><br><input type=button name=bidAwardButton value='Select Winning Bid' onClick=\"document.$args{form}.bidAwardButton.disabled=true;bidAward(document.$args{form});\"></center>\n";
            } else {
                $output .= "<center><br>Can Not Select Winning Bid,<br>Charge Number ($pd{chargenumber}) From Future Fiscal Year ($pd{cnFY})</center>\n";
            }
        }
    }
    
    
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function bidEntry (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'bidentry');
}

function bidBrowse (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'browsebid');
}

function addVendor (f) {
    if (f.v_vendorid.selectedIndex != 0) {
        submitFormCGIResults('$args{form}', 'addvendor');
    } else {
        alert('New vendor must be select');
    }
}

function bidQuote (id) {
    var myDate = new Date();
    document.$args{form}.id.value = id;
    document.$args{form}.action = '/mm/doBidAbstractXLS';
    document.$args{form}.target = 'cgiresults';
    document.$args{form}.submit();
}

function saveRemarks () {
    submitFormCGIResults('$args{form}', 'bidsaveremarks');
}

function browseVendor (id) {
    $args{form}.id.value=id;
    submitForm('vendors', 'displayvendor');
}

function bidAbstract () {
    var myDate = new Date();
    var winName = myDate.getTime();
    document.$args{form}.id.value = '$args{id}';
    document.$args{form}.action = '$args{path}' + '$args{form}.pl';
    document.$args{form}.command.value = 'bidabstract';
    document.$args{form}.target = winName;
    var newwin = window.open('',winName);
    newwin.creator = self;
    document.$args{form}.submit();
}

function bidAward (f) {
    var msg = "";
    if (isblank(f.bidremarks.value)) {
      msg += "Bid Remarks must be entered.\\n";
    }
    var bidIsChecked = false;
    if (f.bidcount.value > 1) {
        for (i=0; i < f.bidselect.length; i++) {
            if (f.bidselect[i].checked) {
                bidIsChecked = true;
            }
        }
    } else {
        if (f.bidselect.checked) {
            bidIsChecked = true;
        }
    }
    if (!bidIsChecked) {
        msg += 'A bid must be selected to win the award.\\n';
    }
    if (msg != "") {
      alert (msg);
      f.bidAwardButton.disabled=false;
    } else {
        submitFormCGIResults('$args{form}', 'bidaward');
    }

}

//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub dFormat {  # routine to format dollars
###################################################################################################################################
    my $text = sprintf "%20.2f", ($_[0]);
    $text =~ s/ //g;
    return $text;
}


###################################################################################################################################
sub doBidEntryForm {  # routine to generate an entry form for bids
###################################################################################################################################
    my %args = (
        id => 0,
        browseOnly => 'F',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $form = $args{form};
    my %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$settings{prnumber});
    my %bid;
    
    if ($args{id} == 0) {
        %bid = &genNewBid(dbh => $args{dbh}, schema => $args{schema}, pd=>$settings{prnumber});
    } else {
        %bid = &getBidInfo(dbh => $args{dbh}, schema => $args{schema}, pd=>$settings{prnumber}, id=>$args{id});
    }
    my $vendList = "0";
    for (my $i=0; $i<$pd{vendorCount}; $i++) {
        $vendList .= ", $pd{vendorList}[$i]{vendor}";
    }
    my @vendors = &getVendorList(dbh => $args{dbh}, schema => $args{schema}, idList => $vendList);
    
    $output .= "<input type=hidden name=prnumber value=$pd{prnumber}>\n";
    $output .= "<input type=hidden name=bidid value=$bid{id}>\n";
    $output .= "<input type=hidden name=bidstatus value=$bid{status}>\n";
# vendor & dates
    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td valign=bottom><b>Vendor</b></td><td align=center><b>Date<br>Received</b></td><td align=center><b>Time<br>Received</b></td><td align=center><b>Due/Delivery<br>Date: </b></td></tr>\n";
    if ($args{browseOnly} ne 'T') {
        $output .= "<tr><td><select name=vendor><option value=0> </option>\n";
        for (my $i=0; $i<$#vendors; $i++) {
            $output .= "<option value=$vendors[$i]{id}" . (($vendors[$i]{id}==$bid{vendor}) ? " selected" : "") .">$vendors[$i]{name} - $vendors[$i]{city}</option>\n";
        }
        $output .= "</select></td>\n";
        $output .= "<td align=center><input type=text name=datebidreceived size=10 maxlength=10 value='$bid{datebidreceived}' onfocus=\"this.blur(); showCal('caldatebidreceived')\">";
        $output .= "<span id=\"datebidreceivedid\" style=\"position:relative;\">&nbsp;</span></td>\n";
        $output .= "<td align=center><input type=text name=timebidreceived size=5 maxlength=5 value='$bid{timebidreceived}'></td>";
        $output .= "<td align=center><input type=text name=duedate size=10 maxlength=10 value='$bid{duedate}' onfocus=\"this.blur(); showCal('calduedate')\">\n";
        $output .= "<span id=\"duedateid\" style=\"position:relative;\">&nbsp;</span></td>\n";
        $output .= "</tr>\n";
    } else {
        my %vendor = &getVendorInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$bid{vendor});
        $output .= "<tr><td>$vendor{name} - $vendor{city}</td><td align=center>$bid{datebidreceived}</td><td align=center>$bid{timebidreceived}</td>";
        $output .= "<td>$bid{duedate}</td></tr>\n";
    }
    $output .= "<tr>\n";
    
# fob, ship via & terms
    $output .= "<tr><td colspan=4>\n";
    $output .= "<table border=0 align=center width=100%>\n";
    $output .= "<tr><td><b>FOB</b></td><td> &nbsp;</td><td><b>Ship Via</td><td> &nbsp;</td><td><b>Terms</td></tr>\n";
    if ($args{browseOnly} ne 'T') {
        $output .= "<tr><td><select size=1 name=fob><option value=1" . (($bid{fob}==1) ? " selected" : "") . ">Origin</option>";
        $output .= "<option value=2" . (($bid{fob}==2) ? " selected" : "") . ">Destination</option>";
        $output .= "<option value=3" . (($bid{fob}==3) ? " selected" : "") . ">N/A</option></select></td><td>&nbsp;</td>\n";
        $output .= "<td><input type=text name=shipvia size=20 maxlength=50 value='$bid{shipvia}'><td>&nbsp;</td>\n";
        $output .= "<td><input type=text name=terms size=20 maxlength=50 value='$bid{terms}'></td></tr>\n";
    } else {
        $bid{fob} =~ s/\n/<br>\n/g;
        $bid{shipvia} =~ s/\n/<br>\n/g;
        $bid{terms} =~ s/\n/<br>\n/g;
        $output .= "<tr><td>" . ("", "Origin", "Destination", "N/A")[$bid{fob}] . "</td><td>&nbsp:</td><td>$bid{shipvia}</td><td>&nbsp:</td><td>$bid{terms}</td></tr>\n";
    }
    $output .= "</table></td></tr>\n";
# Response
    $output .= "<tr><td colspan=4>\n";
    $output .= "<b>Vendor Response:<br>\n" . &nbspaces(10);
    if ($args{browseOnly} ne 'T') {
        $output .= "<input name=response type=radio value=1" . (($bid{response}==1) ? " checked" : "") . ">Sent Bid" . &nbspaces(10);
        $output .= "<input name=response type=radio value=2" . (($bid{response}==2) ? " checked" : "") . ">No Bid" . &nbspaces(10);
        $output .= "<input name=response type=radio value=3" . (($bid{response}==3) ? " checked" : "") . ">No Response" . &nbspaces(10);
        $output .= "<input name=response type=radio value=4" . (($bid{response}==4) ? " checked" : "") . ">Other" . &nbspaces(10);
    } else {
        my @responses = ('', 'Sent Bid', 'No Bid', 'No Response', 'Other');
        $output .= $responses[$bid{response}];
    }
    $output .= "</b></td></tr>\n";
# items
    $output .= "<tr><td colspan=4>\n";
    my @unitArray = &getUnitIssue(dbh=>$args{dbh}, schema=>$args{schema});
    my $itemStyle = "font-family: verdana; font-size: 7pt;";
    my $helpStyle = "text-decoration:none; color:$SYSFontColor; cursor: help";
    my $text = "";
    $text .= "<div style=\"$itemStyle\" id=items1>\n";
    $text .= "<table cellpadding=1 cellspacing=0 border=1 style=\"$itemStyle\">\n";
    my $itemCols = 6;
    $text .= "<tr bgcolor=#a0e0c0>";
    $text .= "<td valign=bottom width=70><b><a href=\"javascript:alert('Item Number (must be unique)');\" title='Item Number (must be unique)' style=\"$helpStyle\">#</a>/</b><br>\n";
    $text .= "<b><a href=\"javascript:alert('Part Number');\" title='Part Number' style=\"$helpStyle\">Part #</a></b></td>\n";
    $text .= "<td valign=bottom width=130><b><a href=\"javascript:alert('Product Description');\" title='Product Description' style=\"$helpStyle\">Description</a></b></td>\n";
    $text .= "<td valign=bottom width=40><b><a href=\"javascript:alert('Item Quantity');\" title='Item Quantity' style=\"$helpStyle\">Qty</a></b></td>\n";
    $text .= "<td valign=bottom width=60><b><a href=\"javascript:alert('Unit of Issue');\" title='Unit of Issue' style=\"$helpStyle\">Unit</a></b></td>\n";
    $text .= "<td valign=bottom width=45><b><a href=\"javascript:alert('Price per unit');\" title='Price per unit' style=\"$helpStyle\">Price</a></b></td>\n";
    $text .= "<td valign=bottom width=60><b><a href=\"javascript:alert('Extended Price');\" title='Extended Price' style=\"$helpStyle\">Ext</a></b></td>\n";
    $text .= "</tr>\n";
    if ($args{browseOnly} ne 'T') {
        my $subTotal = 0;
        $text .= "<input type=hidden name=itemcount value=$bid{itemCount}>\n";
        for (my $i=0; $i<$bid{itemCount}; $i++) {
            my ($q, $up) = (($bid{items}[$i]{quantity}*1.0), $bid{items}[$i]{unitprice});
            my $extPrice = ($q * $up);
            my $k = $i + 1;
            $subTotal += $extPrice;
            $text .= "<tr bgcolor=#ffffff><td valign=top><input name=itemnumber$k type=text size=2 maxlength=3 value=$bid{items}[$i]{itemnumber} style=\"$itemStyle\" onChange=\"checkItemNumber(this, $bid{items}[$i]{itemnumber});\"><br>";
            $text .= "<input type=hidden name=olditemnumber$k value=$bid{items}[$i]{itemnumber}>\n";
            $text .= "<input name=partnumber$k type=text size=10 maxlength=30 value='" . ((defined($bid{items}[$i]{partnumber})) ? $bid{items}[$i]{partnumber} : "") . "' style=\"$itemStyle\"></td>";
            my $temp = $bid{items}[$i]{description};
            $text .= "<td valign=top><textarea name=description$k cols=20 rows=3 style=\"$itemStyle\">$temp</textarea></td>";
            $text .= "<td valign=top><input name=quantity$k type=text size=4 maxlength=4 value=$bid{items}[$i]{quantity} style=\"$itemStyle\" onChange=\"updatePrice(this, $form.unitprice$k, itemExt$k);\"></td>";
            $text .= "<td valign=top><select name=unitofissue$k size=1 style=\"$itemStyle\"><option value='0'></option>";
            for (my $j=0; $j<$#unitArray; $j++) {
                $text .= "<option value=$unitArray[$j]{unit}" . (($bid{items}[$i]{unitofissue} eq $unitArray[$j]{unit}) ? " selected" : "") . ">$unitArray[$j]{unit}</option>\n";
            }
            $text .= "</select></td>";
            $text .= "<td valign=top><input name=unitprice$k type=text size=7 maxlength=12 value='" . (($args{id}!=0) ? dFormat($bid{items}[$i]{unitprice}) : '') . "' style=\"$itemStyle\" onChange=\"updatePrice($form.quantity$k, this, itemExt$k);\"></td>";
            $text .= "<td valign=top><div id=itemExt" . ($i + 1) . ">" . dFormat($extPrice) . "</div></td></tr>\n";
        }
        $text .= "</table>\n";
        $text .= "<table cellpadding=0 cellspacing=0 border=0 id=postItemTable style=\\\"$itemStyle\\\" width=100%>";
        $text .= "<tr><td style=\\\"$itemStyle\\\"><table cellpadding=1 cellspacing=0 border=1 style=\\\"$itemStyle\\\"><tr bgcolor=#a0e0c0>";
        my $fontSize = "-2";
        $text .= "<td style=\\\"$itemStyle\\\" align=center width=100><font size=$fontSize><b>Shipping</b></font></td>";
        $text .= "<td style=\\\"$itemStyle\\\" align=center width=100><font size=$fontSize><b>Total</b></font></td>";
        $text .= "</tr><tr bgcolor=#ffffff>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center><input name=shipping type=text size=7 maxlength=8 value='" . dFormat($bid{shipping}) . "' style=\"$itemStyle\" onChange=\"updateTotals();\"></td>\n";
        $subTotal += $bid{shipping};
        $text .= "<td style=\\\"$itemStyle\\\" align=center><font size=$fontSize><div id=total>" . dFormat($subTotal) . "</div></font></td>\n";
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
            +"if ($form.itemnumber"+i+".value > largest) {largest = $form.itemnumber"+i+".value;}\\n"
        + "";
        
        eval(code);
    }
    if (msg != "") {
        alert (msg);
        what.value = largest - 0 + 1;
    }
}
function updatePrice(qnty, prc, ext) {
    var msg = "";
    if (isblank(qnty.value) || isblank(prc.value)) {
        ext.innerText = '0.00';
    }
    if (!isblank(qnty.value) && !isnumeric(qnty.value)) {
        msg +='Quantity must be a positive number';
        qnty.value = '';
        ext.innerText = '0.00';
    }
    if (!isblank(prc.value) && !isFloat(prc.value)) {
        msg +='Price must be a number';
        prc.value = '';
        ext.innerText = '0.00';
    }
    if (msg != "") {
        alert (msg);
    } else {
        var price = (Math.round((qnty.value * prc.value) * 100.)/100.0);
        ext.innerText = dFormat(price);
    }
    updateTotals();
}

function updateTotals() {
    var subTotalv = 0.0;
    //var subTotalTaxable = 0.0;
    //var taxv = ($form.tax.value - 0);
    var totalv = 0.0;
    var shippingv = ($form.shipping.value - 0);
    //var salesTax = ($form.salestax.value - 0) / 100.0;
    for (i=1; i <= $form.itemcount.value; i++) {
        var code = ""
            +"subTotalv += (itemExt" + i + ".innerText - 0);\\n"
            //+"if ($form.ec" + i + ".value == '47' || $form.ec" + i + ".value == '48' || $form.ec" + i + ".value == '49' || $form.ec" + i + ".value == 'sh') {\\n"
            //+"    subTotalTaxable += (itemExt" + i + ".innerText - 0);\\n"
            //+"}\\n"
        + "";
        
        eval(code);
    }
    subTotalv = (Math.round(subTotalv * 100.0) / 100.0);
    //if ($form.taxexempt.value == 'F') {
    //    taxv = (subTotalTaxable + shippingv) * salesTax;
    //    taxv = (Math.round(taxv * 100.0) / 100.0);
    //}
    //totalv = subTotalv + taxv + (shippingv - 0);
    //totalv = subTotalv;
    totalv = subTotalv + (shippingv - 0);
    totalv = (Math.round(totalv * 100.0) / 100.0);
    //subTotal.innerText = dFormat(subTotalv);
    //tax.innerText = dFormat(taxv);
    total.innerText = dFormat(totalv);
    //total.innerText = dFormat(subTotalv);
    //$form.tax.value = dFormat(taxv);
}

function dFormat (val) {
    var text = " ";
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
    newItemRow += "<tr bgcolor=#ffffff><td valign=top width=70><input name=itemnumber" + items + " type=text size=2 maxlength=3 value='" + largest + "' style=\\\"$itemStyle\\\" onChange=\\\"checkItemNumber(this, " + largest + ");\\\"><br>";
    newItemRow += "<input type=hidden name=olditemnumber"+ items + " value='0'>";
    newItemRow += "<input name=partnumber" + items + " type=text size=10 maxlength=30 value='' style=\\\"$itemStyle\\\"></td>";
    newItemRow += "<td valign=top width=130><textarea name=description" + items + " cols=20 rows=3 style=\\\"$itemStyle\\\"></textarea></td>";
    newItemRow += "<td valign=top width=40><input name=quantity" + items + " type=text size=4 maxlength=4 value='' style=\\\"$itemStyle\\\" onChange=\\\"updatePrice(this, $form.unitprice" + items + ", itemExt" + items + ");\\\"></td>";
    newItemRow += "<td valign=top width=60><select name=unitofissue" + items + " size=1 style=\\\"$itemStyle\\\"><option value='0'></option>";
END_OF_BLOCK
    for (my $j=0; $j<$#unitArray; $j++) {
        $text .= "    newItemRow += \"<option value=$unitArray[$j]{unit}>$unitArray[$j]{unit}</option>\";";
    }
    $text .= <<END_OF_BLOCK;
    newItemRow += "</select></td>";
    newItemRow += "<td valign=top width=45><input name=unitprice" + items + " type=text size=7 maxlength=12 value='' style=\\\"$itemStyle\\\" onChange=\\\"updatePrice($form.quantity" + items + ", this, itemExt" + items + ");\\\"></td>";
    newItemRow += "<td valign=top width=60><div id=itemExt" + items + ">0.00</div></td></tr>\\n";
    newItemRow += "</table>\\n";
    document.all.postItemTable.insertAdjacentHTML("BeforeBegin", "" + newItemRow + "");
    
}
//--></script>

END_OF_BLOCK

    } else {
        my $subTotal = 0;
        for (my $i=0; $i<$bid{itemCount}; $i++) {
            my $temp = $pd{items}[$i]{description};
            $temp =~ s/\n/<br>\n/g;
            my $partNumber = ((defined($bid{items}[$i]{partnumber})) ? $bid{items}[$i]{partnumber} : "");
            $text .= "<tr bgcolor=#ffffff><td valign=top>$bid{items}[$i]{itemnumber}<br>$partNumber</td><td valign=top>$temp</td>";
            $text .= "<td valign=top>$bid{items}[$i]{quantity}</td><td valign=top>$bid{items}[$i]{unitofissue}</td><td valign=top>" . dollarFormat($bid{items}[$i]{unitprice}) . "</td>";
            my $extPrice = ($bid{items}[$i]{quantity} * $bid{items}[$i]{unitprice});
            $text .= "<td valign=top>" . dollarFormat($extPrice) . "</td></tr>\n";
            $subTotal += $extPrice;
        }
        $text .= "</table>\n";
        my $fontSize = "-2";
        $text .= "<table cellpadding=1 cellspacing=0 border=1 style=\\\"$itemStyle\\\"><tr bgcolor=#a0e0c0>";
        $text .= "<td style=\\\"$itemStyle\\\" align=center width=100><font size=$fontSize><b>Shipping</b></font></td>";
        $text .= "<td style=\\\"$itemStyle\\\" align=center width=100><font size=$fontSize><b>Total</b></font></td></tr>";
        $text .= "<tr bgcolor=#ffffff>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center><font size=$fontSize><div id=shipping>" . dollarFormat($bid{shipping}) . "</div></font></td>\n";
        $text .= "<td style=\\\"$itemStyle\\\" align=center><font size=$fontSize><div id=total>" . dollarFormat(($subTotal + $bid{shipping})) . "</div></font></td>\n";
        $text .= "</tr></table>\n";
    }
    $text .= "</div>";
    $output .= &buildSectionBlock(title=> "<b>Item List</b>", contents=>$text);
    $output .= "</td></tr>\n";
# controls
    if ($args{browseOnly} ne 'T') {
        $output .= "<tr><td colspan=4 align=center><input type=button name=submitbidbutton value='Save' onClick=\"verifyBidSubmit(document.$args{form})\"></td></tr>\n";
        if ($bid{status} ne 'new') {
            $output .= "<tr><td colspan=4 align=center><input type=button name=deletebidbutton value='Delete' onClick=\"deleteBidSubmit(document.$args{form})\"></td></tr>\n";
        }
    }
    $output .= "</table>\n";

    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifyBidSubmit (f){
// javascript form verification routine
    var msg = "";
    if (f.vendor.selectedIndex == 0) {
      msg += "Vendor must be selected.\\n";
    }
    if (isblank(f.datebidreceived.value) && f.response.value == 1) {
      msg += "Date Received must be entered.\\n";
    }
    if (isblank(f.duedate.value) && f.response.value == 1) {
      msg += "Due Date must be entered.\\n";
    }
    if (isblank(f.shipvia.value) && f.response.value == 1) {
      msg += "Ship Via must be entered.\\n";
    }
    if (isblank(f.terms.value) && f.response.value == 1) {
      msg += "Terms must be entered.\\n";
    }
    var time = f.timebidreceived.value;
    if ((isblank(f.timebidreceived.value) || time.search(/^\\d\\d:\\d\\d\$/) == -1) && f.response.value == 1) {
      msg += "Time Received must be entered (Format as 'HH:MM', 24 hour time).\\n";
    }
    var itemErrors = 0;
    var goodItems = 0;
    for (i=1; i <= f.itemcount.value; i++) {
        var code = ""
            +"if (!isblank(f.partnumber"+i+".value) || !isblank(f.description"+i+".value) || "
            +"      !isblank(f.quantity"+i+".value) || !isblank(f.unitprice"+i+".value) || "
            +"      f.unitofissue"+i+".selectedIndex != 0 "
            +") {"
            +"    if (isblank(f.itemnumber"+i+".value) || isblank(f.description"+i+".value) || "
            +"          isblank(f.quantity"+i+".value) || "
            +"          f.unitofissue"+i+".selectedIndex == 0 "
            +"    ) {"
            +"       itemErrors++;"
            +"    } else {"
            +"       goodItems++;"
            +"    }"
            +"}"
        + "";
        
        eval(code);
    }
    if (itemErrors > 0) {
        msg += 'Item Number, Description, and Unit of Issue are all required for each item.\\n';
    }
    if (goodItems == 0) {
        msg += 'One or more items must be entered for a valid Bid.\\n';
    }
    if (isblank(f.shipping.value) || !isFloat(f.shipping.value)) {
        msg += 'Shipping must be entered as a number (i.e. 1.23).\\n';
        f.shipping.value='0.00';
        updateTotals();
    }
    if (msg != "") {
      alert (msg);
    } else {
        submitFormCGIResults('$args{form}', 'savebid');
    }
}

function deleteBidSubmit (f){
// javascript delete routine
    var msg = "Delete bid from '$bid{vendorname}' received on '$bid{datebidreceived}' at '$bid{timebidreceived}'?";
    if (confirm(msg)) {
        submitFormCGIResults('$args{form}', 'deletebid');
    } else {
    }
}


//--></script>

END_OF_BLOCK

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
sub doBidSave {  # routine to save bid data
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";

    my $status = &doProcessBidSave(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, id => $args{id}, 
              settings => \%settings);

    my $message = "Bid on $settings{prnumber} entered/updated";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, logMessage => $message, type => 35);
    
    $output .= "<script language=javascript><!--\n";
    $output .= "   document.$args{form}.id.value = '$settings{prnumber}';\n";
    $output .= "   submitForm('$args{form}','bidsform');\n";
    $output .= "//--></script>\n";


    return($output);
}


###################################################################################################################################
sub doAddVendor {  # routine to add a vendor to the bid (purchase document)
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";

    my $status = &doProcessAddVendor(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, 
              settings => \%settings);

    my $message = "New vendor added to bid $settings{prnumber}";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, logMessage => $message, type => 21);
    
    $output .= "<script language=javascript><!--\n";
    $output .= "   $args{form}.id.value='$settings{prnumber}';\n";
    $output .= "   submitForm('$args{form}','bidsform');\n";
    $output .= "//--></script>\n";


    return($output);
}


###################################################################################################################################
sub doBidAbstract {  # routine to create a PDF of the bid abstract
###################################################################################################################################
    my %args = (
        forDisplay => 'T',
        @_,
    );
    my $output = "";
    my %pdCurrent = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id});
    my %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id}, history=>'T', historyStatus=>4);
    my @bids = getBids(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id}, getMostRecent=>'T');
    my %siteInfo = &getSiteInfo(dbh => $args{dbh}, schema => $args{schema}, id => $pd{site});

    my $formWidth = 570;
    
    my $pdf = new PDF;
    $pdf->setup(orientation => 'portrait', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
        cellPadding => 4);

#######
    
    my $colCount = 1;
    my @colWidths = (562);
    my @colAlign = ("center");
    my @colData = (" ");
    
    my $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);

## Headers
    my $logo = $pdf->addImage(source=>'file', type=>'png', fileName=>"$SYSFullImagePath/" . lc($siteInfo{shortname}) . "-logo-sm.png");
    $pdf->placeHeaderImage(image=>$logo, alignment => 'left', scale=> .35, xOffset=>-20, yOffset=>30);
    $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    @colData = ("SOLICITATION OF BIDS ABSTRACT OF PROPOSALS");
    $pdf->addHeader(fontSize => 10.0, text => "SOLICITATION OF BIDS ABSTRACT OF PROPOSALS", alignment => "center");


## Footers
#
    $pdf->addFooter(fontSize => 8.0, text => "Page <page>", alignment => "center");
    my $footerDate = &get_date();
    $pdf->addFooter(fontSize => 8.0, text =>$footerDate , alignment => "right", sameLine => 'T');
    my $idText = $pd{prnumber} . ((defined($pd{ponumber})) ? " / $pd{ponumber}" : "");
    $pdf->addFooter(fontSize => 8.0, text =>$idText , alignment => "left", sameLine => 'T');

## start page
    $pdf->newPage(orientation => 'portrait', useGrid => 'F');

# page contents

    for (my $i=0; $i<=$#bids; $i += 2) {
# blank line
        $colCount = 2; @colWidths = (562); @colAlign = ("center"); @colData = (""); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
        $pdf->tableRow(fontSize => 1, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);

# Header info

        $colCount = 2;
        @colWidths = (277,277);
        @colAlign = ("left","left");
        $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
        @colData = ("Purchase Requesition No: $pd{prnumber}", "Purchase Order No: " . ((defined($pdCurrent{ponumber})) ? $pdCurrent{ponumber} : "") . ((defined($pdCurrent{amendment}) && $pdCurrent{amendment} gt ' ') ? "$pdCurrent{amendment}" : ""));
        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);
        @colData = ("Bid Request No: $pd{prnumber}", "Purchase Order Date: " . ((defined($pdCurrent{podate})) ? $pdCurrent{podate} : ""));
        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);

# blank line
        $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (""); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
        $pdf->tableRow(fontSize => 1, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);

# Vendor Info

        $colCount = 4;
        @colWidths = (52,162,162,162);
        @colAlign = ("center","center","center","center");
        $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
        my @responses = ('', '', "\nNo Bid", "\nNo Response", "\nOther");
        @colData = (" ","Purchase Requisition",
                ((defined($bids[$i]{vendorname})) ? $bids[$i]{vendorname} . $responses[$bids[$i]{response}] : " "),
                ((defined($bids[$i+1]{vendorname})) ? $bids[$i+1]{vendorname} . $responses[$bids[$i+1]{response}] : " "));
        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);

# blank line
        $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (""); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
        $pdf->tableRow(fontSize => 1, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);

# Bid info
        $pdf->setFont(font => "Helvetica", fontSize => 10.0);
        $colCount = 7;
        @colWidths = (52,74,80,74,80,74,80);
        @colAlign = ("center","center","center","center","center","center","center");
        my %vend1 = getVendorInfo(dbh => $args{dbh}, schema => $args{schema}, id=>((defined($bids[$i]{vendor})) ? $bids[$i]{vendor} : 0));
        my %vend2 = getVendorInfo(dbh => $args{dbh}, schema => $args{schema}, id=>(((defined($bids[$i+1]{vendor})) ? $bids[$i+1]{vendor} : 0)));
        @colData = (" ","Contact","Due Date",
                    ((defined($vend1{pointofcontact})) ? $vend1{pointofcontact} : " "),$pd{rfpduedate},
                    ((defined($vend2{pointofcontact})) ? $vend2{pointofcontact} : " "),$pd{rfpduedate});
        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);
        @colData = (" ","Phone","Terms",
                    ((defined($vend1{phone})) ? $vend1{phone} : "") . ((defined($vend1{extension})) ? "\nExt: $vend1{extension}" : ""),
                          ((defined($bids[$i]{terms})) ? $bids[$i]{terms} : " "),
                    ((defined($vend2{phone})) ? $vend2{phone} : "") . ((defined($vend2{extension})) ? "\nExt: $vend2{extension}" : ""),
                          ((defined($bids[$i+1]{terms})) ? $bids[$i+1]{terms} : " "));
        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);
        @colData = ("\n ","FOB","Ship Via",
                ((defined($bids[$i]{fob})) ? ("", "Origin", "Destination", "N/A")[$bids[$i]{fob}] : " "), ((defined($bids[$i]{shipvia})) ? $bids[$i]{shipvia} : " "),
                ((defined($bids[$i+1]{fob})) ? ("", "Origin", "Destination", "N/A")[$bids[$i+1]{fob}] : " "), ((defined($bids[$i+1]{shipvia})) ? $bids[$i+1]{shipvia} : " "));
        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);

# blank line
        $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (""); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
        $pdf->tableRow(fontSize => 1, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);
    
# Items

        $colCount = 8;
        @colWidths = (22,22,74,80,74,80,74,80);
        @colAlign = ("center","center","center","center","center","center","center","center");
        $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
        @colData = ("\nItem","\nQty.","\nUnit Price","\nTotal Price","\nUnit Price","\nTotal Price","\nUnit Price","\nTotal Price");
        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);
        @colAlign = ("center","center","right","right","right","right","right","right");
        $pdf->setFont(font => "Helvetica", fontSize => 10.0);
        my $taxableTotal2 = 0.0;
        my $taxableTotal3 = 0.0;
        for (my $j=0; ($j<$pd{itemCount} || $j<$bids[$i]{itemCount} || $j<$bids[$i+1]{itemCount}); $j++) {
            my $q1 = ((defined($pd{items}[$j]{quantity})) ? $pd{items}[$j]{quantity} : 0);
            my $unitPrice1 = ((defined($pd{items}[$j]{unitprice})) ? $pd{items}[$j]{unitprice} : 0.00);
            my $total1 = $q1 * $unitPrice1;
            my $q2 = ((defined($bids[$i]{items}[$j]{quantity})) ? $bids[$i]{items}[$j]{quantity} : 0);
            my $unitPrice2 = ((defined($bids[$i]{items}[$j]{unitprice})) ? $bids[$i]{items}[$j]{unitprice} : 0.00);
            my $total2 = $q2 * $unitPrice2;
            my $q3 = ((defined($bids[$i+1]{items}[$j]{quantity})) ? $bids[$i+1]{items}[$j]{quantity} : 0);
            my $unitPrice3 = ((defined($bids[$i+1]{items}[$j]{unitprice})) ? $bids[$i+1]{items}[$j]{unitprice} : 0.00);
            my $total3 = $q3 * $unitPrice3;
            @colData = (((defined($pd{items}[$j]{itemnumber})) ? $pd{items}[$j]{itemnumber} : ""),$q1,
                     "\$" . dFormat($unitPrice1), "\$" . dFormat($total1),
                     (($unitPrice2 != 0.0) ? "\$" . dFormat($unitPrice2) : ((defined($bids[$i]{terms})) ? "\$0.00" : "")), 
                     (($total2 != 0.0) ? "\$" . dFormat($total2) : ((defined($bids[$i]{terms})) ? "\$0.00" : "")),
                     (($unitPrice3 != 0.0) ? "\$" . dFormat($unitPrice3) : ((defined($bids[$i+1]{terms})) ? "\$0.00" : "")), 
                     (($total3 != 0.0) ? "\$" . dFormat($total3) : ((defined($bids[$i+1]{terms})) ? "\$0.00" : "")));
            $pdf->tableRow(fontSize => 8, fontID => $fontID,
                       colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);
            if (defined($pd{items}[$j]{ec}) && ($pd{items}[$j]{ec} eq '47' || $pd{items}[$j]{ec} eq '48' || $pd{items}[$j]{ec} eq '49' || $pd{items}[$j]{ec} eq 'sh')) {
                $taxableTotal2 += $total2;
                $taxableTotal3 += $total3;
            }
        }

# blank line
        $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (""); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
        $pdf->tableRow(fontSize => 1, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);

# Totals

        $colCount = 4;
        @colWidths = (52,162,162,162);
        @colAlign = ("right","right","right","right");
        my $taxRate = 0.0;
        if ($pd{taxexempt} ne 'T') {
            my @dept = &getDeptArray(dbh => $args{dbh}, schema => $args{schema}, id=>$pd{deptid});
            my @sites = &getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});
            $taxRate = $sites[$dept[0]{site}]{salestax} / 100.0;
        }
        my $subTotal1 = $pd{total} - $pd{tax};
        my $ship1 = $pd{shipping};
        my $tax1 = (($pd{taxexempt} ne 'T') ? $pd{tax} : 0.0);
        my $subTotal2 = ((defined($bids[$i]{total})) ? $bids[$i]{total} : "");
        my $ship2 = ((defined($bids[$i]{shipping})) ? $bids[$i]{shipping} : "");
        $taxableTotal2 += $ship2;
#        my $tax2 = $subTotal2 * $taxRate;
        my $tax2 = (($pd{taxexempt} ne 'T') ? ($taxableTotal2 * $taxRate) : 0.0);
        my $subTotal3 = ((defined($bids[$i+1]{total})) ? $bids[$i+1]{total} : "");
        my $ship3 = ((defined($bids[$i+1]{shipping})) ? $bids[$i+1]{shipping} : "");
        $taxableTotal3 += $ship3;
#        my $tax3 = $subTotal3 * $taxRate;
        my $tax3 = (($pd{taxexempt} ne 'T') ? ($taxableTotal3 * $taxRate) : 0.0);
        @colData = ("Freight\nSubTotal\nTax\nTotal",
              "\$" . dFormat($ship1) . "\n\$" . dFormat($subTotal1) . "\n\$" . dFormat($tax1) . "\n\$" . dFormat($tax1 + $subTotal1),
              
              (($subTotal2 != 0.0) ? "\$" . dFormat($ship2) : "") . "\n" . 
              (($subTotal2 != 0.0) ? "\$" . dFormat($subTotal2) : "") . "\n" . 
              (($subTotal2 != 0.0) ? "\$" . dFormat($tax2) : "") . "\n" . 
              (($subTotal2 != 0.0) ? "\$" . dFormat($tax2 + $subTotal2) : ""),
              
              (($subTotal3 != 0.0) ? "\$" . dFormat($ship3) : "") . "\n" . 
              (($subTotal3 != 0.0) ? "\$" . dFormat($subTotal3) : "") . "\n" . 
              (($subTotal3 != 0.0) ? "\$" . dFormat($tax3) : "") . "\n" . 
              (($subTotal3 != 0.0) ? "\$" . dFormat($tax3 + $subTotal3) : ""));
              
        $pdf->tableRow(fontSize => 8, fontID => $fontID,
                   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);

# blank line
        $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (""); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
        $pdf->tableRow(fontSize => 20, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);

    }
    
# report footer

    $colCount = 3;
    @colWidths = (147,212,187);
    @colAlign = ("left","left","left");
    $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    @colData = ("BASIS OF AWARD:", "REASONABLENESS OF PRICE BASED ON:", "OTHER:");
    $pdf->tableRow(fontSize => 7, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    @colData = (
        "[ ] Low Proposal\n[ ] Low Total Proposal\n[ ] Lowest Proposal Meeting Delivery\n[ ] Less than Competitive Requirement\n[ ] Noncompetitive Proprietary\n[ ] Noncompetitive Proprietary Repair\n[ ] Single/Sole Source (See Documentation)\n[ ] Other (See Documentation)", 
        "[ ] Competition\n[ ] Published/Catalog Price: \n   No. _______________________   Date: ____________________\n[ ] GSA/Federal Supply Schedule \n   No. _______________________   Expires: _____________\n[ ] Similar Prices to Previous P.O. \n   No. ____________________________________________ \n[ ] Cost Analysis of:  [ ]  Independent Cost Estimate or  [ ]  Cost Data\n[ ] Buyer’s Experience\n[ ] Comparative Analysis\n[ ] Similar but not identical items", 
        "Government Source of Supply Checked\n   [ ] Available   [ ]  Not Available\nDisadvantaged Business Set Aside\n   [ ] Yes  [ ] No Known Source\nSmall Business Set Aside\n   [ ] Yes  [ ] No Known Small Business Source\n[ ] No (Explain) ________________________\n\n   _____________________________________________");
    $pdf->tableRow(fontSize => 7, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    
# blank line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (""); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->tableRow(fontSize => 20, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);

# remarks
    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("left");
    $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    @colData = ("REMARKS:\n" . ((defined($pdCurrent{bidremarks}) && $pdCurrent{bidremarks} gt " ") ? $pdCurrent{bidremarks} : "\n\n\n\n\n"));
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);
    
# blank line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (""); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->tableRow(fontSize => 20, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);

    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("left");
    $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    @colData = ("BUYER CERTIFIES (TO THE BEST OF HIS/HER KNOWLEDGE) THIS INFORMATION TO BE TRUE AND CORRECT");
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    
# blank line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (""); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->tableRow(fontSize => 20, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);

    $colCount = 2;
    @colWidths = (281,281);
    @colAlign = ("left","left");
    $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    @colData = (
          "Buyer’s Signature_______________________________________\n\n\n\n\nSite Manager/Project\nManager Signature_______________________________________",
          "Date____________________________________________\n\n\n\n\n\nDate____________________________________________");
    $pdf->tableRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    

    
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
sub doSaveBidRemarks {  # routine to save remarks to the bid form
###################################################################################################################################
    my %args = (
        id => 0,
        reload => 'T',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";

    my $status = &doProcessSaveBidRemarks(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, 
              settings => \%settings);

    my $message = "Remarks Saved for bid $settings{prnumber}";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, logMessage => $message, type => 35);
    
    if ($args{reload} eq 'T') {
        $output .= "<script language=javascript><!--\n";
        $output .= "   $args{form}.id.value='$settings{prnumber}';\n";
        $output .= "   submitForm('$args{form}','bidsform');\n";
        $output .= "//--></script>\n";
    }


    return($output);
}


###################################################################################################################################
sub doBidAward {  # routine to award a bid to a vendor
###################################################################################################################################
    my %args = (
        pd => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";

    my $status = 0;
    $status = &doProcessBidAward(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, pd => $args{pd}, 
              settings => \%settings);
    my $pdf = &doBidAbstract(dbh => $args{dbh}, schema => $args{schema}, id => $args{pd}, forDisplay => 'F');
    $status = &addPDHistory(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, pd => $args{pd},
              archiveDescription => 'Bid Award', changes => 'Bid Award', pdf => $pdf);
    &doProcessAcceptPO(dbh => $args{dbh}, schema => $args{schema}, pd=>$args{pd}, userID => $settings{userid});
    $status = &doProcessBidAwardItemUpdate(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, pd => $args{pd}, 
              settings => \%settings);

    my $message = "Bid awarded for $settings{prnumber}";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, logMessage => $message, type => 36);
    
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('home','home');\n";
    $output .= "//--></script>\n";


    return($output);
}


###################################################################################################################################
sub doBidDelete {  # routine to delete bid data
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";

    my $status = &doProcessBidDelete(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, id => $args{id}, 
              settings => \%settings);

    my $message = "Bid on $settings{prnumber} deleted";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, logMessage => $message, type => 35);
    
    $output .= "<script language=javascript><!--\n";
    $output .= "   document.$args{form}.id.value = '$settings{prnumber}';\n";
    $output .= "   submitForm('$args{form}','bidsform');\n";
    $output .= "//--></script>\n";


    return($output);
}




###################################################################################################################################
###################################################################################################################################



1; #return true
