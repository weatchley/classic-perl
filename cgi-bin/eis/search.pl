#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/crd/perl/RCS/search.pl,v $
#
# $Revision: 1.16 $
#
# $Date: 2002/02/21 00:32:21 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: search.pl,v $
# Revision 1.16  2002/02/21 00:32:21  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.15  2001/09/27 01:07:09  mccartym
# optimizations
#
# Revision 1.14  2001/09/26 16:55:20  mccartym
# Ability to select either/both approved and unapproved responses.
# Eliminate display of obsolete and rejected responses.
#
# Revision 1.13  2001/09/24 21:51:34  mccartym
# slight change to error logging
#
# Revision 1.12  2001/06/29 00:39:16  mccartym
# fix bug causing summary comment results to not appear
# remove preapproved responses, message points from initial baseline version
#
# Revision 1.11  2001/06/27 01:15:09  mccartym
# checkpoint
#
# Revision 1.10  2000/10/18 18:32:39  mccartym
# add option to include duplicate comments
#
# Revision 1.9  2000/05/18 15:35:45  mccartym
# change where clause for searching single bin so it works with summary comments
#
# Revision 1.8  2000/05/18 01:06:53  mccartym
# search summary comments, responses, and remarks
# highlight matches in displayed text
#
# Revision 1.7  2000/04/21 19:44:18  mccartym
# Use linked bin number instead of bin name in search results display
#
# Revision 1.6  2000/02/11 17:26:21  mccartym
# use commentor name instead of id in search results
#
# Revision 1.5  1999/11/30 22:17:17  mccartym
# change commentor id to five digits
#
# Revision 1.4  1999/11/25 01:43:47  mccartym
# escape special characters in search string
#
# Revision 1.3  1999/11/05 19:17:53  mccartym
# add search of commentor data and document addressee
#
# Revision 1.2  1999/11/04 16:18:09  mccartym
# implement initial search capability
#
# Revision 1.1  1999/08/02 03:05:15  mccartym
# Initial revision
#
use integer;
use strict;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);
my $crdcgi = new CGI;
my $userid = $crdcgi->param("userid");
my $username = $crdcgi->param("username");
my $schema = $crdcgi->param("schema");
&checkLogin ($username, $userid, $schema);
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $command = defined($crdcgi->param("command")) ? $crdcgi->param("command") : "";
my $bin = defined($crdcgi->param("bin")) ? $crdcgi->param("bin") : "";
my $searchString = defined($crdcgi->param("searchstring")) ? $crdcgi->param("searchstring") : "";
my $results = "<center>";
my $rows = 0;
my $errorstr = "";
my $checked;
my $dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;
$| = 1;

###################################################################################################################################
sub searchResponses {                                                                                                             #
###################################################################################################################################
   my %args = (
      statusWhere => "",
      binsWhere => "",
      @_,
   );

   my ($sql, $results, $rows) = ("", "", 0);
   if (defined($crdcgi->param($args{paramString}))) {
      print "<!--$args{type}-->\n";
      $sql = "select r.document, r.commentnum, r.version, r.status, r.lastsubmittedtext, b.id, b.name ";
      $sql .= "from $schema.response_version r, $schema.comments c, $schema.bin b ";
      $sql .= "where c.bin = b.id and r.document = c.document and r.commentnum = c.commentnum $args{statusWhere} $args{binsWhere} ";
      $sql .= "order by r.document, r.commentnum, r.version";
      my $csr = $dbh->prepare($sql);
      $csr->execute;
      while (my ($docid, $commentid, $version, $status, $text, $bin, $binName) = $csr->fetchrow_array) {
         if ($args{type} eq "UNAPPROVED RESPONSE") {
            $text = &lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $docid, commentID => $commentid, version => $version);
         }
         if (defined($text) && &matchFound(text => $text, searchString => $searchString)) {
            $rows++;
            $results .= &add_row();
            my $formattedid = &formatID($CRDType, 6, $docid) . " / " . &formatID("", 4, $commentid);
            my $prompt = "Click here for full information on response version $version to comment $formattedid";
            $formattedid .= " / " . &formatID("v. ", 2, $version);
            $results .= &add_col() . "<center><a href=javascript:responses($docid,$commentid,$version) title='$prompt'>$formattedid</a></center>";
            $results .= &writePrintCommentLink(document => $docid, comment => $commentid, version => $version);
            $results .= &writeBin(binID => $bin, binName => $binName);
            $results .= &add_col() . "<center>$args{type}</center>";
            $text = &highlightResults(text => $text, searchString => $searchString);
            $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
         }
      }
      $csr->finish;
   }
   return ($results, $rows);
}

