# DB search functions for the SCM
#
# $Source: /data/dev/rcs/pcl/perl/RCS/DBSearch.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2003/02/03 20:09:12 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBSearch.pm,v $
# Revision 1.2  2003/02/03 20:09:12  atchleyb
# removed refs to SCM
#
# Revision 1.1  2002/11/27 21:06:45  atchleyb
# Initial revision
#
#
#
#

package DBSearch;
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
    &searchSCRDescription           &searchSCRRationale             &searchSCRRejectionRationale
    &searchSCRRemarks               &searchSCRActionsTaken          &searchProcedureDescription
    &searchProcedureVersion         &searchTemplateDescription      &searchTemplateVersion
    &searchConfigItemDescription    &searchConfigItemVersion        &searchProjectDescription
    &searchProductDescription       &searchProcedureVersionContent  &searchTemplateVersionContent
    &searchConfigItemVersionContent
    );
%EXPORT_TAGS =( 
    Functions => [qw(
    &searchSCRDescription           &searchSCRRationale             &searchSCRRejectionRationale
    &searchSCRRemarks               &searchSCRActionsTaken          &searchProcedureDescription
    &searchProcedureVersion         &searchTemplateDescription      &searchTemplateVersion
    &searchConfigItemDescription    &searchConfigItemVersion        &searchProjectDescription
    &searchProductDescription       &searchProcedureVersionContent  &searchTemplateVersionContent
    &searchConfigItemVersionContent
    )]
);


###################################################################################################################################
sub matchFound {                                                                                                                  #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out;
   if (defined($args{text})) {
       if ($args{case} gt "") {
          $out = ($args{text} =~ m/$args{searchString}/) ? 1 : 0;
       } else {
          $out = ($args{text} =~ m/$args{searchString}/i) ? 1 : 0;
       }
   } else {
       $out = 0;
   }
   return ($out);
}


