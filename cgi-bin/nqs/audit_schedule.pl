#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/dattam/intradev/rcs/qa/perl/RCS/audit_schedule.pl,v $
#
# $Revision: 1.10 $
#
# $Date: 2007/04/23 19:38:05 $
#
# $Author: dattam $
#
# $Locker:  $
#
# $Log: audit_schedule.pl,v $
# Revision 1.10  2007/04/23 19:38:05  dattam
# Modified '$orgId' to check for SNL as an Organization
#
# Revision 1.9  2004/10/21 18:41:00  starkeyj
# modified 'cgiaction eq report' tp separate external audits into BSC and OQA and added
# the externalAuditType parameter to external reports and headers
#
# Revision 1.8  2004/05/30 22:49:46  starkeyj
# added NEWINTERNAL and NEWEXTERNAL report types
#
# Revision 1.7  2004/02/19 20:50:39  starkeyj
# added EM report type
#
# Revision 1.6  2003/09/22 17:47:21  starkeyj
# modified '$myOrgId' to check for OCRWM as an organization
#
# Revision 1.5  2002/09/09 19:25:31  johnsonc
# Added code to print an alert box if no audit schedule report is available for the selected fiscal year (SCREQ00044).
#
# Revision 1.4  2002/07/24 23:08:31  johnsonc
# Prompt user if a schedule report is unavailable for a selected fiscal year.
#
# Revision 1.3  2002/04/03 17:38:58  johnsonc
# Added code to redirect the report browser window if the host name is changed  on the address line.
#
# Revision 1.2  2001/10/27 00:21:53  johnsonc
# Added eval blocks, function call to write to error log, and function to generate javascript alert box on an error
#
# Revision 1.1  2001/10/22 14:43:52  starkeyj
# Initial revision
#
#
# Revision: $
#
# 

####################################################################################
#
# Parameters:
# 		$year - fiscal year to generate report
#		$scheduleType - Type of report to generate Current schedule, Accepted Schedule
#		$reportType - Internal or Supplier or Both
#     $schema - Database schema where information is selected from
####################################################################################

use DBI;
use OQA_Reports_Lib qw(:Functions);
use OQA_Utilities_Lib qw(:Functions);
use NQS_Header qw(:Constants);
use CGI qw(param);
use strict;
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

############################
sub getRevisionNumber {
############################
   my ($dbh, $schema, $orgId, $year, $table) = @_;
	my $sql = "SELECT max(revision) FROM $schema." . $table . "_audit WHERE fiscal_year = $year ";
	$sql .= " AND issuedby_org_id = $orgId" if (uc($table) eq "INTERNAL");
	print STDERR "$sql\n";
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	my $rev = $sth->fetchrow_array;
	return($rev);
}


my $NQScgi = new CGI;
my ($dbh, $sth, $date, $title);
my $schema = defined($NQScgi->param("schema")) ? $NQScgi->param("schema") : "None";
my $userid = defined($NQScgi->param('userid')) ? uc($NQScgi->param('userid')) : "";
my $username = defined($NQScgi->param("username")) ? $NQScgi->param("username") : "GUEST";
my $year = defined($NQScgi->param('year')) ? $NQScgi->param('year') : "";
my $scheduleType = defined($NQScgi->param('scheduletype')) ? uc($NQScgi->param('scheduletype')) : "";
my $reportType = defined($NQScgi->param('reporttype')) ? uc($NQScgi->param('reporttype')) : "";
my $internalAuditType = defined($NQScgi->param('internalaudittype')) ? uc($NQScgi->param('internalaudittype')) : "";
my $externalAuditType = defined($NQScgi->param('externalaudittype')) ? uc($NQScgi->param('externalaudittype')) : "";
my $cgiaction = defined($NQScgi->param('cgiaction')) ? $NQScgi->param('cgiaction') : "";
my $emailAddress = defined($NQScgi->param('emailaddress')) ? uc($NQScgi->param('emailaddress')) : "";
my $orgId = ($internalAuditType eq "OQA" || $externalAuditType eq "OQA") ? 28 : ($internalAuditType eq "SNL" || $externalAuditType eq "SNL") ? 33 : ($internalAuditType eq "OCRWM" || $externalAuditType eq "OCRWM") ? 24 : ($internalAuditType eq "EM") ? 3 : 1;
my $alertString = "";
$dbh = &NQS_connect();
$dbh->{LongReadLen} = 1000001;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
print $NQScgi->header('text/html');

