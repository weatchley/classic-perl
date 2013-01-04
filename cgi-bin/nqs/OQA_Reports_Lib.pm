#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/dattam/intradev/rcs/qa/perl/RCS/OQA_Reports_Lib.pm,v $
#
# $Revision: 1.51 $
#
# $Date: 2007/10/26 17:45:03 $
#
# $Author: dattam $
#
# $Locker:  $
#
# $Log: OQA_Reports_Lib.pm,v $
# Revision 1.51  2007/10/26 17:45:03  dattam
# Modified integratedPDFReport to add 'Status' field on the second column of the PDF Report.
# Modified integratedPDFReport to show Audits and Surveillances older than 1 month if their status is not "Complete" and not "Cancelled".
# Modified GenerateSurveillanceHeader to remove "PROG ELEM" and "DEF DOCS ISSUED" from the header of the reports.
# Modified writeConditionReport to remove the
#
# "Level" from the CRs Issued.
#
# Revision 1.50  2007/05/21 21:38:31  dattam
# Modified sub IntegratedPDFReport to print $estbegin if it contains null
#
# Revision 1.49  2007/04/23 17:25:15  dattam
# sub NewInternalSchedule, InternalSchedule, NewSupplierSchedule, SupplierSchedule modified to add SNL as an issuedBy Organization
# in the $sqlClause
# sub GenerateNewAuditHeader, GenerateAuditHeader modified to add SNL as an $issuedByOrg
# sub NewSurveillanceLog, SurveillanceLog modified to add SNL in the $issuedByOrgId
# sub getIntegratedList modified to capture SNL Audit and Surveillance data
# Added new subroutine getSupplier2, getOrganizationName
# sub IntegratedPDFReport modified to show the Organization being assessed, remove the Scheduled/Actual column, change Status/Results
# column to Results/Comments, show the report for past one month and future three months from today's date, show today's date to top
# of report page
#
# Revision 1.48  2005/11/09 21:34:12  starkeyj
# modified integratedPDFReport and getIntegratedList to make changes to 'status' display for PDF report
#
# Revision 1.47  2005/11/07 15:50:07  starkeyj
# modified IntegratedPDFReport to set Team Lead to TBD when one is not assigned
#
# Revision 1.46  2005/10/31 23:48:19  dattam
# Use PDF added, Added new subroutines IntegratedPDFReport, formatXLSRow,
# getSysdate, getOrganization2, getLocation2, writeConditionCount, writeStatus,
# getIntegratedList
#
# Revision 1.45  2005/07/12 15:09:16  starkeyj
# Added the subroutine getSuborganiztion and modified newInternalAuditSchedule and newSurveillanceLog
# to call the new subroutine to select and print BSC suborganizations
#
# Revision 1.44  2005/06/03 13:52:53  starkeyj
# modified SupplierSchedule - changed variable name $status to $state in the fetchrow array
#
# Revision 1.43  2005/01/10 00:34:38  starkeyj
# modified the following subroutines to select and display Reschedule information:
# InternalSchedule, NewInternalSchedule, NewSurveillanceLog
#
# Revision 1.42  2004/12/20 16:58:34  starkeyj
# modified writeConditionReport to check for CR Numbers entered as 0 and display the text No CR Issued
#
# Revision 1.41  2004/11/03 19:27:48  starkeyj
# modified supplierSchedule and NewSupplerSchedule to check for and display Cancelled text on cancelled audits
#
# Revision 1.40  2004/11/01 15:36:09  starkeyj
# modified supplierSchedule and NewSupplierSchedule to change the variable $sqlClause and the select statement for external audits
#
# Revision 1.39  2004/10/21 18:45:29  starkeyj
# modified generateAuditHeader, newAuditHeader, and externalAuditHeader to display OQA or BSC type
# modified supplierSchedule and newSupplierSchedule to add parameter issuedBy and modified select statement
# to select either BSC or OQA
# changed subroutine names from GenerateTwoWeekHeader to GenerateLookaheadHeader and TwoWeekLookahead to
# Lookahead becuase now there are two types of lookahead reports
# modified Lookahead and GenerateLookaheadHeader subroutines to add parameter for which type of
# lookahead report is to be generated
# modified supplierSchedule to check for and display reschedule information
#
# Revision 1.38  2004/07/12 20:01:18  starkeyj
# modified newInternalScheduleto pass auditID and generatedfrom parameters in the call to writeConditionReport
# modified newSupplierSchedule to pass auditID and generatedfrom parameters in the call to writeConditionReport
# modified writeConditionReport to pass auditID and generatedfrom parameters to getConditions
# modified getOrganization so bar denoting a data change does not display on reports
# modified supplierSchedule so bar denoting a data change does not display on report
#
# Revision 1.37  2004/05/30 22:34:31  starkeyj
# added the following subroutines for new reports:
# generateNewSurveillanceHeader, NewSurveillanceLog, GenerateNewAuditHeader,NewInternalSchedule,NewSupplierSchedule,
# writeQARD,writeConditionReport
#
# Revision 1.36  2004/02/19 20:40:59  starkeyj
# modified the InternalSchedule and GenerateAuditHeader subroutines to accomodate the EM/RW audits
#
# Revision 1.35  2004/02/11 22:10:58  starkeyj
# modified InProgress report to sort by seq instead of date
#
# Revision 1.34  2004/02/11 21:59:59  starkeyj
# added condition to InProgress report query - check for est begin date as well as begin date
#
# Revision 1.33  2004/02/11 21:16:21  starkeyj
# modified InProgress report and header to use a fiscal year parameter
#
# Revision 1.32  2004/02/11 19:42:37  starkeyj
# modified to add surveillance two-week lookahead report and header and surveillances in progress
# report and header
#
# Revision 1.31  2003/12/02 22:23:31  starkeyj
# modified SurveillanceLog so surveillance report will display the vendor name (SCR 57)
#
# Revision 1.30  2003/10/08 22:18:17  starkeyj
# modified signature blocks on MailInternalSchedule and MailExternalSchedule
#
# Revision 1.29  2003/10/01 17:11:34  starkeyj
# modified bug to the way it was - error was a database column
#
# Revision 1.28  2003/10/01 16:52:43  starkeyj
# modified generateAuditheader to fix bug in query statement
#
# Revision 1.27  2003/10/01 16:12:36  starkeyj
# modified MailInternalSchedule, MailExternalSchedule, and GenerateAuditHeader
# to combine the OQA and BSC internal audits and have two approvers for the
# external schedule - SCR 54
#
# Revision 1.26  2003/09/22 17:28:45  starkeyj
# modified the following subroutines:  generateAuditHeader,
# internalSchedule, and mailInternalSchedule to include
# OCRWM as an issuing organization
#
# Revision 1.25  2002/12/09 23:45:40  johnsonc
# bug fix - Error with approver name displaying properly for internal audit e-mail report.
#
# Revision 1.24  2002/11/04 23:35:33  johnsonc
# Changed the surveillance begin date to display when no end date is defined.
#
# Revision 1.23  2002/10/23 22:53:36  johnsonc
#  bug fix - Fixed error with the surveillance sequence number selection
#
# Revision 1.22  2002/09/24 23:40:31  johnsonc
# bug fix - Fixed problem with selection of correct revision from the audit revisions table for the Internal Audit report header.
#
# Revision 1.21  2002/09/17 19:40:09  johnsonc
# bug fix- The InternalSchedule function was not passing an issuedby_id to the  getInternalAuditId function.
#
# Revision 1.20  2002/09/12 17:21:29  johnsonc
# bug fix - Fixed error with decrementation of revision number and generation of approver name on the internal accepted schedule report.
#
# Revision 1.19  2002/09/10 20:51:36  johnsonc
# bug fix - Fixed error that caused a record to not print the properly if it contained multiple organizations and was preceded by a record with one organization
#
# Revision 1.18  2002/09/09 19:31:52  johnsonc
# Added code to print multiple locations on a line for internal audit schedule reports (SCREQ00045).
#
# Revision 1.17  2002/07/24 22:14:51  johnsonc
# Created seperate schedule reports for BSCQA and OQA for surveillances, internal audits, and surveillance requests.
# Prompt user if a schedule report is unavailable for a selected fiscal year.
#
# Revision 1.16  2002/04/19 20:13:50  johnsonc
# Fixed the problem with the e-mail report attachments not being deleted from the temporary directory
#
# Revision 1.15  2002/04/03 16:55:12  johnsonc
# Coded change to allow row fields in Surveillance Request report to span all columns.
#
# Revision 1.14  2002/04/01 18:36:16  johnsonc
#  Change external and internal audit schedule reports to display audit number for a cancelled report.
#
# Revision 1.13  2002/02/12 17:46:21  johnsonc
# Added regular expression to remove control characters from the team lead field in the internal audit e-mail generation function.
#
# Revision 1.12  2002/02/11 23:17:03  johnsonc
# Added regular expression to remove control characters from the team lead field
#
# Revision 1.11  2002/02/07 21:58:04  johnsonc
# Changed code for proper pagination in generated reports. Made code changes to code so that unitialized variable references are not written to the webserver error log. Changed report functions so that city and provinces are printed out in proper case.
#
# Revision 1.10  2002/01/08 22:16:55  johnsonc
# Changed e-mail reference from NQS to QA.
#
# Revision 1.9  2001/12/18 18:57:47  johnsonc
# Moved "Approved By" heading to the front of the signators field in the MailInternalSchedule and MailExternalSchedule functions.
#
# Revision 1.8  2001/12/18 00:21:51  johnsonc
# Placed signator's title underneath signator's field in MailExternalSchedule
# and MailInternalSchedule functions.
#
# Revision 1.7  2001/12/13 18:04:18  johnsonc
# Changed name under signators field from approver to director.
#
# Revision 1.6  2001/11/05 00:34:29  johnsonc
# Fixed problem with the location not displaying with certain records in the
# SurveillanceRequest function.
#
# Revision 1.5  2001/11/03 00:38:52  johnsonc
#  Changed code so that audit number does not display if the audit is cancelled
#
# Revision 1.4  2001/11/01 20:30:53  johnsonc
# Minor format changes to reports
#
# Revision 1.3  2001/10/27 01:33:35  johnsonc
# Removed date as a parameter to the function calls.
#
# Revision 1.2  2001/10/22 18:07:12  starkeyj
# no change, user error with RCS
#
# Revision 1.1  2001/10/22 14:45:04  starkeyj
# Initial revision
#
#
# Revision: $
#
package OQA_Reports_Lib;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use DBI;
use DBD::Oracle qw(:ora_types);
use OQA_Utilities_Lib qw(:Functions);
use Mail_Utilities_Lib qw(:Functions);
use DBConditionReports qw(:Functions);
use NQS_Header qw(:Constants);
my $NQSTempReportPath = $ENV{'NQSTempReportPath'};
use CGI;
use PDF;
use FileHandle;
use Exporter;
use integer;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (&GenerateAuditHeader &InternalSchedule &SupplierSchedule &GenerateSurveillanceHeader 
              &SurveillanceLog &SurveillanceRequest &InternalScheduleText &MailExternalSchedule
              &GenerateNewSurveillanceHeader &NewSurveillanceLog &GenerateNewAuditHeader
              &NewInternalSchedule &NewSupplierSchedule &IntegratedPDFReport);
@EXPORT_OK = qw(&GenerateAuditHeader &InternalSchedule  &SupplierSchedule &GenerateSurveillanceHeader 
                &SurveillanceLog &SurveillanceRequest &MailInternalSchedule &MailExternalSchedule
                &GenerateLookaheadHeader &Lookahead &GenerateInProgressHeader &InProgress
                &GenerateNewSurveillanceHeader &NewSurveillanceLog &GenerateNewAuditHeader
                &NewInternalSchedule &NewSupplierSchedule &IntegratedPDFReport);
%EXPORT_TAGS =(
    Functions => [qw(&GenerateAuditHeader &InternalSchedule &SupplierSchedule &GenerateSurveillanceHeader
    		&SurveillanceLog &SurveillanceRequest &MailInternalSchedule &MailExternalSchedule
    		&GenerateLookaheadHeader &Lookahead &GenerateInProgressHeader &InProgress
    		&GenerateNewSurveillanceHeader &NewSurveillanceLog &GenerateNewAuditHeader
    		&NewInternalSchedule &NewSupplierSchedule &IntegratedPDFReport) ]
);
###################################################################################################################################
sub formatXLSRow {  # routine to generate a row for spreed sheet output
###################################################################################################################################
    my %args = (
        cols => 0,
        row => "",
        @_,
    );
    
    my $output = '';
    for (my $i=0; $i<$args{cols}; $i++) {
        $args{row}[$i] = ((defined($args{row}[$i])) ? $args{row}[$i] : "");
        $args{row}[$i] =~ s/\n//g;
        $output .= "$args{row}[$i]" . (($i<($args{cols}-1)) ? "\t" : "\n");
#print STDERR "$args{row}[$i], ";
    }
#print STDERR "\n\n";
    return($output);
}

###################################################################################################################################
sub getSysdate {  # routine to generate the current date 
##################################################################
    my %args = (
        @_,
    );
    
    my $sth = $args{dbh}->prepare("SELECT TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') FROM DUAL");
    $sth->execute;
    my $dateTime = $sth->fetchrow_array;
	
    return($dateTime);
	
}

############################
sub getOrgCount {
############################
	my ($dbh, $schema, $id, $rev, $year) = @_;
	my $sql = "SELECT COUNT(organization_id) FROM $schema.internal_audit_org_loc "
			 	 . "WHERE internal_audit_id = $id AND fiscal_year = $year AND revision = $rev";
	my $count = $dbh->selectrow_array($sql);
	return ($count);
}

############################
sub getOrganizationIds {
############################
	my ($dbh, $schema, $id, $rev, $year) = @_;
	my @orgs;
	my $sql = "SELECT organization_id FROM $schema.internal_audit_org_loc "
			 	 . "WHERE internal_audit_id = $id AND fiscal_year = $year "
			 	 . "AND revision = $rev ORDER BY organization_id";
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	while (my $org = $sth->fetchrow_array) {
		unshift @orgs, $org;
	}
	return (@orgs);
}

############################
sub getLocationIds {
############################
	my ($dbh, $schema, $id, $rev, $year) = @_;
	my @locations;
	my $sql = "SELECT location_id FROM $schema.internal_audit_org_loc "
			 	 	. "WHERE internal_audit_id = $id AND fiscal_year = $year "
			 	 	. "AND revision = $rev ORDER BY location_id";
#	print STDERR "$sql\n";
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	while (my $loc = $sth->fetchrow_array) {
		push @locations, $loc;
	}
	return (@locations);
}

############################
sub getOrganization {
############################
	my ($dbh, $schema, $modified, $scheduleType, $rev, $orgId) = @_;
	my $org = "&nbsp;";
	my $string = "<td width=28%><font size=2>";
	if (defined($orgId)) {
		my $sql = "SELECT abbr FROM $schema.organizations WHERE id = $orgId";
		my $sth = $dbh->prepare($sql);
		$sth->execute;
		$org = $sth->fetchrow_array;
	}
	if ((defined($modified) && $scheduleType ne '' && $modified eq "Y") && ($rev != 1 || $scheduleType eq "WORKING")) {
		#$string .= "<b>|&nbsp;</b>"; ##if they go back to on-line approvals, this needs to go back in
	}
	$string .= "$org</font></td>\n";
	return($string);
}

############################
sub getOrganization2 {
############################
	my ($dbh, $schema, $orgId) = @_;
	my $org = "&nbsp;";
	if (defined($orgId)) {
		my $sql = "SELECT abbr FROM $schema.organizations WHERE id = $orgId";
		my $sth = $dbh->prepare($sql);
		$sth->execute;
		$org = $sth->fetchrow_array;
	}
	return($org);
}
############################
sub getOrganizationName {
############################
	my ($dbh, $schema, $orgId) = @_;
	my $org = "&nbsp;";
	my $abbr;
	if (defined($orgId)) {
		my $sql = "SELECT abbr, organization FROM $schema.organizations WHERE id = $orgId";
		my $sth = $dbh->prepare($sql);
		$sth->execute;
	        ($abbr, $org) = $sth->fetchrow_array;
	}
	if ($abbr eq "BSC") {
	    $org = "BSC";
	}
	return($org);
}
############################
sub getSupplier2 {
############################
	my ($dbh, $schema, $orgId) = @_;
	my $org = "&nbsp;";
	if (defined($orgId)) {
		my $sql = "SELECT company_name FROM $schema.qualified_supplier WHERE id = $orgId";
		my $sth = $dbh->prepare($sql);
		$sth->execute;
		$org = $sth->fetchrow_array;
	}
	return($org);
}
############################
sub getLocation {
############################
	my ($dbh, $schema, $locId) = @_;
	my $string =  "";
	if (defined($locId) && $locId ne "") {
		my $sql = "SELECT city, state, province FROM $schema.locations WHERE id = $locId";
		my $sth = $dbh->prepare($sql);
		$sth->execute;
		my ($city, $state, $province) = $sth->fetchrow_array;
		if (defined($city) && defined($state) && !(defined($province))) {
			$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
			$string = "<font size=2>$city,&nbsp;&nbsp;$state</font>";
		}
		elsif (!(defined($city)) && defined($state) && !(defined($province))) {
			$string =  "<font size=2>$state</font>";
		}
		elsif (defined($city) && !(defined($state)) && defined($province) ) {
			$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
			$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
			$string =  "<font size=2>$city,&nbsp;&nbsp;$province</font>";
		}
		elsif (defined($city) && !(defined($state)) && !(defined($province))) {
			$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
			$string =  "<font size=2>$city</font>";
		}
		elsif (!(defined($city)) && !(defined($state)) && defined($province)) {
			$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
			$string =  "<font size=2>$province</font>";
		}
	}
	return($string)
}
############################
sub getLocation2 {
############################
	my ($dbh, $schema, $locId) = @_;
	my $string =  "";
	if (defined($locId) && $locId ne "") {
		my $sql = "SELECT city, state, province FROM $schema.locations WHERE id = $locId";
		my $sth = $dbh->prepare($sql);
		$sth->execute;
		my ($city, $state, $province) = $sth->fetchrow_array;
		if (defined($city) && defined($state) && !(defined($province))) {
			$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
			$string = "$city, $state";
		}
		elsif (!(defined($city)) && defined($state) && !(defined($province))) {
			$string =  "$state";
		}
		elsif (defined($city) && !(defined($state)) && defined($province) ) {
			$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
			$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
			$string =  "$city, $province";
		}
		elsif (defined($city) && !(defined($state)) && !(defined($province))) {
			$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
			$string =  "$city";
		}
		elsif (!(defined($city)) && !(defined($state)) && defined($province)) {
			$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
			$string =  "$province";
		}
	}
	return($string)
}
###################################################################################################################################
sub writeQARD {  # routine to write the QARD elements
###################################################################################################################################
     my %args = (
        qard => '0000000000000000000000000', 
        @_,
     );
     
     my $i = 0;
     my $selected = "";
     my $output = "";
     foreach my $element ("1.0","2.0", "3.0", "4.0", "5.0", "6.0", "7.0", "8.0", "9.0", "10.0", "11.0", "12.0", "13.0",
	"14.0", "15.0", "16.0", "17.0", "18.0", "SI", "SII", "SIII", "SIV", "SV", "App C", "N/A") {
		$output .= (substr($args{qard},$i,1) == 1) ? (($output ne "") ? ", " : "") . "$element" : "";
		$i++;
     }
     return($output);
}
#####################################################################################################
sub writeConditionReport {
#####################################################################################################
    my %args = (
	survID => 0,
	auditID => 0,
	fiscalyear => 50,
	@_,
    );
    my $first = 1;
    my $output = "CRs Issued:&nbsp;&nbsp;";
    my @crList = &getConditions(dbh => $args{dbh}, schema => $args{schema}, auditID => $args{auditID}, survID => $args{survID}, fiscalyear => $args{fiscalyear}, generatedfrom => $args{generatedfrom});
    for (my $i = 0; $i < $#crList; $i++) {
	my ($crid,$crnum,$crlevel,$crsummary,$crdate) = 
	($crList[$i]{crid},$crList[$i]{crnum},$crList[$i]{crlevel},$crList[$i]{crsummary},$crList[$i]{crdate});  
      	#$output .= (($first) ? "" : ";  ") . ($crnum eq '0' ? "No CRs Issued" : "$crnum - Level " . ($crlevel eq 'N' ? "N/A" : "$crlevel"));
      	$output .= (($first) ? "" : ";  ") . ($crnum eq '0' ? "No CRs Issued" : "$crnum");
      	$first = 0;
    }
    return($output);
}
#####################################################################################################
sub writeConditionCount {
#####################################################################################################
    my ($dbh, $schema, $id, $FY, $audittype) = @_;
    my $crlevel;
    my $levelcount;
    my $output = "";
    my $idFY = $FY > 50 ? $FY + 1900 : $FY + 2000;
    
    my $sqlcondition = "SELECT crlevel, count(crlevel) FROM $schema.condition_report";
    $sqlcondition .= " WHERE generatorfy = $idFY AND generatorid = $id AND generatedfrom  = '$audittype'";
    $sqlcondition .= " GROUP BY crlevel ORDER BY crlevel";

    my $sth = ${dbh}->prepare($sqlcondition);
    $sth->execute;
         
    while (($crlevel, $levelcount) = $sth->fetchrow_array) {
            $output .= ($crlevel ne '') ? ((($output ne "") ? ", " : "").(($crlevel eq 'N') ? "No CRs" : "$levelcount$crlevel")) : "";
     }
    
    
    return($output);
}
###################################################################################################################################
sub writeStatus {  # routine to write the displayed status
###################################################################################################################################
     my %args = (
        state => '', 
        @_,
     );
     my $status = ""; 	  	

     #Determine the displayed text for status on audits and surveillances
     if ($args{reschedule}) {$status = "Rescheduled";}
     elsif ($args{cancelled} eq 'Y') {$status = "Cancelled";}
     elsif ($args{state} eq 'Cancelled') {$status = "Cancelled";}
     elsif ($args{completiondate}) {$status = "Report Issued";}
     elsif ($args{state} ne '') {$status = $args{state};}
     #elsif ($args{state} eq 'Field Work Complete') {$status = "Complete";}
     elsif ($args{state} eq 'Complete') {$status = "Complete";}
     #elsif ($args{enddate}) {$status = "Complete";}
     elsif ($args{state} eq 'In Progress') {$status = "In Progress";}
     elsif ($args{begindate} && !$args{enddate}) {$status = "In Progress";}
     elsif ($args{forecast}) {$status = "Scheduled";}
     else {$status = "Scheduled";}
     
     ##In case they want dates sometime
    #Determine the displayed text for status on audits and surveillances
    #if ($args{reschedule}) {$status = "Rescheduled";}
    #elsif ($args{cancelled} eq 'Y') {$status = "Cancelled";}
    #elsif ($args{state} eq 'Cancelled') {$status = "Cancelled";}
    #elsif ($args{completiondate}) {$status = "Report Approved $args{completiondate}";}
    #elsif ($args{state} eq 'Field Work Complete') {$status = "Field Work Complete $args{completiondate}";}
    #elsif ($args{state} eq 'Complete') {$status = "Complete $args{enddate}";}
    #elsif ($args{state} eq 'In Progress') {$status = "In Progress $args{begindate}";}
    #elsif ($args{forecast}) {$status = "Scheduled $args{forecast}";}
    #else {$status = "$args{begindate}";}
     
     return($status);
}
###################################################################################################################################
sub getSuborganization {  # routine to get the suborganizations for a BSC surveillance
###################################################################################################################################
    my %args = (
    	auditID => 0,
        survID => 0,
        fiscalyear => 50,
        @_,
    );
    my @suborganization;
    my $sqlstring = "SELECT o.id, suborg, labid FROM $args{schema}.bsc_suborganizations o,$args{schema}." . (($args{survID}) ? "surveillance_org_loc s " : "internal_audit_org_loc ia ");
    $sqlstring .= "WHERE o.id=s.suborganization_id AND s.fiscal_year = substr($args{fiscalyear},-1,2) AND s.surveillance_id = $args{survID} " if ($args{survID});
    $sqlstring .= "WHERE o.id=ia.suborganization_id AND ia.fiscal_year = substr($args{fiscalyear},-1,2) AND ia.internal_audit_id = $args{auditID} " if ($args{auditID});
    $sqlstring .= "AND ia.revision = 0 " if ($args{auditID});
    $sqlstring .= "order by o.suborg ";

    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($suborganization[$i]{suborgid},$suborganization[$i]{suborg},$suborganization[$i]{labid}) = $csr->fetchrow_array) {
         if ($suborganization[$i]{suborg} eq 'LAB')
	              {
	                 my $sqlstring1 = "SELECT company_name FROM $args{schema}.qualified_supplier qs ";
	                 $sqlstring1 .= "WHERE qs.id = $suborganization[$i]{labid} ";
	                 my $csr1 = $args{dbh}->prepare($sqlstring1);
	                 my $status1 = $csr1->execute;
	                 $suborganization[$i]{suborg} = $csr1->fetchrow_array;
	               }
              
                       $i++;
    }
    
    return(@suborganization);
}

