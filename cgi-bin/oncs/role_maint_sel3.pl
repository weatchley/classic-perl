#!/usr/local/bin/newperl
# - !/usr/bin/perl

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $cirscgi = new CGI;

# print content type header
print $cirscgi->header('text/html');

my $username = $cirscgi->param('loginusername');
my $usersid = $cirscgi->param('loginusersid');
my $cgiaction = $cirscgi->param('cgiaction');
my $dependson = $cirscgi->param('dependson');
my $dependid = $cirscgi->param('dependselection');
my $siteid = $cirscgi->param('siteid');
my $roleid = $cirscgi->param('roleid');

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq ""))
  {
  print <<openloginpage;
  <script type="text/javascript">
  <!-- 
  _top.location='/cgi-bin/oncs/oncs_user_login.pl';
  //-->
  </script>
openloginpage
  exit 1;
  }

#print top of page
print <<topofpage1;
<html>
<head>
<meta name="pragma" content="no-cache">
<meta name="expires" content="0">
<meta http-equiv="expires" content="0">
<meta http-equiv="pragma" content="no-cache">
topofpage1

print <<scriptlabel1;
<!-- include external javascript code -->
<script src="$ONCSJavaScriptPath/oncs-utilities.js"></script>
scriptlabel1

print <<endofhead;
</head>
endofhead

my $dbh = oncs_connect();

if ($cgiaction eq "process")
  {
  my $selectedusersid = $cirscgi->param('userselection');
  my $roletablename = 'Default' . (($dependson) ? $dependson : 'site') . 'role';
  $dependid = $cirscgi->param('dependid');
  
  my $roledeletesqlstring = "DELETE FROM $SCHEMA.$roletablename 
                             WHERE roleid = $roleid AND siteid = $siteid" . 
                             (($dependson) ? " AND " . $dependson . "id = $dependid" : '');
                             
  my $roleupdatesqlstring = "INSERT INTO $SCHEMA.$roletablename
                             VALUES (" . 
                             (($dependson) ? "$dependid, " : "") .
                             "$roleid, $siteid, $selectedusersid)";
                             
#  print "$roledeletesqlstring<br>\n";
#  print "$roleupdatesqlstring<br>\n";

  $dbh->{AutoCommit} = 0;
  $dbh->{RaiseError} = 1;
  my $activity = "Change $roletablename.";
  eval
    {
    my $csr = $dbh->prepare($roledeletesqlstring);
    my $rv = $csr->execute;
    $csr = $dbh->prepare($roleupdatesqlstring);
    $csr->execute;
    };
  if ($@)
    {
    $dbh->rollback;
    my $alertstring = errorMessage($dbh, $username, $usersid, $roletablename, "$roleid, $siteid, $selectedusersid, $dependid", $activity, $@);
    $alertstring =~ s/"/'/g;
    print <<pageerror;
    <script language="JavaScript" type="text/javascript">
      <!--
      alert("$alertstring");
      parent.parent.control.location="/oncs/blank.pl?loginusersid=$usersid&loginusername=$username";
      //-->
    </script>
pageerror
    }
  else
    {
    print <<pageresults;
    <script language="JavaScript" type="text/javascript">
      <!--
      parent.parent.workspace.location="/cgi-bin/oncs/role_maint.pl?loginusersid=$usersid&loginusername=$username";
      parent.parent.control.location="/oncs/blank.pl?loginusersid=$usersid&loginusername=$username";
      //-->
    </script>
pageresults
    }
  $dbh->commit;
  $dbh->{AutoCommit} = 1;
  $dbh->{RaiseError} = 0;
  &oncs_disconnect($dbh);
  print "</html>\n";

  exit 1;
  }

my %usershash = get_lookup_values($dbh, "users", "lastname || ', ' || firstname || ';' || usersid", "usersid", "isactive = 'T'");
my %defaultrolehash = get_default_role_values($dbh, $roleid, $siteid, $dependson, $dependid);
my $defaultroleusersid = $defaultrolehash{'usersid'};

#This is the role/Site picklist section. It contains two selects and targets the role_maint_sel2.pl to interpret its results.
print <<userrolebody1;
<body>
<form name=role_maint_sel3 action=/cgi-bin/oncs/role_maint_sel3.pl target=control method=post onsubmit="return(verify_input());">
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
<input type=hidden name=siteid value=$siteid>
<input type=hidden name=roleid value=$roleid>
<input type=hidden name=dependson value=$dependson>
<input type=hidden name=dependid value=$dependid>
<input type=hidden name=cgiaction value="process">
<table summary="Role Assignee Selection" width=100% border=0>
<tr width=100%>
  <td width=30% align=center>
  <b>Person</b>
  </td>
  <td width=70% align=left>
  <select name=userselection>
  <option value=0>Select the person to be the default for this role
userrolebody1
foreach my $key (sort keys %usershash)
  {
  my $usernamestring = $key;
  $usernamestring =~ s/;$usershash{$key}//g;
  my $selectedstring = ($defaultroleusersid == $usershash{$key}) ? "selected" : "";
  print "  <option value=$usershash{$key} $selectedstring>$usernamestring\n";
  }
print <<userrolebody2;
  </select>
  </td>
</tr>
<tr>
  <td></td>
  <td>
  <input type=submit name=role_save value="Save Changes">
  </td>
</tr>
</table>
</form>
</body>

<script language="JavaScript" type="text/javascript">
  <!--
  function verify_input()
    {
    var isfilledout;
    var userselec = document.role_maint_sel3.userselection;
    
    isfilledout = (userselec.options[userselec.selectedIndex].value != 0);
    if (! isfilledout)
      {
      alert ("You must select a valid user for this role.");
      }
    return(isfilledout);
    //return(false);
    }  
  //-->
</script>
userrolebody2
print "</html>\n";
&oncs_disconnect($dbh);