###################################################################################################################################
# routine to search SCR descriptions
sub searchSCRDescription {
###################################################################################################################################
    my %args = (
        project => 0,
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $whereClause = "";
    if ($args{project} != 0) {
        my ($product) = $args{dbh}->selectrow_array("SELECT id FROM $args{schema}.product WHERE project_id=$args{project}");
        $whereClause = "WHERE product=$product";
    }
    
    my $sql = "SELECT id, description, product FROM $args{schema}.scrrequest $whereClause ORDER BY product, id";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $text, $product) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $text;
            $resultArray[$rows][2] = $product;
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search SCR rationale
sub searchSCRRationale {
###################################################################################################################################
    my %args = (
        project => 0,
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $whereClause = "";
    if ($args{project} != 0) {
        my ($product) = $args{dbh}->selectrow_array("SELECT id FROM $args{schema}.product WHERE project_id=$args{project}");
        $whereClause = "WHERE product=$product";
    }
    
    my $sql = "SELECT id, rationale, product FROM $args{schema}.scrrequest $whereClause ORDER BY product, id";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $text, $product) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $text;
            $resultArray[$rows][2] = $product;
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search SCR actions taken
sub searchSCRActionsTaken {
###################################################################################################################################
    my %args = (
        project => 0,
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $whereClause = "";
    if ($args{project} != 0) {
        my ($product) = $args{dbh}->selectrow_array("SELECT id FROM $args{schema}.product WHERE project_id=$args{project}");
        $whereClause = "WHERE product=$product";
    }
    
    my $sql = "SELECT id, actionstaken, product FROM $args{schema}.scrrequest $whereClause ORDER BY product, id";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $text, $product) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $text;
            $resultArray[$rows][2] = $product;
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search SCR rejection rationale
sub searchSCRRejectionRationale {
###################################################################################################################################
    my %args = (
        project => 0,
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $whereClause = "";
    if ($args{project} != 0) {
        my ($product) = $args{dbh}->selectrow_array("SELECT id FROM $args{schema}.product WHERE project_id=$args{project}");
        $whereClause = "WHERE product=$product";
    }
    
    my $sql = "SELECT id, rejectionrationale, product FROM $args{schema}.scrrequest $whereClause ORDER BY product, id";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $text, $product) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $text;
            $resultArray[$rows][2] = $product;
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search SCR remarks
sub searchSCRRemarks {
###################################################################################################################################
    my %args = (
        project => 0,
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $whereClause = "";
    if ($args{project} != 0) {
        my ($product) = $args{dbh}->selectrow_array("SELECT id FROM $args{schema}.product WHERE project_id=$args{project}");
        $whereClause = "WHERE product=$product";
    }
    
    my $sql = "SELECT requestid, text, product FROM $args{schema}.scrremarks $whereClause ORDER BY product, requestid, dateentered";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $text, $product) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $text;
            $resultArray[$rows][2] = $product;
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search procedure descriptions
sub searchProcedureDescription {
###################################################################################################################################
    my %args = (
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $sql = "SELECT id, name, description FROM $args{schema}.procedure ORDER BY name";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $name, $text) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $name;
            $resultArray[$rows][2] = $text;
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search procedure change descriptions
sub searchProcedureVersion {
###################################################################################################################################
    my %args = (
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $sql = "SELECT p.id, p.name, v.major_version, v.minor_version, v.change_description ";
    $sql .= "FROM $args{schema}.procedure_version v, $args{schema}.procedure p ";
    $sql .= "WHERE p.id=v.procedureid ORDER BY p.name, v.major_version DESC, v.minor_version DESC";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $name, $major, $minor, $text) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $name;
            $resultArray[$rows][2] = $text;
            $resultArray[$rows][3] = (($major == 0) ? "Draft " : "$major.") . "$minor";
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search procedure contents
sub searchProcedureVersionContent {
###################################################################################################################################
    my %args = (
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $sql = "SELECT p.id, p.name, v.major_version, v.minor_version, v.item_image ";
    $sql .= "FROM $args{schema}.procedure_version v, $args{schema}.procedure p ";
    $sql .= "WHERE p.id=v.procedureid ORDER BY p.name, v.major_version DESC, v.minor_version DESC";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $name, $major, $minor, $text) = $csr->fetchrow_array) {
        $text =~ s/[^(\w|\s)]//g;
        $text =~ s/\s/ /g;
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $name;
            $resultArray[$rows][2] = "Preview Not Available";#$text;
            $resultArray[$rows][3] = (($major == 0) ? "Draft " : "$major.") . "$minor";
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search template descriptions
sub searchTemplateDescription {
###################################################################################################################################
    my %args = (
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $sql = "SELECT id, name, description FROM $args{schema}.template ORDER BY name";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $name, $text) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $name;
            $resultArray[$rows][2] = $text;
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search template change descriptions
sub searchTemplateVersion {
###################################################################################################################################
    my %args = (
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $sql = "SELECT p.id, p.name, v.major_version, v.minor_version, v.change_description ";
    $sql .= "FROM $args{schema}.template_version v, $args{schema}.template p ";
    $sql .= "WHERE p.id=v.templateid ORDER BY p.name, v.major_version DESC, v.minor_version DESC";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $name, $major, $minor, $text) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $name;
            $resultArray[$rows][2] = $text;
            $resultArray[$rows][3] = (($major == 0) ? "Draft " : "$major.") . "$minor";
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search template contents
sub searchTemplateVersionContent {
###################################################################################################################################
    my %args = (
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $sql = "SELECT p.id, p.name, v.major_version, v.minor_version, v.item_image ";
    $sql .= "FROM $args{schema}.template_version v, $args{schema}.template p ";
    $sql .= "WHERE p.id=v.templateid ORDER BY p.name, v.major_version DESC, v.minor_version DESC";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $name, $major, $minor, $text) = $csr->fetchrow_array) {
        $text =~ s/[^(\w|\s)]//g;
        $text =~ s/\s/ /g;
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $name;
            $resultArray[$rows][2] = "Preview Not Available";#$text;
            $resultArray[$rows][3] = (($major == 0) ? "Draft " : "$major.") . "$minor";
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search config item descriptions
sub searchConfigItemDescription {
###################################################################################################################################
    my %args = (
        project => 0,
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $whereClause = "";
    if ($args{project} != 0) {
        $whereClause = "AND project_id=$args{project}";
    }
    
    my $sql = "SELECT id, name, description, project_id FROM $args{schema}.configuration_item ";
    $sql .= "WHERE type_id>6 $whereClause ORDER BY name";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $name, $text, $project) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $name;
            $resultArray[$rows][2] = $text;
            ($resultArray[$rows][3]) = $args{dbh}->selectrow_array("SELECT acronym FROM $args{schema}.project WHERE id=$project");
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search config item change descriptions
sub searchConfigItemVersion {
###################################################################################################################################
    my %args = (
        project => 0,
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $whereClause = "";
    if ($args{project} != 0) {
        $whereClause = "AND p.project_id=$args{project}";
    }
    
    my $sql = "SELECT p.id, p.name, v.major_version, v.minor_version, v.change_description, p.project_id ";
    $sql .= "FROM $args{schema}.item_version v, $args{schema}.configuration_item p ";
    $sql .= "WHERE p.id=v.item_id AND p.type_id>6 $whereClause ORDER BY p.name, v.major_version DESC, v.minor_version DESC";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $name, $major, $minor, $text, $project) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $name;
            $resultArray[$rows][2] = $text;
            $resultArray[$rows][3] = (($major == 0) ? "Draft " : "$major.") . "$minor";
            ($resultArray[$rows][4]) = $args{dbh}->selectrow_array("SELECT acronym FROM $args{schema}.project WHERE id=$project");
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search config item contents
sub searchConfigItemVersionContent {
###################################################################################################################################
    my %args = (
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $whereClause = "";
    if ($args{project} != 0) {
        $whereClause = "AND p.project_id=$args{project}";
    }
    
    my $sql = "SELECT p.id, p.name, v.major_version, v.minor_version, v.item_image, p.project_id ";
    $sql .= "FROM $args{schema}.item_version v, $args{schema}.configuration_item p ";
    $sql .= "WHERE p.id=v.item_id AND p.type_id>6 $whereClause ORDER BY p.name, v.major_version DESC, v.minor_version DESC";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $name, $major, $minor, $text, $project) = $csr->fetchrow_array) {
        $text =~ s/[^(\w|\s)]//g;
        $text =~ s/\s/ /g;
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $name;
            $resultArray[$rows][2] = "Preview Not Available";#$text;
            $resultArray[$rows][3] = (($major == 0) ? "Draft " : "$major.") . "$minor";
            ($resultArray[$rows][4]) = $args{dbh}->selectrow_array("SELECT acronym FROM $args{schema}.project WHERE id=$project");
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search project descriptions
sub searchProjectDescription {
###################################################################################################################################
    my %args = (
        project => 0,
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $whereClause = "";
    if ($args{project} != 0) {
        $whereClause = "WHERE id=$args{project}";
    }
    
    my $sql = "SELECT id, name, description FROM $args{schema}.project $whereClause ORDER BY name";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $name, $text) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $name;
            $resultArray[$rows][2] = $text;
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
# routine to search product descriptions
sub searchProductDescription {
###################################################################################################################################
    my %args = (
        project => 0,
        @_,
    );
    my $rows = 0;
    my @resultArray;
    $args{dbh}->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
    $args{dbh}->{LongReadLen} = 100000000;
    
    my $whereClause = "";
    if ($args{project} != 0) {
        $whereClause = "WHERE id=$args{project}";
    }
    
    my $sql = "SELECT id, name, description FROM $args{schema}.product $whereClause ORDER BY name";
    my $csr = $args{dbh}->prepare($sql);
    $csr->execute;
    while (my ($id, $name, $text) = $csr->fetchrow_array) {
        if (&matchFound(text => $text, searchString => $args{searchString}, case => $args{case})) {
            $resultArray[$rows][0] = $id;
            $resultArray[$rows][1] = $name;
            $resultArray[$rows][2] = $text;
            $rows++;
        }
    }
    $csr->finish;
    return ($rows, @resultArray);
}


###################################################################################################################################
###################################################################################################################################




1; #return true
