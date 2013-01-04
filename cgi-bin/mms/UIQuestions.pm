# UI Questions functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UIQuestions.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2008/10/21 18:09:06 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIQuestions.pm,v $
# Revision 1.1  2008/10/21 18:09:06  atchleyb
# Initial revision
#
#
#
#
#
#

package UIQuestions;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBQuestions qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Sessions qw(:Functions);
use DBRoles qw(:Functions);
use Tie::IxHash;
use Tables;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getInitialValues       &doHeader             &doUpdateQuestionSelect
      &doFooter               &getTitle             &doQuestionEntryForm
      &doQuestionEntry        &doBrowse             &doDisplayQuestion
      &doQuestionDelete
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doUpdateQuestionSelect
      &doFooter               &getTitle             &doQuestionEntryForm
      &doQuestionEntry        &doBrowse             &doDisplayQuestion
      &doQuestionDelete
    )]
);

my $mycgi = new CGI;


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "";
   if (($args{command} eq "addquestion") || ($args{command} eq "addquestionform")) {
      $title = "Add Question";
   } elsif (($args{command} eq "updatequestion") || ($args{command} eq "updatequestionform") || ($args{command} eq "updatequestionselect")) {
      $title = "Update Question";
   } elsif (($args{command} eq "browse") || (($args{command} eq "displayquestion")) || ($args{command} eq "displayquestionform")) {
      $title = "Browse Question";
   } else {
      $title = "$args{command}";
   }
   return ($title);
}


###################################################################################################################################
sub getInitialValues {  # routine to get initial CGI values and return in a hash
###################################################################################################################################
    my %args = (
        dbh => "",
        @_,
    );
    
    my %valueHash = (
       &getStandardValues, (
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "browse",
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
       questionid => (defined($mycgi->param("questionid"))) ? $mycgi->param("questionid") : 0,
       c_questionid => (defined($mycgi->param("c_questionid"))) ? $mycgi->param("c_questionid") : 0,
       role => (defined($mycgi->param("role"))) ? $mycgi->param("role") : 0,
       question => (defined($mycgi->param("question"))) ? $mycgi->param("question") : "",
    ));

    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => $ENV{SCHEMA},
        title => "$SYSType User Functions",
        displayTitle => 'T',
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $form = $args{form};
    my $path = $args{path};
    my $username = $settings{username};
    my $userid = $settings{userid};
    my $Server = $settings{server};
    
    my $extraJS = "";
    $extraJS .= <<END_OF_BLOCK;


END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS,includeJSUtilities => 'T', includeJSWidgets => 'F',);
#              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, onSubmit => "return verify_$form(this)");
    
    $output .= "<table border=0 width=750 align=center><tr><td>\n";

    return($output);
}


###################################################################################################################################
sub doFooter {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my $form = $args{form};
    my $path = $args{path};
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $username = $settings{username};
    my $userid = $settings{userid};
    my $Server = $settings{server};
    my $schema = $settings{schema};
    my $sessionID = $settings{sessionID};
    my $extraHTML = "";
    
    $output .= "<br><br>\n</td></tr></table>\n";
    
    $output .= &doStandardFooter(form => $form, extraHTML => $extraHTML);

    return($output);
}


