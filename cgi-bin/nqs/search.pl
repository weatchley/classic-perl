#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/qa/perl/RCS/search.pl,v $
#
# $Revision: 1.7 $
#
# $Date: 2005/11/02 18:57:21 $
#
# $Author: starkeyj $
#
# $Locker: higashis $
#
# $Log: search.pl,v $
# Revision 1.7  2005/11/02 18:57:21  starkeyj
# modified writeSurveillance to remove a print to STDERR line
#
# Revision 1.6  2005/11/02 18:54:35  starkeyj
# modified querySurveillance to include surveillance_seq in selection
# modified writeSurveillance to pass surveillance_seq to getSurvId call
#
# Revision 1.5  2004/10/21 18:53:17  starkeyj
# modified 'cgiaction eq undefined' to add selection for internal/external surveillances
# modified javascript function surveillance to add objects for surveillance type
# modified writeSurveillance to add parameter of type to querySurveillance call
# modified querySurveillance to add parameter to check for selected type value of internal or external
#
# Revision 1.4  2004/05/30 22:44:14  starkeyj
# added new text fields to the search criteria for audits and surveilalnces
#
# Revision 1.3  2002/09/09 20:50:35  johnsonc
# Included 'Log' entry parameter for RCS file header.
#
#

#use OQA_specific qw(:Functions);
use NQS_Header qw(:Constants);
use OQA_Utilities_Lib qw(:Functions);
use OQA_Widgets qw(:Functions);
use strict;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $NQScgi = new CGI;
my $username = defined($NQScgi->param("username")) ? $NQScgi->param("username") : "GUEST";
my $userid = defined($NQScgi->param("userid")) ? $NQScgi->param("userid") : "None";
my $schema = defined($NQScgi->param("schema")) ? $NQScgi->param("schema") : "None";
my $auditSearchString = defined($NQScgi->param("auditsearchstring")) ? $NQScgi->param("auditsearchstring") : "";
my $survSearchString = defined($NQScgi->param("survsearchstring")) ? $NQScgi->param("survsearchstring") : "";
my $extIssuedBy = defined($NQScgi->param("ext_issued_by")) ? $NQScgi->param("ext_issued_by") : "";
my $intIssuedBy = defined($NQScgi->param("int_issued_by")) ? $NQScgi->param("int_issued_by") : "";
my $survIssuedBy = defined($NQScgi->param("surv_issued_by")) ? $NQScgi->param("surv_issued_by") : "";
my $survType = defined($NQScgi->param("surv_type")) ? $NQScgi->param("surv_type") : "";
my $reqIssuedBy = defined($NQScgi->param("req_issued_by")) ? $NQScgi->param("req_issued_by") : "";
my $cgiaction = defined($NQScgi->param("cgiaction")) ? $NQScgi->param("cgiaction") : "";
my $audit = defined($NQScgi->param("audit")) ? $NQScgi->param("audit") : "";
my $surv = defined($NQScgi->param("surv")) ? $NQScgi->param("surv") : "";

#my $queryYear = defined($NQScgi->param("queryyear")) ? $NQScgi->param("queryyear") : "";
my $option = defined($NQScgi->param("option")) ? $NQScgi->param("option") : "";
my ($checked, $results, $auditType, @years, $queryYear, $scheduleOptions, $scheduleType, $text, $loopCount);
my ($searchText, $formattedId, $title, $prompt, $visibleInternal, $visibleExternal, $visibleSurv, $visibleSurvRequest);
my $message = "";
my $rows = 0;
my $dbh = &NQS_connect();
$dbh->{LongReadLen} = 1000001;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 

###################################################################################################################################
sub matchFound {                                                                                                                  #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out;
   $out = ($args{text} =~ m/$args{searchString}/i) ? 1 : 0;
   #print STDERR "\nmatchfound = $out\n";
   return ($out);
}

###################################################################################################################################
sub highlightResults {                                                                                                            #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = $args{text};
   if (defined($NQScgi->param("case"))) {
      $out =~ s/($args{searchString})/<font color=#ff0000>$1<\/font>/g;
   } else {
      $out =~ s/($args{searchString})/<font color=#ff0000>$1<\/font>/ig;
   }
   return ($out);
}

###################################################################################################################################
sub getFiscalYears {																																					 #					
###################################################################################################################################
	my $dbh = $_[0];
	my $schema = $_[1];
	my $years = "(";
	my $i = 0;
	my $sql = "SELECT SUBSTR(fiscal_year, 3) FROM $schema.fiscal_year ORDER BY fiscal_year DESC";
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	while (my $year = $sth->fetchrow_array) {
		$years .= "$year,";
	}
	chop($years);
	$years .= ")";
	return ($years);
}

###################################################################################################################################
sub formatFiscalYear {																																					 #					
###################################################################################################################################
	my $year = $_[0];
	if ($year >= 95) {
		$year = "19" . $year;
	}
	elsif ($year < 9) {
		$year = "200" . $year;
	}
	else {
		$year = "20" . $year;
	}
	return ($year);
}

###################################################################################################################################
sub queryAudit {																																					 #					
###############################################################################################################################
	my ($dbh, $schema, $tableType, $scheduleOptions, $years, $issuedBy) = @_;
	my $sql = "SELECT id, audit_seq, audit_type, issuedto_org_id, team_members, scope, notes, revision, b.fiscal_year, issuedby_org_id, ";
	$sql .= "title, procedures, overall_results ";
	if ($tableType eq "external") {
		$sql .= ", product";
	}
	#else {
	#	$sql .= ", issuedby_org_id";
	#}
	$sql .= " FROM $schema.$tableType" . "_audit a, fiscal_year b WHERE revision = 0 AND a.fiscal_year IN $years AND "
	        . "a.fiscal_year = SUBSTR(b.fiscal_year, 3)"; 
	if ($issuedBy eq "OQA") {
		$sql .= " AND issuedby_org_id = 28";
	}
	if ($issuedBy eq "BSC") {
		$sql .= " AND issuedby_org_id = 1";
	}
	if ($issuedBy eq "OCRWM") {
		$sql .= " AND issuedby_org_id = 24";
	}
	$sql .= " ORDER BY b.fiscal_year DESC, id";
	#print  "<!-- $sql -->\n";
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	
	return ($sth);
}


######################################################################################################################################
sub querySurveillance {																																					 #					
######################################################################################################################################
	my ($dbh, $schema, $years, $survIssuedBy, $survType) = @_; 
	my $sql = "SELECT id, issuedto_org_id, notes, scope, team_members, elements, initial_contact, status, "
	          . "issuedby_org_id, int_ext, title, procedures, overall_results, b.fiscal_year, surveillance_seq FROM "
				 . "$schema.surveillance a, $schema.fiscal_year b WHERE a.fiscal_year IN $years "
				 . "AND a.fiscal_year = SUBSTR(b.fiscal_year, 3) ";
	if ($survIssuedBy eq "OQA") {
		$sql .= "AND issuedby_org_id = 28 ";
	}
	if ($survIssuedBy eq "BSC") {
		$sql .= "AND issuedby_org_id = 1 ";	
	}
	if ($survIssuedBy eq "OCRWM") {
		$sql .= "AND issuedby_org_id = 24 ";	
	}
	if ($survType ne 'ALL') {
		$sql .= "AND int_ext = '$survType' ";
	}
	$sql .= "ORDER BY b.fiscal_year DESC, id";
	print "<!-- $sql -->\n";
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	
	return ($sth);
}

###################################################################################################################################
sub querySurveillanceRequest {                                                                                                    #
###################################################################################################################################
	my ($dbh, $schema, $years, $issuedBy) = @_; 
	my $sql = "SELECT id, issuedto_org_id, reason_for_request, requestor, subject_line, subject_detail, "
				 . " disapproval_rationale, surveillance_id, issuedby_org_id, b.fiscal_year FROM $schema.surveillance_request a, "
				 . "$schema.fiscal_year b WHERE a.fiscal_year IN $years AND a.fiscal_year = SUBSTR(b.fiscal_year, 3) ";
	if ($issuedBy eq "OQA") {
		$sql .= "AND issuedby_org_id = 28 ";
	}
	if ($issuedBy eq "BSC") {
		$sql .= "AND issuedby_org_id = 1 ";	
	}
	$sql .= "ORDER BY b.fiscal_year DESC, id";

	my $sth = $dbh->prepare($sql);
	$sth->execute;
	return ($sth);
}

###################################################################################################################################
sub getStringDisplayLength {                                                                                                      #
###################################################################################################################################
   my %args = (
      @_,
   );
   return ($NQScgi->param('survtextoption') eq 'truncate' || $NQScgi->param('audittextoption') eq 'truncate') ? 250 : length($args{str});
}

