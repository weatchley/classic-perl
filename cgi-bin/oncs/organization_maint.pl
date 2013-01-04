#!/usr/local/bin/newperl
# - !/usr/bin/perl

#require "oncs_header.pl";
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);
#require "oncs_lib.pl";

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

$testout = new CGI;

# print content type header
print $testout->header('text/html');

$pagetitle = $testout->param('pagetitle');
$cgiaction = $testout->param('action');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
$usersid = $testout->param('loginusersid');
$username = $testout->param('loginusername');
$submitonly = 0;
$updatetable = $testout->param('updatetable');

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "") ||
    (!defined($pagetitle)) || ($pagetitle eq "") || (!defined($updatetable)) || ($updatetable eq ""))
  {
  print <<openloginpage;
  <script type="text/javascript">
  <!--
  //alert ('$usersid $username $pagetitle $updatetable $one $two $three $four');
  parent.location='/cgi-bin/oncs/oncs_user_login.pl';
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

    if (parent == self)  // not in frames
      {
      location = '/cgi-bin/oncs/oncs_user_login.pl'
      }
    //-->
  </script>
testlabel1

print "</head>\n\n";
print "<body>\n";

# print the values passed to the cgi script.
#foreach $key ($testout->param)
#  {
#  print "<B>$key</B> -> ";
#  @values = $testout->param($key);
#  print join(",  ",@values), "[--<BR>\n";
#  }

# connect to the oracle database and generate a database handle
$dbh = oncs_connect();

print "<center><h1>$pagetitle Maintenance</h1></center>\n";
print "<form action=\"/cgi-bin/oncs/organization_maint.pl\" method=post name=orgmaint>\n";

if ($cgiaction eq "add_org")
  {
  # print the sql which will update this table
  #$nextorgid = get_maximum_id($dbh, $updatetable) + 1;
  $nextorgid = get_next_id($dbh, $updatetable);
  $name = $testout->param('name');
  $name =~ s/'/''/g;
  $address1 = $testout->param('address1');
  $address1 =~ s/'/''/g;
  $address2 = $testout->param('address2');
  $address2 =~ s/'/''/g;
  $city = $testout->param('city');
  $city =~ s/'/''/g;
  $state = $testout->param('state');
  $zipcode = $testout->param('zipcode');
  $country = $testout->param('country');
  $areacode = $testout->param('areacode');
  $phonenumber = $testout->param('phonenumber');
  $extension = $testout->param('extension');
  $contact = $testout->param('contact');
  $contact =~ s/'/''/g;
  $department = $testout->param('department');
  $department =~ s/'/''/g;
  $division = $testout->param('division');
  $division =~ s/'/''/g;
  $faxareacode = $testout->param('faxareacode');
  $faxnumber = $testout->param('faxnumber');
  $parentorg = $testout->param('parentorg');
  $parentorg = $parentorg ? $parentorg : 'NULL';
#  $isactive = 'T';

  $sqlstring = "INSERT INTO $SCHEMA.$updatetable VALUES ($nextorgid, '$name',
                           '$address1', '$address2', '$city', '$state', '$zipcode', '$country',
                           '$areacode', '$phonenumber', '$extension', '$contact', '$department',
                           '$division', '$faxareacode', '$faxnumber', $parentorg)";

# print "$sqlstring<br>\n";
  $rc = $dbh->do($sqlstring);
  $cgiaction="query";
  }

