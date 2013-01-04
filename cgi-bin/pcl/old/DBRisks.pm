#
# $Source: $
#
# $Revision: $ 
#
# $Date:  $
#
# $Author:  $
#
# $Locker:  $
#
# $Log:  $
#
#
package DBRisks;
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use Tables qw(:Functions);
use Tie::IxHash;
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
	&getRisks		&doProcessCreateRisk		&doProcessUpdateRisk
	&getRiskHistory
);
%EXPORT_TAGS =( 
    Functions => [qw(
	&getRisks		&doProcessCreateRisk		&doProcessUpdateRisk
	&getRiskHistory
    )]
);


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getRisks {  # routine to get the risks for a project
###################################################################################################################################
    my %args = (
        project => 0,  # null
        risk => 0,  # null
        status => 0, # all
        single => 0,
        @_,
    );
    #$args{dbh}->{LongReadLen} = 100000000;
    my @riskList;
    my $sqlcode = "SELECT id, project_id, version, risk, probability, impact, status, contingency ";
    $sqlcode .= "FROM $args{schema}.temp_risks ";
    $sqlcode .= ($args{single}) ? "WHERE id = $args{risk} " : "WHERE project_id = $args{project} ";
    $sqlcode .= "AND version = 0 ";
    $sqlcode .= "ORDER BY id ";
  # print "\n $sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($riskList[$i]{riskid},$riskList[$i]{projectid},$riskList[$i]{version},$riskList[$i]{risk},
    $riskList[$i]{probability},$riskList[$i]{impact},$riskList[$i]{status},$riskList[$i]{contingency}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@riskList);
}
###################################################################################################################################
sub getRiskHistory {  # routine to get the history for a risk
###################################################################################################################################
    my %args = (
        project => 0,  # null
        risk => 0,  # null
        status => 0, # all
        @_,
    );
    #$args{dbh}->{LongReadLen} = 100000000;
    my @historyList;
    my $sqlcode = "SELECT project_id, version, risk, probability, impact, status, contingency, to_char(date_modified,'Mon DD, YYYY') ";
    $sqlcode .= "FROM $args{schema}.temp_risks ";
    $sqlcode .= "WHERE id = $args{risk} ";
    $sqlcode .= "ORDER BY version desc ";
  # print "\n $sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($historyList[$i]{projectid},$historyList[$i]{version},$historyList[$i]{risk},
    $historyList[$i]{probability},$historyList[$i]{impact},$historyList[$i]{status},
    $historyList[$i]{contingency},$historyList[$i]{datemodified}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@historyList);
}
###################################################################################################################################
sub doProcessCreateRisk {  # routine to insert a new risk into the project DB
###################################################################################################################################
    my %args = (
        project => 0,  # null
        version => 0,
        userID => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $output = "";
    my $riskID = $args{dbh}->selectrow_array("SELECT $args{schema}.risk_seq.NEXTVAL FROM dual");

    my $risk = $args{dbh}->quote($settings{risktext});
    my $contingency = $args{dbh}->quote($settings{contingency});


    my $sqlcode = "INSERT INTO $args{schema}.temp_risks (id, project_id, version, risk, probability, impact, status, contingency, date_modified ) ";
    $sqlcode .= "VALUES ($riskID,$args{project},0,$risk,'$settings{probability}','$settings{impact}','$settings{status}',$contingency,sysdate)";
#print STDERR "\n$sqlcode\n";    
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_activity($args{dbh},$args{schema},$args{userID},"Risk ID $riskID inserted");
    
    $output .= doAlertBox(text => "Risk $riskID successfully inserted");
    $output .= "<script language=javascript><!--\n";
    $output .= " //  changeMainLocation('risks');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessUpdateRisk {  # routine to update a risk in the project DB
###################################################################################################################################
    my %args = (
        project => 0,  # null
        risk => 0,
        version => 0,
        userID => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $output = "";
    my ($version) = $args{dbh}->selectrow_array("SELECT MAX(version) FROM $args{schema}.temp_risks where id = $args{risk}");
    my $risktext = $args{dbh}->quote($settings{risktext});
    my $contingency = $args{dbh}->quote($settings{contingency});

    $args{dbh}->{AutoCommit} = 0;
    $args{dbh}->{RaiseError} = 1;
    
    my $sqlcode = "INSERT INTO $args{schema}.temp_risks (id, project_id, version, risk, probability, impact, status, contingency, date_modified ) ";
    $sqlcode .= "(SELECT id, project_id, $version + 1, risk, probability, impact, status, contingency, date_modified ";
    $sqlcode .= "FROM $args{schema}.temp_risks WHERE id = $args{risk} AND version = 0) ";
    #$sqlcode .= "VALUES ($args{risk},$args{project},$version + 1,$risktext,'$settings{probability}','$settings{impact}','$settings{status}',$contingency,sysdate)";
#print "\n$sqlcode\n";    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    $sqlcode = "UPDATE $args{schema}.temp_risks ";
    $sqlcode .= "SET risk = $risktext, ";
    $sqlcode .= "probability = '$settings{probability}', ";
    $sqlcode .= "impact = '$settings{impact}', ";
    $sqlcode .= "status = '$settings{status}', ";
    $sqlcode .= "contingency = $contingency, ";
    $sqlcode .= "date_modified = sysdate ";
    $sqlcode .= "WHERE id = $args{risk} AND version = 0 ";
    #print STDERR "\n$sqlcode\n";
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    

    
    $args{dbh}->commit;
    $csr->finish;
    &log_activity($args{dbh},$args{schema},$args{userID},"Risk ID $args{risk} updated");
    
    $output .= doAlertBox(text => "Risk $args{risk} successfully updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "  // submitForm('risks');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################


1; #return true

