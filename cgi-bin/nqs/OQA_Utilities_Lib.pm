#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/dattam/intradev/rcs/qa/perl/RCS/OQA_Utilities_Lib.pm,v $
#
# $Revision: 1.26 $
#
# $Date: 2007/10/03 16:39:56 $
#
# $Author: dattam $
#
# $Locker:  $
#
# $Log: OQA_Utilities_Lib.pm,v $
# Revision 1.26  2007/10/03 16:39:56  dattam
# sub getInternalAuditId modified to change the internal audit numbering scheme for FY 2008
#
# Revision 1.25  2007/09/26 18:07:16  dattam
# Sub getExternalAuditId modified to change the external audit numbering scheme for FY 2008
#
# Revision 1.24  2007/04/12 21:19:48  dattam
# Modified getSurvId to generate ids for SNL Surveillance.
#
# Revision 1.23  2005/10/31 23:42:42  starkeyj
# modified getExternalAuditID to fix bug
#
# Revision 1.22  2005/10/04 17:28:53  starkeyj
# modified getInternalAuditID to remove "C" and "P" from audit display and display OQA for OCRWM for years gt 2005
#
# Revision 1.21  2005/07/12 15:30:00  dattam
# new subroutine get_suborg_info added to get the suborganization information for a given id.
# bscsuborg_active check added in SQL query.
#
# Revision 1.20  2004/09/16 20:05:55  starkeyj
# modified getInternalAuditID to check for BSC as an issuer for years 2005 and greater
# This change is for Work Request 15, aka SCR 82
#
# Revision 1.19  2004/02/19 20:44:30  starkeyj
# modified getInternalAuditId to generate id's for EM/RW audits
#
# Revision 1.18  2003/10/08 22:17:48  starkeyj
# added subroutine get_approver2
#
# Revision 1.17  2003/10/02 15:19:33  starkeyj
# modified getSurvId to correctly generate Id's when the issued by org os OQA and the year is > 2003
#
# Revision 1.16  2003/10/01 15:20:54  starkeyj
# added the subroutines CheckApproval and checkApprover for SCR 54
#
# Revision 1.15  2003/09/22 17:54:51  starkeyj
# modified subroutine getInternalAuditId to generate a different
# audit id for fiscal years 2004 and greater
#
# Revision 1.14  2003/05/01 19:39:28  starkeyj
# modified the getInternalAuditID function to display the BSC audit for 2002 as BQAC-BSC instead of BSC-ARC
#
# Revision 1.13  2002/09/24 20:10:02  starkeyj
# bug fix - modified get_approver fcn to include the audit type in the query
#
# Revision 1.12  2002/09/16 23:02:46  johnsonc
# Changed getSurvId function to generate a surveillance id for a BSC 2002 surveillance.
#
# Revision 1.11  2002/09/14 00:53:57  johnsonc
# Changed the getSurveillanceId function for the 2002 fiscal year.
#
# Revision 1.10  2002/09/10 23:41:59  starkeyj
# modified surveillance and surveillance request id functions to display BSC as BQA
#
# Revision 1.9  2002/09/10 22:54:17  starkeyj
# modified internal and external audit id functions to display BSC as BQA - SCR 44
#
# Revision 1.8  2002/09/09 20:28:08  johnsonc
# Added functions getSurvId, getExternalAuditId, getInternalAuditId, and getSurvReqId (SCREQ00044).
#
# Revision 1.7  2002/08/20 20:14:59  starkeyj
# modified get_approver and get_max_revision to include issuedby field for SCR 44
#
# Revision 1.6  2002/03/28 23:27:38  starkeyj
# get_value function to get new location value when user adds a new supplier from the audit screen (SCR 11)
#
# Revision 1.5  2002/01/03 22:18:34  starkeyj
# added functions to print state and province drop down lists
#
# Revision 1.4  2001/11/05 18:42:23  starkeyj
# modified for tablename error
#
# Revision 1.3  2001/11/02 23:01:54  johnsonc
# Changed validation function to check string in upper case.
#
# Revision 1.2  2001/10/22 17:44:44  starkeyj
# no change, user error with RCS
#
# Revision 1.1  2001/10/22 14:45:04  starkeyj
# Initial revision
#
#
# Revision: $
#
# 


package OQA_Utilities_Lib;
use strict;
use Carp;
use Time::Local;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw($DBUser $NQSConnectPath $NQSServer $SCHEMA $NQSCGIDir);
use vars qw($NQSUser $NQSPassword $SCHEMA);
use NQS_Header qw(:Constants);
use Mail_Utilities_Lib;

use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;


$DBUser = $ENV{'DBUser'};
$NQSConnectPath = $ENV{'NQSConnectPath'};
$NQSServer = $ENV{'NQSServer'};
$SCHEMA = $ENV{'SCHEMA'};

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (&getSurvId &getSurvRequestId &getInternalAuditId &getExternalAuditId &NQS_connect &NQS_disconnect &validate_user &does_user_have_priv &get_user_privs &get_userid &get_next_comment_number &print_states &get_locations
 &print_provinces &get_next_commentor_id &get_next_preapproved_text_id &get_next_surveillance_request_id &get_next_users_id &get_lookup_values &get_approver &get_approver2
 &get_authorized_users &get_assigned_users &get_date &log_activity &log_nqs_activity &NQS_encrypt_password &does_user_have_named_priv &get_max_id
 &get_formatted_date &log_trend_error &lookup_single_value &lookup_column_values &get_fullname &get_value &formatID2 &notifyUser &get_next_value
 &get_next_surveillance_id &validate_trend_user &validate_audit &get_max_revision &get_audit_count &get_org_info &get_suborg_info &get_loc_info &get_supplier_info
 &getAuditID &log_nqs_error &error_message &display_error &get_locations2 &validate_lead &get_approver_email &get_city_state &checkApproval &checkApprover);
@EXPORT_OK = qw(&getSurvId &getSurvRequestId &getInternalAuditId &getExternalAuditId &NQS_connect &NQS_disconnect &validate_user &does_user_have_priv &get_user_privs &get_userid &get_next_comment_number &print_states &get_locations
 &print_provinces &get_next_commentor_id &get_next_preapproved_text_id &get_next_surveillance_request_id &get_next_users_id &get_lookup_values &get_approver &get_approver2
 &get_authorized_users &get_assigned_users &get_date &log_activity &log_nqs_activity &NQS_encrypt_password &does_user_have_named_priv &get_max_id
 &get_formatted_date &log_trend_error &lookup_single_value &lookup_column_values &get_fullname &get_value &formatID2 &notifyUser &get_next_value
 &get_next_surveillance_id &validate_trend_user &validate_audit &get_max_revision &get_audit_count &get_org_info &get_suborg_info &get_loc_info &get_supplier_info
 &getAuditID &log_nqs_error &error_message &display_error &get_locations2 &validate_lead &get_approver_email &get_city_state &checkApproval &checkApprover);
%EXPORT_TAGS =(
    Functions => [qw(&getSurvId &getSurvRequestId &getInternalAuditId &getExternalAuditId &NQS_connect &NQS_disconnect &validate_user &does_user_have_priv &get_user_privs &get_userid &get_next_comment_number &print_states &get_locations
 &print_provinces &get_next_commentor_id &get_next_preapproved_text_id &get_next_surveillance_request_id &get_next_users_id &get_lookup_values &get_approver &get_approver2
 &get_authorized_users &get_assigned_users &get_date &log_activity &log_nqs_activity &NQS_encrypt_password &does_user_have_named_priv &get_max_id
 &get_formatted_date &log_trend_error &lookup_single_value &lookup_column_values &get_fullname &get_value &formatID2 &notifyUser &get_next_value
 &get_next_surveillance_id &validate_trend_user &validate_audit &get_max_revision &get_audit_count &get_org_info &get_suborg_info &get_loc_info &get_supplier_info
  &getAuditID &log_nqs_error &error_message &display_error &get_locations2 &validate_lead &get_approver_email &get_city_state &checkApproval &checkApprover) ]
);