###################################################################################################################################
sub getIntegratedList {  # routine to get the audit and/or surveillance data for integrated assessments
###################################################################################################################################
#my ($year, $scheduleType, $audit, $surv, $bsc, $oqa, $ocrwm, $other, $internal, $external, $teamcolumn, $showcancelled, $schema, $dbh) = @_;
my ($year, $scheduleType, $audit, $surv, $bsc, $snl, $oqa, $ocrwm, $other, $internal, $external, $teamcolumn, $showcancelled, $dateRangeType, $fromdate, $todate, $schema, $dbh) = @_;
my @integratedList;
my $out;
my $sth2;
my @locs;
my $locid;
my $sqlinternal;
my $sqlexternal;
my $sqlcode;
my $sqlclause;
my $sqlsurv;
my $sqlFY;
my $activity_type;
my $queryYear = substr($year, 2, 2);

my $include_bsc = " issuedby_org_id = 1";
my $include_snl = " issuedby_org_id = 33";
my $include_oqa = " issuedby_org_id = 28";
my $include_ocrwm = " issuedby_org_id = 24";
my $include_other = " issuedby_org_id NOT IN (1,24,28,33)";

my $sql_common = "SELECT TO_CHAR(forecast_date, 'MM/YYYY'), TO_CHAR(begin_date, 'MM/DD/YY'), state, id ";
$sql_common .= ",scope, issuedto_org_id, issuedby_org_id, team_lead_id, team_members, TO_CHAR(end_date, 'MM/DD/YY') ";
$sql_common .= ",qard_elements, title, overall_results, overall, fiscal_year,TO_CHAR(completion_date,'MM/DD/YY'), cancelled, reschedule ";
$sql_common .= ",NVL(TO_CHAR(forecast_date, 'YYYY/MM'),TO_CHAR(begin_date, 'YYYY/MM/DD')) ";
my $sql_audit .= ",revision, audit_type,audit_seq, notes, otherid, 'A' , NULL, NULL ";
$sqlFY = ($dateRangeType eq 'FISCALYEAR') ? " fiscal_year = $queryYear " : " (forecast_date BETWEEN TO_DATE('$fromdate','MM/DD/RRRR') AND TO_DATE('$todate','MM/DD/RRRR') OR begin_date BETWEEN TO_DATE('$fromdate','MM/DD/RRRR') AND TO_DATE('$todate','MM/DD/RRRR')) " ;

 if (($bsc ne 'BSC') || ($snl ne 'SNL') || ($oqa ne 'OQA') || ($ocrwm ne 'OCRWM') || ($other ne 'OTHER')) {
      if ($bsc eq 'BSC') {
          $sqlclause = " AND ($include_bsc";
          if ($snl eq 'SNL') {$sqlclause .= " OR $include_snl";}
          if ($oqa eq 'OQA') {$sqlclause .= " OR $include_oqa";}
          if ($ocrwm eq 'OCRWM') {$sqlclause .= " OR $include_ocrwm"; }
          if ($other eq 'OTHER') {$sqlclause .= " OR $include_other"; }
       }
       elsif ($snl eq 'SNL') {
          $sqlclause = " AND ($include_snl ";
          if ($oqa eq 'OQA') {$sqlclause .= " OR $include_oqa";}
          if ($ocrwm eq 'OCRWM') {$sqlclause .= " OR $include_ocrwm"; }
       	  if ($other eq 'OTHER') {$sqlclause .= " OR $include_other";  }
       }
       elsif ($oqa eq 'OQA') {
          $sqlclause = " AND ($include_oqa ";
          if ($ocrwm eq 'OCRWM') {$sqlclause .= " OR $include_ocrwm"; }
	  if ($other eq 'OTHER') {$sqlclause .= " OR $include_other";  }
       }
      elsif ($ocrwm eq 'OCRWM') {
         $sqlclause = " AND ($include_ocrwm ";
         if ($other eq 'OTHER') {$sqlclause .= " OR $include_other"; }
      }
      elsif ($other eq 'OTHER') {
         $sqlclause = " AND ($include_other";
      }
      $sqlclause .= ")";
  }
  $sqlclause .= " AND (NVL(state,'1') != 'Cancelled' AND NVL(cancelled,'1') != 'Y') " if ($showcancelled ne 'SHOWCANCELLED'); # OR cancelled != 'Y') ";
  if ($surv eq 'SURV') {
  	$sqlsurv .= $sql_common . ", int_ext,NULL, NULL, surveillance_seq, status, 'NA', 'S', ";
  	$sqlsurv .= "TO_CHAR(estbegin_date, 'MM/YYYY'), TO_CHAR(estend_date, 'MM/DD/YY') ";
 	$sqlsurv .= "FROM $schema.surveillance WHERE $sqlFY ";
 	$sqlsurv .= (($internal eq 'INTERNAL') && ($external ne 'EXTERNAL')) ? " AND int_ext = 'I'" : "";
 	$sqlsurv .= (($internal ne 'INTERNAL') && ($external eq 'EXTERNAL')) ? " AND int_ext = 'E'" : "";
 	$sqlsurv .= "$sqlclause";
 	#$sqlsurv .= " order by TO_CHAR(estbegin_date, 'MM/YYYY') ";
  }
  if ($audit eq 'AUDIT') {            
        $sqlinternal .= $sql_common . ",'I' ". $sql_audit ;
    	$sqlinternal .= "from internal_audit where $sqlFY  and revision = 0 ";
    	$sqlinternal .= "$sqlclause";

    	$sqlexternal .= $sql_common . ",'E' " . $sql_audit ;
    	$sqlexternal .= "FROM external_audit WHERE $sqlFY  AND revision = 0 ";
    	$sqlexternal .= "$sqlclause";
 
        if (($internal eq 'INTERNAL') && ($external ne 'EXTERNAL')) { $sqlcode = "$sqlinternal"; }
	elsif (($internal ne 'INTERNAL') && ($external eq 'EXTERNAL')) { $sqlcode = "$sqlexternal"; }
        else  { $sqlcode = "$sqlinternal union $sqlexternal"; }
        #$sqlcode .= " order by 19 ";

   }
   if (($surv eq 'SURV') && ($audit eq 'AUDIT')) { $sqlcode .= " union $sqlsurv"; }
   elsif (($surv eq 'SURV') && ($audit ne 'AUDIT')) { $sqlcode = $sqlsurv; }
   elsif (($surv ne 'SURV') && ($audit ne 'AUDIT')) { print "<br>**** NOT A VALID SELECTION FOR THIS REPORT ****<br>\n"; }
   
   $sqlcode .= " order by 19 ";
   
  # print STDERR "--->$sqlcode\n";

 my $csr = ${dbh}->prepare($sqlcode);
 my $status = $csr->execute;
     
 my $i = 0;
    
 while (($integratedList[$i]{forecastdate},$integratedList[$i]{begindate},$integratedList[$i]{state},$integratedList[$i]{id},$integratedList[$i]{scope},$integratedList[$i]{issuedto},
         $integratedList[$i]{issuedby},$integratedList[$i]{lead},$integratedList[$i]{member},$integratedList[$i]{enddate},$integratedList[$i]{qard},$integratedList[$i]{title},$integratedList[$i]{results}, $integratedList[$i]{overall},
         $integratedList[$i]{FY},$integratedList[$i]{completiondate},$integratedList[$i]{cancelled},$integratedList[$i]{reschedule},$integratedList[$i]{sortfield},$integratedList[$i]{intext},$integratedList[$i]{revision},$integratedList[$i]{audittype},$integratedList[$i]{seq},
         $integratedList[$i]{notes},$integratedList[$i]{otherid},$integratedList[$i]{scheduletype},$integratedList[$i]{estbegin},$integratedList[$i]{estend}) = $csr->fetchrow_array) {
            $i++;
 }
 return(@integratedList);

}
#########################################################################################################
# Name:                                                                                                 #
#  GenerateAuditHeader                                                                                  #
#                                                                                                       #
# Purpose:																															  #
# 	This function writes the page header for the Audit schedule.                                         #
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The audit schedule year specified in a two digit format	                                   #
#  $reportType - Type of report being specified by the header function. Either Supplier or Internal.    #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #                                                                        #
#  $dbh - database handle                                                                               #
######################################################################################################### 
sub GenerateAuditHeader {

	my ($year, $reportType, $scheduleType, $issuedByOrg, $schema, $dbh, $userid) = @_;
	my $sqlString;
	my $date;
	my $dateTime;
	my $header;
	my $rev;
	my $sqlClauseInternal;
	my $sqlClauseAuditRev;
	my $approveDate;
	my $approveDate2;
	my $approver;
	my $approver2;
	my $title;
	my $out;
	my $queryYear = substr($year, 2, 2);
	if ($issuedByOrg eq "OQA") {
   		$sqlClauseInternal = " issuedby_org_id = 28";
   		$sqlClauseAuditRev = " auditing_org = 'OQA'";
   	}
   	elsif ($issuedByOrg eq "OCRWM") { 
   		$sqlClauseInternal = " issuedby_org_id = 24";
   		$sqlClauseAuditRev = " auditing_org = 'OCRWM'";
   	}
   	elsif ($issuedByOrg eq "BSCQA") { 
   		$sqlClauseInternal = " issuedby_org_id = 1";
   		$sqlClauseAuditRev = " auditing_org = 'BSC'";
   	}
   	elsif ($issuedByOrg eq "SNL") { 
	   		$sqlClauseInternal = " issuedby_org_id = 33";
	   		$sqlClauseAuditRev = " auditing_org = 'SNL'";
   	}
   	elsif ($issuedByOrg eq "EM") { 
   		$sqlClauseInternal = " issuedby_org_id = 3";
   		$sqlClauseAuditRev = " auditing_org = 'EM'";
   	}
	my $sth = $dbh->prepare("SELECT TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') FROM DUAL");
	$sth->execute;
	$dateTime = $sth->fetchrow_array;
	$out = "<!doctype HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\n";
	$out .= "<html>\n";
	$out .= "<head>\n";
	$out .= "<meta http-equiv=\"Content-Type\" CONTENT=\"text/html; charset=ISO-8859-1\">\n";
	if ($reportType eq "EXTERNAL") {
		$header = "<h3>Fiscal Year-$year $issuedByOrg External Audit ";
		$title = "<title>OCRWM FY-$year QA External Audit Schedule</title>\n";
	}
	elsif ($reportType eq "INTERNAL" && $issuedByOrg eq "EM") {
		$header = "<h3>Fiscal Year-$year EM/RW Audit";
		$title = "<title>OCRWM FY-$year EM/RW Audit Schedule</title>\n";
	}
	else {
		$header = "<h3>Fiscal Year-$year $issuedByOrg Internal Audit";
		$title = "<title>OCRWM FY-$year QA Internal Audit Schedule</title>\n";
	}
	$out .= $title;
	$out .= "</head>\n";
	$out .= "<body bgcolor=\"#FFFFFF\" leftmargin=\"15\">\n";
	$out .=  "<center>\n";
	$out .=  "<h2>OFFICE OF CIVILIAN RADIOACTIVE WASTE MANAGEMENT</h2>\n";
	$out .=  "$header Schedule</h3>\n";
	if ($scheduleType eq "ACCEPTED") {
	   if ($reportType eq "INTERNAL") {
	    	$sqlString = "SELECT revision, TO_CHAR(approval_date, 'MM/DD/YYYY'), firstname || ' ' || lastname "
	    	             . "FROM $schema.audit_revisions a, $schema.users b WHERE "
	    	             . "a.fiscal_year = $queryYear AND a.revision = (SELECT MAX(revision) FROM "
	    	             . "$schema.internal_audit where fiscal_year = $queryYear AND "
	    	             . "$sqlClauseInternal) AND a.approver = b.username AND a.audit_type = 'I' AND $sqlClauseAuditRev";
	    	        
	   }
	   else {
	   	$sqlString = "SELECT revision, TO_CHAR(approval_date, 'MM/DD/YYYY'), firstname || ' ' || lastname FROM "
	   	             . "$schema.audit_revisions a, $schema.users b WHERE "
	    	             . "a.fiscal_year = $queryYear AND b.username = a.approver AND "
	    	             . "a.revision = (select max(revision) FROM "
	    	             . "$schema.audit_revisions where fiscal_year = $queryYear AND audit_type = 'E') "
	    	             . "AND a.approver = b.username AND audit_type = 'E'";
	    	          
	   }
	   $sth = $dbh->prepare($sqlString);
	   $sth->execute;
	   ($rev, $approveDate, $approver) = $sth->fetchrow_array;
	    
	   if ($year >= 2004) {
           	$sqlString = "SELECT TO_CHAR(approval2_date, 'MM/DD/YYYY'), firstname || ' ' || lastname FROM "
			     . "$schema.audit_revisions a, $schema.users u WHERE "
			     . "a.fiscal_year = $queryYear AND u.username = a.approver2 AND "
			     . "a.revision = (select max(revision) FROM "
			     . "$schema.audit_revisions where fiscal_year = $queryYear AND audit_type = substr('$reportType',0,1)) "
		     	     . "AND a.approver2 = u.username AND audit_type = substr('$reportType',0,1)";
	  	$sth = $dbh->prepare($sqlString);
		$sth->execute;
	   	($approveDate2, $approver2) = $sth->fetchrow_array;
	   }	   
		
	   $rev = (defined($rev) && $rev > 0) ? --$rev : "";
	   if (!(defined($approveDate))) { $approveDate = ""; }
	   if (!(defined($approver))) { $approver = ""; }
	   $approver2 =  defined($approver2) ?  ", " .$approver2 : "";
	   $out .= "<h3>Revision:&nbsp;$rev<br>Approval Date:&nbsp;&nbsp;$approveDate<br>";
	   $out .= "Approver:&nbsp;$approver$approver2</h3>\n";
	}
	elsif ($issuedByOrg ne "EM") {
		$out .= "<h3>Revision:&nbsp;Work In Progress</h3>\n";
	}
	$out .= "</center>\n";
	$out .= "<font size=2>Generated:&nbsp; $dateTime</font><br>\n";
	$out .= "<hr>\n";
	$out .= "<table width=100% border=0>\n";
	$out .= "<tr>\n";
	if ($reportType eq "EXTERNAL") {
		$out .= "<td width=15% valign=top><b><font size=2>SUPPLIER</font></b></td>\n";
		$out .= "<td width=15%>&nbsp;</td>\n";
		$out .= "<td valign=top><b><font size=2>LOCATION</font></b></td>\n";
		$out .= "<td valign=top><b><font size=2>NUMBER</font></b></td>\n";
		$out .= "<td valign=top><b><font size=2>DATES</font></b></td>\n";
		$out .= "<td valign=top><b><font size=2>STATUS</font></b></td>";
	}
	else {
		$out .= "<td width=15% valign=top><b><font size=2>ORG</font></b></td>\n";
		$out .= "<td width=40% valign=top><b><font size=2>LOCATION</font></b></td>\n";
		$out .= "<td width=15% valign=top><b><font size=2>NUMBER</font></b></td>\n";
		$out .= "<td width=15% valign=top><b><font size=2>DATES</font></b></td>\n";
		$out .= "<td width=15% valign=top><b><font size=2>STATUS</font></b></td>";
	}
	return($out);
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
#	$year - The audit schedule year specified in a two digit format											     #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #
#  $dbh - database handle                                                                               #
######################################################################################################### 

sub InternalSchedule {

	my ($year, $scheduleType, $issuedBy, $schema, $dbh) = @_;
	my $sqlString;
	my $sqlquery;
	my ($sth, $sth1, $sth2, $sth3, $sth4);
	my ($id, $rev, $auditType, $auditSeq, $teamLeadId, $teamLead, $teamMembers, $scope, $auditTypeSeq, $reschedule);
	my ($issuedTo, $issuedToId, $completedDate, $forecastDate, $beginDate, $modified, $issuedById, $status);
	my ($orgId, $locId, $org, $city, $state, $province, $rowCount, $endDate, $notes, $cancelled, $sqlClause);
	my ($orgCount, @locIds, @orgIds, $out);
	my $queryYear = substr($year, 2, 2);
   	$sqlClause = " issuedby_org_id = 28" if ($issuedBy eq "OQA");
   	$sqlClause = " issuedby_org_id = 1" if ($issuedBy eq "BSCQA");
   	$sqlClause = " issuedby_org_id = 24" if ($issuedBy eq "OCRWM");
   	$sqlClause = " issuedby_org_id = 33" if ($issuedBy eq "SNL");
   	$sqlClause = " issuedby_org_id = 3" if ($issuedBy eq "EM");
	if ($scheduleType eq "ACCEPTED") {
		# Choose the max revision number of all internal audits for the Internal Accepted schedule
		$sqlString = "SELECT id, revision, cancelled, audit_type, audit_seq, team_lead_id, team_members, scope, "
		        . "TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, cancelled, "
		        . "TO_CHAR(completion_date, 'MM/DD/YYYY'), issuedto_org_id, TO_CHAR(forecast_date, 'MM/YYYY'), "
		        . "issuedby_org_id FROM $schema.internal_audit WHERE fiscal_year = $queryYear "
			. "AND revision = (SELECT MAX(revision) FROM $schema.internal_audit "
			. "WHERE fiscal_year = $queryYear AND $sqlClause) AND $sqlClause  "
			. "ORDER BY begin_date, end_date, forecast_date";
	}
	else {
		# Select the working copy of all audits for a given fiscal year for the Internal Working schedule
		$sqlString = "SELECT id, revision, cancelled, audit_type, audit_seq, team_lead_id, team_members, scope, "
		        . "TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, cancelled, "
		        . "TO_CHAR(completion_date, 'MM/DD/YYYY'), issuedto_org_id, TO_CHAR(forecast_date, 'MM/YYYY'), "
		        . "issuedby_org_id, state, reschedule, modified FROM $schema.internal_audit WHERE fiscal_year = $queryYear "
			. "AND revision = 0 AND $sqlClause ORDER BY begin_date, end_date, forecast_date";
   	}
   	$sth1 = $dbh->prepare($sqlString);
   	$sth1->execute;
   	$out = "<tr>\n<td colspan=7><hr></td>\n</tr>";
	while (($id, $rev, $cancelled, $auditType, $auditSeq, $teamLeadId, $teamMembers, $scope, $beginDate, 
			  $endDate, $notes, $cancelled, $completedDate, $issuedToId, $forecastDate, $issuedById, $state, 
			  $reschedule, $modified) = $sth1->fetchrow_array) {
	   # If this is an accepted schedule we must check to see if the working copy has been changed since last approval
		if ($scheduleType eq "ACCEPTED") {
			$sth2 = $dbh->prepare("SELECT modified FROM $schema.internal_audit WHERE id = $id AND "
			                      . "fiscal_year = $queryYear AND revision = 0");
			$sth2->execute;
			$modified = $sth2->fetchrow_array;
		}
	 	$out .=  "<tr>\n<td colspan=2 valign=top>\n";	
		$orgCount = &getOrgCount($dbh, $schema, $id, $rev, $queryYear);
		$out .= "<table width=100% border=0 cellpadding=0 cellspacing=0>\n";
		if ($orgCount > 1) {
			my $sql = "SELECT organization_id, location_id FROM $schema.internal_audit_org_loc "
			          . "WHERE internal_audit_id = $id AND fiscal_year = $queryYear "
			          . "AND revision = $rev";
			my $sth3 = $dbh->prepare($sql);
			$sth3->execute;
			while (my ($orgId, $locId) = $sth3->fetchrow_array) {
				$out .= "<tr>\n";
				$out .= &getOrganization($dbh, $schema, $modified, $scheduleType, $rev, $orgId);
				$out .= "<td width=72% valign=top>";
				$out .= &getLocation($dbh, $schema, $locId);
				$out .= "</td>\n</tr>\n";
			}
		}		
		if ($orgCount == 1) {
			$rowCount = 0;
			@locIds = &getLocationIds($dbh, $schema, $id, $rev, $queryYear);
			@orgIds = &getOrganizationIds($dbh, $schema, $id, $rev, $queryYear);
			my $loopCount;
			$loopCount = 1 if (@locIds == 1 || @locIds == 2);
			$loopCount = 2 if (@locIds == 3 || @locIds == 4 || @locIds == 5);
			$loopCount = 3 if (@locIds == 6 || @locIds == 7);
			for (my $i = 0; $i < $loopCount; $i++) {
				if ($rowCount == 0) {
					$out .= "<tr>\n";
					$out .= &getOrganization($dbh, $schema, $modified, $scheduleType, $rev, pop(@orgIds));
					$out .= "<td width=72% valign=top>";
					$out .= &getLocation($dbh, $schema, pop(@locIds));
					$out .= "&nbsp;&nbsp;";
					$out .= &getLocation($dbh, $schema, pop(@locIds));
					$out .= "</td>\n</tr>\n";
				}
				else {
					$out .= "<tr>\n";
					$out .= &getOrganization($dbh, $schema, $modified, $scheduleType, $rev, pop(@orgIds));
					$out .= "<td width=72% valign=top>";
					$out .= &getLocation($dbh, $schema, pop(@locIds));
					$out .= "&nbsp;&nbsp;";
					$out .= &getLocation($dbh, $schema, pop(@locIds));
					$out .= "&nbsp;&nbsp;";
					$out .= &getLocation($dbh, $schema, pop(@locIds));
					$out .= "</td>\n</tr>\n";
				}
				$rowCount++;
			}			
		}				
      		$out .= "</table>\n</td>\n";
		if ($auditSeq eq "0" && (!(defined($cancelled)) || (defined($cancelled) && $cancelled eq "N"))) {
			$out .= "<td valign=top><font size=2>To be determined</font></td>\n";
		}
		elsif ($auditSeq ne "0") {
			$out .= "<td valign=top><font size=2>" . &getInternalAuditId($dbh, $issuedById, $issuedToId, $auditType, $year, $auditSeq) . "</font></td>\n";
		}
		else {
			$out .= "<td><font size=2>Not applicable</font></td>\n";
		}
		if (defined($beginDate) && defined($endDate) && (!(defined($cancelled)) || defined($cancelled) && $cancelled eq "N")) {
			$out .= "<td valign=top><font size=2>$beginDate-$endDate</font></td>\n";
		}
		elsif (!(defined($beginDate)) && !(defined($endDate)) && (!(defined($cancelled)) || defined($cancelled) && $cancelled eq "N") && defined($forecastDate)) {
			$out .= "<td valign=top><font size=2>$forecastDate</font></td>\n";
		}
		else {
			$out .= "<td>&nbsp;</td>\n";
		}
		
	      	$status = defined($reschedule) ? "Rescheduled" : defined($cancelled) && $cancelled eq 'Y' ? "Cancelled" : defined($state) && $state eq 'Cancelled' ? "Cancelled" : 
	      	defined($completedDate) ? "Report Approved" : defined($state) ? "$state" : "&nbsp;";  
	      	
		$out .= "<td valign=top><font size=2>$status</font></td>\n</tr>\n";
		if (defined($teamLeadId) && $teamLeadId != 0) {
			$out .= "<tr>\n<td><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Lead:</b></font></td>\n";
			$sth = $dbh->prepare("SELECT firstname || ' ' || lastname FROM $schema.users WHERE id = $teamLeadId");
			$sth->execute;
			$teamLead = $sth->fetchrow_array;
			$out .= "<td colspan=4><font size=2>$teamLead</font></td>\n</tr>\n";
		}
		if (defined($teamMembers)) {
			$out .= "<tr>\n<td nowrap><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Members:</b>\n";
			$out .= "<td colspan=6><font size=2>$teamMembers</font></td>\n</tr>\n";
		}
		if (defined($scope)) {
			$out .= "<tr>\n<td nowrap valign=top><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Scope:</b>\n";
			$out .= "<td valign=top colspan=6><font size=2>$scope</font></td>\n</tr>\n";
		}
		if (defined($notes)) {
			$out .= "<tr>\n";
			$out .= "<td valign=top><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Notes:</b></font></td>\n";
			$out .= "<td valign=top colspan=6><font size=2>$notes</font></td>\n";
			$out .= "</tr>\n";
		}
		if (defined($reschedule)) {
			$out .= "<tr>\n";
			$out .= "<td valign=top><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Reschedule Info:</b></font></td>\n";
			$out .= "<td valign=top colspan=6><font size=2>$reschedule</font></td>\n";
			$out .= "</tr>\n";
		}
		$out .= "<tr>\n<td colspan=7><hr></td></tr>\n";
	}
	$out .= "</table>\n";
	$out .= "<br>\n<hr>\n";
	$out .= "</body>\n";
	$out .= "</html>\n";
	return($out);
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
#	$year - The audit schedule year specified in a two digit format											     #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #
#  $dbh - database handle                                                                               #
######################################################################################################### 
sub SupplierSchedule {

	my ($year, $scheduleType, $issuedBy, $schema, $dbh) = @_;
	my $sqlString;
	my ($sth, $sth1, $sth2);
	my ($id, $rev, $auditType, $issuedTo, $auditSeq, $teamLead, $teamMembers, $scope, $status);
	my ($teamLeadId, $issuedToId, $reschedule, $sqlClause);
	my ($beginDate, $endDate, $notes, $cancelled, $product, $completedDate, $modified, $forecastDate);
	my ($orgId, $locId, $org, $city, $state, $province, $rowCount, $qualifiedSupplierId, $name, $out);
	my $issuedById;
	my $queryYear = substr($year, 2, 2);
   	$sqlClause = " AND issuedby_org_id = 28" if ($issuedBy eq "OQA");
  	$sqlClause = " AND issuedby_org_id = 1" if ($issuedBy eq "BSCQA");
   	$sqlClause = " AND issuedby_org_id = 24" if ($issuedBy eq "OCRWM");
   	$sqlClause = " AND issuedby_org_id = 33" if ($issuedBy eq "SNL");
   	$sqlClause = " AND issuedby_org_id = 3" if ($issuedBy eq "EM");	
	if ($scheduleType eq "ACCEPTED") {
		# Choose max revision number of all external audits for the External Accepted schedule
		$sqlString = "SELECT id, revision, cancelled, audit_type, issuedto_org_id, audit_seq, team_lead_id, "
		        . "team_members, scope, TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, "
		        . "qualified_supplier_id, product, TO_CHAR(completion_date, 'MM/DD/YYYY'), TO_CHAR(forecast_date, 'MM/YYYY'), "
		        . "modified, issuedby_org_id FROM $schema.external_audit WHERE fiscal_year = $queryYear AND revision = (SELECT MAX(revision) FROM "
			. "$schema.external_audit WHERE fiscal_year = $queryYear) ORDER BY begin_date, forecast_date";
	}
	else {
		# Select the working copy all audits for a given fiscal year for the External Working schedule
		$sqlString = "SELECT id, revision, cancelled, audit_type, issuedto_org_id, audit_seq, team_lead_id, team_members, "
			. "scope, TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, qualified_supplier_id, product, "
			. "TO_CHAR(completion_date, 'MM/DD/YYYY'), TO_CHAR(forecast_date, 'MM/YYYY'), modified, issuedby_org_id, reschedule, state "
			. "FROM $schema.external_audit "
			. "WHERE fiscal_year = $queryYear AND revision = 0 $sqlClause ORDER BY begin_date, forecast_date";
   	}
   	$sth = $dbh->prepare($sqlString);
   	$sth->execute;
   	$out .= "<tr>\n<td colspan=7><hr></td>\n</tr>\n";
	while (($id, $rev, $cancelled, $auditType, $issuedToId, $auditSeq, $teamLeadId, $teamMembers, $scope, $beginDate, 
			  $endDate, $notes, $qualifiedSupplierId, $product, $completedDate, $forecastDate, $modified, 
			  $issuedById, $reschedule, $state) = $sth->fetchrow_array) {
			  
		# If this is an accepted schedule we must check to see if the working copy has been changed since last approval
		if ($scheduleType eq "ACCEPTED") {
			$sth1 = $dbh->prepare("SELECT modified FROM $schema.external_audit WHERE id = $id AND "
				. "fiscal_year = $queryYear AND revision = 0");
			$sth1->execute;
			$modified = $sth1->fetchrow_array;
		}  
	 	if (defined($qualifiedSupplierId)) {
	 		$sth1 = $dbh->prepare("SELECT company_name FROM $schema.qualified_supplier "
				. "WHERE id = $qualifiedSupplierId");
			$sth1->execute;
			$name = $sth1->fetchrow_array;
		}
		#if ((defined($modified) && $modified eq "Y") && ($rev != 1 || $scheduleType eq "WORKING")) {
		#	$out .= "<td valign=\"top\" colspan=\"2\"><font size=2>|&nbsp;$name</font></td>\n";
		#} ##if they go back to online approvals, put this back in
		#else {
			$out .= "<td valign=\"top\" colspan=\"2\"><font size=2>$name</font></td>\n";
		#}
		$sth1 = $dbh->prepare("SELECT location_id FROM $schema.external_audit_locations "
				. "WHERE external_audit_id = $id AND fiscal_year = $queryYear "
				. "AND revision = $rev");
		$sth1->execute;
		my $rowCount = 0;
		while ($locId = $sth1->fetchrow_array) {
			if ($rowCount > 0) {
				$out .= "<tr><td>&nbsp;</td>\n<td>&nbsp;</td>\n";
			}
			$out .= "<td valign=top>";
			$out .= &getLocation($dbh, $schema, $locId);
			$out .= "</td>\n";
			$out .= "</tr>" if ($rowCount > 0);
		   if ($rowCount == 0) {
		   		#if (defined($state) && $state eq 'Cancelled') {
		   		#	$out .= "<td valign=\"top\"><font size=2>CANCELLED</font></td>\n";
		   		#}
				if ($auditSeq eq "0" && (!(defined($cancelled)) || (defined($cancelled) && $cancelled eq "N"))) {
					$out .= "<td valign=top><font size=2>To be determined</font></td>\n";
				}
				elsif ($auditSeq ne "0"){
					$out .= "<td valign=top><font size=2>" . &getExternalAuditId($dbh, $issuedById, $issuedToId, $auditType, $year, $auditSeq) . "</font></td>\n";
				}
				else {
					$out .= "<td><font size=2>Not applicable</font></td>\n";
				}
				if (defined($beginDate) && defined($endDate) && (!(defined($cancelled)) || defined($cancelled) && $cancelled eq "N") || (defined($state) && $state eq 'Cancelled') ) {
					$out .= "<td valign=top><font size=2>$beginDate-$endDate</font></td>\n";
				}
				elsif (!(defined($beginDate)) && !(defined($endDate)) && (!(defined($cancelled)) || defined($cancelled) && $cancelled eq "N") && defined($forecastDate)) {
					$out .= "<td valign=top><font size=2>$forecastDate</font></td>\n";
				}	
				else {
					$out .= "<td>&nbsp;</td>\n";
				}
	      			$status = defined($reschedule) ? "Rescheduled" : defined($cancelled) && $cancelled eq 'Y' ? "Cancelled" : defined($state) && $state eq 'Cancelled' ? "Cancelled" : 
	      			defined($completedDate) ? "Complete" : defined($state) ? "$state" : "&nbsp;";  
				$out .= "<td valign=top><font size=2>$status</font></td>\n</tr>\n";
			}
			$rowCount++;
		}
		if (defined($teamLeadId) && $teamLeadId != 0) {
			$out .= "<tr>\n<td><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Lead:</b></font></td>\n";
			$sth2 = $dbh->prepare("SELECT firstname || ' ' || lastname FROM $schema.users WHERE id = $teamLeadId");
			$sth2->execute;
			$teamLead = $sth2->fetchrow_array;
			$out .= "<td><font size=2>$teamLead</font></td>\n";
		}
		if (defined($teamMembers)) {
			$out .= "<tr>\n<td nowrap valign=top><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Members:</b><\/td>";
			$out .= "<td colspan=5><font size=2>$teamMembers</font>"
			      . "</td>\n</tr>\n";
		}		  
		$out .= "</tr>\n";
		if (defined($product)) {
			$out .= "<tr>\n";
			$out .= "<td valign=top><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Product:</b></font></td>\n";
			$out .= "<td colspan=5><font size=2>$product</font></td>\n";
			$out .= "</tr>\n";
		}
		if (defined($scope)) {
			$out .= "<tr>\n";
			$out .= "<td valign=top><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Scope:</b></font></td>\n";
			$out .= "<td colspan=5><font size=2>$scope</font></td>\n";
			$out .= "</tr>\n";
		}
		if (defined($notes)) {
			$out .= "<tr>\n";
			$out .= "<td valign=top><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Notes:</b></font></td>\n";
			$out .= "<td colspan=5><font size=2>$notes</font></td>\n";
			$out .= "</tr>\n";
		}
		if (defined($reschedule)) {
			$out .= "<tr>\n";
			$out .= "<td valign=top><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Reschedule Info:</b></font></td>\n";
			$out .= "<td colspan=5><font size=2>$reschedule</font></td>\n";
			$out .= "</tr>\n";		
		}
		$out .= "<tr>\n<td colspan=6><hr></td></tr>\n";
	}
	$out .= "</table>\n";
	$out .= "<br>\n<hr>\n";
	$out .= "</body>\n";
	$out .= "</html>\n";
	return($out);
}
#########################################################################################################
# Name:                                                                                                 #
#  GenerateNewAuditHeader                                                                                  #
#                                                                                                       #
# Purpose:																															  #
# 	This function writes the page header for the Audit schedule.                                         #
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The audit schedule year specified in a two digit format	                                   #
#  $reportType - Type of report being specified by the header function. Either Supplier or Internal.    #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #                                                                        #
#  $dbh - database handle                                                                               #
######################################################################################################### 
sub GenerateNewAuditHeader {

	my ($year, $reportType, $scheduleType, $issuedByOrg, $schema, $dbh, $userid) = @_;
	my $sqlString;
	my $date;
	my $dateTime;
	my $header;
	my $rev;
	my $sqlClauseInternal;
	my $sqlClauseAuditRev;
	my $approveDate;
	my $approveDate2;
	my $approver;
	my $approver2;
	my $title;
	my $out;
	my $queryYear = substr($year, 2, 2);
	if ($issuedByOrg eq "OQA") {
   		$sqlClauseInternal = " issuedby_org_id = 28";
   		$sqlClauseAuditRev = " auditing_org = 'OQA'";
   	}
   	elsif ($issuedByOrg eq "OCRWM") { 
   		$sqlClauseInternal = " issuedby_org_id = 24";
   		$sqlClauseAuditRev = " auditing_org = 'OCRWM'";
   	}
   	elsif ($issuedByOrg eq "BSCQA") { 
   		$sqlClauseInternal = " issuedby_org_id = 1";
   		$sqlClauseAuditRev = " auditing_org = 'BSC'";
   	}
   	elsif ($issuedByOrg eq "SNL") { 
	   		$sqlClauseInternal = " issuedby_org_id = 33";
	   		$sqlClauseAuditRev = " auditing_org = 'SNL'";
   	}
   	elsif ($issuedByOrg eq "EM") { 
   		$sqlClauseInternal = " issuedby_org_id = 3";
   		$sqlClauseAuditRev = " auditing_org = 'EM'";
   	}
	my $sth = $dbh->prepare("SELECT TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') FROM DUAL");
	$sth->execute;
	$dateTime = $sth->fetchrow_array;
	$out = "<!doctype HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\n";
	$out .= "<html>\n";
	$out .= "<head>\n";
	$out .= "<meta http-equiv=\"Content-Type\" CONTENT=\"text/html; charset=ISO-8859-1\">\n";
	if ($reportType eq "EXTERNAL" || $reportType eq "NEWEXTERNAL") {
		$header = "<h3>Fiscal Year-$year $issuedByOrg External Audit ";
		$title = "<title>OCRWM FY-$year QA External Audit Schedule</title>\n";
	}
	elsif ($reportType eq "INTERNAL" && $issuedByOrg eq "EM") {
		$header = "<h3>Fiscal Year-$year EM/RW Audit";
		$title = "<title>OCRWM FY-$year EM/RW Audit Schedule</title>\n";
	}
	else {
		$header = "<h3>Fiscal Year-$year $issuedByOrg Internal Audit";
		$title = "<title>OCRWM FY-$year QA Internal Audit Schedule</title>\n";
	}
	$out .= $title;
	$out .= "</head>\n";
	$out .= "<body bgcolor=#FFFFFF leftmargin=15>\n";
	$out .=  "<center>\n";
	$out .=  "<h2>OFFICE OF CIVILIAN RADIOACTIVE WASTE MANAGEMENT</h2>\n";
	$out .=  "$header Schedule<br>Status and Results</h3>\n";
	if ($scheduleType eq "ACCEPTED") {
	   if ($reportType eq "INTERNAL" || $reportType eq "NEWINTERNAL") {
	    	$sqlString = "SELECT revision, TO_CHAR(approval_date, 'MM/DD/YYYY'), firstname || ' ' || lastname "
	    	             . "FROM $schema.audit_revisions a, $schema.users b WHERE "
	    	             . "a.fiscal_year = $queryYear AND a.revision = (SELECT MAX(revision) FROM "
	    	             . "$schema.internal_audit where fiscal_year = $queryYear AND "
	    	             . "$sqlClauseInternal) AND a.approver = b.username AND a.audit_type = 'I' AND $sqlClauseAuditRev";
	    	        
	   }
	   else {
	   	$sqlString = "SELECT revision, TO_CHAR(approval_date, 'MM/DD/YYYY'), firstname || ' ' || lastname FROM "
	   	             . "$schema.audit_revisions a, $schema.users b WHERE "
	    	             . "a.fiscal_year = $queryYear AND b.username = a.approver AND "
	    	             . "a.revision = (select max(revision) FROM "
	    	             . "$schema.audit_revisions where fiscal_year = $queryYear AND audit_type = 'E') "
	    	             . "AND a.approver = b.username AND audit_type = 'E'";
	    	          
	   }
	   $sth = $dbh->prepare($sqlString);
	   $sth->execute;
	   ($rev, $approveDate, $approver) = $sth->fetchrow_array;
	    
	   if ($year >= 2004) {
           	$sqlString = "SELECT TO_CHAR(approval2_date, 'MM/DD/YYYY'), firstname || ' ' || lastname FROM "
			     . "$schema.audit_revisions a, $schema.users u WHERE "
			     . "a.fiscal_year = $queryYear AND u.username = a.approver2 AND "
			     . "a.revision = (select max(revision) FROM "
			     . "$schema.audit_revisions where fiscal_year = $queryYear AND audit_type = substr('$reportType',0,1)) "
		     	     . "AND a.approver2 = u.username AND audit_type = substr('$reportType',0,1)";
	  	$sth = $dbh->prepare($sqlString);
		$sth->execute;
	   	($approveDate2, $approver2) = $sth->fetchrow_array;
	   }	   
		
	   $rev = (defined($rev) && $rev > 0) ? --$rev : "";
	   if (!(defined($approveDate))) { $approveDate = ""; }
	   if (!(defined($approver))) { $approver = ""; }
	   $approver2 =  defined($approver2) ?  ", " .$approver2 : "";
	   $out .= "<h3>Revision:&nbsp;$rev<br>Approval Date:&nbsp;&nbsp;$approveDate<br>";
	   $out .= "Approver:&nbsp;$approver$approver2</h3>\n";
	}
	elsif ($issuedByOrg ne "EM") {
		$out .= "<h3>Revision:&nbsp;Work In Progress</h3>\n";
	}
	$out .= "</center>\n";
	$out .= "<b>Generated:</b> &nbsp; $dateTime<br>\n";
	$out .= "<hr>\n";
	$out .= "<table width=100% border=0 cellspacing=2>\n";

	return($out);
}
#########################################################################################################
# Name:                                                                                                 #
#  NewInternalSchedule                                                                                     #
#                                                                                                       #
# Purpose:																															  #
# 	This function will write all the audits for a Internal audit schedule for a given fiscal year.       #
#  The two types of schedules that this function will generate are the working or the accepted schedule #
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The audit schedule year specified in a two digit format											     #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #
#  $dbh - database handle                                                                               #
######################################################################################################### 

sub NewInternalSchedule {

	my ($year, $scheduleType, $issuedBy, $schema, $dbh) = @_;
	my $sqlString;
	my $sqlquery;
	my ($sth, $sth1, $sth2, $sth3, $sth4, $sth5);
	my ($id, $rev, $auditType, $auditSeq, $teamLeadId, $teamLead, $teamMembers, $scope, $auditTypeSeq, $reschedule);
	my ($issuedTo, $issuedToId, $completedDate, $forecastDate, $beginDate, $modified, $issuedById, $suborgId, $suborg);
	my ($orgId, $locId, $org, $city, $state, $province, $rowCount, $endDate, $notes, $cancelled, $sqlClause);
	my ($orgCount, @locIds, @orgIds, $out, $title, $qard, $adequacy, $implementation, $effectiveness, $status);
	my $queryYear = substr($year, 2, 2);
   	$sqlClause = " issuedby_org_id = 28" if ($issuedBy eq "OQA");
   	$sqlClause = " issuedby_org_id = 1" if ($issuedBy eq "BSCQA");
   	$sqlClause = " issuedby_org_id = 24" if ($issuedBy eq "OCRWM");
   	$sqlClause = " issuedby_org_id = 33" if ($issuedBy eq "SNL");
   	$sqlClause = " issuedby_org_id = 3" if ($issuedBy eq "EM");
	if ($scheduleType eq "ACCEPTED") {
		# Choose the max revision number of all internal audits for the Internal Accepted schedule
		$sqlString = "SELECT id, revision, cancelled, audit_type, audit_seq, team_lead_id, team_members, scope, "
		             . "TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, cancelled, "
		             . "TO_CHAR(completion_date, 'MM/DD/YYYY'), issuedto_org_id, TO_CHAR(forecast_date, 'MM/YYYY'),issuedby_org_id, "
			     . "title, qard_elements, adequacy, implementation, effectiveness, state "
		             . "FROM $schema.internal_audit WHERE fiscal_year = $queryYear "
						 . "AND revision = (SELECT MAX(revision) FROM $schema.internal_audit "
						 . "WHERE fiscal_year = $queryYear AND $sqlClause) AND $sqlClause  "
						 . "ORDER BY begin_date, end_date, forecast_date";
	}
	else {
		# Select the working copy of all audits for a given fiscal year for the Internal Working schedule
		$sqlString = "SELECT id, revision, cancelled, audit_type, audit_seq, team_lead_id, team_members, scope, "
		             . "TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, cancelled, "
		             . "TO_CHAR(completion_date, 'MM/DD/YYYY'), issuedto_org_id, TO_CHAR(forecast_date, 'MM/YYYY'),issuedby_org_id, "
			     . "title, qard_elements, adequacy, implementation, effectiveness, state, reschedule, "
		             . "modified FROM $schema.internal_audit WHERE fiscal_year = $queryYear "
						 . "AND revision = 0 AND $sqlClause ORDER BY begin_date, end_date, forecast_date";
   	}
   	$sth1 = $dbh->prepare($sqlString);
  	$sth1->execute;
	while (($id, $rev, $cancelled, $auditType, $auditSeq, $teamLeadId, $teamMembers, $scope, $beginDate, 
			  $endDate, $notes, $cancelled, $completedDate, $issuedToId, $forecastDate, $issuedById, 
			  $title, $qard, $adequacy, $implementation, $effectiveness, $status, $reschedule, $modified) = $sth1->fetchrow_array) {
	   # If this is an accepted schedule we must check to see if the working copy has been changed since last approval
		if ($scheduleType eq "ACCEPTED") {
			$sth2 = $dbh->prepare("SELECT modified FROM $schema.internal_audit WHERE id = $id AND "
			                      . "fiscal_year = $queryYear AND revision = 0");
			$sth2->execute;
			$modified = $sth2->fetchrow_array;
		}
		$issuedToId = 0 unless (defined($issuedToId));
		$issuedById = 0 unless (defined($issuedById));
		$out .= "<tr><td valign=top><font size=2><b>Audit Number:</b>&nbsp;&nbsp;" . &getInternalAuditId($dbh, $issuedById, $issuedToId, $auditType, $year, $auditSeq) . "</font></td>\n";
		$out .= "<td valign=top><font size=2><b>Lead:</b>&nbsp;";
		if (defined($teamLeadId) && $teamLeadId != 0) {
			$sth3 = $dbh->prepare("SELECT firstname || ' ' || lastname FROM $schema.users WHERE id = $teamLeadId");
			$sth3->execute;
			$teamLead = $sth3->fetchrow_array;
			$out .= "$teamLead";
		}
		$out .= "</font></td>\n<td valign=top><font size=2>";
		if (defined($reschedule)) {
			$out .= "<b>Rescheduled:</b>&nbsp;$reschedule";
		}		
		elsif (defined($cancelled) && $cancelled eq "Y"  || ($state eq 'Cancelled')) {
			$out .= "<b>Performance Dates:</b>&nbsp;CANCELLED";
		}
		elsif (defined($beginDate)) {
			$out .= "<b>Performance Dates:</b>&nbsp;$beginDate";
			if (defined($endDate)) {
				$out .= "-$endDate";
			} else {
				$out .= " (in progress)";
			}
		}
		else {
			$out .= "&nbsp;";
		}
		if (defined($completedDate)) {
			$out .= "<br><b>Report Approved:</b>&nbsp;$completedDate";
		}
		$out .= "</font></td></tr>\n";
		my $sql = "SELECT organization_id, location_id, suborganization_id FROM $schema.internal_audit_org_loc "
			          . "WHERE internal_audit_id = $id AND fiscal_year = $queryYear "
			          . "AND revision = $rev";
		my $sth3 = $dbh->prepare($sql);
		$sth3->execute;
		while (my @values = $sth3->fetchrow_array) {
			($orgId, $locId, $suborgId) = @values;
			$out .= "<tr>" if (defined($orgId) || defined($locId));
			if (defined($orgId)) {
				$sql = "SELECT abbr FROM $schema.organizations WHERE id = $orgId";
			 	$sth4 = $dbh->prepare($sql);
			 	$sth4->execute;
			 	$org = $sth4->fetchrow_array;
				$out .= "<td valign=top><font size=2><b>Organization:</b>&nbsp;$org</font></td>\n";
				if (defined($suborgId) && $orgId eq 1) {
					my @suborg = &getSuborganization(dbh=>$dbh,schema=>$schema,auditID=>$id,fiscalyear=>$queryYear);
					$out .= "<td valign=top><font size=2><b>Suborg:</b>&nbsp;";
				        for (my $j = 0; $j < $#suborg; $j++) {
				        	$out .= (($j != 0) ? ", " : "") . "$suborg[$j]{suborg}";
				        }
				        $out .= "</font></td>";
				} else {
					$out .= "<td valign=top><font size=2>&nbsp;</font></td>";
				}
			}
			if (defined($locId)) {
				$out .= "<td valign=top><font size=2><b>Location:</b>&nbsp;";
				$out .= &getLocation($dbh, $schema, $locId);
				$out .= "</font></td>\n";
			}
			$out .= "</tr>\n" if (defined($orgId) || defined($locId));
		}		
		$out .= "<tr><td colspan=2><font size=2><b>Audit Title:</b>&nbsp;$title</font></td>\n";
		$out .= "<td><font size=2><b>QA Elements:</b>&nbsp;" . &writeQARD(qard=>"$qard") . "</font></td></tr>\n";
		$out .= "<tr><td colspan=3><font size=2><b>Audit Scope Summary:</b>&nbsp;$scope</font></td></tr>\n";
		$out .= "<tr><td><font size=2><b>Results:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Adequacy - $adequacy</font></td>\n";
		$out .= "<td><font size=2>Implementation - $implementation</font></td><td><font size=2>Effectiveness - $effectiveness</font></td></tr>\n";
		$out .= "<tr><td colspan=3><font size=2>" . writeConditionReport(dbh => $dbh, schema => $schema, auditID => $id, generatedfrom => 'IA', fiscalyear => $queryYear) . "</font></td></tr>\n";
		$out .= "<tr><td colspan=7><hr></td></tr>\n";
	}
	$out .= "</table><br>\n";
	$out .= "</body>\n";
	$out .= "</html>\n";
	return($out);
}

#########################################################################################################
# Name:                                                                                                 #
#  NewSupplierSchedule                                                                                     #
#                                                                                                       #
# Purpose:																															  #
# 	This function will write all the audits for a External audit schedule for a given fiscal year.       #
#  The two types of schedules that this function will generate are the working or the accepted schedule #
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The audit schedule year specified in a two digit format											     #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #
#  $dbh - database handle                                                                               #
######################################################################################################### 
sub NewSupplierSchedule {

	my ($year, $scheduleType, $issuedBy, $schema, $dbh) = @_;
	my $sqlString;
	my ($sth, $sth1, $sth2, $sth3);
	my ($id, $rev, $auditType, $issuedTo, $auditSeq, $teamLead, $teamMembers, $scope, $sqlClause);
	my ($teamLeadId, $issuedToId, $title, $qard, $adequacy, $implementation, $effectiveness, $status, $reschedule);
	my ($beginDate, $endDate, $notes, $cancelled, $product, $completedDate, $modified, $forecastDate);
	my ($orgId, $locId, $org, $city, $state, $province, $rowCount, $qualifiedSupplierId, $name, $out);
	my $issuedById;
	my $queryYear = substr($year, 2, 2);
   	$sqlClause = " AND issuedby_org_id = 28" if ($issuedBy eq "OQA");
  	$sqlClause = " AND issuedby_org_id = 1" if ($issuedBy eq "BSCQA");
   	$sqlClause = " AND issuedby_org_id = 24" if ($issuedBy eq "OCRWM");
   	$sqlClause = " AND issuedby_org_id = 33" if ($issuedBy eq "SNL");
   	$sqlClause = " AND issuedby_org_id = 3" if ($issuedBy eq "EM");	
	if ($scheduleType eq "ACCEPTED") {
		# Choose max revision number of all external audits for the External Accepted schedule
		$sqlString = "SELECT id, revision, cancelled, audit_type, issuedto_org_id, audit_seq, team_lead_id, "
		             . "team_members, scope, TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, "
		             . "qualified_supplier_id, product, TO_CHAR(completion_date, 'MM/DD/YYYY'), TO_CHAR(forecast_date, 'MM/YYYY'), "
		             . "modified, issuedby_org_id, title, qard_elements, adequacy, implementation, effectiveness, state " 
		             . "FROM $schema.external_audit WHERE fiscal_year = $queryYear AND revision = (SELECT MAX(revision) FROM "
						 . "$schema.external_audit WHERE fiscal_year = $queryYear) ORDER BY begin_date, forecast_date";
	}
	else {
		# Select the working copy all audits for a given fiscal year for the External Working schedule
		$sqlString = "SELECT id, revision, cancelled, audit_type, issuedto_org_id, audit_seq, team_lead_id, team_members, "
			     . "scope, TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, qualified_supplier_id, product, "
			     . "TO_CHAR(completion_date, 'MM/DD/YYYY'), TO_CHAR(forecast_date, 'MM/YYYY'), modified, issuedby_org_id, "
			     . "title, qard_elements, adequacy, implementation, effectiveness, state, reschedule FROM $schema.external_audit "
			     . "WHERE fiscal_year = $queryYear AND revision = 0 $sqlClause ORDER BY begin_date, forecast_date";
   }
   $sth = $dbh->prepare($sqlString);
   $sth->execute;
   $out = "";
	while (($id, $rev, $cancelled, $auditType, $issuedToId, $auditSeq, $teamLeadId, $teamMembers, $scope, $beginDate, 
			  $endDate, $notes, $qualifiedSupplierId, $product, $completedDate, $forecastDate, $modified, $issuedById,
			  $title, $qard, $adequacy, $implementation, $effectiveness, $status, $reschedule) = $sth->fetchrow_array) {
			  
		# If this is an accepted schedule we must check to see if the working copy has been changed since last approval
		if ($scheduleType eq "ACCEPTED") {
			$sth1 = $dbh->prepare("SELECT modified FROM $schema.external_audit WHERE id = $id AND "
			                      . "fiscal_year = $queryYear AND revision = 0");
			$sth1->execute;
			$modified = $sth1->fetchrow_array;
		}  
	 	if (defined($qualifiedSupplierId)) {
	 		$sth1 = $dbh->prepare("SELECT company_name FROM $schema.qualified_supplier "
					 					 . "WHERE id = $qualifiedSupplierId");
			$sth1->execute;
			$name = $sth1->fetchrow_array;
		}
		if ((defined($modified) && $modified eq "Y") && ($rev != 1 || $scheduleType eq "WORKING")) {
			#$out .= "<td valign=\"top\" colspan=\"2\"><font size=2>|&nbsp;$name</font></td>\n";
		}
		else {
			#$out .= "<td valign=\"top\" colspan=\"2\"><font size=2>$name</font></td>\n";
		}
		$sth1 = $dbh->prepare("SELECT location_id FROM $schema.external_audit_locations "
					 				. "WHERE external_audit_id = $id AND fiscal_year = $queryYear "
					 				. "AND revision = $rev");
		$sth1->execute;
		$out .= "<tr><td valign=top><font size=2><b>Audit Number:</b>&nbsp;&nbsp;" . &getExternalAuditId($dbh, $issuedById, $issuedToId, $auditType, $year, $auditSeq) . "</font></td>\n";
		$out .= "<td valign=top><font size=2><b>Lead:</b>&nbsp;";
		if (defined($teamLeadId) && $teamLeadId != 0) {
			$sth3 = $dbh->prepare("SELECT firstname || ' ' || lastname FROM $schema.users WHERE id = $teamLeadId");
			$sth3->execute;
			$teamLead = $sth3->fetchrow_array;
			$out .= "$teamLead";
		}
		$out .= "</font></td>\n<td valign=top><font size=2>";
		if (defined($reschedule)) {
			$out .= "<b>Rescheduled:</b>&nbsp;$reschedule";
		}
		elsif ((defined($cancelled) && $cancelled eq "Y")  || ($status eq 'Cancelled')) {
			$out .= "<b>Performance Dates:</b>&nbsp;CANCELLED";
		}
		elsif (defined($beginDate)) {
			$out .= "<b>Performance Dates:</b>&nbsp;$beginDate";
			if (defined($endDate)) {
				$out .= "-$endDate";
			} else {
				$out .= " (in progress)";
			}
		}
		else {
			$out .= "<b>Scheduled:</b>&nbsp;$forecastDate";
		}
		if (defined($completedDate)) {
			$out .= "<br><b>Report Approved:</b>&nbsp;$completedDate";
		}
		$out .= "</font></td></tr>\n";
		$out .= "<tr><td valign=top colspan=2><font size=2><b>Supplier:</b>&nbsp;$name</font></td>\n";
		$out .= "<td valign=top><font size=2><b>Location:</b>&nbsp;";
		my $sql = "SELECT location_id FROM $schema.external_audit_locations "
			. "WHERE external_audit_id = $id AND fiscal_year = $queryYear AND revision = $rev";
		my $sth3 = $dbh->prepare($sql);
		$sth3->execute;
		while ($locId = $sth3->fetchrow_array) {
			$out .= &getLocation($dbh, $schema, $locId);
		}
		$out .= "</font></td>\n";
		$out .= "</tr>";		
		$out .= "<tr><td colspan=2><font size=2><b>Audit Title:</b>&nbsp;$title</font></td>\n";
		$out .= "<td><font size=2><b>QA Elements:</b>&nbsp;" . &writeQARD(qard=>"$qard") . "</font></td></tr>\n";
		$out .= "<tr><td colspan=3><font size=2><b>Audit Scope Summary:</b>&nbsp;$scope</font></td></tr>\n";
		$out .= "<tr><td><font size=2><b>Results:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Adequacy - $adequacy</font></td>\n";
		$out .= "<td><font size=2>Implementation - $implementation</font></td><td><font size=2>Effectiveness - $effectiveness</font></td></tr>\n";
		$out .= "<tr><td colspan=3><font size=2>" . writeConditionReport(dbh => $dbh, schema => $schema, auditID => $id, generatedfrom => 'EA', fiscalyear => $queryYear) . "</font></td></tr>\n";
		$out .= "<tr><td colspan=\"7\"><hr></td></tr>\n";
	}
	$out .= "</table><br>\n";
	$out .= "</body>\n";
	$out .= "</html>\n";
	return($out);
}
#########################################################################################################
# Name:                                                                                                 #
#  GenerateSurveillanceHeader                                                                           #
#                                                                                                       #
# Purpose:																															  #
# 	This function writes the page header for the Surveillance schedule.                                  #
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The audit schedule year specified in a two digit format	                                   #
#  $reportType - Type of report being specified by the header function. Either Supplier or Internal.    #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #                                                                        #
#  $dbh - database handle                                                                               #
######################################################################################################### 
sub GenerateSurveillanceHeader {

	my ($year, $reportType, $issuedByOrg, $schema, $dbh) = @_;
	my $sqlString;
	my $dateTime;
	my $header;
	my $out;
	my $queryYear = substr($year, 2, 2);
	my $sth = $dbh->prepare("SELECT TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') FROM DUAL");
	$sth->execute;
	$dateTime = $sth->fetchrow_array;
	$out = "<!doctype HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\n";
 	$out .= "<html>\n";
	$out .= "<head>\n";
	if ($reportType eq "LOG") {
		$out .= "<title>OCRWM FY-$year $issuedByOrg Yucca Mountain Surveillance Log</title>\n";
	}
	else {
		$out .= "<title>OCRWM FY-$year $issuedByOrg Yucca Mountain Surveillance Request List</title>\n";
	}
	$out .= "<style type=\"text/css\">\n";
	$out .= "	<!--\n";
	$out .= "		td.org_loc {padding-top: 0px; padding-left: 0px}\n";
	$out .= "	-->\n";
	$out .= "</style>\n";
	$out .= "</head>\n";
	$out .= "<body bgcolor=\"#FFFFFF\" leftmargin=\"15\">\n";
	$out .= "<center>\n";
	$out .= "<h2>OFFICE OF CIVILIAN RADIOACTIVE WASTE MANAGEMENT</h2>\n";
	if ($reportType eq "LOG") {
		$out .= "<h3>OCRWM Fiscal Year-$year $issuedByOrg Yucca Mountain Surveillance Log</h3>\n";
		$out .= "</center>\n";
		$out .= "<b>Generated:</b> &nbsp; $dateTime<br>\n";
		$out .= "<hr>\n";
		$out .= "<table width=\"100%\" border=\"0\" cellspacing=\"3\" cellpadding=\"2\">\n";
		$out .= "<tr>\n";
		$out .= "<td width=\"15%\" valign=\"top\"><b><font size=2>SURVEILLANCE<br>NUMBER</font></b></td>\n";
		$out .= "<td width=\"10%\" valign=\"top\"><b><font size=2>ORG</font></b></td>\n";
		$out .= "<td width=\"15%\" valign=\"top\"><b><font size=2>LOCATION</font></b></td>\n";
		#$out .= "<td width=\"10%\" valign=\"top\"><b><font size=2>PROG<br>ELEM</font></b></td>\n";
		$out .= "<td width=\"20%\" valign=\"top\"><b><font size=2>START DATE-<br>END DATE</font></b></td>\n";
		$out .= "<td width=\"20%\" valign=\"top\"><b><font size=2>REPORT<br>APPROVED<br>DATE</font></b></td>";
		#$out .= "<td valign=\"top\"><b><font size=2>DEF. DOCS ISSUED</font></b></td>\n</tr>\n";
   }
   else {
		$out .= "<h3>OCRWM Fiscal Year-$year $issuedByOrg Yucca Mountain Surveillance Request List</h3>\n";
		$out .= "</center>\n";
		$out .= "<b>Generated:</b> &nbsp; $dateTime<br>\n";
		$out .= "<hr>\n";
		$out .= "<table width=\"100%\" border=\"0\" cellspacing=\"3\" cellpadding=\"2\">\n";
		$out .= "<tr>\n";
		$out .= "<td width=\"12%\" valign=\"top\"><b><font size=2>REQUEST NUMBER</font></b></td>\n";
		$out .= "<td width=\"15%\" valign=\"top\"><b><font size=2>ORG</font></b></td>\n";
		$out .= "<td width=\"15%\" valign=\"top\"><b><font size=2>LOCATION</font></b></td>\n";
		$out .= "<td width=\"15%\" valign=\"top\"><b><font size=2>REQUESTOR</font></b></td>\n";
		$out .= "<td width=\"15%\" valign=\"top\"><b><font size=2>REQUEST DATE</font></b></td>\n</tr>\n";	
   }
   return($out);
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
#  $date - Today's date                                                                                 #
#  $dbh - database handle                                                                               #
######################################################################################################### 
sub SurveillanceLog {

	my ($year, $issuedToOrg, $issuedByOrg, $schema, $dbh) = @_;
	my $sqlString;
	my ($sth1, $sth2, $sth3, $sth4, $sth5, $issuedToId, $issuedTo, $teamMembers, $reschedule);
	my ($id, $rev, $teamLeadId, $teamLead, $activity, $beginDate, $notes, $endDate, $cancelled, $status, $docId);
	my ($orgId, $locId, $org, $city, $state, $province, $completedDate, $elements, $out, $intExt, $issuedById, $supplierId);
	my $survSeq;
	my $queryYear = substr($year, 2, 2);
	my $issuedByOrgId = ($issuedByOrg eq "OQA") ? 28 : ($issuedByOrg eq "SNL") ? 33 : 1;
	
	if ($issuedToOrg == 0) {
		# Select all surveillances for a given surveillance year
		$sqlString = "SELECT issuedto_org_id, id, elements, status, team_lead_id, scope, TO_CHAR(begin_date, 'MM/DD/YYYY'), "
		             . "TO_CHAR(end_date, 'MM/DD/YYYY'), TO_CHAR(completion_date, 'MM/DD/YYYY'), "
						 . "notes, cancelled, team_members, int_ext, issuedby_org_id, surveillance_seq, reschedule, state "
						 . "FROM $schema.surveillance "
						 . "WHERE fiscal_year = $queryYear AND issuedby_org_id = $issuedByOrgId ORDER BY surveillance_seq";
	}
	else {
		# Select only those surveillances pertaining to a specific organization for a given surveillance year
		$sqlString = "SELECT issuedto_org_id, id, elements, status, team_lead_id, scope, "
		             . "TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), "
		             . "TO_CHAR(completion_date, 'MM/DD/YYYY'), "
						 . "notes, cancelled, team_members, int_ext, issuedby_org_id, surveillance_seq, reschedule, state "
						 . "FROM $schema.surveillance WHERE fiscal_year = $queryYear AND issuedto_org_id = $issuedToOrg "
						 . "AND issuedby_org_id = $issuedByOrgId ORDER BY surveillance_seq";
   }
   $sth1 = $dbh->prepare($sqlString);
   $sth1->execute;
   $out .= "<tr>\n<td colspan=\"7\"><hr></td>\n</tr>\n";
	while (($issuedToId, $id, $elements, $status, $teamLeadId, $activity, $beginDate, $endDate, $completedDate, 
	        $notes, $cancelled, $teamMembers, $intExt, $issuedById, $survSeq, $reschedule, $state) = $sth1->fetchrow_array) {
	 	$sth2 = $dbh->prepare("SELECT location_id, organization_id, supplier_id FROM $schema.surveillance_org_loc "
			 						 . "WHERE surveillance_id = $id AND fiscal_year = $queryYear");
		$sth2->execute;
		$issuedToId = 0 unless (defined($issuedToId));
		$issuedById = 0 unless (defined($issuedById));
		$out .= "<tr>\n<td valign=\"top\"><font size=2>" . &getSurvId($dbh, $issuedById, $issuedToId, $intExt, $year, $survSeq) . "</font></td>\n";
		$out .= "<td class=org_loc colspan=2 valign=top><table border=0 width=100%>";
		while (my @values = $sth2->fetchrow_array) {
			($locId, $orgId, $supplierId) = @values;
			$out .= "<tr>";
			if (defined($orgId) || defined($supplierId)) {
				my $sql = "";
				$sql = "SELECT abbr FROM $schema.organizations WHERE id = $orgId" if ($intExt eq "I");
				$sql = "SELECT company_name FROM $schema.qualified_supplier WHERE id = $supplierId" if ($intExt eq "E");
			 	$sth3 = $dbh->prepare($sql);
			 	$sth3->execute;
			 	$org = $sth3->fetchrow_array;
			}
			if (defined($orgId)) {
				$out .= "<td valign=\"top\" width=40%><font size=2>$org</font></td>\n";
			}
			else {
				$out .= "<td valign=\"top\" width=40%><font size=2>&nbsp;</font></td>\n";
			}
			$out .= "<td valign=\"top\" valign=\"top\">";
			$out .= &getLocation($dbh, $schema, $locId);
			$out .= "</td>\n";
			$out .= "</tr>";
		}
		$out .= "</table></td>";
		#if (defined($elements)) {
			#$out .= "<td valign=\"top\"><font size=2>$elements</font></td>\n";
		#}
		#else {
			#$out .= "<td valign=\"top\">&nbsp;</td>\n";
		#}
		if (defined($reschedule)) {
			$out .= "<td valign=\"top\"><font size=2>RESCHEDULED</font></td>\n";
		}		
		elsif ((defined($cancelled) && $cancelled eq "Y")  || ($state eq 'Cancelled')){
			$out .= "<td valign=\"top\"><font size=2>CANCELLED</font></td>\n";
		}
		elsif (defined($beginDate)) {
			$out .= "<td valign=\"top\"><font size=2>$beginDate";
			if (defined($endDate)) {
				$out .= "-$endDate";
			}
			$out .= "</font></td>\n";
		}
		else {
			$out .= "<td>&nbsp;</td>\n";
		}
		if (defined($completedDate)) {
			$out .= "<td valign=\"top\"><font size=2>$completedDate</font></td>\n";
		}
		else {
			$out .= "<td valign=\"top\"><font size=2>&nbsp;</font></td>\n";
		}
		$sth5 = $dbh->prepare("SELECT deficiency FROM $schema.surveillance_deficiencies "
									 . "WHERE surveillance_id = $id "
									 . "AND fiscal_year = $queryYear");
		$sth5->execute;
		$out .= "<td valign=\"top\"><font size=2>";
		while ($docId = $sth5->fetchrow_array) {
			$out .= "-$docId<br>";
		}
		$out .= "</font></td>\n</tr>\n";
		if (defined($supplierId)) {
			$out .= "<tr>\n<td colspan=\"1\" valign=\"\"top\"\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Supplier:</b></font></td>\n";
			$out .= "<td colspan=\"6\"><font size=\"2\">$org</font></td>\n</tr>\n";
		}
		if (defined($teamLeadId) && $teamLeadId != 0) {
			$sth3 = $dbh->prepare("SELECT firstname || ' ' || lastname FROM $schema.users WHERE id = $teamLeadId");
			$sth3->execute;
			$teamLead = $sth3->fetchrow_array;
			$out .= "<tr>\n<td colspan=\"1\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Lead:</b></font></td>\n";
			$out .= "<td colspan=\"6\"><font size=2>$teamLead</font></td>\n</tr>\n";
		}
		if (defined($teamMembers)) {
			$out .= "<tr>\n<td colspan=\"1\" valign=\"\"top\"\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Team ";
			$out .= "<br>&nbsp;&nbsp;&nbsp;&nbsp;Members:</b></font></td>\n";
			$out .= "<td colspan=\"6\" valign=\"top\"><font size=\"2\">$teamMembers</font></td>\n</tr>\n";
		}
		if (defined($activity)) {
			$out .= "<tr>\n<td colspan=\"1\" valign=\"\"top\"\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Scope:</b></font></td>\n";
			$out .= "<td colspan=\"6\"><font size=\"2\">$activity</font></td>\n</tr>\n";
		}
		if (defined($status)) {
			$out .= "<tr>\n<td valign=\"top\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Status:</b></font></td>\n";
			$out .= "<td colspan=\"6\"><font size=\"2\">$status</font></td>\n</tr>\n";
		}
		if (defined($notes)) {
			$out .= "<tr>\n<td valign=\"top\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Notes:</b></font></td>\n";
			$out .= "<td colspan=\"6\"><font size=\"2\">$notes</font></td>\n</tr>\n";
		}	
		if (defined($reschedule)) {
			$out .= "<tr>\n<td valign=\"top\"><font size=2><b>&nbsp;&nbsp;&nbsp;&nbsp;Reschedule Info:</b></font></td>\n";
			$out .= "<td colspan=\"6\"><font size=\"2\">$reschedule</font></td>\n</tr>\n";
		}		
		$out .= "</tr>\n";
		$out .= "<tr>\n<td colspan=\"7\"><hr></td></tr>\n";
	}
	$out .= "</table>\n";
	$out .= "<br>\n<hr>\n";
	$out .= "</body>\n</html>\n";
	return($out);
}
#########################################################################################################
# Name:                                                                                                 #
#  GenerateNewSurveillanceHeader                                                                           #
#                                                                                                       #
# Purpose:																															  #
# 	This function writes the page header for the Surveillance schedule.                                  #
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The audit schedule year specified in a two digit format	                                   #
#  $reportType - Type of report being specified by the header function. Either Supplier or Internal.    #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #                                                                        #
#  $dbh - database handle                                                                               #
######################################################################################################### 
sub GenerateNewSurveillanceHeader {

	my ($year, $reportType, $issuedByOrg, $schema, $dbh) = @_;
	my $sqlString;
	my $dateTime;
	my $header;
	my $out;
	my $queryYear = substr($year, 2, 2);
	my $sth = $dbh->prepare("SELECT TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') FROM DUAL");
	$sth->execute;
	$dateTime = $sth->fetchrow_array;
	$out = "<!doctype HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\n";
 	$out .= "<html>\n";
	$out .= "<head>\n";
	if ($reportType eq "LOG") {
		$out .= "<title>OCRWM FY-$year $issuedByOrg Yucca Mountain Surveillance Log</title>\n";
	}
	else {
		$out .= "<title>OCRWM FY-$year $issuedByOrg Yucca Mountain Surveillance Request List</title>\n";
	}
	$out .= "<style type=\"text/css\">\n";
	$out .= "	<!--\n";
	$out .= "		td.org_loc {padding-top: 0px; padding-left: 0px}\n";
	$out .= "	-->\n";
	$out .= "</style>\n";
	$out .= "</head>\n";
	$out .= "<body bgcolor=\"#FFFFFF\" leftmargin=\"15\">\n";
	$out .= "<center>\n";
	$out .= "<h2>OFFICE OF CIVILIAN RADIOACTIVE WASTE MANAGEMENT</h2>\n";
	if ($reportType eq "LOG" || $reportType eq "NEWLOG") {
		$out .= "<h3>OCRWM Fiscal Year-$year $issuedByOrg Yucca Mountain Surveillance Log<br>Status and Results</h3>\n";
		$out .= "</center>\n";
		$out .= "<b>Generated:</b> &nbsp; $dateTime<br>\n";
		$out .= "<hr>\n";
		$out .= "<table width=\"100%\" border=0 cellspacing=3 cellpadding=2>\n";
		#$out .= "<tr>\n";
		#$out .= "<td width=\"12%\" valign=\"top\"><b><font size=2>SURVEILLANCE<br>NUMBER</font></b></td>\n";
		#$out .= "<td width=\"10%\" valign=\"top\"><b><font size=2>ORG</font></b></td>\n";
		#$out .= "<td width=\"15%\" valign=\"top\"><b><font size=2>LOCATION</font></b></td>\n";
		#$out .= "<td width=\"10%\" valign=\"top\"><b><font size=2>PROG<br>ELEM</font></b></td>\n";
		#$out .= "<td width=\"15%\" valign=\"top\"><b><font size=2>START DATE-<br>END DATE</font></b></td>\n";
		#$out .= "<td width=\"10%\" valign=\"top\"><b><font size=2>DATE<br>COMPLETED</font></b></td>";
		#$out .= "<td valign=\"top\"><b><font size=2>DEF. DOCS ISSUED</font></b></td>\n</tr>\n";
   }
   else {
		$out .= "<h3>OCRWM Fiscal Year-$year $issuedByOrg Yucca Mountain Surveillance Request List</h3>\n";
		$out .= "</center>\n";
		$out .= "<b>Generated:</b> &nbsp; $dateTime<br>\n";
		$out .= "<hr>\n";
		$out .= "<table width=\"100%\" border=0 cellspacing=3  cellpadding=2>\n";
		$out .= "<tr>\n";
		$out .= "<td width=\"12%\" valign=\"top\"><b><font size=2>REQUEST NUMBER</font></b></td>\n";
		$out .= "<td width=\"15%\" valign=\"top\"><b><font size=2>ORG</font></b></td>\n";
		$out .= "<td width=\"15%\" valign=\"top\"><b><font size=2>LOCATION</font></b></td>\n";
		$out .= "<td width=\"15%\" valign=\"top\"><b><font size=2>REQUESTOR</font></b></td>\n";
		$out .= "<td width=\"15%\" valign=\"top\"><b><font size=2>REQUEST DATE</font></b></td>\n</tr>\n";	
   }
   return($out);
}

#########################################################################################################
# Name:                                                                                                 #
#  NewSurveillanceLog                                                                                      #
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
#  $date - Today's date                                                                                 #
#  $dbh - database handle                                                                               #
######################################################################################################### 
sub NewSurveillanceLog {

	my ($year, $issuedToOrg, $issuedByOrg, $schema, $dbh) = @_;
	my $sqlString;
	my ($sth1, $sth2, $sth3, $sth4, $sth5, $issuedToId, $issuedTo, $teamMembers, $reschedule);
	my ($id, $rev, $teamLeadId, $teamLead, $activity, $beginDate, $notes, $endDate, $cancelled, $status, $docId);
	my ($orgId, $locId, $org, $city, $state, $province, $completedDate, $elements, $out, $intExt, $issuedById, $supplierId);
	my ($title,$qard,$adequacy,$implementation,$effectiveness, $suborgId, $suborg, $estbeginDate, $estendDate);
	my $survSeq;
	my $queryYear = substr($year, 2, 2);
	my $issuedByOrgId = ($issuedByOrg eq "OQA") ? 28 : ($issuedByOrg eq "SNL") ? 33 : 1;
	#print "<br>-- $issuedByOrg -- <br>";
	if ($issuedToOrg == 0) {
		# Select all surveillances for a given surveillance year
		$sqlString = "SELECT issuedto_org_id, id, elements, status, team_lead_id, scope, TO_CHAR(begin_date, 'MM/DD/YYYY'), "
		             . "TO_CHAR(end_date, 'MM/DD/YYYY'), TO_CHAR(completion_date, 'MM/DD/YYYY'), "
		             . "TO_CHAR(estbegin_date, 'MM/YYYY'), TO_CHAR(estend_date, 'MM/DD/YYYY'), "
			     . "notes, cancelled, team_members, int_ext, issuedby_org_id, surveillance_seq, reschedule,"
			     . "title, qard_elements, adequacy, implementation, effectiveness, state "
			     . "FROM $schema.surveillance "
			     . "WHERE fiscal_year = $queryYear AND issuedby_org_id = $issuedByOrgId ORDER BY surveillance_seq";
	}
	else {
		# Select only those surveillances pertaining to a specific organization for a given surveillance year
		$sqlString = "SELECT issuedto_org_id, id, elements, status, team_lead_id, scope, "
		             . "TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), "
		             . "TO_CHAR(completion_date, 'MM/DD/YYYY'), TO_CHAR(estbegin_date, 'MM/YYYY'), TO_CHAR(estend_date, 'MM/DD/YYYY'), "
			     . "notes, cancelled, team_members, int_ext, issuedby_org_id, surveillance_seq, reschedule,"
			     . "title, qard_elements, adequacy, implementation, effectiveness, state "
			     . "FROM $schema.surveillance WHERE fiscal_year = $queryYear AND issuedto_org_id = $issuedToOrg "
			     . "AND issuedby_org_id = $issuedByOrgId ORDER BY surveillance_seq";
   }
   $sth1 = $dbh->prepare($sqlString);
   $sth1->execute;
  # $out .= "<tr>\n<td colspan=\"3\"><hr></td>\n</tr>\n";
	while (($issuedToId, $id, $elements, $status, $teamLeadId, $activity, $beginDate, $endDate, $completedDate, 
	        $estbeginDate, $estendDate, $notes, $cancelled, $teamMembers, $intExt, $issuedById, $survSeq, $reschedule, 
	        $title,$qard,$adequacy,$implementation,$effectiveness,$state) = $sth1->fetchrow_array) {
	 	$sth2 = $dbh->prepare("SELECT location_id, organization_id, supplier_id, suborganization_id FROM $schema.surveillance_org_loc "
			 						 . "WHERE surveillance_id = $id AND fiscal_year = $queryYear");
		$sth2->execute;
		$issuedToId = 0 unless (defined($issuedToId));
		$issuedById = 0 unless (defined($issuedById));
		$out .= "<tr>\n<td valign=top><font size=2><b>Surveillance Number:</b>&nbsp;&nbsp;" . &getSurvId($dbh, $issuedById, $issuedToId, $intExt, $year, $survSeq) . "</font></td>\n";
		$out .= "<td valign=top><font size=2><b>Lead:</b>&nbsp;";
		if (defined($teamLeadId) && $teamLeadId != 0) {
			$sth3 = $dbh->prepare("SELECT firstname || ' ' || lastname FROM $schema.users WHERE id = $teamLeadId");
			$sth3->execute;
			$teamLead = $sth3->fetchrow_array;
			$out .= "$teamLead";
		}
		$out .= "</font></td>\n<td valign=top><font size=2>";
		if (defined($reschedule)) {
			$out .= "<b>Rescheduled:</b>&nbsp;$reschedule";
		}
		elsif (defined($cancelled) && $cancelled eq "Y"  || ($state eq 'Cancelled')) {
			$out .= "<b>Performance Dates:</b>&nbsp;CANCELLED";
		}
		elsif (defined($beginDate)) {
			$out .= "<b>Performance Dates:</b>&nbsp;$beginDate";
			if (defined($endDate)) {
				$out .= "-$endDate";
			} else {
				$out .= " (in progress)";
			}
		}
		elsif (defined($estbeginDate)) {
			$out .= "<b>Scheduled:</b>&nbsp;$estbeginDate";
			#if (defined($estendDate)) {
				#$out .= "-$estendDate";
			#}
		}
		else {
			$out .= "&nbsp;";
		}
		if (defined($completedDate)) {
			$out .= "<br><b>Report Approved:</b>&nbsp;$completedDate";
		}
		$out .= "</font></td></tr>\n";
		my $sql = "";
		while (my @values = $sth2->fetchrow_array) {
			($locId, $orgId, $supplierId, $suborgId) = @values;
			$out .= "<tr>" if (defined($orgId) || defined($locId) || defined($supplierId));
			if (defined($orgId) || defined($supplierId)) {
				$sql = "SELECT abbr FROM $schema.organizations WHERE id = $orgId" if ($intExt eq "I");
				$sql = "SELECT company_name FROM $schema.qualified_supplier WHERE id = $supplierId" if ($intExt eq "E");
			 	$sth3 = $dbh->prepare($sql);
			 	$sth3->execute;
			 	$org = $sth3->fetchrow_array;
			}
			if (defined($orgId)) {
				$out .= "<td valign=top><font size=2><b>Organization:</b>&nbsp;$org</font></td>\n";
				if (defined($suborgId) && $orgId eq 1) {
					my @suborg = &getSuborganization(dbh=>$dbh,schema=>$schema,survID=>$id,fiscalyear=>$queryYear);
					$out .= "<td valign=top><font size=2><b>Suborg:</b>&nbsp;";
				        for (my $j = 0; $j < $#suborg; $j++) {
				        	$out .= (($j != 0) ? ", " : "") . "$suborg[$j]{suborg}";
				        }
				        $out .= "</font></td>";
				} else {
					$out .= "<td valign=top><font size=2>&nbsp;</font></td>";
				}
			}
			elsif (defined($supplierId)) {
				$out .= "<td valign=top colspan=2><font size=2><b>Supplier:</b>&nbsp;$org</font></td>\n";
			}
			if (defined($locId)) {
				$out .= "<td valign=top><font size=2><b>Location:</b>&nbsp;";
				$out .= &getLocation($dbh, $schema, $locId);
				$out .= "</font></td>\n";
			}
			$out .= "</tr>" if (defined($orgId) || defined($locId) || defined($supplierId));
		}
		$out .= "<tr><td colspan=2><font size=2><b>Surveillance Title:</b>&nbsp;$title</font></td>\n";
		$out .= "<td><font size=2><b>QA Elements:</b>&nbsp;" . &writeQARD(qard=>"$qard") . "</font></td></tr>\n";
		$out .= "<tr><td colspan=3><font size=2><b>Surveillance Scope Summary:</b>&nbsp;$activity</font></td></tr>\n";
		$out .= "<tr><td><font size=2><b>Results:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Adequacy - $adequacy</font></td>\n";
		$out .= "<td><font size=2>Implementation - $implementation</font></td><td><font size=2>Effectiveness - $effectiveness</font></td></tr>\n";
		$out .= "<tr><td colspan=3><font size=2>" . writeConditionReport(dbh => $dbh, schema => $schema, survID => $id, fiscalyear => $queryYear) . "</font></td></tr>\n";
				

		$out .= "<tr>\n<td colspan=\"7\"><hr></td></tr>\n";

	}
	$out .= "</table>\n";
	$out .= "</body>\n</html>\n";
	return($out);
}
#########################################################################################################
# Name:                                                                                                 #
#  GenerateLookaheadHeader                                                                           	#
#                                                                                                       #           
#  $dbh - database handle                                                                               #
######################################################################################################### 
sub GenerateLookaheadHeader {

	my ($schema, $dbh, $lookaheadType) = @_;
	my $sqlString;
	my $dateTime;
	my $header;
	my $out;
	my $sth = $dbh->prepare("SELECT TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') FROM DUAL");
	$sth->execute;
	$dateTime = $sth->fetchrow_array;
	$out = "<!doctype HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\n";
 	$out .= "<html>\n";
	$out .= "<head>\n";
	$out .= "<title>Surveillance Schedule - " . ( $lookaheadType eq "MONTH" ? "One Month " : "Two Week " ) . "Look-Ahead</title>\n";
	$out .= "<style type=\"text/css\">\n";
	$out .= "	<!--\n";
	$out .= "		td.org_loc {padding-top: 0px; padding-left: 0px}\n";
	$out .= "	-->\n";
	$out .= "</style>\n";
	$out .= "</head>\n";
	$out .= "<body bgcolor=\"#FFFFFF\" leftmargin=\"15\">\n";
	$out .= "<center>\n";
	$out .= "<h2>OFFICE OF CIVILIAN RADIOACTIVE WASTE MANAGEMENT</h2>\n";
	$out .= "<h3>BSC Surveillance Schedule - " . ( $lookaheadType eq "MONTH" ? "One Month " : "Two Week " ) . "Look-Ahead</h3>\n";
	$out .= "</center>\n";
	$out .= "<b>Generated:</b> &nbsp; $dateTime<br>\n";
	$out .= "<hr>\n";
	$out .= "<table width=\"100%\" border=\"0\" cellspacing=\"3\" cellpadding=\"2\">\n";
	$out .= "<tr>\n";
	$out .= "<td width=\"30\" valign=\"top\"><b><font size=2>SURVEILLANCE NUMBER</font></b></td>\n";
	$out .= "<td width=\"35%\" valign=\"top\"><b><font size=2>SCHEDULED<br>START DATE</font></b></td>\n";
	$out .= "<td width=\"35%\" valign=\"top\"><b><font size=2>SCHEDULED<br>END DATE</font></b></td></tr>\n";
   return($out);
}

#########################################################################################################
# Name:                                                                                                 #
#  Lookahead                                                                                      #
#                                                                                                       #                                                #
#  $dbh - database handle                                                                               #
######################################################################################################### 
sub Lookahead {

	my ($schema, $dbh, $lookaheadType) = @_;
	my $sqlString;
	my ($sth1, $sth2, $sth3, $sth4, $sth5, $issuedToId, $issuedTo, $teamMembers);
	my ($id, $rev, $teamLeadId, $teamLead, $activity, $beginDate, $notes, $endDate, $cancelled, $status, $docId);
	my ($orgId, $locId, $org, $city, $state, $province, $completedDate, $elements, $out, $intExt, $issuedById, $supplierId);
	my ($survSeq, $title, $estbegin, $estend, $fy);

	# Select all surveillances for a given surveillance year
	$sqlString = "SELECT issuedto_org_id, id, elements, status, team_lead_id, scope, TO_CHAR(begin_date, 'MM/DD/YYYY'), "
		. "TO_CHAR(end_date, 'MM/DD/YYYY'), TO_CHAR(completion_date, 'MM/DD/YYYY'), "
		. "notes, cancelled, team_members, int_ext, issuedby_org_id, surveillance_seq, title, to_char(estbegin_date,'MM/DD/YYYY'), "
		. "to_char(estend_date,'MM/DD/YYYY'), fiscal_year FROM $schema.surveillance "
		. "WHERE issuedby_org_id = 1 AND ((estbegin_date between sysdate and (sysdate + " . ( $lookaheadType eq "MONTH" ? " 31 " : " 14 " ) . ")) OR "
		.  "(begin_date between sysdate and (sysdate + "  . ( $lookaheadType eq "MONTH" ? " 31 " : " 14 " ) . ") AND estbegin_date IS NULL)) "
		. "ORDER BY to_char(estbegin_date,'YYYYMMDD') || to_char(begin_date,'YYYYMMDD')";


   $sth1 = $dbh->prepare($sqlString);
   $sth1->execute;
   $out .= "<tr>\n<td colspan=\"7\"><hr></td>\n</tr>\n";
	while (($issuedToId, $id, $elements, $status, $teamLeadId, $activity, $beginDate, $endDate, $completedDate, 
	        $notes, $cancelled, $teamMembers, $intExt, $issuedById, $survSeq, $title, $estbegin, $estend, $fy) = $sth1->fetchrow_array) {
	 	$sth2 = $dbh->prepare("SELECT location_id, organization_id, supplier_id FROM $schema.surveillance_org_loc "
			 						 . "WHERE surveillance_id = $id AND fiscal_year = $fy");
		$sth2->execute;
		$issuedToId = 0 unless (defined($issuedToId));
		$issuedById = 0 unless (defined($issuedById));
		$out .= "<tr>\n<td valign=\"top\"><font size=2>" . &getSurvId($dbh, $issuedById, $issuedToId, $intExt, ($fy < 50 ? 2000 + $fy : 1900 + $fy), $survSeq) . "</font></td>\n";

		$out .= "<td valign=\"top\"><font size=2>" . (defined($estbegin) ? "$estbegin" : defined($beginDate) ? "$beginDate" : "No Data") . "</font></td>\n" ;
		$out .= "<td valign=\"top\"><font size=2>" . (defined($estend) ? "$estend" : defined($endDate) ? "$endDate" : "No Data") . "</font></td></tr>\n" ;
		$out .= "<tr><td valign=\"top\" colspan=3><font size=2>&nbsp;&nbsp;&nbsp;&nbsp;" . (defined($title) ? "Title:" : "Activity:");
		$out .= "&nbsp;&nbsp;&nbsp;&nbsp;" . (defined($title) ? "$title" : "$activity") . "</font></td></tr>\n" ;

		if (defined($teamLeadId) && $teamLeadId != 0) {
			$sth3 = $dbh->prepare("SELECT firstname || ' ' || lastname FROM $schema.users WHERE id = $teamLeadId");
			$sth3->execute;
			$teamLead = $sth3->fetchrow_array;
			$out .= "<tr><td colspan=3><font size=2>&nbsp;&nbsp;&nbsp;&nbsp;Team Lead:&nbsp;&nbsp;&nbsp;&nbsp;$teamLead</font></td></tr>\n";
		}
		$out .= "<tr>\n<td colspan=\"7\"><hr></td></tr>\n";
	}
	$out .= "</table>\n";
	$out .= "<br>\n<hr>\n";
	$out .= "</body>\n</html>\n";
	return($out);
}

#########################################################################################################
# Name:                                                                                                 #
#  GenerateInProgressHeader                                                                           	#
#                                                                                                       #           
#  $dbh - database handle                                                                               #
######################################################################################################### 
sub GenerateInProgressHeader {

	my ($fy, $schema, $dbh) = @_;
	my $sqlString;
	my $dateTime;
	my $header;
	my $out;
	my $sth = $dbh->prepare("SELECT TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') FROM DUAL");
	$sth->execute;
	$dateTime = $sth->fetchrow_array;
	$out = "<!doctype HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">\n";
 	$out .= "<html>\n";
	$out .= "<head>\n";
	$out .= "<title>Surveillances In Progress</title>\n";
	$out .= "<style type=\"text/css\">\n";
	$out .= "	<!--\n";
	$out .= "		td.org_loc {padding-top: 0px; padding-left: 0px}\n";
	$out .= "	-->\n";
	$out .= "</style>\n";
	$out .= "</head>\n";
	$out .= "<body bgcolor=\"#FFFFFF\" leftmargin=\"15\">\n";
	$out .= "<center>\n";
	$out .= "<h2>OFFICE OF CIVILIAN RADIOACTIVE WASTE MANAGEMENT</h2>\n";
	$out .= "<h3>BSC Fiscal Year-$fy Surveillance Schedule - Surveillances In Progress</h3>\n";
	$out .= "</center>\n";
	$out .= "<b>Generated:</b> &nbsp; $dateTime<br>\n";
	$out .= "<hr>\n";
	$out .= "<table width=\"100%\" border=\"0\" cellspacing=\"3\" cellpadding=\"2\">\n";
	$out .= "<tr>\n";
	$out .= "<td width=\"30\" valign=\"top\"><b><font size=2>SURVEILLANCE NUMBER</font></b></td>\n";
	$out .= "<td width=\"35%\" valign=\"top\"><b><font size=2>START DATE</font></b></td>\n";
	$out .= "<td width=\"35%\" valign=\"top\"><b><font size=2>END DATE</font></b></td></tr>\n";
   return($out);
}

#########################################################################################################
# Name:                                                                                                 #
#  InProgress                                                                                      #
#                                                                                                       #                                                #
#  $dbh - database handle                                                                               #
######################################################################################################### 
sub InProgress {

	my ($fy, $schema, $dbh) = @_;
	my $sqlString;
	my ($sth1, $sth2, $sth3, $sth4, $sth5, $issuedToId, $issuedTo, $teamMembers);
	my ($id, $rev, $teamLeadId, $teamLead, $activity, $beginDate, $notes, $endDate, $cancelled, $status, $docId);
	my ($orgId, $locId, $org, $city, $state, $province, $completedDate, $elements, $out, $intExt, $issuedById, $supplierId);
	my ($survSeq, $title, $estbegin, $estend);

	my $queryYear = substr($fy, 2, 2);
	# Select all surveillances for a given surveillance year
	$sqlString = "SELECT issuedto_org_id, id, elements, status, team_lead_id, scope, TO_CHAR(begin_date, 'MM/DD/YYYY'), "
		. "TO_CHAR(end_date, 'MM/DD/YYYY'), TO_CHAR(completion_date, 'MM/DD/YYYY'), "
		. "notes, cancelled, team_members, int_ext, issuedby_org_id, surveillance_seq, title, to_char(estbegin_date,'MM/DD/YYYY'), "
		. "to_char(estend_date,'MM/DD/YYYY') FROM $schema.surveillance "
		. "WHERE fiscal_year = $queryYear AND issuedby_org_id = 1 AND (begin_date < sysdate OR estbegin_date < sysdate) AND completion_date IS NULL "
		. "ORDER BY surveillance_seq ";


   $sth1 = $dbh->prepare($sqlString);
   $sth1->execute;
   $out .= "<tr>\n<td colspan=\"7\"><hr></td>\n</tr>\n";
	while (($issuedToId, $id, $elements, $status, $teamLeadId, $activity, $beginDate, $endDate, $completedDate, 
	        $notes, $cancelled, $teamMembers, $intExt, $issuedById, $survSeq, $title, $estbegin, $estend) = $sth1->fetchrow_array) {
	 	$sth2 = $dbh->prepare("SELECT location_id, organization_id, supplier_id FROM $schema.surveillance_org_loc "
			 						 . "WHERE surveillance_id = $id AND fiscal_year = $queryYear");
		$sth2->execute;
		$issuedToId = 0 unless (defined($issuedToId));
		$issuedById = 0 unless (defined($issuedById));
		$out .= "<tr>\n<td valign=\"top\"><font size=2>" . &getSurvId($dbh, $issuedById, $issuedToId, $intExt, $fy, $survSeq) . "</font></td>\n";
		$out .= "<td valign=\"top\"><font size=2>" . (defined($beginDate) ? "$beginDate" : "No Data") . "</font></td>\n" ;
		$out .= "<td valign=\"top\"><font size=2>" . (defined($endDate) ? "$endDate" : "No Data") . "</font></td></tr>\n" ;
		$out .= "<tr><td>&nbsp;</td><td valign=\"top\"><font size=2>Scheduled Start:&nbsp;" . (defined($estbegin) ? "$estbegin" : "No Data") . "</font></td>\n" ;
		$out .= "<td valign=\"top\"><font size=2>Scheduled End:&nbsp;" . (defined($estend) ? "$estend" : "No Data") . "</font></td></tr>\n" ;
		$out .= "<tr><td valign=\"top\" colspan=3><font size=2>&nbsp;&nbsp;&nbsp;&nbsp;" . (defined($title) ? "Title:" : "Activity:");
		$out .= "&nbsp;&nbsp;&nbsp;&nbsp;" . (defined($title) ? "$title" : "$activity") . "</font></td></tr>\n" ;

		if (defined($teamLeadId) && $teamLeadId != 0) {
			$sth3 = $dbh->prepare("SELECT firstname || ' ' || lastname FROM $schema.users WHERE id = $teamLeadId");
			$sth3->execute;
			$teamLead = $sth3->fetchrow_array;
			$out .= "<tr><td colspan=3><font size=2>&nbsp;&nbsp;&nbsp;&nbsp;Team Lead:&nbsp;&nbsp;&nbsp;&nbsp;$teamLead</font></td></tr>\n";
		}
		$out .= "<tr>\n<td colspan=\"7\"><hr></td></tr>\n";
	}
	$out .= "</table>\n";
	$out .= "<br>\n<hr>\n";
	$out .= "</body>\n</html>\n";
	return($out);
}
#########################################################################################################
# Name:                                                                                                 #
#  IntegratedPDFReport                                                                                    #
#                                                                                                       #
# Purpose:																															  #
# 	This function will combine and write all the audits for a Internal audit schedule and all the
#  audits for external audit by doing union of two tables for a given fiscal year.       #
#  
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The audit schedule year specified in a two digit format											     #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #
#  $dbh - database handle                                                                               #
######################################################################################################### 


sub IntegratedPDFReport{
my ($year, $scheduleType, $audit, $surv, $bsc, $snl, $oqa, $ocrwm, $other, $internal, $external, $teamcolumn, $showcancelled, $dateRangeType, $fromdate, $todate, $schema, $dbh) = @_;
my @integratedList = &getIntegratedList($year, $scheduleType, $audit, $surv, $bsc, $snl, $oqa, $ocrwm, $other, $internal, $external, $teamcolumn, $showcancelled, $dateRangeType, $fromdate, $todate, $schema, $dbh);
my $out;
my $sth2;
my @locs;
my $loc;
my $locid;
my $organization;
my $orgid;
my $activity_type;
my $assessmentID;
my $team;
my $lead_name;
my $plandate;
my $CRcount;
my $queryYear = substr($year, 2, 2);
my $fontSize = 7;

## Find the System Date
my $sth = $dbh->prepare ("select to_char(sysdate,'MM/YYYY') from dual");
$sth->execute;
my $mmyyyy = $sth->fetchrow_array;
my $current_year = substr($mmyyyy,-4);
my $current_month = substr($mmyyyy,0,2);

#    my $hashRef = $args{settings};
#    my %settings = %$hashRef;
    my $xlsBuff = '';
    my $output = "";
#    my @delg = getCurrentPendingDelegations(dbh => $args{dbh}, schema => $args{schema});

#print STDERR "---> $year --- $audit\n";
    
    my $pdf = new PDF;
    $pdf->setup(orientation => 'landscape', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5,
        cellPadding => 4);

#######

## Headers

    my $reportDate = &getSysdate(dbh=>$dbh);
    my $colCount = 1;
    my @colWidths = (762);
    my @colAlign = ("center");
    my $fontID = $pdf->setFont(font => "Helvetica-Bold", fontSize => 12.0);
    my @colData = ("OCRWM " . ($dateRangeType eq 'FISCALYEAR' ?  "FY $year " : "$fromdate - $todate ") . "Integrated Assessment Schedule\n\n");
    $pdf->addHeaderRow(fontSize => 12, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
               
    ##Generate the report date under the header
    @colData = ("Generated: $reportDate");
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID,
             colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);
    ##
    
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);

    $colCount =  $teamcolumn eq 'TEAMCOLUMN' ? 6 : 5;
    ## $colCount =  $teamcolumn eq 'TEAMCOLUMN' ? 8 : 7;
    
    @colWidths = (32,147,100,120,200,50);
    ## *Previous* @colWidths = (32,45,52,120,100,200,50,50);
    
    @colAlign = ("center", "center", "center", "center", "center", "center");
    ## *Previous* @colAlign = ("center", "center", "center", "center", "center", "center", "center", "center");
    
    @colData = ("\n\nPlan", "\n\nStatus/\nResults/\nComments", "\n\nAssessment Number/\nActivity Type", "\n\nOrganization Being Assessed/\nLocation", "\n\nScope", "\nResponsible Team");
    ## *Previous* @colData = ("\n\nPlan", "\n\nScheduled/\nActual", "\n\nStatus/\nResults", "\nOrg Performing Assessment/\nAssessment Number/\nActivity Type", "\nOrganization Being\nAssessed/Title/\nLocation", "\n\nScope/Comments", "\nQARD\nElements\nAudited", "\nResponsible Team");
    
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID, rowColor => 0.8,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0.01);
    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
    $pdf->newPage(orientation => 'landscape', useGrid => 'F');
    
    
## Footers
# 
    $colCount = 3;
    @colWidths = (75,500,75);
    @colAlign = ("center","center","right");
    @colData = ("","\n\n\n\n\nPage <page>", "\n\n\n\n\n$reportDate\n");
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    $pdf->addFooterRow(fontSize => 6, fontID => $fontID,
               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>0);


# page contents    
    $colCount =   $teamcolumn eq 'TEAMCOLUMN' ? 6 : 5;
    ## $colCount =  $teamcolumn eq 'TEAMCOLUMN' ? 8 : 7;
    @colWidths = (32,147,100,120,200,50);
    ## *Previous* @colWidths = (32,45,52,120,100,200,50,50);
    $fontID = $pdf->setFont(font => "helvetica", fontSize => 4.0);
    @colAlign = ("left", "left", "left", "left", "left", "left");
    ## *Previous* @colAlign = ("left", "left", "left", "left", "left", "left", "left", "left");
    
    for (my $j=0; $j<$#integratedList; $j++) {  
    	my ($forecastdate,$begindate,$state,$id,$scope,$issuedto,$issuedby,$teamlead,$member,$enddate,$qard,$title,$results,$overall,$FY,$completiondate,$cancelled,$reschedule,$sortfield,$intext,$rev,$audittype, $seq, $notes, $otherid, $scheduletype, $estbegin, $estend) = 
         ($integratedList[$j]{forecastdate},$integratedList[$j]{begindate},$integratedList[$j]{state},$integratedList[$j]{id},
         $integratedList[$j]{scope},$integratedList[$j]{issuedto},$integratedList[$j]{issuedby},$integratedList[$j]{lead},$integratedList[$j]{member},
         $integratedList[$j]{enddate},$integratedList[$j]{qard},$integratedList[$j]{title},$integratedList[$j]{results},$integratedList[$j]{overall},$integratedList[$j]{FY},$integratedList[$j]{completiondate},
         $integratedList[$j]{cancelled},$integratedList[$j]{reschedule},$integratedList[$j]{sortfield},$integratedList[$j]{intext},
         $integratedList[$j]{revision},$integratedList[$j]{audittype},$integratedList[$j]{seq},$integratedList[$j]{notes},$integratedList[$j]{otherid},$integratedList[$j]{scheduletype},
         $integratedList[$j]{estbegin},$integratedList[$j]{estend});

  	 my $idFY = $FY > 50 ? $FY + 1900 : $FY + 2000;
  	 my $crtype = $scheduletype eq 'S' ? 'S' : $intext.$scheduletype;
  	 my $org = &getOrganization2($dbh, $schema, $issuedby);
  	 my $issuedtoorg = &getOrganization2($dbh, $schema, $issuedto);
  	 
   	 if ($org eq 'GAO' || $org eq 'OIG') {
       	 	$activity_type = $org." Audit";
   	 }
   	 elsif ($org eq 'EM') {
	        $activity_type = "EM/RW Audit";
   	 }
   	 elsif ($org eq 'PAT') {
       	 	$activity_type = "Program Assessment";
   	 }
   	 else {
       		$activity_type =  ($scheduletype eq 'A') ? ($intext eq 'I' ? "Internal" : "Supplier") . " Audit" : ($scheduletype eq 'S') ? ($intext eq 'I' ? "Internal" : "Supplier") . " Surveillance" : "";
  	 }
  	 if ($intext eq 'I' && $scheduletype eq 'A')  {
  	        if (($org eq 'GAO') || ($org eq 'OIG') || ($org eq 'PAT')) {
  	             $assessmentID = $otherid;
  	        }
  	        else {
      	 	     $assessmentID = &getInternalAuditId($dbh, $issuedby, $issuedto, $audittype, $idFY, $seq);
      	 	}
  	 }
  	 elsif ($intext eq 'E' && $scheduletype eq 'A') {
      	 	$assessmentID = &getExternalAuditId($dbh, $issuedby, $issuedto, $audittype, $idFY, $seq);
  	 }
  	 elsif ($scheduletype eq 'S')  {
  		$assessmentID = &getSurvId($dbh, $issuedby, $issuedto, $intext, $idFY, $seq);
  	 }    
   	 my $sqlstring = ""; 
   	 if ($intext eq 'E' && $scheduletype eq 'A')  {
       		$sqlstring = "SELECT location_id FROM $schema.external_audit_locations WHERE external_audit_id = $id AND fiscal_year = $FY AND revision = 0 ";
   	 }
   	 elsif ($intext eq 'I' && $scheduletype eq 'A') {
       		$sqlstring = "SELECT location_id FROM $schema.internal_audit_org_loc WHERE internal_audit_id = $id AND fiscal_year = $FY AND revision = 0 ";
   	 }
   	 elsif ($scheduletype eq 'S') {
       		$sqlstring = "SELECT location_id FROM $schema.surveillance_org_loc WHERE surveillance_id = $id AND fiscal_year = $FY ";
   	 } 
   	 $sth2 = $dbh->prepare($sqlstring);
   	 $sth2->execute;
   	 my $first = 1;
   	 $loc = "";
   	 while ($locid = $sth2->fetchrow_array) {
 		$loc .= ($first ? "" : ", ") . &getLocation2($dbh, $schema, $locid);
 		$first = 0;
   	 }
   	 
   	 $sqlstring = "";
   	 if ($intext eq 'E' && $scheduletype eq 'A')  {
   	        $sqlstring = "SELECT qualified_supplier_id FROM $schema.external_audit WHERE id = $id AND fiscal_year = $FY AND revision = 0 ";
   	 }
   	 elsif ($intext eq 'I' && $scheduletype eq 'A') {
   	        $sqlstring = "SELECT organization_id FROM $schema.internal_audit_org_loc WHERE internal_audit_id = $id AND fiscal_year = $FY AND revision = 0 ";
   	 }
   	 elsif ($intext eq 'E' && $scheduletype eq 'S')  {
	    	$sqlstring = "SELECT supplier_id FROM $schema.surveillance_org_loc WHERE surveillance_id = $id AND fiscal_year = $FY ";
   	 }
   	 elsif ($intext eq 'I' && $scheduletype eq 'S')  {
	 	$sqlstring = "SELECT organization_id FROM $schema.surveillance_org_loc WHERE surveillance_id = $id AND fiscal_year = $FY ";
   	 }
   	 $sth2 = $dbh->prepare($sqlstring);
   	 $sth2->execute;
   	 if ($intext eq 'I') {
   	      $first = 1;
   	      $organization = "";
   	      while ($orgid = $sth2->fetchrow_array) {
 		$organization .= ($first ? "" : ", ") . &getOrganizationName($dbh, $schema, $orgid);
 		$first = 0;
 	      }
   	 }
   	 elsif ($intext eq 'E') {
   	        $organization = "";
   	        $orgid = $sth2->fetchrow_array;
   	        $organization = &getSupplier2($dbh, $schema, $orgid);
   	 }
   	 
         if (defined($teamlead) && $teamlead != 0) {
  		my $sth3 = $dbh->prepare("SELECT upper(substr(firstname,1,1)) || '. ' || upper(lastname) FROM $schema.users WHERE id = $teamlead");
  		$sth3->execute;
  		$lead_name = $sth3->fetchrow_array;
  	 }
  	 else {$lead_name = 'TBD';}
  	 #$plandate = ($scheduletype eq 'S' ? $estbegin . (defined($estend) ? "-$estend" : "") : defined($forecastdate) ? "$forecastdate" : "");
  	 $plandate = ($scheduletype eq 'S' ? (defined($estbegin) ? "$estbegin" : "") : (defined($forecastdate) ? "$forecastdate" : ""));
  	 #$plandate = (defined($forecastdate) ? "$forecastdate" : "");
  	 $CRcount = &writeConditionCount($dbh, $schema, $id, $FY, $crtype);
  	 
  	 ########
  	 # the Integrated Assessement Report should only show all surveillances and audits for future 3 months and
  	 # completed surveillances and audits for the past one month from the "today date".
  	 
  	 @colData = ($plandate, &writeStatus(state=>"$state",forecast=>"$forecastdate",startdate=>"$begindate",enddate=>"$enddate",completiondate=>"$completiondate",cancelled=>"$cancelled",reschedule=>"$reschedule",estbegin=>$estbegin,estend=>$estend)."\n$results\n$notes", "$assessmentID\n$activity_type","$organization\n$loc","$scope", "$lead_name\n$member");
  	 
  	 #########################################
	 ### ** Previous ** @colData = ($plandate,(defined($begindate) ? "$begindate" : "") . (defined($enddate) ? "-\n$enddate" : ""),
	 ## &writeStatus(state=>"$state",forecast=>"$forecastdate",startdate=>"$begindate",enddate=>"$enddate",completiondate=>"$completiondate",cancelled=>"$cancelled",reschedule=>"$reschedule",estbegin=>$estbegin,estend=>$estend). (($overall ne '') ? "\n$overall" : "\n") . (($CRcount ne '') ? "\n$CRcount" : "") . (($results ne '') ? "\n$results" : ""),
	 ## ($org eq 'BSC' ? "BSC QA" : $org eq 'EM' ? "EM/RW" : $org eq 'OCRWM' ? "OQA" : $org)."\n$assessmentID\n$activity_type","$issuedtoorg\n$title \n$loc","$scope", &writeQARD(qard=>"$qard"), "$lead_name\n$member");
         #########################################
  	 if ($dateRangeType eq 'FISCALYEAR') {
  	       	 
  	          my $planyear = substr($plandate, -4);
  	          my $planmonth = substr($plandate,0,2);
  	          if ($current_year > $planyear) {         ## Show only the December Reports if the status is complete
  	              if ($state eq "Complete") {
  	                  if (($planmonth - $current_month) == 11) {
  	                       $pdf->tableRow(fontSize => $fontSize, fontID => $fontID,
		               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>1.00);
                               $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
                          }
                      }
                      elsif ($state ne "Cancelled") {
                          $pdf->tableRow(fontSize => $fontSize, fontID => $fontID,
			   colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>1.00);
			   $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
                     }
                  }
  	         elsif ($planyear == $current_year) {
  	              if ($state eq "Complete") {
  	                  if (($current_month == $planmonth) || (($current_month - $planmonth) == 1) || (($planmonth - $current_month) == 3) || (($planmonth - $current_month) == 2) || (($planmonth - $current_month) == 1)) {     ## Show the reports for the past one month from the current month
  	                       $pdf->tableRow(fontSize => $fontSize, fontID => $fontID,                                                             ## Show reports for future 3 months from current month
                               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>1.00);
                               $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
                          }
                      }
                      elsif ($state ne "Cancelled") {
                          if (($current_month == $planmonth) || (($current_month - $planmonth) ge 1) || (($planmonth - $current_month) == 3) || (($planmonth - $current_month) == 2) || (($planmonth - $current_month) == 1)) {     ## Show the reports for the past one month from the current month
  	                       $pdf->tableRow(fontSize => $fontSize, fontID => $fontID,                                                             ## Show reports for future 3 months from current month
                               colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>1.00);
                               $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
                          }
                     }
                      
                 }
                elsif ($planyear > $current_year) {
                      if ((($current_month - $planmonth) == 9) || (($current_month - $planmonth) == 10) || (($current_month - $planmonth) == 11)) {   ## Show reports for future 3 months 
                            $pdf->tableRow(fontSize => $fontSize, fontID => $fontID,                                                             ## Show reports for future 3 months from current month
		            colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>1.00);
		            $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
                      }
                }
           
        }
        else {
            $pdf->tableRow(fontSize => $fontSize, fontID => $fontID,
	    colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colData, border=>1.00);
	    $xlsBuff .= formatXLSRow(cols=>$colCount, row=>\@colData);
        }
        
    }
 
 ## finish report
     my $repBuff = '';
     $repBuff = $pdf->finish;

 ########    
     
     if (1) {
         my $mimeType = 'application/pdf';
         #my $mimeType = 'application/vnd.ms-excel';
         $output .= "Content-type: $mimeType\n\n";
         #$output .= "Content-disposition: inline; filename=Test.pdf\n";
         $output .= "\n";
     }
     $output .= $repBuff;
     #$output .= $xlsBuff;
 
     
 
    return($output);

}

#########################################################################################################
# Name:                                                                                                 #
#  SurveillanceRequest                                                                                  #
#                                                                                                       #
# Purpose:												#																  #
# 	This function will write all the audits for a External audit schedule for a given fiscal year.  #
#  The two types of schedules that this function will generate are the working or the accepted schedule #
#                                                                                                       #
# Parameters:                                                                                           #
#	$year - The audit schedule year specified in a two digit format				        #
#  $scheduleType - Type of schedule being generated either a working or accepted schedule               #
#  $dbh - database handle                                                                               #
######################################################################################################### 
sub SurveillanceRequest {

	my ($year, $issuedByOrg, $schema, $dbh) = @_;
	my $sqlString;
	my ($sth, $sth1);
	my ($reqId, $survId, $reasonForRequest, $requestor, $requestDate, $subjectDetail, $subjectLine, $disaprovalRationale);
	my ($beginDate, $teamLeadId, $org, $displayId, $issuedToId, $teamLead, $issuedToOrg, $city, $state, $province);
	my ($out, $intExt, $issuedById, $survSeq);
	my $queryYear = substr($year, 2, 2);
	my $issuedByOrgId = ($issuedByOrg eq "OQA") ? 28 : 1;
	
	$sqlString = "SELECT id, surveillance_id, reason_for_request, requestor, TO_CHAR(request_date, 'MM/DD/YYYY'), "
	             . "subject_detail, subject_line, disapproval_rationale FROM $schema.surveillance_request "
					 . "WHERE fiscal_year = $queryYear AND (issuedby_org_id = $issuedByOrgId OR issuedby_org_id IS NULL) ORDER BY id";
   $sth = $dbh->prepare($sqlString);
   $sth->execute;
   $out = "<tr>\n<td colspan=\"5\"><hr></td>\n</tr>\n";
   while (($reqId, $survId, $reasonForRequest, $requestor, $requestDate, $subjectDetail, $subjectLine, $disaprovalRationale) 
           = $sth->fetchrow_array) {
		$sqlString = "SELECT abbr, city, state, province FROM $schema.request_org_loc a, $schema.organizations b, $schema.locations c "
		   			 . "WHERE a.fiscal_year = $queryYear AND a.request_id = $reqId "
		   			 . "AND b.id = a.organization_id AND c.id = a.location_id";
		$sth1 = $dbh->prepare($sqlString);
		$sth1->execute;
		$out .= "<td valign=top><font size=\"2\">" . &getSurvRequestId($dbh, $issuedByOrgId, $issuedToId, $year, $reqId) . "</font></td>\n";
		$out .= "<td class=org_loc colspan=2 valign=top><table border=0 width=100%>";
		while (($org, $city, $state, $province) = $sth1->fetchrow_array) {
			$out .= "<tr>\n";
			if (defined($org)) {
				$out .= "<td  width=50%><font size=\"2\">$org</font></td>\n";
   		}
   		else {
   			$out .= "<td width=50%><font size=\"2\">&nbsp;</font></td>\n";
   		}
			if (defined($city) && defined($state) && !(defined($province))) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$out .= "<td valign=\"top\"><font size=2>$city,&nbsp;&nbsp;$state</font></td>\n";
			}
			elsif (!(defined($city)) && defined($state) && !(defined($province))) {
				$out .= "<td valign=\"top\"><font size=2>$state</font></td>\n";
			}
			elsif (defined($city) && !(defined($state)) && defined($province) ) {
				$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$out .= "<td valign=\"top\"><font size=2>$city,&nbsp;&nbsp;$province</font></td>\n";
			}
			elsif (defined($city) && !(defined($state)) && !(defined($province))) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$out .= "<td valign=\"top\"><font size=2>$city</font></td>\n";
			}
			elsif (!(defined($city)) && !(defined($state)) && defined($province)) {
				$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$out .= "<td valign=\"top\"><font size=2>$province</font></td>\n";
			}
			else {
				$out .= "<td valign=\"top\"><font size=2>&nbsp;</font></td>\n";
			}
			$out .= "</tr>\n";
		}
	   $out .= "</table></td>";
		if (defined($requestor)) {
			$out .= "<td><font size=\"2\">$requestor</font></td>\n";
		}
		else {
			$out .= "<td><font size=\"2\">&nbsp;</font></td>\n";
		}
		if (defined($requestDate)) {
			$out .= "<td><font size=\"2\">$requestDate</font></td>\n";
		}
		else {
			$out .= "<td><font size=\"2\">&nbsp;</font></td>\n";
		}
		$out .= "</tr>\n";
   	if (defined($reasonForRequest)) {
		   $out .= "<tr>\n<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Reason for<br>&nbsp;&nbsp;&nbsp;&nbsp;Request:</b></font>";
		   $out .= "</td><td colspan=\"4\" valign=\"top\"><font size=\"2\">$reasonForRequest</font></td>\n</tr>\n";
   	}
   	if (defined($subjectLine)) {
   		$out .= "<tr>\n<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Subject Line:</b></font>";
   		$out .= "</td><td colspan=\"4\"><font size=\"2\">$subjectLine</font></td>\n</tr>\n";
   	}
   	if (defined($subjectDetail)) {
		   $out .= "<tr>\n<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Subject Detail:</b></font>";
		   $out .= "</td><td colspan=\"4\"><font size=\"2\">$subjectDetail</font></td>\n</tr>\n";
   	}
   	if (defined($disaprovalRationale)) {
			$out .= "<tr>\n<td valign=\"top\" colspan=\"3\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Disapproval<br>&nbsp;&nbsp;&nbsp;&nbsp;Rationale:</b></font>";
			$out .= "</td><td colspan=\"4\" valign=\"top\"><font size=\"2\">&nbsp;$disaprovalRationale</font></td>\n</tr>\n";
   	}
	if (defined($survId) && $survId gt "") {
		$sqlString = "SELECT id, TO_CHAR(begin_date, 'MM/DD/YYYY'), team_lead_id, issuedto_org_id, issuedby_org_id, int_ext, surveillance_seq "
					 . "FROM $schema.surveillance WHERE fiscal_year = $queryYear AND id = $survId";
		$sth1 = $dbh->prepare($sqlString);
		$sth1->execute;
		($survId, $beginDate, $teamLeadId, $issuedToId, $issuedById, $intExt, $survSeq) = $sth1->fetchrow_array;
		if (defined($survId)) {
			$out .= "<tr>\n<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Surveillance<br>&nbsp;&nbsp;&nbsp;&nbsp;Number:</b></font>";
			$out .= "</td><td valign=\"bottom\" colspan=\"4\"><font size=\"2\">" . &getSurvId($dbh, $issuedById, $issuedToId, $intExt, $year, $survSeq) . "</font></td></tr>\n";
			if (defined($beginDate) && $beginDate gt "") {                 
				$out .= "<tr>\n<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Begin Date:</b></font>";
				$out .= "</td><td colspan=\"4\"><font size=\"2\">$beginDate</font></td>\n</tr>\n";
			}
			if (defined($teamLeadId) && $teamLeadId != 0) {
				$sqlString = "SELECT firstname || ' ' || lastname FROM $schema.users "
								 . "WHERE id = $teamLeadId";
				$sth1 = $dbh->prepare($sqlString);
				$sth1->execute;
				$teamLead = $sth1->fetchrow_array;
				$out .= "<tr>\n<td valign=\"top\"><font size=\"2\"><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Lead:</b></font>";
				$out .= "</td><td colspan=\"4\"><font size=\"2\">$teamLead</font></td></tr>\n";
			}
		}
	}
   	$out .= "<tr><td colspan=\"5\"><hr></td></tr>";
   }
	$out .= "</table>\n";
	$out .= "<br>\n<hr>\n";
	$out .= "</body>\n</html>\n";
	return($out);
}

