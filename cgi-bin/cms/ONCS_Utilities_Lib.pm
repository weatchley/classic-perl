# Library of utilities routines for the ONCS
#
# $Source: /data/dev/rcs/cms/perl/RCS/ONCS_Utilities_Lib.pm,v $
# $Revision: 1.22 $
# $Date: 2002/04/12 23:48:12 $
# $Author: naydenoa $
# $Locker:  $
# $Log: ONCS_Utilities_Lib.pm,v $
# Revision 1.22  2002/04/12 23:48:12  naydenoa
# Checkpoint
#
# Revision 1.21  2002/02/06 18:35:29  naydenoa
# Temporary suppression of email notification function.
#
# Revision 1.20  2001/11/30 18:10:17  naydenoa
# Fixed email notification message.
# ,
#
# Revision 1.19  2001/11/30 17:52:13  naydenoa
# Updated Lynn's contact information - new phone number, added email
#
# Revision 1.18  2001/11/15 23:16:01  naydenoa
# Updated commitment retriaval to include new leads and managers.
#
# Revision 1.17  2001/05/31 16:33:13  naydenoa
# Changed Lynn Weishaar's contact number on the email notification
#
# Revision 1.16  2001/05/11 21:49:29  naydenoa
# Added sub for role lookup
#
# Revision 1.15  2001/05/08 17:15:00  naydenoa
# Added commit in log_activity function.
#
# Revision 1.14  2001/04/03 21:45:37  naydenoa
# Changed email notification - direct questions to Lynn Weishaar
# instead of Sheryl Morris.
#
# Revision 1.13  2000/12/07 00:23:46  atchleyb
# Updated to allow for a dev oracle server
#
# Revision 1.12  2000/11/07 00:42:49  atchleyb
# updated the notify user function to test if a user is active
#
# Revision 1.11  2000/11/06 22:59:58  atchleyb
# changed message for cms user notify
#
# Revision 1.10  2000/11/03 17:43:58  atchleyb
# added use Mail_Utlities_Lib
# added the notifyUser routine to send a message (only one per day) to a user
#
# Revision 1.9  2000/10/17 23:38:50  munroeb
# renamed formatID to formatID2 to prevent conflict
#
# Revision 1.8  2000/10/17 22:50:41  munroeb
# added formatID function
#
# Revision 1.7  2000/10/17 16:24:52  munroeb
# removed log_history function
#
# Revision 1.6  2000/10/16 21:26:29  munroeb
# added log_activity function
#
# Revision 1.5  2000/10/05 17:13:56  atchleyb
# removed some dead code (log_activity)
#
# Revision 1.4  2000/09/28 19:58:31  atchleyb
# fixed insert with column names
#
# Revision 1.3  2000/05/24 23:07:30  zepedaj
# Fixed does_user_have_named_priv and does_user_have_prived routines
#
# Revision 1.2  2000/05/12 23:38:18  atchleyb
# Added get_fullname and get_value
# minor bug fixes
#
# Revision 1.1  2000/04/11 23:42:01  zepedaj
# Initial revision
#
#

package ONCS_Utilities_Lib;
use strict;
use Carp;
use Time::Local;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw($ONCSUser $ONCSPassword $SCHEMA);
use ONCS_Header qw(:Constants);
use Mail_Utilities_Lib;

use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (       &oncs_connect                 &oncs_disconnect     
                     &validate_user                &does_user_have_priv 
                     &get_user_privs               &get_userid 
                     &get_next_comment_number      &get_next_commentor_id 
                     &get_next_preapproved_text_id &get_next_summary_comment_id
                     &get_next_users_id            &get_lookup_values
                     &get_authorized_users         &get_assigned_users 
                     &get_date                     &log_activity 
                     &oncs_encrypt_password        &does_user_have_named_priv
                     &get_formatted_date           &lookup_single_value 
                     &lookup_column_values         &get_fullname 
                     &get_value                    &formatID2 
                     &notifyUser                   &does_user_have_role);
@EXPORT_OK = qw(     &oncs_connect                 &oncs_disconnect 
                     &validate_user                &does_user_have_priv 
                     &get_user_privs               &get_userid 
                     &get_next_comment_number      &get_next_commentor_id 
                     &get_next_preapproved_text_id &get_next_summary_comment_id
                     &get_next_users_id            &get_lookup_values
                     &get_authorized_users         &get_assigned_users 
                     &get_date                     &log_activity 
                     &oncs_encrypt_password        &does_user_have_named_priv
                     &get_formatted_date           &lookup_single_value 
                     &lookup_column_values         &get_fullname 
                     &get_value                    &formatID2 
                     &notifyUser                   &does_user_have_role);
