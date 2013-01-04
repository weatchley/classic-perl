# UI Home functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UIHome.pm,v $
#
# $Revision: 1.24 $
#
# $Date: 2009/07/31 22:43:26 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIHome.pm,v $
# Revision 1.24  2009/07/31 22:43:26  atchleyb
# Updates related to ACR0907_004-SWR0149   New intermediate buyer role, minor bug fixes
#
# Revision 1.23  2009/07/13 19:01:01  atchleyb
# Fix typo in purchaseing menu for roles selection
#
# Revision 1.22  2009/06/26 21:57:40  atchleyb
# ACR0906_001 - List of changes
#
# Revision 1.21  2009/05/29 21:35:51  atchleyb
# ACR0905_001 - user change request, multiple changes
#
# Revision 1.20  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.19  2006/05/17 23:18:55  atchleyb
# CR0026 cleaned up commented out code, replaced doebilled with clientbilled
#
# Revision 1.18  2006/03/27 19:10:09  atchleyb
# CR 0023 - updated to have new, simpler design for the purchaseing and receiving menues, simular to the accounts payable menu.
#
# Revision 1.17  2006/01/31 23:08:08  atchleyb
# CR 0022 - Added quantity ordered/received/outstanding to AP menues
#
# Revision 1.16  2005/08/18 19:23:55  atchleyb
# CR00015 - added logout button to home screen
#
# Revision 1.15  2005/06/13 15:59:20  atchleyb
# moved javascript function browsePD to common section
#
# Revision 1.14  2005/06/10 22:43:07  atchleyb
# CR0011
# added code to display users open PD's
#
# Revision 1.13  2005/05/27 19:56:11  atchleyb
# updated the isFinanceLead test to use site number rather than the site code from the prnumber
#
# Revision 1.12  2005/03/30 23:15:33  atchleyb
# fixed bug in testing status for AP approvals
#
# Revision 1.11  2005/02/10 00:49:42  atchleyb
# Updated for CR004, updated and simplified the AP menu
#
# Revision 1.10  2004/12/07 18:44:15  atchleyb
# added menu items for receiving and accounts payable
#
# Revision 1.9  2004/04/22 21:39:52  atchleyb
# Updates related to SCR 1 (add field briefdescription)
#
# Revision 1.8  2004/04/21 23:06:01  atchleyb
# Updated look and feel and added sorting
#
# Revision 1.7  2004/04/05 23:28:52  atchleyb
# added check for ammendedby in po selection
#
# Revision 1.6  2004/04/01 23:44:27  atchleyb
# updates required to handle PO processing
#
# Revision 1.5  2004/02/27 00:16:28  atchleyb
# added calls to improve lookup times
# made some areas site specific
#
# Revision 1.4  2004/01/08 17:18:19  atchleyb
# added code for accounts payable
#
# Revision 1.3  2003/12/15 18:47:37  atchleyb
# added code for receiving
#
# Revision 1.2  2003/12/02 16:48:17  atchleyb
# added code for bids
#
# Revision 1.1  2003/11/12 20:33:17  atchleyb
# Initial revision
#
#
#
#
#

package UIHome;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBUtilities qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use DBHome qw(:Functions);
use DBPurchaseDocuments qw(getPDByStatus getApprovalList getPDInfo);
use DBReceiving qw (getReceiving);
use DBBusinessRules qw (getRuleInfo);
use DBAccountsPayable qw(getAP getAPTotals);
use Text_Menus;
use Tie::IxHash;
use Tables;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
#use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getInitialValues       &doHeader             &doFooter
      &getTitle               &doMainMenu
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doFooter
      &getTitle               &doMainMenu
    )]
);

my $mycgi = new CGI;


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "Home";
   if ($args{command} eq "?") {
      $title = "Home";
   } elsif ($args{command} eq "?") {
      $title = "Home";
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
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "",
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
       apsort => (defined($mycgi->param("apsort"))) ? $mycgi->param("apsort") : "vendor",
       rcvsort => (defined($mycgi->param("rcvsort"))) ? $mycgi->param("rcvsort") : "vendor",
    ));
    $valueHash{title} = &getTitle(command => $valueHash{command});
    
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
    function doHome(script) {
      	$form.command.value = 'browse';
       	$form.action = '$path' + script + '.pl';
        $form.submit();
    }
    function submitForm3(script, command, type) {
        document.$form.command.value = command;
        document.$form.type.value = type;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function updatePR(id) {
        document.$form.id.value = id;
        submitForm('purchaseDocuments', 'updateprform');
    }
    function updatePO(id) {
        document.$form.id.value = id;
        submitForm('purchaseDocuments', 'updatepoform');
    }
    function acceptPO(id) {
        document.$form.id.value = id;
        submitForm('purchaseDocuments', 'acceptpo');
    }
    function placePO(id) {
        document.$form.id.value = id;
        submitForm('purchaseDocuments', 'placepoform');
    }
    function acceptPlacePO(id) {
        document.$form.id.value = id;
        submitForm('purchaseDocuments', 'acceptplacepoform');
    }
    function approvePD(id) {
        document.$form.id.value = id;
        submitForm('purchaseDocuments', 'approvepdform');
    }
    function acceptPR(id) {
        if(confirm('Accept ' + id + ' for processing as "Buyer"?')) {
            document.$form.id.value = id;
            submitForm('purchaseDocuments', 'acceptprforrfp');
        }
    }
    function updateRFP(id) {
        document.$form.id.value = id;
        submitForm('purchaseDocuments', 'updaterfpform');
    }
    function receiveBids(id) {
        document.$form.id.value = id;
        submitForm('bids', 'bidsform');
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
    function updateRLog(id) {
        document.$form.id.value = id;
        submitForm('receiving', 'updaterlogform');
    }
    function browseRLog(id) {
        document.$form.id.value = id;
        submitForm('receiving', 'browsereceiving');
    }
    function newRLogPO(id) {
        document.$form.id.value = id;
        submitForm('receiving', 'newrlogpo');
    }
    function newRLogNoPO() {
        if ($form.receivingsite[0].selected) {
            alert('You must select a site');
        } else {
            submitForm('receiving', 'newrlognopo');
        }
    }
    function newAP(id) {
        document.$form.id.value = id;
        submitForm('accountsPayable', 'newap');
    }
    function updateAP(id) {
        document.$form.id.value = id;
        submitForm('accountsPayable', 'updateapform');
    }
    function approveAP(id) {
        document.$form.id.value = id;
        submitForm('accountsPayable', 'approveapform');
    }
    function finalizeAP(id) {
        document.$form.id.value = id;
        submitForm('accountsPayable', 'finalizeapform');
    }
    function browseAP(id) {
        document.$form.id.value = id;
        submitForm('accountsPayable', 'browseap');
    }
    function closePO(id, po) {
        document.$form.id.value = id;
        if (confirm('Close Purchase Order ' + po + '?')) {
            submitFormCGIResults('accountsPayable', 'closepo');
            printPOInfo(id);
        }
    }

    function printPOInfo(id) {
        var myDate = new Date();
        var winName = myDate.getTime();
        document.$form.id.value = id;
        document.$form.action = '$args{path}' + 'purchaseDocuments.pl';
        document.$form.command.value = 'printpoinfo';
        document.$form.target = winName;
        var newwin = window.open('',winName);
        newwin.creator = self;
        document.$form.submit();
    }


function browsePD (id) {
    var msg = '';
    $args{form}.id.value=id;
    submitForm('purchaseDocuments', 'displaypd');
}

function showHidePOSection(pr) {
    var code = ""
        +"if (" + pr + ".style.display=='none') {\\n"
        +"    " + pr + ".style.display='';\\n"
        +"} else {\\n"
        +"    " + pr + ".style.display='none';\\n"
        +"}\\n"
        + "";
    eval(code);
}

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


END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'T', includeJSWidgets => 'F');
    
    $output .= "<input type=hidden name=type value=0>\n";
    #$output .= "<input type=hidden name=server value=$Server>\n";
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
    
    $output .= &doStandardFooter();

    return($output);
}


