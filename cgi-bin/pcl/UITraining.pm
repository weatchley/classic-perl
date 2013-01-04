#
# $Source: /data/dev/rcs/pcl/perl/RCS/UITraining.pm,v $
#
# $Revision: 1.6 $ 
#
# $Date: 2003/02/12 18:53:18 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UITraining.pm,v $
# Revision 1.6  2003/02/12 18:53:18  atchleyb
# added session management
#
# Revision 1.5  2003/02/03 20:16:55  atchleyb
# removed refs to SCM
#
# Revision 1.4  2002/11/29 22:11:08  atchleyb
# added popup messages for links
#
# Revision 1.3  2002/11/27 20:58:43  atchleyb
# updated main browse screen to not show inactive users.
#
# Revision 1.2  2002/11/07 23:50:31  atchleyb
# updated to include ui widgets javascripts
#
# Revision 1.1  2002/10/31 17:07:05  atchleyb
# Initial revision
#
#
#
#
package UITraining;
use strict;
use SharedHeader qw(:Constants);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Tables qw(:Functions);
use DBTraining qw(:Functions);
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
      &doHeader                     &doFooter                     &getInitialValues
      &doBrowseSample               &doAddTrainingRecordForm      &doBrowseUserTraining
      &doDisplayTrainingCertificate &doBrowseProcedureTraining
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doHeader                     &doFooter                     &getInitialValues
      &doBrowseSample               &doAddTrainingRecordForm      &doBrowseUserTraining
      &doDisplayTrainingCertificate &doBrowseProcedureTraining
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
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
       majorversion => (defined($mycgi->param("majorversion"))) ? $mycgi->param("majorversion") : "",
       minorversion => (defined($mycgi->param("minorversion"))) ? $mycgi->param("minorversion") : "",
       major => (defined($mycgi->param("major"))) ? $mycgi->param("major") : "",
       minor => (defined($mycgi->param("minor"))) ? $mycgi->param("minor") : "",
       itemid => (defined($mycgi->param("itemid"))) ? $mycgi->param("itemid") : "",
       traininguserid => (defined($mycgi->param("traininguserid"))) ? $mycgi->param("traininguserid") : "",
       procedureid => (defined($mycgi->param("procedureid"))) ? $mycgi->param("procedureid") : "",
       trainingdate_month => (defined($mycgi->param("trainingdate_month"))) ? lpadzero($mycgi->param("trainingdate_month"),2) : "00",
       trainingdate_day => (defined($mycgi->param("trainingdate_day"))) ? lpadzero($mycgi->param("trainingdate_day"),2) : "00",
       trainingdate_year => (defined($mycgi->param("trainingdate_year"))) ? $mycgi->param("trainingdate_year") : "0000",
       sessionID => (defined($mycgi->param("sessionid"))) ? $mycgi->param("sessionid") : "0",
       document => (defined($mycgi->param("document"))) ? $mycgi->param("document") : "0",
    );
    $valueHash{title} = "Browse Training Records";
    $valueHash{trainingdate} = "$valueHash{trainingdate_month}/$valueHash{trainingdate_day}/$valueHash{trainingdate_year}";
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        schema => $ENV{SCHEMA},
        title => 'Training Management',
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
       function displayUserTraining(id) {
          $form.id.value = id;
          submitForm ('training', 'browseusertraining');
       }
       function displayTrainingCertificatePDF(userid,procedureVersion) {
          var myDate = new Date();
          var winName = myDate.getTime();
          $form.command.value = 'displaytrainingcertificate';
          $form.id.value = userid;
          $form.document.value = procedureVersion;
          $form.action = '$path$form.pl';
          $form.target = winName;
          var newwin = window.open('',winName);
          newwin.creator = self;
          $form.submit();
       }
       function displayVersions(documentID) {
           $form.command.value = 'browseversions';
           $form.document.value = documentID;
           $form.action = '$path' + 'documents.pl';
           $form.target = 'main';
           $form.submit();
       }
       function displayProcedureTraining(documentID) {
           $form.command.value = 'browseproceduretraining';
           $form.document.value = documentID;
           $form.action = '$path' + 'training.pl';
           $form.target = 'main';
           $form.submit();
       }
