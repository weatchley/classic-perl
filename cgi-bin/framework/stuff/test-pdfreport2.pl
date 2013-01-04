#!/usr/local/bin/perl

#use pdflib_pl 4.0;

use strict;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use PDF;
use SharedHeader qw(:Constants);

my $pdfcgi = new CGI;

#$SCHEMA = (defined($pdfcgi->param("schema"))) ? $pdfcgi->param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $pageNumber = 0;
#my $command = ((defined($pdfcgi->param('command'))) ? $pdfcgi->param('command') : "");

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

    #my $pdf = new ReportWriterPDF(orientation => 'landscape');
    my $pdf = new PDF;
    $pdf->setup(orientation => 'landscape', useGrid => 'T', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5);

#    my $titleText = ((defined($pdfcgi->param('title'))) ? $pdfcgi->param('title') : "Header Line 1");
    my $curdate = uc(&get_date()); 
    $pdf->setFont(font => "Times-Bold", fontSize => 10.0);
    $pdf->addHeader(fontSize=>11.0, text => "Header 1", alignment => "center");
    $pdf->addHeader(fontSize=>8.0, text => "Header 2", alignment => "center");
    $pdf->addHeader(fontSize=>8.0, text => " ", alignment => "center");
    
    $pdf->addFooter(fontSize => 8.0, text => "Footer 1", alignment => "left");
    $pdf->addFooter(fontSize => 8.0, text => "Footing 2 on $curdate", alignment => "right", sameLine => 'T');
    $pdf->addFooter(fontSize => 8.0, text => "Page <page>", alignment => "center", sameLine => 'T');
    
    
    my $colCount = 12;
    my @colWidths = (30, 40, 40, 120, 50, 50, 50, 50, 50, 50, 50, 50);
    my @colAlign = ("center", "center", "center", "left", "center", "center", "center", "center", "center", "center", "center", "center");
    my @colTitles = ("ID", "Category", "External ID", "Commitment Text", "Status", "Original DOE Completion Due Date", "Revised DOE Completion Due Date", "Actual DOE Completion Date", "NRC Concurrence on Closure", "DOE Responsible Individual", "DOE Oversight", "BSC Responsible Manager");
    
    my $fontID = $pdf->setFont(font => "Times-Bold", fontSize => 10.0);
    $pdf->addHeaderRow(fontSize => 8, fontID => $fontID,
                           colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@colTitles);

#open FH1, "</data/dev/cgi-bin/framework/test-flow1.gif";
open FH1, "</data/dev/cgi-bin/framework/rsis.png";
#open FH1, "</data/dev/cgi-bin/framework/forest1.jpg";
my $data = "";
my $rc = read(FH1, $data, 100000000);
close FH1;
    #my $logo = $pdf->addImage(source=>'file', type=>'gif', fileName=>'/data/dev/cgi-bin/framework/rsis.gif');
    #my $logo = $pdf->addImage(source=>'file', type=>'gif', fileName=>'/data/dev/cgi-bin/framework/test.gif');
    #my $logo = $pdf->addImage(source=>'file', type=>'gif', fileName=>'/data/dev/cgi-bin/framework/test-flow1.gif');
    #my $logo = $pdf->addImage(source=>'file', type=>'png', fileName=>'/data/dev/cgi-bin/framework/rsis.png');
    #my $logo = $pdf->addImage(source=>'file', type=>'jpeg',fileName=>'/data/dev/cgi-bin/framework/rsis.jpg');
    #my $logo = $pdf->addImage(source=>'file', type=>'jpeg', fileName=>'/data/dev/cgi-bin/framework/forest1.jpg');
    #my $logo = $pdf->addImage(source=>'file', type=>'png', fileName=>'/data/dev/cgi-bin/framework/bigchart.png');
    my $logo = $pdf->addImage(source=>'memory', data=>$data);
    $pdf->placeHeaderImage(image=>$logo, alignment => 'left');    

    $pdf->newPage(orientation => 'landscape', useGrid => 'T');
    #$pdf->placeImage(image=>$logo, x => 200, y=> 200);    
    $pdf->placeImage(image=>$logo, x => 680, y=> 280);    

    $pdf->setFont(font => "Times-Bold", fontSize => 8.0);
    $pdf->setFont(font => "Times-Roman", fontSize => 8.0);


#    my $getstuff = $dbh -> prepare ("select c.commitmentid, c.text, c.externalid, c.fulfilldate, c.closeddate, c.statusid, r.lastname, s.workflow, s.description from $SCHEMA.commitment c, $SCHEMA.responsiblemanager r, $SCHEMA.status s where r.responsiblemanagerid(+)=c.managerid and s.statusid=c.statusid order by s.workflow, c.commitmentid");
#    $getstuff -> execute;
#    my $i = 0;
#    while (my ($cid, $ctext, $eid, $fdate, $cdate, $stat, $mgr, $sorder, $sdesc) = $getstuff -> fetchrow_array) {
#	$i++;
#
#	my $dyerstat;
#	if ($sorder == 1) {
#	    $dyerstat = "Potential commitment";
#	}
#	elsif ($sorder == 2) {
#	    $dyerstat = "Open";
#	}
#	elsif ($sorder == 3) {
#	    $dyerstat = "Complete";
#	}
#	else {
#	    $dyerstat = "Closed";
#	}
#
#        my @rowList;
#	$cid = "C" . substr("0000$cid",-5);
#        @rowList = ($cid, "Category", "External ID", $ctext, $dyerstat, $fdate, uc(&get_date()), $cdate, uc(&get_date()), "Someone", "Someone Else", $mgr);
#        my $fontSize = 8;
#        $lastLine = $pdf->tableRow(fontSize => $fontSize,
#                  colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@rowList );
#
#    }

#    $getstuff -> finish;    
    my $pdfBuff = $pdf->finish;

    #print $pdfcgi->header('application/text');

    print "Content-type: application/pdf\n";
    print "Content-disposition: inline; filename=testpfd.pdf\n";
    #print "Content-disposition: inline; filename=testpfd.pdf\n";
    #print "Content-type: application/pdf\n";
    print "\n";
    print $pdfBuff;


