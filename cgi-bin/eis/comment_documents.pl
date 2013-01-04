#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/atchleyb/rcs/crd/perl/RCS/comment_documents.pl,v $wasrescanned
#
# $Revision: 1.115 $
#
# $Date: 2008/01/18 00:50:00 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: comment_documents.pl,v $
# Revision 1.115  2008/01/18 00:50:00  atchleyb
# CREQ00052 - fix problem with change of copyComments
#
# Revision 1.114  2007/03/15 23:24:43  atchleyb
# CR0049 - Updated to use local per module rather than Oracle stored procedure
#
# Revision 1.113  2002/02/13 19:04:32  atchleyb
# removed depricated function for html header
#
# Revision 1.112  2001/10/31 21:25:50  atchleyb
# changed the popup selection for comparing commentors for dup/sim evaluation to use \' instead of ''
#
# Revision 1.111  2001/10/16 21:54:34  atchleyb
# removed debug code
#
# Revision 1.110  2001/10/16 21:29:10  atchleyb
# updated code that does the document test for duplicate/similar
# updated code so that all dependant similar documents call copyComments
#
# Revision 1.109  2001/10/15 21:43:45  atchleyb
# updated verification code to allow forms to correctly select a duplicate or similar document
# to be a duplicate or similar to
#
# Revision 1.108  2001/10/10 21:36:58  atchleyb
# changed the order of the dopdown for evaluation factor in update document
#
# Revision 1.107  2001/10/10 21:29:57  atchleyb
# added lists of similar and duplicate documents to browse
#
# Revision 1.106  2001/10/05 23:47:03  atchleyb
# updated browse of evaluation factor to have null displayed as None Assigned
#
# Revision 1.105  2001/10/05 23:25:57  atchleyb
# made the evaluation factor selection one line
#
# Revision 1.104  2001/10/05 23:14:19  atchleyb
# added evaluation factor to browse and update
#
# Revision 1.103  2001/09/28 21:18:40  atchleyb
# added code to get rid of duplicate chaining problem
#
# Revision 1.102  2001/09/12 16:47:18  atchleyb
# updated the javascript verification code testing phone and fax numbers
#
# Revision 1.101  2001/07/13 18:03:26  atchleyb
# un-did change from 1.100
# fixed javascript verification bug in update document that needlessly required a value in the new commentor id box when one was already set.
#
# Revision 1.100  2001/07/13 17:42:56  atchleyb
# changed update document to have the current commentor id in the new commentor box so that a javascript error will not be generated
#
# Revision 1.99  2001/07/02 23:22:20  atchleyb
# fixed bug that did not allow the input of organizations with an ' into doc capture
#
# Revision 1.98  2001/07/02 17:02:40  atchleyb
# added line to document capture menu about printing landscape - (Prints Landscape - select File/Page Setup... and Landscape option)
#
# Revision 1.97  2001/06/29 22:10:45  atchleyb
# adds organization and type of comment to mail receipt log.
# it also changes the format of the report to landscape and shrinks the font size so that the new columns will fit
#
# Revision 1.96  2001/06/28 22:18:13  atchleyb
# fixed misspelling of Anonymous and Similar
#
# Revision 1.95  2001/06/28 17:14:04  atchleyb
# additional javascript verification for getupdate
#
# Revision 1.94  2001/06/27 17:19:16  atchleyb
# fixed javascript verification error for getupdate
#
# Revision 1.93  2001/06/19 01:21:36  mccartym
# add grouporder column to document_type table - for ordering elements in the dropdowns
#
# Revision 1.92  2001/06/15 19:42:24  atchleyb
# added activity log entries for data entry 2 and proofread
#
# Revision 1.91  2001/06/15 19:24:32  atchleyb
# updated some error messages to be more specific.
#
# Revision 1.90  2001/06/15 16:21:49  atchleyb
# fixed spelling typo
#
# Revision 1.89  2001/06/11 18:28:03  atchleyb
# fixed bug with view new commentor button on data entry screens
# may have been caused by an IE 5.0 problem
#
# Revision 1.88  2001/06/01 19:04:51  atchleyb
# fixed bug in proofread that allowed a dupsimid to not be reset to null if field cleared out
#
# Revision 1.87  2001/06/01 15:53:45  atchleyb
# modified entry/edit screens to be more compact with one item per line,
# organized by related types
#
# Revision 1.86  2001/05/17 16:27:07  atchleyb
# modified to use &RelatedCRDText from DocumentSpecific.pm for $CRDRelatedText
#
# Revision 1.85  2001/05/16 22:52:48  atchleyb
# changed to display Environmental Impact Statement instead of Site Recomendation for SR by using
# a variable set at the top '$CRDRelatedText'
#
# Revision 1.84  2001/04/27 21:38:18  atchleyb
# added the textbox resize function to all text boxes
#
# Revision 1.83  2001/04/24 00:49:33  atchleyb
# added the new enclosurepagecout field to all screens
#
# Revision 1.82  2001/04/04 16:54:34  atchleyb
# changed addressee to use the build_select_from_piclist widget
#
# Revision 1.81  2001/04/04 00:57:43  atchleyb
# made change to addressee selection javascript for document cpature
#
# Revision 1.80  2001/04/04 00:40:54  atchleyb
# added javascript code to fix bug where if on an update, an addressee is not in addressee table, it is reset to default
#
# Revision 1.79  2001/04/03 23:11:53  atchleyb
# added call to activity_log when documents are updated
#
# Revision 1.78  2001/04/03 17:52:16  atchleyb
# fixed update bug that reset commentsentered flag to F
#
# Revision 1.77  2001/04/02 15:47:15  atchleyb
# fixed browse bug that allowed the input of a 0 for document id
#
# Revision 1.76  2001/03/29 16:32:28  atchleyb
# added wasrescanned to browse and update
# added some javascript form checking
#
# Revision 1.75  2001/03/27 02:32:36  atchleyb
# fixed bug in leading C for commentor id's
#
# Revision 1.74  2001/03/19 23:02:04  atchleyb
# updated to display a 'C' in front of commentor ID's
# left padded display of commentor ID's with upto 5 zeros
#
# Revision 1.73  2001/03/15 21:35:29  atchleyb
# changed max len of organization field to 120
#
# Revision 1.72  2001/03/14 02:26:29  atchleyb
# added "wasrescanned" check box to update
#
# Revision 1.71  2001/03/13 00:28:04  atchleyb
# added ability to enter organization in initial data entry
# made addressee a selection from a dropdown menu populated from a new addressee table
#
# Revision 1.70  2001/02/13 00:22:49  atchleyb
# fixed bug that would allow a document to be a duplicate of a duplicate
#
# Revision 1.69  2000/12/20 19:11:18  atchleyb
# fixed bug that did not allow changes to a document that was a duplicate or simular
#
# Revision 1.68  2000/12/07 23:32:53  atchleyb
# added code to handle multiple oracle servers
#
# Revision 1.67  2000/04/24 21:28:33  atchleyb
# modified to call display_image in CGIResults rathar than new window
#
# Revision 1.66  2000/04/14 19:45:28  atchleyb
# Updated code to make all popup windows open in thier own window
#
# Revision 1.65  2000/04/11 18:30:44  atchleyb
# changed display_commentor to fix javascript problem in popup window.
#
# Revision 1.64  2000/04/06 22:33:08  atchleyb
# modified to remove misc warnings
#
# Revision 1.63  2000/03/20 18:23:33  atchleyb
# updated code to get rid of warning messages about uninitialized values
#
# Revision 1.62  2000/03/10 18:15:33  atchleyb
# updated max width for signer count to 5
#
# Revision 1.61  2000/03/07 17:25:41  atchleyb
# modified the javascript function to call a commentor display
# added a hidden variable of "newwindow" with a value of 1 so display commentor could tell it is in a new window
#
# Revision 1.60  2000/03/01 17:28:06  atchleyb
# Added link on the Document Capture Report screen to go to the documents captured by week report in reports.pl
#
# Revision 1.59  2000/02/11 16:24:40  atchleyb
# removed $CRDAddressee and replaced with Wendy Dixson
#
# Revision 1.58  2000/02/10 23:15:54  atchleyb
# fixed error message
#
# Revision 1.57  2000/02/10 17:21:06  atchleyb
# removed form-verify.js
#
# Revision 1.56  2000/02/09 22:32:06  atchleyb
# updated to use $CRDAddressee instead of "Wendy Dixson"
#
# Revision 1.55  2000/02/07 23:40:37  atchleyb
# added link to browse screen for duplicate and simular documents
#
# Revision 1.54  2000/02/07 20:05:26  atchleyb
# fixed bug in loading scanned images caused by change in using File_Utilities.pl
#
# Revision 1.53  2000/02/07 18:06:50  atchleyb
# changed description on document capture report selection page.
#
# Revision 1.52  2000/02/07 16:59:06  atchleyb
# Replaced Jason with Supplemental Data Entry
#
# Revision 1.51  2000/01/14 23:32:09  atchleyb
# replaced all references to EIS with $crdtype
# changed file paths to use $CRDFullDocPath
# changed getbraketedimage to file_utilities.pl
#
# Revision 1.50  2000/01/06 18:55:58  atchleyb
# Fix a problem with the document capture report
# it was having a problem finding single didget dates
#
# Revision 1.49  1999/12/02 19:10:53  atchleyb
# commented out the message that says the bracketed image not found and using the scanned image instead
#
# Revision 1.48  1999/11/30 23:10:28  atchleyb
# fixed hidden variable bug for command on browse3
#
# Revision 1.47  1999/11/17 22:42:21  atchleyb
# fixed potential bad error message when a remark can't be written and document is set as simular
#
# Revision 1.46  1999/11/15 22:56:16  atchleyb
# added form verification for email to test for '@' to match database
#
# Revision 1.45  1999/11/15 22:11:48  atchleyb
# modified to get rid of leading zeros on input ids
# changed message not finding the scanned image to load to be more descriptive and have the correct id number
#
# Revision 1.44  1999/11/15 18:34:28  atchleyb
# fixed bug with browse and anonymous commentors
#
# Revision 1.43  1999/11/15 17:42:35  atchleyb
# fixed javascript bug in form verify that would not allow submition of simular documents
#
# Revision 1.42  1999/11/12 23:45:16  atchleyb
# changed browse comment document to not display commentor table, just name and link
# changed update comment document to compact name and address of commentor display
# fixed display title bug
# scanned image will now load on both dup and sim documents
# now deletes bracketed image from web server when scanned image is loaded
#
# Revision 1.41  1999/11/10 23:01:42  atchleyb
# loadScannedImage is now called for both similar and duplicate documents
# bracketed image file is now deleted when document is updated to duplicate or similar
#
# Revision 1.40  1999/11/10 00:37:47  atchleyb
# updated javascript form verification to handle condition of untested dupid
#
# Revision 1.39  1999/11/09 23:37:20  atchleyb
# changed 'browse3' section to set titlebar
#
# Revision 1.38  1999/11/09 16:20:37  mccartym
# change ID: to Commentor ID:
#
# Revision 1.37  1999/11/05 17:51:22  atchleyb
# fixed minor bug in test if documents is a duplicate or simular
#
# Revision 1.36  1999/11/04 15:45:45  mccartym
# title changes
#
# Revision 1.35  1999/10/28 00:05:45  atchleyb
# updated to use new tilte bar function
# fixed bugs with popup pages
# minor updates
#
# Revision 1.34  1999/10/19 17:27:16  atchleyb
# changed screen table widths to handle the new document types
# start of simular document processing (commented out to make this version production clean)
#
# Revision 1.33  1999/10/18 22:32:40  atchleyb
# changed default for signer count to 0
# forced form validation on doc capture/update - needed because of change from submit to javascript button
#
# Revision 1.32  1999/10/18 21:17:17  atchleyb
# fixed bug in dataentry2
#
# Revision 1.31  1999/10/15 23:44:48  atchleyb
# changed intructions on doc capture update
#
# Revision 1.30  1999/10/15 00:01:40  atchleyb
# several formating changes
# incorporated functions from mailroom_entry.pl as 'document capture'
# added fuction to update document capture
# fixed bug with popup window for simular commentors
# disabled browse commentors in new window due to a bug introduced by a change in commentors.pl browse
#
# Revision 1.29  1999/10/05 21:34:59  atchleyb
# added missing hidden variable for view braketed image in browse comment document
#
# Revision 1.28  1999/10/05 16:38:09  atchleyb
# fixed bug in update introduced when commentor display was changed
#
# Revision 1.27  1999/10/04 23:07:06  atchleyb
# fixed bug with single quotes in clobs
# fixed problem blanking fields in proofread
#
# Revision 1.26  1999/10/04 21:03:35  atchleyb
# changed table display type on display CD
#
# Revision 1.24  1999/09/30 17:12:27  atchleyb
# centered remarks from doRemarks
# added more error traping to the new document capture section
# modified to only display remarks table if there are remarks
# minor formating changes
#
# Revision 1.22  1999/09/28 21:50:26  atchleyb
# fixed misspelling of successful
#
# Revision 1.21  1999/09/28 17:34:53  atchleyb
# added check for viewcommentor to see if the use commentor id box is empty
#
# Revision 1.20  1999/09/23 22:59:12  atchleyb
# added code to display scanned images
# began merg of comment_documents.pl and mailroom_entry.pl
#
# Revision 1.19  1999/09/16 17:01:18  atchleyb
# minior modifications in the initial entry reports
#
# Revision 1.18  1999/09/16 00:01:39  atchleyb
# added view/reports for initial data entry
# switched order of state and postal code on screens
# created screens for initial data entry
#
# Revision 1.17  1999/09/13 22:55:41  atchleyb
# added screens for initial data entry list and reports
#
# Revision 1.16  1999/09/03 20:14:04  atchleyb
# added evals around db function calls
# commented out all raise error lines
#
# Revision 1.15  1999/09/01 22:39:57  atchleyb
# changed error handling in browse, gave it more error options
#
# Revision 1.14  1999/08/25 18:05:26  atchleyb
# changed background image path to use $CRDImagePath
#
# Revision 1.13  1999/08/18 16:35:00  atchleyb
# set all commentor fields to blur if anonymous or illegible is checked
#
# Revision 1.12  1999/08/16 22:53:20  atchleyb
# fixed some javascript, changed a name in a cgi form field refferance
#
# Revision 1.11  1999/08/13 23:49:56  atchleyb
# updated remarks display
#
# Revision 1.10  1999/08/12 18:33:47  atchleyb
# added a dash to phone numbers
# added a check for popup html window to see if it lost its connection.
#
# Revision 1.9  1999/08/12 00:12:35  atchleyb
# UI mods, field length fix, single quote fix in organization
#
# Revision 1.8  1999/08/10 23:48:07  atchleyb
# added popup html form to check for duplicate commentors
#
# Revision 1.7  1999/08/07 00:04:47  atchleyb
# added new way to tell if document is a duplicate/simular
#
# Revision 1.6  1999/08/06 15:39:53  atchleyb
# minor mod to states and countries functions
#
# Revision 1.5  1999/08/06 00:02:21  atchleyb
# Changed states and countires to function calls
#
# Revision 1.4  1999/08/05 18:19:38  atchleyb
# added eval blocks with raiserror and commits
#
# Revision 1.3  1999/08/02 02:47:48  mccartym
#  Reversed order of parameters on call to headerBar()
#
# Revision 1.2  1999/07/30 18:27:42  atchleyb
# changed hardcoded paths and changed most links to form submits
#
# Revision 1.1  1999/07/17 00:08:10  atchleyb
# Initial revision
#
#
use integer;
use strict;
#
$| = 1;
#
# get all required libraries and modules
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DocumentSpecific qw(:Functions);
use StoredProcedures qw(:Functions);
use Comments qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

# create cgi object for processing
my $crdcgi = new CGI;

# change any environment variables here

# set schema name
my $schema = $crdcgi->param("schema");

# Set server parameter
my $Server = $crdcgi->param("server");
if (!(defined($Server))) {$Server=$CRDServer;}

# Get username from the previous form for use later
my $username = $crdcgi->param("username");
my $userid = $crdcgi->param("userid");

# verify that user is accessing screen correctly
&checkLogin($username,$userid,$schema);

# Get document info from the previous form
my $documentid = ((defined($crdcgi->param("id"))) ? $crdcgi->param("id") : 0);

# get passed command
my $command = ((defined($crdcgi->param("command"))) ? $crdcgi->param("command") : "");

if (substr($command,0,6) ne 'report') {
  $documentid = $documentid - 0;
}

# tell the browser that this is an html page using the header method
print $crdcgi->header('text/html');

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $blankpath = $path . "blank.pl";

#
my $CRDRelatedText = &RelatedCRDText;
my $message='';
my $urllocation='';
my $sqlquery='';
my $sqlquery2='';
my $csr;
my @values;
tie my %lookup_values, "Tie::IxHash";
my @documentarray;
my @commentorarray;
my $status;
my $rows = 0;
my $rows2 = 0;
my $form2;

my $id=0;
my $newid=0;
my $documenttype=0;
my $datereceived='';
my $datereceived_month='';
my $datereceived_day='';
my $datereceived_year='';
my $enteredby1=0;
my $entrydate1='';
my $entryremarks1='';
my $enteredby2='';
my $entrydate2='';
my $entryremarks2='';
my $proofreadby=0;
my $proofreaddate='';
my $proofreadremarks='';
my $dupsimstatus=0;
my $dupsimid='';
my $dupsimstatussave=0;
my $dupsimidsave='';
my $hassrcomments=0;
my $haslacomments=0;
my $has960comments=0;
my $hasenclosures=0;
my $isillegible=0;
my $pagecount=0;
my $enclosurepagecount=0;
my $addressee='';
my $signercount='';
my $namestatus=0;
my $commentor=0;
my $removecommentorid=0;
my $newcommentorid=0;
my $remarks='';
my $todaysdate = &get_date;
my $wasrescanned='F';
my $evaluationfactor='';

my $commentorid=0;
my $lastname='';
my $firstname='';
my $middlename='';
my $title='';
my $suffix='';
my $address='';
my $city='';
my $state='';
my $country='';
my $postalcode='';
my $areacode='';
my $phonenumber='';
my $phoneextension='';
my $faxareacode='';
my $faxnumber='';
my $faxextension='';
my $email='';
my $organization='';
my $position='';
my $affiliation='';

my $pagetitle = '';

# vars for reports
my $currpagenumb=0;
my $islastpage=0;
my $pagelength=16;
my $startline=0;
my $endline=0;
my $lastpage=0;
my $doselected=0;
my $datecheck='';
my $startdate='';
my $enddate='';
my $startid=0;
my $endid=0;

#=================================================================================================
# subroutines
#=================================================================================================

sub build_states {
    # routine to build a selection box of states and set the current state to passed value
    my $state = ((defined($_[0])) ? $_[0] : "");

    my $outputstring = qq(
<select name=state>
<option value="">(None)<option value="AL">Alabama<option value="AK">Alaska<option value="AZ">Arizona<option value="AR">Arkansas<option value="CA">California<option value="CO">Colorado<option value="CT">Connecticut<option value="DE">Delaware<option value="FL">Florida<option value="GA">Georgia<option value="HI">Hawaii<option value="ID">Idaho<option value="IL">Illinois<option value="IN">Indiana<option value="IA">Iowa<option value="KS">Kansas<option value="KY">Kentucky<option value="LA">Louisiana<option value="ME">Maine<option value="MD">Maryland<option value="MA">Massachusetts<option value="MI">Michigan<option value="MN">Minnesota<option value="MS">Mississippi<option value="MO">Missouri<option value="MT">Montana<option value="NE">Nebraska<option value="NV">Nevada<option value="NH">New Hampshire<option value="NJ">New Jersey<option value="NM">New Mexico<option value="NY">New York<option value="NC">North Carolina<option value="ND">North Dakota<option value="OH">Ohio<option value="OK">Oklahoma<option value="OR">Oregon<option value="PA">Pennsylvania<option value="RI">Rhode Island<option value="SC">South Carolina<option value="SD">South Dakota<option value="TN">Tennessee<option value="TX">Texas<option value="UT">Utah<option value="VT">Vermont<option value="VA">Virginia<option value="WA">Washington<option value="DC">Washington D.C.<option value="WV">West Virginia<option value="WI">Wisconsin<option value="WY">Wyoming
</SELECT>
<script language=javascript><!--
   set_selected_option(document.$form.state, '$state');
//--></script>
    );
    return ($outputstring);
}


sub build_countries {
    # routine to build a select box of countries and set the default
    my $country = $_[0];

    my $outputstring = qq(

<select name=country>
<option value="">(None)<option value="US">United States<option value="CA">Canada<option value="MX">Mexico<option value="JP">Japan<option value="FR">France<option value="GR">Germany
</select>
<script language=javascript><!--
   set_selected_option(document.$form.country, '$country');
//--></script>
    );

    return ($outputstring);
}


sub get_commentor_name {
    my %args = (
        dbh => '',
        schema => '',
        userid => '',
        id => '',
        @_,
    );

    my $outputstring = '';
    my @values;

    @values = $args{'dbh'}->selectrow_array("SELECT firstname,lastname FROM $args{'schema'}.commentor WHERE id = $args{'id'}");
    $outputstring = ((defined($values[0])) ? "$values[0] " : "") . ((defined($values[1])) ? $values[1] : "");

    return($outputstring);

}


sub build_commentor_display {
    # routine to build a commentor display table
    my $dbh = $_[0];
    my $schema = $_[1];
    my $namestatus = $_[2];
    my $commentor;

    my $outputstring;
    my @commentorarray;
    my $csr;
    my @values;

    # commentor info
    $commentorarray[0][0] = "Commentor Information";
    $commentorarray[1][0] = "<b>" . "n/a" . "</b>";
    $commentorarray[1][1] = " ";
    if ($namestatus == 1) {
        $commentor = $_[3];
        $sqlquery = "SELECT id,lastname,firstname,middlename,title,suffix,address,city,state,country,postalcode,areacode,phonenumber,phoneextension,faxareacode,faxnumber,faxextension,email,organization,position,affiliation FROM $schema.commentor WHERE id = $commentor";
        eval {
            $csr = $dbh->prepare($sqlquery);
            $status = $csr->execute;
            @values = $csr->fetchrow_array;
            $csr->finish;
        };
        if (!($status) || $@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"select commentor # $commentor.",$@);
            $message =~ s/\n/\\n/g;
            $message =~ s/'/''/g;
        } else {
            $commentorarray[1][0] = "<b>Commentor ID:</b>";
            $commentorarray[1][1] = "<b>" . (defined($values[0]) ? "C" . lpadzero($values[0],4) : ' ') . "</b>";
            $commentorarray[2][0] = "<b>Title:</b>";
            $commentorarray[2][1] = "<b>" . (defined($values[4]) ? $values[4] : ' ') . "</b>";
            $commentorarray[3][0] = "<b>Name:</b>";
            $commentorarray[3][1] = "<b>" . (defined($values[2]) ? $values[2] : ' ') . (defined($values[3]) ? " $values[3]" : ' ') . (defined($values[1]) ? " $values[1]" : ' ') . "</b>";
            $commentorarray[4][0] = "<b>Suffix:</b>";
            $commentorarray[4][1] = "<b>" . (defined($values[5]) ? $values[5] : ' ') . "</b>";
            $commentorarray[5][0] = "<b>Position:</b>";
            $commentorarray[5][1] = "<b>" . (defined($values[19]) ? $values[19] : ' ') . "</b>";
            $commentorarray[6][0] = "<b>Organization:</b>";
            $commentorarray[6][1] = "<b>" . (defined($values[18]) ? $values[18] : ' ') . "</b>";
            $commentorarray[7][0] = "<b>Affiliation:</b>";
            eval {
                $commentorarray[7][1] = "<b>" . (defined($values[20]) ? get_value($dbh,$schema,'commentor_affiliation','name',"id = $values[20]") : ' ') . "</b>";
            };
            if ($@) {
                $message = errorMessage($dbh,$username,$userid,$schema,"get commentor affiliation.",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            }
            $commentorarray[8][0] = "<b>Street:</b>";
            $commentorarray[8][1] = "<b>" . (defined($values[6]) ? $values[6] : ' ') . "</b>";
            $commentorarray[9][0] = "<b>City/State/Postal Code: &nbsp; </b>";
            $commentorarray[9][1] = "<b>" . (defined($values[7]) ? "$values[7], " : ' ') . (defined($values[8]) ? $values[8] : ' ') . (defined($values[10]) ? " $values[10]" : ' ') . "</b>";
            $commentorarray[10][0] = "<b>Country:</b>";
            $commentorarray[10][1] = "<b>" . (defined($values[9]) ? $values[9] : ' ') . "</b>";
            $commentorarray[11][0] = "<b>Phone Number:</b>";
            $commentorarray[11][1] = "<b>" . (defined($values[11]) ? "(" . $values[11] . ") " : '') . (defined($values[12]) ? substr($values[12],0,3) . "-" . substr($values[12],3) : '') . (defined($values[13]) ? "-" . $values[13] : '') . "</b>";
            $commentorarray[12][0] = "<b>Fax Number:</b>";
            $commentorarray[12][1] = "<b>" . (defined($values[14]) ? "(" . $values[14] . ") " : '') . (defined($values[15]) ? substr($values[15],0,3) . "-" . substr($values[15],3) : '') . (defined($values[16]) ? "-" . $values[16] : '') . "</b>";
            $commentorarray[13][0] = "<b>Email Address:</b>";
            $commentorarray[13][1] = "<b>" . (defined($values[17]) ? $values[17] : ' ') . "</b>";

        }
    }

    $outputstring = gen_table (\@commentorarray);

    return ($outputstring);
}

