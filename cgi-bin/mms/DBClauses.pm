# DB Clauses functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBClauses.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2009/05/29 21:35:51 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBClauses.pm,v $
# Revision 1.2  2009/05/29 21:35:51  atchleyb
# ACR0905_001 - user change request, multiple changes
#
# Revision 1.1  2003/11/12 20:25:54  atchleyb
# Initial revision
#
#
#
#
#

package DBClauses;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getClauseArray     &doProcessClauseEntry
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getClauseArray     &doProcessClauseEntry
    )]
);


###################################################################################################################################
sub getClauseArray {  # routine to get an array of clauses
###################################################################################################################################
    my %args = (
        id => 0,
        activeOnly => 'T',
        @_,
    );

    my $i = 0;
    my @clauses;
    $args{dbh}->{LongReadLen} = 10000000;
    $args{dbh}->{LongTruncOk} = 0;
    my $sqlcode = "SELECT id, isactive, description, text FROM $args{schema}.clauses WHERE 1=1" . (($args{activeOnly} eq 'T') ? " AND isactive='T'" : "");

    if ($args{id} > 0) {$sqlcode .= "AND id=$args{id}";}
    $sqlcode .= "ORDER BY description";
#print STDERR "\n$sqlcode\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($clauses[$i]{id}, $clauses[$i]{isactive}, $clauses[$i]{description}, $clauses[$i]{text}) = $csr->fetchrow_array) {
        ($clauses[$i]{usecount}) = $args{dbh}->selectrow_array("select count(*) from rules where type in (4, 8, 9) and nvalue1=$clauses[$i]{id}");
        $i++;
    }
    $csr->finish;

    return (@clauses);
}


###################################################################################################################################
sub doProcessClauseEntry {  # routine to enter a new clause or update a clause
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "",  # new or update
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    my $id;
    
    eval {
        ($id) = (($args{type} eq 'new') ? $args{dbh}->selectrow_array("SELECT $args{schema}.clauses_id.NEXTVAL FROM dual") : ($settings{c_clauseid}));
        my $description = $settings{description};
        my $text = $settings{clause};
        my $isactive = $settings{isactive};
        if ($args{type} eq 'new') {
            $sqlcode = "INSERT INTO $args{schema}.clauses (id, isactive, description, text) VALUES ($id, '$isactive', " . $args{dbh}->quote($description) . ", :clause)";
            
#print STDERR "\n$sqlcode\n\n";
            my $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":clause", $text, {ora_type => ORA_CLOB, ora_field => 'text'});
            $status = $csr->execute;
        } else {
            $sqlcode = "UPDATE $args{schema}.clauses SET description = " .$args{dbh}->quote($description) . ", ";
            $sqlcode .= "isactive = '$isactive', ";
            $sqlcode .= "text = :clause ";
            $sqlcode .= "WHERE id = $id";
#print STDERR "\n$sqlcode\n\n";
            my $csr = $args{dbh}->prepare($sqlcode);
            $csr -> bind_param (":clause", $text, {ora_type => ORA_CLOB, ora_field => 'text'});
            $status = $csr->execute;
        }

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$id);
}


1; #return true
