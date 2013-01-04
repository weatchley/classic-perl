#
# $Source: /data/dev/rcs/pcl/perl/RCS/DBTraining.pm,v $
#
# $Revision: 1.3 $ 
#
# $Date: 2003/02/10 18:55:52 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBTraining.pm,v $
# Revision 1.3  2003/02/10 18:55:52  atchleyb
# updated to not require training on depricated documents
#
# Revision 1.2  2003/02/03 20:16:20  atchleyb
# removed refs to SCM
#
# Revision 1.1  2002/10/31 17:06:46  atchleyb
# Initial revision
#
#
#
#
package DBTraining;
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
      &selectTitle      &getUserArray         &getConfigItemArray           &getUserTrainingHistory
      &getTrainingItem  &getLastTrainingDate  &doProcessAddTrainingRecord   &getDocumentList
      &getMimeType      &hasSignedImage       &getMissingProcedureTraining  &getUsersWithoutTraining
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &selectTitle      &getUserArray         &getConfigItemArray           &getUserTrainingHistory
      &getTrainingItem  &getLastTrainingDate  &doProcessAddTrainingRecord   &getDocumentList
      &getMimeType      &hasSignedImage       &getMissingProcedureTraining  &getUsersWithoutTraining
    )]
);


###################################################################################################################################
###################################################################################################################################


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
sub getUserArray {  # routine to get an array of users
###################################################################################################################################
    my %args = (
        where => "",
        @_,
    );

    my $i = 0;
    my @users;
    my $sqlcode = "SELECT id, firstname, lastname FROM $args{schema}.users ";
    $sqlcode .= (($args{where} gt "") ? "WHERE $args{where} ": "");
    $sqlcode .= "ORDER BY lastname, firstname";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($users[$i]{id}, $users[$i]{firstname}, $users[$i]{lastname}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;

    return (@users);
}


###################################################################################################################################
sub getConfigItemArray {  # routine to get an array of config Items
###################################################################################################################################
    my %args = (
        where => "",
        @_,
    );

    my $i = 0;
    my @items;
    my $sqlcode = "SELECT id, description FROM $args{schema}.procedure ";
    $sqlcode .= (($args{where} gt "") ? "WHERE $args{where} ": "");
    $sqlcode .= "ORDER BY description";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($items[$i]{id}, $items[$i]{description}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;

    return (@items);
}


###################################################################################################################################
sub getUserTrainingHistory {  # routine to get an array of config Items
###################################################################################################################################
    my %args = (
        where => "",
        userID => 0,
        document => 0,
        @_,
    );

    my $i = 0;
    my @items;
    my $sqlcode = "SELECT pt.userid, TO_CHAR(pt.datecompleted,'MM/DD/YYYY'), pv.procedureid,pv.major_version, pv.minor_version, p.description, ";
    $sqlcode .= "pt.procedureversion ";
    $sqlcode .= "FROM $args{schema}.procedure_training_completed pt, $args{schema}.procedure p, $args{schema}.procedure_version pv, ";
    $sqlcode .= "$args{schema}.users u ";
    $sqlcode .= "WHERE pv.procedureid=p.id AND pv.id=pt.procedureversion AND pt.userid = u.id ";
    $sqlcode .= (($args{userID} != 0) ? "AND pt.userid=$args{userID} " : "");
    $sqlcode .= (($args{document} != 0) ? " AND pv.procedureid=$args{document} " : "");
    $sqlcode .= (($args{where} gt "") ? "AND ($args{where}) ": "");
    $sqlcode .= "ORDER BY p.description, pt.datecompleted DESC, u.username";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    
    while (($items[$i]{userid}, $items[$i]{datecompleted}, $items[$i]{procedureid}, $items[$i]{major_version}, 
            $items[$i]{minor_version}, $items[$i]{description}, $items[$i]{procedureversion}) = $csr->fetchrow_array) {
        $i++;
    }
    $csr->finish;

    return (@items);
}


###################################################################################################################################
sub getMissingProcedureTraining {  # routine to get a string of missing training
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );

    my $trainingList = "0";
    my $missingTraining = "";
    
    my $csr = $args{dbh}->prepare("SELECT procedureversion FROM $args{schema}.procedure_training_completed WHERE userid=$args{userID} ORDER BY procedureversion");
    $csr->execute;
    while (my ($id) = $csr->fetchrow_array) {
        $trainingList .= ", $id";
    }
    $csr->finish;
    
    my $sqlcode = "SELECT p.description FROM $args{schema}.procedure p, $args{schema}.procedure_version pv WHERE p.id=pv.procedureid AND ";
    $sqlcode .= "(pv.procedureid,pv.version_date) IN (SELECT procedureid,MAX(version_date) FROM $args{schema}.procedure_version GROUP BY procedureid) AND ";
    $sqlcode .= "pv.signed_image IS NOT NULL AND pv.id NOT IN ($trainingList) AND pv.status_id <3 ORDER BY p.description";
    $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    my $count = 0;
    while (my ($description) = $csr->fetchrow_array) {
        $missingTraining .= "$description<br>";
        $count++;
    }
    $csr->finish;
    
    $missingTraining =~ s/<br>$//;

    return ($count,$missingTraining);
}


###################################################################################################################################
sub getUsersWithoutTraining {  # routine to get a string of missing training
###################################################################################################################################
    my %args = (
        procedure => 0,
        @_,
    );

    my $trainingList = "0";
    my $missingTraining = "";
    
    my $sqlcode = "SELECT id FROM $args{schema}.procedure_version WHERE procedureid=$args{procedure} AND ";
    $sqlcode .= "(procedureid,version_date) IN (SELECT procedureid,MAX(version_date) FROM $args{schema}.procedure_version ";
    $sqlcode .= "WHERE signed_image IS NOT NULL AND status_id <3 GROUP BY procedureid)";
    
    my $currentVersion = $args{dbh}->selectrow_array($sqlcode);

    my $count = 0;
    if (defined($currentVersion)) {
        $sqlcode = "SELECT u.id FROM $args{schema}.users u, $args{schema}.user_privilege up WHERE u.id=up.userid AND up.privilege=-1 AND ";
        $sqlcode .= "u.id NOT IN (SELECT userid FROM $args{schema}.procedure_training_completed WHERE procedureversion=$currentVersion)";
        
        my $csr = $args{dbh}->prepare($sqlcode);
        $csr->execute;
        while (my ($id) = $csr->fetchrow_array) {
            $missingTraining .= &getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $id) . "<br>";
            $count++;
        }
        $csr->finish;
    
        $missingTraining =~ s/<br>$//;
    }

    return ($count,$missingTraining);
}


