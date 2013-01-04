# DB Utility functions for the SCM
#
# $Source: /data/dev/rcs/pcl/perl/RCS/DBLogin.pm,v $
#
# $Revision: 1.6 $
#
# $Date: 2004/06/14 21:27:31 $
#
# $Author: munroeb $
#
# $Locker:  $
#
# $Log: DBLogin.pm,v $
# Revision 1.6  2004/06/14 21:27:31  munroeb
# Fixed time calculation error in validateUser() function
#
# Revision 1.5  2004/05/21 18:24:09  munroeb
# Modified script to reflect password change requests
#
# Revision 1.4  2003/07/08 17:08:27  starkeyj
# modified getPasswordExpiration - switched ($sysYear - $year) to ($year - $sysYear)
# for PCL SCR 0013
#
# Revision 1.3  2003/02/14 18:13:49  atchleyb
# added improved password security
#
# Revision 1.2  2003/02/03 19:58:25  atchleyb
# removed refs to SCM
#
# Revision 1.1  2002/10/24 22:10:27  atchleyb
# Initial revision
#
#
#
#

package DBLogin;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;
use UI_Widgets qw(lpadzero);

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
    my $password = &db_encrypt_password($args{password});
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
                my $delay = Math::BigInt->new(time);
                my $delayTime = $delay->badd(($SYSLockoutTime * 60));
                my @dta = localtime $delayTime;
                $delayTime = ($dta[5] + 1900) . lpadzero($dta[7],3) . lpadzero($dta[2], 2) . lpadzero($dta[1], 2);

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
