# UI Report functions
#
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/prp/perl/RCS/UIReports.pm,v $
# $Revision: 1.35 $
# $Date: 2008/02/19 23:37:12 $
# $Author: higashis $
# $Locker: higashis $
#
# $Log: UIReports.pm,v $
# Revision 1.35  2008/02/19 23:37:12  higashis
# made changes for CREQ00086 - sh.
#
# Revision 1.34  2006/06/19 22:45:49  naydenoa
# CREQ00080 fulfillment - optional date on PDF reports (QARD & Table 1A).
#
# Revision 1.33  2006/06/15 17:24:54  naydenoa
# Customer-requested temporary suspension of date print in StoQ PDF report.
# Will reset upon completion of current customer task.
#
# Revision 1.32  2006/06/15 00:34:44  naydenoa
# Correction from CREQ - no update display in reports.
#
# Revision 1.31  2006/06/13 23:41:12  naydenoa
# CREQ00079 - tweaked date retrieval and coloring for matrix approval (HTML report display).
#
# Revision 1.30  2006/01/10 23:46:04  naydenoa
# CREQ00073 - take out zeroes.
# ,
#
# Revision 1.29  2006/01/06 19:23:53  naydenoa
# Added sort condition for qard on html and pdf NRD Format reports
# CREQ00071
#
# Revision 1.28  2005/11/14 20:43:19  naydenoa
# CREQ00068 - added display of N/A in absence of related reqs/ctriteria
#
# Revision 1.27  2005/10/06 16:20:27  naydenoa
# CREQ00065 - 0th req/crit/t1a display; update headers to sect id - sub id
#
# Revision 1.26  2005/09/28 23:17:38  naydenoa
# Phase 3 implementation
# Added AQAP reports (PDF, HTML, to AQAP, from AQAP)
#
# Revision 1.25  2005/07/14 16:20:17  naydenoa
# CREQ00060 - fixed bug in HTML matrix filtering (QARD to Source)
#
# Revision 1.24  2005/03/23 00:09:42  naydenoa
# Tweaked omission option text on main menu - per L. Wagner - CREQ00044
#
# Revision 1.23  2005/03/22 18:57:27  naydenoa
# Replaced all occurrences of YMP with ORD - CREQ00043
# Updated table 1a item identification in compliance matrices - CREQ00044-1
# Added optional text display of table 1a position in PDF reports - 44-2
#
# Revision 1.22  2005/03/15 21:53:50  naydenoa
# Suspended some warning to avoid littering the error log
#
# Revision 1.21  2005/03/15 21:37:14  naydenoa
# Updated matrix display to take into account new QARD table 1a assignment
# paradigm - CREQ00042
#
# Revision 1.20  2005/02/17 16:39:51  naydenoa
# CREQ00039, CREQ00040 - table 1a linked to soure to QARD matrix,
# implementation of QARD to source matrix display. PDF and HTML.
#
# Revision 1.19  2005/01/10 17:18:26  naydenoa
# Tweaked column widths for default PDF format - CREQ00032
#
# Revision 1.18  2004/12/16 18:42:01  naydenoa
# Minor tweak - filtered out NRC docs and standards when same item listed
#
# Revision 1.17  2004/12/16 17:07:25  naydenoa
# Added Table 1a to main reports screen, added PDF report for Table 1a
# (phase 2 development, CREQ00024)
#
# Revision 1.16  2004/10/05 22:05:01  naydenoa
# CREQ00030 - bug on QARD retrieval in HTML report
#
# Revision 1.15  2004/10/05 17:27:50  naydenoa
# Fix filtering bug in PDF reports associated with CREQ00008
#
# Revision 1.14  2004/09/15 23:38:24  naydenoa
# Update QARD rev sort - CREQ00005
#
# Revision 1.13  2004/09/15 23:23:44  naydenoa
# Update to CREQ00005 - default to most current QARD version on main menu;
# default to selected QARD text and YMP position & justification
#
# Revision 1.12  2004/09/15 15:20:37  naydenoa
# Updated PDF report retrieval to include matrix id - CREQ00022
#
# Revision 1.11  2004/09/13 20:34:15  naydenoa
# Minor formatting tweak in main menu
#
# Revision 1.10  2004/09/13 20:28:28  naydenoa
# CREQ00005 - reports filtering - fulfilled - updated main menu and PDF display
# CREQ00020 - partial fulfillment - updated main menu, PDF, and HTML displays
#
# Revision 1.9  2004/09/10 18:38:19  naydenoa
# Added QARD text to HTML report per M. Ulschafer's request - CREQ00018
#
# Revision 1.8  2004/08/12 21:14:50  naydenoa
# Added OCRWM position and OCRWM justification columns to html report - CR00016
#
# Revision 1.7  2004/08/11 15:02:10  naydenoa
# Updated requirements filtering - CREQ00015
#
# Revision 1.6  2004/07/23 19:45:35  naydenoa
# Updated requirements sort - CREQ00007
#
# Revision 1.5  2004/07/13 15:36:26  naydenoa
# Fulfillment of CR00013
#
# Revision 1.4  2004/07/07 21:11:06  naydenoa
# Added sort order to sql stmt for QARD data retrieval in doDisplayPDFReport
#
# Revision 1.3  2004/06/18 18:07:20  naydenoa
# Added OCRWM position and justification display to PDF report - CR00004
#
# Revision 1.2  2004/06/16 21:20:19  naydenoa
# Enabled reports for Phase 1, cycle 2
#
# Revision 1.1  2004/04/22 20:40:13  naydenoa
# Initial revision
#
#

package UIReports;

# get all required libraries and modules
#use pdflib_pl 4.0;
use pdflib_pl;
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBUtilities qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Text_Menus;
use Tie::IxHash;
use Tables;
use PDF;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getInitialValues        &doHeader               &doFooter
      &getTitle                &doDisplayHTMLReport    &doDisplayPDFReport
      &doRealMainMenu          &doDisplayPDFTable1A    &doDisplayQtoSHTMLReport
      &doDisplayQtoSPDFReport  &doMainQARDReport       &doMainAQAPReport
      &doDisplayPDFAQAP        &doDisplayHTMLAQAP
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues        &doHeader               &doFooter
      &getTitle                &doDisplayHTMLReport    &doDisplayPDFReport
      &doRealMainMenu          &doDisplayPDFTable1A    &doDisplayQtoSHTMLReport
      &doDisplayQtoSPDFReport  &doMainQARDReport       &doMainAQAPReport
      &doDisplayPDFAQAP        &doDisplayHTMLAQAP
    )]
);

my $mycgi = new CGI;

##############
sub getTitle {
##############
   my %args = (
      @_,
   );
   my $title = "Reports";
   if ($args{command} eq "?") {
      $title = "Reports";
   } elsif ($args{command} eq "?") {
      $title = "Reports";
   }
   return ($title);
}

