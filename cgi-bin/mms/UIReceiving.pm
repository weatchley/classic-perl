# UI Receiving functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UIReceiving.pm,v $
#
# $Revision: 1.12 $
#
# $Date: 2009/07/14 15:55:39 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIReceiving.pm,v $
# Revision 1.12  2009/07/14 15:55:39  atchleyb
# fixed prob with neg numbers in quantity received
#
# Revision 1.11  2009/06/26 21:57:40  atchleyb
# ACR0906_001 - List of changes
#
# Revision 1.10  2009/05/29 21:35:51  atchleyb
# ACR0905_001 - user change request, multiple changes
#
# Revision 1.9  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.8  2006/05/17 23:24:19  atchleyb
# CR0026 updated browse to work like home page
#
# Revision 1.7  2006/02/14 23:39:17  atchleyb
# CR 0022 - Help text for e-mail categorization was entered and commented out pending text approval so that CR could be closed out.
#
# Revision 1.6  2005/08/18 19:44:45  atchleyb
# CR00015 - added site filter to browse
#
# Revision 1.5  2004/12/07 18:47:28  atchleyb
# fixed typo in title, updated formatting
#
# Revision 1.4  2004/04/22 21:39:52  atchleyb
# Updates related to SCR 1 (add field briefdescription)
#
# Revision 1.3  2004/04/19 23:11:56  atchleyb
# fixed bug that sent e-mail notice to wrong user.
#
# Revision 1.2  2004/02/27 00:12:09  atchleyb
# added code to only display selected fyscal year
# removed some log warnings
#
# Revision 1.1  2003/12/15 18:52:51  atchleyb
# Initial revision
#
#
#
#
#
#

