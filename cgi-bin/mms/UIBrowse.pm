# UI Browse functions
#
# $Source: /data/dev/rcs/mms/perl/RCS/UIBrowse.pm,v $
#
# $Revision: 1.8 $
#
# $Date: 2005/08/18 19:03:03 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIBrowse.pm,v $
# Revision 1.8  2005/08/18 19:03:03  atchleyb
# CR00015 changed label for site browse
#
# Revision 1.7  2004/04/21 17:19:07  atchleyb
# Update look of menu page
#
# Revision 1.6  2004/01/12 19:40:35  atchleyb
# added link to browse sites
#
# Revision 1.5  2004/01/09 23:29:38  atchleyb
# added link to browse charge numbers
#
# Revision 1.4  2004/01/09 18:54:40  atchleyb
# added link to browse departments
#
# Revision 1.3  2004/01/08 17:26:19  atchleyb
# added link to browse accounts payable
#
# Revision 1.2  2003/12/15 18:47:18  atchleyb
# added code for receiving
#
# Revision 1.1  2003/11/12 20:31:56  atchleyb
# Initial revision
#
#
#
#
#

package UIBrowse;
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
   my $title = "Browse";
   if ($args{command} eq "?") {
      $title = "Browse";
   } elsif ($args{command} eq "?") {
      $title = "Browse";
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
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "browse",
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
    ));
    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        dbh => '',
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
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'F', includeJSWidgets => 'F');
    
    $output .= "<input type=hidden name=type value=0>\n";
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
sub doMainMenu {  # routine to generate main browse menu
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my $message = '';
    my @siteInfo = &getSiteInfoArray(dbh=>$args{dbh}, schema=>$args{schema});

    $output .= "<table border=0 align=center><tr><td valign=top>\n";
    #$output .= "<h2>Browse Page</h2>\n";
    $output .= "<ul>\n";
    $output .= "<li><a href=\"javascript:doBrowse('users');\"><b>System Users</b></a>\n";
    $output .= "<li><a href=\"javascript:doBrowse('sites');\"><b>Site Information</b></a><br>\n";
    $output .= "<li><a href=\"javascript:doBrowse('departments');\"><b>Departments</b></a>\n";
    $output .= "<li><a href=\"javascript:doBrowse('chargeNumbers');\"><b>Charge Numbers</b></a>\n";
    $output .= "<li><a href=\"javascript:doBrowse('clauses');\"><b>Clauses</b></a>\n";
    $output .= "<li><a href=\"javascript:doBrowse('roles');\"><b>Roles</b></a><br> (for site: <select name=rolesite size=1>\n";
    $output .= "<option value=0 selected>All Sites</option>\n";
    for (my $i=1; $i <= $#siteInfo; $i++) {
        $output .= "<option value=$i>$siteInfo[$i]{name}</option>\n";
    }
    $output .= "</select>)\n";
    $output .= "</ul></td><td valign=top><ul>\n";
    $output .= "<li><a href=\"javascript:doBrowse('vendors');\"><b>Vendors</b></a><br> ";
    $output .= "(Show <input type=checkbox name=showbidders value='T' checked>Bidders, &nbsp;";
    $output .= "<input type=checkbox name=showactive value='T' checked>Active, &nbsp;";
    $output .= "<input type=checkbox name=showarchived value='T'>Archived)";
    $output .= "<li><a href=\"javascript:doBrowse('purchaseDocuments');\"><b>Purchase Documents</b></a> ";
    $output .= "<li><a href=\"javascript:doBrowse('receiving');\"><b>Receiving Log</b></a> ";
    $output .= "<li><a href=\"javascript:doBrowse('accountsPayable');\"><b>Accounts Payable</b></a> ";
    $output .= "</ul>\n";
    $output .= "</td></tr></table>\n";

    
    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