######################
sub getInitialValues { # routine to get initial CGI values and return in a hash
######################
    my %args = (
        dbh => "",
        @_,
    );
    
    my %valueHash = (
       &getStandardValues, (
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "",
       id => (defined ($mycgi -> param ("id"))) ? $mycgi -> param ("id") : "",
       rid => (defined ($mycgi -> param ("rid"))) ? $mycgi -> param ("rid") : 0,
       matrixid => (defined ($mycgi -> param ("matrixid"))) ? $mycgi -> param ("matrixid") : "",
       approvalmatrixid => (defined ($mycgi -> param ("approvalmatrixid"))) ? $mycgi -> param ("approvalmatrixid") : "",
       revisionid => (defined ($mycgi -> param ("revisionid"))) ? $mycgi -> param ("revisionid") : 0,
       matrixtitle => (defined ($mycgi -> param ("matrixtitle"))) ? $mycgi -> param ("matrixtitle") : "",
       ocrwm => (defined ($mycgi -> param ("ocrwm"))) ? $mycgi -> param ("ocrwm") : "F",
       qard => (defined ($mycgi -> param ("qard"))) ? $mycgi -> param ("qard") : "F",
       blank => (defined ($mycgi -> param ("blank"))) ? $mycgi -> param ("blank") : "F",
       truncate => (defined ($mycgi -> param ("truncate"))) ? $mycgi -> param ("truncate") : "F",
       noposition => (defined ($mycgi -> param ("noposition"))) ? $mycgi -> param ("noposition") : "F",
       aqaprid => (defined ($mycgi -> param ("aqaprid"))) ? $mycgi -> param ("aqaprid") : 0,
       thedate => (defined ($mycgi -> param ("thedate"))) ? $mycgi -> param ("thedate") : "F",
    ));
    $valueHash{title} = &getTitle(command => $valueHash{command});
    
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
    function doBrowse(script) {
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
    function submitFormT(script, command, rid) {
        document.$form.command.value = command;
        document.$form.rid.value = rid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function submitReport(script, command, matrixid) {
        document.$form.command.value = command;
        document.$form.matrixid.value = matrixid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function submitRevision() {
        document.$form.command.value = 'main_qard';
        document.$form.action = '$path' + 'reports.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }
    function submitReportNewWindow(script, command, matrixid) {
        var myDate = new Date();
        var winName = myDate.getTime();
        document.$form.command.value = command;
        document.$form.matrixid.value = matrixid;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = winName;
        var newwin = window.open("",winName);
        newwin.creator = self;
        document.$form.submit();
     //  newwin.focus();
    }

END_OF_BLOCK

    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'F', includeJSWidgets => 'F');
    
    $output .= "<input type=hidden name=type value=0>\n";
    $output .= "<input type=hidden name=projectID value=0>\n";
    #$output .= "<input type=hidden name=server value=$Server>\n";
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

####################
sub doRealMainMenu {
####################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";
    $outstr .= "<input type=hidden name=isupdate value=0>\n";
    $outstr .= "<input type=hidden name=matrixid value=>\n";
    $outstr .= "<input type=hidden name=matrixtitle value=\"\">\n";

    $outstr .= "<br><table width=725 align=center border=3 bordercolor=#aaaaaa cellpadding=10 cellspacing=5>\n";
    $outstr .= "<tr><td colspan=2 align=center><font face=helvetica size=6>Compliance Matrices</font></td></tr>\n";
    $outstr .= "<tr valign=top><td width=50%>\n";
    $outstr .= "<table>\n";
    $outstr .= "<tr><td><font face=helvetica size=4><b>QARD</b></td></tr>\n";

    my ($latestqard) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "qard", what => "max(id)", where => "iscurrent = 'L' and isdeleted = 'F' and qardtypeid = 1");
    my $theqardid = $settings{rid};
    my ($tmpoutstr) = &makeQARDDropdown (dbh => $args{dbh}, schema => $args{schema}, where => "qardtypeid = 1 and isdeleted = 'F' and iscurrent = 'L'", orderby => "revid desc", qardtype => "", rid => $theqardid, idlist => 0, blankentry => 0);
    $outstr .= $tmpoutstr;

    my $whichqard = "All";
    my $selected = "";
    my $thesection = "";

    $outstr .= "<tr><td><input type=submit name=submitrevision value=Submit onClick=submitRevision()></td></tr></table>\n";
    $outstr .= "</td>\n";

#----------- end QARD -----------#

#------------- AQAP -------------#

    $outstr .= "<td>\n";
    $outstr .= "<table>\n";
    $outstr .= "<tr><td><font face=helvetica><font size=4><b>AQAP</b></font></td></tr>\n";

    ($tmpoutstr) = &makeQARDDropdown (dbh => $args{dbh}, schema => $args{schema}, where => "qardtypeid = 2 and isdeleted = 'F' and iscurrent = 'L'", orderby => "revid desc", qardtype => "aqap", blankentry => 0);
    $outstr .= $tmpoutstr;

    $outstr .= "<tr><td><font size=2><a href=javascript:submitForm('reports','main_aqap')>HTML</a>&nbsp;&nbsp;\n";
    $outstr .= "<a href=javascript:submitReportNewWindow('reports','pdf_report_aqap',0)>PDF</a></font></font>\n";
    $outstr .= "</td></tr>\n";
    $outstr .= "</table>\n";
    $outstr .= "</td></tr>\n";
    $outstr .= "</table>\n";

    return ($outstr);
}

######################
sub doMainQARDReport {
######################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $key;
    my $outstr = "";
    my $theqardid = $settings{rid};

    $outstr .= "<input type=hidden name=isupdate value=0>\n";
    $outstr .= "<input type=hidden name=matrixid value=>\n";
    $outstr .= "<input type=hidden name=matrixtitle value=\"\">\n";

    $outstr .= "<table width=650 align=center border=0>\n";
    $outstr .= "<tr><td colspan=3><font size=2 face=helvetica><b>Select&nbsp;QARD&nbsp;Revision:</b>&nbsp;&nbsp;\n";
     my ($tmpoutstr) = &makeQARDDropdown (dbh => $args{dbh}, schema => $args{schema}, where => "qardtypeid = 1 and isdeleted = 'F' and iscurrent = 'L'", orderby => "revid desc", rid => $theqardid, idlist => 0, blankentry => 0, tablerow => 0);
    my ($whichqard) = ($theqardid) ? &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "revid", table => "qard", where => "id = $theqardid") : ("All");
    $outstr .= $tmpoutstr;

    $outstr .= "<input type=submit name=submitrevision value=Submit onClick=submitRevision()></td></tr>\n";
    $outstr .= "<tr><td valign=top><font size=2 face=helvetica><b>Select PDF Report Columns:</b><br><font size=2>(then click on PDF link to display)</font></td>\n";
    $outstr .= "<td><font size=2 face=helvetica>\n";
    $outstr .= "<input type=checkbox name=ocrwm value=T checked>OCRWM&nbsp;Position&nbsp;and&nbsp;Justification&nbsp;&nbsp;(<input type=checkbox name=noposition value=T>Omit&nbsp;OCRWM&nbsp;Position&nbsp;Text)<br>\n";
    $outstr .= "<input type=checkbox name=qard value=T checked>QARD Section Text&nbsp;&nbsp;(<input type=checkbox name=truncate value=T>Truncate QARD and Source Text)<br>\n";
    $outstr .= "<input type=checkbox name=blank value=T>Add Blank Column for Comments<br>\n";
    if (&doesUserHavePriv (dbh => $args{dbh}, schema => $args{schema}, userid => $settings{userid}, privList => [-1, 10, 6])) {
        $outstr .= "<input type=checkbox name=thedate value=T checked>Include Matrix Generation Date\n";
    }
    $outstr .= "</td></tr>\n";
    $outstr .= "</table>\n";

    $outstr .= "<table width=650 cellpadding=4 cellspacing=0 align=center bgcolor=#ffffff border=1>\n";
    $outstr .= "<tr bgcolor=#789aff><td colspan=3 height=20><font face=helvetica><b>QARD Compliance Matrices - $whichqard (xxxx total)</font></td>\n";
    $outstr .= "</tr>\n";
    my $mowhere = "";

    $mowhere = " and qardid = $theqardid";

    tie my %matrices, "Tie::IxHash";
    %matrices = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, table => "matrix m, $args{schema}.source s", idColumn => "m.id", nameColumn => "m.title", where => "m.isdeleted = 'F' and s.id = m.sourceid $mowhere", orderBy => "title")}; #and s.typeid in (1, 2, 3)
    my $count = 0;
    foreach $key (keys %matrices) {
        $outstr .= "<tr bgcolor=#dddddd><td align=center><font face=helvetica size=2><b>Matrix</td><td align=center width=75><font face=helvetica size=2><b>Source to QARD</td><td align=center width=75><font face=helvetica size=2><b>QARD to Source<br><a href=javascript:submitReportNewWindow('reports','pdf_report_qtos',0); title=\"Click for full PDF traceability between QARD and all source documents\">PDF</a>&nbsp;&nbsp;<a href=javascript:submitReport('reports','html_report_qtos',0); title=\"Click for full HTML traceability between QARD and all source documents - section ID's ONLY!\") >HTML</a></td></tr>\n" if ($count == 0);        
        $count++;
        $outstr .= "<tr><td><font face=helvetica size=2>$matrices{$key}</td>\n";
        $outstr .= "<td align=center><font face=helvetica size=2><! this is where the javascript call goes with the key (id)><a href=javascript:submitReportNewWindow('reports','pdf_report',$key);>PDF</a>&nbsp;&nbsp;<a href=javascript:submitReport('reports','html_report',$key);>HTML</a></td>\n";
        $outstr .= "<td align=center><font face=helvetica size=2><a href=javascript:submitReportNewWindow('reports','pdf_report_qtos',$key);>PDF</a>&nbsp;&nbsp;<a href=javascript:submitReport('reports','html_report_qtos',$key);>HTML</a></td></tr>\n";
    }
    $outstr .= "<tr bgcolor=#dddddd><td align=center colspan=2><font face=helvetica size=2><b>There are no linked matrices for this QARD revision.</td></tr>\n" if ($count == 0);        
    $outstr .= "</table>\n";
    $outstr =~ s/xxxx/$count/g;

    my ($tableexists) = ($theqardid) ? &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "count (*)", table => "qardtable1a", where => "revisionid = $theqardid") : 0; 
    $outstr .= "<br><table align=center border=1 bgcolor=#ffffff width=650 cellspacing=0 cellpadding=4>";
    $outstr .= "<tr><td width=553><font face=helvetica size=2>$whichqard Table 1A</td><td align=center><font face=helvetica size=2><a href=javascript:submitReportNewWindow('reports','pdf_table',$theqardid)>PDF</a>&nbsp;&nbsp;<a href=javascript:submitFormT('qard','update_select_table',$theqardid)>HTML</td></tr>" if (($settings{rid} || ($settings{command} ne "sth")) && $tableexists);
    $outstr .= "</table>";

    return ($outstr);
}