###################################################################################################################


sub MailExternalSchedule {
   my ($year, $schema, $dbh, $emailAddress, $isApproverReport) = @_;
	my ($ocrwm, $dateTime, $name, $title, $sth, $revision, $approveDate, $approver);
	my ($id, $rev, $auditType, $auditSeq, $teamLeadId, $teamLead, $teamMembers, $scope);
	my ($issuedTo, $issuedToId, $completedDate, $forecastDate, $beginDate, $modified);
	my ($orgId, $locId, $org, @location, $city, $state, $province, $rowCount, $endDate, $notes, $cancelled);
	my ($location, $number, $dates, $status, $qualifiedSupplierId, $product, $sth1, $issuedById, $approver2, $approveDate2);
	my $queryYear = substr($year, 2, 2);
	my $signatorTitle = "BSC Manager of Quality Assurance";
	$sth = $dbh->prepare("SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') FROM DUAL");
	$sth->execute;
	my $currentTime = $sth->fetchrow_array;
	my $sqlString;
	if ($year < 2004) {
   		$sqlString = "SELECT revision, TO_CHAR(approval_date, 'MM/DD/YYYY'), to_char(approval2_date, 'MM/DD/YYYY'), "
   		       . "firstname || ' ' || lastname, firstname || ' ' || lastname "
	               . "FROM $schema.audit_revisions, $schema.users WHERE "
	    	       . "fiscal_year = $queryYear and revision = (select max(revision) FROM "
	    	       . "$schema.audit_revisions where fiscal_year = $queryYear AND audit_type = 'E') "
	    	       . "AND approver = username AND audit_type = 'E'";  
	} else {
		$sqlString = "SELECT revision, TO_CHAR(approval_date, 'MM/DD/YYYY'), TO_CHAR(approval2_date, 'MM/DD/YYYY'), "
			. "u.firstname || ' ' || u.lastname, v.firstname || ' ' || v.lastname "
	    	        . "FROM $schema.audit_revisions a, $schema.users u, $schema.users v WHERE "
	    	        . "a.fiscal_year = $queryYear AND a.revision = (SELECT MAX(revision) FROM "
	    	        . "$schema.audit_revisions where fiscal_year = $queryYear AND audit_type = 'E') "
	    	        . "AND a.approver = u.username AND a.approver2 = v.username ";	
	}
	$sth = $dbh->prepare($sqlString); 
	$sth->execute;
	($revision, $approveDate, $approveDate2, $approver, $approver2) = $sth->fetchrow_array;
	$ocrwm = "OFFICE OF CIVILIAN RADIOACTIVE WASTE MANAGEMENT";
	$title = "Fiscal Year-$year Quality Assurance Supplier Audit Schedule";
	my $titleapprover = $year >= 2004 ? "$approver, $approver2 " : $approver;
	my $titleapproveDate = $approveDate gt $approveDate2 ? $approveDate : $approveDate2;
	
format SUPPLIER_REPORT_TOP_LAST = 
												
													
					    @||||||||||||||||||||||||||||||||||||||||||||||||
					    $ocrwm
                             @||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
				                 $title												
                                                   Revision: @<<
								                                     $revision - 1
								 
Approved By: @<<<<<<<<<<<<<<<<<<<<<<                                                               Page: @<<
				 $approver,                                                                                  $%
Approval Date: @<<<<<<<<<<<<<<<<<<
					$approveDate
.					
					
format SUPPLIER_REPORT_TOP = 
													
													
					     @|||||||||||||||||||||||||||||||||||||||||||||||
					     $ocrwm
                             @||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
				                 $title												
                                                   Revision: @<<
								                                     $revision - 1
								 
Approved By: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                 Page: @<<
				 $titleapprover,                                                                                  $%
Approval Date: @<<<<<<<<<<<<<<<<<<
					$titleapproveDate
___________________________________________________________________________________________________________

  SUPPLIER                    LOCATION                   NUMBER            DATES                  STATUS
___________________________________________________________________________________________________________

.

format SUPPLIER_REPORT = 
~ ^<<<<<<<<<<<<<<<<<<<<<<<   ~^<<<<<<<<<<<<<<<<<<<<<<    @<<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<
$name,                       $location[0],               $number,          $dates,                $status
~~^<<<<<<<<<<<<<<<<<<<<<<<   ~^<<<<<<<<<<<<<<<<<<<<<<
$name,                       $location[1]      
~                            ^<<<<<<<<<<<<<<<<<<<<<<
			                    $location[2]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[3]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[4]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[5]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[6]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[7]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[8]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[9]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[10]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[11]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[12]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[13]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[14]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[15]
~                            ^<<<<<<<<<<<<<<<<<<<<<<
                             $location[16]

~  Team Lead:     ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $teamLead
~  Team Members:  ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   					$teamMembers
   ~~             ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $teamMembers
~  Product:       ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $product
   ~~             ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $product
~  Scope:         ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $scope
   ~~             ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $scope
~  Notes:         ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $notes
   ~~             ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $notes
___________________________________________________________________________________________________________

.

format SUPPLIER_REPORT_BOTTOM = 
    					
    																			   
    Approved By: ___________________________________________________________              Date: @||||||||||	     
    		                                                                                    $approveDate  
                  @||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	  
                  $signatorTitle                                                   
.

format SUPPLIER_REPORT_BOTTOM2 = 
    					
    Approved By: ________________________________   Approved By: ________________________________      	                                                                                            
                 Michael J. Mason                                R. Dennis Brown
                 Manager                    			 Director, Department of Energy
                 BSC Quality Assurance                           Office of Quality Assurance
    
    Date: @||||||||||                               Date: @||||||||||
    $approveDate                                    $approveDate2            
    
.

	my $oldHandle = select SUPPLIER_REPORT;
	$= = 42;
	$currentTime =~ s/://g;
	my	$filename = "external_audit$currentTime.doc";
	if (!(open (SUPPLIER_REPORT, "| ./File_Utilities.pl --command=writeFile --fullFilePath="
		                           . "$NQSFullTempReportPath/$filename --protection=0777"))) {
		die "Unable to open output file $NQSFullTempReportPath/$filename";
	}
	$sqlString = "SELECT id, revision, qualified_supplier_id, cancelled, audit_type, issuedto_org_id, audit_seq, team_lead_id, team_members, "
		          . "scope, TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, "
		          . "product, TO_CHAR(completion_date, 'MM/DD/YYYY'), "
		          . "TO_CHAR(forecast_date, 'MM/DD/YYYY'), issuedby_org_id FROM $schema.external_audit "
				  . "WHERE fiscal_year = $queryYear AND revision = (SELECT MAX(revision) FROM "
				  . "$schema.external_audit WHERE fiscal_year = $queryYear) ORDER BY begin_date, forecast_date";
	    	       
	$sth = $dbh->prepare($sqlString);
	$sth->execute;
	while (($id, $rev, $qualifiedSupplierId, $cancelled, $auditType, $issuedToId, $auditSeq, $teamLeadId, $teamMembers, $scope, $beginDate, 
		     $endDate, $notes, $product, $completedDate, $forecastDate, $issuedById) = $sth->fetchrow_array) {
		$teamMembers = defined($teamMembers) ? $teamMembers : "";
		$product = defined($product) ? $product : "";
		$scope = defined($scope) ? $scope : "";
		$notes = defined($notes) ? $notes : "";
		$teamMembers =~ s/(\n|\t|\r|\e|\f)//g;
		$teamMembers =~ s/,/, /g;
		#$notes =~ s/(\n|\t|\r|\e|\f)//g;
		#$scope =~ s/(\n|\t|\r|\e|\f)//g;
		#$product =~ s/(\n|\t|\r|\e|\f)//g;
		$sth1 = $dbh->prepare("SELECT modified FROM $schema.external_audit WHERE id = $id AND "
				                . "fiscal_year = $queryYear AND revision = 0");
		$sth1->execute;
		$modified = $sth1->fetchrow_array;
		if ($auditSeq eq "0" && (!(defined($cancelled)) || (defined($cancelled) && $cancelled eq "N"))) {
	   	$number = "To be determined";
		}
		elsif ($auditSeq ne "0") {
			$number = &getExternalAuditId($dbh, $issuedById, $issuedToId, $auditType, $year, $auditSeq);
		}
		else {
			$number = "Not applicable";
		}
		if (defined($beginDate) && defined($endDate) && (!(defined($cancelled)) || defined($cancelled) && $cancelled ne "Y")) {
			$dates = "$beginDate-$endDate";
		}
		elsif (!(defined($beginDate)) && !(defined($endDate)) && !(defined($cancelled)) && defined($forecastDate)) {
			$dates = "$forecastDate";
		}
   	else {
	   	$dates = "";
		}
		if (defined($cancelled) && $cancelled eq "Y") {
			$status = "CANCELLED";
		}
		elsif (defined($completedDate)) {
			$status = "COMPLETE";
		}
		else {
			$status = "";
		}

   	if (defined($teamLeadId) && $teamLeadId != 0) {
			$sqlString = "SELECT firstname || ' ' || lastname FROM $schema.users "
				       	. "WHERE id = $teamLeadId";
			$sth1 = $dbh->prepare($sqlString);
			$sth1->execute;
			$teamLead = $sth1->fetchrow_array;
		}		
		$teamLead = defined($teamLead ) ? $teamLead  : "";
	 	$sth1 = $dbh->prepare("SELECT company_name FROM $schema.qualified_supplier "
					 				 . "WHERE id = '$qualifiedSupplierId'");
		$sth1->execute;
		if (defined($modified) && $modified eq "Y") {
			$name = "|"; 
			$name .= $sth1->fetchrow_array;
		}
		else {
			$name = $sth1->fetchrow_array;
		}
		$name = defined($name) ? $name : "";
		my $sql = "SELECT location_id FROM $schema.external_audit_locations "
			   . "WHERE external_audit_id = $id AND fiscal_year = $queryYear "
			   . "AND revision = $rev";
		$sth1 = $dbh->prepare($sql);
		$sth1->execute;
		$locId = $sth1->fetchrow_array;
		$sql = "SELECT city, state, province FROM $schema.locations "
					 . "WHERE id = $locId";
		$sth1 = $dbh->prepare($sql);
		$sth1->execute;
		my $count = 0;
		while (($city, $state, $province) = $sth1->fetchrow_array) {
			if (defined($city) && defined($state) && !(defined($province))) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$location[$count] = "$city, $state";
			}
			elsif (!(defined($city)) && defined($state) && !(defined($province))) {
				$location[$count] = "$state";
			}
			elsif (defined($city) && !(defined($state)) && defined($province) ) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$location[$count] = "$city, $province";
			}
			elsif (defined($city) && !(defined($state)) && !(defined($province))) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$location[$count] = "$city";
			}
			elsif (!(defined($city)) && !(defined($state)) && defined($province)) {
				$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$location[$count] = "$province";
			}
			else {
			  $location[$count] = "";
			}
			$count++;
		}
		for (my $i = $count; $i < 17; $i++) {
			$location[$i] = "";
		}
   	write (SUPPLIER_REPORT);
	}
	if ($isApproverReport eq "TRUE") {
		if ($- > 3) {
			for (my $i = 0; $i < $- - 4; $i++) {
				print "\n";
			}
		}
		else {
			for (my $i = 0; $i < $-; $i++) {
				print "\n";
			}
			$- = 0;
			$^ = "SUPPLIER_REPORT_TOP_LAST";
			$number = "";
			$dates = "";
			$status = "";
			$name = "";
			for (my $i = 0; $i < 17; $i++) {
				$location[$i] = "";
		   }
		   $teamLead = "";
		   $teamMembers = "";
		   $product = "";
		   $scope = "";
		   $notes = "";
			write;
			print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
			$- = 31;
		}
		my $previousHandle = select SUPPLIER_REPORT;
		$~ = "SUPPLIER_REPORT_BOTTOM" if ($year < 2004);
		$~ = "SUPPLIER_REPORT_BOTTOM2" if ($year >= 2004);
		write (SUPPLIER_REPORT);
		select $previousHandle;
	}
	close(SUPPLIER_REPORT);
	open(FILE, "$NQSFullTempReportPath/$filename") || die "Can't open file $NQSFullTempReportPath/$filename\n";
	my $line;
	my $report;
	while (defined($line = <FILE>))  {
		$report .= $line;
	}
	close(FILE);
	select $oldHandle;
   my $message = "The QA external audit schedule is contained in the attachment below. Double click the attachment then "
		           . "click the button labeled \"Launch....\". This will open Microsoft Word. In Microsoft Word click the "
		           . "File tab at the top left of the window, then click \"Page Setup\". This will open a dialog box. Click "
		           . "the tab entitled \"Paper Size\" then click the radio button entitled \"Landscape\". "
		           . "To print the report in Microsoft Word click the File tab at the top left of the window, then click \"Print\"."
		           . "When the Print dialog box opens click the \"properties\" button in the right corner of the box. When the new "
		           . "dialog box opens click the radio button labeled \"Landscape\". Finally click \"Ok\" on the properties dialog box "
		           . "and \"Ok\" on the print dialog box. For best results all document margins should be set to 1\".";
	&SendMailMessage(sendTo=>$emailAddress, sender=>"QA", subject=>"external audit schedule",
						  message=>$message, timeStamp=>"F", attachmentCount=>1, 
						  attachmentFileName1=>$filename, attachmentContents1=>$report);
	if (!(open (SUPPLIER_REPORT, "| ./File_Utilities.pl --command=deleteFile --fullFilePath="
			                           . "$NQSFullTempReportPath/$filename --protection=0777"))) {
		die "Unable to delete output file $NQSFullTempReportPath/$filename";
	}
	close(SUPPLIER_REPORT);
