#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/crd/perl/RCS/home.pl,v $
#
# $Revision: 1.17 $
#
# $Date: 2002/02/21 00:25:40 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: home.pl,v $
# Revision 1.17  2002/02/21 00:25:40  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.16  2001/12/13 22:42:19  mccartym
# display summary comment title instead of response text on concurrence display
#
# Revision 1.15  2001/08/04 00:57:31  mccartym
# SCR #1 and #5
#
# Revision 1.14  2001/06/28 18:47:28  mccartym
# remove preapproved responses, message points from initial baseline version
#
# Revision 1.13  2001/06/27 01:43:04  mccartym
# checkpoint
#
# Revision 1.12  2000/05/15 22:44:42  mccartym
# Correctly display assignments on comments from anonyumous and illegible documents
#
# Revision 1.11  2000/04/19 16:56:43  mccartym
# fix error on NEPA Review counts
#
# Revision 1.10  2000/04/18 04:25:51  mccartym
# Reformatted response assignment tables - include commentor info, counts, addl. links, etc.
#
# Revision 1.9  2000/03/24 20:44:37  mccartym
# Add summarize multiple comments function
#
# Revision 1.8  2000/03/20 20:14:01  mccartym
# Adjust section counts for bin filter, show filter setting on section header
#
# Revision 1.7  2000/02/29 01:59:25  mccartym
# optionally include or exclude subbins on bin filter
#
# Revision 1.6  2000/02/28 22:52:44  mccartym
# add filtering of assignments by bin
#
# Revision 1.5  2000/02/10 17:33:08  atchleyb
# removed form-verify.ps
#
# Revision 1.4  2000/02/07 17:13:27  mccartym
# Change order by clauses to show data by bin rather than by date updated
# Remove hardcoded 'EIS' and 'Jason'
#
# Revision 1.3  1999/11/25 01:56:04  mccartym
# formatting changes
#
# Revision 1.2  1999/10/15 01:52:36  mccartym
# checkpoint
#
# Revision 1.1  1999/08/02 02:58:46  mccartym
# Initial revision
#
#

use integer;
use strict;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DocumentSpecific qw(:Functions);
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
my $errorstr = "";

my $dateFormat = 'DD-MON-YY HH24:MI:SS';
my $process = $crdcgi->param("process");
my ($binFilter, $subbins);
my @binFilterList = ();
my %counts;

my $firstReviewName = &FirstReviewName();
my $secondReviewName = &SecondReviewName();
my $pageNum = 1;
tie my %sections, "Tie::IxHash";
%sections = (
   'messages' =>          { 'privilege' => [ 1 ],    'enabled' => 1, 'defaultOpen' => 0, 'title' => 'Messages' },
   'mailroom_entry' =>    { 'privilege' => [ 2 ],    'enabled' => 1, 'defaultOpen' => 1, 'title' => 'Document Capture'},
   'document_entry' =>    { 'privilege' => [ 3 ],    'enabled' => 1, 'defaultOpen' => 0, 'title' => 'Comment Documents Data Entry'},
   'comment_entry' =>     { 'privilege' => [ 3 ],    'enabled' => 1, 'defaultOpen' => 0, 'title' => 'Comments Data Entry'},
   'response_entry' =>    { 'privilege' => [ 3 ],    'enabled' => 1, 'defaultOpen' => 0, 'title' => 'Responses Data Entry'},
   'summary_entry' =>     { 'privilege' => [ 3 ],    'enabled' => 1, 'defaultOpen' => 0, 'title' => 'Summary Comment/Response Data Entry'},
   'preapproved_entry' => { 'privilege' => [ 3 ],    'enabled' => 0, 'defaultOpen' => 0, 'title' => 'Preapproved Text Data Entry'},
   'coordinator' =>       { 'privilege' => [ 8 ],    'enabled' => 1, 'defaultOpen' => 0, 'title' => 'Bin Coordinator Assignments'},
   'write_response' =>    { 'privilege' => [ 4, 8 ], 'enabled' => 1, 'defaultOpen' => 0, 'title' => 'Write Response Assignments'},
   'tech_review' =>       { 'privilege' => [ 5, 8 ], 'enabled' => 1, 'defaultOpen' => 0, 'title' => 'Technical Review Assignments'},
   'tech_edit' =>         { 'privilege' => [ 9 ],    'enabled' => 1, 'defaultOpen' => 0, 'title' => 'Technical Edit Assignments'},
   'nepa_approval' =>     { 'privilege' => [ 6 ],    'enabled' => 1, 'defaultOpen' => 0, 'title' => "$firstReviewName Review/Approval Assignments"},
   'doe_approval' =>      { 'privilege' => [ 7 ],    'enabled' => 1, 'defaultOpen' => 0, 'title' => "$secondReviewName Review/Approval Assignments"}
#  'concurrence' =>       { 'privilege' => [ 1 ],    'enabled' => 1, 'defaultOpen' => 0, 'title' => "Observer Review/Concur Assignments"};
#  concurrence section is added dynamically before call to setup setions for users that need it
);

###################################################################################################################################
sub getConcurCount {                                                                                                              #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $count = 0;
   my $sql = "select bin, concurrencetype from $args{schema}.concurrer c where c.userid = $args{user}";
   my $csr = $args{dbh}->prepare($sql);

   $sql = "select count(*) from $args{schema}.comments c, $args{schema}.response_version r ";
   $sql .= "where c.document = r.document and c.commentnum = r.commentnum and ";
   $sql .= "c.bin = :param1 and r.status >= 7 and r.status <= 9 and ";
   $sql .= "not exists (select 1 from $args{schema}.concurrence cc where cc.document = c.document and cc.commentnum = c.commentnum ";
   $sql .= "and cc.concurrencetype = :param2 and cc.concurs = 'T')";
   my $csr2 = $args{dbh}->prepare($sql);

   $sql = "select count(*) from $args{schema}.summary_comment sc ";
   $sql .= "where sc.bin = :param1 and sc.dateapproved is not null and ";
   $sql .= "not exists (select 1 from $args{schema}.concurrence_summary scc where sc.id = scc.summarycomment ";
   $sql .= "and scc.concurrencetype = :param2 and scc.concurs = 'T')";
   my $csr3 = $args{dbh}->prepare($sql);

   $csr->execute;
   while (my ($concurBin, $concurType) = $csr->fetchrow_array) {
      my @bins = ();
      my $bincsr = $dbh->prepare("select id from $schema.bin connect by prior id = parent start with id = $concurBin order by id");
      $bincsr->execute;
      my $useList = ($binFilter == 0);   # Process the subbin list for every top level concur bin if the bin filter is off
      while (my ($subbin) = $bincsr->fetchrow_array) {
         push(@bins, $subbin);
         if ($subbin == $binFilter) {  # The filter bin is in the subbin tree of this top level concur bin
            $useList = 1;
            @bins = @binFilterList;
            last;
         }
      }
      $bincsr->finish;
      @bins = () if (!$useList);
      foreach my $bin (@bins) {
         $csr2->bind_param(":param1", $bin);
         $csr2->bind_param(":param2", $concurType);
         $csr2->execute;
         my ($thisCount) = $csr2->fetchrow_array;
         $csr2->finish;
         $count += $thisCount;

         $csr3->bind_param(":param1", $bin);
         $csr3->bind_param(":param2", $concurType);
         $csr3->execute;
         ($thisCount) = $csr3->fetchrow_array;
         $csr3->finish;
         $count += $thisCount;
      }
   }
   $csr->finish;
   return ($count);
}

###################################################################################################################################
sub userIsConcurrer {                                                                                                             #
###################################################################################################################################
   my %args = (
      @_,
   );
   my ($count) = $args{dbh}->selectrow_array ("select count(*) from $args{schema}.concurrer where userid = $args{user}");
   return ($count);
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
sub applyBinFilter {                                                                                                              #
###################################################################################################################################
   $" = ',';
   my $output = ($binFilter > 0) ? " and c.bin in (@binFilterList) " : "";
   $" = ' ';
   return ($output);
}

###################################################################################################################################
sub showBinFilter {                                                                                                               #
###################################################################################################################################
   my $show = (&does_user_have_priv($dbh, $schema, $userid, -1)) ? 1 : 0;
   for (my $priv = 4; $priv <= 10; $priv++) {
      last if ($show = &does_user_have_priv($dbh, $schema, $userid, $priv));
   }
   return ($show);
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
sub getLookupValues {                                                                                                             #
###################################################################################################################################
   my %lookupHash = ();
   my $lookup = $_[0]->prepare("select id, name from $_[1].$_[2]");
   $lookup->execute;
   while (my @values = $lookup->fetchrow_array) {
      $lookupHash{$values[0]} = $values[1];
   }
   $lookup->finish;
   return (\%lookupHash);
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
sub getCommentorName {                                                                                                            #
###################################################################################################################################
   my ($dbh, $schema, $table, $namestatus, $commentorid) = @_;
   my %commentorNameStatus = %{&getLookupValues($dbh, $schema, 'commentor_name_status')};
   my $nameText = $commentorNameStatus{$namestatus};
   if ($nameText eq "PROVIDED") {
      my @row = $dbh->selectrow_array ("select firstname, lastname from $schema.$table where id = $commentorid");
      $nameText = (defined($row[0])) ? $row[0] . " " . $row[1] : $row[1];
   }
   return ($nameText);
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
sub writeResponseAssignmentLink {                                                                                                 #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Doc ID /<br>Comment ID",
      prompt => "",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $prompt = ($args{prompt}) ? "Click here to $args{prompt}" : "";
      $out .= "<center><a href=javascript:responses('$args{action}',$args{document},$args{comment},$args{version}) title='$prompt'>";
      $out .= &formatID($CRDType, 6, $args{document});
      $out .= " /<br>";
      $out .= &formatID("", 4, $args{comment});
      $out .= "</a></center>";
   }
   return ($out);
}

###################################################################################################################################
sub writeConcurrenceLink {                                                                                                        #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "",
      useTableFunction => 1,
      @_,
   );
   my %concurTypes = %{&getLookupValues($dbh, $schema, 'concurrence_type')};
   my $out = ($args{useTableFunction}) ? &add_col() : "<td width=80><font size=-1><b>";
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my ($formattedID, $args) = ("", "");
      if ($args{type} eq 'individual') {
         $formattedID = &formatID($CRDType, 6, $args{document}) . " / " . &formatID("", 4, $args{comment});
         $args = "'responses',$args{concurType},$args{document},$args{comment}";
      } elsif ($args{type} eq 'summary') {
         $formattedID = &formatID('SCR', 4, $args{id});
         $args = "'summary_comments',$args{concurType},$args{id}";
      }
      my $prompt = "Click here to enter $concurTypes{$args{concurType}} concurrence for $formattedID";
      $out .= "<center><a href=javascript:concur($args) title='$prompt'>$formattedID</a></center>";
   }
   $out .= "</b></font></td>\n" if (!$args{useTableFunction});
   return ($out);
}

###################################################################################################################################
sub writeDate {                                                                                                                    #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Last<br>Activity",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      $out .= "<center>$args{date}</center>";
   }
   return ($out);
}

