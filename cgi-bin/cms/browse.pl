#!/usr/local/bin/newperl
#
# $Source: /data/dev/rcs/cms/perl/RCS/browse.pl,v $
# $Revision: 1.25 $
# $Date: 2003/01/21 22:53:26 $
# $Author: naydenoa $
# $Locker:  $
# $Log: browse.pl,v $
# Revision 1.25  2003/01/21 22:53:26  naydenoa
# Changed date due to NRC with date due to originator - CREQ00024 - rework
#
# Revision 1.24  2003/01/03 00:30:08  naydenoa
# Added browse commitments by DOE manager and NRC due date
# CREQ00023, CREQ00024
#
# Revision 1.23  2002/11/13 20:43:07  naydenoa
# Corrected problem with date range validation
#
# Revision 1.22  2002/10/11 20:41:01  naydenoa
# Internal enhancement - updated sourcedoc information display
#
# Revision 1.21  2002/04/12 23:43:00  naydenoa
# Checkpoint
#
# Revision 1.20  2002/03/09 00:06:17  naydenoa
# Removed frames constraint
#
# Revision 1.19  2002/03/08 20:54:16  naydenoa
# Fixed forward to login screen when loading outside frames.
#
# Revision 1.18  2001/12/10 23:12:40  naydenoa
# Updated commitment display. Changed BSCLL to BSCDL
#
# Revision 1.17  2001/11/16 20:07:59  naydenoa
# Updated RIS links.
#
# Revision 1.16  2001/11/16 17:27:42  naydenoa
# Fixed LL & RM retrieval bug.
#
# Revision 1.15  2001/11/15 23:17:08  naydenoa
# Added action browse, updated commitment and user browse to accommodate
# new roles and actions.
#
# Revision 1.14  2001/06/01 23:09:13  naydenoa
# Updated user browse; checkpoint
#
# Revision 1.13  2001/05/11 21:40:15  naydenoa
# Updated user browse - removed privileges, added sys admin role
#
# Revision 1.12  2001/03/21 18:48:32  naydenoa
# Added more browse capabilities, consolidated some functions
#
# Revision 1.11  2001/01/30 23:14:43  naydenoa
# Added text of commitment to results, took out wbs and discipline
# Took out secondary discipline from details, added associated historicals
#
# Revision 1.10  2001/01/22 21:29:21  naydenoa
# Add Historical Browse
#
# Revision 1.9  2001/01/02 17:37:02  naydenoa
# Added associated commitments to issue details
#
# Revision 1.8  2000/12/19 17:59:45  naydenoa
# Re-arranged table rows for commitments,
# merged all browseDetails and openWindow subs
#
# Revision 1.7  2000/12/11 16:19:41  munroeb
# added fulfillment date to commitment details
#
# Revision 1.6  2000/11/14 23:13:12  munroeb
# fixed issue browse error
#
# Revision 1.5  2000/11/13 21:25:49  munroeb
# fixed minor bug in commitment statuses radio button
#
# Revision 1.4  2000/11/13 18:37:38  munroeb
# moved commitment statuses underneath commitments query page
#
# Revision 1.3  2000/11/11 00:53:11  munroeb
# added browse statuses, browse commitment letters features, and fixed
# commitment details to reflect changes to responses
#
# Revision 1.2  2000/10/05 22:32:25  munroeb
# modified so that usersid zero never shows up in users browse
#
# Revision 1.1  2000/10/05 17:49:02  munroeb
# Initial revision
#

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific;
use UI_Widgets;
use Edit_Screens;

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $dbh = oncs_connect();
$dbh->{LongTruncOk}=1;
$dbh->{LongReadLen}=$MaxBytesStored;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

@| = 1;

my $q = new CGI;

my $schema = $q->param("schema");
my $loginusername = $q->param("loginusername");
my $loginusersid = $q->param("loginusersid");
my $option = $q->param("option"); $option = "main" if !defined($option);
my $interface = $q->param("theinterface");
my $interfaceLevel = $q->param("interfaceLevel");
my $cgiaction = $q -> param ("cgiaction");

my $nodevelopers = '';
if ($CMSProductionStatus) {
    $nodevelopers = 'u.usersid < 1000 and ';
}

&drawHead();
&drawMain() if $option eq "main";
&drawQuery() if $option eq "query";
&drawResults() if $option eq "results";
&drawDetails() if $option eq "details";
&drawFoot();


##############
sub drawHead {
##############
print "content-type:  text/html\n\n";

print "<HTML>\n<HEAD>\n";
print "<TITLE>Commitment Management System - Browse</TITLE>\n\n";

print "<SCRIPT SRC=$ONCSJavaScriptPath/oncs-utilities.js></SCRIPT>\n";
print "<SCRIPT LANGUAGE=JavaScript1.2>\n";
if ($option ne "details") {
    print "if (parent == self) {\n";
    print "  location = '$ONCSCGIDir/login.pl';\n";
    print "}\n";
}
print <<eof_head;
function validateForm() {
    var itsallgood = true;
    var theinterface = document.browse.theinterface.value;
    if (theinterface == "keywords"  || theinterface == "category"  ||
        theinterface == "sitename"  || theinterface == "users"     ||
        theinterface == "statuses") { 
	return true; 
    }
    var errmsg = "";
    if (document.browse.issueid) {
        var id = document.browse.issueid.value;
        var issue = true;
    }
    if (document.browse.commitmentflag) {
        var id = document.browse.commitmentid.value;
        var commitment = true;
    }
    if (document.browse.actionflag) {
        var id = document.browse.commitmentid.value;
	//var actionid = document.browse.actionid.value;
        var action = true;
    }
    if (document.browse.letterflag) {
        var id = document.browse.commitmentid.value;
        var letter = true;
    }
    // this is for either the issue or the commitmentid
    if (document.browse.chkOption[1].checked == true) {
        if (issue) {
            if (id == "") {
                errmsg = "Please Enter an Issue ID";
                document.browse.issueid.focus();
                document.browse.issueid.select();
                alert(errmsg);
                return false;
            }
            if (isNaN(id) == true || id < 0) {
                errmsg = "issue " + id + " is not a valid id";
                document.browse.issueid.focus();
                document.browse.issueid.select();
                alert(errmsg);
                return false;
            }
            document.browse.issueid.value = id;
        }
        if (commitment || letter || action) {
            if (id == "") {
                errmsg = "Please Enter a Commitment ID";
                document.browse.commitmentid.focus();
                document.browse.commitmentid.select();
                alert(errmsg);
                return false;
            }
            if (isNaN(id) == true || id < 0) {
                errmsg = "commitment " + id + " is not a valid id";
                document.browse.commitmentid.focus();
                document.browse.commitmentid.select();
                alert(errmsg);
                return false;
            }
            document.browse.commitmentid.value = id;
        }
    }
    // this is to check the dateoccurred field for issues, commitments, actions
    if ((document.browse.chkOption[2].checked == true && issue) || (document.browse.chkOption[2].checked == true && commitment) || (document.browse.chkOption[2].checked == true && action)) {
	itsallgood = checkDate (document.browse.dateoccurred_year_f,document.browse.dateoccurred_month_f,document.browse.dateoccurred_year_t,document.browse.dateoccurred_month_t);
    }
    // letter sent date check
    if (document.browse.chkOption[2].checked == true && letter) {
	itsallgood = checkDate (document.browse.sentdate_year_f,document.browse.sentdate_month_f,document.browse.sentdate_year_t,document.browse.sentdate_month_t.value);
    }
    // issue entry date check
    if (document.browse.chkOption[3].checked == true && issue) {
	itsallgood = checkDate (document.browse.dateentered_year_f, document.browse.dateentered_month_f, document.browse.dateentered_year_t, document.browse.dateentered_month_t);
    }
    if (document.browse.chkOption[3] && document.browse.chkOption[3].checked == true && letter) {
	itsallgood = checkDate (document.browse.signeddate_year_f,document.browse.signeddate_month_f,document.browse.signeddate_year_t,document.browse.signeddate_month_t);
    }
    // commitment fulfillment date check
    if (commitment && document.browse.chkOption[8].checked == true) {
	itsallgood = checkDate (document.browse.fuldate_year_f, document.browse.fuldate_month_f, document.browse.fuldate_year_t, document.browse.fuldate_month_t);
    }
    // commitment approval date check
    if (commitment && document.browse.chkOption[9].checked == true) {
	itsallgood = checkDate (document.browse.appdate_year_f, document.browse.appdate_month_f, document.browse.appdate_year_t, document.browse.appdate_month_t);
    }
    // commitment closing date check
    if (commitment && document.browse.chkOption[10].checked == true) {
	itsallgood = checkDate (document.browse.closedate_year_f, document.browse.closedate_month_f, document.browse.closedate_year_t, document.browse.closedate_month_t);
    }
    // commitment NRC date check
    if (commitment && document.browse.chkOption[15].checked == true) {
	itsallgood = checkDate (document.browse.nrcdate_year_f, document.browse.nrcdate_month_f, document.browse.nrcdate_year_t, document.browse.nrcdate_month_t);
    }
    return (itsallgood);
}
// End of validateForm function

function convertMonth(month) {
    var months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    for (i = 0; i < months.length; i++) {
        if (months[i] == month) {
            return (i+1);
        }
    }
}
function checkDate (y1,m1,y2,m2) {
    var year_f = parseInt(y1.value);
    var year_t = parseInt(y2.value);
    var month_f = m1.value;
    var month_t = m2.value;
    var i = 0;
    var month_f_numeric;
    var month_t_numeric;

    var months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

    month_f_numeric = convertMonth(month_f);
    month_t_numeric = convertMonth(month_t);

    if (year_t < year_f) {
	errmsg = "date range is invalid (" + month_f + " " + year_f + " - " + month_t + " " + year_t + ")";
	y1.focus();
	y1.select();
	alert(errmsg);
	return false;
    }
    if (month_t_numeric < month_f_numeric && year_t == year_f){
	errmsg = "date range is invalid (" + month_f + " " + year_f + " - " + month_t + " " + year_t + ")";
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
</SCRIPT>
eof_head

print "<SCRIPT LANGUAGE=JavaScript1.2>\n";
print "function browseDetails(theinterface, interfaceLevel, id) {\n";
print "\t document.browse.option.value = \'details\'\;\n";
print "\t document.browse.theinterface.value = theinterface\;\n";
print "\t document.browse.interfaceLevel.value = interfaceLevel\;\n";
print "\t document.browse.id.value = id\;\n";
print "\t document.browse.submit()\;\n";
print "}\n\n";

print "function openWindow(image) {\n";
print "\t window.open(image,\"image_window\",\"height=500,width=700,scrollbars=yes,resizable=yes\");\n";
print "}\n\n";

print "function browseAction(actionid, commitmentid) {\n";
print "    document.$form.option.value = \'details\';\n";
print "    document.$form.theinterface.value = \'actions\';\n";
print "    document.$form.interfaceLevel.value = \'actionid\';\n";
print "    document.$form.id.value = commitmentid;\n";
print "    document.$form.actionid.value = actionid;\n";
print "    document.$form.submit();\n";
print "}\n";

print "</SCRIPT>\n";
print<<eof_head_too;
</HEAD>
<BODY BACKGROUND=/cms/images/background.gif TEXT=#000099 LINK=#0000FF VLINK=#0000FF ALINK=#0000FF TOPMARGIN=0 LEFTMARGIN=0>
<FORM NAME=browse METHOD=POST onSubmit='return validateForm();'>
<INPUT TYPE=HIDDEN NAME=loginusersid VALUE=$loginusersid>
<INPUT TYPE=HIDDEN NAME=loginusername VALUE=$loginusername>
<INPUT TYPE=HIDDEN NAME=schema VALUE=$schema>
<!-- End of drawHead -->
eof_head_too
}

##############
sub drawFoot {
##############
    print "</FORM><BR><BR></BODY></HTML>\n";
    print "<!-- End of drawFoot -->";
}

##############
sub drawMain {
##############
print <<eof_main;
<SCRIPT LANGUAGE="JavaScript1.2">
if (parent.titlebar) {
    doSetTextImageLabel('Browse');
}
function browse(theinterface, interfaceLevel) {
    document.browse.theinterface.value = theinterface;
    document.browse.submit();
}
</SCRIPT>
<INPUT TYPE=HIDDEN NAME=option VALUE=query>
<INPUT TYPE=HIDDEN NAME=theinterface VALUE=>
<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=>
<CENTER><BR>
<TABLE BORDER=0><TR><TD>
<TABLE WIDTH=250 BORDER=0 CELLSPACING=0 CELLPADDING=3>
<TR><TD COLSPAN=2 VALIGN=TOP>
<FONT SIZE=4><LI><A HREF="javascript:browse('issues');">Issues</A></LI><BR><BR>
<LI><A HREF="javascript:browse('commitments');">Commitments</A></LI><BR><BR>
<li><a href="javascript:browse('actions');">Actions</a></li><br><br>
<LI><A HREF="javascript:browse('letters');">Commitment Letters</A></LI></FONT>
<BR><BR></TD></TR>
<TR><TD COLSPAN=2 VALIGN=TOP>
<FONT SIZE=4><LI><B>Issues and Commitments by:</B></LI></FONT>
</TD></TR>
<TR><TD>&nbsp;</TD><TD VALIGN=TOP><FONT SIZE=4>
<LI><A HREF="javascript:browse('keywords');">Keywords</A></LI>
<LI><A HREF="javascript:browse('category');">Category</A></LI>
<LI><A HREF="javascript:browse('sitename');">Site</A></LI>
</FONT></TD></TR>
<TR><TD COLSPAN=2 VALIGN=TOP><FONT SIZE=4><BR>
<LI><A HREF="javascript:browse('users');">Users</A></LI>
</FONT></TD></TR></TABLE></TD></TR></TABLE>
<!-- End of drawMain -->
eof_main
}

###############
sub drawQuery {
###############
    &drawQuery_Issues() if $interface eq "issues";
    &drawQuery_Commitments() if $interface eq "commitments";
    &drawQuery_Keywords() if $interface eq "keywords";
    &drawQuery_Category() if $interface eq "category";
    &drawQuery_SiteName() if $interface eq "sitename";
    &drawQuery_Users() if $interface eq "users";
    &drawQuery_Letters() if $interface eq "letters";
    &drawQuery_Statuses() if $interface eq "statuses";
    &drawQuery_Actions() if $interface eq "actions";
}

######################
sub drawQuery_Issues {
######################

my ($interface, $id, $i, $show_state) = @_;
my ($javascript_show_state, $month_f, $year_f, $month_t, $year_t);
if ($show_state) {
    if ($interface eq "issueid") {
        $javascript_show_state = "<SCRIPT>document.browse.chkOption[$i].checked = true; document.browse.$interface.value = '$id'; document.browse.$interface.focus();</SCRIPT>";
    }
    if ($interface eq "dateoccurred") {
        ($month_f, $year_f, $month_t, $year_t) = split(/:/, $id);
	$javascript_show_state = "
    <SCRIPT>
    months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    function convertMonth(month) {
        for (i = 0; i < months.length; i++) {
            if (months[i] == month) {
                return i;
            }
        }
    }
    d = document.browse;
    d.chkOption[$i].checked = true;
    d.dateoccurred_month_f[convertMonth('$month_f')].selected = true;
    d.dateoccurred_year_f.value = '$year_f';
    d.dateoccurred_month_t[convertMonth('$month_t')].selected = true;
    d.dateoccurred_year_t.value = '$year_t'; </SCRIPT>;
    </SCRIPT>
    ";
    }
    if ($interface eq "dateentered") {
        ($month_f, $year_f, $month_t, $year_t) = split(/:/, $id);
	$javascript_show_state = "
    <SCRIPT>
    months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    function convertMonth(month) {
        for (i = 0; i < months.length; i++) {
            if (months[i] == month) {
                return i;
            }
        }
    }
    d = document.browse;
    d.chkOption[$i].checked = true;
    d.dateentered_month_f[convertMonth('$month_f')].selected = true;
    d.dateentered_year_f.value = '$year_f';
    d.dateentered_month_t[convertMonth('$month_t')].selected = true;
    d.dateentered_year_t.value = '$year_t'; </SCRIPT>;
    </SCRIPT>
    ";
    }
}
print <<eof_drawIssuesInterface;

<INPUT TYPE=HIDDEN NAME=option VALUE=results>
<INPUT TYPE=HIDDEN NAME=theinterface VALUE=issues>
<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=all>
<SCRIPT LANGUAGE=JavaScript1.2>
    function setRadio(theinterface, interfaceLevel, option, i) {
        document.browse.chkOption[i].checked = true;
        document.browse.option.value = option;
        document.browse.theinterface.value = theinterface;
        document.browse.interfaceLevel.value = interfaceLevel;
    }
if (parent.titlebar) {
    doSetTextImageLabel('Browse Issues');
}
</SCRIPT>
<CENTER><BR>
<TABLE WIDTH=580 BORDER=0>
<TR>
<TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=0 CHECKED onFocus="setRadio(\'issues\', \'all\', \'results\', 0);"></TD>
<TD WIDTH=130><B>All Issues</B></TD></TR>
<TR>
<TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption onFocus="setRadio(\'issues\', \'issueid\', \'results\', 1);" VALUE=1></TD>
<TD><B>Issue ID</B></TD>
<TD><B>I </B><INPUT TYPE=TEXT SIZE=5 MAXLENGTH=5 NAME=issueid onFocus="setRadio(\'issues\', \'issueid\', \'results\', 1);"></TD></TR>
<TR>
<TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption onFocus="setRadio(\'issues\', \'dateoccurred\', \'results\', 2);" VALUE=4></TD>
<TD><B>Date Occurred</B></TD>
<TD VALIGN=MIDDLE>
    <SELECT NAME=dateoccurred_month_f onFocus="setRadio(\'issues\', \'dateoccurred\', \'results\', 2);" >
    <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
    <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
    <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
    <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
    <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
    <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
    </SELECT>
    <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=dateoccurred_year_f
          onFocus="setRadio(\'issues\', \'dateoccurred\', \'results\', 2);" >
through
    <SELECT NAME=dateoccurred_month_t onFocus="setRadio(\'issues\', \'dateoccurred\', \'results\', 2);" >
    <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
    <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
    <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
    <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
    <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
    <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
    </SELECT>

    <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=dateoccurred_year_t
         onFocus="setRadio(\'issues\', \'dateoccurred\', \'results\', 2);" > (yyyy)</TD></TR>
<TR>
<TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption onFocus="setRadio(\'issues\', \'dateentered\', \'results\', 3);" VALUE=5></TD>
<TD><B>Date Entered</B></TD>
<TD VALIGN=MIDDLE>
    <SELECT NAME=dateentered_month_f onFocus="setRadio(\'issues\', \'dateentered\', \'results\', 3);" >
    <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
    <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
    <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
    <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
    <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
    <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
    </SELECT>
    <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=dateentered_year_f
          onFocus="setRadio(\'issues\', \'dateentered\', \'results\', 3);" >
through
    <SELECT NAME=dateentered_month_t onFocus="setRadio(\'issues\', \'dateentered\', \'results\', 3);" >
    <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
    <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
    <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
    <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
    <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
    <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
    </SELECT>

    <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=dateentered_year_t
         onFocus="setRadio(\'issues\', \'dateentered\', \'results\', 3);" > (yyyy)</TD></TR>
<TR><TD COLSPAN=5><BR>
<CENTER><INPUT TYPE=SUBMIT VALUE=Submit><BR><BR>
</TD></TR></TABLE></CENTER>
<!-- Talk about hackerware! -->
$javascript_show_state
<!-- End of drawQuery_Issues -->
eof_drawIssuesInterface
}

###########################
sub drawQuery_Commitments {
###########################
    my ($interface, $id, $i, $show_state) = @_;
    my ($javascript_show_state, $month_f, $year_f, $month_t, $year_t);
    my ($wbs, $status_select);
    if ($show_state) {
        if ($interface eq "commitmentid") {
            $javascript_show_state = "<SCRIPT>document.browse.chkOption[$i].checked = true; document.browse.$interface.value = '$id'; document.browse.$interface.focus();</SCRIPT>";
        }
        if ($interface eq "dateoccurred") {
            ($month_f, $year_f, $month_t, $year_t) = split(/:/, $id);
            $javascript_show_state = "
            <SCRIPT>
            months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
            function convertMonth(month) {
                for (i = 0; i < months.length; i++) {
                    if (months[i] == month) {
                        return i;
                    }
                }
            }
            d = document.browse;
            d.chkOption[$i].checked = true;
            d.dateoccurred_month_f[convertMonth('$month_f')].selected = true;
            d.dateoccurred_year_f.value = '$year_f';
            d.dateoccurred_month_t[convertMonth('$month_t')].selected = true;
            d.dateoccurred_year_t.value = '$year_t'; </SCRIPT>;
            </SCRIPT>
            ";
        } ## end of dateoccurred
        if ($interface eq "fuldate") {
            ($month_f, $year_f, $month_t, $year_t) = split(/:/, $id);
            $javascript_show_state = "
        <SCRIPT>
        months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
        function convertMonth(month) {
            for (i = 0; i < months.length; i++) {
                if (months[i] == month) {
                    return i;
                }
            }
        }
        d = document.browse;
        d.chkOption[$i].checked = true;
        d.fuldate_month_f[convertMonth('$month_f')].selected = true;
        d.fuldate_year_f.value = '$year_f';
        d.fuldate_month_t[convertMonth('$month_t')].selected = true;
        d.fuldate_year_t.value = '$year_t'; </SCRIPT>;
        </SCRIPT>
        ";
        } ## end of dateoccurred
        if ($interface eq "appdate") {
            ($month_f, $year_f, $month_t, $year_t) = split(/:/, $id);
            $javascript_show_state = "
        <SCRIPT>
        months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
        function convertMonth(month) {
            for (i = 0; i < months.length; i++) {
                if (months[i] == month) {
                    return i;
                }
            }
        }
        d = document.browse;
        d.chkOption[$i].checked = true;
        d.appdate_month_f[convertMonth('$month_f')].selected = true;
        d.appdate_year_f.value = '$year_f';
        d.appdate_month_t[convertMonth('$month_t')].selected = true;
        d.appdate_year_t.value = '$year_t'; </SCRIPT>;
        </SCRIPT>
        ";
        } ## end of date approved
        if ($interface eq "closedate") {
            ($month_f, $year_f, $month_t, $year_t) = split(/:/, $id);
            $javascript_show_state = "
        <SCRIPT>
        months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
        function convertMonth(month) {
            for (i = 0; i < months.length; i++) {
                if (months[i] == month) {
                    return i;
                }
            }
        }
        d = document.browse;
        d.chkOption[$i].checked = true;
        d.closedate_month_f[convertMonth('$month_f')].selected = true;
        d.closedate_year_f.value = '$year_f';
        d.closedate_month_t[convertMonth('$month_t')].selected = true;
        d.closedate_year_t.value = '$year_t'; </SCRIPT>;
        </SCRIPT>
        ";
        } ## end of date closed
        if ($interface eq "nrcdate") {
            ($month_f, $year_f, $month_t, $year_t) = split(/:/, $id);
            $javascript_show_state = "
        <SCRIPT>
        months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
        function convertMonth(month) {
            for (i = 0; i < months.length; i++) {
                if (months[i] == month) {
                    return i;
                }
            }
        }
        d = document.browse;
        d.chkOption[$i].checked = true;
        d.nrcdate_month_f[convertMonth('$month_f')].selected = true;
        d.nrcdate_year_f.value = '$year_f';
        d.nrcdate_month_t[convertMonth('$month_t')].selected = true;
        d.nrcdate_year_t.value = '$year_t'; </SCRIPT>;
        </SCRIPT>
        ";
        } ## end of date closed
        if ($interface eq "wbs") {
            $javascript_show_state = "
                <SCRIPT>
                function getWBSIndex(wbs) {
                    for (i = 0; i < document.browse.wbs.length; i++) {
                        if (document.browse.wbs[i].value == wbs) {
                            return i;
                        }
                    }
                }
                document.browse.chkOption[$i].checked = true;
                document.browse.wbs[getWBSIndex('$id')].selected = true;

             </SCRIPT>";
        } ## end of wbs
        if ($interface eq "discipline") {
            $javascript_show_state = "
                <SCRIPT>
                function getDisciplineIndex(discipline) {
                    for (i = 0; i < document.browse.discipline.length; i++) {
                        if (document.browse.discipline[i].value == discipline){
                            return i;
                        }
                    }
                }
                document.browse.chkOption[$i].checked = true;
                document.browse.discipline[getDisciplineIndex('$id')].selected = true;

             </SCRIPT>";
        } ## end of discipline
        if ($interface eq "productaffected") {
            $javascript_show_state = "
                <SCRIPT>
                function getProductIndex(productaffected) {
                    for (i=0; i<document.browse.productaffected.length; i++) {
                        if (document.browse.productaffected[i].value == productaffected) {
                            return i;
                        }
                    }
                }
                document.browse.chkOption[$i].checked = true;
                document.browse.productaffected[getProductIndex('$id')].selected = true;
             </SCRIPT>";
        } ## end of product affected
        if ($interface eq "commitmentlevel") {
            $javascript_show_state = "
                <SCRIPT>
                function getCommitmentLevelIndex(commitmentlevel) {
                    for (i=0; i<document.browse.commitmentlevel.length; i++) {
                        if (document.browse.commitmentlevel[i].value == commitmentlevel) {
                            return i;
                        }
                    }
                }
                document.browse.chkOption[$i].checked = true;
                document.browse.commitmentlevel[getCommitmentLevelIndex('$id')].selected = true;
             </SCRIPT>";
        } ## end of commitment level
        if ($interface eq "status") {
            $javascript_show_state = "
                <SCRIPT>
                function getStatusIndex(status) {
                    for (i = 0; i < document.browse.status.length; i++) {
                        if (document.browse.status[i].value == status) {
                            return i;
                        }
                    }
                }
                document.browse.chkOption[$i].checked = true;
                document.browse.status[getStatusIndex('$id')].selected = true;
             </SCRIPT>";
        } ## end of statuses
        if ($interface eq "licensinglead") {
            $javascript_show_state = "
                <SCRIPT>
                function getLicensingLeadIndex(licensinglead) {
                    for (i = 0; i < document.browse.licensinglead.length;i++) {
                        if (document.browse.licensinglead[i].value == licensinglead){
                            return i;
                        }
                    }
                }
                document.browse.chkOption[$i].checked = true;
                document.browse.licensinglead[getLicensingLeadIndex('$id')].selected = true;

             </SCRIPT>";
        } ## end of licensinglead
        if ($interface eq "responsiblemanager") {
            $javascript_show_state = "
                <SCRIPT>
                function getRMIndex(responsiblemanager) {
                    for (i = 0; i < document.browse.responsiblemanager.length; i++) {
                        if (document.browse.responsiblemanager[i].value == responsiblemanager){
                            return i;
                        }
                    }
                }
                document.browse.chkOption[$i].checked = true;
                document.browse.responsiblemanager[getRMIndex('$id')].selected = true;

             </SCRIPT>";
        } ## end of responsiblemanager
        if ($interface eq "doeresponsiblemanager") {
            $javascript_show_state = "
                <SCRIPT>
                function getRMIndex(doeresponsiblemanager) {
                    for (i = 0; i < document.browse.doeresponsiblemanager.length; i++) {
                        if (document.browse.doeresponsiblemanager[i].value == doeresponsiblemanager){
                            return i;
                        }
                    }
                }
                document.browse.chkOption[$i].checked = true;
                document.browse.doeresponsiblemanager[getRMIndex('$id')].selected = true;

             </SCRIPT>";
        } ## end of doeresponsiblemanager
        if ($interface eq "externalid") {
            $javascript_show_state = "<SCRIPT>document.browse.chkOption[$i].checked = true; document.browse.$interface.value = '$id'; document.browse.$interface.focus();</SCRIPT>";
        }
    }
    my ($sql, $sth, $id, $description, $discipline_select);
    my ($product_affected_select, $commitment_level_select, $wbs_select);
    my ($ll_select, $rm_select, $doe_rm_select, $name);

    ## Lookup query for Work Break Down structure
    $sql = "select controlaccountid, controlaccountid || ' - ' || description from $schema.workbreakdownstructure order by controlaccountid";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($id, $description) = $sth->fetchrow_array()) {
        $wbs_select = $wbs_select."<OPTION VALUE=$id>" . getDisplayString ($description, 65) . "</OPTION>\n";
    }
    ## Lookup query for Discipline
    $sql = "select disciplineid, description from $schema.discipline order by description";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($id, $description) = $sth->fetchrow_array()) {
        $discipline_select = $discipline_select."<OPTION VALUE=$id>$description</OPTION>\n";
    }
    ## Lookup query for Product Affected
    $sql = "select productid, description from $schema.product order by productid";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($id, $description) = $sth->fetchrow_array()) {
        $product_affected_select = $product_affected_select."<OPTION VALUE=$id>$description</OPTION>\n";
    }
    ## Lookup query for Commitment Level
    $sql = "select commitmentlevelid, description from $schema.commitmentlevel order by description";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($id, $description) = $sth->fetchrow_array()) {
        $commitment_level_select = $commitment_level_select."<OPTION VALUE=$id>$description</OPTION>\n";
    }
    $sth->finish();
    ## Lookup query for Commitment Statuses
    $sql ="select statusid, description from $schema.status order by statusid";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    $status_select = "<OPTION VALUE=open>Any Open Commitments</OPTION><OPTION VALUE=closed>Any Closed Commitments</OPTION>";
    while (($id, $description) = $sth->fetchrow_array()) {
        $status_select = $status_select."<OPTION VALUE=$id>$description</OPTION>\n";
    }
    ## Lookup query for BSC Discipline Lead
    $sql = "select distinct u.usersid, u.firstname || ' ' || u.lastname, u.lastname from $schema.users u, $schema.defaultsiterole dsr where dsr.roleid=2 and dsr.usersid = u.usersid order by u.lastname";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($id, $name) = $sth->fetchrow_array()) {
        $ll_select = $ll_select."<OPTION VALUE=$id>$name</OPTION>\n";
    }
    ## Lookup query for BSC Responsible Manager
    $sql = "select responsiblemanagerid, firstname || ' ' || lastname from $schema.responsiblemanager where managertypeid = 1 order by lastname";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($id, $name) = $sth->fetchrow_array()) {
        $rm_select = $rm_select."<OPTION VALUE=$id>$name</OPTION>\n";
    }
    ## Lookup query for DOE Responsible Manager
    $sql = "select responsiblemanagerid, firstname || ' ' || lastname from $schema.responsiblemanager where managertypeid = 2 order by lastname";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($id, $name) = $sth->fetchrow_array()) {
        $doe_rm_select = $doe_rm_select."<OPTION VALUE=$id>$name</OPTION>\n";
    }
    $sth->finish();

    print <<eof_drawCommitmentsInterface;
