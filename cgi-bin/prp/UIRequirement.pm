# UI Requirement functions
#
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/prp/perl/RCS/UIRequirement.pm,v $
# $Revision: 1.24 $
# $Date: 2008/02/19 23:37:12 $
# $Author: higashis $
# $Locker: higashis $
#
# $Log: UIRequirement.pm,v $
# Revision 1.24  2008/02/19 23:37:12  higashis
# made changes for CREQ00086 - sh.
#
# Revision 1.23  2006/06/14 00:04:29  naydenoa
# Tweaked sort on QARD sections retrieval for CM assignment.
#
# Revision 1.22  2006/01/06 17:45:39  naydenoa
# Added new function for matrix browse access.
#
# Revision 1.21  2005/10/06 16:27:30  naydenoa
# CREQ00065 - display 0th criterion; update headers to sect id - sub id
#
# Revision 1.20  2005/09/28 23:20:59  naydenoa
# Phase 3 implementation
# Separated source criteria entry from matrix updates
# Tweaked code to accommodate AQAP matrices
#
# Revision 1.19  2005/04/28 17:41:38  naydenoa
# Made the pop-up window the focus window when envoked at reqs browse
# CREQ00054
#
# Revision 1.18  2005/03/22 19:01:24  naydenoa
# Replaced all occurrences of YMP with ORD - CREQ00043
#
# Revision 1.17  2005/03/15 21:39:28  naydenoa
# Replaced table 1a assignment with multiple dual select - CREQ00042
#
# Revision 1.16  2005/02/17 16:42:23  naydenoa
# CREQ00039 - accommodate table 1a linking from entry/update screen
#
# Revision 1.15  2004/10/04 21:50:57  naydenoa
# Bug fix in JavaScript validation of entry data - type changes - CREQ00018
#
# Revision 1.14  2004/09/30 16:59:41  naydenoa
# CREQ00018 - enable matrix assignments for reference documents
#
# Revision 1.13  2004/09/16 17:07:25  naydenoa
# Updated QARD sort - CREQ00005
#
# Revision 1.12  2004/09/15 15:16:09  naydenoa
# Added matrix id/qard id to selections - CREQ00022
#
# Revision 1.11  2004/09/13 21:07:16  naydenoa
# Changed OCRM position to YMP position - CREQ00020
#
# Revision 1.10  2004/08/20 22:14:05  naydenoa
# Updated doc select
#
# Revision 1.9  2004/08/11 15:03:15  naydenoa
# Updated requirements filtering for browse and update options - CREQ00015
#
# Revision 1.8  2004/07/23 19:44:23  naydenoa
# Added sorter to entry form, updated sorts for browse - CREQ00007
#
# Revision 1.7  2004/06/18 21:31:59  naydenoa
# Minor formatting changes, updated matrix ID retrieval - CR00006
#
# Revision 1.6  2004/06/18 18:05:16  naydenoa
# Added OCRWM position and justification to assignment section - CR00004
#
# Revision 1.5  2004/06/16 21:51:54  naydenoa
# Update default value for QARD rev ID in values hash
#
# Revision 1.4  2004/06/16 21:48:11  naydenoa
# Minor tweak to QARD revision selection
#
# Revision 1.3  2004/06/16 21:21:21  naydenoa
# Updated with QARD section assignments for Phase 1, Cycle 2
# Added undelete utilities, update select
#
# Revision 1.2  2004/04/23 23:38:37  naydenoa
# Updated title bars to display different headings for entries and updates
#
# Revision 1.1  2004/04/22 20:40:35  naydenoa
# Initial revision
#
#

package UIRequirement;

# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBUtilities qw(:Functions);
use UI_Widgets qw(:Functions);
use DBRequirement qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UIReports qw(doDisplayHTMLReport doDisplayHTMLAQAP doMainAQAPReport);
#use DBSource qw(:Functions);
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
      &getInitialValues           &doHeader    &doFooter
      &getTitle                   &doMainMenu  &doSourceRequirementEntry
      &doSourceRequirementBrowse  &doPopQARD   &doSourceBrowseDetail
      &doUndeleteSelect           &doSourceRequirementEntryMatrix
      &doApproveMatrix
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues           &doHeader    &doFooter
      &getTitle                   &doMainMenu  &doSourceRequirementEntry
      &doSourceRequirementBrowse  &doPopQARD   &doSourceBrowseDetail
      &doUndeleteSelect           &doSourceRequirementEntryMatrix
      &doApproveMatrix
    )]
);

my $mycgi = new CGI;


