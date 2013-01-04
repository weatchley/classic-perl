#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/qa/perl/RCS/reports.pl,v $
#
# $Revision: 1.25 $
#
# $Date: 2008/10/21 19:00:23 $
#
# $Author: higashis $
#
# $Locker: higashis $
#
# $Log: reports.pl,v $
# Revision 1.25  2008/10/21 19:00:23  higashis
# snapshot of how it is..
#
# Revision 1.24  2008/10/20 17:50:08  higashis
# for excel integrated report.
#
# Revision 1.23  2007/04/12 21:37:33  dattam
# Modified Report screen to add Internal and External Audit Schedule,
# SNL Internal and External Audit Schedule Status and Results,
# YMP SNL Surveillance Log, YMP Surveillance Log Status and Results,
# Added chack box corresponding to SNL
# Javascript function submitTest modified to update the alert signal for SNL
#
# Revision 1.22  2005/10/31 23:30:57  dattam
# Modified writeReportSelect to add new link for Integrated Assessment
# Schedule, Added new cgiaction select_params_PDFtest, Added new
# javascript functions submitPDFtest, submitTest to validate
#
# Revision 1.21  2004/11/01 15:37:05  starkeyj
# modified cgiaction eq undefined to change text for External Audit reports in the Audit Schedule Menu
#
# Revision 1.20  2004/10/21 18:49:58  starkeyj
# modified selection in 'cgiaction eq undefined' to separate OQA and BSC external audits adn to add
# BSC reports to audit schedule menu, and added OneMonth Lookahead to surveillance menu
# modified javascript function submitSurveillanceNoParams to pass lookahead report type
# modified select_params_audit to change label on parameter form
# modified javascript submitAudit to pass report type
#
# Revision 1.19  2004/05/30 22:29:10  starkeyj
# modified the surveillance and audit schedule selection lists to add new reports
# modified selection parameters to remove selection for approved reports
# added section for Report Metrics
# added subroutines getCurrentFiscalDate, getFiscalYears, writeReportDateSelect and writeReportSelect
# to run the metric reports
#
# Revision 1.18  2004/02/19 20:45:54  starkeyj
# added link for EM/RW audit reports
#
# Revision 1.17  2004/02/11 21:17:56  starkeyj
# modified so InProgress report uses an intermediate fiscal year parameter screen
#
# Revision 1.16  2004/02/11 19:45:24  starkeyj
# modified to add surveillance two-week lookahead report link and surveillances in progress report link
#
# Revision 1.15  2003/09/22 17:58:09  starkeyj
# added OCRWM Internal as a parameter and a choice with a link
#
# Revision 1.14  2002/12/09 23:40:48  johnsonc
# bug fix - Error with approver report option displaying for external audit report
#
# Revision 1.13  2002/10/09 23:28:05  johnsonc
# Included 'use strict' pragma in script.
#
# Revision 1.12  2002/09/09 19:21:15  johnsonc
# Added code that allows users to select BSC and OQA schedule reports for internal, surveillance, and surveillance requests (SCREQ00044).
#
# Revision 1.11  2002/03/29 00:00:14  johnsonc
# Added parameter scheduletype to fix the problem with the lastest accepted report not printing
#
# Revision 1.10  2002/02/19 00:57:56  johnsonc
# Implemented change to the reports section of the system that fixed a design flaw that caused the latest accepted radio button to remain checked when the browser back button, followed by the forward button was used to reload the page.
#
# Revision 1.9  2002/02/06 00:51:28  johnsonc
#  Added new option that allows a user to choose whether or not the signature field will appear on a audit scehdule
#
# Revision 1.7  2002/01/08 21:33:23  johnsonc
# Modified the ReportType row in the Audit Schedule Options screen to display only if the Latest Accepted radio button is selected.
#
# Revision 1.6  2001/11/05 16:23:05  starkeyj
# changed background image path
#
# Revision 1.5  2001/11/02 22:39:44  starkeyj
# cosmetic change - removed 'report options' text label
#
# Revision 1.4  2001/11/01 20:29:17  johnsonc
# Changed code that was generating uninitialized variable errors
#
# Revision 1.3  2001/10/27 01:07:19  johnsonc
# dded eval blocks, function call to write to error log, and function to generate javascript alert box on an error
#
# Revision 1.2  2001/10/22 17:54:33  starkeyj
# no change, user error with RCS
#
# Revision 1.1  2001/10/19 23:32:19  starkeyj
# Initial revision
#
#
# Revision: $
#

#use Sections;
use strict;
use OQA_Utilities_Lib qw(:Functions);
use NQS_Header qw(:Constants);
use CGI qw(param);
use Env;

#new ones added for excel reporting 10/9/2008 - sh
use integer;
use OQA_specific;
use OQA_Widgets qw(:Functions);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