package UIReceiving;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBReceiving qw(:Functions);
use DBPurchaseDocuments qw(getPDInfo getMimeType getPDByStatus);
use DBVendors qw (getVendorInfo);
use DBUsers qw(getUserInfo);
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
      &doFooter               &getTitle             &doBrowse
      &doReceivingForm        &doReceivingSave      &doIssueDocument
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             
      &doFooter               &getTitle             &doBrowse
      &doReceivingForm        &doReceivingSave      &doIssueDocument
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
   if (($args{command} eq "receivingform") || ($args{command} eq "printissuedoc") 
            || ($args{command} eq "saveprintissuedoc")) {
      $title = "Receiving";
   } elsif (($args{command} eq "browse") || ($args{command} eq "browsereceiving")) {
      $title = "Browse Receiving";
   } elsif (($args{command} eq "amend") || ($args{command} eq "amendreceiving")) {
      $title = "Amend Receiving";
   } elsif (($args{command} eq "receivingentry") || ($args{command} eq "savereceiving")
            || ($args{command} eq "updaterlogform") || ($args{command} eq "newrlogpo")
            || ($args{command} eq "newrlognopo")) {
      $title = "Receiving Entry";
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
       ponumber => (defined($mycgi->param("ponumber"))) ? $mycgi->param("ponumber") : "0",
       rlogid => (defined($mycgi->param("rlogid"))) ? $mycgi->param("rlogid") : "0",
       rlogstatus => (defined($mycgi->param("rlogstatus"))) ? $mycgi->param("rlogstatus") : "0",
       receivingsite => (defined($mycgi->param("receivingsite"))) ? $mycgi->param("receivingsite") : "0",
       datereceived => (defined($mycgi->param("datereceived"))) ? $mycgi->param("datereceived") : "",
       shipvia => (defined($mycgi->param("shipvia"))) ? $mycgi->param("shipvia") : "",
       vendor => (defined($mycgi->param("vendor"))) ? $mycgi->param("vendor") : "",
       shipmentnumber => (defined($mycgi->param("shipmentnumber"))) ? $mycgi->param("shipmentnumber") : "",
       deliveredto => (defined($mycgi->param("deliveredto"))) ? $mycgi->param("deliveredto") : "",
       olddeliveredto => (defined($mycgi->param("olddeliveredto"))) ? $mycgi->param("olddeliveredto") : "",
       datedelivered => (defined($mycgi->param("datedelivered"))) ? $mycgi->param("datedelivered") : "",
       comments => (defined($mycgi->param("comments"))) ? $mycgi->param("comments") : "",
       itemcount => (defined($mycgi->param("itemcount"))) ? $mycgi->param("itemcount") : "0",
       sortby => (defined($mycgi->param("sortby"))) ? $mycgi->param("sortby") : "",
       viewfy => (defined($mycgi->param("viewfy"))) ? $mycgi->param("viewfy") : &getFY,
       sitecode => (defined($mycgi->param("sitecode"))) ? $mycgi->param("sitecode") : 'xx',
    ));

    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    for (my $i=0; $i<=$valueHash{itemcount}; $i++) {
        $valueHash{items}[$i]{"itemnumber"} = (defined($mycgi->param("itemnumber$i"))) ? $mycgi->param("itemnumber$i") : 0;
        $valueHash{items}[$i]{"description"} = (defined($mycgi->param("description$i"))) ? $mycgi->param("description$i") : "";
        $valueHash{items}[$i]{"quantityreceived"} = (defined($mycgi->param("received$i"))) ? $mycgi->param("received$i") : 0;
        $valueHash{items}[$i]{"qualitycode"} = (defined($mycgi->param("quality$i"))) ? $mycgi->param("quality$i") : "";
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
sub doBrowse {  # routine to generate a table of Receiving for browse
###################################################################################################################################
    my %args = (
        sortBy => 'ponumber',
        siteCode => 'xx',
        deliveredto => 'none',
        amendment => 'T',
        pd => '0',
        pdStatusList => '0',
        @_,
    );
    my $output = "";
    my $fy = &getFY;
    my @rLog = getReceiving(dbh => $args{dbh}, schema => $args{schema}, orderBy=>'prnumber', fy=> $args{fy}, firstItemOnly=>'T',
          deliveredto => $args{deliveredto}, siteList=> [$args{siteCode}], pd=>$args{pd}, pdStatusList=>$args{pdStatusList});
    my @dList = getDeliveredtoList(dbh => $args{dbh}, schema => $args{schema}, fy => $fy);
    for (my $i=0; $i<$#rLog; $i++) {
        my %pd = ((defined($rLog[$i]{prnumber}) && $rLog[$i]{prnumber} gt '  ') ? getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$rLog[$i]{prnumber}) : 
            (none => 'n/a', vendorname => 'n/a', prnumber => 'No PR', ponumber => 'No PO'));
        $rLog[$i]{prnumber} = ((defined($pd{prnumber})) ? $pd{prnumber} : "No PR");
        $rLog[$i]{ponumber} = ((defined($pd{ponumber})) ? $pd{ponumber} : "No PO");
        $rLog[$i]{mydescription} = ((defined($pd{briefdescription})) ? $pd{briefdescription} : $rLog[$i]{items}[0]{description});
        my $test = 'test';
        $rLog[$i]{vendorname} = ((defined($pd{vendorname})) ? $pd{vendorname} : ((defined($rLog[$i]{vendor})) ? $rLog[$i]{vendor} : " n/a"));
        if ($args{sortBy} eq "ponumber") {
            $rLog[$i]{sortBy} = "$rLog[$i]{ponumber} - $rLog[$i]{id}";
        } elsif ($args{sortBy} eq "prnumber") {
            $rLog[$i]{sortBy} = "$rLog[$i]{prnumber} - $rLog[$i]{id}";
        } elsif ($args{sortBy} eq "vendorname") {
            $rLog[$i]{sortBy} = "$rLog[$i]{vendorname} - $rLog[$i]{ponumber} - $rLog[$i]{id}";
        } else {
            $rLog[$i]{sortBy} = "$rLog[$i]{ponumber} - $rLog[$i]{id}";
        }
    }

    $output .= "<input type=hidden name=sortby value='id'>\n";
    if ($args{pd} eq '0') {
        $output .= "<table align=center border=0><tr>";
        $output .= "<td>Display Fiscal Year <select name=viewfy size=1>\n";
        for (my $i=1999; $i<=$fy; $i++) {
            $output .= "<option value=$i" . (($i == $args{fy}) ? " selected" : "") . ">$i</option>\n";
        }
        $output .= "</select></td>";
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
        $output .= "<td> &nbsp; Delivered To <select name=deliveredto size=1><option value='all'>All</option>\n";
        for (my $i=0; $i<$#dList; $i++) {
            $output .= "<option value=\"$dList[$i]\"" . (($dList[$i] eq $args{deliveredto}) ? " selected" : "") . ">$dList[$i]</option>\n";
        }
        $output .= "</select></td>";
        $output .= "<td> &nbsp; <input type=button name=refresh value='Refresh' onClick=submitForm('$args{form}','browse')></td>\n";
        $output .= "</tr></table>\n";
    }
    $output .= "<table align=center cellpadding=1 cellspacing=0 border=1>\n";
    $output .= "<tr bgcolor=#a0e0c0>";
    $output .= "<td><b><a href=\"javascript:reSort('prnumber');\">PR Number</a></b></td>";
    $output .= "<td><b><a href=\"javascript:reSort('ponumber');\">PO Number</a></b></td>";
    $output .= "<td><b><a href=\"javascript:reSort('vendorname');\">Vendor</a></b></td>";
    $output .= "<td><b>Description</b></td>";
    $output .= "<td><b>Count</b></td></tr>\n";
    @rLog = sort { ((defined($a->{sortBy})) ? $a->{sortBy} : "") cmp ((defined($b->{sortBy})) ? $b->{sortBy} : "") } @rLog;
    my $prevPR = "first";
    my $iCount = 0;
    for (my $i=1; $i<=$#rLog; $i++) {
        if ($rLog[$i]{prnumber} ne $prevPR) {
            if ($prevPR ne 'first') {
                $output .= "</table></div></td></tr>\n";
                $output =~ s/<icount>/$iCount/g;
                $iCount = 0;
            }
            my $tempID = "$rLog[$i]{prnumber}rec";
            $tempID =~ s/\s//g;
            $prevPR = $rLog[$i]{prnumber};
            $output .= "<tr bgcolor=#ffffff>";
            $output .= "<td><a href=\"javascript:showHidePOSection('$tempID')\">$rLog[$i]{prnumber}</a></td>";
            $output .= "<td><a href=\"javascript:showHidePOSection('$tempID')\">$rLog[$i]{ponumber}</a></td>";
            $output .= "<td>$rLog[$i]{vendorname}</td>";
            $output .= "<td>" . &getDisplayString($rLog[$i]{mydescription}, 100) . "</td>";
            $output .= "<td><icount></td>";
            $output .= "</tr>\n";
            #
            $output .= "<tr><td colspan=5><div id=\"$tempID\" style=\"display:'none'\">";
            $output .= "<table border=1 cellspacing=0 width=100% style=\"font-size: 10pt;\">\n";
            $output .= "<tr bgcolor=#ffff00><td align=center valign=bottom><b>Log ID</b></td>";
            $output .= "<td align=center valign=bottom><b>Date Received</b></td><td align=center valign=bottom><b>Delivered To</b></td>";
            $output .= "<td align=center valign=bottom><b>Date Delivered</b></td>";
            $output .= (($rLog[$i]{prnumber} eq "No PR") ? "<td align=center valign=bottom><b>Description</b> (from item 1)</td>" : "");
            $output .= "</tr>\n";

        }
        $output .= "<tr bgcolor=#ffffff>";
        $output .= "<td><a href=\"javascript:browseRLog('$rLog[$i]{id}');\">$rLog[$i]{id}</a>" . (($args{amendment} eq 'T') ? " &nbsp; &nbsp; &nbsp; <a href=\"javascript:amendRLog('$rLog[$i]{id}');\">amend</a>" : "") . "</td>";
        $output .= "<td>$rLog[$i]{datereceived}</td>";
        $output .= "<td>" . ((defined($rLog[$i]{deliveredto} )) ? $rLog[$i]{deliveredto}  : "&nbsp;"). "</td>";
        $output .= "<td>" . ((defined($rLog[$i]{datedelivered} )) ? $rLog[$i]{datedelivered}  : "&nbsp;"). "</td>";
        $output .= (($rLog[$i]{prnumber} eq "No PR") ? "<td>" . ((defined($rLog[$i]{items}[0]{description} )) ? $rLog[$i]{items}[0]{description}  : "&nbsp;"). "</td>" : "");
        $output .= "</tr>\n";
        $iCount++;
    }
    $output =~ s/<icount>/$iCount/g;
    $output .= "</table></div></td></tr>\n";
    $output .= "</table>\n";
    
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function browseRLog (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'browsereceiving');
}

