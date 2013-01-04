#!/usr/local/bin/perl -w
#
# CGI user login for the SCR
#
# $Source$
# $Revision$
# $Date$
# $Author$
# $Locker$
# $Log$
#
#

use strict;
use integer;
use MMS_Header qw(:Constants);
use CGI;
use DB_Utilities_Lib qw(:Functions);
use UI_Widgets qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);

my $mmscgi = new CGI;
my $schema = (defined($mmscgi->param("schema"))) ? $mmscgi->param("schema") : $ENV{'SCHEMA'};
my $schema1 = "SCM";
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $urllocation;
my $command = (defined ($mmscgi -> param("command"))) ? $mmscgi -> param("command") : "write_request";
my $username = (defined($mmscgi->param("username"))) ? $mmscgi->param("username") : "";
my $password = (defined($mmscgi->param("password"))) ? $mmscgi->param("password") : "";
my $userid = (defined($mmscgi->param("userid"))) ? $mmscgi->param("userid") : "";
my $error = "";
my $dbh = db_connect();
my ($sccbid) = $dbh -> selectrow_array ("select sccbid from $schema.sccbuser where userid=$userid");

print $mmscgi->header('text/html');
print "<html>\n<head>\n";
print "<meta http-equiv=expires content=now>\n";
print "<title>Software Changes Requests Database</title>\n";
print "<script src=$MMSJavaScriptPath/utilities.js></script>\n";
print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
print "<!--\n";
print "function validate_commitment_data() {\n";
print "    var msg = \"\";\n";
print "    var tmpmsg = \"\";\n";
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
print "    if (validate_commitment_data()) {\n";
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
print "//-->\n";
print "</script>\n";
print "</head>\n";

##################################
if ($command eq "write_request") {
##################################
    print "<body background=$MMSImagePath/background.gif text=$MMSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<table width=750 align=center><tr><td>\n";
    print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => 'Submit Software Change Request');
    print "<form name=$form method=post target=main action=$path$form.pl>\n";
    print "<input type=hidden name=command value=$command>\n";
    print "<input name=userid type=hidden value=$userid>\n";
    print "<input name=username type=hidden value=$username>\n";
    print "<input type=hidden name=schema value=$schema>\n";
    print "<table width=650 align=center cellspacing=10>\n";

    my $expand = "<a href=\"javascript:expandTextBox(document.$form.request,document.request_button,'force',5);\">\n";
    $expand .= "<img name=request_button border=0 src=$MMSImagePath/expand_button.gif></a>\n";
    print "<tr><td><table border=0 cellpadding=0 cellspacing=0><tr>";
    print "<td align=left valign=bottom><li><b>Detailed Description of the Requested Software Change:</b></td>\n";
    print "<td align=right valign=bottom>$expand</td></tr>\n";
    print "<tr><td colspan=2><textarea cols=75 rows=5 name=request wrap=physical ";
    print "onKeyPress=\"expandTextBox(this,document.request_button,'dynamic');\"></textarea></tr></table></td></tr>\n";

    print "<tr><td><li><b>Priority:&nbsp;&nbsp;</b>\n";
    my $str = "select id, description from $schema1.scrpriority";
    my $doit = $dbh -> prepare ($str);
    $doit -> execute;
    print "<select name=\"priority\">\n";
    print "<option value='' selected>Select Request Priority&nbsp;\n";
    while (my ($pid, $pdesc) = $doit -> fetchrow_array){
    print "<option value=\"$pid\">$pdesc\n";
    }
    $doit -> finish;
    print "</select></td></tr>\n";
    $expand = "<a href=\"javascript:expandTextBox(document.$form.rationale,document.rationale_button,'force',5);\">\n";
    $expand .= "<img name=rationale_button border=0 src=$MMSImagePath/expand_button.gif></a>\n";
    print "<tr><td><table border=0 cellpadding=0 cellspacing=0><tr>";
    print "<td align=left valign=bottom><li><b>Rationale for Request:</b></td>\n";
    print "<td align=right valign=bottom>$expand</td></tr>\n";
    print "<tr><td colspan=2><textarea cols=75 rows=5 name=rationale wrap=physical ";
    print "onKeyPress=\"expandTextBox(this,document.rationale_button,'dynamic');\"></textarea></tr></table></td></tr>\n";
    print "<tr><td align=center><input type=button value=\"Submit Request\" onClick=\"return(submit_request())\">\n";
    print "</td></tr></table></td></tr></table>\n";
    print "</form>\n</center>\n</font>\n";
} ####  end if write_request  ####

###################################
if ($command eq "submit_request") {
###################################
    no strict 'refs';
    my $request = $mmscgi -> param ("request");
    my $priority = $mmscgi -> param ("priority");
    my $rationale = $mmscgi -> param ("rationale");
    my $product = 1;
    my $status = 1;
    my $newid;
    my $activity;
    eval {
        $activity = "Get next SC request id";
        $newid = get_next_id ($dbh, 'scrrequest', $schema1);
        $activity = "Insert new SC request $newid";
        my $insert = "insert into $schema1.scrrequest (id, description, priority, rationale, datesubmitted, submittedby, status, product) values ($newid, :reqclob, $priority, :ratclob, SYSDATE, $sccbid, $status, $product)";
        my $doinsert = $dbh -> prepare ($insert);
        $doinsert -> bind_param (":reqclob", $request, {ora_type => ORA_CLOB, ora_field => 'description'});
        $doinsert -> bind_param (":ratclob", $rationale, {ora_type => ORA_CLOB, ora_field => 'rationale'});
        $doinsert -> execute;
        $dbh -> commit;
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
        my $newidformatted = formatID('SCREQ', 5, $newid);
        my $logactivity = "Request $newidformatted created in schema $schema";
        my $actlog = $dbh -> prepare ("insert into $schema1.activity_log (userid, datelogged, text) values ($sccbid, SYSDATE, '$logactivity')");
        $actlog -> execute;
        $actlog -> finish;
   print "<body background=$MMSImagePath/background.gif text=$MMSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
   print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
   print "<!--\n";
   print "alert(\"Software change request $newidformatted has been processed.\");";
   print "parent.main.location=\"$path$form.pl?userid=$userid&username=$username&schema=$schema\";\n";
   print "parent.cgiresults.location=\"". $path . "blank.pl?userid=$userid&username=$username&schema=$schema\";\n";
   print "//-->\n";
   print "</script>\n";
    }
} ####  end if submit_request  ####


print "</body>\n</html>\n";
my $stat = db_disconnect($dbh);



#################
sub get_next_id {
#################
    my $dbh=$_[0];
    my $tablename = $_[1];
    my $schema = $_[2];

    my $sqlstring;
    my $csr;
    my $rv;
    my @nextvalue;
    my $rc;

    $sqlstring = "SELECT $schema1.SCRREQUEST_ID_SEQ.NEXTVAL FROM DUAL";
    $csr=$dbh->prepare($sqlstring);
    $rv=$csr->execute;
    @nextvalue=$csr->fetchrow_array;
    $rc = $csr->finish;

    return ($nextvalue[0]);
}