###################################################################################################################################
sub doMainMenu {  # routine to generate main home page menu
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = '';
    my $text = "";
    my $text2 = "";
    my $count = 0;
    my $count2 = 0;
    
    my @sites = &getSiteInfoArray(dbh=>$args{dbh}, schema=>$args{schema});

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
<div id="remarkEditWindow" class="float1" style="display:'none';">
<table border=0 cellpadding=0 cellspacing=0>
<tr bgcolor=#eeeeee><td align=center><b>Enter Remark</b></td></tr>
<tr><td>
<textarea name=remarks cols=80 rows=6></textarea><br>
<a href="javascript:doAddRemark();closeAllFloatingWindows();">Accept</a> &nbsp;
<a href="javascript:resetRemark();">Reset</a> &nbsp;
<!--a href="javascript:closeAllFloatingWindows();document.$args{form}.remarks.value='0';document.$args{form}.id.value='0';">Cancel</a-->
<a href="javascript:closeAllFloatingWindows();resetRemark();">Cancel</a>
</td></tr></table>
</div>

<script language=javascript><!--

// Checks if the browsers is IE or another.
// document.all will return true or false depending if its IE
// If its not IE then it adds the mouse event
if (!document.all)
document.captureEvents(Event.MOUSEMOVE)

// On the move of the mouse, it will call the function getPosition
document.onmousemove = getPosition;

// These varibles will be used to store the position of the mouse
var X = 0
var Y = 0

// This is the function that will set the position in the above varibles 
function getPosition(args) 
{
  // Gets IE browser position
  if (document.all) 
  {
    X = event.clientX + document.body.scrollLeft
    Y = event.clientY + document.body.scrollTop
  }
  
  // Gets position for other browsers
  else 
  {  
    X = args.pageX
    Y = args.pageY
  }  
}


function resetRemark() {
    document.$args{form}.remarks.value = "";
}

function addRemark(id,e) {
    document.$args{form}.id.value = id;
    section = document.getElementById('remarkEditWindow');
    section.style.top = Y;
    section.style.display='';

    //alert('Not yet ready');
}

function doAddRemark() {
    if (!isblank(document.$args{form}.remarks.value)) {
        submitFormCGIResults('purchaseDocuments', 'dosavepdremark');
    }
    //alert('Not yet ready');
}

    function closeAllFloatingWindows() {
        section = document.getElementById('remarkEditWindow');
        section.style.display='none';
    }

    closeAllFloatingWindows();

//--></script>


<!-- *************************** End Floating Window Section *************************** -->

END_OF_BLOCK


    $output .= "<table border=0 align=center>\n";
# links/commands
    $output .= "<tr><td><b><a href=javascript:submitForm('purchaseDocuments','addprform')>New PR</a></b> &nbsp; &nbsp;</td>\n";
    $output .= "<td><b><a href=javascript:submitForm('purchaseDocuments','copyprform')>New PR copied from an old PR</a></b></td>\n";
    $output .= "<td><b><a href=\"javascript:submitFormCGIResults('logout','logout');\">Logout</a></b></tr>\n";
# My open PDs
    $text = "<table cellpadding=0 cellspacing=0 border=1>\n";
    $text .= "<tr bgcolor=#a0e0c0><td><b>PR/PO</b></td><td><b>Description</b></td><td><b>Author/Requester</b></td><td><b>Status</b></td></tr>\n";
    $count = 0;
    my @PDList = &getPDByStatus(dbh=>$args{dbh}, schema=>$args{schema}, orderBy=>"briefdescription", statusList=>"1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18", authorOrRequester=>$args{userID});
    my $myName = &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID});
    for (my $i=0; $i < $#PDList; $i++) {
        $text .= "<tr bgcolor=#ffffff>";
        $text .= "<td width=5><a href=\"javascript:browsePD('$PDList[$i]{prnumber}')\">$PDList[$i]{prnumber}". ((defined($PDList[$i]{ponumber})) ? " / $PDList[$i]{ponumber}" : "") . "</a></td>";
        $text .= "<td>$PDList[$i]{briefdescription}</td>";
        $text .= "<td>" . (($args{userID} == $PDList[$i]{author}) ? "$myName" : &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$PDList[$i]{author})) . " / <br>";
        $text .= (($args{userID} == $PDList[$i]{requester}) ? "$myName" : &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$PDList[$i]{requester})) . "</td>";
        $text .= "<td>$PDList[$i]{statusname}</td></tr>\n";
        $count++;
    }
    @PDList = &getPDByStatus(dbh=>$args{dbh}, schema=>$args{schema}, orderBy=>"briefdescription", statusList=>"1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18", buyer=>$args{userID});
    if ($#PDList > 0) {
        $text .= "<tr bgcolor=#c0f0e0><td colspan=4><b>Purchase Documents I am Buyer for...</b></td></tr>\n";
        for (my $i=0; $i < $#PDList; $i++) {
            $text .= "<tr bgcolor=#ffffff>";
            $text .= "<td width=5><a href=\"javascript:browsePD('$PDList[$i]{prnumber}')\">$PDList[$i]{prnumber}". ((defined($PDList[$i]{ponumber})) ? " / $PDList[$i]{ponumber}" : "") . "</a></td>";
            $text .= "<td>$PDList[$i]{briefdescription}</td>";
            $text .= "<td>" . (($args{userID} == $PDList[$i]{author}) ? "$myName" : &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$PDList[$i]{author})) . " / <br>";
            $text .= (($args{userID} == $PDList[$i]{requester}) ? "$myName" : &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$PDList[$i]{requester})) . "</td>";
            $text .= "<td>$PDList[$i]{statusname}</td></tr>\n";
            $count++;
        }
    }
    $text .= "</table>\n";
    $output .= "<tr><td colspan=3>" . &buildSectionBlock(title=> "<b>Browse My Open Purchase Documents</b> ($count)", contents=>$text) . "</td></tr>\n";
