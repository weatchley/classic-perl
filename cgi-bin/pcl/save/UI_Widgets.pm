# Library of UI widget routines for cgi scripts (used first for CRD)
#
# $Source:$
# $Revision:$
# $Date:$
# $Author:$
# $Locker:$
#
# $Log:$
#

package UI_Widgets;
use strict;
use SCM_Header qw(:Constants);
use DB_Utilities_Lib qw(:Functions);
use CGI qw(param);
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw(%UIHash);
use Tie::IxHash;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (
    &build_dual_select    &build_select_from_piclist 
    &build_drop_box       &build_date_selection 
    &build_text_box       &build_radio_block_wide 
    &gen_table            &start_table 
    &title_row            &add_header_row 
    &add_row              &add_col 
    &add_col_link         &end_table
    &nbspaces             &lpadzero 
    &getDisplayString     &formatID 
    &errorMessage         &writeTitleBar
    &selectProducts       &doRemarksTable
);
@EXPORT_OK = qw(
    &build_dual_select    &build_select_from_piclist 
    &build_drop_box       &build_date_selection 
    &build_text_box       &build_radio_block_wide
    &gen_table            &start_table 
    &title_row            &add_header_row 
    &add_row              &add_col 
    &add_col_link         &end_table
    &nbspaces             &lpadzero 
    &getDisplayString     &formatID 
    &errorMessage         &writeTitleBar
    &selectProducts       &doRemarksTable
);
%EXPORT_TAGS =( Functions => [qw( 
    &build_dual_select    &build_select_from_piclist 
    &build_drop_box       &build_date_selection 
    &build_text_box       &build_radio_block_wide
    &gen_table            &start_table 
    &title_row            &add_header_row 
    &add_row              &add_col 
    &add_col_link         &end_table
    &nbspaces             &lpadzero 
    &getDisplayString     &formatID 
    &errorMessage         &writeTitleBar
    &selectProducts       &doRemarksTable
)]);

#
# Contents of library:
#
# User Interface 'Widgets'
#
# 'build_dual_select'
# (output string) = &build_dual_select( (element name), (form name), \(hash of available values/names), \(hash of selected values/names), (name of available box (left side)), (name of selected box (right side)) [, (locked value)[, (locked value)[, (locked value) [...]]]] );
# 'build_select_from_piclist'
# (output string) = &build_select_from_piclist( (element name), (form name), \(array of values for piclist), (width of text), (size of piclist), (use a button: yes/true or no/false), (sort list: yes/true or no/false), (save data: yes/true or no/false), (max width), (default value) );
# 'build_drop_box'
# (output string) = &build_drop_box( (element name), \(hash of values/names), (selected value) );
# 'build_date_selection'
# (output string) = &build_date_selection( (element name), (form name), (initial date ('today' or date i.e. '12/31/1999') );
#      needs more work, need javascript to make correct number of days
# 'build_text_box'
# (output string) = &build_text_box( (element name), (rows), (cols), (initial text), (left label), (right label), (readonly: yes/true or no/false) );
# 'build_radio_block_wide'
# (output string) = &build_radio_block_wide( (element name), \(hash of values/labels), (default/selected value) );
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
# 'writeTitleBar'
# (output string) = &writeTitleBar( (username), (userid), (schema), (title) );
# 'formatID'
# (output string) = &formatID( (prepend string), (numeric length), (number) );
# 'doRemarks'
# (output string) = &doRemarks( (arg hash - see function header documentation) );
# 'errorMessage'
# (output string) = &errorMessage( (username), (userid), (schema), (application error), (oracle error) );
#