#
# Contents of library:
#
# utilities
#
# 'NQS_connect'
# (database handle) = &NQS_connect;
# 'NQS_disconnect'
# (status) = &NQS_disconnect( (database handle) );
# 'NQS_encrypt_password'
# (encrypted password) = &NQS_encrypt_password( (input password) );
# 'validate_user'
# (status) = &validate_user( (database handle), (username) , (password) );
#     status of 1 is a valid user
# 'does_user_have_priv'
# (status) = &does_user_have_priv( (database handle), (userid), (priv) );
# 'get_user_privs'
# (array of privs) = &get_user_privs( (database handle), (userid) );
# 'get_userid'
# (user id) = &get_userid ( (database handle), (username) );
# 'get_next_comment_number'
# (comment number ) = &get_next_comment_number( (document number), (database handle) );
# 'get_next_commentor_id'
# (commentor id) = &get_next_commentor_id( (database handle) );
# 'get_next_preapproved_text_id'
# (preapproved text id) = &get_next_preapproved_text_id( (database handle) );
# 'get_next_surveillance_request_id'
# (request id) = &get_next_surveillance_request_id( (database handle), (schema) );
# 'get_next_surveillance_id'
# (surveillance id) = &get_next_surveillance_id( (database handle), (schema) );
# 'get_next_users_id'
# (users id) = &get_next_users_id( (database handle) );
# 'get_lookup_values'
# (hash of lookups/values) = &get_lookup_values( (db handle), (table name), (lookup column name), (value column name) [, (with statement)] );
# 'get_authorized_users'
# (hash of userids/usernames) = &get_authorized_users( (priv), (db handle) );
# 'get_assigned_users'
#      needs to be rethought
# 'get_date'
# (oracle friendly date) = &get_date [( (date i.e. '12/31/1999') )];
#      if no date is passed in, today is used
# 'log_activity'
# (status) = &log_activity ( (db handle), (user id), (message) );
#      currently status is always 1
# 'get_org_info'
# (org hash) = &get_org_info( (db handle), (orgid) );
# 'get_locations'
# (loc hash) = &get_locations( (db handle) );
# 'get_loc_info'
# (loc hash) = &get_loc_info( (db handle), (locid) );
# 'get_supplier_info'
# (supplier hash) = &get_supplier_info( (db handle), (supplierid) );
# 'get_user_names_and_ids'
# (user hash) = &get_user_names_and_ids( (db handle) );
# 'does_user_have_named_priv'
# (status) = &does_user_have_named_priv( (db handle), (user id), (privilege name) );
# 'get_formatted_date'
# (formatted date string) = &get_formatted_date ( (format string), (date i.e. '12/31/1999') );
#        if no date is passed in, today is used
# 'lookup_single_value'
# (value) = &lookup_single_value( (db handle), (table), (column), (lookupid) );
# 'lookup_column_values'
# (value array) = &lookup_column_values( (db handle), (table), (column), (wherestatement) (orderbystatement) );
# 'get_fullname'
# (user's full name) = &get_fullname ( (database handle), (schema), (userid) );
# 'get_value'
# (value) = &get_value( (db handle), (schema), (table name), (value column name), (with statement) );
#     if value not found, it returns 0
#
# 'notifyUser'
# ($status) = &notifyUser( dbh => (db handle), schema => (schema), userID => (user id) [, message => ('message')] )
#     returns 1 if successful, and a negative number if not
#
# 'get_max_id'
# ($scalar number) = &get_max_id( (database handle), (tablename), (fieldname) )
#       assumes id is not the field name for the id (yes, it happens)
#    
# 'get_next_value'
# ($scalar number) = &get_next_value( (database handle), (tablename), (fieldname), (fieldname), (value) )
#       returns the max value in a table where there the max value depends on another field
#
# 'validate_audit'
# (status) = &validate_user ( (db handle), (schema), (fy), (type), (seq) );
#
# 'get_max_revision'
# (value) = &get_max_revision ( (db handle), (schema), (fy)  )
#
# 'get_audit_count'
# (value) = &get_audit_count ( (db handle), (schema), (table), (whereclause) )
#
# 'get_approver'
# (list) = &get_approver ( (db handle), (schema), (fy), (revision) )
#
###########
###########
#
###########
###########

###########

###################
sub getSurvId {
###################
	my ($dbh, $issuedById, $issuedToId, $type, $year, $seq) = @_;
	my $id = "";
	my %orghash;
	$orghash{abbr} = "";
	if (defined($seq) && $seq gt "") {
		%orghash = &get_org_info($dbh, $issuedById) if (defined($issuedById) && $issuedById gt "");
		if ($orghash{abbr} eq "OQA") {
			if ($year le "2001" || ($year eq "2002" && $seq <= 9)) {
				%orghash = &get_org_info($dbh, $issuedToId) if (defined($issuedToId) && $issuedToId gt "");
				$id = $orghash{abbr} . "-" if ($orghash{abbr} gt "");
			}
			if ($year le "2001") {
				$id .= "SR-" . substr($year, 2, 2) . "-" . &lpadzero($seq, 2);
			}
			elsif ($year eq "2002" && $seq <= 3) {
				$id .= "SR-" . substr($year, 2, 2) . "-" . &lpadzero($seq, 3);
			}
			elsif ($year eq "2002" && $seq >= 4) {
				$id .= substr($year, 2, 2) . "-S-" . &lpadzero($seq, 2);
			}
			if ($year ge "2003" || ($year eq "2002" && $seq >= 10)) {
				$id = $orghash{abbr} . "-";
				$id .= substr($year, 2, 2) . "-S-" . &lpadzero($seq, 2) if ($year eq "2002");
				$id .= "S$type-" . substr($year, 2, 2) . "-" . &lpadzero($seq, 3) if ($year ge "2003");
			}
		}
		elsif ($orghash{abbr} eq "BSC") {
			if ($year le "2002") {
				$id = "BSCQA-" . substr($year, 2, 2) . "-S-" .&lpadzero($seq, 2);
			}
			elsif ($year ge "2003") {
				$id = "BQA-S$type-" . substr($year, 2, 2) . "-" .&lpadzero($seq, 3);				
			}
		}
		else {
		         $id = "$orghash{abbr}-S$type-" . substr($year, 2, 2) . "-" .&lpadzero($seq, 3);
		}
	}
	return $id;
}

###################
sub getSurvRequestId {
###################
	my ($dbh, $issuedById, $issuedToId, $year, $seq) = @_;
	my $id = "";
	my %orghash;
	if (defined($seq) && $seq gt "") {
		if ($year le "2002") {
			if (defined($issuedToId) && $issuedToId != 0) {
				%orghash = &get_org_info($dbh, $issuedToId);
				$id = $orghash{abbr} ;
			}
			else {$id = "TBD";}
			$id .= "-" . substr($year, 2, 2) . "-R-" . &lpadzero($seq, 3);
		}
		elsif ($year ge "2003") {
			if (defined($issuedById) && $issuedById != 0) {
				%orghash = &get_org_info($dbh, $issuedById) ;
				if ($orghash{abbr} eq 'BSC') {$id = "BQA";}
				else {$id = $orghash{abbr} ;}
			}
			else {$id = "TBD";}
			$id .= "-R-" . substr($year, 2, 2) . "-" . &lpadzero($seq, 3);		
		}
	}
	return $id;
}

###################
sub getInternalAuditId {
###################
	my ($dbh, $issuedById, $issuedToId, $type, $year, $seq) = @_;
	my $id = "";
	my %orghash;
	if (defined($seq) && $seq gt "") {
		if ($year gt "2005") {$type = "";}
		elsif ($type =~ /^pb/i) {$type = "P";}
		elsif ($type eq 'P/PB') {$type = "P";}
		elsif ($type =~ /^all/i) {$type = "C";}
		
		$seq = "##" if ($seq eq "0" && $issuedById != 3);
		$seq = "###" if ($seq eq "0" && $issuedById == 3);
		if ($year ge "2008") {
		        if ($issuedById == 3) {
			     $id = substr($year, 2, 2) . "-DOE-AU-" . &lpadzero($seq, 3);
			}
			else {
			     $id = "IA" . "-" . substr($year, 2, 2) . "-" . &lpadzero($seq, 2);
			}
		}
		elsif ($year le "2002" || (($year > 2004) && ($year < 2008))) {
			%orghash = &get_org_info($dbh, $issuedToId) if (defined($issuedToId) && $issuedToId gt "");
			my %orghash2 = &get_org_info($dbh, $issuedById);
			if ($orghash2{abbr} eq 'BSC' && ($year eq "2002" || $year > 2004)) {
				$id = "BQA";
				$id .= "$type-";
				$id .= $orghash{abbr} . "-" . substr($year, 2, 2) . "-" . &lpadzero($seq, 2);
			}
			else {
				$id = $orghash{abbr} . "-" if (defined($orghash{abbr}));
				$id .= "AR$type-" . substr($year, 2, 2) . "-" . &lpadzero($seq, 2);
			}
		}
		elsif ($year eq "2003") {
			%orghash = &get_org_info($dbh, $issuedById);
			if ($orghash{abbr} eq 'BSC') {$id = "BQA";}
			else {$id = $orghash{abbr} ;}
			$id .= "$type-";
			%orghash = &get_org_info($dbh, $issuedToId);		
			$id .= $orghash{abbr} . "-" . substr($year, 2, 2) . "-" . &lpadzero($seq, 2);
		}
		if (($year ge "2004" && $year < 2008) && $issuedById != 1) {
			if ($issuedById == 3) {
				$id = substr($year, 2, 2) . "-DOE-AU-" . &lpadzero($seq, 3);
			}
			else {
				%orghash = &get_org_info($dbh, $issuedById);
				$id = (($orghash{abbr} eq "OCRWM" && $year gt "2005") ? "OQA" : "$orghash{abbr}");
				$id .= "$type-";
				%orghash = &get_org_info($dbh, $issuedToId);		
				$id .= $orghash{abbr} . "-" . substr($year, 2, 2) . "-" . &lpadzero($seq, 2);
			}
		}
	}
	return $id;
}
 
