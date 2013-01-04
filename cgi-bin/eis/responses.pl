#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/crd/perl/RCS/responses.pl,v $
#
# $Revision: 1.10 $
#
# $Date: 2002/02/21 00:30:52 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: responses.pl,v $
# Revision 1.10  2002/02/21 00:30:52  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.9  2001/11/16 19:39:29  mccartym
# save entered response source as remark when user presses Save Response (as draft)
#
# Revision 1.8  2001/10/05 15:48:15  mccartym
# truncate long summary comment titles in rebin dropdown
#
# Revision 1.7  2001/08/17 23:40:44  mccartym
# add text box expanders
#
# Revision 1.6  2001/08/04 00:59:06  mccartym
# SCR #1 and #5
#
# Revision 1.5  2001/06/27 01:33:52  mccartym
# enable elimination of techedit step and
# parameterize review names
#
# Revision 1.4  2001/05/18 01:43:45  mccartym
# checkpoint
#
# Revision 1.3  1999/11/25 01:37:58  mccartym
# response development processing completed
#
# Revision 1.2  1999/08/26 21:01:54  mccartym
# checkpoint
#
# Revision 1.1  1999/08/02 03:00:09  mccartym
# Initial revision
#
#

use integer;
use strict;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DocumentSpecific qw(:Functions);
use DataObjects qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use Sections;
use DBI;
use DBD::Oracle qw(:ora_types);

$| = 1;
my $crdcgi = new CGI;
my $userid = $crdcgi->param("userid");
my $username = $crdcgi->param("username");
my $schema = $crdcgi->param("schema");
&checkLogin ($username, $userid, $schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $dbh;
my $command = $crdcgi->param("command");
my $documentid = $crdcgi->param("id") - 0;
my $commentid = $crdcgi->param("commentid") - 0;
my $version = $crdcgi->param("version") - 0;
my $process = $crdcgi->param("process");
my $bookmark = defined($crdcgi->param("bookmark")) ? $crdcgi->param("bookmark") : "";
my $summarycommentid = defined($crdcgi->param("summarycommentid")) ? $crdcgi->param("summarycommentid") - 0 : 0;
my $useFormValues = defined($crdcgi->param("useFormValues")) ? 1 : 0;
my $isProxy = ($crdcgi->param("proxy") == 1) ? 1 : 0;
my $proxy = ($isProxy) ? " - proxy" : "";
my $whichApprovedUpdateEntryType = defined($crdcgi->param("updateapprovedentrytype")) ? $crdcgi->param("updateapprovedentrytype") : "";

my %responseText = ();
my $output = '';
my $commentText = "";
my $instructionsColor = $CRDFontColor;
my $errorstr = "";
my $firstReviewName = &FirstReviewName();
my $secondReviewName = &SecondReviewName();
my $nextColor = 0;
my $responseSourceName = "ResponseSource";

my $relateDocument = "document = $documentid";
my $relateComment = $relateDocument . " and commentnum = $commentid";
my $relateResponseVersion = $relateComment . " and version = $version";

my $dateFormat = 'DD-MON-YY HH24:MI:SS';
my $focus = "";
my $enableAllFunction;
my $delimiter = "-";
my ($binFilter, $subbins);
my @binFilterList = ();

tie my %sections, "Tie::IxHash";
%sections = (
   'browse' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 1,
      'header' => 'Browse Response'
   },
   'information' => {
      'privilege' => [ 1 ],
      'enabled' => 1,
      'defaultOpen' => 1,
      'title' => 'General Information about this Comment / Response'
   },
   'remarks' => {
      'privilege' => [ 1 ],
      'enabled' => 1,
      'defaultOpen' => 0,
      'title' => 'Remarks'
   },
   'comment' => {
      'privilege' => [ 1 ],
      'enabled' => 1,
      'defaultOpen' => 0,
      'title' => 'Comment Text'
   },
   'instructions' => {
      'privilege' => [ 1 ],
      'enabled' => 1,
      'defaultOpen' => 0,
      'title' => 'Instructions'
   },
   'doereview' => {
      'privilege' => [ 7, 10 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 2,
      'header' => "$secondReviewName Review/Approval",
      'title' => "$secondReviewName Review: Accept or Reject Response",
      'instructions' => "<ol><li>Review the comment and subsequent responses.  Note that they are provided in ascending order with the most recent work towards the top of the screen.</li><li>If you wish to modify the response, enter your modified text in the space provided.  If the modifications are small, you may want to select the 'Copy Text' option and work with the most current response text in the modified response entry space.</li><li>Optionally, you may add remarks.  These remarks are not part of the response.  Remarks may address administrative issues, explanation of why a response is accepted or rejected, and other related concerns outside the scope of the response itself.</li><li>Click 'Save Response' to save but not submit your work.  Choose this option to continue working on the item at a later time.</li><li>Select the appropriate radio button and click the 'Submit' button to submit your approval decision (and modified response if applicable) into the database.</li></ol>"
   },
   'browsedoereview' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'title' => "$secondReviewName Review/Approval"
   },
   'nepareview' => {
      'privilege' => [ 6, 10 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 3,
      'header' => "$firstReviewName Review/Approval",
      'title' => "$firstReviewName Review: Accept or Reject Response",
      'instructions' => "<ol><li>Review the comment and subsequent responses.  Note that they are provided in ascending order with the most recent work towards the top of the screen.</li><li>If you wish to modify the response, enter your modified text in the space provided.  If the modifications are small, you may want to select the 'Copy Text' option and work with the most current response text in the modified response entry space.</li><li>Optionally, you may add remarks.  These remarks are not part of the response.  Remarks may address administrative issues, explanation of why a response is accepted or rejected, and other related concerns outside the scope of the response itself.</li><li>Click 'Save Response' to save but not submit your work.  Choose this option to continue working on the item at a later time.</li><li>Select the appropriate radio button and click the 'Submit' button to submit your approval decision (and modified response if applicable) into the database.</li></ol>"
   },
   'browsenepareview' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'title' => "$firstReviewName Review/Approval"
   },
   'accept' => {
      'privilege' => [ 8, 10 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 4,
      'header' => 'Bin Coordinator Accept Response',
      'title' => 'Bin Coordinator Review: Accept or Reject Response',
      'instructions' => "<ol><li>Review the comment and subsequent responses.  Note that they are provided in ascending order with the most recent work towards the top of the screen.</li><li>If you wish to modify the response, enter your modified text in the space provided.  If the modifications are small, you may want to select the 'Copy Text' option and work with the most current response text in the modified response entry space.</li><li>Optionally, you may add remarks.  These remarks are not part of the response.  Remarks may address administrative issues, explanation of why a response is accepted or rejected, and other related concerns outside the scope of the response itself.</li><li>Click 'Save Response' to save but not submit your work.  Choose this option to continue working on the item at a later time.</li><li>Select the appropriate radio button and click the 'Submit' button to submit your approval decision (and modified response if applicable) into the database.</li></ol>"
   },
   'browseaccept' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'title' => 'Bin Coordinator Acceptance'
   },
   'edit' => {
      'privilege' => [ 9, 10 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 5,
      'header' => 'Enter Technical Edits',
      'title' => 'Edit Response',
      'instructions' => "No instruction have been entered for this section."
   },
   'browseedit' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'title' => 'Technical Edited Response'
   },
   'modify' => {
      'privilege' => [ 4, 8, 10 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 6,
      'header' => 'Enter Modified Response',
      'title' => 'Enter Modified Response',
      'instructions' => "No instruction have been entered for this section."
   },
   'browsemodify' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'title' => 'Modified Response'
   },
   'review' => {
      'privilege' => [ 5, 8 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 7,
      'header' => 'Enter Technical Review',
      'title' => 'Enter Technical Review',
      'instructions' => "No instruction have been entered for this section."
   },
   'browsereview' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'title' => 'Technical Reviews'
   },
   'write' => {
      'privilege' => [ 4, 8, 10 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 8,
      'header' => 'Enter Response',
      'title' => 'Enter Response',
      'instructions' => "Press the 'Save Response' button whenever you want to save the response text you have entered so far.  Check the 'Done' checkbox before your final save.  This marks your response as completed in the database and initiates the next step of the response development process."
   },
   'browsewrite' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'title' => 'Original Response'
   },
   'assign' => {
      'privilege' => [ 8, 10 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 9,
      'header' => 'Bin Coordinator Assign Response',
      'title' => 'Update Comment/Response Information and Assign',
      'instructions' => "Press the 'Submit' button after making your selections. This updates the record and assigns response development to the selected response writer."
   },
   'proofread' => {
      'privilege' => [ 3 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 10,
      'header' => 'Proofread Response',
      'title' => 'Proofread Response',
      'instructions' => "Press the 'Response Text Verified' button below after making all required additions and corrections. This updates the record, marks it as having been verified for correctness, and releases it for technical review."
   },
   'enter' => {
      'privilege' => [ 3 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 11,
      'header' => 'Enter Response',
      'title' => 'Enter Response',
      'instructions' => "Press the 'Submit' button below after all data entry is complete. This will enter the response record into the database and add it to the list of records awaiting proofreading."
   }
);

my %responseTextColumns = (
   'write'      => 'originaltext',
   'modify'     => 'reviewedtext',
   'edit'       => 'techeditedtext',
   'accept'     => 'coordeditedtext',
   'nepareview' => 'nepaeditedtext',
   'doereview'  => 'doeeditedtext'
);

###################################################################################################################################
sub writeTextBox {                                                                                                                #
###################################################################################################################################
   my %args = (
      rows => 4,
      cols => 90,
      readOnly => 0,
      left => "",
      right => "",
      text => "",
      drawBoxIfTextNull => 1,
      align => "",
      @_,
   );

   my $out = "<tr><td $args{align}>";
   if (($args{text} ne "") || $args{drawBoxIfTextNull}) {
      my $readOnly = ($args{readOnly}) ? "readonly" : "";
      my $expand = "<a href=\"javascript:expandTextBox(document.$form.$args{name},document.$args{name}_button,'force',5);\">\n";
      $expand .= "<img name=$args{name}_button border=0 src=$CRDImagePath/expand_button.gif></a>\n";
      $out .= "<table border=0 cellpadding=0 cellspacing=0><tr>";
      $out .= "<td align=left valign=bottom><b>$args{left}</b></td><td align=right valign=bottom>$args{right}" . &nbspaces(3) . " $expand</td></tr>\n";
      $out .= "<tr><td colspan=2><textarea name=$args{name} rows=$args{rows} cols=$args{cols} wrap=physical $readOnly ";
      $out .= "onKeyPress=\"expandTextBox(this,document.$args{name}_button,'dynamic');\">$args{text}</textarea></tr></table>\n";
   } else {
      $out .= "<table cellpadding=0 cellspacing=0 border=0 width=100%><tr><td>$args{left}</td><td align=right>$args{right}</td></tr></table>";
   }
   $out .= "</td></tr>";
   return ($out);
}

###################################################################################################################################
sub writeGeneralInfoTable {                                                                                                       #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   my $relateDocument = "document = $args{document}";
   my $relateComment = $relateDocument . " and commentnum = $args{comment}";
   my $relateResponseVersion = $relateComment . " and version = $args{version}";
   my $formattedDocumentID = &formatID($CRDType, 6, $args{document});
   my $formattedCommentID = &formatID("", 4, $args{comment});
   my $formattedID = "$formattedDocumentID / $formattedCommentID";
   my %changeImpactValues = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'document_change_impact')};
   my %affiliationValues = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'commentor_affiliation')};
   my %nameStatusValues = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'commentor_name_status')};
   my %statusValues = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'response_status')};
   my ($hascommitments, $changeImpact, $changeControlNumber) = $args{dbh}->selectrow_array ("select hascommitments, changeimpact, changecontrolnum from $args{schema}.comments where $relateComment");
   $hascommitments = ($hascommitments eq 'T') ? 'Yes' : 'No';
   my $otherText = "";
   my ($maxVersion) = $args{dbh}->selectrow_array("select max(version) from $args{schema}.response_version where $relateComment");
   if ($maxVersion > 1) {
      $otherText .= &nbspaces(4) . "<font size=2><i>(Browse other versions of the response:</i></font>";
      for (my $otherVersion = 1; $otherVersion <= $maxVersion; $otherVersion++) {
         if ($otherVersion != $args{version}) {
            $otherText .= &nbspaces(2) . "<a href=javascript:display_response($args{document},$args{comment},$otherVersion)>" . &formatID("", 2, $otherVersion) . "</a>";
         }
      }
      $otherText .= "<font size=2><i>)</i></font>";
   }
   my ($status, $dateUpdated) = $args{dbh}->selectrow_array ("select status, to_char(dateupdated, '$dateFormat') from $args{schema}.response_version where $relateResponseVersion");
   my $binid = &getBinID(document => $args{document}, comment => $args{comment});
   my $binname = &getBinName(document => $args{document}, comment => $args{comment});
   $out .= "<tr bgcolor=" . &nextColor() . "><td width=310><b>Comment Document:</b></td><td><b><a href=javascript:display_document($args{document}) title='Click here to browse detailed information on comment document $formattedDocumentID'>$formattedDocumentID</a></b>";
   $out .= &nbspaces(4) . "<font size=2><i><b>(You can also <a href=javascript:display_image($args{document},$args{comment}) title='Click here to view the image of comment document $formattedDocumentID'>view the document image</a>.)</b></i></font></td></tr>\n";
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Comment Number:</b></td><td><b><a href=javascript:display_comments($args{document},$args{comment}) title='Click here to browse detailed information on comment $formattedID'>$formattedCommentID</a>";
   $out .= &nbspaces(4) . "<font size=2><i><b>(You can also " . &writePrintCommentLink(document => $args{document}, comment => $args{comment}, useIcon => 0, addTableColumn => 0) . "</a>.)</b></i></font></td></tr>\n";
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Commentor:</b></td><td><b>" . &writeCommentorLink(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}) . "</b></td></tr>\n";
   my ($commentor) = $args{dbh}->selectrow_array ("select nvl(commentor,0) from $args{schema}.document where id = $args{document}");
   if ($commentor) {
      my ($affiliation, $organization) = $args{dbh}->selectrow_array ("select affiliation, nvl(organization, 'None Entered') from $args{schema}.commentor where id = $commentor");
      $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Commentor Affiliation:</b></td><td><b>$affiliationValues{$affiliation}</b></td></tr>\n";
      $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Commentor Organization:</b></td><td><b>$organization</b></td></tr>\n";
   }
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Response Version:</b></td><td><b>" . &formatID("", 2, $args{version}) . "$otherText</b></td></tr>\n";
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Response Status:</b></td><td><b>";
   $out .= "Comment is" . &nbspaces(1) if (($status == 14) || ($status == 15));
   $out .= "$statusValues{$status}</b>";
   if ($status == 14) {
      my $dupsimstatus = $args{dbh}->selectrow_array ("select dupsimstatus from $args{schema}.comments where $relateComment");
      if ($dupsimstatus != 1) {
         my ($dupdocument, $dupcomment) = $args{dbh}->selectrow_array ("select nvl(dupsimdocumentid,0), nvl(dupsimcommentid,0) from $args{schema}.comments where $relateComment");
         if ($dupdocument && $dupcomment) {
            my ($dupversion) = $args{dbh}->selectrow_array ("select max(version) from $args{schema}.response_version where document = $dupdocument and commentnum = $dupcomment");
            $out .= &nbspaces(1) . "<b>of" . &nbspaces(2) ."<a href=javascript:display_response($dupdocument,$dupcomment,$dupversion)>" . &formatID("$CRDType", 6, $dupdocument) . " / " . &formatID("", 4, $dupcomment) . "</a>";
         }
      }
   } elsif ($status == 15) {
      my $summary = $args{dbh}->selectrow_array ("select nvl(summary,0) from $args{schema}.comments where $relateComment");
      $out .= &nbspaces(1) . "<b>by" . &nbspaces(2) ."<a href=javascript:display_summary_comment($summary)>" . &formatID("SCR", 4, $summary) . "</a>"  if ($summary);
   }
   $out .= "</td></tr>\n";
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Response Updated:</b></td><td><b>$dateUpdated</b></td></tr>";
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Bin:</b></td><td><b><a href=javascript:display_bin($binid)>" . $binname . "</a></b></td></tr>\n";
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Document Change Impact / Control Number:</b></td><td><b>$changeImpactValues{$changeImpact}";
   $out .= &nbspaces(2) . "-" . &nbspaces(2) . "$changeControlNumber" if ($changeControlNumber);
   $out .= "</b></td></tr>\n";
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Potential DOE Commitment:</b></td><td><b>$hascommitments</b></td></tr>\n";
   return ($out);
}

###################################################################################################################################
sub writeCommentAndResponseText {                                                                                                 #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   my ($version) = $dbh->selectrow_array("select max(version) from $schema.response_version where $relateComment");
   my $sql = "select c.text, r.lastsubmittedtext from $args{schema}.comments c, $args{schema}.response_version r ";
   $sql .= "where c.document = r.document and c.commentnum = r.commentnum and c.document = $args{document} and c.commentnum = $args{comment} and r.version = $version";
   my ($commentText, $responseText) = $args{dbh}->selectrow_array ($sql);
   my $left = "<b>Comment Text:</b>";
   $out .= &writeTextBox(name => 'commentText', text => $commentText, left => $left, readOnly => 'true');
   $out .= "<tr><td height=5></td></tr>";
   $left = "<b>Response Text:</b>";
   $out .= &writeTextBox(name => 'responseText', text => $responseText, left => $left, readOnly => 'true');
   return ($out);
}

###################################################################################################################################
sub nextColor {                                                                                                                   #
###################################################################################################################################
   my %args = (
      @_,
   );
   $nextColor++;
   return ($nextColor % 2) ? "#f0f0f0" : "#ffffff";
}

