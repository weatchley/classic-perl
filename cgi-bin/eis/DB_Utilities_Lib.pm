# Library of UI widget routines for the DB

#
# $Source: /usr/local/homes/atchleyb/rcs/crd/perl/RCS/DB_Utilities_Lib.pm,v $
#
# $Revision: 1.43 $
#
# $Date: 2006/11/03 16:54:04 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DB_Utilities_Lib.pm,v $
# Revision 1.43  2006/11/03 16:54:04  atchleyb
# Updated to fix bug in Samba introduced by the new evironment (added the characters  2>&1 to the endof the connect strings)
#
# Revision 1.42  2005/12/08 19:44:04  atchleyb
# CR00045 - change password for 'eiscrd' user and change server for source files
#
# Revision 1.41  2004/05/26 22:06:17  atchleyb
# updated to use newer password security
#
# Revision 1.40  2004/02/26 16:18:49  atchleyb
# added check to force secure login (CR042)
#
# Revision 1.39  2001/11/13 01:13:22  mccartym
# eliminate copycomments function
#
# Revision 1.38  2001/10/02 16:12:06  naydenoa
# Added dbi finish to copyComments code.
#
# Revision 1.37  2001/09/21 22:23:27  atchleyb
# hard coded the smb user to eiscrd
#
# Revision 1.36  2001/07/27 23:09:17  atchleyb
# changed the way that does_user_have_priv gets the list of privs
#
# Revision 1.35  2001/07/27 20:58:27  atchleyb
# added code to does_user_have_priv to default the user id to 0 if none is passed
#
# Revision 1.34  2001/07/27 19:25:00  atchleyb
# added code in does_user_have_priv to handle the condition if no priv is passed in
#
# Revision 1.33  2001/05/17 20:12:40  mccartym
# add lastSubmittedText function
#
# Revision 1.32  2001/05/10 17:40:36  atchleyb
# added stub code for lastSubmittedText function
#
# Revision 1.31  2001/04/27 21:00:49  atchleyb
# updated copycomments to include two new columns, hasissues, summaryapproved
#
# Revision 1.30  2001/02/12 17:56:13  atchleyb
# added option to db_connect to select server
#
# Revision 1.29  2001/01/18 22:31:16  atchleyb
# fixed bug in copy comments function
# replaced 'SELECT *' in copy comments function
#
# Revision 1.28  2000/08/16 18:37:06  naydenoa
# Changed copyComments on insert: summary = NULL, dateassigned = NULL;
# on update: createdby = current user, datecreated = SYSDATE
#
# Revision 1.27  2000/07/26 17:45:20  naydenoa
# Completed update and testing of sub copyComments
#
# Revision 1.26  2000/07/13 17:54:52  naydenoa
# Fixed misidentified variable ($dupSimStatus to $dupsimstatus) in
# insert part of copyComment
#
# Revision 1.25  2000/07/13 17:18:41  naydenoa
# Updated sub copyComments to handle comment updates for
# similar documents.
#
# Revision 1.24  2000/04/13 17:41:32  atchleyb
# modified log-activity and log_error to use a common function updateActivityLog
#
# Revision 1.23  2000/02/23 21:36:44  atchleyb
# modified function log_activity to use log_error when it has an error
#
# Revision 1.22  2000/02/04 20:57:50  atchleyb
# removed refferences to DBPassword
#
# Revision 1.21  1999/11/22 18:36:37  fergusoc
# fixed bug in copy comments subroutine
#
# Revision 1.20  1999/10/19 20:41:04  fergusoc
# fixed bug in copyComments subroutine
#
# Revision 1.19  1999/10/18 17:28:57  fergusoc
# added copy comments subroutine
#
# Revision 1.18  1999/10/07 23:33:10  mccartym
# more cleanup
#
# Revision 1.17  1999/10/07 22:46:45  mccartym
# add colum list to activity log inserts
# clean up and remove some dead code
#
# Revision 1.16  1999/09/14 20:09:38  atchleyb
# updated get_authorized_users to allow an exclude priv, also set it to exclude user id's greater than 1000
#
# Revision 1.15  1999/09/02 23:49:51  atchleyb
# added eval blocks and errorchecking to selected functions
#
# Revision 1.14  1999/09/02 17:46:08  atchleyb
# changed connection routine to have autocommit off and raise error on by default
#
# Revision 1.13  1999/09/01 00:07:24  atchleyb
# fixed minor bug in getBracketedImageFile
#
# Revision 1.12  1999/09/01 00:01:26  atchleyb
# changed doesScannedImageFileExist and getBracketedImageFile to use named parameters with defaults
#
# Revision 1.11  1999/08/31 17:53:03  atchleyb
# added description of getBracketedImageFile
#
# Revision 1.10  1999/08/31 17:47:48  atchleyb
# added doesScannedImageFileExist and getBracketedImageFile routines
#
# Revision 1.9  1999/08/18 16:03:34  atchleyb
# added tie to get_authorized_users
#
# Revision 1.8  1999/08/10 02:30:02  mccartym
# removed get_next_comment_number()
#
# Revision 1.7  1999/07/30 17:29:45  atchleyb
# changed get_next_*_id functions to use sequences
#
# Revision 1.6  1999/07/29 18:48:31  mccartym
# added redirect subroutine
#
# Revision 1.5  1999/07/19 19:55:08  atchleyb
# fixed bug in get_user_privs
#
# Revision 1.4  1999/07/17 00:06:14  atchleyb
# added tie module
#
# Revision 1.3  1999/07/14 18:30:04  atchleyb
# got rid of some of the warnings
#
# Revision 1.2  1999/07/06 23:48:53  mccartym
# Add checkLogin subroutine to redirect to login script if user not logged in
#
# Revision 1.1  1999/07/06 20:55:35  atchleyb
# Initial revision
#
#
#
package DB_Utilities_Lib;
use strict;
use Carp;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use vars qw($DBUser $CRDConnectPath $CRDServer);
#use CRD_Header qw(:Constants);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

