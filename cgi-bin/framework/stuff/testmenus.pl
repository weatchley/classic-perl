#!/usr/local/bin/perl -w

# test page
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
#
#

$| = 1;

use strict;
use integer;
use SharedHeader qw(:Constants);
use DBShared qw(:Functions);
use Text_Menus;
use UI_Widgets qw(:Functions);
use UIShared qw(:Functions);
use CGI;

my $mycgi = new CGI;


$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
$dbh = &db_connect();
my %settings = getInitialValues(dbh => $dbh);

my $schema = $settings{schema};
my $command = $settings{command};
my $username = $settings{username};
my $userid = $settings{userid};
my $title = $settings{title};
my $error = "";
#&checkLogin(cgi => $cgi);
#&checkLogin ($username, $userid, $schema);
my $errorstr = "";

#! test for invalid or timed out session
#&validateCurrentSession(dbh => $dbh, schema => $schema, userID => $userid, sessionID => $settings{sessionID});


###################################################################################################################################
sub getInitialValues {  # routine to get initial CGI values and return in a hash
###################################################################################################################################
    my %args = (
        dbh => "",
        @_,
    );
    
    my %valueHash = (
       &getStandardValues, (
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "form",
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
       type => (defined($mycgi->param("type"))) ? $mycgi->param("type") : "",
    ));
    $valueHash{title} = "Test Menu";
    
    return (%valueHash);
}


###################################################################################################################################
sub doMenu {  # routine to generate utilities menu
###################################################################################################################################
    my %args = (
        @_,
    );
    my $menu1 = new Text_Menus;
    my $output = "";
    
    # display utilities menu -----------------------------------------------------------------------------

    $output .= "<center>\n";
    my $subMenuType = 'bullets';
    $subMenuType = 'tree';
    my $menutype = ((defined($mycgi->param('menutype'))) ? $mycgi->param('menutype') : "tabs");
    $menutype="tree";
    my $linkStyle = "'overline underline'";
    $linkStyle = "'none'";

# sub sub menu 1
    my $subSubMenu1 = new Text_Menus;
    $subSubMenu1->addMenu(name => 'sm1o1', label => 'Sub Menu 1 Option 1', contents => "stuff");
    $subSubMenu1->addMenu(name => 'sm1o2', label => 'Sub Menu 1 Option 2', contents => "stuff");
    $subSubMenu1->addMenu(name => 'sm1o3', label => 'Sub Menu 1 Option 3', contents => "stuff");
    $subSubMenu1->addMenu(name => 'sm1o4', label => 'Sub Menu 1 Option 4', contents => "stuff");

# sub menu 1
    my $subMenu1 = new Text_Menus;
    $subMenu1->addMenu(name => 'm1o1', label => 'Menu 1 Option 1', contents => "stuff");
    #$subMenu1->addMenu(name => 'm1o2', label => 'Menu 1 Option 2', contents => $subSubMenu1->buildMenus(name => 'm1o2a', type => $subMenuType), title => 'Sub Menu');
    $subMenu1->addMenu(name => 'm1o3', label => 'Menu 1 Option 3', contents => "stuff");
    $subMenu1->addMenu(name => 'm1o4', label => 'Menu 1 Option 4', contents => "stuff");

# sub menu 2
    my $subMenu2 = new Text_Menus;
    $subMenu2->addMenu(name => 'm2o1', label => 'Menu 2 Option 1', contents => "stuff");
    $subMenu2->addMenu(name => 'm2o2', label => 'Menu 2 Option 2', contents => "stuff");
    $subMenu2->addMenu(name => 'm2o3', label => 'Menu 2 Option 3', contents => "stuff");
    $subMenu2->addMenu(name => 'm2o4', label => 'Menu 2 Option 4', contents => "stuff");

# sub menu 3
    my $subMenu3 = new Text_Menus;
    $subMenu3->addMenu(name => 'm3o1', label => 'Menu 3 Option 1', contents => "stuff");
    $subMenu3->addMenu(name => 'm3o2', label => 'Menu 3 Option 2', contents => "stuff");
    $subMenu3->addMenu(name => 'm3o3', label => 'Menu 3 Option 3', contents => "stuff");
    $subMenu3->addMenu(name => 'm3o4', label => 'Menu 3 Option 4', contents => "stuff");

# sub menu 4
    my $subMenu4 = new Text_Menus;
    $subMenu4->addMenu(name => 'm4o1', label => 'Menu 4 Option 1', contents => "stuff");
    $subMenu4->addMenu(name => 'm4o2', label => 'Menu 4 Option 2', contents => "stuff");
    $subMenu4->addMenu(name => 'm4o3', label => 'Menu 4 Option 3', contents => "stuff");
    $subMenu4->addMenu(name => 'm4o4', label => 'Menu 4 Option 4', contents => "stuff");


# Top menu

    $menu1->addMenu(name => "m1", label => "Menu 1", status => 'open', contents => $subMenu1->buildMenus(name => 'm1', type => $subMenuType), title => 'Menu 1');
    $menu1->addMenu(name => "m2", label => "Menu 2", contents => $subMenu2->buildMenus(name => 'm2', type => $subMenuType), title => 'Menu 2');
    $menu1->addMenu(name => "m3", label => "Menu 3", contents => $subMenu3->buildMenus(name => 'm3', type => $subMenuType), title => 'Menu 3');
    $menu1->addMenu(name => "m4", label => "Menu 4", contents => $subMenu4->buildMenus(name => 'm4', type => $subMenuType), title => 'Menu 4');

    $menu1->imageSource("$SYSImagePath/");
    $output .= $menu1->buildMenus(name => 'TestMenu1', type => $menutype, linkStyle=>$linkStyle);

    $output .= "</center>\n";

    return($output);
}


###################################################################################################################################
###################################################################################################################################


###################################################################################################################################
#
if ($command eq "form") {
    print &writeHTTPHeader;
    print &writeHTMLHead(title => $settings{title});
    eval {
        print &doMenu(dbh => $dbh, schema => $schema, title => $title, userID => $userid);
    };
    if ($@) {
        print doAlertBox(text => errorMessage($dbh, $username, $userid, $schema, "Test menu $form", $@));
    }
    print &doEndPage;
}


&db_disconnect($dbh);
exit();
