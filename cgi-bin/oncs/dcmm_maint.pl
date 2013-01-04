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
$pagetitleplural = ((substr($pagetitle, length($pagetitle) - 1, 1) =~ /y/i) ? (substr($pagetitle, 0, length($pagetitle) - 1)) . "ies" : ((substr($pagetitle, length($pagetitle) - 1, 1) =~ /s/i) ? $pagetitle . "es" : $pagetitle . "s"));
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
<script src="$ONCSJavaScriptPath/oncs-utilities.js"></script>

    <script type="text/javascript">
    <!--

    if (parent == self)  // not in frames
      {
      location = '/cgi-bin/oncs/oncs_user_login.pl'
      }

    function highlightdata()
      {
      selectemall(document.maintenance.newdata);
      }

    function validatedata(selectobj, activeobj, inactiveobj)
      {
      var msg = "";
      var tempval = "";
      var temptext = "";

      for(var i = 0; i < ((selectobj.length) - 1); i++)
        {
        tempval = selectobj.options[i].value;
        for (var j = 0; j < ((activeobj.length) - 1); j++)
          {
          temptext = activeobj.options[j].text;
          if (tempval.toUpperCase() == temptext.toUpperCase())
            {
            msg = msg + tempval + " is a duplicate entry.\\n";
            }
          }
        for (var j = 0; j < ((inactiveobj.length) - 1); j++)
          {
          temptext = inactiveobj.options[j].text;
          if (tempval.toUpperCase() == temptext.toUpperCase())
            {
            msg = msg + tempval + " is a duplicate entry.\\n";
            }
          }
        }

      if (msg != "")
        {
        alert(msg);
        return false;
        }
      return true;
      }

    //-->
  </script>
testlabel1

print "</head>\n\n";
print "<body>\n";   #onload=\"document.maintenance.newtype.focus()\">\n";

# print the values passed to the cgi script.
#foreach $key ($testout->param)
#  {
#  print "<B>$key</B> -> ";
#  @values = $testout->param($key);
#  print join(",  ",@values), "[--<BR>\n";
#  }

# connect to the oracle database and generate a database handle
$dbh = oncs_connect();

if ($testout->param('action') ne "query")
  {
  # print the sql which will update this table
  #$nextvalue = $testout->param('nextvalue');
  $counter = 0;
  foreach $value ($testout->param('newdata'))
    {
    $valuestring = $value;
    $valuestring =~ s/'/''/g;
    $counter++;
#   print "insert into $SCHEMA.$updatetable values ($nextvalue, '$valuestring', 'T');<BR>";
    $nextvalue = get_next_id($dbh, $updatetable);
    $sqlstrings[$counter] = "INSERT INTO $SCHEMA.$updatetable VALUES ($nextvalue, '$valuestring', 'T')";
#   print "$sqlstrings[$counter]<br>\n";
    }

  #update the table
  for (; $counter > 0; $counter--)
    {
#   print "$sqlstrings[$counter]<br>\n";
    $rc = $dbh->do($sqlstrings[$counter]);
    }

  # move active/inactive keywords.
  $history = $testout->param('history');
  $history =~ s/\s+//;
  #print (($history eq " " ? "trueblank" : "falseblank") . "<br>\n");
  #print (($history eq "  " ? "truetwoblank" : "falsetwoblank") . "<br>\n");
  #print (($history eq "" ? "Truenull" : "Falsenull") . "<br>\n");
  #print length($history) . "<br>\n";
  #print ord($history) . "<br>\n";
  while ($histitem = substr($history, 0, index($history, ';')))
    {
    #die "this is a test<br>\n";
    $history = substr($history, (index($history, ';') + 1));
    #print "$history<br>\n$histitem<br>\n";
    if ($histitem =~ /inactive/i)
      {
       #print "UPDATE $SCHEMA.$updatetable SET isactive = 'F' WHERE " . $updatetable . "id = " . substr($histitem, 0, index($histitem, '-->')) . "<br>\n";
      $rc = $dbh->do("UPDATE $SCHEMA.$updatetable SET isactive = 'F' WHERE " . $updatetable . "id = " . substr($histitem, 0, index($histitem, '-->')));
      }
    else
      {
       #print "UPDATE $SCHEMA.$updatetable SET isactive = 'T' WHERE " . $updatetable . "id = " . substr($histitem, 0, index($histitem, '-->')) . "<br>\n";
      $rc = $dbh->do("UPDATE $SCHEMA.$updatetable SET isactive = 'T' WHERE " . $updatetable . "id = " . substr($histitem, 0, index($histitem, '-->')));
      }
    }

  #$csr = $dbh->prepare($statement);
  #$csr->execute;

  #commit the changes
  #$dbh->rollback;
  #$dbh->commit;

  #free up the 'cursor';
  #$csr->finish;
  }

print "<center><h2>$pagetitle Maintenance</h2></center>\n\n";

print "<form action=\"/cgi-bin/oncs/dcmm_maint.pl\" method=Post name=maintenance onsubmit=\"highlightdata(); return validatedata(document.maintenance.newdata, document.maintenance.activedata, document.maintenance.inactivedata)\">\n";
print "<table border=0 summary=\"Current Data\">\n";
print "  <tr align=Center>\n";
print "    <td>\n";
print "      <b>Active $pagetitleplural</b>\n";
print "    </td><td></td>\n";
print "    <td>\n";
print "      <b>Inactive $pagetitleplural</b>\n";
print "    </td>\n";
print "  </tr>\n";
print "  <tr>\n";
print "    <td>\n";
print "      <select name=activedata size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.maintenance.activedata, document.maintenance.inactivedata, 'movehist', document.maintenance.history)\">\n";
#onclick=\"selectedIndex=-1\" onfocus=\"blur()\"
$nextvalue = 0;
#generate query of issue types
#$sqlquery = "SELECT " . $updatetable . "id, description FROM $SCHEMA.$updatetable WHERE isactive='T' ORDER BY " . $updatetable . "id";
#print "$sqlquery<br>\n";
#generate a 'cursor'
#$csr = $dbh->prepare($sqlquery);
#$csr->execute;

