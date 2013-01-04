#!/usr/local/bin/perl -w
#
# -*- Mode: perl; indent-tabs-mode: nil -*-
#
# $Source: /data/dev/rcs/dms/perl/RCS/search.pl,v $
#
# $Revision: 1.5 $
#
# $Date: 2002/08/08 14:38:09 $
#
# $Author: munroeb $
#
# $Locker: munroeb $
#
# $Log: search.pl,v $
# Revision 1.5  2002/08/08 14:38:09  munroeb
# fixed error in browse option and selection criteria
#
# Revision 1.4  2002/07/08 21:37:48  munroeb
# fixed links on results page
#
# Revision 1.3  2002/05/28 16:34:45  atchleyb
# updated categories and fixed table problem
#
# Revision 1.2  2002/03/13 17:45:55  atchleyb
# removed mockup code and made functional
#
# Revision 1.1  2002/03/08 21:11:54  atchleyb
# Initial revision
#
#
#
use integer;
use strict;
use DMS_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);
my $dmscgi = new CGI;
my $userid = $dmscgi->param("userid");
my $username = $dmscgi->param("username");
my $schema = $dmscgi->param("schema");
&checkLogin ($username, $userid, $schema);
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $command = defined($dmscgi->param("command")) ? $dmscgi->param("command") : "";
my $searchString = defined($dmscgi->param("searchstring")) ? $dmscgi->param("searchstring") : "";
my $results = "<center>";
my $rows = 0;
my $errorstr = "";
my $checked;
my $dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;
$| = 1;


###################################################################################################################################
sub getStringDisplayLength {                                                                                                      #
###################################################################################################################################
   my %args = (
      @_,
   );
   return ($dmscgi->param('fullText') eq 'truncate') ? 250 : length($args{str});
}

###################################################################################################################################
sub matchFound {                                                                                                                  #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out;
   if (defined($args{text})) {
       if (defined($dmscgi->param("case"))) {
          $out = ($args{text} =~ m/$args{searchString}/) ? 1 : 0;
       } else {
          $out = ($args{text} =~ m/$args{searchString}/i) ? 1 : 0;
       }
   } else {
       $out = 0;
   }
   return ($out);
}

###################################################################################################################################
sub highlightResults {                                                                                                            #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = $args{text};
   if (defined($dmscgi->param("case"))) {
      $out =~ s/($args{searchString})/<font color=#ff0000>$1<\/font>/g;
   } else {
      $out =~ s/($args{searchString})/<font color=#ff0000>$1<\/font>/ig;
   }
   return ($out);
}

###################################################################################################################################
sub processError {                                                                                                                #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $error = &errorMessage($dbh, $username, $userid, $schema, $args{activity}, $@);
   $error =  ('_' x 100) . "\n\n" . $error if ($errorstr ne "");
   $error =~ s/\n/\\n/g;
   $error =~ s/'/%27/g;
   $errorstr .= $error;
}


###################################################################################################################################
###################################################################################################################################

print $dmscgi->header('text/html');
print <<end;
<html>
<head>
   <meta http-equiv=expires content=now>
   <script src=$DMSJavaScriptPath/utilities.js></script>
   <script language=javascript><!--
      function submitForm(script, command) {
         if ($form.searchstring.value == "") {
            alert ("No search string has been entered");
         } else {
            $form.action = '$path' + script + '.pl';
            $form.command.value = command;
            $form.submit();
         }
      }

	  function decision(decisionid) {
		 document.search.command2.value = 'detailview';
   		//alert(document.decisions.command2.value);
		document.search.command.value = 'browse';
		document.search.decisionid.value = decisionid;
		document.search.action = '/cgi-bin/dms/decisions.pl';
		document.search.target = 'main';
		document.search.submit();
	 }

      function decisionanalysis(decisionid) {
		document.search.command2.value = 'detailview';
   		//alert(document.decisions.command2.value);
		document.search.command.value = 'browse';
		document.search.decisionid.value = decisionid;
		document.search.action = '/cgi-bin/dms/decisions.pl';
		document.search.target = 'main';
		document.search.submit();
	  }

      function selection(decisionid) {
		document.search.command2.value = 'detailview';
   		//alert(document.decisions.command2.value);
		document.search.command.value = 'browse';
		document.search.decisionid.value = decisionid;
		document.search.action = '/cgi-bin/dms/decisions.pl';
		document.search.target = 'main';
		document.search.submit();
      }
      function option(decisionid) {
		document.search.command2.value = 'detailview';
   		//alert(document.decisions.command2.value);
		document.search.command.value = 'browse';
		document.search.decisionid.value = decisionid;
		document.search.action = '/cgi-bin/dms/decisions.pl';
		document.search.target = 'main';
		document.search.submit();
      }
   //-->
   </script>
