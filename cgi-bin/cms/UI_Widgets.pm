# Library of UI widget routines for cgi scripts (used first for CRD)

#
# $Source: /data/dev/eis/perl/RCS/UI_Widgets.pm,v $
#
# $Revision: 1.7 $
#
# $Date: 1999/07/22 17:09:56 $
#
# $Author: atchleyb $
#
# $Locker: mccartym $
#
# $Log: UI_Widgets.pm,v $
# Revision 1.7  1999/07/22 17:09:56  atchleyb
# minor modifications
#
# Revision 1.6  1999/07/19 17:48:05  mccartym
# add getDisplayString function
#
# Revision 1.5  1999/07/17 02:06:31  mccartym
# remove sort from keys hash access in build_drop_box()
#
# Revision 1.3  1999/07/15 21:52:00  fergusoc
# change line 510 from "on ... test" to "on ... set" to match
# corresponding javascript function it calls.
#
# Revision 1.1  1999/07/06 18:06:32  atchleyb
# Initial revision
#
#
#
package UI_Widgets;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw(%UIHash);
use Tie::IxHash;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (&build_dual_select &build_select_from_piclist &build_drop_box &build_date_selection &build_text_box &build_radio_block
 &build_radio_block_wide &build_checkbox_textbox_lock &build_selectbox_textbox_lock &gen_table &start_table &title_row &add_header_row &add_row
 &add_col &add_col_link &end_table &nbspaces &lpadzero &getDisplayString &headerBar &expire_form);
@EXPORT_OK = qw(&build_dual_select &build_select_from_piclist &build_drop_box &build_date_selection &build_text_box &build_radio_block
 &build_radio_block_wide &build_checkbox_textbox_lock &build_selectbox_textbox_lock &gen_table &start_table &title_row &add_header_row &add_row
 &add_col &add_col_link &end_table &nbspaces &lpadzero &getDisplayString &headerBar &expire_form);
%EXPORT_TAGS =(
    Functions => [qw(&build_dual_select &build_select_from_piclist &build_drop_box &build_date_selection &build_text_box &build_radio_block
 &build_radio_block_wide &build_checkbox_textbox_lock &build_selectbox_textbox_lock &gen_table &start_table &title_row &add_header_row &add_row
 &add_col &add_col_link &end_table &nbspaces &lpadzero &getDisplayString &headerBar &expire_form) ]
);

#
# Contents of library:
#
# User Interface 'Widgets'
#
# 'build_dual_select'
# (output string) = &build_dual_select( (element name), (form name), \(hash of available values/names), \(hash of selected values/names), (name of available box (left side)), (name of selected box (right side)) [, (locked value)[, (locked value)[, (locked value) [...]]]] );
# 'build_select_from_piclist'
# (output string) = &build_select_from_piclist( (element name), (form name), \(array of values for piclist), (width of text), (size of piclist), (use a button: yes/true or no/false), (sort list: yes/true or no/false), (save data: yes/true or no/false) );
# 'build_drop_box'
# (output string) = &build_drop_box( (element name), \(hash of values/names), (selected value) );
# 'build_date_selection'
# (output string) = &build_date_selection( (element name), (form name), (initial date ('today' or date i.e. '12/31/1999') );
#      needs more work, need javascript to make correct number of days
# 'build_text_box'
# (output string) = &build_text_box( (element name), (rows), (cols), (initial text), (left label), (right label), (readonly: yes/true or no/false) );
# 'build_radio_block'
# (output string) = &build_radio_block( (element name), \(hash of values/labels), (default/selected value) );
# 'build_radio_block_wide'
# (output string) = &build_radio_block_wide( (element name), \(hash of values/labels), (default/selected value) );
# 'build_checkbox_textbox_lock'
# (outputstring) = &build_checkbox_textbox_lock( (formname), (checkbox name), (checkbox label), (checkbox width), (checkbox checked: yes/true or no/false), \(array of textbox names), \(array of textbox labels), \(array of textbox widths), \(array of textbox sizes), \(array of textbox initial values) );
# 'build_selectbox_text_boxlock'
# (output string) = &build_selectbox_textbox_lock( (formname), (selectbox name), (seletbox label), (selectbox width), (selectbox size), (selectbox selected value), \(array of selectbox values), \(array of selectbox 'on' values'), \(array of textbox names), \(array of textbox labels), \(array of textbox widths), \(array of textbox sizes), \(array of textbox initial values) );
# 'gen_table'
# (output string) = &gen_table( \(array of table row arrays) );
#       array[0][0] is the title, array[i][0] is the left column, array[i][1] is the right column
# 'start_table'
# (output string) = &start_table( (number of columns), (table alignment) [, (col width 1), (col width 2), ... , (col width n)] );
# 'title_row'
# (output string) = &title_row( (backgrount color), (text color), (text) );
# 'add_header_row'
# (output string) = &add_header_row;
# 'add_row'
# (output string) = &add_row;
# 'add_col'
# (output string) = &add_col [( (columns to span) )];
# 'add_col_link'
# (output string) = &add_col_link( (url) [, (columns to span)] );
# 'end_table'
# (output string) = &end_table;
# 'nbspaces'
# (output string) = &nbspaces( (number of non-breaking spaces) );
# 'lpadzero'
# (output string) = &lpadzero( (input string), (length of result string) );
# 'getDisplayString'
# (output string) = &getDisplayString( (input string), (max length of output string) );
# 'headerBar'
# (output string) = &headerBar( (userid), (username), (schema) );
# 'expire_form'
# (output string) = &expire_form( (form_name), (location_if_expired) );
#
###########
###########
#
###########
###########