###################################################################################################################################
sub doBrowse {  # routine to generate a table of questions for browse
###################################################################################################################################
    my %args = (
        forUpdate => 'F',
        @_,
    );
    my $output = "";
    my @questions = getQuestionArray(dbh => $args{dbh}, schema => $args{schema});

    $output .= "<table align=center border=" . (($args{forUpdate} eq "T") ? "1 cellspacing=0" : "0") .">\n";
    $output .= "<tr><td" . (($args{forUpdate} eq "T") ? " colspan=2" : "") ."><b>Questions</td></tr>\n";
    for (my $i=0; $i<$#questions; $i++) {
        my $questionText = &getDisplayString($questions[$i]{text}, 1200);
        $questionText =~ s/"/'/g; #"
        $questionText =~ s/\n/ /g;
        $output .= "<tr><td><a href=\"javascript:" . (($args{forUpdate} eq 'T') ? "update" : "browse") . "Question($questions[$i]{id});\" title=\"$questionText\">$questions[$i]{text}</a></td>";
        if ($args{forUpdate} eq 'T') {
            my $qCount = getQuestionSiteCount(dbh => $args{dbh}, schema => $args{schema}, question => $questions[$i]{id});
            if ($qCount <= 0) {
                $output .= "<td><a href=\"javascript:deleteQuestion($questions[$i]{id});\">Delete</a></td>";
            } else {
                $output .= "<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>";
            }
        }
        $output .= "</tr>\n";
    }
    $output .= "</table>\n";
    $output .= "<input type=hidden name=c_questionid value=0>\n";
    
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function browseQuestion (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'displayquestion');
}

function updateQuestion (id) {
    $args{form}.id.value=id;
    $args{form}.c_questionid.value=id;
    submitForm('$args{form}', 'updatequestionform');
}

function deleteQuestion (id) {
    $args{form}.id.value=id;
    $args{form}.c_questionid.value=id;
    submitFormCGIResults('$args{form}', 'deletequestion');
}
//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doDisplayQuestion {  # routine to display a question
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my @question = &getQuestionArray(dbh => $args{dbh}, schema => $args{schema}, id=>$settings{id});
    
    $output .= "<table align=center border=0>\n";
    $question[0]{text} =~ s/\n/<br>\n/g;
    $output .= "<tr><td valign=top><b>Question:</b></td><td>$question[0]{text}</td></tr>\n";
    $output .= "<tr><td><b>Role:</b></td><td>$question[0]{rolename}</td></tr>\n";
    $output .= "</table>\n";
    

    return($output);
}


###################################################################################################################################
sub doUpdateQuestionSelect {  # routine to generate a select box of Questions for update
###################################################################################################################################
    my %args = (
        selectedQuestion => 0,
        onlyActive => 'F',
        command => 'updatequestionform',
        commandText => "Retrieve Question",
        target => "",
        @_,
    );
    my $output = "";
    if ($args{selectedQuestion} == 0) {
        $output .= &doBrowse(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, userID => $args{userid}, 
            form => $args{form}, forUpdate => 'T');
    } else {
        my @questions = getQuestionArray(dbh => $args{dbh}, schema => $args{schema});
        my $selectedID = 0;

        $output .= <<END_OF_BLOCK;
<table border=0 width=680 align=center>
<tr><td colspan=4 align=center>
<table border=0>
END_OF_BLOCK
        $output .= "<tr><td><b>Select Question: </b>&nbsp;</td></tr><tr><td><select name=c_questionid size=1>\n";
        for (my $i=0; $i < $#questions; $i++) {
            my $questionText = &getDisplayString($questions[$i]{text}, 200);
            $questionText =~ s/"/'/g; #"
            $questionText =~ s/\n/ /g;
            my ($id, $question) = ($questions[$i]{id},$questionText);
            my $selected = "";
            if ($id == $args{selectedQuestion}) {
                $selected = "selected";
                $selectedID = $i;
            }
            $output .= "<option value='$id' $selected>$question</option>\n";
        }
        $output .= "</select></td>\n";
        my $target = (($args{target} gt "") ? "document.$args{form}.target.value='$args{target}';" : "");
        $output .= <<END_OF_BLOCK;
<td>&nbsp;<input type=submit name="updatequestion" value="$args{commandText}" onClick="document.$args{form}.command.value='$args{command}';$target"></td></tr>
END_OF_BLOCK
        if ($args{selectedQuestion} != 0) {
            $output .= "<tr><td><b>Question:</b></td></tr><tr><td><b>$questions[$selectedID]{text}</b></td></tr>";
        }
        $output .= <<END_OF_BLOCK;
</table>
</td></tr>
</table>
END_OF_BLOCK
    
    }

    return($output);
}


