#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/pcl/perl/RCS/DBShared.pm,v $
# $Revision: 1.19 $
# $Date: 2003/02/14 18:17:34 $
#
# $Author: atchleyb $
# $Locker:  $
#
# $Log: DBShared.pm,v $
# Revision 1.19  2003/02/14 18:17:34  atchleyb
# added improved password security
#
# Revision 1.18  2003/02/03 18:48:17  atchleyb
# updated to remove PCL from script and variable names
#
# Revision 1.17  2003/01/28 00:10:21  atchleyb
# turned on encrypted schma password use
#
# Revision 1.16  2003/01/27 22:44:41  atchleyb
# changed all references to SCM to PCL
# added functions for decrypting schema password
# added line in getOracleID to decrypt password (commented out until needed)
#
# Revision 1.15  2002/12/28 00:10:50  johnsonc
# Added the 'isactive' attribute to the getUser function
#
# Revision 1.14  2002/11/27 21:15:49  atchleyb
# removed the function 'getUserUnixID'
#
# Revision 1.13  2002/11/27 21:06:59  starkeyj
# modified getUsers so location is not selected (not a column) and modified getProjectInfo
# to include isNotes and sccbid in the select (new columns)
#
# Revision 1.12  2002/11/08 20:28:10  atchleyb
# updated calling format for doesUserHavePriv
#
# Revision 1.11  2002/11/07 23:54:25  atchleyb
# removed checkLogin function, added isNotes column to get project functions
#
# Revision 1.10  2002/11/07 02:46:32  mccartym
# modified checkLogin() to check for POST method
#
# Revision 1.9  2002/11/06 22:20:02  atchleyb
# updated activity and error logging to allow a project ID
#
# Revision 1.8  2002/11/01 21:57:44  starkeyj
# modified functions that return a hash and have an 'order by' in the select statement
# so they return the hash sorted as requested (use Tie)
#
# Revision 1.7  2002/10/31 17:14:55  atchleyb
# removed several functions that belonged in other modules or were not needed
# add new versions of some functions using new calling paramenters
#
# Revision 1.6  2002/10/18 17:56:57  mccartym
# added getUnixUserID function
#
# Revision 1.5  2002/09/20 23:18:46  atchleyb
# removed unneeded setUser and setUserPriv functions
# added new versions of old functions with named parameters
#
# Revision 1.4  2002/09/18 23:08:53  atchleyb
# removed redundant errormessage function
#
# Revision 1.3  2002/09/18 21:59:05  atchleyb
# updated to include missing functions from DB_utilities that are used
#
# Revision 1.2  2002/09/18 16:52:16  atchleyb
# removed the use of oracle connect script, replaced with readFile.pl
#
# Revision 1.1  2002/09/17 20:03:40  atchleyb
# Initial revision
#
#
package DBShared;
use strict;
use Carp;
use SharedHeader qw(:Constants);
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw($DBUser $SYSConnectPath $SYSServer);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

$DBUser = $ENV{'DBUser'};
$SYSConnectPath = $ENV{'SYSConnectPath'};
$SYSServer = $ENV{'SYSServer'};

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (
      &db_connect          &db_disconnect      &getSysdate           
      &getProjects         &getUsersByPrivilege 
      &getUsers            &getItemType        
      &createSequence      &getProducts        &getProjectInfo       
      &db_encrypt_password &get_userid         &updateActivityLog    &updateActivityLog 
      &log_activity        &log_error          &does_user_have_priv  &doesUserHavePriv   &get_username 
      &get_fullname        &get_lookup_values  &get_date             &getFullName        &getUserID 
      &getUserName         &logError           &logActivity          &getLookupValues    
      &isNotesProject
);
@EXPORT_OK = qw(
      &db_connect          &db_disconnect      &getSysdate           
      &getProjects         &getUsersByPrivilege 
      &getUsers            &getItemType        
      &createSequence      &getProducts        &getProjectInfo       
      &db_encrypt_password &get_userid         &updateActivityLog    &updateActivityLog 
      &log_activity        &log_error          &does_user_have_priv  &doesUserHavePriv   &get_username 
      &get_fullname        &get_lookup_values  &get_date             &getFullName        &getUserID 
      &getUserName         &logError           &logActivity          &getLookupValues    
      &isNotesProject
);
%EXPORT_TAGS =(
    Functions => [qw(
      &db_connect          &db_disconnect      &getSysdate           
      &getProjects         &getUsersByPrivilege 
      &getUsers            &getItemType        
      &createSequence      &getProducts        &getProjectInfo       
      &db_encrypt_password &get_userid         &updateActivityLog    &updateActivityLog 
      &log_activity        &log_error          &does_user_have_priv  &doesUserHavePriv   &get_username 
      &get_fullname        &get_lookup_values  &get_date             &getFullName        &getUserID 
      &getUserName         &logError           &logActivity          &getLookupValues    
      &isNotesProject
    ) 
]);