##############
sub getTitle {
##############
    my %args = (
        qardtypeid => 1,
        @_,
    );

    $args{qardtypeid} = $args{qardtypeid} ? $args{qardtypeid} : 1;
    my $qardtype = "QARD";
    if ($args{qardtypeid} == 2) {
        $qardtype = "AQAP";
    }

    my $title = "Criterion from Source Document";
    if ($args{command} eq "enter") {
        $title = "Enter $qardtype Source Criterion" if (!$args{isupdate});
        $title = "Update $qardtype Source Criterion" if $args{isupdate};
        $title = "Update $qardtype CM Assignment" if ($args{matrixid});
    }  
    elsif ($args{command} eq "enter_matrix") {
        $title = "Populate $qardtype Compliance Matrix";
    }
    elsif ($args{command} eq "browse_matrix") {
        $title = "$qardtype Criteria for CM Assignment";
    }
    elsif ($args{command} eq "browse") {
        $title = ($args{isupdate}) ? "Select $qardtype Criterion for Update" : "Browse $qardtype Source Criteria";
    }
    elsif ($args{command} eq "approve_matrix") {
        $title = "Review and Approve CM Changes";
    }
    elsif ($args{command} eq "?") {
        $title = "Criterion from Source Document";
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
       aqaprid => (defined ($mycgi -> param ("aqaprid"))) ? $mycgi -> param ("aqaprid") : 0,
       aqapsid => (defined ($mycgi -> param ("aqapsid"))) ? $mycgi -> param ("aqapsid") : 0,
       aqapsourceid => (defined($mycgi->param("aqapsourceid"))) ? $mycgi->param("aqapsourceid") : 0,
       id => (defined ($mycgi -> param ("id"))) ? $mycgi -> param ("id") : "",
       isupdate => (defined($mycgi->param("isupdate"))) ? $mycgi->param("isupdate") : 0,
       mid => (defined($mycgi->param("mid"))) ? $mycgi->param("mid") : 0,
       matrixid => (defined($mycgi->param("matrixid"))) ? $mycgi->param("matrixid") : 0,
       aqapmatrixid => (defined($mycgi->param("aqapmatrixid"))) ? $mycgi->param("aqapmatrixid") : 0,
       sid => (defined ($mycgi -> param ("sid"))) ? $mycgi -> param ("sid") : 0,
       sourceid => (defined($mycgi->param("sourceid"))) ? $mycgi->param("sourceid") : 0,
       qrid => (defined($mycgi->param("qrid"))) ? $mycgi->param("qrid") : 0,
       qrsectionid => (defined($mycgi->param("qrsectionid"))) ? $mycgi->param("qrsectionid") : "",
       qracceptancecriterion => (defined($mycgi->param("qracceptancecriterion"))) ? $mycgi->param("qracceptancecriterion") : "",
       qractext => (defined ($mycgi -> param ("qractext"))) ? $mycgi -> param ("qractext") : "",
       qrsubsection => (defined ($mycgi -> param ("qrsubsection"))) ? $mycgi -> param ("qrsubsection") : "",
       qrtext => (defined ($mycgi -> param ("qrtext"))) ? $mycgi -> param ("qrtext") : "",
       rid => (defined ($mycgi -> param ("rid"))) ? $mycgi -> param ("rid") : 0,
       requirementid => (defined($mycgi->param("requirementid"))) ? $mycgi->param("requirementid") : 0,
       ocrwmposition => (defined ($mycgi -> param ("ocrwmposition"))) ? $mycgi -> param ("ocrwmposition") : "",
       ocrwmjustification => (defined ($mycgi -> param ("ocrwmjustification"))) ? $mycgi -> param ("ocrwmjustification") : "",
       sorter => (defined ($mycgi -> param ("sorter"))) ? $mycgi -> param ("sorter") : "main",
       table1aid => (defined ($mycgi -> param ("table1aid"))) ? $mycgi -> param ("table1aid") : 0,
       qardtypeid => (defined ($mycgi -> param ("qardtypeid"))) ? $mycgi -> param ("qardtypeid") : 0,
       matrix => (defined ($mycgi -> param ("matrix"))) ? $mycgi -> param ("matrix") : 0,
       approvalmatrixid => (defined ($mycgi -> param ("approvalmatrixid"))) ? $mycgi -> param ("approvalmatrixid") : 0,
       rationale => (defined ($mycgi -> param ("rationale"))) ? $mycgi -> param ("rationale") : "",
    ));
