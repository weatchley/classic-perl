#!/usr/local/bin/newperl -w
# - !/usr/bin/perl

# Work Breakdown Structure Maintenance Script
#
# $Source: /data/dev/cirs/perl/RCS/wbs_maint.pl,v $
# $Revision: 1.10 $
# $Date: 2000/09/21 21:40:14 $
# $Author: atchleyb $
# $Locker:  $
# $Log: wbs_maint.pl,v $
# Revision 1.10  2000/09/21 21:40:14  atchleyb
# updated title
#
# Revision 1.9  2000/08/22 15:56:17  atchleyb
# added check schema line
#
# Revision 1.8  2000/07/24 16:22:11  johnsonc
# Inserted GIF file for display.
#
# Revision 1.7  2000/07/12 21:08:51  munroeb
# finished modifying html formatting.
#
# Revision 1.6  2000/07/11 16:37:26  munroeb
# finished modifying html formatting.
#
# Revision 1.5  2000/07/06 23:52:26  munroeb
# finished mods to html and javascripts.
#
# Revision 1.4  2000/07/05 23:14:36  munroeb
# made minor changes to html and javascripts.
#
# Revision 1.3  2000/06/13 16:54:03  zepedaj
# altered length of description field to accept 200 characters.
#
# Revision 1.2  2000/05/19 19:12:52  zepedaj
# Modified to support new WBS table format.
#
# Revision 1.1  2000/04/12 00:04:13  zepedaj
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
use strict;

my $CIRSCgi = new CGI;

$SCHEMA = (defined($CIRSCgi->param("schema"))) ? $CIRSCgi->param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

# print content type header
print $CIRSCgi->header('text/html');

