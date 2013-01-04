# Library of UI widget routines for the DB

#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
#
#
#
package DB_Utilities_Lib;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw($DBUser $BMSConnectPath $BMSServer);
#use BMS_Header qw(:Constants);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);
use Sessions qw(:Functions);

$DBUser = $ENV{'DBUser'};
$BMSConnectPath = $ENV{'BMSConnectPath'};
$BMSServer = $ENV{'BMSServer'};
#$schema = $ENV{'SCHEMA'};

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (&db_connect &db_disconnect &validate_user &does_user_have_priv &get_userid &get_username &get_fullname
 &get_next_commentor_id &get_next_users_id &get_lookup_values &get_value
 &get_authorized_users &get_date &log_activity &log_error &db_encrypt_password &checkLogin
 &doesScannedImageFileExist &getBracketedImageFile &lastSubmittedText &validateCurrentSession);
@EXPORT_OK = qw(&db_connect &db_disconnect &validate_user &does_user_have_priv &get_userid &get_username &get_fullname
 &get_next_commentor_id &get_next_users_id &get_lookup_values &get_value
 &get_authorized_users &get_date &log_activity &log_error &db_encrypt_password &checkLogin
 &doesScannedImageFileExist &getBracketedImageFile &lastSubmittedText &validateCurrentSession);
%EXPORT_TAGS =(
    Functions => [qw(&db_connect &db_disconnect &validate_user &does_user_have_priv &get_userid &get_username &get_fullname
 &get_next_commentor_id &get_next_users_id &get_lookup_values &get_value
 &get_authorized_users &get_date &log_activity &log_error &db_encrypt_password &checkLogin
 &doesScannedImageFileExist &getBracketedImageFile &lastSubmittedText &validateCurrentSession) ]
);

#
# Contents of library:
#
# utilities
#
# 'db_connect'
# (database handle) = &db_connect( [ server => (server name) ] );
# 'db_disconnect'
# (status) = &db_disconnect( (database handle) );
# 'db_encrypt_password'
# (encrypted password) = &db_encrypt_password( (input password) );
# 'validate_user'
# (status) = &validate_user( (database handle), (schema), (username) , (password) );
#     status of 1 is a valid user
# 'does_user_have_priv'
# (status) = &does_user_have_priv( (database handle), (schema), (userid), (priv) );
# 'get_userid'
# (user id) = &get_userid ( (database handle), (schema), (username) );
# 'get_username'
# (username) = &get_username ( (database handle), (schema), (userid) );
# 'get_fullname'
# (user's full name) = &get_fullname ( (database handle), (schema), (userid) );
# 'get_next_users_id'
# (users id) = &get_next_users_id( (database handle), (schema) );
# 'get_lookup_values'
# (hash of lookups/values) = &get_lookup_values( (db handle), (schema), (table name), (lookup column name), (value column name) [, (with statement)] );
# 'get_value'
# (value) = &get_value( (db handle), (schema), (table name), (value column name), (with statement) );
#     if value not found, it returns 0
# 'get_authorized_users'
# (hash of userids/usernames) = &get_authorized_users( (db handle), (schema), (priv) );
# 'get_date'
# (oracle friendly date) = &get_date [( (date i.e. '12/31/1999') )];
#      if no date is passed in, today is used
# 'log_activity'
# (status) = &log_activity ( (db handle), (schema), (user id), (message) );
#      currently status is always 1
# 'log_error'
# (status) = &log_error ( (db handle), (schema), (user id), (message) );
#      currently status is always 1
# 'checkLogin'
# checkLogin ( (user name), (user id), (schema) );


# routine to get username/password for oracle
sub getOracleID {
    my $username = $DBUser;
    my $password;
    my $temp;
    if (open (FH, "$BMSConnectPath |")) {
        ($password, $temp) = split('//', <FH>);
        close (FH);
    } else {
        $username = "null";
        $password = "null";
    }

    return ($username, $password);
}


# routine to connect to the oracle database
sub db_connect {
    my %args = (
          server => $BMSServer,
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
        print STDERR "\nDB_Utilities_Lib.pm/db_connect - Error Message: $@\n";
    }
    return ($dbh);
}

###########

# routine to disconnect from the oracle database
sub db_disconnect {
    my $dbh = $_[0];
    my $rc;
    eval {
        $rc = $dbh->disconnect;
    };
    if ($@) {
        print STDERR "\nDB_Utilities_Lib.pm/db_disconnect - Error Message: $@\n";
    }
    return ($rc);
}

###########

# routine to encrypt a password
sub db_encrypt_password {
    my $input_password = $_[0];
    $input_password = uc($input_password);
    my $password = crypt ($input_password, "database");
    if (length($input_password)>8) {
        $password .= crypt (substr($input_password, 8), "database");
    }
    while (length($password) > 26) {
        chop ($password);
    }
    return ($password);
}

###########

# routine to validate a user of the DB system
sub validate_user {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $username = $_[2];
    my $input_password = $_[3];
    my $status;
    my $csr;
    my @values;
    my $password = &db_encrypt_password($input_password);
    $username = uc($username);
    my $sqlquery = "select password from $schema.users where (username = '$username') and (password = '$password') and (isactive = 'T')";
        $csr = $dbh->prepare ($sqlquery);
        $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    my $test_password = $values[0];
    if ($#values < 0) {
        $status = 0;
    } else {
        if ($password eq $test_password) {
            $status = 1;
        } else {
            $status = 0;
        }
    }
    return ($status);
}

