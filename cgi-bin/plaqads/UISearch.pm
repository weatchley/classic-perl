# UI Search functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/UISearch.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2005/04/04 16:18:20 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UISearch.pm,v $
# Revision 1.2  2005/04/04 16:18:20  atchleyb
# updated to allow for boolean search
#
# Revision 1.1  2004/11/09 19:09:36  atchleyb
# Initial revision
#
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
       fullText => (defined($mycgi->param("fullText"))) ? $mycgi->param("fullText") : "F",
       case => (defined($mycgi->param("case"))) ? $mycgi->param("case") : "F",
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
       notfirst => (defined($mycgi->param("notfirst")) ? $mycgi->param("notfirst") : "F"),
       matchType => (defined($mycgi->param("matchType")) ? $mycgi->param("matchType") : "full"),
       searchdocuments => (defined($mycgi->param("searchdocuments")) ? $mycgi->param("searchdocuments") : ((defined($mycgi->param("notfirst"))) ? "F" : "T")),
       searchextractions => (defined($mycgi->param("searchextractions")) ? $mycgi->param("searchextractions") : ((defined($mycgi->param("notfirst"))) ? "F" : "F")),
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
    $output .= "<input type=hidden name=notfirst value='T'>\n";
    my $matchType = $settings{matchType};
    $checked = ($matchType eq 'full') ? "checked" : "";
    $output .= "<tr colspan=2><td><b>Match" . &nbspaces(1) . "<input type=radio name=matchType value='full' $checked>whole phrase" . &nbspaces(1);
    $checked = ($matchType eq 'any') ? "checked" : "";
    $output .= "<input type=radio name=matchType value='any' $checked>any term" . &nbspaces(1);
    $checked = ($matchType eq 'all') ? "checked" : "";
    $output .= "<input type=radio name=matchType value='all' $checked>all terms</td></tr>";
    my $fullText = $settings{fullText};
    $checked = ($fullText eq 'T') ? "checked" : "" ;
    $output .= "<tr><td><b>Show" . &nbspaces(1) . "<input type=radio name=fullText value='T' $checked>full text" . &nbspaces(1);
    $checked = ($fullText eq 'F') ? "checked" : "" ;
    $output .= "<input type=radio name=fullText value='F' $checked>first 250 characters" . &nbspaces(2) . "of each result</b></td>\n";
    $checked = ($settings{case} eq "T") ? "checked" : "" ;
    $output .= "<td align=right><b><input type=checkbox name=case value='T' $checked> Case sensitive search</b></td></tr>\n";
    $output .= "</table><table width=750 border=$border cellpadding=0 cellspacing=7>";
    $output .= "<tr><td><b>Search the following areas:</b></font></td></tr>\n";
    $checked = ($settings{searchdocuments} eq "T") ? "checked" : "" ;
    $output .= "<tr><td><b><input type=checkbox name=searchdocuments value='T' $checked> Documents</b></td>\n";
    $checked = ($settings{searchextractions} eq "T") ? "checked" : "" ;
    $output .= "<td><b><input type=checkbox name=searchextractions value='T' $checked> Comments / Responses</b></td></tr>\n";


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
    
    my @searchTerms = &parseSearchString(string=>$searchString, matchType=>$settings{matchType});

    $output .= &doSearchForm(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, userID => $args{userID}, form => $args{form}, settings => \%settings);
    $output .= "<br>&nbsp;\n";
    $results .= &startTable(columns => 4, align => 'center', title => '<font size=3>Search Results: Found <x> Matches</font>&nbsp;&nbsp;&nbsp;(<i><font size=2>Click on ID to view individual results</font></i>)');
    $results .= &startRow(bgcolor => "#f0f0f0");
    $results .= &addCol(value => "ID", width => 125, isBold => 1, align => 'center');
    $results .= &addCol(value => "Result Type", width => 110, isBold => 1, align => 'center');
    $results .= &addCol(value => "Text", width => 530, isBold => 1, align => 'center');
    $results .= &endRow;

