# UI QARD Section functions
#
# $Source: /data/dev/rcs/prp/perl/RCS/UIQARD.pm,v $
# $Revision: 1.26 $
# $Date: 2005/10/06 15:56:03 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: UIQARD.pm,v $
# Revision 1.26  2005/10/06 15:56:03  naydenoa
# CREQ00065 - changed "toc sub-section" to "display in browse toc" on entry;
# Show 0 with 0th requirement; update table headings to "sect id - sub id"
#
# Revision 1.25  2005/09/28 17:30:09  naydenoa
# Phase 3 implementation
# Tweaked most functions to check for QA doc type to accommodate AQAP
# display and processing.
# Implemented backwards assignment - criteria to QARD/AQAP requirements
#
# Revision 1.24  2005/07/13 23:20:07  naydenoa
# CREQ00059 - add requirement id retrieval and display in doPopSource
#
# $Log: UIQARD.pm,v $
# Revision 1.26  2005/10/06 15:56:03  naydenoa
# CREQ00065 - changed "toc sub-section" to "display in browse toc" on entry;
# Show 0 with 0th requirement; update table headings to "sect id - sub id"
#
# Revision 1.25  2005/09/28 17:30:09  naydenoa
# Phase 3 implementation
# Tweaked most functions to check for QA doc type to accommodate AQAP
# display and processing.
# Implemented backwards assignment - criteria to QARD/AQAP requirements
#
# Revision 1.23  2005/07/08 22:11:40  naydenoa
# CREQ00058 - add link to AQAP compliance matrix
# proof of concept work for phase 3 not affecting current configuration
#
# Revision 1.22  2005/04/28 16:34:32  naydenoa
# Made the pop-up window the focus window when envoked at QARD browse
# CREQ00054
#
# Revision 1.21  2005/04/11 18:13:48  naydenoa
# Fixed omission of istoc assignment in section entry - CREQ00050
#
# Revision 1.20  2005/04/08 22:37:19  naydenoa
# Minor tweak to fix AQAP, QAMP, and QARD browse headings and selection
# CREQ00047
#
# Revision 1.19  2005/04/07 19:30:12  naydenoa
# Updated TOC formatting on QARD display - CREQ00046
# Added QAMP to types of QA documents - CREQ00047
#
# Revision 1.18  2005/03/28 17:34:19  naydenoa
# Added pop-up for Table 1 on QARD browse - CREQ00045
#
# Revision 1.17  2005/03/22 18:47:13  naydenoa
# Changed all occurrences of YMP to ORD - CREQ00043
#
# Revision 1.16  2005/03/15 21:36:11  naydenoa
# Updated linked QARD browse - added detailed TOC and Table 1 displays
# CREQ00036, CREQ00041
#
# Revision 1.15  2005/02/18 17:51:02  naydenoa
# Fix color retrieval - info was lost (doSectionBrowse)
#
# Revision 1.14  2005/02/17 16:37:48  naydenoa
# CREQ00033, CREQ00034, CREQ00038
# Modifications to pop-up for browse, color-coding processing for browse,
# table 1a sort, revision retrieval for log.
#
# Revision 1.13  2004/12/16 17:21:03  naydenoa
# Added validation for Table 1A - phase 2, CREQ00024
#
# Revision 1.12  2004/12/16 16:29:24  naydenoa
# Added color-coding functionality for QARD, added display for Table 1A,
# added QARD typing, modified update and undelete functionality to include
# Table 1A and AQAP, updated QARD entry with new QARD varieties (linked,
# current, archived), added approver utility - phase 2 development
#
# Revision 1.11  2004/10/28 22:56:56  naydenoa
# Bug fix on QARD update select sort stemming from CREQ00008
#
# Revision 1.10  2004/10/05 17:52:18  naydenoa
# Bug fix on QARD browse filtering stemming from CREQ00008
# Checkpoint for color-coding requirement (commented out for production move)
#
# Revision 1.9  2004/09/28 21:30:43  naydenoa
# Added sorter to QARD display - partial fulfillment of CREQ00027 rework
#
# Revision 1.8  2004/09/24 16:02:58  naydenoa
# CREQ00027 rework - add subid to QARD entry/update screen, sort QARD
# sections on update select
#
# Revision 1.7  2004/09/22 17:35:18  naydenoa
# CREQ00028 - defect in quoting a string in HTML QARD section entry form
#
# Revision 1.6  2004/09/22 17:12:17  naydenoa
# CREQ00027 - add subsection id's to qard browse display
# Checkpoint for CREQ00024
# CREQ00010 - add current QARD image to display
#
# Revision 1.5  2004/08/30 21:30:44  naydenoa
# CREQ00010 - add "iscurrent" to QARD revision entry, browse for
# archived QARD revisions
# Took out image capabilities - does not work; need to figure out why
#
# Revision 1.4  2004/08/18 20:09:27  naydenoa
# CREQ00017 - updated all QARD screen titles
#
# Revision 1.3  2004/07/23 16:58:12  naydenoa
# CREQ00014 - update proper text element value for QARD revision
#
# Revision 1.2  2004/06/17 22:41:56  naydenoa
# Updated titles
#
# Revision 1.1  2004/06/16 21:54:40  naydenoa
# Initial revision
#
#

package UIQARD;

# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBUtilities qw(:Functions);
use UI_Widgets qw(:Functions);
use DBQARD qw(:Functions);
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
      &getInitialValues       &doHeader             &doFooter
      &getTitle               &doMainMenu           &doSectionEntry
      &doSectionBrowse        &doPopSource          &doTableEntry
      &doTOCEntry             &doRevisionEntry      &doUpdateSelect
      &doQARDImage            &doUndeleteSelect     &doOtherImage
      &doBrowseQARDReference  &doTableUpdateSelect  &doAQAPEntry
      &doAddThing             &doBrowseAQAP         &doUpdateSelectTable
      &doQAMPEntry            &doBrowseQAMP         &doAQAPSectionEntry
      &doMatrixEntryStoQ      &doMatrixSelectStoQ
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doFooter
      &getTitle               &doMainMenu           &doSectionEntry
      &doSectionBrowse        &doPopSource          &doTableEntry
      &doTOCEntry             &doRevisionEntry      &doUpdateSelect
      &doQARDImage            &doUndeleteSelect     &doOtherImage
      &doBrowseQARDReference  &doTableUpdateSelect  &doAQAPEntry
      &doAddThing             &doBrowseAQAP         &doUpdateSelectTable
      &doQAMPEntry            &doBrowseQAMP         &doAQAPSectionEntry
      &doMatrixEntryStoQ      &doMatrixSelectStoQ
    )]
);

my $mycgi = new CGI;