$DBUser = $ENV{'DBUser'};
$CRDConnectPath = $ENV{'CRDConnectPath'};
$CRDServer = $ENV{'CRDServer'};
#$schema = $ENV{'SCHEMA'};

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (&db_connect &db_disconnect &validate_user &does_user_have_priv &get_userid &get_username &get_fullname
 &get_next_commentor_id &get_next_users_id &get_lookup_values &get_value
 &get_authorized_users &get_date &log_activity &log_error &db_encrypt_password &checkLogin
 &doesScannedImageFileExist &getBracketedImageFile &lastSubmittedText &getPasswordExpiration
 );
@EXPORT_OK = qw(&db_connect &db_disconnect &validate_user &does_user_have_priv &get_userid &get_username &get_fullname
 &get_next_commentor_id &get_next_users_id &get_lookup_values &get_value
 &get_authorized_users &get_date &log_activity &log_error &db_encrypt_password &checkLogin
 &doesScannedImageFileExist &getBracketedImageFile &lastSubmittedText &getPasswordExpiration
 );
%EXPORT_TAGS =(
    Functions => [qw(&db_connect &db_disconnect &validate_user &does_user_have_priv &get_userid &get_username &get_fullname
 &get_next_commentor_id &get_next_users_id &get_lookup_values &get_value
 &get_authorized_users &get_date &log_activity &log_error &db_encrypt_password &checkLogin
 &doesScannedImageFileExist &getBracketedImageFile &lastSubmittedText &getPasswordExpiration
 ) ]
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
# 'get_next_commentor_id'
# (commentor id) = &get_next_commentor_id( (database handle), (schema) );
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
# 'doesScannedImageFileExist'
# (status) = &doesScannnedImageFileExist ( image_file => (image file name) [ , share => (), user => (), password => (), group => (), remote_path => () ] );
# 'getBracketedImageFile'
# (status) = &getBracketedImageFile ( image_file => (image file name), local_path => (dir path on local server, does not include document_root) [ , share => (), user => (), password => (), group => (), remote_path => (), local_file => () ] );


# routine to get username/password for oracle
sub getOracleID {
    my $username = $DBUser;
    my $password;
    my $temp;
    if (open (FH, "$CRDConnectPath |")) {
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
          server => $CRDServer,
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
    my $passwordUC = &db_encrypt_password(uc($input_password));
    $username = uc($username);
    my $sqlquery = "select password from $schema.users where (username = '$username') and ((password = '$password') or (password = '$passwordUC')) and (isactive = 'T')";
        $csr = $dbh->prepare ($sqlquery);
        $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    my $test_password = $values[0];
    if ($#values < 0) {
        $status = 0;
    } else {
        if ($password eq $test_password || $passwordUC eq $test_password) {
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

# routine to get the next available commentor id
sub get_next_commentor_id {
    my $dbh = $_[0];
    my $schema = $_[1];
    my $csr;
    my $status;
    my @values;
    my $commentor_id;
    my $sqlquery = "SELECT $schema.commentor_id.NEXTVAL from DUAL";
    $csr = $dbh->prepare($sqlquery);
    $status = $csr->execute;
    @values = $csr->fetchrow_array;
    $csr->finish;
    $commentor_id = $values[0];
    return ($commentor_id);
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
   if (!defined($username) || !defined($userid) || !defined($schema) || !(defined($ENV{HTTPS}) && $ENV{HTTPS} eq 'on')) {
      $ENV{SCRIPT_NAME} =~ m%^(.*/)%;
      print "Location: https://$ENV{SERVER_NAME}$1$script.pl\n\n";
      exit;
   }
}

###########

# routine to test if a comment document image has been scanned
sub doesScannedImageFileExist {
    my %args = (
        image_file => '',
        #share => '//ydnts100.ydservices.ymp.gov/group',
        share => '//ydnts100/group',
        #user => lc($ENV{'CRDType'}) . 'crd',
        user => 'eiscrd',
        password => 'C1r2D3c4G5i6!',
        group => 'ydservices',
        remote_path => "$ENV{'CRDType'}_CD_Images\\Scanned",
        @_,
    );
    my $status = 0;
    my $resultdata = '';
    my $connectstring = '';
    #use vars qw(CDFILEPTR);
    local *CDFILEPTR;
    $connectstring = "/usr/local/samba/bin/smbclient $args{share} $args{password} -U $args{user} -W $args{group} -c 'cd $args{remote_path};rename ";
    $connectstring .= "$args{image_file} $args{image_file};exit;' 2>&1|";
    open CDFILEPTR, $connectstring ;
    while (<CDFILEPTR>) {
        $resultdata .= $_;
    }
    close CDFILEPTR;
    if (index($resultdata, "ERRbadfile") >= 0) {
        $status = 0;
    } else {
        $status = 1;
    }
    return ($status);
}

###########

# routine to get a bracketed comment document image
sub getBracketedImageFile {
    my %args = (
        image_file => '',
        local_path => '',
        local_file => '',
        #share => '//ydnts100.ydservices.ymp.gov/group',
        share => '//ydnts100/group',
        #user => lc($ENV{'CRDType'}) . 'crd',
        user => 'eiscrd',
        password => 'C1r2D3c4G5i6!',
        group => 'ydservices',
        remote_path => "$ENV{'CRDType'}_CD_Images\\Bracketed",
        @_,
    );
    #my $DocPath=$ENV{'DOCUMENT_ROOT'} . "/" . $args{local_path};
    my $DocPath=$args{local_path};
    my $status = 0;
    my $resultdata = '';
    my $connectstring = '';
    my $filename = '';
    local *CDFILEPTR;
    $connectstring = "/usr/local/samba/bin/smbclient $args{share} $args{password} -U $args{user} -W $args{group} -c 'cd $args{remote_path};";
    if ($args{local_file} eq '') {
        $connectstring .= "lcd $DocPath;get $args{image_file};exit;' 2>&1|";
    } else {
        $connectstring .= "lcd $DocPath;get $args{image_file} $args{local_file};exit;' 2>&1|";
    }
    open CDFILEPTR, $connectstring ;
    while (<CDFILEPTR>) {
        $resultdata .= $_;
    }
    close CDFILEPTR;
    if (index($resultdata, "ERRbadfile") >= 0) {
        $status = 0;
    } elsif (index($resultdata, "getting file") >= 0) {
        $status = 1;
    } else {
        $status = -1;
        print STDERR "\ngetBracketedImageFile Error - Parameters: @_ - \nSamba Session: $resultdata\n$connectstring\n\n";
    }
    if ($args{local_file} eq '') {
        $filename = "$DocPath/$args{image_file}";
    } else {
        $filename = "$DocPath/$args{local_file}";
    }
    if (open (CDFILEPTR, "<$filename")) {
        close (CDFILEPTR);
        eval {
            chmod 0774, "$filename";
        };
        if ($@) {
            print STDERR "\ngetBracketedImageFile Error - Parameters: @_ - Error Message: $@\n";
        }
        if ($status != 1) {
            eval {
                unlink $filename;
            };
            if ($@) {
                print STDERR "\ngetBracketedImageFile Error - Parameters: @_ - DocPath: $DocPath - Error Message: $@\n";
            }
        }
    }
    return ($status);
}

###################################################################################################################################
sub lastSubmittedText {                       # get the most recently updated version of the response - including 'save as draft' #
###################################################################################################################################
   my %args = (
      version => "",
      @_,
   );
   my ($out, $status, $version) = ("", 0, $args{version});
   my $relateComment = "document = $args{documentID} and commentnum = $args{commentID} ";
   ($version) = $args{dbh}->selectrow_array("select max(version) from $args{schema}.response_version where $relateComment") if (!$version);
   if ($version) {
      my $relateResponseVersion = "$relateComment and version = $version";
      ($status, $out) = $args{dbh}->selectrow_array("select status, lastsubmittedtext from $args{schema}.response_version where $relateResponseVersion");
      if (($status > 1) && ($status != 3) && ($status < 9)) {
         my @text = ("", "", "originaltext", "", "reviewedtext", "techeditedtext", "coordeditedtext", "nepaeditedtext", "doeeditedtext");
         my ($draft) = $args{dbh}->selectrow_array("select $text[$status] from $args{schema}.response_version where $relateResponseVersion");
         $out = $draft if ($draft);
      }
   }
   return ($out);
}


################################################################################################################
sub getPasswordExpiration { # routine to get a users password expiration date/time
################################################################################################################
    my %args = (
          userID => 0,
          @_,
          );
    my $sqlcode = "SELECT TO_CHAR(datepasswordexpires, 'YYYYMMDDHH24MI'),TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI'),";
    $sqlcode .= "TO_CHAR(datepasswordexpires, 'DDD'),TO_CHAR(SYSDATE, 'DDD') ";
    $sqlcode .= "FROM $args{schema}.users WHERE (id = $args{userID})";
    my ($dateTime,$sysDateTime,$jDay,$sysJDay) = $args{dbh}->selectrow_array($sqlcode);
    my $year = substr($dateTime,0,4);
    my $sysYear = substr($sysDateTime,0,4);
    my $daysRemaining = $jDay + (($year - $sysYear)*365) - $sysJDay;
    return ($dateTime, $sysDateTime, $daysRemaining);
}

1; #return true