###################################################################################################################################
    if ($settings{searchdocuments} eq 'T') {
        my @documents = &searchDocuments(dbh=>$args{dbh}, schema=>$args{schema},searchString=>$searchString, caseSensitive=>$settings{case},
              matchType=>$settings{matchType}, searchTerms => \@searchTerms);
        for (my $i=0; $i<$#documents; $i++) {
            $rows++;
            $results .= &startRow(bgcolor => "#ffffff");
            $results .= &addCol(value => "<a href=\"javascript:browseDoc('$documents[$i]{id}');\">DOC-" . &lpadzero($documents[$i]{id},6) . "</a>", align=>'center', valign=>'top');
            $results .= &addCol(value=>"Document", align=>'center', valign=>'top');
            my $text = '';
            my $text2 = $documents[$i]{title};
            if (&matchFound(text=>$text2,caseSensitive=>$settings{case},matchType=>$settings{matchType}, searchTerms => \@searchTerms) == 1) {
                $text2 =~ s/\n/<br>\n/g;
                $text2 =~ s/  / &nbsp;/g;
                #$text2 = &getDisplayString($text2, getStringDisplayLength(fullText=>$settings{fullText}, str=>$text2));
                $text .= "<b>Title:</b> " . $text2;
            }
            $text2 = $documents[$i]{source};
            if (&matchFound(text=>$text2,caseSensitive=>$settings{case},matchType=>$settings{matchType}, searchTerms => \@searchTerms) == 1) {
                $text2 =~ s/\n/<br>\n/g;
                $text2 =~ s/  / &nbsp;/g;
                #$text2 = &getDisplayString($text2, getStringDisplayLength(fullText=>$settings{fullText}, str=>$text2));
                $text .= ((length($text) > 0) ? "<br>\n" : "") . "<b>Source:</b> " . $text2;
            }
            $text2 = $documents[$i]{url};
            if (&matchFound(text=>$text2,caseSensitive=>$settings{case},matchType=>$settings{matchType}, searchTerms => \@searchTerms) == 1) {
                $text2 =~ s/\n/<br>\n/g;
                $text2 =~ s/  / &nbsp;/g;
                #$text2 = &getDisplayString($text2, getStringDisplayLength(fullText=>$settings{fullText}, str=>$text2));
                $text .= ((length($text) > 0) ? "<br>\n" : "") . "<b>URL:</b> " . $text2;
            }
            $text2 = $documents[$i]{description};
            if (&matchFound(text=>$text2,caseSensitive=>$settings{case},matchType=>$settings{matchType}, searchTerms => \@searchTerms) == 1) {
                $text2 =~ s/\n/<br>\n/g;
                $text2 =~ s/  / &nbsp;/g;
                $text2 = &getDisplayString($text2, getStringDisplayLength(fullText=>$settings{fullText}, str=>$text2));
                $text .= ((length($text) > 0) ? "<br>\n" : "") . "<b>Description:</b> " . $text2;
            }
            $text2 = $documents[$i]{comments};
            if (&matchFound(text=>$text2,caseSensitive=>$settings{case},matchType=>$settings{matchType}, searchTerms => \@searchTerms) == 1) {
                $text2 =~ s/\n/<br>\n/g;
                $text2 =~ s/  / &nbsp;/g;
                $text2 = &getDisplayString($text2, getStringDisplayLength(fullText=>$settings{fullText}, str=>$text2));
                $text .= ((length($text) > 0) ? "<br>\n" : "") . "<b>Remarks:</b> " . $text2;
            }
            $text2 = $documents[$i]{filename};
            if (&matchFound(text=>$text2,caseSensitive=>$settings{case},matchType=>$settings{matchType}, searchTerms => \@searchTerms) == 1) {
                $text2 =~ s/\n/<br>\n/g;
                $text2 =~ s/  / &nbsp;/g;
                #$text2 = &getDisplayString($text2, getStringDisplayLength(fullText=>$settings{fullText}, str=>$text2));
                $text .= ((length($text) > 0) ? "<br>\n" : "") . "<b>File Name:</b> " . $text2;
            }
            $text2 = $documents[$i]{translation};
            if (&matchFound(text=>$text2,caseSensitive=>$settings{case},matchType=>$settings{matchType}, searchTerms => \@searchTerms) == 1) {
                $text2 =~ s/\n/<br>\n/g;
                $text2 =~ s/  / &nbsp;/g;
                $text2 = &getDisplayString($text2, getStringDisplayLength(fullText=>$settings{fullText}, str=>$text2));
                $text .= ((length($text) > 0) ? "<br>\n" : "") . "<b>Translation:</b> " . $text2;
            }
            $text2 = $documents[$i]{vcomments};
            if (&matchFound(text=>$text2,caseSensitive=>$settings{case},matchType=>$settings{matchType}, searchTerms => \@searchTerms) == 1) {
                $text2 =~ s/\n/<br>\n/g;
                $text2 =~ s/  / &nbsp;/g;
                $text2 = &getDisplayString($text2, getStringDisplayLength(fullText=>$settings{fullText}, str=>$text2));
                $text .= ((length($text) > 0) ? "<br>\n" : "") . "<b>Version Remarks:</b> " . $text2;
            }
            $results .= &addCol(value => &highlightResults(case=>$settings{case}, text=>$text, searchString=>$searchString,
                  searchTerms => \@searchTerms), align=>'left', valign=>'top');
            $results .= &endRow;
        }
    }