################################################################################################################
sub caesar {
# caesar cipher
################################################################################################################
    my $text = shift;
    my $key = shift;
    
    #key of 0 does nothing
    my $ks = $key % 26 or return $text;
    my $ke = $ks -1;
    
    my ($s, $S, $e, $E);
    $s = chr(ord('a') + $ks);
    $S = chr(ord('A') + $ks);
    $e = chr(ord('a') + $ke);
    $E = chr(ord('A') + $ke);
    
    eval "\$text =~ tr/a-zA-Z/$s-za-$e$S-ZA-$E/;";
    
    return $text;
}


################################################################################################################
sub decrypt {
# description code
################################################################################################################
    my %args = (
          text => '',
          key => '',
          depth => 5,
          @_,
          );
    
    my $outString = '';
    my $testKey = $args{key};
    my $text = '';
    for (my $i=0; $i<length($args{text}); $i += 3) {
        $text .= chr(substr($args{text}, $i, 3));
    }
    while (length($testKey) < (length($text) + $args{depth})) {
        $testKey .= $args{key};
    }
    
    for (my $i=0; $i<length($text); $i++) {
        my $temp = substr($text,$i,1);
        for (my $j=0; $j<$args{depth}; $j++) {
            my $keySeg = substr($testKey,($i + ($args{depth} - $j -1)),1);
            $temp = $temp ^ $keySeg;
            $temp = caesar($temp, ((26-($i+1))%26));
        }
        $outString .= $temp;
    }
    
    return ($outString);
}



################################################################################################################
sub getOracleID {
#
# Routine to get username/password for oracle. This is a helper function for the db_connect routine.
#
################################################################################################################
    my $username = $DBUser;
    my $password;
    my $temp;
    if (open (FH, "$SYSConnectPath |")) {
       ($temp, $password) = split('//', <FH>);
        chomp($password);
        $password = decrypt(text => $password, key => $SYSPassKey);
        close (FH);
    } else {
        $username = "null";
        $password = "null";
    }
    return ($username, $password);
}

################################################################################################################
sub db_connect {
#
# Routine to connect to the oracle database.
#
################################################################################################################
    my %args = (
          server => $SYSServer,
          @_,
          );
    my $dbh;
    my $username;
    my $password;
    ($username, $password) = getOracleID;
    eval {
    	  $dbh = DBI->connect("dbi:Oracle:$args{server}",$username,$password, { RaiseError => 1, AutoCommit => 0 });
    };
    if ($@) {
        print STDERR "\nDBShared.pm/db_connect - Error Message: $@\n";
    }
    return ($dbh);
}


################################################################################################################
sub db_disconnect {
#
# routine to disconnect from the oracle database
#
#
################################################################################################################

    my $dbh = $_[0];
    my $rc;
    eval {
        $rc = $dbh->disconnect;
    };
    if ($@) {
        print STDERR "\nDBShared.pm/db_disconnect - Error Message: $@\n";
    }
    return ($rc);
}


