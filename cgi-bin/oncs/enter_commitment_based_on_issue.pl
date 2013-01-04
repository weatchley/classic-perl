#!/usr/local/bin/newperl
# - !/usr/bin/perl
#require "oncs_header.pl";
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);
use UI_Widgets qw(:Functions);
#require "oncs_lib.pl";
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;
my $testout;
my $pagetitle;
my $cgiaction;
my $usersid;
my $username;
my $submitonly;
my $updatetable;
my $dbh;
my $activity;
$testout = new CGI;
# print content type header
print $testout->header('text/html');
$pagetitle = "Old Commitment";
$cgiaction = $testout->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
$submitonly = 0;
$usersid = $testout->param('loginusersid');
$username = $testout->param('loginusername');
$updatetable = "commitment";
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
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>
    <script type="text/javascript">
    <!--
    var dosubmit = true;
    if (parent == self)  // not in frames
      {
      location = '/cgi-bin/oncs/oncs_user_login.pl';
      }
    //-->
  </script>
testlabel1
# connect to the oracle database and generate a database handle
$dbh = oncs_connect();
# process the input issue
if ($cgiaction eq "save_commitment")
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

# Gather information regarding the commitment
  my $issueid;
  my $nextcommitmentid;
  my $duedate;
  my $statusid;
  my $commitdate;
  my $criticalpath;
  my $estimate;
  my $estimatesql;
  my $functionalrecommend;
  my $functionalrecommendsql;
  my $commitmentrationale;
  my $commitmentrationalesql;
  my $closingdocimage;
  my $text;
  my $textsql;
  my $comments;
  my $commentssql;
  my $rejectionrationale;
  my $rejectionrationalesql;
  my $resubmitrationale;
  my $resubmitrationalesql;
  my $actionstaken;
  my $actionstakensql;
  my $actionsummary;
  my $actionsummarysql;
  my $actionplan;
  my $actionplansql;
  my $cmrecommendation;
  my $cmrecommendationsql;
  my $closeddate;
  my $changerequestnum;
  my $controlaccountid;
  my $issueid;
  my $approver;
  my $replacedby;
  my $updatedby;
  my $commitmentlevelid;
  my $oldid;
  my $primarydiscipline;
  my $secondarydiscipline;
  print "</head><body>\n";
  $nextcommitmentid = get_next_id($dbh, $updatetable);
  $duedate = $testout->param('duedate');
  $duedate = ($duedate eq "") ? "NULL" : "TO_DATE('$duedate', 'MM/DD/YYYY')";
  $statusid = $testout->param('statusid');
  $commitdate = $testout->param('commitdate');
  $commitdate = ($commitdate eq "") ? "NULL" : "TO_DATE('$commitdate', 'MM/DD/YYYY')";
  $criticalpath = 'NULL';
  $estimate = $testout->param('estimate');
#  $estimate =~ s/'/''/g;
  $estimatesql = $estimate ? ":estimateclob" : "NULL";
  $functionalrecommend = $testout->param('functionalrecommend');
#  $functionalrecommend =~ s/'/''/g;
  $functionalrecommend = $functionalrecommend ? $functionalrecommend : "Historical Data Not Available.";
  $functionalrecommendsql = $functionalrecommend ? ":functionalrecommendclob" : "NULL";
  $commitmentrationale = $testout->param('commitmentrationale');
#  $commitmentrationale =~ s/'/''/g;
  $commitmentrationale = $commitmentrationale ? $commitmentrationale : "Historical Data Not Available.";
  $commitmentrationalesql = $commitmentrationale ? ":commitmentrationaleclob" : "NULL";
#  $closingdocimage = $testout->param('closingdocimage');
  $text = $testout->param('text');
#  $text =~ s/'/''/g;
  $textsql = $text ? ":textclob" : "NULL";
  $comments = $testout->param('comments');
#  $comments =~ s/'/''/g;
  $commentssql = $comments ? ":commentsclob" : "NULL";
#  $rejectionrationale = $testout->param('rejectionrationale');
#  $rejectionrationale =~ s/'/''/g;
  $rejectionrationale = "";
  $rejectionrationalesql = $rejectionrationale ? ":rejectionrationaleclob" : "NULL";
#  $resubmitrationale = $testout->param('resubmitrationale');
#  $resubmitrationale =~ s/'/''/g;
  $resubmitrationale = "";
  $resubmitrationalesql = $resubmitrationale ? ":resubmitrationaleclob" : "NULL";
  $actionstaken = $testout->param('actionstaken');
#  $actionstaken =~ s/'/''/g;
  $actionstaken = $actionstaken ? $actionstaken : "Historical Data not Available.";
  $actionstakensql = $actionstaken ? ":actionstakenclob" : "NULL";
  $actionsummary = $testout->param('actionsummary');
#  $actionsummary =~ s/'/''/g;
  $actionsummary = $actionsummary ? $actionsummary : "Historical Data not Available.";
  $actionsummarysql = $actionsummary ? ":actionsummaryclob" : "NULL";
  $actionplan = $testout->param('actionplan');
#  $actionplan =~ s/'/''/g;
  $actionplan = $actionplan ? $actionplan : "Historical Data not Available.";
  $actionplansql = $actionplan ? ":actionplanclob" : "NULL";
  $cmrecommendation = $testout->param('cmrecommendation');
#  $cmrecommendation =~ s/'/''/g;
  $cmrecommendation = $cmrecommendation ? $cmrecommendation : "Historical Data not Available.";
  $cmrecommendationsql = $cmrecommendation ? ":cmrecommendationclob" : "NULL";
  $closeddate = $testout->param('closeddate');
  $closeddate = ($closeddate eq "") ? "NULL" : "TO_DATE('$closeddate', 'MM/DD/YYYY')";
  $commitmentlevelid = $testout->param('commitmentlevelid');
  $commitmentlevelid = ($commitmentlevelid eq "") ? "NULL" : $commitmentlevelid;
  $oldid = $testout->param('oldid');
  $oldid = ($oldid eq "") ? "NULL" : "'$oldid'";
  $primarydiscipline = $testout->param('primarydiscipline');
  $secondarydiscipline = $testout->param('secondarydiscipline');
  $controlaccountid = "'" . $testout->param('workbreakdownstructure') . "'";
  #$thiswbs =~ m/ \. /;
  #$changerequestnum = "'" . $` . "'";
  #$controlaccountid = "'" . $' . "'";
  $changerequestnum = "NULL";
  if ($controlaccountid eq "")
    {
    $controlaccountid = "NULL";
    }
  $issueid = $testout->param('issueid');
  $approver = $testout->param('approver');
  $replacedby = $testout->param('replacedby');
  $updatedby = $usersid;
  my $imagetype = 'NULL';
  my $imageextension = 'NULL';
  my $fnameinsertstring = 'NULL';
