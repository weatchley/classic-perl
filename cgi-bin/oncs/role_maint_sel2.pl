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
$dependson = "\u\L$dependson";
my $roleid = $cirscgi->param('roleid');
my $siteid = $cirscgi->param('siteid');

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
  my $dependid = $cirscgi->param('dependselection');

  print "<body>\n";
  
  print <<sel1procform1;
  <input type=hidden name=cgiaction value=query>  
  <input type=hidden name=loginusersid value=$usersid>
  <input type=hidden name=loginusername value=$username>
  <input type=hidden name=roleid value=$roleid>
  <input type=hidden name=siteid value=$siteid>
  <input type=hidden name=dependson value=$dependson>
  <input type=hidden name=dependid value=$dependid>
  </form>
  <script language="JavaScript" type="text/javascript">
  <!--
  document.sel1proc.submit();
  
  //parent.control.location="/cgi-bin/oncs/blank.pl?loginusersid=$usersid&loginusername=$username";
  
  //-->
</script>
sel1procform1
  &oncs_disconnect($dbh);
  exit 1;
  }

my %dependsonhash = get_lookup_values($dbh, $dependson, "description", $dependson . "id", "isactive = 'T'");

#This is the role/Site picklist section. It contains two selects and targets the role_maint_sel2.pl to interpret its results.
print <<dependbody1;
<body>
<form name=role_maint_sel2 action=/cgi-bin/oncs/role_maint_sel3.pl method=post target=rolesel3>
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
<input type=hidden name=dependson value=$dependson>
<input type=hidden name=roleid value=$roleid>
<input type=hidden name=siteid value=$siteid>
<table summary="Dependent Table Selection" width=100% border=0>
<tr width=100%>
  <td width=30% align=center>
  <b>$dependson</b>
  </td>
  <td width=70% align=left>
  <select name=dependselection onchange="checkandsubmit();">
  <option value=0>Select the $dependson to edit
dependbody1
foreach my $key (sort keys %dependsonhash)
  {
  print "  <option value=$dependsonhash{$key}>$key\n";
  }
print <<dependbody2;
  </select>
  </td>
</tr>
</table>
</form>
</body>

<script language="JavaScript" type="text/javascript">
  <!--
  function checkandsubmit()
    {
    var isfilledout;
    var dependselec = document.role_maint_sel2.dependselection;
    
    isfilledout = (dependselec.options[dependselec.selectedIndex].value != 0);
    if (isfilledout)
      {
      document.role_maint_sel2.submit();
      }
    }
  
  //-->
</script>
dependbody2
print "</html>\n";
&oncs_disconnect($dbh);