function amendRLog (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'amendreceiving');
}

function reSort (by) {
    $args{form}.sortby.value=by;
    submitForm('$args{form}', 'browse');
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

//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doReceivingForm {  # routine to generate a form for receiving
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
    my %pd;
    my %rLog;
    $pd{prnumber} = '';
    $pd{ponumber} = 'No PO';
    if ($args{command} eq "updaterlogform" || $args{command} eq "browsereceiving" || $args{command} eq "amendreceiving") {
        %rLog = &getReceivingInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id});
        if (defined($rLog{prnumber}) && $rLog{prnumber} gt ' ') {
            %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$rLog{prnumber});
        } else {
            #$pd{prnumber} = '';
            #$pd{ponumber} = 'No PO';
        }
    } elsif ($args{command} eq "newrlogpo") {
        %rLog = &genNewReceiving(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, pd=>$args{id});
        %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id});
    } elsif ($args{command} eq "newrlognopo") {
        %rLog = &genNewReceiving(dbh => $args{dbh}, schema => $args{schema}, userID=>$args{userID}, site=>$args{site});
        #$pd{prnumber} = '';
        #$pd{ponumber} = 'No PO';
    }
    if (!defined($pd{prnumber}) || $pd{prnumber} le ' ') {
        $pd{prnumber} = '';
        $pd{ponumber} = 'No PO';
    }

    $output .= "<input type=hidden name=rlogid value='$rLog{id}'>\n";
    $output .= "<input type=hidden name=prnumber value='$pd{prnumber}'>\n";
    $output .= "<input type=hidden name=ponumber value='" . ((defined($pd{ponumber})) ? $pd{ponumber} : "") . "'>\n";
    $output .= "<input type=hidden name=rlogstatus value='$rLog{status}'>\n";
    $output .= "<table align=center border=0>\n";
    $output .= "<tr><td><b>Receiving Log ID:</b><br>$rLog{id} &nbsp; </td><td><b>Purchase Order Number:</b><br>$pd{ponumber}</td></tr>\n";
    $output .= "<tr><td><b>Date Items Received: </b></td>";
    if ($args{browseOnly} eq 'F') {
        $output .= "<td><input type=text name=datereceived size=10 maxlength=10 value='$rLog{datereceived}' onfocus=\"this.blur(); showCal('caldatereceived')\">";
        $output .= "<span id=\"datereceivedid\" style=\"position:relative;\">&nbsp;</span>\n";
    } else {
        $output .= "<td>$rLog{datereceived}";
    }
    $output .= "</td></tr>\n";
    if ($pd{ponumber} eq 'No PO') {
        if ($args{browseOnly} eq 'F') {
            $output .= "<tr><td><b>Vendor:</b></td><td><input type=text name=vendor size=50 maxlength=50 value='" . ((defined($rLog{vendor})) ? $rLog{vendor} : "") . "'></td></tr>\n";
        } else {
            $output .= "<tr><td><b>Vendor:</b></td><td>" . ((defined($rLog{vendor})) ? $rLog{vendor} : "") . "</td></tr>\n";
        }
    }
    if ($args{browseOnly} eq 'F') {
        $output .= "<tr><td><b>Shipped Via:</b></td><td><input type=text name=shipvia size=30 maxlength=30 value='$rLog{shipvia}'></td></tr>\n";
        $output .= "<tr><td><b>Shipment Number:</b> </td><td><input type=text name=shipmentnumber size=30 maxlength=30 value='" . ((defined($rLog{shipmentnumber})) ? $rLog{shipmentnumber} : "") . "'></td></tr>\n";
    } else {
        $output .= "<tr><td><b>Shipped Via:</b></td><td>$rLog{shipvia}</td></tr>\n";
        $output .= "<tr><td><b>Shipment Number:</b> </td><td>" . ((defined($rLog{shipmentnumber})) ? $rLog{shipmentnumber} : "") . "</td></tr>\n";
    }
    my $name = (($pd{ponumber} ne 'No PO') ? &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$pd{requester}) : "n/a");
    $output .= "<tr><td><b>Requester:</b> </td><td>$name</td></tr>\n";
    if ($args{browseOnly} eq 'F') {
        $output .= "<tr><td><b>Delivered To:</b> </td><td><input type=text name=deliveredto size=50 maxlength=50 value='" . ((defined($rLog{deliveredto})) ? $rLog{deliveredto} : "") . "'></td></tr>\n";
        $output .= "<input type=hidden name=olddeliveredto value='" . ((defined($rLog{deliveredto})) ? $rLog{deliveredto} : "") . "'>\n";
        $output .= "<tr><td><b>Date Delivered: </b></td>";
        $output .= "<td><input type=text name=datedelivered size=10 maxlength=10 value='" . ((defined($rLog{datedelivered})) ? $rLog{datedelivered} : "") . "' onfocus=\"this.blur(); showCal('caldatedelivered')\">";
        $output .= "<span id=\"datedeliveredid\" style=\"position:relative;\">&nbsp;</span>\n";
        $output .= "</td></tr>\n";
        $output .= "<tr><td colspan=2><b>Comments:</b><br><textarea name=comments rows=4 cols=80>" . ((defined($rLog{comments})) ? $rLog{comments} : "") . "</textarea></td></tr>\n";
        $output .= "<div style=\"display:none\"><textarea name=oldcomments rows=4 cols=80>" . ((defined($rLog{comments})) ? $rLog{comments} : "") . "</textarea></div>\n";
    } else {
        $output .= "<tr><td><b>Delivered To:</b> </td><td>" . ((defined($rLog{deliveredto})) ? $rLog{deliveredto} : "") . "</td></tr>\n";
        $output .= "<tr><td><b>Date Delivered: </b></td><td>" . ((defined($rLog{datedelivered})) ? $rLog{datedelivered} : "") . "</td></tr>\n";
        my $comments = ((defined($rLog{comments})) ? $rLog{comments} : "");
        $comments =~ s/\n/<br>\n/g;
        $comments =~ s/  / &nbsp;/g;
        $output .= "<tr><td colspan=2><b>Comments:</b><br>$comments</td></tr>\n";
    }
    
