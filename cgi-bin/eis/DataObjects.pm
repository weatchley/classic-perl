#
# $Source: /data/dev/eis/perl/RCS/DataObjects.pm,v $
#
# $Revision: 1.8 $
#
# $Date: 2001/05/17 16:28:23 $
#
# $Author: mccartym $
#
# $Locker:  $
#
# $Log: DataObjects.pm,v $
# Revision 1.8  2001/05/17 16:28:23  mccartym
# use document specific review name
#
# Revision 1.7  2001/04/27 00:01:15  atchleyb
# added functions for HasIssues in comments
#
# Revision 1.6  2001/04/23 14:54:32  mccartym
# change default to no reviewer if policy is 'optional'
#
# Revision 1.5  2000/02/07 17:09:01  mccartym
# remove hardcoded 'EIS' on Change Impact
#
# Revision 1.4  1999/12/01 23:37:32  mccartym
# fix problem with change control number disable
#
# Revision 1.3  1999/12/01 22:13:42  mccartym
# fix problem with writeTechReviewers()
#
# Revision 1.2  1999/11/25 02:01:40  mccartym
# add support for multiple tables such as comments_entry and summary_comments
# add enable/disable javascript code
#
# Revision 1.1  1999/11/04 16:43:15  mccartym
# Initial revision
#
#
package DataObjects;
use strict;
use integer;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DocumentSpecific qw(:Functions);
use CGI qw(param);
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $AUTOLOAD);
use Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(
   &selectChangeImpact   &updateChangeImpact   &writeChangeImpact
   &selectDateDue        &updateDateDue        &writeDateDue
   &selectHasCommitments &updateHasCommitments &writeHasCommitments
   &selectHasIssues      &updateHasIssues      &writeHasIssues
   &selectDOEReviewer    &updateDOEReviewer    &writeDOEReviewer
   &selectResponseWriter &updateResponseWriter &writeResponseWriter
   &selectTechReviewers  &updateTechReviewers  &writeTechReviewers
);
@EXPORT_OK = qw(
   &selectChangeImpact   &updateChangeImpact   &writeChangeImpact
   &selectDateDue        &updateDateDue        &writeDateDue
   &selectHasCommitments &updateHasCommitments &writeHasCommitments
   &selectHasIssues      &updateHasIssues      &writeHasIssues
   &selectDOEReviewer    &updateDOEReviewer    &writeDOEReviewer
   &selectResponseWriter &updateResponseWriter &writeResponseWriter
   &selectTechReviewers  &updateTechReviewers  &writeTechReviewers
);
%EXPORT_TAGS = (Functions => [qw(
   &selectChangeImpact   &updateChangeImpact   &writeChangeImpact
   &selectDateDue        &updateDateDue        &writeDateDue
   &selectHasCommitments &updateHasCommitments &writeHasCommitments
   &selectHasIssues      &updateHasIssues      &writeHasIssues
   &selectDOEReviewer    &updateDOEReviewer    &writeDOEReviewer
   &selectResponseWriter &updateResponseWriter &writeResponseWriter
   &selectTechReviewers  &updateTechReviewers  &writeTechReviewers
)]);

my ($crdcgi, $path, $form, $instructionsColor, $secondReviewName);
BEGIN {
   $crdcgi = new CGI;
   $ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
   $path = $1;
   $form = $2;
   $instructionsColor = $CRDFontColor;
   $secondReviewName = &SecondReviewName();
}

