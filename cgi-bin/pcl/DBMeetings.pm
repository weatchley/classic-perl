#
# $Source: /data/dev/rcs/scm/perl/RCS/DBMeetings.pm,v $
#
# $Revision: 1.4 $ 
#
# $Date: 2002/12/11 22:52:22 $
#
# $Author: johnsonc $
#
# $Locker:  $
#
# $Log: DBMeetings.pm,v $
# Revision 1.4  2002/12/11 22:52:22  johnsonc
# Added create SCCB meeting functionality
#
# Revision 1.3  2002/10/11 19:59:50  starkeyj
# modified getMeetingList to select only the meetings for a selected project
#
# Revision 1.2  2002/10/09 22:12:52  starkeyj
# DB  added functions to get meeting agenda and meeting minutes
#
# Revision 1.1  2002/09/27 00:15:57  starkeyj
# Initial revision
#
#
#
#
#
package DBMeetings;
use strict;
use SCM_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_scm qw(:Functions);
use Tables qw(:Functions);
use DBSCCB qw(getSCCBUserRoleList);
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
      &doProcessAddMeeting             	&doProcessUpdateMeeting    
      &doProcessUpdateMeetingInfo 	      &getMeetingList           
      &getProjectArray							&getMeetingAgenda
      &getMeetingMinutes 						&getAttachments
      &getDocument                      &getSCCB
      &getSCCBUserRoleList				&getSCCBProjectCount
      &getSCRByStatus					&getProductList
      &doProcessCreateMeeting
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doProcessAddMeeting             	&doProcessUpdateMeeting    
      &doProcessUpdateMeetingInfo 	      &getMeetingList           
      &getProjectArray							&getMeetingAgenda
      &getMeetingMinutes 						&getAttachments
      &getDocument                      &getSCCB
      &getSCCBUserRoleList              &getSCCBProjectCount
      &getSCRByStatus					&getProductList
      &doProcessCreateMeeting
    )]
);


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub doProcessAddMeeting {  # routine to insert a new document into the DB
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
sub doProcessUpdateMeetingInfo {  # routine to update document information
###################################################################################################################################
    my %args = (
        document => 0,
        name => '',
        description => '',
        userID => 0,
        @_,
    );
    my $output = '';
    my $description = $args{dbh}->quote($args{description});
    
    my $sqlcode = "UPDATE $args{schema}.configuration_item SET name='$args{name}', description=$description WHERE id=$args{document}";
    my $status = $args{dbh}->do($sqlcode);
    $args{dbh}->commit;
    &log_activity($args{dbh},$args{schema},$args{userID},"Information for Document ID $args{document} updated");

    my ($project, $type) = $args{dbh}->selectrow_array("SELECT project_id, type_id FROM $args{schema}.configuration_item WHERE id=$args{document}");
    $output .= "<input type=hidden name=type value=$type>\n";
    $output .= "<input type=hidden name=project value=$project>\n" if (defined($project));
    $output .= doAlertBox(text => "Update was successful");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','update');\n";
    $output .= "//--></script>\n";
    
    return($output);
}


###################################################################################################################################
sub doProcessUpdateMeeting {  # routine to insert a document update into the DB
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
sub getMeetingList {  # routine to get a list of documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        itemType => 0,
        status => 0, # all
        @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    my @mtgList;
    my $sqlcode = "SELECT m.sccbid, s.name, to_char(m.mtgdate,'Mon DD, YYYY'), m.room, ";
    $sqlcode .= "m.time, m.agenda, m.meeting, p.name, p.acronym, m.board_members, m.alternates, m.guests, m.attending, m.absent ";
    $sqlcode .= "FROM $args{schema}.sccb s, $args{schema}.meetings m, $args{schema}.project p ";
    $sqlcode .= "WHERE m.sccbid = s.id AND m.project_id = p.id ";
    $sqlcode .= "AND m.project_id = $args{project} " if ($args{project} != 0);
    $sqlcode .= "order by s.id, mtgdate desc";
#	print "$sqlcode\n";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($mtgList[$i]{sccbid},$mtgList[$i]{sccb},$mtgList[$i]{mtgdate},$mtgList[$i]{room}, 
    		$mtgList[$i]{mtgtime}, $mtgList[$i]{agenda}, $mtgList[$i]{minutes}, $mtgList[$i]{project}, 
    		$mtgList[$i]{abbr}, $mtgList[$i]{board}, $mtgList[$i]{alt}, $mtgList[$i]{guests}, $mtgList[$i]{attending}, 
    		$mtgList[$i]{absent}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@mtgList);
}

###################################################################################################################################
sub getMeetingAgenda {  # routine to get a list of documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        itemType => 0,
        status => 0, # all
        @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    my @mtgAgenda;
    my $sqlcode = "SELECT m.sccbid, s.name, to_char(m.mtgdate,'Mon DD, YYYY'), m.room, ";
    $sqlcode .= "m.time, m.agenda, p.name, p.acronym  ";
    $sqlcode .= "FROM $args{schema}.sccb s, $args{schema}.meetings m, $args{schema}.project p ";
    $sqlcode .= "WHERE m.sccbid = s.id AND m.project_id = p.id ";
    $sqlcode .= "AND m.sccbid = $args{sccbid} and to_char(mtgdate,'Mon DD, YYYY') = '$args{mtgdate}' " ;

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($mtgAgenda[$i]{sccbid},$mtgAgenda[$i]{sccb},$mtgAgenda[$i]{mtgdate},$mtgAgenda[$i]{room},
    $mtgAgenda[$i]{mtgtime}, $mtgAgenda[$i]{agenda}, $mtgAgenda[$i]{project}, $mtgAgenda[$i]{abbr}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@mtgAgenda);
}

###################################################################################################################################
sub getMeetingMinutes {  # routine to get a list of documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        itemType => 0,
        status => 0, # all
        @_,
    );
    $args{dbh}->{LongReadLen} = 100000000;
    my @mtgMinutes;
    my $sqlcode = "SELECT m.sccbid, s.name, to_char(m.mtgdate,'Mon DD, YYYY'), m.room, ";
    $sqlcode .= "m.time, m.meeting, p.name, p.acronym ";
    $sqlcode .= "FROM $args{schema}.sccb s, $args{schema}.meetings m, $args{schema}.project p ";
    $sqlcode .= "WHERE m.sccbid = s.id AND m.project_id = p.id ";
    $sqlcode .= "AND m.sccbid = $args{sccbid} and to_char(mtgdate,'Mon DD, YYYY') = '$args{mtgdate}' " ;

    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($mtgMinutes[$i]{sccbid},$mtgMinutes[$i]{sccb},$mtgMinutes[$i]{mtgdate},$mtgMinutes[$i]{room}, 
    $mtgMinutes[$i]{mtgtime}, $mtgMinutes[$i]{minutes}, $mtgMinutes[$i]{project}, $mtgMinutes[$i]{abbr}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@mtgMinutes);
}
###################################################################################################################################
sub getAttachments {  # routine to get a list of attachments
###################################################################################################################################
    my %args = (
        project => 0,  # null
        itemType => 0,
        minutes => 'T', # all
        document => 0, # all
        @_,
    );
    my @docList;
    my $sqlcode = "SELECT name, attachmentnum ";
    $sqlcode .= "FROM $args{schema}.attachments ";
    $sqlcode .= "WHERE sccbid = $args{sccbid} and to_char(mtgdate,'Mon DD, YYYY') = '$args{mtgdate}' ";
    $sqlcode .= $args{minutes} eq 'T' ? "AND meeting = 'T' " : "AND agenda = 'T' ";
       
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    my $i = 0;
    while (($docList[$i]{name},$docList[$i]{attachmentnum}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@docList);
}

###################################################################################################################################
sub getDocument {  # routine to get all info for a version of a document
###################################################################################################################################
    my %args = (
        document => 0,
        attachmentnum => 1,
        @_,
    );
    my %docimage;
    $args{dbh}->{LongReadLen} = 100000000;
    my $sqlcode = "SELECT name, attachment FROM $args{schema}.attachments " .
            "WHERE sccbid = $args{sccbid} AND attachmentnum = $args{attachmentnum} ";   
    ($docimage{name},$docimage{attachment}) = $args{dbh}->selectrow_array($sqlcode);
    
    return (%docimage);
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
    my $sqlcode = "SELECT id, name, acronym,description, creation_date, project_manager_id,created_by, requirements_manager_id, configuration_manager_id, isnotes, sccbid FROM $args{schema}.project ";
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
            $itemList[$i]{configuration_manager_id},$itemList[$i]{isnotes},$itemList[$i]{sccbid}) = $csr->fetchrow_array) {
        $i++;
    }

    return (@itemList);
}

