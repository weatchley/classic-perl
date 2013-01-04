#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/crd/perl/RCS/summary_comments.pl,v $
#
# $Revision: 1.25 $
#
# $Date: 2008/04/01 16:47:41 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: summary_comments.pl,v $
# Revision 1.25  2008/04/01 16:47:41  atchleyb
# CR0053, updates for new workflow to allow the skipping of the proofread step for SCR's
#
# Revision 1.24  2002/02/21 00:34:08  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.23  2001/10/05 22:17:45  mccartym
# SCREQ #00011 - Print report on summary comment and response text
#
# Revision 1.22  2001/10/05 18:46:13  mccartym
# increase maximum title length from 50 to 150
#
# Revision 1.21  2001/08/17 23:38:46  mccartym
# add text box expanders
# code reorganization and rewrites
#
# Revision 1.20  2001/08/14 22:08:09  mccartym
# add sleep to submitRemarks
#
# Revision 1.19  2001/08/04 00:58:10  mccartym
# SCR #1 and #5
#
# Revision 1.18  2001/05/18 01:41:09  mccartym
# checkpoint
#
# Revision 1.17  2000/06/05 22:05:34  mccartym
# new browse, code rewrites, etc.
#
# Revision 1.16  2000/05/19 00:13:56  mccartym
# fix create summary comment problem
#
# Revision 1.15  2000/05/17 23:39:44  mccartym
# remove debug info
#
# Revision 1.14  2000/05/17 22:39:26  mccartym
# Add comments summarized count to browse table
#
# Revision 1.13  2000/05/17 22:27:47  mccartym
# Add tabular browse
#
# Revision 1.12  2000/05/17 18:29:41  mccartym
# enhance browse and update
#
# Revision 1.11  2000/05/16 18:29:47  mccartym
# implement browse summary comment
#
# Revision 1.10  2000/04/13 15:44:24  mccartym
# allow sys admin to update
#
# Revision 1.9  2000/03/24 20:44:56  mccartym
# Add summarize multiple comments function
#
# Revision 1.8  2000/02/10 17:37:13  atchleyb
# removed form-verify.js
#
# Revision 1.7  1999/12/10 18:07:21  mccartym
# minor change to table html tags
#
# Revision 1.6  1999/12/09 19:50:57  mccartym
# add check for bin coordinaor on update summary comment
# remove leading zeros from input summary comment id
#
# Revision 1.5  1999/12/09 02:54:07  fergusoc
# made changes to update function
#
# Revision 1.4  1999/12/08 05:08:04  fergusoc
# update completed
#
# Revision 1.3  1999/11/17 19:23:11  fergusoc
# data entry - enter and proofread done, enter from response done
#
# Revision 1.2  1999/11/04 19:48:32  mccartym
# title change
#
# Revision 1.1  1999/08/02 03:08:10  mccartym
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
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);

$| = 1;
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $crdcgi = new CGI;
my $userid = $crdcgi->param("userid");
my $username = $crdcgi->param("username");
my $schema = $crdcgi->param("schema");
&checkLogin ($username, $userid, $schema);
my $process = $crdcgi->param("process");
my $useFormValues = $crdcgi->param("useFormValues");
my $title;
my $sortBy = (defined($crdcgi->param("sortBy"))) ? $crdcgi->param("sortBy") : "sc.id";
my $sortOrder = (defined($crdcgi->param("sortOrder"))) ? $crdcgi->param("sortOrder") : "ASC";
my $dbh;
my $command = $crdcgi->param("command");
my $error;
my $responseStatus = (defined($crdcgi->param("response_status"))) ? $crdcgi->param("response_status") : 1;  #default to BIN COORDINATOR ASSIGN
my $summaryCommentID = $crdcgi->param("summarycommentid") - 0;
my $formattedID = &formatID('SCR', 4, $summaryCommentID);
my $output = "";
my $instructionsColor = $CRDFontColor;
my $errorstr = "";
my $dateFormat = 'DD-MON-YY HH24:MI:SS';
my $delimiter = "-";
my $descriptionTitle = "Description/Rationale for the Update";
my $nextColor = 0;
my $responseSourceName = "ResponseSource";

###################################################################################################################################
sub writePrintSummaryCommentLink {                                                                                                #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      addTableColumn => 0,
      useIcon => 0,
      icon => "$CRDImagePath/printer.gif",
      linkText => "",
      @_,
   );
   my $out = ($args{addTableColumn}) ? &add_col() . "<center>" : "";
   if ($args{writeHeader}) {
      $out .= "<image src=$CRDImagePath/printer.gif border=0>";
   } else {
      my $formattedid = &formatID("SCR", 4, $args{summary});
      my $prompt = "Click here for $formattedid comment/response text report";
      $out .= "<a href=javascript:submitPrintSummaryCommentResponse($args{summary}) title='$prompt'>";
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
sub addSpace {                                                                                                                    #
###################################################################################################################################
   my %args = (
      height => 15,
      @_,
   );
   my $out = "<tr><td height=$args{height}></td></tr>";
   return ($out);
}

###################################################################################################################################
sub writeTextBox {                                                                                                                #
###################################################################################################################################
   my %args = (
      rows => 4,
      cols => 80,
      readOnly => 0,
      label => "",
      text => "",
      @_,
   );
   my $out = "";
   my $readOnly = ($args{readOnly}) ? "readonly" : "";
   my $expand = "<a href=\"javascript:expandTextBox(document.$form.$args{name},document.$args{name}_button,'force',5);\">\n";
   $expand .= "<img name=$args{name}_button border=0 src=$CRDImagePath/expand_button.gif></a>\n";
   $out .= "<tr><td><table border=0 cellpadding=0 cellspacing=0>\n";
   $out .= "<tr><td align=left valign=bottom><b>$args{label}</b></td><td align=right valign=bottom>$expand</td></tr>\n";
   $out .= "<tr><td colspan=2><textarea name=$args{name} rows=$args{rows} cols=$args{cols} wrap=physical $readOnly ";
   $out .= "onKeyPress=\"expandTextBox(this,document.$args{name}_button,'dynamic');\">$args{text}</textarea></td></tr>\n";
   $out .= "</table></td></tr>\n";
   return ($out);
}

###################################################################################################################################
sub writeGeneralInfoTable {                                                                                                       #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   my $sql = "select title, bin, responsewriter, to_char(dateapproved,'$dateFormat'), createdby, to_char(datecreated,'$dateFormat'), ";
   $sql .= "nvl(proofreadby,0), to_char(proofreaddate,'$dateFormat') from $args{schema}.summary_comment where id = $args{id}";
   my ($title, $bin, $author, $dateApproved, $createdBy, $dateCreated, $proofreadBy, $proofreadDate) = $args{dbh}->selectrow_array ($sql);
   my ($binName) = $args{dbh}->selectrow_array ("select name from $args{schema}.bin where id = $bin");
   my ($changeImpact, $changeControlNum) = &selectChangeImpact(dbh => $args{dbh}, schema => $args{schema}, table => 'summary_comment', summaryID => $args{id});
   my %changeImpactValues = %{&getLookupValues($args{dbh}, $args{schema}, 'document_change_impact')};
   my $hasCommitments = &selectHasCommitments(dbh => $args{dbh}, schema => $args{schema}, table => 'summary_comment', summaryID => $args{id});
   $hasCommitments = ($hasCommitments eq 'T') ? 'Yes' : 'No';
   my $formattedID = &formatID('SCR', 4, $args{id});
   my $printSCRReport = "<font size=2>" . &writePrintSummaryCommentLink(summary => $args{id}, linkText => "Print $formattedID text") . "</font>\n" . &nbspaces(1);
   my $IDAndLink = "<table cellpadding=0 cellspacing=0 border=0 width=100%><tr><td><b>$formattedID</b></td><td align=right><b>$printSCRReport</b></td></tr></table>";
   $out .= "<tr><td><table bgcolor=#ffffff cellpadding=2 cellspacing=1 border=0 width=100%>\n";
   $out .= "<tr bgcolor=" . &nextColor() . "><td width=33%><b>ID:</td><td width=67%>$IDAndLink</td></tr>\n";
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Title:</td><td><b>$title</b></td></tr>\n";
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Bin:</td><td><b><a href=javascript:display_bin($bin)>$binName</b></td></tr>\n";
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Author:</td><td><b><a href=javascript:display_user($author)>";
   $out .= &get_fullname($args{dbh}, $args{schema}, $author) . "</a></b></td></tr>\n";
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Entered By:</td><td><b><a href=javascript:display_user($createdBy)>";
   $out .= &get_fullname($args{dbh}, $args{schema}, $createdBy) . "</a>" . &nbspaces(2) . "on" . &nbspaces(2) . "$dateCreated</b></td></tr>\n";
   if ($proofreadBy) {
      $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Proofread By:</td><td><b><a href=javascript:display_user($proofreadBy)>";
      $out .= &get_fullname($args{dbh}, $args{schema}, $proofreadBy);
      $out .= "</a>" . &nbspaces(2) . "on" . &nbspaces(2) . "$proofreadDate</b></td></tr>\n";
   }
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Change Impact / Control Number:</b></td><td><b>$changeImpactValues{$changeImpact}";
   $out .= &nbspaces(2) . "-" . &nbspaces(2) . "$changeControlNum" if ($changeControlNum);
   $out .= "</b></td></tr>\n";
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Potential DOE Commitment:</b></td><td><b>$hasCommitments</b></td></tr> \n";
   $out .= "<tr bgcolor=" . &nextColor() . "><td><b>Date Bin Coordinator Accepted:</td><td><b>$dateApproved</b></td></tr>\n";
   $out .= "</table></td></tr>\n";
   return ($out);
}

###################################################################################################################################
sub writeCommentAndResponseText {                                                                                                 #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = "";
   my $sql = "select commenttext, responsetext, commenttextapproved, responsetextapproved from $args{schema}.summary_comment where id = $args{id}";
   my ($commentText, $responseText, $commentIsApproved, $responseIsApproved) = $args{dbh}->selectrow_array ($sql);
   my $isApproved = ($commentIsApproved eq 'T') ? "(Approved)" : "(Unapproved)";
   my $label = "<b>Comment Text $isApproved:</b>";
   $out .= &writeTextBox(name => "commentText", label => $label, text => $commentText, readOnly => 1, cols => 90);
   $out .= &addSpace(height => 5);
   $isApproved = ($responseIsApproved eq 'T') ? "(Approved)" : "(Unapproved)";
   $label = "<b>Response Text $isApproved:</b>";
   $out .= &addSpace(height => 5);
   $out .= &writeTextBox(name => "responseText", label => $label, text => $responseText, readOnly => 1, cols => 90);
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
sub delinkCommentFromSummary {                                                                                                    #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $relateComment = "document = $args{documentID} and commentnum = $args{commentID} ";
   my ($version) = $args{dbh}->selectrow_array("select max(version) from $args{schema}.response_version where $relateComment");
   my $relateResponseVersion = "$relateComment and version = $version";
   my ($lastSubmitted) = $args{dbh}->selectrow_array("select lastsubmittedtext from $args{schema}.response_version where $relateResponseVersion");
   my ($dateApproved) = $args{dbh}->selectrow_array("select dateapproved from $args{schema}.summary_comment where id = $args{summary}");
   my $newStatus = 1;
   if ($lastSubmitted) {
      $newStatus = ($dateApproved) ? 7 : 6;
   }
   $args{dbh}->do("update $args{schema}.comments set summary = NULL, summaryapproved = 'F' where $relateComment");
   $args{dbh}->do("update $args{schema}.response_version set status = $newStatus, dateupdated = SYSDATE where $relateResponseVersion");
   if ($newStatus == 1) {
      my $sql = "select b.coordinator from $args{schema}.comments c, $args{schema}.bin b, $args{schema}.response_version r ";
      $sql .= "where c.document = $args{documentID} and c.commentnum = $args{commentID} ";
      $sql .= "and c.document = r.document and c.commentnum = r.commentnum ";
      $sql .= "and r.version = $version and c.bin = b.id";
      my ($coord) = $args{dbh}->selectrow_array("$sql");
      $args{dbh}->do("update $args{schema}.response_version set responsewriter = $coord, techeditor = NULL where $relateResponseVersion")
   }
   my $formattedid = &formatID($CRDType, 6, $args{documentID}) . " / " . &formatID("", 4, $args{commentID});
   my $remark = "unlinked $formattedid";
   &submitRemarks(dbh => $args{dbh}, schema => $args{schema}, summary => $args{summary}, remarker => $userid, remark => $remark);
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
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "";
   if (($args{command} eq "create") || ($args{command} eq "enter_summary_comment")) {
      $title = "Enter Summary Comment";
   } elsif ($args{command} eq "proxy_enter") {
      $title = "Enter Summary Comment Response";
   } elsif ($args{command} eq "proofread_summary_comment") {
      $title = "Proofread Summary Comment";
   } elsif ($args{command} eq "proofread_proxy_enter") {
      $title = "Proofread Summary Comment Response";
   } elsif (($args{command} eq "browse") || ($args{command} eq "browseSummaryComment")) {
      $title = "Browse Summary Comment";
   } elsif (($args{command} eq "update") || ($args{command} eq "updateSummaryComment")) {
      $title = "Update Summary Comment";
   } elsif ($args{command} eq "summarize_multiple") {
      $title = "Summarize Comments";
   } elsif ($args{command} eq "manageApprovals") {
      $title = "Manage Summary Comment Approvals";
   } elsif ($args{command} eq "concur") {
      $title = "Enter Concurrence";
   }
   return ($title);
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
sub writeBrowseSummaryID {                                                                                                        #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "SCR<br>ID",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center><a href=javascript:redraw('sc.id','ASC')>$args{headerText}</a></center>";
   } else {
      my $formattedID = &formatID('', 4, $args{id});
      my $prompt = "Click here to browse summary comment $formattedID";
      $out .= "<center><a href=javascript:displaySummaryComment($args{id}) title='$prompt'>$formattedID</a></center>";
   }
   return ($out);
}

###################################################################################################################################
sub writeSummaryID {                                                                                                              #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "SCR<br>ID",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center><a href=javascript:redraw('sc.id','ASC')>$args{headerText}</a></center>";
   } else {
      my $formattedID = &formatID('', 4, $args{id});
      $out .= "<center>$formattedID</center>";
   }
   return ($out);
}

###################################################################################################################################
sub writeUpdateLink {                                                                                                             #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Update",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $formattedID = &formatID('SCR', 4, $args{id});
      my $prompt = "Click here to update summary comment $formattedID";
      $out .= "<center><a href=javascript:updateSummaryComment($args{id}) title='$prompt'>Update</a></center>";
   }
   return ($out);
}

