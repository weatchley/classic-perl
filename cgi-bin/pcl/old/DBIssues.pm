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
package DBIssues;
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
	&getIssues		&doProcessCreateIssue		&doProcessUpdateIssue
	&getIssueHistory
);
%EXPORT_TAGS =( 
    Functions => [qw(
	&getIssues		&doProcessCreateIssue		&doProcessUpdateIssue
	&getIssueHistory
    )]
);


###################################################################################################################################
###################################################################################################################################
sub getIssues {  # routine to get the issues for a project
###################################################################################################################################
    my %args = (
        project => 0,  # null
        issue => 0,  # null
        status => 0, # all
        single => 0,
        @_,
    );
    #$args{dbh}->{LongReadLen} = 100000000;
    my @issueList;
    my $sqlcode = "SELECT id, project_id, version, issue, impact, status, to_char(date_modified,'Mon DD, YYYY') ";
    $sqlcode .= "FROM $args{schema}.temp_isues ";
    $sqlcode .= ($args{single}) ? "WHERE id = $args{issue} " : "WHERE project_id = $args{project} ";
    $sqlcode .= "AND version = 0 ";
    $sqlcode .= "ORDER BY id ";
  # print "\n $sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($issueList[$i]{riskid},$issueList[$i]{projectid},$issueList[$i]{version},$issueList[$i]{issue},
    $issueList[$i]{impact},$issueList[$i]{status},$issueList[$i]{datemodified}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@riskList);
}
###################################################################################################################################
sub getIssueHistory {  # routine to get the history for an issue
###################################################################################################################################
    my %args = (
        project => 0,  # null
        issue => 0,  # null
        status => 0, # all
        @_,
    );
    #$args{dbh}->{LongReadLen} = 100000000;
    my @historyList;
    my $sqlcode = "SELECT project_id, version, issue, impact, status, to_char(date_modified,'Mon DD, YYYY') ";
    $sqlcode .= "FROM $args{schema}.temp_issues ";
    $sqlcode .= "WHERE id = $args{issue} ";
    $sqlcode .= "ORDER BY version desc ";
  # print "\n $sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($historyList[$i]{projectid},$historyList[$i]{version},$historyList[$i]{risk},
    $historyList[$i]{impact},$historyList[$i]{status},$historyList[$i]{datemodified}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@historyList);
}
###################################################################################################################################
sub doProcessCreateIssue {  # routine to insert a new issue into the project DB
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
    my $issueID = $args{dbh}->selectrow_array("SELECT $args{schema}.issue_seq.NEXTVAL FROM dual");

    my $issue = $args{dbh}->quote($settings{issuetext});

    my $sqlcode = "INSERT INTO $args{schema}.temp_issues (id, project_id, version, issue, impact, status, date_modified ) ";
    $sqlcode .= "VALUES ($issueID,$args{project},0,$issue,'$settings{impact}','$settings{status}',sysdate)";
#print STDERR "\n$sqlcode\n";    
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_activity($args{dbh},$args{schema},$args{userID},"Issue ID $issueID inserted");
    
    $output .= doAlertBox(text => "Issue $issueID successfully inserted");
    $output .= "<script language=javascript><!--\n";
    $output .= " //  changeMainLocation('issues');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################
sub doProcessUpdateIssue {  # routine to update an issue in the project DB
###################################################################################################################################
    my %args = (
        project => 0,  # null
        issue => 0,
        version => 0,
        userID => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $output = "";
    my ($version) = $args{dbh}->selectrow_array("SELECT MAX(version) FROM $args{schema}.temp_issues where id = $args{issue}");
    my $issuetext = $args{dbh}->quote($settings{risktext});

    $args{dbh}->{AutoCommit} = 0;
    $args{dbh}->{RaiseError} = 1;
    
    my $sqlcode = "INSERT INTO $args{schema}.temp_issues (id, project_id, version, issue, impact, status, date_modified ) ";
    $sqlcode .= "(SELECT id, project_id, $version + 1, issue, impact, status, date_modified ";
    $sqlcode .= "FROM $args{schema}.temp_risks WHERE id = $args{issue} AND version = 0) ";
    #$sqlcode .= "VALUES ($args{issue},$args{project},$version + 1,$issuetext,'$settings{impact}','$settings{status}',sysdate)";
#print "\n$sqlcode\n";    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    $sqlcode = "UPDATE $args{schema}.temp_issues ";
    $sqlcode .= "SET issue = $issuetext, ";
    $sqlcode .= "impact = '$settings{impact}', ";
    $sqlcode .= "status = '$settings{status}', ";
    $sqlcode .= "date_modified = sysdate ";
    $sqlcode .= "WHERE id = $args{issue} AND version = 0 ";
    #print STDERR "\n$sqlcode\n";
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    

    
    $args{dbh}->commit;
    $csr->finish;
    &log_activity($args{dbh},$args{schema},$args{userID},"Issue ID $args{issue} updated");
    
    $output .= doAlertBox(text => "Issue $args{issue} successfully updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "  // submitForm('issues');\n";
    $output .= "//--></script>\n";
    
    return($output);
}
###################################################################################################################################


1; #return true

