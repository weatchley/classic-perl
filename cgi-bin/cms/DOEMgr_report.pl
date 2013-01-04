#!/usr/local/bin/perl

# $Source: /data/dev/rcs/cms/perl/RCS/DOEMgr_report.pl,v $
# $Revision: 1.3 $
# $Date: 2003/01/02 22:43:54 $
# $Author: naydenoa $
# $Locker:  $
# $Log: DOEMgr_report.pl,v $
# Revision 1.3  2003/01/02 22:43:54  naydenoa
# Added report filtering by status, fulfillment date, and DOE responsible
# Reformatted data
# Added use of table HEADING for header display consistency
#
# Revision 1.2  2002/11/27 21:16:21  naydenoa
# Filtered commitments by status - displays only open commitments
# Added calls to getHeader for elements headers consistency
# Updated order of data elements display
#
# Revision 1.1  2002/10/25 16:38:48  naydenoa
# Initial revision
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

$SCHEMA = (defined($pdfcgi -> param("schema"))) ? $pdfcgi -> param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $pageNumber = 0;
my $command = ((defined($pdfcgi -> param('command'))) ? $pdfcgi -> param('command') : "makereport");
my $statuscheck = ((defined ($pdfcgi -> param('statuscheck'))) ? $pdfcgi -> param ('statuscheck') : 0);
my $selectstatus = ((defined ($pdfcgi -> param('selectstatus'))) ? $pdfcgi -> param ('selectstatus') : 0);
my $datecheck = ((defined ($pdfcgi -> param('datecheck'))) ? $pdfcgi -> param ('datecheck') : 0);
my $month_f = ((defined ($pdfcgi -> param('month_f'))) ? $pdfcgi -> param ('month_f') : 0);
my $year_f = ((defined ($pdfcgi -> param('year_f'))) ? $pdfcgi -> param ('year_f') : 0);
my $month_t = ((defined ($pdfcgi -> param('month_t'))) ? $pdfcgi -> param ('month_t') : 0);
my $year_t = ((defined ($pdfcgi -> param('year_t'))) ? $pdfcgi -> param ('year_t') : 0);
my $doecheck = ((defined ($pdfcgi -> param('doecheck'))) ? $pdfcgi -> param ('doecheck') : 0);
my $doeselect = ((defined ($pdfcgi -> param('doeselect'))) ? $pdfcgi -> param ('doeselect') : 0);
#print STDERR "$datecheck: $month_f $year_f - $month_t $year_t; $statuscheck - $selectstatus; $doecheck - $doeselect\n";
my $lastLine;
my $pageBottom;

my $dbh = oncs_connect();
my $statwhere = "";
if ($statuscheck eq "on" && $selectstatus == 1) {
    $statwhere = "c.statusid in (1, 2, 3, 4, 5, 6, 9, 10, 11, 12, 13, 14, 17, 18) and ";
}
elsif ($statuscheck eq "on" && $selectstatus == 2) {
    $statwhere = "c.statusid in (7, 8, 15, 16) and ";
}
my $datewhere = "";
my $startdate;
my $enddate;
if ($datecheck eq "on") {
    $startdate = "01-$month_f-$year_f";
    $enddate = "LAST_DAY('01-$month_t-$year_t')";
    $datewhere = "(c.fulfilldate between '$startdate' and $enddate) and ";
}
my $doewhere = "";
my $roletable = "";
if ($doeselect && $doecheck eq "on") {
    $doewhere = "cr.roleid = 3 and cr.usersid = $doeselect and c.commitmentid = cr.commitmentid and";
    $roletable = ", $SCHEMA.commitmentrole cr";
}
#print STDERR "$statwhere\n";
my $prepccount = "select count(*) from $SCHEMA.commitment c $roletable where $statwhere $doewhere $datewhere 1=1";
#print STDERR "$prepccount\n";
my $ccount = $dbh -> selectrow_array ($prepccount);
#print STDERR "$ccount\n";    