###################################################################################################################################
sub writeBin {                                                                                                                    #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Bin",
      useTableFunction => 1,
      @_,
   );
   my $out = ($args{useTableFunction}) ? &add_col() : "<td width=40><font size=-1><b>";
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $prompt = "Click here to browse bin $args{binName}";
      $out .= "<center><a href=javascript:display_bin($args{binID}) title='$prompt'>";
      $out .= &getBinNumber(binName => $args{binName});
      $out .= "</a></center>";
   }
   $out .= "</b></font></td>\n" if (!$args{useTableFunction});
   return ($out);
}

###################################################################################################################################
sub writeUser {                                                                                                                   #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Response<br>Writer",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $displayedUserName = &get_fullname($dbh, $schema, $args{userID});
      my $prompt = "Click here to browse information about $displayedUserName";
      $out .= "<center><a href=javascript:display_user($args{userID}) title='$prompt'>$displayedUserName</a></center>";
   }
   return ($out);
}

###################################################################################################################################
sub writeCommentorOrgAndText {                                                                                                    #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "<center>Commentor Organization or Name /<br>Response Text</center>",
      text => "",
      textWidth => 85,
      textBgColor => "#f0f0f0",
      commentorDisplayFunction => "display_commentor",
      @_,
   );

   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= $args{headerText};
   } else {
      $out .= "<table border=0 cellpadding=1 cellspacing=0 width=100%>\n";
      $out .= "<tr><td><font size=-1><b>";
      if ($args{nameStatus} == 2) {
         $out .= "<font color=#ff0000>ANONYMOUS Comment Document</font>";
      } elsif ($args{nameStatus} == 3) {
         $out .= "<font color=#ff0000>ILLEGIBLE Commentor Name on Document</font>";
      } else {
         my $prompt = "Click here to browse detailed information about the commentor";
         my ($title, $firstName, $middleName, $lastName, $suffix, $organization) = $dbh->selectrow_array ("select nvl(title,' '), nvl(firstname,' '), nvl(middlename,' '), nvl(lastname,' '), nvl(suffix,' '), organization from $schema.commentor where id = $args{commentor}");
         $organization = "$title $firstName $middleName $lastName $suffix" if (!$organization);
         $out .= "<a href=javascript:$args{commentorDisplayFunction}($args{commentor}) title='$prompt'>$organization</a>";
      }
      $out .= "</b></font></td></tr>\n";
      $out .= "<tr><td bgcolor=$args{textBgColor}><font size=-1><b>";
      $out .= &getDisplayString($args{text}, $args{textWidth});
      $out .= "</b></font></td></tr>";
      $out .= "</table>";
   }
   return ($out);
}

###################################################################################################################################
sub writeResponseStatus {                                                                                                         #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Response<br>Status",
      @_,
   );
   my $out = &add_col();
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      my $status = $args{status};
      $status =~ s'/APPROVAL'';
      $out .= "<center>$status</center>";
   }
   return ($out);
}

###################################################################################################################################
sub writeConcurrenceStatus {                                                                                                      #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      headerText => "Concurrence<br>Status",
      useTableFunction => 1,
      @_,
   );
   my $out = ($args{useTableFunction}) ? &add_col() : "<td width=80><font size=-1><b>";
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      $out .= "<center>";
      $out .= ($args{negative}) ? "Negative" : "None Entered";
      $out .= "</center>";
   }
   $out .= "</b></font></td>\n" if (!$args{useTableFunction});
   return ($out);
}

###################################################################################################################################
sub writeResponseText {                                                                                                           #
###################################################################################################################################
   my %args = (
      writeHeader => 0,
      textWidth => 60,
      headerText => "Response Text",
      useTableFunction => 1,
      @_,
   );
   my $out = ($args{useTableFunction}) ? &add_col() : "<td width=555><font size=-1><b>";
   if ($args{writeHeader}) {
      $out .= "<center>$args{headerText}</center>";
   } else {
      $args{text} = "&nbsp;" if (!$args{text});
      $out .= &getDisplayString($args{text}, $args{textWidth});
   }
   $out .= "</b></font></td>\n" if (!$args{useTableFunction});
   return ($out);
}

###################################################################################################################################
sub getCount {                                                                                                                    #
###################################################################################################################################
   my @row = $dbh->selectrow_array ("select count(*) from $_[0] where $_[1]");
   return ($row[0]);
}