#################
sub writeSurveillance {
#################
	my $results = "";
	my $years;
	eval {
		$survSearchString =~ s/\\/\\\\/g;
		$survSearchString =~ s/\{/\\\{/g;
		$survSearchString =~ s/\}/\\\}/g;
		$survSearchString =~ s/\(/\\\(/g;
		$survSearchString =~ s/\)/\\\)/g;
		$survSearchString =~ s/\[/\\\[/g;
		$survSearchString =~ s/\]/\\\]/g;
		$survSearchString =~ s/\*/\\\*/g;
		$survSearchString =~ s/\./\\\./g;
		$survSearchString =~ s/\?/\\\?/g;
		$survSearchString =~ s/\+/\\\+/g;
		$survSearchString =~ s/\|/\\\|/g;
		$survSearchString =~ s/\^/\\\^/g;
		$survSearchString =~ s/\$/\\\$/g;
		$survSearchString =~ s.\/.\\\/.g;
		if (defined($NQScgi->param('dosurveillance'))) {
			$results .= &start_table(3, 'center', 150, 80, 520);
			$results .= &title_row('lightsteelblue', 'black', '<center><font size=3>Surveillances</font></center>');
			$results .= &title_row('lightsteelblue', 'black', '<font size=3>Search Results: Found <x> Matches</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to view individual results</font></i>)');
			$results .= &add_header_row();
			$results .= "<td bgcolor=aliceblue><center><b><font color=black>Surveillance Number</font></b></center></td>\n";
		#				$results .= "<td bgcolor=aliceblue><center><b><font color=black>Fiscal Year</font></b></center></td>\n";
			$results .= "<td bgcolor=aliceblue><center><b><font color=black>Field Name</font></b></center></td>\n";
			$results .= "<td bgcolor=aliceblue><b><font color=black>Text</font></b></td>\n";      		
			if ($NQScgi->param('survqueryyear') eq "(all)") {
				$years = &getFiscalYears($dbh, $schema);
			}
			else {
				$years = "(" . substr($NQScgi->param('survqueryyear'), 2) . ")";
			}
			my %searchHash;
			my $sth = &querySurveillance($dbh, $schema, $years, $survIssuedBy, $NQScgi->param('surv_type'));
			while (my ($id, $issuedToId, $notes, $scope, $team, $element, $contact, $status, $issuedById, $intExt, $surveillancetitle, $procedures, $overallresults, $year, $seq) = $sth->fetchrow_array) {
#				if (defined($NQScgi->param('dosurveillancenotes'))) {
#					$searchHash{'Notes'} = $notes;
#				}
				if (defined($NQScgi->param('dosurveillancescope'))) {
					$searchHash{'Scope'} = $scope;
				}      				
				if (defined($NQScgi->param('dosurveillanceteam'))) {
					$searchHash{'Team Members'} = $team;
				}
				if (defined($NQScgi->param('dosurveillanceelements'))) {
					$searchHash{'Elements'} = $element;
				}
#				if (defined($NQScgi->param('dosurveillancecontact'))) {
#					$searchHash{'Contact'} = $contact;
#				}
				if (defined($NQScgi->param('dosurveillancestatus'))) {
					$searchHash{'Status'} = $status;
				}
				if (defined($NQScgi->param('dosurveillancetitle'))) {
					$searchHash{'Title'} = $surveillancetitle;
				}
				if (defined($NQScgi->param('dosurveillanceprocedures'))) {
					$searchHash{'Procedures'} = $procedures;
				}
				if (defined($NQScgi->param('dosurveillanceResults'))) {
					$searchHash{'Overall Results'} = $overallresults;
				}
				while (($title, $searchText) = each(%searchHash)) {
					if (&matchFound(text => $searchText, searchString => $survSearchString)) {
						$rows++;
						$results .= &add_row();
						$formattedId = &getSurvId($dbh, $issuedById, $issuedToId, $intExt, $year, $seq);
						$prompt = "Click here for full information on surveillance $formattedId";
						$queryYear = substr($year, 2);
						$results .= &add_col() . "<center><a href=\"javascript:submitSurvView($id, $queryYear);\" title='$prompt'>$formattedId</a></center>";
#		#           $results .= &add_col() . "<center><b>$years[$i]</b></center>";
						$results .= &add_col() . "<center><b>$title</b></center>";
						$text = &highlightResults(text => $searchText, searchString => $survSearchString);
						$results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
					}
				}
			}
			$results .= &end_table() . "</center>\n";
			if ($rows > 0) {
				$results =~ s/<x>/$rows/;
				$results =~ s/Matches/Match/ if ($rows == 1);
				print $results
			} 
			else {
				$message = "No surveillance matches found for \"$survSearchString\"\\n";
				$message =~ s/'/%27/g;
			}
		}
		if (defined($NQScgi->param('dosurveillancerequest'))) {
			$rows = 0;
			$results = "";
			$results .= &start_table(3, 'center', 150, 80, 520);
			$results .= &title_row('lightsteelblue', 'black', '<center><font size=3>Surveillance Request</font></center>');
			$results .= &title_row('lightsteelblue', 'black', '<font size=3>Search Results: Found <x> Matches</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to view individual results</font></i>)');
			$results .= &add_header_row();
			$results .= "<td bgcolor=aliceblue><center><b><font color=black>Surveillance Request Number</font></b></center></td>\n";
		#				$results .= "<td bgcolor=aliceblue><center><b><font color=black>Fiscal Year</font></b></center></td>\n";
			$results .= "<td bgcolor=aliceblue><center><b><font color=black>Field Name</font></b></center></td>\n";
			$results .= "<td bgcolor=aliceblue><b><font color=black>Text</font></b></td>\n";      		
			if ($NQScgi->param('survqueryyear') eq "(all)") {
				$loopCount = @years = &getFiscalYears($dbh, $schema);
				$years = &getFiscalYears($dbh, $schema);
			}
			else {
				$years = "(" . substr($NQScgi->param('survqueryyear'), 2) . ")";
			}
			my %searchHash;
			my $sth = &querySurveillanceRequest($dbh, $schema, $years, $reqIssuedBy);
			while (my ($id, $issuedToId, $request, $requestor, $subject, $detail, $rationale, $survId, $issuedById, $year) = $sth->fetchrow_array) {
				if (defined($NQScgi->param('dosurveillancerequestreason'))) {
					$searchHash{'Reason For Request'} = defined($request) ? $request : "";
				}
				if (defined($NQScgi->param('dosurveillancerequestrequestor'))) {
					$searchHash{'Requestor'} = defined($requestor) ? $requestor : "";
				}
				if (defined($NQScgi->param('dosurveillancerequestsubjectline'))) {
					$searchHash{'Subject Line'} = defined($subject) ? $subject : "";
				}      				
				if (defined($NQScgi->param('dosurveillancerequestsubjectdetail'))) {
					$searchHash{'Subject Detail'} = defined($detail) ? $detail : "";
				}
#					if (defined($NQScgi->param('dosurveillancerequestdisapprovalrationale'))) {
#						$searchHash{'Disapproval Rationale'} = $rationale;
#					}
				while (($title, $searchText) = each(%searchHash)) {
					if (&matchFound(text => $searchText, searchString => $survSearchString)) {
						$rows++;
						$results .= &add_row();
#						if (!(defined($id))) {print STDERR "id is null $id\n"; }
						$formattedId = &getSurvRequestId($dbh, $issuedById, $issuedToId, $year, $id);
						$prompt = "Click here for full information on surveillance request $formattedId";
						$queryYear = substr($year, 2, 2);
						$results .= &add_col() . "<center><a href=\"javascript:submitSurvRequestView($id, $queryYear, '";
						if (defined($survId) && $survId gt "") {
							my $sth1 = $dbh->prepare("SELECT int_ext, surveillance_seq FROM $schema.surveillance WHERE fiscal_year = " . substr($year, 2, 2) . " AND id = $survId");
							$sth1->execute;
							my ($intExt, $seq) = $sth1->fetchrow_array;
						$results .= &getSurvId($dbh, $issuedById, $issuedToId, $intExt, $year, $seq);
						}
						$results .= "','$formattedId');\"";
						$results .= " title='$prompt'>$formattedId</a></center>";
						$results .= &add_col() . "<center><b>$title</b></center>";
						$text = &highlightResults(text => $searchText, searchString => $survSearchString);
						$results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
					}
				}
			}
			$results .= &end_table() . "</center>\n";
			if ($rows > 0) {
				$results =~ s/<x>/$rows/;
				$results =~ s/Matches/Match/ if ($rows == 1);
				print $results;
			} 
			else {
				$message .= "No surveillance request matches found for \"$survSearchString\"";
				$message =~ s/'/%27/g;
			}
		}
		if ($message ne "") {
			print "<script language=javascript>\n<!--\nvar mytext ='$message';\nalert(unescape(mytext));\n // $form.submit();\n//-->\n</script>\n";
		}
	};
	if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid," $username Error searching for surveillance requests. $@");
	}

}

