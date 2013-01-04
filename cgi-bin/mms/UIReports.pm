# UI Report functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UIReports.pm,v $
#
# $Revision: 1.8 $
#
# $Date: 2009/10/08 21:44:57 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIReports.pm,v $
# Revision 1.8  2009/10/08 21:44:57  atchleyb
# ACR0910_006 - Fix prob with report selection
#
# Revision 1.7  2009/09/04 16:55:30  atchleyb
# ACR0908_007 - Changes to implement new Tax Report
#
# Revision 1.6  2009/07/31 22:43:26  atchleyb
# Updates related to ACR0907_004-SWR0149   New intermediate buyer role, minor bug fixes
#
# Revision 1.5  2009/06/26 21:57:40  atchleyb
# ACR0906_001 - List of changes
#
# Revision 1.4  2009/05/29 21:35:51  atchleyb
# ACR0905_001 - user change request, multiple changes
#
# Revision 1.3  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.2  2005/08/18 19:46:46  atchleyb
# added menu options for role delegation report
#
# Revision 1.1  2004/12/07 18:49:21  atchleyb
# Initial revision
#
#
#
#
#

package UIReports;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBUtilities qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use DBVendors qw(getVendorList);
use DBPurchaseDocuments qw(getChargeNumberArray);
use Text_Menus;
use Tie::IxHash;
use Tables;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
use integer;

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
   my $title = "Reports";
   if ($args{command} eq "?") {
      $title = "Reports";
   } elsif ($args{command} eq "?") {
      $title = "Reports";
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
        includeJSUtilities => 'F',
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
    function doBrowse(script) {
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


END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              includeJSCalendar => $args{includeJSCalendar}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS,includeJSUtilities => $args{includeJSUtilities}, 
              includeJSWidgets => $args{includeJSWidgets});
    
    $output .= "<input type=hidden name=type value=0>\n";
    $output .= "<input type=hidden name=projectID value=0>\n";
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
sub doMainMenu {  # routine to generate main report menu
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my $message = '';
    my $menu1 = new Text_Menus;

    $output .= "<center>\n";

# Sample section
#    my $sampleMenu = new Text_Menus;
        
#    $sampleMenu->addMenu(name => "report1", label => "Report 1", contents => "javascript:alert('Submit Report');");
#    $sampleMenu->addMenu(name => "report2", label => "Report 2", contents => "Test 2");
#    $sampleMenu->addMenu(name => "report3", label => "Report 3", contents => "Test 3");
#    $sampleMenu->addMenu(name => "report4", label => "Report 4", contents => "Test 4");
#    $sampleMenu->addMenu(name => "report5", label => "Report 5", contents => "Test 5");
#    $sampleMenu->addMenu(name => "report6", label => $SomeReportMenu->label(), contents => $SomeReportMenu->contents(), title => $SomeReportMenu->label());
		  
    my $splMenu = new Text_Menus;
    $splMenu->addMenu(name => 'softwareProjects', label => 'Software Projects', contents => 'Software Projects');
    $splMenu->addMenu(name => 'softwareProducts', label => 'Software Products', contents => 'Software Products');
    $splMenu->addMenu(name => 'releaseHistory', label => 'Product Release History', contents => 'Product Release History');
    $splMenu->addMenu(name => 'configItems', label => 'Product Configuration Items', contents => 'Product Configuration Items');
    $splMenu->addMenu(name => 'productBaseline', label => 'Current Product Baselines', contents => 'Current Product Baselines');
    $splMenu->addMenu(name => 'baselineItem', label => 'Baseline Configuration Item', contents => 'Baseline Configuration Item');
    $splMenu->addMenu(name => 'baselineHistory', label => 'Baseline History', contents => 'Baseline History');

    my $scrMenu = new Text_Menus;     
    $scrMenu->addMenu(name => 'scrMenu', label => 'Software Change Requests', contents => 'Software Change Requests');

    my $sccbMenu = new Text_Menus;
    $sccbMenu->addMenu(name => 'sccbMenu', label => 'Software Configuration Control Board Members', contents => 'Software Configuration Control Board Members');
		  
    my $usersMenu = new Text_Menus;
    $usersMenu->addMenu(name => 'sysusers', label => 'System Users', contents => 'System Users');
    $usersMenu->addMenu(name => 'userspriv', label => 'Users by Privilege', contents => 'Users by Privilege');

    my @sites = &getSiteInfoArray(dbh=>$args{dbh}, schema=>$args{schema});

# po menus
    my $poMenu = new Text_Menus;
##
    my $actText = '';
    $actText .= "<table border=0 align=center><tr><td align=center><b>PO Activity Report</b></td></tr>\n";
    $actText .= "<tr><td align=center><b>Site: </b>\n<select name=site size=1><option value=0>All</option>\n";
    for (my $i=1; $i<=$#sites; $i++) {
        $actText .= "<option value=$sites[$i]{id}>$sites[$i]{name}</option>\n";
    }
    $actText .= "</select></td></tr>\n";
    $actText .= "<tr><td align=center><b>Sort By: </b>\n<select name=actsortby size=1>\n";
    $actText .= "<option value='ponumber'>PO Number</option>\n";
    $actText .= "<option value='prnumber'>PR Number</option>\n";
    $actText .= "<option value='vendorName'>Vendor</option>\n";
    $actText .= "</select></td></tr>\n";
    my $iDate = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => -1);
    $actText .= "<tr><td align=center><b>Start Date: </b>\n";
    $actText .= "<input type=text name=startdate size=10 maxlength=10 value='$iDate' onfocus=\"this.blur(); showCal('calstartdate')\">";
    $actText .= "<span id=\"startdateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    $iDate = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => 0);
    $actText .= "<tr><td align=center><b>End Date: </b>\n";
    $actText .= "<input type=text name=enddate size=10 maxlength=10 value='$iDate' onfocus=\"this.blur(); showCal('calenddate')\">";
    $actText .= "<span id=\"enddateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    $actText .= "<tr><td align=center><b><input type=checkbox name=poactmaintonly value='T'>Maintenance/Partial Maintenance Only</b></td></tr>\n";
    $actText .= "<tr><td align=center><b><input type=radio name=poactformat value='pdf' checked>PDF &nbsp; <input type=radio name=poactformat value='xls'>Excel</b></td></tr>\n";
    $actText .= "<tr><td align=center><input type=button name=actbutton value='Create Report' onClick=submitReport('purchaseDocuments','printpoactivity')></td></tr>\n";
    $actText .= "</table>\n";
    $poMenu->addMenu(name => 'activity', label => 'Activity', contents => $actText);
##
    my $seText = '';
    $seText .= "<table border=0 align=center><tr><td align=center><b>SocioEconomic Monitoring Report</b></td></tr>\n";
    $seText .= "<tr><td align=center><b>Site: </b>\n<select name=sesite size=1><option value=0>All</option>\n";
    for (my $i=1; $i<=$#sites; $i++) {
        $seText .= "<option value=$sites[$i]{id}>$sites[$i]{name}</option>\n";
    }
    $seText .= "</select></td></tr>\n";
    $seText .= "<tr><td align=center><b>Sort By: </b>\n<select name=sesortby size=1>\n";
    $seText .= "<option value='vendorpo'>Vendor</option>\n";
    $seText .= "<option value='povendor'>PO Number</option>\n";
    $seText .= "</select></td></tr>\n";
    $iDate = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => -1);
    $seText .= "<tr><td align=center><b>Start Date: </b>\n";
    $seText .= "<input type=text name=sestartdate size=10 maxlength=10 value='$iDate' onfocus=\"this.blur(); showCal('calsestartdate')\">";
    $seText .= "<span id=\"sestartdateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    $iDate = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => 0);
    $seText .= "<tr><td align=center><b>End Date: </b>\n";
    $seText .= "<input type=text name=seenddate size=10 maxlength=10 value='$iDate' onfocus=\"this.blur(); showCal('calseenddate')\">";
    $seText .= "<span id=\"seenddateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    $seText .= "<tr><td align=center><b><input type=radio name=poseformat value='pdf' checked>PDF &nbsp; <input type=radio name=poseformat value='xls'>Excel</b></td></tr>\n";
    $seText .= "<tr><td align=center><input type=button name=sebutton value='Create Report' onClick=submitReport('purchaseDocuments','printposocioeconomic')></td></tr>\n";
    $seText .= "</table>\n";
    $poMenu->addMenu(name => 'socioeconomic', label => 'Socio-Economic', contents => $seText);