###################################################################################################################################
sub writeApprovalLink {                                                                                                           #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Manage<br>Approvals",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      if (!$args{canDo}) {
         $out .= "&nbsp";
      } else {
         my $formattedID = &formatID('SCR', 4, $args{id});
         my $prompt = "Click here to manage summary comment $formattedID approvals";
         $out .= "<center><a href=javascript:manageSummaryCommentApprovals($args{id}) title='$prompt'>Approvals</a></center>";
      }
   }
   return ($out);
}

###################################################################################################################################
sub writeAcceptedApproved {                                                                                                       #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Accepted?<br>Approved?",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      $out .= "<center>";
      $out .= ($args{isAccepted}) ? 'Yes' : 'No';
      $out .= " / ";
      $out .= ($args{isApproved}) ? 'Yes' : 'No';
      if ($args{canDo}) {
         my $formattedID = &formatID('SCR', 4, $args{id});
         my $prompt = "Click here to accept summary comment $formattedID";
         $out .= "<br><a href=javascript:acceptSummaryComment($args{id}) title='$prompt'>Accept</a>";
      }
      $out .= "</center>";
   }
   return ($out);
}

###################################################################################################################################
sub writeText {                                                                                                                   #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      center => 0,
      text => "",
      textWidth => 0,
      valign => "",
      @_,
   );
   my $out = "";
   if ($args{valign} eq "top") {
      $out = "<td valign=top><font size=-1><b>";
   } else {
      $out = &add_col();
   }
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      $out .= "<center>" if ($args{center});
      my $length = ($args{textWidth}) ? $args{textWidth} : length ($args{text});
      $out .= &getDisplayString($args{text}, $length);
      $out .= "</center>" if ($args{center});
   }
   if ($args{valign} eq "top") {
      $out .= "</b></font></td>";
   }
   return ($out);
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
      $out .= "<center><a href=javascript:redraw('b.name,sc.id','ASC')>$args{headerText}</a></center>";
   } else {
      my $prompt = "Click here to browse bin $args{binName}";
      $out .= "<center><a href=javascript:display_bin($args{binID}) title='$prompt'>";
      $out .= &getBinNumber(binName => $args{binName});
      $out .= "</a></center>";
   }
   return ($out);
}

###################################################################################################################################
sub writeUser {                                                                                                                    #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      center => 0,
      headerText => "Response<br>Writer",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $displayedUserName = &get_fullname($dbh, $schema, $args{userID});
      my $prompt = "Click here to browse information about $displayedUserName";
      $out .= "<center>" if ($args{center});
      $out .= "<a href=javascript:display_user($args{userID}) title='$prompt'>$displayedUserName</a>";
      $out .= "</center>" if ($args{center});
   }
   return ($out);
}

###################################################################################################################################
sub writeDate {                                                                                                                    #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Last<br>Activity",
      valign => "",
      @_,
   );
   my $out = "";
   if ($args{valign} eq "top") {
      $out = "<td valign=top><font size=-1><b>";
   } else {
      $out = &add_col();
   }
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      $out .= "<center>$args{date}</center>";
   }
   if ($args{valign} eq "top") {
      $out .= "</b></font></td>";
   }
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
      $out .= "<center><a href=javascript:displayComment($args{document},$args{comment}) title='$prompt'>$formattedID</a></center>";
   }
   return ($out);
}

###################################################################################################################################
sub summarizedCommentsTable {                                                                                                     #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $output .= "<tr><td>";
   my ($bin) = $args{dbh}->selectrow_array("select bin from $args{schema}.summary_comment where id = $args{summary}");
   my $sql = "select c.document, c.commentnum, c.text, nvl(c.summary,0), c.summaryapproved from $args{schema}.comments c, $args{schema}.response_version r ";
   $sql .= "where c.document = r.document and c.commentnum = r.commentnum and c.dupsimstatus = 1 and c.bin = $bin ";
   $sql .= "and (c.summary = $args{summary} or r.summary = $args{summary}) and ((r.status <= 9) or (r.status >= 14)) order by c.document, c.commentnum";
   my $csr = $args{dbh}->prepare($sql);
   $csr->execute;
   my $tableHeader = "No Comments Attached to " . &formatID('SCR', 4, $args{summary});
   $output .= &start_table(4, 'right', 75, 20, 65, 590);
   $output .= &title_row("#a0e0c0", "#000099", "<font size=3>$tableHeader</font>");
   my $header .= &add_header_row();
   $header .= &writeBrowseCommentLink(writeHeader => 1);
   $header .= &writePrintCommentLink(writeHeader => 1);
   $header .= &add_col() . "<center>Attachment Status</center>";
   $header .= &add_col() . "<center>Comment Text</center>";
   my $numComments = 0;
   while (my ($docid, $commentid, $text, $summary, $approved) = $csr->fetchrow_array) {
      $output .= $header if (!$numComments);
      $numComments++;
      my $name = "comment$numComments";
      $output .= &add_row();
      $output .= &writeBrowseCommentLink(document => $docid, comment => $commentid);
      $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
      $output .= &add_col() . "<center>";
      my $approvedText = ($approved eq 'T') ? "Attached (approved)" : "Attached (unapproved)";
      $output .= ($summary) ? "$approvedText" : "Pending";
      $output .= "</center>";
      $output .= &add_col() . $text;
   }
   $csr->finish;
   $output .= &end_table();
   $output =~ s/No Comments/Comments ($numComments) Already/ if ($numComments);
   $output .= "</td></tr>";
   return ($output);
}

