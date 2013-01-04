# UI Browse functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/UIBrowse.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2004/11/16 19:36:58 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIBrowse.pm,v $
# Revision 1.2  2004/11/16 19:36:58  atchleyb
# added new browse filters
#
# Revision 1.1  2004/07/27 18:27:16  atchleyb
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
use UIDocuments qw(doBrowseDocumentFilter);
use UIExtractions qw(doBrowseExtractionFilter);
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
sub doMainMenu {  # routine to generate main report menu
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = '';

    $output .= "<center>\n";
    $output .= &doBrowseDocumentFilter(dbh=>$args{dbh}, schema=>$args{schema}, form=>$args{form}, buttonText=>"Browse", 
          title => 'Documents', settings => \%settings);
    #$output .= "<a href=javascript:submitForm('documents','browse')>Documents</a><br>\n";
    $output .= "<br>\n";
    $output .= &doBrowseExtractionFilter(dbh=>$args{dbh}, schema=>$args{schema}, form=>$args{form}, buttonText=>"Browse", 
          title => 'Comments/Responses', settings => \%settings);
    #$output .= "<a href=javascript:submitForm('extractions','browse')>Comments/Responses</a><br>\n";
    $output .= "</center>\n";

    
    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
