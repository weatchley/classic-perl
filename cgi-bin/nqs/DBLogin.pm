# DB Utility functions
#
# $Source: /data/dev/rcs/qa/perl/RCS/DBLogin.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/05/30 22:58:12 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: DBLogin.pm,v $
# Revision 1.1  2004/05/30 22:58:12  starkeyj
# Initial revision
#
#
#
#
#

package DBLogin;
#
# get all required libraries and modules
use strict;
use NQS_Header qw(:Constants);
use OQA_Utilities_Lib qw(:Functions);
#use DBShared qw(:Functions);
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
    &validateUser   &getPasswordExpiration
    );
%EXPORT_TAGS =( 
    Functions => [qw(
    &validateUser   &getPasswordExpiration
    )]
);


###################################################################################################################################
###################################################################################################################################



################################################################################################################
sub validateUser {
# routine to validate a user of the DB system
################################################################################################################
    my %args = (
          userName => "",
          password => "",
          @_,
          );
    use Math::BigInt;
    my $status;
    my $dateFormat = "YYYYDDDHH24MI";
    my $password = &NQS_encrypt_password($args{password});
    my $username = uc($args{userName});
    my $sqlcode = "SELECT id, password,failedattempts,TO_CHAR(lockout,'$dateFormat'),TO_CHAR(lastfailure,'$dateFormat'),";
    $sqlcode .= "TO_CHAR(SYSDATE,'$dateFormat') ";
    $sqlcode .= "FROM $args{schema}.users WHERE (username = '$username') AND (isactive = 'T')";
    my ($id, $test_password, $failedattempts,$lockout,$lastfailure,$sysdate) = $args{dbh}->selectrow_array($sqlcode);
    if (!defined($test_password)) {
        $status = 0;
    } else {
        if ($password eq $test_password) {
            $status = 1;
        } else {
            $status = 0;
        }
    }
    eval {
        if ($status == 1) {
            if (!defined($lockout) || ($sysdate) gt ($lockout)) {
                $args{dbh}->do("UPDATE $args{schema}.users SET failedattempts=0, lockout=NULL, lastfailure=NULL WHERE id=$id");
            } else {
                $status = 0;
            }
        } else {
            if (defined($id) && $id >=0) {
                my $delay = Math::BigInt->new($sysdate);
                my $delayTime = $delay->badd($SYSLockoutTime);
                $sqlcode = "UPDATE $args{schema}.users SET failedattempts=" . (++$failedattempts) . ", " .
                    "lastfailure=SYSDATE" . 
                    (($failedattempts >= $SYSLockoutCount) ? ", lockout=TO_DATE('" . ($delayTime) . "', '$dateFormat')" : "") . 
                    " WHERE id=$id";
                $args{dbh}->do($sqlcode);
            }
        }
        $args{dbh}->commit;
    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return ($status);
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



###################################################################################################################################
###################################################################################################################################




1; #return true
