#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/dattam/intradev/rcs/qa/perl/RCS/surveillance_schedule.pl,v $
#
# $Revision: 1.11 $
#
# $Date: 2007/04/13 16:01:39 $
#
# $Author: dattam $
#
# $Locker:  $
#
# $Log: surveillance_schedule.pl,v $
# Revision 1.11  2007/04/13 16:01:39  dattam
# Modified $orgId to check for SNL as an organization
#
# Revision 1.10  2004/10/21 18:56:39  starkeyj
# modified 'cgiaction eq report' to change reportType of TwoWeeks to Lookahead and pass the
# parameter for which type of lookahead report is to be generated
#
# Revision 1.9  2004/05/30 23:09:43  starkeyj
# addedd NEWLOG report type
#
# Revision 1.8  2004/02/11 21:17:18  starkeyj
# modified so InProgress report uses a fiscal year paramater screen
#
# Revision 1.7  2004/02/11 19:41:41  starkeyj
# modified to add two-week lookahead report and surveillances in progress report
#
# Revision 1.6  2002/10/23 22:42:53  johnsonc
# bug fix - Fixed error with the surveillance sequence number selection
#
# Revision 1.5  2002/09/24 23:39:15  johnsonc
# Removed extraneous code that caused error to be written to the web server error log
#
# Revision 1.4  2002/09/09 19:27:26  johnsonc
# Added code to print an alert box if no surveillance schedule report is available for the selected fiscal year (SCREQ00044).
#
# Revision 1.3  2002/04/03 17:36:39  johnsonc
# Added code to redirect the report browser window if the host name is changed  on the address line.
#
# Revision 1.2  2001/10/27 00:38:41  johnsonc
# Added eval blocks, function call to write to error log, and function to generate javascript alert box on an error
#
# Revision 1.1  2001/10/22 14:43:52  starkeyj
# Initial revision
#
#

####################################################################################
#
# Parameters:
# 		$year - fiscal year to generate request for
#		$org - Request Surveillance Log or Request List for a particuliar organnization
#		$reportType - Surveillance Log, Request List
####################################################################################

use OQA_Reports_Lib qw(:Functions);
use DBI;
use OQA_Utilities_Lib qw(:Functions);
use NQS_Header qw(:Constants);
use CGI qw(param);
use strict;
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

sub getSurveillanceCount {
   my ($dbh, $schema, $orgId, $year, $table, $queryOrg) = @_;
	my $sql = "SELECT count(id) FROM $schema." . $table . " WHERE fiscal_year = $year "
	          . "AND issuedby_org_id = $orgId";
	$sql .= " AND issuedto_org_id = $queryOrg" if ($queryOrg > 0);
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	my $count = $sth->fetchrow_array;
	print STDERR "$sql -- $count\n";
	return($count);
}