<CENTER>
<INPUT TYPE=HIDDEN NAME=option VALUE=results>
<INPUT TYPE=HIDDEN NAME=theinterface VALUE=commitments>
<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=all>
<INPUT TYPE=HIDDEN NAME=commitmentflag VALUE=true>

<SCRIPT LANGUAGE=JavaScript1.2>
function setRadio(theinterface, interfaceLevel, option, i) {
    document.browse.chkOption[i].checked = true;
    document.browse.option.value = option;
    document.browse.theinterface.value = theinterface;
    document.browse.interfaceLevel.value = interfaceLevel;
}
if (parent.titlebar) {
    doSetTextImageLabel('Browse Commitments');
}
</SCRIPT>
<TABLE WIDTH=650 BORDER=0><TR>
<TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=0 CHECKED onFocus='setRadio(\"commitments\", \"all\", \"results\", 0);'></TD>
<TD WIDTH=190><B>All Commitments</B></TD>
<TD></TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=1 onFocus='setRadio(\"commitments\", \"commitmentid\", \"results\", 1);return false;'></TD>
<TD><B>Commitment ID</B></TD>
<TD><B>C </B><INPUT TYPE=TEXT SIZE=5 MAXLENGTH=5 NAME=commitmentid onFocus='setRadio(\"commitments\", \"commitmentid\", \"results\", 1);'></TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=2 onFocus='setRadio(\"commitments\", \"dateoccurred\", \"results\", 2);'></TD>
<TD><B>Due Date</B></TD>
<TD COLSPAN=4 VALIGN=MIDDLE>
  <SELECT NAME=dateoccurred_month_f  onFocus='setRadio(\"commitments\", \"dateoccurred\", \"results\", 2);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=dateoccurred_year_f onFocus='setRadio(\"commitments\",\"dateoccurred\",\"results\",2);'>
through
  <SELECT NAME=dateoccurred_month_t  onFocus='setRadio(\"commitments\", \"dateoccurred\", \"results\", 2);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=dateoccurred_year_t  onFocus='setRadio(\"commitments\", \"dateoccurred\", \"results\", 2);'> (yyyy)</TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=3  onFocus='setRadio(\"commitments\", \"wbs\", \"results\", 3);'></TD>
<TD><B>WBS</B></TD>
<TD><SELECT NAME=wbs onFocus='setRadio(\"commitments\", \"wbs\", \"results\", 3);'>
$wbs_select</SELECT></TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=4 onFocus='setRadio(\"commitments\", \"discipline\", \"results\", 4);'></TD>
<TD><B>Discipline</B></TD>
<TD><SELECT NAME=discipline onFocus='setRadio(\"commitments\", \"discipline\", \"results\", 4);'>
$discipline_select</SELECT></TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=5  onFocus='setRadio(\"commitments\", \"productaffected\", \"results\", 5);'></TD>
<TD><B>Affected Products</B></TD>
<TD COLSPAN=3><SELECT NAME=productaffected onFocus='setRadio(\"commitments\", \"productaffected\", \"results\", 5);'>
$product_affected_select</SELECT></TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=6  onFocus='setRadio(\"commitments\", \"commitmentlevel\", \"results\", 6);'></TD>
<TD><B>Commitment Level</B></TD>
<TD COLSPAN=3><SELECT NAME=commitmentlevel onFocus='setRadio(\"commitments\", \"commitmentlevel\", \"results\", 6);'>
$commitment_level_select</SELECT></TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=7 onFocus='setRadio(\"commitments\", \"status\", \"results\", 7);'></TD>
<TD><B>Commitment Status</B></TD>
<TD><SELECT NAME=status onFocus='setRadio(\"commitments\", \"status\", \"results\", 7);'>
$status_select
</SELECT></TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=8 onFocus='setRadio(\"commitments\", \"fuldate\", \"results\", 8);'></TD>
<TD><B>Fulfillment Date</B></TD>
<TD COLSPAN=4 VALIGN=MIDDLE>
  <SELECT NAME=fuldate_month_f  onFocus='setRadio(\"commitments\", \"fuldate\", \"results\", 8);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=fuldate_year_f onFocus='setRadio(\"commitments\",\"fuldate\",\"results\",8);'>
through
  <SELECT NAME=fuldate_month_t  onFocus='setRadio(\"commitments\", \"fuldate\", \"results\", 8);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=fuldate_year_t  onFocus='setRadio(\"commitments\", \"fuldate\", \"results\", 8);'> (yyyy)</TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=9 onFocus='setRadio(\"commitments\", \"appdate\", \"results\", 9);'></TD>
<TD><B>Approval Date</B></TD>
<TD COLSPAN=4 VALIGN=MIDDLE>
  <SELECT NAME=appdate_month_f  onFocus='setRadio(\"commitments\", \"appdate\", \"results\", 9);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=appdate_year_f onFocus='setRadio(\"commitments\",\"appdate\",\"results\",9);'>
through
  <SELECT NAME=appdate_month_t  onFocus='setRadio(\"commitments\", \"appdate\", \"results\", 9);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=appdate_year_t  onFocus='setRadio(\"commitments\", \"appdate\", \"results\", 9);'> (yyyy)</TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=10 onFocus='setRadio(\"commitments\", \"closedate\", \"results\", 10);'></TD>
<TD><B>Closure Date</B></TD>
<TD COLSPAN=4 VALIGN=MIDDLE>
  <SELECT NAME=closedate_month_f  onFocus='setRadio(\"commitments\", \"closedate\", \"results\", 10);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=closedate_year_f
          onFocus='setRadio(\"commitments\",\"closedate\",\"results\",10);'>
through
  <SELECT NAME=closedate_month_t  onFocus='setRadio(\"commitments\", \"closedate\", \"results\", 10);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=closedate_year_t  onFocus='setRadio(\"commitments\", \"closedate\", \"results\", 10);'> (yyyy)</TD></TR>

<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=11 onFocus='setRadio(\"commitments\", \"licensinglead\", \"results\", 11);'></TD>
<TD><B>BSC Discipline Lead</B></TD>
<TD><SELECT NAME=licensinglead onFocus='setRadio(\"commitments\", \"licensinglead\", \"results\", 11);'>
$ll_select</SELECT></TD></TR>

<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=12 onFocus='setRadio(\"commitments\", \"responsiblemanager\", \"results\", 12);'></TD>
<TD><B>BSC&nbsp;Responsible&nbsp;Manager&nbsp;</B></TD>
<TD><SELECT NAME=responsiblemanager onFocus='setRadio(\"commitments\", \"responsiblemanager\", \"results\", 12);'>
$rm_select</SELECT></TD></TR>

<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=13 onFocus='setRadio(\"commitments\", \"externalid\", \"results\", 13);return false;'></TD>
<TD><B>External ID</B></TD>
<TD><INPUT TYPE=TEXT SIZE=20 MAXLENGTH=20 NAME=externalid onFocus='setRadio(\"commitments\", \"externalid\", \"results\", 13);'></TD></TR>

<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=14 onFocus='setRadio(\"commitments\", \"doeresponsiblemanager\", \"results\", 14);'></TD>
<TD><B>DOE&nbsp;Responsible&nbsp;Manager&nbsp;</B></TD>
<TD><SELECT NAME=doeresponsiblemanager onFocus='setRadio(\"commitments\", \"doeresponsiblemanager\", \"results\", 14);'>
$doe_rm_select</SELECT></TD></TR>

<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=15 onFocus='setRadio(\"commitments\", \"nrcdate\", \"results\", 15);'></TD>
<TD><B>Date Due To Originator:</B></TD>
<TD COLSPAN=4 VALIGN=MIDDLE>
  <SELECT NAME=nrcdate_month_f  onFocus='setRadio(\"commitments\", \"nrcdate\", \"results\", 15);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=nrcdate_year_f onFocus='setRadio(\"commitments\",\"nrcdate\",\"results\",15);'>
through
  <SELECT NAME=nrcdate_month_t  onFocus='setRadio(\"commitments\", \"nrcdate\", \"results\", 15);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=nrcdate_year_t  onFocus='setRadio(\"commitments\", \"nrcdate\", \"results\", 15);'> (yyyy)</TD></TR>

<TR><TD COLSPAN=5><CENTER><INPUT TYPE=SUBMIT VALUE=Submit><BR><BR>
</TD></TR></TABLE>
</CENTER>
$javascript_show_state
<!-- End of drawQuery_Commitments -->
eof_drawCommitmentsInterface
}

#######################
sub drawQuery_Actions {
#######################

    my ($interface, $id, $i, $show_state) = @_;
    my ($javascript_show_state, $month_f, $year_f, $month_t, $year_t, $sql, $sth);
    my ($disciplinelead_select, $licensinglead_select, $responsiblemanager_select);
    ## Lookup query for Discipline Lead
    $sql = "select distinct a.usersid, u.lastname, u.firstname from $schema.users u, $schema.defaultsiterole a where a.roleid=2 and a.usersid=u.usersid order by u.lastname";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my ($id, $lastname, $firstname) = $sth->fetchrow_array()) {
        $disciplinelead_select = $disciplinelead_select."<OPTION VALUE=$id>$firstname $lastname</OPTION>\n";
    }
    ## Lookup query for Licensing Lead
    $sql = "select distinct a.usersid, u.firstname, u.lastname from $schema.defaultsiterole a, $schema.users u where a.roleid=7 and a.usersid=u.usersid order by u.lastname";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my ($id, $firstname, $lastname) = $sth->fetchrow_array()) {
        $licensinglead_select = $licensinglead_select."<OPTION VALUE=$id>$firstname $lastname</OPTION>\n";
    }
    ## Lookup query for Responsible Manager
    $sql = "select responsiblemanagerid, firstname, lastname from $schema.responsiblemanager where managertypeid = 1 order by lastname";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my ($id, $firstname, $lastname) = $sth->fetchrow_array()) {
        $responsiblemanager_select = $responsiblemanager_select."<OPTION VALUE=$id>$firstname $lastname</OPTION>\n";
    }
    if ($show_state) {
	if ($interface eq "commitmentid") {
	    $javascript_show_state = "<SCRIPT>document.browse.chkOption[$i].checked = true; document.browse.$interface.value = '$id'; document.browse.$interface.focus();</SCRIPT>";
	}
        if ($interface eq "dateoccurred") {
            ($month_f, $year_f, $month_t, $year_t) = split(/:/, $id);
            $javascript_show_state = "
            <SCRIPT>
            months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
            function convertMonth(month) {
                for (i = 0; i < months.length; i++) {
                    if (months[i] == month) {
                        return i;
                    }
                }
            }
            d = document.browse;
            d.chkOption[$i].checked = true;
            d.dateoccurred_month_f[convertMonth('$month_f')].selected = true;
            d.dateoccurred_year_f.value = '$year_f';
            d.dateoccurred_month_t[convertMonth('$month_t')].selected = true;
            d.dateoccurred_year_t.value = '$year_t'; </SCRIPT>;
            </SCRIPT>
            ";
        } ## end of dateoccurred
        if ($interface eq "disciplinelead") {
            $javascript_show_state = "
                <SCRIPT>
                function getDisciplineLeadIndex(disciplinelead) {
                    for (i = 0; i < document.browse.disciplinelead.length; i++) {
                        if (document.browse.disciplinelead[i].value == disciplinelead){
                            return i;
                        }
                    }
                }
                document.browse.chkOption[$i].checked = true;
                document.browse.disciplinelead[getDisciplineLeadIndex('$id')].selected = true;
             </SCRIPT>";
        } ## end of disciplinelead
        if ($interface eq "licensinglead") {
            $javascript_show_state = "
                <SCRIPT>
                function getLicensingLeadIndex(licensinglead) {
                    for (i = 0; i < document.browse.licensinglead.length; i++) {
                        if (document.browse.licensinglead[i].value == licensinglead){
                            return i;
                        }
                    }
                }
                document.browse.chkOption[$i].checked = true;
                document.browse.licensinglead[getLicensingLeadIndex('$id')].selected = true;
             </SCRIPT>";
        } ## end of licensinglead
        if ($interface eq "responsiblemanager") {
            $javascript_show_state = "
                <SCRIPT>
                function getResponsibleManagerIndex(responsiblemanager) {
                    for (i = 0; i < document.browse.responsiblemanager.length; i++) {
                        if (document.browse.responsiblemanager[i].value == responsiblemanager){
                            return i;
                        }
                    }
                }
                document.browse.chkOption[$i].checked = true;
                document.browse.responsiblemanager[getResponsibleManagerIndex('$id')].selected = true;
             </SCRIPT>";
        } ## end of responsiblemanager
    }
print <<eof_drawActionsInterface;

<INPUT TYPE=HIDDEN NAME=option VALUE=results>
<INPUT TYPE=HIDDEN NAME=theinterface VALUE=actions>
<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=all>
<input type=hidden name=actionflag value=true>

<SCRIPT LANGUAGE=JavaScript1.2>
    function setRadio(theinterface, interfaceLevel, option, i) {
        document.browse.chkOption[i].checked = true;
        document.browse.option.value = option;
        document.browse.theinterface.value = theinterface;
        document.browse.interfaceLevel.value = interfaceLevel;
    }
if (parent.titlebar) {
    doSetTextImageLabel('Browse Actions');
}
</SCRIPT>
<CENTER><BR>
<TABLE WIDTH=650 BORDER=0>
<TR>
<TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=0 CHECKED onFocus="setRadio(\'actions\', \'all\', \'results\', 0);"></TD>
<TD WIDTH=130><B>All Actions</B></TD></TR>
<TR>
<TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption onFocus="setRadio(\'actions\', \'commitmentid\', \'results\', 1);" VALUE=1></TD>
<TD><B>Commitment ID</B></TD>
<TD><B>C </B><INPUT TYPE=TEXT SIZE=5 MAXLENGTH=5 NAME=commitmentid onFocus="setRadio(\'actions\', \'commitmentid\', \'results\', 1);"></TD></TR>
<TR>
<TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption onFocus="setRadio(\'actions\', \'dateoccurred\', \'results\', 2);" VALUE=2></TD>
<TD><B>Due Date</B></TD>
<TD VALIGN=MIDDLE>
    <SELECT NAME=dateoccurred_month_f onFocus="setRadio(\'actions\', \'dateoccurred\', \'results\', 2);" >
    <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
    <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
    <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
    <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
    <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
    <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
    </SELECT>
    <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=dateoccurred_year_f
          onFocus="setRadio(\'actions\', \'dateoccurred\', \'results\', 2);" >
through
    <SELECT NAME=dateoccurred_month_t onFocus="setRadio(\'actions\', \'dateoccurred\', \'results\', 2);" >
    <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
    <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
    <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
    <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
    <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
    <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
    </SELECT>
    <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=dateoccurred_year_t
         onFocus="setRadio(\'actions\', \'dateoccurred\', \'results\', 2);" > (yyyy)</TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=3 onFocus='setRadio(\"actions\", \"disciplinelead\", \"results\", 3);'></TD>
<TD><B>BSC Discipline Lead</B></TD>
<TD><SELECT NAME=disciplinelead onFocus='setRadio(\"actions\", \"disciplinelead\", \"results\", 3);'>
$disciplinelead_select</SELECT></TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=4 onFocus='setRadio(\"actions\", \"licensinglead\", \"results\", 4);'></TD>
<TD><B>BSC Licensing Lead</B></TD>
<TD><SELECT NAME=licensinglead onFocus='setRadio(\"actions\", \"licensinglead\", \"results\", 4);'>
$licensinglead_select</SELECT></TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=5 onFocus='setRadio(\"actions\", \"responsiblemanager\", \"results\", 5);'></TD>
<TD><B>BSC Responsible Manager</B></TD>
<TD><SELECT NAME=responsiblemanager onFocus='setRadio(\"actions\", \"responsiblemanager\", \"results\", 5);'>
$responsiblemanager_select</SELECT></TD></TR>

<TR><TD COLSPAN=5><BR>
<CENTER><INPUT TYPE=SUBMIT VALUE=Submit><BR><BR>
</TD></TR></TABLE></CENTER>
$javascript_show_state
eof_drawActionsInterface
}

########################
sub drawQuery_Keywords {
########################
    my ($interface, $id, $i, $show_state) = @_;
    my ($javascript_show_state);
    if ($show_state) {
	if ($interface eq "all") {
	    $javascript_show_state = "
<SCRIPT>
function getKeywordsIndex(keyword) {
    for (i = 0; i < document.browse.keyword.length; i++) {
        if (document.browse.keyword[i].value == keyword) {
            return i;
        }
    }
}
document.browse.keyword[getKeywordsIndex('$id')].selected = true;
</SCRIPT>";
	} ## end of keywords
    }
    my ($sql, $sth, $id, $description, $keyword_select);

    ## Lookup query for Keywords
    $sql = "select keywordid, description from $schema.keyword order by description";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($id, $description) = $sth->fetchrow_array()) {
        $keyword_select = $keyword_select."<OPTION VALUE=$id>$description</OPTION>\n";
    }
    $sth->finish();

print <<eof_drawKeywordsInterface;
<SCRIPT LANGUAGE=JavaScript>
function setValues() {
    document.browse.option.value = \"results\";
    document.browse.theinterface.value = \"keywords\";
    document.browse.interfaceLevel.value = \"all\";
}
if (parent.titlebar) {
    doSetTextImageLabel('Browse Keywords');
}
</SCRIPT>
<CENTER>
<INPUT TYPE=HIDDEN NAME=option VALUE=results>
<INPUT TYPE=HIDDEN NAME=theinterface VALUE=keywords>
<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=all><BR>
<TABLE BORDER=0>
<TR><TD><B>Keyword:</B></TD>
<TD><SELECT NAME=keyword onFocus=\'setValues();\'>$keyword_select</SELECT></TD>
</TR>
<TR><TD COLSPAN=5><BR><CENTER><INPUT TYPE=SUBMIT VALUE=Submit><BR><BR>
</TD></TR></TABLE>
</CENTER>
$javascript_show_state
<!-- End of drawQuery_Keywords -->
eof_drawKeywordsInterface
}

########################
sub drawQuery_Category {
########################
    my ($interface, $id, $i, $show_state) = @_;
    my ($javascript_show_state);
    if ($show_state) {
        if ($interface eq "all") {
            $javascript_show_state = "
                <SCRIPT>
                function getCategoryIndex(category) {
                    for (i = 0; i < document.browse.category.length; i++) {
                        if (document.browse.category[i].value == category) {
                            return i;
                        }
                    }
                }
                document.browse.category[getCategoryIndex('$id')].selected = true;
             </SCRIPT>";
        } ## end of keywords
    }
    my ($sql, $sth, $id, $description, $category_select);

    ## Lookup query for Category
    $sql = "select categoryid, description from $schema.category order by description";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($id, $description) = $sth->fetchrow_array()) {
        $category_select = $category_select."<OPTION VALUE=$id>$description</OPTION>\n";
    }
    $sth->finish();

print <<eof_drawCategoryInterface;
<SCRIPT LANGUAGE="JavaScript1.2">
function setValues() {
    document.browse.option.value = \"results\";
    document.browse.theinterface.value = \"category\";
    document.browse.interfaceLevel.value = \"all\";
}
if (parent.titlebar) {
    doSetTextImageLabel('Browse Category');
}
</SCRIPT>
<CENTER>
<INPUT TYPE=HIDDEN NAME=option VALUE=results>
<INPUT TYPE=HIDDEN NAME=theinterface VALUE=category>
<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=all><BR>
<TABLE BORDER=0><TR><TD><B>Category:</B></TD>
<TD><SELECT NAME=category onFocus=\'setValues();\'>$category_select</SELECT></TD></TR>
<TR><TD COLSPAN=5><BR><CENTER>
<INPUT TYPE=SUBMIT VALUE=Submit><BR><BR></TD></TR></TABLE>
</CENTER>
$javascript_show_state
<!-- End of drawQuery_Category -->
eof_drawCategoryInterface
}

########################
sub drawQuery_SiteName {
########################
    my ($interface, $id, $i, $show_state) = @_;
    my ($javascript_show_state);

    if ($show_state) {
        if ($interface eq "all") {
            $javascript_show_state = "
<SCRIPT>
function getSiteNameIndex(sitename) {
    for (i = 0; i < document.browse.sitename.length; i++) {
        if (document.browse.sitename[i].value == sitename) {
            return i;
        }
    }
}
document.browse.sitename[getSiteNameIndex('$id')].selected = true;
</SCRIPT>\n";
        } ## end of Sitename
    }
    my ($sql, $sth, $id, $description, $sitename_select);

    ## Lookup query for Sitename
    $sql = "select siteid, name from $schema.site order by name";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($id, $description) = $sth->fetchrow_array()) {
        $sitename_select = $sitename_select."<OPTION VALUE=$id>$description</OPTION>\n";
    }
    $sth->finish();

print <<eof_drawSiteNameInterface;
<SCRIPT LANGUAGE=JavaScript>
function setValues() {
    document.browse.option.value = \"results\";
    document.browse.theinterface.value = \"sitename\";
    document.browse.interfaceLevel.value = \"all\";
}
if (parent.titlebar) {
    doSetTextImageLabel('Browse Sites');
}
</SCRIPT>
<CENTER>
<INPUT TYPE=HIDDEN NAME=option VALUE=results>
<INPUT TYPE=HIDDEN NAME=theinterface VALUE=sitename>
<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=all><BR>
<TABLE BORDER=0><TR><TD><B>Site Name:</B></TD>
<TD><SELECT NAME=sitename onFocus=\'setValues();\'>$sitename_select</SELECT></TD></TR>
<TR><TD COLSPAN=5><BR><CENTER><INPUT TYPE=SUBMIT VALUE=Submit><BR><BR>
</TD></TR></TABLE></CENTER>
$javascript_show_state
<!-- End of drawQuery_SiteName -->
eof_drawSiteNameInterface
}

#####################
sub drawQuery_Users {
#####################
    #$interface = "users";
    &drawResults_Users();
}

#######################
sub drawQuery_Letters {
#######################
    my ($cbid, $data) = @_;

    my $javascript_show_state = "setState($cbid, \'$data\')" if $cbid;
    my ($sql, $sth, $id, $description, $organization_select);

    ## Lookup query for Sitename
    $sql = "select a.organizationid, a.name from $schema.organization a where a.organizationid ".
           "in (select distinct b.organizationid from $schema.letter b)";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($id, $description) = $sth->fetchrow_array()) {
        $organization_select = $organization_select."<OPTION VALUE=$id>$description</OPTION>\n";
    }
    $sth->finish();

print <<eof_drawLettersInterface;
<SCRIPT LANGUAGE="JavaScript1.2">
if (parent.titlebar) { doSetTextImageLabel('Browse Commitment Letters'); }
function setRadio(theinterface, interfaceLevel, option, i) {
    document.browse.chkOption[i].checked = true;
    document.browse.option.value = option;
    document.browse.theinterface.value = theinterface;
    document.browse.interfaceLevel.value = interfaceLevel;
}
function setState(id, data) {
    var d = document.browse;
    var i;
    // view all letters
    if (id == 0) {
        d.theinterface.value = 'letters';
        d.interfaceLevel.value = 'all';
        d.chkOption[id].checked = true;
    }
    // view letters for a commitmentid
    if (id == 1) {
        d.commitmentid.value = data;
        d.theinterface.value = 'letters';
        d.interfaceLevel.value = 'commitmentid';
        d.chkOption[id].checked = true;
    }
    // view letters for sent date
    if (id == 2) {
        d.theinterface.value = 'letters';
        d.interfaceLevel.value = 'sentdate';
        d.chkOption[id].checked = true;

        a = new Array(4);
        a = data.split(":");

        d.sentdate_year_f.value = a[1];
        d.sentdate_year_t.value = a[3];

        for (i = 0; i < d.sentdate_month_f.length; i++) {
            if (d.sentdate_month_f[i].value == a[0]) {
                d.sentdate_month_f[i].selected = true;
            }
        }
        for (i = 0; i < d.sentdate_month_t.length; i++) {
            if (d.sentdate_month_t[i].value == a[2]) {
                d.sentdate_month_t[i].selected = true;
            }
        }
    }
    // view letters for a signed date
    if (id == 3) {
        d.theinterface.value = 'letters';
        d.interfaceLevel.value = 'signeddate';
        d.chkOption[id].checked = true;

        a = new Array(4);
        a = data.split(":");

        d.signeddate_year_f.value = a[1];
        d.signeddate_year_t.value = a[3];

        for (i = 0; i < d.sentdate_month_f.length; i++) {
            if (d.signeddate_month_f[i].value == a[0]) {
                d.signeddate_month_f[i].selected = true;
            }
        }
        for (i = 0; i < d.sentdate_month_t.length; i++) {
            if (d.signeddate_month_t[i].value == a[2]) {
                d.signeddate_month_t[i].selected = true;
            }
        }
    }
    // view letters for an organization
    if (id == 4) {
        d.theinterface.value = 'letters';
        d.interfaceLevel.value = 'organization';
        d.chkOption[id].checked = true;

        for (i = 0; i < d.organizationid.length; i++) {
            if (d.organizationid[i].value == data) {
                d.organizationid[i].selected = true;
            }
        }
    }
}
</SCRIPT>
<CENTER>
<INPUT TYPE=HIDDEN NAME=option VALUE=results>
<INPUT TYPE=HIDDEN NAME=theinterface VALUE=letters>
<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=all>
<INPUT TYPE=HIDDEN NAME=letterflag VALUE=true><BR>
<TABLE WIDTH=650 BORDER=0>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=0 CHECKED onFocus='setRadio(\"letters\", \"all\", \"results\", 0);'></TD>
<TD WIDTH=220><B>All Commitment Letters</B></TD>
<TD></TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=1 onFocus='setRadio(\"letters\", \"commitmentid\", \"results\", 1);return false;'></TD>
<TD><B>Commitment ID</B></TD>
<TD><B>C </B><INPUT TYPE=TEXT SIZE=5 MAXLENGTH=5 NAME=commitmentid onFocus='setRadio(\"letters\", \"commitmentid\", \"results\", 1);'></TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=2 onFocus='setRadio(\"letters\", \"sentdate\", \"results\", 2);'></TD>
<TD><B>Date Sent</B></TD>
<TD COLSPAN=4 VALIGN=MIDDLE>
  <SELECT NAME=sentdate_month_f  onFocus='setRadio(\"letters\", \"sentdate\", \"results\", 2);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=sentdate_year_f
          onFocus='setRadio(\"letters\", \"sentdate\", \"results\", 2);'>
through
  <SELECT NAME=sentdate_month_t  onFocus='setRadio(\"letters\", \"sentdate\", \"results\", 2);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=sentdate_year_t  onFocus='setRadio(\"letters\", \"sentdate\", \"results\", 2);'> (yyyy)
</TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=2 onFocus='setRadio(\"letters\", \"signeddate\", \"results\", 3);'></TD>
<TD><B>Date Signed</B></TD>
<TD COLSPAN=4 VALIGN=MIDDLE>
  <SELECT NAME=signeddate_month_f  onFocus='setRadio(\"letters\", \"signeddate\", \"results\", 3);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=signeddate_year_f
          onFocus='setRadio(\"letters\", \"signeddate\", \"results\", 3);'>
through
  <SELECT NAME=signeddate_month_t  onFocus='setRadio(\"letters\", \"signeddate\", \"results\", 3);'>
  <OPTION VALUE=JAN>January</OPTION><OPTION VALUE=FEB>February</OPTION>
  <OPTION VALUE=MAR>March</OPTION><OPTION VALUE=APR>April</OPTION>
  <OPTION VALUE=MAY>May</OPTION><OPTION VALUE=JUN>June</OPTION>
  <OPTION VALUE=JUL>July</OPTION><OPTION VALUE=AUG>August</OPTION>
  <OPTION VALUE=SEP>September</OPTION><OPTION VALUE=OCT>October</OPTION>
  <OPTION VALUE=NOV>November</OPTION><OPTION VALUE=DEC>December</OPTION>
  </SELECT>
  <INPUT TYPE=TEXT SIZE=4 MAXLENGTH=4 NAME=signeddate_year_t  onFocus='setRadio(\"letters\", \"signeddate\", \"results\", 3);'> (yyyy)
</TD></TR>
<TR><TD WIDTH=10><INPUT TYPE=RADIO NAME=chkOption VALUE=3  onFocus='setRadio(\"letters\", \"organization\", \"results\", 4);'></TD>
<TD><B>Organization</B></TD>
<TD COLSPAN=4><SELECT NAME=organizationid onFocus='setRadio(\"letters\", \"organization\", \"results\", 4);'>
$organization_select
</SELECT></TD></TR>
<TR><TD COLSPAN=5><BR><CENTER><INPUT TYPE=SUBMIT VALUE=Submit>
<BR><BR></TD></TR></TABLE>
<SCRIPT LANGUAGE="JavaScript1.2">
  $javascript_show_state
</SCRIPT>
<!-- End of drawQuery_Letters -->
eof_drawLettersInterface
}

#################
sub drawResults {
#################
    &drawResults_Issues() if $interface eq 'issues';
    &drawResults_Commitments() if $interface eq 'commitments';
    &drawResults_Actions() if $interface eq 'actions';
    &drawResults_Keywords() if $interface eq 'keywords';
    &drawResults_Category() if $interface eq 'category';
    &drawResults_SiteName() if $interface eq 'sitename';
    &drawResults_Users() if $interface eq 'users';
    &drawResults_Letters() if $interface eq 'letters';
    &drawResults_Statuses() if $interface eq 'statuses';
}

########################
sub drawResults_Issues {
########################
    &drawResults_Issues_All() if $interfaceLevel eq 'all';
    &drawResults_Issues_IssueID() if $interfaceLevel eq 'issueid';
    &drawResults_Issues_DateOccurred() if $interfaceLevel eq 'dateoccurred';
    &drawResults_Issues_DateEntered() if $interfaceLevel eq 'dateentered';
    &drawResults_Issues_AccessionNum() if $interfaceLevel eq 'accessionnum';
    &drawResults_Issues_SourceDocID() if $interfaceLevel eq 'sourcedocid';
}

############################
sub drawResults_Issues_All {
############################
    &drawQuery_Issues(undef, undef, undef, undef);

    my ($total)=$dbh -> selectrow_array ("select count(*) from $schema.issue");
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=770 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>All Issues ($total total)</TD></TR>\n";
    &issueResults();

    print "</TABLE>";
    print "\n<!-- End of drawResults_Issues_All -->\n\n";
}

################################
sub drawResults_Issues_IssueID {
################################
    my $issueid = $q->param("issueid");
    my $chkOption = $q->param("chkOption");

    &checkForExistence("issues", "issueid", "$issueid");
    &drawQuery_Issues("issueid", $issueid, $chkOption, 1);

    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=770 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>Issue " . formatID2 ($issueid, 'I') . "</TD></TR>\n";
    my $where = "i.issueid=$issueid";
    issueResults(where => $where);
    print "</TABLE>";
    print "\n<!-- End of drawResults_Issues_IssueID -->\n\n";
}

#####################################
sub drawResults_Issues_DateOccurred {
#####################################
    my $dateoccurred_month_f = $q->param("dateoccurred_month_f");
    my $dateoccurred_year_f = $q->param("dateoccurred_year_f");
    my $dateoccurred_month_t = $q->param("dateoccurred_month_t");
    my $dateoccurred_year_t = $q->param("dateoccurred_year_t");

    my $datestr = "$dateoccurred_month_f:$dateoccurred_year_f:$dateoccurred_month_t:$dateoccurred_year_t";

    &drawQuery_Issues("dateoccurred", "$datestr", 2, 1);

    my ($date_low, $date_high);
    my ($headerFlag, $main_title);
    $date_low = "01-".$dateoccurred_month_f."-".$dateoccurred_year_f;
    $date_high = "LAST_DAY(\'01-$dateoccurred_month_t-$dateoccurred_year_t\')";

    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.issue where dateoccurred between \'$date_low\' and $date_high");
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;

    if ($total >= 1) {
        $main_title = "Issues occurring between $dateoccurred_month_f-$dateoccurred_year_f and $dateoccurred_month_t-$dateoccurred_year_t ($total total)";
    } 
    else {
        $main_title = "No Issues found within the specified date range\n";
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=770 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "i.dateoccurred between '$date_low' and $date_high";
	issueResults (where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Issues_DateOccurred -->\n\n";
}

#####################################
sub drawResults_Issues_DateEntered {
#####################################
    my $dateentered_month_f = $q->param("dateentered_month_f");
    my $dateentered_year_f = $q->param("dateentered_year_f");
    my $dateentered_month_t = $q->param("dateentered_month_t");
    my $dateentered_year_t = $q->param("dateentered_year_t");

    my $datestr = "$dateentered_month_f:$dateentered_year_f:$dateentered_month_t:$dateentered_year_t";
    &drawQuery_Issues("dateentered", "$datestr", 3, 1);

    my ($date_low, $date_high);
    my ($headerFlag, $main_title);
    $date_low = "01-".$dateentered_month_f."-".$dateentered_year_f;
    $date_high = "LAST_DAY(\'01-$dateentered_month_t-$dateentered_year_t\')";
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.issue where entereddate between \'$date_low\' and $date_high");
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($total >= 1) {
        $main_title = "Issues entered between $dateentered_month_f-$dateentered_year_f and $dateentered_month_t-$dateentered_year_t ($total total)";
    } 
    else {
        $main_title = "No Issues found within the specified date range\n";
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=770 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "i.entereddate between '$date_low' and $date_high";
	issueResults (where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Issues_DateEntered -->\n\n";
}

#############################
sub drawResults_Commitments {
#############################
    &drawResults_Commitments_All() if $interfaceLevel eq 'all';
    &drawResults_Commitments_CommitmentID() if $interfaceLevel eq 'commitmentid';
    &drawResults_Commitments_DateOccurred() if $interfaceLevel eq 'dateoccurred';
    &drawResults_Commitments_FulfillmentDate() if $interfaceLevel eq 'fuldate';
    &drawResults_Commitments_ApprovalDate() if $interfaceLevel eq 'appdate';
    &drawResults_Commitments_ClosedDate() if $interfaceLevel eq 'closedate';
    &drawResults_Commitments_NRCDate() if $interfaceLevel eq 'nrcdate';
    &drawResults_Commitments_WBS() if $interfaceLevel eq 'wbs';
    &drawResults_Commitments_Discipline() if $interfaceLevel eq 'discipline';
    &drawResults_Commitments_ProductAffected() if $interfaceLevel eq 'productaffected';
    &drawResults_Commitments_CommitmentLevel() if $interfaceLevel eq 'commitmentlevel';
    &drawResults_Commitments_Status() if $interfaceLevel eq 'status';
    &drawResults_Commitments_LicensingLead() if $interfaceLevel eq 'licensinglead';
    &drawResults_Commitments_ResponsibleManager() if $interfaceLevel eq 'responsiblemanager';
    &drawResults_Commitments_DOEResponsibleManager() if $interfaceLevel eq 'doeresponsiblemanager';
    &drawResults_Commitments_ExternalID() if $interfaceLevel eq 'externalid';
}

#################################
sub drawResults_Commitments_All {
#################################
    &drawQuery_Commitments(undef, undef, undef, undef);
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.commitment");
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>All Commitments ($total total)</B></FONT></TD></TR>\n";
    commitmentResults();
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_All -->\n\n";

}

##########################################
sub drawResults_Commitments_CommitmentID {
##########################################
    my $commitmentid = $q->param("commitmentid");
    my $chkOption = $q->param("chkOption");

    &checkForExistence("commitments", "commitmentid", "$commitmentid");
    &drawQuery_Commitments("commitmentid", $commitmentid, $chkOption, 1);

    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>Commitment " . formatID2 ($commitmentid, 'C') . "</B></FONT></TD></TR>\n";
    my $where = "c.commitmentid = $commitmentid";
    commitmentResults (where => $where);
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_CommitmentID -->\n\n";
}

##########################################
sub drawResults_Commitments_DateOccurred {
##########################################
    my $dateoccurred_month_f = $q->param("dateoccurred_month_f");
    my $dateoccurred_year_f = $q->param("dateoccurred_year_f");
    my $dateoccurred_month_t = $q->param("dateoccurred_month_t");
    my $dateoccurred_year_t = $q->param("dateoccurred_year_t");

    my $datestr = "$dateoccurred_month_f:$dateoccurred_year_f:$dateoccurred_month_t:$dateoccurred_year_t";
    &drawQuery_Commitments("dateoccurred", "$datestr", 2, 1);

    my ($date_low, $date_high);
    my ($headerFlag, $main_title);
    $date_low = "01-".$dateoccurred_month_f."-".$dateoccurred_year_f;
    $date_high = "LAST_DAY(\'01-$dateoccurred_month_t-$dateoccurred_year_t\')";
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.commitment where duedate between \'$date_low\' and $date_high"); 
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($total >= 1) {
        $main_title = "Commitments due to Commitment Maker between $dateoccurred_month_f-$dateoccurred_year_f and $dateoccurred_month_t-$dateoccurred_year_t ($total total)";
    } 
    else {
        $main_title = "No Commitments found within the specified due date range\n";
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "c.duedate between \'$date_low\' and $date_high";
	commitmentResults(where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_DateOccurred -->\n\n";
}

#############################################
sub drawResults_Commitments_FulfillmentDate {
#############################################
    my $fuldate_month_f = $q->param("fuldate_month_f");
    my $fuldate_year_f = $q->param("fuldate_year_f");
    my $fuldate_month_t = $q->param("fuldate_month_t");
    my $fuldate_year_t = $q->param("fuldate_year_t");
    my $datestr = "$fuldate_month_f:$fuldate_year_f:$fuldate_month_t:$fuldate_year_t";
    &drawQuery_Commitments("fuldate", "$datestr", 8, 1);

    my ($date_low, $date_high);
    my ($headerFlag, $main_title);
    $date_low = "01-".$fuldate_month_f."-".$fuldate_year_f;
    $date_high = "LAST_DAY(\'01-$fuldate_month_t-$fuldate_year_t\')";

    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.commitment where fulfilldate between \'$date_low\' and $date_high"); 

    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($total >= 1) {
        $main_title = "Commitments with estimated fulfillment between $fuldate_month_f-$fuldate_year_f and $fuldate_month_t-$fuldate_year_t ($total total)";
    } 
    else {
        $main_title = "No Commitments found within that date range\n";
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "c.fulfilldate between \'$date_low\' and $date_high";
	commitmentResults(where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_FulfDateOccurred -->\n\n";
}

##########################################
sub drawResults_Commitments_ApprovalDate {
##########################################
    my $appdate_month_f = $q->param("appdate_month_f");
    my $appdate_year_f = $q->param("appdate_year_f");
    my $appdate_month_t = $q->param("appdate_month_t");
    my $appdate_year_t = $q->param("appdate_year_t");
    my $datestr = "$appdate_month_f:$appdate_year_f:$appdate_month_t:$appdate_year_t";
    &drawQuery_Commitments("appdate", "$datestr", 9, 1);

    my ($date_low, $date_high);
    my ($headerFlag, $main_title);
    $date_low = "01-".$appdate_month_f."-".$appdate_year_f;
    $date_high = "LAST_DAY(\'01-$appdate_month_t-$appdate_year_t\')";

    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.commitment where commitdate between \'$date_low\' and $date_high"); 

    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($total >= 1) {
        $main_title = "Commitments approved between $appdate_month_f-$appdate_year_f and $appdate_month_t-$appdate_year_t ($total total)";
    } 
    else {
        $main_title = "No Commitments found within the specified approval date range\n";
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "c.commitdate between \'$date_low\' and $date_high";
	commitmentResults(where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_ApprovalDate -->\n\n";
}

########################################
sub drawResults_Commitments_ClosedDate {
########################################
    my $closedate_month_f = $q->param("closedate_month_f");
    my $closedate_year_f = $q->param("closedate_year_f");
    my $closedate_month_t = $q->param("closedate_month_t");
    my $closedate_year_t = $q->param("closedate_year_t");

    my $datestr = "$closedate_month_f:$closedate_year_f:$closedate_month_t:$closedate_year_t";
    &drawQuery_Commitments("closedate", "$datestr", 10, 1);
    my ($date_low, $date_high);
    my ($headerFlag, $main_title);
    $date_low = "01-".$closedate_month_f."-".$closedate_year_f;
    $date_high = "LAST_DAY(\'01-$closedate_month_t-$closedate_year_t\')";
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.commitment where closeddate between \'$date_low\' and $date_high"); 
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($total >= 1) {
        $main_title = "Commitments closed between $closedate_month_f-$closedate_year_f and $closedate_month_t-$closedate_year_t ($total total)";
    } 
    else {
        $main_title = "No Commitments found within the specified closing date range\n";
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "c.closeddate between \'$date_low\' and $date_high";
	commitmentResults(where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_DateOccurred -->\n\n";
}

#####################################
sub drawResults_Commitments_NRCDate {
#####################################
    my $nrcdate_month_f = $q->param("nrcdate_month_f");
    my $nrcdate_year_f = $q->param("nrcdate_year_f");
    my $nrcdate_month_t = $q->param("nrcdate_month_t");
    my $nrcdate_year_t = $q->param("nrcdate_year_t");
    my $datestr = "$nrcdate_month_f:$nrcdate_year_f:$nrcdate_month_t:$nrcdate_year_t";
    &drawQuery_Commitments("nrcdate", "$datestr", 9, 1);

    my ($date_low, $date_high);
    my ($headerFlag, $main_title);
    $date_low = "01-".$nrcdate_month_f."-".$nrcdate_year_f;
    $date_high = "LAST_DAY(\'01-$nrcdate_month_t-$nrcdate_year_t\')";

    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.commitment where dateduetonrc between \'$date_low\' and $date_high"); 

    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($total >= 1) {
        $main_title = "Commitments due to originator between $nrcdate_month_f-$nrcdate_year_f and $nrcdate_month_t-$nrcdate_year_t ($total total)";
    } 
    else {
        $main_title = "No Commitments found within the specified date due to originator range\n";
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "c.dateduetonrc between \'$date_low\' and $date_high";
	commitmentResults(where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_NRCDate -->\n\n";
}

#################################
sub drawResults_Commitments_WBS {
#################################
    my $wbs = $q->param("wbs");
    my $chkOption = $q->param("chkOption");
    &drawQuery_Commitments("wbs", "$wbs", $chkOption, 1);

    my ($headerFlag, $main_title);
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.commitment where controlaccountid = \'$wbs\'");
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($total >= 1) {
        $main_title = "Commitments with WBS \"$wbs\" ($total total)";
    } 
    else {
        $main_title = "No Commitments found with WBS Level \"$wbs\"";
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "c.controlaccountid = \'$wbs\' ";
	commitmentResults(where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_WBS -->\n\n";
}

########################################
sub drawResults_Commitments_Discipline {
########################################
    my $disciplineid = $q->param("discipline");
    my $chkOption = $q->param("chkOption");
    &drawQuery_Commitments("discipline", "$disciplineid", $chkOption, 1);

    my ($headerFlag, $main_title);
    my ($total) = $dbh -> selectrow_array ( "select count(*) from $schema.commitment where primarydiscipline = $disciplineid");
    my ($disciplinetitle) = $dbh -> selectrow_array ("select description from $schema.discipline where disciplineid = $disciplineid");
    if ($total >= 1) {
        $main_title = "Commitments with discipline $disciplinetitle ($total total)";
    } 
    else {
        $main_title = "No commitments found with discipline $disciplinetitle";
    }
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "c.primarydiscipline = $disciplineid";
	commitmentResults(where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_Discipline -->\n\n";
}

#############################################
sub drawResults_Commitments_ProductAffected {
#############################################
    my $productid = $q->param("productaffected");
    my $chkOption = $q->param("chkOption");
    &drawQuery_Commitments("productaffected", "$productid", $chkOption, 1);

    my ($producttitle, $headerFlag, $main_title);
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.productaffected where productid = $productid");
    ($producttitle) = $dbh -> selectrow_array ("select description from $schema.product where productid=$productid");
    if ($total >= 1) {
        $main_title = "Commitments affecting the $producttitle ($total total)";
    } 
    else {
        $main_title = "No commitments found affecting $producttitle";
    }
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "p.productid = $productid and p.commitmentid = c.commitmentid(+)";
	my $table = "$schema.productaffected p";
	commitmentResults (where => $where, table => $table);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_ProductAffected -->\n\n";
}

#############################################
sub drawResults_Commitments_CommitmentLevel {
#############################################
    my $commitmentlevelid = $q->param("commitmentlevel");
    my $chkOption = $q->param("chkOption");

   &drawQuery_Commitments("commitmentlevel","$commitmentlevelid",$chkOption,1);
    my ($commitmentleveltitle, $headerFlag, $main_title);
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.commitment where commitmentlevelid = $commitmentlevelid");
    ($commitmentleveltitle) = $dbh -> selectrow_array ("select description from $schema.commitmentlevel where commitmentlevelid = $commitmentlevelid");
    if ($total >= 1) {
        $main_title = "Commitments with level $commitmentleveltitle ($total total)";
    } 
    else {
        $main_title = "No commitments found with level $commitmentleveltitle";
    }
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "c.commitmentlevelid=$commitmentlevelid";
	commitmentResults (where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_CommitmentLevel -->\n\n";
}

####################################
sub drawResults_Commitments_Status {
####################################
    my ($headerFlag, $main_title, $sql_count, $sql_title, $title);
    my ($statusid);
    my $status_option = $q-> param ('status');
    &drawQuery_Commitments ('status', $status_option, 7, 1);
    if ($status_option eq 'open') {
        $sql_count = "select count(*) from $schema.commitment where statusid not in (8, 15, 16)";
    } 
    elsif ($status_option eq 'closed') {
        $sql_count = "select count(*) from $schema.commitment where statusid in (8, 15, 16)";
    } 
    else {
        $sql_count = "select count(*) from $schema.commitment where statusid = $status_option";
        ($title) = $dbh -> selectrow_array ("select description from $schema.status where statusid = $status_option");
    }
    my ($total) = $dbh -> selectrow_array($sql_count);

    ## Open Commitments
    if ($total <= 0 && $status_option eq 'open') {
        $headerFlag = undef;
        $main_title = "There are currently no open commitments in the system";
    }
    if ($total > 0 && $status_option eq 'open') {
        $headerFlag = 1;
        $main_title = "All Open Commitments ($total total)";
    }
    ## Closed Commitments
    if ($total <= 0 && $status_option eq 'closed') {
        $headerFlag = undef;
        $main_title = "There are currently no closed commitments in the system";
    }
    if ($total > 0 && $status_option eq 'closed') {
        $headerFlag = 1;
        $main_title = "All Closed Commitments ($total total)";
    }
    ## All Other Commitments
    if ($total <= 0 && $status_option ne 'open' && $status_option ne 'closed'){
        $headerFlag = undef;
        $main_title = "No commitments with status $title";
    }
    if ($total > 0 && $status_option ne 'open' && $status_option ne 'closed') {
        $headerFlag = 1;
        $main_title = "Commitments with status $title ($total total)";
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "";
	if ($status_option eq 'open') {
	    $where = "c.statusid not in (8, 15, 16)";
	}
	elsif ($status_option eq 'closed') {
	    $where = "c.statusid in (8, 15, 16)";
	}
	else {
	    $where = "c.statusid = $status_option";
	}
	commitmentResults(where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_Status -->\n\n";
}

###########################################
sub drawResults_Commitments_LicensingLead {
###########################################
    my $llid = $q -> param ("licensinglead");
    my $chkOption = $q -> param ("chkOption");

    &drawQuery_Commitments ("licensinglead", "$llid", $chkOption, 1);
    my ($llname, $headerFlag, $main_title);
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.commitment where lleadid = $llid");
    ($llname) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from $schema.users where usersid = $llid");
    if ($total >= 1) {
        $main_title = "Commitments for BSC Discipline Lead $llname ($total total)";
    } 
    else {
        $main_title = "No commitments found for BSC Discipline Lead $llname";
    }
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "c.lleadid=$llid";
	commitmentResults (where => $where);
    }
    print "</TABLE>\n\n";
}

################################################
sub drawResults_Commitments_ResponsibleManager {
################################################
    my $rmid = $q -> param ("responsiblemanager");
    my $chkOption = $q -> param ("chkOption");

    &drawQuery_Commitments ("responsiblemanager", "$rmid", $chkOption, 1);
    my ($rmname, $headerFlag, $main_title);
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.commitment where managerid = $rmid");
    ($rmname) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from $schema.responsiblemanager where responsiblemanagerid = $rmid");
    if ($total >= 1) {
        $main_title = "Commitments for BSC Responsible Manager $rmname ($total total)";
    } 
    else {
        $main_title = "No commitments found for BSC Responsible Manager $rmname";
    }
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "c.managerid=$rmid";
	commitmentResults (where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_ResponsibleManager -->\n\n";
}

###################################################
sub drawResults_Commitments_DOEResponsibleManager {
###################################################
    my $rmid = $q -> param ("doeresponsiblemanager");
    my $chkOption = $q -> param ("chkOption");

    &drawQuery_Commitments ("doeresponsiblemanager", "$rmid", $chkOption, 1);
    my ($rmname, $headerFlag, $main_title);
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.commitment where doemanagerid = $rmid");
    ($rmname) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from $schema.responsiblemanager where responsiblemanagerid = $rmid");
    if ($total >= 1) {
        $main_title = "Commitments for DOE Responsible Manager $rmname ($total total)";
    } 
    else {
        $main_title = "No commitments found for DOE Responsible Manager $rmname";
    }
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "c.doemanagerid=$rmid";
	commitmentResults (where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_DOEResponsibleManager -->\n\n";
}

########################################
sub drawResults_Commitments_ExternalID {
########################################
    my $externalid = $q->param("externalid");
    my $chkOption = $q->param("chkOption");

    &checkForExistence("commitments", "externalid", "$externalid");
    &drawQuery_Commitments("externalid", $externalid, $chkOption, 1);

    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>External ID $externalid</B></FONT></TD></TR>\n";
    my $where = "c.externalid = \'$externalid\'";
    commitmentResults (where => $where);
    print "</TABLE>\n\n";
}

#########################
sub drawResults_Actions {
#########################
    &drawResults_Actions_All() if $interfaceLevel eq 'all';
    &drawResults_Actions_CommitmentID() if $interfaceLevel eq 'commitmentid';
    &drawResults_Actions_DueDate() if $interfaceLevel eq 'dateoccurred';
    &drawResults_Actions_DisciplineLead() if $interfaceLevel eq 'disciplinelead';
    &drawResults_Actions_LicensingLead() if $interfaceLevel eq 'licensinglead';
    &drawResults_Actions_ResponsibleManager() if $interfaceLevel eq 'responsiblemanager';
}

#############################
sub drawResults_Actions_All {
#############################
    &drawQuery_Actions(undef, undef, undef, undef);

    my ($total)=$dbh -> selectrow_array ("select count(*) from $schema.action");
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<input type=hidden name=actionid value=>";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=770 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#fabaaa><FONT COLOR=#000099 SIZE=4><B>All Actions ($total total)</TD></TR>\n";
    &actionResults();

    print "</TABLE>\n\n";
}

######################################
sub drawResults_Actions_CommitmentID {
######################################
    my $commitmentid = $q->param("commitmentid");
    my $chkOption = $q->param("chkOption");

    &checkForExistence("actions", "commitmentid", "$commitmentid");
    &drawQuery_Actions("commitmentid", $commitmentid, $chkOption, 1);

    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<input type=hidden name=actionid value=>";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=770 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#fabaaa><FONT COLOR=#000099 SIZE=4><B>Actions for Commitment " . formatID2 ($commitmentid, 'C') . "</TD></TR>\n";
    my $where = "a.commitmentid=$commitmentid";
    actionResults(where => $where);
    print "</TABLE>\n\n";
}

#################################
sub drawResults_Actions_DueDate {
#################################
    my $duedate_month_f = $q -> param ("dateoccurred_month_f");
    my $duedate_year_f = $q -> param ("dateoccurred_year_f");
    my $duedate_month_t = $q -> param ("dateoccurred_month_t");
    my $duedate_year_t = $q -> param ("dateoccurred_year_t");

    my $datestr = "$duedate_month_f:$duedate_year_f:$duedate_month_t:$duedate_year_t";
    &drawQuery_Actions ("dateoccurred", "$datestr", 2, 1);

    my ($date_low, $date_high);
    my ($headerFlag, $main_title);
    $date_low = "01-".$duedate_month_f."-".$duedate_year_f;
    $date_high = "LAST_DAY(\'01-$duedate_month_t-$duedate_year_t\')";
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.action where duedate between \'$date_low\' and $date_high"); 
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($total >= 1) {
        $main_title = "Actions due between $duedate_month_f-$duedate_year_f and $duedate_month_t-$duedate_year_t ($total total)";
    } 
    else {
        $main_title = "No Commitments found within the specified due date range\n";
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<input type=hidden name=actionid value=>";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#fabaaa><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "a.duedate between \'$date_low\' and $date_high";
	actionResults(where => $where);
    }
    print "</TABLE>";
    print "\n\n";
}

########################################
sub drawResults_Actions_DisciplineLead {
########################################
    my $dlid = $q -> param ("disciplinelead");
    my $chkOption = $q -> param ("chkOption");
    &drawQuery_Actions ("disciplinelead", "$dlid", $chkOption, 1);
    my ($dlname, $headerFlag, $main_title);
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.action where dleadid = $dlid");
    ($dlname) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from $schema.users where usersid = $dlid");
    if ($total >= 1) {
        $main_title = "Actions for BSC Discipline Lead $dlname ($total total)";
    } 
    else {
        $main_title = "No actions found for BSC Discipline Lead $dlname";
    }
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<input type=hidden name=actionid value=>";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#fabaaa><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "a.dleadid=$dlid";
	actionResults (where => $where);
    }
    print "</TABLE>\n\n";
}

#######################################
sub drawResults_Actions_LicensingLead {
#######################################
    my $llid = $q -> param ("licensinglead");
    my $chkOption = $q -> param ("chkOption");

    &drawQuery_Actions ("licensinglead", "$llid", $chkOption, 1);
    my ($llname, $headerFlag, $main_title);
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.action where lleadid = $llid");
    ($llname) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from $schema.users where usersid = $llid");
    if ($total >= 1) {
        $main_title = "Actions for BSC Licensing Lead $llname ($total total)";
    } 
    else {
        $main_title = "No actions found for BSC Licensing Lead $llname";
    }
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<input type=hidden name=actionid value=>";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#fabaaa><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "a.lleadid=$llid";
	actionResults (where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Commitments_LicensingLead -->\n\n";
}

############################################
sub drawResults_Actions_ResponsibleManager {
############################################
    my $rmid = $q -> param ("responsiblemanager");
    my $chkOption = $q -> param ("chkOption");

    &drawQuery_Actions ("responsiblemanager", "$rmid", $chkOption, 1);
    my ($rmname, $headerFlag, $main_title);
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.action where managerid = $rmid");
    ($rmname) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from $schema.responsiblemanager where responsiblemanagerid = $rmid");
    if ($total >= 1) {
        $main_title = "Actions for BSC Responsible Manager $rmname ($total total)";
    } 
    else {
        $main_title = "No actions found for BSC Responsible Manager $rmname";
    }
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<input type=hidden name=actionid value=>";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#fabaaa><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "a.managerid=$rmid";
	actionResults (where => $where);
    }
    print "</TABLE>\n\n";
}

##########################
sub drawResults_Keywords {
##########################
    &drawResults_Keywords_All() if $interfaceLevel eq "all";
}

##############################
sub drawResults_Keywords_All {
##############################
    my $keywordid = $q->param("keyword");
    my $chkOption = $q->param("chkOption");
    &drawQuery_Keywords("all", $keywordid, 0, 1);
    my ($headerFlag, $main_title);

    ## First show all the issues
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema.issuekeyword where keywordid = $keywordid");
    my ($keyword) = $dbh -> selectrow_array ("select description from $schema.keyword where keywordid = $keywordid");
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($headerFlag == 1) {
        $main_title = "Issues associated with keyword $keyword ($total total)";
        $headerFlag = 1;
    } 
    else {
        $main_title = "No issues associated with keyword $keyword";
        $headerFlag = undef;
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "i.issueid in (select ik.issueid from $schema.issuekeyword ik where ik.keywordid = $keywordid)";
	issueResults(where => $where);
    }
    print "</TABLE><BR><BR>";

    ## now do all the commitments
    my ($total) = $dbh->selectrow_array("select count(*) from $schema.commitmentkeyword where keywordid = $keywordid");
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($headerFlag == 1) {
        $main_title = "Commitments associated with keyword $keyword ($total total)";
        $headerFlag = 1;
    } 
    else {
        $main_title = "No commitments associated with keyword $keyword";
        $headerFlag = undef;
    }
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=BLACK SIZE=4><B>$main_title</B></FONT></TD></TR>\n";

    ## If there are records to print, turn on the table header
    if ($headerFlag) {
	my $where = "c.commitmentid in (select commitmentid from $schema.commitmentkeyword where keywordid = $keywordid)";
	commitmentResults(where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Keywords_All -->\n\n";
}

##########################
sub drawResults_Category {
##########################
    &drawResults_Category_All() if $interfaceLevel eq "all";
}

##############################
sub drawResults_Category_All {
##############################
    my $categoryid = $q->param("category");
    &drawQuery_Category("all", "$categoryid", 0, 1);
    my ($headerFlag, $main_title);

    ## First show all issues
    my ($total) = $dbh -> selectrow_array("select count(*) from $schema.issue where categoryid = $categoryid");
    my ($category) = $dbh -> selectrow_array("select description from $schema.category where categoryid = $categoryid");
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($headerFlag == 1) {
        $main_title="Issues associated with category $category ($total total)";
        $headerFlag = 1;
    } 
    else {
        $main_title = "No issues associated with category $category";
        $headerFlag = undef;
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "i.categoryid = $categoryid";
	issueResults(where => $where);
    }
    print "</TABLE><BR><BR>";

    ## now do all the commitments
    ($total) = $dbh -> selectrow_array("select count (*) from $schema.commitment where issueid in (select issueid from $schema.issue where categoryid = $categoryid)");
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($headerFlag == 1) {
        $main_title = "Commitments associated with category $category ($total total)";
        $headerFlag = 1;
    } 
    else {
        $main_title = "No commitments associated with category $category";
        $headerFlag = undef;
    }
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "c.issueid in (select issueid from $schema.issue where categoryid = $categoryid)";
	commitmentResults(where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Category_All -->\n\n";
}

##########################
sub drawResults_SiteName {
##########################
    &drawResults_SiteName_All() if $interfaceLevel eq "all";
}

##############################
sub drawResults_SiteName_All {
##############################
    my $siteid = $q->param("sitename");
    &drawQuery_SiteName("all", "$siteid", 0, 1);

    my ($sitename, $main_title);
    my ($headerFlag);

    ## issues
    my ($total) = $dbh -> selectrow_array("select count(*) from $schema.issue where siteid = $siteid");
    my ($sitename) = $dbh -> selectrow_array("select name from $schema.site where siteid = $siteid");
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($headerFlag == 1) {
        $main_title = "Issues for site $sitename ($total total)";
        $headerFlag = 1;
    } 
    else {
        $main_title = "No issues for site $sitename";
        $headerFlag = undef;
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "i.siteid = $siteid";
	issueResults(where => $where);
    }
    print "</TABLE><BR><BR>";

    ## now do all the commitments
    ($total) = $dbh -> selectrow_array("select count(*) from $schema.commitment where siteid = $siteid");
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    if ($headerFlag == 1) {
        $main_title = "Commitments for site $sitename ($total total)";
        $headerFlag = 1;
    } 
    else {
        $main_title = "No commitments for site $sitename";
        $headerFlag = undef;
    }
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=2 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=tan><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "c.siteid = $siteid";
	commitmentResults(where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_SiteName_All -->\n\n";
}

#######################
sub drawResults_Users {
#######################
    $interfaceLevel = "all";
    &drawResults_Users_All() if $interfaceLevel eq "all";
}

###########################
sub drawResults_Users_All {
###########################
    my ($roleid, $rolename, $sth, $sql, @roleidArray, @rolenameArray);
    my ($fontsize, $bgcolor);
    my ($rowflag, $color, $i, $j, $k);
    my ($sitename, $siteid, @usersidArray, $usersid);
    my ($disciplinename, $disciplinelist);

    $fontsize = 2;
    print "<CENTER>\n";
    print "<INPUT TYPE=HIDDEN NAME=option VALUE=details>\n";
    print "<INPUT TYPE=HIDDEN NAME=theinterface VALUE=users>\n";
    print "<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=enteredby>\n";
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=popup VALUE=>\n";
    print "<SCRIPT LANGUAGE=JavaScript1.2>\n";
    print "\tfunction browseUser(usersid, interfaceLevel) {\n";
    print "\t  document.browse.option.value = \'details\';\n";
    print "\t  document.browse.theinterface.value = \'issues\';\n";
    print "\t  document.browse.interfaceLevel.value = interfaceLevel;\n";
    print "\t  document.browse.id.value = usersid\n";
    print "\t  document.browse.popup.value = \'TRUE\';\n";
    print "\t  document.browse.submit();\n";
    print "\t}\n";
    print "</SCRIPT>\n\n";
    print "<SCRIPT LANGUAGE=JavaScript1.2> if (parent.titlebar) {doSetTextImageLabel('Browse Users'); }</SCRIPT>\n";

    ## Generate the hyperlinks.
    print "<A NAME=top></A>\n";
    print "<TABLE BORDER=0 WIDTH=550><TR><TD VALIGN=TOP><B>\n";
    print "<LI><A HREF=#alpha>Alphabetical Listing</A></LI>\n";

    $sql = "select roleid, description from $schema.role order by description";
    $sth = $dbh -> prepare ($sql);
    $sth -> execute;
    my $count = 0;
    while (($roleid, $rolename) = $sth -> fetchrow_array) {
	print "<LI><A HREF=\"#$rolename\">" . $rolename . "s</A></LI>\n";
	if ($count == 3) {
	    print "<B></TD>\n";
	    print "<TD VALIGN=TOP><B>\n";
	}
	$count++;
    }
    print "<LI><A HREF=\"#Software Developer\">Software Developers</A></LI>\n";
    print "</B></TD></TR></TABLE>\n";
    print "<BR>\n";

    ## Alphabetical Listing of Users
    print "<A NAME=\"alpha\"></A>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD BGCOLOR=#f0e0b0 COLSPAN=3><B>Alphabetical Listing of All Users (by last name)</B></TD></TR>\n";
    print "<TR><TH>Name</TH><TH>Username</TH><TH>Site</TH></TR>\n";

    $sql = "select a.usersid, a.lastname, a.firstname, a.username, b.name from $schema.users a, $schema.site b where a.isactive = 'T' and  a.usersid != 0 and a.siteid = b.siteid(+) order by lastname";
    $sth = $dbh->prepare($sql);
    $sth->execute();

    $color = "#eeeeee";
    while (my ($uid, $lname, $fname, $uname, $site) = $sth->fetchrow_array()) {
        print "<TR bgcolor=$color><TD width=250><FONT SIZE=$fontsize><A HREF='javascript:browseUser($uid, \"enteredby\");'>$fname $lname</A></TD><TD width=250><FONT SIZE=$fontsize>$uname</FONT></TD><TD width=250><FONT SIZE=$fontsize>$site</FONT></TD></TR>\n";
	$color = ($color eq "#eeeeee") ? "#ffffff" : "#eeeeee";
    }
    print "<TR><TD COLSPAN=4 ALIGN=CENTER><A HREF=#top>Back to Top</A></TD></TR>\n";
    print "</TABLE><BR><BR>\n";

    ## Query for the defaultcategoryroles
    print "<A NAME=\"Commitment Coordinator\"></A>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD BGCOLOR=#ffc0ff COLSPAN=3><B>Commitment Coodinators</B></TD></TR>\n";
    print "<TR><TH>Name</TH><TH>Username</TH><TH>Site</TH></TR>\n";

    $sql = "select distinct(a.usersid), u.firstname, u.lastname, 
                   u.username, c.name 
            from $schema.defaultcategoryrole a, $schema.users u, 
                 $schema.site c 
            where $nodevelopers u.isactive='T' and a.usersid = u.usersid(+) 
                  and a.siteid = c.siteid
            order by u.lastname";
    $sth = $dbh -> prepare($sql);
    $sth -> execute();
    $color = "#eeeeee";
    while (my ($uid, $fname, $lname, $uname, $site) = $sth->fetchrow_array()) {
        print "<TR bgcolor=$color><TD width=250><FONT SIZE=$fontsize><A HREF='javascript:browseUser($uid, \"enteredby\");'>$fname $lname</A></TD><TD width=250><FONT SIZE=$fontsize>$uname</FONT></TD><TD width=250><FONT SIZE=$fontsize>$site</FONT></TD></TR>\n";
	$color = ($color eq "#eeeeee") ? "#ffffff" : "#eeeeee";
    }
    print "<TR><TD COLSPAN=4 ALIGN=CENTER><A HREF=#top>Back to Top</A></TD></TR>\n";
    print "</TABLE><BR><BR>\n\n";

    ## Query for DOEDL
    print "<a name=\"DOE Discipline Lead\"></a>\n";
    print "<table width=750 align=center border=1 cellpadding=3 cellspacing=0 bordercolor=#c0c0c0>\n";    
    print "<tr><td colspan=4 bgcolor=#c0c0ff><font color=#000099><b>DOE Discipline Leads</b></font></td></tr>";
    print "<tr><th>Name</th><th>Username</th><th>Site</th><th>Discipline(s)</th></tr>\n";

    my $doedls = $dbh -> prepare ("select distinct u.usersid, u.username, u.firstname, u.lastname, s.name from $schema.users u, $schema.defaultdisciplinerole ddr, $schema.site s where ddr.roleid=3 and u.usersid=ddr.usersid and ddr.siteid=s.siteid order by u.lastname");
    $doedls -> execute;
    my $bg="#eeeeee";
    while (my ($uid, $uname, $fname, $lname, $site) = $doedls -> fetchrow_array) {
	my $disclist = "";
	my $disc = $dbh -> prepare ("select d.description from $schema.discipline d, $schema.defaultdisciplinerole ddr where ddr.usersid=$uid and ddr.disciplineid=d.disciplineid order by d.description");
	$disc -> execute;
	while (my ($discdesc) = $disc -> fetchrow_array) {
	    $disclist .= "<li>$discdesc";
	}
	print "<tr bgcolor=$bg valign=top><td width=25%><font size=2><A HREF='javascript:browseUser($uid, \"enteredby\");'>$fname $lname</a></td><td width=25%><font size=2>$uname</td><td width=25%><font size=2>$site</td><td width=25%><font size=2>$disclist</td></tr>\n";
	$bg = ($bg eq "#eeeeee") ? "#ffffff" : "#eeeeee";
    }
    print "<tr><td colspan=4 align=center><a href=#top>Back to Top</a></td></tr>\n";
    print "</table><br><br>\n\n";

    ## Site Roles
    my $role = $dbh -> prepare ("select distinct r.roleid, r.description from $schema.role r, $schema.defaultsiterole dsr where r.roleid=dsr.roleid order by r.description");
    $role -> execute;
    while (my ($curroleid, $currole) = $role -> fetchrow_array) {
	print "<a name=\"$currole\"></a>\n";
	print "<table width=750 align=center border=1 cellpadding=3 cellspacing=0 bordercolor=#c0c0c0>\n";    
	my $headerback;
	$headerback = "#c0c0ff" if ($curroleid == 7);
	$headerback = "#f0e0b0" if ($curroleid == 6);
	$headerback = "#c0ffc0" if ($curroleid == 5);
	$headerback = "#ffffc0" if ($curroleid == 4);
	$headerback = "#fabaaa" if ($curroleid == 2);
	print "<tr><td colspan=3 bgcolor=$headerback><font color=#000099><b>" . $currole . "s</b></font></td></tr>";
	print "<tr><th>Name</th><th>Username</th><th>Site</th></tr>\n";
	
	my $rolees = $dbh -> prepare ("select distinct u.usersid, u.username, u.firstname, u.lastname, s.name from $schema.users u, $schema.defaultsiterole dsr, $schema.site s where dsr.roleid=$curroleid and u.usersid=dsr.usersid and dsr.siteid=s.siteid order by u.lastname");
	$rolees -> execute;
	my $bg="#eeeeee";
	while (my ($uid, $uname, $fname, $lname, $site) = $rolees -> fetchrow_array) {
	    print "<tr bgcolor=$bg valign=top><td width=250><font size=2><A HREF='javascript:browseUser($uid, \"enteredby\");'>$fname $lname</a></td><td width=250><font size=2>$uname</td><td width=250><font size=2>$site</td></tr>\n";
	    $bg = ($bg eq "#eeeeee") ? "#ffffff" : "#eeeeee";
	}
	$rolees -> finish;
	print "<tr><td colspan=3 align=center><a href=#top>Back to Top</a></td></tr>\n";
	print "</table><br><br>\n\n";
    }
    $role -> finish;

    ## Software Developers
    print "<A NAME=\"Software Developer\"></A>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=750 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD BGCOLOR=#f0e0b0 COLSPAN=3><FONT COLOR=#000099><B>Software Developers</B></FONT></TD></TR>\n";
    print "<TR><TH>Name</TH><TH>Username</TH><TH>Site</TH></TR>\n";

    $sql = "select a.usersid, a.firstname, a.lastname, a.username, b.name from $schema.users a, $schema.site b where a.siteid = b.siteid(+) and a.usersid >= 1000 order by a.lastname";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    $color = "#eeeeee";
    while (my ($uid, $fname, $lname, $uname, $site) = $sth->fetchrow_array()) {
        print "<TR bgcolor=$color><TD width=250><FONT SIZE=$fontsize><A HREF='javascript:browseUser($uid, \"enteredby\");'>$fname $lname</A></TD><TD width=250><FONT SIZE=$fontsize>$uname</FONT></TD><TD width=250><FONT SIZE=$fontsize>$site</FONT></TD></TR>\n";
	$color = ($color eq "#eeeeee") ? "#ffffff" : "#eeeeee";
    }
    print "<TR><TD COLSPAN=4 ALIGN=CENTER><A HREF=#top>Back to Top</A></TD></TR>\n";
    print "</TABLE><BR><BR>";
    print "\n<!-- End of drawResults_Users_All -->\n";
}

#########################
sub drawResults_Letters {
#########################
    &drawResults_Letters_All() if $interfaceLevel eq 'all';
    &drawResults_Letters_CommitmentID() if $interfaceLevel eq 'commitmentid';
    &drawResults_Letters_SignedDate() if $interfaceLevel eq 'signeddate';
    &drawResults_Letters_SentDate() if $interfaceLevel eq 'sentdate';
    &drawResults_Letters_Organization() if $interfaceLevel eq 'organization';
}

#############################
sub drawResults_Letters_All {
#############################
    &drawQuery_Letters(0, undef);
    my ($total) = $dbh->selectrow_array("select count(*) from $schema.letter");
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=770 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>View All Letters ($total total)</TD></TR>\n";
    letterResults();
    print "</TABLE>";
    print "\n<!-- End of drawResults_Letters_All -->\n\n";
}

######################################
sub drawResults_Letters_CommitmentID {
######################################
    my $commitmentid = $q->param("commitmentid");
    &checkForExistence("letters", "commitmentid", "$commitmentid");
    &drawQuery_Letters(1, $commitmentid);
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=770 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>Letters associated with Commitment " . formatID2 ($commitmentid, 'C') . "</B></FONT></TD></TR>\n";
    my $where = "l.letterid in (select letterid from $schema.response where commitmentid = $commitmentid)";
    letterResults(where => $where);
    print "</TABLE>";
    print "\n<!-- End of drawResults_Letters_CommitmentID -->\n\n";
}

####################################
sub drawResults_Letters_SignedDate {
####################################
    my $signeddate_month_f = $q->param("signeddate_month_f");
    my $signeddate_year_f = $q->param("signeddate_year_f");
    my $signeddate_month_t = $q->param("signeddate_month_t");
    my $signeddate_year_t = $q->param("signeddate_year_t");
    my $datestr = "$signeddate_month_f:$signeddate_year_f:$signeddate_month_t:$signeddate_year_t";
    &drawQuery_Letters(3, $datestr);
    my ($date_low, $date_high, $headerFlag, $main_title);
    $date_low = "01-".$signeddate_month_f."-".$signeddate_year_f;
    $date_high = "LAST_DAY(\'01-$signeddate_month_t-$signeddate_year_t\')";
    my ($total) = $dbh->selectrow_array("select count(*) from $schema.letter where signeddate between \'$date_low\' and $date_high");
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    if ($total >= 1) {
        $main_title = "Letters signed between $signeddate_month_f-$signeddate_year_f and $signeddate_month_t-$signeddate_year_t ($total total)";
    } 
    else {
        $main_title = "No Letters found within that date range\n";
    }
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=770 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "l.signeddate between \'$date_low\' and $date_high";
	letterResults(where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Letters_SignedDate -->\n\n";
}

##################################
sub drawResults_Letters_SentDate {
##################################
    my $sentdate_month_f = $q->param("sentdate_month_f");
    my $sentdate_year_f = $q->param("sentdate_year_f");
    my $sentdate_month_t = $q->param("sentdate_month_t");
    my $sentdate_year_t = $q->param("sentdate_year_t");
    my $datestr = "$sentdate_month_f:$sentdate_year_f:$sentdate_month_t:$sentdate_year_t";
    drawQuery_Letters(2, $datestr);
    my ($date_low, $date_high, $headerFlag, $main_title);
    $date_low = "01-".$sentdate_month_f."-".$sentdate_year_f;
    $date_high = "LAST_DAY(\'01-$sentdate_month_t-$sentdate_year_t\')";
    my ($total) = $dbh->selectrow_array("select count(*) from $schema.letter where sentdate between \'$date_low\' and $date_high");
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    if ($total >= 1) {
        $main_title = "Letters sent between $sentdate_month_f-$sentdate_year_f and $sentdate_month_t-$sentdate_year_t ($total total)";
    } 
    else {
        $main_title = "No Letters found within that date range\n";
    }
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=770 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "l.sentdate between \'$date_low\' and $date_high";
	letterResults (where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Letters_SignedDate -->\n\n";
}

######################################
sub drawResults_Letters_Organization {
######################################
    my $organizationid = $q->param("organizationid");
    &drawQuery_Letters(4, $organizationid);
    my ($headerFlag, $main_title, $org_name);
    my ($total) = $dbh->selectrow_array("select count(*) from $schema.letter where organizationid = $organizationid");
    my ($org_name) = $dbh->selectrow_array("select name from $schema.organization where organizationid = $organizationid");
    $headerFlag = undef if $total <= 0;
    $headerFlag = 1 if $total >= 1;
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=><CENTER>\n";
    if ($total >= 1) {
        $main_title = "Letters sent to $org_name ($total total)";
    } 
    else {
        $main_title = "No Letters found associated with $org_name\n";
    }
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=770 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>$main_title</B></FONT></TD></TR>\n";
    if ($headerFlag) {
	my $where = "l.organizationid = $organizationid";
	letterResults (where => $where);
    }
    print "</TABLE>";
    print "\n<!-- End of drawResults_Letters_Organization -->\n\n";
}

#################
sub drawDetails {
#################
    &drawDetails_Issues() if $interface eq "issues";
    &drawDetails_Commitments() if $interface eq "commitments";
    &drawDetails_Responses() if $interface eq "responses";
    &drawDetails_Organizations() if $interface eq "organizations";
    &drawDetails_Historical() if $interface eq "historical";
    &drawDetails_Historical_Issues() if $interface eq "historicalissues";
    &drawDetails_Actions() if $interface eq "actions";
}

########################
sub drawDetails_Issues {
########################
    &drawDetails_Issues_IssueID() if $interfaceLevel eq "issueid";
    &drawDetails_Issues_EnteredBy() if $interfaceLevel eq "enteredby";
    &drawDetails_Issues_SourceDoc() if $interfaceLevel eq "sourcedoc";
}

################################
sub drawDetails_Issues_IssueID {
################################
    print "<INPUT TYPE=HIDDEN NAME=option VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=theinterface VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<SCRIPT LANGUAGE=JavaScript1.2>\n";
    print "\n if (parent.titlebar) { doSetTextImageLabel('Browse Issue'); }\n";
    print "</SCRIPT>\n\n";
    my $issueid = $q->param('id');
    my (@myArray, $color, $fontsize, $rowflag, $sth, $sql, $element);
    my ($source_doc_notice, $accession_notice);
    my ($keywordid, $keyworddescription, $keywordlist);
    $sql = "select a.issueid, a.text, to_char(a.entereddate, 'MM/DD/YYYY'), 
                   a.sourcedocid, a.image, a.imagecontenttype, 
                   a.imageextension, a.page, b.username, e.description, 
                   to_char(a.dateoccurred, 'MM/DD/YYYY'), NULL, 
                   f.name, b.firstname, 
                   b.lastname, b.usersid, g.accessionnum, g.title 
            from $schema.issue a, $schema.users b, $schema.discipline c, 
                 $schema.discipline d, $schema.category e, $schema.site f, 
                 $schema.sourcedoc g 
            where a.issueid = $issueid and a.enteredby = b.usersid(+) and 
            a.categoryid = e.categoryid(+) and a.siteid = f.siteid(+) and 
            a.sourcedocid = g.sourcedocid(+)";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    @myArray = $sth->fetchrow_array();
    $sql = "select a.keywordid, b.description from $schema.issuekeyword a, $schema.keyword b where a.issueid = $issueid and ".
           "a.keywordid = b.keywordid(+)";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($keywordid, $keyworddescription) = $sth->fetchrow_array()){
        $keywordlist = $keywordlist."<LI>$keyworddescription</LI>";
    }
    $keywordlist = "&nbsp;" if $keywordlist eq "";

    ## This is for the View Image section
    my $image_notice = "<FONT COLOR=#101010>Image Not Available</FONT>";

    if ($myArray[4] ne "") {
        my $image = $CMSFullImagePath."/issueimage$issueid$myArray[6]";
        open (OUTFILE, "| ./File_Utilities.pl --command writeFile --protection 0664 --fullFilePath $image");
            print OUTFILE $myArray[4];
        close (OUTFILE);

        $image_notice = "<A HREF=\"javascript:openWindow(\'$CMSImagePath/issueimage$issueid$myArray[6]\');\">View Image</A>";
    }
    my $display_issue = "I"."0" x (5 - length($myArray[0])).$myArray[0];

    if ($myArray[16] ne "") {
        $accession_notice = "<A HREF=\"javascript:openWindow(\'http://rms.ymp.gov/cgi-bin/get_record.com?$myArray[16]\');\">$myArray[16]</A>";
#        $accession_notice = "<A HREF=\"javascript:openWindow(\'http://ym1701.ymp.gov/scripts/get_record.com?$myArray[16]\');\">$myArray[16]</A>";
    } 
    else {
        $accession_notice = "Not Available";
    }
    foreach $element (@myArray) {
        $element = "Not Available" if $element eq "";
    }
    $myArray[1] =~ s/\n/<BR>/g;  # suggested resolution
    $myArray[11] =~ s/\n/<BR>/g; # text
    print "<BR><BR>";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=650 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD BGCOLOR=#cdecff COLSPAN=2><FONT COLOR=#000099 SIZE=4><B>Issue Information</B></FONT></TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee WIDTH=120><B>ID</B></TD><TD BGCOLOR=#eeeeee><b>$display_issue</b></TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff><B>Category</B></TD><TD BGCOLOR=#ffffff>$myArray[9]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee><B>Site</B></TD><TD BGCOLOR=#eeeeee>$myArray[12]</A></TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff VALIGN=TOP><B>Issue Text</B></TD><TD BGCOLOR=#ffffff WIDTH=400 VALIGN=TOP>$myArray[1]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee><B>Date Issue Occurred</B></TD><TD BGCOLOR=#eeeeee>$myArray[10]</A></TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff WIDTH=200><B>Date Entered</B></TD><TD BGCOLOR=#ffffff WIDTH=400>$myArray[2]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee><B>Entered By</B></TD><TD BGCOLOR=#eeeeee><A HREF=\"javascript:browseDetails(\'issues\',\'enteredby\',$myArray[15]);\"> $myArray[13] $myArray[14]</A></TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff VALIGN=TOP><B>Keywords</B></TD><TD BGCOLOR=#ffffff VALIGN=TOP>$keywordlist</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee><B>Source Accession #</B></TD><TD BGCOLOR=#eeeeee>$accession_notice</TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff valign=top><B>Source&nbspDocument&nbspTitle</B></TD><TD BGCOLOR=#ffffff>$myArray[17]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee><B>Issue Starts on Page</B></TD><TD BGCOLOR=#eeeeee>$myArray[7]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff><B>Issue Image</B></TD><TD BGCOLOR=#ffffff>$image_notice</TD></TR>\n";
    print "<tr bgcolor=#eeeeee valign=top><td><b>Associated&nbspCommitments</b></td><td>";
    my $commsql = "select commitmentid, text from $SCHEMA.commitment where issueid=$issueid order by commitmentid";
    my $commcsr = $dbh -> prepare ($commsql);
    $commcsr -> execute;
    my $rows = 0;
    my $outstr = "";
    while (my @values = $commcsr -> fetchrow_array) {
	my $commstr = "C" . substr ("0000$values[0]",-5);
	my $short = getDisplayString ($values[1],50);
	$outstr .= "<li><a href=\"javascript:browseDetails(\'commitments\',\'commitmentid\',$values[0]);\">$commstr</a> - $short<br>\n";
	$rows++;
    }
    $commcsr -> finish;
    if ($rows != 0) {
	print $outstr;
    }
    else {
	print "None";
    }
    print "</td></tr>";
    print "</TABLE>\n<!-- End of drawDetails_Issues_IssueID -->\n\n";
    print "<BR><BR><TABLE CELLPADDING=3 CELLSPACING=0 BORDER=0>\n";
    print doRemarksTable (iid => $issueid, dbh => $dbh, schema => $schema);
    print "</TABLE>";
}

##################################
sub drawDetails_Issues_EnteredBy {
##################################
    my $entered_by = $q->param('id');
    my (@myArray, $color, $fontsize, $rowflag, $sth, $sql, $sql2, $element);
    my ($source_doc_notice, $usersid, $description, $rights);
    my ($extension, $role, @myArray2);

    $sql = "select a.usersid, a.lastname, a.firstname, a.areacode,
                   a.phonenumber, a.extension, a.email, b.name,
                   a.username, a.location, a.organization 
            from $schema.users a, $schema.site b 
            where a.usersid = $entered_by and a.siteid = b.siteid(+)";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    @myArray = $sth->fetchrow_array();
    my $prefix = substr($myArray[4], 0, 3);
    my $postfix = substr($myArray[4], 3,4);
    $myArray[4] = $prefix."-".$postfix;
    $extension = "Ext. ".$myArray[5] if $myArray[5] ne undef();
    foreach $element (@myArray) {
        $element = "&nbsp;" if $element eq "";
    }
    ## Build the list for the Role(s)
    ## Query 3 -- Select the defaultcategoryroles.
    $sql = "select count(*) from $schema.defaultcategoryrole where usersid=$entered_by";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (@myArray2 = $sth->fetchrow_array()) {
	if ($myArray2[0]>0) {
	    $role = $role . "<li> Commitment Coordinator";
	}
    }
    ## Query 1 -- Select the defaultsiteroles and the sitename
    $sql = "select distinct a.roleid, d.description from $schema.defaultsiterole a, $schema.site c, $schema.role d, $schema.users e where a.usersid = $entered_by and c.siteid = a.siteid(+) and d.roleid = a.roleid and e.usersid = a.usersid";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (@myArray2 = $sth->fetchrow_array()) {
        $role = $role."<LI>$myArray2[1]</LI>";
    }
    ## Query 2 -- Select the defaultdisciplineroles.
    $sql = "select a.disciplineid, b.description || ' - ' || a.description 
            from $schema.discipline a, $schema.role b, $schema.users c, 
                 $schema.defaultdisciplinerole d 
            where d.usersid = $entered_by and 
                  a.disciplineid = d.disciplineid(+) 
                  and b.roleid = d.roleid and c.usersid = d.usersid 
            order by b.description, a.disciplineid";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    if ($entered_by > 1000) {
	$role = "<li>Software Developer";
    }
    else {
	while (@myArray2 = $sth->fetchrow_array()) {
	    $role = $role."<LI>$myArray2[1]</LI>";
	}
    }
    $rights = "&nbsp;" if $rights eq "";
    $role = "&nbsp;" if $role eq "";
    my $location = ($myArray[9] && $myArray[9] ne "&nbsp;") ? $myArray[9] : "Not Available";
    my $organization = ($myArray[10] && $myArray[10] ne "&nbsp;") ? $myArray[10] : "Not Available";
    print "\n <SCRIPT LANGUAGE=JavaScript1.2> if (parent.titlebar) { doSetTextImageLabel('Browse User'); } </SCRIPT>\n";
    print "<BR><BR>";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=650 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD BGCOLOR=#f0e0b0 COLSPAN=2><FONT COLOR=#000099 SIZE=4><B>User Information</TD></TR>\n";
    print "<TR BGCOLOR=#eeeeee><TD WIDTH=200><B>ID</B></TD><TD>$myArray[0]</TD></TR>\n";
    print "<TR BGCOLOR=#ffffff><TD><B>Username</B></TD><TD>$myArray[8]</TD></TR>\n";
    print "<TR BGCOLOR=#eeeeee><TD><B>Name</B></TD><TD WIDTH=500>$myArray[2] $myArray[1]</TD></TR>\n";
    print "<TR BGCOLOR=#ffffff><TD><B>Phone Number</B></TD><TD>($myArray[3]) $myArray[4] $extension</TD></TR>\n";
    print "<TR BGCOLOR=#eeeeee><TD><B>Email</B></TD><TD WIDTH=500>$myArray[6]</TD></TR>\n";
    print "<TR BGCOLOR=#ffffff><TD><B>Location</B></TD><TD>$location</TD></TR>\n";
    print "<TR BGCOLOR=#eeeeee><TD><B>Organization</B></TD><TD>$organization</TD></TR>\n";
    print "<TR BGCOLOR=#ffffff><TD><B>Site</B></TD><TD>$myArray[7]</TD></TR>\n";
    print "<TR BGCOLOR=#eeeeee><TD VALIGN=TOP><B>Role(s)</B></TD><TD>$role</TD></TR>\n";
    print "</TABLE>\n<!-- End of drawDetails_Issues_EnteredBy -->\n\n";
}

##################################
sub drawDetails_Issues_SourceDoc {
##################################
    my $issueid = $q -> param("id");
    my (@myArray, $color, $fontsize, $rowflag, $sth, $sql, $element, $display_issue, $accession_notice);
    my ($sourcedocid, $parent_org_display);
    $sql = "select sourcedocid from $schema.issue where issueid = $issueid";
    $sth = $dbh -> prepare($sql);
    $sth->execute();
    ($sourcedocid) = $sth -> fetchrow_array();

    $sql = "select a.accessionnum, a.title, 
                   to_char(a.documentdate, 'MM/DD/YYYY'), 
                   a.signer, a.organizationid, c.name 
            from $schema.sourcedoc a, $schema.organization c 
            where a.sourcedocid = $sourcedocid and 
                  a.organizationid = c.organizationid(+)";
    $sth = $dbh -> prepare($sql);
    $sth -> execute();
    @myArray = $sth -> fetchrow_array();
    my ($accnum, $title, $docdate, $signer, $orgid, $orgname) = @myArray;
    if ($accnum ne "") {
        $accession_notice = "<A HREF=\"javascript:openWindow(\'http://rms.ymp.gov/cgi-bin/get_record.com?$accnum\');\">$accnum</A>";
    } 
    else {
        $accession_notice = "Not Available";
    }
#    foreach $element (@myArray) {
#        $element = "&nbsp;" if $element eq "";
#    }
    if ($orgid) {
        $parent_org_display = "<A HREF=\"javascript:browseDetails(\'organizations\', \'organizationinfo\', $orgid);\">$orgname</A>";
    } 
    else {
        $parent_org_display = "Not Available";
    }
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=option VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=theinterface VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=>\n";
    print "<BR>";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=650 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD BGCOLOR=#f0e0b0 COLSPAN=2><FONT COLOR=#000099 SIZE=4><B>Issue Source Information</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee width=200><B>Accession #</B></TD><TD BGCOLOR=#eeeeee>$accession_notice</TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff valign=top><B>Title</B></TD><TD BGCOLOR=#ffffff>$title</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee><B>Document Date</B></TD><TD BGCOLOR=#eeeeee>$docdate</TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff><B>Originating&nbsp;Organization</B></TD><TD BGCOLOR=#ffffff>$parent_org_display&nbsp;</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee><B>Signer</B></TD><TD BGCOLOR=#eeeeee>$signer</TD></TR>\n";
    print "</TABLE>\n<!-- End of drawDetails_Issues_EnteredBy -->\n\n";
    $sth->finish();
    print "</TABLE>";
    print "\n<!-- End of drawResults_Issues_SourceDocID -->\n\n";
}

#############################
sub drawDetails_Commitments {
#############################
    &drawDetails_Commitments_CommitmentID() if $interfaceLevel eq "commitmentid";
    &drawDetails_Commitments_ResponseLetter() if $interfaceLevel eq "responseletter";
}

##########################################
sub drawDetails_Commitments_CommitmentID {
##########################################
    print "<INPUT TYPE=HIDDEN NAME=option VALUE=details>\n";
    print "<INPUT TYPE=HIDDEN NAME=theinterface VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=details>\n";
    print "<input type=hidden name=actionid value=>\n";

    my $commitmentid = $q->param('id');
    my (@myArray, $color, $fontsize, $rowflag, $sth, $sql, $element);
    my ($display_issue, $i, $approver, $updatedby);
    my ($keywordid, $keyworddescription, $keywordlist);
    my ($licensingid, $licensinglead, $licensinglist, $response_display);
    my ($productid, $productdescription, $productlist);

    $sql = "select a.commitmentid, to_char(a.duedate, 'MM/DD/YYYY'), 
                   b.description, to_char(a.commitdate, 'MM/DD/YYYY'),
                   a.estimate, a.functionalrecommend, 
                   a.closingdocimage, a.text, a.rejectionrationale,
                   a.resubmitrationale, a.actionstaken, a.actionsummary, 
                   a.actionplan, a.cmrecommendation, 
                   to_char(a.closeddate, 'MM/DD/YYYY'), a.controlaccountid,
                   a.issueid, a.approver, a.replacedby, a.updatedby, 
                   d.description, a.oldid, e.description,  
                   g.name, a.imageextension, c.firstname,
                   c.lastname, i.firstname, i.lastname, b.statusid,
                   to_char(a.fulfilldate, 'MM/DD/YYYY'), a.externalid, 
                   a.lleadid, a.managerid, a.doemanagerid,
                   to_char(a.dateduetonrc,'MM/DD/YYYY') 
            from $schema.commitment a, $schema.status b, $schema.users c,
                 $schema.commitmentlevel d, $schema.discipline e, 
                 $schema.site g, $schema.users i 
            where a.commitmentid = $commitmentid and a.statusid = b.statusid(+)
                  and a.approver = c.usersid(+) and 
                  a.commitmentlevelid = d.commitmentlevelid(+) and 
                  a.primarydiscipline = e.disciplineid(+) and 
                  a.siteid = g.siteid(+) and a.updatedby = i.usersid 
            order by a.commitmentid";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    @myArray = $sth->fetchrow_array();
    my ($cid, $duedate, $status, $commitdate, $estimate, $doerec, 
        $closingimage, $ctext, $rejrat,
        $resubrat, $ataken, $actsum, $aplan, $cmrec,
        $closedate, $accnum, $iid, $cmaker, $replacedby,
        $updatedbyid, $clevel, $oldid, $pdisc, 
        $site, $imgext, $cmakerfname, $cmakerlname,
        $updatedbyfname, $updatedbylname, $statid, 
        $fulfildate, $extid, $llid, $rmid, $doermid, $nrcdate) = @myArray;
    ## Keywords
    $sql = "select a.keywordid, b.description from $schema.commitmentkeyword a, $schema.keyword b where a.commitmentid = $commitmentid and ".
           "a.keywordid = b.keywordid(+)";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($keywordid, $keyworddescription) = $sth->fetchrow_array()){
        $keywordlist = $keywordlist."<LI>$keyworddescription</LI>";
    }
    $keywordlist = "None" if $keywordlist eq "";

    ## Products
    $sql = "select a.productid, b.description from $schema.productaffected a, $schema.product b where a.commitmentid = $commitmentid and a.productid = b.productid(+)";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    while (($productid, $productdescription) = $sth->fetchrow_array()){
        $productlist = $productlist."<LI>$productdescription</LI>";
    }
    $productlist = "None" if $productlist eq "";

    ## This is for the View Image section
    my $image_notice = "<FONT COLOR=#101010>Image Not Available</FONT>";
    if ($closingimage ne "") {
        my $image = $CMSFullImagePath."/closingdoc$commitmentid$imgext";
        open (OUTFILE, "| ./File_Utilities.pl --command writeFile --protection 0664 --fullFilePath $image");
            print OUTFILE $closingimage;
        close (OUTFILE);

        $image_notice = "<A HREF=\"javascript:openWindow(\'$CMSImagePath/closingdoc$commitmentid$imgext\');\">View Image</A>";
    }

    ## Replace all nulls with something that the web browser will understand.
    if ($resubrat eq "") {
	$resubrat = "N/A";
    }
    if ($oldid eq "") {
	$oldid = "N/A";
    }
    foreach $element (@myArray) {
        $element = "Not Available" if $element eq "";
	$element = "None Entered" if $element eq " ";
    }
    $estimate =~ s/\n/<BR>/g;
    $doerec =~ s/\n/<BR>/g;
    $ctext =~ s/\n/<BR>/g;
    $rejrat =~ s/\n/<BR>/g;
    $resubrat =~ s/\n/<BR>/g;
    $ataken =~ s/\n/<BR>/g;
    $actsum =~ s/\n/<BR>/g;
    $aplan =~ s/\n/<BR>/g;
    $cmrec =~ s/\n/<BR>/g;

    ## Format the commitmentid
    my $display_commitment = formatID2 ($commitmentid, 'C');
    ## Format the issueid
    if ($iid ne '&nbsp;') {
        $display_issue = "<A HREF=\"javascript:browseDetails(\'issues\',\'issueid\', $iid)\;\">" . formatID2 ($iid, 'I') . "</A>";
    } 
    else {
        $display_issue = "&nbsp;"
    }
    ## Format the approver
    if ($cmaker ne "") {
        $approver = "<A HREF=\"javascript:browseDetails(\'issues\',\'enteredby\', $cmaker)\;\">$cmakerfname $cmakerlname</A>";
    } 
    else {
        $approver = "Not Available";
    }
    ## Format the updatedby field
    if ($updatedbyid ne "") {
        $updatedby = "<A HREF=\"javascript:browseDetails(\'issues\',\'enteredby\', $updatedbyid)\;\">$updatedbyfname $updatedbylname</A>";
    } 
    else {
        $updatedby = "Not Available";
    }
    my $issue_doc_display = "<A HREF=\"javascript:browseIssue($iid)\">View Issue Document</A>";
    my $first_response_display = "<A HREF=\"javascript:browseResponse(\'firstresponse\', $commitmentid)\">View First Response</A>";
    my $final_response_display = "<A HREF=\"javascript:browseResponse(\'finalresponse\', $commitmentid)\">View Final Response</A>";
    ## Format the first/final response display
    if ($statid != 16) {
        $final_response_display = "<FONT COLOR=#101010>Document Not Available</FONT>";
    }
    if ($statid < 8) {
        $first_response_display = "Document Not Available";
    }
    ## Get and format WBS description
    my $wbs = "";
    if ($accnum ne "") {
        my ($getwbs) = $dbh -> selectrow_array ("select description from $SCHEMA.workbreakdownstructure where controlaccountid = '$accnum'");
	$wbs = $accnum . " - " . $getwbs;
    }
    else {
        $wbs = "Not Available";
    }
    ## Format the fulfillment date
    $fulfildate = "To Be Determined" if !$fulfildate;
    ## Is commitment approved or rejected?
    my $aprej;
    if ($statid == 7 || $statid == 8) {
        $aprej = "Rejection";
    }
    else {
        $aprej = "Approval";
    }
    print "<SCRIPT LANGUAGE=JavaScript1.2>\n";
    print "function browseResponse(type, id) {\n";
    print "\t document.browse.option.value = \'details\'\n";
    print "\t document.browse.theinterface.value = \'commitments\'\n";
    print "\t document.browse.interfaceLevel.value = \'responseletter\'\n";
    print "\t document.browse.type.value = type;\n";
    print "\t document.browse.id.value = id;\n";
    print "\t document.browse.submit();\n";
    print "}\n\n";

    print "function browseIssue(id) {\n";
    print "\t document.browse.option.value = \'details\'\n";
    print "\t document.browse.theinterface.value = \'issues\'\n";
    print "\t document.browse.interfaceLevel.value = \'sourcedoc\'\n";
    print "\t document.browse.id.value = id;\n";
    print "\t document.browse.submit();\n";
    print "}\n\n";
    print "if (parent.titlebar) { doSetTextImageLabel('Browse Commitment'); }\n\n</SCRIPT>\n<BR><BR>\n";
    print "<INPUT TYPE=HIDDEN NAME=type VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=650 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD BGCOLOR=tan COLSPAN=2><FONT COLOR=#000099 SIZE=4><B>Commitment Information</TD></TR>\n";
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD WIDTH=250><B>Commitment ID</B></TD><TD width=400><b>$display_commitment</b></TD></TR>\n";
    print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Status</B></TD><TD>$status</TD></TR>\n";
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>Site</B></TD><TD>$site</TD></TR>\n";
    print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Commitment Text</B></TD><TD VALIGN=TOP>$ctext</TD></TR>\n";
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>Issue ID</B></TD><TD>$display_issue</TD></TR>\n";
    print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Issue Source Document</B></TD><TD>$issue_doc_display</TD></TR>\n";
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>Due&nbspto&nbspCommitment&nbspMaker</B></TD><TD>$duedate</TD></TR>\n";
    $commitdate = "Not Available" if !$commitdate;
    print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>$aprej Date</B></TD><TD>$commitdate</TD></TR>\n";
    $nrcdate = ($nrcdate) ? $nrcdate : "Not Available";
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>Date Due To Originator</B></TD><TD>$nrcdate&nbsp;</TD></TR>\n";
    if ($statid != 7 && $statid != 8) {
        print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Fulfillment Date Estimate</B></TD><TD>$fulfildate</TD></TR>\n";
	$closedate = "Not Available" if !$closedate;
        print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>Closing Date</B></TD><TD>$closedate</TD></TR>\n";
    }
    print "<tr bgcolor=#ffffff valign=top><td><b>Associated&nbsp;Historical&nbsp;Commitments</b></td><td>\n";
    my $hiscom = $dbh -> prepare ("select historicalid from $SCHEMA.commitmenthistory where commitmentid = $commitmentid");
    $hiscom -> execute;
    my $howmany = 0;
    while (my @values = $hiscom -> fetchrow_array) {
	my ($historicalid, $historicaltext) = $dbh -> selectrow_array ("select commitmentid, text from oncs.commitment where commitmentid = $values[0]");
	print "<li><a href=\"javascript:browseHistorical($historicalid)\;\">" . formatID2 ($historicalid, 'HC') . "</a> - " . getDisplayString ($historicaltext, 40) . "<br>\n";
	$howmany ++;
    }
    $hiscom -> finish;
    if ($howmany == 0) {
	print "None";
    }
    print "</td></tr>\n";
    print "<tr bgcolor=#eeeeee valign=top><td><b>Associated&nbsp;Actions</b></td><td>\n";
    my $acts = $dbh -> prepare ("select actionid, text from $SCHEMA.action where commitmentid = $commitmentid order by actionid");
    $acts -> execute;
    $howmany = 0;
    while (my ($actionid, $actiontext) = $acts -> fetchrow_array) {
	print "<li><a href=\"javascript:browseAction($actionid,$commitmentid)\;\">" . formatID2 ($commitmentid, 'CA') . "/" . substr("00$actionid",-3) . "</a> - " . getDisplayString ($actiontext, 40) . "<br>\n";
	$howmany ++;
    }
    $acts -> finish;
    if ($howmany == 0) {
	print "None";
    }
    print "</td></tr>\n";
    $extid = "None" if !$extid;
    print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>External ID</B></TD><TD>$extid</TD></TR>\n";
    my $licensinglead = "Not Available";
    if ($llid) {
	($licensinglead) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from $schema.users where usersid = $llid");
    }
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>BSC Discipline Lead</B></TD><TD>$licensinglead</TD></TR>\n";
    my $responsiblemanager = "Not Available";
    if ($rmid) {
	($responsiblemanager) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from $schema.responsiblemanager where responsiblemanagerid = $rmid");
    }
    my $doemanager = "Not Available";
    if ($doermid) {
	($doemanager) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from $schema.responsiblemanager where responsiblemanagerid = $doermid");
    }
    print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>BSC Responsible Manager</B></TD><td>$responsiblemanager</TD></TR>\n";
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>DOE Responsible Manager</B></TD><td>$doemanager&nbsp;</TD></TR>\n";
    print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Discipline</B></TD><TD>$pdisc</TD></TR>\n";
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>Keywords</B></TD><TD>$keywordlist</TD></TR>\n";
    print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Level of Commitment</B></TD><TD>$clevel&nbsp;</TD></TR>\n";
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>WBS</B></TD><TD>$wbs</TD></TR>\n";
    $estimate = "Not Available" if !$estimate;
    print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Estimate</B></TD><TD VALIGN=TOP>$estimate</TD></TR>\n";
    $aplan = "Not Available" if !$aplan;
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>Action Plan</B></TD><TD VALIGN=TOP>$aplan</TD></TR>\n";
    $actsum = "Not Available" if !$actsum;
    print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Action Summary</B></TD><TD VALIGN=TOP>$actsum</TD></TR>\n";
    $doerec = "Not Available" if !$doerec;
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>DOE Lead Recommendation</B></TD><TD VALIGN=TOP>$doerec</TD></TR>\n";
    print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Products Affected</B></TD><TD>$productlist</TD></TR>\n";
    $cmrec = "Not Available" if !$cmrec;
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>Manager Recommendation</B></TD><TD VALIGN=TOP>$cmrec</TD></TR>\n";
    print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Commitment Maker</B></TD><TD>$approver</TD></TR>\n";
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>First Response</B></TD><TD>$first_response_display</TD></TR>\n";
    if ($status eq 'Rejected' || $status eq 'Commitment Rejection Letter') {
        print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Rejection Rationale</B></TD><TD VALIGN=TOP>$rejrat</TD></TR>\n";
        print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>Rejection Document Image</B></TD><TD VALIGN=TOP>$image_notice</TD></TR>\n";
    }
    else {
	$ataken = "Not Available" if !$ataken;
        print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Action(s) Taken</B></TD><TD VALIGN=TOP>$ataken</TD></TR>\n";
        print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>Final Response</B></TD><TD>$final_response_display</TD></TR>\n";
        print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Closing Document Image</B></TD><TD VALIGN=TOP>$image_notice</TD></TR>\n";
        print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>Resubmit Rationale</B></TD><TD VALIGN=TOP>$resubrat</TD></TR>\n";
    }
    print "<TR bgcolor=#ffffff VALIGN=TOP><TD><B>Old ID</B></TD><TD>$oldid</TD></TR>\n";
    print "<TR bgcolor=#eeeeee VALIGN=TOP><TD><B>Last Updated By</B></TD><TD>$updatedby</TD></TR>\n";

    print "</TABLE>\n<!-- End of drawDetails_Commitments_CommitmentID -->\n\n";

    print "<BR><BR>\n<TABLE CELLPADDING=3 CELLSPACING=0 BORDER=0 align=center>\n";
    print doRemarksTable (cid => $commitmentid, dbh => $dbh, schema => $schema);
    print "</TABLE>";
    print "<script language=javascript><!--\n";
    print "function browseHistorical(id) {\n";
    print "    var script = \'browse\';\n";
    print "    window.open (\"\", \"historicalwin\", \"height=350, width=750, status=yes, scrollbars=yes\");\n";
    print "    document.$form.target = \'historicalwin\';\n";
    print "    document.$form.action = \'$path\' + script + \'.pl\';\n";
    print "    document.$form.option.value = \'details\';\n";
    print "    document.$form.theinterface.value = \'historical\';\n";
    print "    document.$form.interfaceLevel.value = \'historicalid\';\n";
    print "    document.$form.id.value = id;\n";
    print "    document.$form.submit();\n";
    print "}\n\n";
    print "//-->\n</script>\n";
}

#########################
sub drawDetails_Actions {
#########################
    if ($interfaceLevel eq "allactions") {
	&allActions;
    }
    else {
    print "<INPUT TYPE=HIDDEN NAME=option VALUE=details>\n";
    print "<INPUT TYPE=HIDDEN NAME=theinterface VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=details>\n";
    my $commitmentid = $q -> param ('id');
    my $actionid = $q -> param ('actionid');
    print "<input type=hidden name=id value=$commitmentid>\n";
    my $actinf = "select a.text, to_char(a.duedate, 'MM/DD/YYYY'), a.actionstaken, to_char(a.closedate,'MM/DD/YYYY'), a.status, a.dleadid, a.lleadid, a.managerid, s.name, a.updatedby, a.reworkrationale from $schema.action a, $schema.site s where a.actionid=$actionid and a.commitmentid=$commitmentid and a.siteid=s.siteid"; 
#    print STDERR "$actinf\n";
    my ($text, $duedate, $ataken, $closedate, $status, $dlid, $llid, $mgrid, $siteid, $updatedby, $rework) = $dbh -> selectrow_array ($actinf);
    print "<br><br><table align=center border=1 bordercolor=#c0c0c0 cellspacing=0 cellpadding=3 width=650><tr bgcolor=#fabaaa><td colspan=2><font size=+1><b>Details for Action " . formatID2($commitmentid, 'CA') . "/" . substr("00$actionid",-3) . "</td></tr>\n";
    print "<tr bgcolor=#eeeeee valign=top><td width=250><b>Action ID</td><td><b>" . formatID2($commitmentid, 'CA') . "/" . substr("00$actionid",-3) ."</td></tr>\n";
    print "<tr bgcolor=#ffffff valign=top><td><b>Commitment ID</td><td><a href=javascript:browseDetails(\'commitments\',\'commitmentid\',$commitmentid)>" . formatID2($commitmentid, 'C') . "</a></td></tr>\n";
    print "<tr bgcolor=#eeeeee valign=top><td><b>Due Date</td><td>$duedate</td></tr>\n";
    $closedate = "Open Action" if !$closedate;
    print "<tr bgcolor=#ffffff valign=top><td><b>Date Closed</td><td>$closedate</td></tr>\n";
    print "<tr bgcolor=#eeeeee valign=top><td><b>Status</td><td>$status</td></tr>\n";
    print "<tr bgcolor=#ffffff valign=top><td><b>Site</td><td>$siteid</td></tr>\n";
    my ($disclead) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from $schema.users where usersid = $dlid");
    print "<tr bgcolor=#eeeeee valign=top><td><b>BSC Discipline Lead</td><td>$disclead</td></tr>\n";
    my ($liclead) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from $schema.users where usersid = $llid");
    print "<tr bgcolor=#ffffff valign=top><td><b>BSC Licensing Lead</td><td>$liclead</td></tr>\n";
    my ($manager) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from $schema.responsiblemanager where responsiblemanagerid = $mgrid");
    print "<tr bgcolor=#eeeeee valign=top><td><b>BSC Responsible Manager</td><td>$manager</td></tr>\n";
    print "<tr bgcolor=#ffffff valign=top><td><b>Action Text</td><td>$text</td></tr>\n";
    $ataken = "Not Available" if !$ataken;
    print "<tr bgcolor=#eeeeee><td><b>Fulfillment Information</td><td>$ataken</td></tr>\n";
    $rework = "N/A" if !$rework;
    print "<tr bgcolor=#ffffff valign=top><td><b>Rationale for Rework</td><td>$rework</td></tr>\n";
    my ($upbyname) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from $schema.users where usersid = $updatedby");
    print "<tr bgcolor=#eeeeee valign=top><td><b>Updated By</td><td>$upbyname</td></tr>\n";
    print "</table>\n";
    print "<BR><BR>\n<TABLE CELLPADDING=3 CELLSPACING=0 BORDER=0 align=center>\n";
    print doRemarksTable (cid => $commitmentid, aid => $actionid, dbh => $dbh, schema => $schema);
    print "</TABLE>";
}
}

############################
sub drawDetails_Historical {
############################
    print "<INPUT TYPE=HIDDEN NAME=option VALUE=details>\n";
    print "<INPUT TYPE=HIDDEN NAME=theinterface VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=details>\n";

    my $historicalid = $q->param('id');
    my $commitmentinfo = "select statusid, text, issueid, to_char(commitdate,'MM/DD/YYYY'), primarydiscipline, commitmentlevelid, oldid, actionplan, actionsummary, functionalrecommend, cmrecommendation, approver, actionstaken from oncs.commitment where commitmentid = $historicalid";
    my ($statusid, $text, $issueid, $commitdate, $disciplineid, $locid, $oldid, $aplan, $asummary, $doerecommend, $cmrecommend, $cmakerid, $ataken) = $dbh-> selectrow_array ($commitmentinfo);
    my ($status) = $dbh -> selectrow_array ("select description from oncs.status where statusid = $statusid");
    my ($discipline) = $dbh -> selectrow_array ("select description from oncs.discipline where disciplineid = $disciplineid") if $disciplineid;
    $discipline = "Not Available" if $disciplineid eq "";
    my ($loc) = $dbh -> selectrow_array ("select description from oncs.commitmentlevel where commitmentlevelid = $locid") if $locid;
    $loc = "Not Available" if $locid eq "";
    $oldid = "N/A" if $oldid eq "";
    my ($cmaker) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from oncs.users where usersid = $cmakerid");

    print "<br><br><table width=650 border=1 align=center cellpadding=3 cellspacing=0 bordercolor=#c0c0c0><th bgcolor=yellow align=left colspan=2>Historical Commitment Information</th>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Historical Commitment ID</b></td><td valign=top><b>" . formatID2($historicalid, 'HC') ."</b></td></tr>\n";
    print "<tr bgcolor=#ffffff valign=top><td><b>Status</b></td><td valign=top>$status</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Text</b></td><td valign=top>$text</td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Approval Date</b></td><td valign=top>$commitdate</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Issue ID</b></td><td valign=top><a href=\"javascript:browseDetails(\'historicalissues\',\'historicalid\',$issueid);\">" . formatID2($issueid, 'HI') . "</a></td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Discipline</b></td><td valign=top>$discipline</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Level of Commitment</b></td><td valign=top>$loc</td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Old ID</b></td><td valign=top>$oldid</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Keywords</b></td><td valign=top>\n";
    my $keywords = $dbh -> prepare ("select k.description from oncs.keyword k, oncs.commitmentkeyword ck where ck.commitmentid = $historicalid and k.keywordid = ck.keywordid");
    $keywords -> execute;
    my $howmany = 0;
    while (my @values = $keywords -> fetchrow_array) {
	print "<li>$values[0]<br>\n";
	$howmany ++;
    }
    $keywords -> finish;
    print "None" if $howmany == 0;
    print "</td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Affected Products</b></td><td valign=top>\n";
    my $products = $dbh -> prepare ("select p.description from oncs.product p, oncs.productaffected pa where pa.commitmentid = $historicalid and p.productid = pa.productid");
    $products -> execute;
    $howmany = 0;
    while (my @values = $products -> fetchrow_array) {
	print "<li>$values[0]<br>\n";
	$howmany ++;
    }
    $products -> finish;
    print "None" if $howmany == 0;
    print "</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Commitment Maker</b></td><td valign=top>$cmaker</td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Action Plan</b></td><td valign=top>$aplan</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Action Summary</b></td><td valign=top>$asummary</td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>DOE&nbspLead&nbspRecommendation</b></td><td valign=top>$doerecommend</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Manager Recommendation</b></td><td valign=top>$cmrecommend</td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Actions Taken</b></td><td valign=top>$ataken</td></tr>\n";
    print "</table>\n";
    print "<BR><BR>";
    print "<INPUT TYPE=HIDDEN NAME=type VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
}

###################################
sub drawDetails_Historical_Issues {
###################################
    print "<INPUT TYPE=HIDDEN NAME=option VALUE=details>\n";
    print "<INPUT TYPE=HIDDEN NAME=theinterface VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=>\n";

    my $hissueid = $q->param('id');

    my $issueinfo = "select text, categoryid, to_char(dateoccurred,'MM/DD/YYYY'), to_char(entereddate,'MM/DD/YYYY'), enteredby, imageextension, sourcedocid, page from oncs.issue where issueid = $hissueid";
    my ($text, $categoryid, $dateoccurred, $dateentered, $enteredbyid, $ext, $sourceid, $pages) = $dbh -> selectrow_array ($issueinfo);
    my ($category) = $dbh -> selectrow_array ("select description from oncs.category where categoryid = $categoryid") if $categoryid;
    $category = "Not Available" if $categoryid eq "";
    my ($enteredby) = $dbh -> selectrow_array ("select firstname || ' ' || lastname from oncs.users where usersid = $enteredbyid") if $enteredbyid;
    $enteredby = "Not Available" if $enteredby eq "";
    my ($accnum, $title) = $dbh -> selectrow_array ("select accessionnum, title from oncs.sourcedoc where sourcedocid = $sourceid") if $sourceid;
    my $source; 
    if ($sourceid && $accnum ne "") {
	$source = "<a href=\"javascript:openWindow(\'http://rms.ymp.gov/cgi-bin/get_record.com?$accnum\');\">" . $accnum . "</a> - " . $title;
    }
    elsif ($sourceid && $accnum eq "") {
	$source = $title;
    }
    else {
	$source = "Not Available";
    }
    $pages = "Not Available" if $pages eq "";

    print "<br><br><table width=650 border=1 cellpadding=3 cellspacing=0 borgercolor=#c0c0c0 align=center><th colspan=2 bgcolor=orange align=left>Historical Issue Information</th>\n";
    print "<tr bgcolor=#eeeeee><td valign=top width=250><b>Historical Issue ID</b></td><td valign=top width=400><b>" . formatID2($hissueid, 'HI') . "</b></td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Text</b></td><td valign=top>$text</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Category</b></td><td valign=top>$category</td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Date Occurred</b></td><td valign=top>$dateoccurred</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Date Entered</b></td><td valign=top>$dateentered</td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Entered By</b></td><td valign=top>$enteredby</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Keywords</b></td><td valign=top>\n";
    my $keywords = $dbh -> prepare ("select k.description from oncs.keyword k, oncs.issuekeyword ik where ik.issueid = $hissueid and k.keywordid = ik.keywordid");
    $keywords -> execute;
    my $howmany = 0;
    while (my @values = $keywords -> fetchrow_array) {
	print "<li>$values[0]<br>\n";
	$howmany ++;
    }
    print "None\n" if $howmany == 0;
    $keywords -> finish;
    print "</td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Issue Image</b></td><td valign=top>\n";
    print "View image</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Source Document</b></td><td valign=top>$source</td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Page(s)&nbspContaining&nbspIssue</b></td><td valign=top>$pages&nbsp</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Associated&nbspHistorical&nbspCommitments</b></td><td valign=top>\n";
    my $commitments = $dbh -> prepare ("select commitmentid, text from oncs.commitment where issueid = $hissueid");
    $commitments -> execute;
    $howmany =0;
    while (my @values = $commitments -> fetchrow_array) {
	print "<a href=\"javascript:browseDetails(\'historical\',\'historicalid\',$values[0])\;\">" . formatID2($values[0],'HC') . "</a> - " . getDisplayString($values[1],40) . "<br>\n";
	$howmany ++;
    }
    print "None\n" if $howmany == 0;
    $commitments -> finish;
    print "</td></tr>\n";
    print "</table>\n";
    print "<BR><BR>";
    print "<INPUT TYPE=HIDDEN NAME=type VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
}

############################################
sub drawDetails_Commitments_ResponseLetter {
############################################
    print "<INPUT TYPE=HIDDEN NAME=option VALUE=details>\n";
    print "<INPUT TYPE=HIDDEN NAME=theinterface VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=>\n";
    print "\n <SCRIPT LANGUAGE=JavaScript1.2> if (parent.titlebar) { doSetTextImageLabel('Browse Commitment Responses'); } </SCRIPT>\n";

    my (@myArray, $color, $fontsize, $rowflag, $sth, $sql);
    my ($continueFlag, $main_title, $letterid, $count, $responseid);
    my ($accession_notice, $parent_org_display);

    $continueFlag = 1;

    my $commitmentid = $q->param('id');
    my $type = $q->param('type');

    if ($type eq "firstresponse") {
        $sql = "select min(letterid), min(responseid) from $schema.response where commitmentid = $commitmentid";
        $sth = $dbh->prepare($sql);
        $sth->execute();
        ($letterid, undef) = $sth->fetchrow_array();
        $continueFlag = undef if $letterid eq undef;
        $main_title = "No First Response Letter Found" if $continueFlag == undef;
        $main_title = "First Response Letter" if $continueFlag;
    }
    if ($type eq "finalresponse") {
        $sql = "select statusid from $schema.commitment where statusid = 16 and commitmentid = $commitmentid";
        $sth = $dbh->prepare($sql);
        $sth->execute();
        ($count) = $sth->fetchrow_array();
        $continueFlag = undef if $count == undef;
        $main_title = "No Final Response Letter Found" if $continueFlag == undef;
        if ($continueFlag) {
            $sql = "select max(letterid), max(responseid) from $schema.response where commitmentid = $commitmentid";
            $sth = $dbh->prepare($sql);
            $sth->execute();
            ($letterid, undef) = $sth->fetchrow_array();
            $continueFlag = undef if $letterid < 0;
            $main_title = "Final Response Letter" if $continueFlag;
        }
    }
    if ($continueFlag) {
        $sql = "select a.accessionnum, to_char(a.signeddate,'MM/DD/YYYY'), 
                       b.name, a.organizationid, r.text, 
                       u.firstname || ' ' || u.lastname, a.signer 
                from $schema.letter a, $schema.organization b, 
                     $schema.response r, $schema.users u 
                where r.commitmentid = $commitmentid and 
                      a.letterid = $letterid and 
                      a.organizationid = b.organizationid(+) and 
                      r.letterid = a.letterid and u.usersid = a.signer";
        $sth = $dbh->prepare($sql);
        $sth->execute();
        @myArray = $sth->fetchrow_array();

        if ($myArray[0] ne "") {
	    $accession_notice = "<A HREF=\"javascript:openWindow(\'http://rms.ymp.gov/cgi-bin/get_record.com?$myArray[0]\');\">$myArray[0]</A>";
#            $accession_notice = "<A HREF=\"javascript:openWindow(\'http://ym1701.ymp.gov/scripts/get_record.com?$myArray[0]\');\">$myArray[0]</A>";
        } 
	else {
            $accession_notice = "Not Available";
        }
        if ($myArray[2] ne "&nbsp;") {
            $parent_org_display = "<A HREF=\"javascript:browseDetails(\'organizations\', \'organizationinfo\', $myArray[3]);\">$myArray[2]</A>";
        } 
        else {
            $parent_org_display = "&nbsp;";
        }
    }
    print "<BR><BR>\n";
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=650 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD BGCOLOR=tan COLSPAN=2><FONT COLOR=#000099 SIZE=4><B></B>$main_title</FONT></TD></TR>\n";
    if ($continueFlag) {
        print "<TR><TD BGCOLOR=#eeeeee VALIGN=TOP WIDTH=200><B>Accession #</B></TD><TD BGCOLOR=#eeeeee>$accession_notice</TD></TR>\n";
        print "<TR><TD BGCOLOR=#ffffff VALIGN=TOP WIDTH=200><B>Response Text</B></TD><TD BGCOLOR=#ffffff>$myArray[4]</TD></TR>\n";
        print "<TR><TD BGCOLOR=#eeeeee VALIGN=TOP WIDTH=200><B>Signer</B></TD><TD BGCOLOR=#eeeeee><A HREF=\"javascript:browseDetails(\'issues\', \'enteredby\', $myArray[6]);\">$myArray[5]</a></TD></TR>\n";
        print "<TR><TD BGCOLOR=#ffffff VALIGN=TOP WIDTH=200><B>Date Signed</B></TD><TD BGCOLOR=#ffffff>$myArray[1]</TD></TR>\n";
        print "<TR><TD BGCOLOR=#eeeeee VALIGN=TOP WIDTH=200><B>Organization Sent To</B></TD><TD BGCOLOR=#eeeeee>$parent_org_display</TD></TR>\n";
        print "</TABLE><BR><BR>\n";
    }
}
###########################
sub drawDetails_Responses {
###########################
    &drawDetails_Responses_ResponseLetter() if $interfaceLevel eq "responseletter";
}

##########################################
sub drawDetails_Responses_ResponseLetter {
##########################################
    print "<INPUT TYPE=HIDDEN NAME=option VALUE=details>\n";
    print "<INPUT TYPE=HIDDEN NAME=theinterface VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=details>\n";
    print "\n <SCRIPT LANGUAGE=JavaScript1.2> if (parent.titlebar) { doSetTextImageLabel('Browse Letter Responses'); } </SCRIPT>\n";

    my $letterid = $q->param('id');
    my (@myArray, $color, $fontsize, $rowflag, $sth, $sql);

    $sql = "select text, to_char(writtendate, 'MM/DD/YYYY'), commitmentid, letterid from $schema.response where letterid = $letterid";
    $sth = $dbh->prepare($sql);
    $sth->execute();

    print "<BR><BR>\n";
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    while (@myArray = $sth->fetchrow_array()) {
        my $display_commitment="C"."0" x (5 - length($myArray[2])).$myArray[2];
        print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=650 BORDERCOLOR=#c0c0c0>\n";
        print "<TR><TD BGCOLOR=tan COLSPAN=2><FONT COLOR=#000099 SIZE=4><B>Response Information for Commmitment ID $display_commitment</TD></TR>\n";
        print "<TR><TD BGCOLOR=#eeeeee WIDTH=100 NOWRAP><B>Date Written</B></TD><TD BGCOLOR=#eeeeee WIDTH=550>$myArray[1]</TD></TR>\n";
        print "<TR><TD BGCOLOR=#ffffff VALIGN=TOP><B>Text</B></TD><TD BGCOLOR=#ffffff WIDTH=550>$myArray[0]</TD></TR>\n";
        print "</TABLE><BR><BR>\n";
    }
}

###############################
sub drawDetails_Organizations {
###############################
    &drawDetails_Organizations_OrganizationInfo() if $interfaceLevel eq "organizationinfo";
}

################################################
sub drawDetails_Organizations_OrganizationInfo {
################################################
    print "<INPUT TYPE=HIDDEN NAME=option VALUE=details>\n";
    print "<INPUT TYPE=HIDDEN NAME=theinterface VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=details>\n";
    print "\n <SCRIPT LANGUAGE=JavaScript1.2> if (parent.titlebar) { doSetTextImageLabel('Browse Organization'); } </SCRIPT>\n";

    my $organizationid = $q->param('id');
    my (@myArray, $color, $fontsize, $rowflag, $sth, $sql, $element, $parent_org_display);

    $sql = "select a.organizationid, a.name, a.address1, a.address2, 
                   a.city, a.state, a.zipcode, a.country, a.areacode, 
                   a.phonenumber, a.extension, a.contact, a.department, 
                   a.division, a.faxareacode, a.faxnumber, b.name, 
                   a.parentorg 
            from $schema.organization a, $schema.organization b 
            where a.organizationid = $organizationid 
                  and a.parentorg = b.organizationid(+)";

    $sth = $dbh->prepare($sql);
    $sth->execute();
    @myArray = $sth->fetchrow_array();

    foreach $element (@myArray) {
        $element = "&nbsp;" if $element eq "";
    }
    if ($myArray[17] ne "&nbsp;") {
        $parent_org_display = "<A HREF=\"javascript:browseDetails(\'organizations\', \'organizationinfo\', $myArray[17]);\">$myArray[16]</A>";
    } 
    else {
        $parent_org_display = "&nbsp;";
    }
    ## fix the phone numbers
    $myArray[9] = substr($myArray[9], 0,3)." - ".substr($myArray[9], 3,4) if $myArray[9] ne "&nbsp;";
    $myArray[15] = substr($myArray[15], 0,3)." - ".substr($myArray[15], 3,4) if $myArray[15] ne "&nbsp;";

    print "<BR><BR>\n";
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=650 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD BGCOLOR=tan COLSPAN=2><FONT COLOR=#000099 SIZE=4><B>Organization Information</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee VALIGN=TOP WIDTH=200><B>Name</B></TD><TD BGCOLOR=#eeeeee>$myArray[1]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff VALIGN=TOP WIDTH=200><B>Address</B></TD><TD BGCOLOR=#ffffff>$myArray[2] $myArray[3]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee VALIGN=TOP WIDTH=200><B>City</B></TD><TD BGCOLOR=#eeeeee>$myArray[4]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff VALIGN=TOP WIDTH=200><B>State</B></TD><TD BGCOLOR=#ffffff>$myArray[5]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee VALIGN=TOP WIDTH=200><B>Zip</B></TD><TD BGCOLOR=#eeeeee>$myArray[6]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff VALIGN=TOP WIDTH=200><B>Country</B></TD><TD BGCOLOR=#ffffff>$myArray[7]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee VALIGN=TOP WIDTH=200><B>Phone</B></TD><TD BGCOLOR=#eeeeee>$myArray[8] $myArray[9] $myArray[10]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff VALIGN=TOP WIDTH=200><B>Contact</B></TD><TD BGCOLOR=#ffffff>$myArray[11]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee VALIGN=TOP WIDTH=200><B>Department</B></TD><TD BGCOLOR=#eeeeee>$myArray[12]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff VALIGN=TOP WIDTH=200><B>Division</B></TD><TD BGCOLOR=#ffffff>$myArray[13]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#eeeeee VALIGN=TOP WIDTH=200><B>Fax</B></TD><TD BGCOLOR=#eeeeee>$myArray[14] $myArray[15]</TD></TR>\n";
    print "<TR><TD BGCOLOR=#ffffff VALIGN=TOP WIDTH=200><B>Parent Organization</B></TD><TD BGCOLOR=#ffffff>$parent_org_display</TD></TR>\n";
    print "</TABLE><BR><BR>\n";
}

#######################
sub checkForExistence {
#######################
    my ($interface, $interfaceLevel, $parameter) = @_;
    my ($sql, $element_name, $element_rdo, $sth, $element);

    if ($interface eq 'issues') {
        if ($interfaceLevel eq 'issueid') {
            $sql="select issueid from $schema.issue where issueid=$parameter";
            $element_name = "document.browse.issueid";
            $element_rdo = 1;
            $element = "An Issue ID of";
        }
        if ($interfaceLevel eq 'accessionnum') {
            $sql = "select a.issueid 
                    from $schema.issue a, $schema.sourcedoc b 
                    where b.accessionnum = \'$parameter\' and 
                          b.sourcedocid = a.sourcedocid(+)";
            $element_name = "document.browse.accessionnum";
            $element_rdo = 2;
            $element = "An Accession Number of";
        }
        if ($interfaceLevel eq 'sourcedocid') {
            $sql = "select issueid from $schema.issue where sourcedocid = $parameter";
            $element_name = "document.browse.sourcedocid";
            $element_rdo = 3;
            $element = "A Source Document ID of";
        }
    }
    if ($interface eq 'commitments') {
        if ($interfaceLevel eq 'commitmentid') {
            $sql = "select commitmentid from $schema.commitment where commitmentid = $parameter";
            $element_name = "document.browse.commitmentid";
            $element_rdo = 1;
            $element = "A Commitment ID of";
        }
        if ($interfaceLevel eq 'wbs') {
            $sql = "select controlaccountid from $schema.commitment where controlaccountid = \'$parameter\'";
            $element_name = "document.browse.wbs";
            $element_rdo = 3;
            $element = "A Work Breakdown Structure ID of";
        }
	if ($interfaceLevel eq 'externalid') {
	    $sql = "select externalid from $schema.commitment where externalid = \'$parameter\'";
            $element_name = "document.browse.externalid";
            $element_rdo = 13;
            $element = "An External ID of";
	}
    }
    if ($interface eq 'letters') {
        if ($interfaceLevel eq 'commitmentid') {
            $sql = "select commitmentid from $schema.response where commitmentid = \'$parameter\'";
            $element_name = "document.browse.commitmentid";
            $element_rdo = 1;
            $element = "A Commitment ID of";
        }
    }
    if ($interface eq 'actions') {
        if ($interfaceLevel eq 'commitmentid') {
            $sql = "select commitmentid from $schema.commitment where commitmentid = $parameter";
            $element_name = "document.browse.commitmentid";
            $element_rdo = 1;
            $element = "A Commitment ID of";
        }
    } 
    $sth = $dbh->prepare($sql);
    $sth->execute();
    my $rowtest = $sth->fetchrow_array();
    if (!$rowtest) { #($rowtest == undef()) {
        &drawQuery_Issues() if $interface eq "issues";
        &drawQuery_Commitments() if $interface eq "commitments";
        &drawQuery_Letters() if $interface eq "letters";
	&drawQuery_Actions() if $interface eq "actions";
        print "<SCRIPT>\n $element_name.value = \'$parameter\';\n";
        print "document.browse.chkOption[$element_rdo].checked = true\n";
        print "$element_name.focus();\n";
        print "$element_name.select();\n";
        print "alert('$element $parameter does not exist in the system');\n";
        print "</SCRIPT>";
        &drawFoot();
        exit(0);
    }
}

##################
sub issueResults {
##################
    my %args = (
		table => '',
		where => '',
		@_,
		);
    print "<tr>\n";
    print "<th>ID</th>\n";
    print "<th>Site</th>\n";
    print "<th>Accession</th>\n";
    print "<th>Entered By</th>\n";
    print "<th>Issue Text</th>\n";
    print "<th><font size=-1>Date<BR>Occurred</th>\n";
    print "<th><font size=-1>Associated<BR>Commitments</th>\n";

    my $table = ($args{table} ne '') ? "$args{table}, " : "";
    my $where = ($args{where} ne '') ? "$args{where} and " : "";
    my $pick = "select i.issueid, s.name, so.accessionnum, i.enteredby, u.firstname || ' ' || u.lastname, i.text, to_char(i.dateoccurred, 'MM/DD/YYYY') from $table $SCHEMA.issue i, $SCHEMA.site s, $SCHEMA.sourcedoc so, $SCHEMA.users u where $where i.siteid=s.siteid(+) and i.enteredby=u.usersid and i.sourcedocid = so.sourcedocid(+) order by i.issueid";
    my $results = $dbh -> prepare ($pick);
    $results -> execute;
    my $bg = "#eeeeee";
    my $count = 0;
    while (my @values = $results -> fetchrow_array) {
	my ($iid, $site, $accnum, $uid, $user, $text, $dateoc) = @values;
	my ($assocom) = $dbh -> selectrow_array ("select count(*) from $SCHEMA.commitment where issueid = $iid");
	$accnum = ($accnum eq "") ? "&nbsp;" : "<A HREF=\"javascript:openWindow(\'http://rms.ymp.gov/cgi-bin/get_record.com?$accnum\');\">$accnum</A>";

	print "<tr bgcolor=$bg><td nowrap><font size=-1><A HREF=\"javascript:browseDetails(\'issues\',\'issueid\',$iid);\">" . formatID2($iid, 'I')."</a></font></td>\n";
	print "<td nowrap><font size=-1>$site</font></td>\n";
	print "<td nowrap><font size=-1>$accnum</font></td>\n";
	print "<td nowrap><font size=-1><A HREF=\"javascript:browseDetails(\'issues\',\'enteredby\',\'$uid\');\">$user</a></font></td>\n";
	print "<td nowrap><font size=-1>" . getDisplayString ($text, 45) . "</font></td>\n";
	print "<td nowrap><font size=-1>$dateoc</font></td>\n";
	print "<td align=center><font size=-1>$assocom</font></td></tr>\n";
	$count++;
	$bg = ($count%2) ? "#ffffff" : "eeeeee";
    }
    $results -> finish;
}

#######################
sub commitmentResults {
#######################
    my %args = (
        where => '',
        table => '',
	@_,
    );
    print "<tr>\n";
    print "<th valign=bottom>ID</th>\n";
    print "<th valign=bottom>Site</th>\n";
    print "<th valign=bottom>Text</th>\n";
    print "<th valign=bottom>Due Date</th>\n";
    print "<th valign=bottom>Status</th>\n";
    print "<th valign=bottom>Issue</th></tr>\n";

    my $where = ($args{where} ne '') ? "$args{where} and " : "";
    my $table = ($args{table} ne '') ? "$args{table}, " : "";
    my $pick = "select c.commitmentid, to_char(c.duedate, 'MM/DD/YYYY'), st.description, c.issueid, s.name, c.text from $table $schema.commitment c, $schema.status st, $schema.site s where $where c.statusid = st.statusid(+) and c.siteid = s.siteid(+) order by commitmentid";
    my $results = $dbh -> prepare ($pick);
    $results -> execute;
    my $bg = "#eeeeee";
    my $count = 0;
    while (my @values = $results -> fetchrow_array) {
	my ($cid, $due, $status, $iid, $site, $text) = @values;
	print "<tr bgcolor=$bg><td nowrap><font size=-1><A HREF=\"javascript:browseDetails(\'commitments\',\'commitmentid\',$cid);\">".formatID2($cid, 'C')."</a></font></td>\n";
	print "<td nowrap><font size=-1>$site</font></td>\n";
	print "<td nowrap><font size=-1>".getDisplayString($text,50)."</font></td>\n";
	print "<td nowrap><font size=-1>$due</font></td>\n";
	print "<td nowrap><font size=-1>$status</font></td>\n";
	print "<td nowrap><font size=-1><A HREF=\"javascript:browseDetails(\'issues\',\'issueid\',$iid);\">".formatID2($iid,'I')."</a></font></td></tr>\n";
	$count++;
	$bg = ($count%2) ? "#ffffff" : "eeeeee";
    }
    $results -> finish;
}

###################
sub actionResults {
###################
    my %args = (
		table => '',
		where => '',
		@_,
		);
    print "<tr>\n";
    print "<th><font size=-1>ID</th>\n";
    print "<th><font size=-1>Site</th>\n";
    print "<th nowrap><font size=-1>Due Date</th>\n";
    print "<th><font size=-1>Text</th>\n";
    print "<th><font size=-1>Discipline Lead</th>\n";
    print "<th><font size=-1>Licensing Lead</th>\n";
    print "<th><font size=-1>Responsible Manager</th>\n";

    my $table = ($args{table} ne '') ? "$args{table}, " : "";
    my $where = ($args{where} ne '') ? "$args{where} and " : "";
    my $pick = "select a.actionid, a.commitmentid, u.firstname || ' ' || u.lastname, u2.firstname ||  ' ' || u2.lastname, a.text, to_char(a.duedate, 'MM/DD/YYYY'), s.name, m.firstname || ' ' || m.lastname from $table $SCHEMA.action a, $SCHEMA.site s, $SCHEMA.responsiblemanager m, $SCHEMA.users u, $SCHEMA.users u2 where $where a.siteid=s.siteid(+) and a.dleadid=u.usersid and a.lleadid = u2.usersid and a.managerid=m.responsiblemanagerid order by a.commitmentid, a.actionid";
    my $results = $dbh -> prepare ($pick);
    $results -> execute;
    my $bg = "#eeeeee";
    my $count = 0;
    while (my @values = $results -> fetchrow_array) {
	my ($aid, $cid, $dl, $ll, $text, $duedate, $site, $rm) = @values;
	my $fullactionid = substr("0000$cid",-5) . substr("00$aid",-3);
	print "<tr bgcolor=$bg><td nowrap><font size=-1><A HREF=\"javascript:browseAction($aid,$cid);\">" . formatID2($cid, 'C') . "/" . substr("00$aid",-3) . "</a></font></td>\n";
	print "<td nowrap><font size=-1>$site</font></td>\n";
	print "<td nowrap><font size=-1>$duedate</font></td>\n";
	print "<td nowrap><font size=-1>" . getDisplayString ($text, 35) . "</font></td>\n";
	print "<td nowrap><font size=-1>$dl</font></td>\n";
	print "<td nowrap><font size=-1>$ll</font></td>\n";
	print "<td nowrap><font size=-1>$rm</font></td>\n";
	$count++;
	$bg = ($count%2) ? "#ffffff" : "eeeeee";
    }
    $results -> finish;
}

###################
sub letterResults {
###################
    my %args = (
	where => '',
        table => '',
	@_,
    );
    print "<tr><th nowrap>Response(s)</th>\n";
    print "<th nowrap>Accession</th>\n";
    print "<th nowrap>Sent Date</th>\n";
    print "<th nowrap>Signed Date</th>\n";
    print "<th nowrap>Addressee</th>\n";
    print "<th nowrap>Organization</th>\n";
    print "<th nowrap>Signer</th></tr>\n";
    my $where = ($args{where}) ? "$args{where} and " : "";
    my $sql = "select l.accessionnum, to_char(l.sentdate, 'MM/DD/YYYY'), 
                      to_char(l.signeddate, 'MM/DD/YYYY'), l.addressee, 
                      o.name, l.signer, u.firstname || ' ' || u.lastname, 
                      l.organizationid, l.letterid 
               from $schema.letter l, $schema.organization o, $schema.users u 
               where $where l.organizationid = o.organizationid(+) 
                     and l.signer = u.usersid(+)";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $bgcolor = "#eeeeee";
    while (my @values = $sth -> fetchrow_array) {
	my ($accnum, $sent, $signed, $addressee, $orgname, $uid, $uname, $oid, $lid) = @values;
	print "<tr bgcolor=$bgcolor><td align=center><font size=-1><a href=\"javascript:browseDetails(\'responses\',\'responseletter\', $lid);\">View</a></font></td>\n";
        print "<td><font size=-1><A HREF=\"javascript:openWindow(\'http://rms.ymp.gov/cgi-bin/get_record.com?$accnum\');\">$accnum</A>&nbsp;</font></td>\n";
	print "<td><font size=-1>$sent</font></td>\n";
	print "<td><font size=-1>$signed</font></td>\n";
	print "<td><font size=-1>$addressee</font></td>\n";
	print "<td><font size=-1><A HREF=\"javascript:browseDetails(\'organizations\', \'organizationinfo\', $oid);\">$orgname</a></font></td>\n";
	print "<td><font size=-1><a href=\"javascript:browseDetails(\'issues\', \'enteredby\',\'$uid\');\">$uname</a></font></td></tr>\n";
	$bgcolor = ($bgcolor eq "#eeeeee") ? "#ffffff" : "#eeeeee";
    }
}

################
sub allActions {
################
    my $cid = $q -> param ('commitmentid');
    print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n<center>\n";
    print "<table width=650 align=center border=1 cellspacing=0 cellpadding=0>\n";
    print "<tr><td bgcolor=#fabaaa><b>Actions associated with commitment ". formatID2($cid, "C") . "</b></td></tr>\n";
    my $csr = $dbh -> prepare ("select actionid from $SCHEMA.action where commitmentid=$cid order by actionid");
    $csr -> execute;
    while (my ($actid) = $csr -> fetchrow_array) {
	print doActionsTable (cid => $cid, aid => $actid, dbh => $dbh, schema => $SCHEMA, view => 1);
    }
    print "</table><br><br>\n";
    exit 1;
} ####  endif viewactions  ####

$dbh->disconnect();



