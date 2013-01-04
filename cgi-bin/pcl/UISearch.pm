# UI User functions for the SCM
#
# $Source: /data/dev/rcs/pcl/perl/RCS/UISearch.pm,v $
#
# $Revision: 1.4 $
#
# $Date: 2003/02/14 21:00:50 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UISearch.pm,v $
# Revision 1.4  2003/02/14 21:00:50  atchleyb
# changed Template to Form
#
# Revision 1.3  2003/02/12 18:51:56  atchleyb
# added session management
#
# Revision 1.2  2003/02/03 20:09:23  atchleyb
# removed refs to SCM
#
# Revision 1.1  2002/11/27 21:05:54  atchleyb
# Initial revision
#
# Revision 1.2  2002/11/08 20:30:19  atchleyb
# updated calling format for doesUserHavePriv
#
# Revision 1.1  2002/10/24 22:12:27  atchleyb
# Initial revision
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
       schema => (defined($mycgi->param("schema"))) ? $mycgi->param("schema") : $ENV{'SCHEMA'},
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "search",
       username => (defined($mycgi->param("username"))) ? $mycgi->param("username") : "",
       userid => (defined($mycgi->param("userid"))) ? $mycgi->param("userid") : "",
       server => (defined($mycgi->param("server"))) ? $mycgi->param("server") : "$SYSServer",
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
    $output .= &doStandardHeader(schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
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
    my $sessionID = $args{sessionID};
    my $extraHTML = "";
    
    $output .= "<br><br>\n</td></tr></table>\n";
    $extraHTML .= "<form name=dummy$form method=post>\n";
    $extraHTML .= "<input type=hidden name=username value=\"$username\">\n";
    $extraHTML .= "<input type=hidden name=userid value=\"$userid\">\n";
    $extraHTML .= "<input type=hidden name=schema value=\"$schema\">\n";
    $extraHTML .= "<input type=hidden name=id value=0>\n";
    $extraHTML .= "<input type=hidden name=sessionid value='$sessionID'>\n";
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
#    $output .= "<tr><td><b>Search the following areas:</b></font></td></tr>\n";

    $output .= "<tr><td>\n";
    $output .= "<table border=0 cellpadding=0 cellspacing=0 align=center>\n";
    $output .= "<tr><td valign=top width=10%><b>Search:</b></td>\n";
    $output .= "<td valign=top><b>Project: \n";
    $output .= &buildProjectSelect(dbh => $args{dbh}, schema => $args{schema}, name => 'project', cgi => $mycgi);
    $output .= "</b></td></tr>\n";
    $output .= "<tr><td colspan=2>&nbsp;</td></tr>\n";
    $output .= "<tr><td colspan=2><table border=0 width=100% cellpadding=0 cellspacing=0><tr>\n";

    $output .= "<td valign=top>\n";
    $output .= "<table border=0 width=100% cellpadding=0 cellspacing=0>\n";
    $output .= "<tr><td valign=top><b>Projects</b></td></tr>\n";
    $checked = ($settings{doprojectdescription} gt "") ? "checked" : "" ;
    $output .= "<tr><td><input type=checkbox name=doprojectdescription value=projectdescription $checked> Summary Information</td></tr>\n";
    $checked = ($settings{doproductdescription} gt "") ? "checked" : "" ;
    $output .= "<tr><td><input type=checkbox name=doproductdescription value=productdescription $checked> Product Summary</td></tr>\n";
    $output .= "</table>\n";

    $output .= "<table border=0 width=100% cellpadding=0 cellspacing=0>\n";
    $output .= "<tr><td><font size=1>&nbsp;</font></td></tr>\n";
    $output .= "<tr><td valign=top><b>Non-code configuration Items</b></td></tr>\n";
    $checked = ($settings{docidescription} gt "") ? "checked" : "" ;
    $output .= "<tr><td><input type=checkbox name=docidescription value=cidescription $checked> Description</td></tr>\n";
    $output .= "<tr><td>\n";
    $checked = ($settings{dociversion} gt "") ? "checked" : "" ;
    $output .= "<tr><td><input type=checkbox name=dociversion value=dociversion $checked> Change History</td></tr>\n";
    if ($SYSProductionStatus == 0 && 1==2) {
        $checked = ($settings{dociversioncontents} gt "") ? "checked" : "" ;
        $output .= "<tr><td><input type=checkbox name=dociversioncontents value=dociversioncontents $checked> Contents</td></tr>\n";
    }
    $output .= "</table>\n";
    $output .= "</td><td> &nbsp; &nbsp; </td>\n";

    $output .= "<td valign=top><table border=0 width=100% cellpadding=0 cellspacing=0>\n";
    $output .= "<tr><td valign=top><b>Software Change Requests</b></td></tr>\n";
    $checked = ($settings{doscrdescription} gt "") ? "checked" : "" ;
    $output .= "<tr><td><input type=checkbox name=doscrdescription value=scrdescription $checked> Description</td></tr>\n";
    $checked = ($settings{doscrrationale} gt "") ? "checked" : "" ;
    $output .= "<tr><td><input type=checkbox name=doscrrationale value=scrrationale $checked> Rationale</td></tr>\n";
    $checked = ($settings{doscractionstaken} gt "") ? "checked" : "" ;
    $output .= "<tr><td><input type=checkbox name=doscractionstaken value=scractionstaken $checked> Actions Taken</td></tr>\n";
    $checked = ($settings{doscrrejectionrationale} gt "") ? "checked" : "" ;
    $output .= "<tr><td><input type=checkbox name=doscrrejectionrationale value=scrrejectionrationale $checked> Rejection Rationale</td></tr>\n";
    $checked = ($settings{doscrremarks} gt "") ? "checked" : "" ;
    $output .= "<tr><td><input type=checkbox name=doscrremarks value=scrremarks $checked> Remarks</td></tr>\n";
    $output .= "</table></td><td> &nbsp; &nbsp; </td>\n";

    $output .= "<td valign=top>\n";
    $output .= "<table border=0 width=100% cellpadding=0 cellspacing=0>\n";
    $output .= "<tr><td valign=top><b>Procedures</b></td></tr>\n";
    $checked = ($settings{doproceduresdescription} gt "") ? "checked" : "" ;
    $output .= "<tr><td><input type=checkbox name=doproceduresdescription value=proceduresdescription $checked> Description</td></tr>\n";
    $checked = ($settings{doprocedureversion} gt "") ? "checked" : "" ;
    $output .= "<tr><td><input type=checkbox name=doprocedureversion value=doprocedureversion $checked> Change History</td></tr>\n";
    if ($SYSProductionStatus == 0 && 1==2) {
        $checked = ($settings{doprocedureversioncontent} gt "") ? "checked" : "" ;
        $output .= "<tr><td><input type=checkbox name=doprocedureversioncontent value=doprocedureversioncontent $checked> Contents</td></tr>\n";
    }
    $output .= "</table>\n";

    if (&doesUserHavePriv(dbh=>$args{dbh}, schema=>$args{schema}, userid=>$args{userID}, privList=>[-1])) {
        $output .= "<table border=0 width=100% cellpadding=0 cellspacing=0>\n";
        $output .= "<tr><td><font size=1>&nbsp;</font></td></tr>\n";
        $output .= "<tr><td valign=top><b>Forms</b></td></tr>\n";
        $checked = ($settings{dotemplatesdescription} gt "") ? "checked" : "" ;
        $output .= "<tr><td><input type=checkbox name=dotemplatesdescription value=dotemplatesdescription $checked> Description</td></tr>\n";
        $checked = ($settings{dotemplateversion} gt "") ? "checked" : "" ;
        $output .= "<tr><td><input type=checkbox name=dotemplateversion value=dotemplateversion $checked> Change History</td></tr>\n";
        if ($SYSProductionStatus == 0 && 1==2) {
            $checked = ($settings{dotemplateversioncontent} gt "") ? "checked" : "" ;
            $output .= "<tr><td><input type=checkbox name=dotemplateversioncontent value=dotemplateversioncontent $checked> Contents</td></tr>\n";
        }
        $output .= "</table>\n";
    }
    $output .= "</td><td> &nbsp; &nbsp; </td>\n";

    $output .= "</tr>\n";

    $output .= "</table></td></tr></table>\n";

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
    #my %products = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'product', idColumn => "id" , nameColumn => "name")};
    my %products = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'product', idColumn => "id" , nameColumn => "acronym")};

