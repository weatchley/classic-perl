#
# $Source: /data/dev/rcs/scm/perl/RCS/Documents.pm,v $
#
# $Revision: 1.5 $ 
#
# $Date: 2002/09/20 22:14:10 $
#
# $Author: atchleyb $
#
# $Locker: atchleyb $
#
# $Log: Documents.pm,v $
# Revision 1.5  2002/09/20 22:14:10  atchleyb
# updated to work with generic UI_documents.pl
# updated to properly handle quotes in desccription fields
#
# Revision 1.4  2002/09/18 20:22:31  atchleyb
# fixed bug in multi type display and added javascript functions to allow links to work
#
# Revision 1.3  2002/09/18 17:20:53  starkeyj
# modified addform function to display a project and item type drop down for documents
# that aren't procedures, templates, or training records
#
# Revision 1.2  2002/09/17 23:36:00  atchleyb
# changed name of multi type browse
#
# Revision 1.1  2002/09/17 21:30:47  starkeyj
# Initial revision
#
#
#
#
#
package Documents;
use strict;
use SCM_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_scm qw(:Functions);
use Tables qw(:Functions);
use CGI qw(param);
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
      &doBrowseDocumentTable     &doBrowseDocumentVersions     &doAddDocumentForm         &doProcessAddDocument
      &doDisplayDocument         &doUpdateDocumentForm         &doProcessUpdateDocument   &doCheckOutDocument
      &doUpdateDocumentInfoForm  &doProcessUpdateDocumentInfo  &doProcessCheckInNoChange  &buildProjectSelect 
      &buildTypeSelect           &displayNonRCSItemsTables     &doSelectDocumentProject   &doUpdateSelect
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doBrowseDocumentTable     &doBrowseDocumentVersions     &doAddDocumentForm         &doProcessAddDocument
      &doDisplayDocument         &doUpdateDocumentForm         &doProcessUpdateDocument   &doCheckOutDocument
      &doUpdateDocumentInfoForm  &doProcessUpdateDocumentInfo  &doProcessCheckInNoChange  &buildProjectSelect 
      &buildTypeSelect           &displayNonRCSItemsTables     &doSelectDocumentProject   &doUpdateSelect
    )]
);

#my $scmcgi = new CGI;

