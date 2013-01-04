#
# $Source: /data/dev/rcs/pcl/perl/RCS/DBBaseline.pm,v $
#
# $Revision: 1.3 $ 
#
# $Date: 2003/03/09 17:10:35 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: DBBaseline.pm,v $
# Revision 1.3  2003/03/09 17:10:35  starkeyj
# modified select baselien select statements to match new table structure
#
# Revision 1.2  2002/11/06 22:32:12  starkeyj
# modified functions to display the baseline version
#
# Revision 1.1  2002/10/31 17:02:47  starkeyj
# Initial revision
#
#
package DBBaseline;
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
      &doProcessCreateBaseline      &doProcessUpdatebaseline			&getBaseline 
      &getBaselineList              &getBaselineVersion					&getBaselineCount
      &getCurrentBaseline				&getApprovedSCRFiles
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doProcessCreateBaseline      &doProcessUpdatebaseline			&getBaseline 
      &getBaselineList              &getBaselineVersion					&getBaselineCount
      &getCurrentBaseline				&getApprovedSCRFiles
    )]
);


###################################################################################################################################
###################################################################################################################################

###################################################################################################################################
sub doProcessCreateBaseline {  # routine to insert a new document into the DB
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
sub doProcessUpdateBaseline {  # routine to insert a document update into the DB
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
sub  getBaselineCount {  # routine to get a list of documents
###################################################################################################################################
    my %args = (
       project => 0,  # null
        @_,
    );
    my @values;
	 my $sqlcode = "SELECT count(*) FROM $args{schema}.baseline ";
	 $sqlcode .= "WHERE  $args{project} = projectid  ";

	 my $csr = $args{dbh}->prepare($sqlcode);
	 my $status = $csr->execute;
	 @values = $csr->fetchrow_array;
	         $csr->finish;
    return ($values[0]);
}

###################################################################################################################################
sub getBaseline {  # routine to get a list of documents
###################################################################################################################################
    my %args = (
       project => 0,  # null
       baselineid => 0,
        @_,
    );
    my @baselineInfo;
	 my $sqlcode = "SELECT to_char(b.baseline_date,'MM/DD/YYYY HH:MI:SS AM'), b.major_version, b.minor_version ";
	 $sqlcode .= "FROM $args{schema}.baseline b ";
	 $sqlcode .= "WHERE b.id = $args{baselineid} ";
#print "\n $sqlcode \n";
	 my $csr = $args{dbh}->prepare($sqlcode);
	 my $status = $csr->execute;
	 my $count = 0;
	 my $i = 0;
    while (($baselineInfo[$i]{baselinedate},$baselineInfo[$i]{baselinemajor},
    $baselineInfo[$i]{baselineminor}) = $csr->fetchrow_array) {
    	$i++;
    }

    return (@baselineInfo);
}
###################################################################################################################################
sub getBaselineList {  # routine to get a list of versions of a document
###################################################################################################################################
    my %args = (
        product => 0,
        project => 0,
        @_,
    );
       
    my @baselineList;
    my $sqlcode = "SELECT TO_CHAR(baseline_date,'YYYYMMDDHH24MISS'), TO_CHAR(baseline_date,'MM/DD/YYYY HH:MI:SS AM'), ";
    $sqlcode .= "ci.id, ci.name, bi.major_version, bi.minor_version, ci.type_id ";
    $sqlcode .= "FROM $args{schema}.baseline_item bi, $args{schema}.item_version iv, $args{schema}.configuration_item ci ";
    $sqlcode .= "where ci.project_id = $args{project} AND bi.item_id = iv.item_id AND bi.item_id = ci.id ";
	 $sqlcode .= "AND bi.major_version = iv.major_version AND bi.minor_version = iv.minor_version ";
    $sqlcode .= "GROUP BY TO_CHAR(baseline_date,'YYYYMMDDHH24MISS'),TO_CHAR(baseline_date,'MM/DD/YYYY HH:MI:SS AM'), ";
    $sqlcode .= "ci.id, ci.name, bi.major_version, bi.minor_version, ci.type_id ";
    $sqlcode .= "ORDER BY TO_CHAR(baseline_date,'YYYYMMDDHH24MISS')DESC, upper(ci.name) ";
#print "\n$sqlcode\n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($baselineList[$i]{baselinedate},$baselineList[$i]{baselinedate2},$baselineList[$i]{itemid},
    $baselineList[$i]{itemname},$baselineList[$i]{itemmajor},$baselineList[$i]{itemminor},
    $baselineList[$i]{itemtype}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@baselineList);
}

###################################################################################################################################
sub getBaselineList2 {  # routine to get a list of versions of a document
###################################################################################################################################
    my %args = (
        product => 0,
        project => 0,
        @_,
    );
       
    my @baselineList;
    my $sqlcode = "SELECT  b.id, b.minor_version, TO_CHAR(b.baseline_date,'MM/DD/YYYY HH:MI:SS AM'), ";
    $sqlcode .= "ci.id, ci.name, bi.major_version, bi.minor_version, ci.type_id ";
    $sqlcode .= "FROM $args{schema}.baseline_item bi, $args{schema}.item_version iv, ";
    $sqlcode .= "$args{schema}.configuration_item ci, $args{schema}.baseline b ";
    $sqlcode .= "where ci.project_id = $args{project} AND bi.item_id = iv.item_id AND bi.item_id = ci.id ";
	 $sqlcode .= "AND bi.major_version = iv.major_version AND bi.minor_version = iv.minor_version ";
	 $sqlcode .= "AND b.baseline_date = bi.baseline_date ";
    $sqlcode .= "GROUP BY b.id, b.minor_version,TO_CHAR(b.baseline_date,'MM/DD/YYYY HH:MI:SS AM'), ";
    $sqlcode .= "ci.id, ci.name, bi.major_version, bi.minor_version, ci.type_id ";
    $sqlcode .= "ORDER BY b.minor_version DESC, upper(ci.name) ";
#print "\n$sqlcode\n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($baselineList[$i]{baselineid},$baselineList[$i]{baselineminor},$baselineList[$i]{baselinedate2},
    $baselineList[$i]{itemid},$baselineList[$i]{itemname},$baselineList[$i]{itemmajor},
    $baselineList[$i]{itemminor},$baselineList[$i]{itemtype}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@baselineList);
}

