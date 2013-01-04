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
use Tie::IxHash;

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
$pagetitle = "View/Modify Commitment";
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
      location = '/cgi-bin/oncs/oncs_user_login.pl';
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
if (($cgiaction eq "query_commitment") || ($cgiaction eq "report_popup"))
  {
  my $commitmentid;
  my $commitmentidstring;
  my %commitmenthash;
    
  my $duedate;
  my $statusid;
  my $status;
  my $commitdate;
  my $criticalpath;
  my $estimate;
  my $functionalrecommend;
  my $commitmentrationale;
  my $closingdocimage;
  my $text;
  my $comments;
  my $rejectionrationale;
  my $resubmitrationale;
  my $actionstaken;
  my $actionsummary;
  my $actionplan;
  my $cmrecommendation;
  my $closeddate;
  my $changerequestnum;
  my $controlaccountid;
  my $issueid;
  my $approver;
  my $approvername;
  my $replacedby;
  my $updatedby;
  my $updatedbyname;
  my $commitmentlevelid;
  my $commitmentlevel;
  my $oldid;
  my $primarydiscipline;
  my $primarydisciplinename;
  my $secondarydiscipline;
  my $secondarydisciplinename;
  my @committedto;
  my @keywords;
  my @productsaffected;
  my $arrayvalue;
  my %roleshash;

  my $textareawidth = ($cgiaction eq "query_commitment") ? 80 : 60;
    
  $commitmentid = $testout->param('commitmentid');
  $commitmentidstring = substr("0000$commitmentid", -5);
  %commitmenthash = get_commitment_info($dbh, $commitmentid);
  $duedate = $commitmenthash{'duedate'};
  $statusid = $commitmenthash{'statusid'};
  $commitdate = $commitmenthash{'commitdate'};
  $criticalpath = $commitmenthash{'criticalpath'};
  $estimate = $commitmenthash{'estimate'};
  $functionalrecommend = $commitmenthash{'functionalrecommend'};
  $commitmentrationale = $commitmenthash{'commitmentrationale'};
  $text = $commitmenthash{'text'};
  $comments = $commitmenthash{'comments'};
  $rejectionrationale = $commitmenthash{'rejectionrationale'};
  $resubmitrationale = $commitmenthash{'resubmitrationale'};
  $actionstaken = $commitmenthash{'actionstaken'};
  $actionsummary = $commitmenthash{'actionsummary'};
  $actionplan = $commitmenthash{'actionplan'};
  $cmrecommendation = $commitmenthash{'cmrecommendation'};
  $closeddate = $commitmenthash{'closeddate'};
  $changerequestnum = $commitmenthash{'changerequestnum'};
  $controlaccountid = $commitmenthash{'controlaccountid'};
  $issueid = $commitmenthash{'issueid'};
  $approver = $commitmenthash{'approver'};
  $replacedby = $commitmenthash{'replacedby'};
  $updatedby = $commitmenthash{'updatedby'};
  $commitmentlevelid = $commitmenthash{'commitmentlevelid'};
  $oldid = $commitmenthash{'oldid'};
  $primarydiscipline = $commitmenthash{'primarydiscipline'};
  $secondarydiscipline = $commitmenthash{'secondarydiscipline'};
  
  $commitmentlevel = ($commitmentlevelid) ? lookup_single_value($dbh, "commitmentlevel", "description", $commitmentlevelid) : "";
  $approvername = ($approver) ? lookup_single_value($dbh, "users", "lastname || ', ' || firstname", $approver) : "";
  $status = ($statusid) ? lookup_single_value($dbh, "status", "description", $statusid) : "";
  $updatedbyname = ($updatedbyname) ? lookup_single_value($dbh, "users", "lastname || ', ' || firstname", $updatedby): "";
  $primarydisciplinename = ($primarydiscipline) ? lookup_single_value($dbh, "discipline", "description", $primarydiscipline) : "";
  $secondarydisciplinename = ($secondarydiscipline) ? lookup_single_value($dbh, "discipline", "description", $secondarydiscipline) : "";
  
  @committedto = lookup_column_values($dbh, "committedorg", "organizationid", "commitmentid = $commitmentid", "organizationid");
  @keywords = lookup_column_values($dbh, "commitmentkeyword", "keywordid", "commitmentid = $commitmentid", "keywordid");
  @productsaffected = lookup_column_values($dbh, "productaffected", "productid", "commitmentid = $commitmentid", "productid");

  %roleshash = get_lookup_values($dbh, "commitmentrole", "roleid", "usersid", "commitmentid = $commitmentid");

  #get role ids
  my $doeflroleid = lookup_role_by_name($dbh, "DOE Functional Lead");
#  my $doeccroleid = lookup_role_by_name($dbh, "DOE Commitment Coordinator");
#  my $doecmgrroleid = lookup_role_by_name($dbh, "DOE Commitment Manager");
#  my $cmroleid = lookup_role_by_name($dbh, "Commitment Maker");
  my $moflroleid = lookup_role_by_name($dbh, "M&O Functional Lead");
#  my $moccroleid = lookup_role_by_name($dbh, "M&O Commitment Coordinator");
#  my $mocmgrroleid = lookup_role_by_name($dbh, "M&O Commitment Manager");

  my %usershash = get_lookup_values($dbh, 'users', 'usersid', "lastname || ', ' || firstname");

  print <<commitmentdisplay1;
  </head>
  <body>
  <form name=commitmentquery method=post action="/cgi-bin/oncs/readcommitments.pl">
  <input name=cgiaction type=hidden value="editcommitment">
  <input name=loginusersid type=hidden value=$usersid>
  <input name=loginusername type=hidden value=$username>
  <input name=issueid type=hidden value=$issueid>
  <input name=commitmentid type=hidden value=$commitmentid>
  <table summary="Query Commitment Table" width=100% border=1>
  <tr>
    <th colspan=2 align=center>
    Commitment Information
    </th>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Commitment ID</b>
    </td>
    <td width=80% align=left>
    $commitmentidstring
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Commitment Text</b>
    </td>
    <td align=left>
    <textarea name=text cols=$textareawidth rows=5 onfocus=blur()>$text</textarea>
    </td>
  </tr>
  <tr>
    <td align=center width=20%>
    <b>Due Date</b>
    </td>
    <td align=left width=70%>
    $duedate
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Date of Commitment</b>
    </td>
    <td>
    $commitdate
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Level of Commitment</b>
    </td>
    <td>
    $commitmentlevel
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Primary Functional Discipline</b>
    </td>
    <td>
    $primarydisciplinename
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Secondary Functional Discipline</b>
    </td>
    <td>
    $secondarydisciplinename
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>DOE Functional Lead</b>
    </td>
    <td>
    $usershash{$roleshash{$doeflroleid}}
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>M&amp;O Functional Lead</b>
    </td>
    <td>
    $usershash{$roleshash{$moflroleid}}
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Action Summary</b>
    </td>
    <td>
    <textarea name=actionsummary cols=$textareawidth rows=5 onfocus=blur()>$actionsummary</textarea>
    </td>
  </tr>
commitmentdisplay1
  if ($cgiaction ne "report_popup")
    {
    print <<commitmentdisplay1a;
  <tr>
    <td align=center>
    <b>Work Estimate</b>
    </td>
    <td>
    <textarea name=estimate cols=$textareawidth rows=5 onfocus=blur()>$estimate</textarea>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>DOE Functional Lead Recommendation</b>
    </td>
    <td>
    <textarea name=functionalrecommend cols=$textareawidth rows=5 onfocus=blur()>$functionalrecommend</textarea>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Action Plan</b>
    </td>
    <td>
    <textarea name=actionplan cols=$textareawidth rows=5 onfocus=blur()>$actionplan</textarea>
    </td>
  </tr>
commitmentdisplay1a
    }
  print <<commitmentdisplay1b;
  <tr>
    <td align=center>
    <b>Products Affected</b>
    </td>
    <td>
commitmentdisplay1b
  foreach $arrayvalue (@productsaffected)
    {
    print lookup_single_value($dbh, "product", "description", $arrayvalue) . "<BR>\n";
    }
  print <<commitmentdisplay2;
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>DOE Commitment Manager Recommendation</b>
    </td>
    <td>
    <textarea name=cmrecommendation cols=$textareawidth rows=5 onfocus=blur()>$cmrecommendation</textarea>
    </td>
  </tr>
commitmentdisplay2
  if ($cgiaction ne "report_popup")
    {
    print <<commitmentdisplay2a;
  <tr>
    <td align=center>
    <b>Commitment Rationale</b>
    </td>
    <td>
    <textarea name=commitmentrationale cols=$textareawidth rows=5 onfocus=blur()>$commitmentrationale</textarea>
    </td>
  </tr>
commitmentdisplay2a
    }
  print <<commitmentdisplay2b;
  <tr>
    <td align=center>
    <b>Approver</b>
    </td>
    <td>
    $approvername
    </td>
  </tr>
commitmentdisplay2b
  if ($cgiaction ne "report_popup")
    {
    print <<commitmentdisplay2c;
  <tr>
    <td align=center>
    <b>Actions Taken</b>
    </td>
    <td>
    <textarea name=actionstaken cols=$textareawidth rows=5 onfocus=blur()>$actionstaken</textarea>
    </td>
  </tr>
commitmentdisplay2c
    }
  print <<commitmentdisplay2d;
  <tr>
    <td align=center>
    <b>Date Closed</b>
    </td>
    <td>
    $closeddate
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Comments</b>
    </td>
    <td>
    <textarea name=comments cols=$textareawidth rows=5 onfocus=blur()>$comments</textarea>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Status</b>
    </td>
    <td>
    $status
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Replaced By</b>
    </td>
    <td>
    $replacedby
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Organization(s) Committed To</b>
    </td>
    <td>
commitmentdisplay2d
  foreach $arrayvalue (@committedto)
    {
    print lookup_single_value($dbh, "organization", "name", $arrayvalue) . "<BR>\n";
    }
  print <<commitmentdisplay3;    
    </td>
  </tr>
commitmentdisplay3
  if ($cgiaction ne "report_popup")
    {
    print <<commitmentdisplay3a;
  <tr>
    <td align=center>
    <b>Keywords</b>
    </td>
    <td>
commitmentdisplay3a
    foreach $arrayvalue (@keywords)
      {
      print lookup_single_value($dbh, "keyword", "description", $arrayvalue) . "<BR>\n";
      }
    print <<commitmentdisplay3b;    
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Old Id Number</b>
    </td>
    <td>
    $oldid
    </td>
  </tr>
commitmentdisplay3b
    }
  print "  </table>";
my $oldcommitmentlink = does_user_have_named_priv($dbh, $usersid, 'Enter Old Commitment Data');
if ($cgiaction eq "report_popup")
  {
  print "  <input type=button name=closewindow value=\"Close This Window\" title=\"Click this button to close this popup window.\" onclick=\"self.close()\">\n";
  }
elsif ($oldcommitmentlink == 1)
  {
  print "  <input type=submit name=submit value=\"Edit This Commitment\" title=\"Click this button to edit this commitment.\">\n";
  }
print <<commitmentdisplay5;
  </form>
  </body>
  </html>
commitmentdisplay5
  &oncs_disconnect($dbh);
  exit 1;
  }
  
