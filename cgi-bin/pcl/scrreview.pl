#!/usr/local/bin/perl -w
#
# CGI screen for SCR processing
#
# $Source: /data/dev/rcs/pcl/perl/RCS/scrreview.pl,v $
# $Revision: 1.10 $
# $Date: 2003/03/11 19:12:14 $
# $Author: naydenoa $
# $Locker:  $
# $Log: scrreview.pl,v $
# Revision 1.10  2003/03/11 19:12:14  naydenoa
# Added session management.
#
# Revision 1.9  2003/02/11 20:39:03  naydenoa
# Updated !/usr/local/bin/newperl to !/usr/local/bin/perl
# Updated SCR to CR
# Changed processing to cgiresults from main
# Changed status references to ID from description
# Moved CR update processing to updateSCR function in DB_SCR module
# Moved remarks insert to insertRemarks function in DB_SCR module
#
# Revision 1.8  2002/11/25 23:56:47  naydenoa
# Corrected spelling error in status name condition (Submitted - Awaiting Acceptance)
#
# Revision 1.7  2002/11/20 23:54:08  naydenoa
# Updated code handling SCR type to refer to name instead of description
#
# Revision 1.6  2002/11/07 21:16:43  naydenoa
# Removed test print
#
# Revision 1.5  2002/11/07 18:43:39  naydenoa
# Added checkLogin, updated form tags
#
# Revision 1.4  2002/11/05 23:51:42  naydenoa
# Changed "dateapproved" to "dateaccepted"
#
# Revision 1.3  2002/10/31 18:51:14  naydenoa
# Added use of UI and DB modules, enhanced workflow, cleaned up code
#
# Revision 1.2  2002/09/18 21:50:11  atchleyb
# updated to remove DB_Utilities
#
# Revision 1.1  2002/09/17 21:20:02  starkeyj
# Initial revision
#

use strict;
use integer;
use SharedHeader qw(:Constants);
use Tables;
use UI_SCR qw(:Functions);
use DB_SCR qw(:Functions);
use CGI;
use DBShared qw(:Functions);
use UIShared qw(:Functions);
use UI_Widgets qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use Tie::IxHash;
tie my %lookupHash, "Tie::IxHash";
my $key;
my $selected = "";
 
my $mycgi = new CGI;

my $schema = (defined($mycgi->param("schema"))) ? $mycgi->param("schema") : $ENV{'SCHEMA'};
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $urllocation;
my $command = (defined ($mycgi -> param("command"))) ? $mycgi -> param("command") : "write_request";
my $productid = (defined ($mycgi -> param("productid"))) ? $mycgi -> param("productid") : "";
my $projectid = (defined ($mycgi -> param("projectID"))) ? $mycgi -> param("projectID") : "";
my $userid = (defined($mycgi->param("userid"))) ? $mycgi->param("userid") : "";
my $username = (defined($mycgi->param("username"))) ? $mycgi->param("username") : "";
my $sessionID = ((defined($mycgi->param("sessionid"))) ? $mycgi->param("sessionid") : 0);

my $error = "";

&checkLogin (cgi => $mycgi);

my $dbh = db_connect();
$dbh -> {LongReadLen}=1000000;

if ($SYSUseSessions eq 'T') {
    &validateCurrentSession(dbh=>$dbh, schema=>$schema, userID=>$userid, sessionID=>$sessionID);
}

tie my %lookup_values, "Tie::IxHash";