#########################
sub doDisplayHTMLReport {
#########################
    my %args = (
        matrixid => 0,
        qtos => 0,
        approval => 0,
        dateapproved => '19550101',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    $args{dbh}->{LongTruncOk} = 0;
    $args{dbh}->{LongReadLen} = 10000;

    my $outstr = "";
    my $key;
    my $matrixid = ($settings{matrixid}) ? $settings{matrixid} : $args{matrixid};
    my $revisionid = $settings{rid};

    my $tablewidth = ($args{qtos}) ? 800 : 1000; 
    $tablewidth = 600 if (!$settings{matrixid} && $settings{command} eq "html_report_qtos");
    $tablewidth = 800 if ($settings{command} eq "approve_matrix");
    my ($matrixtitle, $sourcedocid, $qardrevid, $sourcedocdesignation, $sourcedoctitle) = ("", "", "", "", "");
    my $textwidth = 300;
    if ($matrixid) {
        ($matrixtitle, $sourcedocid, $qardrevid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "title, sourceid, qardid", where => "id = $matrixid", table => "matrix");
        ($sourcedocdesignation, $sourcedoctitle) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "designation, title", where => "id = $sourcedocid", table => "source");
        $outstr .= "<center><font face=helvetica><b>$matrixtitle</b></font></center><br>\n";
    }
    else {
        my ($rev) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, table => "qard", what => "revid", where => "id = $revisionid");
        $outstr .= "<center><font face=helvetica><b>QARD to Source Compliance Matrix<br>$rev</b></font></center><br>\n";
    }
    $outstr .= "<table width=$tablewidth align=center cellpadding=2 cellspacing=0 border=1 bgcolor=#ffffff>";
    my ($sid, $sourcesectionid, $sectiontext, $textcolor, $qardsectionid, $qardtext, $sourcetypeid, $sourcereqid, $ocrwmposition, $ocrwmjustification, $table1aid, $designation);

    if ($args{qtos}) {
        my (@qardsections) = &getSections (dbh => $args{dbh}, schema => $args{schema}, where => "qardrevid = $revisionid and isdeleted = 'F'", orderby => "tocid, sorter, sectionid, subid");
        $outstr .= "<tr bgcolor=#dddddd><td align=center><font face=helvetica size=2><b>QARD Section ID - Sub ID</td>\n";
        $outstr .= "<td align=center><font face=helvetica size=2><b>QARD Section Text</td>\n" if $settings{matrixid};
        $outstr .= "<td align=center><font face=helvetica size=2><b>Source Criteria</td></tr>\n";
        for (my $i = 1; $i <= $#qardsections; $i++) {
            my ($qsid, $qsubid, $qtitle, $sreqid);
            $qsid = $qardsections[$i]{id};
            $qardsectionid = ($qardsections[$i]{subid}) ? "$qardsections[$i]{sectionid} - $qardsections[$i]{subid}" : "$qardsections[$i]{sectionid}";# - 0";
            $qardtext = ($qardsections[$i]{title}) ? "<b>$qardsections[$i]{title}</b><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$qardsections[$i]{text}" : $qardsections[$i]{text};
            $outstr .= "<tr valign=top><td width=120 align=center><font size=2>$qardsectionid</td>\n";
            $outstr .= "<td width=$textwidth><font size=2>$qardtext</td>\n" if $settings{matrixid};
            $outstr .= "<td><font size=2>\n";
        
            my $requirements;
            if ($settings{matrixid}) {
                $requirements = $args{dbh} -> prepare ("select NULL, r.id, r.sectionid, r.requirementid, r.text, r.ocrwmposition, r.ocrwmjustification from $args{schema}.qardmatrix m, $args{schema}.sourcerequirement r where m.matrixid = $settings{matrixid} and m.qardsectionid = $qsid and m.sourcerequirementid = r.id order by r.sorter, r.sectionid, r.requirementid");
            }
            else {
                $requirements = $args{dbh} -> prepare ("select s.designation, r.id, r.sectionid, r.requirementid, r.text, r.ocrwmposition, r.ocrwmjustification from $args{schema}.qardmatrix m, $args{schema}.sourcerequirement r, $args{schema}.source s where m.qardsectionid = $qsid and m.sourcerequirementid = r.id and r.sourceid = s.id order by s. designation, r.sorter, r.sectionid, r.requirementid");
            }
            $requirements -> execute;
            my $thereqid = "";
            while (($designation, $sid, $sourcesectionid, $sreqid, $sectiontext, $ocrwmposition, $ocrwmjustification) = $requirements -> fetchrow_array) {
                $thereqid = ($sreqid) ? "$sourcesectionid - $sreqid" : "$sourcesectionid";# - 0";
                $thereqid = "$designation: $thereqid" if (!$settings{matrixid});
                $outstr .= "<b>$thereqid</b>&nbsp;&nbsp;\n";
                $outstr .= "<br>\n" if (!$settings{matrixid});
                $outstr .= "$sectiontext<br>\n" if $settings{matrixid};
            }
            $requirements -> finish;
            $outstr .= "N/A" if ($thereqid eq "");#"&nbsp;" if ($thereqid eq "");
            $outstr .= "</td></tr>\n";
        }
    }
    else {
        my (@sourcesections) = &getSourceRequirements (dbh => $args{dbh}, schema => $args{schema}, where => "sourceid = $sourcedocid and isdeleted = 'F'", orderby => "sorter desc, sectionid, requirementid");
 		
        $outstr .= "<tr bgcolor=#dddddd><td align=center><font face=helvetica size=2><b>$sourcedocdesignation Section ID - Sub ID</td>\n";
        $outstr .= "<td align=center><font face=helvetica size=2><b>$sourcedocdesignation Criteria</td>\n";
        
        #$outstr .= "<td align=center><font face=helvetica size=2><b>Notes, OCRWM Position, etc.</td>\n";
        #$outstr .= "<td align=center><font face=helvetica size=2><b>Justification for OCRWM Position</td>\n";
        
         if ($settings{rid} >= 30) { #rid:30 == revision 20 - sh 03/18/08
         		$outstr .= "<td align=center><font face=helvetica size=2><b>Notes</td>\n";
		  }else{
		  		$outstr .= "<td align=center><font face=helvetica size=2><b>Notes, OCRWM Position, etc.</td>\n";	
		  		$outstr .= "<td align=center><font face=helvetica size=2><b>Justification for OCRWM Position</td>\n";
		  }
		  
        $outstr .= "<td align=center><font face=helvetica size=2><b>QARD Section(s)</td></tr>\n";

        for (my $i = 1; $i <= $#sourcesections; $i++) {
            $sid = $sourcesections[$i]{id};
            $sourcesectionid = $sourcesections[$i]{sectionid};
            $sectiontext = $sourcesections[$i]{text};
            $sourcereqid = ($sourcesections[$i]{requirementid}) ? " - $sourcesections[$i]{requirementid}" : "";# - 0";

            tie my %t1a, "Tie::IxHash";
            %t1a = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "'QARD Table 1, Item ' || t.item || '-' || t.subid || ':<br>' || t.position", nameColumn => "'Item ' || t.item || '-' || t.subid || ':<br>' || t.justification", table => "qardtable1a t, $args{schema}.requirementtable1a r", where => "r.requirementid = $sid and r.table1aid = t.id", orderBy => "t.item, t.subid")};

            my $t1aposition = "";
            my $t1ajustification = "";
            my $key;
            foreach $key (keys %t1a) {
                $t1aposition .= "$key<br><br>\n";
                $t1ajustification .= "$t1a{$key}<br><br>\n";
            }
            my $posspacer = ($sourcesections[$i]{ocrwmposition} && $t1aposition) ? "<br><br>" : "";
            my $justspacer = ($sourcesections[$i]{ocrwmjustification} && $t1ajustification) ? "<br><br>" : "";
            
            $ocrwmposition = ($sourcesections[$i]{ocrwmposition} || $t1aposition) ? "$t1aposition$posspacer$sourcesections[$i]{ocrwmposition}" : "&nbsp;";           
            $ocrwmjustification = ($sourcesections[$i]{ocrwmjustification} || $t1ajustification) ? "$justspacer$t1ajustification$sourcesections[$i]{ocrwmjustification}" : "&nbsp;";
            
            ### begins new addition 02/13/08 ~ sh
            
		            my $ocrwmposition_mod;
		            my $ocrwmjustification_mod;
		            
		                if ($settings{rid} >= 30) { #rid:30 == revision 20
		    			($ocrwmposition_mod, $ocrwmjustification_mod) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "ocrwmposition, ocrwmjustification", table => "srnotes", where => "srid = $sourcesections[$i]{id} and rid = $settings{rid}") if $sourcesections[$i]{id};
		  				 }
		            
		           	 $ocrwmposition = ($ocrwmposition_mod) ? $ocrwmposition_mod :  $ocrwmposition;
		             $ocrwmjustification = ($ocrwmjustification_mod) ? $ocrwmjustification_mod : $ocrwmjustification;
            
            ### ends new addition 02/13/08 ~ sh
            
            $ocrwmposition =~ s/\n/<br>/g;
            $ocrwmjustification =~ s/\n/<br>/g;
            
            $outstr .= "<tr valign=top><td width=120 align=center><font size=2>$sourcesectionid$sourcereqid</td>\n";
            $outstr .= "<td><font size=2>$sectiontext</td>\n";
            $outstr .= "<td width=150><font size=2>$ocrwmposition</td>\n";
            #$outstr .= "<td width=140><font size=2>$ocrwmjustification</td>\n";
            
            if ($settings{rid} >= 30) { #rid:30 == revision 20 - sh 03/18/08
			}else{
            	$outstr .= "<td width=140><font size=2>$ocrwmjustification</td>\n";
			}
           
            $outstr .= "<td width=280><font size=2>\n";
            my $qards = $args{dbh} -> prepare ("select s.id, s.sectionid, s.text, s.title, to_char(m.lastupdated,'YYYYMMDD'), s.subid, u.firstname || ' ' || u.lastname from $args{schema}.qardsection s, $args{schema}.qardmatrix m, $args{schema}.users u where m.matrixid = $matrixid and m.sourcerequirementid = $sid and s.isdeleted = 'F' and m.qardsectionid = s.id and m.updatedby = u.id(+) order by s.tocid, s.sorter, s.sectionid, s.subid");
            $qards -> execute;
            my $theqards = "";
            my $count = 0;
            my $prevdate = "";
            while (my ($qid, $qsection, $qtext, $qtitle, $lastup, $qsubid, $upby) = $qards -> fetchrow_array) {
                $upby = ($upby && $upby ne " ") ? $upby : "Unknown"; 
                my $updatedetail = (($count == 0 || $lastup ne $prevdate) && $args{approval}) ? "<b>Last updated on " . substr($lastup, 4, 2) . "/" . substr($lastup, 6, 2) . "/" . substr($lastup, 0, 4) . " by $upby</b><br><br>" : "";
                $prevdate = $lastup;
                my $fontcolor = ($args{approval} && ($lastup gt $args{dateapproved})) ? "<font color=#ff0000>" : "<font color=#000000>";
                $qtitle = ($qtitle ne "" && $qtitle ne " " && $qtitle) ? "<b>$qtitle</b><br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" : "";
                $qsubid = ($qsubid) ? " - $qsubid" : "";# - 0";
                $theqards .= "$updatedetail$fontcolor$qsection$qsubid&nbsp;&nbsp;$qtitle$qtext</font><br><br>\n";
				$count++;
            }
            $qards -> finish;
            $outstr .= ($theqards) ? $theqards : "N/A"; #"&nbsp;";
            $outstr .= "</td></tr>\n";
        }
    }
    $outstr .= "</table>\n<br>\n";
    $outstr .= &matrixApprovalInfo (dbh => $args{dbh}, schema => $args{schema}, matrixid => $matrixid) if !($args{qtos});
    $outstr .= "<br>\n";
    return ($outstr);
}