##############
sub get_date {    # routine to generate an oracle friendly date
##############
    my $indate = $_[0];
    my $outstring = '';
    my $day; 
    my $month; 
    my $year;
    my @months = ("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
    if (defined ($indate) && $indate gt ' ') {
        ($month, $day, $year) = split /\//, $indate;
        $month = $month -1;
    } else {
        ($day, $month, $year) = (localtime)[3,4,5];
        $year = $year + 1900;
    }
    $outstring .= "$day $months[$month] $year";
    return ($outstring);
}
######################
sub buildMonthSelect {
######################
    my %args = (
        name => "",
        @_,
    );
    my $outstr;
    $outstr .= "<select name=$args{name} onFocus=\"document.$form.datecheck.checked = true;\">\n";
    $outstr .= "<option value=JAN>January</option>\n";
    $outstr .= "<option value=FEB>February</option>\n";
    $outstr .= "<option value=MAR>March</option>\n";
    $outstr .= "<option value=APR>April</option>\n";
    $outstr .= "<option value=MAY>May</option>\n";
    $outstr .= "<option value=JUN>June</option>\n";
    $outstr .= "<option value=JUL>July</option>\n";
    $outstr .= "<option value=AUG>August</option>\n";
    $outstr .= "<option value=SEP>September</option>\n";
    $outstr .= "<option value=OCT>October</option>\n";
    $outstr .= "<option value=NOV>November</option>\n";
    $outstr .= "<option value=DEC>December</option>\n";
    $outstr .= "</select>\n";
    return ($outstr);
}


#########  main body  #########
if ($command ne "makereport") {
    # print form page
    print <<END_OF_BLOCK;

<html>
<head>
   <base target=main>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <title>Commitment Management System: DOE Licensing Manager Report - Set-up Screen</title>

<script language=javascript><!--
if (parent == self && command != "makereport") {
  location = '$ONCSCGIDir/login.pl';
}

    function submitFormCGIResults(script,command) {
	if (document.$form.datecheck.checked) {
//	    if (checkDate(document.$form.month_f[document.$form.month_f.selectedIndex].value, document.$form.year_f.value, document.$form.month_t[document.$form.month_t.selectedIndex].value, document.$form.year_t.value) == false) {
	    if (checkDate(document.$form.month_f, document.$form.year_f, document.$form.month_t, document.$form.year_t) == false) {
		return false;
	    }
	}
        document.$form.command.value = command;
        document.$form.action = '/cgi-bin/cms/' + script + '.pl';
        document.$form.target = 'control';
        document.$form.submit();	
    }
    function convertMonth(month) {
	var months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
	for (i = 0; i < months.length; i++) {
	    if (months[i] == month) {
		return (i+1);
	    }
	}
    }
    function checkDate (m1,y1,m2,y2) {	
	var year_f = parseInt(y1.value);
	var year_t = parseInt(y2.value);
	var month_f = m1.value;
	var month_t = m2.value;
	var month_f_numeric = convertMonth(month_f);
	var month_t_numeric = convertMonth(month_t);
	
	if (year_t < year_f) {
	    errmsg = "Date range is invalid (" + month_f + " " + year_f + " - " + month_t + " " + year_t + ")";
	    y1.focus();
	    y1.select();
 	    alert(errmsg);
	    return false;
	}
	if (month_t_numeric < month_f_numeric && year_t == year_f){
	    errmsg = "Date range is invalid (" + month_f + " " + year_f + " - " + month_t + " " + year_t + ")";
	    y1.focus();
	    y1.select();
 	    alert(errmsg);
	    return false;
	}
	if (year_f > 5000 || year_f < 1900 || isNaN(year_f) == true) { 
	    errmsg = y1.value + " is not a valid year";
	    y1.focus();
	    y1.select();
 	    alert(errmsg);
	    return false;
	}
	if (year_t > 5000 || year_t < 1900 || isNaN(year_t) == true) {
	    errmsg = y2.value + " is not a valid year";
	    y2.focus();
	    y2.select();
 	    alert(errmsg);
	    return false;
	}
    }
    function submitFormNewWindow(script, command) {
         var myDate = new Date();
         var winName = myDate.getTime();
         document.$form.action = '$path' + script + '.pl';
         document.$form.target = winName;
         var newwin = window.open("",winName);
         newwin.creator = self;
         document.$form.submit();
    //	newwin.focus();
    }
//-->
</script>
</head>

<body background=/eis/images/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>

<table border=0 align=center width=720><tr><td>
<form name=$form action=$ENV{SCRIPT_NAME} method=post>
END_OF_BLOCK
}


##############################
if ($command eq "adhoctest") {
    my $where = "";
    my $startdate;
    my $enddate;
    my $doeresp;
    my $status;
    print "<input type=hidden name=command value=makereport>\n";
    print "<input type=hidden name=month_f value=$month_f>\n";
    print "<input type=hidden name=year_f value=$year_f>\n";
    print "<input type=hidden name=month_t value=$month_t>\n";
    print "<input type=hidden name=year_t value=$year_t>\n";
    print "<input type=hidden name=selectstatus value=$selectstatus>\n";
    print "<input type=hidden name=doeselect value=$doeselect>\n";
    print "<input type=hidden name=statuscheck value=$statuscheck>\n";
    print "<input type=hidden name=datecheck value=$datecheck>\n";
    print "<input type=hidden name=doecheck value=$doecheck>\n";

#    print STDERR "-$datecheck -$month_f -$year_f -$month_t -$year_t -$statuscheck -$selectstatus -$doecheck -$doeselect\n";
    print "<script language=javascript><!--\n";
    if ($ccount) {
        print "    if (confirm('Found $ccount record" . (($ccount != 1) ? "s" : "") . ".\\nDo you wish to continue?')) {\n";
	print "        submitFormNewWindow('$form', 'makereport');\n";
	print "    };\n";
    }
    else {
	print "    alert ('The selection generated an empty report.');\n";
    }
    print "//-->\n";
    print "</script>\n";
}

###############################
if ($command eq "makereport") {
    $dbh -> {LongTruncOk} = 1;   # specify whole text or truncated fraction
    $dbh -> {LongReadLen} = 100000;

    my $pdf = new ReportWriterPDF;
    $pdf -> setup(orientation => 'portrait', useGrid => 'F', leftMargin => .5, rightMargin => .5, topMargin => .5, bottomMargin => .5);
    
    my $curdate = &get_date(); 
    $pdf -> setFont(font => "Times-Bold", fontSize => 10.0);
    $pdf -> addHeader(fontSize => 13.0, text => "Commitment Status Report", alignment => "center");
    $pdf -> addHeader(fontSize => 10.0, text => "Commitment Management System", alignment => "center");
    $pdf -> addHeader(fontSize => 10.0, text => "U.S. Department of Energy - Office of Civilan Radioactive Waste Management", alignment => "center");
    $pdf -> addHeader(fontSize => 10.0, text => " ", alignment => "center");
    
    $pdf -> addFooter(fontSize => 10.0, text => "Report Date: $curdate", alignment => "left");
    $pdf -> addFooter(fontSize => 10.0, text => "Page <page>", alignment => "right", sameLine => 'T');
    
    my $fontID = $pdf -> setFont(font => "Times-Bold", fontSize => 12.0);
    
    $pdf -> setFont(font => "Times-Bold", fontSize => 10.0);
    $pdf -> setFont(font => "Times-Roman", fontSize => 10.0);
    my $i=0;
    
    my $eidhead = &getHeading (dbh => $dbh, schema => $SCHEMA, lookup => "extid");
    my $stathead = &getHeading (dbh => $dbh, schema => $SCHEMA, lookup => "stat");
    my $fuldhead = &getHeading (dbh => $dbh, schema => $SCHEMA, lookup => "fuldate");
    my $comdhead = &getHeading (dbh => $dbh, schema => $SCHEMA, lookup => "comdate");
    my $comlethead = &getHeading (dbh => $dbh, schema => $SCHEMA, lookup => "comlet");
    my $closelethead = &getHeading (dbh => $dbh, schema => $SCHEMA, lookup => "closelet");
    my $cinfo = "select c.commitmentid, c.text, 
                    to_char(c.fulfilldate,'MM/DD/YYYY'), s.description, 
                    c.actionplan, c.actionsummary, c.actionstaken, 
                    c.externalid, to_char(c.commitdate,'MM/DD/YYYY'), 
                    cat.description, i.issueid,
                    i.text, c.estimate, s.statusid, c.doemanagerid 
             from $SCHEMA.commitment c, $SCHEMA.issue i, $SCHEMA.status s,
                  $SCHEMA.category cat $roletable 
             where $statwhere $doewhere $datewhere
                   s.statusid = c.statusid and
                   c.issueid=i.issueid and 
                   i.categoryid = cat.categoryid
             order by c.externalid, c.statusid";
    my $getstuff = $dbh -> prepare ($cinfo);
    $getstuff -> execute;
    my $i = 0;
    while (my ($cid, $text, $duedate, $status, $aplan, $asum, $ataken, $eid, $cdate, $icat, $iid, $itext, $estimate, $sid, $doemid) = $getstuff -> fetchrow_array) {
	my ($bscmgr, $bsclead) = $dbh -> selectrow_array ("select rm.firstname || ' ' || rm.lastname, u.firstname || ' ' || u.lastname from $SCHEMA.commitment c, $SCHEMA.responsiblemanager rm, $SCHEMA.users u where c.commitmentid = $cid and c.managerid = rm.responsiblemanagerid and c.lleadid = u.usersid");
	
	my ($doelead) = $dbh -> selectrow_array ("select u.firstname || ' ' || u.lastname from $SCHEMA.commitmentrole cr, $SCHEMA.users u where cr.commitmentid = $cid and cr.roleid=3 and cr.usersid=u.usersid");
	my ($doemgr) = ($doemid) ? $dbh -> selectrow_array ("select firstname || ' ' || lastname from $SCHEMA.responsiblemanager where responsiblemanagerid = $doemid") : "Not Available";

	my $duestring;
	my $dueexplain;
	my ($old, $new, $appacc, $reason, $changeapprover);
	my $duehist = $dbh -> prepare("select to_char(d.oldduedate,'MM/DD/YYYY'), to_char(d.newduedate,'MM/DD/YYYY'), d.approvalletteraccession, d.reason, u.firstname || ' ' || u.lastname from $SCHEMA.duedatehistory d, $SCHEMA.users u where d.commitmentid=$cid and d.datetype=2 and d.approver=u.usersid order by d.oldduedate desc");
	$duehist -> execute;
	while (($old, $new, $appacc, $reason, $changeapprover) = $duehist -> fetchrow_array) {
	    $duestring .= "$old\n";
	    $appacc = ($appacc) ? $appacc : "Not Available";
	    $dueexplain .= "- Fulfillment date changed from $old to $new. Change approved by $changeapprover. Change approval letter accession number: $appacc. Reason: $reason\n\n";
	}
	$duehist -> finish;
	my ($firstresponses, $closingresponses, $isfirst, $raccnum, $response);
	my $resplist = $dbh -> prepare ("select l.accessionnum, r.isfirst from $SCHEMA.letter l, $SCHEMA.response r where r.commitmentid=$cid and r.letterid=l.letterid");
	$resplist -> execute;
	while (($raccnum, $isfirst) = $resplist -> fetchrow_array) {
	    if ($raccnum) {
		$firstresponses .= "$raccnum, " if ($isfirst eq "T");
		$closingresponses .= "$raccnum, " if ($isfirst eq "F");
	    }
	    else {
		$firstresponses .= "Accession # Not Assigned, " if ($isfirst eq "T");
		$closingresponses .= "Accession # Not Assigned, " if ($isfirst eq "F");
	    }
	}
	$resplist -> finish;
	if ($firstresponses) {
	    chop ($firstresponses); 
	    chop ($firstresponses);
	}
	else {
	    $firstresponses = "Not Available";
	}
	if ($closingresponses) {
	    chop ($closingresponses); 
	    chop ($closingresponses);
	}
	else { 
	    $closingresponses = "Not Available";
	}
	$response = "$comlethead: $firstresponses\n$closelethead: $closingresponses\n";
	my $colCount = 2;
	my @colWidths = (260, 260);
	my @colAlign = ("left", "left");
	$pdf -> newPage(orientation => 'portrait', useGrid => 'F');
	$i++;
	my @rowList;
	my $formattedcid = "C" . substr("0000$cid",-5);
	$duestring = ($duestring) ? $duestring : "Not Applicable";
	$duedate = ($duedate) ? $duedate : "Not Available";
	$cdate = ($cdate) ? $cdate : "Not Available";
	$eid = ($eid) ? $eid : "Not Available";
	$bsclead = ($bsclead) ? $bsclead : "Not Available";
	$bscmgr = ($bscmgr) ? $bscmgr : "Not Available";
	$estimate = ($estimate) ? $estimate : "Not Available";
	$aplan = ($aplan) ?$aplan : "Not Available";
	$asum =  ($asum) ? $asum : "Not Available";
	$ataken = ($ataken) ? $ataken : "Not Available"; 
	$doemgr = ($doemgr) ? $doemgr : "Not Available";
	
	@rowList = ("$eidhead: $eid\n\nIssue Category: $icat\n$comdhead: $cdate\n\n", "$fuldhead: $duedate\n\nFulfillment Date History:\n$duestring\n\n");
	my $fontSize = 10;
	$lastLine = $pdf -> tableRow(fontSize => $fontSize, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@rowList );
	my $isopen = "Open";
	if ($sid == 7 || $sid == 8 || $sid == 15 || $sid == 16) {
	    $isopen = "Closed";
	}
	$colCount = 3;
	@colWidths = (260, 196, 56);
	my @colAlign = ("left", "center", "center");
	@rowList = ("$stathead: $isopen\n\n", "", "$formattedcid");
	$lastLine = $pdf -> tableRow(fontSize => $fontSize, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@rowList );
	my $colCount = 2;
	my @colWidths = (260, 260);
	my @colAlign = ("left", "left");
	@rowList = ("DOE Responsible: $doelead\n\n", "BSC Responsible: $bsclead\n\n");
	$lastLine = $pdf -> tableRow(fontSize => $fontSize, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@rowList );
	@rowList = ("DOE Manager: $doemgr\n\n", "BSC Manager: $bscmgr\n\n");
	$lastLine = $pdf -> tableRow(fontSize => $fontSize, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@rowList );
	
	$colCount = 1;
	@colWidths = (528);
	my @colAlign = ("left");
	my $assoccoms = "";
	my $getmorecoms = $dbh -> prepare ("select commitmentid from $SCHEMA.commitment where issueid = $iid and commitmentid != $cid");
	$getmorecoms -> execute;
	while (my ($morecoms) = $getmorecoms -> fetchrow_array) {
	    $assoccoms .= "C" . substr("0000$morecoms",-5) . ", ";
	}
	if ($assoccoms) {
	    chop ($assoccoms);
	    chop ($assoccoms);
	}
	else {
	    $assoccoms = "None";
	}
	$getmorecoms -> finish;
	my $formattediid = "I" . substr("0000$iid",-5);
	@rowList = ("Commitment Text:\n\n$text\n\n");
	$lastLine = $pdf -> tableRow(fontSize => $fontSize, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@rowList );
	@rowList = ("Notes and comments:\n\n- Related Correspondence Accession Numbers:\n$response\n\n- Estimate: $estimate\n\n$dueexplain");
	$lastLine = $pdf -> tableRow(fontSize => $fontSize, colCount => $colCount, colWidths => \@colWidths, colAlign => \@colAlign, row => \@rowList );
    }
    $getstuff -> finish;    
    my $pdfBuff = $pdf -> finish;
    
    print "Content-type: application/pdf\n";
    print "Content-disposition: inline; filename=testpfd.pdf\n";
    print "\n";
    print $pdfBuff;
    
}

##########################
if ($command eq "query") {

    print <<END_OF_BLOCK;
<input type=hidden name=command value="adhoctest">
<table width=650 align=center>
<tr><td><input type=checkbox name=statuscheck checked></td><td><b>Commitment Status:</b></td>
<td><select name=selectstatus onFocus="document.$form.statuscheck.checked = true;">
<option value=0>All
<option value=1 selected>Open
<option value=2>Closed
</select></td></tr>
<tr><td><input type=checkbox name=datecheck></td><td><b>Estimated Fulfillment Date:</b></td>
<td>
END_OF_BLOCK
    print &buildMonthSelect (name => "month_f");
    print "<input type=text size=4 maxlength=4 name=year_f onFocus=\"document.$form.datecheck.checked = true;\">&nbsp;&nbsp;through&nbsp;&nbsp;\n";
    print &buildMonthSelect (name => "month_t");
    print <<END_OF_BLOCK3;
    <input type=text size=4 maxlength=4 name=year_t onFocus="document.$form.datecheck.checked = true;"> (yyyy)</td></tr>
<tr><td><input type=checkbox name=doecheck></td><td><b>DOE Lead:</b></td>
<td><select name=doeselect onFocus="document.$form.doecheck.checked = true;">
<option value=0>All
END_OF_BLOCK3
    my $dbh = oncs_connect();
    my $doepeeps = $dbh -> prepare ("select unique u.usersid, u.firstname || ' ' || u.lastname, u.lastname from $SCHEMA.users u, $SCHEMA.defaultdisciplinerole dr where dr.roleid=3 and dr.usersid=u.usersid order by u.lastname");
    $doepeeps -> execute;
    while (my ($uid, $uname) = $doepeeps -> fetchrow_array) {
	print "<option value=$uid>$uname\n";
    }
    $doepeeps -> finish;
    &oncs_disconnect($dbh);
    print <<END_OF_BLOCK2;
</select></td></tr>
<tr><td colspan=3 align=center>(Note: If all checkboxes are unchecked, the resulting report will contain all CMS commitments)</td></tr>
<tr><td colspan=3 align=center><input type=button name=ad_hoc_submit value=Submit onClick="submitFormCGIResults('DOEMgr_report','adhoctest');"></td></tr>
</table>
</center>

END_OF_BLOCK2

}

&oncs_disconnect($dbh);

if ($command ne "makereport") {
    print "</form>\n";
    print "</td></tr></table>\n";
    print "</body>\n";
    print "</html>\n";
}

