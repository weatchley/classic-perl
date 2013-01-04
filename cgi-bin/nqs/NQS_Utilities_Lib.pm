#!/usr/local/bin/newperl -w 
#
# $Source: /data/dev/rcs/nqs/perl/RCS/NQS_Utilities_Lib.pm,v $
#
# $Revision: 1.4 $
#
# $Date: 2002/03/28 22:54:30 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: NQS_Utilities_Lib.pm,v $
# Revision 1.4  2002/03/28 22:54:30  starkeyj
# added functionto retrieve trend user privileges (SCR 23)
#
# Revision 1.3  2001/12/03 22:35:49  starkeyj
# modified validate_org function to remove print SQL statement
#
# Revision 1.2  2001/11/20 14:54:32  starkeyj
# added functions for form verification of trend documents
#
# Revision 1.1  2001/07/26 15:42:41  starkeyj
# Initial revision
#
# Revision 1.1  2001/07/03 15:38:05  starkeyj
# Initial revision
#
#

package NQS_Utilities_Lib;
use strict;
use Carp;
use Time::Local;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw($DBUser $NQSConnectPath $NQSServer $SCHEMA $NQSCGIDir);
#use TEST_Header qw(:Constants);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

$DBUser = $ENV{'DBUser'};
$NQSConnectPath = $ENV{'NQSConnectPath'};
$NQSServer = $ENV{'NQSServer'};
$SCHEMA = $ENV{'SCHEMA'};

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (&trend_connect &trend_disconnect &get_userid &get_value &validate_cause_and_group
 &get_next_surveillance_request_id &get_next_users_id &get_lookup_values &validate_code_and_element
 &get_date &log_trend_activity &trend_encrypt_password &get_max_id &validate_supplier &get_userpriv
 &log_trend_error &lookup_single_value &lookup_column_values &get_next_value &validate_HW
 &get_next_surveillance_id &validate_trend_user &lpadzero &validate_org &validate_HW_proc);
@EXPORT_OK = qw(&trend_connect &trend_disconnect &get_userid &get_value &validate_cause_and_group
 &get_next_surveillance_request_id &get_next_users_id &get_lookup_values &validate_code_and_element
 &get_date &log_trend_activity &trend_encrypt_password &get_max_id &validate_supplier &get_userpriv
 &log_trend_error &lookup_single_value &lookup_column_values &get_next_value &validate_HW
 &get_next_surveillance_id &validate_trend_user &lpadzero &validate_org &validate_HW_proc);
%EXPORT_TAGS =(
    Functions => [qw(&trend_connect &trend_disconnect &get_userid &get_value &validate_cause_and_group
 &get_next_surveillance_request_id &get_next_users_id &get_lookup_values &validate_code_and_element
 &get_date &log_trend_activity &trend_encrypt_password &get_max_id &validate_supplier &get_userpriv
 &log_trend_error &lookup_single_value &lookup_column_values &get_next_value &validate_HW
 &get_next_surveillance_id &validate_trend_user &lpadzero &validate_org &validate_HW_proc) ]
);

#
# Contents of library:
#
# utilities
#
# 'log_trend_activity'
# (log activity) = &log_trend_activity( ($dbh), ($SCHEMA), ($iserror), ($userid), ($description) );
# 'log_trend_error'
# (log error) = &log_trend_error( ($dbh), ($SCHEMA), ($iserror), ($userid), ($description) );
# 'lpadzero'
# (outstring) = &lpadzero ( (instring), (strlength) );
# 'trend_connect'
# (database handle) = &trend_connect;
# 'trend_disconnect'
# (status) = &trend_disconnect( (database handle) );
# 'trend_encrypt_password'
# (encrypted password) = &trend_encrypt_password( (input password) );
# 'validate_trend_user'
# (status) = &validate_trend_user( (database handle), (schema), (username) , (password) );
#     status of 1 is a valid user
# 'validate_supplier'
# (status) = &validate_supplier( (database handle), (schema), (supplier) );
#     status of 1 is a valid supplier
# 'get_userid'
# (user id) = &get_userid ( (database handle), (username) );
# 'get_next_surveillance_request_id'
# (request id) = &get_next_surveillance_request_id( (database handle), (schema) );
# 'get_next_surveillance_id'
# (surveillance id) = &get_next_surveillance_id( (database handle), (schema) );
# 'get_next_users_id'
# (users id) = &get_next_users_id( (database handle) );
# 'get_lookup_values'
# (hash of lookups/values) = &get_lookup_values( (db handle), (table name), (lookup column name), (value column name) [, (with statement)] );
# 'get_date'
# (oracle friendly date) = &get_date [( (date i.e. '12/31/1999') )];
#      if no date is passed in, today is used
# 'lookup_single_value'
# (value) = &lookup_single_value( (db handle), (table), (column), (lookupid) );
# 'lookup_column_values'
# (value array) = &lookup_column_values( (db handle), (table), (column), (wherestatement) (orderbystatement) );
# 'get_value'
# (value) = &get_value( (db handle), (schema), (table name), (value column name), (with statement) );
#     if value not found, it returns 0
# 'get_max_id'
# ($scalar number) = &get_max_id( (database handle), (tablename), (fieldname) )
#       assumes id is not the field name for the id (yes, it happens) 
# 'get_next_value'
# ($scalar number) = &get_next_value( (database handle), (tablename), (fieldname), (fieldname), (value) )
#       returns the max value in a table where there the max value depends on another field
#    
###########
###########
#
###########
###########
# routine to get username/password for oracle
sub getOracleID {
    my $username = $DBUser;
    my $password;
    my $temp;
    if (open (FH, "$NQSConnectPath |")) {
        ($password, $temp) = split('//', <FH>);
        close (FH);
    } else {
        $username = "null";
        $password = "null";
    }

    return ($username, $password);
}


