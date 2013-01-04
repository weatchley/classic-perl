#
# $Source: /data/dev/rcs/scm/perl/RCS/DBSCCB.pm,v $
#
# $Revision: 1.1 $ 
#
# $Date: 2002/12/12 00:09:54 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: DBSCCB.pm,v $
# Revision 1.1  2002/12/12 00:09:54  starkeyj
# Initial revision
#
#
package DBSCCB;
use strict;
use SCM_Header qw(:Constants);
use DB_scm qw(:Functions);
use UI_Widgets qw(:Functions);
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
      &doProcessCreateSCCB		&doProcessUpdateSCCB				&getSCCBList
      &getUserList				&getSCCBUserRoleList				&getSCCBRoleList
      &getSCCBProjectList
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doProcessCreateSCCB		&doProcessUpdateSCCB				&getSCCBList 
      &getUserList				&getSCCBUserRoleList				&getSCCBRoleList
      &getSCCBProjectList
    )]
);


###################################################################################################################################
###################################################################################################################################

###################################################################################################################################
sub doProcessCreateSCCB {  # routine to create the SCCB
###################################################################################################################################
    my %args = (
    	  sccbid => 0,
        project => 0,  # null
        title => 'Add',
        userID => 0,
        userName => '',
        roleList => '',
        @_,
    );

    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
	 my $sqlcode = '';
	 my $roleid = 0;
	 
	 my @roles = split /--/, $settings{roles};
	 my @primaries = split /--/, $settings{primaries};
	 my @alternates = split /--/, $settings{alternates};
	 my @projects = split /,/, $settings{sccbprojectlist};
	 print "roles: @roles<br>primaries: @primaries<br>alts: @alternates<br>projects: @projects<br>";
	 my $sccbid = &getNextSCCB;
	 $sqlcode = "insert into $args{schema}.sccb (id, name) VALUES ($sccbid, '$settings{sccbname}')";
	 my $status = $args{dbh}->do($sqlcode);
	 
	 $sqlcode = "update $args{schema}.project set sccbid = $sccbid where id in ($settings{sccbprojectlist})";
	 $status = $args{dbh}->do($sqlcode);
	 
	 for (my $k = 0; $k <= $#roles; $k++) {
	   my $roleAlready = &getRoleID(dbh=>$args{dbh},schema=>$args{schema},role=>$roles[$k]);
	 	if (!$roleAlready) {
	 		$roleid = &getNextRoleID;
	 		$sqlcode = "INSERT INTO $args{schema}.roles (id, type, description) ";
    		$sqlcode .= "VALUES ($roleid,1,'$roles[$k]')";
    		$status = $args{dbh}->do($sqlcode);
      }
    	else {$roleid = $roleAlready;}
    	
    	my @peeps = split /,/, $primaries[$k];
    	for (my $j=0;$j<$#peeps;$j++) {
    		for (my $p=0;$p<$#projects;$p++) {
    			$sqlcode = "INSERT INTO $args{schema}.user_roles (userid, projectid, roleid, isalt) ";
    			$sqlcode .= "VALUES ($peeps[$j],$projects[$p],$roleid,'F')";
    			$status = $args{dbh}->do($sqlcode);
    		}
    	}
    	
    	@peeps = split /,/, $alternates[$k];
		for (my $j=0;$j<$#peeps;$j++) {
			for (my $p=0;$p<$#projects;$p++) {
				$sqlcode = "INSERT INTO $args{schema}.user_roles (userid, projectid, roleid, isalt) ";
				$sqlcode .= "VALUES ($peeps[$j],$projects[$p],$roleid,'T')";
				$status = $args{dbh}->do($sqlcode);
			}
    	}
    }
    
    $args{dbh}->commit;
    &log_activity($args{dbh},$args{schema},$args{userID},"$settings{sccbname} succesfully created");
        
    return(1);
}


