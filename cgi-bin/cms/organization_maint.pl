#!/usr/local/bin/newperl
# - !/usr/bin/perl

#
# CIRS Maintenance script for organizations.
#
# $Source: /data/dev/rcs/cms/perl/RCS/organization_maint.pl,v $
# $Revision: 1.14 $
# $Date: 2002/10/04 21:35:17 $
# $Author: naydenoa $
# $Locker:  $
# $Log: organization_maint.pl,v $
# Revision 1.14  2002/10/04 21:35:17  naydenoa
# Added "use strict"
#
# Revision 1.13  2000/12/12 22:15:08  naydenoa
# Alphabetized pick list
#
# Revision 1.12  2000/12/12 21:19:46  naydenoa
# Changed address lines size to 80
#
# Revision 1.11  2000/09/28 18:19:21  naydenoa
# Updated interface to match the rest of the system
#
# Revision 1.10  2000/09/26 17:09:00  atchleyb
# fixed insert, added names
#
# Revision 1.9  2000/09/21 22:07:55  atchleyb
# updated title
#
# Revision 1.8  2000/08/21 23:33:43  atchleyb
# added check schema line
#
# Revision 1.7  2000/07/24 16:23:36  johnsonc
# Inserted GIF file for display.
#
# Revision 1.6  2000/07/12 21:06:04  munroeb
# finished modifying html formatting
#
# Revision 1.5  2000/07/12 21:02:25  munroeb
# finished modifying html formatting
#
# Revision 1.4  2000/07/06 23:43:54  munroeb
# finished making mods to html and javascripts.
#
# Revision 1.3  2000/07/05 23:08:41  munroeb
# made minor changes to html and javascripts
#
# Revision 1.2  2000/05/18 23:15:18  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/11 23:59:28  zepedaj
# Initial revision
#
#

use strict;
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

# print content type header
print $cmscgi->header('text/html');

my $pagetitle = $cmscgi->param('pagetitle');
my $cgiaction = $cmscgi->param('action');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $submitonly = 0;
my $updatetable = $cmscgi->param('updatetable');
my ($one, $two, $three, $four);
my $organizationid;
my $nextorgid;
my $name;
my $address1;
my $address2;
my $city;
my $state;
my $zipcode;
my $country;
my $areacode;
my $phonenumber;
my $extension;
my $contact;
my $department;
my $division;
my $faxareacode;
my $faxnumber;
my $parentorg;
my $sqlstring;
my $rc;
my %orghash;

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "") ||
    (!defined($pagetitle)) || ($pagetitle eq "") || (!defined($updatetable)) || ($updatetable eq "")) {
    print <<openloginpage;
    <script type="text/javascript">
    <!--
    //alert ('$usersid $username $pagetitle $updatetable $one $two $three $four');
    parent.location='$ONCSCGIDir/login.pl';
    //-->
    </script>
openloginpage
    exit 1;
}

#print html
print "<html>\n";
print "<head>\n";
print "<meta http-equiv=\"expires\" content=\"Fri, 12 May 1996 14:35:02 EST\">\n";
print "<title>$pagetitle Maintenance</title>\n";

print <<testlabel1;
<!-- include external javascript code -->
<script src="$ONCSJavaScriptPath/oncs-utilities.js"></script>
    <script type="text/javascript">
    <!--
    var dosubmit=true;
    if (parent == self) {   // not in frames
	 location = '$ONCSCGIDir/login.pl'
    }
    //-->
    </script>
    <script language="JavaScript" type="text/javascript">
    <!--
      doSetTextImageLabel('Organization Maintenance');
    //-->
    </script>
testlabel1

print "</head>\n\n";
print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><CENTER>\n";

# print the values passed to the cgi script.
#foreach $key ($cmscgi->param)
#  {
#  print "<B>$key</B> -> ";
#  @values = $cmscgi->param($key);
#  print join(",  ",@values), "[--<BR>\n";
#  }

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

#print "<center><h1>$pagetitle Maintenance</h1></center>\n";
print "<form action=\"$ONCSCGIDir/organization_maint.pl\" method=post name=orgmaint>\n";