###################################################################################################################################
    if (defined($mycgi->param("doscrdescription"))) {
        my $type = "SCR Description";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchSCRDescription(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
              case => $settings{case}, project => $settings{project});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $text, $product) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2]);
            $rows++;
            $results .= &startRow;
            my $formattedid = $products{$product} . " - " . &formatID("SCREQ", 5, $id);
            my $prompt = "Click here for full information on SCR $formattedid";
            $results .= &addCol(value => "<center><a href=\"javascript:scr('$id', '$product');\" title='$prompt'>$formattedid</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }

    if (defined($mycgi->param("doscrrationale"))) {
        my $type = "SCR Rationale";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchSCRRationale(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
              case => $settings{case}, project => $settings{project});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $text, $product) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2]);
            $rows++;
            $results .= &startRow;
            my $formattedid = $products{$product} . " - " . &formatID("SCREQ", 5, $id);
            my $prompt = "Click here for full information on SCR $formattedid";
            $results .= &addCol(value => "<center><a href=\"javascript:scr('$id', '$product');\" title='$prompt'>$formattedid</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }

    if (defined($mycgi->param("doscractionstaken"))) {
        my $type = "SCR Actions Taken";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchSCRActionsTaken(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
              case => $settings{case}, project => $settings{project});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $text, $product) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2]);
            $rows++;
            $results .= &startRow;
            my $formattedid = $products{$product} . " - " . &formatID("SCREQ", 5, $id);
            my $prompt = "Click here for full information on SCR $formattedid";
            $results .= &addCol(value => "<center><a href=\"javascript:scr('$id', '$product');\" title='$prompt'>$formattedid</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }

    if (defined($mycgi->param("doscrrejectionrationale"))) {
        my $type = "SCR Rejection Rationale";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchSCRRejectionRationale(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
              case => $settings{case}, project => $settings{project});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $text, $product) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2]);
            $rows++;
            $results .= &startRow;
            my $formattedid = $products{$product} . " - " . &formatID("SCREQ", 5, $id);
            my $prompt = "Click here for full information on SCR $formattedid";
            $results .= &addCol(value => "<center><a href=\"javascript:scr('$id', '$product');\" title='$prompt'>$formattedid</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }
      
    if (defined($mycgi->param("doscrremarks"))) {
        my $type = "SCR Remarks";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchSCRRemarks(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
            case => $settings{case}, project => $settings{project});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $text, $product) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2]);
            $rows++;
            $results .= &startRow;
            my $formattedid = $products{$product} . " - " . &formatID("SCREQ", 5, $id);
            my $prompt = "Click here for full information on SCR $formattedid";
            $results .= &addCol(value => "<center><a href=\"javascript:scr('$id', '$product');\" title='$prompt'>$formattedid</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }
      
    if (defined($mycgi->param("doproceduresdescription"))) {
        my $type = "Procedure Description";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchProcedureDescription(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
            case => $settings{case});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $name, $text) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2]);
            $rows++;
            $results .= &startRow;
            $name =~ s/\..{0,3}$//;
            my $prompt = "Click here for full information on $name";
            $results .= &addCol(value => "<center><a href=\"javascript:displayDocumentVersions($id, 10);\" title='$prompt'>$name</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }
      
    if (defined($mycgi->param("doprocedureversion"))) {
        my $type = "Procedure Change History";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchProcedureVersion(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
            case => $settings{case});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $name, $text, $version) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2], $resultArray[$i][3]);
            $rows++;
            $results .= &startRow;
            $name =~ s/\..{0,3}$//;
            my $prompt = "Click here for full information on $name";
            $name .= " - $version";
            $results .= &addCol(value => "<center><a href=\"javascript:displayDocumentVersions($id, 10);\" title='$prompt'>$name</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }
      
    if (defined($mycgi->param("doprocedureversioncontent"))) {
        my $type = "Procedure Contents";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchProcedureVersionContent(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
            case => $settings{case});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $name, $text, $version) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2], $resultArray[$i][3]);
            $rows++;
            $results .= &startRow;
            $name =~ s/\..{0,3}$//;
            my $prompt = "Click here for full information on $name";
            $name .= " - $version";
            $results .= &addCol(value => "<center><a href=\"javascript:displayDocumentVersions($id, 10);\" title='$prompt'>$name</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }
      
    if (defined($mycgi->param("dotemplatesdescription"))) {
        my $type = "Form Description";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchTemplateDescription(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
            case => $settings{case});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $name, $text) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2]);
            $rows++;
            $results .= &startRow;
            $name =~ s/\..{0,3}$//;
            my $prompt = "Click here for full information on $name";
            $results .= &addCol(value => "<center><a href=\"javascript:displayDocumentVersions($id, 11);\" title='$prompt'>$name</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }
      
    if (defined($mycgi->param("dotemplateversion"))) {
        my $type = "Form Change History";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchTemplateVersion(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
            case => $settings{case});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $name, $text, $version) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2], $resultArray[$i][3]);
            $rows++;
            $results .= &startRow;
            $name =~ s/\..{0,3}$//;
            my $prompt = "Click here for full information on $name";
            $name .= " - $version";
            $results .= &addCol(value => "<center><a href=\"javascript:displayDocumentVersions($id, 11);\" title='$prompt'>$name</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }
      
    if (defined($mycgi->param("dotemplateversioncontent"))) {
        my $type = "Form Contents";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchTemplateVersionContent(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
            case => $settings{case});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $name, $text, $version) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2], $resultArray[$i][3]);
            $rows++;
            $results .= &startRow;
            $name =~ s/\..{0,3}$//;
            my $prompt = "Click here for full information on $name";
            $name .= " - $version";
            $results .= &addCol(value => "<center><a href=\"javascript:displayDocumentVersions($id, 11);\" title='$prompt'>$name</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }
      
    if (defined($mycgi->param("docidescription"))) {
        my $type = "Configuration Item Description";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchConfigItemDescription(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
            case => $settings{case}, project => $settings{project});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $name, $text, $acronym) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2], $resultArray[$i][3]);
            $rows++;
            $results .= &startRow;
            $name =~ s/\..{0,3}$//;
            $name = "$acronym - $name";
            my $prompt = "Click here for full information on $name";
            $results .= &addCol(value => "<center><a href=\"javascript:displayDocumentVersions($id, 0);\" title='$prompt'>$name</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }
      
    if (defined($mycgi->param("dociversion"))) {
        my $type = "Configuration Item Change History";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchConfigItemVersion(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
            case => $settings{case}, project => $settings{project});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $name, $text, $version, $acronym) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2], $resultArray[$i][3], $resultArray[$i][4]);
            $rows++;
            $results .= &startRow;
            $name =~ s/\..{0,3}$//;
            my $prompt = "Click here for full information on $name";
            $name = "$acronym - $name - $version";
            $results .= &addCol(value => "<center><a href=\"javascript:displayDocumentVersions($id, 0);\" title='$prompt'>$name</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }
      
    if (defined($mycgi->param("dociversioncontents"))) {
        my $type = "Configuration Item Contents";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchConfigItemVersionContent(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
            case => $settings{case});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $name, $text, $version, $acronym) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2], $resultArray[$i][3], $resultArray[$i][4]);
            $rows++;
            $results .= &startRow;
            $name =~ s/\..{0,3}$//;
            my $prompt = "Click here for full information on $name";
            $name = "$acronym - $name - $version";
            $results .= &addCol(value => "<center><a href=\"javascript:displayDocumentVersions($id, 0);\" title='$prompt'>$name</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }
      
    if (defined($mycgi->param("doprojectdescription"))) {
        my $type = "Project Description";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchProjectDescription(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
            case => $settings{case}, project => $settings{project});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $name, $text) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2]);
            $rows++;
            $results .= &startRow;
            my $prompt = "Click here for full information on $name";
            $results .= &addCol(value => "<center><a href=\"javascript:dummy($id);\" title='$prompt'>$name</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }
      
    if (defined($mycgi->param("doproductdescription"))) {
        my $type = "Product Description";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchProductDescription(dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, 
            case => $settings{case}, project => $settings{project});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $name, $text) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2]);
            $rows++;
            $results .= &startRow;
            my $prompt = "Click here for full information on $name";
            $results .= &addCol(value => "<center><a href=\"javascript:dummy($id);\" title='$prompt'>$name</a></center>", isBold => 1);
            $results .= &addCol(value => "<center>$type</center>", isBold => 1);
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1);
            $results .= &endRow;
        }
    }