###################################################################################################################################
sub doProcessUpdateSCCB {  # routine to insert a document update into the DB
###################################################################################################################################
    my %args = (
    	  sccb => 0,
    	  project => 0,
        title => 'Add',
        userID => 0,
        userName => '',
        @_,
    );

	 my $hashRef = $args{settings};
	 my %settings = %$hashRef;
	 my $output = "";
	 my $sqlcode = '';
	 my $roleid = 0;
	 my @peeps;
	 my @roles = split /--/, $settings{roles};
	 my @updateroles = split /--/, $settings{updateroles};
	 my @removeroles = split /--/, $settings{removeroles};
	 my @primaries = split /--/, $settings{primaries};
	 my @alternates = split /--/, $settings{alternates};
	 my @updateprimaries = split /--/, $settings{updateprimaries};
	 my @updatealternates = split /--/, $settings{updatealternates};
	 my @projects = split /,/, $settings{sccbprojectlist};
	 
	 $sqlcode = "update $args{schema}.project set sccbid = NULL where sccbid = $args{sccb}";
	 my $status = $args{dbh}->do($sqlcode);
	 
	 $sqlcode = "update $args{schema}.project set sccbid = $args{sccb} where id in ($settings{sccbprojectlist})";
	 $status = $args{dbh}->do($sqlcode);
	 
	 
	 for (my $k = 0; $k <= $#removeroles; $k++) {
	 	$sqlcode = "DELETE FROM $args{schema}.user_roles ";
	 	$sqlcode .= "WHERE roleid = $removeroles[$k] AND projectid in ($settings{sccbprojectlist}) ";
	 	$status = $args{dbh}->do($sqlcode);
	 }
	 
	 for (my $k = 0; $k <= $#updateroles; $k++) {
		$sqlcode = "DELETE FROM $args{schema}.user_roles ";
		$sqlcode .= "WHERE roleid = $updateroles[$k] AND projectid in ($settings{sccbprojectlist}) ";
	 	$status = $args{dbh}->do($sqlcode);
	 	
	   @peeps = split /,/, $updateprimaries[$k];
	   for (my $j=0;$j<$#peeps;$j++) {
	   	for (my $p=0;$p<$#projects;$p++) {
    			$sqlcode = "INSERT INTO $args{schema}.user_roles (userid, projectid, roleid, isalt) ";
    			$sqlcode .= "VALUES ($peeps[$j],$projects[$p],$updateroles[$k],'F')";
    			$status = $args{dbh}->do($sqlcode);
    		}
    	}
    	
    	@peeps = split /,/, $updatealternates[$k];
		for (my $j=0;$j<$#peeps;$j++) {
			for (my $p=0;$p<$#projects;$p++) {
				$sqlcode = "INSERT INTO $args{schema}.user_roles (userid, projectid, roleid, isalt) ";
				$sqlcode .= "VALUES ($peeps[$j],$projects[$p],$updateroles[$k],'T')";
    			$status = $args{dbh}->do($sqlcode);
    		}
      }
	 }
	 
	 for (my $k = 0; $k <= $#roles; $k++) {
	   my $roleAlready = &getRoleID(dbh=>$args{dbh},schema=>$args{schema},role=>$roles[$k]);
	   if (!$roleAlready) {
	 		$roleid = &getNextRoleID;
	 		$sqlcode = "INSERT INTO $args{schema}.roles (id, type, description) ";
    		$sqlcode .= "VALUES ($roleid,1,'$roles[$k]')";
    		$status = $args{dbh}->do($sqlcode);
    	}
    	else {$roleid = $roleAlready;}
    	
    	@peeps = split /,/, $primaries[$k];
    	for (my $j=0;$j<$#peeps;$j++) {
    		for (my $p=0;$p<$#projects;$p++) {
    			$sqlcode = "INSERT INTO $args{schema}.user_roles (userid, projectid, roleid, isalt) ";
    			$sqlcode .= "VALUES ($peeps[$j],$projects[$p],$roleid,'F')";
    			$status = $args{dbh}->do($sqlcode);
    		}
    	}
    	
    	@peeps = split /,/, $alternates[$k];
		for (my $j=0;$j<$#peeps;$j++) {
			for (my $p=0;$p<$#projects;$p++) {
				$sqlcode = "INSERT INTO $args{schema}.user_roles (userid, projectid, roleid, isalt) ";
				$sqlcode .= "VALUES ($peeps[$j],$projects[$p],$roleid,'T')";
				$status = $args{dbh}->do($sqlcode);
			}
    	}
    }
	 
    $args{dbh}->commit;
    &log_activity($args{dbh},$args{schema},$args{userID},"$settings{sccbname} succesfully updated");
        
    return(1);
}


###################################################################################################################################
sub getSCCBList {  # routine to get a list of SCCB members
###################################################################################################################################
    my %args = (
        project => 0,
        sccb => 0,
        @_,
    );
       
    my @sccbList;
    my $sqlcode = "SELECT id, name ";
    $sqlcode .= "FROM $args{schema}.sccb ";
    $sqlcode .= "ORDER BY upper(name) ";

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($sccbList[$i]{sccbid},$sccbList[$i]{name}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@sccbList);
}

###################################################################################################################################
sub getSCCBProjectList {  # routine to get a list of SCCB members
###################################################################################################################################
    my %args = (
        project => 0,
        includesccb => 'T',
        sccb => 0,
        @_,
    );
       
    my $sccbstr = $args{includesccb} eq 'T' ? " sccbid = $args{sccb} " : " sccbid IS NULL ";
    my @sccbProjectList;
    my $sqlcode = "SELECT id, name FROM $args{schema}.project ";
    $sqlcode .= "WHERE $sccbstr ORDER BY upper(name) ";

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($sccbProjectList[$i]{projectid},$sccbProjectList[$i]{projectname}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@sccbProjectList);
}