</head>
end
my $border = 0;
print "<body background=$DMSImagePath/background.gif text=$DMSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
print "<font face=$DMSFontFace color=$DMSFontColor>\n";
print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Search");
print "<form name=$form action=$ENV{SCRIPT_NAME} method=post>\n";
print "<input type=hidden name=command2 value=\"\">\n";
print "<input type=hidden name=decisionid value=\"\">\n";

print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=command value=$command>\n";
print "<table width=750 border=$border cellpadding=0 cellspacing=7>\n";
print "<tr><td><b>Search for:" . &nbspaces(3) . "<input type=text name=searchstring maxlength=100 size=80></td>\n";
$searchString =~ s/'/%27/g;
print "<script language=javascript>\n<!--\nvar mytext ='$searchString';\n$form.searchstring.value = unescape(mytext);\n//-->\n</script>\n";
print "<td align=right><input type=button name=dosearch value=Submit onClick=javascript:submitForm('search','dosearch')></td></tr>\n";
print "</table><table width=750 border=$border cellpadding=0 cellspacing=7>\n";
my $fullText = $dmscgi->param("fullText");
$checked = ($fullText ne 'truncate') ? "checked" : "" ;
print "<tr><td><b>Show" . &nbspaces(1) . "<input type=radio name=fullText value=full $checked>full text" . &nbspaces(1);
$checked = ($fullText eq 'truncate') ? "checked" : "" ;
print "<input type=radio name=fullText value=truncate $checked>first 250 characters" . &nbspaces(2) . "of each result</b></td>\n";
$checked = (defined($dmscgi->param("case"))) ? "checked" : "" ;
print "<td align=right><b><input type=checkbox name=case value=case $checked> Case sensitive search</b></td></tr>\n";
print "</table><table width=750 border=$border cellpadding=0 cellspacing=7>";
#print "<tr><td><b>Search the following areas:</b></font></td></tr>\n";

print "<tr><td>\n";
print "<table border=0 width=75% cellpadding=0 cellspacing=0>\n";
print "<tr><td valign=top><b>Search: &nbsp; &nbsp;</b></td><td valign=top><table border=0 width=100% cellpadding=0 cellspacing=0>\n";
print "<tr><td valign=top><b>Executive Summary</b></td></tr>\n";
$checked = (defined($dmscgi->param("dostatementofconsideration"))) ? "checked" : "" ;
print "<tr><td><input type=checkbox name=dostatementofconsideration value=statementofconsideration $checked> Statement of Consideration</b></td></tr>\n";
$checked = (defined($dmscgi->param("dorecommendation"))) ? "checked" : "" ;
print "<tr><td><input type=checkbox name=dorecommendation value=recommendation $checked> Recommendation</b></td></tr>\n";
$checked = (defined($dmscgi->param("dodecision"))) ? "checked" : "" ;
print "<tr><td><input type=checkbox name=dodecision value=decision $checked> Decision</b></td></tr>\n";

print "</table></td><td> &nbsp; &nbsp; </td><td><table border=0 width=100% cellpadding=0 cellspacing=0>\n";

print "<tr><td valign=top><b>Decision Analysis</b></td></tr>\n";
$checked = (defined($dmscgi->param("doselectioncriteria"))) ? "checked" : "" ;
print "<tr><td><input type=checkbox name=doselectioncriteria value=selectioncriteria $checked> Selection Criteria</b></td></tr>\n";
$checked = (defined($dmscgi->param("dooptioncriteria"))) ? "checked" : "" ;
print "<tr><td><input type=checkbox name=dooptioncriteria value=optioncriteria $checked> Option Criteria</b></td></tr>\n";
$checked = (defined($dmscgi->param("dorecommendation"))) ? "checked" : "" ;
print "<tr><td><input type=checkbox name=dodecisionanalysisrecommendation value=decisionanalysisrecommendation $checked> Recommendation</b></td></tr>\n";
$checked = (defined($dmscgi->param("doreferences"))) ? "checked" : "" ;
print "<tr><td><input type=checkbox name=doreferences value=references $checked> References</b></td></tr>\n";

print "</table></td></tr>\n";

print "</table></form></font>\n";

