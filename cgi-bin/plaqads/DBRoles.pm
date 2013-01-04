# DB Role functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/DBRoles.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/07/27 18:27:16 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBRoles.pm,v $
# Revision 1.1  2004/07/27 18:27:16  atchleyb
# Initial revision
#
#
#
#
#

package DBRoles;
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
      &getUserRolesHash          &doProcessUserRoleEntry       &getRoleListArray
      &getUserRoleInfoArray      &doProcessUserRoleDelegation
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getUserRolesHash      &doProcessUserRoleEntry       &getRoleListArray
      &getUserRoleInfoArray      &doProcessUserRoleDelegation
    )]
);


###################################################################################################################################
sub getUserRolesHash {  # routine to defined roles for a user
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    tie my %userRoles, "Tie::IxHash";
    
    my $sqlcode = "SELECT r.id, r.name FROM $args{schema}.roles r, $args{schema}.user_roles ur WHERE r.id=ur.role AND ur.userid=$args{userID} ";
    $sqlcode .= " ORDER BY r.name";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (my ($id, $name) = $csr->fetchrow_array) {
        $userRoles{$id} = $name;
    }
    $csr->finish;

    return (\%userRoles);
}


###################################################################################################################################
sub doProcessUserRoleEntry {  # routine to enter roles for a user
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $userName = "";
    my $u_ID = $settings{u_id};
    my $sqlcode;
    my $status = 0;
    
    eval {
        
        my $roleRef = $settings{rolelist};
        my @roleList = @$roleRef;
        my $roleString = "0";
        
        for (my $i=0; $i<$#roleList; $i++) {
            $roleString .= ", $roleList[$i]";
        }
    
        $args{dbh}->do("DELETE FROM $args{schema}.user_roles WHERE userid=$u_ID AND role NOT IN ($roleString)");
        for (my $i=0; $i<=$#roleList; $i++) {
            my ($count) = $args{dbh}->selectrow_array("SELECT COUNT(*) FROM $args{schema}.user_roles WHERE userid=$u_ID AND role=$roleList[$i]");
            if ($count == 0) {
                $sqlcode = "INSERT INTO $args{schema}.user_roles (userid, role) VALUES ($u_ID, $roleList[$i])";
                $args{dbh}->do($sqlcode);
            }
        }
        $userName = &getUserName(dbh => $args{dbh}, schema => $args{schema}, userID => $u_ID);

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$userName);
}


###################################################################################################################################
sub getRoleListArray {  # routine to get all roles for specified and all users in that role
###################################################################################################################################
    my %args = (
        @_,
    );
    my @roles;
    my $roleCount = 0;
    my $sqlcode = "SELECT id, name FROM $args{schema}.roles ORDER BY name";
    my $rcsr = $args{dbh}->prepare($sqlcode);
    $rcsr->execute;
    
    while (my ($roleid, $role) = $rcsr->fetchrow_array) {
        $roles[$roleCount]{id} = $roleid;
        $roles[$roleCount]{name} = $role;

        $sqlcode = "SELECT ur.userid,ur.role,NVL(ur.delegatedto,0), TO_CHAR(ur.delegationstart,'MM/DD/YYYY'),";
        $sqlcode .= "TO_CHAR(ur.delegationstop,'MM/DD/YYYY'),u.firstname,u.lastname FROM $args{schema}.user_roles ur, ";
        $sqlcode .= "$args{schema}.users u WHERE ur.userid=u.id AND ur.role=$roleid ";
        $sqlcode .= "ORDER BY u.lastname, u.firstname";
        my $urcsr = $args{dbh}->prepare($sqlcode);
        $urcsr->execute;

        my $userCount = 0;
        while (my ($userid, $roleid, $delegatedto, $delegationstart, $delegationstop, $firstname, $lastname) = $urcsr->fetchrow_array) {
            $roles[$roleCount]{users}[$userCount]{userid} = $userid;
            $roles[$roleCount]{users}[$userCount]{roleid} = $roleid;
            $roles[$roleCount]{users}[$userCount]{delegatedto} = $delegatedto;
            $roles[$roleCount]{users}[$userCount]{delegationstart} = $delegationstart;
            $roles[$roleCount]{users}[$userCount]{delegationstop} = $delegationstop;
            $roles[$roleCount]{users}[$userCount]{firstname} = $firstname;
            $roles[$roleCount]{users}[$userCount]{lastname} = $lastname;
            $userCount++;
        }
        $urcsr->finish;
        $roles[$roleCount]{userCount} = $userCount;

        $roleCount++;
    }
    $rcsr->finish;
    
    return (@roles);
}


