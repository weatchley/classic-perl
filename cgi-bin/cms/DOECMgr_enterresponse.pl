#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# Commitment Maker commitment response entry screen.
#
# $Source: /data/dev/cirs/perl/RCS/DOECMgr_enterresponse.pl,v $
# $Revision: 1.15 $
# $Date: 2001/01/04 18:40:42 $
# $Author: naydenoa $
# $Locker:  $
# $Log: DOECMgr_enterresponse.pl,v $
# Revision 1.15  2001/01/04 18:40:42  naydenoa
# Script rewrite -- letter display from Edit_Screens
#
# Revision 1.14  2000/10/06 18:20:56  naydenoa
# Interface update
#
# Revision 1.13  2000/09/29 17:30:37  atchleyb
# fixed javascript validation fornetscape
# fixed form submit for netscape
#
# Revision 1.12  2000/09/28 20:05:03  naydenoa
# Checkpoint after Version 2 release
#
# Revision 1.11  2000/09/21 22:15:27  atchleyb
# updated title
#
# Revision 1.10  2000/08/25 16:16:04  atchleyb
# changed Technical Lead to Discipline Lead
#
# Revision 1.9  2000/07/17 16:15:53  atchleyb
# changed selected graphic text label
# placed form in a 750 wide table
#
# Revision 1.8  2000/07/11 14:54:22  munroeb
# formatted html for better UI layout
#
# Revision 1.7  2000/07/06 23:21:31  munroeb
# finished mods to html and javascript
#
# Revision 1.6  2000/07/05 22:35:42  munroeb
# made minor tweaks to html and javascripts
#
# Revision 1.5  2000/06/15 18:31:16  johnsonc
# Revise table columns to be uniform in width
#
# Revision 1.4  2000/06/13 21:58:26  zepedaj
# Added "C" prior to commitment id on edit page
#
# Revision 1.3  2000/06/13 15:30:51  johnsonc
# Editted commitments select object to a fixed width.
#
# Revision 1.2  2000/05/31 19:46:09  atchleyb
# changed status lookup to lookup by name instead of number
#
# Revision 1.1  2000/05/19 23:05:29  atchleyb
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

# print content type header
print $cmscgi->header('text/html');