# routine to connect to the oracle database
sub trend_connect {
    my %args = (
          server => $NQSServer,
          @_,
          );
    my $dbh;
    my $username;
    my $password;
    ($username, $password) = getOracleID;

    eval {
            $dbh = DBI->connect("dbi:Oracle:$args{server}",$username, $password, { RaiseError => 1, AutoCommit => 0 });
    };
    if ($@) {
        print STDERR "\nNQS_Utilities_Lib.pm/trend_connect - Error Message: $@\n";
    }
    return ($dbh);
}

#########################

# routine to generate a hash of lookup/values from a table
sub get_max_id {
    my $dbh = $_[0];
    my $table = $_[1];
    my $field = $_[2];

# generate query
# make sql statement
    my $sqlquery = "SELECT max($field) FROM $SCHEMA.$table";
 
# generate a 'cursor'
    my $csr = $dbh->prepare($sqlquery);
# execute or run the query
    $csr->execute;

  # max will return 1 row with 1 column which holds the largest value
   my @maxid=$csr->fetchrow_array;

# free up the generated 'cursor'
    $csr->finish;

  return ($maxid[0]);
  
}

###########

# routine to get the next value
sub get_next_value {
    my $dbh = $_[0];
    my $SCHEMA = $_[1];
    my $table = $_[2];
    my $field = $_[3];
    my $field2 = $_[4];
    my $value = $_[5];


# generate query
# make sql statement
    my $sqlquery = "SELECT max($field) FROM $SCHEMA.$table where $field2 = $value";
 
# generate a 'cursor'
    my $csr = $dbh->prepare($sqlquery);
# execute or run the query
    $csr->execute;

  # max will return 1 row with 1 column which holds the largest value
   my @maxid=$csr->fetchrow_array;

# free up the generated 'cursor'
    $csr->finish;

  return ($maxid[0]);
  
}

###########

# routine to connect to the oracle database
sub trend_connect_old {

   #my $dbh = DBI->connect("dbi:Oracle:$NQSServer",$DBUser,$DBPassword);
  # my $dbh = DBI->connect("dbi:Oracle:$DDTServer",);

    #return ($dbh);
}

###########

# routine to disconnect from the oracle database
sub trend_disconnect {
    my $dbh = $_[0];

    my $rc = $dbh->disconnect;

    return ($rc);
}

###########

# routine to Encrypt a password
sub trend_encrypt_password {
    my $input_password = $_[0];

    $input_password = uc($input_password);
    my $password = crypt ($input_password, "Trend");
    if (length($input_password)>8) {
        $password .= crypt (substr($input_password, 8), "Trend");
    }

    while (length($password) > 25) {
        chop ($password);
    }

    return ($password);
}

###########

# routine to validate a user of the DB system
sub validate_supplier {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $supplier = $_[2];
    my $csr;
    my $sqlquery;
    my @values;
    my $status;
    
    $sqlquery = "select count(*) from $schema.supplier where abbrev = '$supplier' ";
    
    #print "<br>** $sqlquery ** <br>\n";
    $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    my $count = $values[0];
    if ($#values < 0 | $count == 0) {
        $status = 0;
    } 
    else {
	 	$status = 1;
    }
        
    return ($status);
}
###########

# routine to validate a user of the DB system
sub validate_code_and_element {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $codeandelement = $_[2];
    my $csr;
    my $sqlquery;
    my @values;
    my $status;
    
    $sqlquery = "select count(*) from $schema.t_code where element || code = $codeandelement ";
    
    #print "<br>** $sqlquery ** <br>\n";
    $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    my $count = $values[0];
    if ($#values < 0 | $count == 0) {
        $status = 0;
    } 
    else {
	 	$status = 1;
    }
        
    return ($status);
}
###########

