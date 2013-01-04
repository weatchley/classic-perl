#
# $Source: /data/dev/rcs/pcl/perl/RCS/UIDocuments.pm,v $
#
# $Revision: 1.20 $ 
#
# $Date: 2003/03/06 17:02:42 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIDocuments.pm,v $
# Revision 1.20  2003/03/06 17:02:42  atchleyb
# fixed bug with session id paramater
#
# Revision 1.19  2003/02/14 21:00:50  atchleyb
# changed Template to Form
#
# Revision 1.18  2003/02/12 18:49:05  atchleyb
# added session management
#
# Revision 1.17  2003/02/10 18:16:51  atchleyb
# removed refs to PCL
#
# Revision 1.16  2003/01/03 18:03:38  atchleyb
# update display format for rev history
#
# Revision 1.15  2002/11/15 17:39:28  atchleyb
# updated to removed refferences to RCS code
# added functions to display checkout table that could be called by other modules
#
# Revision 1.14  2002/11/08 20:29:05  atchleyb
# updated calling format for doesUserHavePriv
#
# Revision 1.13  2002/11/07 23:37:27  atchleyb
# updated html form parameter name sent in from utilities screen
# fixed bug in function called from home and browse screens, usename was not being correctly put in the form
# updated display of version numbers for check in and check out
#
# Revision 1.12  2002/11/06 21:45:17  atchleyb
# updated to allow check in from the home page
#
# Revision 1.11  2002/10/31 21:54:36  atchleyb
# updated add and update document functions to get the project id from the utilities screen/form
#
# Revision 1.10  2002/10/31 17:31:20  atchleyb
# updated to change defaults for using jswidgets
#
# Revision 1.9  2002/10/21 22:22:07  atchleyb
# change user_functions.pl to users.pl
#
# Revision 1.8  2002/10/18 17:03:32  atchleyb
# updated to allow procedures and templates to be in different table sets
#
# Revision 1.7  2002/10/03 16:31:54  atchleyb
# added function to display signed documents (PDF's)
#
# Revision 1.6  2002/09/26 21:05:01  atchleyb
# renamed module
# updated to only contin UI code
#
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
package UIDocuments;
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Tables qw(:Functions);
use DBDocuments qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use Carp;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &doBrowseDocumentTable               &doBrowseDocumentVersions            &doAddDocumentForm
      &doDisplayDocument                   &doUpdateDocumentForm                &doAddDocument
      &doUpdateDocumentInfoForm            &buildProjectSelect                  &doDisplaySignedDocument
      &buildTypeSelect                     &displayNonCodeItemsTables           &doUpdateSelect
      &doHeader                            &doFooter                            &getInitialValues
      &doCheckOutDocument                  &doUpdateDocumentInfo                &doUpdateDocument
      &doCheckInNoChange                   &displayNonCodeCheckedOutItemsTable  &displayNonCodeItemCheckOutTable
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doBrowseDocumentTable               &doBrowseDocumentVersions            &doAddDocumentForm
      &doDisplayDocument                   &doUpdateDocumentForm                &doAddDocument
      &doUpdateDocumentInfoForm            &buildProjectSelect                  &doDisplaySignedDocument
      &buildTypeSelect                     &displayNonCodeItemsTables           &doUpdateSelect
      &doHeader                            &doFooter                            &getInitialValues
      &doCheckOutDocument                  &doUpdateDocumentInfo                &doUpdateDocument
      &doCheckInNoChange                   &displayNonCodeCheckedOutItemsTable  &displayNonCodeItemCheckOutTable
    )]
);

my $mycgi = new CGI;