###################################################################################################################################
sub concurrenceEntry {                                                                                                            #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   my $remarks = ($useFormValues) ? $crdcgi->param("remarks") : "";
   my $concurType = $crdcgi->param("concurtype");
   my %concurTypes = %{&getLookupValues(dbh => $dbh, schema => $schema, table => 'concurrence_type')};
   my $formattedID = &formatID($CRDType, 6, $documentid) . " / " . &formatID("", 4, $commentid);
   my ($version) = $dbh->selectrow_array ("select max(version) from $schema.response_version where $relateComment");
   $out .= "<tr><td align=center><table width=750 border=0>\n";
   $out .= "<tr><td align=center><table width=600 border=0>\n";
   $out .= "<tr><td valign=top height=30><b>Enter $concurTypes{$concurType} concurrence for $formattedID (see information below):\n";
   $out .= &nbspaces(2);
   $out .= "<input type=radio checked name=concurs value=1> Positive\n";
   $out .= "<input type=radio name=concurs value=0> Negative\n";
   $out .= "</td></tr>";
   my $label = "<b>Enter Remark:" . &nbspaces(3) . "<font size=-1 color=$instructionsColor><i>(Required with negative concurrence)</i></font></b>";
   $out .= &writeTextBox(name => "remarks", left => $label, text => $remarks);
   $out .= "</table></td></tr>\n";
   my $submit = &writeControl(label => "Submit", callback => "enterConcur($documentid,$commentid,$concurType)", useLinks => 0);
   $out .= "<tr><td align=center height=40>$submit</td></tr>\n";
   $out .= "<tr><td height=30><hr width=90%</td></tr>\n";
   $out .= "<tr><td><table width=750 border=0>\n";
   $out .= &writeGeneralInfoTable(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, version => $version);
   $out .= "</table></td></tr>\n";
   $out .= "<tr><td height=5></td></tr>";
   $out .= &writeCommentAndResponseText(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid);
   $out .= "<tr><td height=15></td></tr>";
   $out .= "<tr><td><table cellpadding=0 cellspacing=0>\n";
   $out .= &doRemarks(schema => $schema, dbh => $dbh, remark_type => 'comment', document => $documentid, comment => $commentid, show_text_box => 0, useForm => $useFormValues);
   $out .= "</table></td></tr>\n";
   return ($out);
}

###################################################################################################################################
sub addRemark {                                                                                                                   #
###################################################################################################################################
   my %args = (
      user => $userid,
      date => "SYSDATE",
      @_,
   );
   my $sql = "insert into $schema.comments_remark (document, commentnum, remarker, dateentered, text) values ($args{document}, $args{comment}, $args{user}, $args{date}, :text)";
   my $csr = $dbh->prepare($sql);
   $csr->bind_param(":text", $args{text}, {ora_type => ORA_CLOB, ora_field => 'text'});
   $csr->execute;
}

###################################################################################################################################
sub changeResponseWriter {                                                                                                        #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $formattedID = &formatID($CRDType, 6, $documentid) . " / " . &formatID("", 4, $commentid);
   my $out = "";
   $out .= "<tr><td height=15> </td></tr></table><center>\n";
   $out .= "<b>$formattedID<br><br></b>\n";
   my $binid = &getBinID(document => $documentid, comment => $commentid);
   my $relateComment = "document = $documentid and commentnum = $commentid";
   my ($version) = $dbh->selectrow_array ("select max(version) from $schema.response_version where $relateComment");
   tie my %writers, "Tie::IxHash";
   %writers = %{&getBinWritersAndReviewers(dbh => $dbh, schema => $schema, bin => $binid)};
   $out .= &writeResponseWriter(writers => \%writers, dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, version => $version, useForm => 0);
   $out .= &nbspaces(3) . "<input type=button name=updateresponsewritergo value='Go' onClick=javascript:update_response_writer($documentid,$commentid)></b></font></td></tr>\n";
   $out .= "<table><tr><td></td></tr>\n";
   return ($out);
}

###################################################################################################################################
sub updateApprovedResponse {  # added 1/7/01 - cut 'n paste from other response code                                              #
###################################################################################################################################
   my %args = (
      @_,
   );
   eval {
      $output .= "<tr><td align=center><table width=750 border=0>\n";
      my $documentid = $args{document};
      my $commentid = $args{comment};
      my $relateComment = "document = $documentid and commentnum = $commentid";
      my ($version) = $dbh->selectrow_array ("select max(version) from $schema.response_version where $relateComment");
      my $relateResponseVersion = "$relateComment and version = $version";
      my $formattedID = &formatID($CRDType, 6, $documentid) . " / " . &formatID("", 4, $commentid);
      $output .= &writeGeneralInfoTable(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, version => $version);
      $output .= "</table><table width=750 cellpadding=5 cellspacing=5 border=0>\n";
      my $commentText = &getText(useForm => 0, query => "select text from $schema.comments where $relateComment");
      $output .= &writeTextBox(name => "commentText", text => $commentText, left => '<b>Comment Text:</b>', readOnly => 'true');
      my $responseText = &getText(useForm => 0, query => "select lastsubmittedtext from $schema.response_version where $relateResponseVersion");
      $output .= &writeTextBox(name => "approvedResponse", text => $responseText, left => '<b>Edit Approved Response:</b>');
      my $leftText = "<b>Enter Remark:" . &nbspaces(3) . "<font size=-1><i>(optional)</i></font></b>";
      $output .= &writeTextBox(name => "remark", text => "", left => $leftText);
      $output .= &doRemarks(schema => $schema, dbh => $dbh, remark_type => 'comment', document => $documentid, comment => $commentid, show_text_box => 0, useForm => $useFormValues);
      $output .= "<tr><td align=center>" . &writeControl(label => 'Submit', callback => "process_update_approved_response($documentid,$commentid,$version)", useLinks => 0) . "</td></tr>";
   };
   &processError(activity => "display entry of approved response") if ($@);
   $output .= "</table></td></tr>\n";
}

###################################################################################################################################
sub applyBinFilter {                                                                                                              #
###################################################################################################################################
   $" = ',';
   my $output = ($binFilter > 0) ? " and c.bin in (@binFilterList) " : "";
   $" = ' ';
   return ($output);
}

###################################################################################################################################
sub setupBinFilterList {                                                                                                          #
###################################################################################################################################
   if ($binFilter > 0) {
      if ($subbins eq 'F') {
         push(@binFilterList, $binFilter);
      } else {
         my $csr = $dbh->prepare("select id from $schema.bin connect by prior id = parent start with id = $binFilter order by id");
         $csr->execute;
         while (my ($bin) = $csr->fetchrow_array) {
            push(@binFilterList, $bin);
         }
         $csr->finish;
      }
   }
}

###################################################################################################################################
sub filterBinNumber {                                                                                                             #
###################################################################################################################################
   my $section = $_[0];
   my $binNumber = "";
   if (($section eq 'coordinator') || ($section eq 'write_response') || ($section eq 'tech_review') ||
       ($section eq 'tech_edit')   || ($section eq 'nepa_approval')  || ($section eq 'doe_approval')) {
      my ($count) = $dbh->selectrow_array ("select count(*) from $schema.user_preferences where userid = $userid and binfilter is not null");
      if (!$count) {
         $binNumber = "<font size=-1 color=#ff0000>" . &nbspaces(3) . "(All bins)" . "</font>";
      } else {
         my ($filterBin, $filterSubbins) = $dbh->selectrow_array ("select binfilter, binfiltersubbins from $schema.user_preferences where userid = $userid");
         my $filterBinName = $dbh->selectrow_array ("select name from $schema.bin where id = $filterBin");
         $filterBinName =~ m/([0-9].*?)[ ]/;
         $binNumber = "<font size=-1 color=#ff0000>";
         $binNumber .= &nbspaces(3) . "(Bin $1";
         $binNumber .= " & subbins" if ($filterSubbins eq 'T');
         $binNumber .= ")</font>";
      }
   }
   return ($binNumber);
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
sub displayApprovedResponseEnterID {                                                                                              #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   $out .= "<tr><td height=15> </td></tr>\n";
   $out .= "<tr><td align=center><font face=arial><b>$CRDType<input type=text size=6 maxlength=6 name=updateresponsecdid> / <input type=text size=4 maxlength=4 name=updateresponsecid>";
   $out .= &nbspaces(3) . "<input type=button name=responsego value='Update' onClick=javascript:update_approved_response_entered_ID()></b></font></td></tr>\n";
   return ($out);
}

###################################################################################################################################
sub doWorkflowStepEnterID {                                                                                                       #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   $out .= "<tr><td height=15> </td></tr>\n";
   $out .= "<tr><td align=center><font face=arial><b>$CRDType<input type=text size=6 maxlength=6 name=workflowstepresponsecdid> / <input type=text size=4 maxlength=4 name=workflowstepresponsecid>";
   $out .= &nbspaces(3) . "<input type=button name=responsego value='Go' onClick=javascript:do_workflow_step_entered_ID()></b></font></td></tr>\n";
   return ($out);
}

###################################################################################################################################
sub updateResponseWriterEnterID {                                                                                                 #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   $out .= "<tr><td height=15> </td></tr>\n";
   $out .= "<tr><td align=center><font face=arial><b>$CRDType<input type=text size=6 maxlength=6 name=updateresponsewritercdid> / <input type=text size=4 maxlength=4 name=updateresponsewritercid>";
   $out .= &nbspaces(3) . "<input type=button name=responsego value='Go' onClick=javascript:update_response_writer_entered_ID()></b></font></td></tr>\n";
   return ($out);
}

###################################################################################################################################
sub displayApprovedResponseTable {                                                                                                #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   my ($hasPreferences) = $dbh->selectrow_array ("select count(*) from $schema.user_preferences where userid = $userid");
   ($binFilter, $subbins) = (!$hasPreferences) ? (0, 'F') : $dbh->selectrow_array ("select nvl(binfilter,0), binfiltersubbins from $schema.user_preferences where userid = $userid");
   &setupBinFilterList();
   tie my %binlookup, "Tie::IxHash";
   %binlookup = ('0' => "All Bins", &get_lookup_values($dbh, $schema, 'bin', 'id', 'name', "1=1 order by name"));
   my $submit = &writeControl(label => 'Go', callback => "saveFilter('$command')", useLinks => 0);
   $out .= "<tr><td align=center><b>Show Responses From:</b>" . &nbspaces(2) . &build_drop_box('filterBin', \%binlookup, $binFilter) . $submit . "</td></tr>";
   my $checked = ($subbins eq 'T') ? "checked" : "";
   $out .= "<tr><td align=center><input type=checkbox name=subbins value=subbins $checked><b>Include All Subbins</b></td></tr>\n";
   $out .= "<tr><td height=25> </td></tr>\n";
   my $sql = "select r.document, r.commentnum, r.lastsubmittedtext, c.bin, b.name from $schema.comments c, $schema.response_version r, $schema.bin b ";
   $sql .= "where c.document = r.document and c.commentnum = r.commentnum and c.dupsimstatus = 1 and c.summary is null and r.status = 9 and c.bin = b.id  " . &applyBinFilter();
   $sql .= "order by r.document, r.commentnum";
   my $csr = $dbh->prepare($sql);
   $csr->execute;
   my $tableHeader = "Approved Responses (xxx)";
   $out .= "<tr><td>";
   $out .= &start_table(5, 'center', 60, 120, 20, 50, 500);
   my $promptText = "Click 'Update' to change the text of one of the approved responses";
   $out .= &title_row("#a0e0c0", "#000099", "<font size=3>$tableHeader</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>$promptText</font></i>)");
   $out .= &add_header_row();
   $out .= &add_col() . "<center>Update<center>";
   $out .= &add_col() . "<center>Doc ID /<br>Comment ID<center>";
   $out .= &writePrintCommentLink(writeHeader => 1);
   $out .= &writeBin(writeHeader => 1);
   $out .= &add_col() . "<center>Response<br>Text</center>";
   my $numComments = 0;
   while (my ($docid, $commentid, $response, $bin, $binname) = $csr->fetchrow_array) {
      $numComments++;
      my $name = "comment$numComments";
      $out .= &add_row();
      $out .= &add_col();
      my $formattedID = &formatID($CRDType, 6, $docid) . " / " . &formatID("", 4, $commentid);
      my $prompt = "click here to update $formattedID";
      my $update = &writeControl(label => 'Update', callback => "update_approved_response($docid,$commentid)", prompt => $prompt, useLinks => 1);
      $out .= "<center>$update</center>";
      $out .= &writeBrowseCommentLink(document => $docid, comment => $commentid);
      $out .= &writePrintCommentLink(document => $docid, comment => $commentid);
      $out .= &writeBin(binID => $bin, binName => $binname);
      $out .= &add_col() . &getDisplayString($response, 75);
   }
   $csr->finish;
   $out .= &end_table();
   $out =~ s/xxx/$numComments/;
   $out .= "</td></tr>";
   $out .= "<input type=hidden name=numComments value=$numComments>\n";
   return ($out);
}

###################################################################################################################################
sub displayUpdateStatusTable {                                                                                                    #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   $out .= "<tr><td height=15> </td></tr>\n";
   my ($hasPreferences) = $dbh->selectrow_array ("select count(*) from $schema.user_preferences where userid = $userid");
   ($binFilter, $subbins) = (!$hasPreferences) ? (0, 'F') : $dbh->selectrow_array ("select nvl(binfilter,0), binfiltersubbins from $schema.user_preferences where userid = $userid");
   &setupBinFilterList();
   tie my %binlookup, "Tie::IxHash";
   %binlookup = ('0' => "All Bins", &get_lookup_values($dbh, $schema, 'bin', 'id', 'name', "1=1 order by name"));
   my $submit = &writeControl(label => 'Go', callback => "saveFilter('$command')", useLinks => 0);
   $out .= "<tr><td align=center><b>Show Responses From:</b>" . &nbspaces(2) . &build_drop_box('filterBin', \%binlookup, $binFilter) . $submit . "</td></tr>";
   my $checked = ($subbins eq 'T') ? "checked" : "";
   $out .= "<tr><td align=center><input type=checkbox name=subbins value=subbins $checked><b>Include All Subbins</b></td></tr>\n";
   $out .= "<tr><td height=25> </td></tr>\n";
   my $sql = "select c.document, c.commentnum, c.text, r.lastsubmittedtext, c.bin, b.name from $schema.comments c, $schema.response_version r, $schema.bin b ";
   $sql .= "where c.document = r.document and c.commentnum = r.commentnum and c.dupsimstatus = 1 and c.summary is null and r.status = 9 and c.bin = b.id  " . &applyBinFilter();
   $sql .= "order by c.document, c.commentnum";
   my $csr = $dbh->prepare($sql);
   $csr->execute;
   my $tableHeader = "Approved Responses (xxx)";
   $out .= "<tr><td>";
   $out .= &start_table(6, 'center', 95, 75, 20, 50, 255, 255);
   my $promptText;
   $promptText = "Click checkboxes for return to $firstReviewName Review/Approval status - press 'Submit' when done";
   $out .= &title_row("#a0e0c0", "#000099", "<font size=3>$tableHeader</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>$promptText</font></i>)");
   $out .= &add_header_row();
   $out .= &add_col() . "<center>Return to $firstReviewName<br>Review/Approval<center>";
   $out .= &add_col() . "<center>Doc ID /<br>Comment ID<center>";
   $out .= &writePrintCommentLink(writeHeader => 1);
   $out .= &writeBin(writeHeader => 1);
   $out .= &add_col() . "<center>Comment<br>Text</center>";
   $out .= &add_col() . "<center>Response<br>Text</center>";
   my $numComments = 0;
   while (my ($docid, $commentid, $comment, $response, $bin, $binname) = $csr->fetchrow_array) {
      $numComments++;
      my $name = "comment$numComments";
      $out .= &add_row();
      $out .= &add_col();
      $out .= "<center><input type=checkbox name=$name value='$docid$delimiter$commentid'></center>";
      $out .= &writeBrowseCommentLink(document => $docid, comment => $commentid);
      $out .= &writePrintCommentLink(document => $docid, comment => $commentid);
      $out .= &writeBin(binID => $bin, binName => $binname);
      $out .= &add_col() . &getDisplayString($comment, 110);
      $out .= &add_col() . &getDisplayString($response, 110);
   }
   $csr->finish;
   $out .= &end_table();
   $out =~ s/xxx/$numComments/;
   $out .= "</td></tr>";
   $out .= "<input type=hidden name=numComments value=$numComments>\n";
   $submit = &writeControl(label => 'Submit', callback => "update_response_status()", useLinks => 0);
   $out .= "<tr><td align=center height=40>$submit</td></tr>\n";
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
sub writeBrowseCommentLink {                                                                                                      #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Doc ID /<br>Comment ID",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $formattedID = &formatID($CRDType, 6, $args{document}) . " / " . &formatID("", 4, $args{comment});
      my $prompt = "Click here to browse comment information for $formattedID";
      $out .= "<center><a href=javascript:display_comments($args{document},$args{comment}) title='$prompt'>$formattedID</a></center>";
   }
   return ($out);
}

###################################################################################################################################
sub writeCommentorLink {                                                                                                          #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out;
   my %commentorNameStatus = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'commentor_name_status')};
   my ($nameStatus, $commentor) = $args{dbh}->selectrow_array ("select namestatus, commentor from $schema.document where id = $args{document}");
   if ($nameStatus != 1) {
      $out = $commentorNameStatus{$nameStatus};
   } else {
      my $prompt = "Click here to browse detailed information about the commentor";
      my ($title, $firstName, $middleName, $lastName, $suffix) = $args{dbh}->selectrow_array ("select nvl(title,' '), nvl(firstname,' '), nvl(middlename,' '), nvl(lastname,' '), nvl(suffix,' ') from $schema.commentor where id = $commentor");
      $out = "<a href=javascript:display_commentor($commentor) title='$prompt'>$title $firstName $middleName $lastName $suffix</a>";
   }
   return ($out);
}

