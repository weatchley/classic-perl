# UI keyword functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/UIKeywords.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/12/02 18:43:17 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIKeywords.pm,v $
# Revision 1.1  2004/12/02 18:43:17  atchleyb
# Initial revision
#
#
#
#
#
#

package UIKeywords;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBKeywords qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Sessions qw(:Functions);
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
      &getInitialValues       &doHeader             &doUpdateKeywordSelect
      &doFooter               &getTitle             &doKeywordEntryForm
      &doKeywordEntry         &doKeywordDelete
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doUpdateKeywordSelect
      &doFooter               &getTitle             &doKeywordEntryForm
      &doKeywordEntry         &doKeywordDelete
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
   if (($args{command} eq "addkeyword") || ($args{command} eq "addkeywordform")) {
      $title = "Add Keyword";
   } elsif (($args{command} eq "updatekeyword") || ($args{command} eq "updatekeywordform") || ($args{command} eq "updatekeywordselect")) {
      $title = "Update Keyword";
   } else {
      $title = "Keyword";
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
       keywordid => (defined($mycgi->param("keywordid"))) ? $mycgi->param("keywordid") : "",
       text => (defined($mycgi->param("text"))) ? $mycgi->param("text") : "",
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
        title => "$SYSType Keyword Functions",
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
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS);
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
sub doUpdateKeywordSelect {  # routine to generate a table of keywords for update
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my @keywords = &getKeywordList(dbh=>$args{dbh}, schema=>$args{schema}, getCount=>'T');

    $output .= "<center><table border=0><tr><td valign=top align=center>";
    $output .= "<b><a href=\"javascript:addKeyword()\">Add New</a></b><br><br>\n";
    $output .= "<table border=1 cellspacing=0>\n";
    $output .= "<tr bgcolor='#a0e0c0'><td align=center><b>ID</b></td><td colspan=2><b>Text</b></td></tr>";
    for (my $i=0; $i<$#keywords; $i++) {
        $output .= "<tr bgcolor='#ffffff'><td align=center>$keywords[$i]{id}</td>";
        my $text = $keywords[$i]{text};
        $text =~ s/  / &nbsp;/g;
        $output .= "<td><a href=\"javascript:updateKeyword($keywords[$i]{id})\">$text</a></td>";
        $output .= "<td align=center>" . (($keywords[$i]{count} == 0) ? "<a href=\"javascript:deleteKeyword($keywords[$i]{id})\">Delete</a>" : "&nbsp") . "</td>";
        $output .= "</tr>\n";
    }
    $output .= "</table>\n";
    $output .= "</td></tr></table><br>\n";
    $output .= "</center>";

    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function addKeyword (id){
// submit update
    submitForm('$args{form}', 'addkeywordform');
}

function updateKeyword (id){
// submit update
    document.$args{form}.id.value = id;
    submitForm('$args{form}', 'updatekeywordform');
}

function deleteKeyword (id){
// submit update
    document.$args{form}.id.value = id;
    submitForm('$args{form}', 'deletekeyword');
}

//--></script>

END_OF_BLOCK
    

    return($output);
}


###################################################################################################################################
sub doKeywordEntryForm {  # routine to generate a keyword data entry/update form
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %keywordInfo = (
        id => 0,
        text => "",
    );
    my $id = 0;
    if ($args{type} eq 'update') {
        $id = $settings{id};
        %keywordInfo = &getKeyword(dbh => $args{dbh}, schema => $args{schema}, ID => $id);
    }

    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td colspan=2 align=center><table border=0>\n";
    $output .= "<tr><td><b>ID: </b>&nbsp</td><td><input type=text name=dummy1 value=" . (($args{type} eq 'new') ? "New" : $keywordInfo{id}) . " readonly disabled size=4></td></tr>\n";
    $output .= "<input type=hidden name=keywordid value=$keywordInfo{id}>\n";
    my $text = $keywordInfo{text};
    $text =~ s/"/''/g;
    $output .= "<tr><td><b>Text: </b>&nbsp</td><td><input type=text name=text value=\"$text\" maxlength=100 size=70></td></tr>\n";
    $output .= "</table></td></tr>\n";
    $output .= "<tr><td align=center><br><input type=button name=submitbutton value=\"Submit\" onClick=\"verifySubmit(document.$args{form})\"></td>\n";
    $output .= "<td align=center><br><input type=button name=resetbutton value=\"Reset\" onClick=\"resetForm(document.$args{form})\"></td></tr>\n";
    $output .= "</table>\n";
    
    my $nextCommand = (($args{type} eq 'new') ? "addkeyword" : "updatekeyword");
    $text = $keywordInfo{text};
    $text =~ s/"/\\"/g;
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    if (isblank(f.text.value)) {
      msg += "All form fields must be entered.\\n";
    }
    if (msg != "") {
      alert (msg);
    } else {
      submitFormCGIResults('$args{form}', '$nextCommand');
    }
}

function resetForm (f){
// javascript form reset
    document.$args{form}.text.value = "$text";
}

//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doKeywordEntry {  # routine to get keyword entry/update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my $status = &doProcessKeywordEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, settings => \%settings);

    if ($args{type} eq 'new') {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "keyword $settings{text} inserted", type => 13);
    } else {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "keyword $settings{text} updated", type => 14);
    }
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','updatekeywordselect');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doKeywordDelete {  # routine to delete keyword
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my $status = &doProcessKeywordDelete(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, settings => \%settings);

    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "keyword $settings{id} deleted", type => 15);
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','updatekeywordselect');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