%EXPORT_TAGS =(
    Functions => [qw(&oncs_connect                 &oncs_disconnect 
                     &validate_user                &does_user_have_priv 
                     &get_user_privs               &get_userid 
                     &get_next_comment_number      &get_next_commentor_id 
                     &get_next_preapproved_text_id &get_next_summary_comment_id
                     &get_next_users_id            &get_lookup_values
                     &get_authorized_users         &get_assigned_users 
                     &get_date                     &log_activity 
                     &oncs_encrypt_password        &does_user_have_named_priv
                     &get_formatted_date           &lookup_single_value 
                     &lookup_column_values         &get_fullname 
                     &get_value                    &formatID2 
                     &notifyUser                   &does_user_have_role) ]
);

#
# Contents of library:
#
# utilities
#
# 'oncs_connect'
# (database handle) = &oncs_connect;
# 'oncs_disconnect'
# (status) = &oncs_disconnect( (database handle) );
# 'oncs_encrypt_password'
# (encrypted password) = &oncs_encrypt_password( (input password) );
# 'validate_user'
# (status) = &validate_user( (database handle), (username) , (password) );
#     status of 1 is a valid user
# 'does_user_have_priv'
# (status) = &does_user_have_priv( (database handle), (userid), (priv) );
# 'get_user_privs'
# (array of privs) = &get_user_privs( (database handle), (userid) );
# 'get_userid'
# (user id) = &get_userid ( (database handle), (username) );
# 'get_next_comment_number'
# (comment number ) = &get_next_comment_number( (document number), (database handle) );
# 'get_next_commentor_id'
# (commentor id) = &get_next_commentor_id( (database handle) );
# 'get_next_preapproved_text_id'
# (preapproved text id) = &get_next_preapproved_text_id( (database handle) );
# 'get_next_summary_comment_id'
# (summary comment id) = &get_next_summary_comment_id( (database handle) );
# 'get_next_users_id'
# (users id) = &get_next_users_id( (database handle) );
# 'get_lookup_values'
# (hash of lookups/values) = &get_lookup_values( (db handle), (table name), (lookup column name), (value column name) [, (with statement)] );
# 'get_authorized_users'
# (hash of userids/usernames) = &get_authorized_users( (priv), (db handle) );
# 'get_assigned_users'
#      needs to be rethought
# 'get_date'
# (oracle friendly date) = &get_date [( (date i.e. '12/31/1999') )];
#      if no date is passed in, today is used
# 'log_activity'
# (status) = &log_activity ( (db handle), (user id), (message) );
#      currently status is always 1
# 'get_user_info'
# (user hash) = &get_user_info( (db handle), (usersid) );
# 'get_user_names_and_ids'
# (user hash) = &get_user_names_and_ids( (db handle) );
# 'does_user_have_named_priv'
# (status) = &does_user_have_named_priv( (db handle), (user id), (privilege name) );
# 'get_formatted_date'
# (formatted date string) = &get_formatted_date ( (format string), (date i.e. '12/31/1999') );
#        if no date is passed in, today is used
# 'lookup_single_value'
# (value) = &lookup_single_value( (db handle), (table), (column), (lookupid) );
# 'lookup_column_values'
# (value array) = &lookup_column_values( (db handle), (table), (column), (wherestatement) (orderbystatement) );
# 'get_fullname'
# (user's full name) = &get_fullname ( (database handle), (schema), (userid) );
# 'get_value'
# (value) = &get_value( (db handle), (schema), (table name), (value column name), (with statement) );
#     if value not found, it returns 0
#
# 'notifyUser'
# ($status) = &notifyUser( dbh => (db handle), schema => (schema), userID => (user id) [, message => ('message')] )
#     returns 1 if successful, and a negative number if not
# 'does_user_have_role'
# (status) = &does_user_have_role( dbh => (db handle), uid => (userid), rid => (roleid) );
#

###########
#
###########

# routine to connect to the oracle database
##################
sub oncs_connect {
##################
    my $dbh = DBI->connect("dbi:Oracle:$CMSServer", $ONCSUser, $ONCSPassword, { RaiseError => 1, AutoCommit => 0 });
    return ($dbh);
}