###################
sub getExternalAuditId {
###################
	my ($dbh, $issuedById, $issuedToId, $type, $year, $seq) = @_;
	my $id = "";
	my %orghash;
	
	if (defined($seq) && $seq gt "") {
		$seq = "##" if ($seq eq "0");
		if ($year le "2002") {
			%orghash = &get_org_info($dbh, $issuedToId) if (defined($issuedToId) && $issuedToId gt "");
			$id = $orghash{abbr} . "-" if (defined($orghash{abbr}));
			$id .= "$type-" . substr($year, 2, 2) . "-" . &lpadzero($seq, 2);
		}
		elsif ($year le "2007") {
			if ($type =~ /^sa/i) {$type = "AS";}
			elsif ($type =~ /^sfe/i) {$type = "FS";}
			%orghash = &get_org_info($dbh, $issuedById) if (defined($issuedById) && $issuedById gt "");
			if ($orghash{abbr} eq 'BSC') {$id = "BQA-";}
			else {$id = $orghash{abbr} . "-" ;}
			if ($orghash{abbr} eq 'BSC' && $year == 2003 && ($seq == 13 || $seq == 17)) {
				$id .= "$type-" . substr($year, 2, 2) . "-" . &lpadzero($seq, 3);
			} else {
				$id .= "$type-" . substr($year, 2, 2) . "-" . &lpadzero($seq, 2);
			}
			
		}
	       else {
	                if ($type =~ /^sa/i) {$type = "SA";}
			elsif ($type =~ /^sfe/i) {$type = "FS";}
			$id .= "$type-" . substr($year, 2, 2) . "-" . &lpadzero($seq, 2);
	       }
	             
	}
	return $id;
}

###################
sub get_org_info {
###################
    my $dbh=$_[0];
    my $passedid=$_[1];

    my %orghash;

    # setup a cursor to read the information
    my $sqlquery = "SELECT organization, abbr, internal_active, 
    						issued_to_list, surveillance_active, performed_on_list
                    FROM $SCHEMA.organizations
                    WHERE id = $passedid";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @orgresults = $csr->fetchrow_array;

    %orghash = (organization => $orgresults[0], abbr => $orgresults[1],
    internal_active => $orgresults[2], issuedTo_list => $orgresults[3],
    surveillance_active => $orgresults[4], performedOn_list => $orgresults[5]);
    my $rc = $csr->finish;
  
    return(%orghash);
}



###################
sub get_suborg_info {
###################
    my $dbh=$_[0];
    my $passedid=$_[1];

    my %suborghash;

    # setup a cursor to read the information
    my $sqlquery = "SELECT suborg, suborg_abbr, active 
    						
                    FROM $SCHEMA.bsc_suborganizations
                    WHERE id = $passedid";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @suborgresults = $csr->fetchrow_array;

    %suborghash = (suborg => $suborgresults[0], suborg_abbr => $suborgresults[1],
                active => $suborgresults[2]);
    my $rc = $csr->finish;
  
    return(%suborghash);
}


###############################
sub print_states {
###############################
	my ($state, $form) = @_;
	tie my %state_hash, "Tie::IxHash"; 
	my $key;
	
	$state_hash{'AK'} = 'Alaska, USA';
	$state_hash{'AL'} = 'Alabama, USA';
	$state_hash{'AZ'} = 'Arizona, USA';
	$state_hash{'AR'} = 'Arkansas, USA';
	$state_hash{'CA'} = 'California, USA';
	$state_hash{'CO'} = 'Colorado, USA';
	$state_hash{'CT'} = 'Connecticut, USA';
	$state_hash{'DE'} = 'Delaware, USA';
	$state_hash{'FL'} = 'Florida, USA';
	$state_hash{'GA'} = 'Georgia, USA';
	$state_hash{'HI'} = 'Hawaii, USA';
	$state_hash{'ID'} = 'Idaho, USA';
	$state_hash{'IL'} = 'Illinois, USA';
	$state_hash{'IN'} = 'Indiana, USA';
	$state_hash{'IA'} = 'Iowa, USA';
	$state_hash{'KS'} = 'Kansas, USA';
	$state_hash{'KY'} = 'Kentucky, USA';
	$state_hash{'LA'} = 'Louisiana, USA';
	$state_hash{'ME'} = 'Maine, USA';
	$state_hash{'MD'} = 'Maryland, USA';
	$state_hash{'MA'} = 'Massachusetts, USA';
	$state_hash{'MI'} = 'Michigan, USA';
	$state_hash{'MN'} = 'Minnesota, USA';
	$state_hash{'MS'} = 'Mississippi, USA';
	$state_hash{'MO'} = 'Missouri, USA';
	$state_hash{'MT'} = 'Montana, USA';
	$state_hash{'NE'} = 'Nebraska, USA';
	$state_hash{'NV'} = 'Nevada, USA';
	$state_hash{'NH'} = 'New Hampshire, USA';
	$state_hash{'NJ'} = 'New Jersey, USA';
	$state_hash{'NM'} = 'New Mexico, USA';
	$state_hash{'NY'} = 'New York, USA';
	$state_hash{'NC'} = 'North Carolina, USA';
	$state_hash{'ND'} = 'North Dakota, USA';
	$state_hash{'OH'} = 'Ohio, USA';
	$state_hash{'OK'} = 'Oklahoma, USA';
	$state_hash{'OR'} = 'Oregon, USA';
	$state_hash{'PA'} = 'Pennsylvania, USA';
	$state_hash{'RI'} = 'Rhode Island, USA';
	$state_hash{'SC'} = 'South Carolina, USA';
	$state_hash{'SD'} = 'South Dakota, USA';
	$state_hash{'TN'} = 'Tennessee, USA';
	$state_hash{'TX'} = 'Texas, USA';
	$state_hash{'UT'} = 'Utah, USA';
	$state_hash{'VT'} = 'Vermont, USA';
	$state_hash{'VA'} = 'Virginia, USA';
	$state_hash{'WA'} = 'Washington, USA';
	$state_hash{'DC'} = 'Washington, DC, USA'; 
	$state_hash{'WV'} = 'West Virginia, USA';
	$state_hash{'WI'} = 'Wisconsin, USA';
	$state_hash{'WY'} = 'Wyoming, USA';

	print "	<select name=state onClick=\"document.$form.province.selectedIndex=0\">\n";
	print "<option value=\"\">(None) \n";
	foreach $key (keys %state_hash) {
		if (uc($key) eq uc($state)) {
			print "<option selected value=\"$key\">$state_hash{$key}\n";
		}
		else {
			print "<option value=\"$key\">$state_hash{$key}\n";
		}
	}
	print "	</select>\n";
}