##############################
if ($cgiaction eq "add_org") {
##############################
    # print the sql which will update this table
    #$nextorgid = get_maximum_id($dbh, $updatetable) + 1;
    $nextorgid = get_next_id($dbh, $updatetable);
    $name = $cmscgi->param('name');
    $name =~ s/\'/\'\'/g;
    $address1 = $cmscgi->param('address1');
    $address1 =~ s/\'/\'\'/g;
    $address2 = $cmscgi->param('address2');
    $address2 =~ s/\'/\'\'/g;
    $city = $cmscgi->param('city');
    $city =~ s/\'/\'\'/g;
    $state = $cmscgi->param('state');
    $zipcode = $cmscgi->param('zipcode');
    $country = $cmscgi->param('country');
    $areacode = $cmscgi->param('areacode');
    $phonenumber = $cmscgi->param('phonenumber');
    $extension = $cmscgi->param('extension');
    $contact = $cmscgi->param('contact');
    $contact =~ s/\'/\'\'/g;
    $department = $cmscgi->param('department');
    $department =~ s/\'/\'\'/g;
    $division = $cmscgi->param('division');
    $division =~ s/\'/\'\'/g;
    $faxareacode = $cmscgi->param('faxareacode');
    $faxnumber = $cmscgi->param('faxnumber');
    $parentorg = $cmscgi->param('parentorg');
    $parentorg = $parentorg ? $parentorg : 'NULL';
#  $isactive = 'T';
    
    $sqlstring = "INSERT INTO $SCHEMA.$updatetable 
                         (organizationid, name, address1, address2, city,
                          state, zipcode, country, areacode, phonenumber,
                          extension, contact, department,
                          division, faxareacode, faxnumber, parentorg)
                  VALUES ($nextorgid, '$name', '$address1', '$address2', 
                          '$city', '$state', '$zipcode', '$country',
                          '$areacode', '$phonenumber', '$extension', 
                          '$contact', '$department', '$division', 
                          '$faxareacode', '$faxnumber', $parentorg)";
    
# print "$sqlstring<br>\n";
    $rc = $dbh->do($sqlstring);
    $cgiaction="query";
}  #################  endif add_org  ######################

#################################
if ($cgiaction eq "modify_org") {
#################################
    # print the sql which will update this table
    $organizationid = $cmscgi->param('organizationid');
    $name = $cmscgi->param('name');
    $name =~ s/\'/\'\'/g;
    $address1 = $cmscgi->param('address1');
    $address1 =~ s/\'/\'\'/g;
    $address2 = $cmscgi->param('address2');
    $address2 =~ s/\'/\'\'/g;
    $city = $cmscgi->param('city');
    $city =~ s/\'/\'\'/g;
    $state = $cmscgi->param('state');
    $zipcode = $cmscgi->param('zipcode');
    $country = $cmscgi->param('country');
    $areacode = $cmscgi->param('areacode');
    $phonenumber = $cmscgi->param('phonenumber');
    $extension = $cmscgi->param('extension');
    $contact = $cmscgi->param('contact');
    $contact =~ s/\'/\'\'/g;
    $department = $cmscgi->param('department');
    $department =~ s/\'/\'\'/g;
    $division = $cmscgi->param('division');
    $division =~ s/\'/\'\'/g;
    $faxareacode = $cmscgi->param('faxareacode');
    $faxnumber = $cmscgi->param('faxnumber');
    $parentorg = $cmscgi->param('parentorg');
    $parentorg = $parentorg ? $parentorg : 'NULL';
#  $isactive = ($cmscgi->param('isactive') eq 'T') ? 'T' : 'F';
    
    $sqlstring = "UPDATE $SCHEMA.$updatetable 
                  SET name='$name', address1='$address1', address2='$address2',
                      city='$city', state='$state', zipcode='$zipcode',
                      country='$country', areacode='$areacode', 
                      phonenumber='$phonenumber', extension='$extension', 
                      contact='$contact', department='$department',
                      division='$division', faxareacode='$faxareacode',
                      faxnumber='$faxnumber', parentorg=$parentorg
                  WHERE organizationid = $organizationid";

    #print "$sqlstring<br>\n";
    $rc = $dbh->do($sqlstring);
    $cgiaction="query";
}  #################  endif modify_org  ####################

