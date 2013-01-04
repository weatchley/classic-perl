# UI Home functions
#
# $Source: /data/dev/rcs/prp/perl/RCS/UISource.pm,v $
# $Revision: 1.9 $
# $Date: 2005/10/06 16:30:25 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: UISource.pm,v $
# Revision 1.9  2005/10/06 16:30:25  naydenoa
# CREQ00065 - Update call to UI_Widgets.pm (source dropdown function) to
# make default dropdown for master matrix a blank entry.
#
# Revision 1.8  2005/09/28 23:34:26  naydenoa
# Phase 3 implementation
# Added utility to manage source document types
# Updated page titles
# Tweaks to document and matrix processing to accomodate multiple QA doc types
# Moved dropdown generation to UI_Widgets.pm
#
# Revision 1.7  2004/09/23 22:17:42  naydenoa
# CREQ00018 - add reference documents to dropdown for matrix creation
#
# Revision 1.6  2004/08/18 20:12:54  naydenoa
# CREQ00017 - updated screen titles
#
# Revision 1.5  2004/06/16 21:26:41  naydenoa
# Added QARD assignment capabilities - P1C2
#
# Revision 1.4  2004/05/26 17:56:21  naydenoa
# Updated source date field to comply with reopened CR00002
#
# Revision 1.3  2004/05/13 17:44:28  naydenoa
# Fulfillment of CR00002 - correct start year for document date dropdown
#
# Revision 1.2  2004/04/23 23:40:36  naydenoa
# Updated title bars to display different headings for entries and updates
#
# Revision 1.1  2004/04/22 20:43:02  naydenoa
# Initial revision
#
#

package UISource;

# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBUtilities qw(:Functions);
use UI_Widgets qw(:Functions);
use DBSource qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Text_Menus;
use Tie::IxHash;
use Tables;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getInitialValues       &doHeader              &doFooter
      &getTitle               &doMainMenu            &doSourceEntry
      &doSourceBrowse         &doSourceImage         &doUndeleteSelect
      &doMatrixEntry          &doMatrixUpdateSelect  &doAddSourceType
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader              &doFooter
      &getTitle               &doMainMenu            &doSourceEntry
      &doSourceBrowse         &doSourceImage         &doUndeleteSelect
      &doMatrixEntry          &doMatrixUpdateSelect  &doAddSourceType
    )]
);

my $mycgi = new CGI;


##############
sub getTitle {
##############
    my %args = (
        qardtypeid => 1,
        command => '',
        matrixid => 0,
        @_,
    );
    my $qardtype = "QARD";
    if ($args{qardtypeid} == 2) {
        $qardtype = "AQAP";
    }
    elsif ($args{qardtypeid} == 3) {
        $qardtype = "QAMP";
    }

    my $title = "Source";
    if ($args{command} eq "enter") {
        $title = "Create New $qardtype Source Document" if (!$args{isupdate});
        $title = "Update $qardtype Source Document" if ($args{isupdate});
    }  
    elsif ($args{command} eq "enter_matrix") {
        $title = $args{matrixid} ? "Update " : "Create New ";
        $title .= "$qardtype Compliance Matrix";
    }
    elsif ($args{command} eq "browse") {
        $title = "$qardtype Source Documents Table";
    }
    elsif ($args{command} eq "browse_detail") {
        $title = "Browse $qardtype Source Documents";
    }
    elsif ($args{command} eq "update_matrix_select") {
        $title = "Select $qardtype Compliance Matrix To Update";
    }
    elsif ($args{command} eq "update_select") {
        $title = "Select $qardtype Source Document To Update";
    }
    elsif ($args{command} eq "undelete") {
        $title = "Undelete Source Document";
    }
    elsif ($args{command} eq "undelete_matrix") {
        $title = "Undelete Compliance Matrix";
    }
    elsif ($args{command} eq "?") {
        $title = "Source";
    }
    return ($title);
}

