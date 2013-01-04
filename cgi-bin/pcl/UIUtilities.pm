# # UI Utility functions for the SCM
#
# $Source: /data/dev/rcs/pcl/perl/RCS/UIUtilities.pm,v $
#
# $Revision: 1.10 $
#
# $Date: 2003/03/11 20:57:52 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: UIUtilities.pm,v $
# Revision 1.10  2003/03/11 20:57:52  starkeyj
# uncommented the 'add configuration item'
#
# Revision 1.9  2003/03/05 16:27:53  starkeyj
# chnaged 'scmcgi' to 'mycgi' and added session management; changed privilege
# requirement for document management
#
# Revision 1.8  2002/11/27 00:54:35  starkeyj
# removed 'use DBSCCB' - DBSCCB not ready for production
#
# Revision 1.7  2002/11/27 00:46:27  starkeyj
# modified buildProjectSelect function to filter Lotus Notes and non Lotus Notes
# projects, based on parameter passed in
#
# Revision 1.6  2002/11/13 19:03:03  atchleyb
# added submitFormCheckout function
#
# Revision 1.5  2002/11/11 21:10:33  mccartym
# add 'DisplaySCREntryScreen' to legacy_scr() call
#
# Revision 1.4  2002/11/08 20:30:34  atchleyb
# updated calling format for doesUserHavePriv
#  now requires priv 2 to update documents
#
# Revision 1.3  2002/11/08 17:03:19  starkeyj
# modified items listed under Project so there is a drop down that includes
# Lotus Notes projects and one that excludes Lotus Notes projects
#
# Revision 1.2  2002/11/05 18:17:20  starkeyj
# modified configuration item section to include a project drop down box
#
# Revision 1.1  2002/10/31 17:01:03  atchleyb
# Initial revision
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
use DBSCCB ('getSCCBList');
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
       schema => (defined($mycgi->param("schema"))) ? $mycgi->param("schema") : $ENV{'SCHEMA'},
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "browse",
       username => (defined($mycgi->param("username"))) ? $mycgi->param("username") : "",
       userid => (defined($mycgi->param("userid"))) ? $mycgi->param("userid") : "",
       server => (defined($mycgi->param("server"))) ? $mycgi->param("server") : "$SYSServer",
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
       type => (defined($mycgi->param("type"))) ? $mycgi->param("type") : "",
       projectID => (defined($mycgi->param("projectID"))) ? $mycgi->param("projectID") : "",
       logOption => (defined($mycgi->param("logOption"))) ? $mycgi->param("logOption") : "today",
       logactivity => (defined($mycgi->param("logactivity"))) ? $mycgi->param("logactivity") : "all",
       selecteduser => (defined($mycgi->param("selecteduser"))) ? $mycgi -> param ("selecteduser") : -1,
       sessionID => (defined($mycgi->param("sessionid"))) ? $mycgi->param("sessionid") : "0",
    );
    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        schema => $ENV{SCHEMA},
        title => 'PCL User Functions',
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
    function submitFormCheckout() {
        document.$form.command.value = 'checkout';
        document.$form.project.value = document.$form.nonLNproject.value;
        document.$form.action = '$path' + 'project_items' + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }


