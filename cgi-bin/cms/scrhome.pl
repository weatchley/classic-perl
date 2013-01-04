#!/usr/local/bin/newperl -w
#
# CGI user login for the SCR
#
# $Source: /data/dev/rcs/cms/perl/RCS/scrhome.pl,v $
# $Revision: 1.6 $
# $Date: 2003/11/21 17:24:11 $
# $Author: naydenoa $
# $Locker:  $
# $Log: scrhome.pl,v $
# Revision 1.6  2003/11/21 17:24:11  naydenoa
# Updated secondary schema from SCM to PCL.
#
# Revision 1.5  2002/11/13 23:59:09  naydenoa
# Removed reference to SCCBUSER table - sccbid is passed as parameter from utilities.pl
# Checkpoint
#
# Revision 1.4  2001/09/04 23:02:17  naydenoa
# checkpoint
#
# Revision 1.3  2001/08/31 20:33:37  naydenoa
# Removed test print statement
#
# Revision 1.2  2001/08/30 22:13:01  naydenoa
# Added title bar text.
#
# Revision 1.1  2001/08/30 21:54:09  naydenoa
# Initial revision
#
#

use strict;
use integer;
use ONCS_Header qw(:Constants);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_Widgets qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

    my $warn = $^W;
    $^W=0;
my $scrcgi = new CGI;
    $^W=$warn;
my $schema = (defined($scrcgi->param("schema"))) ? $scrcgi->param("schema") : $ENV{'SCHEMA'};
my $schema1 = "PCL";
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $urllocation;
my $command = (defined ($scrcgi -> param("command"))) ? $scrcgi -> param("command") : "write_request";
my $username = (defined($scrcgi->param("loginusername"))) ? $scrcgi->param("loginusername") : "";
my $password = (defined($scrcgi->param("password"))) ? $scrcgi->param("password") : "";
my $userid = (defined($scrcgi->param("loginusersid"))) ? $scrcgi->param("loginusersid") : "";
my $sccbid = (defined($scrcgi->param("sccbid"))) ? $scrcgi->param("sccbid") : "";
my $error = "";
my $dbh = oncs_connect();

print $scrcgi->header('text/html');
print "<html>\n<head>\n";
print "<meta http-equiv=expires content=now>\n";
print "<title>Software Changes Requests Database</title>\n";
print "<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>\n";
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
print "doSetTextImageLabel(\'Enter Software Change Request\');\n";
print "//-->\n";
print "</script>\n";
print "</head>\n";

##################################
if ($command eq "write_request") {
##################################
    print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<table width=750 align=center><tr><td>\n";
    print "<form name=$form method=post target=control action=$ONCSCGIDir/scrhome.pl>\n";
    print "<input type=hidden name=command value=$command>\n";
    print "<input type=hidden name=loginusersid value=$userid>\n";
    print "<input type=hidden name=loginusername value=$username>\n";
    print "<input type=hidden name=schema value=$schema>\n";
    print "<input type=hidden name=sccbid value=$sccbid>\n";
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
    my $request = $scrcgi -> param ("request");
    my $priority = $scrcgi -> param ("priority");
    my $rationale = $scrcgi -> param ("rationale");
    my $product = 2;
    my $newid;
    my $activity;
    eval {
        $activity = "Get next SC request id";
        $newid = get_next_id ($dbh, 'scrrequest_cms_id_seq', $schema1);
        $activity = "Insert new SC request $newid";
        my $insert = "insert into $schema1.scrrequest (id, description, priority, rationale, datesubmitted, submittedby, status, product) values ($newid, :reqclob, $priority, :ratclob, SYSDATE, $sccbid, 1, 2)";
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
        print "<body background=$ONCSBackground text=$ONCSBackground link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
        print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
        print "<!--\n";
        print "alert(\"Software change request $newidformatted has been processed.\");";
        print "parent.workspace.location=\"$ONCSCGIDir/utilities.pl?loginusersid=$userid&loginusername=$username&schema=$schema\";\n";
        print "parent.control.location=\"$ONCSCGIDir/blank.pl?loginusersid=$userid&loginusername=$username&schema=$schema\";\n";
        print "//-->\n";
        print "</script>\n";
    }
} ####  end if submit_request  ####

print "</body>\n</html>\n";
my $stat = oncs_disconnect($dbh);

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
#    print STDERR "$sqlstring\n";
    $csr=$dbh->prepare($sqlstring);
    $rv=$csr->execute;
    @nextvalue=$csr->fetchrow_array;
    $rc = $csr->finish;

    return ($nextvalue[0]);
}
