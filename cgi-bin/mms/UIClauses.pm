# UI Clause functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UIClauses.pm,v $
#
# $Revision: 1.6 $
#
# $Date: 2009/05/29 21:35:51 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIClauses.pm,v $
# Revision 1.6  2009/05/29 21:35:51  atchleyb
# ACR0905_001 - user change request, multiple changes
#
# Revision 1.5  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.4  2007/02/07 17:28:29  atchleyb
# CR 0030 - Updated to handle default PO clauses
#
# Revision 1.3  2006/03/16 17:48:57  atchleyb
# CR 0023 - updated to have a popup display of the first 1200 character os text for clauses when the mouse rolls over the description
#
# Revision 1.2  2005/08/19 20:54:43  atchleyb
# changed description length to 100
# CR00015
#
# Revision 1.1  2003/11/12 20:32:59  atchleyb
# Initial revision
#
#
#
#
#

package UIClauses;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBClauses qw(:Functions);
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
      &getInitialValues       &doHeader             &doUpdateClauseSelect
      &doFooter               &getTitle             &doClauseEntryForm
      &doClauseEntry          &doBrowse             &doDisplayClause
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doUpdateClauseSelect
      &doFooter               &getTitle             &doClauseEntryForm
      &doClauseEntry          &doBrowse             &doDisplayClause
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
   if (($args{command} eq "addclause") || ($args{command} eq "addclauseform")) {
      $title = "Add Clause";
   } elsif (($args{command} eq "updateclause") || ($args{command} eq "updateclauseform") || ($args{command} eq "updateclauseselect")) {
      $title = "Update Clause";
   } elsif (($args{command} eq "browse") || (($args{command} eq "displayclause")) || ($args{command} eq "displayclauseform")) {
      $title = "Browse Clause";
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
       isactive => (defined($mycgi->param("isactive"))) ? $mycgi->param("isactive") : "F",
       clauseid => (defined($mycgi->param("clauseid"))) ? $mycgi->param("clauseid") : 0,
       c_clauseid => (defined($mycgi->param("c_clauseid"))) ? $mycgi->param("c_clauseid") : 0,
       description => (defined($mycgi->param("description"))) ? $mycgi->param("description") : "",
       clause => (defined($mycgi->param("clause"))) ? $mycgi->param("clause") : "",
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
sub doBrowse {  # routine to generate a table of clauses for browse
###################################################################################################################################
    my %args = (
        forUpdate => 'F',
        @_,
    );
    my $output = "";
    my @clauses = getClauseArray(dbh => $args{dbh}, schema => $args{schema}, activeOnly => 'F');

    $output .= "<table align=center border=0>\n";
    $output .= "<tr><td><b>Descriptions</td></tr>\n";
    for (my $i=0; $i<$#clauses; $i++) {
        my $clauseText = &getDisplayString($clauses[$i]{text}, 1200);
        $clauseText =~ s/"/'/g; #"
        $output .= "<tr><td>" . (($clauses[$i]{isactive} ne 'T') ? "<i>" : "") . "<a href=\"javascript:" . (($args{forUpdate} eq 'T') ? "update" : "browse") . 
            "Clause($clauses[$i]{id});\" title=\"$clauseText\">$clauses[$i]{description}" . 
            (($clauses[$i]{isactive} ne 'T') ? " - Inactive" : "") . "</a>" . (($clauses[$i]{isactive} ne 'T') ? "</i>" : "") . "</td></tr>\n";
    }
    $output .= "</table>\n";
    $output .= "<input type=hidden name=c_clauseid value=0>\n";
    
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function browseClause (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'displayclause');
}

function updateClause (id) {
    $args{form}.id.value=id;
    $args{form}.c_clauseid.value=id;
    submitForm('$args{form}', 'updateclauseform');
}
//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doDisplayClause {  # routine to display a clause
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my @clause = &getClauseArray(dbh => $args{dbh}, schema => $args{schema}, id=>$settings{id});
    
    $output .= "<table align=center border=0>\n";
    $output .= "<tr><td><b>Description:</b></td><td>$clause[0]{description}</td></tr>\n";
    $clause[0]{text} =~ s/\n/<br>\n/g;
    $output .= "<tr><td valign=top><b>Clause:</b></td><td>$clause[0]{text}</td></tr>\n";
    $output .= "</table>\n";
    

    return($output);
}


