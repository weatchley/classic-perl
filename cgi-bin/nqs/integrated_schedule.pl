#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/dattam/intradev/rcs/qa/perl/RCS/integrated_schedule.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2007/04/12 17:12:00 $
#
# $Author: dattam $
#
# $Locker:  $
#
# $Log: integrated_schedule.pl,v $
# Revision 1.2  2007/04/12 17:12:00  dattam
# New variable $snl created for SNL Reports.
#
# Revision 1.1  2005/10/31 23:24:25  starkeyj
# Initial revision
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
#my $orgId = ($internalAuditType eq "OQA" || $externalAuditType eq "OQA") ? 28 : ($internalAuditType eq "OCRWM" || $externalAuditType eq "OCRWM") ? 24 : ($internalAuditType eq "EM") ? 3 : 1;
#my $alertString = "";

my $audit = defined($NQScgi->param('audit')) ? uc($NQScgi->param('audit')) : "";
my $bsc = defined($NQScgi->param('bsc')) ? uc($NQScgi->param('bsc')) : "";
my $snl = defined($NQScgi->param('snl')) ? uc($NQScgi->param('snl')) : "";
my $oqa = defined($NQScgi->param('oqa')) ? uc($NQScgi->param('oqa')) : "";
my $surv = defined($NQScgi->param('surv')) ? uc($NQScgi->param('surv')) : "";
my $ocrwm = defined($NQScgi->param('ocrwm')) ? uc($NQScgi->param('ocrwm')) : "";
my $other = defined($NQScgi->param('other')) ? uc($NQScgi->param('other')) : "";
my $internal = defined($NQScgi->param('internal')) ? uc($NQScgi->param('internal')) : "";
my $external = defined($NQScgi->param('external')) ? uc($NQScgi->param('external')) : "";
my $teamcolumn = defined($NQScgi->param('teamcolumn')) ? uc($NQScgi->param('teamcolumn')) : "";
my $showcancelled = defined($NQScgi->param('showcancelled')) ? uc($NQScgi->param('showcancelled')) : "";
my $dateRangeType = defined($NQScgi->param('dateRangeType')) ? uc($NQScgi->param('dateRangeType')) : "";
my $fromdate = defined($NQScgi->param('fromdate')) ? ($NQScgi->param('fromdate')) : "";
my $todate = defined($NQScgi->param('todate')) ? ($NQScgi->param('todate')) : "";

$dbh = &NQS_connect();
$dbh->{LongReadLen} = 1000001;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
#print $NQScgi->header('text/html');

if ($cgiaction eq "PDFtest") {
	eval {
		print &IntegratedPDFReport($year, $scheduleType, $audit, $surv, $bsc, $oqa, $ocrwm, $other, $internal, $external, $teamcolumn, $schema, $dbh);
	};
}	
elsif ($cgiaction ne "report") {
	print $NQScgi->header('text/html');
	print "<html>\n";
	print "<head>\n";
	print "</head>\n";
	print "<body background=/nqs/images/background.gif text=\"#000099\" link=\"#0000ff\" vlink=\"#0000ff\" alink=\"#0000ff\" topmargin=0 leftmargin=0>\n";
	print "<form name=$form method=post>\n";
	print "<input type=hidden name=cgiaction value='$cgiaction'>\n";
	print "<input type=hidden name=year value='$year'>\n";
	print "<input type=hidden name=audit value='$audit'>\n";
	print "<input type=hidden name=bsc value='$bsc'>\n";
	print "<input type=hidden name=snl value='$snl'>\n";
	print "<input type=hidden name=ocrwm value='$ocrwm'>\n";
	print "<input type=hidden name=oqa value='$oqa'>\n";
	print "<input type=hidden name=other value='$other'>\n";
	print "<input type=hidden name=surv value='$surv'>\n";
	print "<input type=hidden name=internal value='$internal'>\n";
	print "<input type=hidden name=external value='$external'>\n";
	print "<input type=hidden name=teamcolumn value='$teamcolumn'>\n";
	print "<input type=hidden name=showcancelled value='$showcancelled'>\n";
	print "<input type=hidden name=dateRangeType value='$dateRangeType'>\n";
	print "<input type=hidden name=fromdate value='$fromdate'>\n";
	print "<input type=hidden name=todate value='$todate'>\n";
	print "<input type=hidden name=schema value='$schema'>\n";
	print "<input type=hidden name=username value='$username'>\n";
	print "<input type=hidden name=userid value='$userid'>\n";
	print "<input type=hidden name=reporttype value='$reportType'>\n";
	#print "<input type=hidden name=scheduletype value='$scheduleType'>\n";
	print "<input type=hidden name=internalaudittype value='$internalAuditType'>\n";
	print "<input type=hidden name=externalaudittype value='$externalAuditType'>\n";
	print "<script type=\"text/javascript\">\n";
	print "  <!--\n";
   	print "		var myDate = new Date();\n";
	print "		var winName = myDate.getTime();\n";
	print "		document.$form.target = winName;\n";
	print "		var newwin = window.open(\"\",winName);\n";
	print "		newwin.creator = self;\n";
	print "         document.$form.cgiaction.value = 'report';\n";
	print "         document.$form.action = 'integrated_schedule.pl'\n";
	print "         $form.submit()\n";
  	print "   //-->\n";
   	print "</script>\n";
   	print "</form>\n";
	print "</body>\n";
	print "</html>\n";
}

if ($cgiaction eq "report") {
	if ($reportType eq "PDFTEST") {
		eval {
			print &IntegratedPDFReport($year, $scheduleType, $audit, $surv, $bsc, $snl, $oqa, $ocrwm, $other, $internal, $external, $teamcolumn, $showcancelled, $dateRangeType, $fromdate, $todate, $schema, $dbh);
		};
	}	
	if ($@) {
		&display_error($dbh, 'generate the PDF integrated schedule');
		&log_nqs_error($dbh, $schema, 'T', $userid, "($username) $@");
	}
}

&NQS_disconnect($dbh);
exit();
	