END_OF_BLOCK
    $output .= &doStandardHeader(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, useFileUpload => 'T',
              includeJSUtilities => 'F', includeJSWidgets => 'T');
    
    $output .= "<input type=hidden name=majorversion value=''>\n";
    $output .= "<input type=hidden name=minorversion value=''>\n";
    $output .= "<input type=hidden name=itemid value=''>\n";
    $output .= "<input type=hidden name=document value=''>\n";

    return($output);
}


###################################################################################################################################
sub doFooter {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    
    $output .= &doStandardFooter;
    
    return($output);
}


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub doBrowseUserTraining {  # routine to generate a table of a user's training history
###################################################################################################################################
    my %args = (
        userID => 0,
        @_,
    );
    my $output = "";
    my $numColumns = 4;
    my $id = $mycgi->param('id');
    my $name = getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $id);

    $output .= &startTable(columns => $numColumns, title => "Training Records for: " .
            "<a href=\"javascript:displayUser($id)\" title=\"Click here to browse information for $name\">$name</a> (xxx)", width => 750);
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= &startRow (bgColor => "#f0f0f0");
    $output .= &addCol (value => "Procedure", align => "center");
    $output .= &addCol (value => "Version", align => "center");
    $output .= &addCol (value => "Training Date", align => "center");
    $output .= &addCol (value => "Certificate", align => "center");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    my @items = &getUserTrainingHistory(dbh => $args{dbh}, schema => $args{schema}, userID => $id);
    
    my $count = 0;
    for (my $i=0; $i<$#items; $i++) {
        $count++;
        $output .= &startRow;
        my $url = "javascript:displayProcedureTraining($items[$i]{procedureid})";
        $output .= &addCol (value=>$items[$i]{description}, url => $url, align => "left", prompt => "Click here to display $items[$i]{description} training");
        $output .= &addCol (value=>"$items[$i]{major_version}.$items[$i]{minor_version}", align => "center");
        $output .= &addCol (value=>$items[$i]{datecompleted}, align => "center");
        $url = "javascript:displayTrainingCertificatePDF($id,$items[$i]{procedureversion})";
        $output .= &addCol (value=>"PDF", url=>$url, align => "center", prompt => "Click here to view training certificate");
        $output .= &endRow;
    }
    $output .= &endTable();
    
    $output =~ s/xxx/$count/;
    $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    
    
    return($output);
}


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
sub doAddTrainingRecordForm {  # routine to generate html for add training reocrd
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my @users = &getUserArray(dbh => $args{dbh}, schema => $args{schema}, where => "id >= 1000");
    my @configItems = &getConfigItemArray(dbh => $args{dbh}, schema => $args{schema});

    my $dateSelect = &build_date_selection("trainingdate", "$args{form}", "today");
    $output .= <<END_OF_BLOCK;
    <table border=0 width=750 align=center>
    <tr><td>Version</td><td>Major: <input type=text name=major size=2 maxlength=2 value=''> &nbsp; 
                            Minor: <input type=text name=minor size=3 maxlength=3 value=''></td></tr>
    <tr><td>Date</td><td>$dateSelect</td></tr>
    <tr><td>User</td><td><select name=traininguserid size=1><option value=0> -None Selected-</option>
END_OF_BLOCK
    for (my $i=0; $i < $#users; $i++) {
       my ($id, $fname, $lname) = ($users[$i]{id},$users[$i]{firstname},$users[$i]{lastname});
       $output .= "<option value=$id>$fname $lname</option>\n";
    }
    $output .= "</select></td></tr>\n";
    
    $output .= "<tr><td>Procedure</td><td><select name=procedureid size=1><option value=0> -None Selected-</option>\n";
    for (my $i=0; $i < $#configItems; $i++) {
       my ($id, $description) = ($configItems[$i]{id},$configItems[$i]{description});
       $output .= "<option value=$id>$description</option>\n";
    }
    $output .= "</select></td></tr>\n";
    
    $output .= <<END_OF_BLOCK;
    <tr><td>Certificate File:</td><td><input type=file name=documentfile size=50></td></tr>
    <tr><td colspan=2 align=center><input type=button name=submitadd value=Submit onClick="doVerifySubmit(document.$args{form});"></td></tr>
    <script language=javascript><!--
        function doVerifySubmit(f) {
            var msg = "";
            if (f.traininguserid.options[0].selected) {
                msg += "User must be selected.\\n";
            }
            if (f.procedureid.options[0].selected) {
                msg += "Procedure must be selected.\\n";
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
                //alert('Not Yet Implemented');
                submitFormCGIResults('$args{form}','addtrainingrecordprocess')
            }
        }
    //-->
    </script>
    </table>
    
END_OF_BLOCK
    
    return($output);
}