##############
sub getTitle {
##############
    my %args = (
        command => '',
        update => '',
        what => '',
        @_,
    );
    my $qardtype = "QARD";
    $qardtype = "AQAP" if ($args{qardtypeid} == 2);
    $qardtype = "QAMP" if ($args{qardtypeid} == 3);

    my $title = "$qardtype Section";
    if ($args{command} eq "enter_section" || $args{command} eq "enter_section_aqap") {
        $title = (!$args{isupdate}) ? "Enter New " : "Update ";
        $title .= "$qardtype Section";
    }  
    elsif ($args{command} eq "enter_toc") {
        $title = ($args{isupdate}) ? "Update " : "Create New ";
        $title .= "$qardtype TOC";
    }
    elsif ($args{command} eq "enter_qard" || $args{command} eq "enter_aqap" || $args{command} eq "enter_qamp") {
        $title = ($args{isupdate}) ? "Update " : "Create New ";
        $title .= "$qardtype Revision";
    }
    elsif ($args{command} eq "enter_table") {
        $title = ($args{isupdate}) ? "Update " : "Create New ";
        $title .= "$qardtype Table 1A Row";
    }
    elsif ($args{command} eq "browse") {
        $title = "Browse $qardtype Sections";
    }
    elsif ($args{command} eq "browse_color") {
        $title = "Browse Color-Coded $qardtype Sections";
    }
    elsif ($args{command} eq "update_select" || $args{command} eq "update_select_aqap" || $args{command} eq "update_select_qamp") {
        if ($args{selection} eq "") {
            $title = "Select $qardtype Revision To Update";
        }
        elsif ($args{selection} eq "section") {
            $title = "Select $qardtype Section To Update";
        }
        elsif ($args{selection} eq "toc") {
            $title = "Select $qardtype TOC To Update";
        }
        elsif ($args{selection} eq "table") {
            $title = "Select $qardtype Table 1A Row To Update";
        }
    }
    elsif ($args{command} eq "update_select_table") {
        $title = "Select $qardtype Table 1A Row To Update" if $args{isupdate};
        $title = "View $qardtype Table 1A" if (!$args{isupdate});
    }
    elsif ($args{command} eq "update_toc_select") {
        $title = "Select $qardtype TOC Section To Update";
    }
    elsif ($args{command} eq "update_section_select") {
        $title = "Select $qardtype Section To Update";
    }
    elsif ($args{command} eq "browse_reference" || $args{command} eq "browse_aqap") {
        $title = "Browse Image-Only $qardtype Revisions";
    }
    elsif ($args{command} eq "undelete_revision" || $args{command} eq "undelete_aqap" || $args{command} eq "undelete_qamp") {
        $title = "Undelete $qardtype Revision";
    }
    elsif ($args{command} eq "undelete_toc") {
        $title = "Undelete $qardtype TOC";
    }
    elsif ($args{command} eq "undelete_section") {
        $title = "Undelete $qardtype Section";
    }
    elsif ($args{command} eq "undelete_table1a") {
        $title = "Undelete $qardtype Table 1A Row";
    }
    elsif ($args{command} eq "browse_qamp") {
        $title = "Browse QAMP Revisions";
    }
    elsif ($args{command} eq "browse_matrix") {
        $title = "Select $qardtype Section to Assign Criteria";
    }
    elsif ($args{command} eq "update_matrix") {
        $title = "$qardtype Compliance Matrix Assignment";
    }
    elsif ($args{command} eq "add_approver") {
        $title = "Add QA Documents Approver";
    }
    else {
        $title = "$qardtype";
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
       approver => (defined ($mycgi -> param ("approver"))) ? $mycgi -> param ("approver") : "",
       approvername => (defined ($mycgi -> param ("approvername"))) ? $mycgi -> param ("approvername") : "",
       aqaprid => (defined ($mycgi -> param ("aqaprid"))) ? $mycgi -> param ("aqaprid") : 0,
       aqapmatrixid => (defined ($mycgi -> param ("aqapmatrixid"))) ? $mycgi -> param ("aqapmatrixid") : 0,
       color => (defined ($mycgi -> param ("color"))) ? $mycgi -> param ("color") : 0,
       dateapproved => (defined ($mycgi -> param ("dateapproved"))) ? $mycgi -> param ("dateapproved") : "",
       dateapproved_day => (defined ($mycgi -> param ("dateapproved_day"))) ? $mycgi -> param ("dateapproved_day") : "",
       dateapproved_month => (defined ($mycgi -> param ("dateapproved_month"))) ? $mycgi -> param ("dateapproved_month") : "",
       dateapproved_year => (defined ($mycgi -> param ("dateapproved_year"))) ? $mycgi -> param ("dateapproved_year") : "",
       dateeffective => (defined ($mycgi -> param ("dateeffective"))) ? $mycgi -> param ("dateeffective") : "",
       dateeffective_day => (defined ($mycgi -> param ("dateeffective_day"))) ? $mycgi -> param ("dateeffective_day") : "",
       dateeffective_month => (defined ($mycgi -> param ("dateeffective_month"))) ? $mycgi -> param ("dateeffective_month") : "",
       dateeffective_year => (defined ($mycgi -> param ("dateeffective_year"))) ? $mycgi -> param ("dateeffective_year") : "",
       documentfile => (defined ($mycgi -> param ("documentfile"))) ? $mycgi -> param ("documentfile") : "",
       iscurrent => (defined ($mycgi -> param ("iscurrent"))) ? $mycgi -> param ("iscurrent") : "",
       isupdate => (defined ($mycgi -> param ("isupdate"))) ? $mycgi -> param ("isupdate") : 0,
       item => (defined ($mycgi -> param ("item"))) ? $mycgi -> param ("item") : "",
       justification => (defined ($mycgi -> param ("justification"))) ? $mycgi -> param ("justification") : "",
       nrcdescription => (defined ($mycgi -> param ("nrcdescription"))) ? $mycgi -> param ("nrcdescription") : "",
       nrcsource => (defined ($mycgi -> param ("nrcsource"))) ? $mycgi -> param ("nrcsource") : 0,
       parentsectionid => (defined ($mycgi -> param ("parentsectionid"))) ? $mycgi -> param ("parentsectionid") : "",
       position => (defined ($mycgi -> param ("position"))) ? $mycgi -> param ("position") : "",
       qardtocid => (defined ($mycgi -> param ("qardtocid"))) ? $mycgi -> param ("qardtocid") : "",
       qardtypeid => (defined ($mycgi -> param ("qardtypeid"))) ? $mycgi -> param ("qardtypeid") : 1,
       qrid => (defined ($mycgi -> param ("qrid"))) ? $mycgi -> param ("qrid") : 0,
       revid => (defined ($mycgi -> param ("revid"))) ? $mycgi -> param ("revid") : "",
       revisionid => (defined ($mycgi -> param ("revisionid"))) ? $mycgi -> param ("revisionid") : "",
       rid => (defined ($mycgi -> param ("rid"))) ? $mycgi -> param ("rid") : 0,
       rowid => (defined ($mycgi -> param ("rowid"))) ? $mycgi -> param ("rowid") : 0,
       sectionid => (defined ($mycgi -> param ("sectionid"))) ? $mycgi->param ("sectionid") : "",
       sectionstatusid => (defined ($mycgi -> param ("sectionstatusid"))) ? $mycgi -> param ("sectionstatusid") : "",
       sectiontext => (defined ($mycgi -> param ("sectiontext"))) ? $mycgi -> param ("sectiontext") : "",
       sectiontitle => (defined ($mycgi -> param ("sectiontitle"))) ? $mycgi -> param ("sectiontitle") : "",
       shortsectionid => (defined ($mycgi -> param ("shortsectionid"))) ? $mycgi -> param ("shortsectionid") : "",
       sid => (defined ($mycgi -> param ("sid"))) ? $mycgi -> param ("sid") : "",
       sourceid => (defined ($mycgi -> param ("sourceid"))) ? $mycgi -> param ("sourceid") : 0,
       standarddescription => (defined ($mycgi -> param ("standarddescription"))) ? $mycgi -> param ("standarddescription") : "",
       status => (defined ($mycgi -> param ("status"))) ? $mycgi -> param ("status") : "",
       subid => (defined ($mycgi -> param ("subid"))) ? $mycgi -> param ("subid") : 0,
       tid => (defined ($mycgi -> param ("tid"))) ? $mycgi -> param ("tid") : 0,
       tocid => (defined ($mycgi -> param ("tocid"))) ? $mycgi -> param ("tocid") : "",
       toctitle => (defined ($mycgi -> param ("toctitle"))) ? $mycgi -> param ("toctitle") : "",
       what => (defined ($mycgi -> param ("what"))) ? $mycgi -> param ("what") : 0,
       istoc => (defined ($mycgi -> param ("istoc"))) ? $mycgi -> param ("istoc") : "F",
       matrixid => (defined ($mycgi -> param ("matrixid"))) ? $mycgi -> param ("matrixid") : 0,
    ));
#        => (defined ($mycgi -> param (""))) ? $mycgi -> param ("") : "",

    my @sectionsList = $mycgi -> param ("subsections");
    $valueHash{subsections} = \@sectionsList;
    my $isupdate = (($valueHash{sid} || $valueHash{isupdate} || ($valueHash{rid}) && ($valueHash{command} eq "enter_qard" || $valueHash{command} eq "enter_aqap" || $valueHash{command} eq "enter_qamp"))) ? 1 : 0;
    $valueHash{title} = &getTitle(command => $valueHash{command}, isupdate => $isupdate, selection => $valueHash{selection}, what => $valueHash{what}, qardtypeid => $valueHash{qardtypeid});
    
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
    my $outstr = "";
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
    function submitFormUpdate(script,command,id,qardtypeid) {
        document.$args{form}.command.value = command;
        document.$args{form}.id.value = id;
        document.$args{form}.qardtypeid.value = qardtypeid;
        document.$args{form}.action = '$args{path}' + script + '.pl';
        document.$args{form}.target = 'main';
        document.$args{form}.submit();
    }
    function submitForm3(script, command, type) {
        document.$form.command.value = command;
        document.$form.type.value = type;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function submitForm4(script, command, prid) {
        document.$form.command.value = command;
        document.$form.rid.value = prid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
//alert (document.$form.sourceid.value);
        document.$form.submit();
    }
    function submitFormA(script, command, revisionid, sectionid) {
        document.$form.command.value = command;
        document.$form.rid.value = revisionid;
//        document.$form.sid.value = sectionid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function submitFormT(script, command, rowid) {
        document.$form.command.value = command;
        document.$form.rowid.value = rowid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function popSource (script,id,command) {
        var winName = "sourcewin";
        document.$form.command.value = command;
        document.$form.qrid.value = id;
        document.$form.action = '$path$form.pl';
        document.$form.target = winName;
        var newwin = window.open('',winName,"height=450,width=650,scrollbars=yes,toolbar=yes");
        newwin.creator = self;
        newwin.focus();
        document.$form.submit();
    }
    function displayQARDImage (revisionid) {
        var myDate = new Date();
        var winName = myDate.getTime();
        document.$form.command.value = 'view_image';
        document.$form.rid.value = revisionid;
        document.$form.action = '$path$form.pl';
        document.$form.target = winName;
        var newwin = window.open('',winName);
        newwin.creator = self;
        document.$form.submit();
    }
    function displayOtherImage (revisionid) {
        var myDate = new Date();
        var winName = myDate.getTime();
        document.$form.command.value = 'view_other_image';
        document.$form.rid.value = revisionid;
        document.$form.action = '$path$form.pl';
        document.$form.target = winName;
        var newwin = window.open('',winName);
        newwin.creator = self;
        document.$form.submit();
    }
    function submitUndelete (script, command, what, id) {
        document.$form.command.value = command;
        if (what == "qard" || what == "aqap" || what == "qamp") {
            document.$form.rid.value = id;
        }
        else if (what == "toc") {
            document.$form.tid.value = id;
        }
        else if (what == "table1a") {
            document.$form.rowid.value = id;
        }
        else {
            document.$form.sid.value = id;
        }
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
END_OF_BLOCK

    $outstr .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'T', includeJSWidgets => 'T');
    
    $outstr .= "<input type=hidden name=type value=0>\n";
#    $outstr .= "<input type=hidden name=rid value=>\n";
    $outstr .= "<table border=0 width=$args{width} align=center><tr><td>\n";

    return($outstr);
}

##############
sub doFooter {  # routine to generate html page footers
##############
    my %args = (
        @_,
    );
    my $outstr = "";
    $outstr .= &doStandardFooter();
    return($outstr);
}

################
sub doMainMenu {  # routine to generate main report menu
################
    my %args = (
        @_,
    );
    my $outstr = "";
    my $message = '';

    return($outstr);
}

####################
sub doSectionEntry {
####################
    my %args = (
        qardtypeid => 1,
        @_,
    );
    my $outstr = "";
    my $message = '';
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $selected = "";
    my $qardtypeid = ($args{qardtypeid}) ? $args{qardtypeid} : 0;
    my $qtypeid = (!($settings{qardtypeid})) ? 0 : $settings{qardtypeid};
    my $isupdate = ($settings{sid} || $settings{isupdate}) ? 1 : 0;
    $settings{sid} = (!$settings{sid} && $settings{id}) ? $settings{id} : $settings{sid};
    $outstr .= "<input type=hidden name=isupdate value=$isupdate>\n";
    $outstr .= "<input type=hidden name=sid value=$settings{sid}>\n";
    $outstr .= "<input type=hidden name=rid value=$settings{rid}>\n";
    $outstr .= "<input type=hidden name=aqaprid value=$settings{aqaprid}>\n";
    $outstr .= "<input type=hidden name=qardtypeid value=$qtypeid>\n";
    
    my $rid = ($qardtypeid == 2 || $qtypeid == 2) ? $settings{aqaprid} : $settings{rid};   
    my ($qardrevision) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "revid", table => "qard", where => "id = $rid");
    my ($qardtype) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "description", table => "qardtype", where => "id = $qtypeid");
    my $qardrevid = 0;
    my $tocid = 0;
    my $sectionid = "";
    my $subid = "";
    my $title = "";
    my $text = "";
    my $status = "";
    my $isdeleted = "";
    my $istoc = "";

    ($qardrevid, $tocid, $sectionid, $title, $text, $status, $isdeleted, $subid, $istoc) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "qardsection", what => "qardrevid, tocid, sectionid, title, text, status, isdeleted, subid, istoc", where => "id = $settings{sid}") if $settings{sid};
    $title = $title ? $title : "";

    $outstr .= "<table width=650 align=center cellspacing=10>\n";
    $outstr .= "<tr><td><li><b>$qardtype Revision:</b>&nbsp;&nbsp;\n";
    $outstr .= "$qardrevision</td></tr>\n";
    $outstr .= "<input type=hidden name=revid value=$qardrevision>\n";

    my $checked = "";
    if ($settings{qardtypeid} == 1) {
        $outstr .= "<tr><td><li><b>Table of Contents:</b>&nbsp;&nbsp;\n";
        $outstr .= "<select name=tocid><option value=''>Select TOC Section\n";
        tie my %qardtoc, "Tie::IxHash";
        %qardtoc = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "id", nameColumn => "tocid || '&nbsp;&nbsp;' || title", table => "qardtoc", orderBy => "id", where => "revisionid = $rid and isdeleted = 'F'")};
        my $thesection = "";
        foreach $key (keys %qardtoc) {
            $selected = ($key == $tocid) ? " selected" : "";
            $thesection = &getDisplayString ($qardtoc{$key}, 59);
            $outstr .= "<option value=$key$selected>$thesection\n";
        }
        $outstr .= "</td></tr>";
        $checked = ($istoc eq "T") ? " checked" : "";
        $outstr .= "<tr><td><li><b>Display in Browse Table of Contents:&nbsp;&nbsp;<input type=checkbox name=istoc value='T' $checked>\n";
        $outstr .= "</td></tr>";
    }
    $outstr .= "<tr><td><li><b>Section ID:&nbsp;&nbsp;\n";
    $outstr .= "<input name=shortsectionid size=40 maxlength=40 value=\"$sectionid\">" . &nbspaces (5) . "Sub ID:&nbsp;&nbsp;<input name=subid size=10 maxlength=4 value=\"$subid\"></td></tr>\n";
    $outstr .= "<tr><td><li><b>Section Title:<br>\n";
    $outstr .= "<textarea name=sectiontitle rows=3 cols=75>$title</textarea></td></tr>\n";
    $outstr .= "<tr><td><li><b>Section Text:&nbsp;&nbsp;</b><br><textarea name=sectiontext rows=5 cols=75>$text</textarea></b></td></tr>\n";
    my $dselected = ($status eq "D") ? " selected" : "";
    my $aselected = ($status eq "A") ? " selected" : "";
    $outstr .= "<tr><td><li><b>Section Status:</b>&nbsp;&nbsp<select name=sectionstatusid><option value=D$dselected>Draft<option value=A$aselected>Verified</select></td></tr>\n";
    $checked = ($isdeleted eq "T") ? " checked" : "";
    $outstr .= "<tr><td><li><b>Mark as Deleted:</b>&nbsp;&nbsp;<input type=checkbox name=isdeleted value='T' $checked></td></tr>\n" if $isupdate;
    $outstr .= "<tr><td colspan=2><center><br><input type=button name=checkbutton value=\"Check Work\" title=\"Click to check work\" onClick=checkWork()>&nbsp;&nbsp;\n";
    $outstr .= "<input type=button value=\"Submit\" title=\"Click to submit source document\" onClick=javascript:validateStuff('enter_process');></center><br></td></tr>\n";
    $outstr .= "</table>\n";

    $outstr .= <<END_OF_BLOCK;
    <script language=javascript><!--
    function validateStuff(command) {
        var msg = "";
//        msg += (document.$args{form}.revid.value == "") ? "You must select the QARD revision.\\n" : "";
        if (document.$args{form}.qardtypeid.value == 1) {
            msg += (document.$args{form}.tocid.value == "") ? "You must select the Table of Contents section.\\n" : "";
        }
        msg += (isblank(document.$args{form}.shortsectionid.value)) ? "You must enter the section ID.\\n" : "";
        msg += (isblank(document.$args{form}.sectiontitle.value) & isblank(document.$args{form}.sectiontext.value)) ? "You must enter the title or text of the section.\\n" : "";
        if (msg != "") {
            alert (msg);
        }
        else {
            submitFormCGIResults('$args{form}', command);
        }
    }
    function checkWork () {
        var confmsg = "";
        confmsg += "Revision ID: " + document.$args{form}.revid.value + "\\n";
//        confmsg += "TOC ID: " + document.$args{form}.tocid.value + "\\n";
        confmsg += "Section ID: " + document.$args{form}.shortsectionid.value + "\\n";
        confmsg += "Section Title:" + document.$args{form}.sectiontitle.value + "\\n";
        confmsg += "Section Text: " + document.$args{form}.sectiontext.value  + "\\n";
        alert (confmsg);
    }
    //--></script>