######################################
if ($cgiaction eq "modify_selected") {
######################################
    $organizationid = $cmscgi->param('selectedorg');
    $submitonly = 1;
    
    %orghash = get_org_info($dbh, $organizationid);
    
    # print the sql which will update this table
    $name = $orghash{'name'};
    $address1 = $orghash{'address1'};
    $address2 = $orghash{'address2'};
    $city = $orghash{'city'};
    $state = $orghash{'state'};
    $zipcode = $orghash{'zipcode'};
    $country = $orghash{'country'};
    $areacode = $orghash{'areacode'};
    $phonenumber = $orghash{'phonenumber'};
    $extension = $orghash{'extension'};
    $contact = $orghash{'contact'};
    $department = $orghash{'department'};
    $division = $orghash{'division'};
    $faxareacode = $orghash{'faxareacode'};
    $faxnumber = $orghash{'faxnumber'};
    $parentorg = $orghash{'parentorg'};
#  $isactive         = $orghash{'isactive'};
#  $checkedifactive  = ($isactive eq 'T') ? "checked" : "";
    
    print <<modifyform;
    <input name=cgiaction type=hidden value="modify_org">
    <input type=hidden name=schema value=$SCHEMA>
    <br><br>
    <table summary="modify org table" width=740 border=0 align=center>
    <tr><td width=25% align=left><b><li>Organization Name: </b></td>
    <td><input name=name type=text maxlength=80 size=80 value="$name">
    <input name=organizationid type=hidden value=$organizationid></td></tr>
    <tr><td align=left><b><li>Address Line 1:</b></td>
    <td align=left><input name=address1 type=text maxlength=80 size=80 value="$address1"></td></tr>
    <tr><td align=left><b><li>Address Line 2:</b></td>
    <td align=left><input name=address2 type=text maxlength=80 size=80 value="$address2"></td></tr>
    <tr><td align=left><b><li>City:</b></td>
    <td align=left><input name=city type=text maxlength=25 size=25 value="$city"></td></tr>
    <tr><td align=left><b><li>State:</b></td>
    <td align=left><input name=state type=text maxlength=2 size=2 value="$state"></td></tr>
    <tr><td align=left><b><li>Zip Code:</b></td>
    <td align=left><input name=zipcode type=text maxlength=10 size=10 value="$zipcode"></td></tr>
    <tr><td align=left><b><li>Country:</b></td>
    <td align=left><input name=country type=text maxlength=15 size=15 value="$country"></td></tr>
    <tr><td align=left><b><li>Phone Number:</b></td>
    <td align=left><b>Area Code: &nbsp; </b>
    (<input name=areacode type=text maxlength=3 size=3 value=$areacode>)
    &nbsp; <b>Number:</b>
    &nbsp; <input name=phonenumber type=text maxlength=7 size=7 value=$phonenumber>  &nbsp; (no hyphen)
    &nbsp; <b>Extension:</b>
    &nbsp; <input name=extension type=text maxlength=5 size=5 value=$extension>
    </td></tr>
    <tr><td align=left><b><li>Point of Contact:</b></td>
    <td align=left><input name=contact type=text maxlength=30 size=30 value="$contact"></td></tr>
    <tr><td align=left><b><li>Department:</b></td>
    <td align=left><input name=department type=text maxlength=15 size=15 value="$department"></td></tr>
    <tr><td><b><li>Division:</b></td>
    <td align=left><input name=division type=text maxlength=15 size=15 value="$division"></td></tr>
    <tr><td><b><li>Fax:</b></td> 
    <td><b>Area Code: &nbsp; </b>(<input name=faxareacode type=text maxlength=3 size=3 value="$faxareacode">)
    &nbsp; <b>Number: </b>
    &nbsp; <input name=faxnumber type=text maxlength=7 size=7 value="$faxnumber">  (no hyphen)</td></tr>
    <tr><td><b><li>Parent Organization:</b></td>
    <td align=left><input name=parentorg type=text maxlength=80 size=80 value=$parentorg></td></tr>
    </table><br><br>
modifyform

#  'print "$sqlstring<br>\n";
# $rc = $dbh->do($sqlstrings[$counter]);
    print "<input name=action type=hidden value=modify_org>\n";
} ###############  endif modify_selected  ######################