################################################################################################################
sub db_encrypt_password {
# routine to encrypt a password
################################################################################################################
    my $input_password = $_[0];
    $input_password = $input_password;
    my $password = crypt ($input_password, "database");
    if (length($input_password)>8) {
        $password .= crypt (substr($input_password, 8), "database");
    }
    while (length($password) > 26) {
        chop ($password);
    }
    return ($password);
}


################################################################################################################
sub get_userid {
# routine to get a user id
################################################################################################################
    my $dbh = $_[0];
    my $schema = $_[1];
    my $username = $_[2];
    my @values;
    $username = uc($username);
    my $sqlquery = "select id from $schema.users where username = '$username'";
    my $csr = $dbh->prepare($sqlquery);
        $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    return ($values[0]);
}


################################################################################################################
sub getUserID {
# routine to get a user id
################################################################################################################
    my %args = (
          userName => "",
          @_,
          );

    my ($userID) = $args{dbh}->selectrow_array("SELECT id FROM $args{schema}.users WHERE username='$args{userName}'");
    
    return ($userID);
}


################################################################################################################
sub log_error {
#
# Routine to insert an error into the activity log. This is a helper function called by the
# updateActivityLog routine.
#
#
################################################################################################################														  
    return(updateActivityLog ($_[0], $_[1], $_[2], $_[3], 'T', 0));
}


################################################################################################################
sub logError {
#
# Routine to insert an error into the activity log. This is a helper function called by the
# updateActivityLog routine.
#
#
################################################################################################################														  
    my %args = (
        schema => "$SCHEMA",
        userID => 0,
        logMessage => "",
        errorStatus => "T",
        projectID => 0,
        @_,
        );	
    return(updateActivityLog ($args{dbh}, $args{schema}, $args{userID}, $args{logMessage}, $args{errorStatus}, $args{projectID}));
}


################################################################################################################
sub log_activity {
#
# Routine to insert an error into the activity log. This is a helper function called by the
# updateActivityLog routine.
#
#
################################################################################################################														  
    return(updateActivityLog ($_[0], $_[1], $_[2], $_[3], 'F', 0));
}


################################################################################################################
sub logActivity {
#
# Routine to insert an error into the activity log. This is a helper function called by the
# updateActivityLog routine.
#
#
################################################################################################################														  
    my %args = (
        schema => "$SCHEMA",
        userID => 0,
        logMessage => "",
        errorStatus => "F",
        projectID => 0,
        @_,
        );	
    return(updateActivityLog ($args{dbh}, $args{schema}, $args{userID}, $args{logMessage}, $args{errorStatus}, $args{projectID}));
}


################################################################################################################
sub getSysdate {
#
#      Returns the system date from the oracle database.
#
################################################################################################################

	my %args = (
		schema => "$SCHEMA",
		@_,
        );	
	my $sqlquery = "SELECT TO_CHAR(sysdate, 'MM/DD/YYYY HH:MI:SS') FROM dual";
	my $sth = $args{dbh}->prepare($sqlquery);
	$sth->execute;
	return ($sth->fetchrow_array);
}

################################################################################################################
sub updateActivityLog {
#
#     Inserts an entry into the activity log
#
#        Parameters:
#        schema      	  - database schema	
#        dbh         	  - database handle 
#        userid           - id of the user
#        logmessage       - message to be logged into the activity log
#        errorstatus      - flag to denote an error or activity
#
################################################################################################################
    my $dbh = $_[0];
    my $schema = $_[1];
    my $userId = $_[2];
    my $logmessage = $_[3];
    my $errorStatus = $_[4];
    my $projectID = ((defined($_[5]) && $_[5] > 0) ? $_[5] : 'NULL');
    my $status = 1;
    my $sqlquery = "INSERT INTO $schema.activity_log (userid, datelogged, iserror, text, project_id) "
                   . "VALUES ($userId, SYSDATE, '$errorStatus', '$logmessage', $projectID)";
    eval {
        $dbh->do($sqlquery);
    };
    if ($@) {
        if ($errorStatus eq 'F') {
            log_error($dbh, $schema, $userId, "Error writing message to activity log");
        }
        print STDERR "\nDBShared.pm/log_error - Passed Message: $logmessage\n - Error Message: \"$@\"\n";
    } else {
		$dbh->commit;
	 }
    return ($status);
}