print $mycgi->header('text/html');
print "<html>\n<head>\n";
print "<meta http-equiv=expires content=now>\n";
print "<title>Change Request - review and assignment</title>\n";
print "<script src=$SYSJavaScriptPath/utilities.js></script>\n";
print "<script src=$SYSJavaScriptPath/widgets.js></script>\n";
print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
print "<!--\n";
print "function validate_request_data(status) {\n";
print "    var msg = \"\";\n";
print "    var tmpmsg = \"\";\n";
print "    var returnvalue = true;\n";
print "    var validateform = document.$form;\n";
print "    if (status == 1 || status == 11) {\n";
print "        if (validateform.accepted[0].checked) {\n";
print "            msg += (validateform.priority.value==\"\") ? \"You must enter the assigned priority for this request.\\n\" : \"\";\n";
print "            msg += (validateform.developer.value==\"\") ? \"You must enter the primary developer for this request.\\n\" : \"\";\n";
print "            msg += (validateform.estimate.value==\"\") ? \"You must enter the estimated cost for this request.\\n\" : \"\";\n";
print "            msg += (validateform.analysis.value==\"\") ? \"You must enter the analysis notes for this request.\\n\" : \"\";\n";
print "            msg += ((tmpmsg = validate_date(validateform.duedate_year.value, validateform.duedate_month.value, validateform.duedate_day.value, 0, 0, 0, 0, false, true, false)) == \"\") ? \"\" : \"Date Due - \" + tmpmsg + \"\\n\";\n\n";
print "        }\n";
print "        else {\n";
print "            for (var i = 1; i <= 4; i++) {\n";
print "                msg += (validateform.accepted[i].checked && validateform.rejectrat.value==\"\") ? \"You must enter the rationale for this decision.\\n\" : \"\";\n";
print "            }\n";
print "        }\n";
print "    }\n";
print "    else if (status == 3 || status == 14) {\n";
print "       msg += (validateform.actions.value==\"\") ? \"You must enter the actions taken to fulfil the request.\\n\" : \"\";\n";
print "       msg += (validateform.actual.value==\"\") ? \"You must enter the actual cost of the request.\\n\" : \"\";\n";
print "    }\n";
print "    else if (status == 4) {\n";
print "        msg += (validateform.approved[1].checked && validateform.rejectrat.value==\"\") ? \"You must enter the rationale for rework.\\n\" : \"\";\n";
print "    }\n";
print "    if (msg != \"\") {\n";
print "        alert(msg);\n";
print "        returnvalue = false;\n";
print "    }\n";
print "    return (returnvalue);\n";
print "}\n";
print "function selectemall(selectobj) {\n";
print "    for(var i = 0; ((selectobj.options[i].value != \"\") ? (selectobj.options[i].selected = true) : true) && (i < (selectobj.length - 2)) ; i++);\n";
print "}\n\n";
print "function update_request(status) {\n";
print "    var tempcgiaction;\n";
print "    var returnvalue = true;\n";
print "    if (validate_request_data(status)) {\n";
print "        tempcgiaction = document.$form.command.value;\n";
print "        document.$form.command.value = \"update_request\";\n";
print "        document.$form.target = 'cgiresults'\n";
print "        document.$form.submit();\n";
print "        document.$form.command.value = tempcgiaction;\n";
print "    }\n";
print "    else {\n";
print "        returnvalue = false;\n";
print "    }\n";
print "    return (returnvalue);\n";
print "}\n\n";
print "//-->\n";
print "</script>\n";
print &doStandardJS (form => $form, path => $path);
print "</head>\n";
print "<body background=$SYSImagePath/background.gif text=$SYSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
print "<form name=$form method=post action=$path$form.pl target=main>\n";
print "<input type=hidden name=command value=$command>\n";
print "<input name=userid type=hidden value=$userid>\n";
print "<input name=username type=hidden value=$username>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=sessionid value='$sessionID'>\n";

