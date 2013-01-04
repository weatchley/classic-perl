#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/qa/perl/RCS/OQA_WebReports_Lib.pm,v $
#
# $Revision: 1.11 $
#
# $Date: 2003/10/01 16:19:35 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: OQA_WebReports_Lib.pm,v $
# Revision 1.11  2003/10/01 16:19:35  starkeyj
# modified the GenerateAuditHeader subroutine to have two approvers for fy 2004 and greater
#
# Revision 1.10  2003/09/22 17:38:06  starkeyj
# modified the following subroutines:  generateAuditHeader,
# internalSchedule to include OCRWM as an issuing organization
#
# Revision 1.9  2002/07/24 22:19:25  johnsonc
# Created seperate schedule reports for BSCQA and OQA for surveillances, internal audits, and surveillance requests.
# Prompt user if a schedule report is unavailable for a selected fiscal year..
#
# Revision 1.8  2002/04/03 16:53:31  johnsonc
# Coded change to allow row fields in Surveillance Request report to span all columns.
#
# Revision 1.7  2002/04/01 18:34:14  johnsonc
# Change external and internal audit schedule reports to display audit number for a cancelled report.
#
# Revision 1.6  2002/02/11 23:29:56  johnsonc
# Changed report functions so that city and provinces are printed out in proper case.
#
# Revision 1.5  2001/11/07 21:18:02  johnsonc
# Corrected error that was causing multiple organizations and locations  associated with a record in the SurveillanceLog function to be displayed in the margin.
#
# Revision 1.4  2001/11/05 00:35:54  johnsonc
# Fixed problem with the location not displaying with certain records in the
# SurveillanceRequest function.
#
# Revision 1.3  2001/11/03 00:37:57  johnsonc
# Changed code so that audit number does not display if the audit is cancelled
#
# Revision 1.2  2001/11/01 20:29:52  johnsonc
# Minor format changes to reports
#
# Revision 1.1  2001/10/26 19:45:52  johnsonc
# Initial revision
#
# 
package OQA_WebReports_Lib;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use DBI;
use DBD::Oracle qw(:ora_types);
use OQA_Utilities_Lib qw(:Functions);
use Mail_Utilities_Lib qw(:Functions);
use NQS_Header qw(:Constants);
my $NQSTempReportPath = $ENV{'NQSTempReportPath'};
use CGI;
use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (&GenerateAuditHeader &InternalSchedule &SupplierSchedule &GenerateSurveillanceHeader 
              &SurveillanceLog &SurveillanceRequest);
@EXPORT_OK = qw(&GenerateAuditHeader &InternalSchedule &SupplierSchedule &GenerateSurveillanceHeader 
                &SurveillanceLog &SurveillanceRequest);
%EXPORT_TAGS =(
    Functions => [qw(&GenerateAuditHeader &InternalSchedule &SupplierSchedule &GenerateSurveillanceHeader
    						&SurveillanceLog &SurveillanceRequest) ]
);


#########################################################################################################
# Name:                                                                                                 #
#  GenerateAuditHeader                                                                                  #
#                                                                                                       #
# Purpose:																															  #
# 	This function writes the page header for the Audit schedule.                                         #
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The audit schedule year specified in a four digit format	                                   #
#  $reportType - Type of report being specified by the header function. Either Supplier or Internal.    #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #  
#  $schema - Name of the schema                                                                         #
#  $dbh - database handle                                                                               #
#  $filehandle - File handle that inforamtion is written to                                             #
######################################################################################################### 
sub GenerateAuditHeader {

	my $year = $_[0];
	my $reportType = $_[1];
	my $scheduleType = $_[2];
	my $issuedByOrg = $_[3];
	my $schema = $_[4];
	my $dbh = $_[5];
	my $filehandle = $_[6];
	my $sqlString;
	my $date;
	my $dateTime;
	my $header;
	my $rev;
	my $approveDate;
	my $approveDate2;
	my $approver;
	my $approver2;
	my $sqlClause;
	my $queryYear = substr($year, 2, 2);
	$sqlClause = " issuedby_org_id = 28" if ($issuedByOrg eq "OQA");
   	$sqlClause = " issuedby_org_id = 1" if ($issuedByOrg eq "BSCQA");
   	$sqlClause = " issuedby_org_id = 24" if ($issuedByOrg eq "OCRWM");
	my $sth = $dbh->prepare("SELECT TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') FROM DUAL");
	$sth->execute;
	$dateTime = $sth->fetchrow_array;
	
	if ($reportType eq "SUPPLIER") {
		$header = "Fiscal Year-$year Quality Assurance External Audit ";
	}
	else {
		$header = "Fiscal Year-$year $issuedByOrg Internal Audit";
	}
	print $filehandle "<!doctype HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\n";
	print $filehandle "<html>\n<head>\n<meta http-equiv=\"Content-Type\" CONTENT=\"text/html; charset=ISO-8859-1\">\n";
	print $filehandle "<title>$header Schedule</title>\n</head>\n";
	print $filehandle "<body>\n";
	print $filehandle "<center>\n";
	print $filehandle "<h2>OFFICE OF CIVILIAN RADIOACTIVE WASTE MANAGEMENT</h2>\n";
	print $filehandle "<h3>$header Schedule</h3>\n";
	if ($scheduleType eq "ACCEPTED") {
		if ($reportType eq "INTERNAL") {
	    	$sqlString = "SELECT revision, TO_CHAR(approval_date, 'MM/DD/YYYY'), firstname || ' ' || lastname "
	    	             . "FROM $schema.audit_revisions a, $schema.users b WHERE "
	    	             . "a.fiscal_year = $queryYear AND a.revision = (SELECT MAX(revision) FROM "
	    	             . "$schema.internal_audit where fiscal_year = $queryYear AND $sqlClause) "
	    	             . "AND a.approver = b.username";
		}
		else {
	   	$sqlString = "SELECT revision, TO_CHAR(approval_date, 'MM/DD/YYYY'), firstname || ' ' || lastname FROM "
	   	             . "$schema.audit_revisions a, $schema.users b WHERE "
	    	             . "a.fiscal_year = $queryYear and a.revision = (select max(revision) FROM "
	    	             . "$schema.audit_revisions where fiscal_year = $queryYear AND audit_type = 'E') "
	    	             . "AND a.approver = b.username";
		}
		$sth = $dbh->prepare($sqlString);
		$sth->execute;
		($rev, $approveDate, $approver) = $sth->fetchrow_array;
		
	   	if ($year >= 2004) {
           		$sqlString = "SELECT TO_CHAR(approval2_date, 'MM/DD/YYYY'), firstname || ' ' || lastname FROM "
			     . "$schema.audit_revisions a, $schema.users b WHERE "
			     . "a.fiscal_year = $queryYear AND b.username = a.approver2 AND "
			     . "a.revision = (select max(revision) FROM "
			     . "$schema.audit_revisions where fiscal_year = $queryYear AND audit_type = substr('$reportType',0,1)) "
		     	     . "AND a.approver2 = b.username AND audit_type = substr('$reportType',0,1)";
	  		$sth = $dbh->prepare($sqlString);
			$sth->execute;
	   		($approveDate2, $approver2) = $sth->fetchrow_array;
	  	}	   
				
		
		$rev--;
		if (!(defined($rev) && defined($approveDate) && defined($approver))) {
			$rev = $approveDate = $approver = "";
		}
		$approver2 =  defined($approver2) ?  ", " .$approver2 : "";
		print $filehandle "<h3>Revision:&nbsp;$rev<br>Approval Date:&nbsp;&nbsp;$approveDate<br>";
		print $filehandle "Approver:&nbsp;$approver$approver2</h3>\n";
	}
	else {
		print $filehandle "<h3>Revision:&nbsp;Work In Progress</h3>\n"
	}
	print $filehandle "</center>\n";
	print $filehandle "<b>Generated:</b> &nbsp; $dateTime<br>\n";
	print $filehandle "<hr>\n";
	print $filehandle "<table width=\"100%\" border=\"0\" cellspacing=\"5\">\n";
	print $filehandle "<tr>\n";
	if ($reportType eq "SUPPLIER") {
		print $filehandle "<td width=\"15%\" valign=\"top\"><b><font size=2>SUPPLIER</font></b></td>\n";
		print $filehandle "<td width=\"15%\">&nbsp;</td>\n";
	}
	else {
		print $filehandle "<td width=\"15%\"valign=\"top\"><b><font size=2>ORG</font></b></td>\n";
	}
	print $filehandle "<td valign=\"top\"><b><font size=2>LOCATION</font></b></td>\n";
	print $filehandle "<td valign=\"top\"><b><font size=2>NUMBER</font></b></td>\n";
	print $filehandle "<td valign=\"top\"><b><font size=2>DATES</font></b></td>\n";
	print $filehandle "<td valign=\"top\"><b><font size=2>STATUS</font></b></td>\n</tr>\n";
}

