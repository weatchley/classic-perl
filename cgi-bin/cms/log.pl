#!/usr/local/bin/newperl
#
# $Date: 2001/06/01 22:32:53 $
# $Author: naydenoa $
# $Locker:  $
# $Log: log.pl,v $
# Revision 1.9  2001/06/01 22:32:53  naydenoa
# Minor tweaks
#
# Revision 1.8  2001/06/01 17:32:28  naydenoa
# Added errors to activity log - color-coded error text in red
#
# Revision 1.7  2001/05/08 17:13:44  naydenoa
# Added filter by user to activities and error logs
#
# Revision 1.6  2000/11/01 19:21:50  munroeb
# fixed localtime() function error
#
# Revision 1.5  2000/10/18 15:53:42  munroeb
# added additional formatting features to system
#
# Revision 1.4  2000/10/18 14:29:10  munroeb
# removed hardcode reference schema perm
#
# Revision 1.3  2000/10/18 14:24:54  munroeb
# fixed schema issue
#
# Revision 1.2  2000/10/12 22:51:38  munroeb
# changed Past month to Past 30 Days
#
# Revision 1.1  2000/10/12 22:45:01  munroeb
# Initial revision
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

###############
sub drawQuery {
###############
    my ($view, $type, $query, $user) = @_;
    my ($title);
    my %userhash = get_lookup_values($dbh, 'users', "lastname || ', ' || firstname || ';' || usersid", 'usersid', "usersid > 0");
    my $key;

    $title = "Activity Log" if $type eq "activity";
    $title = "Error Log" if $type eq "error";
    
    print <<queryformtop;
<SCRIPT LANGUAGE=JavaScript1.2>
    
    function setOption(value) {
	for (i = 0; i < document.log.query.length; i++) {
	    if (document.log.query[i].value == value) {
		return i;
	    }
	}
    }
    function browsedetails(interfaceLevel, id) {
	document.log.action = "$ONCSCGIDir/browse.pl";
	document.log.option.value = 'details';
	document.log.theinterface.value = "issues";
	document.log.interfaceLevel.value = interfaceLevel;
	document.log.id.value = id;
	document.log.submit();
    }
    if (parent.titlebar) {
	doSetTextImageLabel('$title');
    }
    document.log.type.value = \'$type\';
    </SCRIPT>

<CENTER><BR>
<TABLE BORDER=0 WIDTH=400 CELLSPACING=5 CELLPADDING=5 align=center>
<TR><TD ALIGN=right width=150><B>View:</B></td><td>
<SELECT NAME=query><! onChange="javascript:document.log.view.value = \'results\'; document.log.submit();">
<OPTION VALUE="today">Today</OPTION>
<OPTION VALUE="yesterday">Yesterday</OPTION>
<OPTION VALUE="7days">Past 7 Days</OPTION>
<OPTION VALUE="month">Past 30 Days</OPTION>
<OPTION VALUE="100">Last 100 Entries</OPTION>
<OPTION VALUE="1000">Last 1000 Entries</OPTION>
<OPTION VALUE="all">All Entries</OPTION>
</SELECT>
</TD>
<td align=right><b>&nbsp;&nbsp;User:</b> </td><td>   
<select name=selecteduser>
<option valie=-1 selected>All Users
queryformtop

    foreach $key (sort keys %userhash) {
	my $usernamestring = $key;
	$usernamestring =~ s/;$userhash{$key}//g;
	if ($userhash{$key} == $user){
	    print "<option value=\"$userhash{$key}\" selected>$usernamestring\n";
	}
	else {
	    print "<option value=\"$userhash{$key}\">$usernamestring\n";
	}
    }
    print <<eof_drawQuery;
    </select>
</td>
<td align=center>
<input type=button value=Display name=displaylog onClick="javascript:document.log.view.value = \'results\'; document.log.submit();"></td></tr>
</TABLE><BR>
eof_drawQuery

    if ($query) {
        print "<SCRIPT LANGUAGE=JavaScript1.2>document.log.query[setOption(\"$query\")].selected = true;</SCRIPT>\n";
    }
}

