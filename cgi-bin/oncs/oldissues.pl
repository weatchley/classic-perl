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

my $pagetitle = "Old Issue";
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

    function disablenewsourcedoc()
      {
      document.issueentry.accessionnum.disabled = true;
      document.issueentry.accessionnum.value = "";
      document.issueentry.signer.disabled = true;
      document.issueentry.signer.value = "";
      document.issueentry.title.disabled = true;
      document.issueentry.title.value = "";
      document.issueentry.emailaddress.disabled = true;
      document.issueentry.emailaddress.value = "";
      document.issueentry.areacode.disabled = true;
      document.issueentry.areacode.value = "";
      document.issueentry.phonenumber.disabled = true;
      document.issueentry.phonenumber.value = "";
      document.issueentry.documentdate_month.disabled = true;
      //document.issueentry.documentdate_month.value = "";
      document.issueentry.documentdate_day.disabled = true;
      //document.issueentry.documentdate_day.value = "";
      document.issueentry.documentdate_year.disabled = true;
      //document.issueentry.documentdate_year.value = "";
      document.issueentry.organizationid.disabled = true;
      document.issueentry.organizationid.value = "";
      }

    function enablenewsourcedoc()
      {
      document.issueentry.accessionnum.disabled = false;
      document.issueentry.signer.disabled = false;
      document.issueentry.title.disabled = false;
      document.issueentry.emailaddress.disabled = false;
      document.issueentry.areacode.disabled = false;
      document.issueentry.phonenumber.disabled = false;
      document.issueentry.documentdate_month.disabled = false;
      document.issueentry.documentdate_day.disabled = false;
      document.issueentry.documentdate_year.disabled = false;
      document.issueentry.organizationid.disabled = false;
      }

    function checknewsource (sourcedocselection)
      {
      if (sourcedocselection.value!="NEW")
        {
        disablenewsourcedoc();
        }
      else
        {
        enablenewsourcedoc();
        }
      }

    function validatedata()
      {
      var msg = "";
      var tmpmsg = "";
      var returnvalue = true;
      var validateform = document.issueentry;

      if (! validateform.chkissuetext.checked)
        msg += (validateform.issuetext.value=="") ? "You must enter the issue text.\\n" : "";
      msg += ((tmpmsg = validate_date(validateform.dateoccurred_year.value, validateform.dateoccurred_month.value, validateform.dateoccurred_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : tmpmsg + "\\n";
      if (validateform.sourcedocid.value != "NULL")
        {
        msg += (validateform.image.value=="") ? "You must select the issue image file.\\n" : "";
        msg += (validateform.page.value=="") ? "You must enter the page number the issue starts on.\\n" : "";
        }
      //msg += (validateform.primarydiscipline.value=='') ? "You must select the primary discipline for this issue.\\n" : "";
      //msg += (validateform.secondarydiscipline.value=='') ? "You must select the secondary discipline for this issue.\\n" : "";
      msg += (validateform.category.value=='') ? "You must select the category for this issue.\\n" : "";
      msg += (validateform.sourcedocid.value=='') ? "You must select the source document or enter data for it.\\n" : "";
      if (validateform.sourcedocid.value=="NEW")
        {
        msg += ((tmpmsg = validate_accession_number(validateform.accessionnum.value)) == "") ? "" : tmpmsg + "\\n";
        msg += (validateform.title.value=="") ? "You must enter the title of the source document.\\n" : "";
        msg += (validateform.signer.value=="") ? "You must enter the signer of the source document.\\n" : "";
        msg += ((validateform.areacode.value != "") && (validateform.areacode.value.length < 3)) ? "You have enterd an invalid area code.\\n" : "";
        msg += ((validateform.phonenumber.value != "") && (validateform.phonenumber.value.length < 7)) ? "You have enterd an invalid phone number.\\n" : "";
        msg += ((tmpmsg = validate_date(validateform.documentdate_year.value, validateform.documentdate_month.value, validateform.documentdate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : tmpmsg + "\\n";
        msg += (validateform.organizationid.value=='') ? "You must select the organization the source document came from.\\n" : "";
        }
      if (msg != "")
        {
        alert(msg);
        returnvalue = false;
        }
      return (returnvalue);
      }

    function process_checkmark(chkbox, startblank)
      {
      var argcounter = 0;

      if (chkbox.checked)
        {
        for (argcounter = 2; argcounter < arguments.length; argcounter++)
          {
          //alert (arguments[argcounter].name);
          arguments[argcounter].disabled = true;
          if ((argcounter + 1) >= startblank)
            {
            arguments[argcounter].value = "";
            }
          }
        }
      else
        {
        for (argcounter = 2; argcounter < arguments.length; argcounter++)
          {
          //alert (arguments[argcounter].name);
          arguments[argcounter].disabled = false;
          var controlname = arguments[argcounter].name;
          if (controlname.substr(controlname.length - 4) == "date")
            {
            arguments[argcounter].value = Melt_Date_Parts_Together(arguments[argcounter - 3].options[arguments[argcounter - 3].selectedIndex].value, arguments[argcounter - 2].options[arguments[argcounter - 2].selectedIndex].value, arguments[argcounter - 1].value);
            }
          }
        }
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
#  $issuetext =~ s/'/''/g;
  $issuetext = $issuetext ? $issuetext : "Historical Data not Available.";
  my $dateoccurred = $testout->param('dateoccurred');
  my $entered_date = get_formatted_date('DD-MON-YYYY');
  my $filename = $testout->param('image');
  my $imagetype = '';
  my $imageextension = '';
  my $fnameinsertstring = '';
  my $filesize = 0;
  my $filedata = '';
  if ($filename)
    {
    my $bytesread = 0;
    my $buffer = '';
    # read a 16 K chunk and append the data to the variable $filedata
    while ($bytesread = read($filename, $buffer, 16384))
      {
      $filedata .= $buffer;
      $filesize += $bytesread;
      }
    $imagetype = $testout->uploadInfo($filename)->{'Content-Type'};
    $imagetype =~ s/'/''/g;
    $imagetype = "'$imagetype'";
    $filename =~ /.*\\.*(\..*)/;
    $imageextension = "'" . $1 . "'";
    $fnameinsertstring = ":imgblob";
    }
  else
    {
    $imagetype = 'NULL';
    $imageextension = 'NULL';
    $fnameinsertstring = 'NULL';
    }
  my $page = $testout->param('page');
#  my $primarydiscipline = $testout->param('primarydiscipline');
#  my $secondarydiscipline = $testout->param('secondarydiscipline');
  my $categoryid = 0;
  $categoryid = $testout->param('category');
  $categoryid = ($categoryid) ? $categoryid : 'NULL';
  my $sourcedocid = 0;
  $sourcedocid = $testout->param('sourcedocid');
  my $processsourcedoc = 0;
  my $sourcesqlstring;
  if ($sourcedocid eq 'NEW')   # we've got to post the new source document information first
    {
    $processsourcedoc = 1;
    $activity = "Get Next Sourcedoc Sequence";
    $dbh->{RaiseError} = 1;
    $dbh->{AutoCommit} = 0;
    eval
      {
      $sourcedocid = get_next_id($dbh, 'sourcedoc');
      };
    if ($@)
      {
      my $alertstring = errorMessage($dbh, $username, $usersid, 'sourcedocid_seq', "", $activity, $@);
      print <<sourcedocseqerror;
      <script language="JavaScript" type="text/javascript">
        <!--
        alert("$alertstring");
        parent.control.location="/oncs/blank.htm";
        //-->
      </script>
sourcedocseqerror
      $dbh->commit;
      &oncs_disconnect($dbh);
      exit 1;
      }
    $dbh->{RaiseError} = 0;
    $dbh->{AutoCommit} = 1;
    my $accessionnum = $testout->param('accessionnum');
    my $title = $testout->param('title');
    $title =~ s/'/''/g;
    my $signer = $testout->param('signer');
    $signer =~ s/'/''/g;
    my $email = $testout->param('emailaddress');
    $email =~ s/'/''/g;
    $email = ($email) ? "'$email'" : 'NULL';
    my $areacode = $testout->param('areacode');
    $areacode = ($areacode) ? "'$areacode'" : 'NULL';
    my $phonenumber = $testout->param('phonenumber');
    $phonenumber = ($phonenumber) ? "'$phonenumber'" : 'NULL';
    #my $documentdateyear = $testout->param('documentdate_year');
    #my $documentdatemonth = $testout->param('documentdate_month');
    #my $documentdateday = $testout->param('documentdate_day');
    my $documentdate = $testout->param('documentdate');
    my $organizationid = $testout->param('organizationid');

    $sourcesqlstring = "INSERT INTO $SCHEMA.sourcedoc VALUES ($sourcedocid, '$accessionnum', '$title', '$signer',
                        $email, $areacode, $phonenumber, TO_DATE('$documentdate', 'MM/DD/YYYY'),
                        $organizationid, $categoryid)";
    }
  my $issuetype = 0;
  $issuetype = 1;
  my $enteredby = '';
  $enteredby = $usersid;

#  my $sqlstring = "INSERT INTO $SCHEMA.$updatetable VALUES ($nextissueid, :textclob,
#                 TO_DATE('$entered_date', 'DD-MON-YYYY'), $sourcedocid, $fnameinsertstring,
#                 $imagetype, $imageextension, '$page', $enteredby, $primarydiscipline,
#                 $secondarydiscipline, $categoryid,
#                 TO_DATE('$dateoccurred', 'MM/DD/YYYY'), NULL)";

  my $sqlstring = "INSERT INTO $SCHEMA.$updatetable (issueid, text, entereddate, sourcedocid,
                 image, imagecontenttype, imageextension, page, issuetypeid, enteredby,
                 primarydiscipline, secondarydiscipline, categoryid, dateoccurred, suggestedresolution)
                 VALUES ($nextissueid, :textclob,
                 TO_DATE('$entered_date', 'DD-MON-YYYY'), $sourcedocid, $fnameinsertstring,
                 $imagetype, $imageextension, '$page', 1, $enteredby, NULL,
                 NULL, $categoryid,
                 TO_DATE('$dateoccurred', 'MM/DD/YYYY'), NULL)";

  my $issueclassifysqlstring = "INSERT INTO $SCHEMA.issueclassify
                                VALUES ($issuetype, $nextissueid)";

  $dbh->{AutoCommit} = 0;
  $dbh->{RaiseError} = 1;
  eval
    {
    if ($processsourcedoc)
      {
      $activity = "Insert Historical Source Document Information: $sourcedocid";
      my $sourcecsr = $dbh->prepare($sourcesqlstring);
      $sourcecsr->execute;
      $sourcecsr->finish;
      }

    $activity = "Insert Historical Issue Information: $nextissueid";
    my $csr = $dbh->prepare($sqlstring);
    $csr->bind_param(":textclob", $issuetext, {ora_type => ORA_CLOB, ora_field => 'text' });
    if ($filename)
      {
      $csr->bind_param(":imgblob", $filedata, {ora_type => ORA_BLOB, ora_field => 'image' });
      }
    $csr->execute;

    $activity = "Insert Historical Issue Classification: $nextissueid, $issuetype";
    $csr = $dbh->prepare($issueclassifysqlstring);
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
    my $alertstring = errorMessage($dbh, $username, $usersid, 'issue/sourcedoc', "$nextissueid . $sourcedocid", $activity, $@);
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
    &log_history($dbh, "Historical Issue Added", 'F', $usersid, 'issue', $nextissueid, "Issue $nextissueid was added by user $username.");
    print <<pageresults;
    <script language="JavaScript" type="text/javascript">
      <!--
      parent.workspace.location="/cgi-bin/oncs/commitment_module_main.pl?loginusersid=$usersid&loginusername=$username";
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

print "<form target=control action=\"/cgi-bin/oncs/oldissues.pl\" enctype=\"multipart/form-data\" method=post name=issueentry onsubmit=\"return(validatedata())\">\n";

#my %disciplinehash = get_lookup_values($dbh, 'discipline', 'description', 'disciplineid', "isactive='T'");
my %categoryhash = get_lookup_values($dbh, 'category', 'description', 'categoryid', "isactive='T'");
my %sourcedochash = get_lookup_values($dbh, 'sourcedoc', "accessionnum || ' - ' || title || ' - ' || to_char(documentdate, 'MM/DD/YYYY') || ';' || sourcedocid", 'sourcedocid');
my %keywordhash = get_lookup_values($dbh, 'keyword', 'description', 'keywordid', "isactive='T'");
my $key = '';

#display the old issue form
print <<issueform1;
<input name=cgiaction type=hidden value="submit_issue">
<table summary="enter issue table" width=100% border=1>
<tr border=0>
  <th align=center colspan=3><b>Issue Information</b>
</tr>
<tr>
  <td width=20% align=center>
  <b>Issue Text</b>
  </td>
  <td width=70% align=left>
  <textarea name=issuetext cols=65 rows=5></textarea>
  <input name=usersid type=hidden value=$usersid>
  <input name=username type=hidden value=$username>
  </td>
  <td width=10% align=center>
  Not Available<br>
  <input name=chkissuetext type=checkbox value=1 onclick="process_checkmark(document.issueentry.chkissuetext, 3, document.issueentry.issuetext)">
  </td>
</tr>
<tr>
  <td width=20% align=center>
  <b>Date of Occurence</b>
  </td>
  <td align=left colspan=2>
issueform1
print build_date_selection('dateoccurred', 'issueentry');
print <<issueform2;
  <br>(Use date of letter or date entered if issue does not have a specific date of occurence)
  </td>
</tr>
<tr>
  <td align=center>
  <b>Issue Source Image File</b>
  </td>
  <td align=left colspan=2>
  <input type=file name=image size=50 maxlength=256>
  <br>(Leave blank if Not Available)
  </td>
</tr>
<tr>
  <td align=center>
  <b>Source Document Page Number</b>
  </td>
  <td align=left colspan=2>
  <input name=page type=text maxlength=5 size=5>
  <br>(Leave blank if Not Available)
  </td>
</tr>
<!-- <tr>
  <td align=center>
  <b>Primary Discipline</b>
  </td>
  <td align=left colspan=2> -->
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
  <td align=left colspan=2> -->
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
  <td align=left colspan=2>
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
  <td colspan=2>
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
  <b>Source Document</b>
  </td>
  <td align=left colspan=2>
issueform6
    print "<select name=sourcedocid onChange=\"checknewsource(document.issueentry.sourcedocid);\">\n";
    print "<option value='' selected>Select A Source Document\n";
    print "<option value='NULL'>No Source Document\n";
    print "<option value=\"NEW\">New Source Document\n";
    foreach $key (sort keys %sourcedochash)
      {
      my $sourcedocdescription = $key;
      $sourcedocdescription =~ s/;$sourcedochash{$key}//g;
      if (length($sourcedocdescription) > 80)
        {
        $sourcedocdescription = substr($sourcedocdescription, 0, 80) . '...';
        }
      print "<option value=\"$sourcedochash{$key}\">$sourcedocdescription\n";
      }
    print "</select>\n";
print <<issueform7;
  </td>
</tr>
</table>
issueform7

my %orghash = get_lookup_values($dbh, 'organization', "name || ' - ' || department || ' - ' || division || ';' || organizationid", 'organizationid');

print <<sourcedoctable1;
<br>
<table summary="table for source document data entry" width=100% border=1>
<tr>
  <th align=center colspan=2><b>New Source Document Information</b>
</tr>
<tr>
  <td width=20% align=center>
  <b>Accession Number</b>
  </td>
  <td width=80% align=left>
  <input type=text name=accessionnum size=17 maxlength=17>
  </td>
</tr>
<tr>
  <td align=center>
  <b>Document Title</b>
  </td>
  <td align=left>
  <textarea name=title cols=65 rows=5 onblur="if(document.issueentry.title.value.length > 1000){alert('Only 1000 characters allowed in a title');document.issueentry.title.focus();}"></textarea>
  </td>
</tr>
<tr>
  <td align=center>
  <b>Signer</b>
  </td>
  <td align=left>
  <input type=text name=signer size=30 maxlength=30>
  </td>
</tr>
<tr>
  <td align=center>
  <b>Signer's Email Address</b>
  </td>
  <td align=left>
  <input type=text name=emailaddress size=50 maxlength=50>
  <br>(Leave blank if Not Available)
  </td>
</tr>
<tr>
  <td align=center>
  <b>Area Code</b>
  </td>
  <td align=left>
  (<input type=text name=areacode size=3 maxlength=3>)
  <br>(Leave blank if Not Available)
  </td>
</tr>
<tr>
  <td align=center>
  <b>Phone Number</b>
  </td>
  <td align=left>
  <input type=text name=phonenumber size=7 maxlength=7>  (no hyphens)
  <br>(Leave blank if Not Available)
  </td>
</tr>
<tr>
  <td align=center>
  <b>Document Date</b>
  </td>
  <td align=left>
sourcedoctable1
print build_date_selection('documentdate', 'issueentry');
print <<sourcedoctable2;
<!--   <input type=text name=documentdate size=10 maxlength=10> (use MM/DD/YYYY format) -->
  </td>
</tr>
<tr>
  <td align=center>
  <b>Organization</b>
  </td>
  <td align=left>
sourcedoctable2
    print "<select name=organizationid>\n";
    print "<option value='' selected>Select An Organization\n";
    foreach $key (sort keys %orghash)
      {
      my $orgdescription = $key;
      $orgdescription =~ s/;$orghash{$key}//g;
      print "<option value=\"$orghash{$key}\">$orgdescription\n";
      }
    print"</select>\n";
print <<sourcedoctable3;
  </td>
</tr>
</table>
sourcedoctable3

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
  disablenewsourcedoc();
//-->
</script>
endofpage