# items
    $output .= "<tr><td colspan=2>\n";
    my $text = "";
    $text .= "<table border=1 cellpadding=1 cellspacing=0>\n";
    $text .= "<tr bgcolor=#a0e0c0><td align=center valign=top width=62><b>Item<br>Number</b></td>";
    $text .= "<td align=center valign=top width=287><b><br>Description</b></td>";
    $text .= "<td align=center valign=top width=62><b>Qty<br>Ordered</b></td><td align=center valign=top width=65><b>Prev.<br>Received</b></td>";
    $text .= "<td align=center valign=top width=65><b>Received<br>New</b></td><td align=center valign=top width=62><b>Quality<br>Code</b></td><td align=center valign=top width=80><b>Technical<br>Inspection</td></tr>\n";
    my @rLogItems;
    for (my $i=0; $i<$rLog{itemCount}; $i++) {
        $rLogItems[$rLog{items}[$i]{itemnumber}] = $i;
    }
    my @qualityCodes = ("N", "SS", "OV", "WI", "DA", "O");
    my @qualityDescr = ("N", "SS", "OV", "WI", "DA", "O");
    $text .= "<input type=hidden name=itemcount value=" . ((defined($pd{itemCount})) ? $pd{itemCount} : $rLog{itemCount}) . ">\n";
    for (my $i=0; $i<((defined($pd{itemCount})) ? $pd{itemCount} : $rLog{itemCount}); $i++) {
        my $k = $i + 1;
        my $itemNumber = ((defined($pd{items}[$i]{itemnumber}) && $pd{items}[$i]{itemnumber} gt ' ') ? $pd{items}[$i]{itemnumber} : $rLog{items}[$i]{itemnumber});
        my $rLogItem = ((defined($rLogItems[$itemNumber])) ? $rLogItems[$itemNumber] : -1);
        $text .= "<tr bgcolor=ffffff><td align=center>$itemNumber<input type=hidden name=itemnumber$k value=$itemNumber></td>\n";
        if ($pd{ponumber} ne 'No PO') {
            $text .= "<td>$pd{items}[$i]{description}</td>\n";
            $text .= "<td align=center>$pd{items}[$i]{quantity}</td>\n";
            $text .= "<td align=center>$pd{items}[$i]{quantityreceived}</td>\n";
        } else {
            if ($args{browseOnly} eq 'F') {
                $text .= "<td><textarea name=description$k rows=2 cols=30>" . ((defined($rLog{items}[$rLogItem]{description})) ? $rLog{items}[$rLogItem]{description} : "") . "</textarea></td>\n";
            } else {
                my $description = ((defined($rLog{items}[$rLogItem]{description})) ? $rLog{items}[$rLogItem]{description} : "");
                $description =~ s/\n/<br>\n/g;
                $description =~ s/  / &nbsp;/g;
                $text .= "<td>$description</td>\n";
            }
            $text .= "<td align=center>n/a</td>\n";
            $text .= "<td align=center>n/a</td>\n";
        }
        if ($args{browseOnly} eq 'F') {
            $text .= "<td align=center><input type=text size=4 maxlength=4 name=received$k value=" . (($rLogItem >= 0) ? $rLog{items}[$rLogItem]{quantityreceived} : 0) . " onBlur=\"checkNumber(this);\"></td>\n";
            $text .= "<td align=center><select name=quality$k size=1>\n";
            for (my $j=0; $j<=$#qualityCodes; $j++) {
                $text .= "<option value='$qualityCodes[$j]'" . (((($rLogItem >= 0) ? $rLog{items}[$rLogItem]{qualitycode} : "N") eq $qualityCodes[$j]) ? " selected" : "") . ">$qualityDescr[$j]</option>";
            }
            $text .= "</select></td><td align=center>" . $pd{items}[$i]{techinspection} . "</td></tr>\n";
        } else {
            $text .= "<td align=center>" . (($rLogItem >= 0) ? $rLog{items}[$rLogItem]{quantityreceived} : 0) . "</td>\n";
            $text .= "<td align=center>" . ((defined($rLog{items}[$rLogItem]{qualitycode})) ? $rLog{items}[$rLogItem]{qualitycode} : "") . "</td><td align=center>" . $pd{items}[$i]{techinspection} . "</td></tr>\n";
        }
    }
    $text .= "</table>\n";
    $text .= "<table cellpadding=0 cellspacing=0 border=0 id=postItemTable width=100%>\n";
    if ($args{browseOnly} eq 'F') {
        $text .= "<tr><td><a href=javascript:addItem()><font size=-1>Add Item</font></a></td></tr>\n";
    }
    $text .= "</table>\n";
    $text .= <<END_OF_BLOCK;