########################
sub doDisplayPDFReport {
########################
    my %args = (
        matrixid => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    $args{dbh} -> {LongTruncOk} = 0;
    $args{dbh} -> {LongReadLen} = 10000;

    my $colCount = 5;
    my @colWidths = (90, 330, 150, 150, 380);
    my @colAlign = ("center", "left", "left", "left", "left");
    my @colAlignHeader = ("center", "center", "center", "center", "center");
    my @colTitles = ("", "", "", "", "", "");

    my ($matrixtitle, $sourcedocid, $statusid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "title, sourceid, statusid", where => "id = $args{matrixid}", table => "matrix");
    my ($sourcedocdesignation, $sourcedoctitle) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "designation, title", where => "id = $sourcedocid", table => "source");
    my $csr;
    my $getmatrix = "";
    $getmatrix = "select qr.id, qr.sectionid, qr.text, qr.ocrwmposition,
                         qr.ocrwmjustification, qr.requirementid, 
                         qr.table1aid, NULL
                  from $args{schema}.sourcerequirement qr
                  where qr.sourceid = $sourcedocid and qr.isdeleted = 'F'
                  order by qr.sorter desc, qr.sectionid, qr.requirementid";

    my $curdate = uc(&get_date());
    my $pdf = new PDF;
    $pdf -> setup (orientation => 'landscape', useGrid => 'F', leftMargin => 0.5, rightMargin => 0.5, topMargin => 0.5, bottomMargin => 0.5);
    $pdf -> setFont (font => "helvetica-bold", fontSize => 10.0);
    my $addon = ""; #($statusid == 1) ? " - Draft" : "";
    $pdf -> addHeader (fontSize => 18.0, text => "$matrixtitle$addon\n\n", alignment => "center");
    if ($settings{thedate} eq "T") {
        $pdf -> addFooter(fontSize => 8.0, text => "Status as of $curdate", alignment => "right", sameLine => 'T');
    }
    $pdf -> addFooter(fontSize => 8.0, text => "Page <page>", alignment => "center", sameLine => 'T');

    my $critid = "$sourcedocdesignation Section ID - Sub ID";
    my $crittext = "$sourcedocdesignation Criteria";
    my $ordnotes = "Notes, OCRWM Position, etc.";
     if ($settings{rid} >= 30) { #rid:30 == revision 20 - sh 03/18/08
         		$ordnotes = "Notes";
		  }
    my $ordjustif = "Justification for OCRWM Position";
    my $qardstuff = "QARD Section(s) and Text";
    my $qardid = "QARD Section(s)";
    my $comments = "Comments";
    
    
    
    if ($settings{ocrwm} eq "T" && $settings{qard} eq "T" && $settings{blank} eq "T") {
    	 if ($settings{rid} >= 30) { #rid:30 == revision 20 - sh 03/18/08
    	  			$getmatrix = "select qr.id, qr.sectionid, qr.text, qr.ocrwmposition,
			                             qr.requirementid, 
			                             qr.table1aid, NULL
			                      from $args{schema}.sourcerequirement qr
			                      where qr.sourceid = $sourcedocid and qr.isdeleted = 'F'
			                      order by qr.sorter desc, qr.sectionid, qr.requirementid";
			        $colCount = 5;
			        @colWidths = (80, 280, 100, 280, 260);
			        @colAlign = ("center", "left", "left", "left", "left");
			        @colAlignHeader = ("center", "center", "center", "center", "center", "center");
			        @colTitles = ($critid, $crittext, $ordnotes, $qardstuff, $comments);
    	 }else{
			        $getmatrix = "select qr.id, qr.sectionid, qr.text, qr.ocrwmposition,
			                             qr.ocrwmjustification, qr.requirementid, 
			                             qr.table1aid, NULL
			                      from $args{schema}.sourcerequirement qr
			                      where qr.sourceid = $sourcedocid and qr.isdeleted = 'F'
			                      order by qr.sorter desc, qr.sectionid, qr.requirementid";
			        $colCount = 6;
			        @colWidths = (80, 280, 100, 100, 280, 260);
			        @colAlign = ("center", "left", "left", "left", "left", "left");
			        @colAlignHeader = ("center", "center", "center", "center", "center", "center");
			        @colTitles = ($critid, $crittext, $ordnotes, $ordjustif, $qardstuff, $comments);
    	 }
    }
    elsif ($settings{ocrwm} eq "T" && $settings{qard} eq "T") {
    		if ($settings{rid} >= 30) { #rid:30 == revision 20 - sh 03/18/08
    				$getmatrix = "select qr.id, qr.sectionid, qr.text, qr.ocrwmposition,
			                             qr.requirementid, 
			                             qr.table1aid, NULL
			                      from $args{schema}.sourcerequirement qr
			                      where qr.sourceid = $sourcedocid and qr.isdeleted = 'F'
			                      order by qr.sorter desc, qr.sectionid, qr.requirementid";
			        $colCount = 4;
			        @colWidths = (90, 330, 150, 380);
			        @colAlign = ("center", "left", "left",  "left");
			        @colAlignHeader = ("center", "center", "center", "center");
			        @colTitles = ($critid, $crittext, $ordnotes, $qardstuff);
    		 }else{
			        $getmatrix = "select qr.id, qr.sectionid, qr.text, qr.ocrwmposition,
			                             qr.ocrwmjustification, qr.requirementid, 
			                             qr.table1aid, NULL
			                      from $args{schema}.sourcerequirement qr
			                      where qr.sourceid = $sourcedocid and qr.isdeleted = 'F'
			                      order by qr.sorter desc, qr.sectionid, qr.requirementid";
			        $colCount = 5;
			        @colWidths = (90, 330, 150, 150, 380);
			        @colAlign = ("center", "left", "left", "left", "left");
			        @colAlignHeader = ("center", "center", "center", "center", "center");
			        @colTitles = ($critid, $crittext, $ordnotes, $ordjustif, $qardstuff);
    		 }
    }
    elsif ($settings{ocrwm} eq "T" && $settings{blank} eq "T") {
    		if ($settings{rid} >= 30) { #rid:30 == revision 20 - sh 03/18/08
    				$getmatrix = "select qr.id, qr.sectionid, qr.text, qr.ocrwmposition,
			                             qr.requirementid, 
			                             qr.table1aid, NULL
			                      from $args{schema}.sourcerequirement qr
			                      where qr.sourceid = $sourcedocid and qr.isdeleted = 'F'
			                      order by qr.sorter desc, qr.sectionid, qr.requirementid";
			        $colCount = 5;
			        @colWidths = (90, 340, 140, 90, 300);
			        @colAlign = ("center", "left", "left", "left",  "left");
			        @colAlignHeader = ("center", "center", "center", "center", "center");
			        @colTitles = ($critid, $crittext, $ordnotes, $qardid, $comments);
    		 }else{
			        $getmatrix = "select qr.id, qr.sectionid, qr.text, qr.ocrwmposition,
			                             qr.ocrwmjustification, qr.requirementid, 
			                             qr.table1aid, NULL
			                      from $args{schema}.sourcerequirement qr
			                      where qr.sourceid = $sourcedocid and qr.isdeleted = 'F'
			                      order by qr.sorter desc, qr.sectionid, qr.requirementid";
			        $colCount = 6;
			        @colWidths = (90, 340, 140, 140, 90, 300);
			        @colAlign = ("center", "left", "left", "left", "left", "left");
			        @colAlignHeader = ("center", "center", "center", "center", "center", "center");
			        @colTitles = ($critid, $crittext, $ordnotes, $ordjustif, $qardid, $comments);
    		 }
    }
    elsif ($settings{qard} eq "T" && $settings{blank} eq "T") {
        $getmatrix = "select qr.id, qr.sectionid, qr.text, NULL,
                             NULL, qr.requirementid, NULL, NULL
                      from $args{schema}.sourcerequirement qr
                      where qr.sourceid = $sourcedocid and qr.isdeleted = 'F'
                      order by qr.sorter desc, qr.sectionid, qr.requirementid";
        $colCount = 4;
        @colWidths = (100, 350, 350, 300);
        @colAlign = ("center", "left", "left", "left");
        @colAlignHeader = ("center", "center", "center", "center");
        @colTitles = ($critid, $crittext, $qardstuff, $comments);
    }
    elsif ($settings{ocrwm} eq "T") {
    	if ($settings{rid} >= 30) { #rid:30 == revision 20 - sh 03/18/08
    				$getmatrix = "select qr.id, qr.sectionid, qr.text, qr.ocrwmposition,
			                             qr.requirementid, 
			                             qr.table1aid, NULL
			                      from $args{schema}.sourcerequirement qr
			                      where qr.sourceid = $sourcedocid and qr.isdeleted = 'F'
			                      order by qr.sorter desc, qr.sectionid, qr.requirementid";
			        $colCount = 4;
			        @colWidths = (150, 400, 200, 150);
			        @colAlign = ("center", "left", "left", "center");
			        @colAlignHeader = ("center", "center", "center", "center");
			        @colTitles = ($critid, $crittext, $ordnotes,  $qardid);
        }else{
			        $getmatrix = "select qr.id, qr.sectionid, qr.text, qr.ocrwmposition,
			                             qr.ocrwmjustification, qr.requirementid, 
			                             qr.table1aid, NULL
			                      from $args{schema}.sourcerequirement qr
			                      where qr.sourceid = $sourcedocid and qr.isdeleted = 'F'
			                      order by qr.sorter desc, qr.sectionid, qr.requirementid";
			        $colCount = 5;
			        @colWidths = (150, 400, 200, 200, 150);
			        @colAlign = ("center", "left", "left", "left", "center");
			        @colAlignHeader = ("center", "center", "center", "center", "center");
			        @colTitles = ($critid, $crittext, $ordnotes, $ordjustif, $qardid);
        }
    }
    elsif ($settings{qard} eq "T") {
        $getmatrix = "select qr.id, qr.sectionid, qr.text, NULL,
                             NULL, qr.requirementid, NULL, NULL
                      from $args{schema}.sourcerequirement qr
                      where qr.sourceid = $sourcedocid and qr.isdeleted = 'F'
                      order by qr.sorter desc, qr.sectionid, qr.requirementid";
        $colCount = 3;
        @colWidths = (200, 450, 450);
        @colAlign = ("center", "left", "left");
        @colAlignHeader = ("center", "center", "center");
        @colTitles = ($critid, $crittext, $qardstuff);
    }
    elsif ($settings{blank} eq "T") {
        $getmatrix = "select qr.id, qr.sectionid, qr.text, NULL,
                             NULL, qr.requirementid, NULL, NULL
                      from $args{schema}.sourcerequirement qr
                      where qr.sourceid = $sourcedocid and qr.isdeleted = 'F'
                      order by qr.sorter desc, qr.sectionid, qr.requirementid";
        $colCount = 4;
        @colWidths = (150, 400, 150, 400);
        @colAlign = ("center", "left", "left", "left");
        @colAlignHeader = ("center", "center", "center", "center");
        @colTitles = ($critid, $crittext, $qardid, $comments);
    }
    else {
        $colCount = 3;
        @colWidths = (200, 700, 200);
        @colAlign = ("center", "left", "left");
        @colAlignHeader = ("center", "center", "center");
        @colTitles = ($critid, $crittext, $qardid);
    }
    
    
    
    $csr = $args{dbh} -> prepare ($getmatrix);
    $csr -> execute;

    my $fontID = $pdf->setFont(font => "Times-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID, border => 1,
                       colCount => $colCount, colWidths => \@colWidths,
                       colAlign => \@colAlignHeader, row => \@colTitles);
    $pdf -> newPage (orientation => 'landscape', useGrid => 'F', paperSize => '11x17');
    $pdf -> setFont(font => "Times-Roman", fontSize => 8.0);

    my $row;
    my ($docsectionid, $docsection, $doctext, $ocrwmposition, $ocrwmjustification, $qardsection, $qardsectiontext, $requirementid, $table1aid, $blank) = ("", "", "", "", "", "", "", "", "");
    
   while (($docsectionid, $docsection, $doctext, $ocrwmposition, $ocrwmjustification, $requirementid, $table1aid, $blank) = $csr -> fetchrow_array) {

            my $noposition = ($settings{noposition} eq 'T') ? "" : "|| ':\n' || t.position";
            tie my %t1a, "Tie::IxHash";
            %t1a = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, idColumn => "'QARD Table 1, Item ' || t.item || '-' || t.subid $noposition", nameColumn => "'Item ' || t.item || '-' || t.subid || ':\n' || t.justification", table => "qardtable1a t, $args{schema}.requirementtable1a r", where => "r.requirementid = $docsectionid and r.table1aid = t.id", orderBy => "t.item, t.subid")};

            my $t1aposition = "";
            my $t1ajustification = "";
            my $key;
            foreach $key (keys %t1a) {
                $t1aposition .= "$key\n\n";
                $t1ajustification .= "$t1a{$key}\n\n";
            }
