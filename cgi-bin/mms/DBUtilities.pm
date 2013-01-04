# DB Utility functions
#
# $Source: /home/atchleyb/rcs/mms/perl/RCS/DBUtilities.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2003/11/12 20:28:05 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBUtilities.pm,v $
# Revision 1.1  2003/11/12 20:28:05  atchleyb
# Initial revision
#
#
#
#
#

package DBUtilities;
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
        &getActivityLog
    );
%EXPORT_TAGS =( 
    Functions => [qw(
        &getActivityLog
    )]
);


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getActivityLog {  # routine to display error and activity logs
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    $hashRef = $args{options};
    my %options = %$hashRef;
    my $output = "";
    my @items;

    my $logOption = $settings{logOption};
    my $logactivity = (($settings{logactivity} != 0) ? "type = $settings{logactivity} and" : "");
    $logactivity = (($settings{logactivity} == -1) ? "type IS NULL and" : $logactivity);
    my $selecteduser = $settings{selecteduser};
    my $userwhere = ($selecteduser == -1) ? "" : "userid = $selecteduser and";
    my $iserror = (($settings{command} eq 'view_errors') ? "iserror = 'T' and" : "");
    my $where = "$userwhere $iserror $logactivity ${$options{$logOption}}{'where'}";
    my $sqlquery = "SELECT userid, TO_CHAR(datelogged,'DD-MON-YY HH24:MI:SS'), description, iserror, NVL(type,0) FROM $args{schema}.activity_log WHERE $where ORDER BY datelogged DESC";
    my $csr = $args{dbh}->prepare($sqlquery);
    $csr->execute;
    my $i = 0;
    while (($items[$i]{user}, $items[$i]{date}, $items[$i]{text}, $items[$i]{err}, $items[$i]{type}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;

    return(@items);
}


###################################################################################################################################
###################################################################################################################################




1; #return true