###############################
sub print_provinces {
###############################
   my ($province, $form) = @_;
	tie my %province_hash, "Tie::IxHash"; 
	my $key;
	$province_hash{'Alberta'} = 'Alberta, CAN';
	$province_hash{'British Columbia'} = 'British Columbia, CAN';
	$province_hash{'Manitoba'} = 'Manitoba, CAN';
	$province_hash{'New Brunswick'} = 'New Brunswick, CAN';
	$province_hash{'New Foundland'} = 'New Foundland, CAN';
	$province_hash{'Northwest Territories'} = 'Northwest Territories, CAN';
	$province_hash{'Nova Scotia'} = 'Nova Scotia, CAN';
	$province_hash{'Nunavut'} = 'Nunavut, CAN';
	$province_hash{'Ontario'} = 'Ontario, CAN';
	$province_hash{'Prince Edward Island'} = 'Prince Edward Island, CAN';
	$province_hash{'Quebec'} = 'Quebec, CAN';
	$province_hash{'Saskatchewan'} = 'Saskatchewan, CAN';
	$province_hash{'Yukon'} = 'Yukon, CAN';

	print "	<select name=province onClick=\"document.$form.state.selectedIndex=0\">\n";
	print "<option value=\"\">(None) \n";
	foreach $key (keys %province_hash) {
		if (uc($key) eq uc($province)) {
			print "<option selected value=\"$key\">$province_hash{$key}\n";
		}
		else {
			print "<option value=\"$key\">$province_hash{$key}\n";
		}
	}
	print "	</select>\n";
}

###################
sub get_locations{
###################
    my $dbh=$_[0];

    my @locresults;

    # setup a cursor to read the information
    my $sqlquery = "SELECT initcap(city), initcap(province), state, country, id, active
                    FROM $SCHEMA.locations
                    order by city || province";
                    
    my $csr = $dbh->prepare($sqlquery);
    $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    while (my $array_ref = $csr->fetchrow_arrayref) {
	 				push @locresults, [@$array_ref];
			}
    #@locresults = $csr->fetchrow_array;

    #%lochash = (city => $locresults[0], province => $locresults[1],
    #state => $locresults[2], country => $locresults[3], id => $locresults[4]);
    my $rc = $csr->finish;
  
    return(@locresults);
}
###################
sub get_locations2{
###################
    my $dbh=$_[0];
    my $active=$_[1];
    my $id=$_[2];
    my $fy = $_[3];
    my $field;
    my $table;

    if (!$id) {$id = 0;}
    if ($fy eq '') {$fy = 50;}
    if ($active eq 'internal') {
    	$table = 'internal_audit_org_loc'; 
    	$field = 'internal_audit_id and revision = 0';
    }
    elsif ($active eq 'external') {
    	$table = 'external_audit_locations';
    	$field = 'external_audit_id and revision = 0';
    }
    elsif ($active eq 'surveillance') {
		$table = 'surveillance_org_loc';
		$field = 'surveillance_id';
    }
    elsif ($active eq 'request') {
      $active = 'surveillance';
		$table = 'request_org_loc';
		$field = 'request_id';
    }
    my @locresults;

    # setup a cursor to read the information
    my $sqlquery = "SELECT initcap(city), initcap(province), state, country, id
                    FROM $SCHEMA.locations where $active" . "_active = 'T' 
                    or id in (select location_id from $SCHEMA.$table where
                    fiscal_year = ". $fy . " and  $id = $field )
                    order by city || province";
    
    #print "<br>***** $sqlquery *****\n";
    my $csr = $dbh->prepare($sqlquery);
    $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    while (my $array_ref = $csr->fetchrow_arrayref) {
		push @locresults, [@$array_ref];
	 }
   
  
    return(@locresults);
}
###################
sub get_loc_info {
###################
    my $dbh=$_[0];
    my $passedid=$_[1];

    tie my %lochash,  "Tie::IxHash";

    # setup a cursor to read the information
    my $sqlquery = "SELECT initcap(city), initcap(province), state, country, 
    					  internal_active, external_active, surveillance_active
                    FROM $SCHEMA.locations
                    WHERE id = $passedid";
                    
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @locresults = $csr->fetchrow_array;

    %lochash = (city => $locresults[0], province => $locresults[1],
    state => $locresults[2], country => $locresults[3], 
    internal_active => $locresults[4], external_active => $locresults[5],
    surveillance_active => $locresults[6]);
    my $rc = $csr->finish;
  
    return(%lochash);
}
#####################


# routine to validate a user of the DB system
sub get_city_state {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $city = $_[2];
    my $state = $_[3];
    my $province = $_[4];
    my $country = $_[5];
    my $status;
    my $csr;
    my $table;
    my $audit_type;
    my $sqlquery;
    my @values;
    my $citystring;
    my $statestring;
    my $provincestring;
    
    if ($city eq '') {
    	$citystring = " city IS NULL ";
    }
    else {
    	$citystring = " upper(city) = upper('$city') ";
    }
    
    if ($state eq '') {
    	$statestring = " state IS NULL ";
    }
    else {
	   $statestring = " state = '$state' ";
    }
    
    if ($province eq '') {
    	$provincestring = " province IS NULL ";
    }
    else {
	   $provincestring = " upper(province) = upper('$province') ";
    }
   
	 $sqlquery = "select id from $schema.locations where ";
	 $sqlquery .= " $citystring and $statestring and $provincestring " ;
	 #$sqlquery .= " and country = '$country' ";
    
   
    
    #print "<br>** $sqlquery ** <br>\n";
	 $csr = $dbh->prepare ($sqlquery);
	 $csr->execute;
	 @values = $csr->fetchrow_array;
	 $csr->finish;
	 my $id = $values[0];
	 if ($#values < 0 | $#values > 1) {
		$status = 0;
	 } 
	 else {
		$status = $id;
	 }
    
    return ($status);
}
###################
sub get_supplier_info {
###################
    my $dbh=$_[0];
    my $passedid=$_[1];

    my %supplierhash;

    # setup a cursor to read the information
    my $sqlquery = "SELECT company_name, address1, address2, city, state,
     					  zip, province, country, foreign_zip, areacode1, phone1,
     					  extension, areacode2, phone2, areacode_fax, fax, to_char(qualified_date,'MM/DD/YYYY'),
     					  to_char(next_audit_due_date,'MM/DD/YYYY'), product, external_active, surveillance_active, bscsuborg_active 
                    FROM $SCHEMA.qualified_supplier
                    WHERE id = $passedid";
    
    #print "<br>***** $sqlquery *****\n";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    my @supplierresults = $csr->fetchrow_array;

    %supplierhash = (company => $supplierresults[0], address1 => $supplierresults[1],
    address2 => $supplierresults[2], city => $supplierresults[3], state => $supplierresults[4],
    zip => $supplierresults[5], province => $supplierresults[6], country => $supplierresults[7],
    f_zip => $supplierresults[8], areacode1 => $supplierresults[9], phone1 => $supplierresults[10],
    extension => $supplierresults[11], areacode2 => $supplierresults[12], phone2 => $supplierresults[13],
    areacode_fax => $supplierresults[14], fax => $supplierresults[15], qual_date => $supplierresults[16],
    next_due => $supplierresults[17], cat_id => $supplierresults[18], 
    external_active => $supplierresults[19], surveillanceactive => $supplierresults[20], 
    bscsuborg_active => $supplierresults[21]);
    my $rc = $csr->finish;
  
    return(%supplierhash);
}
####################
# routine to validate a user of the DB system
sub get_approver {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $fy = $_[2];
    my $revision = $_[3];
    my $org = $_[4];
    my $type = $_[5];
    
    my @values;
    my $sqlquery = "SELECT approver, to_char(approval_date,'MM/DD/YYYY') from $schema.audit_revisions ";
    $sqlquery .= "where fiscal_year = $fy and revision = $revision and auditing_org = '$org' and audit_type = '$type' ";

    my $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    
    return (@values);
     	
}
####################
# routine to validate a user of the DB system
sub get_approver2 {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $fy = $_[2];
    my $revision = $_[3];
    my $org = $_[4];
    my $type = $_[5];
    
    my @values;
    my $sqlquery = "SELECT approver2, to_char(approval2_date,'MM/DD/YYYY') from $schema.audit_revisions ";
    $sqlquery .= "where fiscal_year = $fy and revision = $revision and auditing_org = '$org' and audit_type = '$type' ";

    my $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    
    return (@values);
     	
}
####################
# routine to validate a user of the DB system
sub get_approver_email {
    my $dbh = $_[0];
    my $id = $_[1];
 
    
    my @values;
    my $sqlquery = "SELECT email from $SCHEMA.users ";
    $sqlquery .= "where id = $id ";
    	
    my $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    
    return ($values[0]);
     	
}
###################
sub getAuditID{
###################
    my $dbh = $_[0];
    my $field = $_[1];
    my $table = $_[2];
    my $where = $_[3];
    my $fy = $_[4];
    my @IDs;
    my $index = 0;

    # setup a cursor to read the information
    my $sqlquery = "SELECT $field
                    FROM $SCHEMA.$table where "
                    . $where . "and fiscal_year = $fy and revision = 0";
    
    #print "<br> ** $sqlquery ** \n";
    my $csr = $dbh->prepare($sqlquery);
    $csr->execute;

    #A single row will be returned (unless the database fails) we couldn't be
    #here otherwise.
    

    while (my @values = $csr->fetchrow_array)  {
	 	$IDs[$index++] = $values[0];
	 }
    #@locresults = $csr->fetchrow_array;

    #%lochash = (city => $locresults[0], province => $locresults[1],
    #state => $locresults[2], country => $locresults[3], id => $locresults[4]);
    my $rc = $csr->finish;
  
    return(@IDs);
}
#####################