# routine to disconnect from the oracle database
#####################
sub oncs_disconnect {
#####################
    my $dbh = $_[0];
    my $rc = $dbh->disconnect;
    return ($rc);
}

# routine to Encrypt a password
###########################
sub oncs_encrypt_password {
###########################
    my $input_password = $_[0];

    $input_password = uc($input_password);
    my $password = crypt ($input_password, "ONCS");
    if (length($input_password)>8) {
        $password .= crypt (substr($input_password, 8), "ONCS");
    }

    while (length($password) > 25) {
        chop ($password);
    }

    return ($password);
}

# routine to validate a user of the ONCS system
###################
sub validate_user {
###################
    my $dbh = $_[0];
    my $username = $_[1];
    my $input_password = $_[2];

    my $status;
    my $password = &oncs_encrypt_password($input_password);
    $username = uc($username);

    if (($username eq "GUEST") && (uc($input_password) eq "GUEST")) {
        $status = 2;
        return ($status);
    }
    my $sqlquery = "select password from $SCHEMA.users where (username = '$username') and (password = '$password') and (isactive = 'T')";
    my $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    my @values = $csr->fetchrow_array;
    $csr->finish;

    my $test_password = $values[0];
    if ($#values < 0) {
        $status = 0;
    } 
    else {
        if ($password eq $test_password) {
            $status = 1;
        } 
        else {
            $status = 0;
        }
    }

#    my $csr = $dbh->prepare(qq{
#        BEGIN
#            $SCHEMA.validate_user (:user, :pass);
#        END;
#      });
#
#    $csr->bind_param(":user", $username);
#    $csr->bind_param(":pass", $password);
#    $csr->bind_param_inout(":stat", \$status, 5);
#    $csr->execute;
#    # free up the generated 'cursor'
#    $csr->finish;

#$status =1;
    return ($status);
}

# routine to see if a user of the ONCS system has a specific named priv
###############################
sub does_user_have_named_priv {
###############################
  my $dbh = $_[0];
  my $userid = $_[1];
  my $namedpriv = uc($_[2]);

  my $status;

  my $sqlquery = "SELECT privilegeid FROM $SCHEMA.privilege where UPPER(description) = '$namedpriv'";
  print "\n<!-- $sqlquery -->\n\n";
  my $csr = $dbh->prepare($sqlquery);
  $csr->execute;
  my @results = $csr->fetchrow_array;
  $csr->finish;

  my $test_priv = $results[0];
  if ((!defined($test_priv)) || ($test_priv eq '')) {
      $status = 0;
  }
  else {
      $status = does_user_have_priv($dbh, $userid, $test_priv);
  }
  return ($status);
}

# routine to see if a user of the ONCS system has a specific priv
#########################
sub does_user_have_priv {
#########################
    my $dbh = $_[0];
    my $userid = $_[1];
    my $priv = $_[2];

    my $status;

    my $sqlquery = "select privilegeid from $SCHEMA.userprivilege where (usersid = $userid) and (privilegeid = $priv)";
    print "\n<!-- $sqlquery -->\n\n";
    my $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    my @values = $csr->fetchrow_array;
    $csr->finish;

    my $test_priv = $values[0];
    if ((!defined($test_priv)) || ($test_priv eq '')) {
        $status = 0;
    } 
    else {
        if ($priv == $test_priv) {
            $status = 1;
        } 
        else {
            $status = 0;
        }
    }
    return ($status);
}

# routine to get the privs for a user of the ONCS system
####################
sub get_user_privs {
####################
    my $dbh = $_[0];
    my $userid = $_[1];

    my @privs;
    my @values;
    $values[0] = 'F';
    my $sqlquery = "select id from $SCHEMA.system_privilege";
    my $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    while (@values = $csr->fetchrow_array) {
        $privs[$values[0]] = 'F';
    }
    $sqlquery = "select privilege from $SCHEMA.user_privilege where (userid = $userid)";
    $csr = $dbh->prepare ($sqlquery);
    $csr->execute;
    while (@values = $csr->fetchrow_array) {
        $privs[$values[0]] = 'T';
    }
    $csr->finish;
    return (@privs);
}

# routine to get a user id
################
sub get_userid {
################
    my $dbh = $_[0];
    my $username = $_[1];

    $username = uc($username);

    my $sqlquery = "select usersid from $SCHEMA.users where username = '$username'";
    my $csr = $dbh->prepare($sqlquery);
    $csr->execute;
    my @values = $csr->fetchrow_array;

    # free up the generated 'cursor'
    $csr->finish;
    return ($values[0]);
}