# routine to build a dual selection box from hashes passed to it
sub build_dual_select {
    my $elementname=$_[0];
    my $formname = $_[1];
    my $availref = $_[2];
    my $selectedref = $_[3];
    my $leftname = $_[4];
    my $rightname = $_[5];
    my @lockedvals;

    for (my $i=6; $i<=$#_; $i++) {
        $lockedvals[$i-6] = $_[$i];
    }

    my %avail = %$availref;
    my %selected = %$selectedref;
    my $outstring = '';
    my $username;

# remove entrys from left table that exist in right table
    foreach $username (keys %selected) {
        if (exists ($avail{$username})) {
            delete $avail{$username};
        }
    }

    $outstring .= "\n<!-- set up $elementname -->\n";
    $outstring .= "<table border=0><tr><td valign=top>\n";
    $outstring .= "$leftname<br>\n";
    $outstring .= "<!-- the ondblclick event calls the javascript to move selected element to twin option box -->\n";
    $outstring .= "<select name=avail$elementname size=5 ondblclick=\"process_dual_select_option(document.$formname.avail$elementname,document.$formname.$elementname,'move')\">\n";

    foreach $username (sort keys %avail) {
        $outstring .= "<option value=\"$username\">" . $avail{$username} . "\n";
    }

    $outstring .= "<!-- this is used to force the size of the option box -->\n";
    $outstring .= "<option value=\"\">&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp\n";
    $outstring .= "</select>\n";
    $outstring .= "</td><td align=center>\n";
    $outstring .= "<!-- the select and deselect buttons call the javascript to move selected element to twin option box -->\n";
    $outstring .= "<input type=button value=\"Select ->\" name=select$elementname  onClick=\"process_dual_select_option(document.$formname.avail$elementname,document.$formname.$elementname,'move')\"><br>\n";
    $outstring .= "<input type=button value=\"<- Deselect\" name=deselect$elementname  onClick=\"process_dual_select_option(document.$formname.$elementname,document.$formname.avail$elementname,'move'";
    for (my $i=0; $i<=$#lockedvals; $i++) {
        $outstring .= ", '$lockedvals[$i]'";
    }
    $outstring .= ")\"><br>\n";
    $outstring .= "</td><td valign=top>\n";
    $outstring .= "$rightname<br>\n";
    $outstring .= "<!-- the ondblclick event calls the javascript to move selected element to twin option box -->\n";
    $outstring .= "<select multiple name=$elementname size=5 ondblclick=\"process_dual_select_option(document.$formname.$elementname,document.$formname.avail$elementname,'move'";
    for (my $i=0; $i<=$#lockedvals; $i++) {
        $outstring .= ", '$lockedvals[$i]'";
    }
    $outstring .= ")\">\n";

    foreach $username (sort keys %selected) {
        $outstring .= "<option value=\"$username\">" . $selected{$username} . "\n";
    }

    $outstring .= "<!-- this is used to force the size of the option box -->\n";
    $outstring .= "<option value=\"\">&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp\n";
    $outstring .= "</select>\n";
    $outstring .= "</td></tr></table>\n\n";

    return ($outstring);
}

###########

