#!/usr/local/bin/newperl
#
# CMS Response Update Screen
#
# $Source: /data/dev/cirs/perl/RCS/responseupdate.pl,v $
# $Revision: 1.5 $
# $Date: 2001/01/02 17:38:34 $
# $Author: naydenoa $
# $Locker:  $
#
# $Log: responseupdate.pl,v $
# Revision 1.5  2001/01/02 17:38:34  naydenoa
# Moved letter fill-out to Edit_Screens
#
# Revision 1.4  2000/10/24 15:20:14  naydenoa
# Updated javascripts, changed log message
#
# Revision 1.3  2000/10/18 23:51:31  munroeb
# fixed activity log message
#
# Revision 1.2  2000/10/18 23:03:28  naydenoa
# Updated validation
#
# Revision 1.1  2000/10/18 21:31:18  naydenoa
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
tie my %lookup_values_response, "Tie::IxHash";
tie my %lookup_values_first, "Tie::IxHash";
tie my %lookup_values_final, "Tie::IxHash";

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

# print content type header
print $cmscgi->header('text/html');

my $cgiaction = $cmscgi->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = "response";

my $commitmentid = ((defined ($cmscgi -> param ('commitmentid'))) ? $cmscgi -> param ('commitmentid') : "");
my $responseid = ((defined($cmscgi->param("responseid"))) ? $cmscgi->param("responseid") : "");
my $message = '';

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "")) {
    print "<script type=\"text/javascript\">\n";
    print "<!--\n";
    print "parent.location=\'$ONCSCGIDir/login.pl\';\n";
    print "//-->\n";
    print "</script>\n";
    exit 1;
}

print "<html>\n";
print "<head>\n";
print "<meta name=pragma content=no-cache>\n";
print "<meta name=expires content=0>\n";
print "<meta http-equiv=expires content=0>\n";
print "<meta http-equiv=pragma content=no-cache>\n";
print "<title>Response Update</title>\n";

print "<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>\n";
print "<script type=\"text/javascript\">\n";
print "<!--\n";
print "var dosubmit = true;\n";
print "if (parent == self) { // not in frames\n";
print "    location = \'$ONCSCGIDir/login.pl\'\n";
print "}\n";
print "function submitForm(script, command) {\n";
print "    document.$form.cgiaction.value = command;\n";
print "    document.$form.action = \'$path\' + script + \'.pl\';\n";
print "    document.$form.target = \'workspace\';\n";
print "    document.$form.submit();\n";
print "}\n";
print "function processQuery() {\n";
print "    if (document.$form.selectedcommitmentidfirst.options[document.$form.selectedcommitmentidfirst.options.length - 1].selected == 1 || document.$form.selectedcommitmentidfinal.options[document.$form.selectedcommitmentidfinal.options.length - 1].selected == 1) {\n";
print "        alert (\'You must first select a commitment\');\n";
print "    }\n";
print "    else if (document.$form.selectedcommitmentidfirst.selectedIndex >= 0) {\n";
print "        document.$form.commitmentid.value = document.$form.selectedcommitmentidfirst[document.$form.selectedcommitmentidfirst.selectedIndex].value;\n";
print "        submitForm(\'$form\',\'queryresponse\');\n";
print "    }\n";
print "    else if (document.$form.selectedcommitmentidfinal.selectedIndex >=0) {\n";
print "        document.$form.commitmentid.value = document.$form.selectedcommitmentidfinal[document.$form.selectedcommitmentidfinal.selectedIndex].value;\n";
print "        submitForm(\'$form\',\'queryresponse\');\n";
print "    }\n";
print "    else {\n";
print "        alert (\'You must first select a commitment\');\n";
print "    }\n";
print "}\n";
print "function processResponse() {\n";
print "    if (document.$form.selectedresponseid.selectedIndex == -1 || document.$form.selectedresponseid.options[document.$form.selectedresponseid.options.length - 1].selected == 1) {\n";
print "        alert (\'You must first select a commitment\');\n";
print "    }\n";
print "    else {\n";
print "        document.$form.responseid.value = document.$form.selectedresponseid[document.$form.selectedresponseid.selectedIndex].value;\n";
print "        submitForm(\'$form\',\'responseupdate\');\n";
print "    }\n";
print "}\n";
print "doSetTextImageLabel(\'Response Update\');\n";
print "//-->\n";
print "</script>\n\n";

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();
$dbh->{RaiseError} = 1;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 1000;