######################
sub getInitialValues {  # routine to get initial CGI values and return in hash
######################
    my %args = (
        dbh => "",
        @_,
    );
    my %valueHash = (
       &getStandardValues, (
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "",
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
       aqapsid => (defined($mycgi->param("aqapsid"))) ? $mycgi->param("aqapsid") : 0,
       aqapsourceid => (defined($mycgi->param("aqapsourceid"))) ? $mycgi->param("aqapsourceid") : 0,
       sid => (defined($mycgi->param("sid"))) ? $mycgi->param("sid") : 0,
       sourceid => (defined($mycgi->param("sourceid"))) ? $mycgi->param("sourceid") : 0,
       sourcedesignation => (defined($mycgi->param("sourcedesignation"))) ? $mycgi->param("sourcedesignation") : "",
       sourcetitle => (defined($mycgi->param("sourcetitle"))) ? $mycgi->param("sourcetitle") : "",
       sourcetype => (defined($mycgi->param("sourcetype"))) ? $mycgi->param("sourcetype") : "",
       sourcetypeid => (defined($mycgi->param("sourcetypeid"))) ? $mycgi->param("sourcetypeid") : "",
       sourceurl => (defined($mycgi->param("sourceurl"))) ? $mycgi->param("sourceurl") : 0,
       docdate => (defined ($mycgi -> param ("docdate"))) ? $mycgi -> param ("docdate") : "",
       docdate_month => (defined ($mycgi -> param ("docdate_month"))) ? $mycgi -> param ("docdate_month") : "",
       docdate_day => (defined ($mycgi -> param ("docdate_day"))) ? $mycgi -> param ("docdate_day") : "",
       docdate_year => (defined ($mycgi -> param ("docdate_year"))) ? $mycgi -> param ("docdate_year") : "",
       sourcematrixstatusid => (defined ($mycgi -> param ("sourcematrixstatusid"))) ? $mycgi -> param ("sourcematrixstatusid") : "",
       documentfile => (defined ($mycgi -> param ("documentfile"))) ? $mycgi -> param ("documentfile") : "",
       isupdate => (defined($mycgi->param("isupdate"))) ? $mycgi->param("isupdate") : 0,
       mid => (defined ($mycgi -> param ("mid"))) ? $mycgi -> param ("mid") : 0,
       matrixid => (defined ($mycgi -> param ("matrixid"))) ? $mycgi -> param ("matrixid") : 0,
       aqapmatrixid => (defined ($mycgi -> param ("aqapmatrixid"))) ? $mycgi -> param ("aqapmatrixid") : 0,
       matrixtitle => (defined ($mycgi -> param ("matrixtitle"))) ? $mycgi -> param ("matrixtitle") : "",
    ));
#        => (defined ($mycgi -> param (""))) ? $mycgi -> param ("") : "",
    my $isupdate = ($valueHash{sourceid} || $valueHash{isupdate}) ? 1 : 0;
    my $matrixid = ($valueHash{matrixid} && $valueHash{qardtypeid} == 1) ? $valueHash{matrixid} : $valueHash{aqapmatrixid};
    $valueHash{title} = &getTitle(command => $valueHash{command}, isupdate => $isupdate, qardtypeid => $valueHash{qardtypeid}, matrixid => $matrixid);
    
    return (%valueHash);
}