sub getLookupValues {
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
sub updateChangeImpact {                                                                                                          #
###################################################################################################################################
   my %args = (
      changeImpactName => 'changeImpact',
      changeControlName => 'changeControlNumber',
      table => 'comments',
      @_,
   );
   my $where;
   my $changeImpact = $crdcgi->param("$args{changeImpactName}");
   my $changeControlNumber = $crdcgi->param("$args{changeControlName}");
   $changeControlNumber =~ s/'/''/g;
   if (($args{table} eq 'comments') || ($args{table} eq 'comments_entry')) {
      $where = "document = $args{document} and commentnum = $args{comment}";
   } elsif (($args{table} eq 'summary_comment') || ($args{table} eq 'summary_comment_entry')) {
      $where = "id = $args{summaryID}";
   } else {
      die ("Unknown table name '$args{table}' in updateChangeImpact()");
   }
   $args{dbh}->do("update $args{schema}.$args{table} set changeimpact = $changeImpact, changecontrolnum = '$changeControlNumber' where $where");
}

###################################################################################################################################
sub selectChangeImpact {                                                                                                          #
###################################################################################################################################
   my %args = (
      table => 'comments',
      @_,
   );
   my $where;
   if (($args{table} eq 'comments') || ($args{table} eq 'comments_entry')) {
      $where = "document = $args{document} and commentnum = $args{comment}";
   } elsif (($args{table} eq 'summary_comment') || ($args{table} eq 'summary_comment_entry')) {
      $where = "id = $args{summaryID}";
   } else {
      die ("Unknown table name '$args{table}' in selectChangeImpact()");
   }
   return ($args{dbh}->selectrow_array ("select changeimpact, changecontrolnum from $args{schema}.$args{table} where $where"));
}

###################################################################################################################################
sub writeChangeImpact {                                                                                                           #
###################################################################################################################################
   my %args = (
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      changeImpactName => 'changeImpact',
      changeControlName => 'changeControlNumber',
      changeImpactLabel => 'Document Change Impact',
      changeControlLabel => 'Change Control Number',
      changeControlLength => 10,
      table => 'comments',
      height => 30,
      doSelect => 1,
      @_,
   );
   my ($changeImpact, $changeControl) = (1, "");
   if ($args{useForm}) {
      $changeImpact = $crdcgi->param($args{changeImpactName});
      $changeControl = (defined($crdcgi->param($args{changeControlName}))) ? $crdcgi->param($args{changeControlName}) : "";
   } elsif ($args{doSelect}) {
      if (($args{table} eq 'comments') || ($args{table} eq 'comments_entry')) {
         ($changeImpact, $changeControl) = &selectChangeImpact(dbh => $args{dbh}, schema => $args{schema}, table => $args{table}, document => $args{document}, comment => $args{comment});
      } elsif (($args{table} eq 'summary_comment') || ($args{table} eq 'summary_comment_entry')) {
         ($changeImpact, $changeControl) = &selectChangeImpact(dbh => $args{dbh}, schema => $args{schema}, table => $args{table}, summaryID => $args{summaryID});
      } else {
         die ("Unknown table name '$args{table}' in writeChangeImpact()");
      }
   }
   if (!defined($changeControl)) {
      $changeControl = "";
   } else {
      $changeControl =~ s/'/%27/g;
   }
   my %changeImpactValues = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'document_change_impact')};
   my $output = "<td height=$args{height}><b>$args{changeImpactLabel}:</b>" . &nbspaces(2);
   $output .= "<select name=$args{changeImpactName} size=1 onChange='setChangeControl();'>";
   while (my ($id, $value) = each(%changeImpactValues)) {
      my $selected = ($changeImpact == $id) ? 'selected' : '';
      $output .= "<option value='$id' $selected>$value";
   }
   $output .= "</select>\n";
   $output .= &nbspaces(3) . "<b>$args{changeControlLabel}:</b>" . &nbspaces(2);
   $output .= "<input type=text size=$args{changeControlLength} maxlength=$args{changeControlLength} name=$args{changeControlName} onChange='saveChangeControl();'>";
   $output .= "<script language=javascript><!--\n";
   $output .= "var save;\n";
   $output .= "var mytext ='$changeControl';\n";
   $output .= "$form.$args{changeControlName}.value = unescape(mytext);\n";
   $output .= "function setChangeControl() {\n";
   $output .= "   if ($form.$args{changeImpactName}\[$form.$args{changeImpactName}.selectedIndex].value >= 2) {\n";
   $output .= "      $form.$args{changeControlName}.disabled = false;\n";
   $output .= "      $form.$args{changeControlName}.value = save;\n";
   $output .= "   } else {\n";
   $output .= "      $form.$args{changeControlName}.disabled = true;\n";
   $output .= "      $form.$args{changeControlName}.value = \"\";\n";
   $output .= "   }\n";
   $output .= "}\n";
   $output .= "function saveChangeControl() {\n";
   $output .= "   save = $form.$args{changeControlName}.value;\n";
   $output .= "}\n";
   $output .= "function checkChangeControl() {\n";
   $output .= "   var output = \"\";\n";
   $output .= "   if (($form.$args{changeImpactName}\[$form.$args{changeImpactName}.selectedIndex].value >= 2) && isblank($form.$args{changeControlName}.value)) {\n";
   $output .= "      output = \"Please enter a valid Change Control Number\\n\";\n";
   $output .= "   }\n";
   $output .= "   return(output);\n";
   $output .= "}\n";
   $output .= "function setChangeImpactDisabled(value) {\n";
   $output .= "   $form.$args{changeImpactName}.disabled = value;\n";
   $output .= "   if (!value) {\n";
   $output .= "      setChangeControl();\n";
   $output .= "   } else {\n";
   $output .= "      $form.$args{changeControlName}.disabled = value;\n";
   $output .= "   }\n";
   $output .= "}\n";
   $output .= "saveChangeControl();\n";
   $output .= "setChangeControl();\n";
   $output .= "//-->\n";
   $output .= "</script>\n";
   $output .= "</td>\n";
   return ($output);
}