###################################################################################################################################
sub getBaselineVersion2 {  # routine to get all info for a version of a document
###################################################################################################################################
    my %args = (
        project => 0,
        selecteddate => 1,
        baselineid => 0,
        @_,
    );
    my @baselineItems;
    my $sqlcode = "SELECT bi.baseline_start,ci.id, ci.name, bi.major_version, bi.minor_version, ci.type_id ";
    $sqlcode .= "FROM $args{schema}.baseline_item bi, $args{schema}.item_version iv, ";
    $sqlcode .= "$args{schema}.configuration_item ci ";
    $sqlcode .= "WHERE bi.item_id = iv.item_id AND bi.item_id = ci.id AND ci.project_id = $args{project} ";
    $sqlcode .= "AND bi.major_version = iv.major_version AND bi.minor_version = iv.minor_version ";
    $sqlcode .= "AND ($args{baselineid} BETWEEN bi.baseline_start AND bi.baseline_inactive ";
    $sqlcode .= "OR (bi.baseline_start <= $args{baselineid} AND bi.baseline_inactive IS NULL)) ";
    $sqlcode .= "ORDER BY UPPER(name), bi.minor_version DESC";

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($baselineItems[$i]{baseline_start},$baselineItems[$i]{itemid},
    $baselineItems[$i]{itemname},$baselineItems[$i]{itemmajor},$baselineItems[$i]{itemminor},
    $baselineItems[$i]{itemtype}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@baselineItems);
}