##############
sub doHeader {  # routine to generate html page headers
##############
    my %args = (
        dbh => '',
        schema => $ENV{SCHEMA},
        title => "$SYSType User Functions",
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
    my $Server = $settings{server};
    
    my $extraJS = "";
    $extraJS .= <<END_OF_BLOCK;
    function doHome(script) {
      	$form.command.value = 'browse';
       	$form.action = '$path' + script + '.pl';
        $form.submit();
    }
    function submitForm3(script, command, type) {
        document.$form.command.value = command;
        document.$form.type.value = type;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function submitMatrix (script, command, matrixid) {
        document.$form.command.value = command;
        document.$form.matrixid.value = matrixid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function submitUndelete (script, command, what, id) {
        document.$form.command.value = command;
        if (what == "source") {
            document.$form.sid.value = id;
        }
        else {
            document.$form.matrixid.value = id;
        }
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function displaySourceImage (sourceid) {
        var myDate = new Date();
        var winName = myDate.getTime();
        document.$form.command.value = 'view_image';
        document.$form.sourceid.value = sourceid;
        document.$form.action = '$path$form.pl';
        document.$form.target = winName;
        var newwin = window.open('',winName);
        newwin.creator = self;
        document.$form.submit();
    }
END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'T', includeJSWidgets => 'T', useFileUpload => 'T');
    
    $output .= "<input type=hidden name=type value=0>\n";
    $output .= "<table border=0 width=750 align=center><tr><td>\n";

    return($output);
}

##############
sub doFooter {  # routine to generate html page footers
##############
    my %args = (
        @_,
    );
    my $output = "";
    $output .= &doStandardFooter();
    return($output);
}

################
sub doMainMenu {  # routine to generate main report menu
################
    my %args = (
        @_,
    );
    my $output = "";
    my $message = '';

    return($output);
}

###################
sub doSourceEntry {
###################
    my %args = (
        @_,
    );
    my $output = "";
    my $message = '';
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;

    my $isupdate = ($settings{isupdate}) ? 1 : 0;
    my $qardtypeid = $settings{qardtypeid} ? $settings{qardtypeid} : 1;
    my $sourceid = ($settings{qardtypeid} == 1) ? $settings{sourceid} : $settings{aqapsourceid};

    $output .= "<input type=hidden name=isupdate value=$isupdate>\n";
    $output .= "<input type=hidden name=qardtypeid value=$qardtypeid>\n";
    $output .= "<input type=hidden name=sourceid value=$sourceid>\n";
    my $designation = "";
    my $typeid = 0;
    my $title = "";
    my $docdate = "";
    my $matrixstatusid = 0;
    my $imageextension = "";
    my $url = "";
    my $isdeleted = "";
    ($designation, $title, $typeid, $docdate, $matrixstatusid, $imageextension, $url, $isdeleted) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "source", what => "designation, title, typeid, to_char(docdate,'MM/DD/YYYY'), matrixstatusid, imageextension, url, isdeleted", where => "id = $sourceid") if $sourceid;
    $output .= "<table width=650 align=center cellspacing=10>\n";
    $output .= "<tr><td><li><b>Source Document Type:&nbsp;&nbsp;</b><select name=sourcetypeid><option value=\"\">Select Source Document Type\n";

    my $selected = "";
    my @sourcetypes = &getSourceType (dbh => $args{dbh}, schema => $args{schema}, orderby => "description");
    for (my $i = 1; $i <= $#sourcetypes; $i++) {        
        $selected = ($sourcetypes[$i]{id} == $typeid) ? " selected" : "";
        $output .= "<option value=$sourcetypes[$i]{id}$selected>$sourcetypes[$i]{description}\n"; 
    }    

    $output .= "</select></td></tr>\n";
    $output .= "<tr><td><li><b>Document Number:&nbsp;&nbsp;\n";
    $output .= "<input name=sourcedesignation size=40 maxlength=100 value=\"$designation\"></td></tr>\n";
    $output .= "<tr><td><li><b>Document Title:<br>\n";
    $output .= "<textarea name=sourcetitle rows=3 cols=75>$title</textarea></td></tr>\n";
    $docdate = ($docdate) ? $docdate : "today";
    $output .= "<tr><td><li><b>Publication Date:&nbsp;&nbsp;\n" . &buildDateSelection (element => "docdate", form => $args{form}, initdate => $docdate, startyear => "1950") . "";
    $output .= "</td></tr>\n";
    $output .= "<tr><td><li><b>Compliance Matrix Status:&nbsp;&nbsp;\n";
    $output .= "<select name=sourcematrixstatusid><option value=\"\">Select Compliance Matrix Status\n";
    my %matrixstatus = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => "sourcematrixstatus", idColumn => "id", nameColumn => "description")};
    foreach $key (sort keys %matrixstatus) {
        $selected = ($key == $matrixstatusid) ? " selected" : "";
        $output .= "<option value=$key$selected>$matrixstatus{$key}\n";
    }
    $output .= "</td></tr>\n";
    $output .= "<tr><td><li><b>Enter Web Address:&nbsp;&nbsp;</b>\n";
    $output .= "<input type=text name=sourceurl size=50 maxlength=300 value=$url>&nbsp;&nbsp;(if available)\n";
    $output .= "</td></tr>\n";
    $output .= "<tr><td><li><b>Attach Document:&nbsp;&nbsp;</b>(if available)\n";
    if ($imageextension ne "") {
        $output .= "&nbsp;&nbsp;<a href=javascript:displaySourceImage($settings{sourceid}) title=\"Click to display the current document image\">Current source document image</a>\n";
    }
    $output .= "<br><input type=file name=documentfile size=50 maxlength=256></b></td></tr>\n";
    my $checked = ($isdeleted eq "T") ? " checked" : "";
    $output .= "<tr><td><li><b>Mark as deleted:</b>&nbsp;&nbsp;<input type=checkbox name=isdeleted value='T' $checked></td></tr>\n" if $isupdate;
    $output .= "<tr><td colspan=2><center><br><input type=button name=checkbutton value=\"Check Work\" title=\"Click to check work\" onClick=checkWork()>&nbsp;&nbsp;\n";
    $output .= "<input type=button name=submitbutton value=\"Submit\" title=\"Click to submit source document\" onClick=\"verifySubmit(document.$args{form},'enter_process')\"></center><br></td></tr>\n";
    $output .= "</table>\n";
    $output .= "\n";

    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifySubmit (f,command){ //  javascript form verification routine
    var msg = "";
    var validateform = f;
    msg += (validateform.sourcetypeid.value == "") ? "You must enter the type of the source document.\\n" : "";
    msg += (validateform.sourcedesignation.value == "") ? "You must enter the number/designation of the source document.\\n" : "";
    msg += (validateform.sourcetitle.value == "") ? "You must enter the title of the source document.\\n" : "";
    msg += (validate_date(validateform.docdate_year.value,validateform.docdate_month.value,validateform.docdate_day.value,0,0,0,0,1,0,0))
    msg += (validateform.sourcematrixstatusid.value == "") ? "You must enter the source document matrix status.\\n" : "";
    if (msg != "") {
        alert (msg);
    }
    else {
        submitFormCGIResults('$args{form}',command);
    }
}
function checkWork () {
    var msg = "Source Type ID: " + document.$args{form}.sourcetypeid.value + "\\n";
    msg += "Source Number: " + document.$args{form}.sourcedesignation.value + "\\n";
    msg += "Source Title: " + document.$args{form}.sourcetitle.value + "\\n";
    msg += "Document Date: " + document.$args{form}.docdate_month.value + "/" + document.$args{form}.docdate_day.value + "/" + document.$args{form}.docdate_year.value + "\\n";
    msg += "Source Matrix Status: " + document.$args{form}.sourcematrixstatusid.value + "\\n";
    msg += "URL: " + document.$args{form}.sourceurl.value + "\\n";
    alert (msg);
}
//--></script>
END_OF_BLOCK

    $output .= "\n";
    return ($output);
}

