#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/crd/perl/RCS/commentors.pl,v $
#
# $Revision: 1.46 $
#
# $Date: 2002/02/20 16:39:51 $
#
# $Author: atchleyb $
#
# $Locker:  $
# 
# $Log: commentors.pl,v $
# Revision 1.46  2002/02/20 16:39:51  atchleyb
# removed depricated function use named parameters and changed the html header
#
# Revision 1.45  2002/02/19 19:23:12  atchleyb
# fixed bug that would incorrectly select viewScannedPDF instead of viewPDF
#
# Revision 1.44  2001/11/07 00:12:17  atchleyb
# changed javascript submit functions to not reset values after submition
# changed alert box code to handle single quotes
#
# Revision 1.43  2001/09/12 16:45:14  atchleyb
# updated the javascript verification code testing phone and fax numbers
#
# Revision 1.42  2001/05/16 21:42:34  atchleyb
# added option to browse by organization
#
# Revision 1.41  2001/04/06 21:15:20  atchleyb
# added code for browse list that gives number of documents for each commentor
#
# Revision 1.40  2001/03/27 02:32:59  atchleyb
# fixed bug in leading C for commentor id's
#
# Revision 1.39  2001/03/19 17:27:34  atchleyb
# changed max width of organization in update screen to 120
#
# Revision 1.38  2001/03/19 17:20:23  atchleyb
# Changed display of commentor id to have a leading 'C' and left pad with zeros
# checned input of commentor ids to have a leading 'C'
#
# Revision 1.37  2000/12/22 19:51:41  atchleyb
# fixed bug in update that interpreted zip + 4 as first part minus second part.
#
# Revision 1.36  2000/12/07 23:36:23  atchleyb
# added code to handle multiple oracle servers
#
# Revision 1.35  2000/11/08 22:51:04  atchleyb
# fixed bug in browse that would not allow names with ' in them.
#
# Revision 1.34  2000/04/24 21:30:24  atchleyb
# modified to call display_image in CGIResults rathar than a new window
#
# Revision 1.33  2000/04/11 18:31:37  atchleyb
# changed display commentor to correctly test for a popup window
#
# Revision 1.32  2000/04/06 22:32:09  atchleyb
# modified to remove misc warnings
#
# Revision 1.31  2000/03/07 17:22:59  atchleyb
# modified display commentor to not try to update the page title when in a new window using a hidden variable "newwindow" value of 1
#
# Revision 1.30  2000/02/10 17:22:49  atchleyb
# removed form-verify.pl
#
# Revision 1.29  2000/01/14 23:35:02  atchleyb
# replaced all references to EIS with $crdtype
#
# Revision 1.28  1999/12/14 00:46:25  atchleyb
# Changed submit buttons into regular javascript buttons
#
# Revision 1.27  1999/11/12 23:44:15  atchleyb
# changed display commentor code to compact name and address data
#
# Revision 1.26  1999/11/09 23:38:19  atchleyb
# added function to display documents submitted by displayed commentor
#
# Revision 1.25  1999/11/09 17:20:35  atchleyb
# fixed problem in browse by letter where code was getting executed in cgiresults that shouldn't
#
# Revision 1.24  1999/11/05 00:29:10  atchleyb
# made changes for popup screens not to call writetitlebar function
#
# Revision 1.23  1999/11/04 15:46:09  mccartym
# title changes
#
# Revision 1.22  1999/10/28 00:04:49  atchleyb
# modified display documents for simular commentors to test for image and
# display scanned image if not loaded
#
# Revision 1.21  1999/10/27 21:28:25  atchleyb
# updated to use the new title bar
# minor formating changes
#
# Revision 1.20  1999/10/26 16:13:21  atchleyb
# got rid of some eronious error messages
#
# Revision 1.19  1999/10/25 23:40:09  atchleyb
# changed format on browse screens
# made first and last name one field on browse screens
#
# Revision 1.18  1999/10/22 23:29:24  atchleyb
# fixed minor bug in cgiresults proccessing that tried to go to the database after it was closed
#
# Revision 1.17  1999/10/22 22:40:34  atchleyb
# Added fuction to browse commentor by affiliation.
#
# Revision 1.16  1999/10/12 21:23:50  atchleyb
# added display by commentor number to browse screen.
# changed browse by letter to test in cgiresults
# formatting changes
#
# Revision 1.15  1999/10/02 00:00:52  atchleyb
# format changes
#
# Revision 1.13  1999/09/28 17:32:25  atchleyb
# added error message formating and added the unexcape function to error alerts
#
# Revision 1.12  1999/09/21 17:17:54  atchleyb
# added dash hadeling for phone and fax numbers
#
# Revision 1.11  1999/09/15 23:56:06  atchleyb
# switched order of state and postal code
#
# Revision 1.10  1999/08/25 18:11:47  atchleyb
# got rid of comment with hardcoded path
#
# Revision 1.9  1999/08/12 00:17:51  atchleyb
# fixed length problem on email in update
#
# Revision 1.8  1999/08/06 15:39:26  atchleyb
# changed states and countries to functions
#
# Revision 1.7  1999/08/05 22:40:11  atchleyb
# added display document image to display commentors with same last name
#
# Revision 1.6  1999/08/04 17:38:21  atchleyb
# added raise error and commits to eval blocks
# fixed problem with form values not in quotes
#
# Revision 1.5  1999/08/02 22:30:24  atchleyb
# updated error handling, now using errorMessage routine
#
# Revision 1.4  1999/08/02 02:47:37  mccartym
#  Reversed order of parameters on call to headerBar()
#
# Revision 1.3  1999/07/30 22:57:32  atchleyb
# removed hard coded paths
# replaced most links with form submits
#
# Revision 1.2  1999/07/22 21:27:09  atchleyb
# added headerBar function
#
# Revision 1.1  1999/07/22 17:10:40  atchleyb
# Initial revision
#
#

use integer;
use strict;
use CRD_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_Utilities_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI qw(param);

$| = 1;

my $crdcgi = new CGI;
my $userid = $crdcgi->param("userid");
my $username = $crdcgi->param("username");
my $schema = $crdcgi->param("schema");
# Set server parameter
my $Server = $crdcgi->param("server");
if (!(defined($Server))) {$Server=$CRDServer;}

&checkLogin ($username, $userid, $schema);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $command = $crdcgi->param("command");
my $id = $crdcgi->param("id");

my $message;
my $urllocation;
my $sqlquery;
my $sqlquery2;
my $csr;
my $csr2;
my @values;
my @values2;
my %lookup_values;
my @commentorarray;
my @documentsarray;
my $status;
my $letterlinks = '';