################################################################################################################
sub formatID {
#
# Returns a formatted time (either month, day, hour, second, or minute. This is a helper function for the
# errorMesage routine.
#
################################################################################################################
   return (sprintf("$_[0]%0$_[1]d", $_[2]));
}


################################################################################################################
sub getSCRConfigItems {	
#	
# Retrieves all the configuration items for a project that are associated with completed SCR's 
# but are not in the current baseline.	
#		Named Parameters:	
#     	schema      	  - database schema	
#     	dbh         	  - database handle 
#        projectId        - id of the project the configuration items are associated with 
#
################################################################################################################

    my %args = (
    	schema => "$SCHEMA",
	@_,
    );
   my %config;
	my $sqlquery = "SELECT id FROM $args{schema}.scrrequest WHERE product = $args{projectId} "
	               . "AND status = 5";
	my $sth = $args{dbh}->prepare($sqlquery);
	$sth->execute;
	$sqlquery = "SELECT id, name, major_version, minor_version, version_date, DEVELOPER_ID, change_description, "
	  	      	. "status,  approval_date FROM $args{schema}.configuration_item, $args{schema}.item_version "
	  	      	. "WHERE scr = ? AND project_id = $args{projectId} AND id = item_id "
	  	      	. "AND (id, major_version, minor_version) NOT IN (SELECT item_id, item_major_version, item_minor_version FROM "
	  	      	. "$args{schema}.baseline_item)";
	#print "\n~~ $sqlquery";
   my $sth2 = $args{dbh}->prepare($sqlquery);
   my $i = 0;
	while (my $id = $sth->fetchrow_array) {
		$sth2->execute($id);
		while (my ($configId, $name, $majorVersion, $minorVersion, $revDate, $developerId, $desc, $status, $approvalDate) = $sth2->fetchrow_array) {
			#print "loop\n";
			$config{$configId} = {			
											'name' 		   => $name,
											'majorVersion' => $majorVersion,
											'minorVersion' => $minorVersion,
											'revDate'      => $revDate,
											'developer'    => $developerId,
											'scr'          => $id,
											'description'  => $desc,
											'status'       => $status,
											'approvalDate' => $approvalDate
								  };
		}
	}
	return (%config);
}

###############################################################################################################
sub createSequence {
#
#  Create a sequence in the database schema.
#
#     	schema      	  - database schema
#     	dbh         	  - database handle
#     	acronym          - acronym of the project
#
###############################################################################################################

	my %args = (
		schema => "$SCHEMA",
		@_,
   );
	my $sqlquery = "CREATE SEQUENCE " . uc($args{schema}) . "." . uc($args{acronym}) . "_PRODUCT_SEQ MINVALUE 1";
	$args{dbh}->do($sqlquery);
}


