#
# $Source: /data/dev/rcs/qa/perl/RCS/DBMetricReports.pm,v $
#
# $Revision: 1.1 $ 
#
# $Date: 2004/05/30 22:24:45 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: DBMetricReports.pm,v $
# Revision 1.1  2004/05/30 22:24:45  starkeyj
# Initial revision
#
#
package DBMetricReports;
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
	&getSurveillanceLocation	&getSurveillanceOrganization		&getSurveillanceSuborganization					
	&getFullUserName		&getAuditLocation			&getAuditSuborganization
	&getAuditOrganization		&getAuditSupplier			&getIssuedOrg
	&getSurveillanceSupplier	&getLookupValues			&getAuditOrgLocation 		
	&getSurveillanceOrgLocation 	
);	
%EXPORT_TAGS =( 
    Functions => [qw(
	&getSurveillanceLocation	&getSurveillanceOrganization		&getSurveillanceSuborganization				
	&getFullUserName		&getAuditLocation			&getAuditSuborganization
	&getAuditOrganization		&getAuditSupplier			&getIssuedOrg
	&getSurveillanceSupplier	&getLookupValues			&getAuditOrgLocation 
	&getSurveillanceOrgLocation 		
				
	
    )]
);


###################################################################################################################################
###################################################################################################################################


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
sub getAuditLocation {  # routine to get the locations for an audit
###################################################################################################################################
    my %args = (
        auditID => 0,
        fiscalyear => 50,
        @_,
    );
    my @location;
    my $sqlstring = "SELECT l.id, initcap(city), initcap(province), state FROM $args{schema}.locations l,";
    $sqlstring .= ($args{table} eq 'internal' ? "$args{schema}.internal_audit_org_loc al " : "$args{schema}.external_audit_locations al " );
    $sqlstring .= "WHERE l.id=al.location_id AND al.fiscal_year = substr($args{fiscalyear},-1,2) AND al." ;
    $sqlstring .= ($args{table} eq 'internal' ? "internal_audit_id = $args{auditID} " : "external_audit_id = $args{auditID} " );
    $sqlstring .= "AND al.revision = 0 ";

    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($location[$i]{id},$location[$i]{city},$location[$i]{province},$location[$i]{state}) = $csr->fetchrow_array) {
        $i++;
    }
    return(@location);
}
###################################################################################################################################
sub getAuditOrganization {  # routine to get the organizations for an audit
###################################################################################################################################
    my %args = (
        auditID => 0,
        fiscalyear => 50,
        @_,
    );
    my @organization;
    my $sqlstring = "SELECT o.id, abbr, organization FROM $args{schema}.organizations o,$args{schema}.internal_audit_org_loc ia ";
    $sqlstring .= "WHERE o.id=ia.organization_id AND ia.fiscal_year = substr($args{fiscalyear},-1,2) AND ia.internal_audit_id = $args{auditID} ";
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
sub getAuditSuborganization {  # routine to get the suborganizations for a BSC audit
###################################################################################################################################
    my %args = (
        auditID => 0,
        fiscalyear => 50,
        @_,
    );
    my @suborganization;
    my $sqlstring = "SELECT o.id, suborg FROM $args{schema}.bsc_suborganizations o,$args{schema}.internal_audit_org_loc ia ";
    $sqlstring .= "WHERE o.id=ia.suborganization_id AND ia.fiscal_year = substr($args{fiscalyear},-1,2) AND ia.internal_audit_id = $args{auditID} ";
    $sqlstring .= "AND ia.revision = 0 ";
    $sqlstring .= "order by o.suborg ";
#print "\n<br>$sqlstring \n";
    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($suborganization[$i]{suborgid},$suborganization[$i]{suborg}) = $csr->fetchrow_array) {
        $i++;
    }
    
    return(@suborganization);
}
###################################################################################################################################
sub getAuditOrgLocation {  # routine to get the organizations and locations for an audit
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
    	
	$sqlstring = "SELECT id, suborg ";
	$sqlstring .= "FROM $args{schema}.bsc_suborganizations ";
	$sqlstring .= "order by suborg ";

	$csr = $args{dbh}->prepare($sqlstring);
	$status = $csr->execute;

	$i = 0;
	while (($orglocation[$i]{suborgid},$orglocation[$i]{suborg}) = $csr->fetchrow_array) {
			$i++;
	}
    	
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
sub getAuditSupplier{  # routine to get a supplier id and name
###################################################################################################################################
    my %args = (
        auditID => 0,
        fiscalyear => 50,
        @_,
    );
    my @supplier;
    
    my $sqlstring = "SELECT q.id, company_name FROM $args{schema}.qualified_supplier q,$args{schema}.external_audit ea ";
    $sqlstring .= "WHERE q.id=ea.qualified_supplier_id AND ea.fiscal_year = substr($args{fiscalyear},-1,2) AND ea.id = $args{auditID} ";
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
sub getSurveillanceLocation {  # routine to get the locations for a surveillance
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
sub getSurveillanceOrganization {  # routine to get the organizations for a surveillance
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
sub getSurveillanceSuborganization {  # routine to get the suborganizations for a BSC surveillance
###################################################################################################################################
    my %args = (
        survID => 0,
        fiscalyear => 50,
        @_,
    );
    my @suborganization;
    my $sqlstring = "SELECT o.id, suborg FROM $args{schema}.bsc_suborganizations o,$args{schema}.surveillance_org_loc s ";
    $sqlstring .= "WHERE o.id=s.suborganization_id AND s.fiscal_year = substr($args{fiscalyear},-1,2) AND s.surveillance_id = $args{survID} ";
    $sqlstring .= "order by o.suborg ";
#print "\n $sqlstring \n";
    my $csr = $args{dbh}->prepare($sqlstring);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($suborganization[$i]{suborgid},$suborganization[$i]{suborg}) = $csr->fetchrow_array) {
        $i++;
    }
    
    return(@suborganization);
}
###################################################################################################################################
sub getSurveillanceOrgLocation {  # routine to get the organizations and locations for a surveillance
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
    	
	$sqlstring = "SELECT id, suborg ";
	$sqlstring .= "FROM $args{schema}.bsc_suborganizations ";
	$sqlstring .= "order by suborg ";

	$csr = $args{dbh}->prepare($sqlstring);
	$status = $csr->execute;

	$i = 0;
	while (($orglocation[$i]{suborgid},$orglocation[$i]{suborg}) = $csr->fetchrow_array) {
			$i++;
	}
    	
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
sub getSurveillanceSupplier{  # routine to get a surveillance supplier
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


1; #return true