###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub getInitialValues {  # routine to get initial CGI values and return in a hash
###################################################################################################################################
    my %args = (
        dbh => "",
        @_,
    );
    
    my %valueHash = (
       schema => (defined($mycgi->param("schema"))) ? $mycgi->param("schema") : $ENV{'SCHEMA'},
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "browse",
       username => (defined($mycgi->param("username"))) ? $mycgi->param("username") : "",
       userid => (defined($mycgi->param("userid"))) ? $mycgi->param("userid") : "",
       projectID => (defined($mycgi->param("projectID"))) ? $mycgi->param("projectID") : 0,
       itemType => (defined($mycgi->param("type"))) ? $mycgi->param("type") : 0,
       document => (defined($mycgi->param("document"))) ? $mycgi->param("document") : 0,
       majorversion => (defined($mycgi->param("majorversion"))) ? $mycgi->param("majorversion") : 0,
       minorversion => (defined($mycgi->param("minorversion"))) ? $mycgi->param("minorversion") : 0,
       project => (defined($mycgi->param("project"))) ? $mycgi->param("project") : 0,
       nonLNproject => (defined($mycgi->param("nonLNproject"))) ? $mycgi->param("nonLNproject") : 0,
       major => (defined($mycgi->param("major"))) ? $mycgi->param("major") : 0,
       minor => (defined($mycgi->param("minor"))) ? $mycgi->param("minor") : 0,
       description => (defined($mycgi->param("description"))) ? $mycgi->param("description") : 0,
       itemid => (defined($mycgi->param("itemid"))) ? $mycgi->param("itemid") : 0,
       documentfile => (defined($mycgi->param("documentfile"))) ? $mycgi->param("documentfile") : 0,
       itemTypeEntry => (defined($mycgi->param("itemtype"))) ? $mycgi->param("itemtype") : 0,
       name => (defined($mycgi->param("name"))) ? $mycgi->param("name") : 0,
       sessionID => (defined($mycgi->param("sessionid"))) ? $mycgi->param("sessionid") : "0",
    );
    $valueHash{title} = &selectTitle(dbh => $args{dbh}, schema => $valueHash{schema}, itemType => $valueHash{itemType});
    %valueHash = &setDBTables(settings => \%valueHash);
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        schema => $ENV{SCHEMA},
        title => 'Document Management',
        displayTitle => 'T',
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $form = $args{form};
    my $path = $args{path};
    my $username = $settings{username};
    my $userid = $settings{userid};

    my $extraJS = "";
    $extraJS .= <<END_OF_BLOCK;
       function displayVersions(documentID, type) {
           $form.command.value = 'browseversion';
           $form.document.value = documentID;
           $form.type.value = type;
           $form.action = '$path$form.pl';
           $form.target = 'main';
           $form.submit();
       }
       function displayDocument(document,type) {
          var myDate = new Date();
          var winName = myDate.getTime();
          $form.command.value = 'displaydocument';
          $form.document.value = document;
          //$form.majorversion.value = major;
          //$form.minorversion.value = minor;
          $form.type.value = type;
          $form.action = '$path$form.pl';
          $form.target = winName;
          var newwin = window.open('',winName);
          newwin.creator = self;
          $form.submit();
       }
       function displayDocumentPDF(document,type) {
          var myDate = new Date();
          var winName = myDate.getTime();
          $form.command.value = 'displaysigneddocument';
          $form.document.value = document;
          //$form.majorversion.value = major;
          //$form.minorversion.value = minor;
          $form.type.value=type;
          $form.action = '$path$form.pl';
          $form.target = winName;
          var newwin = window.open('',winName);
          newwin.creator = self;
          $form.submit();
       }
       function updateVersion(documentID,type) {
           document.$form.document.value=documentID;
           $form.type.value = type;
           submitForm('$form','updatedocument');
       }
       function updateDocumentInfoformation(documentID,type) {
           document.$form.document.value=documentID;
           document.$form.type.value = type;
           submitForm('$form','updateinformation');
       }
       function checkOutDocument(document,type) {
           $form.document.value = document;
           //$form.majorversion.value = major;
           //$form.minorversion.value = minor;
           $form.type.value = type;
           submitFormCGIResults ('$form', 'checkoutdocument');
       }
END_OF_BLOCK
    
    $output .= &doStandardHeader(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, useFileUpload => 'T',
              includeJSUtilities => 'T', includeJSWidgets => 'F');

    $output .= "<input type=hidden name=type value=''>\n";
    $output .= "<input type=hidden name=document value=''>\n";
    $output .= "<input type=hidden name=majorversion value=''>\n";
    $output .= "<input type=hidden name=minorversion value=''>\n";

    
    return($output);
}