###################################################################################################################################
sub getBinList {                                                                                                                  #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $bin = $crdcgi->param("bin");
   my @binList = ();
   if (!defined($crdcgi->param("subbins"))) {
      push(@binList, $bin);
   } else {
      my $csr = $dbh->prepare("select id from $schema.bin connect by prior id = parent start with id = $bin order by id");
      $csr->execute;
      while (my ($subbin) = $csr->fetchrow_array) {
         push(@binList, $subbin);
      }
      $csr->finish;
   }
   return @binList;
}

###################################################################################################################################
sub buildBinDropdown {                                                                                                            #
###################################################################################################################################
   my %args = (
      @_,
   );
   tie my %bins, "Tie::IxHash";
   $bins{0} = "--- Search All Bins ---";
   my $csr = $dbh->prepare("select id, name from $schema.bin order by name");
   $csr->execute;
   while (my ($id, $name) = $csr->fetchrow_array) {
      $bins{$id} = $name;
   }
   $csr->finish;
   my $selected;
   my $out = "<b>Bin:" . &nbspaces(2) . "</b><select name=bin size=1>\n";
   foreach my $id (keys (%bins)) {
      if (defined($crdcgi->param("bin"))) {
         $selected = ($id == $crdcgi->param("bin")) ? "selected" : "";
      } else {
         $selected = ($id == 0) ? "selected" : "";
      };
      $out .= "<option value='$id' $selected>$bins{$id}\n";
   }
   $out .= "</select>\n";
   return ($out);
}

###################################################################################################################################
sub getStringDisplayLength {                                                                                                      #
###################################################################################################################################
   my %args = (
      @_,
   );
   return ($crdcgi->param('fullText') eq 'truncate') ? 250 : length($args{str});
}

###################################################################################################################################
sub matchFound {                                                                                                                  #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out;
   if (defined($crdcgi->param("case"))) {
      $out = ($args{text} =~ m/$args{searchString}/) ? 1 : 0;
   } else {
      $out = ($args{text} =~ m/$args{searchString}/i) ? 1 : 0;
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
   if (defined($crdcgi->param("case"))) {
      $out =~ s/($args{searchString})/<font color=#ff0000>$1<\/font>/g;
   } else {
      $out =~ s/($args{searchString})/<font color=#ff0000>$1<\/font>/ig;
   }
   return ($out);
}

###################################################################################################################################
sub writePrintCommentLink {                                                                                                       #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      addTableColumn => 1,
      useIcon => 1,
      icon => "$CRDImagePath/printer.gif",
      linkText => "print the comment and response text",
      @_,
   );
   my $out = ($args{addTableColumn}) ? &add_col() . "<center>" : "";
   if ($args{writeHeader}) {
      $out .= "<image src=$CRDImagePath/printer.gif border=0>";
   } elsif ($args{document} == 0) {
      $out .= "N/A";
   } else {
      my $formattedid = &formatID($CRDType, 6, $args{document}) . " / " . &formatID("", 4, $args{comment});
      my $version = ($args{version}) ? " version $args{version}" : "";
      my $prompt = "Click here for $formattedid comment and response$version text report";
      $version = ($args{version}) ? ",$args{version}" : "";
      $out .= "<a href=javascript:submitPrintCommentResponse($args{document},$args{comment}$version) title='$prompt'>";
      if ($args{useIcon}) {
         $out .= "<image src=$args{icon} border=0>";
      } else {
         $out .= "$args{linkText}";
      }
      $out .= "</a>";
   }
   $out .= "</center>" if ($args{addTableColumn});
   return ($out);
}

###################################################################################################################################
sub getBinNumber {                                                                                                                #
###################################################################################################################################
   my %args = (
      @_,
   );
   $args{binName} =~ m/([0-9].*?)[ ]/;
   return ($1);
}