#        => (defined ($mycgi -> param (""))) ? $mycgi -> param ("") : "",
    my @sectionsList = $mycgi -> param ("subsections");
    my @t1aList = $mycgi -> param ("table1a");

    $valueHash{subsections} = \@sectionsList;
    $valueHash{table1a} = \@t1aList;

    my $isupdate = ($valueHash{qrid} || $valueHash{isupdate}) ? 1 : 0;
    my $matrixid = $valueHash{matrixid} ? $valueHash{matrixid} : $valueHash{aqapmatrixid};
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
        width => 750,
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
    my $isupdate = ($settings{qrid}) ? 1 : 0;
    
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
    function submitFormSource(script, command, sourceid) {
        document.$form.command.value = command;
        document.$form.sourceid.value = sourceid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function submitForm4(script, command, requirementid) {
        document.$form.command.value = command;
//        document.$form.isupdate.value = 1;
        document.$form.qrid.value = requirementid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function submitFormMatrix(script, command, matrixid) {
        document.$form.command.value = command;
//        document.$form.isupdate.value = 1;
        document.$form.matrixid.value = matrixid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function submitFormUpdate(script, command, isupdate, sourceid) {
        document.$form.command.value = command;
        document.$form.isupdate.value = isupdate;
        document.$form.sourceid.value = sourceid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function popQARD (script,reqid) {
        var winName = "qardwin";
        document.$form.command.value = 'pop_qard';
        document.$form.qrid.value = reqid;
        document.$form.action = '$path$form.pl';
        document.$form.target = winName;
        var newwin = window.open('',winName,"height=450,width=650,scrollbars=yes");
        newwin.creator = self;
        newwin.focus();
        document.$form.submit();
    }
    function submitUndelete (script, command, what, id) {
        document.$form.command.value = command;
        document.$form.qrid.value = id;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
END_OF_BLOCK

    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'T', includeJSWidgets => 'T');
    
    $output .= "<input type=hidden name=type value=0>\n";
    $output .= "<table border=0 width=$args{width} align=center><tr><td>\n";

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

##############################
sub doSourceRequirementEntry {
##############################
    my %args = (
        @_,
    );
    my $output = "";
    my $message = '';
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;

    $output .= "<input type=hidden name=qrid value=$settings{qrid}>\n";
    my $isupdate = ($settings{qrid} || $settings{isupdate}) ? "1" : "0";
    $output .= "<input type=hidden name=isupdate value=$isupdate>\n";
    $output .= "<input type=hidden name=rid value=$settings{rid}>\n";
    my $sourceid = ($settings{qardtypeid} == 1) ? $settings{sourceid} : $settings{aqapsourceid};
    my $sectionid = "";
    my $requirementid = "";
    my $text = "";
    my $mid = 0;
    my $isdeleted = "";
    my $ocrwmposition = "";
    my $ocrwmjustification = ""; 
    my $sorter = "main";
    my $sourcetypeid = 0;
    my $designation = "";
    my $title = "";
    my $table1aid = 0;

    ($sourceid, $sectionid, $text, $requirementid, $isdeleted, $ocrwmposition, $ocrwmjustification, $sorter, $table1aid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "sourceid, sectionid, text, requirementid, isdeleted, ocrwmposition, ocrwmjustification, sorter, table1aid", table => "sourcerequirement", where => "id = $settings{qrid}") if $settings{qrid};
    ($mid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "id", table => "matrix", where => "sourceid = $sourceid and qardid = $settings{rid}") if $settings{qrid};
     $mid = ($mid) ? $mid : 0;
     $table1aid = ($table1aid) ? $table1aid : 0;
    ($sourcetypeid, $designation, $title) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "typeid, designation, title", table => "source", where => "id = $sourceid");
    $requirementid = ($requirementid) ? $requirementid : ""; 
    $sourcetypeid = ($sourcetypeid) ? $sourcetypeid : ""; 
    $output .= "<table width=650 align=center cellspacing=10>\n";
    $output .= "<input type=hidden name=typeid value=$sourcetypeid>\n";
    if ($isupdate == 1) {
        $output .= "<input type=hidden name=sourceid value=$sourceid>\n";
        $output .= "<tr><td colspan=2><li><b>Source Document:&nbsp;&nbsp;&nbsp;&nbsp;$designation - $title</b>\n"; 
    }
    if ($isupdate == 0) {
        $output .= "<tr><td colspan=2><li><b>Source Document:&nbsp;&nbsp;&nbsp;&nbsp;<select name=sourceid><option value=0>Select Source Document\n" if !$isupdate;
        tie my %sources, "Tie::IxHash"; 
        %sources = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "id", nameColumn => "designation || ' ' || title", table => "source", orderBy => "designation", where => "isdeleted = 'F'")}; # and typeid in (1, 2, 3)")};
        foreach $key (keys %sources) {
            my $selected = ($key == $sourceid) ? " selected" : "";
            $output .= "<option value=$key$selected>" . &getDisplayString ($sources{$key}, 65) . "\n";
        }
        $output .= "</select>\n";
    }
    $output .= "</td></tr>\n";
    $output .= "<tr><td valign=top><li><b>Section ID:</b>&nbsp;&nbsp;<br>\n";
    $output .= "<input name=qrsectionid size=30 maxlength=100 value=\"$sectionid\">\n";
    $output .= "<li><b>Sub ID:</b>&nbsp;&nbsp;<br>\n";
    $output .= "<input name=requirementid size=10 maxlength=3 value=\"$requirementid\">\n";
    $output .= "<li><b>Sorter:</b>&nbsp;&nbsp;<font size=-1>(top, main, or bottom)</font><br>\n";
    $output .= "<input name=sorter size=10 maxlength=20 value=\"$sorter\">\n";
    $output .= "</td><td valign=top><li><b>Text:<br>\n";
    $output .= "<textarea name=qrtext rows=6 cols=50>$text</textarea></td></tr>\n";
    my $checked = ($isdeleted eq "T") ? " checked" : "";
    $output .= "<tr><td><li><b>Mark as deleted:</b>&nbsp;&nbsp;<input type=checkbox name=isdeleted value='T' $checked></td></tr>\n" if $isupdate;

    $output .= "<tr><td colspan=2><center><br><input type=button name=checkbutton value=\"Check Work\" title=\"Click to check work\" onClick=checkWork()>&nbsp;&nbsp;\n";
    $output .= "<input type=button name=submitbutton value=\"Submit\" title=\"Click to submit source document\" onClick=validateStuff('enter_process')></center><br></td></tr>\n";

    $output .= "</table>\n";
    $output .= <<END_OF_BLOCK;

    <script language=javascript><!--
    function validateStuff(command) {
        var msg = "";
//        msg += (document.$args{form}.sourceid.value == "") ? "You must select the source document of this criterion.\\n" : "";
        msg += (isblank(document.$args{form}.qrsectionid.value)) ? "You must enter the section ID.\\n" : "";
        msg += (isNaN(document.$args{form}.requirementid.value) == true || document.$args{form}.requirementid.value < 0) ? document.$args{form}.requirementid.value + " is not a valid sub ID.\\n" : "";
        msg += (isblank(document.$args{form}.qrtext.value)) ? "You must enter the text of the section/criterion.\\n" : "";
        if (msg != "") {
            alert (msg);
        }
        else {
            submitFormCGIResults('$args{form}', command);
        }
    }
    function checkWork () {
        var msg = "Source ID: " + document.$args{form}.sourceid.value + "\\n";
        msg += "Section ID: " + document.$args{form}.qrsectionid.value + "\\n";
        msg += "Sub ID: " + document.$args{form}.requirementid.value + "\\n";
        msg += "Section Text: " + document.$args{form}.qrtext.value + "\\n";
        alert (msg);
    }
    //--></script>
END_OF_BLOCK

    $output .= "\n";
    return ($output);
}

####################################
sub doSourceRequirementEntryMatrix {
####################################
    my %args = (
        qardtypeid => 1,
        @_,
    );
    my $output = "";
    my $message = '';
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;

    my $qardrid = ($settings{rid}) ? $settings{rid} : $settings{aqaprid};
    my ($qardtype) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "description", table => "qardtype", where => "id = $settings{qardtypeid}");
    $output .= "<input type=hidden name=qrid value=$settings{qrid}>\n";
    my $isupdate = ($settings{qrid}) ? "1" : "0";
    $output .= "<input type=hidden name=isupdate value=$isupdate>\n";
    $output .= "<input type=hidden name=rid value=$qardrid>\n";
    $output .= "<input type=hidden name=qardtypeid value=$settings{qardtypeid}>\n";
    $output .= "<input type=hidden name=matrix value=$settings{matrix}>\n";
    my $sourceid = $settings{sourceid};
    my $sectionid = "";
    my $requirementid = "";
    my $text = "";
    my $mid = 0;
    my $isdeleted = "";
    my $ocrwmposition = "";
    my $ocrwmjustification = ""; 
    my $sorter = "main";
    my $sourcetypeid = 0;
    my $designation = "";
    my $title = "";
    my $table1aid = 0;
	
    ($sourceid, $sectionid, $text, $requirementid, $isdeleted, $ocrwmposition, $ocrwmjustification, $sorter, $table1aid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "sourceid, sectionid, text, requirementid, isdeleted, ocrwmposition, ocrwmjustification, sorter, table1aid", table => "sourcerequirement", where => "id = $settings{qrid}") if $settings{qrid};

    if ($settings{rid} >= 30) { #rid:30 == revision 20
    	($ocrwmposition, $ocrwmjustification) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "ocrwmposition, ocrwmjustification", table => "srnotes", where => "srid = $settings{qrid} and rid = $settings{rid}") if $settings{qrid};
    }
    
    if ($settings{qardtypeid} == 1) {
        ($mid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "id", table => "matrix", where => "sourceid = $sourceid and qardid = $settings{rid}") if $settings{qrid};
    }
    elsif ($settings{qardtypeid} == 2) {
        ($mid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "id", table => "matrix", where => "qardid = $settings{rid}") if $settings{qrid};
    }
    $mid = ($mid) ? $mid : 0;
    $table1aid = ($table1aid) ? $table1aid : 0;
    ($sourcetypeid, $designation, $title) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "typeid, designation, title", table => "source", where => "id = $sourceid");

    $requirementid = ($requirementid) ? $requirementid : ""; 
    $sourcetypeid = ($sourcetypeid) ? $sourcetypeid : ""; 
    $output .= "<table width=650 align=center cellpadding=5 border=1>\n";
    $output .= "<input type=hidden name=typeid value=$sourcetypeid>\n";

    $output .= "<input type=hidden name=sourceid value=$sourceid>\n";
    $output .= "<input type=hidden name=qrsectionid value=$sectionid>\n";
    $output .= "<input type=hidden name=requirementid value=$requirementid>\n";
    $output .= "<input type=hidden name=qrtext value=$text>\n";
    $output .= "<input type=hidden name=matrixid value=$mid>\n";
    $output .= "<input type=hidden name=matrix value=1>\n";
    my $sourcebgcolor = "#ffff99";
    if ($sourcetypeid == 1) {
       $sourcebgcolor = $RegulatoryHeader;
    }
    elsif ($sourcetypeid == 2) {
       $sourcebgcolor = $CommitmentHeader;
    }
    elsif ($sourcetypeid == 3) {
       $sourcebgcolor = $GuidanceHeader;
    }
    elsif ($sourcetypeid == 4) {
       $sourcebgcolor = $ReferenceHeader;
    }

    $output .= "<tr bgcolor=$sourcebgcolor><td colspan=2><font face=$SYSFontFace size=3><b>Source Document:&nbsp;&nbsp;&nbsp;&nbsp;$designation - $title</b></font>\n"; 
    $output .= "</td></tr>\n";

    $output .= "<tr bgcolor=#ffffff><td valign=top width=150><font face=$SYSFontFace size=2><b>Section ID - Sub ID:</b><br>\n";
    $output .= "$sectionid - $requirementid\n";
    $output .= "</font></td><td valign=top><font face=$SYSFontFace size=2><b>Text:</b><br>\n";
    $output .= "$text</font></td></tr></table>\n";

    $output .= "<br><table width=650 align=center>\n";
    my $qardrevision = "None";
    ($qardrevision) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "revid", table => "qard", where => "id = $qardrid") if $qardrid;
    $output .= "<tr><td colspan=2><li><b>$qardtype $qardrevision</b></td></tr>\n";
    $output .= "<tr><td colspan=2><li><b>Compliance Matrix:</b>&nbsp;&nbsp;\n";
    my ($mtitle) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "title", table => "matrix", where => "id = $mid"); 
    $output .= "<b>$mtitle</b>\n";
    $output .= "</td></tr>\n";
    my $where = ($qardrid) ? " and qardrevid = $qardrid" : "";
    my $therevid = ($qardrid) ? $qardrid : 0;

    tie my %allsections, "Tie::IxHash";
    %allsections = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "id", nameColumn => "sectionid || ' - ' || subid", table => "qardsection", where => "isdeleted = 'F' $where", orderBy => "tocid, sorter, sectionid, subid")};

    tie my %selectedsections, "Tie::IxHash";
    %selectedsections = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "s.id", nameColumn => "s.sectionid || ' - ' || s.subid", table => "qardsection s, $args{schema}.qardmatrix m", orderBy => "s.tocid, s.sorter, s.sectionid, s.subid", where => "m.matrixid = $mid and m.sourcerequirementid = $settings{qrid} and m.qardsectionid = s.id and s.isdeleted = 'F'")};

    $output .= "<tr><td colspan=2><li><b>Assign $qardtype Sections from $qardrevision:</b><center>\n";
    $output .= &build_dual_select ('subsections', "$args{form}", \%allsections, \%selectedsections, "Available $qardtype Sections", "Selected $qardtype Sections");
    $output .= "</td></tr>\n";

    if ($settings{qardtypeid} == 1) {
        tie my %allt1a, "Tie::IxHash";
        %allt1a = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "id", nameColumn => "item || ' - ' || subid", table => "qardtable1a", where => "revisionid = $therevid and isdeleted = 'F'", orderBy => "item, subid")};
        tie my %selectedt1a, "Tie::IxHash";
        
        #original 02/07/08
        #%selectedt1a = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "t.id", nameColumn => "t.item || ' - ' || t.subid", table => "qardtable1a t, $args{schema}.requirementtable1a r", orderBy => "t.item, t.subid", where => "r.requirementid = $settings{qrid} and r.table1aid = t.id and t.isdeleted = 'F'")};
         
         if ($settings{rid} >= 30) { #rid:30 == revision 20
         	%selectedt1a = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "t.id", nameColumn => "t.item || ' - ' || t.subid", table => "qardtable1a t, $args{schema}.requirementtable1a r", orderBy => "t.item, t.subid", where => "r.rid = $settings{rid} and r.requirementid = $settings{qrid} and r.table1aid = t.id and t.isdeleted = 'F'")};
        }else{
         	%selectedt1a = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "t.id", nameColumn => "t.item || ' - ' || t.subid", table => "qardtable1a t, $args{schema}.requirementtable1a r", orderBy => "t.item, t.subid", where => "r.requirementid = $settings{qrid} and r.table1aid = t.id and t.isdeleted = 'F' and r.rid is null")};	
         }
         
        $output .= "<tr><td colspan=2><li><b>Assign Items from $qardrevision Table 1A:</b><center>\n";
        $output .= &build_dual_select ('table1a', "$args{form}", \%allt1a, \%selectedt1a, "Available Table 1A Items", "Selected Table 1A Items");
        $output .= "</td></tr>\n";

        #$output .= "<tr><td colspan=2><b><li>Notes, OCRWM Position, etc.:</b><br>\n";
	    
	         if ($settings{rid} >= 30) { #rid:30 == revision 20	# 03/18/08 sh
	    		$output .= "<tr><td colspan=2><b><li>Notes:</b><br>\n"; 
	         }else{
	         	$output .= "<tr><td colspan=2><b><li>Notes, OCRWM Position, etc.:</b><br>\n";
	         }
	    
	    
        $ocrwmposition = ($ocrwmposition) ? $ocrwmposition : "";
        $ocrwmjustification = ($ocrwmjustification) ? $ocrwmjustification : "";
        $output .= "<textarea name=ocrwmposition cols=75 rows=5>$ocrwmposition</textarea></td></tr>\n";
        
        #$output .= "<tr><td colspan=2><b><li>Justification for OCRWM Position:</b><br>\n";
        #$output .= "<textarea name=ocrwmjustification cols=75 rows=5>$ocrwmjustification</textarea></td></tr>\n";
        
         if ($settings{rid} >= 30) { #rid:30 == revision 20	# 03/18/08 sh
	    		 $output .= "<tr><td colspan=2><!--b><li>Justification for OCRWM Position:</b><br-->\n";
        		 $output .= "<textarea name=ocrwmjustification cols=75 rows=1 style='visibility:hidden;'>$ocrwmjustification</textarea></td></tr>\n";
	         }else{
	         	 $output .= "<tr><td colspan=2><b><li>Justification for OCRWM Position:</b><br>\n";
        		 $output .= "<textarea name=ocrwmjustification cols=75 rows=5>$ocrwmjustification</textarea></td></tr>\n";
	         }
                
    }

    $output .= "<tr><td colspan=2><center><br><input type=button name=checkbutton value=\"Check Work\" title=\"Click to check work\" onClick=checkWork()>&nbsp;&nbsp;\n";
    $output .= "<input type=button name=submitbutton value=\"Submit\" title=\"Click to submit source document\" onClick=validateStuff('enter_matrix_process')></center><br></td></tr>\n";

    $output .= "</table>\n";
    $output .= <<END_OF_BLOCK;

    <script language=javascript><!--
    function validateStuff(command) {
        var msg = "";
//        msg += (document.$args{form}.sourceid.value == "") ? "You must select the source document of this requirement.\\n" : "";
        if (document.$args{form}.qardtypeid.value == 1) {
            msg += (isblank(document.$args{form}.qrsectionid.value)) ? "You must enter the section ID.\\n" : "";
            msg += (isNaN(document.$args{form}.requirementid.value) == true || document.$args{form}.requirementid.value < 0) ? document.$args{form}.requirementid.value + " is not a valid sub ID.\\n" : "";
            msg += (isblank(document.$args{form}.qrtext.value)) ? "You must enter the text of the section/criterion.\\n" : "";
        }
        if (msg != "") {
            alert (msg);
        }
        else {
            selectemall (document.$args{form}.subsections);
            if (document.$args{form}.qardtypeid.value == 1) {
                selectemall (document.$args{form}.table1a);
            }
            submitFormCGIResults('$args{form}', command);
        }
    }
    function checkWork () {
        var msg = "Source ID: " + document.$args{form}.sourceid.value + "\\n";
        msg += "Section ID: " + document.$args{form}.qrsectionid.value + "\\n";
        msg += "Sub ID: " + document.$args{form}.requirementid.value + "\\n";
        msg += "Section Text: " + document.$args{form}.qrtext.value + "\\n";
        msg += "Notes, OCRWM Position: " + document.$args{form}.ocrwmposition.value + "\\n";
        msg += "Justification for OCRWM Position:" + document.$args{form}.ocrwmjustification.value + "\\n";
        alert (msg);
    }
    //--></script>
