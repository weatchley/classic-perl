# UI Business Rule functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UIBusinessRules.pm,v $
#
# $Revision: 1.7 $
#
# $Date: 2009/07/31 22:43:26 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIBusinessRules.pm,v $
# Revision 1.7  2009/07/31 22:43:26  atchleyb
# Updates related to ACR0907_004-SWR0149   New intermediate buyer role, minor bug fixes
#
# Revision 1.6  2008/10/21 18:06:05  atchleyb
# ACR0810_002 - Updated to allow for routing questions
#
# Revision 1.5  2008/08/29 15:50:29  atchleyb
# ACR0808_013 - Fix problems with clauses and PO's, fix problem with shipping costs on bids not transfering to PO
#
# Revision 1.4  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.3  2007/02/07 17:28:29  atchleyb
# CR 0030 - Updated to handle default PO clauses and larger clause description field
#
# Revision 1.2  2005/06/10 22:38:34  atchleyb
# CR0011
# updated to use site name instead of sitecode for selection
#
# Revision 1.1  2004/04/21 17:04:10  atchleyb
# Initial revision
#
#
#
#
#
#
#

package UIBusinessRules;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBSites qw(getSiteInfo);
use DBBusinessRules qw(:Functions);
use DBClauses qw(getClauseArray);
use DBQuestions qw(:Functions);
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
      &getInitialValues       &doHeader             &doUpdateRuleSelect
      &doFooter               &getTitle             &doRuleEntryForm
      &doRuleEntry
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doUpdateRuleSelect
      &doFooter               &getTitle             &doRuleEntryForm
      &doRuleEntry
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
   if (($args{command} eq "addrule") || ($args{command} eq "addruleform")) {
      $title = "Add Business Rule";
   } elsif (($args{command} eq "updaterule") || ($args{command} eq "updateruleform") || ($args{command} eq "updateruleselect")) {
      $title = "Update Business Rule";
   } elsif (($args{command} eq "browse") || (($args{command} eq "displayrule")) || ($args{command} eq "displayruleform")) {
      $title = "Browse Business Rule";
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
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : 0,
       ruleid => (defined($mycgi->param("ruleid"))) ? $mycgi->param("ruleid") : 0,
       siteid => (defined($mycgi->param("siteid"))) ? $mycgi->param("siteid") : 0,
       ruletype => (defined($mycgi->param("ruletype"))) ? $mycgi->param("ruletype") : 0,
       name => (defined($mycgi->param("name"))) ? $mycgi->param("name") : "",
       nvalue1 => (defined($mycgi->param("nvalue1"))) ? $mycgi->param("nvalue1") : 0,
       nvalue2 => (defined($mycgi->param("nvalue2"))) ? $mycgi->param("nvalue2") : 0,
       cvalue1 => (defined($mycgi->param("cvalue1"))) ? $mycgi->param("cvalue1") : "",
       cvalue2 => (defined($mycgi->param("cvalue2"))) ? $mycgi->param("cvalue2") : "",
       itemcount => (defined($mycgi->param("itemcount"))) ? $mycgi->param("itemcount") : 0,
    ));

    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    for (my $i=0; $i<=$valueHash{itemcount}; $i++) {
        $valueHash{items}[$i]{"nvalue1"} = (defined($mycgi->param("nvalue1x$i"))) ? $mycgi->param("nvalue1x$i") : 0;
        $valueHash{items}[$i]{"nvalue2"} = (defined($mycgi->param("nvalue2x$i"))) ? $mycgi->param("nvalue2x$i") : 0;
        $valueHash{items}[$i]{"cvalue1"} = (defined($mycgi->param("cvalue1x$i"))) ? $mycgi->param("cvalue1x$i") : "";
        $valueHash{items}[$i]{"cvalue2"} = (defined($mycgi->param("cvalue2x$i"))) ? $mycgi->param("cvalue2x$i") : "";
        $valueHash{items}[$i]{"brid"} = (defined($mycgi->param("brid$i"))) ? $mycgi->param("brid$i") : 0;
        $valueHash{items}[$i]{"delete"} = (defined($mycgi->param("delete$i"))) ? $mycgi->param("delete$i") : "F";
    }
    
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
sub doUpdateRuleSelect {  # routine to generate a select box of Rules for update
###################################################################################################################################
    my %args = (
        browseOnly => 'F',
        @_,
    );
    my $output = "";
    my @sites = getSiteInfoArray(dbh => $args{dbh}, schema => $args{schema});
    my @types = getRuleTypesArray(dbh => $args{dbh}, schema => $args{schema});
    my $selectedID = 0;

    $output .= <<END_OF_BLOCK;
<table border=0 width=680 align=center>
<tr><td colspan=4 align=center>
<table border=0>
END_OF_BLOCK
    $output .= "<tr><td><b>Site: <select size=1 name=siteid>\n";
    for (my $i=1; $i <= $#sites; $i++) {
        $output .= "<option value=$sites[$i]{id}>$sites[$i]{name}</option>\n";
    }
    $output .= "</select></td></tr>\n";
    $output .= "<tr><td><table border=1 cellpadding=2 cellspacing=0 align=center>\n";
    $output .= "<tr bgcolor=#a0e0c0><td><b>Name</b></td></tr>\n";
    for (my $i=0; $i < $#types; $i++) {
        $output .= "<tr bgcolor=#ffffff><td><a href=javascript:" . (($args{browseOnly} eq 'F') ? "update" : "browse") . "Rule($types[$i]{id})>";
        $output .= "$types[$i]{name}</a></td></tr>\n";
    }
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function updateRule (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'updateruleform');
}