#########################################################################################################
# Name:                                                                                                 #
#  InternalSchedule                                                                                     #
#                                                                                                       #
# Purpose:																															  #
# 	This function will write all the audits for a Internal audit schedule for a given fiscal year.       #
#  The two types of schedules that this function will generate are the working or the accepted schedule #
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The audit schedule year specified in a four digit format											     #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #
#  $schema - Name of the schema                                                                         #
#  $dbh - database handle                                                                               #
#  $filehandle - File handle that inforamtion is written to                                             #
######################################################################################################### 

sub InternalSchedule {

	my $year = $_[0];
	my $scheduleType = $_[1];
	my $issuedByOrg = $_[2];
	my $schema = $_[3];
	my $dbh = $_[4];
	my $filehandle = $_[5];
	my $sqlString;
	my ($sth, $sth1, $sth2, $sth3, $sth4);
	my ($id, $rev, $auditType, $auditSeq, $teamLeadId, $teamLead, $teamMembers, $scope, $auditTypeSeq);
	my ($issuedTo, $issuedToId, $completedDate, $forecastDate, $beginDate, $issuedById, $modified);
	my ($orgId, $locId, $org, $city, $state, $province, $rowCount, $endDate, $notes, $cancelled, $sqlClause);
	my $queryYear = substr($year, 2, 2);
   $sqlClause = " issuedby_org_id = 28" if ($issuedByOrg eq "OQA");
   $sqlClause = " issuedby_org_id = 1" if ($issuedByOrg eq "BSCQA");
   $sqlClause = " issuedby_org_id = 24" if ($issuedByOrg eq "OCRWM");
   
	if ($scheduleType eq "ACCEPTED") {
		# Choose the max revision number of all internal audits for the Internal Accepted schedule
		$sqlString = "SELECT id, revision, cancelled, audit_type, audit_seq, team_lead_id, team_members, scope, "
		             . "TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, cancelled, "
		             . "TO_CHAR(completion_date, 'MM/DD/YYYY'), issuedto_org_id, TO_CHAR(forecast_date, 'MM/YYYY'), "
		             . "issuedby_org_id FROM $schema.internal_audit WHERE fiscal_year = $queryYear "
						 . "AND revision = (SELECT MAX(revision) FROM $schema.internal_audit "
						 . "WHERE fiscal_year = $queryYear AND $sqlClause) AND $sqlClause "
						 . "ORDER BY begin_date, end_date, forecast_date";
	}
	else {
		# Select the working copy of all audits for a given fiscal year for the Internal Working schedule
		$sqlString = "SELECT id, revision, cancelled, audit_type, audit_seq, team_lead_id, team_members, scope, "
		             . "TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, cancelled, "
		             . "TO_CHAR(completion_date, 'MM/DD/YYYY'), issuedto_org_id, TO_CHAR(forecast_date, 'MM/YYYY'), "
		             . "issuedby_org_id, modified FROM $schema.internal_audit WHERE fiscal_year = $queryYear "
						 . "AND revision = 0 AND $sqlClause ORDER BY begin_date, end_date, forecast_date";
   }
   $sth1 = $dbh->prepare($sqlString);
   $sth1->execute;
   print $filehandle "<tr>\n<td colspan=\"7\"><hr></td>\n</tr>\n";
	while (($id, $rev, $cancelled, $auditType, $auditSeq, $teamLeadId, $teamMembers, $scope, $beginDate, 
			  $endDate, $notes, $cancelled, $completedDate, $issuedToId, $forecastDate, $issuedById, $modified) = $sth1->fetchrow_array) {
			  
	   # If this is an accepted schedule we must check to see if the working copy has been changed since last approval
		if ($scheduleType eq "ACCEPTED") {
			$sth2 = $dbh->prepare("SELECT modified FROM $schema.internal_audit WHERE id = $id AND "
			                      . "fiscal_year = $queryYear AND revision = 0");
			$sth2->execute;
			$modified = $sth2->fetchrow_array;
		}
	 	if ($auditType =~ /^pb/i) {
	 		$auditTypeSeq = "P";
	 	}
	 	elsif ($auditType =~ /^all/i) {
	 		$auditTypeSeq = "C";
	 	}
	 	else {
	 		$auditTypeSeq = $auditType;
	 	}
	 	$sth2 = $dbh->prepare("SELECT location_id, organization_id FROM $schema.internal_audit_org_loc "
			 						 . "WHERE internal_audit_id = $id AND fiscal_year = $queryYear "
			 						 . "AND revision = $rev ORDER BY organization_id");
		$sth2->execute;
		$rowCount = 0;
		
		# Retrieve locations and organizations for a given audit record 
		while (($locId, $orgId) = $sth2->fetchrow_array) {
			if (defined($orgId)) {
			 	$sth3 = $dbh->prepare("SELECT abbr FROM $schema.organizations WHERE id = $orgId");
			 	$sth3->execute;
			 	$org = $sth3->fetchrow_array;
			}
			else {
				$org = "";
			}
			if (defined($locId)) {
			 	$sth4 = $dbh->prepare("SELECT city, state, province FROM $schema.locations WHERE id = $locId");
			 	$sth4->execute;
			 	($city, $state, $province) = $sth4->fetchrow_array;
			}
			else {
				($city, $state, $province) = "";
			}
			print $filehandle "<tr>\n";
			if ((defined($modified) && $modified eq "Y") && ($rev != 1 || $scheduleType eq "WORKING")) {
				print $filehandle "<td valign=\"top\"><font size=2><b>|&nbsp;</b>";
			}
			else {
				print $filehandle "<td valign=\"top\"><font size=2>";
			}
			if (defined($orgId)) {
				print $filehandle "$org</font></td>\n";
			}
			else {
				print $filehandle "&nbsp;</font></td>\n";
			}
			if (defined($city) && defined($state) && !(defined($province))) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				print $filehandle "<td valign=\"top\"><font size=2>$city,&nbsp;&nbsp;$state</font></td>\n";
			}
			elsif (!(defined($city)) && defined($state) && !(defined($province))) {
				print $filehandle "<td valign=\"top\"><font size=2>$state</font></td>\n";
			}
			elsif (defined($city) && !(defined($state)) && defined($province)) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				print $filehandle "<td valign=\"top\"><font size=2>$city,&nbsp;&nbsp;$province</font></td>\n";
			}
			elsif (defined($city) && !(defined($state)) && !(defined($province))) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				print $filehandle "<td valign=\"top\"><font size=2>$city</font></td>\n";
			}
			elsif (!(defined($city)) && !(defined($state)) && defined($province)) {
				$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				print $filehandle "<td valign=\"top\"><font size=2>$province</font></td>\n";
			}
			else {
				print $filehandle "<td valign=\"top\"><font size=2>&nbsp;</font></td>\n";
			}
			#First row so print $filehandle the audit number, date, and status
			if ($rowCount == 0) {
				if (length($auditSeq) == 1) {
					$auditSeq = "00" . $auditSeq;
				}	
				if (length($auditSeq) == 2) {
					$auditSeq = "0" . $auditSeq;
				}
				if (defined($issuedToId)) {
					$sth = $dbh->prepare("SELECT abbr FROM $schema.organizations WHERE id = $issuedToId");
					$sth->execute;
					$issuedTo = $sth->fetchrow_array;
					$issuedTo .= "-";
				}
				else {
					$issuedTo = "";
				}
			   if ($auditTypeSeq eq "P/PB") {
					$auditTypeSeq = "P";
				}
				if ($auditSeq eq "000" && (!(defined($cancelled)) || (defined($cancelled) && $cancelled eq "N"))) {
					print $filehandle "<td valign=\"top\"><font size=2>To be determined</font></td>\n";
				}
				elsif ($auditSeq ne "000") {
					print $filehandle "<td valign=\"top\"><font size=2>" . $issuedTo . "AR" . "$auditTypeSeq-$queryYear-$auditSeq</font></td>\n";
				}
				else {
					print $filehandle "<td><font size=\"2\">Not applicable</font></td>\n";
				}
				if (defined($beginDate) && defined($endDate) && (!(defined($cancelled)) || defined($cancelled) && $cancelled ne "Y")) {
					print $filehandle "<td valign=\"top\"><font size=2>$beginDate-$endDate</font></td>\n";
				}
				elsif (!(defined($beginDate)) && !(defined($endDate)) && !(defined($cancelled)) && defined($forecastDate)) {
					print $filehandle "<td>$forecastDate</td>\n";
				}
				else {
					print $filehandle "<td>&nbsp;</td>\n";
				}
				if (defined($cancelled) && $cancelled eq "Y") {
					print $filehandle "<td valign=\"top\"><font size=2>CANCELLED</font></td>\n";
				}
				elsif (defined($completedDate)) {
					print $filehandle "<td valign=\"top\"><font size=2>COMPLETE</font></td>\n";
				}
				else {
					print $filehandle "<td>&nbsp;</td>\n";
				}
				print $filehandle "</tr>\n";
			}
			$rowCount++;
		}
		if (defined($teamLeadId) && $teamLeadId != 0) {
			print $filehandle "<tr>\n<td><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Lead:</b></font></td>\n";
			$sth = $dbh->prepare("SELECT firstname || ' ' || lastname FROM $schema.users WHERE id = $teamLeadId");
			$sth->execute;
			$teamLead = $sth->fetchrow_array;
			print $filehandle "<td><font size=2>$teamLead</font></td>\n";
		}
		if (defined($teamMembers)) {
			print $filehandle "<tr>\n<td nowrap><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Members:</b>\n";
			print $filehandle "<td colspan=\"6\"><font size=2>$teamMembers</font></td>\n</tr>\n";
		}
		if (defined($scope)) {
			print $filehandle "<tr>\n<td nowrap valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Scope:</b></font></td>\n";
			print $filehandle "<td valign=\"top\" colspan=\"6\"><font size=2>$scope</font></td>\n</tr>\n";
		}
		if (defined($notes)) {
			print $filehandle "<tr>\n";
			print $filehandle "<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Notes:</b></font></td>\n";
			print $filehandle "<td valign=\"top\" colspan=\"6\"><font size=\"2\">$notes</font></td>\n";
			print $filehandle "</tr>\n";
		}
		print $filehandle "<tr>\n<td colspan=\"7\"><hr></td></tr>\n";
	}
	print $filehandle "</table>\n";
	print $filehandle "<br>\n<hr>\n";
	print $filehandle "</body>\n</html>\n";
}