END_OF_BLOCK

    $output .= "\n";
    return ($output);
}

###############################
sub doSourceRequirementBrowse {
###############################
    my %args = (
        matrix => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    $settings{rid} = ($settings{rid}) ? $settings{rid} : 0;

    my $sourceid = 0;
    my $qardid = 0;
    my $matrixid = 0;
    if ($settings{qardtypeid} == 2) {
        $sourceid = $settings{aqapsourceid};
        $qardid = ($settings{aqaprid}) ? $settings{aqaprid} : 0; 
        $matrixid = $settings{aqapmatrixid} ? $settings{aqapmatrixid} : 0;
   }
    elsif ($settings{qardtypeid} == 1) {
        $sourceid = ($settings{sourceid}) ? $settings{sourceid} : $settings{sid};
        $qardid = $settings{rid};
        $matrixid = $settings{matrixid} ? $settings{matrixid} : 0;
    }
    if ($matrixid) {
    ($qardid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "qardid", table => "matrix", where => "id = $matrixid");
    }
    my $sourceidlist = "(";
    if ($settings{command} eq "browse_matrix") {
        $matrixid = ($settings{qardtypeid} == 2) ? $settings{aqapmatrixid} : $settings{matrixid};
        if ($settings{qardtypeid} == 1) {
            ($qardid, $sourceid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "qardid, sourceid", table => "matrix", where => "id = $matrixid"); 
        }
        elsif ($settings{qardtypeid} == 2) {
            my @mats = &getMatrices (dbh => $args{dbh}, schema => $args{schema}, where => "id = $matrixid");
            for (my $i = 1; $i <= $#mats; $i++) {
                 $sourceidlist .= "$mats[$i]{sourceid}, ";
            }
        }
        chop ($sourceidlist);
        chop ($sourceidlist);
    }
    $sourceidlist .= ")" if $sourceidlist;
    
    my $matrix = ($settings{matrix}) ? $settings{matrix} : $args{matrix};
    my $output = "";
    $output .= "<input type=hidden name=qrid value=>\n";
    $output .= "<input type=hidden name=isupdate value=$settings{isupdate}>\n";
    $output .= "<input type=hidden name=sourceid value=$sourceid>\n";
    $output .= "<input type=hidden name=qardtypeid value=$settings{qardtypeid}>\n";
    $output .= "<input type=hidden name=matrix value=$matrix>\n";
    $output .= "<input type=hidden name=matrixid value=$matrixid>\n";
#    $output .= ($settings{sourceid}) ? "<input type=hidden name=sourceid value=$settings{sourceid}>\n" : "<input type=hidden name=sourceid value=$settings{sid}>\n";

print STDERR "matrix id: $matrixid; qard id: $qardid; source id: $sourceid; qardtypeid: $settings{qardtypeid}\n";
    $output .= "<table width=750 align=center cellspacing=0 cellpadding=3 border=0>\n";
    my $message = '';
    my $key;


    $output .= "<input type=hidden name=rid value=$qardid>\n";
    my ($qardtype) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "description", table => "qardtype", where => "id = $settings{qardtypeid}");
    my ($qardrevision) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "revid", table => "qard", where => "id = $qardid");
    $output .= "<tr><td><font face=$SYSFontFace>To link requirements from <font size=4><b>$qardtype $qardrevision</b></font> to a specific criterion, click on a section ID from the selected source document:</font></td></tr>\n" if ($settings{command} eq "browse_matrix");

    my $sourcelist = "";
    my $requirementslist = "";
    my $where = "";
    if ($sourceid) {
        $where = "id = $sourceid";
    }
    elsif ($sourceidlist && $sourceidlist ne "()") {
        $where = "id in $sourceidlist";
    }

    my (@sources) = &getSourceDocs (dbh => $args{dbh}, schema => $args{schema}, table => "source", orderby => "designation", where => $where);

    my ($sid, $designation, $desjump, $title, $rid, $sectionid, $text, $tempqardids, $requirementid, $type, $typeid);
    for (my $i = 1; $i <= $#sources; $i++) {
        $sid = $sources[$i]{id};
        $designation = $sources[$i]{designation};
        $title = $sources[$i]{title};
        ($type) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "sourcetype", what => "description", where => "id = $sources[$i]{typeid}");
        $sourcelist .= "<li><a href=#$sid title=\"Click to jump to the contents of this document\">$designation $title</a>\n";
        my (@requirements) = &getSourceRequirements (dbh => $args{dbh}, schema => $args{schema}, where => "isdeleted = 'F' and sourceid = $sid", orderby => "id");
        my $headercolor = "#ffff99";
        $headercolor = "#" . $SYSColorBlueHeader if ($sources[$i]{typeid} == 1);
        $headercolor = "#" . $SYSColorGreenHeader if ($sources[$i]{typeid} == 2);
        $headercolor = $SYSColorRedHeader if ($sources[$i]{typeid} == 3);
        $headercolor = $SYSColorPurpleHeader if ($sources[$i]{typeid} == 4);
        my $count = 0;
        $requirementslist .= "</table>\n<table width=750 border=1 cellpadding=3 cellspacing=0 align=center bgcolor=#ffffff>\n<tr bgcolor=$headercolor><td colspan=2 align=center><a name=$sid></a><font size=+1 face=$SYSFontFace><b>$designation: $title</b><br>[$type Document]</td></tr>\n";
        for (my $i = 1; $i <= $#requirements; $i++) {
            $rid = $requirements[$i]{id};
            $sectionid = $requirements[$i]{sectionid};
            $requirementid = ($requirements[$i]{requirementid}) ? "&nbsp;-&nbsp;$requirements[$i]{requirementid}" : "&nbsp;-&nbsp;0";
            $text = $requirements[$i]{text};
            $tempqardids = $requirements[$i]{tempqardsections};
            if ($count == 0) {
                $requirementslist .= "<tr bgcolor=#eeeeee><td><font size=2 face=$SYSFontFace><b>Section ID - Sub ID</td><td><font size=2 face=$SYSFontFace><b>Text</td></tr>\n<tr><td colspan=2></td></tr>\n";
            }
            if ($settings{isupdate} || $matrix) {
                $requirementslist .= "<tr valign=top><td width=150><font face=$SYSFontFace size=2><a href=javascript:submitForm4('requirement','enter',$rid) title=\"Click to assign QARD sections to this source document section\">$sectionid$requirementid</a></td><td><font size=2 face=$SYSFontFace>" . &getDisplayString($text,200) . "</td></tr>\n";
            }
            else {
                $requirementslist .= "<tr valign=top><td width=150><font size=2 face=$SYSFontFace><a href=javascript:popQARD('requirement',$rid)>$sectionid$requirementid</a></td><td><font size=2 face=$SYSFontFace>$text</td></tr>\n";
            }
            $count++;
        }
    }
     $requirementslist .= "</table>\n";