###################################################################################################################################
sub writeDuplicateCommentInput {                                                                                                  #
###################################################################################################################################
   my %args = (
      duplicateDocumentName => 'dupDocument',
      duplicateCommentName => 'dupComment',
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      label => 'Original Comment is',
      @_,
   );
   my ($dupDocumentValue, $dupCommentValue) = ("", "");
   if ($args{useForm}) {
      $dupDocumentValue = $crdcgi->param($args{duplicateDocumentName});
      $dupCommentValue = $crdcgi->param($args{duplicateCommentName});
   } else {
      my ($dupSimStatus, $dupDocument, $dupComment) = $dbh->selectrow_array ("select dupsimstatus, dupsimdocumentid, dupsimcommentid from $schema.response_version where $relateResponseVersion");
      ($dupDocumentValue, $dupCommentValue) = ($dupDocument, $dupComment) if ($dupSimStatus != 1);
   }
   my $output = "<td><b>$args{label}:" . &nbspaces(2) . "$CRDType<input type=text size=6 maxlength=6 name=$args{duplicateDocumentName} value=$dupDocumentValue>";
   $output .= &nbspaces(2) . 'Comment' . &nbspaces(2) . "<input type=text size=4 maxlength=4 name=$args{duplicateCommentName} value=$dupCommentValue></td>\n";
   $output .= "<script language=javascript><!--\n";
   $output .= "function validateNumber(value, min, max, str) {\n";
   $output .= "   var msg = \"\";\n";
   $output .= "   if (isNaN(value - 0) || (value <= min) || (value > max)) {\n";
   $output .= "      msg = 'Invalid ' + str + '\\n';\n";
   $output .= "   }\n";
   $output .= "   return(msg);\n";
   $output .= "}\n";
   $output .= "function validateDuplicateDocumentID() {\n";
   $output .= "   return (validateNumber($form.$args{duplicateDocumentName}.value, 0, 999999, 'Duplicate Comment Document ID'));\n";
   $output .= "}\n";
   $output .= "function validateDuplicateCommentID() {\n";
   $output .= "   return (validateNumber($form.$args{duplicateCommentName}.value, 0, 9999, 'Duplicate Comment ID'));\n";
   $output .= "}\n";
   $output .= "function validateDuplicateInput() {\n";
   $output .= "   return (validateDuplicateDocumentID() + validateDuplicateCommentID());\n";
   $output .= "}\n";
   $output .= "function setDuplicateDisabled(value) {\n";
   $output .= "   $form.$args{duplicateDocumentName}.disabled = value;\n";
   $output .= "   $form.$args{duplicateCommentName}.disabled = value;\n";
   $output .= "}\n";
   $output .= "//-->\n";
   $output .= "</script>\n";
   return ($output);
}

###################################################################################################################################
sub selectSummaryCommentTitles {                                                                                                  #
###################################################################################################################################
   my %args = (
      table => 'summary_comments',
      @_,
   );
   tie my %titles, "Tie::IxHash";
   my $csr = $args{dbh}->prepare("select id, title from $args{schema}.$args{table} where bin = $args{bin} order by id");
   $csr->execute;
   while (my ($id, $title) = $csr->fetchrow_array) {
      $titles{$id} = $title;
   }
   $csr->finish;
   return (\%titles);
}

###################################################################################################################################
sub writeSummaryCommentTitles {                                                                                                   #
###################################################################################################################################
   my %args = (
      name => 'summaryComment',
      selected => 0,
      label => 'Use Summary Comment',
      table => 'summary_comment',
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      @_,
   );
   tie my %titles, "Tie::IxHash";
   my $titlesref = &selectSummaryCommentTitles(dbh => $args{dbh}, schema => $args{schema}, table => $args{table}, bin => $args{bin});
   %titles = %$titlesref;
   my $output = "<td><b>$args{label}:</b>" . &nbspaces(2) . "<select name=$args{name} size=1>";
   my $current = ($args{useForm} && defined($args{name})) ? $crdcgi->param($args{name}) : $args{selected};
   my $count = 0;
   foreach my $id (keys (%titles)) {
      $count++;
      my $selected = ($current == $id) ? 'selected' : '';
      my $scrTitle = &getDisplayString($titles{$id}, 75);
      $output .= "<option value='$id' $selected>$scrTitle";
   }
   $output .= "</select></td>\n";
   $output = "<td><b>Bin" . &nbspaces(2) . "<a href=javascript:display_bin($args{bin})>" . &getDisplayString(&binIDtoName($args{bin}), 50) . "</a>" . &nbspaces(2) . "contains no summary comments</b></td>" if ($count == 0);
   return ($count, $output);
}

###################################################################################################################################
sub writeSummaryCommentInput {                                                                                                    #
###################################################################################################################################
   my %args = (
      summaryCommentName => 'summaryComment',
      summaryCommentButtonName => 'summaryCommentButton',
      selectedSummaryComment => 0,
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      label => 'Use Summary Comment',
      documentID => $documentid,
      commentID => $commentid,
      responseVersion => $version,
      command => $command,
      @_,
   );
   my $binid = &getBinID(document => $documentid, comment => $commentid);
   my $selectedSummaryComment = ($summarycommentid) ? $summarycommentid : $args{selectedSummaryComment};
   my ($numSummaryComments, $text) = &writeSummaryCommentTitles(name => $args{summaryCommentName}, label => $args{label}, bin => $binid, dbh => $dbh, schema => $schema, selected => $selectedSummaryComment);
   my $output .= "<tr>$text</tr><tr><td>";
   $output .= &writeControl(label => 'Create', useLinks => 0, name => $args{summaryCommentButtonName}, callback => "summary_comment('create',$binid,$args{documentID},$args{commentID},$args{responseVersion},'$args{command}')");
   $output .= "<b> a new Summary Comment based on this comment</b></td></tr>\n";
   $output .= "<script language=javascript><!--\n";
   $output .= "function validateSummarizeInput() {\n";
   $output .= "   var msg = \"\";\n";
   $output .= "   msg = \"No summary comment is selected.\";\n" if ($numSummaryComments == 0);
   $output .= "   return (msg);\n";
   $output .= "}\n";
   $output .= "function setSummarizeDisabled(value) {\n";
   $output .= "   $form.$args{summaryCommentName}.disabled = value;\n" if ($numSummaryComments > 0);
   $output .= "   $form.$args{summaryCommentButtonName}.disabled = value;\n";
   $output .= "}\n";
   $output .= "//-->\n";
   $output .= "</script>\n";
   return ($output);
}

###################################################################################################################################
sub getBinWritersAndReviewers {                                                                                                   #
###################################################################################################################################
   my %args = (
      @_,
   );
   tie my %writers, "Tie::IxHash";
   my ($id, $fname, $lname) = $args{dbh}->selectrow_array ("select u.id, u.firstname, u.lastname from $args{schema}.users u, $args{schema}.bin b where b.id = $args{bin} and b.coordinator = u.id");
   $writers{$id} = "$fname $lname";
   my $csr = $args{dbh}->prepare("select u.id, u.firstname, u.lastname from $args{schema}.users u, $args{schema}.default_tech_reviewer d where d.bin = $args{bin} and u.id = d.reviewer order by u.lastname, u.firstname");
   $csr->execute;
   while (($id, $fname, $lname) = $csr->fetchrow_array) {
      $writers{$id} = "$fname $lname";
   }
   $csr->finish;
   return (\%writers);
}

###################################################################################################################################
sub getLookupValues {
###################################################################################################################################
   my %args = (
      @_,
   );
   my %lookupHash = ();
   my $lookup = $args{dbh}->prepare("select id, name from $args{schema}.$args{table}");
   $lookup->execute;
   while (my @values = $lookup->fetchrow_array) {
      $lookupHash{$values[0]} = $values[1];
   }
   $lookup->finish;
   return (\%lookupHash);
}

###################################################################################################################################
sub getCoordinator {                                                                                                              #
###################################################################################################################################
   my @row = $dbh->selectrow_array("select b.coordinator from $schema.comments c, $schema.bin b, $schema.response_version r where c.document = $documentid and c.commentnum = $commentid and c.document = r.document and c.commentnum = r.commentnum and r.version = $version and c.bin = b.id");
   return ($row[0]);
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
sub getText {                                                                                                                     #
###################################################################################################################################
   my %args = (
      name => 'text',
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      @_,
   );
   my $text = "";
   if ($args{useForm}) {
      $text = $crdcgi->param($args{name});
      $text =~ s/%27/'/g;
   }
   elsif ($args{query} ne "") {
      ($text) = $dbh->selectrow_array($args{query});
      $text = "" if (!defined($text));
   }
   return ($text);
}

###################################################################################################################################
sub writeControl {                                                                                                                #
###################################################################################################################################
   my %args = (
      name => 'button',
      useLinks => 1,
      prompt => "",
      @_,
   );
   return ($args{useLinks}) ? "<b><a href=\"javascript:$args{callback}\" title='$args{prompt}'>$args{label}</a></b>" : "<input type=button name=$args{name} value='$args{label}' onClick=javascript:$args{callback}>";
}

###################################################################################################################################
sub writeRadioBox {                                                                                                               #
###################################################################################################################################
   my %args = (
      name => 'radioBox',
      height => 30,
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      @_,
   );
   tie my %buttons, "Tie::IxHash";
   %buttons = %{$args{buttons}};
   my $default = ($args{useForm} && defined($crdcgi->param($args{name}))) ? $crdcgi->param($args{name}) : $args{default};
   my $onClick = (exists($args{onClick})) ? "onClick=$args{onClick}" : "";
   my $output = "";
   while (my ($button, $values) = each %buttons) {
      my $checked = ($button eq $default) ? 'checked' : '';
      $output .= "<tr><td height=$args{height} valign=bottom><input type=radio name=$args{name} value=$button $onClick $checked>" . &nbspaces(2) . "<b>$$values{label}</b></td></tr>\n";
      if (defined($$values{content})) {
         $output .= "<tr><td align=right><table width=96% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellpadding=8 cellspacing=0>$$values{content}</table></td></tr>\n";
      }
   }
   return ($output);
}

###################################################################################################################################
sub writeResponseRadioBox {                                                                                                       #
###################################################################################################################################
   my %args = (
      name => 'radioBox',
      height => 30,
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      @_,
   );
   $enableAllFunction = "setEnabled('all')";
   my $onClick = "setEnabled($form.$args{name})";
   my $selectedButton = 'respond';
   my ($dupSimStatus, $summaryID) = $dbh->selectrow_array ("select dupsimstatus, summary from $schema.response_version where $relateResponseVersion");
   if ($dupSimStatus != 1) {
      $selectedButton = 'duplicate';
   } elsif ($summaryID || $summarycommentid) {
      $selectedButton = 'summarize';
   }
   tie my %buttons, "Tie::IxHash";
   %buttons = (
      'duplicate' => {label => "<b>This comment is an <font color=#ff0000>exact</font> duplicate:</b>", content => &writeDuplicateCommentInput()},
      'summarize' => {label => "<b>This comment is being summarized:</b>", content => &writeSummaryCommentInput(selectedSummaryComment => $summaryID)},
      'respond'   => {label => "This comment is being responded to individually:", content => $args{responseSection}}
   );
   my $output = &writeRadioBox(name => $args{name}, buttons => \%buttons, default => $selectedButton, onClick => $onClick, height => $args{height});
   $output .= "<script language=javascript><!--\n";
   $output .= "function setEnabled(object) {\n";
   $output .= "   var disabled = (object == 'all') ? false : eval(!object[0].checked);\n";
   $output .= "   var forceEnable = (object == 'all');\n";
   $output .= "   setDuplicateDisabled(disabled);\n";
   $output .= "   disabled = (object == 'all') ? false : eval(!object[1].checked);\n";
   $output .= "   setSummarizeDisabled(disabled);\n";
   $output .= "   disabled = (object == 'all') ? false : eval(!object[2].checked);\n";
   if ($command eq 'assign') {
      $output .= "   setResponseWriterDisabled(disabled);\n";
      $output .= "   setDateDueDisabled(disabled);\n";
      $output .= "   setTechReviewersDisabled(disabled);\n";
   } else {
      $output .= "   $form.$responseText{active}.disabled = disabled;\n";
   }
   $output .= "   setDOEReviewerDisabled(disabled, forceEnable);\n";
   $output .= "   setHasCommitmentsDisabled (disabled);\n";
   $output .= "   setChangeImpactDisabled(disabled);\n";
   $output .= "}\n";
   $output .= "$onClick;\n";
   $output .= "//-->\n";
   $output .= "</script>\n";
   return ($output);
}

###################################################################################################################################
sub responseNeedsTechReview {                                                                                                     #
###################################################################################################################################
   my @row = $dbh->selectrow_array ("select count(*) from $schema.technical_reviewer where $relateComment");
   return ($row[0]);
}

###################################################################################################################################
sub getBinID {                                                                                                                    #
###################################################################################################################################
   my %args = (
      @_,
   );
   my @row = $dbh->selectrow_array ("select b.id from $schema.bin b, $schema.comments c where b.id = c.bin and c.document = $args{document} and c.commentnum = $args{comment}");
   return ($row[0]);
}

###################################################################################################################################
sub getBinName {                                                                                                                  #
###################################################################################################################################
   my %args = (
      @_,
   );
   my @row = $dbh->selectrow_array ("select b.name from $schema.bin b, $schema.comments c where b.id = c.bin and c.document = $args{document} and c.commentnum = $args{comment}");
   return ($row[0]);
}

###################################################################################################################################
sub binIDtoName {                                                                                                                 #
###################################################################################################################################
   my @row = ($dbh->selectrow_array ("select name from $schema.bin b where id = $_[0]"));
   return ($row[0]);
}

###################################################################################################################################
sub haveResponseID {                                                                                                              #
###################################################################################################################################
   return (defined($documentid) && defined($commentid) && ($documentid > 0) && ($documentid <= 999999) && ($commentid > 0) && ($commentid <= 9999));
}

###################################################################################################################################
sub haveVersionNumber {                                                                                                           #
###################################################################################################################################
   return (defined($version) && ($version > 0) && ($version <= 999));
}

###################################################################################################################################
sub saveText {                                                                                                                    #
###################################################################################################################################
   my %args = (
      table => 'response_version',
      where => "$relateResponseVersion",
      @_,
   );
   my $haveText = defined($args{text}) && ($args{text} ne "");
   my $textParamString = ($haveText) ? ":param" : "NULL";
   my $csr = $dbh->prepare("update $schema.$args{table} set $args{column} = $textParamString, dateupdated = SYSDATE where $args{where}");
   $csr->bind_param(":param", $args{text}, {ora_type => ORA_CLOB, ora_field => $args{column}}) if ($haveText);
   $csr->execute;
   $dbh->commit;
}

###################################################################################################################################
sub markDuplicate {                                                                                                               #
###################################################################################################################################
   my %args = (
      updateComment => 1,
      @_,
   );
   my ($dupDocumentID, $dupCommentID) = ($args{dupDocumentID}, $args{dupCommentID});
   my $formattedID = &formatID($CRDType, 6, $dupDocumentID) . "/" . &formatID('', 4, $dupCommentID);
   die ("Comment cannot be a duplicate of itself") if (($args{document} == $dupDocumentID) && ($args{comment} == $dupCommentID));
   die ("Comment $formattedID does not exist") if (!$args{dbh}->selectrow_array("select count(*) from $args{schema}.comments where document = $dupDocumentID and commentnum = $dupCommentID"));
   my $binID = &getBinID(document => $args{document}, comment => $args{comment});
   my $dupBinID = &getBinID(document => $dupDocumentID, comment => $dupCommentID);
   die ("Original and duplicate comment must be in the same bin") if ($binID != $dupBinID);
   my ($dupSimStatus, $dupDupDocumentID, $dupDupCommentID) = $args{dbh}->selectrow_array("select dupsimstatus, dupsimdocumentid, dupsimcommentid from $args{schema}.comments where document = $dupDocumentID and commentnum = $dupCommentID");
   if ($dupSimStatus == 2) { # referenced comment is a duplicate - use its dup doc/comment ID's unless circular reference
      if (($dupDupDocumentID == $args{document}) && ($dupDupCommentID == $args{comment})) {
         die ("Circular duplicate reference - comment $formattedID is a duplicate of the current comment");
      } else {
         ($dupDocumentID, $dupCommentID) = ($dupDupDocumentID, $dupDupCommentID);
         my $origFormattedID = &formatID($CRDType, 6, $args{document}) . "/" . &formatID('', 4, $args{comment});
         my $dupDupFormattedID = &formatID($CRDType, 6, $dupDocumentID) . "/" . &formatID('', 4, $dupCommentID);
         my $msg = "$origFormattedID will be marked as a duplicate of $dupDupFormattedID (instead of \\n$formattedID) because $formattedID is a duplicate of $dupDupFormattedID";
         print "<script language=javascript>\n<!--\nvar mytext ='$msg';\nalert(unescape(mytext));\n//-->\n</script>\n";
      }
   }
   if ($args{updateComment}) {
      my ($changeImpact, $changeControlNum) = &selectChangeImpact(dbh => $args{dbh}, schema => $args{schema}, document => $dupDocumentID, comment => $dupCommentID);
      my $hasCommitments = &selectHasCommitments(dbh => $args{dbh}, schema => $args{schema}, document => $dupDocumentID, comment => $dupCommentID);
      my $DOEReviewer = &selectDOEReviewer(dbh => $args{dbh}, schema => $args{schema}, document => $dupDocumentID, comment => $dupCommentID);
      my ($dateApproved) = $args{dbh}->selectrow_array("select to_char(dateapproved, '$dateFormat') from $args{schema}.comments where document = $dupDocumentID and commentnum = $dupCommentID");
      my $sql = "update $args{schema}.comments set ";
      $sql .= "summary = NULL, ";  # was copying from orig comment but removed it - caused dup comment to be marked both dup and summarized
      $sql .= "hascommitments = '$hasCommitments', ";
      $sql .= "changeimpact = $changeImpact, ";
      $sql .= "changecontrolnum = ";
      $sql .= (defined($changeControlNum)) ? "'$changeControlNum', " : "NULL, ";
      $sql .= "doereviewer = ";
      $sql .= (defined($DOEReviewer)) ? "$DOEReviewer, " : "NULL, ";
      $sql .= "dateapproved = ";
      $sql .= (defined($dateApproved)) ? "to_date('$dateApproved', '$dateFormat'), " : "NULL, ";
      $sql .= "dupsimstatus = 2, dupsimdocumentid = $dupDocumentID, dupsimcommentid = $dupCommentID ";
      $sql .= "where document = $args{document} and commentnum = $args{comment}";
      $args{dbh}->do($sql);
   }
   return ($dupDocumentID, $dupCommentID);
}

###################################################################################################################################
sub markCommentSummarized {                                                                                                       #
###################################################################################################################################
   my %args = (
      @_,
   );
   my ($changeImpact, $changeControlNum) = &selectChangeImpact(dbh => $args{dbh}, schema => $args{schema}, table => 'summary_comment', summaryID => $args{summaryID});
   my $hasCommitments = &selectHasCommitments(dbh => $args{dbh}, schema => $args{schema}, table => 'summary_comment', summaryID => $args{summaryID});
   my $sql = "update $args{schema}.comments set ";
   $sql .= "hascommitments = '$hasCommitments', ";
   $sql .= "changeimpact = $changeImpact, changecontrolnum = ";
   $sql .= (defined($changeControlNum)) ? "'$changeControlNum', " : "NULL, ";
   $sql .= "doereviewer = NULL, summary = $args{summaryID}, ";
   $sql .= "dupsimstatus = 1, dupsimdocumentid = NULL, dupsimcommentid = NULL ";
   $sql .= "where document = $args{document} and commentnum = $args{comment}";
   $args{dbh}->do($sql);
}

###################################################################################################################################
sub createNewResponseVersion {                                                                                                    #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $newStatus = 1;
   my $newVersion = $args{version} + 1;
   my $writer = &getCoordinator();
   my $query = "insert into $args{schema}.response_version (document, commentnum, version, status, responsewriter, dateupdated) ";
   $query .= "values ($args{document}, $args{comment}, $newVersion, $newStatus, $writer, SYSDATE)";
   $args{dbh}->do($query);
}

###################################################################################################################################
sub getRejectStatus {                                                                                                             #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $status;
   if ($args{processStep} eq 'accept') {
      $status = 11;
   } elsif ($args{processStep} eq 'nepareview') {
      $status = 12;
   } elsif ($args{processStep} eq 'doereview') {
      $status = 13;
   }
   return ($status);
}

###################################################################################################################################
sub updateResponseText {                                                                                                          #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $csr = $args{dbh}->prepare("update $args{schema}.response_version set $responseTextColumns{$args{processStep}} = :param1, lastsubmittedtext = :param2 where $args{where}");
   $csr->bind_param(":param1", $args{text}, {ora_type => ORA_CLOB, ora_field => "$responseTextColumns{$args{processStep}}"});
   $csr->bind_param(":param2", $args{text}, {ora_type => ORA_CLOB, ora_field => "lastsubmittedtext"});
   $csr->execute;
}

###################################################################################################################################
sub processAcceptOrRejectResponse {                                                                                               #
###################################################################################################################################
   my %args = (
      decisionName => 'decision',
      radioBoxName => 'radioBox',
      duplicateDocumentName => 'dupDocument',
      duplicateCommentName => 'dupComment',
      summaryCommentName => 'summaryComment',
      @_,
   );
   my ($deleteExistingConcurrences, $deletedConcurrences) = (1, 0);
   my $relateComment = "document = $args{document} and commentnum = $args{comment}";
   my $relateResponseVersion = "$relateComment and version = $args{version}";
   my $decision = $crdcgi->param($args{decisionName});
   my $radioValue = $crdcgi->param($args{radioBoxName});
   my $status;
   my ($summaryID, $dupSimStatus, $dupDocumentID, $dupCommentID) = ('NULL', 1, 'NULL', 'NULL');
   if ($radioValue eq 'duplicate') {
      $dupSimStatus = 2;
      $dupDocumentID = $crdcgi->param($args{duplicateDocumentName});
      $dupCommentID = $crdcgi->param($args{duplicateCommentName});
      if ($decision eq 'reject') {
         &createNewResponseVersion(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment}, version => $args{version});
         $status = &getRejectStatus(processStep => $args{processStep});
      } elsif ($decision eq 'accept') {
         ($dupDocumentID, $dupCommentID) = &markDuplicate(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment}, dupDocumentID => $dupDocumentID, dupCommentID => $dupCommentID);
         $status = 14;
         $dupSimStatus = 1;
         $dupDocumentID = 'NULL';
         $dupCommentID = 'NULL';
      } else {
         die ("$args{processStep} response - unknown decision value");
      }
   } elsif ($radioValue eq 'summarize') {
      $summaryID = $crdcgi->param($args{summaryCommentName});
      if ($decision eq 'reject') {
         &createNewResponseVersion(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment}, version => $args{version});
         $status = &getRejectStatus(processStep => $args{processStep});
      } elsif ($decision eq 'accept') {
         &markCommentSummarized(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment}, summaryID => $summaryID);
         $summaryID = 'NULL';
         $status = 15;
      } else {
         die ("$args{processStep} response - unknown decision value");
      }
   } elsif ($radioValue eq 'respond') {
      if ($decision eq 'reject') {
         &createNewResponseVersion(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment}, version => $args{version});
         $status = &getRejectStatus(processStep => $args{processStep});
      } elsif ($decision eq 'accept') {
         if ($args{processStep} eq 'accept') {
            $status = 7;
         } elsif ($args{processStep} eq 'nepareview') {
            $status = (defined($crdcgi->param("DOEReviewSelected"))) ? 8 : 9;
         } elsif ($args{processStep} eq 'doereview') {
            $status = 9;
         }
         my $modifiedTextName = $args{processStep} . 'text';
         $deleteExistingConcurrences = 0;
         if (defined($crdcgi->param($modifiedTextName))) {
            my $text = $crdcgi->param($modifiedTextName);
            if ($text ne "") {
               $deleteExistingConcurrences = 1;
               &updateResponseText(dbh => $args{dbh}, schema => $args{schema}, processStep => $args{processStep}, text => $text, where => $relateResponseVersion);
            } else {
               $args{dbh}->do("update $args{schema}.response_version set $responseTextColumns{$args{processStep}} = null where $relateResponseVersion");
            }
         }
         &updateDOEReviewer(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment});
         &updateHasCommitments(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment});
         &updateChangeImpact(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment});
         if ($status == 9) {
            my $approvedText = (defined($crdcgi->param($modifiedTextName))) ? $crdcgi->param($modifiedTextName) : "";
            if (!$approvedText) {
               ($approvedText) = $dbh->selectrow_array ("select lastsubmittedtext from $schema.response_version where $relateResponseVersion");
            }
            my $sql = "update $args{schema}.response_version set approvedtext = :param where $relateResponseVersion";
            my $csr = $dbh->prepare($sql);
            $csr->bind_param(":param", $approvedText, {ora_type => ORA_CLOB, ora_field => 'approvedtext'});
            $csr->execute;
            $args{dbh}->do("update $args{schema}.comments set dateapproved = SYSDATE where $relateComment")
         }
      } else {
         die ("$args{processStep} response - unknown decision value");
      }
   } else {
      die ("$args{processStep} response - unknown radio box value");
   }
   $args{dbh}->do("update $args{schema}.response_version set status = $status, dateupdated = SYSDATE, summary = $summaryID, dupsimstatus = $dupSimStatus, dupsimdocumentid = $dupDocumentID, dupsimcommentid = $dupCommentID where $relateResponseVersion");
   if ($deleteExistingConcurrences) {
      my %concurTypes = %{&getLookupValues(dbh => $dbh, schema => $schema, table => 'concurrence_type')};
      foreach my $concurType (keys (%concurTypes)) {
         my ($count) = $dbh->selectrow_array("select count(*) from $schema.concurrence where $relateComment and concurrencetype = $concurType and concurs = 'T'");
         if ($count) {
            $deletedConcurrences = 1;
            $dbh->do ("delete from $schema.concurrence where $relateComment and concurrencetype = $concurType and concurs = 'T'");
            my $remark = "response modified - positive $concurTypes{$concurType} concurrence deleted";
            &addRemark(document => $args{document}, comment => $args{comment}, text => $remark);
            sleep 1;
         }
      }
   }
   $args{dbh}->commit;
   return ($deletedConcurrences);
}