###################################################################################################################################
    if ($settings{searchextractions} eq 'T') {
        my @extractions = &searchExtractions(dbh=>$args{dbh}, schema=>$args{schema},searchString=>$searchString, caseSensitive=>$settings{case},
              matchType=>$settings{matchType}, searchTerms => \@searchTerms);
        for (my $i=0; $i<$#extractions; $i++) {
            $rows++;
            $results .= &startRow(bgcolor => "#ffffff");
            $results .= &addCol(value => "<a href=\"javascript:browseDoc('$extractions[$i]{sourcedoc}');\">DOC-" . &lpadzero($extractions[$i]{sourcedoc},6) . "</a>&nbsp;/" .
                "&nbsp;<a href=\"javascript:browseItem('$extractions[$i]{id}');\">$extractions[$i]{id}</a>", align=>'center', valign=>'top');
            $results .= &addCol(value=>"$extractions[$i]{typename}", align=>'center', valign=>'top');
            my $text = '';
            my $text2 = $extractions[$i]{text};
            if (&matchFound(text=>$text2,caseSensitive=>$settings{case},matchType=>$settings{matchType}, searchTerms => \@searchTerms) == 1) {
                $text2 =~ s/\n/<br>\n/g;
                $text2 =~ s/  / &nbsp;/g;
                $text2 = &getDisplayString($text2, getStringDisplayLength(fullText=>$settings{fullText}, str=>$text2));
                $text .= $text2;
            }
            $text2 = $extractions[$i]{context};
            if (&matchFound(text=>$text2,caseSensitive=>$settings{case},matchType=>$settings{matchType}, searchTerms => \@searchTerms) == 1) {
                $text2 =~ s/\n/<br>\n/g;
                $text2 =~ s/  / &nbsp;/g;
                $text2 = &getDisplayString($text2, getStringDisplayLength(fullText=>$settings{fullText}, str=>$text2));
                $text .= ((length($text) > 0) ? "<br>\n" : "") . "<b>Context:</b> " . $text2;
            }
            $results .= &addCol(value => &highlightResults(case=>$settings{case}, text=>$text, searchString=>$searchString,
                  searchTerms => \@searchTerms), align=>'left', valign=>'top');
            $results .= &endRow;
        }
    }