# routine to get the next available comment number for a comment document
#############################
sub get_next_comment_number {
#############################
    my $cd = $_[0];
    my $dbh = $_[1];

    my $comment_number;
    my $csr = $dbh->prepare(qq{
        BEGIN
            $SCHEMA.get_next_comment_number (:cd, :cnum);
        END;
      });
    $csr->bind_param(":cd", $cd);
    $csr->bind_param_inout(":cnum", \$comment_number, 5);
    $csr->execute;
    # free up the generated 'cursor'
    $csr->finish;

#    $comment_number = 1;

    return ($comment_number);
}

# routine to get the next available commentor id
###########################
sub get_next_commentor_id {
###########################
    my $dbh = $_[0];

    my $commentor_id;
    my $csr = $dbh->prepare(qq{
        BEGIN
            $SCHEMA.get_next_commentor_id (:cid);
        END;
      });
    $csr->bind_param_inout(":cid", \$commentor_id, 5);
    $csr->execute;
    # free up the generated 'cursor'
    $csr->finish;
    return ($commentor_id);
}

# routine to get the next available preapproved_text id
##################################
sub get_next_preapproved_text_id {
##################################
    my $dbh = $_[0];

    my $preapproved_text_id;
    my $csr = $dbh->prepare(qq{
        BEGIN
            $SCHEMA.get_next_preapproved_text_id (:ptid);
        END;
      });
    $csr->bind_param_inout(":ptid", \$preapproved_text_id, 5);
    $csr->execute;
    $csr->finish;
    return ($preapproved_text_id);
}

# routine to get the next available summary_comment id
#################################
sub get_next_summary_comment_id {
#################################
    my $dbh = $_[0];

    my $summary_comment_id;
    my $csr = $dbh->prepare(qq{
        BEGIN
            $SCHEMA.get_next_summary_comment_id (:scid);
        END;
      });
    $csr->bind_param_inout(":scid", \$summary_comment_id, 5);
    $csr->execute;
    $csr->finish;
    return ($summary_comment_id);
}

# routine to get the next available users id
#######################
sub get_next_users_id {
#######################
    my $dbh = $_[0];

    my $users_id;
    my $csr = $dbh->prepare(qq{
        BEGIN
            $SCHEMA.get_next_users_id (:uid);
        END;
      });
    $csr->bind_param_inout(":uid", \$users_id, 5);
    $csr->execute;
    $csr->finish;
    return ($users_id);
}

# routine to generate a hash of lookup/values from a table
#######################
sub get_lookup_values {
#######################
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

    # generate query # make sql statement
    my $sqlquery = "SELECT $lookups, $values FROM $SCHEMA.$table";
    if ($wherestatement gt " ") {
        $sqlquery .= " WHERE $wherestatement";
    }
    my $csr = $dbh->prepare($sqlquery);
    $csr->execute;

    while (@values = $csr->fetchrow_array) {
        ($lookup, $value) = @values;
        $lookup_list{$lookup} = $value;
    }
    $csr->finish;
    return (%lookup_list);
}

# routine to generate a hash of users/names with selected priv
##########################
sub get_authorized_users {
##########################
    my $priv = $_[0];
    my $dbh = $_[1];

    my @values;
    my $firstname;
    my $lastname;
    my $id;
    my %user_list;

    my $sqlquery = "select users.firstname, users.lastname, users.id from $SCHEMA.users, $SCHEMA.user_privilege privs where users.id=privs.userid and privs.privilege =$priv";
    my $csr = $dbh->prepare($sqlquery);
    $csr->execute;

    while (@values = $csr->fetchrow_array) {
        ($firstname, $lastname, $id) = @values;
        $user_list{$id} = "$firstname $lastname";
    }
    $csr->finish;
    return (%user_list);
}

# routine to generate hash of users/names assigned a task for cd/comment
########################
sub get_assigned_users {
########################
    my $authtype = $_[0];
    my $cd_id = $_[1];
    my $comment_id = $_[2];
    my $dbh = $_[3];

    my %user_list = (
        "brownf" => "Fred Brown",
        "calhouns" => "Steve Calhoun",
    );
    return (%user_list);
}

# routine to generate an oracle friendly date
##############
sub get_date {
##############
    my $indate = $_[0];

    my $outstring = '';
    my $day; my $month; my $year;
    my @months = ("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec");
    if ($indate gt ' ') {
        ($month, $day, $year) = split /\//, $indate;
        $month = $month -1;
    } 
    else {
        ($day, $month, $year) = (localtime)[3,4,5];
        $year = $year + 1900;
    }
    $outstring .= "$day-$months[$month]-$year";
    return ($outstring);
}