##
    my $ageText = '';
    $ageText .= "<table border=0 align=center><tr><td align=center><b>PO Aging Report</b></td></tr>\n";
    $ageText .= "<tr><td align=center><b>Site: </b>\n<select name=agesite size=1><option value=0>All</option>\n";
    for (my $i=1; $i<=$#sites; $i++) {
        $ageText .= "<option value=$sites[$i]{id}>$sites[$i]{name}</option>\n";
    }
    $ageText .= "</select></td></tr>\n";
    $ageText .= "<tr><td align=center><b>Sort By: </b>\n<select name=agesortby size=1>\n";
    $ageText .= "<option value='ponumber'>PO Number</option>\n";
    $ageText .= "<option value='prnumber'>PR Number</option>\n";
    $ageText .= "<option value='vendorName'>Vendor</option>\n";
    $ageText .= "</select></td></tr>\n";
    $ageText .= "<tr><td align=center><b>Age: </b>\n<select name=agehowold size=1>\n";
    $ageText .= "<option value='0-30'>0 to 30 Days</option>\n";
    $ageText .= "<option value='31-60'>31 to 60 Days</option>\n";
    $ageText .= "<option value='61-120'>61 to 120 Days</option>\n";
    $ageText .= "<option value='>120'>Greater Than 120 Days</option>\n";
    $ageText .= "</select></td></tr>\n";
    $ageText .= "<tr><td align=center><b>Type: </b>\n<select name=agetype size=1>\n";
    $ageText .= "<option value='initial'>Initial PR to PR Approval</option>\n";
    $ageText .= "<option value='pending'>PR Approved to PO Approval</option>\n";
    $ageText .= "<option value='receiving'>PO's with Pending Receiving</option>\n";
    $ageText .= "</select></td></tr>\n";
