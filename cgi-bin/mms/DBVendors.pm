# DB Vendors functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBVendors.pm,v $
#
# $Revision: 1.5 $
#
# $Date: 2009/06/26 21:57:40 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBVendors.pm,v $
# Revision 1.5  2009/06/26 21:57:40  atchleyb
# ACR0906_001 - List of changes
#
# Revision 1.4  2006/04/20 16:17:53  atchleyb
# CR 0024 - getVendorInfo was altered to test for undefined id and reset it to 0
#
# Revision 1.3  2004/05/05 23:18:19  atchleyb
# minor updates for taxpermits and default values
#
# Revision 1.2  2003/12/02 16:48:03  atchleyb
# added code for bids
#
# Revision 1.1  2003/11/12 20:28:20  atchleyb
# Initial revision
#
#
#
#
#

package DBVendors;
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
      &getVendorList     &doProcessVendorEntry
      &getVendorInfo     &createBlankVendor
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getVendorList     &doProcessVendorEntry
      &getVendorInfo     &createBlankVendor
    )]
);


###################################################################################################################################
sub getVendorList {  # routine to get list of vendors
###################################################################################################################################
    my %args = (
        activeOnly => 'T',
        orderBy => 'name, city, state',
        statusList => "",
        pdStatusList => "",
        idList => "",
        excludeList => "",
        @_,
    );

    my $i = 0;
    my @vendors;
    #$args{dbh}->{LongReadLen} = 100000000;
    #$args{dbh}->{LongTruncOk} = 0;
    my $sqlcode = "SELECT id, name, city, state, mainproduct,status FROM $args{schema}.vendors WHERE 1=1 ";

    if ($args{activeOnly} eq 'T') {$sqlcode .= "AND (status IN (1, 2)) ";}
    if ($args{statusList} gt '') {$sqlcode .= "AND (status IN ($args{statusList})) ";}
    if ($args{idList} gt '') {$sqlcode .= "AND (id IN ($args{idList})) ";}
    if ($args{excludeList} gt '') {$sqlcode .= "AND (id NOT IN ($args{excludeList})) ";}
    if ($args{pdStatusList} gt '') {$sqlcode .= "AND (id IN (SELECT vendor FROM $args{schema}.purchase_documents WHERE status IN ($args{pdStatusList}))) ";}
    $sqlcode .= "ORDER BY $args{orderBy}";
#print STDERR "\n$sqlcode\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($vendors[$i]{id}, $vendors[$i]{name}, $vendors[$i]{city}, $vendors[$i]{state}, $vendors[$i]{mainproduct}, $vendors[$i]{status}) = 
            $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;

    return (@vendors);
}


###################################################################################################################################
sub getVendorInfo {  # routine to get vendor info
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );

    my $i = 0;
    my %vendor;
    
    $args{dbh}->{LongReadLen} = 100000000;
    $args{dbh}->{LongTruncOk} = 0;
    $args{id} = ((defined($args{id})) ? $args{id} : 0);

    my $sqlcode = "SELECT id,abrv,name,address,nvl(city,''),nvl(state,''),nvl(zip,''),nvl(country,''),";
       $sqlcode .= "nvl(remitaddress,''),nvl(remitcity,''),nvl(remitstate,''),nvl(remitzip,''),";
       $sqlcode .= "nvl(pointofcontact,''),nvl(phone,''),nvl(extension,''),nvl(fax,''),nvl(email,''),nvl(url,''),";
       $sqlcode .= "mainphone,mainproduct,nvl(lastpo,0),TO_CHAR(lastused,'MM/DD/YYYY'),status,";
       $sqlcode .= "nvl(relatedto,0),nvl(relationship,''),TO_CHAR(datecreated, 'MM/DD/YYYY') FROM $args{schema}.vendors WHERE id=$args{id} ";