# routine to generate an oracle friendly date
########################
sub get_formatted_date {
########################
    my $formatstring = $_[0];
    my $indate = $_[1];

    my $outstring = '';
    my $day; my $month; my $year; my $wday;
    my $outday; my $outmonth; my $outyear;
    my $inday; my $inmonth; my $inyear; my $intime;
    my @mons = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    my @months = qw(January February March April May June July August September October November Decmeber);
    my @dys = qw(Sun Mon Tue Wed Thu Fri Sat);
    my @days = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);

    if ($indate gt ' ') {
        ($inmonth, $inday, $inyear) = split /\//, $indate;
        $inmonth--;
        $inyear -= 1900;
        $intime = timelocal(0, 0, 0, $inday, $inmonth, $inyear);
        ($day, $month, $year, $wday) = (localtime ($intime))[3,4,5,6];
        $year = $year + 1900;
    }
    else {
        ($day, $month, $year, $wday) = (localtime)[3,4,5,6];
        $year = $year + 1900;
    }
    $outstring .= "$day-$mons[$month]-$year";
    if ($formatstring) {  # if format string empty, outstring already formatted
        $outmonth = '';
        while ($formatstring =~ /(MONTH)/) {
            $outmonth = $months[$month];
            $formatstring =~ s/$1/$outmonth/;
        }
        $outmonth = '';
        while ($formatstring =~ /(MON)/) {
            $outmonth = $mons[$month];
            $formatstring =~ s/$1/$outmonth/;
        }
        $outmonth = '';
        while ($formatstring =~ /(MM)/) {
            $outmonth = "00$month";
            $outmonth = substr($outmonth, -2);
            $formatstring =~ s/$1/$outmonth/;
        }
        $outday = '';
        while ($formatstring =~ /(DAY)/) {
            $outday = $days[$wday];
            $formatstring =~ s/$1/$outday/;
        }
        $outday = '';
        while ($formatstring =~ /(DY)/) { 
            $outday = $dys[$wday];
            $formatstring =~ s/$1/$outday/;
        }
        $outday = '';
        while ($formatstring =~ /(DD)/) {
            $outday = "00$day";
            $outday = substr($outday, -2);
            $formatstring =~ s/$1/$outday/;
        }
        $outyear = '';
        while ($formatstring =~ /(YYYY)/) {
            $outyear = $year;
            $formatstring =~ s/$1/$outyear/;
        }
        $outyear = '';
        while ($formatstring =~ /(YY)/) {
            $outyear = substr($year, -2);
            $formatstring =~ s/$1/$outyear/;
        }
        $outstring = $formatstring;
    }
    return ($outstring);
}

# routine to insert an entry into the activity log
##################
sub log_activity {
##################
    my ($dbh, $iserror, $usersid, $description) = @_;
    my ($sql, $sth);

    eval {	
        $dbh->do("INSERT INTO $SCHEMA.activity_log (USERSID, DATELOGGED, ISERROR, DESCRIPTION) VALUES ($usersid, SYSDATE, '$iserror','$description')");
        $dbh -> commit;
    };
    if ($@) {
        my $errormsg = errorMessage ($dbh, '', $usersid, 'activity_log',"Error writing to Activity Log", $@); 
    }
}

#########################
sub lookup_single_value {
#########################
    # This sub executes a SELECT which returns a single column value (or
    # concatentation of column values) (cell) from a single table with given
    # ID, primarily for lookup tables, but can be used for others.
    # If lookupid is a string, the calling procedure must include the needed
    # single quotes.
    my $dbh = $_[0];
    my $tablename = $_[1];
    my $column = $_[2];
    my $lookupid = $_[3];

    my $sqlquery = "SELECT $column
                  FROM $SCHEMA.$tablename
                  WHERE " . $tablename . "id = $lookupid";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    # should return 1 row with 1 column which will hold the requested value
    my @results = $csr->fetchrow_array;

    my $rc = $csr->finish;

    return ($results[0]);
}