###################################################################################################################################
sub doFooter {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        username => "",
        userID => 0,
        @_,
    );
    my $output = "";
    my $extraHTML = "";
    
    $output .= &doStandardFooter(extraHTML => $extraHTML);
    
    return($output);
}


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
        nonCode => 'T',
        update => 'F',
        fromExternal => 'F',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    $args{status} = ($args{update} eq "T" && $args{status} == 0) ? 1 : $args{status};
    my @docList = &getDocumentList(dbh => $args{dbh}, schema => $args{schema}, project => $args{project}, itemType => $args{itemType}, 
                                   status => $args{status}, userID => $args{userID}, nonCode => $args{nonCode}, settings => \%settings);
    my $numColumns = 6;
    #if ($args{update} eq 'F' || $args{itemType} >= 10 && $args{itemType} <= 12) {
    if ($args{update} eq 'F') {
        #$numColumns += (($args{update} eq 'T') ? 1 : 0);
        $numColumns = $numColumns - 1;
        $output .= &startTable(columns => $numColumns, title => "$args{title}<yyy> (xxx)", width => 750);
        $output .= &startRow (bgColor => "#f0f0f0");
        $output .= &addCol (value => "Name", align => "center");
        $output .= &addCol (value => "Current Version", align => "center");
        $output .= &addCol (value => "Status", align => "center");
        $output .= &addCol (value => "Created / Last Revised", align => "center");
        $output .= &addCol (value => "Description", align => "center");
        my $text = (($args{status} ==0 || $args{status}==1) ? "Check Out" : "Check In");
        $output .= (($args{update} eq 'T') ? &addCol (value => $text, align => "center") : "");
    } else {
        $numColumns += (($args{project} == 0 && ($args{itemType} < 10 || $args{itemType} > 12)) ? 1 : 0);
        $output .= &startTable(columns => $numColumns, title => "$args{title}<yyy> (xxx)", width => 750);
        $output .= &startRow (bgColor => "#f0f0f0");
        $output .= (($args{project} == 0 && ($args{itemType} < 10 || $args{itemType} > 12)) ? &addCol (value => "Project", align => "center") : "");
        $output .= &addCol (value => "Item Name", align => "center");
        $output .= &addCol (value => "Item Type", align => "center");
        $output .= &addCol (value => "Versions", align => "center");
        $output .= &addCol (value => "Last Revised", align => "center", width => 110);
        $output .= &addCol (value => "Description", align => "center");
        my $text = (($args{status} ==0 || $args{status}==1) ? "Check Out" : "Check In");
        $output .= &addCol (value => $text, align => "center");
    }
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    
    my $count = 0;
    
    
    for (my $i = 0; $i < $#docList; $i++) {
        my ($id,$name,$pid,$descr,$itemType,$verID,$major,$minor,$date,$statusID,$status,$developer,$locker, $acronym, $creator, $creationDate) = 
          ($docList[$i]{id},$docList[$i]{name},$docList[$i]{pid},$docList[$i]{descr},$docList[$i]{itemType},$docList[$i]{verID},$docList[$i]{major},
          $docList[$i]{minor},$docList[$i]{date},$docList[$i]{statusID},$docList[$i]{status},$docList[$i]{developer},$docList[$i]{locker},
          $docList[$i]{projAcronym},$docList[$i]{creator},$docList[$i]{creationDate});
        $count++;
        $output .= &startRow;
        $output .= (($args{project} == 0 && $args{update} eq 'T' && ($args{itemType} > 12 || $args{itemType} == 0)) ? &addCol(value=>$acronym) : "");
        my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, ID => $itemType, settings => \%settings);
        my $hasMime = ((defined($mimeType)) ? "T" : "F");
        my $url;
        my $prompt = "";
        my $checkInOut = "&nbsp;";
        my $checkInOutURL = "";
        my $checkInOutPrompt = "";
        $name =~ s/\..{0,3}$//;
        if ($args{update} ne 'T') {
        } else {
            if ($statusID == 1) {
                $checkInOut = "Check Out";
                $checkInOutPrompt = "Click here to check out $name";
                #$checkInOutURL = "javascript:checkOutDocument($id,$major,$minor)";
                $checkInOutURL = "javascript:checkOutDocument($verID,$itemType)";
            } elsif ($statusID == 2 && $locker == $args{userID}) {
                $checkInOut = "Check In";
                $checkInOutPrompt = "Click here to check in $name";
                #$checkInOutURL = "javascript:updateVersion($id)";
                $checkInOutURL = "javascript:updateVersion($id,$itemType)";
            }
        }
        $url = "javascript:displayVersions($id,$itemType)";
        $output .= &addCol (value=>$name, url => $url, prompt => "Click here for complete version history of $name");
        #if ($args{update} eq 'T' && ($args{itemType} > 12 || $args{itemType} == 0)) {
        if ($args{update} eq 'T') {
            my @items = &getItemTypeArray(dbh => $args{dbh}, schema => $args{schema}, selection => "id=$itemType");
            $output .= &addCol (value=>$items[0]{type});
        }
        $url = (($hasMime eq "T") ? "javascript:displayDocument($verID,$itemType)" : "");
        my $value = "";
        if ($hasMime eq 'T') {
            $value .= "<a href=$url title='Click here to display $name'>" . (("$major" ne "0") ? "$major.$minor" : "Draft $minor") . "</a>";
        } else {
            $value .= (("$major" ne "0") ? "$major.$minor" : "Draft&nbsp;$minor");
        }
        my $newMinor = $minor + 1;
        $value .= (($args{update} eq 'T' && $statusID == 2) ? (" => " . (("$major" ne "0") ? "$major.$newMinor" : "Draft&nbsp;$newMinor")) : "");
        $url = "<a href=\"javascript:displayDocumentPDF($verID,$itemType)\" title='Click here to display $name PDF'>";
        $value .= ((hasSignedImage(dbh => $args{dbh}, schema => $args{schema}, ID => $id, majorVersion => $major, minorVersion => $minor, settings => \%settings)) ? " $url" . "PDF</a>" : "");
        $output .= &addCol (value=>$value, align => "center");
        if ($args{update} eq 'T') {
            $output .= &addCol (value=>$date, align => "center");
        }
        #if ($args{update} eq 'F' || ($args{itemType} >= 10 && $args{itemType} <= 12)) {
        if ($args{update} eq 'F') {
            my $lockerLink = '';
            if ($statusID == 2) {
                my $lockerName = getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $locker);
                $lockerLink = " by<br><a href=\"javascript:displayUser($locker)\" title=\"Click here to browse information for $lockerName\">$lockerName</a>";
            }
            $output .= &addCol (value=>$status . $lockerLink , align => "center");
            $url = "javascript:displayUser($developer)";
            my $fullName = getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $creator);
            $value = "C: &nbsp;$creationDate by <a href=$url title='Click here to browse information for $fullName'>$fullName</a>";
            $fullName = getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $developer);
            if ($date ne $creationDate) {
                $value .= "<br>R: &nbsp;$date by <a href=$url title='Click here to browse information for $fullName'>$fullName</a>";
            }
            $output .= &addCol (value=>$value, align => "center");
        }
        $url = "";
        $prompt = "";
        if ($args{update} eq 'T' && ($args{status} == 0 || $args{status} == 1)) {
            $url = "javascript:updateDocumentInfoformation($id,$itemType)";
            $prompt = "Click here to update document information for $name";
        }
        $output .= &addCol (value=>((defined($descr)) ? $descr : "none given"), url => $url, prompt => $prompt);
        $output .= (($args{update} eq 'T') ? &addCol (value => $checkInOut, url => $checkInOutURL, align => "center", prompt => $checkInOutPrompt) : "");
        $output .= &endRow;
    }
    $output .= &endTable();
    
    $output =~ s/xxx/$count/;
    $output =~ s/<yyy>// if ($args{itemType} > 12 || $args{fromExternal} eq 'T');
    $output =~ s/<yyy>/s/ if ($count != 1);
    $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    $output = '' if ($count == 0);
    return($output);
}