#################
sub drawResults {
#################
    my ($view, $type, $query, $user) = @_;
    my ($iserror, $header, $sql, $sth, $timei, $mmm, $dd, $yyyy);
    my (@myArray, $i, $rowflag, $color, $title, $display_user);
    my ($count, $sql2);

    my $userwhere = ($user eq "All Users") ? "" : "a.usersid = $user and";
    my $selectedusername = ($user eq "All Users") ? $user : get_fullname($dbh, $schema, $user);
    &drawQuery($view, $type, $query, $user);

    ## determine whether error or activity log; set appropriate variables
    if ($type eq "activity") {
        $iserror = "";
        $title = "Activity/<font color=#990000>Error</font> Text";
        $header = "Activity Log";
    }
    if ($type eq "error") {
        $iserror = "a.iserror = 'T' and";
        $title = "Error Text";
        $header = "Error Log";
    }
    ## build sql query according to which query option user selected
    my @months = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

    (undef,undef,undef,$dd,$mmm,$yyyy,undef,undef,undef) = localtime(time);
    $yyyy = $yyyy + 1900;
    $mmm = $months[$mmm];
    $timei = uc("$dd-$mmm-$yyyy");

    if ($query eq "today") {
        $header = $header." - Today";
        $sql = "select TO_CHAR(a.datelogged,'DD-MON-YY HH24:MI:SS'), 
                       b.firstname, b.lastname, a.description, 
                       b.usersid, a.iserror 
                from $schema.activity_log a, $schema.users b 
                where $userwhere $iserror 
                      to_date(a.datelogged) = to_date(\'$timei\') and 
                      a.usersid = b.usersid 
                order by a.datelogged desc";
        $sql2 = "select count(a.datelogged) 
                 from $schema.activity_log a, $schema.users b 
                 where $userwhere $iserror 
                       to_date(a.datelogged) = to_date(\'$timei\') and 
                       a.usersid = b.usersid 
                 order by a.datelogged desc";
    }
    if ($query eq "yesterday") {
        $header = $header." - Yesterday";
        $sql = "select TO_CHAR(a.datelogged,'DD-MON-YY HH24:MI:SS'), 
                       b.firstname, b.lastname, a.description, 
                       b.usersid, a.iserror 
                from $schema.activity_log a, $schema.users b 
                where $userwhere $iserror 
                      to_date(a.datelogged) = to_date(\'$timei\') - 1 and 
                      a.usersid = b.usersid 
                order by a.datelogged desc";
        $sql2 = "select count(a.datelogged) 
                 from $schema.activity_log a, $schema.users b 
                 where $userwhere $iserror 
                       to_date(a.datelogged) = to_date(\'$timei\') - 1 and 
                       a.usersid = b.usersid 
                 order by a.datelogged desc";
    }
    if ($query eq "7days") {
        $header = $header." - Past 7 Days";
        $sql = "select TO_CHAR(a.datelogged,'DD-MON-YY HH24:MI:SS'), 
                        b.firstname, b.lastname, a.description, 
                        b.usersid, a.iserror 
                from $schema.activity_log a, $schema.users b 
                where $userwhere $iserror 
                      to_date(datelogged) between to_date(\'$timei\') - 7 and 
                      to_date(\'$timei\') and a.usersid = b.usersid 
                order by a.datelogged desc";
        $sql2 = "select count(a.datelogged) 
                 from $schema.activity_log a, $schema.users b 
                 where $userwhere $iserror
                       to_date(datelogged) between to_date(\'$timei\') - 7 and
                       to_date(\'$timei\') and a.usersid = b.usersid 
                 order by a.datelogged desc";
    }
    if ($query eq "month") {
        $header = $header." - Past Month";
        $sql = "select TO_CHAR(a.datelogged,'DD-MON-YY HH24:MI:SS'), 
                       b.firstname, b.lastname, a.description, 
                       b.usersid, a.iserror 
                from $schema.activity_log a, $schema.users b 
                where $userwhere $iserror 
                      to_date(a.datelogged) between 
                      add_months(to_date(\'$timei\'), -1) and 
                      to_date(\'$timei\') and a.usersid = b.usersid 
                order by a.datelogged desc";
        $sql2 = "select count(a.datelogged) 
                 from $schema.activity_log a, $schema.users b 
                 where $userwhere $iserror 
                       to_date(a.datelogged) between 
                       add_months(to_date(\'$timei\'), -1) and 
                       to_date(\'$timei\') and a.usersid = b.usersid 
                 order by a.datelogged desc";
    }
    if ($query eq "all" || $query == 100 || $query == 1000) {
        $header = $header." - All Entries" if $query eq "all";
        $header = $header." - Last 100 Entries" if $query == 100;
        $header = $header." - Last 1000 Entries" if $query == 1000;

        $sql = "select TO_CHAR(a.datelogged,'DD-MON-YY HH24:MI:SS'), 
                       b.firstname, b.lastname, a.description, 
                       b.usersid, a.iserror 
                from $schema.activity_log a, $schema.users b 
                where $userwhere $iserror 
                      a.usersid = b.usersid 
                order by a.datelogged desc";
        $sql2 = "select count(a.datelogged) 
                 from $schema.activity_log a, $schema.users b 
                 where $userwhere $iserror 
                       a.usersid = b.usersid 
                 order by a.datelogged desc";
    }
    $sth = $dbh->prepare($sql2);
    $sth->execute();

    ($count) = $sth->fetchrow_array();

    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=770 BORDERCOLOR=#c0c0c0>\n";
    print "<TR><TD COLSPAN=3 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=3><B>$header for $selectedusername ($count total) (<i><font size=2>Most recent entries at top</font></i>)</B></FONT></TD></TR>\n";
    print "<TR>\n";
    print "<TH VALIGN=BOTTOM><font size=-1>Date Logged</TH>\n";
    print "<TH VALIGN=BOTTOM><font size=-1>User</TH>\n";
    print "<TH VALIGN=BOTTOM><font size=-1>$title</TH>\n";

    $rowflag = 1;

    if ($query != 100 && $query != 1000) {

        $sth = $dbh->prepare($sql);
        $sth->execute();
        while (@myArray = $sth->fetchrow_array()) {

            if ($myArray[4] == 0) {
                $display_user = "<FONT COLOR=#0000ff>None</FONT>";
            } else {
                $display_user = "<A HREF=\"javascript:browsedetails(\'enteredby\',\'$myArray[4]\');\">$myArray[1] $myArray[2]</A>";
            }
            if ($rowflag == 1) {
                $color = "#eeeeee";
                $rowflag = 0;
            } else {
                $color = "#ffffff";
                $rowflag = 1;
            }
            print "<TR><TD VALIGN=TOP BGCOLOR=$color NOWRAP><FONT SIZE=2>$myArray[0]</TD><TD VALIGN=TOP BGCOLOR=$color NOWRAP><FONT SIZE=2>$display_user</TD><TD BGCOLOR=$color><FONT SIZE=2>";
	    if ($myArray[5] eq "T" && $iserror eq "") {
		print "<font color=#990000>$myArray[3]</font>";
	    }
	    else {
		print "$myArray[3]";
	    }
	    print "</TD></TR>\n";
        }
    } 
    else {
        $sth = $dbh->prepare($sql);
        $sth->execute();
        $i = 0;
        while (@myArray = $sth->fetchrow_array()) {

            if ($myArray[4] == 0) {
                $display_user = "<FONT COLOR=#0000ff>None</FONT>";
            } else {
                $display_user = "<A HREF=\"javascript:browsedetails(\'enteredby\',\'$myArray[4]\');\">$myArray[1] $myArray[2]</A>";
            }

            if ($i < $query * 1){
                if ($rowflag == 1) {
                    $color = "#eeeeee";
                    $rowflag = 0;
                } else {
                    $color = "#ffffff";
                    $rowflag = 1;
                }
                print "<TR><TD VALIGN=TOP BGCOLOR=$color NOWRAP><FONT SIZE=2>$myArray[0]</TD><TD VALIGN=TOP BGCOLOR=$color NOWRAP><FONT SIZE=2>$display_user</TD><TD BGCOLOR=$color><FONT SIZE=2>";
		if ($myArray[5] eq "T" && $iserror eq "") {
		    print "<font color=#990000>$myArray[3]</font>";
		}
		else {
		    print "$myArray[3]";
		}
		print "</TD></TR>\n";
            } else {
                last;
            }
            $i++;
        }
    }
    print "</TABLE>\n";
}
