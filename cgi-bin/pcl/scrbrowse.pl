#!/usr/local/bin/perl
#
# $Source: /data/dev/rcs/pcl/perl/RCS/scrbrowse.pl,v $
# $Revision: 1.9 $
# $Date: 2003/02/12 16:38:03 $
# $Author: atchleyb $
# $Locker:  $
# $Log: scrbrowse.pl,v $
# Revision 1.9  2003/02/12 16:38:03  atchleyb
# added session management
#
# Revision 1.8  2003/02/11 20:17:46  naydenoa
# Updated !/usr/local/bin/newperl to !/usr/local/bin/perl
# Replaced references to SCR's with "Change Request"
# Replaced module and variable names with generic ones, e.g. SCMHeader with SharedHeader, etc...
#
# Revision 1.7  2002/12/04 22:32:53  naydenoa
# Added filtering by status and type and updated filtering by product
#
# Revision 1.6  2002/11/25 21:06:59  naydenoa
# Added titles to hyperlinks, moved function drawResults to UI_SCR module
#
# Revision 1.5  2002/11/07 23:40:23  naydenoa
# Changed a parameter passed to doRemarksTable
#
# Revision 1.4  2002/11/07 19:02:19  naydenoa
# Added checkLogin
#
# Revision 1.3  2002/10/31 18:46:35  naydenoa
# Added use of UI and DB modules, cleaned up code
#
# Revision 1.2  2002/09/18 21:49:48  atchleyb
# updated to remove DB_Utilities
#
# Revision 1.1  2002/09/17 21:19:30  starkeyj
# Initial revision
#

use strict;
use integer;
use SharedHeader qw(:Constants);
use Tables qw(:Functions);
use DB_SCR qw(:Functions);
use DBShared qw(:Functions);
use UI_SCR qw(:Functions);
use UIShared qw(:Functions);
use UI_Widgets qw(:Functions);
use CGI;

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

my $dbh = db_connect();
$dbh -> {LongReadLen} = 1000000;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

@| = 1;

my $mycgi = new CGI;

my $schema = $mycgi  -> param ("schema");
my $username = $mycgi  -> param ("username");
my $userid = $mycgi  -> param ("userid");
my $option = $mycgi  -> param ("option"); 
my $sessionID = ((defined($mycgi->param("sessionid"))) ? $mycgi->param("sessionid") : 0);
$option = "main" if !defined($option);
my $projectid = (defined ($mycgi -> param ("projectid"))) ? $mycgi -> param ("projectid") : "";
my $productid = $mycgi -> param ("productid");
my $requestid = $mycgi -> param ("requestid");
my $project = $mycgi -> param ("project");
my $browseby = $mycgi -> param ("browseby");
####### This product is actually the project ID ######
my $product = ($browseby eq "product") ? $mycgi -> param ("product") : 0;
my $status = ($browseby eq "status") ? $mycgi -> param ("status") : 0;
my $type = ($browseby eq "type") ? $mycgi -> param ("type") : 0;
&checkLogin (cgi => $mycgi);
if ($SYSUseSessions eq 'T') {
   &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$sessionID);
}
 
my $outstr = "";

&drawHead();
print "$outstr";
if ($option eq "main"){
    my $filterid;
    $filterid = $status if $status;
    $filterid = $product if $product;
    $filterid = $type if $type;
    $project = $product; #### for new browse by product ####
    my $where = ($project) ? "project_id = $project" : "";
    my $projectname = singleValueLookup (dbh => $dbh, schema => $schema, table => "project", column => "name", lookupid => $project);
    my $prodcount = getCount (dbh => $dbh, schema => $schema, table => "product", where => $where);
    my $prodcount2 = ($prodcount%2 == 0) ? $prodcount : $prodcount + 1;
    my $count = 0;
    my $liststring = "";
    my $drawstring = "";
    my $menustring = "";
    $where = ($where) ? " where $where" : "";
    my $prod = $dbh -> prepare ("select id, name from $schema.product $where order by name");
    $prod -> execute;
    while (my ($pid, $pn) = $prod -> fetchrow_array) {
	$count ++;
	my $pname = $pn;
	$pn =~ s/ //g; ; 
	$liststring .= "<b><li><a href=#$pn title=\"Click here to jump to list of change requests for $pname\"><font color=#000099 size=2>$pname</font></a></b>\n";
	$drawstring .= &drawResults(pid => $pid, pname => "$pname", schema => $schema, dbh => $dbh, filter => $browseby, filterid => $filterid);
	if ($count == $prodcount2/2) {
	    $liststring .= "</td><td>\n";
	}
    }
    $prod -> finish;
    if ($count < 1) {
	$menustring .= "<tr><td>There are no products associated with project $projectname</td></tr>";
    }
    if ($prodcount > 1) {
	print "<tr><td>\n";
	print "<table width=750 cellpadding=0 cellspacing=10 align=center>\n";
	print "<tr valign=top><td width=50%>\n";
	print $liststring;
	print &endRow;
	print &endTable;
	print "</td></tr>\n";
    }
    print $menustring;
    print $drawstring;
}

&drawDetails (id => $requestid, pid => $productid) if $option eq "details";
print "</form>\n<br>\n</body></html>\n";

my $stat = db_disconnect($dbh);

##############
sub drawHead {
##############
print "content-type:  text/html\n\n";

print "<html>\n<head>\n<title>PCL - Change Requests - Browse</title>\n";
print "<script language=JavaScript1.2><!--\n";
print "function browseDetails(id, pid) {\n";
print "    var script = \'scrbrowse\';";
print "    document.$form.option.value = \'details\'\;\n";
print "    document.$form.requestid.value = id\;\n";
print "    document.$form.productid.value = pid\;\n";
print "    document.$form.action = \'$path\' + script + \'.pl\';\n";
print "    document.$form.target = \'main\';\n";
print "    document.$form.submit()\;\n";
print "}\n\n";

print "//-->\n</script>\n";
$outstr .= &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => 'Browse Software Change Requests');

print<<eof_head_too;
</head>
<body background=$SYSImagePath/background.gif TEXT=#000099 LINK=#0000FF VLINK=#0000FF ALINK=#0000FF TOPMARGIN=0 LEFTMARGIN=0><center>
<form name=$form method=post target='main' action=$ENV{SCRIPT_NAME}>
<input type=hidden name=userid value=$userid>
<input type=hidden name=username value=$username>
<input type=hidden name=schema value=$schema>
<input type=hidden name=sessionid value='$sessionID'>
<input type=hidden name=projectid value=$projectid>
<input type=hidden name=productid value=$productid>
<input type=hidden name=requestid value=$requestid>
<input type=hidden name=option value=$option>
eof_head_too
}

#################
sub drawDetails {
#################
my %args = (
	    id => 0,
	    pid => 0,
	    @_,
	    );
    print "<input type=hidden name=option VALUE=>\n";
    print "<input type=hidden name=id VALUE=>\n";
    print "<input type=hidden name=pid VALUE=>\n";

    print &doDisplayTable (rid => $args{id}, productid => $args{pid}, dbh => $dbh, schema => $schema, browsedetails => 1);
    print "<tr><td><br>";
    print doRemarksTable (cid => $args{id}, iid => $args{pid}, dbh => $dbh, schema => $schema);
    print "</td></tr>";
}