###################################################################################################################################
sub updateDateDue {                                                                                                               #
###################################################################################################################################
   my %args = (
      name => 'dateDue',
      table => 'comments',
      @_,
   );
   my $dateDue = "NULL";
   my ($day, $month, $year) = ($crdcgi->param($args{name} . "_day"), $crdcgi->param($args{name} . "_month"), $crdcgi->param($args{name} . "_year"));
   if (defined($day) && ($day ne "") && defined($month) && ($month ne "") && defined($year) && ($year ne "")) {
      $dateDue = $month . "/" . $day . "/" . $year;
      $dateDue = "to_date('$dateDue', 'MM/DD/YYYY')";
   }
   $args{dbh}->do("update $args{schema}.$args{table} set datedue = $dateDue where document = $args{document} and commentnum = $args{comment}");
}

###################################################################################################################################
sub selectDateDue {                                                                                                               #
###################################################################################################################################
   my %args = (
      table => 'comments',
      @_,
   );
   return ($args{dbh}->selectrow_array("select to_char(datedue, 'MM/DD/YYYY') from $args{schema}.$args{table} where document = $args{document} and commentnum = $args{comment}"));
}

###################################################################################################################################
sub writeDateDue {                                                                                                                #
###################################################################################################################################
   my %args = (
      name => 'dateDue',
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      table => 'comments',
      doSelect => 1,
      @_,
   );
   my $date = "";
   if ($args{useForm}) {
      my ($day, $month, $year) = ($args{name} . "_day", $args{name} . "_month", $args{name} . "_year");
      $date = $crdcgi->param($month) if (defined($crdcgi->param($month)));
      $date .= "/";
      $date .= $crdcgi->param($day) if (defined($crdcgi->param($day)));
      $date .= "/";
      $date .= $crdcgi->param($year) if (defined($crdcgi->param($year)));
   } elsif ($args{doSelect}) {
      ($date) = selectDateDue(dbh => $args{dbh}, schema => $args{schema}, table => $args{table}, document => $args{document}, comment => $args{comment});
   }
   my $output = "<b>Date Due:" . &nbspaces(2) . &build_date_selection($args{name}, $form, $date);
   $output .= &nbspaces(1) . "<font face=arial size=2 color=$instructionsColor>(optional)</font></b></td>\n";
   $output .= "<script language=javascript><!--\n";
   $output .= "function checkDateDue() {\n";
   $output .= "   var output = \"\";\n";
   $output .= "   var cat = $form.$args{name}_day.value + $form.$args{name}_month.value + $form.$args{name}_year.value;\n";
   $output .= "   if (!isblank(cat)) {\n";
   $output .= "      if (isblank($form.$args{name}_day.value) || isblank($form.$args{name}_month.value) || isblank($form.$args{name}_year.value)) {\n";
   $output .= "         output = \"Please enter a valid Due Date\\n\";\n";
   $output .= "      } else {\n";
   $output .= "         var year = $form.$args{name}_year.value;\n";
   $output .= "         var month = $form.$args{name}_month.value;\n";
   $output .= "         var day = $form.$args{name}_day.value;\n";
   $output .= "         output = validate_date(year, month, day, 0, 0, 0, 0, false, true, false);\n";
   $output .= "      }\n";
   $output .= "   }\n";
   $output .= "   return(output);\n";
   $output .= "}\n";
   $output .= "function setDateDueDisabled(value) {\n";
   $output .= "   $form.$args{name}_year.disabled = value;\n";
   $output .= "   $form.$args{name}_month.disabled = value;\n";
   $output .= "   $form.$args{name}_day.disabled = value;\n";
   $output .= "}\n";
   $output .= "//-->\n";
   $output .= "</script>\n";
   return ($output);
}

