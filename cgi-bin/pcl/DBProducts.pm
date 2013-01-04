#
# $Source: /data/dev/rcs/scm/perl/RCS/DBProducts.pm,v $
#
# $Revision: 1.3 $ 
#
# $Date: 2002/11/12 14:57:19 $
#
# $Author: starkeyj $
#
# $Locker: starkeyj $
#
# $Log: DBProducts.pm,v $
# Revision 1.3  2002/11/12 14:57:19  starkeyj
# added new functions to return product name(s) and associated product
#
# Revision 1.2  2002/10/09 18:36:29  starkeyj
# DB functions to browse products, product versions, and configuration items for a product version
#
# Revision 1.1  2002/09/27 00:14:32  starkeyj
# Initial revision
#
#
#
#
#
package DBProducts;
use strict;
use SCM_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_scm qw(:Functions);
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
      &doProcessCreateProduct   		&doProcessUpdateProduct     	&getCurrentProduct 
      &getProductList               &getProjectArray					&getVersion
      &getVersionList               &getProductVersion				&getProductName
      &getProductProject				&getProductNames
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doProcessCreateProduct   		&doProcessUpdateProduct			&getCurrentProduct
      &getProductList               &getProjectArray					&getVersion
      &getVersionList               &getProductVersion				&getProductName
      &getProductProject				&getProductNames
    )]
);


###################################################################################################################################
###################################################################################################################################

###################################################################################################################################
sub doProcessCreateProduct {  # routine to insert a new document into the DB
###################################################################################################################################
    my %args = (
        itemType => 0,
        project => 0,  # null
        title => 'Add',
        form => '',
        fileName => '',
        file => '',
        majorVersion => 0,
        minorVersion => 0,
        userID => 0,
        userName => '',
        @_,
    );

    my $output = "";
    my ($itemID) = $args{dbh}->selectrow_array("SELECT $args{schema}.config_item_seq.NEXTVAL FROM dual");
    my $fileContents = $args{file};
    my $name = $args{fileName};
    $name =~ s/\\/\//g;
    $name = substr($name,(rindex($name,'/')+1));
    my $description = $args{dbh}->quote($args{description});
    my $major = $args{majorVersion};
    my $minor = $args{minorVersion};

    my $sqlcode = "INSERT INTO $args{schema}.configuration_item (id, name, source_id, type_id, project_id, description) VALUES ";
    $sqlcode .= "($itemID,'$name',1,$args{itemType}," . (($args{project} == 0) ? "NULL" : $args{project}) . ",$description)";
    my $status = $args{dbh}->do($sqlcode);
    $sqlcode = "INSERT INTO $args{schema}.item_version (item_id,major_version,minor_version,version_date,status_id,developer_id, ";
    $sqlcode .= "change_description,item_image) VALUES ($itemID,$major,$minor,SYSDATE,1,$args{userID},'Initial Load', :document)";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->bind_param(":document", $fileContents, { ora_type => ORA_BLOB, ora_field=>'item_image' });
    $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_activity($args{dbh},$args{schema},$args{userID},"Document ID $itemID inserted");
    
    $output .= doAlertBox(text => "$name successfully inserted");
    $output .= "<script language=javascript><!--\n";
    $output .= "   changeMainLocation('utilities');\n";
    $output .= "//--></script>\n";
    
    return($output);
}


