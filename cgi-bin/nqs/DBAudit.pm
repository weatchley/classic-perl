#
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/qa/perl/RCS/DBAudit.pm,v $
#
# $Revision: 1.23 $ 
#
# $Date: 2009/09/22 18:20:47 $
#
# $Author: higashis $
#
# $Locker: higashis $
#
# $Log: DBAudit.pm,v $
# Revision 1.23  2009/09/22 18:20:47  higashis
# major version release.
#
# Revision 1.22  2009/03/24 20:45:58  patelr
# added delete attachment function
#
# Revision 1.21  2009/02/10 20:49:29  patelr
# edited doProcessCreateAudit doProcessUpdateAudit to allow editing of reports issued by lead lab
#
# Revision 1.20  2009/02/04 00:15:00  patelr
# Added filename validation for ll and snl prefixes
#
# Revision 1.19  2009/01/17 00:02:19  patelr
# WR0115 - changes for file upload
#
# Revision 1.18  2007/11/15 20:05:22  dattam
# ns when the Fiscal year is before 2008
# and sort the internal and external audits by scheduled date for Fiscal Year 2008 and after
#
# Revision 1.17  2007/10/09 18:11:07  dattam
# sub getAudit modified to sort the Internal Audits by scheduled date instead of issued-by organizations
#
# Revision 1.16  2007/10/03 16:36:43  dattam
# sub getAudit modified to sort the External Audits by scheduled date instead of issued-by organizations
# sub getSequences modified to chack for "EM/RW" Audits
#
# Revision 1.15  2007/09/26 17:56:33  dattam
# Sub getAudit modified so that $issuedbystr has choice for 2008 external audits
# Sub doProcessCreateAudit, doProcessUpdateAudit modified so that the control is transferred to audit2.pl with audit_selection value as "external" for FY 2008 external audits
#
# Revision 1.14  2007/04/12 16:18:37  dattam
# Sub doProcessCreateAudit, doProcessUpdateAudit modified to add SNL as an issued-by organization.
# Sub getAudit modified to add SNL in the $issuedbystr.
# Sub doProcessCreateAudit, doProcessUpdateAudit modified to enter value of
# overall results.
#
# Revision 1.13  2005/10/31 20:03:30  dattam
# Modified subroutines getAudit, doProcessCreateAudit, doBrowseAudit, doViewAudit to accomodate 'other' assessments and to select and display the alternate id for assessments defined as 'other' and modify parameters for writeConditionReport
#
# Revision 1.12  2005/07/12 15:06:27  dattam
# modified subroutines getSuborganization, getOrgLocation to get actual company-name for LABs.
#
# Revision 1.11  2005/04/20 13:34:54  starkeyj
# modified doProcessUpdateAudit to insert NULL when team lead id value is zero
#
# Revision 1.10  2005/01/10 00:29:54  starkeyj
# modified the following subroutines to include the MOL number:  getAudit, doProcessCreateAudit, doProcessUpdateAudit
#
# Revision 1.9  2004/10/21 18:43:15  starkeyj
# modified getAudit to check for external_bsc and external_oqa and modified the irder by for external audits
#
# Revision 1.8  2004/08/26 22:34:51  starkeyj
# modified doProcessCreateAudit to add fiscal year to javascript that redirects form to browse screen
#
# Revision 1.6  2004/08/18 17:46:18  starkeyj
# modified to add database selection for report links
#
# Revision 1.5  2004/06/28 14:12:33  starkeyj
# modified getteamLead to select audit team leads instead of surveillance team leads
#
# Revision 1.4  2004/05/30 22:09:27  starkeyj
# modified getAudit to add a where clause and modified getLocation to select country
#
# Revision 1.3  2004/05/17 23:30:47  starkeyj
# modified doProcessCreateAudit so audit_seq is entered as zero instead of a blank
#
# Revision 1.2  2004/04/08 14:24:49  starkeyj
# modified the getOrgLocation function to check for external audit locations
#
# Revision 1.1  2004/04/07 15:08:05  starkeyj
# Initial revision
#
#
#
package DBAudit;
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
	&getAudit			&doProcessCreateAudit		&doProcessUpdateAudit
	&getFullUserName		&getLocation			&getCurrentFiscalyear
	&getOrganization		&getSupplier			&getIssuedOrg
	&get_user_privs2		&getLookupValues		&doProcessEditReportlink
	&getTeamLeads			&getOrgLocation 		&getSuborganization
	&getUserPrivs			&doProcessCancelAudit		&getSequences
	&doProcessDeleteAudit		&getMaxrevision
       &doDeleteAuditAttachment
);	
%EXPORT_TAGS =( 
    Functions => [qw(
	&getAudit			&doProcessCreateAudit		&doProcessUpdateAudit
	&getFullUserName		&getLocation			&getCurrentFiscalyear
	&getOrganization		&getSupplier			&getIssuedOrg
	&get_user_privs2		&getLookupValues		&doProcessEditReportlink
	&getTeamLeads			&getOrgLocation 		&getSuborganization
	&getUserPrivs			&doProcessCancelAudit		&getSequences
	&doProcessDeleteAudit		&getMaxrevision
       &doDeleteAuditAttachment
    )]
);


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getAudit {  # routine to get the selected audit(s)
###################################################################################################################################
    my %args = (
        auditID => 0,  # null
        table => '',
        selection => 'all', # all
        type => 0, # all
        single => 0,
        fiscalyear => 50,
        @_,
    );
    #$args{dbh}->{LongReadLen} = 100000000;
    
    my $issuedbystr = $args{selection} eq 'internal_bsc' || $args{selection} eq 'external_bsc' ? "and issuedby_org_id = 1 " :
    $args{selection} eq 'internal_snl' || $args{selection} eq 'external_snl' ? "and issuedby_org_id = 33 " :
    $args{selection} eq 'external' && $args{fiscalyear} eq '08' ? "" :
    $args{selection} eq 'internal_oqa' || $args{selection} eq 'external_oqa' ? "and issuedby_org_id = 28 " : $args{selection} eq 'internal_em' ? "and issuedby_org_id = 3 " 
    : $args{selection} eq 'internal_ocrwm' ? "and issuedby_org_id = 24 " : $args{selection} eq 'other' ? "and issuedby_org_id not in (1,3,17,24,28,33) " : $args{single} == 0 ? "and issuedby_org_id in (1,3,17,24,28,33) " : "";
    
    my @auditList;
    my $sqlcode = "SELECT id,fiscal_year,audit_seq,audit_type,issuedto_org_id,team_lead_id,team_members, ";
    $sqlcode .= "scope,to_char(forecast_date,'MM/YYYY'),modified,approver_id,approval_date,cancelled,to_char(begin_date,'MM/DD/YYYY'), ";
    $sqlcode .= "to_char(end_date,'MM/DD/YYYY'),to_char(completion_date,'MM/DD/YYYY'),notes,issuedby_org_id, ";
    $sqlcode .= "reportlink,dblink,qard_elements,procedures,reschedule, ";
    $sqlcode .= "overall_results,overall,title,state,adequacy,implementation,effectiveness,mol,otherid, ";
    $sqlcode .= ($args{table} eq 'internal') ? "approver2_id,to_char(approval2_date,'MM/DD/YYYY'),NULL,NULL " : "NULL,NULL,qualified_supplier_id,product ";
    $sqlcode .= "FROM $args{schema}." . $args{table} . "_audit WHERE revision = 0 AND ";
    $sqlcode .= ($args{single}) ? " id = $args{auditID} AND " : " ";
   $sqlcode .= " fiscal_year = substr(lpad($args{fiscalyear},2),-2) $issuedbystr $args{where} ";
  
    $sqlcode .= "ORDER BY issuedby_org_id desc, to_char(begin_date,'YYYY/MM/DD') || to_char(forecast_date,'YYYY/MM/DD'), audit_seq, audit_type " if (($args{table} eq 'internal') && ($args{fiscalyear} lt '08'));
    $sqlcode .= "ORDER BY to_char(begin_date,'YYYY/MM/DD') || to_char(forecast_date,'YYYY/MM/DD'), audit_seq, audit_type " if (($args{table} eq 'internal') && ($args{fiscalyear} ge '08'));
    $sqlcode .= "ORDER BY issuedby_org_id desc, to_char(begin_date,'YYYY/MM/DD') || to_char(forecast_date,'YYYY/MM/DD'), audit_type, audit_seq " if (($args{table} eq 'external') && ($args{fiscalyear} lt '08'));
    $sqlcode .= "ORDER BY to_char(begin_date,'YYYY/MM/DD') || to_char(forecast_date,'YYYY/MM/DD'), audit_type, audit_seq " if (($args{table} eq 'external') && ($args{fiscalyear} ge '08'));
   
   #print "\n<br>*** $sqlcode <br>\n";
   
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($auditList[$i]{auditid},$auditList[$i]{fy},$auditList[$i]{seq},$auditList[$i]{type},$auditList[$i]{issuedto},
    $auditList[$i]{lead},$auditList[$i]{team},$auditList[$i]{scope},$auditList[$i]{forecast},$auditList[$i]{modified},
    $auditList[$i]{approver},$auditList[$i]{approvaldate},$auditList[$i]{cancelled},$auditList[$i]{begindate},
    $auditList[$i]{enddate},$auditList[$i]{completion_date},$auditList[$i]{notes},$auditList[$i]{issuedby},
    $auditList[$i]{reportlink},$auditList[$i]{dblink},$auditList[$i]{qard},$auditList[$i]{procedures},$auditList[$i]{reschedule},
    $auditList[$i]{results},$auditList[$i]{overall},$auditList[$i]{title},$auditList[$i]{state},$auditList[$i]{adequacy},$auditList[$i]{implementation},
    $auditList[$i]{effectiveness},$auditList[$i]{mol},$auditList[$i]{otherid},$auditList[$i]{approver2},$auditList[$i]{approval2date},$auditList[$i]{supplier},
    $auditList[$i]{product}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@auditList);
}
###################################################################################################################################
sub getSequences {  # routine to get the sequence numbers for an audit type
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my @sequenceList;
    my $audittype;
    my $auditorgstr;
   
    if ($args{type} eq 'C' || $args{type} eq 'P' || $args{type} eq 'PB' || $args{type} eq 'P/PB' || $args{type} eq 'ALL' ) {
   	$audittype = " ";
   	$auditorgstr = $args{issuedby} eq "3" ? " and issuedby_org_id = $args{issuedby} " : "";
    }
    elsif ($args{type} eq 'SA'  ) {
   	$audittype = " and audit_type = 'SA' ";
   	$auditorgstr = "  ";
    }
    elsif ($args{type} eq 'SFE'  ) {
   	$audittype = " and audit_type = 'SFE' ";
   	$auditorgstr = "  ";
    }
   
    my $sqlquery = "SELECT distinct audit_seq from " . $args{schema} . "." . $args{table} . "_audit where ";
    $sqlquery .= "fiscal_year = $args{fiscalyear} and revision = 0  $audittype $auditorgstr and audit_seq != 0 order by audit_seq";
print STDERR  "\n** $args{type} -- $sqlquery **\n";
    my $csr = $args{dbh}->prepare($sqlquery);
    $csr->execute;
    
    my $i = 0;
    while (($sequenceList[$i]) = $csr->fetchrow_array) {
            $i++;
    }
    
    return(@sequenceList);
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
sub getLocation {  # routine to get the locations for an audit
###################################################################################################################################
    my %args = (
        auditID => 0,
        fiscalyear => 50,
        @_,
    );
    my @location;
    my $sqlstring = "SELECT l.id, initcap(city), initcap(province), state, country FROM $args{schema}.locations l,";
    $sqlstring .= ($args{table} eq 'internal' ? "$args{schema}.internal_audit_org_loc al " : "$args{schema}.external_audit_locations al " );
    #$sqlstring .= "WHERE l.id=al.location_id AND al.fiscal_year = substr($args{fiscalyear},-1,2) AND al." ;
    
      if($args{fiscalyear}>2009){
      	$sqlstring .= "WHERE l.id=al.location_id AND al.fiscal_year = substr($args{fiscalyear},-2,2) AND al." ;
      }else{
      	$sqlstring .= "WHERE l.id=al.location_id AND al.fiscal_year = substr($args{fiscalyear},-1,2) AND al." ;
      }
    
    $sqlstring .= ($args{table} eq 'internal' ? "internal_audit_id = $args{auditID} " : "external_audit_id = $args{auditID} " );
    $sqlstring .= "AND al.revision = 0 ";
#print "\n<br>$sqlstring \n";
    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($location[$i]{id},$location[$i]{city},$location[$i]{province},$location[$i]{state},$location[$i]{country}) = $csr->fetchrow_array) {
        $i++;
    }
    return(@location);
}
###################################################################################################################################
sub getOrganization {  # routine to get the organizations for an audit
###################################################################################################################################
    my %args = (
        auditID => 0,
        fiscalyear => 50,
        @_,
    );
    my @organization;
    my $sqlstring = "SELECT o.id, abbr, organization FROM $args{schema}.organizations o,$args{schema}.internal_audit_org_loc ia ";
    
    #$sqlstring .= "WHERE o.id=ia.organization_id AND ia.fiscal_year = substr($args{fiscalyear},-1,2) AND ia.internal_audit_id = $args{auditID} ";
    
      if($args{fiscalyear}>2009){
      	$sqlstring .= "WHERE o.id=ia.organization_id AND ia.fiscal_year = substr($args{fiscalyear},-2,2) AND ia.internal_audit_id = $args{auditID} ";
      }else{
      	$sqlstring .= "WHERE o.id=ia.organization_id AND ia.fiscal_year = substr($args{fiscalyear},-1,2) AND ia.internal_audit_id = $args{auditID} ";
      }
    
    $sqlstring .= "AND ia.revision = 0 ";
#print "\n<br>$sqlstring \n";
    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($organization[$i]{orgid},$organization[$i]{orgabbr},$organization[$i]{orgname}) = $csr->fetchrow_array) {
        $i++;
    }
    
    return(@organization);
}
###################################################################################################################################
sub getSuborganization {  # routine to get the suborganizations for a BSC audit
###################################################################################################################################
    my %args = (
        auditID => 0,
        fiscalyear => 50,
        @_,
    );
    my @suborganization;
    my $sqlstring = "SELECT o.id, suborg, labid FROM $args{schema}.bsc_suborganizations o,$args{schema}.internal_audit_org_loc ia ";
    
    #$sqlstring .= "WHERE o.id=ia.suborganization_id AND ia.fiscal_year = substr($args{fiscalyear},-1,2) AND ia.internal_audit_id = $args{auditID} ";
    
    if($args{fiscalyear}>2009){
      	$sqlstring .= "WHERE o.id=ia.suborganization_id AND ia.fiscal_year = substr($args{fiscalyear},-2,2) AND ia.internal_audit_id = $args{auditID} ";
      }else{
      	$sqlstring .= "WHERE o.id=ia.suborganization_id AND ia.fiscal_year = substr($args{fiscalyear},-1,2) AND ia.internal_audit_id = $args{auditID} ";
      }
      
    $sqlstring .= "AND ia.revision = 0 ";
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
sub getOrgLocation {  # routine to get the organizations and locations for an audit
###################################################################################################################################
    my %args = (
        auditID => 0,
        fiscalyear => 50,
        locationID => 0,
        organizationID => 0,
        supplierID => 0,
        table => '',
        @_,
    );
    my @orglocation;
    
    my $sqlstring = "SELECT initcap(city), initcap(province), state, country, id ";
    $sqlstring .= "FROM $args{schema}.locations where $args{table}_active = 'T' OR id = $args{locationID} ";
    $sqlstring .= "order by city || province ";

    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($orglocation[$i]{city},$orglocation[$i]{province},$orglocation[$i]{state},
    $orglocation[$i]{country},$orglocation[$i]{locationid}) = $csr->fetchrow_array) {
        $i++;
    }
    
    if ($args{table} eq 'internal') {
    	$sqlstring = "SELECT id, abbr, organization ";
    	$sqlstring .= "FROM $args{schema}.organizations where internal_active = 'T' OR id = $args{organizationID} ";
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
    	$sqlstring .= "FROM $args{schema}.qualified_supplier where external_active = 'T' OR id = $args{supplierID} ";
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
sub getSupplier{  # routine to get a supplier id and name
###################################################################################################################################
    my %args = (
        auditID => 0,
        fiscalyear => 50,
        @_,
    );
    my @supplier;
    
    my $sqlstring = "SELECT q.id, company_name FROM $args{schema}.qualified_supplier q,$args{schema}.external_audit ea ";
    
    #$sqlstring .= "WHERE q.id=ea.qualified_supplier_id AND ea.fiscal_year = substr($args{fiscalyear},-1,2) AND ea.id = $args{auditID} ";
    
        if($args{fiscalyear}>2009){
      	$sqlstring .= "WHERE q.id=ea.qualified_supplier_id AND ea.fiscal_year = substr($args{fiscalyear},-2,2) AND ea.id = $args{auditID} ";
      }else{
      	$sqlstring .= "WHERE q.id=ea.qualified_supplier_id AND ea.fiscal_year = substr($args{fiscalyear},-1,2) AND ea.id = $args{auditID} ";
      }
    
    
    $sqlstring .= "AND ea.revision = 0 ";
#print "\n<br>$sqlstring \n";
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
sub getTeamLeads{  # routine to get users with team lead privileges
###################################################################################################################################
    my %args = (
        leadid => 0,
        @_,
    );
    my @values;
    #my $priv = $args{table} eq 'internal' ? "Internal Lead" : "Supplier Lead";
    my $priv = "Team Lead";
    my $sqlstring = "SELECT u.id, firstname || ' ' || lastname, lastname, firstname FROM $args{schema}.users u, ";
    $sqlstring .= "$args{schema}.user_privilege up, $args{schema}.privilege p ";
    #$sqlstring .= "WHERE  (p.privilege like '%" . $priv . "' and p.id = up.privilege ";
    $sqlstring .= "WHERE  (p.privilege = '" . $priv . "' and p.id = up.privilege ";
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
sub getCurrentFiscalyear{  # routine to get the current fiscal year
###################################################################################################################################
    my %args = (
        @_,
    );
    my $currentFiscalyear;
    my $csh = $args{dbh} -> prepare ("select to_char(sysdate,'MM/YYYY') from dual");
    $csh -> execute;
    my $mmyyyy = $csh -> fetchrow_array;
    $csh -> finish;
    
    my $mm = substr($mmyyyy,0,2);
    if ($mm > 9) {$currentFiscalyear = substr($mmyyyy,3) + 1;}
    else { $currentFiscalyear = substr($mmyyyy,3); }
    
    return($currentFiscalyear);
}

###################################################################################################################################
sub doProcessCreateAudit {  # routine to insert a new audit into the DB
###################################################################################################################################
    my %args = (
        auditID => 0,  # null
        fiscalyear => 50,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $output = "";
    my $team = $args{dbh}->quote($settings{team});
    my $scope = $args{dbh}->quote($settings{scope});
    my @forecast = split /\//, $settings{forecast};
    my $procedures = $args{dbh}->quote($settings{procedures});
    my $notes = $args{dbh}->quote($settings{notes});
    my $title = $args{dbh}->quote($settings{title});
    my $status = $args{dbh}->quote($settings{status});
    my $product = $args{dbh}->quote($settings{product});
    my $mol = $args{dbh}->quote($settings{mol});
    my $otherid = $args{dbh}->quote($settings{otherid});
    my $reschedule = $args{dbh}->quote($settings{rescheduletext});
    my $results = $args{dbh}->quote($settings{results});
    my @orgstr = ($settings{org0},$settings{org1},$settings{org2},$settings{org3},$settings{org4},$settings{org5},$settings{org6});
    my @locstr = ($settings{loc0},$settings{loc1},$settings{loc2},$settings{loc3},$settings{loc4},$settings{loc5},$settings{loc6});
    my @suborgcount = split /,/, $settings{suborgstring};
    my ($auditid) = $args{dbh}->selectrow_array("select $args{schema}.audit_" . substr($args{fiscalyear},-2) . "_seq.nextval from dual");
    
    ## Attachment Code
    #
    use CGI;
    my $q = new CGI();
    my @filenames = $q->param('attachment');
    my $newFilename = "";
    my $yearf = "";  
    my $reportlink = "";
    my $index = "";

    foreach $index (@filenames) {
        if ($index) {
            $newFilename = $index;
            $newFilename =~ s/\\/\//g;
            $newFilename =~ s!^.*/!!;  # return only the filename, remove the file path
            $newFilename =~ s/&//g;
            $newFilename =~ s/ /_/g;
        }
      }
      
    if($newFilename){
      $yearf = substr($args{fiscalyear},-2);  
      $reportlink = "fy $yearf / $newFilename ";
      $reportlink =~ s/ //g;
      
      my $testname1 = "i $yearf a";
      $testname1 =~ s/ //g;
      my $testname2 = "e $yearf a";
      $testname2 =~ s/ //g;
      my $testname3 = "doe $yearf a";
      $testname3 =~ s/ //g;
      my $testname4 = "ll $yearf a";
      $testname4 =~ s/ //g;
      my $testname5 = "snl $yearf a";
      $testname5 =~ s/ //g;  
      my $inputname = substr($newFilename,0,-7);
      if(substr($inputname,-8) ne $testname1  && substr($inputname,-8) ne $testname2 && substr($inputname,-8) ne $testname3 && substr($inputname,-8) ne $testname4 && substr($inputname,-8) ne $testname5){
         print "<script language = 'JavaScript'>alert(\"File \'$newFilename\' does not meet filenaming conventions!\\nNaming convention is [department name] PLUS [last two digits of year] PLUS ['a' for audit document] PLUS [three digit document number]\\nFilename should begin with [\'i\' or \'e\' or \'doe\' or \'ll\' or \'snl\'][last two digits of year][\'a\']\\nFor example, \'i09a001.pdf\'\");</script>\n";
         return;
      }
      
       
      my $upload_dir = "$SYSPathRoot /www/nqs/reports/";
      $upload_dir =~ s/ //g;
      my $dir = "$upload_dir fy $yearf";
         $dir =~ s/ //g;
      if (-e "$upload_dir$reportlink") {
         print "<script language = 'JavaScript'>alert('File $newFilename already exists!');</script>\n";
         return;
        } 
       unless(-d $dir){
         mkdir $dir or die;
         chmod("$dir", 0770);
        }

         my $upload_filehandle = $q->upload("attachment"); 
         open ( UPLOADFILE, ">$upload_dir$reportlink" ) or die "$!"; 
         binmode UPLOADFILE; 
         while ( <$upload_filehandle> ) 
         { 
          print UPLOADFILE; 
         } 
         chmod("$upload_dir$reportlink", 0770);
         close UPLOADFILE;
    }
   
    $args{dbh}->{AutoCommit} = 0;
    $args{dbh}->{RaiseError} = 1;
	    
		    my $i = 0;
		    my $msg;
		    my $msg2;
		    my $nextSequentialID=0;		    
					    
			my @availableID;
			#my @sequenceList = &getSequences(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-1,2),type=>$args{type},table=> $settings{table},issuedby=>$settings{issuedby});
			
			my @sequenceList;
			 if($args{fiscalyear}>2009){
			 @sequenceList = &getSequences(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-2,2),type=>$args{type},table=> $settings{table},issuedby=>$settings{issuedby});
			 }else{
			 @sequenceList = &getSequences(dbh => $args{dbh}, schema => $args{schema},fiscalyear => substr($args{fiscalyear},-1,2),type=>$args{type},table=> $settings{table},issuedby=>$settings{issuedby});	
			 }
			 
			for (my $j = 0; $j < $#sequenceList; $j++) { 
			$nextSequentialID = $sequenceList[$j];
				$i++;
				while ($i < $nextSequentialID) {
					@availableID = @availableID + $i;
					$msg .= " " . $i ;
					$i++;
				}
			}
			
			$nextSequentialID += 1;
			
		    #my ($survseq) = $args{dbh}->selectrow_array("select max(surveillance_seq) from $args{schema}.surveillance where issuedby_org_id = $settings{issuedby} and fiscal_year = $fy"); 
		    
    my $sqlcode = "INSERT into $args{schema}." . ($settings{table} eq 'internal' ? "internal_audit " : "external_audit ");
    $sqlcode .= "(id,audit_seq,fiscal_year,revision,audit_type,issuedto_org_id ";
    $sqlcode .= ",approver_id,approval_date";
    $sqlcode .= ",qualified_supplier_id,product" if ($settings{table} eq 'external');
    $sqlcode .= defined($settings{leadid}) && $settings{leadid} ? ",team_lead_id " : "";
    $sqlcode .= defined($team) ? ",team_members " : "";
    $sqlcode .= defined($scope) ? ",scope" : "";
    $sqlcode .= defined($title) ? ",title" : "";
    $sqlcode .= defined($settings{start}) ? ",begin_date" : "";
    $sqlcode .= defined($settings{end}) ? ",end_date" : "";
    $sqlcode .= defined($settings{completed}) ? ",completion_date" : "";
    $sqlcode .= ($settings{forecast} ne 'mm/yyyy') ? ",forecast_date" : "";
    $sqlcode .= defined($procedures) ? ",procedures" : "";
    $sqlcode .= defined($mol) ? ",mol" : "";
    $sqlcode .= defined($notes) ? ",notes" : "";
   # $sqlcode .= defined($status) ? ",state" : "";
    $sqlcode .= ",issuedby_org_id,qard_elements";
    $sqlcode .= defined($settings{reschedule}) ? ",reschedule" : "";
    $sqlcode .= defined($results) ? ",overall_results" : "";
    $sqlcode .= defined($settings{overall}) ? ",overall" : "";
    $sqlcode .= defined($settings{state}) ? ",state" : "";
    $sqlcode .= defined($settings{adequacy}) ? ",adequacy" : "";
    $sqlcode .= defined($settings{implementation}) ? ",implementation" : "";
    $sqlcode .= defined($settings{effectiveness}) ? ",effectiveness" : "";
    if($newFilename){
       $sqlcode .= ",reportlink,dblink";
       }
    $sqlcode .= defined($otherid) ? ",otherid" : "";
    
    #$sqlcode .= ")VALUES ($auditid,0,substr($args{fiscalyear},-2),0,'$settings{auditType}',$settings{issuedto}";
    
    $sqlcode .= ")VALUES ($auditid,$nextSequentialID,substr($args{fiscalyear},-2),0,'$settings{auditType}',$settings{issuedto}";
    $sqlcode .= ",$settings{userid},SYSDATE";
    $sqlcode .= ",$settings{supplier},$product" if ($settings{table} eq 'external');
    $sqlcode .= defined($settings{leadid}) && $settings{leadid} ? ",$settings{leadid}" : "";
    $sqlcode .= defined($team) ? ",$team" : "";
    $sqlcode .= defined($scope) ? ",$scope " : "";
    $sqlcode .= defined($title) ? ",$title " : "";
    $sqlcode .= defined($settings{eststart}) ? ",to_date('$settings{eststart}','MM/DD/RRRR')" : "";
    $sqlcode .= defined($settings{estend}) ? ",to_date('$settings{estend}','MM/DD/RRRR')" : "";
    $sqlcode .= defined($settings{start}) ? ",to_date('$settings{start}','MM/DD/RRRR')" : "";
    $sqlcode .= defined($settings{end}) ? ",to_date('$settings{end}','MM/DD/RRRR')" : "";
    $sqlcode .= defined($settings{completed}) ? ",to_date('$settings{completed}','MM/DD/RRRR')" : "";
    $sqlcode .= ($settings{forecast} ne 'mm/yyyy') ? ",to_date('$forecast[0]/1/$forecast[1]','MM/DD/RRRR')" : "";
    $sqlcode .= defined($procedures) ? ",$procedures " : "";
    $sqlcode .= defined($mol) ? ",$mol " : "";
    $sqlcode .= defined($notes) ? ",$notes " : "";
  #  $sqlcode .= defined($status) ? ",$status" : "";
    $sqlcode .= ",$settings{issuedby},'$settings{qardstring}'";
    $sqlcode .= defined($settings{reschedule}) ? ",'$settings{reschedule}'" : "";
    $sqlcode .= defined($results) ? ",$results " : "";
    $sqlcode .= defined($settings{overall}) ? ",'$settings{overall}' " : "";
    $sqlcode .= defined($settings{state}) ? ",'$settings{state}' " : "";
    $sqlcode .= defined($settings{adequacy}) ? ",'$settings{adequacy}' " : "";
    $sqlcode .= defined($settings{implementation}) ? ",'$settings{implementation}' " : "";
    $sqlcode .= defined($settings{effectiveness}) ? ",'$settings{effectiveness}' " : "";
    if($newFilename){
       $sqlcode .= ",'$reportlink','intranet'";
       }
    $sqlcode .= defined($otherid) ? ",$otherid " : "";
    $sqlcode .= ")";

#print STDERR = "\n<br>$sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;  
    
    my $insertrecords = $#suborgcount > 6 ? $#suborgcount : 6;
    
    for (my $i = 0; $i <= $insertrecords; $i++) {
	if ($orgstr[$i] || $locstr[$i] || $suborgcount[$i]) {
    		$sqlcode = "INSERT INTO $args{schema}." . ($settings{table} eq 'internal' ? "internal_audit_org_loc " : "external_audit_locations ");   	
    		$sqlcode .= "(id, fiscal_year, " . ($settings{table} eq 'internal' ? "in" : "ex") . "ternal_audit_id, revision ";
    		$sqlcode .= (!defined($locstr[$i]) || !($locstr[$i])) ? "" : ",location_id";
    		$sqlcode .= (!defined($orgstr[$i]) || !($orgstr[$i])) ? "" : ",organization_id" if ($settings{table} eq 'internal');
    		$sqlcode .= ($i != 0  || !($settings{supplier})) ? "" : ",supplier_id" if ($settings{table} eq 'internal');
    		$sqlcode .= (!defined($suborgcount[$i]) || !($suborgcount[$i])) ? "" : ",suborganization_id" if ($settings{table} eq 'internal');   	
    		
    		#$sqlcode .= ")\nVALUES ( $i + 1,substr($args{fiscalyear},-1,2),$auditid,0";
    		
    		if($args{fiscalyear}>2009){
			 $sqlcode .= ")\nVALUES ( $i + 1,substr($args{fiscalyear},-2,2),$auditid,0";
			 }else{
			 $sqlcode .= ")\nVALUES ( $i + 1,substr($args{fiscalyear},-1,2),$auditid,0";
			 }
    		
    		$sqlcode .= (!defined($locstr[$i]) || !($locstr[$i])) ? "" : ",$locstr[$i]";
    		$sqlcode .= (!defined($orgstr[$i]) || !($orgstr[$i])) ? "" : ",$orgstr[$i]" if ($settings{table} eq 'internal');
    		$sqlcode .= ($i != 0  || !($settings{supplier})) ? "" : ",$settings{supplier}" if ($settings{table} eq 'internal');
    		$sqlcode .= (!defined($suborgcount[$i]) || !($suborgcount[$i])) ? "" : ",$suborgcount[$i]" if ($settings{table} eq 'internal');
    		$sqlcode .= ")";
    		$csr = $args{dbh}->prepare($sqlcode);
    		$csr->execute;
	}
    
    }

    
    $args{dbh}->commit;
    $csr->finish;
    
    my $acnym = ($settings{table} eq 'internal' ? "IA" : "SA");
    my $displayid;
    if($settings{issuedby} == 3){
   $displayid = substr($args{fiscalyear},-2)."-DOE-AU-".$nextSequentialID;	 	
    }else{
    $displayid = $acnym."-".substr($args{fiscalyear},-2)."-".$nextSequentialID;	
    }
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"$settings{table} audit $displayid ($auditid) created for fiscal year $args{fiscalyear}");
    
    #&log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"$settings{table} audit $auditid created for fiscal year $args{fiscalyear}");
       
    #$output .= doAlertBox(text => "Audit $args{auditID} successfully updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "   document.audit2.fiscalyear.value = $args{fiscalyear};\n";
    if(($settings{issuedby} == 62 ) || ($settings{issuedby} == 63) || ($settings{issuedby} == 64)) {
        $output .= "   document.audit2.audit_selection.value = 'other';\n";
    }
    elsif ($args{fiscalyear} == 2008) {
        $output .= "   document.audit2.audit_selection.value = '$settings{table}';\n";
    }
    else {
    	#$output .= "   document.audit2.audit_selection.value = '$settings{table}_" . ($settings{issuedby} == 1 ? "bsc'" : $settings{issuedby} == 3 ? "em'" : $settings{issuedby} == 17 ? "bsc'" : $settings{issuedby} == 33 ? "snl'" : $settings{issuedby} == 24 ? "ocrwm'" : $settings{issuedby} == 28 ? "oqa'" :  "" ) . ";\n";
        $output .= "   document.audit2.audit_selection.value = '$settings{table}_" . ($settings{issuedby} == 1 ? "bsc'" : $settings{issuedby} == 3 ? "em'" : $settings{issuedby} == 17 ? "mo'" : $settings{issuedby} == 33 ? "snl'" : $settings{issuedby} == 24 ? "ocrwm'" : $settings{issuedby} == 28 ? "oqa'" :  "" ) . ";\n";
    }
    
    $output .= "   submitForm('audit2','browse');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessUpdateAudit {  # routine to update an audit in the DB
###################################################################################################################################
    my %args = (
        auditID => 0,  # null
        fiscalyear => 50,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $output = "";
    my $team = $args{dbh}->quote($settings{team});
    my $scope = $args{dbh}->quote($settings{scope});
    my @forecast = split /\//, $settings{forecast};
    my $procedures = $args{dbh}->quote($settings{procedures});
    my $mol = $args{dbh}->quote($settings{mol});
    my $otherid = $args{dbh}->quote($settings{otherid});
    my $notes = $args{dbh}->quote($settings{notes});
    my $title = $args{dbh}->quote($settings{title});
    my $status = $args{dbh}->quote($settings{status});
    my $product = $args{dbh}->quote($settings{product});
    my $reschedule = $args{dbh}->quote($settings{rescheduletext});
    my $results = $args{dbh}->quote($settings{results});
    my @orgstr = ($settings{org0},$settings{org1},$settings{org2},$settings{org3},$settings{org4},$settings{org5},$settings{org6});
    my @locstr = ($settings{loc0},$settings{loc1},$settings{loc2},$settings{loc3},$settings{loc4},$settings{loc5},$settings{loc6});
    
    my @suborgcount = split /,/, $settings{suborgstring};
    
    #print "--->\n$forecast[0] *** $forecast[1] --->\n";

    ## Attachment Code
    #
    use CGI;
    my $q = new CGI();
    my @filenames = $q->param('attachment');
    my $newFilename = "";
    my $yearf = "";  
    my $reportlink = "";;
    my $index = "";

    foreach $index (@filenames) {
        if ($index) {
            $newFilename = $index;
            $newFilename =~ s/\\/\//g;
            $newFilename =~ s!^.*/!!;  # return only the filename, remove the file path
            $newFilename =~ s/&//g;
            $newFilename =~ s/ /_/g;
        }
      }
      
    if($newFilename){
      $yearf = substr($args{fiscalyear},-2);  
      $reportlink = "fy $yearf / $newFilename ";
      $reportlink =~ s/ //g;

      my $testname1 = "i $yearf a";
      $testname1 =~ s/ //g;
      my $testname2 = "e $yearf a";
      $testname2 =~ s/ //g;
      my $testname3 = "doe $yearf a";
      $testname3 =~ s/ //g;
      my $testname4 = "ll $yearf a";
      $testname4 =~ s/ //g;
      my $testname5 = "snl $yearf a";
      $testname5 =~ s/ //g;  
      my $inputname = substr($newFilename,0,-7);
      if(substr($inputname,-8) ne $testname1  && substr($inputname,-8) ne $testname2 && substr($inputname,-8) ne $testname3 && substr($inputname,-8) ne $testname4 && substr($inputname,-8) ne $testname5){
         print "<script language = 'JavaScript'>alert(\"File \'$newFilename\' does not meet filenaming conventions!\\nNaming convention is [department name] PLUS [last two digits of year] PLUS ['a' for audit document] PLUS [three digit document number]\\nFilename should begin with [\'i\' or \'e\' or \'doe\' or \'ll\' or \'snl\'][last two digits of year][\'a\']\\nFor example, \'i09a001.pdf\'\");</script>\n";
         return;
      }
      
      my $upload_dir = "$SYSPathRoot /www/nqs/reports/";
      $upload_dir =~ s/ //g;
      my $dir = "$upload_dir fy $yearf";
         $dir =~ s/ //g;
      if (-e "$upload_dir$reportlink") {
         print "<script language = 'JavaScript'>alert('File $newFilename already exists!');</script>\n";
         return;
        } 
       unless(-d $dir){
         mkdir $dir or die;
         chmod("$dir", 0770);
        }

         my $upload_filehandle = $q->upload("attachment"); 
         open ( UPLOADFILE, ">$upload_dir$reportlink" ) or die "$!"; 
         binmode UPLOADFILE; 
         while ( <$upload_filehandle> ) 
         { 
          print UPLOADFILE; 
         } 
         chmod("$upload_dir$reportlink", 0770);
         close UPLOADFILE;
    }
       
    $args{dbh}->{AutoCommit} = 0;
    $args{dbh}->{RaiseError} = 1;
    
    my $sqlcode = "UPDATE $args{schema}.$args{table}_audit SET ";
   # $sqlcode .= "SET issuedto_org_id = $settings{issuedto}, ";
   # $sqlcode .= "cancelled = '$settings{cancelled}', ";
    $sqlcode .= "audit_seq = $settings{seq}, " if ($settings{seq});
    $sqlcode .= "team_lead_id = $settings{leadid}, " if (defined($settings{leadid}) && $settings{leadid});
    $sqlcode .= "team_lead_id = NULL, " if (defined($settings{leadid}) && $settings{leadid} eq 0);
    $sqlcode .= "team_members = $team, ";
    $sqlcode .= "scope = $scope, ";
    $sqlcode .= "title = $title, ";
    $sqlcode .= "forecast_date = to_date('$forecast[0]/1/$forecast[1]','MM/DD/RRRR'), " if ($settings{forecast} ne 'mm/yyyy');
    $sqlcode .= "begin_date = to_date('$settings{start}','MM/DD/RRRR'), ";
    $sqlcode .= "end_date = to_date('$settings{end}','MM/DD/RRRR'), ";
    $sqlcode .= "completion_date = to_date('$settings{completed}','MM/DD/RRRR'), ";
    $sqlcode .= "procedures = $procedures, ";
    $sqlcode .= "mol = $mol, ";
    $sqlcode .= "otherid = $otherid, ";
    $sqlcode .= "notes = $notes, ";
    $sqlcode .= "qualified_supplier_id = $settings{supplier}, " if ($args{table} eq 'external');
    $sqlcode .= "product = $product, " if ($args{table} eq 'external');
    $sqlcode .= "qard_elements = '$settings{qardstring}', ";
    $sqlcode .= "reschedule = $reschedule, ";
    $sqlcode .= "overall_results = $results, ";
    $sqlcode .= "overall = '$settings{overall}', ";
    $sqlcode .= "state = '$settings{state}', ";
    $sqlcode .= "adequacy = '$settings{adequacy}', ";
    $sqlcode .= "implementation = '$settings{implementation}', ";
    if($newFilename){
       $sqlcode .= "reportlink = '$reportlink', dblink = 'intranet',";
       }
    $sqlcode .= "effectiveness = '$settings{effectiveness}' ";
    
    #$sqlcode .= "WHERE id = $args{auditID} AND fiscal_year = substr($args{fiscalyear},-1,2) ";
    
    if($args{fiscalyear}>2009){
			 $sqlcode .= "WHERE id = $args{auditID} AND fiscal_year = substr($args{fiscalyear},-2,2) ";
			 }else{
			 $sqlcode .= "WHERE id = $args{auditID} AND fiscal_year = substr($args{fiscalyear},-1,2) ";
			 }
    
    $sqlcode .= "AND revision = 0 ";

    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;

    $sqlcode = "DELETE from $args{schema}." . ($args{table} eq 'internal' ? "internal_audit_org_loc " : "external_audit_locations ");
    $sqlcode .= "WHERE " . ($args{table} eq 'internal' ? "in" : "ex") . "ternal_audit_id = $args{auditID} ";
    
    #$sqlcode .= "AND fiscal_year = substr($args{fiscalyear},-1,2) ";
    
        if($args{fiscalyear}>2009){
			 $sqlcode .= "AND fiscal_year = substr($args{fiscalyear},-2,2) ";
			 }else{
			 $sqlcode .= "AND fiscal_year = substr($args{fiscalyear},-1,2) ";
			 }
    
    $sqlcode .= "AND revision = 0 ";

    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
        
    my $insertrecords = $#suborgcount > 6 ? $#suborgcount : 6;
    
    for (my $i = 0; $i <= $insertrecords; $i++) {
	if ($orgstr[$i] || $locstr[$i] || $suborgcount[$i]) {
    		$sqlcode = "INSERT INTO $args{schema}." . ($args{table} eq 'internal' ? "internal_audit_org_loc " : "external_audit_locations ");   	
    		$sqlcode .= "(id, fiscal_year, " . ($args{table} eq 'internal' ? "in" : "ex") . "ternal_audit_id, revision ";
    		$sqlcode .= (!defined($locstr[$i]) || !($locstr[$i])) ? "" : ",location_id";
    		$sqlcode .= (!defined($orgstr[$i]) || !($orgstr[$i])) ? "" : ",organization_id" if ($args{table} eq 'internal');
    		$sqlcode .= ($i != 0  || !($settings{supplier})) ? "" : ",supplier_id" if ($args{table} eq 'internal');
    		$sqlcode .= (!defined($suborgcount[$i]) || !($suborgcount[$i])) ? "" : ",suborganization_id" if ($args{table} eq 'internal');   	
    		
    		#$sqlcode .= ")\nVALUES ( $i + 1,substr($args{fiscalyear},-1,2),$args{auditID},0";
    		
    		  if($args{fiscalyear}>2009){
			 $sqlcode .= ")\nVALUES ( $i + 1,substr($args{fiscalyear},-2,2),$args{auditID},0";
			 }else{
			 $sqlcode .= ")\nVALUES ( $i + 1,substr($args{fiscalyear},-1,2),$args{auditID},0";
			 }
    		
    		$sqlcode .= (!defined($locstr[$i]) || !($locstr[$i])) ? "" : ",$locstr[$i]";
    		$sqlcode .= (!defined($orgstr[$i]) || !($orgstr[$i])) ? "" : ",$orgstr[$i]" if ($args{table} eq 'internal');
    		$sqlcode .= ($i != 0  || !($settings{supplier})) ? "" : ",$settings{supplier}" if ($args{table} eq 'internal');
    		$sqlcode .= (!defined($suborgcount[$i]) || !($suborgcount[$i])) ? "" : ",$suborgcount[$i]" if ($args{table} eq 'internal');
    		$sqlcode .= ")";
    		$csr = $args{dbh}->prepare($sqlcode);
    		$csr->execute;
	}
    
    }
    
    $args{dbh}->commit;
    $csr->finish;
    
    
     #print STDERR "\n####################################### $settings{displayid} #############################################\n";
    #&log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Audit $args{auditID} updated");
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"Audit $settings{displayid} ($args{auditID}) updated");
    
    #$output .= doAlertBox(text => "Audit $args{auditID} successfully updated");
    $output .= "<script language=javascript><!--\n";
    if(($settings{issuedby} == 62 ) || ($settings{issuedby} == 63) || ($settings{issuedby} == 64)) {
        $output .= "   document.audit2.audit_selection.value = 'other';\n";
    }
    elsif ($args{fiscalyear} == 2008) {
            $output .= "   document.audit2.audit_selection.value = '$settings{table}';\n";
    }
    else {
        $output .= "   document.audit2.audit_selection.value = '$settings{table}_" . ($settings{issuedby} == 1 ? "bsc'" : $settings{issuedby} == 3 ? "em'": $settings{issuedby} == 17 ? "mo'" : $settings{issuedby} == 33 ? "snl'" : $settings{issuedby} == 24 ? "ocrwm'" : $settings{issuedby} == 28 ? "oqa'" :  "" ) . ";\n";
    }
    
    $output .= "   submitForm('audit2','browse');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessCancelAudit {  # routine to cancel an audit in the DB
###################################################################################################################################
    my %args = (
        survID => 0,  # null
        fiscalyear => 50,
        @_,
    );

    my $output = "";

    $args{dbh}->{AutoCommit} = 0;
    $args{dbh}->{RaiseError} = 1;
    
    my $sqlcode = "UPDATE $args{schema}.$args{table}_audit ";
    $sqlcode .= "SET cancelled = 'Y', state = 'Cancelled' ";
    $sqlcode .= "WHERE id = $args{auditID} AND fiscal_year = substr($args{fiscalyear},-2) AND revision = 0 ";

    print STDERR "\n-->$sqlcode\n";

    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;

    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"$args{table} audit $args{auditID} cancelled");
    #&log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"$args{table} audit $settings{displayid} ($args{auditID}) cancelled");
    
    #$output .= doAlertBox(text => "$args{table} audit $args{auditID} successfully cancelled");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('audit2','browse');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessDeleteAudit {  # routine to delete an audit from the DB
###################################################################################################################################
    my %args = (
        auditID => 0,  # null
        fiscalyear => 50,
        displayid => 0,
        @_,
    );
    
    my $output = "";
    my $sqlcode;
    my $sqlcode2;

    $args{dbh}->{AutoCommit} = 0;
    $args{dbh}->{RaiseError} = 1;

    $sqlcode = "delete from $args{schema}.internal_audit_org_loc where revision = 0 and internal_audit_id = $args{auditID} and fiscal_year = substr($args{fiscalyear},-2)" if ($args{table} eq 'internal');	
    $sqlcode = "delete from $args{schema}.external_audit_locations where revision = 0 and external_audit_id = $args{auditID} and fiscal_year = substr($args{fiscalyear},-2)" if ($args{table} eq 'external');
	
    $sqlcode2 = "delete from $args{schema}.$args{table}_audit where fiscal_year = substr($args{fiscalyear},-2) and revision = 0 and id = $args{auditID}";


  #  print STDERR "\n-->$sqlcode\n";
  #  print STDERR "\n-->$sqlcode2\n";

    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;

    $csr = $args{dbh}->prepare($sqlcode2);
    $csr->execute;
    
    $args{dbh}->commit;
    $csr->finish;
    		#&log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"$args{table} $args{auditID} deleted for fy $args{fiscalyear}");
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"$args{table} $args{displayid} ($args{auditID}) deleted for fy $args{fiscalyear}");
    
    	#$output .= doAlertBox(text => "$args{table} audit $args{auditID} successfully deleted");
    $output .= "<script language=javascript><!--\n";
    #$output .= "   alert('".$args{displayid}."');\n";
    $output .= "   submitForm('audit2','browse');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessEditReportlink {  # routine to edit or add an audit reportlink 
###################################################################################################################################
    my %args = (
        survID => 0,  # null
        fiscalyear => 50,
        @_,
    );

    my $output = "";

    $args{dbh}->{AutoCommit} = 0;
    $args{dbh}->{RaiseError} = 1;
    
    my $sqlcode = "UPDATE $args{schema}.$args{table}_audit ";
    $sqlcode .= "SET reportlink = '$args{reportlink}', dblink = '$args{dbname}' ";
    #$sqlcode .= "WHERE id = $args{auditID} AND fiscal_year = substr($args{fiscalyear},-1,2) AND revision = 0";

        if($args{fiscalyear}>2009){
      	$sqlcode .= "WHERE id = $args{auditID} AND fiscal_year = substr($args{fiscalyear},-2,2) AND revision = 0";
      }else{
      	$sqlcode .= "WHERE id = $args{auditID} AND fiscal_year = substr($args{fiscalyear},-1,2) AND revision = 0";
      }

    print "\n-->$sqlcode\n";

    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;

    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"$args{table}_audit $args{auditID} reportlink updated");
    
    #$output .= doAlertBox(text => "$args{table}_audit $args{auditID} reportlink successfully updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('audit2','browse');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doDeleteAuditAttachment {  # routine to delete an attachment
###################################################################################################################################
    my %args = (
        survID => 0,  # null
        fiscalyear => 50,
        @_,
    );

    my $output = "";

    $args{dbh}->{AutoCommit} = 0;
    $args{dbh}->{RaiseError} = 1;
    
    my $sqlcode = "UPDATE $args{schema}.$args{table}_audit ";
    $sqlcode .= "SET reportlink = '', dblink = '' ";
    
    #$sqlcode .= "WHERE id = $args{auditID} AND fiscal_year = substr($args{fiscalyear},-1,2) AND revision = 0";

        if($args{fiscalyear}>2009){
      	$sqlcode .= "WHERE id = $args{auditID} AND fiscal_year = substr($args{fiscalyear},-2,2) AND revision = 0";
      }else{
      	$sqlcode .= "WHERE id = $args{auditID} AND fiscal_year = substr($args{fiscalyear},-1,2) AND revision = 0";
      }

    print "\n-->$sqlcode\n";

    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;

    $args{dbh}->commit;
    $csr->finish;
    &log_nqs_activity($args{dbh},$args{schema},'F',$args{userID},"$args{table}_audit $args{auditID} reportlink updated");
    
    #$output .= doAlertBox(text => "$args{table}_audit $args{auditID} reportlink successfully updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('audit2','browse');\n";
    $output .= "//--></script>\n";

    # delete file
      my $upload_dir = "$SYSPathRoot /www/nqs/reports/";
      $upload_dir =~ s/ //g;
      unlink("$upload_dir$args{reportlink}");
    
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
sub getMaxrevision {  # routine to get the max revision of an audit to see if it has ever been approved
###################################################################################################################################
    my %args = (
        auditID => 0,
        @_,
    );
    my ($maxrev) = $args{dbh}->selectrow_array("SELECT max(revision) from $args{schema}.$args{table}_audit WHERE fiscal_year = $args{fiscalyear} AND id = $args{auditID}");
    
    return($maxrev);
}
###################################################################################################################################


1; #return true

