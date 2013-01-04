# UI Department functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UISites.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2008/02/11 18:20:29 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UISites.pm,v $
# Revision 1.2  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.1  2004/01/12 20:17:03  atchleyb
# Initial revision
#
#
#
#
#
#

package UISites;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBSites qw(:Functions);
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
      &getInitialValues       &doHeader             &doUpdateSiteSelect
      &doFooter               &getTitle             &doSiteEntryForm
      &doSiteEntry
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doUpdateSiteSelect
      &doFooter               &getTitle             &doSiteEntryForm
      &doSiteEntry
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
   if (($args{command} eq "addsite") || ($args{command} eq "addsiteform")) {
      $title = "Add Site";
   } elsif (($args{command} eq "updatesite") || ($args{command} eq "updatesiteform") || ($args{command} eq "updatesiteselect")) {
      $title = "Update Site";
   } elsif (($args{command} eq "browse") || (($args{command} eq "displaysite")) || ($args{command} eq "displaysiteform")) {
      $title = "Browse Site";
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
       siteid => (defined($mycgi->param("siteid"))) ? $mycgi->param("siteid") : 0,
       name => (defined($mycgi->param("name"))) ? $mycgi->param("name") : "",
       shortname => (defined($mycgi->param("shortname"))) ? $mycgi->param("shortname") : "",
       longname => (defined($mycgi->param("longname"))) ? $mycgi->param("longname") : "",
       companycode => (defined($mycgi->param("companycode"))) ? $mycgi->param("companycode") : "",
       organization => (defined($mycgi->param("organization"))) ? $mycgi->param("organization") : "",
       address => (defined($mycgi->param("address"))) ? $mycgi->param("address") : "",
       city => (defined($mycgi->param("city"))) ? $mycgi->param("city") : "",
       state => (defined($mycgi->param("state"))) ? $mycgi->param("state") : "",
       zip => (defined($mycgi->param("zip"))) ? $mycgi->param("zip") : "",
       daddress => (defined($mycgi->param("daddress"))) ? $mycgi->param("daddress") : "",
       dcity => (defined($mycgi->param("dcity"))) ? $mycgi->param("dcity") : "",
       dstate => (defined($mycgi->param("dstate"))) ? $mycgi->param("dstate") : "",
       dzip => (defined($mycgi->param("dzip"))) ? $mycgi->param("dzip") : "",
       phone => (defined($mycgi->param("phone"))) ? $mycgi->param("phone") : "",
       fax => (defined($mycgi->param("fax"))) ? $mycgi->param("fax") : "",
       contractnumber => (defined($mycgi->param("contractnumber"))) ? $mycgi->param("contractnumber") : "",
       salestax => (defined($mycgi->param("salestax"))) ? $mycgi->param("salestax") : 0.0,
       taxexempt => (defined($mycgi->param("taxexempt"))) ? $mycgi->param("taxexempt") : "F",
       sitecode => (defined($mycgi->param("sitecode"))) ? $mycgi->param("sitecode") : "",
       trackfunding => (defined($mycgi->param("trackfunding"))) ? $mycgi->param("trackfunding") : "F",
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
sub doUpdateSiteSelect {  # routine to generate a select box of Sites for update
###################################################################################################################################
    my %args = (
        browseOnly => 'F',
        @_,
    );
    my $output = "";
    my @sites = getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});
    my $selectedID = 0;

    $output .= <<END_OF_BLOCK;
<table border=0 width=680 align=center>
<tr><td colspan=4 align=center>
<table border=0>
END_OF_BLOCK
    $output .= "<tr><td><table border=1 cellpadding=2 cellspacing=0 align=center>\n";
    $output .= "<tr bgcolor=#a0e0c0><td><b>Name</b></td></tr>\n";
    for (my $i=1; $i <= $#sites; $i++) {
        $output .= "<tr bgcolor=#ffffff><td><a href=javascript:" . (($args{browseOnly} eq 'F') ? "update" : "browse") . "Site($sites[$i]{id})>";
        $output .= "$sites[$i]{name}</a></td></tr>\n";
    }
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function updateSite (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'updatesiteform');
}

function browseSite (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'displaysite');
}
//--></script>

</table>
</td></tr>
</table>
END_OF_BLOCK
    

    return($output);
}