#print STDERR "\n$sqlcode\n";

    ($vendor{id},$vendor{abrv},$vendor{name},$vendor{address},$vendor{city},$vendor{state},$vendor{zip},$vendor{country},
        $vendor{remitaddress},$vendor{remitcity},$vendor{remitstate},$vendor{remitzip},$vendor{pointofcontact},
        $vendor{phone},$vendor{extension},$vendor{fax},$vendor{email},$vendor{url},$vendor{mainphone},$vendor{mainproduct},
        $vendor{lastpo},$vendor{lastused},$vendor{status},$vendor{relatedto},$vendor{relationship},
        $vendor{datecreated}) = $args{dbh}->selectrow_array($sqlcode);

    $vendor{siteCount} = 0;
    $sqlcode = "SELECT id FROM $args{schema}.site_info ORDER BY id";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (my ($id) = $csr->fetchrow_array) {
        $vendor{taxpermits}[$id]{hastaxid} = 'F';
        $vendor{taxpermits}[$id]{taxid} = '';
        $vendor{taxpermits}[$id]{effectivedate} = '';
        $vendor{siteCount}++;
    }
    $csr->finish;

    $sqlcode = "SELECT vendor,site,hastaxid,NVL(taxid,''),NVL(TO_CHAR(effectivedate, 'MM/DD/YYYY'),'') FROM $args{schema}.vendor_tax_permit ";
    $sqlcode .= "WHERE vendor=$args{id} ORDER BY site";
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (my ($vendor,$site,$hastaxid,$taxid,$effectivedate) = $csr->fetchrow_array) {
        $vendor{taxpermits}[$site]{hastaxid} = $hastaxid;
        $vendor{taxpermits}[$site]{taxid} = $taxid;
        $vendor{taxpermits}[$site]{effectivedate} = $effectivedate;
        #$vendor{siteCount}++;
    }
    $csr->finish;
    
    $sqlcode = "SELECT vc.vendor,vc.classification,c.name FROM $args{schema}.vendor_classification vc, $args{schema}.classifications c ";
    $sqlcode .= "WHERE vc.classification=c.id AND vc.vendor=$args{id} ORDER BY c.name";
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    $vendor{classificationCount} = 0;
    while (my ($vendor,$classification,$name) = $csr->fetchrow_array) {
        $vendor{classifications}[$vendor{classificationCount}]{id} = $classification;
        $vendor{classifications}[$vendor{classificationCount}]{name} = $name;
        $vendor{classificationCount}++;
    }
    $csr->finish;
    
    $sqlcode = "SELECT vendor,text,TO_CHAR(dateentered, 'MM/DD/YYYY HH24:MI'),enteredby FROM $args{schema}.vendor_comments ";
    $sqlcode .= "WHERE vendor=$args{id} ORDER BY dateentered DESC";
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    $vendor{commentCount} = 0;
    while (my ($vendor, $text, $dateentered, $enteredby) = $csr->fetchrow_array) {
        $vendor{comments}[$vendor{commentCount}]{text} = $text;
        $vendor{comments}[$vendor{commentCount}]{dateentered} = $dateentered;
        $vendor{comments}[$vendor{commentCount}]{enteredby} = $enteredby;
        $vendor{commentCount}++;
    }
    $csr->finish;
    

    return (%vendor);
}


###################################################################################################################################
sub createBlankVendor {  # routine to create a blank vendor
###################################################################################################################################
    my %args = (
        @_,
    );

    my %vendor;
    
    my $sqlcode = "";
    
    %vendor = (
        id => 0,
        abrv => '',
        name => '',
        address => '',
        city => '',
        state => '',
        zip => '',
        remitaddress => '',
        remitcity => '',
        remitstate => '',
        remitzip => '',
        pointofcontact => '',
        phone => '',
        extension => '',
        fax => '',
        email => '',
        url => '',
        mainphone => '',
        mainproduct => '',
        lastpo => '',
        lastused => '',
        status => 0,
        relatedto => 0,
        relationship => '',
        country => 'US',
        datecreated => '',
        classificationCount => 0,
        classifications => [],
        commentCount => 0,
        comments => [],
        siteCount => 0,
    );
    $vendor{classifications}[0]{id} = 0;
    $vendor{classifications}[0]{name} = '';
    $vendor{comments}[0]{text} = '';
    $vendor{comments}[0]{dateentered} = '';
    $vendor{comments}[0]{enteredby} = 0;
    
    $sqlcode = "SELECT id FROM $args{schema}.site_info ORDER BY id";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (my ($id) = $csr->fetchrow_array) {
        $vendor{taxpermits}[$id]{hastaxid} = 'F';
        $vendor{taxpermits}[$id]{taxid} = '';
        $vendor{taxpermits}[$id]{effectivedate} = '';
        $vendor{siteCount}++;
    }
    $csr->finish;

    return (%vendor);
}


