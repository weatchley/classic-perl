# UI Search functions
#
# $Source: /data/dev/rcs/prp/perl/RCS/UISearch.pm,v $
# $Revision: 1.7 $
# $Date: 2005/10/06 16:29:24 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: UISearch.pm,v $
# Revision 1.7  2005/10/06 16:29:24  naydenoa
# CREQ00065 - display 0th req/crit; update headers to sect id - sub id
#
# Revision 1.6  2005/09/28 23:22:14  naydenoa
# Phase 3 implementation
# Added AQAP search
#
# Revision 1.5  2005/02/07 22:08:50  naydenoa
# CREQ00037 - eliminate deleted QARD revisions from search results
# Tweak to sub doSearch
#
# Revision 1.4  2004/12/15 23:03:23  naydenoa
# Add Table 1A to search options, link to QARD/Table 1A display
# (Phase 2, CREQ00024)
#
# Revision 1.3  2004/07/19 22:42:46  naydenoa
# Fulfillment of CREQ00012
#
# Revision 1.2  2004/06/16 21:24:02  naydenoa
# Enabled for Phase 1, Cycle 2
#
# Revision 1.1  2004/04/22 20:41:13  naydenoa
# Initial revision
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

##############
sub getTitle {
##############
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

######################
sub getInitialValues { # routine to get initial CGI values and return in a hash
######################
    my %args = (
        dbh => "",
        @_,
    );
    
    my %valueHash = (
       &getStandardValues, (
       command => (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "search",
       id => (defined ($mycgi -> param ("id"))) ? $mycgi -> param ("id") : "",
       fullText => (defined ($mycgi -> param ("fullText"))) ? $mycgi -> param ("fullText") : "",
       aqapsection => (defined ($mycgi -> param ("aqapsection"))) ? $mycgi -> param ("aqapsection") : "",
       case => (defined ($mycgi -> param ("case"))) ? $mycgi -> param ("case") : "",
       sourcerequirement => (defined ($mycgi -> param ("sourcerequirement"))) ? $mycgi -> param ("sourcerequirement") : "",
       sourceid => (defined ($mycgi -> param ("sourceid"))) ? $mycgi -> param ("sourceid") : "",
       qardsection => (defined ($mycgi -> param ("qardsection"))) ? $mycgi -> param ("qardsection") : "",
       qardtable1a => (defined ($mycgi -> param ("qardtable1a"))) ? $mycgi -> param ("qardtable1a") : "",
       searchString => (defined ($mycgi -> param ("searchstring")) ? $mycgi -> param ("searchstring") : ""),
    ));
    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    return (%valueHash);
}

##############
sub doHeader {  # routine to generate html page headers
##############
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
       function submitTable (script, command, revisionid, qardtypeid) {
           document.$form.action = '$path' + script + '.pl';
           document.$form.command.value = command;
           document.$form.rid.value = revisionid;
           document.$form.revid.value = revisionid;
           document.$form.qardtypeid.value = qardtypeid;
           document.$form.submit();
       }
       function dummy(id) {
           alert('Not Yet Implemented');
       }

END_OF_BLOCK
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSUtilities => 'F', includeJSWidgets => 'F');
    
    $output .= "<table border=0 width=750 align=center><tr><td>\n";

    return($output);
}

##############
sub doFooter {  # routine to generate html page footers
##############
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

##################
sub doSearchForm {  # routine to generate html search form
##################
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
    $output .= "<table width=700 align=center border=$border cellpadding=0 cellspacing=7>\n";
    $output .= "<tr><td><b>Search for:" . &nbspaces(3) . "<input type=text name=searchstring maxlength=100 size=80></td>\n";
    $searchString =~ s/'/%27/g;
    $output .= "<script language=javascript>\n<!--\nvar mytext ='$searchString';\n$form.searchstring.value = unescape(mytext);\n//-->\n</script>\n";
    $output .= "<td><input type=button name=dosearch value=Submit onClick=javascript:submitSearch('$form','dosearch')></td></tr>\n";
    $output .= "</table><table width=700 align=center border=$border cellpadding=0 cellspacing=7>\n";
    my $fullText = $settings{fullText};
    $checked = ($fullText ne 'truncate') ? "checked" : "" ;
    $output .= "<tr><td><b>Show" . &nbspaces(1) . "<input type=radio name=fullText value=full $checked>full text" . &nbspaces(1);
    $checked = ($fullText eq 'truncate') ? "checked" : "" ;
    $output .= "<input type=radio name=fullText value=truncate $checked>first 250 characters" . &nbspaces(2) . "of each result</b></td>\n";
    $checked = ($settings{case} gt "") ? "checked" : "" ;
    $output .= "<td><b><input type=checkbox name=case value=case $checked> Case sensitive search</b></td></tr>\n";
    $output .= "</table><table width=700 align=center border=$border cellpadding=0 cellspacing=7>";
    $output .= "<tr><td valign=top width=200><b>Search the following areas:</b></font></td>\n";
    
    $checked = ($settings{sourcerequirement} gt "") ? "checked" : "" ;
    $output .= "<td><input type=checkbox name=sourcerequirement value=sourcerequirement $checked>Criteria from Source Documents<br>\n";
    $checked = ($settings{qardsection} gt "") ? "checked" : "" ;
    $output .= "<input type=checkbox name=qardsection value=qardsection $checked>QARD Sections<br>\n";
    $checked = ($settings{qardtable1a} gt "") ? "checked" : "" ;
    $output .= "<input type=checkbox name=qardtable1a value=qardsection $checked>QARD Table 1A Rows<br>\n";
    $checked = ($settings{aqapsection} gt "") ? "checked" : "" ;
    $output .= "<input type=checkbox name=aqapsection value=aqapsection $checked>AQAP Sections<br>\n";

    $output .= "</td></tr>\n";
    $output .= "</table>\n";

    return($output);
}

##############
sub doSearch {  # routine to generate html page footers
##############
    my %args = (
        @_,
    );
    my $output = "";
    $output .= "<input type=hidden name=sourceid value=>\n";
    $output .= "<input type=hidden name=rid value=>\n";
    $output .= "<input type=hidden name=revid value=>\n";
    $output .= "<input type=hidden name=qardtypeid value=>\n";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $results = "";
    my $rows = 0;
    my $srows = 0;
    my $qrows = 0;
    my $trows = 0;
    my $arows = 0;
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
    $results .= &startTable(columns => 4, align => 'center', title => '<font size=3>Search Results: Found <x> Matches (<y> in <a href=#source title="Jump to results from source documents">Source Documents</a>, <z> in <a href=#qard title="Jump to results from QARD">QARD</a>, <w> in <a href=#table1a title="Jump to results from QARD Table 1A">QARD Table 1A</a>, <v> in <a href=#aqap title="Jump to results from AQAP">AQAP</a>)</font>'); #&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to view individual results</font></i>)');
    $results .= &startRow(bgColor => "#f0f0f0");
    $results .= &addCol(value => "Section ID - Sub ID", width => 125, isBold => 1, align => 'center');
    $results .= &addCol(value => "Result&nbsp;Type", width => 110, isBold => 1, align => 'center');
    $results .= &addCol(value => "Text", width => 530, isBold => 1, align => 'center');
    $results .= &endRow;


    my @resultsArray;
    if (defined($mycgi->param("sourcerequirement"))) {
        my $type = "Requirement from Source Document";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchRequirement (dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, case => $settings{case}, project => $settings{project});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $sourceid, $longrequirementid, $text) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2], $resultArray[$i][3]);
            my $jump = ($srows == 0) ? "<a name=source></a>\n" : "";
            $rows++;
            $srows++;
            $results .= &startRow;
            my $prompt = "Click here for full information on $longrequirementid";
            $results .= &addCol(value => "$jump<center><a href=\"javascript:submitSource('requirement','browse_detail',$sourceid);\" title='$prompt'>$longrequirementid</a></center>", isBold => 1, width => 120, valign => "top") if ($type eq  "Requirement from Source Document");
#            $results .= &addCol(value => "<center>$longrequirementid</center>", isBold => 1, width => 120, valign => "top");
#            $results .= &addCol(value => "<center><a href=\"javascript:dummy($id);\" title='$prompt'>$longrequirementid</a></center>", isBold => 1, width => 120, valign => "top");
            $results .= &addCol(value => "<center>$type</center>", isBold => 1, valign => "top");
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1, valign => "top");
            $results .= &endRow;
        }
    }


    if (defined($mycgi->param("qardsection"))) {
        my $type = "QARD Section";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchSection (dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, case => $settings{case}, project => $settings{project}, qardtypeid => 1);
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $sectionid, $text, $revid, $revision) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2], $resultArray[$i][3], $resultArray[$i][4]);
            my $jump = ($qrows == 0) ? "<a name=qard></a>\n" : "";
            $rows++;
            $qrows++;
            $results .= &startRow;
            my $prompt = "Click here for full information on $sectionid";