#    my $iDate = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => -1);
#    $ageText .= "<tr><td align=center><b>Start Date: </b>\n";
#    $ageText .= "<input type=text name=startdate size=10 maxlength=10 value='$iDate' onfocus=\"this.blur(); showCal('calstartdate')\">";
#    $ageText .= "<span id=\"startdateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
#    $iDate = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => 0);
#    $ageText .= "<tr><td align=center><b>End Date: </b>\n";
#    $ageText .= "<input type=text name=enddate size=10 maxlength=10 value='$iDate' onfocus=\"this.blur(); showCal('calenddate')\">";
#    $ageText .= "<span id=\"enddateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    $ageText .= "<tr><td align=center><b><input type=radio name=poageformat value='pdf' checked>PDF &nbsp; <input type=radio name=poageformat value='xls'>Excel</b></td></tr>\n";
    $ageText .= "<tr><td align=center><input type=button name=agebutton value='Create Report' onClick=submitReport('purchaseDocuments','printpoaging')></td></tr>\n";
    $ageText .= "</table>\n";
    $poMenu->addMenu(name => 'aging', label => 'Aging', contents => $ageText);
##
# invoice menus
    my $apMenu = new Text_Menus;
##
    my @vendors = &getVendorList(dbh=>$args{dbh}, schema=>$args{schema},pdStatusList => '15, 16, 17, 18');
    my @chargeNumbers = &getChargeNumberArray(dbh=>$args{dbh}, schema=>$args{schema},statusList => '15, 16, 17, 18', onlyFY => 'F');
    my $oniText = '';
    $oniText .= "<table border=0 align=center><tr><td align=center><b>Obligated Not Invoiced</b></td></tr>\n";
    $oniText .= "<tr><td align=center><b>Site: </b>\n<select name=onisite size=1><option value=0>All</option>\n";
    for (my $i=1; $i<=$#sites; $i++) {
        $oniText .= "<option value=$sites[$i]{id}>$sites[$i]{name}</option>\n";
    }
    $oniText .= "</select></td></tr>\n";
    $oniText .= "<tr><td align=center><b>Vendor: </b>\n<select name=vendorid size=1><option value=0>All</option>\n";
    for (my $i=1; $i<=$#vendors; $i++) {
        $oniText .= "<option value=$vendors[$i]{id}>$vendors[$i]{name}</option>\n";
    }
    $oniText .= "</select></td></tr>\n";
    $oniText .= "<tr><td align=center><b>Charge Number: </b>\n<select name=onichargenumber size=1><option value='0'>All</option>\n";
    for (my $i=1; $i<=$#chargeNumbers; $i++) {
        $oniText .= "<option value=$chargeNumbers[$i]{chargenumber}>$chargeNumbers[$i]{chargenumber}</option>\n";
    }
    $oniText .= "</select></td></tr>\n";
    $oniText .= "<tr><td align=center><b>Sort By: </b>\n<select name=onisortby size=1>\n";
    $oniText .= "<option value='podate'>Date</option>\n";
    $oniText .= "<option value='vendorName'>Vendor</option>\n";
    $oniText .= "</select></td></tr>\n";
    $oniText .= "<tr><td align=center><b><input type=radio name=oniformat value='pdf' checked>PDF &nbsp; <input type=radio name=oniformat value='xls'>Excel</b></td></tr>\n";
    $oniText .= "<tr><td align=center><input type=button name=onibutton value='Create Report' onClick=submitReport('purchaseDocuments','printobnotinv')></td></tr>\n";
    $oniText .= "</table>\n";
    $apMenu->addMenu(name => 'obligatednyb', label => 'Obligated Not Yet Billed', contents => $oniText);