###################################
if ($cgiaction eq "add_selected") {
###################################
    $submitonly = 1;
    
    print <<addform;
    <input name=cgiaction type=hidden value="add_org">
    <br><br>
    <table summary="add organization entry" width="750" align=center border=0>
    <tr><td width=25%><b><li>Organization Name:</b></td>
    <td><input name=name type=text maxlength=80 size=80></td></tr> 
    <tr><td valign=top><b><li>Address Line 1:</b></td>
    <td><input name=address1 type=text maxlength=80 size=80></td></tr>
    <tr><td><b><li>Address Line 2:</b></td>
    <td><input name=address2 type=text maxlength=80 size=80>
    <tr><td><b><li>City:</b></td>
    <td><input name=city type=text maxlength=25 size=25></td></tr>
    <tr><td><b><li>State:</b></td>
    <td><input name=state type=text maxlength=2 size=2></td></tr>
    <tr><td><b><li>Zip Code:</b></td>
    <td><input name=zipcode type=text maxlength=10 size=10></td></tr>
    <tr><td><b><li>Country:</b></td>
    <td><input name=country type=text maxlength=15 size=15>&nbsp;</td></tr>
    <tr><td><b><li>Phone Number: </b></td>
    <td><b>Area Code:</b>
    &nbsp; (<input name=areacode type=text maxlength=3 size=3>)
    &nbsp; <b>Number:</b>
    &nbsp; <input name=phonenumber type=text maxlength=7 size=7> 
    &nbsp; (no hyphen)
    &nbsp; <b>Extension:</b>
    &nbsp; <input name=extension type=text maxlength=5 size=5>
    </td></tr>
    <tr><td><b><li>Point of Contact:</b></td>
    <td><input name=contact type=text maxlength=30 size=30></td></tr>
    <tr><td><b><li>Department:</b></td>
    <td><input name=department type=text maxlength=15 size=15></td></tr>
    <tr><td><b><li>Division:</b></td>
    <td><input name=division type=text maxlength=15 size=15></td></tr>
    <tr><td><b><li>Fax:</b></td>
    <td><b>Area Code:</b>
    &nbsp; (<input name=faxareacode type=text maxlength=3 size=3>)
    &nbsp; <b>Fax Number:</b>
    &nbsp; <input name=faxnumber type=text maxlength=7 size=7> &nbsp; (no hyphen)</td></tr>
    <tr><td><b><li>Parent Organization:</b></td>
    <td><input name=parentorg type=text maxlength=8 size=8></td></tr>
    </table>
addform

  print "<input name=action type=hidden value=add_org>\n";
  }  ##################  endif add_selected  ##########################

############################
if ($cgiaction eq "query") {
############################
    %orghash = get_lookup_values($dbh, $updatetable, "organizationid", "name");
    
    print "<br><br><select name=selectedorg size=10>\n";

    my $orglist = "select name, organizationid from $SCHEMA.organization order by name";
    my $organizations = $dbh -> prepare ($orglist);
    $organizations -> execute;

    while (my @values = $organizations -> fetchrow_array) {
        my ($name, $id) = @values;
	print "<option value=\"$id\">$name\n";
    }
    $organizations -> finish;
    print "</select><br>\n";
    print "<input name=action type=hidden value=query>\n";
}

print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=loginusername type=hidden value=$username>\n";
print "<input name=loginusersid type=hidden value=$usersid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";

#disconnect from the database
&oncs_disconnect($dbh);

# print html footers.
print "<br>\n";
if ($submitonly == 0) {
    print "<input name=add type=submit value=\"Add New Organization\" onclick=\"document.orgmaint.action.value='add_selected'\">\n";
    print "<input name=modify type=submit value=\"Modify Selected Organization\" onclick=\"dosubmit=true; (document.orgmaint.selectedorg.selectedIndex == -1) ? (alert(\'No Organization Selected\') || (dosubmit = false)) : document.orgmaint.action.value='modify_selected'; return(dosubmit)\">\n";
}
else {
    print "<input name=submit type=submit value=\"Submit Changes\">\n";
}
print "</form>\n";
# menu to return to the maintenance menu and the main screen
#print "<ul title=\"Link Menu\"><b>Link Menu</b>\n<li><a href=\"/dcmm/prototype/maintenance.htm\">Maintenance Screen</a></li>\n";
#print "<li><a href=\"/dcmm/prototype/home.htm\">Main Menu</a></li>\n";
#print "</ul><br><br>\n";

print "</CENTER><br><br><br><br></body>\n";
print "</html>\n";
