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
$submitonly = 0;
$usersid = $testout->param('loginusersid');
$username = $testout->param('loginusername');
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
<!--   <script src=/dcmm/prototype/javascript/dcmm-utilities.js></script> -->

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
print "<form action=\"/cgi-bin/oncs/users_maint.pl\" method=post name=usermaint>\n";

if ($cgiaction eq "add_user")
  {
  # print the sql which will update this table
  #$nextusersid = get_maximum_id($dbh, $updatetable) + 1;
  $nextusersid = get_next_id($dbh, $updatetable);
  $lastname = $testout->param('lastname');
  $lastname =~ s/'/''/g;
  $firstname = $testout->param('firstname');
  $firstname =~ s/'/''/g;
  $areacode = $testout->param('areacode');
  $phonenumber = $testout->param('phonenumber');
  $extension = $testout->param('extension');
  $email = $testout->param('email');
  $email =~ s/'/''/g;
  $thisusername = make_username($dbh, $lastname, $firstname);
  $password = oncs_encrypt_password($testout->param('password'));
  $siteid = $testout->param('siteid');
  $isactive = 'T';
  @privilege = $testout->param('privilegeselect');

  $sqlstring = "INSERT INTO $SCHEMA.$updatetable VALUES ($nextusersid, '$lastname', '$firstname',
                           '$areacode', '$phonenumber', '$extension', '$email', '$isactive', $siteid,
                           '$thisusername', '$password')";

# print "$sqlstring<br>\n";
  $rc = $dbh->do($sqlstring);

  foreach $priv (@privilege)
    {
    $sqlstring = "INSERT INTO $SCHEMA.userprivilege VALUES ($priv, $nextusersid)";
    $rc = $dbh->do($sqlstring);
    }

  $cgiaction="query";
  }

if ($cgiaction eq "modify_user")
  {
  # print the sql which will update this table
  $thisusersid = $testout->param('thisusersid');
  $lastname = $testout->param('lastname');
  $lastname =~ s/'/''/g;
  $firstname = $testout->param('firstname');
  $firstname =~ s/'/''/g;
  $areacode = $testout->param('areacode');
  $phonenumber = $testout->param('phonenumber');
  $extension = $testout->param('extension');
  $email = $testout->param('email');
  $email =~ s/'/''/g;
  $thisusername = $testout->param('thisusername');
  $password = $testout->param('password');
  $siteid = $testout->param('siteid');
  if ($password ne $testout->param('oldpassword'))
    {
    # encrypt new password
    $password = oncs_encrypt_password($testout->param('password'));
    }
  $isactive = ($testout->param('isactive') eq 'T') ? 'T' : 'F';
  @privilege = $testout->param('privilegeselect');

  $sqlstring = "UPDATE $SCHEMA.$updatetable SET lastname='$lastname', firstname='$firstname',
                           areacode='$areacode', phonenumber='$phonenumber', extension='$extension',
                           email='$email', isactive='$isactive', siteid=$siteid,
                           username='$thisusername', password='$password'
           WHERE usersid=$thisusersid";

#  print "$sqlstring<br>\n";
  $rc = $dbh->do($sqlstring);

  $sqlstring = "DELETE $SCHEMA.userprivilege WHERE usersid=$thisusersid";
#  print "$sqlstring<br>\n";
  $rc = $dbh->do($sqlstring);

  foreach $priv (@privilege)
    {
    $sqlstring = "INSERT INTO $SCHEMA.userprivilege VALUES ($priv, $thisusersid)";
#    print "$sqlstring<br>\n";
    $rc = $dbh->do($sqlstring);
    }

  $cgiaction="query";
  }

if ($cgiaction eq "modify_selected")
  {
  $thisusersid = $testout->param('selecteduser');
  $submitonly = 1;

  %userhash = get_user_info($dbh, $thisusersid);

  # print the sql which will update this table
  $lastname =     $userhash{'lastname'};
  $firstname =    $userhash{'firstname'};
  $areacode =     $userhash{'areacode'};
  $phonenumber =  $userhash{'phonenumber'};
  $extension =    $userhash{'extension'};
  $email =        $userhash{'email'};
  $thisusername = $userhash{'thisusername'};
  $password =     $userhash{'password'};
  $isactive =     $userhash{'isactive'};
  $siteid =       $userhash{'siteid'};
  $checkedifactive = ($isactive eq 'T') ? "checked" : "";

  %privilegehash = get_lookup_values($dbh, 'privilege', 'description', 'privilegeid', "isactive = 'T'");
  %userprivilegehash = get_lookup_values($dbh, 'userprivilege', 'privilegeid', 'usersid', "usersid = $thisusersid");

  print <<modifyform;
  <input name=cgiaction type=hidden value="modify_user">
  <table summary="modify user table" width="100%" border=1>
  <tr>
    <td width="20%" align=center>
    <b>User ID</b>
    </td>
    <td width="80%" align=left>
    <b>$thisusername</b>
    <input name=thisusersid type=hidden value=$thisusersid>
    <input name=thisusername type=hidden value=$thisusername>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Last Name</b>
    </td>
    <td width="80%" align=left>
    <input name=lastname type=text maxlength=30 size=35 value="$lastname" onload="focus()">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>First Name</b>
    </td>
    <td width="80%" align=left>
    <input name=firstname type=text maxlength=30 size=35 value="$firstname">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Area Code</b>
    </td>
    <td width="80%" align=left>
    (<input name=areacode type=text maxlength=3 size=5 value=$areacode>)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Phone Number</b>
    </td>
    <td width="80%" align=left>
    <input name=phonenumber type=text maxlength=7 size=10 value=$phonenumber>  (no hyphen)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Extension</b>
    </td>
    <td width="80%" align=left>
    <input name=extension type=text maxlength=5 size=8 value=$extension>  (no hyphen)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Email Address</b>
    </td>
    <td width="80%" align=left>
    <input name=email type=text maxlength=75 size=80 value=$email>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Password</b>
    </td>
    <td width="80%" align=left>
    <input name=password type=password maxlength=50 size=50 value=$password>
    <input type=hidden name=oldpassword value=$password>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Site</b>
    </td>
    <td width="80%" align=left>
modifyform
    print "<select name=siteid>\n";
    %sitehash = get_lookup_values($dbh, "site", "name", "siteid");
    foreach $key (sort keys %sitehash)
      {
      $selectedoption = ($sitehash{$key} == $siteid) ? "selected" : "";
      print "<option value=$sitehash{$key} $selectedoption>$key\n";
      }
    print"</select>\n";
    ##<input name=siteid type=text maxlength=2 size=2 value="$siteid">
print <<modifyform2;
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Active User</b>
    </td>
    <td width="80%" align=left>
    <input name=isactive type=checkbox value='T' $checkedifactive>
    </td>
  </tr>
  </table>
modifyform2
  print "<br>\n<br>\n";
  print "<select multiple name=privilegeselect title=\"Select the privileges for this user.\" size=10>\n";
  foreach $key (sort keys %privilegehash)
    {
    $selectedoption = defined($userprivilegehash{$privilegehash{$key}}) ? "selected" : "";
    print "<option value=\"$privilegehash{$key}\" $selectedoption>$key\n";
    }
  print "</select>\n<br>\n";
  print "<input name=action type=hidden value=modify_user>\n";
  }

