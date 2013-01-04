#!/usr/local/bin/newperl
#
# CMS Issue Source Document Entry Screen
#
# $Source: /data/dev/cirs/perl/RCS/newsource.pl,v $
# $Revision: 1.3 $
# $Date: 2001/01/30 23:43:33 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: newsource.pl,v $
# Revision 1.3  2001/01/30 23:43:33  naydenoa
# Took out source category as per Sheryl's clarification
#
# Revision 1.2  2001/01/22 22:00:36  naydenoa
# Removed category references.
#
# Revision 1.1  2000/10/23 18:14:30  naydenoa
# Initial revision
#
#
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
tie my %lookup_values, "Tie::IxHash";

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

# print content type header
print $cmscgi->header('text/html');

my $cgiaction = $cmscgi->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "sourcentry" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = "sourcedoc";

# my $sourcedocid = ((defined($cmscgi->param("sourcedocidid"))) ? $cmscgi->param("sourcedocid") : "");
my $message = '';

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
print "<title></title>\n";

print <<testlabel1;
<!-- include external javascript code -->
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>

    <script type="text/javascript">
    <!--
    var dosubmit = true;
    if (parent == self) { // not in frames
        location = '$ONCSCGIDir/login.pl'
    }
    function submitForm(script, command) {
	document.$form.cgiaction.value = command;
	document.$form.action = '$path' + script + '.pl';
	document.$form.target = 'workspace';
	document.$form.submit();
    }
    //-->
    </script>
    <script language="JavaScript" type="text/javascript">
    <!--
      doSetTextImageLabel('Source Document Entry');
    //-->
    </script>

testlabel1

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();
$dbh->{RaiseError} = 1;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 1000;
print "</head>\n<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

