# UI Vendor functions
#
# $Source: /data/dev/rcs/mms/perl/RCS/UIVendors.pm,v $
#
# $Revision: 1.5 $
#
# $Date: 2006/01/31 23:01:25 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIVendors.pm,v $
# Revision 1.5  2006/01/31 23:01:25  atchleyb
# CR 0022 updated to change so that vendor name sort on browse would be cas independent
# CR 0022 changed text on note for relating vendors
#
# Revision 1.4  2005/08/18 19:52:35  atchleyb
# CR00015 - extended the length of the phone number form fields
#
# Revision 1.3  2005/06/10 23:16:18  atchleyb
# CR0011
# updated to use site name instead of site code for tax id's
#
# Revision 1.2  2004/05/05 23:27:47  atchleyb
# forced vendors to have a remit address
#
# Revision 1.1  2003/11/12 20:35:51  atchleyb
# Initial revision
#
#
#
#
#

package UIVendors;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBVendors qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
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
      &getInitialValues       &doHeader             &doUpdateVendorSelect
      &doFooter               &getTitle             &doVendorEntryForm
      &doVendorEntry          &doBrowse             &doDisplayVendor
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doUpdateVendorSelect
      &doFooter               &getTitle             &doVendorEntryForm
      &doVendorEntry          &doBrowse             &doDisplayVendor
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
   if (($args{command} eq "addvendor") || ($args{command} eq "addvendorform")) {
      $title = "Add Vendor";
   } elsif (($args{command} eq "updatevendor") || ($args{command} eq "updatevendorform") || ($args{command} eq "updatevendorselect")) {
      $title = "Update Vendor";
   } elsif (($args{command} eq "browse") || (($args{command} eq "displayvendor")) || ($args{command} eq "displayvendorform")) {
      $title = "Browse Vendor";
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
       vendorid => (defined($mycgi->param("vendorid"))) ? $mycgi->param("vendorid") : 0,
       v_vendorid => (defined($mycgi->param("v_vendorid"))) ? $mycgi->param("v_vendorid") : 0,
       vendor => (defined($mycgi->param("vendor"))) ? $mycgi->param("vendor") : "",
       vendorstatus => (defined($mycgi->param("vendorstatus"))) ? $mycgi->param("vendorstatus") : 0,
       name => (defined($mycgi->param("name"))) ? $mycgi->param("name") : "",
       mainphone => (defined($mycgi->param("mainphone"))) ? $mycgi->param("mainphone") : "",
       url => (defined($mycgi->param("url"))) ? $mycgi->param("url") : "",
       mainproduct => (defined($mycgi->param("mainproduct"))) ? $mycgi->param("mainproduct") : "",
       address => (defined($mycgi->param("address"))) ? $mycgi->param("address") : "",
       city => (defined($mycgi->param("city"))) ? $mycgi->param("city") : "",
       state => (defined($mycgi->param("state")) && $mycgi->param("state") ne '0') ? $mycgi->param("state") : "",
       zip => (defined($mycgi->param("zip"))) ? $mycgi->param("zip") : "",
       country => (defined($mycgi->param("country"))) ? $mycgi->param("country") : "",
       remitaddress => (defined($mycgi->param("remitaddress"))) ? $mycgi->param("remitaddress") : "",
       remitcity => (defined($mycgi->param("remitcity"))) ? $mycgi->param("remitcity") : "",
       remitstate => (defined($mycgi->param("remitstate")) && $mycgi->param("remitstate") ne '0') ? $mycgi->param("remitstate") : "",
       remitzip => (defined($mycgi->param("remitzip"))) ? $mycgi->param("remitzip") : "",
       pointofcontact => (defined($mycgi->param("pointofcontact"))) ? $mycgi->param("pointofcontact") : "",
       phone => (defined($mycgi->param("phone"))) ? $mycgi->param("phone") : "",
       extension => (defined($mycgi->param("extension"))) ? $mycgi->param("extension") : "",
       fax => (defined($mycgi->param("fax"))) ? $mycgi->param("fax") : "",
       email => (defined($mycgi->param("email"))) ? $mycgi->param("email") : "",
       relatedto => (defined($mycgi->param("relatedto"))) ? $mycgi->param("relatedto") : 0,
       relationship => (defined($mycgi->param("relationship"))) ? $mycgi->param("relationship") : "",
       comments => (defined($mycgi->param("comments"))) ? $mycgi->param("comments") : "",
       sitecount => (defined($mycgi->param("sitecount"))) ? $mycgi->param("sitecount") : 0,
       showbidders => (defined($mycgi->param("showbidders"))) ? $mycgi->param("showbidders") : 'F',
       showactive => (defined($mycgi->param("showactive"))) ? $mycgi->param("showactive") : 'F',
       showarchived => (defined($mycgi->param("showarchived"))) ? $mycgi->param("showarchived") : 'F',
    ));

    my @classifications = $mycgi->param("classifications");
    $valueHash{classifications} = \@classifications;
    for (my $i=1; $i<=$valueHash{sitecount}; $i++) {
        $valueHash{"hastaxid$i"} = (defined($mycgi->param("hastaxid$i"))) ? $mycgi->param("hastaxid$i") : "F";
        $valueHash{"taxid$i"} = (defined($mycgi->param("taxid$i"))) ? $mycgi->param("taxid$i") : "";
        $valueHash{"effectivedate$i"} = (defined($mycgi->param("effectivedate$i"))) ? $mycgi->param("effectivedate$i") : "";
    }
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