my $warn = $^W;
$^W = 0;
            if ($t1aposition && $ocrwmposition) {
                $ocrwmposition = "$t1aposition\n\n$ocrwmposition";
            }
            elsif ($t1aposition) {
                chomp ($t1aposition);
                chomp ($t1aposition);
                $ocrwmposition = $t1aposition;
            }
            if ($t1ajustification && $ocrwmjustification) {
                $ocrwmjustification = "$t1ajustification\n\n$ocrwmjustification";
            }
            elsif ($t1ajustification) {
                chomp ($t1ajustification);
                chomp ($t1ajustification);
                $ocrwmjustification = $t1ajustification;
            }
$^W = $warn;

        $qardsection = "";
        my $qards = $args{dbh} -> prepare ("select s.id, s.sectionid, s.subid, s.text, s.title from $args{schema}.qardsection s, $args{schema}.qardmatrix m where m.matrixid = $settings{matrixid} and m.sourcerequirementid = $docsectionid and s.isdeleted = 'F' and m.qardsectionid = s.id order by s.tocid, s.sorter, s.sectionid, s.subid");
        $qards -> execute;
        while (my ($qid, $qsection, $qsubid, $qtext, $qtitle) = $qards -> fetchrow_array) {
            $qtext = &getDisplayString ($qtext, 100) if $settings{truncate} eq 'T';
            $qsubid = $qsubid ? " - $qsubid" : "";
#            $qsubid = $qsubid ? $qsubid : 0;
$warn = $^W;
$^W = 0;
             if (!($qtitle eq "" || $qtitle eq " ")) {
                 $qardsection .= ($settings{qard} eq "T") ? "$qsection$qsubid $qtitle\n\n     $qtext\n\n" : "$qsection\n";
             }
             else {
                 $qardsection .= ($settings{qard} eq "T") ? "$qsection$qsubid $qtext\n\n" : "$qsection\n";
}
        }