# routine to validate a user of the DB system
sub validate_audit {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $fy = $_[2];
    my $type = $_[3];
    my $seq = $_[4];
    my $status;
    my $csr;
    my $table;
    my $audit_type;
    my $sqlquery;
    my @values;
    
    
    if (uc($type) eq "SA" | uc($type) eq "SFE" ) {
   	$sqlquery = "select id from $schema.external_audit where fiscal_year = $fy ";
   	$sqlquery .= "and audit_type = '$type' and audit_seq = $seq and revision = 0";
    }
    elsif (uc($type) eq "ARC" | uc($type) eq "ARP") {
    	$sqlquery = "select id from $schema.internal_audit where fiscal_year = $fy ";
    	$sqlquery .= "and audit_seq = $seq and revision = 0";
    }
    elsif ($type eq "S") {
		$sqlquery = "select id from $schema.surveillance where fiscal_year = $fy ";
		$sqlquery .= "and id = $seq ";
    }
    else {
    	$status = 0;
    	return ($status);
    }
    
    #print "<br>** $sqlquery ** <br>\n";
    if ($seq != 0) {
    	$csr = $dbh->prepare ($sqlquery);
    	$csr->execute;
    	@values = $csr->fetchrow_array;
    	$csr->finish;
    	my $count = $values[0];
    	if ($#values < 0 | $#values > 1) {
        	$status = 0;
    	} 
    	else {
		  	$status = $count;
    	}
    }
    else {$status = 0;}
        
    return ($status);
}
#####################


# routine to validate a user of the DB system
sub validate_lead {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $fy = $_[2];
    my $type = $_[3];
    my $seq = $_[4];
    my $leadid = $_[5];
    my $status;
    my $csr;
    my $table;
    my $audit_type;
    my $sqlquery;
    my @values;
    
    if ($type eq "SA" | $type eq "SFE") {
   	$sqlquery = "select id from $schema.external_audit where fiscal_year = $fy ";
   	$sqlquery .= "and audit_type = '$type' and audit_seq = $seq and revision = 0 ";
   	$sqlquery .= "and team_lead_id = $leadid";
    }
    elsif ($type eq "ARC" | $type eq "ARP") {
    	$sqlquery = "select id from $schema.internal_audit where fiscal_year = $fy ";
    	$sqlquery .= "and audit_seq = $seq and revision = 0 and ";
    	$sqlquery .= "team_lead_id = $leadid";
    }
    elsif ($type eq "S") {
	     $sqlquery = "select id from $schema.surveillance where fiscal_year = $fy ";
	     $sqlquery .= "and id = $seq and team_lead_id = $leadid";
    }
    else {
    	$status = 0;
    	return ($status);
    }
    
    #print "<br>** $sqlquery ** <br>\n";
    $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    my $count = $values[0];
    if ($#values < 0 | $#values > 1) {
        $status = 0;
    } 
    else {
		  $status = $values[0];
    }
        
    return ($status);
}



#################################

# routine to generate a hash of lookup/values from a table
sub get_max_id {
    my $dbh = $_[0];
    my $table = $_[1];
    my $field = $_[2];

# generate query
# make sql statement
    my $sqlquery = "SELECT max($field) FROM $SCHEMA.$table";
 
# generate a 'cursor'
    my $csr = $dbh->prepare($sqlquery);
# execute or run the query
    $csr->execute;

  # max will return 1 row with 1 column which holds the largest value
   my @maxid=$csr->fetchrow_array;

# free up the generated 'cursor'
    $csr->finish;

  return ($maxid[0]);
  
}


###########

# routine to get the next value
sub get_next_value {
    my $dbh = $_[0];
    my $SCHEMA = $_[1];
    my $table = $_[2];
    my $field = $_[3];
    my $field2 = $_[4];
    my $value = $_[5];


# generate query
# make sql statement
    my $sqlquery = "SELECT max($field) FROM $SCHEMA.$table where $field2 = $value";
 
# generate a 'cursor'
    my $csr = $dbh->prepare($sqlquery);
# execute or run the query
    $csr->execute;

  # max will return 1 row with 1 column which holds the largest value
   my @maxid=$csr->fetchrow_array;

# free up the generated 'cursor'
    $csr->finish;

  return ($maxid[0]);
  
}

###########

# routine to get the next value
sub get_max_revision {
    my $dbh = $_[0];
    my $SCHEMA = $_[1];
    my $fy = $_[2];
    my $type = $_[3];
    my $org = $_[4];


# generate query
# make sql statement
    my $sqlquery = "SELECT max(revision) FROM $SCHEMA.audit_revisions 
                    where fiscal_year = $fy and audit_type = upper('$type') and auditing_org = '$org' ";

#print STDERR"** $sqlquery ** \n"; 
# generate a 'cursor'
    my $csr = $dbh->prepare($sqlquery);
# execute or run the query
    $csr->execute;

  # max will return 1 row with 1 column which holds the largest value
   my @maxid=$csr->fetchrow_array;

# free up the generated 'cursor'
    $csr->finish;
  if ($maxid[0]) {
  	return ($maxid[0]);
  }
  else {
   return 0;
  }
  
}
###########

# function to see if the audit schedule has been approved by one of the two approvers
sub checkApproval {
    my $dbh = $_[0];
    my $SCHEMA = $_[1];
    my $fy = $_[2];
    my $table = $_[3];


# generate query
# make sql statement
    my $sqlquery = "SELECT count(*) FROM $SCHEMA.$table 
                    where fiscal_year = $fy AND revision = -1 ";

#print STDERR"** $sqlquery ** \n"; 
# generate a 'cursor'
    my $csr = $dbh->prepare($sqlquery);
# execute or run the query
    $csr->execute;

  # max will return 1 row with 1 column which holds the largest value
   my $halfapproved = $csr->fetchrow_array;
#print STDERR "\n--> $halfapproved <--\n";
# free up the generated 'cursor'
    $csr->finish;
  if ($halfapproved) {
  	return (1);
  }
  else {
   return 0;
  }
  
}

####################
# routine to see if OQA or BSC has approved the schedule
sub checkApprover {
    my $dbh = $_[0];
    my $SCHEMA = $_[1];
    my $fy = $_[2];
    my $type = $_[3];

# generate query
# make sql statement
    my $sqlquery = "SELECT approver, to_char(approval_date,'MM/DD/YYYY'), approver2, to_char(approval2_date,'MM/DD/YYYY') FROM $SCHEMA.audit_revisions 
                    where fiscal_year = $fy and audit_type = upper('$type') and revision = -1 ";

#print STDERR"** $sqlquery ** \n"; 
# generate a 'cursor'
    my $csr = $dbh->prepare($sqlquery);
# execute or run the query
    $csr->execute;

   my @approver=$csr->fetchrow_array;

# free up the generated 'cursor'
    $csr->finish;

  return (@approver);
 
  
}
###########

# routine to get the next value
sub get_audit_count {
    my $dbh = $_[0];
    my $SCHEMA = $_[1];
    my $table  = $_[2];
    my $whereclause = $_[3];


# generate query
# make sql statement
    my $sqlquery = "SELECT count(*) FROM $SCHEMA.$table where $whereclause";

#print "<br>** $sqlquery ** <br>\n"; 
# generate a 'cursor'
    my $csr = $dbh->prepare($sqlquery);
# execute or run the query
    $csr->execute;

  # max will return 1 row with 1 column which holds the largest value
   my @count=$csr->fetchrow_array;

# free up the generated 'cursor'
    $csr->finish;

  return ($count[0]);
  
}