###################################################################################################################################
sub updateHasCommitments {                                                                                                        #
###################################################################################################################################
   my %args = (
      name => 'hasCommitments',
      table => 'comments',
      @_,
   );
   my $where;
   my $hasCommitments = $crdcgi->param("$args{name}");
   $hasCommitments = (defined($hasCommitments)) ? "T" : "F";
   if (($args{table} eq 'comments') || ($args{table} eq 'comments_entry')) {
      $where = "document = $args{document} and commentnum = $args{comment}";
   } elsif (($args{table} eq 'summary_comment') || ($args{table} eq 'summary_comment_entry')) {
      $where = "id = $args{summaryID}";
   } else {
      die ("Unknown table name '$args{table}' in updateHasCommitments()");
   }
   $args{dbh}->do("update $args{schema}.$args{table} set hascommitments = '$hasCommitments' where $where");
}


###################################################################################################################################
sub selectHasCommitments {                                                                                                        #
###################################################################################################################################
   my %args = (
      table => 'comments',
      @_,
   );
   my $where;
   if (($args{table} eq 'comments') || ($args{table} eq 'comments_entry')) {
      $where = "document = $args{document} and commentnum = $args{comment}";
   } elsif (($args{table} eq 'summary_comment') || ($args{table} eq 'summary_comment_entry')) {
      $where = "id = $args{summaryID}";
   } else {
      die ("Unknown table name '$args{table}' in selectHasCommitments()");
   }
   return ($args{dbh}->selectrow_array ("select hascommitments from $args{schema}.$args{table} where $where"));
}

###################################################################################################################################
sub writeHasCommitments {                                                                                                         #
###################################################################################################################################
   my %args = (
      name => 'hasCommitments',
      table => 'comments',
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      label => 'Potential DOE Commitment',
      height => 30,
      doSelect => 1,
      @_,
   );
   my $checked = "";
   if ($args{useForm}) {
      $checked = (defined($crdcgi->param($args{name}))) ? "checked" : "";
   } elsif ($args{doSelect}) {
      my $hasCommitments;
      if (($args{table} eq 'comments') || ($args{table} eq 'comments_entry')) {
         ($hasCommitments) = &selectHasCommitments(dbh => $args{dbh}, schema => $args{schema}, table => $args{table}, document => $args{document}, comment => $args{comment});
      } elsif (($args{table} eq 'summary_comment') || ($args{table} eq 'summary_comment_entry')) {
         ($hasCommitments) = &selectHasCommitments(dbh => $args{dbh}, schema => $args{schema}, table => $args{table}, summaryID => $args{summaryID});
      } else {
         die ("Unknown table name '$args{table}' in writeHasCommitments()");
      }
      $checked = ($hasCommitments eq "T") ? "checked" : "";
   }
   my $output .= "<td height=$args{height}><input type=checkbox name=$args{name} $checked value=on>" . &nbspaces(1) . "<b>$args{label}</b></td>\n";
   $output .= "<script language=javascript><!--\n";
   $output .= "function setHasCommitmentsDisabled(value) {\n";
   $output .= "   $form.$args{name}.disabled = value;\n";
   $output .= "}\n";
   $output .= "//-->\n";
   $output .= "</script>\n";
   return ($output);
}

###################################################################################################################################
sub updateHasIssues {                                                                                                             #
###################################################################################################################################
   my %args = (
      name => 'hasIssues',
      table => 'comments',
      @_,
   );
   my $where;
   my $hasIssues = $crdcgi->param("$args{name}");
   $hasIssues = (defined($hasIssues)) ? "T" : "F";
   if (($args{table} eq 'comments')) {
      $where = "document = $args{document} and commentnum = $args{comment}";
   } else {
      die ("Unknown table name '$args{table}' in updateHasIssues()");
   }
   $args{dbh}->do("update $args{schema}.$args{table} set hasissues = '$hasIssues' where $where");
}