###################################################################################################################################
sub doSiteEntryForm {  # routine to generate a Site data entry/update form
###################################################################################################################################
    my %args = (
        type => 'new',
        browseOnly => 'F',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %site;
    my $id = $settings{id};
    if ($args{type} eq 'update' || $args{browseOnly} eq 'T') {
        %site = &getSiteInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$id);
    } else {
        $site{id} = 0;
        $site{name} = "";
        $site{site} = 0;
        $site{shortname} = "";
        $site{longname} = "";
        $site{companycode} = "";
        $site{organization} = "";
        $site{address} = "";
        $site{city} = "";
        $site{state} = "";
        $site{zip} = "";
        $site{daddress} = "";
        $site{dcity} = "";
        $site{dstate} = "";
        $site{dzip} = "";
        $site{phone} = "";
        $site{fax} = "";
        $site{contractnumber} = "";
        $site{salestax} = 0;
        $site{taxexempt} = "F";
        $site{sitecode} = "";
        $site{trackfunding} = "F";
    }

    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td colspan=2 align=center><table border=0>\n";
    $output .= "<input type=hidden name=siteid value=$id>\n";
# name info
    $output .= "<tr><td><b>Name: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=name value=\"$site{name}\" maxlength=50 size=40>";
    } else {
        $output .= "$site{name}";
    }
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>Short Name: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=shortname value=\"$site{shortname}\" maxlength=10 size=10>";
    } else {
        $output .= "$site{shortname}";
    }
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>Long Name: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=longname value=\"$site{longname}\" maxlength=50 size=40>";
    } else {
        $output .= "$site{longname}";
    }
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>Company Code: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=companycode value=\"$site{companycode}\" maxlength=2 size=2>";
    } else {
        $output .= "$site{companycode}";
    }
    $output .= "</td><tr>\n";
# site code
    $output .= "<tr><td><b>Site Code: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=sitecode value=\"$site{sitecode}\" maxlength=2 size=2>";
    } else {
        $output .= "$site{sitecode}";
    }
    $output .= "</td><tr>\n";
#organization
    $output .= "<tr><td><b>Organization: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=organization value=\"$site{organization}\" maxlength=50 size=40>";
    } else {
        $output .= "$site{organization}";
    }
    $output .= "</td><tr>\n";
# Address info
    $output .= "<tr><td><b>Address: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<textarea name=address cols=50 rows=2>$site{address}</textarea>";
    } else {
        $site{address} =~ s/\n/<br>\n/g;
        $site{address} =~ s/  / &nbsp;\n/g;
        $output .= "$site{address}";
    }
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>City: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=city value=\"$site{city}\" maxlength=50 size=40>";
    } else {
        $output .= "$site{city}";
    }
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>State: </b>&nbsp</td><td>";
    my @states = &getStateArray(dbh=>$args{dbh}, schema=>$args{schema});
    if ($args{browseOnly} ne 'T') {
        $output .= "<select name=state><option value=''> </option>\n";
        for (my $i=0; $i<=$#states; $i++) {
            $output .= "<option value=$states[$i]{abbreviation}" . (($states[$i]{abbreviation} eq $site{state}) ? " selected" : "") . ">$states[$i]{name}</option>\n";
        }
        $output .= "</select>\n";
    } else {
        $output .= "$site{state}";
    }
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>Zip: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=zip value=\"$site{zip}\" maxlength=10 size=10>";
    } else {
        $output .= "$site{zip}";
    }
    $output .= "</td><tr>\n";
# Delivery Address info
    $output .= "<tr><td><b>Delivery Address: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<textarea name=daddress cols=50 rows=2>$site{daddress}</textarea>";
    } else {
        $site{address} =~ s/\n/<br>\n/g;
        $site{address} =~ s/  / &nbsp;\n/g;
        $output .= "$site{daddress}";
    }
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>Delivery City: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=dcity value=\"$site{dcity}\" maxlength=50 size=40>";
    } else {
        $output .= "$site{dcity}";
    }
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>Delivery State: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<select name=dstate><option value=''> </option>\n";
        for (my $i=0; $i<=$#states; $i++) {
            $output .= "<option value=$states[$i]{abbreviation}" . (($states[$i]{abbreviation} eq $site{dstate}) ? " selected" : "") . ">$states[$i]{name}</option>\n";
        }
        $output .= "</select>\n";
    } else {
        $output .= "$site{dstate}";
    }
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>Delivery Zip: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=dzip value=\"$site{dzip}\" maxlength=10 size=10>";
    } else {
        $output .= "$site{dzip}";
    }
    $output .= "</td><tr>\n";