sub loadScannedImage {
    my %args = (
        dbh => '',
        schema => '',
        userid => '',
        id => '',
        docpath => '',
        productionstatus => '',
        @_,
    );
    my $status =1;
    if ($args{'dbh'} eq '' || $args{'schema'} eq '' || $args{'userid'} eq '' || $args{'id'} eq '' || $args{'docpath'} eq '' || $args{'productionstatus'} eq '') {
        $status =0;
    } else {
        my $filename = "$CRDType" . lpadzero($args{'id'},6) . ".pdf";
        my $localfilename = "$CRDType" . lpadzero($args{'id'},6) . ".pdf";
        my $remote_path;
        #my $filepath = $ENV{'DOCUMENT_ROOT'} . $args{'docpath'};
        my $filepath = $args{'docpath'};
        $filepath =~ s/bracketed/scanned/;
        my $fullfilename = $filepath . "/" . $localfilename;
        if ($args{'productionstatus'} == 0) {
            $remote_path = $CRDType . "_CD_Images\\\\DevScanned";
        } else {
            $remote_path = $CRDType . "_CD_Images\\\\Scanned";
        }
        #$status = getBracketedImageFile(remote_path=>$remote_path,local_path=>"$args{'docpath'}/temp",image_file=>$filename,local_file=>$localfilename);
        if (open (FH2, "./File_Utilities.pl --command=sambaCopy --localPath=$filepath --remotePath=$remote_path --imageFile=$filename --localFile=$localfilename --protection=0777 |")) {
            $status = <FH2>;
            close FH2;
            if ($status == 1) {
                #chmod 0777, "$fullfilename";
                # load the file
                open FH1, "<$fullfilename";
                my $sqlquery = "UPDATE $args{'schema'}.document SET image = ? where id = $args{'id'}";
                my $val = "";
                my $rc = read(FH1, $val, 100000000);
                close FH1;
                my $csr = $args{'dbh'}->prepare($sqlquery);
                $csr->bind_param(1, $val, { ora_type=>ORA_BLOB, ora_field=>'image'});
                $status=$csr->execute;
                $args{'dbh'}->commit;
            } elsif ($status == 0) {
                $message = "Error trying to load Scanned image into table, Scanned image not found for $CRDType" . lpadzero($args{'id'},6);
                log_error ($args{'dbh'},$schema,$userid,$message);
            } else {
                $message = "Error trying to load Scanned image into table, Problem getting scanned image for $CRDType" . lpadzero($args{'id'},6);
                log_error ($args{'dbh'},$schema,$userid,$message);
            }
        } else {
            $message = "Error trying to load Scanned image into table, Problem getting scanned image for $CRDType" . lpadzero($args{'id'},6);
            log_error ($args{'dbh'},$schema,$userid,$message);
        }
    }

    return ($status);
}


#=======================================================================================================================================


# output page header
print "<html>\n";
print "<head>\n";
print "<meta http-equiv=expires content=0>\n";
print "<title>CRD Comment Document Entry</title>\n";
print "<!-- include external javascript code -->\n";
print "   <script src=$CRDJavaScriptPath/utilities.js></script>\n";
print "   <script src=$CRDJavaScriptPath/widgets.js></script>\n";
print " \n";
print "<!-- declare javascript functions unique to this form -->\n";
print <<END_OF_JAVASCRIPTS;
<script language=javascript><!--
// function to move focus off of a disabled field
function dupsim_test (obj1,obj2) {
  if (obj1[0].checked) {
    obj2.blur();
  }
}


//function to open new window
//function newWindow(name){
//   var file = name + ".htm";
//   window.open ( file, "", "width=750,height=500,scrollbars=yes");
//}

// function to enable the name field when required
function on_name_set(focustest) {
  if (document.$form.namestatus[0].checked) {
    document.$form.commentorlastname.disabled=false;
    if (focustest != "NoFocus") document.$form.commentorlastname.focus();
  } else {
    document.$form.commentorlastname.disabled=true;
    document.$form.commentorlastname.value="";
  }
}

//function to move focus off name field
function name_test(obj1, obj2) {
  if ((document.$form.namestatus[1].checked)||document.$form.namestatus[2].checked ) {
   obj2.blur();
  }
}

// Routine to check the data from the comment document data entry form part 2
function verify_comment_documents(f) {
  var msg = "";
  var returnVal = f.submitreturn.value;
  if (returnVal == 0) {
    returnVal = false;
  }
  if (f.command.value=='reportsetup' && f.documentid.value=='doc_capture') {
    returnVal = true;
    if (f.doselected[1].checked) {
      var startDate = (f.report_date_start_year.value - 0) * 10000 + (f.report_date_start_month.value - 0) * 100 + (f.report_date_start_day.value - 0);
      var endDate = (f.report_date_end_year.value - 0) * 10000 + (f.report_date_end_month.value - 0) * 100 + (f.report_date_end_day.value - 0);
      if (startDate > endDate) {
        msg += "End Date must be greater than or equal to Start Date\\n";
      }
    }
    if (f.doselected[2].checked) {
      if ((isblank(f.startid.value) && !(isblank(f.endid.value))) || (!(isblank(f.startid.value)) && isblank(f.endid.value)) || ((!(isnumeric(f.startid.value))) || (!(isnumeric(f.endid.value))))) {
        msg += "Both Start and End values must be set to positive integer numbers.\\n";
      } else if ((!(isblank(f.startid.value))) && (!(isblank(f.endid.value))) && ((f.endid.value-0) < (f.startid.value-0))) {
        msg += "End ID must be greater than Start ID.\\n";
      }
    }
  } else if (f.command.value=='doc_cap_entry_action' || f.command.value=='doc_cap_update_action') {
    returnVal = true;
    if (isblank(f.document.value)) {
      msg += "Comment Document ID must be input.\\n";
    } else if (!(isnumeric(f.document.value))) {
      msg += "Comment Document ID must be a number 1 to 6 digits long.\\n";
    } else if (f.document.value < 1) {
      msg += "Comment Document ID must be a positive number 1 to 6 digits long.\\n";
    }
    if (!(isblank(f.email.value))) {
      if (f.email.value.indexOf('\@') == -1) {
          msg += "Invalid E-Mail format.\\n";
      }
    }
    if ((f.namestatus[0].checked) && (f.commentorname.value == "")) {
      msg += "Commentor Name must be input.\\n";
    }
    if ((f.namestatus[1].checked) || (f.namestatus[2].checked)) {
      if (!(isblank(f.commentorname.value)) || !(isblank(f.email.value))) {
        msg += "Commentor Name and Email must be blank when Anonymous or Illegible is selected.\\n";
      }
    }
    if (isblank(f.addressee.value)) {
      msg += "Addressee must be input.\\n";
    }
    if (isblank(f.pagecount.value)) {
      msg += "Page Count must be input.\\n";
    } else if (!(isnumeric(f.pagecount.value))) {
      msg += "Page Count must be a number.\\n";
    } else if (f.pagecount.value < 1) {
      msg += "Page Count must be greater than 0\\n";
    }
    if (!(isnumeric(f.enclosurepagecount.value))) {
      msg += "Enclosure Page Count must be a number.\\n";
    } else if (f.enclosurepagecount.value < 0) {
      msg += "Enclosure Page Count must be 0 or greater\\n";
    }
    if (f.enclosurepagecount.value > 0 && !f.hasenclosures.checked) {
      msg += "Has Enclosures must be checked if Enclosure Page Count is greater than 0\\n";
    }
  } else if (f.command.value=='doc_cap_update') {
    returnVal = true;
  } else if (f.command.value=='browse1' || f.command.value=='update1' || f.command.value=='browse_form' || f.command.value=='update_form') {
    if (isblank(f.newid.value)) {
      msg += "Comment Document ID must be input.\\n";
    } else if (!(isnumeric(f.newid.value))) {
      msg += "Comment Document ID must be a positive number 1 to 6 digits long.\\n";
    } else if (f.document.value < 1) {
      msg += "Comment Document ID must be a positive number 1 to 6 digits long.\\n";
    } else if (f.document.value == 0 || f.document.value == '0') {
      msg += "Comment Document ID must be a positive number 1 to 6 digits long.\\n";
    }
    if (msg == "") {
        returnVal = true;
    }
  } else {
    if (isblank(f.newid.value)) {
      msg += "Comment Document ID must be input.\\n";
    } else if (!(isnumeric(f.newid.value))) {
      msg += "Comment Document ID must be a number 1 to 6 digits long.\\n";
    } else if (f.document.value < 1) {
      msg += "Comment Document ID must be a positive number 1 to 6 digits long.\\n";
    }
    if (isblank(f.addressee.value)) {
      msg += "Addressee must be input.\\n";
    }
    if (f.command.value != 'getupdate') {
        if ((f.namestatus[0].checked) && (f.commentorlastname.value == "") && (f.command.value != 'getupdate')) {
          msg += "Commentor Name must be input.\\n";
        }
        if ((f.namestatus[0].checked) && (f.commentorlastname.value == "") && (f.command.value == 'getupdate') && (isblank(f.newcommentorid.value)) && (f.commentorid.value<1)) {
          msg += "Commentor id to use must be input.\\n";
        }
        if (((f.namestatus[1].checked) || (f.namestatus[2].checked)) && (f.command.value != 'getupdate')) {
          if (!(isblank(f.commentorlastname.value)) || !(isblank(f.email.value))) {
            msg += "Commentor Last Name and Email must be blank when Anonymous or Illegible is selected.\\n";
          }
        }
    } else {
        if ((f.namestatus[0].checked) && (isblank(f.newcommentorid.value)) && (f.commentorid.value<1)) {
          msg += "Commentor id to use must be input.\\n";
        }
    }
    if (f.command.value == 'getproofread' || f.command.value == 'getentry' || f.command.value == 'doc_cap_entry_action' || f.command.value == 'doc_cap_update_action') {
        if (!(isblank(f.email.value))) {
          if (f.email.value.indexOf('\@') == -1) {
              msg += "Invalid E-Mail format.\\n";
          }
        }
    }
    if (f.command.value == 'getproofread' || f.command.value == 'getentry') {
        if (!(isblank(f.areacode.value))) {
          var ac = f.areacode.value;
          if (!(isnumeric(ac)) || ac.length != 3) {
            msg += "Area Code must be a 3 digit number.\\n";
          }
        }
        if (!(isblank(f.phonenumber.value))) {
          var pn = f.phonenumber.value;
          pn = pn.replace(/-/gi, "");
          if (!(isnumeric(pn)) || pn.length != 7) {
            msg += "Phone number must be a 7 digit number (with or with out the '-').\\n";
          }
        }
        if (!(isblank(f.phoneextension.value))) {
          var extn = f.phoneextension.value;
          if (!(isnumeric(extn))) {
            msg += "Phone extension must be a 1 to 5 digit number.\\n";
          }
        }
        if (!(isblank(f.faxareacode.value))) {
          var fac = f.faxareacode.value;
          if (!(isnumeric(fac)) || fac.length != 3) {
            msg += "FAX Area Code must be a 3 digit number.\\n";
          }
        }
        if (!(isblank(f.faxnumber.value))) {
          var fn = f.faxnumber.value;
          fn = fn.replace(/-/gi, "");
          if (!(isnumeric(fn)) || fn.length != 7) {
            msg += "FAX number must be a 7 digit number (with or with out the '-').\\n";
          }
        }
        if (!(isblank(f.faxextension.value))) {
          var fextn = f.faxextension.value;
          if (!(isnumeric(fextn))) {
            msg += "FAX extension must be a 1 to 5 digit number.\\n";
          }
        }
    }
    if (isblank(f.pagecount.value)) {
      msg += "Page Count must be input.\\n";
    } else if (!(isnumeric(f.pagecount.value))) {
      msg += "Page Count must be a number.\\n";
    } else if (f.pagecount.value < 1) {
      msg += "Page Count must be greater than 0\\n";
    }
    if (!(isnumeric(f.enclosurepagecount.value))) {
      msg += "Enclosure Page Count must be a number.\\n";
    } else if (f.enclosurepagecount.value < 0) {
      msg += "Enclosure Page Count must be 0 or greater\\n";
    }
    if (f.enclosurepagecount.value > 0 && !f.hasenclosures.checked) {
      msg += "Has Enclosures must be checked if Enclosure Page Count is greater than 0\\n";
    }
    if (isblank(f.signercount.value)) {
      msg += "Cosigner Count must be input.\\n";
    } else if (!(isnumeric(f.signercount.value))) {
      msg += "Cosigner Count must be a number.\\n";
    } else if (f.signercount.value < 0) {
      msg += "Cosigner Count must be greater than or equal to 0\\n";
    }
    if (!(isblank(f.dupsimdocid.value)) && !(f.dupstatus[0].checked) && !(f.dupstatus[1].checked)) {
      msg += "You must check the id # of the identical document first.\\n";
    }
    if (msg == "") {
      if (f.command.value == 'getproofread' || f.command.value == 'getentry') {
        if ((isblank(f.dupsimdocid.value) || f.dupstatus[1].checked) && (f.commentorid.value == f.newcommentorid.value || isblank(f.newcommentorid.value)) && (f.namestatus[0].checked)) {
        //if ((f.namestatus[0].checked) && !(f.dupstatus[0].checked)) {
          var old_id = document.$form.id.value;
          f.id.value = f.commentorid.value;
          //submitFormNewWindow('comment_documents','lookupcommentors2');
          submitFormCGIResults('comment_documents','lookupcommentors');
          f.id.value = old_id;
        } else {
          returnVal = true;
        }
      } else {
        returnVal = true;
      }
    } else {
      returnVal = true;
    }
  }
  if (msg != "") {
    alert (msg);
    returnVal = false;
  }
  //return true;
  return returnVal;
}

function submitForm(script, command) {
    var old_command = document.$form.command.value;
    var old_action = document.$form.action;
    var old_target = document.$form.target;
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'main';
    document.$form.submit();
    document.$form.command.value = old_command;
    document.$form.action = old_action;
    document.$form.target = old_target;
}


function submitFormCGIResults(script, command) {
    var old_command = document.$form.command.value;
    var old_action = document.$form.action;
    var old_target = document.$form.target;
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'cgiresults';
    document.$form.submit();
    document.$form.command.value = old_command;
    document.$form.action = old_action;
    document.$form.target = old_target;
}
function submitFormCGIResults2(script, command, id) {
          var old_command = document.$form.command.value;
          var old_id = document.$form.id.value;
          var old_action = document.$form.action;
          var old_target = document.$form.target;
          document.$form.command.value = command;
          document.$form.id.value = id;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = 'cgiresults';
          document.$form.submit();
          document.$form.command.value = old_command;
          document.$form.id.value = old_id;
          document.$form.action = old_action;
          document.$form.target = old_target;
}


function submitFormNewWindow(script, command) {
    var old_command = document.$form.command.value;
    var old_action = document.$form.action;
    var old_target = document.$form.target;
    var myDate = new Date();
    var winName = myDate.getTime();
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = winName;
    var newwin = window.open("",winName);
    newwin.creator = self;
    document.$form.submit();
    document.$form.command.value = old_command;
    document.$form.action = old_action;
    document.$form.target = old_target;
    //newwin.focus();
}


function submitFormNewWindow2(script, command, id) {
          var old_command = document.$form.command.value;
          var old_id = document.$form.command.id.value;
          var old_action = document.$form.action;
          var old_target = document.$form.target;
          var myDate = new Date();
          var winName = myDate.getTime();
          document.$form.command.value = command;
          document.$form.id.value = id;
          document.$form.action = '$path' + script + '.pl';
          document.$form.target = winName;
          var newwin = window.open("",winName);
          newwin.creator = self;
          document.$form.submit();
          document.$form.command.value = old_command;
          document.$form.id.value = old_id;
          document.$form.action = old_action;
          document.$form.target = old_target;
          //newwin.focus();
}


function submitFormNewWindow3(script, command, id) {
          var myDate = new Date();
          var winName = myDate.getTime();
          document.submit$form.command.value = command;
          document.submit$form.id.value = id;
          document.submit$form.action = '$path' + script + '.pl';
          document.submit$form.target = winName;
          var newwin = window.open("",winName);
          newwin.creator = self;
          document.submit$form.submit();
          //newwin.focus();
}


function resetSubmit(command) {
    document.$form.command.value = command;
    document.$form.action = '$ENV{'SCRIPT_NAME'}';
    document.$form.target = 'cgiresults';
}

function DisplayUser(id) {
    var old_id = document.$form.id.value;
    document.$form.id.value = id;
    submitForm ('user_functions', 'displayuser');
    document.$form.id.value = old_id;
}

function DisplayDocument(id) {
    var old_id = document.$form.id.value;
    document.$form.id.value = id;
    submitForm ('$form', 'browse2');
    document.$form.id.value = old_id;
}

function DocsByCommentor() {
    document.$form.lastname.value = document.$form.commentorlastname.value;
    submitFormNewWindow ('commentors', 'viewdocuments');
}

function ViewPDF(id) {
    document.$form.documentid.value = id;
    submitFormCGIResults ('display_image', 'pdf');
}

function ViewBracketedPDF(id) {
    var old_id = document.$form.id.value;
    document.$form.id.value = id;
    submitFormCGIResults ('$form', 'test_for_bracketed');
    document.$form.id.value = old_id;
}

function checkDupID() {
    if (!(isblank(document.$form.dupsimdocid.value))) {
        document.$form.formname.value='$form';
        submitFormCGIResults('comment_documents','checkdocumentid');
    }
    if (isblank(document.$form.dupsimdocid.value)) {
        document.$form.dupstatus[0].checked = false;
        document.$form.dupstatus[1].checked = false;
    }
}

//function DontKnowIfDup() {
//    document.$form.formname.value='$form';
//    submitFormCGIResults('comment_documents','comparecommentors');
//}


function viewCommentor(id) {
    var old_id = document.$form.id.value;
    document.$form.id.value = id;
    submitForm('commentors','display');
    document.$form.id.value = old_id;
}


function displayCommentor(id) {
    //var old_id = document.$form.id.value;
    //document.$form.id.value = id;
    if (id != document.$form.commentorid.value) {
        if (!(isblank(id)) && isnumeric(id) || isnumeric(id)) {
            //document.submit$form.newwindow.value=1;
            submitFormNewWindow3('commentors', 'display',id);
            //submitForm('commentors', 'display');
            //document.submit$form.newwindow.value=0;
        } else {
            alert ('"Commentor ID" must be set to a valid Commentor ID');
        }
    } else {
        alert ('Commentor #' + id + ' is currently on screen');
    }
    //document.$form.id.value = old_id;
}


function processMainForm() {
    opener.parent.main.$form.submitreturn.value=true;
    opener.parent.main.$form.submit();
    self.close();
    opener.parent.main.focus();
    location='$blankpath';
}


function selectNewCommentor(id) {
    opener.parent.main.$form.newcommentorid.value=id;
    opener.parent.main.$form.submitreturn.value=true;
    opener.parent.main.$form.submit();
    self.close();
    opener.parent.main.focus();
    location='$blankpath';
}


function doVerifySubmit (f) {
    if (verify_comment_documents(f)) {
        f.submit();
    }
}

//-->
</script>
END_OF_JAVASCRIPTS
print " \n";
print "</head>\n";
print "<body background=$CRDImagePath/background.gif text=#000099 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

# set default font atributes
print "<font face=\"$CRDFontFace\" color=$CRDFontColor>\n";

print "<!-- Command = $command -->\n";


# Connect to the oracle database and generate an object 'handle' to the database
my $dbh = db_connect();
#####my $dbh = db_connect(server => 'ydoracle');

$dbh->{LongReadLen} = 100000000;

# set up form for whole page
print "<center>\n";
if (index($command,'report') >=0) {
    print "<table border=0><tr><td>\n";
} else {
    print "<table border=0 width=750><tr><td>\n";
}

# setup form for the page (use filename_form as name of form)
print "<form name=$form onSubmit=\"return verify_comment_documents(this);\" action=$ENV{SCRIPT_NAME} target=cgiresults method=post>\n";


# process input data =============================================================================================================================
if ($command eq 'enter') {
    # get data for entry screen 2 ----------------------------------------------------------------------------------------------------------------
    $command = 'entry_form';

    $sqlquery = "SELECT id,documenttype,TO_CHAR(datereceived,'MM/DD/YYYY'),enteredby1,TO_CHAR(entrydate1,'MM/DD/YYYY HH:MI:SS'),entryremarks1,hasenclosures,isillegible,pagecount,addressee,namestatus,commentor,enclosurepagecount FROM $schema.document_entry WHERE id = $documentid";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    };
    if ($#values < 0 || $@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select document $CRDType" . &lpadzero($documentid,6) . " from DB for data entry 2.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        $urllocation = $path . "home.pl?username=$username&userid=$userid&schema=$schema";
    } else {

        ($id,$documenttype,$datereceived,$enteredby1,$entrydate1,$entryremarks1,$hasenclosures,$isillegible,$pagecount,$addressee,$namestatus,$commentor,$enclosurepagecount) = @values;
        if ($namestatus == 1) {
            # get commentor info
            $sqlquery = "SELECT id, lastname, email, organization FROM $schema.commentor_entry WHERE id = $commentor";
            eval {
                $csr = $dbh->prepare($sqlquery);
                $csr->execute;
                @values = $csr->fetchrow_array;
                $csr->finish;
            };
            if (!($@)) {
                ($commentorid, $lastname, $email, $organization) = @values;
            } else {
                $message = errorMessage($dbh,$username,$userid,$schema,"select commentor data.",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
                $urllocation = $path . "home.pl?username=$username&userid=$userid&schema=$schema";
            }
        } else {
            ($commentorid, $lastname, $email, $organization) = (0, '', '', '');
        }
    }


}

