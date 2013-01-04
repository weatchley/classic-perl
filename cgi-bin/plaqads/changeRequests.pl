#!/usr/local/bin/perl -w
#
# CR processing
#
# $Source: /data/dev/rcs/plaqads/perl/RCS/changeRequests.pl,v $
# $Revision: 1.1 $
# $Date: 2004/07/27 18:27:16 $
# $Author: atchleyb $
# $Locker:  $
# $Log: changeRequests.pl,v $
# Revision 1.1  2004/07/27 18:27:16  atchleyb
# Initial revision
#
#

use strict;
use integer;
use SharedHeader qw(:Constants);
use CGI;
use DBShared qw(:Functions);
use UI_Widgets qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);

my $mycgi = new CGI;
my $schema = (defined($mycgi -> param("schema"))) ? $mycgi -> param("schema") : $ENV{'SCHEMA'};
my $schema1 = "PCL";
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $urllocation;
my $command = (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "write_request";
my $username = (defined($mycgi -> param("username"))) ? $mycgi -> param("username") : "";
my $password = (defined($mycgi -> param("password"))) ? $mycgi -> param("password") : "";
my $userid = (defined($mycgi -> param("userid"))) ? $mycgi -> param("userid") : "";
my $option = $mycgi -> param("option"); 
$option = "main" if !defined($option);
my $error = "";

my $dbh = db_connect();
$dbh->{LongReadLen}=1000000;
my ($sccbid) = $dbh -> selectrow_array ("select sccbid from $schema.sccbuser where userid=$userid");
my $getprodid = "select id from $schema1.product where acronym = upper(\'$schema\')";
my $productid = $dbh -> selectrow_array ($getprodid);

@| = 1;
 
print $mycgi -> header('text/html');
print "<html>\n<head>\n";
print "<meta http-equiv=expires content=now>\n";
print "<title>Changes Requests Database</title>\n";
print "<script src=$SYSJavaScriptPath/utilities.js></script>\n";
print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
print "<!--\n";
print "function validate_commitment_data() {\n";
print "    var msg = \"\";\n";
print "    var tmpmsg = \"\";\n";
print "    var returnvalue = true;\n";
print "    var validateform = document.$form;\n";
print "    msg += (validateform.request.value==\"\") ? \"You must enter the description of the request.\\n\" : \"\";\n";
print "    msg += (validateform.rationale.value==\"\") ? \"You must enter your rationale for making this request.\\n\" : \"\";\n";
print "    msg += (validateform.priority.value==\"\") ? \"You must select the priority of the request.\\n\" : \"\";\n";
print "    msg += (validateform.type.value==\"\") ? \"You must select the type of the request.\\n\" : \"\";\n";
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
print "        tempcgiaction = document.$form.command.value;\n";
print "        document.$form.command.value = \"submit_request\";\n";
print "        document.$form.target = \"cgiresults\";\n";
print "        document.$form.submit();\n";
print "        document.$form.command.value = tempcgiaction;\n";
print "    }\n";
print "    else {\n";
print "        returnvalue = false;\n";
print "    }\n";
print "    return (returnvalue);\n";
print "}\n";
print "function browseDetails(id) {\n";
print "    var script = \'changeRequests\';";
print "    tempcgiaction = document.$form.command.value;\n";
print "    document.$form.command.value = \"browse\";\n";
print "    document.$form.option.value = \'details\'\;\n";
print "    document.$form.id.value = id\;\n";
print "    document.$form.action = \'$path\' + script + \'.pl\';\n";
print "    document.$form.target = \'main\';\n";
print "    document.$form.submit()\;\n";
print "    document.$form.command.value = tempcgiaction;\n";
print "}\n\n";
print "function openWindow(image) {\n";
print "\t window.open(image,\"image_window\",\"height=500,width=700,scrollbars=yes,resizable=yes\");\n";
print "}\n\n";
print "function doReport() {\n";
print "    var script = \'changeRequests\';\n";
print "    window.open (\"\", \"reportwin\", \"height=500, width=700, status=yes, scrollbars=yes menubar=yes toolbar=yes\");\n";
print "    tempcgiaction = document.$form.command.value;\n";
print "    document.$form.command.value = \"report\";\n";
print "    document.$form.target = \'reportwin\';\n";
print "    document.$form.action = \'$path\' + script + \'.pl\';\n";
print "    document.$form.submit();\n";
print "    document.$form.command.value = tempcgiaction;\n";
print "}\n";
print "//-->\n";
print "</script>\n";
print "</head>\n";

##################################
if ($command eq "write_request") {
##################################
    print "<body background=$SYSImagePath/background.gif text=$SYSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
    print "<table width=750 align=center><tr><td>\n";
    print &writeTitleBar(dbh => $dbh, userName => $username, userID => $userid, schema => $schema, title => 'Submit Change Request');
    print "<form name=$form method=post target=main action=$path$form.pl>\n";
    print "<input type=hidden name=command value=$command>\n";
    print "<input name=userid type=hidden value=$userid>\n";
    print "<input name=username type=hidden value=$username>\n";
    print "<input type=hidden name=schema value=$schema>\n";
    print "<table width=650 align=center cellspacing=10>\n";

    my $expand = "<a href=\"javascript:expandTextBox(document.$form.request,document.request_button,'force',5);\">\n";
    $expand .= "<img name=request_button border=0 src=$SYSImagePath/expand_button.gif></a>\n";
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
    print "<tr><td><li><b>Type:&nbsp;&nbsp;</b>\n";
    $str = "select id, name from $schema1.scrtype order by name";
    $doit = $dbh -> prepare ($str);
    $doit -> execute;
    print "<select name=\"type\">\n";
    print "<option value='' selected>Select Request Type&nbsp;\n";
    while (my ($tid, $tname) = $doit -> fetchrow_array){
	my $selected = ($tname eq "User Change Request") ? " selected" : "";
        print "<option value=\"$tid\"$selected>$tname\n";
    }
    $doit -> finish;
    print "</select></td></tr>\n";
    $expand = "<a href=\"javascript:expandTextBox(document.$form.rationale,document.rationale_button,'force',5);\">\n";
    $expand .= "<img name=rationale_button border=0 src=$SYSImagePath/expand_button.gif></a>\n";
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
    my $request = $mycgi -> param ("request");
    my $priority = $mycgi -> param ("priority");
    my $type = $mycgi -> param ("type");
    my $rationale = $mycgi -> param ("rationale");
    my $status = 1;
    my $newid;
    my $activity;
    eval {
        $activity = "Get next SC request id";
        $newid = get_next_id ($dbh, 'scrrequest');
        $activity = "Insert new SC request $newid";
        my $insert = "insert into $schema1.scrrequest (id, description, priority, type, rationale, datesubmitted, submittedby, status, product) values ($newid, :reqclob, $priority, $type, :ratclob, SYSDATE, $sccbid, $status, $productid)";
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
        my $newidformatted = formatID('CREQ', 5, $newid);
        my $logactivity = "Request $newidformatted created in schema $schema";
        my $actlog = $dbh -> prepare ("insert into $schema1.activity_log (userid, datelogged, text) values ($sccbid, SYSDATE, '$logactivity')");
        $actlog -> execute;
        $actlog -> finish;
   print "<body background=$SYSImagePath/background.gif text=$SYSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
   print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
   print "<!--\n";
   print "alert(\"Software change request $newidformatted has been processed.\");";
   print "parent.main.location=\"$path$form.pl?userid=$userid&username=$username&schema=$schema\";\n";
   print "parent.cgiresults.location=\"". $path . "blank.pl?userid=$userid&username=$username&schema=$schema\";\n";
   print "//-->\n";
   print "</script>\n";
    }
} ####  end if submit_request  ####

###########################
if ($command eq "browse") {
###########################

    print "<BODY BACKGROUND=/cms/images/background.gif TEXT=#000099 LINK=#0000FF VLINK=#0000FF ALINK=#0000FF TOPMARGIN=0 LEFTMARGIN=0><center><br>\n";
    print "<FORM NAME=$form METHOD=POST onSubmit=\'return validateForm();\'>\n";
    print "<INPUT TYPE=HIDDEN NAME=userid VALUE=$userid>\n";
    print "<INPUT TYPE=HIDDEN NAME=username VALUE=$username>\n";
    print "<INPUT TYPE=HIDDEN NAME=schema VALUE=$schema>\n";
    print "<input type=hidden name=option value=$option>\n";
    print "<input type=hidden name=command value=$command>\n";
    print &writeTitleBar(dbh => $dbh, userName => $username, userID => $userid, schema => $schema, title => 'Browse Change Requests');
    &drawResults() if $option eq "main";
    &drawDetails() if $option eq "details";
    print "</form>\n";
}


###########################
if ($command eq "report") {
###########################
    print "<BODY BACKGROUND=/cms/images/background.gif TEXT=#000099 LINK=#0000FF VLINK=#0000FF ALINK=#0000FF TOPMARGIN=0 LEFTMARGIN=0><center><br>\n";
    print "<FORM NAME=$form METHOD=POST onSubmit=\'return validateForm();\'>\n";
    print "<INPUT TYPE=HIDDEN NAME=userid VALUE=$userid>\n";
    print "<INPUT TYPE=HIDDEN NAME=username VALUE=$username>\n";
    print "<INPUT TYPE=HIDDEN NAME=schema VALUE=$schema>\n";
    print "<input type=hidden name=option value=$option>\n";
    print "<input type=hidden name=command value=$command>\n";

    my ($total)=$dbh -> selectrow_array ("select count(*) from $schema1.scrrequest where product = $productid");
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER><br>\n";
    print "<table width=650 align=center>\n";
    my ($reportdate) = $dbh -> selectrow_array ("select to_char(sysdate, 'DD Month YYYY; HH:MI:SS AM') from dual");
    print "<TR><TD colspan=2 align=center><FONT SIZE=4 face=arial>Report on Change Requests ($total total)<br>$reportdate</TD></TR><tr><td colspan=2>&nbsp;</td></tr>\n";
    if ($total > 0) { 
	my $pick = "select r.id, s.id, s.description, r.submittedby, u.firstname || ' ' || u.lastname, r.description, to_char(r.datesubmitted, 'MM/DD/YYYY'), p.description, r.rationale, pr.name, t.name from $schema1.scrrequest r, $schema1.users u, $schema1.scrstatus s, $schema1.scrpriority p, $schema1.product pr, $schema1.scrtype t where pr.id = $productid and r.status = s.id and r.submittedby = u.id and r.priority = p.id and pr.id = r.product and t.id = r.type order by r.id";
	my $results = $dbh -> prepare ($pick);
	$results -> execute;
	my $bg = "#eeeeee";
	my $count = 0;
	while (my @values = $results -> fetchrow_array) {
	    my ($rid, $sid, $status, $uid, $user, $desc, $date, $priority, $rationale, $product, $type) = @values;
	    print "<tr><td valign=top width=125><font size=-1 face=arial><b>ID:</b></td><td><font size=-1 face=arial>" . formatID('CREQ', 5, $rid) . "</td></tr>\n";
	    $desc =~ s/\n/<BR>/g;
	    print "<tr><td valign=top><font size=-1 face=arial><b>Description:</td><td><font size=-1 face=arial>$desc</td></tr>\n";
	    $rationale =~ s/\n/<BR>/g;
	    print "<tr><td valign=top><font size=-1 face=arial><b>Rationale:</td><td><font size=-1 face=arial>$rationale</td></tr>\n";
	    my $clop = ($sid==5||$sid==6||$sid==7||$sid==8) ? "Closed" : "Open";
	    print "<tr><td valign=top><font size=-1 face=arial><b>Status:</td><td><font size=-1 face=arial>$clop</td></tr>\n";
	    print "<tr><td valign=top><font size=-1 face=arial><b>Status Description:</td><td><font size=-1 face=arial>$status</td></tr>\n";
	    print "<tr><td valign=top><font size=-1 face=arial><b>Priority:</td><td><font size=-1 face=arial>$priority</td></tr>\n";
	    print "<tr><td valign=top><font size=-1 face=arial><b>Type:</td><td><font size=-1 face=arial>$type</td></tr>\n";
	    print "<tr><td valign=top><font size=-1 face=arial><b>Product:</td><td><font size=-1 face=arial>$product</td></tr>\n";
	    print "<tr><td valign=top><font size=-1 face=arial><b>Entered By:</td><td><font size=-1 face=arial>$user</td></tr>\n";
	    print "<tr><td valign=top><font size=-1 face=arial><b>Date Entered:</td><td><font size=-1 face=arial>$date</td></tr>\n";
	    print "<tr><td colspan=2><hr width=50%></td></tr>";
	}
	$results -> finish;
    }
    else {
	print "No change requests for this product.\n";
    }
    print "</table>\n";
    print "</form>\n";
}

###########################
print "<br><br>\n</body>\n</html>\n";
my $stat = db_disconnect($dbh);

#################
sub drawResults {
#################
    my $getprodid = "select id from $schema1.product where acronym = upper(\'$schema\')";
    my $productid = $dbh -> selectrow_array ($getprodid);
    my ($total) = $dbh -> selectrow_array ("select count(*) from $schema1.scrrequest where product = $productid");
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    print "<CENTER><br>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=750 bgcolor=#ffffff>\n";
    print "<TR><TD COLSPAN=7 BGCOLOR=#cdecff><FONT COLOR=#000099 SIZE=4><B>All Change Requests ($total total)</TD></TR>\n";#cdecff
    if ($total > 0) {
        print "<tr bgcolor=#d8d8d8>\n";
	print "<th><font size=-1>ID</th>\n";
	print "<th><font size=-1>Request Description</th>\n";
	print "<th><font size=-1>Status</th>\n";
	print "<th><font size=-1>Status&nbsp;Description</th>\n";
	print "<th><font size=-1>Entered By</th>\n";
	print "<th><font size=-1>Date&nbsp;Entered</th>\n";
	print "<th><font size=-1>Priority</th>\n";
	print "<tr><td colspan=6></td><tr>\n";
	
	my $pick = "select r.id, s.description, s.id, r.submittedby, u.firstname || ' ' || u.lastname, r.description, to_char(r.datesubmitted, 'MM/DD/YYYY'), p.description, pr.name from $schema1.scrrequest r, $schema1.users u, $schema1.scrstatus s, $schema1.scrpriority p, $schema1.product pr where pr.id = $productid and r.status = s.id and r.submittedby=u.id and r.priority=p.id and r.product=pr.id order by r.id";
	my $results = $dbh -> prepare ($pick);
	$results -> execute;
	my $bg = "#eeeeee";
	my $count = 0;
	while (my @values = $results -> fetchrow_array) {
	    my ($rid, $status, $sid, $uid, $user, $desc, $date, $priority, $product) = @values;
	    print "<tr bgcolor=$bg><td nowrap><font size=-1><A HREF=\"javascript:browseDetails($rid);\">" . formatID('CREQ', 5, $rid) . "</a></font></td>\n";
	    print "<td nowrap><font size=-1>" . getDisplayString ($desc, 30) . "</font></td>\n";
	    print "<td nowrap><font size=-1>";
	    print "Open" if ($sid==1 || $sid==2 || $sid==3 || $sid==4);
	    print "Closed" if ($sid==5 || $sid==6 || $sid==7 || $sid==8);
	    print "</font></td>\n";
	    print "<td nowrap><font size=-1>$status</font></td>\n";
	    print "<td nowrap><font size=-1>$user</font></td>\n";
	    print "<td nowrap><font size=-1>$date</font></td>\n";
	    print "<td nowrap><font size=-1>$priority</font></td>\n";
	    $count++;
	    $bg = ($count%2) ? "#ffffff" : "eeeeee";
	}
	$results -> finish;
    }
    print "</TABLE>\n";

    print "<br><center><input type=button name=genrep value=\"Generate Report\" onClick=doReport();>&nbsp;&nbsp;";
}

#################
sub drawDetails {
#################
    print "<INPUT TYPE=HIDDEN NAME=option VALUE=>\n";
    print "<INPUT TYPE=HIDDEN NAME=id VALUE=>\n";
    my $rid = $mycgi -> param('id');
    my ($sth, $sql, $element);

    $sql = "select to_char(r.datesubmitted, 'MM/DD/YYYY'), u.firstname || ' ' ||u.lastname, p.description, s.id, s.description, r.description, r.rationale, pr.name, t.name from $schema1.scrrequest r, $schema1.users u, $schema1.scrpriority p, $schema1.scrstatus s, $schema1.product pr, $schema1.scrtype t where r.id = $rid and r.product = $productid and u.id = r.submittedby and p.id = r.priority and s.id = r.status and r.product = pr.id and r.type = t.id";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    my ($date, $uid, $pid, $sid, $status, $desc, $rat, $product, $type) = $sth->fetchrow_array();
    $desc =~ s/\n/<BR>/g;  # request description
    $rat =~ s/\n/<BR>/g; # request rationale
    print "<BR><BR>";
    print "<CENTER>\n";
    print "<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=3 WIDTH=650>\n";
    print "<tr><td BGCOLOR=#cdecff COLSPAN=2><FONT COLOR=#000099 SIZE=4><B>Change Request Information</B></FONT></TD></TR>\n";
    print "<TR bgcolor=#eeeeee><td WIDTH=120 valign=top><B>ID</B></TD><TD valign=top><b>" . formatID ('CREQ', 5, $rid) . "</b></TD></TR>\n";
    print "<tr bgcolor=#ffffff><td valign=top><B>Description</B></TD><TD valign=top>$desc</TD></TR>\n";
    print "<tr bgcolor=#eeeeee><td VALIGN=TOP><B>Priority</B></TD><TD WIDTH=400 VALIGN=TOP>$pid</TD></TR>\n";
    print "<tr bgcolor=#ffffff><td VALIGN=TOP><B>Type</B></TD><TD WIDTH=400 VALIGN=TOP>$type</TD></TR>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><B>Rationale</B></TD><TD valign=top>$rat</A></TD></TR>\n";
    my $clop = ($sid < 5) ? "Open" : "Closed";
    print "<tr bgcolor=#ffffff><td valign=top><B>Status</B></TD><TD valign=top>$clop</TD></TR>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><B>Status Description</B></TD><TD valign=top>$status</TD></TR>\n";
    print "<tr bgcolor=#ffffff><td valign=top><B>Affected Product</B></TD><TD valign=top>$product</TD></TR>\n";
    print "<tr bgcolor=#eeeeee><td valign=top><B>Date Entered</B></TD><TD valign=top>$date</TD></TR>\n";
    print "<tr bgcolor=#ffffff><td valign=top><B>Entered By</B></TD><TD valign=top>$uid</TD></TR>\n";
    print "</TABLE>\n";
}

#################
sub get_next_id {
#################
    my $dbh=$_[0];
    my $tablename = $_[1];

    my $sqlstring;
    my $csr;
    my $rv;
    my @nextvalue;
    my $rc;

    $sqlstring = "SELECT $schema1.SCRREQUEST_" . $schema . "_ID_SEQ.NEXTVAL FROM DUAL";
    $csr=$dbh->prepare($sqlstring);
    $rv=$csr->execute;
    @nextvalue=$csr->fetchrow_array;
    $rc = $csr->finish;

    return ($nextvalue[0]);
}
