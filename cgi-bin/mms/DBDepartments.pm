# DB Departments functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBDepartments.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2009/06/26 21:57:40 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBDepartments.pm,v $
# Revision 1.2  2009/06/26 21:57:40  atchleyb
# ACR0906_001 - List of changes
#
# Revision 1.1  2004/01/09 18:58:43  atchleyb
# Initial revision
#
#
#
#
#
#

package DBDepartments;
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
      &getDeptInfo     &doProcessDepartmentEntry   &doProcessDepartmentDelete
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getDeptInfo     &doProcessDepartmentEntry   &doProcessDepartmentDelete
    )]
);


###################################################################################################################################
sub getDeptInfo {  # routine to get a hash of dept info
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );

    my $i = 0;
    my %deptInfo;
    my $sqlcode = "SELECT id, name, site, chargenumber, manager, groupcode, active FROM $args{schema}.departments WHERE id=$args{id}";

    ($deptInfo{id}, $deptInfo{name}, $deptInfo{site}, $deptInfo{chargenumber}, $deptInfo{manager}, $deptInfo{groupcode}, $deptInfo{active}) = 
        $args{dbh}->selectrow_array($sqlcode);
    ($deptInfo{sitecode}, $deptInfo{sitename}) = $args{dbh}->selectrow_array("SELECT sitecode, name FROM $args{schema}.site_info WHERE id=$deptInfo{site}");
    $deptInfo{managername} = getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$deptInfo{manager});
    my ($count) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.departments WHERE id=$args{id} AND (id IN (SELECT deptid FROM $args{schema}.purchase_documents) " .
          "OR id IN (SELECT deptid FROM $args{schema}.pd_history) OR id IN (SELECT dept FROM $args{schema}.user_dept))");
    $deptInfo{isUsed} = (($count > 0) ? "T" : "F");
    ($count) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.purchase_documents WHERE deptid=$args{id} AND status < 19");
    $deptInfo{isCurrent} = (($count > 0) ? "T" : "F");

    return (%deptInfo);
}


###################################################################################################################################
sub doProcessDepartmentEntry {  # routine to enter a new department or update a department
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
        ($id) = (($args{type} eq 'new') ? $args{dbh}->selectrow_array("SELECT $args{schema}.departments_id.NEXTVAL FROM dual") : ($settings{deptid}));
        $settings{groupcode} = uc($settings{groupcode});
        if ($args{type} eq 'new') {
            $sqlcode = "INSERT INTO $args{schema}.departments (id, name, site, chargenumber, manager, groupcode) VALUES ";
            $sqlcode .= "($id, " . $args{dbh}->quote($settings{name}) . ",$settings{site}, '$settings{chargenumber}', ";
            $sqlcode .= "$settings{manager}, '$settings{groupcode}')";
            
#print STDERR "\n$sqlcode\n\n";
            $args{dbh}->do($sqlcode);
        } else {
            $sqlcode = "UPDATE $args{schema}.departments SET name = " .$args{dbh}->quote($settings{name}) . ", ";
            $sqlcode .= "chargenumber = '$settings{chargenumber}', manager=$settings{manager}, groupcode='$settings{groupcode}', ";
            $sqlcode .= "active = '$settings{active}' ";
            $sqlcode .= "WHERE id = $id";
#print STDERR "\n$sqlcode\n\n";
            $args{dbh}->do($sqlcode);
        }

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$id);
}


###################################################################################################################################
sub doProcessDepartmentDelete {  # routine to delete an unused a department
###################################################################################################################################
    my %args = (
        userID => 0,
        id => 0, 
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    my $id;
    
    eval {
        $sqlcode = "DELETE FROM $args{schema}.departments WHERE id=$args{id}";
print STDERR "\n$sqlcode\n\n";
        $args{dbh}->do($sqlcode);

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$id);
}


###################################################################################################################################
###################################################################################################################################


1; #return true
