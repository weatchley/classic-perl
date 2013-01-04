#!/usr/local/bin/newperl
# - !/usr/bin/perl

#
# CIRS Site Maintenance Script
#
# $Source: /data/dev/cirs/perl/RCS/site_maint.pl,v $
# $Revision: 1.9 $
# $Date: 2000/09/21 21:45:13 $
# $Author: atchleyb $
# $Locker:  $
# $Log: site_maint.pl,v $
# Revision 1.9  2000/09/21 21:45:13  atchleyb
# updated title
#
# Revision 1.8  2000/08/22 15:53:19  atchleyb
# added check schema line
#
# Revision 1.7  2000/07/24 16:27:07  johnsonc
# Inserted GIF file for display.
#
# Revision 1.6  2000/07/12 21:16:11  munroeb
# finished mods to html formatting.
#
# Revision 1.5  2000/07/11 16:42:46  munroeb
# finished modifying html formatting
#
# Revision 1.4  2000/07/06 23:50:23  munroeb
# finished making mods to html and javascripts.
#
# Revision 1.3  2000/07/05 23:13:34  munroeb
# made minor changes to html and javascripts
#
# Revision 1.2  2000/05/18 23:16:57  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/12 00:03:44  zepedaj
# Initial revision
#
#

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

$cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

# print content type header
print $cmscgi->header('text/html');

$pagetitle = $cmscgi->param('pagetitle');
$cgiaction = $cmscgi->param('action');
$username = $cmscgi->param('loginusername');
$usersid = $cmscgi->param('loginusersid');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
$submitonly = 0;
$updatetable = $cmscgi->param('updatetable');

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "") ||
    (!defined($pagetitle)) || ($pagetitle eq "") || (!defined($updatetable)) || ($updatetable eq ""))
  {
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
<script src="$ONCSJavaScriptPath/oncs-utilities.js"></script>

    <script type="text/javascript">
    <!--

    var dosubmit = true;
    if (parent == self)  // not in frames
      {
      location = '$ONCSCGIDir/login.pl'
      }

    //-->
  </script>
  <script language="JavaScript" type="text/javascript">
  <!--
      doSetTextImageLabel('Site Maintenance');
  //-->
</script>
testlabel1

print "</head>\n\n";
print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

# print the values passed to the cgi script.
#foreach $key ($cmscgi->param)
#  {
#  print "<B>$key</B> -> ";
#  @values = $cmscgi->param($key);
#  print join(",  ",@values), "[--<BR>\n";
#  }

# connect to the oracle database and generate a database handle
$dbh = oncs_connect();

#print "<center><h1>$pagetitle Maintenance</h1></center>\n";
print "<CENTER>\n";
print "<form action=\"$ONCSCGIDir/site_maint.pl\" method=post name=sitemaint>\n";

if ($cgiaction eq "add_site")
  {
  # print the sql which will update this table
  #$siteid = get_maximum_id($dbh, $updatetable) + 1;
  $siteid = get_next_id($dbh, $updatetable);
  $city = $cmscgi->param('city');
  $city =~ s/'/''/g;
  $state = $cmscgi->param('state');
  $name = $cmscgi->param('name');
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
  $siteid = $cmscgi->param('siteid');
  $city = $cmscgi->param('city');
  $city =~ s/'/''/g;
  $state = $cmscgi->param('state');
  $name = $cmscgi->param('name');
  $name =~ s/'/''/g;
#  $isactive = ($cmscgi->param('isactive') eq 'T') ? 'T' : 'F';

  $sqlstring = "UPDATE $SCHEMA.$updatetable SET name='$name', city='$city',
                           state='$state'
                           WHERE siteid = $siteid";

#  print "$sqlstring<br>\n";
  $rc = $dbh->do($sqlstring);
  $cgiaction="query";
  }

if ($cgiaction eq "modify_selected")
  {
  $thissite = $cmscgi->param('selectedsite');
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
  <input type=hidden name=schema value=$SCHEMA>
  <table summary="modify site table" width="750" border=1>
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
  <table summary="add site entry" width="750" border=1>
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

print "</CENTER></body>\n";
print "</html>\n";