###################################################################################################################################
sub writeAcceptOrRejectResponse {                                                                                                 #
###################################################################################################################################
   my %args = (
      decisionName => 'decision',
      radioBoxName => 'radioBox',
      @_,
   );
   my %changeImpactValues = %{&getLookupValues(dbh => $dbh, schema => $schema, table => 'document_change_impact')};
   my $binid = &getBinID(document => $documentid, comment => $commentid);
   $responseText{active} = $args{processStep} . 'text';
   $responseText{previous} = 'lastSubmittedText';
   my $submittedText = &getText(name => $responseText{previous}, query => "select lastsubmittedtext from $args{schema}.response_version where document = $args{document} and commentnum = $args{comment} and version = $args{version}");
   my $modifiedText = &getText(name => $responseText{active}, query => "select $responseTextColumns{$args{processStep}} from $args{schema}.response_version where document = $args{document} and commentnum = $args{comment} and version = $args{version}");
   my $save = &writeControl(label => 'Save Modified Response', callback => "saveResponse()");
   my $copy = &writeControl(label => 'Copy', callback => 'copyText()');
   my $responseOutput = "<input type=hidden name=$args{decisionName} value=0>\n";
   $responseOutput .= "<tr><td><table border=0 cellpadding=0 cellspacing=0>";
   $responseOutput .= &writeTextBox(name => $responseText{previous}, cols => 83, text => $submittedText, left => '<b>Submitted Response:</b>', right => "<b>$copy the 'Submitted Response' to the 'Enter Modified Response' box</b>", align => 'align=right', readOnly => "true");
   $responseOutput .= &writeTextBox(name => $responseText{active}, cols => 83, text => $modifiedText, left => "<b>Enter Modified Response:</b>", right => $save, align => "height=135 valign=bottom align=right");
   $responseOutput .= "</table></td></tr>";
   $responseOutput .= "<tr>" . &writeDOEReviewer(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment}) . "</tr>";
   $responseOutput .= "<tr>" . &writeHasCommitments(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment}) . "</tr>";
   $responseOutput .= "<tr>" . &writeChangeImpact(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment}) . "</tr>";
   my $accept = &writeControl(label => 'Accept', callback => "processAcceptReject('$args{processStep}','accept')", useLinks => 0);
   my $reject = &writeControl(label => 'Reject', callback => "processAcceptReject('$args{processStep}','reject')", useLinks => 0);
   my $output = "<tr><td><table width=100% border=0>\n";
   $output .= &writeResponseRadioBox(name => $args{radioBoxName}, responseSection => $responseOutput, command => $args{processStep}, height => 35);
   $output .= "<tr><td align=center height=40>$accept" . &nbspaces(4) . "$reject</td></tr>\n";
   $output .= "</table></td></tr>\n";
   $output .= "<script language=javascript><!--\n";
   $output .= "function validateRespondInput() {\n";
   $output .= "   var msg = \"\";\n";
   $output .= "   return (msg);\n";
   $output .= "}\n";
   $output .= "function processAcceptReject(processStep, decision) {\n";
   $output .= "   var msg = \"\";\n";
   $output .= "   var changeImpactValues = new Array();\n";
   foreach my $key (keys (%changeImpactValues)) {
      my $index = $key - 1;
      $output .= "   changeImpactValues[$index] = '$changeImpactValues{$key}';\n";
   }
   $output .= "   var str = changeImpactValues[$form.changeImpact.selectedIndex];\n";
   $output .= "   if ($form.$args{radioBoxName}\[0\].checked) {\n";
   $output .= "      msg = validateDuplicateInput();\n";
   $output .= "   } else if ($form.$args{radioBoxName}\[1\].checked) {\n";
   $output .= "      msg = validateSummarizeInput();\n";
   $output .= "   } else if ($form.$args{radioBoxName}\[2\].checked) {\n";
   $output .= "      msg = validateRespondInput();\n";
   $output .= "   }\n";
   $output .= "   if (msg != \"\") {\n";
   $output .= "      alert(msg);\n";
   $output .= "   } else if (confirm(\"The current Document Change Impact selection for this comment is '\" + str + \"'.\\n\\nIf that value is correct, press 'OK'.\\n\\nIf it is NOT correct, press 'Cancel'.  Then select the correct value and press 'Accept' or 'Reject' again to submit.\")) {\n";
   $output .= "      $form.target = 'cgiresults';\n";
   $output .= "      $form.process.value = processStep;\n";
#   $output .= "      $form.bookmark.value = '$bookmark';\n" if ($bookmark);
   $output .= "      $form.$args{decisionName}.value = decision;\n";
   $output .= "      submitForm('responses', processStep);\n";
   $output .= "   }\n";
   $output .= "}\n";
   $output .= "//-->\n";
   $output .= "</script>\n";
   return ($output);
}

###################################################################################################################################
sub processDevelopResponse {                                                                                                      #
###################################################################################################################################
   my %args = (
      radioBoxName => 'radioBox',
      duplicateDocumentName => 'dupDocument',
      duplicateCommentName => 'dupComment',
      summaryCommentName => 'summaryComment',
      @_,
   );
   my $relateComment = "document = $args{document} and commentnum = $args{comment}";
   my $relateResponseVersion = "$relateComment and version = $args{version}";
   my $radioValue = $crdcgi->param($args{radioBoxName});
   my $status;
   my ($summaryID, $dupSimStatus, $dupDocumentID, $dupCommentID) = ('NULL', 1, 'NULL', 'NULL');
   if ($radioValue eq 'noedits') {
      if ($args{processStep} eq 'edit') {
         $status = 6;
         $args{dbh}->do("update $args{schema}.response_version set techeditedtext = null where $relateResponseVersion");
       } else {
         die ("radio box value is $radioValue but process step is $args{processStep}");
       }
   } elsif ($radioValue eq 'duplicate') {
      $dupSimStatus = 2;
      $dupDocumentID = $crdcgi->param($args{duplicateDocumentName});
      $dupCommentID = $crdcgi->param($args{duplicateCommentName});
      $status = ($args{processStep} eq 'assign') ? 14 : 6;
      my $updateComment = ($args{processStep} eq 'assign') ? 1 : 0;
      ($dupDocumentID, $dupCommentID) = &markDuplicate(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment}, dupDocumentID => $dupDocumentID, dupCommentID => $dupCommentID, updateComment => $updateComment);
      if ($updateComment) {
         $dupSimStatus = 1;
         $dupDocumentID = 'NULL';
         $dupCommentID = 'NULL';
      }
   } elsif ($radioValue eq 'summarize') {
      $summaryID = $crdcgi->param($args{summaryCommentName});
      if ($args{processStep} ne 'assign') {
         $status = 6;
      } else {
         &markCommentSummarized(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment}, summaryID => $summaryID);
         $summaryID = 'NULL';
         $status = 15;
      }
   } elsif ($radioValue eq 'respond') {
      if ($args{processStep} eq 'edit') {
         $status = 6;
         my $redlinetext = $crdcgi->param("redlinetext");
         if (defined($redlinetext) && ($redlinetext ne "")) {
            #  upload and save redline/strikeout text
         }
      } else {
         if ($args{processStep} eq 'write') {
            if (&requireResponseSource()) {
               my $responseSource = "Response source:  " . $crdcgi->param("$responseSourceName");
               &addRemark(document => $args{document}, comment => $args{comment}, text => $responseSource);
            }
            if (&responseNeedsTechReview()) {
               $status = 3;
            } else {
               $status = (&doTechEdit()) ? 5 : 6;
            }
            if ($status == 3) { # insert a row in the technical_review table for each reviewer
               my $csr = $args{dbh}->prepare("insert into $args{schema}.technical_review (document, commentnum, reviewer, version, dateupdated, status) values ($args{document}, $args{comment}, ?, $args{version}, SYSDATE, 1)");
               my @reviewers = &selectTechReviewers (dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment});
               foreach my $reviewer (@reviewers) {
                  $csr->execute($reviewer);
               }
               $csr->finish;
            }
         } elsif ($args{processStep} eq 'modify') {
            $status = (&doTechEdit()) ? 5 : 6;
         } elsif ($args{processStep} eq 'assign') {
            $status = 2;
            my @reviewers;
            my $numReviewers = defined($crdcgi->param("numReviewers")) ? $crdcgi->param("numReviewers") : 0;
            for (my $i = 1; $i <= $numReviewers; $i++) {
               push (@reviewers, $crdcgi->param("reviewer$i")) if defined($crdcgi->param("reviewer$i"));
            }
            $args{dbh}->do("update $args{schema}.comments set dateassigned = SYSDATE where $relateComment");
            &updateResponseWriter(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment}, version => $args{version});
            &updateDateDue(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment});
            &updateTechReviewers(reviewers => \@reviewers, dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment}) if ($args{version} == 1);
         }
         &updateDOEReviewer(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment});
         &updateHasCommitments(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment});
         &updateChangeImpact(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, comment => $args{comment});
      }
      &updateResponseText(dbh => $args{dbh}, schema => $args{schema}, processStep => $args{processStep}, text => $args{text}, where => $relateResponseVersion) if ($args{processStep} ne 'assign');
   } else {
      die ("Process $args{processStep} response - unknown radio box value");
   }
   $args{dbh}->do("update $args{schema}.response_version set status = $status, dateupdated = SYSDATE, summary = $summaryID, dupsimstatus = $dupSimStatus, dupsimdocumentid = $dupDocumentID, dupsimcommentid = $dupCommentID where $relateResponseVersion");
   $args{dbh}->commit;
}

###################################################################################################################################
sub writeDevelopResponse {                                                                                                        #
###################################################################################################################################
   my %args = (
      radioBoxName => 'radioBox',
      @_,
   );
   my %changeImpactValues = %{&getLookupValues(dbh => $dbh, schema => $schema, table => 'document_change_impact')};
   my $output = "<script language=javascript><!--\n";
   $output .= "function validateRespondInput(processStep) {\n";
   $output .= "   var msg = \"\";\n";
   $output .= "   if (((processStep == 'write') || (processStep == 'modify')) && (isblank($form.$responseText{active}.value))) {\n";
   $output .= "      msg = \"Response text is required but none has been entered.\\n\";\n";
   $output .= "   }\n";
   if (&requireResponseSource()) {
      $output .= "   if ((processStep == 'write') && (isblank($form.$responseSourceName.value))) {\n";
      $output .= "      msg += \"Response text source is required but none has been entered.\";\n";
      $output .= "   }\n";
   }
   $output .= "   return (msg);\n";
   $output .= "}\n";
   $output .= "function processResponse(processStep) {\n";
   $output .= "   var changeImpactValues = new Array();\n";
   foreach my $key (keys (%changeImpactValues)) {
      my $index = $key - 1;
      $output .= "   changeImpactValues[$index] = '$changeImpactValues{$key}';\n";
   }
   $output .= "   var str = changeImpactValues[$form.changeImpact.selectedIndex];\n";
   $output .= "   var msg = \"\";\n";
   $output .= "   if ($form.$args{radioBoxName}\[0\].checked) {\n";
   $output .= "      msg = validateDuplicateInput();\n";
   $output .= "   } else if ($form.$args{radioBoxName}\[1\].checked) {\n";
   $output .= "      msg = validateSummarizeInput();\n";
   $output .= "   } else if ($form.$args{radioBoxName}\[2\].checked) {\n";
   $output .= "      msg = validateRespondInput(processStep);\n";
   $output .= "   }\n";
   $output .= "   if (msg != \"\") {\n";
   $output .= "      alert(msg);\n";
   $output .= "   } else if (confirm(\"The current Document Change Impact selection for this comment is '\" + str + \"'.\\n\\nIf that value is correct, press 'OK'.\\n\\nIf it is NOT correct, press 'Cancel'.  Then select the correct value and press 'Submit' again.\")) {\n";
   $output .= "      $form.target = 'cgiresults';\n";
   $output .= "      $form.process.value = processStep;\n";
   $output .= "      submitForm('responses', processStep);\n";
   $output .= "   }\n";
   $output .= "}\n";
   $output .= "//-->\n";
   $output .= "</script>\n";
   return ($output);
}