my $letter;
my $lastname;
my $firstname;
my $middlename;
my $title;
my $suffix;
my $address;
my $city;
my $state;
my $country;
my $postalcode;
my $areacode;
my $phonenumber;
my $phoneextension;
my $faxareacode;
my $faxnumber;
my $faxextension;
my $email;
my $organization;
my $position;
my $affiliation;
my $affiliationname;
my $pagetitle = "";


#=================================================================================================
# subroutines
#=================================================================================================

###################################################################################################################################
sub doAlertBox {
###################################################################################################################################
   my %args = (
      text => "",
      includeScriptTags => 'T',
      @_,
   );
   
   my $outputstring = '';
   $args{text} =~ s/\n/\\n/g;
   $args{text} =~ s/'/%27/g;
   if ($args{includeScriptTags} eq 'T') {$outputstring .= "<script language=javascript>\n<!--\n";}
   $outputstring .= "var mytext ='$args{text}';\nalert(unescape(mytext));\n";
   if ($args{includeScriptTags} eq 'T') {$outputstring .= "//-->\n</script>\n";}
   
   return ($outputstring);
   
}


###################################################################################################################################
sub build_states {
    # routine to build a selection box of states and set the current state to passed value
    my $state = $_[0];
    
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


sub display_documents {
    my %args = (
        @_,
    );
    my $outputstring = '';
    my $message = '';
    my $sqlquery;
    my $csr;
    my $status;
    my @values;
    my @values2;
    my $count = 0;
    my @row;
    
    eval {
        $sqlquery = "SELECT id,documenttype,TO_CHAR(datereceived,'DD-MON-YYYY'),enteredby1,entrydate1,enteredby2,entrydate2,proofreadby,proofreaddate,dupsimstatus,dupsimid,pagecount,addressee FROM $args{'schema'}.document WHERE commentor=$args{'commentor'} ORDER BY id";
        $csr = $args{'dbh'}->prepare($sqlquery);
        $status = $csr->execute;
        $outputstring .= "<input type=hidden name=id value=0>\n";
        $outputstring .= start_table(6,'center');
        while (@values = $csr->fetchrow_array) {
            if ($count ==0) {
                @values2 = $args{'dbh'}->selectrow_array("SELECT firstname, lastname FROM $args{'schema'}.commentor WHERE id=$args{'commentor'}");
                $outputstring .= title_row('#a0e0c0', '#000099', "Documents Submitted by " . ((defined($values2[0])) ? $values2[0] : "") . " " . ((defined($values2[1])) ? $values2[1] : "") . " - ID: C" . lpadzero($args{'commentor'},4) . " " . nbspaces(8) . "<font size=-1>(<i>Click on Doc ID to Display Document Information</i>)</font>");
                $outputstring .= add_header_row . add_col . "Doc ID" . add_col . "Image" . add_col . "Date Received" . add_col . "Addressee" . add_col . "Type" . add_col . "Pages";
                
            }
            $count++;
            $outputstring .= add_row;
            $outputstring .= add_col_link ("javascript:browseDocument($values[0])") . "$CRDType" . lpadzero($values[0],6);
            @row = $args{'dbh'}->selectrow_array("SELECT count(*) FROM $args{'schema'}.document WHERE id=$values[0] AND image IS NOT NULL");
            if ($row[0] > 0) {
                $outputstring .= add_col_link ("javascript:ViewPDF($values[0])") . "<i>pdf</i>" . add_col . $values[2];
            } else {
                $outputstring .= add_col_link ("javascript:ViewScannedPDF($values[0])") . "<i>pdf</i>" . add_col . $values[2];
            }
            $outputstring .= add_col . $values[12] . add_col . get_value($args{'dbh'},$args{'schema'}, 'document_type', 'name', "id=$values[1]") . add_col . $values[11];
            
        }
        $outputstring .= end_table;
        if ($count == 0) {
            $outputstring .= "No documents found for commentor";
        }
    };
    if ($@) {
        $message = errorMessage($args{'dbh'},$args{'userName'},$args{'userId'},$args{'schema'},"display documents for commentor id $args{'commentor'}.",$@);
        $outputstring .= doAlertBox( text => $message);
    }
    
    return ($outputstring);
}

#=======================================================================================================================================
    

print $crdcgi->header('text/html');
print <<END_OF_BLOCK;
<html>
<head>
   <script src=$CRDJavaScriptPath/utilities.js></script>
   <script src=$CRDJavaScriptPath/widgets.js></script>
<script language=javascript><!--

function verify_$form (f){
// javascript form verification routine
  var msg = "";
  if (f.command.value == 'update3') {
    var phone = f.phonenumber.value;
    var fax = f.faxnumber.value;
    var phonelen=7;
    var faxlen=7;
    var loc;
        if (!(isblank(f.email.value))) {
          if (f.email.value.indexOf('\@') == -1) {
              msg += "Invalid E-Mail format.\\n";
          }
        }
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
//    if (phone.indexOf("-") >=0) {
//      phonelen=8;
//    }
//    if (fax.indexOf("-") >=0) {
//      faxlen=8;
//    }
//    if (phone.length > phonelen) {
//      msg += "Phone Number can not be longer than 7 digits.\\n";
//    }
//    if (fax.length > faxlen) {
//      msg += "FAX Number can not be longer than 7 digits.\\n";
//    }
    
  }
  if (msg != "") {
    alert (msg);
    return false;
  }
  return true;
}


function submitForm(script, command) {
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = '_self';
    document.$form.submit();
}


function submitFormDummy(script, command) {
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = '_self';
    document.$form.submit();
}


function submitFormNewWindow(script, command) {
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = '_blank';
    document.$form.submit();
}


function submitFormCGIResults(script, command) {
    document.$form.command.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'cgiresults';
    document.$form.submit();
}


function submitFormCGIResultsDummy(script, command) {
    document.dummy$form.command.value = command;
    document.dummy$form.action = '$path' + script + '.pl';
    document.dummy$form.target = 'cgiresults';
    document.dummy$form.submit();
}


function browseLetter(letter) {
    document.dummy$form.letter.value = letter;
    submitFormCGIResultsDummy('commentors', 'browseletter')
    
}

function displayCommentor(id) {
    document.$form.id.value = id;
    submitForm('commentors', 'display')
}

function browseDocument(id) {
    document.$form.id.value = id;
    submitForm('comment_documents', 'browse3')
}

function ViewPDF(id) {
    document.$form.documentid.value = id;
    submitFormCGIResults ('display_image', 'pdf');
}

function ViewScannedPDF(id) {
    document.$form.documentid.value = id;
    submitFormCGIResults ('display_image', 'scanned');
}

function RetrieveCommentor() {
    if (!(isblank(document.$form.newid.value)) && isnumeric(document.$form.newid.value)) {
        submitFormCGIResults('$form', 'update1');
    } else {
        alert ('Commentor ID must be a positive number.');
    }
}

function doUpdateSubmit() {
    if (verify_$form(document.$form)) {
        submitFormCGIResults('$form', 'update3');
    }
}


//-->
</script>
</head>

<body background=$CRDImagePath/background.gif text=$CRDFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
<font face=$CRDFontFace color=$CRDFontColor>
<center>
END_OF_BLOCK

#print headerBar($username,$userid,$schema);

print "<br><table border=0><tr><td>\n";
if ($command eq 'report') { 
   print "<b>report type: $id</b></font>\n";
}
print "</td></tr></table>\n";

# Connect to the oracle database and generate an object 'handle' to the database
my $dbh = db_connect();

# set up form for whole page
print "<center>\n";
print "<table border=0 width=750><tr><td><center>\n";


# process input data =============================================================================================================================
if ($command eq 'browse') {
    # process info for initial browse ----------------------------------------------------------------------------------
    $command = 'browseform';
}


if ($command eq 'browse1') {
    # process info for browse by name ----------------------------------------------------------------------------------
    $lastname = $crdcgi->param('lastname');
    $lastname =~ s/\*//g;
    $lastname =~ s/'/''/g;
    $sqlquery = "SELECT id FROM $schema.commentor WHERE UPPER('$lastname') = UPPER(SUBSTR(lastname,1,LENGTH('$lastname')))";
print "\n<!-- $sqlquery -->\n\n";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select commentor from database.",$@);
    } else {
        if ($status && $#values >=0) {
            $lastname =~ s/''/\\'/g;
            $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&schema=$schema&command=browse2&lastname=$lastname";
            
        } else {
            $lastname =~ s/''/`/g;
            $message = "There are no commentors with a last name starting with $lastname";
        }
    }
}


if ($command eq 'browse2') {
    # process info for browse by name ----------------------------------------------------------------------------------
    $command = 'browse2form';
    $lastname = $crdcgi->param('lastname');
    $lastname =~ s/'/''/g;
    $sqlquery = "SELECT id,lastname,firstname,state,organization FROM $schema.commentor WHERE UPPER('$lastname') = UPPER(SUBSTR(lastname,1,LENGTH('$lastname'))) ORDER BY LASTNAME, FIRSTNAME";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        $commentorarray[0][0] = "Matches for Last Name '$lastname'";
        my $i = 0;
        while (@values = $csr->fetchrow_array) {
            $i++;
            my @rows = $dbh->selectrow_array("SELECT count(*) FROM $schema.document WHERE commentor=$values[0]");
            $commentorarray[$i][0] = (defined($values[2]) ? $values[2] . " " : '') . (defined($values[1]) ? $values[1] : '&nbsp;');
            #$commentorarray[$i][1] = (defined($values[0]) ? "C" . lpadzero($values[0],4) : '&nbsp;');
            $commentorarray[$i][1] = (defined($values[0]) ? $values[0] : '&nbsp;');
            $commentorarray[$i][2] = (defined($rows[0]) ? $rows[0] : 0);
            $commentorarray[$i][3] = (defined($values[3]) ? $values[3] : '&nbsp;');
            $commentorarray[$i][4] = (defined($values[4]) ? $values[4] : '&nbsp;');
        }
        $commentorarray[0][0] .= " - Count = $i";
        $csr->finish;
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select commentor from database for browse.",$@);
    }

}


if ($command eq 'browseorganization') {
    # process info for browse by organization ----------------------------------------------------------------------------------
    $organization = $crdcgi->param('organization');
    $organization =~ s/\*//g;
    $organization =~ s/'/''/g;
    $sqlquery = "SELECT id FROM $schema.commentor WHERE UPPER('$organization') = UPPER(SUBSTR(organization,1,LENGTH('$organization')))";
print "\n<!-- $sqlquery -->\n\n";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select commentor from database.",$@);
    } else {
        if ($status && $#values >=0) {
            $lastname =~ s/''/\\'/g;
            $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&schema=$schema&command=browseorganization2&organization=$organization";
            
        } else {
            $lastname =~ s/''/`/g;
            $message = "There are no commentors with an organization name starting with $organization";
        }
    }
}