my $NQScgi = new CGI;
my ($dbh, $sth, $date, $title);
my $schema = defined($NQScgi->param("schema")) ? $NQScgi->param("schema") : "None";
my $year = defined($NQScgi->param('year')) ? $NQScgi->param('year') : "";
my $userid = defined($NQScgi->param('userid')) ? uc($NQScgi->param('userid')) : "";
my $username = defined($NQScgi->param("username")) ? $NQScgi->param("username") : "GUEST";
my $reportType = defined($NQScgi->param('reporttype')) ? uc($NQScgi->param('reporttype')) : "";
my $lookaheadType = defined($NQScgi->param('lookaheadtype')) ? uc($NQScgi->param('lookaheadtype')) : "";
my $queryOrg = defined($NQScgi->param('org')) ? $NQScgi->param('org') : 0;
my $survType = defined($NQScgi->param('internalaudittype')) ? uc($NQScgi->param('internalaudittype')) : "";
my $scheduleType = defined($NQScgi->param('scheduletype')) ? uc($NQScgi->param('scheduletype')) : "";
my $cgiaction = defined($NQScgi->param('cgiaction')) ? $NQScgi->param('cgiaction') : "";
my $orgId = ($survType eq "OQA") ? 28 : ($survType eq "SNL") ? 33 : 1;
my $alertString = "";
my $table = ($reportType eq "LOG" || $reportType eq "NEWLOG") ? "SURVEILLANCE" : "SURVEILLANCE_REQUEST";	
$dbh = &NQS_connect();
print $NQScgi->header('text/html');
if (($year eq "" && $reportType ne 'LOOKAHEAD') || $reportType eq "" || $schema eq "NONE") {
	print <<OUT;
	<script type="text/javascript">
	<!--
		var dosubmit = true;
	   if (parent == self) {    // not in frames
			location = '$NQSCGIDir/login.pl'
	   }
	//-->
   </script>
OUT
}
my $count;
$count = &getSurveillanceCount($dbh, $schema, $orgId, substr($year, 2, 2), $table, $queryOrg) if ($reportType ne 'LOOKAHEAD' && $reportType ne 'INPROGRESS');
#print "<br>-- $count -- <br>";
if ($cgiaction ne "report") {
	print "<html>\n";
	print "<head>\n";
	print "</head>\n";
	print "<body background=/nqs/images/background.gif text=\"#000099\" link=\"#0000ff\" vlink=\"#0000ff\" alink=\"#0000ff\" topmargin=0 leftmargin=0>\n";
	print "<form name=$form method=post>\n";
	print "<input type=hidden name=cgiaction value='$cgiaction'>\n";
	print "<input type=hidden name=year value='$year'>\n";
	print "<input type=hidden name=schema value='$schema'>\n";
	print "<input type=hidden name=username value='$username'>\n";
	print "<input type=hidden name=userid value='$userid'>\n";
	print "<input type=hidden name=reporttype value='$reportType'>\n";
	print "<input type=hidden name=lookaheadtype value='$lookaheadType'>\n";
	print "<input type=hidden name=org value='$queryOrg'>\n";
	$alertString = "There is no schedule report available for the selected fiscal year" if ($reportType ne 'LOOKAHEAD' && $reportType ne 'INPROGRESS' && (!(defined($count)) || $count < 1));
	print "<input type=hidden name=internalaudittype value='$survType'>\n";
	print "<script type=\"text/javascript\">\n";
	print "  <!--\n";
	if ($alertString ne "") {
		print "		alert('$alertString');\n";
	}
	else {
   	print "		var myDate = new Date();\n";
		print "		var winName = myDate.getTime();\n";
		print "		document.$form.target = winName;\n";
		print "		var newwin = window.open(\"\",winName);\n";
		print "		newwin.creator = self;\n";
		print "     document.$form.cgiaction.value = 'report';\n";
		print "     document.$form.action = 'surveillance_schedule.pl'\n";
		print "     $form.submit()\n";
	}
  	print "   //-->\n";
   print "</script>\n";
   print "</form>\n";
	print "</body>\n";
	print "</html>\n";
}
if ($cgiaction eq "report") {
	if ($reportType eq "LOOKAHEAD") {
		eval {
			print &GenerateLookaheadHeader($schema, $dbh, $lookaheadType);	
			print &Lookahead($schema, $dbh, $lookaheadType);
		};
	}
	elsif ($reportType eq "INPROGRESS") {
		eval {
			print &GenerateInProgressHeader($year, $schema, $dbh, $lookaheadType);	
			print &InProgress($year, $schema, $dbh);
		};
	}
	elsif ($reportType eq "LOG") {
		eval {
			print &GenerateSurveillanceHeader($year, $reportType, $survType, $schema, $dbh);	
			print &SurveillanceLog($year, $queryOrg, $survType, $schema, $dbh);
		};
	}
	elsif ($reportType eq "NEWLOG") {
		eval {
			print &GenerateNewSurveillanceHeader($year, $reportType, $survType, $schema, $dbh);	
			print &NewSurveillanceLog($year, $queryOrg, $survType, $schema, $dbh);
		};
	}
	else {
		eval {
			print &GenerateSurveillanceHeader($year, $reportType, $survType, $schema, $dbh);
			print &SurveillanceRequest($year, $survType, $schema, $dbh);
		};
	}
	if ($@) {
		&display_error($dbh, 'generate a log or request schedule');
		&log_nqs_error($dbh, $schema, 'T', $userid, "($username) $@");
	}
}
&NQS_disconnect($dbh);
exit();



