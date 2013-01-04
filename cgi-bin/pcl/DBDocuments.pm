#
# $Source: /data/dev/rcs/pcl/perl/RCS/DBDocuments.pm,v $
#
# $Revision: 1.9 $ 
#
# $Date: 2003/02/10 18:16:38 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBDocuments.pm,v $
# Revision 1.9  2003/02/10 18:16:38  atchleyb
# removed regs to PCL
#
# Revision 1.8  2003/01/03 18:06:35  atchleyb
# updates date format and makes it a parameter
#
# Revision 1.7  2002/11/08 20:28:48  atchleyb
# updated calling format for doesUserHavePriv
#
# Revision 1.6  2002/11/06 21:44:35  atchleyb
# updated to allow check in from the home page
#
# Revision 1.5  2002/10/31 21:53:08  atchleyb
# updated function getProjectArray to allow a project id to be specified
#
# Revision 1.4  2002/10/31 17:29:52  atchleyb
# updated comments for policies
#
# Revision 1.3  2002/10/24 21:54:09  atchleyb
# updated to handle different itemid column names in different tables
# updated to handle policies
#
# Revision 1.2  2002/10/18 17:03:13  atchleyb
# updated to allow procedures and templates to be in different table sets
#
# Revision 1.1  2002/09/26 21:05:40  atchleyb
# Initial revision
#
#
#
#
#
package DBDocuments;
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
#use vars qw ();
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &doProcessAddDocument         &selectTitle
      &doProcessUpdateDocument      &doCheckOutDocumentDB
      &doProcessUpdateDocumentInfo  &doProcessCheckInNoChange
      &getDocumentList              &getMimeType
      &getItemTypeArray             &getProjectArray
      &getVersionList               &getDocumentVersion
      &getConfigurationItem         &hasSignedImage
      &setDBTables
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doProcessAddDocument         &selectTitle
      &doProcessUpdateDocument      &doCheckOutDocumentDB
      &doProcessUpdateDocumentInfo  &doProcessCheckInNoChange
      &getDocumentList              &getMimeType
      &getItemTypeArray             &getProjectArray
      &getVersionList               &getDocumentVersion
      &getConfigurationItem         &hasSignedImage
      &setDBTables
    )]
);


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub setDBTables {  # routine to select tables for use with type
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;

    if ($settings{itemType} == 10) {  # Procedure
        $settings{itemTable} = "procedure";
        $settings{versionTable} = "procedure_version";
        $settings{itemSeq} = "procedure_id";
        $settings{versionSeq} = "procedure_version_id";
        $settings{itemIDCol} = "procedureid";
    } elsif ($settings{itemType} == 11) {  # template
        $settings{itemTable} = "template";
        $settings{versionTable} = "template_version";
        $settings{itemSeq} = "template_id";
        $settings{versionSeq} = "template_version_id";
        $settings{itemIDCol} = "templateid";
    } elsif ($settings{itemType} == 12) {  # policy
        $settings{itemTable} = "policy";
        $settings{versionTable} = "policy_version";
        $settings{itemSeq} = "policy_id";
        $settings{versionSeq} = "policy_version_id";
        $settings{itemIDCol} = "policyid";
    } else {  # other
        $settings{itemTable} = "configuration_item";
        $settings{versionTable} = "item_version";
        $settings{itemSeq} = "config_item_seq";
        $settings{versionSeq} = "item_version_seq";
        $settings{itemIDCol} = "item_id";
    }

    return (%settings);
}


###################################################################################################################################
sub selectTitle {  # routine to select title for use in funcitons
###################################################################################################################################
    my %args = (
        itemType => 0,
        @_,
    );
    my $output = "";
    if ($args{itemType} >= 10 && $args{itemType} <= 12) {
        ($output) = $args{dbh}->selectrow_array("SELECT type FROM $args{schema}.item_type WHERE id=$args{itemType}");
    } else {
        $output = "Configuration Item";
    }

    return ($output);
}


