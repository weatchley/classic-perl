#
# $Source: /data/dev/rcs/scm/perl/RCS/DB_SCR.pm,v $
# $Revision: 1.7 $ 
# $Date: 2002/12/04 22:39:42 $
# $Author: naydenoa $
# $Locker:  $
# $Log: DB_SCR.pm,v $
# Revision 1.7  2002/12/04 22:39:42  naydenoa
# Added filtering for SCR browse in function getSCRBrowseResults
# Added funtion insertRemarks
#
# Revision 1.6  2002/11/25 18:18:25  mccartym
# added &getSCRRequestTypes() and modified &createNewLegacySCR() to handle request type
#
# Revision 1.5  2002/11/25 17:59:54  naydenoa
# Added functions getSCRRequests and getSCRBrowseResults to handle the retrieval of SCR info for the home and browse screens
#
# Revision 1.4  2002/11/12 01:49:55  mccartym
# added &getSCRPriorityDescriptions() function.  returns a reference to a hash containing the priority ID's and descriptions.
#
# Revision 1.3  2002/11/11 23:57:25  naydenoa
# Added functions getIDforNewLegacySCR and createNewLegacySCR
# for legacy SCR processing
#
# Revision 1.2  2002/11/05 23:53:09  naydenoa
# Changed "dateapproved" to "dateaccepted"
#
# Revision 1.1  2002/10/24 23:14:51  naydenoa
# Initial revision
#
#

package DB_SCR;
use strict;
use SCM_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_scm qw(:Functions);
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

@EXPORT = qw (
	&getSCRInfo           &singleValueLookup   &getCount
    );
@EXPORT_OK = qw(
	&getSCRInfo           &singleValueLookup   &getCount
        &getIDforNewLegacySCR &createNewLegacySCR  &getSCRPriorityDescriptions 
        &getSCRRequestTypes   &getSCRBrowseResults &getSCRRequests
	&updateSCR            &insertRemarks
    );
%EXPORT_TAGS =( 
    Functions => [qw(
	&getSCRInfo           &singleValueLookup   &getCount
        &getSCRBrowseResults  &getSCRRequests      &updateSCR
        &insertRemarks
    )]
);

################
sub getSCRInfo {
################
    my %args = (
	rid => 0,
        pid => 0,	
	@_,
    );
    my %requesthash;
    my $requeststring = "select to_char(datesubmitted, 'MM/DD/YYYY'), 
                                description, rationale, submittedby, 
                                status, priority, 
                                to_char(datecompleted, 'MM/DD/YYYY'), 
                                estimatedcost, actualcost, developer,
                                to_char(datedue,'MM/DD/YYYY'), 
                                to_char(dateaccepted, 'MM/DD/YYYY'),
                                actionstaken, rejectionrationale,
                                to_char(lastupdated,'MM/DD/YYYY'), 
                                updatedby, analysis,
                                testplan, assignedpriority, type
                         from $args{schema}.scrrequest
                         where id = $args{rid} and product = $args{pid}";
    my @results = $args{dbh} -> selectrow_array ($requeststring);
    my ($edate, $desc, $rat, $entby, $sid, $rpid, $compdate, $ecost, $acost, $dev, $due, $accdate, $ataken, $rejrat, $update, $upby, $analysis, $testplan, $apid, $typeid) = @results;

    %requesthash = (datesubmitted => $edate,
                    description => $desc,
                    rationale => $rat,
                    submittedby => $entby,
                    status  => $sid,
                    priority => $rpid,
                    datecompleted => $compdate,
                    estimatedcost  => $ecost,
                    actualcost  => $acost,
                    developer => $dev,
                    datedue => $due,
                    dateaccepted => $accdate,
                    actionstaken  => $ataken,
                    rejectionrationale => $rejrat,
                    lastupdated => $update,
                    updatedby => $upby,
                    analysis => $analysis,
                    testplan => $testplan,
                    assignedpriority => $apid,
                    type => $typeid
    );

    return (%requesthash);
}