END_OF_BLOCK

    $outstr .= "\n";
    $outstr .= "\n";
    return ($outstr);
}

#####################
sub doSectionBrowse {
#####################
    my %args = (
        color => 0,
        matrix => 0,
        @_,
    );
    my $outstr = "";
    my $message = '';
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $tid = $settings{tid};
#    my $rid = $settings{revid};
    my $revisionid = $settings{rid} ? $settings{rid} : 0;
    my ($sourceid, $stitle, $sdesignation, $sourcestring) = ($settings{sourceid}, "", "", "");
    my $matrixid = ($settings{qardtypeid} == 1) ? $settings{matrixid} : $settings{aqapmatrixid};
#print STDERR "$matrixid\n";
    if ($matrixid || $args{matrixid}) {
        if ($settings{qardtypeid} == 1) {
            ($revisionid, $sourceid, $stitle, $sdesignation) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "m.qardid, m.sourceid, s.title, s.designation", table => "matrix m, $args{schema}.source s", where => "m.id = $matrixid and m.sourceid = s.id");
            $sourcestring = "<br><font face=helvetica>Click section ID to assign criteria from source document";
            $sourcestring .= ($settings{qardtypeid} == 1) ? " <b>$sdesignation $stitle</b></font><br><br>\n" : "s.<br><br>\n";
            $sourcestring .= "<input type=hidden name=sourceid value=$sourceid>\n";
        }
	elsif ($settings{qardtypeid} == 2) {
            ($revisionid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "qardid", table => "matrix", where => "id = $matrixid");
            $sourcestring = "<br><font face=helvetica>Click section ID to assign criteria from source document";
            $sourcestring .= "<br>Select source document from the dropdown:&nbsp;&nbsp;\n";
            $sourcestring .= &makeSourceDropdown (dbh => $args{dbh}, schema => $args{schema}, where => "typeid in (3, 5) and qardtypeid = 2 and isdeleted = 'F'", orderby => "typeid, designation", sid => $settings{sid}, tablerow => 0, blankentry => 0);
        }
    }

    my ($qardtype) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "description", table => "qardtype", where => "id = $settings{qardtypeid}");

    my $color = $args{color};
    my $colorheading = (!$args{color}) ? "<input type=button name=browsecolor onClick=submitForm('qard','browse_color') value=\"Color-code sections\">&nbsp;&nbsp;&nbsp;" : "<input type=button name=browse onClick=submitForm('qard','browse') value=\"Display sections in black-and-white\">&nbsp;&nbsp;&nbsp;";
    my $colspan = 2;
    my $tocheading = "";
    my $revheading = "";
    my $extraheading = "";
    my $tablerow = "";
    my $extracolumn = "";
    my $where = "isdeleted = 'F'";
    my $explanations = "";

    if ($revisionid) {
        $where .= "and qardrevid = $revisionid";
        ($revheading) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema},table => "qard", what => "' - ' || revid", where => "id = $revisionid");
        if ($tid) {
            $where .= " and tocid = $tid";
            ($tocheading) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema},table => "qardtoc", what => "' - ' || tocid || ': ' || title", where => "id = $tid"); 
        }
    }

    $outstr .= "<input type=hidden name=qrid value=0>\n";
    $outstr .= "<input type=hidden name=rid value=$revisionid>\n";
    $outstr .= "<input type=hidden name=revisionid value=$revisionid>\n";
    $outstr .= "<input type=hidden name=tid value=$tid>\n";
    $outstr .= "<input type=hidden name=matrixid value=$matrixid>\n";
    $outstr .= "<input type=hidden name=qardtypeid value=$settings{qardtypeid}>\n";
    $outstr .= $sourcestring;

    if ($color == 1 && $settings{qardtypeid} == 1 && $args{matrix} == 0) {
        $extraheading = "<td><b><font size=-1>508</font></b></td>";
        $colspan = 3;
        $explanations = "<table align=center bgcolor=#ffffff cellpadding=1 cellspacing=0 border=1>\n" .
                        "<tr valign=top bgcolor=#e0e0e0><td width=150><font face=$SYSFontFace size=2><b>Color-coding Legend:</b></td>\n" .
                        "<td width=50><font face=$SYSFontFace size=2><b>Color</b></td>\n" .
                        "<td width=200><font face=$SYSFontFace size=2><b>Source Type</b></td>\n" .
                        "<td width=110><font face=$SYSFontFace size=2><b>508 Designation</b></td></tr>\n" .
                        "<tr>" .
                        "<td bgcolor=$Regulatory>&nbsp;</td>" .
                        "<td><font face=$SYSFontFace size=2>Blue</td>\n" .
                        "<td><font face=$SYSFontFace size=2>Regulatory</td>\n" .
                        "<td><font face=$SYSFontFace size=2><b><font face=helvetica size=-1>Reg</font></b></td></tr>\n" .
                        "<tr bgcolor=#f9f9f9>" .
                        "<td bgcolor=#ffff99>&nbsp;</td>" .
                        "<td><font face=$SYSFontFace size=2>Yellow</td>\n" .
                        "<td><font face=$SYSFontFace size=2>DOE Order</td>\n" .
                        "<td><font face=$SYSFontFace size=2><b><font face=helvetica size=-1>O</font></b></td></tr>\n" .
                        "<tr>" .
                        "<td bgcolor=$Commitment>&nbsp;</td>" .
                        "<td><font face=$SYSFontFace size=2>Green</td>\n" .
                        "<td><font face=$SYSFontFace size=2>Commitment</td>\n" .
                        "<td><font face=$SYSFontFace size=2><b><font face=helvetica size=-1>C</font></b></td></tr>\n" .
                        "<tr bgcolor=#f9f9f9>" .
                        "<td bgcolor=$Guidance>&nbsp;</td>" .
                        "<td><font face=$SYSFontFace size=2>Red</td>\n" .
                        "<td><font face=$SYSFontFace size=2>Guidance</td>\n" .
                        "<td><font face=$SYSFontFace size=2><b><font face=helvetica size=-1>G</font></b></td></tr>\n" .
                        "<tr>" .
                        "<td bgcolor=$Reference>&nbsp;</td>" .
                        "<td><font face=$SYSFontFace size=2>Purple</td>\n" .
                        "<td><font face=$SYSFontFace size=2>Reference</td>\n" .
                        "<td><font face=$SYSFontFace size=2><b><font face=helvetica size=-1>Ref</font></b></td></tr>\n" .
                        "<tr bgcolor=#f9f9f9>" .
                        "<td bgcolor=$SYSColorOrange>&nbsp;</td>" .
                        "<td><font face=$SYSFontFace size=2>Orange</td>\n" .
                        "<td><font face=$SYSFontFace size=2>Multiple related source types</td>\n" .
                        "<td><font face=$SYSFontFace size=2><b><font face=helvetica size=-1>M</font></b></td></tr>\n" .
                        "<tr>" .
                        "<td bgcolor=#000000>&nbsp;</td>" .
                        "<td><font face=$SYSFontFace size=2>Black</td>\n" .
                        "<td><font face=$SYSFontFace size=2>Requirement endorsed by DOE Management with NRC concurrence&nbsp;</td>\n" .
                        "<td><font face=$SYSFontFace size=2><b><font face=helvetica size=-1>N/A</font></b></td></tr>\n" .
                        "</table><br>\n";
    }
    my $tocdisplay = "";
    my (@sections) = &getSections (dbh => $args{dbh}, schema => $args{schema}, orderby => "tocid, sorter, sectionid, subid", where => $where);
    my ($sectionid, $title, $text, $qrid, $subid, $istoc);
    for (my $i = 1; $i <= $#sections; $i++) {
        my $fontcolor = " color=#000000";
        my $compliance = "";
        $qrid = $sections[$i]{id};

        if ($color == 1 && $settings{qardtypeid} == 1 && $args{matrix} == 0) {
            my $colorcode = $sections[$i]{types};
            if ($colorcode eq "R") {
                $fontcolor = " color=$Regulatory";
                $compliance = "Reg";
            }
            elsif ($colorcode eq "C") {
                $fontcolor = " color=$Commitment";
                $compliance = "C";
            }
            elsif ($colorcode eq "G") {
                $fontcolor = " color=$Guidance";
                $compliance = "G";
            }
            elsif ($colorcode eq "F") {
                $fontcolor = " color=$Reference";
                $compliance = "Ref";
            }
            elsif ($colorcode eq "O") {
                $fontcolor = " color=#ffff99";
                $compliance = "O";
            }
            elsif ($colorcode eq "M") {
                $fontcolor = " color=$SYSColorOrange";
                $compliance = "M";
            }
            elsif ($colorcode eq "N") {
                $fontcolor = " color=#000000";
                $compliance = "N/A";
            }
            $extracolumn = "<td><b><font face=helvetica size=-1>$compliance</a></b></td>";
        }
        $sectionid = $sections[$i]{sectionid};
        $istoc = $sections[$i]{istoc};
        my $br = ($sections[$i]{title} && $sections[$i]{text}) ? "<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" : "";
        $title = ($sections[$i]{title}) ? "<b>$sections[$i]{title}</b>$br" : "";
        $text = ($sections[$i]{text}) ? $sections[$i]{text} : "";
        $text =~ s/\n/<br>/g;
        $subid = ($sections[$i]{subid}) ? " - $sections[$i]{subid}" : " - 0";
        my $sectionidnospace = $sections[$i]{sectionid};
        $sectionidnospace =~ s/ //g;
        my $jump = "<a name=$sectionidnospace></a>";
        my $thesection = "$jump$title $text";
        if ($sectionid eq "TOC") {
            my @tocs = &getFullTOC (dbh => $args{dbh}, schema => $args{schema}, revisionid => $revisionid);#&getSections (dbh => $args{dbh}, schema => $args{schema}, where => "qardrevid = $revisionid and istoc = 'T' and isdeleted = 'F'", orderby => "sorter, sectionid, subid");
            $thesection = "<table width=100% border=1 cellspacing=0 cellpadding=3>\n";
            $thesection .= "<tr bgcolor=#abcdef><td colspan=2><b>Table of Contents</td></tr>\n";
            $thesection .= "<tr bgcolor=#f0f0f0><td><font size=2 face=times><b>ID</td><td><font size=2 face=times><b>Title</td></tr>\n";
            for (my $i = 1; $i <= $#tocs; $i++) {
                my $tocidnospace = $tocs[$i]{tocid};
                $tocidnospace =~ s/ //g;
                my $tocid = "<a href=#$tocidnospace>$tocs[$i]{tocid}</a>";
                my $toctitle = ($tocs[$i]{title}) ? $tocs[$i]{title} : "&nbsp;";
                $thesection .= "<tr><td width=117><font size=2>$tocid</td><td><font size=2>$toctitle</td></tr>\n";
            }
            $thesection .= "</table>\n";
            $tocdisplay .= "<tr valign=top>$extracolumn<td colspan=2><font size=-1 face=helvetica>$jump$thesection</td></tr>\n";
#            $tablerow .= "<tr valign=top>$extracolumn<td colspan=2><font size=-1 face=helvetica>$jump$thesection</td></tr>\n";
        }
        elsif ($sectionid eq "Table 1" && $args{matrix} == 0) {
            $thesection = &doUpdateSelectTable (dbh => $args{dbh}, schema => $args{schema}, isupdate => 0, settings => \%settings, width => "100%", a => 0, sourcelink => 1, revisionid => $revisionid);
            $tablerow .= "<tr valign=top>$extracolumn<td colspan=2><font size=-1 face=helvetica>$jump$thesection</td></tr>\n";
        }
        else {
            $tablerow .= "<tr valign=top>$extracolumn<td>\n";
            $tablerow .= "<font size=-1 face=helvetica>$jump\n";
            if ($args{matrix}) {
                $tablerow .= "<a href=javascript:submitForm4('qard','update_matrix',$qrid)>$sectionid$subid</a></td>\n";
            }
            else {
                $tablerow .= "<a href=javascript:popSource('qard',$qrid,'pop_source')>$sectionid$subid</a>\n";
            }
            $tablerow .= "</td>\n";
            $tablerow .= "<td><font size=-1 face=helvetica$fontcolor>$thesection</td></tr>\n";
        }
    }

    my $maintableheader = "";
    $maintableheader .= "<tr bgcolor=#78b6ef><td colspan=$colspan>\n";
    $maintableheader .= "<table border=0 cellpadding=0 cellspacing=0 width=100%>\n";
    $maintableheader .= "<tr><td>\n";
    $maintableheader .= "<font face=helvetica size=3><b>$qardtype$revheading$tocheading</b></font>\n";
    $maintableheader .= "</td><td align=right>\n";
    $maintableheader .= "$colorheading\n" if ($args{matrix} == 0 && $settings{qardtypeid} == 1);
    $maintableheader .= "<input type=button name=qardimage onClick=displayQARDImage($revisionid) value=Image>\n";
    $maintableheader .= "</td></tr>\n";
    $maintableheader .= "</table>\n";
    $maintableheader .= "</td></tr>\n";

    $outstr .= $explanations;
    $outstr .= "<table width=750 align=center cellspacing=0 cellpadding=3 border=1 bgcolor=#ffffff>\n";
    if ($settings{qardtypeid} == 1) {
        $outstr .= $maintableheader if $tocdisplay;
        $outstr .= $tocdisplay;
    }
    $outstr .= $maintableheader;
    $outstr .= "<tr bgcolor=#eeeeee>$extraheading<td width=110><font size=2><b>Section&nbsp;ID&nbsp;-&nbsp;Sub&nbsp;ID</td><td><font size=2><b>Text</td></tr>\n";
    $outstr .= "<tr><td colspan=$colspan></td></tr>\n";
    $outstr .= $tablerow;
    $outstr .= "</table><br><br>\n";
    return ($outstr);
}

