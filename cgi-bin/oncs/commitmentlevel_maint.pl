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

my $pagetitle = $cirscgi->param('pagetitle');
my $cgiaction = $cirscgi->param('cgiaction');
my $username = $cirscgi->param('loginusername');
my $usersid = $cirscgi->param('loginusersid');
my $cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $updatetable = $cirscgi->param('updatetable');

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "") ||
    (!defined($pagetitle)) || ($pagetitle eq "") || (!defined($updatetable)) || ($updatetable eq ""))
  {
  print <<openloginpage;
  <script type="text/javascript">
  <!--
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
#foreach my $key ($cirscgi->param)
#  {
#  print "<B>$key</B> -> ";
#  my @values = $cirscgi->param($key);
#  print join(",  ",@values), "<--<BR>\n";
#  }

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

print "<center><h1>$pagetitle Maintenance</h1></center>\n";
print "<form action=\"/cgi-bin/oncs/commitmentlevel_maint.pl\" method=post name=commitlevelmaint>\n";

if ($cgiaction eq "add_commitmentlevel")
  {
  # print the sql which will update this table
  my $commitmentlevelid = get_next_id($dbh, $updatetable);
  my $description = $cirscgi->param('description');
  $description =~ s/'/''/g;
  my $definition = $cirscgi->param('definition');
  $definition =~ s/'/''/g;
  my $isactive = 'T';

  my $sqlstring = "INSERT INTO $SCHEMA.$updatetable VALUES ($commitmentlevelid, '$description',
                             '$isactive', '$definition')";

# print "$sqlstring<br>\n";
  my $rc = $dbh->do($sqlstring);
  $cgiaction="query";
  }

if ($cgiaction eq "modify_commitmentlevel")
  {
  # print the sql which will update this table
  my $commitmentlevelid = $cirscgi->param('commitmentlevelid');
  my $description = $cirscgi->param('description');
  $description =~ s/'/''/g;
  my $definition = $cirscgi->param('definition');
  $definition =~ s/'/''/g;
  my $isactive = ($cirscgi->param('isactive') eq 'T') ? 'T' : 'F';

  my $sqlstring = "UPDATE $SCHEMA.$updatetable SET definition='$definition', description='$description', 
                           isactive='$isactive'
                           WHERE commitmentlevelid = $commitmentlevelid";

#  print "$sqlstring<br>\n";
  my $rc = $dbh->do($sqlstring);
  $cgiaction="query";
  }

if ($cgiaction eq "modify_selected")
  {
  my $thiscommitmentlevel = $cirscgi->param('selectedcommitmentlevel');
  $submitonly = 1;

  my %commitlevelhash = get_commitmentlevel_info($dbh, $thiscommitmentlevel);

  # print the sql which will update this table
  my $description = $commitlevelhash{'description'};
  my $definition = $commitlevelhash{'definition'};
  my $isactive = $commitlevelhash{'isactive'};
  my $checkedifactive  = ($isactive eq 'T') ? "checked" : "";

  print <<modifyform;
  <input name=cgiaction type=hidden value=modify_commitmentlevel>
  <table summary="modify site table" width=100% border=1>
  <tr>
    <td width=20% align=center>
    <b>Level Of Commitment</b>
    </td>
    <td width=80% align=left>
    <b>$description</b>
    <input name=description type=hidden value="$description">
    <input name=commitmentlevelid type=hidden value=$thiscommitmentlevel>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Definition</b>
    </td>
    <td align=left>
    <textarea name=definition cols=80 rows=5 onblur="if(document.commitlevelmaint.definition.value.length > 500){alert('Only 500 characters allowed in the definition');document.commitlevelmaint.definition.focus();}">$definition</textarea>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Active Level Of Commitment</b>
    </td>
    <td align=left>
    <input name=isactive type=checkbox value='T' $checkedifactive>
    </td>
  </tr>
  </table>
modifyform
  }

if ($cgiaction eq "add_selected")
  {
  $submitonly = 1;

  print <<addform;
  <input name=cgiaction type=hidden value=add_commitmentlevel>
  <table summary="add site entry" width=100% border=1>
  <tr>
    <td width=20% align=center>
    <b>Level Of Commitment</b>
    </td>
    <td width=80% align=left>
    <input name=description type=text maxlength=80 size=80>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Definition</b>
    </td>
    <td align=left>
    <textarea name=definition cols=80 rows=5 onblur="if(document.commitlevelmaint.definition.value.length > 500){alert('Only 500 characters allowed in the definition');document.commitlevelmaint.definition.focus();}"></textarea>
    </td>
  </tr>
  </table>
addform
  }

if ($cgiaction eq "query")
  {
  my %commitlevelhash = get_lookup_values($dbh, $updatetable, "commitmentlevelid", "description");

  print<<queryformtop;
  <input name=cgiaction type=hidden value=query>
  <select name=selectedcommitmentlevel size=10>
queryformtop

  foreach my $key (sort keys %commitlevelhash)
    {
    print "<option value=\"$key\">$commitlevelhash{$key}\n";
    }

  print <<queryformbottom;
  </select>
  <br>
queryformbottom
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
  print "<input name=add type=submit value=\"Add New Level of Commitment\" onclick=\"document.commitlevelmaint.cgiaction.value='add_selected'\">\n";
  print "<input name=modify type=submit value=\"Modify Selected Level of Commitment\" onclick=\"dosubmit=true; (document.commitlevelmaint.selectedcommitmentlevel.selectedIndex == -1) ? (alert(\'No Site Selected\') || (dosubmit = false)) : document.commitlevelmaint.cgiaction.value='modify_selected'; return(dosubmit)\">\n";
  }
else
  {
  print "<input name=submit_changes type=submit value=\"Submit Changes\">\n";
  }
print "</form>\n";
print "</body>\n";
print "</html>\n";
