#!/usr/local/bin/newperl
#
# $Source: /data/dev/rcs/dms/perl/RCS/scrbrowse.pl,v $
# $Revision: 1.4 $
# $Date: 2002/10/22 22:43:14 $
# $Author: munroeb $
# $Locker:  $
# $Log: scrbrowse.pl,v $
# Revision 1.4  2002/10/22 22:43:14  munroeb
# modified tablename SCRPRODUCT to PRODUCT
#
# Revision 1.3  2002/09/12 21:49:42  munroeb
# changed tablename from scruser to users
#
# Revision 1.2  2002/06/30 20:33:56  mccartym
# change product id
#
# Revision 1.1  2002/03/08 21:10:44  atchleyb
# Initial revision
#
#
#

use strict;
use integer;
use DMS_Header qw(:Constants);
use CGI;
use DB_Utilities_Lib qw(:Functions);
use UI_Widgets qw(:Functions);
use DBI;

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $dbh = db_connect();
$dbh->{LongReadLen}=1000000;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

@| = 1;

my $q = new CGI;

my $schema = $q->param("schema");
my $schema1 = "SCM";
my $username = $q->param("username");
my $userid = $q->param("userid");
my $option = $q->param("option"); $option = "main" if !defined($option);

&drawHead();
print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => 'Browse Software Change Requests');
&drawResults() if $option eq "main";
&drawDetails() if $option eq "details";
&drawFoot();

my $stat = db_disconnect($dbh);

##############
sub drawHead {
##############
print "content-type:  text/html\n\n";

print "<HTML>\n<HEAD>\n<TITLE>SCR - Browse</TITLE>\n";
print "<SCRIPT LANGUAGE=JavaScript1.2><!--\n";
print "function browseDetails(id) {\n";
print "    var script = \'scrbrowse\';";
print "    document.$form.option.value = \'details\'\;\n";
print "    document.$form.id.value = id\;\n";
print "    document.$form.action = \'$path\' + script + \'.pl\';\n";
print "    document.$form.target = \'main\';\n";
print "    document.$form.submit()\;\n";
print "}\n\n";
print "function openWindow(image) {\n";
print "\t window.open(image,\"image_window\",\"height=500,width=700,scrollbars=yes,resizable=yes\");\n";
print "}\n\n";
print "function doReport() {\n";
print "    var script = \'scrreport\';\n";
print "    window.open (\"\", \"reportwin\", \"height=500, width=700, status=yes, scrollbars=yes menubar=yes toolbar=yes\");\n";
print "    document.$form.target = \'reportwin\';\n";
print "    document.$form.action = \'$path\' + script + \'.pl\';\n";
print "    document.$form.submit();\n";
print "}\n";
print "//-->\n</script>\n";
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
    print "</FORM><BR><BR></BODY></HTML>\n";
}