##
    my $comText = '';
    $comText .= "<table border=0 align=center><tr><td align=center><b>Committed Report</b></td></tr>\n";
    $comText .= "<tr><td align=center><b>Site: </b>\n<select name=comsite size=1><option value=0>All</option>\n";
    for (my $i=1; $i<=$#sites; $i++) {
        $comText .= "<option value=$sites[$i]{id}>$sites[$i]{name}</option>\n";
    }
    $comText .= "</select></td></tr>\n";
    #$comText .= "<tr><td align=center><b>Sort By: </b>\n<select name=comsortby size=1>\n";
    #$comText .= "<option value='vendorName'>Vendor</option>\n";
    #$comText .= "<option value='ponumber'>PO Number</option>\n";
    #$comText .= "</select></td></tr>\n";
    $iDate = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => -1);
    $comText .= "<tr><td align=center><b>Start Date: </b>\n";
    $comText .= "<input type=text name=comstartdate size=10 maxlength=10 value='$iDate' onfocus=\"this.blur(); showCal('calcomstartdate')\">";
    $comText .= "<span id=\"comstartdateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    $iDate = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => 0);
    $comText .= "<tr><td align=center><b>End Date: </b>\n";
    $comText .= "<input type=text name=comenddate size=10 maxlength=10 value='$iDate' onfocus=\"this.blur(); showCal('calcomenddate')\">";
    $comText .= "<span id=\"comenddateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    $comText .= "<tr><td align=center><b><input type=radio name=comformat value='pdf' checked>PDF &nbsp; <input type=radio name=comformat value='xls'>Excel</b></td></tr>\n";
    $comText .= "<tr><td align=center><input type=button name=combutton value='Create Report' onClick=submitReport('purchaseDocuments','printcommitted')></td></tr>\n";
    $comText .= "</table>\n";
    $apMenu->addMenu(name => 'committed', label => 'Committed', contents => $comText);