###################################################################################################################################
sub getUserList {  # routine to get a list of SCCB members
###################################################################################################################################
    my %args = (
        project => 0,
        checkActive => 'F',
        @_,
    );
       
    my @userList;
    my $sqlcode = "SELECT id, lastname || ', ' || firstname as name ";
    $sqlcode .= "FROM $args{schema}.users ";
    $sqlcode .= $args{checkActive} eq 'T' ? "WHERE isactive = 'T' " : "" ;
    $sqlcode .= "ORDER BY upper(lastname) ";

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($userList[$i]{userid},$userList[$i]{name}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@userList);
}

###################################################################################################################################
sub getSCCBUserRoleList {  # routine to get a list of SCCB members
###################################################################################################################################
    my %args = (
        project => 0,
        sccb => 0,
        excludeRole => 0,
        includeRole => 0,
        isalt => 0,
        @_,
    );
       
    my @userRoleList;
    my $sqlcode = "SELECT u.id, firstname || ' ' || lastname as name ";
    $sqlcode .= "FROM $args{schema}.users u, $args{schema}.user_roles ur, ";
    $sqlcode .= "$args{schema}.sccb s, $args{schema}.project p ";
    $sqlcode .= "WHERE ur.userid = u.id AND s.id = p.sccbid ";
    $sqlcode .= "AND ur.projectid = p.id ";
    $sqlcode .= (($args{project} ne 0) ? "AND ur.projectid = $args{project} " : "");
    $sqlcode .= (($args{excludeRole} ne 0) ? "AND ur.roleid != $args{excludeRole} " : $args{sccb} ne 0 ? "" : "AND s.id = 0 ");
    $sqlcode .= (($args{includeRole} ne 0 && ($args{sccb} ne 0)) ? "AND ur.roleid = $args{includeRole} AND s.id = $args{sccb} " : "");
    $sqlcode .= (($args{isalt} ne 0 && ($args{sccb} ne 0)) ? "AND isalt = '$args{isalt}' " : "");
    $sqlcode .= "GROUP BY u.id, firstname, lastname ";
    $sqlcode .= "ORDER BY upper(u.lastname) ";

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($userRoleList[$i]{userid},$userRoleList[$i]{username}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@userRoleList);
}

###################################################################################################################################
sub getSCCBRoleList {  # routine to get a list of SCCB members
###################################################################################################################################
    my %args = (
        project => 0,
        sccb => 0,
        @_,
    );
       
    my @roleList;
    my $sqlcode = "SELECT distinct s.name, r.id, r.description ";
    $sqlcode .= "FROM $args{schema}.user_roles ur, $args{schema}.project p, ";
    $sqlcode .= "$args{schema}.sccb s, $args{schema}.roles r ";
    $sqlcode .= "WHERE s.id = $args{sccb} AND ur.projectid = p.id  ";
    $sqlcode .= "AND ur.roleid = r.id AND p.sccbid = s.id ";
    $sqlcode .= "ORDER BY r.id ";

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    
    my $i = 0;
    while (($roleList[$i]{sccbname},$roleList[$i]{roleid}, $roleList[$i]{rolename}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@roleList);
}
###################################################################################################################################
sub getNextSCCB {                                                                                                              #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $sccbid = $args{dbh}->selectrow_array("select $args{schema}.sccb_seq.nextval from dual ");
   
   if (defined($sccbid)) {return ($sccbid);}
   else {return 0;}
}

###################################################################################################################################
sub getNextRoleID {                                                                                                              #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $roleid = $args{dbh}->selectrow_array("select $args{schema}.role_seq.nextval from dual ");
   
   if (defined($roleid)) {return ($roleid);}
   else {return 0;}
}

###################################################################################################################################
sub getRoleID {                                                                                                              #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $roleid = $args{dbh}->selectrow_array("select id from $args{schema}.roles where upper(description) = upper('$args{role}') ");

   if (defined($roleid)) {return ($roleid);}
   else {return 0;}
}

###################################################################################################################################
###################################################################################################################################

sub new {
    my $self = {};
    bless $self;
    return $self;
}

# proccess variable name methods
sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self) || croak "$self is not an object";
    my $name = $AUTOLOAD;
    $name =~ s/.*://; # strip fully-qualified portion
    unless (exists $self->{$name} ) {
        croak "Can't Access '$name' field in object of class $type";
    }
    if (@_) {
        return $self->{$name} = shift;
    } else {
        return $self->{$name};
    }
}

1; #return true