my $pagetitle = "Response Data Entry";
my $pageheader = $pagetitle;
my $cgiaction = $cmscgi->param('cgiaction');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $schema = ((defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA);
my $submitonly = 0;
my $usersid = $cmscgi->param('loginusersid');
my $username = $cmscgi->param('loginusername');
my $updatetable = "issue";

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

tie my %lookup_values, "Tie::IxHash";
my $commitmentid = ((defined($cmscgi->param("commitmentid"))) ? $cmscgi->param("commitmentid") : "");
my $message = '';

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "")) {
    print <<openloginpage;
    <script type="text/javascript">
    <!--
    parent.location='/cgi-bin/oncs/login.pl';
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
print "<title>$pagetitle</title>\n";

print <<testlabel1;
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>
<script type="text/javascript">
    <!--
    var dosubmit = true;
    if (parent == self)  {  
	location = '/cgi-bin/oncs/login.pl'
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
	if (document.$form.selectedcommitmentid.selectedIndex == -1 || document.$form.selectedcommitmentid.options[document.$form.selectedcommitmentid.options.length - 1].selected == 1) {
	    alert ('You must first select a commitment');
	} 
        else {
	    document.$form.commitmentid.value = document.$form.selectedcommitmentid[document.$form.selectedcommitmentid.selectedIndex].value;
	    submitForm('$form','enterResponse');
	}
    }
//-->
</script>
<script language="JavaScript" type="text/javascript">
<!--
    doSetTextImageLabel('Response Data Entry');
//-->
</script>
testlabel1

print "</head>\n";
print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
print "<table border=0 align=center width=650><tr><td>\n<CENTER>\n";
print "<form name=$form enctype=\"multipart/form-data\" method=post target=\"control\">\n";
print "<input name=cgiaction type=hidden value=\"query\">\n";
print "<input name=loginusersid type=hidden value=$usersid>\n";
print "<input name=loginusername type=hidden value=$username>\n";
print "<input name=commitmentid type=hidden value=$commitmentid>\n";
print "<input type=hidden name=schema value=$SCHEMA>\n";

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();
$dbh->{RaiseError} = 1;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 1000;

if ($cgiaction eq "query") {
    eval {
        print "<br><b>Approved Commitments</b><br><br>\n";
        print "<select size=10 name=selectedcommitmentid onDblClick=\"processQuery();\">\n";
#####        %lookup_values = get_lookup_values($dbh, "commitment com, $schema.commitmentrole cr", 'com.commitmentid', "com.text", "((com.commitmentid = cr.commitmentid) AND (cr.roleid = 3) AND (cr.usersid = $usersid) AND (com.statusid IN (9,10,11,12,13,14))) ORDER BY com.commitmentid");
        %lookup_values = get_lookup_values($dbh, "commitment com", 'com.commitmentid', "com.text", "com.statusid IN (9,10,11,12,13,14) ORDER BY com.commitmentid");
        foreach my $key (keys %lookup_values) {
            print "<option value=$key>C" . lpadzero($key,5) . " - " . getDisplayString($lookup_values{$key},60) . "</option>\n";
        }
        print "<option value=blank>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; \n";
        print "</select><br><br>\n";
        print "<input type=button name=querysubmit value='Enter Response' onClick=\"processQuery();\">\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"enter response - query page.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/\'/\'\'/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }
} #################  endif query  ###############

elsif ($cgiaction eq "enterResponse") {
    eval {
        print "<script language=\"JavaScript\" type=\"text/javascript\"><!--\n";
        print "function clearletter() {\n";
        print "    document.$form.letteraccessionnum.value = \"\";\n";
        print "    document.$form.lettersigner.value = \"NULL\";\n";
        print "    document.$form.letteraddressee.value = \"\";\n";
        print "    document.$form.letterorganizationid.value = \"\";\n";
        print "    document.$form.lettersigneddate_month.value = \"\";\n";
        print "    document.$form.lettersigneddate_day.value = \"\";\n";
        print "    document.$form.lettersigneddate_year.value = \"\";\n";
        print "    document.$form.lettersentdate_month.value = \"\";\n";
        print "    document.$form.lettersentdate_day.value = \"\";\n";
        print "    document.$form.lettersentdate_year.value = \"\";\n";
        print "}\n";
        print "function disableletter() {\n";
	print "    document.$form.letteraccessionnum.disabled = true;\n";
	print "    document.$form.lettersigner.disabled = true;\n";
	print "    document.$form.lettersigneddate_month.disabled = true;\n";
	print "    document.$form.lettersigneddate_day.disabled = true;\n";
	print "    document.$form.lettersigneddate_year.disabled = true;\n";
	print "    document.$form.lettersentdate_month.disabled = true;\n";
	print "    document.$form.lettersentdate_day.disabled = true;\n";
	print "    document.$form.lettersentdate_year.disabled = true;\n";
	print "    document.$form.letteraddressee.disabled = true;\n";
	print "    document.$form.letterorganizationid.disabled = true;\n";
        print "}\n";
        print "function enableletter() {\n";
        print "    document.$form.letteraccessionnum.disabled = false;\n";
        print "    document.$form.lettersigner.disabled = false;\n";
        print "    document.$form.letteraddressee.disabled = false;\n";
        print "    document.$form.lettersigneddate_month.disabled = false;\n";
        print "    document.$form.lettersigneddate_day.disabled = false;\n";
        print "    document.$form.lettersigneddate_year.disabled = false;\n";
        print "    document.$form.lettersentdate_month.disabled = false;\n";
        print "    document.$form.lettersentdate_day.disabled = false;\n";
        print "    document.$form.lettersentdate_year.disabled = false;\n";
        print "    document.$form.letterorganizationid.disabled = false;\n";
        print "}\n";
        print "function fillout_letter() {\n";
	print "    var validateform = document.$form;\n";
	print "    var tempcgiaction;\n";
	print "    tempcgiaction = document.$form.cgiaction.value;\n";
	print "    document.$form.cgiaction.value = \"getLetterInfo\";\n";
	print "    document.$form.submit();\n";
	print "    document.$form.cgiaction.value = tempcgiaction;\n";
	print "    return (true);\n";
        print "}\n";
        print "function checkletter(letterselection) {\n";
        print "    if (letterselection.value!=\"NEW\") {\n";
        print "        if (letterselection.value != \'\'){\n";
	print "            clearletter();\n";
	print "            disableletter();\n";
	print "            fillout_letter();\n";
        print "        }\n";
        print "        else {\n";
        print "            clearletter();\n";
        print "            disableletter();\n";
        print "        }\n";
	print "    }\n";
        print "    else {\n";
	print "        clearletter();\n";
	print "        enableletter();\n";
	print "    }\n";
        print "}\n";
        print "//-->\n";
        print "</script>\n";
        print "<script language=\"JavaScript\" type=\"text/javascript\"><!--\n";
        print "function isLetterNew(accNum, list) {\n";
        print "    var returnVal = true;\n";
        print "    for(var i = 0; i < list.length; i++) {\n";
        print "        if (list.options[i].text == accNum) returnVal = false;\n";
	print "    }\n";
        print "    return(returnVal);\n";
        print "}\n";
        print "function validateResponse() {\n";
        print "    var msg = \'\';\n";
        print "    var tmp = \'\';\n";
        print "    if (document.$form.responsetext.value <= \' \') {\n";
        print "        msg += \'No response entered.\\n\';\n";
        print "    }\n";
        print "    tmp = validate_date(document.$form.responsewrittendate_year.value, document.$form.responsewrittendate_month[document.$form.responsewrittendate_month.selectedIndex].value, document.$form.responsewrittendate_day[document.$form.responsewrittendate_day.selectedIndex].value, 0, 0, 0, 0, true, false, false);\n";
        print "    if (tmp >= \" \") {\n";
        print "        msg += tmp + \"\\n\";\n";
        print "    }\n";
        print "    if (document.$form.letterid[document.$form.letterid.selectedIndex].value == \'-1\') {\n";
        print "        msg += \'You must select or enter a letter\\n\';\n";
        print "    }\n";
        print "    else if (document.$form.letterid[document.$form.letterid.selectedIndex].value == \'-2\') {\n";
        print "        tmp = validate_accession_number(document.$form.letteraccessionnum.value);\n";
        print "        if (tmp > \'\') {\n";
        print "            msg += tmp + \"\\n\";\n";
        print "        }\n";
        print "        else if (!(isLetterNew(document.$form.letteraccessionnum.value,document.$form.letterid))) {\n";
        print "            msg += \'Accession Number already in use, please select from list\\n\';\n";
        print "        }\n";
        print "        tmp = validate_date(document.$form.lettersentdate_year.value, document.$form.lettersentdate_month[document.$form.lettersentdate_month.selectedIndex].value, document.$form.lettersentdate_day[document.$form.lettersentdate_day.selectedIndex].value, 0, 0, 0, 0, true, false, false);\n";
        print "        if (tmp >= \" \") {\n";
        print "            msg += tmp + \"\\n\";\n";
        print "        }\n";
        print "        if (isblank(document.$form.letteraddressee.value)) {\n";
        print "            msg += \'Addressee is required\\n\';\n";
        print "        }\n";
        print "        tmp = validate_date(document.$form.lettersigneddate_year.value, document.$form.lettersigneddate_month[document.$form.lettersigneddate_month.selectedIndex].value, document.$form.lettersigneddate_day[document.$form.lettersigneddate_day.selectedIndex].value, 0, 0, 0, 0, true, false, false);\n";
        print "        if (tmp >= \" \") {\n";
        print "            msg += tmp + \"\\n\";\n";
        print "        }\n";
        print "        if (document.$form.signer[document.$form.lettersigner.selectedIndex].value == \'0\') {\n";
        print "            msg += \'Signer must be selected\\n\';\n";
        print "        }\n";
        print "        if (document.$form.organizationid[document.$form.letterorganizationid.selectedIndex].value == \'0\') {\n";
        print "            msg += \'Organization must be selected\\n\';\n";
        print "        }\n";
        print "    }\n";
        print "    if (msg > \'\') {\n";
        print "        alert (msg);\n";
        print "    }\n"; 
        print "    else {\n";
        print "        submitFormCGIResults(\'$form\', \'processResponse\')\n";
        print "    }\n";
        print "}\n";
        print "//--></script>\n\n";

        print "<br><tr><td><b><li>Commitment ID:</b>&nbsp;&nbsp;\n";
        print "<b>C" . lpadzero($commitmentid,5) . "</b></td></tr>\n";
        print "<tr><td><b><li>Commitment Text:</b><br>\n";
        print "<table border=1 width=100% align=center>\n";
        print "<tr><td><table width=100% border=0 cellpadding=0 cellspacing=0>\n";
        print "<tr bgcolor=#eeeeee><td>" . getDisplayString(get_value($dbh,$schema,'commitment','text',"commitmentid = $commitmentid"),1000000) . "</td></tr>\n";
        print "</td></tr></table></td></tr></table></td></tr><tr><td>\n";
        my $out = writeResponse (dbh => $dbh, cid => $commitmentid, schema => $SCHEMA, doc => 2);
        print "</td></tr></table>\n";

        print "<br><center><input type=button name=responseSubmit value='Submit' onClick=\"validateResponse();\"></center>\n";
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"enter response - entry page.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }
} ###############  endif enterResponse  ############################
 
elsif ($cgiaction eq "processResponse") {
    my $activity = "";

    my $commitmentid = $cmscgi -> param ('commitmentid');
    my $text = $cmscgi -> param ('responsetext');
    my $writtendate = $cmscgi -> param ('responsewrittendate');
    my $accnum = $cmscgi -> param ('letteraccessionnum');
    my $sentdate = $cmscgi -> param ('lettersentdate');
    my $signdate = $cmscgi -> param ('lettersigneddate');
    my $addressee = $cmscgi -> param ('letteraddressee');
    my $signer = $cmscgi -> param ('lettersigner');
    my $orgid = $cmscgi -> param ('letterorganizationid');
    my $letterid = $cmscgi -> param ('letterid');
    my $responseid;

    eval {
        if ($letterid eq 'NEW') {
            # get next id
            $letterid = get_next_id($dbh, 'letter');
            $activity = "Insert letter $letterid";
            my $insertletter = "insert into $SCHEMA.letter (letterid, accessionnum, sentdate, addressee, signeddate, signer, organizationid) values ($letterid, '$accnum', to_date ('$sentdate', 'MM/DD/YYYY'), '$addressee', to_date('$signdate','MM/DD/YYYY'), $signer, $orgid)";
            my $csr = $dbh -> prepare ($insertletter);
            $csr -> execute;
            $csr -> finish;
        }

        $responseid = get_next_id ($dbh, 'response');
        $activity = "Insert response $responseid";
        my $insertresponse = "insert into $SCHEMA.response (responseid, text, commitmentid, letterid, writtendate) values ($responseid, :text, $commitmentid, $letterid, to_date ('$writtendate','MM/DD/YYYY'))";
        my $csr = $dbh -> prepare ($insertresponse); 
        $csr -> bind_param (":text", $text, {ora_type => ORA_CLOB, ora_field => 'text'});
        $csr -> execute;
        $csr -> finish;
    };
    if ($@){
        $dbh->rollback;
        my $alertstring = errorMessage($dbh, $username, $usersid, 'commitment', "$commitmentid", $activity, $@);
        $alertstring =~ s/"/'/g;
        print <<pageerror;
        <script language="JavaScript" type="text/javascript">
        <!--
        alert("$alertstring");
        parent.control.location="$ONCSCGIDir/DOECMgr_enterresponse.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA&cgiaction=query";
        //-->
        </script>
pageerror
    }
    else {
        &log_activity($dbh, 'F', $usersid, "Response ".&formatID2($responseid, 'R')." and letter ".formatID2($letterid, 'L')." added to commitment ".formatID2($commitmentid, 'C'));
        print <<pageresults;
        <script language="JavaScript" type="text/javascript">
        <!--
        parent.workspace.location="$ONCSCGIDir/DOECMgr_enterresponse.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA&cgiaction=query";
        parent.control.location="$ONCSCGIDir/blank.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA";
        //-->
        </script>
pageresults
    }
} ####################  endif processResponse  ##################

elsif ($cgiaction eq "getLetterInfo") {
    eval {
        my $letterid = $cmscgi->param('letterid');
        print fillLetter (dbh => $dbh, letterid => $letterid, doc => 2);
    };
    if ($@) {
        $message = errorMessage($dbh,$username,$usersid,'','',"enter response - get letter info page.",$@);
        $message =~ s/\n/\\n/g;
        $message =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "    alert('$message');\n";
        print "//--></script>\n";
    }
} ###############  endif getLetterInfo  ####################

else {
    print "Invalid command - $cgiaction\n";
}

#disconnect from the database
&oncs_disconnect($dbh);

# print html footers.
print "<br>\n";
print "</form>\n";
print "</CENTER>\n";
print "</td></tr></table>\n";
print "</body>\n";
print "</html>\n";