#	$sth->finish;
	
	return $filename;
}



####################################################################################################################

sub MailInternalSchedule {
   my ($year, $issuedBy, $schema, $dbh, $emailAddress, $isApproverReport) = @_;
	my ($ocrwm, $dateTime, $name, $title, $sth, $revision, $approveDate, $approver);
	my ($id, $rev, $auditType, $auditSeq, $teamLeadId, $teamLead, $teamMembers, $scope, $auditTypeSeq);
	my ($issuedTo, $issuedToId, $completedDate, $forecastDate, $beginDate, $modified, $sqlClauseInternal, $sqlClauseAuditRev);
	my ($orgId, $locId, $org, @org, @location, $city, $state, $province, $rowCount, $endDate, $notes, $cancelled);
	my ($location, $number, $dates, $status, $sth1, $sth2, $sth3, $sth4, $issuedById, $approveDate2, $approver2, $signatorTitle2);
	my $text;
	my $queryYear = substr($year, 2, 2);
	my $signatorTitle;
	$signatorTitle = "Director, Office of Quality Assurance" if ($issuedBy eq "OQA");
	$signatorTitle = "Bechtel SAIC Company QA Manager" if ($issuedBy eq "BSCQA");
	$signatorTitle = "Quality Verification Manager\nBSC Quality Assurance" if ($issuedBy eq "OCRWM");
	$signatorTitle2 = "Team Lead, Assessments\nOCRWM Office of Quality Assurance" ;
	$sth = $dbh->prepare("SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') FROM DUAL");
	$sth->execute;
	if ($issuedBy eq "OQA") {
   	$sqlClauseInternal = " issuedby_org_id = 28";
   	$sqlClauseAuditRev = " auditing_org = 'OQA'";
   }
   elsif ($issuedBy eq "OCRWM") { 
   	$sqlClauseInternal = " issuedby_org_id = 24";
   	$sqlClauseAuditRev = " auditing_org = 'OCRWM'";
   }
   elsif ($issuedBy eq "BSCQA") { 
   	$sqlClauseInternal = " issuedby_org_id = 1";
   	$sqlClauseAuditRev = " auditing_org = 'BSC'";
   }
	my $currentTime = $sth->fetchrow_array;
	my $sqlString;
	if ($year < 2004) {
		$sqlString = "SELECT revision, TO_CHAR(approval_date, 'MM/DD/YYYY'), TO_CHAR(approval2_date, 'MM/DD/YYYY'), "
			. "firstname || ' ' || lastname, firstname || ' ' || lastname "
	    	        . "FROM $schema.audit_revisions a, $schema.users b WHERE "
	    	        . "a.fiscal_year = $queryYear AND a.revision = (SELECT MAX(revision) FROM "
	    	        . "$schema.internal_audit where fiscal_year = $queryYear AND "
	    	        . "$sqlClauseInternal) AND a.approver = b.username AND a.audit_type = 'I' AND $sqlClauseAuditRev";
	} else {
		$sqlString = "SELECT revision, TO_CHAR(approval_date, 'MM/DD/YYYY'), TO_CHAR(approval2_date, 'MM/DD/YYYY'), "
			. "u.firstname || ' ' || u.lastname, v.firstname || ' ' || v.lastname "
	    	        . "FROM $schema.audit_revisions a, $schema.users u, $schema.users v WHERE "
	    	        . "a.fiscal_year = $queryYear AND a.revision = (SELECT MAX(revision) FROM "
	    	        . "$schema.audit_revisions where fiscal_year = $queryYear AND audit_type = 'I') "
	    	        . "AND a.approver = u.username AND a.approver2 = v.username ";	
	}
#print "\n$sqlString\n";	
	$sth = $dbh->prepare($sqlString); 
	$sth->execute;
	($revision, $approveDate, $approveDate2, $approver, $approver2) = $sth->fetchrow_array;
	$ocrwm = "OFFICE OF CIVILIAN RADIOACTIVE WASTE MANAGEMENT";
	$title = "Fiscal Year-$year $issuedBy Internal Audit Schedule";
	my $titleapprover = $year >= 2004 ? "$approver, $approver2 " : $approver;
	my $titleapproveDate = $approveDate gt $approveDate2 ? $approveDate : $approveDate2;

format INTRNL_REPORT_TOP_LAST = 
													
					  @|||||||||||||||||||||||||||||||||||||||||||||||||
					  $ocrwm
                             @||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
				                 $title												
                                                   Revision: @<<
								                                     $revision - 1
								                                    
Approved By: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                                Page: @<<
				 $titleapprover,                                                                                  $%
Approval Date: @<<<<<<<<<<<<<<<<<<
					$titleapproveDate
.

format INTRNL_REPORT_TOP_LAST2 = 
													
					  @|||||||||||||||||||||||||||||||||||||||||||||||||
					  $ocrwm
                             @||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
				                 $title												
                                                   Revision: @<<
								                                     $revision - 1
								                                    
Approved By: @<<<<<<<<<<<<<<<<<<<<<<           Approval Date: @<<<<<<<<<<<<<<<<<<                                                    Page: @<<
				 $approver,                        $approveDate                                                          $%
					
.

format INTRNL_REPORT_TOP = 
													
					     @|||||||||||||||||||||||||||||||||||||||||||||||
					     $ocrwm
                              @||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
				                  $title												
                                                    Revision: @<<
								                                      $revision - 1
								 
Approved By: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<                                                Page: @<<
				 $titleapprover,                                                                                  $%
Approval Date: @<<<<<<<<<<<<<<<<<<
					$titleapproveDate
___________________________________________________________________________________________________________

 ORG             LOCATION                      NUMBER                   DATES                    STATUS
___________________________________________________________________________________________________________

.

format INTRNL_REPORT = 
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<   @<<<<<<<<<<<<<<<<<<<<<   @<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<
$org[0],         $location[0],                 $number,                 $dates,                  $status
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[1],         $location[1]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[2],         $location[2]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[3],         $location[3]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[4],         $location[4]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[5],         $location[5]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[6],         $location[6]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[7],         $location[7]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[8],         $location[8]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[9],         $location[9]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[10],        $location[10]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[11],        $location[11]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[12],        $location[12]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[13],        $location[13]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[14],        $location[14]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[15],        $location[15]
~^<<<<<<<<<<<<   ^<<<<<<<<<<<<<<<<<<<<<<<<<<
$org[16],        $location[16]

~  Team Lead:     ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $teamLead
~  Team Members:  ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   					$teamMembers
   ~~             ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $teamMembers
~  Scope:         ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $scope
   ~~             ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $scope
~  Notes:         ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $notes
   ~~             ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                  $notes
___________________________________________________________________________________________________________

.

format INTRNL_REPORT_BOTTOM = 
    
    Note: For PB Audits, the WBS title follows each WBS# with the actual subject or product to be audited
	    following the title in parenthesis, or the WP# is followed by the subject to be audited.
	    For Compliance Audits, each ATL is directed to place emphasis on personnel qualifications
	    activities and AO implementation of newly issued APs.
    																					  
    Approved By: ___________________________________________________________              Date: @||||||||||	     
    		                                                                                    $approveDate         
                 @||||||||||||||||||||||||||||||||||||||||||||||||||||||||||	              
                 $signatorTitle                
.

format INTRNL_REPORT_BOTTOM2 = 
    
    Note: For PB Audits, the WBS title follows each WBS# with the actual subject or product to be audited
	    following the title in parenthesis, or the WP# is followed by the subject to be audited.
	    For Compliance Audits, each ATL is directed to place emphasis on personnel qualifications
	    activities and AO implementation of newly issued APs.
    																					  
    Approved By: ________________________________   Approved By: ________________________________      	                                                                                            
                 Michael J. Mason                                R. Dennis Brown
                 Manager                    			 Director, Department of Energy
                 BSC Quality Assurance                           Office of Quality Assurance
    
    Date: @||||||||||                               Date: @||||||||||
    $approveDate                                    $approveDate2                                                                                  
  
.

	my $oldHandle = select INTRNL_REPORT;
	$= = 42;
	$currentTime =~ s/://g;
   my	$filename = "internal_audit$currentTime.doc";
	if (!(open (INTRNL_REPORT, "| ./File_Utilities.pl --command=writeFile --fullFilePath="
	                           . "$NQSFullTempReportPath/$filename --protection=0777"))) {
	    die "Unable to open output file $NQSFullTempReportPath/$filename";
	}
	
	if ($year < 2004) {
		$sqlString = "SELECT id, revision, cancelled, audit_type, audit_seq, team_lead_id, team_members, scope, "
		       	. "TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, cancelled, "
		       	. "TO_CHAR(completion_date, 'MM/DD/YYYY'), issuedto_org_id, TO_CHAR(forecast_date, 'MM/DD/YYYY'), issuedby_org_id, modified "
		       	. "FROM $schema.internal_audit WHERE fiscal_year = $queryYear "
			. "AND revision = (SELECT MAX(revision) FROM $schema.internal_audit "
			. "WHERE fiscal_year = $queryYear AND $sqlClauseInternal) AND $sqlClauseInternal "
			. "ORDER BY begin_date, end_date, forecast_date";	    	       
	} else {
		$sqlString = "SELECT id, revision, cancelled, audit_type, audit_seq, team_lead_id, team_members, scope, "
			. "TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), notes, cancelled, "
			. "TO_CHAR(completion_date, 'MM/DD/YYYY'), issuedto_org_id, TO_CHAR(forecast_date, 'MM/DD/YYYY'), issuedby_org_id, modified "
			. "FROM $schema.internal_audit WHERE fiscal_year = $queryYear "
			. "AND revision = (SELECT MAX(revision) FROM $schema.audit_revisions "
			. "WHERE fiscal_year = $queryYear AND audit_type = 'I')  "
			. "ORDER BY begin_date, end_date, forecast_date";	
	}
	$sth = $dbh->prepare($sqlString);
	$sth->execute;
	while (($id, $rev, $cancelled, $auditType, $auditSeq, $teamLeadId, $teamMembers, $scope, $beginDate, 
		  	  $endDate, $notes, $cancelled, $completedDate, $issuedToId, $forecastDate, $issuedById, $modified) = $sth->fetchrow_array) {
		$teamMembers = defined($teamMembers) ? $teamMembers : "";
		$scope = defined($scope) ? $scope : "";
		$notes = defined($notes) ? $notes : "";
		$teamMembers =~ s/(\n|\t|\r|\e|\f)//g;
		$teamMembers =~ s/,/, /g;
		$sth1 = $dbh->prepare("SELECT modified FROM $schema.internal_audit WHERE id = $id AND "
				                . "fiscal_year = $queryYear AND revision = 0");
		$sth1->execute;
		$modified = $sth1->fetchrow_array;
		if ($auditType =~ /^pb/i) {
		 	$auditTypeSeq = "P";
		}
		elsif ($auditType =~ /^all/i) {
		 	$auditTypeSeq = "C";
		}
		else {
		 	$auditTypeSeq = $auditType;
		}
		if ($auditSeq eq "0" && (!(defined($cancelled)) || (defined($cancelled) && $cancelled eq "N"))) {
			$number = "To be determined";
		}
		elsif ($auditSeq ne "0") {
			$number = &getInternalAuditId($dbh, $issuedById, $issuedToId, $auditTypeSeq, $year, $auditSeq);
		}
		else {
			$number = "Not applicable";
		}
		if (defined($beginDate) && defined($endDate) && (!(defined($cancelled)) || defined($cancelled) && $cancelled ne "Y")) {
			$dates = "$beginDate-$endDate";
		}
		elsif (!(defined($beginDate)) && !(defined($endDate)) && !(defined($cancelled)) && defined($forecastDate)) {
			$dates = "$forecastDate";
		}
		else {
			$dates = "";
		}
		if (defined($cancelled) && $cancelled eq "Y") {
			$status = "CANCELLED";
		}
		elsif (defined($completedDate)) {
				$status = "COMPLETE";
		}
		else {
			$status = "";
		}

   	if (defined($teamLeadId) && $teamLeadId != 0) {
			$sqlString = "SELECT firstname || ' ' || lastname FROM $schema.users "
				       	. "WHERE id = $teamLeadId";
			$sth1 = $dbh->prepare($sqlString);
			$sth1->execute;
			$teamLead = $sth1->fetchrow_array;
		}
		$teamLead = "";
		$sth1 = $dbh->prepare("SELECT location_id, organization_id FROM $schema.internal_audit_org_loc "
				 				 	. "WHERE internal_audit_id = $id AND fiscal_year = $queryYear "
				 				 	. "AND revision = $rev");
		$sth1->execute;
		my $count = 0;
		while (($locId, $orgId) = $sth1->fetchrow_array) {
			$org[$count] = "";
			if (defined($modified) && $modified eq "Y") {
				$org[$count] .= "|";
			}
			if (defined($orgId)) {
			 	my $sth3 = $dbh->prepare("SELECT abbr FROM $schema.organizations WHERE id = $orgId");
			 	$sth3->execute;
			 	$org[$count] .= $sth3->fetchrow_array;
			}
			if (defined($locId)) {
			 	my $sth4 = $dbh->prepare("SELECT city, state, province FROM $schema.locations WHERE id = $locId");
			 	$sth4->execute;
			 	($city, $state, $province) = $sth4->fetchrow_array;
			}
			if (defined($city) && defined($state) && !(defined($province))) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$location[$count] = "$city, $state";
			}
			elsif (!(defined($city)) && defined($state) && !(defined($province))) {
				$location[$count] = "$state";
			}
			elsif (defined($city) && !(defined($state)) && defined($province) ) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$location[$count] = "$city, $province";
			}
			elsif (defined($city) && !(defined($state)) && !(defined($province))) {
				$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$location[$count] = "$city";
			}
			elsif (!(defined($city)) && !(defined($state)) && defined($province)) {
				$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
				$location[$count] = "$province";
			}
			else {
				$location[$count] = "";
			}
			$count++;
		}
		for (my $i = $count; $i < 17; $i++) {
			$location[$i] = "";
			$org[$i] = "";
		}
		write (INTRNL_REPORT);
	}
	if ($isApproverReport eq "TRUE") {
		if ($- > 11) {
			for (my $i = 0; $i < $- - 12; $i++) {
				print "\n";
			}
		}
		else {
			for (my $i = 0; $i < $-; $i++) {
				print "\n";
			}
			for (my $i = 0; $i < 17; $i++) {
				$location[$i] = "";
				$org[$i] = "";
			}
			$- = 0;
			$^ = "INTRNL_REPORT_TOP_LAST";
			$number = "";
			$dates = "";
			$status = "";
			$teamLead = "";
			$teamMembers = "";
			$scope = "";
			$notes = "";
			$- = 0;
   		write;
   		print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		}
		my $previousHandle = select INTRNL_REPORT;
		
   	$~ = "INTRNL_REPORT_BOTTOM" if ($year < 2004);
   	$~ = "INTRNL_REPORT_BOTTOM2" if ($year >= 2004);
   	write (INTRNL_REPORT);
		select $previousHandle;
	}
	close(INTRNL_REPORT);
	open(FILE, "$NQSFullTempReportPath/$filename") || die "Can't open file $NQSFullTempReportPath/$filename\n";
	my $line;
	my $report;
	while (defined($line = <FILE>))  {
		$report .= $line;
	}
	close(FILE);
	select $oldHandle;
   my $message =  "The QA internal audit schedule is contained in the attachment below. Double click the attachment then "
		           . "click the button labeled \"Launch....\". This will open Microsoft Word. In Microsoft Word click the "
		           . "File tab at the top left of the window, then click \"Page Setup\". This will open a dialog box. Click "
		           . "the tab entitled \"Paper Size\" then click the radio button entitled \"Landscape\". "
		           . "To print the report in Microsoft Word click the File tab at the top left of the window, then click \"Print\"."
		           . "When the Print dialog box opens click the \"properties\" button in the right corner of the box. When the new "
		           . "dialog box opens click the radio button labeled \"Landscape\". Finally click \"Ok\" on the properties dialog box "
		           . "and \"Ok\" on the print dialog box. For best results all document margins should be set to 1\".";
		           
	&SendMailMessage(sendTo=>$emailAddress, sender=>"QA", subject=>"internal audit schedule",
						 message=>$message, timeStamp=>"F", attachmentCount=>1, 
						 attachmentFileName1=>$filename, attachmentContents1=>$report);
	if (!(open (INTRNL_REPORT, "| ./File_Utilities.pl --command=deleteFile --fullFilePath="
			                           . "$NQSFullTempReportPath/$filename --protection=0777"))) {
		die "Unable to delete output file $NQSFullTempReportPath/$filename";
	}
	close(INTRNL_REPORT);
   return $filename;
}