#################
sub writeAudit {
#################
	my $years;
	my $results = "";
   eval {
      $auditSearchString =~ s/\\/\\\\/g;
      $auditSearchString =~ s/\{/\\\{/g;
      $auditSearchString =~ s/\}/\\\}/g;
      $auditSearchString =~ s/\(/\\\(/g;
		$auditSearchString =~ s/\)/\\\)/g;
		$auditSearchString =~ s/\[/\\\[/g;
		$auditSearchString =~ s/\]/\\\]/g;
		$auditSearchString =~ s/\*/\\\*/g;
		$auditSearchString =~ s/\./\\\./g;
		$auditSearchString =~ s/\?/\\\?/g;
		$auditSearchString =~ s/\+/\\\+/g;
		$auditSearchString =~ s/\|/\\\|/g;
		$auditSearchString =~ s/\^/\\\^/g;
		$auditSearchString =~ s/\$/\\\$/g;
		$auditSearchString =~ s.\/.\\\/.g;
		if (defined($NQScgi->param('dointernalaudit'))) {
			$results = &start_table(3, 'center', 150, 80, 520);
			$results .= &title_row('lightsteelblue', 'black', '<center><font size=3>Internal Audits</font></center>');
			$results .= &title_row('lightsteelblue', 'black', '<font size=3>Search Results: Found <x> Matches</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to view individual results</font></i>)');
			$results .= &add_header_row();
			$results .= "<td bgcolor=aliceblue nowrap><center><b><font color=black>Audit Number</font></b></center></td>\n";
			$results .= "<td bgcolor=aliceblue><center><b><font color=black>Field Name</font></b></center></td>\n";
			$results .= "<td bgcolor=aliceblue><b><font color=black>Text</font></b></td>\n";
			if ($NQScgi->param('auditqueryyear') eq "(all)") {
				$years = &getFiscalYears($dbh, $schema);
			}
			else {
				$years = "(" . substr($NQScgi->param('auditqueryyear'), 2) . ")";
			}
			my %searchHash;
			my $sth = &queryAudit($dbh, $schema, 'internal', $scheduleOptions, $years, $intIssuedBy);
			while (my ($id, $auditSeq, $auditType, $issuedToId, $team, $scope, $notes, $rev, $year, 
			$issuedById, $audittitle, $procedures, $auditresults) = $sth->fetchrow_array) {
				if (defined($NQScgi->param('dointernalauditnotes'))) {
					$searchHash{'Notes'} = $notes;
				}
				if (defined($NQScgi->param('dointernalauditscope'))) {
					$searchHash{'Scope'} = $scope;
				}      				
				if (defined($NQScgi->param('dointernalauditteam'))) {
					$searchHash{'Team Members'} = $team;
				}
				if (defined($NQScgi->param('dointernaltitle'))) {
					$searchHash{'Title'} = $audittitle;
				}
				if (defined($NQScgi->param('dointernalprocedures'))) {
					$searchHash{'Procedures'} = $procedures;
				}
				if (defined($NQScgi->param('dointernalresults'))) {
					$searchHash{'Results'} = $auditresults;
				}
				while (($title, $searchText) = each(%searchHash)) {
					if (&matchFound(text => $searchText, searchString => $auditSearchString)) {
						$rows++;
						$results .= &add_row();
						$queryYear = substr($year, 2, 2);
						$formattedId = &getInternalAuditId($dbh, $issuedById, $issuedToId, $auditType, $year, $auditSeq);
						$prompt = "Click here for full information on audit $formattedId";
						$formattedId =~ /\-(\w+)\-/;
						$results .= &add_col() . "<center><a href=\"javascript:submitAuditView('internal', '$queryYear', '$1', $id);\" title='$prompt'>$formattedId</a></center></b>";
						$results .= &add_col() . "<center>$title</center></b>";
						$text = &highlightResults(text => $searchText, searchString => $auditSearchString);
						$results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
					}
				}
			}
			$results .= &end_table() . "</center>\n";
			if ($rows > 0) {
				$results =~ s/<x>/$rows/;
				$results =~ s/Matches/Match/ if ($rows == 1);
				print $results;
			}
			else {
				$message = "No internal audit matches found for \"$auditSearchString\"\\n";
				$message =~ s/'/%27/g;
			}
		}
		if (defined($NQScgi->param('doexternalaudit'))) {
			$rows = 0;
			$results = "";
			$results .= &start_table(3, 'center', 150, 80, 520);
			$results .= &title_row('lightsteelblue', 'black', '<center><font size=3>External Audits</font></center>');
			$results .= &title_row('lightsteelblue', 'black', '<font size=3>Search Results: Found <x> Matches</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to view individual results</font></i>)');
			$results .= &add_header_row();
			$results .= "<td bgcolor=aliceblue><center><b><font color=black>Audit Number</font></b></center></td>\n";
			$results .= "<td bgcolor=aliceblue><center><b><font color=black>Field Name</font></b></center></td>\n";
			$results .= "<td bgcolor=aliceblue><b><font color=black>Text</font></b></td>\n";
			$auditType = "internal";
			if ($NQScgi->param('auditqueryyear') eq "(all)") {
				$years = &getFiscalYears($dbh, $schema);
			}
			else {
				$years = "(" . substr($NQScgi->param('auditqueryyear'), 2) . ")";
			}
			my %searchHash;

			my $sth = &queryAudit($dbh, $schema, 'external', $scheduleOptions, $years, $extIssuedBy);
			while (my ($id, $auditSeq, $auditType, $issuedToId, $team, $scope, $notes, $rev, $year, $issuedById, 
			$audittitle, $procedures, $auditresults, $product) = $sth->fetchrow_array) {
				if (defined($NQScgi->param('doexternalauditnotes'))) {
					$searchHash{'Notes'} = defined($notes) ? $notes : "";
				}
				if (defined($NQScgi->param('doexternalauditscope'))) {
					$searchHash{'Scope'} = defined($scope) ? $scope : "";
				}      				
				if (defined($NQScgi->param('doexternalauditteam'))) {
					$searchHash{'Team Members'} = defined($team) ? $team : "";
				}
				if (defined($NQScgi->param('doexternalauditproduct'))) {
					$searchHash{'Product'} = defined($product) ? $product : "";
				}
				if (defined($NQScgi->param('dointernaltitle'))) {
					$searchHash{'Title'} = $audittitle;
				}
				if (defined($NQScgi->param('dointernalprocedures'))) {
					$searchHash{'Procedures'} = $procedures;
				}
				if (defined($NQScgi->param('dointernalresults'))) {
					$searchHash{'Results'} = $auditresults;
				}
				while (($title, $searchText) = each(%searchHash)) {
					if (&matchFound(text => $searchText, searchString => $auditSearchString)) {
						$rows++;
						$results .= &add_row();
						$queryYear = substr($year, 2, 2);
						$formattedId = &getExternalAuditId($dbh, $issuedById, $issuedToId, $auditType, $year, $auditSeq);
						$prompt = "Click here for full information on audit $formattedId";
						$formattedId =~ /\-(\w+)\-/;
						$results .= &add_col() . "<center><a href=\"javascript:submitAuditView('external', '$queryYear', '$1', $id);\" title='$prompt'>$formattedId</a></center>";
						$results .= &add_col() . "<center><b>$title</b></center>";
						$text = &highlightResults(text => $searchText, searchString => $auditSearchString);
						$results .= &add_col() . &getDisplayString($text, &getStringDisplayLength(str => $text));
					}
				}
			}
			$results .= &end_table() . "</center>\n";
			if ($rows > 0) {
				$results =~ s/<x>/$rows/;
				$results =~ s/Matches/Match/ if ($rows == 1);
				print $results;
			} 
			else {
				$message .= "No external audit matches found for \"$auditSearchString\"";
				$message =~ s/'/%27/g;
			}
		}
		if ($message ne "") {
			print "<script language=javascript>\n<!--\nvar mytext ='$message';\nalert(unescape(mytext));\n// $form.submit();\n//-->\n</script>\n";
		}
	};
	if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid," $username Error searching for audits. $@");
	}
}

print <<END_of_Multiline_Text;
Content-type: text/html

<html>
<head>
<script src=$NQSJavaScriptPath/utilities.js></script>
<Title>Data Deficiency Tracking</Title>

<!-- include external javascript code -->
<script src="$NQSJavaScriptPath/utilities.js"></script>

