# DB Role functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBRoles.pm,v $
#
# $Revision: 1.6 $
#
# $Date: 2008/10/21 18:06:05 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBRoles.pm,v $
# Revision 1.6  2008/10/21 18:06:05  atchleyb
# ACR0810_002 - Updated to allow for routing questions
#
# Revision 1.5  2006/03/27 19:15:18  atchleyb
# CR 0023 - Updated to add a new function/utility for transfering pending approvals to a new role holder.
#
# Revision 1.4  2005/08/18 18:29:38  atchleyb
# CR00015 - added function getCurrentPendingDelegations
#
# Revision 1.3  2005/06/10 22:24:18  atchleyb
# Updates for CR0011
# added funciton getCurrentDelegate
#
# Revision 1.2  2004/04/01 23:52:07  atchleyb
# added lookup selection criteria
#
# Revision 1.1  2003/11/12 20:27:19  atchleyb
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
      &getUserSiteRolesHash          &doProcessUserRoleEntry       &getRoleListArray
      &getUserRoleInfoArray          &doProcessUserRoleDelegation  &getCurrentDelegate
      &getCurrentPendingDelegations  &getPendingApprovals          &getUserRoleListArray
      &doProcessReassignApprovals    &getRoleArray
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getUserSiteRolesHash          &doProcessUserRoleEntry       &getRoleListArray
      &getUserRoleInfoArray          &doProcessUserRoleDelegation  &getCurrentDelegate
      &getCurrentPendingDelegations  &getPendingApprovals          &getUserRoleListArray
      &doProcessReassignApprovals    &getRoleArray
    )]
);


###################################################################################################################################
sub getUserSiteRolesHash {  # routine to defined roles for a site for a user
###################################################################################################################################
    my %args = (
        userID => 0,
        site => 0,
        @_,
    );
    tie my %userRoles, "Tie::IxHash";
    
    my $sqlcode = "SELECT r.id, r.name FROM $args{schema}.roles r, $args{schema}.user_roles ur WHERE r.id=ur.role AND ur.userid=$args{userID} ";
    $sqlcode .= "AND ur.site=$args{site} ORDER BY r.name";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (my ($id, $name) = $csr->fetchrow_array) {
        $userRoles{$id} = $name;
    }
    $csr->finish;

    return (\%userRoles);
}


