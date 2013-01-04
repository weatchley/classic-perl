#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/nqs/perl/RCS/reports.pl,v $
#
# $Revision: 1.2 $
#
# $Date: 2001/10/22 17:54:33 $
#
# $Author: starkeyj $
#
# $Locker: johnsonc $
#
# $Log: reports.pl,v $
# Revision 1.2  2001/10/22 17:54:33  starkeyj
# no change, user error with RCS
#
# Revision 1.1  2001/10/19 23:32:19  starkeyj
# Initial revision
#
#
# Revision: $
#

use OQA_Utilities_Lib qw(:Functions);
use NQS_Header qw(:Constants);
use CGI qw(param);
use Env;
my $NQScgi = new CGI;
my $username = defined($NQScgi->param("username")) ? $NQScgi->param("username") : "GUEST";
my $userid = defined($NQScgi->param("userid")) ? $NQScgi->param("userid") : "None";
my $schema = defined($NQScgi->param("schema")) ? $NQScgi->param("schema") : "None";
my $cgiaction = defined($NQScgi->param('cgiaction')) ? $NQScgi->param('cgiaction') : "";
my $year = defined($NQScgi->param('year')) ? $NQScgi->param('year') : "";
my $scheduleType = defined($NQScgi->param('scheduletype')) ? $NQScgi->param('scheduletype') : "";
my $reportType = defined($NQScgi->param('reporttype')) ? $NQScgi->param('reporttype') : "";

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

#Print info common to all cgiactions
print <<END_of_Multiline_Text;
Content-type: text/html

<html>
<head>
<script src="$NQSJavaScriptPath/utilities.js" type="text/javascript"></script>
<meta name=pragma content="no-cache">
<meta name=expires content=0>
<meta http-equiv=expires content=0>
<meta http-equiv=pragma content="no-cache">
<Title>Data Deficiency Tracking</Title>
</head>
<script language="javascript" type="text/javascript">
<!--
	doSetTextImageLabel('Reports');
	
	function submitForm(script, cgiaction) {
		document.$form.cgiaction.value = cgiaction;
		document.$form.action = '$path' + script + '.pl';
		if (script == 'audit_schedule' || script == 'surveillance_schedule') {
		 	var myDate = new Date();
			var winName = myDate.getTime();
			document.$form.target = winName;
			var newwin = window.open("",winName);
			newwin.creator = self;
		}
		if (script == 'email_report') {
			document.$form.target = 'control';
			alert('An e-mail message has been sent to you with the attached report');
		}
		document.$form.submit(); 	
	}
	function submitAudit(reporttype) {
		document.$form.reporttype.value = reporttype;
		submitForm('reports', 'select_params_audit');
	}
	function submitSurveillance(reporttype) {
		document.$form.reporttype.value = reporttype;
		submitForm('reports', 'select_params_surveillance');
	}
	function submitParams(script) {
		submitForm(script, '');
	}
	function submitReport(script, emailaddress) {
		if ($form.scheduletype[1].checked == true && $form.reportopt[1].checked == true) {
			if (emailaddress == '' || emailaddress == '?') {
				alert('You do not have a valid e-mail address in the system.\\n Please contact the system administrator');
			}
			else {
				submitForm('email_report', '');
			}
	   }
	   else {
	   	submitForm('audit_schedule', '');
	   }
	}
	function ReportCheck(username) {
		if ($form.scheduletype[1].checked == true && username != 'GUEST') {
			$form.reportopt[0].disabled = false;
			$form.reportopt[1].disabled = false;
		}
		else {
			$form.reportopt[1].checked = false;
			$form.reportopt[0].checked = true;
			$form.reportopt[0].disabled = true;
			$form.reportopt[1].disabled = true;
		}
	}
//-->
</script>
<body background="$NQSBackground" text="#000099">
<form name="$form" method=post onSubmit=false>
END_of_Multiline_Text



##################################################
if ($cgiaction eq "undefined" || $cgiaction eq "") {
##################################################

print <<END_of_Multiline_Text;
<center>
<table border=0 align=center>
<tr>
  <td valign=top><br><ul><b>Report Options</b>
	<li><a href="javascript:submitForm('reports', 'audit');">Audit Schedule Management Reports</a></li>
  	<li><a href="javascript:submitForm('reports', 'surveillance');">Yucca Surveillance Log Reports</a></li>
  	</ul>
  </td>
</tr>
</table>
</center>
END_of_Multiline_Text
}

#############################
elsif ($cgiaction eq "audit") {
#############################

print <<END_of_Multiline_Text;
<center>
<table border=0 align=center>
<tr>
	<td valign=top><br><ul><b>Audit Schedule Menu</b>
  	<li><a href="javascript:submitAudit('full', 'false');">Full Audit Schedule</a></li>
  	<li><a href="javascript:submitAudit('internal', 'false');">Internal Audit Schedule</a></li>
  	<li><a href="javascript:submitAudit('supplier', 'false');">External Audit Schedule</a></li>
  	</ul>
  </td>
<tr>
</table>
</center>
END_of_Multiline_Text
}

