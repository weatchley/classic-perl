#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/dattam/intradev/rcs/qa/perl/RCS/web_reports.pl,v $
#
# $Revision: 1.11 $
#
# $Date: 2007/10/26 17:54:23 $
#
# $Author: dattam $
#
# $Locker:  $
#
# $Log: web_reports.pl,v $
# Revision 1.11  2007/10/26 17:54:23  dattam
# Added function calls to generate the integrated assessment schedule report for the OCRWM QA internet site.
#
# Revision 1.10  2007/02/02 23:05:50  dattam
# $NQSFullWebReportPath changed for new environment.
#
# Revision 1.9  2005/10/30 23:13:36  starkeyj
# modified filename for supplier schedule to append fy 06
#
# Revision 1.8  2005/10/30 22:56:57  starkeyj
# modified parameters for SupplierSchedule
#
# Revision 1.7  2004/07/04 16:05:08  starkeyj
# Added filename variables for EM/RW report and added subroutine calls for EM/RW reports
#
# Revision 1.6  2003/10/01 16:25:15  starkeyj
# modified the report names and types for fiscal year 2004
#
# Revision 1.5  2002/10/23 22:37:55  johnsonc
# bug fix - Fixed problem with the external audit report and the incorrect audit heading
#
# Revision 1.4  2002/09/09 19:07:19  johnsonc
# Added function calls to generate BSC reports for the OCRWM OQA internet site (SCREQ00044).
#
# Revision 1.3  2002/07/24 22:24:59  johnsonc
# Created seperate schedule reports for BSCQA and OQA for surveillances, internal audits, and surveillance requests.
#
# Revision 1.2  2001/11/01 20:28:08  johnsonc
# Changed code that was generating uninitialized variable errors
#
# Revision 1.1  2001/10/26 19:46:29  johnsonc
# Initial revision
#
#
# 

use OQA_Reports_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use OQA_Utilities_Lib qw(:Functions);
use NQS_Header qw(:Constants);
use IO::File;
use Getopt::Long;
use strict;
my $NQSFullWebReportPath = $ENV{'NQSFullWebReportPath'};
my $schema = $ENV{'SCHEMA'};
my ($internalAcceptedOCRWMFileName,  $internalCurrentOCRWMFileName,  $internalCurrentEMRWFileName);
my ($externalScheduleFileName, $survScheduleBSCQAFileName, $survScheduleOQAFileName, $integratedScheduleFileName);
my ($survReqOQAFileName, $survReqBSCQAFileName, $sth, $sqlString, $year, $filehandle);
#$NQSFullWebReportPath = "/usr/local/www/gov.ymp.intradev/data" . $NQSFullWebReportPath;
$NQSFullWebReportPath = "/usr/local/www/gov.ymp.intra" . (($NQSProductionStatus == 1) ? "net" : "dev") . "/data" . $NQSFullWebReportPath;
&GetOptions("year=s" => \$year,
				"internalAcceptedOCRWMFileName:s" => \$internalAcceptedOCRWMFileName,
				"internalCurrentOCRWMFileName:s" => \$internalCurrentOCRWMFileName,
				"internalCurrentEMRWFileName:s" => \$internalCurrentEMRWFileName,
				"externalScheduleFileName:s" => \$externalScheduleFileName, 
      		"survBSCQAFileName:s" => \$survScheduleBSCQAFileName,
      		"survOQAFileName:s" => \$survScheduleOQAFileName, 
      		"survReqBSCQAFileName:s" => \$survReqBSCQAFileName,
      		"survReqOQAFileName:s" => \$survReqOQAFileName);