# routine to validate a user of the DB system
sub validate_cause_and_group {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $cause = $_[2];
    my $group = $_[3];
    my $csr;
    my $sqlquery;
    my @values;
    my $status;
    
    $sqlquery = "select count(*) from $schema.t_cause where cause_group = $group and cause = '$cause' ";
	 #print STDERR "\n** $sqlquery ** \n";
    #print "** $sqlquery ** <br>\n";
    $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    my $count = $values[0];
    if ($#values < 0 | $count == 0) {
        $status = 0;
    } 
    else {
	 	$status = 1;
    }
        
    return ($status);
}
###########

# routine to validate a user of the DB system
sub validate_HW {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $hw = $_[2];
    my $csr;
    my $sqlquery;
    my @values;
    my $status;
    
    $sqlquery = "select count(*) from $schema.t_hardware where hardware = '$hw' ";
    
    #print "<br>** $sqlquery ** <br>\n";
    $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    my $count = $values[0];
    if ($#values < 0 | $count == 0) {
        $status = 0;
    } 
    else {
	$status = 1;
    }
        
    return ($status);
}###########

# routine to validate a user of the DB system
sub validate_HW_proc {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $hw_proc = $_[2];
    my $csr;
    my $sqlquery;
    my @values;
    my $status;
    
    $sqlquery = "select count(*) from $schema.t_hw_process where process = '$hw_proc' ";
    
    #print "<br>** $sqlquery ** <br>\n";
    $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    my $count = $values[0];
    if ($#values < 0 | $count == 0) {
        $status = 0;
    } 
    else {
	$status = 1;
    }
        
    return ($status);
}
###########

# routine to validate a user of the DB system
sub validate_org {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $org = $_[2];
    my $csr;
    my $sqlquery;
    my @values;
    my $status;
    
    $sqlquery = "select count(*) from $schema.organization where organization = '$org' ";
    
    #print "<br>** $sqlquery ** <br>\n";
    $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    my $count = $values[0];
    if ($#values < 0 | $count == 0) {
        $status = 0;
    } 
    else {
	$status = 1;
    }
        
    return ($status);
}


###########

