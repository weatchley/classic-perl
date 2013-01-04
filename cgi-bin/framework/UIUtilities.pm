# UI Utility functions
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
#
#

package UIUtilities;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBUtilities qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Text_Menus;
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
      &getInitialValues       &doHeader             &doFooter
      &getTitle               &doMenu               &doViewLogs
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doFooter
      &getTitle               &doMenu               &doViewLogs
    )]
);

my $mycgi = new CGI;


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "Utilities";
   if ($args{command} eq "view_errors") {
      $title = "Error Log";
   } elsif ($args{command} eq "view_activity") {
      $title = "Activity Log";
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
       type => (defined($mycgi->param("type"))) ? $mycgi->param("type") : "",
       projectID => (defined($mycgi->param("projectID"))) ? $mycgi->param("projectID") : "",
       logOption => (defined($mycgi->param("logOption"))) ? $mycgi->param("logOption") : "today",
       logactivity => (defined($mycgi->param("logactivity"))) ? $mycgi->param("logactivity") : "all",
       selecteduser => (defined($mycgi->param("selecteduser"))) ? $mycgi -> param ("selecteduser") : -1,
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
    function doBrowse(script) {
      	$form.command.value = 'browse';
       	$form.action = '$path' + script + '.pl';
        $form.submit();
    }
    function submitForm3(script, command, type) {
        document.$form.command.value = command;
        document.$form.type.value = type;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }


END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'F', includeJSWidgets => 'F');
    
    $output .= "<input type=hidden name=type value=0>\n";
    $output .= "<input type=hidden name=project value=0>\n";
    $output .= "<input type=hidden name=projectID value=0>\n";
    #$output .= "<input type=hidden name=server value=$Server>\n";
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
    
    $output .= &doStandardFooter();

    return($output);
}


###################################################################################################################################
sub doMenu1 {  # routine to generate utilities menu
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    # display utilities menu -----------------------------------------------------------------------------
    $output .= "<table width=100% align=center><tr><td>\n";
    $output .= "<table border=0 cellspacing=5 cellpadding=5 align=center>\n";
    $output .= "<tr>\n";
    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[10])) {
      $output .= "<td valign=top>\n<font size=3><b>System</b><br>\n";
        my ($sccb) = $args{dbh} -> selectrow_array ("select sccbid from $args{schema}.sccbuser where userid=$args{userID}");
        $output .= "<li><b>Change Request:</b><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
        if ($sccb) {
            $output .= "<a href=javascript:submitForm('changeRequests','write_request')>Submit</a>\n";
        }
        $output .= "<a href=javascript:submitForm('changeRequests','')>Browse</a>\n";
        $output .= "</font></td>\n";
    }	
    $output .= "<td valign=top><font size=3><b>General Utilities</b>\n";
    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[10])) {
        $output .= "<li><b>Users:</b>&nbsp;&nbsp;<a href=javascript:submitForm('users','adduserform')>Add</a>&nbsp;&nbsp;<a href=javascript:submitForm('users','updateuserselect')>Update</a>\n";
    }
    $output .= "<li><a href=javascript:submitForm('users','changepasswordform')>Change&nbsp;Password</a>\n";
    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[10])) {
        $output .= "<li><b>View&nbsp;Logs:</b>&nbsp;&nbsp;<a href=javascript:submitForm('utilities','view_activity')>Activity</a>&nbsp;&nbsp;<a href=javascript:submitForm('utilities','view_errors')>Error</a>\n";
    }
    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[-1])) {
        $output .= "<li><a href=javascript:submitForm('users','becomeusernameform')>Become Another User</a>\n";
    }
    if ($SYSUseSessions eq 'T') {
        $output .= "<li><a href=javascript:submitFormCGIResults('logout','logout')>Logout</a>\n";
    }
    $output .= "</td></tr>\n<tr>\n";
  
    $output .= "</tr>\n</table>\n";
    if ($SYSProductionStatus == 0) { # temporary links for development
        #$output .= "<br><a href=javascript:submitForm('products','browse',0)>Browse Products (temporarily here)</a>\n";
    }
    $output .= "</td></tr></table>\n";

    return($output);
}


