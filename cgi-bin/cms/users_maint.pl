#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
#
# CMS User Maintenance Script
#
# $Source: /data/dev/rcs/cms/perl/RCS/users_maint.pl,v $
# $Revision: 1.18 $
# $Date: 2002/10/04 21:42:16 $
# $Author: naydenoa $
# $Locker:  $
# $Log: users_maint.pl,v $
# Revision 1.18  2002/10/04 21:42:16  naydenoa
# Added "use strict"
#
# Revision 1.17  2002/04/12 23:49:42  naydenoa
# Checkpoint
#
# Revision 1.16  2001/05/11 22:33:47  naydenoa
# Took out privilege assignment
#
# Revision 1.15  2001/03/20 22:58:30  naydenoa
# Added log message for user update and insert
#
# Revision 1.14  2001/02/17 00:28:29  naydenoa
# Added location and organizaton
#
# Revision 1.13  2000/11/22 00:12:19  naydenoa
# Took out password assignment for new users.
# Default password is "password"
#
# Revision 1.12  2000/10/03 20:45:10  naydenoa
# Interface update.
#
# Revision 1.11  2000/10/02 18:23:27  atchleyb
# replaced username generator with one used in EIS
#
# Revision 1.10  2000/09/28 16:04:59  atchleyb
# added names to insert
# added button to clear priv list
#
# Revision 1.9  2000/09/21 21:42:46  atchleyb
# updated title
#
# Revision 1.8  2000/08/22 15:54:39  atchleyb
# added check schema line
#
# Revision 1.7  2000/07/24 16:22:49  johnsonc
# Inserted GIF file for display.
#
# Revision 1.6  2000/07/12 21:18:07  munroeb
# finished mods for html formatting.
#
# Revision 1.5  2000/07/11 16:44:33  munroeb
# finished modifying html formatting.
#
# Revision 1.4  2000/07/06 23:50:53  munroeb
# finished making mods to html and javascripts.
#
# Revision 1.3  2000/07/05 23:14:02  munroeb
# made minor changes to html and javascripts
#
# Revision 1.2  2000/05/18 23:17:03  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/12 00:03:57  zepedaj
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
my $cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = $cmscgi->param('updatetable');
my ($one, $two, $three, $four);

