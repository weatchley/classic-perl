# UI Report functions
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

package UIReports;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBUtilities qw(:Functions);
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
       &getStandardValues, (
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "",
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
    ));
    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        schema => $ENV{SCHEMA},
        title => "$SYSType User Functions",
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
		  
    my $sampleMenu1 = new Text_Menus;
        
    #$sampleMenu1->addMenu(name => "1report1", label => "Report 1.1", contents => "javascript:alert('Submit Report');");
    $sampleMenu1->addMenu(name => '1report2', label => 'Report 1.2', contents => 'Test 2');
    #$sampleMenu1->addMenu(name => "1report3", label => "Report 1.3", contents => "Test 3");
    #$sampleMenu1->addMenu(name => "1report4", label => "Report 1.4", contents => "Test 4");
    #$sampleMenu1->addMenu(name => "1report5", label => "Report 1.5", contents => "Test 5");
		  
    my $sampleMenu2 = new Text_Menus;
        
    $sampleMenu2->addMenu(name => "2report1", label => "Report 2.1", contents => "javascript:alert('Submit Report');");
    #$sampleMenu2->addMenu(name => "2report2", label => "Report 2.2", contents => "Test 2");
    #$sampleMenu2->addMenu(name => "2report3", label => "Report 2.3", contents => "Test 3");
    #$sampleMenu2->addMenu(name => "2report4", label => "Report 2.4", contents => "Test 4");
    #$sampleMenu2->addMenu(name => "2report5", label => "Report 2.5", contents => "Test 5");
		  
    my $sampleMenu3 = new Text_Menus;
        
    $sampleMenu3->addMenu(name => "3report1", label => "Report 3.1", contents => "javascript:alert('Submit Report');");
    #$sampleMenu3->addMenu(name => "3report2", label => "Report 3.2", contents => "Test 2");
    #$sampleMenu3->addMenu(name => "3report3", label => "Report 3.3", contents => "Test 3");
    #$sampleMenu3->addMenu(name => "3report4", label => "Report 3.4", contents => "Test 4");
    #$sampleMenu3->addMenu(name => "3report5", label => "Report 3.5", contents => "Test 5");
		  
    my $usersMenu = new Text_Menus;
    $usersMenu->addMenu(name => 'sysusers', label => 'System Users', contents => 'System Users');
    $usersMenu->addMenu(name => 'userspriv', label => 'Users by Privilege', contents => 'Users by Privilege');
        
# Top menu
    $menu1->addMenu(name => "samp1", label => "Sample Menu 1", status => 'open', contents => $sampleMenu1->buildMenus(name => 'samp1', type => 'bullets'), title => 'Sample Menu 1 Reports');
    #$menu1->addMenu(name => "samp2", label => "Sample Menu 2", contents => $sampleMenu2->buildMenus(name => 'samp2', type => 'bullets'), title => 'Sample Menu 2 Reports');
    #$menu1->addMenu(name => "samp3", label => "Sample Menu 3", contents => $sampleMenu3->buildMenus(name => 'samp3', type => 'bullets'), title => 'Sample Menu 3 Reports');
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