####################
sub doSourceBrowse {
####################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    $output .= "<input type=hidden name=sourceid value=>\n";
    $output .= "<input type=hidden name=qardtypeid value=$settings{qardtypeid}>\n";
    my $message = '';
    my $key = "";

    my ($id, $designation, $title, $docdate, $revision, $typeid, $type, $matrixstatusid, $matrixstatus, $url);

    tie my %types, "Tie::IxHash";
    %types = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "id", nameColumn => "description", table => "sourcetype", orderBy => "weight desc, id")};
    foreach $key (keys %types) {
        $typeid = $key;
        $type = $types{$key};
        my $textcolor = "#000000";
        my $headercolor = "#ffff66";
        $textcolor = $Regulatory if $type eq "Regulatory";
        $headercolor = $RegulatoryHeader if $type eq "Regulatory";
        $textcolor = $Guidance if $type eq "Guidance";
        $headercolor = $GuidanceHeader if $type eq "Guidance";
        $textcolor = $Commitment if $type eq "Commitment";
        $headercolor = $CommitmentHeader if $type eq "Commitment";
        $textcolor = $Reference if $type eq "Reference";
        $headercolor = $ReferenceHeader if $type eq "Reference";
        
        $output .= "<table width=750 align=center cellspacing=0 cellpadding=3 border=1 bgcolor=#ffffff>\n";
        $output .= "<tr bgcolor=$headercolor><td colspan=6 align=center><font size=+2>$type Documents</font></td></tr>\n";
        $output .= "<tr bgcolor=#eeeeee><td><font size=-1><b>Designation</td><td><font size=-1><b>Title</td><td><font size=-1><b>Document Date</td><td><font size=-1><b>Matrix Status</td><td><font size=-1><b>Display</td><td><font size=-1><b>Links</b></td></tr>\n";#Type</td></tr>\n";
        $output .= "<tr><td colspan=6></td></tr>\n";


        my (@sourcedocs) = &getSourceDocs (dbh => $args{dbh}, schema => $args{schema}, orderby => "typeid, designation", where => "typeid = $typeid and qardtypeid = $settings{qardtypeid}");
        my $arethereany = 0;
        for (my $i = 1; $i <= $#sourcedocs; $i++) {
            my $count = 0;
            $id = $sourcedocs[$i]{id};
            $designation = $sourcedocs[$i]{designation};
            $title = ($sourcedocs[$i]{title}) ? $sourcedocs[$i]{title} : "&nbsp;";
#            $typeid = $sourcedocs[$i]{typeid};
            $docdate = ($sourcedocs[$i]{docdate}) ? $sourcedocs[$i]{docdate} : "&nbsp;";
            $revision = ($sourcedocs[$i]{revision}) ? $sourcedocs[$i]{revision} : "&nbsp;";
            $matrixstatusid = ($sourcedocs[$i]{matrixstatusid}) ? $sourcedocs[$i]{matrixstatusid} : 0; 
            $matrixstatus = "&nbsp;";
            $matrixstatus = "Integral" if ($matrixstatusid == 1);
            $matrixstatus = "One-liner" if ($matrixstatusid == 2);
            my $image = ($sourcedocs[$i]{imageextension} && $sourcedocs[$i]{imagecontenttype}) ? "<a href=javascript:displaySourceImage($id) title=\"Click to display source document image\">Image</a>&nbsp;&nbsp;" : "";
            $url = ($sourcedocs[$i]{url}) ? "<a href=$sourcedocs[$i]{url} target=new>URL</a>" : "&nbsp;";
            $output .= "<tr valign=top><td width=150><font size=-1 color=$textcolor face=$SYSFontFace>$designation</font></td>\n";
            $output .= "<td><font size=-1 color=$textcolor face=$SYSFontFace>$title</td>\n";
            $output .= "<td width=105><font size=-1 color=$textcolor face=$SYSFontFace>$docdate</td>\n";
            $output .= "<td width=95><font size=-1 face=$SYSFontFace color=$textcolor>$matrixstatus</td>\n";
            $output .= "<td><font size=-1 face=$SYSFontFace color=$textcolor><a href=javascript:submitSource('requirement','browse_detail',$id); title=\"Click to display source document text\">Text</a>&nbsp;&nbsp;<a href=javascript:submitSource('requirement','browse',$id) title=\"Click to display source document text (requirements) in a table\">Table</a>\n";
            $output .= "<td><font size=-1 face=$SYSFontFace color=$textcolor>$image$url</td></tr>\n";
            $arethereany++;
        }
        $output .= "<tr><td colspan=6 align=center><font face=helvetica size=2>None</td></tr>" if !$arethereany;
        $output .= "</table><br><br>\n";
    }
    return ($output);
}

