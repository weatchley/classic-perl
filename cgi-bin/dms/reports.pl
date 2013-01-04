#!/usr/local/bin/perl -w
#
# $Source: /data/dev/rcs/dms/perl/RCS/reports.pl,v $
#
# $Revision: 1.3 $
#
# $Date: 2002/06/26 15:05:12 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: reports.pl,v $
# Revision 1.3  2002/06/26 15:05:12  atchleyb
# updated to only display "under development"
#
# Revision 1.2  2002/05/28 16:34:02  atchleyb
# updated titles and test menus
#
# Revision 1.1  2002/03/08 21:10:01  atchleyb
# Initial revision
#
#
#

use integer;
use strict;
use DMS_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use Text_Menus;
use DBI;
use DBD::Oracle qw(:ora_types);

$| = 1;
my $dmscgi = new CGI;
my $userid = $dmscgi->param("userid");
my $username = $dmscgi->param("username");
my $schema = $dmscgi->param("schema");
my $command = defined($dmscgi->param("command")) ? $dmscgi->param("command") : "";
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

# Decisions section
        my $decisionsMenu = new Text_Menus;
        
        $decisionsMenu->addMenu(name => "report1", label => "Specific Decision", contents => "javascript:alert('Submit Report');");
        $decisionsMenu->addMenu(name => "report2", label => "Pending Decisions", contents => "Test 2");
        $decisionsMenu->addMenu(name => "report3", label => "Report 3", contents => "Test 3");
        $decisionsMenu->addMenu(name => "report4", label => "Report 4", contents => "Test 4");
        $decisionsMenu->addMenu(name => "report5", label => "Report 5", contents => "Test 5");
        #$decisionsMenu->addMenu(name => "report6", label => $SomeReportMenu->label(), contents => $SomeReportMenu->contents(), title => $SomeReportMenu->label());


# Top menu
        $menu1->addMenu(name => "summary", label => "Summary Reports", contents => "test", title => 'Summary Reports');
        $menu1->addMenu(name => "decisions", label => "Decisions", status => 'open', contents => $decisionsMenu->buildMenus(name=>'decisionsMenu', type => 'bullets'), title => 'Decisons');
        $menu1->addMenu(name => "templates", label => "Templates", contents => "test", title => 'Templates');
        $menu1->addMenu(name => "users", label => "Users", contents => "test", title => 'Users');

        my $menutype = ((defined($dmscgi->param('menutype'))) ? $dmscgi->param('menutype') : "table");
        #$menutype="tabs";
        $menu1->imageSource("$DMSImagePath/");
        $outputstring .= $menu1->buildMenus(name => 'ReportMenu1', type => $menutype);
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"generate a Status Report - Summary.",$@);
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

# tell the browser that this is an html page using the header method
print $dmscgi->header('text/html');

# build page
print <<END_OF_BLOCK;

<html>
<head>
   <base target=main>
   <title>Decision Management System</title>
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

<body background=$DMSImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
END_OF_BLOCK

if ($command ne 'report') {
    print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => "Reports");
}
print "<form name=$form target=cgiresults action=\"" . $path . "$form.pl\" method=post>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=command value=0>\n";

###################################################################################################################################

if ($command ne 'report') {
    eval {
        print "<table border=0 width=750 align=center><tr><td align=center>\n";
        
        #print &doMainMenu;
        print "Under Development\n";
        print "</td></tr>\n";
        
        #print "<tr><td>$printHeaderHelp</td></tr>\n";
        
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