#################
sub drawResults {
#################
    my ($total)=$dbh -> selectrow_array ("select count(*) from $schema1.scrrequest where product=9");
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER><br>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=750 bgcolor=#ffffff>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>All DMS Software Change Requests ($total total)</TD></TR>\n";#cdecff
    print "<tr bgcolor=#d8d8d8>\n";
    print "<th><font size=-1>ID</th>\n";
    print "<th><font size=-1>Request Description</th>\n";
    print "<th><font size=-1>Status</th>\n";
    print "<th><font size=-1>Status&nbsp;Description</th>\n";
    print "<th><font size=-1>Entered By</th>\n";
    print "<th><font size=-1>Date&nbsp;Entered</th>\n";
    print "<th><font size=-1>Priority</th>\n";
    print "<tr><td colspan=6></td><tr>\n";

    my $pick = "select r.id, s.description, s.id, r.submittedby, u.firstname || ' ' || u.lastname, r.description, to_char(r.datesubmitted, 'MM/DD/YYYY'), p.description, pr.name from $schema1.scrrequest r, $schema1.users u, $schema1.scrstatus s, $schema1.scrpriority p, $schema1.product pr where pr.id=9 and r.status=s.id and r.submittedby=u.id and r.priority=p.id and r.product=pr.id order by r.id";
    my $results = $dbh -> prepare ($pick);
    $results -> execute;
    my $bg = "#eeeeee";
    my $count = 0;
    while (my @values = $results -> fetchrow_array) {
	my ($rid, $status, $sid, $uid, $user, $desc, $date, $priority, $product) = @values;
	print "<tr bgcolor=$bg><td nowrap><font size=-1><A HREF=\"javascript:browseDetails($rid);\">" . formatID('SCREQ', 5, $rid) . "</a></font></td>\n";
	print "<td nowrap><font size=-1>" . getDisplayString ($desc, 30) . "</font></td>\n";
	print "<td nowrap><font size=-1>";
	print "Open" if ($sid==1 || $sid==2 || $sid==3 || $sid==4);
	print "Closed" if ($sid==5 || $sid==6 || $sid==7 || $sid==8);
	print "</font></td>\n";
	print "<td nowrap><font size=-1>$status</font></td>\n";
	print "<td nowrap><font size=-1>$user</font></td>\n";
	print "<td nowrap><font size=-1>$date</font></td>\n";
	print "<td nowrap><font size=-1>$priority</font></td>\n";
	$count++;
	$bg = ($count%2) ? "#ffffff" : "eeeeee";
    }
    $results -> finish;

    print "</TABLE>\n";

    print "<br><center><input type=button name=genrep value=\"Generate Report\" onClick=doReport();>&nbsp;&nbsp;";
}

#################
sub drawDetails {
#################
    print "<INPUT TYPE=HIDDEN NAME=option VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    my $rid = $q->param('id');
    my ($sth, $sql, $element);

    $sql = "select to_char(r.datesubmitted, 'MM/DD/YYYY'), u.firstname || ' ' ||u.lastname, p.description, s.id, s.description, r.description, r.rationale, pr.name from $schema1.scrrequest r, $schema1.users u, $schema1.scrpriority p, $schema1.scrstatus s, $schema1.product pr where r.id = $rid and u.id=r.submittedby and p.id=r.priority and s.id=r.status and r.product=pr.id and r.product=9";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    my ($date, $uid, $pid, $sid, $status, $desc, $rat, $product) = $sth->fetchrow_array();
    $desc =~ s/\n/<BR>/g;  # request description
    $rat =~ s/\n/<BR>/g; # request rationale
    print "<BR><BR>";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=650>\n";
    print "<tr><td BGCOLOR=#cdecff COLSPAN=2><FONT COLOR=#000099 SIZE=4><B>Software Change Request Information</B></FONT></TD></TR>\n";
    print "<TR bgcolor=#eeeeee><td WIDTH=120 valign=top><B>ID</B></TD><TD valign=top><b>" . formatID ('SCREQ', 5, $rid) . "</b></TD></TR>\n";
    print "<tr bgcolor=#ffffff><td valign=top><B>Description</B></TD><TD valign=top>$desc</TD></TR>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><B>Rationale</B></TD><TD valign=top>$rat</A></TD></TR>\n";
    print "<tr bgcolor=#ffffff><td VALIGN=TOP><B>Priority</B></TD><TD WIDTH=400 VALIGN=TOP>$pid</TD></TR>\n";
    my $clop = ($sid < 5) ? "Open" : "Closed";
    print "<tr bgcolor=#eeeeee><td valign=top><B>Status</B></TD><TD valign=top>$clop</TD></TR>\n";
    print "<tr bgcolor=#ffffff><td valign=top><B>Status Description</B></TD><TD valign=top>$status</TD></TR>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><B>Affected Product</B></TD><TD valign=top>$product</TD></TR>\n";
    print "<tr bgcolor=#ffffff><td valign=top><B>Date Entered</B></TD><TD valign=top>$date</TD></TR>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><B>Entered By</B></TD><TD valign=top>$uid</TD></TR>\n";
    print "</TABLE>\n";
}