###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub doBrowseDocumentTable {  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        itemType => 0, # all
        project => 0,  # null
        title => 'Documents',
        status => 0, # all
        userID => 0, # all
        update => 'F',
        @_,
    );
    my $output = '';
    my $numColumns = 6;
    $numColumns += (($args{update} eq 'T') ? 1 : 0);
    $output .= &startTable(columns => $numColumns, title => "$args{title}<yyy> (xxx)", width => 750);
    $output .= &startRow (bgColor => "#f0f0f0");
    $output .= &addCol (value => "Name", align => "center");
    $output .= &addCol (value => "Current Version", align => "center");
    $output .= (($args{update} eq 'T') ? &addCol (value => "Check In/Out", align => "center") : "");
    $output .= &addCol (value => "Last Revised", align => "center", width => 110);
    $output .= &addCol (value => "Status", align => "center");
    $output .= &addCol (value => "Created By", align => "center");
    $output .= &addCol (value => "Description", align => "center");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    
    my $sqlcode = "SELECT c.id,c.name,c.project_id,c.description,c.type_id,v.major_version,v.minor_version,TO_CHAR(v.version_date,'mm/dd/yyyy hh:mi:ss'),";
    $sqlcode .= "v.status_id,s.status,v.developer_id, v.locker_id ";
    $sqlcode .= "FROM $args{schema}.configuration_item c, $args{schema}.item_version v, $args{schema}.item_status s ";
    $sqlcode .= "WHERE (c.id = v.item_id) AND v.status_id = s.id AND ";
    $sqlcode .= ($args{status} != 0) ? "v.ststus = $args{status} AND " : "";
    $sqlcode .= ($args{itemType} != 0) ? "c.type_id = $args{itemType} AND " : "";
    $sqlcode .= ($args{project} != 0) ? "c.project_id = $args{project} AND " : "c.project_id IS NULL AND ";
    $sqlcode .= "(v.item_id,v.version_date) IN (SELECT item_id,MAX(version_date) FROM $args{schema}.item_version GROUP BY item_id) ORDER BY c.name";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    
    while (my ($id,$name,$pid,$descr,$itemType,$major,$minor,$date,$statusID,$status,$developer,$locker) = $csr->fetchrow_array) {
        $count++;
        $output .= &startRow;
        my ($mimeType) = $args{dbh}->selectrow_array("SELECT mimetype FROM $args{schema}.item_type WHERE id=$itemType");
        my $hasMime = ((defined($mimeType)) ? "T" : "F");
        my $url;
        my $prompt = "";
        my $checkInOut = "&nbsp;";
        my $checkInOutURL = "";
        if ($args{update} ne 'T') {
        } else {
            if ($statusID == 1) {
                $checkInOut = "Check Out";
                $prompt = "Click here to check out document";
                $checkInOutURL = "javascript:checkOutDocument($id,$major,$minor)";
            } elsif ($statusID == 2 && $locker == $args{userID}) {
                $checkInOut = "Check In";
                $prompt = "Click here to check in document";
                $checkInOutURL = "javascript:updateVersion($id)";
            }
        }
        $url = "javascript:displayVersions($id)";
        $name =~ s/\..{0,3}$//;
        $output .= &addCol (value=>$name, url => $url, prompt => "Click here for complete version history of $name");
        $url = (($hasMime eq "T") ? "javascript:displayDocument($id,$major,$minor)" : "");
        $output .= &addCol (value=>(("$major" ne "0") ? "$major.$minor" : "Draft $minor"), url => $url, prompt => "Click here to display document", align => "center");
        $output .= (($args{update} eq 'T') ? &addCol (value => $checkInOut, url => $checkInOutURL, align => "center", prompt => $prompt) : "");
        $output .= &addCol (value=>$date, align => "center");
        my $lockerLink = '';
        if ($statusID == 2) {
            my $lockerName = getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $locker);
            $lockerLink = " by<br><a href=\"javascript:displayUser($locker)\" title=\"Click here to browse information for $lockerName\">$lockerName</a>";
        }
        $output .= &addCol (value=>$status . $lockerLink , align => "center");
        $url = "javascript:displayUser($developer)";
        my $fullName = getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $developer);
        $output .= &addCol (value=>$fullName, align => "center", url => $url, prompt => "Click here to browse information for $fullName");
        $url = "";
        $prompt = "";
        if ($args{update} eq 'T') {
            $url = "javascript:updateDocumentInfoformation($id)";
            $prompt = "Click here to update document information";
        }
        $output .= &addCol (value=>((defined($descr)) ? $descr : "none given"), url => $url, prompt => $prompt);
        $output .= &endRow;
    }
    $csr->finish;
    $output .= &endTable();
    
    $output =~ s/xxx/$count/;
    $output =~ s/<yyy>/s/ if ($count != 1);
    $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    $output = '' if ($count == 0);
    return($output);
}