###################################################################################################################################
sub createNonCodeItemsForm {  # routine to create a form for use in non documents scripts
###################################################################################################################################
    my %args = (
        form => 'displayNonCodeItemsTablesForm',
        path => '',
        userID => 0,
        userName => '',
        sessionID => 0,
        @_,
    );
    my $output = '';
    my $path = $args{path};
    my $username = $args{userName};
    $output .= <<END_OF_BLOCK;
    <script language=javascript><!--
       function displayVersions(documentID,type) {
           $args{form}.command.value = 'browseversion';
           $args{form}.document.value = documentID;
           $args{form}.type.value = type;
           $args{form}.action = '$path/documents.pl';
           $args{form}.target = 'main';
           $args{form}.submit();
       }
       function displayDocument(document,type) {
          var myDate = new Date();
          var winName = myDate.getTime();
          $args{form}.command.value = 'displaydocument';
          $args{form}.document.value = document;
          $args{form}.type.value = type;
          $args{form}.action = '$path/documents.pl';
          $args{form}.target = winName;
          var newwin = window.open('',winName);
          newwin.creator = self;
          $args{form}.submit();
       }
       function displayDocumentPDF(document,type) {
          var myDate = new Date();
          var winName = myDate.getTime();
          $args{form}.command.value = 'displaysigneddocument';
          $args{form}.document.value = document;
          $args{form}.type.value=type;
          $args{form}.action = '$path/documents.pl';
          $args{form}.target = winName;
          var newwin = window.open('',winName);
          newwin.creator = self;
          $args{form}.submit();
       }
       function displayUser(id) {
           $args{form}.id.value = id;
           $args{form}.command.value = 'displayuser';
           $args{form}.action = '$path/users' + '.pl';
           $args{form}.target = 'main';
           $args{form}.submit();
       }
       function updateVersion(documentID,type) {
           $args{form}.document.value=documentID;
           $args{form}.type.value = type;
           $args{form}.command.value = 'updatedocument';
           $args{form}.target = 'main';
           $args{form}.action = '$path/documents' + '.pl';
           $args{form}.submit();
       }
       function updateDocumentInfoformation(documentID,type) {
           $args{form}.document.value=documentID;
           $args{form}.type.value = type;
           $args{form}.command.value = 'updateinformation';
           $args{form}.target = 'main';
           $args{form}.action = '$path/documents' + '.pl';
           $args{form}.submit();
       }
       function checkOutDocument(document,type) {
           $args{form}.document.value = document;
           $args{form}.type.value = type;
           $args{form}.command.value = 'checkoutdocument';
           $args{form}.target = 'cgiresults';
           $args{form}.action = '$path/documents' + '.pl';
           $args{form}.submit();
       }
    //-->
    </script>
    <form name=$args{form} method=post target=main action=dummy.pl>
    <input type=hidden name=userid value=$args{userID}>
    <input type=hidden name=username value=$username>
    <input type=hidden name=schema value=$args{schema}>
    <input type=hidden name=command value=''>
    <input type=hidden name=document value=''>
    <input type=hidden name=type value=0>
    <input type=hidden name=id value=''>
    <input type=hidden name=sessionid value='$args{sessionID}'>
    <input type=hidden name=majorversion value=''>
    <input type=hidden name=minorversion value=''>
    </form>
END_OF_BLOCK
    
    return($output);
}


