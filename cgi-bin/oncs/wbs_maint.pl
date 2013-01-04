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
print "<form action=\"/cgi-bin/oncs/wbs_maint.pl\" method=post name=wbsmaint>\n";

if ($cgiaction eq "add_wbs")
  {
  # print the sql which will update this table
  $changerequestnum = $testout->param('changerequestnum');
  $controlaccountid = $testout->param('controlaccountid');
  $description = $testout->param('description');
  $description =~ s/'/''/g;
  $pointofcontact = $testout->param('pointofcontact');
  $pointofcontact =~ s/'/''/g;
  $isactive = 'T';

  $sqlstring = "INSERT INTO $SCHEMA.$updatetable VALUES ('$changerequestnum', '$controlaccountid',
                             '$description', '$pointofcontact', '$isactive')";

# print "$sqlstring<br>\n";
  $rc = $dbh->do($sqlstring);
  $cgiaction="query";
  }

if ($cgiaction eq "modify_wbs")
  {
  # print the sql which will update this table
  $changerequestnum = $testout->param('changerequestnum');
  $controlaccountid = $testout->param('controlaccountid');
  $description = $testout->param('description');
  $description =~ s/'/''/g;
  $pointofcontact = $testout->param('pointofcontact');
  $pointofcontact =~ s/'/''/g;
  $isactive = ($testout->param('isactive') eq 'T') ? 'T' : 'F';

  $sqlstring = "UPDATE $SCHEMA.$updatetable SET description='$description',
                           pointofcontact='$pointofcontact', isactive='$isactive'
                           WHERE changerequestnum = '$changerequestnum'
                           AND   controlaccountid = '$controlaccountid'";

  #print "$sqlstring<br>\n";
  $rc = $dbh->do($sqlstring);
  $cgiaction="query";
  }

if ($cgiaction eq "modify_selected")
  {
  $thiswbs = $testout->param('selectedwbs');
  $submitonly = 1;

  %wbshash = get_wbs_info($dbh, $thiswbs);

  # print the sql which will update this table
  $changerequestnum = $wbshash{'changerequestnum'};
  $controlaccountid = $wbshash{'controlaccountid'};
  $description      = $wbshash{'description'};
  $pointofcontact   = $wbshash{'pointofcontact'};
  $isactive         = $wbshash{'isactive'};
  $checkedifactive  = ($isactive eq 'T') ? "checked" : "";

  print <<modifyform;
  <input name=cgiaction type=hidden value="modify_wbs">
  <table summary="modify wbs table" width="100%" border=1>
  <tr>
    <td width="20%" align=center>
    <b>Change Request Number</b>
    </td>
    <td width="80%" align=left>
    <b>$changerequestnum</b>
    <input name=changerequestnum type=hidden value=$changerequestnum>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Control Account Id</b>
    </td>
    <td width="80%" align=left>
    <b>$controlaccountid</b>
    <input name=controlaccountid type=hidden value=$controlaccountid>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Description</b>
    </td>
    <td width="80%" align=left>
    <input name=description type=text maxlength=50 size=50 value="$description">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Point Of Contact</b>
    </td>
    <td width="80%" align=left>
    <input name=pointofcontact type=text maxlength=50 size=50 value="$pointofcontact">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Active WBS</b>
    </td>
    <td width="80%" align=left>
    <input name=isactive type=checkbox value='T' $checkedifactive>
    </td>
  </tr>
  </table>
modifyform

#  'print "$sqlstring<br>\n";
# $rc = $dbh->do($sqlstrings[$counter]);
  print "<input name=action type=hidden value=modify_wbs>\n";
  }

if ($cgiaction eq "add_selected")
  {
  $submitonly = 1;

  print <<addform;
  <input name=cgiaction type=hidden value="add_wbs">
  <table summary="add wbs entry" width="100%" border=1>
  <tr>
    <td width="20%" align=center>
    <b>Change Request Number</b>
    </td>
    <td width="80%" align=left>
    <input name=changerequestnum type=text maxlength=10 size=10 value=$changerequestnum>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Control Account Id</b>
    </td>
    <td width="80%" align=left>
    <input name=controlaccountid type=text maxlength=10 size=10 value=$controlaccountid>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Description</b>
    </td>
    <td width="80%" align=left>
    <input name=description type=text maxlength=50 size=50 value=$description>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Point Of Contact</b>
    </td>
    <td width="80%" align=left>
    <input name=pointofcontact type=text maxlength=50 size=50 value=$pointofcontact>
    </td>
  </tr>
  </table>
addform

  print "<input name=action type=hidden value=add_wbs>\n";
  }

if ($cgiaction eq "query")
  {
  %wbshash = get_lookup_values($dbh, $updatetable, "changerequestnum || ' . ' || controlaccountid", "description");

  print<<queryformtop;
  <select name=selectedwbs size=10>
queryformtop

  foreach $key (sort keys %wbshash)
    {
    print "<option value=\"$key\">$wbshash{$key}\n";
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
  print "<input name=add type=submit value=\"Add New WBS\" onclick=\"document.wbsmaint.action.value='add_selected'\">\n";
  print "<input name=modify type=submit value=\"Modify Selected WBS\" onclick=\"dosubmit=true; (document.wbsmaint.selectedwbs.selectedIndex == -1) ? (alert(\'No Work Breakdown Structure Selected\') || (dosubmit = false)) : document.wbsmaint.action.value='modify_selected'; return(dosubmit)\">\n";
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