if ($command eq 'browseorganization2') {
    # process info for browse by organization ----------------------------------------------------------------------------------
    $command = 'browse2form';
    $organization = $crdcgi->param('organization');
    $organization =~ s/'/''/g;
    $sqlquery = "SELECT id,lastname,firstname,state,organization FROM $schema.commentor WHERE UPPER('$organization') = UPPER(SUBSTR(organization,1,LENGTH('$organization'))) ORDER BY organization, LASTNAME, FIRSTNAME";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        $commentorarray[0][0] = "Matches for Organization '$organization'";
        my $i = 0;
        while (@values = $csr->fetchrow_array) {
            $i++;
            my @rows = $dbh->selectrow_array("SELECT count(*) FROM $schema.document WHERE commentor=$values[0]");
            $commentorarray[$i][0] = (defined($values[2]) ? $values[2] . " " : '') . (defined($values[1]) ? $values[1] : '&nbsp;');
            #$commentorarray[$i][1] = (defined($values[0]) ? "C" . lpadzero($values[0],4) : '&nbsp;');
            $commentorarray[$i][1] = (defined($values[0]) ? $values[0] : '&nbsp;');
            $commentorarray[$i][2] = (defined($rows[0]) ? $rows[0] : 0);
            $commentorarray[$i][3] = (defined($values[3]) ? $values[3] : '&nbsp;');
            $commentorarray[$i][4] = (defined($values[4]) ? $values[4] : '&nbsp;');
        }
        $commentorarray[0][0] .= " - Count = $i";
        $csr->finish;
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select commentor from database for browse.",$@);
    }

}


if ($command eq 'browseaffiliation') {
    # process info for browse by affifliation ----------------------------------------------------------------------------------
    $affiliation = $crdcgi->param('affiliation');
    $sqlquery = "SELECT id FROM $schema.commentor WHERE UPPER('$affiliation') = UPPER(affiliation)";
    eval {
        $affiliationname=get_value($dbh,$schema, "commentor_affiliation", "name", "id = $affiliation");
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select commentor from database.",$@);
    } else {
        if ($status && $#values >=0) {
            $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&schema=$schema&command=browseaffiliation2&affiliation=$affiliation";
        } else {
            $message = "There are no commentors with an affiliation of $affiliationname";
        }
    }
}


