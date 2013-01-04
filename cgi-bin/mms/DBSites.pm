# DB Sites functions
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/mms/perl/RCS/DBSites.pm,v $
#
# $Revision: 1.3 $
#
# $Date: 2009/07/31 22:43:26 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBSites.pm,v $
# Revision 1.3  2009/07/31 22:43:26  atchleyb
# Updates related to ACR0907_004-SWR0149   New intermediate buyer role, minor bug fixes
#
# Revision 1.2  2008/02/11 18:20:29  atchleyb
# SCR000037 - Updates related to change request, see change request for details
#
# Revision 1.1  2004/01/12 20:17:19  atchleyb
# Initial revision
#
#
#
#
#
#

package DBSites;
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
      &getSiteInfo     &doProcessSiteEntry
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getSiteInfo     &doProcessSiteEntry
    )]
);


###################################################################################################################################
sub getSiteInfo {  # routine to get a hash of site info
###################################################################################################################################
    my %args = (
        id => 0,
        @_,
    );

    my $i = 0;
    my %siteInfo;
    my $sqlcode = "SELECT id, name, shortname, longname, companycode, organization, address, city, state, zip, daddress, dcity, dstate, dzip, ";
    $sqlcode .= "phone, fax, contractnumber, salestax, taxexempt, sitecode, trackfunding FROM $args{schema}.site_info WHERE id=$args{id}";
    ($siteInfo{id}, $siteInfo{name}, $siteInfo{shortname}, $siteInfo{longname}, $siteInfo{companycode}, $siteInfo{organization}, 
               $siteInfo{address}, $siteInfo{city}, $siteInfo{state}, $siteInfo{zip}, 
               $siteInfo{daddress}, $siteInfo{dcity}, $siteInfo{dstate}, $siteInfo{dzip}, 
               $siteInfo{phone}, $siteInfo{fax}, $siteInfo{contractnumber}, 
               $siteInfo{salestax}, $siteInfo{taxexempt}, $siteInfo{sitecode}, $siteInfo{trackfunding}) 
            = $args{dbh}->selectrow_array($sqlcode);

    return (%siteInfo);
}


###################################################################################################################################
sub doProcessSiteEntry {  # routine to enter a new site or update a site
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
        if ($args{type} eq 'new') {
            ($id) = $args{dbh}->selectrow_array("SELECT MAX(id) FROM $args{schema}.site_info");
            $id++;
        } else {
            $id = $settings{siteid};
        }
        $settings{phone} =~ s/[() \-]//g;
        $settings{fax} =~ s/[() \-]//g;
        $settings{shortname} = uc($settings{shortname});
        $settings{companycode} = uc($settings{companycode});
        $settings{sitecode} = uc($settings{sitecode});
        if ($args{type} eq 'new') {
            $sqlcode = "INSERT INTO $args{schema}.site_info (id, name, shortname, longname, companycode, organization,";
            $sqlcode .= "address, city, state, zip, daddress, dcity, dstate, dzip, phone, fax,";
            $sqlcode .= "contractnumber, salestax, taxexempt, sitecode, trackfunding) VALUES ";
            $sqlcode .= "($id, " . $args{dbh}->quote($settings{name}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{shortname}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{longname}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{companycode}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{organization}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{address}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{city}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{state}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{zip}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{daddress}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{dcity}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{dstate}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{dzip}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{phone}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{fax}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{contractnumber}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{salestax}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{taxexempt}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{sitecode}) . ", ";
            $sqlcode .= $args{dbh}->quote($settings{trackfunding}) . ")";
            
#print STDERR "\n$sqlcode\n\n";
            $args{dbh}->do($sqlcode);
            $sqlcode = "INSERT INTO $args{schema}.ec_site (ec, site, taxable) (SELECT ec, $id, taxable FROM $args{schema}.ec_site WHERE site=" . ($id - 1) . ")";
            $args{dbh}->do($sqlcode);
            $sqlcode = "INSERT INTO $args{schema}.rules (id, name, type, site, nvalue1, nvalue2, cvalue1, cvalue2) (SELECT $args{schema}.rules_id.NEXTVAL, name, " 
                  . "type, $id, nvalue1, nvalue2, cvalue1, cvalue2 FROM $args{schema}.rules WHERE site=" . ($id - 1) . ")";
            $args{dbh}->do($sqlcode);
        } else {
            $sqlcode = "UPDATE $args{schema}.site_info SET name = " .$args{dbh}->quote($settings{name}) . ", ";
            $sqlcode .= "shortname = " . $args{dbh}->quote($settings{shortname}) . ", ";
            $sqlcode .= "longname = " . $args{dbh}->quote($settings{longname}) . ", ";
            $sqlcode .= "companycode = " . $args{dbh}->quote($settings{companycode}) . ", ";
            $sqlcode .= "organization = " . $args{dbh}->quote($settings{organization}) . ", ";
            $sqlcode .= "address = " . $args{dbh}->quote($settings{address}) . ", ";
            $sqlcode .= "city = " . $args{dbh}->quote($settings{city}) . ", ";
            $sqlcode .= "state = " . $args{dbh}->quote($settings{state}) . ", ";
            $sqlcode .= "zip = " . $args{dbh}->quote($settings{zip}) . ", ";
            $sqlcode .= "daddress = " . $args{dbh}->quote($settings{daddress}) . ", ";
            $sqlcode .= "dcity = " . $args{dbh}->quote($settings{dcity}) . ", ";
            $sqlcode .= "dstate = " . $args{dbh}->quote($settings{dstate}) . ", ";
            $sqlcode .= "dzip = " . $args{dbh}->quote($settings{dzip}) . ", ";
            $sqlcode .= "phone = " . $args{dbh}->quote($settings{phone}) . ", ";
            $sqlcode .= "fax = " . $args{dbh}->quote($settings{fax}) . ", ";
            $sqlcode .= "contractnumber = " . $args{dbh}->quote($settings{contractnumber}) . ", ";
            $sqlcode .= "salestax = " . $args{dbh}->quote($settings{salestax}) . ", ";
            $sqlcode .= "taxexempt = " . $args{dbh}->quote($settings{taxexempt}) . ", ";
            $sqlcode .= "sitecode = " . $args{dbh}->quote($settings{sitecode}) . ", ";
            $sqlcode .= "trackfunding = " . $args{dbh}->quote($settings{trackfunding}) . " ";
            $sqlcode .= "WHERE id = $id";
#print STDERR "\n$sqlcode\n\n";
            $args{dbh}->do($sqlcode);
        }

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1,$id);
}


1; #return true