##############################################################################################################
sub getProjects {
#	
# Get the attributes of all projects in the system	
#	
#		Named Parameters:	
#     	schema      	  - database schema	
#     	dbh         	  - database handle
#
##############################################################################################################
	my %args = (
		schema => "$SCHEMA",
		@_,
	);
	tie my %project, "Tie::IxHash";
	my $sqlquery = "SELECT id, name, acronym, description, TO_CHAR(creation_date, 'MM/DD/YYYY'), project_manager_id, "
	               . "requirements_manager_id, configuration_manager_id, isnotes, sccbid FROM $args{schema}.project "
	               . "order by name";
	#print STDERR "\n$sqlquery\n";
   my $sth = $args{dbh}->prepare($sqlquery);
   $sth->execute;
   while (my ($id, $name, $acronym, $desc, $date, $projectManagerID, $requirementsManagerID, $configurationManagerID, $isNotes, $sccbid) = $sth->fetchrow_array) {
   	$project{$id} = {
   								'name' 		    	=> $name,
   								'acronym'       	=> $acronym,
   								'description'   	=> $desc,
   								'creationDate'  	=> $date,
   								'projectManagerID' => $projectManagerID,
   								'requirementsManagerID' => $requirementsManagerID,
   								'configurationManagerID' => $configurationManagerID,
   								'isNotes'               => $isNotes,
   								'sccbid'               => $sccbid
   						  };
   }
	return (%project);
}
##############################################################################################################
sub getProjectInfo {
#	
# Get the attributes of all projects in the system	
#	
#		Named Parameters:	
#     	schema      	  - database schema	
#     	dbh         	  - database handle
#
##############################################################################################################
	my %args = (
		schema => "$SCHEMA",
		@_,
	);
	my %project;
	my $sqlquery = "SELECT name, acronym, description, TO_CHAR(creation_date, 'MM/DD/YYYY'), project_manager_id, "
	               . "requirements_manager_id, configuration_manager_id, isnotes, sccbid FROM $args{schema}.project  "
	               . "WHERE id = $args{projectId} ";
	#print STDERR "\n$sqlquery\n";
   my $sth = $args{dbh}->prepare($sqlquery);
   $sth->execute;
   while (my ($name, $acronym, $desc, $date, $projectManagerID, $requirementsManagerID, $configurationManagerID, $isNotes, $sccbid) = $sth->fetchrow_array) {
   	$project{name} = $name;
   	$project{acronym} = $acronym;
   	$project{description} = $desc;
   	$project{creationDate} = $date;
   	$project{projectManagerID} = $projectManagerID;
   	$project{requirementsManagerID} = $requirementsManagerID;
   	$project{configurationManagerID} = $configurationManagerID;
   	$project{isNotes} = $isNotes;
   	$project{sccbid} = $sccbid;
   }
	return (%project);
}

##############################################################################################################
sub getProducts {
#	
# Get the attributes of all projects in the system	
#	
#		Named Parameters:	
#     	schema      	  - database schema	
#     	dbh         	  - database handle
#			id   	  			  - project id
#
##############################################################################################################
	my %args = (
		schema => "$SCHEMA",
		@_,
	);
	my %product;
	my $sqlquery = "SELECT id, name, MAX(major_version), MAX(minor_version) FROM $args{schema}.product, "
	               . "$args{schema}.product_version WHERE project_id = $args{Id} AND id = product_id "
	               . " GROUP BY id, name";
	#print "\n$sqlquery\n";
   my $sth = $args{dbh}->prepare($sqlquery);
   $sth->execute;
   while (my ($id, $name, $majorVersion, $minorVersion) = $sth->fetchrow_array) {
   	$product{$id} = {
   							'name' => $name,
   						  	'majorVersion' => $majorVersion,
   						  	'minorVersion' => $minorVersion
   						  };
   }
	return (%product);
}

############################################################################################################
sub getUsersByPrivilege {
#
# Get all the users associated with a specific privilege
#
#		Named Parameters:
#     	schema      	  - database schema
#     	dbh         	  - database handle
#			privilegeId      - id of the privilege to retrieve system users associated with
#
############################################################################################################
	my %args = (
		schema => "$SCHEMA",
		@_,
	);
	tie my %users, "Tie::IxHash"; 
	my $sqlquery = "SELECT a.id,  firstname || ' ' || lastname as name, username, email, areacode, phonenumber  "
						. "FROM $args{schema}.users a, $args{schema}.user_privilege b, $args{schema}.system_privilege c WHERE "
						. "c.id = $args{privilegeID} AND c.id = b.privilege AND a.id = b.userid order by lastname";
   #print "\n $sqlquery \n";
   my $sth = $args{dbh}->prepare($sqlquery);
   $sth->execute;	
	while (my ($id, $name, $username, $email, $areacode, $phone, $org) = $sth->fetchrow_array) {
		$users{$id} = { 
								'name'           => $name,
								'username'       => $username,
								'email'          => $email,
								'areacode'       => $areacode,
								'phone'     	  => $phone,
								'organization'   => $org
							};
	}
	return (%users);
}