if ($cgiaction eq "modify_org")
  {
  # print the sql which will update this table
  $organizationid = $testout->param('organizationid');
  $name = $testout->param('name');
  $name =~ s/'/''/g;
  $address1 = $testout->param('address1');
  $address1 =~ s/'/''/g;
  $address2 = $testout->param('address2');
  $address2 =~ s/'/''/g;
  $city = $testout->param('city');
  $city =~ s/'/''/g;
  $state = $testout->param('state');
  $zipcode = $testout->param('zipcode');
  $country = $testout->param('country');
  $areacode = $testout->param('areacode');
  $phonenumber = $testout->param('phonenumber');
  $extension = $testout->param('extension');
  $contact = $testout->param('contact');
  $contact =~ s/'/''/g;
  $department = $testout->param('department');
  $department =~ s/'/''/g;
  $division = $testout->param('division');
  $division =~ s/'/''/g;
  $faxareacode = $testout->param('faxareacode');
  $faxnumber = $testout->param('faxnumber');
  $parentorg = $testout->param('parentorg');
  $parentorg = $parentorg ? $parentorg : 'NULL';
#  $isactive = ($testout->param('isactive') eq 'T') ? 'T' : 'F';

  $sqlstring = "UPDATE $SCHEMA.$updatetable SET name='$name', address1='$address1',
                           address2='$address2', city='$city', state='$state', zipcode='$zipcode',
                           country='$country', areacode='$areacode', phonenumber='$phonenumber',
                           extension='$extension', contact='$contact', department='$department',
                           division='$division', faxareacode='$faxareacode',
                           faxnumber='$faxnumber', parentorg=$parentorg
                           WHERE organizationid = $organizationid";

  #print "$sqlstring<br>\n";
  $rc = $dbh->do($sqlstring);
  $cgiaction="query";
  }

if ($cgiaction eq "modify_selected")
  {
  $organizationid = $testout->param('selectedorg');
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
  <table summary="modify org table" width="100%" border=1>
  <tr>
    <td width="20%" align=center>
    <b>Organization Name</b>
    </td>
    <td width="80%" align=left>
    <input name=name type=text maxlength=80 size=80 value="$name">
    <input name=organizationid type=hidden value=$organizationid>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Address Line 1</b>
    </td>
    <td width="80%" align=left>
    <input name=address1 type=text maxlength=50 size=50 value="$address1">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Address Line 2</b>
    </td>
    <td width="80%" align=left>
    <input name=address2 type=text maxlength=50 size=50 value="$address2">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>City</b>
    </td>
    <td width="80%" align=left>
    <input name=city type=text maxlength=25 size=25 value="$city">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>State</b>
    </td>
    <td width="80%" align=left>
    <input name=state type=text maxlength=2 size=2 value="$state">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Zip Code</b>
    </td>
    <td width="80%" align=left>
    <input name=zipcode type=text maxlength=10 size=10 value="$zipcode">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Country</b>
    </td>
    <td width="80%" align=left>
    <input name=country type=text maxlength=15 size=15 value="$country">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Area Code</b>
    </td>
    <td width="80%" align=left>
    (<input name=areacode type=text maxlength=3 size=3 value=$areacode>)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Phone Number</b>
    </td>
    <td width="80%" align=left>
    <input name=phonenumber type=text maxlength=7 size=7 value=$phonenumber>   (no hyphen)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Extension</b>
    </td>
    <td width="80%" align=left>
    <input name=extension type=text maxlength=5 size=5 value=$extension>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Point of Contact</b>
    </td>
    <td width="80%" align=left>
    <input name=contact type=text maxlength=30 size=30 value="$contact">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Department</b>
    </td>
    <td width="80%" align=left>
    <input name=department type=text maxlength=15 size=15 value="$department">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Division</b>
    </td>
    <td width="80%" align=left>
    <input name=division type=text maxlength=15 size=15 value="$division">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Fax Area Code</b>
    </td>
    <td width="80%" align=left>
    (<input name=faxareacode type=text maxlength=3 size=3 value="$faxareacode">)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Fax Number</b>
    </td>
    <td width="80%" align=left>
    <input name=faxnumber type=text maxlength=7 size=7 value="$faxnumber">  (no hyphen)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Parent Organization</b>
    </td>
    <td width="80%" align=left>
    <input name=parentorg type=text maxlength=8 size=8 value=$parentorg>
    </td>
  </tr>
  </table>
modifyform

#  'print "$sqlstring<br>\n";
# $rc = $dbh->do($sqlstrings[$counter]);
  print "<input name=action type=hidden value=modify_org>\n";
  }