###################################################################################################################################
sub filterBinNumber {                                                                                                             #
###################################################################################################################################
   my $section = $_[0];
   my $binNumber = "";
   if (($section eq 'coordinator') || ($section eq 'write_response') || ($section eq 'tech_review') ||
       ($section eq 'tech_edit')   || ($section eq 'nepa_approval')  || ($section eq 'doe_approval') || ($section eq 'concurrence')) {
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
sub printCount {                                                                                                                  #
###################################################################################################################################
   print "<td bgcolor=#f3f3f3 align=center width=160><font face=arial color=#000060 size=-1><b>$_[0]</b></font></td>\n";
}

###################################################################################################################################
sub doHeader {                                                                                                                    #
###################################################################################################################################
   my $section = $_[0];
   my $tables = "$schema.comments c, $schema.bin b, $schema.response_version r";
   my $relateTables = 'c.bin = b.id and c.document = r.document and c.commentnum = r.commentnum';
   print "<tr><td><table width=100% border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellspacing=0 cellpadding=0><tr>\n";
   print "<td align=center bgcolor=#f3f3f3 width=22>" . &sectionImageTag($section) . "</td>\n";
   print "<td height=23 bgcolor=#f3f3f3><font face=arial color='#000060'><b>&nbsp;&nbsp;${$sections{$section}}{'title'}" . &filterBinNumber($section) . "</b></font></td>\n";
   eval {
      if ($section eq 'messages') {
         $counts{messagesReceived} = &getCount("$schema.message", "sentto = $userid and senttodeleted = 'F'");
         $counts{messagesReceivedNew} = &getCount("$schema.message", "sentto = $userid and hasbeenread = 'F' and senttodeleted = 'F'");
         $counts{messagesSent} = &getCount("$schema.message", "sentby = $userid and sentbydeleted = 'F'");
         if (!&sectionIsOpen($section)) {
            printCount("$counts{messagesReceived} received&nbsp;&nbsp;<font color=#ff0000>($counts{messagesReceivedNew} new)</font>");
            printCount("$counts{messagesSent} sent");
         }
      } elsif ($section eq 'document_entry') {
         $counts{documentsEntry} = &getCount("$schema.document_entry", 'entrydate2 is null');
         $counts{documentsProofread} = &getCount("$schema.document_entry", "entrydate2 is not null and enteredby2 <> $userid");
         if (!&sectionIsOpen($section)) {
            printCount("$counts{documentsEntry} to enter");
            printCount("$counts{documentsProofread} to proofread");
         }
      } elsif ($section eq 'comment_entry') {
         $counts{commentsEntry} = &getCount("$schema.document", "commentsentered = 'F' and dupsimstatus = 1");
         $counts{commentsProofread} = &getCount("$schema.comments_entry", "createdby <> $userid");
         if (!&sectionIsOpen($section)) {
            printCount("$counts{commentsEntry} to enter");
            printCount("$counts{commentsProofread} to proofread");
         }
      } elsif ($section eq 'response_entry') {
         $counts{responseProofread} = &getCount("$schema.response_version_entry", "enteredby <> $userid");
         printCount("$counts{responseProofread} to proofread") if (!&sectionIsOpen($section));
      } elsif ($section eq 'summary_entry') {
         $counts{summaryCommentProofread} = &getCount("$schema.summary_comment_entry", "createdby <> $userid");
         $counts{summaryResponseProofread} = &getCount("$schema.summary_response_entry", "enteredby <> $userid");
         my $count = $counts{summaryCommentProofread} + $counts{summaryResponseProofread};
         printCount("$count to proofread") if (!&sectionIsOpen($section));
      } elsif ($section eq 'preapproved_entry') {
         $counts{preapprovedProofread} = &getCount("$schema.preapproved_text_entry", "enteredby <> $userid");
         printCount("$counts{preapprovedProofread} to proofread") if (!&sectionIsOpen($section));
      } elsif ($section eq 'coordinator') {
          $counts{initialAssign} = &getCount("$tables", "$relateTables and b.coordinator = $userid and r.status = 1 and c.dupsimstatus = 1 and c.summary is NULL and r.version = 1" . &applyBinFilter());
          $counts{reassign} = &getCount("$tables", "$relateTables and b.coordinator = $userid and r.status = 1 and c.dupsimstatus = 1 and r.version > 1" . &applyBinFilter());
          $counts{bcaccept} = &getCount("$tables", "$relateTables and b.coordinator = $userid and r.status = 6" . &applyBinFilter());
          if (!&sectionIsOpen($section)) {
             my $count = $counts{initialAssign} + $counts{reassign};
             printCount("$count to assign");
             printCount("$counts{bcaccept} to accept");
          }
      } elsif ($section eq 'write_response') {
         $counts{developResponse} = &getCount("$tables", "$relateTables and r.responsewriter = $userid and r.status = 2" . &applyBinFilter());
         $counts{modifyResponse} = &getCount("$tables", "$relateTables and r.responsewriter = $userid and r.status = 4" . &applyBinFilter());
         if (!&sectionIsOpen($section)) {
            printCount("$counts{developResponse} to write");
            printCount("$counts{modifyResponse} to modify");
         }
      } elsif ($section eq 'tech_review') {
         $counts{techReview} = &getCount("$tables, $schema.technical_review t", "$relateTables and t.reviewer = $userid and r.status = 3 and r.document = t.document and r.commentnum = t.commentnum and r.version = t.version and t.status = 1" . &applyBinFilter());
         printCount("$counts{techReview} to review") if (!&sectionIsOpen($section));
      } elsif ($section eq 'tech_edit') {
         $counts{techEditAssigned} = &getCount("$tables", "$relateTables and r.techeditor = $userid and r.status = 5" . &applyBinFilter());
         $counts{techEditUnassigned} = &getCount("$tables", "$relateTables and r.techeditor is null and r.status = 5" . &applyBinFilter());
         if (!&sectionIsOpen($section)) {
            printCount("$counts{techEditAssigned} to edit");
            printCount("$counts{techEditUnassigned} unassigned");
         }
      } elsif ($section eq 'nepa_approval') {
         $counts{nepaReview} = &getCount("$tables", "$relateTables and b.nepareviewer = $userid and r.status = 7" . &applyBinFilter());
         printCount("$counts{nepaReview} to review/approve") if (!&sectionIsOpen($section));
      } elsif ($section eq 'doe_approval') {
         $counts{doeReview} = &getCount("$tables", "$relateTables and c.doereviewer = $userid and r.status = 8" . &applyBinFilter());
         printCount("$counts{doeReview} to review/approve") if (!&sectionIsOpen($section));
      } elsif ($section eq 'concurrence') {
         my $count = &getConcurCount(dbh => $dbh, schema => $schema, user => $userid);
         printCount("$count to review/concur") if (!&sectionIsOpen($section));
      }
   };
   &processError(activity => "display $section header") if ($@);
   print "</tr></table>\n</td></tr>\n";
   print "<tr><td height=15> </td></tr>\n";
}

###################################################################################################################################
sub processSubmittedData {                                                                                                        #
###################################################################################################################################
   print $crdcgi->header('text/html');
   print "<html>\n<head>\n</head>\n<body>\n";
   my $activity = "";
   my $logActivity = 0;
   my $error = "";
   eval {
      #############################################################################################################################
      if ($process eq 'saveFilter') {                                                                                             #
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
      #############################################################################################################################
      } elsif ($process eq 'summarizeMultiple') {                                                                                 #
      #############################################################################################################################
         my $bin = $crdcgi->param("bin");
         my ($count) = $dbh->selectrow_array("select count(*) from $schema.summary_comment where bin = $bin");
         if (!$count) {
            my ($binName) = $dbh->selectrow_array("select name from $schema.bin where id = $bin");
            $binName =~ m/([0-9].*?)[ ]/;
            $binName = $1;
            $error = "No Summary Comments in bin $1";
         } else {
            $form = 'summary_comments';
         }
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
      print "<form name=$form method=post target=main action=$path$form.pl>\n";
      if ($form ne 'home') {
         my @paramlist = $crdcgi->param();
         foreach my $param (@paramlist) {
            my $val = ($param eq 'process') ? 0 : $crdcgi->param($param);
            $val =~ s/'/%27/g;
            print "<input type=hidden name='$param' value='$val'>\n";
         }
      } else {
         print "<input type=hidden name=username value=$username>\n";
         print "<input type=hidden name=userid value=$userid>\n";
         print "<input type=hidden name=schema value=$schema>\n";
      }
      print "</form>\n";
      print "<script language=javascript>\n<!--\n$form.submit();\n//-->\n</script>\n";
   }
   print "</body>\n</html>\n";
}

sub doSection {
   my $entryBackground = '#ffc0ff';
   my $entryForeground = '#000099';
   my $section = $_[0];
   eval {
      ################################################################################################################################
      if ($section eq 'messages') {                                                                                     #  Messages  #
      ################################################################################################################################
         print "<tr><td align=right>\n";
         print "<table width=750 cellpadding=4 cellspacing=0 border=0>\n";
         print "<ul><tr><td><li><b><a href=javascript:message('compose')>Send a new message</a></b></td></tr></ul>\n";
         print "</table>\n</td></tr>\n<tr><td height=15> </td></tr>\n";

         my $csr = $dbh->prepare("select id, sentby, to_char(datesent,'$dateFormat'), subject, hasbeenread from $schema.message where sentto = $userid and senttodeleted = 'F' order by datesent desc");
         $csr->execute;
         my $output = "<tr><td align=right>\n";
         $output .= &start_table(4, 'right', 130, 160, 410, 50);
         $output .= &title_row('#ffffc0', '#000099', "<font size=3>Received Messages ($counts{messagesReceived})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on subject to read - red indicates unread message</font></i>)");
         $output .= &add_header_row();
         $output .= &add_col() . 'Received';
         $output .= &add_col() . 'From';
         $output .= &add_col() . 'Subject';
         $output .= &add_col() . 'Delete';
         my $rows = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows++;
            my ($id, $sender, $date, $subject, $hasbeenread) = @values;
            $output .= &add_row();
            $output .= &add_col() . $date;
            $output .= &add_col_link ("javascript:display_user($sender)") . &get_fullname($dbh, $schema, $sender);
            $subject = &getDisplayString($subject, 50);
            $subject = '<font color=#ff0000>' . $subject . '</font>' if ($hasbeenread eq 'F');
            $output .= &add_col_link ("javascript:message('senttodisplay',$id)") . $subject;
            $output .= &add_col_link ("javascript:message('senttodelete',$id)") . 'delete';
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows > 0);

         $csr = $dbh->prepare("select id, sentto, to_char(datesent,'$dateFormat'), subject from $schema.message where sentby = $userid and sentbydeleted = 'F' order by datesent desc");
         $csr->execute;
         $output = "<tr><td align=right>\n";
         $output .= &start_table(4, 'right', 130, 160, 410, 50);
         $output .= &title_row('#ffffc0', '#000099', "<font size=3>Sent Messages ($counts{messagesSent})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on subject to read</font></i>)");
         $output .= &add_header_row();
         $output .= &add_col() . 'Sent';
         $output .= &add_col() . 'To';
         $output .= &add_col() . 'Subject';
         $output .= &add_col() . 'Delete';
         $rows = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows++;
            my ($id, $sender, $date, $subject) = @values;
            $output .= &add_row();
            $output .= &add_col() . $date;
            $output .= &add_col_link ("javascript:display_user($sender)") . &get_fullname($dbh, $schema, $sender);
            $output .= &add_col_link ("javascript:message('sentbydisplay',$id)") . &getDisplayString($subject, 50);
            $output .= &add_col_link ("javascript:message('sentbydelete',$id)") . 'delete';
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows > 0);
         print "<tr><td height=15> </td></tr>\n";
      ################################################################################################################################
      } elsif ($section eq 'mailroom_entry') {                                                                    # Document Capture #
      ################################################################################################################################
         print "<tr><td align=right>\n";
         print "<table width=750 cellpadding=4 cellspacing=0 border=0><ul>\n";
         print "<tr><td><b><li><a href=javascript:document_capture('doc_capture_enter')>Enter</a>" . &nbspaces(2) . "new Comment Documents</b></td></tr>\n";
         print "<tr><td><b><li><a href=javascript:document_capture('doc_capture_view')>Browse</a>" . &nbspaces(2) . "entered Comment Documents</b></td></tr>\n";
         print "<tr><td><b><li><a href=javascript:document_capture('doc_capture_update')>Update</a>" . &nbspaces(2) . "entered Comment Documents</b></td></tr>\n";
         print "<tr><td><b><li><a href=javascript:document_capture('report')>Report</a>" . &nbspaces(2) . "on entered Comment Documents</b></td></tr>\n";
         print "</ul></table>\n</td></tr>\n<tr><td height=30> </td></tr>\n";
      ################################################################################################################################
      } elsif ($section eq 'document_entry') {                                     #  Supplemental Comment Document Entry/Proofread  #
      ################################################################################################################################
         my %documentTypes = %{&getLookupValues($dbh, $schema, 'document_type')};
         my $csr = $dbh->prepare("select id, documenttype, commentor, datereceived, enteredby1, entrydate1, namestatus from $schema.document_entry where entrydate2 is null order by id");
         $csr->execute;
         my $output = "<tr><td align=right>\n";
         $output .= &start_table(6, 'right', 70, 160, 175, 85, 175, 85);
         $output .= &title_row("$entryBackground", "$entryForeground", "<font size=3>Enter Comment Documents ($counts{documentsEntry})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to complete data entry</font></i>)");
         $output .= &add_header_row();
         $output .= &add_col() . 'Doc ID';
         $output .= &add_col() . 'Type';
         $output .= &add_col() . 'Commentor';
         $output .= &add_col() . 'Date Received';
         $output .= &add_col(2) . 'Document Capture';
         my $rows1 = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows1++;
            my ($id, $documenttype, $commentor, $datereceived, $enteredby1, $entrydate1, $namestatus) = @values;
            $output .= &add_row();
            $output .= &add_col_link ("javascript:comment_documents('enter',$id)") . &formatID($CRDType, 6, $id);
            $output .= &add_col() . $documentTypes{$documenttype};
            $output .= &add_col() . &getCommentorName($dbh, $schema, 'commentor_entry', $namestatus, $commentor);
            $output .= &add_col() . $datereceived;
            $output .= &add_col_link ("javascript:display_user($enteredby1)") . &get_fullname($dbh, $schema, $enteredby1);
            $output .= &add_col() . $entrydate1;
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows1 > 0);

         $csr = $dbh->prepare("select id, documenttype, enteredby1, entrydate1, enteredby2, entrydate2, commentor, namestatus from $schema.document_entry where entrydate2 is not null and enteredby2 <> $userid order by id");
         $csr->execute;
         $output = "<tr><td align=right>\n";
         $output .= &start_table(7, 'right', 70, 160, 120, 120, 80, 120, 80);
         $output .= &title_row("$entryBackground", "$entryForeground", "<font size=3>Proofread Comment Documents ($counts{documentsProofread})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to proofread</font></i>)");
         $output .= &add_header_row();
         $output .= &add_col() . 'Doc ID';
         $output .= &add_col() . 'Type';
         $output .= &add_col() . 'Commentor';
         $output .= &add_col(2) . 'Document Capture';
         $output .= &add_col(2) . 'Supplemental Data Entry';
         my $rows2 = 0;
         while (my @values = $csr->fetchrow_array) {
            my ($id, $documenttype, $enteredby1, $entrydate1, $enteredby2, $entrydate2, $commentor, $namestatus) = @values;
            $rows2++;
            $output .= &add_row();
            $output .= &add_col_link ("javascript:comment_documents('proofread',$id)") . &formatID($CRDType, 6, $id);
            $output .= &add_col() . $documentTypes{$documenttype};
            $output .= &add_col() . &getCommentorName($dbh, $schema, 'commentor_entry', $namestatus, $commentor);
            $output .= &add_col_link ("javascript:display_user($enteredby1)") . &get_fullname($dbh, $schema, $enteredby1);
            $output .= &add_col() . $entrydate1;
            $output .= &add_col_link ("javascript:display_user($enteredby2)") . &get_fullname($dbh, $schema, $enteredby2);
            $output .= &add_col() . $entrydate2;
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows2 > 0);
         print "<tr><td height=15> </td></tr>\n" if (($rows1 + $rows2) > 0);
      ################################################################################################################################
      } elsif ($section eq 'comment_entry') {                                                           #  Comments Entry/Proofread  #
      ################################################################################################################################
         my %documentTypes = %{&getLookupValues($dbh, $schema, 'document_type')};
         my $csr = $dbh->prepare("select id, documenttype, commentor, enteredby2, entrydate2, proofreadby, proofreaddate, namestatus from $schema.document where commentsentered = 'F' and dupsimstatus = 1 order by id");
         $csr->execute;
         my $output = "<tr><td align=right>\n";
         $output .= &start_table(7, 'right', 70, 160, 120, 120, 80, 120, 80);
         $output .= &title_row("$entryBackground", "$entryForeground", "<font size=3>Enter Comments from Comment Document ($counts{commentsEntry})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to enter comments</font></i>)");
         $output .= &add_header_row();
         $output .= &add_col() . 'Doc ID';
         $output .= &add_col() . 'Type';
         $output .= &add_col() . 'Commentor';
         $output .= &add_col(2) . 'Supplemental Data Entry By';
         $output .= &add_col(2) . 'Proofread By';
         my $rows1 = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows1++;
            my ($id, $documenttype, $commentor, $enteredby2, $entrydate2, $proofreadby, $proofreaddate, $namestatus) = @values;
            $output .= &add_row();
            $output .= &add_col_link ("javascript:comments('enter',$id)") . &formatID($CRDType, 6, $id);
            $output .= &add_col() . $documentTypes{$documenttype};
            $output .= &add_col() . &getCommentorName($dbh, $schema, 'commentor', $namestatus, $commentor);
            $output .= &add_col_link ("javascript:display_user($enteredby2)") . &get_fullname($dbh, $schema, $enteredby2);
            $output .= &add_col() . $entrydate2;
            $output .= &add_col_link ("javascript:display_user($proofreadby)") . &get_fullname($dbh, $schema, $proofreadby);
            $output .= &add_col() . $proofreaddate;
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows1 > 0);

         $csr = $dbh->prepare("select document, commentnum, createdby, datecreated, text from $schema.comments_entry where createdby <> $userid order by document, commentnum");
         $csr->execute;
         $output = "<tr><td align=right>\n";
         $output .= &start_table(4, 'right', 120, 120, 80, 430);
         $output .= &title_row("$entryBackground", "$entryForeground", "<font size=3>Proofread Comments ($counts{commentsProofread})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to proofread</font></i>)");
         $output .= &add_header_row();
         $output .= &add_col() . 'Doc ID/Comment ID';
         $output .= &add_col() . 'Entered By';
         $output .= &add_col() . 'Date Entered';
         $output .= &add_col() . 'Comment Text';
         my $rows2 = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows2++;
            my ($docid, $commentid, $enteredby, $entrydate, $text) = @values;
            if (defined($text) && ($text ne "")) {
               $output .= &add_row();
               my $formattedid = &formatID($CRDType, 6, $docid) . " / " . &formatID("", 4, $commentid);
               $output .= &add_col_link ("javascript:comments('proofread',$docid,$commentid)") . $formattedid;
               $output .= &add_col_link ("javascript:display_user($enteredby)") . &get_fullname($dbh, $schema, $enteredby);
               $output .= &add_col() . $entrydate;
               $output .= &add_col() . &getDisplayString($text, 70);
            }
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows2 > 0);
         print "<tr><td height=15> </td></tr>\n" if (($rows1 + $rows2) > 0);
      ################################################################################################################################
      } elsif ($section eq 'response_entry') {                                                         #  Responses Entry/Proofread  #
      ################################################################################################################################
         print "<tr><td align=right>\n";
         print "<table width=750 cellpadding=0 cellspacing=0 border=0>\n";
         print "<ul><tr><td><li><font size=3><b>Enter Response to $CRDType<input type=text size=6 name=responseproxycdid> / <input type=text size=3 name=responseproxycid>";
         print &nbspaces(3) . "<input type=button name=responsego value='Go' onClick=javascript:responses('enter')></b></font></td></tr></ul>\n";
         print "</table>\n";
         print "</td></tr>\n";
         print "<tr><td height=15> </td></tr>\n";
         my $csr = $dbh->prepare("select document, commentnum, enteredby, entrydate, text, version from $schema.response_version_entry where enteredby <> $userid order by document, commentnum");
         $csr->execute;
         my $output = "<tr><td align=right>\n";
         $output .= &start_table(4, 'right', 120, 120, 80, 430);
         $output .= &title_row("$entryBackground", "$entryForeground", "<font size=3>Proofread Responses ($counts{responseProofread})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to proofread</font></i>)");
         $output .= &add_header_row();
         $output .= &add_col() . 'Doc ID/Comment ID';
         $output .= &add_col() . 'Entered By';
         $output .= &add_col() . 'Date Entered';
         $output .= &add_col() . 'Response Text';
         my $rows = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows++;
            my ($docid, $commentid, $enteredby, $entrydate, $text, $version) = @values;
            $output .= &add_row();
            my $formattedid = &formatID($CRDType, 6, $docid) . " / " . &formatID("", 4, $commentid);
            $output .= &add_col_link ("javascript:responses('proofread',$docid,$commentid,$version)") . $formattedid;
            $output .= &add_col_link ("javascript:display_user($enteredby)") . &get_fullname($dbh, $schema, $enteredby);
            $output .= &add_col() . $entrydate;
            $output .= &add_col() . &getDisplayString($text, 70);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows > 0);
         print "<tr><td height=15> </td></tr>\n";
      ################################################################################################################################
      } elsif ($section eq 'summary_entry') {                #  Summary Comments, Comments/Responses, and Responses Entry/Proofread  #
      ################################################################################################################################
         print "<tr><td align=right>\n";
         print "<table width=750 cellpadding=0 cellspacing=0 border=0>\n";
         print "<ul><tr><td><li><font size=3><b>Enter a new&nbsp;&nbsp;<a href=javascript:summary_comments('enter_summary_comment')>Summary Comment/Response</a></td></tr>\n";
         print "</table>\n";
         print "</td></tr>\n";
         print "<tr><td height=15> </td></tr>\n";
         print "<tr><td align=right>\n";
         print "<table width=750 cellpadding=0 cellspacing=0 border=0><tr><td><li><font size=3><b>Enter a Response to Summary Comment&nbsp;&nbsp;SCR\n";
         print "<input type=text size=6 name=summaryresponseproxyid>&nbsp;&nbsp;&nbsp;\n";
         print "<input type=button name=summaryresponsego value='Go' onClick=javascript:summary_comments('proxy_enter')>\n";
         print "</b></font></td></tr></ul>\n";
         print "</table>\n";
         print "</td></tr>\n";
         print "<tr><td height=15> </td></tr>\n";
         my $csr = $dbh->prepare("select id, createdby, datecreated, commenttext from $schema.summary_comment_entry where createdby <> $userid order by id");
         $csr->execute;
         my $output = "<tr><td align=right>\n";
         $output .= &start_table(4, 'right', 60, 160, 80, 450);
         $output .= &title_row("$entryBackground", "$entryForeground", "<font size=3>Proofread Summary Comments and Summary Comment/Response Pairs ($counts{summaryCommentProofread})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to proofread</font></i>)");
         $output .= &add_header_row();
         $output .= &add_col() . 'ID';
         $output .= &add_col() . 'Entered By';
         $output .= &add_col() . 'Date Entered';
         $output .= &add_col() . 'Summary Comment Text';
         my $rows = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows++;
            my ($id, $enteredby, $entrydate, $text) = @values;
            $output .= &add_row();
            $output .= &add_col_link ("javascript:summary_comments('proofread_summary_comment',$id)") . &formatID('SCR', 4, $id);
            $output .= &add_col_link ("javascript:display_user($enteredby)") . &get_fullname($dbh, $schema, $enteredby);
            $output .= &add_col() . $entrydate;
            $output .= &add_col() . &getDisplayString($text, 70);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows > 0);
         $output .= "<tr><td height=15> </td></tr>\n";

         $csr = $dbh->prepare("select summarycomment, enteredby, entrydate, text from $schema.summary_response_entry where enteredby <> $userid order by summarycomment");
         $csr->execute;
         $output = "<tr><td align=right>\n";
         $output .= &start_table(4, 'right', 60, 160, 80, 450);
         $output .= &title_row("$entryBackground", "$entryForeground", "<font size=3>Proofread Responses to Summary Comments ($counts{summaryResponseProofread})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to proofread</font></i>)");
         $output .= &add_header_row();
         $output .= &add_col() . 'ID';
         $output .= &add_col() . 'Entered By';
         $output .= &add_col() . 'Date Entered';
         $output .= &add_col() . 'Response Text';
         $rows = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows++;
            my ($id, $enteredby, $entrydate, $text) = @values;
            $output .= &add_row();
            my $formattedid = &formatID('SCR', 4, $id);
            $output .= &add_col_link ("javascript:summary_comments('proofread_proxy_enter',$id)") . $formattedid;
            $output .= &add_col_link ("javascript:display_user($enteredby)") . &get_fullname($dbh, $schema, $enteredby);
            $output .= &add_col() . $entrydate;
            $output .= &add_col() . &getDisplayString($text, 70);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows > 0);
         print "<tr><td height=15> </td></tr>\n";
      ################################################################################################################################
      } elsif ($section eq 'preapproved_entry') {                                               #  Preapproved Text Entry/Proofread  #
      ################################################################################################################################
         print "<tr><td align=right>\n";
         print "<table width=750 cellpadding=0 cellspacing=0 border=0>\n";
         print "<ul><tr><td><li><font size=3><b>Enter a&nbsp;&nbsp;<a href=javascript:preapproved_text('enter_preapproved')>Preapproved Response</a>";
         print "&nbsp;&nbsp;or&nbsp;&nbsp;<a href=javascript:preapproved_text('enter_messagepoint')>Message Point</a></b></td></tr></ul></table>\n";
         print "</td></tr>\n<tr><td height=15> </td></tr>\n";
         my %preapprovedTextTypes = %{&getLookupValues($dbh, $schema, 'preapproved_text_type')};
         my $csr = $dbh->prepare("select id, enteredby, entrydate, texttype, text from $schema.preapproved_text_entry where enteredby <> $userid order by id");
         $csr->execute;
         my $output = "<tr><td align=right>\n";
         $output .= &start_table(5, 'right', 60, 120, 80, 130, 360);
         $output .= &title_row("$entryBackground", "$entryForeground", "<font size=3>Proofread Preapproved Text ($counts{preapprovedProofread})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to proofread</font></i>)");
         $output .= &add_header_row();
         $output .= &add_col() . 'ID';
         $output .= &add_col() . 'Entered by';
         $output .= &add_col() . 'Date Entered';
         $output .= &add_col() . 'Type';
         $output .= &add_col() . 'Preapproved Text';
         my $rows = 0;
         while (my @values = $csr->fetchrow_array) {
            my ($id, $enteredby, $entrydate, $texttype, $text) = @values;
            $rows++;
            $output .= &add_row();
            $output .= &add_col_link ("javascript:preapproved_text('proofread',$id)") . &formatID('PAT', 4, $id);
            $output .= &add_col_link ("javascript:display_user($enteredby)") . &get_fullname($dbh, $schema, $enteredby);
            $output .= &add_col() . $entrydate;
            $output .= &add_col() . $preapprovedTextTypes{$texttype};
            $output .= &add_col() . &getDisplayString($text, 60);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows > 0);
         print "<tr><td height=15> </td></tr>\n";
      ################################################################################################################################
      } elsif ($section eq 'coordinator') {                                                          #  Bin Coordinator Assignments  #
      ################################################################################################################################
         print "<tr><td align=right>\n";
         my $output;
         my $count = 0;
         my $responseStatus = 1; # BIN COORDINATOR ASSIGN
         my (@bins, $bin);
         my $csr = $dbh->prepare("select id from $schema.bin where coordinator = $userid");
         $csr->execute;
         while ($bin = $csr->fetchrow_array) {
            push(@bins, $bin);
         }
         $csr->finish;
         my $binlist = "(";
         foreach $bin (@bins) {
            $binlist .= ", " if ($count++ != 0);
            $binlist .= $bin;
         }
         $binlist .= ")";
         if ($count) {
            tie my %binlookup, "Tie::IxHash";
            %binlookup = &get_lookup_values($dbh, $schema, 'bin', 'id', 'name', "coordinator = $userid order by name");
            my $submit = &writeControl(label => 'Go', callback => "summarizeMultiple($responseStatus)", useLinks => 0);
            $output .= "<table width=750 cellpadding=0 cellspacing=0 border=0>\n";
            $output .= "<ul><tr><td><li><font size=3><b>Attach Directly to Summary:</b>" . &nbspaces(2) . &build_drop_box('bin1', \%binlookup, 1) . $submit . "</font></li></td></tr></ul>";
            $output .= "<tr><td height=15> </td></tr>\n";
            $output .= "</table></td></tr>";
            print $output;
         }

         my $sql = "select c.document, c.commentnum, c.proofreaddate, c.text, c.bin, b.name, r.version, nvl(d.commentor,0), d.namestatus ";
         $sql .= "from $schema.comments c, $schema.bin b, $schema.response_version r, $schema.document d ";
         $sql .= "where c.bin = b.id and b.coordinator = $userid and c.document = r.document and c.commentnum = r.commentnum and ";
         $sql .= "r.status = 1 and c.dupsimstatus = 1 and c.summary is NULL and r.version = 1 and c.document = d.id " . &applyBinFilter();
         $sql .= "order by b.name, c.document, c.commentnum";
         $csr = $dbh->prepare($sql);
         $csr->execute;
         $output = "<tr><td align=right>\n";
         $output .= &start_table(5, 'right', 80, 20, 70, 40, 540);
         $output .= &title_row('#c0ffff', '#000099', "<font size=3>Comments Awaiting Initial Assignment ($counts{initialAssign})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on 'Doc ID / Comment ID' to assign comment</font></i>)");
         $output .= &add_header_row();
         $output .= &writeResponseAssignmentLink(writeHeader => 1);
         $output .= &writePrintCommentLink(writeHeader => 1);
         $output .= &writeDate(writeHeader => 1, headerText => "Date<br>Entered");
         $output .= &writeBin(writeHeader => 1);
         $output .= &writeCommentorOrgAndText(writeHeader => 1);
         my $rows1 = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows1++;
            my ($docid, $commentid, $date, $text, $bin, $binname, $version, $commentor, $namestatus) = @values;
            $output .= &add_row();
            $output .= &writeResponseAssignmentLink(action => "assign", document => $docid, comment => $commentid, version => $version, prompt => "make assignment");
            $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
            $output .= &writeDate(date => $date);
            $output .= &writeBin(binID => $bin, binName => $binname);
            $output .= &writeCommentorOrgAndText(nameStatus => $namestatus, commentor => $commentor, text => $text);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows1 > 0);

         $sql = "select c.document, c.commentnum, r.dateupdated, r.responsewriter, c.text, c.bin, b.name, r.version, nvl(d.commentor,0), d.namestatus, nvl(r.summary,0), r.dupsimstatus ";
         $sql .= "from $schema.comments c, $schema.bin b, $schema.response_version r, $schema.document d ";
         $sql .= "where c.bin = b.id and b.coordinator = $userid and c.document = r.document and c.commentnum = r.commentnum and ";
         $sql .= "r.status = 1 and c.dupsimstatus = 1 and r.version > 1 and c.document = d.id " . &applyBinFilter();
         $sql .= "order by b.name, c.document, c.commentnum";
         $csr = $dbh->prepare($sql);
         $csr->execute;
         $output = "<tr><td align=right>\n";
         $output .= &start_table(6, 'right', 80, 20, 70, 40, 60, 480);
         $output .= &title_row('#c0ffff', '#000099', "<font size=3>Rejected Responses Awaiting Reassignment ($counts{reassign})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on 'Doc ID / Comment ID' to reassign</font></i>)");
         $output .= &add_header_row();
         $output .= &writeResponseAssignmentLink(writeHeader => 1);
         $output .= &writePrintCommentLink(writeHeader => 1);
         $output .= &writeDate(writeHeader => 1);
         $output .= &writeBin(writeHeader => 1);
         $output .= &writeUser(writeHeader => 1);
         $output .= &writeCommentorOrgAndText(writeHeader => 1);
         my $rows2 = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows2++;
            my ($docid, $commentid, $date, $writer, $text, $bin, $binname, $version, $commentor, $namestatus, $markedSummarized, $markedDuplicate) = @values;
            if ($markedDuplicate != 1) {
               $text = "<font color=#ff0000>Response Writer Marked Comment as Duplicate</font>";
            } elsif ($markedSummarized) {
               $text = "<font color=#ff0000>Response Writer Summarized with " . &formatID('SCR', 4, $markedSummarized) . "</font>";
            }
            $output .= &add_row();
            $output .= &writeResponseAssignmentLink(action => "assign", document => $docid, comment => $commentid, version => $version, prompt => "reassign");
            $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
            $output .= &writeDate(date => $date);
            $output .= &writeBin(binID => $bin, binName => $binname);
            $output .= &writeUser(userID => $writer);
            $output .= &writeCommentorOrgAndText(nameStatus => $namestatus, commentor => $commentor, text => $text, textWidth => 75);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows2 > 0);

         $sql = "select c.document, c.commentnum, r.dateupdated, r.responsewriter, r.coordeditedtext, r.lastsubmittedtext, c.bin, b.name, r.version, nvl(d.commentor,0), d.namestatus, nvl(r.summary,0), r.dupsimstatus ";
         $sql .= "from $schema.comments c, $schema.bin b, $schema.response_version r, $schema.document d ";
         $sql .= "where c.bin = b.id and b.coordinator = $userid and c.document = r.document and c.commentnum = r.commentnum and r.status = 6 and c.document = d.id " . &applyBinFilter();
         $sql .= "order by b.name, c.document, c.commentnum";
         $csr = $dbh->prepare($sql);
         $csr->execute;
         $output = "<tr><td align=right>\n";
         $output .= &start_table(6, 'right', 80, 20, 70, 40, 60, 480);
         $output .= &title_row('#c0ffff', '#000099', "<font size=3>Responses Awaiting Acceptance Decision ($counts{bcaccept})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on 'Doc ID / Comment ID' to accept/reject response</font></i>)");
         $output .= &add_header_row();
         $output .= &writeResponseAssignmentLink(writeHeader => 1);
         $output .= &writePrintCommentLink(writeHeader => 1);
         $output .= &writeDate(writeHeader => 1);
         $output .= &writeBin(writeHeader => 1);
         $output .= &writeUser(writeHeader => 1);
         $output .= &writeCommentorOrgAndText(writeHeader => 1);
         my $rows3 = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows3++;
            my ($docid, $commentid, $date, $writer, $coordeditedtext, $text, $bin, $binname, $version, $commentor, $namestatus, $markedSummarized, $markedDuplicate) = @values;
            if ($markedDuplicate != 1) {
               $text = "<font color=#ff0000>Response Writer Marked Comment as Duplicate</font>";
            } elsif ($markedSummarized) {
               $text = "<font color=#ff0000>Response Writer Summarized with " . &formatID('SCR', 4, $markedSummarized) . "</font>";
            }
            $text = $coordeditedtext if (defined($coordeditedtext) && ($coordeditedtext ne ""));
            $output .= &add_row();
            $output .= &writeResponseAssignmentLink(action => "accept", document => $docid, comment => $commentid, version => $version, prompt => "enter acceptance decision");
            $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
            $output .= &writeDate(date => $date);
            $output .= &writeBin(binID => $bin, binName => $binname);
            $output .= &writeUser(userID => $writer);
            $output .= &writeCommentorOrgAndText(nameStatus => $namestatus, commentor => $commentor, text => $text, textWidth => 75);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows3 > 0);
         print "<tr><td height=15> </td></tr>\n" if (($count + $rows1 + $rows2 + $rows3) > 0);
      ################################################################################################################################
      } elsif ($section eq 'write_response') {                                                  #  Response Development Assignments  #
      ################################################################################################################################
         print "<tr><td align=right>\n";
         my $output;
         my $count = 0;
         my $responseStatus = 2; # RESPONSE_DEVELOPMENT
         my (@bins, $bin);
         my $csr = $dbh->prepare("select id from $schema.bin where coordinator = $userid");
         $csr->execute;
         while ($bin = $csr->fetchrow_array) {
            push(@bins, $bin);
         }
         $csr->finish;
         $csr = $dbh->prepare("select bin from $schema.default_tech_reviewer where reviewer = $userid");
         $csr->execute;
         while ($bin = $csr->fetchrow_array) {
            push(@bins, $bin);
         }
         $csr->finish;
         my $binlist = "(";
         foreach $bin (@bins) {
            $binlist .= ", " if ($count++ != 0);
            $binlist .= $bin;
         }
         $binlist .= ")";
         if ($count) {
            tie my %binlookup, "Tie::IxHash";
            %binlookup = &get_lookup_values($dbh, $schema, 'bin', 'id', 'name', "id in $binlist order by name");
            my $submit = &writeControl(label => 'Go', callback => "summarizeMultiple($responseStatus)", useLinks => 0);
            $output .= "<table width=750 cellpadding=0 cellspacing=0 border=0>\n";
            $output .= "<ul><tr><td><li><font size=3><b>Attach Directly to Summary:</b>" . &nbspaces(2) . &build_drop_box('bin2', \%binlookup, 1) . $submit . "</font></li></td></tr></ul>";
            $output .= "<tr><td height=15> </td></tr>\n";
            $output .= "</table></td></tr>";
            print $output;
         }

         my $sql = "select c.document, c.commentnum, r.dateupdated, c.text, c.bin, b.name, r.version, nvl(d.commentor,0), d.namestatus ";
         $sql .= "from $schema.comments c, $schema.bin b, $schema.response_version r, $schema.document d ";
         $sql .= "where c.bin = b.id and r.responsewriter = $userid and c.document = r.document and c.commentnum = r.commentnum and r.status = 2 and c.document = d.id " . &applyBinFilter();
         $sql .= "order by b.name, c.document, c.commentnum";
         $csr = $dbh->prepare($sql);
         $csr->execute;
         $output = "<tr><td align=right>\n";
         $output .= &start_table(5, 'right', 80, 20, 70, 40, 540);
         $output .= &title_row('#f0e0b0', '#000099', "<font size=3>Develop Response ($counts{developResponse})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on 'Doc ID / Comment ID' to enter/update response</font></i>)");
         $output .= &add_header_row();
         $output .= &writeResponseAssignmentLink(writeHeader => 1);
         $output .= &writePrintCommentLink(writeHeader => 1);
         $output .= &writeDate(writeHeader => 1);
         $output .= &writeBin(writeHeader => 1);
         $output .= &writeCommentorOrgAndText(writeHeader => 1);
         my $rows1 = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows1++;
            my ($docid, $commentid, $date, $text, $bin, $binname, $version, $commentor, $namestatus) = @values;
            $output .= &add_row();
            $output .= &writeResponseAssignmentLink(action => "write", document => $docid, comment => $commentid, version => $version, prompt => "enter/update response");
            $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
            $output .= &writeDate(date => $date);
            $output .= &writeBin(binID => $bin, binName => $binname);
            $output .= &writeCommentorOrgAndText(nameStatus => $namestatus, commentor => $commentor, text => $text);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows1 > 0);

         $sql = "select c.document, c.commentnum, r.dateupdated, r.reviewedtext, r.lastsubmittedtext, c.bin, b.name, r.version, nvl(d.commentor,0), d.namestatus ";
         $sql .= "from $schema.comments c, $schema.bin b, $schema.response_version r, $schema.document d ";
         $sql .= "where c.bin = b.id and r.responsewriter = $userid and c.document = r.document and c.commentnum = r.commentnum and r.status = 4 and c.document = d.id " . &applyBinFilter();
         $sql .= "order by b.name, c.document, c.commentnum";
         $csr = $dbh->prepare($sql);
         $csr->execute;
         $output = "<tr><td align=right>\n";
         $output .= &start_table(5, 'right', 80, 20, 70, 40, 540);
         $output .= &title_row('#f0e0b0', '#000099', "<font size=3>Modify Response ($counts{modifyResponse})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on 'Doc ID / Comment ID' to enter/update modified response</font></i>)");
         $output .= &add_header_row();
         $output .= &writeResponseAssignmentLink(writeHeader => 1);
         $output .= &writePrintCommentLink(writeHeader => 1);
         $output .= &writeDate(writeHeader => 1);
         $output .= &writeBin(writeHeader => 1);
         $output .= &writeCommentorOrgAndText(writeHeader => 1);
         my $rows2 = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows2++;
            my ($docid, $commentid, $date, $reviewedtext, $text, $bin, $binname, $version, $commentor, $namestatus) = @values;
            $text = $reviewedtext if (defined($reviewedtext) && ($reviewedtext ne ""));
            $output .= &add_row();
            $output .= &writeResponseAssignmentLink(action => "modify", document => $docid, comment => $commentid, version => $version, prompt => "enter/update modified response");
            $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
            $output .= &writeDate(date => $date);
            $output .= &writeBin(binID => $bin, binName => $binname);
            $output .= &writeCommentorOrgAndText(nameStatus => $namestatus, commentor => $commentor, text => $text);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows2 > 0);
         print "<tr><td height=15> </td></tr>\n" if (($count + $rows1 + $rows2) > 0);
      ################################################################################################################################
      } elsif ($section eq 'tech_review') {                                                #  Response Technical Review Assignments  #
      ################################################################################################################################
         my $sql = "select c.document, c.commentnum, r.dateupdated, r.responsewriter, r.lastsubmittedtext, c.bin, b.name, r.version, nvl(d.commentor,0), d.namestatus ";
         $sql .= "from $schema.comments c, $schema.bin b, $schema.response_version r, $schema.technical_review t, $schema.document d ";
         $sql .= "where c.bin = b.id and t.reviewer = $userid and c.document = r.document and c.commentnum = r.commentnum  and ";
         $sql .= "r.document = t.document and r.commentnum = t.commentnum and r.version = t.version and r.status = 3 and t.status = 1 and c.document = d.id " . &applyBinFilter();
         $sql .= "order by b.name, c.document, c.commentnum";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         my $output = "<tr><td align=right>\n";
         $output .= &start_table(6, 'right', 80, 20, 70, 40, 60, 480);
         $output .= &title_row('#cdecff', '#000099', "<font size=3>Technical Review ($counts{techReview})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on 'Doc ID / Comment ID' to enter technical review</font></i>)");
         $output .= &add_header_row();
         $output .= &writeResponseAssignmentLink(writeHeader => 1);
         $output .= &writePrintCommentLink(writeHeader => 1);
         $output .= &writeDate(writeHeader => 1);
         $output .= &writeBin(writeHeader => 1);
         $output .= &writeUser(writeHeader => 1);
         $output .= &writeCommentorOrgAndText(writeHeader => 1);
         my $rows1 = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows1++;
            my ($docid, $commentid, $date, $writer, $text, $bin, $binname, $version, $commentor, $namestatus) = @values;
            $output .= &add_row();
            $output .= &writeResponseAssignmentLink(action => "review", document => $docid, comment => $commentid, version => $version, prompt => "enter technical review");
            $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
            $output .= &writeDate(date => $date);
            $output .= &writeBin(binID => $bin, binName => $binname);
            $output .= &writeUser(userID => $writer);
            $output .= &writeCommentorOrgAndText(nameStatus => $namestatus, commentor => $commentor, text => $text, textWidth => 75);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=30> </td></tr>\n";
         print $output if ($rows1 > 0);
      ################################################################################################################################
      } elsif ($section eq 'tech_edit') {                                                    #  Response Technical Edit Assignments  #
      ################################################################################################################################
         my $sql = "select c.document, c.commentnum, r.dateupdated, r.responsewriter, r.techeditedtext, r.lastsubmittedtext, c.bin, b.name, r.version, nvl(d.commentor,0), d.namestatus ";
         $sql .= "from $schema.comments c, $schema.bin b, $schema.response_version r, $schema.document d ";
         $sql .= "where c.bin = b.id and c.document = r.document and c.commentnum = r.commentnum and r.status = 5 and r.techeditor = $userid and c.document = d.id " . &applyBinFilter();
         $sql .= "order by b.name, c.document, c.commentnum";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         my $output = "<tr><td align=right>\n";
         $output .= &start_table(6, 'right', 80, 20, 70, 40, 60, 480);
         my $userName = &get_fullname($dbh, $schema, $userid);
         $output .= &title_row('#f0f080', '#000099', "<font size=3>Technical Edit - Assigned to $userName ($counts{techEditAssigned})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on 'Doc ID / Comment ID' to enter technical edits</font></i>)");
         $output .= &add_header_row();
         $output .= &writeResponseAssignmentLink(writeHeader => 1);
         $output .= &writePrintCommentLink(writeHeader => 1);
         $output .= &writeDate(writeHeader => 1);
         $output .= &writeBin(writeHeader => 1);
         $output .= &writeUser(writeHeader => 1);
         $output .= &writeCommentorOrgAndText(writeHeader => 1);
         my $rows1 = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows1++;
            my ($docid, $commentid, $date, $writer, $techeditedtext, $text, $bin, $binname, $version, $commentor, $namestatus) = @values;
            $text = $techeditedtext if (defined($techeditedtext) && ($techeditedtext ne ""));
            $output .= &add_row();
            $output .= &writeResponseAssignmentLink(action => "edit", document => $docid, comment => $commentid, version => $version, prompt => "enter technical edits");
            $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
            $output .= &writeDate(date => $date);
            $output .= &writeBin(binID => $bin, binName => $binname);
            $output .= &writeUser(userID => $writer);
            $output .= &writeCommentorOrgAndText(nameStatus => $namestatus, commentor => $commentor, text => $text, textWidth => 75);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows1 > 0);

         $sql = "select c.document, c.commentnum, r.dateupdated, r.responsewriter, r.techeditedtext, r.lastsubmittedtext, c.bin, b.name, r.version, nvl(d.commentor,0), d.namestatus ";
         $sql .= "from $schema.comments c, $schema.bin b, $schema.response_version r, $schema.document d ";
         $sql .= "where c.bin = b.id and c.document = r.document and c.commentnum = r.commentnum and r.status = 5 and r.techeditor is null and c.document = d.id " . &applyBinFilter();
         $sql .= "order by b.name, c.document, c.commentnum";
         $csr = $dbh->prepare($sql);
         $csr->execute;
         $output = "<tr><td align=right>\n";
         $output .= &start_table(6, 'right', 80, 20, 70, 40, 60, 480);
         $output .= &title_row('#f0f080', '#000099', "<font size=3>Technical Edit - Unassigned ($counts{techEditUnassigned})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on 'Doc ID / Comment ID' to enter technical edits</font></i>)");
         $output .= &add_header_row();
         $output .= &writeResponseAssignmentLink(writeHeader => 1);
         $output .= &writePrintCommentLink(writeHeader => 1);
         $output .= &writeDate(writeHeader => 1);
         $output .= &writeBin(writeHeader => 1);
         $output .= &writeUser(writeHeader => 1);
         $output .= &writeCommentorOrgAndText(writeHeader => 1);
         my $rows2 = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows2++;
            my ($docid, $commentid, $date, $writer, $techeditedtext, $text, $bin, $binname, $version, $commentor, $namestatus) = @values;
            $text = $techeditedtext if (defined($techeditedtext) && ($techeditedtext ne ""));
            $output .= &add_row();
            $output .= &writeResponseAssignmentLink(action => "edit", document => $docid, comment => $commentid, version => $version, prompt => "enter technical edits");
            $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
            $output .= &writeDate(date => $date);
            $output .= &writeBin(binID => $bin, binName => $binname);
            $output .= &writeUser(userID => $writer);
            $output .= &writeCommentorOrgAndText(nameStatus => $namestatus, commentor => $commentor, text => $text, textWidth => 75);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=15> </td></tr>\n";
         print $output if ($rows2 > 0);

         print "<tr><td height=15> </td></tr>\n" if (($rows1 + $rows2) > 0);
      ################################################################################################################################
      } elsif ($section eq 'nepa_approval') {                                            #  NEPA/Policy Review/Approval Assignments  #
      ################################################################################################################################
         my $sql = "select c.document, c.commentnum, r.dateupdated, b.coordinator, r.nepaeditedtext, r.lastsubmittedtext, c.bin, b.name, r.version, nvl(d.commentor,0), d.namestatus ";
         $sql .= "from $schema.comments c, $schema.bin b, $schema.response_version r, $schema.document d ";
         $sql .= "where c.bin = b.id and c.document = r.document and c.commentnum = r.commentnum and ";
         $sql .= "r.status = 7 and b.nepareviewer = $userid and c.document = d.id " . &applyBinFilter();
         $sql .= "order by b.name, c.document, c.commentnum";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         my $output = "<tr><td align=right>\n";
         $output .= &start_table(6, 'right', 80, 20, 70, 40, 60, 480);
         $output .= &title_row('#c0ffc0', '#000099', "<font size=3>$firstReviewName Review/Approval ($counts{nepaReview})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on 'Doc ID / Comment ID' to enter approval decision</font></i>)");
         $output .= &add_header_row();
         $output .= &writeResponseAssignmentLink(writeHeader => 1);
         $output .= &writePrintCommentLink(writeHeader => 1);
         $output .= &writeDate(writeHeader => 1);
         $output .= &writeBin(writeHeader => 1);
         $output .= &writeUser(writeHeader => 1, headerText => "Bin<br>Coordinator");
         $output .= &writeCommentorOrgAndText(writeHeader => 1);
         my $rows = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows++;
            my ($docid, $commentid, $date, $coordinator, $nepaeditedtext, $text, $bin, $binname, $version, $commentor, $namestatus) = @values;
            $text = $nepaeditedtext if (defined($nepaeditedtext) && ($nepaeditedtext ne ""));
            $output .= &add_row();
            $output .= &writeResponseAssignmentLink(action => "nepareview", document => $docid, comment => $commentid, version => $version, prompt => "enter approval decision");
            $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
            $output .= &writeDate(date => $date);
            $output .= &writeBin(binID => $bin, binName => $binname);
            $output .= &writeUser(userID => $coordinator);
            $output .= &writeCommentorOrgAndText(nameStatus => $namestatus, commentor => $commentor, text => $text, textWidth => 75);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=30> </td></tr>\n";
         print $output if ($rows > 0);
      ################################################################################################################################
      } elsif ($section eq 'doe_approval') {                                                     #  DOE Review/Approval Assignments  #
      ################################################################################################################################
         my $sql = "select c.document, c.commentnum, r.dateupdated, b.coordinator, r.doeeditedtext, r.lastsubmittedtext, c.bin, b.name, r.version, nvl(d.commentor,0), d.namestatus ";
         $sql .= "from $schema.comments c, $schema.bin b, $schema.response_version r, $schema.document d ";
         $sql .= "where c.bin = b.id and c.document = r.document and c.commentnum = r.commentnum and ";
         $sql .= "r.status = 8 and c.doereviewer = $userid and c.document = d.id " . &applyBinFilter();
         $sql .= "order by b.name, c.document, c.commentnum ";
         my $csr = $dbh->prepare($sql);
         $csr->execute;
         my $output = "<tr><td align=right>\n";
         $output .= &start_table(6, 'right', 80, 20, 70, 40, 60, 480);
         $output .= &title_row('#ffc0c0', '#000099', "<font size=3>$secondReviewName Review/Approval ($counts{doeReview})</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on 'Doc ID / Comment ID' to enter approval decision</font></i>)");
         $output .= &add_header_row();
         $output .= &writeResponseAssignmentLink(writeHeader => 1);
         $output .= &writePrintCommentLink(writeHeader => 1);
         $output .= &writeDate(writeHeader => 1);
         $output .= &writeBin(writeHeader => 1);
         $output .= &writeUser(writeHeader => 1, headerText => "Bin<br>Coordinator");
         $output .= &writeCommentorOrgAndText(writeHeader => 1);
         my $rows = 0;
         while (my @values = $csr->fetchrow_array) {
            $rows++;
            my ($docid, $commentid, $date, $coordinator, $doeeditedtext, $text, $bin, $binname, $version, $commentor, $namestatus) = @values;
            $text = $doeeditedtext if (defined($doeeditedtext) && ($doeeditedtext ne ""));
            $output .= &add_row();
            $output .= &writeResponseAssignmentLink(action => "doereview", document => $docid, comment => $commentid, version => $version, prompt => "enter approval decision");
            $output .= &writePrintCommentLink(document => $docid, comment => $commentid);
            $output .= &writeDate(date => $date);
            $output .= &writeBin(binID => $bin, binName => $binname);
            $output .= &writeUser(userID => $coordinator);
            $output .= &writeCommentorOrgAndText(nameStatus => $namestatus, commentor => $commentor, text => $text, textWidth => 75);
         }
         $csr->finish;
         $output .= &end_table();
         $output .= "</td></tr>\n";
         $output .= "<tr><td height=30> </td></tr>\n";
         print $output if ($rows > 0);
      ################################################################################################################################
      } elsif ($section eq 'concurrence') {                                                     #  Observer Concurrence Assignments  #
      ################################################################################################################################
         my ($rows1, $rows2, $allRows) = (0, 0, 0);
         my %concurTypes = %{&getLookupValues($dbh, $schema, 'concurrence_type')};
         my %responseStatus = %{&getLookupValues($dbh, $schema, 'response_status')};
         my $sql = "select bin from $schema.concurrer c where c.userid = $userid and c.concurrencetype = :param1";
         my $csr = $dbh->prepare($sql);

         $sql = "select c.document, c.commentnum, r.status, r.lastsubmittedtext from $schema.comments c, $schema.response_version r ";
         $sql .= "where c.document = r.document and c.commentnum = r.commentnum and ";
         $sql .= "c.bin = :param1 and r.status >= 7 and r.status <= 9 and ";
         $sql .= "not exists (select 1 from $schema.concurrence cc where cc.document = c.document and cc.commentnum = c.commentnum ";
         $sql .= "and cc.concurrencetype = :param2 and cc.concurs = 'T') ";
         $sql .= "order by c.document, c.commentnum";
         my $csr2 = $dbh->prepare($sql);

         $sql = "select sc.id, sc.title from $schema.summary_comment sc ";
         $sql .= "where sc.bin = :param1 and sc.dateapproved is not null and ";
         $sql .= "not exists (select 1 from $schema.concurrence_summary scc where sc.id = scc.summarycomment ";
         $sql .= "and scc.concurrencetype = :param2 and scc.concurs = 'T') ";
         $sql .= "order by sc.id";
         my $csr3 = $dbh->prepare($sql);

         foreach my $concurType (keys (%concurTypes)) {
            my $output1 = "<tr><td align=right>\n";
            $output1 .= &start_table(6, 'right', 120, 20, 40, 100, 80, 390);
            $output1 .= &title_row('#ffffaa', '#000099', "<font size=3>Individual Responses Requiring $concurTypes{$concurType} Concurrence (xxx)</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on 'Doc ID / Comment ID' to to review/concur</font></i>)");
            $output1 .= &add_header_row();
            $output1 .= &writeConcurrenceLink(writeHeader => 1, headerText => "Doc ID /<br>Comment ID");
            $output1 .= &writePrintCommentLink(writeHeader => 1);
            $output1 .= &writeBin(writeHeader => 1);
            $output1 .= &writeResponseStatus(writeHeader => 1);
            $output1 .= &writeConcurrenceStatus(writeHeader => 1);
            $output1 .= &writeResponseText(writeHeader => 1);
            my $output2 = "<tr><td align=right>\n";
            #  $output2 .= &start_table(4, 'right', 80, 40, 80, 550);   table functions can't do two tables at once!!
            #  $output2 .= &title_row('#ffffaa', '#000099', "<font size=3>Summary Comment/Responses Requiring $concurTypes{$concurType} Concurrence (xxx)</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on 'Summary Comment ID' to review/concur</font></i>)");
            #  $output2 .= &add_header_row();
            $output2 .= "<table width=750 cellpadding=4 cellspacing=0 border=1 align=right>\n";
            $output2 .= "<tr><td bgcolor=#ffffaa colspan=4><font color=#000099><b><font size=3>\n";
            $output2 .= "Summary Comment/Responses Requiring $concurTypes{$concurType} Concurrence (xxx)</font>\n";
            $output2 .= "&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on 'Summary Comment ID' to review/concur</font></i>)</b></font></td>\n";
            $output2 .= "</tr><tr bgcolor=#f0f0f0>\n";
            $output2 .= &writeConcurrenceLink(writeHeader => 1, headerText => "Summary<br>Comment ID", useTableFunction => 0);
            $output2 .= &writeBin(writeHeader => 1, useTableFunction => 0);
            $output2 .= &writeConcurrenceStatus(writeHeader => 1, useTableFunction => 0);
            $output2 .= &writeResponseText(writeHeader => 1, headerText => "Summary Comment<br>Title", useTableFunction => 0);
            $output2 .= "</tr>\n";

            $csr->bind_param(":param1", $concurType);
            $csr->execute;
            $rows1 = $rows2 = 0;
            my $useList = ($binFilter == 0);   # Process the subbin list for every top level concur bin if the bin filter is off
            while (my ($concurBin) = $csr->fetchrow_array) {
               my @bins = ();
               my $bincsr = $dbh->prepare("select id from $schema.bin connect by prior id = parent start with id = $concurBin order by id");
               $bincsr->execute;
               while (my ($subbin) = $bincsr->fetchrow_array) {
                  push(@bins, $subbin);
                  if ($subbin == $binFilter) {  # The filter bin is in the subbin tree of this top level concur bin
                     $useList = 1;
                     @bins = @binFilterList;
                     last;
                  }
               }
               $bincsr->finish;
               @bins = () if (!$useList);
               foreach my $bin (@bins) {
                  my ($binname) = $dbh->selectrow_array ("select b.name from $schema.bin b where b.id = $bin");
                  $csr2->bind_param(":param1", $bin);
                  $csr2->bind_param(":param2", $concurType);
                  $csr2->execute;
                  while (my ($docid, $commentid, $status, $text) = $csr2->fetchrow_array) {
                     $rows1++;
                     my ($isNegative) = $dbh->selectrow_array ("select count(*) from $schema.concurrence where document = $docid and commentnum = $commentid and concurrencetype = $concurType");
                     $output1 .= &add_row();
                     $output1 .= &writeConcurrenceLink(type => "individual", concurType => $concurType,  document => $docid, comment => $commentid);
                     $output1 .= &writePrintCommentLink(document => $docid, comment => $commentid);
                     $output1 .= &writeBin(binID => $bin, binName => $binname);
                     $output1 .= &writeResponseStatus(status => $responseStatus{$status});
                     $output1 .= &writeConcurrenceStatus(negative => $isNegative);
                     $output1 .= &writeResponseText(text => $text, textWidth => 55);
                  }
                  $csr2->finish;
                  $csr3->bind_param(":param1", $bin);
                  $csr3->bind_param(":param2", $concurType);
                  $csr3->execute;
                  while (my ($summary, $text) = $csr3->fetchrow_array) {
                     $rows2++;
                     my ($isNegative) = $dbh->selectrow_array ("select count(*) from $schema.concurrence_summary where summarycomment = $summary and concurrencetype = $concurType");
                     #  $output2 .= &add_row();
                     $output2 .= "<tr bgcolor=#ffffff>\n";
                     $output2 .= &writeConcurrenceLink(type => "summary",  concurType => $concurType, id => $summary, useTableFunction => 0);
                     $output2 .= &writeBin(binID => $bin, binName => $binname, useTableFunction => 0);
                     $output2 .= &writeConcurrenceStatus(negative => $isNegative, useTableFunction => 0);
                     $output2 .= &writeResponseText(text => $text, useTableFunction => 0, textWidth => 150);
                     $output2 .= "</tr>\n";
                  }
                  $csr3->finish;
               }
               last if ($useList && ($binFilter != 0));  # Bin filter is on and has been applied, don't bother checking any more concur bins
            }
            $csr->finish;
            $output1 .= &end_table();
            $output1 .= "</td></tr>\n";
            $output1 .= "<tr><td height=30> </td></tr>\n";
            $output1 =~ s/xxx/$rows1/;
            print $output1 if ($rows1 > 0);
            $allRows += $rows1;
            #  $output2 .= &end_table();
            $output2 .= "</table>\n";
            $output2 .= "</td></tr>\n";
            $output2 .= "<tr><td height=30> </td></tr>\n";
            $output2 =~ s/xxx/$rows2/;
            print $output2 if ($rows2 > 0);
            $allRows += $rows2;
         }
         print "<tr><td height=15> </td></tr>\n" if ($allRows > 0);
      }
   };
   &processError(activity => "display $section section") if ($@);
}