###################################################################################################################################
sub getBaselineVersion {  # routine to get all info for a version of a document
###################################################################################################################################
    my %args = (
        project => 0,
        selecteddate => 1,
        @_,
    );
    my @baselineItems;
    my $sqlcode = "SELECT to_char(bi.baseline_date,'MM/DD/YYYY HH:MI:SS AM'),to_char(bi.superceded_date,'MM/DD/YYYY HH:MI:SS AM'),";
    $sqlcode .= "ci.id, ci.name, bi.major_version, bi.minor_version, ci.type_id,to_char(bi.baseline_date,'YYYYMMDDHH24MISS') ";
    $sqlcode .= "FROM $args{schema}.baseline_item bi, $args{schema}.item_version iv, ";
    $sqlcode .= "$args{schema}.configuration_item ci ";
    $sqlcode .= "WHERE bi.item_id = iv.item_id AND bi.item_id = ci.id AND ci.project_id = $args{project} ";
    $sqlcode .= "AND bi.major_version = iv.major_version AND bi.minor_version = iv.minor_version ";
    $sqlcode .= "AND ('$args{baselinedate}' BETWEEN TO_CHAR(bi.baseline_date,'YYYYMMDDHH24MISS') ";
    $sqlcode .= "AND TO_CHAR(bi.superceded_date,'YYYYMMDDHH24MISS') OR  ";
    $sqlcode .= "(TO_CHAR(bi.baseline_date,'YYYYMMDDHH24MISS') <= '$args{baselinedate}' AND bi.superceded_date IS NULL)) ";
    $sqlcode .= "ORDER BY UPPER(name), bi.minor_version DESC";
#print "\n$sqlcode \n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($baselineItems[$i]{baselinedate},$baselineItems[$i]{supercededdate},
    $baselineItems[$i]{itemid},$baselineItems[$i]{itemname},$baselineItems[$i]{itemmajor},
    $baselineItems[$i]{itemminor},$baselineItems[$i]{itemtype},$baselineItems[$i]{baselinedate2}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@baselineItems);
}

###################################################################################################################################
sub getCurrentBaseline {  # routine to get a list of documents
###################################################################################################################################
    my %args = (
       project => 0,  # null
        @_,
    );
    my @baselineItems;
	 my $sqlcode = "SELECT to_char(bi.baseline_date,'MM/DD/YYYY'),to_char(bi.superceded_date,'MM/DD/YYYY'),";
	 $sqlcode .= "ci.id, ci.name, bi.major_version, bi.minor_version ";
	 $sqlcode .= "FROM $args{schema}.baseline_item bi, $args{schema}.item_version iv, ";
	 $sqlcode .= "$args{schema}.configuration_item ci, $args{schema}.baseline b ";
	 $sqlcode .= "WHERE b.projectid = $args{project} AND bi.item_id = iv.item_id AND bi.item_id = ci.id ";
	 $sqlcode .= "AND bi.major_version = iv.major_version AND bi.minor_version = iv.minor_version ";
	 $sqlcode .= "AND b.id = bi.baseline_start AND bi.baseline_inactive IS NULL ";
 	 $sqlcode .= "ORDER BY UPPER(name) ";

	 my $csr = $args{dbh}->prepare($sqlcode);
	 my $status = $csr->execute;
	 my $count = 0;

    my $i = 0;
    while (($baselineItems[$i]{baselinedate},$baselineItems[$i]{supercededdate},
    $baselineItems[$i]{itemid},$baselineItems[$i]{itemname},$baselineItems[$i]{itemmajor},
    $baselineItems[$i]{itemminor}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@baselineItems);
}

###################################################################################################################################
sub getApprovedSCRFiles {  # routine to get a list of documents
###################################################################################################################################
    my %args = (
       project => 0,  # null
        @_,
    );
    my @scrFiles;
	 my $sqlcode = "SELECT ci.id, ci.name, iv.major_version, iv.minor_version, scr.id, ";
	 $sqlcode .= "scr.description, scr.dateaccepted ";
	 $sqlcode .= "FROM $args{schema}.product p, $args{schema}.item_version iv, ";
	 $sqlcode .= "$args{schema}.configuration_item ci, $args{schema}.scrrequest scr ";
	 $sqlcode .= "WHERE p.project_id = $args{project} AND ci.id = iv.item_id  ";
	 $sqlcode .= "AND  scr.product = p.id AND scr.status = 5 AND scr.id = iv.scr ";
 	 $sqlcode .= "ORDER BY scr, UPPER(name), iv.minor_version desc, iv.minor_version desc ";

	 my $csr = $args{dbh}->prepare($sqlcode);
	 my $status = $csr->execute;
	 my $count = 0;

    my $i = 0;
    while (($scrFiles[$i]{itemid},$scrFiles[$i]{itemname},$scrFiles[$i]{itemmajor},
    $scrFiles[$i]{itemminor}, $scrFiles[$i]{scrnum}, $scrFiles[$i]{desc},
    $scrFiles[$i]{accepted}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@scrFiles);
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