#            my $revision = $revid; 
#            my ($revision) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "revid", table => "qard", where => "id = $revid"); 
            $results .= &addCol(value => "<center><a href=javascript:submitTable('qard','browse',$revid,1)>$revision<br>$sectionid</a></center>", isBold => 1, width => 120, valign => "top");
            $results .= &addCol(value => "$jump<center>$type</center>", isBold => 1, valign => "top");
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1, valign => "top");
            $results .= &endRow;
        }
    }

    if (defined($mycgi->param("qardtable1a"))) {
        my $type = "QARD Table 1A Row";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchTable1A (dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, case => $settings{case}, project => $settings{project});
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $item, $subid, $text, $revid) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2], $resultArray[$i][3], $resultArray[$i][4]);
            my $jump = ($trows == 0) ? "<a name=table1a></a>\n" : "";
            $rows++;
            $trows++;
            $results .= &startRow;
            my $prompt = "Click here for full information on $item";
            $item = ($subid) ? "$item - $subid" : $item;
            my ($revision) = &getSingleRow (dbh => $args{dbh}, schema => $args{schema}, what => "revid", table => "qard", where => "id = $revid"); 
            $results .= &addCol(value => "<center><a href=javascript:submitTable('qard','update_select_table',$revid,1)>QARD $revision<br>Row $item</a></center>", isBold => 1, width => 120, valign => "top");
            $results .= &addCol(value => "$jump<center>$type</center>", isBold => 1, valign => "top");
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1, valign => "top");
            $results .= &endRow;
        }
    }


    if (defined($mycgi->param("aqapsection"))) {
        my $type = "AQAP Section";
        $output .= "<!--$type-->\n";
        my ($rowCount, @resultArray) = &searchSection (dbh => $args{dbh}, schema => $args{schema}, searchString => $searchString, case => $settings{case}, project => $settings{project}, qardtypeid => 2);
        for (my $i=0; $i < $rowCount; $i++) {
            my ($id, $sectionid, $text, $revid, $revision) = ($resultArray[$i][0], $resultArray[$i][1], $resultArray[$i][2], $resultArray[$i][3], $resultArray[$i][4]);
            my $sectionidnospace = $sectionid;
            $sectionidnospace =~ s/ //g;
            my $jump = ($arows == 0) ? "<a name=aqap></a>\n" : "";
            $rows++;
            $arows++;
            $results .= &startRow;
            my $prompt = "Click here for full information on $sectionid";
            $results .= &addCol(value => "<center><a href=javascript:submitTable('qard','browse',$revid,2)>AQAP $revision<br>$sectionid</a></center>", isBold => 1, width => 120, valign => "top");
            $results .= &addCol(value => "$jump<center>$type</center>", isBold => 1, valign => "top");
            $text = &highlightResults(text => $text, searchString => $searchString, case => $settings{case});
            $results .= &addCol(value => &getDisplayString($text, &getStringDisplayLength(str => $text, fullText => $settings{fullText})), isBold => 1, valign => "top");
            $results .= &endRow;
        }
    }


#################################################
    $results .= &endTable . "</center>\n";
    my $plural = ($rows != 1) ? "es" : "";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, projectID => $settings{project}, 
          logMessage => "Search for \"$searchString\" - found $rows match$plural", type => 6);
    if ($rows > 0) {
        $results =~ s/<x>/$rows/;
        $results =~ s/<y>/$srows/;
        $results =~ s/<z>/$qrows/;
        $results =~ s/<w>/$trows/;
        $results =~ s/<v>/$arows/;
        $results =~ s/Matches/Match/ if ($rows == 1);
        $output .= $results;
    } 
    else {
        my $message = "No matches found for \"$searchString\"";
        $message =~ s/'/%27/g;
        $output .= doAlertBox(text => $message);
    }

    $output .= "";
    
    return($output);
}

######################
sub highlightResults {
######################
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

############################
sub getStringDisplayLength {
############################
   my %args = (
      @_,
   );
   return ($args{fullText} eq 'truncate') ? 250 : length($args{str});
}

###############
1; #return true