#################
sub doPopSource {
#################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $count = 0;
    my $outstr = "<table width=600 align=left><tr><td>\n";
    my $getsources;
    my ($qardtype) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "description", table => "qardtype", where => "id = $settings{qardtypeid}");

    if ($settings{command} eq "pop_table") {
        my $sources = "select s.designation, r.sectionid, r.text, r.requirementid from $args{schema}.source s, $args{schema}.sourcerequirement r, $args{schema}.requirementtable1a t where s.isdeleted = 'F' and t.table1aid = $settings{qrid} and t.requirementid = r.id and r.sourceid = s.id order by s.designation, r.sorter, r.sectionid, r.requirementid";
        my ($item, $subid, $revision, $nrcdescription, $standarddescription, $position) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "qardtable1a t, $args{schema}.qard q", what => "t.item, t.subid, q.revid, t.nrcdescription, t.standarddescription, t.position", where => "t.id = $settings{qrid} and t.revisionid = q.id");
        $outstr .= "<center><font face=helvetica><b>$qardtype $revision<br></center>Table 1, Item $item - $subid</b></center><br><br><font size=-1 face=times><b>US NRC Document:</b><br>$nrcdescription<br><br><b>National/Industry Standard:</b><br>$standarddescription<br><br><b>ORD Position:</b><br>$position</font>\n";