# routine to build a combination text box and piclist from data passed to it.
sub build_select_from_piclist {
    my $elementname=$_[0];
    my $formname = $_[1];
    my $piclistref = $_[2];
    my $width = $_[3];
    my $size = $_[4];
    my $usebutton = $_[5];
    my $sorted = $_[6];
    my $saveit = $_[7];

    my @piclist = @$piclistref;
    my $picname = '';
    my $outstring = '';

    $outstring .= "<input type=text size=$width name=\"$elementname\">\n";
    if (($usebutton eq "yes") || ($usebutton eq "true")) {
        $outstring .= "<input type=button name=move_$elementname value='<--' onclick=\"select_from_piclist(document.$formname.source_$elementname,document.$formname.$elementname, \'$saveit\')\">\n";
    }
    $outstring .= "<select size=$size name=\"source_$elementname\" ondblclick=\"select_from_piclist(document.$formname.source_$elementname, document.$formname.$elementname, \'$saveit\')\" onchange=\"select_from_piclist(document.$formname.source_$elementname, document.$formname.$elementname, \'$saveit\')\">\n";
    if (($sorted eq "yes") || ($sorted eq "true")) {
        foreach $picname (sort @piclist) {
            $outstring .= "<option value=\"" . $picname . "\">" . $picname . "\n";
        }
    } else {
        foreach $picname (@piclist) {
            $outstring .= "<option value=\"" . $picname . "\">" . $picname . "\n";
        }
    }
    $outstring .= "<option value=\" \"> \n";
    $outstring .= "</select>\n";

    return ($outstring);
}


###########

# routine to build a dropdown box from a passed hash
sub build_drop_box {
    my $elementname=$_[0];
    my $valuesref = $_[1];
    my $selectedval=$_[2];

    tie my %values, "Tie::IxHash";
    %values = %$valuesref;
    my $picname = '';
    my $outstring = '';

    $outstring .= "<select size=1 name=\"$elementname\">\n";
    if (defined($_[3]) && $_[3] eq 'InitialBlank') {
        if ($selectedval le $_[4]) {
            $outstring .= "<option value=\"$_[4]\" selected> \n";
        } else {
            $outstring .= "<option value=\"$_[4]\"> \n";
        }
    }
    foreach $picname (keys %values) {
        if ($picname eq $selectedval) {
            $outstring .= "<option value=\"$picname\" selected>" . $values{$picname} . "\n";
        } else {
            $outstring .= "<option value=\"$picname\">" . $values{$picname} . "\n";
        }
    }
    $outstring .= "</select>\n";

    return ($outstring);
}


###########

# routine to build a date selection widget
sub build_date_selection
  {
    my $elementname=$_[0];
    my $formname=$_[1];
    my $initdate = $_[2];

    my $outstring = '';
#    my @months = ("", "January","February","March","April","May","June","July","August","September","October","November","December");
#    my @monthlengths = (0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    my $day=0; my $month=0; my $year=0;
    if ($initdate gt ' ')
      {
      if ($initdate eq 'today')
        {
        ($day, $month, $year) = (localtime)[3,4,5];
        $month = $month + 1;
        $year = $year + 1900;
        }
      else
        {
        ($month, $day, $year) = split /\//, $initdate;
        }
      }
    else
      {
      ($day, $month, $year) = (localtime)[3,4,5];
      $month = $month + 1;
      $year = $year + 1900;
      }

    $outstring .= "<select name=$elementname\_month size=1 onchange=\"document.$formname.$elementname.value = Melt_Date_Parts_Together(document.$formname.$elementname\_month.options[document.$formname.$elementname\_month.selectedIndex].value, document.$formname.$elementname\_day.options[document.$formname.$elementname\_day.selectedIndex].value, document.$formname.$elementname\_year.value)\"><option value=1>January<option value=2>February<option value=3>March<option value=4>April<option value=5>May<option value=6>June<option value=7>July<option value=8>August<option value=9>September<option value=10>October<option value=11>November<option value=12>December</select>\n";
    $outstring .= "<select name=$elementname\_day size=1 onchange=\"document.$formname.$elementname.value = Melt_Date_Parts_Together(document.$formname.$elementname\_month.options[document.$formname.$elementname\_month.selectedIndex].value, document.$formname.$elementname\_day.options[document.$formname.$elementname\_day.selectedIndex].value, document.$formname.$elementname\_year.value)\"><option value=1>1<option value=2>2<option value=3>3<option value=4>4<option value=5>5<option value=6>6<option value=7>7<option value=8>8<option value=9>9<option value=10>10<option value=11>11<option value=12>12<option value=13>13<option value=14>14<option value=15>15<option value=16>16<option value=17>17<option value=18>18<option value=19>19<option value=20>20<option value=21>21<option value=22>22<option value=23>23<option value=24>24<option value=25>25<option value=26>26<option value=27>27<option value=28>28<option value=29>29<option value=30>30<option value=31>31</select>,\n";
    $outstring .= "<input type=text maxlength=4 size=4 name=$elementname\_year onchange=\"document.$formname.$elementname.value = Melt_Date_Parts_Together(document.$formname.$elementname\_month.options[document.$formname.$elementname\_month.selectedIndex].value, document.$formname.$elementname\_day.options[document.$formname.$elementname\_day.selectedIndex].value, document.$formname.$elementname\_year.value)\"> (enter 4 digit year)\n";
    $outstring .= "<input type=hidden name=$elementname>\n";

    $outstring .= "<script language=javascript><!--\n";
    $outstring .= "   set_selected_option(document.$formname.$elementname\_month, $month);\n";
    $outstring .= "   set_selected_option(document.$formname.$elementname\_day, $day);\n";
    $outstring .= "   document.$formname.$elementname\_year.value = $year;\n";
#    $outstring .= "   alert(document.$formname.$elementname\_month.options[document.$formname.$elementname\_month.selectedIndex].value);\nalert(document.$formname.$elementname\_day.options[document.$formname.$elementname\_day.selectedIndex].value);\nalert(document.$formname.$elementname\_year.value);\n";
    $outstring .= "   document.$formname.$elementname.value = Melt_Date_Parts_Together(document.$formname.$elementname\_month.options[document.$formname.$elementname\_month.selectedIndex].value, document.$formname.$elementname\_day.options[document.$formname.$elementname\_day.selectedIndex].value, document.$formname.$elementname\_year.value);\n";
    $outstring .= "//--></script>\n";

    return ($outstring);
  }