END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              includeJSCalendar => $args{includeJSCalendar},
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS,includeJSUtilities => 'T', includeJSWidgets => 'T',);
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
sub doBrowse {  # routine to generate a table of vendors for browse
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %listTypes = (
        'Name' => 'LOWER(name), city, state',
        'Main Product' => 'mainproduct, LOWER(name), city, state',
    );
    my @vendors;
    my $statusList = '';
    if ($settings{showbidders} eq 'T') {$statusList .= ',1';}
    if ($settings{showactive} eq 'T') {$statusList .= ',2';}
    if ($settings{showarchived} eq 'T') {$statusList .= ',3';}
    $statusList = substr($statusList,1);
    foreach my $key (sort keys %listTypes) {
        @vendors = &getVendorList(dbh => $args{dbh}, schema => $args{schema}, orderBy=>$listTypes{$key}, activeOnly=>'F', statusList=>$statusList);
        my $currLetter = ' ';
        my $text = "<table align=center border=0><tr><td>\n";
        my $textInner = '';
        for (my $i=0; $i<=$#vendors; $i++) {
            my $vendName = "";
            if ($key eq 'Name') {
                $vendName = "$vendors[$i]{name} - $vendors[$i]{city}, $vendors[$i]{state} - $vendors[$i]{mainproduct}";
            } else {
                $vendName = "$vendors[$i]{mainproduct} - $vendors[$i]{name} - $vendors[$i]{city}, $vendors[$i]{state}";
            }
            my $letter = substr($vendName, 0, 1);
            if ($currLetter ne lc($letter)) {
                if ($currLetter ne ' ') {
                    $text .= &buildSectionBlock(title=> "<b>" . uc($currLetter) . "</b>", contents=>$textInner);
                }
                $currLetter = lc($letter);
                $textInner = '';
            }
            $textInner .= "<a href=\"javascript:browseVendor($vendors[$i]{id});\">$vendName</a><br>\n";
        }
        $text .= "</td></tr></table>\n";
        $output .= &buildSectionBlock(title=> "<b>$key</b>", contents=>$text);
    }
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function browseVendor (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'displayvendor');
}
//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doDisplayVendor {  # routine to display a vendor
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my @siteInfo = &getSiteInfoArray(dbh=>$args{dbh}, schema=>$args{schema});
    my $output = "";
    my %vendor = &getVendorInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$settings{id});
    
    $output .= "<table align=center border=0>\n";
    $output .= "<tr><td><b>ID:</b></td><td>$vendor{id}</td></tr>\n";
    $output .= "<tr><td><b>Name:</b></td><td>$vendor{name}</td></tr>\n";
    $output .= "<tr><td><b>Main Phone:</b></td><td>$vendor{mainphone}</td></tr>\n";
    $output .= "<tr><td><b>URL:</b></td><td>$vendor{url}</td></tr>\n";
    $output .= "<tr><td><b>Main Product:  </b></td><td>$vendor{mainproduct}</td></tr>\n";
    $output .= "<tr><td valign=top><b>Address:</b></td><td>";
    $vendor{address} =~ s/\n/<br>\n/g;
    $output .= $vendor{address};
    $output .= ((defined($vendor{city})) ? "<br>$vendor{city}" : "") . ((defined($vendor{state})) ? ", $vendor{state}" : "");
    $output .= ((defined($vendor{zip})) ? " $vendor{zip}" : "") . ((defined($vendor{country})) ? "<br>$vendor{country}" : "");
    $output .= "</td></tr>\n";
    $output .= "<tr><td valign=top><b>Remit Address:</b></td><td>";
    $vendor{remitaddress} =~ s/\n/<br>\n/g;
    $output .= $vendor{remitaddress};
    $output .= ((defined($vendor{remitcity})) ? "<br>$vendor{remitcity}" : "") . ((defined($vendor{remitstate})) ? ", $vendor{remitstate}" : "");
    $output .= ((defined($vendor{remitzip})) ? " $vendor{remitzip}" : "");
    $output .= "</td></tr>\n";
    $output .= "<tr><td valign=top><b>Point of Contact: </b></td><td>$vendor{pointofcontact}";
    $output .= ((defined($vendor{phone})) ? "<br>Phone: $vendor{phone}" : "") . ((defined($vendor{extension})) ? " - $vendor{extension}" : "");
    $output .= ((defined($vendor{fax})) ? "<br>FAX: $vendor{fax}" : "");
    $output .= ((defined($vendor{email})) ? "<br>$vendor{email}" : "");
    $output .= "</td></tr>\n";
    $output .= "<tr><td valign=top><b>Related Vendor: </b></td><td>";
    my %relatedVendor = &getVendorInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$vendor{relatedto});
    $output .= "$relatedVendor{name}<br>$vendor{relationship}</td></tr>\n";
    $output .= "<tr><td valign=top><b>Classifications: </b></td><td>";
    my $classString = '';
    for (my $i=0; $i<$vendor{classificationCount}; $i++) {
        $classString .= (($i>0) ? ", " : "") . $vendor{classifications}[$i]{name};
    }
    $output .= "$classString</td></tr>\n";
    $output .= "<tr><td valign=top><b>Tax Permits: </b></td><td>";
    $output .= "<table border=0 width=100%>\n";
    $output .= "<tr><td><b>Site</b></td><td>" . &nbspaces(5) . "</td>";
    $output .= "<td align=center><b>Has Tax ID</b></td><td>" . &nbspaces(5) . "</td>";
    $output .= "<td align=center><b>Tax ID</b></td><td>" . &nbspaces(5) . "</td>";
    $output .= "<td><b align=center>EffectiveDate</b></td></tr>\n";
    for (my $i=1; $i<=$vendor{siteCount}; $i++) {
        $output .= "<tr><td><b>$siteInfo[$i]{name}</b></td><td> </td>\n";
        $output .= "<td align=center>" . (($vendor{taxpermits}[$i]{hastaxid} eq 'T') ? " Yes" : "No") . "</td><td> </td>\n";
        $output .= "<td align=center>$vendor{taxpermits}[$i]{taxid}</td><td> </td>\n";
        $output .= "<td align=center>$vendor{taxpermits}[$i]{effectivedate}</td>\n";
        $output .= "</tr>\n";
    }
    $output .= "</table></td></tr>\n";
    $output .= "<tr><td valign=top><b>Comments: </b></td><td>\n";
    $output .= "<table border=0 cellspacing=0 cellpadding=0>\n";
    for (my $i=0; $i<$vendor{commentCount}; $i++) {
        $output .= "<tr><td>$vendor{comments}[$i]{dateentered} - " . &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$vendor{comments}[$i]{enteredby}) . "<br>\n";
        $vendor{comments}[$i]{text} =~ s/\n/<br>\n/g;
        $output .= "$vendor{comments}[$i]{text}</td></tr>\n";
    }
    $output .= "</table></td></tr>\n";
    $output .= "<tr><td><b>Date Created</b></td><td>$vendor{datecreated}</td></tr>\n";
    $output .= "<tr><td><b>Last Used</b></td><td>$vendor{lastused}</td></tr>\n";
    


    $output .= "</table>\n";
    

    return($output);
}


