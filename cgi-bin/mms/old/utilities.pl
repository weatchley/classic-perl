#!/usr/local/bin/perl -w

# Utilities page for the MMS
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

$| = 1;

use strict;
use integer;
use MMS_Header qw(:Constants);
use CGI;
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);

my $mmscgi = new CGI;
my $username = $mmscgi->param("username");
my $userid = $mmscgi->param("userid");
my $sessionID = $mmscgi->param("sessionid");
my $schema = $mmscgi->param("schema");
&checkLogin($username,$userid,$schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $dbh;
my $command = defined($mmscgi->param("command")) ? $mmscgi->param("command") : "";
my $message = '';
my $instructionsColor = $MMSFontColor;
my $title = "Utilities";
if ($command eq "view_errors") {
   $title = "Error Log";
} elsif ($command eq "view_activity") {
   $title = "Activity Log";
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
sub getReportDateTime {
###################################################################################################################################
    my @timedata = localtime(time);
    return(uc(get_date()) . " " . lpadzero($timedata[2],2) . ":" . lpadzero($timedata[1],2) . ":" . lpadzero($timedata[0],2));
}



$dbh = db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;

#! test for invalid or timed out session
&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $sessionID);

print $mmscgi->header('text/html');
print <<end;
<html>
<head>
   <meta http-equiv=expires content=now>
   <script src=$MMSJavaScriptPath/utilities.js></script>
   <script src=$MMSJavaScriptPath/widgets.js></script>
   <script language=javascript><!--
      function submitForm(script, command) {
         document.$form.command.value = command;
         document.$form.action = '$path' + script + '.pl';
         document.$form.submit();
      }

        function submitFormMain(script, command) {
        document.$form.target = 'main';
        document.$form.command.value = command;
        document.$form.action = '$path' + script + '.pl';
        document.$form.submit();
      }

      function submitForm2(script, command, id) {
          document.$form.command.value = command;
          document.$form.id.value = id;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'main';
          document.$form.submit();
      }

     function submitFormNewWindow(script, command) {
          var myDate = new Date();
          var winName = myDate.getTime();
          document.$form.command.value = command;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = winName;
          var newwin = window.open("",winName);
          newwin.creator = self;
          document.$form.submit();
          //newwin.focus();
      }

      function submitFormCGIResults(script, command) {
          document.$form.command.value = command;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'cgiresults';
          document.$form.submit();
      }


      function display_user(id) {
         document.$form.id.value = id;
         submitForm('user_functions', 'displayuser');
      }
//-->
</script>
end
print "\n</head>\n";
print "<body background=$MMSImagePath/background.gif text=$MMSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
if ($command ne 'print_duplicate_comments_report') {
    print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $title);
}
print "<font face=$MMSFontFace color=$MMSFontColor>\n";
print "<br>\n";
if ($command ne 'print_duplicate_comments_report') {
    print "<table border=0 width=750><tr><td>\n";
} else {
    print "<table border=0 width=650><tr><td>\n";
}
print "<form name=$form method=post onSubmit=false>\n";
print "<input type=hidden name=command value=$command>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=sessionid value=$sessionID>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=id value=0>\n";
print "<center>\n";

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


