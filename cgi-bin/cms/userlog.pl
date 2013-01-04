#!/usr/local/bin/newperl
#
# $Date: 2002/04/23 21:41:44 $
# $Author: naydenoa $
# $Locker:  $
# $Log: userlog.pl,v $
# Revision 1.1  2002/04/23 21:41:44  naydenoa
# Initial revision
#
#

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use UI_Widgets;

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

my $view = $q->param("view"); $view = "results" if !defined($view);
my $type = $q->param("type"); $type = "activity" if !defined($type);
my $query = $q->param("query"); $query = "today" if !defined($query);
my $user = $q->param("selecteduser"); $user = "All Users" if !defined ($user);

&drawHead($type);
&drawQuery($view, $type, $query, $user) if $view eq "query";
&drawResults($view, $type, $query, $user) if $view eq "results";
&drawFoot();

$dbh->disconnect();

##############
sub drawHead {
##############
print "content-type: text/html\n\n";
print <<eof_head;
<HTML>
<HEAD>
<TITLE> Commitment Management System - Activity / Error Log </TITLE>
<SCRIPT SRC=$ONCSJavaScriptPath/oncs-utilities.js></SCRIPT>
</HEAD>

<BODY BACKGROUND=/cms/images/background.gif TEXT=#000099 LINK=#0000FF VLINK=#0000FF ALINK=#0000FF TOPMARGIN=0 LEFTMARGIN=0>

<FORM NAME=log METHOD=POST>
<INPUT TYPE=HIDDEN NAME=loginusersid VALUE=$loginusersid>
<INPUT TYPE=HIDDEN NAME=loginusername VALUE=$loginusername>
<INPUT TYPE=HIDDEN NAME=schema VALUE=$schema>
<INPUT TYPE=HIDDEN NAME=view VALUE=>
<INPUT TYPE=HIDDEN NAME=type VALUE=$type>

<INPUT TYPE=HIDDEN NAME=option VALUE=>
<INPUT TYPE=HIDDEN NAME=theinterface VALUE=>
<INPUT TYPE=HIDDEN NAME=interfaceLevel VALUE=>
<INPUT TYPE=HIDDEN NAME=id VALUE=>

<!-- End of drawHead -->
eof_head
}

##############
sub drawFoot {
##############
    print "</FORM><BR><BR></BODY></HTML>\n";
    print "<!-- End of drawFoot -->";
}

#################
sub drawResults {
#################
    my ($view, $type, $query, $user) = @_;
    my ($iserror, $header, $sql, $sth);
    my (@myArray, $i, $rowflag, $color, $title, $display_user);

    $header = "User Activity Log";

    $sql = "select firstname, lastname, usersid from $schema.users where isactive='T' order by lastname";        
    $sth = $dbh->prepare($sql);
    $sth->execute();

    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=400 align=center BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=3 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=3><B>User Activity Log</B></FONT></TD></TR>\n";
    print "<TR>\n";
    print "<TH VALIGN=BOTTOM><font size=-1>User</TH>\n";
    print "<TH VALIGN=BOTTOM><font size=-1>Last Login</TH>\n";

    $rowflag = 1;
    while (my ($first, $last, $uid) = $sth->fetchrow_array()) {
	$display_user = "$first $last";
	if ($rowflag == 1) {
	    $color = "#eeeeee";
	    $rowflag = 0;
	} else {
	    $color = "#ffffff";
	    $rowflag = 1;
	}
	my ($date) = $dbh -> selectrow_array ("select to_char (datelogged,'MM/DD/YYYY HH:MI:SS AM') from $schema.activity_log where usersid = $uid and description like '%logged in' order by datelogged desc");
	$date = ($date) ? $date : "Never logged in";
	print "<TR><TD VALIGN=TOP BGCOLOR=$color NOWRAP width=200><FONT SIZE=2>$display_user</TD><TD BGCOLOR=$color><FONT SIZE=2>$date</TD></TR>\n";
    }
    print "</TABLE>\n";
}