###########

# routine to build a text box
sub build_text_box {
    my $elementname=$_[0];
    my $rows = $_[1];
    my $cols = $_[2];
    my $text = $_[3];
    my $leftlabel = $_[4];
    my $rightlabel = $_[5];
    my $readonly = $_[6];

    my $outstring = '';

    $outstring .= "<table border=0 cellbadding=0 cellspacing=0><tr><td halign=left>$leftlabel</td><td align=right>$rightlabel</td></tr>\n";
    $outstring .= "<tr><td colspan=2>\n";
    $outstring .= "<textarea name=commenttextreadonly rows=$rows cols=$cols";
    if (($readonly eq "yes") || ($readonly eq "true")) {
        $outstring .= " readonly onfocus=\"on_readonly(this)\"";
    }
    $outstring .= ">\n";
    $outstring .= "$text\n";
    $outstring .= "</textarea>\n";
    $outstring .= "</td></tr></table>\n";

    return ($outstring);
}


###########

# routine to build a set of radio buttons
sub build_radio_block {
    my $elementname=$_[0];
    my $optionsref = $_[1];
    my $default = $_[2];

    my $outstring = '';
    my %options = %$optionsref;
    my $opname;

    $outstring .= "<table border=0>\n";
    foreach $opname (keys %options) {
      if ($default eq $opname) {
        $outstring .= "<tr><td><input type=radio name=$elementname value=\"$opname\" checked>" . $options{$opname} . "</td></tr>\n";
      } else {
        $outstring .= "<tr><td><input type=radio name=$elementname value=\"$opname\">" . $options{$opname} . "</td></tr>\n";
      }
    }
    $outstring .= "</table>\n";

    return ($outstring);
}


###########

# routine to build a set of radio buttons
sub build_radio_block_wide {
    my $elementname=$_[0];
    my $optionsref = $_[1];
    my $default = $_[2];

    my $outstring = '';
    my %options = %$optionsref;
    my $opname;

    $outstring .= "<table border=0><tr>\n";
    foreach $opname (keys %options) {
      if ($default eq $opname) {
        $outstring .= "<td><input type=radio name=$elementname value=\"$opname\" checked>" . $options{$opname} . "</td>\n";
      } else {
        $outstring .= "<td><input type=radio name=$elementname value=\"$opname\">" . $options{$opname} . "</td>\n";
      }
    }
    $outstring .= "</tr></table>\n";

    return ($outstring);
}


###########