if ($cgiaction eq "add_selected")
  {
  $submitonly = 1;

  print <<addform;
  <input name=cgiaction type=hidden value="add_org">
  <table summary="add organization entry" width="100%" border=1>
  <tr>
    <td width="20%" align=center>
    <b>Organization Name</b>
    </td>
    <td width="80%" align=left>
    <input name=name type=text maxlength=80 size=80>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Address Line 1</b>
    </td>
    <td width="80%" align=left>
    <input name=address1 type=text maxlength=50 size=50>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Address Line 2</b>
    </td>
    <td width="80%" align=left>
    <input name=address2 type=text maxlength=50 size=50>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>City</b>
    </td>
    <td width="80%" align=left>
    <input name=city type=text maxlength=25 size=25>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>State</b>
    </td>
    <td width="80%" align=left>
    <input name=state type=text maxlength=2 size=2>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Zip Code</b>
    </td>
    <td width="80%" align=left>
    <input name=zipcode type=text maxlength=10 size=10>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Country</b>
    </td>
    <td width="80%" align=left>
    <input name=country type=text maxlength=15 size=15>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Area Code</b>
    </td>
    <td width="80%" align=left>
    (<input name=areacode type=text maxlength=3 size=3>)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Phone Number</b>
    </td>
    <td width="80%" align=left>
    <input name=phonenumber type=text maxlength=7 size=7>   (no hyphen)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Extension</b>
    </td>
    <td width="80%" align=left>
    <input name=extension type=text maxlength=5 size=5>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Point of Contact</b>
    </td>
    <td width="80%" align=left>
    <input name=contact type=text maxlength=30 size=30>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Department</b>
    </td>
    <td width="80%" align=left>
    <input name=department type=text maxlength=15 size=15>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Division</b>
    </td>
    <td width="80%" align=left>
    <input name=division type=text maxlength=15 size=15>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Fax Area Code</b>
    </td>
    <td width="80%" align=left>
    (<input name=faxareacode type=text maxlength=3 size=3>)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Fax Number</b>
    </td>
    <td width="80%" align=left>
    <input name=faxnumber type=text maxlength=7 size=7>  (no hyphen)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Parent Organization</b>
    </td>
    <td width="80%" align=left>
    <input name=parentorg type=text maxlength=8 size=8>
    </td>
  </tr>
  </table>
addform

  print "<input name=action type=hidden value=add_org>\n";
  }

if ($cgiaction eq "query")
  {
  %orghash = get_lookup_values($dbh, $updatetable, "organizationid", "name");

  print<<queryformtop;
  <select name=selectedorg size=10>
queryformtop

  foreach $key (sort keys %orghash)
    {
    print "<option value=\"$key\">$orghash{$key}\n";
    }

  print <<queryformbottom;
  </select>
  <br>
queryformbottom
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
if ($submitonly == 0)
  {
  print "<input name=add type=submit value=\"Add New Organization\" onclick=\"document.orgmaint.action.value='add_selected'\">\n";
  print "<input name=modify type=submit value=\"Modify Selected Organization\" onclick=\"dosubmit=true; (document.orgmaint.selectedorg.selectedIndex == -1) ? (alert(\'No Organization Selected\') || (dosubmit = false)) : document.orgmaint.action.value='modify_selected'; return(dosubmit)\">\n";
  }
else
  {
  print "<input name=submit type=submit value=\"Submit Changes\">\n";
  }
print "</form>\n";
# menu to return to the maintenance menu and the main screen
#print "<ul title=\"Link Menu\"><b>Link Menu</b>\n<li><a href=\"/dcmm/prototype/maintenance.htm\">Maintenance Screen</a></li>\n";
#print "<li><a href=\"/dcmm/prototype/home.htm\">Main Menu</a></li>\n";
#print "</ul><br><br>\n";

print "</body>\n";
print "</html>\n";
