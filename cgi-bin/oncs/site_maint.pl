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
$username = $testout->param('loginusername');
$usersid = $testout->param('loginusersid');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
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

    var dosubmit = true;
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
print "<form action=\"/cgi-bin/oncs/site_maint.pl\" method=post name=sitemaint>\n";

if ($cgiaction eq "add_site")
  {
  # print the sql which will update this table
  #$siteid = get_maximum_id($dbh, $updatetable) + 1;
  $siteid = get_next_id($dbh, $updatetable);
  $city = $testout->param('city');
  $city =~ s/'/''/g;
  $state = $testout->param('state');
  $name = $testout->param('name');
  $name =~ s/'/''/g;
#  $isactive = 'T';

  $sqlstring = "INSERT INTO $SCHEMA.$updatetable VALUES ($siteid, '$city',
                             '$state', '$name')";

# print "$sqlstring<br>\n";
  $rc = $dbh->do($sqlstring);
  $cgiaction="query";
  }

if ($cgiaction eq "modify_site")
  {
  # print the sql which will update this table
  $siteid = $testout->param('siteid');
  $city = $testout->param('city');
  $city =~ s/'/''/g;
  $state = $testout->param('state');
  $name = $testout->param('name');
  $name =~ s/'/''/g;
#  $isactive = ($testout->param('isactive') eq 'T') ? 'T' : 'F';

  $sqlstring = "UPDATE $SCHEMA.$updatetable SET name='$name', city='$city',
                           state='$state'
                           WHERE siteid = $siteid";

#  print "$sqlstring<br>\n";
  $rc = $dbh->do($sqlstring);
  $cgiaction="query";
  }

if ($cgiaction eq "modify_selected")
  {
  $thissite = $testout->param('selectedsite');
  $submitonly = 1;

  %sitehash = get_site_info($dbh, $thissite);

  # print the sql which will update this table
  $city = $sitehash{'city'};
  $state = $sitehash{'state'};
  $name = $sitehash{'name'};
#  $isactive         = $sitehash{'isactive'};
#  $checkedifactive  = ($isactive eq 'T') ? "checked" : "";

  print <<modifyform;
  <input name=cgiaction type=hidden value="modify_site">
  <table summary="modify site table" width="100%" border=1>
  <tr>
    <td width="20%" align=center>
    <b>Site Name</b>
    </td>
    <td width="80%" align=left>
    <b>$name</b>
    <input name=name type=hidden value=$name>
    <input name=siteid type=hidden value=$thissite>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>City</b>
    </td>
    <td width="80%" align=left>
    <input name=city type=text maxlength=30 size=30 value="$city">
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
<!--
  <tr>
    <td width="20%" align=center>
    <b>Active Site</b>
    </td>
    <td width="80%" align=left>
    <input name=isactive type=checkbox value='T' $checkedifactive>
    </td>
  </tr>
-->
  </table>
modifyform

#  'print "$sqlstring<br>\n";
# $rc = $dbh->do($sqlstrings[$counter]);
  print "<input name=action type=hidden value=modify_site>\n";
  }

if ($cgiaction eq "add_selected")
  {
  $submitonly = 1;

  print <<addform;
  <input name=cgiaction type=hidden value="add_site">
  <table summary="add site entry" width="100%" border=1>
  <tr>
    <td width="20%" align=center>
    <b>Site Name</b>
    </td>
    <td width="80%" align=left>
    <input name=name type=text maxlength=30 size=30 value=$name>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>City</b>
    </td>
    <td width="80%" align=left>
    <input name=city type=text maxlength=30 size=30 value=$city>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>State</b>
    </td>
    <td width="80%" align=left>
    <input name=state type=text maxlength=2 size=2 value=$state>
    </td>
  </tr>
  </table>
addform

  print "<input name=action type=hidden value=add_site>\n";
  }

if ($cgiaction eq "query")
  {
  %sitehash = get_lookup_values($dbh, $updatetable, "siteid", "name");

  print<<queryformtop;
  <select name=selectedsite size=10>
queryformtop

  foreach $key (sort keys %sitehash)
    {
    print "<option value=\"$key\">$sitehash{$key}\n";
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
  print "<input name=add type=submit value=\"Add New Site\" onclick=\"document.sitemaint.action.value='add_selected'\">\n";
  print "<input name=modify type=submit value=\"Modify Selected Site\" onclick=\"dosubmit=true; (document.sitemaint.selectedsite.selectedIndex == -1) ? (alert(\'No Site Selected\') || (dosubmit = false)) : document.sitemaint.action.value='modify_selected'; return(dosubmit)\">\n";
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
