# Library of UI widget routines for cgi scripts 

#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/UI_Widgets.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2008/10/21 18:07:02 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UI_Widgets.pm,v $
# Revision 1.2  2008/10/21 18:07:02  atchleyb
# ACR0810_002 - Added non production warning and changed tile to text from image
#
# Revision 1.1  2003/11/12 20:36:07  atchleyb
# Initial revision
#
#
#
#
#
package UI_Widgets;
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
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
   &build_dual_select     &build_select_from_piclist   &build_drop_box 
   &build_date_selection  &build_radio_block_wide      &gen_table 
   &nbspaces              &lpadzero                    &getDisplayString
   &formatID              &errorMessage                &writeTitleBar 
   &doAlertBox            &buildSectionBlock
);
@EXPORT_OK = qw(
   &build_dual_select     &build_select_from_piclist   &build_drop_box 
   &build_date_selection  &build_radio_block_wide      &gen_table 
   &nbspaces              &lpadzero                    &getDisplayString
   &formatID              &errorMessage                &writeTitleBar 
   &doAlertBox            &buildSectionBlock
);
%EXPORT_TAGS =( Functions => [qw(
   &build_dual_select     &build_select_from_piclist   &build_drop_box 
   &build_date_selection  &build_radio_block_wide      &gen_table 
   &nbspaces              &lpadzero                    &getDisplayString
   &formatID              &errorMessage                &writeTitleBar 
   &doAlertBox            &buildSectionBlock
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

# 'nbspaces'
# (output string) = &nbspaces( (number of non-breaking spaces) );
# 'lpadzero'
# (output string) = &lpadzero( (input string), (length of result string) );
# 'getDisplayString'
# (output string) = &getDisplayString( (input string), (max length of output string) );
# 'writeTitleBar'
# (output string) = &writeTitleBar( (username), (userid), (dbh), (schema), (title) );
# 'formatID'
# (output string) = &formatID( (prepend string), (numeric length), (number) );
# 'doRemarks'
# (output string) = &doRemarks( (arg hash - see function header documentation) );
# 'errorMessage'
# (output string) = &errorMessage( (username), (userid), (schema), (application error), (oracle error) );
# 'doAlertBox'
# (output string) = &doAlertBox( text => (text for alert) [, includeScriptTags => (T or F) ] );

# 'buildSectionBlock'
# (output string) = &buildSectionBlock( contents => (contents of section), title => (title of section) [, button => (button style), style => (section style), isOpen => (T or F) ] );
#

####################################################################################################################################
sub build_dual_select {
# routine to build a dual selection box from hashes passed to it
####################################################################################################################################
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

####################################################################################################################################
sub build_select_from_piclist {
# routine to build a combination text box and piclist from data passed to it.
####################################################################################################################################
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

####################################################################################################################################
sub build_drop_box {
# routine to build a dropdown box from a passed hash
####################################################################################################################################
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

####################################################################################################################################
sub build_date_selection {
# routine to build a date selection widget
####################################################################################################################################
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

####################################################################################################################################
sub build_radio_block_wide {
# routine to build a set of radio buttons
####################################################################################################################################
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

####################################################################################################################################
sub gen_table {
# routine to generate a standard two column table with a title cell
####################################################################################################################################
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
   my $mycgi = new CGI;
   my $command = (defined($mycgi->param("command"))) ? $mycgi->param("command") : "No command";
   $ENV{SCRIPT_NAME} =~ m%.*/(.*)%;
   print STDERR "***** $ENV{'SYSType'} $1 $mon/$mday/$year $hour:$min:$sec $args{userName}/$args{userID}/$args{schema} $ENV{REMOTE_ADDR} $command\n";

   $args{schema} = uc($args{schema}) unless ($args{schema} eq "None");
   $ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
   my $path = $1;
   my $form = $2;
   #my $output = "<script language=javascript><!--\nparent.frames[0].titleimage.src= '" . $path . "text_labels.pl?width=390&size=15&parsetitle=T&text=$args{title}';\n//-->\n</script>\n";
   #my $output = "<script language=javascript><!--\nparent.frames[1].titleimage.src= '" . $path . "text_labels.pl?width=390&size=15&parsetitle=T&text=$args{title}';\n//-->\n</script>\n";
   my $output = "<script language=javascript><!--\nparent.frames[1].titletext.innerHTML= '$args{title}';\n//-->\n</script>\n";
   my $userid = ($args{userID}) ? $args{userID} : 0;
   if ($SYSDebug && &doesUserHavePriv (userid => $userid, dbh => $args{dbh}, schema => $args{schema}, privList => [-1])) {
      my $menu1 = new Text_Menus;
      my $output2 = "<table width=750 border=1>";
      my @list = $mycgi->param();
      foreach my $item (@list) {
          my $val = $mycgi->param($item);
        $output2 .= "<tr><td><b>$item</b></td><td><b>$val</b></td></tr>";
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
   print STDERR "\n $ENV{'SYSType'} error: $mon/$mday/$year $hour:$min:$sec - $username/$userid/$schema - $appError failed:\n$oracleError\n";
   my $logError = $appError;
   $logError .= " - " . $oracleError if ($oracleError);
   &logError(dbh => $dbh, schema => $schema, userID => $userid, logMessage => $logError);
   return ($errorMessage);
}



###################################################################################################################################
sub doAlertBox {
###################################################################################################################################
   my %args = (
      text => "",
      includeScriptTags => 'T',
      @_,
   );
   
   my $outputstring = '';
   $args{text} =~ s/\n/\\n/g;
   $args{text} =~ s/'/%27/g;
   if ($args{includeScriptTags} eq 'T') {$outputstring .= "<script language=javascript>\n<!--\n";}
   $outputstring .= "var mytext ='$args{text}';\nalert(unescape(mytext));\n";
   if ($args{includeScriptTags} eq 'T') {$outputstring .= "//-->\n</script>\n";}
   
   return ($outputstring);
   
}


###################################################################################################################################
my $SectionNumber = 1;
sub buildSectionBlock {
###################################################################################################################################
   my %args = (
       label => "Block" . $SectionNumber++,
       title => "",
       contents => '',,
       style => "noborder",
       button => "arrow",
       isOpen => "F",
       @_,
   );
   
   my %buttonType = (
       arrow => ["$SYSImagePath/arrow_close.gif","$SYSImagePath/arrow_open.gif"],
       plusminus => ["$SYSImagePath/expand_button.gif","$SYSImagePath/collapse_button.gif"]
   );
   my %styleType = (
       border => [1],
       noborder => [0]
   );
   my $outputstring = '';
   
   $outputstring .= "<script language=\"JavaScript\" type=\"text/javascript\">\n";
   $outputstring .= "<!--\n";
   $outputstring .= "function showHide" . $args{label} . "Section() {\n";
   $outputstring .= "  if (" . $args{label} . "Section.style.display=='none') {\n";
   $outputstring .= "      " . $args{label} . "Section.style.display='';\n\n";
   $outputstring .= "      document." . $args{label} . "Image.src ='" . $buttonType{$args{button}}[1] . "';\n";
   $outputstring .= "  } else {\n";
   $outputstring .= "      " . $args{label} . "Section.style.display='none';\n\n";
   $outputstring .= "      document." . $args{label} . "Image.src ='" . $buttonType{$args{button}}[0] . "';\n";
   $outputstring .= "  }\n";
   $outputstring .= "}\n";
   $outputstring .= "//-->\n";
   $outputstring .= "</script>\n";
   $outputstring .= "<table border=$styleType{$args{style}}[0] width=100%><tr>\n";
   $outputstring .= "<td valign=top width=1><a href=\"javascript:showHide" . $args{label} . "Section();\">";
   $outputstring .= "<img id=\"" . $args{label} . "Image\" name=\"" . $args{label} . "Image\" src=" . (($args{isOpen} eq "T") ? $buttonType{$args{button}}[1] : $buttonType{$args{button}}[0]) . " border=0></a></td>\n";
   $outputstring .= "<td valign=top align=left>$args{title}</td>\n";
   $outputstring .= "</tr></table>\n";
   $outputstring .= "<div id=\"" . $args{label} . "Section\" style=\"display:" . (($args{isOpen} eq "T") ? "''" : "'none'") . "\">\n";
   $outputstring .= "<table border=0><tr><td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td>\n";
   $outputstring .= "$args{contents}\n";
   $outputstring .= "</td></tr></table>\n";
   $outputstring .= "</div>\n";


   
   return ($outputstring);
   
}


1; #return true
