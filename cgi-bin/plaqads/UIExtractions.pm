# UI Extraction functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/UIExtractions.pm,v $
#
# $Revision: 1.4 $
#
# $Date: 2004/11/19 20:56:12 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIExtractions.pm,v $
# Revision 1.4  2004/11/19 20:56:12  atchleyb
# changed to have the user return to the screen they selected from when an add or update is performed
#
# Revision 1.3  2004/11/16 19:38:28  atchleyb
# added new browse filters
# added dual selects on categories, keywords, and related extractions
#
# Revision 1.2  2004/08/03 17:29:57  atchleyb
# updated code used to display which comments/responses are related
#
# Revision 1.1  2004/07/27 18:27:16  atchleyb
# Initial revision
#
#
#
#
#

package UIExtractions;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBExtractions qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Sessions qw(:Functions);
use DBDocuments qw(getDocumentInfo);
use DBUsers qw (getUserArray);
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
      &doBrowse               &doDisplayExtraction      &doDisplayExtractionVersion
      &getInitialValues       &doHeader                 &doUpdateExtractionSelect
      &doFooter               &getTitle                 &doExtractionEntryForm
      &doExtractionEntry      &doBrowseExtractionFilter
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doBrowse               &doDisplayExtraction      &doDisplayExtractionVersion
      &getInitialValues       &doHeader                 &doUpdateExtractionSelect
      &doFooter               &getTitle                 &doExtractionEntryForm
      &doExtractionEntry      &doBrowseExtractionFilter
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
   if (($args{command} eq "addextraction") || ($args{command} eq "addextractionform")) {
      $title = "Add Comment/Response";
   } elsif (($args{command} eq "updateextraction") || ($args{command} eq "updateextractionform") || ($args{command} eq "updateextractionselect")) {
      $title = "Update Comment/Response";
   } elsif (($args{command} eq "browse") || (($args{command} eq "displayextraction")) || ($args{command} eq "displayextractionform")) {
      $title = "Browse Comment/Response";
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
       documentid => (defined($mycgi->param("documentid"))) ? $mycgi->param("documentid") : 0,
       location => (defined($mycgi->param("location"))) ? $mycgi->param("location") : "",
       text => (defined($mycgi->param("text"))) ? $mycgi->param("text") : "",
       type => (defined($mycgi->param("type"))) ? $mycgi->param("type") : 0,
       context => (defined($mycgi->param("context"))) ? $mycgi->param("context") : "",
       comments => (defined($mycgi->param("comments"))) ? $mycgi->param("comments") : "",
       sortby => (defined($mycgi->param("sortby"))) ? $mycgi->param("sortby") : "",
       version => (defined($mycgi->param("version"))) ? $mycgi->param("version") : "",
       extrtype => (defined($mycgi->param("extrtype"))) ? $mycgi->param("extrtype") : "",
       extrid => (defined($mycgi->param("extrid"))) ? $mycgi->param("extrid") : "",
       relationtype => (defined($mycgi->param("relationtype"))) ? $mycgi->param("relationtype") : 0,
       extrdate => (defined($mycgi->param("extrdate"))) ? $mycgi->param("extrdate") : 0,
       extruser => (defined($mycgi->param("extruser"))) ? $mycgi->param("extruser") : 0,
       extrkeyword => (defined($mycgi->param("extrkeyword"))) ? $mycgi->param("extrkeyword") : 0,
       extrcat => (defined($mycgi->param("extrcat"))) ? $mycgi->param("extrcat") : 0,
    ));
    my @categoryList = $mycgi->param("categories");
    $valueHash{categoryList} = \@categoryList;
    my @keywordList = $mycgi->param("keywords");
    $valueHash{keywordList} = \@keywordList;
    my @relateditems = $mycgi->param("relateditems");
    $valueHash{relateditems} = \@relateditems;
    $valueHash{title} = &getTitle(command => $valueHash{command});
    
    return (%valueHash);
}