##
    my $invLogText = '';
    $invLogText .= "<table border=0 align=center><tr><td align=center><b>PO Invoice Report</b></td></tr>\n";
    $invLogText .= "<tr><td align=center><b>Site: </b>\n<select name=invlsite size=1><option value=0>All</option>\n";
    for (my $i=1; $i<=$#sites; $i++) {
        $invLogText .= "<option value=$sites[$i]{id}>$sites[$i]{name}</option>\n";
    }
    $invLogText .= "</select></td></tr>\n";
    #$invLogText .= "<tr><td align=center><b>Sort By: </b>\n<select name=invlsortby size=1>\n";
    #$invLogText .= "<option value='vendorpo'>Vendor</option>\n";
    #$invLogText .= "<option value='povendor'>PO Number</option>\n";
    #$invLogText .= "</select></td></tr>\n";
    $invLogText .= "<tr><td align=center><b>Starting PO: </b><input type=text name=startpo size=11 maxlength=11><br><font size=-1>(Using Starting PO will use all dates)</font></td></tr>\n";
    $iDate = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => -1);
    $invLogText .= "<tr><td align=center><b>Start Date: </b>\n";
    $invLogText .= "<input type=text name=invlstartdate size=10 maxlength=10 value='$iDate' onfocus=\"this.blur(); showCal('calinvlstartdate')\">";
    $invLogText .= "<span id=\"invlstartdateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    $iDate = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => 0);
    $invLogText .= "<tr><td align=center><b>End Date: </b>\n";
    $invLogText .= "<input type=text name=invlenddate size=10 maxlength=10 value='$iDate' onfocus=\"this.blur(); showCal('calinvlenddate')\">";
    $invLogText .= "<span id=\"invlenddateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    $invLogText .= "<tr><td align=center><b><input type=radio name=invlformat value='pdf' checked>PDF &nbsp; <input type=radio name=invlformat value='xls'>Excel</b></td></tr>\n";
    $invLogText .= "<tr><td align=center><input type=button name=invlbutton value='Create Report' onClick=submitReport('purchaseDocuments','printinvlog')></td></tr>\n";
    $invLogText .= "</table>\n";
    $apMenu->addMenu(name => 'invlog', label => 'PO Log', contents => $invLogText);
##
    @vendors = &getVendorList(dbh=>$args{dbh}, schema=>$args{schema},pdStatusList => '15, 16, 17, 18, 19');
    @chargeNumbers = &getChargeNumberArray(dbh=>$args{dbh}, schema=>$args{schema},statusList => '15, 16, 17, 18, 19', onlyFY => 'F');
    my $trText = '';
    $trText .= "<table border=0 align=center><tr><td align=center><b>Tax Report</b></td></tr>\n";
    $trText .= "<tr><td align=center><b>Site: </b>\n<select name=trsite size=1><option value=0>All</option>\n";
    for (my $i=1; $i<=$#sites; $i++) {
        $trText .= "<option value=$sites[$i]{id}>$sites[$i]{name}</option>\n";
    }
    $trText .= "<tr><td align=center><b>Charge Number: </b>\n<select name=trchargenumber size=1><option value='0'>All</option>\n";
    for (my $i=1; $i<=$#chargeNumbers; $i++) {
        $trText .= "<option value=$chargeNumbers[$i]{chargenumber}>$chargeNumbers[$i]{chargenumber}</option>\n";
    }
    $trText .= "</select></td></tr>\n";
    $trText .= "<tr><td align=center><b>Tax Type: </b>\n<select name=taxtype size=1>\n";
    $trText .= "<option value='all'>All</option>\n";
    $trText .= "<option value='sales'>Sales</option>\n";
    $trText .= "<option value='use'>Use</option>\n";
    $trText .= "</select></td></tr>\n";
    $trText .= "<tr><td align=center><b>Sort By: </b>\n<select name=trsortby size=1>\n";
    $trText .= "<option value='ponumber'>PO Number</option>\n";
    $trText .= "<option value='podate'>Date</option>\n";
    $trText .= "<option value='refnumber'>Reference Number</option>\n";
    $trText .= "</select></td></tr>\n";
    $trText .= "<tr><td align=center><b>Start Date: </b>\n";
    $trText .= "<input type=text name=trstartdate size=10 maxlength=10 value='$iDate' onfocus=\"this.blur(); showCal('caltrstartdate')\">";
    $trText .= "<span id=\"trstartdateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    $iDate = &getDateOffset(dbh=>$args{dbh}, schema=>$args{schema}, offset => 0);
    $trText .= "<tr><td align=center><b>End Date: </b>\n";
    $trText .= "<input type=text name=trenddate size=10 maxlength=10 value='$iDate' onfocus=\"this.blur(); showCal('caltrenddate')\">";
    $trText .= "<span id=\"trenddateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    $trText .= "<tr><td align=center><b><input type=radio name=trformat value='pdf' checked>PDF &nbsp; <input type=radio name=trformat value='xls'>Excel</b></td></tr>\n";
    $trText .= "<tr><td align=center><input type=button name=trbutton value='Create Report' onClick=submitReport('purchaseDocuments','printtaxrep')></td></tr>\n";
    $trText .= "</table>\n";
    $apMenu->addMenu(name => 'taxreport', label => 'Tax Report', contents => $trText);
