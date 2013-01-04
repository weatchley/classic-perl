#
# $Source: /usr/local/homes/dattam/intradev/rcs/qa/perl/RCS/DBSurveillance.pm,v $
#
# $Revision: 1.10 $ 
#
# $Date: 2007/05/21 21:36:04 $
#
# $Author: dattam $
#
# $Locker:  $
#
# $Log: DBSurveillance.pm,v $
# Revision 1.10  2007/05/21 21:36:04  dattam
# Modilfied sub doProcessCreateSurveillance, doProcessUpdateSurveillance to copy value of estbegin_date to forecast_date for sorting
#
# Revision 1.9  2007/04/12 16:26:40  dattam
# Sub doProcessCreateSurveillance, doProcessUpdateSurveillance, getSurveillance modified to add SNL as a surveillance organization, to add overall results.
# Added new sub doProcessDeleteSurveillance to delete a surveillance from the database.
#
# Revision 1.8  2005/07/12 15:09:28  dattam
# modified subroutines getSuborganization, getOrgLocation to get actual company_name for LABs.
#
# Revision 1.7  2005/01/10 00:33:26  starkeyj
# modified the follwoing subroutines to include the MOL number:  getSurveillance, doProcessCreateSurveillance,
# do ProcessUpdateSurveillance
#
# Revision 1.6  2004/12/09 23:12:43  starkeyj
# modified the redirect on doProcessCreateSurveillance to make FY four digits
#
# Revision 1.5  2004/08/26 14:06:12  starkeyj
# modified getSurveillance to add dblink
# modified doProcessEditReport to add dblink
# modified doProcessCreateSurveillance for javascript redirect to the browse screen
#
# Revision 1.4  2004/05/30 22:39:21  starkeyj
# modified getSurveillance to add a where clause
#
# Revision 1.3  2004/03/12 20:10:57  starkeyj
# added doProcessEditReportlink
#
# Revision 1.2  2004/01/25 23:52:49  starkeyj
# modified functions to accomodate new fields
#
# Revision 1.1  2004/01/13 13:51:34  starkeyj
# Initial revision
#
#
#
package DBSurveillance;
use strict;
#use SharedHeader qw(:Constants);
#use UI_Widgets qw(:Functions);
#use DBShared qw(:Functions);
use OQA_Utilities_Lib qw(:Functions);
use OQA_specific qw(:Functions);
use OQA_Widgets qw(:Functions);
use NQS_Header qw(:Constants);
use DBI;
use DBD::Oracle qw(:ora_types);
use Carp;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
	&getSurveillance		&doProcessCreateSurveillance	&doProcessUpdateSurveillance
	&getFullUserName		&getLocation			doProcessDeleteSurveillance
	&getOrganization		&getSupplier			&getIssuedOrg
	&getDeficiency			&get_user_privs2		&getLookupValues
	&getTeamLeads			&getOrgLocation 		&getSuborganization
	&getUserPrivs			&doProcessCancelSurveillance	&doProcessEditReportlink
);
%EXPORT_TAGS =( 
    Functions => [qw(
	&getSurveillance		&doProcessCreateSurveillance	&doProcessUpdateSurveillance
	&getFullUserName		&getLocation			doProcessDeleteSurveillance
	&getOrganization		&getSupplier			&getIssuedOrg
	&getDeficiency			&get_user_privs2		&getLookupValues
	&getTeamLeads			&getOrgLocation 		&getSuborganization
	&getUserPrivs			&doProcessCancelSurveillance	&doProcessEditReportlink
    )]
);


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getSurveillance {  # routine to get the selected surveillance(s)
###################################################################################################################################
    my %args = (
        survID => 0,  # null
        selection => 'all', # all
        type => 0, # all
        single => 0,
        fiscalyear => 50,
        @_,
    );
    #$args{dbh}->{LongReadLen} = 100000000;
    my $issuedbystr = $args{selection} eq 'BSC' ? "and issuedby_org_id = 1 " : $args{selection} eq 'SNL' ? "and issuedby_org_id = 33 " : $args{selection} eq 'OQA' ? "and issuedby_org_id = 28 " : "";
    my @surveillanceList;
    my $sqlcode = "SELECT id,fiscal_year,initial_contact,elements,team_members,team_lead_id,issuedto_org_id,issuedby_org_id,";
    $sqlcode .= "scope,to_char(approval_date,'MM/DD/YYYY'),cancelled,to_char(forecast_date,'MM/YYYY'),to_char(begin_date,'MM/DD/YYYY'),";
    $sqlcode .= "to_char(end_date,'MM/DD/YYYY'),to_char(completion_date,'MM/DD/YYYY'),surveillance_seq,int_ext,status,";
    $sqlcode .= "qard_elements, reschedule, overall_results,overall,to_char(estbegin_date,'MM/YYYY'),";
    $sqlcode .= "to_char(estend_date,'MM/DD/YYYY'),procedures,state,adequacy,implementation,effectiveness,title,reportlink,dblink,mol ";
    $sqlcode .= "FROM $args{schema}.surveillance WHERE ";
    $sqlcode .= ($args{single}) ? " id = $args{survID} AND " : " ";
    $sqlcode .= " fiscal_year = substr($args{fiscalyear},-1,2) $issuedbystr $args{where} ";
    $sqlcode .= "ORDER BY issuedby_org_id, id ";
   #print "\n $sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($surveillanceList[$i]{surveillanceid},$surveillanceList[$i]{num},$surveillanceList[$i]{contact},
    $surveillanceList[$i]{elements},$surveillanceList[$i]{team},$surveillanceList[$i]{leadid},$surveillanceList[$i]{issuedto},
    $surveillanceList[$i]{issuedby},$surveillanceList[$i]{scope},$surveillanceList[$i]{approved},
    $surveillanceList[$i]{cancelled},$surveillanceList[$i]{forecast},$surveillanceList[$i]{start},$surveillanceList[$i]{end},
    $surveillanceList[$i]{completed},$surveillanceList[$i]{seq},$surveillanceList[$i]{intext},$surveillanceList[$i]{status},
    $surveillanceList[$i]{qard},$surveillanceList[$i]{reschedule},$surveillanceList[$i]{results},$surveillanceList[$i]{overall},
    $surveillanceList[$i]{estbegindate},$surveillanceList[$i]{estenddate},$surveillanceList[$i]{procedures},
    $surveillanceList[$i]{state},$surveillanceList[$i]{adequacy},$surveillanceList[$i]{implementation},
    $surveillanceList[$i]{effectiveness},$surveillanceList[$i]{title},$surveillanceList[$i]{reportlink},
    $surveillanceList[$i]{dblink},$surveillanceList[$i]{mol}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@surveillanceList);
}
###################################################################################################################################
sub getFullUserName {  # routine to get a user name
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my ($output) = $args{dbh}->selectrow_array("SELECT firstname || ' ' || lastname FROM $args{schema}.users WHERE id=$args{userID}");
    
    return($output);
}
###################################################################################################################################
sub getLocation {  # routine to get the locations for a surveillance
###################################################################################################################################
    my %args = (
        survID => 0,
        fiscalyear => 50,
        @_,
    );
    my @location;
    my $sqlstring = "SELECT l.id, initcap(city), state FROM $args{schema}.locations l,$args{schema}.surveillance_org_loc s ";
    $sqlstring .= "WHERE l.id=s.location_id AND s.fiscal_year = substr($args{fiscalyear},-1,2) AND s.surveillance_id = $args{survID} ";

    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($location[$i]{id},$location[$i]{city},$location[$i]{state}) = $csr->fetchrow_array) {
        $i++;
    }
    return(@location);
}
###################################################################################################################################
sub getOrganization {  # routine to get the organizations for a surveillance
###################################################################################################################################
    my %args = (
        survID => 0,
        fiscalyear => 50,
        @_,
    );
    my @organization;
    my $sqlstring = "SELECT o.id, abbr, organization FROM $args{schema}.organizations o,$args{schema}.surveillance_org_loc s ";
    $sqlstring .= "WHERE o.id=s.organization_id AND s.fiscal_year = substr($args{fiscalyear},-1,2) AND s.surveillance_id = $args{survID} ";
#print "<br>\n $sqlstring \n";
    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($organization[$i]{orgid},$organization[$i]{orgabbr},$organization[$i]{orgname}) = $csr->fetchrow_array) {
        $i++;
    }
    
    return(@organization);
}
###################################################################################################################################
sub getSuborganization {  # routine to get the suborganizations for a BSC surveillance
###################################################################################################################################
    my %args = (
        survID => 0,
        fiscalyear => 50,
        @_,
    );
    my @suborganization;
    my $sqlstring = "SELECT o.id, suborg, labid FROM $args{schema}.bsc_suborganizations o,$args{schema}.surveillance_org_loc s ";
    $sqlstring .= "WHERE o.id=s.suborganization_id AND s.fiscal_year = substr($args{fiscalyear},-1,2) AND s.surveillance_id = $args{survID} ";
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
sub getOrgLocation {  # routine to get the organizations and locations for a surveillance
###################################################################################################################################
    my %args = (
        survID => 0,
        fiscalyear => 50,
        locationID => 0,
        organizationID => 0,
        supplierID => 0,
        int => 'I',
        @_,
    );
    my @orglocation;
    
    my $sqlstring = "SELECT initcap(city), initcap(province), state, country, id ";
    $sqlstring .= "FROM $args{schema}.locations where surveillance_active = 'T' OR id = $args{locationID} ";
    $sqlstring .= "order by city || province ";
  
    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($orglocation[$i]{city},$orglocation[$i]{province},$orglocation[$i]{state},
    $orglocation[$i]{country},$orglocation[$i]{locationid}) = $csr->fetchrow_array) {
        $i++;
    }
    
    if ($args{intext} eq 'I') {
    	$sqlstring = "SELECT id, abbr, organization ";
    	$sqlstring .= "FROM $args{schema}.organizations where surveillance_active = 'T' OR id = $args{organizationID} ";
    	$sqlstring .= "order by abbr ";
 
    	$csr = $args{dbh}->prepare($sqlstring);
    	$status = $csr->execute;
    
    	$i = 0;
   	while (($orglocation[$i]{orgid},$orglocation[$i]{orgabbr},$orglocation[$i]{orgname}) = $csr->fetchrow_array) {
        	$i++;
    	}
    	
	$sqlstring = "SELECT id, suborg, labid ";
	$sqlstring .= "FROM $args{schema}.bsc_suborganizations ";
	$sqlstring .= defined($args{where}) ? "WHERE $args{where} ": "" ;
	$sqlstring .= "order by suborg ";

	$csr = $args{dbh}->prepare($sqlstring);
	$status = $csr->execute;

	$i = 0;
	while (($orglocation[$i]{suborgid},$orglocation[$i]{suborg}, $orglocation[$i]{labid}) = $csr->fetchrow_array) {
	   if ($orglocation[$i]{suborg} eq 'LAB')
	        {
	   		            	                 
	           my $sqlstring1 = "SELECT company_name FROM $args{schema}.qualified_supplier qs ";
	           $sqlstring1 .= "WHERE qs.id = $orglocation[$i]{labid} ";
	   	   my $csr1 = $args{dbh}->prepare($sqlstring1);
	   	   my $status1 = $csr1->execute;
	   	   $orglocation[$i]{suborg} = $csr1->fetchrow_array;
	         }
          
		$i++;
	}
	@orglocation = sort  { $a->{suborg} cmp $b->{suborg} } @orglocation;
    	
    } else {
    	$sqlstring = "SELECT id, company_name ";
    	$sqlstring .= "FROM $args{schema}.qualified_supplier where surveillance_active = 'T' OR id = $args{supplierID} ";
    	$sqlstring .= "order by company_name ";

    	$csr = $args{dbh}->prepare($sqlstring);
    	$status = $csr->execute;
    
   	 $i = 0;
   	 while (($orglocation[$i]{supplierid},$orglocation[$i]{supplier}) = $csr->fetchrow_array) {
        	$i++;
    	}
    }
    
    return(@orglocation);
}
###################################################################################################################################
sub getSupplier{  # routine to get a user name
###################################################################################################################################
    my %args = (
        survID => 0,
        fiscalyear => 50,
        @_,
    );
    my @supplier;
    
    my $sqlstring = "SELECT q.id, company_name FROM $args{schema}.qualified_supplier q,$args{schema}.surveillance_org_loc s ";
    $sqlstring .= "WHERE q.id=s.supplier_id AND s.fiscal_year = substr($args{fiscalyear},-1,2) AND s.surveillance_id = $args{survID} ";
#print "\n $sqlstring \n";
    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($supplier[$i]{supplierid},$supplier[$i]{supplier}) = $csr->fetchrow_array) {
        $i++;
    }
    
    return(@supplier);    

}
###################################################################################################################################
sub getIssuedOrg{  # routine to get an org abbreviation
###################################################################################################################################
    my %args = (
        orgID => 0,
        @_,
    );
    my $sqlstring = "SELECT abbr FROM $args{schema}.organizations ";
    $sqlstring .= "WHERE id = $args{orgID} ";

    my ($output) = $args{dbh}->selectrow_array($sqlstring);
    
    return($output);
}
###################################################################################################################################
sub getDeficiency{  # routine to get the deficiencies for a surveillance
###################################################################################################################################
    my %args = (
        recordID => 0,
        fiscalyear => 50,
        @_,
    );
    my @deficiency;
    my $sqlstring = "SELECT deficiency FROM $args{schema}.surveillance_deficiencies  ";
    $sqlstring .= "WHERE fiscal_year = substr($args{fiscalyear},-1,2) AND surveillance_id = $args{recordID} ";

    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($deficiency[$i]{deficiencytext}) = $csr->fetchrow_array) {
        $i++;
    }
    return(@deficiency);
}
###################################################################################################################################
sub getTeamLeads{  # routine to get users with team lead privileges
###################################################################################################################################
    my %args = (
        leadid => 0,
        @_,
    );
    my @values;
    my $sqlstring = "SELECT u.id, firstname || ' ' || lastname, lastname, firstname FROM $args{schema}.users u, ";
    $sqlstring .= "$args{schema}.user_privilege up, $args{schema}.privilege p ";
    $sqlstring .= "WHERE  (p.privilege like '%Surveillance Lead' and p.id = up.privilege ";
    $sqlstring .= "and u.id = up.userid) or u.id = $args{leadid} ";
    $sqlstring .= "union SELECT id, firstname || ' ' || lastname, lastname, firstname FROM $args{schema}.users ";
    $sqlstring .= "WHERE id = $args{leadid} order by 3,4 ";
#print "\n$sqlstring\n";
    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($values[$i]{id},$values[$i]{name},$values[$i]{lastname},$values[$i]{firstname}) = $csr->fetchrow_array) {
        $i++;
    }
    return(@values);
}
###################################################################################################################################
sub getLookupValues{  # routine to get generic lookup values
###################################################################################################################################
    my %args = (
        tablename => "",
        column => "",
        @_,
    );
    my @values;
    my $sqlstring = "SELECT $args{value}, $args{text} FROM $args{schema}.$args{tablename} ";
    $sqlstring .= defined($args{where}) ? "WHERE $args{where} ": "" ;
#print "\n$sqlstring\n";
    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($values[$i]{value},$values[$i]{text}) = $csr->fetchrow_array) {
        $i++;
    }
    return(@values);
}
###################################################################################################################################
sub doProcessCreateSurveillance {  # routine to insert a new surveillance into the DB
###################################################################################################################################
    my %args = (
        survID => 0,  # null
        fiscalyear => 50,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $output = "";
    my $contact = $args{dbh}->quote($settings{contact});
    my $team = $args{dbh}->quote($settings{team});
    my $scope = $args{dbh}->quote($settings{scope});
    #my @forecast = split /\//, $settings{forecast};
    #my $forecast = $args{dbh}->quote($settings{forecast});
    my $elements = $args{dbh}->quote($settings{elements});
    my $procedures = $args{dbh}->quote($settings{procedures});
    my $notes = $args{dbh}->quote($settings{notes});
    my $status = $args{dbh}->quote($settings{status}); # status is labelled notes on the form
    my $title = $args{dbh}->quote($settings{title});
    my $mol = $args{dbh}->quote($settings{mol});
    my $reschedule = $args{dbh}->quote($settings{rescheduletext});
    my $results = $args{dbh}->quote($settings{results});
    my @eststart = split /\//, $settings{eststart};
    my @orgstr = ($settings{org0},$settings{org1},$settings{org2});
    my @locstr = ($settings{loc0},$settings{loc1},$settings{loc2});
    my @suborgcount = split /,/, $settings{suborgstring};
    my $fy = substr($settings{newfyselect},-1,2);

#print "\n-->select $args{schema}.surveillance_" . lpadzero($fy,2) . "_seq.nextval from dual<br>\n";
    my ($survid) = $args{dbh}->selectrow_array("select $args{schema}.surveillance_" . lpadzero($fy,2) . "_seq.nextval from dual");
    my ($survseq) = $args{dbh}->selectrow_array("select max(surveillance_seq) from $args{schema}.surveillance where issuedby_org_id = $settings{issuedby} and fiscal_year = $fy"); 
    if (!defined($survseq)) {$survseq = 1;}
    else {$survseq = $survseq + 1;}
    
    $args{dbh}->{AutoCommit} = 0;
    $args{dbh}->{RaiseError} = 1;
    
    my $sqlcode = "INSERT into $args{schema}.surveillance ";
    $sqlcode .= "(id,fiscal_year,issuedto_org_id ";
    $sqlcode .= defined($contact) ? ",initial_contact " : "";
    $sqlcode .= ",approver_id,approval_date,team_lead_id ";
    $sqlcode .= defined($team) ? ",team_members " : "";
    $sqlcode .= defined($scope) ? ",scope" : "";
    $sqlcode .= defined($title) ? ",title" : "";
    $sqlcode .= ($settings{eststart} ne 'mm/yyyy') ? ",forecast_date" : "";
    $sqlcode .= ($settings{eststart} ne 'mm/yyyy') ? ",estbegin_date" : "";
    #$sqlcode .= defined($settings{eststart}) ? ",estbegin_date" : "";
    $sqlcode .= defined($settings{estend}) ? ",estend_date" : "";
    $sqlcode .= defined($settings{start}) ? ",begin_date" : "";
    $sqlcode .= defined($settings{end}) ? ",end_date" : "";
    $sqlcode .= defined($settings{completed}) ? ",completion_date" : "";
    $sqlcode .= defined($elements) ? ",elements" : "";
    $sqlcode .= defined($procedures) ? ",procedures" : "";
   # $sqlcode .= defined($notes) ? ",notes" : "";
    $sqlcode .= defined($status) ? ",status" : "";
    $sqlcode .= ",int_ext,issuedby_org_id,surveillance_seq,qard_elements";
    $sqlcode .= defined($settings{reschedule}) ? ",reschedule" : "";
    $sqlcode .= defined($results) ? ",overall_results" : "";
    $sqlcode .= defined($settings{overall}) ? ",overall" : "";
    $sqlcode .= defined($settings{state}) ? ",state" : "";
    $sqlcode .= defined($settings{adequacy}) ? ",adequacy" : "";
    $sqlcode .= defined($settings{implementation}) ? ",implementation" : "";
    $sqlcode .= defined($settings{effectiveness}) ? ",effectiveness" : "";
    $sqlcode .= defined($mol) ? ",mol" : "";
    
    $sqlcode .= ")VALUES ($survid,$fy,$settings{issuedto}";
    $sqlcode .= defined($contact) ? ",$contact" : "";
    $sqlcode .= ",$settings{userid},SYSDATE,$settings{leadid}";
    $sqlcode .= defined($team) ? ",$team" : "";
    $sqlcode .= defined($scope) ? ",$scope " : "";
    $sqlcode .= defined($title) ? ",$title " : "";
    $sqlcode .= ($settings{eststart} ne 'mm/yyyy') ? ",to_date('$eststart[0]/1/$eststart[1]','MM/DD/RRRR')" : "";
    $sqlcode .= ($settings{eststart} ne 'mm/yyyy') ? ",to_date('$eststart[0]/1/$eststart[1]','MM/DD/RRRR')" : "";
    #$sqlcode .= defined($settings{eststart}) ? ",to_date('$settings{eststart}','MM/DD/RRRR')" : "";
    $sqlcode .= defined($settings{estend}) ? ",to_date('$settings{estend}','MM/DD/RRRR')" : "";
    $sqlcode .= defined($settings{start}) ? ",to_date('$settings{start}','MM/DD/RRRR')" : "";
    $sqlcode .= defined($settings{end}) ? ",to_date('$settings{end}','MM/DD/RRRR')" : "";
    $sqlcode .= defined($settings{completed}) ? ",to_date('$settings{completed}','MM/DD/RRRR')" : "";
    $sqlcode .= defined($elements) ? ",$elements " : "";
    $sqlcode .= defined($procedures) ? ",$procedures " : "";
   # $sqlcode .= defined($notes) ? ",$notes " : "";
    $sqlcode .= defined($status) ? ",$status" : "";
    $sqlcode .= ",'$settings{int_ext}',$settings{issuedby},$survseq,'$settings{qardstring}'";
    $sqlcode .= defined($settings{reschedule}) ? ",'$settings{reschedule}'" : "";
    $sqlcode .= defined($results) ? ",$results " : "";
    $sqlcode .= defined($settings{overall}) ? ",'$settings{overall}' " : "";
    $sqlcode .= defined($settings{state}) ? ",'$settings{state}' " : "";
    $sqlcode .= defined($settings{adequacy}) ? ",'$settings{adequacy}' " : "";
    $sqlcode .= defined($settings{implementation}) ? ",'$settings{implementation}' " : "";
    $sqlcode .= defined($settings{effectiveness}) ? ",'$settings{effectiveness}' " : "";
    $sqlcode .= defined($mol) ? ",$mol " : "";
    $sqlcode .= ")";
    
    
    #print "\n-->$sqlcode<br>\n";

    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;  
    
    my $insertrecords = ($settings{org2} || $settings{loc2}) ? 3 : ($settings{org1} || $settings{loc1}) ? 2 : 1;
    $insertrecords = $#suborgcount + 1 if ($#suborgcount >= $insertrecords);
    
    for (my $i = 0; $i < $insertrecords; $i++) {

    	$sqlcode = "INSERT INTO $args{schema}.surveillance_org_loc ";    	
    	$sqlcode .= "(id, fiscal_year, surveillance_id ";
    	$sqlcode .= (!defined($locstr[$i]) || !($locstr[$i])) ? "" : ",location_id";
    	$sqlcode .= (!defined($orgstr[$i]) || !($orgstr[$i])) ? "" : ",organization_id";
    	$sqlcode .= ($i != 0  || !($settings{supplier})) ? "" : ",supplier_id";
    	$sqlcode .= (!defined($suborgcount[$i]) || !($suborgcount[$i])) ? "" : ",suborganization_id";    	
    	$sqlcode .= ")\nVALUES ( $i + 1,substr($args{fiscalyear},-1,2),$survid";
    	$sqlcode .= (!defined($locstr[$i]) || !($locstr[$i])) ? "" : ",$locstr[$i]";
    	$sqlcode .= (!defined($orgstr[$i]) || !($orgstr[$i])) ? "" : ",$orgstr[$i]";
    	$sqlcode .= ($i != 0  || !($settings{supplier})) ? "" : ",$settings{supplier}";
    	$sqlcode .= (!defined($suborgcount[$i]) || !($suborgcount[$i])) ? "" : ",$suborgcount[$i]"; 
    	$sqlcode .= ")";

    #	print "\n-->$sqlcode<br>\n";
    	$csr = $args{dbh}->prepare($sqlcode);
    	$csr->execute;
    
    }

    
    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Surveillance $survid inserted by $settings{username}");
    
    #$output .= doAlertBox(text => "Surveillance $args{survID} successfully updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "   document.surveillance2.fiscalyear.value = $fy + 2000;\n";
    $output .= "   submitForm('surveillance2','browse');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessUpdateSurveillance {  # routine to update a surveillance in the DB
###################################################################################################################################
    my %args = (
        survID => 0,  # null
        fiscalyear => 50,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $output = "";
    my $contact = $args{dbh}->quote($settings{contact});
    my $team = $args{dbh}->quote($settings{team});
    my $scope = $args{dbh}->quote($settings{scope});
    #my @forecast = split /\//, $settings{forecast};
    #my $forecast = $args{dbh}->quote($settings{forecast});
    my $elements = $args{dbh}->quote($settings{elements});
    my $procedures = $args{dbh}->quote($settings{procedures});
    my $notes = $args{dbh}->quote($settings{notes});
    my $title = $args{dbh}->quote($settings{title});
    my $mol = $args{dbh}->quote($settings{mol});
    my $status = $args{dbh}->quote($settings{status});
    my $reschedule = $args{dbh}->quote($settings{rescheduletext});
    my $results = $args{dbh}->quote($settings{results});
    my @eststart = split /\//, $settings{eststart};
    my @orgstr = ($settings{org0},$settings{org1},$settings{org2});
    my @locstr = ($settings{loc0},$settings{loc1},$settings{loc2});
    my @deficiencystr = ($settings{deficiency1},$settings{deficiency2},$settings{deficiency3});
    my @suborgcount = split /,/, $settings{suborgstring};

    $args{dbh}->{AutoCommit} = 0;
    $args{dbh}->{RaiseError} = 1;
    
    my $sqlcode = "UPDATE $args{schema}.surveillance ";
    $sqlcode .= "SET issuedto_org_id = $settings{issuedto}, ";
    $sqlcode .= "initial_contact = $contact, ";
   # $sqlcode .= "cancelled = '$settings{cancelled}', ";
    $sqlcode .= "team_lead_id = $settings{leadid}, ";
    $sqlcode .= "team_members = $team, ";
    $sqlcode .= "scope = $scope, ";
    $sqlcode .= "title = $title, ";
    $sqlcode .= "forecast_date = to_date('$eststart[0]/1/$eststart[1]','MM/DD/RRRR'), " if ($settings{eststart} ne 'mm/yyyy');
    #$sqlcode .= "forecast_date = $forecast, ";
    $sqlcode .= "estbegin_date = to_date('$eststart[0]/1/$eststart[1]','MM/DD/RRRR'), " if ($settings{eststart} ne 'mm/yyyy');
    #$sqlcode .= "estbegin_date = to_date('$settings{eststart}','MM/DD/RRRR'), ";
    $sqlcode .= "estend_date = to_date('$settings{estend}','MM/DD/RRRR'), ";
    $sqlcode .= "begin_date = to_date('$settings{start}','MM/DD/RRRR'), ";
    $sqlcode .= "end_date = to_date('$settings{end}','MM/DD/RRRR'), ";
    $sqlcode .= "completion_date = to_date('$settings{completed}','MM/DD/RRRR'), ";
    $sqlcode .= "elements = $elements, ";
    $sqlcode .= "procedures = $procedures, ";
    $sqlcode .= "notes = $notes, ";
    $sqlcode .= "status = $status, ";
    $sqlcode .= "mol = $mol, ";
    $sqlcode .= "qard_elements = '$settings{qardstring}', ";
    $sqlcode .= "reschedule = $reschedule, ";
    $sqlcode .= "overall_results = $results, ";
    $sqlcode .= "overall = '$settings{overall}', ";
    $sqlcode .= "state = '$settings{state}', ";
    $sqlcode .= "adequacy = '$settings{adequacy}', ";
    $sqlcode .= "implementation = '$settings{implementation}', ";
    $sqlcode .= "effectiveness = '$settings{effectiveness}' ";
    $sqlcode .= "WHERE id = $args{survID} AND fiscal_year = substr($args{fiscalyear},-1,2) ";

 #   print "\n-->$sqlcode\n";

    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;

    $sqlcode = "DELETE from $args{schema}.surveillance_org_loc ";
    $sqlcode .= "WHERE surveillance_id = $args{survID} AND fiscal_year = substr($args{fiscalyear},-1,2) ";

  #  print "\n--><br>$sqlcode\n";

    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
        
    my $insertrecords = ($settings{org2} || $settings{loc2}) ? 3 : ($settings{org1} || $settings{loc1}) ? 2 : 1;
    $insertrecords = $#suborgcount + 1 if ($#suborgcount >= $insertrecords);
    
    for (my $i = 0; $i < $insertrecords; $i++) {

    	$sqlcode = "INSERT INTO $args{schema}.surveillance_org_loc ";    	
    	$sqlcode .= "(id, fiscal_year, surveillance_id ";
    	$sqlcode .= (!defined($locstr[$i]) || !($locstr[$i])) ? "" : ",location_id";
    	$sqlcode .= (!defined($orgstr[$i]) || !($orgstr[$i])) ? "" : ",organization_id";
    	$sqlcode .= ($i != 0  || !($settings{supplier})) ? "" : ",supplier_id";
    	$sqlcode .= (!defined($suborgcount[$i]) || !($suborgcount[$i])) ? "" : ",suborganization_id";    	
    	$sqlcode .= ")\nVALUES ( $i + 1,substr($args{fiscalyear},-1,2),$args{survID}";
    	$sqlcode .= (!defined($locstr[$i]) || !($locstr[$i])) ? "" : ",$locstr[$i]";
    	$sqlcode .= (!defined($orgstr[$i]) || !($orgstr[$i])) ? "" : ",$orgstr[$i]";
    	$sqlcode .= ($i != 0  || !($settings{supplier})) ? "" : ",$settings{supplier}";
    	$sqlcode .= (!defined($suborgcount[$i]) || !($suborgcount[$i])) ? "" : ",$suborgcount[$i]"; 
    	$sqlcode .= ")";
#print "\n--><br>$sqlcode\n";
    	$csr = $args{dbh}->prepare($sqlcode);
    	$csr->execute;
    
    }
    
    if ($settings{deficiency1} || $settings{deficiency2} || $settings{deficiency3}) {
    	$sqlcode = "DELETE from $args{schema}.surveillance_deficiencies ";
    	$sqlcode .= "WHERE surveillance_id = $args{survID} AND fiscal_year = substr($args{fiscalyear},-1,2) ";

  	  #print "\n--><br>$sqlcode\n";
    	$csr = $args{dbh}->prepare($sqlcode);
    	$csr->execute;
    
    	for (my $i = 1; $i <= 3; $i++) {
		if ($deficiencystr[$i-1]) {
			my $deficiency = $args{dbh}->quote($deficiencystr[$i-1]);
    			$sqlcode = "INSERT INTO $args{schema}.surveillance_deficiencies ";    	
    			$sqlcode .= "(id, surveillance_id, fiscal_year, issuedto_org_id, deficiency)\n ";
    			$sqlcode .= "VALUES ( $i,$args{survID},substr($args{fiscalyear},-1,2),1,$deficiency)";
		#print "\n--><br>$sqlcode\n";
    			$csr = $args{dbh}->prepare($sqlcode);
    			$csr->execute;    
    		} 
    	}
    }
    
    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Surveillance $args{survID} updated");
    
    #$output .= doAlertBox(text => "Surveillance $args{survID} successfully updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('surveillance2','browse');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessCancelSurveillance {  # routine to cancel a surveillance in the DB
###################################################################################################################################
    my %args = (
        survID => 0,  # null
        fiscalyear => 50,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $output = "";

    $args{dbh}->{AutoCommit} = 0;
    $args{dbh}->{RaiseError} = 1;
    
    my $sqlcode = "UPDATE $args{schema}.surveillance ";
    $sqlcode .= "SET cancelled = 'Y', state = 'Cancelled' ";
    $sqlcode .= "WHERE id = $args{survID} AND fiscal_year = substr($args{fiscalyear},-1,2) ";

 #   print "\n-->$sqlcode\n";

    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;

    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Surveillance $args{survID} updated");
    
    #$output .= doAlertBox(text => "Surveillance $args{survID} successfully cancelled");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('surveillance2','browse');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessDeleteSurveillance {  # routine to delete a surveillance from the DB
###################################################################################################################################
    my %args = (
        survID => 0,  # null
        fiscalyear => 50,
        @_,
    );
    
    my $output = "";
    my $sqlcode;
    my $sqlcode2;

    $args{dbh}->{AutoCommit} = 0;
    $args{dbh}->{RaiseError} = 1;
    
    $sqlcode = "DELETE from $args{schema}.surveillance_org_loc ";
    $sqlcode .= "WHERE surveillance_id = $args{survID} AND fiscal_year = substr($args{fiscalyear},-1,2) ";
    
    $sqlcode2 = "DELETE from $args{schema}.surveillance WHERE id = $args{survID} AND fiscal_year = substr($args{fiscalyear},-1,2)";


    #print  "\n-->$sqlcode\n";
    #print "\n-->$sqlcode2\n";

    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;

    $csr = $args{dbh}->prepare($sqlcode2);
   $csr->execute;
    
    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Surveillance $args{survID} deleted for fy $args{fiscalyear}");
    
    #$output .= doAlertBox(text => "Surveillance $args{survID} successfully deleted");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('surveillance2','browse');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessEditReportlink {  # routine to edit or add a surveillance reportlink 
###################################################################################################################################
    my %args = (
        survID => 0,  # null
        fiscalyear => 50,
        @_,
    );

    my $output = "";

    $args{dbh}->{AutoCommit} = 0;
    $args{dbh}->{RaiseError} = 1;
    
    my $sqlcode = "UPDATE $args{schema}.surveillance ";
    $sqlcode .= "SET reportlink = '$args{reportlink}', dblink = '$args{dbname}' ";
    $sqlcode .= "WHERE id = $args{survID} AND fiscal_year = substr($args{fiscalyear},-1,2) ";

    #print "\n-->$sqlcode\n";

    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;

    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Surveillance $args{survID} reportlink updated");
    
    #$output .= doAlertBox(text => "Surveillance $args{survID} reportlink successfully updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('surveillance2','browse');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub getUserPrivs{  # routine to check the user's privileges
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my %userPrivilegeHash;
	 
    # get all privileges and set to 'F'
    my $privquery = "select privilege from $args{schema}.privilege";
    my $csr = $args{dbh}->prepare ($privquery);
    $csr->execute;
    while (my @values = $csr->fetchrow_array) {
	 $userPrivilegeHash{$values[0]} = 0;
    }
    $csr->finish;
	 
    #set the user's privs to 'T'
    my $userprivquery = "select p.privilege from $args{schema}.privilege p, $args{schema}.user_privilege up ";
    $userprivquery .= "where up.userid = $args{userID} and up.privilege = p.id ";

    $csr = $args{dbh}->prepare ($userprivquery);
    $csr->execute;
    while (my @privs = $csr->fetchrow_array) {
	 $userPrivilegeHash{$privs[0]} = 1;
    }
    $csr->finish;

    return (%userPrivilegeHash);
}
###################################################################################################################################


1; #return true