#########################################################################################################
# Name:                                                                                                 #
#  SupplierSchedule                                                                                     #
#                                                                                                       #
# Purpose:																															  #
# 	This function will write all the audits for a External audit schedule for a given fiscal year.       #
#  The two types of schedules that this function will generate are the working or the accepted schedule #
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The audit schedule year specified in a four digit format											     #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #
#  $schema - Name of the schema                                                                         #
#  $dbh - database handle                                                                               #
#  $filehandle - File handle that inforamtion is written to                                             #
######################################################################################################### 
sub SupplierSchedule {

	my $year = $_[0];
	my $scheduleType = $_[1];
	my $schema = $_[2];
	my $dbh = $_[3];
	my $filehandle = $_[4];
	my $sqlString;
	my ($sth, $sth1, $sth2);
	my ($id, $rev, $auditType, $issuedTo, $auditSeq, $teamLead, $teamMembers, $scope, $scopeSeq);
	my ($teamLeadId, $issuedToId);
	my ($beginDate, $endDate, $notes, $cancelled, $product, $completedDate, $modified, $forecastDate);
	my ($orgId, $locId, $org, $city, $state, $province, $rowCount, $qualifiedSupplierId, $name);
	my $queryYear = substr($year, 2, 2);
	
	if ($scheduleType eq "ACCEPTED") {
		# Choose max revision number of all internal audits for the External Accepted schedule
		$sqlString = "SELECT id, revision, cancelled, audit_type, issuedto_org_id, audit_seq, team_lead_id, "
		             . "team_members, scope, TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, "
		             . "qualified_supplier_id, product, TO_CHAR(completion_date, 'MM/YYYY'), TO_CHAR(forecast_date, 'MM/DD/YYYY') "
		             . "FROM $schema.external_audit WHERE fiscal_year = $queryYear AND revision = (SELECT MAX(revision) FROM "
						 . "$schema.external_audit WHERE fiscal_year = $queryYear) ORDER BY begin_date, forecast_date";
	}
	else {
		# Select the working copy all audits for a given fiscal year for the External Working schedule
		$sqlString = "SELECT id, revision, cancelled, audit_type, issuedto_org_id, audit_seq, team_lead_id, team_members, "
						 . "scope, TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, qualified_supplier_id, product, "
						 . "TO_CHAR(completion_date, 'MM/DD/YYYY'), TO_CHAR(forecast_date, 'MM/YYYY'), modified FROM $schema.external_audit "
						 . "WHERE fiscal_year = $queryYear AND revision = 0 ORDER BY begin_date, forecast_date";
   }
   $sth = $dbh->prepare($sqlString);
   $sth->execute;
   print $filehandle "<tr>\n<td colspan=\"7\"><hr></td>\n</tr>\n";
	while (($id, $rev, $cancelled, $auditType, $issuedToId, $auditSeq, $teamLeadId, $teamMembers, $scope, $beginDate, 
			  $endDate, $notes, $qualifiedSupplierId, $product, $completedDate, $forecastDate, $modified) = $sth->fetchrow_array) {
			  
		# If this is an accepted schedule we must check to see if the working copy has been changed since last approval
		if ($scheduleType eq "ACCEPTED") {
			$sth1 = $dbh->prepare("SELECT modified FROM $schema.external_audit WHERE id = $id AND "
			                      . "fiscal_year = $queryYear AND revision = 0");
			$sth1->execute;
			$modified = $sth1->fetchrow_array;
		}  
	 	print $filehandle "<tr>\n";
	 	if (defined($qualifiedSupplierId)) {
	 		$sth1 = $dbh->prepare("SELECT company_name FROM $schema.qualified_supplier "
					 					 . "WHERE id = $qualifiedSupplierId");
			$sth1->execute;
			$name = $sth1->fetchrow_array;
		}
		if ((defined($modified) && $modified eq "Y") && ($rev != 1 || $scheduleType eq "WORKING")) {
			print $filehandle "<td valign=\"top\" colspan=\"2\"><font size=2>|&nbsp;$name</font></td>\n";
		}
		else {
			print $filehandle "<td valign=\"top\" colspan=\"2\"><font size=2>$name</font></td>\n";
		}
		$sth1 = $dbh->prepare("SELECT location_id FROM $schema.external_audit_locations "
					 				. "WHERE external_audit_id = $id AND fiscal_year = $queryYear "
					 				. "AND revision = $rev");
		$sth1->execute;
		my $rowCount = 0;
		while ($locId = $sth1->fetchrow_array) {
			if ($rowCount > 0) {
				print $filehandle "<td>&nbsp;</td>\n<td>&nbsp;</td>\n";
			}
			$sth2 = $dbh->prepare("SELECT city, state, province FROM $schema.locations "
									 	. "WHERE id = $locId");
			$sth2->execute;
			($city, $state, $province) = $sth2->fetchrow_array;
			if (defined($city) && defined($state) && !(defined($province))) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				print $filehandle "<td valign=\"top\" valign=\"top\"><font size=2>$city,&nbsp;&nbsp;$state</font></td>\n";
			}
			elsif (!(defined($city)) && defined($state) && !(defined($province))) {
				print $filehandle "<td valign=\"top\"><font size=2>$state</font></td>\n";
			}
			elsif (defined($city) && !(defined($state)) && defined($province) ) {
				$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				print $filehandle "<td valign=\"top\"><font size=2>$city,&nbsp;&nbsp;$province</font></td>\n";
			}
			elsif (defined($city) && !(defined($state)) && !(defined($province))) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				print $filehandle "<td valign=\"top\"><font size=2>$city</font></td>\n";
			}
			elsif (!(defined($city)) && !(defined($state)) && defined($province)) {
				$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				print $filehandle "<td valign=\"top\"><font size=2>$province</font></td>\n";
			}
			else {
				print $filehandle "<td valign=\"top\"><font size=2>&nbsp;</font></td>\n";
			}	
		   if ($rowCount == 0) {
				if (length($auditSeq) == 1) {
					$auditSeq = "00" . $auditSeq;
				}	
				if (length($auditSeq) == 2) {
					$auditSeq = "0" . $auditSeq;
				}
				if (defined($issuedToId)) {
					my $sth3 = $dbh->prepare("SELECT abbr FROM $schema.organizations WHERE id = $issuedToId");
					$sth3->execute;
					$issuedTo = $sth3->fetchrow_array;
					$issuedTo .= "-";
				}
				else {
					$issuedTo = "";
				}
				if ($auditSeq eq "000" && (!(defined($cancelled)) || (defined($cancelled) && $cancelled eq "N"))) {
					print $filehandle "<td valign=\"top\"><font size=2>To be determined</font></td>\n";
				}
				elsif ($auditSeq ne "000"){
					print $filehandle "<td valign=\"top\"><font size=\"2\">$issuedTo$auditType-$queryYear-$auditSeq</font></td>\n";
				}
				else {
					print $filehandle "<td><font size=\"2\">Not applicable</font></td>\n";
				}
				if (defined($beginDate) && defined($endDate) && (!(defined($cancelled)) || defined($cancelled) && $cancelled eq "N")) {
					print $filehandle "<td valign=\"top\"><font size=2>$beginDate-$endDate</font></td>\n";
				}
				elsif (!(defined($beginDate)) && !(defined($endDate)) && (!(defined($cancelled)) || defined($cancelled) && $cancelled eq "N") && defined($forecastDate)) {
					print $filehandle "<td valign=\"top\"><font size=2>$forecastDate</font></td>\n";
				}	
				else {
					print $filehandle "<td>&nbsp;</td>\n";
				}
				if (defined($cancelled) && $cancelled eq "Y") {
					print $filehandle "<td valign=\"top\"><font size=2>CANCELLED</font></td>\n";
				}
				elsif (defined($completedDate)) {
					print $filehandle "<td valign=\"top\"><font size=2>COMPLETE</font></td>\n";
				}
				else {
					print $filehandle "<td>&nbsp;</td>\n";
				}
				print $filehandle "</tr>\n";
			}
			$rowCount++;
		}
		print $filehandle "</tr>\n";
		if (defined($teamLeadId) && $teamLeadId != 0) {
			print $filehandle "<tr>\n<td><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Lead:</b></font></td>\n";
			$sth2 = $dbh->prepare("SELECT firstname || ' ' || lastname FROM $schema.users WHERE id = $teamLeadId");
			$sth2->execute;
			$teamLead = $sth2->fetchrow_array;
			print $filehandle "<td><font size=2>$teamLead</font></td>\n</tr>\n";
		}
		if (defined($teamMembers)) {
			print $filehandle "<tr>\n<td nowrap valign=\"top\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Members:</b></td>";
			print $filehandle "<td colspan=\"5\"><font size=2>$teamMembers</font>"
			      . "</td>\n</tr>\n";
		}		  
		if (defined($product)) {
			print $filehandle "<tr>\n";
			print $filehandle "<td valign=\"top\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Product:</b></font></td>\n";
			print $filehandle "<td colspan=\"5\"><font size=2>$product</font></td>\n";
			print $filehandle "</tr>\n";
		}
		if (defined($scope)) {
			print $filehandle "<tr>\n";
			print $filehandle "<td valign=\"top\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Scope:</b></font></td>\n";
			print $filehandle "<td colspan=\"5\"><font size=2>$scope</font></td>\n";
			print $filehandle "</tr>\n";
		}
		if (defined($notes)) {
			print $filehandle "<tr>\n";
			print $filehandle "<td valign=\"top\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Notes:</b></font></td>\n";
			print $filehandle "<td colspan=\"5\"><font size=2>$notes</font></td>\n";
			print $filehandle "</tr>\n";
		}
		print $filehandle "<tr>\n<td colspan=\"6\"><hr></td></tr>\n";
	}
	print $filehandle "</table>\n";
	print $filehandle "<br>\n<hr>\n";
	print $filehandle "</body>\n</html>\n";
}