###################################################################################################################################
sub doProcessUpdateProduct {  # routine to insert a document update into the DB
###################################################################################################################################
    my %args = (
        itemID => 0,
        title => 'Add',
        form => '',
        fileName => '',
        file => '',
        majorVersion => 0,
        minorVersion => 0,
        description => '',
        userID => 0,
        userName => '',
        @_,
    );
    my $output = "";
    my $itemID = $args{itemID};
    my $fileContents = $args{file};
    my $name = $args{fileName};
    $name =~ s/\\/\//g;
    $name = substr($name,(rindex($name,'/')+1));
    my $description = $args{dbh}->quote($args{description});
    my $major = $args{majorVersion};
    my $minor = $args{minorVersion};

    my $status = $args{dbh}->do("UPDATE $args{schema}.item_version SET status_id = 3 WHERE item_id = $args{itemID}");
    my $sqlcode = "INSERT INTO $args{schema}.item_version (item_id,major_version,minor_version,version_date,status_id,developer_id, ";
    $sqlcode .= "change_description,item_image) VALUES ($itemID,$major,$minor,SYSDATE,1,$args{userID},$description, :document)";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->bind_param(":document", $fileContents, { ora_type => ORA_BLOB, ora_field=>'item_image' });
    $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_activity($args{dbh},$args{schema},$args{userID},"Document ID $args{itemID} updated");
    my ($project, $type) = $args{dbh}->selectrow_array("SELECT project_id, type_id FROM $args{schema}.configuration_item WHERE id=$args{itemID}");
    $output .= "<input type=hidden name=type value=$type>\n";
    $output .= "<input type=hidden name=project value=$project>\n" if (defined($project));
    $output .= doAlertBox(text => "$name successfully inserted/updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','update');\n";
    $output .= "//--></script>\n";
    
    return($output);
}

###################################################################################################################################
sub getProductList {  # routine to get a list of documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        itemType => 0,
        status => 0, # all
        @_,
    );
    my @docList;
    my $sqlcode = "SELECT prod.name, prod.project_id, proj.name ";
    $sqlcode .= "FROM $args{schema}.product prod, $args{schema}.project proj ";
    $sqlcode .= "WHERE prod.project_id = proj.id ";

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($docList[$i]{product},$docList[$i]{id},$docList[$i]{project}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@docList);
}



###################################################################################################################################
sub getCurrentProduct {  # routine to get a list of documents
###################################################################################################################################
    my %args = (
       project => 0,  # null
        @_,
    );
    my @product;
    my $sqlcode = "SELECT p.id, p.name, pv.major_version, pv.minor_version, to_char(pv.approve_date,'Mon DD, YYYY'), " .
            "to_char(pv.release_date,'Mon DD, YYYY'), pr.name, to_char(pv.creation_date,'Mon DD, YYYY'), " . 
            "u.firstname, u.lastname FROM $args{schema}.product_version pv, " .
            "$args{schema}.product p, $args{schema}.project pr, $args{schema}.users u  ".
            "WHERE pv.product_id = p.id AND pr.id = p.project_id AND u.id = pv.released_by " .
            "AND (product_id, minor_version) in (SELECT product_id, max(minor_version) " .
            "from $args{schema}.product_version GROUP BY product_id) " .
            "order by product_id ";

	 my $csr = $args{dbh}->prepare($sqlcode);
	 my $status = $csr->execute;
	 my $count = 0;

	 my $i = 0;
	 while (($product[$i]{product_id},$product[$i]{product},$product[$i]{maj},$product[$i]{minorver},
	 $product[$i]{approved},$product[$i]{released},$product[$i]{project},$product[$i]{created},
	 $product[$i]{firstname},$product[$i]{lastname}) = $csr->fetchrow_array) {
		  $i++;
	 }

    
    return (@product);
}


###################################################################################################################################
sub getVersionList {  # routine to get a list of versions of a document
###################################################################################################################################
    my %args = (
        product => 0,
        @_,
    );
       
    my @versionList;
    my $sqlcode = "SELECT pr.name, p.name, pv.major_version, pv.minor_version, to_char(pv.approve_date,'Mon DD, YYYY'), ";
    $sqlcode .= "to_char(pv.release_date,'Mon DD, YYYY'), to_char(pv.creation_date,'Mon DD, YYYY'), ";
    $sqlcode .= "u.firstname, u.lastname ";
    $sqlcode .= "FROM $args{schema}.product_version pv, $args{schema}.product p, ";
    $sqlcode .= "$args{schema}.project pr, $args{schema}.users u ";
    $sqlcode .= "WHERE pv.product_id = p.id AND p.project_id = pr.id AND u.id = pv.released_by ";
    $sqlcode .= "AND p.id = $args{product} ";
    $sqlcode .= "ORDER BY pv.major_version DESC, pv.minor_version DESC";

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($versionList[$i]{projectname},$versionList[$i]{product},$versionList[$i]{major},$versionList[$i]{minor},
    $versionList[$i]{approved},$versionList[$i]{released},$versionList[$i]{created},
    $versionList[$i]{firstname},$versionList[$i]{lastname}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@versionList);
}