###################################################################################################################################
sub doMenu {  # routine to generate utilities menu
###################################################################################################################################
    my %args = (
        @_,
    );
    my $menu1 = new Text_Menus;
    my $output = "";
    
    # display utilities menu -----------------------------------------------------------------------------

    $output .= "<center>\n";

# General menu
    my $genMenu = new Text_Menus;
    $genMenu->addMenu(name => 'changepassword', label => 'Change Password', contents => "javascript:submitForm('users','changepasswordform');");
    if ($SYSUseSessions eq 'T') {
        $genMenu->addMenu(name => 'logout', label => 'Logout', contents => "javascript:submitFormCGIResults('logout','logout');");
    }

# User menu
    my $userMenu = new Text_Menus;
    $userMenu->addMenu(name => 'adduser', label => 'Add User', contents => "javascript:submitForm('users','adduserform');");
    $userMenu->addMenu(name => 'updateuser', label => 'Update User', contents => "javascript:submitForm('users','updateuserselect');");
    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[-1])) {
        $userMenu->addMenu(name => 'becomeuser', label => 'Become Another User', contents => "javascript:submitForm('users','becomeusernameform');");
    }

# Logs menu
    my $logMenu = new Text_Menus;
    $logMenu->addMenu(name => 'viewactivities', label => 'View Activity Log', contents => "javascript:submitForm('utilities','view_activity');");
    $logMenu->addMenu(name => 'viewerrors', label => 'View Error Log', contents => "javascript:submitForm('utilities','view_errors');");

# cr menu
    my $crMenu = new Text_Menus;
    $crMenu->addMenu(name => 'browse', label => 'Browse', contents => "javascript:submitForm('changeRequests','');");
    my ($sccb) = $args{dbh} -> selectrow_array ("select sccbid from $args{schema}.sccbuser where userid=$args{userID}");
    if ($sccb) {
        $crMenu->addMenu(name => 'test2', label => 'Submit', contents => "javascript:submitForm('changeRequests','write_request');");
    }

# test menu
    my $testMenu = new Text_Menus;
    $testMenu->addMenu(name => 'test1', label => 'Test 1', contents => "Test 1");
    $testMenu->addMenu(name => 'test2', label => 'Test 2', contents => "Test 2");

# Top menu
    my $subMenuType = 'bullets';
    #$subMenuType = 'tree';

    $menu1->addMenu(name => "gen", label => "General", status => 'open', contents => $genMenu->buildMenus(name => 'gen', type => $subMenuType), title => 'General Utilities');
    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[10])) {
        $menu1->addMenu(name => "user", label => "User", contents => $userMenu->buildMenus(name => 'user', type => $subMenuType), title => 'User Utilities');
        $menu1->addMenu(name => "logs", label => "Logs", contents => $logMenu->buildMenus(name => 'logs', type => $subMenuType), title => 'Log Utilities');
        $menu1->addMenu(name => "cr", label => "Change Requests", contents => $crMenu->buildMenus(name => 'cr', type => $subMenuType), title => 'Change Requests');
    }
    if ($SYSProductionStatus == 0) { # temporary links for development
        $menu1->addMenu(name => "test", label => "Test", contents => $testMenu->buildMenus(name => 'test', type => $subMenuType), title => 'Test Utilities');
    }

    my $menutype = ((defined($mycgi->param('menutype'))) ? $mycgi->param('menutype') : "tabs");
    #$menutype="tree";
    $menutype="table";
    $menu1->imageSource("$SYSImagePath/");
    $output .= $menu1->buildMenus(name => 'UtilitiesMenu1', type => $menutype, linkStyle=>"'overline underline'");

    $output .= "</center>\n";

    return($output);
}