#    $output .= "<tr><td colspan=2><font size=2>$sourcelist</font></td></tr>\n";
    $output .= $requirementslist;

    $output .= "</table><br>";
    return ($output);
}

###############
sub doPopQARD {
###############
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $count = 0;
    my ($sectionid, $sourcedesignation, $stext, $stitle) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "sourcerequirement r, $args{schema}.source s", what => "r.sectionid || ' - ' || r.requirementid, s.designation, r.text, s.title", where => "r.id = $settings{qrid} and r.sourceid = s.id");
    my $outstr = "<table width=600 align=left><tr><td>\n";
    $outstr .= "<center><font face=$SYSFontFace><b>$sourcedesignation $stitle</center><br><br>Section $sectionid</b><br><br>$stext</font>\n<br><hr><br>\n";

    my $getqards = "";

    my ($qardtype) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "description", table => "qardtype", where => "id = $settings{qardtypeid}"); 
    $outstr .= "<b>Related $qardtype Sections:</b><br><br>\n";

    $getqards = $args{dbh} -> prepare ("select q.id, q.sectionid, q.subid, q.title || ' ' || q.text, r.revid from $args{schema}.qardsection q, $args{schema}.qardmatrix m, $args{schema}.qard r where r.isdeleted = 'F' and m.qardsectionid = q.id and m.sourcerequirementid = $settings{qrid} and q.qardrevid = r.id");

    $getqards -> execute;
    while (my ($id, $sectionid, $subid, $sectiontext, $revid) = $getqards -> fetchrow_array) {
        $sectionid = ($subid) ? "$sectionid - $subid" : $sectionid;
        $outstr .= "<font face=$SYSFontFace size=2><b>$revid, Section $sectionid:</b> $sectiontext</font><br><br>\n";
        $count++;
    }
    $getqards -> finish;

    $outstr .= "None\n" if ($count == 0);
    $outstr .= "</td></tr></table>\n";
    return ($outstr);
}

