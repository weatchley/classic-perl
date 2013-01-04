# DB Category functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/DBCategories.pm,v $
#
# $Revision: 1.1 $
#
# $Date: 2004/12/02 18:43:17 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBCategories.pm,v $
# Revision 1.1  2004/12/02 18:43:17  atchleyb
# Initial revision
#
#
#
#
#
#

package DBCategories;
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
      &getCategoryList             &getCategory          &doProcessCategoryEntry
      &doProcessCategoryDelete
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getCategoryList             &getCategory          &doProcessCategoryEntry
      &doProcessCategoryDelete
    )]
);


###################################################################################################################################
sub getCategoryList {  # routine to get an array of categories
###################################################################################################################################
    my %args = (
        ID => 0,
        getCount => 'F',
        @_,
    );

    my $i = 0;
    my @categories;
    my $sqlcode = "SELECT id, text ";
    $sqlcode .= "FROM $args{schema}.categories WHERE id>0 ";
    $sqlcode .= (($args{ID} ne 0) ? "AND (id = $args{ID}) ": "");
    $sqlcode .= "ORDER BY text";
#print STDERR "\n$sqlcode\n";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($categories[$i]{id}, $categories[$i]{text}) = $csr->fetchrow_array) {
        if ($args{getCount} eq 'T') {
            ($categories[$i]{count}) = $args{dbh}->selectrow_array("SELECT COUNT(*) FROM $args{schema}.extraction_categories WHERE category=$categories[$i]{id}");
        } else {
            $categories[$i]{count} = 0;
        }
        $i++;
    }
    $csr->finish;

    return (@categories);
}


###################################################################################################################################
sub getCategory { # routine to get a category
###################################################################################################################################
    my %args = (
        ID => 0,
        @_,
    );
    my %category;
    my @categories = getCategoryList(dbh => $args{dbh}, schema => $args{schema}, ID => $args{ID});
    
    my $hashref = $categories[0];
    %category = %$hashref;
    
    return (%category);
}


###################################################################################################################################
sub doProcessCategoryEntry {  # routine to enter a new category or update a category
###################################################################################################################################
    my %args = (
        type => "",  # new or update
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    
    eval {
        if ($args{type} eq 'new') {
            $sqlcode = "INSERT INTO $args{schema}.categories (id, text) VALUES ($args{schema}.categories_id.NEXTVAL, ";
            $sqlcode .= $args{dbh}->quote($settings{text}) . ")";
#print STDERR "\n$sqlcode\n\n";
            $status = $args{dbh}->do($sqlcode);
        } else {
            $sqlcode = "UPDATE $args{schema}.categories SET text = " .$args{dbh}->quote($settings{text}) . " ";
            $sqlcode .= "WHERE id = $settings{categoryid}";
#print STDERR "\n$sqlcode\n\n";
            $status = $args{dbh}->do($sqlcode);
        }

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
sub doProcessCategoryDelete {  # routine to delete a category
###################################################################################################################################
    my %args = (
        type => "",  # new or update
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $sqlcode;
    my $status = 0;
    
    eval {
        $sqlcode = "DELETE FROM $args{schema}.categories WHERE id = $settings{id}";
#print STDERR "\n$sqlcode\n\n";
        $status = $args{dbh}->do($sqlcode);

    };
    if ($@) {
        my $errMessage = $@;
        $args{dbh}->rollback;
        die $errMessage;
    }

    return (1);
}


###################################################################################################################################
###################################################################################################################################


1; #return true
