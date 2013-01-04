#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/qa/perl/RCS/utilities.pl,v $
#
# $Revision: 1.17 $
#
# $Date: 2005/07/12 15:33:46 $
#
# $Author: dattam $
#
# $Locker: higashis $
#
# $Log: utilities.pl,v $
# Revision 1.17  2005/07/12 15:33:46  dattam
# modified subroutine matchFound to add link for suborganizations.
#
# Revision 1.16  2003/09/03 18:57:54  starkeyj
# modified subroutine 'matchFound' to hide the create fiscal year and remove fiscal
# year links - SCR 55
#
# Revision 1.15  2002/10/09 22:56:41  johnsonc
# Included 'use strict' pragma in script.
#
# Revision 1.14  2002/09/10 01:03:02  starkeyj
# modified page so BSC and OQA can generate and drop draft schedules independently
# and modified privileges so OQA and BSC are separate - SCR 44
#
# Revision 1.13  2002/07/01 23:47:38  starkeyj
# added link so internal audit administrator can create a draft schedule for a new FY
# automatically, based on the current FY - for SCR 43
#
# Revision 1.12  2002/02/22 22:37:30  starkeyj
# modified so SCR Requests are shown to be requested from the ASSM application
#
# Revision 1.11  2002/02/11 21:03:59  johnsonc
# Moved unordered list closing tag out of if block in Password Maintenance section
#
# Revision 1.10  2002/02/06 00:58:11  johnsonc
# Re-formatted lay-out for utitlities main screen section
#
# Revision 1.8  2002/01/08 21:29:55  johnsonc
# Changed heading of utilities main screen column from User Maintenance to Password Maintenance
#
# Revision 1.7  2002/01/07 22:47:57  johnsonc
# Added two rows in the utitilities main screen
#
# Revision 1.6  2002/01/03 22:05:31  starkeyj
# added view activity log and view error log
#
# Revision 1.5  2001/11/06 17:59:35  starkeyj
# modified user privilege for software change requests
#
# Revision 1.4  2001/11/02 22:56:43  starkeyj
# changed software request labels
#
# Revision 1.3  2001/10/23 00:26:55  starkeyj
# started the functions to allow software change requests
#
# Revision 1.2  2001/10/22 18:04:18  starkeyj
# no change, user error with RCS
#
# Revision 1.1  2001/10/19 23:32:19  starkeyj
# Initial revision
#
#
# Revision: $
#
# 
use NQS_Header qw(:Constants);
use OQA_Utilities_Lib qw(:Functions);
use OQA_Widgets qw(:Functions);
use CGI;
use strict;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $NQScgi = new CGI;
my $username = defined($NQScgi->param("username")) ? $NQScgi->param("username") : "GUEST";
my $userid = defined($NQScgi->param("userid")) ? $NQScgi->param("userid") : 0;
my $schema = defined($NQScgi->param("schema")) ? $NQScgi->param("schema") : "None";
my $cgiaction = defined($NQScgi->param("cgiaction")) ? $NQScgi->param("cgiaction") : "None";
my $Server = defined($NQScgi->param("server")) ? $NQScgi->param("server") : $NQSServer;
#my $command = ((defined($NQScgi->param('command'))) ? (($NQScgi->param('command') gt " ") ? $NQScgi->param('command') : "menu") : "menu");
my $idstr = "&username=$username&userid=$userid";
my $dbh = &NQS_connect();
my %userprivhash = &get_user_privs($dbh,$userid);


print <<END_of_Multiline_Text;
Content-type: text/html

<HTML>
<HEAD>
<script src=$NQSJavaScriptPath/utilities.js></script>
<Title>Data Deficiency Tracking</Title>
</HEAD>
<script language=javascript type=text/javascript><!--
	doSetTextImageLabel('Utilities');\n//-->
</script>

<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) {    // not in frames
    location = '$NQSCGIDir/login.pl';
}
function display_user(id) {
	document.$form.id.value = id;
	submitForm('system_functions', 'displayuser');
}
function submitForm(script, command) {
	 document.$form.cgiaction.value = command;
	 document.$form.action = '$path' + script + '.pl';
	 document.$form.target = 'workspace';
	 document.$form.submit();
}
function makesure(org) {
	if (confirm("Are you sure?")) {
		document.$form.cgiaction.value = 'remove_fy';
		document.$form.org.value = org;
		document.$form.action = '$path' + 'create_fy.pl';
		document.$form.target = 'control';
		document.$form.submit();
	}
}
//-->
</script>
</head>