##########################
sub lookup_column_values {
##########################
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
    if ($wherestatement ne "") {
        $sqlquery .= " WHERE $wherestatement";
    }
    if ($orderbystatement ne "") {
        $sqlquery .= " ORDER BY $orderbystatement";
    }
    print "\n\n<!-- $sqlquery -->\n\n";
    my $csr = $dbh->prepare($sqlquery);
    my $rv = $csr->execute;

    # should return 1 column which will hold the requested values
    while (my @results = $csr->fetchrow_array) {
        $valuearray[$arrayindex++] = $results[0];
    }
    my $rc = $csr->finish;
    return (@valuearray);
}

# routine to get a user's full name
##################
sub get_fullname {
##################
    my $dbh = $_[0];
    my $schema = $_[1];
    my $userid = $_[2];
    my $csr;
    my @values;
    my $fullname;
    my $sqlquery = "SELECT firstname, lastname FROM $schema.users WHERE usersid = $userid";
        $csr = $dbh->prepare($sqlquery);
        $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    $fullname = ((defined($values[0])) ? $values[0] : "") . ' ' . ((defined($values[1])) ? $values[1] : "");
    return ($fullname);
}

# routine to lookup a value from a table
###############
sub get_value {
###############
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

###############
sub formatID2 {
###############
    my ($id, $type) = @_;
    return("$type"."0" x (5 - length($id)).$id);
}

# routine to send mail message to users notifing of work in the cms.
################
sub notifyUser {
################
    my %args = (
        dbh => '',
        schema => '',
        userID => 0,
        sender => 'Commitment_Management_System@ymp.gov',
        subject => 'CMS Notification',

        message => "You have new work waiting for you in the Commitment Management System.\n\nA link to the CMS can be found on the DOE Intranet Home Page.\nOr you can log in at: http://intranet.ymp.gov/cgi-bin/cms/login.pl\n\n\nPlease do not reply to this message. \nDirect any questions to Lynn Weishaar at (702) 295-5329 or cms_coordinator\@ymp.gov.",
        timeStamp => 'F',
        @_,
    );
    my $status = 0;
    my $sqlcode = '';
    my $csr;
    my @values;
    eval {
	my ($enabled) = $args{dbh} -> selectrow_array ("select enable from $args{schema}.notification");
        if (defined($CMSNotify) && $CMSNotify == 1 && $enabled eq 'T') {
            $sqlcode = "SELECT usersid, email, TO_CHAR(lastnotified, 'YYYYMMDD'), TO_CHAR(SYSDATE, 'YYYYMMDD'),isactive FROM $args{schema}.users WHERE usersid = $args{userID}";
            @values = $args{'dbh'}->selectrow_array($sqlcode);
            if (! defined($values[2])) {
                $values[2] = ' ';
            }
            if ($values[0] == $args{userID}) {
                if ($values[4] eq 'T') {
                    $status = 1;
                    if ($values[2] < $values[3]) {
                        $status = SendMailMessage(sendTo => $values[1], sender => $args{sender}, subject => $args{subject}, message => $args{message}, timeStamp => $args{timeStamp});
                        if ($status == 1) {
                            $sqlcode = "UPDATE $args{schema}.users SET lastnotified = SYSDATE WHERE usersid = $args{userID}";
                            $csr = $args{dbh}->prepare($sqlcode);
                            $status = $csr->execute;
                            $csr->finish;
                            $args{dbh}->commit;
                            $status = 1;
                        }
                    }
                } else {
                    $status = -6;
                }
            } else {
                $status = -4;
            }
        } else {
            $status = 1;
        }
    };
    if ($@) {
        $status = -5;
    }
    return ($status);
}


#########################
sub does_user_have_role {
#########################
    my %args = (
        dbh => '',
        uid => 0,
        rid => 0,
        @_,
    );
    my $status;

    my $sqlquery = "select roleid from $SCHEMA.defaultsiterole where usersid = $args{uid} and roleid = $args{rid}";
    my $csr = $args{dbh}->prepare ($sqlquery);
    $csr->execute;
    my @values = $csr->fetchrow_array;
    $csr->finish;

    my $test_role = $values[0];
    if ((!defined($test_role)) || ($test_role eq '')) {
        $status = 0;
    } 
    else {
        if ($args{rid} == $test_role) {
            $status = 1;
        } 
        else {
            $status = 0;
        }
    }
    return ($status);
}

# routine to
#sub testit {
#    my $elementname=$_[0];
#    my $usersref = $_[1];
#    my $other = $_[2];

#    my %users = %$usersref;

#    print "Name = $name\n";
#    print "User 1 = " . $users{'brownf'} . "\n";
#    print "Other = $other\n";
#}

###############
1; #return true
