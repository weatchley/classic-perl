#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/qa/perl/RCS/email_report.pl,v $
#
# $Revision: 1.5 $
#
# $Date: 2003/09/22 17:45:21 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: email_report.pl,v $
# Revision 1.5  2003/09/22 17:45:21  starkeyj
# modified '$myOrgId' to check for OCRWM as an organization
#
# Revision 1.4  2002/09/09 20:55:25  johnsonc
# Added code to print an alert box if no schedule report is available for the selected fiscal year.
# ,
#
# Revision 1.3  2002/02/06 00:42:52  johnsonc
#  Added additonal parameter to MailInternalSchedule and MailExternalSchedule function calls
#
# Revision 1.2  2001/10/27 01:32:54  johnsonc
# Added eval blocks, function call to write to error log, and function to generate javascript alert box on an error
#
# Revision 1.1  2001/10/22 14:43:52  starkeyj
# Initial revision
#
#
# Revision: $
#
# 
use OQA_Reports_Lib qw(:Functions);
use OQA_Utilities_Lib qw(:Functions);
use CGI qw(param);
use NQS_Header qw(:Constants);
use Mail_Utilities_Lib qw(:Functions);
use strict;
my $dbh;

$ENV{'ORACLE_HOME'} = "/usr/local/oracle8";
$dbh = &NQS_connect();
$dbh->{LongReadLen} = 1000001;
$dbh->{LongTruncOk} = 1;

my $NQScgi = new CGI;
my $username = defined($NQScgi->param("username")) ? $NQScgi->param("username") : "GUEST";
my $userid = defined($NQScgi->param("userid")) ? $NQScgi->param("userid") : "None";
my $schema = defined($NQScgi->param("schema")) ? $NQScgi->param("schema") : "None";
my $cgiaction = defined($NQScgi->param('cgiaction')) ? $NQScgi->param('cgiaction') : "";
my $year = defined($NQScgi->param('year')) ? $NQScgi->param('year') : "";
my $scheduleType = defined($NQScgi->param('scheduletype')) ? $NQScgi->param('scheduletype') : "";
my $reportType = defined($NQScgi->param('reporttype')) ? uc($NQScgi->param('reporttype')) : "";
my $emailAddress = defined($NQScgi->param('emailaddress')) ? uc($NQScgi->param('emailaddress')) : "";
my $isApproverReport = defined($NQScgi->param('approver_report')) ? $NQScgi->param('approver_report') : "";
my $internalAuditType = defined($NQScgi->param('internalaudittype')) ? uc($NQScgi->param('internalaudittype')) : "";
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

############################
sub getRevisionNumber {
############################
   my ($dbh, $schema, $orgId, $year, $table) = @_;
	my $sql = "SELECT max(revision) FROM $schema." . $table . "_audit WHERE fiscal_year = $year ";
	$sql .= " AND issuedby_org_id = $orgId" if (uc($table) eq "INTERNAL");
#	print STDERR "$sql\n";
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	my $rev = $sth->fetchrow_array;
	return($rev);
}


my $sth;
my $alertString = "An e-mail message has been sent to you with the attached report";
my $orgId = ($internalAuditType eq "OQA") ? 28 : ($internalAuditType eq "OCRWM") ? 24 : 1;
my $rev = &getRevisionNumber($dbh, $schema, $orgId, substr($year, 2, 2), $reportType);
$alertString = "There is no approved schedule report for the selected fiscal year" if (!(defined($rev)) || $rev < "1");
if (defined($emailAddress) && $emailAddress ne "" && $emailAddress ne "?") {
	if ($reportType eq "INTERNAL" && defined($rev) && $rev >= "1") {
		eval {
			&MailInternalSchedule($year, $internalAuditType, $schema, $dbh, $emailAddress, $isApproverReport);
		};	
	}
	elsif ($reportType eq "EXTERNAL" && defined($rev) && $rev >= "1") {
		eval {
			&MailExternalSchedule($year, $schema, $dbh, $emailAddress, $isApproverReport);
		};
	}
}
&NQS_disconnect($dbh);
print <<END_of_Multiline_Text;
Content-type: text/html

<html>
<head>
END_of_Multiline_Text
if ($@) {
	&display_error($dbh, 'email report to user');
	&log_nqs_error($dbh, $schema, 'T', $userid, "($username) $@");
}	
print "<!--script src=\"/nqs/javascript/utilities.js\"></script-->\n";
print "<script type=\"text/javascript\">\n";
print "  <!--\n";
print "  alert('$alertString');\n";
print <<END_of_Multiline_Text;
  if (parent == self)  // not in frames, go to login screen.
    {
    location = '/cgi-bin/nqs/login.pl'
    }
  //-->
</script>
</head>
<body background=/nqs/images/background.gif text="#000099" link="#0000ff" vlink="#0000ff" alink="#0000ff" topmargin=0 leftmargin=0>
</body>
</html>
END_of_Multiline_Text