#  my $filesize = 0;
#  my $filedata = '';
#  if ($closingdocimage)
#    {
#    my $bytesread = 0;
#    my $buffer = '';
#    # read a 16 K chunk and append the data to the variable $filedata
#    while ($bytesread = read($closingdocimage, $buffer, 16384))
#      {
#      $filedata .= $buffer;
#      $filesize += $bytesread;
#      }
#    $imagetype = "'" . $testout->uploadInfo($closingdocimage)->{'Content-Type'} . "'";
#    $closingdocimage =~ /.*\\.*(\..*)/;
#    $imageextension = "'" . $1 . "'";
#    $fnameinsertstring = ":imgblob";
#    }
#  else
#    {
#    $imagetype = 'NULL';
#    $imageextension = 'NULL';
#    $fnameinsertstring = 'NULL';
#    }
  my $sqlstring = "INSERT INTO $SCHEMA.$updatetable (commitmentid, duedate, statusid, commitdate, criticalpath, estimate,
                 functionalrecommend, commitmentrationale, closingdocimage, text, comments, rejectionrationale,
                 resubmitrationale, actionstaken, actionsummary, actionplan, cmrecommendation, closeddate,
                 changerequestnum, controlaccountid, issueid, approver, replacedby, updatedby, commitmentlevelid, oldid,
                 primarydiscipline, secondarydiscipline) VALUES ($nextcommitmentid, $duedate,
                 $statusid, $commitdate, $criticalpath, $estimatesql, $functionalrecommendsql,
                 $commitmentrationalesql, $fnameinsertstring, $textsql, $commentssql, $rejectionrationalesql,
                 $resubmitrationalesql, $actionstakensql, $actionsummarysql, $actionplansql, $cmrecommendationsql,
                 $closeddate, $changerequestnum, $controlaccountid, $issueid, $approver,
                 $replacedby, $updatedby, $commitmentlevelid, $oldid, $primarydiscipline, $secondarydiscipline)";

# Gather information regarding assignments
  my $doefunctionallead;
  my $doecommitmentcoordinator;
  my $doecommitmentmanager;
  my $commitmentmaker;
  my $mofunctionallead;
  my $mocommitmentcoordinator;
  my $mocommitmentmanager;
  my $doeflsqlstring;
  my $doeccsqlstring;
  my $doecmgrsqlstring;
  my $cmsqlstring;
  my $moflsqlstring;
  my $moccsqlstring;
  my $mocmgrsqlstring;
  my $doeflroleid;
  my $doeccroleid;
  my $doecmgrroleid;
  my $cmroleid;
  my $moflroleid;
  my $moccroleid;
  my $mocmgrroleid;

  #get assignments form form
  $doefunctionallead = $testout->param('doefunctionallead');
  $doecommitmentcoordinator = $testout->param('doecommitmentcoordinator');
  $doecommitmentmanager = $testout->param('doecommitmentmanager');
  $commitmentmaker = $testout->param('commitmentmaker');
  $mofunctionallead = $testout->param('mofunctionallead');
  $mocommitmentcoordinator = $testout->param('mocommitmentcoordinator');
  $mocommitmentmanager = $testout->param('mocommitmentmanager');

  #get role ids
  $doeflroleid = lookup_role_by_name($dbh, "DOE Functional Lead");
  $doeccroleid = lookup_role_by_name($dbh, "DOE Commitment Coordinator");
  $doecmgrroleid = lookup_role_by_name($dbh, "DOE Commitment Manager");
  $cmroleid = lookup_role_by_name($dbh, "Commitment Maker");
  $moflroleid = lookup_role_by_name($dbh, "M&O Functional Lead");
  $moccroleid = lookup_role_by_name($dbh, "M&O Commitment Coordinator");
  $mocmgrroleid = lookup_role_by_name($dbh, "M&O Commitment Manager");

  #create sql strings for assignments
  my $doeflsqlstring = "INSERT INTO $SCHEMA.commitmentrole VALUES($nextcommitmentid,
                        $doeflroleid, $doefunctionallead)";
  my $doeccsqlstring = "INSERT INTO $SCHEMA.commitmentrole VALUES($nextcommitmentid,
                        $doeccroleid, $doecommitmentcoordinator)";
  my $doecmgrsqlstring = "INSERT INTO $SCHEMA.commitmentrole VALUES($nextcommitmentid,
                          $doecmgrroleid, $doecommitmentmanager)";
  my $cmsqlstring = "INSERT INTO $SCHEMA.commitmentrole VALUES($nextcommitmentid,
                     $cmroleid, $commitmentmaker)";
  my $moflsqlstring = "INSERT INTO $SCHEMA.commitmentrole VALUES($nextcommitmentid,
                       $moflroleid, $mofunctionallead)";
  my $moccsqlstring = "INSERT INTO $SCHEMA.commitmentrole VALUES($nextcommitmentid,
                       $moccroleid, $mocommitmentcoordinator)";
  my $mocmgrsqlstring = "INSERT INTO $SCHEMA.commitmentrole VALUES($nextcommitmentid,
                         $mocmgrroleid, $mocommitmentmanager)";