###################################################################################################################################
sub getTrainingItem {  # routine to get all info for a training item
###################################################################################################################################
    my %args = (
        userID => 0,
        itemID => 0,
        procedureVersion => 0,
        majorVersion => 0,
        minorVersion => 0,
        @_,
    );
    my %item;
    $args{dbh}->{LongReadLen} = 100000000;
    my $sqlcode = "SELECT pt.userid, pv.procedureid, TO_CHAR(pt.datecompleted,'MM/DD/YYYY'), pv.major_version, pv.minor_version, " . 
            "pt.certificate,pt.procedureversion FROM $args{schema}.procedure_training_completed pt, $args{schema}.procedure_version pv " .
            "WHERE pv.id=pt.procedureversion AND pt.userid=$args{userID} ";
    if ($args{procedureVersion} != 0) {
        $sqlcode .= "AND pt.procedureversion=$args{procedureVersion}";
    } else {
        $sqlcode .= "AND pv.procedureid = $args{itemID} AND pv.major_version = $args{majorVersion} AND pv.minor_version = $args{minorVersion}";
    }
    ($item{userid},$item{procedureid},$item{datecompleted},$item{major_version},$item{minor_version},$item{certificate}) = 
            $args{dbh}->selectrow_array($sqlcode);
    
    return (%item);
}


###################################################################################################################################
sub getLastTrainingDate {  # routine to get the last training compleated for either a user or a training item
###################################################################################################################################
    my %args = (
        ID => 0,
        type => 'user',
        @_,
    );
    my $sqlcode = "SELECT TO_CHAR(MAX(pt.datecompleted),'MM/DD/YYYY HH24:MI:SS') FROM $args{schema}.procedure_training_completed pt, ";
    $sqlcode .= "$args{schema}.procedure_version pv, $args{schema}.procedure p WHERE pt.procedureversion=pv.id AND pv.procedureid=p.id AND ";
    if ($args{type} eq 'user') {
        $sqlcode .= "pt.userid=$args{ID}";
    } else {
        $sqlcode .= "pv.procedureid=$args{ID}";
        #$sqlcode .= "1=1";
    }
#print STDERR "\n$sqlcode\n\n";
    my ($date) = $args{dbh}->selectrow_array($sqlcode);
    $date = (defined($date)) ? $date : "00/00/00  00:00:00";
    
    return ($date);
}