###################################################################################################################################
sub displayNonCodeItemsTables {  # routine to display a table of documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        userID => 0, # all
        title => 'Non-Code Configuration Item',
        update => 'F',
        fromExternal => 'F',
        status => 0,
        sessionID => 0,
        @_,
    );
    my %settings = (
        itemType => 0,
    );
    %settings = &setDBTables(settings => \%settings);
    my $output = '';
    #my $username = '';
    my $username = &getUserName(dbh =>$args{dbh}, schema => $args{schema}, userID => $args{userID});
    my $path = "/cgi-bin/" . lc($ENV{SYSType});
    my $status = (($args{update} eq 'T' && $args{status} == 0) ? 2 : $args{status});

    $output .= &createNonCodeItemsForm(schema => $args{schema}, userID => $args{userID}, path => $path, userName => $username, sessionID => $args{sessionID});

    my $title = $args{title};
    my $displayed = 'F';
    if ($args{update} eq 'T' && $status == 2) {
        $title = "All Non-Code Configuration Items Checked Out by User <font size=-1>" . &getUserName(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}) . "</font>";
    } elsif ($args{update} eq 'T' && $status == 1) {
        my %projInfo = &getProjectInfo(dbh => $args{dbh}, schema => $args{schema}, projectId => $args{project});
        $title = $projInfo{acronym} . " Non-Code Items Available for Check Out";
    }
    $output .= &doBrowseDocumentTable(dbh => $args{dbh}, schema => $args{schema}, itemType => 0, title => $title, userID => $args{userID}, 
              project => $args{project}, update => $args{update}, status => $status, fromExternal => $args{fromExternal}, settings => \%settings);
    if ($args{update} eq 'T' && $status == 2) {
        $title = "All Procedures Checked Out by User <font size=-1>" . & getUserName(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}) . "</font>";
        $settings{itemType} = 10;
        %settings = &setDBTables(settings => \%settings);
        my $temp = &doBrowseDocumentTable(dbh => $args{dbh}, schema => $args{schema}, itemType => 10, title => $title, userID => $args{userID}, 
              project => $args{project}, update => $args{update}, status => $status, fromExternal => $args{fromExternal}, settings => \%settings);
        $displayed = 'T' if ($temp gt " ");
        $output .= "<br><br>" . $temp if ($temp gt " ");
        $title = "All Forms Checked Out by User <font size=-1>" . & getUserName(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}) . "</font>";
        $settings{itemType} = 11;
        %settings = &setDBTables(settings => \%settings);
        $temp = &doBrowseDocumentTable(dbh => $args{dbh}, schema => $args{schema}, itemType => 11, title => $title, userID => $args{userID}, 
              project => $args{project}, update => $args{update}, status => $status, fromExternal => $args{fromExternal}, settings => \%settings);
        $displayed = 'T' if ($temp gt " ");
        $output .= "<br>" . $temp if ($temp gt " ");
        if ($SYSProductionStatus == 0) {
            $title = "All Policies Checked Out by User <font size=-1>" . & getUserName(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}) . "</font>";
            $settings{itemType} = 12;
            %settings = &setDBTables(settings => \%settings);
            $temp = &doBrowseDocumentTable(dbh => $args{dbh}, schema => $args{schema}, itemType => 12, title => $title, userID => $args{userID}, 
              project => $args{project}, update => $args{update}, status => $status, fromExternal => $args{fromExternal}, settings => \%settings);
            $displayed = 'T' if ($temp gt " ");
            $output .= "<br>" . $temp if ($temp gt " ");
        }
        $output .= "<br>\n" if ($displayed eq "T");
    }
    return($output);
}


###################################################################################################################################
sub displayNonCodeCheckedOutItemsTable {  # routine to display a table of checked out documents
###################################################################################################################################
    my %args = (
        project => 0,  # null
        userID => 0, # all
        title => 'Non-Code Configuration Item',
        update => 'T',
        sessionID => 0,
        @_,
    );
    my $output = '';
    $output .= &displayNonCodeItemsTables(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, update => $args{update},
          project => $args{project}, userID => $args{userID}, fromExternal => 'T', sessionID => $args{sessionID});
    return($output);
}


###################################################################################################################################
sub displayNonCodeItemCheckOutTable {  # routine to display a table of documents for check out
###################################################################################################################################
    my %args = (
        project => 0,  # null
        userID => 0, # all
        title => 'Non-Code Configuration Item',
        update => 'T',
        status => 1,
        @_,
    );
    my $output = '';
    $output .= &displayNonCodeItemsTables(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, update => $args{update},
          project => $args{project}, userID => $args{userID}, fromExternal => 'T', status => $args{status});
    return($output);
}


