#!/usr/local/bin/newperl -w
#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
#
#

use integer;
use strict;
use BMS_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

$| = 1;
my $bmscgi = new CGI;
my $userid = $bmscgi->param("userid");
my $username = $bmscgi->param("username");
my $sessionID = $bmscgi->param("sessionid");
my $schema = $bmscgi->param("schema");
my $command = defined($bmscgi->param("command")) ? $bmscgi->param("command") : "";
my $underDevelopment = &nbspaces(3) . "<b><font size=2 color=#ff0000>(in development)</font></b>";
my $printHeaderHelp = "<table border=1 width=75% align=center><tr><td><font size=-1><b><i>To set report page headers and footers for printing, select Page Setup... from the File menu, remove the text from the Footer box and replace the text in the Header box with the following:</i> <br><center>&d &t &b&bPage &p of &P</center><i>Then click on OK.</i></b></font></td></tr></table>\n";
&checkLogin ($username, $userid, $schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $dbh;
my $errorstr = "";


###################################################################################################################################
sub doMainMenu {
###################################################################################################################################
    my $message = '';
    my $outputstring = '';
    eval {
        my $menu1 = new Text_Menus;

# Summary section
        my $summaryMenu = new Text_Menus;
        
        $summaryMenu->addMenu(name => "report1", label => "Report 1", contents => "javascript:alert('Submit Report');");
        $summaryMenu->addMenu(name => "report2", label => "Report 2", contents => "Test 2");
        $summaryMenu->addMenu(name => "report3", label => "Report 3", contents => "Test 3");
        $summaryMenu->addMenu(name => "report4", label => "Report 4", contents => "Test 4");
        $summaryMenu->addMenu(name => "report5", label => "Report 5", contents => "Test 5");
        #$SomeReportMenu->addMenu(name => "report6", label => $SomeReportMenu->label(), contents => $SomeReportMenu->contents(), title => $SomeReportMenu->label());

# Accounting section
        my $accountingMenu = new Text_Menus;
        
        $accountingMenu->addMenu(name => "report1", label => "Report 1", contents => "javascript:alert('Submit Report');");
        $accountingMenu->addMenu(name => "report2", label => "Report 2", contents => "Test 2");
        $accountingMenu->addMenu(name => "report3", label => "Report 3", contents => "Test 3");
        $accountingMenu->addMenu(name => "report4", label => "Report 4", contents => "Test 4");
        $accountingMenu->addMenu(name => "report5", label => "Report 5", contents => "Test 5");
        #$SomeReportMenu->addMenu(name => "report6", label => $SomeReportMenu->label(), contents => $SomeReportMenu->contents(), title => $SomeReportMenu->label());


# Top menu
        $menu1->addMenu(name => "summary", label => "Summary Reports", status => 'open', contents => $summaryMenu->buildMenus(name=>'summaryMenu', type => 'bullets'), title => 'Summary Reports');
        $menu1->addMenu(name => "accounting", label => "Accounting", contents => $accountingMenu->buildMenus(name=>'accountingMenu', type => 'bullets'), title => 'Accounting');
        $menu1->addMenu(name => "prs", label => "Purchase Requests", contents => "test", title => 'Purchase Requests');
        $menu1->addMenu(name => "pos", label => "Purchase Orders", contents => "test", title => 'Purchase Orders');

        my $menutype = ((defined($bmscgi->param('menutype'))) ? $bmscgi->param('menutype') : "table");
        #$menutype="tabs";
        $menu1->imageSource("$BMSImagePath/");
        $outputstring .= $menu1->buildMenus(name => 'ReportMenu1', type => $menutype);
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate Report menu.",$@);
        print doAlertBox( text => $message);
    }
    
    return ($outputstring);
}



###################################################################################################################################
# begin main
###################################################################################################################################


#$dbh = &db_connect(server => "ydoracle");
$dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;

#! test for invalid or timed out session, allow for guest access
if ($userid != 0) {
    &validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $sessionID);
}

# tell the browser that this is an html page using the header method
print $bmscgi->header('text/html');

# build page
print <<END_OF_BLOCK;

<html>
<head>
   <base target=main>
   <title>Business Management System</title>
</head>

<script language=javascript><!--

function submitForm(script, command) {
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'main';
    document.$form.submit();
}

function submitFormCGIResults(script, command) {
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'cgiresults';
    document.$form.submit();
}

//-->
</script>

<body background=$BMSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
END_OF_BLOCK

if ($command ne 'report') {
    print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Reports");
}
print "<form name=$form target=cgiresults action=\"" . $path . "$form.pl\" method=post>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=sessionid value=$sessionID>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=command value=0>\n";

###################################################################################################################################

if ($command ne 'report') {
    eval {
        print "<table border=0 width=750 align=center><tr><td align=center>\n";
        
        print &doMainMenu;
        print "</td></tr>\n";
        
        print "<tr><td>$printHeaderHelp</td></tr>\n";
        
        print "</table>\n";
    };
    if ($@) {
        my $message = errorMessage($dbh,$username,$userid,$schema,"reports menu screen.",$@);
        print doAlertBox( text => $message);
    }
} else {
    eval {

    };
    if ($@) {
        my $message = errorMessage($dbh,$username,$userid,$schema,"generate report.",$@);
        print doAlertBox( text => $message);
    }
}


print "</form>\n";
print <<END_OF_BLOCK;

</body>
</html>
END_OF_BLOCK


&db_disconnect($dbh);
exit();