###################################################################################################################################
sub selectHasIssues {                                                                                                             #
###################################################################################################################################
   my %args = (
      table => 'comments',
      @_,
   );
   my $where;
   if (($args{table} eq 'comments')) {
      $where = "document = $args{document} and commentnum = $args{comment}";
   } else {
      die ("Unknown table name '$args{table}' in selectHasIssues()");
   }
   return ($args{dbh}->selectrow_array ("select hasissues from $args{schema}.$args{table} where $where"));
}

###################################################################################################################################
sub writeHasIssues {                                                                                                              #
###################################################################################################################################
   my %args = (
      name => 'hasIssues',
      table => 'comments',
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      label => 'Potential Issues',
      height => 30,
      doSelect => 1,
      @_,
   );
   my $checked = "";
   if ($args{useForm}) {
      $checked = (defined($crdcgi->param($args{name}))) ? "checked" : "";
   } elsif ($args{doSelect}) {
      my $hasIssues;
      if (($args{table} eq 'comments')) {
         ($hasIssues) = &selectHasIssues(dbh => $args{dbh}, schema => $args{schema}, table => $args{table}, document => $args{document}, comment => $args{comment});
      } else {
         die ("Unknown table name '$args{table}' in writeHasIssues()");
      }
      $checked = ($hasIssues eq "T") ? "checked" : "";
   }
   my $output .= "<td height=$args{height}><input type=checkbox name=$args{name} $checked value=on>" . &nbspaces(1) . "<b>$args{label}</b></td>\n";
   $output .= "<script language=javascript><!--\n";
   $output .= "function setHasIssuesDisabled(value) {\n";
   $output .= "   $form.$args{name}.disabled = value;\n";
   $output .= "}\n";
   $output .= "//-->\n";
   $output .= "</script>\n";
   return ($output);
}
###################################################################################################################################
sub updateDOEReviewer {                                                                                                           #
###################################################################################################################################
   my %args = (
      selectedName => 'DOEReviewSelected',
      reviewerIDName => 'DOEReviewerID',
      table => 'comments',
      @_,
   );
   my $reviewer = (defined($crdcgi->param("$args{selectedName}"))) ? $crdcgi->param("$args{reviewerIDName}") : 'NULL';
   $args{dbh}->do("update $args{schema}.$args{table} set doereviewer = $reviewer where document = $args{document} and commentnum = $args{comment}");
}

###################################################################################################################################
sub selectDOEReviewer {                                                                                                           #
###################################################################################################################################
   my %args = (
      table => 'comments',
      @_,
   );
   return ($args{dbh}->selectrow_array ("select doereviewer from $args{schema}.$args{table} where document = $args{document} and commentnum = $args{comment}"));
}

###################################################################################################################################
sub writeDOEReviewer {                                                                                                            #
###################################################################################################################################
   my %args = (
      selectedName => 'DOEReviewSelected',
      reviewerIDName => 'DOEReviewerID',
      table => 'comments',
      align => 'left',
      label => "$secondReviewName Review/Approval by",
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      doSelect => 1,
      defaultReviewerID => 16,  # Kenneth Skipper
      @_,
   );
   my $output = "";
   my ($reviewerID, $isChecked) = (0, 0);
   if ($args{useForm}) {
      $reviewerID = $crdcgi->param($args{reviewerIDName});
      $isChecked = (defined($crdcgi->param($args{selectedName}))) ? 'checked' : '';
   } elsif ($args{doSelect}) {
      ($reviewerID) = &selectDOEReviewer(dbh => $args{dbh}, schema => $args{schema}, table => $args{table}, document => $args{document}, comment => $args{comment});
      $isChecked = ($reviewerID) ? 'checked' : '';
   }
   my $height = (defined($args{height})) ? "height=$args{height}" : "";
   $output .= "<td align=$args{align} $height><input type=checkbox name=$args{selectedName} $isChecked value=on onClick=javascript:setDOEReviewerNameDisabled(!this.checked)>";
   $output .= &nbspaces(1) . "<b>$args{label}:</b>" . &nbspaces(2) . "<select name=$args{reviewerIDName} size=1>\n";
   my $csr = $args{dbh}->prepare("select u.id, u.firstname, u.lastname from $args{schema}.users u, $args{schema}.user_privilege p where u.id = p.userid and p.privilege = 7 and u.id < 1000");
   $csr->execute;
   while (my ($id, $fname, $lname) = $csr->fetchrow_array) {
      my $selected;
      if (defined($reviewerID)) {
         $selected = ($id == $reviewerID) ? 'selected' : '';
      } else {
         $selected = ($id == $args{defaultReviewerID}) ? 'selected' : '';
      }
      $output .= "<option value='$id' $selected>$fname $lname";
   }
   $csr->finish;
   $output .= "</select></td>\n";
   $output .= "<script language=javascript><!--\n";
   $output .= "function setDOEReviewerCheckboxDisabled(value) {\n";
   $output .= "   $form.$args{selectedName}.disabled = value;\n";
   $output .= "}\n";
   $output .= "function setDOEReviewerNameDisabled(value, forceEnable) {\n";
   $output .= "   $form.$args{reviewerIDName}.disabled = ((!($form.$args{selectedName}.checked) || value) && !forceEnable);\n";
   $output .= "}\n";
   $output .= "function setDOEReviewerDisabled(value, forceEnable) {\n";
   $output .= "   setDOEReviewerCheckboxDisabled(value);\n";
   $output .= "   setDOEReviewerNameDisabled(value, forceEnable);\n";
   $output .= "}\n";
   $output .= "//-->\n";
   $output .= "</script>\n";
   return ($output);
}