if ($command eq 'getentry') {
    # get data from entry 2 screen and process it -------------------------------------------------------------------------------------

    $newid = ((defined($crdcgi->param('newid'))) ? $crdcgi->param('newid') : 0) - 0;
    $documenttype = $crdcgi->param('doctype');
    $datereceived_month = $crdcgi->param("datereceived_month");
    $datereceived_day = $crdcgi->param("datereceived_day");
    $datereceived_year = $crdcgi->param("datereceived_year");
    $datereceived = &get_date ("$datereceived_month/$datereceived_day/$datereceived_year");
    $enteredby2 = $userid;
    $entrydate2 = $todaysdate;
    $entryremarks2 = ((defined($crdcgi->param('remarks'))) ? $crdcgi->param('remarks') : "");
    $dupsimstatus = $crdcgi->param('dupstatus');
    $dupsimid = ((defined($crdcgi->param('dupsimdocid'))) ? $crdcgi->param('dupsimdocid') : 1);
    if (!(defined($dupsimstatus))) {$dupsimstatus=1;}
    if ($dupsimstatus > 1 && (!(defined($dupsimid)) || $dupsimid <= 0)) {$dupsimstatus=1;}
    $hassrcomments = ((defined($crdcgi->param('hassrcomments'))) ? $crdcgi->param('hassrcomments') : "F");
    $haslacomments = ((defined($crdcgi->param('haslacomments'))) ? $crdcgi->param('haslacomments') : "F");
    $has960comments = ((defined($crdcgi->param('has96comments'))) ? $crdcgi->param('has96comments') : "F");
    $hasenclosures = ((defined($crdcgi->param('hasenclosures'))) ? $crdcgi->param('hasenclosures') : "F");
    $isillegible = ((defined($crdcgi->param('isillegible'))) ? $crdcgi->param('isillegible') : "F");
    $pagecount = $crdcgi->param('pagecount');
    $enclosurepagecount = $crdcgi->param('enclosurepagecount');
    $addressee = $crdcgi->param('addressee');
    if(defined($addressee)) {$addressee =~ s/'/''/g;}
    $signercount = $crdcgi->param('signercount');
    $namestatus = $crdcgi->param('namestatus');

    $commentorid = ((defined($crdcgi->param('commentorid'))) ? $crdcgi->param('commentorid') :"");
    $lastname = $crdcgi->param('commentorlastname');
    if(defined($lastname)) {$lastname =~ s/'/''/g;}
    $firstname = ((defined($crdcgi->param('firstname'))) ? $crdcgi->param('firstname') : "");
    if(defined($firstname)) {$firstname =~ s/'/''/g;}
    $middlename = ((defined($crdcgi->param('middlename'))) ? $crdcgi->param('middlename') : "");
    if(defined($middlename)) {$middlename =~ s/'/''/g;}
    $title = ((defined($crdcgi->param('title'))) ? $crdcgi->param('title') : "");
    if(defined($title)) {$title =~ s/'/''/g;}
    $suffix = ((defined($crdcgi->param('suffix'))) ? $crdcgi->param('suffix') : "");
    if(defined($suffix)) {$suffix =~ s/'/''/g;}
    $address = $crdcgi->param('address');
    if(defined($address)) {$address =~ s/'/''/g;}
    $city = ((defined($crdcgi->param('city'))) ? $crdcgi->param('city') : "");
    if(defined($city)) {$city =~ s/'/''/g;}
    $state = ((defined($crdcgi->param('state'))) ? $crdcgi->param('state') : "");
    $country = ((defined($crdcgi->param('country'))) ? $crdcgi->param('country') : "");
    $postalcode = ((defined($crdcgi->param('postalcode'))) ? $crdcgi->param('postalcode') : "");
    $areacode = ((defined($crdcgi->param('areacode'))) ? $crdcgi->param('areacode') : "");
    $phonenumber = ((defined($crdcgi->param('phonenumber'))) ? $crdcgi->param('phonenumber') : "");
    $phonenumber =~ s/-//;
    $phoneextension = ((defined($crdcgi->param('phoneextension'))) ? $crdcgi->param('phoneextension') : "");
    $faxareacode = ((defined($crdcgi->param('faxareacode'))) ? $crdcgi->param('faxareacode') : "");
    $faxnumber = ((defined($crdcgi->param('faxnumber'))) ? $crdcgi->param('faxnumber') : "");
    $faxnumber =~ s/-//;
    $faxextension = ((defined($crdcgi->param('faxextension'))) ? $crdcgi->param('faxextension') : "");
    $email = ((defined($crdcgi->param('email'))) ? $crdcgi->param('email') : "");
    if(defined($email)) {$email =~ s/'/''/g;}
    $organization = ((defined($crdcgi->param('organization'))) ? $crdcgi->param('organization') : "");
    if(defined($organization)) {$organization =~ s/'/''/g;}
    $position = ((defined($crdcgi->param('position'))) ? $crdcgi->param('position') : "");
    if(defined($position)) {$position =~ s/'/''/g;}
    $affiliation = $crdcgi->param('affiliation');
    $newcommentorid = ((defined($crdcgi->param('newcommentorid'))) ? $crdcgi->param('newcommentorid') : "");

    $sqlquery = "UPDATE $schema.document_entry SET id=$newid, documenttype=$documenttype, datereceived='$datereceived', enteredby2=$enteredby2, ";
    $sqlquery .= "entrydate2=SYSDATE, dupsimstatus=$dupsimstatus, pagecount=$pagecount, enclosurepagecount=$enclosurepagecount, addressee='$addressee', signercount=$signercount, ";
    $sqlquery .= "namestatus=$namestatus";
    if (defined($entryremarks2) && $entryremarks2 gt ' ') {
        $sqlquery .= ", entryremarks2=:remarks";
    }
    if (defined($dupsimid) && $dupsimid gt ' ') {
        $sqlquery .= ", dupsimid=$dupsimid";
    }
    if (defined($hassrcomments) && $hassrcomments eq 'T') {
        $sqlquery .= ", hassrcomments='$hassrcomments'";
    }
    if (defined($haslacomments) && $haslacomments eq 'T') {
        $sqlquery .= ", haslacomments='$haslacomments'";
    }
    if (defined($has960comments) && $has960comments eq 'T') {
        $sqlquery .= ", has960comments='$has960comments'";
    }
    if (defined($hasenclosures) && $hasenclosures eq 'T') {
        $sqlquery .= ", hasenclosures='$hasenclosures'";
    }
    if (defined($isillegible) && $isillegible eq 'T') {
        $sqlquery .= ", isillegible='$isillegible'";
    }
    if (defined($commentorid) && $commentorid > 0) {
        if ($namestatus == 1) {
            if (!(defined($commentorid)) || $commentorid < 1) {
                eval {
                    $commentorid = &get_next_commentor_id ($dbh, $schema);
                    $sqlquery2 = "INSERT INTO $schema.commentor_entry (id, lastname)  VALUES ('$commentorid', '$lastname')";
                    $csr = $dbh->prepare($sqlquery2);
                    $status = $csr->execute;
                    $dbh->commit;
                    $csr->finish;
                };
                if (!($status) || $@) {
                    $message = errorMessage($dbh,$username,$userid,$schema,"insert new commentor.",$@);
                    $message =~ s/\n/\\n/g;
                    $message =~ s/'/''/g;
                }
            }
            $sqlquery .= ", commentor=$commentorid";
        } else {
            $sqlquery .= ", commentor=NULL";
            $removecommentorid = $commentorid;
        }
    } else {
        if ($namestatus == 1) {
            eval {
                $commentorid = &get_next_commentor_id ($dbh, $schema);
                $sqlquery2 = "INSERT INTO $schema.commentor_entry (id, lastname)  VALUES ('$commentorid', '$lastname')";
                $csr = $dbh->prepare($sqlquery2);
                $status = $csr->execute;
                $dbh->commit;
                $csr->finish;
            };
            if (!($status) || $@) {
                $message = errorMessage($dbh,$username,$userid,$schema,"insert new commentor.",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            }
            $sqlquery .= ", commentor=$commentorid";
        } else {
            $sqlquery .= ", commentor=NULL";
        }
    }
    $sqlquery .= " WHERE id = $documentid";

    eval {
        $csr = $dbh->prepare($sqlquery);
        if (defined($entryremarks2) && $entryremarks2 gt ' ') {
            $csr->bind_param(":remarks", $entryremarks2, { ora_type => ORA_CLOB, ora_field=>'entryremarks2' });
        }
        $status = $csr->execute;
        $dbh->commit;
        $csr->finish;
    };

    if ($status && !($@)) {
        # if we have a name, update the commentor info
        $status = log_activity ($dbh, $schema, $userid, "Data entry 2 for Document $CRDType" . lpadzero($documentid,6) . ".");
        if ($namestatus == 1) {
            $sqlquery = "UPDATE $schema.commentor_entry SET lastname='$lastname', affiliation=$affiliation";
            if (defined($firstname) && $firstname gt ' ') {
                $sqlquery .= ", firstname='$firstname'";
            }
            if (defined($middlename) && $middlename gt ' ') {
                $sqlquery .= ", middlename='$middlename'";
            }
            if (defined($title) && $title gt ' ') {
                $sqlquery .= ", title='$title'";
            }
            if (defined($suffix) && $suffix gt ' ') {
                $sqlquery .= ", suffix='$suffix'";
            }
            if (defined($address) && $address gt ' ') {
                $sqlquery .= ", address='$address'";
            }
            if (defined($city) && $city gt ' ') {
                $sqlquery .= ", city='$city'";
            }
            if (defined($state) && $state gt ' ') {
                $sqlquery .= ", state='$state'";
            }
            if (defined($country) && $country gt ' ') {
                $sqlquery .= ", country='$country'";
            }
            if (defined($postalcode) && $postalcode gt ' ') {
                $sqlquery .= ", postalcode='$postalcode'";
            }
            if (defined($areacode) && $areacode gt ' ') {
                $sqlquery .= ", areacode='$areacode'";
            }
            if (defined($phonenumber) && $phonenumber gt ' ') {
                $sqlquery .= ", phonenumber='$phonenumber'";
            }
            if (defined($phoneextension) && $phoneextension gt ' ') {
                $sqlquery .= ", phoneextension='$phoneextension'";
            }
            if (defined($faxareacode) && $faxareacode gt ' ') {
                $sqlquery .= ", faxareacode='$faxareacode'";
            }
            if (defined($faxnumber) && $faxnumber gt ' ') {
                $sqlquery .= ", faxnumber='$faxnumber'";
            }
            if (defined($faxextension) && $faxextension gt ' ') {
                $sqlquery .= ", faxextension='$faxextension'";
            }
            if (defined($email) && $email gt ' ') {
                $sqlquery .= ", email='$email'";
            } else {
                $sqlquery .= ", email=NULL";
            }
            if (defined($organization) && $organization gt ' ') {
                $sqlquery .= ", organization='$organization'";
            }
            if (defined($position) && $position gt ' ') {
                $sqlquery .= ", position='$position'";
            }
            if (defined($newcommentorid) && $newcommentorid > 0 && $newcommentorid != $commentorid) {
                $sqlquery .= ", duplicates=$newcommentorid";
            }
            $sqlquery .= " WHERE id = $commentorid";
            eval {
                $csr = $dbh->prepare($sqlquery);
                $status = $csr->execute;
                $dbh->commit;
                $csr->finish;
            };

            if ($status && !($@)) {
                $urllocation = $path . "home.pl?username=$username&userid=$userid&schema=$schema";
            } else {
                $message = errorMessage($dbh,$username,$userid,$schema,"update commentor ID: $commentorid, for document ID: $CRDType" . lpadzero($newid,6) . ".",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            }
        } else {
            $urllocation = $path . "home.pl?username=$username&userid=$userid&schema=$schema";
        }

        if ($removecommentorid > 0) {
            $sqlquery = "DELETE FROM $schema.commentor_entry WHERE id = $removecommentorid";
            eval {
                $csr = $dbh->prepare($sqlquery);
                $status = $csr->execute;
                $dbh->commit;
                $csr->finish;
            };
            if (!($status) || $@) {
                $message = errorMessage($dbh,$username,$userid,$schema,"remove commentor # $removecommentorid from commentor_entry.",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            }
        }

    } else {
        $message = errorMessage($dbh,$username,$userid,$schema,"update $CRDType" . lpadzero($newid, 6) . ".",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    }

}

if ($command eq 'proofread') {
    # get data for the Comment Document ProofReed screen -------------------------------------------------------------------------------------
    $sqlquery = "SELECT id,documenttype,TO_CHAR(datereceived,'MM/DD/YYYY'),enteredby1,TO_CHAR(entrydate1,'MM/DD/YYYY HH:MI:SS'),entryremarks1,enteredby2,TO_CHAR(entrydate2,'MM/DD/YYYY HH:MI:SS'),entryremarks2,dupsimstatus,dupsimid,hassrcomments,haslacomments,has960comments,hasenclosures,isillegible,pagecount,addressee,signercount,namestatus,commentor,enclosurepagecount FROM $schema.document_entry WHERE id = $documentid";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    };
    if ($#values < 0 || $@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select document $CRDType" . &lpadzero($documentid,6) . " for proofread.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        $urllocation = $path . "home.pl?username=$username&userid=$userid&schema=$schema";
    } else {

        $command = 'proofread_form';
        ($id,$documenttype,$datereceived,$enteredby1,$entrydate1,$entryremarks1,$enteredby2,$entrydate2,$entryremarks2,$dupsimstatus,$dupsimid,$hassrcomments,$haslacomments,$has960comments,$hasenclosures,$isillegible,$pagecount,$addressee,$signercount,$namestatus,$commentor,$enclosurepagecount) = @values;
        if (defined($dupsimid) && $dupsimid > 0 && $dupsimstatus ==1) {
            $dupsimstatus=4;
        }
        if ((!defined($hassrcomments)) || $hassrcomments ne 'T') {
            $hassrcomments = 'F';
        }
        if ((!defined($haslacomments)) || $haslacomments ne 'T') {
            $haslacomments = 'F';
        }
        if ((!defined($has960comments)) || $has960comments ne 'T') {
            $has960comments = 'F';
        }
        if ((!defined($hasenclosures)) || $hasenclosures ne 'T') {
            $hasenclosures = 'F';
        }
        if ((!defined($isillegible)) || $isillegible ne 'T') {
            $isillegible = 'F';
        }
        if ($namestatus == 1) {
            # get commentor info
            $sqlquery = "SELECT id, lastname,firstname,middlename,title,suffix,address,city,state,country,postalcode,areacode,phonenumber,phoneextension,faxareacode,faxnumber,faxextension, email,organization,position,affiliation,duplicates FROM $schema.commentor_entry WHERE id = $commentor";
            eval {
                $csr = $dbh->prepare($sqlquery);
                $csr->execute;
                @values = $csr->fetchrow_array;
                $csr->finish;
            };
            if (!($@)) {
                ($commentorid, $lastname,$firstname,$middlename,$title,$suffix,$address,$city,$state,$country,$postalcode,$areacode,$phonenumber,$phoneextension,$faxareacode,$faxnumber,$faxextension, $email,$organization,$position,$affiliation,$newcommentorid) = @values;
                if (!(defined($newcommentorid)) || $newcommentorid <= 0) {
                    $newcommentorid = $commentorid;
                }
                if (defined($phonenumber)) {
                    $phonenumber = substr($phonenumber,0,3) . "-" . substr($phonenumber,3,4);
                }
                if (defined($faxnumber)) {
                    $faxnumber = substr($faxnumber,0,3) . "-" . substr($faxnumber,3,4);
                }
            } else {
                $message = errorMessage($dbh,$username,$userid,$schema,"select commentor data for $CRDType" . &lpadzero($documentid,6) . ".",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
                $urllocation = $path . "home.pl?username=$username&userid=$userid&schema=$schema";
            }
        } else {
            ($commentorid, $lastname,$firstname,$middlename,$title,$suffix,$address,$city,$state,$country,$postalcode,$areacode,$phonenumber,$phoneextension,$faxareacode,$faxnumber,$faxextension, $email,$organization,$position,$affiliation,$newcommentorid) = (0, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 0,'');
        }
    }

}

if ($command eq 'getproofread') {
    # get proofread data from form and process it --------------------------------------------------------------------------------------------

    $newid = ((defined($crdcgi->param('newid'))) ? $crdcgi->param('newid') : 0) - 0;
    $documenttype = $crdcgi->param('doctype');
    $datereceived_month = $crdcgi->param("datereceived_month");
    $datereceived_day = $crdcgi->param("datereceived_day");
    $datereceived_year = $crdcgi->param("datereceived_year");
    $datereceived = &get_date ("$datereceived_month/$datereceived_day/$datereceived_year");
    $proofreadby = $userid;
    $proofreaddate = $todaysdate;
    $proofreadremarks = $crdcgi->param('remarks');
    $dupsimstatus = ((defined($crdcgi->param('dupstatus'))) ? $crdcgi->param('dupstatus') : 1);
    $dupsimid = ((defined($crdcgi->param('dupsimdocid'))) ? $crdcgi->param('dupsimdocid') : "NULL");
    if (!(defined($dupsimstatus))) {$dupsimstatus=1;}
    if ($dupsimstatus > 1 && (!(defined($dupsimid)) || $dupsimid <= 0)) {$dupsimstatus=1;}
    $dupsimid = (($dupsimstatus != 1) ? "$dupsimid" : "NULL");
    $hassrcomments = ((defined($crdcgi->param('hassrcomments'))) ? $crdcgi->param('hassrcomments') : "F");
    $haslacomments = ((defined($crdcgi->param('haslacomments'))) ? $crdcgi->param('haslacomments') : "F");
    $has960comments = ((defined($crdcgi->param('has96comments'))) ? $crdcgi->param('has96comments') : "F");
    $hasenclosures = ((defined($crdcgi->param('hasenclosures'))) ? $crdcgi->param('hasenclosures') : "F");
    $isillegible = ((defined($crdcgi->param('isillegible'))) ? $crdcgi->param('isillegible') : "F");
    $pagecount = $crdcgi->param('pagecount');
    $enclosurepagecount = $crdcgi->param('enclosurepagecount');
    $addressee = $crdcgi->param('addressee');
    if(defined($addressee)) {$addressee =~ s/'/''/g;}
    $signercount = $crdcgi->param('signercount');
    $namestatus = $crdcgi->param('namestatus');

    $commentorid = ((defined($crdcgi->param('commentorid'))) ? $crdcgi->param('commentorid') : 0);
    $lastname = $crdcgi->param('commentorlastname');
    if(defined($lastname)) {$lastname =~ s/'/''/g;}
    $firstname = ((defined($crdcgi->param('firstname'))) ? $crdcgi->param('firstname') : "");
    if(defined($firstname)) {$firstname =~ s/'/''/g;}
    $middlename = ((defined($crdcgi->param('middlename'))) ? $crdcgi->param('middlename') : "");
    if(defined($middlename)) {$middlename =~ s/'/''/g;}
    $title = ((defined($crdcgi->param('title'))) ? $crdcgi->param('title') : "");
    if(defined($title)) {$title =~ s/'/''/g;}
    $suffix = ((defined($crdcgi->param('suffix'))) ? $crdcgi->param('suffix') : "");
    if(defined($suffix)) {$suffix =~ s/'/''/g;}
    $address = ((defined($crdcgi->param('address'))) ? $crdcgi->param('address') : "");
    if(defined($address)) {$address =~ s/'/''/g;}
    $city = ((defined($crdcgi->param('city'))) ? $crdcgi->param('city') : "");
    if(defined($city)) {$city =~ s/'/''/g;}
    $state = ((defined($crdcgi->param('state'))) ? $crdcgi->param('state') : "");
    if(defined($state)) {$state =~ s/'/''/g;}
    $country = ((defined($crdcgi->param('country'))) ? $crdcgi->param('country') : "");
    if(defined($country)) {$country =~ s/'/''/g;}
    $postalcode = ((defined($crdcgi->param('postalcode'))) ? $crdcgi->param('postalcode') : "");
    $areacode = ((defined($crdcgi->param('areacode'))) ? $crdcgi->param('areacode') : "");
    $phonenumber = ((defined($crdcgi->param('phonenumber'))) ? $crdcgi->param('phonenumber') : "");
    $phonenumber =~ s/-//;
    $phoneextension = ((defined($crdcgi->param('phoneextension'))) ? $crdcgi->param('phoneextension') : "");
    $faxareacode = ((defined($crdcgi->param('faxareacode'))) ? $crdcgi->param('faxareacode') : "");
    $faxnumber = ((defined($crdcgi->param('faxnumber'))) ? $crdcgi->param('faxnumber') : "");
    $faxnumber =~ s/-//;
    $faxextension = ((defined($crdcgi->param('faxextension'))) ? $crdcgi->param('faxextension') : "");
    $email = ((defined($crdcgi->param('email'))) ? $crdcgi->param('email') : "");
    if(defined($email)) {$email =~ s/'/''/g;}
    $organization = ((defined($crdcgi->param('organization'))) ? $crdcgi->param('organization') : "");
    if(defined($organization)) {$organization =~ s/'/''/g;}
    $position = ((defined($crdcgi->param('position'))) ? $crdcgi->param('position') : "");
    if(defined($position)) {$position =~ s/'/''/g;}
    $affiliation = $crdcgi->param('affiliation');
    $newcommentorid = ((defined($crdcgi->param('newcommentorid'))) ? $crdcgi->param('newcommentorid') : 0);
    if ((defined($commentorid)) && $newcommentorid < 1) { $newcommentorid = $commentorid; }
    if ($namestatus == 1 && $dupsimstatus ==2) {
        eval {
            $newcommentorid = get_value ($dbh,$schema, 'document', 'commentor', "id = $dupsimid");
        };
    }

    # save changes back to document_entry
    $sqlquery = "UPDATE $schema.document_entry SET id=$newid, documenttype=$documenttype, datereceived='$datereceived', ";
    $sqlquery .= "dupsimstatus=$dupsimstatus, pagecount=$pagecount, enclosurepagecount=$enclosurepagecount, addressee='$addressee', signercount=$signercount, ";
    $sqlquery .= "namestatus=$namestatus";
    if (defined($dupsimid) && $dupsimid gt ' ') {
        $sqlquery .= ", dupsimid=$dupsimid";
    }
    if (defined($hassrcomments) && $hassrcomments eq 'T') {
        $sqlquery .= ", hassrcomments='$hassrcomments'";
    }
    if (defined($haslacomments) && $haslacomments eq 'T') {
        $sqlquery .= ", haslacomments='$haslacomments'";
    }
    if (defined($has960comments) && $has960comments eq 'T') {
        $sqlquery .= ", has960comments='$has960comments'";
    }
    if (defined($hasenclosures) && $hasenclosures eq 'T') {
        $sqlquery .= ", hasenclosures='$hasenclosures'";
    }
    if (defined($isillegible) && $isillegible eq 'T') {
        $sqlquery .= ", isillegible='$isillegible'";
    }
    if (defined($commentorid) && $commentorid > 0) {
        if ($namestatus == 1) {
            if (!(defined($commentorid)) || $commentorid < 1) {
                eval {
                    $commentorid = &get_next_commentor_id ($dbh, $schema);
                    $newcommentorid = $commentorid;
                    $sqlquery2 = "INSERT INTO $schema.commentor_entry (id, lastname)  VALUES ('$commentorid', '$lastname')";
                    $csr = $dbh->prepare($sqlquery2);
                    $status = $csr->execute;
                    $dbh->commit;
                    $csr->finish;
                };
                if (!($status) || $@) {
                    $message = errorMessage($dbh,$username,$userid,$schema,"insert new commentor.",$@);
                    $message =~ s/\n/\\n/g;
                    $message =~ s/'/''/g;
                }
            }
            $sqlquery .= ", commentor=$commentorid";
        } else {
            $sqlquery .= ", commentor=NULL";
            $removecommentorid = $commentorid;
        }
    } else {
        if ($namestatus == 1) {
            eval {
                $commentorid = &get_next_commentor_id ($dbh, $schema);
                $newcommentorid = $commentorid;
                $sqlquery2 = "INSERT INTO $schema.commentor_entry (id, lastname)  VALUES ('$commentorid', '$lastname')";
                $csr = $dbh->prepare($sqlquery2);
                $status = $csr->execute;
                $dbh->commit;
                $csr->finish;
            };
            if (!($status) || $@) {
                $message = errorMessage($dbh,$username,$userid,$schema,"insert new commentor.",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            }
            $sqlquery .= ", commentor=$commentorid";
        } else {
            $sqlquery .= ", commentor=NULL";
        }
    }
    $sqlquery .= " WHERE id = $documentid";

    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        $dbh->commit;
        $csr->finish;
    };

    if ($status && !($@)) {
        # if we have a name, update the commentor info
        if ($namestatus == 1) {
            $sqlquery = "UPDATE $schema.commentor_entry SET lastname='$lastname', affiliation=$affiliation";
            if (defined($firstname) && $firstname gt ' ') {
                $sqlquery .= ", firstname='$firstname'";
            } else {
                $sqlquery .= ", firstname=NULL";
            }
            if (defined($middlename) && $middlename gt ' ') {
                $sqlquery .= ", middlename='$middlename'";
            } else {
                $sqlquery .= ", middlename=NULL";
            }
            if (defined($title) && $title gt ' ') {
                $sqlquery .= ", title='$title'";
            } else {
                $sqlquery .= ", title=NULL";
            }
            if (defined($suffix) && $suffix gt ' ') {
                $sqlquery .= ", suffix='$suffix'";
            } else {
                $sqlquery .= ", suffix=NULL";
            }
            if (defined($address) && $address gt ' ') {
                $sqlquery .= ", address='$address'";
            } else {
                $sqlquery .= ", address=NULL";
            }
            if (defined($city) && $city gt ' ') {
                $sqlquery .= ", city='$city'";
            } else {
                $sqlquery .= ", city=NULL";
            }
            if (defined($state) && $state gt ' ') {
                $sqlquery .= ", state='$state'";
            } else {
                $sqlquery .= ", state=NULL";
            }
            if (defined($country) && $country gt ' ') {
                $sqlquery .= ", country='$country'";
            } else {
                $sqlquery .= ", country=NULL";
            }
            if (defined($postalcode) && $postalcode gt ' ') {
                $sqlquery .= ", postalcode='$postalcode'";
            } else {
                $sqlquery .= ", postalcode=NULL";
            }
            if (defined($areacode) && $areacode gt ' ') {
                $sqlquery .= ", areacode='$areacode'";
            } else {
                $sqlquery .= ", areacode=NULL";
            }
            if (defined($phonenumber) && $phonenumber gt ' ') {
                $sqlquery .= ", phonenumber='$phonenumber'";
            } else {
                $sqlquery .= ", phonenumber=NULL";
            }
            if (defined($phoneextension) && $phoneextension gt ' ') {
                $sqlquery .= ", phoneextension='$phoneextension'";
            } else {
                $sqlquery .= ", phoneextension=NULL";
            }
            if (defined($faxareacode) && $faxareacode gt ' ') {
                $sqlquery .= ", faxareacode='$faxareacode'";
            } else {
                $sqlquery .= ", faxareacode=NULL";
            }
            if (defined($faxnumber) && $faxnumber gt ' ') {
                $sqlquery .= ", faxnumber='$faxnumber'";
            } else {
                $sqlquery .= ", faxnumber=NULL";
            }
            if (defined($faxextension) && $faxextension gt ' ') {
                $sqlquery .= ", faxextension='$faxextension'";
            } else {
                $sqlquery .= ", faxextension=NULL";
            }
            if (defined($email) && $email gt ' ') {
                $sqlquery .= ", email='$email'";
            } else {
                $sqlquery .= ", email=NULL";
            }
            if (defined($organization) && $organization gt ' ') {
                $sqlquery .= ", organization='$organization'";
            } else {
                $sqlquery .= ", organization=NULL";
            }
            if (defined($position) && $position gt ' ') {
                $sqlquery .= ", position='$position'";
            } else {
                $sqlquery .= ", position=NULL";
            }
            if (defined($newcommentorid) && $newcommentorid > 0 && $newcommentorid != $commentorid) {
                $sqlquery .= ", duplicates=$newcommentorid";
            }
            $sqlquery .= " WHERE id = $commentorid";
            eval {
                $csr = $dbh->prepare($sqlquery);
                $status = $csr->execute;
                $dbh->commit;
                $csr->finish;
            };

            if ($status && !($@)) {
                eval {
                $commentor = get_value ($dbh,$schema,'commentor','id', "id = $newcommentorid");
                };
                if ($@) {
                    $message = errorMessage($dbh,$username,$userid,$schema,"get commentor id.",$@);
                    $message =~ s/\n/\\n/g;
                    $message =~ s/'/''/g;
                }
                if ($commentorid == $newcommentorid || $commentor == $newcommentorid) {
                    $status = 1;
                } else {
                    $status = 0;
                    $message = "New commentor id not found, try again.";
                }

                if ($status == 1) {
                    eval {
                        $status = &process_document_entry(dbh=>$dbh, schema=>$schema, id=>$newid, proofreadby=>$userid, namestatus=>$namestatus,
                            newcommentor=>$newcommentorid);
                        
                        my $status2 = log_activity ($dbh, $schema, $userid, "Proofread for Document $CRDType" . lpadzero($documentid,6) . ".");
                    };
                    if ($status == 0 && !($@)) {
                        #$message .= "$CRDType" . lpadzero($newid,6);
                        $urllocation = $path . "home.pl?username=$username&userid=$userid&schema=$schema";

                        if ($proofreadremarks ge ' ') {
                            $sqlquery = "INSERT INTO $schema.document_remark (document, remarker, dateentered, text) VALUES ($newid, $userid, SYSDATE, :remarks)";
                            eval {
                                $csr = $dbh->prepare($sqlquery);
                                $csr->bind_param(":remarks", $proofreadremarks, { ora_type => ORA_CLOB, ora_field=>'text' });
                                $status = $csr->execute;
                                $dbh->commit;
                                $csr->finish;
                            };
                            if (!($status) || $@) {
                                $message = errorMessage($dbh,$username,$userid,$schema,"store remarks made by proofreader for $CRDType" . lpadzero($newid,6) . ".",$@);
                                $message =~ s/\n/\\n/g;
                                $message =~ s/'/''/g;
                            }
                        }
                        if ($dupsimstatus ==3) {
                            # copy duplicate comments from similar document
                            my $commentsentered;
                            eval {
                                $commentsentered = get_value ($dbh,$schema, 'document', 'commentsentered', "id = $dupsimid");
                                $rows= $dbh->selectrow_array ("SELECT count(*) FROM $schema.comments_entry WHERE document=$dupsimid");
                                if ($commentsentered eq 'T' && $rows == 0) {
                                    createDupCommentsForSimilarDocument(dbh => $dbh, schema => $schema, userId => $userid, duplicateDocument => $newid, parentDocument => $dupsimid);
                                }
                            };
                            if ($@) {
                                $message = errorMessage($dbh,$username,$userid,$schema,"copy comments for duplicate document $CRDType" . lpadzero($newid,6) . ".",$@);
                                $message =~ s/\n/\\n/g;
                                $message =~ s/'/''/g;
                            }

                        }
                        if ($dupsimstatus != 1) {
                            eval {
                                $sqlquery = "UPDATE $schema.document SET commentsentered = 'T' WHERE id = $newid";
                                $csr = $dbh->prepare($sqlquery);
                                $status = $csr->execute;
                                $dbh->commit;
                                $csr->finish;
                                $status = loadScannedImage(dbh => $dbh, schema => $schema, userid => $userid, id => $newid, docpath => $CRDFullDocPath, productionstatus => $CRDProductionStatus);
                                $dbh->commit;

                            };
                            if (!($status) || $@) {
                                $message = errorMessage($dbh,$username,$userid,$schema,"set comments entered flag to T and load scanned image for duplicate/similar document $CRDType" . lpadzero($newid,6) . ".",$@);
                                $message =~ s/\n/\\n/g;
                                $message =~ s/'/''/g;
                            }
                        }
                    } else {
                        $message .= errorMessage($dbh,$username,$userid,$schema,"save proofread to $CRDType" . lpadzero($newid,6) . ".",$@);
                        $message =~ s/\n/\\n/g;
                        $message =~ s/'/''/g;
                    }
                }
            } else {
                $message .= errorMessage($dbh,$username,$userid,$schema,"update commentor ID: C" . lpadzero($commentorid,4) . ", for document ID: $CRDType" . lpadzero($newid,6) . ".",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            }
        } else {
            eval {
                $status = &process_document_entry(dbh=>$dbh, schema=>$schema, id=>$newid, proofreadby=>$userid, namestatus=>$namestatus,
                        newcommentor=>0);

                my $status2 = log_activity ($dbh, $schema, $userid, "Proofread for Document $CRDType" . lpadzero($documentid,6) . ".");
            };
            if ($status == 0 && !($@)) {
                #$message .= "$CRDType" . lpadzero($newid,6);
                $urllocation = $path . "home.pl?username=$username&userid=$userid&schema=$schema";

                if ($proofreadremarks ge ' ') {
                    $sqlquery = "INSERT INTO $schema.document_remark (document, remarker, dateentered, text) VALUES ($newid, $userid, SYSDATE, :remarks)";
                    eval {
                        $csr = $dbh->prepare($sqlquery);
                        $csr->bind_param(":remarks", $proofreadremarks, { ora_type => ORA_CLOB, ora_field=>'text' });
                        $status = $csr->execute;
                        $dbh->commit;
                        $csr->finish;
                    };
                    if (!($status) || $@) {
                        $message = errorMessage($dbh,$username,$userid,$schema,"store remarks made by proofreader for $CRDType" . lpadzero($newid,6) . ".",$@);
                        $message =~ s/\n/\\n/g;
                        $message =~ s/'/''/g;
                    }
                }
                if ($dupsimstatus ==3) {
                    # copy duplicate comments from similar document
                    my $commentsentered;
                    eval {
                        $commentsentered = get_value ($dbh,$schema, 'document', 'commentsentered', "id = $dupsimid");
                        $rows= $dbh->selectrow_array ("SELECT count(*) FROM $schema.comments_entry WHERE document=$dupsimid");
                        if ($commentsentered eq 'T' && $rows == 0) {
                            createDupCommentsForSimilarDocument(dbh => $dbh, schema => $schema, userId => $userid, duplicateDocument => $newid, parentDocument => $dupsimid);
                        }
                    };
                    if ($@) {
                        $message = errorMessage($dbh,$username,$userid,$schema,"copy comments for duplicate document $CRDType" . lpadzero($newid,6) . ".",$@);
                        $message =~ s/\n/\\n/g;
                        $message =~ s/'/''/g;
                    }
                }
                if ($dupsimstatus != 1) {
                    eval {
                        $sqlquery = "UPDATE $schema.document SET commentsentered = 'T' WHERE id = $newid";
                        $csr = $dbh->prepare($sqlquery);
                        $status = $csr->execute;
                        $dbh->commit;
                        $csr->finish;
                        $status = loadScannedImage(dbh => $dbh, schema => $schema, userid => $userid, id => $newid, docpath => $CRDFullDocPath, productionstatus => $CRDProductionStatus);
                        $dbh->commit;

                    };
                    if (!($status) || $@) {
                        $message = errorMessage($dbh,$username,$userid,$schema,"set comments entered flag to T and load scanned image for duplicate/similar document $CRDType" . lpadzero($newid,6) . ".",$@);
                        $message =~ s/\n/\\n/g;
                        $message =~ s/'/''/g;
                    }
                }
            } else {
                $message = errorMessage($dbh,$username,$userid,$schema,"save proofread to $CRDType" . lpadzero($newid,6) . ".",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            }
        }

        if ($removecommentorid > 0) {
            $sqlquery = "DELETE FROM $schema.commentor_entry WHERE id = $removecommentorid";
            eval {
                $csr = $dbh->prepare($sqlquery);
                $status = $csr->execute;
                $dbh->commit;
                $csr->finish;
            };
            if (!($status) || $@) {
                $message = errorMessage($dbh,$username,$userid,$schema,"remove commentor # C" . lpadzero($removecommentorid,4) . " from commentor_entry.",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            }
        }

    } else {
        $message = errorMessage($dbh,$username,$userid,$schema,"update updating $CRDType" . lpadzero($newid, 6) . ".",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    }


}

if ($command eq "browse") {
    # setup for first browse screen --------------------------------------------------------------------------------------------------------------
    $command = "browse_form";

}

if ($command eq "browse1") {
    # process browse 1 ---------------------------------------------------------------------------------------------------------------------------

    $documentid = ((defined($crdcgi->param('newid'))) ? $crdcgi->param('newid') : 0) - 0;
    if ($documentid != 0) {
        $sqlquery = "SELECT id FROM $schema.document WHERE id = $documentid";
        eval {
            $csr = $dbh->prepare($sqlquery);
            $status = $csr->execute;
            @values = $csr->fetchrow_array;
            $csr->finish;
        };
        if (!($status) || $documentid != $values[0] || $@) {
            if (!($@)) {
                $message = "Document $CRDType" . lpadzero($documentid,6) . " does not exist.";
            } else {
                $message = errorMessage($dbh,$username,$userid,$schema,"select $CRDType" . lpadzero($documentid,6) . ".",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            }
        } else {
            $urllocation = $path . "comment_documents.pl?username=$username&userid=$userid&schema=$schema&id=$documentid&command=browse2";
        }
    } else {
        $message = "Please input a valid document id.";
    }
}
if ($command eq "browse2" || $command eq "browse3") {
    # process browse 2 ---------------------------------------------------------------------------------------------------------------------------

    #$documentid = ((defined($crdcgi->param('id'))) ? $crdcgi->param('id') : 0) - 0;
    $sqlquery = "SELECT id,documenttype,TO_CHAR(datereceived,'DD-MON-YYYY'),enteredby1,TO_CHAR(entrydate1,'DD-MON-YYYY HH:MI:SS'),enteredby2,TO_CHAR(entrydate2,'DD-MON-YYYY HH:MI:SS'),proofreadby,TO_CHAR(proofreaddate,'DD-MON-YYYY HH:MI:SS'),dupsimstatus,dupsimid,hassrcomments,haslacomments,has960comments,hasenclosures,isillegible,commentsentered,pagecount, addressee, signercount,namestatus,commentor,wasrescanned,enclosurepagecount,evaluationfactor FROM $schema.document WHERE id = $documentid";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    };
    if (!($status) || $@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select $CRDType" . lpadzero($documentid,6) . ".",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    } else {
        if ($command eq "browse2") {
            $command = "browse2_form";
        } else {
            $command = "browse3_form";
        }
        $pagetitle = "Browse Comment Document";
        $datereceived = $values[2];

        $documentarray[0][0] = "Comment Document Information";
        $documentarray[1][0] = "Document ID:";
        $documentarray[1][1] = "<b>" . "$CRDType" . lpadzero($values[0],6) . "</b>";
        $documentarray[2][0] = "Type:";
        eval {
            $documentarray[2][1] = "<b>" . get_value($dbh,$schema,'document_type','name',"id = $values[1]") . "</b>";
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get document type.",$@);
            $message =~ s/\n/\\n/g;
            $message =~ s/'/''/g;
        }
        $documentarray[3][0] = "Date Received:";
        $documentarray[3][1] = "<b>" . $values[2] . "</b>";
        $documentarray[4][0] = "View Image:";
        $documentarray[4][1] = "<b>" . "<a href=\"javascript:ViewBracketedPDF($documentid)\">$CRDType" . lpadzero($values[0],6) . "</a>" . "</b>";
        eval {
            $documentarray[5][0] = "Commentor:";
            if ($values[20] == 1) {
                $documentarray[5][1] = "<b><a href=javascript:viewCommentor($values[21])>" . get_commentor_name(dbh => $dbh, schema => $schema, userid => $userid, id => $values[21]) . "</a></b>";
            } else {
                $documentarray[5][1] = "<b>" . get_value($dbh,$schema,'commentor_name_status','name', "id=$values[20]") . "</b>";
            }
            $documentarray[6][0] = "Document Capture by:";
            $documentarray[6][1] = "<b><a href=javascript:DisplayUser($values[3])>" . get_fullname($dbh,$schema,$values[3]) . "</a></b>";
            $documentarray[7][0] = "Document Capture Date:";
            $documentarray[7][1] = "<b>" . $values[4] . "</b>";
            $documentarray[8][0] = "Data Entry by:";
            $documentarray[8][1] = "<b><a href=javascript:DisplayUser($values[5])>" . get_fullname($dbh,$schema,$values[5]) . "</a></b>";
            $documentarray[9][0] = "Data Entry Date:";
            $documentarray[9][1] = "<b>" . $values[6] . "</b>";
            $documentarray[10][0] = "Proofread by:";
            $documentarray[10][1] = "<b><a href=javascript:DisplayUser($values[7])>" . get_fullname($dbh,$schema,$values[7]) . "</a></b>";
            $documentarray[11][0] = "Proofread Date:";
            $documentarray[11][1] = "<b>" . $values[8] . "</b>";
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get data entry names.",$@);
            $message =~ s/\n/\\n/g;
            $message =~ s/'/''/g;
        }
        $documentarray[12][0] = "Addressee:";
        $documentarray[12][1] = "<b>" . $values[18] . "</b>";
        $documentarray[13][0] = "Page Count:";
        $documentarray[13][1] = "<b>" . $values[17] . "</b>";
        $documentarray[14][0] = "Cosigner Count:";
        $documentarray[14][1] = "<b>" . $values[19] . "</b>";
        $documentarray[15][0] = "Enclosures:";
        $documentarray[15][1] = "<b>" . $values[14] . "</b>";
        $documentarray[16][0] = "Enclosure Page count:";
        $documentarray[16][1] = "<b>" . $values[23] . "</b>";
        $documentarray[17][0] = "Illegible Text:";
        $documentarray[17][1] = "<b>" . $values[15] . "</b>";
        $documentarray[18][0] = "$CRDRelatedText:";
        $documentarray[18][1] = "<b>" . $values[11] . "</b>";
        $documentarray[19][0] = "License Application:";
        $documentarray[19][1] = "<b>" . $values[12] . "</b>";
        $documentarray[20][0] = "960/963:";
        $documentarray[20][1] = "<b>" . $values[13] . "</b>";
        $documentarray[21][0] = "Was Rescanned/Remarked:";
        $documentarray[21][1] = "<b>" . $values[22] . "</b>";
        $documentarray[22][0] = "All Comments Entered:";
        $documentarray[22][1] = "<b>" . $values[16] . "</b>";
        eval {
            $documentarray[23][0] = "Evaluation Factor:";
            my $evalFactor = ((defined($values[24])) ? get_value($dbh,$schema,'evaluation_factor','name',"id=$values[24]") : "None Assigned");
            $documentarray[23][1] = "<b>" . $evalFactor . "</b>";
            $documentarray[24][0] = "Duplicate of:";
            my $dupid = (($values[9] == 2) ? "<a href=javascript:DisplayDocument($values[10])>$CRDType" . lpadzero($values[10],6) . "</a>" : 'N/A');
            my $simid = (($values[9] == 3) ? "<a href=javascript:DisplayDocument($values[10])>$CRDType" . lpadzero($values[10],6) . "</a>" : 'N/A');
            $documentarray[24][1] = "<b>" . $dupid . "</b>";
            $documentarray[25][0] = "Similar To:";
            $documentarray[25][1] = "<b>" . $simid . "</b>";
            my $rows;
            ($rows) = $dbh->selectrow_array("SELECT count(*) FROM $schema.document WHERE dupsimstatus=2 AND dupsimid=$documentid");
            $documentarray[26][0] = "Has Duplicate Documents ($rows):&nbsp;";
            $documentarray[26][1] = "<b>";
            my $csrDoc = $dbh->prepare("SELECT id FROM $schema.document WHERE dupsimstatus=2 AND dupsimid=$documentid ORDER BY id");
            $status = $csrDoc->execute;
            my $count=0;
            while (my ($dupID) = $csrDoc->fetchrow_array) {
                $documentarray[26][1] .= (($count > 0) ? "<br>" : "") . "<a href=javascript:DisplayDocument($dupID)>$CRDType" . lpadzero($dupID,6) . "</a>";
                $count++;
            }
            $csrDoc->finish;
            $documentarray[26][1] .= "<b>";
            ($rows) = $dbh->selectrow_array("SELECT count(*) FROM $schema.document WHERE dupsimstatus=3 AND dupsimid=$documentid");
            $documentarray[27][0] = "Has Similar Documents ($rows):";
            $documentarray[27][1] = "<b>";
            $csrDoc = $dbh->prepare("SELECT id FROM $schema.document WHERE dupsimstatus=3 AND dupsimid=$documentid ORDER BY id");
            $status = $csrDoc->execute;
            $count=0;
            while (my ($dupID) = $csrDoc->fetchrow_array) {
                $documentarray[27][1] .= (($count > 0) ? "<br>" : "") . "<a href=javascript:DisplayDocument($dupID)>$CRDType" . lpadzero($dupID,6) . "</a>";
                $count++;
            }
            $csrDoc->finish;
            $documentarray[27][1] .= "<b>";
            
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"browse document $CRDType" . lpadzero($documentid,6) . ".",$@);
            $message =~ s/\n/\\n/g;
            $message =~ s/'/''/g;
        }


    }

}


if ($command eq 'update') {
    # goto update selection form ----------------------------------------------------------------------------------------------------------------
    $command = 'update_form';

}


if ($command eq 'update1') {
    # goto update form ----------------------------------------------------------------------------------------------------------------
    $newid = ((defined($crdcgi->param('newid'))) ? $crdcgi->param('newid') : 0) - 0;
    eval {
        $id = get_value($dbh,$schema,'document','id',"id = $newid");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"test document id for update.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    }
    if ($id == $newid) {
        $urllocation = $path . "comment_documents.pl?username=$username&userid=$userid&schema=$schema&documentid=$newid&command=update2";
    } else {
        $message = "Document $CRDType" . lpadzero($newid,6) . " does not exist.";
    }
}


if ($command eq 'update2') {
    # get data for update form ----------------------------------------------------------------------------------------------------------------
    $documentid = ((defined($crdcgi->param('documentid'))) ? $crdcgi->param('documentid') : 0) - 0;
    $sqlquery = "SELECT id,documenttype,TO_CHAR(datereceived,'MM/DD/YYYY'),enteredby1,TO_CHAR(entrydate1,'MM/DD/YYYY HH:MI:SS'),enteredby2,TO_CHAR(entrydate2,'MM/DD/YYYY HH:MI:SS'),proofreadby,TO_CHAR(proofreaddate,'MM/DD/YYYY HH:MI:SS'),dupsimstatus,dupsimid,hassrcomments,haslacomments,has960comments,hasenclosures,isillegible,pagecount,addressee,signercount,namestatus,commentor,wasrescanned,enclosurepagecount,evaluationfactor FROM $schema.document WHERE id = $documentid";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    };
    if ($#values < 0 || $@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select $CRDType" . &lpadzero($documentid,6) . ".",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    } else {

        $command = 'update2_form';
        ($id,$documenttype,$datereceived,$enteredby1,$entrydate1,$enteredby2,$entrydate2,$proofreadby,$proofreaddate,$dupsimstatus,$dupsimid,$hassrcomments,$haslacomments,$has960comments,$hasenclosures,$isillegible,$pagecount,$addressee,$signercount,$namestatus,$commentor,$wasrescanned,$enclosurepagecount,$evaluationfactor) = @values;
        if ((!defined($hassrcomments)) || $hassrcomments ne 'T') {
            $hassrcomments = 'F';
        }
        if ((!defined($haslacomments)) || $haslacomments ne 'T') {
            $haslacomments = 'F';
        }
        if ((!defined($has960comments)) || $has960comments ne 'T') {
            $has960comments = 'F';
        }
        if ((!defined($hasenclosures)) || $hasenclosures ne 'T') {
            $hasenclosures = 'F';
        }
        if ((!defined($isillegible)) || $isillegible ne 'T') {
            $isillegible = 'F';
        }
        if ((!defined($wasrescanned)) || $wasrescanned ne 'T') {
            $wasrescanned = 'F';
        }
        if ($namestatus == 1) {
            # get commentor info
            $sqlquery = "SELECT id, lastname,firstname,middlename,title,suffix,address,city,state,country,postalcode,areacode,phonenumber,phoneextension,faxareacode,faxnumber,faxextension, email,organization,position,affiliation FROM $schema.commentor WHERE id = $commentor";
            eval {
                $csr = $dbh->prepare($sqlquery);
                $csr->execute;
                @values = $csr->fetchrow_array;
                $csr->finish;
            };
            if (!($@)) {
                ($commentorid, $lastname,$firstname,$middlename,$title,$suffix,$address,$city,$state,$country,$postalcode,$areacode,$phonenumber,$phoneextension,$faxareacode,$faxnumber,$faxextension, $email,$organization,$position,$affiliation) = @values;
            } else {
                $message = errorMessage($dbh,$username,$userid,$schema,"select commentor data for commentor # C" . lpadzero($commentor,4) . ".",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            }
        } else {
            ($commentorid, $lastname,$firstname,$middlename,$title,$suffix,$address,$city,$state,$country,$postalcode,$areacode,$phonenumber,$phoneextension,$faxareacode,$faxnumber,$faxextension, $email,$organization,$position,$affiliation,$commentor) = (0, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 0,0);
        }
    }

}


if ($command eq 'getupdate') {
    # process update form ----------------------------------------------------------------------------------------------------------------
    $documentid = ((defined($crdcgi->param('newid'))) ? $crdcgi->param('newid') : 0) - 0;
    $documenttype = $crdcgi->param('doctype');
    $datereceived_month = $crdcgi->param('datereceived_month');
    $datereceived_day = $crdcgi->param('datereceived_day');
    $datereceived_year = $crdcgi->param('datereceived_year');
    $datereceived = get_date("$datereceived_month/$datereceived_day/$datereceived_year");
    $dupsimstatus = $crdcgi->param('dupstatus');
    $dupsimid = ((defined($crdcgi->param('dupsimdocid'))) ? $crdcgi->param('dupsimdocid') : "");
    $dupsimstatussave = $crdcgi->param('dupstatussave');
    $dupsimidsave = $crdcgi->param('dupsimdocidsave');
    if (!(defined($dupsimstatus))) {$dupsimstatus=1;}
    if ($dupsimstatus > 1 && (!(defined($dupsimid)) || $dupsimid <= 0)) {$dupsimstatus=1;}
    if (!(defined($dupsimstatussave))) {$dupsimstatussave=1;}
    if ($dupsimstatussave > 1 && (!(defined($dupsimidsave)) || $dupsimidsave <= 0)) {$dupsimstatussave=1;}
    $hassrcomments = $crdcgi->param('hassrcomments');
    if (!(defined($hassrcomments)) || $hassrcomments ne 'T') {$hassrcomments = 'F';}
    $haslacomments = $crdcgi->param('haslacomments');
    if (!(defined($haslacomments)) || $haslacomments ne 'T') {$haslacomments = 'F';}
    $has960comments = $crdcgi->param('has96comments');
    if (!(defined($has960comments)) || $has960comments ne 'T') {$has960comments = 'F';}
    $hasenclosures = $crdcgi->param('hasenclosures');
    if (!(defined($hasenclosures)) || $hasenclosures ne 'T') {$hasenclosures = 'F';}
    $isillegible = $crdcgi->param('isillegible');
    if (!(defined($isillegible)) || $isillegible ne 'T') {$isillegible = 'F';}
    $wasrescanned = ((defined($crdcgi->param('wasrescanned'))) ? $crdcgi->param('wasrescanned') : "F");
    $pagecount = $crdcgi->param('pagecount');
    $enclosurepagecount = $crdcgi->param('enclosurepagecount');
    $addressee = $crdcgi->param('addressee');
    $addressee =~ s/'/''/g;
    $signercount = $crdcgi->param('signercount');
    $evaluationfactor = ((defined($crdcgi->param('evaluationfactor'))) ? $crdcgi->param('evaluationfactor') : 0);
    $namestatus = $crdcgi->param('namestatus');
    $commentorid = ((defined($crdcgi->param('commentorid'))) ? $crdcgi->param('commentorid') : 0);
    $newcommentorid = ((defined($crdcgi->param('newcommentorid'))) ? $crdcgi->param('newcommentorid') : 0);
    $remarks = ((defined($crdcgi->param('remarks'))) ? $crdcgi->param('remarks') : "");

    if (defined($newcommentorid)) {
        if ($newcommentorid le ' ' || $newcommentorid < 1) {$newcommentorid = $commentorid;}
        eval {
            $commentor = get_value ($dbh,$schema,'commentor','id', "id = $newcommentorid");
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"test for new commentor id.",$@);
            $message =~ s/\n/\\n/g;
            $message =~ s/'/''/g;
        }
        if ($commentor == $newcommentorid) {
            $status = 1;
        } else {
            $status = 0;
            $message = "New commentor id not found, try again.";
        }
    } else {
        $newcommentorid = $commentorid;
    }
    if ($status) {
        $documentid = $documentid +1 -1;
        $rows= $dbh->selectrow_array ("SELECT count(*) FROM $schema.comments_entry WHERE document=$documentid");
        $rows2= $dbh->selectrow_array ("SELECT count(*) FROM $schema.comments WHERE document=$documentid");
        my $commentsentered;
        if (($rows > 0 || $rows2 > 0) && $dupsimstatus !=1 && $dupsimstatus != $dupsimstatussave) {
            $message = "Can not set document as a similar to or duplicate of another when it has comments entered";
        } elsif (($dupsimstatus != 3 && $dupsimstatussave == 3) || ($dupsimstatus == 3 && $dupsimstatussave == 3 && $dupsimid != $dupsimidsave)) {
            $message = "Can not change similar document information once set";
        } else {
            my ($parentID,$parentDupsimStatus,$parentDupsimid);
            if ($status) {
                if ($dupsimstatus ==1) {
                    $commentsentered = get_value ($dbh,$schema, 'document', 'commentsentered', "id = $documentid");
                    $commentsentered="'$commentsentered'";
                } else {
                    $commentsentered="'T'";
                }
                $sqlquery = "UPDATE $schema.document SET documenttype = $documenttype, datereceived = '$datereceived', dupsimstatus = $dupsimstatus, dupsimid = ";
                $sqlquery .= (($dupsimstatus != 1) ? "$dupsimid" : "NULL");
                $sqlquery .= ", hassrcomments = '$hassrcomments', haslacomments = '$haslacomments', has960comments = '$has960comments', hasenclosures = '$hasenclosures', isillegible = '$isillegible', ";
                $sqlquery .= "pagecount = $pagecount, enclosurepagecount=$enclosurepagecount, addressee = '$addressee', signercount = $signercount, namestatus = $namestatus, commentor = ";
                $sqlquery .= (($namestatus == 1) ? ((defined($newcommentorid) && $commentorid != $newcommentorid && $newcommentorid > 0) ? $newcommentorid : $commentorid) : "NULL");
                $sqlquery .= ",commentsentered = $commentsentered, wasrescanned = '$wasrescanned', evaluationfactor=";
                $sqlquery .= (($evaluationfactor != 0) ? "$evaluationfactor" : "NULL");
                $sqlquery .= " WHERE id = $documentid";
                eval {
                    $csr = $dbh->prepare($sqlquery);
                    $status = $csr->execute;
                    $dbh->commit;
                    $csr->finish;
                    $status = log_activity ($dbh, $schema, $userid, "Document $CRDType" . lpadzero($documentid,6) . " updated.");
                    if ($dupsimstatus ==3) {
                        # copy duplicate comments from similar document
                        my $commentsentered;
                        $commentsentered = get_value ($dbh,$schema, 'document', 'commentsentered', "id = $dupsimid");
                        $rows= $dbh->selectrow_array ("SELECT count(*) FROM $schema.comments_entry WHERE document=$dupsimid");
                        if ($commentsentered eq 'T' && $rows == 0) {
                            createDupCommentsForSimilarDocument(dbh => $dbh, schema => $schema, userId => $userid, duplicateDocument => $documentid, parentDocument => $dupsimid);
                        }
                    }
                    my ($parentID,$parentDupsimStatus,$parentDupsimID);
                    if ($dupsimstatus != 1) {
                        ($parentID,$parentDupsimStatus,$parentDupsimID) = $dbh->selectrow_array("SELECT id,dupsimstatus,NVL(dupsimid,0) FROM $schema.document WHERE id=$dupsimid");
                        $sqlquery = "SELECT id,dupsimstatus FROM $schema.document WHERE dupsimid = $documentid";
                        $csr = $dbh->prepare($sqlquery);
                        $status = $csr->execute;
                        while (my ($dupID, $dupStatus) = $csr->fetchrow_array) {
                            my $setSimTo = (($parentDupsimStatus != 1) ? $parentDupsimID : $parentID);

                            if ($dupsimstatus == 2 && $dupStatus == 2) {
                                $status = $dbh->do("UPDATE $schema.document SET dupsimid=$dupsimid WHERE dupsimid=$dupID AND dupsimstatus=2");
                            #} elsif ($dupsimstatus == 2 && $dupStatus == 3) {
                            #} elsif ($dupsimstatus == 3 && $dupStatus == 2) {
                            #} elsif ($dupsimstatus == 3 && $dupStatus == 3) {
                            }
                            my $commentsentered = get_value ($dbh,$schema, 'document', 'commentsentered', "id = $dupID");
                            if ($commentsentered eq 'T') {
                                my $csr2 = $dbh->prepare("SELECT id FROM $schema.document WHERE dupsimid=$dupID AND dupsimstatus=3");
                                $status = $csr2->execute;
                                while (my ($ID) = $csr2->fetchrow_array) {
                                    createDupCommentsForSimilarDocument(dbh => $dbh, schema => $schema, userId => $userid, duplicateDocument => $ID, parentDocument => $setSimTo);
                                }
                                $csr2->finish;
                            }
                            $status = $dbh->do("UPDATE $schema.document SET dupsimid=$setSimTo WHERE dupsimid=$dupID AND dupsimstatus=3");
                            
                            if ($dupStatus == 2) {
                                $status = $dbh->do("UPDATE $schema.document SET dupsimid=$dupsimid WHERE id=$dupID");
                            } else {
                                $status = $dbh->do("UPDATE $schema.document SET dupsimid=$setSimTo WHERE id=$dupID");
                                my $commentsentered = get_value ($dbh,$schema, 'document', 'commentsentered', "id = $dupID");
                                if ($commentsentered eq 'T') {
                                    createDupCommentsForSimilarDocument(dbh => $dbh, schema => $schema, userId => $userid, duplicateDocument => $dupID, parentDocument => $setSimTo);
                                }
                            }
                        }
                        $csr->finish;
                        $dbh->commit;
                    }
                    if ($dupsimstatus !=1) {
                        $status = loadScannedImage(dbh => $dbh, schema => $schema, userid => $userid, id => $documentid, docpath => $CRDFullDocPath, productionstatus => $CRDProductionStatus);
                        $dbh->commit;

                        #my $filepath = $ENV{'DOCUMENT_ROOT'} . $CRDDocPath;
                        my $filepath = $CRDFullDocPath;
                        my $filename = "$CRDType" . lpadzero($documentid,6) . ".pdf";
                        if (open (FH1, "<$filepath/$filename")) {
                            close (FH1);
                            #unlink("$filepath/$filename") or die "Can't delete bracketed image file $filename: $!\n";
                            if (open (FH2, "./File_Utilities.pl --command=deleteFile --fullFilePath=$filepath/$filename |")) {
                                close (FH2);
                            } else {
                                die "Can't delete bracketed image file $filename: $!\n";
                            }
                        }
                    }
                };
                if ($status && !($@)) {
                    $message = "Update was successful.";
                    $urllocation = $path . "comment_documents.pl?username=$username&userid=$userid&schema=$schema&command=update";
    
                    if (defined($remarks) && $remarks ge ' ') {
                        $sqlquery = "INSERT INTO $schema.document_remark (document, remarker, dateentered, text) VALUES ($documentid, $userid, SYSDATE, :remarks)";
                        eval {
                            $csr = $dbh->prepare($sqlquery);
                            $csr->bind_param(":remarks", $remarks, { ora_type => ORA_CLOB, ora_field=>'text' });
                            $status = $csr->execute;
                            $dbh->commit;
                            $csr->finish;
                        };
                        if (!($status) || $@) {
                            $message = errorMessage($dbh,$username,$userid,$schema,"store remarks made by updater for $CRDType" . lpadzero($documentid,6) . ".",$@);
                            $message =~ s/\n/\\n/g;
                            $message =~ s/'/''/g;
                        }
                    }
                } else {
                    $message = errorMessage($dbh,$username,$userid,$schema,"update document $CRDType" . lpadzero($documentid,6) . ".",$@);
                    $message =~ s/\n/\\n/g;
                    $message =~ s/'/''/g;
                }
            }
        }
    }

}


my $dupsimidParent = 0;
my ($dupnamestatus, $dupid, $dupcommentor);
my $testdupsimid = 0;
if ($command eq 'checkdocumentid') {
    # test to see if document id exists ----------------------------------------------------------------------------------------------------------------
    my $dupinfo=0;
    my $hasDups = 'F';
    my $currentID;
    $dupsimid = ((defined($crdcgi->param('dupsimdocid'))) ? $crdcgi->param('dupsimdocid') : 0) - 0;
    eval {
        $documentid = get_value ($dbh,$schema, 'document', 'id', "id = $dupsimid");
    };
    if (!(defined($documentid)) || ($dupsimid != $documentid) || $dupsimid == 0) {
        $message = "Document $CRDType" . lpadzero($dupsimid,6) . " not found.\\n Please enter a new document id.";
        $form2 = $crdcgi->param('formname');
        print "<script language=javascript><!--\n";
        print "  parent.main.$form2.dupsimdocid.value = '';\n";
        print "  parent.main.$form2.dupsimdocid.focus();\n";
        print "//--></script>\n";
    } else {
        eval {
            $dupinfo = get_value ($dbh,$schema, 'document', 'dupsimstatus', "id = $dupsimid");
            $currentID = $crdcgi->param('documentid');
            if ($dupinfo != 1) {
                ($dupnamestatus, $dupid, $dupcommentor) = $dbh->selectrow_array("SELECT namestatus, dupsimid, commentor FROM $schema.document WHERE id=$dupsimid");
            }
        };
        $form2 = $crdcgi->param('formname');
        if ($dupinfo == 2) {
            print "<script language=javascript><!--\n";
            print "  parent.main.$form2.dupsimdocid.value = '$dupid';\n";
            $dupsimid = $dupid;
            print "//--></script>\n";
            $command = 'comparecommentors';
        } elsif ($dupinfo == 3) {
            eval {
                $namestatus = $crdcgi->param('namestatus');
                if ($namestatus == 1 && $dupnamestatus == 1) {
                    $command = 'comparecommentors-dup';
                    $dupsimidParent = $dupid;
                } elsif ($namestatus == $dupnamestatus) {
                    print "<script language=javascript><!--\n";
                    print "    parent.main.$form2.dupstatus[0].checked = true;\n";
                    print "//--></script>\n";
                } else {
                    print "<script language=javascript><!--\n";
                    print "  parent.main.$form2.dupsimdocid.value = '$dupid';\n";
                    print "    parent.main.$form2.dupstatus[1].checked = true;\n";
                    print "//--></script>\n";
                    $dupsimid = $dupid;
                }
            };
            if ($@) {
                $message = errorMessage($dbh,$username,$userid,$schema,"test for duplicate $CRDType" . lpadzero($documentid,6) . ".",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            }
        } else {
            $command = 'comparecommentors';
        }
    }

    $testdupsimid = $dupsimid;
}


if ($command eq 'comparecommentors' || $command eq 'comparecommentors-dup') {
    # test to see if document id exists ----------------------------------------------------------------------------------------------------------------
    my $message2='';
    $dupsimid = $testdupsimid;
    $namestatus = $crdcgi->param('namestatus');
    $documentid = $crdcgi->param('id') - 0;
    $form2 = $crdcgi->param('formname');
    if ($dupsimid != $documentid ) {
            my ($parentID,$parentDupsimStatus,$parentDupsimid);
            $sqlquery = "SELECT namestatus, commentor,id FROM $schema.document WHERE id = $dupsimid";
            eval {
                $csr = $dbh->prepare($sqlquery);
                $status = $csr->execute;
                @values = $csr->fetchrow_array;
                $csr->finish;
                
                ($parentID,$parentDupsimStatus,$parentDupsimid) = $dbh->selectrow_array("SELECT id,dupsimstatus,dupsimid FROM $schema.document where id=$dupsimid");
            };
            if ($status && $values[2] == $dupsimid && !($@)) {
              if ($namestatus == 1 && $values[0] == 1) {
                $sqlquery = "SELECT id,lastname,firstname,middlename,title,suffix,address,city,state,country,postalcode,areacode,phonenumber,phoneextension,faxareacode,faxnumber,faxextension,email,organization,position,affiliation FROM $schema.commentor WHERE id = $values[1]";
                eval {
                    $csr = $dbh->prepare($sqlquery);
                    $status = $csr->execute;
                    @values = $csr->fetchrow_array;
                    $csr->finish;
                };
                $message2 .= "This is the commentor from $CRDType".lpadzero($dupsimid,6).".\\nIs it the same as the one for this document?\\n____________________________\\n";
                $message2 .= "Name: " . ((defined($values[2])) ? $values[2] : "") . " " . ((defined($values[3])) ? $values[3] : "") . " " . ((defined($values[1])) ? $values[1] : "") . "\\n";
                $message2 .= "Title: " . ((defined($values[4])) ? $values[4] : "") . "\\nSuffix: " . ((defined($values[5])) ? $values[5] : "") . "\\n";
                $message2 .= "Address:\\n" . ((defined($values[6])) ? $values[6] : "") . "\\n " . ((defined($values[7])) ? $values[7] : "") . ", " . ((defined($values[8])) ? $values[8] : "") . " " . ((defined($values[10])) ? $values[10] : "") . "\\n" . ((defined($values[9])) ? $values[9] : "") . "\\n";
                $message2 .= "Email Address: " . ((defined($values[17])) ? $values[17] : "") . "\\n";
                $message2 .= "Organization: " . ((defined($values[18])) ? $values[18] : "") . "\\n";
                $message2 .= "Position: " . ((defined($values[19])) ? $values[19] : "") . "\\n";
                eval {
                    $message2 .= "Affiliation: " . get_value($dbh,$schema,'commentor_affiliation','name', "id = $values[20]") . "\\n";
                };
                if ($@) {
                    $message = errorMessage($dbh,$username,$userid,$schema,"get commentor affiliation.",$@);
                    $message =~ s/\n/\\n/g;
                    $message =~ s/'/''/g;
                }
                $message2 .= "____________________________\\nClick on <OK> if it is the same.\\n";
                #$message2 =~ s/'/''/g;
                $message2 =~ s/'/\\'/g;
                if ($command eq 'comparecommentors') {
                    print "<script language=javascript><!--\n";
                    print "  if (confirm('$message2')) {\n";
                    print "    parent.main.$form2.dupstatus[0].checked = true;\n";
                    print "  } else {\n";
                    if ($parentDupsimStatus != 1) {
                        print "      parent.main.$form2.dupsimdocid.value = '$parentDupsimid';\n";
                    }
                    print "    parent.main.$form2.dupstatus[1].checked = true;\n";
                    print "  }\n";
                    print "//--></script>\n";
                } else {
                    print "<script language=javascript><!--\n";
                    print "  if (confirm('$message2')) {\n";
                    print "    parent.main.$form2.dupstatus[0].checked = true;\n";
                    print "  } else {\n";
                    print "      parent.main.$form2.dupsimdocid.value = '" . (($parentDupsimStatus == 1) ? $dupid : $parentDupsimid) . "';\n";
                    print "      parent.main.$form2.dupstatus[1].checked = true;\n";
                    print "  }\n";
                    print "//--></script>\n";
                }
              } else {
                print "<script language=javascript><!--\n";
                if ($namestatus == $values[0]) {
                    print "    parent.main.$form2.dupstatus[0].checked = true;\n";
                } else {
                    if ($command eq 'comparecommentors') {
                        print "    parent.main.$form2.dupstatus[1].checked = true;\n";
                    } else {
                        print "    parent.main.$form2.dupsimdocid.value = '$dupid';\n";
                        print "    parent.main.$form2.dupstatus[1].checked = true;\n";
                    }
                }
                print "//--></script>\n";
              }
            } else {
                $message = errorMessage($dbh,$username,$userid,$schema,"check if $CRDType" . lpadzero($documentid,6) . " is a duplicate or similar.",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            }
    } else {
        $message = "Document can not be a duplicate of itself.";
        print "<script language=javascript><!--\n";
        print "  parent.main.$form2.dupsimdocid.value = '';\n";
        print "  parent.main.$form2.dupstatus[0].checked = false;\n";
        print "  parent.main.$form2.dupstatus[1].checked = false;\n";
        print "//--></script>\n";
    }
}


if ($command eq 'lookupcommentors') {
    # get commentor data to help determine if it is a duplicate commentor ----------------------------------------------------------------------------------------------------------------
    #$command = 'lookupcommentorsform';
    $lastname = $crdcgi->param('commentorlastname');
    $lastname =~ s/'/''/g;
    $firstname = ((defined($crdcgi->param('firstname'))) ? $crdcgi->param('firstname') : "");
    $firstname =~ s/'/''/g;
    $city = ((defined($crdcgi->param('city'))) ? $crdcgi->param('city') : "");
    $city =~ s/'/''/g;
    $state = ((defined($crdcgi->param('state'))) ? $crdcgi->param('state') : "");
    $country = ((defined($crdcgi->param('country'))) ? $crdcgi->param('country') : "");
    $sqlquery = "SELECT id,lastname,firstname,middlename,city,state,country FROM $schema.commentor WHERE UPPER(lastname)=UPPER('$lastname')";
    if (defined($firstname) && $firstname gt ' ') {
        $sqlquery .= " AND UPPER(firstname)=UPPER('$firstname')";
    }
    if (defined($city) && $city gt ' ') {
        $sqlquery .= " AND UPPER(city)=UPPER('$city')";
    }
    if (defined($state) && $state gt ' ') {
        $sqlquery .= " AND UPPER(state)=UPPER('$state')";
    }
    if (defined($country) && $country gt ' ') {
        $sqlquery .= " AND UPPER(country)=UPPER('$country')";
    }
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"check if there are any similar commentors.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    } else {
        if ($#values>1) {
            $lastname =~ s/''/'/g;
            print "<input type=hidden name=commentorlastname value=\"$lastname\">\n";
            $firstname =~ s/''/'/g;
            print "<input type=hidden name=firstname value=\"$firstname\">\n";
            $city =~ s/''/'/g;
            print "<input type=hidden name=username value=$username>\n";
            print "<input type=hidden name=userid value=$userid>\n";
            print "<input type=hidden name=schema value=$schema>\n";
            print "<input type=hidden name=server value=$Server>\n";
            print "<input type=hidden name=city value=\"$city\">\n";
            print "<input type=hidden name=state value=\"$state\">\n";
            print "<input type=hidden name=country value=\"$country\">\n";
            print "<input type=hidden name=command value=\"lookupcommentors2\">\n";
            print "<input type=hidden name=id value=\"$documentid\">\n";
            print "<script language=javascript><!--\n";
            print "  parent.main.submitFormNewWindow('comment_documents','lookupcommentors2');\n";
            print "//--></script>\n";
        } else {
            print "<script language=javascript><!--\n";
            print "  parent.main.$form.submitreturn.value=true;\n";
            print "  parent.main.$form.submit();\n";
            print "//--></script>\n";
        }
    }

}


if ($command eq 'lookupcommentors2') {
    # get commentor data to help determine if it is a duplicate commentor ----------------------------------------------------------------------------------------------------------------
    $command = 'lookupcommentorsform';
    $lastname = $crdcgi->param('commentorlastname');
    $lastname =~ s/'/''/g;
    $firstname = ((defined($crdcgi->param('firstname'))) ? $crdcgi->param('firstname') : "");
    $firstname =~ s/'/''/g;
    $city = ((defined($crdcgi->param('city'))) ? $crdcgi->param('city') : "");
    $city =~ s/'/''/g;
    $state = ((defined($crdcgi->param('state'))) ? $crdcgi->param('state') : "");
    $country = ((defined($crdcgi->param('country'))) ? $crdcgi->param('country') : "");
    $sqlquery = "SELECT id,lastname,firstname,middlename,city,state,country FROM $schema.commentor WHERE UPPER(lastname)=UPPER('$lastname')";
    if (defined($firstname) && $firstname gt ' ') {
        $sqlquery .= " AND UPPER(firstname)=UPPER('$firstname')";
    }
    if (defined($city) && $city gt ' ') {
        $sqlquery .= " AND UPPER(city)=UPPER('$city')";
    }
    if (defined($state) && $state gt ' ') {
        $sqlquery .= " AND UPPER(state)=UPPER('$state')";
    }
    if (defined($country) && $country gt ' ') {
        $sqlquery .= " AND UPPER(country)=UPPER('$country')";
    }
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        $commentorarray[0][0] = "Similar Commentors in database";
        my $i=0;
        while (@values = $csr->fetchrow_array) {
            $i++;
            #$commentorarray[$i][0] = "C" . lpadzero($values[0],4);
            $commentorarray[$i][0] = $values[0];
            $commentorarray[$i][1] = ((defined($values[2])) ? $values[2] : "") . " " . ((defined($values[3])) ? $values[3] : "") . " $values[1]";
            $commentorarray[$i][2] = ((defined($values[4])) ? $values[4] : "");
            $commentorarray[$i][3] = ((defined($values[5])) ? $values[5] : "");
            $commentorarray[$i][4] = ((defined($values[6])) ? $values[6] : "");
        }
        $csr->finish;
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"check if there are any similar commentors (2).",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    }
}


if ($command eq 'doc_capture_enter') {
    # set up for initial data entry screen ----------------------------------------------------------------------------------------------------------------
    $documentid='';
    my $month = $crdcgi->param("datereceived_month");
    my $day = $crdcgi->param("datereceived_day");
    my $year = $crdcgi->param("datereceived_year");
    if (defined($month) && defined($day) && defined($year)) {
        $datereceived="$month/$day/$year";
    } else {
        $datereceived='today';
    }
    $namestatus=1;
    $lastname = '';
    $documenttype=1;
    $email='';
    $organization = '';
    $pagecount=1;
    #$addressee='Wendy Dixon';
    eval {
        $addressee=get_value($dbh, $schema,'addressee','name','grouporder=1');
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get default addressee.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    }
    $hasenclosures='F';
    $isillegible='F';
    $remarks='';
    $command = 'doc_cap_entry_form';

}


if ($command eq 'doc_capture_update') {
    # set up for initial data update screen ----------------------------------------------------------------------------------------------------------------
    $command = 'doc_capture_update_form';

}


if ($command eq 'doc_cap_update') {
    # set up for initial data update screen ----------------------------------------------------------------------------------------------------------------
    $newid = ((defined($crdcgi->param('newid'))) ? $crdcgi->param('newid') : 0) - 0;
    $sqlquery = "SELECT id,enteredby2 from $schema.document_entry WHERE id = $newid";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"check if $CRDType" . lpadzero($newid,6) . " is in entry table for update.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    } else {
        if ($#values >= 1) {
            if (defined($values[1]) && $values[1] gt ' ') {
                $message = "Document no longer available for update";
            } else {
                $urllocation = $path . "comment_documents.pl?username=$username&userid=$userid&schema=$schema&id=$newid&command=doc_cap_update2";
            }
        } else {
            $message = "Document not in entry table";
        }
    }
}


if ($command eq 'doc_cap_update2') {
    # set up for initial data update screen ----------------------------------------------------------------------------------------------------------------
    $documentid = lpadzero($documentid,6);
    $datereceived='today';
    $namestatus=1;
    $lastname = '';
    $documenttype=1;
    $email='';
    $organization = '';
    $pagecount=1;
    $enclosurepagecount=0;
    #$addressee='Wendy Dixon';
    eval {
        $addressee=get_value($dbh, $schema,'addressee','name','grouporder=1');
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get default addressee.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    }
    $hasenclosures='F';
    $isillegible='F';
    $remarks='';
    $command = 'doc_cap_update_form';
    $enteredby1=0;
    $entrydate1='';
    $commentorid=0;
    $sqlquery = "SELECT id,documenttype,TO_CHAR(datereceived,'MM/DD/YYYY'),enteredby1,entrydate1,entryremarks1,hasenclosures,isillegible,pagecount,addressee,namestatus,commentor,enclosurepagecount FROM $schema.document_entry WHERE id = $documentid";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
        if ($status) {
            $documenttype=$values[1];
            $datereceived=$values[2];
            $enteredby1=$values[3];
            $entrydate1=$values[4];
            $remarks=$values[5];
            $hasenclosures=$values[6];
            $isillegible=$values[7];
            $pagecount=$values[8];
            $addressee=$values[9];
            $namestatus=$values[10];
            $commentorid=$values[11];
            $enclosurepagecount=$values[12];

            if ($namestatus == 1) {
                $sqlquery = "SELECT id,lastname,email,organization FROM $schema.commentor_entry WHERE id = $commentorid";
                $csr = $dbh->prepare($sqlquery);
                $status = $csr->execute;
                @values = $csr->fetchrow_array;
                $csr->finish;
                if ($status) {
                    $lastname = $values[1];
                    $email=((defined($values[2])) ? $values[2] : "");
                    $organization=((defined($values[3])) ? $values[3] : "");
                }
            }
        } else {
            $message = "Error, $CRDType" . lpadzero($newid,6) . " not in entry table.";
            $urllocation = $path . "home.pl?username=$username&userid=$userid&schema=$schema";
        }

    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"retrieve $CRDType" . lpadzero($newid,6) . " from entry table for update.",$@ . $sqlquery);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    } else {
    }

}


# Process initial form input
if ($crdcgi->param("command") eq "doc_cap_entry_action") {
    # process initial data entry ----------------------------------------------------------------------------------------------------------------
    my $document = $crdcgi->param("document");
    $namestatus = $crdcgi->param("namestatus");
    my $commentorname = ((defined($crdcgi->param("commentorname"))) ? $crdcgi->param("commentorname") : "");
    if(defined($commentorname)) {$commentorname =~ s/'/''/g;}
    my $doctype = $crdcgi->param("doctype");
    $email = ((defined($crdcgi->param("email"))) ? $crdcgi->param("email") : "");
    $organization = ((defined($crdcgi->param("organization"))) ? $crdcgi->param("organization") : "");
    if(defined($organization)) {$organization =~ s/'/''/g;}
    if(defined($email)) {$email =~ s/'/''/g;}
    $pagecount = $crdcgi->param("pagecount");
    $enclosurepagecount = $crdcgi->param("enclosurepagecount");
    $addressee = $crdcgi->param("addressee");
    if(defined($addressee)) {$addressee =~ s/'/''/g;}
    $hasenclosures = ((defined($crdcgi->param("hasenclosures"))) ? $crdcgi->param("hasenclosures") : "F");
    $isillegible = ((defined($crdcgi->param("isillegible"))) ? $crdcgi->param("isillegible") : "F");
    $remarks = ((defined($crdcgi->param("remarks"))) ? $crdcgi->param("remarks") : "");
    $datereceived_month = $crdcgi->param("datereceived_month");
    $datereceived_day = $crdcgi->param("datereceived_day");
    $datereceived_year = $crdcgi->param("datereceived_year");
    $datereceived = &get_date ("$datereceived_month/$datereceived_day/$datereceived_year");

    # generate query to see if document already exists in either table
    # make sql statement
    my $sqlquery = "select id  from $schema.document_entry where id = $document";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    };
    if ($#values < 0 && !($@)) {
        $sqlquery = "select id  from $schema.document where id = $document";
        eval {
            $csr = $dbh->prepare($sqlquery);
            $csr->execute;
            @values = $csr->fetchrow_array;
            $csr->finish;
        };
    }

    if ($#values >= 0 || $@) {
        $message = "Document $CRDType" . lpadzero($document,6) . " already exists";
    } else {
      my $remote_path = $CRDType . '_CD_Images\\Scanned';
      if (!($CRDProductionStatus)) {$remote_path = $CRDType . '_CD_Images\\DevScanned';}
      if (doesScannedImageFileExist(image_file => "$CRDType" . lpadzero($document,6) . ".pdf", remote_path => $remote_path) == 1) {
        my $commentor_id = 0;
        if ($namestatus eq "1") {
            # Insert commentor information --------------------------------------------------------------------------
            eval {
                $commentor_id = &get_next_commentor_id ($dbh, $schema);
                $sqlquery = "INSERT INTO $schema.commentor_entry (id, lastname, email, organization)  VALUES ('$commentor_id', '$commentorname', ";
                if ($email gt " ") {
                    $sqlquery .= "'$email', ";
                } else {
                    $sqlquery .= "NULL, ";
                }
                if ($organization gt " ") {
                    $sqlquery .= "'$organization')";
                } else {
                    $sqlquery .= "NULL)";
                }
                $csr = $dbh->prepare($sqlquery);
                $status = $csr->execute;
                # free up the generated 'cursor'
                $csr->finish;
                $dbh->commit;
            };

            if ($@) {
                $message = errorMessage($dbh,$username,$userid,$schema,"insert new commentor $commentorname/$commentor_id.",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            } else {
                $status = log_activity ($dbh, $schema, $userid, "Commentor id C" . lpadzero($commentor_id,4) . " created");
                $dbh->commit;
            }

        }
        # Insert Document information ----------------------------------------------------------------------------------
        if (($namestatus == 1 && $status) || $namestatus != 1) {
            $sqlquery = "INSERT INTO $schema.document_entry (id, documenttype, datereceived, enteredby1, entrydate1, dupsimstatus, hasenclosures, isillegible, pagecount, enclosurepagecount, addressee, signercount, namestatus, commentor, entryremarks1) VALUES ('$document', '$doctype', '$datereceived', '$userid', SYSDATE, 1, '$hasenclosures', '$isillegible', '$pagecount', '$enclosurepagecount', '$addressee', 0, $namestatus, ";
            # insert document information
            if ($commentor_id == 0) {
                $sqlquery .= "NULL";
            } else {
                $sqlquery .= "$commentor_id";
            }
            if (defined($remarks) && $remarks le " ") {
                $sqlquery .= ", NULL)";
            } else {
                $sqlquery .= ", :remarks)";
            }
            eval {
                $csr = $dbh->prepare($sqlquery);
                if (defined($remarks) && $remarks ge " ") {
                    $csr->bind_param(":remarks", $remarks, { ora_type => ORA_CLOB, ora_field=>'entryremarks1' });
                }
                # free up the generated 'cursor'
                $csr->execute;
                $csr->finish;
                $dbh->commit;
            };
            if ($dbh->err || $@) {
                $message = errorMessage($dbh,$username,$userid,$schema,"insert document data for $CRDType" . lpadzero($document,6) . ".",$@);
                $message =~ s/\n/\\n/g;
                $message =~ s/'/''/g;
            } else {

                eval {
                    $status = log_activity ($dbh, $schema, $userid, "Document id $document created");
                    $dbh->commit;
                };
                if ($@) {
                    $message = "Problem writing to database, please call tech support";
                }
            }

            if ($message eq '') {
                print "<input type=hidden name=command value=doc_capture_enter>\n";
                print "<input type=hidden name=datereceived_month value=$datereceived_month>\n";
                print "<input type=hidden name=datereceived_day value=$datereceived_day>\n";
                print "<input type=hidden name=datereceived_year value=$datereceived_year>\n";
                print "<input type=hidden name=username value=$username>\n";
                print "<input type=hidden name=userid value=$userid>\n";
                print "<input type=hidden name=schema value=$schema>\n";
                print "<input type=hidden name=server value=$Server>\n";
                print "<script language=javascript><!--\n";
                print "    submitForm('$form', 'doc_capture_enter');\n";
                print "//--></script>\n";
        #        $urllocation ="$ENV{SCRIPT_NAME}?username=$username&userid=$userid&schema=$schema&command=doc_capture_enter";
            }
        }
      } else {
            $message = "Scanned image for Document $CRDType" . lpadzero($document,6) . " does not exist.\\nDocument must be scanned before data can be input.";
      }
    }

}


if ($command eq 'doc_cap_update_action') {
    # process update screen for initial data entry ----------------------------------------------------------------------------------------------
    my $document = $crdcgi->param("document");
    $namestatus = $crdcgi->param("namestatus");
    my $commentorname = ((defined($crdcgi->param("commentorname"))) ? $crdcgi->param("commentorname") : "");
    if(defined($commentorname)) {$commentorname =~ s/'/''/g;}
    $commentorid = ((defined($crdcgi->param('commentorid'))) ? $crdcgi->param('commentorid') : 0);
    my $doctype = $crdcgi->param("doctype");
    $email = ((defined($crdcgi->param("email"))) ? $crdcgi->param("email") : "");
    $organization = ((defined($crdcgi->param("organization"))) ? $crdcgi->param("organization") : "");
    if(defined($organization)) {$organization =~ s/'/''/g;}
    if(defined($email)) {$email =~ s/'/''/g;}
    $pagecount = $crdcgi->param("pagecount");
    $enclosurepagecount = $crdcgi->param("enclosurepagecount");
    $addressee = $crdcgi->param("addressee");
    if(defined($addressee)) {$addressee =~ s/'/''/g;}
    $hasenclosures = ((defined($crdcgi->param("hasenclosures"))) ? $crdcgi->param("hasenclosures") : "F");
    $isillegible = ((defined($crdcgi->param("isillegible"))) ? $crdcgi->param("isillegible") : "F");
    $remarks = ((defined($crdcgi->param("remarks"))) ? $crdcgi->param("remarks") : "");
    $datereceived_month = $crdcgi->param("datereceived_month");
    $datereceived_day = $crdcgi->param("datereceived_day");
    $datereceived_year = $crdcgi->param("datereceived_year");
    $datereceived = &get_date ("$datereceived_month/$datereceived_day/$datereceived_year");

    eval {
        if ($document != $documentid) {
            # if document id has changed
            # generate query to see if new document already exists in either table
            # make sql statement
            $sqlquery = "select id  from $schema.document_entry where id = $document";
                $csr = $dbh->prepare($sqlquery);
                $csr->execute;
                @values = $csr->fetchrow_array;
                $csr->finish;
            if ($#values < 0) {
                $sqlquery = "select id  from $schema.document where id = $document";
                    $csr = $dbh->prepare($sqlquery);
                    $csr->execute;
                    @values = $csr->fetchrow_array;
                    $csr->finish;
            }
            if ($#values >= 0) {
                $message = "Can not change Document ID from $CRDType" . lpadzero($documentid,6) . " to $CRDType" . lpadzero($document,6) ."!\\nDocument ID already in use.";
            }
        }
        if ($message eq "") {
                # process commentor -------------------
                if ($namestatus != 1) {
                    if ($commentorid != 0) {
                        # delete commentor info ---------------------------
                    }
                } else {
                    if ($commentorid == 0) {
                        # insert new commentor into entry table --------------------
                        $commentorid = &get_next_commentor_id ($dbh, $schema);
                        $sqlquery = "INSERT INTO $schema.commentor_entry (id, lastname, email, organization)  VALUES ('$commentorid', '$commentorname', ";
                        if ($email gt " ") {
                            $sqlquery .= "'$email', ";
                        } else {
                            $sqlquery .= "NULL, ";
                        }
                        if ($organization gt " ") {
                            $sqlquery .= "'$organization')";
                        } else {
                            $sqlquery .= "NULL)";
                        }
                        $csr = $dbh->prepare($sqlquery);
                        $csr->execute;
                        # free up the generated 'cursor'
                        $csr->finish;
                        $dbh->commit;
                    } else {
                        # update commentor
                        $sqlquery = "UPDATE $schema.commentor_entry SET lastname='$commentorname', ";
                        if ($email gt " ") {
                            $sqlquery .= "email='$email', ";
                        } else {
                            $sqlquery .= "email=NULL, ";
                        }
                        if ($organization gt " ") {
                            $sqlquery .= "organization='$organization'";
                        } else {
                            $sqlquery .= "organization=NULL";
                        }
                        $sqlquery .= " WHERE id=$commentorid";
                        $csr = $dbh->prepare($sqlquery);
                        $csr->execute;
                        # free up the generated 'cursor'
                        $csr->finish;
                        $dbh->commit;
                    }
                }
                # process comment document -------------------------------
                $sqlquery = "UPDATE $schema.document_entry SET id=$document, documenttype=$doctype, datereceived='$datereceived',";
                if (defined($remarks) && $remarks ge " ") {
                    $sqlquery .= " entryremarks1=:remarks,"
                } else {
                    $sqlquery .= " entryremarks1=NULL,"
                }
                $sqlquery .= "hasenclosures='$hasenclosures', isillegible='$isillegible', addressee='$addressee', pagecount=$pagecount, enclosurepagecount=$enclosurepagecount, namestatus=$namestatus,";
                if ($namestatus == 1) {
                    $sqlquery .= "commentor=$commentorid";
                } else {
                    $sqlquery .= "commentor=NULL";
                }
                $sqlquery .= " WHERE id=$documentid";


                $csr = $dbh->prepare($sqlquery);
                if (defined($remarks) && $remarks ge " ") {
                    $csr->bind_param(":remarks", $remarks, { ora_type => ORA_CLOB, ora_field=>'entryremarks1' });
                }
                $csr->execute;
                # free up the generated 'cursor'
                $csr->finish;
                $dbh->commit;

                $message = "Update was successful";
                $urllocation = $path . "comment_documents.pl?username=$username&userid=$userid&schema=$schema&command=doc_capture_update";
                log_activity($dbh,$schema,$userid, "Updated document capture of $CRDType" . lpadzero($documentid,6) .".");
        }
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"update document $CRDType" . lpadzero($newid,6) . " from Document Capture",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    }

}


if ($command eq 'reportsetup' && $documentid eq 'doc_capture') {
    # set up for initial data list/report screen ----------------------------------------------------------------------------------------------------------------
    my $areerrors=0;
    $datecheck=get_date;
    $doselected= ((defined($crdcgi->param("doselected")) && $crdcgi->param("doselected") > 0) ? $doselected=$crdcgi->param("doselected") : 0);
    $startdate = get_date($crdcgi->param('report_date_start_month') . "/" . $crdcgi->param('report_date_start_day') . "/" . $crdcgi->param('report_date_start_year'));
    $enddate = get_date($crdcgi->param('report_date_end_month') . "/" . $crdcgi->param('report_date_end_day') . "/" . $crdcgi->param('report_date_end_year'));
    if (substr($startdate,1,1) eq '-') {$startdate = '0' . $startdate; }
    if (substr($enddate,1,1) eq '-') {$enddate = '0' . $enddate; }
    if ($doselected == 3) {
        $startid = ((defined($crdcgi->param('startid'))) ? $crdcgi->param('startid') : "");
        $endid = ((defined($crdcgi->param('endid'))) ? $crdcgi->param('endid') : "");
        if (($startid =~ /\D/) || $startid <=0) {
            $areerrors=1;
            $message .= "Start ID must be a positive integer number\\n";
        }
        if (($endid =~ /\D/) || $endid <=0) {
            $areerrors=1;
            $message .= "End ID must be a positive integer number\\n";
        }
        if ($startid > $endid) {
            $areerrors=1;
            $message .= "End ID must be a greater than or equal to Start ID\\n";
        }
    }
    if ($doselected == 4) {
        print "<input type=hidden name=command value=report>\n";
        print "<input type=hidden name=id value=$documentid>\n";
        print "<input type=hidden name=entrycountscounttype value=week>\n";
        print "<input type=hidden name=entrycountsbegindate value=19990101>\n";
        print "<input type=hidden name=entrycountsenddate value=30001231>\n";
        print "<input type=hidden name=username value=$username>\n";
        print "<input type=hidden name=userid value=$userid>\n";
        print "<input type=hidden name=schema value=$schema>\n";
        print "<input type=hidden name=server value=$Server>\n";
        print "<script language=javascript><!--\n";
        print "    submitFormNewWindow2('reports', 'report','EntryCountsReport');\n";
        print "//--></script>\n";

    } elsif (!($areerrors)) {
        print "<input type=hidden name=command value=reportgen>\n";
        print "<input type=hidden name=id value=$documentid>\n";
        print "<input type=hidden name=doselected value=$doselected>\n";
        print "<input type=hidden name=datecheck value=$datecheck>\n";
        print "<input type=hidden name=startdate value=$startdate>\n";
        print "<input type=hidden name=enddate value=$enddate>\n";
        print "<input type=hidden name=startid value=$startid>\n";
        print "<input type=hidden name=endid value=$endid>\n";
        print "<input type=hidden name=username value=$username>\n";
        print "<input type=hidden name=userid value=$userid>\n";
        print "<input type=hidden name=schema value=$schema>\n";
        print "<input type=hidden name=server value=$Server>\n";

        $sqlquery = "SELECT doc.id ";
        $sqlquery .= "FROM $schema.document_entry doc,$schema.commentor_entry com ";
        $sqlquery .= "WHERE ((doc.commentor=com.id(+)) AND (NVL(doc.enteredby2,-1) = -1))";
        if ($doselected == 1) {
            $sqlquery .= " AND (UPPER(TO_CHAR(doc.entrydate1,'DD-MON-YYYY')) = UPPER(TO_CHAR(TO_DATE('$datecheck'),'DD-MON-YYYY')))";
        }
        if ($doselected == 2) {
            $sqlquery .= " AND (TO_CHAR(doc.entrydate1,'YYYY-MM-DD') >= TO_CHAR(TO_DATE('$startdate'),'YYYY-MM-DD')) AND (TO_CHAR(doc.entrydate1,'YYYY-MM-DD') <= TO_CHAR(TO_DATE('$enddate'),'YYYY-MM-DD'))";
        }
        if ($doselected == 3) {
            $sqlquery .= " AND (doc.id >= $startid) AND (doc.id <= $endid)";
        }
        eval {
            $csr = $dbh->prepare($sqlquery);
            $status = $csr->execute;
            @values = $csr->fetchrow_array;
            $csr->finish;
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"determine the number of records returned from the data entry table.",$@);
            $message =~ s/\n/\\n/g;
            $message =~ s/'/''/g;
        } else {
            if (scalar(@values) < 1 || $values[0] < 1) {
                $message = "No records found matching selection.";
            } else {
                print "<script language=javascript><!--\n";
                print "    submitFormNewWindow('$form', 'reportgen');\n";
                print "//--></script>\n";
            }
        }
    }

}


if ($command eq 'doc_capture_view' || ($command eq 'reportgen' && $documentid eq 'doc_capture')) {
    # set up for initial data list/report screen ----------------------------------------------------------------------------------------------------------------
    $datecheck=get_date;
    if ($command eq 'reportgen') {
        $command = 'doc_capture_report_form';
        if (defined($crdcgi->param('currpagenumb'))) {
            $currpagenumb = $crdcgi->param('currpagenumb') + 1;
        } else {
            $currpagenumb = 1;
        }
    } else {
        $command = 'doc_capture_view_form';
    }
    $doselected=((defined($crdcgi->param("doselected"))) ? $crdcgi->param("doselected") : 0);
    if ($doselected == 2) {
        if (defined($crdcgi->param('startdate')) && $crdcgi->param('startdate') gt ' ') {
            $startdate = $crdcgi->param('startdate');
        } else {
            $startdate = get_date($crdcgi->param('report_date_start_month') . "/" . $crdcgi->param('report_date_start_day') . "/" . $crdcgi->param('report_date_start_year'));
            if (substr($startdate,1,1) eq '-') {$startdate = '0' . $startdate; }
        }
        if (defined($crdcgi->param('enddate')) && $crdcgi->param('enddate') gt ' ') {
            $enddate = $crdcgi->param('enddate');
        } else {
            $enddate = get_date($crdcgi->param('report_date_start_month') . "/" . $crdcgi->param('report_date_start_day') . "/" . $crdcgi->param('report_date_start_year'));
            if (substr($enddate,1,1) eq '-') {$enddate = '0' . $enddate; }
        }
    }
    if ($doselected == 3) {
        if (defined($crdcgi->param('startid')) && $crdcgi->param('startid') gt ' ') {
            $startid = $crdcgi->param('startid')
        }
        if (defined($crdcgi->param('endid')) && $crdcgi->param('endid') gt ' ') {
            $endid = $crdcgi->param('endid')
        }
    }

    $sqlquery = "SELECT doc.id,doc.documenttype,UPPER(TO_CHAR(doc.datereceived,'DD-MON-YYYY')),doc.enteredby1,doc.entrydate1,doc.entryremarks1, ";
    $sqlquery .= "doc.hasenclosures,doc.isillegible,doc.pagecount,doc.addressee,doc.namestatus,com.id,com.lastname,com.email,com.organization,doc.enclosurepagecount ";
    $sqlquery .= "FROM $schema.document_entry doc,$schema.commentor_entry com ";
    $sqlquery .= "WHERE ((doc.commentor=com.id(+)) AND (NVL(doc.enteredby2,-1) = -1))";
    if ($doselected == 0) {
        $sqlquery .= " ORDER BY doc.id";
    }
    if ($doselected == 1) {
        $sqlquery .= " AND (UPPER(TO_CHAR(doc.entrydate1,'DD-MON-YYYY')) = UPPER(TO_CHAR(TO_DATE('$datecheck'),'DD-MON-YYYY')))";
        $sqlquery .= " ORDER BY doc.id";
    }
    if ($doselected == 2) {
        $sqlquery .= " AND (TO_CHAR(doc.entrydate1,'YYYY-MM-DD') >= TO_CHAR(TO_DATE('$startdate'),'YYYY-MM-DD')) AND (TO_CHAR(doc.entrydate1,'YYYY-MM-DD') <= TO_CHAR(TO_DATE('$enddate'),'YYYY-MM-DD'))";
        $sqlquery .= " ORDER BY doc.entrydate1,doc.id";
    }
    if ($doselected == 3) {
        $sqlquery .= " AND (doc.id >= $startid) AND (doc.id <= $endid)";
        $sqlquery .= " ORDER BY doc.id";
    }
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        my $i =0;
        while (@values = $csr->fetchrow_array) {
            for (my $j=0; $j<=$#values; $j++) {
                $documentarray[$i][$j] = $values[$j];
            }
            if ($documentarray[$i][10] != 1) {
                $documentarray[$i][12] = get_value ($dbh, $schema, 'commentor_name_status', 'name', "id = $documentarray[$i][10]");
            }
            $i++;
        }
        $lastpage = scalar(@documentarray) / $pagelength + (((scalar(@documentarray) % $pagelength >=1) || $i ==0) ? 1 : 0);
        if ($lastpage == $currpagenumb) { $islastpage=1; }
        $startline = $pagelength * ($currpagenumb - 1);
        $endline = $startline + $pagelength -1;
        if ($endline > $#documentarray) {$endline = $#documentarray; }
        $csr->finish;
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"display comment documents in data entry table.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    }

}


if ($command eq 'doc_capture_browse') {
    # set up for initial data entry browse screen ----------------------------------------------------------------------------------------------------------------
    $command = 'doc_capture_browse_form';

    $sqlquery = "SELECT doc.id,doc.documenttype,UPPER(TO_CHAR(doc.datereceived,'DD-MON-YYYY')),doc.enteredby1,doc.entrydate1,doc.entryremarks1, ";
    $sqlquery .= "doc.hasenclosures,doc.isillegible,doc.pagecount,doc.addressee,doc.namestatus,com.id,com.lastname,com.email,com.organization,doc.enclosurepagecount ";
    $sqlquery .= "FROM $schema.document_entry doc,$schema.commentor_entry com ";
    $sqlquery .= "WHERE ((doc.commentor=com.id(+)) AND (NVL(doc.enteredby2,-1) = -1)) AND doc.id=$documentid";

    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
        $documentarray[0][0] = '<b>Selected Comment Document</b> &nbsp;<font size=-1>(<i>Click on ID to View Scanned Image</i>)</font>';
        $documentarray[1][0] = "<b>Comment Document ID </b>";
        $documentarray[1][1] = "<b><a href=javascript:document.$form.id.value=$values[0];submitFormCGIResults('display_image','scanned')>$CRDType" . lpadzero($values[0],6) . "</a></b>";
        $documentarray[2][0] = "<b>Date Received </b>";
        $documentarray[2][1] = "<b>" . $values[2] . "</b>";
        $documentarray[3][0] = "<b>Commentor Name Information &nbsp; </b>";
        $documentarray[3][1] = "<b>" . get_value($dbh,$schema,'commentor_name_status','name',"id=$values[10]") . "</b>";
        $documentarray[4][0] = "<b>Commentor Last Name </b>";
        $documentarray[4][1] = "<b>" . ((defined($values[12]) && ($values[12] gt ' ')) ? $values[12] : '&nbsp; ') . "</b>";
        $documentarray[5][0] = "<b>Type </b>";
        $documentarray[5][1] = "<b>" . get_value($dbh, $schema,'document_type','name', "id=$values[1]") . "</b>";
        $documentarray[6][0] = "<b>Commentor Email Address </b>";
        $documentarray[6][1] = "<b>" . ((defined($values[13]) && ($values[13] gt ' ')) ? $values[13] : '&nbsp; ') . "</b>";
        $documentarray[7][0] = "<b>Commentor Organization </b>";
        $documentarray[7][1] = "<b>" . ((defined($values[14]) && ($values[14] gt ' ')) ? $values[14] : '&nbsp; ') . "</b>";
        $documentarray[8][0] = "<b>Page Count </b>";
        $documentarray[8][1] = "<b>" . $values[8] . "</b>";
        $documentarray[9][0] = "<b>Addressee </b>";
        $documentarray[9][1] = "<b>" . $values[9] . "</b>";
        $documentarray[10][0] = "<b>Has Enclosures </b>";
        $documentarray[10][1] = "<b>" . $values[6] . "</b>";
        $documentarray[11][0] = "<b>Enclosure Page Count </b>";
        $documentarray[11][1] = "<b>" . $values[15] . "</b>";
        $documentarray[12][0] = "<b>Contains Illegible Text </b>";
        $documentarray[12][1] = "<b>" . $values[7] . "</b>";
        $documentarray[13][0] = "<b>Remarks </b>";
        $documentarray[13][1] = "<b>" . ((defined($values[5]) && ($values[5] gt ' ')) ? $values[5] : '&nbsp; ') . "</b>";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"browse a comment document in data entry table.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    }

}


if ($command eq 'test_for_bracketed') {
    # set up for viewing bracketed or scanned pdf images ----------------------------------------------------------------------------------------------------------------
    #$command = 'doc_capture_browse_form';

    $sqlquery = "SELECT count(*) FROM $schema.document WHERE id=$documentid AND image IS NOT NULL";

    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        print "<input type=hidden name=id value=$documentid>\n";
        print "<input type=hidden name=documentid value=$documentid>\n";
        print "<input type=hidden name=command value=' '>\n";
        print "<input type=hidden name=username value=$username>\n";
        print "<input type=hidden name=userid value=$userid>\n";
        print "<input type=hidden name=schema value=$schema>\n";
        print "<input type=hidden name=server value=$Server>\n";
        print "<script language=javascript><!--\n";
        $csr->finish;
        if ($#values >=0 && $values[0] >= 1) {
            # bracketed image is in table
            print "  ViewPDF($documentid);\n";
        } else {
            # bracketed image is not in table, use scanned image
            print "  document.comment_documents.id.value=$documentid;\n";
            #print "  alert ('Bracketed image is not available, Scanned image will be displayed')\n";
            print "  submitFormCGIResults('display_image','scanned');\n";
        }
        print "//--></script>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"test for a bracketed image.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
    }

}


#=============================================================================================================

# display any messages generated by the script
print "<script language=javascript><!--\n";
if (defined($message) && $message gt " ") {
    print "   alert('$message');\n";
}

# send the main frame to the requested url
if (defined ($urllocation) && $urllocation gt ' ') {
    # close connection to the oracle database
    db_disconnect($dbh);

    print "   var newurl ='$urllocation';\n";
    print "   parent.main.location=newurl;\n";

    # reset the cgiresults frame to a blank page to help avoid reprocessing of scripts
    #print "   location='" . $path . "blank.pl';\n";
}
print "//--></script>\n";

#=============================================================================================================

# use a hidden field to tell the next cgi what to do
# use hidden fields to keep track of the user.  Populate them with the username and the userid
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=server value=$Server>\n";
print "<input type=hidden name=id value=$documentid>\n";
print "<input type=hidden name=documentid value=$documentid>\n";
print "<input type=hidden name=lastname value=$lastname>\n";
print "<input type=hidden name=formname value=$form>\n";
print "<input type=hidden name=submitreturn value=0>\n";
print "<input type=hidden name=newwindow value=0>\n";

if ($command eq 'entry_form') {
    # entry form ---------------------------------------------------------------------------------------------------------------

    $command = 'getentry';
    print "<input type=hidden name=command value=$command>\n";

    $pagetitle = "Enter Comment Document";

    print <<END_OF_BLOCK;
<center>

<table border=0 width=750>


<tr><td align=center colspan=2>
<table border=0>
END_OF_BLOCK
    print "<tr><td align=left><b>Document Capture:</b>" . nbspaces(3) . "</td><td align=left><b>";
    print "<a href=\"javascript:DisplayUser($enteredby1)\"> ";
    eval {
        print get_fullname($dbh, $schema, $enteredby1) . "</a>" . nbspaces(3) . "on &nbsp;";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get a users full name.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print $entrydate1 . "</b></td></tr>\n";
    print <<END_OF_BLOCK;
<tr><td align=left><b>Show:</b>&nbsp;&nbsp;&nbsp; </td><td align=left><a href="javascript:DocsByCommentor()"><b>Submissions by Same Last Name</b></a></td></tr>
<tr><td align=left><b></b>&nbsp;&nbsp;&nbsp; </td><td align=left><a href=javascript:document.$form.id.value=$documentid;submitFormCGIResults('display_image','scanned')><b>Display Scanned Image</b></a></td></tr>
<tr><td align=left><b></b>&nbsp;&nbsp;&nbsp; </td><td align=left><!--<a href="javascript:newWindow3('$CRDDocPath/enter/postcard')">--><b>Postcard Samples</b><!--</a>--></td></tr>
</table></td></tr>
<tr><td align=center colspan=2><hr width=100% height=30></td></tr>

<tr><td colspan=2>&nbsp;<br></td></tr>

END_OF_BLOCK

    print "<tr><td><b>Comment Document ID:</b>" . nbspaces(3) . "</td><td><b>$CRDType</b><input name=newid type=text size=6 maxlength=6 value=" . lpadzero($documentid, 6) . "></td></tr>\n";

    print "<tr><td><b>Date Received:</b>&nbsp;&nbsp;</td><td>\n";

    print build_date_selection ('datereceived', $form, $datereceived);

    print "<tr><td><b>Type:</b></td><td>\n";
    eval {
        %lookup_values = &get_lookup_values($dbh, $schema, "document_type", "id", "name", "1=1 ORDER BY grouporder, id");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get document types.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print &build_drop_box ("doctype", \%lookup_values, $documenttype);
    print "</td></tr>\n";

    eval {
        %lookup_values = &get_lookup_values($dbh, $schema, "addressee a", "a.name", "a.name", "1=1 ORDER BY a.grouporder,a.name");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get addressee list.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print "<tr><td><b>Addressee:</b>&nbsp;&nbsp;</td><td>\n";
    my @lookup_array = (keys %lookup_values);
    print &build_select_from_piclist ("addressee", $form, \@lookup_array, 25, 1, 'true', 'false', 'true', 75, $addressee);
    print "</td></tr>\n";

    print "<tr><td><b>Page Count:</b></td><td><input type=text size=4 maxlength=5 name=pagecount value=$pagecount></td></tr>\n";

    print "<tr><td><b>Has Enclosures</b></td><td>";
    print "<input type=checkbox name=hasenclosures value='T'";
    if ($hasenclosures eq 'T') {
        print " checked";
    }
    print "></td></tr>\n";

    print "<tr><td><b>Enclosure Page Count:</b></td><td><input type=text size=4 maxlength=5 name=enclosurepagecount value=$enclosurepagecount></td></tr>\n";

    print "<tr><td><b>Has Illegible Text</b></td><td>\n";
    print "<input type=checkbox name=isillegible value='T'";
    if ($isillegible eq 'T') {
        print " checked";
    }
    print "></td></tr>\n";

    print "<tr><td><b>Cosigner Count:</b></td><td><input type=text size=5 maxlength=5 name=signercount value=0></td></tr>\n";

    print "<tr><td><b>Contains Comments related to:</b> </td>\n";
    print "<td><input type=checkbox name=hassrcomments value='T'><b>$CRDRelatedText</b> &nbsp;&nbsp;\n";
    print "<input type=checkbox name=haslacomments value='T'><b>License Application</b> &nbsp;&nbsp;\n";
    print "<input type=checkbox name=has96comments value='T'><b>960/963</b>\n";
    print "</td></tr>\n";

    print "<tr><td><b>This&nbsp;Document&nbsp;is&nbsp;IDENTICAL&nbsp;to:&nbsp;</b></td><td><b>$CRDType</b> &nbsp;<input type=text size=6 maxlength=6 name=dupsimdocid onBlur=\"checkDupID();\"> &nbsp; &nbsp; <input type=button name=checkid value=\"Check ID #\" onClick=\"checkDupID();\"></td></tr>\n";
    print "<tr><td valign=top><b>The two documents are from:</b> &nbsp; </td><td>\n";

    print "<input type=radio name=dupstatus value=2 onClick=\"if (isblank($form.dupsimdocid.value)) {this.checked = false;} else {return checkDupID();}\"><b>The same commentor</b> &nbsp; \n";
    print "<input type=radio name=dupstatus value=3 onClick=\"if (isblank($form.dupsimdocid.value)) {this.checked = false;} else {return checkDupID();}\"><b>Different commentors </b>\n";
    print "<!-- <input type=radio name=dupstatus value=4 onClick=\"if (isblank($form.dupsimdocid.value)) {this.checked = false;} else {return checkDupID();}\">Don't Know -->\n";
    print "</td></tr>\n";

    print "<tr><td colspan=2>&nbsp;<br></td></tr>\n";

    print "<tr><td colspan=2><h3>Commentor Information</h3></td></tr>\n";

    print "<tr><td><b>Name Information:</b> &nbsp</td><td>\n";
    eval {
        %lookup_values = get_lookup_values ($dbh, $schema, 'commentor_name_status', 'id', 'name');
        foreach  my $key (keys %lookup_values) { $lookup_values{$key} = "<b>" . $lookup_values{$key} . "</b>"; }
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get commentor name status.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print build_radio_block_wide('namestatus', \%lookup_values, $namestatus) . "</td></tr>\n";

    print "<input type=hidden name=commentorid value=$commentorid>\n";

    print "<tr><td><b>Commentor ID #</b> <b>" . ((defined($commentor)) ? "C" . lpadzero($commentor,4) : "") . "</b></td><td><b>Use Commentor ID # C</b><input type=text size=5 maxlength=5 name=newcommentorid value='" . ((defined($commentor)) ? $commentor : "") . "' onfocus=\"name_test(document.$form.namestatus, this);\"> &nbsp; \n";
    print "<input type=button name=commentorchecksubmit value='View' onClick=\"javascript:displayCommentor(document.$form.newcommentorid.value)\"></td></tr>\n";

    print "<tr><td><b>Title:</b></td><td><input type=text size=10 maxlength=25 name=title onfocus=\"name_test(document.$form.namestatus, this);\"></td>\n";
    print "<tr><td><b>First Name:</b></td><td><input type=text size=25 maxlength=25 name=firstname onfocus=\"name_test(document.$form.namestatus, this);\"></td>\n";
    print "<tr><td><b>Middle Name:</b></td><td><input type=text size=25 maxlength=25 name=middlename onfocus=\"name_test(document.$form.namestatus, this);\"></td>\n";
    print "<tr><td><b>Last Name:</b></td><td><input type=text size=25 maxlength=25 name=commentorlastname value=\"$lastname\" onfocus=\"name_test(document.$form.namestatus, this);\"></td>\n";
    print "<tr><td><b>Suffix</b></td><td><input type=text size=10 maxlength=10 name=suffix onfocus=\"name_test(document.$form.namestatus, this);\"></td>\n";

    print "<tr><td><b>Email Address:</b></td><td><input type=text size=25 maxlength=75 name=email value=\"" . ((defined($email)) ? $email : "") . "\" onfocus=\"name_test(document.$form.namestatus, this);\">&nbsp;</td></tr>\n";

    print "<tr><td><b>Organization:</b></td><td><input type=text size=25 maxlength=120 name=organization value=\"$organization\" onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>Position:</b></td><td><input type=text size=25 maxlength=75 name=position onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>Affiliation:</b></td><td>";
    eval {
        %lookup_values = &get_lookup_values($dbh, $schema, "commentor_affiliation", "id", "name");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get commentor affiliations.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print &build_drop_box ("affiliation", \%lookup_values, 1);
    print "</td></tr>\n";

    print "<tr><td><b>Street</b></td><td><input type=text size=50 maxlength=100 name=address onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>City</b></td><td><input type=text size=27 maxlength=40 name=city onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>State</b></td><td>";
    print build_states('NV');
    print "</td></tr>\n";

    print "<tr><td><b>Postal Code</b></td><td><input type=text size=9 maxlength=10 name=postalcode onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>Country</b></td><td>";
    print build_countries ('US');
    print "</td></tr>\n";

    print "<tr><td><b>Phone Number</b></td><td><input type=text size=3 maxlength=3 name=areacode onfocus=\"name_test(document.$form.namestatus, this);\"> - <input type=text size=7 maxlength=8 name=phonenumber onfocus=\"name_test(document.$form.namestatus, this);\">";
    print " &nbsp; <b>ext.</b> <input type=text size=4 maxlength=5 name=phoneextension onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>Fax Number</b></td><td><input type=text size=3 maxlength=3 name=faxareacode onfocus=\"name_test(document.$form.namestatus, this);\"> - <input type=text size=7 maxlength=8 name=faxnumber onfocus=\"name_test(document.$form.namestatus, this);\">";
    print " &nbsp; <b>ext.</b> <input type=text size=4 maxlength=5 name=faxextension onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print <<END_OF_BLOCK;
</table><table border=0>
<tr><td colspan=2>
END_OF_BLOCK

    if (defined($entryremarks1) && $entryremarks1 gt ' ') {
        print "<tr><td colspan=2>\n";
        print start_table(3, 'center', 120,130,400);
        print title_row('#cdecff','#000099',"Remarks on Document $CRDType" . lpadzero($documentid,6));
        print add_header_row() . add_col() . "Entered By" . add_col() . "Date" . add_col() . "Remark Text";

        eval {
            print add_row() . add_col_link("javascript:DisplayUser($enteredby1)") . get_fullname($dbh, $schema, $enteredby1);
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get a users full name.",$@);
            $message =~ s/\n/\\n/g;
            $message =~ s/'/''/g;
            print "<script language=javascript><!--\n";
            print "   alert('$message');\n";
            print "//--></script>\n";
        }
        print add_col() . $entrydate1 . add_col() . $entryremarks1;
        print end_table();
        print "</td></tr>\n";
    }

    print <<END_OF_BLOCK;

<tr><td colspan=2>&nbsp;</td></tr>

<tr><td colspan=2>
<b>Add Remarks</b>
END_OF_BLOCK
    print nbspaces(155);
    print <<END_OF_BLOCK;
<a href="javascript:expandTextBox(document.$form.remarks,document.remarks_button,'force',5);"><img name=remarks_button border=0 src=$CRDImagePath/expand_button.gif></a>
<br> <textarea name=remarks wrap=virtual rows=4 cols=90 onKeyPress="expandTextBox(this,document.remarks_button,'dynamic');"></textarea></td></tr>

<tr><td colspan=2>&nbsp;</td></tr>

<tr><td align=center colspan=2><b><i>Press the button below after all data entry is complete.
This will enter the comment document<br>record into the database and add it to the list of records awaiting proofreading.</i></b><br><br></td></tr>

<tr><td colspan=2 align=center><input type="submit" name="cdsubmit" value="Submit" onClick="resetSubmit('$command')"> </td></tr>

<tr><td colspan=2>&nbsp;</td></tr>

</table>

END_OF_BLOCK

}
#----------------------------------------------------------------------------------------------------------------


if ($command eq 'proofread_form') {
    # proofread form ---------------------------------------------------------------------------------------------------------------

    $command = 'getproofread';
    print "<input type=hidden name=command value=$command>\n";

    $pagetitle = "Proofread Comment Document";

    print <<END_OF_BLOCK;
<center>

<table border=0 width=750>

<tr><td align=center colspan=2>
<table border=0>
END_OF_BLOCK
    print "<tr><td align=left><b>Document Capture:</b>" . nbspaces(3) . "</td><td align=left><b>";
    print "<a href=javascript:DisplayUser($enteredby1)> ";
    eval {
        print get_fullname($dbh, $schema, $enteredby1) . "</a>" . nbspaces(3) . "on &nbsp;";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get a users full name.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print $entrydate1 . "</b></td></tr>\n";
    print "<tr><td align=left><b>Supplemental Data Entry:</b>" . nbspaces(3) . "</td><td align=left><b>";
    print "<a href=javascript:DisplayUser($enteredby2)> ";
    eval {
        print get_fullname($dbh, $schema, $enteredby2) . "</a>" . nbspaces(3) . "on &nbsp;";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get a users full name.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print $entrydate2 . "</b></td></tr>\n";

    print "<tr><td align=left><b>Show:</b>&nbsp;&nbsp;&nbsp; </td><td align=left><a href=\"javascript:DocsByCommentor()\"><b>Submissions by Same Last Name</b></a></td></tr>\n";
    print "<tr><td align=left><b></b>&nbsp;&nbsp;&nbsp; </td><td align=left><a href=javascript:document.$form.id.value=$documentid;submitFormCGIResults('display_image','scanned')><b>Display Scanned Image</b></a></td></tr>\n";
    print "<tr><td align=left><b></b>&nbsp;&nbsp;&nbsp; </td><td align=left><!--<a href=\"javascript:newWindow3('$CRDDocPath/enter/postcard')\">--><b>Postcard Samples</b><!--</a>--></td></tr>\n";
    print <<END_OF_BLOCK;
</table></td></tr>
<tr><td align=center colspan=2><hr width=100% height=30></td></tr>

<tr><td colspan=2>&nbsp;<br></td></tr>

END_OF_BLOCK

    print "<tr><td><b>Comment Document ID:</b>" . nbspaces(3) . "</td><td><b>$CRDType</b><input name=newid type=text size=6 maxlength=6 value=" . lpadzero($documentid, 6) . "></td></tr>\n";

    print "<tr><td><b>Date Received:</b>&nbsp;&nbsp;</td><td>\n";
    print build_date_selection ('datereceived', $form, $datereceived);

    print "<tr><td><b>Type:</b>&nbsp;&nbsp;</td><td>\n";
    eval {
        %lookup_values = &get_lookup_values($dbh, $schema, "document_type", "id", "name", "1=1 ORDER BY grouporder, id");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get document types.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print &build_drop_box ("doctype", \%lookup_values, $documenttype);
    print "</td></tr>\n";

    eval {
        %lookup_values = &get_lookup_values($dbh, $schema, "addressee a", "a.name", "a.name", "1=1 ORDER BY a.grouporder,a.name");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get addressee list.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print "<tr><td><b>Addressee:</b></td><td>\n";
    my @lookup_array = (keys %lookup_values);
    print &build_select_from_piclist ("addressee", $form, \@lookup_array, 25, 1, 'true', 'false', 'true', 75, $addressee);
    print "</tr></tr>";

    print "<tr><td><b>Page Count:</b></td><td><input type=text size=4 maxlength=5 name=pagecount value=$pagecount></td></tr>\n";

    print "<tr><td><b>Has Enclosures</b></td><td><input type=checkbox name=hasenclosures value='T'";
    if ($hasenclosures eq 'T') {
        print " checked";
    }
    print "></td></tr>\n";

    print "<tr><td><b>Enclosure Page Count:</b></td><td><input type=text size=4 maxlength=5 name=enclosurepagecount value=$enclosurepagecount></td></tr>\n";

    print "<tr><td><b>Has Illegible Text</b></td><td>";
    print "<input type=checkbox name=isillegible value='T'";
    if ($isillegible eq 'T') {
        print " checked";
    }
    print "></td></tr>\n";

    print "<tr><td><b>Cosigner Count:</b></td><td><input type=text size=5 maxlength=5 name=signercount value=$signercount></td></tr>\n";

    print "<tr><td><b>Contains Comments related to:</b> </td>\n";
    print "<td><input type=checkbox name=hassrcomments value='T'";
    if ($hassrcomments eq 'T'){
        print " checked";
    }
    print "><b>$CRDRelatedText</b> &nbsp;&nbsp;\n";
    print "<input type=checkbox name=haslacomments value='T'";
    if ($haslacomments eq 'T'){
        print " checked";
    }
    print "><b>License Application</b> &nbsp;&nbsp;\n";
    print "<input type=checkbox name=has96comments value='T'";
    if ($has960comments eq 'T'){
        print " checked";
    }
    print "><b>960/963</b></td></tr>\n";

    print "<tr><td><b>This Document is IDENTICAL to:</b></td><td><b>$CRDType</b> &nbsp;<input type=text size=6 maxlength=6 name=dupsimdocid value='" . ((defined($dupsimid) && $dupsimid >0) ? lpadzero($dupsimid,6) : "") . "' onBlur=\"checkDupID();\"> &nbsp; &nbsp; <input type=button name=checkid value=\"Check ID #\" onClick=\"checkDupID();\"></td></tr>\n";
    print "<tr><td valign=top><b>The two documents are from:</b></td><td>\n";
    print "<input type=radio name=dupstatus value=2". (($dupsimstatus == 2) ? " checked" : "") . " onClick=\"if (isblank($form.dupsimdocid.value)) {this.checked = false;} else {return checkDupID();}\"><b>The same commentor</b> &nbsp; \n";
    print "<input type=radio name=dupstatus value=3". (($dupsimstatus == 3) ? " checked" : "") . " onClick=\"if (isblank($form.dupsimdocid.value)) {this.checked = false;} else {return checkDupID();}\"><b>Different commentors </b>\n";
    #print "<input type=radio name=dupstatus value=4 onClick=\"if (isblank($form.dupsimdocid.value)) {this.checked = false;} else {return checkDupID();}\">Don't Know\n";
    print "</td></tr>\n";

    print "<tr><td colspan=2>&nbsp;</td></tr>\n";

    print "<tr><td colspan=2><h3>Commentor Information</h3></td></tr>\n";

    print "<tr><td><b>Name Information:</b> &nbsp</td><td>\n";
    eval {
        %lookup_values = get_lookup_values ($dbh, $schema, 'commentor_name_status', 'id', 'name');
        foreach  my $key (keys %lookup_values) { $lookup_values{$key} = "<b>" . $lookup_values{$key} . "</b>"; }
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get commentor name status.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print build_radio_block_wide('namestatus', \%lookup_values, $namestatus);
    print "</td></tr>\n";

    print "<tr><td colspan=2>&nbsp;<br></td></tr>\n";

    print "<tr><td><b>Commentor ID #</b> <b>" . ((defined($commentor)) ? "C" . lpadzero($commentor,4) : "") . "</b>\n";
    if (((defined($commentor)) ? $commentor : 0) != ((defined($newcommentorid)) ? $newcommentorid : 0)) {
        print " <font color=#ff0000>(Note: New Commentor)</font>";
    }
    print "</td><td valign=top><b>Use Commentor ID # C</b><input type=text size=5 maxlength=5 name=newcommentorid value='" . $newcommentorid . "' onfocus=\"name_test(document.$form.namestatus, this);\"> &nbsp; \n";
    print "<input type=button name=commentorchecksubmit value='View' onClick=\"javascript:displayCommentor(document.$form.newcommentorid.value)\"></td></tr>\n";

    print "<tr><td><b>Title:</b></td><td><input type=text size=10 maxlength=25 name=title value=\"" . ((defined($title)) ? $title : "") . "\" onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>First Name:</b></td><td><input type=text size=25 maxlength=25 name=firstname value=\"" . ((defined($firstname)) ? $firstname : "") . "\" onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>Middle Name:</b></td><td><input type=text size=25 maxlength=25 name=middlename value=\"" . ((defined($middlename)) ? $middlename : "") . "\" onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>Last Name:</b></td><td><input type=text size=25 maxlength=25 name=commentorlastname value=\"$lastname\" onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";
    print "<input type=hidden name=commentorid value=$commentorid>\n";

    print "<tr><td><b>Suffix:</b></td><td><input type=text size=10 maxlength=10 name=suffix value=\"" . ((defined($suffix)) ? $suffix : "") . "\" onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>Email Address:</b></td><td><input type=text size=25 maxlength=75 name=email value=\"" . ((defined($email)) ? $email : "") . "\" onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>Organization:</b></td><td><input type=text size=25 maxlength=120 name=organization value=\"" . ((defined($organization)) ? $organization : "") . "\" onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>Position:</b></td><td><input type=text size=25 maxlength=75 name=position value=\"" . ((defined($position)) ? $position : "") . "\" onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>Affiliation</b></td><td>";
    eval {
        %lookup_values = &get_lookup_values($dbh, $schema, "commentor_affiliation", "id", "name");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get commentor affiliations.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print &build_drop_box ("affiliation", \%lookup_values, $affiliation);
    print "</td></tr>\n";

    print "<tr><td><b>Street:</b></td><td><input type=text size=50 maxlength=100 name=address value=\"" . ((defined($address)) ? $address : "") . "\" onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>City:</b></td><td><input type=text size=27 maxlength=40 name=city value=\"" . ((defined($city)) ? $city : "") . "\" onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>State</b></td><td>" . build_states(((defined($state)) ? $state : "")) . "</td></tr>\n";

    print "<tr><td><b>Postal Code</b></td><td><input type=text size=9 maxlength=10 name=postalcode value=\"" . ((defined($postalcode)) ? $postalcode : "") . "\" onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>Country</b></td><td>" . build_countries (((defined($country)) ? $country : "")) . "</td></tr>\n";

    print "<tr><td><b>Phone Number</b></td><td>";
    print "<input type=text size=3 maxlength=3 name=areacode value='" . ((defined($areacode)) ? $areacode : "") . "' onfocus=\"name_test(document.$form.namestatus, this);\"> - <input type=text size=7 maxlength=8 name=phonenumber value='" . ((defined($phonenumber)) ? $phonenumber : "") . "' onfocus=\"name_test(document.$form.namestatus, this);\">\n";
    print "  &nbsp; <b>ext.</b> <input type=text size=4 maxlength=5 name=phoneextension value='" . ((defined($phoneextension)) ? $phoneextension : "") . "' onfocus=\"name_test(document.$form.namestatus, this);\">\n";
    print "</td></tr>\n";

    print "<tr><td><b>Fax Number</b></td><td>";
    print "<input type=text size=3 maxlength=3 name=faxareacode value='" . ((defined($faxareacode)) ? $faxareacode : "") . "' onfocus=\"name_test(document.$form.namestatus, this);\"> - <input type=text size=7 maxlength=8 name=faxnumber value='" . ((defined($faxnumber)) ? $faxnumber : "") . "' onfocus=\"name_test(document.$form.namestatus, this);\">\n";
    print "  &nbsp; <b>ext.</b> <input type=text size=4 maxlength=5 name=faxextension value='" . ((defined($faxextension)) ? $faxextension : "") . "' onfocus=\"name_test(document.$form.namestatus, this);\">\n";
    print "</td></tr>\n";

    print "</table>\n";

    print "<table border=0 width=750>\n";
    print "<tr><td colspan=3>\n";

    if ((defined($entryremarks1) && $entryremarks1 gt ' ') || (defined($entryremarks2) && $entryremarks2 gt ' ')) {
        print start_table(3, 'center', 120,130,400);
        print title_row('#cdecff','#000099',"Remarks on Document $CRDType" . lpadzero($documentid,6));
        print add_header_row() . add_col() . "Entered By" . add_col() . "Date" . add_col() . "Remark Text";

        eval {
            if (defined($entryremarks1) && $entryremarks1 gt ' ') {
                print add_row() . add_col_link("javascript:DisplayUser($enteredby1)") . get_fullname($dbh, $schema, $enteredby1);
                print add_col() . $entrydate1 . add_col() . $entryremarks1;
            }
            if (defined($entryremarks2) && $entryremarks2 gt ' ') {
                print add_row() . add_col_link("javascript:DisplayUser($enteredby2)") . get_fullname($dbh, $schema, $enteredby2);
                print add_col() . $entrydate2 . add_col() . $entryremarks2;
            } else {
                print " ";
            }
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"get a users full name.",$@);
            $message =~ s/\n/\\n/g;
            $message =~ s/'/''/g;
            print "<script language=javascript><!--\n";
            print "   alert('$message');\n";
            print "//--></script>\n";
        }
        print end_table();
    }

    print <<END_OF_BLOCK;

</td></tr>

<tr><td colspan=3>&nbsp;</td></tr>

<tr><td colspan=3>
<b>Add Remarks</b>
END_OF_BLOCK
    print nbspaces(155);
    print <<END_OF_BLOCK;
<a href="javascript:expandTextBox(document.$form.remarks,document.remarks_button,'force',5);"><img name=remarks_button border=0 src=$CRDImagePath/expand_button.gif></a>
<br> <textarea name=remarks wrap=virtual rows=4 cols=90 onKeyPress="expandTextBox(this,document.remarks_button,'dynamic');"></textarea></td></tr>

<tr><td colspan=3>&nbsp;</td></tr>

<tr><td align=center colspan=3><b><i>Press the button below after all data entry is complete.
This will enter the comment document<br>record into the database and add it to the list of records awaiting comment entry.</i></b><br><br></td></tr>

<tr><td colspan=3 align=center><input type="submit" name="cdsubmit" value="Submit" onClick="resetSubmit('$command')"> </td></tr>

<tr><td colspan=3>&nbsp;</td></tr>

</table>

END_OF_BLOCK

}
#----------------------------------------------------------------------------------------------------------------
if ($command eq "browse_form") {

        print "<center>\n";

        $pagetitle = "Browse Comment Document";

        print "<input type=hidden name=command value=browse1>\n";
        print "<b>Comment Document:</b> &nbsp; <b>$CRDType<input type=text name=newid size=6 maxlength=6> <input type=submit name=submitbrowse value=Retrieve>\n";
        print "<script language=javascript><!--\n";
        print "  document.$form.newid.focus();\n";
        print "//--></script>\n";

        print "</center>\n";

}


#----------------------------------------------------------------------------------------------------------------
if ($command eq "browse2_form" || $command eq "browse3_form") {

        print "<center>\n";

        if ($command eq "browse2_form") {
            print "<b>Comment Document:</b> &nbsp; <b>$CRDType<input type=text name=newid size=6 maxlength=6> <input type=submit name=submitbrowse value=Retrieve><br>\n";
            print "<script language=javascript><!--\n";
            print "  document.$form.newid.focus();\n";
            print "//--></script>\n";
            #print "<b>View Image:</b> &nbsp; <b><a href=\"javascript:ViewPDF($documentid)\">$CRDType" . lpadzero($documentid,6) . "</a></b><br>\n";
            #print "<b>Date Received:</b> &nbsp; <b>$datereceived</b><br>\n";
            print "<hr><br>\n";
        }
        $pagetitle = "Browse Comment Document";
        print "<input type=hidden name=command value=browse1>\n";

        print "<table border=0><tr><td valign=top align=center>\n";
        print gen_table (\@documentarray);
        print "</td><tr></table>\n";
        print "<table width=100%><tr><td>\n";

        print "<center><table border=0><tr><td>" . doRemarks(schema => $schema, dbh => $dbh, remark_type => 'document', document => $documentid, show_text_box => 0) . "</td><tr></table></center>";

        print "</td><tr></table>\n";
        print "</td><tr></table>\n";

        if ($command eq "browse3_form") {
            print "<br><a href=javascript:history.back()>Return to Previous Page</a>\n";
        }

        print "</center>\n";

}


#----------------------------------------------------------------------------------------------------------------
if ($command eq "update_form") {

        print "<center>\n";

        $pagetitle = "Update Comment Document";

        print "<input type=hidden name=command value=update1>\n";
        print "<b>Comment Document:</b> &nbsp; <b>$CRDType<input type=text name=newid size=6 maxlength=6> <input type=submit name=submitupdate value=Retrieve><br>\n";
        print "<script language=javascript><!--\n";
        print "  document.$form.newid.focus();\n";
        print "//--></script>\n";

        print "</center>\n";

}


#----------------------------------------------------------------------------------------------------------------
if ($command eq "update2_form") {

    $command = 'getupdate';
    print "<input type=hidden name=command value=$command>\n";

    $pagetitle = "Update Comment Document";

    print <<END_OF_BLOCK;
<center>

<table border=0 width=750>

<tr><td align=center colspan=2>
<table border=0>
END_OF_BLOCK
    print "<b>Comment Document:</b> &nbsp; <b>$CRDType<input type=text name=newid size=6 maxlength=6 value=" . lpadzero($documentid, 6) . "> <input type=submit name=submitupdate value=Retrieve onClick=\"document.$form.command.value='update1';\"><br>\n";
    print "<script language=javascript><!--\n";
    print "  document.$form.newid.focus();\n";
    print "//--></script>\n";
    print "<tr><td align=left><b>Document Capture:</b>" . nbspaces(3) . "</td><td align=left><b>";
    print "<a href=javascript:DisplayUser($enteredby1)> ";
    eval {
        print get_fullname($dbh, $schema, $enteredby1) . "</a>" . nbspaces(3) . "on &nbsp;";
        print $entrydate1 . "</b></td></tr>\n";
        print "<tr><td align=left><b>Supplemental Data Entry:</b>" . nbspaces(3) . "</td><td align=left><b>";
        print "<a href=javascript:DisplayUser($enteredby2)> ";
        print get_fullname($dbh, $schema, $enteredby2) . "</a>" . nbspaces(3) . "on &nbsp;";
        print $entrydate2 . "</b></td></tr>\n";
        print "<tr><td align=left><b>Proofread:</b>" . nbspaces(3) . "</td><td align=left><b>";
        print "<a href=javascript:DisplayUser($proofreadby)> ";
        print get_fullname($dbh, $schema, $proofreadby) . "</a>" . nbspaces(3) . "on &nbsp;";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get a users full name.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print $proofreaddate . "</b></td></tr>\n";
    print <<END_OF_BLOCK;
</table></td></tr>
<tr><td align=center colspan=2><hr width=100% height=30></td></tr>

<tr><td colspan=2>&nbsp;<br></td></tr>

END_OF_BLOCK

    print "<tr><td><b>Comment Document ID:</b></td><td><b>$CRDType" . lpadzero($documentid, 6) . "</b></td></tr>\n";

    print "<tr><td><b>Date Received:</b></td><td>\n";

    print build_date_selection ('datereceived', $form, $datereceived) . "</td></tr>\n";

    print "<tr><td><b>Type:</b></td><td>\n";
    eval {
        %lookup_values = &get_lookup_values($dbh, $schema, "document_type", "id", "name", "1=1 ORDER BY grouporder, id");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get document types.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print &build_drop_box ("doctype", \%lookup_values, ((defined($documenttype)) ? $documenttype : ""));
    print "</td></tr>\n";

    eval {
        %lookup_values = &get_lookup_values($dbh, $schema, "addressee a", "a.name", "a.name", "1=1 ORDER BY a.grouporder,a.name");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get addressee list.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print "<tr><td><b>Addressee:</b></td><td>\n";
    my @lookup_array = (keys %lookup_values);
    print &build_select_from_piclist ("addressee", $form, \@lookup_array, 25, 1, 'true', 'false', 'true', 75, $addressee);
    print "</td></tr>\n";

    print "<tr><td><b>Page Count:</b></td><td><input type=text size=4 maxlength=5 name=pagecount value=$pagecount></td></tr>\n";

    print "<tr><td><b>Has Enclosures:</b></td><td>";
    print "<input type=checkbox name=hasenclosures value='T'";
    if ($hasenclosures eq 'T') {
        print " checked";
    }
    print "></td></tr>\n";

    print "<tr><td><b>Enclosure Page Count:</b></td><td><input type=text size=4 maxlength=5 name=enclosurepagecount value=$enclosurepagecount></td></tr>\n";

    print "<tr><td><b>Has Illegible Text:</b></td><td>";
    print "<input type=checkbox name=isillegible value='T'";
    if ($isillegible eq 'T') {
        print " checked";
    }
    print "></td></tr>\n";

    print "<tr><td><b>Cosigner Count:</b></td><td><input type=text size=5 maxlength=5 name=signercount value=$signercount></td></tr>\n";

    print "<tr><td><b>Contains Comments related to:</b> </td><td>\n";
    print "<input type=checkbox name=hassrcomments value='T'";
    if ($hassrcomments eq 'T'){
        print " checked";
    }
    print "><b>$CRDRelatedText </b>&nbsp;&nbsp;\n";
    print "<input type=checkbox name=haslacomments value='T'";
    if ($haslacomments eq 'T'){
        print " checked";
    }
    print "><b>License Application</b>&nbsp;&nbsp;\n";
    print "<input type=checkbox name=has96comments value='T'";
    if ($has960comments eq 'T'){
        print " checked";
    }
    print "><b>960/963</b></td></tr>\n";

    print "<tr><td><b>This Document is IDENTICAL to:</b></td><td><b>$CRDType</b> &nbsp;<input type=text size=6 maxlength=6 name=dupsimdocid value='" . ((defined($dupsimid) && $dupsimid >0) ? lpadzero($dupsimid,6) : "") . "' onBlur=\"checkDupID();\"> &nbsp; &nbsp; <input type=button name=checkid value=\"Check ID #\" onClick=\"checkDupID();\"></td></tr>\n";
    print "<tr><td valign=top><b>The two documents are from: </b></td><td>\n";
    print "<input type=radio name=dupstatus value=2". (($dupsimstatus == 2) ? " checked" : "") . " onClick=\"if (isblank($form.dupsimdocid.value)) {this.checked = false;} else {return checkDupID();}\"><b>The same commentor</b> &nbsp; \n";
    print "<input type=radio name=dupstatus value=3". (($dupsimstatus == 3) ? " checked" : "") . " onClick=\"if (isblank($form.dupsimdocid.value)) {this.checked = false;} else {return checkDupID();}\"><b>Different commentors</b> \n";
    #print "<input type=radio name=dupstatus value=4 onClick=\"if (isblank($form.dupsimdocid.value)) {this.checked = false;} else {return checkDupID();}\">Don't Know\n";
    print "<input type=hidden name=dupsimdocidsave value='" . ((defined($dupsimid) && $dupsimid >0) ? lpadzero($dupsimid,6) : "") . "'>";
    print "<input type=hidden name=dupstatussave value=$dupsimstatus>\n";
    print "</td></tr>\n";

    print "<tr><td><b>Document has been Rescanned,<br>Remarked, and Appended</b></td><td valign=top>";
    print "<input type=checkbox name=wasrescanned value='T'";
    if ($wasrescanned eq 'T'){
        print " checked";
    }
    print "></td></tr>\n";
    
    eval {
        %lookup_values = ('0' => 'None Assigned', (get_lookup_values ($dbh, $schema, 'evaluation_factor', 'id', 'name', '1=1 ORDER BY id')));
        print "<tr><td><b>Evaluation Factor</b></td><td>";
        print &build_drop_box ("evaluationfactor", \%lookup_values,((defined($evaluationfactor)) ? $evaluationfactor : ""), "","");
        print "</td></tr>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get evaluation factor values.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }

    print "<tr><td><b>Commentor Name Information:<b> &nbsp</td><td>\n";
    eval {
        %lookup_values = get_lookup_values ($dbh, $schema, 'commentor_name_status', 'id', 'name');
        foreach  my $key (keys %lookup_values) { $lookup_values{$key} = "<b>" . $lookup_values{$key} . "</b>"; }
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get commentor name status values.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print build_radio_block_wide('namestatus', \%lookup_values, $namestatus) . "</td></tr>";

    print "<tr><td colspan=2>&nbsp;<br></td></tr>\n";

    print "</table>\n";

    print "<table border=0 cellpadding=1 width=750>\n";
    print "<tr><td colspan=2><hr><br></td></tr>\n";
    print "<tr><td valign=top>\n";

    print "<center>\n" . build_commentor_display($dbh,$schema,$namestatus,$commentorid) . "</center>\n";

    print "</td><td valign=top align=center>\n";

    print "<b>New Commentor ID: C</b><input type=text size=5 maxlength=5 name=newcommentorid onfocus=\"name_test(document.$form.namestatus, this);\"> &nbsp; \n";
    print "<input type=button name=commentorchecksubmit value='View' onClick=\"javascript:displayCommentor(document.$form.newcommentorid.value)\"><br>\n";
    print "<input type=hidden name=commentorid value=$commentorid>\n";
    print "<!--<a href=\"javascript:submitFormNewWindow('commentors', 'browse')\">--><b>Browse commentors in a new window</b><!--</a>-->\n";

    print "</td></tr>\n";
    print "</table>\n";

    print <<END_OF_BLOCK;
<table border=0 cellpadding=1 width=750>

<tr><td colspan=3>&nbsp;</td></tr>

<!--<tr><td colspan=3><b>Remarks</b> </td></tr>-->
<tr><td colspan=3>
<!--<table border=1 width=100% bgcolor=#ffffff>
<tr><td>-->
END_OF_BLOCK

    print "<center><table border=0><tr><td>" . doRemarks(schema => $schema, dbh => $dbh, remark_type => 'document', document => $documentid, show_text_box => 0) . "</td></tr></table></center>";

    print <<END_OF_BLOCK;

<!--<br><br></td></tr>
<!--</table>-->
</td></tr>

<tr><td colspan=3>&nbsp;</td></tr>

<tr><td colspan=3>
<b>Add Remarks</b>
END_OF_BLOCK
    print nbspaces(155);
    print <<END_OF_BLOCK;
<a href="javascript:expandTextBox(document.$form.remarks,document.remarks_button,'force',5);"><img name=remarks_button border=0 src=$CRDImagePath/expand_button.gif></a>
<br> <textarea name=remarks wrap=virtual rows=4 cols=90 onKeyPress="expandTextBox(this,document.remarks_button,'dynamic');"></textarea></td></tr>

<tr><td colspan=3>&nbsp;</td></tr>

<tr><td colspan=3 align=center><input type="submit" name="cdsubmit" value="Submit" onClick="resetSubmit('$command')"> </td></tr>

<tr><td colspan=3>&nbsp;</td></tr>

</table>

END_OF_BLOCK

}


#----------------------------------------------------------------------------------------------------------------
if ($command eq "lookupcommentorsform") {

        print "<center>\n";

        #$pagetitle = "Similar Commentors";

        print "<h2>Similar Commentors</h2>\n";

        print "<hr><br>\n";
        print "<input type=hidden name=command value=?>\n";
        print "<input type=hidden name=commentorid value=0>\n";
        print "<script language=javascript><!--\n";
        print "    document.$form.newwindow.value=1;\n";
        print "//--></script>\n";
        #print "<input type=hidden name=newwindow value=1>\n";
        print start_table (5, 'center');
        print title_row ('#ffc0ff', '#000000', $commentorarray[0][0]);
        print add_header_row;
        print add_col . "&nbsp;" . add_col . "Name/Id" . add_col . "City" . add_col . "State" . add_col . "Country";
        for (my $i=1; $i <= $#commentorarray; $i++) {
            print add_row;
            print add_col . "<center><input type=button name=selectC" . lpadzero($commentorarray[$i][0],4) . " value='Select C" . lpadzero($commentorarray[$i][0],4) . "' onclick=\"javascript:selectNewCommentor($commentorarray[$i][0])\"></center>";
            print add_col_link ("javascript:displayCommentor($commentorarray[$i][0])") . $commentorarray[$i][1] . "/C" . lpadzero($commentorarray[$i][0],4);
            print add_col . $commentorarray[$i][2] . add_col . $commentorarray[$i][3] . add_col . $commentorarray[$i][4];
        }
        print end_table . "<br>";
        print "<input type=button name=usecurrent value='None' onClick=\"javascript:processMainForm()\"><br><br>\n";

        print "<b><i>Review the displayed similar commentors to see if the commentor for the current comment document is a duplicate.  If the current commentor is a duplicate of one of the displayed commentors, use the 'Select' button to the left of the name of the duplicate.  If none of them are a duplicate, use the 'None' button to use the current commentor.</i></b>\n";

        print "</center>\n";

        print "<script language=javascript><!--\n";
        if ($#commentorarray >0) {
            print "  focus();\n";
            print "  if (opener.parent.main.$form.submitreturn == null) {\n";
            print "    alert('Error, lost connection to main window!\\nIf it does not close by itself,\\nplease close this window and then try again.');\n";
            print "    self.close();\n";
            print "    location='" . $path . "blank.pl';\n";
            print "  }\n";
        } else {
            print "  processMainForm();\n";
            print "  //location='" . $path . "blank.pl';\n";
            print "  opener.focus();\n";
            print "  self.close();\n";
        }
        print "//--></script>\n";
}


#----------------------------------------------------------------------------------------------------------------
if ($command eq "doc_capture_view_form") {

    $pagetitle = "Document Capture Browse";

    print "<input type=hidden name=command value=$command>\n";
    print start_table(5, 'center');
    print title_row('#ffc0ff', '#000099', '<b>Entered Comment Documents <font size=-1>(<i>Click on ID to View Details</i>)</font></b>');
    print add_header_row;
    print add_col . "<b>Doc ID</b>" . add_col . "<b>Date Received</b>" . add_col . "<b>From</b>" . add_col . "<b>Page Count</b>" . add_col . "Supplemental Material/Pages";
    for (my $i =0; $i <= $#documentarray; $i++) {
        print add_row . add_col_link("javascript:document.$form.id.value=$documentarray[$i][0];submitForm('$form','doc_capture_browse')") . "$CRDType" . lpadzero($documentarray[$i][0], 6) . add_col . $documentarray[$i][2];
        print add_col . $documentarray[$i][12];
        print  add_col . $documentarray[$i][8] . add_col . $documentarray[$i][6], " / " . $documentarray[$i][15];
    }
    print end_table;

}


#----------------------------------------------------------------------------------------------------------------
if ($command eq "doc_capture_browse_form") {

    print "<center>\n";
    $pagetitle = "Document Capture Browse";
    print "<input type=hidden name=command value=$command>\n";
    print start_table(2,'center',200,550);
    print title_row('#ffcoff', '#000099', $documentarray[0][0]);
    for (my $i=1; $i<=$#documentarray; $i++) {
        print add_row . add_col . $documentarray[$i][0] . add_col . $documentarray[$i][1];
    }
    print end_table;

    print "<br><a href=javascript:history.back()>Return to Previous Page</a>\n";
    print "</center>\n";

}


#----------------------------------------------------------------------------------------------------------------
if ($command eq "report") {

    if ($documentid eq "doc_capture") {
        print "<center>\n";
        $pagetitle = "Document Capture Report";
        print "<h4><i>Report will only include documents that have been processed<br>by Document Capture but not by Supplemental Data Entry.<br>(Prints Landscape - select File/Page Setup... and Landscape option)</i></h4>\n";
        print "<input type=hidden name=command value=reportsetup>\n";
        print "<script language=javascript><!--\n";
        print "    document.$form.id.value='doc_capture';\n";
        print "//--></script>\n";
        # get initial data for form ------------------------------------------
        $sqlquery = "SELECT MIN(id), MAX(id), TO_CHAR(MIN(entrydate1),'MM/DD/YYYY'), TO_CHAR(MAX(entrydate1),'MM/DD/YYYY') FROM $schema.document_entry WHERE NVL(enteredby2,0) = 0";
        eval {
            $csr = $dbh->prepare($sqlquery);
            $status = $csr->execute;
            @values = $csr->fetchrow_array;
            $csr->finish;
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"select max and min data for document capture report setup screen",$@);
            $message =~ s/\n/\\n/g;
            $message =~ s/'/''/g;
            print "<script language=javascript><!--\n";
            print "   alert('$message');\n";
            print "//--></script>\n";
        }
        print "<table border=0 align=center cellspacing=1 cellpadding=0>\n";
        print "<tr><td><b>Include Documents:</b></td></tr>\n";
        print "<tr><td>&nbsp;</td></tr>\n";
        print "<tr><td>\n";
        print "<table border=0 cellspacing=1 cellpadding=0><tr><td><input type=radio name=doselected value=1 checked> &nbsp; <b>Entered Today</b><br></td></tr></table>\n";
        print "</td></tr>\n";
        print "<tr><td>&nbsp;</td></tr>\n";
        print "<tr><td>\n";
        print "<table border=0 cellspacing=1 cellpadding=0><tr><td align=right><input type=radio name=doselected value=2> &nbsp; <b>Entered between</b> &nbsp; </td><td>" . build_date_selection ('report_date_start', $form, $values[2]) . "</td></tr>\n";
        print "<tr><td align=right><b>and</b> &nbsp; </td><td>" . build_date_selection ('report_date_end', $form, $values[3]) . " <b>inclusive</b></td></tr></table>\n";
        print "</td></tr>\n";
        print "<tr><td>&nbsp;</td></tr>\n";
        print "<tr><td>\n";
        print "<table border=0 cellspacing=1 cellpadding=0><tr><td align=right><input type=radio name=doselected value=3> &nbsp; <b>With Document ID's between</b> &nbsp; </td><td><input type=text size=6 maxlength=6 name=startid value=$values[0]></td></tr>\n";
        print "<tr><td align=right><b>and</b> &nbsp; </td><td><input type=text size=6 maxlength=6 name=endid value=$values[1]> <b>inclusive</b></td></tr></table>\n";
        print "<tr><td>&nbsp;</td></tr>\n";
        print "</table>\n";
        print "<input type=submit name=report1submit value=\"Submit\">\n";
        print "<br><br>\n";
        print "<input type=hidden name=entrycountscounttype value=week>\n";
        print "<input type=hidden name=entrycountsbegindate value=19990101>\n";
        print "<input type=hidden name=entrycountsbegindate_year value=1999>\n";
        print "<input type=hidden name=entrycountsbegindate_month value=01>\n";
        print "<input type=hidden name=entrycountsbegindate_day value=01>\n";
        print "<input type=hidden name=entrycountsenddate value=30001231>\n";
        print "<input type=hidden name=entrycountsenddate_year value=3000>\n";
        print "<input type=hidden name=entrycountsenddate_month value=12>\n";
        print "<input type=hidden name=entrycountsenddate_day value=31>\n";
        print "<hr><br>\n";
        print "<b>Summary Report of Documents Captured By Week &nbsp; </b>\n";
        print "<input type=button name=doccapcountssubmit value=\"Go\" onClick=\"submitFormCGIResults2('reports', 'report','EntryCountsReportTest');\">\n";
        print "</center>\n";

    } else {
        print "<b>Report ID: $documentid</b>\n";
    }

}


#----------------------------------------------------------------------------------------------------------------
if ($command eq "doc_capture_report_form") {

    print "<center>\n";
    print "<h2>Repository $CRDType<br>Public Comment Response Process</h2><h3>Mail Receipt Log</h3>\n";
    if ($doselected==1) {print "<h5>Report Selection Criteria - Entry Date: " . uc($datecheck) . "</h5>\n";}
    if ($doselected==2) {
        print "<h5>Report Selection Criteria - Entry Dates: " . uc($startdate) . " to " . uc($enddate) . "<br>\n";
    }
    if ($doselected==3) {
        print "<h5>Report Selection Criteria - Document ID's: $CRDType" . lpadzero($startid,6) . " to $CRDType" . lpadzero($endid,6) . "<br>\n";
    }
    print "<h4>Page $currpagenumb of $lastpage</h4>\n";
    print "<input type=hidden name=command value=$command>\n";
    print "<input type=hidden name=currpagenumb value=$currpagenumb>\n";
    print "<input type=hidden name=doselected value=$doselected>\n";
    print "<input type=hidden name=datecheck value=$datecheck>\n";
    print "<input type=hidden name=startdate value=$startdate>\n";
    print "<input type=hidden name=enddate value=$enddate>\n";
    print "<input type=hidden name=startid value=$startid>\n";
    print "<input type=hidden name=endid value=$endid>\n";
    #print "<table width=650 cellpadding=4 cellspacing=0 border=1 align=center>\n";
    print "<table width=900 cellpadding=4 cellspacing=0 border=1 align=center>\n";
    my $fontsize="-2";
    print "<tr bgcolor=#f0f0f0>\n";
    print "<td valign=bottom>" . "<font size=$fontsize><b>Doc ID</b></font>" . "</td><td valign=bottom>" . "<font size=$fontsize><b>Date Received</b></font>" . "</td><td valign=bottom>" . "<font size=$fontsize><b>From</b></font>" . "</td><td valign=bottom>" . "<font size=$fontsize><b>Page<br>Count</b></font>" . "</td><td valign=bottom>" . "<font size=$fontsize><b>Supplemental<br>Material/Pages</b></font>" . "</td><td valign=bottom>" . "<font size=$fontsize><b>Document<br>Type</b></font>" . "</td><td valign=bottom>" . "<font size=$fontsize><b>Organization</b></font>" . "</td></tr>\n";
    for (my $i =$startline; $i <= $endline; $i++) {

        print "<tr><td>" . "<font size=$fontsize>$CRDType" . lpadzero($documentarray[$i][0], 6) . "</font></td><td><font size=$fontsize>" . $documentarray[$i][2];
        print "</font></td><td><font size=$fontsize>" . $documentarray[$i][12];
        print "</font></td><td><font size=$fontsize>" . $documentarray[$i][8] . "</td><td><font size=$fontsize>" . $documentarray[$i][6] . " / " . $documentarray[$i][15];
        print "</font></td><td><font size=$fontsize>" . get_value($dbh,$schema, 'document_type', 'name', "id=$documentarray[$i][1]");
        print "</font></td><td><font size=$fontsize>" . ((defined($documentarray[$i][14])) ? getDisplayString($documentarray[$i][14],50) : "&nbsp;") . "</font></td></tr>\n";
    }
    print "</table>\n";
    if ($islastpage) {
            print "<br><table border=0>\n";
            print "<tr><td valign=top><b>Sent by:</b></td><td valign=top>&nbsp;</td></tr>\n";
            print "<tr><td valign=top><b>Document Capture ______________________________</b><br><center><b>" . nbspaces(44) . "Name</b></center></td><td valign=top align=right><b>Date: __________</b></td></tr>\n";
            print "<tr><td valign=top><b>Received by:</b></td><td valign=top>&nbsp;</td></tr>\n";
            print "<tr><td valign=top><b>$CRDType Contractor ______________________</b><br><center><b>Name</b></center></td><td valign=top><b>Contents Verified: __________</b><br><center><b>" . nbspaces(32) . "Initial</b></center></td></tr>\n";
            print "</table>\n";
    } else {
        print "<br><br><a href=\"javascript:submitFormNewWindow('$form','reportgen');\"><i>Next Page</i></a>\n";
    }
    print "</center>\n";

}


#----------------------------------------------------------------------------------------------------------------
if ($command eq "doc_capture_update_form") {

    $pagetitle = "Document Capture Update";

    print "<tr><td colspan=4><center><b>Comment Document:</b> &nbsp; <b>$CRDType<input type=text name=newid size=6 maxlength=6 value=";
    print "> <input type=submit name=submitgetupdate value=Retrieve></center></td></tr>\n";
    print "<input type=hidden name=command value=\"doc_cap_update\">\n";
    print "<script language=javascript><!--\n";
    print "  document.$form.newid.focus();\n";
    print "//--></script>\n";

}


#----------------------------------------------------------------------------------------------------------------
if ($command eq "doc_cap_entry_form" || $command eq "doc_cap_update_form") {
    # use a hidden field to tell the next cgi what to do
    if ($command eq "doc_cap_entry_form") {
        print "<input type=hidden name=command value=\"doc_cap_entry_action\">\n";
    } elsif ($command eq "doc_cap_update_form") {
        print "<input type=hidden name=command value=\"doc_cap_update_action\">\n";
        print "<input type=hidden name=enteredby1 value=\"$enteredby1\">\n";
        print "<input type=hidden name=entrydate1 value=\"$entrydate1\">\n";
        print "<input type=hidden name=commentorid value=\"" . ((defined($commentorid)) ? $commentorid : "") . "\">\n";
    }


    print "<center>\n";
    print "<table border=0 width=750>\n";

    $pagetitle = "Document Capture Entry";
    if ($command eq "doc_cap_update_form") {
        $pagetitle = "Document Capture Update";
    }
    if ($command eq "doc_cap_update_form") {
        print "<tr><td colspan=2><center><b>Comment Document:</b> &nbsp; <b>$CRDType<input type=text name=newid size=6 maxlength=6";
        print "> <input type=button name=submitgetupdate value=Retrieve onClick=\"document.$form.command.value='doc_cap_update';document.$form.submit();\"></center></td></tr>\n";
        print "<script language=javascript><!--\n";
        print "  document.$form.newid.focus();\n";
        print "//--></script>\n";
        print "<tr><td align=center colspan=2><hr width=100% height=30></td></tr>\n";

        print "<tr><td colspan=2>&nbsp;<br></td></tr>\n";

    }

    print "<table border=0 align=center>\n";
    print "<tr><td><b>Comment Document ID: &nbsp </b></td><td><b>$CRDType</b><input name=document type=text size=6 maxlength=6 value=$documentid></td></tr>\n";
    if ($command eq "doc_cap_entry_form") {
        print "<script language=javascript><!--\n";
        print "  document.$form.document.focus();\n";
        print "//--></script>\n";
    }
    print "<tr><td><b>Date Received:</b></td>\n";

    print "<td>" . &build_date_selection("datereceived", "$form", $datereceived) . "</td></tr>\n";

    print "<tr><td><b>Type:</b> </td>\n";
    print "<td>\n";
    eval {
        %lookup_values = &get_lookup_values($dbh, $schema, "document_type", "id", "name", "1=1 ORDER BY grouporder, id");
    };
    if ($@) {
        $message = "Problem reading from the database, please call tech support";
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print &build_drop_box ("doctype", \%lookup_values, $documenttype);
    print "</td></tr>\n";

    print "<tr><td><b>Addressee:</b> </td><td>\n";
    eval {
        %lookup_values = &get_lookup_values($dbh, $schema, "addressee a", "a.name", "a.name", "1=1 ORDER BY a.grouporder,a.name");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"get addressee list.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    my @lookup_array = (keys %lookup_values);
    print &build_select_from_piclist ("addressee", $form, \@lookup_array, 25, 1, 'true', 'false', 'true', 75, ((defined($addressee)) ? $addressee : ""));
    print "</td></tr>\n";

    print "<tr><td><b>Page Count: </b></td>";
    print "<td><input type=text size=5 maxlength=5 name=pagecount value=$pagecount></td></tr>\n";

    print "<tr><td><b>Has Enclosures:</b></td><td><input type=checkbox name=hasenclosures value=\"T\"" . ((defined($hasenclosures) && $hasenclosures eq 'T') ? ' checked' : ' ') . "></td></tr>\n";

    print "<tr><td><b>Enclosure Page Count: </b></td>\n";
    print "<td valign=top><input type=text size=5 maxlength=5 name=enclosurepagecount value=$enclosurepagecount></td></tr>\n";

    print "<tr><td><b>Contains Illegible Text:</b></td><td><input type=checkbox name=isillegible value=\"T\"" . ((defined($isillegible) && $isillegible eq 'T') ? ' checked' : ' ') . "></td></tr>\n";

    print "<tr><td colspan=2>&nbsp;<br></td></tr>\n";

    print "<tr><td valign=top><b>Commentor Name Information: &nbsp</td><td valign=top>\n";
    eval {
        %lookup_values = get_lookup_values ($dbh, $schema, 'commentor_name_status', 'id', 'name');
        foreach  my $key (keys %lookup_values) { $lookup_values{$key} = "<b>" . $lookup_values{$key} . "</b>"; }
    };
    if ($@) {
        $message = "Problem reading from the database, please call tech support";
        print "<script language=javascript><!--\n";
        print "   alert('$message');\n";
        print "//--></script>\n";
    }
    print build_radio_block_wide('namestatus', \%lookup_values, $namestatus);

    print "<tr><td colspan=2><b>Commentor</b></td></tr>\n";

    print "<tr><td><b>Last Name:</b> </td>\n";
    print "<td><input type=text size=25 name=\"commentorname\" maxlength=25 value=\"$lastname\" onfocus=\"name_test(document.$form.namestatus, this);\"></td></tr>\n";

    print "<tr><td><b>Email Address: </b></td>\n";
    print "<td valign=top><input type=text size=25 maxlength=75 name=email onfocus=\"name_test(document.$form.namestatus, this);\" value=\"$email\"></td></tr>\n";

    print "<tr><td><b>Organization: </b></td>\n";
    print "<td valign=top><input type=text size=25 maxlength=120 name=organization onfocus=\"name_test(document.$form.namestatus, this);\" value=\"$organization\"></td>\n";

    print "<tr><td colspan=2>&nbsp;<br></td></tr>\n";

    print "<tr><td colspan=2>";
    print "<table border=0 cellpadding=0 cellspacing=0><tr><td>\n";
    print "<b>Add Remarks</b> ";
    print nbspaces(135);
    print "<a href=\"javascript:expandTextBox(document.$form.remarks,document.remarks_button,'force',5);\"><img name=remarks_button border=0 src=$CRDImagePath/expand_button.gif></a>\n";
    print "</td></tr>\n";
    print "<tr><td><textarea name=remarks wrap=virtual rows=4 cols=80 onKeyPress=\"expandTextBox(this,document.remarks_button,'dynamic');\">" . ((defined($remarks)) ? $remarks : "") . "</textarea></td></tr>\n";
    print "</table></td></tr>\n";

    print "</table>\n";

    print "<tr><td>&nbsp;</td></tr>\n";
    print "<tr><td align=center>\n";
    if ($command eq "doc_cap_update_form") {
        print "<i><b>Press the button below after all data updates are completed.<br>\n";
        print "This will enter the comment document record into the\n";
        print "database and send it to the data entry team.</b></i><br><br>\n";
    } else {
        print "<i><b>Press the button below after all data entry is complete.<br><br>\n";
    }
    print "<input type=button name=\"doc_cap_submit\" value=\"Submit\" onClick=\"doVerifySubmit(document.$form);\"> \n";
    print "</td></tr>\n";
    print "</table>\n";
    print "</center>\n";
}



# close form for page
print "</form>\n";

# close table for whole page
print "</td></tr></table>\n";

# make submitform
print "<form name=submit$form>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=server value=$Server>\n";
print "<input type=hidden name=documentid value=$documentid>\n";
print "<input type=hidden name=lastname value=$lastname>\n";
print "<input type=hidden name=formname value=$form>\n";
print "<input type=hidden name=submitreturn value=0>\n";
print "<input type=hidden name=id value=0>\n";
print "<input type=hidden name=command value=0>\n";
print "<input type=hidden name=newwindow value=1>\n";
print "</form>\n";

if ($pagetitle gt "" && $command ne "reportgen") {
    # show user and database on top of every screen...
    print  &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $pagetitle);
}

# end font attributes for page
print "</font>\n";

# close connection to the oracle database
db_disconnect($dbh);

print $crdcgi->end_html;