###################################################################################################################################
sub doProcessUserRoleEntry {  # routine to enter site roles for a user
###################################################################################################################################
    my %args = (
        userID => 0,
        site => 0,
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
    
        $args{dbh}->do("DELETE FROM $args{schema}.user_roles WHERE userid=$u_ID AND site=$args{site} AND role NOT IN ($roleString)");
        for (my $i=0; $i<=$#roleList; $i++) {
            my ($count) = $args{dbh}->selectrow_array("SELECT COUNT(*) FROM $args{schema}.user_roles WHERE userid=$u_ID AND site=$args{site} AND role=$roleList[$i]");
            if ($count == 0) {
                $sqlcode = "INSERT INTO $args{schema}.user_roles (userid, role, site) VALUES ($u_ID, $roleList[$i], $args{site})";
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
sub getRoleListArray {  # routine to get all roles for specified site(s) and all users in that role
###################################################################################################################################
    my %args = (
        site => 0,  # 0 = all sites
        @_,
    );
    my @roles;
    my $roleCount = 0;
    my $siteWhere = "";
    if ($args{site} != 0) {$siteWhere = "AND ur.site=$args{site}";}
    my $sqlcode = "SELECT id, name FROM $args{schema}.roles ORDER BY name";
    my $rcsr = $args{dbh}->prepare($sqlcode);
    $rcsr->execute;
    
    while (my ($roleid, $role) = $rcsr->fetchrow_array) {
        $roles[$roleCount]{id} = $roleid;
        $roles[$roleCount]{name} = $role;

        $sqlcode = "SELECT ur.userid,ur.role,ur.site,si.sitecode,NVL(ur.delegatedto,0), TO_CHAR(ur.delegationstart,'MM/DD/YYYY'),";
        $sqlcode .= "TO_CHAR(ur.delegationstop,'MM/DD/YYYY'),u.firstname,u.lastname,si.name FROM $args{schema}.user_roles ur, ";
        $sqlcode .= "$args{schema}.site_info si, $args{schema}.users u WHERE ur.site=si.id AND ur.userid=u.id AND ur.role=$roleid $siteWhere ";
        $sqlcode .= "ORDER BY si.sitecode, u.lastname, u.firstname";
        my $urcsr = $args{dbh}->prepare($sqlcode);
        $urcsr->execute;

        my $userCount = 0;
        while (my ($userid, $roleid, $site, $sitecode, $delegatedto, $delegationstart, $delegationstop, $firstname, $lastname, $sitename) = $urcsr->fetchrow_array) {
            $roles[$roleCount]{users}[$userCount]{userid} = $userid;
            $roles[$roleCount]{users}[$userCount]{roleid} = $roleid;
            $roles[$roleCount]{users}[$userCount]{site} = $site;
            $roles[$roleCount]{users}[$userCount]{sitecode} = $sitecode;
            $roles[$roleCount]{users}[$userCount]{delegatedto} = $delegatedto;
            $roles[$roleCount]{users}[$userCount]{delegationstart} = $delegationstart;
            $roles[$roleCount]{users}[$userCount]{delegationstop} = $delegationstop;
            $roles[$roleCount]{users}[$userCount]{firstname} = $firstname;
            $roles[$roleCount]{users}[$userCount]{lastname} = $lastname;
            $roles[$roleCount]{users}[$userCount]{sitename} = $sitename;
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
        site => 0,  # 0 = all sites
        role => 0, # 0 = all roles
        @_,
    );
    my @roles;
    my $roleCount = 0;
    my $userWhere = "";
    my $siteWhere = "";
    my $roleWhere = "";
    if ($args{userID} != 0) {$userWhere = "AND ur.userid=$args{userID}";}
    if ($args{site} != 0) {$siteWhere = "AND ur.site=$args{site}";}
    if ($args{role} != 0) {$roleWhere = "AND r.id=$args{role}";}
    
    my $sqlcode = "SELECT ur.userid,ur.role,ur.site,NVL(ur.delegatedto,0),TO_CHAR(ur.delegationstart,'MM/DD/YYYY'),";
    $sqlcode .= "TO_CHAR(ur.delegationstop,'MM/DD/YYYY'),si.sitecode,r.name,r.canbedelegated,si.name ";
    $sqlcode .= "FROM $args{schema}.user_roles ur, $args{schema}.site_info si, $args{schema}.roles r ";
    $sqlcode .= "WHERE ur.site=si.id AND ur.role=r.id $userWhere $siteWhere $roleWhere ";
    $sqlcode .= "ORDER BY si.sitecode, r.name";
    my $urcsr = $args{dbh}->prepare($sqlcode);
    $urcsr->execute;
    
    while (my ($userid,$roleid,$site,$delegatedto,$delegationstart,$delegationstop,$sitecode,$rolename,$canbedelegated,$sitename) = $urcsr->fetchrow_array) {
        ($roles[$roleCount]{userid},$roles[$roleCount]{roleid},$roles[$roleCount]{site},
              $roles[$roleCount]{delegatedto},$roles[$roleCount]{delegationstart},$roles[$roleCount]{delegationstop},
              $roles[$roleCount]{sitecode},$roles[$roleCount]{rolename},$roles[$roleCount]{canbedelegated},
              $roles[$roleCount]{sitename}) =
              ($userid,$roleid,$site,$delegatedto,$delegationstart,$delegationstop,$sitecode,$rolename,$canbedelegated,$sitename);
        $roleCount++;
    }
    $urcsr->finish;


    return (@roles);
}


###################################################################################################################################
sub doProcessUserRoleDelegation {  # routine to enter site roles for a user
###################################################################################################################################
    my %args = (
        userID => 0,
        rUserID => 0,
        role => 0,
        site => 0,
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
            $sqlcode .= "delegationstop=NULL WHERE userid=$args{rUserID} AND role=$args{role} AND site=$args{site}";
            $args{dbh}->do($sqlcode);
        } else {
            $sqlcode = "UPDATE $args{schema}.user_roles SET delegatedto=$settings{delegatedto}, ";
            $sqlcode .= "delegationstart=TO_DATE('$settings{delegationstart}','MM/DD/YYYY'), ";
            $sqlcode .= "delegationstop=TO_DATE('$settings{delegationstop}','MM/DD/YYYY') ";
            $sqlcode .= "WHERE userid=$args{rUserID} AND role=$args{role} AND site=$args{site}";
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
sub getCurrentDelegate {  # routine to the current (if any) delegate for a user/site/role
###################################################################################################################################
    my %args = (
        userID => 0,
        role => 0,
        site => 0,
        @_,
    );
    my $sqlcode = "SELECT NVL(delegatedto,0) FROM $args{schema}.user_roles WHERE userid=$args{userID} AND site=$args{site} ";
    $sqlcode .= "AND role=$args{role} AND delegationstart<=SYSDATE AND (delegationstop+1)>= SYSDATE";

    my ($delegate) = $args{dbh}->selectrow_array($sqlcode);
    
    return ($delegate);
}


###################################################################################################################################
sub getCurrentPendingDelegations {  # routine to get all current and pending role delegations
###################################################################################################################################
    my %args = (
        site => 0,  # 0 = all sites
        @_,
    );
    my @delegations;
    my $siteWhere = "";
    if ($args{site} != 0) {$siteWhere = "AND ur.site=$args{site}";}
    my $sqlcode = "SELECT r.id, r.name, ur.userid,ur.site,si.sitecode,ur.delegatedto, TO_CHAR(ur.delegationstart,'MM/DD/YYYY'), ";
    $sqlcode .= "TO_CHAR(ur.delegationstop,'MM/DD/YYYY'),u.firstname,u.lastname,si.name,u2.firstname,u2.lastname ";
    $sqlcode .= "FROM $args{schema}.roles r, $args{schema}.user_roles ur, $args{schema}.site_info si, $args{schema}.users u, $args{schema}.users u2 ";
    $sqlcode .= "WHERE ur.site=si.id AND ur.userid=u.id AND ur.delegatedto=u2.id AND ur.role=r.id AND ur.delegatedto IS NOT NULL ";
    $sqlcode .= "AND ur.delegationstop >= TO_DATE(TO_CHAR(sysdate,'MM/DD/YYYY'),'MM/DD/YYYY') $siteWhere ";
    $sqlcode .= "ORDER BY si.name,r.name,u.lastname";
#print STDERR "\n$sqlcode\n\n";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    my $count = 0;
    while (my ($roleid, $role, $userid, $site, $sitecode, $delegatedto, $delegationstart, $delegationstop, 
          $firstname, $lastname, $sitename, $dFirstname, $dLastname) = $csr->fetchrow_array) {
        $delegations[$count]{role}{id} = $roleid;
        $delegations[$count]{role}{name} = $role;
        $delegations[$count]{role}{site} = $sitename;
        $delegations[$count]{user}{id} = $userid;
        $delegations[$count]{user}{firstname} = $firstname;
        $delegations[$count]{user}{lastname} = $lastname;
        $delegations[$count]{delegation}{start} = $delegationstart;
        $delegations[$count]{delegation}{stop} = $delegationstop;
        $delegations[$count]{delegation}{user}{id} = $delegatedto;
        $delegations[$count]{delegation}{user}{firstname} = $dFirstname;
        $delegations[$count]{delegation}{user}{lastname} = $dLastname;
        $count++;
    }
    $csr->finish;
    
    return (@delegations);
}


###################################################################################################################################
sub getPendingApprovals {  # routine to get pending approvals
###################################################################################################################################
    my %args = (
        userID => 0,
        role => 0,
        site => 0,
        pd => "",
        @_,
    );
    my $where = "";
    $where .= (($args{userID} != 0) ? " AND al.userid=$args{userID}" : "");
    $where .= (($args{role} != 0) ? " AND al.role=$args{role}" : "");
    $where .= (($args{site} != 0) ? " AND d.site=$args{site}" : "");
    $where .= (($args{pd} ne "") ? " AND al.prnumber='$args{pd}'" : "");
    
    my $sqlcode = "SELECT al.prnumber, pd.ponumber, pd.amendment, al.role, al.userid, al.pdstatus, r.name, d.site, u.firstname, u.lastname ";
    $sqlcode .= "FROM $args{schema}.approval_list al, $args{schema}.purchase_documents pd, $args{schema}.departments d, ";
    $sqlcode .= "$args{schema}.roles r, $args{schema}.users u ";
    $sqlcode .= "WHERE al.prnumber=pd.prnumber AND al.role=r.id AND pd.deptid=d.id AND al.userid=u.id AND al.dateapproved IS NULL $where ";
    $sqlcode .= "ORDER BY u.lastname, pd.ponumber, al.prnumber, r.name";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    my $count = 0;
    my @pa;
    while (($pa[$count]{prnumber}, $pa[$count]{ponumber}, $pa[$count]{amendment}, $pa[$count]{role}, $pa[$count]{userid},  $pa[$count]{pdstatus}, 
           $pa[$count]{rolename}, $pa[$count]{site}, $pa[$count]{firstname}, $pa[$count]{lastname}) = $csr->fetchrow_array) {
        $count++;
    }

    
    return (@pa);
}


###################################################################################################################################
sub getUserRoleListArray {  # routine to get all users with a given role for specified site
###################################################################################################################################
    my %args = (
        site => 0,
        role => 0,
        @_,
    );
    my @users;
    my $count = 0;
    my $sqlcode = "SELECT ur.userid, ur.site, ur.role, u.lastname, u.firstname FROM $args{schema}.user_roles ur, $args{schema}.users u ";
    $sqlcode .= "WHERE ur.userid=u.id AND ur.site=$args{site} AND ur.role=$args{role} ORDER BY u.lastname, u.firstname";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($users[$count]{userid},$users[$count]{site},$users[$count]{role},$users[$count]{lastname},
          $users[$count]{firstname}) = $csr->fetchrow_array) {
        $count++
    }
    
    return (@users);
}


###################################################################################################################################
sub doProcessReassignApprovals {  # routine to process role reassignment
###################################################################################################################################
    my %args = (
        pd => '',
        oldUser => 0,
        newUser => 0,
        role => 0,
        @_,
    );
    my $status = 0;
    my $sqlcode = "UPDATE $args{schema}.approval_list SET userid=$args{newUser} WHERE prnumber='$args{pd}' AND role=$args{role} ";
    $sqlcode .= "AND userid=$args{oldUser} AND dateapproved IS NULL";
    
    $status = $args{dbh}->do($sqlcode);
    
    return ($status);
}


###################################################################################################################################
sub getRoleArray {  # routine to get all users with a given role for specified site
###################################################################################################################################
    my %args = (
        role => 0,
        @_,
    );
    my @roles;
    my $count = 0;
    my $where = ($args{role} > 0) ? " WHERE id=$args{role} " : "";
    my $sqlcode = "SELECT id, name, precedence, canbedelegated FROM $args{schema}.roles ";
    $sqlcode .= "$where ORDER BY name";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($roles[$count]{id},$roles[$count]{name},$roles[$count]{precedence},$roles[$count]{canbedelegated}) = $csr->fetchrow_array) {
        $count++
    }
    
    return (@roles);
}


###################################################################################################################################
###################################################################################################################################

1; #return true