###################################################################################################################################
sub approveCommentsTable {                                                                                                        #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $sql = "select c.document, c.commentnum, c.text, c.summaryapproved from $args{schema}.comments c ";
   $sql .= "where c.dupsimstatus = 1 and c.bin = $args{bin} and c.summary = $args{summary} order by c.document, c.commentnum";
   my $csr = $args{dbh}->prepare($sql);
   $csr->execute;
   my $tableHeader = "No Comments Attached to " . &formatID('SCR', 4, $args{summary});
   my $output = "<tr><td>" . &start_table(4, 'right', 75, 20, 110, 545);
   $output .= &title_row("#a0e0c0", "#000099", "<font size=3>$tableHeader</font>");
   my $header .= &add_header_row();
   $header .= &writeBrowseCommentLink(writeHeader => 1);
   $header .= &writePrintCommentLink(writeHeader => 1);
   $header .= &add_col() . "<center>Approval Status<br>Yes / TBD / Unlink</center>";
   $header .= &add_col() . "<center>Comment Text</center>";
   my $numComments = 0;
   while (my ($docid, $commentid, $text, $approved) = $csr->fetchrow_array) {
      $output .= $header if (!$numComments);
      $numComments++;
      my $name = "comment$numComments";
      $output .= &add_row();
      $output .= &writeBrowseCommentLink(document => $docid, comment => $commentid);
      $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
      my $radio = "";
      my $selected = ($approved eq 'T') ? 1 : 2;
      for (my $button = 1; $button <= 3; $button++) {
         my $checked = ($button == $selected) ? "checked" : "";
         $radio .= "<input type=radio $checked name=$docid-$commentid  value=$button>\n";
      }
      $output .= &add_col() . "\n<center>$radio</center>";
      $output .= &add_col() . $text;
   }
   $csr->finish;
   $output .= &end_table() . "</td></tr>";
   $output =~ s/No Comments/Comments ($numComments)/ if ($numComments);
   return ($output);
}

###################################################################################################################################
sub writeUpdatesTable {                                                                                                           #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $output .= "<tr><td>";
   my $sql = "select to_char(updatedate, '$dateFormat'), updatedby, description from $args{schema}.summary_update ";
   $sql .= "where summarycomment = $args{summary} order by updatedate desc";
   my $csr = $args{dbh}->prepare($sql);
   $csr->execute;
   my $tableHeader = "No History of Updates to " . &formatID('SCR', 4, $args{summary});
   $output .= &start_table(3, 'right', 140, 140, 470);
   $output .= &title_row("#a0e0c0", "#000099", "<font size=3>$tableHeader</font>");
   my $header .= &add_header_row();
   $header .= &writeDate(writeHeader => 1, headerText => "Date Updated");
   $header .= &writeUser(writeHeader => 1, headerText => "Updated By");
   $header .= &writeText(writeHeader => 1, headerText => $descriptionTitle);
   my $rows = 0;
   while (my ($date, $user, $description) = $csr->fetchrow_array) {
      $output .= $header if (!$rows);
      $rows++;
      $output .= &add_row();
      $output .= &writeDate(date => $date);
      $output .= &writeUser(userID => $user);
      $output .= &writeText(text => $description);
   }
   $csr->finish;
   $output .= &end_table();
   $output =~ s/No History/History/ if ($rows);
   $output .= "</td></tr><tr><td>&nbsp;</td></tr><tr><td>";
   $sql = "select to_char(updatedate, '$dateFormat'), commenttext, responsetext from $args{schema}.summary_history ";
   $sql .= "where summarycomment = $args{summary} order by updatedate desc";
   $csr = $args{dbh}->prepare($sql);
   $csr->execute;
   $tableHeader = "No Previous Versions of " . &formatID('SCR', 4, $args{summary});
   $output .= &start_table(3, 'right', 140, 305, 305);
   $output .= &title_row("#a0e0c0", "#000099", "<font size=3>$tableHeader</font>");
   $header = &add_header_row();
   $header .= &writeDate(writeHeader => 1, headerText => "Date Replaced");
   $header .= &writeText(writeHeader => 1, headerText => "Comment Text");
   $header .= &writeText(writeHeader => 1, headerText => "Response Text");
   $rows = 0;
   while (my ($date, $comment, $response) = $csr->fetchrow_array) {
      $response = "&nbsp;" if (!$response);
      $output .= $header if (!$rows);
      $rows++;
      $output .= &add_row();
      $output .= &writeDate(date => $date, valign => "top");
      $output .= &writeText(text => $comment, valign => "top");
      $output .= &writeText(text => $response, valign => "top");
   }
   $csr->finish;
   $output .= &end_table() . "</td></tr>";
   $output =~ s/No Previous/Previous/ if ($rows);
   return ($output);
}

###################################################################################################################################
sub getLookupValues {                                                                                                             #
###################################################################################################################################
   my %lookupHash = ();
   my $lookup = $_[0]->prepare("select id, name from $_[1].$_[2]");
   $lookup->execute;
   while (my ($key, $value) = $lookup->fetchrow_array) {
      $lookupHash{$key} = $value;
   }
   $lookup->finish;
   return (\%lookupHash);
}

###################################################################################################################################
sub writeControl {                                                                                                                #
###################################################################################################################################
   my %args = (
      name => 'button',
      useLinks => 1,
      @_,
   );
   return ($args{useLinks}) ? "<b><a href=\"javascript:$args{callback}\">$args{label}</a></b>" : "<input type=button name=$args{name} value='$args{label}' onClick=javascript:$args{callback}>";
}

###################################################################################################################################
sub getSummaryId {
###################################################################################################################################
   my $returnValue = $dbh->selectrow_array("SELECT $schema.summary_comment_id.NEXTVAL from DUAL");
   return ($returnValue);
}

###################################################################################################################################
sub writeBinDropdown {
###################################################################################################################################
   my %args = (
      @_,
   );
   tie my %binlookup, "Tie::IxHash";
   %binlookup = get_lookup_values($dbh, $schema, 'bin', 'id', 'name', '1=1 order by name');
   my $output .= "<tr><td><b>Bin:</b>&nbsp;&nbsp; \n";
   $output .= build_drop_box('dropdownbin', \%binlookup, $args{bin}) . "</td></tr>\n";
   return ($output);
}

###################################################################################################################################
sub getBinName {
###################################################################################################################################
   my $binName = $dbh->selectrow_array ("select name from $schema.bin where id = $_[0]");
   return ($binName);
}

###################################################################################################################################
sub getResponseWriter {
###################################################################################################################################
   my %args = (
      @_,
   );
   tie my %writers, "Tie::IxHash";
   my ($id, $fname, $lname);
   my $csr = $dbh->prepare("SELECT u.id, u.firstname, u.lastname FROM $schema.users u, $schema.user_privilege p WHERE (p.privilege = 4 or p.privilege = 8) AND u.id = p.userid AND u.id NOT IN (SELECT u.id FROM $schema.users u, $schema.user_privilege p WHERE p.privilege = -1 AND u.id = p.userid) ORDER BY u.lastname, u.firstname");
   $csr->execute;
   while (($id, $fname, $lname) = $csr->fetchrow_array) {
      $writers{$id} = "$fname $lname";
   }
   $csr->finish;
   return (%writers);
}

###################################################################################################################################
sub writeWriter {
###################################################################################################################################
   my %args = (
      name => 'responseWriter',
      label => 'Response Writer',
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      @_,
   );
   tie my %writers, "Tie::IxHash";
   %writers = &getResponseWriter();
   my $writer = ($args{writer}) ? $args{writer} : 1;
   my $current = ($args{useForm}) ? $crdcgi->param($args{name}) : $writer;
   $output .= "<tr><td><b>$args{label}:</b>" . &nbspaces(2) . "<select name=$args{name} size=1>";
   foreach my $id (keys (%writers)) {
      my $selected = ($current == $id) ? 'selected' : '';
      $output .= "<option value='$id' $selected>$writers{$id}";
   }
   $output .= "</select></td></td>\n";
   return ($output);
}

###################################################################################################################################
sub processError {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $error = &errorMessage($dbh, $username, $userid, $schema, $args{activity}, $@) . "\n";
   $error .=  ('-' x 80) . "\n" if ($errorstr ne "");
   $error =~ s/\n/\\n/g;
   $error =~ s/'/%27/g;
   $errorstr .= $error;
}

###################################################################################################################################
sub submitRemarks {
###################################################################################################################################
   my %args = (
      date => "SYSDATE",
      table => "summary_remark",
      @_,
   );
   my $sql = "insert into $args{schema}.$args{table} (summarycomment, remarker, dateentered, text) ";
   $sql .= "values ($args{summary}, $args{remarker}, $args{date}, :text)";
   my $csr = $args{dbh}->prepare($sql);
   $csr->bind_param(":text", $args{remark}, {ora_type => ORA_CLOB, ora_field => 'text'});
   $csr->execute;
   sleep 1;
}

###################################################################################################################################
sub updateText {
###################################################################################################################################
  my %args = (
      column => "responsetext",
      table => "summary_comment",
      @_,
   );
   my $sql = "update $args{schema}.$args{table} set $args{column} = :text where id = $args{summary}";
   my $csr = $args{dbh}->prepare($sql);
   $csr->bind_param(":text", $args{text}, {ora_type => ORA_CLOB, ora_field => $args{column}});
   $csr->execute;
}