my $pagetitle = $CIRSCgi->param('pagetitle');
my $cgiaction = $CIRSCgi->param('action');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $username = $CIRSCgi->param('loginusername');
my $usersid = $CIRSCgi->param('loginusersid');
my $submitonly = 0;
my $updatetable = $CIRSCgi->param('updatetable');

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "") ||
    (!defined($pagetitle)) || ($pagetitle eq "") || (!defined($updatetable)) || ($updatetable eq ""))
  {
  print <<openloginpage;
  <script type="text/javascript">
  <!--
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
      doSetTextImageLabel('WBS Maintenance');
  //-->
</script>
testlabel1

print "</head>\n\n";
print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

# print the values passed to the cgi script.
#foreach $key ($CIRSCgi->param)
#  {
#  print "<B>$key</B> -> ";
#  @values = $CIRSCgi->param($key);
#  print join(",  ",@values), "[--<BR>\n";
#  }

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

#print "<center><h1>$pagetitle Maintenance</h1></center>\n";
print "<CENTER>\n";
print "<form action=\"$ONCSCGIDir/wbs_maint.pl\" method=post name=wbsmaint>\n";

if ($cgiaction eq "add_wbs")
  {
  # print the sql which will update this table
  #my $changerequestnum = $CIRSCgi->param('changerequestnum');
  my $controlaccountid = $CIRSCgi->param('controlaccountid');
  my $description = $CIRSCgi->param('description');
  $description =~ s/'/''/g;
  my $pointofcontact = $CIRSCgi->param('pointofcontact');
  $pointofcontact =~ s/'/''/g;
  my $isactive = 'T';

  my $sqlstring = "INSERT INTO $SCHEMA.$updatetable (controlaccountid, description, pointofcontact, isactive)
                   VALUES ('$controlaccountid', '$description', '$pointofcontact', '$isactive')";

  my $activity = "Add new WBS";
  $dbh->{AutoCommit} = 0;
  $dbh->{RaiseError} = 1;
  eval
    {
    my $csr = $dbh->prepare($sqlstring);
    $csr->execute;
    $csr->finish;
    };
  if ($@)
    {
    $dbh->rollback;
    my $alertstring = errorMessage($dbh, $username, $usersid, 'workbreakdownstructure', "$controlaccountid", $activity, $@);
    $alertstring =~ s/"/'/g;
    print <<pageerror;
    <script language="JavaScript" type="text/javascript">
      <!--
      alert("$alertstring");
      parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
      //-->
    </script>
pageerror
    }
  else
    {
    print <<pageresults;
    <script language="JavaScript" type="text/javascript">
      <!--
      parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
      //-->
    </script>
pageresults
    }
  $dbh->{AutoCommit} = 1;
  $dbh->{RaiseError} = 0;
  $cgiaction="query";
  }

if ($cgiaction eq "modify_wbs")
  {
  # print the sql which will update this table
  #my $changerequestnum = $CIRSCgi->param('changerequestnum');
  my $controlaccountid = $CIRSCgi->param('controlaccountid');
  my $description = $CIRSCgi->param('description');
  $description =~ s/'/''/g;
  my $pointofcontact = $CIRSCgi->param('pointofcontact');
  $pointofcontact =~ s/'/''/g;
  my $isactive = ($CIRSCgi->param('isactive') eq 'T') ? 'T' : 'F';

  my $sqlstring = "UPDATE $SCHEMA.$updatetable SET description='$description',
                   pointofcontact='$pointofcontact', isactive='$isactive'
                   WHERE controlaccountid = '$controlaccountid'";

  #print "$sqlstring<br>\n";

  my $activity = "Modify WBS";
  $dbh->{AutoCommit} = 0;
  $dbh->{RaiseError} = 1;
  eval
    {
    my $csr = $dbh->prepare($sqlstring);
    $csr->execute;
    $csr->finish;
    };
  if ($@)
    {
    $dbh->rollback;
    my $alertstring = errorMessage($dbh, $username, $usersid, 'workbreakdownstructure', "$controlaccountid", $activity, $@);
    $alertstring =~ s/"/'/g;
    print <<pageerror;
    <script language="JavaScript" type="text/javascript">
      <!--
      alert("$alertstring");
      parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
      //-->
    </script>
pageerror
    }
  else
    {
    print <<pageresults;
    <script language="JavaScript" type="text/javascript">
      <!--
      parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
      //-->
    </script>
pageresults
    }
  $dbh->{AutoCommit} = 1;
  $dbh->{RaiseError} = 0;
  $cgiaction="query";
  }

if ($cgiaction eq "modify_selected")
  {
  my $controlaccountid = $CIRSCgi->param('selectedwbs');
  $submitonly = 1;

  my %wbshash = get_wbs_info($dbh, $controlaccountid);

  # print the sql which will update this table
  my $description      = $wbshash{'description'};
  my $pointofcontact   = $wbshash{'pointofcontact'};
  my $isactive         = $wbshash{'isactive'};
  my $checkedifactive  = ($isactive eq 'T') ? "checked" : "";

  print <<modifyform;
  <input name=cgiaction type=hidden value="modify_wbs">
  <input type=hidden name=schema value=$SCHEMA>
  <table summary="modify wbs table" width="750" border=1>
  <tr>
    <td width=20% align=center>
    <b>WBS Number</b>
    </td>
    <td width=80% align=left>
    <b>$controlaccountid</b>
    <input name=controlaccountid type=hidden value=$controlaccountid>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Description</b>
    </td>
    <td align=left>
    <input name=description type=text maxlength=200 size=80 value="$description">
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Point Of Contact</b>
    </td>
    <td align=left>
    <input name=pointofcontact type=text maxlength=50 size=50 value="$pointofcontact">
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Active WBS</b>
    </td>
    <td align=left>
    <input name=isactive type=checkbox value='T' $checkedifactive>
    </td>
  </tr>
  </table>
modifyform

  print "<input name=action type=hidden value=modify_wbs>\n";
  }

if ($cgiaction eq "add_selected")
  {
  $submitonly = 1;

  print <<addform;
  <input name=cgiaction type=hidden value="add_wbs">
  <table summary="add wbs entry" width="750" border=1>
  <tr>
    <td width=20% align=center>
    <b>Control Account Id</b>
    </td>
    <td width=80% align=left>
    <input name=controlaccountid type=text maxlength=30 size=30>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Description</b>
    </td>
    <td align=left>
    <input name=description type=text maxlength=200 size=80>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Point Of Contact</b>
    </td>
    <td align=left>
    <input name=pointofcontact type=text maxlength=50 size=50>
    </td>
  </tr>
  </table>
addform

  print "<input name=action type=hidden value=add_wbs>\n";
  }

if ($cgiaction eq "query")
  {
  my %wbshash = get_lookup_values($dbh, $updatetable, "controlaccountid", "controlaccountid || ' - ' || description");

  print<<queryformtop;
  <select name=selectedwbs size=10>
queryformtop

  foreach my $key (sort keys %wbshash)
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

print "</CENTER></body>\n";
print "</html>\n";
