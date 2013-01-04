# DB User functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/DBUsers.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2004/11/16 19:33:41 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBUsers.pm,v $
# Revision 1.2  2004/11/16 19:33:41  atchleyb
# added new browse filters
#
# Revision 1.1  2004/07/27 18:27:16  atchleyb
# Initial revision
#
#
#
#
#

package DBUsers;
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
      &getNextUsersID          &getUserArray             &getUserInfo         &doProcessEnableDisableUser
      &doProcessResetPassword  &doProcessChangePassword  &doProcessUserEntry  &isReusedPassword
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getNextUsersID          &getUserArray             &getUserInfo          &doProcessEnableDisableUser
      &doProcessResetPassword  &doProcessChangePassword  &doProcessUserEntry   &isReusedPassword
    )]
);


###################################################################################################################################
sub getNextUsersID { # routine to get the next available users id
###################################################################################################################################
    my %args = (
        @_,
    );
    my ($usersID) = $args{dbh}->selectrow_array("SELECT $args{schema}.users_id.NEXTVAL from DUAL");
    return ($usersID);
}


###################################################################################################################################
sub getUserArray {  # routine to get an array of users
###################################################################################################################################
    my %args = (
        onlyActive => 'T',
        where => "",
        startID => 0,
        endID => 0,
        privilege => 0,
        role => 0,
        userName => "",
        enteredDocument => 'F',
        enteredExtraction => 'F',
        excludeDevelopers => 'F',
        orderBy => "lastname, firstname",
        @_,
    );

    my $i = 0;
    my @users;
    my $sqlcode = "SELECT id, username, firstname, lastname, organization, areacode, phonenumber, extension, email, isactive, location, accesstype, ";
    $sqlcode .= "failedattempts, lockout, dateaccountexpires ";
    $sqlcode .= "FROM $args{schema}.users WHERE id>0 ";
    $sqlcode .= (($args{onlyActive} eq "T") ? "AND isactive='T' ": "");
    $sqlcode .= (($args{startID} ne 0) ? "AND (id >= $args{startID}) ": "");
    $sqlcode .= (($args{endID} ne 0) ? "AND (id <= $args{endID}) ": "");
    $sqlcode .= (($args{where} gt "") ? "AND ($args{where}) ": "");
    $sqlcode .= (($args{privilege} != 0) ? "AND (id IN (SELECT userid FROM $args{schema}.user_privilege WHERE privilege=$args{privilege})) ": "");
    $sqlcode .= (($args{role} != 0) ? "AND (id IN (SELECT userid FROM $args{schema}.user_roles WHERE role=$args{role})) ": "");
    $sqlcode .= (($args{userName} gt "") ? "AND (username = '$args{userName}') ": "");
    $sqlcode .= (($args{enteredDocument} eq "T") ? "AND (id IN (SELECT enteredby FROM $args{schema}.document_versions)) ": "");
    #$sqlcode .= (($args{enteredExtraction} eq "T") ? "AND (id IN (SELECT savedby FROM $args{schema}.extraction_versions)) ": "");
    $sqlcode .= (($args{enteredExtraction} eq "T") ? "AND (id IN (SELECT dv.enteredby FROM $args{schema}.document_versions dv, " .
                  "$args{schema}.extractions e WHERE dv.documentid=e.sourcedoc)) ": "");
    $sqlcode .= (($args{excludeDevelopers} eq 'T') ? "AND (id <1000) " : "");
    $sqlcode .= "ORDER BY $args{orderBy}";
#print STDERR "\n$sqlcode\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($users[$i]{id}, $users[$i]{username}, $users[$i]{firstname}, 
            $users[$i]{lastname}, $users[$i]{organization}, 
            $users[$i]{areacode}, $users[$i]{phonenumber}, 
            $users[$i]{extension}, $users[$i]{email}, $users[$i]{isactive}, 
            $users[$i]{location}, $users[$i]{accesstype},
            $users[$i]{failedattempts}, $users[$i]{lockout}, $users[$i]{dateaccountexpires}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;

    return (@users);
}