###########
# routine to get username/password for oracle
sub getOracleID {
    my $username = $DBUser;
    my $password;
    my $temp;
    if (open (FH, "$NQSConnectPath |")) {
        ($password, $temp) = split('//', <FH>);
        close (FH);
    } else {
        $username = "null";
        $password = "null";
    }

    return ($username, $password);
}


# routine to connect to the oracle database
sub NQS_connect {
    my %args = (
          server => $NQSServer,
          @_,
          );
    my $dbh;
    my $username;
    my $password;
    ($username, $password) = getOracleID;

    eval {
            $dbh = DBI->connect("dbi:Oracle:$args{server}",$username, $password, { RaiseError => 1, AutoCommit => 0 });
    };
    if ($@) {
        print STDERR "\nNQS_Utilities_Lib.pm/NQS_connect - Error Message: $@\n";
    }
    return ($dbh);
}

#########################



###########

# routine to disconnect from the oracle database
sub NQS_disconnect {
    my $dbh = $_[0];

    my $rc = $dbh->disconnect;

    return ($rc);
}


###########

# routine to Encrypt a password
sub NQS_encrypt_password {
    my $input_password = $_[0];

    $input_password = uc($input_password);
    my $password = crypt ($input_password, "NQS");
    if (length($input_password)>8) {
        $password .= crypt (substr($input_password, 8), "NQS");
    }

    while (length($password) > 25) {
        chop ($password);
    }

    return ($password);
}


###########

# routine to validate a user of the NQS system
sub validate_user {
    my $dbh = $_[0];
    my $username = $_[1];
    my $input_password = $_[2];

    my $status;
    my $password = &NQS_encrypt_password($input_password);
    $username = uc($username);

    if (($username eq "GUEST") && (uc($input_password) eq "GUEST"))
      {
      $status = 2;
      return ($status);
      }

    my $sqlquery = "select password from $SCHEMA.users where (username = '$username') and (password = '$password') and (isactive = 'T')";
    my $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    my @values = $csr->fetchrow_array;
    $csr->finish;

    my $test_password = $values[0];
    if ($#values < 0) {
        $status = 0;
    } else {
        if ($password eq $test_password) {
            $status = 1;
        } else {
            $status = 0;
        }
    }

#    my $csr = $dbh->prepare(qq{
#        BEGIN
#            $SCHEMA.validate_user (:user, :pass);
#        END;
#      });
#
#    $csr->bind_param(":user", $username);
#    $csr->bind_param(":pass", $password);
#    $csr->bind_param_inout(":stat", \$status, 5);
#    $csr->execute;
#    # free up the generated 'cursor'
#    $csr->finish;

#$status =1;
    return ($status);
}


###########

# routine to validate a user of the TREND system
sub validate_trend_user {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $username = $_[2];
    my $input_password = $_[3];

    my $status;
    my $password = &NQS_encrypt_password($input_password);
    $username = uc($username);

    if (($username eq "GUEST") && (uc($input_password) eq "GUEST"))
      {
      $status = 0;
      return ($status);
      }

    my $sqlquery = "select password from $schema.t_user where (username = '$username') and (password = '$password')";
    #print "$sqlquery\n";
    my $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    my @values = $csr->fetchrow_array;
    $csr->finish;

    my $test_password = $values[0];
    if ($#values < 0) {
        $status = 0;
    } else {
        if ($password eq $test_password) {
            $status = 1;
        } else {
            $status = 0;
        }
    }

#    my $csr = $dbh->prepare(qq{
#        BEGIN
#            $SCHEMA.validate_user (:user, :pass);
#        END;
#      });
#
#    $csr->bind_param(":user", $username);
#    $csr->bind_param(":pass", $password);
#    $csr->bind_param_inout(":stat", \$status, 5);
#    $csr->execute;
#    # free up the generated 'cursor'
#    $csr->finish;

#$status =1;
    return ($status);
}



###########
# routine to see if a user of the NQS system has a specific named priv
sub does_user_have_named_priv
  {
 # my $dbh = $_[0];
 # my $userid = $_[1];
 # my $namedpriv = uc($_[2]);

  my $status;

 # my $sqlquery = "SELECT privilegeid FROM $SCHEMA.privilege where UPPER(description) = '$namedpriv'";
 # print "\n<!-- $sqlquery -->\n\n";
 # my $csr = $dbh->prepare($sqlquery);
 # $csr->execute;
 # my @results = $csr->fetchrow_array;
 # $csr->finish;

 # my $test_priv = $results[0];
  #print "\n<!-- $userid $namedpriv $test_priv -->\n\n";
 # if ((!defined($test_priv)) || ($test_priv eq ''))
 #   {
 #   $status = 0;
 #   }
 # else
 #   {
 #   $status = does_user_have_priv($dbh, $userid, $test_priv);
 #   }
  #print "\n<!-- $status -->\n\n";
  return ($status);
  }


###########

# routine to select all available accesses to the DDT application
#sub select_access {
#    my $dbh = $_[0];
#    my $userid = $_[1];
#    my @privs
    
#    my $sqlquery = "select privilege from $SCHEMA.privilege";
#    print "\n<!-- $sqlquery -->\n\n";
#    my $csr = $dbh->prepare ($sqlquery);
#    $csr->execute;
#    while (@values = $csr->fetchrow_array) {
#            $privs[$values[0]] = 'F';
#    }
#    $csr->finish;

    
#    return (@privs);
#}


###########

# routine to get the privs for a user of the NQS system
sub get_user_privs {
    my $dbh = $_[0];
    my $userid = $_[1];
	 my %userPrivilegeHash;
	 
	 # get all privileges and set to 'F'
	 my $privquery = "select privilege from $SCHEMA.privilege";
	 my $csr = $dbh->prepare ($privquery);
    $csr->execute;
    while (my @values = $csr->fetchrow_array) {
	 	$userPrivilegeHash{$values[0]} = 0;
    }
	 $csr->finish;
	 
	 #set the user's privs to 'T'
	 my $userprivquery = "select p.privilege from $SCHEMA.privilege p, $SCHEMA.user_privilege up ";
	 $userprivquery .= "where up.userid = $userid and up.privilege = p.id ";

	 $csr = $dbh->prepare ($userprivquery);
    $csr->execute;
	 while (my @privs = $csr->fetchrow_array) {
	 	$userPrivilegeHash{$privs[0]} = 1;
    }
    $csr->finish;

    return (%userPrivilegeHash);
}


###########

# routine to get a user id
sub get_userid {
    my $dbh = $_[0];
    my $username = $_[1];

    $username = uc($username);

    my $sqlquery = "select id from $SCHEMA.users where username = '$username'";

    my $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    my @values = $csr->fetchrow_array;

    # free up the generated 'cursor'
    $csr->finish;


    return ($values[0]);
}


###########

# routine to get the next available comment number for a comment document
sub get_next_comment_number {
    my $cd = $_[0];
    my $dbh = $_[1];

    my $comment_number;
    my $csr = $dbh->prepare(qq{
        BEGIN
            $SCHEMA.get_next_comment_number (:cd, :cnum);
        END;
      });

    $csr->bind_param(":cd", $cd);
    $csr->bind_param_inout(":cnum", \$comment_number, 5);
    $csr->execute;
    # free up the generated 'cursor'
    $csr->finish;

#    $comment_number = 1;

    return ($comment_number);
}


###########

# routine to get the next available commentor id
sub get_next_commentor_id {
    my $dbh = $_[0];

    my $commentor_id;
    my $csr = $dbh->prepare(qq{
        BEGIN
            $SCHEMA.get_next_commentor_id (:cid);
        END;
      });

    $csr->bind_param_inout(":cid", \$commentor_id, 5);
    $csr->execute;
    # free up the generated 'cursor'
    $csr->finish;

    return ($commentor_id);
}


###########

# routine to get the next available preapproved_text id
sub get_next_preapproved_text_id {
    my $dbh = $_[0];

    my $preapproved_text_id;
    my $csr = $dbh->prepare(qq{
        BEGIN
            $SCHEMA.get_next_preapproved_text_id (:ptid);
        END;
      });

    $csr->bind_param_inout(":ptid", \$preapproved_text_id, 5);
    $csr->execute;
    # free up the generated 'cursor'
    $csr->finish;

    return ($preapproved_text_id);
}


###########

# routine to get the next available surveillance request id
sub get_next_surveillance_request_id {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $csr;
    my $status;
    my @values;
    my $request_id;
    my $sqlquery = "SELECT $schema.surveillance_request_seq.NEXTVAL from DUAL";
    $csr = $dbh->prepare($sqlquery);
    $status = $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    $request_id = $values[0];
    
    return ($request_id);
}

