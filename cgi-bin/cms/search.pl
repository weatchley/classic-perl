#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/cms/perl/RCS/search.pl,v $
#
# $Revision: 1.10 $
#
# $Date: 2002/03/08 20:52:54 $
#
# $Author: naydenoa $
#
# $Locker:  $
#
# $Log: search.pl,v $
# Revision 1.10  2002/03/08 20:52:54  naydenoa
# Fixed forward to login screen when loaded outside frames.
# Updated header for cgi upgrade.
#
# Revision 1.9  2001/11/15 23:35:39  naydenoa
# Added action search.
#
# Revision 1.8  2001/02/13 21:47:16  naydenoa
# Added search of remarks for issues and commitments
#
# Revision 1.7  2000/10/25 18:00:47  mccartym
# netscape changes
#
# Revision 1.1  2000/10/25 17:38:49  mccartym
# Initial revision
#
# Revision 1.6  2000/10/19 22:58:15  mccartym
# add search of historical issues and commitments in the oncs schema
#
# Revision 1.5  2000/10/07 01:17:20  mccartym
# more reformatting, remove log_history calls
#
# Revision 1.4  2000/10/06 20:51:37  munroeb
# added log_activity feature to script
#
# Revision 1.3  2000/10/06 18:35:42  mccartym
# reformat
#
# Revision 1.2  2000/09/21 22:57:05  atchleyb
# updated title
#
# Revision 1.1  2000/09/21 00:28:56  mccartym
# Initial revision
#
#
use integer;
use strict;
use ONCS_Header qw(:Constants);
use ONCS_specific;
use UI_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use CGI qw(param);
use DBI;
use DBD::Oracle qw(:ora_types);

my $cmscgi = new CGI;
my $loginusername = $cmscgi->param("loginusername");
my $loginusersid = $cmscgi->param("loginusersid");
my $schema = $cmscgi->param("schema");
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $command = defined($cmscgi->param("command")) ? $cmscgi->param("command") : "";
my $searchString = defined($cmscgi->param("searchstring")) ? $cmscgi->param("searchstring") : "";
my $historicalSchema = "oncs";
my $results = "<center>";
my $rows = 0;
my $errorstr = "";
my $checked;
my $dbh;

##################
sub errorMessage {
##################
#  Constructs and returns a formatted error message including the 
#  application-specific and oracle error strings and instructions
#  for getting help.  This string is intended to be displayed by a 
#  javascript alert() call.  Also writes an error message to the 
#  database activity_log table and to the web server error log.  
#  The web server error log message consists of the date/time the
#  error occurred, the username, userid, and schema in effect, and 
#  the application-specific and oracle error strings.  Required
#  parameters are: 
#                  
#     dbh         - database handle
#     username    -                
#     userid      -                
#     schema      - database schema
#     appError    - application-specific error string
#     oracleError - oracle error string - obtained from $@ after 
#                   attempting to execute SQL statement(s) inside an eval{}
#  
###################
   my ($dbh, $username, $userid, $schema, $appError, $oracleError) = @_;
   my $instructions = "Please save the diagnostic information shown above and contact the Computer Support Center at (702) 794-1335 for assistance.";
   my $errorMessage = "The following error occurred while attempting to $appError:\n\n$oracleError\n$instructions\n";
   my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
   $mon = &formatID('', 2, ++$mon);
   $mday = &formatID('', 2, $mday);
   $year += 1900;
   $hour = &formatID('', 2, $hour);
   $min = &formatID('', 2, $min);
   $sec = &formatID('', 2, $sec);
   print STDERR "\n CMS error: $mon/$mday/$year $hour:$min:$sec - $username/$userid/$schema - $appError failed:\n$oracleError\n";
   my $logError = $appError;
   $logError .= " - " . $oracleError if ($oracleError);
   &log_activity($dbh, 'T', $userid, $logError);
   return ($errorMessage);
}

##############
sub formatID {
##############
   return (sprintf("$_[0]%0$_[1]d", $_[2]));
}