###################
sub doSourceImage {
###################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $outstr = "Hello! :P";
    my ($mimetype, $image) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "source", what => "imagecontenttype, document", where => "id = $settings{sourceid}");
    $outstr = "Content-type: $mimetype\n\n";
    $outstr .= $image;
    return ($outstr);
}

###################
sub doMatrixEntry {
###################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";
    my $selected = "";

    my $isupdate = $settings{isupdate} ? 1 : 0;
    my $qardtypeid = $settings{qardtypeid};
    my $mid = 0;
    if ($settings{matrixid} && $qardtypeid == 1) {
        $mid = $settings{matrixid};
    }
    elsif ($settings{aqapmatrixid} && $qardtypeid == 2) {
        $mid = $settings{aqapmatrixid};
    }

    my ($qardtype) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "description", table => "qardtype", where => "id = $qardtypeid");

#    my ($qardid, $sourceid, $title) = ($mid) ? &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "qardid, sourceid, title", table => "matrix", where => "id = $mid) : (0, 0, "");

    $outstr .= "<input type=hidden name=isupdate value=$isupdate>\n";
    $outstr .= "<input type=hidden name=matrixid value=$mid>\n";
    $outstr .= "<input type=hidden name=qardtypeid value=$qardtypeid>\n";

    my $qardid = $settings{rid};
    $qardid = $settings{aqaprid} if (($qardtypeid == 2) && $settings{aqapid});
    $qardid = $qardid ? $qardid : 0;
    my $sourceid = ($settings{sid}) ? $settings{sid} : 0;
    my $title = $settings{matrixtitle} ? $settings{matrixtitle} : "";
    my $isdeleted = $settings{isdeleted};
    ($qardid, $sourceid, $title, $isdeleted) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "qardid, sourceid, title, isdeleted", table => "matrix", where => "id = $mid") if ($isupdate || $mid);
    $outstr .= "<table width=700 align=center>\n";
    if ($qardtypeid == 1) {
        $outstr .= "<tr><td><li><b>Source Document:</b>&nbsp;&nbsp;\n";
        $outstr .= &makeSourceDropdown (dbh => $args{dbh}, schema => $args{schema}, where => "isdeleted = 'F' and qardtypeid = 1", orderby => "designation", qardtype => "", sid => $sourceid, tablerow => 0, title => 1);
        $outstr .= "</td></tr>\n";
    }
    $outstr .= "<tr><td><li><b>$qardtype Revision:</b>&nbsp;&nbsp;\n";
    my ($tmpoutstr) = &makeQARDDropdown (dbh => $args{dbh}, schema => $args{schema}, where => "qardtypeid = $qardtypeid and isdeleted = 'F' and iscurrent = 'L'", orderby => "iscurrent desc, revid desc", qardtypeid => $qardtypeid, rid => $qardid, tablerow => 0);
    $outstr .= $tmpoutstr;
    $outstr .= "</td></tr>\n";
    $outstr .= "<tr><td><li><b>Matrix Title:</b>&nbsp;&nbsp;<input type=text name=matrixtitle value=\"$title\" size=70 maxlength=500></td></tr>\n";
    my $checked = ($isdeleted eq "T") ? " checked" : "";
    $outstr .= "<tr><td><li><b>Mark as deleted:</b>&nbsp;&nbsp;<input type=checkbox name=isdeleted value='T' $checked></td></tr>\n" if $isupdate;
    $outstr .= "<tr><td><center><br><input type=button name=checkbutton value=\"Check Work\" title=\"Click to check work\" onClick=checkWork()>&nbsp;&nbsp;<input type=button name=submitbutton value=\"Submit\" title=\"Click to submit QARD Compliance Matrix\" onClick=validateStuff('enter_matrix_process')></center><br></td></tr>\n";
    $outstr .= "</table>\n";
    $outstr .= <<END_OF_BLOCK;

    <script language=javascript><!--
    function validateStuff(command) {
        var msg = "";
        msg += ($qardtypeid == 1 && document.$args{form}.sourceid.value == "") ? "You must select a source document.\\n" : "";
        msg += (document.$args{form}.rid.value == "") ? "You must select a $qardtype revision.\\n" : "";
        msg += (isblank(document.$args{form}.matrixtitle.value)) ? "You must enter the title of the QARD Compliance Matrix.\\n" : "";
        if (msg != "") {
            alert (msg);
        }
        else {
            submitFormCGIResults('$args{form}', command);
        }
    }
    function checkWork () {
        var msg = "Source ID: " + document.$args{form}.sid.value + "\\n";
        msg += "QARD Revision ID: " + document.$args{form}.rid.value + "\\n";
        msg += "Matrix Title: " + document.$args{form}.matrixtitle.value + "\\n";
        alert (msg);
    }
    //--></script>