# new/update PRs
    $text = "<table border=0>\n";
    $count = 0;
    my @PRList = &getPDByStatus(dbh=>$args{dbh}, schema=>$args{schema}, statusList=>"1, 2", author=>$args{userID});
    for (my $i=0; $i < $#PRList; $i++) {
        $text .= "<tr><td><a href=\"javascript:updatePR('$PRList[$i]{prnumber}')\">$PRList[$i]{prnumber} - $PRList[$i]{briefdescription}</a></td></tr>\n";
        $count++;
    }
    @PRList = &getPDByStatus(dbh=>$args{dbh}, schema=>$args{schema}, statusList=>"1, 2", requester=>$args{userID}, notRequesterAuthorMatch => 'T');
    for (my $i=0; $i < $#PRList; $i++) {
        $text .= "<tr><td><a href=\"javascript:updatePR('$PRList[$i]{prnumber}')\">$PRList[$i]{prnumber} - $PRList[$i]{briefdescription}</a></td></tr>\n";
        $count++;
    }
    $text .= "</table>\n";
    $output .= "<tr><td colspan=3>" . &buildSectionBlock(title=> "<b>Purchase Requests in Initial or Updating status</b> ($count)", contents=>$text) . "</td></tr>\n";
# pending approvals
    $text = "<table border=0>\n";
    $count = 0;
    my @approvals = &getApprovalList(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID});
    for (my $i=0; $i < $#approvals; $i++) {
        $text .= "<tr><td><a href=\"javascript:approvePD('$approvals[$i]{prnumber}')\">$approvals[$i]{prnumber}";
        $text .= ((defined($approvals[$i]{ponumber})) ? " / $approvals[$i]{ponumber}" . 
                   ((defined($approvals[$i]{amendment})) ? $approvals[$i]{amendment} : "") : "");
        $text .= "</a> - $approvals[$i]{briefdescription}</td></tr>\n";
        $count++;
    }
    $text .= "</table>\n";
    $output .= "<tr><td colspan=3>" . &buildSectionBlock(title=> "<b>Pending Approvals</b> ($count)", contents=>$text) . "</td></tr>\n";