# routine to build a dual selection box from hashes passed to it
#######################
sub build_dual_select {
#######################
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
    tie my %avail, "Tie::IxHash";
    %avail = %$availref;
    tie my %selected, "Tie::IxHash";
    %selected = %$selectedref;
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
    foreach $username (keys %avail) {
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
    foreach $username (keys %selected) {
        $outstring .= "<option value=\"$username\">" . $selected{$username} . "\n";
    }
    $outstring .= "<!-- this is used to force the size of the option box -->\n";
    $outstring .= "<option value=\"\">&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp\n";
    $outstring .= "</select>\n";
    $outstring .= "</td></tr></table>\n\n";
    return ($outstring);
}

# routine to build a combination text box and piclist from data passed to it.
###############################
sub build_select_from_piclist {
###############################
    my $elementname=$_[0];
    my $formname = $_[1];
    my $piclistref = $_[2];
    my $width = $_[3];
    my $size = $_[4];
    my $usebutton = $_[5];
    my $sorted = $_[6];
    my $saveit = $_[7];
    my $maxwidth = $_[8];
    my $default = $_[9];
    my @piclist = @$piclistref;
    my $picname = '';
    my $outstring = '';
    $outstring .= "<input type=text size=$width name=\"$elementname\"" . ((defined($maxwidth) && $maxwidth > 0) ? " maxlength=$maxwidth" : "") . ((defined($default) && $default gt ' ') ? " value='$default'" : "") . ">\n";
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

# routine to build a dropdown box from a passed hash
####################
sub build_drop_box {
####################
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
        if (defined($selectedval)) {
            if ($picname eq $selectedval) {
                $outstring .= "<option value=\"$picname\" selected>" . $values{$picname} . "\n";
            } else {
                $outstring .= "<option value=\"$picname\">" . $values{$picname} . "\n";
            }
        } else {
            $outstring .= "<option value=\"$picname\">" . $values{$picname} . "\n";
        }
    }
    $outstring .= "</select>\n";
    return ($outstring);
}

=pod
# routine to build a date selection widget
##########################
sub build_date_selection {
##########################
    my $elementname=$_[0];
    my $formname=$_[1];
    my $initdate = ((defined($_[2])) ? $_[2] : ' ');
    my $outstring = '';
    my $day=0; my $month=0; my $year=0;
    if ($initdate gt ' ') {
        if ($initdate eq 'today') {
            ($day, $month, $year) = (localtime)[3,4,5];
            $month = $month + 1;
            $year = $year + 1900;
        } else {
            ($month, $day, $year) = split /\//, $initdate;
            $day = 0 if ($day eq "");
            $month = 0 if ($month eq "");
            $year = 0 if ($year eq "");
        }
    }
    $outstring .= "<select name=$elementname\_month size=1><option value=\"\"><option value=1>January<option value=2>February<option value=3>March<option value=4>April<option value=5>May<option value=6>June<option value=7>July<option value=8>August<option value=9>September<option value=10>October<option value=11>November<option value=12>December</select>\n";
    $outstring .= "<select name=$elementname\_day size=1><option value=\"\"><option value=1>1<option value=2>2<option value=3>3<option value=4>4<option value=5>5<option value=6>6<option value=7>7<option value=8>8<option value=9>9<option value=10>10<option value=11>11<option value=12>12<option value=13>13<option value=14>14<option value=15>15<option value=16>16<option value=17>17<option value=18>18<option value=19>19<option value=20>20<option value=21>21<option value=22>22<option value=23>23<option value=24>24<option value=25>25<option value=26>26<option value=27>27<option value=28>28<option value=29>29<option value=30>30<option value=31>31</select>,\n";
    $outstring .= "<select name=$elementname\_year size=1><option value=\"\"><option value=1999>1999<option value=2000>2000<option value=2001>2001<option value=2002>2002<option value=2003>2003<option value=2004>2004<option value=2005>2005</select>\n";
    $outstring .= "<script language=javascript><!--\n";
    $outstring .= "// routine to set the selected value in an option list.\n";
    $outstring .= "function set_selected_option (what, set_val) {\n";
    $outstring .= "    var last =what.length -1;\n";
    $outstring .= "    var index;\n";
    $outstring .= "    for (index=0; index<what.length; index++) {\n";
    $outstring .= "        if (what[index].value == set_val) {\n";
    $outstring .= "            what.selectedIndex = index;\n";
    $outstring .= "        }\n";
    $outstring .= "    }\n";
    $outstring .= "}\n";
    $outstring .= "set_selected_option(document.$formname.$elementname\_month, $month);\n";
    $outstring .= "set_selected_option(document.$formname.$elementname\_day, $day);\n";
    $outstring .= "set_selected_option(document.$formname.$elementname\_year, $year);\n";
    $outstring .= "//--></script>\n";
    return ($outstring);
}
=cut

# routine to build a text box
####################
sub build_text_box {
####################
    my $elementname=$_[0];
    my $rows = $_[1];
    my $cols = $_[2];
    my $text = $_[3];
    my $leftlabel = $_[4];
    my $rightlabel = $_[5];
    my $readonly = ((defined($_[6])) ? $_[6] : "no");
    my $outstring = '';
    $outstring .= "<table border=0 cellpadding=0 cellspacing=0><tr><td halign=left>$leftlabel</td><td align=right>$rightlabel</td></tr>\n";
    $outstring .= "<tr><td colspan=2>\n";
    $outstring .= "<textarea name=$elementname rows=$rows cols=$cols";
    if (($readonly eq "yes") || ($readonly eq "true")) {
        $outstring .= " readonly onfocus=\"on_readonly(this)\"";
    }
    $outstring .= ">";
    $outstring .= "$text";
    $outstring .= "</textarea>\n";
    $outstring .= "</td></tr></table>\n";
    return ($outstring);
}

# routine to build a set of radio buttons
############################
sub build_radio_block_wide {
############################
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

# routine to generate a standard two column table with a title cell
###############
sub gen_table {
###############
    my $arrayref=$_[0];
    my $outstring = "";
    my $color;
    my @table_array = @$arrayref;
    $outstring .= "<table border=1 bordercolor=#d0d0d0 cellpadding=0 cellspacing=0><tr><td><table border=0  cellpadding=0 bgcolor=#ffffff>\n";
    $outstring .= "<tr><td colspan=2 bgcolor=#a0e0c0><font size=+1 color=#000099>$table_array[0][0]</font></td></tr>\n";
    for (my $i=1; $i <= $#table_array; $i++) {
        $color = '#ffffff'; unless ($i%2 == 0) { $color = '#f0f0f0';}
        $outstring .= "<tr bgcolor=$color><td valign=top>$table_array[$i][0]</td><td valign=top>$table_array[$i][1]</td></tr>\n";
    }
    $outstring .= "</table></td></tr></table>\n";
    return ($outstring);
}

# routine to start a standard options table
#################
sub start_table {
#################
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

# routine to generate the title row for a standard options table
###############
sub title_row {
###############
    my $bgcolor=$_[0];
    my $textcolor = $_[1];
    my $text = $_[2];
    my $outstring = "";
    $outstring .= "<tr><td bgcolor=$bgcolor colspan=$UIHash{'table_cols'}><font color=$textcolor><b>$text</b></font></td></tr>\n";
    return ($outstring);
}

# routine to add a header row to a standard options table
####################
sub add_header_row {
####################
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

# routine to add a row to a standard options table
#############
sub add_row {
#############
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

# routine to add a column to a standard options table.  
# optionally, a number of columns to span can be passed in
#############
sub add_col {
#############
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

# routine to add a column with a link to a standard options table
# The URL that the contents of the column will link to is the first parameter
# optionally, a number of columns to span can be passed in as second parameter
##################
sub add_col_link {
##################
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

# routine to end a standard options table
###############
sub end_table {
###############
    my $outstring = "";
    if ($UIHash{'table_row'} >= 0) {
        $outstring .= "</b></font></td></tr>\n";
    }
    $outstring .= "</table>";
    $UIHash{'table_cols'} = "";
    $UIHash{'table_row'} = "";
    $UIHash{'table_cur_col'} = "";
    $UIHash{'table_col_type'} = "";
    return ($outstring);
}

##############
sub nbspaces { # routine to generate a string of non breaking space
##############
    my $numbofspaces = $_[0];
    my $outstring = "";
    for (my $i=1; $i <= $numbofspaces; $i++) {
        $outstring .= "&nbsp;";
    }
    return ($outstring);
}

##############
sub lpadzero { # routine to left pad a string with zeros
##############
    my $instring = $_[0];
    my $strlength = $_[1];
    my $outstring = "";
    for (my $i=1; $i <= ($strlength - length($instring)); $i++) {
        $outstring .= "0";
    }
    $outstring .= $instring;
    return ($outstring);
}

######################
sub getDisplayString {
######################
   my ($str, $maxlen) = @_;
   if (length ($str) > $maxlen) {
      $str = substr ($str, 0, $maxlen + 1);
      $str =~ s/\s+\S+$//;
      $str =~ s/\s+$//;
      $str .= '...';
   }
   return ($str);
}

###################
sub writeTitleBar {
###################
   my %args = (
      @_,
   );
   my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
   $mon = &formatID('', 2, ++$mon);
   $mday = &formatID('', 2, $mday);
   $year += 1900;
   $hour = &formatID('', 2, $hour);
   $min = &formatID('', 2, $min);
   $sec = &formatID('', 2, $sec);
   my $scmcgi = new CGI;
   my $command = (defined($scmcgi->param("command"))) ? $scmcgi->param("command") : "No command";
   my $documentid = (defined($scmcgi->param("id"))) ? $scmcgi->param("id") - 0 : "No Doc ID";
   my $commentid = (defined($scmcgi->param("commentid"))) ? $scmcgi->param("commentid") - 0 : "No Comment ID";
   $ENV{SCRIPT_NAME} =~ m%.*/(.*)%;
   print STDERR "***** $ENV{'SCMType'} $1 $mon/$mday/$year $hour:$min:$sec $args{userName}/$args{userID}/$args{schema} $ENV{REMOTE_ADDR} $command\n";

   $args{schema} = uc($args{schema}) unless ($args{schema} eq "None");
   #$args{title} = lc($args{title}) unless ($args{title} eq "None");
   #$args{title} =~ s/ /_/g;
   ##$args{title} =~ s?/?_?g;
   ##my $output = "<script language=javascript><!--\nparent.frames[1].writeTitleBar('$SCMJavaScriptPath', '$SCMImagePath', '$args{title}', '$args{userName}', '$args{userID}', '$args{schema}');\n//-->\n</script>\n";
   ##my $output = "<script language=javascript><!--\ndoSetTextImageLabel('$args{title}');\n//-->\n</script>\n";
   $ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
   my $path = $1;
   my $form = $2;
   my $output = "<script language=javascript><!--\nparent.frames[1].titleimage.src= '" . $path . "text_labels.pl?width=390&size=15&parsetitle=T&text=$args{title}';\n//-->\n</script>\n";

   if ($SCMDebug) {
      $output .= "<table width=750 border=1>";
      my @list = $scmcgi->param();
      foreach my $item (@list) {
          my $val = $scmcgi->param($item);
        $output .= "<tr><td><b>$item</b></td><td><b>$val</b></tr></td>";
      }
      $output .= "</table>\n";
   }

   return ($output);
}

##############
sub formatID {
##############
   return (sprintf("$_[0]%0$_[1]d", $_[2]));
}

##################
sub errorMessage {
##################
#  Constructs and returns a formatted error message including the 
#  application-specific and oracle error strings and instructions  #
#  for getting help.  This string is intended to be displayed by a 
#  javascript alert() call.  Also writes an error message to the  #
#  database activity_log table and to the web server error log.  
#  The web server error log message consists of the date/time the   #
#  error occurred, the username, userid, and schema in effect, and 
#  the application-specific and oracle error strings.  Required   #
#  parameters are: 
#     dbh         - database handle
#     username    -                
#     userid      -                
#     schema      - database schema
#     appError    - application-specific error string
#     oracleError - oracle error string - obtained from $@ after attempting 
#                   to execute SQL statement(s) inside an eval{}
################################################################

   my ($dbh, $username, $userid, $schema, $appError, $oracleError) = @_;
   my $instructions = "Please save the diagnostic information shown above and contact the Computer Support Center at (702) 794-1335 for assistance.";
   my $errorMessage = "The following error occurred while attempting to $appError:\n\n$oracleError\n$instructions\n";
   my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
   $mon = &formatID('', 2, ++$mon);
   $mday = &formatID('', 2, $mday);
   $year += 1900;
   $hour = &formatID('', 2, $hour);
   $min = &formatID('', 2, $min);
   $sec = &formatID('', 2, $sec);
   print STDERR "\n $ENV{'SCMType'} SCM error: $mon/$mday/$year $hour:$min:$sec - $username/$userid/$schema - $appError failed:\n$oracleError\n";
   my $logError = $appError;
   $logError .= " - " . $oracleError if ($oracleError);
   &log_error($dbh, $schema, $userid, $logError);
   return ($errorMessage);
}

####################
sub selectProducts {
####################
    my %args = (
	rid => 0,
        update => 0,
	@_,
	);
    my $document = ($args{update}) ? "scrupdate" : "scrhome";
    my $outstr;
    my %productshash = get_lookup_values($args{dbh}, $args{schema}, 'scrproduct', 'name', 'id', "1=1 order by name");
    my %productsaffectedhash = get_lookup_values($args{dbh}, $args{schema}, "scrrequestproduct", "productid", "'True'", "requestid = $args{rid}");
    my $key;

    $outstr .= "<tr><td align=left><b><li>Products Affected:&nbsp;&nbsp;</b><br>\n";
    $outstr .= "<table border=0 align=center summary=\"Product Data\">\n";
    $outstr .= "<tr align=center><td><b>Product List</b></td><td>&nbsp;</td>\n";
    $outstr .= "<td><b>Products Affected</b></td></tr><tr><td>\n";
    $outstr .= "<select name=allproductslist size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.$document.allproductslist, document.$document.productsaffected, 'movehist', document.$document.prodhist)\">\n";
    foreach $key (sort keys %productshash) {
        if ($productsaffectedhash{$productshash{$key}} ne 'True') {
            $outstr .= "<option value=\"$productshash{$key}\">$key\n";
        }
    }
    $outstr .= "<option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp</select></td><td>\n";
    $outstr .= "<input name=prodrightarrow title=\"click to commit to the selected product(s)\" value=\"-->\" type=button onclick=\"process_multiple_dual_select_option(document.$document.allproductslist, document.$document.productsaffected, 'movehist', document.$document.prodhist)\">\n";
    $outstr .= "<br>\n";
    $outstr .= "<input name=prodleftarrow title=\"click to remove the selected product(s)\" value=\"<--\" type=button onclick=\"process_multiple_dual_select_option(document.$document.productsaffected, document.$document.allproductslist, 'movehist', document.$document.prodhist)\">\n";
    $outstr .= "<input name=prodhist type=hidden></td><td>\n";
    $outstr .= "<select name=productsaffected size=5 multiple ondblclick=\"process_multiple_dual_select_option(document.$document.productsaffected, document.$document.allproductslist, 'movehist', document.$document.prodhist)\">\n";
    foreach $key (sort keys %productshash) {
        if ($productsaffectedhash{$productshash{$key}} eq 'True') {
            $outstr .= "<option value=\"$productshash{$key}\">$key\n";
        }
    }
    $outstr .= "<option value=''>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp\n";
    $outstr .= "</select></td></tr>\n";
    $outstr .= "</table>\n";
    $outstr .= "<center>Hold the Control key while clicking to select more than one.</center>\n";
    $outstr .= "</td></tr>\n";
print<<end;
<script language=JavaScript type=text/javascript>
<!--
function process_multiple_dual_select_option (source, target, option, history){
    var optionindex = 0;
    var foundone = false;
    var maxindex = source.length;
    for(var i = (maxindex - 2); i >= 0; i--) {
        if (source.options[i].selected) {
            foundone = true;
            if ((option == 'append') || (option == 'move') || (option == 'movehist')){
                insert_option (target, source[i].value, source[i].text, true);
            }
            if (option == 'movehist') {  // add to the history select.
                history.value += source[i].value + '-->' + target.name + ';';
            }
            if ((option == 'remove') || (option == 'move') || (option == 'movehist')) {
                remove_option2 (source, i);
            }
         }
    }
    if (!foundone) {
        alert ("You must make a selection first");
    }
}
// routine to insert passed values to a sorted option list.
// code assumes that the last element in the list is a blank entry
// if sortbytext is true, the insert is done into the sorted text
// rather than the sorted values (default).
function insert_option(what, val, tex, sortbytext) {
    var last = what.length - 1;
    var index;
    sortbytext = (sortbytext==null) ? false : sortbytext;
    what.length = what.length + 1;
    what[what.length - 1].value = what[last].value;
    what[what.length - 1].text = what[last].text;
    index=(last-1);
    if (sortbytext) {
        while ((index>=0)&&(what[index].text>tex)) {
            what[index + 1].value = what[index].value;
            what[index + 1].text = what[index].text;
            index = index - 1;
        }
    }
    else {
        while ((index>=0)&&(what[index].value>val)) {
            what[index + 1].value = what[index].value;
            what[index + 1].text = what[index].text;
            index = index - 1;
        }
    }
    index = index+1;
    what[index].value = val;
    what[index].text = tex;
}
// routine to remove an entry from an option list.
function remove_option2(what, index) {
    what[index] = null;
}
//-->
</script>
end

    return ($outstr);
}

####################
sub doRemarksTable {
####################
    my %args = (
	rid => 0,
	@_,
	);
    my $output;
    my $id = 0; 
    my $table = "";
    my $remarks = "";
    my $entryBackground = '#ffdddd'; 
    my $entryForeground = '#000099';

    $id = formatID ('SCREQ', 5, $args{cid});
    $remarks = "select userid, to_char(dateentered, 'MM/DD/YYYY HH:MI:SS AM'), text from $args{schema}.scrremarks where requestid = $args{cid} order by dateentered desc";
    my $csr = $args{dbh} -> prepare ($remarks);
    $csr -> execute;

    $output .= "<br><table width=650 align=center border=1 cellpadding=4 cellspacing=0>\n";
    $output .= "<tr><td bgcolor=$entryBackground colspan=3><font color=$entryForeground><b>Remarks on request $id</b></font></td></tr>\n";

    $output .= "<tr bgcolor=#f0f0f0>\n"; 
    $output .= "<td width=150><font size=-1><b>Entered By</b></font></td>";
    $output .= "<td width=170><font size=-1><b>Date/Time&nbsp;Entered</b></font></td>\n"; 
    $output .= "<td width=380><font size=-1><b>Text</b></font></td></tr>\n"; 
    my $rows =0;
    while (my @values = $csr -> fetchrow_array){
	$rows++;
	my ($user, $date, $text) = @values;
	$output .= "<tr bgcolor=#ffffff>";
	my ($username) = $args{dbh} -> selectrow_array ("select firstname || ' ' || lastname from $args{schema}.scruser where id=$user");
	$output .= "<td><font size=2><b>$username</td>\n";
	$output .= "<td><font size=2><b>$date</td>\n";
	$text = ($text && $text ne " ") ? $text : "* BLANK MESSAGE *";
	$text =~ s/\n/<BR>/g;
	$output .= "<td><font size=2><b>$text</td>\n";
        $output .= "</tr>";
    }
    $csr -> finish;
    $output .= "</table>\n";
    if ($rows > 0) {
        return ($output);
    }
    else {
	my $nosuch = "<table width=650 align=center><tr><td><b><li>Currently there are no remarks on this request</b></td></tr>\n<tr><td height=15> </td></tr></table>\n"; 
        return ($nosuch);
    }
}



##################

# routine to build a date selection widget
##########################
sub build_date_selection {
##########################
    my $elementname=$_[0];
    my $formname=$_[1];
    my $initdate = $_[2];

    my $outstring = '';
    my $day=0; my $month=0; my $year=0;
    if ($initdate gt ' ') {
        if ($initdate eq 'today') {
            ($day, $month, $year) = (localtime)[3,4,5];
            $month = $month + 1;
            $year = $year + 1900;
        }
        elsif ($initdate eq 'blank') {
            ($month, $day, $year) = (0, 0, "");
        }
        else {
            ($month, $day, $year) = split /\//, $initdate;
        }
    }
    else {
        ($day, $month, $year) = (localtime)[3,4,5];
        $month = $month + 1;
        $year = $year + 1900;
    }

    $outstring .= "<select name=$elementname\_month size=1 onchange=\"document.$formname.$elementname.value = Melt_Date_Parts_Together(document.$formname.$elementname\_month.options[document.$formname.$elementname\_month.selectedIndex].value, document.$formname.$elementname\_day.options[document.$formname.$elementname\_day.selectedIndex].value, document.$formname.$elementname\_year.value);\"><option value=\"\"><option value=1>January<option value=2>February<option value=3>March<option value=4>April<option value=5>May<option value=6>June<option value=7>July<option value=8>August<option value=9>September<option value=10>October<option value=11>November<option value=12>December</select>\n";
    $outstring .= "<select name=$elementname\_day size=1 onchange=\"document.$formname.$elementname.value = Melt_Date_Parts_Together(document.$formname.$elementname\_month.options[document.$formname.$elementname\_month.selectedIndex].value, document.$formname.$elementname\_day.options[document.$formname.$elementname\_day.selectedIndex].value, document.$formname.$elementname\_year.value);\"><option value=\"\"><option value=1>1<option value=2>2<option value=3>3<option value=4>4<option value=5>5<option value=6>6<option value=7>7<option value=8>8<option value=9>9<option value=10>10<option value=11>11<option value=12>12<option value=13>13<option value=14>14<option value=15>15<option value=16>16<option value=17>17<option value=18>18<option value=19>19<option value=20>20<option value=21>21<option value=22>22<option value=23>23<option value=24>24<option value=25>25<option value=26>26<option value=27>27<option value=28>28<option value=29>29<option value=30>30<option value=31>31</select>,\n";
    $outstring .= "<input type=text maxlength=4 size=4 name=$elementname\_year onchange=\"document.$formname.$elementname.value = Melt_Date_Parts_Together(document.$formname.$elementname\_month.options[document.$formname.$elementname\_month.selectedIndex].value, document.$formname.$elementname\_day.options[document.$formname.$elementname\_day.selectedIndex].value, document.$formname.$elementname\_year.value);\"><font size=-1> (enter 4 digit year)</font>\n";
    $outstring .= "<input type=hidden name=$elementname>\n";

    $outstring .= "<script language=javascript><!--\n";
    $outstring .= "   set_selected_option(document.$formname.$elementname\_month, $month);\n";
    $outstring .= "   set_selected_option(document.$formname.$elementname\_day, $day);\n";
    $outstring .= "   document.$formname.$elementname\_year.value = '$year';\n";
    $outstring .= "   document.$formname.$elementname.value = Melt_Date_Parts_Together(document.$formname.$elementname\_month.options[document.$formname.$elementname\_month.selectedIndex].value, document.$formname.$elementname\_day.options[document.$formname.$elementname\_day.selectedIndex].value, document.$formname.$elementname\_year.value);\n";

    $outstring .= "//This function combines a month, day, year value from three fields (from the perl widget which\n";
    $outstring .= "//produces date entry screens) into a single date value in the format (MM/DD/YYYY)\n";
    $outstring .= "function Melt_Date_Parts_Together(monthvalue, dayvalue, yearvalue) {\n";
    $outstring .= "  var zerostring = \"0000\";\n";
    $outstring .= "  var newmonth = zerostring + monthvalue;\n";
    $outstring .= "  var newday = zerostring + dayvalue;\n";
    $outstring .= "  var newyear = zerostring + yearvalue;\n";
    $outstring .= "  newmonth = newmonth.substr(newmonth.length - 2);\n";
    $outstring .= "  newday = newday.substr(newday.length - 2);\n";
    $outstring .= "  newyear = newyear.substr(newyear.length - 4);\n";
    $outstring .= "  return (newmonth + \"/\" + newday + \"/\" + newyear);\n";
    $outstring .= "  }\n";
    $outstring .= "// routine to set the selected value in an option list.\n";
    $outstring .= "function set_selected_option (what, set_val) {\n";
    $outstring .= "  var last = what.length - 1;\n";
    $outstring .= "  var index;\n";
    $outstring .= "  for (index=0; index<what.length; index++) {\n";
    $outstring .= "    if (what[index].value == set_val) {\n";
    $outstring .= "      what.selectedIndex = index;\n";
    $outstring .= "      }\n";
    $outstring .= "    }\n";
    $outstring .= "  }\n";

    $outstring .= "//--></script>\n";

    return ($outstring);
  }

##################


1; #return true