###########

# routine to get the next available surveillance id
sub get_next_surveillance_id {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $csr;
    my $status;
    my @values;
    my $request_id;
    my $sqlquery = "SELECT $schema.surveillance_seq.NEXTVAL from DUAL";
    $csr = $dbh->prepare($sqlquery);
    $status = $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    $request_id = $values[0];
    
    return ($request_id);
}


###########

# routine to get the next available users id
sub get_next_users_id {
    my $dbh = $_[0];

    my $users_id;
    my $csr = $dbh->prepare(qq{
        BEGIN
            $SCHEMA.get_next_users_id (:uid);
        END;
      });

    $csr->bind_param_inout(":uid", \$users_id, 5);
    $csr->execute;
    # free up the generated 'cursor'
    $csr->finish;

    return ($users_id);
}


###########

# routine to generate a hash of lookup/values from a table
sub get_lookup_values {
    my $dbh = $_[0];
    my $table = $_[1];
    my $lookups = $_[2];
    my $values = $_[3];
    my $wherestatement = ($_[4]) ? $_[4] : "";     # optional

    tie my %lookup_list, "Tie::IxHash";
    #my %lookup_list;
    my @values;
    my $lookup;
    my $value;

# generate query
# make sql statement
    my $sqlquery = "SELECT $lookups, $values FROM $SCHEMA.$table " ;
    if ($wherestatement gt " ") {
        $sqlquery .= " WHERE $wherestatement ";
    }
    $sqlquery .= " ORDER BY $values ";

 #print STDERR "\n  $sqlquery \n";   
# generate a 'cursor'
    my $csr = $dbh->prepare($sqlquery);
# execute or run the query
    $csr->execute;

    while (@values = $csr->fetchrow_array) {
        ($lookup, $value) = @values;
        $lookup_list{$lookup} = $value;
    }

# free up the generated 'cursor'
    $csr->finish;

    return (%lookup_list);
}


###########

# routine to generate a hash of users/names with selected priv
sub get_authorized_users {
    my $priv = $_[0];
    my $dbh = $_[1];

    my @values;
    my $firstname;
    my $lastname;
    my $id;
    my %user_list;

# generate query
# make sql statement
    my $sqlquery = "select users.firstname, users.lastname, users.id from $SCHEMA.users, $SCHEMA.user_privilege privs where users.id=privs.userid and privs.privilege =$priv";
# generate a 'cursor'
    my $csr = $dbh->prepare($sqlquery);
# execute or run the query
    $csr->execute;

    while (@values = $csr->fetchrow_array) {
        ($firstname, $lastname, $id) = @values;
        $user_list{$id} = "$firstname $lastname";
    }

# free up the generated 'cursor'
    $csr->finish;

#    %user_list = (
#        "brownf" => "Fred Brown",
#        "calhouns" => "Steve Calhoun",
#        "farmerc" => "Carl Farmer",
#        "francesc" => "Carol Frances",
#        "fritzm" => "Michael Fritz",
#        "hamiltonb" => "Bertha Hamilton",
#        "harrisong" => "Howard Hollingsworth",
#        "jacksonj" => "Jeff Jackson",
#        "joelb" => "Bonnie Joel",
#        "johnj" => "James John",
#        "juddw" => "Wilma Judd",
#        "larsons" => "Steve Larson",
#        "morrisonp" => "Paul Morrison",
#        "russellj" => "James Russell",
#        "russells" => "Sue Russell",
#        "slates" => "Steve Slate",
#        "stevensonl" => "Linda Stevenson",
#        "taylort" => "Tom Taylor",
#        "washingtonw" => "Wilbur Washington",
#        "worthingtonj" => "John Worthington"
#    );
    return (%user_list);
}


###########

# routine to generate a hash of users/names who are assigned a task for cd/comment
sub get_assigned_users {
    my $authtype = $_[0];
    my $cd_id = $_[1];
    my $comment_id = $_[2];
    my $dbh = $_[3];

    my %user_list = (
        "brownf" => "Fred Brown",
        "calhouns" => "Steve Calhoun",
    );
    return (%user_list);
}


###########

# routine to generate an oracle friendly date
sub get_date {
    my $indate = $_[0];

    my $outstring = '';
    my $day; my $month; my $year;
    my @months = ("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec");

    if ($indate gt ' ') {
        ($month, $day, $year) = split /\//, $indate;
        $month = $month -1;
    } else {
        ($day, $month, $year) = (localtime)[3,4,5];
        $year = $year + 1900;
    }

    $outstring .= "$day-$months[$month]-$year";

    return ($outstring);
}

###########

# routine to generate an oracle friendly date
sub get_formatted_date {
    my $formatstring = $_[0];
    my $indate = $_[1];

    my $outstring = '';
    my $day; my $month; my $year; my $wday;
    my $outday; my $outmonth; my $outyear;
    my $inday; my $inmonth; my $inyear; my $intime;
    my @mons = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    my @months = qw(January February March April May June July August September October November Decmeber);
    my @dys = qw(Sun Mon Tue Wed Thu Fri Sat);
    my @days = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);

    if ($indate gt ' ')
      {
      ($inmonth, $inday, $inyear) = split /\//, $indate;
      $inmonth--;
      $inyear -= 1900;
      $intime = timelocal(0, 0, 0, $inday, $inmonth, $inyear);
      #print "$inmonth $inday $inyear $intime<br>\n";
      ($day, $month, $year, $wday) = (localtime ($intime))[3,4,5,6];
      $year = $year + 1900;
      }
    else
      {
      ($day, $month, $year, $wday) = (localtime)[3,4,5,6];
      $year = $year + 1900;
      }

    $outstring .= "$day-$mons[$month]-$year";

    if ($formatstring)  # if format string is empty, outstring is already formatted.
      {
      $outmonth = '';
      while ($formatstring =~ /(MONTH)/)
        {
        $outmonth = $months[$month];
        $formatstring =~ s/$1/$outmonth/;
        }
      $outmonth = '';
      while ($formatstring =~ /(MON)/)
        {
        $outmonth = $mons[$month];
        $formatstring =~ s/$1/$outmonth/;
        }
      $outmonth = '';
      while ($formatstring =~ /(MM)/)
        {
        $outmonth = "00$month";
        $outmonth = substr($outmonth, -2);
        $formatstring =~ s/$1/$outmonth/;
        }

      $outday = '';
      while ($formatstring =~ /(DAY)/)
        {
        $outday = $days[$wday];
        $formatstring =~ s/$1/$outday/;
        }
      $outday = '';
      while ($formatstring =~ /(DY)/)
        {
        $outday = $dys[$wday];
        $formatstring =~ s/$1/$outday/;
        }

      $outday = '';
      while ($formatstring =~ /(DD)/)
        {
        $outday = "00$day";
        $outday = substr($outday, -2);
        $formatstring =~ s/$1/$outday/;
        }

      $outyear = '';
      while ($formatstring =~ /(YYYY)/)
        {
        $outyear = $year;
        $formatstring =~ s/$1/$outyear/;
        }
      $outyear = '';
      while ($formatstring =~ /(YY)/)
        {
        $outyear = substr($year, -2);
        $formatstring =~ s/$1/$outyear/;
        }

      $outstring = $formatstring;
      }

    return ($outstring);
}

############
# routine to insert an entry into the activity log
sub log_activity {
    my ($dbh, $iserror, $usersid, $description) = @_;
    my ($sql, $sth);

    $dbh->do("INSERT INTO $SCHEMA.activity_log (USERSID, DATELOGGED, ISERROR, DESCRIPTION) VALUES ($usersid, SYSDATE, '$iserror','$description')");
}

############
# routine to insert an entry into the NQS activity log
sub log_nqs_activity {
    my ($dbh, $SCHEMA, $iserror, $userid, $description) = @_;
    my ($sql, $sth);

    $dbh->do("INSERT INTO nqs.nqs_activity_log (USERID, DATELOGGED, ISERROR, DESCRIPTION) VALUES ($userid, SYSDATE, '$iserror','$description')");
}

############
# routine to insert an error entry into the NQS error log
sub log_nqs_error {

    my ($dbh, $SCHEMA, $iserror, $userid, $description) = @_;
    my ($sql, $sth);

    $dbh->do("INSERT INTO nqs.nqs_error_log (USERID, DATELOGGED, ISERROR, DESCRIPTION) VALUES ($userid, SYSDATE, '$iserror','$description')");
}
###########