if ($cgiaction eq "add_selected")
  {
  $submitonly = 1;
  %privilegehash = get_lookup_values($dbh, 'privilege', 'description', 'privilegeid', "isactive = 'T'");

  print <<addform;
  <input name=cgiaction type=hidden value="add_user">
  <table summary="add user table" width="100%" border=1>
  <tr>
    <td width="20%" align=center>
    <b>Last Name</b>
    </td>
    <td width="80%" align=left>
    <input name=lastname type=text maxlength=30 size=35 value="$lastname">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>First Name</b>
    </td>
    <td width="80%" align=left>
    <input name=firstname type=text maxlength=30 size=35 value="$firstname">
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Area Code</b>
    </td>
    <td width="80%" align=left>
    (<input name=areacode type=text maxlength=3 size=5 value=$areacode>)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Phone Number</b>
    </td>
    <td width="80%" align=left>
    <input name=phonenumber type=text maxlength=7 size=10 value=$phonenumber>  (no hyphen)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Extension</b>
    </td>
    <td width="80%" align=left>
    <input name=extension type=text maxlength=5 size=8 value=$extension>  (no hyphen)
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Email Address</b>
    </td>
    <td width="80%" align=left>
    <input name=email type=text maxlength=75 size=80 value=$email>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Password</b>
    </td>
    <td width="80%" align=left>
    <input name=password type=password maxlength=50 size=50 value=$password>
    <input type=hidden name=oldpassword value=$password>
    </td>
  </tr>
  <tr>
    <td width="20%" align=center>
    <b>Site</b>
    </td>
    <td width="80%" align=left>
addform
    print "<select name=siteid>\n";
    %sitehash = get_lookup_values($dbh, "site", "name", "siteid");
    foreach $key (sort keys %sitehash)
      {
      print "<option value=\"$sitehash{$key}\">$key\n";
      }
    print"</select>\n";
    ##<input name=siteid type=text maxlength=2 size=2 value="$siteid">
print <<addform2;
    </td>
  </tr>
  </table>
addform2

  print "<br>\n<br>\n";
  print "<select multiple name=privilegeselect title=\"Select the privileges for this user.\" size=10>\n";
  foreach $key (sort keys %privilegehash)
    {
    print "<option value=\"$privilegehash{$key}\">$key\n";
    }
  print "</select>\n<br>\n";
  print "<input name=action type=hidden value=add_user>\n";
  }

if ($cgiaction eq "query")
  {
  %userhash = get_lookup_values($dbh, $updatetable, "lastname || ', ' || firstname || ';' || usersid", 'usersid');

  print<<queryformtop;
  <select name=selecteduser size=10>
queryformtop

  foreach $key (sort keys %userhash)
    {
    $usernamestring = $key;
    $usernamestring =~ s/;$userhash{$key}//g;
    print "<option value=\"$userhash{$key}\">$usernamestring\n";
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
  print "<input name=add type=submit value=\"Add New User\" title=\"Add New User\" onclick=\"document.usermaint.action.value='add_selected'\">\n";
  print "<input name=modify type=submit value=\"Modify Selected User\" title=\"Modify the Selected User's Record\" onclick=\"dosubmit=true; (document.usermaint.selecteduser.selectedIndex == -1) ? (alert(\'No User Selected\') || (dosubmit = false)) : document.usermaint.action.value='modify_selected'; return(dosubmit)\">\n";
#  print "<input name=privilege type=submit value=\"Assign Privileges/Roles\" title=\"Assign privileges or Roles to the selected user\" onclick=\"dosubmit=true; (document.usermaint.selecteduser.selectedIndex == -1) ? (alert(\'No User Selected\') || (dosubmit = false)) : document.usermaint.action.value='assign_privileges'; return(dosubmit)\">\n";
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