###################################################################################################################################
sub processSubmittedData {
###################################################################################################################################
   print "<html>\n<head>\n</head>\n<body>\n";
   my ($message, $popMessage, $activity, $confirm, $error, $logActivity) = ("", "", "", "", "", 0);
   my $summaryCommentTitle = (defined($crdcgi->param("summaryCommentTitle"))) ? $crdcgi->param("summaryCommentTitle") : "";
   $summaryCommentTitle =~ s/'/''/g;
   my $commentText = $crdcgi->param("commentText");
   my $responseText = ($crdcgi->param("responseText")) ? $crdcgi->param("responseText") : "";
   my $hasCommitments = ($crdcgi->param("hasCommitments")) ? 'T' : 'F';
   my $changeImpact = $crdcgi->param("changeImpact");
   my $changeControlNumber = $crdcgi->param("changeControlNumber");
   my $createdby = $userid unless ($command eq 'proofread_summary_comment');
   my $description = $crdcgi->param("description");
   my $summaryRemarks = $crdcgi->param("summaryRemarks");
   my $responseWriter = $crdcgi->param("responseWriter") unless ($process eq 'create');
   my $doProofRead = &doSCRProofRead;
   eval {
      #############################################################################################################################
      if ($process eq 'create') {
      #############################################################################################################################
         my $bin = $crdcgi->param("bin");
         $summaryCommentID = &getSummaryId();
         my $formattedID = &formatID('SCR', 4, $summaryCommentID);
         $activity = "summary comment $formattedID created - response writer";
         my $sql = "insert into $schema.summary_comment (id, title, commenttext, hascommitments, changeimpact, changecontrolnum, createdby, ";
         $sql .= "datecreated, bin, responsewriter, proofreadby, proofreaddate";
         $sql .= ") values ($summaryCommentID, '$summaryCommentTitle', :commenttext, '$hasCommitments', $changeImpact, ";
         $sql .= ($changeControlNumber) ? "'$changeControlNumber'" : "NULL";
         $sql .= ", $createdby, SYSDATE, $bin, $userid, ";
         $sql .= ($doProofRead == 0) ? " $userid, SYSDATE" : " NULL, NULL";
         $sql .= ")";
         my $csr = $dbh->prepare($sql);
         $csr->bind_param(":commenttext", $commentText, {ora_type => ORA_CLOB, ora_field => 'commenttext'});
         $csr->execute;
         &updateText(dbh => $dbh, schema => $schema, summary => $summaryCommentID, text => $responseText) if ($responseText);
         if (&requireResponseSource()) {
            my $responseSource = "Response source:  " . $crdcgi->param("$responseSourceName");
            &submitRemarks(dbh => $dbh, schema => $schema, summary => $summaryCommentID, remarker => $userid, remark => $responseSource);
         }
         &submitRemarks(dbh => $dbh, schema => $schema, summary => $summaryCommentID, remarker => $userid, remark => $summaryRemarks) if ($summaryRemarks);
         $dbh->commit;
         $message = "Created Summary Comment $formattedID";
         $popMessage = 1;
         $logActivity = 1;
         $form = 'responses';
      #############################################################################################################################
      } elsif ($process eq 'enter_summary_comment') {
      #############################################################################################################################
         my $bin = $crdcgi->param("dropdownbin");
         $summaryCommentID = &getSummaryId();
         my $formattedID = &formatID('SCR', 4, $summaryCommentID);
         $activity = "summary comment $formattedID created - data entry";
#         my $sql = "insert into $schema.summary_comment_entry (id, title, commenttext, hascommitments, changeimpact, changecontrolnum, ";
         my $sql = "insert into $schema.summary_comment" . (($doProofRead == 0) ? "" : "_entry") . " (id, title, commenttext, hascommitments, changeimpact, changecontrolnum, ";
         $sql .= "createdby, datecreated, bin, responsewriter";
         $sql .= ($doProofRead == 0) ? ", proofreadby, proofreaddate" : "";
         $sql .= ") values ($summaryCommentID, '$summaryCommentTitle', :commenttext, '$hasCommitments', $changeImpact, ";
         $sql .= ($changeControlNumber) ? "'$changeControlNumber'" : "NULL";
         $sql .= ", $createdby, SYSDATE, $bin, $responseWriter";
         $sql .= ($doProofRead == 0) ? ", $userid, SYSDATE" : "";
         $sql .= ")";
         my $csr = $dbh->prepare($sql);
         $csr->bind_param(":commenttext", $commentText, {ora_type => ORA_CLOB, ora_field => 'commenttext'});
         $csr->execute;
         &updateText(dbh => $dbh, schema => $schema, table => (($doProofRead == 1) ? 'summary_comment_entry' : "summary_comment"), summary => $summaryCommentID, text => $responseText) if ($responseText);
         if (&requireResponseSource()) {
            my $responseSource = "Response source:  " . $crdcgi->param("$responseSourceName");
            $summaryRemarks = "$responseSource\n$summaryRemarks";
         }
         if ($doProofRead == 1) {
             &updateText(dbh => $dbh, schema => $schema, table => 'summary_comment_entry', column => 'remarks', summary => $summaryCommentID, text => $summaryRemarks) if ($summaryRemarks);
         } else {
             &submitRemarks(dbh => $dbh, schema => $schema, summary => $summaryCommentID, remarker => $userid, remark => $summaryRemarks) if ($summaryRemarks);
         }
         $dbh->commit;
         $message = "Summary Comment $formattedID " . (($doProofRead == 1) ? "added to proofread queue" : "Created");
         $popMessage = 1;
         $logActivity = 1;
         $form = 'home';
      #############################################################################################################################
      } elsif ($process eq 'proofread_summary_comment') {
      #############################################################################################################################
         my $bin = $crdcgi->param("dropdownbin");
         $activity = "process proofread of summary comment entry";
         my ($createdby, $datecreated) = $dbh->selectrow_array ("select createdby, to_char(datecreated,'$dateFormat') from $schema.summary_comment_entry where id=$summaryCommentID");
         my $sql = "insert into $schema.summary_comment (id, title, commenttext, hascommitments, changeimpact, changecontrolnum, ";
         $sql .= "createdby, datecreated, proofreadby, proofreaddate, bin, responsewriter) ";
         $sql .= "values ($summaryCommentID, '$summaryCommentTitle', :commenttext, '$hasCommitments', $changeImpact, ";
         $sql .= ($changeControlNumber) ? "'$changeControlNumber'" : "NULL";
         $sql .= ", $createdby,  to_date('$datecreated','$dateFormat'), $userid, SYSDATE, $bin, $responseWriter)";
         my $csr = $dbh->prepare($sql);
         $csr->bind_param(":commenttext", $commentText, {ora_type => ORA_CLOB, ora_field => 'commenttext'});
         $csr->execute;
         &updateText(dbh => $dbh, schema => $schema, summary => $summaryCommentID, text => $responseText) if ($responseText);
         my $oldRemarks = $crdcgi->param("oldRemarks");
         &submitRemarks(dbh => $dbh, schema => $schema, summary => $summaryCommentID, remarker => $createdby, remark => $oldRemarks, date => "to_date('$datecreated','$dateFormat')") if ($oldRemarks);
         &submitRemarks(dbh => $dbh, schema => $schema, summary => $summaryCommentID, remarker => $userid, remark => $summaryRemarks) if ($summaryRemarks);
         $dbh->do("delete from $schema.summary_comment_entry where id = $summaryCommentID");
         $dbh->commit;
         $message = "Proofread on $formattedID successful";
         $popMessage = 1;
         $logActivity = 1;
         $form = 'home';
      #############################################################################################################################
      } elsif ($process eq 'update') {
      #############################################################################################################################
         $activity .= "update summary comment $formattedID";
         my $concurDeleteActivity = "";
         my ($oldComment, $oldResponse) = $dbh->selectrow_array("select commenttext, responsetext from $schema.summary_comment where id = $summaryCommentID");
         if (($oldComment ne $commentText) || ($oldResponse ne $responseText)) {
            my $insertsql = "insert into $schema.summary_history (summarycomment, updatedate, commenttext";
            $insertsql .= ", responsetext" if ($oldResponse);
            $insertsql .= ") values ($summaryCommentID, SYSDATE, :commenttext";
            $insertsql .= ", :responsetext" if ($oldResponse);
            $insertsql .= ")";
            my $insertcsr = $dbh->prepare($insertsql);
            $insertcsr->bind_param(":commenttext", $oldComment, {ora_type => ORA_CLOB, ora_field => 'commenttext'});
            $insertcsr->bind_param(":responsetext", $oldResponse, {ora_type => ORA_CLOB, ora_field => 'responsetext'}) if ($oldResponse);
            $insertcsr->execute;

            my %concurTypes = %{&getLookupValues($dbh, $schema, 'concurrence_type')};
            foreach my $concurType (keys (%concurTypes)) {
               my ($count) = $dbh->selectrow_array("select count(*) from $schema.concurrence_summary where summarycomment = $summaryCommentID and concurrencetype = $concurType and concurs = 'T'");
               if ($count) {
                  $dbh->do ("delete from $schema.concurrence_summary where summarycomment = $summaryCommentID and concurrencetype = $concurType and concurs = 'T'");
                  my $remarks = "summary comment/response text updated - positive $concurTypes{$concurType} concurrence deleted";
                  &submitRemarks(dbh => $dbh, schema => $schema, summary => $summaryCommentID, remarker => $userid, remark => $remarks);
                  $concurDeleteActivity = " - positive concurrence(s) deleted";
               }
            }
         }
         $activity .= $concurDeleteActivity;
         my $sql = "update $schema.summary_comment set commenttext = :text where id = $summaryCommentID";
         my $csr = $dbh->prepare($sql);
         $csr->bind_param(":text", $commentText, {ora_type => ORA_CLOB, ora_field => 'commenttext'});
         $csr->execute;
         if (!$responseText) {
            $dbh->do ("update $schema.summary_comment set responsetext = NULL where id = $summaryCommentID");
         } else {
            $sql = "update $schema.summary_comment set responsetext = :text where id = $summaryCommentID";
            $csr = $dbh->prepare($sql);
            $csr->bind_param(":text", $responseText, {ora_type => ORA_CLOB, ora_field => 'responsetext'});
            $csr->execute;
         }
         $dbh->do ("update $schema.summary_comment set title = '$summaryCommentTitle' where id = $summaryCommentID");
         $dbh->do ("update $schema.summary_comment set commenttextapproved = 'F' where id = $summaryCommentID") if ($oldComment ne $commentText);
         $dbh->do ("update $schema.summary_comment set responsetextapproved = 'F' where id = $summaryCommentID") if ($oldResponse ne $responseText);
         $sql = "insert into $schema.summary_update (summarycomment, updatedate, updatedby, description) values ($summaryCommentID, SYSDATE, $userid, :text)";
         $csr = $dbh->prepare($sql);
         $csr->bind_param(":text", $description, {ora_type => ORA_CLOB, ora_field => 'description'});
         $csr->execute;
         &updateHasCommitments(dbh => $dbh, schema => $schema, table => 'summary_comment', summaryID => $summaryCommentID);
         &updateChangeImpact(dbh => $dbh, schema => $schema, table => 'summary_comment', summaryID => $summaryCommentID);
         &submitRemarks(dbh => $dbh, schema => $schema, summary => $summaryCommentID, remarker => $userid, remark => $summaryRemarks) if ($summaryRemarks);
         $dbh->commit;
         $message = "Update on $formattedID successful";
         $popMessage = 1;
         $logActivity = 1;
         $form = 'utilities';
      #############################################################################################################################
      } elsif ($process eq 'saveRemark') {
      #############################################################################################################################
         $activity = "save summary comment remark";
         &submitRemarks(dbh => $dbh, schema => $schema, summary => $summaryCommentID, remarker => $userid, remark => $summaryRemarks);
         $dbh->commit;
      #############################################################################################################################
      } elsif ($process eq 'summarize_multiple') {
      #############################################################################################################################
         $activity = "summarize multiple comments with $formattedID";
         my $numComments = defined($crdcgi->param("numComments")) ? $crdcgi->param("numComments") : 0;
         for (my $i = 1; $i <= $numComments; $i++) {
            if (defined($crdcgi->param("comment$i"))) {
               my ($documentID, $commentID) = split $delimiter, $crdcgi->param("comment$i");
               my ($version) = $dbh->selectrow_array ("select max(version) from $schema.response_version where document = $documentID and commentnum = $commentID");
               if ($responseStatus == 1) {
                  $dbh->do ("update $schema.comments set summary = $summaryCommentID where document = $documentID and commentnum = $commentID");
                  $dbh->do ("update $schema.response_version set status = 15, dateupdated = SYSDATE where document = $documentID and commentnum = $commentID and version = $version");
               } elsif ($responseStatus == 2) {
                  $dbh->do ("update $schema.response_version set status = 6, dateupdated = SYSDATE, summary = $summaryCommentID where document = $documentID and commentnum = $commentID and version = $version");
               } else {
                  $error = "Unknown response status '$responseStatus' processing multiple summarized comments";
               }
            }
         }
         $logActivity = 1;
      #############################################################################################################################
      } elsif ($process eq 'manageApprovals') {
      #############################################################################################################################
         $activity = "manage approvals for $formattedID";
         $logActivity = 1;
         my $commentApproved = (defined($crdcgi->param("commentApproved"))) ? 'T' : 'F';
         my $responseApproved = (defined($crdcgi->param("responseApproved"))) ? 'T' : 'F';
         $dbh->do ("update $schema.summary_comment set commenttextapproved = '$commentApproved', responsetextapproved = '$responseApproved' where id = $summaryCommentID");
         my @paramlist = $crdcgi->param();
         foreach my $param (@paramlist) {
            if ($param =~ m/(\d{1,6})-(\d{1,4})/) {
               my $val = $crdcgi->param($param);
               if ($val == 3) {
                  &delinkCommentFromSummary(dbh => $dbh, schema => $schema, documentID => $1, commentID => $2, summary => $summaryCommentID);
               } else {
                  my $approved = ($val == 1) ? 'T' : 'F';
                  $dbh->do ("update $schema.comments set summaryapproved = '$approved' where document = $1 and commentnum = $2");
               }
            }
         }
         $dbh->commit;
      #############################################################################################################################
      } elsif ($process eq 'accept') {
      #############################################################################################################################
         $activity = "bin coordinator accept $formattedID";
         $logActivity = 1;
         $dbh->do ("update $schema.summary_comment set dateapproved = SYSDATE where id = $summaryCommentID");
         $dbh->commit;
      #############################################################################################################################
      } elsif ($process eq 'concur') {
      #############################################################################################################################
         $logActivity = 1;
         my $activityType = "";
         my $concurs = ($crdcgi->param("concurs")) ? 'T' : 'F';
         my $concurType = $crdcgi->param("concurtype");
         my $summaryRemarks = (defined($crdcgi->param("summaryRemarks"))) ? $crdcgi->param("summaryRemarks") : "";
         my %concurTypes = %{&getLookupValues($dbh, $schema, 'concurrence_type')};
         my ($count) = $dbh->selectrow_array("select count(*) from $schema.concurrence_summary where summarycomment = $summaryCommentID and concurrencetype = $concurType");
         if ($count) {
            $activityType = "update";
            $dbh->do ("update $schema.concurrence_summary set concurrencetype = $concurType, concurdate = SYSDATE, concurs = '$concurs' where summarycomment = $summaryCommentID and concurrencetype = $concurType");
         } else {
            $activityType = "enter";
            $dbh->do ("insert into $schema.concurrence_summary (summarycomment, concurrencetype, concurs, concurdate) values ($summaryCommentID, $concurType, '$concurs', SYSDATE)");
         }
         $activity = "$activityType $concurTypes{$concurType} concurrence for $formattedID";
         &submitRemarks(dbh => $dbh, schema => $schema, summary => $summaryCommentID, remarker => $userid, remark => $summaryRemarks) if ($summaryRemarks);
         $dbh->commit;
         $form = 'home';
      #############################################################################################################################
      } else {
      #############################################################################################################################
         $error .= 'process unknown command in summary_comments script';
         $message .= 'process unknown command in summary_comments script';
         $popMessage = 1;
         $form = 'browse';
      }
   };
   ################################################################################################################################
   if ($@) {
      $dbh->rollback;
      $error .= &errorMessage($dbh, $username, $userid, $schema, $activity, $@);
   } elsif ($logActivity) {
      &log_activity ($dbh, $schema, $userid, $activity);
   }
   if ($error) { # display the error message
      $error =~ s/\n/\\n/g;
      $error =~ s/'/%27/g;
      print "<script language=javascript>\n<!--\nvar mytext ='$error';\nalert(unescape(mytext));\n//-->\n</script>\n";
   } else { # submit a form to run the required script and produce output in the main window
      $message =~ s/\n/\\n/g;
      $message =~ s/'/%27/g;
      print "<form name=$form method=post target='main' action=$path$form.pl>\n";
      if ($form eq 'summary_comments') {
         my @paramlist = $crdcgi->param();
         foreach my $param (@paramlist) {
            my $val = ($param eq 'process') ? 0 : $crdcgi->param($param);
            $val =~ s/'/%27/g;
            $val = $summaryCommentID if ($param eq 'summarycommentid');
            $val = $command if (($param eq 'command') && ($command eq 'enter'));
            print "<input type=hidden name='$param' value='$val'>\n";
         }
      } else {
         print "<input type=hidden name=username value=$username>\n";
         print "<input type=hidden name=userid value=$userid>\n";
         print "<input type=hidden name=schema value=$schema>\n";
         if ($form eq 'responses') {
            print "<input type=hidden name=id value=" . $crdcgi->param('documentid') . ">\n";
            print "<input type=hidden name=commentid value=" . $crdcgi->param('commentid') . ">\n";
            print "<input type=hidden name=version value=" . $crdcgi->param('version') . ">\n";
            print "<input type=hidden name=command value=" . $crdcgi->param('caller') . ">\n";
            print "<input type=hidden name=summarycommentid value=$summaryCommentID>\n";
         }
      }
      print "</form>\n";
      if ($popMessage) {
         print "<script language=javascript>\n<!--\nvar mytext ='$message';\n alert(unescape(mytext));\n $form.submit();\n//-->\n</script>\n";
      } else {
         print "<script language=javascript>\n<!--\n $form.submit();\n//-->\n</script>\n";
      }
   }
   print "</body>\n</html>\n";
}