#########################################################################################################
# Name:                                                                                                 #
#  GenerateSurveillanceHeader                                                                           #
#                                                                                                       #
# Purpose:																															  #
# 	This function writes the page header for the Surveillance schedule.                                  #
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The audit schedule year specified in a four digit format	                                   #
#  $reportType - Type of report being specified by the header function. Either Supplier or Internal.    #
#  $schema - Name of the schema                                                                         #                                                                     #
#  $dbh - database handle                                                                               #
#  $filehandle - File handle that inforamtion is written to                                             #
######################################################################################################### 
sub GenerateSurveillanceHeader {

	my $year = $_[0];
	my $reportType = $_[1];
	my $issuedByOrg = $_[2];
	my $schema = $_[3];
	my $dbh = $_[4];
	my $filehandle = $_[5];
	my $sqlString;
	my $date;
	my $dateTime;
	my $header;
	my $title;
	my $queryYear = substr($year, 2, 2);
	my $sth = $dbh->prepare("SELECT TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') FROM DUAL");
	$sth->execute;
	$dateTime = $sth->fetchrow_array;
	print $filehandle "<!doctype HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\n";
	print $filehandle "<html>\n<head>\n<meta http-equiv=\"Content-Type\" CONTENT=\"text/html; charset=ISO-8859-1\">\n";
	$title = "OCRWM Fiscal Year-$year";
	$title .= " OQA" if ($issuedByOrg eq "OQA");
	$title .= " BSCQA" if ($issuedByOrg eq "BSC");
	if ($reportType eq "LOG") {
		$title .= " Yucca Mountain Surveillance Log";
	}
	else {
		$title .= " Yucca Mountain Surveillance Request List";
	}
	print $filehandle "<title>$title Schedule</title>\n";
	print $filehandle "</head>\n";
	print $filehandle "<body>\n";
	print $filehandle "<center>\n";
	print $filehandle "<h2>OFFICE OF CIVILIAN RADIOACTIVE WASTE MANAGEMENT</h2>\n";
	if ($reportType eq "LOG") {
		print $filehandle "<h3>OCRWM Fiscal Year-$year $issuedByOrg Yucca Mountain Surveillance Log</h3>\n";
		print $filehandle "</center>\n";
		print $filehandle "<b>Generated:</b> &nbsp; $dateTime\n";
		print $filehandle "<br>\n";
		print $filehandle "<hr>\n";
		print $filehandle "<table width=\"100%\" border=\"0\" cellspacing=\"5\">\n";
		print $filehandle "<tr>\n";
		print $filehandle "<td width=\"12%\" valign=\"top\"><b><font size=2>SURVEILLANCE<br>NUMBER</font></b></td>\n";
		print $filehandle "<td width=\"10%\" valign=\"top\"><b><font size=2>ORG</font></b></td>\n";
		print $filehandle "<td width=\"15%\" valign=\"top\"><b><font size=2>LOCATION</font></b></td>\n";
		print $filehandle "<td width=\"10%\" valign=\"top\"><b><font size=2>PROG<br>ELEM</font></b></td>\n";
		print $filehandle "<td width=\"15%\" valign=\"top\"><b><font size=2>DATES</font></b></td>\n";
		print $filehandle "<td width=\"10%\" valign=\"top\"><b><font size=2>DATE<br>COMPLETED</font></b></td>";
		print $filehandle "<td valign=\"top\"><b><font size=2>DEF. DOCS ISSUED</font></b></td>\n</tr>\n";
   }
   else {
   	print $filehandle "<h3>OCRWM Fiscal Year-$year $issuedByOrg Yucca Mountain Surveillance Request List</h3>\n";
   	print $filehandle "</center>\n";
		print $filehandle "<b>Generated:</b> &nbsp; $dateTime\n";
		print $filehandle "<br>\n";
		print $filehandle "<hr>\n";
		print $filehandle "<table width=\"100%\" border=\"0\" cellspacing=\"5\">\n";
		print $filehandle "<tr>\n";	
		print $filehandle "<td width=\"15%\" valign=\"top\"><b><font size=2>ORG</font></b></td>\n";
		print $filehandle "<td width=\"25%\" valign=\"top\"><b><font size=2>LOCATION</font></b></td>\n";
		print $filehandle "<td valign=\"top\"><b><font size=2>REQUESTOR</font></b></td>\n";
		print $filehandle "<td valign=\"top\"><b><font size=2>REQUEST DATE</font></b></td>\n</tr>\n";	
   }
}