###################################################################################################################################
sub doUpdateVendorSelect {  # routine to generate a select box of Vendors for update
###################################################################################################################################
    my %args = (
        selectedVendor => 0,
        onlyActive => 'F',
        command => 'updatevendorform',
        commandText => "Retrieve Vendor",
        target => "",
        @_,
    );
    my $output = "";
    my @vendors = getVendorList(dbh => $args{dbh}, schema => $args{schema});
    my $selectedID = 0;

    $output .= <<END_OF_BLOCK;
<table border=0 width=680 align=center>
<tr><td colspan=4 align=center>
<table border=0>
END_OF_BLOCK
    $output .= "<tr><td><b>Select Vendor: </b>&nbsp;</td><td><select name=v_vendorid size=1>\n";
    $output .= "<option value=0></option>\n";
    for (my $i=0; $i < $#vendors; $i++) {
        my ($id, $name, $city, $state, $mainproduct) = ($vendors[$i]{id},$vendors[$i]{name},$vendors[$i]{city},$vendors[$i]{state},$vendors[$i]{mainproduct});
        my $selected = "";
        if ($id == $args{selectedVendor}) {
            $selected = "selected";
            $selectedID = $i;
        }
        $output .= "<option value='$id' $selected>$name - " . ((defined($city)) ? $city : "") . ", " . ((defined($state)) ? $state : "") . "</option>\n";
    }
    $output .= "</select></td>\n";
    my $target = (($args{target} gt "") ? "document.$args{form}.target.value='$args{target}';" : "");
    $output .= <<END_OF_BLOCK;
<td>&nbsp;<input type=submit name="updatevendor" value="$args{commandText}" onClick="document.$args{form}.command.value='$args{command}';$target"></td></tr>
END_OF_BLOCK
    if ($args{selectedVendor} != 0) {
        $output .= "<tr><td><b>Name:</b></td><td><b>$vendors[$selectedID]{name}</b></td></tr>";
        $output .= "<tr><td><b>ID:</b></td><td><b>$vendors[$selectedID]{id}</b></td></tr>";
        $output .= "<tr><td><b>Status:</b></td><td><b>";
        if ($vendors[$selectedID]{status} == 1) {
            $output .= "Bidder";
        } elsif ($vendors[$selectedID]{status} == 2) {
            $output .= "Active";
        } elsif ($vendors[$selectedID]{status} == 3) {
            $output .= "Archive";
        }
        $output .= "</b></td></tr>";
    }
    $output .= <<END_OF_BLOCK;
</table>
</td></tr>
</table>
END_OF_BLOCK
    

    return($output);
}