###################################################################################################################################
    $results .= &endTable . "</center>\n";
    my $plural = ($rows != 1) ? "es" : "";
    &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, projectID => $settings{project}, 
          logMessage => "Search for \"$searchString\" - found $rows match$plural (Match terms setting: $settings{matchType})", type => 6);
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
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function browseDoc (id) {
    var msg = '';
    $args{form}.id.value=id;
    if (msg != "") {
      alert (msg);
    } else {
        submitForm('documents', 'displaydocument');
    }
}

function browseItem (id) {
    var msg = '';
    $args{form}.id.value=id;
    if (msg != "") {
      alert (msg);
    } else {
        submitForm('extractions', 'displayextraction');
    }
}

//--></script>

END_OF_BLOCK
    
    return($output);
}


###################################################################################################################################
sub highlightResults {                                                                                                            #
###################################################################################################################################
    my %args = (
        searchTerms => '',
        @_,
    );
    my $arrayref = $args{searchTerms};
    my @searchTerms = @$arrayref;
    my $out = $args{text};
    for (my $i=0; $i<=$#searchTerms; $i++) {
        if ($args{case} eq "T") {
            $out =~ s/($searchTerms[$i])/<font color=#ff0000>$1<\/font>/g;
        } else {
            $out =~ s/($searchTerms[$i])/<font color=#ff0000>$1<\/font>/ig;
        }
    }
    return ($out);
    #return ($args{text});
}


###################################################################################################################################
sub getStringDisplayLength {                                                                                                      #
###################################################################################################################################
    my %args = (
        @_,
    );
    return ($args{fullText} eq 'F') ? 250 : length($args{str});
}


###################################################################################################################################
sub parseSearchString {                                                                                                           #
###################################################################################################################################
    my %args = (
        string => '',
        matchType => 'full', # 'full' | 'any' | 'all'
        @_,
    );
    my @terms;
    
    if ($args{matchType} eq 'full') {
        $terms[0] = $args{string};
    } elsif ($args{matchType} eq 'any' || $args{matchType} eq 'all') {
        @terms = split('\s', $args{string});
    } else {
        $terms[0] = $args{string};
    }

    return (@terms);
}


###################################################################################################################################
sub matchFound {                                                                                                                  #
###################################################################################################################################
    my %args = (
        text => '',
        caseSensitive => 'F',
        matchType => 'full', # 'full' | 'any' | 'all'
        searchTerms => '',
        @_,
    );
    my $arrayref = $args{searchTerms};
    my @searchTerms = @$arrayref;
    my $out = 0;
    if ($args{matchType} eq 'full' && defined($args{text})) {
        if ($args{caseSensitive} gt "T") {
            $out = ($args{text} =~ m/$searchTerms[0]/) ? 1 : 0;
        } else {
            $out = ($args{text} =~ m/$searchTerms[0]/i) ? 1 : 0;
        }
    } elsif ($args{matchType} eq 'any' && defined($args{text})) {
        for (my $i=0; $i<=$#searchTerms; $i++) {
            if ($args{caseSensitive} gt "T") {
                if ($args{text} =~ m/$searchTerms[$i]/) {
                    $out = 1;
                }
            } else {
                if ($args{text} =~ m/$searchTerms[$i]/i) {
                    $out = 1;
                }
            }
        }
    } elsif ($args{matchType} eq 'all' && defined($args{text})) {
        my $foundCount = 0;
        for (my $i=0; $i<=$#searchTerms; $i++) {
            if ($args{caseSensitive} gt "T") {
                if ($args{text} =~ m/$searchTerms[$i]/) {
                    $foundCount++;
                }
            } else {
                if ($args{text} =~ m/$searchTerms[$i]/i) {
                    $foundCount++;
                }
            }
        }
        if ($foundCount >= $#searchTerms) {
            $out = 1;
        }
    }

    return ($out);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
