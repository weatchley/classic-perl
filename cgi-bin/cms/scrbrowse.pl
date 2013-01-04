#!/usr/local/bin/newperl
#
# $Source: /data/dev/rcs/cms/perl/RCS/scrbrowse.pl,v $
# $Revision: 1.5 $
# $Date: 2003/11/21 17:21:16 $
# $Author: naydenoa $
# $Locker:  $
# $Log: scrbrowse.pl,v $
# Revision 1.5  2003/11/21 17:21:16  naydenoa
# Updated secondary schema from SCM to PCL.
#
# Revision 1.4  2002/11/08 20:58:32  naydenoa
# Removed references to scruser, scrproduct - replaced with users, product
#
# Revision 1.3  2001/09/13 19:50:32  naydenoa
# Fixed bug in browse details.
#
# Revision 1.2  2001/09/04 23:02:27  naydenoa
# checkpoint
#
# Revision 1.1  2001/08/30 21:53:53  naydenoa
# Initial revision
#
#

use strict;
use integer;
use ONCS_Header qw(:Constants);
use CGI;
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_Widgets qw(:Functions);
#use DocumentSpecific qw(:Functions);
use DBI;

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $dbh = oncs_connect();
$dbh -> {LongReadLen}=1000000;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

@| = 1;

my $scrcgi = new CGI;

my $schema = $scrcgi -> param("schema");
my $schema1 = "PCL";
my $username = $scrcgi -> param("username");
my $userid = $scrcgi -> param("userid");
my $option = $scrcgi -> param("option"); $option = "main" if !defined($option);

&drawHead();
#print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => 'Browse Software Change Requests');
&drawResults() if $option eq "main";
&drawDetails() if $option eq "details";
&drawFoot();

my $stat = oncs_disconnect($dbh);

##############
sub drawHead {
##############
print "content-type:  text/html\n\n";

print "<html>\n<head>\n<title>SCR - Browse</title>\n";
print "<script language=JavaScript1.2><!--\n";
print "function browseDetails(id) {\n";
print "    var script = \'scrbrowse\';";
print "    document.$form.option.value = \'details\'\;\n";
print "    document.$form.id.value = id\;\n";
print "    document.$form.action = \'$path\' + script + \'.pl\';\n";
print "    document.$form.target = \'workspace\';\n";
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

print "// routine to set the image for the graphic text label\n";
print "function doSetTextImageLabel(label) {\n";
print "    parent.titlebar.SetImageLabel(label);\n";
print "}\n";
print "doSetTextImageLabel('Browse Software Change Requests');\n";
print "//-->\n</script>\n";
print<<eof_head_too;
</head>
<body background=/cms/images/background.gif text=#000099 link=#0000FF vlink=#0000FF alink=#0000FF topmargin=0 leftmargin=0><center><br>
<form name=$form method=post onSubmit='return validateForm();'>
<input type=hidden name=userid value=$userid>
<input type=hidden name=username value=$username>
<input type=hidden name=schema value=$schema>
<input type=hidden name=option value=$option>
eof_head_too
}

##############
sub drawFoot {
##############
    print "</form><br><br></body></html>\n";
    print "<!-- End of drawFoot -->";
}