%picklisthash = get_lookup_values($dbh, $updatetable, "description", $updatetable . "id", "isactive='T'");

  foreach $key (sort keys %picklisthash)
    {
    print "      <option value=\"$picklisthash{$key}\">$key\n";
    }

##get all rows from the select
#while (@values = $csr->fetchrow_array)
#        {
#        ($typeid, $description) = @values;
#        if ($typeid > $nextvalue)
#           {
#           $nextvalue = $typeid;
#           }
#        print "<option value=\"$typeid\">$description\n";
#        }

print "      <option value=\"\">&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp\n";

#discard the cursor
#$csr->finish;

print "      </select>\n";
print "    </td>\n";
print "    <td>\n";
print "      <input name=\"leftarrow\" title=\"click to make the selected item(s) active\" value=\"<--\" type=\"button\" onclick=\"process_multiple_dual_select_option(document.maintenance.inactivedata, document.maintenance.activedata, 'movehist', document.maintenance.history)\">\n";
print "      <br>\n";
print "      <input name=\"rightarrow\" title=\"click to make the selected item(s) inactive\" value=\"-->\" type=\"button\" onclick=\"process_multiple_dual_select_option(document.maintenance.activedata, document.maintenance.inactivedata, 'movehist', document.maintenance.history)\">\n";
print "    </td>\n";
print "    <td>\n";
print "      <select name=\"inactivedata\" size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.maintenance.inactivedata, document.maintenance.activedata, 'movehist', document.maintenance.history)\">\n";
#onfocus=\"blur()\" onclick=\"selectedIndex=-1\"
#generate query of issue types
#$sqlquery = "SELECT " . $updatetable . "id, description FROM $SCHEMA.$updatetable WHERE isactive='F' ORDER BY " . $updatetable . "id";
#print "$sqlquery<br>\n";
#generate a 'cursor'
#$csr = $dbh->prepare($sqlquery);
#$csr->execute;

%picklisthash = get_lookup_values($dbh, $updatetable, "description", $updatetable . "id", "isactive='F'");

  foreach $key (sort keys %picklisthash)
    {
    print "      <option value=\"$picklisthash{$key}\">$key\n";
    }

#get all rows from the select
#while (@values = $csr->fetchrow_array)
#        {
#        ($typeid, $description) = @values;
#        if ($typeid > $nextvalue)
#           {
#           $nextvalue = $typeid;
#           }
#        print "<option value=\"$typeid\">$description\n";
#        }

print "      <option value=\"\">&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp\n";

#discard the cursor
#$csr->finish;

print "      </select>\n";
print "    </td>\n";
print "  </tr>\n";
print "  <tr>\n";
print "    <td align=center>\n";

# the history input holds changes from active to inactive status for keywords.
print "      <input type=hidden name=history>\n";
#print "<option value=\"\">&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp\n";
#print "</select>\n";

$nextvalue = get_maximum_id($dbh, $updatetable) + 1;

print "      <input name=nextvalue type=hidden value=$nextvalue>\n";
print "      <input name=updatetable type=hidden value=$updatetable>\n";
print "      <input name=loginusername type=hidden value=$username>\n";
print "      <input name=loginusersid type=hidden value=$usersid>\n";
print "      <input name=pagetitle type=hidden value=\"$pagetitle\">\n";

#disconnect from the database
&oncs_disconnect($dbh);


# print html footers.
print "<b>New $pagetitleplural</b>\n";
print <<testlabel;
    </td>
    <td>
    </td>
    <td>
    </td>
  </tr>
  <tr>
    <td>
      <select name=newdata size=5 multiple>
      <!-- this is used to force the size of the option box -->
      <option value="">&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
      </select>
    </td>
    <td>
    </td>
    <td valign=bottom>
      <input title="Remove item from the list" value="Remove" type=button onclick="remove_option(document.maintenance.newdata)" name="Remove">
    </td>
  </tr>
</table>
<b>Select an item and click "Remove" to remove from the list</b>
<br>
<b>Enter a new item here and click \"Add\"</b><br>
<input name=action type=hidden value=update>
<input name=newtype type=text maxlength=30 size=30>
<br>
<input title="Add new item to the list" value=Add type=button onclick="addvalue_to_selectlist(document.maintenance.newtype,document.maintenance.newdata, 'move'); document.maintenance.newtype.focus();" name=Add>
&nbsp &nbsp
<input type=submit title="Click here to submit your changes" value=Submit onclick=\"selectemall(document.maintenance.newdata)\">
</form>
testlabel

# menu to return to the maintenance menu and the main screen
#print "<ul title=\"Link Menu\"><b>Link Menu</b>\n<li><a href=\"/dcmm/prototype/maintenance.htm\">Maintenance Screen</a></li>\n";
#print "<li><a href=\"/dcmm/prototype/home.htm\">Main Menu</a></li>\n";
#print "</ul><br><br>\n";

print "</body>\n";
print "</html>\n";