###########################################
elsif ($cgiaction eq "select_params_audit") {
###########################################
my $dbh = &NQS_connect();
$dbh->{LongReadLen} = 1000001;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
my $emailAddress;

print <<END_of_Multiline_Text;
<center>
<table border=0 align=center cellspacing=15>
<tr>
<br>
<td><b>Audit Schedule Options</b></td>
</tr>
<tr>
<td>Fiscal Year:</td>
<td>
<select name=year>
END_of_Multiline_Text

	my $optCount = 1;
	eval {
		my $sth = $dbh->prepare("SELECT fiscal_year FROM $schema.fiscal_year ORDER BY fiscal_year DESC");
		$sth->execute();
		while (my $year = $sth->fetchrow_array()) {
			if ($optCount == 1) {
				print "<option value=$year selected>$year</option>\n";
			}
			else {
				print "<option value=$year>$year</option>\n";
			}
			$optCount++;
		}
		$sth->finish;
	};
	if ($@) {
		&display_error($dbh, 'select users email address');
		&log_nqs_error($dbh, $schema, 'T', $userid, "($username) $@");
	}
	eval {
		$sth = $dbh->prepare("SELECT email FROM $schema.users WHERE id = $userid");
		$sth->execute;
		$emailAddress = $sth->fetchrow_array;
		$sth->finish;
	};
	if ($@) {
		&display_error($dbh, 'select users email address');
		&log_nqs_error($dbh, $schema, 'T', $userid, "($username) $@");
	}
	$emailAddress = "" if (!(defined($emailAddress)));
	
print <<END_of_Multiline_Text;
</td>
</tr>
<tr>
<td>Schedule Type:</td>
<td><input type=radio name=scheduletype value=working checked onClick="ReportCheck('$username')">Current working</td>
<td><input type=radio name=scheduletype value=accepted onClick="ReportCheck('$username')">Latest accepted</td>
</tr>
<tr>
<td>Report Type:</td>
<td><input type=radio name=reportopt value=web disabled checked>Web report</td>
<td><input type=radio name=reportopt value=mail disabled>E-mail report</td>
</tr>
<tr>
<td align=center colspan=3><input type=button name=submit_button value=Submit onClick="submitReport('$script', '$emailAddress')"></td>
</tr>
</table>
</center>
<input type=hidden name=emailaddress value='$emailAddress'>
END_of_Multiline_Text
$sth->finish();
&NQS_disconnect($dbh);
}

####################################
elsif ($cgiaction eq "surveillance") {
####################################

print <<END_of_Multiline_Text;
<center>
<table border=0 align=center>
<tr>
	<td valign=top><br><ul><b>Surveillance Menu</b>
  	<li><a href="javascript:submitSurveillance('log');">YMP Surveillance Log</a></li>
  	<li><a href="javascript:submitSurveillance('request');">Surveillance Request Report</a></li>
  	</ul>
   </td>
<tr>
</table>
</center>
END_of_Multiline_Text
}

##################################################
elsif ($cgiaction eq "select_params_surveillance") {
##################################################
my $dbh = &NQS_connect();
$dbh->{LongReadLen} = 1000001;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction

print <<END_of_Multiline_Text;
<center>
<table border=0 align=center cellspacing=5>
<tr>
<br>
<td><b>Surveillance Schedule Options</b></td>
</tr>
<tr>
<td>Fiscal year:</td>
<td>
<select name=year>
END_of_Multiline_Text
 	eval {
	   my $sth = $dbh->prepare("SELECT fiscal_year FROM $schema.fiscal_year ORDER BY fiscal_year DESC");
	   $sth->execute();
		my $optCount = 1;
		while (my $year = $sth->fetchrow_array()) {
			if ($optCount == 1) {
				print "<option value=$year selected>$year</option>\n";
			}
			else {
				print "<option value=$year>$year</option>\n";
			}
			$optCount++;
		}
		$sth->finish();
	};
	if ($@) {
		&display_error($dbh, 'select fiscal year');
		&log_nqs_error($dbh, $schema, 'T', $userid, "($username) $@");
	}	
print <<END_of_Multiline_Text;
</td>
</tr>
END_of_Multiline_Text

if ($reportType eq "log") {
print <<END_of_Multiline_Text;
<tr>
<td>Organization:</td>
<td>
END_of_Multiline_Text
	eval {
		$sth = $dbh->prepare("SELECT id, abbr FROM $schema.organizations ORDER BY organization");
		$sth->execute();
		while (my ($id, $org) = $sth->fetchrow_array) {
			print "<option value=$id>$org</option>\n";
		}
		$sth->finish();
	};
	if ($@) {
		&display_error($dbh, 'select organization');
		&log_nqs_error($dbh, $schema, 'T', $userid, "($username) $@");
	}
	print "<select name=org>\n";
	print "<option value=0 selected>All</option>\n";

print <<END_of_Multiline_Text;
</td>
</tr>
END_of_Multiline_Text
}

print <<END_of_Multiline_Text;
<tr>
<td align=center colspan=3><input type=button name=submit_button value=Submit onClick="submitParams('surveillance_schedule')"></td>
</tr>
</table>
</center>
END_of_Multiline_Text

&NQS_disconnect($dbh);
}


print <<END_of_Multiline_Text;
<input type=hidden name=cgiaction value='$cgiaction'>
<input type=hidden name=username value='$username'>
<input type=hidden name=userid value='$userid'>
<input type=hidden name=schema value='$schema'>
<input type=hidden name=reporttype value='$reportType'>
</form>
</body>
</html>
END_of_Multiline_Text