#################
sub drawResults {
#################
    my ($total)=$dbh -> selectrow_array ("select count(*) from $schema1.scrrequest r where product=2");
    print "<input type=hidden name=id value=>\n";
    print "<center><br>\n";
    print "<table border=1 cellspacing=0 cellpadding=3 width=750 bgcolor=#ffffff>\n";
    print "<tr><td colspan=7 bgcolor=#cdecff><font color=#000099 size=4><b>All CMS Software Change Requests ($total total)</td></tr>\n";#cdecff
    print "<tr bgcolor=#d8d8d8>\n";
    print "<th><font size=-1>ID</th>\n";
    print "<th><font size=-1>Request Description</th>\n";
    print "<th><font size=-1>Status</th>\n";
    print "<th><font size=-1>Status&nbsp;Description</th>\n";
    print "<th><font size=-1>Entered By</th>\n";
    print "<th><font size=-1>Date&nbsp;Entered</th>\n";
    print "<th><font size=-1>Priority</th>\n";
    print "<tr><td colspan=6></td><tr>\n";

    my $pick = "select r.id, s.description, s.id, r.submittedby, u.firstname || ' ' || u.lastname, r.description, to_char(r.datesubmitted, 'MM/DD/YYYY'), p.description from $schema1.scrrequest r, $schema1.users u, $schema1.scrstatus s, $schema1.scrpriority p where r.product=2 and r.status=s.id and r.submittedby=u.id and r.priority=p.id order by r.id";
    my $results = $dbh -> prepare ($pick);
    $results -> execute;
    my $bg = "#eeeeee";
    my $count = 0;
    while (my @values = $results -> fetchrow_array) {
	my ($rid, $status, $sid, $uid, $user, $desc, $date, $priority, $product) = @values;
	print "<tr bgcolor=$bg><td nowrap><font size=-1><a href=\"javascript:browseDetails($rid);\">" . formatID2($rid, 'SCREQ') . "</a></font></td>\n";
	print "<td nowrap><font size=-1>" . getDisplayString ($desc, 30) . "</font></td>\n";
	print "<td nowrap><font size=-1>";
	print "Open" if ($sid <= 4 || $sid >= 9);
	print "Closed" if ($sid >= 5 && $sid <= 8);
	print "</font></td>\n";
	print "<td nowrap><font size=-1>$status</font></td>\n";
	print "<td nowrap><font size=-1>$user</font></td>\n";
	print "<td nowrap><font size=-1>$date</font></td>\n";
	print "<td nowrap><font size=-1>$priority</font></td>\n";
	$count++;
	$bg = ($count%2) ? "#ffffff" : "eeeeee";
    }
    $results -> finish;

    print "</table>\n";

    print "<br><center><input type=button name=genrep value=\"Generate Report\" onClick=doReport();><br><br>\n";
}

#################
sub drawDetails {
#################
    print "<input type=hidden name=option value=>\n";
    print "<input type=hidden name=id value=>\n";
    my $rid = $scrcgi -> param('id');
    my ($prodlist, $color, $fontsize, $rowflag, $sth, $sql, $element);

    $sql = "select to_char(r.datesubmitted, 'MM/DD/YYYY'), u.firstname || ' ' ||u.lastname, p.description, s.description, r.description, r.rationale, pr.name from $schema1.scrrequest r, $schema1.users u, $schema1.scrpriority p, $schema1.scrstatus s, $schema1.product pr where r.id = $rid and r.product=2 and u.id=r.submittedby and p.id=r.priority and s.id=r.status and pr.id=r.product";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    my ($date, $uid, $pid, $sid, $desc, $rat, $product) = $sth->fetchrow_array();
    $desc =~ s/\n/<br>/g;  # request description
    $rat =~ s/\n/<br>/g; # request rationale
    print "<br><br>";
    print "<center>\n";
    print "<table border=1 cellspacing=0 cellpadding=3 width=650>\n";
    print "<tr><td bgcolor=#cdecff colspan=2><font color=#000099 size=4><b>Software Change Request Information</b></font></td></tr>\n";
    print "<tr bgcolor=#eeeeee><td width=120 valign=top><b>ID</b></td><td valign=top><b>" . formatID2 ($rid, 'SCREQ') . "</b></td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Description</b></td><td valign=top>$desc</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Rationale</b></td><td valign=top>$rat</A></td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Priority</b></td><td width=400 valign=top>$pid</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Status</b></td><td valign=top>$sid</td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Affected Product</b></td><td valign=top>$product</td></tr>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><b>Date Entered</b></td><td valign=top>$date</td></tr>\n";
    print "<tr bgcolor=#ffffff><td valign=top><b>Entered By</b></td><td valign=top>$uid</td></tr>\n";
    print "</table>\n";
}