function browseRule (id) {
    $args{form}.id.value=id;
    submitForm('$args{form}', 'displayrule');
}
//--></script>

</table>
</td></tr>
</table>
END_OF_BLOCK
    

    return($output);
}


###################################################################################################################################
sub doRuleEntryForm {  # routine to generate a Rule data entry/update form
###################################################################################################################################
    my %args = (
        type => 'new',
        browseOnly => 'F',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %rule;
    my $id = $settings{id};
    if ($args{type} eq 'update' || $args{browseOnly} eq 'T') {
        %rule = &getRuleInfo(dbh=>$args{dbh}, schema=>$args{schema}, type=>$id, site=>$settings{siteid});
        if (!defined($rule{name}) || $rule{name} le " ") {
            my @types = &getRuleTypesArray(dbh => $args{dbh}, schema => $args{schema}, id=>$id);
            $rule{id} = 0;
            $rule{name} = $types[0]{name};
            $rule{site} = 0;
            $rule{type} = 0;
            $rule{nvalue1} = 0;
            $rule{nvalue2} = 0;
            $rule{cvalue1} = "";
            $rule{cvalue2} = "";
            $args{type} = 'new';
        }
    } else {
        $rule{id} = 0;
        $rule{name} = "";
        $rule{site} = 0;
        $rule{type} = 0;
        $rule{nvalue1} = "";
        $rule{nvalue2} = "";
        $rule{cvalue1} = "";
        $rule{cvalue2} = "";
    }

    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td colspan=2 align=center><table border=0>\n";
    $output .= "<input type=hidden name=siteid value=$settings{siteid}>\n";
    $output .= "<input type=hidden name=ruletype value=$id>\n";
    $output .= "<input type=hidden name=ruleid value=$rule{id}>\n";
    $output .= "<input type=hidden name=brcount value=0>\n";
    my %site = &getSiteInfo(dbh=>$args{dbh}, schema=>$args{schema}, id=>$settings{siteid});
    $output .= "<tr><td><b>Site: </b>$site{name}</td></tr>\n";
    if ($id <= 3 || ($id >= 6 && $id <= 7) || ($id >= 12 && $id <= 13)) {
        if ($id == 0) {
            $rule{nvalue1} = 50000;
        }
        $output .= "<tr><td><b>Name: </b>&nbsp</td><td>$rule{name}</td><tr>\n";
        $output .= "<tr><td><b>Threshold: </b>&nbsp</td><td>";
        if ($args{browseOnly} ne 'T') {
            $output .= "\$<input type=text name=nvalue1 value=\"$rule{nvalue1}\" maxlength=10 size=10>";
        } else {
            $output .= "\$$rule{nvalue1}";
        }
        $output .= "</td><tr>\n";
    } elsif ($id == 5) {
        if ($id == 0) {
            $rule{nvalue1} = 5;
            $rule{nvalue2} = 1;
        }
        $output .= "<tr><td><b>Name: </b>&nbsp</td><td>$rule{name}</td><tr>\n";
        $output .= "<tr><td><b>Lower Threshold: </b>&nbsp</td><td>";
        if ($args{browseOnly} ne 'T') {
            $output .= "<input type=text name=nvalue1 value=\"$rule{nvalue1}\" maxlength=10 size=10>%";
        } else {
            $output .= "$rule{nvalue1}%";
        }
        $output .= "</td><tr>\n";
        $output .= "<tr><td><b>Upper Threshold: </b>&nbsp</td><td>";
        if ($args{browseOnly} ne 'T') {
            $output .= "<input type=text name=nvalue2 value=\"$rule{nvalue2}\" maxlength=10 size=10>%";
        } else {
            $output .= "$rule{nvalue2}%";
        }
        $output .= "</td><tr>\n";
    } elsif ($id == 10) {
        if ($id == 0) {
            $rule{nvalue1} = 90;
            $rule{nvalue2} = 30;
        }
        $output .= "<tr><td><b>Name: </b>&nbsp</td><td>$rule{name}</td><tr>\n";
        $output .= "<tr><td><b>Standard Due Date In Days: </b>&nbsp</td><td>";
        if ($args{browseOnly} ne 'T') {
            $output .= "<input type=text name=nvalue1 value=\"$rule{nvalue1}\" maxlength=3 size=4>";
        } else {
            $output .= "$rule{nvalue1}%";
        }
        $output .= "</td><tr>\n";
        $output .= "<tr><td><b>Priority Due Date In Days: </b>&nbsp</td><td>";
        if ($args{browseOnly} ne 'T') {
            $output .= "<input type=text name=nvalue2 value=\"$rule{nvalue2}\" maxlength=3 size=4>";
        } else {
            $output .= "$rule{nvalue2}%";
        }
        $output .= "</td><tr>\n";
    } elsif ($id == 4 || $id == 9) {
        my @rules = &getRuleArray(dbh=>$args{dbh}, schema=>$args{schema}, type=>$id, site=>$settings{siteid}, orderBy=>'cvalue1 DESC, nvalue1');
        my @clauses = &getClauseArray(dbh=>$args{dbh}, schema=>$args{schema});
        my @types = getRuleTypesArray(dbh => $args{dbh}, schema => $args{schema}, id=>$id);
        $output .= "<tr><td><b>$types[0]{name}</b></td></tr>\n";
        $output .= "<tr><td><table border=1 cellspacing=0>\n";
        $output .= "<tr bgcolor=#a0e0c0><td width=90 align=center><b>Precedence</b></td><td><b>Clause</b></td><td><b>Type</b></td>" . (($id ==4) ? "<td><b>PO</b></td>" : "") . "<td>&nbsp;</td></tr>\n";
        my %types = (H => 'Header', F => 'Footer',);
        $output .= "<input type=hidden name=itemcount value=$#rules>\n";
        for (my $i=0; $i<$#rules; $i++) {
            $output .= "<tr bgcolor=#ffffff>";
            if ($args{browseOnly} ne 'T') {
                $output .= "<input type=hidden name=brid$i value=$rules[$i]{id}>\n";
                $output .= "<input type=hidden name=delete$i value='F'>\n";
                $output .= "<input type=hidden name=saveitem$i value=$rules[$i]{nvalue1}>\n";
                $output .= "<td align=center><input type=text name=nvalue1x$i value=\"$rules[$i]{nvalue1}\" maxlength=5 size=5 onChange=\"checkPresNumber(this, $i);\"></td>";
                $output .= "<td><select name=nvalue2x$i size=1><option value=0> </option>\n";
                for (my $j=0; $j<$#clauses; $j++) {
                    $output .= "<option value=$clauses[$j]{id}" . (($clauses[$j]{id} == $rules[$i]{nvalue2}) ? " selected" : "") . ">" . &getDisplayString($clauses[$j]{description}, 90) . "</option>\n";
                }
                $output .= "</select></td>";
                $output .= "<td align=center><select name=cvalue1x$i size=1>";
                foreach my $key (sort keys %types) {
                    $output .= "<option value=$key" . (($key eq $rules[$i]{cvalue1}) ? " selected" : "") . ">$types{$key}</option>\n";
                }
                $output .= "</select></td>";
                if ($id == 4) {
                    $output .= "<td><input type=checkbox name=cvalue2x$i value='T'" . ((defined($rules[$i]{cvalue2}) && $rules[$i]{cvalue2} eq 'T') ? " checked" : "") . "></td>";
                } else {
                    $output .= "<input type=hidden name=cvalue2x$i value='F'>";
                }
                $output .= "<td><a href=javascript:deleteBR($i)>delete</a></td>";
            } else {
                $output .= "<td>$rules[$i]{nvalue1}</td>";
                $output .= "<td>";
                for (my $j=0; $j<$#clauses; $j++) {
                    if ($clauses[$j]{id} == $rules[$i]{nvalue2}) {
                        $output .= "$clauses[$j]{description}";
                    }
                }
                $output .= "</select></td>";
                $output .= "<td align=center>$types{$rules[$i]{nvalue2}}</td>";
            }
            $output .= "</tr>";
        }
        $output .= "</table>\n";
        $output .= "<table cellpadding=0 cellspacing=0 border=0 id=postItemTable width=100%>";
        if ($args{browseOnly} ne 'T') {
            $output .= "<tr><td align=center><a href=javascript:addClause()><font size=-1>Add Clause</font></a></td></tr></table>\n";
        }
        $output .= "</td></tr>\n";
        $output .= "<script language=javascript><!--\n";
        $output .= "    $args{form}.brcount.value=$#rules;\n";
        $output .= "//--></script>\n";
    $output .= <<END_OF_BLOCK;
<script language=javascript><!--

function deleteBR(item){
    var code = ""
        +"var disable = (($args{form}.delete" + item + ".value == 'F') ? true : false);\\n"
        +"$args{form}.nvalue1x" + item + ".disabled=disable;\\n"
        +"$args{form}.nvalue2x" + item + ".disabled=disable;\\n"
        +"$args{form}.cvalue1x" + item + ".disabled=disable;\\n"
        +"$args{form}.delete" + item + ".value=((disable) ? 'T' : 'F');\\n"
        +"if (disable) {\\n"
        +"    $args{form}.saveitem" + item + ".value=$args{form}.nvalue1x" + item + ".value;\\n"
        +"    $args{form}.nvalue1x" + item + ".value=0;\\n"
        +"} else {\\n"
        +"    $args{form}.nvalue1x" + item + ".value=$args{form}.saveitem" + item + ".value;\\n"
        +"    checkPresNumber($args{form}.nvalue1x" + item + ", " + item + ");\\n"
        +"}\\n"
        + "";
    eval(code);
}

function checkPresNumber(what,item) {
    var msg = "";
    var largest = 0;
    if (!isnumeric(what.value)) {
        msg += 'Precedence must be a positive number\\n';
        what.value = 0;
    }
    for (i=0; i < $args{form}.itemcount.value; i++) {
        var code = ""
            +"if ($args{form}.nvalue1x"+i+".value == what.value && item != i) {\\n"
            +"    msg = 'Precedence must be unique';\\n"
            +"}\\n"
            +"if (($args{form}.nvalue1x"+i+".value - 0) > largest) {largest = $args{form}.nvalue1x"+i+".value;}\\n"
        + "";
        eval(code);
    }
    if (msg != "") {
        alert (msg);
        what.value = largest - 0 + 1;
    }
}

function addClause() {
// add an entry to the clause table
    var largest = 0;
    for (i=0; i < $args{form}.itemcount.value; i++) {
        var code = ""
            +"if (($args{form}.nvalue1x"+i+".value - 0) > largest) {largest = $args{form}.nvalue1x"+i+".value;}\\n"
        eval(code);
    }
    largest++;
    var items = document.$args{form}.itemcount.value;
    items++;
    document.$args{form}.itemcount.value = items;
    items--;
    var newItemRow = "";
    newItemRow += "<table border=1 cellpadding=1 cellspacing=0>\\n";
    newItemRow += "<tr bgcolor=#ffffff>\\n";
    newItemRow += "<input type=hidden name=brid"+ items + " value=0>\\n";
    newItemRow += "<input type=hidden name=delete"+ items + " value='F'>\\n";
    newItemRow += "<input type=hidden name=saveitem"+ items + " value="+ largest + ">\\n";
    newItemRow += "<script language=javascript>\\n";
    newItemRow += "</script>\\n";
    newItemRow += "<td width=90 align=center><input type=text name=nvalue1x"+ items + " value="+ largest + " maxlength=5 size=5 onChange=\\"checkPresNumber(this, "+ items + ");\\"></td>\\n";
    newItemRow += "<td><select name=nvalue2x"+ items + " size=1><option value=0> </option>\\n";
END_OF_BLOCK
        for (my $j=0; $j<$#clauses; $j++) {
            $output .= "    newItemRow += \"<option value=$clauses[$j]{id}>" . &getDisplayString($clauses[$j]{description}, 90) . "</option>\\n\";\n";
        }
    $output .= <<END_OF_BLOCK;
    newItemRow += "</select></td>\\n";
    newItemRow += "<td align=center><select name=cvalue1x"+ items + " size=1>\\n";
END_OF_BLOCK
        foreach my $key (sort keys %types) {
            $output .= "    newItemRow += \"<option value=$key>$types{$key}</option>\\n\";\n";
        }
    $output .= <<END_OF_BLOCK;
    newItemRow += "</select></td>";
END_OF_BLOCK
    if ($id == 4) {
        $output .= <<END_OF_BLOCK;
    newItemRow += "<td><input type=checkbox name=cvalue2x" + items + " value='T'></td>";
END_OF_BLOCK
    } else {
        $output .= <<END_OF_BLOCK;
    newItemRow += "<td><input type=hidden name=cvalue2x" + items + " value='F'></td>";
END_OF_BLOCK
    }
    $output .= <<END_OF_BLOCK;
    newItemRow += "<td><a href=javascript:deleteBR("+ items + ")>delete</a></td>\\n";
    newItemRow += "</tr>\\n";
    newItemRow += "</table>\\n";
    document.all.postItemTable.insertAdjacentHTML("BeforeBegin", "" + newItemRow + "");
    
}

//--></script>
END_OF_BLOCK
    } elsif ($id == 11) {
        my @rules = &getRuleArray(dbh=>$args{dbh}, schema=>$args{schema}, type=>$id, site=>$settings{siteid}, orderBy=>'nvalue1');
        my @questions = &getQuestionArray(dbh=>$args{dbh}, schema=>$args{schema});
        my @types = getRuleTypesArray(dbh => $args{dbh}, schema => $args{schema}, id=>$id);
        $output .= "<tr><td><b>$types[0]{name}</b></td></tr>\n";
        $output .= "<tr><td><table border=1 cellspacing=0>\n";
        $output .= "<tr bgcolor=#a0e0c0><td width=90 align=center><b>Precedence</b></td><td><b>Question</b></td><td>&nbsp;</td></tr>\n";
        $output .= "<input type=hidden name=itemcount value=$#rules>\n";
        for (my $i=0; $i<$#rules; $i++) {
            $output .= "<tr bgcolor=#ffffff>";
            if ($args{browseOnly} ne 'T') {
                $output .= "<input type=hidden name=brid$i value=$rules[$i]{id}>\n";
                $output .= "<input type=hidden name=delete$i value='F'>\n";
                $output .= "<input type=hidden name=saveitem$i value=$rules[$i]{nvalue1}>\n";
                $output .= "<td align=center><input type=text name=nvalue1x$i value=\"$rules[$i]{nvalue1}\" maxlength=5 size=5 onChange=\"checkPresNumber(this, $i);\"></td>";
                $output .= "<td><select name=nvalue2x$i size=1><option value=0> </option>\n";
                for (my $j=0; $j<$#questions; $j++) {
                    $output .= "<option value=$questions[$j]{id}" . (($questions[$j]{id} == $rules[$i]{nvalue2}) ? " selected" : "") . ">" . &getDisplayString($questions[$j]{text}, 90) . "</option>\n";
                }
                $output .= "</select></td>";
                $output .= "<td><a href=javascript:deleteBR($i)>delete</a></td>";
            } else {
                $output .= "<td>$rules[$i]{nvalue1}</td>";
                $output .= "<td>";
                for (my $j=0; $j<$#questions; $j++) {
                    if ($questions[$j]{id} == $rules[$i]{nvalue2}) {
                        $output .= "$questions[$j]{text}";
                    }
                }
                $output .= "</select></td>";
            }
            $output .= "</tr>";
        }
        $output .= "</table>\n";
        $output .= "<table cellpadding=0 cellspacing=0 border=0 id=postItemTable width=100%>";
        if ($args{browseOnly} ne 'T') {
            $output .= "<tr><td align=center><a href=javascript:addQuestion()><font size=-1>Add Question</font></a></td></tr></table>\n";
        }
        $output .= "</td></tr>\n";
        $output .= "<script language=javascript><!--\n";
        $output .= "    $args{form}.brcount.value=$#rules;\n";
        $output .= "//--></script>\n";
    $output .= <<END_OF_BLOCK;
<script language=javascript><!--

function deleteBR(item){
    var code = ""
        +"var disable = (($args{form}.delete" + item + ".value == 'F') ? true : false);\\n"
        +"$args{form}.nvalue1x" + item + ".disabled=disable;\\n"
        +"$args{form}.nvalue2x" + item + ".disabled=disable;\\n"
        +"$args{form}.delete" + item + ".value=((disable) ? 'T' : 'F');\\n"
        +"if (disable) {\\n"
        +"    $args{form}.saveitem" + item + ".value=$args{form}.nvalue1x" + item + ".value;\\n"
        +"    $args{form}.nvalue1x" + item + ".value=0;\\n"
        +"} else {\\n"
        +"    $args{form}.nvalue1x" + item + ".value=$args{form}.saveitem" + item + ".value;\\n"
        +"    checkPresNumber($args{form}.nvalue1x" + item + ", " + item + ");\\n"
        +"}\\n"
        + "";
    eval(code);
}

function checkPresNumber(what,item) {
    var msg = "";
    var largest = 0;
    if (!isnumeric(what.value)) {
        msg += 'Precedence must be a positive number\\n';
        what.value = 0;
    }
    for (i=0; i < $args{form}.itemcount.value; i++) {
        var code = ""
            +"if ($args{form}.nvalue1x"+i+".value == what.value && item != i) {\\n"
            +"    msg = 'Precedence must be unique';\\n"
            +"}\\n"
            +"if (($args{form}.nvalue1x"+i+".value - 0) > largest) {largest = $args{form}.nvalue1x"+i+".value;}\\n"
        + "";
        eval(code);
    }
    if (msg != "") {
        alert (msg);
        what.value = largest - 0 + 1;
    }
}

function addQuestion() {
// add an entry to the clause table
    var largest = 0;
    for (i=0; i < $args{form}.itemcount.value; i++) {
        var code = ""
            +"if (($args{form}.nvalue1x"+i+".value - 0) > largest) {largest = $args{form}.nvalue1x"+i+".value;}\\n"
        eval(code);
    }
    largest++;
    var items = document.$args{form}.itemcount.value;
    items++;
    document.$args{form}.itemcount.value = items;
    items--;
    var newItemRow = "";
    newItemRow += "<table border=1 cellpadding=1 cellspacing=0>\\n";
    newItemRow += "<tr bgcolor=#ffffff>\\n";
    newItemRow += "<input type=hidden name=brid"+ items + " value=0>\\n";
    newItemRow += "<input type=hidden name=delete"+ items + " value='F'>\\n";
    newItemRow += "<input type=hidden name=saveitem"+ items + " value="+ largest + ">\\n";
    newItemRow += "<script language=javascript>\\n";
    newItemRow += "</script>\\n";
    newItemRow += "<td width=90 align=center><input type=text name=nvalue1x"+ items + " value="+ largest + " maxlength=5 size=5 onChange=\\"checkPresNumber(this, "+ items + ");\\"></td>\\n";
    newItemRow += "<td><select name=nvalue2x"+ items + " size=1><option value=0> </option>\\n";
END_OF_BLOCK
        for (my $j=0; $j<$#questions; $j++) {
            $output .= "    newItemRow += \"<option value=$questions[$j]{id}>" . &getDisplayString($questions[$j]{text}, 90) . "</option>\\n\";\n";
        }
    $output .= <<END_OF_BLOCK;
    newItemRow += "</select></td>\\n";
    newItemRow += "<td><a href=javascript:deleteBR("+ items + ")>delete</a></td>\\n";
    newItemRow += "</tr>\\n";
    newItemRow += "</table>\\n";
//alert(newItemRow);
    document.all.postItemTable.insertAdjacentHTML("BeforeBegin", "" + newItemRow + "");
    
}

//--></script>
END_OF_BLOCK
    }
# submit
    if ($args{browseOnly} ne 'T') {
        $output .= "<tr><td colspan=2 align=center><input type=button name=rulesubmit value='Submit' onClick=verifySubmit(document.$args{form})></td></tr>\n";
    }
    
    $output .= "</table>\n";
    
    my $nextCommand = (($args{type} eq 'new') ? "addrule" : "updaterule");
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--


function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    if ((f.ruletype.value <=3 || (f.ruletype.value >=6 && f.ruletype.value <=7)) && (isblank(f.nvalue1.value) || !isnumeric(f.nvalue1.value))) {
        msg += "Threshold value must be a positive whole number.\\n";
    }
    if ((f.ruletype.value ==5) && (isblank(f.nvalue1.value) || !isnumeric(f.nvalue1.value) || isblank(f.nvalue2.value) || !isnumeric(f.nvalue2.value))) {
        msg += "Both threshold values must be a positive whole number.\\n";
    }
    if ((f.ruletype.value == 4)) {
        //msg += "Not yet ready.\\n";
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
sub doRuleEntry {  # routine to get rule entry/update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my $status = &doProcessRuleEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, settings => \%settings);

    if ($args{type} eq 'new') {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "rule type $settings{ruletype} inserted", type => 14);
    } else {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "rule type $settings{ruletype} updated", type => 15);
    }
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','updateruleselect');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub dFormat {  # routine to format dollars
###################################################################################################################################
    my $text = sprintf "%20.2f", ($_[0]);
    $text =~ s/ //g;
    return $text;
}


###################################################################################################################################
###################################################################################################################################



1; #return true
