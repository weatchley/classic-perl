#!/usr/local/bin/perl

use strict;
use CGI;
use PDF;

my $pdfcgi = new CGI;


$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $pageNumber = 0;

my $lastLine;
my $pageBottom;


###########
# main Body
###########

    my $pdf = new PDF;
    $pdf->setup(orientation => 'portrait', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5);
    #$pdf->setFont(font => "Times-Bold", fontSize => 10.0);
    #$pdf->setFont(font => "Courier", fontSize => 10.0);
    $pdf->setFont(font => "Helvetica", fontSize => 10.0);
    #$pdf->addHeader(fontSize=>11.0, text => "PDF Font - Times", alignment => "center");
    #$pdf->addHeader(fontSize=>11.0, text => "PDF Font - Courier", alignment => "center");
    $pdf->addHeader(fontSize=>11.0, text => "PDF Font - Helvetica", alignment => "center");
    
    my $colCount = 1;
    my @colWidths = (30);
    my @colAlign = ("center");
    my @colTitles = ("?");
    my $fontID = $pdf->setFont(font => "Times-Bold", fontSize => 10.0);
    $fontID = $pdf->setFont(font => "Courier", fontSize => 10.0);
    $fontID = $pdf->setFont(font => "Helvetica", fontSize => 10.0);


    $pdf->newPage(orientation => 'portrait', useGrid => 'F');

    #$pdf->setFont(font => "Times-Roman", fontSize => 8.0);
    #$pdf->setFont(font => "Courier", fontSize => 8.0);
    $pdf->setFont(font => "Helvetica", fontSize => 8.0);

    my $fontMap = "";
    @colWidths = (30,20,30,20,30,20,30,20);
    @colAlign = ("left", "left","left", "left","left", "left","left", "left");
    my @rowList;
    for (my $i=0; $i<64; $i++) {
        for (my $j=0; $j<4; $j++) {
            $fontMap = chr($i+($j*64));
            $rowList[($j*2)] = ($i+($j*64)) . " -> ";
            $rowList[($j*2+1)] = $fontMap;
            #my @rowList = (, );
        }
        $lastLine = $pdf->tableRow(fontSize => 8,
                   colCount => 8, colWidths => \@colWidths, colAlign => \@colAlign, row => \@rowList );
    }

    my $pdfBuff = $pdf->finish;

    print "Content-type: application/pdf\n";
    print "Content-disposition: inline; filename=testpfd.pdf\n";
    print "\n";
    print $pdfBuff;