##########################
sub doSourceBrowseDetail {
##########################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $key;

    my $sourceid = 0;
    if ($settings{qardtypeid} == 2) {
        $sourceid = ($settings{aqapsourceid}) ? $settings{aqapsourceid} : $settings{sourceid};
    }
    else {
        $sourceid = ($settings{sourceid}) ? $settings{sourceid} : $settings{sid};
    }
    my ($designation, $title, $type) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "s.designation, s.title, t.description", table => "source s, $args{schema}.sourcetype t", where => "s.id = $sourceid and s.typeid = t.id");

    my $textcolor = "#000000";
    $textcolor = $Regulatory if ($type eq "Regulatory");
    $textcolor = $Commitment if ($type eq "Commitment");
    $textcolor = $Guidance if ($type eq "Guidance");
    $textcolor = $Reference if ($type eq "Reference");

    my $docquery = "select id, sectionid, text, requirementid from $args{schema}.sourcerequirement where sourceid = $sourceid and isdeleted = 'F' order by sorter desc, sectionid, requirementid";

    my $getdoc = $args{dbh} -> prepare ($docquery);
    $getdoc -> execute;
    $output .= "<input type=hidden name=qrid value=>\n";
    $output .= "<input type=hidden name=qardtypeid value=$settings{qardtypeid}>\n";
    $output .= "<table width=750 align=center cellspacing=7><tr><td align=center colspan=2>\n";
    $output .= "<font face=$SYSFontFace><b>$designation</b><br>$title<br><b>[$type Document]</b><br></td></tr>\n";
    while (my ($rid, $section, $text, $reqid) = $getdoc -> fetchrow_array) {
        $text =~ s/\n/<br>/g;
        my $fullid = ($reqid) ? "$section - $reqid" : "$section - 0";
        $output .="<tr valign=top><td width=190 align=right nowrap><a href=javascript:popQARD('requirement',$rid)><font size=2 color=$textcolor face=$SYSFontFace><b>$fullid</b></font></a></td><td><font size=2 face=$SYSFontFace color=$textcolor>$text<br></td></tr>\n";
    }

    $output .= "</table>\n";
    $getdoc -> finish;
    return ($output);
}