###################################################################################################################################
sub updateTechReviewStatus {                                                                                                      #
###################################################################################################################################
   my $reviewStatus = 0;
   my $done = 1;
   my $csr = $dbh->prepare("select status from $schema.technical_review where $relateResponseVersion");
   $csr->execute;
   while (my @values = $csr->fetchrow_array) {
      if ($values[0] == 1) {
         $done = 0;
         last;
      } elsif ($values[0] > $reviewStatus) {
         $reviewStatus = $values[0];
      }
   }
   $csr->finish;
   my $responseStatus;
   if ($done) {
      if ($reviewStatus == 2) {
         $responseStatus = (doTechEdit()) ? 5 : 6;
      } elsif ($reviewStatus == 3) {
         $responseStatus = 4;
      } elsif ($reviewStatus == 4) {
         $responseStatus = 10;
      } else {
         die ("Invalid review status value: $reviewStatus");
      }
      my $rc = $dbh->do("update $schema.response_version set status = $responseStatus, dateupdated = SYSDATE where $relateResponseVersion");
      if ($responseStatus == 10) {
         $responseStatus = 1;
         my $newVersion = $version + 1;
         my $writer = &getCoordinator();
         $rc = $dbh->do("insert into $schema.response_version (document, commentnum, version, status, responsewriter, dateupdated) values ($documentid, $commentid, $newVersion, $responseStatus, $writer, SYSDATE)");
      }
   }
}

###################################################################################################################################
sub processSubmittedData {                                                                                                        #
###################################################################################################################################
   print $crdcgi->header('text/html');
   print "<html>\n<head>\n</head>\n<body>\n";
   my $activity = "";
   my $logActivity = 0;
   my $error = "";
   my $newCommand;
   my $identifiers = "- " . &formatID($CRDType, 6, $documentid) . "/" . &formatID('', 4, $commentid) . "/" . &formatID('', 2, $version);
   eval {
      #############################################################################################################################
      if ($process eq 'browse') {                                                                                                 #
      #############################################################################################################################
         $activity = "browse - get current response version number";
         my ($count) = $dbh->selectrow_array("select count(*) from $schema.comments where $relateComment");
         if (!$count) {
            $error = "No such comment:  " . &formatID($CRDType, 6, $documentid) . " / " . &formatID('', 4, $commentid);
         } else {
            my @row = $dbh->selectrow_array("select max(version) from $schema.response_version where $relateComment");
            if (defined($row[0])) {
               $version = $row[0];
            } else {
               $error = "No response exists for " . &formatID($CRDType, 6, $documentid) . " / " . &formatID('', 4, $commentid);
            }
         }
      #############################################################################################################################
      } elsif ($process eq 'validateIDforUpdateApproved') {                                                                       #
      #############################################################################################################################
         $activity = "update approved response - get current response version number";
         my $formattedID = &formatID($CRDType, 6, $documentid) . " / " . &formatID('', 4, $commentid);
         my ($count) = $dbh->selectrow_array("select count(*) from $schema.comments where $relateComment");
         if (!$count) {
            $error = "No such comment: $formattedID";
         } else {
            my ($version) = $dbh->selectrow_array("select max(version) from $schema.response_version where $relateComment");
            if (!defined($version)) {
               $error = "No response exists for $formattedID";
            } else {
               my ($responseStatus) = $dbh->selectrow_array("select status from $schema.response_version where $relateComment and version = $version");
               $error = "Response for comment $formattedID is not approved" if ($responseStatus != 9);
            }
         }
      #############################################################################################################################
      } elsif ($process eq 'validateIDforDoWorkflowStep') {                                                                       #
      #############################################################################################################################
         $activity = "do workflow step - get response version and status";
         my $formattedID = &formatID($CRDType, 6, $documentid) . " / " . &formatID('', 4, $commentid);
         my ($count) = $dbh->selectrow_array("select count(*) from $schema.comments where $relateComment");
         if (!$count) {
            $error = "No such comment: $formattedID";
         } else {
            ($version) = $dbh->selectrow_array("select max(version) from $schema.response_version where $relateComment");
            if (!defined($version)) {
               $error = "No response exists for $formattedID";
            } else {
               my ($responseStatus) = $dbh->selectrow_array("select status from $schema.response_version where $relateComment and version = $version");
               my %statusValues = %{&getLookupValues(dbh => $dbh, schema => $schema, table => 'response_status')};
               if (($responseStatus == 3) || ($responseStatus > 8)) {
                  $error = "Response $formattedID - workflow step cannot be performed (status = $statusValues{$responseStatus})"
               } else {
                  if ($responseStatus == 1) {
                     $newCommand = 'assign';
                  } elsif ($responseStatus == 2) {
                     $newCommand = 'write';
                  } elsif ($responseStatus == 4) {
                     $newCommand = 'modify';
                  } elsif ($responseStatus == 5) {
                     $newCommand = 'edit';
                  } elsif ($responseStatus == 6) {
                     $newCommand = 'accept';
                  } elsif ($responseStatus == 7) {
                     $newCommand = 'nepareview';
                  } elsif ($responseStatus == 8) {
                     $newCommand = 'doereview';
                  }
               }
            }
         }
      #############################################################################################################################
      } elsif ($process eq 'validateIDforUpdateResponseWriter') {                                                                 #
      #############################################################################################################################
         $activity = "update response writer - validate ID";
         my $formattedID = &formatID($CRDType, 6, $documentid) . " / " . &formatID('', 4, $commentid);
         my ($count) = $dbh->selectrow_array("select count(*) from $schema.comments where $relateComment");
         if (!$count) {
            $error = "No such comment: $formattedID";
         } else {
            my ($version) = $dbh->selectrow_array("select max(version) from $schema.response_version where $relateComment");
            if (!defined($version)) {
               $error = "No response exists for $formattedID";
            } else {
               my ($responseStatus) = $dbh->selectrow_array("select status from $schema.response_version where $relateComment and version = $version");
               $error = "Can't update writer for $formattedID - not in RESPONSE DEVELOPMENT/MODIFICATION or TECHNICAL REVIEW status" if (($responseStatus < 2) || ($responseStatus > 4));
            }
         }
      #############################################################################################################################
      } elsif ($process eq 'enter') { # invoked from supplemental data entry home - proxy enter of response - check validity here #
      #############################################################################################################################
         $activity = "enter response - determine version number";
         my @row = $dbh->selectrow_array("select version from $schema.response_version where $relateComment and status = 2 and originaltext is NULL");
         if (defined($row[0])) {
            $version = $row[0];
            my ($count) = $dbh->selectrow_array("select count(*) from $schema.response_version_entry where $relateComment and version = $version");
            if ($count != 0) {
               $error = "A response has already been entered for comment document " . &formatID($CRDType, 6, $documentid) . ", comment " . &formatID('', 4, $commentid) . " and is awaiting proofreading.";
            }
         } else {
            $error = "A response cannot be entered for comment document " . &formatID($CRDType, 6, $documentid) . ", comment " . &formatID('', 4, $commentid) . ".\n\n";
            $error .= "Either the ID's you entered do not identify a valid comment or a response version cannot be entered while the response is in its current state.";
         }
      #############################################################################################################################
      } elsif ($process eq 'saveRemark') {                                                                                        #
      #############################################################################################################################
         my $text = $crdcgi->param('remarktext');
         $activity = "save remark on comment " . &formatID('', 4, $commentid) . ", document " . &formatID($CRDType, 6, $documentid);
         my $csr = $dbh->prepare("insert into $schema.comments_remark (document, commentnum, remarker, dateentered, text) values ($documentid, $commentid, $userid, SYSDATE, :param)");
         $csr->bind_param(":param", $text, {ora_type => ORA_CLOB, ora_field => 'text'});
         $csr->execute;
         $dbh->commit;
         $crdcgi->delete('remarktext');
      #############################################################################################################################
      } elsif ($process eq 'saveReview') {                                                                                        #
      #############################################################################################################################
         $activity = "save technical review $identifiers";
         my $text = $crdcgi->param("reviewtext");
         &saveText(text => $text, table => 'technical_review', column => 'text', where => "$relateResponseVersion and reviewer = $userid");
      #############################################################################################################################
      } elsif ($process eq 'saveResponse') {  # incremental saves of response text                                                #
      #############################################################################################################################
         my $textName = $command . 'text';
         my $text = $crdcgi->param($textName);
         $activity = "save $command response text: $identifiers";
         &saveText(text => $text, column => $responseTextColumns{$command});
         if (&requireResponseSource()) {
            if ($crdcgi->param("$responseSourceName")) {
               my $responseSource = "Response source (draft):  " . $crdcgi->param("$responseSourceName");
               &addRemark(document => $documentid, comment => $commentid, text => $responseSource);
            }
         }
      #############################################################################################################################
      } elsif ($process eq 'enterResponse') {                                                                                     #
      #############################################################################################################################
         my $textName = $command . 'text';
         my $text = $crdcgi->param($textName);
         $activity = "proxy enter response $identifiers";
         my $csr = $dbh->prepare("insert into $schema.response_version_entry (document, commentnum, version, text, enteredby, entrydate) values ($documentid, $commentid, $version, :param, $userid, SYSDATE)");
         $csr->bind_param(":param", $text, {ora_type => ORA_CLOB, ora_field => 'text'});
         $csr->execute;
         $dbh->commit;
         $logActivity = 1;
         $form = 'home';
      #############################################################################################################################
      } elsif ($process eq 'proofreadResponse') {                                                                                 #
      #############################################################################################################################
         my $textName = $command . 'text';
         my $text = $crdcgi->param($textName);
         my $status = (responseNeedsTechReview()) ? 3 : 5;
         $activity = "proofread response version $identifiers";
         my ($enteredBy, $entryDate) = $dbh->selectrow_array("select enteredby, to_char(entrydate, '$dateFormat') from $schema.response_version_entry where $relateResponseVersion");
         my $csr = $dbh->prepare("update $schema.response_version set originaltext = :param1, lastsubmittedtext = :param2, status = $status, enteredby = $enteredBy, entrydate = to_date('$entryDate', '$dateFormat'), proofreadby = $userid, proofreaddate = SYSDATE, dateupdated = SYSDATE where $relateResponseVersion");
         $csr->bind_param(":param1", $text, {ora_type => ORA_CLOB, ora_field => 'originaltext'});
         $csr->bind_param(":param2", $text, {ora_type => ORA_CLOB, ora_field => 'lastsubmittedtext'});
         $csr->execute;
         if ($status == 3) { # Response status changed to TECHNICAL_REVIEW - insert a row in the Technical_Review table for each reviewer
            my $insertcsr = $dbh->prepare("insert into $schema.technical_review (document, commentnum, reviewer, version, dateupdated, status) values ($documentid, $commentid, ?, $version, SYSDATE, 1)");
            my $csr = $dbh->prepare("select reviewer from $schema.technical_reviewer where $relateComment");
            $csr->execute;
            while (my @values = $csr->fetchrow_array) {
               $insertcsr->execute($values[0]);
            }
            $csr->finish;
         }
         my $rc = $dbh->do("delete from $schema.response_version_entry where $relateResponseVersion");
         $dbh->commit;
         $logActivity = 1;
         $form = 'home';
      #############################################################################################################################
      } elsif ($process eq 'assign') {                                                                                            #
      #############################################################################################################################
         $activity = "process response - $process $identifiers" . $proxy;
         &processDevelopResponse(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, version => $version, processStep => $process);
         $logActivity = 1;
         $form = 'home';
      #############################################################################################################################
      } elsif (($process eq 'write') || ($process eq 'modify') || ($process eq 'edit')) {                                         #
      #############################################################################################################################
         my $textName = $command . 'text';
         my $text = $crdcgi->param($textName);
         $activity = "process response - $process $identifiers" . $proxy;
         &processDevelopResponse(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, version => $version, processStep => $process, text => $text);
         $logActivity = 1;
         $form = 'home';
      #############################################################################################################################
      } elsif (($process eq 'accept') || ($process eq 'nepareview') || ($process eq 'doereview')) {                               #
      #############################################################################################################################
         my $processString = "";
         if ($process eq 'accept') {
            $processString = $process;
         } elsif ($process eq 'nepareview') {
            $processString = lc($firstReviewName) . "review";
         } elsif ($process eq 'doereview') {
            $processString = lc($secondReviewName) . "review";
         }
         $activity = "process response - $processString $identifiers" . $proxy;
         my $deletedConcurrences = &processAcceptOrRejectResponse(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, version => $version, processStep => $process);
         $activity .= " - positive concurrence(s) deleted" if ($deletedConcurrences);
         $logActivity = 1;
         $form = 'home';
      #############################################################################################################################
      } elsif ($process eq 'review') {                                                                                            #
      #############################################################################################################################
         $activity = "process technical review $identifiers";
         my $radioValue = $crdcgi->param("radioBox");
         my $text = $crdcgi->param("reviewtext");
         my $status;
         if ($radioValue eq 'approve') {
            $status = 2;
         } elsif ($radioValue eq 'modify') {
            $status = 3;
         } elsif ($radioValue eq 'reject') {
            $status = 4;
         } else {
            die ("Unknown radio box value");
         }
         my $textParamString = ($status == 2) ? "" : "text = :param,";
         my $csr = $dbh->prepare("update $schema.technical_review set $textParamString status = $status, dateupdated = SYSDATE where $relateResponseVersion and reviewer = $userid");
         $csr->bind_param(":param", $text, {ora_type => ORA_CLOB, ora_field => 'text'}) if ($status != 2);
         $csr->execute;
         &updateTechReviewStatus();
         $dbh->commit;
         $logActivity = 1;
         $form = 'home';
      #############################################################################################################################
      } elsif ($process eq 'assigneditor') {                                                                                      #
      #############################################################################################################################
         $activity = "check for assigned tech editor $identifiers";
         my @row = $dbh->selectrow_array("select techeditor from $schema.response_version where $relateResponseVersion");
         if (!defined($row[0])) {
            $activity = "assign user $username tech editor $identifiers";
            my $rc = $dbh->do("update $schema.response_version set techeditor = $userid where $relateResponseVersion");
            $dbh->commit;
            $logActivity = 1;
         }
      #############################################################################################################################
      } elsif ($process eq 'update_status') {
      #############################################################################################################################
         my $numComments = defined($crdcgi->param("numComments")) ? $crdcgi->param("numComments") : 0;
         my $count = 0;
         for (my $i = 1; $i <= $numComments; $i++) {
            if (defined($crdcgi->param("comment$i"))) {
               $count++;
               my ($documentID, $commentID) = split $delimiter, $crdcgi->param("comment$i");
               my ($version) = $dbh->selectrow_array ("select max(version) from $schema.response_version where document = $documentID and commentnum = $commentID");
               $dbh->do ("update $schema.response_version set status = 7, dateupdated = SYSDATE where document = $documentID and commentnum = $commentID and version = $version");
               $dbh->do ("update $schema.comments set dateapproved = NULL where document = $documentID and commentnum = $commentID");
               &addRemark(document => $documentID, comment => $commentID, text => "Reset from APPROVED to $firstReviewName REVIEW/APPROVAL status");
               $crdcgi->delete("comment$i");
            }
         }
         $activity = "update response status for $count comment";
         $activity .= "s" if ($count > 1);
         $logActivity = ($count) ? 1 : 0;
      #############################################################################################################################
      } elsif ($process eq 'update_response_writer') {
      #############################################################################################################################
         my $formattedDocumentID = &formatID($CRDType, 6, $documentid);
         my $formattedCommentID = &formatID("", 4, $commentid);
         my $formattedID = "$formattedDocumentID / $formattedCommentID";
         my ($version) = $dbh->selectrow_array("select max(version) from $schema.response_version where document = $documentid and commentnum = $commentid");
         &updateResponseWriter(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, version => $version);
         my ($writer) = $crdcgi->param("responseWriter");
         $writer = &get_fullname($dbh, $schema, $writer);
         $activity = "update response writer for $formattedID - $writer";
         $logActivity = 1;
         $form = 'utilities';
      #############################################################################################################################
      } elsif ($process eq 'update_approved') {                                                                                                 #
      #############################################################################################################################
         my $formattedDocumentID = &formatID($CRDType, 6, $documentid);
         my $formattedCommentID = &formatID("", 4, $commentid);
         my $formattedID = "$formattedDocumentID / $formattedCommentID";
         $activity = "process response - update approved response for $formattedID";
         my $concurDeleteActivity = "";
         my $responseText = $crdcgi->param("approvedResponse");
         my $remarkText = $crdcgi->param("remark");
         my $sql = "update $schema.response_version set lastsubmittedtext = :param, dateupdated = SYSDATE where $relateResponseVersion";
         my $csr = $dbh->prepare($sql);
         $csr->bind_param(":param", $responseText, {ora_type => ORA_CLOB, ora_field => 'lastsubmittedtext'});
         $csr->execute;
         if ($remarkText) {
            $csr = $dbh->prepare("insert into $schema.comments_remark (document, commentnum, remarker, dateentered, text) values ($documentid, $commentid, $userid, SYSDATE, :param)");
            $csr->bind_param(":param", $remarkText, {ora_type => ORA_CLOB, ora_field => 'text'});
            $csr->execute;
         }
         my %concurTypes = %{&getLookupValues(dbh => $dbh, schema => $schema, table => 'concurrence_type')};
         foreach my $concurType (keys (%concurTypes)) {
            my ($count) = $dbh->selectrow_array("select count(*) from $schema.concurrence where document = $documentid and commentnum = $commentid and concurrencetype = $concurType and concurs = 'T'");
            if ($count) {
               $dbh->do ("delete from $schema.concurrence where document = $documentid and commentnum = $commentid and concurrencetype = $concurType and concurs = 'T'");
               my $remark = "approved response text updated - positive $concurTypes{$concurType} concurrence deleted";
               &addRemark(document => $documentid, comment => $commentid, text => $remark);
               $concurDeleteActivity = " - positive concurrence(s) deleted";
               sleep 1;
            }
         }
         $activity .= $concurDeleteActivity;
         $dbh->commit;
         $logActivity = 1;
      #############################################################################################################################
      } elsif ($process eq 'concur') {
      #############################################################################################################################
         my $formattedID = &formatID($CRDType, 6, $documentid) . " / " . &formatID("", 4, $commentid);
         $logActivity = 1;
         my $activityType = "";
         my $concurs = ($crdcgi->param("concurs")) ? 'T' : 'F';
         my $concurType = $crdcgi->param("concurtype");
         my $remarks = (defined($crdcgi->param("remarks"))) ? $crdcgi->param("remarks") : "";
         my %concurTypes = %{&getLookupValues(dbh => $dbh, schema => $schema, table => 'concurrence_type')};
         my ($count) = $dbh->selectrow_array("select count(*) from $schema.concurrence where document = $documentid and commentnum = $commentid and concurrencetype = $concurType");
         if ($count) {
            $activityType = "update";
            $dbh->do ("update $schema.concurrence set concurrencetype = $concurType, concurdate = SYSDATE, concurs = '$concurs' where document = $documentid and commentnum = $commentid and concurrencetype = $concurType");
         } else {
            $activityType = "enter";
            $dbh->do ("insert into $schema.concurrence (document, commentnum, concurrencetype, concurs, concurdate) values ($documentid, $commentid, $concurType, '$concurs', SYSDATE)");
         }
         $activity = "$activityType $concurTypes{$concurType} concurrence for $formattedID";
         &addRemark(document => $documentid, comment => $commentid, text => $remarks) if ($remarks);
         $dbh->commit;
         $form = 'home';
      #############################################################################################################################
      } elsif ($process eq 'saveFilter') {                                                                                        #
      #############################################################################################################################
         $activity = "save new user preference value for bin filter";
         my $bin = defined($crdcgi->param("filterBin")) ? $crdcgi->param("filterBin") : 0;
         my $subbins = defined($crdcgi->param("subbins")) ? 'T' : 'F';
         my ($hasPreferences) = $dbh->selectrow_array ("select count(*) from $schema.user_preferences where userid = $userid");
         if ($bin == 0) {
            $dbh->do("update $schema.user_preferences set binfilter = null, binfiltersubbins = '$subbins' where userid = $userid") if ($hasPreferences);
         } else {
            if ($hasPreferences) {
               $dbh->do("update $schema.user_preferences set binfilter = $bin, binfiltersubbins = '$subbins' where userid = $userid");
            } else {
               $dbh->do("insert into $schema.user_preferences (userid, binfilter, binfiltersubbins) values ($userid, $bin, '$subbins')");
            }
         }
         $dbh->commit;
         $logActivity = 1;
      }
   };
   ################################################################################################################################
   if ($@) {
      $dbh->rollback;
      $error = &errorMessage($dbh, $username, $userid, $schema, $activity, $@);
   } elsif ($logActivity) {
      &log_activity ($dbh, $schema, $userid, $activity);
   }
   if ($error) { # display the error message
      $error =~ s/\n/\\n/g;
      $error =~ s/'/%27/g;
      print "<script language=javascript>\n<!--\nvar mytext ='$error';\nalert(unescape(mytext));\n//-->\n</script>\n";
   } else { # submit a form to run the required script and produce output in the main window
      $form = "utilities" if ($isProxy && ($command ne 'validateIDforDoWorkflowStep'));
      print "<form name=$form method=post target=main action=$path$form.pl>\n";
      if ($form eq 'responses') {
         my @paramlist = $crdcgi->param();
         foreach my $param (@paramlist) {
            my $val = ($param eq 'process') ? 0 : $crdcgi->param($param);
            $val =~ s/'/%27/g;
            $val = $version if ($param eq 'version');
            $val = $newCommand if (($param eq 'command') && ($command eq 'validateIDforDoWorkflowStep'));
            next if (($param eq 'useFormValues') && ($command eq 'validateIDforDoWorkflowStep'));
            print "<input type=hidden name='$param' value='$val'>\n";
         }
      } else {
         print "<input type=hidden name=username value=$username>\n";
         print "<input type=hidden name=userid value=$userid>\n";
         print "<input type=hidden name=schema value=$schema>\n";
#         print "<input type=hidden name=bookmark value=$bookmark>\n" if ($bookmark && ($form eq "home"));
      }
      print "</form>\n";
      print "<script language=javascript>\n<!--\n$form.submit();\n//-->\n</script>\n";
   }
   print "</body>\n</html>\n";
}