# routine to build a combo checkbox, texbox with lock
sub build_checkbox_textbox_lock {
    my $formname = $_[0];
    my $cb_name = $_[1];
    my $cb_label = $_[2];
    my $cb_width = $_[3];
    my $cb_checked = $_[4];
    my $tb_nameref = $_[5];
    my $tb_labelref = $_[6];
    my $tb_widthref = $_[7];
    my $tb_sizeref = $_[8];
    my $tb_valueref = $_[9];

# pass arrays by ref
    my @tb_name = @$tb_nameref;
    my @tb_label = @$tb_labelref;
    my @tb_width = @$tb_widthref;
    my @tb_size = @$tb_sizeref;
    my @tb_value = @$tb_valueref;
    my $outstring = "";
    my $tb =0;

# output required javascript functions
    $outstring .= "<script language=javascript><!--\n";
    $outstring .= "// function to enable the text box(es) that are associated with $cb_name\n";
    $outstring .= "function on_$cb_name\_set(focustest) {\n";
    $outstring .= "  if (document.$formname.$cb_name.checked) {\n";
    for ($tb = 0; $tb <= $#tb_name; $tb++) {
        $outstring .= "    document.$formname." . $tb_name[$tb] . ".disabled=false;\n";
        $outstring .= "    if (global_hash." . $tb_name[$tb] . "!= null) {\n";
        $outstring .= "      document.$formname." . $tb_name[$tb] . ".value=global_hash." . $tb_name[$tb] . ";\n";
        $outstring .= "    }\n";
    }
    $outstring .= "    if (focustest != \"NoFocus\") document.$formname." . $tb_name[0] . ".focus();\n";
    $outstring .= "  } else {\n";
    for ($tb = 0; $tb <= $#tb_name; $tb++) {
        $outstring .= "    document.$formname." . $tb_name[$tb] . ".disabled=true;\n";
        $outstring .= "    global_hash." . $tb_name[$tb] . " = document.$formname." . $tb_name[$tb] . ".value;\n";
        $outstring .= "    document.$formname." . $tb_name[$tb] . ".value=\"\";\n";
    }
    $outstring .= "  }\n";
    $outstring .= "}\n";
    $outstring .= "// function to turn off a disabled field with $cb_name\n";
    $outstring .= "function on_$cb_name\_test(obj) {\n";
    $outstring .= "  if (!(document.$formname.$cb_name.checked)) {\n";
    $outstring .= "    obj.blur();\n";
    $outstring .= "  }\n";
    $outstring .= "}\n";
    $outstring .= "//-->\n";
    $outstring .= "</script>\n";

# output check box and text box(es)
    $outstring .= "<table border=0 cellbadding=0 cellspacing=0><tr>";
    $outstring .= "<td width=$cb_width><input type=checkbox name=$cb_name";
    if (($cb_checked eq "yes") || ($cb_checked eq "true")) {$outstring .= " checked";}
    $outstring .= " onClick=\"on_$cb_name\_set('Focus')\">$cb_label </td>\n";
    for ($tb = 0; $tb <= $#tb_name; $tb++) {
        $outstring .= "<td>" . $tb_label[$tb] . "<input type=textbox name=" . $tb_name[$tb] . " size=" . $tb_size[$tb] . " value=\"" . $tb_value[$tb] . "\" onfocus=\"on_$cb_name\_test(this)\"></td>\n";
    }
    $outstring .= "</tr></table>\n";

# activate locking
    $outstring .= "<script language=javascript><!--\n";
    $outstring .= "on_$cb_name\_set(\"NoFocus\");\n";
    $outstring .= "//-->\n";
    $outstring .= "</script>\n";

    return ($outstring);
}


###########

