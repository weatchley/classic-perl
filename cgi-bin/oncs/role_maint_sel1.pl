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
  my $selectedrole = $cirscgi->param('roleselection');
  my $selectedsite = $cirscgi->param('siteselection');
    
  my %rolehash = get_role_info($dbh, $selectedrole);
  my $dependson = $rolehash{'dependson'};

  print "<body>\n";
  
  if ($dependson)
    {
    # There is a dependent table, so frame rolesel2 will be used.
    print "<form name=sel1proc action=/cgi-bin/oncs/role_maint_sel2.pl target=rolesel2>\n";
    print "<input type=hidden name=dependson value=$dependson>\n";
    #rolesel3 should be made blank
    print <<blankrolesel3;
    <script language="JavaScript" type="text/javascript">
      <!--
      parent.workspace.rolesel3.location="/cgi-bin/oncs/blank.pl?loginusersid=$usersid&loginusername=$username";
      //-->
    </script>
blankrolesel3
    }
  else
    {
    # There is not a dependent table, so frame rolesel2 will be blank.
    # We will go directly to frame rolesel3.
    print "<form name=sel1proc action=/cgi-bin/oncs/role_maint_sel3.pl target=rolesel3>\n";
    print <<blankrolesel2;
    <script language="JavaScript" type="text/javascript">
      <!--
      parent.workspace.rolesel2.location="/cgi-bin/oncs/blank.pl?loginusersid=$usersid&loginusername=$username";
      //-->
    </script>
blankrolesel2
    }

  print <<sel1procform1;
  <input type=hidden name=cgiaction value=query>  
  <input type=hidden name=loginusersid value=$usersid>
  <input type=hidden name=loginusername value=$username>
  <input type=hidden name=roleid value=$selectedrole>
  <input type=hidden name=siteid value=$selectedsite>
  </form>
  <script language="JavaScript" type="text/javascript">
  <!--
  document.sel1proc.submit();
  
  parent.control.location="/cgi-bin/oncs/blank.pl?loginusersid=$usersid&loginusername=$username";
  
  //-->
</script>
sel1procform1
  &oncs_disconnect($dbh);
  exit 1;
  }

my %rolehash = get_lookup_values($dbh, "role", "description", "roleid", "isactive = 'T'");
my %sitehash = get_lookup_values($dbh, "site", "name || ' - ' || city || ', ' || state", "siteid");  

#This is the role/Site picklist section. It contains two selects and targets the role_maint_sel2.pl to interpret its results.
print <<rolebody1;
<body>
<form name=role_maint_sel1 action=/cgi-bin/oncs/role_maint_sel1.pl method=post target=control>
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
<input type=hidden name=cgiaction value="process">
<table summary="Role/Site Selection" width=100% border=0>
<tr width=100%>
  <td width=30% align=center>
  <b>Role</b>
  </td>
  <td width=70% align=left>
  <select name=roleselection onchange="checkandsubmit();">
  <option value=0>Select the Role to edit
rolebody1
foreach my $key (sort keys %rolehash)
  {
  print "  <option value=$rolehash{$key}>$key\n";
  }
print <<rolebody2;
  </select>
  </td>
</tr>
<tr>
  <td align=center>
  <b>Site</b>
  </td>
  <td align=left>
  <select name=siteselection onchange="checkandsubmit();">
  <option value=0>Select the Site for this role
rolebody2
foreach my $key (sort keys %sitehash)
  {
  print "  <option value=$sitehash{$key}>$key\n";
  }
print <<rolebody3;
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
    var roleselec = document.role_maint_sel1.roleselection;
    var siteselec = document.role_maint_sel1.siteselection
    
    isfilledout = ((roleselec.options[roleselec.selectedIndex].value != 0) && (siteselec.options[siteselec.selectedIndex].value != 0));
    if (isfilledout)
      {
      document.role_maint_sel1.submit();
      }
    }
  
  //-->
</script>
rolebody3
print "</html>\n";
&oncs_disconnect($dbh);