if ($command eq 'dosearch') {
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
      $" = ',';
      #my $whereClause = "";
      $" = ' ';
      $results .= &start_table(3, 'center', 110, 110, 530);
      $results .= &title_row('#a0e0c0', '#000099', '<font size=3>Search Results: Found <x> Matches</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to view individual results</font></i>)');
      $results .= &add_header_row();
      $results .= &add_col() . 'ID';
      $results .= &add_col() . 'Result Type';
      $results .= &add_col() . 'Text';
      if (defined($dmscgi->param("dostatementofconsideration"))) {
         my $type = "STATEMENT OF CONSIDERATION";
         print "<!--$type-->\n";
         my $sql = "select decisionid, statementofconsideration from $schema.decisions order by decisionid";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($id, $text) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               #my $formattedid = &formatID($DMSType, 6, $id);
               my $formattedid = $id;
               my $prompt = "Click here for full information on decison $formattedid";
               $results .= &add_col() . "<center><a href=javascript:decision('$id') title='$prompt'>$formattedid</a></center>";
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }

      if (defined($dmscgi->param("dorecommendation"))) {
         my $type = "SUMMARY RECOMMENDATION";
         print "<!--$type-->\n";
         my $sql = "select decisionid, esrecommendation from $schema.decisions order by decisionid";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($id, $text) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               #my $formattedid = &formatID($DMSType, 6, $id);
               my $formattedid = $id;
               my $prompt = "Click here for full information on decison $formattedid";
               $results .= &add_col() . "<center><a href=javascript:decision('$id') title='$prompt'>$formattedid</a></center>";
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }

      if (defined($dmscgi->param("dodecision"))) {
         my $type = "DECISION";
         print "<!--$type-->\n";
         my $sql = "select decisionid, esdecision from $schema.decisions order by decisionid";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($id, $text) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               #my $formattedid = &formatID($DMSType, 6, $id);
               my $formattedid = $id;
               my $prompt = "Click here for full information on decison $formattedid";
               $results .= &add_col() . "<center><a href=javascript:decision('$id') title='$prompt'>$formattedid</a></center>";
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }

      if (defined($dmscgi->param("doselectioncriteria"))) {
         my $type = "SELECTION CRITERIA";
         print "<!--$type-->\n";
         my $sql = "select selectionid, decisionid, title, description from $schema.selection_criteria order by selectionid";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($id, $Did, $title, $text) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               #my $formattedid = &formatID($DMSType, 6, $id);
               my $formattedid = $Did;
               my $prompt = "Click here for full information on selection criteria item $formattedid";
               $results .= &add_col() . "<center><a href=javascript:selection('$Did') title='$prompt'>$formattedid</a></center>";
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }

      if (defined($dmscgi->param("dooptioncriteria"))) {
         my $type = "OPTION CRITERIA";
         print "<!--$type-->\n";
         my $sql = "select optionid, decisionid, description from $schema.options order by optionid";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($id, $Did, $text) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               #my $formattedid = &formatID($DMSType, 6, $id);
               my $formattedid = $Did;
               my $prompt = "Click here for full information on option criteria item $formattedid";
               $results .= &add_col() . "<center><a href=javascript:option('$Did') title='$prompt'>$formattedid</a></center>";
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }

      if (defined($dmscgi->param("dodecisionanalysisrecommendation"))) {
         my $type = "ANALYSIS REOMMENDATION";
         print "<!--$type-->\n";
         my $sql = "select decisionid, darecommendation from $schema.decisions order by decisionid";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($id, $text) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               #my $formattedid = &formatID($DMSType, 6, $id);
               my $formattedid = $id;
               my $prompt = "Click here for full information on decison analysis $formattedid";
               $results .= &add_col() . "<center><a href=javascript:decisionanalysis('$id') title='$prompt'>$formattedid</a></center>";
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }

      if (defined($dmscgi->param("doreferences"))) {
         my $type = "OPTION CRITERIA";
         print "<!--$type-->\n";
         my $sql = "select decisionid, dareferences from $schema.decisions order by decisionid";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($id, $text) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               #my $formattedid = &formatID($DMSType, 6, $id);
               my $formattedid = $id;
               my $prompt = "Click here for full information on decison analysis $formattedid";
               $results .= &add_col() . "<center><a href=javascript:decisionanalysis('$id') title='$prompt'>$formattedid</a></center>";
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }

      $results .= &end_table() . "</center>\n";
   };
   my $plural = ($rows != 1) ? "es" : "";
   if ($@) {
      &processError(activity => "search");
   } else {
      &log_activity ($dbh, $schema, $userid, "Search for \"$searchString\" - found $rows match$plural");
   }
   if ($errorstr) {
      $errorstr =~ s/\n/\\n/g;
      $errorstr =~ s/'/%27/g;
      print "<script language=javascript>\n<!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n";
   } else {
      if ($rows > 0) {
         $results =~ s/<x>/$rows/;
         $results =~ s/Matches/Match/ if ($rows == 1);
         print $results;
      } else {
         my $message = "No matches found for \"$searchString\"";
         $message =~ s/'/%27/g;
         print "<script language=javascript>\n<!--\nvar mytext ='$message';\nalert(unescape(mytext));\n//-->\n</script>\n";
      }
   }
}
print "<form name=dummy method=post>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=command value=0>\n";
print "<input type=hidden name=id value=0>\n";
print "<input type=hidden name=documentid value=0>\n";
print "<input type=hidden name=summarycommentid value=0>\n";
print "<input type=hidden name=commentid value=0>\n";
print "<input type=hidden name=version value=0>\n";
print "</form>\n";
print &BuildPrintCommentResponse($username, $userid, $schema, $path);
print "<script language=javascript>\n<!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n" if ($errorstr);
print "</body>\n</html>\n";
db_disconnect($dbh);
exit();
