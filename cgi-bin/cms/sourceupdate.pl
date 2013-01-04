#!/usr/local/bin/newperl
#
# CMS Issue Source Document Update Screen
#
# $Source: /data/dev/cirs/perl/RCS/sourceupdate.pl,v $
# $Revision: 1.6 $
# $Date: 2001/01/30 23:50:49 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: sourceupdate.pl,v $
# Revision 1.6  2001/01/30 23:50:49  naydenoa
# Took out source category (inactive column)
#
# Revision 1.5  2001/01/22 22:24:41  naydenoa
# Removed references to source category.
#
# Revision 1.4  2000/10/24 15:21:28  naydenoa
# Changed log message
#
# Revision 1.3  2000/10/18 21:34:35  munroeb
# modified activity log message
#
# Revision 1.2  2000/10/17 17:13:10  naydenoa
# Cleaned up code, fixed html bug, took out log_history call
#
# Revision 1.1  2000/10/10 22:49:41  naydenoa
# Initial revision
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
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = "sourcedoc";

my $sourcedocid = ((defined($cmscgi->param("sourcedocidid"))) ? $cmscgi->param("sourcedocid") : "");
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
    function submitFormCGIResults(script, command) {
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'control';
    document.$form.submit();
    }
    function submitFormWorkspace(script, command) {
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'workspace';
    document.$form.submit();
    }
    function processQuery() {
    if (document.$form.selectedsource.selectedIndex == -1 || document.$form.selectedsource.options[document.$form.selectedsource.options.length - 1].selected == 1) {
        alert ('You must first select a source document');
    }
    else {
        document.$form.sourcedocid.value = document.$form.selectedsource[document.$form.selectedsource.selectedIndex].value;
        submitForm('$form','sourceupdate');
    }
    }
    //-->
  </script>
  <script language="JavaScript" type="text/javascript">
  <!--
      doSetTextImageLabel('Source Document Update');
  //-->
</script>

testlabel1

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();
$dbh->{RaiseError} = 1;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 1000;
print "</head>\n<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

############################
if ($cgiaction eq "query") {
############################

print<<testlabel1;
<table border=0 align=center width=750><tr><td>
<center>
<form name=$form enctype="multipart/form-data" method=post target="control">
<input name=cgiaction type=hidden value="query">
<input name=loginusersid type=hidden value=$usersid>
<input name=loginusername type=hidden value=$username>
<input name=sourcedocid type=hidden value=$sourcedocid>
<input type=hidden name=schema value=$SCHEMA>
testlabel1
    eval {
        print "<br><br><b>Source Documents:</b><br><br>\n";
        print "<select size=10 name=selectedsource onDblClick=\"processQuery();\">\n";
        %lookup_values = get_lookup_values($dbh, "sourcedoc", 'sourcedocid', "accessionnum || ' - ' || title", "1=1 order by accessionnum");
        foreach my $key (keys %lookup_values) {
            print "<option value=$key>" . getDisplayString($lookup_values{$key},60) . "</option>\n";
        }
        print "<option value=blank>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; \n";
        print "</select><br><br><br>\n";
        print "<input type=button name=querysubmit value='Update Source Document' onClick=\"processQuery();\">\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"source document update -- query page",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/\'/\'\'/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script></form>\n";
    }
&oncs_disconnect($dbh);
}