<script language=javascript><!--

function addItem() {
// add an entry to the item table
    var items = document.$args{form}.itemcount.value;
    items++;
    document.$args{form}.itemcount.value = items;
    var newItemRow = "";
    newItemRow += "<table border=1 cellpadding=1 cellspacing=0>\\n";
    newItemRow += "<tr bgcolor=#ffffff><td valign=top width=62 align=center>" + items + "</td>";
    newItemRow += "<input type=hidden name=itemnumber"+ items + " value='" + items + "'>";
    newItemRow += "<td valign=top width=287 align=center><textarea name=description" + items + " cols=30 rows=2></textarea></td>";
    newItemRow += "<td valign=top width=62 align=center>n/a</td>";
    newItemRow += "<td valign=top width=65 align=center>n/a</td>";
    newItemRow += "<td valign=top width=65 align=center><input name=received" + items + " type=text size=4 maxlength=4 value='' onBlur=\\"checkNumber(this);\\"></td>";
    //newItemRow += "<td valign=top width=62 align=center><input name=quality" + items + " type=text size=5 maxlength=5 value=''></td></tr>";
    newItemRow += "<td valign=top width=62 align=center><select name=quality" + items + " size=1>";
END_OF_BLOCK
    for (my $j=0; $j<=$#qualityCodes; $j++) {
        $text .= "newItemRow += \"<option value='$qualityCodes[$j]'>$qualityDescr[$j]</option>\";\n";
    }
    $text .= <<END_OF_BLOCK;
    newItemRow += "</select></td><td width=80 align=center>n/a</td></tr>";
    newItemRow += "</table>\\n";
    document.all.postItemTable.insertAdjacentHTML("BeforeBegin", "" + newItemRow + "");
    
}
//--></script>