######################################################################################################################################
sub drawPage {
######################################################################################################################################
   my %args = (
      @_,
   );
   my $output = "";
   $output .= "<script language=javascript><!--\n";
   $output .= "   function checkSource() {\n";
   $output .= "      var msg = \"\";\n";
   if (&requireResponseSource()) {
      $output .= "   if ($form.$responseSourceName.value == \"\") {\n";
      $output .= "      msg = \"Please Enter Comment/Response Text Source\\n\";\n";
      $output .= "   }\n";
   }
   $output .= "      return (msg);\n";
   $output .= "   }\n";
   $output .= <<end;
      function submitForm(script, command, target) {
         $form.target = target;
         $form.command.value = command;
         $form.action = '$path' + script + '.pl';
         $form.submit();
      }
      function checkTitle() {
         return ($form.summaryCommentTitle.value != "") ? "" : "Please Enter Summary Comment Title\\n";
      }
      function checkCommentText() {
         return ($form.commentText.value != "") ? "" : "Please Enter Summary Comment Text\\n";
      }
      function checkDescription() {
         return ($form.description.value != "") ? "" : "Please Enter $descriptionTitle\\n";
      }
      function create(bin, documentid, commentid, version, caller) {
         var msg = checkTitle();
         msg += checkCommentText();
         msg += checkSource();
         msg += checkChangeControl();
         if (msg != '') {
            alert (msg);
         } else {
            escape($form.summaryCommentTitle.value);
            $form.bin.value = bin;
            $form.documentid.value = documentid;
            $form.commentid.value = commentid;
            $form.version.value = version;
            $form.caller.value = caller;
            $form.process.value = 'create';
            $form.useFormValues.value = 0;
            submitForm('$form', 'create', 'cgiresults');
         }
      }
      function enter() {
         var msg = checkTitle();
         msg += checkCommentText();
         msg += checkSource();
         msg += checkChangeControl();
         if (msg != '') {
            alert (msg);
         } else {
            escape($form.summaryCommentTitle.value);
            $form.process.value = 'enter_summary_comment';
            $form.useFormValues.value = 0;
            submitForm('$form', 'enter_summary_comment', 'cgiresults');
         }
      }
      function verifyEntry(command, id) {
         var msg = checkTitle();
         msg += checkCommentText();
         msg += checkChangeControl();
         if (command != 'proofread_summary_comment') {
            msg += checkDescription();
         }
         if (msg != '') {
            alert (msg);
         } else {
            escape($form.summaryCommentTitle.value);
            $form.summarycommentid.value = id;
            $form.process.value = command;
            $form.useFormValues.value = 0;
            submitForm('$form', command, 'cgiresults');
         }
      }
      function display_user(id) {
         $form.id.value = id;
         submitForm('user_functions', 'displayuser', 'main');
      }
      function displayComment(documentid, commentid) {
         $form.id.value = documentid;
         $form.commentid.value = commentid;
         submitForm('comments', 'browse', 'main');
      }
      function display_bin(id) {
         $form.binid.value = id;
         submitForm('bins', 'browse', 'main');
      }
      function displaySummaryComment(id) {
         $form.summarycommentid.value = id;
         submitForm('$form', 'browseSummaryComment', 'main');
      }
      function updateSummaryComment(id) {
         $form.summarycommentid.value = id;
         submitForm('$form', 'updateSummaryComment', 'main');
      }
      function manageSummaryCommentApprovals(id) {
         $form.summarycommentid.value = id;
         submitForm('$form', 'manageApprovals', 'main');
      }
      function processManageApprovals(id) {
         $form.summarycommentid.value = id;
         $form.process.value = '$command';
         submitForm('$form', 'update', 'cgiresults');
      }
      function acceptSummaryComment(id) {
         $form.summarycommentid.value = id;
         $form.process.value = 'accept';
         submitForm('$form', 'update', 'cgiresults');
      }
      function redraw(sortBy, sortOrder) {
         $form.sortBy.value = sortBy;
         $form.sortOrder.value = sortOrder;
         submitForm('$form', '$command', 'main');
      }
      function summarizeMultiple(bin) {
         $form.summarycommentid.value = $form.summarizeMultipleID.value;
         $form.command.value = 'summarize_multiple';
         $form.bin.value = bin;
         $form.response_status.value = '$responseStatus';
         submitForm('$form', 'summarize_multiple', 'main');
      }
      function enterConcur(id, concurType) {
         if (($form.concurs\[1\].checked) && ($form.summaryRemarks.value == "")) {
            alert ('A remark must be entered with a negative concurrence');
         } else {
            $form.summarycommentid.value = id;
            $form.concurtype.value = concurType;
            $form.process.value = 'concur';
            submitForm('$form', 'concur', 'cgiresults');
         }
      }
      function saveRemark() {
         if (isblank($form.summaryRemarks.value)) {
            alert("No text has been entered in the remarks field.");
         } else {
            $form.summarycommentid.value = $summaryCommentID;
            $form.process.value = 'saveRemark';
            submitForm('$form', 'updateSummaryComment', 'cgiresults');
         }
      }
   //-->
   </script>
end
   ################################################################################################################################
   if (($args{command} eq "create") || ($args{command} eq "enter_summary_comment")) {
   ################################################################################################################################
      my $bin = 1;
      my $documentid = $crdcgi->param("documentid");
      my $commentid = $crdcgi->param("commentid");
      my $version = $crdcgi->param("version");
      my $caller = $crdcgi->param("caller");
      my ($summaryCommentTitle, $commentText, $responseText, $sourceText, $summaryRemarks) = ("", "", "", "", "");
      if ($useFormValues) {
         $commentText = $crdcgi->param("commentText");
         $responseText = $crdcgi->param("responseText");
         $sourceText = $crdcgi->param("sourceText");
         $summaryRemarks = $crdcgi->param("summaryRemarks");
         $summaryCommentTitle = $crdcgi->param("summaryCommentTitle");
      } elsif ($args{command} eq 'create') {
         $commentText = $dbh->selectrow_array ("select text from $schema.comments where document = $documentid and commentnum = $commentid");
         $responseText = &lastSubmittedText(dbh => $dbh, schema => $schema, documentID => $documentid, commentID => $commentid);
      }
      $output .= "<tr><td><br></td></tr>\n";
      $output .= "<tr><td align=right><table width=96% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellpadding=8 cellspacing=0>\n";
      if ($args{command} eq 'enter_summary_comment') {
         $output .= &writeBinDropdown(bin => $bin);
         $output .= &writeWriter(bin => $bin);
      } else {
         $bin = $crdcgi->param("binid");  # passed from response script
         my $binName = &getBinName($bin);
         $output .= "<tr><td align=left height=40><b>Bin: &nbsp;&nbsp;<a href=javascript:display_bin($bin)>$binName</a></b></td></tr>\n";
      }
      $output .= "<tr><td><b>Title: &nbsp;&nbsp;</b><input type=text size=75 maxlength=150 name=summaryCommentTitle value=\"$summaryCommentTitle\"> </td></tr>\n";
      $output .= "<tr> " . &writeHasCommitments(dbh => $dbh, schema => $schema, doSelect => 0, table => 'summary_comments', useForm => $useFormValues) . "</tr>\n";
      $output .= "<tr> " . &writeChangeImpact(dbh => $dbh, schema => $schema, doSelect => 0, table => 'summary_comments', useForm => $useFormValues) . "</tr>\n";
      $output .= &writeTextBox(name => "commentText", label => "Summary Comment Text:", text => $commentText);
      my $label = "Response Text:" . &nbspaces(2) . "<font face=arial size=2 color=$instructionsColor>(Optional)";
      $output .= &writeTextBox(name => "responseText", label => $label, text => $responseText);
      $output .= &writeTextBox(name => $responseSourceName, label => "Source:", text => $sourceText) if (&requireResponseSource());
      $label = "Remarks:" . &nbspaces(2) . "<font face=arial size=2 color=$instructionsColor>(Optional)";
      $output .= &writeTextBox(name => "summaryRemarks", label => $label, text => $summaryRemarks);
      $output .= "</td></tr></table></td></tr>\n";
      my $callback = ($args{command} eq "create") ? "create($bin,$documentid,$commentid,$version,'$caller')" : "enter()";
      my $submit = &writeControl(label => "Submit", callback => $callback, useLinks => 0);
      $output .= "<tr><td align=center height=40>$submit</td></tr>\n";
   ################################################################################################################################
   } elsif ($args{command} eq 'proofread_summary_comment') {
   ################################################################################################################################
      my $summaryCommentID = $crdcgi->param("id");
      my $formattedID = &formatID('SCR', 4, $summaryCommentID);
      my ($summaryCommentTitle, $commentText, $responseText, $summaryRemarks, $createdby, $datecreated, $oldRemarks, $bin, $responseWriter) = ("", "", "", "", "", "", "", "", 1, 1);
      if ($useFormValues) {
         $commentText = $crdcgi->param("commentText");
         $responseText = $crdcgi->param("responseText");
         $summaryRemarks = $crdcgi->param("summaryRemarks");
         $summaryCommentTitle = $crdcgi->param("summaryCommentTitle");
         $bin = $crdcgi->param("dropdownbin");
      } else {
         my $sql = "select title, commenttext, responsetext, createdby, to_char(datecreated,'$dateFormat'), remarks, bin, responsewriter from $schema.summary_comment_entry where id=$summaryCommentID";
         ($summaryCommentTitle, $commentText, $responseText, $createdby, $datecreated, $oldRemarks, $bin, $responseWriter) = $dbh->selectrow_array ($sql);
      }
      my $remarkString;
      if ((defined($oldRemarks)) && ($oldRemarks gt '') && ($remarkString eq '')) {
         $remarkString = "$datecreated - " . get_fullname($dbh, $schema, $createdby);
      }
      my $createdbyname = &get_fullname($dbh, $schema, $createdby);
      $output .= "<tr><td align=right><table width=96% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellpadding=8 cellspacing=0>\n";
      $output .= "<tr><td height=40><b>ID: &nbsp;&nbsp;$formattedID</b></td></tr>\n";
      $output .= "<tr><td height=40><b>Created By: &nbsp;&nbsp;<a href=javascript:display_user($createdby)>$createdbyname</a></b></td></tr>\n";
      $output .= "<tr><td height=40><b>Date Created: &nbsp;&nbsp;$datecreated </b></td></tr>\n";
      $output .= &writeBinDropdown(bin => $bin);
      $output .= &writeWriter(bin=>$bin, writer=>$responseWriter);
      $summaryCommentTitle =~ s/'/%27/g;
      $output .= "<tr><td><b>Title: &nbsp;&nbsp;</b><input type=text size=75 maxlength=150 name=summaryCommentTitle > </td></tr>\n";
      $output .= "<script language=javascript><!--\n";
      $output .= "var mytext ='$summaryCommentTitle';\n";
      $output .= "$form.summaryCommentTitle.value = unescape(mytext);\n";
      $output .= "//-->\n";
      $output .= "</script>\n";
      $output .= "<tr> " . &writeHasCommitments(dbh => $dbh, schema => $schema, useForm => $useFormValues, summaryID => $summaryCommentID, table => 'summary_comment_entry') . "</tr>\n";
      $output .= "<tr> " . &writeChangeImpact(dbh => $dbh, schema => $schema, useForm => $useFormValues, summaryID => $summaryCommentID, table => 'summary_comment_entry') . "</tr>\n";
      $output .= &writeTextBox(name => "commentText", label => "Summary Comment Text:", text => $commentText);
      my $label = "Response Text:" . &nbspaces(2) . "<font face=arial size=2 color=$instructionsColor>(Optional)";
      $output .= &writeTextBox(name => "responseText", label => $label, text => $responseText);
      if ($remarkString) {
         $label = "Entry Remarks:" . &nbspaces(2) . "<font face=arial size=2 color=$instructionsColor>(Read Only)";
         $output .= &writeTextBox(name => "oldRemarks", label => $label, text => $oldRemarks, readOnly => 1);
      }
      $label = "Add Remarks:" . &nbspaces(2) . "<font face=arial size=2 color=$instructionsColor>(Optional)";
      $output .= &writeTextBox(name => "summaryRemarks", label => $label, text => $summaryRemarks);
      $output .= "</td></tr></table></td></tr>\n";
      my $submit = &writeControl(label => "Submit", callback => "verifyEntry('$args{command}',$summaryCommentID)", useLinks => 0);
      $output .= "<tr><td align=center height=40>$submit</td></tr>\n";
   ################################################################################################################################
   } elsif ($args{command} eq 'browse') {
   ################################################################################################################################
      my $sql = "select sc.id, sc.title, sc.responsewriter, sc.datecreated, sc.bin, b.name, sc.dateapproved, sc.commenttextapproved, sc.responsetextapproved from $schema.summary_comment sc, $schema.bin b where sc.bin = b.id order by $sortBy $sortOrder";
      my $csr = $dbh->prepare($sql);
      $csr->execute;
      $output .= "<tr><td>" . &start_table(7, 'right', 30, 375, 125, 40, 75, 60, 45);
      $output .= &title_row('#c0ffff', '#000099', "<font size=3>Summary Comments (xxx)</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to browse detailed information</font></i>)");
      $output .= &add_header_row();
      $output .= &writeBrowseSummaryID(writeHeader => 1);
      $output .= &writeText(writeHeader => 1, headerText => "Title");
      $output .= &writeUser(writeHeader => 1, headerText => "Author");
      $output .= &writeBin(writeHeader => 1);
      $output .= &writeDate(writeHeader => 1, headerText => "Date<br>Created");
      $output .= &writeText(writeHeader => 1, headerText => "Accepted?<br>Approved?");
      $output .= &writeText(writeHeader => 1, headerText => "#<br>Attached");
      my $rows = 0;
      while (my ($summary, $title, $writer, $date, $bin, $binname, $dateApproved, $commentIsApproved, $responseIsApproved) = $csr->fetchrow_array) {
         $rows++;
         my ($summarizedCount) = $dbh->selectrow_array ("select count(*) from $schema.comments where summary = $summary");
         $output .= &add_row();
         $output .= &writeBrowseSummaryID(id => $summary);
         $output .= &writeText(text => $title);
         $output .= &writeUser(userID => $writer);
         $output .= &writeBin(binID => $bin, binName => $binname);
         $output .= &writeDate(date => $date);
         my $approvedAcceptedText = ($dateApproved) ? 'Yes' : 'No';
         $approvedAcceptedText .= " / ";
         my ($unapprovedCount) = $dbh->selectrow_array ("select count(*) from $schema.comments where summary = $summary and summaryapproved = 'F'");
         $approvedAcceptedText .= (($unapprovedCount == 0) && ($commentIsApproved eq 'T') && ($responseIsApproved eq 'T')) ? 'Yes' : 'No';
         $output .= &writeText(text => "$approvedAcceptedText", center => 1);
         $output .= &writeText(text => "$summarizedCount", center => 1);
      }
      $csr->finish;
      $output .= &end_table();
      $output =~ s/xxx/$rows/;
   ################################################################################################################################
   } elsif ($args{command} eq 'update') {
   ################################################################################################################################
      my $isAdmin = (&does_user_have_priv($dbh, $schema, $userid, 10)) ? 1 : 0;
      my $sql = "select sc.id, sc.title, sc.responsewriter, sc.bin, b.name, sc.dateapproved, sc.commenttextapproved, ";
      $sql .= "sc.responsetextapproved, b.coordinator, b.nepareviewer from $schema.summary_comment sc, $schema.bin b ";
      $sql .= "where sc.bin = b.id ";
      $sql .= "and (((b.coordinator = $userid or sc.responsewriter = $userid) and sc.dateapproved is null) or b.nepareviewer = $userid) " if (!$isAdmin);
      $sql .= "order by $sortBy $sortOrder";
      my $csr = $dbh->prepare($sql);
      $csr->execute;
      $output .= "<tr><td>" . &start_table(8, 'right', 30, 345, 130, 40, 40, 60, 60, 45);
      $output .= &title_row('#c0ffff', '#000099', "<font size=3>Update Summary Comments/Manage Approvals (xxx)</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to update</font></i>)");
      $output .= &add_header_row();
      $output .= &writeSummaryID(writeHeader => 1);
      $output .= &writeText(writeHeader => 1, headerText => "Title");
      $output .= &writeUser(writeHeader => 1, headerText => "Author");
      $output .= &writeBin(writeHeader => 1);
      $output .= &writeUpdateLink(writeHeader => 1);
      $output .= &writeApprovalLink(writeHeader => 1);
      $output .= &writeAcceptedApproved(writeHeader => 1);
      $output .= &writeText(writeHeader => 1, headerText => "#<br>Attached");
      my $rows = 0;
      while (my ($summary, $title, $writer, $bin, $binname, $dateApproved, $commentIsApproved, $responseIsApproved, $coordinator, $nepaReviewer) = $csr->fetchrow_array) {
         $rows++;
         my ($summarizedCount) = $dbh->selectrow_array ("select count(*) from $schema.comments where summary = $summary");
         my ($unapprovedCount) = $dbh->selectrow_array ("select count(*) from $schema.comments where summary = $summary and summaryapproved = 'F'");
         my $isApproved = (($unapprovedCount == 0) && ($commentIsApproved eq 'T') && ($responseIsApproved eq 'T'));
         my $isAccepted = (defined($dateApproved) && $dateApproved) ? 1 : 0;
         my $canDoApprovals = ((($coordinator == $userid) && !$isAccepted) || (($nepaReviewer == $userid) && $isAccepted) || $isAdmin) ? 1 : 0;
         my $canAccept = (!$isAccepted && $isApproved && (($coordinator == $userid) || $isAdmin)) ? 1 : 0;
         $output .= &add_row();
         $output .= &writeSummaryID(id => $summary);
         $output .= &writeText(text => $title);
         $output .= &writeUser(userID => $writer);
         $output .= &writeBin(binID => $bin, binName => $binname);
         $output .= &writeUpdateLink(id => $summary);
         $output .= &writeApprovalLink(id => $summary, canDo => $canDoApprovals);
         $output .= &writeAcceptedApproved(id => $summary, canDo => $canAccept, isAccepted => $isAccepted, isApproved => $isApproved);
         $output .= &writeText(text => "$summarizedCount", center => 1);
      }
      $csr->finish;
      $output .= &end_table();
      $output =~ s/xxx/$rows/;
   ################################################################################################################################
   } elsif ($args{command} eq 'browseSummaryComment') {
   ################################################################################################################################
      $output .= &writeGeneralInfoTable(dbh => $dbh, schema => $schema, id => $summaryCommentID);
      $output .= &addSpace(height => 5);
      $output .= &writeCommentAndResponseText(dbh => $dbh, schema => $schema, id => $summaryCommentID);
      $output .= &addSpace();
      $output .= &summarizedCommentsTable(dbh => $dbh, schema => $schema, summary => $summaryCommentID);
      $output .= &addSpace();
      $output .= &doRemarks(schema => $schema, dbh => $dbh, remark_type => 'summary comment', summary_comment => $summaryCommentID, show_text_box => 0);
      $output .= &addSpace();
      $output .= &writeUpdatesTable(dbh => $dbh, schema => $schema, summary => $summaryCommentID);
   ################################################################################################################################
   } elsif ($args{command} eq 'updateSummaryComment') {
   ################################################################################################################################
      my $summaryCommentTitle = ($useFormValues) ? $crdcgi->param("summaryCommentTitle") : "";
      my $commentText = ($useFormValues) ? $crdcgi->param("commentText") : "";
      my $responseText = ($useFormValues) ? $crdcgi->param("responseText") : "";
      my $description = ($useFormValues) ? $crdcgi->param("description") : "";
      my $summaryRemarks = ($useFormValues) ? $crdcgi->param("summaryRemarks") : "";
      my ($commentIsApproved, $responseIsApproved);
      if (!$useFormValues) {
         my $sql = "select title, commenttext, responsetext, commenttextapproved, responsetextapproved from $schema.summary_comment where id = $summaryCommentID";
         ($summaryCommentTitle, $commentText, $responseText, $commentIsApproved, $responseIsApproved) = $dbh->selectrow_array ($sql);
      }
      $output .= &writeGeneralInfoTable(dbh => $dbh, schema => $schema, id => $summaryCommentID);
      $output .= &addSpace();
      $output .= &doRemarks(schema => $schema, dbh => $dbh, remark_type => 'summary comment', summary_comment => $summaryCommentID, show_text_box => 0);
      $output .= &addSpace();
      $output .= "<tr><td align=center><table width=96% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellpadding=8 cellspacing=0>\n";
      $summaryCommentTitle =~ s/'/%27/g;
      $output .= "<tr><td><b>Title:&nbsp;&nbsp;</b><input type=text size=75 maxlength=150 name=summaryCommentTitle></td></tr>\n";
      $output .= "<script language=javascript><!--\n";
      $output .= "var mytext ='$summaryCommentTitle';\n";
      $output .= "$form.summaryCommentTitle.value = unescape(mytext);\n";
      $output .= "//-->\n";
      $output .= "</script>\n";
      $output .= "<tr>" . &writeChangeImpact(dbh => $dbh, schema => $schema, useForm => $useFormValues, summaryID => $summaryCommentID, table => 'summary_comment') . "</tr>\n";
      $output .= "<tr>" . &writeHasCommitments(dbh => $dbh, schema => $schema, useForm => $useFormValues, summaryID => $summaryCommentID, table => 'summary_comment') . "</tr>\n";
      my $isApproved = ($commentIsApproved eq 'T') ? "(Approved)" : "(Unapproved)";
      $output .= &writeTextBox(name => "commentText", label => "Summary Comment Text $isApproved:", text => $commentText);
      $isApproved = ($responseIsApproved eq 'T') ? "(Approved)" : "(Unapproved)";
      $output .= &writeTextBox(name => "responseText", label => "Response Text $isApproved:", text => $responseText);
      $output .= &writeTextBox(name => "description", label => "$descriptionTitle (required):", text => $description);
      $output .= &writeTextBox(name => "summaryRemarks", label => "Remarks (optional):", text => $summaryRemarks);
      $output .= "</td></tr></table></td></tr>\n";
      my $submit = &writeControl(label => "Submit", callback => "verifyEntry('update',$summaryCommentID)", useLinks => 0);
      $output .= "<tr><td align=center height=40>$submit</td></tr>\n";
   ################################################################################################################################
   } elsif ($args{command} eq 'summarize_multiple') {
   ################################################################################################################################
      my $bin = $crdcgi->param("bin");
      my ($binName) = $dbh->selectrow_array ("select name from $schema.bin where id = $bin");
      tie my %sclookup, "Tie::IxHash";
      %sclookup = &get_lookup_values($dbh, $schema, 'summary_comment', 'id', 'title', "bin = $bin order by id");
      foreach my $id (keys (%sclookup)) {
         $sclookup{$id} = &getDisplayString($sclookup{$id}, 75);
      }
      my $submit = &writeControl(label => 'Go', callback => "summarizeMultiple($bin)", useLinks => 0);
      my $show = ($summaryCommentID) ? $summaryCommentID : 1;
      $output .= "<tr><td align=center><b>Bin:" . &nbspaces(2) . "$binName</b></td></tr>\n";
      $output .= "<tr><td align=center><b>Select Summary Comment:</b>" . &nbspaces(2) . &build_drop_box('summarizeMultipleID', \%sclookup, $show) . "$submit</td></tr>";
      if ($summaryCommentID) {
         $output .= "<tr><td align=center height=35><hr width=90%></td></tr>";
         $output .= &writeGeneralInfoTable(dbh => $dbh, schema => $schema, id => $summaryCommentID);
         $output .= &writeCommentAndResponseText(dbh => $dbh, schema => $schema, id => $summaryCommentID);
         $output .= &addSpace();
         $output .= &summarizedCommentsTable(dbh => $dbh, schema => $schema, summary => $summaryCommentID);
         $output .= &addSpace();
         my $sql = "select c.document, c.commentnum, c.text from $schema.comments c, $schema.response_version r ";
         $sql .= "where c.document = r.document and c.commentnum = r.commentnum and c.dupsimstatus = 1 and c.bin = $bin ";
         $sql .= "and c.summary is null and r.status = $responseStatus and r.responsewriter = $userid ";
         $sql .= "order by c.document, c.commentnum";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         $binName = &getBinNumber(binName =>$binName);
         my $tableHeader = "Bin $binName - xxx Comments ";
         $tableHeader .= ($responseStatus == 1) ? "Awaiting Assignment" : "Assigned For Response Writing";
         $output .= "<tr><td>" . &start_table(4, 'right', 95, 75, 20, 560);
         $output .= &title_row("#a0e0c0", "#000099", "<font size=3>$tableHeader</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click checkboxes to summarize - press submit when done</font></i>)");
         $output .= &add_header_row();
         $output .= &add_col() . "<center>Summarize with<br>$formattedID<center>";
         $output .= &add_col() . "<center>Doc ID /<br>Comment ID<center>";
         $output .= &writePrintCommentLink(writeHeader => 1);
         $output .= &add_col() . "<center>Comment Text</center>";
         my $numComments = 0;
         while (my ($docid, $commentid, $text, $summary) = $csr->fetchrow_array) {
            $numComments++;
            my $name = "comment$numComments";
            $output .= &add_row();
            $output .= &add_col();
            $output .= "<center><input type=checkbox name=$name value='$docid$delimiter$commentid'>";
            $output .= &add_col() . "<center>" . &formatID($CRDType, 6, $docid) . " /<br>" . &formatID("", 4, $commentid) . "</center>";
            $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
            $output .= &add_col() . $text;
          }
         $csr->finish;
         $output .= &end_table() . "</td></tr>";
         $output =~ s/xxx/$numComments/;
         $output .= "<input type=hidden name=numComments value=$numComments>\n";
         my $submit = &writeControl(label => 'Submit', callback => "summarizeComments()", useLinks => 0);
         $output .= "<tr><td align=center height=40>$submit</td></tr>\n";
         $output .= "<script language=javascript><!--\n";
         $output .= "function summarizeComments() {\n";
         $output .= "   $form.summarycommentid.value = $summaryCommentID;\n";
         $output .= "   $form.response_status.value = $responseStatus;\n";
         $output .= "   $form.command.value = 'summarize_multiple';\n";
         $output .= "   $form.bin.value = $bin;\n";
         $output .= "   $form.action = '$path' + 'summary_comments' + '.pl';\n";
         $output .= "   $form.process.value = 'summarize_multiple';\n";
         $output .= "   $form.target = 'cgiresults';\n";
         $output .= "   $form.submit();\n";
         $output .= "}\n";
         $output .= "//--></script>\n";
      }
      $output .= "</td></tr>\n";
   ################################################################################################################################
   } elsif ($args{command} eq 'manageApprovals') {
   ################################################################################################################################
      my $sql = "select commenttext, responsetext, bin, commenttextapproved, responsetextapproved from $schema.summary_comment where id = $summaryCommentID";
      my ($commentText, $responseText, $bin, $commentTextApproved, $responseTextApproved) = $dbh->selectrow_array ($sql);
      my ($count) = $dbh->selectrow_array ("select count(*) from $schema.comments where summary = $summaryCommentID");
      my ($commentTextChecked, $responseTextChecked);
      if ($useFormValues) {
         $commentTextChecked = (defined($crdcgi->param("commentApproved"))) ? "checked" : "";
         $responseTextChecked = (defined($crdcgi->param("responseApproved"))) ? "checked" : "";
      } else {
         $commentTextChecked = ($commentTextApproved eq 'T') ? "checked" : "";
         $responseTextChecked = ($responseTextApproved eq 'T') ? "checked" : "";
      }
      $output .= &writeGeneralInfoTable(dbh => $dbh, schema => $schema, id => $summaryCommentID);
      $output .= &addSpace(height => 5);
      my $label = "<b>Comment Text:" . &nbspaces(4) . "<input type=checkbox name=commentApproved value=commentApproved $commentTextChecked> Approved</b>";
      $output .= &writeTextBox(name => "commentText", label => $label, text => $commentText, readOnly => 1, cols => 90);
      $output .= &addSpace(height => 5);
      $label = "<b>Response Text:" . &nbspaces(4) . "<input type=checkbox name=responseApproved value=responseApproved $responseTextChecked> Approved</b>";
      $output .= &addSpace(height => 5);
      $output .= &writeTextBox(name => "responseText", label => $label, text => $responseText, readOnly => 1, cols => 90);
      $output .= &addSpace();
      $output .= &approveCommentsTable(dbh => $dbh, schema => $schema, summary => $summaryCommentID, bin => $bin);
      $output .= &addSpace();
      my $submit = &writeControl(label => "Submit", callback => "processManageApprovals($summaryCommentID)", useLinks => 0);
      $output .= "<tr><td align=center height=40>$submit</td></tr>\n";
   ################################################################################################################################
   } elsif ($args{command} eq 'concur') {
   ################################################################################################################################
      my $id = $crdcgi->param("id");
      my $summaryRemarks = ($useFormValues) ? $crdcgi->param("summaryRemarks") : "";
      my $concurType = $crdcgi->param("concurtype");
      my %concurTypes = %{&getLookupValues($dbh, $schema, 'concurrence_type')};
      my $formattedID = &formatID('SCR', 4, $id);
      $output .= "<tr><td align=center><table width=600 border=0>\n";
      $output .= "<tr><td valign=top height=30><b>Enter $concurTypes{$concurType} concurrence for $formattedID (see information below):\n";
      $output .= &nbspaces(2);
      $output .= "<input type=radio checked name=concurs value=1> Positive\n";
      $output .= "<input type=radio name=concurs value=0> Negative\n";
      $output .= "</td></tr>";
      my $label = "Enter Remark:" . &nbspaces(3) . "<font size=-1 color=$instructionsColor><i>(Required with negative concurrence)</i></font>";
      $output .= &writeTextBox(name => "summaryRemarks", label => $label, text => $summaryRemarks);
      $output .= "</table></td></tr>\n";
      my $submit = &writeControl(label => "Submit", callback => "enterConcur($id,$concurType)", useLinks => 0);
      $output .= "<tr><td align=center height=40>$submit</td></tr>\n";
      $output .= "<tr><td height=30><hr width=90%</td></tr>\n";
      $output .= &writeGeneralInfoTable(dbh => $dbh, schema => $schema, id => $id);
      $output .= &addSpace(height => 5);
      $output .= &writeCommentAndResponseText(dbh => $dbh, schema => $schema, id => $id);
      $output .= &addSpace();
      $output .= &summarizedCommentsTable(dbh => $dbh, schema => $schema, summary => $id);
      $output .= &addSpace();
      $output .= &doRemarks(schema => $schema, dbh => $dbh, remark_type => 'summary comment', summary_comment => $id, show_text_box => 0);
      $output .= "</td></tr>\n";
   }
   return ($output);
}

