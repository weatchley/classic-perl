#!/usr/local/bin/newperl
# - !/usr/bin/perl

#require "oncs_header.pl";
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);
use UI_Widgets qw(:Functions);
#require "oncs_lib.pl";

use strict;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

my $testout = new CGI;

# print content type header
print $testout->header('text/html');

my $pagetitle = "Issue/Condition Entry";
my $cgiaction = $testout->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $testout->param('loginusersid');
my $username = $testout->param('loginusername');
my $updatetable = "issue";
my $activity;

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq ""))
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
print "<meta name=pragma content=no-cache>\n";
print "<meta name=expires content=0>\n";
print "<meta http-equiv=expires content=0>\n";
print "<meta http-equiv=pragma content=no-cache>\n";
#print "<meta http-equiv=\"expires\" content=\"Fri, 12 May 1996 14:35:02 EST\">\n";
print "<title>$pagetitle</title>\n";

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

    function validatedata()
      {
      var msg = "";
      var tmpmsg = "";
      var returnvalue = true;
      var validateform = document.issueentry;

      msg += (validateform.issuetext.value=="") ? "You must enter the issue text.\\n" : "";
      msg += ((tmpmsg = validate_date(validateform.dateoccurred_year.value, validateform.dateoccurred_month.value, validateform.dateoccurred_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : tmpmsg + "\\n";
      //msg += (validateform.primarydiscipline.value=='') ? "You must select the primary discipline for this issue.\\n" : "";
      //msg += (validateform.secondarydiscipline.value=='') ? "You must select the secondary discipline for this issue.\\n" : "";
      msg += (validateform.category.value=='') ? "You must select the category for this issue.\\n" : "";
      if (msg != "")
        {
        alert(msg);
        returnvalue = false;
        }
      return (returnvalue);
      }

    //-->
  </script>
testlabel1

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

# process the input issue
if ($cgiaction eq "submit_issue")
  {
  no strict 'refs';
  # print the sql which will update this table
  # print the values passed to the cgi script.
#  foreach $key ($testout->param)
#    {
#    print "<B>$key</B> -> ";
#    @values = $testout->param($key);
#    print join(",  ",@values), "[--<BR>\n";
#    }

#######

  my $nextissueid;
  $activity = "Get Next Issue Sequence";
  $dbh->{RaiseError} = 1;
  $dbh->{AutoCommit} = 0;
  eval
    {
    $nextissueid = get_next_id($dbh, $updatetable);
    };
  if ($@)
    {
    my $alertstring = errorMessage($dbh, $username, $usersid, 'issueid_seq', "", $activity, $@);
    print <<issueseqerror;
    <script language="JavaScript" type="text/javascript">
      <!--
      alert("$alertstring");
      parent.control.location="/oncs/blank.htm";
      //-->
    </script>
issueseqerror
    $dbh->commit;
    &oncs_disconnect($dbh);
    exit 1;
    }
  $dbh->{RaiseError} = 0;
  $dbh->{AutoCommit} = 1;
  my $issuetext = $testout->param('issuetext');
  my $dateoccurred = $testout->param('dateoccurred');
  my $entered_date = get_formatted_date('DD-MON-YYYY');
  my $page = $testout->param('page');
#  my $primarydiscipline = $testout->param('primarydiscipline');
#  my $secondarydiscipline = $testout->param('secondarydiscipline');
  my $categoryid = $testout->param('category');
  $categoryid = ($categoryid) ? $categoryid : 'NULL';
  my $enteredby = $usersid;
  my $suggestedresolution = $testout->param('suggestedresolution');
  my $suggressqlstring = ($suggestedresolution) ? ":suggresclob" : "NULL"; 

#  my $sqlstring = "INSERT INTO $SCHEMA.$updatetable VALUES ($nextissueid, :textclob,
#                 TO_DATE('$entered_date', 'DD-MON-YYYY'), NULL, NULL,
#                 NULL, NULL, '$page', $enteredby, $primarydiscipline,
#                 $secondarydiscipline, $categoryid, 
#                 TO_DATE('$dateoccurred', 'MM/DD/YYYY'), $suggressqlstring)";

  my $sqlstring = "INSERT INTO $SCHEMA.$updatetable VALUES ($nextissueid, :textclob,
                 TO_DATE('$entered_date', 'DD-MON-YYYY'), NULL, NULL,
                 NULL, NULL, '$page', $enteredby, NULL,
                 NULL, $categoryid, 
                 TO_DATE('$dateoccurred', 'MM/DD/YYYY'), $suggressqlstring)";

  $dbh->{AutoCommit} = 0;
  $dbh->{RaiseError} = 1;
  eval
    {
    $activity = "Insert Historical Issue Information: $nextissueid";
    my $csr = $dbh->prepare($sqlstring);
    $csr->bind_param(":textclob", $issuetext, {ora_type => ORA_CLOB, ora_field => 'text' });
    if ($suggestedresolution)
      {
      $csr->bind_param(":suggresclob", $suggestedresolution, {ora_type => ORA_CLOB, ora_field => 'suggestedresolution' });
      }
    $csr->execute;

    #add keywords to record(s)
    my $keywordid;
    foreach $keywordid ($testout->param('keywords'))
      {
      if ($keywordid ne '')
        {
        $activity = "Insert keyword: $keywordid for issue: $nextissueid.";
        my $keywordsqlstring = "INSERT INTO $SCHEMA.issuekeyword VALUES($nextissueid, $keywordid)";
        $csr = $dbh->prepare($keywordsqlstring);
        $csr->execute;
        }
      }

    $csr->finish;
    };
  if ($@)
    {
    $dbh->rollback;
    my $alertstring = errorMessage($dbh, $username, $usersid, 'issue', "$nextissueid", $activity, $@);
    $alertstring =~ s/"/'/g;
    print <<pageerror;
    <script language="JavaScript" type="text/javascript">
      <!--
      alert("$alertstring");
      parent.control.location="/oncs/blank.htm";
      //-->
    </script>
pageerror
    }
  else
    {
    &log_history($dbh, "Issue Added", 'F', $usersid, 'issue', $nextissueid, "Issue $nextissueid was added by user $username.");
    print <<pageresults;
    <script language="JavaScript" type="text/javascript">
      <!--
      parent.workspace.location="/cgi-bin/oncs/oncs_home.pl?loginusersid=$usersid&loginusername=$username";
      parent.control.location="/oncs/blank.htm";
      //-->
    </script>
pageresults
    }
  $dbh->commit;
  $dbh->{AutoCommit} = 1;
  $dbh->{RaiseError} = 0;
  &oncs_disconnect($dbh);
  print "</head><body></body></html>\n";
  exit 1;
  }

print "</head>\n\n";
print "<body>\n";

print "<center><h1>$pagetitle</h1></center>\n";

print "<form target=control action=\"/cgi-bin/oncs/newissue.pl\" enctype=\"multipart/form-data\" method=post name=issueentry onsubmit=\"return(validatedata())\">\n";

#my %disciplinehash = get_lookup_values($dbh, 'discipline', 'description', 'disciplineid', "isactive='T'");
my %categoryhash = get_lookup_values($dbh, 'category', 'description', 'categoryid', "isactive='T'");
my %sourcedochash = get_lookup_values($dbh, 'sourcedoc', "accessionnum || ' - ' || title || ' - ' || to_char(documentdate, 'MM/DD/YYYY') || ';' || sourcedocid", 'sourcedocid');
my %keywordhash = get_lookup_values($dbh, 'keyword', 'description', 'keywordid', "isactive='T'");
my $key = '';

#display the old issue form
print <<issueform1;
<input name=cgiaction type=hidden value="submit_issue">
<table summary="enter issue table" width=100% border=1>
<tr>
  <th align=center colspan=2><b>Issue Information</b>
</tr>
<tr>
  <td width=20% align=center>
  <b>Issue Text</b>
  </td>
  <td width=80% align=left>
  <textarea name=issuetext cols=65 rows=5></textarea>
  <br>
  Please be as clear and complete as possible.  Include events leading up to occurrence, names of people involved and witnesses, actions taken to correct condition (if any) and any observed results of condition. 
  <input name=usersid type=hidden value=$usersid>
  <input name=username type=hidden value=$username>
  </td>
</tr>
<tr>
  <td align=center>
  <b>Date of Occurence</b>
  </td>
  <td align=left>
issueform1
print build_date_selection('dateoccurred', 'issueentry');
print <<issueform2;
  <br>(Use date of letter or date entered if issue does not have a specific date of occurence)
  </td>
</tr>
<tr>
  <td align=center>
  <b>Source Document Page Number</b>
  </td>
  <td align=left>
  <input name=page type=text maxlength=5 size=5>
  <br>(Leave blank if Not Available)
  </td>
</tr>
<!-- <tr>
  <td align=center>
  <b>Primary Discipline</b>
  </td>
  <td align=left> -->
issueform2
#    print "<select name=primarydiscipline>\n";
#    print "<option value='' selected>Select a Primary Discipline\n";
#    print "<option value=NULL>Not Available\n";
#    foreach $key (sort keys %disciplinehash)
#      {
#      print "<option value=\"$disciplinehash{$key}\">$key\n";
#      }
#    print"</select>\n";
print <<issueform3;
<!--   </td>
</tr>
<tr>
  <td align=center>
  <b>Secondary Discipline</b>
  </td>
  <td align=left> -->
issueform3
#    print "<select name=secondarydiscipline>\n";
#    print "<option value='' selected>Select a Secondary Discipline\n";
#    print "<option value=NULL>Not Available\n";
#    foreach $key (sort keys %disciplinehash)
#      {
#      print "<option value=\"$disciplinehash{$key}\">$key\n";
#      }
#    print"</select>\n";
print <<issueform4;
<!--   </td>
</tr> -->
<tr>
  <td align=center>
  <b>Source Category</b>
  </td>
  <td align=left>
issueform4
    print "<select name=category>\n";
    print "<option value='' selected>Select A Category\n";
    print "<option value=NULL>Not Available\n";
    foreach $key (sort keys %categoryhash)
      {
      print "<option value=\"$categoryhash{$key}\">$key\n";
      }
    print"</select>\n";
print <<issueform5;
  </td>
</tr>
<tr>
  <td align=center>
  <b>Keywords</b>
  </td>
  <td>
  <table border=0 summary="Keyword Selection">
    <tr align=Center>
      <td>
      <b>Keyword List</b>
      </td>
      <td>&nbsp;
      </td>
      <td>
      <b>Keywords Selected</b>
      </td>
    </tr>
    <tr>
      <td>
      <select name=allkeywordlist size=5 multiple ondblclick="process_multiple_dual_select_option(document.issueentry.allkeywordlist, document.issueentry.keywords, 'move')">
issueform5
foreach $key (sort keys %keywordhash)
  {
  print "        <option value=\"$keywordhash{$key}\">$key\n";
  }
print <<issueform6;
      <option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
      </select>
      </td>
      <td>
      <input name=keywordleftarrow title="Click to remove the selected keyword(s)" value="<--" type=button onclick="process_multiple_dual_select_option(document.issueentry.keywords, document.issueentry.allkeywordlist, 'move')">
      <br>
      <input name=keywordrightarrow title="Click to select the keyword(s)" value="-->" type=button onclick="process_multiple_dual_select_option(document.issueentry.allkeywordlist, document.issueentry.keywords, 'move')">
      </td>
      <td>
      <select name=keywords size=5 multiple ondblclick="process_multiple_dual_select_option(document.issueentry.keywords, document.issueentry.allkeywordlist, 'move')">
      <option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
      </select>
      </td>
    </tr>
  </table>
  (optional, do not select any if not available)
  </td>
</tr>
<tr>
  <td align=center>
  <b>Suggestions for Resolution</b>
  </td>
  <td width=80% align=left>
  <textarea name=suggestedresolution cols=65 rows=5></textarea>
  <br>
  Please enter any suggestions you have for resolving this condition.  Be as clear and complete as possible, include costs, time estimates, etc. wherever relevant.
  <br>
  (leave blank if you don't have a suggestion) 
  </td>
</tr>
</table>
issueform6

print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=loginusername type=hidden value=$username>\n";
print "<input name=loginusersid type=hidden value=$usersid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";

#disconnect from the database
&oncs_disconnect($dbh);

# print html footers.
print "<br>\n";
print "<input name=submit type=submit value=\"Submit Changes\" onclick=\"selectemall(document.issueentry.keywords)\">\n";
print "</form>\n";
# menu to return to the maintenance menu and the main screen
#print "<ul title=\"Link Menu\"><b>Link Menu</b>\n<li><a href=\"/dcmm/prototype/maintenance.htm\">Maintenance Screen</a></li>\n";
#print "<li><a href=\"/dcmm/prototype/home.htm\">Main Menu</a></li>\n";
#print "</ul><br><br>\n";

print <<endofpage;
</body>
</html>
<script language="JavaScript" type="text/javascript"><!--
  //disablenewsourcedoc();
//-->
</script>
endofpage