###################################################################################################################################
sub doUpdateSelect {  # routine to display a table of documents that a user can update, by project
###################################################################################################################################
    my %args = (
        userID => 0, # all
        title => 'Non-Code Items Available for Checkout',
        form => '',
        status => 0, # use 1 to display only items available for checkout, 0 for all
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $username = '';
    my @items = &getProjectArray(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, authorized => 'T', 
                                 project => $settings{nonLNproject});
    for (my $i=0; $i < $#items; $i++) {
        my ($id, $name, $acronym) = ($items[$i]{id}, $items[$i]{name}, $items[$i]{acronym});
        my @project = ($id, lc($acronym));
        $output .= &doBrowseDocumentTable(dbh => $args{dbh}, schema => $args{schema}, title => "$args{title}", userID => $args{userID}, 
              project => $id, update => 'T', form => $args{form}, status => $args{status}, settings => \%settings);
        $output .= (((substr($output,-4) ne "<br>") && (substr($output,-8) ne "</form>\n")) ? "<br><br>" : "");
    }
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
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $numColumns = 4;
    my @docList = &getDocumentList(dbh => $args{dbh}, schema => $args{schema}, itemType => $settings{itemType}, document => $args{document}, settings => \%settings);
    my ($name, $documentDescription, $itemType) = ($docList[0]{name},$docList[0]{description}, $docList[0]{itemType});
    $name =~ s/\..{0,3}$//;
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
    
    my $count = 0;
    #my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, ID => $args{document}, IDSource => "item_version", settings => \%settings);
    my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, ID => $itemType, settings => \%settings);
    my $hasMime = ((defined($mimeType)) ? "T" : "F");
    my @items = &getVersionList(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, settings => \%settings);
    
    for (my $i=0; $i<$#items; $i++) {
        my ($id,$itemid,$descr,$major,$minor,$date,$statusID,$status,$developer,$locker) = ($items[$i]{id},$items[$i]{itemid},$items[$i]{descr},$items[$i]{major},
            $items[$i]{minor},$items[$i]{date},$items[$i]{statusID},$items[$i]{status},$items[$i]{developer},$items[$i]{locker});
        my $temp = $status . (($statusID == 2) ? " by " . getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $locker) : "");
        $output =~ s/--status--/$temp/;
        $count++;
        $output .= &startRow;
        my $url = (($hasMime eq "T") ? "javascript:displayDocument($id,$settings{itemType})" : "");
        my $value = "";
        if ($hasMime eq 'T') {
            $value .= "<a href=$url title='Click here to display document'>" . (("$major" ne "0") ? "$major.$minor" : "Draft $minor") . "</a>";
        } else {
            $value .= (("$major" ne "0") ? "$major.$minor" : "Draft&nbsp;$minor");
        }
        $url = "<a href=\"javascript:displayDocumentPDF($id,$settings{itemType})\" title='Click here to display signed PDF'>";
        $value .= ((hasSignedImage(dbh => $args{dbh}, schema => $args{schema}, ID => $id, majorVersion => $major, 
                minorVersion => $minor, settings => \%settings)) ? " $url" . "PDF</a>" : "");
        $output .= &addCol (value=>$value, align => "center");
        $output .= &addCol (value=>$date, align => "center");
        $output .= &addCol (value=>getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $developer), align => "center");
        $output .= &addCol (value=>((defined($descr)) ? $descr : "none given"));
        $output .= &endRow;
    }
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
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    
    $output .= "<input type=hidden name=itemtype value=$args{itemType}>\n" if ($args{itemType} != 0);
    $output .= "<input type=hidden name=project value=$args{project}>\n";
    if ($args{itemType} < 10 || $args{itemType} > 12) {
        my @items = &getProjectArray(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, authorized => 'T', 
                                     project => $args{project});
        $output .= "<center><b>$items[0]{description}</b><br>&nbsp;</center>\n";
    }
    $output .= <<END_OF_BLOCK;
    <input type=hidden name=itemid value=0>
    <table border=0 width=750 align=center>
    <tr><td>Description:</td><td><input type=text name=description size=100 maxlength=250></td></tr>