###################################################################################################################################
sub writeHTTPHeader {
###################################################################################################################################
   print $crdcgi->header('text/html');
}

###################################################################################################################################
sub writeHead {
###################################################################################################################################
   print "<html>\n<head>\n";
   print "<meta http-equiv=expires content=now>\n";
   print "<script src=$CRDJavaScriptPath/utilities.js></script>\n";
   print "<script src=$CRDJavaScriptPath/widgets.js></script>\n";
   print "</head>\n";
}

###################################################################################################################################
sub writeBody {
###################################################################################################################################
   print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0 >\n<center>\n";
   print "<font face=$CRDFontFace color=$CRDFontColor>\n";
   $title = &getTitle(command => $command);
   print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $title);
   print "<form name=summary_comments action=$ENV{SCRIPT_NAME} method=post>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=command value=$command>\n";
   print "<input type=hidden name=id value=0>\n";
   print "<input type=hidden name=documentid value=0>\n";
   print "<input type=hidden name=commentid value=0>\n";
   print "<input type=hidden name=version value=0>\n";
   print "<input type=hidden name=summarycommentid value=0>\n";
   print "<input type=hidden name=process value=0>\n";
   print "<input type=hidden name=useFormValues value=0>\n";
   print "<input type=hidden name=response_status value=0>\n";
   print "<input type=hidden name=bin value=0>\n";
   print "<input type=hidden name=binid value=0>\n";
   print "<input type=hidden name=caller value=0>\n";
   print "<input type=hidden name=sortBy value=id>\n";
   print "<input type=hidden name=sortOrder value=ASC>\n";
   print "<input type=hidden name=concurtype value=0>\n";
   print "<table width=750 border=0>\n";
   eval {
      print &drawPage(command => $command);
   };
   &processError(activity => 'draw summary comment page') if ($@);
   print "</table>\n";
   print "<script language=javascript>\n<!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n" if ($errorstr);
   print "</form>\n";
   print &BuildPrintCommentResponse($username, $userid, $schema, $path);
   print &BuildPrintSummaryCommentResponse($username, $userid, $schema, $path);
   print "</font></center>\n</body>\n</html>\n";
}

################################################################################################################################
$dbh = db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;
&writeHTTPHeader();
if ($process) {
   &processSubmittedData();
} else {
   &writeHead();
   &writeBody();
}
db_disconnect($dbh);
exit();
