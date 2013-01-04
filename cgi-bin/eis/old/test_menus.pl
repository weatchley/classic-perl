#!/usr/local/bin/newperl -w
#
#
#

use integer;
use strict;
use Text_Menus;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DocumentSpecific qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);
use Tie::IxHash;

$| = 1;

my $crdcgi = new CGI;
my $userid = $crdcgi->param("userid");
my $username = $crdcgi->param("username");
my $schema = ((defined($crdcgi->param("schema"))) ? $crdcgi->param("schema") : "$SCHEMA");

#&checkLogin ($username, $userid, $schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $command = $crdcgi->param("command");
my $dbh = db_connect();
#my $dbh = db_connect(server =>'ydoradev');

print $crdcgi->header('text/html');
print <<END_of_1;
<html>
<head>
<meta http-equiv=expires content='31 Dec 1997'>
<script src=$CRDJavaScriptPath/utilities.js></script>
<script src=$CRDJavaScriptPath/widgets.js></script>
</head>

<script language=javascript><!--
      function submitForm(script, command, id) {
          alert ('Submit Form - ' + script + ' - ' + command + ' - ' + id);
      }
      function submitFormNewWindow(script, command, id) {
          alert ('Submit Form New Window - ' + script + ' - ' + command + ' - ' + id);

      }
      function submitFormCGIResults(script, command, id) {
          alert ('Submit Form CGI Results - ' + script + ' - ' + command + ' - ' + id);

      }
      
      function checkResponseStatusReport() {
          var msg = '';
          // Response Status Report
          if (!isnumeric(document.$form.rsstartid.value)) {
              msg = "Starting Document ID must be a positive number\\n";
          }
          if (!isnumeric(document.$form.rsendid.value)) {
              msg = "Ending Document ID must be a positive number\\n";
          }
          if (Number(document.$form.rsendid.value) < Number(document.$form.rsstartid.value)) {
              msg = "Ending Document ID must not be less than Starting Document ID\\n";
          }
          if (msg != "") {
              alert (msg);
          } else {
             submitFormNewWindow('$form', 'report','ResponseStatusReport');
          }
      }
      
      function checkSCRReport() {
          var msg = '';
          // summary comment/response report
          if (document.$form.scridtype[1].checked) {
              var s = document.$form.scridpastelist.value;
              var hasnumb = false;
              var valid = true;
              if (s.length == 0) valid = false;
              for(var i = 0; i < s.length; i++) {
                  var c = s.charAt(i);
                  if ((c >= '0') || (c <= '9')) hasnumb = true;
                  if (!(c == 's' || c == 'S' || c== 'c' || c == 'C' || c == 'r' || c == 'R' || (c >= '0' && c <= '9') || c==' ' || c=='\\n' || c=='\\r' || c==',')) valid = false;
              }
              
              if (hasnumb == false || valid == false) {
                  msg = "SCR ID List must contain one or more items in the form of 'SCR0000'.";
              }
          }
          if (msg != "") {
              alert (msg);
          } else {
              submitFormCGIResults('$form', 'report', 'SummaryCommentReportTest');
          }
      }
      
      function checkSearchStringsReport() {
          var msg = '';
          // Search Strings Report
          if (isblank(document.$form.commentsearchstrings.value)) {
              msg += "You must input one or more strings to search for\\n";
          }
          if (!document.$form.cwscomments.checked && !document.$form.cwsresponses.checked && !document.$form.cwsscr.checked) {
              msg += "You must check at least one of the search options\\n";
          }
          if (msg != "") {
              alert (msg);
          } else {
              submitFormNewWindow('$form', 'report', 'CommentsWithStringsReport');
          }
      }
      
      function checkConcurrenceReport() {
          var msg = '';
          // Concurrence Report
          if (!document.$form.includeindividualcon.checked && !document.$form.includescrcon.checked) {
              msg += "You must check at least one of the include options\\n";
          }
          if (document.$form.includeindividualcon.checked && !document.$form.includeindividualcon.disabled && !document.$form.includefirstreviewcon.checked && !document.$form.includesecondreviewcon.checked && !document.$form.includeapprovedcon.checked) {
              msg += "You must check at least one of the options for individual responses\\n";
          }
          if (!document.$form.includefirstnonecon.checked && !document.$form.includefirstpositivecon.checked && !document.$form.includefirstnegativecon.checked && !document.$form.includesecondnonecon.checked && !document.$form.includesecondpositivecon.checked && !document.$form.includesecondnegativecon.checked) {
              msg += "You must check at least one of the concurrence options\\n";
          }
          if (msg != "") {
              alert (msg);
          } else {
              submitFormCGIResults('$form', 'report', 'ConcurrenceReportTest');
          }
      }