END_OF_BLOCK
    $output .= &doStandardHeader(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
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
sub doMenu {  # routine to generate utilities menu
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    # display utilities menu -----------------------------------------------------------------------------
    $output .= "<table width=100% align=center><tr><td>\n";
    $output .= "<table border=0 cellspacing=5 cellpadding=5 align=center>\n";
    $output .= "<tr>\n";
    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[10,2])) {
      $output .= "<td valign=top>\n<font size=3><b>System</b><br>\n";
        if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[2, 11])) {
            $output .= "<li><b>Documented Procedures</b>&nbsp;<a href=javascript:submitForm3('documents','add',10)>Add</a>&nbsp;\n";
            $output .= "<a href=javascript:submitForm3('documents','update',10)>Check Out (Update)</a>\n";
            if ($SYSProductionStatus == 0) {
                $output .= "<li><b>Documented Policies</b>&nbsp;<a href=javascript:submitForm3('documents','add',12)>Add</a>&nbsp;\n";
                $output .= "<a href=javascript:submitForm3('documents','update',12)>Check Out (Update)</a>\n";
            }
            $output .= "<li><b>Forms</b>&nbsp;<a href=javascript:submitForm3('documents','add',11)>Add</a>&nbsp;\n";
        }	
        $output .= "<a href=javascript:submitForm3('documents','update',11)>Check Out (Update)</a>\n";
        $output .= "<li><b>Training Records</b>&nbsp;<a href=javascript:submitForm('training','addtrainingrecord')>Add</a>&nbsp;\n";
        $output .= "</font></td>\n";
    }	
    $output .= "<td valign=top><font size=3><b>General Utilities</b>\n";
    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[10])) {
        $output .= "<li><b>Users:</b>&nbsp;&nbsp;<a href=javascript:submitForm('users','adduserform')>Add</a>&nbsp;&nbsp;<a href=javascript:submitForm('users','updateuserselect')>Update</a>\n";
    }
    $output .= "<li><a href=javascript:submitForm('users','changepasswordform')>Change&nbsp;Password</a>\n";
    if ($SYSUseSessions eq "T") {
        $output .= "<li><a href=javascript:submitForm('logout','')>Logout</a>\n";
    }
    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[10])) {
        $output .= "<li><b>View&nbsp;Logs:</b>&nbsp;&nbsp;<a href=javascript:submitForm('utilities','view_activity')>Activity</a>&nbsp;&nbsp;<a href=javascript:submitForm('utilities','view_errors')>Error</a>\n";
    }
    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[-1])) {
        $output .= "<li><a href=javascript:submitForm('users','becomeusernameform')>Become Another User</a>\n";
    }
    $output .= "</td></tr>\n<tr>\n";
    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[10])) {
        $output .= "<td valign=top>\n<font size=3><b>Project</b><br>\n";
        $output .= "<li><a href=javascript:submitForm('project','create_project')>Create</a>\n";
        $output .= "<li><a href=javascript:submitForm('project','update_project')>Update</a>&nbsp;\n" . &buildProjectSelect(dbh=>$args{dbh}, schema=>$args{schema},name=>'project1',userID=>$args{userID},userID=>$args{userID},notesfilter=>'F') . "\n";
        $output .= "<br><br>&nbsp;&nbsp;&nbsp;&nbsp;" . &buildProjectSelect(dbh=>$args{dbh}, schema=>$args{schema},name=>'nonLNproject',userID=>$args{userID},notesfilter=>'T');
        #$output .= "<li><b>Baseline</b>&nbsp;<a href=\"javascript:submitForm('baseline','create')\">Create</a>&nbsp;\n";
        $output .= "<li><b>Baseline</b>&nbsp;<a href=\"javascript:alert('Under Construction')\">Create</a>&nbsp;\n";
        $output .= "<a href=\"javascript:alert('Under Construction')\">Update</a>&nbsp;\n";
        $output .= "<a href=\"javascript:alert('Under Construction')\">Audit</a>\n";
        $output .= "<li><b>Software Product</b>&nbsp;<a href=\"javascript:alert('Under Construction')\">Create</a>&nbsp;\n";
        $output .= "<a href=\"javascript:alert('Under Construction')\">Release</a>\n";
        $output .= "<li><b>Configuration Item</b>\n";
        $output .= "<a href=javascript:submitForm('documents','add')>Add</a>\n";
       # $output .= "&nbsp;<a href=\"javascript:alert('Under Construction')\">Administrative Check-In</a>&nbsp;\n";
        $output .= "&nbsp;<a href=javascript:submitForm3('documents','updateselect',0)>Check Out (Update)</a>\n";
     #   $output .= "&nbsp;<a href=javascript:submitFormCheckout()>Check Out (Update)</a>\n";
        $output .= "</font></td>\n";		  
    }
  
    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[10])) {
        $output .= "<td valign=top>\n<font size=3><b>Software Change Requests</b><br>\n";
        $output .= "<li><a href=javascript:submitForm('legacy_scr','displaySCREntryScreen')>Enter Legacy SCR</a>\n";
        $output .= "<li><a href=\"javascript:alert('Under Construction')\">Update</a><br><br>\n";  
			
    }
   # if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[10])) {
	#	  $output .= "<font size=3><b>SCCB</b><br>\n";
	#	  $output .= "<li><a href=javascript:submitForm('sccb','create')>Create</a>\n";
	#	  $output .= "<br><br>&nbsp;&nbsp;&nbsp;&nbsp;" . &buildSCCBSelect(dbh=>$args{dbh}, schema=>$args{schema},name=>'sccbselect');
	#	  $output .= "<li><a href=\"javascript:submitForm('sccb','update')\">Update</a>\n";  
	#	  $output .= "<li><a href=javascript:submitForm('meetings','createmeeting')>Create Meeting</a>\n";
	#	  $output .= "<li><a href=javascript:submitForm('meetings','updateselectmeeting')>Update Meeting</a>\n";
	#	  $output .= "</font></td>\n";
   # }
    $output .= "</tr>\n</table>\n";
    if ($SYSProductionStatus == 0) { # temporary links for development
        $output .= "<br><a href=javascript:submitForm('products','browse',0)>Browse Products (temporarily here)</a>\n";
        #$output .= "<br><a href=javascript:submitForm('utilities_new','')>New Utilities (temporarily here)</a>\n";
        #$output .= "<br><b>View&nbsp;Logs:</b>&nbsp;&nbsp;<a href=javascript:submitForm('utilities_new','view_activity')>Activity</a>&nbsp;&nbsp;<a href=javascript:submitForm('utilities_new','view_errors')>Error</a>\n";
        #$output .= "<br><b>Temp Users:</b>&nbsp;&nbsp;<a href=javascript:submitForm('users','adduserform')>Add</a>&nbsp;&nbsp;<a href=javascript:submitForm('users','updateuserselect')>Update</a>\n";
        $output .= "<br><a href=javascript:submitForm('sccb','browse')>Browse SCCB (temporarily here)</a>\n";
        #$output .= "<br><a href=javascript:submitForm('sccb','create')>Create SCCB (temporarily here)</a>\n";
        #$output .= "<br><a href=javascript:submitForm('sccb','update')>Update SCCB (temporarily here)</a>\n";
        $output .= "<br><a href=javascript:submitForm3('documents','browse',12)>Browse Policies (temporarily here)</a>\n";
    }
    $output .= "</td></tr></table>\n";

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
        "all" => {'index' => 0, 'title' => "All Activities"}
           );

    tie my %logerr, "Tie::IxHash";
    %logerr = (
        "all" => {'index' => 0, 'title' => "All Errors"}
          );

    my %userhash;
    my $key;
    %userhash = get_lookup_values($args{dbh}, $args{schema}, 'users', "lastname || ', ' || firstname || ';' || id", 'id', "id > 0");

    my @items = &getActivityLog(dbh => $args{dbh}, schema => $args{schema}, options => \%options, settings => \%settings);
    
    my $selectedusername = ($settings{selecteduser} == -1) ? "all users" : getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$settings{selecteduser});

    my $rows = 0;
    my $outString = '';
    my $logtype = ($settings{command} eq 'view_errors') ? 'Error' : 'Activity';
    my $selectedactivity = ($settings{command} eq 'view_activity') ? ${$logacts{$settings{logactivity}}}{'title'} : ${$logerr{$settings{logactivity}}}{'title'};
    my $title = "$logtype Log - ${$options{$settings{logOption}}}{'title'} for $selectedusername - $selectedactivity (xxx Entries)&nbsp;&nbsp; (<i><font size=2>Most&nbsp;recent&nbsp;at&nbsp;top</font></i>)";
    $outString .= &startTable(columns => 3, title => $title);
    $outString .= &startRow(bgcolor => "#f0f0f0");
    $outString .= &addCol(value => "Date/Time", width => 130, isBold => 1);
    $outString .= &addCol(value => "User", width => 140, isBold => 1);
    $logtype = "Activity/<font color=#cc0000>Error</font>" if ($logtype eq 'Activity');
    $outString .= &addCol(value => "$logtype Text", width => 480, isBold => 1);
    $outString .= &endRow . &addSpacerRow;
    for (my $i=0; $i<$#items; $i++) {
        my ($user, $date, $text, $err) = ($items[$i]{user}, $items[$i]{date}, $items[$i]{text}, $items[$i]{err});
        if ($settings{logactivity} eq "all" || matchFound (text => $text, searchString => $settings{logactivity})) {
          if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[-1]) || !(matchFound (text=>$text, searchString => 'search'))) {
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
           my $usernamestring = $key;
           $usernamestring =~ s/;$userhash{$key}//g;
           if ($userhash{$key} == $settings{selecteduser}){
               $output .= "<option value=\"$userhash{$key}\" selected>$usernamestring\n";
           }
           else {
               $output .= "<option value=\"$userhash{$key}\">$usernamestring\n";
           }
       }
       $output .= "</select></td>\n";
       if ($settings{command} eq 'view_activity') {
           $output .= "<td><select name=logactivity>";
           foreach my $acts (keys (%logacts)) {
             if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[-1]) || $acts ne 'search') {
               my $selected = ($settings{logactivity} eq $acts) ? " selected" : "";
               $output .= "<option value=\"$acts\"$selected>${$logacts{$acts}}{'title'}\n";
             }
           }
           $output .= "</select></td>";
       }
       else {
           $output .= "<td><select name=logactivity>";
           foreach my $acts (keys (%logerr)) {
               my $selected = ($settings{logactivity} eq $acts) ? " selected" : "";
               $output .= "<option value=\"$acts\"$selected>${$logerr{$acts}}{'title'}\n";
           }
           $output .= "</select></td>";
       }
       $output .= "<td align=center><input type=button name=displaylog value=Display onClick=\"document.$args{form}.command.value='$settings{command}';document.$args{form}.submit();\"></td></tr></table><br>";
       $output .= $outString;
       $output .= "<script language=javascript><!--\ndocument.$args{form}.logOption.selectedIndex = ${$options{$settings{logOption}}}{'index'};\n//--></script>\n";

    return($output);
}