sub lookup_single_value
  {
  # This sub executes a SELECT which returns a single column value (or
  # concatentation of column values) (cell) from a single table with the given
  # ID, primarily for lookup tables, but can be used for others.
  # If the lookupid is a string, the calling procedure must include the needed
  # single quotes.
  my $dbh = $_[0];
  my $SCHEMA = $_[1];
  my $tablename = $_[2];
  my $column = $_[3];
  my $lookupid = $_[4];
  
  if (!($lookupid)) {
  	$lookupid = 0;
  }

  my $sqlquery = "SELECT $column FROM $SCHEMA.$tablename WHERE id = $lookupid";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  # should return 1 row with 1 column which will hold the requested value
  my @results = $csr->fetchrow_array;

  my $rc = $csr->finish;

  return ($results[0]);
  }

###########

sub lookup_column_values
  {
  # This sub executes a SELECT which returns rows of a column (or concatentation of columns)
  # from a single table with the given where statement.
  my $dbh = $_[0];
  my $tablename = $_[1];
  my $column = $_[2];
  my $wherestatement = $_[3];
  my $orderbystatement = $_[4];

  my @valuearray;
  my $arrayindex = 0;

  my $sqlquery = "SELECT $column
                  FROM $SCHEMA.$tablename";
  if (defined($wherestatement) && $wherestatement ne "")
    {
    $sqlquery .= " WHERE $wherestatement";
    }
  if (defined($orderbystatement) && $orderbystatement ne "")
    {
    $sqlquery .= " ORDER BY $orderbystatement";
    }
    
#  print STDERR "$sqlquery\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;
  
  # should return 1 column which will hold the requested values
  while (my @results = $csr->fetchrow_array)
    {
    $valuearray[$arrayindex++] = $results[0];
    }

  my $rc = $csr->finish;
#  print STDERR "returnvalue = $valuearray[0]\n";
  return (@valuearray);
  }

###########

# routine to get a user's full name
sub get_fullname {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $userid = $_[2];
    my $csr;
    my @values;
    my $fullname;
    my $sqlquery = "SELECT firstname, lastname FROM $schema.users WHERE id = $userid";
        $csr = $dbh->prepare($sqlquery);
        $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    $fullname = ((defined($values[0])) ? $values[0] : "") . ' ' . ((defined($values[1])) ? $values[1] : "");
    return ($fullname);
}

###########

# routine to lookup a value from a table
sub get_value {
    my $dbh = $_[0];
    my $table = $_[1];
    my $values = $_[2];
    my $wherestatement='';      # optional
    $wherestatement = $_[3];
    my @values;
    my $csr;
    my $value=0;
    my $sqlquery = "select $values from $SCHEMA.$table WHERE $wherestatement";
#print STDERR "\n $sqlquery \n";  
    $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    @values = $csr->fetchrow_array;
    if ($#values >= 0) {
       $value = $values[0];
    }
    else {$value = 0; }
    $csr->finish;
    return ($value);
}

###########

sub formatID2 {
    my ($id, $type) = @_;
    return("$type"."0" x (5 - length($id)).$id);
}

###########

# routine to send a mail message to a user notifing that they have work in the cms.
sub notifyUser {
    my %args = (
        dbh => '',
        schema => '',
        userID => 0,
        sender => 'jodi_starkey@ymp.gov',
        subject => 'ddt Notification',
#        message => "You have new work waiting for you in the Commitment Management System.\n\nThe CMS can be found on the DOE Intranet Home Page.\nOr you can log in at: http://intranet.ymp.gov/cgi-bin/cms/login.pl\n\n\nPlease do not reply to this message. \nDirect any questions to Sheryl Morris at (702) 794-5487.",
        message => "You have new work waiting for you in the Commitment Management System.\n\nA link to the CMS can be found on the DOE Intranet Home Page.\nOr you can log in at: http://intranet.ymp.gov/cgi-bin/cms/login.pl\n\n\nPlease do not reply to this message. \nDirect any questions to Sheryl Morris at (702) 794-5487.",
        timeStamp => 'F',
        @_,
    );
    my $status = 0;
    my $sqlcode = '';
    my $csr;
    my @values;
    
    eval {
        
        if (defined(1) && 1 == 1) {
            $sqlcode = "SELECT usersid, email, TO_CHAR(lastnotified, 'YYYYMMDD'), TO_CHAR(SYSDATE, 'YYYYMMDD'),isactive FROM $args{schema}.users WHERE usersid = $args{userID}";
            @values = $args{'dbh'}->selectrow_array($sqlcode);
            if (! defined($values[2])) {
                $values[2] = ' ';
            }
            if ($values[0] == $args{userID}) {
                if ($values[4] eq 'T') {
                    $status = 1;
                    if ($values[2] < $values[3]) {
                        $status = SendMailMessage(sendTo => $values[1], sender => $args{sender}, subject => $args{subject}, message => $args{message}, timeStamp => $args{timeStamp});
                        if ($status == 1) {
                            $sqlcode = "UPDATE $args{schema}.users SET lastnotified = SYSDATE WHERE usersid = $args{userID}";
                            $csr = $args{dbh}->prepare($sqlcode);
                            $status = $csr->execute;
                            $csr->finish;
                            $args{dbh}->commit;
                            $status = 1;
                        }
                    }
                } else {
                    $status = -6;
                }
            } else {
                $status = -4;
            }
        } else {
            $status = 1;
        }
    };
    if ($@) {
        $status = -5;
    }

    return ($status);
}

sub lpadzero {
    my $instring = $_[0];
    my $strlength = $_[1];

    my $outstring = "";
    for (my $i=1; $i <= ($strlength - length($instring)); $i++) {
        $outstring .= "0";
    }
    $outstring .= $instring;
    return ($outstring);
}

############
# routine to insert an error entry into the trend analysis error log
sub log_oqa_error {

    my ($dbh, $SCHEMA, $iserror, $userid, $description) = @_;
    my ($sql, $sth);

    $dbh->do("INSERT INTO $SCHEMA.error_log (USERID, DATELOGGED, ISERROR, DESCRIPTION) VALUES ($userid, SYSDATE, '$iserror','$description')");
}

###################################################################################################################################
sub error_message {                                                                                                                #
#                                                                                                                                 #
#  Constructs and returns a formatted error message including the application-specific and oracle error strings and instructions  #
#  for getting help.  This string is intended to be displayed by a javascript alert() call.  Also writes an error message to the  #
#  database activity_log table and to the web server error log.  The web server error log message consists of the date/time the   #
#  error occurred, the username, userid, and schema in effect, and the application-specific and oracle error strings.  Required   #
#  parameters are:                                                                                                                #
#                                                                                                                                 #
#     dbh         - database handle                                                                                               #
#     username    -                                                                                                               #
#     usersid     -                                                                                                               #
#     tablename   - name of the table that was being updated                                                                      #
#     recordid    - record number of the table where the error occurred                                                           #
#     appError    - application-specific error string                                                                             #
#     oracleError - oracle error string - obtained from $@ after attempting to execute SQL statement(s) inside an eval{}          #
#                                                                                                                                 #
###################################################################################################################################
   my ($dbh, $username, $usersid, $tablename, $recordid, $appError, $oracleError) = @_;
   my $instructions = "Please save the diagnostic information shown above and contact the Computer Support Center at (702) 794-1335 for assistance.";
   my $errorMessage = "The following error occurred while attempting to $appError:\n\n$oracleError\n$instructions\n";
   my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
   $mon = substr("00" . ++$mon, -2);
   $mday = substr("00" . $mday, -2);
   $year += 1900;
   $hour = substr("00" . $hour, -2);
   $min = substr("00" . $min, -2);
   $sec = substr("00" . $sec, -2);
   print STDERR "\nNQS error: $mon/$mday/$year $hour:$min:$sec - $username/$usersid - $appError failed:\n$oracleError\n";
   $errorMessage =~ s/\n/\\n/g;
   return ($errorMessage);
}

###########

# Routine to display the error generated by ErrorMessage in a javascript alert box
sub display_error {
	my $dbh = $_[0];
	my $errorString = $_[1];
	if ($@) {
		my $alertstring = error_message($dbh,'','','','',$errorString,$@);
		$alertstring =~ s/'/\\'/g;
		print <<PAGEERROR;
		<script type="text/javascript">
		<!--
			 alert('$alertstring');	     
		//-->
		</script>
PAGEERROR
	}

}

#