###################################################################################################################################
sub updateResponseWriter {                                                                                                        #
###################################################################################################################################
   my %args = (
      name => 'responseWriter',
      table => 'response_version',
      @_,
   );
   my $writer = $crdcgi->param("$args{name}");
   $args{dbh}->do("update $args{schema}.$args{table} set responsewriter = $writer where document = $args{document} and commentnum = $args{comment} and version = $args{version}");
}

###################################################################################################################################
sub selectResponseWriter {                                                                                                        #
###################################################################################################################################
   my %args = (
      table => 'response_version',
      @_,
   );
   return ($args{dbh}->selectrow_array ("select responsewriter from $args{schema}.$args{table} where document = $args{document} and commentnum = $args{comment} and version = $args{version}"));
}

###################################################################################################################################
sub writeResponseWriter {                                                                                                         #
###################################################################################################################################
   my %args = (
      name => 'responseWriter',
      label => 'Response Writer',
      table => 'response_version',
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      @_,
   );
   tie my %writers, "Tie::IxHash";
   %writers = %{$args{writers}};
   my ($writer) = &selectResponseWriter(dbh => $args{dbh}, schema => $args{schema}, table => $args{table}, document => $args{document}, comment => $args{comment}, version => $args{version});
   my $current = ($args{useForm}) ? $crdcgi->param($args{name}) : $writer;
   my $output = "<td><b>$args{label}:</b>" . &nbspaces(2) . "<select name=$args{name} size=1>";
   foreach my $id (keys (%writers)) {
      my $selected = ($current == $id) ? 'selected' : '';
      $output .= "<option value='$id' $selected>$writers{$id}";
   }
   $output .= "</select>\n";
   $output .= "<script language=javascript><!--\n";
   $output .= "function setResponseWriterDisabled(value) {\n";
   $output .= "   $form.$args{name}.disabled = value;\n";
   $output .= "}\n";
   $output .= "//-->\n";
   $output .= "</script>\n";
   return ($output);
}

###################################################################################################################################
sub deleteTechReviewers {                                                                                                         #
###################################################################################################################################
   my %args = (
      table => 'technical_reviewer',
      @_,
   );
   $args{dbh}->do("delete from $args{schema}.$args{table} where document = $args{document} and commentnum = $args{comment}");
}

###################################################################################################################################
sub updateTechReviewers {                                                                                                         #
###################################################################################################################################
   my %args = (
      table => 'technical_reviewer',
      @_,
   );
   &deleteTechReviewers (dbh => $args{dbh}, schema => $args{schema}, table => $args{table}, document => $args{document}, comment => $args{comment});
   my @reviewers = @{$args{reviewers}};
   foreach my $reviewer (@reviewers) {
      $args{dbh}->do("insert into $args{schema}.$args{table} (document, commentnum, reviewer, dateassigned) values ($args{document}, $args{comment}, $reviewer, SYSDATE)");
   }
}

###################################################################################################################################
sub selectTechReviewers {                                                                                                         #
###################################################################################################################################
   my %args = (
      table => 'technical_reviewer',
      @_,
   );
   my @reviewers;
   my $csr = $args{dbh}->prepare("select reviewer from $args{schema}.$args{table} where document = $args{document} and commentnum = $args{comment}");
   $csr->execute;
   while (my @values = $csr->fetchrow_array) {
      push(@reviewers, $values[0]);
   }
   $csr->finish;
   return (@reviewers);
}