if ($cgiaction eq "modify_commitment")
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
  my $commitmentid;
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
  $commitmentid = $testout->param('commitmentid');
  $duedate = $testout->param('duedate');
  $duedate = ($duedate eq "") ? "NULL" : "TO_DATE('$duedate', 'MM/DD/YYYY')";
  $statusid = $testout->param('statusid');
  $commitdate = $testout->param('commitdate');
  $commitdate = ($commitdate eq "") ? "NULL" : "TO_DATE('$commitdate', 'MM/DD/YYYY')";
  $criticalpath = 'NULL';
  $estimate = $testout->param('estimate');
  $estimatesql = $estimate ? ":estimateclob" : "NULL";
  $functionalrecommend = $testout->param('functionalrecommend');
  $functionalrecommend = $functionalrecommend ? $functionalrecommend : "Historical Data Not Available.";
  $functionalrecommendsql = $functionalrecommend ? ":functionalrecommendclob" : "NULL";
  $commitmentrationale = $testout->param('commitmentrationale');
  $commitmentrationale = $commitmentrationale ? $commitmentrationale : "Historical Data Not Available.";
  $commitmentrationalesql = $commitmentrationale ? ":commitmentrationaleclob" : "NULL";
#  $closingdocimage = $testout->param('closingdocimage');
  $text = $testout->param('text');
  $textsql = $text ? ":textclob" : "NULL";
  $comments = $testout->param('comments');
  $commentssql = $comments ? ":commentsclob" : "NULL";
#  $rejectionrationale = $testout->param('rejectionrationale');
  $rejectionrationale = "";
  $rejectionrationalesql = $rejectionrationale ? ":rejectionrationaleclob" : "NULL";