##################################
if ($command eq "write_request") {
##################################
    my $rid = $mycgi -> param ("requestid");
    my %requesthash = getSCRInfo (dbh => $dbh, schema => $schema, rid => $rid, pid => $productid);
    my $act = $requesthash{'actionstaken'};
    my $actions = $requesthash{'actualcost'};
    my $est = $requesthash{'estimatedcost'};
    my $analysis = $requesthash{'analysis'};
    my $dev = $requesthash{'developer'};
    my $rejrat = $requesthash{'rejectionrationale'};
    my $stat = $requesthash{'status'};
    my $pri = $requesthash{'priority'};
    my $type = $requesthash{'type'};
    my $str;
    my $doit;
    $act = ($act) ? $act : "";
    $actions = ($actions) ? $actions : "";
    $est = ($est) ? $est : "";
    $analysis = ($analysis) ? $analysis : "";
    $dev = ($dev) ? $dev : "";
    $rejrat = ($rejrat) ? $rejrat : "";
    print "<table width=650 align=center cellspacing=10><tr><td>\n";
    print "<input type=hidden name=requestid value=$rid>";
    print "<input type=hidden name=projectID value=$projectid>";
    print "<input type=hidden name=productid value=$productid>";
    print "<input type=hidden name=status value=$stat>";
    my $status = singleValueLookup (dbh => $dbh, schema => $schema, table => "scrstatus", lookupid => $stat);
    if ($stat == 1 || $stat == 11) {
	print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => 'CR Acceptance and Assignment');
	print &doDisplayTable (rid => $rid, productid => $productid, dbh => $dbh, schema => $schema);
	print "</td></tr>\n";
	print "<tr><td><hr width=50%></td></tr>\n";
	if ($status eq "Tabled") {
	    print "<tr><td>";
	    print &startTable (width => 650, title => "This Change Request has been tabled", columns => 2);
	    print &addSpacerRow (columns => 2);
	    print &startRow ();
	    print &addCol (width => 160, value => "Rationale for Decision", isBold => 1);
	    print &addCol (value => $rejrat);
	    print &endRow;
	    print &endTable . "</td></tr>\n";
	}
	print "<tr><td align=left><b><li>Request Acceptance / Rejection</b>\n";
	my @values = ("accept", "reject", "withdraw", "table", "nochange");
	my @strings = ("Accept Request", "Reject Request", "Withdraw Request", "Table Request", "No Software Change Required");
	print &doRadioButton (howmany => 5, values => \@values, strings => \@strings, name => 'accepted');
	print "</td></tr>\n";
	print "<tr><td><b><li>Rationale for decision:</b>&nbsp;&nbsp; (enter if request is not accepted<br><textarea name=rejectrat cols=75 rows=5>$rejrat</textarea></td></tr>";
        print "<tr><td><hr width=50%></td></tr>";
	print "<tr><td><h3 align=center>RSIS Analysis and Assignment</h3></td></tr>";
	print "<tr><td><li><b>Request Type:&nbsp;&nbsp;</b>\n";
	print "<select name=\"type\">\n";
	print "<option value='' selected>Select Request Type&nbsp;\n";
	%lookupHash = %{&getLookupValues (dbh => $dbh, schema => $schema, idColumn => "id", nameColumn => "name", table => "scrtype", orderBy => "name")};
	foreach $key (keys %lookupHash) {
	    my $selected = ($key == $type) ? " selected" : "";
	    print "<option value=\"$key\"$selected>$lookupHash{$key}\n";
	}
	print "</select></td></tr>\n";
	print "<tr><td><li><b>Assigned Priority:&nbsp;&nbsp;</b>\n";
	print "<select name=\"priority\">\n";
	print "<option value='' selected>Select Request Priority&nbsp;\n";
	%lookupHash = %{&getLookupValues (dbh => $dbh, schema => $schema, idColumn => "id", nameColumn => "description", table => "scrpriority", orderBy => "id")};
	foreach $key (keys %lookupHash) {
	    my $selected = ($key == $pri) ? " selected" : "";
	    print "<option value=\"$key\"$selected>$lookupHash{$key}\n";
	}
	print "</select> (enter if request is accepted)</td></tr>\n";
	print "<input type=hidden name=prioritize value=1>";
        print "<tr><td><li><b>Assign Primary Developer:&nbsp;&nbsp;</b>\n";
        print "<select name=developer>\n";
        print "<option value=\"\" selected>Select Primary Developer\n";
	%lookupHash = %{&getLookupValues (dbh => $dbh, schema => $schema, idColumn => "id", nameColumn => "firstname || ' ' || lastname", table => "users", where => "id > 1000", orderBy => "lastname")};
	foreach $key (keys %lookupHash) {
	    print "<option value=\"$key\">$lookupHash{$key}\n";
	}
        print "</select></td></tr>\n";
        print "<tr><td><li><b>Estimated Cost:</b>&nbsp;&nbsp;<input type=text name=estimate size=5 maxlength=5 value=$est> (in work hours) </td></tr>\n";
        print "<input type=hidden name=prioritize value=1>\n";
	print "<tr><td><li><b>Due Date:</b>&nbsp;&nbsp;" . build_date_selection ("duedate", "$form", "today") . "</td></tr>\n";
        print "<tr><td><li><b>Estimate and Analysis Notes:</b><br><textarea name=analysis cols=75 rows=5>$analysis</textarea></td></tr>\n";

    }
    elsif ($status eq "Accepted - In Development" || $status eq "Resubmitted for Rework") {
	print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => 'CR Development');
	print &doDisplayTable (rid => $rid, productid => $productid, dbh => $dbh, schema => $schema);
	print "</td></tr>";
	print "<tr><td><hr width=50%></td></tr>\n";
	if ($status eq "Resubmitted for Rework") {
	    print "<tr><td>";
	    print &startTable (width => 650, title => "This Change Request has been returned for rework", columns => 2);
	    print &addSpacerRow (columns => 2);
	    print &startRow ();
	    print &addCol (width => 160, value => "Rationale for Rework", isBold => 1);
	    print &addCol (value => $rejrat);
	    print &endRow;
	    print &endTable . "</td></tr>\n";
	}
	print "<tr><td><li><b>Actions Taken:</b><br><textarea cols=75 rows=5 name=actions>$act</textarea></td></tr>\n";
	print "<tr><td><li><b>Actual Cost:</b>&nbsp;&nbsp;<input type=text name=actual size=5 maxlength=5 value=$actions> (in work hours)</td></tr>\n";
	print "<input type=hidden name=type value=$type>";
    }
    elsif ($status eq "Completed - Awaiting Approval") {
	print &writeTitleBar(userName => $username, userID => $userid, schema => $schema, title => 'CR Approval');
	print &doDisplayTable (rid => $rid, productid => $productid, dbh => $dbh, schema => $schema);
        print "</td></td>";
	print "<tr><td><hr width=50%></td></tr>\n";
	print "<tr><td align=left><b><li>Work Approval</b>\n";
	my @values = ("approve", "rework");
	my @strings = ("Approve", "Return for Rework");
	print &doRadioButton (howmany => 2, values => \@values, strings => \@strings, name => 'approved');
	print "</td></tr>\n";
	print "<tr><td><b><li>Rework Rationale:</b>&nbsp;&nbsp; (enter if request needs to be reworked)<br><textarea name=rejectrat cols=75 rows=5></textarea></td></tr>";
	print "<input type=hidden name=type value=$type>";
    }
    print "<tr><td><hr width=50%></td></tr>\n";
    print "<tr><td><li><b>Remarks:</b><br><textarea cols=75 rows=5 name=remarks></textarea></td></tr>";
    print "<tr><td>" . &doRemarksTable (dbh => $dbh, schema => $schema, cid => $rid, iid => $productid) . "</td></tr>";
    print "<tr><td align=center><br><!-- input type=button value=\"Save as Draft\" onClick=\"return(save_request($stat))\">&nbsp; --><input type=button value=\"Update Request\" onClick=\"return(update_request($stat))\">\n";
    print "</td></tr></table></td></tr></table>\n";
} ####  end if write_request  ####