###################################################################################################################################
sub getUserRoleInfoArray {  # routine to get all roles for specified user
###################################################################################################################################
    my %args = (
        userID => 0,
        role => 0, # 0 = all roles
        @_,
    );
    my @roles;
    my $roleCount = 0;
    my $userWhere = "";
    my $roleWhere = "";
    if ($args{userID} != 0) {$userWhere = "AND ur.userid=$args{userID}";}
    if ($args{role} != 0) {$roleWhere = "AND r.id=$args{role}";}
    
    my $sqlcode = "SELECT ur.userid,ur.role,NVL(ur.delegatedto,0),TO_CHAR(ur.delegationstart,'MM/DD/YYYY'),";
    $sqlcode .= "TO_CHAR(ur.delegationstop,'MM/DD/YYYY'),r.name,r.canbedelegated ";
    $sqlcode .= "FROM $args{schema}.user_roles ur, $args{schema}.roles r ";
    $sqlcode .= "WHERE ur.role=r.id $userWhere $roleWhere ";
    $sqlcode .= "ORDER BY r.name";
    my $urcsr = $args{dbh}->prepare($sqlcode);
    $urcsr->execute;
    
    while (my ($userid,$roleid,$delegatedto,$delegationstart,$delegationstop,$rolename,$canbedelegated) = $urcsr->fetchrow_array) {
        ($roles[$roleCount]{userid},$roles[$roleCount]{roleid},
              $roles[$roleCount]{delegatedto},$roles[$roleCount]{delegationstart},$roles[$roleCount]{delegationstop},
              $roles[$roleCount]{rolename},$roles[$roleCount]{canbedelegated}) =
              ($userid,$roleid,$delegatedto,$delegationstart,$delegationstop,$rolename,$canbedelegated);
        $roleCount++;
    }
    $urcsr->finish;


    return (@roles);
}


###################################################################################################################################
sub doProcessUserRoleDelegation {  # routine to enter roles for a user
###################################################################################################################################
    my %args = (
        userID => 0,
        rUserID => 0,
        role => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $userName = "";
    my $sqlcode;
    my $status = 0;
    
    eval {
        if ($settings{delegatedto} == 0) {
            $sqlcode = "UPDATE $args{schema}.user_roles SET delegatedto=NULL, delegationstart=NULL, ";
            $sqlcode .= "delegationstop=NULL WHERE userid=$args{rUserID} AND role=$args{role}";
            $args{dbh}->do($sqlcode);
        } else {
            $sqlcode = "UPDATE $args{schema}.user_roles SET delegatedto=$settings{delegatedto}, ";
            $sqlcode .= "delegationstart=TO_DATE('$settings{delegationstart}','MM/DD/YYYY'), ";
            $sqlcode .= "delegationstop=TO_DATE('$settings{delegationstop}','MM/DD/YYYY') ";
            $sqlcode .= "WHERE userid=$args{rUserID} AND role=$args{role}";
            $args{dbh}->do($sqlcode);
        }

    
        $userName = &getUserName(dbh => $args{dbh}, schema => $args{schema}, userID => $args{rUserID});

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$userName);
}


###################################################################################################################################
###################################################################################################################################

1; #return true