$^W = $warn;

        $qards -> finish;
        $qardsection = $qardsection ? $qardsection : "N/A";
        $docsection = ($requirementid) ? "$docsection - $requirementid" : "$docsection";# - 0";
        $doctext = &getDisplayString ($doctext, 100) if $settings{truncate} eq 'T'; 

		### begins new addition 02/13/08 ~ sh
            
            my $ocrwmposition_mod;
            my $ocrwmjustification_mod;
            
                if ($settings{rid} >= 30) { #rid:30 == revision 20
    			($ocrwmposition_mod, $ocrwmjustification_mod) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "ocrwmposition, ocrwmjustification", table => "srnotes", where => "srid = $docsectionid and rid = $settings{rid}") if $docsectionid;
  				 }
            
            $ocrwmposition = ($ocrwmposition_mod) ? $ocrwmposition_mod :  $ocrwmposition;
            $ocrwmjustification = ($ocrwmjustification_mod) ? $ocrwmjustification_mod : $ocrwmjustification;
            
       ### ends new addition 02/13/08 ~ sh

		 if ($settings{rid} >= 30) { #rid:30 == revision 20 - sh 03/18/08
				 			 if ($settings{ocrwm} eq "T" && $settings{qard} eq "T" && $settings{blank} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $ocrwmposition, $qardsection, $blank]);
					        } 
					        elsif ($settings{ocrwm} eq "T" && $settings{qard} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $ocrwmposition,  $qardsection]);
					        }
					        elsif ($settings{ocrwm} eq "T" && $settings{blank} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $ocrwmposition,  $qardsection, $blank]);
					        }
					        elsif ($settings{qard} eq "T" && $settings{blank} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $qardsection, $blank]);
					        }
					        elsif ($settings{ocrwm} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $ocrwmposition, $qardsection]);
					        }
					        elsif ($settings{qard} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $qardsection]);
					        }
					        elsif ($settings{blank} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $qardsection, $blank]);
					        }
					        else {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $qardsection]);
			        }
			}else{
					        if ($settings{ocrwm} eq "T" && $settings{qard} eq "T" && $settings{blank} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $ocrwmposition, $ocrwmjustification, $qardsection, $blank]);
					        } 
					        elsif ($settings{ocrwm} eq "T" && $settings{qard} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $ocrwmposition, $ocrwmjustification, $qardsection]);
					        }
					        elsif ($settings{ocrwm} eq "T" && $settings{blank} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $ocrwmposition, $ocrwmjustification, $qardsection, $blank]);
					        }
					        elsif ($settings{qard} eq "T" && $settings{blank} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $qardsection, $blank]);
					        }
					        elsif ($settings{ocrwm} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $ocrwmposition, $ocrwmjustification, $qardsection]);
					        }
					        elsif ($settings{qard} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $qardsection]);
					        }
					        elsif ($settings{blank} eq "T") {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $qardsection, $blank]);
					        }
					        else {
					            $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$docsection, $doctext, $qardsection]);
			        }
		}
        
    }    
    $csr -> finish;
    my $pdfBuff = $pdf -> finish;

    print "Content-type: application/pdf\n";
    print "Content-disposition: inline; filename=training_cert.pdf\n";
    print "\n";
    print $pdfBuff;
}

#########################
sub doDisplayPDFTable1A {
#########################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    $args{dbh} -> {LongTruncOk} = 0;
    $args{dbh} -> {LongReadLen} = 10000;

	    my $colCount = 5;
	    my @colWidths = (50, 250, 250, 250, 250);
	    my @colAlign = ("center", "left", "left", "left", "left");
	    my @colAlignHeader = ("center", "center", "center", "center", "center");
	    my @colTitles = ("Item", "US NRC Document", "National/Industry Standard", "Position", "Justification");
	    
	 if ($settings{rid} >= 30) { #rid:30 == revision 20 - sh 03/18/08
	   	 $colCount = 4;
		@colWidths = (50, 250, 250, 250);
		@colAlign = ("center", "left", "left", "left");
		@colAlignHeader = ("center", "center", "center", "center");
		@colTitles = ("Item", "NRC Document/Industry Standard", "Position", "Justification");
	 }

    my ($revisionid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "revid", where => "id = $settings{matrixid}", table => "qard");

    my $curdate = uc(&get_date());
    my $pdf = new PDF;
    $pdf -> setup (orientation => 'landscape', useGrid => 'F', leftMargin => 0.5, rightMargin => 0.5, topMargin => 0.5, bottomMargin => 0.5);
    $pdf -> setFont (font => "helvetica-bold", fontSize => 10.0);
    $pdf -> addHeader (fontSize => 18.0, text => "$revisionid\nTable 1A - Regulatory/Commitment Document Positions with Justification\n\n", alignment => "center");
    if ($settings{thedate} ne "F") {
        $pdf -> addFooter(fontSize => 8.0, text => "Status as of $curdate", alignment => "right", sameLine => 'T');
    }
    $pdf -> addFooter(fontSize => 8.0, text => "Page <page>", alignment => "center", sameLine => 'T');

    my $fontID = $pdf->setFont(font => "Times-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID, border => 1,
                       colCount => $colCount, colWidths => \@colWidths,
                       colAlign => \@colAlignHeader, row => \@colTitles);
    $pdf -> newPage (orientation => 'landscape', useGrid => 'F', paperSize => '11x17');
    $pdf -> setFont(font => "Times-Roman", fontSize => 8.0);

    my $row;
    my ($item, $subid, $nrc, $standard, $position, $justification) = ("", "", "", "", "", "");
    my $previtem = "";
    my @table1a = &getTable (dbh => $args{dbh}, schema => $args{schema}, where => "revisionid = $settings{matrixid} and isdeleted = 'F'", orderby => "item, subid");
    for (my $i=1; $i <= $#table1a; $i++) {
        $item = $table1a[$i]{item};
        $subid = $table1a[$i]{subid};
        $position = $table1a[$i]{position};
        $justification = $table1a[$i]{justification};
        $nrc = $table1a[$i]{nrcdescription};
        $standard = $table1a[$i]{standarddescription};
        my $theitem = ($subid) ? "$item - $subid" : "$item";# - 0";
        if ($previtem eq $item) {
            $nrc = "";
            $standard = "";
        }
        #$row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$theitem, $nrc, $standard, $position, $justification]);
        # 03/19/08 sh mod
		if ($settings{rid} >= 30) { #rid:30 == revision 20 - sh 03/19/08
			$row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$theitem, $nrc, $position, $justification]);
		}else{
			$row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$theitem, $nrc, $standard, $position, $justification]);
		}
		   	
        $previtem = $item;
    }
    my $pdfBuff = $pdf -> finish;

    print "Content-type: application/pdf\n";
    print "Content-disposition: inline; filename=training_cert.pdf\n";
    print "\n";
    print $pdfBuff;

}