<Body background=$NQSImagePath/background.gif text=#000099>
<center>
<form name=$form method=post>
<input type=hidden name=username value=$username>
<input type=hidden name=userid value=$userid>
<input type=hidden name=schema value=$schema>
<input type=hidden name=id value=0>
<input type=hidden name=cgiaction value=$cgiaction>
<input type=hidden name=app value=ASSM>
<br><table align=center>
END_of_Multiline_Text

###########################
sub getLatestFY {
###########################
	 my @values;
	 my $sqlquery = "SELECT max(fiscal_year) from $SCHEMA.fiscal_year ";

	 my $csr = $dbh->prepare($sqlquery);
	 $csr->execute;
	 @values = $csr->fetchrow_array;
	 $csr->finish;
	    
	 my $latest_fy = $values[0];
	 #print STDERR "\n Latest FY = $latest_fy\n";
    return ($latest_fy);
}

###########################
sub getLastApprovedFY {
###########################
   my $auditing_org = $_[0];
#   print STDERR "in func audit = $auditing_org\n";
	my @values;
	my $sqlquery = "SELECT max(fiscal_year) from $SCHEMA.audit_revisions ";
	$sqlquery .= "where audit_type = 'I' and auditing_org = '$auditing_org' and fiscal_year < 50 ";
#	print STDERR "$sqlquery\n";
	my $csr = $dbh->prepare($sqlquery);
	$csr->execute;
	@values = $csr->fetchrow_array;
	$csr->finish;

	my $last_approved_fy = $values[0] + 2000;
	#print STDERR "\n Last Approved FY = $last_approved_fy\n";
	return ($last_approved_fy);
}

###########################
sub getLastAuditFY {
###########################
   my $auditing_org = $_[0];
	my @orgid = lookup_column_values($dbh, 'organizations', 'id', "abbr = '$auditing_org'");
	my @values;
	my $sqlquery = "SELECT max(fiscal_year) from $SCHEMA.internal_audit ";
	$sqlquery .= "where issuedby_org_id = $orgid[0] and fiscal_year < 50 ";
	#print STDERR "~~$sqlquery $auditing_org\n";
	my $csr = $dbh->prepare($sqlquery);
	$csr->execute;
	@values = $csr->fetchrow_array;
	$csr->finish;

	my $last_approved_fy = $values[0] + 2000;
	#print STDERR "\n Last Approved FY = $last_approved_fy\n";
	return ($last_approved_fy);

}
###########################
sub getCurrentFY {
###########################
 	my $current_fy;
	my $current_year = $dbh -> prepare ("select to_char(sysdate,'MM/YYYY') from dual");
	$current_year -> execute;
	my $mmyyyy = $current_year -> fetchrow_array;
	$current_year -> finish;
	my $mm = substr($mmyyyy,0,2);
	if ($mm > 9) {
		$current_fy = substr($mmyyyy,3) + 1;
	}
	else { $current_fy = substr($mmyyyy,3); }
	return ($current_fy);
}

################
sub matchFound {
################
   my %args = (
      @_,
   );
   my $out;
   $out = ($args{text} =~ m/$args{searchString}/i) ? 1 : 0;
   return ($out);
}