###################################################################################################################################
sub displayNonRCSItemsTables {  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        userID => 0, # all
        single => 'T',
        title => 'Non-Code Configuration Item',
        @_,
    );
    my $output = '';
    my $username = '';
    my $path = "/cgi-bin/" . lc($ENV{SCMType});
    $output .= <<END_OF_BLOCK;
    <script language=javascript><!--
       function displayVersions(documentID) {
           displayNonRCSItemsTablesForm.command.value = 'browseversion';
           displayNonRCSItemsTablesForm.document.value = documentID;
           displayNonRCSItemsTablesForm.action = '$path/UI_documents.pl';
           displayNonRCSItemsTablesForm.target = 'main';
           displayNonRCSItemsTablesForm.submit();
       }
       function displayDocument(document,major,minor) {
          var myDate = new Date();
          var winName = myDate.getTime();
          displayNonRCSItemsTablesForm.command.value = 'displaydocument';
          displayNonRCSItemsTablesForm.document.value = document;
          displayNonRCSItemsTablesForm.majorversion.value = major;
          displayNonRCSItemsTablesForm.minorversion.value = minor;
          displayNonRCSItemsTablesForm.action = '$path/UI_documents.pl';
          displayNonRCSItemsTablesForm.target = winName;
          var newwin = window.open('',winName);
          newwin.creator = self;
          displayNonRCSItemsTablesForm.submit();
       }
       function displayUser(id) {
           displayNonRCSItemsTablesForm.id.value = id;
           displayNonRCSItemsTablesForm.command.value = 'displayuser';
           displayNonRCSItemsTablesForm.action = '$path/user_functions' + '.pl';
           displayNonRCSItemsTablesForm.target = 'main';
           displayNonRCSItemsTablesForm.submit();
       }
    //-->
    </script>
    <form name=displayNonRCSItemsTablesForm method=post target=main action=dummy.pl>
    <input type=hidden name=userid value=$args{userID}>
    <input type=hidden name=username value=$username>
    <input type=hidden name=schema value=$args{schema}>
    <input type=hidden name=command value=''>
    <input type=hidden name=document value=''>
    <input type=hidden name=id value=''>
    <input type=hidden name=majorversion value=''>
    <input type=hidden name=minorversion value=''>
    </form>
END_OF_BLOCK
    
    if ($args{single} ne 'T') {
        my $sqlcode = "SELECT id, type FROM $args{schema}.item_type WHERE id>=13 ORDER BY type";
        my $csr = $args{dbh}->prepare($sqlcode);
        $csr->execute;
        while (my ($id, $type) = $csr->fetchrow_array) {
            $output .= &doBrowseDocumentTable(dbh => $args{dbh}, schema => $args{schema}, itemType => $id, title => $type, userID => $args{userID}, 
                  project => $args{project});
            $output .= (((substr($output,-4) ne "<br>") && (substr($output,-8) ne "</form>\n")) ? "<br><br>" : "");
        }
        $csr->finish;
    } else {
        $output .= &doBrowseDocumentTable(dbh => $args{dbh}, schema => $args{schema}, itemType => 0, title => $args{title}, userID => $args{userID}, 
              project => $args{project});
    }
    return($output);
}


###################################################################################################################################
sub doUpdateSelect {  # routine to display a table of documents that a user can update, by project
###################################################################################################################################
    my %args = (
        userID => 0, # all
        title => 'Non-Code Configuration Item',
        form => '',
        @_,
    );
    my $output = '';
    my $username = '';
    my $whereClause = '';
    if (&doesUserHavePriv(dbh =>$args{dbh}, schema => $args{schema}, userid => $args{userID}) < 1) {
        $whereClause = "WHERE project_manager_id=$args{userID} OR requirements_manager_id=$args{userID} OR configuration_manager_id=$args{userID}";
    }
    
    my $sqlcode = "SELECT id, name FROM $args{schema}.project $whereClause ORDER BY name";
    my $csr = $args{dbh}->prepare($sqlcode);
    $csr->execute;
    while (my ($id, $name) = $csr->fetchrow_array) {
        $output .= &doBrowseDocumentTable(dbh => $args{dbh}, schema => $args{schema}, title => $name ."$args{title}", userID => $args{userID}, 
              project => $id, update => 'T', form => $args{form});
        $output .= (((substr($output,-4) ne "<br>") && (substr($output,-8) ne "</form>\n")) ? "<br><br>" : "");
    }
    $csr->finish;
    return($output);
}


