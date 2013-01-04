# UI Search functions
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

package UISearch;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBSearch qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
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
      &getInitialValues       &doHeader             &doSearchForm
      &doFooter               &getTitle             &doSearch
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &getInitialValues       &doHeader             &doSearchForm
      &doFooter               &getTitle             &doSearch
    )]
);

my $mycgi = new CGI;


###################################################################################################################################
sub getTitle {
###################################################################################################################################
   my %args = (
      @_,
   );
   my $title = "";
   if ($args{command} eq "dosearch") {
      $title = "Search";
   } else {
      $title = "Search";
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
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "search",
       id => (defined($mycgi->param("id"))) ? $mycgi->param("id") : "",
       project => (defined($mycgi->param("project"))) ? $mycgi->param("project") : 0,
       fullText => (defined($mycgi->param("fullText"))) ? $mycgi->param("fullText") : "",
       case => (defined($mycgi->param("case"))) ? $mycgi->param("case") : "",
       doprojectdescription => (defined($mycgi->param("doprojectdescription"))) ? $mycgi->param("doprojectdescription") : "",
       doproductdescription => (defined($mycgi->param("doproductdescription"))) ? $mycgi->param("doproductdescription") : "",
       docidescription => (defined($mycgi->param("docidescription"))) ? $mycgi->param("docidescription") : "",
       dociversion => (defined($mycgi->param("dociversion"))) ? $mycgi->param("dociversion") : "",
       dociversioncontents => (defined($mycgi->param("dociversioncontents"))) ? $mycgi->param("dociversioncontents") : "",
       doscrdescription => (defined($mycgi->param("doscrdescription"))) ? $mycgi->param("doscrdescription") : "",
       doscrrationale => (defined($mycgi->param("doscrrationale"))) ? $mycgi->param("doscrrationale") : "",
       doscractionstaken => (defined($mycgi->param("doscractionstaken"))) ? $mycgi->param("doscractionstaken") : "",
       doscrrejectionrationale => (defined($mycgi->param("doscrrejectionrationale"))) ? $mycgi->param("doscrrejectionrationale") : "",
       doscrremarks => (defined($mycgi->param("doscrremarks"))) ? $mycgi->param("doscrremarks") : "",
       doproceduresdescription => (defined($mycgi->param("doproceduresdescription"))) ? $mycgi->param("doproceduresdescription") : "",
       doproductdescription => (defined($mycgi->param("doproductdescription"))) ? $mycgi->param("doproductdescription") : "",
       doprocedureversion => (defined($mycgi->param("doprocedureversion"))) ? $mycgi->param("doprocedureversion") : "",
       doprocedureversioncontent => (defined($mycgi->param("doprocedureversioncontent"))) ? $mycgi->param("doprocedureversioncontent") : "",
       dotemplatesdescription => (defined($mycgi->param("dotemplatesdescription"))) ? $mycgi->param("dotemplatesdescription") : "",
       dotemplateversion => (defined($mycgi->param("dotemplateversion"))) ? $mycgi->param("dotemplateversion") : "",
       dotemplateversioncontent => (defined($mycgi->param("dotemplateversioncontent"))) ? $mycgi->param("dotemplateversioncontent") : "",
       searchString => (defined($mycgi->param("searchstring")) ? $mycgi->param("searchstring") : ""),
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
        title => 'Search',
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
    
    my $extraJS = "";
    $extraJS .= <<END_OF_BLOCK;
      function submitSearch() {
         if ($form.searchstring.value == "") {
            alert ("No search string has been entered");
         } else {
            submitForm('$form','dosearch');
         }
      }
      function scr(id,product) {
         var script = 'scrbrowse';
         dummy$form.action = '$path' + script + '.pl';
         //dummy$form.command.value = 'browse';
         dummy$form.option.value = 'details';
         dummy$form.requestid.value = id;
         dummy$form.productid.value = product;
         dummy$form.submit();
      }
       function displayDocumentVersions(documentID, type) {
           dummy$form.command.value = 'browseversion';
           dummy$form.document.value = documentID;
           dummy$form.type.value = type;
           dummy$form.action = '$path' + 'documents.pl';
           dummy$form.target = 'main';
           dummy$form.submit();
       }
       function dummy(id) {
           alert('Not Yet Implemented');
       }

END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'F', includeJSWidgets => 'F');
    
    $output .= "<br>\n<table border=0 width=750 align=center><tr><td>\n";

    return($output);
}


###################################################################################################################################
sub doFooter {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my $form = $args{form};
    my $username = $args{username};
    my $userid = $args{userID};
    my $schema = $args{schema};
    my $extraHTML = "";
    
    $output .= "<br><br>\n</td></tr></table>\n";
    $extraHTML .= "<form name=dummy$form method=post>\n";
    $extraHTML .= "<input type=hidden name=username value=\"$username\">\n";
    $extraHTML .= "<input type=hidden name=userid value=\"$userid\">\n";
    $extraHTML .= "<input type=hidden name=schema value=\"$schema\">\n";
    $extraHTML .= "<input type=hidden name=id value=0>\n";
    $extraHTML .= "<input type=hidden name=document value=0>\n";
    $extraHTML .= "<input type=hidden name=type value=0>\n";
    $extraHTML .= "<input type=hidden name=requestid value=0>\n";
    $extraHTML .= "<input type=hidden name=command value=0>\n";
    $extraHTML .= "<input type=hidden name=option value=0>\n";
    $extraHTML .= "<input type=hidden name=productid value=0>\n";
    $extraHTML .= "</form>\n";
    
    $output .= &doStandardFooter(form => $form, extraHTML => $extraHTML);

    return($output);
}