END_OF_BLOCK

    $output .= &buildSectionBlock(title=> "<b>Item List</b>", contents=>$text);

# control buttons
    if ($args{browseOnly} eq 'F') {
        $output .= "<tr><td colspan=2 align=center>";
        $output .= "<input type=button name=submitsavebutton value='Save' onClick=\"verifySaveSubmit(document.$args{form})\"> &nbsp; ";
        $output .= "<input type=button name=submitprintbutton value='Save \& Print Issue Document' onClick=\"verifyPrintSubmit(document.$args{form})\">";
        $output .= "</td></tr>\n";
    } else {
        $output .= "<tr><td colspan=2 align=center>";
        $output .= "<input type=button name=submitprintbutton value='Print Issue Document' onClick=\"PrintSubmit()\">";
        $output .= "</td></tr>\n";
    }
    
    $output .= "</td></tr>\n";
    
    
    $output .= "</table>\n";


    $output .= <<END_OF_BLOCK;

<script language=javascript><!--
function checkNumber(item) {
    var isGood = true;
    var s = item.value;
    if (!isblank(s)) {
        if (s.length == 0) isGood = false;
        var m=0;
        for(var i = 0; i < s.length; i++) {
            var c = s.charAt(i);
            if (c == '-') m++;
            if (c == '-' && i > 0) m++;
            if (((c != '-') && ((c < '0') || (c > '9'))) ||  m > 1) isGood = false;
        }
    }
    if (!isGood) {
        alert('Numbers only in field');
        item.value='0';
        item.focus();
    }
}



function verifySaveSubmit (f){
// javascript form verification routine
    var msg = "";
    if (isblank(f.datereceived.value)) {
        msg += "Date Received must be entered.\\n";
    }
    if (isblank(f.deliveredto.value) && !isblank(f.datedelivered.value)) {
        msg += "Can not have a date delivered without delivered to being set.\\n";
    }
    if (isblank(f.shipvia.value)) {
        msg += "Ship Via must be entered.\\n";
    }
    //for (i=1; i <= f.itemcount.value; i++) {
    //    var code = ""
    //        +"if (!isnumeric(f.received" + i + ".value)) {\\n";
    //        +"    msg += 'Numbers only in the Received New field on item " + i + ".\\\\n';\\n"
    //        +"}\\n"
    //    + "";
    //    
    //    eval(code);
    //}
END_OF_BLOCK
    if ($pd{ponumber} eq 'No PO') {
    $output .= <<END_OF_BLOCK;
    
    if (isblank(f.vendor.value)) {
        msg += "Vendor must be entered.\\n";
    }
    var descrErr = false;
    for (i=1; i <= f.itemcount.value; i++) {
        var code = ""
            +"if (f.received" + i + ".value > 0 && isblank(f.description" + i + ".value)) {\\n"
            +"    descrErr = true;\\n"
            +"}\\n"
        + "";
        
        eval(code);
    }
    if (descrErr) {
        msg += "Description must be entered for each item received.\\n";
    }
        
    
END_OF_BLOCK
    }
    if ($args{command} eq 'amendreceiving') {
    $output .= <<END_OF_BLOCK;
    if (isblank(f.comments.value) || f.comments.value == f.oldcomments.value) {
        msg += "Comment must be entered for amendments.\\n";
    }
END_OF_BLOCK
    }
    $output .= <<END_OF_BLOCK;
    if (msg != "") {
      alert (msg);
    } else {
        submitFormCGIResults('$args{form}', 'savereceiving');
    }
}