############################
if ($cgiaction eq "query") {
############################
    print "</head>\n<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<table border=0 align=center width=750><tr><td>\n<center>\n";
    print "<form name=$form enctype=\"multipart/form-data\" method=post target=\"control\">\n";
    print "<input name=cgiaction type=hidden value=\"query\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=commitmentid type=hidden value=$commitmentid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    eval {
        print "<br><br><b>Commitments with First Response:</b><br><br>\n";
        print "<select size=10 name=selectedcommitmentidfirst onDblClick=\"processQuery();\">\n";
        %lookup_values_first = get_lookup_values($dbh, "commitment", 'commitmentid', "text", "statusid in (8, 9, 10, 11, 12, 13, 14, 15) order by commitmentid");
        foreach my $key (keys %lookup_values_first) {
            print "<option value=$key>C" . lpadzero($key,5) . " - " . getDisplayString($lookup_values_first{$key},60) . "</option>\n";
        }
        print "<option value=blank>" . &nbspaces(25) . "\n";
        print "</select><br><br><br>\n";
        print "<br><br><b>Commitments with Final Response:</b><br><br>\n";
        print "<select size=10 name=selectedcommitmentidfinal onDblClick=\"processQuery();\">\n";
        %lookup_values_final = get_lookup_values($dbh, "commitment", 'commitmentid', "text", "statusid=16 order by commitmentid");
        foreach my $key (keys %lookup_values_final) {
            print "<option value=$key>C" . lpadzero($key,5) . " - " . getDisplayString($lookup_values_final{$key},60) . "</option>\n";
        }
        print "<option value=blank>" . &nbspaces(25) . "\n";
        print "</select><br><br><br>\n";
        print "<input type=button name=querysubmit value='Update Response' onClick=\"processQuery();\">\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"response update -- query page",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/\'/\'\'/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }
    print "</form><br><br><br><br></body></html>\n";
    &oncs_disconnect($dbh);
} ########## endif query  ###################