###################################################################################################################################
sub getSCCB {  # get SCCB info given an SCCB ID
###################################################################################################################################
    my %args = (
        @_,
    );  
    my %sccb;
    my $sqlcode = "SELECT id, name ";
    $sqlcode .= "FROM $args{schema}.sccb ";
    $sqlcode .= "WHERE id = $args{sccbID} ";
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
   
    ($sccb{sccbID}, $sccb{name}) = $csr->fetchrow_array;
    return (%sccb);
}
###################################################################################################################################
sub getSCCBProjectCount {
###################################################################################################################################
	my %args = (
		@_,
	);
	my $sql = "SELECT COUNT(id) FROM $args{schema}.project WHERE sccbid = $args{sccbID}";
	my $sth = $args{dbh}->prepare($sql);
	$sth->execute;
	my $count = $sth->fetchrow_array;
	return ($count);
}
###################################################################################################################################
sub getSCRByStatus {
###################################################################################################################################
	my %args = (
		@_,
	);
	my @scr;
	my $sql = "SELECT a.id, TO_CHAR(datesubmitted, 'MM/DD/YYYY'), a.description, rationale, e.firstname || ' ' || e.lastname as name "
			  . ", status, priority, b.name, c.description, c.open, d.description FROM "
	          . "$args{schema}.scrrequest a, $args{schema}.product b, $args{schema}.scrstatus c, $args{schema}.scrpriority d, $args{schema}.users e "
	          . "WHERE status = $args{status} AND project_id = $args{project} AND "
	          . "status = c.id AND product = b.id AND priority = d.id "
	          . "AND e.id = submittedby ORDER BY a.id";
	$args{dbh}->{LongReadLen} = 100000000;
	my $sth = $args{dbh}->prepare($sql);
	$sth->execute;
	my $i = 0;
	while (($scr[$i]{id}, $scr[$i]{datesubmitted}, $scr[$i]{description}, $scr[$i]{rationale}, $scr[$i]{name},
		   $scr[$i]{status}, $scr[$i]{priority}, $scr[$i]{product}, $scr[$i]{statusdescription}, $scr[$i]{open}, $scr[$i]{priority}) = $sth->fetchrow_array) {
		$i++;
	}
	return(@scr);        
}
###################################################################################################################################
sub doProcessCreateMeeting {
###################################################################################################################################
	my %args = (
		@_,
	);
	my $hashRef = $args{settings};
	my %settings = %$hashRef;
	my $board = $args{dbh}->quote($settings{board});
	my $alternates = $args{dbh}->quote($settings{alternates});
	my $output = "";
	my $guestList = "";
	foreach my $i (0 .. $#{$settings{guests}}) {
		$guestList .= "$settings{guests}[$i], ";
	}
	chop($guestList);
	chop($guestList);
	$guestList = $args{dbh}->quote($guestList);
	$board =~ s/\<br\>//g;
	$alternates =~ s/\<br\>//g;	
	my $sql = "INSERT INTO $args{schema}.meetings (sccbid, mtgdate, time, room, board_members, alternates, "
			  . "guests, agenda, project_id) VALUES ($args{sccbID}, TO_DATE('$settings{date}', 'MM/DD/YYYY'), "
			  . "'$settings{begin}' || ' - ' || '$settings{end}', '$settings{room}', $board, $alternates, $guestList, "
			  . ":agenda, $settings{projectID})";
	my $sth = $args{dbh}->prepare($sql);
	$sth->bind_param(":agenda", $settings{agenda}, { ora_type => ORA_CLOB, ora_field => 'agenda' });
	$sth->execute;
	$args{dbh}->commit;
    &log_activity($args{dbh},$args{schema},$settings{userid},"Meeting for SCCB ID $args{sccbID} created");
    $output .= doAlertBox(text => "SCCB meeting successfully created");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('utilities','');\n";
    $output .= "//--></script>\n";
    return($output);
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