# buyer section
    if (&doesUserHaveRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[7, 6, 21, 22])) {
        @PDList = ();
        my $pdCount = 0;
        $text2 = "<table border=0>\n";
        $count2 = 0;
        #
        $count = 0;
        @PRList = &getPRsForRFP(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID});
        for (my $i=0; $i <= $#PRList; $i++) {
#print STDERR "$PRList[$i]{prnumber}, Priority:$PRList[$i]{priority}\n";
            $PDList[$pdCount]{prnumber} = $PRList[$i]{prnumber};
            $PDList[$pdCount]{ponumber} = "&nbsp;";
            $PDList[$pdCount]{priority} = $PRList[$i]{priority};
            $PDList[$pdCount]{jscommand} = "acceptPR";
            $PDList[$pdCount]{popr} = (($PRList[$i]{priority} eq 'T') ? "a " : "z ") . " / $PRList[$i]{prnumber}";
            $PDList[$pdCount]{description} = $PRList[$i]{briefdescription};
            $PDList[$pdCount]{vendor} = "n/a";
            $PDList[$pdCount]{status} = "Approved PR ready for RFP";
            $PDList[$pdCount]{dollarvalue} = $PRList[$i]{dollarvalue};
            $pdCount++;
            $count++;
        }
        $count2 += $count;
        #
        $count = 0;
        @PRList = &getPDByStatus(dbh=>$args{dbh}, schema=>$args{schema}, statusList=>"5, 7, 9", buyer=>$args{userID});
        for (my $i=0; $i < $#PRList; $i++) {
            $PDList[$pdCount]{prnumber} = $PRList[$i]{prnumber};
            $PDList[$pdCount]{ponumber} = "&nbsp;";
            $PDList[$pdCount]{priority} = $PRList[$i]{priority};
            $PDList[$pdCount]{popr} = (($PDList[$pdCount]{priority} eq 'T') ? "a " : "z ") . " / $PRList[$i]{prnumber}";
            $PDList[$pdCount]{description} = $PRList[$i]{briefdescription};
            $PDList[$pdCount]{vendor} = "n/a";
            $PDList[$pdCount]{status} = "Pending RFP";
            $PDList[$pdCount]{dollarvalue} = $PRList[$i]{total};
            if ($PRList[$i]{status} != 5) {
                $PDList[$pdCount]{jscommand} = "updateRFP";
            } else {
                $PDList[$pdCount]{jscommand} = "updatePR";
            }
            $pdCount++;
            $count++;
        }
        $count2 += $count;
        #
        $count = 0;
        @PRList = &getPDByStatus(dbh=>$args{dbh}, schema=>$args{schema}, statusList=>"10", buyer=>$args{userID});
        for (my $i=0; $i < $#PRList; $i++) {
            $PDList[$pdCount]{prnumber} = $PRList[$i]{prnumber};
            $PDList[$pdCount]{ponumber} = "&nbsp;";
            $PDList[$pdCount]{priority} = $PRList[$i]{priority};
            $PDList[$pdCount]{jscommand} = "receiveBids";
            $PDList[$pdCount]{popr} = (($PDList[$pdCount]{priority} eq 'T') ? "a " : "z ") . " / $PRList[$i]{prnumber}";
            $PDList[$pdCount]{description} = $PRList[$i]{briefdescription};
            $PDList[$pdCount]{vendor} = "n/a";
            $PDList[$pdCount]{status} = "RFP Ready to receive/modify Bids<br>$PRList[$i]{statusname}";
            $PDList[$pdCount]{dollarvalue} = $PRList[$i]{total};
            $pdCount++;
            $count++;
        }
        my $siteList = &sitesUserHasRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[7, 6, 21, 22]);
        $count2 += $count;
        #
        $count = 0;
        @PRList = &getPDByStatus(dbh=>$args{dbh}, schema=>$args{schema}, statusList=>"11, 12, 16", siteList=>$siteList, getVendor=>'T');
        for (my $i=0; $i < $#PRList; $i++) {
            if (defined($PRList[$i]{buyer}) && ($PRList[$i]{buyer}== $args{userID} || 
                   (defined($PRList[$i]{amendedby}) && $PRList[$i]{amendedby}== $args{userID}))) {
                $PDList[$pdCount]{prnumber} = $PRList[$i]{prnumber};
                $PDList[$pdCount]{ponumber} = $PRList[$i]{ponumber} . ((defined($PRList[$i]{amendment})) ? $PRList[$i]{amendment} : "");
                $PDList[$pdCount]{priority} = $PRList[$i]{priority};
                $PDList[$pdCount]{jscommand} = "updatePO";
                $PDList[$pdCount]{popr} = (($PDList[$pdCount]{priority} eq 'T') ? "a " : "z ") . " / $PRList[$i]{prnumber}";
                $PDList[$pdCount]{description} = $PRList[$i]{briefdescription};
                $PDList[$pdCount]{vendor} = $PRList[$i]{vendorName};
                $PDList[$pdCount]{status} = "PO ready to continue processing";
                $PDList[$pdCount]{dollarvalue} = $PRList[$i]{total};
                $pdCount++;
                $count++;
            } elsif (!defined($PRList[$i]{buyer})) {
                $PDList[$pdCount]{prnumber} = $PRList[$i]{prnumber};
                $PDList[$pdCount]{ponumber} = $PRList[$i]{ponumber} . ((defined($PRList[$i]{amendment})) ? $PRList[$i]{amendment} : "");
                $PDList[$pdCount]{priority} = $PRList[$i]{priority};
                $PDList[$pdCount]{jscommand} = "acceptPO";
                $PDList[$pdCount]{popr} = (($PDList[$pdCount]{priority} eq 'T') ? "a " : "z ") . " / $PRList[$i]{prnumber}";
                $PDList[$pdCount]{description} = $PRList[$i]{briefdescription};
                $PDList[$pdCount]{vendor} = $PRList[$i]{vendorName};
                $PDList[$pdCount]{status} = "PO ready to process";
                $PDList[$pdCount]{dollarvalue} = $PRList[$i]{total};
                $pdCount++;
                $count++;
            }
        }
        $count2 += $count;
        #
        $count = 0;
        @PRList = &getPDByStatus(dbh=>$args{dbh}, schema=>$args{schema}, statusList=>"15", noBuyer=>'T', siteList=>$siteList, getVendor=>'T');
        for (my $i=0; $i < $#PRList; $i++) {
            $PDList[$pdCount]{prnumber} = $PRList[$i]{prnumber};
            $PDList[$pdCount]{ponumber} = $PRList[$i]{ponumber} . ((defined($PRList[$i]{amendment})) ? $PRList[$i]{amendment} : "");
            $PDList[$pdCount]{priority} = $PRList[$i]{priority};
            $PDList[$pdCount]{jscommand} = "acceptPlacePO";
            $PDList[$pdCount]{popr} = (($PDList[$pdCount]{priority} eq 'T') ? "a " : "z ") . " / $PRList[$i]{prnumber}";
            $PDList[$pdCount]{description} = $PRList[$i]{briefdescription};
            $PDList[$pdCount]{vendor} = $PRList[$i]{vendorName};
            $PDList[$pdCount]{status} = "Blanket Release / Delivery Order ready to place";
            $PDList[$pdCount]{dollarvalue} = $PRList[$i]{total};
            $pdCount++;
            $count++;
        }
        $count2 += $count;
        #
        $count = 0;
        @PRList = &getPDByStatus(dbh=>$args{dbh}, schema=>$args{schema}, statusList=>"15", buyer=>$args{userID}, getVendor=>'T');
        for (my $i=0; $i < $#PRList; $i++) {
            $PDList[$pdCount]{prnumber} = $PRList[$i]{prnumber};
            $PDList[$pdCount]{ponumber} = $PRList[$i]{ponumber} . ((defined($PRList[$i]{amendment})) ? $PRList[$i]{amendment} : "");
            $PDList[$pdCount]{priority} = $PRList[$i]{priority};
            $PDList[$pdCount]{jscommand} = "placePO";
            $PDList[$pdCount]{popr} = (($PDList[$pdCount]{priority} eq 'T') ? "a " : "z ") . " / $PRList[$i]{prnumber}";
            $PDList[$pdCount]{description} = $PRList[$i]{briefdescription};
            $PDList[$pdCount]{vendor} = $PRList[$i]{vendorName};
            $PDList[$pdCount]{status} = "PO ready to place";
            $PDList[$pdCount]{dollarvalue} = $PRList[$i]{total};
            $pdCount++;
            $count++;
        }
        $count2 += $count;
        