sub writeHTTPHeader {
   print $crdcgi->header('text/html');
}

sub writeHead {
   print <<end;
<html>
<head>
   <meta http-equiv=expires content=now>
   <script src=$CRDJavaScriptPath/utilities.js></script>
   <script src=$CRDJavaScriptPath/widgets.js></script>
   <script language=javascript><!--
      function submitForm(script, command) {
         $form.command.value = command;
         $form.action = '$path' + script + '.pl';
         $form.submit();
      }
      function saveFilter() {
         $form.process.value = 'saveFilter';
         $form.target = 'cgiresults';
         submitForm('home', '');
      }
      function summarizeMultiple(response_status) {
         $form.process.value = 'summarizeMultiple';
         $form.response_status.value = response_status;
         if (response_status == 1) {
            $form.bin.value = $form.bin1.value;
         } else if (response_status == 2) {
            $form.bin.value = $form.bin2.value;
         }
         $form.target = 'cgiresults';
         submitForm('home','summarize_multiple');
      }
      function display_user(id) {
         $form.id.value = id;
         submitForm('user_functions', 'displayuser');
      }
      function display_commentor(id) {
         $form.id.value = id;
         submitForm('commentors', 'display');
      }
      function display_bin(id) {
         $form.binid.value = id;
         submitForm('bins', 'browse');
      }
      function document_capture(command) {
         if (command == 'report') {
            $form.id.value = 'doc_capture';
         }
         submitForm('comment_documents', command);
      }
      function comment_documents(command, id) {
         $form.id.value = id;
         submitForm('comment_documents', command);
      }
      function comments(command, id, commentid) {
         $form.id.value = id;
         $form.commentid.value = (command == 'proofread') ? commentid : 0;
         $form.target = (command == 'enter') ? 'cgiresults' : 'main';
         submitForm('comments', command);
      }
      function summary_comments(command, id) {
         if ((command == 'proxy_enter') && (isNaN($form.summaryresponseproxyid.value - 0) || ($form.summaryresponseproxyid.value <= 0) || ($form.summaryresponseproxyid.value > 9999))) {
            alert('Invalid Summary Comment ID');
         }
         else {
            $form.id.value = (command == 'proxy_enter') ? $form.summaryresponseproxyid.value : id;
            submitForm('summary_comments', command);
         }
      }
      function preapproved_text(command, id) {
         $form.id.value = (command == 'proofread') ? id : 0;
         submitForm('preapproved_text', command);
      }
      function responses(command, id, commentid, version) {
         if ((command == 'enter') && (isNaN($form.responseproxycid.value - 0) || ($form.responseproxycid.value <= 0) || ($form.responseproxycid.value > 9999))) {
            alert('Invalid Comment ID');
         }
         else if ((command == 'enter') && (isNaN($form.responseproxycdid.value - 0) || ($form.responseproxycdid.value <= 0) || ($form.responseproxycdid.value > 999999))) {
            alert('Invalid Comment Document ID');
         }
         else {
            $form.id.value = (command == 'enter') ? $form.responseproxycdid.value : id;
            $form.commentid.value = (command == 'enter') ? $form.responseproxycid.value : commentid;
            $form.version.value = (command == 'enter') ? 0 : version;
            $form.target = ((command == 'enter') || (command == 'edit')) ? 'cgiresults' : 'main';
            if (command == 'enter') {
               $form.process.value = 'enter';
            } else if (command == 'edit') {
               $form.process.value = 'assigneditor';
            } else {
               $form.process.value = 0;
            }
            submitForm('responses', command);
         }
      }
      function concur(script, concurtype, id, commentid) {
         $form.id.value = id;
         $form.commentid.value = (script == 'responses') ? commentid : 0;
         $form.concurtype.value = concurtype;
         $form.target = 'main';
         $form.process.value = 0;
         submitForm(script, 'concur');
      }
      function message(command, id) {
         if (message.arguments.length > 1) {
            $form.id.value = id;
         }
         $form.process.value = ((command == 'sentbydelete') || (command == 'senttodelete')) ? 1 : 0;
         $form.target = ((command == 'sentbydelete') || (command == 'senttodelete'))  ? 'cgiresults' : 'main';
         submitForm('messages', command);
      }
   //-->
   </script>
end
   print &sectionHeadTags($form);
   print "</head>\n\n";
}