###################################################################################################################################
sub getUserInfo { # routine to get user info
###################################################################################################################################
    my %args = (
        ID => 0,
        @_,
    );
    my %userInfo;
    my @users = getUserArray(dbh => $args{dbh}, schema => $args{schema}, startID => $args{ID}, endID => $args{ID}, onlyActive => 'F');
    
    my $hashref = $users[0];
    %userInfo = %$hashref;
    
    my $sqlcode = "SELECT sp.id, sp.name FROM $args{schema}.system_privilege sp, $args{schema}.user_privilege up WHERE (sp.id = up.privilege) AND ";
    $sqlcode .= "up.userid = $userInfo{id} ORDER BY sp.name";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    $userInfo{privileges} = "";
    $userInfo{privilegeids} = "";
    
    while (my ($id, $privilege) = $csr->fetchrow_array) {
        $userInfo{privileges} .= "$privilege\t";
        $userInfo{privilegeids} .= "$id\t";
        $userInfo{privHash}{$id} = $privilege;
        $userInfo{"priv$id"} = $privilege;
    }
    $csr->finish;
    
    $sqlcode = "SELECT r.id, r.name, NVL(ur.delegatedto, 0), ur.delegationstart, ur.delegationstop FROM $args{schema}.user_roles ur, ";
    $sqlcode .= "$args{schema}.roles r WHERE ur.role=r.id AND ur.userid=$userInfo{id} ";
    $sqlcode .= "ORDER BY r.name";
    
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    $userInfo{roles} = "";
    $userInfo{roleids} = "";
    
    while (my ($id, $role, $delegatedto, $delgationstart, $delegationstop) = $csr->fetchrow_array) {
        $userInfo{roles} .= "$role\t";
        $userInfo{roleids} .= "$id\t";
        $userInfo{roleHash}{"$id"} = "$role";
        $userInfo{"role$id"} = "$role";
        if ($delegatedto != 0) {
            my $user = &getFullName(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$delegatedto);
            my $tempText = " (Delegated to $user from $delgationstart to $delegationstop)";
            $userInfo{roleHash}{"$id"} .= $tempText;
            $userInfo{"role$id"} .= $tempText;
        }
    }
    $csr->finish;

    return (%userInfo);
}