<script type="text/javascript">
<!--
		var dosubmit = true;
    	if (parent == self) {    // not in frames
			location = '$NQSCGIDir/login.pl'
    	}
    	function submitForm(script, cgiaction, noresults) {
    		var msg;
    		var error = "";
			if ($form.auditsearchstring.value == "" && ($form.dointernalaudit.checked == true || $form.doexternalaudit.checked == true)) {
				error += "\\t- No audit search string has been entered\\n";
		   }
		   if ($form.dointernalaudit.checked == false && $form.doexternalaudit.checked == false && $form.audit.checked == true) {
				error += "\\t- No audit search option has been selected\\n";
		   }
		   if ($form.dointernalaudit.checked == true && $form.dointernalauditnotes.checked == false &&
		   	$form.dointernalauditscope.checked == false && $form.dointernalauditteam.checked == false &&
		   	$form.dointernaltitle.checked == false && $form.dointernalprocedures.checked == false &&
		   	$form.dointernalresults.checked == false) {
		   	error += "\\t- No internal audit searchable fields have been selected\\n";
		   }		   
		   if ($form.doexternalaudit.checked == true && $form.doexternalauditnotes.checked == false &&
		   	$form.doexternalauditscope.checked == false && $form.doexternalauditproduct.checked == false &&
		   	$form.doexternalauditteam.checked == false && $form.doexternaltitle.checked == false &&
		   	$form.doexternalprocedures.checked == false && $form.doexternalresults.checked == false) {
		   	error += "\\t- No external audit searchable fields have been selected\\n";
		   }
		   if ($form.survsearchstring.value == "" && ($form.dosurveillance.checked == true || $form.dosurveillancerequest.checked == true)) {
				error += "\\t- No surveillance search string has been entered\\n";
			}
			if ($form.dosurveillance.checked == false && $form.dosurveillancerequest.checked == false && $form.surv.checked == true) {
				error += "\\t- No surveillance search option has been selected\\n";
			}	   
			if ($form.dosurveillance.checked == true && 
				$form.dosurveillancescope.checked == false && $form.dosurveillanceelements.checked == false &&
				$form.dosurveillanceteam.checked == false && $form.dosurveillancestatus.checked == false &&
				$form.dosurveillancetitle.checked == false && $form.dosurveillanceprocedures.checked == false &&
				$form.dosurveillanceresults.checked == false) {
				error += "\\t- No surveillance searchable fields have been selected\\n";
			}
			if ($form.dosurveillancerequest.checked == true && $form.dosurveillancerequestreason.checked == false &&
				$form.dosurveillancerequestrequestor.checked == false && $form.dosurveillancerequestsubjectline.checked == false &&
				$form.dosurveillancerequestsubjectdetail.checked == false) {
				error += "\\t- No surveillance request searchable fields have been selected\\n";
		   }	
//		   $form.target = 'control';
		   if (error) {
		   	msg = "The form could not be submitted due to the following error(s):\\n";
		   	msg += error;
		   	alert(msg);
		   	return false;
		   }
		   else {
		      $form.action = '$path' + script + '.pl';
		      $form.cgiaction.value = cgiaction;
		      $form.option.value='dosearch'; 
		      $form.submit();
		      return true;
		   }
      }
      function auditOption(option) {
      	if (option == 'true') {
      		document.all.audit_options.style.visibility = "visible";
      	}
      	else {
      		document.all.audit_options.style.visibility = "hidden";
      	}
      }
      function submitFormInitial(script, cgiaction) {
      	$form.action = '$path' + script + '.pl';
			$form.cgiaction.value = cgiaction;
		   $form.submit();
		}
		function submitAuditView(table,fy,type,num) {   
			document.$form.fy.value = fy;
			document.$form.sched.value = num;
			document.$form.id_type.value = type;
			document.$form.table.value = table;
			document.$form.cgiaction.value = 'view_audit';
			$form.action = '$path' + 'audit.pl';
			$form.submit();
		}
		function submitSurvView(id, fy) {   
			document.$form.fy.value = fy;
			document.$form.id.value = id;
			$form.action = '$path' + 'surveillance.pl';
			document.$form.cgiaction.value = 'view_surveillance';
			$form.submit();
		}
		function submitSurvRequestView(id, fy, survid, requestid) {
			document.$form.surveillanceid_display.value = survid;
			document.$form.requestid_display.value = requestid;
			document.$form.fy.value = fy;
			document.$form.id.value = id;
			$form.action = '$path' + 'request.pl';
			document.$form.cgiaction.value = 'active_request';
			$form.submit();
		}
		function surveillance2() {
			if (document.$form.dosurveillance.checked == false) {
				document.$form.dosurveillancenotes.checked = false;
				document.$form.dosurveillancescope.checked = false;
				document.$form.dosurveillanceelements.checked = false;
				document.$form.dosurveillanceteam.checked = false;
				document.$form.dosurveillancecontact.checked = false;
				document.$form.dosurveillancestatus.checked = false;
				document.all.tdsurveillanceelements.style.visibility = "hidden";
				document.all.tdsurveillanceteam.style.visibility = "hidden";
				document.all.tdsurveillancecontact.style.visibility = "hidden";
				document.all.tdsurveillancestatus.style.visibility = "hidden";
				document.all.tdsurvissuedby.style.visibility = "hidden";
				document.all.tdsurvtype.style.visibility = "hidden";
				if (document.$form.dosurveillancerequest.checked == false) {
					document.all.tdsurveillanceelements.style.display = "none";
					document.all.tdsurveillanceteam.style.display = "none";
					document.all.tdsurveillancecontact.style.display = "none";
					document.all.tdsurveillancestatus.style.display = "none";
					document.all.tdsurvissuedby.style.display = "none";
					document.all.tdsurvtype.style.display = "none";
					document.all.td
				}
				else {
					document.all.tdsurveillancenotes.style.visibility = "hidden";
					document.all.tdsurveillancescope.style.visibility = "hidden";
				}
			}
			else {
				document.all.tdsurveillancenotes.style.display = "block";
				document.all.tdsurveillancescope.style.display = "block";
				document.all.tdsurveillanceelements.style.display = "block";
				document.all.tdsurveillanceteam.style.display = "block";
				document.all.tdsurveillancecontact.style.display = "block";
				document.all.tdsurveillancestatus.style.display = "block";
				document.all.tdsurvissuedby.style.display = "block";
				document.all.tdsurvissuedbylabel.style.display = "block";
				document.all.tdsurveillancenotes.style.visibility = "visible";
				document.all.tdsurveillancescope.style.visibility = "visible";
				document.all.tdsurveillanceelements.style.visibility = "visible";
				document.all.tdsurveillanceteam.style.visibility = "visible";
				document.all.tdsurveillancecontact.style.visibility = "visible";
				document.all.tdsurveillancestatus.style.visibility = "visible";
				document.all.tdsurvissuedby.style.visibility = "visible";
			}
      }
		function surveillance() {
			if (document.$form.dosurveillance.checked == false) {
//				document.$form.dosurveillancenotes.checked = false;
				document.$form.dosurveillancescope.checked = false;
				document.$form.dosurveillanceelements.checked = false;
				document.$form.dosurveillanceteam.checked = false;
//				document.$form.dosurveillancecontact.checked = false;
				document.$form.dosurveillancestatus.checked = false;
				document.$form.dosurveillancetitle.checked = false;
				document.$form.dosurveillanceprocedures.checked = false;
				document.$form.dosurveillanceresults.checked = false;
//				document.all.tdsurveillance.style.visibility = "hidden";
//				document.all.tdsurveillancenotes.style.visibility = "hidden";
				document.all.tdsurveillancescope.style.visibility = "hidden";
				document.all.tdsurveillanceelements.style.visibility = "hidden";
				document.all.tdsurveillanceteam.style.visibility = "hidden";
//				document.all.tdsurveillancecontact.style.visibility = "hidden";
				document.all.tdsurveillancestatus.style.visibility = "hidden";
				document.all.tdsurveillancetitle.style.visibility = "hidden";
				document.all.tdsurveillanceprocedures.style.visibility = "hidden";
				document.all.tdsurveillanceresults.style.visibility = "hidden";
				document.all.tdsurvissuedby.style.visibility = "hidden";
				document.all.tdsurvtype.style.visibility = "hidden";
				document.all.tdsurvtypelabel.style.visibility = "hidden";
				if (document.$form.dosurveillancerequest.checked == false) {
					document.all.tdsurvissuedbylabel.style.visibility = "hidden";
				}
			}
			else {
//				document.all.tdsurveillance.style.visibility = "visible";
//				document.all.tdsurveillancenotes.style.visibility = "visible";
				document.all.tdsurveillancescope.style.visibility = "visible";
				document.all.tdsurveillanceelements.style.visibility = "visible";
				document.all.tdsurveillanceteam.style.visibility = "visible";
//				document.all.tdsurveillancecontact.style.visibility = "visible";
				document.all.tdsurveillancestatus.style.visibility = "visible";
				document.all.tdsurveillancetitle.style.visibility = "visible";
				document.all.tdsurveillanceprocedures.style.visibility = "visible";
				document.all.tdsurveillanceresults.style.visibility = "visible";
				document.all.tdsurvissuedby.style.visibility = "visible";
				document.all.tdsurvtype.style.visibility = "visible";
				document.all.tdsurvissuedbylabel.style.visibility = "visible";
				document.all.tdsurvtypelabel.style.visibility = "visible";
			}
		}
		
		function surveillanceRequest2() {
			if (document.$form.dosurveillancerequest.checked == false) {
				document.$form.dosurveillancerequestrequestor.checked = false;
				document.$form.dosurveillancerequestsubjectline.checked = false;
				document.$form.dosurveillancerequestsubjectdetail.checked = false;
				document.$form.dosurveillancerequestrationale.checked = false;
				document.$form.dosurveillancerequestreason.checked = false;
				document.all.tdsurveillancerequestsubjectline.style.visibility = "hidden";
				document.all.tdsurveillancerequestsubjectdetail.style.visibility = "hidden";
				document.all.tdsurveillancerequestrationale.style.visibility = "hidden";
				document.all.tdreqissuedby.style.visibility = "hidden";
				if (document.$form.dosurveillance.checked == false) {
					document.all.tdsurvissuedbylabel.style.display = "none";
					document.all.tdsurveillancerequestsubjectline.style.display = "none";
					document.all.tdsurveillancerequestsubjectdetail.style.display = "none";
					document.all.tdsurveillancerequestrationale.style.display = "none";
					document.all.tdsurveillancerequestreason.style.display = "none";
					document.all.tdsurveillancerequestrequestor.style.display = "none";
					document.all.tdreqissuedby.style.display = "none";
				}
				else {
					document.all.tdsurveillancerequestreason.style.visibility = "hidden";
					document.all.tdsurveillancerequestrequestor.style.visibility = "hidden";
			   }
			}
			else {
				document.all.tdsurveillancerequestsubjectline.style.display = "block";
				document.all.tdsurveillancerequestsubjectdetail.style.display = "block";
				document.all.tdsurveillancerequestrationale.style.display = "block";
				document.all.tdsurveillancerequestreason.style.display = "block";
				document.all.tdsurveillancerequestrequestor.style.display = "block";
				document.all.tdreqissuedby.style.display = "block";
				document.all.tdsurvissuedbylabel.display = "block";
				document.all.tdsurveillancerequestsubjectline.style.visibility = "visible";
				document.all.tdsurveillancerequestsubjectdetail.style.visibility = "visible";
				document.all.tdsurveillancerequestrationale.style.visibility = "visible";
				document.all.tdsurveillancerequestreason.style.visibility = "visible";
				document.all.tdsurveillancerequestrequestor.style.visibility = "visible";
				document.all.tdreqissuedby.style.visibility = "visible";
				document.all.tdsurvissuedbylabel.style.visibility = "visible";
			}
		}

		function surveillanceRequest() {
			if (document.$form.dosurveillancerequest.checked == false) {
				document.$form.dosurveillancerequestrequestor.checked = false;
				document.$form.dosurveillancerequestsubjectline.checked = false;
				document.$form.dosurveillancerequestsubjectdetail.checked = false;
//				document.$form.dosurveillancerequestrationale.checked = false;
				document.$form.dosurveillancerequestreason.checked = false;
				document.all.tdsurveillancerequestsubjectline.style.visibility = "hidden";
				document.all.tdsurveillancerequestsubjectdetail.style.visibility = "hidden";
//				document.all.tdsurveillancerequestrationale.style.visibility = "hidden";
				document.all.tdsurveillancerequestreason.style.visibility = "hidden";
				document.all.tdsurveillancerequestrequestor.style.visibility = "hidden";
				document.all.tdreqissuedby.style.visibility = "hidden";
				if (document.$form.dosurveillance.checked == false) {
					document.all.tdsurvissuedbylabel.style.visibility = "hidden";
				}
			}
			else {
				document.all.tdsurveillancerequestsubjectline.style.visibility = "visible";
				document.all.tdsurveillancerequestsubjectdetail.style.visibility = "visible";
//				document.all.tdsurveillancerequestrationale.style.visibility = "visible";
				document.all.tdsurveillancerequestreason.style.visibility = "visible";
				document.all.tdsurveillancerequestrequestor.style.visibility = "visible";
				document.all.tdreqissuedby.style.visibility = "visible";
				document.all.tdsurvissuedbylabel.style.visibility = "visible";
			}
		}
		
		function internalAudit() {
			showTable();
			if (document.$form.dointernalaudit.checked == false) {
				document.$form.dointernalauditnotes.checked = false;
				document.$form.dointernalauditscope.checked = false;
				document.$form.dointernalauditteam.checked = false;
				document.$form.dointernaltitle.checked = false;
				document.$form.dointernalprocedures.checked = false;
				document.$form.dointernalresults.checked = false;
//				document.all.tdinternal.style.visibility = "hidden";
				document.all.tdinternalauditnotes.style.visibility = "hidden";
//				document.all.tdinternalauditscope.style.visibility = "hidden";
				document.all.tdinternalauditteam.style.visibility = "hidden";
				document.all.tdinternaltitle.style.visibility = "hidden";
				document.all.tdinternalresults.style.visibility = "hidden";
				document.all.tdintissuedby.style.visibility = "hidden";
				if (document.$form.doexternalaudit.checked == false) {
					document.all.tdissuedbylabel.style.visibility = "hidden";
				}
			}
			else {
//				document.all.tdinternal.style.visibility = "visible";
				document.all.tdinternalauditnotes.style.visibility = "visible";
//				document.all.tdinternalauditscope.style.visibility = "visible";
				document.all.tdinternalauditteam.style.visibility = "visible";
				document.all.tdissuedbylabel.style.visibility = "visible";
				document.all.tdintissuedby.style.visibility = "visible";
				document.all.tdinternaltitle.style.visibility = "visible";
				document.all.tdinternalresults.style.visibility = "visible";
			}
		}
		function externalAudit() {
			if (document.$form.doexternalaudit.checked == false) {
				document.$form.doexternalauditnotes.checked = false;
				document.$form.doexternalauditscope.checked = false;
				document.$form.doexternalauditteam.checked = false;
				document.$form.doexternalauditproduct.checked = false;
				document.$form.doexternaltitle.checked = false;
				document.$form.doexternalprocedures.checked = false;
				document.$form.doexternalresults.checked = false;
//				document.all.tdexternal.style.visibility = "hidden";
				document.all.tdexternalauditnotes.style.visibility = "hidden";
//				document.all.tdexternalauditscope.style.visibility = "hidden";
				document.all.tdexternalauditteam.style.visibility = "hidden";
//				document.all.tdexternalauditproduct.style.visibility = "hidden";
				document.all.tdexternaltitle.style.visibility = "hidden";
				document.all.tdexternalresults.style.visibility = "hidden";
				document.all.tdextissuedby.style.visibility = "hidden";
				if (document.$form.dointernalaudit.checked == false) {
					document.all.tdissuedbylabel.style.visibility = "hidden";
				}
			}
			else {
//				document.all.tdexternal.style.visibility = "visible";
				document.all.tdexternalauditnotes.style.visibility = "visible";
//				document.all.tdexternalauditscope.style.visibility = "visible";
				document.all.tdexternalauditteam.style.visibility = "visible";
//				document.all.tdexternalauditproduct.style.visibility = "visible";
				document.all.tdextissuedby.style.visibility = "visible";
				document.all.tdissuedbylabel.style.visibility = "visible";
				document.all.tdexternaltitle.style.visibility = "visible";
				document.all.tdexternalresults.style.visibility = "visible";
			}
		}
		function showTable() {
			if (document.$form.audit.checked == true) {
				document.all.audittable.style.display = 'block';
				document.all.$form.submitbutton.style.visibility  = 'visible';
			}
			else {
				document.all.audittable.style.display = 'none';
			}
			if (document.$form.surv.checked == true) {
				document.all.survtable.style.display = 'block';
				document.all.$form.submitbutton.style.visibility  = 'visible';
			}
			else {
				document.all.survtable.style.display = 'none';
			}
			if (document.$form.audit.checked == false && document.$form.surv.checked == false) {
				document.all.$form.submitbutton.style.visibility  = 'hidden';
			}
		}
		
		
		function KeyEvent(script, cgiaction) {
			if (event.keyCode == 13 && cgiaction == 'audit_search') {
				if (submitForm(script, cgiaction)) {
				   event.returnValue = true;
				}
			   else {
				 	event.returnValue = false;
			 	}
			}
			else if (event.keyCode == 13 && cgiaction == 'surveillance_search') {
				if (submitForm(script, cgiaction)) {
					event.returnValue = true;
				 }
				 else {
				 	event.returnValue = false;
				 }
			}
		} 
	//-->