#<br><font size=2>$text<br>
        $outstr .= "<hr><br><font size=3><b>Related Criteria from Source Documents: </b><br><br><font size=2>\n";
        $getsources = $args{dbh} -> prepare ($sources);
    }
    else {
        my ($sectionid, $revision, $title, $text, $subid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "qardsection s, $args{schema}.qard q", what => "s.sectionid, q.revid, s.title, s.text, s.subid", where => "s.id = $settings{qrid} and s.qardrevid = q.id");
        $sectionid = ($subid) ? "$sectionid - $subid" : "$sectionid - 0";
        $text = ($title) ? "<b>$title</b><br>$text" : $text;
        $outstr .= "<center><font face=helvetica><b>$qardtype $revision<br></center>Section $sectionid</b></center><br><font size=2>$text<br><hr><br><font size=3><b>Related Criteria from Source Documents: </b><br><br><font size=2>\n";
        $getsources = $args{dbh} -> prepare ("select s.designation, r.sectionid, r.text, r.requirementid from $args{schema}.source s, $args{schema}.sourcerequirement r, $args{schema}.qardmatrix m where s.isdeleted = 'F' and m.qardsectionid = $settings{qrid} and m.sourcerequirementid = r.id and r.sourceid = s.id order by s.designation, r.sorter, r.sectionid, r.requirementid");
    }
    $getsources -> execute;
    while (my ($designation, $sectionid, $sectiontext, $reqid) = $getsources -> fetchrow_array) {
        my $subreq = ($reqid) ? " - $reqid" : "";
        $outstr .= "<font face=helvetica size=2><b>$designation, Section $sectionid$subreq:</b> $sectiontext</font><br><br>\n";
         $count++;
    }
    $getsources -> finish;
    $outstr .= "None\n" if ($count == 0);
    $outstr .= "</font></td></tr></table>\n";
    return ($outstr);
}

################
sub doTOCEntry {
################
    my %args = (
        @_,
    );
    my $outstr = "";
    my $message = '';
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $selected = "";
    my $key;
    my $isupdate = ($settings{tid} || $settings{isupdate}) ? 1 : 0;
    $settings{tid} = (!$settings{tid} && $settings{id}) ? $settings{id} : $settings{tid};

    my $toctitle = "";
    my $tocid = "";
    my $qardrevid = $settings{rid};
    my $isdeleted = "";
    my $qardtypeid = $settings{qardtypeid};

    ($tocid, $toctitle, $qardrevid, $isdeleted) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "qardtoc", what => "tocid, title, revisionid, isdeleted", where => "id = $settings{tid}") if $settings{tid};
    $outstr .= "<input type=hidden name=isupdate value=$isupdate>\n";
    $outstr .= "<input type=hidden name=tid value=$settings{tid}>\n";

    $outstr .= "<table width=650 align=center cellspacing=10>\n";
    $outstr .= "<tr><td><li><b>QARD Revision:</b>&nbsp;&nbsp;\n";
    my ($tmpoutstr) = &makeQARDDropdown (dbh => $args{dbh}, schema => $args{schema}, where => "qardtypeid = $qardtypeid and isdeleted = 'F' and iscurrent = 'L'", orderby => "revid desc", idlist => 0, blankentry => 0, tablerow => 0, rid => $qardrevid);
    $outstr .= $tmpoutstr;
=pod
    $outstr .= "<br><select name=rid><option value=''>Select QARD Revision\n";
    my $thesection = "";
    my @qards = getQARDRevs (dbh => $args{dbh}, schema => $args{schema}, where => "iscurrent = 'L' and isdeleted = 'F' and qardtypeid = 1", orderby => "revid desc");
    for (my $i = 1; $i <= $#qards; $i++) {
        my $id = $qards[$i]{id};
        my $revid = $qards[$i]{revid};
        $selected = ($id == $qardrevid) ? " selected" : "";
        $thesection = &getDisplayString ($revid, 59);
        $outstr .= "<option value=$id$selected>$revid\n";
    }
=cut
    $outstr .= "</td></tr>";
    $outstr .= "<tr><td><li><b>Table of Contents ID:&nbsp;&nbsp;\n";
    $outstr .= "<input name=tocid size=40 maxlength=40 value=\"$tocid\"></td></tr>\n";
    $outstr .= "<tr><td><li><b>Table of Contents Title:<br>\n";
    $outstr .= "<textarea name=toctitle rows=3 cols=75>$toctitle</textarea></td></tr>\n";
    my $checked = ($isdeleted eq "T") ? " checked" : "";
    $outstr .= "<tr><td><li><b>Mark as deleted:</b>&nbsp;&nbsp;<input type=checkbox name=isdeleted value='T' $checked></td></tr>\n" if $isupdate;
    $outstr .= "<tr><td><center><br><input type=button value=\"Submit\" title=\"Click to submit QARD table of contents section\" onClick=javascript:validateStuff('enter_toc_process');></center><br></td></tr>\n";
    $outstr .= "</table>\n";

    $outstr .= <<END_OF_BLOCK;
    <script language=javascript><!--
    function validateStuff(command) {
        var msg = "";
        msg += (document.$args{form}.rid.value == "") ? "You must select the QARD revision.\\n" : "";
        msg += (isblank(document.$args{form}.tocid.value)) ? "You must enter the TOC ID.\\n" : "";
        msg += (isblank(document.$args{form}.toctitle.value)) ? "You must enter the TOC title.\\n" : "";
        if (msg != "") {
            alert (msg);
        }
        else {
            submitFormCGIResults('$args{form}','enter_toc_process');
        }
    }
    //--></script>
END_OF_BLOCK

    $outstr .= "\n";
    $outstr .= "\n";
    return ($outstr);
}

#####################
sub doRevisionEntry {
#####################
    my %args = (
        @_,
    );
    my $outstr = "";
    my $message = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
#    my $isupdate = ($settings{rid}) ? 1 : 0;
#    my $isupdate = ($settings{rid} && $settings{isupdate}) ? 1 : 0;
#    my $isupdate = ($settings{rid} || $settings{isupdate}) ? 1 : 0;
    my $rid = "";
    $settings{rid} = (!$settings{rid} && $settings{id}) ? $settings{id} : $settings{rid};
    my $qardtypeid = ($settings{qardtypeid}) ? $settings{qardtypeid} : $args{qardtypeid};

    my ($qardtype) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "description", table => "qardtype", where => "id = $qardtypeid");
    $rid = $settings{rid};
    $rid = $settings{aqaprid} if ($settings{aqaprid} && $qardtypeid == 2);
    $rid = $settings{qamprid} if ($settings{qamprid} && $qardtypeid == 3);

    my $isupdate = ($rid || $settings{isupdate}) ? 1 : 0;

    my $revid = "";
    my $appby = 0;
    my $appdate = "";
    my $effdate = "";
    my $status = "";
    my $selected = "";
    my $imageextension = "";
    my $isdeleted = "";
    my $iscurrent = "";

    ($revid, $appby, $appdate, $effdate, $status, $imageextension, $isdeleted, $iscurrent) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "qard", what => "revid, approvedby, to_char(dateapproved,'MM/DD/YYYY'), to_char(dateeffective,'MM/DD/YYYY'), status, imageextension, isdeleted, iscurrent", where => "id = $rid") if ($rid);# && ($qardtype eq "QARD"));

    $outstr .= "<input type=hidden name=isupdate value=$isupdate>\n";
    $outstr .= "<input type=hidden name=rid value=$rid>\n";
    $outstr .= "<input type=hidden name=aqaprid value=$settings{aqaprid}>\n";
    $outstr .= "<input type=hidden name=qardtypeid value=$qardtypeid>\n";

    $outstr .= "<table width=700 align=center cellspacing=10>\n";
    $outstr .= "<tr><td colspan=4><li><b>$qardtype ID:&nbsp;&nbsp;\n";
    $outstr .= "<input name=revid size=40 maxlength=100 value=\"$revid\"></td></tr>\n";
    $outstr .= "<tr><td><li><b>Approved By:</td><td>\n";
    $outstr .= "<select name=approver><option value=''>Select Approver\n";
    $appby = ($appby) ? $appby : 0;
    tie my %approver, "Tie::IxHash";
    %approver = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "id", nameColumn => "name", table => "qardapprover", orderBy => "name")};
    foreach $key (keys %approver) {
        $selected = ($key == $appby) ? " selected" : "";
        $outstr .= "<option value=$key$selected>$approver{$key}\n";
    }
    $outstr .= "</td>\n";
    $outstr .= "<td><li><b>Date Approved:</td><td>\n";
    $appdate = ($appdate) ? $appdate : "";
    $outstr .= &buildDateSelection(element => 'dateapproved', form => $args{form}, initdate => $appdate, startyear => '1980') . "</td></tr>\n";
    my $dselected = ($status eq "D") ? " selected" : "";
    my $aselected = ($status eq "A") ? " selected" : "";
    $outstr .= "<tr><td><li><b>Revision Status:</b></td><td><select name=status><option value=D$dselected>Draft<option value=A$aselected>Approved</select></td>\n";
#    $outstr .= "<tr><td><li><b>Revision Status:</b></td><td><select name=status><option value=D" . ($status eq "D") ? " selected" : "" . ">Draft<option value=A" . ($status eq "A") ? " selected" : "" . ">Approved</select></td>\n";
    $outstr .= "<td><li><b>Effective Date:</td><td>\n";
    $effdate = ($effdate) ? $effdate : "";
    $outstr .= &buildDateSelection(element => 'dateeffective', form => $args{form}, initdate => $effdate, startyear => '1980') . "</td></tr>\n";
###
=pod
    $outstr .= "<tr><td colspan=4><li><b>Attach document:&nbsp;&nbsp;</b>(if available)\n";
    if ($imageextension) {
        $outstr .= "&nbsp;&nbsp;<a href=javascript:displayQARDImage($settings{rid}) title=\"Click to display the current document image\">Current revision image</a>\n";
    }
    $outstr .= "<br><input type=file name=documentfile size=50 maxlength=256></b></td></tr>\n";
=cut
    my $checked = ($isdeleted eq "T") ? " checked" : "";
    $outstr .= "<tr><td colspan=4><li><b>Mark as deleted:</b>&nbsp;&nbsp;<input type=checkbox name=isdeleted value='T' $checked></td></tr>\n" if $isupdate;
    $outstr .= "<tr><td colspan=2><li><b>Revision Type:</b>&nbsp;&nbsp;\n";
    $outstr .= "<select name=iscurrent>\n";
    my %qrevtype = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "abbrev", nameColumn => "description", table => "qardrevisiontype")};
    foreach $key (keys %qrevtype) {
        $selected = ($key eq $iscurrent) ? " selected" : "";
        $outstr .= "<option value=$key$selected>$qrevtype{$key}\n";
    }
    $outstr .= "</td></tr>\n";