###################################################################################################################################
sub getVersion {  # routine to get a list of versions of a document
###################################################################################################################################
    my %args = (
        product => 0,
        majorversion => 1,
        minorversion => 1,
        @_,
    );
       
    my @version;
    my $sqlcode = "SELECT to_char(pv.creation_date,'Mon DD, YYYY'), to_char(pv.approve_date,'Mon DD, YYYY'), ";
    $sqlcode .= "to_char(pv.release_date,'Mon DD, YYYY'), firstname, lastname ";
    $sqlcode .= "FROM $args{schema}.product_version pv, $args{schema}.users u ";
    $sqlcode .= "WHERE pv.product_id = $args{product} AND pv.minor_version = $args{minorversion} ";
    $sqlcode .= "AND pv.released_by = u.id ";

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($version[$i]{created},$version[$i]{approved},$version[$i]{released},
    $version[$i]{firstname},$version[$i]{lastname}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@version);
}
###################################################################################################################################
sub getProductVersion {  # routine to get all info for a version of a document
###################################################################################################################################
    my %args = (
        product => 0,
        majorversion => 1,
        minorversion => 1,
        @_,
    );
    my @productItems;
    my $sqlcode = "SELECT bpi.item_id, bpi.item_major_version, bpi.item_minor_version, ci.name, ";
    $sqlcode .= "p.name, iv.scr, to_char(iv.approval_date,'Mon DD, YYYY') ";
    $sqlcode .= "FROM $args{schema}.baseline_product_item bpi, $args{schema}.product p, ";
    $sqlcode .= "$args{schema}.configuration_item ci, $args{schema}.item_version iv ";
    $sqlcode .= "WHERE ci.id = bpi.item_id AND bpi.product_id = p.id AND bpi.item_id = iv.item_id AND bpi.item_major_version = iv.major_version ";
    $sqlcode .= "AND bpi.item_minor_version = iv.minor_version ";
    $sqlcode .= "AND bpi.product_id = $args{product} AND bpi.product_major_version = $args{majorversion} ";
    $sqlcode .= "AND bpi.product_minor_version in($args{minorversion},$args{minorversion}-1) ";
    $sqlcode .= "GROUP BY bpi.item_id, bpi.item_major_version, bpi.item_minor_version,ci.name,p.name,iv.scr,iv.approval_date ";
    $sqlcode .= "ORDER BY upper(ci.name), bpi.item_major_version DESC, bpi.item_minor_version DESC";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($productItems[$i]{itemid},$productItems[$i]{itemmajor},$productItems[$i]{itemminor},
    $productItems[$i]{itemname},$productItems[$i]{productname},$productItems[$i]{scr},
    $productItems[$i]{approvaldate}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@productItems);
}

###################################################################################################################################
sub getProjectArray {  # routine to get a list of projects
###################################################################################################################################
    my %args = (
        selection => "",
        authorized => 'F',
        userID => 0,
        @_,
    );
    my @itemList;
    my $sqlcode = "SELECT id, name, acronym,description, creation_date, project_manager_id,created_by, requirements_manager_id, configuration_manager_id FROM $args{schema}.project ";
    $sqlcode .= (($args{selection} ne "" || $args{authorized} eq 'T') ? "WHERE 1=1" : "");
    $sqlcode .= (($args{selection} ne "") ? " AND ($args{selection}) " : ""); 
    $sqlcode .= (($args{authorized} eq "T") ? " AND (project_manager_id=$args{userID} OR requirements_manager_id=$args{userID} OR configuration_manager_id=$args{userID}) " : "");
    $sqlcode .= " ORDER BY name";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($itemList[$i]{id},$itemList[$i]{name},$itemList[$i]{acronym},$itemList[$i]{description},$itemList[$i]{creation_date},
            $itemList[$i]{project_manager_id},$itemList[$i]{created_by},$itemList[$i]{requirements_manager_id},
            $itemList[$i]{configuration_manager_id}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@itemList);
}

###################################################################################################################################
sub getProductName {                                                                                                              #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $name = $args{dbh}->selectrow_array("select name from $args{schema}.product where id = $args{id}");
   return ($name);
}

###################################################################################################################################
sub getProductProject {                                                                                                           #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $project= $args{dbh}->selectrow_array("select project_id from $args{schema}.product where id = $args{id}");
   return ($project);
}

###################################################################################################################################
sub getProductNames {                                                                                                             #
###################################################################################################################################
   my %args = (
      orderBy => 'name',
      @_,
   );
   tie my %productNames, "Tie::IxHash";
   my $csr = $args{dbh}->prepare ("select id, name from $args{schema}.product $args{where} order by $args{orderBy}");
   $csr->execute;
   while (my ($id, $name) = $csr->fetchrow_array) {
      $productNames{$id} = $name;
   }
   $csr->finish;
   return (\%productNames);
}

###################################################################################################################################
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