###################################################################################################################################
sub doVendorEntryForm {  # routine to generate a Vendor data entry/update form
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my @siteInfo = &getSiteInfoArray(dbh=>$args{dbh}, schema=>$args{schema});
    my $output = "";
    my $text = "";
    my %vendor;
    my $id = $settings{v_vendorid};
    my $isVendorManager = &doesUserHaveRole(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, roleList=>[17]);
    if ($args{type} eq 'update') {
        $output .= &doUpdateVendorSelect(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, form => $args{form}, 
                                   userID => $args{userID}, settings => \%settings, selectedVendor => $id);
        %vendor = getVendorInfo(dbh => $args{dbh}, schema => $args{schema}, id=>$id);
    } else {
        %vendor = &createBlankVendor(dbh => $args{dbh}, schema => $args{schema});
    }

    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td><hr></td></tr>\n" if ($args{type} eq 'update');
    $output .= "<tr><td colspan=2><br></td></tr>\n" if ($args{type} eq 'update');
    $output .= "<tr><td colspan=2 align=center><table border=0 width=650>\n";
    $output .= "<input type=hidden name=vendorid value=$id>\n";
    $output .= "<input type=hidden name=vendorstatus value=$vendor{status}>\n";
    $output .= "<tr><td><b>Name: </b>&nbsp;</td><td><input type=text name=name value=\"$vendor{name}\" maxlength=50 size=50></td></tr>\n";
    $output .= "<tr><td><b>Main&nbsp;Phone: </b>&nbsp;</td><td><input type=text name=mainphone value=\"$vendor{mainphone}\" maxlength=20 size=15></td></tr>\n";
    $output .= "<tr><td><b>URL: </b>&nbsp;</td><td><input type=text name=url value=\"" . ((defined($vendor{url})) ? $vendor{url} : "") . "\" maxlength=100 size=80></td></tr>\n";
    $output .= "<tr><td><b>Main&nbsp;Product: </b>&nbsp;</td><td><input type=text name=mainproduct value=\"" . ((defined($vendor{mainproduct})) ? $vendor{mainproduct} : "") . "\" maxlength=50 size=50></td></tr>\n";
    $output .= "<tr><td colspan=2><table border=0 cellspacing=0 cellpadding=0 width=100%>\n";
    $output .= "<tr><td><b>Address</b></td><td><b>City</b></td><td><b>State</b></td><td><b>ZIP</b></td></tr>\n";
    $output .= "<tr>\n";
    $output .= "<td><textarea name=address cols=30 rows=4>$vendor{address}</textarea>&nbsp;</td>\n";
    $output .= "<td valign=top><input type=text name=city value=\"$vendor{city}\" maxlength=30 size=15>&nbsp;<br><br><b>Country:</b></td>\n";
    my @states = &getStateArray(dbh=>$args{dbh}, schema=>$args{schema});
    $output .= "<td valign=top><select name=state><option value=''> </option>\n";
    for (my $i=0; $i<=$#states; $i++) {
        $output .= "<option value=$states[$i]{abbreviation}" . (($states[$i]{abbreviation} eq $vendor{state}) ? " selected" : "") . ">$states[$i]{name}</option>\n";
    }
    $output .= "</select>&nbsp;<br><br>\n";
    my @countries = &getCountryArray(dbh=>$args{dbh}, schema=>$args{schema});
    $output .= "<select name=country><option value=''> </option>\n";
    for (my $i=0; $i<=$#countries; $i++) {
        $output .= "<option value=$countries[$i]{abbreviation}" . (($countries[$i]{abbreviation} eq $vendor{country}) ? " selected" : "") . ">$countries[$i]{name}</option>\n";
    }
    $output .= "</select>&nbsp;</td>\n";
    $output .= "<td valign=top><input type=text name=zip maxlength=10 size=10 value=\"$vendor{zip}\"></td>\n";
    $output .= "</tr>\n";
    $output .= "</table></td></tr>\n";
## Remit to
    $text = "<table border=0 cellspacing=0 cellpadding=0 width=100%>\n";
    $text .= "<tr><td><b>Address</b></td><td><b>City</b></td><td><b>State</b></td><td><b>ZIP</b></td></tr>\n";
    $text .= "<tr>\n";
    $text .= "<td><textarea name=remitaddress cols=30 rows=4>$vendor{remitaddress}</textarea>&nbsp;</td>\n";
    $text .= "<td valign=top><input type=text name=remitcity value=\"$vendor{remitcity}\" maxlength=30 size=15>&nbsp;</td>\n";
    $text .= "<td valign=top><select name=remitstate><option value=''> </option>\n";
    for (my $i=0; $i<=$#states; $i++) {
        $text .= "<option value=$states[$i]{abbreviation}" . (($states[$i]{abbreviation} eq $vendor{remitstate}) ? " selected" : "") . ">$states[$i]{name}</option>\n";
    }
    $text .= "</select>&nbsp;</td>\n";
    $text .= "<td valign=top><input type=text name=remitzip maxlength=10 size=10 value=\"$vendor{remitzip}\"></td>\n";
    $text .= "</tr>\n";
    $text .= "<tr><td colspan=4><a href=javascript:copyAddress()>Copy from Main address</a></td></tr>\n";
    $text .= <<END_OF_BLOCK;

<script language=javascript><!--

function copyAddress () {
    $args{form}.remitaddress.value = $args{form}.address.value;
    $args{form}.remitcity.value = $args{form}.city.value;
    $args{form}.remitstate.selectedIndex = $args{form}.state.selectedIndex;
    $args{form}.remitzip.value = $args{form}.zip.value;
}
//--></script>

END_OF_BLOCK
    $text .= "</table>\n";
    $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Remit To</b>", contents=>$text) . "</td></tr>\n";
## Point of Contact
    $text = "<table border=0>\n";
    $text .= "<tr><td><b>Name</b></td><td><b>Phone</b></td><td><b>Ext</b></td><td><b>Fax</b></td></tr>\n";
    $text .= "<tr>\n";
    $text .= "<td><input type=text name=pointofcontact value=\"" . ((defined($vendor{pointofcontact})) ? $vendor{pointofcontact} : "") . "\" maxlength=50 size=50></td>\n";
    $text .= "<td><input type=text name=phone value=\"$vendor{phone}\" maxlength=20 size=15></td>\n";
    $text .= "<td><input type=text name=extension value=\"" . ((defined($vendor{extension})) ? $vendor{extension} : "") . "\" maxlength=5 size=5></td>\n";
    $text .= "<td><input type=text name=fax value=\"" . ((defined($vendor{fax})) ? $vendor{fax} : "") . "\" maxlength=20 size=15></td>\n";
    $text .= "</tr>\n";
    $text .= "<tr><td colspan=4><b>Email</b></td></tr>\n";
    $text .= "<tr><td colspan=4><input type=text name=email value=\"" . ((defined($vendor{email})) ? $vendor{email} : "") . "\" maxlength=100 size=90></td></tr>\n";
    $text .= "</table>\n";
    $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Point of Contact</b>", contents=>$text) . "</td></tr>\n";
## Related vendor
    if ($isVendorManager && $vendor{status} >= 1) {
        $text = "<table border=0>\n";
        $text .= "<tr><td><b>Name </b>&nbsp;<select name=relatedto><option value=0> </option>\n";
        my @vendors = &getVendorList(dbh=>$args{dbh}, schema=>$args{schema});
        for (my $i=0; $i<$#vendors; $i++) {
            $text .= "<option value=$vendors[$i]{id}" . (($vendor{relatedto}==$vendors[$i]{id}) ? " selected" : "") . 
                ">$vendors[$i]{name} - " . ((defined($vendors[$i]{city})) ? $vendors[$i]{city} : "") .  ", " . ((defined($vendors[$i]{state})) ? $vendors[$i]{state} : "") . "</option>\n";
        }
        $text .= "</select></td></tr>\n";
        $text .= "<tr><td><b>Relationship: </b>&nbsp;<input type=text name=relationship value=\"" . ((defined($vendor{relationship})) ? $vendor{relationship} : "") . "\" maxlength=100 size=60></td></tr>\n";
        $text .= "<tr><td>Note: The vendor currently being edited will be placed into archive status and the selected vendor will be considered to have replaced it.</td></tr>\n";
        $text .= "</table>\n";
        $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Related Vendor</b> (Replaced By, etc...)", contents=>$text) . "</td></tr>\n";
    }
## Classifications
    if ($isVendorManager) {
        $text = "<table border=0>\n";
        tie my %availClassifications, "Tie::IxHash";
        tie my %currClassifications, "Tie::IxHash";
        %availClassifications =%{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table=>'classifications', idColumn=>'id',
              nameColumn=>'name', orderBy=>'name')};
        for (my $i=0; $i<$vendor{classificationCount}; $i++) {
            $currClassifications{$vendor{classifications}[$i]{id}} = $vendor{classifications}[$i]{name};
        }
        $text .= "<tr><td>\n";
        $text .= build_dual_select ('classifications', "$args{form}", \%availClassifications, \%currClassifications, "<b>Available Classifications</b>", "<b>Selected Classifications</b>", 0);
        $text .= "</td></tr>\n";
        $text .= "</table>\n";
        $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Classifications</b>", contents=>$text) . "</td></tr>\n";
    }