if (!(defined($internalAcceptedOCRWMFileName)) ||  $internalAcceptedOCRWMFileName eq '') {
	$internalAcceptedOCRWMFileName = "internal_accepted_ocrwm_schedule.htm";
}
if (!(defined($internalCurrentOCRWMFileName)) || $internalCurrentOCRWMFileName eq '') {
	$internalCurrentOCRWMFileName = "internal_current_ocrwm_schedule.htm";
}
if (!(defined($internalCurrentEMRWFileName)) || $internalCurrentEMRWFileName eq '') {
	$internalCurrentEMRWFileName = "emrw_schedule.htm";
}
if (!(defined($externalScheduleFileName)) || $externalScheduleFileName eq '') {
	$externalScheduleFileName = "external_schedule.htm"; 
}
if (!(defined($survScheduleOQAFileName)) || $survScheduleOQAFileName eq '') {
	$survScheduleOQAFileName = "surveillance_oqa_schedule_07.htm";
}
if (!(defined($integratedScheduleFileName)) || $integratedScheduleFileName eq '') {
	$integratedScheduleFileName = "integrated_schedule.pdf";
}
if (!(defined($survScheduleBSCQAFileName)) || $survScheduleBSCQAFileName eq '') {
	$survScheduleBSCQAFileName = "surveillance_bscqa_schedule.htm";
}
if (!(defined($survReqOQAFileName)) || $survReqOQAFileName eq '') {
	$survReqOQAFileName = "surveillance_request_oqa_schedule.htm";
}
if (!(defined($survReqBSCQAFileName)) || $survReqBSCQAFileName eq '') {
	$survReqBSCQAFileName = "surveillance_request_bscqa_schedule.htm";
}
my $dbh = &NQS_connect();

unlink("$NQSFullWebReportPath/$internalAcceptedOCRWMFileName") if (-e "$NQSFullWebReportPath/$internalAcceptedOCRWMFileName");
$filehandle = new IO::File;
if (!(open ($filehandle, "| ./File_Utilities.pl --command=writeFile --fullFilePath="
	. "$NQSFullWebReportPath/$internalAcceptedOCRWMFileName --protection=0777"))) {
	die "Unable to open output file $NQSFullWebReportPath/$internalAcceptedOCRWMFileName";
}
print $filehandle &GenerateAuditHeader($year, "INTERNAL", "ACCEPTED", "OCRWM", $schema, $dbh);
print $filehandle &InternalSchedule($year, "ACCEPTED", "OCRWM", $schema, $dbh);
$filehandle->close;

#unlink("$NQSFullWebReportPath/$internalAcceptedOQAFileName") if (-e "$NQSFullWebReportPath/$internalAcceptedOQAFileName");
#$filehandle = new IO::File;
#if (!(open ($filehandle, "| ./File_Utilities.pl --command=writeFile --fullFilePath="
#	. "$NQSFullWebReportPath/$internalAcceptedOQAFileName --protection=0777"))) {
#	die "Unable to open output file $NQSFullWebReportPath/$internalAcceptedOQAFileName";
#}
#print $filehandle &GenerateAuditHeader($year, "INTERNAL", "ACCEPTED", "OQA", $schema, $dbh);
#print $filehandle &InternalSchedule($year, "ACCEPTED", "OQA", $schema, $dbh);
#$filehandle->close;

unlink("$NQSFullWebReportPath/$internalCurrentOCRWMFileName") if (-e "$NQSFullWebReportPath/$internalCurrentOCRWMFileName");
if (!(open ($filehandle, "| ./File_Utilities.pl --command=writeFile --fullFilePath="
	. "$NQSFullWebReportPath/$internalCurrentOCRWMFileName --protection=0777"))) {
	die "Unable to open output file $NQSFullWebReportPath/$internalCurrentOCRWMFileName";
}
print $filehandle &GenerateAuditHeader($year, "INTERNAL", "WORKING", "OCRWM", $schema, $dbh);
print $filehandle &InternalSchedule($year, "WORKING", "OCRWM", $schema, $dbh);
$filehandle->close;

unlink("$NQSFullWebReportPath/$internalCurrentEMRWFileName") if (-e "$NQSFullWebReportPath/$internalCurrentEMRWFileName");
if (!(open ($filehandle, "| ./File_Utilities.pl --command=writeFile --fullFilePath="
	. "$NQSFullWebReportPath/$internalCurrentEMRWFileName --protection=0777"))) {
	die "Unable to open output file $NQSFullWebReportPath/$internalCurrentEMRWFileName";
}
print $filehandle &GenerateAuditHeader($year, "INTERNAL", "WORKING", "EM", $schema, $dbh);
print $filehandle &InternalSchedule($year, "WORKING", "EM", $schema, $dbh);
$filehandle->close;

#unlink("$NQSFullWebReportPath/$internalCurrentOQAFileName") if (-e "$NQSFullWebReportPath/$internalCurrentOQAFileName");
#if (!(open ($filehandle, "| ./File_Utilities.pl --command=writeFile --fullFilePath="
#	. "$NQSFullWebReportPath/$internalCurrentOQAFileName --protection=0777"))) {
#	die "Unable to open output file $NQSFullWebReportPath/$internalCurrentOQAFileName";
#}
#print $filehandle &GenerateAuditHeader($year, "INTERNAL", "WORKING", "OQA", $schema, $dbh);
#print $filehandle &InternalSchedule($year, "WORKING", "OQA", $schema, $dbh);
#$filehandle->close;