##--
        
        $text2 .= "<tr><td colspan=2>\n";
        $text2 .= "<table border=1 cellspacing=0>\n";
        $text2 .= "<tr bgcolor=#a0e0c0><td align=center valign=bottom><b>PR / PO</b></td>";
        $text2 .= "<td align=center valign=bottom><b>Vendor</b></td><td align=center valign=bottom><b>Description</b></td>";
        $text2 .= "<td align=center valign=bottom><b>Dollar Value</b></td><td align=center valign=bottom><b>Status</b></td></tr>\n";
        my $sortField = "popr";
        @PDList = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @PDList;
        for (my $i=0; $i < $pdCount; $i++) {
            $text2 .= "<tr bgcolor=#ffffff>\n";
            $text2 .= "<td valign=top>" . (($PDList[$i]{priority} eq 'T') ? "*" : "") . "<a href=\"javascript:$PDList[$i]{jscommand}('$PDList[$i]{prnumber}')\">$PDList[$i]{prnumber} / $PDList[$i]{ponumber}</a><br>";
            $text2 .= "<div valign=top style=\"font-size: 8pt; text-align: right;\"><a href=\"javascript:browsePD('$PDList[$i]{prnumber}')\">Browse</div></td>";
            $text2 .= "<td valign=top>$PDList[$i]{vendor}</td><td valign=top>$PDList[$i]{description}</td>\n";
            $text2 .= "<td valign=top align=right>" . dollarFormat($PDList[$i]{dollarvalue}) . "</td><td valign=top>$PDList[$i]{status}</td>\n";
            $text2 .= "</tr>\n";
        }
        
        $text2 .= "</table>\n";
        $text2 .= "</td></tr>\n";
        
        $text2 .= "</table>\n";
        $output .= "<tr><td colspan=3>" . &buildSectionBlock(title=> "<b>Purchasing</b> ($count2)", contents=>$text2) . "</td></tr>\n";
    }
# receiving
    if (&doesUserHaveRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[10])) {
        my $text3 = "";
        $text2 = "<table border=0>\n";
        my @sites = &getSiteInfoArray(dbh=>$args{dbh}, schema=>$args{schema});
        $text2 .= "<tr><td colspan=2><b>Receive items without a Purchase Order:\n";
        $text2 .= "<select name=receivingsite size=1><option value=0 selected>Select a Site</option>\n";
        for (my $i=1; $i<=$#sites; $i++) {
            $text2 .= "<option value=$i>$sites[$i]{name}</option>\n";
        }
        $text2 .= "</select>\n";
        $text2 .= "<a href=\"javascript:newRLogNoPO()\">Go</a></b></td></tr>\n";
#
        $text2 .= "<tr><td colspan=2><table border=1 cellspacing=0 cellpadding=0>\n";
        $text2 .= "<ReplaceThisWithNewContent>\n";
        $text2 .= "</table></td></tr>\n";
        $count2 = 0;
        my $siteList = &sitesUserHasRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[10]);
        my @siteArray = &sitesUserHasRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[10], asTextArray=>'T');
        $count = 0;
        my @rLog = &getReceiving(dbh=>$args{dbh}, schema=>$args{schema}, isOpen=>'T', siteList=>\@siteArray);
        @rLog = sort { ((defined($a->{ponumber})) ? $a->{ponumber} : "") cmp ((defined($b->{ponumber})) ? $b->{ponumber} : "") || $a->{id} cmp $b->{id} } @rLog;
        my %rLogCounts;
        for (my $i=1; $i<=$#rLog; $i++) {
            if (defined($rLog[$i]{prnumber})) {
                $rLogCounts{$rLog[$i]{prnumber}} = ((defined($rLogCounts{$rLog[$i]{prnumber}})) ? 1 : $rLogCounts{$rLog[$i]{prnumber}}++)
            }
        }
        
        #$output .= "Purchase Documents with pending Receiving:<br>\n";
        $count2 += $count;
        $text = "<table border=0>\n";
        $text .= "<tr><td align=center><b>Sort by: &nbsp; ";
        $text .= "<input type=radio name=rcvsort value='ponumber'" . (($settings{rcvsort} eq "ponumber") ? " checked" : "") . ">PO Number &nbsp; ";
        $text .= "<input type=radio name=rcvsort value='vendor'" . (($settings{rcvsort} eq "vendor") ? " checked" : "") . ">Vendor &nbsp; ";
        $text .= " &nbsp; <input type=button name=rcvsortbutton value='Refresh' onClick=submitForm('$args{form}')></td></tr>\n";
        $text .= "</table>\n";
        $text .= "<table border=1 cellspacing=0 style=\"font-size: 11pt;\">\n";
        $text .= "<tr bgcolor=#a0e0c0><td align=center valign=bottom><b>PO</b></td>";
        $text .= "<td align=center valign=bottom><b>Vendor</b></td><td align=center valign=bottom><b>Description</b></td>";
        $text .= "<td align=center valign=bottom><b>Ordered/\nReceived</b></td><td align=center valign=bottom><b>Status</b></td></tr>\n";
        $count = 0;
        my @PDList = &getPDByStatus(dbh=>$args{dbh}, schema=>$args{schema}, statusList=>('17, 18'), siteList=>$siteList, getVendor=>'T', 
              receivingCount=>'T', orderCount=>'T');
        my $sortField = (($settings{rcvsort} eq 'ponumber') ? 'ponumber' : 'vendorName');
        @PDList = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @PDList;
        for (my $i=1; $i <= $#PDList; $i++) {
            if ($PDList[$i]{status} == 17 || ($PDList[$i]{status} == 18 && $PDList[$i]{orderCount} > $PDList[$i]{receivingCount}) ||
                    (defined($rLogCounts{$PDList[$i]{prnumber}}) && $rLogCounts{$PDList[$i]{prnumber}} > 0)) {
                #$text .= "<tr bgcolor=#ffffff><td valign=top><a href=\"javascript:newRLogPO('$PDList[$i]{prnumber}')\">$PDList[$i]{ponumber}" . 
                $text .= "<tr bgcolor=#ffffff><td valign=top><a href=\"javascript:showHidePOSection('$PDList[$i]{prnumber}rec')\">$PDList[$i]{ponumber}" . 
                        ((defined($PDList[$i]{amendment})) ? $PDList[$i]{amendment} : "") . "</a><br>";
                $text .= "<div valign=top style=\"font-size: 8pt; text-align: right;\"><a href=\"javascript:newRLogPO('$PDList[$i]{prnumber}')\">New Log Entry</a></div></td>";
                $text .= "<td valign=top>$PDList[$i]{vendorName}</td><td valign=top>$PDList[$i]{briefdescription}</td>";
                $text .= "<td valign=top align=center>$PDList[$i]{orderCount}/$PDList[$i]{receivingCount}</td>\n";
                $text .= "<td valign=top>$PDList[$i]{statusname}</td></tr>\n";
                $count++;
##--
                $text .= "<tr bgcolor=#ffffff><td colspan=5>\n";
                $text .= "<div id='$PDList[$i]{prnumber}rec' style=\"display:'none'\">";
                $text .= "<table border=1 cellspacing=0 width=100% style=\"font-size: 10pt;\">\n";
                $text .= "<tr bgcolor=#00ffff><td colspan=4 align=center><div style=\"font-size: 12pt;\"><b>";
                $text .= "<a href=\"javascript:newRLogPO('$PDList[$i]{prnumber}')\">Enter New Receiving Log Entry</a> &nbsp; | &nbsp; ";
                $text .= "<a href=\"javascript:browsePD('$PDList[$i]{prnumber}')\">Browse PO</a></div></td></tr>\n";
                $text .= "<tr bgcolor=#ffff00><td align=center valign=bottom><b>Log ID</b></td><td align=center valign=bottom><b>Date Received</b></td>";
                $text .= "<td align=center valign=bottom><b>Delivered To</b></td><td align=center valign=bottom><b>Date Delivered</b></td></tr>";
                my @rLog2 = &getReceiving(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$PDList[$i]{prnumber});
                for (my $j=0; $j<$#rLog2; $j++) {
                    my $jsCommand = ((defined($rLog2[$j]{deliveredto}) && defined($rLog2[$j]{datedelivered})) ? "browseRLog" : "updateRLog");
                    $text .= "<tr><td><a href=\"javascript:" . $jsCommand . "('$rLog2[$j]{id}')\">$rLog2[$j]{id}</a></td>";
                    $text .= "<td>$rLog2[$j]{datereceived}</td>";
                    $text .= "<td>" . ((defined($rLog2[$j]{deliveredto})) ? $rLog2[$j]{deliveredto} : "&nbsp;") . "</td>";
                    $text .= "<td>" . ((defined($rLog2[$j]{datedelivered})) ? $rLog2[$j]{datedelivered} : "&nbsp;") . "</td></tr>\n";
                }
                for (my $j=0; $j<$#rLog; $j++) {
                    if (defined($rLog[$j]{prnumber}) && $rLog[$j]{prnumber} eq $PDList[$i]{prnumber}) {
                        $rLog[$j]{status} = 'used';
                    }
                }
                
                $text .= "</table>\n";
                $text .= "</div></td></tr>\n";
                
            }
        }