## Tax Permits
    if ($isVendorManager) {
        $text = "<table border=0>\n";
        $text .= "<tr><td><b>Site</b></td><td align=center><b>Has Tax ID</b></td><td align=center><b>Tax ID</b></td><td><b align=center>EffectiveDate</b></td></tr>\n";
        $text .= "<input type=hidden name=sitecount value=$vendor{siteCount}>\n";
        for (my $i=1; $i<=$vendor{siteCount}; $i++) {
            $text .= "<tr><td><b>$siteInfo[$i]{name}</b></td>\n";
            $text .= "<td align=center><input type=checkbox name=hastaxid$i value='T'" . (($vendor{taxpermits}[$i]{hastaxid} eq 'T') ? " checked" : "") . "></td>\n";
            $text .= "<td align=center><input type=text name=taxid$i value=\"" . ((defined($vendor{taxpermits}[$i]{taxid})) ? $vendor{taxpermits}[$i]{taxid} : "") . "\" maxlength=30 size=30></td>\n";
            $text .= "<td align=center><input type=text name=effectivedate$i value=\"" . ((defined($vendor{taxpermits}[$i]{effectivedate})) ? $vendor{taxpermits}[$i]{effectivedate} : "") . "\" maxlength=10 size=10 ";
            $text .= "onfocus=\"this.blur(); showCal('caltaxeffectivedate$i')\"><span id=\"taxeffectivedate$i" . "id\" style=\"position:relative;\">&nbsp;</span></td>\n";
            $text .= "</tr>\n";
        }
        $text .= "</table>\n";
        $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Tax Permits</b>", contents=>$text) . "</td></tr>\n";
    }
