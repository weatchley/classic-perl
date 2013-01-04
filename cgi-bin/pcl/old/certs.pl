#!/usr/local/bin/perl -w

# -*- Mode: perl; indent-tabs-mode: nil; -*-

# $Source: $
# $Revision: $
# $Date: $
# $Author: $
# $Locker: $
# $Log: $
#

use strict;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use PDF;
use pdflib_pl;

my $q = new CGI;

sub drawInterface {
    print $q->header("text/html");
    
    print <<input_EOF;

    <html>
    <head>
    	<script type="text/javascript">

	    function openWindow() {
	    	document.input.hidControl.value = 1;
		document.input.target = "_blank";
		document.input.submit();
	    }
	</script>

    
    </head>
    <body bgcolor="#ffffff">
    <br />
    <br />
    <form name="input" action="/cgi-bin/pcl/certs.pl" method="post">

    <input type="hidden" name="hidControl" value="0">

    <h2>Training Certificate Generator Input Form</h2>
    <table border="0" cellpadding="3" cellspacing="0">
    <tr><td>Training Title:</td>
        <td><input type="text" size="50" name="Title" value="Auditing A Software Baseline (1.0)"></td></tr>
    <tr>
    <td>Training Type:</td>
    <td><select name="Type"><option value="Procedure Review">Procedure Review</option></select></td></tr>
    
    <tr>
    <td>Date:</td>
    <td><input type="text" name="Date" size="10" value="10/21/2002"></td></tr>
    
    <tr>
    <td>Manager:</td>
    <td><input type="text" name="Manager" size="25" value="Ed Jorgenson"></td></tr>
    
    <tr>
    <td>Student Name:</td>
    <td><input type="text" name="StudentName" size="25" value="Brian Munroe"></td></tr>
    
    <tr>
    <td>Organization:</td>
    <td><input type="text" name="Organization" size="15" value="RSIS"></td></tr>
    
    <tr>
    <td>Position:</td>
    <td><input type="text" name="Position" size="25" value="Software Developer"></td></tr>
    
    <tr>
    <td>Course Desc:</td>
    <td><textarea name="CourseDesc" cols="20">I certify that I have completed the training requirements for this course, and understand its contents so that I am qualified to conduct the activities covered in this procedure.

I understand that I am expected to actively consult the procedure throughout my involvement to ensure compliance with its requirements.
    </textarea></td></tr>
    <tr><td colspan="2"><input type="button" value="submit" onClick="javascript:openWindow();"></td></tr>
    </table>
    </form>
    </body>
    </html>

input_EOF

}

sub generateCert {
    
    my $trainingTitle = $q->param("Title");
    my $trainingType = $q->param("Type");
    my $date = $q->param("Date");
    my $manager = $q->param("Manager");
    my $studentName = $q->param("StudentName");
    my $organization = $q->param("Organization");
    my $position = $q->param("Position");
    my $courseDesc = $q->param("CourseDesc");
    
    my $boilerPlate = "Procedure Entry Criteria require that participants have documented training relevant to their roles and responsibilities.  " 
                      ."This training is intended to ensure understanding and adherence to procedure requirements resulting in the " 
                      ."production of qualified outputs and the satisfaction of the procedure's exit criteria.\n\n"
                      ."Training is mandated by the RSIS software development training policy. Procedure related " 
                      ."training requirements are subject to ongoing review and revision independent of the procedure. A review " 
                      ."and understanding of the procedure itself is the primary training resource used to convey "
                      ."procedure-specific knowledge. It is designed to fully describe the requirements for its use, "
                      ."the sequential detailed activities for its conduct, and the resulting products, measurements, " 
                      ."documentation, and verification.";

    my $pdf = new PDF;
    $pdf->setup(orientation => 'portrait', useGrid => 'F', leftMargin => 0.5, rightMargin => 0.5, topMargin => 0.5, bottomMargin => 0.5);
    
    $pdf->setFont(font => "helvetica", fontSize => 10.0);
    $pdf->addHeader(fontSize=>14.0, text => "RSIS Certificate of Training Completion", alignment => "left");
    $pdf->addHeader(fontSize=>8.0, text => " ", alignment => "center");
    
    $pdf->newPage(font => "helvetica-bold", fontSize => 10.0, border => 0, orientation => 'portrait', useGrid => 'F');
    my $row = $pdf->tableRow(border=>1, colCount=>2, colWidths=>[75,425], colAlign=>["left","left"], row=>["\nTraining Title:","\n$trainingTitle\n"]);
    $row = $pdf->tableRow(border=>1, colCount=>2, colWidths=>[75,425], colAlign=>["left","left"], row=>["\nTraining Type:","\n$trainingType\n"]);
    $row = $pdf->tableRow(border=>0, colCount=>1, colWidths=>[500], colAlign=>["center"], row=>[""]);
    $row = $pdf->tableRow(border=>1, colCount=>2, colWidths=>[150,350], colAlign=>["left","left"], row=>["Date: $date\n\nManager: $manager","Student Name:\n\n$studentName\n$organization $position"]);
    $row = $pdf->tableRow(border=>0, colCount=>1, colWidths=>[500], colAlign=>["center"], row=>[""]);
    $row = $pdf->tableRow(border=>0,colCount=>1,colWidths=>[500], colAlign=>["left"], row=>["Course Description:\n\n$courseDesc"]);
    $row = $pdf->tableRow(border=>0, colCount=>1, colWidths=>[500], colAlign=>["center"], row=>[""]);
    $row = $pdf->tableRow(border=>0, colCount=>1, colWidths=>[500], colAlign=>["left"], row=>["Signature:_______________________________________________________________"]);
    $row = $pdf->tableRow(border=>0, colCount=>1, colWidths=>[500], colAlign=>["center"], row=>["\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"]);
    $row = $pdf->tableRow(border=>1, colCount=>1, colWidths=>[500], colAlign=>["left"], row=>["$boilerPlate"]);

    my $pdfBuff = $pdf->finish;

    print "Content-type: application/pdf\n";
    print "Content-disposition: inline; filename=training_cert.pdf\n";
    print "\n";
    print $pdfBuff;    
}

sub main {
    if ($q->param("hidControl") eq "1"){
	&generateCert();
    } else {
	&drawInterface();
    }
}

main();
