#!/usr/local/bin/newperl
#
# $Source: /data/dev/rcs/qa/perl/RCS/scrbrowse.pl,v $
# $Revision: 1.8 $
# $Date: 2002/11/21 15:27:36 $
# $Author: starkeyj $
# $Locker:  $
# $Log: scrbrowse.pl,v $
# Revision 1.8  2002/11/21 15:27:36  starkeyj
# modified sql select statements and titles so  the Trend and ASSM apps display only their own SCR's with
#  the appropriate title
#
# Revision 1.7  2002/11/05 19:23:50  starkeyj
# modified select statements to incorporate changes to table names and columns
#
# Revision 1.6  2002/07/15 22:43:28  starkeyj
# modified to select SCR's from products 7 and 8 (legacy checklist and DR/CAR)
#
# Revision 1.5  2002/07/02 00:32:37  starkeyj
# modified for new implementation of product identification, i.e. not by subproduct
#
# Revision 1.4  2002/03/28 21:48:19  starkeyj
# modified to distinguish between ASSM and Trend subproducts
#
# Revision 1.3  2001/11/05 19:01:43  starkeyj
# typo
#
# Revision 1.2  2001/11/05 18:58:37  starkeyj
# changed title to reflect NQS requests
#
# Revision 1.1  2001/11/02 22:02:28  starkeyj
# Initial revision
#
#

use strict;
use integer;
use NQS_Header qw(:Constants);
use CGI;
use OQA_Utilities_Lib qw(:Functions);
use OQA_Widgets qw(:Functions);
#use DocumentSpecific qw(:Functions);
use DBI;

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $dbh = &NQS_connect();
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
my $app = $q->param("app");
my $background;
my $productid = $app eq 'Trend' ? 4 : 3;
my $apptitle = $app eq 'Trend' ? "Trend Analysis" : "Audit and Surveillance Schedule Management";
if ($app eq 'ASSM') {$background = "background=$NQSImagePath/background.gif";}
elsif ($app eq 'Trend') {$background = "bgcolor=#FFFFEO";}

&drawHead();
#print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => 'Browse Software Change Requests');
&drawResults() if $option eq "main";
&drawDetails() if $option eq "details";
&drawFoot();

my $stat = NQS_disconnect($dbh);

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
    print "    parent.title.SetImageLabel(label);\n";
    print "}\n";
    if ($app eq 'ASSM') {
	 	print "doSetTextImageLabel(\'Enter Software Change Request\');\n";
	 }
    print "//-->\n</script>\n";
    print<<eof_head_too;
</HEAD>

<!-- ################################
Change image path to the correct one
################################ -->

<BODY $background TEXT=#000099 LINK=#0000FF VLINK=#0000FF ALINK=#0000FF TOPMARGIN=0 LEFTMARGIN=0><center><br>
<FORM NAME=$form METHOD=POST onSubmit='return validateForm();'>
<INPUT TYPE=HIDDEN NAME=userid VALUE=$userid>
<INPUT TYPE=HIDDEN NAME=username VALUE=$username>
<INPUT TYPE=HIDDEN NAME=schema VALUE=$schema>
<input type=hidden name=option value=$option>
<input type=hidden name=app value=$app>
<input type=hidden name=productid value=$productid>
eof_head_too
if ($app eq 'Trend') {print "<hr width=80%><br>\n";}
}

##############
sub drawFoot {
##############
    print "</FORM><BR><BR></BODY></HTML>\n";
}

#################
sub drawResults {
#################
    my ($total)=$dbh -> selectrow_array ("select count(*) from $schema1.scrrequest r where product = $productid ");
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER><br>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=750 bgcolor=#ffffff>\n"; #BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>All $apptitle Software Change Requests ($total total)</TD></TR>\n";#cdecff
    print "<tr bgcolor=#d8d8d8>\n";
    print "<th><font size=-1>ID</th>\n";
    print "<th><font size=-1>Request Description</th>\n";
    print "<th><font size=-1>Status</th>\n";
    print "<th><font size=-1>Status&nbsp;Description</th>\n";
    print "<th><font size=-1>Entered By</th>\n";
    print "<th><font size=-1>Date&nbsp;Entered</th>\n";
    print "<th><font size=-1>Priority</th>\n";
    print "<tr><td colspan=6></td><tr>\n";

    my $pick = "select r.id, s.description, s.id, r.submittedby, u.firstname || ' ' || u.lastname, r.description, to_char(r.datesubmitted, 'MM/DD/YYYY'), p.description from $schema1.scrrequest r, $schema1.users u, $schema1.scrstatus s, $schema1.scrpriority p where r.product = $productid and r.status=s.id and r.submittedby=u.id and r.priority=p.id order by r.product, r.id";
    my $results = $dbh -> prepare ($pick);
    $results -> execute;
    my $bg = "#eeeeee";
    my $count = 0;
    while (my @values = $results -> fetchrow_array) {
	my ($rid, $status, $sid, $uid, $user, $desc, $date, $priority, $product) = @values;
	print "<tr bgcolor=$bg><td nowrap><font size=-1><A HREF=\"javascript:browseDetails($rid);\">" . formatID2($rid, 'SCREQ') . "</a></font></td>\n";
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

    print "<br><center><input type=button name=genrep value=\"Generate Report\" onClick=doReport();><br><br>\n";
}

#################
sub drawDetails {
#################
    print "<INPUT TYPE=HIDDEN NAME=option VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    my $rid = $q->param('id');
    my ($prodlist, $color, $fontsize, $rowflag, $sth, $sql, $element);

    $sql = "select to_char(r.datesubmitted, 'MM/DD/YYYY'), u.firstname || ' ' ||u.lastname, p.description, s.description, r.description, r.rationale, pr.name from $schema1.scrrequest r, $schema1.users u, $schema1.scrpriority p, $schema1.scrstatus s, $schema1.product pr where r.id = $rid and r.product = $productid and u.id=r.submittedby and p.id=r.priority and s.id=r.status and pr.id=r.product";
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
    print "<tr bgcolor=#ffffff><td valign=top><B>Description</B></TD><TD valign=top>$desc</TD></TR>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><B>Rationale</B></TD><TD valign=top>$rat</A></TD></TR>\n";
    print "<tr bgcolor=#ffffff><td valign=top><B>Priority</B></TD><TD WIDTH=400 VALIGN=TOP>$pid</TD></TR>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><B>Status</B></TD><TD valign=top>$sid</TD></TR>\n";
    print "<tr bgcolor=#ffffff><td valign=top><B>Affected Product</B></TD><TD valign=top>$product</TD></TR>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><B>Date Entered</B></TD><TD valign=top>$date</TD></TR>\n";
    print "<tr bgcolor=#ffffff><td valign=top><B>Entered By</B></TD><TD valign=top>$uid</TD></TR>\n";
    print "</table>\n";
    print "<br>\n<a href=javascript:history.back()><b>Return to Previous Page</b></a>\n";
}