END_OF_BLOCK

    return ($outstr);
}

##########################
sub doMatrixUpdateSelect {
##########################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";

    $outstr .= "<input type=hidden name=matrixid value=$settings{matrixid}>\n";
    $outstr .= "<input type=hidden name=isupdate value=1>\n";
    $outstr .= "<table width=750 border=1 cellspacing=0 cellpadding=3 align=center bgcolor=#ffffff>\n";
    $outstr .= "<tr bgcolor=#a0e0c0><td><b>Source Document</b></td><td><b>QARD Revision</b></td><td><b>Matrix Title</b></td><tr>\n";

    my $stuff = "select s.designation, q.revid, m.title, m.id from $args{schema}.source s, $args{schema}.qard q, $args{schema}.matrix m where m.qardid = q.id and m.sourceid = s.id and m.isdeleted = 'F' order by m.title";
    my $csr = $args{dbh} -> prepare ($stuff);
    $csr -> execute;
    while (my ($designation, $revid, $title, $mid) = $csr -> fetchrow_array) {
        $outstr .= "<tr><td><font size=2 face=$SYSFontFace>$designation</td><td><font size=2 face=$SYSFontFace>$revid</td><td><font size=2 face=$SYSFontFace><a href=javascript:submitMatrix('source','enter_matrix',$mid)>$title</a></td></tr>\n";
    }
    $csr -> finish;
    $outstr .= "</table>\n";

    return ($outstr);
}