</script>
</head>
<body background=$NQSImagePath/background.gif text="#000099">
<form method=post name=$form >
<input name=username type=hidden value="$username">
<input name=userid type=hidden value="$userid">
<input name=schema type=hidden value="$schema">
<input name=cgiaction type=hidden value=''>
<input name=option type=hidden value=''>
<input name=fy type=hidden value=''>
<input name=id_type type=hidden value=''>
<input name=id type=hidden value=''>
<input name=sched type=hidden value=''>
<input name=table type=hidden value=''>
<input name=requestid_display type=hidden value=''>
<input name=surveillanceid_display type=hidden value=''>
<script language=javascript type=text/javascript><!--
	doSetTextImageLabel('Search');\n//-->
</script>
END_of_Multiline_Text

if ($cgiaction eq "undefined" || $cgiaction eq "" || $cgiaction eq "display") {
#	print "param=" . $NQScgi->param('audit') . "\n";
	print "<center>\n";
	print "<br>\n";
	print "<table border=0 align=center>\n";
	$checked = defined($NQScgi->param('audit')) ? "checked" : "";
	print "<tr>\n<td><input type=checkbox name=audit onClick=\"showTable()\" $checked>&nbsp;<b>Search <font color=black>Internal and External Audits</font></b></td>\n</tr>\n";
	$checked = defined($NQScgi->param('surv')) ? "checked" : "";
	#print "<tr>\n<td><input type=checkbox name=surv onClick=\"showTable()\" $checked>&nbsp;<b>Search <font color=black>Surveillance and Surveillance Requests</font></b></td>\n</tr>\n";
	print "<tr>\n<td><input type=checkbox name=surv onClick=\"showTable()\" $checked>&nbsp;<b>Search <font color=black>Surveillance</font></b></td>\n</tr>\n";
	print "</table>\n";
	print "<center>\n";
	print "<br>\n";
	print "<ul>\n";
	my $display = defined($NQScgi->param('audit')) ? "style=display:block" : "style=display:none";
	print "<table id=audittable width=\"700\" cellpadding=0 cellspacing=7 border=0 $display>\n";
	print "<tr bgcolor=#B0C4DE>\n<td colspan=5 align=center><b>Internal and External Audits</b></td>\n</tr>\n";
	print "<tr>\n";
	print "<td colspan=6 ><b>Search for:&nbsp;&nbsp;&nbsp;</b><input type=text name=auditsearchstring value=\"$auditSearchString\" maxlength=100 size=80 onKeypress=\"KeyEvent('search', 'audit_search');\">&nbsp;&nbsp;&nbsp;\n";
	$auditSearchString =~ s/'/%27/g;
	print "</td>\n";
	print "</tr>\n";
	print "<tr>\n";
	print "<td><b><li>Show:</li></b></td>\n";
	my $textOption = (defined($NQScgi->param('textoption'))) ? $NQScgi->param('textoption') : "";
	$checked = ($textOption eq "" || $textOption eq "full") ? "checked" : ""; 
	print "<td colspan=5><input type=radio name=audittextoption value=full $checked>&nbsp;<b>full text</b>&nbsp;&nbsp;&nbsp;\n";
	$checked = ($textOption eq "truncate") ? "checked" : ""; 
	print "<input type=radio name=audittextoption value=truncate $checked>&nbsp;<b>first 250 characters of each result</b></td>\n";
	print "</tr>\n";
#	print "<tr>\n";
#	print "<td><b><li>Options:</li></b></td>\n";
#	$checked = defined($NQScgi->param('case')) ? "checked" : "";
#	print "<td><input type=checkbox name=case value=case $checked>&nbsp;<b>case sensitive search</b></td>\n";
#	print "</tr>\n";
#	print "<tr>\n";
#	print "<td><b><li>Schedule Type:</li></b></td>\n";
#	$checked = defined($NQScgi->param('doworkingcopy')) ? "checked" : "";
#	print "<td><input type=checkbox name=doworkingcopy value=working_copy $checked>&nbsp;<b>current working</b>" . &nbspaces(3) . "\n";
#	$checked = defined($NQScgi->param('doapprovedcopy')) ? "checked" : "";
#	print "<input type=checkbox name=doapprovedcopy value=approved_copy $checked>&nbsp;<b>latest approved</b></td>\n";
#	print "</tr>\n";
	print "<tr>\n";
	print "<td width=19%><b><li>Fiscal Year:</li></b>&nbsp;&nbsp;&nbsp;</td>\n";
	print "<td colspan=5><select name=auditqueryyear>\n";
	print "<option>(all)</option>\n";
	my $sth = $dbh->prepare ("SELECT fiscal_year FROM $schema.fiscal_year ORDER BY fiscal_year DESC");
	$sth->execute;
	while (my $year = $sth->fetchrow_array) {
		if ($year eq $NQScgi->param('survqueryyear')) {
			print "<option selected>$year</option>\n";
		}
		else {
			print "<option>$year</option>\n";
		}
	}
	print "</select>\n";
	print "</td>\n";
	print "</tr>\n";
	print "<tr>\n";
	print "<td><b><li>Search:</li></b></td>\n";
	$checked = defined($NQScgi->param('dointernalaudit')) ? "checked" : "";
	print "<td width=23%><input type=checkbox name=dointernalaudit value=internal_audit onClick=\"internalAudit();\" $checked><b>internal audit</b></td>\n";
	$checked = defined($NQScgi->param('doexternalaudit')) ? "checked" : "";
	print "<td><input type=checkbox name=doexternalaudit value=external_audit onClick=\"externalAudit();\" $checked><b>external audit</b></td>\n";
	print "</tr>\n";	
	$visibleExternal = defined($NQScgi->param('doexternalaudit')) ? "visible" : "hidden";
	$visibleInternal = defined($NQScgi->param('dointernalaudit')) ? "visible" : "hidden";
#	$visibleExternal = "visible";
#	$visibleInternal = "visible";	
#	print "<td id=tdinternal style=visibility:$visibleInternal><b>Internal audit searchable fields</b></td>\n";
#	print "<td id=tdexternal style=visibility:$visibleExternal><b>External audit searchable fields</b></td>\n";
#	print "</tr>\n";
	print "<tr>\n";
	print "<td id=tdissuedbylabel style=visibility:$visibleInternal><li><b>Issued By:</b></li></td>\n";
#	print "</tr>\n";
#	print "<tr>\n";
	$checked = (!(defined($NQScgi->param('int_issued_by'))) || $intIssuedBy eq "ALL") ? "checked" : "";
	print "<td id=tdintissuedby style=visibility:$visibleInternal width=30%><input type=radio name=int_issued_by value=ALL $checked><b>ALL</b>\n";
	$checked = (defined($NQScgi->param('int_issued_by')) && $intIssuedBy eq "BSC") ? "checked" : "";
	print "&nbsp;<input type=radio name=int_issued_by value=BSC $checked><b>BSC</b>\n";
	$checked = (defined($NQScgi->param('int_issued_by')) && $intIssuedBy eq "OQA") ? "checked" : "";
	print "&nbsp;<input type=radio name=int_issued_by value=OQA $checked><b>OQA</b></td>\n";
	
#	print "</tr>\n";
#	print "<tr>\n";
	$checked = (!(defined($NQScgi->param('ext_issued_by'))) || $extIssuedBy eq "ALL") ? "checked" : "";
	print "<td id=tdextissuedby style=visibility:$visibleExternal width=30%><input type=radio name=ext_issued_by value=ALL $checked><b>ALL</b>\n";
	$checked = (defined($NQScgi->param('ext_issued_by')) && $extIssuedBy eq "BSC") ? "checked" : "";
	print "&nbsp;<input type=radio name=ext_issued_by value=BSC $checked><b>BSC</b>\n";
	$checked = (defined($NQScgi->param('ext_issued_by')) && $extIssuedBy eq "OQA") ? "checked" : "";
	print "&nbsp;<input type=radio name=ext_issued_by value=OQA $checked><b>OQA</b></td>\n";

#	print "<td rowspan=3>&nbsp;</td>\n";
	print "</tr>\n";
	print "<tr>\n";
	print "<td>&nbsp;</td>\n";
	$checked = defined($NQScgi->param('dointernalauditnotes')) ? "checked" : "";
	print "<td id=tdinternalauditnotes style='visibility:$visibleInternal' nowrap><input type=checkbox name=dointernalauditnotes value=internal_audit_notes $checked><b>Notes</b>\n";
	$checked = defined($NQScgi->param('dointernalauditscope')) ? "checked" : "";
	print "&nbsp;&nbsp;<input type=checkbox name=dointernalauditscope value=internal_audit_scope $checked><b>Scope</b>\n";
#	print "<td>&nbsp;</td>\n";	
	$checked = defined($NQScgi->param('doexternalauditnotes')) ? "checked" : "";
	print "<td id=tdexternalauditnotes style=visibility:$visibleExternal width=14%><input type=checkbox name=doexternalauditnotes value=external_audit_notes $checked><b>Notes</b>\n";
	$checked = defined($NQScgi->param('doexternalauditscope')) ? "checked" : "";
	print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=checkbox name=doexternalauditscope value=external_audit_scope $checked><b>Scope</b></td>\n";
	print "</tr>\n";
	print "<tr>\n";
	print "<td>&nbsp;</td>\n";
	$checked = defined($NQScgi->param('dointernalauditteam')) ? "checked" : "";
	print "<td id=tdinternalauditteam style=visibility:$visibleInternal><input type=checkbox name=dointernalauditteam value=internal_audit_team $checked><b>Team&nbsp;members</b></td>\n";
#	print "<td>&nbsp;</td>\n";
#	print "<td>&nbsp;</td>\n";	
	$checked = defined($NQScgi->param('doexternalauditteam')) ? "checked" : "";
	print "<td id=tdexternalauditteam style=visibility:$visibleExternal><input type=checkbox name=doexternalauditteam value=external_audit_team $checked><b>Team&nbsp;members</b>\n";
	$checked = defined($NQScgi->param('doexternalauditproduct')) ? "checked" : "";
	print "&nbsp;&nbsp;<input type=checkbox name=doexternalauditproduct value=external_audit_product $checked><b>Product</b></td>\n";
	print "</tr>\n";


	print "<tr>\n";
	print "<td>&nbsp;</td>\n";
	$checked = defined($NQScgi->param('dointernaltitle')) ? "checked" : "";
	print "<td id=tdinternaltitle style=visibility:$visibleInternal><input type=checkbox name=dointernaltitle value=internal_title $checked><b>Title</b>\n";
	$checked = defined($NQScgi->param('dointernalprocedures')) ? "checked" : "";
	#print "&nbsp;&nbsp;<input type=checkbox name=dointernalprocedures value=internal_procedures $checked><b>Procedures</b></td>\n";
	print "&nbsp;&nbsp;<input type=hidden name=dointernalprocedures value=internal_procedures $checked><!--b>Procedures</b--></td>\n";
#	print "<td>&nbsp;</td>\n";
#	print "<td>&nbsp;</td>\n";	
	$checked = defined($NQScgi->param('doexternaltitle')) ? "checked" : "";
	print "<td id=tdexternaltitle style=visibility:$visibleExternal><input type=checkbox name=doexternaltitle value=external_title $checked><b>Title</b>\n";
	$checked = defined($NQScgi->param('doexternalprocedures')) ? "checked" : "";
	#print "&nbsp;&nbsp;<input type=checkbox name=doexternalprocedures value=external_procedures $checked><b>Procedures</b></td>\n";
	print "&nbsp;&nbsp;<input type=hidden name=doexternalprocedures value=external_procedures $checked><!--b>Procedures</b--></td>\n";
	print "</tr>\n";
	print "<tr>\n";
	print "<td>&nbsp;</td>\n";
	$checked = defined($NQScgi->param('dointernalresults')) ? "checked" : "";
	#print "<td id=tdinternalresults style=visibility:$visibleInternal><input type=checkbox name=dointernalresults value=internal_results $checked><b>Overall&nbsp;results</b></td>\n";
	print "<td id=tdinternalresults style=visibility:$visibleInternal><input type=hidden name=dointernalresults value=internal_results $checked><!--b>Overall&nbsp;results</b--></td>\n";
#	print "<td>&nbsp;</td>\n";
#	print "<td>&nbsp;</td>\n";	
	$checked = defined($NQScgi->param('doexternalresults')) ? "checked" : "";
	#print "<td id=tdexternalresults style=visibility:$visibleExternal><input type=checkbox name=doexternalresults value=external_results $checked><b>Overall&nbsp;results</b></td>\n";
	print "<td id=tdexternalresults style=visibility:$visibleExternal><input type=hidden name=doexternalresults value=external_results $checked><!--b>Overall&nbsp;results</b--></td>\n";
	print "</tr>\n";


	print "</table>\n";
	print "</ul>\n";
	print "<ul>\n";
	$display = defined($NQScgi->param('surv')) ? "style=display:block" : "style=display:none";
	print "<table id=survtable width=\"700\" cellpadding=0 cellspacing=7 border=0 $display>\n";
	#print "<tr bgcolor=#B0C4DE>\n<td colspan=5 align=center><b>Surveillance and Surveillance Requests</b></td>\n</tr>\n";
	print "<tr bgcolor=#B0C4DE>\n<td colspan=5 align=center><b>Surveillance</b></td>\n</tr>\n";
	print "<tr>\n";
	print "<td colspan=5><b>Search for:&nbsp;&nbsp;&nbsp;</b><input type=text name=survsearchstring value=\"$survSearchString\" maxlength=100 size=80 onKeypress=\"KeyEvent('search', 'surveillance_search');\">&nbsp;&nbsp;&nbsp;\n";
	$survSearchString =~ s/'/%27/g;
   print "</td>\n";
	print "</tr>\n";
	print "<tr>\n";
	print "<td><b><li>Show:</li></b></td>\n";
	$textOption = (defined($NQScgi->param('survtextoption'))) ? $NQScgi->param('survtextoption') : "";
	$checked = ($textOption eq "" || $textOption eq "full") ? "checked" : ""; 
	print "<td colspan=4><input type=radio name=survtextoption value=full $checked>&nbsp;<b>full text</b>&nbsp;&nbsp;&nbsp;\n";
	$checked = ($textOption eq "truncate") ? "checked" : ""; 
	print "<input type=radio name=survtextoption value=truncate $checked>&nbsp;<b>first 250 characters of each result</b></td>\n";
	print "</tr>\n";
#	print "<tr>\n";
#	print "<td><b><li>Options:</li></b></td>\n";
#	$checked = defined($NQScgi->param('case')) ? "checked" : "";
#	print "<td><input type=checkbox name=case value=case $checked>&nbsp;<b>case sensitive search</b></td>\n";
#	print "</tr>\n";
	print "<tr>\n";
	print "<td><b><li>Fiscal Year:</li></b>&nbsp;&nbsp;&nbsp;</td>\n";
	print "<td  colspan=4><select name=survqueryyear>\n";
	print "<option>(all)</option>\n";
	$sth = $dbh->prepare ("SELECT fiscal_year FROM $schema.fiscal_year ORDER BY fiscal_year DESC");
	$sth->execute;
	while (my $year = $sth->fetchrow_array) {
		if ($year eq $NQScgi->param('survqueryyear')) {
			print "<option selected>$year</option>\n";
		}
		else {
			print "<option>$year</option>\n";
		}
	}
	print "</select>\n";
	print "</td>\n";
	print "</tr>\n";
	print "<tr>\n";
	print "<td><b><li>Search:</li></b></td>\n";
	$checked = defined($NQScgi->param('dosurveillance')) ? "checked" : "";
	print "<td colspan=2><input type=checkbox name=dosurveillance value=surveillance onClick=\"surveillance();\" $checked><b>Surveillances</b></td>\n";
	$checked = defined($NQScgi->param('dosurveillancerequest')) ? "checked" : "";
	#print "<td colspan=2><input type=checkbox name=dosurveillancerequest value=surveillance_request onClick=\"surveillanceRequest();\" $checked><b>Surveillance Requests</b></td>\n";
	print "<td colspan=2><input style='display:none;'  type=checkbox name=dosurveillancerequest value=surveillance_request onClick=\"surveillanceRequest();\" $checked><!--b>Surveillance Requests</b--></td>\n";
	print "</tr>\n";
#	print "<tr><td>&nbsp;</td></tr>\n";
#	print "</table>\n";
#	print "</ul>\n";
#	print "<table width=\"550\" cellpadding=0 cellspacing=7 border=1>\n";
	print "<tr>\n";
	$visibleSurv = defined($NQScgi->param('dosurveillance')) ? "visible" : "hidden";
	$visibleSurvRequest = defined($NQScgi->param('dosurveillancerequest')) ? "visible" : "hidden";
	my $visibleIssuedByLabel = (defined($NQScgi->param('dosurveillancerequest')) || defined($NQScgi->param('dosurveillance'))) ? "visible" : "hidden";
	print "<td id=tdsurvissuedbylabel style=visibility:$visibleIssuedByLabel valign=top><li><b>Issued By:<b></li></td>\n";
	$checked = (!(defined($NQScgi->param('surv_issued_by'))) || $survIssuedBy eq "ALL") ? "checked" : "";
	print "<td id=tdsurvissuedby style=visibility:$visibleSurv colspan=2><input type=radio name=surv_issued_by value=ALL $checked><b>ALL</b>\n";
	$checked = (defined($NQScgi->param('surv_issued_by')) && $survIssuedBy eq "OQA") ? "checked" : "";
	print "&nbsp;&nbsp;&nbsp;<input type=radio name=surv_issued_by value=OQA $checked><b>OQA</b>\n";
	$checked = (defined($NQScgi->param('surv_issued_by')) && $survIssuedBy eq "BSC") ? "checked" : "";
	print "&nbsp;&nbsp;&nbsp;<input type=radio name=surv_issued_by value=BSC $checked><b>BSC</b></td>\n";
	$checked = (!(defined($NQScgi->param('surv_issued_by'))) || $survIssuedBy eq "ALL") ? "checked" : "";
	print "<td id=tdreqissuedby style=visibility:$visibleSurvRequest colspan=2><input type=radio name=req_issued_by value=ALL $checked><b>ALL</b>\n";
	$checked = (defined($NQScgi->param('req_issued_by')) && $reqIssuedBy eq "OQA") ? "checked" : "";
	print "&nbsp;&nbsp;&nbsp;<input type=radio name=req_issued_by value=OQA $checked><b>OQA</b>\n";
	$checked = (defined($NQScgi->param('req_issued_by')) && $reqIssuedBy eq "BSC") ? "checked" : "";
	print "&nbsp;&nbsp;&nbsp;<input type=radio name=req_issued_by value=BSC $checked><b>BSC</b></td>\n";
	print "</tr>\n";

	
###########	
	print "<tr>\n";
#	$visibleSurv = defined($NQScgi->param('dosurveillance')) ? "visible" : "hidden";
#	$visibleSurvRequest = defined($NQScgi->param('dosurveillancerequest')) ? "visible" : "hidden";
#	my $visibleIssuedByLabel = (defined($NQScgi->param('dosurveillancerequest')) || defined($NQScgi->param('dosurveillance'))) ? "visible" : "hidden";
	print "<td id=tdsurvtypelabel style=visibility:$visibleIssuedByLabel rowspan=5 valign=top><li><b>Type:<b></li></td>\n";
	$checked = (!(defined($NQScgi->param('surv_type'))) || $survType eq "ALL") ? "checked" : "";
	print "<td  id=tdsurvtype style=visibility:$visibleSurv colspan=2><input type=radio name=surv_type value=ALL $checked><b>ALL</b>\n";
	$checked = (defined($NQScgi->param('surv_type')) && $survType eq "I") ? "checked" : "";
	print "&nbsp;&nbsp;&nbsp;<input type=radio name=surv_type value=I $checked><b>Internal</b>\n";
	$checked = (defined($NQScgi->param('surv_type')) && $survType eq "E") ? "checked" : "";
	print "&nbsp;&nbsp;&nbsp;<input type=radio name=surv_type value=E $checked><b>External</b></td>\n";
	print "<td id=tdreqblank style=visibility:$visibleSurv colspan=2>&nbsp;</td>\n";
	print "</tr>\n";

####################	
	print "<tr>\n";
	$checked = defined($NQScgi->param('dosurveillancestatus')) ? "checked" : "";
	print "<td id=tdsurveillancestatus style=visibility:$visibleSurv><input type=checkbox name=dosurveillancestatus value=surveillance_status $checked><b>Status</b></td>\n";
#	$checked = defined($NQScgi->param('dosurveillancenotes')) ? "checked" : "";
#	print "<td id=tdsurveillancenotes style=visibility:$visibleSurv><input type=checkbox name=dosurveillancenotes value=surveillance_notes $checked><b>Notes</b></td>\n";
	$checked = defined($NQScgi->param('dosurveillancescope')) ? "checked" : "";
	print "<td id=tdsurveillancescope style=visibility:$visibleSurv><input type=checkbox name=dosurveillancescope value=surveillance_scope $checked><b>Scope</b></td>\n";
	$checked = defined($NQScgi->param('dosurveillancerequestreason')) ? "checked" : "";
	print "<td id=tdsurveillancerequestreason style=visibility:$visibleSurvRequest><input type=checkbox name=dosurveillancerequestreason value=surveillance_request_reason $checked><b>Reason for request</b></td>\n";
	$checked = defined($NQScgi->param('dosurveillancerequestrequestor')) ? "checked" : "";
	print "<td id=tdsurveillancerequestrequestor style=visibility:$visibleSurvRequest><input type=checkbox name=dosurveillancerequestrequestor value=surveillance_request_requestor $checked><b>Requestor</b></td>\n";
	print "</tr>\n";
	print "<tr>\n";
	$checked = defined($NQScgi->param('dosurveillanceteam')) ? "checked" : "";
	print "<td id=tdsurveillanceteam style=visibility:$visibleSurv><input type=checkbox name=dosurveillanceteam value=surveillance_team $checked><b>Team members</b></td>\n";
	$checked = defined($NQScgi->param('dosurveillanceelements')) ? "checked" : "";
	#print "<td id=tdsurveillanceelements style=visibility:$visibleSurv><input type=checkbox name=dosurveillanceelements value=surveillance_elements $checked><b>Elements</b></td>\n";
	print "<td id=tdsurveillanceelements style=visibility:$visibleSurv><input type=hidden name=dosurveillanceelements value=surveillance_elements $checked><!--b>Elements</b--></td>\n";
	$checked = defined($NQScgi->param('dosurveillancerequestsubjectline')) ? "checked" : "";
	print "<td id=tdsurveillancerequestsubjectline style=visibility:$visibleSurvRequest><input type=checkbox name=dosurveillancerequestsubjectline value=surveillance_request_subjectline $checked><b>Subject line</b></td>\n";
	$checked = defined($NQScgi->param('dosurveillancerequestsubjectdetail')) ? "checked" : "";
	print "<td id=tdsurveillancerequestsubjectdetail style=visibility:$visibleSurvRequest><input type=checkbox name=dosurveillancerequestsubjectdetail value=surveillance_request_subjectdetail $checked><b>Subject detail</b></td>\n";	
	print "</tr>\n";
	
	
	print "<tr>\n";
	$checked = defined($NQScgi->param('dosurveillancetitle')) ? "checked" : "";
	print "<td id=tdsurveillancetitle style=visibility:$visibleSurv><input type=checkbox name=dosurveillancetitle value=surveillance_title $checked><b>Title</b></td>\n";
	$checked = defined($NQScgi->param('dosurveillanceelements')) ? "checked" : "";
	#print "<td id=tdsurveillanceprocedures style=visibility:$visibleSurv><input type=checkbox name=dosurveillanceprocedures value=surveillance_procedures $checked><b>Procedures</b></td>\n";
	print "<td id=tdsurveillanceprocedures style=visibility:$visibleSurv><input type=hidden name=dosurveillanceprocedures value=surveillance_procedures $checked><!--b>Procedures</b--></td>\n";
	print "<td>&nbsp;</td><td>&nbsp;</td>\n";
	print "</tr>\n";
	print "<tr>\n";
	$checked = defined($NQScgi->param('dosurveillanceresults')) ? "checked" : "";
	#print "<td id=tdsurveillanceresults style=visibility:$visibleSurv colspan=2><input type=checkbox name=dosurveillanceresults value=surveillance_results $checked><b>Overall Results</b></td>\n";
	print "<td id=tdsurveillanceresults style=visibility:$visibleSurv colspan=2><input type=hidden name=dosurveillanceresults value=surveillance_results $checked><!--b>Overall Results</b--></td>\n";
	print "<td>&nbsp;</td><td>&nbsp;</td>\n";
	print "</tr>\n";
	
	print "<tr>\n";
#	$checked = defined($NQScgi->param('dosurveillancecontact')) ? "checked" : "";
#	print "<td id=tdsurveillancecontact style=visibility:$visibleSurv><input type=checkbox name=dosurveillancecontact value=surveillance_contact $checked><b>Initial contact</b>\n";
#	$checked = defined($NQScgi->param('dosurveillancerequestrationale')) ? "checked" : "";
#	print "<td id=tdsurveillancerequestrationale style=visibility:$visibleSurvRequest><input type=checkbox name=dosurveillancerequestrationale value=surveillance_request_rationale $checked><b>Disapproval rationale</b></td>\n";	
	print "<td>&nbsp;</td>\n";
	print "</tr>\n";
	print "</table>\n";
#	print "</ul>\n";
	my $button = (defined($NQScgi->param('dosurveillance')) || defined($NQScgi->param('dosurveillancerequest')) || defined($NQScgi->param('dointernalaudit')) || defined($NQScgi->param('doexternalaudit'))) ? "style=visibility:visible" : "style=visibility:hidden";
	print "<input type=button name=submitbutton value=Submit onClick=\"submitForm('search', 'display');\" $button>\n";
	print "</center>\n";
	print "<br>\n";
}

if ($cgiaction eq "display") {
	&writeAudit if (defined($NQScgi->param('dointernalaudit')) || defined($NQScgi->param('doexternalaudit')));
	&writeSurveillance if (defined($NQScgi->param('dosurveillance')) || defined($NQScgi->param('dosurveillancerequest')));
}

print <<Form_End;
</form>
</body>
</html>
Form_End
&NQS_disconnect($dbh);
exit();

