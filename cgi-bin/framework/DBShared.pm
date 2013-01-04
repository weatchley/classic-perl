#!/usr/local/bin/perl -w
#
# $Source$
# $Revision$
# $Date$
#
# $Author$
# $Locker$
#
# $Log$
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
      &db_connect          &db_disconnect       &getSysdate           
      &createSequence      &db_encrypt_password &updateActivityLog
      &doesUserHavePriv    &get_fullname        &get_date
      &getFullName         &getUserID           &getUserName
      &logError            &logActivity         &getLookupValues    
);
@EXPORT_OK = qw(
      &db_connect          &db_disconnect       &getSysdate           
      &createSequence      &db_encrypt_password &updateActivityLog
      &doesUserHavePriv    &get_fullname        &get_date
      &getFullName         &getUserID           &getUserName
      &logError            &logActivity         &getLookupValues    
);
%EXPORT_TAGS =(
    Functions => [qw(
      &db_connect          &db_disconnect       &getSysdate           
      &createSequence      &db_encrypt_password &updateActivityLog
      &doesUserHavePriv    &get_fullname        &get_date
      &getFullName         &getUserID           &getUserName
      &logError            &logActivity         &getLookupValues    
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
        type => 0,
        @_,
        );	
    return(updateActivityLog ($args{dbh}, $args{schema}, $args{userID}, $args{logMessage}, $args{errorStatus}, $args{type}));
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
        type => 0,
        @_,
        );	
    return(updateActivityLog ($args{dbh}, $args{schema}, $args{userID}, $args{logMessage}, $args{errorStatus}, $args{type}));
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
    my $type = $_[5];
    my $status = 1;
    my $sqlquery = "INSERT INTO $schema.activity_log (userid, datelogged, iserror, description, type) "
                   . "VALUES ($userId, SYSDATE, '$errorStatus', " . $dbh->quote($logmessage) . ", " . (($type != 0) ? $type : "NULL") . ")";
    eval {
        $dbh->do($sqlquery);
    };
    if ($@) {
        if ($errorStatus eq 'F') {
            logError(dbh => $dbh, schema => $schema, userID => $userId, logMessage => "Error writing message to activity log");
        }
        print STDERR "\nDBShared.pm/logError - Passed Message: $logmessage\n - Error Message: \"$@\"\n";
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


################################################################################################################
################################################################################################################


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


################################################################################################################
1; #return true