###
    $outstr .= "<tr><td colspan=4><center><br><input type=button value=\"Submit\" title=\"Click to submit QARD document revision\" onClick=javascript:validateStuff('enter_qard_process');></center><br></td></tr>\n";
    $outstr .= "</table>\n";

    $outstr .= <<END_OF_BLOCK;
    <script language=javascript><!--
    function validateStuff(command) {
        var msg = "";
        msg += (isblank(document.$args{form}.revid.value)) ? "You must enter the QARD revision ID.\\n" : "";
        msg += (document.$args{form}.dateapproved_year.value != "" || document.$args{form}.dateapproved_month.value != "" || document.$args{form}.dateapproved_day.value != "") ? (validate_date(document.$args{form}.dateapproved_year.value,document.$args{form}.dateapproved_month.value,document.$args{form}.dateapproved_day.value,0,0,0,0,1,0,0)) : "";
        msg += (document.$args{form}.dateeffective_year.value != "") ? (validate_date(document.$args{form}.dateeffective_year.value,document.$args{form}.dateeffective_month.value,document.$args{form}.dateeffective_day.value,0,0,0,0,1,0,0)) : "";

        if (msg != "") {
            alert (msg);
        }
        else {
            submitFormCGIResults('$args{form}','enter_qard_process');
        }
    }
    //--></script>
END_OF_BLOCK

    $outstr .= "\n";
    $outstr .= "\n";
    return ($outstr);
}

####################
sub doUpdateSelect {
####################
    my %args = (
        @_,
    );
    my $outstr = "";
    my $message = '';
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $what = "";
    my $selectname = "";
    my $where = "";
    my $qardtypeid = $settings{qardtypeid};

    $args{dbh}->{LongReadLen} = 10000;
    $outstr .= "<input type=hidden name=isupdate value=1>\n";
    $outstr .= "<input type=hidden name=rid value=$settings{rid}>\n";
    $outstr .= "<input type=hidden name=aqaprid value=$settings{aqaprid}>\n";
    $outstr .= "<input type=hidden name=qardtypeid value=$settings{qardtypeid}>\n";
    $outstr .= "<table width=600 align=center>\n";
    tie my %updateselect, "Tie::IxHash";
    if ($settings{selection} eq "section") {
        if ($qardtypeid == 2) {
            $where = ($settings{aqaprid}) ? " and qardrevid = $settings{aqaprid}" : "";
        }
        else {
            $where = ($settings{rid}) ? " and qardrevid = $settings{rid}" : "";
        }
        %updateselect = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "id", nameColumn => $settings{selection} . "id || ' - ' || subid || ' - ' || title || ' ' || text", table => "qard$settings{selection}", orderBy => "tocid, sorter, sectionid, subid", where => "isdeleted = 'F' $where")};
        $what = 'enter_section';
        $selectname = "sid";
    }
    elsif ($settings{selection} eq "toc") {
        $where = ($settings{rid}) ? " and revisionid = $settings{rid}" : "";
        %updateselect = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "id", nameColumn => $settings{selection} . "id || ' - ' || title", table => "qard$settings{selection}", orderBy => "id", where => "isdeleted = 'F' $where")};
        $what = 'enter_toc';
        $selectname = "tid";
    }
    my $revwhere = "";
    if ($qardtypeid == 2) {
        $revwhere = ($settings{aqaprid}) ? "id = $settings{aqaprid}" : "";
    }
    else {
        $revwhere = ($settings{rid}) ? "id = $settings{rid}" : "";
    }

    my ($qardrevision) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "revid", table => "qard", where => $revwhere);
    $outstr .= "<tr><td>" . &nbspaces(5) . "<b>QARD: $qardrevision</b></td></tr>\n";
    $outstr .= "<tr><td align=center><select name=$selectname size=15 onDblClick=javascript:submitFormUpdate('qard','" . $what . "','',$qardtypeid)>";
    foreach $key (keys %updateselect) {
        $outstr .= "<option value=$key>". &getDisplayString ($updateselect{$key}, 100) . "\n";
    }
    
    $outstr .= "<option value=''>" . &nbspaces(100) . "\n";
    $outstr .= "</select></td></tr>\n";
    $outstr .= "<tr><td align=center><input type=submit name=updatesubmit value=Submit title=\"Click to update selected item\" onClick=javascript:submitFormUpdate('qard','" . $what . "','',$qardtypeid)></td></tr>\n";
    $outstr .= "\n";
    $outstr .= "</table>\n";
    return ($outstr);
}

#################
sub doQARDImage {
#################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $outstr = "Hello! :P";
    my ($mimetype, $image) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "qard", what => "imagecontenttype, document", where => "id = $settings{rid}");
    $outstr = "Content-type: $mimetype\n\n";
    $outstr .= $image;
    return ($outstr);
}

##################
sub doOtherImage {
##################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $outstr = "";
    my ($mimetype, $image) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "qardattachment", what => "imagecontenttype, document", where => "revisionid = $settings{rid}");
    $outstr = "Content-type: $mimetype\n\n";
    $outstr .= $image;
    return ($outstr);
}

######################
sub doUndeleteSelect {
######################
    my %args = (
        what => "qard",
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";

    $args{dbh}->{LongReadLen} = 10000;
    $outstr .= "<input type=hidden name=rid value=$settings{rid}>\n";
    $outstr .= "<input type=hidden name=tid value=$settings{tid}>\n";
    $outstr .= "<input type=hidden name=sid value=$settings{sid}>\n";
    $outstr .= "<input type=hidden name=rowid value=$settings{rowid}>\n";
    $outstr .= "<input type=hidden name=what value=$args{what}>\n";
    $outstr .= "<table width=650 border=1 cellspacing=0 cellpadding=3 align=center bgcolor=#ffffff>\n";
    $outstr .= "<tr bgcolor=#a0e0c0><td width=100><b>Undelete</b></td><td><b>" . uc ($args{what}) . "</b></td><tr>\n";

    my $stuff;
    if ($args{what} eq "section") {
        $stuff = "select 'QARD ' || q.revid || ', Section ' || s.sectionid || ' ' || s.text, s.id from $args{schema}.qardsection s, $args{schema}.qard q where s.isdeleted = 'T' and s.qardrevid = q.id order by s.qardrevid, s.sectionid";
    }
    elsif ($args{what} eq "table1a") {
        $stuff = "select 'QARD ' || q.revid || ', Table 1A Row ' || t.item || ' ' || t.subid, t.id from $args{schema}.qardtable1a t, $args{schema}.qard q where t.isdeleted = 'T' and t.revisionid = q.id order by t.revisionid, t.item, t.subid";
    }
    elsif ($args{what} eq "toc") {
        $stuff = "select tocid || ' ' || title, id from $args{schema}.qardtoc where isdeleted = 'T' order by title";
    }
    elsif ($args{what} eq "qard") {
        $stuff = "select revid, id from $args{schema}.qard where isdeleted = 'T' and qardtypeid = 1";
    }
    elsif ($args{what} eq "aqap") {
        $stuff = "select revid, id from $args{schema}.qard where isdeleted = 'T' and qardtypeid = 2";
    }
    elsif ($args{what} eq "qamp") {
        $stuff = "select revid, id from $args{schema}.qard where isdeleted = 'T' and qardtypeid = 3";
    }
    my $csr = $args{dbh} -> prepare ($stuff);
    $csr -> execute;
    while (my ($title, $id) = $csr -> fetchrow_array) {
        $outstr .= "<tr><td width=100><font size=2 face=$SYSFontFace><a href=javascript:submitUndelete('qard','undelete_process','$args{what}',$id)>Undelete</a></td><td><font size=2 face=$SYSFontFace>$title</td></tr>\n";
    }
    $csr -> finish;
    $outstr .= "</table>\n";

    return ($outstr);
}

###########################
sub doBrowseQARDReference {
###########################
    my %args = (
         qardtypeid => 1,
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";
    my $qardtypeid = ($settings{qardtypeid}) ? $settings{qardtypeid} : $args{qardtypeid};
    $outstr .= "<input type=hidden name=rid value=>\n";
    $outstr .= "<input type=hidden name=qardtypeid value=$qardtypeid>\n";
    my $theid = ($settings{rid}) ? $settings{rid} : 0;

    my ($thetype) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "description", table => "qardtype", where => "id = $qardtypeid");

    my $status = "Image-Only ";
    my $image2 = "";

    my $thewhere = "and iscurrent = 'I'";
    my $isupdate = ($args{isupdate}) ? 1 : 0;
    my $heading = "$status$thetype Revisions";

    if ($theid == 0) {
# print a table of all old QARD revs
        $outstr .= "<table width=650 align=center border=1 cellpadding=3 cellspacing=0 bgcolor=#ffffff>\n";
        $outstr .= "<tr bgcolor=#78b6ef><td colspan=5><font size=4><b>$heading</b></font></td></tr>\n";
        $outstr .= "<tr bgcolor=#eeeeee><td>\n";
        $outstr .= "<font face=helvetica size=2><b>Revision ID</b></font>\n";
        $outstr .= "</td><td>\n";
        $outstr .= "<font face=helvetica size=2><b>Approver</b></font>\n";
        $outstr .= "</td><td>\n";
        $outstr .= "<font face=helvetica size=2><b>Date Approved</b></font>\n";
        $outstr .= "</td><td>\n";
        $outstr .= "<font face=helvetica size=2><b>Date Effective</b></font>\n";
        $outstr .= "</td><td>\n";
        $outstr .= "<font face=helvetica size=2><b>Image</b></font>\n";
        $outstr .= "</td></tr>\n";
        $outstr .= "<tr><td colspan=5></td></tr>\n";
        my @qards = getQARDRevs (dbh => $args{dbh}, schema => $args{schema}, where => "isdeleted = 'F' and qardtypeid = $qardtypeid $thewhere", orderby => "revid desc");
        for (my $i = 1; $i <= $#qards; $i++) {
            my $id = $qards[$i]{id};
            my $revid;
            if ($isupdate) {
                if ($qardtypeid == 2) {
                    $revid = "<a href=javascript:submitForm4('qard','enter_aqap',$id)>$qards[$i]{revid}</a>";
                }
                elsif ($qardtypeid == 3) {
                    $revid = "<a href=javascript:submitForm4('qard','enter_qamp',$id)>$qards[$i]{revid}</a>";
                }
            }
            else {
                    $revid = "<a href=javascript:submitForm4('qard','browse_reference',$id)>$qards[$i]{revid}</a>";
            }
            my $dateapproved = ($qards[$i]{dateapproved}) ? $qards[$i]{dateapproved} : "&nbsp;";
            my ($approvedby) = ($qards[$i]{approvedby}) ? &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "qardapprover", what => "name", where => "id = $qards[$i]{approvedby}") : "&nbsp;";
            my $dateeffective = ($qards[$i]{dateeffective}) ? $qards[$i]{dateeffective} : "&nbsp;";
            my $image = ($qards[$i]{imageextension}) ? "<a href=javascript:displayQARDImage($id)>Image</a>" : "&nbsp;";
            
            if ($thetype eq "AQAP" || $qardtypeid == 2) {
                 $image2 = "<a href=javascript:displayOtherImage($id)>Matrix</a>";
            }

            $outstr .= "<tr><td>\n";
            $outstr .= "<font face=helvetica size=2>$revid</font>\n";
            $outstr .= "</td><td>\n";
            $outstr .= "<font face=helvetica size=2>$approvedby</font>\n";
            $outstr .= "</td><td>\n";
            $outstr .= "<font face=helvetica size=2>$dateapproved</font>\n";
            $outstr .= "</td><td>\n";
            $outstr .= "<font face=helvetica size=2>$dateeffective</font>\n";
            $outstr .= "</td><td>\n";
            $outstr .= "<font face=helvetica size=2>$image&nbsp;&nbsp;$image2</font>\n";
            $outstr .= "</td></tr>\n";
        }
        $outstr .= "</table>\n";
    }
    else {
# print info on the selected QARD
        my @qard = &getQARDRevs (dbh => $args{dbh}, schema => $args{schema}, where => "id = $theid");
        my ($iscurrent) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "description", table => "qardrevisiontype", where => "abbrev = '$qard[1]{iscurrent}'");
        ($thetype) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "description", table => "qardtype", where => "id = $qard[1]{qardtypeid}");
        $outstr .= "<table width=550 align=center border=1 cellpadding=3 cellspacing=0 bgcolor=#ffffff>\n";
        $outstr .= "<tr bgcolor=#999fcd><td colspan=2><font size=3 face=helvetica><b>$iscurrent $thetype Revision ID: $qard[1]{revid}</td></tr>\n";
        my ($approvedby) = ($qard[1]{approvedby}) ? &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "name", table => "qardapprover", where => "id = $qard[1]{approvedby}") : "N/A";
        $outstr .= "<tr><td width=150><font face=helvetica size=2><b>Approved By:</td><td><font face=helvetica size=2>$approvedby&nbsp;</td></tr>\n";
        my $dateapproved = ($qard[1]{dateapproved}) ? $qard[1]{dateapproved} : "N/A";
        $outstr .= "<tr><td><font face=helvetica size=2><b>Date Approved:</td><td><font face=helvetica size=2>$dateapproved</td></tr>\n";
        my $dateeffective = ($qard[1]{dateeffective}) ? $qard[1]{dateeffective} : "N/A";
        $outstr .= "<tr><td><font face=helvetica size=2><b>Date Effective:</td><td><font face=helvetica size=2>$dateeffective</td></tr>\n";
        my $status = ($qard[1]{status} eq "A") ? "Approved" : "Draft";
        $outstr .= "<tr><td><font face=helvetica size=2><b>Status:</td><td><font face=helvetica size=2>$status</td></tr>\n";
        $outstr .= "<tr><td><font face=helvetica size=2><b>Type:</td><td><font face=helvetica size=2>$iscurrent</td></tr>\n";
        my $image = ($qard[1]{imageextension}) ? "<a href=javascript:displayQARDImage($qard[1]{id}) title='Click for document image'>Image</a>" : "Not Available";
        if ($qard[1]{qardtypeid} == 2) {
             $image2 = "<a href=javascript:displayOtherImage($qard[1]{id})>Matrix</a>";
        }
        $outstr .= "<tr><td><font face=helvetica size=2><b>Image:</td><td><font face=helvetica size=2>$image&nbsp;&nbsp;$image2</td></tr>\n";
        $outstr .= "<tr><td colspan=2 bgcolor=#eeeeee height=5></td></tr>\n";
        my ($entby) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "firstname || ' ' || lastname", table => "users", where => "id = $qard[1]{enteredby}");
        $outstr .= "<tr><td><font face=helvetica size=2><b>Entered By:</td><td><font face=helvetica size=2>$entby</td></tr>\n";
        $outstr .= "<tr><td><font face=helvetica size=2><b>Date Entered:</td><td><font face=helvetica size=2>$qard[1]{dateentered}</td></tr>\n";
        my ($upby) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "firstname || ' ' || lastname", table => "users", where => "id = $qard[1]{updatedby}");
        $outstr .= "<tr><td><font face=helvetica size=2><b>Last Updated By:</td><td><font face=helvetica size=2>$upby</td></tr>\n";
        $outstr .= "<tr><td><font face=helvetica size=2><b>Date Last Updated:</td><td><font face=helvetica size=2>$qard[1]{lastupdated}</td></tr>\n";
        $outstr .= "</table>\n";
    }

    return ($outstr);
}

