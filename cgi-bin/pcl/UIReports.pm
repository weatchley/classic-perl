# UI Report functions for the SCM
#
# $Source: /data/dev/rcs/pcl/perl/RCS/UIReports.pm,v $
#
# $Revision: 1.5 $
#
# $Date: 2003/02/12 18:50:40 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIReports.pm,v $
# Revision 1.5  2003/02/12 18:50:40  atchleyb
# added session management
#
# Revision 1.4  2003/02/03 20:38:56  atchleyb
# changed DB_Utilities to DBShared
#
# Revision 1.3  2003/02/03 20:03:50  atchleyb
# removed refs to SCM
#
# Revision 1.2  2002/12/02 18:09:56  atchleyb
# updated link style for main menu to display properly in Ie 5, 5.5, and 6
#
# Revision 1.1  2002/10/31 17:03:16  atchleyb
# Initial revision
#
#
#
#

package UIReports;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBShared qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Text_Menus;
use Tie::IxHash;
use Tables;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);
#use vars qw ();
use integer;

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
      &getInitialValues       &doHeader             &doFooter
      &getTitle               &doMainMenu
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doFooter
      &getTitle               &doMainMenu
    )]
);

my $mycgi = new CGI;


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "Reports";
   if ($args{command} eq "?") {
      $title = "Reports";
   } elsif ($args{command} eq "?") {
      $title = "Reports";
   }
   return ($title);
}


###################################################################################################################################
sub getInitialValues {  # routine to get initial CGI values and return in a hash
###################################################################################################################################
    my %args = (
        dbh => "",
        @_,
    );
    
    my %valueHash = (
       schema => (defined($mycgi->param("schema"))) ? $mycgi->param("schema") : $ENV{'SCHEMA'},
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "browse",
       username => (defined($mycgi->param("username"))) ? $mycgi->param("username") : "",
       userid => (defined($mycgi->param("userid"))) ? $mycgi->param("userid") : "",
       server => (defined($mycgi->param("server"))) ? $mycgi->param("server") : "$SYSServer",
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
       sessionID => (defined($mycgi->param("sessionid"))) ? $mycgi->param("sessionid") : "0",
    );
    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        schema => $ENV{SCHEMA},
        title => 'PCL User Functions',
        displayTitle => 'T',
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $form = $args{form};
    my $path = $args{path};
    my $username = $settings{username};
    my $userid = $settings{userid};
    my $Server = $settings{server};
    
    my $extraJS = "";
    $extraJS .= <<END_OF_BLOCK;
    function doBrowse(script) {
      	$form.command.value = 'browse';
       	$form.action = '$path' + script + '.pl';
        $form.submit();
    }
    function submitForm3(script, command, type) {
        document.$form.command.value = command;
        document.$form.type.value = type;
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'main';
        document.$form.submit();
    }


END_OF_BLOCK
    $output .= &doStandardHeader(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'F', includeJSWidgets => 'F');
    
    $output .= "<input type=hidden name=type value=0>\n";
    $output .= "<input type=hidden name=projectID value=0>\n";
    #$output .= "<input type=hidden name=server value=$Server>\n";
    $output .= "<table border=0 width=750 align=center><tr><td>\n";

    return($output);
}


###################################################################################################################################
sub doFooter {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    
    $output .= &doStandardFooter();

    return($output);
}


###################################################################################################################################
sub doMainMenu {  # routine to generate main report menu
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my $message = '';
    my $menu1 = new Text_Menus;

    $output .= "<center>\n";

# Sample section
#    my $sampleMenu = new Text_Menus;
        
#    $sampleMenu->addMenu(name => "report1", label => "Report 1", contents => "javascript:alert('Submit Report');");
#    $sampleMenu->addMenu(name => "report2", label => "Report 2", contents => "Test 2");
#    $sampleMenu->addMenu(name => "report3", label => "Report 3", contents => "Test 3");
#    $sampleMenu->addMenu(name => "report4", label => "Report 4", contents => "Test 4");
#    $sampleMenu->addMenu(name => "report5", label => "Report 5", contents => "Test 5");
#    $sampleMenu->addMenu(name => "report6", label => $SomeReportMenu->label(), contents => $SomeReportMenu->contents(), title => $SomeReportMenu->label());
		  
    my $splMenu = new Text_Menus;
    $splMenu->addMenu(name => 'softwareProjects', label => 'Software Projects', contents => 'Software Projects');
    $splMenu->addMenu(name => 'softwareProducts', label => 'Software Products', contents => 'Software Products');
    $splMenu->addMenu(name => 'releaseHistory', label => 'Product Release History', contents => 'Product Release History');
    $splMenu->addMenu(name => 'configItems', label => 'Product Configuration Items', contents => 'Product Configuration Items');
    $splMenu->addMenu(name => 'productBaseline', label => 'Current Product Baselines', contents => 'Current Product Baselines');
    $splMenu->addMenu(name => 'baselineItem', label => 'Baseline Configuration Item', contents => 'Baseline Configuration Item');
    $splMenu->addMenu(name => 'baselineHistory', label => 'Baseline History', contents => 'Baseline History');

    my $scrMenu = new Text_Menus;     
    $scrMenu->addMenu(name => 'scrMenu', label => 'Software Change Requests', contents => 'Software Change Requests');

    my $sccbMenu = new Text_Menus;
    $sccbMenu->addMenu(name => 'sccbMenu', label => 'Software Configuration Control Board Members', contents => 'Software Configuration Control Board Members');
		  
    my $usersMenu = new Text_Menus;
    $usersMenu->addMenu(name => 'sysusers', label => 'System Users', contents => 'System Users');
    $usersMenu->addMenu(name => 'userspriv', label => 'Users by Privilege', contents => 'Users by Privilege');
        
# Top menu
    $menu1->addMenu(name => "spl", label => "Software Project Library", contents => $splMenu->buildMenus(name => 'spl', type => 'bullets'), title => 'Software Project Library Reports');
           $menu1->addMenu(name => "scr", label => "Software Change Requests", contents => $scrMenu->buildMenus(name => 'sccb', type => 'bullets'), title => 'Project Software Change Request Reports');
    $menu1->addMenu(name => "sccb", label => "Software Configuration Control Board", contents => $sccbMenu->buildMenus(name => 'sccb', type => 'bullets'), title => 'Software Configuration Control Board Reports');
    $menu1->addMenu(name => "users", label => "Users", contents => $usersMenu->buildMenus(name => 'users', type => 'bullets'), title => 'Users');

    my $menutype = ((defined($mycgi->param('menutype'))) ? $mycgi->param('menutype') : "table");
    #$menutype="tabs";
    $menu1->imageSource("$SYSImagePath/");
    $output .= $menu1->buildMenus(name => 'ReportMenu1', type => $menutype, linkStyle=>"'overline underline'");

    $output .= "</center>\n";
    
    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