###################################################################################################################################
sub doHeader {  # routine to generate html page headers
###################################################################################################################################
    my %args = (
        dbh => '',
        schema => $ENV{SCHEMA},
        title => "$SYSType Extraction Functions",
        displayTitle => 'T',
        useFileUpload => 'F',
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

    function submitFormDummy(script, command) {
        document.dummy$form.command.value = command;
        document.dummy$form.action = '$path' + script + '.pl';
        document.dummy$form.target = 'main';
        document.dummy$form.submit();
    }


    function submitFormHeader(script) {
        document.$form.command.value = 'header';
        document.$form.action = '$path' + script + '.pl';
        document.$form.target = 'header';
        document.$form.submit();
    }

    function submitFormStatus(script,username,userid) {
        document.$form.username.value = username;
        document.$form.userid.value = userid;
        document.$form.target = 'status';
        document.$form.action = '$path' + script + '.pl';
        document.$form.submit();
    }

       function displayExtractionVersion(id,ver) {
          var myDate = new Date();
          var winName = myDate.getTime();
          document.$form.id.value = id;
          document.$form.version.value = ver;
          document.$args{form}.action = '$path' + 'extractions.pl';
          document.$form.command.value = 'displayextractionversion';
          document.$form.target = winName;
          var newwin = window.open('',winName);
          newwin.creator = self;
          document.$form.submit();
       }


END_OF_BLOCK
#print STDERR "useFileUpload: $args{useFileUpload}\n";
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, useFileUpload=>$args{useFileUpload});
#              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, onSubmit => "return verify_$form(this)");
    
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
    my $form = $args{form};
    my $path = $args{path};
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $username = $settings{username};
    my $userid = $settings{userid};
    my $Server = $settings{server};
    my $schema = $settings{schema};
    my $sessionID = $settings{sessionID};
    my $extraHTML = "";
    
    $output .= "<br><br>\n</td></tr></table>\n";
    $extraHTML .= &doStartForm(schema => $schema, form => "dummy" . $form, sessionID => $sessionID, username => $username, userid => $userid, server => $Server);
    $extraHTML .= "</form>\n";
    
    $output .= &doStandardFooter(form => $form, extraHTML => $extraHTML);

    return($output);
}