##################
sub doTableEntry {
##################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";
    my $item = "";
    my $nrcdoc = "";
    my $standard = "";
    my $position = "";
    my $justification = "";
    my $subid = "";
    my $isdeleted = "";
    my $isupdate = ($settings{isupdate}) ? 1 : 0;

    my ($qardrevision) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "qard", what => "revid", where => "id = $settings{rid}");
    ($item, $nrcdoc, $standard, $position, $justification, $subid, $isdeleted) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "qardtable1a", what => "item, nrcdescription, standarddescription, position, justification, subid, isdeleted", where => "revisionid = $settings{rid} and id = $settings{rowid}") if $settings{rowid}; 

    $outstr .= "<input type=hidden name=rid value=$settings{rid}>\n";
    $outstr .= "<input type=hidden name=rowid value=$settings{rowid}>\n";
    $outstr .= "<input type=hidden name=isupdate value=$settings{isupdate}>\n";

    $outstr .= "<table width=650 align=center border=0 cellpadding=3 cellspacing=0>\n";
    $outstr .= "<tr><td><b><li>QARD:&nbsp;&nbsp;</b>$qardrevision</td></tr>\n";
    $outstr .= "<tr><td><b><li>Item:&nbsp;&nbsp;</b><input type=text name=item size=10 maxlength=1 value=$item>&nbsp;&nbsp;<b>Item Sub-ID:</b>&nbsp;&nbsp;<input type=text name=subid size=10 maxlength=3 value=$subid></td></tr>\n";
    $outstr .= "<tr><td><b><li>US NRC Document:</b><br>\n";
    $outstr .= "<textarea name=nrcdescription rows=5 cols=75>$nrcdoc</textarea></td></tr>\n";
    $outstr .= "<tr><td><b><li>National/Industry Standard:</b><br>\n";
    $outstr .= "<textarea name=standarddescription rows=5 cols=75>$standard</textarea></td></tr>\n";
    $outstr .= "<tr><td><b><li>ORD Position:&nbsp;&nbsp;</b><br><textarea rows=5 cols=75 name=position>$position</textarea></td></tr>\n";
    $outstr .= "<tr><td><b><li>Justification:&nbsp;&nbsp;</b><br><textarea rows=5 cols=75 name=justification>$justification</textarea></td></tr>\n";
    my $checked = ($isdeleted eq "T") ? " checked" : "";
    $outstr .= "<tr><td colspan=4><li><b>Mark as deleted:</b>&nbsp;&nbsp;<input type=checkbox name=isdeleted value='T' $checked></td></tr>\n" if $isupdate;
    $outstr .= "<tr><td align=center><input type=button value=Submit onClick=javascript:validateStuff('enter_table_process')></td></tr>\n";
#    $outstr .= "<tr><td align=center><input type=submit value=Submit onClick=javascript:submitFormCGIResults('qard','enter_table_process')></td></tr>\n";
    $outstr .= "</table>\n";

    $outstr .= <<END_OF_BLOCK;
    <script language=javascript><!--
    function validateStuff(command) {
        var msg = "";
        msg += (isblank(document.$args{form}.item.value)) ? "You must enter the item ID.\\n" : "";
        msg += (isblank(document.$args{form}.subid.value)) ? "You must enter a number for the Sub-ID.\\n" : "";
        msg += (isblank(document.$args{form}.nrcdescription.value) && isblank(document.$args{form}.standarddescription.value)) ? "You must enter the relevant NRC document and/or National/Industry standard.\\n" : "";
        msg += (isblank(document.$args{form}.position.value)) ? "You must enter the ORD Position.\\n" : "";
        msg += (isblank(document.$args{form}.justification.value)) ? "You must enter the justification for the ORD Position.\\n" : "";

        if (msg != "") {
            alert (msg);
        }
        else {
            submitFormCGIResults('$args{form}','enter_table_process');
        }
    }
    //--></script>
END_OF_BLOCK

    return ($outstr);
}

#########################
sub doTableUpdateSelect {
#########################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";

    return ($outstr);
}

#################
sub doAQAPEntry {
#################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = &doRevisionEntry (dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, userID => $args{userID}, form => $args{form}, settings => \%settings, qardtypeid => 2);

    return ($outstr);
}

##################
sub doBrowseAQAP {
##################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = &doBrowseQARDReference (dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, userID => $args{userID}, form => $args{form}, settings => \%settings, qardtypeid => 2, isupdate => $args{isupdate});

    return ($outstr);
}

################
sub doAddThing {
################
    my %args = (
         what => '',
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $what = $args{what};
    my $outstr = "";
    my $action = "'add_" . $what . "_process'";

    $outstr .= "<table width=350 align=center border=0 cellpadding=3 cellspacing=0>\n";
    $outstr .= "<input type=hidden name=approver value=$settings{approver}>\n" if $settings{approver};
    $outstr .= "<tr><td><b><li>New $what:</b>&nbsp;&nbsp;<input type=text name=approvername value=''></td></tr>\n";
    $outstr .= "<tr><td align=center><input type=submit value=Submit onClick=javascript:submitFormCGIResults('qard',$action)></td></tr>\n";
    $outstr .= "<tr><td><hr width=200></td></tr>\n";
    $outstr .= "<tr align=center><td><b>Current " . $what . "s:</b><br><select size=10>\n";
    my %things = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "name", nameColumn => "id", table => "qard$what")};
    foreach $key (sort keys %things) {
        $outstr .= "<option value=$things{$key}>$key\n";
    }
    $outstr .= "</select></td></tr>\n";
    $outstr .= "</table>\n";

    return ($outstr);
}