###################################################################################################################################
sub doProcessAddDocument {  # routine to insert a new document into the DB
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

    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my ($itemID) = $args{dbh}->selectrow_array("SELECT $args{schema}.$settings{itemSeq}.NEXTVAL FROM dual");
    my $fileContents = $args{file};
    my $name = $args{fileName};
    $name =~ s/\\/\//g;
    $name = substr($name,(rindex($name,'/')+1));
    my $description = $args{dbh}->quote($args{description});
    my $major = $args{majorVersion};
    my $minor = $args{minorVersion};

    my $sqlcode = "INSERT INTO $args{schema}.$settings{itemTable} (id, name, ";
    $sqlcode .= (($settings{itemType} <10 || $settings{itemType} >12) ? "source_id, type_id, project_id, " : "") . "description) VALUES ";
    $sqlcode .= "($itemID,'$name'";
    $sqlcode .= (($settings{itemType} <10 || $settings{itemType} >12) ? ",1,$args{itemType}," . (($args{project} == 0) ? "NULL" : $args{project}) : "") . ",$description)";
    my $status = $args{dbh}->do($sqlcode);
    my ($versionID) = $args{dbh}->selectrow_array("SELECT $args{schema}.$settings{versionSeq}.NEXTVAL FROM dual");
    $sqlcode = "INSERT INTO $args{schema}.$settings{versionTable} (id,$settings{itemIDCol},major_version,minor_version,version_date,status_id,developer_id, ";
    $sqlcode .= "change_description,item_image) VALUES ($versionID,$itemID,$major,$minor,SYSDATE,1,$args{userID},'Initial Load', :document)";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->bind_param(":document", $fileContents, { ora_type => ORA_BLOB, ora_field=>'item_image' });
    $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_activity($args{dbh},$args{schema},$args{userID},"Document ID $itemID inserted");
    
    return(1);
}