##--
        $text3 .= "<tr bgcolor=#dddddd><td colspan=5><a href=\"javascript:showHidePOSection('NoPOrec')\">";
        $text3 .= "Open 'Receiving Log' entries for items with closed or no Purchase Order</a> <noPOCount></td></tr>\n";
        $text3 .= "<tr bgcolor=#ffffff><td colspan=5>\n";
        $text3 .= "<div id='NoPOrec' style=\"display:'none'\">";
        $text3 .= "<table border=1 cellspacing=0 width=100% style=\"font-size: 10pt;\">\n";
        $text3 .= "<tr bgcolor=#ffff00><td align=center valign=bottom><b>Log ID</b></td><td align=center valign=bottom><b>PO Number</b></td>";
        $text3 .= "<td align=center valign=bottom><b>Date Received</b></td><td align=center valign=bottom><b>Delivered To</b></td>";
        $text3 .= "<td align=center valign=bottom><b>Date Delivered</b></td></tr>";
        my $noPOCount = 0;
        for (my $i=1; $i<=$#rLog; $i++) {
            if ($rLog[$i]{status} ne 'used') {
                my $jsCommand = ((defined($rLog[$i]{deliveredto}) && defined($rLog[$i]{datedelivered})) ? "browseRLog" : "updateRLog");
                $text3 .= "<tr><td><a href=\"javascript:" . $jsCommand . "('$rLog[$i]{id}')\">$rLog[$i]{id}</a></td>";
                $text3 .= "<td>" . ((defined($rLog[$i]{ponumber})) ? $rLog[$i]{ponumber} : "&nbsp;") . 
                          ((defined($rLog[$i]{amendment})) ? $rLog[$i]{amendment} : "") . "</td>";
                $text3 .= "<td>$rLog[$i]{datereceived}</td>";
                $text3 .= "<td>" . ((defined($rLog[$i]{deliveredto})) ? $rLog[$i]{deliveredto} : "&nbsp;") . "</td>";
                $text3 .= "<td>" . ((defined($rLog[$i]{datedelivered})) ? $rLog[$i]{datedelivered} : "&nbsp;") . "</td></tr>\n";
                $noPOCount++;
            }
        }
        $text3 =~ s/<noPOCount>/($noPOCount)/;
        $text3 .= "</table>\n";
        $text3 .= "</div></td></tr>\n";
        
        $text .= "</table>\n";
        
        $text2 .= "<tr><td colspan=2>$text</td></tr>\n";
        
        $text2 =~ s/<ReplaceThisWithNewContent>/$text3/;
        $count2 += $count;
        $text2 .= "</table>\n";
        $output .= "<tr><td colspan=3>" . &buildSectionBlock(title=> "<b>Receiving</b> ($count2)", contents=>$text2) . "</td></tr>\n";
        
        
    }