END_OF_BLOCK
    $output .= "<tr><td colspan=2><hr></td></tr>\n" if ($args{itemType} == 0);
    $output .= "<tr><td>Version</td><td>Major: <input type=text name=major size=2 maxlength=2> &nbsp; Minor: <input type=text name=minor size=3 maxlength=3>\n";
    $output .= &buildTypeSelect($args{dbh}) if ($args{itemType} == 0);
    $output .= "</td></tr><tr><td>Document File:</td><td><input type=file name=documentfile size=50></td></tr>\n";
    $output .= "<tr><td colspan=2 align=center><input type=button name=submitadd value='Submit" . (($args{itemType} == 0) ? " Non-Code" : "") . "' onClick=\"doVerifySubmit(document.$args{form});\"></td></tr>\n";
    if ($args{itemType} == 0) {
        $output .= "<tr><td colspan=2><hr></td></tr>\n";
        $output .= "<tr><td>Code File Name:</td><td><input type=text name=codefilename size=50></td></tr>\n";
        $output .= "<tr><td colspan=2 align=center><input type=button name=submitadd value='Submit Code' onClick=\"doVerifyCodeSubmit(document.$args{form});\"></td></tr>\n";
    }
    $output .= <<END_OF_BLOCK;
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
                $args{form}.type.value = $args{itemType};
                submitFormCGIResults('$args{form}','addprocess');
            }
        }
        function doVerifyCodeSubmit(f) {
        //alert(f.name);
            var msg = "";
            if (isblank(f.description.value)) {
                msg += "Description must be input.\\n";
            }
            if (isblank(f.codefilename.value)) {
                msg += "File must be selected.\\n";
            }
            if (msg != "") {
                alert (msg);
            } else {
                alert('Not yet ready');
                //submitFormCGIResults('$args{form}','addprocess');
            }
        }
    //-->
    </script>
    </table>
    
END_OF_BLOCK
    
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
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, ID => $args{document}, IDSource => "item_version", settings => \%settings);
#    my %itemHash = &getDocumentVersion(dbh => $args{dbh}, schema => $args{schema}, ID => $args{document}, settings => \%settings);
    my %itemHash = &getDocumentVersion;
    $output .= "Content-type: $mimeType\n\n";
    $output .= $itemHash{item_image};
    
    return($output);
}


###################################################################################################################################
sub doDisplaySignedDocument {  # routine to display a PDF of a document from the DB
###################################################################################################################################
    my %args = (
        document => 0,
        majorVersion => 0,
        minorVersion => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
#    my %itemHash = &getDocumentVersion(dbh => $args{dbh}, schema => $args{schema}, ID => $args{document}, settings => \%settings);
    my %itemHash = &getDocumentVersion;
    $output .= "Content-type: application/pdf\n\n";
    $output .= $itemHash{signed_image};
    
    return($output);
}


###################################################################################################################################
sub doUpdateDocumentInfoForm {  # routine to display form for updating document information
###################################################################################################################################
    my %args = (
        document => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my %item = &getConfigurationItem(dbh => $args{dbh}, schema => $args{schema}, ID => $args{document}, settings => \%settings);
    my ($id,$name,$source_id,$type_id,$project_id,$description) = 
          ($item{id},$item{name},$item{source_id},$item{type_id},$item{project_id},$item{description});
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
            //if (isblank(f.name.value)) {
            //    msg += "Name must be entered.\\n";
            //}
            if (isblank(f.description.value)) {
                msg += "Document description must be entered.\\n";
            }
            if (msg != "") {
                alert (msg);
            } else {
                //submitFormCGIResults('DocumentUpload','addprocess');
                $args{form}.type.value=$settings{itemType};
                submitFormCGIResults('$args{form}','updateinformationprocess');
            }
        }
    //-->
    </script>
    </table>
    
END_OF_BLOCK
    
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
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    
    my @docList = &getDocumentList(dbh => $args{dbh}, schema => $args{schema}, itemType => $args{itemType}, document => $args{document}, settings => \%settings);
    my ($id,$descr,$major,$minor,$status,$developer) = ($docList[0]{id},$docList[0]{description},$docList[0]{major_version},$docList[0]{minor_version},$docList[0]{status_id},$docList[0]{developer_id});
    my $nextMinor = $minor + 1;

    $output .= <<END_OF_BLOCK;
    <input type=hidden name=itemtype value=$args{itemType}>
    <input type=hidden name=project value=$args{project}>
    <input type=hidden name=itemid value=$args{document}>
    <table border=0 width=750 align=center>
    <tr><td colspan=2 align=center><font size=+1><b>$descr</b></font><br>Latest Revision: <b>$major.$minor</b></td></tr>
    <tr><td>&nbsp;</td></tr>
    <tr><td>Version</td><td>Major: <input type=text name=major size=2 maxlength=2 value=$major> &nbsp; Minor: <input type=text name=minor size=3 maxlength=3 value=$nextMinor></td></tr>
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
                $args{form}.type.value = $args{itemType};
                submitFormCGIResults('$args{form}','updatedocumentprocess')
            }
        }
        function doCheckInNoChangeSubmit(f) {
            $args{form}.type.value = $args{itemType};
            submitFormCGIResults('$args{form}','checkinnochange')
        }
    //-->
    </script>
    </table>
    