#############################
sub doDisplayQtoSHTMLReport {
#############################
    my %args = (
        matrixid => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    $args{dbh}->{LongTruncOk} = 0;
    $args{dbh}->{LongReadLen} = 10000;
    my $outstr = &doDisplayHTMLReport (qtos => 1, dbh => $args{dbh}, schema => $args{schema},  matrixid => $args{matrixid}, matrixtitle => $args{matrixtitle}, userID => $args{userID}, form => $args{form}, settings => \%settings);

    return ($outstr);
}

############################
sub doDisplayQtoSPDFReport {
############################
    my %args = (
        matrixid => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    $args{dbh} -> {LongTruncOk} = 0;
    $args{dbh} -> {LongReadLen} = 10000;

    my $colCount = 3;
    my @colWidths = (90, 480, 530);
    my @colAlign = ("center", "left", "left");
    my @colAlignHeader = ("center", "center", "center");
    my @colTitles = ("QARD Section ID - Sub ID", "QARD Section Title and Text", "Source Criteria");

    my ($matrixtitle, $sourcedocid, $sourcedocdesignation, $sourcedoctitle) = ("", "", "", "");
    my $qardrevisionid = $settings{rid};

     if ($args{matrixid}) {
         ($matrixtitle, $sourcedocid, $qardrevisionid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "title, sourceid, qardid", where => "id = $args{matrixid}", table => "matrix");
        ($sourcedocdesignation, $sourcedoctitle) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "designation, title", where => "id = $sourcedocid", table => "source");
        $matrixtitle =~ s/ to / from /g;
    }

    my $csr;
    my $getmatrix = "";
    $getmatrix = "select id, sectionid, subid, title, text
                  from $args{schema}.qardsection
                  where qardrevid = $qardrevisionid and 
                        isdeleted = 'F'
                  order by tocid, sorter, sectionid, subid";

    my $curdate = uc(&get_date());
    my $pdf = new PDF;

    $pdf -> setup (orientation => 'landscape', useGrid => 'F', leftMargin => 0.5, rightMargin => 0.5, topMargin => 0.5, bottomMargin => 0.5);
    $pdf -> setFont (font => "helvetica-bold", fontSize => 10.0);
    $pdf -> addHeader (fontSize => 18.0, text => "$matrixtitle\n\n", alignment => "center");
    $pdf -> addFooter(fontSize => 8.0, text => "Status as of $curdate", alignment => "right", sameLine => 'T');
    $pdf -> addFooter(fontSize => 8.0, text => "Page <page>", alignment => "center", sameLine => 'T');

    $csr = $args{dbh} -> prepare ($getmatrix);
    $csr -> execute;

    my $fontID = $pdf->setFont(font => "Times-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID, border => 1,
                       colCount => $colCount, colWidths => \@colWidths,
                       colAlign => \@colAlignHeader, row => \@colTitles);
    $pdf -> newPage (orientation => 'landscape', useGrid => 'F', paperSize => '11x17');
    $pdf -> setFont(font => "Times-Roman", fontSize => 8.0);

    my $row;
    my ($qardid, $qardsectionid, $qardsubid, $qardtitle, $qardtext) = ("", "", "", "", "");
   while (($qardid, $qardsectionid, $qardsubid, $qardtitle, $qardtext) = $csr -> fetchrow_array) {
        $qardsectionid = ($qardsubid) ? "$qardsectionid - $qardsubid" : "$qardsectionid";# - 0";
        $qardtext = ($qardtitle) ? "$qardtitle\n\n     $qardtext" : $qardtext;
        $qardtext = &getDisplayString ($qardtext, 100) if $settings{truncate} eq 'T';
        my $sourcesection = "";
        my $reqs = "";
        if ($settings{matrixid}) {
            $reqs = $args{dbh} -> prepare ("select NULL, s.sectionid, s.requirementid, s.text from $args{schema}.sourcerequirement s, $args{schema}.qardmatrix m where m.matrixid = $settings{matrixid} and m.qardsectionid = $qardid and s.isdeleted = 'F' and m.sourcerequirementid = s.id order by s.sorter, s.sectionid, s.requirementid");
        }
        else {
            $reqs = $args{dbh} -> prepare ("select so.designation, s.sectionid, s.requirementid, s.text from $args{schema}.sourcerequirement s, $args{schema}.qardmatrix m, $args{schema}.source so where m.qardsectionid = $qardid and s.isdeleted = 'F' and m.sourcerequirementid = s.id and s.sourceid = so.id order by so.designation, s.sorter, s.sectionid, s.requirementid");
        }
        $reqs -> execute;
        while (my ($sdesignation, $ssection, $sreqid, $stext) = $reqs -> fetchrow_array) {
            $ssection = ($sreqid) ? "$ssection - $sreqid" : "$ssection";# - 0";
            if ($settings{truncate} eq 'T') {
                $stext = ($settings{matrixid}) ? &getDisplayString ($stext, 100) : &getDisplayString ($stext, 80); 
            }
            $sourcesection .= ($settings{matrixid}) ? "$ssection  $stext\n" : "$sdesignation: $ssection  $stext\n";
            $sourcesection .= "\n" if ($settings{truncate} eq 'F'); 
        }
        $reqs -> finish;
 
        chomp ($sourcesection); 
        chomp ($sourcesection); 
        chomp ($sourcesection); 
        $sourcesection = $sourcesection ? $sourcesection : "N/A";

        $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$qardsectionid, $qardtext, $sourcesection]);
    }    
    $csr -> finish;
    my $pdfBuff = $pdf -> finish;

    print "Content-type: application/pdf\n";
    print "Content-disposition: inline; filename=training_cert.pdf\n";
    print "\n";
    print $pdfBuff;
}

######################
sub doMainAQAPReport {
######################
    my %args = (
        matrixid => 0,
        approval => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    $args{dbh}->{LongTruncOk} = 0;
    $args{dbh}->{LongReadLen} = 10000;

    my $aqaprid = $settings{aqaprid};
    my ($orderdoc, $guidancedoc) = ("", "");
    my $docs = $args{dbh} -> prepare ("select designation, typeid from $args{schema}.source where typeid in (3,5) and qardtypeid = 2");
    $docs -> execute;
    while (my ($des, $type) = $docs -> fetchrow_array) {
        $orderdoc = $des if ($type == 5);
        $guidancedoc = $des if ($type == 3);
    }
    $docs -> finish;

    my $outstr = "<br>";

    my $matrixid = ($settings{matrixid}) ? $settings{matrixid} : $args{matrixid}; 
    $matrixid = $settings{approvalmatrixid} if $args{approval};
    my ($mid, $mname, $revisionid) = ($matrixid, "", "");

    if ($aqaprid) {
        ($revisionid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "revid", table => "qard", where => "id = $aqaprid") if ($aqaprid);
        ($mid, $mname) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "id, title", table => "matrix", where => "qardid = $aqaprid") if $revisionid;
    }
    elsif ($matrixid) {
        ($aqaprid, $revisionid, $mname) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "q.id, q.revid, m.title", table => "matrix m, $args{schema}.qard q", where => "m.id = $mid and m.qardid = q.id");
    }
    my @sections = &getSections (dbh => $args{dbh}, schema => $args{schema}, where => "qardrevid = $aqaprid", orderby => "sorter, sectionid, subid");
    my ($id, $sectionid, $title, $text, $subid, $tablerow) = (0,"","",0,"");

    for (my $i = 1; $i <= $#sections; $i++) {
        $id = $sections[$i]{id};
        $sectionid = $sections[$i]{sectionid};
        my $br = ($sections[$i]{title} && $sections[$i]{text}) ? "<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" : "";
        $title = ($sections[$i]{title}) ? "<b>$sections[$i]{title}</b>$br" : "";
        $text = ($sections[$i]{text}) ? $sections[$i]{text} : "";
        $text =~ s/\n/<br>/g;
        $subid = ($sections[$i]{subid}) ? " - $sections[$i]{subid}" : "";# - 0";
        my $sectionidnospace = $sections[$i]{sectionid};
        $sectionidnospace =~ s/ //g;
        my $jump = "<a name=$sectionidnospace></a>";
#        my $jump = "<a name=$sections[$i]{sectionid}></a>";
        my $thesection = "$jump$title $text";

        my $getorders = "select s.sectionid, s.requirementid, s.text, m.lastupdated from $args{schema}.sourcerequirement s, $args{schema}.qardmatrix m where m.qardsectionid = $id and m.matrixid = $mid and m.sourcetypeabbrev = 'O' and m.sourcerequirementid = s.id";
        my $orders = "";
        my $csr = $args{dbh} -> prepare ($getorders);
        $csr -> execute;
        while (my ($osect, $oreq, $otext, $lastup) = $csr -> fetchrow_array) {
                my $fontcolor = ($args{approval} && ($lastup gt $args{dateapproved})) ? "<font color=#ff0000>" : "";
            $orders .= "<b>$fontcolor$osect - $oreq</b>&nbsp;&nbsp;$otext<br><br>\n";
        }
        $csr -> finish;
#        $orders .= "&nbsp;\n";
        $orders = $orders ? $orders : "N/A\n";

        my $getguidance = "select s.sectionid, s.requirementid, s.text, to_char(m.lastupdated, 'YYYYMMDD HH24MISS') from $args{schema}.sourcerequirement s, $args{schema}.qardmatrix m where m.qardsectionid = $id and m.matrixid = $mid and m.sourcetypeabbrev = 'G' and m.sourcerequirementid = s.id";
        my $guidances = "";
        $csr = $args{dbh} -> prepare ($getguidance);
        $csr -> execute;
        while (my ($gsect, $greq, $gtext, $lastup) = $csr -> fetchrow_array) {
                my $fontcolor = ($args{approval} && ($lastup gt $args{dateapproved})) ? "<font color=#ff0000>" : "";
            $guidances .= "<b>$fontcolor$gsect - $greq</b>&nbsp;&nbsp;$gtext<br><br>\n";
        }
        $csr -> finish;
#        $guidances .= "&nbsp;\n";
        $guidances = $guidances ? $guidances : "N/A\n";

        $tablerow .= "<tr valign=top><td><font size=-1 face=helvetica>$sectionid$subid</td><td><font size=-1 face=helvetica>$thesection</td><td>$orders</td><td>$guidances</td></tr>\n";
    }
    $outstr .= "<table width=750 align=center cellspacing=0 cellpadding=3 border=1 bgcolor=#ffffff>\n";
    $outstr .= "<tr bgcolor=#78b6ef><td colspan=4><font size=+1><b>AQAP $revisionid -- $mname</td></tr>\n";
    $outstr .= "<tr bgcolor=#eeeeee><td width=10%><font size=2><b>Section ID - Sub ID</td><td width=40%><font size=2><b>Text</td><td width=25% align=center><font size=2><b>$orderdoc</td><td width=25% align=center><font size=2><b>$guidancedoc</td></tr>\n";
    $outstr .= "<tr><td colspan=2></td></tr>\n";
    $outstr .= $tablerow;
    $outstr .= "</table><br>\n";
    $outstr .= &matrixApprovalInfo (dbh => $args{dbh}, schema => $args{schema}, matrixid => $mid);
    $outstr .= "<br>\n";

    return ($outstr);
}