my $nextusersid;
my $lastname;
my $firstname;
my $areacode;
my $phonenumber;
my $extension;
my $email;
my $location;
my $organization;
my $thisusersid;
my $thisusername;
my %userhash;
my $isactive;
my $key;
my %sitehash;
my $siteid;
my $usernamestring;
my $checkedifactive;
my $rc;
my $password;
my $sqlstring;
my $selectedoption;

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "") || (!defined($pagetitle)) || ($pagetitle eq "") || (!defined($updatetable)) || ($updatetable eq "")) {
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
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>
<!--   <script src=/dcmm/prototype/javascript/dcmm-utilities.js></script> -->
    <script type="text/javascript">
    <!--
    var dosubmit = true;
    if (parent == self) {   // not in frames 
	location = '$ONCSCGIDir/login.pl'
    }
    //-->
    </script>
  <script language="JavaScript" type="text/javascript">
  <!--
      doSetTextImageLabel('Users Maintenance');
  //-->
  </script>
testlabel1

print "</head>\n\n";
print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><CENTER>\n";

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

#print "<center><h1>$pagetitle Maintenance</h1></center>\n";
print "<form action=\"$ONCSCGIDir/users_maint.pl\" method=post name=usermaint>\n";

###############################
if ($cgiaction eq "add_user") {
###############################
    # print the sql which will update this table
    #$nextusersid = get_maximum_id($dbh, $updatetable) + 1;
    $nextusersid = get_next_id($dbh, $updatetable);
    $lastname = $cmscgi->param('lastname');
    $lastname =~ s/\'/\'\'/g;
    $firstname = $cmscgi->param('firstname');
    $firstname =~ s/\'/\'\'/g;
    $areacode = $cmscgi->param('areacode');
    $phonenumber = $cmscgi->param('phonenumber');
    $extension = $cmscgi->param('extension');
    $email = $cmscgi->param('email');
    $email =~ s/\'/\'\'/g;
    $location = $cmscgi -> param ('location');
    $location =~ s/\'/\'\'/g;
    $organization = $cmscgi -> param ('organization');
    $organization =~ s/\'/\'\'/g;

    # generate username
    ###$thisusername = make_username($dbh, $lastname, $firstname); # old username generator
    if (length($lastname) >7) {
	$thisusername = substr (uc($lastname), 0, 7) . substr(uc($firstname), 0, 1);
    } 
    else {
	$thisusername = uc($lastname) . substr(uc($firstname), 0, 1);
    }
    $password = oncs_encrypt_password("password");
    $siteid = $cmscgi->param('siteid');
    $isactive = 'T';
    
    $sqlstring = "INSERT INTO $SCHEMA.$updatetable 
                         (usersid, lastname, firstname, areacode, phonenumber,
                          extension, email, isactive, siteid, username,
                          password, location, organization) 
                  VALUES ($nextusersid, '$lastname', '$firstname',
                          '$areacode', '$phonenumber', '$extension', '$email',
                          '$isactive', $siteid, '$thisusername', '$password',
                          '$location', '$organization')";
    $rc = $dbh->do($sqlstring);
    &log_activity($dbh, 'F', $usersid, "User $thisusername added to the system");
    $cgiaction="query";
} ####  endif add user  ####

##################################
if ($cgiaction eq "modify_user") {
##################################
    # print the sql which will update this table
    $thisusersid = $cmscgi->param('thisusersid');
    $lastname = $cmscgi->param('lastname');
    $lastname =~ s/\'/\'\'/g;
    $firstname = $cmscgi->param('firstname');
    $firstname =~ s/\'/\'\'/g;
    $areacode = $cmscgi->param('areacode');
    $phonenumber = $cmscgi->param('phonenumber');
    $extension = $cmscgi->param('extension');
    $email = $cmscgi->param('email');
    $email =~ s/\'/\'\'/g;
    $location = $cmscgi -> param ('location');
    $location =~ s/\'/\'\'/g;
    $organization = $cmscgi -> param ('organization');
    $organization =~ s/\'/\'\'/g;
    $thisusername = $cmscgi->param('thisusername');
    $password = $cmscgi->param('password');
    $siteid = $cmscgi->param('siteid');
    if ($password ne $cmscgi->param('oldpassword')) {
	# encrypt new password
	$password = oncs_encrypt_password($cmscgi->param('password'));
    }
    $isactive = ($cmscgi->param('isactive') eq 'T') ? 'T' : 'F';
    
    $sqlstring = "UPDATE $SCHEMA.$updatetable 
                  SET lastname='$lastname', firstname='$firstname',
                      areacode='$areacode', phonenumber='$phonenumber', 
                      extension='$extension', email='$email', 
                      isactive='$isactive', siteid=$siteid,
                      username='$thisusername', password='$password',
                      location = '$location', organization = '$organization'
                  WHERE usersid=$thisusersid";

    $rc = $dbh->do($sqlstring);
    &log_activity($dbh, 'F', $usersid, "User $thisusername updated");
    $cgiaction="query";
}  ####  endif modify user  ####

######################################
if ($cgiaction eq "modify_selected") {
######################################
    $thisusersid = $cmscgi->param('selecteduser');
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
    $location = $userhash{'location'};
    $organization = $userhash{'organization'};
    
    print <<modifyform;
    <input name=cgiaction type=hidden value="modify_user">
    <input type=hidden name=schema value=$SCHEMA>
    <br><br>
    <table summary="modify user table" width="720" border=0>
    <tr><td width="35%" align=left><b><li>User ID:</b></td>
    <td width="65%" align=left><b>$thisusername</b>
    <input name=thisusersid type=hidden value=$thisusersid>
    <input name=thisusername type=hidden value=$thisusername></td></tr>
    <tr><td align=left><b><li>Last Name:</b></td>
    <td align=left><input name=lastname type=text maxlength=30 size=35 value="$lastname" onload="focus()"></td></tr>
    <tr><td align=left><b><li>First Name:</b></td>
    <td align=left><input name=firstname type=text maxlength=30 size=35 value="$firstname"></td></tr>
    <tr><td align=left><b><li>Location:</b></td>
    <td align=left><input name=location type=text maxlength=75 size=80 value="$location"></td></tr>
    <tr><td align=left><b><li>Organization:</b></td>
    <td align=left><input name=organization type=text maxlength=75 size=80 value="$organization"></td></tr>

    <tr><td align=left><b><li>Phone Number:</b></td>
    <td><b>Area Code:</b>&nbsp;&nbsp;
    (<input name=areacode type=text maxlength=3 size=5 value=$areacode>)&nbsp;&nbsp;
    <b>Number:</b>&nbsp;&nbsp;
    <input name=phonenumber type=text maxlength=7 size=10 value=$phonenumber>&nbsp;&nbsp;(no hyphen)&nbsp;&nbsp;
    <b>Extension:</b>&nbsp;&nbsp;
    <input name=extension type=text maxlength=5 size=8 value=$extension></td></tr>
    <tr><td align=left><b><li>Email Address:</b></td>
    <td align=left><input name=email type=text maxlength=75 size=80 value="$email"></td></tr>
    <tr><td><b><li>Password:</b></td>
    <td align=left><input name=password type=password maxlength=50 size=50 value=$password>
    <input type=hidden name=oldpassword value=$password></td></tr>
    <tr><td><b><li>Site:</b></td>
    <td align=left>
modifyform
    print "<select name=siteid>\n";
    %sitehash = get_lookup_values($dbh, "site", "name", "siteid");
    foreach $key (sort keys %sitehash) {
	$selectedoption = ($sitehash{$key} == $siteid) ? "selected" : "";
	print "<option value=$sitehash{$key} $selectedoption>$key\n";
    }
    print"</select>\n";
    ##<input name=siteid type=text maxlength=2 size=2 value="$siteid">
print <<modifyform2;
    </td></tr>
    <tr><td align=left><b><li>Active User:</b></td>
    <td align=left><input name=isactive type=checkbox value='T' $checkedifactive></td></tr>
    </table>
modifyform2
    print "<br>\n<br>\n";
    print "<input name=action type=hidden value=modify_user>\n";
}  #### endif modify selected  ####

###################################
if ($cgiaction eq "add_selected") {
###################################
    $submitonly = 1;
    
    print <<addform;
    <input name=cgiaction type=hidden value="add_user">
    <br><br>
    <table summary="add user table" width="720" border=0>
    <tr><td width="20%"><b><li>Last Name:</b></td>
    <td width=80%><input name=lastname type=text maxlength=30 size=35 value="$lastname"></td></tr>
    <tr><td><b><li>First Name:</b></td>
    <td><input name=firstname type=text maxlength=30 size=35 value="$firstname"></td></tr>
    <tr><td align=left><b><li>Location:</b></td>
    <td align=left><input name=location type=text maxlength=75 size=75 value="$location"></td></tr>
    <tr><td align=left><b><li>Organization:</b></td>
    <td align=left><input name=organization type=text maxlength=75 size=75 value="$organization"></td></tr>

    <tr><td><b><li>Phone Number:</b></td>
    <td><b>Area Code:&nbsp;</b>
    (<input name=areacode type=text maxlength=3 size=5 value=$areacode>)
    &nbsp;&nbsp;<b>Number:&nbsp;</b>
    <input name=phonenumber type=text maxlength=7 size=10 value=$phonenumber>&nbsp;(no hyphen)
    &nbsp;&nbsp;<b>Extension:</b>
    &nbsp;<input name=extension type=text maxlength=5 size=8 value=$extension></td></tr>
    <tr><td><b><li>Email Address:</b></td>
    <td> <input name=email type=text maxlength=75 size=80 value=$email></td></tr>
    <!-- tr><td><b><li>Password:</b></td>
    <td><input name=password type=password maxlength=50 size=50 value=$password>
    <input type=hidden name=oldpassword value=$password></td></tr -->
    <tr><td><b><li>Site:</b></td>
    <td>
addform
    print "<select name=siteid>\n";
    %sitehash = get_lookup_values($dbh, "site", "name", "siteid");
    foreach $key (sort keys %sitehash) {
	print "<option value=\"$sitehash{$key}\">$key\n";
    }
    print"</select>\n";
    ##<input name=siteid type=text maxlength=2 size=2 value="$siteid">
print <<addform2;
    </td></tr>
    </table>
addform2
    
    print "<br>\n<br>\n";
    print "<input name=action type=hidden value=add_user>\n";
}  #### endif add_selected  ####

###################################
if ($cgiaction eq "reset_passwd") {
###################################
    my $uid = $cmscgi->param('selecteduser');
    $password = oncs_encrypt_password("password");
    my $uname = $dbh -> selectrow_array ("select username from $SCHEMA.users where usersid=$uid");

    $sqlstring = "update $SCHEMA.users 
                  set password='$password'
                  where usersid=$uid";
    $rc = $dbh->do($sqlstring);
    &log_activity($dbh, 'F', $usersid,"Reset password for user $uname");
    $cgiaction="query";
}  ####  endif reset_passwd  ####

############################
if ($cgiaction eq "query") {
############################
    %userhash = get_lookup_values($dbh, $updatetable, "lastname || ', ' || firstname || ';' || usersid", 'usersid');
    
    print "<br><select name=selecteduser size=10>\n";
    foreach $key (sort keys %userhash) {
	$usernamestring = $key;
	$usernamestring =~ s/;$userhash{$key}//g;
	print "<option value=\"$userhash{$key}\">$usernamestring\n";
    }
    print "</select><br>\n";
    print "<input name=action type=hidden value=query>\n";
}
print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=loginusername type=hidden value=$username>\n";
print "<input name=loginusersid type=hidden value=$usersid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";
&oncs_disconnect($dbh);

# print html footers.
if ($submitonly == 0) {
    print "<br><input name=add type=submit value=\"Add User\" title=\"Add new user to the system\" onclick=\"document.usermaint.action.value='add_selected'\">\n";
    print "<input name=modify type=submit value=\"Modify User\" title=\"Modify selected user's record\" onclick=\"dosubmit=true; (document.usermaint.selecteduser.selectedIndex == -1) ? (alert(\'No User Selected\') || (dosubmit = false)) : document.usermaint.action.value='modify_selected'; return(dosubmit)\">\n";
    print "<input name=reset type=submit value=\"Reset Password\" title=\"Reset selected user's password\" onclick=\"dosubmit=true; (document.usermaint.selecteduser.selectedIndex==-1) ? (alert(\'No user selected\') || (dosubmit = false)) : document.usermaint.action.value='reset_passwd'; return(dosubmit)\">\n";
}
else {
    print "<input name=submit type=submit value=\"Submit Changes\">\n";
}
print "</form>\n";
print "</CENTER><br><br></body>\n";
print "</html>\n";