# routine to build a select box text box with lock combo
sub build_selectbox_textbox_lock {
    my $formname = $_[0];
    my $sb_name = $_[1];
    my $sb_label = $_[2];
    my $sb_width = $_[3];
    my $sb_size = $_[4];
    my $sb_selected = $_[5];
    my $sb_valuesref = $_[6];
    my $sb_onvalueref = $_[7];
    my $tb_nameref = $_[8];
    my $tb_labelref = $_[9];
    my $tb_widthref = $_[10];
    my $tb_sizeref = $_[11];
    my $tb_valueref = $_[12];

# pass arrays by ref
    my @sb_values = @$sb_valuesref;
    my @sb_onvalue = @$sb_onvalueref;
    my @tb_name = @$tb_nameref;
    my @tb_label = @$tb_labelref;
    my @tb_width = @$tb_widthref;
    my @tb_size = @$tb_sizeref;
    my @tb_value = @$tb_valueref;
    my $outstring = "";
    my $tb =0;
    my $sb_value = "";
    my $sb_onvalue = "";

# output required javascript functions
    $outstring .= "<script language=javascript><!--\n";
    $outstring .= "// function to enable the text box(es) that are associated with $sb_name\n";
    $outstring .= "function on_$sb_name\_set(focustest) {\n";
    $outstring .= "  var index;\n";
    $outstring .= "  var enabled = \"false\";\n";
    $outstring .= "  if (document.$formname.$sb_name.selectedIndex != -1) {\n";
    $outstring .= "    index = document.$formname.$sb_name.selectedIndex;\n";
    foreach $sb_onvalue (@sb_onvalue) {
        $outstring .= "    if (document.$formname." . $sb_name . "[index].value == \"$sb_onvalue\") {enabled = \"true\";}\n";
    }
    $outstring .= "  }\n";
    $outstring .= "  if (enabled == \"true\") {\n";
    for ($tb = 0; $tb <= $#tb_name; $tb++) {
        $outstring .= "    document.$formname." . $tb_name[$tb] . ".disabled=false;\n";
        $outstring .= "    if (global_hash." . $tb_name[$tb] . "!= null) {\n";
        $outstring .= "      document.$formname." . $tb_name[$tb] . ".value=global_hash." . $tb_name[$tb] . ";\n";
        $outstring .= "    }\n";
    }
    $outstring .= "    if (focustest != \"NoFocus\") {document.$formname." . $tb_name[0] . ".focus();}\n";
    $outstring .= "  } else {\n";
    for ($tb = 0; $tb <= $#tb_name; $tb++) {
        $outstring .= "    document.$formname." . $tb_name[$tb] . ".disabled=true;\n";
        $outstring .= "    if (document.$formname." . $tb_name[$tb] . ".value != \"\") {global_hash." . $tb_name[$tb] . " = document.$formname." . $tb_name[$tb] . ".value;}\n";
        $outstring .= "    document.$formname." . $tb_name[$tb] . ".value=\"\";\n";
    }
    $outstring .= "  }\n";
    $outstring .= "}\n";
    $outstring .= "// function to turn off a disabled field with $sb_name\n";
    $outstring .= "function on_$sb_name\_test(obj) {\n";
    $outstring .= "  var enabled = \"false\";\n";
    $outstring .= "  if (document.$formname.$sb_name.selectedIndex != -1) {\n";
    $outstring .= "    index = document.$formname.$sb_name.selectedIndex;\n";
    foreach $sb_onvalue (@sb_onvalue) {
        $outstring .= "    if (document.$formname." . $sb_name . "[index].value == \"$sb_onvalue\") {\n";
        $outstring .= "      enabled = \"true\";\n";
        $outstring .= "    }\n";
    }
    $outstring .= "  }\n";
    $outstring .= "  if (enabled == \"false\") {\n";
    $outstring .= "    obj.blur();\n";
    $outstring .= "  }\n";
    $outstring .= "}\n";
    $outstring .= "//-->\n";
    $outstring .= "</script>\n";

# output select box and text box(es)
    $outstring .= "<table border=0 cellbadding=0 cellspacing=0><tr>";
    $outstring .= "<td width=$sb_width><table border=0 cellbadding=0 cellspacing=0><tr><td>$sb_label</td><td><select name=$sb_name size=$sb_size";
    $outstring .= " onChange=\"on_$sb_name\_set('Focus')\">\n";

    foreach $sb_value (@sb_values) {
        $outstring .= "<option value=\"$sb_value\"";
        if ($sb_value eq $sb_selected) {$outstring .= " selected";}
        $outstring .= ">$sb_value\n";
    }
    $outstring .= "</select></td></tr></table></td>\n";

    for ($tb = 0; $tb <= $#tb_name; $tb++) {
        $outstring .= "<td>" . $tb_label[$tb] . "<input type=textbox name=" . $tb_name[$tb] . " size=" . $tb_size[$tb] . " value=\"" . $tb_value[$tb] . "\" onfocus=\"on_$sb_name\_set(this)\"></td>\n";
    }
    $outstring .= "</tr></table>\n";

# activate locking
    $outstring .= "<script language=javascript><!--\n";
    $outstring .= "on_$sb_name\_set(\"NoFocus\");\n";
    $outstring .= "//-->\n";
    $outstring .= "</script>\n";

    return ($outstring);
}


###########