###################################################################################################################################
sub writeBin {                                                                                                                    #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Bin",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $prompt = "Click here to browse bin $args{binName}";
      $out .= "<center><a href=javascript:display_bin($args{binID}) title='$prompt'>";
      $out .= &getBinNumber(binName => $args{binName});
      $out .= "</a></center>";
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

print $crdcgi->header('text/html');
print <<end;
<html>
<head>
   <meta http-equiv=expires content=now>
   <script src=$CRDJavaScriptPath/utilities.js></script>
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
      function documents(docid) {
         var script = 'comment_documents';
         dummy.action = '$path' + script + '.pl';
         dummy.command.value = 'browse2';
         dummy.id.value = docid;
         dummy.submit();
      }
      function comments(docid, commentid) {
         var script = 'comments';
         dummy.action = '$path' + script + '.pl';
         dummy.command.value = 'browse';
         dummy.id.value = docid;
         dummy.commentid.value = commentid;
         dummy.submit();
      }
      function responses(docid, commentid, version) {
         var script = 'responses';
         dummy.action = '$path' + script + '.pl';
         dummy.command.value = 'browse';
         dummy.id.value = docid;
         dummy.commentid.value = commentid;
         dummy.version.value = version;
         dummy.submit();
      }
      function preapproved(id) {
         var script = 'preapproved_text';
         dummy.action = '$path' + script + '.pl';
         dummy.command.value = 'browse';
         dummy.id.value = id;
         dummy.submit();
      }
      function commentors(id) {
         var script = 'commentors';
         dummy.action = '$path' + script + '.pl';
         dummy.command.value = 'display';
         dummy.id.value = id;
         dummy.submit();
      }
      function display_bin(id) {
         var script = 'bins';
         dummy.action = '$path' + script + '.pl';
         dummy.command.value = 'browse';
         dummy.binid.value = id;
         dummy.submit();
      }
      function displaySummaryComment(id) {
         var script = 'summary_comments';
         dummy.summarycommentid.value = id;
         dummy.action = '$path' + script + '.pl';
         dummy.command.value = 'browseSummaryComment';
         dummy.submit();
      }
   //-->
   </script>
</head>
end
my $border = 0;
print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
print "<font face=$CRDFontFace color=$CRDFontColor>\n";
print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Search");
print "<form name=$form action=$ENV{SCRIPT_NAME} method=post>\n";
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
my $fullText = $crdcgi->param("fullText");
$checked = ($fullText ne 'truncate') ? "checked" : "" ;
print "<tr><td><b>Show" . &nbspaces(1) . "<input type=radio name=fullText value=full $checked>full text" . &nbspaces(1);
$checked = ($fullText eq 'truncate') ? "checked" : "" ;
print "<input type=radio name=fullText value=truncate $checked>first 250 characters" . &nbspaces(2) . "of each result</b></td>\n";
$checked = (defined($crdcgi->param("case"))) ? "checked" : "" ;
print "<td align=right><b><input type=checkbox name=case value=case $checked> Case sensitive search</b></td></tr>\n";
print "</table><table width=750 border=$border cellpadding=0 cellspacing=7>";
print "<tr><td><b>Search the following areas:</b></font></td></tr>\n";
print "<tr><td align=right><table border=$border cellpadding=0 cellspacing=7>\n";
$checked = (defined($crdcgi->param("docommentors"))) ? "checked" : "" ;
print "<tr><td width=150><b><input type=checkbox name=docommentors value=commentors $checked> Commentors</b></td>\n";
$checked = (defined($crdcgi->param("dodocumentremarks"))) ? "checked" : "" ;
print "<td width=200><b><input type=checkbox name=dodocumentremarks value=document_remarks $checked> Document Remarks</b></td>\n";
$checked = (defined($crdcgi->param("doaddressee"))) ? "checked" : "" ;
print "<td width=350><b><input type=checkbox name=doaddressee value=addressee $checked> Document Addressee</b></td></tr>\n";
print "</table></td></tr>\n";
print "<tr><td align=right><table border=$border cellpadding=0 cellspacing=0>\n";
print "<tr><td>" . &buildBinDropdown() . "</td>";
$checked = (defined($crdcgi->param("subbins")) || ($command ne "dosearch")) ? "checked" : "" ;
print "<td><b>" .  &nbspaces(4) . "<input type=checkbox name=subbins value=subbins $checked> Search subbins</b></td></tr>\n";
print "</table></td></tr>";
print "<tr><td align=right><table border=$border cellpadding=0 cellspacing=7 width=715><ul>\n";
print "<tr><td colspan=4><li><b>Individual Comments and Responses</b></td></tr>\n";
print "<tr><td width=15>&nbsp;</td>\n";
$checked = (defined($crdcgi->param("docomments")) || ($command ne "dosearch")) ? "checked" : "" ;
print "<td width=230><b><input type=checkbox name=docomments value=comments $checked>Original Comments</b></td>\n";
$checked = (defined($crdcgi->param("doduplicatecomments"))) ? "checked" : "" ;
print "<td width=230><b><input type=checkbox name=doduplicatecomments value=duplicatecomments $checked>Duplicate Comments</b></td>\n";
$checked = (defined($crdcgi->param("docommentremarks"))) ? "checked" : "" ;
print "<td width=240><b><input type=checkbox name=docommentremarks value=comment_remarks $checked>Comment Remarks</b></td>";
print "</tr><tr><td width=15>&nbsp;</td>\n";
$checked = (defined($crdcgi->param("doresponses")) || ($command ne "dosearch")) ? "checked" : "" ;
print "<td><b><input type=checkbox name=doresponses value=responses $checked>Unapproved Responses</b></td>\n";
$checked = (defined($crdcgi->param("doapprovedresponses")) || ($command ne "dosearch")) ? "checked" : "" ;
print "<td><b><input type=checkbox name=doapprovedresponses value=approvedresponses $checked>Approved Responses</b></td>\n";
$checked = (defined($crdcgi->param("doreviews"))) ? "checked" : "" ;
print "<td><b><input type=checkbox name=doreviews value=reviews $checked>Technical Reviews</b></td>\n";
print "</tr><tr>\n";
print "<td colspan=4 height=30 valign=bottom><li><b>Summary Comment/Responses</b></td></tr>\n";
print "<tr><td width=15>&nbsp;</td>\n";
$checked = (defined($crdcgi->param("dosummarycomment"))) ? "checked" : "" ;
print "<td><b><input type=checkbox name=dosummarycomment value=summarycomments $checked>Summary Comments</b></td>\n";
$checked = (defined($crdcgi->param("dosummaryresponse"))) ? "checked" : "" ;
print "<td><b><input type=checkbox name=dosummaryresponse value=summaryresponses $checked>Summary Responses</b></td>\n";
$checked = (defined($crdcgi->param("dosummaryremark"))) ? "checked" : "" ;
print "<td><b><input type=checkbox name=dosummaryremark value=summaryremarks $checked>Summary Remarks</b></td>\n";
print "</tr></ul></table></td></tr>\n";
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
      my @binList = &getBinList();
      $" = ',';
      my $whereClause = ($bin == 0) ? "" : "and b.id in (@binList)";
      $" = ' ';
      $results .= &start_table(5, 'center', 80, 20, 40, 80, 530);
      $results .= &title_row('#a0e0c0', '#000099', '<font size=3>Search Results: Found <x> Matches</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to view individual results</font></i>)');
      $results .= &add_header_row();
      $results .= &add_col() . 'ID';
      $results .= &writePrintCommentLink(writeHeader => 1);
      $results .= &writeBin(writeHeader => 1);
      $results .= &add_col() . 'Result Type';
      $results .= &add_col() . 'Text';
      if (defined($crdcgi->param("dodocumentremarks"))) {
         my $type = "DOCUMENT REMARK";
         print "<!--$type-->\n";
         my $sql = "select document, text from $schema.document_remark order by document";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($docid, $text) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               my $formattedid = &formatID($CRDType, 6, $docid);
               my $prompt = "Click here for full information on comment document $formattedid";
               $results .= &add_col() . "<center><a href=javascript:documents($docid) title='$prompt'>$formattedid</a></center>";
               $results .= &writePrintCommentLink(document => 0);
               $results .= &add_col() . "<center>N/A</center>";
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }
      if (defined($crdcgi->param("doaddressee"))) {
         my $type = "ADDRESSEE";
         print "<!--$type-->\n";
         my $sql = "select id, addressee from $schema.document order by id";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($docid, $text) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               my $formattedid = &formatID($CRDType, 6, $docid);
               my $prompt = "Click here for full information on comment document $formattedid";
               $results .= &add_col() . "<center><a href=javascript:documents($docid) title='$prompt'>$formattedid</a></center>";
               $results .= &writePrintCommentLink(document => 0);
               $results .= &add_col() . "<center>N/A</center>";
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }
      if (defined($crdcgi->param("docomments")) || defined($crdcgi->param("doduplicatecomments"))) {
         my $type = "COMMENT";
         print "<!--$type-->\n";
         my $dupWhere = "";
         if (!defined($crdcgi->param("docomments"))) {
            $dupWhere = " and c.dupsimstatus = 2";
         } elsif (!defined($crdcgi->param("doduplicatecomments"))) {
            $dupWhere = " and c.dupsimstatus = 1";
         }
         my $sql = "select c.document, c.commentnum, b.id, b.name, c.text, c.dupsimstatus from $schema.comments c, $schema.bin b where c.bin = b.id $dupWhere $whereClause order by c.document, c.commentnum";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($docid, $commentid, $bin, $binName, $text, $dup) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               my $formattedid = &formatID($CRDType, 6, $docid) . " / " . &formatID("", 4, $commentid);
               my $prompt = "Click here for full information on comment $formattedid";
               $results .= &add_col() . "<center><a href=javascript:comments($docid,$commentid) title='$prompt'>$formattedid</a></center>";
               $results .= &writePrintCommentLink(document => $docid, comment => $commentid);
               $results .= &writeBin(binID => $bin, binName => $binName);
               $type = ($dup == 1) ? "COMMENT" : "DUPLICATE<br>COMMENT";
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }
      if (defined($crdcgi->param("docommentremarks"))) {
         my $type = "COMMENT REMARK";
         print "<!--$type-->\n";
         my $sql = "select cr.document, cr.commentnum, b.id, b.name, cr.text from $schema.comments_remark cr, $schema.bin b, $schema.comments c where c.bin = b.id and cr.document = c.document and cr.commentnum = c.commentnum $whereClause order by cr.document, cr.commentnum";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($docid, $commentid, $bin, $binName, $text) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               my $formattedid = &formatID($CRDType, 6, $docid) . " / " . &formatID("", 4, $commentid);
               my $prompt = "Click here for full information on comment $formattedid";
               $results .= &add_col() . "<center><a href=javascript:comments($docid,$commentid) title='$prompt'>$formattedid</a></center>";
               $results .= &writePrintCommentLink(document => $docid, comment => $commentid);
               $results .= &writeBin(binID => $bin, binName => $binName);
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }
      my ($returnString, $returnRows) = &searchResponses(type => "UNAPPROVED RESPONSE", paramString => "doresponses", statusWhere => " and r.status >= 2 and r.status <= 8", binsWhere => $whereClause);
      $results .= $returnString;
      $rows += $returnRows;
      ($returnString, $returnRows) = &searchResponses(type => "APPROVED RESPONSE", paramString => "doapprovedresponses", statusWhere => " and r.status = 9", binsWhere => $whereClause);
      $results .= $returnString;
      $rows += $returnRows;
      if (defined($crdcgi->param("doreviews"))) {
         my $type = "TECHNICAL REVIEW";
         print "<!--$type-->\n";
         my $sql = "select t.document, t.commentnum, t.version, b.id, b.name, t.text from $schema.technical_review t, $schema.bin b, $schema.comments c where c.bin = b.id and t.document = c.document and t.commentnum = c.commentnum $whereClause order by t.document, t.commentnum";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($docid, $commentid, $version, $bin, $binName, $text) = $csr->fetchrow_array) {
            if (defined($text) && &matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               my $formattedid = &formatID($CRDType, 6, $docid) . " / " . &formatID("", 4, $commentid);
               my $prompt = "Click here for full information on response version $version to comment $formattedid";
               $formattedid .= " / " . &formatID("v. ", 2, $version);
               $results .= &add_col() . "<center><a href=javascript:responses($docid,$commentid,$version) title='$prompt'>$formattedid</a></center>";
               $results .= &writePrintCommentLink(document => $docid, comment => $commentid, version => $version);
               $results .= &writeBin(binID => $bin, binName => $binName);
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }
      if (defined($crdcgi->param("docommentors"))) {
         my $type = "COMMENTOR";
         print "<!--$type-->\n";
         my $sql = "select id, firstname, lastname, middlename, title, suffix, address, city, state, country, email, organization, position from $schema.commentor order by id";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my @columns = $csr->fetchrow_array) {
            my $id = shift(@columns);
            my $name = (defined($columns[0])) ? $columns[0] . " " . $columns[1] : $columns[1];
            foreach my $text (@columns) {
            if (defined($text) && &matchFound(text => $text, searchString => $searchString)) {
                  $rows++;
                  $results .= &add_row();
                  my $prompt = "Click here for full information on commentor $name";
                  $results .= &add_col() . "<center><a href=javascript:commentors($id) title='$prompt'>$name</a></center>";
                  $results .= &writePrintCommentLink(document => 0);
                  $results .= &add_col() . "<center>N/A</center>";
                  $results .= &add_col() . "<center>$type</center>";
                  $text = &highlightResults(text => $text, searchString => $searchString);
                  $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
                  last;
               }
            }
         }
         $csr->finish;
      }
      if (defined($crdcgi->param("dosummarycomment"))) {
         my $type = "SUMMARY COMMENT";
         print "<!--$type-->\n";
         my $sql = "select sc.id, b.id, b.name, sc.commenttext from $schema.summary_comment sc, $schema.bin b where sc.bin = b.id $whereClause order by sc.id";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($summary, $bin, $binName, $text) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               my $formattedid = &formatID("SCR", 4, $summary);
               my $prompt = "Click here for full information on summary comment $formattedid";
               $results .= &add_col() . "<center><a href=javascript:displaySummaryComment($summary) title='$prompt'>$formattedid</a></center>";
               $results .= &writePrintCommentLink(document => 0);
               $results .= &writeBin(binID => $bin, binName => $binName);
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }
      if (defined($crdcgi->param("dosummaryresponse"))) {
         my $type = "SUMMARY RESPONSE";
         print "<!--$type-->\n";
         my $sql = "select sc.id, b.id, b.name, sc.responsetext from $schema.summary_comment sc, $schema.bin b where sc.bin = b.id $whereClause order by sc.id";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($summary, $bin, $binName, $text) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               my $formattedid = &formatID("SCR", 4, $summary);
               my $prompt = "Click here for full information on summary comment $formattedid";
               $results .= &add_col() . "<center><a href=javascript:displaySummaryComment($summary) title='$prompt'>$formattedid</a></center>";
               $results .= &writePrintCommentLink(document => 0);
               $results .= &writeBin(binID => $bin, binName => $binName);
               $results .= &add_col() . "<center>$type</center>";
               $text = &highlightResults(text => $text, searchString => $searchString);
               $results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
            }
         }
         $csr->finish;
      }
      if (defined($crdcgi->param("dosummaryremark"))) {
         my $type = "SUMMARY REMARK";
         print "<!--$type-->\n";
         my $sql = "select sc.id, b.id, b.name, sr.text from $schema.summary_remark sr, $schema.bin b, $schema.summary_comment sc where sc.bin = b.id and sr.summarycomment = sc.id $whereClause order by sc.id";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         while (my ($summary, $bin, $binName, $text) = $csr->fetchrow_array) {
            if (&matchFound(text => $text, searchString => $searchString)) {
               $rows++;
               $results .= &add_row();
               my $formattedid = &formatID("SCR", 4, $summary);
               my $prompt = "Click here for full information on summary comment $formattedid";
               $results .= &add_col() . "<center><a href=javascript:displaySummaryComment($summary) title='$prompt'>$formattedid</a></center>";
               $results .= &writePrintCommentLink(document => 0);
               $results .= &writeBin(binID => $bin, binName => $binName);
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
print "<input type=hidden name=binid value=0>\n";
print "</form>\n";
print &BuildPrintCommentResponse($username, $userid, $schema, $path);
print "<script language=javascript>\n<!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n" if ($errorstr);
print "</body>\n</html>\n";
db_disconnect($dbh);
exit();