if ($cgiaction eq "view_activitylog" || $cgiaction eq "view_errorlog") {
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
    "all" => {'index' => 0, 'title' => "All Activities"},
    "cancelled external audit" => {'index' => 1, 'title' => "Cancel external audit"},
    "cancelled internal audit" => {'index' => 2, 'title' => "Cancel internal audit"},
    "added external audit" => {'index' => 3, 'title' => "Create external audit"},
    "added internal audit" => {'index' => 4, 'title' => " Create internal audit"},
    "added location" => {'index' => 5, 'title' => "Create location"},
    "added organization" => {'index' => 6, 'title' => "Create organization"},
    "added company" => {'index' => 7, 'title' => "Create supplier"},
    "added surveillance" => {'index' => 8, 'title' => "Create surveillance"},
    "added request" => {'index' => 9, 'title' => "Create surveillance request"},
    "added user" => {'index' => 10, 'title' => "Create user"},
    "deleted external audit" => {'index' => 11, 'title' => "Delete external audit"},
    "deleted internal audit" => {'index' => 12, 'title' => "Delete internal audit"},
    "deleted surveillance" => {'index' => 13, 'title' => "Delete surveillance"},
    "deleted request" => {'index' => 14, 'title' => "Delete surveillance request"},
    "updated external audit" => {'index' => 15, 'title' => "Modify external audit"},
    "updated internal audit" => {'index' => 16, 'title' => "Modify internal audit"},
    "updated location" => {'index' => 17, 'title' => "Modify location"},
    "updated organization" => {'index' => 18, 'title' => "Modify organization"},
    "updated supplier" => {'index' => 19, 'title' => "Modify supplier"},
    "updated surveillance" => {'index' => 20, 'title' => "Modify surveillance"},
    "updated request" => {'index' => 21, 'title' => "Modify surveillance request"},
    "updated user" => {'index' => 22, 'title' => "Modify user"},
    "logged" => {'index' => 23, 'title' => "User login"}
       );
	tie my %logerr, "Tie::IxHash";
	%logerr = (
    "all" => {'index' => 0, 'title' => "All Errors"},
    "activity log" => {'index' => 59, 'title' => "Write to activity log"}
      );
      
    my %userhash;
    my $key;
    %userhash = get_lookup_values($dbh, 'users', "lastname || ' ' || firstname", 'id', "isactive = 'T' ");
      
   my $logOption = (defined($NQScgi->param("logOption"))) ? $NQScgi->param("logOption") : "today";
	    my $logactivity = (defined($NQScgi->param("logactivity"))) ? $NQScgi->param("logactivity") : "all";
	    my $selecteduser = (defined($NQScgi->param("selecteduser"))) ? $NQScgi -> param ("selecteduser") : -1;
	    my $selectedusername = ($selecteduser == -1) ? "all users" : get_fullname($dbh, $schema, $selecteduser);
	    my $userwhere = ($selecteduser == -1) ? "" : "userid = $selecteduser and";
	    my $iserror = (($cgiaction eq 'view_errorlog') ? 'T' : 'F');
	    my $table = (($cgiaction eq 'view_errorlog') ? 'nqs_error_log' : 'nqs_activity_log');
	    my $where = "$userwhere iserror = '$iserror' and ${$options{$logOption}}{'where'}";
	    my $sqlquery = "SELECT userid, TO_CHAR(datelogged,'DD-MON-YY HH24:MI:SS'), description FROM $schema.$table WHERE $where ORDER BY datelogged DESC";
	    eval {
	        my $csr = $dbh->prepare($sqlquery);
	        $csr->execute;
	        my $rows = 0;
	        my $output .= &start_table(3, 'center', 130, 140, 480);
	        my $logtype = ($iserror eq 'T') ? 'Error' : 'Activity';
	        my $selectedactivity = ($cgiaction eq 'view_activitylog') ? ${$logacts{$logactivity}}{'title'} : ${$logerr{$logactivity}}{'title'};
	        my $title = "$logtype Log - ${$options{$logOption}}{'title'} for $selectedusername - $selectedactivity (xxx Entries)&nbsp;&nbsp; (<i><font size=2>Most&nbsp;recent&nbsp;at&nbsp;top</font></i>)";
	        $output .= &title_row('#cdecff', '#000099', $title);
	        $output .= &add_header_row();
	        $output .= &add_col() . 'Date/Time';
	        $output .= &add_col() . 'User';
	        $output .= &add_col() . "$logtype Text";
	        while (my @values = $csr->fetchrow_array) {
	            my ($user, $date, $text) = @values;
	            if ($logactivity eq "all" || matchFound (text => $text, searchString => $logactivity)) {
	                $rows++;
	                $output .= &add_row();
	                $output .= &add_col() . $date;
	                $output .= ($user == 0) ? &add_col() . '<b>None</b>' : &add_col_link("javascript:display_user($user)") . &get_fullname($dbh, $schema, $user);
	                $output .= &add_col() . $text;
	                last if ((($rows >= 10) and ($logOption eq "last10")) ||(($rows >= 100) and ($logOption eq "last100")) || (($rows >= 1000) and ($logOption eq "last1000")));
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
	       print "<table width=700 cellpadding=0 cellspacing=0 align=center>\n";
	       print "<tr><td><b>View: </b></td><td><b>User: </b></td>\n";
	       #my $whichone = ($cgiaction eq 'view_activitylog') ? "Activity:" : "Error:";
	       my $whichone = ($cgiaction eq 'view_activitylog') ? "Activity:" : " ";
	       print "<td><b>$whichone</b></td>\n";
	       print "<td>&nbsp;</td></tr>";
	       print "<tr><td><select name=logOption size=1>\n";
	       foreach my $option (keys (%options)) {
	           print "<option value=\"$option\">${$options{$option}}{'title'}\n";
	       }
	       print "</select></td>\n";
	       print "<td><select name=selecteduser>\n";
	       print "<option value=-1 selected>All Users\n";
	       foreach $key (sort { lc($a) cmp lc($b) } keys %userhash) {
	           my $usernamestring = $key;
	           $usernamestring =~ s/;$userhash{$key}//g;
	           $usernamestring =~ /(.*)\s(.*)/;
	           if ($userhash{$key} == $selecteduser){
	               print "<option value=\"$userhash{$key}\" selected>$2 $1\n";
	           }
	           else {
	               print "<option value=\"$userhash{$key}\">$2 $1\n";
	           }
	       }
	       print "</select></td>\n";
	       if ($cgiaction eq 'view_activitylog') {
	           print "<td><select name=logactivity>";
	           foreach my $acts (keys (%logacts)) {
	               my $selected = ($logactivity eq $acts) ? " selected" : "";
	               print "<option value=\"$acts\"$selected>${$logacts{$acts}}{'title'}\n";
	           }
	           print "</select></td>";
	       }
	       else {
	       		print "<td>&nbsp;</td>";
	      #     print "<td><select name=logactivity>";
	      #     foreach my $acts (keys (%logerr)) {
	      #         my $selected = ($logactivity eq $acts) ? " selected" : "";
	      #         print "<option value=\"$acts\"$selected>${$logerr{$acts}}{'title'}\n";
	      #     }
	      #     print "</select></td>";
	       }
	       print "<td align=center><input type=button name=displaylog value=Display onClick=document.$form.submit()></td></tr></table><br>";
	       print $output;
	       print "<script language=javascript><!--\ndocument.$form.logOption.selectedIndex = ${$options{$logOption}}{'index'};\n//--></script>\n";
    };
	 #print "<td align=center><input type=button name=displaylog value=Display onClick=document.$form.submit()></td>";


}
else {
	print "<tr><td valign=top><br><ul><lh><b>Password Maintenance</b>\n";
	print "<li><a href=\"$NQSCGIDir/system_functions.pl?cgiaction=change_password&pagetitle=abcd$idstr&schema=$SCHEMA\">Change Your Password</a></li>\n";
  	if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'BSC Internal Administration'} == 1 
  		|| $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'BSC Supplier Administration'} == 1 
  		|| $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'BSC Surveillance Administration'} == 1) {
  	
  		print "<li><a href=\"$NQSCGIDir/system_functions.pl?cgiaction=reset_password&pagetitle=abcd$idstr&schema=$SCHEMA\">Reset User Password</a></li>\n";
  	}
  	print "</ul>";
   print "<br><ul><lh><b>System Maintenance</b>\n";
  	print <<END_of_Multiline_Text2;

  	<li><a href="$NQSCGIDir/location_maint.pl?action=query&updatetable=locations&pagetitle=Location$idstr&schema=$SCHEMA">Locations</a></li>
  	<li><a href="$NQSCGIDir/organization_maint.pl?action=query&updatetable=organizations&pagetitle=Organization$idstr&schema=$SCHEMA">Organizations</a></li>
  	<li><a href="$NQSCGIDir/organization_maint.pl?action=suborg_query&updatetable=bsc_suborganizations&pagetitle=Suborganization$idstr&schema=$SCHEMA">Suborganizations</a></li>
  	<li><a href="$NQSCGIDir/supplier_maint.pl?action=query&updatetable=qualified_supplier&pagetitle=Qualified_Suppliers$idstr&schema=$SCHEMA">Suppliers</a></li>
  	<li><a href="$NQSCGIDir/users_maint.pl?action=query&updatetable=users&pagetitle=Users$idstr&schema=$SCHEMA">Users</a></li>
    	</td>
  	<td valign=top>