###################################################################################################################################
sub doBrowse {  # routine to generate a table of extractions for browse
###################################################################################################################################
    my %args = (
        sortBy => 'sortid',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my @extr = &getExtractionArray(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$settings{extruser}, dates=>$settings{extrdate},
          keyword => $settings{extrkeyword}, category => $settings{extrcat});
    
    $output .= &doBrowseExtractionFilter(dbh=>$args{dbh}, schema=>$args{schema}, form=>$args{form}, buttonText=>"Refresh", settings => \%settings);
    $output .= "<hr width=30%>\n";
    $output .= "<input type=hidden name=sortby value='$args{sortBy}'>\n";
    $output .= "<table border=1 cellspaceing=0 align=center>";
    $output .= "<tr bgcolor=#a0e0c0><td align=center><b><a href=\"javascript:reSort('sortid');\">ID</a></b></td>";
    $output .= "<td align=center><b><a href=\"javascript:reSort('typeName');\">Type</a></b></td>\n";
    $output .= "<td align=center><b><a href=\"javascript:reSort('sorttext');\">Text</a></b> &nbsp; (Found $#extr)</td></tr>\n";
    my $sortField = ((defined($args{sortBy})) ? $args{sortBy} : "sortid");
    @extr = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @extr;
    my $rangeMod = ((defined($extr[0]{id})) ? 0 : 1);
    for (my $i=$rangeMod; $i<($#extr+$rangeMod); $i++) {
        $output .= "<tr bgcolor=#ffffff><td align=center><a href=\"javascript:browseItem('$extr[$i]{id}');\">$extr[$i]{id}</a></td>";
        $output .= "<td>$extr[$i]{typeName}</td>";
        $output .= "<td>$extr[$i]{shorttext2}</td></tr>\n";
    }
    $output .= "</table>\n";
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function browseItem (id) {
    var msg = '';
    $args{form}.id.value=id;
    if (msg != "") {
      alert (msg);
    } else {
        submitForm('$args{form}', 'displayextraction');
    }
}

function reSort (by) {
    $args{form}.sortby.value=by;
    submitForm('$args{form}', 'browse');
}

//--></script>

END_OF_BLOCK
    

    return($output);
}


###################################################################################################################################
sub doDisplayExtraction {  # routine to display an extraction
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my @extractionvalues;
    my ($id) = (0);
    $id = $settings{id};
    my %extrInfo = &getExtractionInfo(dbh => $args{dbh}, schema => $args{schema}, id => $id);
    my %docInfo = &getDocumentInfo(dbh => $args{dbh}, schema => $args{schema}, id => $extrInfo{sourcedoc});
    
    $output .= "<input type=hidden name=version value=0>\n";
    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td><b>From: </b></td><td><a href=\"javascript:browseDoc('$docInfo{id}');\">DOC" . &lpadzero($docInfo{id},6) . "</a> - $docInfo{title}</td></tr>\n";
    $output .= "<tr><td><b>$extrInfo{typeName}&nbsp;#: </b></td><td>$extrInfo{id}</td></tr>\n";
    $output .= "<tr><td><b>Location: </b></td><td>" . ((defined($extrInfo{location})) ? $extrInfo{location} : "") . "</td></tr>\n";
    my $temp = $extrInfo{versions}[$extrInfo{currentVersion}]{text};
    $temp =~ s/\n/<br>/g;
    $temp =~ s/  / &nbsp;/g;
    $output .= "<tr><td valign=top><b>Text:</b> </td><td valign=top>" . $temp . "</td></tr>\n";
    $temp = ((defined($extrInfo{versions}[$extrInfo{currentVersion}]{context})) ? $extrInfo{versions}[$extrInfo{currentVersion}]{context} : " ");
    $temp =~ s/\n/<br>/g;
    $temp =~ s/  / &nbsp;/g;
    $output .= "<tr><td valign=top><b>Context:</b> </td><td valign=top>" . $temp . "</td></tr>\n";
    
    my %verInfo = &getExtrVersionInfo(dbh => $args{dbh}, schema => $args{schema}, id => $id, version => $extrInfo{currentVersion});
    $output .= "<tr><td valign=top><b>Keywords:</b> </td><td valign=top>";
    for (my $i=0; $i<$verInfo{keywordCount}; $i++) {
        $output .= (($i>0) ? ", " : "") . $verInfo{keywords}[$i]{keywordName};
    }
    $output .= "</td></tr>\n";
    $output .= "<tr><td valign=top><b>Categories:</b> </td><td valign=top>";
    for (my $i=0; $i<$verInfo{categoryCount}; $i++) {
        $output .= $verInfo{categories}[$i]{categoryName} . ((($i+1) < $verInfo{categoryCount}) ? "<br>" : "");
    }
    $output .= "</td></tr>\n";
    
    my @rItems;
    if($extrInfo{type} == 1) {
        @rItems = &getExtractionArray(dbh=>$args{dbh}, schema=>$args{schema}, linkedFrom=>$id, linkType=>2, type=>2);
    } else {
        @rItems = &getExtractionArray(dbh=>$args{dbh}, schema=>$args{schema}, linkedTo=>$id, linkType=>2, type=>1);
    }
    $output .= "<tr><td colspan=2><b>Related " . ('','Response','Comment')[$extrInfo{type}] . (($#rItems != 1) ? "s" : "") . "</b></td></tr>\n";
    $output .= "<tr><td>&nbsp;</td><td>";
    if ($#rItems == 0) {
        $output .= "None\n";
    } else {
        for (my $i=0; $i<$#rItems; $i++) {
            my %extrInfo2 = &getExtractionInfo(dbh => $args{dbh}, schema => $args{schema}, id => $rItems[$i]{id});
            my $temp = $extrInfo2{versions}[$extrInfo2{currentVersion}]{shorttext2};
            $temp =~ s/\n/<br>/g;
            $temp =~ s/  / &nbsp;/g;
            $output .= "<a href=\"javascript:browseItem('$rItems[$i]{id}');\">DOC" . &lpadzero($rItems[$i]{sourcedoc},6) . " - $rItems[$i]{id}</a><br>\n";
            $output .= "$temp<br>\n";
        }
    }
    $output .= "</td></tr>\n";
    if ($docInfo{currentVersion} > 1) {
        # past versions
    }
    $output .= "</table>\n";
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
        submitForm('$args{form}', 'displayextraction');
    }
}

//--></script>

END_OF_BLOCK
    
    

    return($output);
}


###################################################################################################################################
sub doUpdateExtractionSelect {  # routine to generate a select box of extractions for update
###################################################################################################################################
    my %args = (
        sortBy => 'sortid',
        docID => 0,
        type => 0,
        @_,
    );
    my $output = "";
    my @extr = &getExtractionArray(dbh=>$args{dbh}, schema=>$args{schema}, docID=>$args{docID}, type=>$args{type});
    
    $output .= "<input type=hidden name=sortby value='$args{sortBy}'>\n";
    $output .= "<table border=1 cellspaceing=0 align=center>";
    $output .= "<tr bgcolor=#a0e0c0><td align=center><b><a href=\"javascript:reSort('sortid');\">ID</a></b></td>";
    $output .= "<td align=center><b><a href=\"javascript:reSort('typeName');\">Type</a></b></td>\n";
    $output .= "<td align=center><b><a href=\"javascript:reSort('sorttext');\">Text</a></b></td></tr>\n";
    my $sortField = ((defined($args{sortBy})) ? $args{sortBy} : "sortid");
    @extr = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @extr;
    my $rangeMod = ((defined($extr[0]{id})) ? 0 : 1);
    for (my $i=$rangeMod; $i<($#extr+$rangeMod); $i++) {
        $output .= "<tr bgcolor=#ffffff><td align=center><a href=\"javascript:updateItem('$extr[$i]{id}');\">$extr[$i]{id}</a></td>";
        $output .= "<td>$extr[$i]{typeName}</td>";
        $output .= "<td>$extr[$i]{shorttext2}</td></tr>\n";
    }
    $output .= "</table>\n";
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function updateItem (id) {
    var msg = '';
    $args{form}.id.value=id;
    submitForm('$args{form}', 'updateextractionform');
}

function reSort (by) {
    $args{form}.sortby.value=by;
    submitForm('$args{form}', 'browse');
}

//--></script>

END_OF_BLOCK
    

    return($output);
}


###################################################################################################################################
sub doExtractionEntryForm {  # routine to generate a extraction data entry/update form
###################################################################################################################################
    my %args = (
        type => 'new',
        docID => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %extractionInfo = (
        id => 0,
        sourcedoc => 0,
        type => $settings{extrtype},
        location => "",
    );
    my %extrVersionInfo = (
        id => 0,
        version => 0,
        datesaved => "",
        savedby => 0,
        text => "",
        context => "",
    );
    my $id = 0;
    my $docID = $settings{id};
    if ($args{type} eq 'update') {
        $id = $settings{id};
        %extractionInfo = &getExtractionInfo(dbh => $args{dbh}, schema => $args{schema}, id => $id);
        $docID = $extractionInfo{sourcedoc};
        %extrVersionInfo = &getExtrVersionInfo(dbh => $args{dbh}, schema => $args{schema}, id => $id);
    }
    my %docInfo = &getDocumentInfo(dbh => $args{dbh}, schema => $args{schema}, id => $docID);
    my @eTypes = &getExtractionTypes(dbh => $args{dbh}, schema => $args{schema});

    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td colspan=4 align=center><table border=0 width=650>\n";
    $output .= "<input type=hidden name=documentid value=$docInfo{id}>\n";
    $output .= "<input type=hidden name=type value=$extractionInfo{type}>\n";
    $output .= "<input type=hidden name=extrid value=$extractionInfo{id}>\n";
    $output .= "<tr><td><b>From: </b>&nbsp</td><td>DOC" . &lpadzero($docInfo{id},6) . " - $docInfo{title}</td></tr>\n";
    $output .= "<tr><td><b>$eTypes[$extractionInfo{type}] #: </b>&nbsp</td><td>" . (($id > 0) ? $id : "'New'") . "</td></tr>\n";
    $output .= "<tr><td valign=top><b>Location/Page: </b>&nbsp</td><td><textarea name=location cols=75 rows=4>";
    $output .= ((defined($extractionInfo{location})) ? $extractionInfo{location} : "") . "</textarea></td></tr>\n";

    $output .= "<tr><td colspan=2><hr></td></tr>\n";
    
    $output .= "<tr><td valign=top><b>Text: </b>&nbsp</td><td><textarea name=text cols=75 rows=4>" . ((defined($extrVersionInfo{text})) ? $extrVersionInfo{text} : "") . "</textarea></td></tr>\n";
    $output .= "<tr><td valign=top><b>Context: </b>&nbsp</td><td><textarea name=context cols=75 rows=4>" . ((defined($extrVersionInfo{context})) ? $extrVersionInfo{context} : "") . "</textarea></td></tr>\n";

    $output .= "<tr><td colspan=2><hr></td></tr>\n";
    
    tie my %cats, "Tie::IxHash";
    %cats = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, table=>'categories', idColumn=>'id', nameColumn=>'text', orderBy=>'text')};
    tie my %currcats, "Tie::IxHash";
    %currcats = (($args{type} ne 'new') ? %{&getExtractionCategories (dbh => $args{dbh}, schema => $args{schema}, id=>$extractionInfo{id})} : ());
    $output .= "<tr><td valign=top><b>Categories: </b></td><td>\n";
    $output .= build_dual_select_vertical ('categories', "$args{form}", \%cats, \%currcats, "<b>Available Categories</b>", "<b>Selected Categories</b>", 0);
    #$output .= &buildDualSelect (elementName=>'categories', form=>"$args{form}", available=>\%cats, selected=>\%currcats, 
    #      leftName=>"<b>Available Categories</b>", rightName=>"<b>Selected Categories</b>", isVertical=>'T');
    $output .= "</td></tr>\n";
    
    tie my %keywords, "Tie::IxHash";
    %keywords = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, table=>'keywords', idColumn=>'id', nameColumn=>'text', orderBy=>'text')};
    tie my %currkeywords, "Tie::IxHash";
    %currkeywords = (($args{type} ne 'new') ? %{&getExtractionKeywords (dbh => $args{dbh}, schema => $args{schema}, id=>$extractionInfo{id})} : ());
    $output .= "<tr><td valign=top><b>Keywords: </b></td><td>\n";
    $output .= build_dual_select ('keywords', "$args{form}", \%keywords, \%currkeywords, "<b>Available Keywords</b>", "<b>Selected Keywords</b>", 0);
    #$output .= &buildDualSelect (elementName=>'keywords', form=>$args{form}, available=>\%keywords, selected=>\%currkeywords,
    #      leftName=>"<b>Available Keywords</b>", rightName=>"<b>Selected Keywords</b>", isVertical=>"F");
    $output .= "</td></tr>\n";

    $output .= "<tr><td colspan=2><hr></td></tr>\n";
    
    tie my %extrs, "Tie::IxHash";
    %extrs = %{&getExtractionHash (dbh => $args{dbh}, schema => $args{schema}, type=> (($extractionInfo{type} == 1) ? 2 : 1))};
    tie my %currextrs, "Tie::IxHash";
    %currextrs = %{&getExtractionHash (dbh => $args{dbh}, schema => $args{schema}, id=>$extractionInfo{id}, type=> (($extractionInfo{type} == 1) ? 2 : 1), selected => 'T')};
    my $extrType = (($extractionInfo{type} == 2) ? "Comments" : "Responses");
    $output .= "<input type=hidden name=relationtype value=2>\n";
    $output .= "<tr><td valign=top><b>Related $extrType</b></td><td>\n";
    $output .= build_dual_select_vertical ('relateditems', "$args{form}", \%extrs, \%currextrs, "<b>Available $extrType</b>", "<b>Selected $extrType</b>", 0);
    $output .= "</td></tr>\n";
    $output .= "</td></tr>\n";
    
    $output .= "</table></td></tr>\n";
    $output .= "<tr><td colspan=4 align=center><br><input type=button name=submitbutton value=\"Submit $eTypes[$extractionInfo{type}] Information\" onClick=\"verifySubmit(document.$args{form})\"> &nbsp;\n";
    $output .= "</table>\n";
    
    my $nextCommand = (($args{type} eq 'new') ? "addextraction" : "updateextraction");
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    if (!isblank(f.location.value) && f.location.value.length > 500) {
      msg += "Location/Page must be less than 500 Characters\\n";
    }
    if (isblank(f.text.value)) {
      msg += "Text must be entered.\\n";
    }
    for (index=0; index < f.categories.length-1;index++) {
        f.categories.options[index].selected = true;
    }
    for (index=0; index < f.keywords.length-1;index++) {
        f.keywords.options[index].selected = true;
    }
    for (index=0; index < f.relateditems.length-1;index++) {
        f.relateditems.options[index].selected = true;
    }
    if (msg != "") {
      alert (msg);
    } else {
      submitFormCGIResults('$args{form}', '$nextCommand');
    }
}
//--></script>