###################################################################################################################################
sub doCheckOutDocumentDB {  # routine to check out a document for update
###################################################################################################################################
    my %args = (
        document => 0,
        majorVersion => 0,
        minorVersion => 0,
        userID => 0,
        form => '',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    
    my $sqlcode = "UPDATE $args{schema}.$settings{versionTable} SET status_id=2, locker_id=$args{userID} WHERE id=$args{document}";
    my $status = $args{dbh}->do($sqlcode);
    $args{dbh}->commit;
    &log_activity($args{dbh},$args{schema},$args{userID},"Document ID $args{document} checked out");

    my ($project, $type) = (0, $settings{itemType});
    if ($settings{itemType} <10 || $settings{itemType} >12) {
        ($project, $type) = $args{dbh}->selectrow_array("SELECT c.project_id, c.type_id FROM $args{schema}.$settings{itemTable} c,$args{schema}. $settings{versionTable} v WHERE c.id=v.$settings{itemIDCol} AND v.id=$args{document}");
    }
    
    return(1, $project, $type);
}


###################################################################################################################################
sub doProcessUpdateDocumentInfo {  # routine to update document information
###################################################################################################################################
    my %args = (
        document => 0,
        name => '',
        description => '',
        userID => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $description = $args{dbh}->quote($args{description});
    
    my $sqlcode = "UPDATE $args{schema}.$settings{itemTable} SET name='$args{name}', description=$description WHERE id=$args{document}";
    my $status = $args{dbh}->do($sqlcode);
    $args{dbh}->commit;
    &log_activity($args{dbh},$args{schema},$args{userID},"Information for Document ID $args{document} updated");

    my ($project, $type) = (0,$settings{itemType});
    if ($settings{itemType} < 10 || $settings{itemType} > 12) {
        ($project, $type) = $args{dbh}->selectrow_array("SELECT project_id, type_id FROM $args{schema}.$settings{itemTable} WHERE id=$args{document}");
    }
    
    return(1,$project, $type);
}


###################################################################################################################################
sub doProcessUpdateDocument {  # routine to insert a document update into the DB
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
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $itemID = $args{itemID};
    my $fileContents = $args{file};
    my $name = $args{fileName};
    $name =~ s/\\/\//g;
    $name = substr($name,(rindex($name,'/')+1));
    my $description = $args{dbh}->quote($args{description});
    my $major = $args{majorVersion};
    my $minor = $args{minorVersion};

    my $status = $args{dbh}->do("UPDATE $args{schema}.$settings{versionTable} SET status_id = 3 WHERE $settings{itemIDCol} = $args{itemID}");
    my ($newID) = $args{dbh}->selectrow_array("SELECT $args{schema}.$settings{versionSeq}.NEXTVAL FROM dual");
    my $sqlcode = "INSERT INTO $args{schema}.$settings{versionTable} (id, $settings{itemIDCol},major_version,minor_version,version_date,status_id,developer_id, ";
    $sqlcode .= "change_description,item_image) VALUES ($newID,$itemID,$major,$minor,SYSDATE,1,$args{userID},$description, :document)";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->bind_param(":document", $fileContents, { ora_type => ORA_BLOB, ora_field=>'item_image' });
    $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_activity($args{dbh},$args{schema},$args{userID},"Document ID $args{itemID} updated");
    my ($project, $type) = (0,$settings{itemType});
    if ($settings{itemType} < 10 || $settings{itemType} > 12) {
        ($project, $type) = $args{dbh}->selectrow_array("SELECT project_id, type_id FROM $args{schema}.$settings{itemTable} WHERE id=$args{itemID}");
    }
    
    return(1,$project, $type);
}


###################################################################################################################################
sub doProcessCheckInNoChange {  # routine to checkin a document with no change
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
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $itemID = $args{itemID};
    my $fileContents = $args{file};
    my $name = $args{fileName};
    $name =~ s/\\/\//g;
    $name = substr($name,(rindex($name,'/')+1));
    my $description = $args{description};
    my $major = $args{majorVersion};
    my $minor = $args{minorVersion};

    my $status = $args{dbh}->do("UPDATE $args{schema}.$settings{versionTable} SET status_id = 1 WHERE $settings{itemIDCol} = $args{itemID} AND status_id = 2");
    $args{dbh}->commit;
    &log_activity($args{dbh},$args{schema},$args{userID},"Document ID $args{itemID} checked in with no change");
    
    my ($project, $type) = (0,$settings{itemType});
    if ($settings{itemType} < 10 || $settings{itemType} > 12) {
        ($project, $type) = $args{dbh}->selectrow_array("SELECT project_id, type_id FROM $args{schema}.$settings{itemTable} WHERE id=$args{itemID}");
    }
    
    return(1,$project, $type);
}


###################################################################################################################################
sub getDocumentList {  # routine to get a list of documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        itemType => 0,
        status => 0, # all
        document => 0, # all
        nonCode => 'F',
        userID => 0, # all
        dateFormat => 'dd-MON-yy hh:mi AM',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my @docList;
    my $sqlcode = "SELECT c.id,c.name," . (($args{itemType} < 10 || $args{itemType} > 12) ? "c.project_id," : "0,") . "c.description,";
    $sqlcode .= (($args{itemType} < 10 || $args{itemType} > 12) ? "c.type_id," : "$args{itemType},");
    $sqlcode .= "v.id,v.major_version,v.minor_version,TO_CHAR(v.version_date,'$args{dateFormat}'),";
    $sqlcode .= "v.status_id,s.status,v.developer_id, v.locker_id, ";
    $sqlcode .= (($args{itemType} < 10 || $args{itemType} > 12) ? "p.name, p.acronym " : "0,0 ");
    $sqlcode .= "FROM $args{schema}.$settings{itemTable} c, $args{schema}.$settings{versionTable} v, $args{schema}.item_status s ";
    $sqlcode .= (($args{itemType} < 10 || $args{itemType} > 12) ? ", $args{schema}.project p " : "");
    $sqlcode .= "WHERE (c.id = v.$settings{itemIDCol}) AND v.status_id = s.id AND ";
    $sqlcode .= (($args{itemType} < 10 || $args{itemType} > 12) ? "p.id=c.project_id AND " : "");
    $sqlcode .= ($args{status} != 0) ? "v.status_id = $args{status} AND " : "";
    $sqlcode .= ($args{itemType} == 0 && $args{nonCode} eq 'T') ? "c.type_id >= 9 AND " : "";
    $sqlcode .= ($args{itemType} != 0 && $args{itemType} < 10 && $args{itemType} > 12) ? "c.type_id = $args{itemType} AND " : "";
    $sqlcode .= (($args{document} == 0) ? (($args{project} != 0 && ($args{itemType} < 10 || $args{itemType} > 12)) ? "c.project_id = $args{project} AND " : "") : "");
    $sqlcode .= ($args{userID} != 0 && $args{status} == 2) ? "v.locker_id = $args{userID} AND " : "";
    $sqlcode .= ($args{document} != 0) ? "c.id = $args{document} AND " : "";
    $sqlcode .= "(v.$settings{itemIDCol},v.version_date) IN (SELECT $settings{itemIDCol},MAX(version_date) ";
    $sqlcode .= "FROM $args{schema}.$settings{versionTable} GROUP BY $settings{itemIDCol}) ORDER BY ". (($args{itemType} < 10 || $args{itemType} > 12) ? "p.name,":"") ."c.name";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($docList[$i]{id},$docList[$i]{name},$docList[$i]{pid},$docList[$i]{descr},$docList[$i]{itemType},$docList[$i]{verID},
           $docList[$i]{major},$docList[$i]{minor},$docList[$i]{date},$docList[$i]{statusID},$docList[$i]{status},
           $docList[$i]{developer},$docList[$i]{locker},$docList[$i]{projName}, $docList[$i]{projAcronym}) = $csr->fetchrow_array) {
        $docList[$i]{description} = $docList[$i]{descr};
        $docList[$i]{major_version} = $docList[$i]{major};
        $docList[$i]{minor_version} = $docList[$i]{minor};
        $docList[$i]{version_date} = $docList[$i]{date};
        $docList[$i]{status_id} = $docList[$i]{statusID};
        $docList[$i]{developer_id} = $docList[$i]{developer};
        $docList[$i]{locker_id} = $docList[$i]{locker};
        my ($creator, $creationDate) = $args{dbh}->selectrow_array("SELECT developer_id,TO_CHAR(version_date,'$args{dateFormat}') FROM $args{schema}.$settings{versionTable} " .
              "WHERE $settings{itemIDCol}=$docList[$i]{id} ORDER BY id");
        $docList[$i]{creator} = $creator;
        $docList[$i]{creationDate} = $creationDate;
        $i++;
    }

    return (@docList);
}


###################################################################################################################################
sub getVersionList {  # routine to get a list of versions of a document
###################################################################################################################################
    my %args = (
        document => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my @docList;
    my $sqlcode = "SELECT v.id,v.$settings{itemIDCol},v.change_description,v.major_version,v.minor_version,TO_CHAR(v.version_date,'mm/dd/yyyy hh:mi:ss'),";
    $sqlcode .= "v.status_id,s.status,v.developer_id,v.locker_id ";
    $sqlcode .= "FROM $args{schema}.$settings{versionTable} v, $args{schema}.item_status s ";
    $sqlcode .= "WHERE v.status_id = s.id AND ";
    $sqlcode .= "v.$settings{itemIDCol} = $args{document} ";
    $sqlcode .= "ORDER BY v.major_version DESC, v.minor_version DESC";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($docList[$i]{id},$docList[$i]{itemid},$docList[$i]{descr},$docList[$i]{major},$docList[$i]{minor},$docList[$i]{date},
           $docList[$i]{statusID},$docList[$i]{status},$docList[$i]{developer},$docList[$i]{locker}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@docList);
}


###################################################################################################################################
sub getDocumentVersion {  # routine to get all info for a version of a document
###################################################################################################################################
    my %args = (
        document => 0,
        majorVersion => 0,
        minorVersion => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my %info;
    $args{dbh}->{LongReadLen} = 100000000;
    my $sqlcode = "SELECT id, $settings{itemIDCol}, major_version, minor_version, version_date, status_id, developer_id, " . 
            "change_description, locker_id, item_image, signed_image FROM $args{schema}.$settings{versionTable} " .
            "WHERE id = $args{document}";
    ($info{id}, $info{item_id},$info{major_version},$info{minor_version},$info{version_date},$info{status_id},$info{developer_id},
        $info{change_description},$info{locker_id},
        $info{item_image}, $info{signed_image}) = $args{dbh}->selectrow_array($sqlcode);
    
    return (%info);
}


###################################################################################################################################
sub getConfigurationItem {  # routine to get all info for a version of a document
###################################################################################################################################
    my %args = (
        ID => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my %item;
    my $sqlcode = "SELECT id,name," . (($settings{itemType} <10 || $settings{itemType} >12) ? "source_id,type_id,project_id" : "0,$settings{itemType},0") . ",description FROM $args{schema}.$settings{itemTable} WHERE id=$args{ID}";
    ($item{id},$item{name},$item{source_id},$item{type_id},$item{project_id},$item{description}) = $args{dbh}->selectrow_array($sqlcode);
    
    return (%item);
}


###################################################################################################################################
sub getMimeType {  # routine to get a mime type from an ID
###################################################################################################################################
    my %args = (
        ID => 0,
        IDSource => 'configuration_item',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $mimeType = "";
    if ($args{IDSource} eq 'configuration_item') {
        ($mimeType) = $args{dbh}->selectrow_array("SELECT mimetype FROM $args{schema}.item_type WHERE id=$args{ID}");
    } elsif ($args{IDSource} eq 'item_version') {
        if ($settings{itemType} >= 10 && $settings{itemType} <= 12) {
            ($mimeType) = $args{dbh}->selectrow_array("SELECT mimetype FROM $args{schema}.item_type WHERE id=$settings{itemType}");
        } else {
            ($mimeType) = $args{dbh}->selectrow_array("SELECT t.mimetype FROM $args{schema}.item_type t,$args{schema}.$settings{itemTable} c," .
                "$args{schema}.$settings{versionTable} v WHERE c.type_id=t.id AND c.id=v.$settings{itemIDCol} AND v.id=$args{ID}");
        }
    }
    return ($mimeType);
}


###################################################################################################################################
sub getItemTypeArray {  # routine to get a list of item types
###################################################################################################################################
    my %args = (
        selection => "",
        @_,
    );
    my @itemList;
    my $sqlcode = "SELECT id, type, mimetype FROM $args{schema}.item_type ";
    $sqlcode .= (($args{selection} ne "") ? "WHERE $args{selection} " : ""); 
    $sqlcode .= "ORDER BY type";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($itemList[$i]{id},$itemList[$i]{type},$itemList[$i]{mimetype}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@itemList);
}


###################################################################################################################################
sub getProjectArray {  # routine to get a list of projects
###################################################################################################################################
    my %args = (
        selection => "",
        authorized => 'F',
        userID => 0,
        project => 0, # all
        @_,
    );
    my @itemList;
    if ($args{authorized} eq 'T' && &doesUserHavePriv(dbh => $args{dbh}, schema => $args{schema}, userid => $args{userID}, privList => [11])) {
        $args{authorized} = 'F';
    }
    my $sqlcode = "SELECT id, name, acronym,description, creation_date, project_manager_id,created_by, requirements_manager_id, configuration_manager_id FROM $args{schema}.project ";
    $sqlcode .= (($args{selection} ne "" || $args{authorized} eq 'T' || $args{project} != 0) ? "WHERE 1=1" : "");
    $sqlcode .= (($args{selection} ne "") ? " AND ($args{selection}) " : ""); 
    $sqlcode .= (($args{authorized} eq "T") ? " AND (project_manager_id=$args{userID} OR requirements_manager_id=$args{userID} OR configuration_manager_id=$args{userID}) " : "");
    $sqlcode .= (($args{project} != 0) ? " AND (id=$args{project}) " : ""); 
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
sub hasSignedImage {  # routine to determine if an item has a signed image
###################################################################################################################################
    my %args = (
        ID => "",
        majorVersion => 0,
        minorVersion => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;

    my ($count) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.$settings{versionTable} WHERE $settings{itemIDCol}=$args{ID} "
          . "AND major_version=$args{majorVersion} AND minor_version=$args{minorVersion} AND signed_image IS NOT NULL");

    return ($count);
}


###################################################################################################################################
###################################################################################################################################


1; #return true