#Gather data relating to the letter containing the response
  my $letterid = $testout->param('letterid');
  my $newletterflag = 0;
  if ($letterid eq "NEW")
    {
    $newletterflag = 1;
    $letterid = get_next_id($dbh, 'letter');
    }
  my $letteraccessionnum = $testout->param('letteraccessionnum');
  $letteraccessionnum = ($letteraccessionnum) ? "'$letteraccessionnum'" : "NULL";
  my $lettersentdate = $testout->param('lettersentdate');
  $lettersentdate = ($lettersentdate eq "") ? "NULL" : "TO_DATE('$lettersentdate', 'MM/DD/YYYY')";
  my $letteraddressee = $testout->param('letteraddressee');
  $letteraddressee =~ s/'/''/g;
  $letteraddressee = ($letteraddressee) ? "'$letteraddressee'" : "NULL";
  my $lettersigneddate = $testout->param('lettersigneddate');
  $lettersigneddate = ($lettersigneddate eq "") ? "NULL" : "TO_DATE('$lettersigneddate', 'MM/DD/YYYY')";
  my $letterorganizationid = $testout->param('letterorganizationid');
  my $lettersigner = $testout->param('lettersigner');
  my $lettersqlstring = "INSERT INTO $SCHEMA.letter VALUES($letterid, $letteraccessionnum, $lettersentdate,
                         $letteraddressee, $lettersigneddate, $letterorganizationid, $lettersigner)";

#Gather data relating to the response (commitment text)
  my $responseid = get_next_id($dbh, 'response');
  my $responsetext = $text;
  my $responsetextsql = $textsql;
  my $datewritten = $testout->param('datewritten');
  $datewritten = ($datewritten eq "") ? "NULL" : "TO_DATE('$datewritten', 'MM/DD/YYYY')";
  my $responsesqlstring = "INSERT INTO $SCHEMA.response VALUES($responseid, $responsetextsql,
                           $datewritten, $nextcommitmentid, $letterid)";

  #add commitment to database
  $activity = "Insert a historical commitment based on issue: $issueid.";
  $dbh->{AutoCommit} = 0;
  $dbh->{RaiseError} = 1;
  eval
    {
    my $csr = $dbh->prepare($sqlstring);
    if ($estimate)
      {
      $csr->bind_param(":estimateclob", $estimate, {ora_type => ORA_CLOB, ora_field => 'estimate' });
      }
    if ($functionalrecommend)
      {
      $csr->bind_param(":functionalrecommendclob", $functionalrecommend, {ora_type => ORA_CLOB, ora_field => 'functionalrecommend' });
      }
    if ($commitmentrationale)
      {
      $csr->bind_param(":commitmentrationaleclob", $commitmentrationale, {ora_type => ORA_CLOB, ora_field => 'commitmentrationale' });
      }
    if ($text)
      {
      $csr->bind_param(":textclob", $text, {ora_type => ORA_CLOB, ora_field => 'text' });
      }
    if ($comments)
      {
      $csr->bind_param(":commentsclob", $comments, {ora_type => ORA_CLOB, ora_field => 'comments' });
      }
    if ($rejectionrationale)
      {
      $csr->bind_param(":rejectionrationaleclob", $rejectionrationale, {ora_type => ORA_CLOB, ora_field => 'rejectionrationale' });
      }
    if ($resubmitrationale)
      {
      $csr->bind_param(":resubmitrationaleclob", $resubmitrationale, {ora_type => ORA_CLOB, ora_field => 'resubmitrationale' });
      }
    if ($actionstaken)
      {
      $csr->bind_param(":actionstakenclob", $actionstaken, {ora_type => ORA_CLOB, ora_field => 'actionstaken' });
      }
    if ($actionsummary)
      {
      $csr->bind_param(":actionsummaryclob", $actionsummary, {ora_type => ORA_CLOB, ora_field => 'actionsummary' });
      }
    if ($actionplan)
      {
      $csr->bind_param(":actionplanclob", $actionplan, {ora_type => ORA_CLOB, ora_field => 'actionplan' });
      }
    if ($cmrecommendation)
      {
      $csr->bind_param(":cmrecommendationclob", $cmrecommendation, {ora_type => ORA_CLOB, ora_field => 'cmrecommendation' });
      }
  #  if ($closingdocimage)
  #    {
  #    $csr->bind_param(":imgblob", $filedata, {ora_type => ORA_BLOB, ora_field => 'closingdocimage' });
  #    }
    $csr->execute;

    #add assignments to database
    if ($doefunctionallead ne "NULL")
      {
      $activity = "Create DOE FL Role for Commitment: $nextcommitmentid.";
      $csr = $dbh->prepare($doeflsqlstring);
      $csr->execute;
      }
    if ($doecommitmentcoordinator ne "NULL")
      {
      $activity = "Create DOE CC Role for Commitment: $nextcommitmentid.";
      $csr = $dbh->prepare($doeccsqlstring);
      $csr->execute;
      }
    if ($doecommitmentmanager ne "NULL")
      {
      $activity = "Create DOE CMgr Role for Commitment: $nextcommitmentid.";
      $csr = $dbh->prepare($doecmgrsqlstring);
      $csr->execute;
      }
    if ($commitmentmaker ne "NULL")
      {
      $activity = "Create Commitment Maker Role for Commitment: $nextcommitmentid.";
      $csr = $dbh->prepare($cmsqlstring);
      $csr->execute;
      }
    if ($mofunctionallead ne "NULL")
      {
      $activity = "Create M\&O FL Role for Commitment: $nextcommitmentid.";
      $csr = $dbh->prepare($moflsqlstring);
      $csr->execute;
      }
    if ($mocommitmentcoordinator ne "NULL")
      {
      $activity = "Create M\&O CC Role for Commitment: $nextcommitmentid.";
      $csr = $dbh->prepare($moccsqlstring);
      $csr->execute;
      }
    if ($mocommitmentmanager ne "NULL")
      {
      $activity = "Create M\&O CMgr Role for Commitment: $nextcommitmentid.";
      $csr = $dbh->prepare($mocmgrsqlstring);
      $csr->execute;
      }

    #add letter for this commitment if necessary
    if ($newletterflag == 1)
      {
      $activity = "Create Letter for commitment: $nextcommitmentid, response: $responseid.";
      $csr = $dbh->prepare($lettersqlstring);
      $csr->execute;
      }

    #add commitment response (commitment text as in respone letter)
    $activity = "Add response $responseid to commitment: $nextcommitmentid.";
    $csr = $dbh->prepare($responsesqlstring);
    if ($responsetext)
      {
      $csr->bind_param(":textclob", $responsetext, {ora_type => ORA_CLOB, ora_field => 'text' });
      }
    $csr->execute;

    #add committed to record(s)
    my $committedorgid;
    foreach $committedorgid ($testout->param('committedto'))
      {
      $activity = "Insert committed to organization: $committedorgid for commitment: $nextcommitmentid.";
      my $committedorgsqlstring = "INSERT INTO $SCHEMA.committedorg VALUES($nextcommitmentid, $committedorgid)";
      $csr = $dbh->prepare($committedorgsqlstring);
      $csr->execute;
      }

    #add keywords to record(s)
    my $keywordid;
    foreach $keywordid ($testout->param('keywords'))
      {
      $activity = "Insert keyword: $keywordid for commitment: $nextcommitmentid.";
      my $keywordsqlstring = "INSERT INTO $SCHEMA.commitmentkeyword VALUES($nextcommitmentid, $keywordid)";
      $csr = $dbh->prepare($keywordsqlstring);
      $csr->execute;
      }

    $csr->finish;
    };
  if ($@)
    {
    $dbh->rollback;
    my $alertstring = errorMessage($dbh, $username, $usersid, 'commitment', $nextcommitmentid, $activity, $@);
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
    my $productid;
    my $errorfree = 1;
    # we have written the commitment to the database, now we must write the products affected table
    foreach $productid ($testout->param('productsaffected'))
      {
      eval
        {
        $activity = "Insert product affection product: $productid, commitment: $nextcommitmentid";
        my $productsqlstring = "INSERT INTO $SCHEMA.productaffected VALUES($productid, $nextcommitmentid)";
        my $csr = $dbh->prepare($productsqlstring);
        $csr->execute;
        $csr->finish;
        };
      if ($@)
        {
        $errorfree = 0;
        $dbh->rollback;
        my $alertstring = errorMessage($dbh, $username, $usersid, 'productaffected', "$productid . $nextcommitmentid", $activity, $@);
        $alertstring =~ s/"/''/g;
        print <<pageerror2;
        <script language="JavaScript" type="text/javascript">
          <!--
          alert("$alertstring");
          parent.control.location="/oncs/blank.htm";
          //-->
        </script>
pageerror2
        }
      }
    if ($errorfree)
      {
      &log_history($dbh, "Historical Commitment Added", 'F', $usersid, 'commitment', $nextcommitmentid, "Commitment $nextcommitmentid was added by user $username.");
      print <<pageresults;
      <script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="/cgi-bin/oncs/commitment_module_main.pl?loginusersid=$usersid&loginusername=$username";
        parent.control.location="/oncs/blank.htm";
        //-->
      </script>
pageresults
      }
    }
  $dbh->commit;
  $dbh->{AutoCommit} = 1;
  $dbh->{RaiseError} = 0;
  &oncs_disconnect($dbh);
  print "</body></html>\n";
  exit 1;
  }