######################
sub doUndeleteSelect {
######################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";

    $outstr .= "<input type=hidden name=qrid value=$settings{qrid}>\n";
    $outstr .= "<table width=750 border=1 cellspacing=0 cellpadding=3 align=center bgcolor=#ffffff>\n";
    $outstr .= "<tr bgcolor=#a0e0c0><td width=100><b>Undelete</b></td><td><b>Criterion</b></td><tr>\n";

    my $stuff;
    $stuff = "select 'Source document ' || s.designation || ', Section ' || r.sectionid || ' - ' || r.requirementid || ': ' || r.text, r.id from $args{schema}.sourcerequirement r, $args{schema}.source s where r.isdeleted = 'T' and r.sourceid = s.id order by r.sourceid, r.sectionid";
    my $csr = $args{dbh} -> prepare ($stuff);
    $csr -> execute;
    while (my ($text, $id) = $csr -> fetchrow_array) {
        $outstr .= "<tr><td><font size=2 face=$SYSFontFace><a href=javascript:submitUndelete('requirement','undelete_process','',$id)>Undelete</a></td>\
<td><font size=2 face=$SYSFontFace>" . &getDisplayString($text, 100) . "</td></tr>\n";
    }
    $csr -> finish;
    $outstr .= "</table>\n";

    return ($outstr);
}