###################################################################################################################################
sub doSearchForm {  # routine to generate html search form
###################################################################################################################################
    my %args = (
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $searchString = $settings{searchString};
    my $output = "";
    my $checked;
    my $form = $args{form};
    
    $output .= "";
    
    my $border = 0;
    $output .= "<table width=750 border=$border cellpadding=0 cellspacing=7>\n";
    $output .= "<tr><td><b>Search for:" . &nbspaces(3) . "<input type=text name=searchstring maxlength=100 size=80></td>\n";
    $searchString =~ s/'/%27/g;
    $output .= "<script language=javascript>\n<!--\nvar mytext ='$searchString';\n$form.searchstring.value = unescape(mytext);\n//-->\n</script>\n";
    $output .= "<td align=right><input type=button name=dosearch value=Submit onClick=javascript:submitSearch('$form','dosearch')></td></tr>\n";
    $output .= "</table><table width=750 border=$border cellpadding=0 cellspacing=7>\n";
    my $fullText = $settings{fullText};
    $checked = ($fullText ne 'truncate') ? "checked" : "" ;
    $output .= "<tr><td><b>Show" . &nbspaces(1) . "<input type=radio name=fullText value=full $checked>full text" . &nbspaces(1);
    $checked = ($fullText eq 'truncate') ? "checked" : "" ;
    $output .= "<input type=radio name=fullText value=truncate $checked>first 250 characters" . &nbspaces(2) . "of each result</b></td>\n";
    $checked = ($settings{case} gt "") ? "checked" : "" ;
    $output .= "<td align=right><b><input type=checkbox name=case value=case $checked> Case sensitive search</b></td></tr>\n";
    $output .= "</table><table width=750 border=$border cellpadding=0 cellspacing=7>";
    $output .= "<tr><td><b>Search the following areas:</b></font></td></tr>\n";
    
    $output .= "<tr><td>TBD</td></tr>\n";


    $output .= "</table>\n";

    return($output);
}


###################################################################################################################################
sub doSearch {  # routine to generate html page footers
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $results = "";
    my $rows = 0;
    my $searchString = $settings{searchString};
    
    $searchString =~ s/\\/\\\\/g;
    $searchString =~ s/\{/\\\{/g;
    $searchString =~ s/\}/\\\}/g;
    $searchString =~ s/\(/\\\(/g;
    $searchString =~ s/\)/\\\)/g;
    $searchString =~ s/\[/\\\[/g;
    $searchString =~ s/\]/\\\]/g;
    $searchString =~ s/\*/\\\*/g;
    $searchString =~ s/\./\\\./g;
    $searchString =~ s/\?/\\\?/g;
    $searchString =~ s/\+/\\\+/g;
    $searchString =~ s/\|/\\\|/g;
    $searchString =~ s/\^/\\\^/g;
    $searchString =~ s/\$/\\\$/g;
    $searchString =~ s.\/.\\\/.g;

    $output .= &doSearchForm(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, userID => $args{userID}, form => $args{form}, settings => \%settings);
    $output .= "<br>&nbsp;\n";
    $results .= &startTable(columns => 4, align => 'center', title => '<font size=3>Search Results: Found <x> Matches</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to view individual results</font></i>)');
    $results .= &startRow(bgcolor => "#f0f0f0");
    $results .= &addCol(value => "ID", width => 125, isBold => 1, align => 'center');
    $results .= &addCol(value => "Result Type", width => 110, isBold => 1, align => 'center');
    $results .= &addCol(value => "Text", width => 530, isBold => 1, align => 'center');
    $results .= &endRow;

###################################################################################################################################


###################################################################################################################################
    $results .= &endTable . "</center>\n";
    my $plural = ($rows != 1) ? "es" : "";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, projectID => $settings{project}, 
          logMessage => "Search for \"$searchString\" - found $rows match$plural", type => 6);
    if ($rows > 0) {
        $results =~ s/<x>/$rows/;
        $results =~ s/Matches/Match/ if ($rows == 1);
        $output .= $results;
    } else {
        my $message = "No matches found for \"$searchString\"";
        $message =~ s/'/%27/g;
        $output .= doAlertBox(text => $message);
    }

    $output .= "";
    
    return($output);
}


###################################################################################################################################
sub highlightResults {                                                                                                            #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $out = $args{text};
   if ($args{case} gt "") {
      $out =~ s/($args{searchString})/<font color=#ff0000>$1<\/font>/g;
   } else {
      $out =~ s/($args{searchString})/<font color=#ff0000>$1<\/font>/ig;
   }
   return ($out);
}


###################################################################################################################################
sub getStringDisplayLength {                                                                                                      #
###################################################################################################################################
   my %args = (
      @_,
   );
   return ($args{fullText} eq 'truncate') ? 250 : length($args{str});
}


###################################################################################################################################
###################################################################################################################################



1; #return true
