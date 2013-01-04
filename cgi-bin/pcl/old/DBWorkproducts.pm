#
# $Source: $
#
# $Revision: $ 
#
# $Date:  $
#
# $Author:  $
#
# $Locker:  $
#
# $Log:  $
#
#
package DBWorkproducts;
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use Tables qw(:Functions);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);
use Carp;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
	&getWorkproducts		&getWorkbreakdown
);
%EXPORT_TAGS =( 
    Functions => [qw(
	&getWorkproducts		&getWorkbreakdown
    )]
);


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getWorkproducts{  # routine to get the work products for a project
###################################################################################################################################
    my %args = (
        project => 0,  # null
        itemType => 0,
        status => 0, # all
        dateFormat => 'Mon DD, YYYY',
        @_,
    );
    #$args{dbh}->{LongReadLen} = 100000000;
    my @workproductList;
    my $sqlcode = "SELECT id,name,type,description,to_char(est_delivery,'MM/DD/YYYY'),to_char(nlt_delivery,'MM/DD/YYYY') ";
    $sqlcode .= "FROM $args{schema}.temp_work_product ";
    $sqlcode .= "WHERE project_id = $args{project} ";
    $sqlcode .= "ORDER BY id ";
  # print STDERR "\n $sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($workproductList[$i]{productid},$workproductList[$i]{productname},$workproductList[$i]{producttype},
    $workproductList[$i]{productdesc},$workproductList[$i]{estdelivery},$workproductList[$i]{nltdelivery}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@workproductList);
}
###################################################################################################################################
sub getWorkbreakdown {  # routine to get the activity breakdown of a work product
###################################################################################################################################
    my %args = (
        project => 0,  # null
        productID => 0,
        status => 0, # all
        dateFormat => 'Mon DD, YYYY',
        @_,
    );
    #$args{dbh}->{LongReadLen} = 100000000;
    my @productBreakdownList;
    my $sqlcode = "SELECT id,work_product_id,version,activity,status,description,source ";
    $sqlcode .= "FROM $args{schema}.temp_work_product_bkdn ";
    $sqlcode .= "WHERE work_product_id = $args{productID} ";
    $sqlcode .= "ORDER BY work_product_id ";
   # print STDERR "\n $sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($productBreakdownList[$i]{id},$productBreakdownList[$i]{wpid},$productBreakdownList[$i]{version},
    $productBreakdownList[$i]{activity},$productBreakdownList[$i]{status},$productBreakdownList[$i]{desc},
    $productBreakdownList[$i]{source}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@productBreakdownList);
}


###################################################################################################################################
sub getSomething {  # routine to get a something
###################################################################################################################################
    my %args = (
        project => 0,  # null
        itemType => 0,
        status => 0, # all
        dateFormat => 'Mon DD, YYYY',
        @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    my %mtg;
    my $sqlcode = "SELECT m.projectid, s.name, to_char(m.mtgdate, '$args{dateFormat}'), m.room, ";
    $sqlcode .= "m.start_time, m.end_time, m.agenda, m.minutes, p.name, p.acronym, m.invitees, m.attendees ";
    $sqlcode .= "FROM $args{schema}.sccb s, $args{schema}.temp_meetings m, $args{schema}.project p ";
    $sqlcode .= "WHERE p.sccbid = s.id AND m.projectid = p.id AND m.projectid = $args{projectID} AND mtgdate = TO_DATE('$args{date}', 'MM/DD/YYYY')";   
    print STDERR "$sqlcode\n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    ($mtg{projectid}, $mtg{sccb}, $mtg{mtgdate}, $mtg{room}, $mtg{starttime}, $mtg{endtime}, $mtg{agenda}, $mtg{minutes}, $mtg{project}, 
     $mtg{abbr}, $mtg{invitees}, $mtg{attendees}) = $csr->fetchrow_array;
    return (%mtg);
}

###################################################################################################################################

sub new {
    my $self = {};
    bless $self;
    return $self;
}

# proccess variable name methods
sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self) || croak "$self is not an object";
    my $name = $AUTOLOAD;
    $name =~ s/.*://; # strip fully-qualified portion
    unless (exists $self->{$name} ) {
        croak "Can't Access '$name' field in object of class $type";
    }
    if (@_) {
        return $self->{$name} = shift;
    } else {
        return $self->{$name};
    }
}

1; #return true

