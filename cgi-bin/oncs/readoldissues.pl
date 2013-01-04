#!/usr/local/bin/newperl
# - !/usr/bin/perl

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);
use UI_Widgets qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use Tie::IxHash;

$| = 1;

$testout = new CGI;

# print content type header
print $testout->header('text/html');

$pagetitle = "Old Issue";
$cgiaction = $testout->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
$submitonly = 0;
$usersid = $testout->param('loginusersid');
$username = $testout->param('loginusername');
$updatetable = "issue";

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

if ($cgiaction ne "report_popup")
  {
  print <<testlabel1;
  <!-- include external javascript code -->
  <script src=$ONCSJavaScriptPath/oncs-utilities.js></script>

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
  }
else
  {
  print <<testlabel2;
  <!-- include external javascript code -->
  <script src=$ONCSJavaScriptPath/oncs-utilities.js></script>
testlabel2
  }

# connect to the oracle database and generate a database handle
$dbh = oncs_connect();

# process the input issue
if (($cgiaction eq "query_issue") || ($cgiaction eq "report_popup"))
  {
  # print the sql which will update this table
  ## print the values passed to the cgi script.
  #foreach $key ($testout->param)
  #  {
  #  print "<B>$key</B> -> ";
  #  @values = $testout->param($key);
  #  print join(",  ",@values), "[--<BR>\n";
  #  }

#######

  $textareawidth = ($cgiaction eq "query_issue") ? 80 : 60;

  $thisissueid = $testout->param('issueselect');
  $issueidstring = substr("0000$thisissueid", -5);
  %issuehash = get_issue_info($dbh, $thisissueid);
  $issuetext = $issuehash{'text'};
  $entereddate = $issuehash{'entereddate'};
  $page = $issuehash{'page'};
  $imagecontenttype = $issuehash{'imagecontenttype'};
  $imageextension = $issuehash{'imageextension'};
  $sourcedocid = $issuehash{'sourcedocid'};
#  $primarydiscipline = $issuehash{'primarydiscipline'};
#  $primarydiscipline = ($primarydiscipline) ? $primarydiscipline : 0;
#  $secondarydiscipline = $issuehash{'secondarydiscipline'};
#  $secondarydiscipline = ($secondarydiscipline) ? $secondarydiscipline : 0;
#  %disciplinehash = ($discipline != '') ? get_lookup_values($dbh, 'discipline', 'disciplineid', 'description', "(disciplineid = $primarydiscipline) OR (disciplineid = $secondarydiscipline)") : ($primarydiscipline, "", $secondarydiscipline, "");
#  %disciplinehash = get_lookup_values($dbh, 'discipline', 'disciplineid', 'description', "(disciplineid = $primarydiscipline) OR (disciplineid = $secondarydiscipline)");
#  $primarydisciplinename = $disciplinehash{$primarydiscipline};
#  $secondarydisciplinename = $disciplinehash{$secondarydiscipline};
  $issuetypeid = $issuehash{'issuetypeid'};
  %issuetypehash = ($issuetypeid) ? get_lookup_values($dbh, 'issuetype', 'issuetypeid', 'description', "issuetypeid = $issuetypeid") : ($issuetypeid, "");
  $issuetypeidname = $issuetypehash{$issuetypeid};
  $categoryid = $issuehash{'categoryid'};
  %categoryhash = ($categoryid) ? get_lookup_values($dbh, 'category', 'categoryid', 'description', "categoryid = $categoryid") : ($categoryid, "");
  $categoryidname = $categoryhash{$categoryid};
  $enteredby = $issuehash{'enteredby'};
  %entereduserhash = get_lookup_values($dbh, 'users', 'usersid', "lastname || ', ' || firstname", "usersid = $enteredby");
  $enteredbyname = $entereduserhash{$enteredby};

#  $dbh->{LongReadLen} = $MaxBytesStored;
#  $imagesqlquery = "SELECT image FROM $SCHEMA.issue WHERE issueid = $thisissueid";
#  $csr = $dbh->prepare($imagesqlquery);
#  $rv = $csr->execute;

#  @imageresults = $csr->fetchrow_array;
#  $rc = $csr->finish;

  if ($imageextension ne "")  # we will skip the image file retrieval and writing if there is no image.
    {
    $image = $ONCSTempFilePath . "images/issueimage$thisissueid$imageextension";

#    print STDERR "$image\n\n";
#    if (open (OUTFILE, ">$image"))
    if (open (OUTFILE, "| ./File_Utilities.pl --command writeFile --protection 0664 --fullFilePath $image"))
      {
      print OUTFILE get_issue_image($dbh, $thisissueid);
      close OUTFILE;
      }
    else
      {
      print "could not open file $image<br>\n";
      }
    }

  if ($sourcedocid)
    {
    %sourcedochash = get_sourcedoc_info($dbh, $sourcedocid);
    $accessionnum = $sourcedochash{'accessionnum'};
    $title = $sourcedochash{'title'};
    $signer = $sourcedochash{'signer'};
    $email = $sourcedochash{'email'};
    $areacode = $sourcedochash{'areacode'};
    $phonenumber = $sourcedochash{'phonenumber'};
    $documentdate = $sourcedochash{'documentdate'};
    $organizationid = $sourcedochash{'organizationid'};
    $categoryid = $sourcedochash{'categoryid'};
    }
  else
    {
    %sourcedochash = ("", "");
    $accessionnum = "";
    $title = "";
    }

  &oncs_disconnect($dbh);

  #display the old issue form
  print <<issuetable1;
  </head>
  <body>
  <form name=issuedata method=post action="/cgi-bin/oncs/enter_commitment_based_on_issue.pl">
  <input name=cgiaction type=hidden value="newcommitment">
  <input name=loginusersid type=hidden value=$usersid>
  <input name=loginusername type=hidden value=$username>
  <input name=issueid type=hidden value=$thisissueid>
  <table summary="display issue table" width="100%" border=1>
  <tr>
    <td width=20% align=center>
    <b>Issue ID</b>
    </td>
    <td width=80% align=left>
    $issueidstring
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Issue Text</b>
    </td>
    <td align=left>
    <textarea name=issuetext onFocus=blur() cols=$textareawidth rows=5>$issuetext</textarea>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Issue Source Image File</b>
    </td>
    <td align=left>
issuetable1
  if ($imageextension eq "")   # No extension means no viewable image attached
    {
    print "    Image not stored for this issue.\n";
    }
  else
    {
    print "    <a href='$ONCSImagePath/images/issueimage$thisissueid$imageextension' target=imagewin>Click for the image source file</a>\n";
    }
print <<issuetable2;
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Page Number</b>
    </td>
    <td align=left>
    $page
    </td>
  </tr>
<!--   <tr>
    <td align=center>
    <b>Primary Discipline</b>
    </td>
    <td align=left>
    $ primarydisciplinename
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Secondary Discipline</b>
    </td>
    <td align=left>
    $ secondarydisciplinename
    </td>
  </tr> -->
  <tr>
    <td align=center>
    <b>Source Category</b>
    </td>
    <td align=left>
    $categoryidname
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Source Document</b>
    </td>
    <td align=left>
issuetable2
  if ($sourcedocid eq "")   # No source document specified
    {
    print "    Source Document Not Specified for this issue.\n";
    }
  else
    {
    $displaytitle = "$accessionnum -- $title";
    if (length($displaytitle) > $textareawidth)
      {
      $displaytitle = substr($displaytitle, 0, $textareawidth) . '...';
      }
    print "    <a href=javascript:PopIt('http://ym1701.ymp.gov/scripts/get_record.com?$accessionnum','newwin')>$displaytitle</a>\n";
    }
print <<issuetable3;
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Entered Date</b>
    </td>
    <td align=left>
    $entereddate
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Entered By</b>
    </td>
    <td align=left>
    $enteredbyname
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Issue Type</b>
    </td>
    <td align=left>
    $issuetypeidname
    </td>
  </tr>
  </table>
issuetable3
if ($cgiaction ne "report_popup")
  {
  print "  <input type=submit name=newcommitment value=\"Enter a New Commitment\" title=\"Enter a new commitment based on the selected issue.\">\n";
  print "  <input type=button name=editissue value=\"Edit This Issue\" title=\"Click this button to edit this issue.\" onclick=\"document.issuedata.action='/cgi-bin/oncs/readoldissues.pl'; document.issuedata.cgiaction.value='editissue'; document.issuedata.submit(); document.issuedata.cgiaction.value='newcommitment'\">\n";
  }
else
  {
  print "  <input type=button name=closewindow value=\"Close This Window\" title=\"Click this button to close this popup window.\" onclick=\"self.close()\">\n";
  }
print <<issuetable4;  
  </form>
  </body>
  </html>
issuetable4

  exit 1;
  }
  