######################
sub doDisplayPDFAQAP {
######################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    $args{dbh} -> {LongTruncOk} = 0;
    $args{dbh} -> {LongReadLen} = 10000;

    my $colCount = 4;
    my @colWidths = (100, 300, 300, 300);
    my @colAlign = ("center", "left", "left", "left");
    my @colAlignHeader = ("center", "center", "center", "center");

    my ($orderdoc, $guidancedoc) = ("", "");
    my $docs = $args{dbh} -> prepare ("select designation, typeid from $args{schema}.source where typeid in (3,5) and qardtypeid = 2");
    $docs -> execute;
    while (my ($des, $type) = $docs -> fetchrow_array) {
        $orderdoc = $des if ($type == 5);
        $guidancedoc = $des if ($type == 3);
    }
    $docs -> finish;

    my @colTitles = ("Section ID - Sub ID", "Section Text", "Related $orderdoc Criteria", "Related $guidancedoc Criteria");

    my ($revisionid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "revid", where => "id = $settings{aqaprid}", table => "qard");
   my ($mid) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "id", where => "qardid = $settings{aqaprid}", table => "matrix");

    my $curdate = uc(&get_date());
    my $pdf = new PDF;
    $pdf -> setup (orientation => 'landscape', useGrid => 'F', leftMargin => 0.5, rightMargin => 0.5, topMargin => 0.5, bottomMargin => 0.5);
    $pdf -> setFont (font => "helvetica-bold", fontSize => 10.0);
    $pdf -> addHeader (fontSize => 18.0, text => "$revisionid\n\n\n", alignment => "center");
    $pdf -> addFooter(fontSize => 9.0, text => "Status as of $curdate", alignment => "right", sameLine => 'T');
    $pdf -> addFooter(fontSize => 9.0, text => "Page <page>", alignment => "center", sameLine => 'T');

    my $fontID = $pdf->setFont(font => "Times-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 10, fontID => $fontID, border => 1,
                       colCount => $colCount, colWidths => \@colWidths,
                       colAlign => \@colAlignHeader, row => \@colTitles);
    $pdf -> newPage (orientation => 'landscape', useGrid => 'F', paperSize => '11x17');
    $pdf -> setFont(font => "Times-Roman", fontSize => 9.0);

    my $row;
    my ($id, $sectionid, $subid, $title, $text) = ("", "", "", "", "");
    my $previtem = "";
    my @aqap = &getSections (dbh => $args{dbh}, schema => $args{schema}, where => "qardrevid = $settings{aqaprid} and isdeleted = 'F'", orderby => "sorter, sectionid, subid");
    for (my $i=1; $i <= $#aqap; $i++) {
        $id = $aqap[$i]{id};
        $sectionid = $aqap[$i]{sectionid};
        $subid = $aqap[$i]{subid};
        $title = $aqap[$i]{title};
        $text = $aqap[$i]{text};
        my $thesection = ($subid) ? "$sectionid - $subid" : "$sectionid";# - 0";

        my $getorders = "select s.sectionid, s.requirementid, s.text, m.lastupdated from $args{schema}.sourcerequirement s, $args{schema}.qardmatrix m where m.qardsectionid = $id and m.matrixid = $mid and m.sourcetypeabbrev = 'O' and m.sourcerequirementid = s.id";
        my $orders = "";
        my $csr = $args{dbh} -> prepare ($getorders);
        $csr -> execute;
        while (my ($osect, $oreq, $otext, $lastup) = $csr -> fetchrow_array) {
            $orders .= "$osect - $oreq     $otext\n\n";
        }
        $csr -> finish;
        $orders = $orders ? $orders : "N/A";

        my $getguidance = "select s.sectionid, s.requirementid, s.text, m.lastupdated from $args{schema}.sourcerequirement s, $args{schema}.qardmatrix m where m.qardsectionid = $id and m.matrixid = $mid and m.sourcetypeabbrev = 'G' and m.sourcerequirementid = s.id";
        my $guidances = "";
        $csr = $args{dbh} -> prepare ($getguidance);
        $csr -> execute;
        while (my ($gsect, $greq, $gtext, $lastup) = $csr -> fetchrow_array) {
            $guidances .= "$gsect - $greq     $gtext\n\n";
        }
        $csr -> finish;
        $guidances = $guidances ? $guidances : "N/A";

        $row = $pdf -> tableRow (border => 1, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => [$thesection, "$title\n$text", $orders, $guidances]);
    }
    my $pdfBuff = $pdf -> finish;

    print "Content-type: application/pdf\n";
    print "Content-disposition: inline; filename=training_cert.pdf\n";
    print "\n";
    print $pdfBuff;
}

########################
sub matrixApprovalInfo {
########################
    my %args = (
        matrixid => 0,
        @_,
    );
#    my $hashRef = $args{settings};
#    my %settings = %$hashRef;

    my $outstr = "<table align=center cellpadding=6 cellspacing=5 bgcolor=#dddddd border=2 bordercolor=#eeeeee><tr><td><font face=helvetica>\n";
    my ($title, $approverid, $approver, $date, $status, $lastupdated, $updatedby, $rationale) = ("", 0, "","","","", "", "");

    ($title, $approverid, $date, $status, $lastupdated, $updatedby, $rationale) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "m.title, m.approvedby, m.dateapproved, s.description, m.lastupdated, u.firstname || ' ' || u.lastname, m.rejectionrationale", table => "matrix m, $args{schema}.matrixstatus s, $args{schema}.users u", where => "m.id = $args{matrixid} and m.statusid = s.id and m.updatedby = u.id");
    ($approver) = ($approverid) ? &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "firstname || ' ' || lastname", table => "users", where => "id = $approverid") : ("");

    $outstr .= "<font size=3>Summary status information for <br>Compliance Matrix <b>$title</b>:</font></td></tr>\n";
    $outstr .= "<tr><td><font size=2 face=helvetica>\n";
    $outstr .= ($date) ? "Most recent approval review by <b>$approver</b> on <b>$date</b>.\n" : "Never been approved.";
    $outstr .= "<br>Current status: <b>$status</b>. <br>Most recent matrix update: <b>$lastupdated</b> by <b>$updatedby</b>. <br>\n";
    $outstr .= "Rejection rationale: $rationale" if ($status eq "Approval Pending" && $rationale);
    $outstr .= "</font>\n";
    $outstr .= "</td></tr></table>\n";

    return ($outstr);
}

###############
1; #return true