END_OF_BLOCK
    
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
        if ($projectlist{$project}{configurationManagerID} == $userid || $projectlist{$project}{projectManagerID} == $userid || 
            &doesUserHavePriv(dbh => $dbh, schema => $args{schema}, userid => $userid, privList => [11]) == 1) 
                {$outstring .= "<option value=$project>$projectlist{$project}{name}\n";}
    }
    $outstring .= <<END_OF_TEXT;
    </select></td></tr>
    </table><br>
END_OF_TEXT
    return($outstring);
}


###################################################################################################################################
sub doAddDocument {  # routine to insert a new document into the DB
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

    my $status = &doProcessAddDocument(dbh => $args{dbh}, schema => $args{schema}, itemType => $args{'itemType'}, 
              project => $args{'project'}, title => $args{title}, 
              form => $args{form}, file => $args{file}, fileName => $args{fileName}, majorVersion => $args{'majorVersion'}, minorVersion => $args{'minorVersion'}, 
              description => $args{'description'}, userID => $args{userID}, userName => $args{userName}, settings => \%settings);
    
    my $tempText = $args{fileName};
    $tempText =~ s/\\/\\\\/g;
    $output .= doAlertBox(text => "$tempText successfully inserted");
    $output .= "<script language=javascript><!--\n";
    $output .= "   changeMainLocation('utilities');\n";
    $output .= "//--></script>\n";
    
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
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    
    my ($status, $project, $type) = &doCheckOutDocumentDB(dbh => $args{dbh}, schema => $args{schema}, itemType => $args{itemType}, document => $args{'document'},
                majorVersion => $args{'majorVersion'}, minorVersion => $args{'minorVersion'}, userID => $args{userID}, form => $args{form}, settings => \%settings);

    $output .= "<input type=hidden name=project value=$project>\n" if (defined($project));
    $output .= "<script language=javascript><!--\n";
    $output .= "   $args{form}.type.value=$settings{itemType};\n";
    if ($type < 10 || $type > 12) {
        $output .= "   submitForm('project_items','checkout');\n";
    } else {
        $output .= "   submitForm('$args{form}','update');\n";
    }
    $output .= "//--></script>\n";
    
    return($output);
}


###################################################################################################################################
sub doUpdateDocumentInfo {  # routine to update document information
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

    my ($status, $project, $type) =  &doProcessUpdateDocumentInfo(dbh => $args{dbh}, schema => $args{schema}, document => $args{'document'}, 
              name => $args{'name'}, description => $args{'description'}, title => $args{title}, form => $args{form}, userID => $args{userID}, 
              project => $args{'project'}, settings => \%settings);

    $output .= "<input type=hidden name=project value=$project>\n" if (defined($project));
    $output .= doAlertBox(text => "Update was successful");
    $output .= "<script language=javascript><!--\n";
    $output .= "   $args{form}.type.value=$settings{itemType};\n";
    if ($type < 10 || $type > 12) {
        $output .= "   submitForm('project_items','checkout');\n";
    } else {
        $output .= "   submitForm('$args{form}','update');\n";
    }
    $output .= "//--></script>\n";
    $output .= "//--></script>\n";
    
    return($output);
}


###################################################################################################################################
sub doUpdateDocument {  # routine to insert a document update into the DB
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

    my ($status, $project, $type) = &doProcessUpdateDocument(dbh => $args{dbh}, schema => $args{schema}, itemID => $args{'itemID'}, title => $args{title}, form => $args{form}, 
              file => $args{file}, fileName => $args{fileName}, majorVersion => $args{'majorVersion'}, minorVersion => $args{'minorVersion'}, 
              description => $args{'description'}, userID => $args{userID}, userName => $args{userName}, settings => \%settings);

    $output .= "<input type=hidden name=project value=$project>\n" if (defined($project));
    my $tempText = $args{fileName};
    $tempText =~ s/\\/\\\\/g;
    $output .= doAlertBox(text => "$tempText successfully inserted/updated");
    $output .= "<script language=javascript><!--\n";
    $output .= "   $args{form}.type.value=$settings{itemType};\n";
    #$output .= "   submitForm('$args{form}','update');\n";
    $output .= "   submitForm('home','');\n";
    $output .= "//--></script>\n";
    
    return($output);
}


###################################################################################################################################
sub doCheckInNoChange {  # routine to checkin a document with no change
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

    my ($status, $project, $type) = &doProcessCheckInNoChange(dbh => $args{dbh}, schema => $args{schema}, itemID => $args{'itemID'}, 
              title => $args{title}, form => $args{form}, userID => $args{userID}, userName => $args{userName}, settings => \%settings);

    $output .= "<input type=hidden name=project value=$project>\n" if (defined($project));
    $output .= doAlertBox(text => "$args{fileName} successfully checked in with no change");
    $output .= "<script language=javascript><!--\n";
    $output .= "   $args{form}.type.value=$settings{itemType};\n";
    #$output .= "   submitForm('$args{form}','update');\n";
    $output .= "   submitForm('home','');\n";
    $output .= "//--></script>\n";
    
    return($output);
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


1; #return true