#################################
if ($cgiaction eq "sourcentry") {
#################################

    my %sourcedochash = get_lookup_values($dbh, 'sourcedoc', "accessionnum || ' - ' || title || ' - ' || to_char(documentdate, 'MM/DD/YYYY') || ';' || sourcedocid", 'sourcedocid');
    my $key = '';
    my %orghash = get_lookup_values($dbh, 'organization', "name || ';' || organizationid", 'organizationid');

    print<<somejavascripts;
    <script language="JavaScript" type="text/javascript"><!--

    function update_source_table() {
        var tempcgiaction;
        var returnvalue = true;

	if (validate_source_data()) {
	    document.newsource.cgiaction.value = "updatesourcetable";
            submitForm ('newsource', 'updatesourcetable');
	}
	else {
	    returnvalue = false;
	}
	return (returnvalue);
    }
    function validate_source_data() {
	var msg = "";
	var tmpmsg = "";
	var returnvalue = true;
	var validateform = document.newsource;

	msg += ((tmpmsg = validate_accession_number(validateform.accessionnum.value,true)) == "") ? "" : tmpmsg + "\\n";
	msg += (validateform.title.value=="") ? "You must enter the title of the source document.\\n" : "";
	msg += (validateform.signer.value=="") ? "You must enter the signer of the source document.\\n" : "";
	msg += ((validateform.areacode.value != "") && (validateform.areacode.value.length < 3)) ? "You have enterd an invalid area code.\\n" : "";
	msg += ((validateform.phonenumber.value != "") && (validateform.phonenumber.value.length < 7)) ? "You have enterd an invalid phone number.\\n" : "";
	msg += ((tmpmsg = validate_date(validateform.documentdate_year.value, validateform.documentdate_month.value, validateform.documentdate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : tmpmsg + "\\n";
	msg += (validateform.organizationid.value=='') ? "You must select the organization the source document came from.\\n" : "";
	if (msg != "") {
	    alert(msg);
	    returnvalue = false;
        }
	return (returnvalue);
    }
    
//-->
</script>
somejavascripts

    print <<sourceform1;
    <form target=control action="$ONCSCGIDir/newsource.pl" enctype="multipart/form-data" method=post name=newsource>
    <input name=cgiaction type=hidden value="updatesourcetable">
    <input name=loginusersid type=hidden value=$usersid>
    <input name=loginusername type=hidden value=$username>
    <input type=hidden name=schema value=$SCHEMA>
    <br><center>
    <table summary="source table" width=750 align=center cellspacing=10 border=0>
    <tr><td><table width=700 align=center cellspacing=10>
    <tr><td align=left><b><li>Accession Number:</b>&nbsp;&nbsp;
    <input type=text name=accessionnum size=17 maxlength=17> &nbsp; &nbsp; (optional)</td></tr>
    <tr><td align=left><b><li>Document Title: &nbsp; &nbsp;</b>
    <textarea name=title cols=60 rows=1 onblur="if(document.newsource.title.value.length > 1000)\{alert('Only 1000 characters allowed in a title');document.newsource.title.focus();\}"></textarea></td></tr>
    <tr><td align=left><b><li>Signer:&nbsp;&nbsp;</b>
    <input type=text name=signer size=30 maxlength=30></td></tr>
    <tr><td align=left><b><li>Signer's Email Address:&nbsp &nbsp</b>
    <input type=text name=emailaddress size=50 maxlength=50>
    &nbsp; &nbsp; (optional)</td></tr>
    <tr><td align=left><b><li>Area Code:</b>&nbsp;&nbsp;
    (<input type=text name=areacode size=3 maxlength=3>)
    &nbsp;&nbsp;&nbsp;<b>Phone Number:&nbsp;&nbsp;</b>
    <input type=text name=phonenumber size=7 maxlength=7>  (no hyphens)
    &nbsp; &nbsp; (optional)</td></tr>
    <tr><td align=left><b><li>Document Date:&nbsp;&nbsp;</b>
sourceform1

    print build_date_selection('documentdate', 'newsource');
    print <<source3;
    &nbsp; &nbsp; (Enter 1st if not available)</td></tr>
    <tr><td align=left><b><li>Originator Organization:&nbsp;&nbsp;</b>
    <select name=organizationid>
    <option value='' selected>Select An Organization
source3
    foreach $key (sort keys %orghash) {
        my $orgdescription = $key;
        $orgdescription =~ s/;$orghash{$key}//g;
        print "<option value=\"$orghash{$key}\">$orgdescription\n";
    }
    print "</select></td></tr>\n";

print<<sourcebutton;
<tr><td><br><br><center>
<input type=button name=submitupdate value="Submit New Source Document" title="Post Source Entry" onClick="update_source_table();">
</center></td></tr></table></form><br><br><br><br></body></html>
sourcebutton

&oncs_disconnect ($dbh);
exit 1;
}  ###############  endif sourceupdate  ################

########################################
if ($cgiaction eq "updatesourcetable") {
########################################
    no strict 'refs';

    my $sourcedocid;

    # source document variables
    my $accessionnum = $cmscgi->param('accessionnum');
    my $title = $cmscgi->param('title');
    $title =~ s/\'/\'\'/g;
    my $signer = $cmscgi->param('signer');
    $signer =~ s/\'/\'\'/g;
    my $email = $cmscgi->param('emailaddress');
    $email =~ s/\'/\'\'/g;
    my $areacode = $cmscgi->param('areacode');
    my $phonenumber = $cmscgi->param('phonenumber');
    my $documentdate = $cmscgi->param('documentdate');
    my $sourceorganizationid = $cmscgi->param('organizationid');
############
    my $sourcesqlstring;
    my $activity;

    $activity = "Get Next Sourcedoc Sequence";
    $dbh->{RaiseError} = 1;
    $dbh->{AutoCommit} = 0;
    eval {
        $sourcedocid = get_next_id($dbh, 'sourcedoc');
    };
    if ($@) {
        my $alertstring = errorMessage($dbh, $username, $usersid, 'sourcedocid_seq', "", $activity, $@);
        print <<sourcedocseqerror;
        <script language="JavaScript" type="text/javascript">
        <!--
            alert("$alertstring");
            parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
            //-->
        </script>
sourcedocseqerror
            $dbh->commit;
        &oncs_disconnect($dbh);
        exit 1;
    }
    $dbh->{RaiseError} = 0;
    $dbh->{AutoCommit} = 1;
    $email = ($email) ? "'$email'" : 'NULL';
    $areacode = ($areacode) ? "'$areacode'" : 'NULL';
    $phonenumber = ($phonenumber) ? "'$phonenumber'" : 'NULL';

    $sourcesqlstring = "INSERT INTO $SCHEMA.sourcedoc
                               (sourcedocid, accessionnum, title, signer,
                                    email, areacode, phonenumber, documentdate,
                                    organizationid)
                            VALUES ($sourcedocid, '$accessionnum',
                                   '$title', '$signer',
                                    $email, $areacode, $phonenumber,
                                    TO_DATE('$documentdate', 'MM/DD/YYYY'),
                                    $sourceorganizationid)";


    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
    my $activity;
    eval {
        $activity = "Insert Source Document Information: $sourcedocid";
        my $sourcecsr = $dbh->prepare($sourcesqlstring);
        $sourcecsr->execute;
        $sourcecsr->finish;
    };
    if ($@) {
        $dbh->rollback;
        my $alertstring = errorMessage($dbh, $username, $usersid, 'sourcedoc', "$sourcedocid", $activity, $@);
        $alertstring =~ s/\"/\'/g;
        print <<pageerror;
        <script language="JavaScript" type="text/javascript">
        <!--
        alert("$alertstring");
        //parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageerror
    }
    else {
        &log_activity ($dbh, 'F', $usersid, "Source Document " . formatID2($sourcedocid,'S') . " inserted by user $username");
        print <<pageresults;
        <script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="$ONCSCGIDir/utilities.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
    }
    $dbh->commit;
    $dbh->{AutoCommit} = 1;
    $dbh->{RaiseError} = 0;

    &oncs_disconnect($dbh);
    exit 1;
}

print "</form><br><br><br><br></body></html>\n";
&oncs_disconnect($dbh);