###########

# routine to see if a user of the DB system has a specific priv
sub does_user_have_priv {
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
#print STDERR "**** does_user_have_priv - userid: $userid, privlist: $privlist, SQL: $sqlquery \n";
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

###########

# routine to get a user id
sub get_userid {
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

###########

# routine to get a user name
sub get_username {
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

###########

# routine to get a user's full name
sub get_fullname {
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

###########

# routine to get the next available users id
sub get_next_users_id {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $csr;
    my $status;
    my @values;
    my $users_id;
    my $sqlquery = "SELECT $schema.users_id.NEXTVAL from DUAL";
    $csr = $dbh->prepare($sqlquery);
    $status = $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    $users_id = $values[0];
    return ($users_id);
}

###########

# routine to generate a hash of lookup/values from a table
sub get_lookup_values {
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

###########

# routine to lookup a value from a table
sub get_value {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $table = $_[2];
    my $values = $_[3];
    my $wherestatement='';      # optional
    $wherestatement = $_[4];
    my %lookup_list;
    my @values;
    my $csr;
    my $value=0;
    my $sqlquery = "select $values from $schema.$table WHERE $wherestatement";
    $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    @values = $csr->fetchrow_array;
    if ($#values >= 0) {
       $value = $values[0];
    }
    $csr->finish;
    return ($value);
}

###########

# routine to generate a hash of users/names with selected priv
sub get_authorized_users {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $priv = $_[2];
    my $remove_priv=((defined($_[3])) ? $_[3] : 0);
    my @values;
    my $firstname;
    my $lastname;
    my $id;
    my $csr;
    tie my %user_list, "Tie::IxHash";
    my $sqlquery = "select users.firstname, users.lastname, users.id from $schema.users, $schema.user_privilege privs where users.id=privs.userid and privs.privilege =$priv ORDER BY users.lastname,users.firstname";
    $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    while (@values = $csr->fetchrow_array) {
       ($firstname, $lastname, $id) = @values;
       if ($id <1000) {
          $user_list{$id} = "$firstname $lastname";
       }
    }
    $csr->finish;
    # get rid of users who have the $remove_priv
    if ($remove_priv != 0) {
       my $sqlquery = "select users.firstname, users.lastname, users.id from $schema.users, $schema.user_privilege privs where users.id=privs.userid and privs.privilege =$remove_priv ORDER BY users.lastname,users.firstname";
       $csr = $dbh->prepare($sqlquery);
       $csr->execute;
       while (@values = $csr->fetchrow_array) {
          ($firstname, $lastname, $id) = @values;
          delete $user_list{$id};
       }
       $csr->finish;
    }
    return (%user_list);
}

###########

# routine to generate an oracle friendly date
sub get_date {
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

###########

# routine to insert a message into the activity log
sub log_activity {
    return(updateActivityLog ($_[0], $_[1], $_[2], $_[3], 'F'));
}

###########

# routine to insert an error into the activity log
sub log_error {
    return(updateActivityLog ($_[0], $_[1], $_[2], $_[3], 'T'));
}

###########

# routine to insert message into the activity log
sub updateActivityLog {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $userid = $_[2];
    my $logmessage = $_[3];
    my $errorStatus = $_[4];
    my $status = 1;
    my $logdate = &get_date();
    my $sqlquery = "INSERT INTO $schema.activity_log (userid, datelogged, iserror, description) VALUES ($userid, SYSDATE, '$errorStatus', '$logmessage')";
    eval {
        $dbh->do($sqlquery);
        $dbh->commit;
    };
    if ($@) {
        if ($errorStatus eq 'F') {
            log_error($dbh,$schema,$userid, "Error writing message to activity log");
        }
        print STDERR "\nDB_Utilities_Lib.pm/log_error - Passed Message: $logmessage\n - Error Message: \"$@\"\n";
    }
    return ($status);
}

###########

#redirect user to login screen if username, userid, or schema are not defined (i.e. user hasn't logged in)
sub checkLogin {
   my ($username, $userid, $schema) = @_;
   my $script = 'login';
   if (!defined($username) || !defined($userid) || !defined($schema)) {
      $ENV{SCRIPT_NAME} =~ m%^(.*/)%;
      print "Location: $1$script.pl\n\n";
      exit;
   }
}


###################################################################################################################################
sub validateCurrentSession {              #redirect user to login screen if session is timed out or not valid.
###################################################################################################################################
    my %args = (
          userID => '',
          dbh => '',
          schema => '',
          sessionID => 'none',
          @_,
          );
    
    my $status;
    if ($ENV{BMSUseSessions} == 1) {
        $status = &sessionValidate(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID}, sessionID=>$args{sessionID});
        if ($status == 1) {
            return ($status);
        } else {
            print "content-type: text/html\n\n";
            print "<html><header></header><body>\n";
            print "<form name=timeout action=login.pl target=_top method=post>\n";
            print "<input type=hidden name=test value=test>\n</form>\n";
            print "<script language=javascript>\n<!--\n";
            print "alert('Session has timed out or is not valid');\n";
            print "document.timeout.submit();\n";
            print "//-->\n</script>\n";
        }
    }
}


###########


1; #return true