###################################################################################################################################
sub enableBrowse {                                                                                                                #
###################################################################################################################################
   foreach my $section (@_) {
      ${$sections{'browse' . $section}}{'enabled'} = 1;
      ${$sections{'browse' . $section}}{'title'} = 'Browse ' . ${$sections{'browse' . $section}}{'title'} if ($command ne 'browse');
   }
}

###################################################################################################################################
sub configureSections {                                                                                                           #
###################################################################################################################################
   my $section = $_[0];
   ${$sections{$section}}{'enabled'} = 1;
   ${$sections{$section}}{'defaultOpen'} = 1;
   ${$sections{$section}}{'locked'} = 1 if (($section eq $command) && ($command ne 'browse'));
   if ($section eq 'browse') {
      ${$sections{'instructions'}}{'enabled'} = 0;
      if (!&haveResponseID) {
         ${$sections{'information'}}{'enabled'} = 0;
         ${$sections{'remarks'}}{'enabled'} = 0;
         ${$sections{'comment'}}{'enabled'} = 0;
      }
      else {
         my @row;
         eval {
            if (!&haveVersionNumber) {
               ($version) = $dbh->selectrow_array ("select max(version) from $schema.response_version where $relateComment");
               $relateResponseVersion = $relateComment . " and version = $version";
            }
            @row = $dbh->selectrow_array ("select status from $schema.response_version where $relateResponseVersion");
            my $status = $row[0] - 0;
            if (($status == 8) || ($status == 9) || ($status == 13)) {
               enableBrowse ('doereview', 'nepareview', 'accept', 'edit', 'modify', 'review', 'write');
            } elsif (($status == 7) || ($status == 12)) {
               enableBrowse ('nepareview', 'accept', 'edit', 'modify', 'review', 'write');
            } elsif (($status == 6) || ($status == 11)) {
               enableBrowse ('accept', 'edit', 'modify', 'review', 'write');
            } elsif ($status == 5) {
               enableBrowse ('edit', 'modify', 'review', 'write');
            } elsif ($status == 4) {
               enableBrowse ('modify', 'review', 'write');
            } elsif (($status == 3) || ($status == 10)) {
               enableBrowse ('review', 'write');
            } elsif ($status == 2) {
               enableBrowse ('review', 'write');
               ${$sections{'browsereview'}}{'title'} = 'Assigned Technical Reviewers';
            }
         };
         &processError(activity => 'configure response sections') if ($@);
      }
   } elsif ($section eq 'doereview') {
       enableBrowse ('nepareview', 'accept', 'edit', 'modify', 'review', 'write');
   } elsif ($section eq 'nepareview') {
       enableBrowse ('accept', 'edit', 'modify', 'review', 'write');
   } elsif ($section eq 'accept') {
       enableBrowse ('edit', 'modify', 'review', 'write');
   } elsif ($section eq 'edit') {
       enableBrowse ('modify', 'review', 'write');
   } elsif ($section eq 'modify') {
       enableBrowse ('review', 'write');
   } elsif ($section eq 'review') {
      enableBrowse ('review', 'write');
      ${$sections{'browsereview'}}{'title'} = 'Browse other Technical Reviews of the Response';
   }
}

###################################################################################################################################
sub doHeader {                                                                                                                    #
###################################################################################################################################
   my $section = $_[0];
   if ($section ne 'browse') {
      my $textColor = (${$sections{$section}}{'locked'}) ? '#ff0000' : '#000060';
      $output .=  "<tr><td><a name=$section></a><table width=100% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellspacing=0 cellpadding=0><tr>\n";
      $output .= "<td align=center bgcolor=#f3f3f3 width=22>" . &sectionImageTag($section) . "</td>\n";
      $output .= "<td height=23 bgcolor=#f3f3f3><font face=arial color=$textColor><b>" . &nbspaces(2) . "${$sections{$section}}{'title'}</b></font></td>\n";
      $output .= "</tr></table>\n</td></tr>\n";
      $output .= "<tr><td height=15> </td></tr>\n";
   }
}