if ($command eq 'browseaffiliation2') {
    # process info for browse by name ----------------------------------------------------------------------------------
    $command = 'browse2form';
    $affiliation = $crdcgi->param('affiliation');
    $sqlquery = "SELECT id,lastname,firstname,state,organization FROM $schema.commentor WHERE UPPER('$affiliation') = UPPER(affiliation) ORDER BY LASTNAME, FIRSTNAME";
    eval {
        $affiliationname=get_value($dbh,$schema, "commentor_affiliation", "name", "id = $affiliation");
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        $commentorarray[0][0] = "Matches for '$affiliationname'";
        my $i = 0;
        while (@values = $csr->fetchrow_array) {
            $i++;
            my @rows = $dbh->selectrow_array("SELECT count(*) FROM $schema.document WHERE commentor=$values[0]");
            $commentorarray[$i][0] = (defined($values[2]) ? $values[2] . " " : '') . (defined($values[1]) ? $values[1] : '&nbsp;');
            #$commentorarray[$i][1] = (defined($values[0]) ? "C". lpadzero($values[0],4) : '&nbsp;');
            $commentorarray[$i][1] = (defined($values[0]) ? $values[0] : '&nbsp;');
            $commentorarray[$i][2] = (defined($rows[0]) ? $rows[0] : 0);
            $commentorarray[$i][3] = (defined($values[3]) ? $values[3] : '&nbsp;');
            $commentorarray[$i][4] = (defined($values[4]) ? $values[4] : '&nbsp;');
        }
        $commentorarray[0][0] .= " - Count = $i";
        $csr->finish;
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select commentor from database for browse.",$@);
    }

}


if ($command eq 'browseletter') {
    # process info for browse letter ----------------------------------------------------------------------------------
    $letter = $crdcgi->param('letter');
    $sqlquery = "SELECT id,lastname,firstname,state,organization FROM $schema.commentor WHERE UPPER('$letter') = UPPER(SUBSTR(lastname,1,1)) ORDER BY LASTNAME, FIRSTNAME";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
        if ($#values>1) {
            #$command = 'browseletter2';
            $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&schema=$schema&command=browseletter2&letter=$letter";
        } else {
            $message = "There are no commentors with a last name starting with $letter";
        }
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select commentor from database for browse by letter.",$@);
    }

}


if ($command eq 'browseletter2') {
    # process info for browse letter ----------------------------------------------------------------------------------
    $command = 'browse2form';
    $letter = $crdcgi->param('letter');
    $sqlquery = "SELECT id,lastname,firstname,state,organization FROM $schema.commentor WHERE UPPER('$letter') = UPPER(SUBSTR(lastname,1,1)) ORDER BY LASTNAME, FIRSTNAME";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        $commentorarray[0][0] = uc($letter);
        my $i = 0;
        while (@values = $csr->fetchrow_array) {
            $i++;
            my @rows = $dbh->selectrow_array("SELECT count(*) FROM $schema.document WHERE commentor=$values[0]");
            $commentorarray[$i][0] = (defined($values[2]) ? $values[2] . " " : '') . (defined($values[1]) ? $values[1] : '&nbsp;');
            #$commentorarray[$i][1] = (defined($values[0]) ? "C" . lpadzero($values[0],4) : '&nbsp;');
            $commentorarray[$i][1] = (defined($values[0]) ? $values[0] : '&nbsp;');
            $commentorarray[$i][2] = (defined($rows[0]) ? $rows[0] : 0);
            $commentorarray[$i][3] = (defined($values[3]) ? $values[3] : '&nbsp;');
            $commentorarray[$i][4] = (defined($values[4]) ? $values[4] : '&nbsp;');
        }
        $commentorarray[0][0] .= " - Count = $i";
        $csr->finish;
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select commentor from database for browse by letter.",$@);
    }

}


if ($command eq 'displayid') {
    # process info for display ----------------------------------------------------------------------------------
    if (defined($crdcgi->param('browseid'))) {
        if ($crdcgi->param('browseid') < 1) {
            $id = 0;
        } else {
            $id = $crdcgi->param('browseid');
        }
    } else {
        $id = 0;
    }
    if ($id > 0) {
        $sqlquery = "SELECT id,lastname,firstname,middlename,title,suffix,address,city,state,country,postalcode,areacode,phonenumber,phoneextension,faxareacode,faxnumber,faxextension,email,organization,position,affiliation FROM $schema.commentor WHERE id = $id";
        eval {
            $csr = $dbh->prepare($sqlquery);
            $status = $csr->execute;
            @values = $csr->fetchrow_array;
            $csr->finish;
            if ($status && $#values >= 0) {
                $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&schema=$schema&command=display&id=$id";
            } else {
                $message = "No such commentor ID number $id";
            }
        };
        if ($@) {
            $message = errorMessage($dbh,$username,$userid,$schema,"select commentor from database for display.",$@);
        }
    } else {
        $message = "Commentor ID must be input.";
    }
        
}


if ($command eq 'display') {
    # process info for display ----------------------------------------------------------------------------------
    $command = 'displayform';
    $sqlquery = "SELECT id,lastname,firstname,middlename,title,suffix,address,city,state,country,postalcode,areacode,phonenumber,phoneextension,faxareacode,faxnumber,faxextension,email,organization,position,affiliation FROM $schema.commentor WHERE id = $id";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
        if ($status && $#values >= 0) {
            $commentorarray[0][0] = "Commentor Information";
            $commentorarray[1][0] = "<b>ID:</b>";
            $commentorarray[1][1] = "<b>C" . lpadzero($values[0],4) . "</b>";
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
            $commentorarray[7][1] = "<b>" . (defined($values[20]) ? get_value($dbh,$schema,'commentor_affiliation', 'name', "id = $values[20]") : ' ') . "</b>";
            $commentorarray[8][0] = "<b>Street:</b>";
            $commentorarray[8][1] = "<b>" . (defined($values[6]) ? $values[6] : ' ') . "</b>";
            $commentorarray[9][0] = "<b>City/State/Postal Code: &nbsp; </b>";
            $commentorarray[9][1] = "<b>" . (defined($values[7]) ? "$values[7], " : ' ') . (defined($values[8]) ? $values[8] : ' ') . (defined($values[10]) ? " $values[10]" : ' ') . "</b>";
            $commentorarray[10][0] = "<b>Country:</b>";
            $commentorarray[10][1] = "<b>" . (defined($values[9]) ? $values[9] : ' ') . "</b>";
            $commentorarray[11][0] = "<b>Phone Number:</b>";
            $commentorarray[11][1] = "<b>" . (defined($values[11]) ? "($values[11]) " : '') . (defined($values[12]) ? substr($values[12],0,3) . "-" . substr($values[12],3,4) : ' ') . (defined($values[13]) ? "-$values[13]" : '') . "</b>";
            $commentorarray[12][0] = "<b>Fax Number:</b>";
            $commentorarray[12][1] = "<b>" . (defined($values[14]) ? "($values[14]) " : '') . (defined($values[15]) ? substr($values[15],0,3) . "-" . substr($values[15],3,4) : ' ') . (defined($values[16]) ? "-$values[16]" : '') . "</b>";
            $commentorarray[13][0] = "<b>Email Address:</b>";
            $commentorarray[13][1] = "<b>" . (defined($values[17]) ? $values[17] : ' ') . "</b>";
        } else {
            $message = "No such commentor ID number C" . lpadzero($id,4);
            $commentorarray[0][0] = "Commentor Information";
            #$urllocation = "javascript:history.back()";
        }
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select commentor from database for display.",$@);
    }
        
}


