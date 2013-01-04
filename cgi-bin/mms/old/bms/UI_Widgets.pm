# Library of UI widget routines for cgi scripts (used first for BMS)

#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
#
#
package UI_Widgets;
use strict;
use BMS_Header qw(:Constants);
use DB_Utilities_Lib qw(:Functions);
use CGI qw(param);
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw(%UIHash);
use Tie::IxHash;
use Text_Menus;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (
   &build_dual_select &build_select_from_piclist &build_drop_box &build_date_selection &build_radio_block_wide
   &gen_table &start_table &title_row &add_header_row &add_row &add_col &add_col_link &end_table
   &nbspaces &lpadzero &getDisplayString &formatID &doRemarks &errorMessage &writeTitleBar 
   &BuildPrintCommentResponse &BuildPrintSummaryCommentResponse
);
@EXPORT_OK = qw(
   &build_dual_select &build_select_from_piclist &build_drop_box &build_date_selection &build_radio_block_wide
   &gen_table &start_table &title_row &add_header_row &add_row &add_col &add_col_link &end_table
   &nbspaces &lpadzero &getDisplayString &formatID &doRemarks &errorMessage &writeTitleBar 
   &BuildPrintCommentResponse &BuildPrintSummaryCommentResponse
);
%EXPORT_TAGS =( Functions => [qw(
   &build_dual_select &build_select_from_piclist &build_drop_box &build_date_selection &build_radio_block_wide
   &gen_table &start_table &title_row &add_header_row &add_row &add_col &add_col_link &end_table
   &nbspaces &lpadzero &getDisplayString &formatID &doRemarks &errorMessage &writeTitleBar 
   &BuildPrintCommentResponse &BuildPrintSummaryCommentResponse
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
sub build_select_from_piclist {
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

# routine to build a date selection widget
sub build_date_selection {
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
    $outstring .= "   set_selected_option(document.$formname.$elementname\_month, $month);\n";
    $outstring .= "   set_selected_option(document.$formname.$elementname\_day, $day);\n";
    $outstring .= "   set_selected_option(document.$formname.$elementname\_year, $year);\n";
    $outstring .= "//--></script>\n";
    return ($outstring);
}

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

# routine to generate a standard two column table with a title cell
sub gen_table {
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

# routine to generate the title row for a standard options table
sub title_row {
    my $bgcolor=$_[0];
    my $textcolor = $_[1];
    my $text = $_[2];
    my $outstring = "";
    $outstring .= "<tr><td bgcolor=$bgcolor colspan=$UIHash{'table_cols'}><font color=$textcolor><b>$text</b></font></td></tr>\n";
    return ($outstring);
}

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

# routine to add a column to a standard options table.  optionally, a number of columns to span can be passed in
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

# routine to end a standard options table
sub end_table {
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

###################################################################################################################################
sub nbspaces { # routine to generate a string of non breaking space                                                               #
###################################################################################################################################
    my $numbofspaces = $_[0];
    my $outstring = "";
    for (my $i=1; $i <= $numbofspaces; $i++) {
        $outstring .= "&nbsp;";
    }
    return ($outstring);
}

###################################################################################################################################
sub lpadzero { # routine to left pad a string with zeros                                                                          #
###################################################################################################################################
    my $instring = $_[0];
    my $strlength = $_[1];
    my $outstring = "";
    for (my $i=1; $i <= ($strlength - length($instring)); $i++) {
        $outstring .= "0";
    }
    $outstring .= $instring;
    return ($outstring);
}

###################################################################################################################################
sub getDisplayString {                                                                                                            #
###################################################################################################################################
   my ($str, $maxlen) = @_;
   if (length ($str) > $maxlen) {
      $str = substr ($str, 0, $maxlen + 1);
      $str =~ s/\s+\S+$//;
      $str =~ s/\s+$//;
      $str .= '...';
   }
   return ($str);
}

###################################################################################################################################
sub writeTitleBar {                                                                                                               #
###################################################################################################################################
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
   my $bmscgi = new CGI;
   my $command = (defined($bmscgi->param("command"))) ? $bmscgi->param("command") : "No command";
   my $documentid = (defined($bmscgi->param("id"))) ? $bmscgi->param("id") - 0 : "No Doc ID";
   my $commentid = (defined($bmscgi->param("commentid"))) ? $bmscgi->param("commentid") - 0 : "No Comment ID";
   $ENV{SCRIPT_NAME} =~ m%.*/(.*)%;
   print STDERR "***** $ENV{'BMSType'} $1 $mon/$mday/$year $hour:$min:$sec $args{userName}/$args{userID}/$args{schema} $ENV{REMOTE_ADDR} $command/$documentid/$commentid\n";

   $args{schema} = uc($args{schema}) unless ($args{schema} eq "None");
   #$args{title} = lc($args{title}) unless ($args{title} eq "None");
   #$args{title} =~ s/ /_/g;
   ##$args{title} =~ s?/?_?g;
   ##my $output = "<script language=javascript><!--\nparent.frames[1].writeTitleBar('$BMSJavaScriptPath', '$BMSImagePath', '$args{title}', '$args{userName}', '$args{userID}', '$args{schema}');\n//-->\n</script>\n";
   ##my $output = "<script language=javascript><!--\ndoSetTextImageLabel('$args{title}');\n//-->\n</script>\n";
   $ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
   my $path = $1;
   my $form = $2;
   my $output = "<script language=javascript><!--\nparent.frames[1].titleimage.src= '" . $path . "text_labels.pl?width=390&size=15&parsetitle=T&text=$args{title}';\n//-->\n</script>\n";

   if ($BMSDebug) {
      my $menu1 = new Text_Menus;
      my $output2 = "<table width=750 border=1>";
      my @list = $bmscgi->param();
      foreach my $item (@list) {
          my $val = $bmscgi->param($item);
        $output2 .= "<tr><td><b>$item</b></td><td><b>$val</b></tr></td>";
      }
      $output2 .= "</table>\n";
      $menu1->addMenu(name => "Menu1", label => "View Debug Info", contents => $output2);
      $output .= $menu1->buildMenus(name => 'DebugMenu1', type => "list");
   }

   return ($output);
}

###################################################################################################################################
sub formatID {                                                                                                                    #
###################################################################################################################################
   return (sprintf("$_[0]%0$_[1]d", $_[2]));
}

###################################################################################################################################
sub buildRemarksTable {                                                                                                           #
###################################################################################################################################
   my %args = %{$_[0]};
   my ($table, $where) = ("", "");
   my $noRemarks = "<font size=3><b>No Remarks for ";
   $args{remark_type} = lc($args{remark_type});
   if ($args{remark_type} eq 'document') {
      $table = 'document_remark';
      $where = "document = $args{document}";
      $noRemarks .= "Document " . &formatID($BMSType, 6, $args{document});
      $args{remark_type} = 'Document';
   } elsif ($args{remark_type} eq 'comment') {
      $table = 'comments_remark';
      $where = "document = $args{document} and commentnum = $args{comment}";
      $noRemarks .= "Comment " . &formatID($BMSType, 6, $args{document}) . " / " . &formatID("", 4, $args{comment});
      $args{remark_type} = 'Comment';
   } elsif ($args{remark_type} eq 'summary comment') {
      $table = 'summary_remark';
      $where = "summarycomment = $args{summary_comment}";
      $args{remark_type} = 'Summary Comment';
      $noRemarks .=  "$args{remark_type} " . &formatID('SCR', 4, $args{summary_comment});
   }
   $noRemarks .= "</b></font>";
   my $title = "Remarks for $args{remark_type} $args{formattedid}";
   my ($barColor, $barTextColor, $dateFormat) = ('#cdecff', '#000099', 'DD-MON-YY HH24:MI:SS');
   my $sql = "select remarker, text, to_char(dateentered, '$dateFormat') from $args{schema}.$table where $where order by dateentered desc";
   my $csr = $args{dbh}->prepare($sql);
   $csr->execute;
   my $out = "<tr><td align=right>\n";
   $out .= &start_table(3, 'right', 120, 130, 500);
   $out .= &title_row($barColor, $barTextColor, $title);
   $out .= &add_header_row();
   $out .= &add_col() . "Entered By";
   $out .= &add_col() . "Date/Time Entered";
   $out .= &add_col() . "Remark Text";
   my $rows = 0;
   while (my @values = $csr->fetchrow_array) {
      $rows++;
      my ($remarker, $text, $date) = @values;
      $text =~ s/\n/<br>/g;
      $out .= &add_row();
      $out .= &add_col_link("javascript:display_user($remarker)") . &get_fullname($args{dbh}, $args{schema}, $remarker);
      $out .= &add_col() . $date;
      $out .= &add_col() . $text;
   }
   $csr->finish;
   if ($rows == 0) {
      $out = "<tr><td align=right>\n";
      $out .= &start_table(1, 'right', 750);
      $out .= &title_row($barColor, $barTextColor, $noRemarks);
   }
   $out .= &end_table();
   $out .= "</td></tr>\n";
   return ($out);
}

###################################################################################################################################
sub doRemarks {                                                                                                                   #
#                                                                                                                                 #
#  Constructs remarks table(s) and remarks entry text box.  Uses args hash to accept parameters passed by name (in any order).    #
#  Required parameters are:                                                                                                       #
#                                                                                                                                 #
#     schema          - database schema                                                                                           #
#     dbh             - database handle (could make this parameter optional and create connection for use here if not passed in)  #
#     remark_type     - valid values are: 'document', 'comment', 'summary comment'                                                #
#     document        - document id (required if remark_type is 'document' or 'comment')                                          #
#     comment         - comment id (required if remark_type is 'comment')                                                         #
#     summary_comment - summary comment id (required if remark_type is 'summary comment')                                         #
#                                                                                                                                 #
#  The values named in %args below are optional and default to the values shown.  The caller must provide a javascript            #
#  event handler function in their script (named saveRamark() by default) to process submitted remarks, which will be in the      #
#  text box (named 'remarktext' by default).  The remarks table header is not displayed if the table is empty.  If remark_type    #
#  is 'comment', remarks tables for both the comment and the source comment document will be displayed.  The text box for         #
#  entering remarks is dispalyed by default.  It can be disabled by passing any value that evaluates to false in the              #
#  show_text_box parameter.  Example calling sequences for each remark type follow:                                               #
#                                                                                                                                 #
#  document:         print &doRemarks(schema => $schema, dbh => $dbh, remark_type => 'document', document => $documentid);        #
#  comment:          print &doRemarks(schema => $schema, dbh => $dbh, remark_type => 'comment', document => $documentid,          #
#                                     comment => $commentid);                                                                     #
#  summary comment:  print &doRemarks(schema => $schema, dbh => $dbh, remark_type => 'summary comment',                           #
#                                     summary_comment => $commentid);                                                             #
#                                                                                                                                 #
#  The following examples shows calls which override one or more of the default values:                                           #
#                                                                                                                                 #
#  print &doRemarks(schema = > $schema, dbh => $dbh, remark_type => 'document', document => $documentid,                          #
#                   text_box_name => 'myname', submit_event_handler => 'myHandler()');                                            #
#  print &doRemarks(schema = > $schema, dbh => $dbh, remark_type => 'document', document => $documentid, show_text_box => 0);     #
#                                                                                                                                 #
###################################################################################################################################
   my %args = (
      useForm => 0,
      show_text_box => 1,
      text_box_name => 'remarktext',
      submit_event_handler => 'saveRemark()',
      submit_button_name => 'remarksubmit',
      submit_button_label => 'Submit Remarks',
      @_,
   );
   my $out;
   $args{remark_type} = lc($args{remark_type});
   if ($args{remark_type} eq 'comment') {
      $args{remark_type} = 'Document';
      $args{formattedid} = &formatID($BMSType, 6, $args{document});
      $out = &buildRemarksTable(\%args);
      $out .= "<tr><td height=15> </td></tr>\n";
      $args{remark_type} = 'Comment';
      $args{formattedid} = &formatID('', 4, $args{comment});
   } elsif ($args{remark_type} eq 'document') {
      $args{remark_type} = 'Document';
      $args{formattedid} = &formatID($BMSType, 6, $args{document});
   } elsif ($args{remark_type} eq 'summary comment') {
      $args{remark_type} = 'Summary Comment';
      $args{formattedid} = &formatID('SCR', 4, $args{summary_comment});
   }
   $out .= &buildRemarksTable(\%args);
   if ($args{show_text_box}) {
      my $bmscgi = new CGI;
      my $text = ($args{useForm} && defined($bmscgi->param($args{text_box_name}))) ? $bmscgi->param($args{text_box_name}) : "";
      $out .= "<tr><td height=15> </td></tr>\n";
      $out .= "<tr><td>\n";
      $ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
      my $form = $2;
      my $expand = "<a href=\"javascript:expandTextBox(document.$form.$args{text_box_name},document.$args{text_box_name}_button,'force',5);\">\n";
      $expand .= "<img name=$args{text_box_name}_button border=0 src=$BMSImagePath/expand_button.gif></a>\n";
      $out .= "<table border=0 cellpadding=0 cellspacing=0>\n";
      $out .= "<td align=left valign=bottom><b>Enter Remarks for $args{remark_type} $args{formattedid}:</b></td>\n";
      $out .= "<td align=right valign=bottom>$expand</td></tr>\n";
      $out .= "<tr><td colspan=2><textarea name=$args{text_box_name} rows=4 cols=90 wrap=physical ";
      $out .= "onKeyPress=\"expandTextBox(this,document.$args{text_box_name}_button,'dynamic');\">$text</textarea></td></tr></table>\n";
      $out .= "</td></tr>\n<tr><td align=center>\n";
      $out .= "<input type=button name='$args{submit_button_name}' value='$args{submit_button_label}' onClick='javascript:$args{submit_event_handler}'>\n";
      $out .= "</td></tr>\n";
   }
   return ($out);
}

###################################################################################################################################
sub errorMessage {                                                                                                                #
#                                                                                                                                 #
#  Constructs and returns a formatted error message including the application-specific and oracle error strings and instructions  #
#  for getting help.  This string is intended to be displayed by a javascript alert() call.  Also writes an error message to the  #
#  database activity_log table and to the web server error log.  The web server error log message consists of the date/time the   #
#  error occurred, the username, userid, and schema in effect, and the application-specific and oracle error strings.  Required   #
#  parameters are:                                                                                                                #
#                                                                                                                                 #
#     dbh         - database handle                                                                                               #
#     username    -                                                                                                               #
#     userid      -                                                                                                               #
#     schema      - database schema                                                                                               #
#     appError    - application-specific error string                                                                             #
#     oracleError - oracle error string - obtained from $@ after attempting to execute SQL statement(s) inside an eval{}          #
#                                                                                                                                 #
###################################################################################################################################
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
   print STDERR "\n $ENV{'BMSType'} BMS error: $mon/$mday/$year $hour:$min:$sec - $username/$userid/$schema - $appError failed:\n$oracleError\n";
   my $logError = $appError;
   $logError .= " - " . $oracleError if ($oracleError);
   &log_error($dbh, $schema, $userid, $logError);
   return ($errorMessage);
}

##################################################################################################################################
sub BuildPrintCommentResponse {
    my ($username, $userid, $schema, $path) = @_;
    my $outputstring = '';

    $outputstring = "<form name=printcommentresponseform action='$path" . "reports.pl' target=cgiresults method=post>\n";
    $outputstring .= "<input type=hidden name=userid value=$userid>\n";
    $outputstring .= "<input type=hidden name=username value=$username>\n";
    $outputstring .= "<input type=hidden name=schema value=$schema>\n";
    $outputstring .= "<input type=hidden name=command value=report>\n";
    $outputstring .= "<input type=hidden name=id value=PrintCommentResponse>\n";
    $outputstring .= "<input type=hidden name=documentid value=0>\n";
    $outputstring .= "<input type=hidden name=commentid value=0>\n";
    $outputstring .= "<input type=hidden name=version value=0>\n";

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "function submitPrintCommentResponse(documentID, commentID) {\n";
    $outputstring .= "    var version = ((arguments.length != 2) ? arguments[2] : 0);\n";
    $outputstring .= "    var old_target = document.printcommentresponseform.target;\n";
    $outputstring .= "    var myDate = new Date();\n";
    $outputstring .= "    var winName = myDate.getTime();\n";
    $outputstring .= "    document.printcommentresponseform.target = winName;\n";
    $outputstring .= "    document.printcommentresponseform.documentid.value = documentID;\n";
    $outputstring .= "    document.printcommentresponseform.commentid.value = commentID;\n";
    $outputstring .= "    document.printcommentresponseform.version.value = version;\n";
    $outputstring .= "    var newwin = window.open(\"\",winName);\n";
    $outputstring .= "    newwin.creator = self;\n";
    $outputstring .= "    document.printcommentresponseform.submit();\n";
    $outputstring .= "    document.printcommentresponseform.target = old_target;\n";
    $outputstring .= "}\n";
    $outputstring .= "//--></script>\n";

    $outputstring .= "</form>\n";

    return ($outputstring);
}


##################################################################################################################################
sub BuildPrintSummaryCommentResponse {
    my ($username, $userid, $schema, $path) = @_;
    my $outputstring = '';

    $outputstring = "<form name=printsummarycommentresponseform action='$path" . "reports.pl' target=cgiresults method=post>\n";
    $outputstring .= "<input type=hidden name=userid value=$userid>\n";
    $outputstring .= "<input type=hidden name=username value=$username>\n";
    $outputstring .= "<input type=hidden name=schema value=$schema>\n";
    $outputstring .= "<input type=hidden name=command value=report>\n";
    $outputstring .= "<input type=hidden name=id value=PrintSummaryCommentResponse>\n";
    $outputstring .= "<input type=hidden name=scrid value=0>\n";

    $outputstring .= "<script language=javascript><!--\n";
    $outputstring .= "function submitPrintSummaryCommentResponse(scrID) {\n";
    $outputstring .= "    var old_target = document.printsummarycommentresponseform.target;\n";
    $outputstring .= "    var myDate = new Date();\n";
    $outputstring .= "    var winName = myDate.getTime();\n";
    $outputstring .= "    document.printsummarycommentresponseform.target = winName;\n";
    $outputstring .= "    document.printsummarycommentresponseform.scrid.value = scrID;\n";
    $outputstring .= "    var newwin = window.open(\"\",winName);\n";
    $outputstring .= "    newwin.creator = self;\n";
    $outputstring .= "    document.printsummarycommentresponseform.submit();\n";
    $outputstring .= "    document.printsummarycommentresponseform.target = old_target;\n";
    $outputstring .= "}\n";
    $outputstring .= "//--></script>\n";

    $outputstring .= "</form>\n";

    return ($outputstring);
}


1; #return true