###################################################################################################################################
sub doSection {                                                                                                                   #
###################################################################################################################################
   my $section = $_[0];
   $output .= "<tr><td align=right>\n";
   $output .= "<table width=750 border=0>\n";
   eval {
      #############################################################################################################################
      if ($section eq 'browse') {                                                                             #  Browse Response  #
      #############################################################################################################################
         if (&sectionIsOpen($section)) {
            $output .= "</table></td></tr><tr><td align=center><table>\n";  # close the right-aligned <td>, so this section can be centered
            $output .= "<tr><td align=center><font face=arial><b>$CRDType<input type=text size=6 maxlength=6 name=responsebrowsecdid> / <input type=text size=4 maxlength=4 name=responsebrowsecid>";
            $output .= &nbspaces(3) . "<input type=button name=responsego value='Go' onClick=javascript:browse_response()></b></font></td></tr>\n";
         }
      #############################################################################################################################
      } elsif ($section eq 'information') {                                                              #  Response Information  #
      #############################################################################################################################
         if (&sectionIsOpen($section)) {
            $output .= &writeGeneralInfoTable(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid,  version => $version);
            my ($status) = $dbh->selectrow_array ("select status from $schema.response_version where $relateResponseVersion");
            if ($status == 9) {
               $output .= "</table><table cellpadding=3 cellspacing=3>";
               my ($text) = $dbh->selectrow_array ("select lastsubmittedtext from $schema.response_version where $relateResponseVersion");
               $output .= &writeTextBox(name => "approved", text => $text, left => "<b>Approved Response Text</b>", readOnly => 'true');
            }
         }
      #############################################################################################################################
      } elsif ($section eq 'comment') {                                                                               #  Comment  #
      #############################################################################################################################
         if (&sectionIsOpen($section)) {
            $commentText = &getText(useForm => 0, query => "select text from $schema.comments where $relateComment");
            $output .= &writeTextBox(name => "commentText", text => $commentText, left => '<b>Comment Text:</b>', readOnly => 'true');
         }
      #############################################################################################################################
      } elsif ($section eq 'remarks') {                                                                               #  Remarks  #
      #############################################################################################################################
         my $showTextBox = ($command ne 'browse') ? 1 : 0;
         $output .= &doRemarks(schema => $schema, dbh => $dbh, remark_type => 'comment', document => $documentid, comment => $commentid, show_text_box => $showTextBox, useForm => $useFormValues) if (&sectionIsOpen($section));
      #############################################################################################################################
      } elsif ($section eq 'instructions') {                                                                     #  Instructions  #
      #############################################################################################################################
         $output .= "<tr><td><b><font face=arial color=$instructionsColor>${$sections{$command}}{$section}</font></b></td></tr>\n" if (&sectionIsOpen($section));
      #############################################################################################################################
      } elsif (($section eq 'doereview') || ($section eq 'nepareview') || ($section eq 'accept')) { #  Accept or Reject Response  #
      #############################################################################################################################
         $output .= &writeAcceptOrRejectResponse(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, version => $version, processStep => $section);
      #############################################################################################################################
      } elsif (($section eq 'browsedoereview') && (&sectionIsOpen($section))) {                    #  Browse DOE Review/Approval  #
      #############################################################################################################################
         my $reviewer = &selectDOEReviewer(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid);
         if (!defined($reviewer)) {
            $output .= "<tr><td><b>The response was not selected for $secondReviewName Review.</b></td></tr>";
         } else {
            my $statusText = '<b>Status:' . &nbspaces(3);
            my $textName = $section . 'text';
            $reviewer = "<b>$secondReviewName Reviewer:" . &nbspaces(2) . "<a href=javascript:display_user($reviewer)>" . &get_fullname($dbh, $schema, $reviewer) . '</a></b>';
            my ($text, $status) = $dbh->selectrow_array ("select doeeditedtext, status from $schema.response_version where $relateResponseVersion");
            $status -= 0;
            if (($status < 8) || ($status == 10) || ($status == 11) || ($status == 12)) {
               $statusText .= 'ERROR: INVALID STATE';
            } elsif ($status == 8) {
               $statusText .= 'AWAITING APPROVAL';
               $statusText .= ' - NO TEXT HAS BEEN ENTERED' if ($text eq "");
            } elsif ($status == 13) {
               $statusText .= 'REJECTED';
            } elsif ($status == 9) {
               $statusText .= 'APPROVED';
               $statusText .= ' WITHOUT MODIFICATION' if ($text eq "");
            }
            $statusText .= '</b>';
            $output .= &writeTextBox(name => $textName, text => $text, left => $reviewer, right => $statusText, readOnly => 'true', drawBoxIfTextNull => 0);
         }
      #############################################################################################################################
      } elsif (($section eq 'browsenepareview') && (&sectionIsOpen($section))) {                  #  Browse NEPA Review/Approval  #
      #############################################################################################################################
         my $textName = $section . 'text';
         my ($text, $status) = $dbh->selectrow_array ("select nepaeditedtext, status from $schema.response_version where $relateResponseVersion");
         my $statusText = '<b>Status:' . &nbspaces(3);
         my @row = $dbh->selectrow_array ("select b.nepareviewer from $schema.comments c, $schema.bin b, $schema.response_version r where c.document = $documentid and c.commentnum = $commentid and c.document = r.document and c.commentnum = r.commentnum and r.version = $version and c.bin = b.id");
         my $nepaReviewer = $row[0];
         $nepaReviewer = "<b>$firstReviewName Reviewer:" . &nbspaces(2) . "<a href=javascript:display_user($nepaReviewer)>" . &get_fullname($dbh, $schema, $nepaReviewer) . '</a></b>';
         $status -= 0;
         if (($status < 7) || ($status == 10) || ($status == 11)) {
            $statusText .= 'ERROR: INVALID STATE';
         } elsif ($status == 7) {
            $statusText .= 'AWAITING APPROVAL';
            $statusText .= ' - NO TEXT HAS BEEN ENTERED' if ($text eq "");
         } elsif ($status == 12) {
            $statusText .= 'REJECTED';
         } else {
            $statusText .= 'APPROVED';
            $statusText .= ' WITHOUT MODIFICATION' if ($text eq "");
         }
         $statusText .= '</b>';
         $output .= &writeTextBox(name => $textName, text => $text, left => $nepaReviewer, right => $statusText, readOnly => 'true', drawBoxIfTextNull => 0);
      #############################################################################################################################
      } elsif (($section eq 'browseaccept') && (&sectionIsOpen($section))) {                #  Browse Bin Coordinator Acceptance  #
      #############################################################################################################################
         my $textName = $section . 'text';
         my ($text, $status) = $dbh->selectrow_array ("select coordeditedtext, status from $schema.response_version where $relateResponseVersion");
         my $statusText = '<b>Status:' . &nbspaces(3);
         my $coordinator = &getCoordinator();
         $coordinator = '<b>Bin Coordinator:' . &nbspaces(2) . "<a href=javascript:display_user($coordinator)>" . &get_fullname($dbh, $schema, $coordinator) . '</a></b>';
         $status -= 0;
         if (($status < 6) || ($status == 10)) {
            $statusText .= 'ERROR: INVALID STATE';
         } elsif ($status == 6) {
            $statusText .= 'AWAITING ACCEPTANCE';
            $statusText .= ' - NO TEXT HAS BEEN ENTERED' if ($text eq "");
         } elsif ($status == 11) {
            $statusText .= 'REJECTED';
         } else {
            $statusText .= 'ACCEPTED';
            $statusText .= ' WITHOUT MODIFICATION' if ($text eq "");
         }
         $statusText .= '</b>';
         $output .= &writeTextBox(name => $textName, text => $text, left => $coordinator, right => $statusText, readOnly => 'true', drawBoxIfTextNull => 0);
      #############################################################################################################################
      } elsif ($section eq 'edit') {                                                                                #  Tech Edit  #
      #############################################################################################################################
         my $textName = $section . 'text';
         $focus = $textName;
         $responseText{active} = $textName;
         $responseText{previous} = "prevText";
         my $redlineTextName = "redlineText";
         my $text = &getText(name => $textName, query => "select techeditedtext from $schema.response_version where $relateResponseVersion");
         my $save = &writeControl(label => 'Save Response', callback => "saveResponse()");
         my $copy = &writeControl(label => 'Copy', callback => 'copyText()');
         my $submit = &writeControl(label => 'Submit', callback => "processResponse('$command')", useLinks => 0);
         my ($prevText) = $dbh->selectrow_array ("select lastsubmittedtext from $schema.response_version where $relateResponseVersion");
         my $responseOutput = "<tr><td><table border=0 cellpadding=0 cellspacing=0>";
         $responseOutput .= &writeTextBox(name => $responseText{previous}, cols => 83, text => $prevText, left => '<b>Current Response:</b>', right => "<b>$copy the 'Current Response' to the 'Edited Response' box</b>", align => 'align=right', readOnly => "true");
         $responseOutput .= &writeTextBox(name => $responseText{active}, cols => 83, text => $text, left => "<b>Edited Response:</b>", right => $save, align => "height=135 valign=bottom align=right");
         $responseOutput .= "</table></td></tr>";
         # value property of file upload filed is read-only, so can't set it after a form submit (e.g. arrow press or remarks submit)
         $responseOutput .= "<tr><td><b>Attach redline/strikeout edits file (optional):" . &nbspaces(2) . "<input type=file name=$redlineTextName>" . &nbspaces(3) . "<font color=#ff0000>(In development)</font>" . "</b></td></tr>";
         tie my %buttons, "Tie::IxHash";
         $enableAllFunction = "setEnabled('all')";
         my $onClick = "setEnabled($form.radioBox)";
         %buttons = (
            'noedits' => {label => 'The response requires no edits'},
            'respond' => {label => 'The response requires the following edits:', content => $responseOutput}
         );
         $output .= "<tr><td><table width=100% border=0>\n";
         $output .= &writeRadioBox(buttons => \%buttons, default => 'noedits', onClick => $onClick);
         $output .= "<tr><td align=center height=40>$submit</td></tr>\n";
         $output .= "<script language=javascript><!--\n";
         $output .= "function validateRespondInput(processStep) {\n";
         $output .= "   var msg = \"\";\n";
         $output .= "   if (isblank($form.$responseText{active}.value)) {\n";
         $output .= "      msg = \"Response text is required but none has been entered.\";\n";
         $output .= "   }\n";
         $output .= "   return (msg);\n";
         $output .= "}\n";
         $output .= "function processResponse(processStep) {\n";
         $output .= "   var msg = \"\";\n";
         $output .= "   if ($form.radioBox\[1\].checked) {\n";
         $output .= "      msg = validateRespondInput(processStep);\n";
         $output .= "   }\n";
         $output .= "   if (msg != \"\") {\n";
         $output .= "      alert(msg);\n";
         $output .= "   } else {\n";
         $output .= "      $form.target = 'cgiresults';\n";
         $output .= "      $form.process.value = processStep;\n";
         $output .= "      submitForm('responses', processStep);\n";
         $output .= "   }\n";
         $output .= "}\n";
         $output .= "function setEnabled(object) {\n";
         $output .= "   disabled = (object == 'all') ? false : eval(!object[1].checked);\n";
         $output .= "   $form.$responseText{active}.disabled = disabled;\n";
         $output .= "   $form.$redlineTextName.disabled = disabled;\n";
         $output .= "}\n";
         $output .= "$onClick;\n";
         $output .= "//-->\n";
         $output .= "</script>\n";
         $output .= "</table></td></tr>\n";
      #############################################################################################################################
      } elsif (($section eq 'browseedit') && (&sectionIsOpen($section))) {                                   #  Browse Tech Edit  #
      #############################################################################################################################
         my $textName = $section . 'text';
         my ($text, $redlineText, $editor, $status) = $dbh->selectrow_array ("select techeditedtext, redlinedtext, techeditor, status from $schema.response_version where $relateResponseVersion");
         if (!defined($editor)) {
            if ($status == 5) {
               $output .= '<tr><td><b>The response is awaiting Technical Edit.</b></td></tr>';
            } else {
               $output .= '<tr><td><b>The response was not selected for Technical Edit.</b></td></tr>';
            }
         }
         else {
            my $statusText = '<b>Status:' . &nbspaces(3);
            $editor = '<b>Tech Editor:' . &nbspaces(2) . "<a href=javascript:display_user($editor)>" . &get_fullname($dbh, $schema, $editor) . '</a></b>';
            if ($status == 5) {
               $statusText .= 'IN DEVELOPMENT';
               $statusText .= ' - NO TEXT HAS BEEN ENTERED' if (($status == 5) && ($text eq ""));
            } else {
               $statusText .= 'DONE';
               $statusText .= ' - NO EDITS WERE ENTERED' if ($text eq "");
            }
            $statusText .= '</b>';
            $output .= &writeTextBox(name => $textName, text => $text, left => $editor, right => $statusText, readOnly => 'true', drawBoxIfTextNull => 0);
         }
#
#  need to check existence of file on webserver, download from database if not there, invoke display_image script
#
#         if (defined($redlineText) && ($redlineText ne "")) {
#            $output .= "<tr><td height=50><b><a href=/>View redline/strikeout version the technical edits</a></td></tr>";
#         } else {
#            $output .= "<tr><td><b>Redline/strikeout version is not available.</a></td></tr>";
#         }
      #############################################################################################################################
      } elsif ($section eq 'modify') {                                                                        #  Modify Response  #
      #############################################################################################################################
         my $binid = &getBinID(document => $documentid, comment =>$commentid);
         my $textName = $section . 'text';
         $focus = $textName;
         $responseText{active} = $textName;
         $responseText{previous} = "prevText";
         my $text = &getText(name => $textName, query => "select reviewedtext from $schema.response_version where $relateResponseVersion");
         my $save = &writeControl(label => 'Save Response', callback => "saveResponse()");
         my $copy = &writeControl(label => 'Copy', callback => "copyText()");
         my ($prevText) = $dbh->selectrow_array ("select lastsubmittedtext from $schema.response_version where $relateResponseVersion");
         my $responseOutput = "<tr><td><table border=0 cellpadding=0 cellspacing=0>";
         $responseOutput .= &writeTextBox(name => $responseText{previous}, cols => 83, text => $prevText, left => '<b>Current Response:</b>', right => "<b>$copy the 'Current Response' to the 'Modify Response' box</b>", align => 'align=right', readOnly => "true");
         $responseOutput .= &writeTextBox(name => $responseText{active}, cols => 83, text => $text, left => "<b>Modify Response:</b>", right => $save, align => "height=135 valign=bottom align=right");
         $responseOutput .= "</table></td></tr>";
         $responseOutput .= "<tr>" . &writeDOEReviewer(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid) . '</tr>';
         $responseOutput .= "<tr>" . &writeHasCommitments(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid) . '</tr>';
         $responseOutput .= "<tr>" . &writeChangeImpact(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid) . '</tr>';
         my $submit = &writeControl(label => 'Submit', callback => "processResponse('$command')", useLinks => 0);
         $output .= "<tr><td><table width=100% border=0>\n";
         $output .= &writeResponseRadioBox(responseSection => $responseOutput, height => 35, command => $command);
         $output .= "<tr><td align=center height=40>$submit</td></tr>\n";
         $output .= &writeDevelopResponse();
         $output .= "</table></td></tr>\n";
      #############################################################################################################################
      } elsif (($section eq 'browsemodify') && (&sectionIsOpen($section))) {                           #  Browse Modify Response  #
      #############################################################################################################################
         my $textName = $section . 'text';
         my ($writer) = &selectResponseWriter(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, version => $version);
         my ($text, $status, $summary, $dupsimstatus, $dupdocument, $dupcomment) = $dbh->selectrow_array ("select reviewedtext, status, summary, dupsimstatus, dupsimdocumentid, dupsimcommentid from $schema.response_version where $relateResponseVersion");
         my $summaryID = &formatID('SCR', 4, $summary);
         my $dupID = &formatID($CRDType, 6, $dupdocument) . " / " . &formatID("", 4, $dupcomment);
         if (($text eq "") && ($status > 4)) {
            $output .= '<tr><td><b>No response modification was required.</b></td></tr>';
         } else {
            my $statusText = '<b>Status:' . &nbspaces(3);
            $writer = '<b>Response Writer:' . &nbspaces(2) . "<a href=javascript:display_user($writer)>" . &get_fullname($dbh, $schema, $writer) . '</a></b>';
            if ($status == 4) {
               $statusText .= 'IN DEVELOPMENT';
               $statusText .= ' - NO TEXT HAS BEEN ENTERED' if ($text eq "");
            } else {
               $statusText .= 'DONE';
               if (defined($summary)) {
                  $statusText .= " - SUMMARIZE WITH $summaryID";
               } elsif ($dupsimstatus == 2) {
                  $statusText .= " - DUPLICATE OF $dupID";
               }
            }
            $statusText .= '</b>';
            $output .= &writeTextBox(name => $textName, text => $text, left => $writer, right => $statusText, readOnly => 'true', drawBoxIfTextNull => 0);
         }
      #############################################################################################################################
      } elsif ($section eq 'review') {                                                                       #  Technical Review  #
      #############################################################################################################################
         tie my %buttons, "Tie::IxHash";
         %buttons = (
            'approve' => {label => 'Response is acceptable in its current form'},
            'modify'  => {label => 'Response is acceptable with modifications noted below'},
            'reject'  => {label => 'Response requires modifications noted below and re-review'}
         );
         my $textName = $section . 'text';
         $focus = $textName;
         my $text = &getText(name => $textName, query => "select text from $schema.technical_review where $relateResponseVersion and reviewer = $userid");
         my $save = &writeControl(label => 'Save Review', callback => "saveReview()");
         my $assign = &writeControl(label => 'Submit', callback => "processReview()", useLinks => 0);
         $output .= "<tr><td align=right><table width=100% border=0>\n";
         $output .= &writeRadioBox(buttons => \%buttons, default => 'approve');
         $output .= &writeTextBox(name => $textName, cols => 86, text => $text, left => $save, align => 'height=135 valign=bottom align=right');
         $output .= "<tr><td align=center height=40>$assign</td></tr></table></td></tr>\n";
      #############################################################################################################################
      } elsif (($section eq 'browsereview') && (&sectionIsOpen($section))) {                          #  Browse Technical Review  #
      #############################################################################################################################
         my ($responseStatus) = $dbh->selectrow_array ("select status from $schema.response_version where $relateResponseVersion");
         if (($command eq 'browse') && ($responseStatus == 2)) {
            my @reviewers = selectTechReviewers(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid);
            my $count = 0;
            foreach my $reviewer (@reviewers) {
               $count++;
               if ($count == 1) {
                  $output .= "<tr><td><table border=0 cellpadding=5 cellspacing=5 width=100%><ul><tr>\n";
               } elsif (($count % 4) == 1) {
                  $output .= "</tr><tr>\n";
               }
               $output .= "<td width=25%><li><b><a href=javascript:display_user($reviewer)>" . &get_fullname($dbh, $schema, $reviewer) . "</a></b></td>";
            }
            if ($count == 0) {
               $output .= "<tr><td><b>The response has not been selected for Technical Review.</b></td></tr>";
            } else {
               while (++$count <= 4) {
                  $output .= "<td width=25%> </td>";
               }
               $output .= "</tr></ul></table></td></tr>\n";
            }
         } else {
            my %statusTypes = %{&getLookupValues(dbh => $dbh, schema => $schema, table => 'technical_review_status')};
            my $csr = $dbh->prepare("select reviewer, text, status from $schema.technical_review where $relateResponseVersion");
            $csr->execute;
            my $count = 0;
            while (my @values = $csr->fetchrow_array) {
               $count++;
               my ($reviewer, $text, $status) = @values;
               my $textName = 'browseTechReviewText';
               if (($command ne 'review') || ($reviewer != $userid)) {
                  my $reviewer = '<b>Technical Reviewer:' . &nbspaces(2) . "<a href=javascript:display_user($reviewer)>" . &get_fullname($dbh, $schema, $reviewer) . '</a></b>';
                  my $statusText = '<b>Status:' . &nbspaces(3) . "$statusTypes{$status}";
                  $statusText .= ' - NO TEXT HAS BEEN ENTERED' if (($status == 1) && ($text eq ""));
                  $statusText .= '</b>';
                  $output .= &writeTextBox(name => $textName, text => $text, left => $reviewer, right => $statusText, readOnly => 'true', drawBoxIfTextNull => 0);
               }
            }
            $csr->finish;
            $output .= '<tr><td><b>The response was not selected for Technical Review.</b></td></tr>' if ($count == 0);
         }
      #############################################################################################################################
      } elsif ($section eq 'write') {                                                                          #  Write Response  #
      #############################################################################################################################
         my $binid = &getBinID(document => $documentid, comment => $commentid);
         my $textName = $section . 'text';
         $focus = $textName;
         $responseText{active} = $textName;
         my ($copy, $responseOutput, $writePrevText) = ("", "", 0);
         if ($version > 1) {
            my $prevVersion = $version - 1;
            my ($prevText) = $dbh->selectrow_array ("select lastsubmittedtext from $schema.response_version where $relateComment and version = $prevVersion");
            if (defined($prevText) && ($prevText ne "")) {
               $copy = &writeControl(label => 'Copy', callback => "copyText()");
               $responseText{previous} = 'prevText';
               $writePrevText = 1;
               $responseOutput .= "<tr><td><table border=0 cellpadding=0 cellspacing=0>";
               $responseOutput .= &writeTextBox(name => $responseText{previous}, text => $prevText, cols => 83, left => "<b>Final Response Text (Version $prevVersion):</b>", right => "<b>$copy the 'Final Response Text' to the 'Enter Response' box</b>", readOnly => "true");
            }
         }
         my $text = &getText(name => $textName, query => "select originaltext from $schema.response_version where $relateResponseVersion");
         my $save = &writeControl(label => 'Save Response', callback => "saveResponse()");
         my $left = ($version > 1) ? "<b>Enter Response (Version $version):</b>" : "<b>Enter Response:</b>";
         my $align = ($writePrevText) ? "height=135 valign=bottom align=right" : "";
         $responseOutput .= &writeTextBox(name => $textName, text => $text, cols => 83, left => $left, right => $save, align => $align);
         if (&requireResponseSource()) {
            my $sourceText = ($useFormValues && defined($crdcgi->param($responseSourceName))) ? $crdcgi->param($responseSourceName) : "";
            $responseOutput .= &writeTextBox(name => $responseSourceName, text => $sourceText, cols => 83, left => "<b>Enter Response Source:</b>", right => "", align => $align);
         }
         $responseOutput .= "</table></td></tr>" if ($writePrevText);
         $responseOutput .= "<tr>" . &writeDOEReviewer(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid) . '</tr>';
         $responseOutput .= "<tr>" . &writeHasCommitments(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid) . '</tr>';
         $responseOutput .= "<tr>" . &writeChangeImpact(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid) . '</tr>';
         my $submit = &writeControl(label => 'Submit', callback => "processResponse('$command')", useLinks => 0);
         $output .= "<tr><td><table width=100% border=0>\n";
         $output .= &writeResponseRadioBox(responseSection => $responseOutput, height => 35, command => $command);
         $output .= "<tr><td align=center height=40>$submit</td></tr>\n";
         $output .= &writeDevelopResponse();
         $output .= "</table></td></tr>\n";
      #############################################################################################################################
      } elsif (($section eq 'browsewrite') && (&sectionIsOpen($section))) {                             #  Browse Write Response  #
      #############################################################################################################################
         my $textName = $section . 'text';
         my ($writer) = &selectResponseWriter(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, version => $version);
         my ($text, $status, $summary, $dupsimstatus, $dupdocument, $dupcomment) = $dbh->selectrow_array ("select originaltext, status, summary, dupsimstatus, dupsimdocumentid, dupsimcommentid from $schema.response_version where $relateResponseVersion");
         my $summaryID = &formatID('SCR', 4, $summary);
         my $dupID = &formatID($CRDType, 6, $dupdocument) . " / " . &formatID("", 4, $dupcomment);
         if (($text eq "") && ($status > 2)) {
            $output .= "<tr><td><b>No response entered - marked ";
            if (defined($summary)) {
               $output .= "summarized (pending) by $summaryID";
            } elsif ($dupsimstatus == 2) {
               $output .= "duplicate of $dupID";
            }
            $output .= '.</b></td></tr>';
         } else {
            my $statusText = '<b>Status:' . &nbspaces(3);
            $writer = '<b>Response Writer:' . &nbspaces(2) . "<a href=javascript:display_user($writer)>" . &get_fullname($dbh, $schema, $writer) . '</a></b>';
            if ($status > 2) {
               $statusText .= 'DONE';
               if (defined($summary)) {
                  $statusText .= " - SUMMARIZE WITH $summaryID";
               } elsif ($dupsimstatus == 2) {
                  $statusText .= " - DUPLICATE OF $dupID";
               }
            } else {
               $statusText .= "IN DEVELOPMENT";
               $statusText .= " - NO TEXT HAS BEEN ENTERED" if ($text eq "");
            }
            $statusText .= '</b>';
            $output .= &writeTextBox(name => $textName, text => $text, left => $writer, right => $statusText, readOnly => 'true', drawBoxIfTextNull => 0);
         }
      #############################################################################################################################
      } elsif ($section eq 'assign') {                                                        #  Bin Coordinator Assign Response  #
      #############################################################################################################################
         my $binid = &getBinID(document => $documentid, comment => $commentid);
         tie my %writers, "Tie::IxHash";
         %writers = %{&getBinWritersAndReviewers(dbh => $dbh, schema => $schema, bin => $binid)};
         my $responseOutput = '<tr>' . &writeResponseWriter(writers => \%writers, dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, version => $version) . &nbspaces(10);
         $responseOutput .= &writeDateDue(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid) . '</tr>';
         $responseOutput .= '<tr>' . &writeTechReviewers(reviewers => \%writers, dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid) . '</tr>';
         $responseOutput .= '<tr>' . &writeDOEReviewer(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid) . '</tr>';
         $responseOutput .= '<tr>' . &writeHasCommitments(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid) . '</tr>';
         $responseOutput .= '<tr>' . &writeChangeImpact(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid) . '</tr>';
         my $submit = &writeControl(label => 'Submit', callback => "processAssign()", useLinks => 0);
         $output .= "<tr><td><table width=100% border=0>\n";
         $output .= &writeResponseRadioBox(responseSection => $responseOutput, height => 35, command => $command);
         $output .= "<tr><td align=center height=40>$submit</td></tr>\n";
         $output .= "<script language=javascript><!--\n";
         $output .= "function processAssign() {\n";
         $output .= "   var msg = \"\";\n";
         $output .= "   if ($form.radioBox\[0\].checked) {\n";
         $output .= "      msg = validateDuplicateInput();\n";
         $output .= "   } else if ($form.radioBox\[1\].checked) {\n";
         $output .= "      msg = validateSummarizeInput();\n";
         $output .= "   } else if ($form.radioBox\[2\].checked) {\n";
         $output .= "      msg = checkChangeControl() + checkDateDue();\n";
         $output .= "   }\n";
         $output .= "   if (msg != \"\") {\n";
         $output .= "      alert(msg);\n";
         $output .= "   } else {\n";
         $output .= "      $form.target = 'cgiresults';\n";
         $output .= "      $form.process.value = '$command';\n";
#         $output .= "      $form.bookmark.value = '$bookmark';\n" if ($bookmark);
         $output .= "      submitForm('responses', '$command');\n";
         $output .= "   }\n";
         $output .= "}\n";
         $output .= "//-->\n";
         $output .= "</script>\n";
         $output .= "</table></td></tr>\n";
      #############################################################################################################################
      } elsif ($section eq 'proofread') {                                                          #  Proofread Entered Response  #
      #############################################################################################################################
         my $textName = $section . 'text';
         my $text = &getText(name => $textName, query => "select text from $schema.response_version_entry where $relateResponseVersion");
         my ($writer) = &selectResponseWriter(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, version => $version);
         $writer = '<b>Assigned response writer:' . &nbspaces(2) . "<a href=javascript:display_user($writer)>" . &get_fullname($dbh, $schema, $writer) . '</a></b>';
         my ($entry, $date) = $dbh->selectrow_array("select enteredby, to_char(entrydate, '$dateFormat') from $schema.response_version_entry where $relateResponseVersion");
         $entry = '<b>Entered by:' . &nbspaces(2) . "<a href=javascript:display_user($entry)>" . &get_fullname($dbh, $schema, $entry) . '</a>' . &nbspaces(2) . 'on' . &nbspaces(2) . $date . '</b>';
         $output .= &writeTextBox(name => $textName, text => $text, left => $writer, right => $entry);
         my $submit = &writeControl(label => 'Response Text Verified', callback => "submitProofread()", useLinks => 0);
         $output .= "<tr><td align=center>$submit</td></tr>\n";
         $output .= "<script language=javascript><!--\n";
         $output .= "function submitProofread () {\n";
         $output .= "   if (isblank($form.$textName.value)) {\n";
         $output .= "      alert(\"No text has been entered in the text field.\");\n";
         $output .= "   } else {\n";
         $output .= "      $form.target = 'cgiresults';\n";
         $output .= "      $form.process.value = 'proofreadResponse';\n";
         $output .= "      submitForm('responses', '$command');\n";
         $output .= "   }\n";
         $output .= "}\n";
         $output .= "//-->\n";
         $output .= "</script>\n";
      #############################################################################################################################
      } elsif ($section eq 'enter') {                                                                          #  Enter Response  #
      #############################################################################################################################
         my $textName = $section . 'text';
         my $text = &getText(name => $textName, query => "");
         my ($writer) = &selectResponseWriter(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, version => $version);
         $writer = '<b>On behalf of assigned response writer:' . &nbspaces(2) . "<a href=javascript:display_user($writer)>" . &get_fullname($dbh, $schema, $writer) . '</a></b>';
         my $submit = &writeControl(label => 'Submit Response', callback => "submitEnter()", useLinks => 0);
         $output .= &writeTextBox(name => $textName, text => $text, left => $writer);
         $output .= "<tr><td align=center>$submit</td></tr>\n";
         $output .= "<script language=javascript><!--\n";
         $output .= "function submitEnter () {\n";
         $output .= "   if (isblank($form.$textName.value)) {\n";
         $output .= "      alert(\"No text has been entered in the text field.\");\n";
         $output .= "   } else {\n";
         $output .= "      $form.target = 'cgiresults';\n";
         $output .= "      $form.process.value = 'enterResponse';\n";
         $output .= "      submitForm('responses', '$command');\n";
         $output .= "   }\n";
         $output .= "}\n";
         $output .= "//-->\n";
         $output .= "</script>\n";
      }
   };
   &processError(activity => "display response $section section") if ($@);
   $output .= "</table>\n";
   $output .= "</td></tr>\n";
   $output .= "<tr><td height=30> </td></tr>\n" if (&sectionIsOpen($section));
}

