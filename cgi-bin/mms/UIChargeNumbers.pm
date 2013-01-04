# UI ChargeNumber functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UIChargeNumbers.pm,v $
#
# $Revision: 1.5 $
#
# $Date: 2009/05/29 21:35:51 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIChargeNumbers.pm,v $
# Revision 1.5  2009/05/29 21:35:51  atchleyb
# ACR0905_001 - user change request, multiple changes
#
# Revision 1.4  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.3  2005/08/18 19:04:39  atchleyb
# CR00015 - changed to select screen after insert or update
#
# Revision 1.2  2005/03/30 23:20:27  atchleyb
# Fixed misspelling on forms
#
# Revision 1.1  2004/01/09 23:32:55  atchleyb
# Initial revision
#
#
#
#
#
#

package UIChargeNumbers;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBChargeNumbers qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use DBPurchaseDocuments qw(getChargeNumberArray);
use DBUsers qw(getUserArray);
use Sessions qw(:Functions);
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
      &getInitialValues       &doHeader                &doUpdateChargeNumberSelect
      &doFooter               &getTitle                &doChargeNumberEntryForm
      &doChargeNumberEntry    &doChargeNumberCopyForm  &doChargeNumberCopy
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader                &doUpdateChargeNumberSelect
      &doFooter               &getTitle                &doChargeNumberEntryForm
      &doChargeNumberEntry    &doChargeNumberCopyForm  &doChargeNumberCopy
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
   if (($args{command} eq "addcn") || ($args{command} eq "addcnform")) {
      $title = "Add Charge Number";
   } elsif (($args{command} eq "updatecn") || ($args{command} eq "updatecnform") || ($args{command} eq "updatecnselect")) {
      $title = "Update Charge Number";
   } elsif (($args{command} eq "browse") || (($args{command} eq "displaycn")) || ($args{command} eq "displaycnform")) {
      $title = "Browse Charge Number";
   } elsif (($args{command} eq "copycn") || ($args{command} eq "copycnform")) {
      $title = "Copy Charge Numbers";
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
       onlyfy => (defined($mycgi->param("onlyfy"))) ? $mycgi->param("onlyfy") : 'T',
       oldchargenumber => (defined($mycgi->param("oldchargenumber"))) ? $mycgi->param("oldchargenumber") : "",
       chargenumber => (defined($mycgi->param("chargenumber"))) ? $mycgi->param("chargenumber") : "",
       fyscalyear => (defined($mycgi->param("fyscalyear"))) ? $mycgi->param("fyscalyear") : 0,
       site => (defined($mycgi->param("site"))) ? $mycgi->param("site") : 0,
       description => (defined($mycgi->param("description"))) ? $mycgi->param("description") : "",
       wbs => (defined($mycgi->param("wbs"))) ? $mycgi->param("wbs") : "",
       funding => (defined($mycgi->param("funding"))) ? $mycgi->param("funding") : 0,
       fromyear => (defined($mycgi->param("fromyear"))) ? $mycgi->param("fromyear") : 0,
       toyear => (defined($mycgi->param("toyear"))) ? $mycgi->param("toyear") : 0,
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


END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS,includeJSUtilities => 'T', includeJSWidgets => 'F',);
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
sub doUpdateChargeNumberSelect {  # routine to generate a select box of ChargeNumbers for update
###################################################################################################################################
    my %args = (
        browseOnly => 'F',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my @CNs = &getChargeNumberArray(dbh=>$args{dbh}, schema=>$args{schema}, onlyFY=>$settings{onlyfy});
    my $selectedID = 0;

    $output .= <<END_OF_BLOCK;
<table border=0 width=680 align=center>
<tr><td colspan=4 align=center>
<table border=0>
END_OF_BLOCK
    $output .= "<tr><td align=center><b>Limit to Current Fiscal Year? &nbsp; ";
    $output .= "<input type=radio name=onlyfy value='T'" . (($settings{onlyfy} eq 'T') ? " checked" : "") . ">True &nbsp; ";
    $output .= "<input type=radio name=onlyfy value='F'" . (($settings{onlyfy} eq 'F') ? " checked" : "") . ">False &nbsp; ";
    $output .= "<input type=button name=cnrefresh value='Refresh' onClick=refresh()></td></tr>\n";
    $output .= "<tr><td><table border=1 cellpadding=2 cellspacing=0 align=center>\n";
    $output .= "<tr bgcolor=#a0e0c0><td><b>Charge Number</b></td><td><b>Year</b></td><td><b>Site&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></td><td><b>Description</b></td><td><b>Funding</b></td><td><b>Committed</b></tr>\n";
    for (my $i=0; $i < $#CNs; $i++) {
        $output .= "<tr bgcolor=#ffffff><td><a href=\"javascript:" . (($args{browseOnly} eq 'F') ? "update" : "browse") . "ChargeNumber('$CNs[$i]{chargenumber}');\">";
        $output .= "$CNs[$i]{chargenumber}</a></td><td>$CNs[$i]{fyscalyear}</td><td>$CNs[$i]{companycode}-$CNs[$i]{sitecode}</td><td>$CNs[$i]{description}</td>";
        $output .= (($CNs[$i]{trackfunding} eq 'T') ? "<td align=right>\$" . dFormat($CNs[$i]{funding}) : "<td align=center>n/a") . "</td>";
        $output .= "<td align=right>\$" . dFormat(&getApprovedAmount(dbh=>$args{dbh}, schema=>$args{schema}, id=>$CNs[$i]{chargenumber})) . "</td></tr>\n";
    }
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function updateChargeNumber (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'updatecnform');
}

function browseChargeNumber (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'displaycn');
}