###################################################################################################################################
sub doBrowseDocumentVersions {  # routine to display a table of versions of a document
###################################################################################################################################
    my %args = (
        document => 0,
        title => 'Versions',
        @_,
    );
    my $output = '';
    my $numColumns = 4;
    my ($name, $documentDescription) = $args{dbh}->selectrow_array("SELECT name,description FROM $args{schema}.configuration_item WHERE id = $args{document}");
    $output .= &startTable(columns => $numColumns, title => "$args{title}: $name (xxx)", width => 750);
    $output .= &startRow(bgColor => "#f0f0f0");
    $output .= &addCol (colspan => $numColumns, value => $documentDescription);
    $output .= &endRow();
    $output .= &startRow(bgColor => "#f0f0f0");
    $output .= &addCol (colspan => $numColumns, value => "Status: --status--");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= &startRow (bgColor => "#f0f0f0");
    $output .= &addCol (value => "Version", align => "center");
    $output .= &addCol (value => "Date Revised", align => "center", width => 110);
    $output .= &addCol (value => "Revised By", align => "center");
    $output .= &addCol (value => "Description", align => "center");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    
    my $sqlcode = "SELECT v.item_id,v.change_description,v.major_version,v.minor_version,TO_CHAR(v.version_date,'mm/dd/yyyy hh:mi:ss'),";
    $sqlcode .= "v.status_id,s.status,v.developer_id,v.locker_id ";
    $sqlcode .= "FROM $args{schema}.item_version v, $args{schema}.item_status s ";
    $sqlcode .= "WHERE v.status_id = s.id AND ";
    $sqlcode .= "v.item_id = $args{document} ";
    $sqlcode .= "ORDER BY v.major_version DESC, v.minor_version DESC";
    
    my $csr = $args{dbh}->prepare($sqlcode);
    my $status = $csr->execute;
    my $count = 0;
    my ($mimeType) = $args{dbh}->selectrow_array("SELECT t.mimetype FROM $args{schema}.item_type t,$args{schema}.configuration_item c WHERE c.type_id=t.id AND c.id=$args{document}");
    my $hasMime = ((defined($mimeType)) ? "T" : "F");
    
    while (my ($id,$descr,$major,$minor,$date,$statusID,$status,$developer,$locker) = $csr->fetchrow_array) {
        my $temp = $status . (($statusID == 2) ? " by " . getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $locker) : "");
        $output =~ s/--status--/$temp/;
        $count++;
        $output .= &startRow;
        my $url = (($hasMime eq "T") ? "javascript:displayDocument($id,$major,$minor)" : "");
        $output .= &addCol (value=>(("$major" ne "0") ? "$major.$minor" : "Draft $minor"), align => "center", url => $url, prompt => "Click here to display document");
        $output .= &addCol (value=>$date, align => "center");
        $output .= &addCol (value=>getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $developer), align => "center");
        $output .= &addCol (value=>((defined($descr)) ? $descr : "none given"));
        $output .= &endRow;
    }
    $csr->finish;
    $output .= &endTable();
    
    $output =~ s/xxx/$count/;
    $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    
    return($output);
}


###################################################################################################################################
sub doAddDocumentForm {  # routine to display form for adding a document
###################################################################################################################################
    my %args = (
        itemType => 0,
        project => 0,  # null
        title => 'Add',
        form => '',
        userID => 0,
        @_,
    );
    my $output = "";
    
    $output .= "<input type=hidden name=itemtype value=$args{itemType}>\n" if ($args{itemType} != 0);
    if ($args{itemType} >= 10 && $args{itemType} <= 12) {
        $output .= "<input type=hidden name=project value=$args{project}>\n";
    } else {
        $output .= &buildProjectSelect(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID});
    }
    $output .= <<END_OF_BLOCK;
    <input type=hidden name=itemid value=0>
    <table border=0 width=750 align=center>
    <tr><td>Description:</td><td><input type=text name=description size=100 maxlength=250></td></tr>
    <tr><td>Version</td><td>Major: <input type=text name=major size=2 maxlength=2> &nbsp; Minor: <input type=text name=minor size=3 maxlength=3>