###########################################################################################################
sub getUsers {  
#	
# Get the attributes of all users in the system	
#	
#		Named Parameters:	
#     	schema      	  - database schema	
#     	dbh         	  - database handle
#
###########################################################################################################
	my %args = (
		schema => "$SCHEMA",
		@_,
	);
	tie my %users, "Tie::IxHash";
	my $sqlquery = "SELECT id, firstname, lastname, username, email, areacode, phonenumber, extension, organization, "
						. "unixid, isactive FROM $args{schema}.users order by upper(lastname), firstname";
						
	my $sth = $args{dbh}->prepare($sqlquery);
    $sth->execute;	
	while (my ($id, $firstname, $lastname, $username, $email, $areacode, $phone, $ext, $org, 
	           $unixid, $active) = $sth->fetchrow_array) {
		$users{$id} = { 
								'firstname'      => $firstname,
								'lastname'       => $lastname,
								'username'       => $username,
								'email'          => $email,
								'areacode'       => $areacode,
								'phone'          => $phone,
								'extension'      => $ext,
								'organization'   => $org,
								'unixid'         => $unixid,
								'isactive'       => $active
						};
	}
	return (%users);
}


###############################################################################################################
sub getItemType {  
#
# Get all the defined configuration item types
#
#		Named Parameters:
#     	schema      	  - database schema
#     	dbh         	  - database handle
#
###############################################################################################################
	my %args = (
		schema => "$SCHEMA",
		@_,
	);
	my $sqlquery = "SELECT id, type FROM $args{schema}.item_type order by type";
	tie my %items, "Tie::IxHash";
	my $sth = $args{dbh}->prepare($sqlquery);
	$sth->execute;
	while (my ($id, $type) = $sth->fetchrow_array) {
		$items{$id} = $type;
	}
	return (%items);
}


################################################################################################################
################################################################################################################