# phone info
    $output .= "<tr><td><b>Phone: </b>&nbsp</td><td>";
    my $phone = "(" . substr($site{phone}, 0,3) . ") " . substr($site{phone}, 3, 3) . "-" . substr($site{phone}, 6, 4);
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=phone value=\"$phone\" maxlength=14 size=14>";
    } else {
        $output .= "$phone";
    }
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>FAX: </b>&nbsp</td><td>";
    my $fax = "(" . substr($site{fax}, 0,3) . ") " . substr($site{fax}, 3, 3) . "-" . substr($site{fax}, 6, 4);
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=fax value=\"$fax\" maxlength=14 size=14>";
    } else {
        $output .= "$fax";
    }
    $output .= "</td><tr>\n";
# contract
    $output .= "<tr><td><b>Contract Number: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=contractnumber value=\"$site{contractnumber}\" maxlength=50 size=40>";
    } else {
        $output .= "$site{contractnumber}";
    }
    $output .= "</td><tr>\n";
# tax
    $output .= "<tr><td><b>Sales Tax: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=text name=salestax value=\"$site{salestax}\" maxlength=6 size=6>";
    } else {
        $output .= "%$site{salestax}";
    }
    $output .= "</td><tr>\n";
    $output .= "<tr><td><b>Tax Exempt: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=radio name=taxexempt value='T'" . (($site{taxexempt} eq 'T') ? "checked" : "") . ">True &nbsp; ";
        $output .= "<input type=radio name=taxexempt value='F'" . (($site{taxexempt} eq 'F') ? "checked" : "") . ">False";
    } else {
        $output .= (($site{taxexempt} eq 'T') ? "True" : "False");
    }
    $output .= "</td><tr>\n";
# track funding
    $output .= "<tr><td><b>Track Funding: </b>&nbsp</td><td>";
    if ($args{browseOnly} ne 'T') {
        $output .= "<input type=radio name=trackfunding value='T'" . (($site{trackfunding} eq 'T') ? "checked" : "") . ">True &nbsp; ";
        $output .= "<input type=radio name=trackfunding value='F'" . (($site{trackfunding} eq 'F') ? "checked" : "") . ">False";
    } else {
        $output .= (($site{taxexempt} eq 'T') ? "True" : "False");
    }
    $output .= "</td><tr>\n";
# submit
    if ($args{browseOnly} ne 'T') {
        $output .= "<tr><td colspan=2 align=center><input type=button name=sitesubmit value='Submit' onClick=verifySubmit(document.$args{form})></td></tr>\n";
    }
    
    $output .= "</table>\n";
    
    my $nextCommand = (($args{type} eq 'new') ? "addsite" : "updatesite");
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

// function that returns true if a string contains only numbers
function isFloat(s) {
    if (s.length == 0) return false;
    var d=0;
    for(var i = 0; i < s.length; i++) {
        var c = s.charAt(i);
        if (c == '.') d++;
        if (((c != '.') && ((c < '0') || (c > '9'))) ||  d > 1) return false;
    }

    return true;
}

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    if (isblank(f.name.value) || isblank(f.shortname.value) || isblank(f.longname.value) || isblank(f.companycode.value) || 
        isblank(f.organization.value) || isblank(f.address.value) || isblank(f.city.value) || isblank(f.state.value) || 
        isblank(f.zip.value) || isblank(f.daddress.value) || isblank(f.dcity.value) || isblank(f.dstate.value) || 
        isblank(f.dzip.value) || isblank(f.phone.value) || isblank(f.fax.value) || isblank(f.contractnumber.value) || 
        isblank(f.salestax.value) || isblank(f.sitecode.value)) {
      msg += "All form fields must be entered.\\n";
    }
    if (f.address.value.length > 100) {
      msg += "Address must be 100 characters or less.\\n";
    }
    if (f.daddress.value.length > 100) {
      msg += "Delivery Address must be 100 characters or less.\\n";
    }
    var phone = f.phone.value;
    phone = phone.replace(/[() \-]/g, "");
    if (phone.length != 10 || !isnumeric(phone)) {
      msg += "Phone must be of the format (999) 999-9999 or 999-999-9999.\\n";
    }
    var fax = f.fax.value;
    fax = fax.replace(/[() \-]/g, "");
    if (fax.length != 10 || !isnumeric(fax)) {
      msg += "FAX must be of the format (999) 999-9999 or 999-999-9999.\\n";
    }
    if (!isFloat(f.salestax.value)) {
      msg += "Sales Tax must be a number of the for 99.999.\\n";
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
sub doSiteEntry {  # routine to get site entry/update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my ($status, $id) = &doProcessSiteEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, settings => \%settings);

    if ($args{type} eq 'new') {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "site $id inserted", type => 12);
    } else {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "site $id updated", type => 13);
    }
    $output .= "<script language=javascript><!--\n";
    $output .= "   document.$args{form}.id.value=$id;\n";
    $output .= "   submitForm('$args{form}','updatesiteform');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