###########
sub debug {
###########
   my $output = "";
   if (index($ENV{'DOCUMENT_ROOT'}, "dev") >= 1) {
      $output = "<table width=750 border=1>";
      my @list = $cmscgi->param();
      foreach my $item (@list) {
          my $val = $cmscgi->param($item);
        $output .= "<tr><td><b>$item</b></td><td><b>$val</b></tr></td>";
      }
      $output .= "</table>\n";
   }
   return ($output);
}

############################
sub getStringDisplayLength {
############################
   my %args = (
      @_,
   );
   return ($cmscgi->param('fullText') eq 'truncate') ? 250 : length($args{str});
}

################
sub matchFound {
################
   my %args = (
      @_,
   );
   my $out;
   if (defined($cmscgi->param("case"))) {
      $out = ($args{text} =~ m/$args{searchString}/) ? 1 : 0;
   } else {
      $out = ($args{text} =~ m/$args{searchString}/i) ? 1 : 0;
   }
   return ($out);
}

######################
sub highlightResults {
######################
   my %args = (
      @_,
   );
   my $out = $args{text};
   if (defined($cmscgi->param("case"))) {
      $out =~ s/($args{searchString})/<font color=#ff0000>$1<\/font>/g;
   } else {
      $out =~ s/($args{searchString})/<font color=#ff0000>$1<\/font>/ig;
   }
   return ($out);
}

##################
sub processError {
##################
   my %args = (
      @_,
   );
   my $error = &errorMessage($dbh, $loginusername, $loginusersid, $schema, $args{activity}, $@);
   $error =  ('_' x 100) . "\n\n" . $error if ($errorstr ne "");
   $error =~ s/\n/\\n/g;
   $error =~ s/'/%27/g;
   $errorstr .= $error;
}