# routine to generate a standard two column table with a title cell
sub gen_table {
    my $arrayref=$_[0];
    my $outstring = "";
    my $color;

    my @table_array = @$arrayref;

    $outstring .= "<table border=1 bordercolor=#e0e0e0 cellpadding=0 cellspacing=0><tr><td><table border=0 cellpadding=0 bgcolor=#ffffff>\n";
    $outstring .= "<tr><td colspan=2 bgcolor=#000099><font size=+1 color=#ffffff>$table_array[0][0]</font></td></tr>\n";
    for (my $i=1; $i <= $#table_array; $i++) {
        $color = '#ffffff'; unless ($i%2 == 0) { $color = '#f0f0f0';}
        $outstring .= "<tr bgcolor=$color><td valign=top>$table_array[$i][0]</td><td valign=top>$table_array[$i][1]</td></tr>\n";
    }
    $outstring .= "</table></td></tr></table>\n";

    return ($outstring);

}


###########

# routine to start a standard options table
sub start_table {
    my $cols = $_[0];
    my $align = $_[1];
# get column widths if they were passed in
    for (my $i = 2; $i<=($cols+1);$i++) {
        my $j=$i-1;
        if ($_[$i]) {
            $UIHash{"table_col_wid$j"} = $_[$i];
        } else {
            $UIHash{"table_col_wid$j"} = 0;
        }
    }

    my $outstring = "";
    $UIHash{'table_cols'} = $cols;
    $UIHash{'table_row'} = -1;
    $UIHash{'table_cur_col'} = 0;
    $UIHash{'table_col_type'} = 'standard';

    $outstring .= "<table width=750 cellpadding=4 cellspacing=0 border=1 align=$align>\n";

    return ($outstring);
}


###########

# routine to generate the title row for a standard options table
sub title_row {
    my $bgcolor=$_[0];
    my $textcolor = $_[1];
    my $text = $_[2];

    my $outstring = "";

    $outstring .= "<tr><td bgcolor=$bgcolor colspan=$UIHash{'table_cols'}><font color=$textcolor><b>$text</b></font></td></tr>\n";

    return ($outstring);

}


###########

# routine to add a header row to a standard options table
sub add_header_row {

    my $outstring = "";
    $UIHash{'table_cur_col'} = 0;

    if ($UIHash{'table_row'} >= 0) {
        $outstring .= "</td></tr>\n";
        if ($UIHash{'table_row'} > 0) {
            $outstring .= "<tr><td colspan=$UIHash{'table_cols'} height=4></td></tr>\n";
        }
    }
    $outstring .= "<tr bgcolor=#f0f0f0>\n";
    $UIHash{'table_row'} = 0;
    $UIHash{'table_col_type'} = 'standard';

    return ($outstring);

}


###########

# routine to add a row to a standard options table
sub add_row {

    my $outstring = "";
    $UIHash{'table_cur_col'} = 0;

    if ($UIHash{'table_row'} >= 0) {
        if ($UIHash{'table_col_type'} eq 'link') {
            $outstring .= "</a>";
        }
        $outstring .= "</b></font></td></tr>\n";
        if ($UIHash{'table_row'} == 0) {
            $outstring .= "<tr><td colspan=$UIHash{'table_cols'} height=4></td></tr>\n";
        }
    }
    $outstring .= "<tr bgcolor=#ffffff>\n";
    $UIHash{'table_row'}++;
    $UIHash{'table_col_type'} = 'standard';

    return ($outstring);

}


###########

# routine to add a column to a standard options table
# optionally, a number of columns to span can be passed in
sub add_col {
    my $colspan=$_[0];

    my $outstring = "";

    if ($UIHash{'table_cur_col'} >= 1) {
        if ($UIHash{'table_col_type'} eq 'link') {
            $outstring .= "</a>";
        }
        $outstring .= "</b></font></td>";
    }
    $UIHash{'table_cur_col'}++;
    $outstring .= "<td";
    if ($colspan) {
        $outstring .= " colspan=$colspan";
    } else {
        my $cur_col = $UIHash{'table_cur_col'};
        my $hashvar = "table_col_wid$cur_col";
        if ($UIHash{$hashvar} != 0) {
            $outstring .= " width=" . $UIHash{$hashvar};
        }
    }
    $outstring .= "><font size=-1><b>";
    $UIHash{'table_col_type'} = 'standard';

    return ($outstring);

}


###########

