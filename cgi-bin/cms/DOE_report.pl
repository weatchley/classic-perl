#!/usr/local/bin/perl

# $Source: /data/dev/rcs/cms/perl/RCS/DOE_report.pl,v $
# $Revision: 1.3 $
# $Date: 2003/01/02 22:46:28 $
# $Author: naydenoa $
# $Locker:  $
# $Log: DOE_report.pl,v $
# Revision 1.3  2003/01/02 22:46:28  naydenoa
# Updated report headers, moved system ID to the last column - CREQ00025
#
# Revision 1.2  2002/08/09 16:16:06  naydenoa
# Added changes log (RCS), updated truncate length
#
#

use pdflib_pl 4.0;
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);
use Edit_Screens;

use strict;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use ReportWriterPDF;

my $pdfcgi = new CGI;

$SCHEMA = (defined($pdfcgi->param("schema"))) ? $pdfcgi->param("schema") : $SCHEMA;

$|=1;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $pageNumber = 0;

my $lastLine;
my $pageBottom;

#############
# subroutines
#############

##############
sub get_date {    # routine to generate an oracle friendly date
##############
    my $indate = $_[0];
    my $outstring = '';
    my $day; my $month; my $year;
    my @months = ("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec");
    if (defined ($indate) && $indate gt ' ') {
        ($month, $day, $year) = split /\//, $indate;
        $month = $month -1;
    } else {
        ($day, $month, $year) = (localtime)[3,4,5];
        $year = $year + 1900;
    }
    $outstring .= "$day-$months[$month]-$year";
    return ($outstring);
}


###########
# main Body
###########

    my $dbh = oncs_connect();
    $dbh->{LongTruncOk} = 1;   # specify whole text or truncated fraction
    $dbh->{LongReadLen} = 100000;

    my $pdf = new ReportWriterPDF;
    $pdf->setup(orientation => 'portrait', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5);

    my $curdate = uc(&get_date()); 
    $pdf->setFont(font => "Times-Bold", fontSize => 10.0);
    $pdf->addHeader(fontSize=>11.0, text => "YMP Project Manager Biweekly Commitment Report", alignment => "center");
    $pdf->addHeader(fontSize=>8.0, text => "(DOE/NRC Mgmt/QA Meetings, KTI Items, Letters, Lower Level Actions)", alignment => "center");
    $pdf->addHeader(fontSize=>8.0, text => " ", alignment => "center");
    
#    $pdf->addFooter(fontSize => 8.0, text => "BSC/LAP Nakashima", alignment => "left");
    $pdf->addFooter(fontSize => 8.0, text => "Status as of $curdate", alignment => "right", sameLine => 'T');
    $pdf->addFooter(fontSize => 8.0, text => "Page <page>", alignment => "center", sameLine => 'T');
    
my $colCount = 12;
    my @colWidths = (50, 60, 120, 50, 45, 45, 45, 45, 50, 50, 50, 30);
    my @colAlign = ("center", "center", "left", "center", "center", "center", "center", "center", "center", "center", "center", "center");
    my @colTitles = ("Category", "External ID", "Commitment Text", "Status", "Original BSC Fulfillment Due Date", "Revised BSC Fulfillment Due Date", "Actual DOE Completion Date", "NRC Concurrence on Closure", "DOE Responsible Individual", "DOE Manager", "BSC Responsible Manager", "System ID");
    
    my $fontID = $pdf->setFont(font => "Times-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
                       colCount => $colCount, colWidths => \@colWidths, 
                       colAlign => \@colAlign, row => \@colTitles);

    $pdf->newPage(orientation => 'landscape', useGrid => 'F');
    
    $pdf->setFont(font => "Times-Bold", fontSize => 8.0);
    $pdf->setFont(font => "Times-Roman", fontSize => 8.0);


    my $query = "select c.commitmentid, c.text, c.externalid, 
                        to_char(c.fulfilldate,'MM/DD/YYYY'), 
                        to_char(c.closeddate,'MM/DD/YYYY'), 
                        c.statusid, r.lastname, s.mapping, 
                        sm.description, cat.description,
                        rm.lastname 
                 from $SCHEMA.commitment c, $SCHEMA.responsiblemanager r, 
                      $SCHEMA.status s, $SCHEMA.statusmapping sm, 
                      $SCHEMA.issue i, $SCHEMA.category cat,
                      $SCHEMA.responsiblemanager rm 
                 where r.responsiblemanagerid(+) = c.managerid and
                       rm.responsiblemanagerid(+) = c.doemanagerid and
                       s.statusid = c.statusid and 
                       s.mapping = sm.statusmappingid and 
                       c.issueid = i.issueid and 
                       i.categoryid = cat.categoryid 
                 order by cat.description, s.mapping, c.commitmentid";
    my $getstuff = $dbh -> prepare ($query);
    $getstuff -> execute;
    my $i = 0;
    while (my ($cid, $ctext, $eid, $fdate, $cdate, $stat, $mgr, $sorder, $sdesc, $cat, $doemgr) = $getstuff -> fetchrow_array) {
	$i++;

	my ($doelead) = $dbh -> selectrow_array ("select u.lastname from $SCHEMA.users u, $SCHEMA.commitmentrole cr where cr.commitmentid=$cid and cr.roleid=3 and u.usersid=cr.usersid");
	my $fuldates = $dbh -> prepare ("select to_char(oldduedate,'MM/DD/YYYY') from $SCHEMA.duedatehistory where commitmentid=$cid and datetype=2 order by oldduedate");
	$fuldates -> execute;
	my $originalful;
	my $fulstring = "";
	my $i = 0;
	while (my ($fd) = $fuldates -> fetchrow_array) {
	    if ($i == 0) {
		$originalful = $fd;
		$i++;
	    }
	    else {
		$fulstring = $fd . " " . $fulstring;
	    }
	}
	$originalful = ($originalful) ? $originalful : $fdate;
	$fuldates -> finish;
	$fulstring = $fdate . " " . $fulstring;
	$eid = ($eid) ? $eid : "";
        my @rowList;
	$cid = "C" . substr("0000$cid",-5);
        @rowList = ($cat, $eid, $ctext, $sdesc, $originalful, $fulstring, $cdate, "", $doelead, $doemgr, $mgr, $cid);
        my $fontSize = 8;
        $lastLine = $pdf -> tableRow (fontSize => $fontSize, 
                                      colCount => $colCount, 
                                      colWidths => \@colWidths, 
                                      colAlign => \@colAlign, 
                                      row => \@rowList );
    }
    $getstuff -> finish;    
    my $pdfBuff = $pdf->finish;

    print "Content-type: application/pdf\n";
    print "Content-disposition: inline; filename=testpfd.pdf\n";
    print "\n";
    print $pdfBuff;

    &oncs_disconnect($dbh);