END_OF_BLOCK
	 $output .= &buildTypeSelect($args{dbh}) if ($args{itemType} == 0);
    $output .= <<END_OF_BLOCK;
    </td></tr><tr><td>Document File:</td><td><input type=file name=documentfile size=50></td></tr>
    <tr><td colspan=2 align=center><input type=button name=submitadd value=Submit onClick="doVerifySubmit(document.$args{form});"></td></tr>
    <script language=javascript><!--
        function doVerifySubmit(f) {
        //alert(f.name);
            var msg = "";
            //if (isblank(f.name.value)) {
            //    msg += "Document Name must be input.\\n";
            //}
            if (isblank(f.description.value)) {
                msg += "Description must be input.\\n";
            }
            if (!isnumeric(f.major.value)) {
                msg += "Major Version must be input as a number.\\n";
            }
            if (!isnumeric(f.minor.value)) {
                msg += "Minor Version must be input as a number.\\n";
            }
            if (isblank(f.documentfile.value)) {
                msg += "File must be selected.\\n";
            }
            if (msg != "") {
                alert (msg);
            } else {
                //submitFormCGIResults('DocumentUpload','addprocess')
                submitFormCGIResults('$args{form}','addprocess')
            }
        }
    //-->
    </script>
    </table>
    
END_OF_BLOCK
    
    return($output);
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
sub doDisplayDocument {  # routine to display a document from the DB
###################################################################################################################################
    my %args = (
        document => 0,
        majorVersion => 0,
        minorVersion => 0,
        @_,
    );
    my $output = '';
    $args{dbh}->{LongReadLen} = 100000000;
    my ($mimeType) = $args{dbh}->selectrow_array("SELECT t.mimetype FROM $args{schema}.configuration_item c, $args{schema}.item_type t WHERE c.id = $args{document} AND c.type_id = t.id");
    my $fileContents = $args{dbh}->selectrow_array("SELECT item_image FROM $args{schema}.item_version WHERE item_id = $args{document} AND major_version = $args{majorVersion} AND minor_version = $args{minorVersion}");
    $output .= "Content-type: $mimeType\n\n";
    $output .= $fileContents;
    
    return($output);
}


###################################################################################################################################
sub doCheckOutDocument {  # routine to check out a document for update
###################################################################################################################################
    my %args = (
        document => 0,
        majorVersion => 0,
        minorVersion => 0,
        userID => 0,
        form => '',
        @_,
    );
    my $output = '';
    
    my $sqlcode = "UPDATE $args{schema}.item_version SET status_id=2, locker_id=$args{userID} WHERE item_id=$args{document} AND major_version=$args{majorVersion} AND minor_version=$args{minorVersion}";
    my $status = $args{dbh}->do($sqlcode);
    $args{dbh}->commit;
    &log_activity($args{dbh},$args{schema},$args{userID},"Document ID $args{document} checked out");

    my ($project, $type) = $args{dbh}->selectrow_array("SELECT project_id, type_id FROM $args{schema}.configuration_item WHERE id=$args{document}");
    $output .= "<input type=hidden name=type value=$type>\n";
    $output .= "<input type=hidden name=project value=$project>\n" if (defined($project));
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','update');\n";
    $output .= "//--></script>\n";
    
    return($output);
}


###################################################################################################################################
sub doSelectDocumentProject {  # routine to selct project for selecting a document
###################################################################################################################################
    my %args = (
        document => 0,
        @_,
    );
    my $output = '';
    my $sqlcode = "SELECT id,name,source_id,type_id,project_id,description FROM $args{schema}.configuration_item WHERE id=$args{document}";
    my ($id,$name,$source_id,$type_id,$project_id,$description) = $args{dbh}->selectrow_array($sqlcode);
    my $nameDisplay = $name;
    $output .= &buildProjectSelect(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID});
    
    $output .= <<END_OF_BLOCK;
    <input type=hidden name=type value=0>
    <center><input type=button name=updateselectbutton value=Submit onClick="submitForm('$args{form}','update');"></center>
    