###################################################################################################################################
sub doProcessAddTrainingRecord {  # routine to insert a new training reocrd into the DB
###################################################################################################################################
    my %args = (
        traininguserid => 0,
        procedureid => 0,
        trainingdate => '00/00/0000',
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
    my $user = $args{traininguserid};
    my $item = $args{procedureid};
    my $date = $args{trainingdate};
    my $fileContents = $args{file};
    my $major = $args{majorVersion};
    my $minor = $args{minorVersion};
    
    my ($procedureVersion) = $args{dbh}->selectrow_array("SELECT id FROM $args{schema}.procedure_version WHERE procedureid=$item AND major_version=$major AND minor_version=$minor");
    

    my $sqlcode = "INSERT INTO $args{schema}.procedure_training_completed (userid, procedureversion, datecompleted, certificate) ";
    $sqlcode .= "VALUES ($user,$procedureVersion,TO_DATE('$date','MM/DD/YYYY'), :document)";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->bind_param(":document", $fileContents, { ora_type => ORA_BLOB, ora_field=>'certificate' });
    my $status = $csr->execute;
    $args{dbh}->commit;
    $csr->finish;
    &log_activity($args{dbh},$args{schema},$args{userID},"Training certificate for user $user inserted");
    
    $output .= doAlertBox(text => "Certificate successfully inserted");
    $output .= "<script language=javascript><!--\n";
    $output .= "   //changeMainLocation('utilities');\n";
    $output .= "//--></script>\n";
    
    return($output);
}


###################################################################################################################################
sub getDocumentList {  # routine to get a list of documents
###################################################################################################################################
    my %args = (
        document => 0, # all
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my @docList;
    my $sqlcode = "SELECT p.id,p.name,p.description,";
    $sqlcode .= "v.id,v.major_version,v.minor_version,TO_CHAR(v.version_date,'mm/dd/yyyy hh:mi:ss'),";
    $sqlcode .= "v.status_id,s.status,v.developer_id, v.locker_id ";
    $sqlcode .= "FROM $args{schema}.procedure p, $args{schema}.procedure_version v, $args{schema}.item_status s ";
    $sqlcode .= "WHERE (p.id = v.procedureid) AND v.status_id = s.id AND ";
    $sqlcode .= "p.id = $args{document} AND ";
    $sqlcode .= "(v.procedureid,v.version_date) IN (SELECT procedureid,MAX(version_date) FROM $args{schema}.procedure_version GROUP BY procedureid) ORDER BY p.name";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($docList[$i]{id},$docList[$i]{name},$docList[$i]{descr},$docList[$i]{verID},
           $docList[$i]{major},$docList[$i]{minor},$docList[$i]{date},$docList[$i]{statusID},$docList[$i]{status},
           $docList[$i]{developer},$docList[$i]{locker}) = $csr->fetchrow_array) {
        $docList[$i]{description} = $docList[$i]{descr};
        $docList[$i]{major_version} = $docList[$i]{major};
        $docList[$i]{minor_version} = $docList[$i]{minor};
        $docList[$i]{version_date} = $docList[$i]{date};
        $docList[$i]{status_id} = $docList[$i]{statusID};
        $docList[$i]{developer_id} = $docList[$i]{developer};
        $docList[$i]{locker_id} = $docList[$i]{locker};
        $i++;
    }

    return (@docList);
}


###################################################################################################################################
sub getMimeType {  # routine to get a mime type from an ID
###################################################################################################################################
    my %args = (
        ID => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $mimeType = "";
    ($mimeType) = $args{dbh}->selectrow_array("SELECT mimetype FROM $args{schema}.item_type WHERE id=$args{ID}");
    return ($mimeType);
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

print STDERR "\nSELECT count(*) FROM $args{schema}.procedure_version WHERE procedureid=$args{ID} "
          . "AND major_version=$args{majorVersion} AND minor_version=$args{minorVersion} AND signed_image IS NOT NULL\n\n";
    my ($count) = $args{dbh}->selectrow_array("SELECT count(*) FROM $args{schema}.procedure_version WHERE procedureid=$args{ID} "
          . "AND major_version=$args{majorVersion} AND minor_version=$args{minorVersion} AND signed_image IS NOT NULL");

    return ($count);
}




###################################################################################################################################
###################################################################################################################################


1; #return true