####################################
if ($cgiaction eq "queryresponse") {
####################################
    my %commitmenthash = get_commitment_info ($dbh, $commitmentid);
    my $commitmenttext = $commitmenthash{'text'};
    my $cstring = substr ('0000' . $commitmentid, -5);
    
    print "</head>\n<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<table border=0 align=center width=750><tr><td>\n<center>\n";
    print "<form name=$form enctype=\"multipart/form-data\" method=post target=\"control\">\n";
    print "<input name=cgiaction type=hidden value=\"queryresponse\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=responseid type=hidden value=$responseid>\n";
    print "<input name=commitmentid type=hidden value=$commitmentid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n";
    print "</center><br><br><table width=600 align=center>\n";
    print "<tr><td><b><li>Commitment ID:&nbsp;&nbsp;C$cstring</b></td></tr>\n";
    print "<tr><td><li><b>Commitment Text:<br><table width=100% border=1><tr bgcolor=#eeeeee><td>$commitmenttext</td></tr></table></td></tr></table><br>";
    eval {
        print "<center><b>Responses for Selected Commitment:</b><br>\n";
        print "<select size=5 name=selectedresponseid onDblClick=\"processResponse();\">\n";
        %lookup_values_response = get_lookup_values($dbh, "response", 'responseid', "text", "commitmentid=$commitmentid order by responseid");
        foreach my $key (keys %lookup_values_response) {
            print "<option value=$key>R" . lpadzero($key,5) . " - " . getDisplayString($lookup_values_response{$key},60) . "</option>\n";
        }
        print "<option value=blank>" . &nbspaces(25) . "\n";
        print "</select><br><br><br>\n";
        print "<input type=button name=querysubmit value='Update Response' onClick=\"processResponse();\">\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"response update -- query response page",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }
    print "</form><br><br><br><br></body></html>\n";
    &oncs_disconnect($dbh);
} ############  endif queryresponse  ###############

#####################################
if ($cgiaction eq "responseupdate") {
#####################################
    my $commitmentid = $cmscgi -> param ('commitmentid');
    my $cstring = substr ('0000' . $commitmentid, -5);
    my $key = '';
    my %orghash = get_lookup_values($dbh, 'organization', "name || ';' || organizationid", 'organizationid');
    my %ihash = get_lookup_values ($dbh, 'issue', "TO_CHAR(dateoccurred, 'MM/DD/YYYY') || ';' || issueid", 'issueid');
    my %letterhash = get_lookup_values($dbh, 'letter', "accessionnum || ' - ' || to_char(sentdate, 'MM/DD/YYYY') || ';' || letterid", 'letterid');
    my %responseinfo = lookup_response_information ($dbh, $commitmentid, $responseid);
    my $responseid = $responseinfo{'responseid'};
    my $rstring = substr ('0000' . $responseid, -5);
    my $responsetext = $responseinfo{'text'};
    my ($datewritten) = $dbh -> selectrow_array ("select to_char(writtendate, 'MM/DD/YYYY') from $SCHEMA.response where responseid = $responseid");
    my $letterid = $responseinfo{'letterid'};
    my $lstring = substr ('0000' . $letterid, -5);
    my %letterinfo = lookup_letter_information ($dbh, $letterid);
    my $accessionnum = $letterinfo{'accessionnum'};
    my ($sentdate, $signdate) = $dbh -> selectrow_array ("select to_char(sentdate, 'MM/DD/YYYY'), to_char(signeddate, 'MM/DD/YYYY') from $SCHEMA.letter where letterid = $letterid");
    my $addressee = $letterinfo{'addressee'};
    my $organizationid = $letterinfo{'organizationid'};
    my $signer = $letterinfo{'signer'};
    my %commitmenthash = get_commitment_info ($dbh, $commitmentid);
    my $commitmenttext = $commitmenthash{'text'};
    my $siteid = $commitmenthash{'siteid'};
    my $nodevelopers = '';
    if ($CMSProductionStatus) {
        $nodevelopers = 'usersid < 1000';
    }
    my %usershash = get_lookup_values($dbh, 'users', "lastname || ', ' || firstname || ';' || usersid", 'usersid', "$nodevelopers");
    my $usernamestring;

    print<<somejavascripts;
    <script language="JavaScript" type="text/javascript"><!--
    function update_response_table() {
        var tempcgiaction;
        var returnvalue = true;
	if (validate_response_data()) {
	    document.responseupdate.cgiaction.value = "updateresponsetable";
            submitForm ('responseupdate', 'updateresponsetable');
	}
	else {
	    returnvalue = false;
	}
	return (returnvalue);
    }
    function validate_response_data() {
	var msg = "";
	var tmpmsg = "";
	var returnvalue = true;
	var validateform = document.responseupdate;
	msg += (validateform.responsetext.value=="") ? "You must enter the response text.\\n" : "";
	msg += ((tmpmsg = validate_date(validateform.writtendate_year.value, validateform.writtendate_month[validateform.writtendate_month.selectedIndex].value, validateform.writtendate_day[validateform.writtendate_day.selectedIndex].value, 0, 0, 0, 0, true, false, false)) == "") ? "" : tmpmsg + "\\n";
	msg += (validateform.letterid.value == "") ? "You must select a response letter.\\n" : "";
	if (validateform.letterid.value != "") {
	    msg += ((tmpmsg = validate_accession_number(validateform.letteraccessionnum.value,true)) == "") ? "" : tmpmsg + "\\n";
	    msg += (validateform.lettersigner.value== "") ? "You must enter the signer of the response letter.\\n" : "";
	    msg += (validateform.letterorganizationid.value== "") ? "You must select the organization the letter was sent to.\\n" : "";
	    msg += (validateform.letteraddressee.value == "") ? "You must select the addressee of the letter.\\n" : "";
	    msg += ((tmpmsg = validate_date(validateform.lettersigneddate_year.value, validateform.lettersigneddate_month.value, validateform.lettersigneddate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : tmpmsg + "\\n";
	    msg += ((tmpmsg = validate_date(validateform.lettersentdate_year.value, validateform.lettersentdate_month.value, validateform.lettersentdate_day.value, 0, 0, 0, 0, true, false, false)) == "") ? "" : tmpmsg + "\\n";
	}
	if (msg != "") {
	    alert(msg);
	    returnvalue = false;
        }
	return (returnvalue);
    }
    //-->
    </script>
somejavascripts
    print "</head>\n<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<form target=control action=\"$ONCSCGIDir/responseupdate.pl\" enctype=\"multipart/form-data\" method=post name=responseupdate>\n";
    print "<input name=cgiaction type=hidden value=\"updateresponsetable\">\n";
    print "<input name=loginusersid type=hidden value=$usersid>\n";
    print "<input name=loginusername type=hidden value=$username>\n";
    print "<input name=responseid type=hidden value=$responseid>\n";
    print "<input type=hidden name=schema value=$SCHEMA>\n<br><center>\n";
    print "<table width=650 align=center cellspacing=10 border=0>\n";
    print "<tr><td><b><li>Response ID: &nbsp;&nbsp; R$rstring</td></tr>\n";
    print "<tr><td><b><li>Commitment ID: &nbsp;&nbsp; C$cstring</td></tr>\n";
    print "<tr><td align=left><b><li>Commitment Text:<br></b>\n";
    print "<table width=100% border=1>\n";
    print "<tr bgcolor=#eeeeee><td>$commitmenttext</td></tr>\n";
    print "</table></td></tr>\n";
    print "<tr><td align=left><b><li>Response Text:&nbsp;&nbsp;</b><br>\n";
    print "<textarea name=responsetext cols=75 rows=5>$responsetext</textarea></td></tr>\n";
    print "<tr><td align=left><b><li>Date Response Was Written:&nbsp;&nbsp;</b>\n";
    print build_date_selection('writtendate', 'responseupdate', $datewritten);
    print "<tr><td><b><li>Response Letter:&nbsp&nbsp</b>\n";
    print "<select name=letterid onChange=\"checkletter(document.responseupdate.letterid)\">\n";
    print "<option value=\'\'>Select the Response Letter\n";
    print "<option value=\'NEW\'>New Letter\n";
    foreach $key (sort keys %letterhash) {
        my $letterdescription = $key;
        $letterdescription =~ s/;$letterhash{$key}//g;
        if (length($letterdescription) > 80) {
            $letterdescription = substr($letterdescription, 0, 80) . '...';
        }
        if ($letterhash{$key} == $letterid){
            print "<option value=\"$letterhash{$key}\" selected>$letterdescription\n";
        }
        else {
            print "<option value=\"$letterhash{$key}\">$letterdescription\n";
        }
    }
    print "</select></td></tr>\n";
    print "<tr><td><b><li>Letter Accession Number:&nbsp&nbsp</b>\n";
    print "<input name=letteraccessionnum size=17 maxlength=17 value=\"$accessionnum\"></td></tr>\n";
    print "<tr><td><b><li>Organization Sent To: &nbsp &nbsp</b>\n";
    print "<select name=letterorganizationid>\n";
    print "<option value=\'\' selected>Select An Organization\n";
    foreach $key (sort keys %orghash) {
        my $orgdescription = $key;
        my $selectedstring = ($orghash{$key} eq $organizationid) ? " selected" : "";
        $orgdescription =~ s/;$orghash{$key}//g;
        print "<option value=\"$orghash{$key}\"$selectedstring>$orgdescription\n";
    }
    print " </select></td></tr>\n";
    print "<tr><td><table width=100% align=center><tr><td align=left><b>Addressee:</b></td>\n";
    print "<td align=left><input name=letteraddressee size=17 maxlength=17 value=\"$addressee\"></td>\n";
    print "<td align=left><b>Sent Date:</b></td><td>\n";
    print build_date_selection('lettersentdate', 'responseupdate', $sentdate);
    print "</td></tr>\n";
    print "<tr><td align=left><b>Signer:</b></td>\n";
    print "<td><select name=lettersigner><option value=NULL selected>Select the Signer\n";
    foreach $key (sort keys %usershash) {
        $usernamestring = $key;
        my $selectedstring = ($usershash{$key} eq $signer) ? " selected" : "";
        $usernamestring =~ s/;$usershash{$key}//g;
        print "<option value=\"$usershash{$key}\"$selectedstring>$usernamestring\n";
    }
    print "</select></td>\n<td align=left><b>Sign Date:</b></td>\n<td align=left>\n";
    print build_date_selection('lettersigneddate', 'responseupdate',$signdate);
    print "</td></tr>\n";
    print "</table></td></tr>\n"; 
    print "</table></td></tr>\n";
    print "</select></td></tr></table></td></tr><br>\n";

    print<<javacheck;
    <script language="JavaScript" type="text/javascript"><!--
    function clearletter() {
        document.responseupdate.letteraccessionnum.value = "";
        document.responseupdate.lettersigner.value = "NULL";
        document.responseupdate.letteraddressee.value = "";
        document.responseupdate.letterorganizationid.value = "";
        document.responseupdate.lettersigneddate_month.value = "";
        document.responseupdate.lettersigneddate_day.value = "";
        document.responseupdate.lettersigneddate_year.value = "";
        document.responseupdate.lettersentdate_month.value = "";
        document.responseupdate.lettersentdate_day.value = "";
        document.responseupdate.lettersentdate_year.value = "";
    }
    function enableletter() {
        document.responseupdate.letteraccessionnum.disabled = false;
        document.responseupdate.lettersigner.disabled = false;
        document.responseupdate.letteraddressee.disabled = false;
        document.responseupdate.lettersigneddate_month.disabled = false;
        document.responseupdate.lettersigneddate_day.disabled = false;
        document.responseupdate.lettersigneddate_year.disabled = false;
        document.responseupdate.lettersentdate_month.disabled = false;
        document.responseupdate.lettersentdate_day.disabled = false;
        document.responseupdate.lettersentdate_year.disabled = false;
        document.responseupdate.letterorganizationid.disabled = false;
    }
    function fillout_letter() {
	var validateform = document.responseupdate;
	var tempcgiaction;
	tempcgiaction = document.responseupdate.cgiaction.value;
	document.responseupdate.cgiaction.value = "fillout_letter";
	document.responseupdate.submit();
	document.responseupdate.cgiaction.value = tempcgiaction;
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
    //-->
    </script>
javacheck
    print "</table><br><br><center>\n";
    print "<input type=button name=submitupdate value=\"Submit Update\" title=\"Post Response Update\" onClick=\"update_response_table();\">\n";
    print "</center></td></tr></table>\n</form>\n<br><br><br><br>\n</body>\n</html>\n";
    &oncs_disconnect ($dbh);
    exit 1;
}  ###############  endif issueupdate  ################

#####################################
if ($cgiaction eq "fillout_letter") {
#####################################
    my $letterid = $cmscgi->param('letterid');
    print fillLetter (dbh => $dbh, letterid => $letterid, doc => 1);
    &oncs_disconnect($dbh);
    exit 1;
} ####### endif fillout_letter  ###################

##########################################
if ($cgiaction eq "updateresponsetable") {
##########################################
    no strict 'refs';

    my $responseid = $cmscgi -> param ('responseid');
    my $letterid = $cmscgi -> param ('letterid');
    my $accnum = $cmscgi -> param ('letteraccessionnum');
    my $signer = $cmscgi -> param ('lettersigner');
    $signer =~ s/\'/\'\'/g;
    my $addressee = $cmscgi -> param ('letteraddressee');
    $addressee =~ s/\'/\'\'/g;
    my $signdate = $cmscgi -> param ('lettersigneddate');
    my $sentdate = $cmscgi -> param ('lettersentdate');
    my $organizationid = $cmscgi -> param ('letterorganizationid');
    my $responsetext = $cmscgi -> param ('responsetext');
    my $datewritten = $cmscgi -> param ('writtendate');
    my $letterisnew = ($letterid eq 'NEW');
    $letterid = ($letterisnew) ? get_next_id($dbh, 'letter') : $letterid;
    my $respstr = substr ("0000$responseid",-5);
    my $letterstr = substr ("0000$letterid",-5);
    my $responsestring = "update $SCHEMA.response
                          set text = :text,
                         writtendate = to_date ('$datewritten', 'MM/DD/YYYY'),
                          letterid = $letterid
                          where responseid = $responseid";
    my $letterupdate = "update $SCHEMA.letter
                        set accessionnum = '$accnum', signer = $signer,
                            addressee = '$addressee',
                            signeddate = to_date ('$signdate', 'MM/DD/YYYY'),
                            sentdate = to_date ('$sentdate', 'MM/DD/YYYY'),
                            organizationid = $organizationid
                        where letterid = $letterid";
    my $letternew = "insert into $SCHEMA.letter
                            (letterid, accessionnum, signer, signeddate,
                             addressee, sentdate, organizationid)
                     values ($letterid, '$accnum', $signer,
                             to_date ('$signdate','MM/DD/YYYY'),
                             '$addressee', to_date ('$sentdate','MM/DD/YYYY'),
                             $organizationid)";
############
    $dbh->{RaiseError} = 1;
    $dbh->{AutoCommit} = 0;

    my $activity;
    eval {
        my $csr;
        if ($letterisnew){
            $activity = "Insert Letter $letterid";
            $csr = $dbh -> prepare ($letternew);
            $csr -> execute;
        }
        else {
            $activity = "Update Letter $letterid";
            $csr = $dbh -> prepare ($letterupdate);
            $csr -> execute;
        }
        $csr -> finish;
        $activity = "Update Response $responseid";
        $csr = $dbh -> prepare ($responsestring);
        $csr->bind_param(":text", $responsetext, {ora_type => ORA_CLOB, ora_field => 'text'});
        $csr -> execute;
    };
    if ($@) {
	$dbh->rollback;
	my $alertstring = errorMessage($dbh, $username, $usersid, 'response', "$responseid", $activity, $@);
	$alertstring =~ s/\"/\'/g;
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
        print "alert(\"$alertstring\");\n";
        print "//parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
        print "//-->\n";
        print "</script>\n";
    }
    else {
	&log_activity($dbh, 'F', $usersid, "Response R$respstr and letter L$letterstr updated by user $username");
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
        print "<!--\n";
        print "parent.workspace.location=\"$ONCSCGIDir/responseupdate.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\";\n";
        print "//-->\n";
        print "</script>\n";
    }
    $dbh->commit;
    $dbh->{AutoCommit} = 1;
    $dbh->{RaiseError} = 0;
    print "</head>\n<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n</body>\n</html>\n";
    &oncs_disconnect($dbh);
    exit 1;
} ################  endif update_issue_table  ###############