#######################
sub singleValueLookup {
#######################
    my %args = (
	table => '',
    	column => 'description',
    	lookupid => 0,
	@_,
    );
    my ($value) = $args{dbh} -> selectrow_array ("select $args{column} from $args{schema}.$args{table} where id = $args{lookupid}");
    return ($value);
}

##############
sub getCount {
##############
     my %args = (
	table => '',
	where => '',
	@_,
    );
    my $where = "where $args{where}" if $args{where};
    my ($thecount) = $args{dbh} -> selectrow_array ("select count(*) from $args{schema}.$args{table} $where");
    return ($thecount);
}

##########################
sub getIDforNewLegacySCR {
##########################
   my %args = (
      @_,
   );
   my ($id) = $args{dbh}->selectrow_array("select max(id) from $args{schema}.scrrequest where product = $args{product}");
   $id += 1;
   return ($id);
}

########################
sub createNewLegacySCR {
########################
   my %args = (
      @_,
   );
   my $insert = "insert into $args{schema}.scrrequest (id, description, priority, rationale, datesubmitted, submittedby, status, product, type) ";
   $insert .= "values ($args{id}, :description, $args{priority}, :rationale, SYSDATE, $args{userid}, 1, $args{product}, $args{type})";
   my $csr = $args{dbh}->prepare ($insert);
   $csr->bind_param (":description", $args{description}, {ora_type => ORA_CLOB, ora_field => 'description'});
   $csr->bind_param (":rationale", $args{rationale}, {ora_type => ORA_CLOB, ora_field => 'rationale'});
   $csr->execute;
   $csr->finish;
}

################################
sub getSCRPriorityDescriptions {
################################
   my %args = (
      orderBy => 'id',
      @_,
   );
   tie my %priorityNames, "Tie::IxHash";
   my $csr = $args{dbh}->prepare ("select id, description from $args{schema}.scrpriority order by $args{orderBy}");
   $csr->execute;
   while (my ($id, $description) = $csr->fetchrow_array) {
      $priorityNames{$id} = $description;
   }
   $csr->finish;
   return (\%priorityNames);
}

########################
sub getSCRRequestTypes {
########################
   my %args = (
      orderBy => 'id',
      @_,
   );
   tie my %requestTypes, "Tie::IxHash";
   my $csr = $args{dbh}->prepare ("select id, name from $args{schema}.scrtype order by $args{orderBy}");
   $csr->execute;
   while (my ($id, $name) = $csr->fetchrow_array) {
      $requestTypes{$id} = $name;
   }
   $csr->finish;
   return (\%requestTypes);
}

#########################
sub getSCRBrowseResults {
#########################
    my %args = (
        pid => 0,
	filterid => 0,
	filter => "",
        @_,
    );
    my $outstr;
    my $count = 0;
    my @resultArray;
    my $filterwhere = "";
    if ($args{filter} eq "product") {
        $filterwhere = "r.product = $args{pid} and ";
    }
    elsif ($args{filter} eq "status") {
        $filterwhere = "r.status = $args{filterid} and r.product = $args{pid} and ";
    }
    elsif ($args{filter} eq "type") {
        $filterwhere = "r.type = $args{filterid} and r.product = $args{pid} and ";
    }
    my $pick = "select r.id, s.id, s.description, r.submittedby, 
                       u.firstname || ' ' || u.lastname, r.description, 
                       to_char(r.datesubmitted, 'MM/DD/YYYY'), 
                       p.description, pr.name, s.open
                from $args{schema}.scrrequest r, $args{schema}.users u, 
                     $args{schema}.scrstatus s, 
                     $args{schema}.scrpriority p, $args{schema}.product pr 
                where $filterwhere r.status=s.id and 
                      r.submittedby=u.id and r.priority=p.id and 
                      r.product=pr.id 
                order by pr.id, r.id";
    my $results = $args{dbh} -> prepare ($pick);
    $results -> execute;
    while (my @values = $results -> fetchrow_array) {
        my ($rid, $sid, $status, $uid, $user, $desc, $date, $priority, $product, $isopen) = @values;
        $resultArray[$count][0] = $rid;
        $resultArray[$count][1] = $sid;
        $resultArray[$count][2] = $status;
        $resultArray[$count][3] = $uid;
        $resultArray[$count][4] = $user;
        $resultArray[$count][5] = $desc;
        $resultArray[$count][6] = $date;
        $resultArray[$count][7] = $priority;
        $resultArray[$count][8] = $product;
        $resultArray[$count][9] = $isopen;
        $count++;
    }
    $results -> finish;

    return ($count, @resultArray);
}