#########################################################################################################
# Name:                                                                                                 #
#  SurveillanceLog                                                                                      #
#                                                                                                       #
# Purpose:																															  #
# 	This function will write all the surveillances for a given fiscal year or all the surveillances      #    
#  associated with a particuliar organization for a given fiscal year.                                  #
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The year specified in a four digit format                                                    #
#  $queryOrg - The organization that the surveillances are being retrieved for a given fiscal year.     #
#              If the value is 'ALL' then all organizations that are being surveilled will be           #
#              retrieved for the given fiscal year.                                                     #
#  $schema - Name of the schema                                                                         #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #                                                                        #
#  $dbh - database handle                                                                               #
#  $filehandle - File handle that inforamtion is written to                                             #
######################################################################################################### 
sub SurveillanceLog {

	my $year = $_[0];
	my $issuedToOrg = $_[1];
	my $issuedByOrg = $_[2];
	my $schema = $_[3];
	my $dbh = $_[4];
	my $filehandle = $_[5];
	my $sqlString;
	my $sqlClause;
	my ($sth1, $sth2, $sth3, $sth4, $sth5, $issuedToId, $issuedTo, $teamMembers);
	my ($id, $rev, $teamLeadId, $teamLead, $activity, $beginDate, $notes, $endDate, $cancelled, $status, $docId);
	my ($orgId, $locId, $org, $city, $state, $province, $rowCount, $completedDate, $elements);
	my $queryYear = substr($year, 2, 2);
	my $issuedByOrgId = ($issuedByOrg eq "OQA") ? 28 : 1;
   $sqlClause = " issuedby_org_id = 28" if ($issuedByOrg eq "OQA");
   $sqlClause = " issuedby_org_id = 1" if ($issuedByOrg eq "BSCQA");
   

	# Select all surveillances for a given surveillance year
	$sqlString = "SELECT issuedto_org_id, id, elements, status, team_lead_id, scope, TO_CHAR(begin_date, 'MM/DD/YYYY'), "
		          . "TO_CHAR(end_date, 'MM/DD/YYYY'), TO_CHAR(completion_date, 'MM/DD/YYYY'), "
					 . "notes, cancelled, team_members FROM $schema.surveillance "
					 . "WHERE fiscal_year = $queryYear AND $sqlClause ORDER BY id";

   $sth1 = $dbh->prepare($sqlString);
   $sth1->execute;
   print $filehandle "<tr>\n<td colspan=\"7\"><hr></td>\n</tr>\n";
	while (($issuedToId, $id, $elements, $status, $teamLeadId, $activity, $beginDate, $endDate, $completedDate, 
	        $notes, $cancelled, $teamMembers) = $sth1->fetchrow_array) {
	   if (defined($issuedToId)) {
	 		$sth2 = $dbh->prepare("SELECT abbr FROM $schema.organizations "
			 						 	. "WHERE id = $issuedToId");
			$sth2->execute;
			$issuedTo = $sth2->fetchrow_array . "-";
		}
		else {
			$issuedTo = "";
			$issuedToId = 0;
		}
		
	 	$sth2 = $dbh->prepare("SELECT location_id, organization_id FROM $schema.surveillance_org_loc "
			 						 . "WHERE surveillance_id = $id AND fiscal_year = $queryYear");
		$sth2->execute;
		if (length($id) == 1) {
			$id = "00" . $id;
		}	
		if (length($id) == 2) {
			$id = "0" . $id;
		}
		print $filehandle "<tr>\n<td valign=\"top\"><font size=2>$issuedTo$queryYear-$id</font></td>\n";
		$rowCount = 0;
		while (($locId, $orgId) = $sth2->fetchrow_array) {
			if (defined($orgId)) {
			 	$sth3 = $dbh->prepare("SELECT abbr FROM $schema.organizations WHERE id = $orgId");
			 	$sth3->execute;
			 	$org = $sth3->fetchrow_array;
			}
			if (defined($locId)) {
			 	$sth4 = $dbh->prepare("SELECT city, state, province FROM $schema.locations WHERE id = $locId");
			 	$sth4->execute;
			 	($city, $state, $province) = $sth4->fetchrow_array;
			}
			if ($rowCount > 0) {
				print $filehandle "<tr><td valign=\"top\"><font size=2>&nbsp;</font></td>\n";
			}
			if (defined($orgId)) {
				print $filehandle "<td valign=\"top\"><font size=2>$org</font></td>\n";
			}
			else {
				print $filehandle "<td valign=\"top\"><font size=2>&nbsp;</font></td>\n";
			}
			if (defined($city) && defined($state) && !(defined($province))) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				print $filehandle  "<td valign=\"top\"><font size=2>$city,&nbsp;&nbsp;$state</font></td>\n";
			}
			elsif (!(defined($city)) && defined($state) && !(defined($province))) {
				print $filehandle  "<td valign=\"top\"><font size=2>$state</font></td>\n";
			}
			elsif (defined($city) && !(defined($state)) && defined($province) ) {
				$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				print $filehandle "<td valign=\"top\"><font size=2>$city,&nbsp;&nbsp;$province</font></td>\n";
			}
			elsif (defined($city) && !(defined($state)) && !(defined($province))) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				print $filehandle "<td valign=\"top\"><font size=2>$city</font></td>\n";
			}
			elsif (!(defined($city)) && !(defined($state)) && defined($province)) {
				$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				print $filehandle "<td valign=\"top\"><font size=2>$province</font></td>\n";
			}
			else {
				print $filehandle "<td valign=\"top\"><font size=2>&nbsp;</font></td>\n";
			}	
			if ($rowCount == 0) {
				if (defined($elements)) {
					print $filehandle "<td valign=\"top\"><font size=2>$elements</font></td>\n";
				}
				if (defined($cancelled) && $cancelled eq "Y") {
					print $filehandle "<td valign=\"top\"><font size=2>CANCELLED</font></td>\n";
				}
				elsif (defined($beginDate) && defined($endDate)) {
					print $filehandle "<td valign=\"top\"><font size=2>$beginDate-$endDate</font></td>\n";
				}
				else {
					print $filehandle "<td>&nbsp;</td>\n";
				}
				if (defined($completedDate)) {
					print $filehandle "<td valign=\"top\"><font size=2>$completedDate</font></td>\n";
				}
				else {
					print $filehandle "<td valign=\"top\"><font size=2>&nbsp;</font></td>\n";
				}
				$sth5 = $dbh->prepare("SELECT deficiency FROM $schema.surveillance_deficiencies "
				                      . "WHERE surveillance_id = $id "
											 . "AND fiscal_year = $queryYear AND issuedto_org_id = $issuedToId");
				$sth5->execute;
				print $filehandle "<td valign=\"top\"><font size=2>";
				while ($docId = $sth5->fetchrow_array) {
					print $filehandle "-$docId<br>";
				}
				print $filehandle "</font></td>\n";
			}
			else {
				print $filehandle "</tr>\n";
			}
			$rowCount++;
		}
		print $filehandle "</tr>\n";
		if (defined($teamLeadId) && $teamLeadId != 0) {
			$sth3 = $dbh->prepare("SELECT firstname || ' ' || lastname FROM $schema.users WHERE id = $teamLeadId");
			$sth3->execute;
			$teamLead = $sth3->fetchrow_array;
			print $filehandle "<tr>\n<td colspan=\"1\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Lead:</b></font></td>\n";
			print $filehandle "<td colspan=\"6\"><font size=2>$teamLead</font></td>\n</tr>\n";
		}
		if (defined($teamMembers)) {
			print $filehandle "<tr>\n<td colspan=\"1\" valign=\"top\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Team ";
			print $filehandle "<br>&nbsp;&nbsp;&nbsp;&nbsp;Members:</b></font></td>\n";
			print $filehandle "<td colspan=\"6\" valign=\"top\"><font size=\"2\">$teamMembers</font></td>\n</tr>\n";
		}
		if (defined($activity)) {
			print $filehandle "<tr>\n<td colspan=\"1\" valign=\"top\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Scope:</b></font></td>\n";
			print $filehandle "<td colspan=\"6\"><font size=\"2\">$activity</font></td>\n</tr>\n";
		}
		if (defined($status)) {
			print $filehandle "<tr>\n<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Status:</b></font></td>\n";
			print $filehandle "<td colspan=\"6\"><font size=\"2\">$status</font></td>\n</tr>\n";
		}
		if (defined($notes)) {
			print $filehandle "<tr>\n<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Notes:</b></font></td>\n";
			print $filehandle "<td colspan=\"6\"><font size=\"2\">$notes</font></td>\n</tr>\n";
		}		
		print $filehandle "<tr>\n<td colspan=\"7\"><hr></td></tr>\n";
	}
	print $filehandle "</table>\n";
	print $filehandle "<br>\n<hr>\n";
	print $filehandle "</body>\n</html>\n";
}