##############
sub doSearch {
##############
   eval {
      $searchString =~ s/\\/\\\\/g;
      $searchString =~ s/\{/\\\{/g;
      $searchString =~ s/\}/\\\}/g;
      $searchString =~ s/\(/\\\(/g;
      $searchString =~ s/\)/\\\)/g;
      $searchString =~ s/\[/\\\[/g;
      $searchString =~ s/\]/\\\]/g;
      $searchString =~ s/\*/\\\*/g;
      $searchString =~ s/\./\\\./g;
      $searchString =~ s/\?/\\\?/g;
      $searchString =~ s/\+/\\\+/g;
      $searchString =~ s/\|/\\\|/g;
      $searchString =~ s/\^/\\\^/g;
      $searchString =~ s/\$/\\\$/g;
      $searchString =~ s.\/.\\\/.g;
      $results .= &start_table(4, 'center', 50, 90, 120, 490);
      $results .= &title_row('#a0e0c0', '#000099', '<font size=3>Search Results: Found <x> Matches</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to view individual results</font></i>)');
      $results .= &add_header_row();
      $results .= &add_col() . '<center>ID</center>';
      $results .= &add_col() . '<center>Record Type</center>';
      $results .= &add_col() . '<center>Data Element</center>';
      $results .= &add_col() . '<center>Text</center>';
      if (defined($cmscgi->param("doissues"))) {
         my $recordType = "ISSUE";
         my @resultTypes = ("TEXT");
         my $sql = "select issueid, text from $schema.issue order by issueid";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my @columns = $csr->fetchrow_array) {
            my @types = @resultTypes;
            my $id = shift(@columns);
            my $issueID = &formatID('I', 5, $id);
            foreach my $text (@columns) {
               my $resultType = shift(@types);
               if (defined($text) && &matchFound(text => $text, searchString => $searchString)) {
                  $rows++;
                  $results .= &add_row();
                  my $prompt = "Click here for full information on issue $issueID";
                  $results .= &add_col() . "<center><a href=javascript:issue($id) title='$prompt'>$issueID</a></center>";
                  $results .= &add_col() . "<center>$recordType</center>";
                  $results .= &add_col() . "<center>$resultType</center>";
                  $text = &highlightResults(text => $text, searchString => $searchString);
                  $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
               }
            }
         }
         my $sql2 = "select issueid, text from $schema.issue_remarks order by issueid, dateentered desc";
         my $csr2 = $dbh->prepare($sql2);
         $csr2->execute;
         while (my @columns = $csr2->fetchrow_array) {
            my @types = ("REMARKS");
            my $id = shift(@columns);
            my $issueID = &formatID('I', 5, $id);
            foreach my $text (@columns) {
               my $resultType = shift(@types);
               if (defined($text) && &matchFound(text => $text, searchString => $searchString)) {
                  $rows++;
                  $results .= &add_row();
                  my $prompt = "Click here for full information on issue $issueID";
                  $results .= &add_col() . "<center><a href=javascript:issue($id) title='$prompt'>$issueID</a></center>";
                  $results .= &add_col() . "<center>$recordType</center>";
                  $results .= &add_col() . "<center>$resultType</center>";
                  $text = &highlightResults(text => $text, searchString => $searchString);
                  $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
               }
            }
         }
      }
      if (defined($cmscgi->param("dohistoricalissues"))) {
         my $recordType = "HISTORICAL<br>ISSUE";
         my @resultTypes = ("TEXT");
         my $sql = "select issueid, text from $historicalSchema.issue order by issueid";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my @columns = $csr->fetchrow_array) {
            my @types = @resultTypes;
            my $id = shift(@columns);
            my $issueID = &formatID('HI', 5, $id);
            foreach my $text (@columns) {
               my $resultType = shift(@types);
               if (defined($text) && &matchFound(text => $text, searchString => $searchString)) {
                  $rows++;
                  $results .= &add_row();
                  $results .= &add_col() . "<center>$issueID</center>";
                  $results .= &add_col() . "<center>$recordType</center>";
                  $results .= &add_col() . "<center>$resultType</center>";
                  $text = &highlightResults(text => $text, searchString => $searchString);
                  $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
               }
            }
         }
      }
      if (defined($cmscgi->param("docommitments"))) {
         my $recordType = "COMMITMENT";
         my @resultTypes = ("TEXT", "ESTIMATE", "RATIONALE", "FUNCTIONAL RECOMMENDATION", "MANAGER RECOMMENDATION", "ACTION SUMMARY");
         push (@resultTypes, "ACTION PLAN", "APPROVAL RATIONALE", "REJECTION RATIONALE", "RESUBMIT RATIONALE", "ACTIONS TAKEN");
         push (@resultTypes, "CONTROL ACCOUNT ID");
         my $sql = "select commitmentid, text, estimate, commitmentrationale, functionalrecommend, cmrecommendation, actionsummary, ";
         $sql .= "actionplan, approvalrationale, rejectionrationale, resubmitrationale, actionstaken, controlaccountid ";
         $sql .= "from $schema.commitment order by commitmentid";
         print STDERR "\n-->$sql<--\n";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my @columns = $csr->fetchrow_array) {
            my @types = @resultTypes;
            my $id = shift(@columns);
            my $commitmentID = &formatID('C', 5, $id);
            foreach my $text (@columns) {
               my $resultType = shift(@types);
               if (defined($text) && &matchFound(text => $text, searchString => $searchString)) {
                  $rows++;
                  $results .= &add_row();
                  my $prompt = "Click here for full information on commitment $commitmentID";
                  $results .= &add_col() . "<center><a href=javascript:commitment($id) title='$prompt'>$commitmentID</a></center>";
                  $results .= &add_col() . "<center>$recordType</center>";
                  $results .= &add_col() . "<center>$resultType</center>";
                  $text = &highlightResults(text => $text, searchString => $searchString);
                  $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
               }
            }
         }
         $csr->finish;

         my $sql2 = "select commitmentid, text from $schema.commitment_remarks order by commitmentid, dateentered desc";
         my $csr2 = $dbh->prepare($sql2);
         $csr2->execute;
         while (my @columns = $csr2->fetchrow_array) {
            my @types = ("REMARKS");
            my $id = shift(@columns);
            my $commitmentID = &formatID('C', 5, $id);
            foreach my $text (@columns) {
               my $resultType = shift(@types);
               if (defined($text) && &matchFound(text => $text, searchString => $searchString)) {
                  $rows++;
                  $results .= &add_row();
                  my $prompt = "Click here for full information on commitment $commitmentID";
                  $results .= &add_col() . "<center><a href=javascript:commitment($id) title='$prompt'>$commitmentID</a></center>";
                  $results .= &add_col() . "<center>$recordType</center>";
                  $results .= &add_col() . "<center>$resultType</center>";
                  $text = &highlightResults(text => $text, searchString => $searchString);
                  $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
               }
            }
         }
         $csr2->finish;
      }
      if (defined($cmscgi->param("dohistoricalcommitments"))) {
         my $recordType = "HISTORICAL<br>COMMITMENT";
         my @resultTypes = ("TEXT", "ESTIMATE", "RATIONALE", "FUNCTIONAL RECOMMENDATION", "MANAGER RECOMMENDATION", "ACTION SUMMARY");
         push (@resultTypes, "ACTION PLAN", "APPROVAL RATIONALE", "REJECTION RATIONALE", "RESUBMIT RATIONALE", "ACTIONS TAKEN");
         push (@resultTypes, "COMMENTS", "CONTROL ACCOUNT ID");
         my $sql = "select commitmentid, text, estimate, commitmentrationale, functionalrecommend, cmrecommendation, actionsummary, ";
         $sql .= "actionplan, approvalrationale, rejectionrationale, resubmitrationale, actionstaken, comments, controlaccountid ";
         $sql .= "from $historicalSchema.commitment order by commitmentid";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my @columns = $csr->fetchrow_array) {
            my @types = @resultTypes;
            my $id = shift(@columns);
            my $commitmentID = &formatID('HC', 5, $id);
            foreach my $text (@columns) {
               my $resultType = shift(@types);
               if (defined($text) && &matchFound(text => $text, searchString => $searchString)) {
                  $rows++;
                  $results .= &add_row();
                  $results .= &add_col() . "<center>$commitmentID</center>";
                  $results .= &add_col() . "<center>$recordType</center>";
                  $results .= &add_col() . "<center>$resultType</center>";
                  $text = &highlightResults(text => $text, searchString => $searchString);
                  $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
               }
            }
         }
         $csr->finish;
      }
      if (defined($cmscgi->param("doactions"))) {
         my $recordType = "ACTION";
         my @resultTypes = ("TEXT", "FULFILLMENT");
         my $sql = "select commitmentid, actionid, text, actionstaken from $schema.action order by commitmentid, actionid";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my @columns = $csr->fetchrow_array) {
            my @types = @resultTypes;
            my $cid = shift(@columns);
            my $aid = shift(@columns);
            my $actionID = &formatID('CA', 5, $cid) . formatID('/', 3, $aid);
            foreach my $text (@columns) {
               my $resultType = shift(@types);
               if (defined($text) && &matchFound(text => $text, searchString => $searchString)) {
                  $rows++;
                  $results .= &add_row();
                  my $prompt = "Click here for full information on action $actionID";
                  $results .= &add_col() . "<center><a href=javascript:action($cid,$aid) title='$prompt'>$actionID</a></center>";
                  $results .= &add_col() . "<center>$recordType</center>";
                  $results .= &add_col() . "<center>$resultType</center>";
                  $text = &highlightResults(text => $text, searchString => $searchString);
                  $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
               }
            }
         }
         my $sql2 = "select commitmentid, actionid, text from $schema.action_remarks order by commitmentid, actionid, dateentered desc";
         my $csr2 = $dbh->prepare($sql2);
         $csr2->execute;
         while (my @columns = $csr2->fetchrow_array) {
            my @types = ("REMARKS");
            my $cid = shift(@columns);
            my $aid = shift(@columns);
            my $actionID = &formatID('CA', 5, $cid) . formatID('/', 3, $aid);
            foreach my $text (@columns) {
               my $resultType = shift(@types);
               if (defined($text) && &matchFound(text => $text, searchString => $searchString)) {
                  $rows++;
                  $results .= &add_row();
                  my $prompt = "Click here for full information on action $actionID";
                  $results .= &add_col() . "<center><a href=javascript:action($cid,$aid) title='$prompt'>$actionID</a></center>";
                  $results .= &add_col() . "<center>$recordType</center>";
                  $results .= &add_col() . "<center>$resultType</center>";
                  $text = &highlightResults(text => $text, searchString => $searchString);
                  $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
               }
            }
         }
      }
      # add future search of letter (accessionnum, addressee), response (text), sourcedoc (several columns) tables?
      $results .= &end_table() . "</center><br><br>\n";
      &log_activity($dbh, 'F', $loginusersid, "Search for \"$searchString\"");
   };
   &processError(activity => "Search") if ($@);
}

