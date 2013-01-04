# Utilities for the CIRS interface
#
# $Source: /data/dev/rcs/cms/perl/RCS/CIRS_procs.pm,v $
# $Revision: 1.1 $
# $Date: 2002/09/05 16:25:16 $
# $Author: naydenoa $
# $Locker:  $
# $Log: CIRS_procs.pm,v $
# Revision 1.1  2002/09/05 16:25:16  naydenoa
# Initial revision
#

package CIRS_procs;
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

@EXPORT = qw (&formatString &insertDataRecord);
@EXPORT_OK = qw(&formatString &insertDataRecord);
%EXPORT_TAGS =(
    Functions => [qw(&formatString &insertDataRecord) ]
);

sub formatString {
my %args = (
	astring => '',
	trim => 0,
	tag => '',
	@_,
);

    my $thestring = $args{astring};
    $thestring =~ s/\&/\&amp;/g;
    $thestring =~ s/</\&lt;/g;
    $thestring =~ s/>/\&gt;/g;
    $thestring =~ s/\"/\&quot;/g;
    $thestring =~ s/\'/\&apos;/g;

    if ($args{trim} > 0) {
	$thestring = substr ($thestring, 0, $args{trim});
    }	
   if ($args{tag}) {
	$thestring = "<" . $args{tag} . ">" . $thestring . "</" . $args{tag} . ">";
   }

    return ($thestring);
}

sub insertDataRecord {
    my %args = (
	key => 0,
	change => 2,
	system => 1,
	thestring => '',
	@_,
	);	

    my $insertstring = "insert into cirs.data_record (record_type, change_type, change_date, key, data) values ($args{system}, $args{change}, SYSDATE, '$args{key}', :stuff)";
    my $cirsinsert = $args{dbh} -> prepare ($insertstring);
    $cirsinsert -> bind_param (":stuff", $args{thestring}, {ora_type => ORA_CLOB, ora_field => 'data'});
    $cirsinsert -> execute;
    $cirsinsert -> finish;
    return; 
}

###############
1; #return true