function refresh () {
    submitForm('$args{form}', '$settings{command}');
}
//--></script>

</table>
</td></tr>
</table>
END_OF_BLOCK
    

    return($output);
}


###################################################################################################################################
sub doChargeNumberEntryForm {  # routine to generate a ChargeNumber data entry/update form
###################################################################################################################################
    my %args = (
        type => 'new',
        browseOnly => 'F',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %CN;
    my $id = $settings{id};
    if ($args{type} eq 'update' || $args{browseOnly} eq 'T') {
        %CN = &getCNInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$id);
    } else {
        $CN{chargenumber} = "";
        $CN{fyscalyear} = "";
        $CN{site} = 0;
        $CN{description} = "";
        $CN{wbs} = "";
    }

    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td colspan=2 align=center><table border=0>\n";
    $output .= "<input type=hidden name=oldchargenumber value='$id'>\n";
    $output .= "<tr><td><b>Charge Number: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=chargenumber value=\"$CN{chargenumber}\" maxlength=50 size=40>";
    } else {
        $output .= "$CN{chargenumber}";
    }
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>Fiscal Year: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=fyscalyear value=\"$CN{fyscalyear}\" maxlength=4 size=4>";
    } else {
        $output .= "$CN{fyscalyear}";
    }
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>Site: </b>&nbsp</td><td>\n";
    if ($args{browseOnly} ne 'T') {
        if ($args{type} eq 'new') {
            my @sites = &getSiteInfoArray(dbh=>$args{dbh}, schema=>$args{schema});
            $output .= "<select size=1 name=site><option value=0>Please select a site</option>\n";
            for (my $i=1; $i<=$#sites; $i++) {
                $output .= "<option value=$sites[$i]{id}" . (($CN{site} == $sites[$i]{id}) ? " selected" : "") . ">$sites[$i]{name}</option>\n";
            }
            $output .= "</select>\n";
        } else {
            $output .= "$CN{sitecode}<input type=hidden name=site value=$CN{site}>\n";
        }
    } else {
        $output .= "$CN{companycode}-$CN{sitecode}";
    }
    $output .= "</td></tr>\n";
    $output .= "<tr><td><b>Description: </b>&nbsp;</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=description value=\"$CN{description}\" maxlength=50 size=50>";
    } else {
        $output .= "$CN{description}";
    }
    $output .= "</td></tr>\n";
    $output .= "<tr><td><b>WBS: </b>&nbsp;</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=wbs size=13 maxlength=13 value='" . ((defined($CN{wbs})) ? $CN{wbs} : "") . "'>";
    } else {
        $output .= ((defined($CN{wbs})) ? $CN{wbs} : "");
    }
    $output .= "</td></tr>\n";
    $output .= "<tr><td><b>Funding: </b>&nbsp;</td><td>";
    if ($CN{trackfunding} eq 'T') {
        if ($args{browseOnly} ne 'T') {
            $output .= "<input type=text name=funding size=14 maxlength=14 value='" . dFormat(((defined($CN{funding})) ? $CN{funding} : "0")) . "'>";
        } else {
            $output .= dFormat(((defined($CN{funding})) ? $CN{funding} : "0"));
        }
    } else {
        $output .= "n/a";
        $output .= "<input type=hidden name=funding value=0>";
    }
    $output .= "</td></tr>\n";
    if ($args{browseOnly} ne 'T') {
        $output .= "<tr><td colspan=2 align=center><input type=button name=cnsubmit value='Submit' onClick=verifySubmit(document.$args{form})></td></tr>\n";
    }
    
    $output .= "</table>\n";
    
    my $nextCommand = (($args{type} eq 'new') ? "addcn" : "updatecn");
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    if (isblank(f.chargenumber.value) || isblank(f.fyscalyear.value) || isblank(f.description.value)) {
      msg += "Charge Number, Fiscal Year, and Description must be entered.\\n";
    }
    if ('$args{type}' == 'new' && f.site[0].selected) {
      msg += "Site must be selected.\\n";
    }
    if (!isnumeric(f.fyscalyear.value) || f.fyscalyear.value < '2000' || f.fyscalyear.value > '2200') {
      msg += "Fiscal Year must be a value of the form \\'YYYY\\'.\\n";
    }
    if (msg != "") {
      alert (msg);
    } else {
      submitFormCGIResults('$args{form}', '$nextCommand');
    }
}
//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doChargeNumberEntry {  # routine to get charge number entry/update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my ($status, $id) = &doProcessChargeNumberEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, settings => \%settings);

    if ($args{type} eq 'new') {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "charge number $id inserted", type => 23);
    } else {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "charge number $id updated", type => 24);
    }
    $output .= "<script language=javascript><!--\n";
    #$output .= "   document.$args{form}.id.value='$id';\n";
    $output .= "   submitForm('$args{form}','updatecnselect');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doChargeNumberCopyForm {  # routine to generate a ChargeNumber copy form
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %CN;
    my $id = $settings{id};
    my $thisYear = &getFY();
    my $nextYear = $thisYear + 1;

    $output .= "<input type=hidden name=currentfy value=$thisYear>\n";
    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td colspan=2 align=center><table border=0>\n";
    $output .= "<tr><td><b>From Year: </b>&nbsp</td><td>";
    $output .= "<input type=text name=fromyear value=\"$CN{chargenumber}\" maxlength=4 size=5>";
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>To Year: </b>&nbsp</td><td>";
    $output .= "<input type=text name=toyear value=\"$CN{fyscalyear}\" maxlength=4 size=5>";
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>Site: </b>&nbsp</td><td>\n";
    my @sites = &getSiteInfoArray(dbh=>$args{dbh}, schema=>$args{schema});
    $output .= "<select size=1 name=site><option value=0>Please select a site</option>\n";
    for (my $i=1; $i<=$#sites; $i++) {
        $output .= "<option value=$sites[$i]{id}" . (($CN{site} == $sites[$i]{id}) ? " selected" : "") . ">$sites[$i]{name}</option>\n";
    }
    $output .= "</select>\n";
    $output .= "</td></tr>\n";
    $output .= "<tr><td colspan=2 align=center><input type=button name=cnsubmit value='Submit' onClick=verifySubmit(document.$args{form})></td></tr>\n";
    
    $output .= "</table>\n";
    
    my $nextCommand = "copycn";
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    if (isblank(f.fromyear.value) || isblank(f.toyear.value) || !isnumeric(f.fromyear.value) || !isnumeric(f.toyear.value) ||
          f.fromyear.value < '2000' || f.fromyear.value > '2200' || f.toyear.value < '2000' || f.toyear.value > '2200') {
      msg += "From and To Years must be entered with a value of the form \\'YYYY\\'.\\n";
    }
    if (!isblank(f.fromyear.value) && !isblank(f.toyear.value) && f.fromyear.value == f.toyear.value) {
      msg += "From and To Years must be different\\n";
    }
    if (!isblank(f.fromyear.value) && f.fromyear.value > $thisYear) {
      msg += "From Year can not be in the future\\n";
    }
    if (!isblank(f.toyear.value) && (f.toyear.value < $thisYear || f.toyear.value > $nextYear)) {
      msg += "To Year can only be this year or next year.\\n";
    }
    if (f.site[0].selected) {
      msg += "Site must be selected.\\n";
    }
    if (msg != "") {
      alert (msg);
    } else {
      submitFormCGIResults('$args{form}', '$nextCommand');
    }
}
//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doChargeNumberCopy {  # routine to copy charge number entry/update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my ($status) = &doProcessChargeNumberCopy(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          settings => \%settings);

    $message = "charge numbers Copied for site $settings{site} from $settings{fromyear} to $settings{toyear}"
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => $message, type => 24);
    $output .= "<script language=javascript><!--\n";
    #$output .= "   document.$args{form}.id.value='$id';\n";
    $output .= "   submitForm('$args{form}','copycnform');\n";
    $output .= "//--></script>\n";

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
###################################################################################################################################



1; #return true