###################################################################################################################################
sub doQuestionEntryForm {  # routine to generate a Question data entry/update form
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my @question;
    $question[0]{id} = "";
    $question[0]{text} = "";
    $question[0]{role} = 0;
    my $id = $settings{c_questionid};
    if ($args{type} eq 'update') {
        $output .= &doUpdateQuestionSelect(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, form => $args{form}, 
                                   userID => $args{userID}, settings => \%settings, selectedQuestion => $id);
        @question = getQuestionArray(dbh => $args{dbh}, schema => $args{schema}, id=>$settings{c_questionid});
    }

    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td><hr></td></tr>\n" if ($args{type} eq 'update');
    $output .= "<tr><td colspan=2><br></td></tr>\n" if ($args{type} eq 'update');
    $output .= "<tr><td colspan=2 align=center><table border=0 width=650>\n";
    $output .= "<input type=hidden name=questionid vlaue=$id>\n";
    $output .= "<tr><td valign=top><b>Role: </b>&nbsp;</td><td><select name=role size=1><option value=0>Please Select a Role</option>\n";
    my @roles = getRoleArray(dbh => $args{dbh}, schema => $args{schema});
    for (my $i=0; $i<$#roles; $i++) {
        $output .= "<option value=$roles[$i]{id}" . (($roles[$i]{id} == $question[0]{role}) ? " selected" : "") . ">$roles[$i]{name}</option>\n";
    }
    $output .= "</select></td></tr>\n";
    $output .= "<tr><td valign=top><b>Question: </b>&nbsp<a href=\"javascript:expandTextBox(document.$args{form}.question,document.question_button,'force',5);\"><img name=question_button border=0 src=$SYSImagePath/expand_button.gif></td>";
    $output .= "<td><textarea name=question cols=80 rows=5 onBlur=checkLength(value,1999,this);>$question[0]{text}</textarea></td></tr>\n";

    $output .= "<tr><td colspan=2 align=center><br><input type=button name=submitbutton value=\"Submit Question Information\" onClick=\"verifySubmit(document.$args{form})\"> &nbsp;\n";
    $output .= "</table>\n";
    
    my $nextCommand = (($args{type} eq 'new') ? "addquestion" : "updatequestion");
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    if (isblank(f.question.value) || f.role[0].selected) {
      msg += "All form fields must be entered.\\n";
    }
    if (msg != "") {
      alert (msg);
    } else {
      submitFormCGIResults('$args{form}', '$nextCommand');
    }
}

    function checkLength(val,maxlen,e) {
        var len = val.length;
        var diff = len - maxlen;
        if (diff > 0) {
            alert ("The text you have entered is " + diff + " characters too long.");
            e.focus();
        }
    }
//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doQuestionEntry {  # routine to get question entry/update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my ($status, $id) = &doProcessQuestionEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, settings => \%settings);

    my $temp = $settings{question};
    $temp =~ s/'/ /g;
    $temp =~ s/"/ /g; #"
    $message = "Question '$temp' has been " . (($args{type} eq 'new') ? "added " : "updated");
    $output .= doAlertBox(text => "$message");
    if ($args{type} eq 'new') {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "question $id inserted", type => 42);
    } else {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "question $id updated", type => 43);
    }
    $output .= "<input type=hidden name=c_questionid value=$id>\n";
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','updatequestionform');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doQuestionDelete {  # routine to get delete a question
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my @questions = &getQuestionArray(dbh => $args{dbh}, schema => $args{schema}, id => $settings{id});
    my ($status, $id) = &doProcessQuestionDelete(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, settings => \%settings);

    my $temp = $questions[0]{text};
    $temp =~ s/'/ /g;
    $temp =~ s/"/ /g; #"
    $message = "Question '$temp' has been deleted";
    $output .= doAlertBox(text => "$message");
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "question $id, " . &getDisplayString($temp, 400) . " deleted", type => 43);
    $output .= "<input type=hidden name=c_questionid value=$id>\n";
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','updatequestionselect');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
