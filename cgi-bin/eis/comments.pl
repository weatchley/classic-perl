#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/atchleyb/rcs/crd/perl/RCS/comments.pl,v $
#
# $Revision: 1.34 $
#
# $Date: 2008/01/18 00:50:00 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: comments.pl,v $
# Revision 1.34  2008/01/18 00:50:00  atchleyb
# CREQ00052 - fix problem with change of copyComments
#
# Revision 1.33  2002/02/21 00:40:58  mccartym
# remove use of named parameters on CGI calls
#
# Revision 1.32  2001/10/05 15:31:28  mccartym
# truncate long summary comment titles in rebin dropdown
#
# Revision 1.31  2001/10/04 17:50:16  mccartym
# add count of duplicates on browse comment display
#
# Revision 1.30  2001/10/01 18:41:57  mccartym
# fix problem with document, user links and back button
#
# Revision 1.29  2001/09/24 22:35:00  mccartym
# Set response status to 14 in response_version when entering a duplicate comment
#
# Revision 1.28  2001/05/18 01:49:16  mccartym
# use document specific review names
#
# Revision 1.27  2001/04/27 21:31:56  atchleyb
# added the text box resize function to all text boxes
# added the summaryapproved flag to browse
#
# Revision 1.26  2001/04/27 00:01:41  atchleyb
# added hasissues flag to update and browse
#
# Revision 1.25  2001/04/26 21:48:44  mccartym
# checkpoint
#
# Revision 1.24  2000/02/22 20:04:02  mccartym
# change rebin error messages
#
# Revision 1.23  2000/02/22 18:10:03  mccartym
# add rebin function
#
# Revision 1.22  2000/02/10 17:28:26  atchleyb
# removed form-veryfy.js
#
# Revision 1.21  2000/02/07 22:28:53  atchleyb
# remade bug fix that was made in 1.18                   $changeControlNumber =~ s/'/''/g;
#
# Revision 1.20  2000/01/14 23:35:34  atchleyb
# reverted to production version 1.17 to make required changes in a working version
# replaced all references to EIS with $crdtype
# changed file paths to use $CRDFullDocPath
# changed getbracketedimage to file_utilities.pl
#
# Revision 1.17  1999/11/22 19:24:51  fergusoc
# update comment has locked section, added enable features so values are
# retained in fields after remarks submit or arrow press, fixed text
# processing errors w.r.t. %27 and single quotes, added summary comment
# so is displayed on browse screen, turned log activity off for data
# fetch on browse, delete and update (initial) screens.
#
#
# Revision 1.16  1999/11/04 00:24:27  fergusoc
# finished update function
#
# Revision 1.15  1999/10/28 22:55:34  fergusoc
# many changes, using eis change stuff, returning to same screen
# on enter, changed where javascript is placed, duplicate
# processing, added summary function to update screen.
#
# Revision 1.14  1999/10/07 20:54:01  fergusoc
# fixed enter screen, stay on enter until all comments entered checked
#
# Revision 1.13  1999/10/07 16:46:37  fergusoc
# fixed changeControlNumber field bug
#
# Revision 1.12  1999/10/07 02:02:23  fergusoc
# fixed javascript to check changeControlNumber existence
#
# Revision 1.11  1999/10/07 01:15:22  fergusoc
# changed wording for comments entered box on enter screen,
# removed javascript check on changeControlNumber, fixed remarks bug
# on update screen
#
# Revision 1.10  1999/10/05 20:39:23  fergusoc
# fixed confirm box error, proofread fix
#
# Revision 1.9  1999/10/05 18:34:36  fergusoc
# fixed dup/sim handling in proofread, added confirm box to enter
# comments when no text entered, fixed date problem
#
# Revision 1.8  1999/10/04 16:59:55  fergusoc
# update functional, modified remarks call in accord with changes
# to remarks subroutine
#
# Revision 1.7  1999/09/28 23:44:35  fergusoc
# fixed remarks, changecontrol fields from entering nulls
#
# Revision 1.6  1999/09/28 17:06:40  fergusoc
# fixed activity/error log bugs
#
# Revision 1.5  1999/09/27 17:53:54  fergusoc
# added more functionality to enter - pop up alert box if comment
# is not found, added last comment from document checkbox, enter,
# moved loading image code to process section
#
# Revision 1.4  1999/09/15 00:47:37  fergusoc
# added red text saying under development to update section
#
# Revision 1.3  1999/09/15 00:13:16  fergusoc
# further changes to format, finished browse function, half of update
# screen done.
#
# Revision 1.1  1999/08/11 00:15:57  fergusoc
# Initial revision
#
#

use integer;
use strict;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DataObjects qw(:Functions);
use DocumentSpecific qw(:Functions);
use Comments qw(:Functions);
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

my $reporttype = $crdcgi->param("id") unless ($command ne 'report');
my $documentid = $crdcgi->param("id") unless ($command eq 'report');
$documentid = $documentid - 0 if ($documentid);
my $commentid = $crdcgi->param("commentid");
$commentid = $commentid - 0 if ($commentid);
my $process = $crdcgi->param("process");
my $useFormValues = defined($crdcgi->param("useFormValues")) ? 1 : 0;
$process = 'enter' if ($command eq 'enter');

my $output = '';
my $instructionsColor = $CRDFontColor;
my $textRows = 8;
my $textColumns = 90;
my $errorstr = "";
my $dateFormat = 'DD-MON-YY HH24:MI:SS';
my $useLinks = 1;
my $enableAllFunction = "";
my $secondReviewName = &SecondReviewName();