###################################################################################################################################
sub doProcessResetPassword {  # routine to reset a user's password
###################################################################################################################################
    my %args = (
        userID => 0,
        password => "$DefPassword",
        @_,
    );

    eval {
        $args{dbh}->do("UPDATE $args{schema}.users SET password='" . (&db_encrypt_password($args{password})) . "', datepasswordexpires=SYSDATE WHERE id=$args{userID}");
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
sub doProcessChangePassword {  # routine to change a user's password
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $status = 0;
    
    eval {
        my $oldPasswordTest = &db_encrypt_password($settings{oldpassword});
        my ($oldPassword) = $args{dbh}->selectrow_array("SELECT password FROM $args{schema}.users WHERE id=$args{userID}");
    
        if ($oldPasswordTest ne $oldPassword) {
            $status = -1;
        } else {
            for (my $i=5; $i>=1; $i--) {
                my $j = $i + 1;
                $status = $args{dbh}->do("UPDATE $args{schema}.users SET oldpassword$j=oldpassword$i WHERE id=$args{userID}");
            }
            $status = $args{dbh}->do("UPDATE $args{schema}.users SET password='" . (&db_encrypt_password($settings{newpassword})) . "', " .
                "datepasswordexpires = ADD_MONTHS(SYSDATE, $SYSPasswordExpireMonths), oldpassword1='$oldPassword' WHERE id=$args{userID}");
        }

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return ($status);
}


###################################################################################################################################
sub isReusedPassword {  # routine to test if user reused an old password
###################################################################################################################################
    my %args = (
        userID => 0,
        password => "password",
        @_,
    );
    my $status = 0;

    eval {
        my $testPassword = &db_encrypt_password($args{password});
        my (@passwords) = $args{dbh}->selectrow_array("SELECT oldpassword1, oldpassword2, oldpassword3, oldpassword4, oldpassword5, " .
              "oldpassword6 FROM $args{schema}.users WHERE id=$args{userID}");
        for (my $i=0; $i<=$#passwords; $i++) {
            if ($passwords[$i] eq $testPassword) {
                $status = 1;
            }
        }
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return ($status);
}


###################################################################################################################################
sub doProcessEnableDisableUser {  # routine to disable or enable a user
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "Enable",
        @_,
    );

    eval {
        $args{dbh}->do("UPDATE $args{schema}.users SET isactive='" . (($args{type} eq "Enable") ? "T" : "F") . "' WHERE id=$args{userID}");
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
sub doProcessUserEntry {  # routine to enter a new user or update a user
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "",  # new or update
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $userName = "";
    my $u_ID = (($args{type} eq 'new') ? &getNextUsersID(dbh => $args{dbh}, schema => $args{schema}) : $settings{u_id});
    my $sqlcode;
    my $status = 0;
    
    eval {
        if ($args{type} eq 'new') {
            my $tempLastName = $settings{lastname};
            $tempLastName =~ s/'//g;
            $tempLastName =~ s/ //g;
            if (length($tempLastName) >19) {
                $userName = substr (uc($tempLastName), 0, 19) . substr(uc($settings{firstname}), 0, 1);
            } else {
                $userName = uc($tempLastName) . substr(uc($settings{firstname}), 0, 1);
            }
            #my $password = (&db_encrypt_password($DefPassword));
            my $password = (&db_encrypt_password($settings{password}));
            $sqlcode = "INSERT INTO $args{schema}.users (id, username, firstname, lastname, organization, areacode, phonenumber, extension, ";
            $sqlcode .= "password, email, isactive,datepasswordexpires, location, accesstype) VALUES ($u_ID, '$userName', ";
            $sqlcode .= $args{dbh}->quote($settings{firstname}) . ", " . $args{dbh}->quote($settings{lastname}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{organization}) . ", $settings{areacode}, $settings{phonenumber}, ";
            $sqlcode .= ((defined($settings{extension})) ? "'$settings{extension}'" : "NULL") . ", '$password', ";
            $sqlcode .= $args{dbh}->quote($settings{email}) . ", 'T', ADD_MONTHS(SYSDATE, $SYSPasswordExpireMonths), " . $args{dbh}->quote($settings{location}) . ", ". $args{dbh}->quote($settings{accesstype}) . ")";
#print STDERR "\n$sqlcode\n\n";
            $status = $args{dbh}->do($sqlcode);
        } else {
            $userName = &getUserName(dbh => $args{dbh}, schema => $args{schema}, userID => $u_ID);
            $sqlcode = "UPDATE $args{schema}.users SET firstname = " .$args{dbh}->quote($settings{firstname}) . ", ";
            $sqlcode .= "lastname = " . $args{dbh}->quote($settings{lastname}) . ", organization = " . $args{dbh}->quote($settings{organization}) . ", ";
            $sqlcode .= "areacode = $settings{areacode}, phonenumber = $settings{phonenumber}, ";
            $sqlcode .= "extension = " . ((defined($settings{extension})) ? "'$settings{extension}'" : "NULL") . ", ";
            $sqlcode .= "email = " . $args{dbh}->quote($settings{email}) . ", ";
            $sqlcode .= "location = " . $args{dbh}->quote($settings{location}) . ", ";
            $sqlcode .= "accesstype = " . $args{dbh}->quote($settings{accesstype}) . " ";
            $sqlcode .= "WHERE id = $u_ID";
#print STDERR "\n$sqlcode\n\n";
            $status = $args{dbh}->do($sqlcode);
        }
        
        my $privRef = $settings{privlist};
        my @privList = @$privRef;
    
        $args{dbh}->do("DELETE FROM $args{schema}.user_privilege WHERE userid=$u_ID AND privilege > 0");
        for (my $i=0; $i<=$#privList; $i++) {
            $sqlcode = "INSERT INTO $args{schema}.user_privilege (userid, privilege) VALUES ($u_ID, $privList[$i])";
#print STDERR "\n$sqlcode\n\n";
            $args{dbh}->do($sqlcode);
        }

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$userName);
}


1; #return true
