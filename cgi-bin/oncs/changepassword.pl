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

$pagetitle = "Password";
$cgiaction = $testout->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
$submitonly = 0;
$usersid = $testout->param('loginusersid');
$username = $testout->param('loginusername');
$updatetable = "users";

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq ""))
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
     
    function comparenew(np1, np2)
      {
      if (np1.value != np2.value)
        {
        alert ("You entered two different new passwords.");
        return (false);
        }
      return (true);
      }

    //-->
  </script>
testlabel1

$badpassword = 0;

if ($cgiaction eq "change_password")
  {
  # print the sql which will update this table
  $oldpassword = $testout->param('oldpass');
  $newpassword = $testout->param('newpass');
  if ( !( ($oldpassword eq "") && ($newpassword eq "") ) )
    {
    $password = oncs_encrypt_password($newpassword);
    # connect to the oracle database and generate a database handle
    $dbh = oncs_connect();
  
    $status = validate_user($dbh, $username, $oldpassword);
    if ($status == 1)  # we have a valid user
      {
      $sqlstring = "UPDATE $SCHEMA.$updatetable SET password='$password'
                    WHERE usersid=$usersid";

#     print "$sqlstring<br>\n";
      $rc = $dbh->do($sqlstring);

      $cgiaction="query";

      #disconnect from the database
      &oncs_disconnect($dbh);
      
      #password changed, go back to home page.
      
      print <<gotomainmenu;
      </form>
      <script type="text/javascript">
      <!-- 
      location='/cgi-bin/oncs/oncs_home.pl?loginusersid=$usersid&loginusername=$username';
      //-->
      </script>
gotomainmenu
      exit 1;
      }
    # not valid old password (probably a typo), proceed and post the invalid password statement
    $badpassword = 1;
    }
  else
    {
    # no old or new password entered, return to the home page.
    
    print <<gotomainmenu;
    </form>
    <script type="text/javascript">
    <!-- 
    location='/cgi-bin/oncs/oncs_home.pl?loginusersid=$usersid&loginusername=$username';
    //-->
    </script>
gotomainmenu
    exit 1;
    }  
  }

print "</head>\n\n";
print "<body>\n";

# print the values passed to the cgi script.
#foreach $key ($testout->param)
#  {
#  print "<B>$key</B> -> ";
#  @values = $testout->param($key);
#  print join(",  ",@values), "[--<BR>\n";
#  }

print "<center><h1>$pagetitle Maintenance</h1></center>\n";

if ($badpassword)
  {
  print "<center>The old password you entered was incorrect, your password has not been changed.</center><br>\n";
  }
  
print "<form action=\"/cgi-bin/oncs/changepassword.pl\" method=post name=passmaint onsubmit=\"return(comparenew(document.passmaint.newpass, document.passmaint.newpass2))\">\n";

#display the change password form
print <<userpassform;
<input name=cgiaction type=hidden value="change_password">
<table summary="modify password table" width="100%" border=1>
<tr>
  <td width="20%" align=center>
  <b>User ID</b>
  </td>
  <td width="80%" align=left>
  <b>$username</b>
  <input name=usersid type=hidden value=$usersid>
  <input name=username type=hidden value=$username>
  </td>
</tr>
<tr>
  <td width="20%" align=center>
  <b>Old Password</b>
  </td>
  <td width="80%" align=left>
  <input name=oldpass type=password maxlength=50 size=50>
  </td>
</tr>
<tr>
  <td width="20%" align=center>
  <b>New Password</b>
  </td>
  <td width="80%" align=left>
  <input name=newpass type=password maxlength=50 size=50>
  </td>
</tr>
<tr>
  <td width="20%" align=center>
  <b>New Password<br>Re-Enter to Verify</b>
  </td>
  <td width="80%" align=left>
  <input name=newpass2 type=password maxlength=50 size=50>
  </td>
</tr>
</table>
userpassform

print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=loginusername type=hidden value=$username>\n";
print "<input name=loginusersid type=hidden value=$usersid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";

# print html footers.
print "<br>\n";
print "<input name=submit type=submit value=\"Submit Changes\">\n";
print "</form>\n";
# menu to return to the maintenance menu and the main screen
#print "<ul title=\"Link Menu\"><b>Link Menu</b>\n<li><a href=\"/dcmm/prototype/maintenance.htm\">Maintenance Screen</a></li>\n";
#print "<li><a href=\"/dcmm/prototype/home.htm\">Main Menu</a></li>\n";
#print "</ul><br><br>\n";

print "</body>\n";
print "</html>\n";
