# UI Document functions
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/UIDocuments.pm,v $
#
# $Revision: 1.2 $
#
# $Date: 2004/11/16 19:37:47 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: UIDocuments.pm,v $
# Revision 1.2  2004/11/16 19:37:47  atchleyb
# added new browse filters
#
# Revision 1.1  2004/07/27 18:27:16  atchleyb
# Initial revision
#
#
#
#
#

package UIDocuments;
#
# get all required libraries and modules
use strict;
use SharedHeader qw(:Constants);
use CGI;
use DBDocuments qw(:Functions);
use UI_Widgets qw(:Functions);
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use Sessions qw(:Functions);
use DBExtractions qw(getExtractionArray);
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
      &doBrowse               &doDisplayDocument        &doDisplayDocumentVersion
      &getInitialValues       &doHeader                 &doUpdateDocumentSelect
      &doFooter               &getTitle                 &doDocumentEntryForm
      &doDocumentEntry        &doBrowseDocumentFilter
    );
%EXPORT_TAGS =( 
    Functions => [qw(
      &doBrowse               &doDisplayDocument        &doDisplayDocumentVersion
      &getInitialValues       &doHeader                 &doUpdateDocumentSelect
      &doFooter               &getTitle                 &doDocumentEntryForm
      &doDocumentEntry        &doBrowseDocumentFilter
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
   if (($args{command} eq "adddocument") || ($args{command} eq "adddocumentform")) {
      $title = "Add Document";
   } elsif (($args{command} eq "updatedocument") || ($args{command} eq "updatedocumentform") || ($args{command} eq "updatedocumentselect")) {
      $title = "Update Document";
   } elsif (($args{command} eq "browse") || (($args{command} eq "displaydocument")) || ($args{command} eq "displaydocumentform")) {
      $title = "Browse Document";
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
       doctitle => (defined($mycgi->param("doctitle"))) ? $mycgi->param("doctitle") : "",
       source => (defined($mycgi->param("source"))) ? $mycgi->param("source") : "",
       type => (defined($mycgi->param("type"))) ? $mycgi->param("type") : 0,
       url => (defined($mycgi->param("url"))) ? $mycgi->param("url") : "",
       sourcedate => (defined($mycgi->param("sourcedate"))) ? $mycgi->param("sourcedate") : "",
       sourceversion => (defined($mycgi->param("sourceversion"))) ? $mycgi->param("sourceversion") : "",
       description => (defined($mycgi->param("description"))) ? $mycgi->param("description") : "",
       sourcefile => (defined($mycgi->param("sourcefile"))) ? $mycgi->param("sourcefile") : "",
       translation => (defined($mycgi->param("translation"))) ? $mycgi->param("translation") : "",
       comments => (defined($mycgi->param("comments"))) ? $mycgi->param("comments") : "",
       sortby => (defined($mycgi->param("sortby"))) ? $mycgi->param("sortby") : "",
       version => (defined($mycgi->param("version"))) ? $mycgi->param("version") : "",
       docdate => (defined($mycgi->param("docdate"))) ? $mycgi->param("docdate") : "0",
       docuser => (defined($mycgi->param("docuser"))) ? $mycgi->param("docuser") : "0",
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
        title => "$SYSType Document Functions",
        displayTitle => 'T',
        includeJSCalendar => 'F',
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

       function displayDocumentVersion(id,ver) {
          var myDate = new Date();
          var winName = myDate.getTime();
          document.$form.id.value = id;
          document.$form.version.value = ver;
          document.$args{form}.action = '$path' + 'documents.pl';
          document.$form.command.value = 'displaydocumentversion';
          document.$form.target = winName;
          var newwin = window.open('',winName);
          newwin.creator = self;
          document.$form.submit();
       }


END_OF_BLOCK
#print STDERR "useFileUpload: $args{useFileUpload}\n";
    $output .= &doStandardHeader(dbh => $args{dbh}, schema => $args{schema}, title => $args{title}, displayTitle => $args{displayTitle}, 
              settings => \%settings, form => $form, path => $path, extraJS => $extraJS, includeJSCalendar=>$args{includeJSCalendar}, 
              useFileUpload=>$args{useFileUpload});
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
sub doBrowse {  # routine to generate a table of documents for browse
###################################################################################################################################
    my %args = (
        sortBy => 'sortid',
        userID => 0,
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my @docs = &getDocumentArray(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$settings{docuser}, dates=>$settings{docdate});
    
    $output .= &doBrowseDocumentFilter(dbh=>$args{dbh}, schema=>$args{schema}, form=>$args{form}, buttonText=>"Refresh", settings => \%settings);
    $output .= "<hr width=30%>\n";
    $output .= "<input type=hidden name=sortby value='$args{sortBy}'>\n";
    $output .= "<table border=1 cellspacing=0 align=center>";
    $output .= "<tr bgcolor=#a0e0c0><td align=center><b><a href=\"javascript:reSort('sortid');\">ID</a></b></td>";
    $output .= "<td align=center><b><a href=\"javascript:reSort('sorttitle');\">Title</a></b> &nbsp; (Found $#docs)</td></tr>\n";
    my $sortField = ((defined($args{sortBy})) ? $args{sortBy} : "sortid");
    @docs = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @docs;
    my $rangeMod = ((defined($docs[0]{id})) ? 0 : 1);
    for (my $i=$rangeMod; $i<($#docs+$rangeMod); $i++) {
        $output .= "<tr bgcolor=#ffffff><td align=center><a href=\"javascript:browseDoc('$docs[$i]{id}');\">DOC" . &lpadzero($docs[$i]{id},6) . "</a></td>";
        $output .= "<td>$docs[$i]{title}</td></tr>\n";
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
        submitForm('$args{form}', 'displaydocument');
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
sub doDisplayDocument {  # routine to display a document
###################################################################################################################################
    my %args = (
        @_,
    );
    my $output = "";
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my @documentvalues;
    my ($id) = (0);
    $id = $settings{id};
    my %docInfo = &getDocumentInfo(dbh => $args{dbh}, schema => $args{schema}, id => $id);
    
    $output .= "<input type=hidden name=version value=0>\n";
    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td><b>ID: </b></td><td>DOC" . &lpadzero($docInfo{id},6) . "</td></tr>\n";
    $output .= "<tr><td><b>Title: </b></td><td>$docInfo{title}</td></tr>\n";
    $output .= "<tr><td><b>Source: </b></td><td>" . ((defined($docInfo{title})) ? $docInfo{title} : "") . "</td></tr>\n";
    $output .= "<tr><td><b>Type: </b></td><td>$docInfo{typeName}</td></tr>\n";
    $output .= "<tr><td><b>URL: </b></td><td>" . ((defined($docInfo{url})) ? "<a href=$docInfo{url} target=_blank>$docInfo{url}</a>" : "") . "</td></tr>\n";
    $output .= "<tr><td><b>Description: </b></td><td>" . ((defined($docInfo{description})) ? $docInfo{description} : "") . "</td></tr>\n";
    $output .= "<tr><td><b>CName: </b></td><td>" . ((defined($docInfo{cname})) ? $docInfo{cname} : "") . "</td></tr>\n";
    $output .= "<tr><td colspan=2><hr></td></tr>\n";
    $output .= "<tr><td><b>Current Version:</b> </td><td>" . $docInfo{currentVersion} . "</td></tr>\n";
    $output .= "<tr><td><b>Source Version:</b> </td><td>" . $docInfo{versions}[$docInfo{currentVersion}]{sourceversion} . "</td></tr>\n";
    $output .= "<tr><td><b>Source Date:</b> </td><td>" . $docInfo{versions}[$docInfo{currentVersion}]{sourcedate} . "</td></tr>\n";
    $output .= "<tr><td><b>Date Entered:</b> </td><td>" . $docInfo{versions}[$docInfo{currentVersion}]{dateentered} . "</td></tr>\n";
    $output .= "<tr><td><b>Entered By:</b> </td><td>" . &getFullName(dbh=>$args{dbh},schema=>$args{schema}, userID=>$docInfo{versions}[$docInfo{currentVersion}]{enteredby}) . "</td></tr>\n";
    $output .= "<tr><td><b>Source File:</b> </td><td><a href=javascript:displayDocumentVersion($id,$docInfo{currentVersion})>$docInfo{versions}[$docInfo{currentVersion}]{filename}</a></td></tr>\n";
    my $temp = $docInfo{versions}[$docInfo{currentVersion}]{translation};
    $temp =~ s/\n/<br>/g;
    $temp =~ s/  / &nbsp;/g;
    if (defined($temp) && $temp gt '   ') {
        $temp = buildSectionBlock(title=>"Full Text", contents=>$temp, isOpen=>'F');
    }
    $output .= "<tr><td valign=top><b>Translation:</b> </td><td>" . $temp . "</td></tr>\n";
    $temp = ((defined($docInfo{versions}[$docInfo{currentVersion}]{comments})) ? $docInfo{versions}[$docInfo{currentVersion}]{comments} : "  ");
    $temp =~ s/\n/<br>/g;
    $temp =~ s/  / &nbsp;/g;
    $output .= "<tr><td><b>Remarks:</b> " . $temp . "</td></tr>\n";
    if ($docInfo{currentVersion} > 1) {
        # past versions
    }

    $output .= "<tr><td colspan=2><hr></td></tr>\n";
    
    
    # comments
    my $sText = '';
    my @items = &getExtractionArray(dbh=>$args{dbh}, schema=>$args{schema}, docID=>$id, type=>1);
    $output .= "<tr><td colspan=2>";
    $sText .= "<table border=1 size=100% cellpadding=2 cellspacing=0>\n";
    #$sText .= "<tr bgcolor=#a0e0c0><td colspan=3><b>Extracted Comments</b> (Count: $#items)</td></tr>\n";
    $sText .= "<tr bgcolor=#bfffdf><td width=50%><b>Comment</b></td><td width=50%><b>Linked&nbsp;Responses</b></td></tr>\n";
    for (my $i=0; $i<$#items; $i++) {
        my $temp = $items[$i]{text};
        $temp =~ s/\n/<br>/g;
        $temp =~ s/  / &nbsp;/g;
        $sText .= "<tr bgcolor=#ffffff><td valign=top><a href=\"javascript:browseItem('$items[$i]{id}');\">$items[$i]{id}</a>: $temp</td><td valign=top>";
        my @rItems = &getExtractionArray(dbh=>$args{dbh}, schema=>$args{schema}, linkedFrom=>$items[$i]{id}, linkType=>2, type=>2);
        for (my $j=0; $j<$#rItems; $j++) {
            my $temp = $rItems[$j]{text};
            $temp =~ s/\n/<br>/g;
            $temp =~ s/  / &nbsp;/g;
            $sText .= (($j>0) ? "<br>" : "");
            $sText .= "DOC" . &lpadzero($rItems[$j]{sourcedoc},6) . " : <a href=\"javascript:browseItem('$rItems[$j]{id}');\">$rItems[$j]{id}</a>: $temp";
        }
        $sText .= "&nbsp;</td></tr>\n";
    }
    $sText .= "</table>";
    $output .= &buildSectionBlock(title=>"<b>Extracted Comments</b> (Count: $#items)", contents=>$sText, isOpen=>'T');
    $output .= "</td></tr>\n";
    
    # responses
    $sText = '';
    @items = &getExtractionArray(dbh=>$args{dbh}, schema=>$args{schema}, docID=>$id, type=>2);
    $output .= "<tr><td colspan=2>";
    $sText .= "<table border=1 size=100% cellpadding=2 cellspacing=0>\n";
    #$sText .= "<tr bgcolor=#a0e0c0><td colspan=3><b>Extracted Responses</b> (Count: $#items)</td></tr>\n";
    $sText .= "<tr bgcolor=#bfffdf><td width=50%><b>Response</b></td><td width=50%><b>Linked&nbsp;Comments</b></td></tr>\n";
    for (my $i=0; $i<$#items; $i++) {
        my $temp = $items[$i]{text};
        $temp =~ s/\n/<br>/g;
        $temp =~ s/  / &nbsp;/g;
        $sText .= "<tr bgcolor=#ffffff><td valign=top><a href=\"javascript:browseItem('$items[$i]{id}');\">$items[$i]{id}</a>: $temp</td><td valign=top>";
        my @rItems = &getExtractionArray(dbh=>$args{dbh}, schema=>$args{schema}, linkedTo=>$items[$i]{id}, linkType=>2, type=>1);
        for (my $j=0; $j<$#rItems; $j++) {
            my $temp = $rItems[$j]{text};
            $temp =~ s/\n/<br>/g;
            $temp =~ s/  / &nbsp;/g;
            $sText .= (($j>0) ? "<br>" : "");
            $sText .= "DOC" . &lpadzero($rItems[$j]{sourcedoc},6) . " : <a href=\"javascript:browseItem('$rItems[$j]{id}');\">$rItems[$j]{id}</a>: $temp";
        }
        $sText .= "&nbsp;</td></tr>\n";
    }
    $sText .= "</table>";
    $output .= &buildSectionBlock(title=>"<b>Extracted Responses</b> (Count: $#items)", contents=>$sText, isOpen=>'T');
    $output .= "</td></tr>\n";
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

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
sub doUpdateDocumentSelect {  # routine to generate a select box of documents for update
###################################################################################################################################
    my %args = (
        sortBy => 'sortid',
        userID => 0,
        @_,
    );
    my $output = "";
    my @docs = &getDocumentArray(dbh=>$args{dbh}, schema=>$args{schema}, userID=>$args{userID});
    
    $output .= "<input type=hidden name=sortby value='$args{sortBy}'>\n";
    $output .= "<input type=hidden name=extrtype value=0>\n";
    $output .= "<input type=hidden name=extrid value=0>\n";
    $output .= "<table border=1 cellspaceing=0 align=center>";
    $output .= "<tr bgcolor=#a0e0c0><td align=center><b><a href=\"javascript:reSort('sortid');\">ID</a></b></td>";
    $output .= "<td align=center><b><a href=\"javascript:reSort('sorttitle');\">Title</a></b></td>";
    $output .= "<td align=center><b>Comments</b></td><td align=center><b>Responses</b></td></tr>\n";
    my $sortField = ((defined($args{sortBy})) ? $args{sortBy} : "sortid");
    @docs = sort { ((defined($a->{$sortField})) ? $a->{$sortField} : "") cmp ((defined($b->{$sortField})) ? $b->{$sortField} : "") } @docs;
    my $rangeMod = ((defined($docs[0]{id})) ? 0 : 1);
    for (my $i=$rangeMod; $i<($#docs+$rangeMod); $i++) {
        $output .= "<tr bgcolor=#ffffff><td align=center><a href=\"javascript:updateDoc('$docs[$i]{id}');\">DOC" . &lpadzero($docs[$i]{id},6) . "</a></td>";
        $output .= "<td>$docs[$i]{title}</td>";
        $output .= "<td align=center><a href=\"javascript:addComment('$docs[$i]{id}');\">add</a>/";
        $output .= "<a href=\"javascript:updateComment('$docs[$i]{id}');\">edit</a></td>";
        $output .= "<td align=center><a href=\"javascript:addResponse('$docs[$i]{id}');\">add</a>/";
        $output .= "<a href=\"javascript:updateResponse('$docs[$i]{id}');\">edit</a></td>";
        $output .= "</tr>\n";
    }
    $output .= "</table>\n";
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function updateDoc (id) {
    var msg = '';
    $args{form}.id.value=id;
    if (msg != "") {
      alert (msg);
    } else {
        submitForm('$args{form}', 'updatedocumentform');
    }
}

function addComment (id) {
    var msg = '';
    $args{form}.id.value=id;
    $args{form}.extrtype.value=1;
    submitForm('extractions', 'addextractionform');
}

function updateComment (id) {
    var msg = '';
    $args{form}.id.value=id;
    $args{form}.extrtype.value=1;
    submitForm('extractions', 'updateextractionselect');
}

function addResponse (id) {
    var msg = '';
    $args{form}.id.value=id;
    $args{form}.extrtype.value=2;
    submitForm('extractions', 'addextractionform');
}

function updateResponse (id) {
    var msg = '';
    $args{form}.id.value=id;
    $args{form}.extrtype.value=2;
    submitForm('extractions', 'updateextractionselect');
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
sub doDocumentEntryForm {  # routine to generate a document data entry/update form
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my %documentInfo = (
        id => 0,
        title => "",
        source => "",
        type => 0,
        url => "",
        description => "",
        cname => "",
        comments => "",
    );
    my %docVersionInfo = (
        documentid => 0,
        version => 0,
        dateentered => "",
        enteredby => 0,
        filename => "",
        sourcedate => "",
        sourceversion => "",
        translation => "",
        comments => "",
    );
    my $id = 0;
    if ($args{type} eq 'update') {
        $id = $settings{id};
        %documentInfo = &getDocumentInfo(dbh => $args{dbh}, schema => $args{schema}, id => $id);
        %docVersionInfo = &getDocVersionInfo(dbh => $args{dbh}, schema => $args{schema}, id => $id);
    }

    $output .= "<table border=0 align=center>\n";
    $output .= "<tr><td colspan=4 align=center><table border=0 width=650>\n";
    $output .= "<input type=hidden name=documentid value=$documentInfo{id}>\n";
    $output .= "<tr><td><b>ID: </b>&nbsp;</td><td>" . (($args{type} eq 'new') ? "New" : "DOC" . &lpadzero($documentInfo{id},6)) . "</td></tr>\n";;
    $output .= "<tr><td><b>Title: </b>&nbsp;</td><td><input type=text name=doctitle value=\"$documentInfo{title}\" maxlength=200 size=100></td></tr>\n";
    $output .= "<tr><td><b>Source: </b>&nbsp;</td><td><input type=text name=source value=\"$documentInfo{source}\" maxlength=200 size=100></td></tr>\n";
    $output .= "<tr><td><b>Type: </b>&nbsp;</td><td><select size=1 name=type><option value=0></option>\n";
    my %dtypes = %{&getLookupValues (dbh => $args{dbh}, schema => $args{schema}, table => 'document_type', idColumn => 'id', nameColumn => 'label')};
    my $key;
    foreach $key (sort keys %dtypes) {
        my $selected = ($documentInfo{type} == $key) ? " selected" : "";
        $output .= "<option value=\"$key\"$selected>$dtypes{$key}\n";
    }
    $output .= "</select></td></tr>\n";
    $output .= "<tr><td><b>URL: </b>&nbsp;</td><td><input type=text name=url value=\"" . ((defined($documentInfo{url})) ? $documentInfo{url} : "") . "\" maxlength=256 size=100></td></tr>\n";
    $output .= "<tr><td valign=top><b>Description: </b>&nbsp;</td><td><textarea name=description cols=75 rows=4>" . ((defined($documentInfo{description})) ? $documentInfo{description} : "") . "</textarea></td></tr>\n";
    $output .= "<tr><td colspan=2><hr></td></tr>\n";
    
    $output .= "<tr><td valign=top><b>File: </b>&nbsp</td><td>";
    if ($args{type} eq 'update') {
        $output .= "$docVersionInfo{filename}<br>";
    }
    $output .= "<input type=file name=sourcefile size=80></td></tr>\n";
    $output .= "<tr><td valign=top><b>Document Date: </b>&nbsp;</td><td colspan=3>";
    $output .= "<input type=text name=sourcedate value=\"" . ((defined($docVersionInfo{sourcedate})) ? $docVersionInfo{sourcedate} : "") . "\" maxlength=10 size=10 onfocus=\"this.blur(); showCal('calsourcedate')\">";
    $output .= "<span id=\"sourcedateid\" style=\"position:relative;\">&nbsp;</span></td></tr>\n";
    $output .= "<tr><td valign=top><b>Document Version: </b>&nbsp;</td><td colspan=3><input type=text name=sourceversion value=\"" . ((defined($docVersionInfo{sourceversion})) ? $docVersionInfo{sourceversion} : "") . "\" maxlength=30 size=15></td></tr>\n";
    $output .= "<tr><td valign=top><b>Translation: </b>&nbsp;</td><td><textarea name=translation cols=75 rows=4>" . ((defined($docVersionInfo{translation})) ? $docVersionInfo{translation} : "") . "</textarea></td></tr>\n";
    $output .= "<tr><td valign=top><b>Remarks: </b>&nbsp;</td><td><textarea name=comments cols=75 rows=4>" . ((defined($docVersionInfo{comments})) ? $docVersionInfo{comments} : "") . "</textarea></td></tr>\n";
    $output .= "</table></td></tr>\n";
    $output .= "<tr><td colspan=4 align=center><br><input type=button name=submitbutton value=\"Submit Document Information\" onClick=\"verifySubmit(document.$args{form})\"> &nbsp;\n";
    $output .= "</table>\n";
    
    my $nextCommand = (($args{type} eq 'new') ? "adddocument" : "updatedocument");
    $output .= <<END_OF_BLOCK;

<script language=javascript><!--

function verifySubmit (f){
// javascript form verification routine
    var msg = "";
    if (isblank(f.doctitle.value)) {
      msg += "Title must be entered.\\n";
    }
    if (f.type.options[0].selected) {
        msg += "Doument Type must be selected \\n";
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
sub doDocumentEntry {  # routine to get document entry/update data
###################################################################################################################################
    my %args = (
        type => 'new',
        @_,
    );
    my $hashRef = $args{settings};
    my %settings = %$hashRef;
    my $output = "";
    my $message = "";
    
    my ($name, $fileContents) = &getFile(fileParam=>'sourcefile');
    my ($status, $id) = &doProcessDocumentEntry(dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, 
          type => $args{type}, fileName=>$name, fileContents=>$fileContents, settings => \%settings);

    #$message = "Document '$id' has been " . (($args{type} eq 'new') ? "added" : "updated");
    #$output .= doAlertBox(text => "$message");
    if ($args{type} eq 'new') {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "document $id inserted", type => 8);
    } else {
        &logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "document $id updated", type => 9);
    }
    $output .= "<script language=javascript><!--\n";
    $output .= "   submitForm('$args{form}','updatedocumentselect');\n";
    $output .= "//--></script>\n";

    return($output);
}


###################################################################################################################################
sub doDisplayDocumentVersion {  # routine to display a document version
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
sub doBrowseDocumentFilter {  # routine to create the filter for document browsing
###################################################################################################################################
    my %args = (
        buttonText => "Browse Documents",
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
    $output .= "<td align=center>Entered/Modified Dates<br>\n";
    $output .= "<select name=docdate size=1>\n";
    $output .= "<option value=0" . (($settings{docdate} eq "0") ? " selected" : "") . ">All</option>\n";
    $output .= "<option value=1" . (($settings{docdate} eq "1") ? " selected" : "") . ">Past Three Months</option>\n";
    $output .= "<option value=2" . (($settings{docdate} eq "2") ? " selected" : "") . ">Past Six Months</option>\n";
    $output .= "<option value=3" . (($settings{docdate} eq "3") ? " selected" : "") . ">Past Year</option>\n";
    $output .= "</select></td><td> &nbsp; </td>";
    $output .= "<td align=center>Entered/Modified By<br>\n";
    my @users = &getUserArray(dbh=>$args{dbh}, schema=>$args{schema}, enteredDocument => 'T');
    $output .= "<select name=docuser size=1>\n";
    $output .= "<option value=0" . (($settings{docuser} == 0) ? " selected" : "") . ">Any User</option>\n";
    for (my $i=0; $i<$#users; $i++) {
        $output .= "<option value=$users[$i]{id}" . (($settings{docuser} == $users[$i]{id}) ? " selected" : "") . ">$users[$i]{lastname}, $users[$i]{firstname}</option>\n";
    }
    $output .= "</select><td> &nbsp; </td>";
    $output .= "<td valign=bottom><input type=button value='$args{buttonText}' onClick=\"submitForm('documents', 'browse');\"></td></tr></table>\n";
    $output .= "</td></tr></table>\n";

    return($output);
}


###################################################################################################################################
###################################################################################################################################



1; #return true