if ($command eq 'view_errors' || $command eq 'view_activity') {
    # generate activity and error log reports ---------------------------------------------------------------------------------------------
    my %userhash;
    my $key;
    eval {
        %userhash = get_lookup_values($dbh, $schema, 'users', "lastname || ', ' || firstname || ';' || id", 'id', "id > 0");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get available users.",$@);
        print doAlertBox( text => $message);
    }
    my $logOption = (defined($mmscgi->param("logOption"))) ? $mmscgi->param("logOption") : "today";
    my $logactivity = (defined($mmscgi->param("logactivity"))) ? $mmscgi->param("logactivity") : "all";
    my $selecteduser = (defined($mmscgi->param("selecteduser"))) ? $mmscgi -> param ("selecteduser") : -1;
    my $selectedusername = ($selecteduser == -1) ? "all users" : get_fullname($dbh, $schema, $selecteduser);
    my $userwhere = ($selecteduser == -1) ? "" : "userid = $selecteduser and";
    my $iserror = (($command eq 'view_errors') ? "iserror = 'T' and" : "");
    my $where = "$userwhere $iserror ${$options{$logOption}}{'where'}";
    my $sqlquery = "SELECT userid, TO_CHAR(datelogged,'DD-MON-YY HH24:MI:SS'), description, iserror FROM $schema.activity_log WHERE $where ORDER BY datelogged DESC";
    eval {
        my $csr = $dbh->prepare($sqlquery);
        $csr->execute;
        my $rows = 0;
        my $output .= &start_table(3, 'center', 130, 140, 480);
        my $logtype = ($command eq 'view_errors') ? 'Error' : 'Activity';
        my $selectedactivity = ($command eq 'view_activity') ? ${$logacts{$logactivity}}{'title'} : ${$logerr{$logactivity}}{'title'};
        my $title = "$logtype Log - ${$options{$logOption}}{'title'} for $selectedusername - $selectedactivity (xxx Entries)&nbsp;&nbsp; (<i><font size=2>Most&nbsp;recent&nbsp;at&nbsp;top</font></i>)";
        $output .= &title_row('#cdecff', '#000099', $title);
        $output .= &add_header_row();
        $output .= &add_col() . 'Date/Time';
        $output .= &add_col() . 'User';
        $logtype = "Activity/<font color=#cc0000>Error</font>" if ($logtype eq 'Activity');
        $output .= &add_col() . "$logtype Text";
        while (my @values = $csr->fetchrow_array) {
            my ($user, $date, $text, $err) = @values;
            if ($logactivity eq "all" || matchFound (text => $text, searchString => $logactivity)) {
              if (&does_user_have_priv($dbh, $schema, $userid, -1) || !(matchFound (text=>$text, searchString => 'search'))) {
                $rows++;
                $output .= &add_row();
                $output .= &add_col() . $date;
                $output .= ($user == 0) ? &add_col() . '<b>None</b>' : &add_col_link("javascript:display_user($user)") . &get_fullname($dbh, $schema, $user);
                if ($err eq 'T' && $command eq 'view_activity') {
                    $output .= &add_col() . "<font color=#cc0000>$text</font>";
                }
                else {
                    $output .= &add_col() . $text;
                }
                last if ((($rows >= 10) and ($logOption eq "last10")) ||(($rows >= 100) and ($logOption eq "last100")) || (($rows >= 1000) and ($logOption eq "last1000")));
              }
            }
       }
       $csr->finish;
       $output .= &end_table();
       if ((($rows >= 10) and ($logOption eq "last10")) ||(($rows >= 100) and ($logOption eq "last100")) || (($rows >= 1000) and ($logOption eq "last1000")) || (($rows >= 10) and ($logOption eq "last10"))) {
           $output =~ s/ \(xxx Entries\)//;
       }
       else {
           $output =~ s/xxx/$rows/;
       }
       print "<table width=700 cellpadding=0 calspacing=0 align=center>\n";
       print "<tr><td><b>View: </b></td><td><b>User: </b></td>\n";
       my $whichone = ($command eq 'view_activity') ? "Activity:" : "Error:";
       print "<td><b>$whichone</b></td>\n";
       print "<td>&nbsp;</td></tr>";
       print "<tr><td><select name=logOption size=1>\n";
       foreach my $option (keys (%options)) {
           print "<option value=\"$option\">${$options{$option}}{'title'}\n";
       }
       print "</select></td>\n";
       print "<td><select name=selecteduser>\n";
       print "<option value=-1 selected>All Users\n";
       foreach $key (sort keys %userhash) {
           my $usernamestring = $key;
           $usernamestring =~ s/;$userhash{$key}//g;
           if ($userhash{$key} == $selecteduser){
               print "<option value=\"$userhash{$key}\" selected>$usernamestring\n";
           }
           else {
               print "<option value=\"$userhash{$key}\">$usernamestring\n";
           }
       }
       print "</select></td>\n";
       if ($command eq 'view_activity') {
           print "<td><select name=logactivity>";
           foreach my $acts (keys (%logacts)) {
             if (&does_user_have_priv($dbh, $schema, $userid, -1) || $acts ne 'search') {
               my $selected = ($logactivity eq $acts) ? " selected" : "";
               print "<option value=\"$acts\"$selected>${$logacts{$acts}}{'title'}\n";
             }
           }
           print "</select></td>";
       }
       else {
           print "<td><select name=logactivity>";
           foreach my $acts (keys (%logerr)) {
               my $selected = ($logactivity eq $acts) ? " selected" : "";
               print "<option value=\"$acts\"$selected>${$logerr{$acts}}{'title'}\n";
           }
           print "</select></td>";
       }
       print "<td align=center><input type=button name=displaylog value=Display onClick=document.$form.submit()></td></tr></table><br>";
       print $output;
       print "<script language=javascript><!--\ndocument.$form.logOption.selectedIndex = ${$options{$logOption}}{'index'};\n//--></script>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"read log data",$@);
        print doAlertBox( text => $message);
    }
}
else {
    # display utilities menu -----------------------------------------------------------------------------
    print "<table width=100% align=center><tr><td>\n";
    eval {
        print "<table border=0 cellspacing=0 cellpadding=0 align=center>\n";
        print "<tr><td valign=top width=250>\n";
        print "<font size=3><b>General Utilities</b>\n";
        print "<li><a href=javascript:submitForm('user_functions','changepasswordform')>Change&nbsp;Password</a>\n";
        if ($MMSUseSessions == 1) {
            print "<li><a href=javascript:submitFormCGIResults('logout','logout')>Logout</a>\n";
        }
        if (&does_user_have_priv($dbh, $schema, $userid, 10)) {
            print "<li><b>View&nbsp;Logs:</b>&nbsp;&nbsp;<a href=javascript:submitForm('utilities','view_activity')>Activity</a>&nbsp;&nbsp;<a href=javascript:submitForm('utilities','view_errors')>Error</a>\n";
        }
        my ($sccb) = $dbh -> selectrow_array ("select sccbid from $schema.sccbuser where userid=$userid");
        if ($sccb) {
            print "<li><b>Software Change Request:</b><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=javascript:submitForm('scrhome','write_request')>Submit</a>\n";
####  <a href=$SCMPath/scrhome.pl?command=write_request&userid=$sccb&schema=SCM&origschema=$schema>Submit</a>&nbsp;\n";
####  print "<a href=$SCMPath/scrbrowse.pl?userid=$sccb&schema=SCM>Browse</a>\n";
            print "<a href=javascript:submitForm('scrbrowse','')>Browse</a>\n";
        }
        if (&does_user_have_priv($dbh, $schema, $userid, -1)) {
            print "<li><a href=javascript:submitForm('user_functions','becomeusernameform')>Become Another User</a>\n";
        }
        print "</font>\n</td>";
        if (&does_user_have_priv($dbh, $schema, $userid, 10)) {
            print "<td valign=top width=250>\n<font size=3><b>Users</b><br>\n";
            print "<li><b>Users:</b>&nbsp;&nbsp;<a href=javascript:submitForm('user_functions','adduserform')>Add</a>&nbsp;&nbsp;<a href=javascript:submitForm('user_functions','updateuserform')>Update</a>\n";
            print "</font></td>\n";
        }
        print "</tr>\n<tr><td colspan=3>&nbsp;</td></tr>\n<tr>\n";
        print "</tr>\n</table>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"test user privileges",$@);
        print doAlertBox( text => $message);
    }
    print "</td></tr></table>\n";
}
print "</center>\n</form>\n</td></tr></table></center>\n</font>\n";
print $mmscgi->end_html;
&db_disconnect($dbh);
exit();