function verifyPrintSubmit (f){
// javascript form verification routine
    var msg = "";
    if (isblank(f.datereceived.value)) {
        msg += "Date Received must be entered.\\n";
    }
    if (isblank(f.deliveredto.value)) {
        msg += "Delivered to must be entered.\\n";
    }
    if (isblank(f.deliveredto.value) && !isblank(f.datedelivered.value)) {
        msg += "Can not have a date delivered without delivered to being set.\\n";
    }
    if (isblank(f.shipvia.value)) {
        msg += "Ship Via must be entered.\\n";
    }
END_OF_BLOCK
    if ($pd{ponumber} eq 'No PO') {
    $output .= <<END_OF_BLOCK;
    
    if (isblank(f.vendor.value)) {
        msg += "Vendor must be entered.\\n";
    }
    var descrErr = false;
    for (i=1; i <= f.itemcount.value; i++) {
        var code = ""
            +"if (f.received" + i + ".value > 0 && isblank(f.description" + i + ".value)) {\\n"
            +"    descrErr = true;\\n"
            +"}\\n"
        + "";
        
        eval(code);
    }
    if (descrErr) {
        msg += "Description must be entered for each item received.\\n";
    }
        
    
END_OF_BLOCK
    }
    if ($args{command} eq 'amendreceiving') {
    $output .= <<END_OF_BLOCK;
    if (isblank(f.comments.value) || f.comments.value == f.oldcomments.value) {
        msg += "Comment must be entered for amendments.\\n";
    }
END_OF_BLOCK
    }
    $output .= <<END_OF_BLOCK;
    if (msg != "") {
      alert (msg);
    } else {
        var myDate = new Date();
        var winName = myDate.getTime();
        document.$args{form}.id.value = '$args{id}';
        document.$args{form}.action = '$args{path}' + '$args{form}.pl';
        document.$args{form}.command.value = 'saveprintissuedoc';
        document.$args{form}.target = winName;
        var newwin = window.open('',winName);
        newwin.creator = self;
        document.$args{form}.submit();
        document.$args{form}.rlogstatus.value = 'update';
    }
}

function PrintSubmit (){
// javascript print routine
    var myDate = new Date();
    var winName = myDate.getTime();
    document.$args{form}.id.value = '$args{id}';
    document.$args{form}.action = '$args{path}' + '$args{form}.pl';
    document.$args{form}.command.value = 'printissuedoc';
    document.$args{form}.target = winName;
    var newwin = window.open('',winName);
    newwin.creator = self;
    document.$args{form}.submit();
}


//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doReceivingSave {  # routine to save receiving data
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";

    my $status = &doProcessReceivingSave(dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, id => $args{id}, 
              settings => \%settings);
    if ($settings{rlogstatus} eq 'new' && (defined($settings{prnumber}) && $settings{prnumber} gt ' ')) {
        my %rLog = &getReceivingInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id});
        my %pd = &getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$rLog{prnumber});
        my $mail = "Items have been received for PR: $pd{prnumber} / PO: $pd{ponumber}";
        #$mail .= "\n    -- This is a computer generated e-mail that requires categorization by the recipient --    \n\n\n";
        #$mail .= "\n\nThis email message is an extra copy of information stored in an automated system and as such is not a Federal Record. \n" .
        #    "Delete this message after you have used it as a reminder or notice.\n";
        my %user = &getUserInfo(dbh => $args{dbh}, schema => $args{schema}, ID => $pd{requester});
        &SendMailMessage (sendTo=>$user{email}, subject=>"New Items Received", message=>$mail);
    }

    my $message = "Receiving Log entry $settings{rlogid} for " . ((defined($settings{prnumber}) && $settings{prnumber} gt ' ') ? $settings{prnumber} : "NO PR") . " entered/updated";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $settings{userid}, logMessage => $message, type => 37);
    
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('home','home');\n";
    $output .= "//--></script>\n";


    return($output);
}


###################################################################################################################################
sub doIssueDocument {  # routine to create a PDF of the issue document
###################################################################################################################################
    my %args = (
        id => '',
        forDisplay => 'T',
        @_,
    );
    my $warnSave = $^W;
    my $output = "";
    my %rLog = &getReceivingInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$args{id});
    my %pd;
    my %vendor;
    if (defined($rLog{prnumber}) && $rLog{prnumber} gt ' ') {
        %pd = getPDInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$rLog{prnumber});
        if (defined($pd{prnumber}) && $pd{prnumber} gt ' ') {
            %vendor = &getVendorInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$pd{vendor});
        }
    }

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
    $pdf->setFont(font => "Helvetica-Bold", fontSize => 10.0);
    @colData = ("ISSUE DOCUMENT");
    $pdf->addHeader(fontSize => 14.0, text => "ISSUE DOCUMENT", alignment => "center");
    