#  $resubmitrationale = $testout->param('resubmitrationale');
  $resubmitrationale = "";
  $resubmitrationalesql = $resubmitrationale ? ":resubmitrationaleclob" : "NULL";
  $actionstaken = $testout->param('actionstaken');
  $actionstaken = $actionstaken ? $actionstaken : "Historical Data not Available.";
  $actionstakensql = $actionstaken ? ":actionstakenclob" : "NULL";
  $actionsummary = $testout->param('actionsummary');
  $actionsummary = $actionsummary ? $actionsummary : "Historical Data not Available.";
  $actionsummarysql = $actionsummary ? ":actionsummaryclob" : "NULL";
  $actionplan = $testout->param('actionplan');
  $actionplan = $actionplan ? $actionplan : "Historical Data not Available.";
  $actionplansql = $actionplan ? ":actionplanclob" : "NULL";
  $cmrecommendation = $testout->param('cmrecommendation');
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

  my $thiswbs = $testout->param('workbreakdownstructure');
  $thiswbs =~ m/ \. /;
  $changerequestnum = "'" . $` . "'";
  $controlaccountid = "'" . $' . "'";
  if ($thiswbs eq "")
    {
    $changerequestnum = "NULL";
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
  my $sqlstring = "UPDATE $SCHEMA.$updatetable SET duedate=$duedate, statusid=$statusid, 
                 commitdate=$commitdate, criticalpath=$criticalpath, estimate=$estimatesql, 
                 functionalrecommend=$functionalrecommendsql, commitmentrationale=$commitmentrationalesql, 
                 closingdocimage=$fnameinsertstring, text=$textsql, comments=$commentssql, 
                 rejectionrationale=$rejectionrationalesql, resubmitrationale=$resubmitrationalesql, 
                 actionstaken=$actionstakensql, actionsummary=$actionsummarysql, 
                 actionplan=$actionplansql, cmrecommendation=$cmrecommendationsql,
                 closeddate=$closeddate, changerequestnum=$changerequestnum, 
                 controlaccountid=$controlaccountid, issueid=$issueid, approver=$approver,
                 replacedby=$replacedby, updatedby=$updatedby, commitmentlevelid=$commitmentlevelid, 
                 oldid=$oldid, primarydiscipline=$primarydiscipline, secondarydiscipline=$secondarydiscipline
                 WHERE (commitmentid=$commitmentid)";

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
  my %roleshash;

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
  %roleshash = get_lookup_values($dbh, "commitmentrole", "roleid", "usersid", "commitmentid = $commitmentid");

  #create sql strings for assignments
  my $doeflsqlstring = ($roleshash{$doeflroleid} eq "") ?
                        "INSERT INTO $SCHEMA.commitmentrole VALUES ($commitmentid,
                        $doeflroleid, $doefunctionallead)" :
                        "UPDATE $SCHEMA.commitmentrole SET usersid=$doefunctionallead
                        WHERE (commitmentid=$commitmentid) AND (roleid=$doeflroleid)";
  my $doeccsqlstring = ($roleshash{$doeccroleid} eq "") ? 
                        "INSERT INTO $SCHEMA.commitmentrole VALUES($commitmentid,
                        $doeccroleid, $doecommitmentcoordinator)" :
                        "UPDATE $SCHEMA.commitmentrole SET usersid=$doecommitmentcoordinator
                        WHERE (commitmentid=$commitmentid) AND (roleid=$doeccroleid)";
  my $doecmgrsqlstring = ($roleshash{$doecmgrroleid} eq "") ? 
                        "INSERT INTO $SCHEMA.commitmentrole VALUES($commitmentid,
                        $doecmgrroleid, $doecommitmentmanager)" :
                        "UPDATE $SCHEMA.commitmentrole SET usersid=$doecommitmentmanager
                        WHERE (commitmentid=$commitmentid) AND (roleid=$doecmgrroleid)";
  my $cmsqlstring = ($roleshash{$cmroleid} eq "") ?
                        "INSERT INTO $SCHEMA.commitmentrole VALUES($commitmentid,
                        $cmroleid, $commitmentmaker)":
                        "UPDATE $SCHEMA.commitmentrole SET usersid=$commitmentmaker
                        WHERE (commitmentid=$commitmentid) AND (roleid=$cmroleid)";
  my $moflsqlstring = ($roleshash{$moflroleid} eq "") ? 
                        "INSERT INTO $SCHEMA.commitmentrole VALUES($commitmentid,
                        $moflroleid, $mofunctionallead)" :
                        "UPDATE $SCHEMA.commitmentrole SET usersid=$mofunctionallead
                        WHERE (commitmentid=$commitmentid) AND (roleid=$moflroleid)";
  my $moccsqlstring = ($roleshash{$moccroleid} eq "") ?
                        "INSERT INTO $SCHEMA.commitmentrole VALUES($commitmentid,
                        $moccroleid, $mocommitmentcoordinator)" :                        
                        "UPDATE $SCHEMA.commitmentrole SET usersid=$mocommitmentcoordinator
                        WHERE (commitmentid=$commitmentid) AND (roleid=$moccroleid)";
  my $mocmgrsqlstring = ($roleshash{$mocmgrroleid} eq "") ? 
                        "INSERT INTO $SCHEMA.commitmentrole VALUES($commitmentid,
                        $mocmgrroleid, $mocommitmentmanager)" :
                        "UPDATE $SCHEMA.commitmentrole SET usersid=$mocommitmentmanager
                        WHERE (commitmentid=$commitmentid) AND (roleid=$mocmgrroleid)";                        

# -- JLZ Commented because a new letter definitely won't be created on a commitment edit.
#Gather data relating to the letter containing the response
#  my $letterid = $testout->param('letterid');
#  my $newletterflag = 0;
#  if ($letterid eq "NEW")
#    {
#    $newletterflag = 1;
#    $letterid = get_next_id($dbh, 'letter');
#    }
#  my $letteraccessionnum = $testout->param('letteraccessionnum');
#  $letteraccessionnum = ($letteraccessionnum) ? "'$letteraccessionnum'" : "NULL";
#  my $lettersentdate = $testout->param('lettersentdate');
#  $lettersentdate = ($lettersentdate eq "") ? "NULL" : "TO_DATE('$lettersentdate', 'MM/DD/YYYY')";
#  my $letteraddressee = $testout->param('letteraddressee');
#  $letteraddressee =~ s/'/''/g;
#  $letteraddressee = ($letteraddressee) ? "'$letteraddressee'" : "NULL";
#  my $lettersigneddate = $testout->param('lettersigneddate');
#  $lettersigneddate = ($lettersigneddate eq "") ? "NULL" : "TO_DATE('$lettersigneddate', 'MM/DD/YYYY')";
#  my $letterorganizationid = $testout->param('letterorganizationid');
#  my $lettersigner = $testout->param('lettersigner');
#  my $lettersqlstring = "INSERT INTO $SCHEMA.letter VALUES($letterid, $letteraccessionnum, $lettersentdate,
#                         $letteraddressee, $lettersigneddate, $letterorganizationid, $lettersigner)";

# -- JLZ
# Commented because no commitment response text is available
##Gather data relating to the response (commitment text)
#  my $responseid = get_next_id($dbh, 'response');
#  my $responsetext = $text;
#  my $responsetextsql = $textsql;
#  my $datewritten = $testout->param('datewritten');
#  $datewritten = ($datewritten eq "") ? "NULL" : "TO_DATE('$datewritten', 'MM/DD/YYYY')";
#  my $responsesqlstring = "INSERT INTO $SCHEMA.response VALUES($responseid, $responsetextsql,
#                           $datewritten, $commitmentid, $letterid)";
                           
  #edit commitment in database
  $activity = "Edit a commitment: $commitmentid.";
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
      $activity = "Create DOE FL Role for Commitment: $commitmentid.";
      $csr = $dbh->prepare($doeflsqlstring);
      $csr->execute;
      }
    if ($doecommitmentcoordinator ne "NULL")
      {
      $activity = "Create DOE CC Role for Commitment: $commitmentid.";
      $csr = $dbh->prepare($doeccsqlstring);
      $csr->execute;
      }
    if ($doecommitmentmanager ne "NULL")
      {
      $activity = "Create DOE CMgr Role for Commitment: $commitmentid.";
      $csr = $dbh->prepare($doecmgrsqlstring);
      $csr->execute;
      }
    if ($commitmentmaker ne "NULL")
      {
      $activity = "Create Commitment Maker Role for Commitment: $commitmentid.";
      $csr = $dbh->prepare($cmsqlstring);
      $csr->execute;
      }
    if ($mofunctionallead ne "NULL")
      {
      $activity = "Create M\&O FL Role for Commitment: $commitmentid.";
      $csr = $dbh->prepare($moflsqlstring);
      $csr->execute;
      }
    if ($mocommitmentcoordinator ne "NULL")
      {
      $activity = "Create M\&O CC Role for Commitment: $commitmentid.";
      $csr = $dbh->prepare($moccsqlstring);
      $csr->execute;
      }
    if ($mocommitmentmanager ne "NULL")
      {
      $activity = "Create M\&O CMgr Role for Commitment: $commitmentid.";
      $csr = $dbh->prepare($mocmgrsqlstring);
      $csr->execute;
      }

#    #add letter for this commitment if necessary
#    if ($newletterflag == 1)
#      {
#      $activity = "Create Letter for commitment: $commitmentid, response: $responseid.";
#      $csr = $dbh->prepare($lettersqlstring);
#      $csr->execute;
#      }

#    #add commitment response (commitment text as in respone letter)
#    $activity = "Add response $responseid to commitment: $commitmentid.";
#    $csr = $dbh->prepare($responsesqlstring);
#    if ($responsetext)
#      {
#      $csr->bind_param(":textclob", $responsetext, {ora_type => ORA_CLOB, ora_field => 'text' });
#      }
# -- JLZ    $csr->execute;   
   
    # update committed to records.
    my $dualhistory = $testout->param('orghist');
    $dualhistory =~ s/\s+//;
    $activity = "Update organizations committed to for commitment: $commitmentid";
    while (my $histitem = substr($dualhistory, 0, index($dualhistory, ';')))
      {
      my $committedorgsqlstring;
      $dualhistory = substr($dualhistory, (index($dualhistory, ';') + 1));
      if ($histitem =~ /committedto/i)
        {
        $activity .= " adding organization: " . substr($histitem, 0, index($histitem, '-->')) . ".";
        $committedorgsqlstring = "INSERT INTO $SCHEMA.committedorg VALUES ($commitmentid, " . substr($histitem, 0, index($histitem, '-->')) . ")";
        }
      else
        {
        $activity .= " removing organization: " . substr($histitem, 0, index($histitem, '-->')) . ".";
        $committedorgsqlstring = "DELETE $SCHEMA.committedorg WHERE (commitmentid = $commitmentid) AND (organizationid = " . substr($histitem, 0, index($histitem, '-->')) . ")";
        }
      #print "$committedorgsqlstring<br>\n";
      $csr = $dbh->prepare($committedorgsqlstring);
      $csr->execute;
      }

    # update commitment keywords.
    my $dualhistory = $testout->param('keyhist');
    $dualhistory =~ s/\s+//;
    $activity = "Update keywords for commitment: $commitmentid";
    while (my $histitem = substr($dualhistory, 0, index($dualhistory, ';')))
      {
      my $keywordsqlstring;
      $dualhistory = substr($dualhistory, (index($dualhistory, ';') + 1));
      if ($histitem =~ /keywords/i)
        {
        $activity .= " adding keyword: " . substr($histitem, 0, index($histitem, '-->')) . ".";
        $keywordsqlstring = "INSERT INTO $SCHEMA.commitmentkeyword VALUES ($commitmentid, " . substr($histitem, 0, index($histitem, '-->')) . ")";
        }
      else
        {
        $activity .= " removing keyword: " . substr($histitem, 0, index($histitem, '-->')) . ".";
        $keywordsqlstring = "DELETE $SCHEMA.commitmentkeyword WHERE (commitmentid = $commitmentid) AND (keywordid = " . substr($histitem, 0, index($histitem, '-->')) . ")";
        }
      #print "$keywordsqlstring<br>\n";
      $csr = $dbh->prepare($keywordsqlstring);
      $csr->execute;
      }
    $csr->finish;
    };
  if ($@)
    {
    $dbh->rollback;
    my $alertstring = errorMessage($dbh, $username, $usersid, 'commitment', $commitmentid, $activity, $@);
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
    my $dualhistory = $testout->param('prodhist');
    $dualhistory =~ s/\s+//;
    $activity = "Update products for commitment: $commitmentid";
    while (my $histitem = substr($dualhistory, 0, index($dualhistory, ';')))
      {
      eval
        {
        my $productsqlstring;
        $dualhistory = substr($dualhistory, (index($dualhistory, ';') + 1));
        if ($histitem =~ /productsaffected/i)
          {
          $activity .= " removing product: " . substr($histitem, 0, index($histitem, '-->')) . ".";
          $productsqlstring = "INSERT INTO $SCHEMA.productaffected VALUES (" . substr($histitem, 0, index($histitem, '-->')) . ", $commitmentid)";
          }
        else
          {
          $activity .= " removing product: " . substr($histitem, 0, index($histitem, '-->')) . ".";
          $productsqlstring = "DELETE $SCHEMA.productaffected WHERE (commitmentid = $commitmentid) AND (productid = " . substr($histitem, 0, index($histitem, '-->')) . ")";
          }
        #print "$productsqlstring<br>\n";
        my $csr = $dbh->prepare($productsqlstring);
        $csr->execute;
        $csr->finish;
        };
      if ($@)
        {
        $errorfree = 0;
        $dbh->rollback;
        my $alertstring = errorMessage($dbh, $username, $usersid, 'productaffected', "$productid . $commitmentid", $activity, $@);
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
      &log_history($dbh, "Commitment Edited", 'F', $usersid, 'commitment', $commitmentid, "Commitment $commitmentid was modified by user $username.");
      print <<pageresults;
      <script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="/cgi-bin/oncs/readcommitments.pl?loginusersid=$usersid&loginusername=$username";
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
  my %wbshash = get_lookup_values($dbh, 'workbreakdownstructure', "changerequestnum || ' . ' || controlaccountid", "description");
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
    print "    <option value=\"$key\">$key -- $wbshash{$key}\n";
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
    <td width=20% align=center>
    <b>Organization Sent To</b>
    </td>
    <td width=80% align=left>
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
  
if ($cgiaction eq "editcommitment")
  {
  my $commitmentid;
  my $commitmentidstring;
  my %commitmenthash;
    
  my $duedate;
  my $duedateavailchk;
  my $statusid;
  my $status;
  my $commitdate;
  my $commitdateavailchk;
  my $criticalpath;
  my $estimate;
  my $functionalrecommend;
  my $commitmentrationale;
  my $closingdocimage;
  my $text;
  my $comments;
  my $rejectionrationale;
  my $resubmitrationale;
  my $actionstaken;
  my $actionsummary;
  my $actionplan;
  my $cmrecommendation;
  my $closeddate;
  my $closeddateavailchk;
  my $changerequestnum;
  my $controlaccountid;
  my $wbsavailchk;
  my $issueid;
  my $approver;
  my $approvername;
  my $replacedby;
  my $updatedby;
  my $updatedbyname;
  my $commitmentlevelid;
  my $commitmentlevelavailchk;
  my $commitmentlevel;
  my $oldid;
  my $primarydiscipline;
  my $secondarydiscipline;
  my %committedtohash;
  my %keywordsusedhash;
  my %productsaffectedhash;
  my %roleshash;
  my $arrayvariable;

  my $textareawidth = ($cgiaction eq "query_commitment") ? 80 : 60;
    
  $commitmentid = $testout->param('commitmentid');
  $commitmentidstring = substr("0000$commitmentid", -5);
  %commitmenthash = get_commitment_info($dbh, $commitmentid);
  $duedate = $commitmenthash{'duedate'};
  $duedateavailchk = ($duedate) ? "" : "checked";
  $statusid = $commitmenthash{'statusid'};
  $commitdate = $commitmenthash{'commitdate'};
  $commitdateavailchk = ($commitdate) ? "" : "checked";
  $criticalpath = $commitmenthash{'criticalpath'};
  $estimate = $commitmenthash{'estimate'};
  $functionalrecommend = $commitmenthash{'functionalrecommend'};
  $commitmentrationale = $commitmenthash{'commitmentrationale'};
  $text = $commitmenthash{'text'};
  $comments = $commitmenthash{'comments'};
  $rejectionrationale = $commitmenthash{'rejectionrationale'};
  $resubmitrationale = $commitmenthash{'resubmitrationale'};
  $actionstaken = $commitmenthash{'actionstaken'};
  $actionsummary = $commitmenthash{'actionsummary'};
  $actionplan = $commitmenthash{'actionplan'};
  $cmrecommendation = $commitmenthash{'cmrecommendation'};
  $closeddate = $commitmenthash{'closeddate'};
  $closeddateavailchk = ($closeddate) ? "" : "checked";
  $changerequestnum = $commitmenthash{'changerequestnum'};
  $controlaccountid = $commitmenthash{'controlaccountid'};
  $wbsavailchk = (($changerequestnum eq "") && ($controlaccountid eq "")) ? "checked" : "";
  $issueid = $commitmenthash{'issueid'};
  $approver = $commitmenthash{'approver'};
  $replacedby = $commitmenthash{'replacedby'};
  $updatedby = $commitmenthash{'updatedby'};
  $commitmentlevelid = $commitmenthash{'commitmentlevelid'};
  $commitmentlevelavailchk = ($commitmentlevelid) ? "" : "checked";
  $oldid = $commitmenthash{'oldid'};
  $primarydiscipline = $commitmenthash{'primarydiscipline'};
  $secondarydiscipline = $commitmenthash{'secondarydiscipline'};
  
  if ($commitmentlevelid)
    {
    $commitmentlevel = lookup_single_value($dbh, "commitmentlevel", "description", $commitmentlevelid);
    $commitmentlevelavailchk = "";
    }
  else
    {
    $commitmentlevel = "";
    $commitmentlevelavailchk = "checked";
    }
    
  $approvername = ($approver) ? lookup_single_value($dbh, "users", "lastname || ', ' || firstname", $approver) : "";
  $status = ($status) ? lookup_single_value($dbh, "status", "description", $statusid) : "";
  $updatedbyname = ($updatedbyname) ? lookup_single_value($dbh, "users", "lastname || ', ' || firstname", $updatedby): "";
  
  %committedtohash = get_lookup_values($dbh, "committedorg", "organizationid", "'True'", "commitmentid = $commitmentid");
  %keywordsusedhash = get_lookup_values($dbh, "commitmentkeyword", "keywordid", "'True'", "commitmentid = $commitmentid");
  %productsaffectedhash = get_lookup_values($dbh, "productaffected", "productid", "'True'", "commitmentid = $commitmentid");
  %roleshash = get_lookup_values($dbh, "commitmentrole", "roleid", "usersid", "commitmentid = $commitmentid");

  #get role ids
  my $doeflroleid = lookup_role_by_name($dbh, "DOE Functional Lead");
  my $doeccroleid = lookup_role_by_name($dbh, "DOE Commitment Coordinator");
  my $doecmgrroleid = lookup_role_by_name($dbh, "DOE Commitment Manager");
  my $cmroleid = lookup_role_by_name($dbh, "Commitment Maker");
  my $moflroleid = lookup_role_by_name($dbh, "M&O Functional Lead");
  my $moccroleid = lookup_role_by_name($dbh, "M&O Commitment Coordinator");
  my $mocmgrroleid = lookup_role_by_name($dbh, "M&O Commitment Manager");

  $dbh->{LongReadLen} = $TitleLength;
  $dbh->{LongTruncOk} = 1;
  my $key;
  my %commitmentlevelhash = get_lookup_values($dbh, 'commitmentlevel', 'description', 'commitmentlevelid', "isactive='T'");
  my %productshash = get_lookup_values($dbh, 'product', 'description', 'productid', "isactive='T'");
  my %keywordhash = get_lookup_values($dbh, 'keyword', 'description', 'keywordid', "isactive='T'");
  my %wbshash = get_lookup_values($dbh, 'workbreakdownstructure', "changerequestnum || ' . ' || controlaccountid", "description");
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
  print <<committable1;
  <script language="JavaScript" type="text/javascript">
    <!--
    function disableletter()
      {
      document.editcommitment.letteraccessionnum.disabled = true;
      document.editcommitment.letteraccessionnum.value = "";
      document.editcommitment.lettersigner.disabled = true;
      document.editcommitment.lettersigner.value = "";
      document.editcommitment.lettersigneddate_month.disabled = true;
      document.editcommitment.lettersigneddate_day.disabled = true;
      document.editcommitment.lettersigneddate_year.disabled = true;
      document.editcommitment.chklettersigneddate.disabled = true;
      document.editcommitment.chklettersigneddate.checked = false;
      document.editcommitment.lettersentdate_month.disabled = true;
      document.editcommitment.lettersentdate_day.disabled = true;
      document.editcommitment.lettersentdate_year.disabled = true;
      document.editcommitment.chklettersentdate.disabled = true;
      document.editcommitment.chklettersentdate.checked = false;
      document.editcommitment.letteraddressee.disabled = true;
      document.editcommitment.letteraddressee.value = "";
      document.editcommitment.letterorganizationid.disabled = true;
      document.editcommitment.letterorganizationid.value = "";
      }

    function enableletter()
      {
      document.editcommitment.letteraccessionnum.disabled = false;
      document.editcommitment.lettersigner.disabled = false;
      document.editcommitment.lettersigneddate_month.disabled = false;
      document.editcommitment.lettersigneddate_day.disabled = false;
      document.editcommitment.lettersigneddate_year.disabled = false;
      document.editcommitment.chklettersigneddate.disabled = false;
      document.editcommitment.lettersentdate_month.disabled = false;
      document.editcommitment.lettersentdate_day.disabled = false;
      document.editcommitment.lettersentdate_year.disabled = false;
      document.editcommitment.chklettersentdate.disabled = false;
      document.editcommitment.letteraddressee.disabled = false;
      document.editcommitment.letterorganizationid.disabled = false;
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
      var validateform = document.editcommitment;
      msg += (validateform.text.value=="") ? "You must enter the commitment text.\\n" : "";
      //msg += ((tmpmsg = validate_date(validateform.datewritten_year.value, validateform.datewritten_month.value, validateform.datewritten_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Date Written - " + tmpmsg + "\\n";
      //if (! validateform.chkduedate.checked)
        msg += ((tmpmsg = validate_date(validateform.duedate_year.value, validateform.duedate_month.value, validateform.duedate_day.value, 0, 0, 0, 0, true, true, false)) == "") ? "" : "Due Date - " + tmpmsg + "\\n";
      if (! validateform.chkcommitdate.checked)
        msg += ((tmpmsg = validate_date(validateform.commitdate_year.value, validateform.commitdate_month.value, validateform.commitdate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Commit Date - " + tmpmsg + "\\n";
      if (! validateform.chkcommitmentlevelid.checked)
        msg += (validateform.commitmentlevelid.value=="") ? "You must select a commitment level.\\n" : "";
      //if (! validateform.chkactionsummary.checked)
      msg += (validateform.actionsummary.value=="") ? "You must enter an action summary.\\n" : "";
      //if (! validateform.chkfunctionalrecommend.checked)
      msg += (validateform.functionalrecommend.value=="") ? "You must enter the DOE Functional Lead recommendation.\\n" : "";
      //if (! validateform.chkactionplan.checked)
      msg += (validateform.actionplan.value=="") ? "You must enter the action plan.\\n" : "";
      //if (! validateform.chkcmrecommendation.checked)
      msg += (validateform.cmrecommendation.value=="") ? "You must enter the Commitment Manager's recomemndation.\\n" : "";
      if (! validateform.chkworkbreakdownstructure.checked)
        msg += (validateform.workbreakdownstructure.selectedIndex == -1) ? "You must select a Work Breakdown Structure.\\n" : "";
      //if (! validateform.chkcommitmentrationale.checked)
      msg += (validateform.commitmentrationale.value=="") ? "You must enter the rationale for making this commitment.\\n" : "";
      msg += (validateform.approver.value=="NULL") ? "You must specify the approver of this commitment.\\n" : "";
      //if (! validateform.chkactionstaken.checked)
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
      //if (validateform.letterid.value=="NEW")
      //  {
      //  msg += ((tmpmsg = validate_accession_number(validateform.letteraccessionnum.value)) == "") ? "" : "Letter Accession Number - " + tmpmsg + "\\n";
      //  msg += ((tmpmsg = validate_date(validateform.lettersentdate_year.value, validateform.lettersentdate_month.value, validateform.lettersentdate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Letter Sent Date - " + tmpmsg + "\\n";
      //  msg += (validateform.letteraddressee.value=="") ? "You must enter the addressee of the letter.\\n" : "";
      //  msg += ((tmpmsg = validate_date(validateform.lettersigneddate_year.value, validateform.lettersigneddate_month.value, validateform.lettersigneddate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Letter Signed Date - " + tmpmsg + "\\n";
      //  msg += (validateform.lettersigner.value=="") ? "You must select the signer of the letter.\\n" : "";
      //  msg += (validateform.letterorganizationid.value=='') ? "You must select the organization the letter was sent to.\\n" : "";
      //  }
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
  <form name=editcommitment method=post target="control" action="/cgi-bin/oncs/readcommitments.pl" onsubmit="return(validate_commitment_data())"> <!--   -->
  <input name=cgiaction type=hidden value="modify_commitment">
  <input name=loginusersid type=hidden value=$usersid>
  <input name=loginusername type=hidden value=$username>
  <input name=issueid type=hidden value=$issueid>
  <input name=commitmentid type=hidden value=$commitmentid>
  <table summary="Enter Commitment Table" width=100% border=1>
  <tr>
    <th colspan=3 align=center>
    Edit Commitment
    </th>
  </tr>
  <tr>
    <td width=20% align=center>
    <b>Commitment Text</b>
    </td>
    <td width=70% colspan=2 align=left>
    <textarea name=text cols=65 rows=5>$text</textarea>
    </td>
  </tr>
  <tr>
    <td align=center width=20%>
    <b>Due Date</b>
    </td>
    <td align=left width=70%>
committable1
  print build_date_selection('duedate', 'editcommitment', $duedate);
  print <<committable2;
    </td>
    <td align=center width=10%>
    Not Available<BR>
    <input type=checkbox name=chkduedate onclick="process_checkmark(document.editcommitment.chkduedate, 6, document.editcommitment.duedate_month, document.editcommitment.duedate_day, document.editcommitment.duedate_year, document.editcommitment.duedate)" value=1 $duedateavailchk>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Date of Commitment</b>
    </td>
    <td>
committable2
  print build_date_selection('commitdate', 'editcommitment', $commitdate);
  print <<committable2b;
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox name=chkcommitdate onclick="process_checkmark(document.editcommitment.chkcommitdate, 6, document.editcommitment.commitdate_month, document.editcommitment.commitdate_day, document.editcommitment.commitdate_year, document.editcommitment.commitdate)" name=chkcommitdate value=1 $commitdateavailchk>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Level of Commitment</b>
    </td>
    <td>
    <select name=commitmentlevelid>
    <option value=''>Select a Level of Commitment
committable2b
  foreach $key (sort keys %commitmentlevelhash)
    {
    my $selectedstring = ($commitmentlevelhash{$key} == $commitmentlevelid) ? "selected" : "";
    print "    <option value=\"$commitmentlevelhash{$key}\" $selectedstring>$key\n";
    }
  print <<committable3;
    </select>
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox name=chkcommitmentlevelid onclick="process_checkmark(document.editcommitment.chkcommitmentlevelid, 3, document.editcommitment.commitmentlevelid)" value=1 $commitmentlevelavailchk>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Action Summary</b>
    </td>
    <td colspan=2>
    <textarea name=actionsummary cols=65 rows=5>$actionsummary</textarea>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Work Estimate</b>
    </td>
    <td colspan=2>
    <textarea name=estimate cols=65 rows=5>$estimate</textarea>
    <br>
    (Optional, leave blank if not available)
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>DOE Functional Lead Recommendation</b>
    </td>
    <td colspan=2>
    <textarea name=functionalrecommend cols=65 rows=5>$functionalrecommend</textarea>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Action Plan</b>
    </td>
    <td colspan=2>
    <textarea name=actionplan cols=65 rows=5>$actionplan</textarea>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Products Affected</b>
    </td>
    <td colspan=2>
    <table border=0 summary="Product Data">
      <tr align=Center>
        <td>
        <b>Product List</b>
        </td>
        <td>&nbsp;
        </td>
        <td>
        <b>Products Affected</b>
        </td>
      </tr>
      <tr>
        <td>
        <select name=allproductslist size=5 multiple ondblclick="process_multiple_dual_select_option(document.editcommitment.allproductslist, document.editcommitment.productsaffected, 'movehist', document.editcommitment.prodhist)">
committable3
  foreach $key (sort keys %productshash)
    {
    if ($productsaffectedhash{$productshash{$key}} ne 'True')
      {
      print "        <option value=\"$productshash{$key}\">$key\n";
      }
    }
print <<committable3b;
        <option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
        </select>
        </td>
        <td>
        <input name=prodleftarrow title="click to remove the selected product(s)" value="<--" type=button onclick="process_multiple_dual_select_option(document.editcommitment.productsaffected, document.editcommitment.allproductslist, 'movehist', document.editcommitment.prodhist)">
        <br>
        <input name=prodrightarrow title="click to commit to the selected product(s)" value="-->" type=button onclick="process_multiple_dual_select_option(document.editcommitment.allproductslist, document.editcommitment.productsaffected, 'movehist', document.editcommitment.prodhist)">
        <input name=prodhist type=hidden>
        </td>
        <td>
        <select name=productsaffected size=5 multiple ondblclick="process_multiple_dual_select_option(document.editcommitment.productsaffected, document.editcommitment.allproductslist, 'movehist', document.editcommitment.prodhist)">
committable3b
  foreach $key (sort keys %productshash)
    {
    if ($productsaffectedhash{$productshash{$key}} eq 'True')
      {
      print "        <option value=\"$productshash{$key}\">$key\n";
      }
    }
print <<committable4;
        <option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
        </select>
        </td>
      </tr>
    </table>
    Hold the Control key while clicking to select more than one.<br>
    (Optional, if no products are affected, leave blank.)
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>DOE Commitment Manager Recommendation</b>
    </td>
    <td colspan=2>
    <textarea name=cmrecommendation cols=65 rows=5>$cmrecommendation</textarea>
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
    my $selectedstring = ("$changerequestnum . $controlaccountid" eq $key) ? "selected" : "";
    print "    <option value=\"$key\" $selectedstring>$key -- $wbshash{$key}\n";
    }
  print <<committable5;
    </select>
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox name=chkworkbreakdownstructure onclick="process_checkmark(document.editcommitment.chkworkbreakdownstructure, 3, document.editcommitment.workbreakdownstructure)" value=1 $wbsavailchk>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Commitment Rationale</b>
    </td>
    <td colspan=2>
    <textarea name=commitmentrationale cols=65 rows=5>$commitmentrationale</textarea>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Approver</b>
    </td>
    <td colspan=2>
    <select name=approver>
    <option value=NULL>Select an Approver
committable5
  foreach $key (sort keys %usershash)
    {
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    my $selectedstring = ($approver == $usershash{$key}) ? "selected" : "";
    print "    <option value=\"$usershash{$key}\" $selectedstring>$usernamestring\n";
    }
  print <<committable6;
    </select>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Actions Taken</b>
    </td>
    <td colspan=2>
    <textarea name=actionstaken cols=65 rows=5>$actionstaken</textarea>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Date Closed</b>
    </td>
    <td>
committable6
  print build_date_selection('closuredate', 'editcommitment', $closeddate);
  print <<committable7;
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox name=chkclosuredate onclick="process_checkmark(document.editcommitment.chkclosuredate, 6, document.editcommitment.closuredate_month, document.editcommitment.closuredate_day, document.editcommitment.closuredate_year, document.editcommitment.closuredate)" value=1 $closeddateavailchk>
    </td>
  </tr>
  <tr>
    <td align=center>
    <b>Comments</b>
    </td>
    <td colspan=2>
    <textarea name=comments cols=65 rows=5>$comments</textarea>
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
    <option value=NULL>Select a Status
committable7
  foreach $key (sort keys %statushash)
    {
    my $selectedstring = ($statusid == $statushash{$key}) ? "selected" : "";
    print "    <option value=\"$statushash{$key}\" $selectedstring>$key\n";
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
    <option value=NULL>Not Replaced
committable8
  foreach $key (sort keys %commitmenthash)
    {
    my $selectedstring = ($replacedby == $commitmenthash{$key}) ? "selected" : "";
    $commitmentstring = $commitmenttexthash{$commitmenthash{$key}} . "--" . $key;
    $commitmentstring =~ s/;$commitmenthash{$key}//g;
    print "    <option value=\"$commitmenthash{$key}\" $selectedstring>$commitmentstring\n";
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
        <select name=allorganizationlist size=5 multiple ondblclick="process_multiple_dual_select_option(document.editcommitment.allorganizationlist, document.editcommitment.committedto, 'movehist', document.editcommitment.orghist)">
committable9
  foreach $key (sort keys %orghash)
    {
    if ($committedtohash{$orghash{$key}} ne 'True')
      {
      my $orgdescription = $key;
      $orgdescription =~ s/;$orghash{$key}//g;
      print "        <option value=\"$orghash{$key}\">$orgdescription\n";
      }
    }
#print &build_dual_select( (element name), (form name), \(hash of available values/names), \(hash of selected values/names), (name of available box (left side)), (name of selected box (right side)) [, (locked value)[, (locked value)[, (locked value) [...]]]] );
print <<committable9b;
        <option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
        </select>
        </td>
        <td>
        <input name=leftarrow title="click to remove the selected organization(s)" value="<--" type=button onclick="process_multiple_dual_select_option(document.editcommitment.committedto, document.editcommitment.allorganizationlist, 'movehist', document.editcommitment.orghist)">
        <br>
        <input name=rightarrow title="click to commit to the selected organization(s)" value="-->" type=button onclick="process_multiple_dual_select_option(document.editcommitment.allorganizationlist, document.editcommitment.committedto, 'movehist', document.editcommitment.orghist)">
        <input name=orghist type=hidden>
        </td>
        <td>
        <select name=committedto size=5 multiple ondblclick="process_multiple_dual_select_option(document.editcommitment.committedto, document.editcommitment.allorganizationlist, 'movehist', document.editcommitment.orghist)">
committable9b
  foreach $key (sort keys %orghash)
    {
    if ($committedtohash{$orghash{$key}} eq 'True')
      {
      my $orgdescription = $key;
      $orgdescription =~ s/;$orghash{$key}//g;
      print "        <option value=\"$orghash{$key}\">$orgdescription\n";
      }
    }
print <<committable10;
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
        <select name=allkeywordlist size=5 multiple ondblclick="process_multiple_dual_select_option(document.editcommitment.allkeywordlist, document.editcommitment.keywords, 'movehist', document.editcommitment.keyhist)">
committable10
  foreach $key (sort keys %keywordhash)
    {
    if ($keywordsusedhash{$keywordhash{$key}} ne 'True')
      {
      print "        <option value=\"$keywordhash{$key}\">$key\n";
      }
    }
print <<committable10b;
        <option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp
        </select>
        </td>
        <td>
        <input name=keywordleftarrow title="Click to remove the selected keyword(s)" value="<--" type=button onclick="process_multiple_dual_select_option(document.editcommitment.keywords, document.editcommitment.allkeywordlist, 'movehist', document.editcommitment.keyhist)">
        <br>
        <input name=keywordrightarrow title="Click to select the keyword(s)" value="-->" type=button onclick="process_multiple_dual_select_option(document.editcommitment.allkeywordlist, document.editcommitment.keywords, 'movehist', document.editcommitment.keyhist)">
        <input name=keyhist type=hidden>
        </td>
        <td>
        <select name=keywords size=5 multiple ondblclick="process_multiple_dual_select_option(document.editcommitment.keywords, document.editcommitment.allkeywordlist, 'movehist', document.editcommitment.keyhist)">
committable10b
  foreach $key (sort keys %keywordhash)
    {
    if ($keywordsusedhash{$keywordhash{$key}} eq 'True')
      {
      print "        <option value=\"$keywordhash{$key}\">$key\n";
      }
    }
print <<committable11;
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
    <input type=text name=oldid maxlength=20 size=20 value="$oldid">
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
committable11
  print "<option value=''" . (($primarydiscipline eq '') ? " selected" : "") . ">Select a Primary Discipline\n";
  print "<option value=NULL>Not Available\n";
  foreach $key (sort keys %disciplinehash)
    {
    my $selectedstring = ($primarydiscipline eq $disciplinehash{$key}) ? "selected" : ""; 
    print "<option value=\"$disciplinehash{$key}\" $selectedstring>$key\n";
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
committable12
  print "<option value=''" . (($secondarydiscipline eq '') ? " selected" : "") . ">Select a Secondary Discipline\n";
  print "<option value=NULL>Not Available\n";
  foreach $ key (sort keys % disciplinehash)
    {
    my $selectedstring = ($secondarydiscipline eq $disciplinehash{$key}) ? "selected" : ""; 
    print "<option value=\"$disciplinehash{$key}\" $selectedstring>$key\n";
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
    <option value=''>Select the DOE Functional Lead
    <option value=NULL>Not Available
assigntable1
  foreach $key (sort keys %usershash)
    {
    my $selectionstring = ($roleshash{$doeflroleid} == $usershash{$key}) ? "selected" : "";
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\" $selectionstring>$usernamestring\n";
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
    <option value=''>Select the DOE Commitment Coordinator
    <option value=NULL>Not Available
assigntable2
  foreach $key (sort keys %usershash)
    {
    my $selectionstring = ($roleshash{$doeccroleid} == $usershash{$key}) ? "selected" : "";
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\" $selectionstring>$usernamestring\n";
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
    <option value=''>Select the DOE Commitment Manager
    <option value=NULL>Not Available
assigntable3
  foreach $key (sort keys %usershash)
    {
    my $selectionstring = ($roleshash{$doecmgrroleid} == $usershash{$key}) ? "selected" : "";
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\" $selectionstring>$usernamestring\n";
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
    <option value=''>Select the Commitment Maker
    <option value=NULL>Not Available
assigntable4
  foreach $key (sort keys %usershash)
    {
    my $selectionstring = ($roleshash{$cmroleid} == $usershash{$key}) ? "selected" : "";
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\" $selectionstring>$usernamestring\n";
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
    <option value=''>Select the M&amp;O Functional Lead
    <option value=NULL>Not Available
assigntable5
  foreach $key (sort keys %usershash)
    {
    my $selectionstring = ($roleshash{$moflroleid} == $usershash{$key}) ? "selected" : "";
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\" $selectionstring>$usernamestring\n";
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
    <option value=''>Select the M&amp;O Commitment Coordinator
    <option value=NULL>Not Available
assigntable6
  foreach $key (sort keys %usershash)
    {
    my $selectionstring = ($roleshash{$moccroleid} == $usershash{$key}) ? "selected" : "";
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\" $selectionstring>$usernamestring\n";
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
    <option value=''>Select the M&amp;O CommitmentManager
    <option value=NULL>Not Available
assigntable7
  foreach $key (sort keys %usershash)
    {
    my $selectionstring = ($roleshash{$mocmgrroleid} == $usershash{$key}) ? "selected" : "";
    $usernamestring = $key;
    $usernamestring =~ s/;$usershash{$key}//g;
    print "    <option value=\"$usershash{$key}\" $selectionstring>$usernamestring\n";
    }
  print <<assigntable8;
    </td>
  </tr>
  </table>
  <input type=submit name=submit value="Submit Changes" title="Submit Changes to This Commitment" onclick="selectemall(document.editcommitment.committedto);selectemall(document.editcommitment.keywords);">
  </form>
  </body>
  </html>
  <script language="JavaScript" type="text/javascript">
    <!-- 
    process_checkmark(document.editcommitment.chkduedate, 6, document.editcommitment.duedate_month, document.editcommitment.duedate_day, document.editcommitment.duedate_year, document.editcommitment.duedate);    
    process_checkmark(document.editcommitment.chkcommitdate, 6, document.editcommitment.commitdate_month, document.editcommitment.commitdate_day, document.editcommitment.commitdate_year, document.editcommitment.commitdate);
    process_checkmark(document.editcommitment.chkcommitmentlevelid, 3, document.editcommitment.commitmentlevelid);
    process_checkmark(document.editcommitment.chkworkbreakdownstructure, 3, document.editcommitment.workbreakdownstructure);
    process_checkmark(document.editcommitment.chkclosuredate, 6, document.editcommitment.closuredate_month, document.editcommitment.closuredate_day, document.editcommitment.closuredate_year, document.editcommitment.closuredate);
    //-->
  </script>
assigntable8

  &oncs_disconnect($dbh);
  exit 1;

##################################################################  
# Exit at this point, the following information is not ready yet #
##################################################################  
  
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
    <select name=letterid onChange="checkletter(document.editcommitment.letterid)">
    <option value='' selected>Select a Commitment Letter
    <option value="NEW">New Letter
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
  print build_date_selection('lettersentdate', 'editcommitment');
  print <<lettertable2;
    </td>
    <td width=10% align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.editcommitment.chklettersentdate, 6, document.editcommitment.lettersentdate_month, document.editcommitment.lettersentdate_day, document.editcommitment.lettersentdate_year, document.editcommitment.lettersentdate)" name=chklettersentdate value=1>
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
  print build_date_selection('lettersigneddate', 'editcommitment');
  print <<lettertable3;
    </td>
    <td align=center>
    Not Available<BR>
    <input type=checkbox onclick="process_checkmark(document.editcommitment.chklettersigneddate, 6, document.editcommitment.lettersigneddate_month, document.editcommitment.lettersigneddate_day, document.editcommitment.lettersigneddate_year, document.editcommitment.lettersigneddate)" name=chklettersigneddate value=1>
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
    <td width=20% align=center>
    <b>Organization Sent To</b>
    </td>
    <td width=80% align=left>
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
  <input type=submit name=submit value="Submit This Commitment" title="Submit This Commitment" onclick="selectemall(document.editcommitment.committedto);selectemall(document.editcommitment.keywords);">
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
print "<form action=\"/cgi-bin/oncs/readcommitments.pl\" enctype=\"multipart/form-data\" method=post name=commitmentselection onsubmit=\"return(true)\">\n";
$dbh->{LongReadLen} = $TitleLength;
$dbh->{LongTruncOk} = 1;
tie my %commitmenthash, "Tie::IxHash";
%commitmenthash = get_lookup_values($dbh, 'commitment', 'commitmentid', "TO_CHAR(commitdate, 'MM/DD/YYYY') || ' - ' || ';' || commitmentid", '1=1 ORDER BY commitmentid');
my %commitmenttexthash = get_lookup_values ($dbh, 'commitment', 'commitmentid', 'text');
$dbh->{LongTruncOk} = 0;
my $key;
#display the old issue form
print <<commitmentselectionform1;
<input name=cgiaction type=hidden value="query_commitment">
<select name=commitmentid size=10>
commitmentselectionform1
foreach $key (keys %commitmenthash) #(sort keys %commitmenthash)
  {
  my $commitmentdescription = $commitmenthash{$key};
  $commitmentdescription =~ s/;$key/$commitmenttexthash{$key}/g;
  my $displaykey = "0000$key";
  $displaykey = substr($displaykey, -5);
  print "<option value=$key>$displaykey - " . getDisplayString($commitmentdescription, 80) . "\n";
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
print "<input name=submit type=submit value=\"View Selected Commitment\" onclick=\"dosubmit=true; (document.commitmentselection.commitmentid.selectedIndex == -1) ? (alert(\'No Commitment Selected\') || (dosubmit = false)) : dosubmit=true; return(dosubmit)\">\n";
print "</form>\n";
print "</body>\n";
print "</html>\n";