###################################
if ($cgiaction eq "sourceupdate") {
###################################

    my $sourcedocid = $cmscgi -> param ('sourcedocid');
    my $sourcestring = substr ("0000" . $sourcedocid, -5);
    my %sourcedochash = get_lookup_values($dbh, 'sourcedoc', "accessionnum || ' - ' || title || ' - ' || to_char(documentdate, 'MM/DD/YYYY') || ';' || sourcedocid", 'sourcedocid');
    my $key = '';
    my %orghash = get_lookup_values($dbh, 'organization', "name || ';' || organizationid", 'organizationid');

    my %sourceinfohash = get_sourcedoc_info ($dbh, $sourcedocid);
    my $sourceaccnum = $sourceinfohash{'accessionnum'};
    my $sourcetitle = $sourceinfohash{'title'};
    my $sourcesigner = $sourceinfohash{'signer'};
    my $sourceemail = $sourceinfohash{'email'};
    my $sourcearea = $sourceinfohash{'areacode'};
    my $sourcephone = $sourceinfohash{'phonenumber'};
    my $sourcedate = $sourceinfohash{'documentdate'};
    my $sourceorgid = $sourceinfohash{'organizationid'};

    print<<somejavascripts;
    <script language="JavaScript" type="text/javascript"><!--

    function update_source_table() {
        var tempcgiaction;
        var returnvalue = true;

    if (validate_source_data()) {
        document.sourceupdate.cgiaction.value = "updatesourcetable";
            submitForm ('sourceupdate', 'updatesourcetable');
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
    var validateform = document.sourceupdate;

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
    <form target=control action="$ONCSCGIDir/sourceupdate.pl" enctype="multipart/form-data" method=post name=sourceupdate>
    <input name=cgiaction type=hidden value="updatesourcetable">
    <input name=loginusersid type=hidden value=$usersid>
    <input name=loginusername type=hidden value=$username>
    <input name=sourcedocid type=hidden value=$sourcedocid>
    <input type=hidden name=schema value=$SCHEMA>
    <br><center>
    <table summary="source table" width=750 align=center cellspacing=10 border=0>
    <tr><td><table width=700 align=center cellspacing=10>
    <tr><td><b><li>Source Document ID: &nbsp;&nbsp; S$sourcestring</td></tr>
    <tr><td align=left><b><li>Accession Number:</b>&nbsp;&nbsp;
    <input type=text name=accessionnum size=17 maxlength=17> &nbsp; &nbsp; (optional)</td></tr>
    <tr><td align=left><b><li>Document Title: &nbsp; &nbsp;</b>
    <textarea name=title cols=60 rows=1 onblur="if(document.sourceupdate.title.value.length > 1000){alert('Only 1000 characters allowed in a title');document.sourceupdate.title.focus();}"></textarea></td></tr>
    <tr><td align=left><b><li>Signer:&nbsp;&nbsp;</b>
    <input type=text name=signer size=30 maxlength=30></td></tr>
    <tr><td align=left><b><li>Signer's Email Address:&nbsp;&nbsp;</b>
    <input type=text name=emailaddress size=50 maxlength=50>
    &nbsp; &nbsp; (optional)</td></tr>
    <tr><td align=left><b><li>Area Code:</b>&nbsp;&nbsp;
    (<input type=text name=areacode size=3 maxlength=3>)
    &nbsp;&nbsp;&nbsp;<b>Phone Number:&nbsp;&nbsp;</b>
    <input type=text name=phonenumber size=7 maxlength=7>  (no hyphens)
    &nbsp; &nbsp; (optional)</td></tr>
    <tr><td align=left><b><li>Document Date:&nbsp;&nbsp;</b>
sourceform1

    print build_date_selection('documentdate', 'sourceupdate', $sourcedate);
    print <<source3;
    &nbsp; &nbsp; (Enter 1st if not available)</td></tr>
    <tr><td align=left><b><li>Originator Organization:&nbsp;&nbsp;</b>
    <select name=organizationid>
    <option value=''>Select An Organization
source3
    foreach $key (sort keys %orghash) {
        my $orgdescription = $key;
        $orgdescription =~ s/;$orghash{$key}//g;
        if ($sourceorgid == $orghash{$key}) {
            print "<option value=\"$orghash{$key}\" selected>$orgdescription\n";
        }
        else {
            print "<option value=\"$orghash{$key}\">$orgdescription\n";
        }
    }
    print "</select></td></tr>\n";

    print<<javacheck;
    <script language="JavaScript" type="text/javascript"><!--

    function clearletter() {
        document.sourceupdate.accessionnum.value = "";
        document.sourceupdate.title.value = "";
        document.sourceupdate.signer.value = "";
        document.sourceupdate.emailaddress.value = "";
        document.sourceupdate.areacode.value = "";
        document.sourceupdate.phonenumber.value = "";
        document.sourceupdate.organizationid.value = "";
    }
    function enableletter() {
        document.sourceupdate.accessionnum.disabled = false;
        document.sourceupdate.title.disabled = false;
        document.sourceupdate.signer.disabled = false;
        document.sourceupdate.emailaddress.disabled = false;
        document.sourceupdate.areacode.disabled = false;
        document.sourceupdate.phonenumber.disabled = false;
        document.sourceupdate.documentdate_month.disabled = false;
        document.sourceupdate.documentdate_day.disabled = false;
        document.sourceupdate.documentdate_year.disabled = false;
        document.sourceupdate.organizationid.disabled = false;
    }
    function fillout_letter() {
        var validateform = document.sourceupdate;
        var tempcgiaction;

        tempcgiaction = document.sourceupdate.cgiaction.value;
        document.sourceupdate.cgiaction.value = "fillout_letter";
        document.sourceupdate.submit();
        document.sourceupdate.cgiaction.value = tempcgiaction;
        return (true);
    }
    function checkletter(letterselection) {
        if (letterselection.value!="NEW" && letterselection.value != ''){
            clearletter();
            enableletter();
            fillout_letter();
        }
        else {
            clearletter();
            enableletter();
        }
    }
    checkletter(document.sourceupdate.sourcedocid);
    //-->
    </script>
javacheck

print<<sourcebutton;
<tr><td><br><br><center>
<input type=button name=submitupdate value="Submit Update" title="Post Source Update" onClick="update_source_table();">
</center></td></tr></table></form><br><br><br><br></body></html>
sourcebutton

&oncs_disconnect ($dbh);
exit 1;
}  ###############  endif sourceupdate  ################


#####################################
if ($cgiaction eq "fillout_letter") {
#####################################
    #control variables
    my $sourcedocid = $cmscgi->param('sourcedocid');

    #sourcedoc variables
    my %sourcedocinfo = get_sourcedoc_info ($dbh, $sourcedocid);
    my $accessionnum = $sourcedocinfo{'accessionnum'};
    my $title = $sourcedocinfo{'title'};
    my $signer = $sourcedocinfo{'signer'};
    my $emailaddress = $sourcedocinfo{'email'};
    my $areacode = $sourcedocinfo{'areacode'};
    my $phone = $sourcedocinfo{'phonenumber'};
    my $organizationid = $sourcedocinfo{'organizationid'};
    my $docdate = $sourcedocinfo{'documentdate'};
    my $docmonth;
    my $docday;
    my $docyear;
    ($docmonth, $docday, $docyear) = split /\//, $docdate;

    print <<letterupdate1;
    <script language="JavaScript" type="text/javascript"><!--
    parent.workspace.sourceupdate.accessionnum.value='$accessionnum';
    parent.workspace.sourceupdate.title.value='$title';
    parent.workspace.sourceupdate.signer.value='$signer';
    parent.workspace.sourceupdate.emailaddress.value='$emailaddress';
    parent.workspace.sourceupdate.areacode.value='$areacode';
    parent.workspace.sourceupdate.phonenumber.value='$phone';
    parent.workspace.sourceupdate.documentdate_month.value=$docmonth;
    parent.workspace.sourceupdate.documentdate_day.value=$docday;
    parent.workspace.sourceupdate.documentdate_year.value=$docyear;
    parent.workspace.sourceupdate.organizationid.value=$organizationid;
    //-->
    </script>
letterupdate1
    &oncs_disconnect($dbh);
    exit 1;
} ####### endif fillout_letter  ###################


#######################################
if ($cgiaction eq "updatesourcetable") {
#######################################
    no strict 'refs';

    my $sourcedocid = $cmscgi -> param ('sourcedocid');
    my $newsource = ($sourcedocid eq 'NEW');

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
    my $processsourcedoc = 0;
    my $activity;
    if ($newsource) {
        # we've got to post the new source document information first
        $processsourcedoc = -1;  #true
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
    }
    else {
        $email = ($email) ? "'$email'" : 'NULL';
        $areacode = ($areacode) ? "'$areacode'" : 'NULL';
        $phonenumber = ($phonenumber) ? "'$phonenumber'" : 'NULL';
        $sourcesqlstring = "update $SCHEMA.sourcedoc
                            set accessionnum = '$accessionnum',
                                title = '$title',
                                signer = '$signer',
                                email = $email,
                                areacode = $areacode,
                                phonenumber = $phonenumber,
                                documentdate = to_date('$documentdate','MM/DD/YYYY'),
                                organizationid = $sourceorganizationid
                            where sourcedocid = $sourcedocid";
    }
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
    my $activity;
    eval {
        if ($processsourcedoc) {
            $activity = "Insert Source Document Information: $sourcedocid";
        }
        else {
            $activity = "Update Source Document Information : $sourcedocid";
        }
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
        //-->
        </script>
pageerror
    }
    else {
	&log_activity ($dbh, 'F', $usersid, "Source Document " . formatID2($sourcedocid,'S') . " updated by user $username");
	print <<pageresults;
	<script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="$ONCSCGIDir/sourceupdate.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
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