#########################
sub doUpdateSelectTable {
#########################
    my %args = (
         width => 775,
         a => 1,
         sourcelink => 0,
         revisionid => 0,
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";
    my $isupdate = ($settings{isupdate}) ? 1 : 0;
    my $revisionid = ($args{revisionid}) ? $args{revisionid} : $settings{rid};

    $outstr .= "<input type=hidden name=isupdate value=$isupdate>\n";
    $outstr .= "<input type=hidden name=rid value=$revisionid>\n";
    $outstr .= "<input type=hidden name=rowid value=$settings{rowid}>\n";
    $outstr .= "<table width=$args{width} align=center border=1 bgcolor=#ffffff cellspacing=0 cellpadding=2>\n";

    my ($qardrevision) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "revid", table => "qard", where => "id = $revisionid");
    my $t1atitle = ($args{a}) ? "QARD $qardrevision - Table 1A - Regulatory/Commitment Document Positions with Justification" : "QARD $qardrevision - Table 1- Regulatory/Commitment Document Positions";
    $outstr .= "<tr align=center bgcolor=#abcdef><td colspan=5><b>$t1atitle</b></td></tr>\n";

    $outstr .= "<tr valign=top bgcolor=#f0f0f0><td width=40><font size=-1><b>Item</td><td><font size=-1><b>US NRC Document</td><td><font size=-1><b>National/Industry Standard</td><td><font size=-1><b>ORD Position</td>\n";
    $outstr .= "<td><font size=-1><b>Justification</td>\n" if ($args{a});
    $outstr .= "</tr>\n";
    
    my $previtem = "";
    my @table = &getTable (dbh => $args{dbh}, schema => $args{schema}, where => "revisionid = $revisionid", orderby => "item, subid, id");
    for (my $i = 1; $i <= $#table; $i++) {
        my $id = $table[$i]{id};
        my $item = $table[$i]{item};
        my $subid = ($table[$i]{subid}) ? " - $table[$i]{subid}" : " - 0";
        my $itemid = "$table[$i]{item}$subid";
        if (!($isupdate)) {
            $itemid = ($args{sourcelink}) ? "<a href=javascript:popSource('qard',$id,'pop_table')>$table[$i]{item}$subid</a>" : "$table[$i]{item}$subid"; 
        }
        else {
            $itemid = "<a href=javascript:submitFormT('qard','enter_table',$id)>$table[$i]{item}$subid</a>";
        }
        my $nrcdoc = ($table[$i]{nrcdescription} && ($item ne $previtem)) ? $table[$i]{nrcdescription} : "&nbsp;";
        my $standard = ($table[$i]{standarddescription} && ($item ne $previtem)) ? $table[$i]{standarddescription} : "&nbsp;";
        my $position = ($table[$i]{position}) ? $table[$i]{position} : "&nbsp;";
        my $justification = ($table[$i]{justification}) ? $table[$i]{justification} : "&nbsp;";
        $outstr .= "<tr valign=top><td><font size=2 face=Helvetica>$itemid</td><td width=150><font size=2 face=Helvetica>$nrcdoc</td><td width=150><font size=2 face=Helvetica>$standard</td><td><font size=2 face=Helvetica>$position</td>\n";
        $outstr .= "<td width=150><font size=2 face=Helvetica>$justification</td>\n" if ($args{a});
        $outstr .= "</tr>\n";
#        $outstr .= "<tr valign=top><td><a href=javascript:submitFormT('qard','enter_table',$id)>$item</a></td><td>$nrcdoc</td><td>$standard</td><td>$position</td><td>$justification</td></tr>\n";
         $previtem = $item;
    }
    $outstr .= "</table>\n";
    return ($outstr);
}

#################
sub doQAMPEntry {
#################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = &doRevisionEntry (dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, userID => $args{userID}, form => $args{form}, settings => \%settings, qardtypeid => 3);

    return ($outstr);
}

##################
sub doBrowseQAMP {
##################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = &doBrowseQARDReference (dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, userID => $args{userID}, form => $args{form}, settings => \%settings, qardtypeid => 3, isupdate => $args{isupdate});

    return ($outstr);
}

########################
sub doAQAPSectionEntry {
########################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = &doSectionEntry (dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, userID => $args{userID}, form => $args{form}, settings => \%settings, qardtypeid => 2);

    return ($outstr);

}

#######################
sub doMatrixEntryStoQ {
#######################
    my %args = (
        qardtypeid => 1,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";

    my $matrixid = $settings{matrixid};
    my $sourceid = $settings{sourceid};
    my $revisionid = $settings{revisionid};
    my $qardsectionid =  $settings{rid};
    my $isupdate = 1;

#print STDERR "$qardsectionid - $matrixid - $sourceid\n";

    $outstr .= "<input type=hidden name=sourceid value=$sourceid>\n";
    $outstr .= "<input type=hidden name=revisionid value=$revisionid>\n";
    $outstr .= "<input type=hidden name=isupdate value=$isupdate>\n";
    $outstr .= "<input type=hidden name=rid value=$qardsectionid>\n";
    $outstr .= "<input type=hidden name=qardtypeid value=$settings{qardtypeid}>\n";
    $outstr .= "<input type=hidden name=matrixid value=$matrixid>\n";

    my $sectionid = "";
    my $title = "";
    my $text = "";
    my $subid = 0;
    my $isdeleted = "F";
    my $qardrevid = "";
    my $qardtype = 0;
    my $sourcedesignation = "";
    my $matrixtitle = "";

    ($sectionid, $title, $text, $subid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "sectionid, title, text, subid", table => "qardsection", where => "id = $qardsectionid");
    ($qardrevid, $qardtype) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "q.revid, t.description", table => "qard q, qardtype t", where => "q.id = $revisionid and q.qardtypeid = t.id");
    ($sourcedesignation) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "designation", table => "source", where => "id = $sourceid");  
    ($matrixtitle) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "title", table => "matrix", where => "id = $matrixid");  

    $outstr .= "<table width=550 align=center border=1 cellspacing=0 cellpadding=3 bgcolor=#ffffff>\n";
    $outstr .= "<tr bgcolor=#78b6ef><td colspan=2>\n";
    $outstr .= "<font face=helvetica size=3><b>$qardtype - $qardrevid\n";
    $outstr .= "</td></tr>\n";
    $outstr .= "<tr valign=top bgcolor=#cccccc><td>\n";
    $outstr .= "<font face=helvetica size=2><b>Section&nbsp;ID\n";
    $outstr .= "</td><td>\n";
    $outstr .= "<font face=helvetica size=2><b>Text\n";
    $outstr .= "</td></tr>\n";
    $outstr .= "<tr valign=top><td></td></tr>\n";
    $outstr .= "<tr valign=top><td>\n";
    my $thesectionid = $subid ? "$sectionid - $subid" : "$sectionid - 0";
    $outstr .= "<font face=helvetica size=2>$thesectionid\n";
    $outstr .= "</td><td>\n";
    my $thetext = $title ? "<b>$title</b><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$text" : $text;
    $outstr .= "<font face=helvetica size=2>$thetext\n";
    $outstr .= "</td></tr>\n";
    $outstr .= "</table>\n";


    $outstr .= "<table width=650 align=center cellpadding=5 border=0>\n";

    $outstr .= "<tr><td colspan=2><br><li><b>Compliance Matrix:&nbsp;&nbsp;$matrixtitle</b></td></tr>\n";

    my $where = ($sourceid) ? " and sourceid = $sourceid" : "";

    tie my %allsections, "Tie::IxHash";
    %allsections = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "id", nameColumn => "sectionid || ' - ' || requirementid", table => "sourcerequirement", where => "isdeleted = 'F' $where", orderBy => "sorter, sectionid, requirementid")};
    tie my %selectedsections, "Tie::IxHash";
    %selectedsections = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "s.id", nameColumn => "s.sectionid || ' - ' || s.requirementid", table => "sourcerequirement s, $args{schema}.qardmatrix m", orderBy => "s.sorter, s.sectionid, s.requirementid", where => "m.matrixid = $matrixid and m.qardsectionid = $qardsectionid and m.sourcerequirementid = s.id and s.isdeleted = 'F'")};

    $outstr .= "<tr><td colspan=2><li><b>Assign Criteria from $sourcedesignation:</b><center>\n";
    $outstr .= &build_dual_select ('subsections', "$args{form}", \%allsections, \%selectedsections, "Available Source Criteria", "Selected Source Criteria");
    $outstr .= "</td></tr>\n";


    $outstr .= "<tr><td colspan=2><center><br><input type=button name=checkbutton value=\"Check Work\" title=\"Click to check work\" onClick=checkWork()>&nbsp;&nbsp;\n";
    $outstr .= "<input type=button name=submitbutton value=\"Submit\" title=\"Click to submit source document\" onClick=validateStuff('enter_matrix_process')></center><br></td></tr>\n";

    $outstr .= "</table>\n";
#=pod
    $outstr .= <<END_OF_BLOCK;

    <script language=javascript><!--
    function validateStuff(command) {
        var msg = "";
//        msg += (document.$args{form}.sourceid.value == "") ? "You must select the source document of this requirement.\\n" : "";
//        if (document.$args{form}.qardtypeid.value == 1) {
//            msg += (isblank(document.$args{form}.qrsectionid.value)) ? "You must enter the section ID.\\n" : "";
//            msg += (isNaN(document.$args{form}.requirementid.value) == true || document.$args{form}.requirementid.value < 0) ? document.$args{form}.requirementid.value + " is not a valid requirement ID.\\n" : "";
//            msg += (isblank(document.$args{form}.qrtext.value)) ? "You must enter the text of the section/requirement.\\n" : "";
//        }
        if (msg != "") {
            alert (msg);
        }
        else {
            selectemall (document.$args{form}.subsections);
            submitFormCGIResults('$args{form}', command);
        }
    }
    function checkWork () {
        var msg = "Source ID: " + document.$args{form}.sourceid.value + "\\n";
        msg += "Section ID: " + document.$args{form}.qrsectionid.value + "\\n";
        msg += "Requirement ID: " + document.$args{form}.requirementid.value + "\\n";
        msg += "Section Text: " + document.$args{form}.qrtext.value + "\\n";
        msg += "Notes, ORD Position: " + document.$args{form}.ocrwmposition.value + "\\n";
        msg += "Justification for ORD Position:" + document.$args{form}.ocrwmjustification.value + "\\n";
        alert (msg);
    }
    //--></script>
END_OF_BLOCK

    $outstr .= "\n";


#=cut

    return ($outstr);
}

########################
sub doMatrixSelectStoQ {
########################
    my %args = (
         @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";

    $outstr .= &doSectionBrowse (dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, userID => $args{userID}, form => $args{form}, settings => \%settings, matrix => 1);

    return ($outstr);
}


###############
1; #return true