####################
sub getSCRRequests {
####################
    my %args = (
        where => "",
        script => "scrreview",
        due => 1,
        @_,
    );
    my $outstr;
    my $count = 0;
    my @resultArray;

    my $reqs = "select r.id, r.description, p.description,
                       pr.acronym, pr.id, ap.description,
                       to_char (r.datedue, 'MM/DD/YYYY'), 
                       r.status, t.name
                from $args{schema}.scrrequest r,
                     $args{schema}.scrpriority p,
                     $args{schema}.product pr,
                     $args{schema}.scrpriority ap,
                     $args{schema}.scrtype t
                where $args{where} and
                      r.priority=p.id and r.product=pr.id and
                      r.assignedpriority=ap.id(+) and
                      r.type = t.id
                order by r.status, r.product, r.id";
    my $csr = $args{dbh} -> prepare ($reqs);
    $csr -> execute;
    while (my ($rid, $desc, $rpri, $pro, $pid, $apri, $duedate, $statusid, $type) = $csr -> fetchrow_array) {
	$resultArray[$count][0] = $rid; 
	$resultArray[$count][1] = $desc; 
	$resultArray[$count][2] = $rpri; 
	$resultArray[$count][3] = $pro; 
	$resultArray[$count][4] = $pid; 
	$resultArray[$count][5] = $apri; 
	$resultArray[$count][6] = $duedate; 
	$resultArray[$count][7] = $statusid; 
	$resultArray[$count][8] = $type; 
	$count++;
    }
    $csr -> finish;
    return ($count, @resultArray);
}

###############
sub updateSCR {
###############
    my %args = (
        updatestr => "",
        analysis => "",
        rejrat => "",
        status => 0,
        actions => "",
        @_,
    );

    my $doupdate = $args{dbh} -> prepare ($args{updatestr});
    if ($args{analysis}) {
        $doupdate -> bind_param (":analysisclob", $args{analysis}, {ora_type => ORA_CLOB, ora_field => 'analysis'});
    }
    if ($args{rejrat} && $args{status} != 14 && $args{status} != 11){
        $doupdate -> bind_param (":rejclob", $args{rejrat}, {ora_type => ORA_CLOB, ora_field => 'rejectionrationale'});
    }
    if ($args{actions}){
        $doupdate -> bind_param (":actclob", $args{actions}, {ora_type => ORA_CLOB, ora_field => 'actionstaken'});
    }
    $doupdate -> execute;
    $doupdate -> finish;
}

###################
sub insertRemarks {
###################
    my %args = (
	rid => 0,
	pid => 0,
	remarks => "",
	@_,
    );
    my $insertrem = $args{dbh} -> prepare ("insert into $args{schema}.scrremarks (userid, requestid, dateentered, text, product) values ($args{uid}, $args{rid}, SYSDATE, :remclob, $args{pid})");
    $insertrem -> bind_param (":remclob", $args{remarks}, {ora_type => ORA_CLOB, ora_field => 'text'});
    $insertrem -> execute;
    $insertrem -> finish;
}

###############
1; #return true