## comments
    $text = "<table border=0>\n";
    $text .= "<tr><td><textarea name=comments cols=70 rows=4></textarea></td></tr>\n";
    if ($args{type} ne 'new') {
        my $text2 = "<table border=1 cellspacing=0 cellpadding=0>\n";
        for (my $i=0; $i<$vendor{commentCount}; $i++) {
            $text2 .= "<tr><td>$vendor{comments}[$i]{dateentered} - " . &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$vendor{comments}[$i]{enteredby}) . "<br>\n";
            $vendor{comments}[$i]{text} =~ s/\n/<br>\n/g;
            $text2 .= "$vendor{comments}[$i]{text}</td></tr>\n";
        }
        $text2 .= "</table>\n";
        $text .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Past Comments</b> ($vendor{commentCount})", contents=>$text2) . "</td></tr>\n";
    }
    $text .= "</table>\n";
    $output .= "<tr><td colspan=2>" . &buildSectionBlock(title=> "<b>Comments</b>", contents=>$text) . "</td></tr>\n";
##

    $output .= "<tr><td colspan=2 align=center><br><input type=button name=submitbutton value=\"Submit Vendor Information\" onClick=\"verifySubmit(document.$args{form})\"> &nbsp;\n";
    $output .= "</table>\n";
    
    my $nextCommand = (($args{type} eq 'new') ? "addvendor" : "updatevendor");
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    if (isblank(f.name.value) || isblank(f.mainphone.value) || isblank(f.mainproduct.value) || isblank(f.address.value) ||
          isblank(f.remitaddress.value)) {
      msg += "The following fields are requried and must be entered:\\nName, Main Phone, Main Product, Address, Remit Address.\\n";
    }
    if ($isVendorManager == 1 && f.vendorstatus.value >= 1) {
      var myIndex = f.relatedto.selectedIndex;
      if (f.relatedto[myIndex].value == f.v_vendorid.value) {
        msg += "Vendor can not have a relationship to itself.\\n";
      }
      if ((f.relatedto[myIndex].value !=0) && (isblank(f.relationship.value))) {
        msg += "Relationship to selected related vendor must be entered.\\n";
      }
      if ((f.relatedto[myIndex].value ==0) && (!isblank(f.relationship.value))) {
        msg += "Relationship can not be entered if no related vendor is selected.\\n";
      }
END_OF_BLOCK
    for (my $i=1; $i<=$vendor{siteCount}; $i++) {
        $output .= "      if (!f.hastaxid$i.checked && (!isblank(f.taxid$i.value) || !isblank(f.taxid$i.value))) {\n";
        $output .= "          msg += \"Can not have a Tax ID or a Tax ID Effective Date when Has Valid Tax ID is not checked.\\n\";\n";
        $output .= "      }\n";
    }
    $output .= <<END_OF_BLOCK;
    }
    if (msg != "") {
      alert (msg);
    } else {
        if ($isVendorManager == 1) {
            for (index=0; index < f.classifications.length-1;index++) {
                f.classifications[index].selected = true;
            }
        }
        submitFormCGIResults('$args{form}', '$nextCommand');
    }
}
//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doVendorEntry {  # routine to get vendor entry/update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my ($status, $id) = &doProcessVendorEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, settings => \%settings);

    my $temp = $settings{name};
    $temp =~ s/'/ /g;
    $temp =~ s/"/ /g;
    $message = "Vendor '$temp' has been " . (($args{type} eq 'new') ? "added " : "updated");
    $output .= doAlertBox(text => "$message");
    if ($args{type} eq 'new') {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "vendor $id inserted", type => 8);
    } else {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "vendor $id updated", type => 9);
    }
    my $nextCommand = (($settings{relatedto} == 0) ? 'updatevendorform' : 'updatevendorselect');
    $output .= "<input type=hidden name=v_vendorid value=$id>\n";
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','$nextCommand');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