###################################################################################################################################
sub doProcessVendorEntry {  # routine to enter a new vendor or update a vendor
###################################################################################################################################
    my %args = (
        userID => 0,
        type => "",  # new or update
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    my $id;
    
    eval {
        ($id) = (($args{type} eq 'new') ? $args{dbh}->selectrow_array("SELECT $args{schema}.vendors_id.NEXTVAL FROM dual") : ($settings{vendorid}));
        my $description = $settings{description};
        my $text = $settings{vendor};
        if ($args{type} eq 'new') {
            $sqlcode = "INSERT INTO $args{schema}.vendors (id,name,address,city,state,zip,country,remitaddress,remitcity,remitstate,remitzip,";
            $sqlcode .= "pointofcontact,phone,extension,fax,email,url,mainphone,mainproduct,datecreated) ";
            $sqlcode .= "VALUES ($id, " . $args{dbh}->quote($settings{name}) . ", " . $args{dbh}->quote($settings{address}) . ", ";
            $sqlcode .= (($settings{city} gt " ") ? "'$settings{city}'" : "NULL") . ", ";
            $sqlcode .= (($settings{state} gt " ") ? "'$settings{state}'" : "NULL") . ", ";
            $sqlcode .= (($settings{zip} gt " ") ? "'$settings{zip}'" : "NULL") . ", ";
            $sqlcode .= (($settings{country} gt " ") ? "'$settings{country}'" : "NULL") . ", ";
            $sqlcode .= (($settings{remitaddress} gt " ") ? $args{dbh}->quote($settings{remitaddress}) : "NULL") . ", ";
            $sqlcode .= (($settings{remitcity} gt " ") ? "'$settings{remitcity}'" : "NULL") . ", ";
            $sqlcode .= (($settings{remitstate} gt " ") ? "'$settings{remitstate}'" : "NULL") . ", ";
            $sqlcode .= (($settings{remitzip} gt " ") ? "'$settings{remitzip}'" : "NULL") . ", ";
            $sqlcode .= (($settings{pointofcontact} gt " ") ? $args{dbh}->quote($settings{pointofcontact}) : "NULL") . ", ";
            $sqlcode .= (($settings{phone} gt " ") ? "'$settings{phone}'" : "NULL") . ", ";
            $sqlcode .= (($settings{extension} gt " ") ? "'$settings{extension}'" : "NULL") . ", ";
            $sqlcode .= (($settings{fax} gt " ") ? "'$settings{fax}'" : "NULL") . ", ";
            $sqlcode .= (($settings{email} gt " ") ? $args{dbh}->quote($settings{email}) : "NULL") . ", ";
            $sqlcode .= (($settings{url} gt " ") ? $args{dbh}->quote($settings{url}) : "NULL") . ", ";
            $sqlcode .= (($settings{mainphone} gt " ") ? "'$settings{mainphone}'" : "NULL") . ", ";
            $sqlcode .= (($settings{mainproduct} gt " ") ? $args{dbh}->quote($settings{mainproduct}) : "NULL") . ", ";
            $sqlcode .= "SYSDATE)";
            
            my $csr = $args{dbh}->prepare($sqlcode);
            $status = $csr->execute;
            for (my $i=1; $i<=$settings{sitecount}; $i++) {
                $sqlcode = "INSERT INTO $args{schema}.vendor_tax_permit (vendor,site,hastaxid,taxid,effectivedate) ";
                $sqlcode .= "VALUES ($id, $i, '" . $settings{"hastaxid$i"} . "', " . (($settings{"taxid$i"} gt " ") ? $args{dbh}->quote($settings{"taxid$i"}) : "NULL") . ", ";
                $sqlcode .= (($settings{"effectivedate$i"} gt " ") ? "TO_DATE('" . $settings{"effectivedate$i"} . "','MM/DD/YYYY')" : "NULL") . ")";
#print STDERR "\n$sqlcode\n\n";
                $args{dbh}->do($sqlcode);
            }
            my $classRef = $settings{classifications};
            my @classList = @$classRef;
            for (my $i=0; $i<=$#classList; $i++) {
                $args{dbh}->do("INSERT INTO $args{schema}.vendor_classification (vendor,classification) VALUES ($id, $classList[$i])");
            }
        } else {
            $status = (($settings{relatedto} > 0) ? 3 : $settings{vendorstatus});
            
            $sqlcode = "UPDATE $args{schema}.vendors SET ";
            $sqlcode .= "name = " . $args{dbh}->quote($settings{name}) . ", ";
            $sqlcode .= "address = " . $args{dbh}->quote($settings{address}) . ", ";
            $sqlcode .= "city = " . (($settings{city} gt " ") ? "'$settings{city}'" : "NULL") . ", ";
            $sqlcode .= "state = " . (($settings{state} gt " ") ? "'$settings{state}'" : "NULL") . ", ";
            $sqlcode .= "zip = " . (($settings{zip} gt " ") ? "'$settings{zip}'" : "NULL") . ", ";
            $sqlcode .= "country = " . (($settings{country} gt " ") ? "'$settings{country}'" : "NULL") . ", ";
            $sqlcode .= "remitaddress = " . (($settings{remitaddress} gt " ") ? $args{dbh}->quote($settings{remitaddress}) : "NULL") . ", ";
            $sqlcode .= "remitcity = " . (($settings{remitcity} gt " ") ? "'$settings{remitcity}'" : "NULL") . ", ";
            $sqlcode .= "remitstate = " . (($settings{remitstate} gt " ") ? "'$settings{remitstate}'" : "NULL") . ", ";
            $sqlcode .= "remitzip = " . (($settings{remitzip} gt " ") ? "'$settings{remitzip}'" : "NULL") . ", ";
            $sqlcode .= "pointofcontact = " . (($settings{pointofcontact} gt " ") ? $args{dbh}->quote($settings{pointofcontact}) : "NULL") . ", ";
            $sqlcode .= "phone = " . (($settings{phone} gt " ") ? "'$settings{phone}'" : "NULL") . ", ";
            $sqlcode .= "extension = " . (($settings{extension} gt " ") ? "'$settings{extension}'" : "NULL") . ", ";
            $sqlcode .= "fax = " . (($settings{fax} gt " ") ? "'$settings{fax}'" : "NULL") . ", ";
            $sqlcode .= "email = " . (($settings{email} gt " ") ? $args{dbh}->quote($settings{email}) : "NULL") . ", ";
            $sqlcode .= "url = " . (($settings{url} gt " ") ? $args{dbh}->quote($settings{url}) : "NULL") . ", ";
            $sqlcode .= "mainphone = " . (($settings{mainphone} gt " ") ? "'$settings{mainphone}'" : "NULL") . ", ";
            $sqlcode .= "mainproduct = " . (($settings{mainproduct} gt " ") ? $args{dbh}->quote($settings{mainproduct}) : "NULL") . ", ";
            $sqlcode .= "status = $status, ";
            $sqlcode .= "relatedto = " . (($settings{relatedto} gt 0) ? $settings{relatedto} : "NULL") . ", ";
            $sqlcode .= "relationship = " . (($settings{relationship} gt " ") ? $args{dbh}->quote($settings{relationship}) : "NULL") . " ";
            $sqlcode .= "WHERE id = $id";
            my $csr = $args{dbh}->prepare($sqlcode);
            $status = $csr->execute;
            
            $args{dbh}->do("DELETE FROM $args{schema}.vendor_tax_permit WHERE vendor=$id");
            for (my $i=1; $i<=$settings{sitecount}; $i++) {
                $sqlcode = "INSERT INTO $args{schema}.vendor_tax_permit (vendor,site,hastaxid,taxid,effectivedate) ";
                $sqlcode .= "VALUES ($id, $i, '" . $settings{"hastaxid$i"} . "', " . (($settings{"taxid$i"} gt " ") ? $args{dbh}->quote($settings{"taxid$i"}) : "NULL") . ", ";
                $sqlcode .= (($settings{"effectivedate$i"} gt " ") ? "TO_DATE('" . $settings{"effectivedate$i"} . "', 'MM/DD/YYYY')" : "NULL") . ")";
#print STDERR "\n$sqlcode\n\n";
                $args{dbh}->do($sqlcode);
            }
            
            $args{dbh}->do("DELETE FROM $args{schema}.vendor_classification WHERE vendor=$id");
            my $classRef = $settings{classifications};
            my @classList = @$classRef;
            for (my $i=0; $i<=$#classList; $i++) {
                $args{dbh}->do("INSERT INTO $args{schema}.vendor_classification (vendor,classification) VALUES ($id, $classList[$i])");
            }
        }
        
        if ($settings{comments} gt "") {
            $sqlcode = "INSERT INTO $args{schema}.vendor_comments (vendor, text, dateentered, enteredby) ";
            $sqlcode .= "VALUES ($id, :text, SYSDATE, $args{userID})";
            my $csr = $args{dbh}->prepare($sqlcode);
            $csr->bind_param (":text", $settings{comments}, {ora_type => ORA_CLOB, ora_field => 'text'});
            $csr->execute;
        }
        
        $args{dbh}->commit;

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$id);
}


1; #return true