if ($command eq 'viewdocuments') {
    # process info for viewing documents by commentor lastname ----------------------------------------------------------------------------------
    $command = 'viewdocumentsform';
    $lastname = $crdcgi->param('lastname');
    $lastname =~ s/.htm//g;
    $sqlquery = "SELECT id,lastname,firstname,middlename FROM $schema.commentor WHERE UPPER(lastname) = UPPER('$lastname')";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        if ($status) {
            $documentsarray[0][0] = "Last Name: $lastname";
            my $i=0;
            while (@values = $csr->fetchrow_array) {
                $sqlquery2 = "SELECT id,documenttype,datereceived,pagecount FROM $schema.document WHERE commentor = $values[0]";
                $csr2 = $dbh->prepare($sqlquery2);
                $status = $csr2->execute;
                while (@values2 = $csr2->fetchrow_array) {
                    $i++;
                    $documentsarray[$i][0] = $values[1] . (defined($values[2]) ? ", " . $values[2] : '') . (defined($values[3]) ? " $values[3]" : '');
                    $documentsarray[$i][1] = $values[0];
                    $documentsarray[$i][2] = $values2[0];
                    $documentsarray[$i][3] = $values2[2];
                    $documentsarray[$i][4] = get_value($dbh,$schema, 'document_type', 'name', "id = $values2[1]");
                    $documentsarray[$i][5] = $values2[3];
                    my @row = $dbh->selectrow_array("SELECT count(*) FROM $schema.document WHERE id=$values2[0] AND image IS NOT NULL");
                    if ($row[0] == 0) {
                        $documentsarray[$i][6] = 'F';
                    } else {
                        $documentsarray[$i][6] = 'T';
                    }
                }
                $csr2->finish;
            }
        } else {
            $message = "No comments that have the same commentor last name as $lastname";
            $urllocation = "javascript:history.back()";
        }
        $csr->finish;
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select commentor/documents from database for view.",$@);
    }
        
}


if ($command eq 'update') {
    # process info updating commentor ----------------------------------------------------------------------------------
    $command = 'updateform';
        
}


if ($command eq 'update2') {
    # process info updating commentor ----------------------------------------------------------------------------------
    $command = 'update2form';
    $sqlquery = "SELECT id,lastname,firstname,middlename,title,suffix,address,city,state,country,postalcode,areacode,phonenumber,phoneextension,faxareacode,faxnumber,faxextension,email,organization,position,affiliation FROM $schema.commentor WHERE id = $id";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
    };
    if ($status && $#values >= 0 && !($@)) {
        ($id,$lastname,$firstname,$middlename,$title,$suffix,$address,$city,$state,$country,$postalcode,$areacode,$phonenumber,$phoneextension,$faxareacode,$faxnumber,$faxextension,$email,$organization,$position,$affiliation) = @values;
    } else {
        $message = errorMessage($dbh,$username,$userid,$schema,"retrieve commentor from database.",$@);
        $command = 'updateform';
    }
        
}


if ($command eq 'update1') {
    # process info updating commentor ----------------------------------------------------------------------------------
    $id = $crdcgi->param('newid');
    $sqlquery = "SELECT id FROM $schema.commentor WHERE id = $id";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        @values = $csr->fetchrow_array;
        $csr->finish;
        if ($status && $#values >= 0) {
            $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&schema=$schema&command=update2&id=$id";
        } else {
            $message = "No commentor matches id # $id";
        }
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"test for commentor in database.",$@);
    }
        
}