if ($year eq "" || $reportType eq "" || $schema eq "NONE") {
	print <<OUT;
	<script type="text/javascript">
	<!--
	   if (parent == self) {    // not in frames
			location = '$NQSCGIDir/login.pl'
	   }
	//-->
   </script>
OUT
}
my $rev = &getRevisionNumber($dbh, $schema, $orgId, substr($year, 2, 2), substr($reportType,-8));  
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
	print "<input type=hidden name=scheduletype value='$scheduleType'>\n";
	print "<input type=hidden name=internalaudittype value='$internalAuditType'>\n";
	print "<input type=hidden name=externalaudittype value='$externalAuditType'>\n";
	$alertString = "There is no schedule report available for the selected fiscal year" if (!(defined($rev)) || ($rev < "0" && $scheduleType eq "WORKING") || ($rev < "1" && $scheduleType eq "ACCEPTED"));
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
		print "     document.$form.action = 'audit_schedule.pl'\n";
		print "     $form.submit()\n";
	}
  	print "   //-->\n";
   print "</script>\n";
   print "</form>\n";
	print "</body>\n";
	print "</html>\n";
}
if ($cgiaction eq "report") {
	my $out;
	if ($reportType eq "INTERNAL" && (defined($rev) && ($rev >= "0" && $scheduleType eq "WORKING") || ($rev >= "1" && $scheduleType eq "ACCEPTED"))) {
		eval {
			print &GenerateAuditHeader($year, $reportType, $scheduleType, $internalAuditType, $schema, $dbh);
			print &InternalSchedule($year, $scheduleType,  $internalAuditType, $schema, $dbh, $out);
		};
	}
	elsif ($reportType eq "NEWINTERNAL" && (defined($rev) && ($rev >= "0" && $scheduleType eq "WORKING") || ($rev >= "1" && $scheduleType eq "ACCEPTED"))) {
		eval {
			print &GenerateNewAuditHeader($year, "INTERNAL", $scheduleType, $internalAuditType, $schema, $dbh);
			print &NewInternalSchedule($year, $scheduleType,  $internalAuditType, $schema, $dbh, $out);
		};
	}
	elsif ($reportType eq "EXTERNAL" && (defined($rev) && ($rev >= "0" && $scheduleType eq "WORKING") || ($rev >= "1" && $scheduleType eq "ACCEPTED"))) {
		eval {
			print &GenerateAuditHeader($year, $reportType, $scheduleType, $externalAuditType, $schema, $dbh);
			print &SupplierSchedule($year, $scheduleType, $externalAuditType, $schema, $dbh, $out);
		};
	}
	elsif ($reportType eq "NEWEXTERNAL" && (defined($rev) && ($rev >= "0" && $scheduleType eq "WORKING") || ($rev >= "1" && $scheduleType eq "ACCEPTED"))) {
		eval {
			print &GenerateNewAuditHeader($year, "EXTERNAL", $scheduleType, $externalAuditType, $schema, $dbh);
			print &NewSupplierSchedule($year, $scheduleType, $externalAuditType, $schema, $dbh, $out);
		};
	}
	elsif ($reportType eq "INTERNAL" && $internalAuditType eq "EM") {
		eval {
			print &GenerateAuditHeader($year, $reportType, $scheduleType, $internalAuditType, $schema, $dbh);
			print &InternalSchedule($year, $scheduleType,  $internalAuditType, $schema, $dbh, $out);
		};
	}
	if ($@) {
		&display_error($dbh, 'generate a schedule');
		&log_nqs_error($dbh, $schema, 'T', $userid, "($username) $@");
	}
}

&NQS_disconnect($dbh);
exit();
	