# routine to add a column with a link to a standard options table
# The URL that the contents of the column will link to is the first parameter
# optionally, a number of columns to span can be passed in as the second parameter
sub add_col_link {
    my $url_link=$_[0];
    my $colspan=$_[1];

    my $outstring = "";

    if ($UIHash{'table_cur_col'} >= 1) {
        if ($UIHash{'table_col_type'} eq 'link') {
            $outstring .= "</a>";
        }
        $outstring .= "</b></font></td>";
    }
    $UIHash{'table_cur_col'}++;
    $outstring .= "<td";
    if ($colspan) {
        $outstring .= " colspan=$colspan";
    } else {
        my $cur_col = $UIHash{'table_cur_col'};
        my $hashvar = "table_col_wid$cur_col";
        if ($UIHash{$hashvar} != 0) {
            $outstring .= " width=" . $UIHash{$hashvar};
        }
    }
    $outstring .= "><font size=-1><b><a href=$url_link>";
    $UIHash{'table_col_type'} = 'link';

    return ($outstring);

}


###########

# routine to end a standard options table
sub end_table {

    my $outstring = "";

    if ($UIHash{'table_row'} >= 0) {
        $outstring .= "</b></font></td></tr>\n";
    }
    $outstring .= "</table>";
#    for (my $i = 1; $i<=$UIHash{'table_cols'); $i++) {
#        $UIHash{"table_col_wid$i"} = "";
#    }
    $UIHash{'table_cols'} = "";
    $UIHash{'table_row'} = "";
    $UIHash{'table_cur_col'} = "";
    $UIHash{'table_col_type'} = "";
#    $UIHash{'table_'} = "";

    return ($outstring);

}


###########

# routine to generate a string of non breaking spaces
sub nbspaces {
    my $numbofspaces = $_[0];

    my $outstring = "";

    for (my $i=1; $i <= $numbofspaces; $i++) {
        $outstring .= "&nbsp;";
    }

    return ($outstring);
}


###########

# routine to left pad a string with zeros
sub lpadzero {
    my $instring = $_[0];
    my $strlength = $_[1];

    my $outstring = "";

    for (my $i=1; $i <= ($strlength - length($instring)); $i++) {
        $outstring .= "0";
    }
    $outstring .= $instring;
    return ($outstring);
}

###########

sub getDisplayString {
   my ($str, $maxlen) = @_;
   if (length ($str) > $maxlen) {
      $str = substr ($str, 0, $maxlen + 1);
      $str =~ s/\s+\S+$//;
      $str =~ s/\s+$//;
      $str .= '...';
   }
   return ($str);
}

###########

sub headerBar {
   my ($userid, $username, $schema) = @_;
   my $output =  "<center><table width=700 border=2 bordercolorlight=#ccddee bordercolordark=#2f4f4f cellspacing=0 cellpadding=0><tr>\n";
   $output .= "<td width=50% height=23 bgcolor=#f3f3f3 align=center><font face=arial color='#000060'><b>User Name&nbsp;/&nbsp;ID:&nbsp;&nbsp;&nbsp;<font color=#0000ff>$username&nbsp;/&nbsp;$userid</font></b></font></td>\n";
   $output .= "<td width=50% height=23 bgcolor=#f3f3f3 align=center><font face=arial color='#000060'><b>Database:&nbsp;&nbsp;&nbsp;<font color=#0000ff>$schema</font></b></font></td>\n";
   $output .= "</tr></table></center>\n";
   return ($output);
}

###########

sub expire_form
  {
  # This routine will add a hidden field named isexpired and script to test the value of isexpired.
  # If isexpired is zero, then the value is automatically changed to -1.  If it is -1, the new
  # location is loaded.
  # This basically expires a page using IE.
  # This does not work with Netscape, so the calling perl script must validate the user.
  my $formname = $_[0];
  my $locationifexpired = $_[1];
  my $output = "  <input type=hidden name=isexpired value=0>\n";
  $output .= "  <script language='JavaScript' type='text/javascript'>\n";
  $output .= "  <!--\n";
  $output .= "  if (document.$formname.isexpired.value == -1)\n";
  $output .= "    {\n";
  $output .= "    location = '$locationifexpired';\n";
  $output .= "    }\n";
  $output .= "  else\n";
  $output .= "    {\n";
  $output .= "    document.$formname.isexpired.value = -1;\n";
  $output .= "    }\n";
  $output .= "  //-->\n";
  $output .= "  </script>\n";
  return ($output);
  }

###########

# routine to
#sub testit {
#    my $elementname=$_[0];
#    my $usersref = $_[1];
#    my $other = $_[2];

#    my %users = %$usersref;

#    print "Name = $name\n";
#    print "User 1 = " . $users{'brownf'} . "\n";
#    print "Other = $other\n";
#}

###########

#{
#}
1; #return true