#variable declarations
my $NQScgi = new CGI;
my $username = defined($NQScgi->param("username")) ? $NQScgi->param("username") : "GUEST";
my $userid = defined($NQScgi->param("userid")) ? $NQScgi->param("userid") : "None";
my $schema = defined($NQScgi->param("schema")) ? $NQScgi->param("schema") : "None";
my $cgiaction = defined($NQScgi->param('cgiaction')) ? $NQScgi->param('cgiaction') : "";
my $year = defined($NQScgi->param('year')) ? $NQScgi->param('year') : "";
my $scheduleType = defined($NQScgi->param('scheduletype')) ? $NQScgi->param('scheduletype') : "";
my $internalAuditType = defined($NQScgi->param('internalaudittype')) ? $NQScgi->param('internalaudittype') : "";
my $externalAuditType = defined($NQScgi->param('internalaudittype')) ? $NQScgi->param('externalaudittype') : "";
my $reportType = defined($NQScgi->param('reporttype')) ? $NQScgi->param('reporttype') : "";
my $lookaheadType;

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
  if (parent == self)  // not in frames, go to login screen.
    {
    	location = '$NQSCGIDir/login.pl'
    }
	doSetTextImageLabel('Reports');
	
	function submitForm(script, cgiaction) {
		document.$form.cgiaction.value = cgiaction;
		document.$form.action = '$path' + script + '.pl';
	   if (script == 'audit_schedule' || script == 'surveillance_schedule' || script == 'email_report' || script == 'integrated_schedule') {
		   document.$form.target = 'control';
	   }
		document.$form.submit(); 	
	}
	function submitReportForm (script, command, id) {
		document.$form.cgiaction.value = command;
	    document.$form.command.value = command;
	    var myDate = new Date();
		var winName = myDate.getTime();
		document.$form.target = winName;
		var newwin = window.open(\"\",winName);
		newwin.creator = self;
		document.$form.action = 'integrated_audit.pl';		
		document.$form.submit();	    
	}
		function submitReportFormSur (script, command, id) {
		document.$form.cgiaction.value = command;
	    document.$form.command.value = command;
	    var myDate = new Date();
		var winName = myDate.getTime();
		document.$form.target = winName;
		var newwin = window.open(\"\",winName);
		newwin.creator = self;
		document.$form.action = 'integrated_surveillance.pl';	
		document.$form.submit();	    
	}
	function submitAudit(reporttype, audittype) {
		document.$form.target = 'workspace';
		document.$form.reporttype.value = reporttype;
		document.$form.internalaudittype.value = audittype;
		document.$form.externalaudittype.value = audittype;
		submitForm('reports', 'select_params_audit');
	}
	function submitMetricReport(reporttype) {
		document.$form.target = 'workspace';
		document.$form.reporttype.value = reporttype;
		submitForm('metricReports', 'browse');
	}
	function submitSurveillance(reporttype, internalaudittype) {
		document.$form.target = 'workspace';
		document.$form.reporttype.value = reporttype;
		document.$form.internalaudittype.value = internalaudittype;
		submitForm('reports', 'select_params_surveillance');
	}
	function submitSurveillanceNoParams(reporttype,lookaheadtype) {
		document.$form.reporttype.value = reporttype;
		document.$form.lookaheadtype.value = lookaheadtype;
		//document.$form.target = 'control';
		submitForm('surveillance_schedule', '');
	}
	function submitParams(script) {
		submitForm(script, '');
	}
	function clearFY() {
		//document.$form.year.value = '2005';
		document.$form.year.disabled = true;
		document.$form.todate.disabled = false;
		document.$form.fromdate.disabled = false;
	}
	function clearDateRange() {
		document.$form.todate.value = '';
		document.$form.fromdate.value = '';
		document.$form.todate.disabled = true;
		document.$form.fromdate.disabled = true;
		document.$form.year.disabled = false;
	}
	function checkDate(val,e) {
	   var valid = 1;
	   var datestr;
	   var returnvalue = "";

	   if (isBlank(val) || val == null || val == '') {
	   	valid = 0;
		returnvalue = "Please enter a date";	
	   }
	   else {
	   	datestr = val.split("/");
	   	var months = new Array('', "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
	   	if (!(isnumeric(datestr[0])) || !(isnumeric(datestr[1])) || !(isnumeric(datestr[2]))) {
	   		valid = 0;
	   	}
	   	else if (!(datestr[0] > 0 && datestr[0] < 13)) {
			valid = 0;
			returnvalue = datestr[0] + " is not a valid month";
	   	}
	   	else if (datestr[2].length != 2 && datestr[2].length != 4) {
			valid = 0;
			returnvalue = datestr[2] + " is not a valid year";
	   	}
	   	switch (datestr[0]) {
	      		case 4: 
	      		case "4":
	      		case "04":
	      		case 6:
	     	 	case "6":
	      		case "06":
	      		case 9:
	      		case "9":
	      		case "09":
	      		case 11:
	      		case "11":
		 		if (datestr[1] > 30) {
		    			returnvalue = months[datestr[0]] + " only has 30 days";
		 		}
		 		break;
	      		case 2:
	      		case "2":
	      		case "02":
		 	if (isleapyear(datestr[2])) {
		    		returnvalue = (datestr[1] > 29) ? "February " + datestr[2] + " only has 29 days" : "";
		 	} else {
		    		returnvalue = (datestr[1] > 28) ? "February " + datestr[2] + " only has 28 days" : "";
		 	}
		 		break;
	      		default:
		 		if (datestr[1] > 31) {
		    		returnvalue = months[datestr[0]] + " only has 31 days";
		 	}
	   	}
	   }
	   if (!valid || returnvalue != "") {
	   	alert( val + ' is not a valid date\\n' + returnvalue ); }
	   	//e.focus();}
	}
	function isnumeric(s) {
		//if (s.length != 4) return false;
		for(var i = 0; i < s.length; i++) {
		  var c = s.charAt(i);
		  if ((c < '0') || (c > '9')) return false;
		}
		return true;
	}
	function isBlank(s) {
		for (var i=0; i<s.length; i++) {
			var c = s.charAt(i);
			if ((c != ' ') && (c != '\\n') && (c != '\\t') ) {return false;}
		}
		return true;
	}
	function isleapyear(year) {
	  	var returnvalue = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0); 
	  	return (returnvalue);  
	}

	function submitPDFtest(reporttype, audittype) {
		document.$form.target = 'workspace';
		document.$form.reporttype.value = reporttype;
		submitForm('reports', 'select_params_PDFtest');
	}
	function submitXSLReport(){
				document.$form.target = 'workspace';
				document.$form.reporttype.value = 'XSLReport';
				submitForm('reports', 'select_params_XSLReport');
	}
	function submitXSLReportSur(){
				document.$form.target = 'workspace';
				document.$form.reporttype.value = 'XSLReport';
				submitForm('reports', 'select_params_XSLReportSur');
	}
	function submitTest(script) {
	      	if ((!document.$form.ocrwm.checked) && (!document.$form.oqa.checked)
	      	&& (!document.$form.bsc.checked) && (!document.$form.snl.checked) && (!document.$form.other.checked)) {
	      		alert('You must select an organization');
	      	}
	      	else if ((!document.$form.internal.checked) && (!document.$form.external.checked)) {
	      		alert('You must designate a type - internal, external or both');
	      	}
	      	else if ((!document.$form.audit.checked) && (!document.$form.surv.checked)) {
	      		alert('You must choose the schedule type - Audit or Surveillance or both');
	      	}
	      	else if ((document.$form.dateRangeType[1].checked == true) && (isBlank(document.$form.fromdate.value) ||
	      	document.$form.fromdate.value == '' || document.$form.fromdate.value == null) ) {
	      		alert('You must enter a From date for the date range');
	      	}
	      	else if ((document.$form.dateRangeType[1].checked == true) && (isBlank(document.$form.todate.value) ||
	      	document.$form.todate.value == '' || document.$form.todate.value == null) ) {
	      		alert('You must enter a To date for the date range');
	      	}
		else {
			document.$form.cgiaction.value = 'PDFtest';
			submitForm(script, '');		
		}
	}
	function submitReport(emailaddress, userid) {
		if (document.$form.scheduletypeworking.checked == true) {
			document.$form.scheduletype.value = 'working';
		}
		else {
			document.$form.scheduletype.value = 'accepted';
	        }
		//if (userid != 0 && $form.scheduletypeaccepted.checked == true && $form.reportopt[1].checked == true) {
		//	if (emailaddress == '' || emailaddress == '?') {
		//		alert('You do not have a valid e-mail address in the system.\\n Please contact the system administrator');
		//	}
		//	else {
		//		submitForm('email_report', '');
		//	}
	   //}
	   //else {
	   	submitForm('audit_schedule', '');
	  // }
	}
	function rowDisappear() {
	//	document.$form.scheduletypeaccepted.checked = false;
   	document.all.middlerow.style.visibility = "hidden";
   	document.all.approver_data.style.visibility = "hidden";
   	document.$form.scheduletype.value = "working";
	}
 
	function rowAppear(isApprover) {
		document.$form.scheduletypeworking.checked = false;
   	document.all.middlerow.style.visibility = "visible";
   	document.$form.reportopt[0].checked = true;
		document.$form.scheduletype.value = "accepted";
	}
	function approverDisappear() {
   	document.all.approver_data.style.visibility = "hidden";
   	document.$form.approver_report.checked = false;
	}
	function approverAppear(isApprover) {
		if (isApprover == 'TRUE') {
	   	document.all.approver_data.style.visibility = "visible";
	   }
	}
	function resetWorking() {
		document.$form.scheduletypeworking.checked = true; 
		//document.$form.scheduletypeaccepted.checked = false;
		document.$form.scheduletype.value = "working";
	}
	function resetAccepted() {
		document.$form.scheduletypeworking.checked = false; 
		//document.$form.scheduletypeaccepted.checked = true;
		document.$form.scheduletype.value = "accepted";
	}
//-->
</script>
END_of_Multiline_Text
###################################################################################################################################
sub getCurrentFiscalDate{  # routine to get the current fiscal year and month
###################################################################################################################################
    my %args = (
        @_,
    );
    my $currentFiscalyear;
    my $csh = $args{dbh} -> prepare ("select to_char(sysdate,'MM/YYYY') from dual");
    $csh -> execute;
    my $mmyyyy = $csh -> fetchrow_array;
    $csh -> finish;
    
    return($mmyyyy);
}
###################################################################################################################################
sub getFiscalyears{  # routine to get the fiscal years from the database
###################################################################################################################################
    my %args = (
        @_,
    );
    my @years;
    my $csr = $args{dbh} -> prepare ("select fiscal_year from $args{schema}.fiscal_year");
    $csr -> execute;
    
    my $i = 0;
    while (($years[$i]) = $csr->fetchrow_array) {
            $i++;
    }
    
    return(@years);
}
###################################################################################################################################
sub writeReportDateSelect{  # routine to write the month/year select 
###################################################################################################################################
    my %args = (
        @_,
    );
    my $dbh = &NQS_connect();
    my $currentFiscalDate = &getCurrentFiscalDate(dbh=>$dbh);
    my $mm = substr($currentFiscalDate,0,2);
    my $yy = substr($currentFiscalDate,3);
    my @months;
    $months[1]{mm} = 1;
    $months[1]{mon} = "Jan";
    $months[2]{mm} = 2;
    $months[2]{mon} = "Feb";
    $months[3]{mm} = 3;
    $months[3]{mon} = "Mar";
    $months[4]{mm} = 4;
    $months[4]{mon} = "Apr";
    $months[5]{mm} = 5;
    $months[5]{mon} = "May";
    $months[6]{mm} = 6;
    $months[6]{mon} = "Jun";
    $months[7]{mm} = 7;
    $months[7]{mon} = "Jul";
    $months[8]{mm} = 8;
    $months[8]{mon} = "Aug";
    $months[9]{mm} = 9;
    $months[9]{mon} = "Sep";
    $months[10]{mm} = 10;
    $months[10]{mon} = "Oct";
    $months[11]{mm} = 11;
    $months[11]{mon} = "Nov";
    $months[12]{mm} = 12;
    $months[12]{mon} = "Dec";
    
    my $currentFiscalyear = $mm > 9 ? substr($currentFiscalDate,3) + 1 : substr($currentFiscalDate,3);
    my $previousMonth = $mm == 1 ? 12 : $mm - 1;

    my @fiscalyearList = &getFiscalyears(dbh => $dbh, schema => $args{schema}); 
    my $output = "";
    $output .= "<b>Month:</b>&nbsp;&nbsp;\n";
    $output .= "<select name=month size=1>\n";
    for (my $j = 1; $j <= $#months; $j++) {
        $output .= "<option value=$months[$j]{mm} " . (($previousMonth == $months[$j]{mm}) ? "selected" : "") . ">$months[$j]{mon}";
    }
    $output .= "</select>\n&nbsp;&nbsp;&nbsp;";
    $output .= "<b>Fiscal Year:</b>&nbsp;&nbsp;\n";
    $output .= "<select name=fiscalyear size=1>\n";
    for (my $j = 0; $j < $#fiscalyearList; $j++) {
    	$output .= "<option value=$fiscalyearList[$j] " . (($currentFiscalyear == $fiscalyearList[$j]) ? "selected" : "") . ">$fiscalyearList[$j]";
    }
    $output .= "</select>\n";
    &NQS_disconnect($dbh);	
    
    return ($output);
}
###################################################################################################################################
sub writeReportSelect{  # routine to write the report select 
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = <<END_of_Multiline_Text;    
    <b>Report:</b>  <select name=metric_report>
      <option value='Internal_Audit'>Internal Audit
      <option value='OCRWM_Internal_Audit'>OCRWM Internal Audit
      <option value='BSC_Internal_Audit'>BSC Internal Audit
      <option value='OQA_Internal_Audit'>OQA Internal Audit
      <option value='External_Audit'>External Audit
      <option value='BSC_Surveillance'>BSC Surveillance
      <option value='OQA_Surveillance'>OQA Surveillance
      <option value='BSC_Internal_Surveillance'>BSC Internal Surveillance
      <option value='OQA_Internal_Surveillance'>OQA Internal Surveillance
      <option value='BSC_External_Surveillance'>BSC External Surveillance
      <option value='OQA_External_Surveillance'>OQA External Surveillance
    </select>
END_of_Multiline_Text

    return ($output);
}
##################################################
if ($cgiaction eq "undefined" || $cgiaction eq "") {
##################################################

print <<END_of_Multiline_Text;
<body background=$NQSImagePath/background.gif text="#000099">
<form name="$form" method=post onSubmit=false>
<center>
<table border=0 align=center>
<tr>
	<td valign=top><br><ul><b>Audit Schedule Menu</b>
	<li><a href="javascript:submitAudit('internal', 'OCRWM');">OCRWM Internal Audit Schedule</a></li>
	<!--li><a href="javascript:submitAudit('newinternal', 'OCRWM');">OCRWM Internal Audit Schedule Status and Results</a></li-->
   	<!--li><a href="javascript:submitAudit('internal', 'OQA');">OQA Internal Audit Schedule</a></li-->
   	<li><a href="javascript:submitAudit('internal', 'EM');">EM/RW Audit Schedule</a></li>
  	<!--li><a href="javascript:submitAudit('internal', 'BSCQA');">BSCQA Internal Audit Schedule</a></li-->
	<!--li><a href="javascript:submitAudit('newinternal', 'BSCQA');">BSCQA Internal Audit Schedule Status and Results</a></li-->
	<!--li><a href="javascript:submitAudit('internal', 'SNL');">SNL Internal Audit Schedule</a></li-->
	<!--li><a href="javascript:submitAudit('newinternal', 'SNL');">SNL Internal Audit Schedule Status and Results</a></li-->
  	<!--li><a href="javascript:submitAudit('external', 'BSCQA');">BSCQA External Audit Schedule</a></li-->
  	<li><a href="javascript:submitAudit('external', 'BSCQA');">M&O QA External Audit Schedule</a></li>
	<!--li><a href="javascript:submitAudit('newexternal', 'BSCQA');">BSCQA External Audit Schedule Status and Results</a></li-->
	<!--li><a href="javascript:submitAudit('external', 'SNL');">SNL External Audit Schedule</a></li-->
	<li><a href="javascript:submitAudit('external', 'SNL');">Lead Lab QA  External Audit Schedule</a></li>
	<!--li><a href="javascript:submitAudit('newexternal', 'SNL');">SNL External Audit Schedule Status and Results</a></li-->
  	<li><a href="javascript:submitAudit('external', 'OQA');">OQA External Audit Schedule</a></li>
	<!--li><a href="javascript:submitAudit('newexternal', 'OQA');">OQA External Audit Schedule Status and Results</a></li-->
  	<li><a href="javascript:submitAudit('external', '');">External Audit Schedule</a></li>
  	<!--li><a href="javascript:submitAudit('newexternal', '');">External Audit Schedule Status and Results</a></li-->
  </td>
</tr>
<tr>
	<td valign=top><br><ul><b>Surveillance Menu</b>
  	<!--li><a href="javascript:submitSurveillance('log', 'OQA');">YMP OQA Surveillance Log</a></li-->
  	<li><a href="javascript:submitSurveillance('log', 'OQA');">OQA Surveillance Log</a></li>
  	<!--li><a href="javascript:submitSurveillance('newlog', 'OQA');">YMP OQA Surveillance Log Status and Results</a></li-->
  	<!--li><a href="javascript:submitSurveillance('log', 'BSCQA');">YMP BSCQA Surveillance Log</a></li-->
  	<li><a href="javascript:submitSurveillance('log', 'BSCQA');">M&O QA Surveillance Log</a></li>
  	<!--li><a href="javascript:submitSurveillance('newlog', 'BSCQA');">YMP BSCQA Surveillance Log Status and Results</a></li-->
  	<!--li><a href="javascript:submitSurveillance('log', 'SNL');">YMP SNL Surveillance Log</a></li-->
  	<li><a href="javascript:submitSurveillance('log', 'SNL');">Lead Lab QA Surveillance Log</a></li>
  	<!--li><a href="javascript:submitSurveillance('newlog', 'SNL');">YMP SNL Surveillance Log Status and Results</a></li-->
  	<li><a href="javascript:submitSurveillanceNoParams('LOOKAHEAD', 'month');">One Month Look Ahead</a></li>
  	<li><a href="javascript:submitSurveillanceNoParams('LOOKAHEAD', 'twoweeks');">Two Week Look Ahead</a></li>
  	<li><a href="javascript:submitSurveillance('inprogress','');">In Progress</a></li>
  	<!--li><a href="javascript:submitSurveillance('request', 'OQA');">OQA Surveillance Request Report</a></li-->
  	<!--li><a href="javascript:submitSurveillance('request', 'BSCQA');">BSCQA Surveillance Request Report</a></li-->
  	</ul>
   </td>
</tr>
<tr>
	<td valign=top><br><ul><b>Other</b>
	<li><a href="javascript:submitPDFtest('PDFtest', '');">Integrated Assessment Schedule (pdf)</a></li>
	<li><a href="javascript:submitXSLReport();">Integrated Audit Report (Excel)</a></li>
	<li><a href="javascript:submitXSLReportSur();">Integrated Surveillance Report (Excel)</a></li>
	</ul>
   </td>
<!--tr>
	<td valign=top><br><ul><b>Metrics Menu</b>
	
END_of_Multiline_Text
	 print "<br>" . &writeReportDateSelect(schema=>$schema);
	 print "<br>" . &writeReportSelect;
print <<END_of_Multiline_Text2;
   <input type=button onClick=submitForm('metricReports','browse',0); value=Go></td>
<tr-->
</table>
</center>
END_of_Multiline_Text2

}

###########################################
elsif ($cgiaction eq "select_params_audit") {
###########################################
	my $dbh = &NQS_connect();
	$dbh->{LongReadLen} = 1000001;
	$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
	my $emailAddress;
	my %userprivhash = &get_user_privs($dbh,$userid);
	my $isApprover;
	if ((($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'BSC Supplier Administration'} == 1 || $userprivhash{'Supplier Schedule Approver'} == 1) && $reportType eq "external")
	   || (($userprivhash{'BSC Internal Administration'} == 1 || $userprivhash{'BSC Internal Schedule Approver'} == 1 || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'OQA Internal Schedule Approver'} == 1) && $reportType eq "internal") && $reportType ne "full") {
		$isApprover = 'TRUE';
	}
	else {
		$isApprover = 'FALSE';
	}
print "<body background=$NQSImagePath/background.gif text=#000099 " . ($internalAuditType eq "EM" ? "" : "onLoad=resetWorking();") . ">\n";
print <<END_of_Multiline_Text;
<form name="$form" method=post onSubmit=false>
<center>
<table border=0 align=center cellspacing=15>
<tr>
<br>
END_of_Multiline_Text
print "<td colspan=2><b>OQA External Audit Schedule Options</b></td>\n" if ($externalAuditType eq "OQA" && $reportType eq "external");
print "<td colspan=3 align=center><b>BSCQA External Audit Schedule Options</b></td>\n" if ($externalAuditType eq "BSCQA" && $reportType eq "external");
print "<td colspan=3 align=center><b>SNL External Audit Schedule Options</b></td>\n" if ($externalAuditType eq "SNL" && $reportType eq "external");
print "<td colspan=3 align=center><b>OQA Internal Audit Schedule Options</b></td>\n" if ($internalAuditType eq "OQA" && $reportType eq "internal");
print "<td colspan=3 align=center><b>EM/RW Audit Schedule Options</b></td>\n" if ($internalAuditType eq "EM" && $reportType eq "internal");
print "<td colspan=3 align=center><b>BSCQA Internal Audit Schedule Options</b></td>\n" if ($internalAuditType eq "BSCQA" && $reportType eq "internal");
print "<td colspan=3 align=center><b>SNL Internal Audit Schedule Options</b></td>\n" if ($internalAuditType eq "SNL" && $reportType eq "internal");
print "<td colspan=3 align=center><b>OCRWM Internal Audit Schedule Options</b></td>\n" if ($internalAuditType eq "OCRWM" && $reportType eq "internal");
print <<END_of_Multiline_Text;
</tr>
<tr>
<td>Fiscal Year:</td>
<td>
<select name=year>
END_of_Multiline_Text

	my $optCount = 1;
	eval {
 		my $def_yr;
		my $sth = $dbh->prepare ("select to_char(sysdate,'MM/YYYY') from dual");
		$sth->execute;
		my $mmyyyy = $sth->fetchrow_array;
		my $mm = substr($mmyyyy,0,2);
		if ($mm > 9) {
			$def_yr = substr($mmyyyy,3) + 1;
		}
		else { 
			$def_yr = substr($mmyyyy,3); 
		}
		$sth = $dbh->prepare("SELECT fiscal_year FROM $schema.fiscal_year ORDER BY fiscal_year DESC");
		$sth->execute();
		while (my $year = $sth->fetchrow_array()) {
			if ($year == $def_yr) {
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
		&display_error($dbh, 'select fiscal year');
		&log_nqs_error($dbh, $schema, 'T', $userid, "($username) $@");
	}
	eval {
		my $sth = $dbh->prepare("SELECT email FROM $schema.users WHERE id = $userid");
		$sth->execute;
		$emailAddress = $sth->fetchrow_array;
		$sth->finish;
	};
	if ($@) {
		&display_error($dbh, 'select users email address');
		&log_nqs_error($dbh, $schema, 'T', $userid, "($username) $@");
	}
   if (!(defined($emailAddress))) {
   	$emailAddress = "";
   }
	print "</td></tr>\n";

if ($internalAuditType eq "EM") {
	print <<END_of_Multiline_Text;
	<tr>
	<td align=center colspan=4><input type=button name=submit_button value=Submit onClick="submitParams('audit_schedule')"></td>
	</tr>
	</table>
	</center>
END_of_Multiline_Text
} else {
	print "<tr><td colspan=4><input type=hidden name=scheduletypeworking value=working></td>\n";

	print <<END_of_Multiline_Text;
		<td id=approver_data style=visibility:hidden><input type=checkbox name=approver_report value=TRUE>Approver report</td>
		</tr>
		<tr>
		<td align=center colspan=4><input type=button name=submit_button value=Submit onClick="submitReport('$emailAddress', '$userid')"></td>
		</tr>
		</table>
		</center>
		<input type=hidden name=emailaddress value='$emailAddress'>
END_of_Multiline_Text
}
&NQS_disconnect($dbh);
}

##################################################
elsif ($cgiaction eq "select_params_surveillance") {
##################################################
my $dbh = &NQS_connect();
$dbh->{LongReadLen} = 1000001;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction

print <<END_of_Multiline_Text;
<body background=$NQSImagePath/background.gif text="#000099">
<form name="$form" method=post onSubmit=false>
<center>
<table border=0 align=center cellspacing=5>
<tr>
<br>
<td><b>$internalAuditType Surveillance Schedule Options</b></td>
</tr>
<tr>
<td>Fiscal year:</td>
<td>
<select name=year>
END_of_Multiline_Text
 	eval {
 		my $def_yr;
		my $sth = $dbh->prepare ("select to_char(sysdate,'MM/YYYY') from dual");
		$sth->execute;
		my $mmyyyy = $sth->fetchrow_array;
		my $mm = substr($mmyyyy,0,2);
		if ($mm > 9) {
			$def_yr = substr($mmyyyy,3) + 1;
		}
		else { 
			$def_yr = substr($mmyyyy,3); 
		}
	   $sth = $dbh->prepare("SELECT fiscal_year FROM $schema.fiscal_year ORDER BY fiscal_year DESC");
	   $sth->execute();
		my $optCount = 1;
		while (my $year = $sth->fetchrow_array()) {
			if ($year == $def_yr) {
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

if ($reportType eq "log" || $reportType eq "newlog") {
print <<END_of_Multiline_Text;
<tr>
<td>Organization:</td>
<td>
END_of_Multiline_Text
	print "<select name=org>\n";
	eval {
		my $sth = $dbh->prepare("SELECT id, abbr FROM $schema.organizations ORDER BY organization");
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

##################################################
elsif ($cgiaction eq "select_params_PDFtest") {
##################################################

my $dbh = &NQS_connect();
$dbh->{LongReadLen} = 1000001;
$dbh->{LongTruncOk} = 1; 
my $entryBackground = '#ffc0ff';
my $entryForeground = '#000099';
my $emailAddress = "";

  eval {
	 my $def_yr;
	 my $current_year = $dbh -> prepare ("select to_char(sysdate,'MM/YYYY') from dual");
	 $current_year -> execute;
	 my $mmyyyy = $current_year -> fetchrow_array;
	 $current_year -> finish;
	 my $mm = substr($mmyyyy,0,2);
	 if ($mm > 9) {
		$def_yr = substr($mmyyyy,3) + 1;
	 }
	 else { $def_yr = substr($mmyyyy,3); }

	 my $csr = $dbh -> prepare ("select fiscal_year from $schema.fiscal_year order by fiscal_year desc");
	 $csr -> execute;
	 print "<body background=$NQSImagePath/background.gif text=\"#000099\">";
	 print "<form name=\"$form\" method=post onSubmit=false>";
	 print "<tr><td>\n";
	 print "<table cellspacing=5 border=0 align=center><ul>\n";
	 print "<tr><td><b>Integrated Assessment Schedule Options</b></td></tr>\n";
	 print "<br><br>";
	 print "<tr><td><table border=1 rules=none bordercolor=gray cellspacing=0 cellpadding=2>\n";
	 print "<tr><td colspan=2><i>Select a Fiscal Year OR enter a date range</i></td></tr>\n";
	 print "<tr><td colspan=2><b><input type=radio name=dateRangeType value=fiscalyear onClick=clearDateRange() checked>Fiscal Year:&nbsp;&nbsp;</b>";
	 
	 print "<select name=year size=1 >\n";
	 	 my $rows = 0;
	 	 while (my $year = $csr -> fetchrow_array){
	 	 	$rows++;
	 	 	
	 	 	if ($year == $def_yr ){
	 			print "<option selected value=$year>$year\n";
	 		}
	 		else {
	 			print "<option value=$year>$year\n";
	 		}
	 	 }
	 	 $csr -> finish;
	
	 print "</select>\n</td></tr>\n";
	 print "<tr><td><input type=radio name=dateRangeType value=daterange onClick=clearFY()><b>From:&nbsp;</b> <input type=text name=fromdate size=10 onBlur=checkDate(value,this) disabled></td>\n";
	 print "<td><b>To:&nbsp;</b> <input type=text name=todate size=10 onBlur=checkDate(value,this) disabled></td></tr>\n</table></td></tr>\n";
	 
	 
	 print "<tr>\n<td><b><li>Audit</b><input type=checkbox name=audit value=audit checked>&nbsp;&nbsp;\n";
	 print "<b>Surveillance</b><input type=checkbox name=surv value=surv checked></td>\n</tr>";
	 print "<tr><td><b><li>BSC</b><input type=checkbox name=bsc value=bsc checked>&nbsp;&nbsp;\n";
	 print "<b>SNL</b><input type=checkbox name=snl value=snl checked>&nbsp;&nbsp;\n";
	 print "<b>OQA</b><input type=checkbox name=oqa value=oqa checked>&nbsp;&nbsp;\n";
	 print "<b>OCRWM</b><input type=checkbox name=ocrwm value=ocrwm checked>&nbsp;&nbsp;\n";
	 print "<b>Other</b><input type=checkbox name=other value=other checked>&nbsp;&nbsp;\n";
	 print "<tr><td><b><li>Internal<input type=checkbox name=internal value=internal checked>&nbsp;&nbsp;\n";
	 print "<b>External</b><input type=checkbox name=external value=external checked></td>\n</tr>";
	 print "<tr><td><b><li>Display Team Members Column<input type=checkbox name=teamcolumn value=teamcolumn></td></tr>\n";
	 print "<tr><td><b><li>Display Cancelled Assessments<input type=checkbox name=showcancelled value=showcancelled></td></tr>\n";
	 	 
	 	  
	 print "<tr><td align=center colspan=3>\n";
	 #print "<input type=button onClick=submitForm('audit','browse_audits',0); value=\"Go\"></td></tr>\n"; 
	 
	 print "<input type=button name=submit_button value=Submit onClick=\"submitTest('integrated_schedule')\"></td></tr>\n"; 
	 print "</ul></table>\n</td></tr>\n<tr><td height=30> </td></tr>\n";	  
  };
}


##################################################
elsif ($cgiaction eq "select_params_XSLReport") {
##################################################
  my $dbh = &NQS_connect();
  $dbh->{LongReadLen} = 1000001;
  $dbh->{LongTruncOk} = 1; 
  my %userprivhash = &get_user_privs($dbh,$userid);
  my $entryBackground = '#ffc0ff';
  my $entryForeground = '#000099';
  eval {
	 my $def_yr;
	 my $current_year = $dbh -> prepare ("select to_char(sysdate,'MM/YYYY') from dual");
	 $current_year -> execute;
	 my $mmyyyy = $current_year -> fetchrow_array;
	 $current_year -> finish;
	 my $mm = substr($mmyyyy,0,2);
	 if ($mm > 9) {
		$def_yr = substr($mmyyyy,3) + 1;
	 }
	 else { $def_yr = substr($mmyyyy,3); }
	

	 my $csr = $dbh -> prepare ("select fiscal_year from $schema.fiscal_year order by fiscal_year desc");
	 $csr -> execute;
	  print "<body background=$NQSImagePath/background.gif text=\"#000099\">";
	  print "<form name=\"$form\" method=post onSubmit=false>";

	 print "<table cellspacing=5 border=0 align=center><ul>\n";
	 print "<tr><td><b>Excel Integrated View Options for Audits</b></td></tr>\n";
	 	 
	 print "<tr><td><b><li>View&nbsp;&nbsp;\n";
	 print "<select name=audit_selection size=1>\n";
	 print "<option value='internal'>All Internal\n";
	 if ($def_yr < 2008) {
	       print "<option value='internal_ocrwm'>OCRWM Internal\n";
	       print "<option value='internal_snl'>SNL Internal\n";
	       print "<option value='internal_bsc'>BSC Internal\n";
	       print "<option value='internal_oqa'>OQA Internal\n";
	 }
	 print "<option value='internal_em'>EM/RW\n";
	 print "<option value='external'>All External\n";
	 if ($def_yr < 2008) {
	       print "<option value='external_snl'>SNL External\n";
	       print "<option value='external_bsc'>BSC External\n";
	       print "<option value='external_oqa'>OQA External\n";
	 }
	 print "<option selected value='all'>All\n";
	 if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'OQA Supplier Administration'} == 1) {
	 	print "<option value='other'>Other\n";	
	 }
	 print "</select>\n";    
	 print "&nbsp;&nbsp;Audits for Fiscal Year&nbsp;&nbsp;</b>\n";
	 print "<select name=fy size=1 >\n";
	 my $rows = 0;
	 while (my @values = $csr -> fetchrow_array){
	 	$rows++;
	 	my ($fy) = @values;
	 	if ($fy == $def_yr ){
			print "<option selected value=$fy>$fy\n";
		}
		else {
			print "<option value=$fy>$fy\n";
		}
	 }
	 $csr -> finish;
	 print "</select>\n";
	 #print "<input type=button onClick=submitReportForm('audit2','browse',0); value=\"Go\"></td></tr>\n"; 
	 print "<input type=button onClick=submitReportForm('reports','browseXsl',0); value=\"Go\"></td></tr>\n"; 
	  
		 print "<tr><td style=\"font-size:x-small;\">Prior to using this reporting function, be sure to add the current domain (i.e. https://ocrwmgateway.ocrwm.doe.gov)<br>";
	  	 print "in the trusted site in your Internet Explorer as follows:<br>";
	  	 print "1. Go to Tools -> Internet Options -> Security<br>2. Click on \"Trusted Sites\" -> Sites<br>3. Add \"https://ocrwmgateway.ocrwm.doe.gov\". Hit OK <br>4. In \"Custom Level\", under \"Downloads\", be sure that \"Automatic prompting for files downloads\" to be \"Enabled\"</td></tr>\n";
		 
	# print "</ul></table>\n</td></tr>\n<tr><td height=30> </td></tr>\n";	
	 print "</ul></table>\n";	 
	 
  };
  &NQS_disconnect($dbh);
  #exit();
}

##################################################
elsif ($cgiaction eq "select_params_XSLReportSur") {
##################################################
 my $dbh = &NQS_connect();
  $dbh->{LongReadLen} = 1000001;
  $dbh->{LongTruncOk} = 1; 
  my %userprivhash = &get_user_privs($dbh,$userid);
  
  
	my $entryBackground = '#ffc0ff';
	my $entryForeground = '#000099';
   eval {
		 my $def_yr;
		 my $current_year = $dbh -> prepare ("select to_char(sysdate,'MM/YYYY') from dual");
		 $current_year -> execute;
		 my $mmyyyy = $current_year -> fetchrow_array;
		 $current_year -> finish;
		 my $mm = substr($mmyyyy,0,2);
		 if ($mm > 9) {
			$def_yr = substr($mmyyyy,3) + 1;
		 }
		 else { $def_yr = substr($mmyyyy,3); }

		 my $csr = $dbh -> prepare ("select fiscal_year from $schema.fiscal_year order by fiscal_year desc");
		 $csr -> execute;
	     print "<body background=$NQSImagePath/background.gif text=\"#000099\">";
	     print "<form name=\"$form\" method=post onSubmit=false>";
		 
	 	print "<table cellspacing=5 border=0 align=center><ul>\n";
	 	print "<tr><td><b>Excel Integrated View Options for Surveillances</b></td></tr>\n";

		 print "<tr><td><b><li>View&nbsp;&nbsp;\n";
		 print "<select name=surveillance_selection size=1>\n";
		 print "<option value='BSC'>BSC\n";
		 print "<option value='OQA'>OQA\n";
		 print "<option value='SNL'>SNL\n";
		 print "<option selected value='all'>All\n";
	 	 print "</select>\n";    
		 print "&nbsp;Surveillances for Fiscal Year&nbsp;&nbsp;</b>\n";
		 print "<select name=fiscalyear size=1 >\n";
		 my $rows = 0;
		 while (my @values = $csr -> fetchrow_array){
			$rows++;
			my ($fy) = @values;
			if ($fy == $def_yr ){
				print "<option selected value=$fy>$fy\n";
			}
			else {
				print "<option value=$fy>$fy\n";
			}
		 }
		 $csr -> finish;
		 print "</select>\n";
		 #print "<input type=button onClick=submitForm('surveillance2','browse',0); value=\"Go\"></td></tr>\n"; 
		 print "<input type=button onClick=submitReportFormSur('reports','browseXsl',0); value=\"Go\"></td></tr>\n"; 
		 
		 print "<tr><td style=\"font-size:x-small;\">Prior to using this reporting function, be sure to add the current domain (i.e. https://ocrwmgateway.ocrwm.doe.gov)<br>";
	  	 print "in the trusted site in your Internet Explorer as follows:<br>";
	  	 print "1. Go to Tools -> Internet Options -> Security<br>2. Click on \"Trusted Sites\" -> Sites<br>3. Add \"https://ocrwmgateway.ocrwm.doe.gov\". Hit OK <br>4. In \"Custom Level\", under \"Downloads\", be sure that \"Automatic prompting for files downloads\" to be \"Enabled\"</td></tr>\n";
		 
		 print "</ul></table>\n";	 
  };
  &NQS_disconnect($dbh);
  #exit();
}
##################################################
elsif ($cgiaction eq "browse") {
##################################################
}
print <<END_of_Multiline_Text;
<input type=hidden name=cgiaction value='$cgiaction'>
<input type=hidden name=command>
<input type=hidden name=username value='$username'>
<input type=hidden name=userid value='$userid'>
<input type=hidden name=schema value='$schema'>
<input type=hidden name=reporttype value='$reportType'>
<input type=hidden name=lookaheadtype>
<input type=hidden name=scheduletype value='$scheduleType'>
<input type=hidden name=internalaudittype value='$internalAuditType'>
<input type=hidden name=externalaudittype value='$externalAuditType'>
</form>
</body>
</html>
END_of_Multiline_Text