END_OF_BLOCK

    return($output);
}


###################################################################################################################################
sub doExtractionEntry {  # routine to get extraction entry/update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my ($status, $id) = &doProcessExtractionEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, settings => \%settings);

    #$message = "Extraction '$id' has been " . (($args{type} eq 'new') ? "added" : "updated");
    #$output .= doAlertBox(text => "$message");
    if ($args{type} eq 'new') {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "extraction $id inserted", type => 10);
    } else {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "extraction $id updated", type => 11);
    }
    $output .= "<script language=javascript><!--\n";
    $output .= "   document.$args{form}.id.value=$settings{documentid};\n";
    if ($args{type} eq 'new') {
        $output .= "   submitForm('documents','updatedocumentselect');\n";
    } else {
        $output .= "   submitForm('$args{form}','updateextractionselect');\n";
    }
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doDisplayExtractionVersion {  # routine to display a extraction version
###################################################################################################################################
    my %args = (
        id => 0,
        version => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %docVer = &getDocVersionInfo(dbh => $args{dbh}, schema => $args{schema}, id=> $args{id}, version=>$args{version});
    my $mimeType = &getMimeType(dbh => $args{dbh}, schema => $args{schema}, name=>$docVer{filename});

    $output .= "Content-type: $mimeType\n\n";
    #$output .= "Content-type: text\n\n";
    $output .= $docVer{sourcefile};

    return($output);
}


###################################################################################################################################
sub doBrowseExtractionFilter {  # routine to create the filter for extraction browsing
###################################################################################################################################
    my %args = (
        buttonText => "Browse Extractions",
        title => '',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    
    $output = "<table border=1 cellpadding=5 cellspacing=0 align=center><tr bgcolor=#ffffff><td align=center>";
    if ($args{title} gt ' ') {
        $output .= "<b>$args{title}</b>\n";
    }
    $output .= "<table border=0><tr>";
    $output .= "<td align=center>Entered/Modified&nbsp;Dates<br>\n";
    $output .= "<select name=extrdate size=1>\n";
    $output .= "<option value=0" . (($settings{extrdate} eq "0") ? " selected" : "") . ">All</option>\n";
    $output .= "<option value=1" . (($settings{extrdate} eq "1") ? " selected" : "") . ">Past Three Months</option>\n";
    $output .= "<option value=2" . (($settings{extrdate} eq "2") ? " selected" : "") . ">Past Six Months</option>\n";
    $output .= "<option value=3" . (($settings{extrdate} eq "3") ? " selected" : "") . ">Past Year</option>\n";
    $output .= "</select></td><td> &nbsp; </td>";
    $output .= "<td align=center>Entered/Modified&nbsp;By<br>\n";
    my @users = &getUserArray(dbh=>$args{dbh}, schema=>$args{schema}, enteredExtraction => 'T');
    $output .= "<select name=extruser size=1>\n";
    $output .= "<option value=0" . (($settings{extruser} == 0) ? " selected" : "") . ">Any User</option>\n";
    for (my $i=0; $i<$#users; $i++) {
        $output .= "<option value=$users[$i]{id}" . (($settings{extruser} == $users[$i]{id}) ? " selected" : "") . ">$users[$i]{lastname}, $users[$i]{firstname}</option>\n";
    }
    $output .= "</select><td> &nbsp; </td>";
    $output .= "<td align=center>Keyword<br>\n";
    my @keywords = &getLookupArray (dbh => $args{dbh}, schema => $args{schema}, table=>'keywords', idColumn=>'id', nameColumn=>'text', orderBy=>'text');
    $output .= "<select name=extrkeyword size=1>\n";
    $output .= "<option value=0" . (($settings{extrkeyword} == 0) ? " selected" : "") . ">None</option>\n";
    for (my $i=0; $i<$#keywords; $i++) {
        $output .= "<option value=$keywords[$i]{id}" . (($settings{extrkeyword} == $keywords[$i]{id}) ? " selected" : "") . ">$keywords[$i]{value}</option>\n";
    }
    $output .= "</select><td> &nbsp; </td>";
    $output .= "</tr><tr>\n";
    $output .= "<td colspan=5 align=center>Category<br>\n";
    my @cats = &getLookupArray (dbh => $args{dbh}, schema => $args{schema}, table=>'categories', idColumn=>'id', nameColumn=>'text', orderBy=>'text');
    $output .= "<select name=extrcat size=1>\n";
    $output .= "<option value=0" . (($settings{extrcat} == 0) ? " selected" : "") . ">None</option>\n";
    for (my $i=0; $i<$#cats; $i++) {
        $output .= "<option value=$cats[$i]{id}" . (($settings{extrcat} == $cats[$i]{id}) ? " selected" : "") . ">" . &getDisplayString($cats[$i]{value}, 80) . "</option>\n";
    }
    $output .= "</select><td> &nbsp; </td>";
    $output .= "<td valign=bottom><input type=button value='$args{buttonText}' onClick=\"submitForm('extractions', 'browse');\"></td></tr></table>\n";
    $output .= "</td></tr></table>\n";

    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