#####################
sub writeHTTPHeader {
#####################
   my $output = $cmscgi->header('text/html');
   return ($output);
}

###############
sub writeHead {
###############
   my $output = <<end;
<html>
<head>
   <meta http-equiv=expires content=now>
   <script src=$ONCSJavaScriptPath/oncs-utilities.js></script>
   <script language=javascript><!--
      if (parent == self) { // not in frames
          location = '$ONCSCGIDir/login.pl';
      }
      doSetTextImageLabel('Search');
      function submitForm(script, command) {
         if (document.$form.searchstring.value == "") {
            alert ("No search string has been entered");
         } else {
            document.$form.action = '$path' + script + '.pl';
            document.$form.command.value = command;
            document.$form.submit();
         }
      }
      function commitment(id) {
         var script = 'browse';
         dummy.action = '$path' + script + '.pl';
         dummy.option.value = 'details';
         dummy.theinterface.value = 'commitments';
         dummy.interfaceLevel.value = 'commitmentid';
         dummy.id.value = id;
         dummy.submit();
      }
      function issue(id) {
         var script = 'browse';
         dummy.action = '$path' + script + '.pl';
         dummy.option.value = 'details';
         dummy.theinterface.value = 'issues';
         dummy.interfaceLevel.value = 'issueid';
         dummy.id.value = id;
         dummy.submit();
     }
     function action(cid, aid) {
         var script = 'browse';
         dummy.action = '$path' + script + '.pl';
         dummy.option.value = 'details';
         dummy.theinterface.value = 'actions';
         dummy.interfaceLevel.value = 'commitmentid';
         dummy.id.value = cid;
	 dummy.actionid.value = aid;
         dummy.submit();
      }
   //-->
   </script>
</head>
end
   return ($output);
}