unlink("$NQSFullWebReportPath/$externalScheduleFileName") if (-e "$NQSFullWebReportPath/$externalScheduleFileName");
if (!(open ($filehandle, "| ./File_Utilities.pl --command=writeFile --fullFilePath="
	. "$NQSFullWebReportPath/$externalScheduleFileName --protection=0777"))) {
	die "Unable to open output file $NQSFullWebReportPath/$externalScheduleFileName";
}
print $filehandle &GenerateAuditHeader($year, "EXTERNAL", "WORKING", "", $schema, $dbh);
print $filehandle &SupplierSchedule($year, "WORKING", "OQA", $schema, $dbh);
$filehandle->close;
	
unlink("$NQSFullWebReportPath/$survScheduleOQAFileName") if (-e "$NQSFullWebReportPath/$survScheduleOQAFileName");
if (!(open ($filehandle, "| ./File_Utilities.pl --command=writeFile --fullFilePath="
	. "$NQSFullWebReportPath/$survScheduleOQAFileName --protection=0777"))) {
	die "Unable to open output file $NQSFullWebReportPath/$survScheduleOQAFileName";
}
print $filehandle &GenerateSurveillanceHeader($year, "LOG", "OQA", $schema, $dbh);
print $filehandle &SurveillanceLog($year, 0, "OQA", $schema, $dbh);
$filehandle->close;

unlink("$NQSFullWebReportPath/$integratedScheduleFileName") if (-e "$NQSFullWebReportPath/$integratedScheduleFileName");
if (!(open ($filehandle, "| ./File_Utilities.pl --command=writeFile --fullFilePath="
	. "$NQSFullWebReportPath/$integratedScheduleFileName --protection=0777"))) {
	die "Unable to open output file $NQSFullWebReportPath/$integratedScheduleFileName";
}
print $filehandle &IntegratedPDFReport($year, "", "AUDIT", "SURV", "BSC", "SNL", "OQA", "OCRWM", "OTHER", "INTERNAL", "EXTERNAL", "TEAMCOLUMN", "", "FISCALYEAR", "", "", $schema, $dbh);
$filehandle->close;

unlink("$NQSFullWebReportPath/$survScheduleBSCQAFileName") if (-e "$NQSFullWebReportPath/$survScheduleBSCQAFileName");
if (!(open ($filehandle, "| ./File_Utilities.pl --command=writeFile --fullFilePath="
	. "$NQSFullWebReportPath/$survScheduleBSCQAFileName --protection=0777"))) {
	die "Unable to open output file $NQSFullWebReportPath/$survScheduleBSCQAFileName";
}
print $filehandle &GenerateSurveillanceHeader($year, "LOG", "BSCQA", $schema, $dbh);
print $filehandle &SurveillanceLog($year, 0, "BSCQA", $schema, $dbh);
$filehandle->close;

unlink("$NQSFullWebReportPath/$survReqOQAFileName") if (-e "$NQSFullWebReportPath/$survReqOQAFileName");
if (!(open ($filehandle, "| ./File_Utilities.pl --command=writeFile --fullFilePath="
	. "$NQSFullWebReportPath/$survReqOQAFileName --protection=0777"))) {
	die "Unable to open output file $NQSFullWebReportPath/$survReqOQAFileName";
}
print $filehandle &GenerateSurveillanceHeader($year, "REQUEST", "OQA", $schema, $dbh);
print $filehandle &SurveillanceRequest($year, "OQA", $schema, $dbh);
$filehandle->close;	
	
unlink("$NQSFullWebReportPath/$survReqBSCQAFileName") if (-e "$NQSFullWebReportPath/$survReqBSCQAFileName");
if (!(open ($filehandle, "| ./File_Utilities.pl --command=writeFile --fullFilePath="
	. "$NQSFullWebReportPath/$survReqBSCQAFileName --protection=0777"))) {
	die "Unable to open output file $NQSFullWebReportPath/$survReqBSCQAFileName";
}
print $filehandle &GenerateSurveillanceHeader($year, "REQUEST", "BSCQA", $schema, $dbh);
print $filehandle &SurveillanceRequest($year, "BSCQA", $schema, $dbh);
$filehandle->close;	

&NQS_disconnect($dbh);
exit(0);