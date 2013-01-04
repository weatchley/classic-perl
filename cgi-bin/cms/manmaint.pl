#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
#
# CMS Managers Maintenance Script
#
# $Source: /data/dev/rcs/cms/perl/RCS/manmaint.pl,v $
# $Revision: 1.4 $
# $Date: 2003/01/03 23:26:42 $
# $Author: naydenoa $
# $Locker:  $
# $Log: manmaint.pl,v $
# Revision 1.4  2003/01/03 23:26:42  naydenoa
# Updated activity log entry to reflect manager type
#
# Revision 1.3  2003/01/03 00:42:24  naydenoa
# Added type to manager retrieval to accommodate the new DOE manager role
# CREQ00023
#
# Revision 1.2  2002/10/04 21:20:42  naydenoa
# Added "use strict"
#
# Revision 1.1  2002/01/04 17:15:27  naydenoa
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

my $mgrtype = $cmscgi -> param ("mgrtype");
my $pagetitle = $cmscgi->param('pagetitle');
my $cgiaction = $cmscgi->param('action');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = $cmscgi->param('updatetable');
my ($one, $two, $three, $four);
my $firstname;
my $lastname;
my $sqlstring;
my $nextusersid;
my $rc;
my $thisusersid;
my $thisusername;
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
my $header = ($mgrtype == 1) ? "BSC" : "DOE";
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
      doSetTextImageLabel('$header Responsible Managers Maintenance');
  //-->
  </script>
testlabel1

print "</head>\n\n";
print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><CENTER>\n";

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

#print "<center><h1>$pagetitle Maintenance</h1></center>\n";
print "<form action=\"$ONCSCGIDir/manmaint.pl\" method=post name=usermaint>\n";

###############################
if ($cgiaction eq "add_user") {
###############################
    my $mgrtype = $cmscgi -> param ("mgrtype");
    # print the sql which will update this table
    $nextusersid = get_maximum_id($dbh, $updatetable) + 1;
#    $nextusersid = get_next_id($dbh, $updatetable);
    $lastname = $cmscgi->param('lastname');
    $lastname =~ s/\'/\'\'/g;
    $firstname = $cmscgi->param('firstname');
    $firstname =~ s/\'/\'\'/g;

    $sqlstring = "INSERT INTO $SCHEMA.$updatetable 
                         (responsiblemanagerid, lastname, firstname, 
                          managertypeid)
                  VALUES ($nextusersid, '$lastname', '$firstname', $mgrtype)";
    $rc = $dbh -> do($sqlstring);
    my $type = ($mgrtype==1) ? "BSC" : "DOE";
    &log_activity($dbh, 'F', $usersid, "$type Manager $lastname added to the system");
    $cgiaction="query";
} ##############  endif add user  ########################

##################################
if ($cgiaction eq "modify_user") {
##################################
    # print the sql which will update this table
    $thisusersid = $cmscgi->param('thisusersid');
    $lastname = $cmscgi->param('lastname');
    $lastname =~ s/\'/\'\'/g;
    $firstname = $cmscgi->param('firstname');
    $firstname =~ s/\'/\'\'/g;

    $sqlstring = "UPDATE $SCHEMA.$updatetable 
                  SET lastname='$lastname', firstname='$firstname'
                  WHERE responsiblemanagerid=$thisusersid";

    $rc = $dbh->do($sqlstring);
    my $type = ($mgrtype==1) ? "BSC" : "DOE";
    &log_activity($dbh, 'F', $usersid, "$type Manager $lastname updated");
    $cgiaction="query";
}  ###############  endif modify user  ####################

######################################
if ($cgiaction eq "modify_selected") {
######################################
    $thisusersid = $cmscgi->param('selecteduser');
    $submitonly = 1;
    
    my ($firstname, $lastname) = $dbh -> selectrow_array ("select firstname, lastname from $SCHEMA.responsiblemanager where responsiblemanagerid=$thisusersid"); 
    print <<modifyform;
    <input name=cgiaction type=hidden value="modify_user">
    <input type=hidden name=schema value=$SCHEMA>
    <input type=hidden name=mgrtype value=$mgrtype>
    <br><br>
    <table summary="modify user table" width="720" border=0>
    <tr><td width="35%" align=left><b><li>User ID:</b></td>
    <td width="65%" align=left><b>$thisusersid</b>
    <input name=thisusersid type=hidden value=$thisusersid>
    <! input name=thisusername type=hidden value=$thisusername></td></tr>
    <tr><td align=left><b><li>Last Name:</b></td>
    <td align=left><input name=lastname type=text maxlength=30 size=35 value="$lastname" onload="focus()"></td></tr>
    <tr><td align=left><b><li>First Name:</b></td>
    <td align=left><input name=firstname type=text maxlength=30 size=35 value="$firstname"></td></tr>
    </table>
modifyform
    print "<br>\n<br>\n";
    print "<input name=action type=hidden value=modify_user>\n";
} ############## endif modify selected  #######################

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
    </table>
addform
    
    print "<br>\n<br>\n";
    print "<input name=action type=hidden value=add_user>\n";
}

############################
if ($cgiaction eq "query") {
############################
    my $mgrs = $dbh -> prepare ("select responsiblemanagerid, firstname, lastname from $SCHEMA.responsiblemanager where managertypeid = $mgrtype order by lastname");   
    $mgrs -> execute;
    print "<br><br><select name=selecteduser size=10>\n";
    while (my ($mid, $first, $last) = $mgrs -> fetchrow_array) {
	print "<option value=\"$mid\">$first $last\n";
    }
    $mgrs -> finish;
    print "</select><br>\n";
    print "<input name=action type=hidden value=query>\n";
}
print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=loginusername type=hidden value=$username>\n";
print "<input name=loginusersid type=hidden value=$usersid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";
print "<input name=mgrtype type=hidden value=$mgrtype>\n";
&oncs_disconnect($dbh);

# print html footers.
if ($submitonly == 0) {
    print "<br><input name=add type=submit value=\"Add New $header Manager\" title=\"Add New $header Manager\" onclick=\"document.usermaint.action.value='add_selected'\">\n";
    print "<input name=modify type=submit value=\"Modify Selected $header Manager\" title=\"Modify Selected $header Manager\" onclick=\"dosubmit=true; (document.usermaint.selecteduser.selectedIndex == -1) ? (alert(\'No User Selected\') || (dosubmit = false)) : document.usermaint.action.value='modify_selected'; return(dosubmit)\">\n";
}
else {
    print "<input name=submit type=submit value=\"Submit Changes\">\n";
}
print "</form>\n";
print "</CENTER><br><br><br><br></body>\n";
print "</html>\n";