###################################################################################################################################
    $results .= &endTable . "</center>\n";
    my $plural = ($rows != 1) ? "es" : "";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, projectID => $settings{project}, 
          logMessage => "Search for \"$searchString\" - found $rows match$plural");
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
sub buildProjectSelect {                                                                                                          #
###################################################################################################################################
   my %args = (
      includeNotesProjects => 1,
      name => "project",
      @_,
   );
   my $out = "";
   my $name = "$args{name}";
   my $selectedProject = (defined($args{cgi}->param ($name))) ? $args{cgi}->param ($name) : ""; 
   tie my %projectNames, "Tie::IxHash";
   %projectNames = %{&getLookupValues(dbh => $args{dbh}, schema => $args{schema}, table => 'project', idColumn => "id" , nameColumn => "name", orderBy => "name")};
   $out .= "<select name=$name>\n";
   my $selected = (0 eq $selectedProject) ? " selected" : "";
   $out .= "<option value=0$selected> All\n";
   foreach my $projectID (keys (%projectNames)) {
      $selected = ($projectID eq $selectedProject) ? " selected" : "";
      if ($args{includeNotesProjects} || !&isNotesProject(dbh => $args{dbh}, schema => $args{schema}, project => $projectID)) { 
         $out .= "<option value='$projectID'$selected>$projectNames{$projectID}\n";
      }
   }
   $out .= "</select>";
   return ($out);
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
