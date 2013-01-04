#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# DOE Commitment Manager's Closure Letter for the commitment.
#
# $Source: /data/dev/rcs/cms/perl/RCS/DOECMgr_closeresponse.pl,v $
# $Revision: 1.41 $
# $Date: 2001/11/15 20:21:08 $
# $Author: naydenoa $
# $Locker:  $
# $Log: DOECMgr_closeresponse.pl,v $
# Revision 1.41  2001/11/15 20:21:08  naydenoa
# Added action display to commitment info.
#
# Revision 1.40  2001/05/08 18:30:04  naydenoa
# Updated evals
#
# Revision 1.39  2001/05/02 22:36:22  naydenoa
# Modified evals, calls to Edit_Screens
#
# Revision 1.38  2001/01/02 17:22:59  naydenoa
# More code clean-up
#
# Revision 1.37  2000/12/19 17:51:28  naydenoa
# Code cleanup
#
# Revision 1.36  2000/12/07 18:51:45  naydenoa
# Code cleanup
#
# Revision 1.35  2000/11/07 23:18:07  naydenoa
# Added issue source display, took out rationales
#
# Revision 1.34  2000/10/31 16:58:13  naydenoa
# Added remarks display
# Changed table width to 650, textarea width to 75
#
# Revision 1.33  2000/10/24 20:06:09  naydenoa
# Updated call to Edit_Screens (commitment info table)
#
# Revision 1.32  2000/10/18 21:23:42  munroeb
# modified activity log message
#
# Revision 1.31  2000/10/17 16:57:39  naydenoa
# Took out log_history call, checkpoint.
#
# Revision 1.30  2000/10/06 16:56:25  munroeb
# added log_activity feature to script
#
# Revision 1.29  2000/10/03 20:40:11  naydenoa
# Updates status id's and references.
#
# Revision 1.28  2000/09/29 21:40:29  naydenoa
# Check for pick lists to include/exclude developers in dev/prod schema;
# changed references to roles, statuses (by ID)
#
# Revision 1.27  2000/09/28 22:12:46  atchleyb
# added names to insert
#
# Revision 1.26  2000/09/28 20:03:17  naydenoa
# Checkpoint after Version 2 release
#
# Revision 1.25  2000/09/18 15:04:03  naydenoa
# More interface updates
#
# Revision 1.24  2000/09/08 23:50:18  naydenoa
# More interface modifications.
#
# Revision 1.23  2000/09/01 23:57:48  naydenoa
# Major interface rewrite. Added use of module Edit_Screens (draws
# most elments of the commitment edit screens).
#
# Revision 1.22  2000/08/25 16:13:26  atchleyb
# changed Technical Lead to Discipline Lead
#
# Revision 1.21  2000/08/21 22:35:03  atchleyb
# fixed var name bug
#
# Revision 1.20  2000/08/21 20:16:04  atchleyb
# fixed var name bug
#
# Revision 1.19  2000/08/21 18:13:42  atchleyb
# added check schema line
#
# Revision 1.18  2000/07/24 15:10:33  johnsonc
# Inserted GIF file for display.
#
# Revision 1.17  2000/07/17 17:10:58  atchleyb
# placed forms in a table of width 750
#
# Revision 1.16  2000/07/11 15:11:31  munroeb
# really I finished modifying html formatting this time!
#
# Revision 1.15  2000/07/11 15:09:44  munroeb
# finished modifying html formatting
#
# Revision 1.14  2000/07/06 23:20:06  munroeb
# finished mods to html and javascripts.
#
# Revision 1.13  2000/07/05 22:33:52  munroeb
# made minor tweaks to javascript and html
#
# Revision 1.12  2000/06/21 21:50:34  johnsonc
# Editted opening page select object to support double click event.
#
# Revision 1.11  2000/06/16 15:42:23  johnsonc
# Revise WSB table entry to be optional display in edit and query screens
#
# Revision 1.10  2000/06/15 21:32:01  zepedaj
# Changed code to allow Commitment Maker Approval Rationale optional,
# while keeping Rejection Rationale Mandatory
#
# Revision 1.9  2000/06/13 21:40:35  zepedaj
# Fixed width of tables so the columns would be the same
#
# Revision 1.8  2000/06/13 19:23:00  johnsonc
# Change 'Rationale For Commitment' field to display only when data is present
#
# Revision 1.7  2000/06/13 15:25:29  johnsonc
# Editted commitments select object to a fixed width.
#
# Revision 1.6  2000/06/12 15:40:37  johnsonc
# Add 'C' in front of commitment ID and 'I' in front of issue ID.
# Add 'proposed' to edit and view commitment page titles.
#
# Revision 1.5  2000/06/09 20:11:23  johnsonc
# Edit secondary discipline text area to display only when it contains data
#
# Revision 1.4  2000/06/08 18:33:36  johnsonc
# Install commitment comment text box.
#
# Revision 1.3  2000/05/19 23:44:02  zepedaj
# Changed code for the final WBS structure
#
# Revision 1.2  2000/05/18 23:10:09  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/05/18 16:08:42  zepedaj
# Initial revision
#

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);
use Edit_Screens;

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use Tie::IxHash;
use strict;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