###################################################################################################################################
sub writeTechReviewers {                                                                                                          #
###################################################################################################################################
   my %args = (
      reviewerName => 'reviewer',
      numReviewersName => 'numReviewers',
      numReviewersSelectedName => 'numReviewersSelected',
      reviewPolicyName => 'techReviewPolicy',
      useForm => defined($crdcgi->param("useFormValues")) ? 1 : 0,
      height => 25,
      width => 172,
      numColumns => 4,
      label => 'Technical Reviewers',
      table => 'comments',
      @_,
   );
   my ($numReviewers, $numSelected, $checked) = (0, 0, "");
   my ($techReviewPolicy) = $args{dbh}->selectrow_array ("select b.techreviewpolicy from $args{schema}.bin b, $args{schema}.$args{table} c where c.document = $args{document} and c.commentnum = $args{comment} and c.bin = b.id");
   tie my %reviewers, "Tie::IxHash";
   %reviewers = %{$args{reviewers}};
   my $output = "<td><table border=0 cellpadding=0 cellspacing=0><tr><td valign=top height=$args{height}><b>$args{label}:</b></td></tr><tr><td><table border=1 cellpadding=0 cellspacing=0><tr>\n";
   foreach my $id (keys (%reviewers)) {
      $numReviewers++;
      $output .= "</tr><tr>\n" if (($numReviewers % $args{numColumns}) == 1);
      my $name = "$args{reviewerName}$numReviewers";
      if ($args{useForm}) {
         $checked = (defined($crdcgi->param($name))) ? "checked" : "";
      } else {
         $checked = (($techReviewPolicy == 1) && ($numReviewers == 1)) ? "checked" : "";
      }
      $numSelected++ if ($checked eq "checked");
      my $onClick = ($techReviewPolicy == 1) ? "onClick=javascript:checkReviewers(this)" : "";
      $output .= "<td height=$args{height} width=$args{width}><input type=checkbox name=$name $checked value=$id $onClick>" . &nbspaces(1) . "<b>$reviewers{$id}</b></td>\n";
   }
   $output .= "</tr></table></td></tr></table></td>\n";
   $output .= "<input type=hidden name=$args{reviewPolicyName} value=$techReviewPolicy>\n";
   $output .= "<input type=hidden name=$args{numReviewersName} value=$numReviewers>\n";
   $output .= "<input type=hidden name=$args{numReviewersSelectedName} value=$numSelected>\n" if ($techReviewPolicy == 1);
   $output .= "<script language=javascript><!--\n";
   if ($techReviewPolicy == 1) {
      $output .= "function checkReviewers(checkbox) {\n";
      $output .= "   if ($form.techReviewPolicy.value == 1) {\n";
      $output .= "      if (checkbox.checked) {\n";
      $output .= "         $form.$args{numReviewersSelectedName}.value++;\n";
      $output .= "      } else {\n";
      $output .= "         $form.$args{numReviewersSelectedName}.value--;\n";
      $output .= "      }\n";
      $output .= "      if ($form.$args{numReviewersSelectedName}.value == 0) {\n";
      $output .= "         checkbox.checked = true;\n";
      $output .= "         $form.$args{numReviewersSelectedName}.value = 1;\n";
      $output .= "         alert(\"This bin has a mandatory technical review policy.  Therefore at least one reviewer must remain selected\\n\\nContact a system administrator if you want to change the technical review policy for this bin to optional.\");\n";
      $output .= "      }\n";
      $output .= "   }\n";
      $output .= "}\n";
   }
   for (my $reviewer = 1; $reviewer <= $numReviewers; $reviewer++) {
      $output .= "function setTechReviewer" . $reviewer . "Disabled(value) {\n";
      $output .= "   $form.$args{reviewerName}$reviewer.disabled = value;\n";
      $output .= "}\n";
   }
   $output .= "function setTechReviewersDisabled(value) {\n";
   for (my $reviewer = 1; $reviewer <= $numReviewers; $reviewer++) {
      $output .= "   setTechReviewer" . $reviewer . "Disabled(value);\n";
   }
   $output .= "}\n";
   $output .= "//-->\n";
   $output .= "</script>\n";
   return ($output);
}

1;