# routine to validate a user of the TREND system
sub validate_trend_user {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $username = $_[2];
    my $input_password = $_[3];

    my $status;
    my $password = &trend_encrypt_password($input_password);
    $username = uc($username);

    if (($username eq "GUEST") && (uc($input_password) eq "GUEST"))
      {
      $status = 0;
      return ($status);
      }

    my $sqlquery = "select password from $schema.t_user where username = '$username' and password = '$password' and privilege != 'Inactive'";
    #print STDERR "$sqlquery\n";
    my $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    my @values = $csr->fetchrow_array;
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

# routine to get a user id
sub get_userid {
    my $dbh = $_[0];
    my $username = $_[1];

    $username = uc($username);

    my $sqlquery = "select id from $SCHEMA.t_user where username = '$username'";
    #print STDERR "\n $sqlquery \n";
    my $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    my @values = $csr->fetchrow_array;

    # free up the generated 'cursor'
    $csr->finish;


    return ($values[0]);
}

###########

# routine to get a user id
sub get_userpriv {
    my $dbh = $_[0];
    my $username = $_[1];

    $username = uc($username);

    my $sqlquery = "select privilege from $SCHEMA.t_user where username = '$username'";
   # print STDERR "\n $sqlquery \n";
    my $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    my @values = $csr->fetchrow_array;

    # free up the generated 'cursor'
    $csr->finish;


    return ($values[0]);
}


###########

# routine to get the next available surveillance request id
sub get_next_surveillance_request_id {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $csr;
    my $status;
    my @values;
    my $request_id;
    my $sqlquery = "SELECT $schema.surveillance_request_seq.NEXTVAL from DUAL";
    $csr = $dbh->prepare($sqlquery);
    $status = $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    $request_id = $values[0];
    
    return ($request_id);
}

###########

# routine to get the next available surveillance id
sub get_next_surveillance_id {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $csr;
    my $status;
    my @values;
    my $request_id;
    my $sqlquery = "SELECT $schema.surveillance_seq.NEXTVAL from DUAL";
    $csr = $dbh->prepare($sqlquery);
    $status = $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    $request_id = $values[0];
    
    return ($request_id);
}

###########

# routine to get the next available users id
sub get_next_users_id {
    my $dbh = $_[0];

    my $users_id;
    my $csr = $dbh->prepare(qq{
        BEGIN
            $SCHEMA.get_next_users_id (:uid);
        END;
      });

    $csr->bind_param_inout(":uid", \$users_id, 5);
    $csr->execute;
    # free up the generated 'cursor'
    $csr->finish;

    return ($users_id);
}

###########

# routine to generate a hash of lookup/values from a table
sub get_lookup_values {
    my $dbh = $_[0];
    my $table = $_[1];
    my $lookups = $_[2];
    my $values = $_[3];
    my $wherestatement = ($_[4]) ? $_[4] : "";     # optional

    tie my %lookup_list, "Tie::IxHash";
    #my %lookup_list;
    my @values;
    my $lookup;
    my $value;

# generate query
# make sql statement
    my $sqlquery = "SELECT $lookups, $values FROM $SCHEMA.$table";
    if ($wherestatement gt " ") {
        $sqlquery .= " WHERE $wherestatement";
#    $sqlquery .= " ORDER BY $values";
    }
#    print "<!-- $sqlquery -->\n";
# generate a 'cursor'
    my $csr = $dbh->prepare($sqlquery);
# execute or run the query
    $csr->execute;

    while (@values = $csr->fetchrow_array) {
        ($lookup, $value) = @values;
        $lookup_list{$lookup} = $value;
    }

# free up the generated 'cursor'
    $csr->finish;

    return (%lookup_list);
}

###########

# routine to generate an oracle friendly date
sub get_date {
    my $indate = $_[0];

    my $outstring = '';
    my $day; my $month; my $year;
    my @months = ("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec");

    if ($indate gt ' ') {
        ($month, $day, $year) = split /\//, $indate;
        $month = $month -1;
    } else {
        ($day, $month, $year) = (localtime)[3,4,5];
        $year = $year + 1900;
    }

    $outstring .= "$day-$months[$month]-$year";

    return ($outstring);
}

############
# routine to insert an entry into the trend analysis activity log
sub log_trend_activity {
    my ($dbh, $schema, $iserror, $userid, $description) = @_;
    my ($sql, $sth);
#print STDERR "INSERT INTO $schema.t_activity_log (USERID, DATELOGGED, ISERROR, DESCRIPTION) VALUES ($userid, SYSDATE, '$iserror','$description')";
    $dbh->do("INSERT INTO $schema.t_activity_log (USERID, DATELOGGED, ISERROR, DESCRIPTION) VALUES ($userid, SYSDATE, '$iserror','$description')");
}

############
# routine to insert an error entry into the trend analysis error log
sub log_trend_error {

    my ($dbh, $schema, $iserror, $userid, $description) = @_;
    my ($sql, $sth);
#print STDERR "INSERT INTO $schema.t_error_log (USERID, DATELOGGED, ISERROR, DESCRIPTION) VALUES ($userid, SYSDATE, '$iserror','$description')";
    $dbh->do("INSERT INTO $schema.t_error_log (USERID, DATELOGGED, ISERROR, DESCRIPTION) VALUES ($userid, SYSDATE, '$iserror','$description')");
}
###########

sub lookup_single_value
  {
  # This sub executes a SELECT which returns a single column value (or
  # concatentation of column values) (cell) from a single table with the given
  # ID, primarily for lookup tables, but can be used for others.
  # If the lookupid is a string, the calling procedure must include the needed
  # single quotes.
  my $dbh = $_[0];
  my $schema = $_[1];
  my $tablename = $_[2];
  my $column = $_[3];
  my $lookupid = $_[4];

  my $sqlquery = "SELECT $column
                  FROM $schema.$tablename
                  WHERE " . $tablename . " . id = $lookupid";
  print "$sqlquery<br>\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;

  # should return 1 row with 1 column which will hold the requested value
  my @results = $csr->fetchrow_array;

  my $rc = $csr->finish;

  return ($results[0]);
  }

###########

sub lookup_column_values
  {
  # This sub executes a SELECT which returns rows of a column (or concatentation of columns)
  # from a single table with the given where statement.
  my $dbh = $_[0];
  my $tablename = $_[1];
  my $column = $_[2];
  my $wherestatement = $_[3];
  my $orderbystatement = $_[4];

  my @valuearray;
  my $arrayindex = 0;

  my $sqlquery = "SELECT $column
                  FROM $SCHEMA.$tablename";
  if ($wherestatement ne "")
    {
    $sqlquery .= " WHERE $wherestatement";
    }
  if ($orderbystatement ne "")
    {
    $sqlquery .= " ORDER BY $orderbystatement";
    }
  print "\n\n<!-- $sqlquery -->\n\n";
  my $csr = $dbh->prepare($sqlquery);
  my $rv = $csr->execute;


  # should return 1 column which will hold the requested values
  while (my @results = $csr->fetchrow_array)
    {
    $valuearray[$arrayindex++] = $results[0];
    }

  my $rc = $csr->finish;

  return (@valuearray);
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

############################

# routine to left pad a string with zeros
sub lpadzero {
    my $instring = $_[0];
    my $strlength = $_[1];

    my $outstring = "";

    for (my $i=1; $i <= ($strlength - length($instring)); $i++) {
        $outstring .= "0";
    }
    $outstring .= $instring;
    return ($outstring);
}