# blank line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (" "); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 2, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    
# line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (" "); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 1, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>2.0);

    $colCount = 4;
    @colWidths = (132, 132, 132, 132);
    @colAlign = ("right", "left", "right", "left");
    @colData = ("\nPO Number: ", ((defined($pd{prnumber}) && $pd{prnumber} gt ' ') ? "\n" . $pd{ponumber} : "\nNO PO"),
                "\nReceived Date: ", "\n" . $rLog{datereceived});
    $pdf->addHeaderRow(fontSize => 12, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    @colData = ("\nCharge Number: ", "\n" . ((defined($pd{prnumber}) && $pd{prnumber} gt ' ') ? $pd{chargenumber} : "N/A"),
                "\nShipped Via: ", "\n" . $rLog{shipvia});
    $pdf->addHeaderRow(fontSize => 12, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    @colData = ("\nDelivered To: ", "\n" . ((defined($rLog{deliveredto})) ? $rLog{deliveredto} : ""), "\nShipment Number: ", "\n" . ((defined($rLog{shipmentnumber})) ? $rLog{shipmentnumber} : "N/A"));
    $pdf->addHeaderRow(fontSize => 12, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    $colCount = 2;
    @colWidths = (132, 412);
    @colAlign = ("right", "left");
    @colData = ("\nVendor: ", "\n" . ((defined($vendor{name})) ? $vendor{name} : $rLog{vendor}));
    $pdf->addHeaderRow(fontSize => 12, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    @colData = ("\nComment: \n\n", "\n" . ((defined($rLog{comments})) ? $rLog{comments} : ""));
    $pdf->addHeaderRow(fontSize => 12, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    
# line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (" "); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 1, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>2.0);
    
    

## Footers
#
# line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (" "); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addFooterRow(fontSize => 1, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>2.0);
    
    $pdf->addFooter(fontSize => 8.0, text => "Page <page>", alignment => "center");
    my $footerDate = &get_date();
    $pdf->addFooter(fontSize => 8.0, text =>$footerDate , alignment => "right", sameLine => 'T');

    $colCount = 2;
    @colWidths = (281,281);
    @colAlign = ("left","left");
    $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    @colData = (
          "\n\n\n\n____________________________________________\nIssued By\n\n\n\n\n____________________________________________\n". ((defined($rLog{deliveredto})) ? $rLog{deliveredto} : ""),
          "\n\n\n\n____________________________________________\nDate\n\n\n\n\n____________________________________________\nDate");
    $pdf->addFooterRow(fontSize => 8, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);

## start page
    $^W = 0;
    $pdf->newPage(orientation => 'portrait', useGrid => 'F');
    $^W = $warnSave;

# page contents

# blank line
    $colCount = 1; @colWidths = (562); @colAlign = ("center"); @colData = (" "); $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->tableRow(fontSize => 10, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $colCount = 1;
    @colWidths = (562);
    @colAlign = ("left");
    @colData = ("Items Received:");
    $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
    $colCount = 7;
    @colWidths = (42,92,192,42,42,52, 52);
    @colAlign = ("center","center","center","center","center","center","center");
    @colData = ("Item\nNumber", "Part Number", "Description", "Quantity\nOrdered", "Qnty\nRecvd", "Unit\nPrice", "Total\nPrice");
    $pdf->tableRow(fontSize => 8, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.5);
    @colAlign = ("center","center","left","center","center","right","right");
    my @itemMap = ();
    if (defined($pd{itemCount})) {
        for (my $i=0; $i<$pd{itemCount}; $i++) {
            $itemMap[$pd{items}[$i]{itemnumber}] = $i;
        }
    }
    for (my $i=0; $i<$rLog{itemCount}; $i++) {
        my $map = $itemMap[$rLog{items}[$i]{itemnumber}];
        @colData = ($rLog{items}[$i]{itemnumber},
              ((defined($pd{items}[$map]{partnumber})) ? $pd{items}[$map]{partnumber} : "N/A"),
              ((defined($pd{items}[$map]{description})) ? $pd{items}[$map]{description} : "$rLog{items}[$i]{description}"),
              ((defined($pd{items}[$map]{quantity})) ? $pd{items}[$map]{quantity} : "N/A"),
              $rLog{items}[$i]{quantityreceived},
              ((defined($pd{items}[$map]{unitprice})) ? dollarFormat($pd{items}[$map]{unitprice}) : "N/A"),
              ((defined($pd{items}[$map]{unitprice})) ? (dollarFormat($pd{items}[$map]{unitprice}*$rLog{items}[$i]{quantityreceived})) : "N/A"));
        $pdf->tableRow(fontSize => 9, fontID => $fontID, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.0);
              
    }
    

    
## finish pdf
    $^W = 0;
    my $pdfBuff = $pdf->finish;
    $^W = $warnSave;
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
    my $text = reverse (sprintf "%20.2f", ($_[0]));
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    $text = scalar reverse $text;
    $text =~ s/ //g;
    return '$' . $text;
}




###################################################################################################################################
###################################################################################################################################



1; #return true