#################################
if ($command eq "save_request") {
#################################
} ####  end if save_request  ####

###################################
if ($command eq "update_request") {
###################################
    no strict 'refs';
    my $rid = $mycgi -> param ("requestid");
    my $status = $mycgi -> param ("status");
    my $accepted = $mycgi -> param ("accepted");
    my $rejrat = $mycgi -> param ("rejectrat");
    my $srejrat = ($rejrat) ? ":rejclob" : "NULL";
    my $priority = $mycgi -> param ("priority");
    my $type = $mycgi -> param ("type");
    my $developer = $mycgi -> param ("developer");
    my $estimate = $mycgi -> param ("estimate");
    my $analysis = $mycgi -> param ("analysis");
    my $sanalysis = ($analysis) ? ":analysisclob" : "NULL";
    my $actions = $mycgi -> param ("actions");
    my $sactions = ($actions) ? ":actclob" : "NULL";
    my $actual = $mycgi -> param ("actual");
    my $approved = $mycgi -> param ("approved");
    my $duedate_month = $mycgi->param('duedate_month');
    my $duedate_day = $mycgi->param('duedate_day');
    my $duedate_year = $mycgi->param('duedate_year');
    my $duedate = ($duedate_month) ? "$duedate_month/$duedate_day/$duedate_year" : "";
    my $remarks = ($mycgi -> param ("remarks")) ? ($mycgi -> param ("remarks")) : "";
    my $newstatus;
    my $activity;
    my $update;
    my $updatestr = "update $schema.scrrequest set ";
    eval {
	$activity = "Update SC request $rid";
	if ($status == 1 || $status == 11) {
	    $updatestr .= "dateaccepted = SYSDATE, ";
	    if ($accepted eq "accept") {
		$newstatus = 3;
		$updatestr .= "assignedpriority = $priority, type = $type, ";
		$updatestr .= "estimatedcost = $estimate, developer = '$developer', analysis = $sanalysis, datedue = to_date('$duedate','MM/DD/YYYY'), ";
	    }
	    elsif ($accepted eq "reject") {
		$newstatus = 6;
		$updatestr .= "rejectionrationale = $srejrat, ";
	    }
	    elsif ($accepted eq "withdraw") {
		$newstatus = 7;
		$updatestr .= "rejectionrationale = $srejrat, ";
	    }
	    elsif ($accepted eq "table") {
		$newstatus = 11;
		$updatestr .= "rejectionrationale = $srejrat, ";
	    }
	    elsif ($accepted eq "nochange") {
		$newstatus = 8;
		$updatestr .= "rejectionrationale = $srejrat, ";
	    }
	}
	elsif ($status == 3 || $status == 14) {
	    if ($type == 1) {
		$newstatus = 4;
	    }
	    else {
		$newstatus = 5;
		$updatestr .= "dateclosed = SYSDATE, ";
	    }
	    $updatestr .= "datecompleted = SYSDATE, actualcost = $actual, actionstaken = $sactions, ";
	}
	elsif ($status == 4) {
	    if ($approved eq "approve") {
		$newstatus = 5;
		$updatestr .= "dateclosed = SYSDATE, ";
	    }
	    else {
		$newstatus = 14;
		$updatestr .= "rejectionrationale = $srejrat, ";
	    }
	}
	$updatestr .= "status = $newstatus, lastupdated = SYSDATE, updatedby = $userid where id = $rid and product = $productid";

        &updateSCR (dbh => $dbh, schema => $schema, updatestr => $updatestr, status => $status, analysis => $analysis, rejrat => $rejrat, actions => $actions);
	if ($remarks ne "") {
	    $activity = "Insert remark for request $rid";
	    &insertRemarks (dbh => $dbh, schema => $schema, rid => $rid, uid => $userid, pid => $productid, remarks => $remarks);
	}
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
	my $ridformatted = formatID('CREQ', 5, $rid);
        my $theprod = singleValueLookup (dbh => $dbh, schema => $schema, table => "product", column => "acronym", lookupid => $productid);
        my $logmessage = "$theprod $ridformatted ";
        $logmessage .= "accepted and submitted for development" if ($newstatus == 3);
        $logmessage .= "completed" if ($newstatus == 4);
        $logmessage .= "completion approved" if ($newstatus == 5);
        $logmessage .= "not accepted" if ($newstatus == 6);
        $logmessage .= "withdrawn" if ($newstatus == 7);
        $logmessage .= "requires no software change" if ($newstatus == 8);
        $logmessage .= "tabled" if ($newstatus == 11);
        $logmessage .= "resubmitted for rework" if ($newstatus == 14);
        &log_activity ($dbh, $schema, $userid, $logmessage);
	print "<body background=$SYSImagePath/background.gif text=$SYSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
	print "alert(\"Software change request $ridformatted updated.\");";
        print "submitForm('home','query');\n";
	print "parent.cgiresults.location=\"". $path . "blank.pl?userid=$userid&username=$username&schema=$schema\";\n";
	print "//-->\n";
	print "</script>\n";
    }
} ####  end if update_request  ####

print "</form>\n</center>\n</font>\n";
print "<br><br></body>\n</html>\n";
my $stat = db_disconnect($dbh);


