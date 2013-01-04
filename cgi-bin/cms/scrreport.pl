#!/usr/local/bin/newperl
#
# SRC report screen
#
# $Source: /data/dev/rcs/cms/perl/RCS/scrreport.pl,v $
# $Revision: 1.5 $
# $Date: 2003/11/21 17:22:49 $
# $Author: naydenoa $
# $Locker:  $
# $Log: scrreport.pl,v $
# Revision 1.5  2003/11/21 17:22:49  naydenoa
# Updated secondary schema from SCM to PCL.
#
# Revision 1.4  2002/11/08 21:00:24  naydenoa
# Removed references to scruser, scrproduct - replaced with users, product
#
# Revision 1.3  2001/09/17 20:47:16  naydenoa
# Fixed request count
#
# Revision 1.2  2001/09/04 23:02:37  naydenoa
# checkpoint
#
# Revision 1.1  2001/08/30 21:54:00  naydenoa
# Initial revision
#
#

use strict;
use integer;
use ONCS_Header qw(:Constants);
use CGI;
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_Widgets qw(:Functions);
use DBI;

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $dbh = oncs_connect();
$dbh->{LongReadLen}=1000000;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

@| = 1;

my $scrcgi = new CGI;

my $schema = $scrcgi -> param("schema");
my $schema1 = "PCL";
my $username = $scrcgi -> param("username");
my $userid = $scrcgi -> param("usersid");
my $option = $scrcgi -> param("option"); $option = "main" if !defined($option);

&drawHead();
&drawResults();
&drawFoot();

my $stat = oncs_disconnect($dbh);

##############
sub drawHead {
##############
print "content-type:  text/html\n\n";

print "<HTML>\n<HEAD>\n<TITLE>SCR - Report</TITLE>\n";
print "<SCRIPT LANGUAGE=JavaScript1.2>\n";
print "function browseDetails(id) {\n";
print "\t document.$form.option.value = \'details\'\;\n";
print "\t document.$form.id.value = id\;\n";
print "\t document.$form.submit()\;\n";
print "}\n\n";
print "function openWindow(image) {\n";
print "\t window.open(image,\"image_window\",\"height=500,width=700,scrollbars=yes,resizable=yes\");\n";
print "}\n\n";
print "</SCRIPT>\n";
print<<eof_head_too;
</HEAD>
<BODY BACKGROUND=/cms/images/background.gif TEXT=#000099 LINK=#0000FF VLINK=#0000FF ALINK=#0000FF TOPMARGIN=0 LEFTMARGIN=0><center><br>
<FORM NAME=$form METHOD=POST onSubmit='return validateForm();'>
<INPUT TYPE=HIDDEN NAME=userid VALUE=$userid>
<INPUT TYPE=HIDDEN NAME=username VALUE=$username>
<INPUT TYPE=HIDDEN NAME=schema VALUE=$schema>
<input type=hidden name=option value=$option>
eof_head_too
}

##############
sub drawFoot {
##############
    print "</form>\n<br><br>\n</body></html>\n";
}

#################
sub drawResults {
#################
    my ($total)=$dbh -> selectrow_array ("select count(*) from $schema1.scrrequest where product=2");
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER><br>\n";
    print "<table width=650 align=center>\n"; 
    my ($reportdate) = $dbh -> selectrow_array ("select to_char(sysdate, 'DD Month YYYY; HH:MI:SS AM') from dual");
    print "<TR><TD colspan=2 align=center><FONT SIZE=4 face=arial>Report on CMS Software Change Requests ($total total)<br>$reportdate</TD></TR><tr><td colspan=2>&nbsp;</td></tr>\n";

    my $pick = "select r.id, s.id, s.description, r.submittedby, u.firstname || ' ' || u.lastname, r.description, to_char(r.datesubmitted, 'MM/DD/YYYY'), p.description, r.rationale, pr.name from $schema1.scrrequest r, $schema1.users u, $schema1.scrstatus s, $schema1.scrpriority p, $schema1.product pr where pr.id=2 and r.status=s.id and r.submittedby=u.id and r.priority=p.id and pr.id=r.product order by r.id";
    my $results = $dbh -> prepare ($pick);
    $results -> execute;
    my $bg = "#eeeeee";
    my $count = 0;
    while (my @values = $results -> fetchrow_array) {
	my ($rid, $sid, $status, $uid, $user, $desc, $date, $priority, $rationale, $product) = @values;
	print "<tr><td valign=top width=125><font size=-1 face=arial><b>ID:</b></td><td><font size=-1 face=arial>" . formatID2($rid, 'SCREQ') . "</td></tr>\n";
	$desc =~ s/\n/<BR>/g;
	print "<tr><td valign=top><font size=-1 face=arial><b>Description:</td><td><font size=-1 face=arial>$desc</td></tr>\n";
	$rationale =~ s/\n/<BR>/g;
	print "<tr><td valign=top><font size=-1 face=arial><b>Rationale:</td><td><font size=-1 face=arial>$rationale</td></tr>\n";
	my $clop = ($sid <= 4 || $sid >= 9) ? "Open" : "Closed";
	print "<tr><td valign=top><font size=-1 face=arial><b>Status:</td><td><font size=-1 face=arial>$clop</td></tr>\n";
	print "<tr><td valign=top><font size=-1 face=arial><b>Status Description:</td><td><font size=-1 face=arial>$status</td></tr>\n";
	print "<tr><td valign=top><font size=-1 face=arial><b>Priority:</td><td><font size=-1 face=arial>$priority</td></tr>\n";
	print "<tr><td valign=top><font size=-1 face=arial><b>Product:</td><td><font size=-1 face=arial>$product</td></tr>\n";
	print "<tr><td valign=top><font size=-1 face=arial><b>Entered By:</td><td><font size=-1 face=arial>$user</td></tr>\n";
	print "<tr><td valign=top><font size=-1 face=arial><b>Date Entered:</td><td><font size=-1 face=arial>$date</td></tr>\n";
	print "<tr><td colspan=2><hr width=50%></td></tr>";
    }
    $results -> finish;

    print "</table>\n";
}