if ($cgiaction eq "newcommitment")
  {
  my $issueid = $testout->param('issueid');
  $dbh->{LongReadLen} = $TitleLength;
  $dbh->{LongTruncOk} = 1;
  my $key;
  my %commitmentlevelhash = get_lookup_values($dbh, 'commitmentlevel', 'description', 'commitmentlevelid', "isactive='T'");
  my %productshash = get_lookup_values($dbh, 'product', 'description', 'productid', "isactive='T'");
  my %keywordhash = get_lookup_values($dbh, 'keyword', 'description', 'keywordid', "isactive='T'");
  my %wbshash = get_lookup_values($dbh, 'workbreakdownstructure', "controlaccountid", "description");
  my %orghash = get_lookup_values($dbh, 'organization', "name || ' - ' || department || ' - ' || division || ';' || organizationid", 'organizationid');
  my %usershash = get_lookup_values($dbh, 'users', "lastname || ', ' || firstname || ';' || usersid", 'usersid');
  my $usernamestring;
  my %statushash = get_lookup_values($dbh, 'status', 'description', 'statusid', "isactive='T'");
  my %disciplinehash = get_lookup_values($dbh, 'discipline', 'description', 'disciplineid', "isactive='T'");
  my %commitmenthash = get_lookup_values($dbh, 'commitment', "TO_CHAR(commitdate, 'MM/DD/YYYY') || ';' || commitmentid", 'commitmentid');
  my %commitmenttexthash = get_lookup_values ($dbh, 'commitment', "commitmentid", "text");
  my $commitmentstring;
  my %letterhash = get_lookup_values($dbh, 'letter', "accessionnum || ' - ' || to_char(sentdate, 'MM/DD/YYYY') || ';' || letterid", 'letterid');
  $dbh->{LongTruncOk} = 0;
  #display the old issue form
  print <<committable0;
  <script language="JavaScript" type="text/javascript">
    <!--
    function disableletter()
      {
      document.newcommitment.letteraccessionnum.disabled = true;
      document.newcommitment.letteraccessionnum.value = "";
      document.newcommitment.lettersigner.disabled = true;
      document.newcommitment.lettersigner.value = "";
      document.newcommitment.lettersigneddate_month.disabled = true;
      document.newcommitment.lettersigneddate_day.disabled = true;
      document.newcommitment.lettersigneddate_year.disabled = true;
      document.newcommitment.chklettersigneddate.disabled = true;
      document.newcommitment.chklettersigneddate.checked = false;
      document.newcommitment.lettersentdate_month.disabled = true;
      document.newcommitment.lettersentdate_day.disabled = true;
      document.newcommitment.lettersentdate_year.disabled = true;
      document.newcommitment.chklettersentdate.disabled = true;
      document.newcommitment.chklettersentdate.checked = false;
      document.newcommitment.letteraddressee.disabled = true;
      document.newcommitment.letteraddressee.value = "";
      document.newcommitment.letterorganizationid.disabled = true;
      document.newcommitment.letterorganizationid.value = "";
      }

    function enableletter()
      {
      document.newcommitment.letteraccessionnum.disabled = false;
      document.newcommitment.lettersigner.disabled = false;
      document.newcommitment.lettersigneddate_month.disabled = false;
      document.newcommitment.lettersigneddate_day.disabled = false;
      document.newcommitment.lettersigneddate_year.disabled = false;
      document.newcommitment.chklettersigneddate.disabled = false;
      document.newcommitment.lettersentdate_month.disabled = false;
      document.newcommitment.lettersentdate_day.disabled = false;
      document.newcommitment.lettersentdate_year.disabled = false;
      document.newcommitment.chklettersentdate.disabled = false;
      document.newcommitment.letteraddressee.disabled = false;
      document.newcommitment.letterorganizationid.disabled = false;
      }

    function checkletter (letterselection)
      {
      if (letterselection.value!="NEW")
        {
        disableletter();
        }
      else
        {
        enableletter();
        }
      }

    function validate_commitment_data()
      {
      var msg = "";
      var tmpmsg = "";
      var returnvalue = true;
      var validateform = document.newcommitment;
      msg += (validateform.text.value=="") ? "You must enter the commitment text.\\n" : "";
      msg += ((tmpmsg = validate_date(validateform.datewritten_year.value, validateform.datewritten_month.value, validateform.datewritten_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Date Written - " + tmpmsg + "\\n";
      if (! validateform.chkduedate.checked)
        msg += ((tmpmsg = validate_date(validateform.duedate_year.value, validateform.duedate_month.value, validateform.duedate_day.value, 0, 0, 0, 0, true, true, false)) == "") ? "" : "Due Date - " + tmpmsg + "\\n";
      if (! validateform.chkcommitdate.checked)
        msg += ((tmpmsg = validate_date(validateform.commitdate_year.value, validateform.commitdate_month.value, validateform.commitdate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Commit Date - " + tmpmsg + "\\n";
      if (! validateform.chkcommitmentlevelid.checked)
        msg += (validateform.commitmentlevelid.value=="") ? "You must select a commitment level.\\n" : "";
      if (! validateform.chkactionsummary.checked)
        msg += (validateform.actionsummary.value=="") ? "You must enter an action summary.\\n" : "";
      if (! validateform.chkfunctionalrecommend.checked)
        msg += (validateform.functionalrecommend.value=="") ? "You must enter the DOE Functional Lead recommendation.\\n" : "";
      if (! validateform.chkactionplan.checked)
        msg += (validateform.actionplan.value=="") ? "You must enter the action plan.\\n" : "";
      if (! validateform.chkcmrecommendation.checked)
        msg += (validateform.cmrecommendation.value=="") ? "You must enter the Commitment Manager's recomemndation.\\n" : "";
      if (! validateform.chkworkbreakdownstructure.checked)
        msg += (validateform.workbreakdownstructure.selectedIndex == -1) ? "You must select a Work Breakdown Structure.\\n" : "";
      if (! validateform.chkcommitmentrationale.checked)
        msg += (validateform.commitmentrationale.value=="") ? "You must enter the rationale for making this commitment.\\n" : "";
      msg += (validateform.approver.value=="NULL") ? "You must specify the approver of this commitment.\\n" : "";
      if (! validateform.chkactionstaken.checked)
        msg += (validateform.actionstaken.value=="") ? "You must enter the actions taken in performint this commitment.\\n" : "";
      if (! validateform.chkclosuredate.checked)
        msg += ((tmpmsg = validate_date(validateform.closuredate_year.value, validateform.closuredate_month.value, validateform.closuredate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Closure Date - " + tmpmsg + "\\n";
      msg += (validateform.primarydiscipline.value=='') ? "You must select the primary discipline for this issue.\\n" : "";
      msg += (validateform.secondarydiscipline.value=='') ? "You must select the secondary discipline for this issue.\\n" : "";
      msg += (validateform.statusid.value=="NULL") ? "You must specify the status of this commitment.\\n" : "";
      msg += (validateform.committedto.selectedindex==-1) ? "You must select the organization(s) the commitment was made to.\\n" : "";
      msg += (validateform.doefunctionallead.value=="") ? "You must specify the DOE Functional Lead of this commitment.\\n" : "";
      msg += (validateform.doecommitmentcoordinator.value=="") ? "You must specify the DOE Commitment Coordinator of this commitment.\\n" : "";
      msg += (validateform.doecommitmentmanager.value=="") ? "You must specify the DOE Commitment Manager of this commitment.\\n" : "";
      msg += (validateform.commitmentmaker.value=="") ? "You must specify the Commitment Maker of this commitment.\\n" : "";
      msg += (validateform.mofunctionallead.value=="") ? "You must specify the M&O Functional Lead of this commitment.\\n" : "";
      msg += (validateform.mocommitmentcoordinator.value=="") ? "You must specify the M&O Commitment Coordinator of this commitment.\\n" : "";
      msg += (validateform.mocommitmentmanager.value=="") ? "You must specify the M&O Commtiment Manager of this commitment.\\n" : "";
      if (validateform.letterid.value=="NEW")
        {
        msg += ((tmpmsg = validate_accession_number(validateform.letteraccessionnum.value)) == "") ? "" : "Letter Accession Number - " + tmpmsg + "\\n";
        msg += ((tmpmsg = validate_date(validateform.lettersentdate_year.value, validateform.lettersentdate_month.value, validateform.lettersentdate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Letter Sent Date - " + tmpmsg + "\\n";
        msg += (validateform.letteraddressee.value=="") ? "You must enter the addressee of the letter.\\n" : "";
        msg += ((tmpmsg = validate_date(validateform.lettersigneddate_year.value, validateform.lettersigneddate_month.value, validateform.lettersigneddate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Letter Signed Date - " + tmpmsg + "\\n";
        msg += (validateform.lettersigner.value=="") ? "You must select the signer of the letter.\\n" : "";
        msg += (validateform.letterorganizationid.value=='') ? "You must select the organization the letter was sent to.\\n" : "";
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
  </head>
  <body>
  <form name=newcommitment method=post target="control" action="/cgi-bin/oncs/enter_commitment_based_on_issue.pl" onsubmit="return(validate_commitment_data())">
  <input name=cgiaction type=hidden value="save_commitment">
  <table summary="Enter Commitment Table" width=100% border=1>
  <tr>
    <th colspan=3 align=center>
    Old Commitment Entry
    </th>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Commitment Text</b>
    </td>
    <td width=70% colspan=2 align=left>
    <textarea name=text cols=65 rows=5></textarea>
    <input name=loginusersid type=hidden value=$usersid>
    <input name=loginusername type=hidden value=$username>
    <input name=issueid type=hidden value=$issueid>
    </td>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Date Written</b>
    </td>
    <td width=70% align=left colspan=2>
committable0
  print build_date_selection('datewritten', 'newcommitment');
print <<committable1;
    </td>
<!--     <td width=10% align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chkdatewritten, 6, document.newcommitment.datewritten_month, document.newcommitment.datewritten_day, document.newcommitment.datewritten_year, document.newcommitment.datewritten)" name=chkdatewritten value=1>
    </td> -->
  </tr>
  <tr>
    <td align=center width=20%>
    <b>Due Date</b>
    </td>
    <td align=left width=70%>
committable1
  print build_date_selection('duedate', 'newcommitment');
  print <<committable2;
    </td>
    <td align=center width=10%>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chkduedate, 6, document.newcommitment.duedate_month, document.newcommitment.duedate_day, document.newcommitment.duedate_year, document.newcommitment.duedate)" name=chkduedate value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Date of Commitment</b>
    </td>
    <td>
committable2
  print build_date_selection('commitdate', 'newcommitment');
  print <<committable2b;
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chkcommitdate, 6, document.newcommitment.commitdate_month, document.newcommitment.commitdate_day, document.newcommitment.commitdate_year, document.newcommitment.commitdate)" name=chkcommitdate value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Level of Commitment</b>
    </td>
    <td>
    <select name=commitmentlevelid>
    <option value='' selected>Select a Level of Commitment
committable2b
  foreach $key (sort keys %commitmentlevelhash)
    {
    print "    <option value=\"$commitmentlevelhash{$key}\">$key\n";
    }
  print <<committable3;
    </select>
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chkcommitmentlevelid, 3, document.newcommitment.commitmentlevelid)" name=chkcommitmentlevelid value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Action Summary</b>
    </td>
    <td>
    <textarea name=actionsummary cols=65 rows=5></textarea>
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chkactionsummary, 3, document.newcommitment.actionsummary)" name=chkactionsummary value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Work Estimate</b>
    </td>
    <td colspan=2>
    <textarea name=estimate cols=65 rows=5></textarea>
    <br>
    (Optional, leave blank if not available)
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>DOE Functional Lead Recommendation</b>
    </td>
    <td>
    <textarea name=functionalrecommend cols=65 rows=5></textarea>
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chkfunctionalrecommend, 3, document.newcommitment.functionalrecommend)" name=chkfunctionalrecommend value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Action Plan</b>
    </td>
    <td>
    <textarea name=actionplan cols=65 rows=5></textarea>
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chkactionplan, 3, document.newcommitment.actionplan)" name=chkactionplan value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Products Affected</b>
    </td>
    <td>
    <select name=productsaffected size=5 multiple>
committable3
  foreach $key (sort keys %productshash)
    {
    print "    <option value=\"$productshash{$key}\">$key\n";
    }
  print <<committable4;
    </select><br>
    Hold the Control key while clicking to select more than one.<br>
    (Optional, if no products are affected, leave blank.  Do not check "Not Available" unless products are affected, but exactly which are currently unkonwn)
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chkproductsaffected, 3, document.newcommitment.productsaffected)" name=chkproductsaffected value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>DOE Commitment Manager Recommendation</b>
    </td>
    <td>
    <textarea name=cmrecommendation cols=65 rows=5></textarea>
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chkcmrecommendation, 3, document.newcommitment.cmrecommendation)" name=chkcmrecommendation value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Work Breakdown Structure</b>
    </td>
    <td>
    <select name=workbreakdownstructure>
committable4
  foreach $key (sort keys %wbshash)
    {
    my $wbsdisplaystring = getDisplayString($wbshash{$key}, 80);
    print "    <option value=\"$key\">$key -- $wbsdisplaystring\n";
    }
  print <<committable5;
    </select>
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chkworkbreakdownstructure, 3, document.newcommitment.workbreakdownstructure)" name=chkworkbreakdownstructure value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Commitment Rationale</b>
    </td>
    <td>
    <textarea name=commitmentrationale cols=65 rows=5></textarea>
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chkcommitmentrationale, 3, document.newcommitment.commitmentrationale)" name=chkcommitmentrationale value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Approver</b>
    </td>
    <td colspan=2>
    <select name=approver>
    <option value=NULL selected>Select an Approver
committable5
  foreach $key (sort keys %usershash)
    {
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\">$usernamestring\n";
    }
  print <<committable6;
    </select>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Actions Taken</b>
    </td>
    <td>
    <textarea name=actionstaken cols=65 rows=5></textarea>
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chkactionstaken, 3, document.newcommitment.actionstaken)" name=chkactionstaken value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Date Closed</b>
    </td>
    <td>
committable6
  print build_date_selection('closuredate', 'newcommitment');
  print <<committable7;
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chkclosuredate, 6, document.newcommitment.closuredate_month, document.newcommitment.closuredate_day, document.newcommitment.closuredate_year, document.newcommitment.closuredate)" name=chkclosuredate value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Comments</b>
    </td>
    <td colspan=2>
    <textarea name=comments cols=65 rows=5></textarea>
    <br>
    (Optional, leave blank if not available)
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Status</b>
    </td>
    <td colspan=2>
    <select name=statusid>
    <option value=NULL selected>Select a Status
committable7
  foreach $key (sort keys %statushash)
    {
    print "    <option value=\"$statushash{$key}\">$key\n";
    }
  print <<committable8;
    </select>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Replaced By</b>
    </td>
    <td colspan=2>
    <select name=replacedby>
    <option value=NULL selected>Not Replaced
committable8
  foreach $key (sort keys %commitmenthash)
    {
    $commitmentstring = $commitmenttexthash{$commitmenthash{$key}} . "--" . $key;
    $commitmentstring =~ s/;$commitmenthash{$key}//g;
    print "    <option value=\"$commitmenthash{$key}\">$commitmentstring\n";
    }
  print <<committable9;
    </select>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Organizations Committed To</b>
    </td>
    <td colspan=2>
    <table border=0 summary="Current Data">
      <tr align=Center>
        <td>
        <b>Organization List</b>
        </td>
        <td>&nbsp;
        </td>
        <td>
        <b>Committed To</b>
        </td>
      </tr>
      <tr>
        <td>
        <select name=allorganizationlist size=5 multiple ondblclick="process_multiple_dual_select_option(document.newcommitment.allorganizationlist, document.newcommitment.committedto, 'move')">
committable9
  foreach $key (sort keys %orghash)
    {
    my $orgdescription = $key;
    $orgdescription =~ s/;$orghash{$key}//g;
    print "        <option value=\"$orghash{$key}\">$orgdescription\n";
    }
#print &build_dual_select( (element name), (form name), \(hash of available values/names), \(hash of selected values/names), (name of available box (left side)), (name of selected box (right side)) [, (locked value)[, (locked value)[, (locked value) [...]]]] );
print <<committable10;
        <option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
        </select>
        </td>
        <td>
        <input name=leftarrow title="click to remove the selected organization(s)" value="<--" type=button onclick="process_multiple_dual_select_option(document.newcommitment.committedto, document.newcommitment.allorganizationlist, 'move')">
        <br>
        <input name=rightarrow title="click to commit to the selected organization(s)" value="-->" type=button onclick="process_multiple_dual_select_option(document.newcommitment.allorganizationlist, document.newcommitment.committedto, 'move')">
        </td>
        <td>
        <select name=committedto size=5 multiple ondblclick="process_multiple_dual_select_option(document.newcommitment.committedto, document.newcommitment.allorganizationlist, 'move')">
        <option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
        </select>
        </td>
      </tr>
    </table>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Keywords</b>
    </td>
    <td colspan=2>
    <table border=0 summary="Commitment Keywords">
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
        <select name=allkeywordlist size=5 multiple ondblclick="process_multiple_dual_select_option(document.newcommitment.allkeywordlist, document.newcommitment.keywords, 'move')">
committable10
  foreach $key (sort keys %keywordhash)
    {
    print "        <option value=\"$keywordhash{$key}\">$key\n";
    }
print <<committable11;
        <option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
        </select>
        </td>
        <td>
        <input name=keywordleftarrow title="Click to remove the selected keyword(s)" value="<--" type=button onclick="process_multiple_dual_select_option(document.newcommitment.keywords, document.newcommitment.allkeywordlist, 'move')">
        <br>
        <input name=keywordrightarrow title="Click to select the keyword(s)" value="-->" type=button onclick="process_multiple_dual_select_option(document.newcommitment.allkeywordlist, document.newcommitment.keywords, 'move')">
        </td>
        <td>
        <select name=keywords size=5 multiple ondblclick="process_multiple_dual_select_option(document.newcommitment.keywords, document.newcommitment.allkeywordlist, 'move')">
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
    <b>Old Id Number</b>
    </td>
    <td colspan=2>
    <input type=text name=oldid maxlength=20 size=20>
    <br>
    (Optional, leave blank if not available)
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Primary Discipline</b>
    </td>
    <td align=left>
    <select name=primarydiscipline>
    <option value='' selected>Select a Primary Discipline
    <option value=NULL>Not Available
committable11
    foreach $key (sort keys %disciplinehash)
      {
      print "<option value=\"$disciplinehash{$key}\">$key\n";
      }
print <<committable12;
    </select>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Secondary Discipline</b>
    </td>
    <td align=left>
    <select name=secondarydiscipline>
    <option value='' selected>Select a Secondary Discipline
    <option value=NULL>Not Available
committable12
    foreach $key (sort keys %disciplinehash)
      {
      print "<option value=\"$disciplinehash{$key}\">$key\n";
      }
print <<committable13;
    </select>
    </td>
  </tr>
  </table>
committable13

#Print The Role Assignment Table
  print <<assigntable1;
  <br><br>
  <table summary="Role Assignment for this commitment" width=100% border=1>
  <tr>
    <th colspan=2>
    <b>Assign Roles</b>
    </th>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>DOE Functional Lead</b>
    </td>
    <td width=80% align=left>
    <select name=doefunctionallead>
    <option value='' selected>Select the DOE Functional Lead
    <option value=NULL>Not Available
assigntable1
  foreach $key (sort keys %usershash)
    {
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\">$usernamestring\n";
    }
  print <<assigntable2;
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>DOE Commitment Coordinator</b>
    </td>
    <td align=left>
    <select name=doecommitmentcoordinator>
    <option value='' selected>Select the DOE Commitment Coordinator
    <option value=NULL>Not Available
assigntable2
  foreach $key (sort keys %usershash)
    {
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\">$usernamestring\n";
    }
  print <<assigntable3;
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>DOE Commitment Manager</b>
    </td>
    <td align=left>
    <select name=doecommitmentmanager>
    <option value='' selected>Select the DOE Commitment Manager
    <option value=NULL>Not Available
assigntable3
  foreach $key (sort keys %usershash)
    {
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\">$usernamestring\n";
    }
  print <<assigntable4;
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Commitment Maker</b>
    </td>
    <td align=left>
    <select name=commitmentmaker>
    <option value='' selected>Select the Commitment Maker
    <option value=NULL>Not Available
assigntable4
  foreach $key (sort keys %usershash)
    {
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\">$usernamestring\n";
    }
  print <<assigntable5;
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>M&amp;O Functional Lead</b>
    </td>
    <td align=left>
    <select name=mofunctionallead>
    <option value='' selected>Select the M&amp;O Functional Lead
    <option value=NULL>Not Available
assigntable5
  foreach $key (sort keys %usershash)
    {
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\">$usernamestring\n";
    }
  print <<assigntable6;
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>M&amp;O Commitment Coordinator</b>
    </td>
    <td align=left>
    <select name=mocommitmentcoordinator>
    <option value='' selected>Select the M&amp;O Commitment Coordinator
    <option value=NULL>Not Available
assigntable6
  foreach $key (sort keys %usershash)
    {
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\">$usernamestring\n";
    }
  print <<assigntable7;
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>M&amp;O Commitment Manager</b>
    </td>
    <td align=left>
    <select name=mocommitmentmanager>
    <option value='' selected>Select the M&amp;O CommitmentManager
    <option value=NULL>Not Available
assigntable7
  foreach $key (sort keys %usershash)
    {
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\">$usernamestring\n";
    }
  print <<assigntable8;
    </td>
  </tr>
  </table>
assigntable8

# Print the Response Letter Table
print <<lettertable0;
  <br><br>
  <table summary="Response Letter Table" width=100% border=1>
  <tr>
    <th colspan=3 align=center>
    Letter Information
    </th>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Letter Selection</b>
    </td>
    <td width=70% align=left colspan=2>
    <select name=letterid onChange="checkletter(document.newcommitment.letterid)">
    <option value='' selected>Select a Commitment Letter
    <option value="NEW">New Letter
    <option value="NULL">No Letter Available (potential Commitment)
lettertable0
  foreach $key (sort keys %letterhash)
    {
    my $letterdescription = $key;
    $letterdescription =~ s/;$letterhash{$key}//g;
    if (length($letterdescription) > 80)
      {
      $letterdescription = substr($letterdescription, 0, 80) . '...';
      }
    print "<option value=\"$letterhash{$key}\">$letterdescription\n";
    }
  print <<lettertable1;
    </select>
    </td>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Accession Number</b>
    </td>
    <td width=70% colspan=2 align=left>
    <input name=letteraccessionnum size=17 maxlength=17>
    </td>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Sent Date</b>
    </td>
    <td width=70% align=left>
lettertable1
  print build_date_selection('lettersentdate', 'newcommitment');
  print <<lettertable2;
    </td>
    <td width=10% align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chklettersentdate, 6, document.newcommitment.lettersentdate_month, document.newcommitment.lettersentdate_day, document.newcommitment.lettersentdate_year, document.newcommitment.lettersentdate)" name=chklettersentdate value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Addressee</b>
    </td>
    <td colspan=2 align=left>
    <input name=letteraddressee size=17 maxlength=17>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Signed Date</b>
    </td>
    <td align=left>
lettertable2
  print build_date_selection('lettersigneddate', 'newcommitment');
  print <<lettertable3;
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.newcommitment.chklettersigneddate, 6, document.newcommitment.lettersigneddate_month, document.newcommitment.lettersigneddate_day, document.newcommitment.lettersigneddate_year, document.newcommitment.lettersigneddate)" name=chklettersigneddate value=1>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Signer</b>
    </td>
    <td colspan=2>
    <select name=lettersigner>
    <option value=NULL selected>Select the Signer
lettertable3
  foreach $key (sort keys %usershash)
    {
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\">$usernamestring\n";
    }
  print <<lettertable4;
    </select>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Organization Sent To</b>
    </td>
    <td colspan=2 align=left>
    <select name=letterorganizationid>
    <option value='' selected>Select An Organization
lettertable4
  foreach $key (sort keys %orghash)
    {
    my $orgdescription = $key;
    $orgdescription =~ s/;$orghash{$key}//g;
    print "    <option value=\"$orghash{$key}\">$orgdescription\n";
    }
  print <<lettertable5;
    </select>
    </td>
  </tr>
  </table>
  <br>
  <input type=submit name=submit value="Submit This Commitment" title="Submit This Commitment" onclick="selectemall(document.newcommitment.committedto);selectemall(document.newcommitment.keywords);">
  </form>
  </body>
  </html>
  <script language="JavaScript" type="text/javascript"><!--
    disableletter();
  //-->
  </script>
lettertable5
  &oncs_disconnect($dbh);
  exit 1;
  }
print "</head>\n\n";
print "<body>\n";
print "<center><h1>$pagetitle</h1></center>\n";
print "<form action=\"/cgi-bin/oncs/readoldcommitments.pl\" enctype=\"multipart/form-data\" method=post name=issueselection onsubmit=\"return(true)\">\n";
$dbh->{LongReadLen} = $TitleLength;
$dbh->{LongTruncOk} = 1;
my %issuehash = get_lookup_values($dbh, 'issue', "TO_CHAR(entereddate, 'MM/DD/YYYY') || ' - ' || ';' || issueid", 'issueid', 'issuetypeid=1');
my %issuetexthash = get_lookup_values ($dbh, 'issue', 'issueid', 'text');
$dbh->{LongTruncOk} = 0;
my $key;
#display the old issue form
print <<issueselectionform1;
<input name=cgiaction type=hidden value="query_issue">
<select name=issueselect size=10>
issueselectionform1
foreach $key (sort keys %issuehash)
  {
  my $issuedescription = $key;
  $issuedescription =~ s/;$issuehash{$key}/$issuetexthash{$issuehash{$key}}/g;
  print "<option value=\"$issuehash{$key}\">" . getDisplayString($issuedescription, 80) . "\n";
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
print "<input name=submit type=submit value=\"Submit Changes\">\n";
print "</form>\n";
# menu to return to the maintenance menu and the main screen
#print "<ul title=\"Link Menu\"><b>Link Menu</b>\n<li><a href=\"/dcmm/prototype/maintenance.htm\">Maintenance Screen</a></li>\n";
#print "<li><a href=\"/dcmm/prototype/home.htm\">Main Menu</a></li>\n";
#print "</ul><br><br>\n";
print "</body>\n";
print "</html>\n";