END_OF_BLOCK
    
    return($output);
}


###################################################################################################################################
sub doUpdateDocumentInfoForm {  # routine to display form for updating document information
###################################################################################################################################
    my %args = (
        document => 0,
        @_,
    );
    my $output = '';
    my $sqlcode = "SELECT id,name,source_id,type_id,project_id,description FROM $args{schema}.configuration_item WHERE id=$args{document}";
    my ($id,$name,$source_id,$type_id,$project_id,$description) = $args{dbh}->selectrow_array($sqlcode);
    my $nameDisplay = $name;
    $nameDisplay =~ s/.doc//;
    $description =~ s/"/&quot;/g; #"
    
    $output .= <<END_OF_BLOCK;
    <input type=hidden name=itemid value=$args{document}>
    <table border=0 width=750 align=center>
    <tr><td>Name:</td><td>$nameDisplay</td></tr>
    <input type=hidden name=name size=50 maxlength=100 value='$name'></td></tr>
    <tr><td>Description:</td><td><input type=text name=description size=100 maxlength=250 value="$description"></td></tr>
    <tr><td colspan=2 align=center><input type=button name=updatebutton value=Submit onClick="doVerifySubmit(document.$args{form});"></td></tr>
    <script language=javascript><!--
        function doVerifySubmit(f) {
            var msg = "";
            if (isblank(f.name.value)) {
                msg += "Name must be entered.\\n";
            }
            if (isblank(f.description.value)) {
                msg += "Document description must be entered.\\n";
            }
            if (msg != "") {
                alert (msg);
            } else {
                //submitFormCGIResults('DocumentUpload','addprocess')
                submitFormCGIResults('$args{form}','updateinformationprocess')
            }
        }
    //-->
    </script>
    </table>
    
END_OF_BLOCK
    
    return($output);
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
sub doUpdateDocumentForm {  # routine to display form for updating a document
###################################################################################################################################
    my %args = (
        document => 0,
        itemType => 0,
        project => 0,  # null
        title => 'Update',
        form => '',
        @_,
    );
    my $output = "";
    
    my $sqlcode = "SELECT c.id,c.description,v.major_version,v.minor_version,v.status_id,v.developer_id ";
    $sqlcode .= "FROM $args{schema}.configuration_item c, $args{schema}.item_version v ";
    $sqlcode .= "WHERE (c.id = v.item_id) AND c.id = $args{document} AND ";
    $sqlcode .= "(v.item_id,v.version_date) IN (SELECT item_id,MAX(version_date) FROM $args{schema}.item_version GROUP BY item_id)";
    my ($id,$descr,$major,$minor,$status,$developer) = $args{dbh}->selectrow_array($sqlcode);

    $output .= <<END_OF_BLOCK;
    <input type=hidden name=itemtype value=$args{itemType}>
    <input type=hidden name=project value=$args{project}>
    <input type=hidden name=itemid value=$args{document}>
    <table border=0 width=750 align=center>
    <tr><td colspan=2 align=center><font size=+1><b>$descr</b></font><br>Latest Revision: <b>$major.$minor</b></td></tr>
    <tr><td>&nbsp;</td></tr>
    <tr><td>Version</td><td>Major: <input type=text name=major size=2 maxlength=2> &nbsp; Minor: <input type=text name=minor size=3 maxlength=3></td></tr>
    <tr><td>Change&nbsp;Description:</td><td><input type=text name=description size=100 maxlength=300></td></tr>
    <tr><td>Document File:</td><td><input type=file name=documentfile size=50></td></tr>
    <tr><td colspan=2 align=center><input type=button name=submitupdate value=Submit onClick="doVerifySubmit(document.$args{form});"></td></tr>
    <tr><td colspan=2 align=center><input type=button name=submitnoupdate value='No Change' onClick="doCheckInNoChangeSubmit(document.$args{form});"></td></tr>
    <script language=javascript><!--
        function doVerifySubmit(f) {
            var msg = "";
            if (!isnumeric(f.major.value)) {
                msg += "Major Version must be input as a number.\\n";
            }
            if (!isnumeric(f.minor.value)) {
                msg += "Minor Version must be input as a number.\\n";
            }
            if ((f.major.value == $major && f.minor.value <= $minor) ||
                  (f.major.value < $major) ){
                msg += "Entered version of " + f.major.value + "." + f.minor.value + " is not greater than $major.$minor.\\n";
            }
            if (isblank(f.description.value)) {
                msg += "Change description must be entered.\\n";
            }
            if (isblank(f.documentfile.value)) {
                msg += "File must be selected.\\n";
            }
            if (msg != "") {
                alert (msg);
            } else {
                submitFormCGIResults('$args{form}','updatedocumentprocess')
            }
        }
        function doCheckInNoChangeSubmit(f) {
            submitFormCGIResults('$args{form}','checkinnochange')
        }
    //-->
    </script>
    </table>
    
END_OF_BLOCK
    
    return($output);
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
    my $output = "";
    my $itemID = $args{itemID};
    my $fileContents = $args{file};
    my $name = $args{fileName};
    $name =~ s/\\/\//g;
    $name = substr($name,(rindex($name,'/')+1));
    my $description = $args{description};
    my $major = $args{majorVersion};
    my $minor = $args{minorVersion};

    my $status = $args{dbh}->do("UPDATE $args{schema}.item_version SET status_id = 1 WHERE item_id = $args{itemID} AND status_id = 2");
    $args{dbh}->commit;
    &log_activity($args{dbh},$args{schema},$args{userID},"Document ID $args{itemID} checked in with no change");
    
    my ($project, $type) = $args{dbh}->selectrow_array("SELECT project_id, type_id FROM $args{schema}.configuration_item WHERE id=$args{itemID}");
    $output .= "<input type=hidden name=type value=$type>\n";
    $output .= "<input type=hidden name=project value=$project>\n" if (defined($project));
    $output .= doAlertBox(text => "$name successfully checked in with no change");
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','update');\n";
    $output .= "//--></script>\n";
    
    return($output);
}


###################################################################################################################################
sub buildProjectSelect {
###################################################################################################################################
    my %args = (
        schema => $SCHEMA,
        userID => 0,
        name => 'project',
        @_,
    );
    my $dbh = $args{dbh};
    my $userid = $args{userID};
    tie my %projectlist, "Tie::IxHash";
    %projectlist = &getProjects(dbh => $dbh);
    my $outstring = "";
    $outstring .= "<table cellpadding=4 cellspacing=0 border=0 align=center>\n";
    $outstring .= "<tr><td height=17></td></tr>\n";
    $outstring .= "<tr><td><font size=-1>Project:&nbsp;&nbsp;</font></td><td><select name=$args{name} size=1>\n";
    foreach my $project (keys (%projectlist)) {
        if ($projectlist{$project}{configurationManagerID} == $userid || $projectlist{$project}{projectManagerID} == $userid || &doesUserHavePriv(dbh => $dbh, schema => $args{schema}, userid => $userid, privList => (11)) == 1) {$outstring .= "<option value=$project>$projectlist{$project}{name}\n";}
    }
    $outstring .= <<END_OF_TEXT;
    </select></td></tr>
    </table><br>
END_OF_TEXT
    return($outstring);
}


###################################################################################################################################
sub buildTypeSelect {
###################################################################################################################################
	my ($dbh) = @_;
	tie my %typelist, "Tie::IxHash";
	%typelist = &getItemType(dbh => $dbh);
	my $outstring = "";
	$outstring .= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Item Type:&nbsp;&nbsp;<select name=itemtype size=1>\n";
	foreach my $type (keys (%typelist)) {
		$outstring .= "<option value=$type>$typelist{$type}\n" if ($type >= 13 || $type == 9);
	}
	$outstring .= "</select>\n";
	return($outstring);
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