###################################################################################################################################
sub buildProjectSelect {
###################################################################################################################################
	 my %args = (
    	 schema => $SCHEMA,
  	 	 userID => 0,
  		 name => 'project1',
  		 @_,
	 );
	 my $dbh = $args{dbh};
	 my $userid = $args{userID};
	 my $notes;
	 tie my %projectlist, "Tie::IxHash";

	 %projectlist = &getProjects(dbh => $dbh);
	 my $outstring = "";
	 $outstring .= "<select name=$args{name} size=1>\n";
	 foreach my $project (keys (%projectlist)) {
	 	 $notes = ($args{notesfilter} eq 'F' || $projectlist{$project}{isNotes} eq 'F') ? 1 : 0;
	    if (($projectlist{$project}{configurationManagerID} == $userid || $projectlist{$project}{projectManagerID} == $userid || 
			&doesUserHavePriv(dbh => $dbh, schema => $args{schema}, userid => $userid, privList => [11]) == 1) && $notes) 
				 {$outstring .= "<option value=$project>$projectlist{$project}{name}\n";}
	 }
	 $outstring .= <<END_OF_TEXT;
	 </select>
END_OF_TEXT
	 return($outstring);
}

###################################################################################################################################
sub buildSCCBSelect {
###################################################################################################################################
	 my %args = (
    	 schema => $SCHEMA,
  	 	 userID => 0,
  		 name => 'sccbselect',
  		 @_,
	 );
	 my $dbh = $args{dbh};
	 my ($sccbid,$name);
	 my @sccblist = &getSCCBList(dbh => $dbh, schema=>$args{schema});
	 my $outstring = "";
	 $outstring .= "<select name=$args{name} size=1>\n";
	 for (my $i = 0; $i < $#sccblist; $i++) {
	   ($sccbid,$name) = ($sccblist[$i]{sccbid},$sccblist[$i]{name});
	 	$outstring .= "<option value=$sccbid>$name\n";
	 }
	 $outstring .= <<END_OF_TEXT;
	 </select>
END_OF_TEXT
	 return($outstring);
}

###################################################################################################################################
###################################################################################################################################



1; #return true