# print content type header
print $cmscgi->header('text/html');

my $pagetitle = "DOE Commitment Maker's Closure Letter";
my $cgiaction = $cmscgi->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = "issue";

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "")) {
    print <<openloginpage;
    <script type="text/javascript">
    <!--
    parent.location='$ONCSCGIDir/login.pl';
    //-->
    </script>
openloginpage
    exit 1;
}

#print html
print "<html>\n";
print "<head>\n";
print "<meta name=pragma content=no-cache>\n";
print "<meta name=expires content=0>\n";
print "<meta http-equiv=expires content=0>\n";
print "<meta http-equiv=pragma content=no-cache>\n";
#print "<meta http-equiv=\"expires\" content=\"Fri, 12 May 1996 14:35:02 EST\">\n";
print "<title>$pagetitle</title>\n";

print <<testlabel1;
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>

    <script type="text/javascript">
    <!--

    var dosubmit = true;
    if (parent == self) { // not in frames
    location = '$ONCSCGIDir/login.pl'
    }

    //-->
  </script>
  <script language="JavaScript" type="text/javascript">
  <!--
      doSetTextImageLabel('Final Response to Commitment');
  //-->
</script>

testlabel1

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

# find the Role ID and Status ID for the Commitment Maker Review
my $DOECMgr_Roleid = 4; # DOE Commitment Manager
my $DOECMgr_closure_letter_statusid = 15; # Closure Letter/Final Response

#####################################
if ($cgiaction eq "fillout_letter") {
#####################################
    #control variables
    my $letterid = $cmscgi->param('letterid');

    print fillLetter(dbh => $dbh, letterid => $letterid);
    &oncs_disconnect($dbh);
    exit 1;
} ####### endif fillout_letter  ###################