######################
sub doUndeleteSelect {
######################
    my %args = (
        what => "source",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";

    $outstr .= "<input type=hidden name=matrixid value=$settings{matrixid}>\n";
    $outstr .= "<input type=hidden name=sid value=$settings{sid}>\n";
    $outstr .= "<input type=hidden name=what value=$args{what}>\n";
    $outstr .= "<table width=750 border=1 cellspacing=0 cellpadding=3 align=center bgcolor=#ffffff>\n";
    $outstr .= "<tr bgcolor=#a0e0c0><td><b>Undelete</b></td><td><b>$args{what}</b></td><tr>\n";

    my $stuff;
    $stuff = "select title, id from $args{schema}.matrix where isdeleted = 'T' order by title" if ($args{what} eq "matrix");
    $stuff = "select designation || ': ' || title, id from $args{schema}.source where isdeleted = 'T'" if ($args{what} eq "source");
    my $csr = $args{dbh} -> prepare ($stuff);
    $csr -> execute;
    while (my ($title, $id) = $csr -> fetchrow_array) {
        $outstr .= "<tr><td><font size=2 face=$SYSFontFace><a href=javascript:submitUndelete('source','undelete_process','$args{what}',$id)>Undelete</a></td><td><font size=2 face=$SYSFontFace>$title</td></tr>\n";
    }
    $csr -> finish;
    $outstr .= "</table>\n";

    return ($outstr);
}

#####################
sub doAddSourceType {
#####################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";

    $outstr .= "<table width=350 align=center border=0 cellpadding=3 cellspacing=0>\n";
    $outstr .= "<input type=hidden name=sourcetypeid value=$settings{sourcetypeid}>\n" if $settings{sourcetypeid};
    $outstr .= "<tr><td><b><li>New Source Type:</b>&nbsp;&nbsp;<input type=text name=sourcetype value=''></td></tr>\n";
#    $outstr .= "<tr><td><b><li>Related QA Document:</b>&nbsp;&nbsp;<select name=qardtypeid>\n";
=pod
    my %qtype = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "id", nameColumn => "description", table => "qardtype", orderby => "id")};
    foreach $key (sort keys %qtype) {
        $outstr .= "<option value=$key>$qtype{$key}\n";
    }
    $outstr .= "</select></td></tr>\n";
=cut
    $outstr .= "<tr><td align=center><input type=submit value=Submit onClick=javascript:submitFormCGIResults('source','add_type_process')></td></tr>\n";
    $outstr .= "<tr><td><hr width=200></td></tr>\n";
    $outstr .= "<tr align=center><td><b>Current Source Document Types:</b><br><select size=10>\n";
    my @stypes = &getSourceType (dbh => $args{dbh}, schema => $args{schema}, orderby => "description");
    for (my $i = 1; $i <= $#stypes; $i++) {
        $outstr .= "<option value=$stypes[$i]{id}>$stypes[$i]{description}\n";
    }
    $outstr .= "</select></td></tr>\n";
    $outstr .= "</table>\n";

    return ($outstr);
}

###############
1; #return true








