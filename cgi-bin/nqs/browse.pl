#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/qa/perl/RCS/browse.pl,v $
#
# $Revision: 1.15 $
#
# $Date: 2004/12/20 16:57:41 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: browse.pl,v $
# Revision 1.15  2004/12/20 16:57:41  starkeyj
# modified getConditionReports to check for CR Number entered as 0 and display the text No CRs Issued
#
# Revision 1.14  2004/10/21 18:41:51  starkeyj
# modified writeAudit to display reschedule information
# modified buildQuery to include a search for forecast start dates when actual start dates are entered
#
# Revision 1.13  2004/05/30 22:44:14  starkeyj
# modified searchCriteria, selectionCriteria and writeAudit to incorporate new data fields to search on
#
# Revision 1.12  2004/02/12 19:58:02  starkeyj
# modified writeSurveillance to pass the surveillance seq instead of id for getSurvId function
#
# Revision 1.11  2004/02/09 19:12:02  starkeyj
# bolded the searchCriteria string at top of surveillance report
#
# Revision 1.10  2004/02/06 23:45:47  starkeyj
# modified the selectionCriteria string for surveillances so QARD elements are correct
#
# Revision 1.9  2004/02/06 23:21:56  starkeyj
# modified form, search criteria, and display for surveillances
#
# Revision 1.8  2002/09/09 21:50:06  johnsonc
# Included new browse criteria to browse audits, surveillances, and surveillance requests by the issued by organization.
# Reformatted the presentation of the browse function (SCREQ00044).
#
# Revision 1.7  2002/04/18 20:39:46  johnsonc
# Modified script in the view user section. A user record now displays User Name History if it exists.
#
# Revision 1.6  2002/03/29 18:34:24  johnsonc
# Fixed error in browse user that prevented blank table rows from being displayed.
#
# Revision 1.5  2002/03/07 23:29:24  johnsonc
# Added code for a browse user feature.
#
# Revision 1.4  2001/11/05 13:45:03  starkeyj
# changed locations to display provinces
#
# Revision 1.3  2001/11/02 22:11:10  starkeyj
# cosmetic chnages - toned down color scheme
#
# Revision 1.2  2001/10/20 00:53:15  starkeyj
# modified to match team leads by id instead of string
#
# Revision 1.1  2001/10/19 23:29:49  starkeyj
# Initial revision
#
#
# Revision: $
#
# 


use OQA_specific qw(:Functions);
use NQS_Header qw(:Constants);
use OQA_Utilities_Lib qw(:Functions);
use OQA_Widgets qw(:Functions);
use UIShared qw(:Functions);
use DBSurveillance qw(:Functions);
use Tables qw(:Functions);
use CGI;
use integer;
use Tie::IxHash;
use strict;
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $NQScgi = new CGI;
my $username = defined($NQScgi->param("username")) ? $NQScgi->param("username") : "GUEST";
my $userid = defined($NQScgi->param("userid")) ? $NQScgi->param("userid") : "None";
my $viewUserId = defined($NQScgi->param("viewuserid")) ? $NQScgi->param("viewuserid") : "";
my $schema = defined($NQScgi->param("schema")) ? $NQScgi->param("schema") : "None";
my $Server = defined($NQScgi->param("server")) ? $NQScgi->param("server") : $NQSServer;
my $cgiaction = defined($NQScgi->param("cgiaction")) ? $NQScgi->param("cgiaction") : "option";
$cgiaction =  ($cgiaction eq '') ? "query" : $cgiaction;
my $browseOption = defined($NQScgi->param("browse_option")) ? $NQScgi->param("browse_option") : "";

my $dbh = &NQS_connect();
my $csr;
my @locresults = get_locations($dbh);
my $loc;
tie my %leadhash, "Tie::IxHash";
%leadhash = get_lookup_values($dbh, "users", 'id', "firstname || ' ' || lastname");
tie my %orghash,  "Tie::IxHash";
%orghash = get_lookup_values($dbh, 'organizations', 'id', 'organization');
tie my %suborghash,  "Tie::IxHash";
%suborghash = get_lookup_values($dbh, 'bsc_suborganizations', 'id', 'suborg');
tie my %supplierhash,  "Tie::IxHash";
%supplierhash = get_lookup_values($dbh, 'qualified_supplier', 'id', 'company_name');
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


############################
sub getOrgCount {
############################
	my ($dbh, $schema, $id, $rev, $year) = @_;
	my $sql = "SELECT COUNT(organization_id) FROM $schema.internal_audit_org_loc "
			 	 . "WHERE internal_audit_id = $id AND fiscal_year = $year AND revision = $rev";
#	print "$sql\n";
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
	my ($dbh, $schema, $id, $rev, $year, $table) = @_;
	my @locations;
	my $sql;
	if ($table eq "internal") {
	   $sql = "SELECT location_id FROM $schema.internal_audit_org_loc "
			 	 . "WHERE internal_audit_id = $id AND fiscal_year = $year "
			 	 . "AND revision = $rev ORDER BY location_id";
	}
	elsif ($table eq "external") {
	   $sql = "SELECT location_id FROM $schema.external_audit_locations "
			 	 . "WHERE external_audit_id = $id AND fiscal_year = $year "
			 	 . "AND revision = $rev ORDER BY location_id";
	}
#	print STDERR "$sql\n";
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	while (my $loc = $sth->fetchrow_array) {
		push @locations, $loc;
	}
	return (@locations);
}