if ($command eq 'update3') {
    # process info updating commentor ----------------------------------------------------------------------------------
    $id = $crdcgi->param('id');
    $lastname = $crdcgi->param('lastname');
    $lastname =~ s/'/''/g;
    $firstname = ((defined($crdcgi->param('firstname'))) ? $crdcgi->param('firstname') : "");
    if (defined($firstname) && $firstname gt ' ') {$firstname  =~ s/'/''/g;}
    $middlename = ((defined($crdcgi->param('middlename'))) ? $crdcgi->param('middlename') : "");
    if (defined($middlename) && $middlename gt ' ') {$middlename  =~ s/'/''/g;}
    $title = ((defined($crdcgi->param('title'))) ? $crdcgi->param('title') : "");
    if (defined($title) && $title gt ' ') {$title  =~ s/'/''/g;}
    $suffix = ((defined($crdcgi->param('suffix'))) ? $crdcgi->param('suffix') : "");
    if (defined($suffix) && $suffix gt ' ') {$suffix  =~ s/'/''/g;}
    $address = ((defined($crdcgi->param('address'))) ? $crdcgi->param('address') : "");
    if (defined($address) && $address gt ' ') {$address  =~ s/'/''/g;}
    $city = ((defined($crdcgi->param('city'))) ? $crdcgi->param('city') : "");
    if (defined($city) && $city gt ' ') { $city =~ s/'/''/g;}
    $state = $crdcgi->param('state');
    $country = $crdcgi->param('country');
    $postalcode = ((defined($crdcgi->param('postalcode'))) ? $crdcgi->param('postalcode') : "");
    $areacode = ((defined($crdcgi->param('areacode'))) ? $crdcgi->param('areacode') : "");
    $phonenumber = ((defined($crdcgi->param('phonenumber'))) ? $crdcgi->param('phonenumber') : "");
    $phonenumber =~ s/-//g;
    $phonenumber =~ s/\D//g;
    $phoneextension = ((defined($crdcgi->param('phoneextension'))) ? $crdcgi->param('phoneextension') : "");
    $faxareacode = ((defined($crdcgi->param('faxareacode'))) ? $crdcgi->param('faxareacode') : "");
    $faxnumber = ((defined($crdcgi->param('faxnumber'))) ? $crdcgi->param('faxnumber') : "");
    $faxnumber =~ s/-//g;
    $faxnumber =~ s/\D//g;
    $faxextension = ((defined($crdcgi->param('faxextension'))) ? $crdcgi->param('faxextension') : "");
    $email = ((defined($crdcgi->param('email'))) ? $crdcgi->param('email') : "");
    if (defined($email) && $email gt ' ') {$email  =~ s/'/''/g;}
    $organization = ((defined($crdcgi->param('organization'))) ? $crdcgi->param('organization') : "");
    if (defined($organization) && $organization gt ' ') {$organization  =~ s/'/''/g;}
    $position = ((defined($crdcgi->param('position'))) ? $crdcgi->param('position') : "");
    if (defined($position) && $position gt ' ') {$position  =~ s/'/''/g;}
    $affiliation = $crdcgi->param('affiliation');
    
    # build sql command
    $sqlquery = "UPDATE $schema.commentor SET lastname = '$lastname'";
    $sqlquery .= ((defined($firstname) && $firstname gt ' ') ? ", firstname = '$firstname'" : ", firstname = NULL");
    $sqlquery .= ((defined($middlename) && $middlename gt ' ') ? ", middlename = '$middlename'" : ", middlename = NULL");
    $sqlquery .= ((defined($title) && $title gt ' ') ? ", title = '$title'" : ", title = NULL");
    $sqlquery .= ((defined($suffix) && $suffix gt ' ') ? ", suffix = '$suffix'" : ", suffix = NULL");
    $sqlquery .= ((defined($address) && $address gt ' ') ? ", address = '$address'" : ", address = NULL");
    $sqlquery .= ((defined($city) && $city gt ' ') ? ", city = '$city'" : ", city = NULL");
    $sqlquery .= ((defined($state) && $state gt ' ') ? ", state = '$state'" : ", state = NULL");
    $sqlquery .= ((defined($country) && $country gt ' ') ? ", country = '$country'" : ", country = NULL");
    $sqlquery .= ((defined($postalcode) && $postalcode gt ' ') ? ", postalcode = '$postalcode'" : ", postalcode = NULL");
    $sqlquery .= ((defined($areacode) && $areacode gt ' ') ? ", areacode = $areacode" : ", areacode = NULL");
    $sqlquery .= ((defined($phonenumber) && $phonenumber gt ' ') ? ", phonenumber = $phonenumber" : ", phonenumber = NULL");
    $sqlquery .= ((defined($phoneextension) && $phoneextension gt ' ') ? ", phoneextension = $phoneextension" : ", phoneextension = NULL");
    $sqlquery .= ((defined($faxareacode) && $faxareacode gt ' ') ? ", faxareacode = $faxareacode" : ", faxareacode = NULL");
    $sqlquery .= ((defined($faxnumber) && $faxnumber gt ' ') ? ", faxnumber = $faxnumber" : ", faxnumber = NULL");
    $sqlquery .= ((defined($faxextension) && $faxextension gt ' ') ? ", faxextension = $faxextension" : ", faxextension = NULL");
    $sqlquery .= ((defined($email) && $email gt ' ') ? ", email = '$email'" : ", email = NULL");
    $sqlquery .= ((defined($organization) && $organization gt ' ') ? ", organization = '$organization'" : ", organization = NULL");
    $sqlquery .= ((defined($position) && $position gt ' ') ? ", position = '$position'" : ", position = NULL");
    $sqlquery .= ", affiliation = $affiliation";
    $sqlquery .= " WHERE id = $id";
    eval {
        $csr = $dbh->prepare($sqlquery);
        $status = $csr->execute;
        $csr->finish;
        $dbh->commit;
    };
    if ($status && !($@)) {
        $message = "Update was successful";
        $urllocation = "$ENV{SCRIPT_NAME}?username=$username&userid=$userid&schema=$schema&command=update";
        log_activity ($dbh, $schema, $userid, "Commentor $id updated");
    } else {
        $message = errorMessage($dbh,$username,$userid,$schema,"update commentor C" . lpadzero($id,4) . ".",$@);
    }
        
}



#=============================================================================================================

# display any messages generated by the script
print "<script language=javascript><!--\n";
if (defined($message) && $message gt " ") {
    #print "   alert(unescape('$message'));\n";
    print doAlertBox( text => $message, includeScriptTags => 'F');
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

# generate html form info
print "<form name=$form onSubmit=\"return verify_$form(this)\" action=$ENV{SCRIPT_NAME} method=post target=cgiresults>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=server value=$Server>\n";
print "<input type=hidden name=letter value=' '>\n";
print "<input type=hidden name=documentid value=0>\n";
#print "<input type=hidden name=command value=$command>\n";

# set up the links for viewing commentors by the first letter of last name
$letterlinks .= " <a href=javascript:browseLetter('a')>A</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('b')>B</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('c')>C</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('d')>D</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('e')>E</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('f')>F</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('g')>G</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('h')>H</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('i')>I</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('j')>J</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('k')>K</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('l')>L</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('m')>M</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('n')>N</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('o')>O</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('p')>P</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('q')>Q</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('r')>R</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('s')>S</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('t')>T</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('u')>U</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('v')>V</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('w')>W</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('x')>X</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('y')>Y</a> \n";
$letterlinks .= " <a href=javascript:browseLetter('z')>Z</a> \n";

# Generate forms for screen output ------------------------------------------------------------------------------------------------------------------------------------------------
if ($command eq 'browseform') {
    # generate first browse form ----------------------------------------------------------------------------------------------

    $command = 'browse1';
    print "<input type=hidden name=command value=$command>\n";
    $pagetitle = "Browse Commentor";
    print "<table border=0><tr><td>\n";
    print "<b>Browse By:</b><br>\n";
    print "<ul>\n";
    print "<li><b>Last Name starting with: &nbsp;\n";
   
    print $letterlinks;
    
    print "</b><br></li>\n";
    print "<li><b>Last Name <font size-1>(partial name OK)</font>: &nbsp; <input type=text name=lastname> <input type=button name=submitbrowse value=Go OnClick='document.$form.command.value=\"browse1\";document.$form.submit();'></b><br></li>";
    print "<br>\n";
    print "<li><b>Organization <font size-1>(partial name OK)</font>: &nbsp; <input type=text name=organization> <input type=button name=submitbrowseorg value=Go OnClick='document.$form.command.value=\"browseorganization\";document.$form.submit();'></b><br></li>";
    print "<br>\n";
    print "<li><b>Affiliation: &nbsp; ";
    eval {
        %lookup_values = &get_lookup_values($dbh, $schema, "commentor_affiliation", "id", "name");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select commentor affiliations.",$@);
        print doAlertBox( text => $message);
    }
    print &build_drop_box ("affiliation", \%lookup_values, $affiliation);
    print " <input type=button name=submitbrowseid value=Go OnClick='document.$form.command.value=\"browseaffiliation\";document.$form.submit();'></b><br></li>";
    print "<br>\n";
    print "<li><b>Display Commentor with ID: &nbsp; C<input type=text name=browseid size=5 maxlength=5> <input type=button name=submitbrowseid value=Go OnClick='document.$form.id.value=document.$form.browseid.value;document.$form.command.value=\"displayid\";document.$form.submit();'></b><br></li>";

    print "</td></tr></table>\n";
}


if ($command eq 'browse2form') {
    # generate browse by letter or name form ----------------------------------------------------------------------------------------------

    $command = 'browse1';
    print "<input type=hidden name=command value=$command>\n";
    $pagetitle = "Browse Commentor";
    print "<table border=0><tr><td>\n";
    print "<b>Browse By:</b><br>\n";
    print "<ul>\n";
    print "<li><b>Last Name starting with: &nbsp;\n";
    
    print $letterlinks;

    print "</b><br></li>\n";
    print "<li><b>Last Name <font size-1>(partial name OK)</font>: &nbsp; <input type=text name=lastname> <input type=button name=submitbrowse value=Go OnClick='document.$form.command.value=\"browse1\";document.$form.submit();'></b><br></li>";
    print "<br>\n";
    print "<li><b>Organization <font size-1>(partial name OK)</font>: &nbsp; <input type=text name=organization> <input type=button name=submitbrowseorg value=Go OnClick='document.$form.command.value=\"browseorganization\";document.$form.submit();'></b><br></li>";
    print "<br>\n";
    print "<li><b>Affiliation: &nbsp; ";
    eval {
        %lookup_values = &get_lookup_values($dbh, $schema, "commentor_affiliation", "id", "name");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select commentor affiliations..",$@);
        print doAlertBox( text => $message);
    }
    print &build_drop_box ("affiliation", \%lookup_values, $affiliation);
    print " <input type=button name=submitbrowseid value=Go OnClick='document.$form.command.value=\"browseaffiliation\";document.$form.submit();'></b><br></li>";
    print "<br>\n";
    print "<li><b>Display Commentor with ID: &nbsp; C<input type=text name=browseid size=5 maxlength=5> <input type=button name=submitbrowseid value=Go OnClick='document.$form.id.value=document.$form.browseid.value;document.$form.command.value=\"displayid\";document.$form.submit();'></b><br></li>";

    print "</td></tr></table>\n";
    print "<br><hr><br>\n";
 
    print "<input type=hidden name=id value=0>\n";
    print start_table (5, 'center');
    print title_row('#ffc0ff', '#000099', $commentorarray[0][0]);
    print add_header_row . add_col . "Name" . add_col . "Commentor ID" .add_col . "<center># Documents</center>" .add_col . "State" . add_col . "Organization";
    for (my $i=1; $i <= $#commentorarray; $i++) {
        print add_row;
        print add_col_link ("javascript:displayCommentor($commentorarray[$i][1])") . $commentorarray[$i][0];
        $commentorarray[$i][1] = "C" . lpadzero($commentorarray[$i][1],4);
        for (my $j=1; $j <= 4; $j++) {
            print add_col . (($j == 2) ? "<center>$commentorarray[$i][$j]</center>" : $commentorarray[$i][$j]);
        }
    }
    print end_table;
}


if ($command eq 'displayform') {
    # generate browse by letter or name form ----------------------------------------------------------------------------------------------

    if (!defined($crdcgi->param('newwindow')) || $crdcgi->param('newwindow') != 1) {
        $pagetitle = "Browse Commentor";
    }
    $command = 'display';
    print "<input type=hidden name=command value=$command>\n";

    print gen_table (\@commentorarray);
    print "<br>\n";
    print display_documents (dbh => $dbh, schema => $schema, userId => $userid, userName => "$username", commentor => "$id");
    if (defined($crdcgi->param('newwindow')) && $crdcgi->param('newwindow') != 1) {
        print "<br><a href=javascript:history.back()><b>Return to Previous Page</b></a>\n";
    }
    
}


if ($command eq 'viewdocumentsform') {
    # generate view documents by comemntor with same last name form ----------------------------------------------------------------------------------------------

    $command = 'viewdocuments';
    $pagetitle = "Documents by Commentor with Same Last Name";
    print "<input type=hidden name=command value=$command>\n";

    print "<input type=hidden name=id value=0>\n";
    print start_table (7, 'center');
    print title_row('#000099', '#ffffff', $documentsarray[0][0]);
    print add_header_row . add_col . "Full Name" . add_col . "Commentor ID" . add_col . "Document ID" . add_col . "Image" . add_col . "Date Received" . add_col . "Type" . add_col . "Pages";
    for (my $i=1; $i <= $#documentsarray; $i++) {
        print add_row;
        print add_col_link ("javascript:displayCommentor($documentsarray[$i][1])") . $documentsarray[$i][0] . add_col . "C" . lpadzero($documentsarray[$i][1],4);
        print add_col_link ("javascript:browseDocument($documentsarray[$i][2])") . "$CRDType" . lpadzero($documentsarray[$i][2],6);
        if ($documentsarray[$i][6] eq 'T') {
            print add_col_link ("javascript:ViewPDF($documentsarray[$i][2])") . "<i>pdf</i>" . add_col . $documentsarray[$i][3];
        } else {
            print add_col_link ("javascript:ViewScannedPDF($documentsarray[$i][2])") . "<i>pdf</i>" . add_col . $documentsarray[$i][3];
        }
        print add_col . $documentsarray[$i][4] . add_col . $documentsarray[$i][5];
    }
    print end_table;

}


if ($command eq 'updateform') {
    # generate get commentor to update form ----------------------------------------------------------------------------------------------

    $command = 'update1';
    print "<input type=hidden name=command value=$command>\n";
    $pagetitle = "Update Commentor";
    print "<b>Commentor ID: C<input type=text name=newid size=5 maxlength=5> &nbsp; <input type=button name=submitupdate value='Retrieve Commentor' onClick=\"RetrieveCommentor();\">\n";
    print "<script language=javascript><!--\n";
    print "  document.$form.newid.focus();\n";
    print "//--></script>\n";

    print "<br>\n";
    
}


if ($command eq 'update2form') {
    # generate get commentor to update form ----------------------------------------------------------------------------------------------

    $command = 'update3';
    print "<input type=hidden name=command value=$command>\n";
    print "<input type=hidden name=id value=$id>\n";
    $pagetitle = "Update Commentor";
    print "<b>Commentor ID: C<input type=text name=newid size=5 maxlength=5> &nbsp; <input type=button name=submitupdate value='Retrieve Commentor' onClick=\"RetrieveCommentor();\">\n";
    print "<script language=javascript><!--\n";
    print "  document.$form.newid.focus();\n";
    print "//--></script>\n";

    print "<br><br><hr><br>\n";
    
    
    print "<table border=0 cellpadding=1 width=680>\n";
    print "<tr><td colspan=5><h3>ID C" . lpadzero($id,4) . "</h3></td></tr>\n";
    print <<END_OF_BLOCK;
<tr>
<td>Title</td>
<td>First Name</td>
<td>Middle Name</td>
<td>Last Name</td>
</tr><tr>
END_OF_BLOCK
    print "<td><input type=text size=10 maxlength=25 name=title value=\"" . ((defined($title)) ? $title : "") . "\"></td>\n";
    print "<td><input type=text size=25 maxlength=25 name=firstname value=\"" . ((defined($firstname)) ? $firstname : "") . "\"></td>\n";
    print "<td><input type=text size=25 maxlength=25 name=middlename value=\"" . ((defined($middlename)) ? $middlename : "") . "\"></td>\n";
    print "<td><input type=text size=25 maxlength=25 name=lastname value=\"" . ((defined($lastname)) ? $lastname : "") . "\"></td>\n";
    
    print <<END_OF_BLOCK;
</tr><tr>
<td>Suffix</td><td> </td><td>Email Address</td></tr>
<tr>
END_OF_BLOCK
    print "<td><input type=text size=10 maxlength=10 name=suffix value=\"" . ((defined($suffix)) ? $suffix : "") . "\"></td>\n";
    print "<td> </td>\n";
    print "<td colspan=2><input type=text name=email size=25 maxlength=75 value=\"" . ((defined($email)) ? $email : "") . "\"></td>\n";
    
    print <<END_OF_BLOCK;
</tr>
</table>

<table border=0 cellpadding=1 width=680>

<tr>
<td>Organization</td>
<td>Position</td>
<td>Affiliation</td>
</tr>

<tr>
END_OF_BLOCK
    print "<td><input type=text size=25 maxlength=120 name=organization value=\"" . ((defined($organization)) ? $organization : "") . "\"></td>\n";
    print "<td><input type=text size=25 maxlength=75 name=position value=\"" . ((defined($position)) ? $position : "") . "\"></td>\n";
    print "<td>\n";

    eval {
        %lookup_values = &get_lookup_values($dbh, $schema, "commentor_affiliation", "id", "name");
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$userid,$schema,"select commentor affiliations...",$@);
        print doAlertBox( text => $message);
    }
    print &build_drop_box ("affiliation", \%lookup_values, $affiliation);
    print <<END_OF_BLOCK;
 
</td></tr>

<tr><td colspan=2 >Street </td> <td >City </td></tr>

END_OF_BLOCK
    print "<tr><td colspan=2 ><input type=text size=50 maxlength=100 name=address value=\"" . ((defined($address)) ? $address : "") . "\"></td>\n";
    print "<td ><input type=text size=27 maxlength=40 name=city value=\"" . ((defined($city)) ? $city : "") . "\"></td></tr>\n";

    print "<tr><td >State</td>\n";
    print "<td >Postal Code</td>\n";
    print "<td >Country</td></tr>\n";

    print "<tr><td>\n";

    print build_states($state);
    print "</td>\n";
    print "<td  align=left><input type=text size=9 maxlength=10 name=postalcode value=\"" . ((defined($postalcode)) ? $postalcode : "") . "\"></td>\n";
    print "<td>\n";
    print build_countries($country);
    print "</td></tr>\n";

    print "<tr><td><table border=0><tr>\n";
    print "  <td colspan=2 > Phone Number </td></tr>\n";
    print "  <tr><td ><input type=text size=3 maxlength=3 name=areacode value=" . ((defined($areacode)) ? $areacode : "") . "> - <input type=text size=7 maxlength=8 name=phonenumber value=" . ((defined($phonenumber)) ? (((length($phonenumber) == 7) ? substr($phonenumber,0,3) . "-" . substr($phonenumber,3,4) : $phonenumber)) : "") . "></td>\n";
    print "  <td >ext. <input type=text size=4 maxlength=5 name=phoneextension value=" . ((defined($phoneextension)) ? $phoneextension : "") . "></td></tr></table></td>\n";
    print "<td><table border=0><tr>\n";
    print "  <td colspan=2 >Fax Number </td></tr>\n";
    print "  <tr><td ><input type=text size=3 maxlength=3 name=faxareacode value=" . ((defined($faxareacode)) ? $faxareacode : "") . "> - <input type=text size=7 maxlength=8 name=faxnumber value=" . ((defined($faxnumber)) ? (((length($faxnumber) == 7) ? substr($faxnumber,0,3) . "-" . substr($faxnumber,3,4) : $faxnumber)) : "") . "></td>\n";
    print "  <td>ext. <input type=text size=4 maxlength=5 name=faxextension value=" . ((defined($faxextension)) ? $faxextension : "") . "></td></tr></table></td>\n";
    print "<td></td></tr>\n";
    print "</table>\n";

    print "<br><input type=button name=submitform value='Submit Updates' onClick=\"doUpdateSubmit();\">\n";

}


print "</form>\n";

if ($pagetitle gt "") {
    # show user and database on top of every screen...
    print  &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => $pagetitle);
}

print "</center></td></tr></table></center></font>\n";

# make submitform
print "<form name=dummy$form>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=server value=$Server>\n";
print "<input type=hidden name=lastname value=0>\n";
print "<input type=hidden name=formname value=$form>\n";
print "<input type=hidden name=letter value=0>\n";
print "<input type=hidden name=id value=0>\n";
print "<input type=hidden name=command value=0>\n";
print "</form>\n";

print "</body>\n</html>\n";

# close connection to the oracle database
db_disconnect($dbh);