###################################################################################################################################
sub doBrowseSample {  # routine to generate a sample browse page
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    
    my $numColumns = 3;
    my $out = "";
    $out .= &startTable(columns => $numColumns, title => "By Development Staff Member (xxx)");
    $out .= &startRow (bgColor => "#f0f0f0");
    $out .= &addCol (value => "Staff Member", align => "center");
    $out .= &addCol (value => "Last Training Received", align => "center");
    $out .= &addCol (value => "Training Status", align => "center");
    $out .= &endRow();
    $out .= &addSpacerRow (columns => $numColumns);
    my $count = 0;
    my @users = &getUserArray(dbh => $args{dbh}, schema => $args{schema}, where => "id >= 1000 AND isactive = 'T'");
    for (my $i=0; $i < $#users; $i++) {
       my ($id, $fname, $lname) = ($users[$i]{id},$users[$i]{firstname},$users[$i]{lastname});
       $out .= &startRow();
       $out .= &addCol (value => "$fname $lname", url => "javascript:displayUserTraining('$id')", prompt => "Click here to browse complete training records for $fname $lname");
       my $lastTrainingDate = &getLastTrainingDate(dbh => $args{dbh}, schema => $args{schema}, ID => $id, type => 'user');
       $out .= &addCol (value => $lastTrainingDate, align => "center");
       my $value = "Current for all applicable training program elements";
       my ($missingCount, $missingTraining) = &getMissingProcedureTraining(dbh => $args{dbh}, schema => $args{schema}, userID => $id);
       if ($missingTraining gt "") {
           $value = "Training not current for the following procedure" . (($missingCount != 1) ? "s" : "") . ":<br>$missingTraining";
       }
       $out .= &addCol (value => $value, align => "center");
       $out .= &endRow();
       $count++;
    }
    $out .= &endTable();
    $out =~ s/xxx/$count/;
    if ($count) {
       $out .= "<br><br>";
    } else {
       $out = "";
    }
 
    my $dummy = "http://intradev.ymp.gov/";

    $numColumns = 3;
    $out .= &startTable(columns => $numColumns, title => "By Training Program Element (xxx)", width => 750);
    $out .= &startRow (bgColor => "#f0f0f0");
    $out .= &addCol (value => "Training Program Element", align => "center");
    $out .= &addCol (value => "Latest Training Completed", align => "center");
    $out .= &addCol (value => "Status", align => "center");
    $out .= &endRow();
    $out .= &addSpacerRow (columns => $numColumns);
    my @courses = ("Software Configuration Management Course", "Software Requirements Management Course", "Software Project Management Course");
    $count = 0;
    foreach my $element (@courses) {
       $count++;
       $out .= &startRow();
       $out .= &addCol (value => $element, url => $dummy, prompt => "Click here to browse complete training records for $element");
       $out .= &addCol (value => "00/00/00  00:00:00", align => "center");
       $out .= &addCol (value => "Training current for all staff members", align => "center");
       $out .= &endRow();
    }
    my @policies = ("RSIS SW Dev Policies");
    foreach my $element (@policies) {
       $count++;
       $out .= &startRow();
       $out .= &addCol (value => $element, url => $dummy, prompt => "Click here to browse complete training records for $element");
       $out .= &addCol (value => "00/00/00  00:00:00", align => "center");
       $out .= &addCol (value => "Training current for all staff members", align => "center");
       $out .= &endRow();
    }
    my @procedures = ("Procedure 1", "Procedure2");
    #my @configItems = &getConfigItemArray(dbh => $args{dbh}, schema => $args{schema}, where => "type_id = 10");
    my @configItems = &getConfigItemArray(dbh => $args{dbh}, schema => $args{schema});
    for (my $i=0; $i< $#configItems; $i++) {
       my ($id, $description) = ($configItems[$i]{id}, $configItems[$i]{description});
       $count++;
       $out .= &startRow();
       my $url = "javascript:displayProcedureTraining($configItems[$i]{id})";
       $out .= &addCol (value => $description, url => $url, prompt => "Click here to browse complete training records for $description");
       my $lastTrainingDate = &getLastTrainingDate(dbh => $args{dbh}, schema => $args{schema}, ID => $id, type => 'item');
       $out .= &addCol (value => $lastTrainingDate, align => "center");
       my $value = "Training current for all staff members";
       my ($missingCount, $missingTraining) = &getUsersWithoutTraining(dbh => $args{dbh}, schema => $args{schema}, procedure => $id);
       if ($missingTraining gt "") {
           $value = "Training not current for the following user" . (($missingCount != 1) ? "s" : "") . ":<br>$missingTraining";
       }
       $out .= &addCol (value => $value, align => "center");
       $out .= &endRow();
    }
    $out .= &endTable();
    $out =~ s/xxx/$count/;
    if ($count) {
       $out .= "<br><br>";
    } else {
       $out = "";
    }
    
    return($out);
}


