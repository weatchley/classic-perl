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
package DBCommitments;
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
	&getWorkproducts		&getWorkbreakdown		&getReqDoc
);
%EXPORT_TAGS =( 
    Functions => [qw(
	&getWorkproducts		&getWorkbreakdown		&getReqDoc
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
sub getReqDoc {  # routine to get the Requirements document
###################################################################################################################################
    my %args = (
        project => 0,  # null
        itemType => 15,
        status => 0, # all
        dateFormat => 'Mon DD, YYYY',
        @_,
    );

    #$args{dbh}->{LongReadLen} = 100000000;
    my @reqDocList;
    my $sqlcode = "SELECT c.id,c.name,c.project_id,c.description,c.type_id,v.id, ";
    $sqlcode .= "v.major_version,v.minor_version,TO_CHAR(v.version_date,'dd-MON-yy hh:mi AM'), ";
    $sqlcode .= "v.status_id,s.status,v.developer_id, v.locker_id, p.name, p.acronym ";
    $sqlcode .= "FROM $args{schema}.configuration_item c, $args{schema}.item_version v, $args{schema}.item_status s , $args{schema}.project p ";
    $sqlcode .= "WHERE (c.id = v.item_id) AND v.status_id = s.id AND p.id=c.project_id AND c.type_id = 25 ";
    $sqlcode .= "AND c.project_id = $args{project} AND (v.item_id,v.version_date) IN (SELECT item_id,MAX(version_date) ";
    $sqlcode .= "FROM $args{schema}.item_version GROUP BY item_id) ORDER BY p.name,c.name ";
    
    #print STDERR "\n$sqlcode\n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($reqDocList[$i]{id},$reqDocList[$i]{name},$reqDocList[$i]{pid},$reqDocList[$i]{descr},$reqDocList[$i]{itemType},$reqDocList[$i]{verID},
           $reqDocList[$i]{major},$reqDocList[$i]{minor},$reqDocList[$i]{date},$reqDocList[$i]{statusID},$reqDocList[$i]{status},
           $reqDocList[$i]{developer},$reqDocList[$i]{locker},$reqDocList[$i]{projName}, $reqDocList[$i]{projAcronym}) = $csr->fetchrow_array) {
        $reqDocList[$i]{description} = $reqDocList[$i]{descr};
        $reqDocList[$i]{major_version} = $reqDocList[$i]{major};
        $reqDocList[$i]{minor_version} = $reqDocList[$i]{minor};
        $reqDocList[$i]{version_date} = $reqDocList[$i]{date};
        $reqDocList[$i]{status_id} = $reqDocList[$i]{statusID};
        $reqDocList[$i]{developer_id} = $reqDocList[$i]{developer};
        $i++;
    }
    
    return (@reqDocList);
}

###################################################################################################################################


1; #return true