###################################################################################################################################
sub doViewLogs {  # routine to display error and activity logs
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my @months = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
    my $dd = sprintf("%02d", $mday);
    $year += 1900;
    my $today = uc("$dd-$months[$mon]-$year");

    # get the first day of last month
    my $lastmonth = ($mon == 0) ? 12 : $mon;
    my $mm = sprintf("%02d", $lastmonth);
    my $yr = ($mon == 0) ? $year - 1 : $year;
    my $startLastMonth = "01-$mm-$yr";

    tie my %options, "Tie::IxHash";
    %options = (
       "today"     => { 'index' => 0, 'title' => "Today",             'where' => "to_date(datelogged) = to_date('$today')" },
       "yesterday" => { 'index' => 1, 'title' => "Yesterday",         'where' => "to_date(datelogged) = to_date('$today') - 1" },
       "thisweek"  => { 'index' => 2, 'title' => "This Week",         'where' => "to_date(datelogged) between to_date('$today') - ($wday - 1) and to_date('$today')" },
       "lastweek"  => { 'index' => 3, 'title' => "Last Week",         'where' => "to_date(datelogged) between to_date('$today') - ($wday + 6) and to_date('$today') - $wday" },
       "thismonth" => { 'index' => 4, 'title' => "This Month",        'where' => "to_date(datelogged) between to_date('$today') - ($mday - 1) and to_date('$today')" },
       "lastmonth" => { 'index' => 5, 'title' => "Last Month",        'where' => "to_date(datelogged) between to_date('$startLastMonth', 'DD-MM-YYYY') and to_date('$today') - $mday" },
       "pastweek"  => { 'index' => 6, 'title' => "Past 7 Days",       'where' => "to_date(datelogged) between to_date('$today') - 6 and to_date('$today')" },
       "pastmonth" => { 'index' => 7, 'title' => "Past 30 Days",      'where' => "to_date(datelogged) between to_date('$today') - 29 and to_date('$today')" },
       "last10"   => { 'index' => 8, 'title' => "Last 10 Entries",  'where' => "1 = 1" },
       "last100"   => { 'index' => 9, 'title' => "Last 100 Entries",  'where' => "1 = 1" },
       "last1000"  => { 'index' => 10, 'title' => "Last 1000 Entries", 'where' => "1 = 1" }
    );

    tie my %logacts, "Tie::IxHash";
    %logacts = (
        0 => "All Activities"
           );
    tie my %logActivities, "Tie::IxHash";
    %logActivities = (
        0 => "All Activities",
        (%{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'activity_type', idColumn => 'id', nameColumn => 'description', orderBy => 'description')})
    );

    tie my %logerr, "Tie::IxHash";
    %logerr = (
        "0" => {'index' => 0, 'title' => "All Errors"}
          );
    tie my %logErrors, "Tie::IxHash";
    %logErrors = (
        0 => "All Errors",
        %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'activity_type', idColumn => 'id', nameColumn => 'description', orderBy => 'description', where => "ISERROR = 'T'")}
    );

    tie my %userhash, "Tie::IxHash";
    my $key;
    %userhash = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'users', 
                  nameColumn => "lastname || ', ' || firstname", idColumn => 'id', orderBy => 'username', where => "id > 0")};

    my @items = &getActivityLog(dbh => $args{dbh}, schema => $args{schema}, options => \%options, settings => \%settings);
    
    my $selectedusername = ($settings{selecteduser} == -1) ? "all users" : getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$settings{selecteduser});

    my $rows = 0;
    my $outString = '';
    my $logtype = ($settings{command} eq 'view_errors') ? 'Error' : 'Activity';
    my $selectedactivity = $logActivities{$settings{logactivity}};
    my $title = "$logtype Log - ${$options{$settings{logOption}}}{'title'} for $selectedusername - $selectedactivity (xxx Entries)&nbsp;&nbsp; (<i><font size=2>Most&nbsp;recent&nbsp;at&nbsp;top</font></i>)";
    $outString .= &startTable(columns => 3, title => $title);
    $outString .= &startRow(bgColor => "#f0f0f0");
    $outString .= &addCol(value => "Date/Time", width => 130, isBold => 1);
    $outString .= &addCol(value => "User", width => 140, isBold => 1);
    $logtype = "Activity/<font color=#cc0000>Error</font>" if ($logtype eq 'Activity');
    $outString .= &addCol(value => "$logtype Text", width => 480, isBold => 1);
    $outString .= &endRow . &addSpacerRow;
    for (my $i=0; $i<$#items; $i++) {
        my ($user, $date, $text, $err, $type) = ($items[$i]{user}, $items[$i]{date}, $items[$i]{text}, $items[$i]{err}, $items[$i]{type});
          if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[-1]) || $type != 6) { # only developers can see search logs
            $rows++;
            $outString .= &startRow;
            $outString .= &addCol(value => $date, isBold => 1);
            $outString .= ($user == 0) ? &addCol(value => '<b>None</b>') : &addCol(url => "javascript:displayUser($user)", value => &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$user), isBold => 1);
            if ($err eq 'T' && $settings{command} eq 'view_activity') {
                $outString .= &addCol(value => "<font color=#cc0000>$text</font>", isBold => 1);
            }
            else {
                $outString .= &addCol(value => $text, isBold => 1);
            }
            last if ((($rows >= 10) and ($settings{logOption} eq "last10")) ||(($rows >= 100) and ($settings{logOption} eq "last100")) || (($rows >= 1000) and ($settings{logOption} eq "last1000")));
          }
   }
   $outString .= &endTable;
   if ((($rows >= 10) and ($settings{logOption} eq "last10")) ||(($rows >= 100) and ($settings{logOption} eq "last100")) || (($rows >= 1000) and ($settings{logOption} eq "last1000")) || (($rows >= 10) and ($settings{logOption} eq "last10"))) {
       $outString =~ s/ \(xxx Entries\)//;
   } else {
       $outString =~ s/xxx/$rows/;
   }


       $output .= "<table width=700 cellpadding=0 calspacing=0 align=center>\n";
       $output .= "<tr><td><b>View: </b></td><td><b>User: </b></td>\n";
       my $whichone = ($settings{command} eq 'view_activity') ? "Activity:" : "Error:";
       $output .= "<td><b>$whichone</b></td>\n";
       $output .= "<td>&nbsp;</td></tr>";
       $output .= "<tr><td><select name=logOption size=1>\n";
       foreach my $option (keys (%options)) {
           $output .= "<option value=\"$option\">${$options{$option}}{'title'}\n";
       }
       $output .= "</select></td>\n";
       $output .= "<td><select name=selecteduser>\n";
       $output .= "<option value=-1 selected>All Users\n";
       foreach $key (sort keys %userhash) {
           if ($key == $settings{selecteduser}){
               $output .= "<option value=\"$key\" selected>$userhash{$key}\n";
           }
           else {
               $output .= "<option value=\"$key\">$userhash{$key}\n";
           }
       }
       $output .= "</select></td>\n";
       if ($settings{command} eq 'view_activity') {
           $output .= "<td><select name=logactivity>";
           foreach my $acts (keys (%logActivities)) {
             if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[-1]) || $acts != 6) { # only show search to developers
               my $selected = ($settings{logactivity} eq $acts) ? " selected" : "";
               $output .= "<option value=\"$acts\"$selected>$logActivities{$acts}\n";
             }
           }
           $output .= "</select></td>";
       }
       else {
           $output .= "<td><select name=logactivity>";
           foreach my $acts (keys (%logErrors)) {
               my $selected = ($settings{logactivity} eq $acts) ? " selected" : "";
               $output .= "<option value=\"$acts\"$selected>$logErrors{$acts}\n";
           }
           $output .= "</select></td>";
       }
       $output .= "<td align=center><input type=button name=displaylog value=Display onClick=\"document.$args{form}.command.value='$settings{command}';document.$args{form}.submit();\"></td></tr></table><br>";
       $output .= $outString;
       $output .= "<script language=javascript><!--\ndocument.$args{form}.logOption.selectedIndex = ${$options{$settings{logOption}}}{'index'};\n//--></script>\n";

    

    return($output);
}



1; #return true