#########################################################################################################
# Name:                                                                                                 #
#  SurveillanceRequest                                                                                  #
#                                                                                                       #
# Purpose:																															  #
# 	This function will write all the audits for a External audit schedule for a given fiscal year.       #
#  The two types of schedules that this function will generate are the working or the accepted schedule #
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The audit schedule year specified in a four digit format											     #
#  $schema - Name of the schema                                                                         #                                                                   #
#  $dbh - database handle                                                                               #
#  $filehandle - File handle that inforamtion is written to                                             #
######################################################################################################### 
sub SurveillanceRequest {

	my $year = $_[0];
	my $issuedByOrg = $_[1];
	my $schema = $_[2];
	my $dbh = $_[3];
	my $filehandle = $_[4];
	my $sqlString;
	my ($sth, $sth1);
	my ($reqId, $survId, $reasonForRequest, $requestor, $requestDate, $subjectDetail, $subjectLine, $disaprovalRationale);
	my ($beginDate, $teamLeadId, $org, $displayId, $issuedToId, $teamLead, $issuedToOrg, $city, $state, $province);
	my $sqlClause;
	my $queryYear = substr($year, 2, 2);
	my $issuedByOrgId = ($issuedByOrg eq "OQA") ? 28 : 1;
   $sqlClause = " issuedby_org_id = 28" if ($issuedByOrg eq "OQA");
   $sqlClause = " issuedby_org_id = 1" if ($issuedByOrg eq "BSCQA");
   
	$sqlString = "SELECT id, surveillance_id, reason_for_request, requestor, TO_CHAR(request_date, 'MM/DD/YYYY'), "
	             . "subject_detail, subject_line, disapproval_rationale FROM $schema.surveillance_request "
					 . "WHERE fiscal_year = $queryYear AND $sqlClause ORDER BY id";
   $sth = $dbh->prepare($sqlString);
   $sth->execute;
   print $filehandle "<tr>\n<td colspan=\"4\"><hr></td>\n</tr>\n";
   while (($reqId, $survId, $reasonForRequest, $requestor, $requestDate, $subjectDetail, $subjectLine, $disaprovalRationale) 
           = $sth->fetchrow_array) {
		$sqlString = "SELECT abbr, city, state, province FROM $schema.request_org_loc a, $schema.organizations b, $schema.locations c "
		   			 . "WHERE a.fiscal_year = $queryYear AND a.request_id = $reqId "
		   			 . "AND b.id = a.organization_id AND c.id = a.location_id";
		$sth1 = $dbh->prepare($sqlString);
		$sth1->execute;
		my $rowCount = 0;
		while (($org, $city, $state, $province) = $sth1->fetchrow_array) {
			print $filehandle "<tr>\n";
			if (defined($org)) {
				print $filehandle "<td><font size=\"2\">$org</font></td>\n";
   		}
   		else {
   			print $filehandle "<td><font size=\"2\">&nbsp;</font></td>\n";
   		}
			if (defined($city) && defined($state) && !(defined($province))) {
				print $filehandle "<td valign=\"top\" valign=\"top\"><font size=2>$city,&nbsp;&nbsp;$state</font></td>\n";
			}
			elsif (!(defined($city)) && defined($state) && !(defined($province))) {
				print $filehandle "<td valign=\"top\"><font size=2>$state</font></td>\n";
			}
			elsif (defined($city) && !(defined($state)) && defined($province) ) {
				print $filehandle "<td valign=\"top\"><font size=2>$city,&nbsp;&nbsp;$province</font></td>\n";
			}
			elsif (defined($city) && !(defined($state)) && !(defined($province))) {
				print $filehandle "<td valign=\"top\"><font size=2>$city</font></td>\n";
			}
			elsif (!(defined($city)) && !(defined($state)) && defined($province)) {
				print $filehandle "<td valign=\"top\"><font size=2>$province</font></td>\n";
			}
			else {
				print $filehandle "<td valign=\"top\"><font size=2>&nbsp;</font></td>\n";
			}	
   		if ($rowCount == 0) {
   			if (defined($requestor)) {
					print $filehandle "<td><font size=\"2\">$requestor</font></td>\n";
				}
				else {
		   		print $filehandle  "<td><font size=\"2\">&nbsp;</font></td>\n";
   			}
   			if (defined($requestDate)) {
					print $filehandle "<td><font size=\"2\">$requestDate</font></td>\n";
				}
				else {
		   		print $filehandle "<td><font size=\"2\">&nbsp;</font></td>\n";
   			}
   		}
   		$rowCount++;
   		print $filehandle  "</tr>\n";
   	}
   	if (defined($reasonForRequest)) {
		   print $filehandle  "<tr>\n<td valign=\"top\" nowrap><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Reason for Request:</b></font>"
		   		. "</td><td colspan=\"3\"><font size=\"2\">$reasonForRequest</font></td></tr>\n";
   	}
   	if (defined($subjectLine)) {
   		print $filehandle "<tr>\n<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Subject Line:</b></font>"
   				. "</td><td colspan=\"3\"><font size=\"2\">$subjectLine</font></td></tr>\n";
   	}
   	if (defined($subjectDetail)) {
		   print $filehandle "<tr>\n<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Subject Detail:</b></font>"
		   		. "</td><td colspan=\"3\"><font size=\"2\">$subjectDetail</font></td></tr>\n";
   	}
   	if (defined($disaprovalRationale)) {
			print $filehandle "<tr>\n<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Disapproval Rationale:</b></font>"
					. "</td><td colspan=\"3\"><font size=\"2\">$disaprovalRationale</font></td></tr>\n";
   	}
		if (defined($survId) && $survId > 0) {
			$sqlString = "SELECT TO_CHAR(begin_date, 'MM/DD/YYYY'), team_lead_id, issuedto_org_id FROM $schema.surveillance "
					   	 . "WHERE fiscal_year = $queryYear AND id = $survId";
			$sth1 = $dbh->prepare($sqlString);
			$sth1->execute;
			($beginDate, $teamLeadId, $issuedToId) = $sth1->fetchrow_array;
		   if (length($survId) == 1) {
				$displayId = "00" . $survId;
			}	
			elsif (length($survId) == 2) {
				$displayId = "0" . $survId;
		   }
		   else {
		   	$displayId = $survId;
		   }
			print $filehandle "<tr>\n<td valign=\"top\" nowrap><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Surveillance Number:</b></font>"
					. "</td><td valign=\"bottom\"><font size=\"2\">$queryYear-$displayId</font></td></tr>\n";
			if (defined($beginDate)) {
				print $filehandle "<tr>\n<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Begin Date:</b></font>"
					. "</td><td><font size=\"2\">$beginDate</font></td></tr>\n";
			}
			if (defined($teamLeadId) && $teamLeadId != 0) {
				$sqlString = "SELECT firstname || ' ' || lastname FROM $schema.users "
								 . "WHERE id = $teamLeadId";
				$sth1 = $dbh->prepare($sqlString);
				$sth1->execute;
				$teamLead = $sth1->fetchrow_array;
				print $filehandle "<tr>\n<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Lead:</b></font>"
						. "</td><td><font size=\"2\">$teamLead</font></td></tr>\n";
			}
		}
   	print $filehandle "<tr><td colspan=\"4\"><hr>\n</td></tr>";
   
   }
	print $filehandle "</table>\n";
	print $filehandle "<br>\n<hr>\n";
	print $filehandle "</body>\n</html>\n";
}


