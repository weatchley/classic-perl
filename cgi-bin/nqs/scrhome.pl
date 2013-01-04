#!/usr/local/bin/newperl -w
#
# Entry Screen for SCR
#
# $Source: /data/dev/rcs/qa/perl/RCS/scrhome.pl,v $
# $Revision: 1.5 $
# $Date: 2002/11/21 15:24:32 $
# $Author: starkeyj $
# $Locker:  $
# $Log: scrhome.pl,v $
# Revision 1.5  2002/11/21 15:24:32  starkeyj
# added productid parameter so the Trend and ASSM apps display only their own SCR's, and removed STDERR printlines
#
# Revision 1.4  2002/07/02 00:33:27  starkeyj
# modified for new implementation of product identification, i.e. not by subproduct
#
# Revision 1.3  2002/03/28 21:49:07  starkeyj
# modified to distinguish between ASSM and Trend subproducts
#
# Revision 1.2  2001/11/05 15:49:11  starkeyj
# added include file for javascript
#
# Revision 1.1  2001/11/02 22:02:45  starkeyj
# Initial revision
#
#

use strict;
use integer;
use NQS_Header qw(:Constants);
use OQA_Utilities_Lib qw(:Functions);
use OQA_Widgets qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

my $warn = $^W;
$^W=0;
my $scrcgi = new CGI;
$^W=$warn;

my $schema = (defined($scrcgi->param("schema"))) ? $scrcgi->param("schema") : $ENV{'SCHEMA'};
my $schema1 = "SCM";
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $urllocation;
my $command = (defined ($scrcgi -> param("command"))) ? $scrcgi -> param("command") : "write_request";
my $username = (defined($scrcgi->param("username"))) ? $scrcgi->param("username") : "";
my $password = (defined($scrcgi->param("password"))) ? $scrcgi->param("password") : "";
my $userid = (defined($scrcgi->param("userid"))) ? $scrcgi->param("userid") : 0;
my $app = (defined($scrcgi->param("app"))) ? $scrcgi->param("app") : '';
my $error = "";
my $dbh = NQS_connect();
my $getsccb;
my $background;
my $productid;
if ($app eq 'ASSM') {
	$getsccb = "select sccbid from $schema.sccbuser where userid=$userid";
	$background = "background=$NQSImagePath/background.gif";
	$productid = 3;
}
elsif ($app eq 'Trend') {
	$getsccb = "select sccbid from $schema.sccbuser where trend_userid=$userid";
	$background = "bgcolor=#FFFFEO";
	$productid = 4;
}
my ($sccbid) = $dbh -> selectrow_array ($getsccb);

print $scrcgi->header('text/html');
print "<html>\n<head>\n";
print "<meta http-equiv=expires content=now>\n";
print "<title>Software Changes Requests Database</title>\n";
#print "<script src=$NQSJavaScriptPath/oncs-utilities.js></script>\n";
print "<script src=\"$NQSJavaScriptPath/utilities.js\"></script>\n";
print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
print "<!--\n";
print "function validate_request_data() {\n";
print "    var msg = \"\";\n";
print "    var returnvalue = true;\n";
print "    var validateform = document.scrhome;\n";
print "    msg += (validateform.request.value==\"\") ? \"You must enter the description of the request.\\n\" : \"\";\n";
print "    msg += (validateform.rationale.value==\"\") ? \"You must enter your rationale for making this request.\\n\" : \"\";\n";
print "    msg += (validateform.priority.value==\"\") ? \"You must select the priority of the request\\n\" : \"\";\n";
print "    if (msg != \"\") {\n";
print "        alert(msg);\n";
print "        returnvalue = false;\n";
print "    }\n";
print "    return (returnvalue);\n";
print "}\n";

print "function submit_request() {\n";
print "    var tempcgiaction;\n";
print "    var returnvalue = true;\n";
print "    if (validate_request_data()) {\n";
print "        tempcgiaction = document.scrhome.command.value;\n";
print "        document.scrhome.command.value = \"submit_request\";\n";
print "        document.scrhome.submit();\n";
print "        document.scrhome.command.value = tempcgiaction;\n";
print "    }\n";
print "    else {\n";
print "        returnvalue = false;\n";
print "    }\n";
print "    return (returnvalue);\n";
print "}\n";
if ($app eq 'ASSM') {
	print "doSetTextImageLabel(\'Enter Software Change Request\');\n";
}
print "//-->\n";
print "</script>\n";
print "</head>\n";