//-->
</script>

<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
<center>
<form name=$form>
END_of_1

eval {

    my $menu1 = new Text_Menus;

    #print $menu1->menuInitialize;

    #$menu1->addMenu("menu1", "Text for Menu 1");
    #$menu1->addMenu("menu2", "Text for Menu 2");
    #$menu1->addMenu("menu3", "Text for Menu 3");
    #$menu1->addMenu("menu4", "Text for Menu 4");
    
    #print $menu1->buildMenus('myMenu1');
    
# Summary section
      tie my %binlookupvalues, "Tie::IxHash";
      tie my %userlookupvalues, "Tie::IxHash";
      my $DocumentCommentCountByTypeInput .= "<table border=0><tr><td><b><input type=checkbox name=displayhearings value=T>Show Submission and Transcript Counts for Individual Hearings</b></td></tr></table><input type=button value=Submit align=center onClick=\"submitFormNewWindow('$form', 'report','DocumentCommentCountByType');\">\n";
      my $DocumentCommentCountByType = new Report_Forms;
      $DocumentCommentCountByType->label("Document/Comment Counts by Document Type");
      $DocumentCommentCountByType->contents($DocumentCommentCountByTypeInput);
      
      %binlookupvalues = ('0' => "All Bins", get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', 'parent is NULL ORDER BY name'));
      my $BinStatisticsReportInput = "<table border=0><tr><td><b>Select Bin:</b>" . &nbspaces(3) . &build_drop_box ('bin1', \%binlookupvalues, '0') . "</td></tr>\n";
      $BinStatisticsReportInput .= "<tr><td><b><input type=checkbox name=includeorgs value=T>Include Commentor Organizations and Affiliations</b></td></tr></table><input type=button value=Submit align=center onClick=\"submitFormNewWindow('$form', 'report','BinStatisticsReport');\">\n";
      my $BinStatisticsReport = new Report_Forms;
      $BinStatisticsReport->label("Bin Statistics Report");
      $BinStatisticsReport->contents($BinStatisticsReportInput);
      
      %binlookupvalues = ('0' => "All Bins",get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', 'parent is NULL ORDER BY name'));
      my $BinWorkLoadReportInput = "<table border=0><tr><td><b>Select Bin:</b>" . &nbspaces(3) . &build_drop_box ('bin2', \%binlookupvalues, '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"submitFormNewWindow('$form', 'report','BinWorkLoadReport');\">\n";
      my $BinWorkLoadReport = new Report_Forms;
      $BinWorkLoadReport->label("Bin Workload Report");
      $BinWorkLoadReport->contents($BinWorkLoadReportInput);
      
      %binlookupvalues = ('0' => "All Bins", get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', 'id = id ORDER BY name'));
      %userlookupvalues = ('0' => "All Users", get_lookup_values ($dbh, $schema, 'users', 'id', "firstname || ' ' || lastname", "(id > 0) AND (id < 1000) AND (id IN (SELECT userid FROM $schema.user_privilege WHERE privilege>3)) ORDER BY username"));
      my $BinStatusReportInput = "<table border=0><tr><td><b>Select Bin:</b>" . &nbspaces(3) . &build_drop_box ('bin', \%binlookupvalues, '0') . "</td></tr>\n";
      $BinStatusReportInput .= "<tr><td><b>Select User:</b>" . &nbspaces(3) . &build_drop_box ('user2', \%userlookupvalues, "0") . "</td></tr>\n";
      $BinStatusReportInput .= "<tr><td><b>Include:</b>" . &nbspaces(5) . "<input type=checkbox name=displaycomments value=T><b>Comment Text</b>\n";
      $BinStatusReportInput .= &nbspaces(5) . "<input type=checkbox name=displayresponses value=T><b>Response Text</b>\n";
      $BinStatusReportInput .= &nbspaces(5) . "<input type=checkbox name=displayduplicates value=T checked><b>Duplicates</b>\n";
      $BinStatusReportInput .= &nbspaces(5) . "<input type=checkbox name=displaytechreview value=T><b>Technical Review</b></td></tr>\n";
      $BinStatusReportInput .= "<tr><td><input type=checkbox name=binstatusselectdates value=T onClick=\"enableSetBinStatusReportDates(!(this.checked));\"><b>Select Date Range - ";
      $BinStatusReportInput .= "From: " . build_date_selection("binstatusbegindate", "$form", "today") . " &nbsp; ";
      $BinStatusReportInput .= "To: " . build_date_selection("binstatusenddate", "$form", "today");
      $BinStatusReportInput .= "<script language=javascript><!--\n";
      $BinStatusReportInput .= "function enableSetBinStatusReportDates (status) {\n";
      $BinStatusReportInput .= "    document.$form.binstatusbegindate_month.disabled = (status);\n";
      $BinStatusReportInput .= "    document.$form.binstatusbegindate_day.disabled = (status);\n";
      $BinStatusReportInput .= "    document.$form.binstatusbegindate_year.disabled = (status);\n";
      $BinStatusReportInput .= "    document.$form.binstatusenddate_month.disabled = (status);\n";
      $BinStatusReportInput .= "    document.$form.binstatusenddate_day.disabled = (status);\n";
      $BinStatusReportInput .= "    document.$form.binstatusenddate_year.disabled = (status);\n";
      $BinStatusReportInput .= "}\n";
      $BinStatusReportInput .= "    //alert (show_props(document.$form.binstatusselectdates,'date'));\n";
      $BinStatusReportInput .= "    enableSetBinStatusReportDates(!(document.$form.binstatusselectdates.checked));\n";
      $BinStatusReportInput .= "//--></script>\n";
      $BinStatusReportInput .= "</table><input type=button value=Submit align=center onClick=\"submitFormCGIResults('$form', 'report','BinStatusReportTest');\">\n";
      my $BinStatusReport = new Report_Forms;
      $BinStatusReport->label("Bin Status Report");
      $BinStatusReport->contents($BinStatusReportInput);
      
      %userlookupvalues = get_lookup_values ($dbh, $schema, 'users', 'id', "firstname || ' ' || lastname", "(id > 0) AND (id < 1000) AND (id IN (SELECT userid FROM $schema.user_privilege WHERE privilege>3)) ORDER BY username");
      my $UserWorkLoadReportInput = "<table border=0><tr><td><b>Select User:</b>". &nbspaces(3) . &build_drop_box ('user', \%userlookupvalues, "0") . "</td></tr></table><input type=button value=Submit align=center onClick=\"submitFormNewWindow('$form', 'report','UserWorkLoadReport');\">\n";
      my $UserWorkLoadReport = new Report_Forms;
      $UserWorkLoadReport->label("User Workload Report");
      $UserWorkLoadReport->contents($UserWorkLoadReportInput);
      
      my $ResponseStatusInput .= "<table border=0><tr><td><b>Report on Documents Starting with ID # $CRDType <input type=text size=6 maxlength=6 name=rsstartid value=000001>";
      #my $maxDocID = 999999;
      my ($maxDocID) = lpadzero($dbh->selectrow_array("SELECT MAX(id) FROM $schema.document"),6);
      $ResponseStatusInput .= " and Ending with ID # $CRDType <input type=text size=6 maxlength=6 name=rsendid value=$maxDocID></b></td></tr></table><input type=button value=Submit align=center onClick=\"checkResponseStatusReport();\">\n";
      my $ResponseStatus = new Report_Forms;
      $ResponseStatus->label("Response Status Report");
      $ResponseStatus->contents($ResponseStatusInput);
      

    my $summaryMenu = new Text_Menus;
    
    $summaryMenu->addMenu(name => "summary1", label => "Summary Status Report", contents => "javascript:submitFormNewWindow('$form', 'report','SummaryStatusReport');");
    $summaryMenu->addMenu(name => "summary2", label => $DocumentCommentCountByType->label(), contents => $DocumentCommentCountByType->contents());
    $summaryMenu->addMenu(name => "summary3", label => $BinStatisticsReport->label(), contents => $BinStatisticsReport->contents());
    $summaryMenu->addMenu(name => "summary4", label => $BinStatusReport->label(), contents => $BinStatusReport->contents());
    $summaryMenu->addMenu(name => "summary5", label => $BinWorkLoadReport->label(), contents => $BinWorkLoadReport->contents());
    $summaryMenu->addMenu(name => "summary6", label => "System Workload Report", contents => "javascript:submitFormNewWindow('$form', 'report','SystemWorkLoadReport');");
    $summaryMenu->addMenu(name => "summary7", label => $UserWorkLoadReport->label(), contents => $UserWorkLoadReport->contents());
    $summaryMenu->addMenu(name => "summary8", label => "System Users Report", contents => "javascript:submitFormNewWindow('$form', 'report','UsersReport');");
    $summaryMenu->addMenu(name => "summary9", label => $ResponseStatus->label(), contents => $ResponseStatus->contents());
    $summaryMenu->addMenu(name => "summary10", label => "Comment and Summary Comment Counts by Bin", contents => "javascript:submitFormNewWindow('$form', 'report','BinCountsReport');");
    $summaryMenu->addMenu(name => "summary11", label => "Comment and Summary Comment Counts by Organization", contents => "javascript:submitFormNewWindow('$form', 'report','OrgCountsReport');");
    $summaryMenu->addMenu(name => "summary12", label => "Concurrence Overview Report", contents => "javascript:submitFormNewWindow('$form', 'report','ConcurrenceSummaryReport');");
    #if (&does_user_have_priv($dbh, $schema, $userid, -1)) {
        $summaryMenu->addMenu(name => "summary13", label => "Bin/Section Mapping Report", contents => "javascript://submitFormNewWindow('$form', 'report','BinMappingReport');");
        $summaryMenu->addMenu(name => "summary14", label => "Final Comment Response Document", contents => "javascript:submitForm('final_crd', 'menu',0);");
    #}
    
# Comment Documents Section
    
    my $commentDocumentMenu = new Text_Menus;

    $commentDocumentMenu->addMenu(name => "documents1", label => "Fully customizable documents report", contents => "javascript:submitForm('ad_hoc_reports','adhocsetup','document');");
    $commentDocumentMenu->addMenu(name => "documents2", label => "Standard document report", contents => "javascript:submitForm('$form', 'reportselect', 'StandardDocumentReport');");
    
# Comments Section

      #tie my %binlookupvalues, "Tie::IxHash";
      tie my %lookupvalues, "Tie::IxHash";
      %binlookupvalues = ('0' => "All Bins", get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', 'id = id ORDER BY name'));
      %lookupvalues = ('0' => "All Summary Comments" . nbspaces(130), get_lookup_values ($dbh, $schema, 'summary_comment', 'id', "id || ' - ' || title", 'id = id ORDER BY id'));
      my $SummaryCommentReportInput = "<table border=0 align=center><tr><td><b>Bin:</b>" . &build_drop_box('binforscrs', \%binlookupvalues, '0') . "</td></tr>\n";
      $SummaryCommentReportInput =~ s/"binforscrs">/"binforscrs" onChange=\"buildSCRList(this.options,document.$form.scrid.options);\">/;
      $SummaryCommentReportInput .= "<tr><td><b><i>Include Summarized Comments:</i></b><input type=checkbox name=includescrcomments checked value='T'>\n";
      $SummaryCommentReportInput .= nbspaces(10) . "<b><i>Include Sub-Bins:</i></b><input type=checkbox name=scrusesubbins checked value='T' onClick=\"buildSCRList(document.$form.binforscrs.options,document.$form.scrid.options);\">\n";
      $SummaryCommentReportInput .= nbspaces(10) . "<b><i>Include Remarks:</i></b><input type=checkbox name=scruseremarks value='T'>\n";
      $SummaryCommentReportInput .= "<br><b><i>Include Commentor Organizations of Summarized Comments:</i></b><input type=checkbox name=scruseorganizations value='T'>\n";
      $SummaryCommentReportInput .= "<br><b><i>Include Only Summary Comments With Potential or Confirmed Document Change Impact:</i></b><input type=checkbox name=scrhaschangeimpact value='T' onClick=\"buildSCRList(document.$form.binforscrs.options,document.$form.scrid.options);\"></td></tr>\n";
      $SummaryCommentReportInput .= "<tr><td><b>Sort by SCR:</b><input type=checkbox name=scrsortbyscr value='T' ></td></tr>\n";
      $SummaryCommentReportInput .= "<tr><td>";
      $SummaryCommentReportInput .= "<input type=radio name=scridtype value=select onClick=\"setSCRIDTypeDisabled()\" checked>";
      $SummaryCommentReportInput .= "<b>SCR:</b>" . &build_drop_box('scrid', \%lookupvalues, '0') . "</td></tr>\n";
      $SummaryCommentReportInput .= "<tr><td><table border=0 cellpadding=0 cellspacing=0><tr><td valign=center><input type=radio name=scridtype value=paste onClick=\"setSCRIDTypeDisabled()\">\n";
      $SummaryCommentReportInput .= "</td><td valign=center><b>Paste in list of SCR numbers<br>use format of 'SCR0000':</b>";
      $SummaryCommentReportInput .= "</td><td>" . nbspaces(30) . "<a href=\"javascript:expandTextBox(document.$form.scridpastelist,document.scridpastelist_button,'force',5);\"><img name=scridpastelist_button border=0 src=/eis/images/expand_button.gif></a><br>\n";
      $SummaryCommentReportInput .= nbspaces(10) . "<textarea name=scridpastelist rows=6 cols=10 onKeyPress=\"expandTextBox(this,document.scridpastelist_button,'dynamic');\"></textarea></td></tr></table></td></tr></table><input type=button value=Submit align=center onClick=\"checkSCRReport();\">\n";
      $SummaryCommentReportInput .= "<script language=javascript><!--\n";
      $SummaryCommentReportInput .= "setSCRIDTypeDisabled();\n";
      $SummaryCommentReportInput .= "//--></script>\n";
      my $SummaryCommentReport = new Report_Forms;
      $SummaryCommentReport->label("Report on a Summary Comment/Response");
      $SummaryCommentReport->contents($SummaryCommentReportInput);
      #
      print "<script language=javascript><!--\n";
      print "function setSCRIDTypeDisabled(object) {\n";
      print "    if (object != 'all') {\n";
      print "        if ($form.scridtype[0].checked) {\n";
      print "            $form.binforscrs.disabled = false;\n";
      print "            $form.scrid.disabled = false;\n";
      print "            $form.scridpastelist.disabled = true;\n";
      print "        } else {\n";
      print "            $form.binforscrs.disabled = true;\n";
      print "            $form.scrid.disabled = true;\n";
      print "            $form.scridpastelist.disabled = false;\n";
      print "        }\n";
      print "    }\n";
      print "    //;\n";
      print "}\n";
      #print "setSCRIDTypeDisabled();\n";
      print "    var scrs = new Array();\n";
      my $sqlquery = "SELECT id, title, changeimpact FROM $schema.summary_comment WHERE bin = ?";
      my $csr = $dbh->prepare($sqlquery);
      foreach my $key (sort keys %binlookupvalues) {
          if ($key > 0) {
              print "    scrs[$key] = [0," . get_value($dbh,$schema,'bin','NVL(parent,0)', "id = $key") . ",0";
              $csr->execute($key);
              my $count=0;
              while (my @values = $csr->fetchrow_array) {
                  $values[1] =~ s/'//g;
                  $binlookupvalues{$key} =~ m/([0-9].*?)[ ]/;
                  my $binnumber = $1;
                  print ",[$values[0],'$binnumber - SCR" . lpadzero($values[0],4) ." - $values[1]',$values[2]]";
                  $count++
              }
              print "];\n";
              print "    scrs[$key][2] = $count;\n";
              $csr->finish;
          }
      }
      print "    function isBinMember(binID,rootBin) {\n";
      print "        var parent = binID;\n";
      print "        while (parent != rootBin && parent != 0) {\n";
      print "            parent = scrs[parent][1];\n";
      print "        }\n";
      print "        if (parent == rootBin) {\n";
      print "            return true;\n";
      print "        } else {\n";
      print "            return false;\n";
      print "        }\n";
      print "    }\n";
      print "    function buildSCRList(binobj,scrobj) {\n";
      print "        var bin = binobj[binobj.selectedIndex].value;\n";
      print "        var last = 0;\n";
      print "        var scrlist = new Array();\n";
      print "        for (var i=(scrobj.length-1); i > 0; i--) {\n";
      print "            scrobj[i].value = 0;\n";
      print "            scrobj[i].text = '';\n";
      print "        }\n";
      print "        scrobj.length = 1;\n";
      print "        scrobj.selectedIndex = 0;\n";
      print "        if (bin == '0') {\n";
      print "            for (var i=1; i < scrs.length; i++) {\n";
      print "                if (scrs[i]) {\n";
      print "                    if (scrs[i][2] != 0) {\n";
      print "                        for (var j=3; j <= scrs[i][2]+2; j++) {\n";
      print "                            if ((!document.$form.scrhaschangeimpact.checked) || (document.$form.scrhaschangeimpact.checked && scrs[i][j][2] > 1)) {\n";
      print "                                scrlist[scrs[i][j][0]] = scrs[i][j][1];\n";
      print "                            }\n";
      print "                        }\n";
      print "                    }\n";
      print "                }\n";
      print "            }\n";
      print "        } else {\n";
      print "            if (document.$form.scrusesubbins.checked) {\n";
      print "                for (var i=1; i < scrs.length; i++) {\n";
      print "                    if (scrs[i]) {\n";
      print "                        if (scrs[i][2] != 0) {\n";
      print "                            if (isBinMember(i, bin)) {\n";
      print "                                for (var j=3; j <= scrs[i][2]+2; j++) {\n";
      print "                                    if ((!document.$form.scrhaschangeimpact.checked) || (document.$form.scrhaschangeimpact.checked && scrs[i][j][2] > 1)) {\n";
      print "                                        scrlist[scrs[i][j][0]] = scrs[i][j][1];\n";
      print "                                    }\n";
      print "                                }\n";
      print "                            }\n";
      print "                        }\n";
      print "                    }\n";
      print "                }\n";
      print "            } else {\n";
      print "                if (scrs[bin][2] != 0) {\n";
      print "                    for (var j=3; j <= scrs[bin][2]+2; j++) {\n";
      print "                        if ((!document.$form.scrhaschangeimpact.checked) || (document.$form.scrhaschangeimpact.checked && scrs[i][j][2] > 1)) {\n";
      print "                            scrlist[scrs[bin][j][0]] = scrs[bin][j][1];\n";
      print "                        }\n";
      print "                    }\n";
      print "                }\n";
      print "            }\n";
      print "        }\n";
      print "        for (var i=1; i < scrlist.length; i++) {\n";
      print "            if (scrlist[i]) {\n";
      print "                last++\n";
      print "                scrobj.length++;\n";
      print "                scrobj[last].value = i;\n";
      print "                scrobj[last].text = scrlist[i];\n";
      print "            }\n";
      print "        }\n";
      print "    }\n";
      print "//-->\n";
      print "</script>\n";
      my $DuplicateReportInput = "<table border=0 align=center><tr><td><b>Select Bin:</b>" . &nbspaces(3) . &build_drop_box ('binfordups', \%binlookupvalues, '0') . "</td></tr></table><input type=button value=Submit align=center onClick=\"submitFormCGIResults('$form', 'report', 'DuplicateCommentsReportTest');\">\n";
      my $DuplicateReport = new Report_Forms;
      $DuplicateReport->label("Report on Duplicate Comments");
      $DuplicateReport->contents($DuplicateReportInput);
      
      my $CommentsWithStringInput = "<table border=0 align=center><tr><td><b>Text Strings:</b>" . nbspaces(135) . "<a href=\"javascript:expandTextBox(document.$form.commentsearchstrings,document.commentsearchstrings_button,'force',5);\"><img name=commentsearchstrings_button border=0 src=/eis/images/expand_button.gif></a><br>\n";
      $CommentsWithStringInput .= "<textarea name=commentsearchstrings wrap=virtual rows=6 cols=80 onKeyPress=\"expandTextBox(this,document.commentsearchstrings_button,'dynamic');\"></textarea>\n";
      $CommentsWithStringInput .= "</tr></td><tr><td><b>Select Bin:</b>" . &nbspaces(3) . &build_drop_box ('cwsbin', \%binlookupvalues, '0') . "</tr></td><tr><td>\n";
      $CommentsWithStringInput .= "<b>Search: \n";
      $CommentsWithStringInput .= "<input type=checkbox name=cwscomments value='T' checked>Comments &nbsp; \n";
      $CommentsWithStringInput .= "<input type=checkbox name=cwsresponses value='T' 'checked'>Responses &nbsp; \n";
      $CommentsWithStringInput .= "<input type=checkbox name=cwsscr value='T' checked>SCR's \n";
      $CommentsWithStringInput .= nbspaces(20) . "<b><i>(End each string with an 'Enter')</i></b></b></td></tr>\n";
      $CommentsWithStringInput .= "<tr><td><b><input type=checkbox name=cwscommentors value='T'>Display Detailed Commentor Information</b></td></tr></table><input type=button value=Submit align=center onClick=\"checkSearchStringsReport();\">\n";
      my $CommentsWithString = new Report_Forms;
      $CommentsWithString->label("Search Strings Report");
      $CommentsWithString->contents($CommentsWithStringInput);
      
      %binlookupvalues = ('0' => "All Bins", get_lookup_values ($dbh, $schema, 'bin', 'id', 'name', 'parent is NULL ORDER BY name'));
      my $ConcurrenceReportInput = "<table border=0 align=center><tr><td><b>Select Bin:</b>" . &nbspaces(3) . &build_drop_box ('concurbin', \%binlookupvalues, '0') . "</td></tr>\n";
      $ConcurrenceReportInput .= "<tr><td><table border=0 width=100%><tr><td valign=top>\n";
      $ConcurrenceReportInput .= "<b>" . get_value($dbh,$schema,'concurrence_type','name',"id=1") . " Concurrence Entered:</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includefirstnonecon value=T checked>None</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includefirstpositivecon value=T checked>Positive</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includefirstnegativecon value=T checked>Negative</b>\n";
      $ConcurrenceReportInput .= "<br><b>" . get_value($dbh,$schema,'concurrence_type','name',"id=2") . " Concurrence Entered:</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includesecondnonecon value=T checked>None</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includesecondpositivecon value=T checked>Positive</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includesecondnegativecon value=T checked>Negative</b>\n";
      $ConcurrenceReportInput .= "</td><td valign=top>\n";
      $ConcurrenceReportInput .= "<b>Include:</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includeindividualcon value=T checked onClick=\"setIndividualConcurrenceReportDisabled('');\">Individual Responses</b>\n";
      $ConcurrenceReportInput .= "<br>" . nbspaces(5) . "<b><input type=checkbox name=includefirstreviewcon value=T checked>" . &FirstReviewName . " Review/Approval</b>\n";
      $ConcurrenceReportInput .= "<br>" . nbspaces(5) . "<b><input type=checkbox name=includesecondreviewcon value=T checked>" . &SecondReviewName . " Review/Approval</b>\n";
      $ConcurrenceReportInput .= "<br>" . nbspaces(5) . "<b><input type=checkbox name=includeapprovedcon value=T checked>Approved</b>\n";
      $ConcurrenceReportInput .= "<br><b><input type=checkbox name=includescrcon value=T checked>Summary Comment/Responses</b>\n";
      $ConcurrenceReportInput .= "</td></tr></table></td></tr></table><input type=button value=Submit align=center onClick=\"checkConcurrenceReport();\">\n";
      my $ConcurrenceReport = new Report_Forms;
      $ConcurrenceReport->label("Concurrence Report");
      $ConcurrenceReport->contents($ConcurrenceReportInput);
      
    
    my $commentsMenu = new Text_Menus;

    $commentsMenu->addMenu(name => "comments1", label => "Fully customizable comments report", contents => "javascript:submitForm('ad_hoc_reports','adhocsetup','comment');");
    $commentsMenu->addMenu(name => "comments2", label => "Standard comment report", contents => "javascript:submitForm('$form', 'reportselect', 'StandardCommentReport');");
    $commentsMenu->addMenu(name => "comments3", label => "Report on all comments related to DOE commitments", contents => "javascript:submitFormCGIResults('$form', 'report', 'DOECommitmentsReportTest');");
    $commentsMenu->addMenu(name => "comments4", label => "Report on all comments related to potential or confirmed $CRDType changes", contents => "javascript:submitFormCGIResults('$form', 'report', 'CRDChangesReportTest');");
    $commentsMenu->addMenu(name => "comments5", label => $SummaryCommentReport->label(), contents => $SummaryCommentReport->contents());
    $commentsMenu->addMenu(name => "comments6", label => $DuplicateReport->label(), contents => $DuplicateReport->contents());
    $commentsMenu->addMenu(name => "comments7", label => $CommentsWithString->label(), contents => $CommentsWithString->contents());
    $commentsMenu->addMenu(name => "comments8", label => $ConcurrenceReport->label(), contents => $ConcurrenceReport->contents());
    
# Commentors Section
    
    my $commentorsMenu = new Text_Menus;

    $commentorsMenu->addMenu(name => "commentors1", label => "Fully customizable commentors report", contents => "javascript:submitForm('ad_hoc_reports','adhocsetup','commentor');");
    $commentorsMenu->addMenu(menu => "commentors", name => "commentors2", label => "Standard commentor report", contents => "javascript:submitForm('$form', 'reportselect', 'StandardCommentorReport');");

# Top menu
    $menu1->addMenu(name => "summary", label => "Summary Reports", status => 'open', contents => $summaryMenu->buildMenus(name=>'summaryMenu', type => 'bullets'), title => 'Summary Reports');
    $menu1->addMenu(name => "documents", label => "Comment Documents", contents => $commentDocumentMenu->buildMenus(name=>'commentDocumentMenu', type => 'bullets'), title => 'Comment Documents');
    $menu1->addMenu(name => "comments", label => "Comments", contents => $commentsMenu->buildMenus(name=>'commentsMenu', type => 'bullets'), title => 'Comments');
    $menu1->addMenu(name => "commentors", label => "Commentors", contents => $commentorsMenu->buildMenus(name=>'commentorsMenu', type => 'bullets'), title => 'Commentors');
    #$summaryMenu->imageSource("/eis/images/");
    #$commentDocumentMenu->imageSource("/eis/images/");
    #$commentsMenu->imageSource("/eis/images/");
    #$commentorsMenu->imageSource("/eis/images/");
    #$menu1->addMenu(name => "summary", label => "Summary Reports", status => 'open', contents => $summaryMenu->buildMenus(name=>'summaryMenu', type => 'tabs'), title => 'Summary Reports');
    #$menu1->addMenu(name => "documents", label => "Comment Documents", contents => $commentDocumentMenu->buildMenus(name=>'commentDocumentMenu', type => 'tabs'), title => 'Comment Documents');
    #$menu1->addMenu(name => "comments", label => "Comments", contents => $commentsMenu->buildMenus(name=>'commentsMenu', type => 'tabs'), title => 'Comments');
    #$menu1->addMenu(name => "commentors", label => "Commentors", contents => $commentorsMenu->buildMenus(name=>'commentorsMenu', type => 'tabs'), title => 'Commentors');

    my $menutype = ((defined($crdcgi->param('menutype'))) ? $crdcgi->param('menutype') : "table");
    $menu1->imageSource("/eis/images/");
    print $menu1->buildMenus(name => 'ReportMenu1', type => $menutype);
    #print $menu1->buildMenus(name => 'ReportMenu1', type => 'buttons');
    #print $menu1->buildMenus(name => 'ReportMenu1', type => 'bullets');
    
    print "<br><br><br><br><br>\n";
    print "Try Top Menu as: <a href=http://intradev/cgi-bin/eis/test_menus.pl?menutype=table>table</a>, <a href=http://intradev/cgi-bin/eis/test_menus.pl?menutype=list>list</a>, <a href=http://intradev/cgi-bin/eis/test_menus.pl?menutype=buttons>buttons</a>, <a href=http://intradev/cgi-bin/eis/test_menus.pl?menutype=bullets>bullets</a>, or <a href=http://intradev/cgi-bin/eis/test_menus.pl?menutype=tabs>tabs</a>.\n"
    
};
if ($@) {
    print $@;
}

db_disconnect($dbh);
print "</form></center></body>\n</html>\n";

#----------------------------------------------------------------------------------------------------------------------------------------------
# Object definitions 
#
package Report_Forms; {

my $warn = $^W;
$^W = 0;
my %objHash = {
        'label' => '',
        'contents' => ''
    };
$^W = $warn;

sub label {
    my $self = shift;
    if (@_) {
        return $self->{label} = shift;
    } else {
        return $self->{label};
    }
}

sub contents {
    my $self = shift;
    if (@_) {
        return $self->{contents} = shift;
    } else {
        return $self->{contents};
    }
}

sub new {
    my $self = {};
    $self = { %objHash };
    bless $self;
    return $self;
}

# proccess variable name methods
#sub AUTOLOAD {
#    my $self = shift;
#    my $type = ref($self) || croak "$self is not an object";
#    my $name = $AUTOLOAD;
#    $name =~ s/.*://; # strip fully-qualified portion
#    unless (exists $self->{$name} ) {
#        croak "Can't Access '$name' field in object of class $type";
#    }
#    if (@_) {
#        return $self->{$name} = shift;
#    } else {
#        return $self->{$name};
#    }
#}

}