#####################################
if ($cgiaction eq "editcommitment") {
#####################################
    my $activity;
    my $commitmentid = $cmscgi->param('commitmentid');
    my $textareawidth = 75;
    my $commitmentidstring = substr("0000$commitmentid", -5);
    my %commitmenthash;
    my $siteid;

    eval {
	%commitmenthash = get_commitment_info($dbh, $commitmentid);
	$siteid = lookup_single_value($dbh, "users", "siteid", $usersid);
    };
    if ($@) {
	my $logmessage = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$logmessage =~ s/\n/\\n/g;
	$logmessage =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$logmessage');\n";
        print "//--></script>\n";
    }
    my $statusid = $commitmenthash{'statusid'};
    my $imgext = $commitmenthash{'imageextension'};
    my $chasimage = ($imgext) ? 1 : 0;
    my $key;

    $dbh->{LongTruncOk} = 0;

    print <<committable;
    <script language="JavaScript" type="text/javascript">
    <!--
    function clearletter() {
	document.editcommitment.letteraccessionnum.value = "";
	document.editcommitment.lettersigner.value = "";
	document.editcommitment.letteraddressee.value = "";
	document.editcommitment.letterorganizationid.value = "";
    }
    function disableletter() {
	document.editcommitment.letteraccessionnum.disabled = true;
	document.editcommitment.lettersigner.disabled = true;
	document.editcommitment.lettersigneddate_month.disabled = true;
	document.editcommitment.lettersigneddate_day.disabled = true;
	document.editcommitment.lettersigneddate_year.disabled = true;
	document.editcommitment.lettersentdate_month.disabled = true;
	document.editcommitment.lettersentdate_day.disabled = true;
	document.editcommitment.lettersentdate_year.disabled = true;
	document.editcommitment.letteraddressee.disabled = true;
	document.editcommitment.letterorganizationid.disabled = true;
    }
    function enableletter() {
	document.editcommitment.letteraccessionnum.disabled = false;
	document.editcommitment.lettersigner.disabled = false;
	document.editcommitment.lettersigneddate_month.disabled = false;
	document.editcommitment.lettersigneddate_day.disabled = false;
	document.editcommitment.lettersigneddate_year.disabled = false;
	document.editcommitment.lettersentdate_month.disabled = false;
	document.editcommitment.lettersentdate_day.disabled = false;
	document.editcommitment.lettersentdate_year.disabled = false;
	document.editcommitment.letteraddressee.disabled = false;
	document.editcommitment.letterorganizationid.disabled = false;
    }
    function fillout_letter() {
	var validateform = document.editcommitment;
	var tempcgiaction;
	tempcgiaction = document.editcommitment.cgiaction.value;
	document.editcommitment.cgiaction.value = "fillout_letter";
	document.editcommitment.submit();
	document.editcommitment.cgiaction.value = tempcgiaction;
	return (true);
    }
    function checkletter (letterselection) {
	if (letterselection.value!="NEW") {
	    if (letterselection.value != '') {
		clearletter();
		disableletter();
		fillout_letter();
	    }
	    else {
		clearletter();
		disableletter();
	    }
	}
	else {
	    clearletter();
	    enableletter();
	}
    }
    function validate_commitment_data() {
	var msg = "";
	var tmpmsg = "";
	var returnvalue = true;
	var validateform = document.editcommitment;
	msg += (validateform.responsetext.value=="") ? "You must enter the text of the closure letter.\\n" : "";
	msg += ((tmpmsg = validate_date(validateform.responsewrittendate_year.value, validateform.responsewrittendate_month.value, validateform.responsewrittendate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Date Response Was Written - " + tmpmsg + "\\n";
    msg += (validateform.finaldocumentimage.value=="" && validateform.commitmenthasimage.value == 0) ? "You must enter the image for the closing letter.\\n" : "";
	msg += (validateform.letterid.value=='') ? "You must enter the information about the letter that this response and image come from or select an existing letter.\\n" : "";
	if (validateform.letterid.value=="NEW") {
	    msg += ((tmpmsg = validate_accession_number(validateform.letteraccessionnum.value,true)) == "") ? "" : "Letter Accession Number - " + tmpmsg + "\\n";
	    msg += ((tmpmsg = validate_date(validateform.lettersentdate_year.value, validateform.lettersentdate_month.value, validateform.lettersentdate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Letter Sent Date - " + tmpmsg + "\\n";
	    msg += (validateform.letteraddressee.value=="") ? "You must enter the addressee of the letter.\\n" : "";
	    msg += ((tmpmsg = validate_date(validateform.lettersigneddate_year.value, validateform.lettersigneddate_month.value, validateform.lettersigneddate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : "Letter Signed Date - " + tmpmsg + "\\n";
	    msg += (validateform.lettersigner.value=="") ? "You must select the signer of the letter.\\n" : "";
	    msg += (validateform.letterorganizationid.value=='') ? "You must select the organization the letter was sent to.\\n" : "";
	}
	if (msg != "") {
	    alert(msg);
	    returnvalue = false;
	}
	return (returnvalue);
    }
    
    function pass_on() {
	var tempcgiaction;
	var returnvalue = true;
	if (validate_commitment_data()) {
	    tempcgiaction = document.editcommitment.cgiaction.value;
	    document.editcommitment.cgiaction.value = "pass_on";
	    document.editcommitment.submit();
	    document.editcommitment.cgiaction.value = tempcgiaction;
	}
	else {
	    returnvalue = false;
	}
	return (returnvalue);
    }

    function save_letter() {
	var tempcgiaction;
	var returnvalue = true;
	var msg = "";
	if (document.editcommitment.responsetext.value == "") {
	    msg += "You must enter the text of the response\\n";
	}
	if (document.editcommitment.letterid.value == "" && document.editcommitment.responsetext.value > "") {
	    msg+= "You must select the closing letter\\n";
	}
	if (msg != "") {
	    alert (msg);
	    returnvalue = false;
	}
	else {
	    tempcgiaction = document.editcommitment.cgiaction.value;
	    document.editcommitment.cgiaction.value = "save_letter";
	    document.editcommitment.submit();
	    document.editcommitment.cgiaction.value=tempcgiaction;
	}
	return (returnvalue);
    }
    //-->
    </script>
    </head>
    <body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
    <table border=0 align=center width=650><tr><td>
    <form name=editcommitment enctype="multipart/form-data" method=post target="control" action="$ONCSCGIDir/DOECMgr_closeresponse.pl">
    <input name=cgiaction type=hidden value="resubmit_commitment">
    <input name=loginusersid type=hidden value=$usersid>
    <input name=loginusername type=hidden value=$username>
    <input name=commitmentid type=hidden value=$commitmentid>
    <input name=statusid type=hidden value=$statusid>
    <input type=hidden name=schema value=$SCHEMA>
committable

    print "<table align=center width=100% border=0 cellspacing=10>\n";
    my $outstring;
    eval {
	print &doIssueTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
	print &doIssueSourceTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
	print &doHeadTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA, cidstring => $commitmentidstring);
        my ($actcount) = $dbh -> selectrow_array ("select count (*) from $SCHEMA.action where commitmentid = $commitmentid");
        if ($actcount) {
            my $count = 0;
            my $header;
            my $curracts = $dbh -> prepare ("select actionid from $SCHEMA.action where commitmentid=$commitmentid order by actionid");
            $curracts -> execute;
            while (my ($curractid) = $curracts -> fetchrow_array) {
                $header = ($count) ? 0 : 1;
                print doActionsTable (cid => $commitmentid, aid => $curractid, dbh => $dbh, schema => $SCHEMA, header => $header);
                $count++;
            }
            $curracts -> finish;
        }
        else {
            print "<tr><td><b><li>Actions:</b>&nbsp;&nbsp;None\n</td></tr>"
        }
	print &doProcessingTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
	print &doResponseTable (cid => $commitmentid, dbh => $dbh);
        ####  Print the Closeout Letter Table  ####
	print "<tr><td><br><hr width=50%><p>\n";
	print "<h3 align=center>Closing Letter Information</h3>\n";
	print writeResponse (cid => $commitmentid, dbh => $dbh, rtype => 'Closing');
	if ($chasimage) {   ####  if there is an image, retrieve for display
	    my $image = $CMSFullImagePath . "/commitmentfinalimage$commitmentid$imgext";
	    if (open (OUTFILE, "| ./File_Utilities.pl --command writeFile --protection 0664 --fullFilePath $image")) {
		print OUTFILE get_final_image($dbh, $commitmentid);
		close OUTFILE;
	    }
	    else {
		print "could not open file $image<br>\n";
	    }
	    print "<tr><td align=left><b><li>Closing Document Image</b>&nbsp;&nbsp;\n";
	    print "<a href='$CMSImagePath/commitmentfinalimage$commitmentid$imgext' target=imagewin>Click for the image file</a>\n";
	    print "<input type=file name=finaldocumentimage size=50 maxlength=256>\n";
	    print "<br>\n(Select different image if necessary)\n</td></tr>\n";
	}
	else {
	    print"<tr><td align=left><b><li>Closing Document Image:</b><br>\n";
	    print"<input type=file name=finaldocumentimage size=50 maxlength=256></td></tr>\n";
	}
	print "<input type=hidden name=commitmenthasimage value=$chasimage>\n";
	print "</td></tr>\n";
	print "<tr><td><hr width=50%></td></tr>\n";
	print "<script language=\"JavaScript\" type=\"text/javascript\"><!--\n";
	print "    disableletter();\n";
	print "//-->\n</script>\n";
        print "<tr><td><table width=650 align=center>\n";
	print &writeComment ();
	print doRemarksTable (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid);
    };
    if ($@) {
	my $logmessage = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$logmessage =~ s/\n/\\n/g;
	$logmessage =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$logmessage');\n";
        print "//--></script>\n";
    }
    print "</td></tr></table>\n<center>\n";
    print "<input type=button name=saveletter value=\"Save Draft Work\" title=\"Save response and letter information; can be edited later\" onclick=\"return(save_letter())\">\n";
    print "<input type=button name=saveandcomplete value=\"Complete Commitment Closure\" title=\"Save the information regarding the closure letter for this commitment.\" onclick=\"return(pass_on())\">\n";
    print "</td></tr></table>\n";
    print "</form> \n<br><br><br> \n </body> \n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
} #### endif editcommitment  ####

##################################
if ($cgiaction eq "save_letter") {
##################################
    no strict 'refs';

    my $commitmentid =  $cmscgi->param('commitmentid');

    my $activity;
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);
    my $chasresponse = ($cmscgi->param('commitmenthasresponse') == 1) ? -1 : 0;
    my $chasimage = ($cmscgi -> param ('commitmenthasimage') == 1) ? -1 : 0;

    #commitment variables
    my $finaldocumentimagefile;
    my $imagecontenttype;
    my $imageextension;
    my $imagesize;
    my $imagedata;
    my $imageinsertstring;
    $finaldocumentimagefile = $cmscgi->param('finaldocumentimage');
    my $comments = $cmscgi->param('commenttext');

    # response variables
    my $responseid;
    eval {
	$responseid = ($chasresponse) ? $cmscgi -> param ('responseid') : get_next_id($dbh, 'response');
    };
    my $responsetext = $cmscgi->param('responsetext');
    my $responsetextsql = ($responsetext) ? ":responsetextclob" : "NULL";
    my $responsewrittendate = $cmscgi->param('responsewrittendate');
    $responsewrittendate = ($responsewrittendate eq "") ? "NULL" : "TO_DATE('$responsewrittendate', 'MM/DD/YYYY')";

    # letter variables
    my $letterid;
    my $letteraccessionnum;
    my $lettersentdate;
    my $letteraddressee;
    my $lettersigneddate;
    my $lettersigner;
    my $letterorganizationid;
    my $letterisnew;
    $letterid = $cmscgi->param('letterid');
    $letterisnew = ($letterid eq 'NEW');
    eval {
	$letterid = ($letterisnew) ? get_next_id($dbh, 'letter') : $letterid;
    };
    $letteraccessionnum = $cmscgi->param('letteraccessionnum');
    $letteraccessionnum =~ s/\'/\'\'/g;
    $lettersentdate = $cmscgi->param('lettersentdate');
    $lettersentdate = ($lettersentdate eq "") ? "NULL" : "TO_DATE('$lettersentdate', 'MM/DD/YYYY')";
    $letteraddressee = $cmscgi->param('letteraddressee');
    $letteraddressee =~ s/\'/\'\'/g;
    $lettersigneddate = $cmscgi->param('lettersigneddate');
    $lettersigneddate = ($lettersigneddate eq "") ? "NULL" : "TO_DATE('$lettersigneddate', 'MM/DD/YYYY')";
    $lettersigner = $cmscgi->param('lettersigner');
    $letterorganizationid = $cmscgi->param('letterorganizationid');
    
    #process image file
    if ($finaldocumentimagefile) {
	my $bytesread = 0;
	my $buffer = '';
	# read a 16 K chunk and append the data to the variable $filedata
	while ($bytesread = read($finaldocumentimagefile, $buffer, 16384)) {
	    $imagedata .= $buffer;
	    $imagesize += $bytesread;
	}
	$imagecontenttype = $cmscgi->uploadInfo($finaldocumentimagefile)->{'Content-Type'};
	$imagecontenttype =~ s/\'/\'\'/g;
	$imagecontenttype = "'$imagecontenttype'";
	$finaldocumentimagefile =~ /.*\\.*(\..*)/;
	$imageextension = "'" . $1 . "'";
	$imageinsertstring = ":imgblob";
    }    
    #sql strings
    my $lettersqlstring;
    my $responsesqlstring;
    my $commitmentupdatesql;
    if ($finaldocumentimagefile) {
	$commitmentupdatesql = "UPDATE $SCHEMA.commitment
                                SET closingdocimage = $imageinsertstring,
                                    imagecontenttype = $imagecontenttype,
                                    imageextension = $imageextension,
                                    updatedby = $usersid
                                WHERE commitmentid = $commitmentid";
    }
    else {
	$commitmentupdatesql = "UPDATE $SCHEMA.commitment
                                set updatedby = $usersid
                                where commitmentid = $commitmentid";
    }
    if ($chasresponse) {
	$responsesqlstring = "update $SCHEMA.response
                              set text = $responsetextsql,
                                  writtendate = $responsewrittendate,
                                  letterid = $letterid,
                                  isfirst = 'F'
                              where responseid = $responseid";
    }
    else {
	$responsesqlstring = "INSERT INTO $SCHEMA.response 
                                     (responseid, text, writtendate, 
                                      commitmentid, letterid, isfirst)
                              VALUES ($responseid, $responsetextsql, 
                                      $responsewrittendate,
                                      $commitmentid, $letterid, 'F')";
    }
    $lettersqlstring = "INSERT INTO $SCHEMA.letter 
                               (letterid, accessionnum, sentdate, addressee,
                                signeddate, organizationid, signer)
                        VALUES ($letterid, '$letteraccessionnum', 
                                $lettersentdate, '$letteraddressee',
                                $lettersigneddate, $letterorganizationid, 
                                $lettersigner)";
    eval {
	my $csr;
	if ($letterisnew) {
	    # must add the letter before adding the response
	    $activity = "Insert Letter";
	    $csr = $dbh->prepare($lettersqlstring);
	    $csr->execute;
	}
	#insert the response
	$activity = "Insert/Update Response";
	$csr = $dbh->prepare($responsesqlstring);
	$csr->bind_param(":responsetextclob", $responsetext, {ora_type => ORA_CLOB, ora_field => 'text'});
	$csr->execute;
	
	$activity = "Update Commitment";
	$csr = $dbh->prepare($commitmentupdatesql);
	if ($finaldocumentimagefile) {
	    $csr->bind_param(":imgblob", $imagedata, {ora_type => ORA_BLOB, ora_field => 'closingdocimage' });
	}
	$csr->execute;
	
        # update commitment remarks
	if ($comments) {
	    my $remarkupdate = "insert into $SCHEMA.commitment_remarks (usersid, text, dateentered, commitmentid) values ($usersid, :remarks, SYSDATE, $commitmentid)";
	    $activity = "Update remarks for commitment $commitmentid";
	    $csr = $dbh -> prepare ($remarkupdate);
	    $csr -> bind_param (":remarks", $comments, {ora_type => ORA_CLOB, ora_field => 'text'});
	    $csr -> execute;
	}
	$csr->finish;
	$dbh->commit;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'commitment', "$commitmentid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print <<pageerror;
	<script language="JavaScript" type="text/javascript">
        <!--
        alert("$alertstring");
    parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageerror
    }
    else {
	my $logmessage = "Commitment ". &formatID2($commitmentid, 'C') . " updated by the Commitment Manager";
	my $logtitle = "Commitment Finalized";
     	&log_activity($dbh, 'F', $usersid, $logmessage);
	print <<pageresults;
	<script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
}
    &oncs_disconnect($dbh);
    print "</head><body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0></body></html>\n";
    exit 1;
}

##############################
if ($cgiaction eq "pass_on") {
##############################
    no strict 'refs';

    #control variables
    my $commitmentid =  $cmscgi->param('commitmentid');
    my $activity;

    # Find pertinent user information
    # Site id of the user is the same for the commitment
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);
    my $chasresponse = ($cmscgi->param('commitmenthasresponse') == 1) ? -1 : 0;
    my $chasimage = ($cmscgi -> param ('commitmenthasimage') == 1) ? -1 : 0;

    #commitment variables
    my $finaldocumentimagefile;
    my $imagecontenttype;
    my $imageextension;
    my $imagesize;
    my $imagedata;
    my $imageinsertstring;
    $finaldocumentimagefile = $cmscgi->param('finaldocumentimage');
    my $comments = $cmscgi->param('commenttext');

    # response variables
    my $responseid;
    eval {
	$responseid = ($chasresponse) ? ($cmscgi -> param ('responseid')) : get_next_id($dbh, 'response');
    };
    my $responsetext = $cmscgi->param('responsetext');
    my $responsetextsql = ($responsetext) ? ":responsetextclob" : "NULL";
    my $responsewrittendate = $cmscgi->param('responsewrittendate');
    $responsewrittendate = ($responsewrittendate eq "") ? "NULL" : "TO_DATE('$responsewrittendate', 'MM/DD/YYYY')";

    # letter variables
    my $letterid;
    my $letteraccessionnum;
    my $lettersentdate;
    my $letteraddressee;
    my $lettersigneddate;
    my $lettersigner;
    my $letterorganizationid;
    my $letterisnew;
    $letterid = $cmscgi->param('letterid');
    eval {
	$letterisnew = ($letterid eq 'NEW');
    };
    $letterid = ($letterisnew) ? get_next_id($dbh, 'letter') : $letterid;
    $letteraccessionnum = $cmscgi->param('letteraccessionnum');
    $letteraccessionnum =~ s/\'/\'\'/g;
    $lettersentdate = $cmscgi->param('lettersentdate');
    $lettersentdate = ($lettersentdate eq "") ? "NULL" : "TO_DATE('$lettersentdate', 'MM/DD/YYYY')";
    $letteraddressee = $cmscgi->param('letteraddressee');
    $letteraddressee =~ s/\'/\'\'/g;
    $lettersigneddate = $cmscgi->param('lettersigneddate');
    $lettersigneddate = ($lettersigneddate eq "") ? "NULL" : "TO_DATE('$lettersigneddate', 'MM/DD/YYYY')";
    $lettersigner = $cmscgi->param('lettersigner');
    $letterorganizationid = $cmscgi->param('letterorganizationid');
    
    #process image file
    if ($finaldocumentimagefile) {
	my $bytesread = 0;
	my $buffer = '';
	# read a 16 K chunk and append the data to the variable $filedata
	while ($bytesread = read($finaldocumentimagefile, $buffer, 16384)) {
	    $imagedata .= $buffer;
	    $imagesize += $bytesread;
	}
	$imagecontenttype = $cmscgi->uploadInfo($finaldocumentimagefile)->{'Content-Type'};
	$imagecontenttype =~ s/\'/\'\'/g;
	$imagecontenttype = "'$imagecontenttype'";
	$finaldocumentimagefile =~ /.*\\.*(\..*)/;
	$imageextension = "'" . $1 . "'";
	$imageinsertstring = ":imgblob";
    }
    my $nextstatusid = 16; # Closed
    
    #sql strings
    my $lettersqlstring;
    my $responsesqlstring;
    my $commitmentupdatesql;
    if (!$chasimage) {
	$commitmentupdatesql = "UPDATE $SCHEMA.commitment
                                SET closingdocimage = $imageinsertstring,
                                    imagecontenttype = $imagecontenttype,
                                    imageextension = $imageextension,
                                    statusid = $nextstatusid,
                                    updatedby = $usersid
                                WHERE commitmentid = $commitmentid";
    }
    else {
	$commitmentupdatesql = "update $SCHEMA.commitment
                                set statusid = $nextstatusid,
                                    updatedby = $usersid
                                where commitmentid = $commitmentid";
    }
    if ($chasresponse) {
	$responsesqlstring = "update $SCHEMA.response
                              set text = $responsetextsql,
                                  writtendate = $responsewrittendate,
                                  letterid = $letterid
                              where responseid = $responseid";
    }
    else {
	$responsesqlstring = "INSERT INTO $SCHEMA.response 
                                     (responseid, text, writtendate, 
                                      commitmentid, letterid)
                              VALUES ($responseid, $responsetextsql, 
                                      $responsewrittendate,
                                      $commitmentid, $letterid)";
    }
    $lettersqlstring = "INSERT INTO $SCHEMA.letter 
                               (letterid, accessionnum, sentdate, addressee,
                                signeddate, organizationid, signer)
                        VALUES ($letterid, '$letteraccessionnum', 
                                $lettersentdate, '$letteraddressee',
                                $lettersigneddate, $letterorganizationid, 
                                $lettersigner)";
    eval {
	my $csr;
	if ($letterisnew) {
	    # must add the letter before adding the response
	    $activity = "Insert Letter";
	    $csr = $dbh->prepare($lettersqlstring);
	    $csr->execute;
	}
	#insert the response
	$activity = "Insert/Update Response";
	$csr = $dbh->prepare($responsesqlstring);
	$csr->bind_param(":responsetextclob", $responsetext, {ora_type => ORA_CLOB, ora_field => 'text'});
	$csr->execute;

	$activity = "Finalize Commitment";
	$csr = $dbh->prepare($commitmentupdatesql);
	if (!$chasimage) {
	    $csr->bind_param(":imgblob", $imagedata, {ora_type => ORA_BLOB, ora_field => 'closingdocimage' });
	}
	$csr->execute;

        # update commitment remarks
	if ($comments) {
	    my $remarkupdate = "insert into $SCHEMA.commitment_remarks (usersid, text, dateentered, commitmentid) values ($usersid, :remarks, SYSDATE, $commitmentid)";
	    $activity = "Update remarks for commitment $commitmentid";
	    $csr = $dbh -> prepare ($remarkupdate);
	    $csr -> bind_param (":remarks", $comments, {ora_type => ORA_CLOB, ora_field => 'text'});
	    $csr -> execute;
	}
	$csr->finish;
	$dbh->commit;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'commitment', "$commitmentid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print <<pageerror;
	<script language="JavaScript" type="text/javascript">
        <!--
        alert("$alertstring");
    parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageerror
    }
    else {
	my $logmessage = "Final document appended to Commitment " . &formatID2($commitmentid, 'C');
	my $logtitle = "Commitment Finalized";
     	&log_activity($dbh, 'F', $usersid, $logmessage);
	print <<pageresults;
	<script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="$ONCSCGIDir/home.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
    }
    &oncs_disconnect($dbh);
    print "</head><body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0></body></html>\n";
    exit 1;
}  #### endif pass_on  ####