##
# user menus
    my $uMenu = new Text_Menus;
##
    my $drText = '';
    $output .= "<input type=hidden name=urdsite value=0>\n";
    $drText .= "javascript:submitReport('roles','printdelegations');";
    $uMenu->addMenu(name => 'cpdur', label => 'Current/Pending Delegated User Roles', contents => $drText);
        
# Top menu
#    $menu1->addMenu(name => "spl", label => "Software Project Library", status => 'open', contents => $splMenu->buildMenus(name => 'spl', type => 'bullets'), title => 'Software Project Library Reports');
#    $menu1->addMenu(name => "scr", label => "Change Requests", contents => $scrMenu->buildMenus(name => 'scr', type => 'bullets'), title => 'Project Software Change Request Reports');
#    $menu1->addMenu(name => "sccb", label => "Control Board", contents => $sccbMenu->buildMenus(name => 'sccb', type => 'bullets'), title => 'Software Configuration Control Board Reports');
#    $menu1->addMenu(name => "users", label => "Users", status => 'open', contents => $usersMenu->buildMenus(name => 'users', type => 'bullets'), title => 'Users');
    $menu1->addMenu(name => "po", label => "Purchase Order", status => 'open', contents => $poMenu->buildMenus(name => 'po', type => 'bullets'), title => 'Purchase Order');
    $menu1->addMenu(name => "ap", label => "Accounts Payable", status => 'closed', contents => $apMenu->buildMenus(name => 'ap', type => 'bullets'), title => 'Accounts Payable');
    $menu1->addMenu(name => "ur", label => "User", status => 'closed', contents => $uMenu->buildMenus(name => 'u', type => 'bullets'), title => 'User');

    my $menutype = ((defined($mycgi->param('menutype'))) ? $mycgi->param('menutype') : "table");
    #$menutype="tabs";
    #$menutype="list";
    $menu1->imageSource("$SYSImagePath/");
    $output .= $menu1->buildMenus(name => 'ReportMenu1', type => $menutype, linkStyle=>"'overline underline'");

    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

       function submitReport(script,command) {
           var myDate = new Date();
           var winName = myDate.getTime();
           document.$args{form}.command.value = command;
           document.$args{form}.action = '$args{path}' + script + '.pl';
           document.$args{form}.target = winName;
           var newwin = window.open('',winName);
           newwin.creator = self;
           document.$args{form}.submit();
       }

//--></script>

END_OF_BLOCK

    $output .= "</center>\n";
    
    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