###################
sub getSurveillanceID{
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
                    . $where . "and fiscal_year = $fy";
    
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

############################
sub getDefDocs {
############################
	my ($dbh, $id, $year) = @_;
	my $sql = "SELECT deficiency FROM $schema.surveillance_deficiencies "
				 . "WHERE surveillance_id = $id "
				 . "AND fiscal_year = $year";
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	return ($sth->fetchrow_array);
}

############################
sub getConditionReports {
############################
	my ($dbh, $id, $year, $type) = @_;
	my $fy = ($year > 50) ? $year + 1900 : $year + 2000;
	my $sql = "SELECT crnum, crlevel, summary FROM $schema.condition_report "
				 . "WHERE generatorid = $id AND generatorfy = $fy AND generatedfrom = '$type'";
				 
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	my $conditions;
	my $first = 1;
	while (my ($crnum,$crlevel,$crsummary) = $sth->fetchrow_array) {
		$conditions .= ($first ? "" : ", ") . ($crnum eq '0' ? "No CRs Issued" : $crnum);
		$first = 0;
	}
	return $conditions;
}

############################
sub getFollowup {
############################
	my ($dbh, $id, $year, $type) = @_;
	my $fy = ($year > 50) ? $year + 1900 : $year + 2000;
	my $sql = "SELECT crid, followup FROM $schema.condition_report_follow_up "
				 . "WHERE crfu_generatorid = $id AND crfu_generatorfy = $fy AND crfu_generatedfrom = '$type' ";
				 
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	my $followup;
	my $first = 1;
	while (my ($crid,$followuptext) = $sth->fetchrow_array) {
		if ($first) {$first = 0; $followup = $crid;}
		else {
			$followup .= ", " . $crid;
		}
	}
	return $followup;
}

############################
sub getBestPractice {
############################
	my ($dbh, $id, $year, $type) = @_;
	my $fy = ($year > 50) ? $year + 1900 : $year + 2000;
	my $sql = "SELECT bestpractice FROM $schema.best_practice "
				 . "WHERE generatorid = $id AND generatorfy = $fy AND generatedfrom = '$type' ";
			 
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	my $bestpractice;
	my $first = 1;
	while (my ($bestpracticetext) = $sth->fetchrow_array) {
		if ($first) {$first = 0; $bestpractice = $bestpracticetext;}
		else {
			$bestpractice .= "<br> " . $bestpracticetext;
		}
	}
	return $bestpractice;
}

############################
sub getSupplier {
############################
	my ($dbh, $schema, $modified, $scheduleType, $supplierId) = @_;
	my $supplier = "&nbsp;";
	my $string = "";
	if (defined($supplierId)) {
		my $sql = "SELECT company_name FROM $schema.qualified_supplier WHERE id = $supplierId";
		my $sth = $dbh->prepare($sql);
		$sth->execute;
		$supplier = $sth->fetchrow_array;
	}
	$string .= "$supplier";
	return($string);
}

############################
sub getOrganization {
############################
	my ($dbh, $schema, $modified, $scheduleType, $orgId) = @_;
	my $org = "&nbsp;";
	my $string = "";
	if (defined($orgId)) {
		my $sql = "SELECT abbr FROM $schema.organizations WHERE id = $orgId";
		my $sth = $dbh->prepare($sql);
		$sth->execute;
		$org = $sth->fetchrow_array;
	}
	$string .= "$org";
	return($string);
}

############################
sub getSuborganization {
############################
	my ($dbh, $schema, $modified, $scheduleType, $suborgId) = @_;
	my $suborg = "&nbsp;";
	my $string = "";
	if (defined($suborgId)) {
		my $sql = "SELECT suborg FROM $schema.bsc_suborganizations WHERE id = $suborgId";
		my $sth = $dbh->prepare($sql);
		$sth->execute;
		$suborg = $sth->fetchrow_array;
	}
	$string .= "$suborg";
	return($string);
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
			$string = "$city,&nbsp;&nbsp;$state";
		}
		elsif (!(defined($city)) && defined($state) && !(defined($province))) {
			$string =  "$state";
		}
		elsif (defined($city) && !(defined($state)) && defined($province) ) {
			$city =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
			$province =~ s/(^\w|\b\w)(\w+)/\u$1\L$2/g;
			$string =  "$city,&nbsp;&nbsp;$province";
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

############################
sub writeLocations {
############################
    my ($id,$fy,$table) = @_;
    my %selectedhash;
    my $select_table;

    if ($table eq "internal") {
		$select_table = "internal_audit_org_loc";
	 }
	 elsif ($table eq "external") {
		$select_table = "external_audit_locations";
    }
    
    %selectedhash = get_lookup_values($dbh, $select_table . ", " .  $schema . ".locations", "initcap(city) || ', ' || state || initcap(province) ", "locations.id", $table . "_audit_id = $id and fiscal_year = $fy and revision = 0 and location_id = locations.id");
    my $i = 1; 
 	 foreach my $keys ( keys %selectedhash) {
	 	print "$keys";
	 	if ($i < (keys(%selectedhash))) {
	 		print "; ";
	 		$i++;
	 	}
    } 
}

############################
sub writeOrganizations {
############################
    my ($id,$fy,$table) = @_;
    tie my %selectedhash, "Tie::IxHash";;
    my $i = 1;
    
    %selectedhash = get_lookup_values($dbh, "internal_audit_org_loc, " .  $schema . ".organizations", "abbr", "organizations.id", $table . "_audit_id = $id and fiscal_year = $fy and revision = 0 and organization_id = organizations.id");
  	 foreach my $keys ( keys %selectedhash) {
 		print "$keys";
 		if ($i < (keys(%selectedhash))) {
			 		print ", ";
			 		$i++;
	 	}
    } 
}

############################
sub writeSupplier {
############################
	my ($id) = @_;
   my $company_name = '';
	if ($id) {
    	$company_name = lookup_single_value($dbh,$schema,'qualified_supplier','company_name'," $id ");
   }
   print "$company_name";
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

###################################################################################################################################
sub writeResultsSelect {  # routine to write the select for sat/unsat
###################################################################################################################################
    my %args = (
	name => "results",
	@_,
    );	
    my @resultsList = ("SAT","UNSAT","NA");
    my $output = "<select name=$args{name}>";
    $output .= "<option value=0>(all)\n";
    for (my $j = 0; $j <= $#resultsList; $j++) {
    	$output .= "<option value=$resultsList[$j]>$resultsList[$j]\n";
    }
    $output .= "</select>\n";
    
    return($output);
}

############################
sub writeAudit {
############################
	 my ($sqlstring,$table,$fy,$output, $auditCriteria) = @_;
    my $csr;
    my $csr2;
    my $csr3;
    my $sql;
    my @values;
    my @details;
    my @summary;
    my $select_table;
	 my $num;
	 my $display_fy = lpadzero($fy,2);
	 my $reportdate = $dbh->selectrow_array("SELECT to_char(SYSDATE,'MM/DD/RRRR HH:Mi PM') FROM dual");
#	 print "<br> $sqlstring <br><br>\n";
	 print "<br><table width=80% border=0 cellspacing=1 cellpadding=1 align=center>\n";
	 print STDERR "output $output\n";
    $csr = $dbh->prepare($sqlstring);
    $csr->execute;
	print "<tr bgcolor=#B0C4DE><td colspan=4 align=center><b><font color=black>Browse " . ($table eq 'internal' ? "Internal " : $table eq 'external' ? "External " : "" ) . "Audits</font></b></td></tr>\n";
        print "<tr><td colspan=4><font size=2><b>$auditCriteria</b></font></td></tr>\n";
	print "<tr bgcolor=#E6E6FA>\n";
	print "<td><b><font size=2 color=black>Audit ID</font></b></td>\n";
    	print "<td><b><font size=2 color=black>Start Date</font></b></td>\n";
	print "<td><b><font size=2 color=black>End Date</font></b></td>\n";
	print "<td><b><font size=2 color=black>Status</font></b></td>\n";	 
	print "</tr>\n";
	 while (@values = $csr->fetchrow_array) {
		 my $seq = defined($values[0]) ? $values[0] : '###';
		 my $type = defined($values[1]) ? $values[1] : '';
		 my $issuedtoid = defined($values[2]) ? $values[2] : '';
		 my $beginDate = defined($values[3]) ? $values[3] : '';
		 my $endDate = defined($values[4]) ? $values[4] : '';
		 my $leadid = defined($values[5]) ? $values[5] : '';
		 my $scope = defined($values[6]) ? $values[6] : '';
		 my $notes = defined($values[7]) ? $values[7] : 'None';
		 my $cancelled = defined($values[8]) ? $values[8] : '';
		 my $forecast = defined($values[9]) ? $values[9] : '';
		 my $completionDate = defined($values[10]) ? $values[10] : '';
		 my $id = defined($values[11]) ? $values[11] : '';
		 my $teamMembers = defined($values[12]) ? $values[12] : '';
		 my $issuedbyid = defined($values[13]) ? $values[13] : '';
		my $qardelements = defined($values[14]) ? $values[14] : '0000000000000000000000000';
		my $adequacy = defined($values[15]) ? $values[15] : '&nbsp;';
		my $implementation = defined($values[16]) ? $values[16] : '&nbsp;';
		my $effectiveness = defined($values[17]) ? $values[17] : '&nbsp;';
		my $procedures = defined($values[18]) ? $values[18] : '';
		my $state = defined($values[19]) ? $values[19] : 0;
		my $title = defined($values[20]) ? $values[20] : 0;
		my $reschedule = defined($values[21]) ? $values[21] : 0;
		my $overall_results = defined($values[22]) ? $values[22] : 0;
		my $supplierId = defined($values[23]) ? $values[23] : 0;
		#my $displayFy = lpadzero($year,2);
		my $teamLead = lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname",$leadid);
#		print STDERR "qard = $qardelements\n";

		$sql = "SELECT location_id, organization_id, suborganization_id FROM $schema.internal_audit_org_loc "
					 . "WHERE internal_audit_id = $id AND fiscal_year = " . substr($fy, 2) . "AND revision = 0" if ($table eq 'internal');
		$sql = "SELECT location_id FROM $schema.external_audit_locations "
					 . "WHERE external_audit_id = $id AND fiscal_year = " . substr($fy, 2) . "AND revision = 0" if ($table eq 'external');
		#		print STDERR "$sql\n";
		my $sth = $dbh->prepare($sql);
		$sth->execute;

		my $auditstatus = ($reschedule) ? "Rescheduled&nbsp;$reschedule" : $cancelled && $cancelled eq 'Y' ? "Cancelled" : $state && $state eq 'Cancelled' ? "Cancelled" : $completionDate ? "Report Approved $completionDate" : 
		$state && $state eq 'Field Work Complete' ? "Field Work Complete $endDate" : $state && $state eq 'In Progress' ? "In Progress $beginDate" : "$beginDate&nbsp;";    
      		
		print "<tr><td valign=top nowrap><font size=2>" . &getInternalAuditId($dbh, $issuedbyid, $issuedtoid, $type, $fy, $seq) . "</font></td>\n" if ($table eq 'internal');
		print "<tr><td valign=top nowrap><font size=2>" . &getExternalAuditId($dbh, $issuedbyid, $issuedtoid, $type, $fy, $seq) . "</font></td>\n" if ($table eq 'external');
		if ($output ne 'abbreviated') {
			print "<td valign=top><font size=2>" . ($beginDate ? "Start: $beginDate" : $forecast ? "Scheduled: $forecast" : "&nbsp;") . "</font></td>\n";
			print "<td valign=top><font size=2>" . ($endDate ? "End: $endDate" : "&nbsp;") . "</font></td>\n";
			print "<td valign=top><font size=2>" . ($completionDate ? "Report Approved: $completionDate" : $auditstatus eq 'Rescheduled' ? "Rescheduled" : $auditstatus eq 'Cancelled' ? "Cancelled" : $state ? "$state" : "&nbsp;") . "</font></td>\n";
		} else {
			print "<td valign=top colspan=3><font size=2>$auditstatus</font></td>\n";
		}
		print "</tr>\n";		 
		if ($title) {
			print "<tr><td valign=top><font size=2>Title:</font></td>\n";
			print "<td colspan=3><font size=2>$title</font></td></tr>\n";		
		} elsif ($scope gt "") {
			print "<tr><td valign=top><font size=2>Scope:</font></td>\n";
			print "<td colspan=3><font size=2>$scope</font></td></tr>\n";
		}
		if ($teamLead gt "") {
			print "<tr><td><font size=2>Team Lead:</font></td>\n";
			print "<td colspan=3><font size=2>$teamLead</font></td></tr>\n";
		}
		if ($output eq 'expanded' && $teamMembers gt "") {
			print "<tr><td nowrap><font size=2>Team Members:</font></td>\n";
			print "<td colspan=3><font size=2>$teamMembers</font></td></tr>\n";
		}   
		if ($output ne 'abbreviated') {
			my $orgs;
			my $locs;
			my $suborgs;
			my $first = 1;
			while (my ($locId, $orgId, $suborgId) = $sth->fetchrow_array) {
				if ($first) {$first = 0;}
				else {
					$orgs .= ", " if (defined($orgId)); 
					$suborgs .= ", " if (defined($suborgId)); 
					$locs .= "; " if (defined($locId));
				}
				$orgs .= &getOrganization($dbh, $schema, "", "", $orgId) if ($table eq "internal" && defined($orgId)); 
				$suborgs .= &getSuborganization($dbh, $schema, "", "", $suborgId) if ($table eq "internal" && defined($suborgId)); 
				$orgs .= $supplierhash{$supplierId} if ($table eq "external" && defined($supplierId));
				$locs .= &getLocation($dbh, $schema, $locId) if (defined($locId));
			}
			print "<tr><td valign=top><font size=2>";		
			print (($table eq "internal") ? "Organization:" : "Supplier:");
			print "</font></td><td colspan=3><font size=2>$orgs&nbsp;</font></td></tr>\n";
			print "<tr><td valign=top><font size=2>Suborganization:</td><td colspan=3><font size=2>$suborgs&nbsp;</font></td></tr>\n" if(defined($suborgs));
			print "<tr><td valign=top><font size=2>Location:</font></td><td colspan=3><font size=2>$locs&nbsp;</font></td></tr>\n";
		
		#	$defDoc = &getDefDocs($dbh, $id, $year);		     			 

 			if ($qardelements gt "") {
     				print "<tr><td><font size=2>QARD&nbsp;Elements:</font></td>\n";
     				print "<td colspan=3><font size=2>" . &writeQARD(qard=>"$qardelements") . "&nbsp;</font></td></tr>\n";
  			}
   			if ($procedures gt "") {
       				print "<tr><td><font size=2>Procedures:</font></td>\n";
       				print "<td colspan=3><font size=2>$procedures</font></td></tr>\n";
  			}
         		print "<tr><td><font size=2>Results:</font></td>\n";
         		print "<td><font size=2>Adequacy - &nbsp;$adequacy</font></td>\n";
         		print "<td><font size=2>Implementation - &nbsp$implementation</font></td>\n";
       			print "<td><font size=2>Effectiveness - &nbsp;$effectiveness</font></td></tr>\n";		
       		} 
       		if ($output eq 'expanded') {
       			my $type = $table eq 'internal' ? "IA" : "EA";
       			my $conditions = &getConditionReports($dbh, $id, substr($fy, 2),$type);
       			my $followup = &getFollowup($dbh, $id, substr($fy, 2),$type);
			my $bestpractice = &getBestPractice($dbh, $id, substr($fy, 2),$type);
			if ($output eq 'expanded' && $overall_results) {		
				print "<tr><td valign=top><font size=2>Results Notes:</font></td>\n";
				print "<td colspan=3><font size=2>$overall_results</font></td></tr>\n";
			}
			if (defined($conditions)) {
				print "<tr><td valign=top nowrap><font size=2>Condition Reports:</font></td>\n";
				print "<td colspan=3><font size=2>$conditions</font></td></tr>\n";
			}
			if (defined($followup)) {		
				print "<tr><td valign=top><font size=2>Follow Up:</font></td>\n";
				print "<td colspan=3><font size=2>$followup</font></td></tr>\n";
			}
			if (defined($bestpractice)) {		
				print "<tr><td valign=top><font size=2>Best Practice:</font></td>\n";
				print "<td colspan=3><font size=2>-$bestpractice</font></td></tr>\n";
			}
#			if ($status gt "") {
#				print "<tr>\n<td valign=top><font size=2>Notes:</font></td>\n";
#				print "<td colspan=3><font size=2>$status</font></td></tr>\n";
#			}
		}
       		print "<tr><td colspan=4><hr></td></tr>\n";
	}
	
	print "</table><br>\n";
}
############################
sub writeAudit_old {
############################
	 my ($sqlstring,$table,$fy) = @_;
    my $csr;
    my $csr2;
    my $csr3;
    my @values;
    my @details;
    my @summary;
    my $select_table;
	 my $num;
	 my $display_fy = lpadzero($fy,2);
#	 print "<br> $sqlstring <br><br>\n";
	 print "<br><table width=80% border=0 cellspacing=1 cellpadding=1 align=center>\n";
#	 print STDERR "write audit $sqlstring\n";
    $csr = $dbh->prepare($sqlstring);
    $csr->execute;
	 print "<tr bgcolor=#E6E6FA>\n";
	 if ($table eq 'internal') {
	    print "<tr bgcolor=#B0C4DE><td align=center colspan=5><b><font color=black size=+1>Internal Audit Browse Results</font></b></td></tr>";
	 	 print "<tr bgcolor=#E6E6FA>\n";
		 print "<td width=\"10%\" valign=\"top\"><b><font size=2 color=black>Organization</font></b></td>\n";
       print "<td width=\"30%\" valign=\"top\"><b><font size=2 color=black>Location</font></b></td>\n";
	    print "<td width=\"14%\" valign=\"top\"><b><font size=2 color=black>Number</font></b></td>\n";
	    print "<td width=\"8%\" valign=\"top\"><b><font size=2 color=black>Dates</font></b></td>\n";
	    print "<td width=\"8%\" valign=\"top\"><b><font size=2 color=black>Status</font></b></td>\n";  
	 }
	 elsif ($table eq 'external') {
	    print "<tr  bgcolor=#B0C4DE><td align=center colspan=5><b><font color=black size=+1>External Audit Browse Results</font></b></td></tr>";
	 	 print "<tr bgcolor=#E6E6FA>\n";
		 print "<td width=\"20%\" valign=\"top\"><b><font size=2 color=black>Supplier</font></b></td>\n";
    	 print "<td width=\"15%\" valign=\"top\"><b><font size=2 color=black>Location</font></b></td>\n";
	 	 print "<td width=\"14%\" valign=\"top\"><b><font size=2 color=black>Number</font></b></td>\n";
	    print "<td width=\"8%\" valign=\"top\"><b><font size=2 color=black>Dates</font></b></td>\n";
	    print "<td width=\"8%\" valign=\"top\"><b><font size=2 color=black>Status</font></b></td>\n";	 
	 }
	 print "</tr>\n";

	 while (@values = $csr->fetchrow_array) {
		 my $seq = defined($values[0]) ? $values[0] : '###';
		 my $type = defined($values[1]) ? $values[1] : '';
		 my $issuedtoid = defined($values[2]) ? $values[2] : '';
		 my $start = defined($values[3]) ? $values[3] : '';
		 my $end = defined($values[4]) ? $values[4] : '';
		 my $leadid = defined($values[5]) ? $values[5] : '';
		 my $plandetail = defined($values[6]) ? $values[6] : '';
		 my $notes = defined($values[7]) ? $values[7] : 'None';
		 my $cancelled = defined($values[8]) ? $values[8] : '';
		 my $forecast = defined($values[9]) ? $values[9] : '';
		 my $completed = defined($values[10]) ? $values[10] : '';
		 my $sched = defined($values[11]) ? $values[11] : '';
		 my $teamMembers = defined($values[12]) ? $values[12] : '';
		 my $issuedbyid = defined($values[13]) ? $values[13] : '';

		 
   	 my $teamlead = lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname",$leadid);
		 print "<tr><td colspan=2>";
		 print "<table width=\"100%\" border=\"0\">\n";
		 if ($table eq 'internal') {
		 	 $num = &getInternalAuditId($dbh, $issuedbyid, $issuedtoid, $type, $fy, $seq);
			 my $orgCount = &getOrgCount($dbh, $schema, $sched, 0, substr($fy, 2));
      	 my $rowCount = 0;
			 if ($orgCount > 1) {
				 my $sql = "SELECT organization_id, location_id FROM $schema.internal_audit_org_loc "
			          	  . "WHERE internal_audit_id = $sched AND fiscal_year = " . substr($fy, 2)
			          	  . "AND revision = 0";
		 		 my $sth3 = $dbh->prepare($sql);
				 $sth3->execute;
				 while (my ($orgId, $locId) = $sth3->fetchrow_array) {
					 print "<tr>\n<td width=\"24%\" valign=\"top\">";
					 print &getOrganization($dbh, $schema, "", "", $orgId);
					 print "<td valign=\"top\" width=\"76%\">";
					 print &getLocation($dbh, $schema, $locId);
					 print "</td>\n</tr>\n";
		 		 } 
		 	  }
		     if ($orgCount == 1) {
				  my @locIds = &getLocationIds($dbh, $schema, $sched, 0, substr($fy, 2), 'internal');
				  my @orgIds = &getOrganizationIds($dbh, $schema, $sched, 0, substr($fy, 2));
				  my $loopCount;
				  $loopCount = 1 if (@locIds == 1 || @locIds == 2);
				  $loopCount = 2 if (@locIds == 3 || @locIds == 4 || @locIds == 5);
				  $loopCount = 3 if (@locIds == 6 || @locIds == 7);
				  my $rowCount = 0;
				  for (my $i = 0; $i < $loopCount; $i++) {
					  if ($rowCount == 0) {
						  print "<tr>\n<td width=\"24%\" valign=\"top\">";
						  print &getOrganization($dbh, $schema, "", "", pop(@orgIds));
						  print "<td  valign=\"top\" width=\"76%\">";
						  print &getLocation($dbh, $schema, pop(@locIds));
						  print "&nbsp;&nbsp;";
						  print &getLocation($dbh, $schema, pop(@locIds));
						  print "</td>\n</tr>\n";
					  }
					  else {
						  print "<tr>\n<td width=\"24%\" valign=\"top\">";
						  print &getOrganization($dbh, $schema, "", "", pop(@orgIds));
						  print "<td  valign=\"top\" width=\"76%\">";
						  print &getLocation($dbh, $schema, pop(@locIds));
						  print "&nbsp;&nbsp;";
						  print &getLocation($dbh, $schema, pop(@locIds));
						  print "&nbsp;&nbsp;";
						  print &getLocation($dbh, $schema, pop(@locIds));
						  print "</td>\n</tr>\n";
					  }
					  $rowCount++;
				  }			
			  }
		  }
		  elsif ($table eq "external") {	
		  	  my $qslId = defined($values[13]) ? $values[13] : '';
		  	  $num = &getExternalAuditId($dbh, $issuedbyid, $issuedtoid, $type, $fy, $seq);
			  print "<tr>\n<td valign=\"top\" width=\"58%\"><font size=2>";
			  &writeSupplier($qslId);
			  print "</font size=2></td>\n";
			  my @locIds = &getLocationIds($dbh, $schema, $sched, 0, substr($fy, 2), 'external');
			  my $rowCount = 0;
			  while (my $locId = pop(@locIds)) {
			  	  print "<tr><td>&nbsp;</td>"	if ($rowCount > 0);
			  	  print "<td valign=top width=\"42%\">";
			  	  print &getLocation($dbh, $schema, $locId);
			  	  print "</td>";
			  	  print "</tr>" if ($rowCount > 0);
			  	  $rowCount++;
			  }
		  } 
        print "</table>\n</td>\n";
        if ($cancelled eq "" || $cancelled eq "N") {
        	  print "<td valign=\"top\"><font size=2>$num</font></td>\n";
        }
        else {
        	  print "<td valign=\"top\">&nbsp;</td>\n";
        } 
		  if ($start gt "" && $end gt "" && ($cancelled eq "" || $cancelled eq "N")) {
			  print "<td valign=\"top\"><font size=2>$start-$end</font></td>\n";
		  }
		  elsif ($start eq "" && $end eq "" && $forecast gt "") {
			  print "<td valign=\"top\"><font size=2>$forecast</font></td>\n";
		  }
		  else {
			  print "<td>&nbsp;</td>\n";
		  }
		  if ($cancelled gt "" && $cancelled eq "Y") {
			  print "<td valign=\"top\"><font size=2>CANCELLED</font></td>\n";
		  }
		  elsif ($completed gt "") {
			  print "<td valign=\"top\"><font size=2>COMPLETE</font></td>\n";
		  }
		  else {
			  print "<td>&nbsp;</td>\n";
		  }
		  print "</tr>\n";
		  print "<tr>\n<td colspan=\"5\">\n";
		  print "<table border=0 width=\"100%\">\n";
		  if ($leadid gt "" && $leadid != 0) {
			  print "<tr>\n<td width=\"14%\"><font size=2 color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Lead:</b></font></td>\n";
			  my $sth = $dbh->prepare("SELECT firstname || ' ' || lastname FROM $schema.users WHERE id = $leadid");
			  $sth->execute;
			  my $teamLead = $sth->fetchrow_array;
			  print "<td colspan=\"4\"><font size=2>$teamLead</font></td>\n</tr>\n";
		  }
		  if ($teamMembers gt "") {
			  print "<tr>\n<td nowrap width=\"14%\"><font size=\"2\" color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Members:</b></td>\n";
			  print "<td colspan=\"4\"><font size=2>$teamMembers</font></td>\n</tr>\n";
		  }
		  if ($plandetail gt "") {
			  print "<tr>\n<td nowrap valign=\"top\" width=\"14%\"><font size=\"2\" color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Scope:</b></td>\n";
			  print "<td valign=\"top\" colspan=\"4\"><font size=\"2\">$plandetail</font></td>\n</tr>\n";
		  }
		  if ($notes gt "") {
			  print "<tr>\n";
			  print "<td valign=\"top\" width=\"14%\"><font size=\"2\" color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Notes:</b></font></td>\n";
			  print "<td valign=\"top\" colspan=\"4\"><font size=\"2\">$notes</font></td>\n";
			  print "</tr>\n";
		  }
		  print "</td></tr>\n</table>";
		  print "<tr><td colspan=5><hr></td></tr>\n";
	}
	print "</table><br>\n";
}

############################
sub writeSurveillance {
############################
	my ($dbh, $sql, $table, $fy, $output, $survCriteria) = @_;
	print "<br><table width=80% border=0 cellspacing=1 cellpadding=1 align=center>\n";
	#	print "<!-- $sql\n -->";
	my $csr = $dbh->prepare($sql);
	$csr->execute;
	print "<tr bgcolor=#B0C4DE><td colspan=4 align=center><b><font color=black>Browse Surveillance</font></b></td></tr>\n";
        print "<tr><td colspan=4><font size=2><b>$survCriteria</b></font></td></tr>\n";
	print "<tr><td colspan=4><hr></td></tr>\n";
	#print "<tr bgcolor=#E6E6FA>\n";
	#print "<td width=\"15%\" valign=\"top\"><b><font size=2 color=black>Organization<br> or Supplier</font></b></td>\n";
	#print "<td width=\"20%\" valign=\"top\"><b><font size=2 color=black>Location</font></b></td>\n";
	#print "<td width=\"15%\" valign=\"top\"><b><font size=2 color=black>Surveillance<br>Number</font></b></td>\n";
	#print "<td width=\"15%\" valign=\"top\"><b><font size=2 color=black>Dates</font></b></td>\n";
	#print "<td width=\"15%\" valign=\"top\"><b><font size=2 color=black>Date<br>Completed</font></b></td>";
	#print "</tr>\n";
    	my $reportdate = $dbh->selectrow_array("SELECT to_char(SYSDATE,'MM/DD/RRRR HH:Mi PM') FROM dual");
   	while (my @values = $csr->fetchrow_array) {
		my $id = defined($values[0]) ? $values[0] : '###';
		my $year = defined($values[1]) ? $values[1] : '';
		my $issuedTo = defined($values[2]) ? $values[2] : '';
		my $cancelled = defined($values[3]) ? $values[3] : 0;
		my $teamLead = defined($values[4]) ? $values[4] : '';
		my $scope = defined($values[5]) ? $values[5] : '';
		my $forecastDate = defined($values[6]) ? $values[6] : 0;
		my $beginDate = defined($values[7]) ? $values[7] : 0;
		my $endDate = defined($values[8]) ? $values[8] : 0;
		my $elem = defined($values[9]) ? $values[9] : '';
		my $notes = defined($values[10]) ? $values[10] : '';
		my $issuedBy = defined($values[11]) ? $values[11] : '';
		my $status = defined($values[12]) ? $values[12] : '';
		my $completionDate = defined($values[13]) ? $values[13] : 0;
		my $teamMembers = defined($values[14]) ? $values[14] : '';
		my $intExt = defined($values[15]) ? $values[15] : '';
		my $qardelements = defined($values[16]) ? $values[16] : '0000000000000000000000000';
		my $adequacy = defined($values[17]) ? $values[17] : '&nbsp;';
		my $implementation = defined($values[18]) ? $values[18] : '&nbsp;';
		my $effectiveness = defined($values[19]) ? $values[19] : '&nbsp;';
		my $procedures = defined($values[20]) ? $values[20] : '';
		my $state = defined($values[21]) ? $values[21] : 0;
		my $title = defined($values[22]) ? $values[22] : 0;
		my $reschedule = defined($values[23]) ? $values[23] : 0;
		my $overall_results = defined($values[24]) ? $values[24] : 0;
		my $estbegin = defined($values[25]) ? $values[25] : 0;
		my $estend = defined($values[26]) ? $values[26] : 0;
		my $seq = defined($values[27]) ? $values[27] : 0;
		my $displayFy = lpadzero($year,2);
		my $displayId;
		my $defDoc;
		$teamLead = lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname",$teamLead);
		#print STDERR "fiscal year= $fy\n";

		my $sql = "SELECT organization_id, location_id, supplier_id, suborganization_id FROM $schema.surveillance_org_loc "
					 . "WHERE surveillance_id = $id AND fiscal_year = $year";
		#		print STDERR "$sql\n";
		my $sth = $dbh->prepare($sql);
		$sth->execute;

		my $survstatus = ($reschedule) ? "Rescheduled" : $cancelled && $cancelled eq 'Y' ? "Cancelled" : $state && $state eq 'Cancelled' ? "Cancelled" : $completionDate ? "Report Approved $completionDate" : 
		$state && $state eq 'Field Work Complete' ? "Field Work Complete $endDate" : $state && $state eq 'In Progress' ? "In Progress $beginDate" : $estbegin ? 
      		"Scheduled $estbegin" : "$beginDate&nbsp;";    
      		
		print "<tr><td valign=top nowrap><font size=2>" .  &getSurvId($dbh, $issuedBy, $issuedTo, $intExt, $fy, $seq) . "</font></td>\n";
		if ($output ne 'abbreviated') {
			print "<td valign=top><font size=2>" . ($beginDate ? "Start: $beginDate" : $estbegin ? "Scheduled: $estbegin" : "&nbsp;") . "</font></td>\n";
			print "<td valign=top><font size=2>" . ($endDate ? "End: $endDate" : $estend ? "Est. End: $estend" : "&nbsp;") . "</font></td>\n";
			print "<td valign=top><font size=2>" . ($completionDate ? "Report Approved: $completionDate" : $survstatus eq 'Rescheduled' ? "Rescheduled" : $survstatus eq 'Cancelled' ? "Cancelled" : $state ? "$state" : "&nbsp;") . "</font></td>\n";
		} else {
			print "<td valign=top colspan=3><font size=2>$survstatus</font></td>\n";
		}
		print "</tr>\n";
		if ($title) {
			print "<tr><td valign=top><font size=2>Title:</font></td>\n";
			print "<td colspan=3><font size=2>$title</font></td></tr>\n";		
		} elsif ($scope gt "") {
			print "<tr><td valign=top><font size=2>Scope:</font></td>\n";
			print "<td colspan=3><font size=2>$scope</font></td></tr>\n";
		}
		if ($teamLead gt "") {
			print "<tr><td><font size=2>Team Lead:</font></td>\n";
			print "<td colspan=3><font size=2>$teamLead</font></td></tr>\n";
		}
		if ($output eq 'expanded' && $teamMembers gt "") {
			print "<tr><td nowrap><font size=2>Team Members:</font></td>\n";
			print "<td colspan=3><font size=2>$teamMembers</font></td></tr>\n";
		}
		if ($output ne 'abbreviated') {
			my $orgs;
			my $locs;
			my $suborgs;
			my $first = 1;
			while (my ($orgId, $locId, $supplierId, $suborgId) = $sth->fetchrow_array) {
				if ($first) {$first = 0;}
				else {
					$orgs .= ", " if (defined($orgId) || defined ($supplierId)); 
					$suborgs .= ", " if (defined($suborgId)); 
					$locs .= "; " if (defined($locId));
				}
				$orgs .= &getOrganization($dbh, $schema, "", "", $orgId) if ($intExt eq "I" && defined($orgId)); 
				$suborgs .= &getSuborganization($dbh, $schema, "", "", $suborgId) if ($intExt eq "I" && defined($suborgId)); 
				$orgs .= $supplierhash{$supplierId} if ($intExt eq "E" && defined($supplierId));
				$locs .= &getLocation($dbh, $schema, $locId) if (defined($locId));
			}
			print "<tr><td valign=top><font size=2>";		
			print (($intExt eq "I") ? "Organization:" : "Supplier:");
			print "</font></td><td colspan=3><font size=2>$orgs&nbsp;</font></td></tr>\n";
			print "<tr><td valign=top><font size=2>Suborganization:</td><td colspan=3><font size=2>$suborgs&nbsp;</font></td></tr>\n" if(defined($suborgs));
			print "<tr><td valign=top><font size=2>Location:</font></td><td colspan=3><font size=2>$locs&nbsp;</font></td></tr>\n";
		
			$defDoc = &getDefDocs($dbh, $id, $year);		     			 
   			if ($elem gt "") {
   				print "<tr><td><font size=2>Program&nbsp;Elements:</font></td>\n";
   				print "<td colspan=3><font size=2>$elem</font></td></tr>\n";
  			}
 			if ($qardelements gt "") {
     				print "<tr><td><font size=2>QARD&nbsp;Elements:</font></td>\n";
     				print "<td colspan=3><font size=2>" . &writeQARD(qard=>"$qardelements") . "&nbsp;</font></td></tr>\n";
  			}
   			if ($procedures gt "") {
       				print "<tr><td><font size=2>Procedures:</font></td>\n";
       				print "<td colspan=3><font size=2>$procedures</font></td></tr>\n";
  			}
         		print "<tr><td><font size=2>Results:</font></td>\n";
         		print "<td><font size=2>Adequacy - &nbsp;$adequacy</font></td>\n";
         		print "<td><font size=2>Implementation - &nbsp$implementation</font></td>\n";
       			print "<td><font size=2>Effectiveness - &nbsp;$effectiveness</font></td></tr>\n";		
       		} 
       		if ($output eq 'expanded') {
       			my $conditions = &getConditionReports($dbh, $id, $year,'S');
       			my $followup = &getFollowup($dbh, $id, $year,'S');
			my $bestpractice = &getBestPractice($dbh, $id, $year,'S');
			if ($output eq 'expanded' && $overall_results) {		
				print "<tr><td valign=top><font size=2>Results Notes:</font></td>\n";
				print "<td colspan=3><font size=2>$overall_results</font></td></tr>\n";
			}
			if (defined($defDoc)) {		
				print "<tr><td valign=top><font size=2>Def. Docs Issued:</font></td>\n";
				print "<td colspan=3><font size=2>-$defDoc</font></td></tr>\n";
			}
			if (defined($conditions)) {
				print "<tr><td valign=top nowrap><font size=2>Condition Reports:</font></td>\n";
				print "<td colspan=3><font size=2>$conditions</font></td></tr>\n";
			}
			if (defined($followup)) {		
				print "<tr><td valign=top><font size=2>Follow Up:</font></td>\n";
				print "<td colspan=3><font size=2>$followup</font></td></tr>\n";
			}
			if (defined($bestpractice)) {		
				print "<tr><td valign=top><font size=2>Best Practice:</font></td>\n";
				print "<td colspan=3><font size=2>-$bestpractice</font></td></tr>\n";
			}
#			if ($status gt "") {
#				print "<tr>\n<td valign=top><font size=2>Notes:</font></td>\n";
#				print "<td colspan=3><font size=2>$status</font></td></tr>\n";
#			}
		}
		print "<tr><td colspan=4><hr></td></tr>\n";
   }
   print "<tr><td colspan=4><font size=-1><i>$reportdate</i></font></td></tr>\n";
   print "</table><br>\n";
}
############################
sub writeSurveillance_old {
############################
	my ($dbh, $sql, $table, $fy) = @_;
	print "<br><table width=80% border=1 cellspacing=1 cellpadding=1 align=center>\n";
	#	print "<!-- $sql\n -->";
	my $csr = $dbh->prepare($sql);
	$csr->execute;
	print "<tr bgcolor=#B0C4DE><td colspan=5 align=center><b><font color=black size=+1>Surveillance Browse Results</font></b></td></tr>\n";
	#print "<tr bgcolor=#E6E6FA>\n";
	#print "<td width=\"15%\" valign=\"top\"><b><font size=2 color=black>Organization<br> or Supplier</font></b></td>\n";
	#print "<td width=\"20%\" valign=\"top\"><b><font size=2 color=black>Location</font></b></td>\n";
	#print "<td width=\"15%\" valign=\"top\"><b><font size=2 color=black>Surveillance<br>Number</font></b></td>\n";
	#print "<td width=\"15%\" valign=\"top\"><b><font size=2 color=black>Dates</font></b></td>\n";
	#print "<td width=\"15%\" valign=\"top\"><b><font size=2 color=black>Date<br>Completed</font></b></td>";
	#print "</tr>\n";

   while (my @values = $csr->fetchrow_array) {
		my $id = defined($values[0]) ? $values[0] : '###';
		my $year = defined($values[1]) ? $values[1] : '';
		my $issuedTo = defined($values[2]) ? $values[2] : '';
		my $cancelled = defined($values[3]) ? $values[3] : '';
		my $teamLead = defined($values[4]) ? $values[4] : '';
		my $scope = defined($values[5]) ? $values[5] : '';
		my $forecastDate = defined($values[6]) ? $values[6] : '';
		my $beginDate = defined($values[7]) ? $values[7] : '';
		my $endDate = defined($values[8]) ? $values[8] : '';
		my $elem = defined($values[9]) ? $values[9] : '';
		my $notes = defined($values[10]) ? $values[10] : '';
		my $issuedBy = defined($values[11]) ? $values[11] : '';
		my $status = defined($values[12]) ? $values[12] : '';
		my $completionDate = defined($values[13]) ? $values[13] : '';
		my $teamMembers = defined($values[14]) ? $values[14] : '';
		my $intExt = defined($values[15]) ? $values[15] : '';
		my $displayFy = lpadzero($year,2);
		my $displayId;
		my $defDoc;
		$teamLead = lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname",$teamLead);
		#print STDERR "fiscal year= $fy\n";
		print "<tr>\n";
		my $sql = "SELECT organization_id, location_id FROM $schema.surveillance_org_loc "
					 . "WHERE surveillance_id = $id AND fiscal_year = $year";
		#		print STDERR "$sql\n";
		my $sth = $dbh->prepare($sql);
		$sth->execute;
	  	if ($cancelled eq "" || $cancelled eq "N") {
		  	print "<tr>\n<td valign=\"top\"><font size=2>" .  &getSurvId($dbh, $issuedBy, $issuedTo, $intExt, $fy, $id) . "</font></td>\n";
	 	}		

		if ($cancelled gt "" && $cancelled eq "Y") {
			print "<td valign=\"top\"><font size=2>CANCELLED</font></td>\n";
		}
		elsif ($beginDate gt "" && $endDate gt "") {
			print "<td valign=\"top\"><font size=2>Start:  $beginDate  End:  $endDate</font></td>\n";
		}
		else {
			print "<td>&nbsp;</td>\n";
		}
		if ($completionDate gt "") {
			print "<td valign=\"top\"><font size=2>Report Approved: $completionDate</font></td>\n";
		}
		else {
			print "<td valign=\"top\"><font size=2>Report Approved:&nbsp;</font></td>\n";
		}
		print "</font></td>\n</tr>\n";
		#print "<tr><td colspan=2>";
		print "<table width=\"100%\" border=\"1\">\n";
		while (my ($orgId, $locId) = $sth->fetchrow_array) {
			print "<tr><td width=\"44%\" valign=\"top\">";
			print &getOrganization($dbh, $schema, "", "", $orgId) if ($intExt eq "I");
			print "<font size=2>$supplierhash{$orgId}</font>" if ($intExt eq "E");
			print "<td valign=\"top\" width=\"56%\">";
			print &getLocation($dbh, $schema, $locId);
			print "</td>\n</tr>\n";
		}
		print "</table></td>\n";

		$defDoc = &getDefDocs($dbh, $id, $year);
		if (defined($defDoc)) {		
			print "<td valign=\"top\" align=\"top\"><font size=2 color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Def. Docs Issued:</font></b></td>\n";
			print "<td colspan=\"5\"><font size=2>-$defDoc</font></td></tr>\n";
		}
   	if ($elem gt "") {
   		print "<tr><td width=\"16%\"><font size=\"2\" color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Program&nbsp;Elements:&nbsp;</font></td>\n";
   		print "<td colspan=\"5\"><font size=2>$elem</font></td></tr>\n";
  		}
		if ($teamLead gt "") {
			print "<tr>\n<td width=\"14%\"><font size=2 color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Lead:</b></font></td>\n";
			print "<td colspan=\"5\"><font size=\"2\">$teamLead</font></td>\n</tr>\n";
		}	
		if ($teamMembers gt "") {
			print "<tr>\n<td><font size=\"2\" color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Members:</b></td>\n";
			print "<td colspan=\"5\"><font size=\"2\">$teamMembers</font></td>\n</tr>\n";
		}
		if ($scope gt "") {
			print "<tr>\n<td valign=\"top\"><font size=2 color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Scope:</b></font></td>\n";
			print "<td colspan=\"5\"><font size=\"2\">$scope</font></td>\n</tr>\n";
		}
		if ($status gt "") {
			print "<tr>\n<td valign=\"top\"><font size=2 color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Status:</b></font></td>\n";
			print "<td colspan=\"5\"><font size=\"2\">$status</font></td>\n</tr>\n";
		}
		if ($notes gt "") {
			print "<tr>\n<td valign=\"top\"><font size=2 color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Notes:</b></font></td>\n";
			print "<td colspan=\"5\"><font size=\"2\">$notes</font></td>\n</tr>\n";
		}
		print "<tr><td colspan=\"6\"><hr></td></tr>\n";
   }
   print "</table>\n";
}

############################
sub writeSurveillanceRequest {
############################
	my ($dbh, $sql, $table, $fy) = @_;
	print "<br><table width=80% border=0 cellspacing=1 cellpadding=1 align=center>\n";
#	print "<!-- $sql\n -->";
   my $csr = $dbh->prepare($sql);
   $csr->execute;
   print "<tr bgcolor=#B0C4DE><td colspan=5 align=center><b><font color=black size=+1>Surveillance Request Browse Results</font></b></td></tr>\n";
   print "<tr bgcolor=#E6E6FA>\n";
	print "<td width=\"20%\" valign=\"top\"><b><font size=2 color=black>Organization</font></b></td>\n";
	print "<td width=\"25%\" valign=\"top\"><b><font size=2 color=black>Location</font></b></td>\n";
	print "<td valign=\"top\"><b><font size=2 color=black>Request Number</font></b></td>\n";	
	print "<td valign=\"top\"><b><font size=2 color=black>Requestor</font></b></td>\n";
	print "<td valign=\"top\"><b><font size=2 color=black>Request Date</font></b></td>\n";	
	print "</tr>\n";

   while (my @values = $csr->fetchrow_array) {
   	my $id = defined($values[0]) ? $values[0] : '###';
   	my $year = defined($values[1]) ? $values[1] : '';
   	my $requestor = defined($values[2]) ? $values[2] : "&nbsp;";
   	my $requestDate = defined($values[3]) ? $values[3] : "&nbsp";
   	my $issuedTo = defined($values[4]) ? $values[4] : '';
   	my $reason = defined($values[5]) ? $values[5] : '';
   	my $subject = defined($values[6]) ? $values[6] : '';
   	my $survId = defined($values[7]) ? $values[7] : '';
   	my $issuedBy = defined($values[8]) ? $values[8] : '';
   	my $disapprovalRationale = defined($values[9]) ? $values[9] : '';
#   	print "<!-- $sql -->\n";
      my $displayFy = lpadzero($year,2);
      my $displayId;
      my $defDoc;
   	my $sql = "SELECT organization_id, location_id FROM $schema.request_org_loc "
					 . "WHERE request_id = $id AND fiscal_year = $year";
		my $sth = $dbh->prepare($sql);
		$sth->execute;
		print "<tr>\n<td colspan=2 valign=top>";
		print "<table width=\"100%\" border=\"0\" cellspacing=1 cellpadding=1>\n";
		while (my ($orgId, $locId) = $sth->fetchrow_array) {
			print "<tr>\n<td width=\"44%\" valign=\"top\">";
			print &getOrganization($dbh, $schema, "", "", $orgId);
			print "<td valign=\"top\" width=\"56%\">";
		 	print &getLocation($dbh, $schema, $locId);
			print "</td>\n</tr>\n";
		}
		print "</table></td>\n";
		print "<td><font size=\"2\">" . &getSurvRequestId($dbh, $issuedBy, $issuedTo, $fy, $id) . "</font></td>\n";
		print "<td valign=\"top\"><font size=\"2\">$requestor</font></td>\n";
		print "<td valign=\"top\"><font size=\"2\">$requestDate</font></td>\n</tr>\n";
		print "<tr>";
   	if ($reason gt "") {
		   print "<tr>\n<td valign=\"top\" nowrap><font size=\"2\" color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Reason for<br>&nbsp;&nbsp;&nbsp;&nbsp;Request:</b></font>"
		   		. "</td><td colspan=\"3\" valign=\"bottom\"><font size=\"2\">$reason</font></td>\n</tr>\n";
   	}
   	if ($subject gt "") {
   		print "<tr>\n<td valign=\"top\" nowrap><font size=\"2\" color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Subject Detail:</b></font>"
   				. "</td><td colspan=\"3\"><font size=\"2\">$subject</font></td>\n</tr>\n";
   	}
   	if ($disapprovalRationale gt "") {
			print "<tr>\n<td valign=\"top\" nowrap><font size=\"2\" color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Disapproval Rationale:</b></font>"
					. "</td><td colspan=\"3\"><font size=\"2\">$disapprovalRationale</font></td>\n</tr>\n";
   	}
		if ($survId gt "") {
			my $sqlString = "SELECT id, TO_CHAR(begin_date, 'MM/DD/YYYY'), team_lead_id, issuedto_org_id, int_ext FROM $schema.surveillance "
					   	 . "WHERE fiscal_year = $year AND id = $survId";
			$sth = $dbh->prepare($sqlString);
			$sth->execute;
			my ($survId, $beginDate, $teamLeadId, $issuedToId, $intExt) = $sth->fetchrow_array;
			print "<tr>\n<td valign=\"top\"><font size=\"2\" color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Surveillance<br>&nbsp;&nbsp;&nbsp;&nbsp;Number:</b></font>";
			print "</td><td valign=\"bottom\"><font size=\"2\">" . &getSurvId($dbh, $issuedBy, $issuedTo, $intExt, $fy, $survId) . "</font></td></tr>\n";
			if (defined($beginDate) && $beginDate gt "") {                 
				print "<tr>\n<td valign=\"top\"><font size=\"2\" color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Begin Date:</b></font>";
				print "</td><td><font size=\"2\">$beginDate</font></td>\n</tr>\n";
			}
			if (defined($teamLeadId) && $teamLeadId != 0) {
				$sqlString = "SELECT firstname || ' ' || lastname FROM $schema.users "
								 . "WHERE id = $teamLeadId";
				my $sth1 = $dbh->prepare($sqlString);
				$sth1->execute;
				my $teamLead = $sth1->fetchrow_array;
				print "<tr>\n<td valign=\"top\"><font size=\"2\" color=black><b>&nbsp;&nbsp;&nbsp;&nbsp;Team Lead:</b></font>";
				print "</td><td><font size=\"2\">$teamLead</font></td></tr>\n";
			}
		}
   	print "<tr><td colspan=\"5\"><hr></td></tr>";
	}
}

############################
sub selectLocations {
############################
	my ($name) = @_;
	my ($array_ref, $loc);
	print "<li>Location &nbsp;&nbsp;<select name=$name size=1>\n";
	print "<option value=0>(all)\n";
	foreach $array_ref (@locresults) { 
		$loc = "";
		if (@$array_ref[0]) {$loc .= @$array_ref[0] . ', ';}
		if (@$array_ref[1]) {$loc .= @$array_ref[1] . ', ';}
		if (@$array_ref[2]) {$loc .= @$array_ref[2];}
		if (defined(@$array_ref[3]) && @$array_ref[3] ne 'USA') {$loc .=  @$array_ref[3];}
		print "<option value=\"@$array_ref[4]\">$loc\n";
	}
	print "</select></li></td>\n";
}
############################
sub selectSuborganizations {
############################
   my ($name) = @_;
	print "<li>Suborganization&nbsp;&nbsp;<select name=$name size=1 onChange='{ if (value != 0) document.$form.survtype[0].checked=true;}' disabled>\n";
	print "<option value=0>(all)\n";
	foreach my $key (keys %suborghash) {
		print "<option value=\"$key\">$suborghash{$key}\n";
	}
	print "</select></li><i>&nbsp;(BSC only)</i>\n";
}
############################
sub selectOrganizations {
############################
   my ($name) = @_;
	print "<li>Organization&nbsp;&nbsp;<select name=$name size=1 onChange='{ if (value != 0) document.$form.survtype[0].checked=true; if (value != 1) document.$form.survsuborg[0].selected=true; document.$form.survsuborg.disabled=true; if (value==1) document.$form.survsuborg.disabled=false;}'>\n";
	print "<option value=0>(all)\n";
	foreach my $key (keys %orghash) {
		print "<option value=\"$key\">$orghash{$key}\n";
	}
	print "</select></li>\n";
}
############################
sub selectSuppliers {
############################
	my ($name) = @_;
	print "<li>Supplier&nbsp;&nbsp;<select name=$name onChange='{ if (value != 0) document.$form.survtype[1].checked=true;}'>\n";
	print "<option value=0>(all)\n";
	foreach my $keys (keys %supplierhash) {
		print "<option value=$keys>$supplierhash{$keys}\n";
	}
	print "</select></li>";
}

############################
sub selectIssuedBy {
############################
	my ($name, $table) = @_;
	my $sql = "select distinct(abbr), org.id from $schema.$table, "
	          . "organizations org WHERE org.id = issuedby_org_id";
#		print STDERR "$sql\n";
	my $csr = $dbh -> prepare($sql);
	$csr -> execute;
	print "<li>Issued&nbsp;By&nbsp;&nbsp;\n";
	print "<select name=$name size=1>\n";
	print "<option value=0>(all)\n";
	while (my @values = $csr -> fetchrow_array) {
		print "<option value=$values[1]>$values[0]\n";
	}
	$csr -> finish;
 	print "</select></li>\n";
}

############################
sub selectIssuedTo {
############################
	my ($name, $table) = @_;
	my $sql = "select distinct(abbr), org.id from $schema.$table, "
	          . "organizations org WHERE org.id = issuedto_org_id";
		print STDERR "$sql\n";
	my $csr = $dbh -> prepare($sql);
	$csr -> execute;
	print "<li>Issued&nbsp;To&nbsp;&nbsp;\n";
	print "<select name=$name size=1>\n";
	print "<option value=0>(all)\n";
	while (my @values = $csr -> fetchrow_array) {
		print "<option value=$values[1]>$values[0]\n";
	}
	$csr -> finish;
 	print "</select></li>\n";
}

############################
sub selectFiscalYears {
############################
	my ($name, $bgcolor) = @_;
	$csr = $dbh -> prepare ("select fiscal_year from $schema.fiscal_year order by fiscal_year desc");
	$csr -> execute;
	print "<b>for&nbsp;Fiscal&nbsp;Year&nbsp;&nbsp;</b></b>\n";
   print "<select name=$name size=1 >\n";
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
}
############################
sub selectTeamLeads {
############################
	my ($name) = @_;
	print "<li>Team&nbsp;Lead&nbsp;&nbsp;<select name=$name size=1>\n"; 
	print "<option value=0>(all)\n";
	foreach my $keys (keys %leadhash) {
		print "<option value=\"$keys\">$leadhash{$keys}\n";
	}
	print "</select></li>\n";
	
}
############################
sub selectBeginMonths {
############################
	my ($name, $label) = @_;
	print <<END_of_beginMonths;
	<li>$label<select name=$name size=1>
		<option selected value=0>(all) 
		<option value=10>October
		<option value=11>November
		<option value=12>December
		<option value=1>January
		<option value=2>February
		<option value=3>March
		<option value=4>April
		<option value=5>May
		<option value=6>June
		<option value=7>July
		<option value=8>August
		<option value=9>September
		</select></li></td>
END_of_beginMonths
}

############################
sub selectRequestors {
############################
	my $name = $_[0];
	my $sql = "SELECT distinct(requestor) FROM $schema.surveillance_request";
	my $sth = $dbh->prepare($sql);
	$sth->execute;
	print "<li>Requestor&nbsp;&nbsp;<select name=$name>\n";
	print "<option value=0>(all)\n";
	while (my $requestor = $sth->fetchrow_array) {
		print "<option value='$requestor'>$requestor\n";
	}
	print "</select></li>";
}
###################################################################################################################################
sub writeQARDcheckbox {  # routine to write the checkboxes for QARD elements 
###################################################################################################################################
     my %args = (
        qard => '000000000000000000000000', 
        name => 'qardElement',
        @_,
     );
     my $i = 0;
     my $j = 0;
     my $output = "<table cellpadding=0 cellspacing=1 border=0 width=100% align=center>\n";
     $output .= "<tr><td colspan=9><font size=-1><b><li>QARD Elements <i>(only applies to fiscal year 2004 and later)</i>:</b></font></td></tr>\n";
     foreach my $element ("1.0","2.0", "3.0", "4.0", "5.0", "6.0", "7.0", "8.0", "9.0", "10.0", "11.0", "12.0", "13.0",
	"14.0", "15.0", "16.0", "17.0", "18.0", "SI", "SII", "SIII", "SIV", "SV", "App C") {
		$i++;
     		if ($i == 13) {
     			$i = 1;
     			$output .= "</tr>\n<tr>";
		}
		$output .= "<td><font size=-1><b><input type=checkbox name=$args{name} value=$j>$element</font></b></td>\n";
		$j++;
     }
     $output .= "</tr></table>\n";
     return($output);
}
############################
sub internalAuditSearch {
############################
#	print "<br>\n";
	print "<table id=internaltable border=1 width=700 align=center style=display:none rules=none>\n";
	print "<tr><td align=center colspan=3><b>Internal Audits</b></td></tr>\n";
	print	"<tr><td width=27%><b><font size=-1><li>Type&nbsp;&nbsp;<select name=intaudittype size=1>\n";
	print	"<option value='internal'>All Internal\n";
	print	"<option value='C'>C\n";
	print	"<option value='P'>P\n";
	print	"<option value='PB'>PB\n";
	print	"<option value='P/PB'>P/PB\n";
	print	"</select></li></font></b></td>\n";
	print "<td width=28%><b><font size=-1>\n";
	&selectIssuedBy('intissuedby', 'internal_audit');
	print "</font></b></td>\n<td><b><font size=-1>";
	&selectTeamLeads('intlead');
	print "</font></b></td></tr>\n";
	print "<tr><td colspan=3><b><font size=-1>\n";
	&selectOrganizations('org');
	print "</font></b></td></tr>\n";
	print "<tr><td colspan=3><b><font size=-1>\n";
	&selectSuborganizations('suborg');
	print "</font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>Start Date:</font></b></td>\n";
	print "<td><b><font size=-1>From:&nbsp;<input type=text name=intstartfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	print "<td><b><font size=-1>To:&nbsp;<input type=text name=intstartto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>End Date:</font></b></td>\n";
	print "<td><b><font size=-1>From:&nbsp;<input type=text name=intendfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	print "<td><b><font size=-1>To:&nbsp;<input type=text name=intendto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>Report Approved Date:</font></b></td>\n";
	print "<td><b><font size=-1>From:&nbsp;<input type=text name=intapprovedfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	print "<td><b><font size=-1>To:&nbsp;<input type=text name=intapprovedto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	print "<tr>\n<td colspan=2><b><font size=-1>";
	&selectLocations('intloc');
	print "</font></b><td><b><font size=-1>\n";
	&selectBeginMonths('intbeginmonth', 'Forecast&nbsp;/&nbsp;Begin&nbsp;Month&nbsp;&nbsp;');
	print "</font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>Adequacy&nbsp;" . &writeResultsSelect(name=>'intAdequacy') . "</font></b></td>\n";
	print "<td><b><font size=-1><li>Implementation&nbsp;" . &writeResultsSelect(name=>'intImplementation') . "</font></b></td>\n";
	print "<td><b><font size=-1><li>Effectiveness&nbsp;" . &writeResultsSelect(name=>'intEffectiveness') . "</font></b></td></tr>\n";
	print "<tr><td colspan=3>" . &writeQARDcheckbox(name=>'intQardElement') . "</td></tr>\n";
	print "<tr><td bgcolor=#E6E6FA>\n";
	&selectFiscalYears('intfy','#CCEEFF');
	print "</td>\n<td colspan=2 align=right><b><font size=-1 color=black>Report Type:&nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=intoutput value=abbreviated>Abbreviated&nbsp;&nbsp;&nbsp;\n";
	print "<input type=radio name=intoutput value=standard default checked>Standard&nbsp;&nbsp;&nbsp;\n";
	print "<input type=radio name=intoutput value=expanded>Expanded&nbsp;&nbsp;</font></b></td></tr>\n";
	print "</table>\n";
#	print "<br>\n";

}
############################
sub internalAuditSearch_old {
############################
#	print "<br>\n";
	print "<table id=internaltable border=1 width=700 align=center style=display:none rules=none>\n";
	print "<tr><td align=center colspan=3><b>Internal Audits</b></td></tr>\n";
	print	"<tr><td width=27%><li>Type&nbsp;&nbsp;<select name=intaudittype size=1>\n";
	print	"<option value='internal'>All Internal\n";
	print	"<option value='C'>C\n";
	print	"<option value='P'>P\n";
	print	"<option value='PB'>PB\n";
	print	"<option value='P/PB'>P/PB\n";
	print	"</select></li></td>\n";
	print "<td width=28%>\n";
	&selectIssuedBy('intissuedby', 'internal_audit');
	print "</td>\n<td>";
	&selectTeamLeads('intlead');
	print "</td></tr>\n";
	print "<tr><td colspan=3>\n";
	&selectOrganizations('org');
	print "</td></tr>\n";
	print "<tr>\n<td colspan=2>";
	&selectLocations('intloc');
	print "<td>\n";
	&selectBeginMonths('intbeginmonth', 'Forecast&nbsp;/&nbsp;Begin&nbsp;Month&nbsp;&nbsp;');
	print "</tr>\n<tr><td colspan=3 bgcolor=#E6E6FA>\n";
	&selectFiscalYears('intfy','#CCEEFF');
	print "</td></tr>\n";
	print "</td></tr></table>\n";
#	print "<br>\n";

}
############################
sub externalAuditSearch {
############################
# 	print "<br>\n";
	print "<table id=externaltable border=1 width=700 align=center style=display:none rules=none>\n";
	print "<tr><td align=center colspan=3><b>External Audits</b></td></tr>\n";
	print "<tr><td width=27%><b><font size=-1><li>Type&nbsp;&nbsp;<select name=extaudittype size=1>\n";
	print "	<option value='external'>All External\n";
	print "	<option value='SA'>SA\n";
	print "	<option value='SFE'>SFE\n";
	print "	</select></li></font></b></td>\n";
	print "<td width=28%>\n<b><font size=-1>";
	&selectIssuedBy('extissuedby', 'external_audit');
	print "</font></b></td>\n<td><b><font size=-1>";
	&selectTeamLeads('extlead');
	print "</font></b></td></tr>\n";
	print "<tr><td colspan=3><b><font size=-1>\n";
   	&selectSuppliers('extsupplier');
   	print "</font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>Start Date:</font></b></td>\n";
	print "<td><b><font size=-1>From:&nbsp;<input type=text name=extstartfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	print "<td><b><font size=-1>To:&nbsp;<input type=text name=extstartto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>End Date:</font></b></td>\n";
	print "<td><b><font size=-1>From:&nbsp;<input type=text name=extendfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	print "<td><b><font size=-1>To:&nbsp;<input type=text name=extendto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>Report Approved Date:</font></b></td>\n";
	print "<td><b><font size=-1>From:&nbsp;<input type=text name=extapprovedfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	print "<td><b><font size=-1>To:&nbsp;<input type=text name=extapprovedto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
   	print "<tr>\n<td colspan=2><b><font size=-1>";
	&selectLocations('extloc');
	print "</font></b><td><b><font size=-1>\n";
	&selectBeginMonths('extbeginmonth', 'Forecast&nbsp;/&nbsp;Begin&nbsp;Month&nbsp;&nbsp;');
	print "</font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>Adequacy&nbsp;" . &writeResultsSelect(name=>'extAdequacy') . "</font></b></td>\n";
	print "<td><b><font size=-1><li>Implementation&nbsp;" . &writeResultsSelect(name=>'extImplementation') . "</font></b></td>\n";
	print "<td><b><font size=-1><li>Effectiveness&nbsp;" . &writeResultsSelect(name=>'extEffectiveness') . "</font></b></td></tr>\n";
	print "<tr><td colspan=3>" . &writeQARDcheckbox(name=>'extQardElement') . "</td></tr>\n";	
	print "<tr><td bgcolor=#E6E6FA>\n";
	&selectFiscalYears('extfy','#DDAAFF');
	print "</td>\n<td colspan=2 align=right><b><font size=-1 color=black>Report Type:&nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=extoutput value=abbreviated>Abbreviated&nbsp;&nbsp;&nbsp;\n";
	print "<input type=radio name=extoutput value=standard default checked>Standard&nbsp;&nbsp;&nbsp;\n";
	print "<input type=radio name=extoutput value=expanded>Expanded&nbsp;&nbsp;</font></b></td></tr>\n";
	print "</table>\n";
}
############################
sub externalAuditSearch_old {
############################
# 	print "<br>\n";
	print "<table id=externaltable border=1 width=700 align=center style=display:none rules=none>\n";
	print "<tr><td align=center colspan=3><b>External Audits</b></td></tr>\n";
	print "<tr><td width=27%><li>Type&nbsp;&nbsp;<select name=extaudittype size=1>\n";
	print "	<option value='external'>All External\n";
	print "	<option value='SA'>SA\n";
	print "	<option value='SFE'>SFE\n";
	print "	</select></li></td>\n";
	print "<td width=28%>\n";
	&selectIssuedBy('extissuedby', 'external_audit');
	print "</td>\n<td>";
	&selectTeamLeads('extlead');
	print "</td></tr>\n";
	print "<tr><td colspan=3>\n";
   	&selectSuppliers('extsupplier');
   	print "<tr>\n<td colspan=2>";
	&selectLocations('extloc');
	print "<td>\n";
	&selectBeginMonths('extbeginmonth', 'Forecast&nbsp;/&nbsp;Begin&nbsp;Month&nbsp;&nbsp;');
	print "</tr><tr><td colspan=3 bgcolor=#E6E6FA>\n";
	&selectFiscalYears('extfy','#DDAAFF');
   	print "</td></tr>\n";
	print "</table>\n";
}

############################
sub auditSearch {
############################
# 	print "<br>\n";
	print "<table id=audittable border=1 cellpadding=4 width=700 align=center style=display:none rules=none>\n";
	print "<tr><td align=center colspan=3><b>Browse <input type=checkbox name=audittype value='I' checked onClick='{ if (!checked) document.$form.auditorg.options[0].selected=true;  document.$form.auditsuborg.options[0].selected=true; document.$form.auditsuborg.disabled=true;}'><b><font size=-1>Internal</font>\n";
	print "<input type=checkbox name=audittype value='E' checked onClick='{ if (!checked) document.$form.auditsupplier.options[0].selected=true;}'><b><font size=-1>External</font>&nbsp;&nbsp;Audits</b></td></tr>\n";
	print "<tr><td colspan=3><b><font size=-1>\n";
	&selectOrganizations('auditorg');
	print "</font></b></td></tr>\n";
	print "<tr><td colspan=3><b><font size=-1>\n";
	&selectSuborganizations('auditsuborg');
	print "</font></b></td></tr>\n";
	print "<tr><td colspan=3><b><font size=-1>\n";
	&selectSuppliers('auditsupplier');
	print "</font></b></td></tr>\n";
   	print "<tr><td><b><font size=-1>\n";
	&selectIssuedBy('internalissuedby', 'internal_audit');
	print "</font></b></td>\n<td><b><font size=-1>";
	&selectIssuedTo('auditissuedto', 'internal_audit');
	print "</font></b></td>\n<td><b><font size=-1>\n";
	&selectTeamLeads('lead');
	print "<font></b></td></tr>\n";	
   	print "<tr><td><b><font size=-1>\n";
	&selectIssuedBy('externalissuedby', 'external_audit');
	print "</font></b></td>\n<td><b><font size=-1>";
	&selectIssuedTo('auditissuedto', 'external_audit');
	print "</font></b></td>\n<td><b><font size=-1>\n";
	&selectTeamLeads('lead');
	print "<font></b></td></tr>\n";	
	#print "<tr><td><b><font size=-1><li>Forecast Start Date:</font></b></td>\n";
	#print "<td><b><font size=-1>From:&nbsp;<input type=text name=forecastfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	#print "<td><b><font size=-1>To:&nbsp;<input type=text name=forecastto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	#print "<tr><td><b><font size=-1><li>Forecast End Date:<font></b></td>\n";
	#print "<td><b><font size=-1>From:&nbsp;<input type=text name=forecastendfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	#print "<td><b><font size=-1>To:&nbsp;<input type=text name=forecastendto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>Start Date:</font></b></td>\n";
	print "<td><b><font size=-1>From:&nbsp;<input type=text name=startfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	print "<td><b><font size=-1>To:&nbsp;<input type=text name=startto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>End Date:</font></b></td>\n";
	print "<td><b><font size=-1>From:&nbsp;<input type=text name=endfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	print "<td><b><font size=-1>To:&nbsp;<input type=text name=endto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>Report Approved Date:</font></b></td>\n";
	print "<td><b><font size=-1>From:&nbsp;<input type=text name=approvedfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	print "<td><b><font size=-1>To:&nbsp;<input type=text name=approvedto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	print "<tr>\n<td colspan=3><b><font size=-1>\n";
	&selectLocations('auditloc');
	print "</font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>Adequacy&nbsp;" . &writeResultsSelect(name=>'adequacy') . "</font></b></td>\n";
	print "<td><b><font size=-1><li>Implementation&nbsp;" . &writeResultsSelect(name=>'implementation') . "</font></b></td>\n";
	print "<td><b><font size=-1><li>Effectiveness&nbsp;" . &writeResultsSelect(name=>'effectiveness') . "</font></b></td></tr>\n";
	print "<tr><td colspan=3>" . &writeQARDcheckbox . "</td></tr>\n";
	print "<tr>\n<td bgcolor=#E6E6FA>\n";
	&selectFiscalYears('auditfy','#66FFCC');
	print "</td>\n<td colspan=2 align=right><b><font size=-1 color=black>Report Type:&nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=auditoutput value=abbreviated>Abbreviated&nbsp;&nbsp;&nbsp;\n";
	print "<input type=radio name=auditoutput value=standard default checked>Standard&nbsp;&nbsp;&nbsp;\n";
	print "<input type=radio name=auditoutput value=expanded>Expanded&nbsp;&nbsp;</font></b></td></tr>\n";
	print "</table>\n";
}

############################
sub survSearch {
############################
# 	print "<br>\n";
	print "<table id=survtable border=1 cellpadding=4 width=700 align=center style=display:none rules=none>\n";
	print "<tr><td align=center colspan=3><b>Browse <input type=checkbox name=survtype value='I' checked onClick='{ if (!checked) document.$form.survorg.options[0].selected=true;  document.$form.survsuborg.options[0].selected=true; document.$form.survsuborg.disabled=true;}'><b><font size=-1>Internal</font>\n";
	print "<input type=checkbox name=survtype value='E' checked onClick='{ if (!checked) document.$form.survsupplier.options[0].selected=true;}'><b><font size=-1>External</font>&nbsp;&nbsp;Surveillances</b></td></tr>\n";
	print "<tr><td colspan=3><b><font size=-1>\n";
	&selectOrganizations('survorg');
	print "</font></b></td></tr>\n";
	print "<tr><td colspan=3><b><font size=-1>\n";
	&selectSuborganizations('survsuborg');
	print "</font></b></td></tr>\n";
	print "<tr><td colspan=3><b><font size=-1>\n";
	&selectSuppliers('survsupplier');
	print "</font></b></td></tr>\n";
   	print "<tr><td><b><font size=-1>\n";
	&selectIssuedBy('survissuedby', 'surveillance');
	print "</font></b></td>\n<td><b><font size=-1>";
	&selectIssuedTo('survissuedto', 'surveillance');
	print "</font></b></td>\n<td><b><font size=-1>\n";
	&selectTeamLeads('lead');
	print "<font></b></td></tr>\n";	
	#print "<tr><td><b><font size=-1><li>Forecast Start Date:</font></b></td>\n";
	#print "<td><b><font size=-1>From:&nbsp;<input type=text name=forecastfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	#print "<td><b><font size=-1>To:&nbsp;<input type=text name=forecastto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	#print "<tr><td><b><font size=-1><li>Forecast End Date:<font></b></td>\n";
	#print "<td><b><font size=-1>From:&nbsp;<input type=text name=forecastendfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	#print "<td><b><font size=-1>To:&nbsp;<input type=text name=forecastendto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>Start Date:</font></b></td>\n";
	print "<td><b><font size=-1>From:&nbsp;<input type=text name=startfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	print "<td><b><font size=-1>To:&nbsp;<input type=text name=startto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>End Date:</font></b></td>\n";
	print "<td><b><font size=-1>From:&nbsp;<input type=text name=endfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	print "<td><b><font size=-1>To:&nbsp;<input type=text name=endto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>Report Approved Date:</font></b></td>\n";
	print "<td><b><font size=-1>From:&nbsp;<input type=text name=approvedfrom maxlength=10 onBlur=checkDate(value,this)></font></b></td>\n";
	print "<td><b><font size=-1>To:&nbsp;<input type=text name=approvedto maxlength=10 onBlur=checkDate(value,this)></font></b></td></tr>\n";
	print "<tr>\n<td colspan=3><b><font size=-1>\n";
	&selectLocations('survloc');
	print "</font></b></td></tr>\n";
	print "<tr><td><b><font size=-1><li>Adequacy&nbsp;" . &writeResultsSelect(name=>'adequacy') . "</font></b></td>\n";
	print "<td><b><font size=-1><li>Implementation&nbsp;" . &writeResultsSelect(name=>'implementation') . "</font></b></td>\n";
	print "<td><b><font size=-1><li>Effectiveness&nbsp;" . &writeResultsSelect(name=>'effectiveness') . "</font></b></td></tr>\n";
	print "<tr><td colspan=3>" . &writeQARDcheckbox(name=>'qardElement') . "</td></tr>\n";
	print "<tr>\n<td bgcolor=#E6E6FA>\n";
	&selectFiscalYears('survfy','#66FFCC');
	print "</td>\n<td colspan=2 align=right><b><font size=-1 color=black>Report Type:&nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=output value=abbreviated>Abbreviated&nbsp;&nbsp;&nbsp;\n";
	print "<input type=radio name=output value=standard default checked>Standard&nbsp;&nbsp;&nbsp;\n";
	print "<input type=radio name=output value=expanded>Expanded&nbsp;&nbsp;</font></b></td></tr>\n";
	print "</table>\n";
}

############################
sub survReqSearch {
############################
#	print "<br>\n";
	print "<table id=survreqtable border=1 width=700 align=center style=display:none rules=none>\n";
	print "<tr><td align=center colspan=3><b>Surveillance Requests</b></td></tr>\n";
   print "<tr><td>\n";
	&selectIssuedBy('survreqissuedby', 'internal_audit');
	print "</td>\n<td>";
	&selectRequestors('requestor');
	print "<td>\n";
	&selectBeginMonths('reqmonth', 'Request&nbsp;Month&nbsp;');
	print "</tr>\n";
	print "<tr><td colspan=3>";
	&selectOrganizations('survreqorg');
	print "</td></tr>\n";
	print "<tr>\n<td width=60% colspan=3>\n";
	&selectLocations('survreqloc');
	print "</tr>\n";
	print "<tr>\n<td colspan=3 bgcolor=#E6E6FA>\n";
	&selectFiscalYears('survreqfy','#66FFCC');
	print "</table>\n";
}

############################
sub searchCount {
############################
	my ($sqlstring) = @_;
	my $csr;
	my @values;
#   print STDERR "$sqlstring\n";
	$csr = $dbh->prepare($sqlstring);
	$csr->execute;

	@values = $csr->fetchrow_array;
	my $count = $values[0];
	
	return ($count);
}

############################
sub getPrivileges {
############################
	my ($dbh, $schema) = @_;
	my $privRef = $dbh->selectall_arrayref("SELECT id, privilege FROM $schema.privilege ORDER BY privilege");
	return ($privRef);
}

############################
sub getIssuedByOrg {
############################
	my ($dbh, $schema, $id) = @_;
	my $sth = $dbh->prepare("SELECT abbr FROM $schema.organizations where id = $id");
	$sth->execute;
	my $abbr = $sth->fetchrow_array;
	return ($abbr);
}

############################
sub getUsers {
############################
	my ($dbh, $schema, $whereClause) = @_;
	my ($sql, $sth, $userRef);
	$sql = "SELECT firstname || ' ' || lastname AS name, username, location, organization, id, isactive FROM "
	       . "$schema.users " . $whereClause . " ORDER BY lastname";
	$userRef = $dbh->selectall_arrayref($sql);
	return ($userRef);
}

############################
sub getUsersByPrivilege {
############################
	my ($dbh, $schema, $privId) = @_;
	my ($sql, $sth, $userRef);
	$sql = "SELECT firstname || ' ' || lastname AS name, username, location, organization, id FROM "
	       . "$schema.users a, user_privilege b WHERE b.privilege = $privId AND "
	       . "a.id = b.userid ORDER BY lastname";
	$userRef = $dbh->selectall_arrayref($sql);
	return ($userRef);
}

############################
sub getUserInfo {
############################
	my ($dbh, $schema, $id) = @_;
	my ($sql, $sth, $userInfoRef, $userPrivRef);
	tie my %userNameHistory, "Tie::IxHash";
	$sql = "SELECT firstname || ' ' || lastname AS name, username, location, organization, "
			 . "areacode, phonenumber, email, user_id_history FROM $schema.users WHERE id = $id";
	$userInfoRef = $dbh->selectall_arrayref($sql);
	$sql = "SELECT id, a.privilege FROM $schema.privilege a, $schema.user_privilege b WHERE b.userid = $id "
	       . " AND b.privilege = a.id ORDER BY privilege";
	$userPrivRef = $dbh->selectall_arrayref($sql);
	my $info = @$userInfoRef[0];
	my @ids = split(/,/,@$info[7]);
	foreach my $id (@ids) {
		my $sqlstring = "SELECT firstname || ' ' || lastname AS name, isactive FROM $SCHEMA.users WHERE id = $id";
		my $rc = $dbh->prepare($sqlstring);
		$rc->execute;
		my ($name, $isactive) = $rc->fetchrow_array;
		$userNameHistory{$name} = $isactive;
	}
	return ($userInfoRef, $userPrivRef, \%userNameHistory);
}

###############################
sub displayUsers {
###############################
	my $privRef = &getPrivileges($dbh, $schema);
	my ($priv, $userInfo, $bgColor, $userRef);
	tie my %userHash, "Tie::IxHash";
	my $i = 0;
	my $mid = @$privRef / 2;
	$mid -= 2;
	print "<br>\n<a name=top></a>\n<ul>\n<center>\n<table width=700 border=0 style=display:none>\n<tr>\n";
	print "<td valign=top><li><b><a href=\"#Alphabetical Listing of Active System Users\">Alphabetical Listing of Active System Users</a></li>\n";
	print "<li><b><a href=\"#Alphabetical Listing of Inactive System Users\">Alphabetical Listing of Inactive System Users</a></li>\n";	
	print "<li><b><a href=\"#Alphabetical Listing of All Users\">Alphabetical Listing of All Users</a></li>\n";
	for $priv (@$privRef) {
		@$priv[1] = "Software @$priv[1]" if (@$priv[1] eq "Developer");
		print "<li><a href=\"#@$priv[1]\">@$priv[1]</a></li>\n";
		if ($i == $mid) {
			print "</td>\n<td valign=top><b>";
		}
		$i++;
	}
	my @tdColors = ('#ffc0ff', '#fabaaa', '#c0c0ff', '#c0ffc0', '#ffffc0', '#f0e0b0',  '#c0ffff');
	$userHash{'Alphabetical Listing of Active System Users'} = "WHERE isactive = 'T'";
	$userHash{'Alphabetical Listing of Inactive System Users'} = "WHERE isactive = 'F'";
	$userHash{'Alphabetical Listing of All Users'} = "";
	while (my ($heading, $whereClause) = each(%userHash)) {
		my $tdColor = shift(@tdColors);
		print "</td>\n</tr>\n</table>\n</ul>\n<a name=\"$heading\"></a>\n";
		print "<br>\n<table border=1 cellspacing=0 cellpadding=3 width=750 bordercolor=\"#c0c0c0\" style=display:none>\n";
		print "<tr>\n<td bgcolor=\"$tdColor\" colspan=5><b>$heading</b></td>\n";
		print "</tr>\n<tr>\n";
		print "<td><b>Name</b></td>\n";
		print "<td><b>User Name</b></td>\n";
		print "<td><b>Location</b></td>\n";
		print "<td><b>Organization</b></td>\n";
		if ($heading eq 'Alphabetical Listing of All Users') {
			print "<td><b>Activity Status</b></td>\n";
		}
		print "<tr>\n";
		$userRef = &getUsers($dbh, $schema, $whereClause);
		$i = 0;
		for $userInfo (@$userRef) {
			if ($i % 2 == 0) {
				$bgColor = "#ffffff";
			}
			print "<tr>\n<td bgcolor=$bgColor><font size=2><a href=\"javascript:submitFormView('$form', 'view_user', '@$userInfo[4]')\">@$userInfo[0]</a></font></td>\n";
			if (!(defined(@$userInfo[2]))) {
				@$userInfo[2] = "&nbsp;";
			}
			if (!(defined(@$userInfo[3]))) {
				@$userInfo[3] = "&nbsp;";
			}		
			print "<td bgcolor=$bgColor><font size=2>@$userInfo[1]</font></td>\n";
			print "<td bgcolor=$bgColor><font size=2>@$userInfo[2]</font></td>\n";
			print "<td bgcolor=$bgColor><font size=2>@$userInfo[3]</font></td>\n";
			if ($heading eq 'Alphabetical Listing of All Users') {
				print "<td bgcolor=$bgColor><font size=2>";
				if (@$userInfo[5] eq 'T') {
					print "Active";
				}
				else {
					print "Inactive";
				}
				print "</font></td>\n";
			}
			print "</tr>\n";
			$i++;
			$bgColor = "#eeeeee";
		}
		push(@tdColors, $tdColor);
		print "<tr>\n<td colspan=5 align=center><a href=#top><b>Back to Top</b></a></td>\n</tr>\n</table>\n";
	}
	#print "<tr>\n<td colspan=4 align=center><a href=#top><b>Back to Top</b></a></td>\n</tr>\n</table>\n";
	for $priv (@$privRef) {
		my $tdColor = shift(@tdColors);
		print "<!-- $tdColor -->\n";
		print "<br>\n<a name=\"@$priv[1]\"></a>\n";
		print "<table border=1 cellspacing=0 cellpadding=3 width=750 bordercolor=\"#c0c0c0\" border=1 style=display:none>\n";
		print "<tr>\n<td bgcolor=\"$tdColor\" colspan=4><b>@$priv[1]</b></td>\n</tr>\n";
		print "<tr>\n<td><b>Name</b></td>\n";
		print "<td><b>User Name</b></td>\n";
		print "<td><b>Location</b></td>\n";
		print "<td><b>Organization</b></td>\n</tr>\n";
		$userRef = &getUsersByPrivilege($dbh, $schema, @$priv[0]);
		for $userInfo (@$userRef) {
			if ($i % 2 == 0) {
				$bgColor = "#ffffff";
			}
			print "<!-- @$priv[0] -->\n";
			print "<tr>\n<td bgcolor=$bgColor><font size=2><a href=\"javascript:submitFormView('$form', 'view_user', '@$userInfo[4]')\">@$userInfo[0]</a></font></td>\n";
			print "<td bgcolor=$bgColor><font size=2>@$userInfo[1]</font></td>\n";
			if (!(defined(@$userInfo[2]))) {
				@$userInfo[2] = "&nbsp;";
			}
			if (!(defined(@$userInfo[3]))) {
				@$userInfo[3] = "&nbsp;";
			}
			print "<td bgcolor=$bgColor><font size=2>@$userInfo[2]</font></td>\n";
			print "<td bgcolor=$bgColor><font size=2>@$userInfo[3]</font></td>\n</tr>\n";
			$i++;
			$bgColor = "#eeeeee";
		}
		push(@tdColors, $tdColor);
		print "<tr>\n<td colspan=4 align=center><a href=#top><b>Back to Top</b></a></td>\n</tr>\n</table>\n";
	}
	print "</center>\n";
	print "<input type=hidden name=viewuserid value=''>\n";

}

print <<END_of_Multiline_Text;
Content-type: text/html

<HTML>
<HEAD>
<script src=$NQSJavaScriptPath/utilities.js></script>
<Title>Quality Assurance - Audit and Surveillance Schedule System</Title>
<script language="JavaScript1.1">
<!--
	function submitForm (script, command, id) {
		document.$form.cgiaction.value = command;
		document.$form.action = '$path' + script + '.pl';
		document.$form.target = 'workspace';
		document.$form.submit();
	}
	function submitFormView (script, command, id) {
		document.$form.viewuserid.value = id;
		submitForm (script, command);
 	}
  	function display (f) {
   	if (document.all.survtable.style.display == 'block') {
 	   	document.$form.browsesurv.value = 'TRUE'
 		}
 		else {
 	   	document.$form.browsesurv.value = 'FALSE' 	
 		}
 //  	if (document.all.survreqtable.style.display == 'block') {
 //	   	document.$form.browsesurvreq.value = 'TRUE'
 //		}
 //		else {
 //	   	document.$form.browsesurvreq.value = 'FALSE' 	
 //		}
   	if (document.all.internaltable.style.display == 'block') {
	   	document.$form.browseinternal.value = 'TRUE'
		}
		else {
	   	document.$form.browseinternal.value = 'FALSE'	
		}
   	if (document.all.externaltable.style.display == 'block') {
	   	document.$form.browseexternal.value = 'TRUE'
		}
		else {
	   	document.$form.browseexternal.value = 'FALSE'		
		}
   	//if (document.all.audittable.style.display == 'block') {
	//   	document.$form.browseaudit.value = 'TRUE'
	//	}
	//	else {
	//   	document.$form.browseaudit.value = 'FALSE'		
	//	}
   	document.$form.cgiaction.value = 'build_query';
   	document.$form.action = '$path' + f.name + '.pl';
   	document.$form.target = 'control';
   	document.$form.submit();
	}
	function submitAuditShow() {
 		if (document.all.internaltable.style.display == 'none' && document.all.externaltable.style.display == 'none') {
 			document.all.submit_button.style.display = 'none';
 		}
 		else {
 			document.all.submit_button.style.display = 'block';
		} 		
 	}
 	function hideUser() {
 		var tableArray = document.all.tags('table');
 		document.$form.user.checked = false;
 		for (var i = 5; i < tableArray.length; i++) {
 			tableArray[i].style.display = 'none';
 		}
 	}
  	function submitShow() {
  		if (document.all.survtable.style.display == 'none' //&& document.all.survreqtable.style.display == 'none'
  			&& document.all.internaltable.style.display == 'none' && document.all.externaltable.style.display == 'none') {
  			document.all.submit_button.style.display = 'none';
  		}
  		else {
  			document.all.submit_button.style.display = 'block';
 		} 		
  	}
	function browseInternal() {
 		hideUser();
 		if (document.$form.internal.checked == true) {
 	  		document.all.internaltable.style.display = 'block';
 		}
 		else {
 			document.all.internaltable.style.display = 'none';
		}
		submitShow();
 	}
	function browseExternal() {
 		hideUser();
 		if (document.$form.external.checked == true) {
 	  		document.all.externaltable.style.display = 'block';
 		}
 		else {
 			document.all.externaltable.style.display = 'none';
		}
		submitShow();
 	}
// 	function browseAudit() {
//  		hideUser();
//  		if (document.$form.audit.checked == true) {
//  	  		document.all.audittable.style.display = 'block';
//  		}
//  		else {
//  			document.all.audittable.style.display = 'none';
//		}
// 		submitShow();
//	}
	function browseSurv() {
 		hideUser();
 		if (document.$form.surv.checked == true) {
 	  		document.all.survtable.style.display = 'block';
 		}
 		else {
 			document.all.survtable.style.display = 'none';
		}
		submitShow();
	}
//	function browseSurvReq() {
// 		hideUser();
// 		if (document.$form.survreq.checked == true) {
// 	  		document.all.survreqtable.style.display = 'block';
// 		}
// 		else {
// 			document.all.survreqtable.style.display = 'none';
//		}
//		submitShow();
//	}
 	function browseUser() {
		var tableArray = document.all.tags('table');
 		if (document.$form.user.checked == true) {
			document.all.internaltable.style.display = 'none';
			document.all.externaltable.style.display = 'none';
			document.all.survtable.style.display = 'none';
			//document.all.audittable.style.display = 'none';
			//document.all.survreqtable.style.display = 'none';
			document.all.submit_button.style.display = 'none';
			document.$form.internal.checked = false;
			document.$form.external.checked = false;
			document.$form.surv.checked = false;
			//document.$form.audit.checked = false;
			//document.$form.survreq.checked = false;
			for (var i = 6; i < tableArray.length; i++) {
				tableArray[i].style.display = 'block';
			}
		}
		else {
			for (var i = 6; i < tableArray.length; i++) {
				tableArray[i].style.display = 'none';
			}
		}
	}
	function uncheck() {
		document.$form.internal.checked = false;
		document.$form.external.checked = false;
		//document.$form.audit.checked = false;
		document.$form.surv.checked = false;
		//document.$form.survreq.checked = false;
	}
function isblank(s)
{
    if (s.length == 0) return true;
    for(var i = 0; i < s.length; i++) {
        var c = s.charAt(i);
        if ((c != ' ') && (c != '\\n') && (c != '\\t') && (c !='\\r')) return false;
    }
    return true;
}
    function checkDate(date,e) {
	var valid = 1;
	var errormsg = "";
	var dateparts;

	if (isblank(date)) {
		valid = 1;
	}
	else  {
		var test = date.match(/[\/]+/g);
		if (!test || test.length != 2) {valid = 0 ;}
		else {
			dateparts = date.split('/');		
			var month = dateparts[0];
			var day = dateparts[1];
			var year = dateparts[2];
		}
		if (valid == 0) {
			alert ("Date should be of the format MM/DD/YYYY or MM/DD/YY");	
			valid = 0;
		}	
		if ((month < 1) || (month > 12)) {
			errormsg += month + " is not a valid month\\n";
			alert (errormsg);	
			valid = 0;
		}	
		if ((day < 1) || ((month == "01" || month == "1") && (day > 31)) || ((month == "02" || month == "2") && (day > 29))
	  	 || ((month == "03" || month == "3") && (day > 31)) || ((month == "04" || month == "4") && (day > 30))
	  	 || ((month == "05" || month == "5") && (day > 31)) || ((month == "06" || month == "6") && (day > 30))
	  	 || ((month == "07" || month == "7") && (day > 31)) || ((month == "08" || month == "8") && (day > 31))
	  	 || ((month == "09" || month == "9") && (day > 30)) || ((month == "10") && (day > 31))
	  	 || ((month == "11") && (day > 30)) || ((month == "12") && (day > 31))) {
	
			alert ("There are not " + day + " days in that month");
			valid = 0;		
		}	
		if ( !year || (year.length != 2 && year.length != 4)) {
			errormsg += year + " is not a valid year\\n";	
			valid = 0;
		}
	}
	if (!valid) {
		alert (errormsg);
		e.focus();
	}
		
	return (valid);
		
    }
//-->
</script>

</HEAD>
<script language=javascript type=text/javascript>
<!--
	if (parent != self) {
		doSetTextImageLabel('Browse');
	}
//-->
</script>
  
<body background=$NQSImagePath/background.gif text="#000099">
<form name=$form method=post>
<input type=hidden name=username value=$username>
<input type=hidden name=userid value=$userid>
<input type=hidden name=schema value=$schema>
<input type=hidden name=cgiaction value=$cgiaction>
<input type=hidden name=browse_option value=$browseOption>
<input type=hidden name=browseinternal>
<input type=hidden name=browseexternal>
<input type=hidden name=browseaudit>
<input type=hidden name=browsesurv>
<input type=hidden name=browsesurvreq>

END_of_Multiline_Text

###############################
if ($cgiaction eq "option") {
###############################
	print "<br>\n";
	print "<a name=top></a>\n";
	print "<table width=500 cellspacing=4 align=center border=0>\n";
	print "<tr>\n<td><input type=checkbox name=internal onClick=\"browseInternal()\">&nbsp;<b>Browse <font color=black>Internal Audits</td>\n";
	print "<td><input type=checkbox name=external onClick=\"browseExternal()\">&nbsp;<b>Browse <font color=black>External Audits</td>\n</tr>";
	print "<tr><td><input type=checkbox name=surv onClick=\"browseSurv()\">&nbsp;<b>Browse <font color=black>Surveillances</td>\n";
	print "<td><input type=checkbox name=user onClick=\"browseUser()\">&nbsp;<b>Browse <font color=black>System Users</td>\n</tr>\n";
	#print "<tr><td><input type=checkbox name=audit onClick=\"browseAudit()\">&nbsp;<b>Browse <font color=black>Audits</td><td>&nbsp;</td></tr>\n";
	print "</table>\n";
	print "<br>\n";
	&internalAuditSearch;
	&externalAuditSearch;
	&survSearch;
	#&auditSearch;
	#&survReqSearch;
	print "<br><center><input id=submit_button type=submit value=Submit style=display:none onClick=display(document.$form);></center>\n";
	&displayUsers;
	print "<script language=javascript>\n<!--\nif (document.$form.browse_option.value == 'user') {document.$form.user.checked = true;\nbrowseUser();\n} else {\nuncheck();\n}\n//-->\n</script>\n"; 
}

################################
if ($cgiaction eq "view_user") {
################################
	my ($userInfoRef, $userPrivRef, $userNameHistory) = &getUserInfo($dbh, $schema, $viewUserId);
	my $userInfo = @$userInfoRef[0];
	my ($phoneNumber, $priv);
	print "<center>\n";
	print "<br>\n<br>\n<table border=0 cellspacing=2 cellpadding=0 width=350 bgcolor=\"#ffffff\">\n";
	print "<tr>\n<td bgcolor=\"#000099\" colspan=2><font size=+1 color=#ffffff>User Information</font></td>\n</tr>\n";
	print "<tr>\n<td bgcolor=#f0f0f0><b>User ID:</b></td>\n";
	print "<td bgcolor=#f0f0f0><b>$viewUserId</b></td>\n</tr>\n";
	print "<tr>\n<td bgcolor=#ffffff><b>User Name:</b></td>\n";
	print "<td bgcolor=#ffffff><b>@$userInfo[1]</b></td>\n</tr>\n";
	print "<tr>\n<td bgcolor=#f0f0f0><b>Name:</b></td>\n";
	print "<td bgcolor=#f0f0f0><b>@$userInfo[0]</b></td>\n</tr>\n";
	print "<tr>\n<td bgcolor=#ffffff><b>Location:</b></td>\n";
	print "<td bgcolor=#ffffff><b>@$userInfo[2]</b></td>\n</tr>\n";
	print "<tr>\n<td bgcolor=#f0f0f0><b>Organization:</b></td>\n";
	print "<td bgcolor=#f0f0f0><b>@$userInfo[3]</b></td>\n</tr>\n";
	print "<tr>\n<td bgcolor=#ffffff><b>Phone Number:</b></td>\n";
	if (@$userInfo[5] ne "N/A" && @$userInfo[5] !~ /^0\D{1,}/) {
		$phoneNumber = "(@$userInfo[4])&nbsp;" . substr(@$userInfo[5], 0, 3) . "-" . substr(@$userInfo[5], -4, 4);
	}
	else {
		$phoneNumber = @$userInfo[5];
	}
	print "<td bgcolor=#ffffff><b>" . $phoneNumber . "</b></td>\n</tr>\n";
	print "<tr>\n<td bgcolor=#f0f0f0><b>Email Address:</b></td>\n";
	print "<td bgcolor=#f0f0f0><b>@$userInfo[6]</b></td>\n</tr>\n";
	print "<tr>\n<td valign=top><b>Privileges:</b></td>\n";
	print "<td>";
	for $priv (@$userPrivRef) {
		print "<b>@$priv[1]</b><br>";
	}
	if (!(defined(@$userPrivRef))) {
		print "<b>Inactive</b>";
	}
	print "</td>\n</tr>\n";
	if (exists($userNameHistory->{@$userInfo[0]})) {
		print "<tr>\n<td valign=top bgcolor=#f0f0f0 nowrap><b>User Name History:</b></td>\n<td bgcolor=#f0f0f0 nowrap>";
		foreach my $name (keys %{$userNameHistory}) {
			if ($userNameHistory->{$name} eq "T") {
				print "<b>$name (current)</b><br>";
			}
			else {
				print "<b>$name</b><br>";
			}
	 	}
	 	print "</td>\n</tr>\n";
	}
	print "</table>\n";
	print "<br><br><a href=javascript:document.$form.browse_option.value='user';submitForm('browse','option','');><b>Return to Previous Page</b></a>\n";
	print "</center>\n";
}


############################
if ($cgiaction eq "display") {
############################
	my $browseOption = defined($NQScgi->param('browse_option')) ? $NQScgi->param('browse_option') : '';
   my $internalSelectQuerystring = defined($NQScgi->param('internalquery')) ? $NQScgi->param('internalquery') : '';
   my $externalSelectQuerystring = defined($NQScgi->param('externalquery')) ? $NQScgi->param('externalquery'): '';
	my $intFy = defined($NQScgi->param('intfy')) ? $NQScgi->param('intfy') : '';
	my $extFy = defined($NQScgi->param('extfy')) ? $NQScgi->param('extfy') : '';
	my $internalCount = defined($NQScgi->param('intcount')) ? $NQScgi->param('intcount') : '';
	my $externalCount = defined($NQScgi->param('extcount')) ? $NQScgi->param('extcount') : '';
   my $survSelectQuerystring = defined($NQScgi->param('survquery')) ? $NQScgi->param('survquery') : '';
   my $intSelectionCriteria = defined($NQScgi->param('intcriteria')) ? $NQScgi->param('intcriteria') : '';
   my $extSelectionCriteria = defined($NQScgi->param('extcriteria')) ? $NQScgi->param('extcriteria') : '';
   my $selectionCriteria = defined($NQScgi->param('survcriteria')) ? $NQScgi->param('survcriteria') : '';
   my $survReqSelectQuerystring = defined($NQScgi->param('survreqquery')) ? $NQScgi->param('survreqquery') : '';
	my $survFy = defined($NQScgi->param('survfy')) ? $NQScgi->param('survfy') : '';
	my $survReqFy = defined($NQScgi->param('survreqfy')) ? $NQScgi->param('survreqfy') : '';
	my $survCount = defined($NQScgi->param('survcount')) ? $NQScgi->param('survcount') : '';
	my $survReqCount = defined($NQScgi->param('survreqcount')) ? $NQScgi->param('survreqcount') : '';
   my $browseInt = defined($NQScgi->param('browseinternal')) ? $NQScgi->param('browseinternal') : '';   
   my $browseExt = defined($NQScgi->param('browseexternal')) ? $NQScgi->param('browseexternal') : '';   
   my $browseSurv = defined($NQScgi->param('browsesurv')) ? $NQScgi->param('browsesurv') : '';   
   my $browseSurvReq = defined($NQScgi->param('browsesurvreq')) ? $NQScgi->param('browsesurvreq') : '';   
   my $intoutput = defined($NQScgi->param('intoutput')) ? $NQScgi->param('intoutput') : ''; 
   my $extoutput = defined($NQScgi->param('extoutput')) ? $NQScgi->param('extoutput') : ''; 
   my $output = defined($NQScgi->param('output')) ? $NQScgi->param('output') : ''; 
	print "<!-- display  ==== $browseExt -->\n";
   if ($browseInt eq "TRUE" && $internalCount > '0') {
		&writeAudit($internalSelectQuerystring,'internal',$intFy,$intoutput, $intSelectionCriteria);
		print "<br>\n";
	}
	if ($browseExt eq "TRUE" && $externalCount > '0') {
		&writeAudit($externalSelectQuerystring,'external',$extFy,$extoutput, $extSelectionCriteria);
		print "<br>\n";
	}
#	print STDERR "<!-- $survSelectQuerystring -->\n";
   if ($browseSurv eq "TRUE" && $survCount > '0') {
		&writeSurveillance($dbh, $survSelectQuerystring, "surveillance", $survFy, $output, $selectionCriteria);
		print "<br>\n";
	}
#	print "<!-- display = $survReqFy -->\n";
	if ($browseSurvReq eq "TRUE" && $survReqCount > '0') {
		&writeSurveillanceRequest($dbh, $survReqSelectQuerystring, "surveillance_request", $survReqFy);	
	}
}


############################
if ($cgiaction eq "build_query") {
############################
   my $org = defined($NQScgi->param('org')) ? $NQScgi->param('org') : '';
   my $suborg = defined($NQScgi->param('suborg')) ? $NQScgi->param('suborg') : '';
   my $intLoc = defined($NQScgi->param('intloc')) ? $NQScgi->param('intloc'): '';
   my $extLoc = defined($NQScgi->param('extloc')) ? $NQScgi->param('extloc'): '';
   my $auditLoc = defined($NQScgi->param('auditloc')) ? $NQScgi->param('auditloc'): '';
   my $intLead = defined($NQScgi->param('intlead')) ? $NQScgi->param('intlead') : '';
   my $extLead = defined($NQScgi->param('extlead')) ? $NQScgi->param('extlead') : '';
   my $auditLead = defined($NQScgi->param('auditlead')) ? $NQScgi->param('auditlead') : '';
   my $supplier = defined($NQScgi->param('extsupplier')) ? $NQScgi->param('extsupplier') : '';
   my $intAuditType = defined($NQScgi->param('intaudittype')) ? $NQScgi->param('intaudittype') : '';
   my $extAuditType = defined($NQScgi->param('extaudittype')) ? $NQScgi->param('extaudittype') : '';
   my $auditType = defined($NQScgi->param('audittype')) ? $NQScgi->param('audittype') : '';
   my $intBeginMonth = defined($NQScgi->param('intbeginmonth')) ? $NQScgi->param('intbeginmonth') : '';
   my $extBeginMonth = defined($NQScgi->param('extbeginmonth')) ? $NQScgi->param('extbeginmonth') : '';
   my $auditBeginMonth = defined($NQScgi->param('auditbeginmonth')) ? $NQScgi->param('auditbeginmonth') : '';
   my $intFy = defined($NQScgi->param('intfy')) ? $NQScgi->param('intfy') : '';
   my $extFy = defined($NQScgi->param('extfy')) ? $NQScgi->param('extfy') : '';
   my $auditFy = defined($NQScgi->param('auditfy')) ? $NQScgi->param('auditfy') : '';
   my $extIssuedBy = defined($NQScgi->param('extissuedby')) ? $NQScgi->param('extissuedby') : '';
   my $intIssuedBy = defined($NQScgi->param('intissuedby')) ? $NQScgi->param('intissuedby') : '';
   my $auditIssuedBy = defined($NQScgi->param('auditissuedby')) ? $NQScgi->param('auditissuedby') : '';
   my $browseInt = defined($NQScgi->param('browseinternal')) ? $NQScgi->param('browseinternal') : '';   
   my $browseExt = defined($NQScgi->param('browseexternal')) ? $NQScgi->param('browseexternal') : '';   
   my $browseAudit = defined($NQScgi->param('browseaudit')) ? $NQScgi->param('browseaudit') : ''; 
   my $browseSurv = defined($NQScgi->param('browsesurv')) ? $NQScgi->param('browsesurv') : '';   
   my $browseSurvReq = defined($NQScgi->param('browsesurvreq')) ? $NQScgi->param('browsesurvreq') : '';   
   my $intstartfrom = defined($NQScgi->param('intstartfrom')) ? $NQScgi->param('intstartfrom') : '';   
   my $extstartfrom = defined($NQScgi->param('extstartfrom')) ? $NQScgi->param('extstartfrom') : ''; 
   my $startfrom = defined($NQScgi->param('startfrom')) ? $NQScgi->param('startfrom') : ''; 
   my $intstartto = defined($NQScgi->param('intstartto')) ? $NQScgi->param('intstartto') : '';   
   my $extstartto = defined($NQScgi->param('extstartto')) ? $NQScgi->param('extstartto') : ''; 
   my $startto = defined($NQScgi->param('startto')) ? $NQScgi->param('startto') : ''; 
   my $intendfrom = defined($NQScgi->param('intendfrom')) ? $NQScgi->param('intendfrom') : '';   
   my $extendfrom = defined($NQScgi->param('extendfrom')) ? $NQScgi->param('extendfrom') : ''; 
   my $endfrom = defined($NQScgi->param('endfrom')) ? $NQScgi->param('endfrom') : ''; 
   my $intendto = defined($NQScgi->param('intendto')) ? $NQScgi->param('intendto') : '';
   my $extendto = defined($NQScgi->param('extendto')) ? $NQScgi->param('extendto') : '';
   my $endto = defined($NQScgi->param('endto')) ? $NQScgi->param('endto') : '';
   my $intapprovedfrom = defined($NQScgi->param('intapprovedfrom')) ? $NQScgi->param('intapprovedfrom') : '';   
   my $extapprovedfrom = defined($NQScgi->param('extapprovedfrom')) ? $NQScgi->param('extapprovedfrom') : '';
   my $approvedfrom = defined($NQScgi->param('approvedfrom')) ? $NQScgi->param('approvedfrom') : '';
   my $intapprovedto = defined($NQScgi->param('intapprovedto')) ? $NQScgi->param('intapprovedto') : '';   
   my $extapprovedto = defined($NQScgi->param('extapprovedto')) ? $NQScgi->param('extapprovedto') : '';  
   my $approvedto = defined($NQScgi->param('approvedto')) ? $NQScgi->param('approvedto') : '';  
   my @intqardstring = defined($NQScgi->param('intQardElement')) ? $NQScgi->param('intQardElement') : ();
   my @extqardstring = defined($NQScgi->param('extQardElement')) ? $NQScgi->param('extQardElement') : ();
   my @qardstring = defined($NQScgi->param('qardElement')) ? $NQScgi->param('qardElement') : ();
   my $intadequacy = defined($NQScgi->param('intAdequacy')) ? $NQScgi->param('intAdequacy') : 0;
   my $extadequacy = defined($NQScgi->param('extAdequacy')) ? $NQScgi->param('extAdequacy') : 0;
   my $adequacy = defined($NQScgi->param('adequacy')) ? $NQScgi->param('adequacy') : 0;
   my $intimplementation = defined($NQScgi->param('intImplementation')) ? $NQScgi->param('intImplementation') : 0;
   my $extimplementation = defined($NQScgi->param('extImplementation')) ? $NQScgi->param('extImplementation') : 0;
   my $implementation = defined($NQScgi->param('implementation')) ? $NQScgi->param('implementation') : 0;
   my $inteffectiveness = defined($NQScgi->param('intEffectiveness')) ? $NQScgi->param('intEffectiveness') : 0;
   my $exteffectiveness = defined($NQScgi->param('extEffectiveness')) ? $NQScgi->param('extEffectiveness') : 0;
   my $effectiveness = defined($NQScgi->param('effectiveness')) ? $NQScgi->param('effectiveness') : 0;
   my $intoutput = defined($NQScgi->param('intoutput')) ? $NQScgi->param('intoutput') : 'standard';
   my $extoutput = defined($NQScgi->param('extoutput')) ? $NQScgi->param('extoutput') : 'standard';
   my $output = defined($NQScgi->param('output')) ? $NQScgi->param('output') : 'standard';
   my @internalAudits;
   my @externalAudits;
   my @audits;
   my @internalIDs;  
   my @externalIDs;  
   my @internalIDlist;
   my @externalIDlist;
   my $internalIDs = "(0,";
   my $externalIDs = "(0,";
   my $internalIDlist; 
   my $externalIDlist;
   my $internalSelectQuerystring = ""; 
   my $externalSelectQuerystring = "";
   my $internalCountQuerystring = ""; 
   my $externalCountQuerystring = "";
   my $internalQuerystring = ""; 
   my $externalQuerystring = "";
   my $issuedByQueryString = "";
   my $intCommonQuerystring = "";
   my $extCommonQuerystring = "";
   my $auditSelectQuerystring = "";
   my $intSelectionCriteria = "";
   my $extSelectionCriteria = "";
   my $internalCount = 0;
   my $externalCount = 0;
   my $alertString = "";
	my $browseOption = defined($NQScgi->param('browse_option')) ? $NQScgi->param('browse_option') : '';
	my $survFy = defined($NQScgi->param("survfy")) ? $NQScgi->param("survfy") : "";
	my $survReqFy = defined($NQScgi->param("survreqfy")) ? $NQScgi->param("survreqfy") : "";	
	my $survIssuedBy = defined($NQScgi->param("survissuedby")) ? $NQScgi->param("survissuedby") : "";
	my $survReqIssuedBy = defined($NQScgi->param("survreqissuedby")) ? $NQScgi->param("survreqissuedby") : "";
	my $lead = defined($NQScgi->param("lead")) ? $NQScgi->param("lead") : "";
	my $survOrg = defined($NQScgi->param("survorg")) ? $NQScgi->param("survorg") : "";
	my $survSuborg = defined($NQScgi->param("survsuborg")) ? $NQScgi->param("survsuborg") : "";
	my $survLoc = defined($NQScgi->param("survloc")) ? $NQScgi->param("survloc") : "";
	my $survSupplier = defined($NQScgi->param("survsupplier")) ? $NQScgi->param("survsupplier") : "";
	my @survType = defined($NQScgi->param("survtype")) ? $NQScgi->param("survtype") : ();
	my $survReqOrg = defined($NQScgi->param("survreqorg")) ? $NQScgi->param("survreqorg") : "";
	my $survReqLoc = defined($NQScgi->param("survreqloc")) ? $NQScgi->param("survreqloc") : "";	
	my $beginMonth = defined($NQScgi->param("survmonth")) ? $NQScgi->param("survmonth") : "";
	my $reqMonth = defined($NQScgi->param("reqmonth")) ? $NQScgi->param("reqmonth") : "";	
	my $requestor = defined($NQScgi->param("requestor")) ? $NQScgi->param("requestor") : "";
#	$survFy = substr($survFy, 2, 2);
#	$survReqFy = substr($survReqFy, 2, 2);
	my $survSelectQuerystring = "";
	my $selectionCriteria = "";
	my $survReqSelectQuerystring = "";
	my $survReqCommonQuerystring = "";
	my $survCommonQuerystring = "";
	my $survIDs = "(0,";
	my $survIDlist;
	my $survCount = 0;
	my $survReqCount = 0;
	my $survReqIDs = "(0,";
	my $survReqIDlist;
	my @survIDs;
	my @survReqIDs;
	
   if ($extAuditType ne 'external') {
		$extCommonQuerystring .= "and audit_type = '$extAuditType' ";
	}
	if ($extLead gt '0') {
		$extCommonQuerystring .= " and team_lead_id = $extLead ";
	}
	if ($extBeginMonth gt '0') {
		$extCommonQuerystring .= "and (to_char(begin_date,'MM') = $extBeginMonth or to_char(forecast_date,'MM') = $extBeginMonth) ";
	}
   if ($intAuditType ne 'internal') {
		$intCommonQuerystring .= "and audit_type = '$intAuditType' ";
	}
	if ($intLead gt '0') {
		$intCommonQuerystring .= " and team_lead_id = $intLead ";
	}
	if ($intBeginMonth gt '0') {
		$intCommonQuerystring .= "and (to_char(begin_date,'MM') = $extBeginMonth or to_char(forecast_date,'MM') = $intBeginMonth) ";
	}
   if ($browseInt eq "TRUE") {
   	$internalSelectQuerystring .= "SELECT audit_seq, audit_type, issuedto_org_id, to_char(begin_date,'MM/DD/YYYY'), to_char(end_date,'MM/DD/YYYY'), ";
	   $internalSelectQuerystring .= "team_lead_id, scope, notes, cancelled, to_char(forecast_date,'MM/DD/YYYY'), to_char(completion_date,'MM/DD/YYYY'), id, team_members, issuedby_org_id, ";
	   $internalSelectQuerystring .= "qard_elements,adequacy, implementation, effectiveness, procedures, state, title, reschedule,overall_results ";
	   $internalCountQuerystring = "select count (*) ";
		$internalQuerystring .= "from $schema.internal_audit ";
	  	$internalQuerystring .= "where fiscal_year = " . substr($intFy,2) . " and revision = 0 ";
		$internalQuerystring .= "AND issuedby_org_id = $intIssuedBy " if ($intIssuedBy gt '0');
		$internalQuerystring .= "AND team_lead_id = $intLead " if ($intLead gt '0');
		$internalQuerystring .= "AND ((begin_date BETWEEN to_date('$intstartfrom','MM/DD/RRRR') AND to_date('$intstartto','MM/DD/RRRR')) OR (forecast_date BETWEEN to_date('$intstartfrom','MM/DD/RRRR') AND to_date('$intstartto','MM/DD/RRRR')))  " if ($intstartfrom gt '' && $intstartto gt '');
		$internalQuerystring .= "AND begin_date > to_date('$intstartfrom','MM/DD/RRRR') " if ($intstartfrom gt '' && $intstartto eq '');
		$internalQuerystring .= "AND begin_date < to_date('$intstartto','MM/DD/RRRR')  " if ($intstartfrom eq '' && $intstartto gt '');
		$internalQuerystring .= "AND end_date BETWEEN to_date('$intendfrom','MM/DD/RRRR') AND to_date('$intendto','MM/DD/RRRR')  " if ($intendfrom gt '' && $intendto gt '');
		$internalQuerystring .= "AND end_date > to_date('$intendfrom','MM/DD/RRRR') " if ($intendfrom gt '' && $intendto eq '');
		$internalQuerystring .= "AND end_date < to_date('$intendto','MM/DD/RRRR')  " if ($intendfrom eq '' && $intendto gt '');
		$internalQuerystring .= "AND completion_date BETWEEN to_date('$intapprovedfrom','MM/DD/RRRR') AND to_date('$intapprovedto','MM/DD/RRRR')  " if ($intapprovedfrom gt '' && $intapprovedto gt '');
		$internalQuerystring .= "AND completion_date > to_date('$intapprovedfrom','MM/DD/RRRR') " if ($intapprovedfrom gt '' && $intapprovedto eq '');
		$internalQuerystring .= "AND completion_date < to_date('$intapprovedto','MM/DD/RRRR')  " if ($intapprovedfrom eq '' && $intapprovedto gt '');
		$internalQuerystring .= "AND adequacy = '$intadequacy' " if ($intadequacy); 
		$internalQuerystring .= "AND implementation = '$intimplementation' " if ($intimplementation);
		$internalQuerystring .= "AND effectiveness = '$inteffectiveness' " if ($inteffectiveness);
	$intSelectionCriteria = "Selected Criteria - Fiscal Year: $intFy";
	$intSelectionCriteria .= ", Organization: " . &getOrganization($dbh, $schema, "", "", $org) if ($org);
	$intSelectionCriteria .= ", Suborganization: " . &getSuborganization($dbh, $schema, "", "", $suborg) if ($suborg);
	$intSelectionCriteria .= ", Location: " . &getLocation($dbh, $schema, $intLoc) if ($intLoc);
	$intSelectionCriteria .= ", Issued By: " . &getOrganization($dbh, $schema, "", "", $intIssuedBy) if ($intIssuedBy gt '0');
	$intSelectionCriteria .= ", Team Lead: " . lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname",$intLead) if ($intLead gt '0');
	$intSelectionCriteria .= ", Start Date between: $intstartfrom and $intstartto" if ($intstartfrom gt '' && $intstartto gt '');
	$intSelectionCriteria .= ", Start Date after: $intstartfrom" if ($intstartfrom gt '' && $intstartto eq '');
	$intSelectionCriteria .= ", Start Date before: $intstartto" if ($intstartfrom eq '' && $intstartto gt '');
	$intSelectionCriteria .= ", End Date between: $intendfrom and $intendto" if ($intendfrom gt '' && $intendto gt '');
	$intSelectionCriteria .= ", End Date after: $intendfrom" if ($intendfrom gt '' && $intendto eq '');
	$intSelectionCriteria .= ", End Date before: $intendto" if ($intendfrom eq '' && $intendto gt '');
	$intSelectionCriteria .= ", Report Completed Date between: $intapprovedfrom and $intapprovedto" if ($intapprovedfrom gt '' && $intapprovedto gt '');
	$intSelectionCriteria .= ", Report Completed Date after: $intapprovedfrom" if ($intapprovedfrom gt '' && $intapprovedto eq '');
	$intSelectionCriteria .= ", Report Completed Date before: $intapprovedto" if ($intapprovedfrom eq '' && $intapprovedto gt '');
	$intSelectionCriteria .= ", Adequacy: $intadequacy" if ($intadequacy);
	$intSelectionCriteria .= ", Implementation: $intimplementation" if ($intimplementation);
	$intSelectionCriteria .= ", Effectiveness: $inteffectiveness" if ($inteffectiveness);
        my $intqard;
        my $intfirst = 1;
        if ($#intqardstring >= 0) {
        	for (my $j = 0; $j <= $#intqardstring; $j++) {
    			if ($intfirst) {
    				$intqard = "AND (substr(qard_elements,$intqardstring[$j]+1,1) = '1' " ;
    				$intSelectionCriteria .= ", QARD Elements: ";
    				$intSelectionCriteria .=  ($intqardstring[$j]+1) if ($intqardstring[$j] < 18);
    				$intSelectionCriteria .=  "SI" if ($intqardstring[$j] == 18);
    				$intSelectionCriteria .=  "SII" if ($intqardstring[$j] == 19);
    				$intSelectionCriteria .=  "SIII" if ($intqardstring[$j] == 20);
    				$intSelectionCriteria .=  "SIV" if ($intqardstring[$j] == 21);
    				$intSelectionCriteria .=  "SV" if ($intqardstring[$j] == 22);
    				$intSelectionCriteria .=  "APP C" if ($intqardstring[$j] == 23);
    				$intfirst = 0;
    			}
    			else {
    				$intqard .= "OR substr(qard_elements,$intqardstring[$j]+1,1) = '1' " ;
    				$intSelectionCriteria .= ",";
    				$intSelectionCriteria .=  ($intqardstring[$j]+1) if ($intqardstring[$j] < 18);
    				$intSelectionCriteria .=  "SI" if ($intqardstring[$j] == 18);
    				$intSelectionCriteria .=  "SII" if ($intqardstring[$j] == 19);
    				$intSelectionCriteria .=  "SIII" if ($intqardstring[$j] == 20);
    				$intSelectionCriteria .=  "SIV" if ($intqardstring[$j] == 21);
    				$intSelectionCriteria .=  "SV" if ($intqardstring[$j] == 22);
    				$intSelectionCriteria .=  "APP C" if ($intqardstring[$j] == 23);
    			}
    			if ($j == $#intqardstring) {$intqard .= ") ";}
    		}
        }
	$internalQuerystring .= $intqard;		  
   	if ($intLoc || $org) {
   		my $whereClause;
   		if ($intLoc gt '0' && $org gt '0') {
   			$whereClause = " (location_id = $intLoc and organization_id = $org) ";
   		} 
   		elsif ($intLoc gt '0' && $org eq '0') {
   			$whereClause = " location_id = $intLoc ";
   		}
   		elsif ($intLoc eq '0' && $org gt '0') {
   			$whereClause = " organization_id = $org ";
   		}
   	   @internalIDs = &getAuditID ($dbh, 'distinct(internal_audit_id) ', 'internal_audit_org_loc', $whereClause, substr($intFy,2));
   	   
			foreach my $val (@internalIDs) {
				$internalIDs .= $val . ",";
   	   }
   	   chop($internalIDs);
	   	$internalIDlist .=  $internalIDs . ")";   	
	   	$internalQuerystring .= "and id in $internalIDlist ";
	   }
	   if ($intIssuedBy ne '' && $intIssuedBy gt '0') {
	   	$intCommonQuerystring .= "and issuedby_org_id = $intIssuedBy";
		}
		
	   $internalQuerystring .= $intCommonQuerystring;
	   $internalSelectQuerystring .= $internalQuerystring;
	   $internalCountQuerystring .= $internalQuerystring;
	   $internalSelectQuerystring .= " ORDER BY begin_date, end_date, forecast_date"; 
#	   print STDERR "<!-- issuedby = $issuedby || internalcount = $internalCountQuerystring -->\n";
#	   print STDERR "<!-- internalselect = $internalSelectQuerystring -->\n";
#	   print "<br><br>#### $intCommonQuerystring ###<br><br>\n";
	   	
	   $internalCount = &searchCount($internalCountQuerystring);
   }
   
   if ($browseExt eq "TRUE") {
		
		$externalSelectQuerystring .= "SELECT audit_seq, audit_type, issuedto_org_id, to_char(begin_date,'MM/DD/YYYY'), to_char(end_date,'MM/DD/YYYY'), ";
	   	$externalSelectQuerystring .= "team_lead_id, scope, notes, cancelled, to_char(forecast_date,'MM/DD/YYYY'), to_char(completion_date,'MM/DD/YYYY'), id, team_members, issuedby_org_id, ";
	   	$externalSelectQuerystring .= "qard_elements,adequacy, implementation, effectiveness, procedures, state, title, reschedule,overall_results, qualified_supplier_id ";
		$externalCountQuerystring = "select count (*) ";
		$externalQuerystring .= "from $schema.external_audit ";
		$externalQuerystring .= "where fiscal_year = " . substr($extFy, 2) . " and revision = 0 ";
		$externalQuerystring .= "AND issuedby_org_id = $extIssuedBy " if ($extIssuedBy gt '0');
		$externalQuerystring .= "AND team_lead_id = $extLead " if ($extLead gt '0');
		$externalQuerystring .= "AND ((begin_date BETWEEN to_date('$extstartfrom','MM/DD/RRRR') AND to_date('$extstartto','MM/DD/RRRR')) OR (forecast_date BETWEEN to_date('$extstartfrom','MM/DD/RRRR') AND to_date('$extstartto','MM/DD/RRRR')))  " if ($extstartfrom gt '' && $extstartto gt '');
		$externalQuerystring .= "AND (begin_date > to_date('$extstartfrom','MM/DD/RRRR') OR forecast_date > to_date('$extstartfrom','MM/DD/RRRR')) " if ($extstartfrom gt '' && $extstartto eq '');
		$externalQuerystring .= "AND (begin_date < to_date('$extstartto','MM/DD/RRRR') OR forecast_date < to_date('$extstartto','MM/DD/RRRR'))  " if ($extstartfrom eq '' && $extstartto gt '');
		$externalQuerystring .= "AND end_date BETWEEN to_date('$extendfrom','MM/DD/RRRR') AND to_date('$extendto','MM/DD/RRRR')  " if ($extendfrom gt '' && $extendto gt '');
		$externalQuerystring .= "AND end_date > to_date('$extendfrom','MM/DD/RRRR') " if ($extendfrom gt '' && $extendto eq '');
		$externalQuerystring .= "AND end_date < to_date('$extendto','MM/DD/RRRR')  " if ($extendfrom eq '' && $extendto gt '');
		$externalQuerystring .= "AND completion_date BETWEEN to_date('$extapprovedfrom','MM/DD/RRRR') AND to_date('$extapprovedto','MM/DD/RRRR')  " if ($extapprovedfrom gt '' && $extapprovedto gt '');
		$externalQuerystring .= "AND completion_date > to_date('$extapprovedfrom','MM/DD/RRRR') " if ($extapprovedfrom gt '' && $extapprovedto eq '');
		$externalQuerystring .= "AND completion_date < to_date('$extapprovedto','MM/DD/RRRR')  " if ($extapprovedfrom eq '' && $extapprovedto gt '');
		$externalQuerystring .= "AND adequacy = '$extadequacy' " if ($extadequacy); 
		$externalQuerystring .= "AND implementation = '$extimplementation' " if ($extimplementation);
		$externalQuerystring .= "AND effectiveness = '$exteffectiveness' " if ($exteffectiveness);
	$extSelectionCriteria = "Selected Criteria - Fiscal Year: $extFy";
	#$extSelectionCriteria .= ", Surveillance Type: Internal" if ($#survType == 0 && $survType[0] eq 'I');
	#$extSelectionCriteria .= ", Surveillance Type: External" if ($#survType == 0 && $survType[0] eq 'E');
	#$extSelectionCriteria .= ", Organization: " . &getOrganization($dbh, $schema, "", "", $extOrg) if ($extOrg);
	#$extSelectionCriteria .= ", Suborganization: " . &getSuborganization($dbh, $schema, "", "", $extSuborg) if ($extSuborg);
	$extSelectionCriteria .= ", Supplier: " . $supplierhash{$supplier} if ($supplier);
	$extSelectionCriteria .= ", Location: " . &getLocation($dbh, $schema, $extLoc) if ($extLoc);
	$extSelectionCriteria .= ", Issued By: " . &getOrganization($dbh, $schema, "", "", $extIssuedBy) if ($extIssuedBy gt '0');
	$extSelectionCriteria .= ", Team Lead: " . lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname",$extLead) if ($extLead gt '0');
	$extSelectionCriteria .= ", Start Date between: $extstartfrom and $extstartto" if ($extstartfrom gt '' && $extstartto gt '');
	$extSelectionCriteria .= ", Start Date after: $extstartfrom" if ($extstartfrom gt '' && $extstartto eq '');
	$extSelectionCriteria .= ", Start Date before: $extstartto" if ($extstartfrom eq '' && $extstartto gt '');
	$extSelectionCriteria .= ", End Date between: $extendfrom and $extendto" if ($extendfrom gt '' && $extendto gt '');
	$extSelectionCriteria .= ", End Date after: $extendfrom" if ($extendfrom gt '' && $extendto eq '');
	$extSelectionCriteria .= ", End Date before: $extendto" if ($extendfrom eq '' && $extendto gt '');
	$extSelectionCriteria .= ", Report Completed Date between: $extapprovedfrom and $extapprovedto" if ($extapprovedfrom gt '' && $extapprovedto gt '');
	$extSelectionCriteria .= ", Report Completed Date after: $extapprovedfrom" if ($extapprovedfrom gt '' && $extapprovedto eq '');
	$extSelectionCriteria .= ", Report Completed Date before: $extapprovedto" if ($extapprovedfrom eq '' && $extapprovedto gt '');
	$extSelectionCriteria .= ", Adequacy: $extadequacy" if ($extadequacy);
	$extSelectionCriteria .= ", Implementation: $extimplementation" if ($extimplementation);
	$extSelectionCriteria .= ", Effectiveness: $exteffectiveness" if ($exteffectiveness);
        my $extqard;
        my $extfirst = 1;
        if ($#extqardstring >= 0) {
        	for (my $j = 0; $j <= $#extqardstring; $j++) {
    			if ($extfirst) {
    				$extqard = "AND (substr(qard_elements,$extqardstring[$j]+1,1) = '1' " ;
    				$extSelectionCriteria .= ", QARD Elements: ";
    				$extSelectionCriteria .=  ($extqardstring[$j]+1) if ($extqardstring[$j] < 18);
    				$extSelectionCriteria .=  "SI" if ($extqardstring[$j] == 18);
    				$extSelectionCriteria .=  "SII" if ($extqardstring[$j] == 19);
    				$extSelectionCriteria .=  "SIII" if ($extqardstring[$j] == 20);
    				$extSelectionCriteria .=  "SIV" if ($extqardstring[$j] == 21);
    				$extSelectionCriteria .=  "SV" if ($extqardstring[$j] == 22);
    				$extSelectionCriteria .=  "APP C" if ($extqardstring[$j] == 23);
    				$extfirst = 0;
    			}
    			else {
    				$extqard .= "OR substr(qard_elements,$extqardstring[$j]+1,1) = '1' " ;
    				$extSelectionCriteria .= ",";
    				$extSelectionCriteria .=  ($extqardstring[$j]+1) if ($extqardstring[$j] < 18);
    				$extSelectionCriteria .=  "SI" if ($extqardstring[$j] == 18);
    				$extSelectionCriteria .=  "SII" if ($extqardstring[$j] == 19);
    				$extSelectionCriteria .=  "SIII" if ($extqardstring[$j] == 20);
    				$extSelectionCriteria .=  "SIV" if ($extqardstring[$j] == 21);
    				$extSelectionCriteria .=  "SV" if ($extqardstring[$j] == 22);
    				$extSelectionCriteria .=  "APP C" if ($extqardstring[$j] == 23);
    			}
    			if ($j == $#extqardstring) {$extqard .= ") ";}
    		}
        }
	$externalQuerystring .= $extqard;		  		
		if ($extLoc > '0' ) {
			@externalIDs = &getAuditID ($dbh,'external_audit_id ','external_audit_locations', " location_id = $extLoc ", substr($extFy, 2));

			foreach my $val (@externalIDs) {
				$externalIDs .= $val . ",";
			}
			chop($externalIDs);
			$externalIDlist .=  $externalIDs . ")";   	
			$externalQuerystring .= "and id in $externalIDlist ";
		}
		if ($supplier > '0') {
	   	$externalQuerystring .= "and qualified_supplier_id = $supplier ";
	   }
	   if ($extIssuedBy ne '' && $extIssuedBy gt '0') {
			$externalQuerystring .= "and issuedby_org_id = $extIssuedBy";
		}
	   $externalQuerystring .= $extCommonQuerystring;
	   $externalSelectQuerystring .= $externalQuerystring;
	   print "<!-- externalselect = $externalSelectQuerystring -->\n"; 
	   $externalCountQuerystring .= $externalQuerystring;   
	   $externalCount = &searchCount($externalCountQuerystring);
   }
   if ($browseAudit eq "TRUE") {
   	$internalSelectQuerystring .= "SELECT audit_seq, audit_type, issuedto_org_id, to_char(begin_date,'MM/DD/YYYY'), to_char(end_date,'MM/DD/YYYY'), ";
	   $internalSelectQuerystring .= "team_lead_id, scope, notes, cancelled, to_char(forecast_date,'MM/DD/YYYY'), to_char(completion_date,'MM/DD/YYYY'), id, team_members, issuedby_org_id ";
	   $internalCountQuerystring = "select count (*) ";
		$internalQuerystring .= "from $schema.internal_audit ";
	  	$internalQuerystring .= "where fiscal_year = " . substr($intFy,2) . " and revision = 0 ";
		$internalQuerystring .= "AND issuedby_org_id = $survIssuedBy " if ($intIssuedBy gt '0');
		$internalQuerystring .= "AND team_lead_id = $lead " if ($intLead gt '0');
		$internalQuerystring .= "AND begin_date BETWEEN to_date('$startfrom','MM/DD/RRRR') AND to_date('$startto','MM/DD/RRRR')  " if ($startfrom gt '' && $startto gt '');
		$internalQuerystring .= "AND begin_date > to_date('$startfrom','MM/DD/RRRR') " if ($startfrom gt '' && $startto eq '');
		$internalQuerystring .= "AND begin_date < to_date('$startto','MM/DD/RRRR')  " if ($startfrom eq '' && $startto gt '');
		$internalQuerystring .= "AND end_date BETWEEN to_date('$endfrom','MM/DD/RRRR') AND to_date('$endto','MM/DD/RRRR')  " if ($endfrom gt '' && $endto gt '');
		$internalQuerystring .= "AND end_date > to_date('$endfrom','MM/DD/RRRR') " if ($endfrom gt '' && $endto eq '');
		$internalQuerystring .= "AND end_date < to_date('$endto','MM/DD/RRRR')  " if ($endfrom eq '' && $endto gt '');
		$internalQuerystring .= "AND completion_date BETWEEN to_date('$approvedfrom','MM/DD/RRRR') AND to_date('$approvedto','MM/DD/RRRR')  " if ($approvedfrom gt '' && $approvedto gt '');
		$internalQuerystring .= "AND completion_date > to_date('$approvedfrom','MM/DD/RRRR') " if ($approvedfrom gt '' && $approvedto eq '');
		$internalQuerystring .= "AND completion_date < to_date('$approvedto','MM/DD/RRRR')  " if ($approvedfrom eq '' && $approvedto gt '');
		$internalQuerystring .= "AND adequacy = '$adequacy' " if ($adequacy); 
		$internalQuerystring .= "AND implementation = '$implementation' " if ($implementation);
		$internalQuerystring .= "AND effectiveness = '$effectiveness' " if ($effectiveness);
	$selectionCriteria = "Selected Criteria - Fiscal Year: $survFy";
	$selectionCriteria .= ", Surveillance Type: Internal" if ($#survType == 0 && $survType[0] eq 'I');
	$selectionCriteria .= ", Surveillance Type: External" if ($#survType == 0 && $survType[0] eq 'E');
	$selectionCriteria .= ", Organization: " . &getOrganization($dbh, $schema, "", "", $survOrg) if ($survOrg);
	$selectionCriteria .= ", Suborganization: " . &getSuborganization($dbh, $schema, "", "", $survSuborg) if ($survSuborg);
	$selectionCriteria .= ", Supplier: " . $supplierhash{$survSupplier} if ($survSupplier);
	$selectionCriteria .= ", Location: " . &getLocation($dbh, $schema, $survLoc) if ($survLoc);
	$selectionCriteria .= ", Issued By: " . &getOrganization($dbh, $schema, "", "", $survIssuedBy) if ($survIssuedBy gt '0');
	$selectionCriteria .= ", Team Lead: " . lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname",$lead) if ($lead gt '0');
	$selectionCriteria .= ", Start Date between: $startfrom and $startto" if ($startfrom gt '' && $startto gt '');
	$selectionCriteria .= ", Start Date after: $startfrom" if ($startfrom gt '' && $startto eq '');
	$selectionCriteria .= ", Start Date before: $startto" if ($startfrom eq '' && $startto gt '');
	$selectionCriteria .= ", End Date between: $endfrom and $endto" if ($endfrom gt '' && $endto gt '');
	$selectionCriteria .= ", End Date after: $endfrom" if ($endfrom gt '' && $endto eq '');
	$selectionCriteria .= ", End Date before: $endto" if ($endfrom eq '' && $endto gt '');
	$selectionCriteria .= ", Report Completed Date between: $approvedfrom and $approvedto" if ($approvedfrom gt '' && $approvedto gt '');
	$selectionCriteria .= ", Report Completed Date after: $approvedfrom" if ($approvedfrom gt '' && $approvedto eq '');
	$selectionCriteria .= ", Report Completed Date before: $approvedto" if ($approvedfrom eq '' && $approvedto gt '');
	$selectionCriteria .= ", Adequacy: $adequacy" if ($adequacy);
	$selectionCriteria .= ", Implementation: $implementation" if ($implementation);
	$selectionCriteria .= ", Effectiveness: $effectiveness" if ($effectiveness);
        my $extqard;
        my $extfirst = 1;
        if ($#extqardstring >= 0) {
        	for (my $j = 0; $j <= $#extqardstring; $j++) {
    			if ($extfirst) {
    				$extqard = "AND (substr(qard_elements,$extqardstring[$j]+1,1) = '1' " ;
    				$selectionCriteria .= ", QARD Elements: ";
    				$selectionCriteria .=  ($extqardstring[$j]+1) if ($extqardstring[$j] < 18);
    				$selectionCriteria .=  "SI" if ($extqardstring[$j] == 18);
    				$selectionCriteria .=  "SII" if ($extqardstring[$j] == 19);
    				$selectionCriteria .=  "SIII" if ($extqardstring[$j] == 20);
    				$selectionCriteria .=  "SIV" if ($extqardstring[$j] == 21);
    				$selectionCriteria .=  "SV" if ($extqardstring[$j] == 22);
    				$selectionCriteria .=  "APP C" if ($extqardstring[$j] == 23);
    				$extfirst = 0;
    			}
    			else {
    				$extqard .= "OR substr(qard_elements,$extqardstring[$j]+1,1) = '1' " ;
    				$selectionCriteria .= ",";
    				$selectionCriteria .=  ($extqardstring[$j]+1) if ($extqardstring[$j] < 18);
    				$selectionCriteria .=  "SI" if ($extqardstring[$j] == 18);
    				$selectionCriteria .=  "SII" if ($extqardstring[$j] == 19);
    				$selectionCriteria .=  "SIII" if ($extqardstring[$j] == 20);
    				$selectionCriteria .=  "SIV" if ($extqardstring[$j] == 21);
    				$selectionCriteria .=  "SV" if ($extqardstring[$j] == 22);
    				$selectionCriteria .=  "APP C" if ($extqardstring[$j] == 23);
    			}
    			if ($j == $#extqardstring) {$extqard .= ") ";}
    		}
        }
	$externalQuerystring .= $extqard;		  	
	  
   	if ($intLoc || $org) {
   		my $whereClause;
   		if ($intLoc gt '0' && $org gt '0') {
   			$whereClause = " (location_id = $intLoc and organization_id = $org) ";
   		} 
   		elsif ($intLoc gt '0' && $org eq '0') {
   			$whereClause = " location_id = $intLoc ";
   		}
   		elsif ($intLoc eq '0' && $org gt '0') {
   			$whereClause = " organization_id = $org ";
   		}
   	   @internalIDs = &getAuditID ($dbh, 'distinct(internal_audit_id) ', 'internal_audit_org_loc', $whereClause, substr($intFy,2));
   	   
			foreach my $val (@internalIDs) {
				$internalIDs .= $val . ",";
   	   }
   	   chop($internalIDs);
	   	$internalIDlist .=  $internalIDs . ")";   	
	   	$internalQuerystring .= "and id in $internalIDlist ";
	   }
	   if ($intIssuedBy ne '' && $intIssuedBy gt '0') {
	   	$intCommonQuerystring .= "and issuedby_org_id = $intIssuedBy";
		}
		
	   $internalQuerystring .= $intCommonQuerystring;
	   $internalSelectQuerystring .= $internalQuerystring;
	   $internalCountQuerystring .= $internalQuerystring;
	   $internalSelectQuerystring .= " ORDER BY begin_date, end_date, forecast_date"; 
#	   print STDERR "<!-- issuedby = $issuedby || internalcount = $internalCountQuerystring -->\n";
#	   print STDERR "<!-- internalselect = $internalSelectQuerystring -->\n";
#	   print "<br><br>#### $intCommonQuerystring ###<br><br>\n";
	   	
	   $internalCount = &searchCount($internalCountQuerystring);
   }
   $alertString .= "No internal audit results\\n" if ($internalCount < 1 && $browseInt eq "TRUE");
   $alertString .= "No external audit results\\n" if ($externalCount < 1 && $browseExt eq "TRUE");
 #	print "cgiaction = build_surv_query browseoption = $browseOption\n";
	if ($browseSurv eq "TRUE") {
		$survSelectQuerystring = "SELECT id, fiscal_year, issuedto_org_id, cancelled, team_lead_id, scope, TO_CHAR(forecast_date, 'MM/DD/YYYY'), "
	          							. "TO_CHAR(begin_date, 'MM/DD/YYYY'), TO_CHAR(end_date, 'MM/DD/YYYY'), elements, notes, issuedby_org_id, "
	          							. "status, TO_CHAR(completion_date, 'MM/DD/YYYY'), team_members, int_ext, qard_elements, "
	          							. "adequacy, implementation, effectiveness, procedures, state, title, reschedule, "
	          							. "overall_results, TO_CHAR(estbegin_date, 'MM/DD/YYYY'), TO_CHAR(estend_date, 'MM/DD/YYYY'), surveillance_seq "
	          							. "FROM $schema.surveillance "
	          							. "WHERE fiscal_year = " . substr($survFy, 2) . " ";
		my $survCountQuerystring = "SELECT COUNT(id) FROM $schema.surveillance WHERE fiscal_year = " . substr($survFy, 2) . " ";
		$survCommonQuerystring .= "AND issuedby_org_id = $survIssuedBy " if ($survIssuedBy gt '0');
		$survCommonQuerystring .= "AND team_lead_id = $lead " if ($lead gt '0');
		$survCommonQuerystring .= "AND ((begin_date BETWEEN to_date('$startfrom','MM/DD/RRRR') AND to_date('$startto','MM/DD/RRRR')) OR (estbegin_date BETWEEN to_date('$startfrom','MM/DD/RRRR') AND to_date('$startto','MM/DD/RRRR')))  " if ($startfrom gt '' && $startto gt '');
		$survCommonQuerystring .= "AND (begin_date > to_date('$startfrom','MM/DD/RRRR') OR estbegin_date > to_date('$startfrom','MM/DD/RRRR')) " if ($startfrom gt '' && $startto eq '');
		$survCommonQuerystring .= "AND (begin_date < to_date('$startto','MM/DD/RRRR') OR estbegin_date < to_date('$startto','MM/DD/RRRR'))  " if ($startfrom eq '' && $startto gt '');
		$survCommonQuerystring .= "AND end_date BETWEEN to_date('$endfrom','MM/DD/RRRR') AND to_date('$endto','MM/DD/RRRR')  " if ($endfrom gt '' && $endto gt '');
		$survCommonQuerystring .= "AND end_date > to_date('$endfrom','MM/DD/RRRR') " if ($endfrom gt '' && $endto eq '');
		$survCommonQuerystring .= "AND end_date < to_date('$endto','MM/DD/RRRR')  " if ($endfrom eq '' && $endto gt '');
		$survCommonQuerystring .= "AND completion_date BETWEEN to_date('$approvedfrom','MM/DD/RRRR') AND to_date('$approvedto','MM/DD/RRRR')  " if ($approvedfrom gt '' && $approvedto gt '');
		$survCommonQuerystring .= "AND completion_date > to_date('$approvedfrom','MM/DD/RRRR') " if ($approvedfrom gt '' && $approvedto eq '');
		$survCommonQuerystring .= "AND completion_date < to_date('$approvedto','MM/DD/RRRR')  " if ($approvedfrom eq '' && $approvedto gt '');
		$survCommonQuerystring .= "AND int_ext = 'I' " if ($#survType == 0 && $survType[0] eq 'I'); 
		$survCommonQuerystring .= "AND int_ext = 'E' " if ($#survType == 0 && $survType[0] eq 'E'); 
		$survCommonQuerystring .= "AND adequacy = '$adequacy' " if ($adequacy); 
		$survCommonQuerystring .= "AND implementation = '$implementation' " if ($implementation);
		$survCommonQuerystring .= "AND effectiveness = '$effectiveness' " if ($effectiveness);
	$selectionCriteria = "Selected Criteria - Fiscal Year: $survFy";
	$selectionCriteria .= ", Surveillance Type: Internal" if ($#survType == 0 && $survType[0] eq 'I');
	$selectionCriteria .= ", Surveillance Type: External" if ($#survType == 0 && $survType[0] eq 'E');
	$selectionCriteria .= ", Organization: " . &getOrganization($dbh, $schema, "", "", $survOrg) if ($survOrg);
	$selectionCriteria .= ", Suborganization: " . &getSuborganization($dbh, $schema, "", "", $survSuborg) if ($survSuborg);
	$selectionCriteria .= ", Supplier: " . $supplierhash{$survSupplier} if ($survSupplier);
	$selectionCriteria .= ", Location: " . &getLocation($dbh, $schema, $survLoc) if ($survLoc);
	$selectionCriteria .= ", Issued By: " . &getOrganization($dbh, $schema, "", "", $survIssuedBy) if ($survIssuedBy gt '0');
	$selectionCriteria .= ", Team Lead: " . lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname",$lead) if ($lead gt '0');
	$selectionCriteria .= ", Start Date between: $startfrom and $startto" if ($startfrom gt '' && $startto gt '');
	$selectionCriteria .= ", Start Date after: $startfrom" if ($startfrom gt '' && $startto eq '');
	$selectionCriteria .= ", Start Date before: $startto" if ($startfrom eq '' && $startto gt '');
	$selectionCriteria .= ", End Date between: $endfrom and $endto" if ($endfrom gt '' && $endto gt '');
	$selectionCriteria .= ", End Date after: $endfrom" if ($endfrom gt '' && $endto eq '');
	$selectionCriteria .= ", End Date before: $endto" if ($endfrom eq '' && $endto gt '');
	$selectionCriteria .= ", Report Completed Date between: $approvedfrom and $approvedto" if ($approvedfrom gt '' && $approvedto gt '');
	$selectionCriteria .= ", Report Completed Date after: $approvedfrom" if ($approvedfrom gt '' && $approvedto eq '');
	$selectionCriteria .= ", Report Completed Date before: $approvedto" if ($approvedfrom eq '' && $approvedto gt '');
	$selectionCriteria .= ", Adequacy: $adequacy" if ($adequacy);
	$selectionCriteria .= ", Implementation: $implementation" if ($implementation);
	$selectionCriteria .= ", Effectiveness: $effectiveness" if ($effectiveness);
	
	
        my $qard;
        my $first = 1;
        if ($#qardstring >= 0) {
        	for (my $j = 0; $j <= $#qardstring; $j++) {
    			if ($first) {
    				$qard = "AND (substr(qard_elements,$qardstring[$j]+1,1) = '1' " ;
    				$selectionCriteria .= ", QARD Elements: ";
    				$selectionCriteria .=  ($qardstring[$j]+1) if ($qardstring[$j] < 18);
    				$selectionCriteria .=  "SI" if ($qardstring[$j] == 18);
    				$selectionCriteria .=  "SII" if ($qardstring[$j] == 19);
    				$selectionCriteria .=  "SIII" if ($qardstring[$j] == 20);
    				$selectionCriteria .=  "SIV" if ($qardstring[$j] == 21);
    				$selectionCriteria .=  "SV" if ($qardstring[$j] == 22);
    				$selectionCriteria .=  "APP C" if ($qardstring[$j] == 23);
    				$first = 0;
    			}
    			else {
    				$qard .= "OR substr(qard_elements,$qardstring[$j]+1,1) = '1' " ;
    				$selectionCriteria .= ",";
    				$selectionCriteria .=  ($qardstring[$j]+1) if ($qardstring[$j] < 18);
    				$selectionCriteria .=  "SI" if ($qardstring[$j] == 18);
    				$selectionCriteria .=  "SII" if ($qardstring[$j] == 19);
    				$selectionCriteria .=  "SIII" if ($qardstring[$j] == 20);
    				$selectionCriteria .=  "SIV" if ($qardstring[$j] == 21);
    				$selectionCriteria .=  "SV" if ($qardstring[$j] == 22);
    				$selectionCriteria .=  "APP C" if ($qardstring[$j] == 23);
    			}
    			if ($j == $#qardstring) {$qard .= ") ";}
    		}
        }
	$survCommonQuerystring .= $qard;
   	$survCommonQuerystring .= "AND (TO_CHAR(begin_date,'MM') = $beginMonth OR TO_CHAR(forecast_date,'MM') = $beginMonth)" if ($beginMonth gt '0');
  		if ($survLoc || $survOrg || $survSupplier) {
  			my $whereClause;
    			if ($survLoc gt '0' && $survOrg gt '0' && $survSupplier gt '0') {
    				if ($survOrg == 1 && $survSuborg gt '0') {
    					$whereClause = " (location_id = $survLoc and ((organization_id =  1 AND  suborganization_id = $survSuborg) or supplier_id = $survSupplier)) ";
    				} else {
    					$whereClause = " (location_id = $survLoc and (organization_id = $survOrg or supplier_id = $survSupplier)) ";
    				}
  			} 
  			elsif ($survLoc gt '0' && $survOrg gt '0') {
  				if ($survOrg == 1 && $survSuborg gt '0') {
  					$whereClause = " (location_id = $survLoc and organization_id = 1 and suborganization_id = $survSuborg) ";
  				} else {
  					$whereClause = " (location_id = $survLoc and organization_id = $survOrg) ";
  				}
  			} 
  			elsif ($survLoc gt '0' && $survSupplier gt '0') {
  				$whereClause = " (location_id = $survLoc and supplier_id = $survSupplier) ";
  			} 
  			elsif ($survLoc gt '0' && $survOrg eq '0' && $survSupplier eq '0') {
  				$whereClause = " location_id = $survLoc ";
  			}
  			elsif ($survLoc eq '0' && $survOrg gt '0' && $survSupplier gt '0') {
  				if ($survOrg == 1 && $survSuborg gt '0') {
  					$whereClause = " ((organization_id = 1 and suborganization_id = $survSuborg) OR supplier_id = $survSupplier) ";
  				} else {
  					$whereClause = " (organization_id = $survOrg OR supplier_id = $survSupplier) ";
  				}
  			}
  			elsif ($survLoc eq '0' && $survOrg gt '0') {
  				if ($survOrg == 1 && $survSuborg gt '0') {
  					$whereClause = " organization_id = 1 and suborganization_id = $survSuborg ";
  				} else {
  					$whereClause = " organization_id = $survOrg ";
  				}
  			}
  			elsif ($survLoc eq '0' && $survSupplier gt '0') {
  				$whereClause = " supplier_id = $survSupplier ";
  			}
			@survIDs = &getSurveillanceID ($dbh, 'surveillance_id ', 'surveillance_org_loc', $whereClause, substr($survFy, 2));
		   	   
			foreach my $val (@survIDs) {
				$survIDs .= $val . ",";
		   }
		   chop($survIDs);
			$survIDlist .=  $survIDs . ")";   	
			$survCommonQuerystring .= "and id in $survIDlist ";
		}
   	$survSelectQuerystring .= $survCommonQuerystring;
  	 	$survCountQuerystring .= $survCommonQuerystring;
  	print "$survSelectQuerystring<br>\n";
#  	print STDERR "$survCountQuerystring\n";
  	 	$survCount = searchCount($survCountQuerystring);
   }
   if ($browseSurvReq eq "TRUE") {
		$survReqSelectQuerystring = "SELECT id, fiscal_year, requestor, TO_CHAR(request_date, 'MM/DD/YYYY'), issuedto_org_id, reason_for_request, subject_detail, "
	          						    . "surveillance_id, issuedby_org_id, disapproval_rationale FROM $schema.surveillance_request "
	          						    . "WHERE fiscal_year = " . substr($survReqFy,2) . " ";
	   my $survReqCountQuerystring = "SELECT COUNT(id) FROM $schema.surveillance_request WHERE fiscal_year = " . substr($survReqFy, 2) . " ";
		$survReqCommonQuerystring .= "AND issuedby_org_id = $survReqIssuedBy " if ($survReqIssuedBy gt '0');
	   $survReqCommonQuerystring .= "AND requestor = '$requestor' " if ($requestor gt '0');
   	$survReqCommonQuerystring .= "AND TO_CHAR(request_date,'MM') = $reqMonth" if ($reqMonth gt '0');
  		if ($survReqLoc || $survReqOrg) {
  			my $whereClause;
  			if ($survReqLoc gt '0' && $survReqOrg gt '0') {
  				$whereClause = " (location_id = $survReqLoc and organization_id = $survReqOrg) ";
  			} 
  			elsif ($survReqLoc gt '0' && $survReqOrg eq '0') {
  				$whereClause = " location_id = $survReqLoc ";
  			}
  			elsif ($survReqLoc eq '0' && $survReqOrg gt '0') {
  				$whereClause = " organization_id = $survReqOrg ";
  			}
			@survReqIDs = &getSurveillanceID ($dbh, 'request_id ', 'request_org_loc', $whereClause, substr($survReqFy, 2));
		   	   
			foreach my $val (@survReqIDs) {
				$survReqIDs .= $val . ",";
		   }
		   chop($survReqIDs);
			$survReqIDlist .=  $survReqIDs . ")";   	
			$survReqCommonQuerystring .= "and id in $survReqIDlist ";
		}
   	$survReqSelectQuerystring .= $survReqCommonQuerystring;
  	 	$survReqCountQuerystring .= $survReqCommonQuerystring;
  	 	$survReqCount = searchCount($survReqCountQuerystring);    
   }
   $alertString .= "No surveillance results\\n" if ($survCount < 1 && $browseSurv eq "TRUE");
	$alertString .= "No surveillance request results" if ($survReqCount < 1 && $browseSurvReq eq "TRUE");
	if ($alertString gt "") {
	   print "<script language=javascript type=text/javascript><!-- \n";
		print "  alert(\"$alertString\");\n";
		print " \n//--></script> \n";
	}
  	print "<!-- $browseExt -->\n";
   if ($survCount > 0 || $survReqCount > 0 || $externalCount > 0 || $internalCount > 0) {
   	print "<input type=hidden name=externalquery value=\"$externalSelectQuerystring\">\n";
	print "<input type=hidden name=internalquery value=\"$internalSelectQuerystring\">\n";
	print "<input type=hidden name=auditquery value=\"$auditSelectQuerystring\">\n";
   	print "<input type=hidden name=intfy value='$intFy'>\n";
   	print "<input type=hidden name=extfy value='$extFy'>\n";
   	print "<input type=hidden name=auditfy value='$auditFy'>\n";
   	print "<input type=hidden name=intcount value='$internalCount'>\n";
   	print "<input type=hidden name=extcount value='$externalCount'>\n";  
   	print "<input type=hidden name=intcriteria value=\"$intSelectionCriteria\">\n";
   	print "<input type=hidden name=extcriteria value=\"$extSelectionCriteria\">\n";
   	print "<input type=hidden name=intoutput value=\"$intoutput\">\n";
   	print "<input type=hidden name=extoutput value=\"$extoutput\">\n";
	  	print "<input type=hidden name=survquery value=\"$survSelectQuerystring\">\n";
	  	print "<input type=hidden name=survcriteria value=\"$selectionCriteria\">\n";
	  	print "<input type=hidden name=intoutput value=\"$intoutput\">\n";
	  	print "<input type=hidden name=extoutput value=\"$extoutput\">\n";
	  	print "<input type=hidden name=output value=\"$output\">\n";
		print "<input type=hidden name=survreqquery value=\"$survReqSelectQuerystring\">\n";
	   print "<input type=hidden name=survfy value='$survFy'>\n";
	   print "<input type=hidden name=survreqfy value='$survReqFy'>\n";
	   print "<input type=hidden name=survcount value='$survCount'>\n";
	   print "<input type=hidden name=survreqcount value='$survReqCount'>\n";
	   print "<script language=javascript type=text/javascript><!-- \n";
		print "  	document.$form.target = 'workspace';\n";
		print "  	document.$form.browseinternal.value = '$browseInt';\n";
		print "  	document.$form.browseexternal.value = '$browseExt';\n";
		print "  	document.$form.browseaudit.value = '$browseAudit';\n";
		print "  	document.$form.browsesurv.value = '$browseSurv';\n";
		print "  	document.$form.browsesurvreq.value = '$browseSurvReq';\n";
		print "  	document.$form.cgiaction.value = 'display';\n";
   	print "		var myDate = new Date();\n";
		print "		var winName = myDate.getTime();\n";
		print "		document.$form.target = winName;\n";
		print "		var newwin = window.open(\"\",winName);\n";
		print "		newwin.creator = self;\n";
		print "  	document.$form.submit();\n";
		print "\n//--></script> \n";
   }
} 
 

print "</center>\n";
print "</form>\n";
print "</Body>\n";
print "</html>\n";
&NQS_disconnect($dbh);