sub writeBody {
   print "<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n<center>\n";
   print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Home");
   print "<form name=$form method=post>\n";
   print "<input type=hidden name=username value=$username>\n";
   print "<input type=hidden name=userid value=$userid>\n";
   print "<input type=hidden name=schema value=$schema>\n";
   print "<input type=hidden name=command value=0>\n";
   print "<input type=hidden name=id value=0>\n";
   print "<input type=hidden name=commentid value=0>\n";
   print "<input type=hidden name=version value=0>\n";
   print "<input type=hidden name=process value=0>\n";
   print "<input type=hidden name=bin value=0>\n";
   print "<input type=hidden name=binid value=0>\n";
   print "<input type=hidden name=response_status value=0>\n";
   print "<input type=hidden name=concurtype value=0>\n";
   print &sectionBodyTags;
   print "<table width=775 cellpadding=0 cellspacing=0 border=0>\n";
   print "<tr><td height=15> </td></tr>\n";
   my ($hasPreferences) = $dbh->selectrow_array ("select count(*) from $schema.user_preferences where userid = $userid");
   ($binFilter, $subbins) = (!$hasPreferences) ? (0, 'F') : $dbh->selectrow_array ("select nvl(binfilter,0), binfiltersubbins from $schema.user_preferences where userid = $userid");
   &setupBinFilterList();
   if (&showBinFilter()) {
      tie my %binlookup, "Tie::IxHash";
      %binlookup = ('0' => "All Bins", &get_lookup_values($dbh, $schema, 'bin', 'id', 'name', "1=1 order by name"));
      my $submit = &writeControl(label => 'Go', callback => "saveFilter()", useLinks => 0);
      my $output = "<tr><td align=center><b>Show Assignments From:</b>" . &nbspaces(2) . &build_drop_box('filterBin', \%binlookup, $binFilter) . $submit . "</td></tr>";
      my $checked = ($subbins eq 'T') ? "checked" : "";
      $output .= "<tr><td align=center><input type=checkbox name=subbins value=subbins $checked><b>Include All Subbins</b></td></tr>\n";
      $output .= "<tr><td height=25> </td></tr>\n";
      print $output;
   }
   foreach my $section (keys (%sections)) {
      if (sectionIsActive($section)) {
         doHeader($section);
         doSection($section) if &sectionIsOpen ($section);
      }
   }
   print "</table>\n</form>\n</center>\n</font>\n\n";
   print &BuildPrintCommentResponse($username, $userid, $schema, $path);
   print "<script language=javascript><!--\nvar mytext ='$errorstr';\nalert(unescape(mytext));\n//-->\n</script>\n" if ($errorstr);
   print "</body>\n</html>\n";
}

$dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;
if ($process) {
   &processSubmittedData();
} else {
   eval {
      # add a section for concurrence assignments if user has concurrence privileges for at least one bin
      if (&userIsConcurrer(dbh => $dbh, schema => $schema, user => $userid)) {
         $sections{'concurrence'} = { 'privilege' => [ 1 ], 'enabled' => 1, 'defaultOpen' => 0, 'title' => "Observer Review/Concur Assignments"};
      }
      &setupSections ($dbh, \%sections, $userid, $schema, $pageNum, $crdcgi->param("arrowPressed"));
   };
   &processError(activity => 'setup home sections') if ($@);
   &writeHTTPHeader();
   &writeHead();
   &writeBody();
}
&db_disconnect($dbh);
exit();