###################################################################################################################################
sub doUpdateClauseSelect {  # routine to generate a select box of Clauses for update
###################################################################################################################################
    my %args = (
        selectedClause => 0,
        onlyActive => 'F',
        command => 'updateclauseform',
        commandText => "Retrieve Clause",
        target => "",
        @_,
    );
    my $output = "";
    if ($args{selectedClause} == 0) {
        $output .= &doBrowse(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, userID => $args{userid}, 
            form => $args{form}, forUpdate => 'T');
    } else {
        my @clauses = getClauseArray(dbh => $args{dbh}, schema => $args{schema}, activeOnly => 'F');
        my $selectedID = 0;

        $output .= <<END_OF_BLOCK;
<table border=0 width=680 align=center>
<tr><td colspan=4 align=center>
<table border=0>
END_OF_BLOCK
        $output .= "<tr><td><b>Select Clause: </b>&nbsp;</td></tr><tr><td><select name=c_clauseid size=1>\n";
        for (my $i=0; $i < $#clauses; $i++) {
            my ($id, $description, $isactive) = ($clauses[$i]{id},&getDisplayString($clauses[$i]{description},100), $clauses[$i]{isactive});
            my $selected = "";
            if ($id == $args{selectedClause}) {
                $selected = "selected";
                $selectedID = $i;
            }
            $output .= "<option value='$id' $selected>$description" . (($isactive ne 'T') ? " - Inactive" : "") . "</option>\n";
        }
        $output .= "</select></td>\n";
        my $target = (($args{target} gt "") ? "document.$args{form}.target.value='$args{target}';" : "");
        $output .= <<END_OF_BLOCK;
<td>&nbsp;<input type=submit name="updateclause" value="$args{commandText}" onClick="document.$args{form}.command.value='$args{command}';$target"></td></tr>
END_OF_BLOCK
        if ($args{selectedClause} != 0) {
            $output .= "<tr><td><b>Description:</b></td></tr><tr><td><b>$clauses[$selectedID]{description}</b></td></tr>";
            #$output .= "<tr><td><b>ID:</b></td><td><b>$clauses[$selectedID]{id}</b><input type=hidden name=clauseid value=$clauses[$selectedID]{id}></td></tr>";
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
sub doClauseEntryForm {  # routine to generate a Clause data entry/update form
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my @clause;
    $clause[0]{id} = "";
    $clause[0]{description} = "";
    $clause[0]{text} = "";
    $clause[0]{isactive} = "T";
    my $id = $settings{c_clauseid};
    if ($args{type} eq 'update') {
        $output .= &doUpdateClauseSelect(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, form => $args{form}, 
                                   userID => $args{userID}, settings => \%settings, selectedClause => $id);
        @clause = getClauseArray(dbh => $args{dbh}, schema => $args{schema}, id=>$settings{c_clauseid}, activeOnly => 'F');
    }

    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td><hr></td></tr>\n" if ($args{type} eq 'update');
    $output .= "<tr><td colspan=2><br></td></tr>\n" if ($args{type} eq 'update');
    $output .= "<tr><td colspan=2 align=center><table border=0 width=650>\n";
    $output .= "<input type=hidden name=clauseid vlaue=$id>\n";
    $output .= "<tr><td><b>Description: </b>&nbsp</td><td><input type=text name=description value=\"$clause[0]{description}\" maxlength=500 size=100></td><tr>\n";
    $output .= "<tr><td valign=top><b>Clause: </b>&nbsp<a href=\"javascript:expandTextBox(document.$args{form}.clause,document.clause_button,'force',5);\"><img name=clause_button border=0 src=$SYSImagePath/expand_button.gif></td>";
    $output .= "<td><textarea name=clause cols=80 rows=15>$clause[0]{text}</textarea></td></tr>\n";
    $output .= "<tr><td><b>Is Active: </b>&nbsp;</td><td><input type=checkbox name=isactive value='T'" . (($clause[0]{isactive} eq 'T') ? " checked" : "") . (($clause[0]{usecount}>0) ? " disabled" : "") . ">";
    $output .= (($clause[0]{usecount}>0) ? " - Clause is used in $clause[0]{usecount} rule(s) and can not be disabled until removed from all rules." : "") . "</td></tr>\n";

    $output .= "<tr><td colspan=2 align=center><br><input type=button name=submitbutton value=\"Submit Clause Information\" onClick=\"verifySubmit(document.$args{form})\"> &nbsp;\n";
    $output .= "</table>\n";
    
    my $nextCommand = (($args{type} eq 'new') ? "addclause" : "updateclause");
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    if (isblank(f.description.value) || isblank(f.clause.value)) {
      msg += "All form fields must be entered.\\n";
    }
    if (msg != "") {
      alert (msg);
    } else {
      submitFormCGIResults('$args{form}', '$nextCommand');
    }
}
//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doClauseEntry {  # routine to get clause entry/update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my ($status, $id) = &doProcessClauseEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, settings => \%settings);

    my $temp = $settings{description};
    $temp =~ s/'/ /g;
    $temp =~ s/"/ /g; #"
    $message = "Clause '$temp' has been " . (($args{type} eq 'new') ? "added " : "updated");
    $output .= doAlertBox(text => "$message");
    if ($args{type} eq 'new') {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "clause $id inserted", type => 10);
    } else {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "clause $id updated", type => 11);
    }
    $output .= "<input type=hidden name=c_clauseid value=$id>\n";
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','updateclauseform');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