END_of_Multiline_Text2
  	if ($userprivhash{'SCCB User'} == 1 ) {
  		print "<br><ul><lh><b>Software Change Requests</b>\n";
  		print "<li><a href=\"$NQSCGIDir/scrhome.pl?$idstr&schema=$schema&app=ASSM\">Software Change Request</a></li>\n";
  		print "<li><a href=\"$NQSCGIDir/scrbrowse.pl?$idstr&schema=$schema&app=ASSM\">Browse Software Change Requests</a></li>\n";
  		print "</ul>";
   }
   if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'BSC Internal Administration'} == 1 
		|| $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'BSC Surveillance Administration'} == 1 
		|| $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'BSC Supplier Administration'} == 1) {
		print "<br><ul><lh><b>System Logs</b>\n";
		print "<li><a href=\"$NQSCGIDir/utilities.pl?$idstr&schema=$schema&cgiaction=view_activitylog\">View Activity Log</a></li>\n";
		print "<li><a href=\"$NQSCGIDir/utilities.pl?$idstr&schema=$schema&cgiaction=view_errorlog\">View Error Log</a></li>\n";
	}
  	print "</ul>\n";
  	my $latest_fy = &getLatestFY;
  	my $currentFY = &getCurrentFY;
  	my $last_OQA_fy = &getLastAuditFY('OQA');
  	my $last_BSC_fy = &getLastAuditFY('BSC');
  	my $last_OQA_approved_fy = &getLastApprovedFY('OQA');
	my $last_BSC_approved_fy = &getLastApprovedFY('BSC');
	print "<input type=hidden name=org>\n";
	print "<ul>\n";
	if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'OQA Internal Schedule Approver'} == 1) {
		#print "<br><lh><b>OQA Internal Audit Administrator Functions</b>\n";
		my $next_fy = $last_OQA_fy + 1;
		if ($last_OQA_fy == $last_OQA_approved_fy) {
			#print "<li><a href=\"$NQSCGIDir/create_fy.pl?userid=$userid&username=$username&schema=$schema&cgiaction=create_schedule&create_yr=$next_fy&org=OQA\">Create OQA Draft Schedule for Fiscal Year $next_fy</a></li>\n";
		}
		else {
			print "<input type=hidden name=remove_yr value=$latest_fy>\n";
			#print "<li><a href=\"javascript:makesure('OQA');\">Remove OQA Draft Schedule for Fiscal Year $latest_fy</a></li>\n";
			#print "<li><a href=\"$NQSCGIDir/create_fy.pl?userid=$userid&username=$username&schema=$schema&cgiaction=remove_fy&remove_yr=$latest_fy\">Remove Draft Fiscal Year $latest_fy</a></li>\n";
		}
	}
	print "<br>\n" if ($userprivhash{'Developer'} == 1);
	if ($userprivhash{'Developer'} == 1 || $userprivhash{'BSC Internal Administration'} == 1 || $userprivhash{'BSC Internal Schedule Approver'} == 1) {
		#print "<br><lh><b>BSC Internal Audit Administrator Functions</b>\n";
		my $next_fy = $last_BSC_fy + 1;
		if ($last_BSC_fy == $last_BSC_approved_fy) {
			#print "<li><a href=\"$NQSCGIDir/create_fy.pl?userid=$userid&username=$username&schema=$schema&cgiaction=create_schedule&create_yr=$next_fy&org=BSC\">Create BSC Draft Schedule for Fiscal Year $next_fy</a></li>\n";
		}
		else {
			print "<input type=hidden name=remove_yr value=$latest_fy>\n";
			#print "<li><a href=\"javascript:makesure('BSC');\">Remove BSC Draft Schedule for Fiscal Year $latest_fy</a></li>\n";
			#print "<li><a href=\"$NQSCGIDir/create_fy.pl?userid=$userid&username=$username&schema=$schema&cgiaction=remove_fy&remove_yr=$latest_fy\">Remove Draft Fiscal Year $latest_fy</a></li>\n";
		}
	}
print "</ul>\n";
}

print <<END_of_Multiline_Text3;
</td>
</tr>
</table>
</form>
</center>
</Body>
</HTML>

END_of_Multiline_Text3
&NQS_disconnect($dbh);