###################################################################################################################################
sub doDisplayTrainingCertificate {  # routine to display a PDF of a document from the DB
###################################################################################################################################
    my %args = (
        userID => 0,
        itemID => 0,
        majorVersion => 0,
        minorVersion => 0,
        @_,
    );
    my $output = '';
    my %itemHash = &getTrainingItem(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          procedureVersion => $args{document});
#          itemID => $args{itemID}, majorVersion => $args{majorVersion}, minorVersion => $args{minorVersion});
    $output .= "Content-type: application/pdf\n\n";
    $output .= $itemHash{certificate};
    
    return($output);
}


###################################################################################################################################
sub doBrowseProcedureTraining {  # routine to display a table of procedure training history
###################################################################################################################################
    my %args = (
        document => 0,
        title => 'Training History',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = '';
    my $numColumns = 4;
    my @docList = &getDocumentList(dbh => $args{dbh}, schema => $args{schema}, document => $args{document}, settings => \%settings);
    my ($name, $documentDescription) = ($docList[0]{name},$docList[0]{description});
    $name =~ s/\..{0,3}$//;
    $output .= &startTable(columns => $numColumns, title => "$args{title}: $name (xxx)", width => 750);
    $output .= &startRow(bgColor => "#f0f0f0");
    $output .= &addCol (colspan => $numColumns, value => $documentDescription);
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    $output .= &startRow (bgColor => "#f0f0f0");
    $output .= &addCol (value => "User", align => "center");
    $output .= &addCol (value => "Version", align => "center");
    $output .= &addCol (value => "Training Date", align => "center");
    $output .= &addCol (value => "Certificate", align => "center");
    $output .= &endRow();
    $output .= &addSpacerRow (columns => $numColumns);
    
    my $count = 0;
    my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, ID => 10, settings => \%settings);
    my $hasMime = ((defined($mimeType)) ? "T" : "F");
    my @items = &getUserTrainingHistory(dbh => $args{dbh}, schema => $args{schema}, document => $args{document});
    
    for (my $i=0; $i<$#items; $i++) {
        my ($id,$date,$itemid,$major,$minor,$descr,$ver) = ($items[$i]{userid}, $items[$i]{datecompleted}, 
            $items[$i]{procedureid}, $items[$i]{major_version}, $items[$i]{minor_version}, $items[$i]{description}, $items[$i]{procedureversion});
        $count++;
        $output .= &startRow;
        my $url = "javascript:displayUser($items[$i]{userid})";
        my $fullName = getFullName(dbh => $args{dbh}, schema => $args{schema}, userID => $id);
        $output .= &addCol (value=> $fullName, url => $url, align => "left", prompt => "Click here to view information for $fullName");
        $output .= &addCol (value=>"$items[$i]{major_version}.$items[$i]{minor_version}", align => "center");
        $output .= &addCol (value=>$items[$i]{datecompleted}, align => "center");
        $url = "javascript:displayTrainingCertificatePDF($id,$items[$i]{procedureversion})";
        $output .= &addCol (value=>"PDF", url=>$url, align => "center", prompt => "Click here to view training certificate");
        $output .= &endRow;
    }
    $output .= &endTable();
    
    $output =~ s/xxx/$count/;
    $output =~ s/&quot;/'/g;  #should not need this, I am doing something wrong *****************************************************************
    
    return($output);
}


###################################################################################################################################
###################################################################################################################################


1; #return true