##################################
if ($command eq "write_request") {
##################################

    print "<body $background text=$NQSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<table width=750 align=center><tr><td>\n";
    print "<form name=$form method=post target=control action=$NQSCGIDir/scrhome.pl>\n";
    print "<input type=hidden name=command value=$command>\n";
    print "<input name=userid type=hidden value=$userid>\n";
    print "<input name=username type=hidden value=$username>\n";
    print "<input type=hidden name=schema value=$schema>\n";
    print "<input type=hidden name=app value=$app>\n";
    print "<input type=hidden name=productid value=$productid>\n";
    if ($app eq 'Trend') {print "<hr width=80%><br>\n";}
    print "<table width=650 align=center cellspacing=10>\n";

    print "<tr><td><table border=0 cellpadding=0 cellspacing=0><tr>";
    print "<td align=left valign=bottom><li><b>Detailed Description of the Requested Software Change:</b></td>\n";
    print "<tr><td colspan=2><textarea cols=75 rows=5 name=request></textarea></tr></table></td></tr>\n";

    print "<tr><td><li><b>Priority:&nbsp;&nbsp;</b>\n";
    my $str = "select id, description from $schema1.scrpriority order by id";
    my $doit = $dbh -> prepare ($str);
    $doit -> execute;
    print "<select name=\"priority\">\n";
    print "<option value='' selected>Select Request Priority&nbsp;\n";
    while (my ($pid, $pdesc) = $doit -> fetchrow_array){
        print "<option value=\"$pid\">$pdesc\n";
    }
    $doit -> finish;
    print "</select></td></tr>\n";
    print "<tr><td><table border=0 cellpadding=0 cellspacing=0><tr>";
    print "<td align=left valign=bottom><li><b>Rationale for Request:</b></td>\n";
    print "<tr><td colspan=2><textarea cols=75 rows=5 name=rationale></textarea></tr></table></td></tr>\n";
    print "<tr><td align=center><input type=button value=\"Submit Request\" onClick=\"return(submit_request())\">\n";
    print "</td></tr></table></td></tr></table>\n";
    print "</form>\n</center>\n</font>\n";
} ####  end if write_request  ####

###################################
if ($command eq "submit_request") {
###################################
    no strict 'refs';
    my $app = $scrcgi -> param ("app");
    my $request = $scrcgi -> param ("request");
    my $priority = $scrcgi -> param ("priority");
    my $rationale = $scrcgi -> param ("rationale");
    my $product = 2;
    my $newid;
    my $activity;
    eval {
        $activity = "Get next SC request id";
        $newid = get_next_id ($dbh, 'scrrequest_qa_id_seq', $schema1);
        $activity = "Insert new SC request $newid";
        my $insert = "insert into $schema1.scrrequest (id, description, priority, rationale, datesubmitted, submittedby, status, product) values ($newid, :reqclob, $priority, :ratclob, SYSDATE, $sccbid, 1, $productid)";
        my $doinsert = $dbh -> prepare ($insert);
        $doinsert -> bind_param (":reqclob", $request, {ora_type => ORA_CLOB, ora_field => 'description'});
        $doinsert -> bind_param (":ratclob", $rationale, {ora_type => ORA_CLOB, ora_field => 'rationale'});
        $doinsert -> execute;
    };
    if ($@) {
        $dbh -> rollback;
        my $error = &errorMessage($dbh, $username, $userid, $schema, $activity, $@);
        $error =~ s/\n/\\n/g;
        $error =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$error');\n";
        print "//--></script>\n";
   }
    else {
        my $newidformatted = formatID2($newid, 'SCREQ');
        my $logactivity = "Request $newidformatted created in schema $schema";
        my $actlog = $dbh -> prepare ("insert into $schema1.activity_log (userid, datelogged, text) values ($sccbid, SYSDATE, '$logactivity')");
        $actlog -> execute;
        $actlog -> finish;
        print "<body $background text=$NQSBackground link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
        print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
        print "<!--\n";
        print "alert(\"$app - Software change request $newidformatted has been processed.\");";
        if ($app eq 'ASSM') {
        	print "parent.workspace.location=\"$NQSCGIDir/utilities.pl?userid=$userid&username=$username&schema=$schema\";\n";
         print "parent.control.location=\"$NQSCGIDir/blank2.pl?userid=$userid&username=$username&schema=$schema\";\n";
        }
        elsif ($app eq 'Trend') {
         print "parent.workspace.location=\"$NQSCGIDir/trend_home.pl?userid=$userid&username=$username&schema=$schema\";\n";
         print "parent.control.location=\"$NQSCGIDir/blank.pl?userid=$userid&username=$username&schema=$schema\";\n";
        }
        print "//-->\n";
        print "</script>\n";
    }
} ####  end if submit_request  ####


print "</body>\n</html>\n";
my $stat = NQS_disconnect($dbh);



#################
sub get_next_id {
#################
    my $dbh=$_[0];
    my $seqname = $_[1];
    my $schema = $_[2];

    my $sqlstring;
    my $csr;
    my $rv;
    my @nextvalue;
    my $rc;

    $sqlstring = "SELECT $schema1.$seqname.NEXTVAL FROM DUAL";
    $csr=$dbh->prepare($sqlstring);
    $rv=$csr->execute;
    @nextvalue=$csr->fetchrow_array;
    $rc = $csr->finish;

    return ($nextvalue[0]);
}