# accounts payable
    my @apStatus = ("", "Initial", "Approval Pending", "Approved", "Closed");
    if (&doesUserHaveRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[1, 4])) {
        $text2 = "<table border=0>\n";
        $text2 .= "<tr><td align=center><b>Sort by: &nbsp; ";
        $text2 .= "<input type=radio name=apsort value='ponumber'" . (($settings{apsort} eq "ponumber") ? " checked" : "") . ">PO Number &nbsp; ";
        $text2 .= "<input type=radio name=apsort value='vendor'" . (($settings{apsort} eq "vendor") ? " checked" : "") . ">Vendor &nbsp; ";
        $text2 .= "<input type=radio name=apsort value='refnumber'" . (($settings{apsort} eq "refnumber") ? " checked" : "") . ">Ref # &nbsp; ";
        $text2 .= " &nbsp; <input type=button name=apsortbutton value='Refresh' onClick=submitForm('$args{form}')></td></tr>\n";
        $count2 = 0;
        my $siteList = &sitesUserHasRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[1, 4]);
        $text = "<table border=1 cellspacing=0>\n";
        $text .= "<tr bgcolor=#a0e0c0><td align=center valign=bottom><b>PO</b></td><td align=center valign=bottom width=90><b>Ref #</b></td>";
        $text .= "<td align=center valign=bottom><b>Vendor</b></td><td align=center valign=bottom><b>Status</b></td>";
        $text .= "<td align=center valign=bottom><b>Balance</b></td><td align=center valign=bottom><b>Open<br>Invoices</b></td>";
        my $isUserFinanceLead = &doesUserHaveRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, site=>0, roleList=>[4]);
        if ($isUserFinanceLead) {
            $text .= "<td align=center valign=bottom><b>Approvals</b></td>";
        }
        $text .= "</tr>\n";
        $count = 0;
        my @PDList = &getPDByStatus(dbh=>$args{dbh}, schema=>$args{schema}, statusList=>('17, 18'), siteList=>$siteList, orderBy=>'ponumber',
              getVendor=>'T', receivingCount => 'T', orderCount => 'T');
        #my $sortField = (($settings{apsort} eq 'ponumber') ? 'ponumber' : 'vendorName');
        my $sortField = "";
        if ($settings{apsort} eq 'ponumber') {
            $sortField = "ponumber";
        } elsif ($settings{apsort} eq 'vendor') {
            $sortField = "vendorName";
        } elsif ($settings{apsort} eq 'refnumber') {
            $sortField = "refnumbpo";
        }
        @PDList = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @PDList;
        my @siteArray = &sitesUserHasRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[1, 4], asTextArray=>'T');
        my @sitesFinaceLeadArray = &sitesUserHasRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[4], asNumArray=>'T');
        my @sitesAPAArray = &sitesUserHasRole(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, roleList=>[1], asTextArray=>'T');
        my @rLog = &getReceiving(dbh=>$args{dbh}, schema=>$args{schema}, isOpen=>'T');
        my @jsFunctions = ("", "updateAP", "approveAP", "finalizeAP", "browseAP");
        my %taxPaidVals = ('F'=>'Use Tax', 'T'=>'Sales Tax', 'NA'=>'N/A');
        for (my $i=1; $i<=$#PDList; $i++) {
            $count++;
            my $isFinanceLead = 'F';
            my %pd = &getPDInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$PDList[$i]{prnumber});
            for (my $j=0; $j<=$#sitesFinaceLeadArray; $j++) {
                if ($pd{site} == $sitesFinaceLeadArray[$j]) {$isFinanceLead = 'T'};
            }
            my $closeText = '';
            my $canBeClosed = 'F';
            if ($isFinanceLead eq 'T') {
                my %rule = &getRuleInfo(dbh=>$args{dbh}, schema=>$args{schema}, type=>5, site=>$PDList[$i]{site});
                my ($apTax, $apAmount, $allClosed) = &getAPTotals(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$PDList[$i]{prnumber}, status=>4);
                my $diff = ($pd{total}) - (((defined($apTax)) ? $apTax : 0) + ((defined($apAmount)) ? $apAmount : 0));
                my $lowerThreshold = $pd{total} * ($rule{nvalue1}/100.);
                if ($diff <= $lowerThreshold && $allClosed eq 'T' && $pd{status} == 18) {
                    $closeText .= " &nbsp; | &nbsp; <a href=\"javascript:closePO('$PDList[$i]{prnumber}', '$PDList[$i]{ponumber}')\">";
                    $closeText .= "Can be Closed (<font size=-1>" . dollarFormat($diff) . " of " . dollarFormat($pd{total}) . " remaining</font>)</a>";
                    $canBeClosed = 'T';
                } else {
                    $closeText .= "&nbsp;";
                }
                
            }
            $text .= "<tr bgcolor=#ffffff><td><a href=\"javascript:showHidePOSection('$PDList[$i]{prnumber}')\">$PDList[$i]{ponumber}" . 
                    ((defined($PDList[$i]{amendment})) ? $PDList[$i]{amendment} : "") . (($canBeClosed eq 'T') ? " *" : "") . "</a></td><td>". ((defined($PDList[$i]{refnumber})) ? $PDList[$i]{refnumber} : "&nbsp;") . 
                    "</td><td>$PDList[$i]{vendorName}</td><td>$PDList[$i]{statusname}";
            my $balance = $pd{chargedistAmount} - ((defined($pd{chargedistInvoiced})) ? $pd{chargedistInvoiced} : 0);
            $text .= "</td><td align=right>" . dollarFormat($balance) . "</td><td align=center><OpenInvCount>";
            if ($isFinanceLead eq 'T') {
                $text .= "</td><td align=center>";
                $text .= "<OpenAppCount>";
            }
            $text .= "</td></tr>\n";
            $text .= "<tr cellpadding=0 bgcolor=#ffffff><td cellpadding=0 colspan=" . (($isUserFinanceLead) ? "6" : "5") . ">";
            $text .= "<div id='$PDList[$i]{prnumber}' style=\"display:'none'\">";
            $text .= "<table border=1 cellspacing=0 width=100% style=\"font-size: 10pt;\">\n";
            $text .= "<tr bgcolor=#00ffff><td colspan=9 align=center><div style=\"font-size: 11pt;\"><b>";
            $text .= "<a href=\"javascript:newAP('$PDList[$i]{prnumber}')\">Enter New Invoice</a> &nbsp; | &nbsp; ";
            $text .= "<a href=\"javascript:addRemark('$PDList[$i]{prnumber}', event)\">Add Remark</a> &nbsp; | &nbsp; ";
            $text .= "<a href=\"javascript:browsePD('$PDList[$i]{prnumber}')\">Browse PO</a> &nbsp; | &nbsp; ";
            $text .= "<a href=\"javascript:printPO('$PDList[$i]{prnumber}')\">Print PO</a>$closeText</b></div><br>";
            $text .= "Item Quantity Ordered: $PDList[$i]{orderCount} / Received: $PDList[$i]{receivingCount} / Outstanding: ";
            $text .= ($PDList[$i]{orderCount} - $PDList[$i]{receivingCount}) . "</td>";
            $text .= "</tr>\n";
            my @ap = &getAP(dbh=>$args{dbh}, schema=>$args{schema}, pd=>$pd{prnumber}, orderBy=>'i.datereceived');
            $text .= "<tr bgcolor=#ffff00><td align=center valign=bottom><b>ID / Invoice</b></td>";
            $text .= "<td align=center valign=bottom><b>Input by</b></td><td align=center valign=bottom><b>Charge #</b></td>";
            $text .= "<td align=center valign=bottom><b>EC</b></td>";
            $text .= "<td align=center valign=bottom><b>Subtotal</b></td><td align=center valign=bottom><b>Tax</b></td>";
            $text .= "<td align=center valign=bottom><b>Total</b></td><td align=center valign=bottom><b>Paid / ";
            $text .= "Billed</b></td><td align=center valign=bottom><b>Status</b></td>";
            $text .= "</tr>\n";
            my $openCount = 0;
            my $approvalCount = 0;
            #$count = 0;
            for (my $i=0; $i<$#ap; $i++) {
                my $name = (($ap[$i]{enteredby} > 0) ? &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$ap[$i]{enteredby}) : "n/a");
                $text .= "<tr bgcolor=#ffffff><td rowspan=$ap[$i]{itemCount}>";
                my $testStatus = $ap[$i]{status};
                if (($testStatus == 2 || $testStatus == 3) && $isFinanceLead eq 'F') {
                    $testStatus = 4;
                } elsif ($testStatus == 1 && $ap[$i]{enteredby} != $args{userID}) {
                    $testStatus = 4;
                }
                $text .= "<a href=\"javascript:$jsFunctions[$testStatus]('$ap[$i]{id}')\">$ap[$i]{id}";
                $text .= " / $ap[$i]{invoicenumber}</a></td>";
                $text .= "<td rowspan=$ap[$i]{itemCount}>$name</td>";
                $text .= "<td>$ap[$i]{items}[0]{chargenumber}</td><td>$ap[$i]{items}[0]{ec}</td>";
                my $tax = ((defined($ap[$i]{items}[0]{tax})) ? $ap[$i]{items}[0]{tax} : 0);
                $text .= "<td align=right>" . dollarFormat($ap[$i]{items}[0]{amount}) . "</td><td align=right>" . dollarFormat($tax);
                $text .= " $taxPaidVals{$ap[$i]{taxpaid}}</td>";
                $text .= "<td align=right>" . dollarFormat($ap[$i]{items}[0]{amount} + $tax) . "</td>";
                $text .= "<td align=center rowspan=$ap[$i]{itemCount}>" . ((defined($ap[$i]{datepaid})) ? $ap[$i]{datepaid} : "-") . "<br>";
                $text .= ((defined($ap[$i]{clientbilled})) ? $ap[$i]{clientbilled} : "-") . "</td>";
                $text .= "<td rowspan=$ap[$i]{itemCount}>$apStatus[$ap[$i]{status}]";
                $text .= (($isFinanceLead eq 'T' && $ap[$i]{status} == 4) ? "<font size=1><br><a href=\"javascript:$jsFunctions[3]('$ap[$i]{id}')\">edit dates</a></font>" : "");
                $text .= "</td></tr>\n";
                for (my $j=1; $j<$ap[$i]{itemCount}; $j++) {
                    $text .= "<tr bgcolor=#ffffff><td>$ap[$i]{items}[$j]{chargenumber}</td><td>$ap[$i]{items}[$j]{ec}</td>";
                    my $tax = ((defined($ap[$i]{items}[$j]{tax})) ? $ap[$i]{items}[$j]{tax} : 0);
                    $text .= "<td align=right>" . dollarFormat($ap[$i]{items}[$j]{amount}) . "</td><td align=right>" . dollarFormat($tax) . "</td>";
                    $text .= "<td align=right>" . dollarFormat($ap[$i]{items}[$j]{amount} + $tax) . "</td></tr>";
                }
                if ($ap[$i]{status} == 1) {$openCount++;}
                if ($ap[$i]{status} == 2) {$approvalCount++;}
                if ($ap[$i]{status} == 3) {$openCount++;}
                #$count++;
            }
            $text =~ s/<OpenInvCount>/$openCount/;
            $text =~ s/<OpenAppCount>/$approvalCount/;
            $text .= "</table>\n";
            $text .= "<font size=1><br>&nbsp;</font>\n";
            $text .= "</div>\n";
            $text .= "</td></tr>\n";
        }
        $text .= "</table>\n";
        $text2 .= "<tr><td>$text</td></tr>\n";
        $count2 += $count;
#
        $output .= "<tr><td colspan=3>" . &buildSectionBlock(title=> "<b>Accounts Payable</b> ($count)", contents=>$text2) . "</td></tr>\n";
    }
    
   
    $output .= "</table>\n";
    $output .= "</table>\n";

    
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
###################################################################################################################################



1; #return true