#####################
sub doApproveMatrix {
#####################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";

    my $matrixid = $settings{approvalmatrixid};

    $outstr .= "<input type=hidden name=approvalmatrixid value=$matrixid>\n";

    my ($dateapproved, $qardtypeid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "to_char(m.dateapproved, 'YYYYMMDD HH24MISS'), q.qardtypeid", table => "qard q, $args{schema}.matrix m", where => "m.id = $matrixid and m.qardid = q.id");
    $dateapproved = $dateapproved ? $dateapproved : "19550101";

#    $outstr .= &matrixButtons (dbh => $args{dbh}, schema => $args{schema}, matrixid => $matrixid);

    $outstr .= "<tr><td>\n";
    if ($qardtypeid == 1) {
        $outstr .= &doDisplayHTMLReport (dbh => $args{dbh}, schema => $args{schema}, settings => \%settings, approval => 1, dateapproved => $dateapproved, matrixid => $matrixid);
    }
    elsif ($qardtypeid == 2) {
        $outstr .= &doMainAQAPReport (dbh => $args{dbh}, schema => $args{schema}, settings => \%settings, approval => 1, dateapproved => $dateapproved, matrixid => $matrixid);
    }
    $outstr .= "</td></tr>\n";

    $outstr .= &matrixButtons (dbh => $args{dbh}, schema => $args{schema}, matrixid => $matrixid);

    return ($outstr);
}

###################
sub matrixButtons {
###################
    my %args = (
        matrixid => 0,
        @_,
    );
    my ($rationale) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "rejectionrationale", table => "matrix", where => "id = $args{matrixid}");
    my $outstr = "";
    $outstr .= "<tr><td><table width=650 align=center>\n";
    $outstr .= "<tr><td><li><b>If matrix is disapproved, please enter rationale:</td></tr>\n";
    $rationale = $rationale ? $rationale : "";
    $outstr .= "<tr><td><textarea name=rationale rows=5 cols=75>$rationale</textarea></td></tr>\n";
    $outstr .= "<tr><td align=center><input type=button name=Approve value=Approve onClick=validateStuff('approve_matrix_process')>&nbsp;&nbsp;\n";
    $outstr .= "<input type=button name=Disapprove value=Disapprove onClick=validateStuff('disapprove_matrix_process')></td></tr>\n";
    $outstr .= "</table></td></tr>\n";

    $outstr .= <<END_OF_BLOCK;

    <script language=javascript><!--
    function validateStuff(command) {
        var msg = "";
        msg += (command == "disapprove_matrix_process" && document.requirement.rationale.value == "") ? "You must enter the rationale for matrix disapproval.\\n" : "";
        if (msg != "") {
            alert (msg);
        }
        else {
            submitFormCGIResults('requirement', command);
        }
    }
    //--></script>
END_OF_BLOCK

    return ($outstr);
}

###############
1; #return true