###############
sub writeBody {
###############
   my $border = 0;
   my $output = "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
   $output .= "<font face='Times New Roman' color='#000099'>\n";
#   $output .= &debug();
   $output .= "<form name=$form action=$ENV{SCRIPT_NAME} method=post>\n";
   $output .= "<input type=hidden name=loginusername value=$loginusername>\n";
   $output .= "<input type=hidden name=loginusersid value=$loginusersid>\n";
   $output .= "<input type=hidden name=schema value=$schema>\n";
   $output .= "<input type=hidden name=command value=0>\n";
   $output .= "<table width=680 border=$border cellpadding=3 cellspacing=3>\n";
   $output .= "<tr><td colspan=2><b>Search for:" . &nbspaces(3) . "<input type=text name=searchstring maxlength=100 size=60>\n";
   $searchString =~ s/'/%27/g;
   $output .= "<script language=javascript>\n<!--\nvar mytext ='$searchString';\ndocument.$form.searchstring.value = unescape(mytext);\n//-->\n</script>\n";
   $output .= "<input type=button name=dosearch value=Submit onClick=javascript:submitForm('search','dosearch')></td></tr><ul>\n";

   $output .= "<tr><td width=10% valign=top><li><b>Search:</b></li>" . &nbspaces(4) . "</td>\n";
   $checked = (defined($cmscgi->param("doissues")) || ($command ne "dosearch")) ? "checked" : "" ;
   $output .= "<td><b><input type=checkbox name=doissues value=issues $checked> Issues</b>\n";
   $checked = (defined($cmscgi->param("docommitments")) || ($command ne "dosearch")) ? "checked" : "" ;
   $output .= &nbspaces(3) . "<b><input type=checkbox name=docommitments value=commitments $checked> Commitments\n";
   $checked = (defined($cmscgi->param("doactions")) || ($command ne "dosearch")) ? "checked" : "" ;
   $output .= "<b><input type=checkbox name=doactions value=actions $checked> Actions</b>\n";

   $checked = (defined($cmscgi->param("dohistoricalissues"))) ? "checked" : "" ;
   $output .= "<br><input type=checkbox name=dohistoricalissues value=historicalissues $checked> Historical Issues</b>\n";
   $checked = (defined($cmscgi->param("dohistoricalcommitments"))) ? "checked" : "" ;
   $output .= &nbspaces(3) . "<b><input type=checkbox name=dohistoricalcommitments value=historicalcommitments $checked> Historical Commitments</b></td></tr>\n";

   $checked = (defined($cmscgi->param("case"))) ? "checked" : "" ;
   $output .= "<tr><td><li><b>Options:</li></b></td><td><b><input type=checkbox name=case value=case $checked> Case sensitive search</b></td></tr>\n";

   my $fullText = $cmscgi->param("fullText");
   $checked = ($fullText ne 'truncate') ? "checked" : "" ;
   $output .= "<tr><td><li><b>Show:</b></li></td><td><b><input type=radio name=fullText value=full $checked>full text" . &nbspaces(2);
   $checked = ($fullText eq 'truncate') ? "checked" : "" ;
   $output .= "<input type=radio name=fullText value=truncate $checked>first 250 characters" . &nbspaces(3) . "of each result</b></td></tr>\n";

   $output .= "</ul></table></form><br><br>\n";
   if (($command eq "dosearch") && !$errorstr) {
      if ($rows > 0) {
         $results =~ s/<x>/$rows/;
         $results =~ s/Matches/Match/ if ($rows == 1);
         $output .= $results;
      } else {
         my $message = "No matches found for \"$searchString\"";
         $message =~ s/'/%27/g;
         $output .= "<script language=javascript>\n<!--\nvar mytext ='$message';\nalert(unescape(mytext));\n//-->\n</script>\n";
      }
   }
   $output .= "<form name=dummy method=post>\n";
   $output .= "<input type=hidden name=loginusername value=$loginusername>\n";
   $output .= "<input type=hidden name=loginusersid value=$loginusersid>\n";
   $output .= "<input type=hidden name=schema value=$schema>\n";
   $output .= "<input type=hidden name=id value=0>\n";
   $output .= "<input type=hidden name=actionid value=0>\n";
   $output .= "<input type=hidden name=option value='details'>\n";
   $output .= "<input type=hidden name=theinterface value='commitments'>\n";
   $output .= "<input type=hidden name=interfaceLevel value='commitmentid'>\n";
   $output .= "</form>\n";
   $output .= "<script language=javascript>\n<!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n" if ($errorstr);
   $output .= "</font></center></body>\n</html>\n";
   return ($output);
}

#######################
$dbh = &oncs_connect();
$dbh->{RaiseError} = 1;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;
&doSearch() if ($command eq 'dosearch');
print &writeHTTPHeader();
print &writeHead();
print &writeBody();
$dbh->{RaiseError} = 0;
&oncs_disconnect($dbh);
exit();