###################################################################################################################################
sub writeHTTPHeader {                                                                                                             #
###################################################################################################################################
   print $crdcgi->header('text/html');
}

###################################################################################################################################
sub writeHead {                                                                                                                   #
###################################################################################################################################
   print <<end;
<html>
<head>
   <meta http-equiv=expires content=now>
   <script src=$CRDJavaScriptPath/utilities.js></script>
   <script src=$CRDJavaScriptPath/widgets.js></script>
   <script language=javascript><!--
      function display_user(userid) {
         dummy.id.value = userid;
         dummy.command.value = 'displayuser';
         dummy.action = '$path' + 'user_functions' + '.pl';
         dummy.target= 'main';
         dummy.submit();
      }
      function display_image(documentid, commentid) {
         dummy.documentid.value = documentid;
         dummy.commentid.value = commentid;
         dummy.command.value = 'pdf';
         dummy.action = '$path' + 'display_image' + '.pl';
         dummy.target= 'cgiresults';
         dummy.submit();
      }
      function display_bin(binid) {
         dummy.binid.value = binid;
         dummy.command.value = 'browse';
         dummy.action = '$path' + 'bins' + '.pl';
         dummy.target= 'main';
         dummy.submit();
      }
      function display_document(documentid) {
         dummy.id.value = documentid;
         dummy.command.value = 'browse2';
         dummy.action = '$path' + 'comment_documents' + '.pl';
         dummy.target= 'main';
         dummy.submit();
      }
      function display_comments(documentid, commentid) {
         dummy.id.value = documentid;
         dummy.commentid.value = commentid;
         dummy.command.value = 'browse';
         dummy.action = '$path' + 'comments' + '.pl';
         dummy.target= 'main';
         dummy.submit();
      }
      function display_response (documentid, commentid, version) {
         dummy.id.value = documentid;
         dummy.commentid.value =  commentid;
         dummy.version.value = version;
         dummy.command.value = 'browse';
         dummy.action = '$path' + 'responses' + '.pl';
         dummy.target= 'main';
         dummy.submit();
      }
      function display_summary_comment(id) {
         dummy.summarycommentid.value = id;
         dummy.command.value = 'browseSummaryComment';
         dummy.action = '$path' + 'summary_comments' + '.pl';
         dummy.target= 'main';
         dummy.submit();
      }
      function display_commentor(id) {
         dummy.id.value = id;
         dummy.command.value = 'display';
         dummy.action = '$path' + 'commentors' + '.pl';
         dummy.target= 'main';
         dummy.submit();
      }
      function update_response_status () {
         $form.process.value = 'update_status';
         $form.command.value = 'update_status';
         $form.action = '$path' + 'responses' + '.pl';
         $form.target= 'main';
         $form.submit();
      }
      function update_approved_response(documentid, commentid) {
         dummy.id.value = documentid;
         dummy.commentid.value = commentid;
         dummy.command.value = 'update_approved';
         dummy.action = '$path' + 'responses' + '.pl';
         dummy.target= 'main';
         dummy.submit();
      }
      function process_update_approved_response(documentid, commentid, version) {
         if (isblank($form.approvedResponse.value)) {
            alert("No text has been entered in the approved response field.");
         }
         else {
            $form.id.value = documentid;
            $form.commentid.value = commentid;
            $form.version.value = version;
            $form.command.value = '$whichApprovedUpdateEntryType';
            $form.process.value = 'update_approved';
            $form.action = '$path' + 'responses' + '.pl';
            $form.target= 'cgiresults';
            $form.submit();
         }
      }
      function saveFilter(command) {
         $form.process.value = 'saveFilter';
         $form.command.value = command;
         $form.target = 'cgiresults';
         $form.action = '$path' + 'responses' + '.pl';
         $form.submit();
      }
      function browse_response () {
         if ((isNaN($form.responsebrowsecid.value - 0) || ($form.responsebrowsecid.value <= 0) || ($form.responsebrowsecid.value > 9999))) {
            alert('Invalid Comment ID');
         }
         else if ((isNaN($form.responsebrowsecdid.value - 0) || ($form.responsebrowsecdid.value <= 0) || ($form.responsebrowsecdid.value > 999999))) {
            alert('Invalid Comment Document ID');
         }
         else {
            $form.id.value = $form.responsebrowsecdid.value;
            $form.commentid.value = $form.responsebrowsecid.value;
            $form.version.value = 0;
            $form.command.value = 'browse';
            $form.action = '$path' + 'responses' + '.pl';
            $form.target = 'cgiresults';
            $form.process.value = 'browse';
            $form.submit();
         }
      }
      function update_approved_response_entered_ID () {
         if ((isNaN($form.updateresponsecid.value - 0) || ($form.updateresponsecid.value <= 0) || ($form.updateresponsecid.value > 9999))) {
            alert('Invalid Comment ID');
         }
         else if ((isNaN($form.updateresponsecdid.value - 0) || ($form.updateresponsecdid.value <= 0) || ($form.updateresponsecdid.value > 999999))) {
            alert('Invalid Comment Document ID');
         }
         else {
            $form.id.value = $form.updateresponsecdid.value;
            $form.commentid.value = $form.updateresponsecid.value;
            $form.version.value = 0;
            $form.command.value = 'update_approved';
            $form.action = '$path' + 'responses' + '.pl';
            $form.target = 'cgiresults';
            $form.process.value = 'validateIDforUpdateApproved';
            $form.submit();
         }
      }
      function do_workflow_step_entered_ID () {
         if ((isNaN($form.workflowstepresponsecid.value - 0) || ($form.workflowstepresponsecid.value <= 0) || ($form.workflowstepresponsecid.value > 9999))) {
            alert('Invalid Comment ID');
         }
         else if ((isNaN($form.workflowstepresponsecdid.value - 0) || ($form.workflowstepresponsecdid.value <= 0) || ($form.workflowstepresponsecdid.value > 999999))) {
            alert('Invalid Comment Document ID');
         }
         else {
            $form.id.value = $form.workflowstepresponsecdid.value;
            $form.commentid.value = $form.workflowstepresponsecid.value;
            $form.version.value = 0;
            $form.proxy.value = 1;
            $form.action = '$path' + 'responses' + '.pl';
            $form.target = 'cgiresults';
            $form.process.value = 'validateIDforDoWorkflowStep';
            $form.command.value = 'validateIDforDoWorkflowStep';  // gets rewritten if valid status
            $form.submit();
         }
      }
      function update_response_writer_entered_ID () {
         if ((isNaN($form.updateresponsewritercid.value - 0) || ($form.updateresponsewritercid.value <= 0) || ($form.updateresponsewritercid.value > 9999))) {
            alert('Invalid Comment ID');
         }
         else if ((isNaN($form.updateresponsewritercdid.value - 0) || ($form.updateresponsewritercdid.value <= 0) || ($form.updateresponsewritercdid.value > 999999))) {
            alert('Invalid Comment Document ID');
         }
         else {
            $form.id.value = $form.updateresponsewritercdid.value;
            $form.commentid.value = $form.updateresponsewritercid.value;
            $form.version.value = 0;
            $form.action = '$path' + 'responses' + '.pl';
            $form.target = 'cgiresults';
            $form.process.value = 'validateIDforUpdateResponseWriter';
            $form.command.value = 'update_response_writer';
            $form.submit();
         }
      }
      function do_workflow_step(command, id, commentid, version) {
         $form.id.value = id;
         $form.commentid.value = commentid;
         $form.version.value = version;
         $form.target = 'main';
         $form.process.value = 0;
         $form.command.value = command;
         $form.action = '$path' + 'responses' + '.pl';
         $form.submit();
      }
      function update_response_writer(documentid, commentid) {
         $form.id.value = documentid;
         $form.commentid.value = commentid;
         $form.target = 'cgiresults';
         $form.process.value = 'update_response_writer';
         $form.action = '$path' + 'responses' + '.pl';
         $form.submit();
      }
      function enterConcur(documentid, commentid, concurType) {
         if (($form.concurs\[1\].checked) && ($form.remarks.value == "")) {
            alert ('A remark must be entered with a negative concurrence');
         } else {
            $form.id.value = documentid;
            $form.commentid.value = commentid;
            $form.concurtype.value = concurType;
            $form.process.value = 'concur';
            $form.command.value = 'concur';
            $form.target = 'cgiresults';
            $form.action = '$path' + 'responses' + '.pl';
            $form.submit();
         }
      }
      function onLoad(section) {
         if (section != '') {
            window.location.href += ('#' + section);
         }
end
#   if ($focus) {
#      print "         $form.$focus.focus();\n";
#   }
   print <<end;
      }
      function submitForm(script, command) {
         $form.action = '$path' + script + '.pl';
         $form.command.value = command;
         $form.submit();
      }
      function saveRemark() {
         if (isblank($form.remarktext.value)) {
            alert("No text has been entered in the remarks field.");
         }
         else {
            $form.target = 'cgiresults';
            $form.process.value = 'saveRemark';
            $form.bookmark.value = 'remarks';
            $enableAllFunction;
            submitForm('responses', '$command');
         }
      }
      function processReview() {
         if (isblank($form.reviewtext.value) && !$form.radioBox[0].checked) {
            alert("Review text is required with the selected option but no text has been entered.");
         }
         else if (!isblank($form.reviewtext.value) && $form.radioBox[0].checked) {
            alert("Review text cannot be submitted with the selected option.");
         }
         else {
            $form.target = 'cgiresults';
            $form.process.value = '$command';
            submitForm('responses', '$command');
         }
      }
      function summary_comment(command, bin, documentID, commentID, responseVersion, caller) {
         dummy.action = '$path' + 'summary_comments' + '.pl';
         dummy.command.value = command;
         dummy.binid.value = bin;
         dummy.documentid.value = documentID;
         dummy.commentid.value = commentID;
         dummy.version.value = responseVersion;
         dummy.caller.value = caller;
         dummy.submit();
      }
      function saveReview () {
         $form.target = 'cgiresults';
         $form.process.value = 'saveReview';
         $form.bookmark.value = '$command';
         submitForm('responses', '$command');
      }
end
   my $isDisabledText = "The edit response section is currently disabled\\n\\nChange the radio button setting to enable it";
   if (defined($responseText{active})) {
      print <<end;
      function saveResponse () {
         if ($form.$responseText{active}.disabled) {
            alert ("$isDisabledText");
         } else {
            $form.target = 'cgiresults';
            $form.process.value = 'saveResponse';
            $form.bookmark.value = '$command';
            submitForm('responses', '$command');
         }
      }
end
   }
   if (defined($responseText{active}) && defined($responseText{previous})) {
      print <<end;
      function copyText() {
         var process = 1;
         if ($form.$responseText{active}.disabled) {
            alert ("$isDisabledText");
         } else {
            if ($form.$responseText{active}.value == $form.$responseText{previous}.value) {
               alert('The two text values are identical.');
            } else {
               if (!isblank($form.$responseText{active}.value)) {
                  process = confirm('Warning: this will overwrite your changes!  Proceed?');
               }
               if (process) {
                  $form.$responseText{active}.value = $form.$responseText{previous}.value;
               }
            }
         }
      }
end
   }
   print "   //-->\n";
   print "   </script>\n";
   print &sectionHeadTags($form, $enableAllFunction);
   print "</head>\n\n";
}

###################################################################################################################################
sub writeBody {                                                                                                                   #
###################################################################################################################################
   print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0 onLoad=javascript:onLoad('$bookmark')>\n<center>\n";
   my $title;
   if ($command eq 'update_status') {
      $title = 'Update Response Status';
   } elsif (($command eq 'select_update_approved_table') || ($command eq 'select_update_approved_enter_ID') || ($command eq 'update_approved')) {
      $title = 'Update Approved Response';
   } elsif (($command eq 'do_workflow_step_enter_ID') || ($command eq 'do_workflow_step')) {
      $title = 'Do Response Workflow Step';
   } elsif (($command eq 'update_response_writer_enter_ID') || ($command eq 'update_response_writer')) {
      $title = 'Update Response Writer';
   } elsif ($command eq 'concur') {
      $title = 'Enter Concurrence';
   } else {
      $title = ${$sections{$command}}{'header'};
   }
   print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $title);
   print "<form name=$form method=post>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=command value=$command>\n";
   print "<input type=hidden name=id value=$documentid>\n";
   print "<input type=hidden name=commentid value=$commentid>\n";
   print "<input type=hidden name=version value=$version>\n";
   print "<input type=hidden name=bookmark value=''>\n";
   print "<input type=hidden name=process value=0>\n";
   print "<input type=hidden name=useFormValues value=1>\n";
   print "<input type=hidden name=proxy value=$isProxy>\n";
   print "<input type=hidden name=updateapprovedentrytype value=$whichApprovedUpdateEntryType>\n";
   print "<input type=hidden name=concurtype value=0>\n";
   print &sectionBodyTags();
   print "<table width=775 cellpadding=0 cellspacing=0 border=0>\n";
   print $output;
   print "</table>\n</form>\n";
   print "<form name=dummy method=post>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=command value=0>\n";
   print "<input type=hidden name=caller value=0>\n";
   print "<input type=hidden name=documentid value=0>\n";
   print "<input type=hidden name=id value=0>\n";
   print "<input type=hidden name=commentid value=0>\n";
   print "<input type=hidden name=summarycommentid value=0>\n";
   print "<input type=hidden name=version value=0>\n";
   print "<input type=hidden name=binid value=0>\n";
   print "<input type=hidden name=updateapprovedentrytype value=$whichApprovedUpdateEntryType>\n";
   print "</form>\n</center>\n</font>\n";
   print &BuildPrintCommentResponse($username, $userid, $schema, $path);
   print "<script language=javascript>\n<!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n" if ($errorstr);
   print "</body>\n</html>\n";
}

###################################################################################################################################
$dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;
if ($process) {
   &processSubmittedData();
} else {
   if ($command eq 'update_status') {
      $output = &displayUpdateStatusTable();
   } elsif ($command eq 'select_update_approved_table') {
      $whichApprovedUpdateEntryType = $command;
      $output = &displayApprovedResponseTable();
   } elsif ($command eq 'select_update_approved_enter_ID') {
      $whichApprovedUpdateEntryType = $command;
      $output = &displayApprovedResponseEnterID();
   } elsif ($command eq 'do_workflow_step_enter_ID') {
      $output = &doWorkflowStepEnterID();
   } elsif ($command eq 'update_response_writer_enter_ID') {
      $output = &updateResponseWriterEnterID();
   } elsif ($command eq 'update_response_writer') {
      $output = &changeResponseWriter();
   } elsif ($command eq 'update_approved') {
      $output = &updateApprovedResponse(document => $documentid, comment => $commentid);
   } elsif ($command eq 'concur') {
      $output = &concurrenceEntry();
   } else {
      &configureSections($command);
      eval {
         &setupSections($dbh, \%sections, $userid, $schema, ${$sections{$command}}{'pageNum'}, $crdcgi->param("arrowPressed"));
      };
      &processError(activity => 'setup response sections') if ($@);
      foreach my $section (keys (%sections)) {
         if (sectionIsActive($section)) {
            doHeader($section);
            doSection($section);
        }
      }
   }
   &writeHTTPHeader();
   &writeHead();
   &writeBody();
}
&db_disconnect($dbh);
exit();