tie my %sections, "Tie::IxHash";
%sections = (
   'browse' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 1,
      'header' => 'Browse Comment'
   },
   'update' => {
      'privilege' => [ 10 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 2,
      'header' => 'Update Comment',
      'instructions' => "Press the button below after making all required additions and corrections.  This updates the record."
   },
   'delete' => {
      'privilege' => [ 10 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 3,
      'header' => 'Delete Comments',
      'instructions' => "Press the 'Submit' button after reviewing the document information. This action deletes the bracketed image and comments associated with the comment document."
   },
   'report' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 4,
      'header' => 'Comments Report'
   },
   'information' => {
      'privilege' => [ 1 ],
      'enabled' => 1,
      'defaultOpen' => 1,
      'title' => 'General Information'
   },
   'remarks' => {
      'privilege' => [ 1 ],
      'enabled' => 1,
      'defaultOpen' => 0,
      'title' => 'Remarks'
   },
   'instructions' => {
      'privilege' => [ 1 ],
      'enabled' => 1,
      'defaultOpen' => 0,
      'title' => 'Instructions'
   },
   'entercomment' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 5,
      'title' => 'Enter Comment',
      'header' => 'Enter Comment',
      'instructions' => "Press the button below after all data entry is complete.  This will enter the comment record into the database and add it to the list of records awaiting proofreading."
   },
   'proofread' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 6,
      'title' => 'Proofread Comment',
      'header' => 'Proofread Comment',
      'instructions' => "Press the button below after making all required additions and corrections.  This updates the record, marks it as having been verified for correctness, and releases it to the response team bin coordinator."
   },
   'browsecomment' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 1,
      'title' => 'Detailed Comment Information',
   },
   'updatecomment' => {
      'privilege' => [ 10 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 7,
      'title' => 'Update Comment',
      'header' => 'Update Comment',
      'instructions' => "Press the button below after making all required additions and corrections.  This updates the record."
   },
   'deletecomment' => {
      'privilege' => [ 10 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 8,
      'title' => 'Delete Comments',
      'header' => 'Delete Comments',
      'instructions' => ""
   },
   'rebin' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 9,
      'header' => 'Rebin/Resummarize Comment',
      'instructions' => "Enter the id of the comment to be rebinned, then press 'Go'."
   },
   'rebincomment' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 10,
      'title' => 'Rebin Comment',
      'header' => 'Rebin/Resummarize Comment',
      'instructions' => "Select the new bin from the list, then press 'Submit'."
   },
   'markduplicate' => {
      'privilege' => [ 1 ],
      'enabled' => 0,
      'defaultOpen' => 0,
      'pageNum' => 11,
      'header' => 'Mark Comment as Duplicate',
      'instructions' => "Enter the id of the comment to be marked as a duplicate, then press 'Go'."
   }
);

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
      $out = "<a href=javascript:displayCommentor($commentor) title='$prompt'>$title $firstName $middleName $lastName $suffix</a>";
   }
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
sub rebinComment {                                                                                                                #
###################################################################################################################################
   my %args = (
      isDuplicate => 0,
      @_,
   );
   my $relateDocument = "document = $args{documentid}";
   my $relateComment = $relateDocument . " and commentnum = $args{commentid}";
   my $oldscr = (defined($args{oldSCR})) ? $args{oldSCR} : 0;
   my $newscr = (defined($args{newSCR})) ? $args{newSCR} : 0;
   my $newscrString = ($newscr) ? ", summary = $newscr" : "";
   $dbh->do("UPDATE $schema.comments SET summaryapproved = 'F', bin = $args{newBin} $newscrString WHERE $relateComment");
   my $id = &formatID($CRDType, 6, $args{documentid}) . " / " . &formatID("", 4, $args{commentid});
   my ($oldcoord) = $dbh->selectrow_array ("select coordinator from $schema.bin where id = $args{oldBin}");
   my ($newcoord) = $dbh->selectrow_array ("select coordinator from $schema.bin where id = $args{newBin}");
   my ($text, $addlText, $status, $responseWriter) = ("Rebinned $args{fromTo}", "", 0, "");
   if ($args{isDuplicate}) {
      my $origID = &formatID($CRDType, 6, $args{origDocument}) . " / " . &formatID("", 4, $args{origComment});
      $addlText = " as duplicate of $origID.";
   } else {
      my ($version) = $dbh->selectrow_array ("select max(version) from $schema.response_version where $relateComment");
      my $relateResponseVersion = $relateComment . " and version = $version";
      ($status, $responseWriter) = $dbh->selectrow_array ("select status, responsewriter from $schema.response_version where $relateResponseVersion");
      my ($statusName) = $dbh->selectrow_array ("select name from $schema.response_status where id = $status");
      $addlText = ".\nCurrent response development status is $statusName.";
      if ($status == 1) {
         $dbh->do("UPDATE $schema.response_version SET responsewriter = $newcoord WHERE $relateResponseVersion");
      } elsif ($status == 2) {
         #
         #  If the two bin coordinators are different, and/or the assigned writer or at least one of the assigned reviewers are not in
         #  the new bin, set the response status back to BIN COORDINATOR ASSIGN and delete all tech review assignments.  Otherwise just
         #  rebin, keeping the existing writer and review assignments.  Explain in the generated comment remark what was done.
         #
         my $allInNewBin = 1;
         my ($count) = $dbh->selectrow_array ("SELECT count(*) from $schema.default_tech_reviewer WHERE reviewer = $responseWriter and bin = $args{newBin}");
         if ($count == 0) {
            $allInNewBin = 0;
         } else {
            my $sql = "SELECT reviewer from $schema.technical_reviewer WHERE $relateComment";
            my $csr = $dbh->prepare($sql);
            $csr->execute;
            while (my ($reviewer) = $csr->fetchrow_array) {
               my ($count) = $dbh->selectrow_array ("SELECT count(*) from $schema.default_tech_reviewer WHERE reviewer = $reviewer and bin = $args{newBin}");
               $allInNewBin = 0 if ($count == 0);
            }
            $csr->finish;
         }
         if ($allInNewBin && ($newcoord == $oldcoord)) {
            $addlText = ".\nCurrent response status is $statusName - no response text has yet been entered.\n";
            $addlText .= "Existing writer and reviewer assignments have been preserved as both bins have the same coordinator and all of the assignees are active in the new bin.";
         } else {
            $addlText = ".\nResponse status was reset from $statusName to BIN COORDINATOR ASSIGN - no response text had yet been entered.\n";
            $addlText .= "Existing writer and reviewer assignments were deleted - the new bin has a different coordinator and/or one or more of the assignees are not active in the new bin.";
            $dbh->do("UPDATE $schema.response_version SET responsewriter = $newcoord, status = 1 WHERE $relateResponseVersion");
            $dbh->do("DELETE from $schema.technical_reviewer WHERE $relateComment");
         }
      } elsif (($status == 15) && ($newscr)) {
         my $oldSCRformattedID = &formatID("SCR", 4, $oldscr);
         my $newSCRformattedID = &formatID("SCR", 4, $newscr);
         $addlText .= "\nRe-summarized from $oldSCRformattedID to $newSCRformattedID.";
      }
   }
   my $sqlinsert = "insert into $schema.comments_remark (document, commentnum, remarker, dateentered, text) values ($args{documentid}, $args{commentid}, $userid, SYSDATE, :text)";
   my $csr = $dbh->prepare($sqlinsert);
   $csr->bind_param(":text", "$text$addlText", { ora_type => ORA_CLOB, ora_field => 'text'});
   $csr->execute;
   return ($status);
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
sub getCommentNumber {                                                                                                            #
###################################################################################################################################
   my $documentid = $_[0];
   my $returnvalue = 0;
   my $maxcomment = $dbh->selectrow_array ("SELECT MAX(commentnum) FROM $schema.comments WHERE (document = $documentid)");
   my $maxcommententry = $dbh->selectrow_array ("SELECT MAX(commentnum) FROM $schema.comments_entry WHERE (document = $documentid)");
   $maxcomment = 0 unless ($maxcomment);
   $maxcommententry = 0 unless ($maxcommententry);
   if ($maxcomment > $returnvalue)  {
      $returnvalue = $maxcomment;
   }
   if ($maxcommententry > $returnvalue) {
      $returnvalue = $maxcommententry;
   }
   $returnvalue = $returnvalue + 1;
   return ($returnvalue);
}

###################################################################################################################################
sub getLookupValues {                                                                                                             #
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
sub writeRadioBox {                                                                                                               #
###################################################################################################################################
   my %args = (
      name => 'radioBox',
      height => 25,
      useForm => $useFormValues,
      @_,
   );
   tie my %buttons, "Tie::IxHash";
   %buttons = %{$args{buttons}};
   my $saved = $crdcgi->param($args{name});
   my $checked;
   my $output = "";
   foreach my $button (keys (%buttons)) {
      if ($button eq $args{default}) {
         $checked = (!$args{useForm} || ($saved eq $button)) ? 'checked' : '';
      } else {
         $checked = ($args{useForm} && ($saved eq $button)) ? 'checked' : '';
      }
      $output .= "<tr><td height=$args{height}><input type=radio name=$args{name} value=$button $checked>" . &nbspaces(2) . "<b>$buttons{$button}</b></td></tr>\n";
   }
   return ($output);
}

###################################################################################################################################
sub writeBin {                                                                                                                    #
###################################################################################################################################
   my $bin = $_[0];
   my $prefix = $_[1];
   tie my %binlookup, "Tie::IxHash";
   %binlookup = get_lookup_values($dbh, $schema, 'bin', 'id', 'name', '1=1 order by name');
   my $output .= "<tr><td valign=middle height=40><b>$prefix Bin:</b>&nbsp;&nbsp; \n";
   $output .= build_drop_box('bin', \%binlookup, $bin );
   $output .= "</td></tr> \n\n";
   return ($output);
}

###################################################################################################################################
sub processError {                                                                                                                #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $error = &errorMessage($dbh, $username, $userid, $schema, $args{activity}, $@) . "\n";
   $error .=  ('-' x 80) . "\n\n" if ($errorstr ne "");
   $error =~ s/\n/\\n/g;
   $error =~ s/'/%27/g;
   $errorstr .= $error;
}

###################################################################################################################################
sub getBinName {                                                                                                                  #
###################################################################################################################################
   my @row = $dbh->selectrow_array ("select b.id, b.name from $schema.bin b, $schema.comments c where b.id = c.bin and c.document = $_[0] and c.commentnum = $_[1]");
   return (@row);
}

###################################################################################################################################
sub getDocType {                                                                                                                  #
###################################################################################################################################
   my @row = $dbh->selectrow_array ("SELECT documenttype FROM $schema.document WHERE id = $_[0]");
   my $name = $dbh->selectrow_array ("SELECT name FROM $schema.document_type WHERE id = @row");
   return ($name);
}

###################################################################################################################################
sub getEntryInfo {                                                                                                                #
###################################################################################################################################
   my @row = $dbh->selectrow_array ("SELECT createdby, to_char(datecreated,'$dateFormat') FROM $schema.comments_entry WHERE document = $_[0] and commentnum = $_[1]");
   return (@row);
}

###################################################################################################################################
sub getCommentInfo {                                                                                                              #
###################################################################################################################################
   my @row = $dbh->selectrow_array ("SELECT createdby, to_char(datecreated,'$dateFormat') FROM $schema.comments WHERE document = $_[0] and commentnum = $_[1]");
   return (@row);
}

###################################################################################################################################
sub getProofreadInfo {                                                                                                            #
###################################################################################################################################
   my $document = $_[0];
   my $comment = $_[1];
   my @row;
   @row = $dbh->selectrow_array ("SELECT proofreadby, to_char(proofreaddate,'$dateFormat') FROM $schema.comments WHERE document = $document and commentnum = $comment");
   return (@row);
}

###################################################################################################################################
sub processDupDocument {                                                                                                          #
###################################################################################################################################
   my $document = $_[0];
   my $rows;
   my $message;
   my $commentsentered = $dbh->selectrow_array ("SELECT commentsentered FROM $schema.document WHERE id=$document");
   if ($commentsentered eq 'T') {
      $rows= $dbh->selectrow_array ("SELECT count(*) FROM $schema.comments_entry WHERE document=$document");
      if ($rows == 0) {
         my $dupStatus = 'SIMILAR';
         my $dupStatusValue;
         my %dupStatusValues = %{&getLookupValues(dbh => $dbh, schema => $schema, table => 'duplication_status')};
         while (my ($id, $value) = each(%dupStatusValues)) {
            $dupStatusValue = $id if ($value eq $dupStatus);
         }
         $rows = $dbh->selectrow_array ("SELECT count(*) FROM $schema.document WHERE dupsimstatus = $dupStatusValue and dupsimid = $document");
         if ($rows) {
            my $dupDocId;
            my $csr1 = $dbh->prepare("SELECT id FROM $schema.document WHERE dupsimstatus = $dupStatusValue and dupsimid = $document");
            $csr1->execute;
            while (my @values = $csr1->fetchrow_array) {
               $dupDocId = $values[0];
               #&copyComments(dbh => $dbh, schema => $schema, userId => $userid, duplicateDocument => $dupDocId, parentDocument => $document);
               &createDupCommentsForSimilarDocument(dbh => $dbh, schema => $schema, userId => $userid, duplicateDocument => $dupDocId, parentDocument => $document);
            }
            $csr1->finish;
            $message .= "Duplicate comments created. \n\n";
            my $activity = "created set of duplicate comments for document $document";
            &log_activity ($dbh, $schema, $userid, $activity);
         } else {
            $message .= "No duplicate comments created. \n\n";
         }
      }
   }
}

###################################################################################################################################
sub writeJavascript { #for proofread and enter                                                                                    #
###################################################################################################################################
   my $outputstring;
   $outputstring .= <<end;
   <script language=javascript>
   <!--
      function setType(object) {
         if (object[0].checked) {
            setDuplicate();
         } else {
            setOriginal();
         }
      }
      function setDuplicate() {
         document.$form.dupsimstatus.value = 2;
         document.$form.text.disabled = true;
         document.$form.changeControlNumber.disabled = true;
         document.$form.bin.disabled = true;
         document.$form.changeImpact.disabled = true;
         document.$form.dupDocument.disabled = false;
         document.$form.dupComment.disabled = false;
      }
      function setOriginal() {
         document.$form.dupsimstatus.value = 1;
         document.$form.text.disabled = false;
         document.$form.changeControlNumber.disabled = false;
         document.$form.bin.disabled = false;
         document.$form.changeImpact.disabled = false;
         document.$form.dupDocument.disabled = true;
         document.$form.dupComment.disabled = true;
      }
      function setEnabled() {
         document.$form.text.disabled = false;
         document.$form.changeControlNumber.disabled = false;
         document.$form.bin.disabled = false;
         document.$form.changeImpact.disabled = false;
         document.$form.dupDocument.disabled = false;
         document.$form.dupComment.disabled = false;
      }
      function verifyEntry(command) {
         var msg = '';
         var confirmText = '';

         if (command == 'entercomment') {
            if ((isNaN(document.$form.enterCommentId.value - 0)) || (document.$form.enterCommentId.value <= 0) || (document.$form.enterCommentId.value > 9999)) {
               msg += "Invalid Comment ID \\n";
            }
         } else if (command == 'proofread') {
            if ((isNaN(document.$form.commentid.value - 0)) || (document.$form.commentid.value <= 0) || (document.$form.commentid.value > 9999)) {
               msg += "Invalid Comment ID \\n";
            }
         }
         if ((isNaN(document.$form.startpage.value - 0)) || (document.$form.startpage.value <= 0) || (document.$form.startpage.value > 99999)) {
            msg += "Invalid Start Page \\n";
         }
         msg += checkChangeControl();
         if ($form.enterRadioBox[0].checked == true) {
            $form.dupsimstatus.value = 2;
            if ((isNaN(document.$form.dupComment.value - 0)) || (document.$form.dupComment.value <= 0) || (document.$form.dupComment.value > 9999)) {
               msg += "Please Enter a Valid Duplicate Comment ID \\n";
            }
            if ((isNaN(document.$form.dupDocument.value - 0)) || (document.$form.dupDocument.value <= 0) || (document.$form.dupDocument.value > 999999)) {
               msg += "Please Enter a Valid Duplicate Document ID \\n";
            }
         }  else {
            $form.dupsimstatus.value = 1;
            if ($form.text.value == '') {
               if ($form.commentsentered.checked != true) {
                  msg += "Please Enter Comment Text \\n";
               } else {
                  confirmText += "You left the comment text blank and checked 'No (more) comments to enter'.  \\nBy doing this you will end comment data entry for this document. \\n\\nIs this what you really want to do?";
               }
            }
         }
         if (msg != '') {
            alert (msg);
         } else if (confirmText != '') {
            if (confirm(unescape(confirmText))) {
               document.$form.process.value = command;
               document.$form.useFormValues.value = 0;
               submitForm('$form', command, 'cgiresults');
            }
         } else {
            document.$form.process.value = command;
            document.$form.useFormValues.value = 0;
            submitForm('$form', command, 'cgiresults');
         }
      }
   //-->
   </script>
end
   return ($outputstring);
}

###################################################################################################################################
sub processSubmittedData {                                                                                                        #
###################################################################################################################################
   print $crdcgi->header('text/html');
   print "<html>\n<head>\n</head>\n<body>\n";
   my $message = "";
   my $popMessage = 0;
   my $activity = "";
   my $confirm = "";
   my $logActivity = 0;
   my $error = "";
   eval {
   ###################################################################################################################################
   if ($process eq 'enter') {
   ###################################################################################################################################
      my $formatid = &formatID($CRDType, 6, $documentid);
      $activity = "check if image loaded for Document $formatid";
      #######################
      ##find out if image has been loaded into the database yet...
      #######################
      my @row = $dbh->selectrow_array("SELECT count(*) FROM $schema.document WHERE id=$documentid AND image IS NOT NULL");
      #######################
      ##if no image in the database, see if it exists so we can load it
      ##if doesn't exist, get text saying doesn't exist
      #######################
      my $remote_path = $CRDType . '_CD_Images\\\\Bracketed';
      if (!($CRDProductionStatus)) {$remote_path = $CRDType . '_CD_Images\\\\DevBracketed';}
      #my $filename = $ENV{DOCUMENT_ROOT}.$CRDDocPath."/".$formatid.".pdf";
      my $filename = $CRDFullDocPath."/".$formatid.".pdf";
      my $status=2;
      if (($row[0] == 0) &&  (!(-e $filename))) {
         $status=-1;
         #$status = &getBracketedImageFile(image_file => $formatid.".pdf", local_path => $CRDFullDocPath, remote_path => $remote_path);
         if (open (FH2, "./File_Utilities.pl --command=sambaCopy --localPath=$CRDFullDocPath --remotePath=$remote_path --imageFile=$formatid.pdf --localFile=$formatid.pdf --protection=0777 |")) {
             $status = <FH2>;
             close FH2;
         }
      }
      if ($status == 0) {
         $error = "The image for Comment Document $formatid (with comments bracketed) \n has not been loaded. \n\nIf the comments have been bracketed and the image is ready to load, \nplace the image in the appropriate directory and start over.";
      } elsif ($status == -1){
         $error = "Error loading image for Comment Document $formatid ";
      } elsif (($status == 1) || ($row[0] == 1) || (-e $filename)) {
         if ($row[0] == 0) {
            open FH1, "<$filename";
            my $sqlquery = "update $schema.document set image = ? where id = $documentid";
            my $val = "";
            my $rc = read(FH1, $val, 100000000);
            close FH1;
            my $csr = $dbh->prepare($sqlquery);
            $csr->bind_param(1, $val, { ora_type=>ORA_BLOB, ora_field=>'image'});
            $csr->execute;
            $dbh->commit;
         }
      }
      $command = 'entercomment';
   ###################################################################################################################################
   } elsif ($process eq 'entercomment') {
   ###################################################################################################################################
      my $formatid = &formatID($CRDType, 6, $documentid);
      my $document = $documentid;
      my $commentnum = $crdcgi->param("enterCommentId");
      my $text = $crdcgi->param("text");
      $text =~ s/%27/'/g if ($text);
      my $startpage = $crdcgi->param("startpage");
      my $changeImpact = $crdcgi->param("changeImpact");
      my $changeControlNumber = $crdcgi->param("changeControlNumber");
      my $createdby = $userid;
      my $entryRemarks = $crdcgi->param("entryRemarks");
      $entryRemarks =~ s/%27/'/g if ($entryRemarks);
      my $bin = $crdcgi->param("bin");
      my $dupsimstatus = $crdcgi->param("dupsimstatus");
      my $dupComment = $crdcgi->param("dupComment");
      my $dupDocument = $crdcgi->param("dupDocument");
      my $commentsentered = $crdcgi->param("commentsentered");
      if ($text || ($dupsimstatus == 2)) {
         $activity = "enter comment ".$commentnum." from comment document " . &formatID($CRDType, 6, $documentid) . " ";
      } else {
         $activity = "set commentsentered for document " . &formatID($CRDType, 6, $documentid);
      }
      my @row;
      if ($dupsimstatus == 2) {
         @row = $dbh->selectrow_array("SELECT count(*) FROM $schema.comments WHERE document=$dupDocument and commentnum=$dupComment");
         if ($row[0] == 0) {
            $error = "Duplicate comment does not exist."
         } else {
            my $sqlquery = "SELECT text, changeimpact, changecontrolnum, bin FROM $schema.comments WHERE document=$dupDocument and commentnum=$dupComment";
            $dbh->{LongTruncOk} = 0;
            my $csr = $dbh->prepare($sqlquery);
            $csr->execute;
            while (my @values = $csr->fetchrow_array) {
               ($text, $changeImpact, $changeControlNumber, $bin) = @values;
            }
            $csr->finish;
         }
      }
      $changeControlNumber =~ s/'/''/g;
      if (($dupsimstatus == 1) || ($row[0] != 0)) {
         if ($text || ($dupsimstatus == 2)) {
            $dupDocument = "NULL" unless ($dupDocument);
            $dupComment = "NULL" unless ($dupComment);
            my $sqlinsert = "INSERT INTO $schema.comments_entry (document, commentnum, text, startpage, changeimpact, changecontrolnum, createdby, datecreated, bin, dupsimstatus, dupsimdocumentid, dupsimcommentid) VALUES ($document, $commentnum, :text, $startpage, $changeImpact, ";
            $sqlinsert .= ($changeControlNumber) ? "'$changeControlNumber', " : "NULL, ";
            $sqlinsert .= "$createdby, SYSDATE, ";
            $sqlinsert .= "$bin, $dupsimstatus, $dupDocument, $dupComment)";
            my $csr = $dbh->prepare($sqlinsert);
            $csr->bind_param(":text", $text, { ora_type => ORA_CLOB, ora_field => 'text'});
            $csr->execute;
            if ($entryRemarks) {
               $csr = $dbh->prepare("UPDATE  $schema.comments_entry SET remarks = :entryRemarks  WHERE document = $document and commentnum = $commentnum");
               $csr->bind_param(":entryRemarks", $entryRemarks, {ora_type => ORA_CLOB, ora_field => 'remarks'});
               $csr->execute;
            }
            $message .= "Comment Entry Successful on " . $formatid . " Comment " . $commentnum . "\n";
            $popMessage = 1;
         }
         if ($commentsentered) {
            my $sqlupdate = $dbh->do("UPDATE $schema.document SET commentsentered = 'T' WHERE id = $document");
            $message .= &formatID($CRDType, 6, $documentid) . " flagged as having no (more) comments";
            &processDupDocument($documentid) unless ($text);
            $form = 'home';
            $process = 0;
            $popMessage = 1;
         }
         $dbh->commit;
         $logActivity = 1;
      }
   ###################################################################################################################################
   } elsif ($process eq 'saveRemark') {
   ###################################################################################################################################
      my $text = $crdcgi->param('remarktext');
      my $csr;
      if (($command eq 'updatecomment') || ($command eq 'rebincomment')) {
         $activity = "save remark on document " . &formatID($CRDType, 6, $documentid) . " comment ". $commentid;
         $csr = $dbh->prepare("INSERT INTO $schema.comments_remark (document, commentnum, remarker, dateentered, text) VALUES ($documentid, $commentid, $userid, SYSDATE, :param)");
      } else {
         $activity = "save remark on document " . &formatID($CRDType, 6, $documentid);
         $csr = $dbh->prepare("INSERT INTO $schema.document_remark (document, remarker, dateentered, text) VALUES ($documentid, $userid, SYSDATE, :param)");
      }
      $csr->bind_param(":param", $text, {ora_type => ORA_CLOB, ora_field => 'text'});
      $csr->execute;
      $dbh->commit;
      $crdcgi->delete('remarktext');
      $logActivity = 1;
   ###################################################################################################################################
   } elsif ($process eq 'proofread') {
   ###################################################################################################################################
      $activity = "proofread comment ".$commentid." from comment document " . &formatID($CRDType, 6, $documentid);
      my $text = $crdcgi->param("text");
      $text =~ s/%27/'/g if ($text);
      my $startpage = $crdcgi->param("startpage");
      my $changeImpact = $crdcgi->param("changeImpact");
      my $changeControlNumber = $crdcgi->param("changeControlNumber");
      my $createdby = $crdcgi->param("createdby");
      my $datecreated = $crdcgi->param("datecreated");
      my $proofreadby = $userid;
      my $bin = $crdcgi->param("bin");
      my $doereviewer;
      my $dupsimstatus = $crdcgi->param("dupsimstatus");
      my $dupDocument = $crdcgi->param("dupDocument");
      my $dupComment = $crdcgi->param("dupComment");
      my $dupDupsimstatus;
      my $dupDupDocument;
      my $dupDupComment;
      my $newremarks = $crdcgi->param("newremarks");
      $newremarks =~ s/%27/'/g if ($newremarks);
      my $oldremarks = $crdcgi->param("remarks");
      $oldremarks =~ s/%27/'/g if ($oldremarks);
      my @row;
      if ($dupsimstatus == 2) {
         @row = $dbh->selectrow_array("SELECT count(*) FROM $schema.comments WHERE document=$dupDocument and commentnum=$dupComment");
         if ($row[0] == 0) {
            $error = "Duplicate comment does not exist."
         } else {
            my $sqlquery = "SELECT text, changeimpact, changecontrolnum, bin, doereviewer, dupsimdocumentid, dupsimcommentid FROM $schema.comments WHERE document=$dupDocument and commentnum=$dupComment";
            $dbh->{LongTruncOk}=0;
            my $csr = $dbh->prepare($sqlquery);
            $csr->execute;
            while (my @values = $csr->fetchrow_array) {
               ($text, $changeImpact, $changeControlNumber, $bin, $doereviewer, $dupDupDocument, $dupDupComment) = @values;
            }
            $csr->finish;
         }
      }
      $changeControlNumber =~ s/'/''/g;
      if (($dupsimstatus == 1) || ($row[0] == 1)) {
         $dupDocument = ($dupDupDocument) ? $dupDupDocument : $dupDocument;
         $dupComment = ($dupDupComment) ? $dupDupComment : $dupComment;
         $dupDocument = "NULL" unless ($dupDocument);
         $dupComment = "NULL" unless ($dupComment);
         my $sqlinsert = "INSERT INTO $schema.comments (document, commentnum, text, startpage, dateassigned, datedue, dateapproved, changeimpact, changecontrolnum, createdby, datecreated, proofreadby, proofreaddate, bin, doereviewer, summary, dupsimstatus, dupsimdocumentid, dupsimcommentid) VALUES ($documentid, $commentid, :text, $startpage, NULL, NULL, NULL, $changeImpact, ";
         $sqlinsert .= ($changeControlNumber) ? "'$changeControlNumber', " : "NULL, ";
         $sqlinsert .= "'$createdby',  to_date('$datecreated','$dateFormat'), '$proofreadby', SYSDATE, '$bin', '$doereviewer', NULL, '$dupsimstatus', $dupDocument, $dupComment)";
         my $csr = $dbh->prepare($sqlinsert);
         $csr->bind_param(":text", $text, { ora_type => ORA_CLOB, ora_field => 'text' });
         $csr->execute;
         if ($oldremarks) {
            $sqlinsert = "INSERT INTO $schema.comments_remark (document, commentnum, remarker, dateentered, text) VALUES ($documentid, $commentid, $createdby, to_date('$datecreated','$dateFormat'), :oldremarks )";
            $csr = $dbh->prepare($sqlinsert);
            $csr->bind_param(":oldremarks", $oldremarks, { ora_type => ORA_CLOB, ora_field => 'text' });
            $csr->execute;
         }
         if ($newremarks gt '') {
            $sqlinsert = "INSERT INTO $schema.comments_remark (document, commentnum, remarker, dateentered, text) VALUES ($documentid, $commentid, $proofreadby, SYSDATE, :newremarks )";
            $csr = $dbh->prepare($sqlinsert);
            $csr->bind_param(":newremarks", $newremarks, { ora_type => ORA_CLOB, ora_field => 'text' });
            $csr->execute;
         }
         my $sqldelete = $dbh->do("DELETE FROM $schema.comments_entry WHERE document=$documentid and commentnum=$commentid");
         my $responsewriter = $dbh->selectrow_array("SELECT coordinator FROM $schema.bin where id=$bin");
         my $responseStatus = ($dupsimstatus == 1) ? 1 : 14;
         $sqlinsert = $dbh->do("INSERT INTO $schema.response_version (document, commentnum, version, status, enteredby, entrydate, responsewriter, dateupdated) VALUES ($documentid, $commentid, 1, $responseStatus, $createdby, SYSDATE, $responsewriter, SYSDATE)");
         &processDupDocument($documentid);
         $message = "Proofread Successful on: " . &formatID($CRDType, 6, $documentid) . " Comment " . $commentid;
         $dbh->commit;
         $logActivity = 1;
         $popMessage = 1;
         $form = 'home';
      }
   ###################################################################################################################################
   } elsif ($process eq 'update') {
   ###################################################################################################################################
      $activity = "update comment ".$commentid." from comment document " . &formatID($CRDType, 6, $documentid);
      my $text = $crdcgi->param("text");
      my $startpage = $crdcgi->param("startpage");
      my $dateassigned = $crdcgi->param("dateassigned");
      my $datedue = $crdcgi->param("datedue");
      my $dateapproved = $crdcgi->param("dateapproved");
      my $hasCommitments;
      my $changeImpact = $crdcgi->param("changeImpact");
      my $changeControlNumber = $crdcgi->param("changeControlNumber");
      my $doereviewer = $crdcgi->param("doereviewer");
      my @row;
      my $update = '';
      my $tempDocId = $documentid;
      my $tempCommentId = $commentid;

      sub updateString {
         my %args = (
            @_,
         );
         my $outputstring = "";
         if ($args{variable}) {
            $outputstring .= "'$args{variable}', ";
         } else {
            $outputstring .= "NULL, ";
         }
         return ($outputstring);
      }

      &updateDOEReviewer(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid);
      &updateHasCommitments(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid);
      &updateChangeImpact(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid);
      &updateHasIssues(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid);
      $update = "UPDATE $schema.comments SET text = :text, startpage = $startpage WHERE document = $documentid and commentnum = $commentid";
      my $csr = $dbh->prepare($update);
      $csr->bind_param(":text", $text, {ora_type => ORA_CLOB, ora_field => 'text'});
      $csr->execute;
      $csr = $dbh->prepare("SELECT document, commentnum FROM $schema.comments WHERE dupsimdocumentid=$documentid and dupsimcommentid=$commentid");
      $csr->execute;
      while (my @values = $csr->fetchrow_array) {
         $documentid = $values[0];
         $commentid = $values[1];
         &updateDOEReviewer(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid);
         &updateHasCommitments(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid);
         &updateChangeImpact(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid);
         $update = "UPDATE $schema.comments SET text = :text, summary = NULL WHERE document = $documentid and commentnum = $commentid";
         my $csr = $dbh->prepare($update);
         $csr->bind_param(":text", $text, {ora_type => ORA_CLOB, ora_field => 'text'});
         $csr->execute;
      }
      $csr->finish;
      $documentid = $tempDocId;
      $commentid = $tempCommentId;
      $crdcgi->delete('rbSetting');
      $dbh->commit;
      $logActivity = 1;
      $documentid = $tempDocId;
      $commentid = $tempCommentId;
      $message = "Update Successful on " . &formatID($CRDType, 6, $documentid) . " Comment " . $commentid;
      $popMessage = 1;
      $form = 'comments';
   ###################################################################################################################################
   } elsif ($process eq 'markduplicate') {
   ###################################################################################################################################
      my $dupDocument = $crdcgi->param("markduplicatedocumentid");
      my $dupComment = $crdcgi->param("markduplicatecommentid");
      my $documentid = $crdcgi->param("markduplicateorigdocumentid");
      my $commentid = $crdcgi->param("markduplicateorigcommentid");
      my $dup = &formatID($CRDType, 6, $dupDocument) . " / " . &formatID("", 4, $dupComment);
      my $orig = &formatID($CRDType, 6, $documentid) . " / " . &formatID("", 4, $commentid);
      $message = "$dup has been marked as a duplicate of $orig";
      $activity = "mark $dup as duplicate of $orig";
      $popMessage = 1;
      my ($count) = $dbh->selectrow_array("select count(*) from $schema.comments where document=$documentid and commentnum=$commentid");
      $error = "Comment $orig does not exist\n" if ($count == 0);
      ($count) = $dbh->selectrow_array("select count(*) from $schema.comments where document=$dupDocument and commentnum=$dupComment");
      $error .= "Comment $dup does not exist\n" if ($count == 0);
      $error .= "A comment cannot be a duplicate of itself" if (($dupDocument == $documentid) && ($dupComment == $commentid));
      ($count) = $dbh->selectrow_array("select count(*) from $schema.comments where document=$documentid and commentnum=$commentid and dupsimdocumentid=$dupDocument and dupsimcommentid=$dupComment");
      $error .= "$orig is already a duplicate of $dup\n\nTwo comments cannot be marked as duplicates of each other" if ($count);
      my $sql = "select dupsimstatus, dupsimdocumentid, dupsimcommentid from $schema.comments where document=$documentid and commentnum=$commentid";
      my ($origDupStatus, $origOrigDocument, $origOrigComment) = $dbh->selectrow_array ("$sql");
      if ($origDupStatus != 1) {
         my $origDup = &formatID($CRDType, 6, $origOrigDocument) . " / " . &formatID("", 4, $origOrigComment);
         $error .= "$orig is a duplicate of $origDup.\n\nPlease mark $dup as a duplicate of $origDup";
      }
      if (!$error) {
         $logActivity = 1;
         my ($bin) = $dbh->selectrow_array("select bin from $schema.comments where document = $documentid and commentnum = $commentid");
         $dbh->do("update $schema.comments set bin = $bin, summary = null, dateapproved = null, dupsimstatus = 2, dupsimdocumentid = $documentid, dupsimcommentid = $commentid where document = $dupDocument and commentnum = $dupComment");
         $dbh->do("update $schema.response_version set status = 14, dateupdated = SYSDATE where document = $dupDocument and commentnum = $dupComment");
         $dbh->do("update $schema.comments set bin = $bin, dupsimstatus = 2, dupsimdocumentid = $documentid, dupsimcommentid = $commentid where dupsimdocumentid = $dupDocument and dupsimcommentid = $dupComment");
      }
      $dbh->commit;
      $form = 'utilities';
   ###################################################################################################################################
   } elsif ($process eq 'delete') {
   ###################################################################################################################################
      my $formatId = &formatID($CRDType, 6, $documentid);
      $activity = "delete comments from comment document " . $formatId;
      #my $filename = $ENV{DOCUMENT_ROOT}.$CRDDocPath."/".$formatId.".pdf";
      my $filename = $CRDFullDocPath."/".$formatId.".pdf";
      #unlink($filename);
      if (open (FH2, "./File_Utilities.pl --command=deleteFile --fullFilePath=$filename |")) {
          close (FH2);
      }
      my $sqldelete = $dbh->do("DELETE FROM $schema.comments_remark WHERE document=$documentid");
      $sqldelete = $dbh->do("DELETE FROM $schema.technical_review WHERE document=$documentid");
      $sqldelete = $dbh->do("DELETE FROM $schema.technical_reviewer WHERE document=$documentid");
      $sqldelete = $dbh->do("DELETE FROM $schema.response_version WHERE document=$documentid");
      $sqldelete = $dbh->do("DELETE FROM $schema.response_version_entry WHERE document=$documentid");
      $sqldelete = $dbh->do("DELETE FROM $schema.comments_entry WHERE document=$documentid");
      $sqldelete = $dbh->do("DELETE FROM $schema.comments WHERE document=$documentid");
      my $sqlupdate = $dbh->do("UPDATE $schema.document SET image = NULL WHERE id = $documentid");
      $sqlupdate = $dbh->do("UPDATE $schema.document SET commentsentered = 'F' WHERE id = $documentid");
      $dbh->commit;
      $logActivity = 1;
      $message = "Successful deletion of comments from " . &formatID($CRDType, 6, $documentid);
      $popMessage = 1;
      $form = 'utilities';
   ###################################################################################################################################
   } elsif (($process eq 'browsecomment') || ($process eq 'updatecomment')) {
   ###################################################################################################################################
      my $id = &formatID($CRDType, 6, $documentid) . " / " . &formatID("", 4, $commentid);
      $activity = "$process - check for existence of entered comment id $id";
      my ($count) = $dbh->selectrow_array("SELECT count(*) FROM $schema.comments WHERE document=$documentid and commentnum=$commentid");
      if ($count == 0) {
         $error = "No such comment: $id";
      }
      $crdcgi->delete('enterRadioBox');
   ###################################################################################################################################
   } elsif ($process eq 'deletecomment') {
   ###################################################################################################################################
      $activity = "delete comments from " . &formatID($CRDType, 6, $documentid);
      my @row = $dbh->selectrow_array("SELECT count(*) FROM $schema.document WHERE id=$documentid");
      if ($row[0] == 0) {
         $error = "Document does not exist."
      }
   ###################################################################################################################################
   } elsif ($process eq 'rebin') {
   ###################################################################################################################################
      $crdcgi->delete('enterRadioBox');
      my $id = &formatID($CRDType, 6, $documentid) . " / " . &formatID("", 4, $commentid);
      $activity = "$process entered id $id - ";
      my $problem = "";
      my $relateDocument = "document = $documentid";
      my $relateComment = $relateDocument . " and commentnum = $commentid";
      my ($count) = $dbh->selectrow_array ("SELECT count(*) FROM $schema.comments WHERE $relateComment");
      if ($count == 0) {
         $logActivity = 1;
         $error = "Comment $id does not exist";
         $activity .= "comment does not exist";
      } elsif (!&does_user_have_priv($dbh, $schema, $userid, 6) && !&does_user_have_priv($dbh, $schema, $userid, 10)) { # user is coordinator - check if entered comment is in their bin
         my ($bin) = $dbh->selectrow_array ("select bin from $schema.comments where $relateComment");
         my ($coordinator) = $dbh->selectrow_array ("SELECT coordinator FROM $schema.bin WHERE id = $bin");
         if ($coordinator != $userid) {
            $logActivity = 1;
            $error = "Comment $id is not in your bin";
            $activity .= "comment is not in your bin";
         }
      }
      if ($error eq "") {
         my ($responseStatus, $rdupsim, $rsummary, $rdupcount, $statusName, $relateResponseVersion, $version) = (0, 1, -1, 0, "", "", 0);
         my ($dupsim, $summary) = $dbh->selectrow_array ("select dupsimstatus, NVL(summary, -1) from $schema.comments where $relateComment");
         if (($dupsim == 1) && ($summary == -1)) {
            ($version) = $dbh->selectrow_array ("select max(version) from $schema.response_version where $relateComment");
            $relateResponseVersion = $relateComment . " and version = $version";
            ($responseStatus, $rdupsim, $rsummary) = $dbh->selectrow_array ("select status, dupsimstatus, NVL(summary, -1) from $schema.response_version where $relateResponseVersion");
            ($statusName) = $dbh->selectrow_array ("select name from $schema.response_status where id = $responseStatus");
            ($rdupcount) = $dbh->selectrow_array ("select count(*) from $schema.response_version where dupsimdocumentid = $documentid and dupsimcommentid = $commentid");
         }
         if ($dupsim != 1) {  # could also check for response_version = 14
            my ($dupdoc, $dupcomment) = $dbh->selectrow_array ("select dupsimdocumentid, dupsimcommentid from $schema.comments where $relateComment");
            my $dupid = &formatID($CRDType, 6, $dupdoc) . " / " . &formatID("", 4, $dupcomment);
            $problem = "comment is duplicate of $dupid";
         } elsif ($rdupsim != 1) {
            my ($dupdoc, $dupcomment) = $dbh->selectrow_array ("select dupsimdocumentid, dupsimcommentid from $schema.response_version where $relateResponseVersion");
            my $dupid = &formatID($CRDType, 6, $dupdoc) . " / " . &formatID("", 4, $dupcomment);
            $problem = "comment is duplicate (pending) of $dupid";
         } elsif ($rsummary != -1) {
            $problem = "comment is summarized (pending) by " . &formatID('SCR', 4, $rsummary);
         } elsif ($rdupcount > 0) {  # disallow for now - marked as dup in response dev process but not yet approved by coord
            $problem = "other comment(s) are duplicates (pending) of this comment";
         } elsif ($responseStatus == 2) {  # disallow for now if not version 1 or response writer has entered text
            if ($version != 1) {
               $problem = "response in $statusName and version = $version";
            } else {
               my ($text) = $dbh->selectrow_array ("select originaltext from $schema.response_version where $relateResponseVersion");
               $problem = "response in $statusName and response text entered" if ($text ne "");
            }
         } elsif ($responseStatus == 3) {  # disallow for now
            $problem = "response in $statusName";
         } elsif ($responseStatus == 4) {  # disallow for now
            $problem = "response in $statusName";
         } elsif ($responseStatus == 6) {  # disallow for now if coordinator has entered text
            my ($text) = $dbh->selectrow_array ("select coordeditedtext from $schema.response_version where $relateResponseVersion");
            $problem = "response in $statusName and coordinator text entered" if ($text ne "");
         }
         if ($problem eq "") {
            $command = 'rebincomment';
         } else {
            $logActivity = 1;
            $activity .= $problem;
            $error = "Cannot rebin $id - $problem";
            $crdcgi->delete('id');
            $crdcgi->delete('commentid');
         }
      }
   ###################################################################################################################################
   } elsif ($process eq 'rebincomment') {
   ###################################################################################################################################
      #
      # Rebinning is:
      #
      #    always allowed in state 1 - BIN_COORDINATOR ASSIGN
      #    allowed in state 2: RESPONSE DEVELOPMENT if version 1 and the response writer has not entered text - disallow on entry otherwise
      #    never attempted in status 3 or 4 - TECHNICAL REVIEW, RESPONSE MODIFICATION - disallowed on entry
      #    always allowed in states 5, 7, 8, 9: TECHNICAL EDIT, NEPA REVIEW/APPROVAL, DOE REVIEW/APPROVAL, APPROVED
      #    allowed in state 6: BIN COORDINATOR ACCEPT if the coordinator has not entered text - disallowed on entry otherwise
      #    never attempted in 10, 11, 12, 13: reject states - always higher numbered version exists - disallowed on entry
      #    never attempted in 14: duplicate - disallowed on entry, never reach here
      #    allowed in state 15: SUMMARIZED - the destination bin must have at least on summary and the user must specify a new summary
      #
      my $id = &formatID($CRDType, 6, $documentid) . " / " . &formatID("", 4, $commentid);
      my ($oldbin, $oldscr) = $dbh->selectrow_array ("select bin, nvl(summary, 0) from $schema.comments WHERE document = $documentid and commentnum = $commentid");
      my ($oldcoord, $oldbinname) = $dbh->selectrow_array ("select coordinator, name from $schema.bin where id = $oldbin");
      my $newbin = $crdcgi->param("newbin");
      my $newscr = (defined($crdcgi->param("newscr"))) ? $crdcgi->param("newscr") : 0;
      my $oldscrString = &formatID("SCR", 4, $oldscr);
      my $newscrString = &formatID("SCR", 4, $newscr);
      my $scrString = ($newscr) ? " - re-summarized from $oldscrString to $newscrString" : "";
      my ($newcoord, $newbinname) = $dbh->selectrow_array ("select coordinator, name from $schema.bin where id = $newbin");
      my $fromToString = "from " . &getBinNumber(binName => $oldbinname) . " to " . &getBinNumber(binName => $newbinname);
      #
      #   Rebin the original
      #
      my $status = &rebinComment(documentid => $documentid, commentid => $commentid, isDuplicate => 0, oldBin => $oldbin, newBin => $newbin, fromTo => $fromToString, oldSCR => $oldscr, newSCR => $newscr);
      #
      #   Get the duplicate ID's and rebin them
      #
      my $csr = $dbh->prepare("select document, commentnum from $schema.comments where dupsimstatus = 2 and dupsimdocumentid = $documentid and dupsimcommentid = $commentid order by document, commentnum");
      $csr->execute;
      my ($dupCount, $dupString) = (0, "");
      while (my ($dupDocumentID, $dupCommentID) = $csr->fetchrow_array) {
         &rebinComment(documentid => $dupDocumentID, commentid => $dupCommentID, isDuplicate => 1, origDocument => $documentid, origComment => $commentid, oldBin => $oldbin, newBin => $newbin, fromTo => $fromToString);
         $dupString .= ", " if ($dupCount);
         $dupString .= &formatID($CRDType, 6, $dupDocumentID) . " / " . &formatID("", 4, $dupCommentID);
         $dupCount++;
      }
      $csr->finish;
      if ($dupCount) {
         my $dupStringPrefix = "(and $dupCount duplicate";
         $dupStringPrefix .= "s" if ($dupCount > 1);
         $dupString = "$dupStringPrefix: " . $dupString . ")";
      }
      #
      #  Send notification(s) only when user is sys admin and not in NEPA REVIEW/APPROVAL, DOE REVIEW/APPROVAL, APPROVED, or SUMMARIZED response status
      #
      if (&does_user_have_priv($dbh, $schema, $userid, 10) && ($status <= 6)) {
         my $text = "Rebinned comment $id $dupString $fromToString.  Please see the remarks for this comment for additional information.";
         my $csr = $dbh->prepare("insert into $schema.message (id, sentby, sentto, datesent, subject, text) values (:id, $userid, :sentto, SYSDATE, '$id rebinned', :text)");
         my ($messageid) = $dbh->selectrow_array("select $schema.message_id.nextval from dual");
         $csr->bind_param(":id", $messageid);
         $csr->bind_param(":sentto", $oldcoord);
         $csr->bind_param(":text", $text, { ora_type => ORA_CLOB, ora_field => 'text'});
         $csr->execute;
         if ($newcoord != $oldcoord) { # Only send the message to both old and new bin coordinators if they differ
            ($messageid) = $dbh->selectrow_array("select $schema.message_id.nextval from dual");
            $csr->bind_param(":id", $messageid);
            $csr->bind_param(":sentto", $newcoord);
            $csr->bind_param(":text", $text, { ora_type => ORA_CLOB, ora_field => 'text'});
            $csr->execute;
         }
      }
      $popMessage = 1;
      if ($newscr && ($oldbin == $newbin)) {
         $message = "Resummarization of $id from $oldscrString to $newscrString was successful";
         $activity = "resummarize $id from $oldscrString to $newscrString";
      } else {
         $message = "Rebinning of $id $dupString $fromToString was successful$scrString";
         $activity = "rebin $id $dupString $fromToString (bin ID $oldbin to $newbin)$scrString";
      }
      $logActivity = 1;
      $crdcgi->delete('id');
      $crdcgi->delete('commentid');
      $crdcgi->delete('newscr');
      $command = 'rebin';
   } else {
      $error .= 'process unknown command in comments script';
      $message .= 'process unknown command in comments script';
      $form = 'home';
   }
   }; # end eval
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
      if (($form eq 'comments') && ($process ne 'entercomment') && ($process ne 'update')) {
         my @paramlist = $crdcgi->param();
         foreach my $param (@paramlist) {
            my $val = ($param eq 'process') ? 0 : $crdcgi->param($param);
            $val =~ s/'/%27/g;
            $val = $commentid if ($param eq 'commentid');
            $val = $command if (($param eq 'command') && (($command eq 'entercomment') || ($command eq 'rebin') || ($command eq 'rebincomment')));
            print "<input type=hidden name='$param' value='$val'>\n";
         }
      } else {
         print "<input type=hidden name=username value=$username>\n";
         print "<input type=hidden name=userid value=$userid>\n";
         print "<input type=hidden name=schema value=$schema>\n";
         if ($process eq 'entercomment') {
            print "<input type=hidden name=command value='enter'>\n";
            print "<input type=hidden name=id value=$documentid>\n";
            print "<input type=hidden name=commentid value=$commentid>\n";
            print "<input type=hidden name=process value=0>\n";
         } elsif ($process eq 'update') {
            print "<input type=hidden name=command value='update'>\n";
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

###################################################################################################################################
sub configureSections {                                                                                                           #
###################################################################################################################################
   my $section = $_[0];
   ${$sections{$section}}{'enabled'} = 1;
   ${$sections{$section}}{'defaultOpen'} = 1;
   ${$sections{$section}}{'locked'} = 1 if (($section eq $command) && ($command ne 'browse') && ($command ne 'update') && ($command ne 'delete') && ($command ne 'rebin') && ($command ne 'markduplicate'));
   if (($section eq 'browse') || ($section eq 'update') || ($section eq 'updatecomment') || ($section eq 'delete') || ($section eq 'report') || ($section eq 'rebin') || ($section eq 'markduplicate')) {
      if (!(defined($commentid)) || ($section eq 'report')) {
         ${$sections{'information'}}{'enabled'} = 0;
         ${$sections{'remarks'}}{'enabled'} = 0;
         ${$sections{'instructions'}}{'enabled'} = 0;
      } elsif ($section eq 'browse') {
         ${$sections{'browsecomment'}}{'enabled'} = 1;
         ${$sections{'browsecomment'}}{'title'} = 'Browse ' . ${$sections{'browsecomment'}}{'title'} if ($command ne 'browse');
         ${$sections{'instructions'}}{'enabled'} = 0;
      } elsif ($section eq 'updatecomment'){
         ${$sections{'update'}}{'enabled'} = 1;
      } elsif ($section eq 'delete') {
         ${$sections{'deletecomment'}}{'enabled'} = 1;
         ${$sections{'deletecomment'}}{'title'} = 'Delete ' . ${$sections{'deletecomment'}}{'title'} if ($command ne 'delete');
      }
   }
}

###################################################################################################################################
sub doHeader {                                                                                                                    #
###################################################################################################################################
   my $section = $_[0];
   if (($section ne 'browse') && ($section ne 'update') && ($section ne 'report') && ($section ne 'delete') && ($section ne 'rebin') && ($section ne 'markduplicate')) {
      my $textColor = (${$sections{$section}}{'locked'}) ? '#ff0000' : '#000060';
      $output .= "<tr><td><a name=$section></a><table width=100% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellspacing=0 cellpadding=0><tr>\n";
      $output .= "<td align=center bgcolor=#f3f3f3 width=22>" . &sectionImageTag($section) . "</td>\n";
      $output .= "<td height=23 bgcolor=#f3f3f3><font face=arial color=$textColor><b>" . &nbspaces(2) . "${$sections{$section}}{'title'}</b></font></td>\n";
      $output .= "</tr></table>\n</td></tr>\n";
      $output .= "<tr><td height=15> </td></tr>\n\n";
   }
}

###################################################################################################################################
sub doSection {                                                                                                                   #
###################################################################################################################################
   my $section = $_[0];
   $output .= "<tr><td align=right>\n";
   $output .= "<table width=750 border=0>\n";
   my $error = "";
   my $activity = "";
   eval {
   ###################################################################################################################################
   if ($section eq 'browse') {                                                                                            #  Browse  #
   ###################################################################################################################################
   if (&sectionIsOpen($section)) {
   $output .= <<end;
   <script language=javascript>
   <!--
      function browse_comment () {
         if ((isNaN(document.$form.browsecommentid.value - 0) || (document.$form.browsecommentid.value <= 0) || (document.$form.browsecommentid.value > 9999))) {
            alert('Invalid Comment ID');
         } else if ((isNaN(document.$form.browsedocumentid.value - 0) || (document.$form.browsedocumentid.value <= 0) || (document.$form.browsedocumentid.value > 999999))) {
               alert('Invalid Comment Document ID');
         } else {
            document.$form.id.value = document.$form.browsedocumentid.value;
            document.$form.commentid.value = document.$form.browsecommentid.value;
            document.$form.command.value = 'browse';
            document.$form.action = '$path' + 'comments' + '.pl';
            document.$form.target = 'main';
            document.$form.process.value = 'browsecomment';
            document.$form.target = 'cgiresults';
            document.$form.submit();
         }
      }
   //-->
   </script>
end
      $activity = "retrieve comment information for browse";
      $output .= "</table></td></tr>\n\n<tr><td align=center><table>\n";  # close the right-aligned <td>, so this section can be centered
      $output .= "<tr><td align=center><font face=arial><b>$CRDType<input type=text size=6 maxlength=6 name=browsedocumentid> / <input type=text size=4 maxlength=4 name=browsecommentid>";
      $output .= &nbspaces(3) . "<input type=button name=commentgo value='Go' onClick=javascript:browse_comment()></b></font></td></tr>\n";
   }
   ###################################################################################################################################
   } elsif ($section eq 'update') {                                                                                       #  Update  #
   ###################################################################################################################################
   if (&sectionIsOpen($section)) {
   $output .= <<end;
   <script language=javascript>
   <!--
      function update_comment () {
         if ((isNaN(document.$form.updatecommentid.value - 0) || (document.$form.updatecommentid.value <= 0) || (document.$form.updatecommentid.value > 9999))) {
            alert('Invalid Comment ID');
         } else if ((isNaN(document.$form.updatedocumentid.value - 0) || (document.$form.updatedocumentid.value <= 0) || (document.$form.updatedocumentid.value > 999999))) {
               alert('Invalid Comment Document ID');
         } else {
            document.$form.useFormValues.value = 0;
            document.$form.id.value = document.$form.updatedocumentid.value;
            document.$form.commentid.value = document.$form.updatecommentid.value;
            document.$form.command.value = 'updatecomment';
            document.$form.action = '$path' + 'comments' + '.pl';
            document.$form.target = 'main';
            document.$form.process.value = 'updatecomment';
            document.$form.target = 'cgiresults';
            document.$form.submit();
         }
      }
   //-->
   </script>
end
      $activity = "retrieve comment information for update";
      $output .= "</table></td></tr>\n\n<tr><td align=center><table>\n";  # close the right-aligned <td>, so this section can be centered
      $output .= "<tr><td align=center><b>$CRDType<input type=text size=6 name=updatedocumentid> / <input type=text size=3 name=updatecommentid>";
      $output .= &nbspaces(3) . "<input type=button name=updatego value='Go' onClick=javascript:update_comment()></b></font></td></tr>\n";
   }
   ###################################################################################################################################
   } elsif ($section eq 'delete') {                                                                                       #  Delete  #
   ###################################################################################################################################
   if (&sectionIsOpen($section)) {
   $output .= <<end;
   <script language=javascript>
   <!--
      function delete_comment () {
         if ((isNaN(document.$form.deletedocumentid.value - 0) || (document.$form.deletedocumentid.value <= 0) || (document.$form.deletedocumentid.value > 999999))) {
               alert('Invalid Comment Document ID');
         } else {
            document.$form.useFormValues.value = 0;
            document.$form.id.value = document.$form.deletedocumentid.value;
            document.$form.command.value = 'delete';
            document.$form.action = '$path' + 'comments' + '.pl';
            document.$form.target = 'main';
            document.$form.process.value = 'deletecomment';
            document.$form.target = 'cgiresults';
            document.$form.submit();
         }
      }
   //-->
   </script>
end
      $activity = "retrieve comment information for delete";
      $output .= "</table></td></tr>\n\n<tr><td align=center><table>\n";  # close the right-aligned <td>, so this section can be centered
      $output .= "<tr><td align=center><font face=arial><font size=+1 color=#ff0000>Under Development</font><br><br><b>from $CRDType<input type=text size=6 name=deletedocumentid>". &nbspaces(3) . "<input type=button name=deletego value='Go' onClick=javascript:delete_comment()></b></font></td></tr>\n";
   }
   ###################################################################################################################################
   } elsif ($section eq 'report') {                                                                                       #  Report  #
   ###################################################################################################################################
   if (&sectionIsOpen($section)) {
      $activity = "retrieve comment information for report";
      $output .= "</table></td></tr><tr><td align=center><table>\n";  # close the right-aligned <td>, so this section can be centered
      $output .= "<tr><td align=center><b>Report ID: $reporttype</b></td></tr>\n";
   }
   ###################################################################################################################################
   } elsif ($section eq 'information') {                                                                              # Information  #
   ###################################################################################################################################
   if (&sectionIsOpen($section)) {
   $output .= <<end;
   <script language=javascript>
   <!--
      function comment_documents(command, id) {
         document.dummy.id.value = id;
         document.dummy.command.value = command;
         document.dummy.action = '$path' + 'comment_documents' + '.pl';
         document.dummy.target= 'main';
         document.dummy.submit();
      }
      function display_user(id) {
         document.dummy.id.value = id;
         document.dummy.command.value = 'displayuser';
         document.dummy.action = '$path' + 'user_functions' + '.pl';
         document.dummy.target= 'main';
         document.dummy.submit();
      }
      function display_image(documentid, commentid) {
         document.dummy.documentid.value = documentid;
         document.dummy.commentid.value = commentid;
         document.dummy.command.value = 'pdf';
         document.dummy.action = '$path' + 'display_image' + '.pl';
         document.dummy.target= 'cgiresults';
         document.dummy.submit();
      }
   //-->
   </script>

end
      if ($command eq 'delete') {
         $output .= "<tr><td><b>Comment Document:</b></td><td width=590><b>" . &formatID($CRDType, 6, $documentid) . "</b>&nbsp;&nbsp;&nbsp;&nbsp;</td></tr>\n";
         $output .= "<tr><td><b>Document Type:</b></td><td width=590><b> " . &getDocType($documentid) . " </b>&nbsp;&nbsp;&nbsp;</td></tr>  \n";
      } else {
         my $imageString;
         my @row = $dbh->selectrow_array("SELECT count(*) FROM $schema.document WHERE id=$documentid AND image IS NULL");
         if ($row[0] == 0) {
            $imageString = "(Click for complete document information.&nbsp;&nbsp;You can also <a href=\"javascript:display_image($documentid)\">view the document image</a>.)";
         } else {
            $imageString = "(Click for complete document information.)";
         }
         $output .= "<tr><td><b>Comment Document:</b></td><td width=590><b><a href=javascript:comment_documents('browse2',$documentid)>" . &formatID($CRDType, 6, $documentid) . "</a></b>&nbsp;&nbsp;&nbsp;&nbsp;<font size=2><i><b>". $imageString ."</b></i></font></td></tr>\n";
         if ($command eq 'entercomment') {
            $output .= "<tr><td><b>Document Type:</b></td><td width=590><b> " . &getDocType($documentid) . " </b>&nbsp;&nbsp;&nbsp;</td></tr>  \n";
         } else {
            $output .= "<tr><td><b>Comment Number:</b></td><td><b> " . &formatID("", 4, $commentid);
            $output .= &nbspaces(4) . "<font size=2><i><b>(You can also " . &writePrintCommentLink(document => $documentid, comment => $commentid, useIcon => 0, addTableColumn => 0) . "</a>.)</b></i></font></td></tr>\n";
            my ($createdby, $datecreated, $createdbyname, $proofreadby, $proofreaddate, $proofreadbyname);
            if ($command eq 'proofread') {
               ($createdby, $datecreated) = &getEntryInfo($documentid, $commentid);
               $createdbyname = &get_fullname($dbh, $schema, $createdby);
               $output .= "<tr><td><b>Entered By:</b></td><td><b><a href=javascript:display_user($createdby)>$createdbyname </a></b></td></tr>\n";
               $output .= "<tr><td><b>Date Entered:</b></td><td><b>$datecreated </b></td></tr>\n";
            }
            if ($command eq 'update') {
                  ($createdby, $datecreated) = &getCommentInfo($documentid, $commentid);
                  $createdbyname = &get_fullname($dbh, $schema, $createdby);
                  @row = $dbh->selectrow_array("SELECT count(*) FROM $schema.comments WHERE document=$documentid AND commentnum=$commentid AND proofreadby IS NULL");
                  if ($row[0] == 0) {
                     ($proofreadby, $proofreaddate) = &getProofreadInfo($documentid, $commentid);
                     $proofreadbyname = "<a href=javascript:display_user($proofreadby)>" . &get_fullname($dbh, $schema, $proofreadby) . "</a>";
                  } else {
                     $proofreadbyname = "";
                     $proofreaddate = "";
                  }
                  $output .= "<tr><td><b>Entered By:</b></td><td><b><a href=javascript:display_user($createdby)>$createdbyname </a></b></td></tr>\n";
                  $output .= "<tr><td><b>Date Entered:</b></td><td><b>$datecreated </b></td></tr>\n";
                  $output .= "<tr><td><b>Proofread By:</b></td><td><b>" . $proofreadbyname . "</b></td></tr>\n";
                  $output .= "<tr><td><b>Date Proofread:</b></td><td><b>" . $proofreaddate . "</b></td></tr>\n";
            }
         }
      }
   }
   ###################################################################################################################################
   } elsif ($section eq 'remarks') {                                                                                     #  Remarks  #
   ###################################################################################################################################
      if (&sectionIsOpen($section)) {
         $output .= "   <script language=javascript><!--\n";
         $output .= "      function saveRemark() {\n";
         $output .= "         if (isblank(document.$form.remarktext.value)) {\n";
         $output .= "            alert('No text has been entered in the remarks field.');\n";
         $output .= "         }\n";
         $output .= "         else {\n";
         $output .= "            document.$form.process.value = 'saveRemark';\n";
         $output .= "            submitForm('comments', '$command', 'cgiresults');\n";
         $output .= "         }\n";
         $output .= "      }\n";
         $output .= "   //-->\n";
         $output .= "   </script>\n";
         if ($command eq 'browse') {
            $output .= &doRemarks(schema => $schema, dbh => $dbh, remark_type => 'comment', document => $documentid, comment => $commentid, show_text_box => 0 );
         } elsif (($command eq 'updatecomment') || ($command eq 'rebincomment')) {
            $output .= &doRemarks(schema => $schema, dbh => $dbh, remark_type => 'comment', document => $documentid, comment => $commentid, useForm => $useFormValues );
         } else {
            $output .= &doRemarks(schema => $schema, dbh => $dbh, remark_type => 'document', document => $documentid, useForm => $useFormValues);
         }
      }
   ###################################################################################################################################
   } elsif ($section eq 'instructions') {                                                                           #  Instructions  #
   ###################################################################################################################################
   if (&sectionIsOpen($section)) {
      $output .= "<tr><td><b><font face=arial>${$sections{$command}}{$section}</font></b></td></tr>\n";
   }
   ###################################################################################################################################
   } elsif ($section eq 'entercomment') {                                                                           #  Enter Comment #
   ###################################################################################################################################
   if (&sectionIsOpen($section)) {
      $output .= &writeJavascript();
      $enableAllFunction = "setEnabled()";
      my $formatid = ($useFormValues) ? $crdcgi->param("formatid") : &formatID($CRDType, 6, $documentid);
      $activity = "enter comment from document " . $formatid;
      my $enterCommentId = ($useFormValues) ? $crdcgi->param("enterCommentId") : &getCommentNumber($documentid);
      my $text = ($useFormValues) ? $crdcgi->param("text") : '';
      $text =~ s/%27/'/g if ($text);
      my $startpage = ($useFormValues) ? $crdcgi->param("startpage") : 1;
      my $changeImpact = ($useFormValues) ? $crdcgi->param("changeImpact") : 1;
      my $changeControlNumber = ($useFormValues) ? $crdcgi->param("changeControlNumber") : '';
      my $entryRemarks = ($useFormValues) ? $crdcgi->param("entryRemarks") : '';
      $entryRemarks =~ s/%27/'/g if ($entryRemarks);
      my $bin = ($useFormValues) ? $crdcgi->param("bin") : 1;
      my $dupsimstatus = ($useFormValues) ? $crdcgi->param("dupsimstatus") : 1;
      my $dupDocument = ($useFormValues) ? $crdcgi->param("dupDocument") : '';
      my $dupComment = ($useFormValues) ? $crdcgi->param("dupComment") : '';
      my $commentsentered = (($useFormValues) &&  ($crdcgi->param("commentsentered") ne '') ) ? 'checked' : '';
      $output .= "<tr><td><br></td></tr> \n\n";
      $output .= "<tr><td align=right><table width=96% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellpadding=8 cellspacing=0> \n\n";
      $output .= "<tr><td align=left height=40><b>Comment Number:</b>&nbsp;&nbsp;<input type=text size=4 maxlength=4 name=enterCommentId value=$enterCommentId> &nbsp;&nbsp;</td><td><b>Comment starts on page</b>&nbsp;&nbsp;<input type=text size=4 maxlength=5 name=startpage value=$startpage>&nbsp;&nbsp;<b>of the Comment Document</b></td></tr> \n";
      $output .= "<tr><td height=30 valign=bottom colspan=2><b>Remarks:" . &nbspaces(2) . "<font face=arial size=2 color=$instructionsColor>(Optional)</font>";
      $output .= nbspaces(125) . "<a href=\"javascript:expandTextBox(document.$form.entryRemarks,document.entryRemarks_button,'force',5);\"><img name=entryRemarks_button border=0 src=$CRDImagePath/expand_button.gif></a>\n";
      $output .= "<br> \n";
      $output .= "<textarea name=entryRemarks rows=5 cols=80 wrap=physical onKeyPress=\"expandTextBox(this,document.entryRemarks_button,'dynamic');\">$entryRemarks</textarea></td></tr> \n\n";
      $output .= "</td></tr></table> \n\n";
      $output .= "<tr><td><br></td></tr> \n\n";
      my $rbName = 'enterRadioBox';
      my $rbSetting = $crdcgi->param($rbName);
      my $rbButton = 'duplicate';
      my $rbChecked = ($useFormValues && ($rbSetting eq $rbButton)) ? 'checked' : '';
      $output .= "<tr><td height=35><input type=radio name=$rbName value=$rbButton $rbChecked onclick=\"setDuplicate()\">";
      my $dupDocumentName = 'dupDocument';
      my $dupDocumentValue = ($crdcgi->param($dupDocumentName)) ? $crdcgi->param($dupDocumentName) : $dupDocument;
      my $dupCommentName = 'dupComment';
      my $dupCommentValue = ($crdcgi->param($dupCommentName)) ? $crdcgi->param($dupCommentName) : $dupComment;
      $output .= &nbspaces(2) . "<b>This comment is a duplicate of $CRDType<input type=text size=6 maxlength=6 name=$dupDocumentName value=$dupDocumentValue>";
      $output .= &nbspaces(1) . 'comment' . &nbspaces(1) . "<input type=text size=4 maxlength=4 name=$dupCommentName value=$dupCommentValue>";
      $output .= &nbspaces(4) . "<font face=arial size=2 color=$instructionsColor>(No further processing will be done)</font></b></td></tr>\n";
      $rbButton = 'original';
      $rbChecked = (!$useFormValues || ($rbSetting eq $rbButton)) ? 'checked' : '';
      $output .= "<tr><td height=35><input type=radio name=$rbName value=$rbButton $rbChecked onclick=\"setOriginal()\">";
      $output .= &nbspaces(2) . "<b>A response to this comment will be written:</b></td></tr>\n\n";
      $output .= "<tr><td align=right><table width=96% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellpadding=8 cellspacing=0>\n\n";
      $output .= &writeBin($bin);
      $output .= "<tr> " . &writeChangeImpact(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, doSelect => 0) . "</tr>\n\n";
      $output .= "<tr><td height=30 valign=bottom><b>Comment Text:</b>";
      $output .= nbspaces(135) . "<a href=\"javascript:expandTextBox(document.$form.text,document.text_button,'force',5);\"><img name=text_button border=0 src=$CRDImagePath/expand_button.gif></a>\n";
      $output .= "<br> \n";
      $output .= "<textarea name=text rows=10 cols=80 wrap=physical onKeyPress=\"expandTextBox(this,document.text_button,'dynamic');\">$text</textarea></td></tr>  \n\n";
      $output .= "</table></td></tr>\n\n";
      my $assignLabel = 'Submit';
      $output .= "<tr><td><table border=0 width=98% align=right><tr><td align=center valign=top height=40 colspan=2 width=36%><input type=checkbox name=commentsentered $commentsentered>" . &nbspaces(1) . "<b>No (more) comments to enter.</b>" . &nbspaces(2) . "</td><td><font face=arial size=2 color=$instructionsColor><b>(Check when entering last comment from document". $formatid .".  Check and leave comment text blank when there are no comments to enter)</font></b></td></tr></table></td></tr>\n\n";
      my $assignCallback = "javascript:verifyEntry('entercomment')";
      my $assign = ($useLinks) ? "<b><a href=$assignCallback>$assignLabel</a></b>" : "<input type=button name=assign value='$assignLabel' onClick=$assignCallback>";
      $output .= "<tr><td align=center height=40>$assign</td></tr>\n";
      $output .= "<script language=javascript>\n<!--\n setType(document.$form.enterRadioBox);\n//-->\n</script>\n";
   }
   ###################################################################################################################################
   } elsif ($section eq 'proofread') {                                                                                 #  Proofread  #
   ###################################################################################################################################
   if (&sectionIsOpen($section)) {
      $output .= &writeJavascript();
      $enableAllFunction = "setEnabled()";
      $output .= "<input type=hidden name=commentsentered value='false'>";
      $activity = "proofread comment ".$commentid ." from comment document " . &formatID($CRDType, 6, $documentid);
      my $text = ($useFormValues) ? $crdcgi->param("text") : '';
      $text =~ s/%27/'/g if ($text);
      my $startpage = ($useFormValues) ? $crdcgi->param("startpage") : 1;
      my $createdby = ($useFormValues) ? $crdcgi->param("createdby") : '';
      my $datecreated = ($useFormValues) ? $crdcgi->param("datecreated"): '';
      my $remarks = ($useFormValues) ? $crdcgi->param("remarks") : '';
      $remarks =~ s/%27/'/g if ($remarks);
      my $newremarks = ($useFormValues) ? $crdcgi->param("newremarks") : '';
      $newremarks =~ s/%27/'/g if ($newremarks);
      my $bin = ($useFormValues) ? $crdcgi->param("bin") : 1;
      my $dupsimstatus = ($useFormValues) ? $crdcgi->param("dupsimstatus") : 1;
      my $dupDocument = ($useFormValues) ? $crdcgi->param("dupDocument") : '';
      my $dupComment = ($useFormValues) ? $crdcgi->param("dupComment"): '';
      my $remarkstring = ($useFormValues) ? $crdcgi->param("remarkstring"): '';
      if (!($useFormValues)) {
         my $sqlquery = "select text, startpage, createdby, to_char(datecreated,'$dateFormat'), remarks, bin, dupsimstatus, dupsimdocumentid, dupsimcommentid from $schema.comments_entry where document=$documentid and commentnum=$commentid";
         $dbh->{LongTruncOk}=0;
         my $csr = $dbh->prepare($sqlquery);
         $csr->execute;
         while (my @values = $csr->fetchrow_array) {
            ($text, $startpage, $createdby, $datecreated, $remarks, $bin, $dupsimstatus, $dupDocument, $dupComment) = @values;
         }
         $csr->finish;
      }
      if ((defined($remarks)) && ($remarks gt '') && ($remarkstring eq '')) {
         $remarkstring = "$datecreated - " . get_fullname($dbh, $schema, $createdby) . " - $remarks <br><br>";
         $remarkstring =~ s/\n/\\n/g;
         #$remarkstring =~ s/'/%27/g;
      }
      $output .= "<input type=hidden name=createdby value=$createdby>\n";
      $output .= "<input type=hidden name=datecreated value='$datecreated'>\n";
      $output .= "<input type=hidden name=remarks value='$remarks'>\n" if ($remarks);
      $output .= "<input type=hidden name=remarkstring value='$remarkstring'>\n";
      $output .= "<tr><td align=right><table width=96% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellpadding=8 cellspacing=0> \n\n";
      $output .= "<tr><td align=left height=40><b>Comment starts on page</b>&nbsp;&nbsp;<input type=text size=4 maxlength=5 name=startpage value=$startpage>&nbsp;&nbsp;<b>of the Comment Document</b></td></tr> \n";
      $output .= "<tr><td height=30 valign=bottom><b>Remarks:<b><br> \n";
      $output .= "<table border=1 width=100% bgcolor=#ffffff> \n";
      $output .= "<tr><td> ";
      if ($remarkstring gt '') {
         $output .= $remarkstring;
      } else {
         $output .= "--No remarks recorded for this comment-- <br><br> ";
      }
      $output .= "</td></tr></table></td></tr> \n";
      $output .= "<tr><td height=30 valign=bottom><b>Add Remarks: <font size = -1></b><i>(optional)</i></font>";
      $output .= nbspaces(120) . "<a href=\"javascript:expandTextBox(document.$form.newremarks,document.newremarks_button,'force',5);\"><img name=newremarks_button border=0 src=$CRDImagePath/expand_button.gif></a>\n";
      $output .= "<br> \n";
      $output .= "<textarea name=newremarks rows=5 cols=80 wrap=physical onKeyPress=\"expandTextBox(this,document.newremarks_button,'dynamic');\">$newremarks</textarea></td></tr> \n\n";
      $output .= "</td></tr></table> \n\n";
      $output .= "<tr><td><br></td></tr> \n\n";
      my $rbName = 'enterRadioBox';
      my $rbSetting = $crdcgi->param($rbName);
      my $rbButton = 'duplicate';
      my $rbChecked = (($dupsimstatus eq 2) || ($useFormValues && ($rbSetting eq $rbButton))) ? 'checked' : '';
      $output .= "<tr><td height=35><input type=radio name=$rbName value=$rbButton $rbChecked onclick=\"setDuplicate()\">";
      my $dupDocumentName = 'dupDocument';
      my $dupDocumentValue = ($crdcgi->param($dupDocumentName)) ? $crdcgi->param($dupDocumentName) : $dupDocument;
      my $dupCommentName = 'dupComment';
      my $dupCommentValue = ($crdcgi->param($dupCommentName)) ? $crdcgi->param($dupCommentName) : $dupComment;
      $output .= &nbspaces(2) . "<b>This comment is a duplicate of $CRDType<input type=text size=6 maxlength=6 name=$dupDocumentName value=$dupDocumentValue>";
      $output .= &nbspaces(1) . 'comment' . &nbspaces(1) . "<input type=text size=4 maxlength=4 name=$dupCommentName value=$dupCommentValue>";
      $output .= &nbspaces(4) . "<font face=arial size=2 color=$instructionsColor>(No further processing will be done)</font></b></td></tr>\n";
      $rbButton = 'original';
      $rbChecked = ( (!($dupsimstatus == 2) && !$useFormValues) || ($rbSetting eq $rbButton)) ? 'checked' : '';
      $output .= "<tr><td height=35><input type=radio name=$rbName value=$rbButton $rbChecked onclick=\"setOriginal()\">";
      $output .= &nbspaces(2) . "<b>A response to this comment will be written:</b></td></tr>\n\n";
      $output .= "<tr><td align=right><table width=96% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellpadding=8 cellspacing=0>\n\n";
      $output .= &writeBin($bin);
      $output .= "<tr> " . &writeChangeImpact(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, table => 'comments_entry' ) . "</tr>\n\n";
      $output .= "<tr><td height=30 valign=bottom><b>Comment Text:</b>";
      $output .= nbspaces(135) . "<a href=\"javascript:expandTextBox(document.$form.text,document.text_button,'force',5);\"><img name=text_button border=0 src=$CRDImagePath/expand_button.gif></a>\n";
      $output .= "<br> \n";
      $output .= "<textarea name=text rows=10 cols=80 wrap=physical onKeyPress=\"expandTextBox(this,document.text_button,'dynamic');\">$text</textarea></td></tr>  \n\n";
      $output .= "</table></td></tr>\n\n";
      my $assignLabel = 'Submit';
      my $assignCallback = "javascript:verifyEntry('proofread')";
      my $assign = ($useLinks) ? "<b><a href=$assignCallback>$assignLabel</a></b>" : "<input type=button name=assign value='$assignLabel' onClick=$assignCallback>";
      $output .= "<tr><td align=center height=40>$assign</td></tr>\n";
      $output .= "<script language=javascript>\n<!--\n setType(document.$form.enterRadioBox);\n//-->\n</script>\n";
   }
   ###################################################################################################################################
   } elsif ($section eq 'browsecomment') {                                                                         #  Browse Comment #
   ###################################################################################################################################
   if (&sectionIsOpen($section)) {
   $output .= <<end;
   <script language=javascript>
   <!--
      function bins(command, id) {
         document.$form.binid.value = id;
         submitForm('bins', command, 'main');
      }
      function browse_response () {
         if ((isNaN(document.$form.commentid.value - 0) || (document.$form.commentid.value <= 0) || (document.$form.commentid.value > 9999))) {
            alert('Invalid Comment ID');
         }
         else if ((isNaN(document.$form.id.value - 0) || (document.$form.id.value <= 0) || (document.$form.id.value > 999999))) {
            alert('Invalid Comment Document ID');
         }
         else {
            document.$form.command.value = 'browse';
end
   $output .= "            document.$form.action = '/cgi-bin/" . lc($CRDType) . "/' + 'responses' + '.pl';\n";
   $output .= <<end;
            document.$form.target = 'cgiresults';
            document.$form.process.value = 'browse';
            document.$form.submit();
         }
      }
      function displaySummaryComment(id) {
         $form.summarycommentid.value = id;
         submitForm ('summary_comments', 'browseSummaryComment', 'main');
      }
      function displayComment(documentid, commentid) {
         $form.id.value = documentid;
         $form.commentid.value = commentid;
         submitForm('$form', 'browse', 'main');
      }
      function displayCommentor(id) {
         $form.id.value = id;
         submitForm ('commentors', 'display', 'main');
      }
   //-->
   </script>
end
      $activity = "browse comment ". $commentid . " from comment document " . &formatID($CRDType, 6, $documentid);
      my ($text, $startpage, $dateassigned,$datedue, $dateapproved, $hascommitments, $hasissues, $changeImpact, $changeControlNumber, $createdby, $datecreated, $proofreadby, $proofreaddate, $bin, $doereviewer, $summary, $dupsimstatus, $dupDocument, $dupComment, $summaryapproved);
      my @values;
      my $sqlquery = "select text, startpage, to_char(dateassigned,'$dateFormat'), datedue, to_char(dateapproved,'$dateFormat'), hascommitments, hasissues, changeimpact, changecontrolnum, createdby, to_char(datecreated,'$dateFormat'), proofreadby, to_char(proofreaddate,'$dateFormat'), bin, doereviewer, summary, dupsimstatus, dupsimdocumentid, dupsimcommentid, summaryapproved from $schema.comments where document=$documentid and commentnum=$commentid";
      $dbh->{LongTruncOk}=0;
      my $csr = $dbh->prepare($sqlquery);
      $csr->execute;
      while (@values = $csr->fetchrow_array) {
         ($text, $startpage, $dateassigned, $datedue, $dateapproved, $hascommitments, $hasissues, $changeImpact, $changeControlNumber, $createdby, $datecreated, $proofreadby, $proofreaddate, $bin, $doereviewer, $summary, $dupsimstatus, $dupDocument, $dupComment, $summaryapproved) = @values;
      }
      $csr->finish;
      $dateassigned = ($dateassigned) ? $dateassigned : '';
      $datedue = ($datedue) ? $datedue : '';
      $dateapproved = ($dateapproved) ? $dateapproved : '';
      $changeControlNumber = ($changeControlNumber) ? $changeControlNumber : '';
      my ($binid, $binname) = &getBinName($documentid, $commentid);
      my $createdbyname = &get_fullname($dbh, $schema, $createdby);
      my $proofreadbyname = &get_fullname($dbh, $schema, $proofreadby) unless !($proofreadby);
      my $doereviewername = &get_fullname($dbh, $schema, $doereviewer) unless !($doereviewer);
      $hascommitments = ($hascommitments eq 'T') ? 'Yes' : 'No';
      $hasissues = ($hasissues eq 'T') ? 'Yes' : 'No';
      my $summaryID = ($summary) ? "<a href=javascript:displaySummaryComment($summary)>" . &formatID('SCR', 4, $summary) . "</a>" : "";
      $summaryapproved = ($summaryapproved eq 'T') ? 'Yes' : 'No';
      $summaryapproved = ($summaryID ne '') ? $summaryapproved : 'N/A';
      my %changeImpactValues = %{&getLookupValues(dbh => $dbh, schema => $schema, table => 'document_change_impact')};
      $output .= "<tr><td><center><table border=0> \n\n";
      $output .= "<tr><td height=30 valign=bottom><b>Comment Text:</b>";
      $output .= nbspaces(135) . "<a href=\"javascript:expandTextBox(document.$form.text,document.text_button,'force',5);\"><img name=text_button border=0 src=$CRDImagePath/expand_button.gif></a>\n";
      $output .= "</td></tr> \n";
      $output .= "<tr><td><textarea name=text rows=10 cols=80 wrap=physical readonly onfocus=\"on_readonly(this)\">$text</textarea></td></tr> \n";
      $output .= "<tr><td height=5></td></tr>\n";
      $output .= "<tr><td><table bgcolor=#ffffff cellpadding=2 cellspacing=1 border=0 width=100%>\n";
      $output .= "<tr bgcolor=#f0f0f0><td><b>Commentor:</b></td><td><b>" . &writeCommentorLink(dbh => $dbh, schema => $schema, document => $documentid) . "</b></td></tr>\n";
      my ($commentor) = $dbh->selectrow_array ("select nvl(commentor,0) from $schema.document where id = $documentid");
      if ($commentor) {
         my ($affiliation, $organization) = $dbh->selectrow_array ("select affiliation, nvl(organization, 'None Entered') from $schema.commentor where id = $commentor");
         my %affiliationValues = %{&getLookupValues(dbh => $dbh, schema => $schema, table => 'commentor_affiliation')};
         $output .= "<tr bgcolor=#ffffff><td><b>Commentor Affiliation:</b></td><td><b>$affiliationValues{$affiliation}</b></td></tr>\n";
         $output .= "<tr bgcolor=#f0f0f0><td><b>Commentor Organization:</b></td><td><b>$organization</b></td></tr>\n";
      }
      $output .= "<tr bgcolor=#ffffff><td><b>Bin:</b></td><td><b><a href=javascript:bins('browse',$binid)>$binname</a></b></td></tr>\n";
      $output .= "<tr bgcolor=#f0f0f0><td><b>Starts on:</b></td><td><b>Page $startpage</b></td></tr>\n";
      $output .= "<tr bgcolor=#ffffff><td width=45%><b>Created by:</b></td><td><b><a href=javascript:display_user($createdby)>$createdbyname </a></b></td></tr>\n";
      $output .= "<tr bgcolor=#f0f0f0><td><b>Date Created:</b></td><td><b>$datecreated </b></td></tr>\n";
      $output .= "<tr bgcolor=#ffffff><td><b>Proofread by:</b></td><td><b><a href=javascript:display_user($proofreadby)>$proofreadbyname </a></b></td></tr>\n";
      $output .= "<tr bgcolor=#f0f0f0><td><b>Date Proofread:</b></td><td><b>$proofreaddate </b></td></tr>\n";
      $output .= "<tr bgcolor=#ffffff><td><b>Document Change Impact:</b></td><td><b>$changeImpactValues{$changeImpact}</b></td></tr>\n";
      $output .= "<tr bgcolor=#f0f0f0><td><b>Document Change Control Number:</b></td><td><b>$changeControlNumber</b></td></tr>\n";
      $output .= "<tr bgcolor=#ffffff><td><b>Summarized By: </b></td><td><b>$summaryID</b></td></tr>\n";
      $output .= "<tr bgcolor=#f0f0f0><td><b>Summary Approved: </b></td><td><b>$summaryapproved</b></td></tr>\n";
      my $dupID = ($dupsimstatus == 1) ? "" : "<a href=javascript:displayComment($dupDocument,$dupComment)>" . &formatID($CRDType, 6, $dupDocument) . " / " . &formatID("", 4, $dupComment) .  "</a>";
      $output .= "<tr bgcolor=#ffffff><td><b>Duplicate Of: </b></td><td><b>$dupID</b></td></tr>\n";
      $csr = $dbh->prepare("select document, commentnum from $schema.comments where dupsimstatus = 2 and dupsimdocumentid = $documentid and dupsimcommentid = $commentid order by document, commentnum");
      $csr->execute;
      $dupID = "";
      my $dupCount = 0;
      while (my ($dupDocument, $dupComment) = $csr->fetchrow_array) {
         $dupCount++;
         $dupID .= "<a href=javascript:displayComment($dupDocument,$dupComment)>" . &formatID($CRDType, 6, $dupDocument) . " / " . &formatID("", 4, $dupComment) .  "</a><br>";
      }
      $csr->finish;
      $output .= "<tr bgcolor=#f0f0f0><td valign=top><b>Has Duplicates ($dupCount): </b></td><td><b>$dupID</b></td></tr>\n";
      $output .= "<tr bgcolor=#ffffff><td><b>$secondReviewName Reviewer: </b></td><td><b>";
      $output .= ($doereviewer) ? "<a href=javascript:display_user($doereviewer)>$doereviewername" : "";
      $output .= "</a></b></td></tr>\n";
      $output .= "<tr bgcolor=#f0f0f0><td><b>Potential DOE Commitment:</b></td><td><b>$hascommitments</b></td></tr>\n";
      $output .= "<tr bgcolor=#ffffff><td><b>Potential Issues:</b></td><td><b>$hasissues</b></td></tr>\n";
      $output .= "<tr bgcolor=#f0f0f0><td><b>Date Assigned:</b></td><td><b>$dateassigned</b></td></tr>\n";
      $output .= "<tr bgcolor=#ffffff><td><b>Date Due:</b></td><td><b>$datedue</b></td></tr>\n";
      $output .= "<tr bgcolor=#f0f0f0><td><b>Date Approved:</b></td><td><b>$dateapproved</b></td></tr>\n";
      $output .= "</table></td></tr>\n";
      my $assignLabel = 'Browse Response Development';
      my $assignCallback = "javascript:browse_response()";
      my $assign = ($useLinks) ? "<b><a href=$assignCallback>$assignLabel</a></b>" : "<input type=button name=assign value='$assignLabel' onClick=$assignCallback>";
      $output .= "<tr><td align=center height=40>$assign</td></tr>\n\n";
   }
   ###################################################################################################################################
   } elsif ($section eq 'deletecomment') {                                                                         #  Delete Comment #
   ###################################################################################################################################
   if (&sectionIsOpen($section)) {
   $output .= <<end;
   <script language=javascript>
   <!--
      function comments(command, id, commentid) {
         document.$form.id.value = id;
         document.$form.commentid.value = commentid;
         document.$form.target = 'main';
         submitForm('comments', command);
      }
      function commentDelete(error, message, command, id) {
         if (error) {
            alert (unescape(error));
         } else {
            if (confirm(unescape(message))) {
               document.$form.id.value = id;
               document.$form.process.value = command;
               document.$form.target = 'cgiresults';
               submitForm('comments', command);
            }
         }
      }
   //-->
   </script>
end
      my $formatId = &formatID($CRDType, 6, $documentid);
      $activity = "delete comments from " . &formatID($CRDType, 6, $documentid);
      $output .= "<tr><td><font size=+1 color=#ff0000>Please...&nbsp;</font><b>view the information below to confirm that you indeed want to delete the comments and bracketed image associated with $formatId before submitting.</b></font></td></tr> \n";
      $output .= "<tr><td><br></td></tr> \n";
      $output .= "<tr><td><b><a href=\"javascript:comment_documents('browse2',$documentid)\">" . &formatID($CRDType, 6, $documentid) . "</a>&nbsp;&nbsp;&nbsp;&nbsp;Click to view complete comment document information</b></td></tr> \n";
      $output .= "<tr><td><b><a href=\"javascript:display_image($documentid)\">Image</a>&nbsp;&nbsp;&nbsp;&nbsp;Click to view the bracketed image</b></td></tr> \n";
      $output .= "<tr><td><br></td></tr> \n";
      my $entryBackground = '#000080';
      my $entryForeground = '#ffffff';
      my $csr = $dbh->prepare("select commentnum, createdby, datecreated, text from $schema.comments_entry where document=$documentid order by commentnum");
      $csr->execute;
      my $outputstring = "<tr><td align=right>\n";
      $outputstring .= &start_table(4, 'right', 120, 120, 80, 430);
      $outputstring .= &title_row("$entryBackground", "$entryForeground", '<font size=3>Comments</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Not proofread</font></i>)');
      $outputstring .= &add_header_row();
      $outputstring .= &add_col() . 'Comment ID';
      $outputstring .= &add_col() . 'Entered By';
      $outputstring .= &add_col() . 'Date Entered';
      $outputstring .= &add_col() . 'Comment Text';
      my $rows1 = 0;
      while (my @values = $csr->fetchrow_array) {
         $rows1++;
         my ($commentid, $enteredby, $entrydate, $text) = @values;
         if (defined($text) && ($text ne "")) {
            $outputstring .= &add_row();
            my $formattedid = &formatID("", 4, $commentid);
            $outputstring .= &add_col() . $formattedid;
            $outputstring .= &add_col_link ("javascript:display_user($enteredby)") . &get_fullname($dbh, $schema, $enteredby);
            $outputstring .= &add_col() . $entrydate;
            $outputstring .= &add_col() . &getDisplayString($text, 70);
         }
      }
      $csr->finish;
      $outputstring .= &end_table();
      $outputstring .= "</td></tr>\n";
      $outputstring .= "<tr><td height=15> </td></tr>\n";
      $output .= $outputstring if ($rows1 > 0);
      $output .= "<tr><td height=15> </td></tr>\n" if ($rows1 > 0);
      $csr = $dbh->prepare("select commentnum, createdby, datecreated, text from $schema.comments where document=$documentid order by commentnum");
      $csr->execute;
      $outputstring = "<tr><td align=right>\n";
      $outputstring .= &start_table(4, 'right', 120, 120, 80, 430);
      $outputstring .= &title_row("$entryBackground", "$entryForeground", '<font size=3>Comments</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Proofread</font></i>)');
      $outputstring .= &add_header_row();
      $outputstring .= &add_col() . 'Comment ID';
      $outputstring .= &add_col() . 'Entered By';
      $outputstring .= &add_col() . 'Date Entered';
      $outputstring .= &add_col() . 'Comment Text';
      my $rows2 = 0;
      while (my @values = $csr->fetchrow_array) {
         $rows2++;
         my ($commentid, $enteredby, $entrydate, $text) = @values;
         if (defined($text) && ($text ne "")) {
            $outputstring .= &add_row();
            my $formattedid = &formatID("", 4, $commentid);
            $outputstring .= &add_col_link ("javascript:comments('browse',$documentid,$commentid)") . $formattedid;
            $outputstring .= &add_col_link ("javascript:display_user($enteredby)") . &get_fullname($dbh, $schema, $enteredby);
            $outputstring .= &add_col() . $entrydate;
            $outputstring .= &add_col() . &getDisplayString($text, 70);
         }
      }
      $csr->finish;
      $outputstring .= &end_table();
      $outputstring .= "</td></tr>\n";
      $output .= $outputstring if ($rows2 > 0);
      $output .= "<tr><td height=15> </td></tr>\n" if ($rows2 > 0);
      $output .= "<tr><td><b>No comments have been entered for $formatId.</b></td></tr>" unless (($rows1) || ($rows2));
      my $deleteMessage = "Are you sure you want to delete these comments?";
      my $deleteError = "";
      my $hasDup1 = $dbh->selectrow_array("SELECT count(*) FROM $schema.comments WHERE dupsimdocumentid = $documentid and dupsimstatus = 2");
      my $hasDup2 = $dbh->selectrow_array("SELECT count(*) FROM $schema.comments_entry WHERE dupsimdocumentid = $documentid and dupsimstatus = 2");
      if (($hasDup1 > 0) || ($hasDup2 > 0)) {
         $deleteError = "Comments exist which are marked as duplicates to the comments you wish to delete. \\nThe duplication status on the dependent duplicate comments must be changed \\nbefore the comments from $formatId can be deleted.";
      }
      my $status = $dbh->selectrow_array("SELECT count(*) FROM $schema.response_version WHERE document=$documentid and (status > 1)");
      my $version = $dbh->selectrow_array("SELECT count(*) FROM $schema.response_version WHERE document=$documentid and (version > 1)");
      if (($status > 0) || ($version > 0)) {
         $deleteMessage = "Response development has begun on these comments. \\nAre you sure you want to delete them?";
      }
      my $assignLabel = 'Delete Comments';
      my $assignCallback = "\"javascript:commentDelete('$deleteError', '$deleteMessage', 'delete', $documentid)\"";
      my $assign = ($useLinks) ? "<b><a href=$assignCallback>$assignLabel</a></b>" : "<input type=button name=assign value='$assignLabel' onClick=$assignCallback>";
      $output .= "<tr><td align=center height=40>$assign</td></tr>\n\n";
   }
   ###################################################################################################################################
   } elsif ($section eq 'updatecomment') {                                                                         #  Update Comment #
   ###################################################################################################################################
   if (&sectionIsOpen($section)) {
   $output .= <<end;
   <script language=javascript><!--
      function verifyEntry(command) {
         var msg = '';
         var confirmText = '';
         if ((isNaN(document.$form.commentid.value - 0)) || (document.$form.commentid.value <= 0) || (document.$form.commentid.value > 9999)) {
            msg += "Invalid Comment ID \\n";
         }
         if ((isNaN(document.$form.startpage.value - 0)) || (document.$form.startpage.value <= 0) || (document.$form.startpage.value > 99999)) {
            msg += "Invalid Start Page \\n";
         }
         if ($form.text.value == '') {
            msg += "Please Enter Comment Text \\n";
         }
         if (msg != '') {
            alert (msg);
         } else if (confirmText != '') {
            if (confirm(unescape(confirmText))) {
               document.$form.process.value = command;
               document.$form.useFormValues.value = 0;
               submitForm('$form', command, 'cgiresults');
            }
         } else {
            document.$form.process.value = command;
            document.$form.useFormValues.value = 0;
            submitForm('$form', command, 'cgiresults');
         }
      }

   //-->
   </script>
end
      $crdcgi->delete('rbName');
      $activity = "update comment ".$commentid ." from comment document " . &formatID($CRDType, 6, $documentid);
      my $text = ($useFormValues) ? $crdcgi->param("text") : '';
      $text =~ s/%27/'/g if ($text);
      my $startpage = ($useFormValues) ? $crdcgi->param("startpage") : 1;
      my $dateassigned = ($useFormValues) ? $crdcgi->param("dateassigned") : '';
      my $datedue = ($useFormValues) ? $crdcgi->param("datedue") : '';
      my $dateapproved = ($useFormValues) ? $crdcgi->param("dateapproved") : '';
      my $bin = ($useFormValues) ? $crdcgi->param("bin") : 1;
      my $doereviewer = ($useFormValues) ? $crdcgi->param("doereviewer") : 1;
      my $summary = ($useFormValues) ? $crdcgi->param("summary") : 0;
      my $dupsimstatus = ($useFormValues) ? $crdcgi->param("dupsimstatus") : 1;
      my $dupDocument = ($useFormValues) ? $crdcgi->param("dupDocument") : '';
      my $dupComment = ($useFormValues) ? $crdcgi->param("dupComment"): '';
      $useFormValues = 0 if ($crdcgi->param("useFormValues") == 0 );
      if (!($useFormValues)) {
         my $sqlquery = "select text, startpage, dateassigned, datedue, dateapproved, bin, doereviewer, summary, dupsimstatus, dupsimdocumentid, dupsimcommentid from $schema.comments where document=$documentid and commentnum=$commentid";
         $dbh->{LongTruncOk}=0;
         $dbh->{LongReadLen} = 100000000;
         my $csr = $dbh->prepare($sqlquery);
         $csr->execute;
         while (my @values = $csr->fetchrow_array) {
            ($text, $startpage, $dateassigned, $datedue, $dateapproved, $bin, $doereviewer, $summary, $dupsimstatus, $dupDocument, $dupComment) = @values;
         }
         $csr->finish;
      }
      my $formatid = &formatID($CRDType, 6, $documentid);
      $output .= "<tr><td align=right><table width=100% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellpadding=8 cellspacing=0>\n\n";
      $output .= "<tr><td align=left height=40><b>Comment starts on page</b>&nbsp;&nbsp;<input type=text size=3 name=startpage value=$startpage>&nbsp;&nbsp;<b>of the Comment Document</b></td></tr> \n";
      $output .= "<tr>" . &writeDOEReviewer(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, useForm => $useFormValues ) . "</tr>\n\n";
      $output .= "<tr>" . &writeHasCommitments(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, useForm => $useFormValues) . "</tr>\n\n";
      $output .= "<tr>" . &writeHasIssues(dbh => $dbh, schema => $schema, document => $documentid, comment => $commentid, useForm => $useFormValues) . "</tr>\n\n";
      $output .= "<tr>" . &writeChangeImpact(dbh => $dbh, schema => $schema, document => $documentid , comment => $commentid, useForm => $useFormValues) . "</tr>\n\n";
      $output .= "<tr><td height=30 valign=bottom><b>Comment Text:</b>";
      $output .= nbspaces(135) . "<a href=\"javascript:expandTextBox(document.$form.text,document.text_button,'force',5);\"><img name=text_button border=0 src=$CRDImagePath/expand_button.gif></a>\n";
      $output .= "<br> \n";
      $output .= "<textarea name=text rows=10 cols=80 wrap=physical onKeyPress=\"expandTextBox(this,document.text_button,'dynamic');\">$text</textarea></td></tr>  \n\n";
      $output .= "</table></td></tr>\n\n";
      my $assignLabel = 'Submit';
      my $assignCallback = "javascript:verifyEntry('update')";
      $useLinks = 0;
      my $assign = ($useLinks) ? "<b><a href=$assignCallback>$assignLabel</a></b>" : "<input type=button name=assign value='$assignLabel' onClick=$assignCallback>";
      $output .= "<tr><td align=center height=40>$assign</td></tr>\n";
   }
   ###################################################################################################################################
   } elsif ($section eq 'markduplicate') {                                                            #  Get ID's for Mark Duplicate #
   ###################################################################################################################################
      $activity = "get document/comment ids for mark duplicate";
      $output .= <<end;
   <script language=javascript><!--
      function mark_duplicate () {
         var msg = "";
         if ((isNaN(document.$form.markduplicatecommentid.value - 0) || (document.$form.markduplicatecommentid.value <= 0) || (document.$form.markduplicatecommentid.value > 9999))) {
            msg += "Invalid Duplicate Comment ID \\n";
         }
         if ((isNaN(document.$form.markduplicatedocumentid.value - 0) || (document.$form.markduplicatedocumentid.value <= 0) || (document.$form.markduplicatedocumentid.value > 999999))) {
            msg += "Invalid Duplicate Document ID \\n";
         }
         if ((isNaN(document.$form.markduplicateorigcommentid.value - 0) || (document.$form.markduplicateorigcommentid.value <= 0) || (document.$form.markduplicateorigcommentid.value > 9999))) {
            msg += "Invalid Original Comment ID \\n";
         }
         if ((isNaN(document.$form.markduplicateorigdocumentid.value - 0) || (document.$form.markduplicateorigdocumentid.value <= 0) || (document.$form.markduplicateorigdocumentid.value > 999999))) {
            msg += "Invalid Original Document ID \\n";
         }
         if (msg != "") {
            alert(msg);
         } else {
            document.$form.useFormValues.value = 0;
            document.$form.id.value = document.$form.markduplicatedocumentid.value;
            document.$form.commentid.value = document.$form.markduplicatecommentid.value;
            document.$form.origdocumentid.value = document.$form.markduplicateorigdocumentid.value;
            document.$form.origcommentid.value = document.$form.markduplicateorigcommentid.value;
            document.$form.command.value = 'markduplicate';
            document.$form.action = '$path' + 'comments' + '.pl';
            document.$form.process.value = 'markduplicate';
            document.$form.target = 'cgiresults';
            document.$form.submit();
         }
      }
   //-->
   </script>
end
      $output .= "</table></td></tr>\n\n<tr><td align=center><table>\n";  # close the right-aligned <td>, so this section can be centered
      $output .= "<tr><td align=center><b>$CRDType<input type=text size=6 maxlength=6 name=markduplicatedocumentid> / <input type=text size=4 maxlength=4 name=markduplicatecommentid></b></td></tr>";
      $output .= "<tr><td height=40 align=center><b>is an exact duplicate of</b></td></tr>";
      $output .= "<tr><td align=center><b>$CRDType<input type=text size=6 maxlength=6 name=markduplicateorigdocumentid> / <input type=text size=4 maxlength=4 name=markduplicateorigcommentid></b></td></tr>";
      $output .= "<tr><td height=70 align=center><input type=button name=markduplicatego value='Submit' onClick=javascript:mark_duplicate()></td></tr>\n";
   ###################################################################################################################################
   } elsif ($section eq 'rebin') {                                                                           #  Get Rebin Comment ID #
   ###################################################################################################################################
      $activity = "rebin get document and comment id";
      $output .= <<end;
   <script language=javascript><!--
      function rebin_comment () {
         if ((isNaN(document.$form.rebincommentid.value - 0) || (document.$form.rebincommentid.value <= 0) || (document.$form.rebincommentid.value > 9999))) {
            alert('Invalid Comment ID');
         } else if ((isNaN(document.$form.rebindocumentid.value - 0) || (document.$form.rebindocumentid.value <= 0) || (document.$form.rebindocumentid.value > 999999))) {
            alert('Invalid Comment Document ID');
         } else {
            document.$form.useFormValues.value = 0;
            document.$form.id.value = document.$form.rebindocumentid.value;
            document.$form.commentid.value = document.$form.rebincommentid.value;
            document.$form.command.value = 'rebin';
            document.$form.action = '$path' + 'comments' + '.pl';
            document.$form.process.value = 'rebin';
            document.$form.target = 'cgiresults';
            document.$form.submit();
         }
      }
   //-->
   </script>
end
      $output .= "</table></td></tr>\n\n<tr><td align=center><table>\n";  # close the right-aligned <td>, so this section can be centered
      $output .= "<tr><td align=center><b>$CRDType<input type=text size=6 maxlength=6 name=rebindocumentid> / <input type=text size=4 maxlength=4 name=rebincommentid>";
      $output .= &nbspaces(3) . "<input type=button name=rebingo value='Go' onClick=javascript:rebin_comment()></b></font></td></tr>\n";
   ###################################################################################################################################
   } elsif ($section eq 'rebincomment') {                                                                           #  Rebin Comment #
   ###################################################################################################################################
      my $id = &formatID($CRDType, 6, $documentid) . " / " . &formatID("", 4, $commentid);
      $activity = "rebin comment $id";
      my $relateDocument = "document = $documentid";
      my $relateComment = $relateDocument . " and commentnum = $commentid";
      my ($oldbin, $summary) = $dbh->selectrow_array ("select bin, nvl(summary,-1) from $schema.comments where $relateComment");
      my ($summaryTitle) = ($summary == -1) ? "" : $dbh->selectrow_array ("select title from $schema.summary_comment where id = $summary");
      my ($oldbinname) = $dbh->selectrow_array ("select name from $schema.bin where id = $oldbin");
      my $justCoordinator = (!&does_user_have_priv($dbh, $schema, $userid, 6) && !&does_user_have_priv($dbh, $schema, $userid, 10));
      $output .= "<table cellpadding=5 cellspacing=5 width=750>\n";
      $output .= "<tr><td width=90><b>Current Bin:</b></td><td><b>$oldbinname</b></td></tr>\n";
      $output .= "<tr><td width=90><b>New Bin:</b></td><td>\n";
      my $onChange = ($summary == -1) ? "" : "onchange=setSummaryList(this.options[this.selectedIndex].value,$form.newscr.options)";
      $output .= "<select size=1 name=newbin $onChange>\n";
      my $sql = "select id, name from $schema.bin where ";
      $sql .= ($summary == -1) ? "id <> $oldbin" : "1 = 1";
      $sql .= " and ";
      $sql .= ($justCoordinator) ? "coordinator = $userid" : "1 = 1";
      $sql .= " order by name";
      my $csr = $dbh->prepare($sql);
      $csr->execute;
      my $selected = " selected";
      my $selectedBin = 0;
      while (my ($bin, $binName) = $csr->fetchrow_array) {
         if (($summary == -1) || ($dbh->selectrow_array ("select count(*) from $schema.summary_comment where bin = $bin"))) {
            $output .= "<option value=$bin$selected>" . $binName . "\n";
            $selected = "";
            $selectedBin = $bin if ($selectedBin == 0);
         }
      }
      $output .= "</select>\n";
      $output .= "</td></tr>\n";
      if ($summary != -1) {
         $output .= "</table><table cellpadding=5 cellspacing=5 width=750>\n";
         $output .= "<tr><td align=center colspan=2><hr width=80%></td></tr>\n";
         $output .= "<tr><td width=115><b>Summarized By:</b></td><td><b>$summaryTitle</b></td></tr>\n";
         $output .= "<tr><td width=115><b>New Summary:</b></td><td>";
         my $sql = "select id, bin, title from $schema.summary_comment order by bin, id";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         $output .= "<script language=javascript><!--\n";
         $output .= "var scrs = new Array();\n";
         my $count = 0;
         while (my ($scrID, $scrBin, $scrTitle) = $csr->fetchrow_array) {
            $scrTitle = &getDisplayString($scrTitle, 75);
            $scrTitle =~ s/"/'/g;
            $output .= "scrs[$count] = [$scrBin, $scrID, \"$scrTitle\"];\n";
            $count++;
         }
         $output .= "//-->\n";
         $output .= "</script>\n";
         $csr->finish;
         $output .= "<select size=1 name=newscr></select>\n";
         $output .= "</td></tr>\n";
      }
      $output .= "</table>\n";
      my $submit = &writeControl(label => 'Submit', callback => "rebin()", useLinks => 0);
      $output .= "<tr><td align=center height=40>$submit</td></tr>\n";
      $output .= "<script language=javascript><!--\n";
      $output .= "function rebin() {\n";
      $output .= "   var msg = \"\";\n";
      $output .= "   if (msg != \"\") {\n";
      $output .= "      alert(msg);\n";
      $output .= "   } else {\n";
      $output .= "      $form.process.value = '$command';\n";
      $output .= "      submitForm('comments', '$command', 'cgiresults');\n";
      $output .= "   }\n";
      $output .= "}\n";
      if ($summary != -1) {
         $output .= "function setSummaryList(bin, scrListOptions) {\n";
         $output .= "   scrListOptions.length = 0;\n";
         $output .= "   for (i = 0; i < scrs.length; i++) {\n";
         $output .= "      if ((bin == scrs[i][0]) && ($summary != scrs[i][1])) {\n";
         $output .= "         scrListOptions.length++;\n";
         $output .= "         scrListOptions[scrListOptions.length - 1].value = scrs[i][1];\n";
         $output .= "         scrListOptions[scrListOptions.length - 1].text = scrs[i][2];\n";
         $output .= "      }\n";
         $output .= "   }\n";
         $output .= "   scrListOptions.selectedIndex = 0;\n";
         $output .= "}\n";
         $output .= "setSummaryList($selectedBin, $form.newscr.options)";
      }
      $output .= "//-->\n";
      $output .= "</script>\n";
   }
   $output .= "</table></td></tr>\n\n";
   $output .= "<tr><td height=30> </td></tr>\n" if (&sectionIsOpen($section));
   };
   if ($@) {
      $dbh->rollback;
      $error .= &errorMessage($dbh, $username, $userid, $schema, $activity, $@);
   }
   if ($error) { # display the error message
      $error =~ s/\n/\\n/g;
      $error =~ s/'/%27/g;
      $output .= "<script language=javascript>\n<!--\nvar mytext ='$error';\nalert(unescape(mytext));\n//-->\n</script>\n";
   }
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
      function submitForm (script, command, target) {
         $form.target = target;
         $form.command.value = command;
         $form.action = '$path' + script + '.pl';
         $form.submit();
      }
   //-->
   </script>
end
   print &sectionHeadTags($form, $enableAllFunction);
   print "</head>\n\n";
}

###################################################################################################################################
sub writeBody {                                                                                                                   #
###################################################################################################################################
   print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0 >\n<center>\n\n";
   print  &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => ${$sections{$command}}{'header'});
   print "<form name=$form method=post>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=command value=$command>\n";
   print "<input type=hidden name=id value=$documentid>\n" if ($documentid);
   print "<input type=hidden name=id value=0>\n" unless ($documentid);
   print "<input type=hidden name=commentid value=$commentid>\n" if ($commentid);
   print "<input type=hidden name=commentid value=0>\n" unless ($commentid);
   print "<input type=hidden name=summarycommentid value=0>\n";
   print "<input type=hidden name=binid value=0>\n";
   print "<input type=hidden name=dupsimstatus value=1> \n" unless (($command eq 'update') || ($command eq 'updatecomment'));
   print "<input type=hidden name=dupsimstatus value= > \n" if (($command eq 'update') || ($command eq 'updatecomment'));
   print "<input type=hidden name=summaryDocument value=9999>\n" unless (($command eq 'update') || ($command eq 'updatecomment'));
   print "<input type=hidden name=hascommitments value=0>\n" unless (($command eq 'update') || ($command eq 'updatecomment'));
   print "<input type=hidden name=version value=1>\n";
   print "<input type=hidden name=process value=0>\n";
   print "<input type=hidden name=origcommentid value=0>\n";
   print "<input type=hidden name=origdocumentid value=0>\n";
   print "<input type=hidden name=useFormValues value=1> \n\n";
   print &sectionBodyTags;
   print "\n<table width=775 cellpadding=0 cellspacing=0 border=0>\n";
   print $output;
   print "</table>\n</form>\n\n";
   print "<form name=dummy method=post>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=command value=0>\n";
   print "<input type=hidden name=documentid value=0>\n";
   print "<input type=hidden name=id value=0>\n";
   print "<input type=hidden name=commentid value=0>\n";
   print "<input type=hidden name=binid value=0>\n";
   print "</form>\n</center>\n</font>\n";
   print &BuildPrintCommentResponse($username, $userid, $schema, $path);
   print "<script language=javascript>\n<!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n" if ($errorstr);
   print "</body>\n</html>\n";
}

###################################################################################################################################
$dbh = db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;
if ($process) {
   &processSubmittedData();
} else {
   &configureSections($command);
   eval {
      &setupSections($dbh, \%sections, $userid, $schema, ${$sections{$command}}{'pageNum'}, $crdcgi->param("arrowPressed"));
   };
   &processError(activity => 'setup comments sections') if ($@);
   foreach my $section (keys (%sections)) {
      if (sectionIsActive($section)) {
         doHeader($section);
         doSection($section);
      }
   }
   &writeHTTPHeader();
   &writeHead();
   &writeBody();
}
db_disconnect($dbh);
exit();