################################################################################################################
sub does_user_have_priv {
# routine to see if a user of the DB system has a specific priv
################################################################################################################
    my $dbh = $_[0];
    my $schema = $_[1];
    my $userid = ((defined($_[2])) ? $_[2] : 0);
    my $priv = $_[3];
    my $test_priv = $priv;
    $test_priv =~ s/-//;
    my $privtype = "number";
    if ($test_priv =~ /\D/) {
        $privtype = "text";
    }
    my $status;
    my $sqlquery;
    my @values;
    $"=',';
    my @privs = (($#_ < 3) ? (0) : @_[3..$#_]);
    my $privlist = "(@privs)";
    $"='';

    my @privlistarray = eval ($privlist);
    if ($privtype eq "number") {
        $sqlquery = "SELECT privilege FROM $schema.user_privilege WHERE (userid = $userid) and (privilege IN $privlist)";
    } else {
        $sqlquery = "SELECT name FROM $schema.user_privilege up, $schema.system_privilege sp WHERE (up.userid = $userid) and (sp.name IN $privlist)";
    }
    my $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    $status = 0;
    while(@values = $csr->fetchrow_array) {
        $test_priv = $values[0];
        for (my $i=0; $i<=$#privlistarray; $i++) {
            if ($privtype eq "number") {
                if ($privlistarray[$i] == $test_priv) {
                    $status = 1;
                }
            } else {
                if ($privlistarray[$i] eq $test_priv) {
                    $status = 1;
                }
            }
        }
    }
    $csr->finish;
    return ($status);
}


################################################################################################################
sub doesUserHavePriv {
# routine to see if a user of the DB system has a specific priv
################################################################################################################
    my %args = (
        userid => "0",
        privList => [0],
        privList2 => [0],
        privType => "number",
        @_,
    );
    my $status;
    my $rows;
    my $arrayRef = $args{privList};
    my @privs = @$arrayRef;
    $"=',';
    my $privlist = "(@privs)";
    $"='';
    if ($args{privType} eq "number") {
        ($rows) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.user_privilege WHERE (userid = $args{userid}) and (privilege IN $privlist)");
    } else {
        ($rows) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.user_privilege up, $args{schema}.system_privilege sp WHERE (up.userid = $args{userid}) and (sp.name IN $privlist)");
    }
    $status = (($rows >0) ? 1 : 0);
    return ($status);
}


################################################################################################################
sub get_username {
# routine to get a user name
################################################################################################################
    my $dbh = $_[0];
    my $schema = $_[1];
    my $userid = $_[2];
    my $csr;
    my @values;
    my $sqlquery = "select username from $schema.users where id = $userid";
    $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    return ($values[0]);
}


################################################################################################################
sub getUserName {
# routine to get a user name
################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my ($output) = $args{dbh}->selectrow_array("SELECT username FROM $args{schema}.users WHERE id=$args{userID}");
    
    return($output);
}


################################################################################################################
sub get_fullname {
# routine to get a user's full name
################################################################################################################
    my $dbh = $_[0];
    my $schema = $_[1];
    my $userid = $_[2];
    my $csr;
    my @values;
    my $fullname;
    my $sqlquery = "select firstname, lastname from $schema.users where id = $userid";
        $csr = $dbh->prepare($sqlquery);
        $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    $fullname = $values[0] . ' ' . $values[1];
    return ($fullname);
}


###################################################################################################################################
sub getFullName {  # routine to get a user name
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my ($output) = $args{dbh}->selectrow_array("SELECT firstname || ' ' || lastname FROM $args{schema}.users WHERE id=$args{userID}");
    
    return($output);
}


################################################################################################################
sub get_lookup_values {
# routine to generate a hash of lookup/values from a table
################################################################################################################
    my $dbh = $_[0];
    my $schema = $_[1];
    my $table = $_[2];
    my $lookups = $_[3];
    my $values = $_[4];
    my $wherestatement='';      # optional
    if (defined($_[5])) {$wherestatement = $_[5];} # optional
    tie my %lookup_list, "Tie::IxHash";
    my @values;
    my $lookup;
    my $value;
    my $csr;
    my $sqlquery = "select $lookups, $values from $schema.$table";
    if ($wherestatement gt " ") {
        $sqlquery .= " where $wherestatement";
    }
    $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    while (@values = $csr->fetchrow_array) {
        ($lookup, $value) = @values;
        $lookup_list{$lookup} = $value;
    }
    $csr->finish;
    return (%lookup_list);
}


###################################################################################################################################
sub getLookupValues {
###################################################################################################################################
   my %args = (
      table => "",
      idColumn => "",
      nameColumn => "",
      orderBy => "",
      where => "",
      @_,
   );
   tie my %lookupHash, "Tie::IxHash";
   %lookupHash = ();
   my $orderBy = ($args{orderBy}) ? "ORDER BY $args{orderBy}" : "";
   my $where = ($args{where}) ? "WHERE $args{where}" : "";
   my $lookup = $args{dbh}->prepare("SELECT $args{idColumn}, $args{nameColumn} FROM $args{schema}.$args{table} $where $orderBy");
   $lookup->execute;
   while (my @values = $lookup->fetchrow_array) {
      $lookupHash{$values[0]} = $values[1];
   }
   $lookup->finish;
   return (\%lookupHash);
}

################################################################################################################
sub get_date {
# routine to generate an oracle friendly date
################################################################################################################
    my $indate = $_[0];
    my $outstring = '';
    my $day; my $month; my $year;
    my @months = ("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec");
    if (defined ($indate) && $indate gt ' ') {
        ($month, $day, $year) = split /\//, $indate;
        $month = $month -1;
    } else {
        ($day, $month, $year) = (localtime)[3,4,5];
        $year = $year + 1900;
    }
    $outstring .= "$day-$months[$month]-$year";
    return ($outstring);
}


###################################################################################################################################
sub isNotesProject {
###################################################################################################################################
   my %args = (
      project => 0,
      @_,
   );
   my ($isNotes) = $args{dbh}->selectrow_array ("SELECT isnotes FROM $args{schema}.project WHERE id = $args{project}");
   return (($isNotes eq 'T') ? 1 : 0);
}

################################################################################################################
1; #return true