if ($cgiaction eq "editissue")
  {
  $textareawidth = 80;

  $thisissueid = $testout->param('issueid');
  $issueidstring = substr("0000$thisissueid", -5);
  %issuehash = get_issue_info($dbh, $thisissueid);
  $issuetext = $issuehash{'text'};
  $entereddate = $issuehash{'entereddate'};
  $page = $issuehash{'page'};
  $imagecontenttype = $issuehash{'imagecontenttype'};
  $imageextension = $issuehash{'imageextension'};
  $sourcedocid = $issuehash{'sourcedocid'};
#  $primarydiscipline = $issuehash{'primarydiscipline'};
#  $secondarydiscipline = $issuehash{'secondarydiscipline'};
#  %issuedisciplinehash = ($discipline != '') ? get_lookup_values($dbh, 'discipline', 'disciplineid', 'description', "(disciplineid = $primarydiscipline) OR (disciplineid = $secondarydiscipline)") : ($primarydiscipline, "", $secondarydiscipline, "");
#  $primarydisciplinename = $issuedisciplinehash{$primarydiscipline};
#  $secondarydisciplinename = $issuedisciplinehash{$secondarydiscipline};
  $issuetypeid = $issuehash{'issuetypeid'};
  %issuetypehash = ($issuetypeid) ? get_lookup_values($dbh, 'issuetype', 'issuetypeid', 'description', "issuetypeid = $issuetypeid") : ($issuetypeid, "");
  $issuetypeidname = $issuetypehash{$issuetypeid};
  $categoryid = $issuehash{'categoryid'};
  %issuecategoryhash = ($categoryid) ? get_lookup_values($dbh, 'category', 'categoryid', 'description', "categoryid = $categoryid") : ($categoryid, "");
  $categoryidname = $issuecategoryhash{$categoryid};
  $enteredby = $issuehash{'enteredby'};
  %entereduserhash = get_lookup_values($dbh, 'users', 'usersid', "lastname || ', ' || firstname", "usersid = $enteredby");
  $enteredbyname = $entereduserhash{$enteredby};

my %keywordsusedhash = get_lookup_values($dbh, "issuekeyword", "keywordid", "'True'", "issueid = $thisissueid");
my %commitmentsusedhash = get_lookup_values($dbh, "commitment", "commitmentid", "'True'", "issueid = $thisissueid");
#my %disciplinehash = get_lookup_values($dbh, 'discipline', 'description', 'disciplineid', "isactive='T'");
my %categoryhash = get_lookup_values($dbh, 'category', 'description', 'categoryid', "isactive='T'");
my %sourcedochash = get_lookup_values($dbh, 'sourcedoc', "accessionnum || ' - ' || title || ' - ' || to_char(documentdate, 'MM/DD/YYYY') || ';' || sourcedocid", 'sourcedocid');
my %keywordhash = get_lookup_values($dbh, 'keyword', 'description', 'keywordid', "isactive='T'");
my %commitmenthash = get_lookup_values($dbh, 'commitment', "SUBSTR('0000' || commitmentid, -5) || ' - ' || commitdate", 'commitmentid');
my %orghash = get_lookup_values($dbh, 'organization', "name || ' - ' || department || ' - ' || division || ';' || organizationid", 'organizationid');
my %organizationhash = get_lookup_values($dbh, 'organization', 'organizationid', "name || ' - ' || department || ' - ' || division");
my $key = '';

  if ($imageextension ne "")  # we will skip the image file retrieval and writing if there is no image.
    {
    $image = $ONCSTempFilePath . "images/issueimage$thisissueid$imageextension";
#    if (open (OUTFILE, ">$image"))
    if (open (OUTFILE, "| ./File_Utilities.pl --command writeFile --protection 0664 --fullFilePath $image"))
      {
      print OUTFILE get_issue_image($dbh, $thisissueid);
      close (OUTFILE);
      }
    else
      {
      print "could not open file $image<br>\n";
      }
    }

  if ($sourcedocid)
    {
    %issuesourcedochash = get_sourcedoc_info($dbh, $sourcedocid);
    $accessionnum = $issuesourcedochash{'accessionnum'};
    $title = $issuesourcedochash{'title'};
    $signer = $issuesourcedochash{'signer'};
    $email = $issuesourcedochash{'email'};
    $areacode = $issuesourcedochash{'areacode'};
    $phonenumber = $issuesourcedochash{'phonenumber'};
    $documentdate = $issuesourcedochash{'documentdate'};
    $organizationid = $issuesourcedochash{'organizationid'};
    $sourcecategoryid = $issuesourcedochash{'categoryid'};
    }
  else
    {
    %issuesourcedochash = ("", "");
    $accessionnum = "";
    $title = "";
    }


print <<editscript1;
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
      document.issuemodification.accessionnum.disabled = true;
      document.issuemodification.accessionnum.value = "";
      document.issuemodification.signer.disabled = true;
      document.issuemodification.signer.value = "";
      document.issuemodification.title.disabled = true;
      document.issuemodification.title.value = "";
      document.issuemodification.emailaddress.disabled = true;
      document.issuemodification.emailaddress.value = "";
      document.issuemodification.areacode.disabled = true;
      document.issuemodification.areacode.value = "";
      document.issuemodification.phonenumber.disabled = true;
      document.issuemodification.phonenumber.value = "";
      document.issuemodification.documentdate_month.disabled = true;
      document.issuemodification.documentdate_day.disabled = true;
      document.issuemodification.documentdate_year.disabled = true;
      document.issuemodification.organizationid.disabled = true;
      document.issuemodification.organizationid.value = "";
      }

    function enablenewsourcedoc()
      {
      document.issuemodification.accessionnum.disabled = false;
      document.issuemodification.signer.disabled = false;
      document.issuemodification.title.disabled = false;
      document.issuemodification.emailaddress.disabled = false;
      document.issuemodification.areacode.disabled = false;
      document.issuemodification.phonenumber.disabled = false;
      document.issuemodification.documentdate_month.disabled = false;
      document.issuemodification.documentdate_day.disabled = false;
      document.issuemodification.documentdate_year.disabled = false;
      document.issuemodification.organizationid.disabled = false;
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
      var validateform = document.issuemodification;

      //if (! validateform.chkissuetext.checked)
      msg += (validateform.issuetext.value=="") ? "You must enter the issue text.\\n" : "";
      if ((validateform.sourcedocisold.value == 0) && (validateform.sourcedocid.value != "NULL"))
        {
        msg += (validateform.newimage.value=="") ? "You must select the issue image file.\\n" : "";
        msg += (validateform.page.value=="") ? "You must enter the page number the issue starts on.\\n" : "";
        }
      else if (validateform.sourcedocisold.value == 1)
        {
        msg += (validateform.page.value=="") ? "You must enter the page number the issue starts on.\\n" : "";
        }
      //msg += (validateform.primarydiscipline.value=='') ? "You must select the primary discipline for this issue.\\n" : "";
      //msg += (validateform.secondarydiscipline.value=='') ? "You must select the secondary discipline for this issue.\\n" : "";
      msg += (validateform.sourcedocid.value=='') ? "You must select the source document or enter data for it.\\n" : "";
      if (validateform.sourcedocid.value=="NEW")
        {
        msg += (validateform.category.value=='') ? "You must select the category for this issue.\\n" : "";
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
editscript1

  print "</head>\n\n";
  print "<body>\n";

  print "<center><h1>$pagetitle</h1></center>\n";
  print "<form target=control action=\"/cgi-bin/oncs/readoldissues.pl\" enctype=\"multipart/form-data\" method=post name=issuemodification onsubmit=\"return(validatedata())\">\n";
  
  #display the old issue form
  print <<issueform0;
  <input name=cgiaction type=hidden value="submitissuemods">
  <table summary="enter issue table" width="100%" border=1>
  <tr>
    <th align=center colspan=2><b>Issue Information</b>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Issue Number</b>
    </td>
    <td width=80% align=left>
    $issueidstring
    <input name=issueid type=hidden value=$thisissueid>
    <input name=usersid type=hidden value=$usersid>
    <input name=username type=hidden value=$username>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Issue Text</b>
    </td>
    <td align=left>
    <textarea name=issuetext cols=65 rows=5>$issuetext</textarea>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Issue Source Image File</b>
    </td>
    <td align=left>
issueform0
  if ($imageextension eq "")   # No extension means no viewable image attached
    {
    print "    Image not stored for this issue.\n";
    }
  else
    {
    print "    <a href='$ONCSImagePath/images/issueimage$thisissueid$imageextension' target=imagewin>Click for the image source file</a>\n";
    }
  print <<issueform1;
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Replace Issue Source Image File</b>
    </td>
    <td align=left>
    <input type=file name=newimage size=50 maxlength=256>
    <br>This will replace the Source image File (leave blank if you do not wish to replace the image)
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Source Document Page Number</b>
    </td>
    <td align=left>
    <input name=page type=text maxlength=5 size=5 value="$page">
    <br>(Leave blank if Not Available)
    </td>
  </tr>
<!--   <tr>
    <td align=center>
    <b>Primary Discipline</b>
    </td>
    <td align=left> -->
issueform1
#  print "<select name=primarydiscipline>\n";
#  print "<option value=''" . (($primarydiscipline eq '') ? " selected" : "") . ">Select a Primary Discipline\n";
#  print "<option value=NULL>Not Available\n";
#  foreach $key (sort keys %disciplinehash)
#    {
#    my $selectedstring = ($primarydiscipline eq $disciplinehash{$key}) ? "selected" : ""; 
#    print "<option value=\"$disciplinehash{$key}\" $selectedstring>$key\n";
#    }
#  print"</select>\n";
  print <<issueform3;
<!--     </td>
  </tr>
  <tr>
    <td align=center>
    <b>Secondary Discipline</b>
    </td>
    <td align=left> -->
issueform3
#  print "<select name=secondarydiscipline>\n";
#  print "<option value=''" . (($secondarydiscipline eq '') ? " selected" : "") . ">Select a Secondary Discipline\n";
#  print "<option value=NULL>Not Available\n";
#  foreach $ key (sort keys % disciplinehash)
#    {
#    my $selectedstring = ($secondarydiscipline eq $disciplinehash{$key}) ? "selected" : ""; 
#    print "<option value=\"$disciplinehash{$key}\" $selectedstring>$key\n";
#    }
#  print"</select>\n";
  print <<issueform4;
<!--     </td>
  </tr> -->
  <tr>
    <td align=center>
    <b>Source Category</b>
    </td>
    <td align=left>
issueform4
  if ($sourcedocid)
    {
    print "$categoryidname\n";
    print "<input type=hidden name=category value=$categoryid>\n";
    }
  else
    {
    print "<select name=category>\n";
    print "<option value=''" . (($categoryid eq '') ? " selected" : "") . ">Select A Category\n";
    print "<option value=NULL>Not Available\n";
    foreach $key (sort keys %categoryhash)
      {
      my $selectedstring = ($categoryid eq $categoryhash{$key}) ? "selected" : "";
      print "<option value=\"$categoryhash{$key}\" $selectedstring>$key\n";
      }
    print"</select>\n";
    }
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
        <select name=allkeywordlist size=5 multiple ondblclick="process_multiple_dual_select_option(document.issuemodification.allkeywordlist, document.issuemodification.keywords, 'movehist', document.issuemodification.keywordhist)">
issueform5
  foreach $key (sort keys %keywordhash)
    {
    if ($keywordsusedhash{$keywordhash{$key}} ne 'True')
      {
      print "        <option value=\"$keywordhash{$key}\">$key\n";
      }
    }
  print <<issueform5b;
        <option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
        </select>
        </td>
        <td>
        <input name=keywordleftarrow title="Click to remove the selected keyword(s)" value="<--" type=button onclick="process_multiple_dual_select_option(document.issuemodification.keywords, document.issuemodification.allkeywordlist, 'movehist', document.issuemodification.keywordhist)">
        <br>
        <input name=keywordrightarrow title="Click to select the keyword(s)" value="-->" type=button onclick="process_multiple_dual_select_option(document.issuemodification.allkeywordlist, document.issuemodification.keywords, 'movehist', document.issuemodification.keywordhist)">
        <input name=keywordhist type=hidden>
        </td>
        <td>
        <select name=keywords size=5 multiple ondblclick="process_multiple_dual_select_option(document.issuemodification.keywords, document.issuemodification.allkeywordlist, 'movehist', document.issuemodification.keywordhist)">
issueform5b
  foreach $key (sort keys %keywordhash)
    {
    if ($keywordsusedhash{$keywordhash{$key}} eq 'True')
      {
      print "        <option value=\"$keywordhash{$key}\">$key\n";
      }
    }
print <<issueform6;
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
    <b>Commitments Based on This Issue</b>
    </td>
    <td>
    <table border=0 summary="Commitment Selection">
      <tr align=Center>
        <td>
        <b>Commitment List</b>
        </td>
        <td>&nbsp;
        </td>
        <td>
        <b>Commitments Selected</b>
        </td>
      </tr>
      <tr>
        <td>
        <select name=allcommitmentlist size=5 multiple ondblclick="process_multiple_dual_select_option(document.issuemodification.allcommitmentlist, document.issuemodification.commitments, 'movehist', document.issuemodification.commitmenthist)">
issueform6
  foreach $key (sort keys %commitmenthash)
    {
    if ($commitmentsusedhash{$commitmenthash{$key}} ne 'True')
      {
      print "        <option value=\"$commitmenthash{$key}\">$key\n";
      }
    }
  print <<issueform6b;
        <option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
        </select>
        </td>
        <td>
        <input name=commitmentrightarrow title="Click to select the keyword(s)" value="-->" type=button onclick="process_multiple_dual_select_option(document.issuemodification.allcommitmentlist, document.issuemodification.commitments, 'movehist', document.issuemodification.commitmenthist)">
        <input name=commitmenthist type=hidden>
        </td>
        <td>
        <select name=commitments size=5 multiple>
issueform6b
  foreach $key (sort keys %commitmenthash)
    {
    if ($commitmentsusedhash{$commitmenthash{$key}} eq 'True')
      {
      print "        <option value=\"$commitmenthash{$key}\">$key\n";
      }
    }
print <<issueform7;
        <option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
        </select>
        </td>
      </tr>
    </table>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Source Document</b>
    </td>
    <td align=left>
issueform7
  if ($sourcedocid)
    {
    print <<sourcedisplay;
      <table width=100% summary="Display of the source document">
      <tr>
        <td width=20%>
          <b>Accession Number</b>
        </td>
        <td width=80%>
          <a href=javascript:PopIt('http://ym1701.ymp.gov/scripts/get_record.com?$accessionnum','newwin')>$accessionnum</a>
          <input type=hidden name=sourcedocid value=$sourcedocid>
          <input type=hidden name=accessionum value=$accessionnum>
          <input type=hidden name=sourcedocisold value=1>
        </td>
      </tr>
      <tr>
        <td>
          <b>Document Title</b>
        </td>
        <td>
          $title
        </td>
      </tr>
      <tr>
        <td>
          <b>Document Signer</b>
        </td>
        <td>
          $signer
        </td>
      </tr>
      <tr>
        <td>
          <b>Signer's Email Address</b>
        </td>
        <td>
          $email
        </td>
      </tr>
      <tr>
        <td>
          <b>Phone Number</b>
        </td>
        <td>
          ($areacode) $phonenumber
        </td>
      </tr>
      <tr>
        <td>
          <b>Document Date</b>
        </td>
        <td>
          $documentdate
        </td>
      </tr>
      <tr>
        <td>
          <b>Organization</b>
        </td>
        <td>
          $organizationhash{$organizationid}
        </td>
      </tr>
      </table>
sourcedisplay
    }
  else
    {
      print "<input type=hidden name=sourcedocisold value=0>\n";
      print "<select name=sourcedocid onChange=\"checknewsource(document.issuemodification.sourcedocid);\">\n";
      print "<option value=''>Select A Source Document\n";
      print "<option value='NULL'>No Source Document\n";
      print "<option value='NEW'>New Source Document\n";
      foreach $key (sort keys %sourcedochash)
        {
        my $selectedstring = ($sourcedocid eq $sourcedochash{$key}) ? "selected" : "";
        my $sourcedocdescription = $key;
        $sourcedocdescription =~ s/;$sourcedochash{$key}//g;
        if (length($sourcedocdescription) > 80)
          {
          $sourcedocdescription = substr($sourcedocdescription, 0, 80) . '...';
          }
        print "<option value=\"$sourcedochash{$key}\" $selectedstring>$sourcedocdescription\n";
        }
      print "</select>\n";
    }
  print <<issueform7;
    </td>
  </tr>
  </table>
issueform7

  if ($sourcedocid)
    {
    print "<input name=updatetable type=hidden value=$updatetable>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";
  
    #disconnect from the database
    &oncs_disconnect($dbh);
  
    # print html footers.
    print "<br>\n";
    print "<input name=submit type=submit value=\"Submit Changes\" onclick=\"selectemall(document.issuemodification.keywords)\">\n";
    print "</form>\n";
  
    print <<endofpageearly;
    </body>
    </html>
endofpageearly
    exit 1;
    }


# now create the source document data entry section.  Note, we cannot edit a 
# source document, just add a new one.  Also, if a source document has been 
# specified for this issue, we should not allow a change to it.
  
  print <<sourcedocedittable1;
  <br>
  <table summary="table for source document data entry" width=100% border=1>
  <tr>
    <th align=center colspan=2><b>Source Document Information</b>
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
    <td width=20% align=center>
    <b>Document Title</b>
    </td>
    <td width=80% align=left>
    <textarea name=title cols=65 rows=5 onblur="if(document.issuemodification.title.value.length > 1000){alert('Only 1000 characters allowed in a title');document.issuemodification.title.focus();}"></textarea>
    <!-- <input type=text name=title size=80 maxlength=80> -->
    </td>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Signer</b>
    </td>
    <td width=80% align=left>
    <input type=text name=signer size=30 maxlength=30>
    </td>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Signer's Email Address</b>
    </td>
    <td width=80% align=left>
    <input type=text name=emailaddress size=50 maxlength=50>
    <br>(Leave blank if Not Available)
    </td>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Area Code</b>
    </td>
    <td width=80% align=left>
    (<input type=text name=areacode size=3 maxlength=3>)
    <br>(Leave blank if Not Available)
    </td>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Phone Number</b>
    </td>
    <td width=80% align=left>
    <input type=text name=phonenumber size=7 maxlength=7>  (no hyphens)
    <br>(Leave blank if Not Available)
    </td>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Document Date</b>
    </td>
    <td width=80% align=left>
sourcedocedittable1
  print build_date_selection('documentdate', 'issuemodification');
  print <<sourcedocedittable2;
  <!--   <input type=text name=documentdate size=10 maxlength=10> (use MM/DD/YYYY format) -->
    </td>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Organization</b>
    </td>
    <td width=80% align=left>
sourcedocedittable2
      print "<select name=organizationid>\n";
      print "<option value='' selected>Select An Organization\n";
      foreach $key (sort keys %orghash)
        {
        my $orgdescription = $key;
        $orgdescription =~ s/;$orghash{$key}//g;
        print "<option value=\"$orghash{$key}\">$orgdescription\n";
        }
      print"</select>\n";
  print <<sourcedocedittable3;
    </td>
  </tr>
  </table>
sourcedocedittable3
  
  print "<input name=updatetable type=hidden value=$updatetable>\n";
  print "<input name=loginusername type=hidden value=$username>\n";
  print "<input name=loginusersid type=hidden value=$usersid>\n";
  print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";
  
  #disconnect from the database
  &oncs_disconnect($dbh);
  
  # print html footers.
  print "<br>\n";
  print "<input name=submit type=submit value=\"Submit Changes\" onclick=\"selectemall(document.issuemodification.keywords)\">\n";
  print "</form>\n";
  
  print <<endofpage;
  </body>
  </html>
  <script language="JavaScript" type="text/javascript"><!--
    //checknewsource(document.issuemodification.sourcedocid);
  //-->
  </script>
endofpage
  
  exit 1;
  }

# process the input issue
if ($cgiaction eq "submitissuemods")
  {
  no strict 'refs';

  my $issueid = $testout->param('issueid');

  my $issuetext = $testout->param('issuetext');
  $issuetext = ($issuetext) ? $issuetext : "Historical Data not Available.";
  my $filename = $testout->param('newimage');
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
    #print "$sourcesqlstring<br> \n";
    #exit 1;
    }
  my $issuetype = 1;

#  my $sqlstring = "UPDATE $SCHEMA.$updatetable SET text=:textclob,
#                 sourcedocid=$sourcedocid, page='$page', issuetypeid=$issuetype, 
#                 primarydiscipline=$primarydiscipline,
#                 secondarydiscipline=$secondarydiscipline, categoryid=$categoryid
#                 WHERE issueid=$issueid";

  my $sqlstring = "UPDATE $SCHEMA.$updatetable SET text=:textclob,
                 sourcedocid=$sourcedocid, page='$page', categoryid=$categoryid
                 WHERE issueid=$issueid";

  my $filesqlstring = "UPDATE $SCHEMA.$updatetable SET image=:imgblob, 
                       imageextension=$imageextension, imagecontenttype=$imagetype
                       WHERE issueid=$issueid";                 

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

    $activity = "Edit Historical Issue Information: $issueid";
    my $csr = $dbh->prepare($sqlstring);
    $csr->bind_param(":textclob", $issuetext, {ora_type => ORA_CLOB, ora_field => 'text' });
    $csr->execute;
    if ($filename)
      {
      $activity = "Replace image in issue record for issue: $issueid";
      $csr = $dbh->prepare($filesqlstring);
      $csr->bind_param(":imgblob", $filedata, {ora_type => ORA_BLOB, ora_field => 'image' });
      $csr->execute;
      }

    # update issue keywords.
    my $dualhistory = $testout->param('keywordhist');
    $dualhistory =~ s/\s+//;
    while (my $histitem = substr($dualhistory, 0, index($dualhistory, ';')))
      {
      my $keywordsqlstring;
      $dualhistory = substr($dualhistory, (index($dualhistory, ';') + 1));
      if ($histitem =~ /keywords/i)
        {
        $keywordsqlstring = "INSERT INTO $SCHEMA.issuekeyword VALUES ($issueid, " . substr($histitem, 0, index($histitem, '-->')) . ")";
        }
      else
        {
        $keywordsqlstring = "DELETE $SCHEMA.issuekeyword WHERE (issueid = $issueid) AND (keywordid = " . substr($histitem, 0, index($histitem, '-->')) . ")";
        }
      #print "$keywordsqlstring<br>\n";
      $csr = $dbh->prepare($keywordsqlstring);
      $csr->execute;
      }

    # add commitments to this issue.
    my $dualhistory = $testout->param('commitmenthist');
    $dualhistory =~ s/\s+//;
    while (my $histitem = substr($dualhistory, 0, index($dualhistory, ';')))
      {
      my $commitmentsqlstring;
      $dualhistory = substr($dualhistory, (index($dualhistory, ';') + 1));
      if ($histitem =~ /commitments/i)
        {
        $commitmentsqlstring = "UPDATE $SCHEMA.commitment SET issueid = $issueid WHERE commitmentid = " . substr($histitem, 0, index($histitem, '-->'));
        }
      #print "$commitmentsqlstring<br>\n";
      $csr = $dbh->prepare($commitmentsqlstring);
      $csr->execute;
      }

    $csr->finish;
    };
  if ($@)
    {
    $dbh->rollback;
    my $alertstring = errorMessage($dbh, $username, $usersid, 'issue/sourcedoc', "$issueid . $sourcedocid", $activity, $@);
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
    &log_history($dbh, "Historical Issue Modified", 'F', $usersid, 'issue', $issueid, "Issue $issueid was modified by user $username.");
    print <<pageresults;
    <script language="JavaScript" type="text/javascript">
      <!--
      parent.workspace.location="/cgi-bin/oncs/readoldissues.pl?loginusersid=$usersid&loginusername=$username";
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

print "<form action=\"/cgi-bin/oncs/readoldissues.pl\" enctype=\"multipart/form-data\" method=post name=issueselection onsubmit=\"return(true)\">\n";

$dbh->{LongReadLen} = $TitleLength;
$dbh->{LongTruncOk} = True;
tie my %issuehash, "Tie::IxHash";
%issuehash = get_lookup_values($dbh, 'issue', 'issueid', "TO_CHAR(entereddate, 'MM/DD/YYYY') || ' - ' || ';' || issueid", "1=1 ORDER BY issueid");
%issuetexthash = get_lookup_values ($dbh, 'issue', 'issueid', 'text');
$dbh->{LongTruncOk} = False;

#display the old issue form
print <<issueselectionform1;
<input name=cgiaction type=hidden value="query_issue">
<select name=issueselect size=10>
issueselectionform1
foreach $key (keys %issuehash) #(sort keys %issuehash)
  {
  $issuedescription = $issuehash{$key};
  $issuedescription =~ s/;$key/$issuetexthash{$key}/g;
  $displaykey = "0000$key";
  $displaykey = substr($displaykey, -5);
  print "<option value=$key>$displaykey - " . getDisplayString($issuedescription, 80) . "\n";
  }
print"</select>\n";

print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=loginusername type=hidden value=$username>\n";
print "<input name=loginusersid type=hidden value=$usersid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";

#disconnect from the database
&oncs_disconnect($dbh);

# print html footers.
print "<br>\n";
print "<input name=submit type=submit value=\"View Selected Issue\" onclick=\"dosubmit=true; (document.issueselection.issueselect.selectedIndex == -1) ? (alert(\'No Issue Selected\') || (dosubmit = false)) : dosubmit=true; return(dosubmit)\">\n";
print "</form>\n";

print "</body>\n";
print "</html>\n";
