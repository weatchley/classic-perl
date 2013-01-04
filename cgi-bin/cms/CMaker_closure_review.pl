#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# Commitment Maker review of the suggested closure of the commitment.
#
# $Source: /data/dev/rcs/cms/perl/RCS/CMaker_closure_review.pl,v $
# $Revision: 1.44 $
# $Date: 2002/09/17 23:01:49 $
# $Author: atchleyb $
# $Locker:  $
# $Log: CMaker_closure_review.pl,v $
# Revision 1.44  2002/09/17 23:01:49  atchleyb
# changed dbi long read length and truncate value also relocated calls
#
# Revision 1.43  2001/11/15 19:00:20  naydenoa
# Added actions to commitment info display.
# ,
#
# Revision 1.42  2001/05/07 16:50:30  naydenoa
# Updated evals
#
# Revision 1.41  2001/05/02 22:35:34  naydenoa
# Modified evals, calls to Edit_Screens
#
# Revision 1.40  2001/01/02 17:19:24  naydenoa
# More code clean-up
#
# Revision 1.39  2000/12/07 18:49:43  naydenoa
# Code clean-up
#
# Revision 1.38  2000/11/07 23:14:31  naydenoa
# Adde issue source discplay, took out rationales, added mail
# notification.
#
# Revision 1.37  2000/10/31 19:39:05  naydenoa
# Updated function calls to Edit_Screens
#
# Revision 1.36  2000/10/31 16:56:16  naydenoa
# Added remark display
# Changed table width to 650, text area width to 75
#
# Revision 1.35  2000/10/24 19:59:15  naydenoa
# Updated call to Edit_Screens (commitment info table)
#
# Revision 1.34  2000/10/18 23:29:13  munroeb
# modified activity log message
#
# Revision 1.33  2000/10/17 23:40:00  munroeb
# renamed formatID to formatID2 to prevent conflict
#
# Revision 1.32  2000/10/17 23:14:06  munroeb
# modified log message
#
# Revision 1.31  2000/10/17 15:46:22  munroeb
# removed log_history perm
#
# Revision 1.30  2000/10/16 16:34:37  munroeb
# removed log_history function
#
# Revision 1.29  2000/10/06 16:27:26  munroeb
# added log_activity to script
#
# Revision 1.28  2000/10/03 20:38:08  naydenoa
# Updates status id's and references.
#
# Revision 1.27  2000/09/29 21:34:12  naydenoa
# Changed references to statuses and roles (now by ID)
#
# Revision 1.26  2000/09/28 20:07:09  naydenoa
# Checkpoint after Version 2 release
#
# Revision 1.25  2000/09/18 15:03:20  naydenoa
# More interface updates
#
# Revision 1.24  2000/09/08 23:49:57  naydenoa
# More interface modifications.
#
# Revision 1.23  2000/08/25 16:09:10  atchleyb
# changed Technical Lead to Discipline Lead
#
# Revision 1.22  2000/08/21 22:32:32  atchleyb
# fixed var name bug
#
# Revision 1.21  2000/08/21 20:11:55  atchleyb
# fixed dir bug
#
# Revision 1.20  2000/08/21 17:43:51  atchleyb
# added shcke shcema line
#
# Revision 1.19  2000/07/24 16:49:49  johnsonc
# Inserted GIF file for display.
#
# Revision 1.18  2000/07/17 16:45:50  atchleyb
# placed form in table of width 750
#
# Revision 1.17  2000/07/11 15:08:04  munroeb
# finished modifying html formatting
#
# Revision 1.16  2000/07/06 23:17:57  munroeb
# finished making modifications to html and javascripts
#
# Revision 1.15  2000/07/05 23:27:54  munroeb
# made changes to html and javascripts
#
# Revision 1.14  2000/07/05 21:48:42  munroeb
# made minor tweaks to fix javascripts and html
#
# Revision 1.13  2000/06/21 21:59:28  johnsonc
# Editted opening page select object to support double click event.
#
# Revision 1.12  2000/06/16 15:47:23  johnsonc
# Revise WSB table entry to be optional display in edit and query screens
#
# Revision 1.11  2000/06/15 21:30:38  zepedaj
# Changed code to allow Commitment Maker Approval Rationale optional,
# while keeping Rejection Rationale Mandatory
#
# Revision 1.10  2000/06/14 18:40:00  zepedaj
# Changed Functional To Technical per DOE request
#
# Revision 1.9  2000/06/13 21:39:51  zepedaj
# Fixed width of tables so the columns would be the same[4~
#
# Revision 1.8  2000/06/13 19:17:43  johnsonc
# Change 'Rationale For Commitment' field to display only when data is present
#
# Revision 1.6  2000/06/12 15:37:03  johnsonc
# Add 'C' in front of commitment ID and 'I' in front of issue ID.
# Add 'proposed' to edit and view commitment page titles.
#
# Revision 1.5  2000/06/09 20:03:00  johnsonc
# Edit secondary discipline text area to display only when it contains data
#
# Revision 1.4  2000/06/08 18:08:52  johnsonc
# Install commitment comment text box.
#
# Revision 1.3  2000/05/19 23:43:46  zepedaj
# Changed code for the final WBS structure
#
# Revision 1.2  2000/05/18 23:02:51  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# cleaned up hardcoded paths
#
# Revision 1.1  2000/05/16 23:44:10  zepedaj
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
my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

# print content type header
print $cmscgi->header('text/html');

my $pagetitle = "Commitment Maker Closure Review";
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
    doSetTextImageLabel('Commitment Closure Review');
//-->
</script>
testlabel1

my $dbh = oncs_connect();

my $CMaker_Roleid = 5; # Commitment Maker
my $CMaker_closure_review_statusid = 14; # Commitment Maker Closure Review

#####################################
if ($cgiaction eq "editcommitment") {
#####################################
    my $activity;
    my $commitmentid = $cmscgi->param('commitmentid');
    my $textareawidth = 75;
    my $commitmentidstring = substr("0000$commitmentid", -5);
    my ($statusid, $actionstaken);
    my %responseinfo;
    my %productsaffectedhash;
    my %committedorghash;
    my %disciplinehash;
    my %commitmentlevelhash;
    my %productshash;
    my %organizationhash;
    my %orghash;
    my %letterhash;
    my %wbshash;
    my %usershash;
    my %statushash;
    eval {
#	$dbh->{LongReadLen} = $TitleLength;
	$dbh->{LongReadLen} = 10000000;
	$dbh->{LongTruncOk} = 1;
	($statusid, $actionstaken) = $dbh -> selectrow_array ("select statusid, actionstaken from $SCHEMA.commitment where commitmentid = $commitmentid");
	%responseinfo = lookup_response_information($dbh, $commitmentid);
	%productsaffectedhash = get_lookup_values($dbh, "productaffected", "productid", "'True'", "commitmentid = $commitmentid");
	%committedorghash = get_lookup_values($dbh, "committedorg", "organizationid", "'True'", "commitmentid = $commitmentid");
	%disciplinehash = get_lookup_values($dbh, 'discipline', 'disciplineid', 'description');
	%commitmentlevelhash = get_lookup_values($dbh, 'commitmentlevel', 'commitmentlevelid', 'description');
	%productshash = get_lookup_values($dbh, 'product', 'description', 'productid', "isactive='T'");
	%organizationhash = get_lookup_values($dbh, 'organization', 'organizationid', 'name');
	%orghash = get_lookup_values($dbh, 'organization', "name || ' - ' || department || ' - ' || division || ';' || organizationid", 'organizationid');
	%letterhash = get_lookup_values($dbh, 'letter', "accessionnum || ' - ' || to_char(sentdate, 'MM/DD/YYYY') || ';' || letterid", 'letterid');
	%wbshash = get_lookup_values($dbh, 'workbreakdownstructure', "controlaccountid", "controlaccountid || ' - ' || description");
	%usershash = get_lookup_values($dbh, 'users', "lastname || ', ' || firstname || ';' || usersid", 'usersid');
	%statushash = get_lookup_values($dbh, 'status', 'description', 'statusid', "isactive='T'");
	$dbh->{LongTruncOk} = 0;
    };
    if ($@) {
	my $logmessage = errorMessage($dbh, $username, $usersid, $SCHEMA, $activity, $@);
	$logmessage =~ s/\n/\\n/g;
	$logmessage =~ s/'/''/g;
        print "<script language=javascript><!--\n";
        print "   alert('$logmessage');\n";
        print "//--></script>\n";
    }

    my $responseid = $responseinfo{'responseid'};
    my $responsetext = $responseinfo{'text'};
    my $responsewrittendate = $responseinfo{'writtendate'};
    my $letteraccessionnum = $responseinfo{'accessionnum'};

    my $commitmenthasproducts = (defined(%productsaffectedhash) && ((values (%productsaffectedhash))[0] eq 'True'));

    my $key;

    print <<committable;
    <script language="JavaScript" type="text/javascript">
    <!--
    function validate_commitment_data() {
        var msg = "";
        var tmpmsg = "";
        var returnvalue = true;
        var validateform = document.editcommitment;
        if (msg != "") {
            alert(msg);
           returnvalue = false;
        }
        return (returnvalue);
    }
    function resubmit_commitment() {
        var tempcgiaction;
        var msg = "";
        var returnvalue = true;
        var validateform = document.editcommitment;
        msg += (validateform.resubmitrationale.value=="") ? "You must enter the resubmission rationale for this commitment if you are rejecting the closure.\\n" : "";
        if (msg != "") {
            alert(msg);
            returnvalue = false;
        }
        if (returnvalue) {
            document.editcommitment.submit();
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
    //-->
    </script>
    </head>
    <body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
    <table border=0 align=center width=650><tr><td><CENTER>
    <form name=editcommitment enctype="multipart/form-data" method=post target="control" action="$ONCSCGIDir/CMaker_closure_review.pl">
    <input name=cgiaction type=hidden value="resubmit_commitment">
    <input name=loginusersid type=hidden value=$usersid>
    <input name=loginusername type=hidden value=$username>
    <input name=commitmentid type=hidden value=$commitmentid>
    <input name=statusid type=hidden value=$statusid>
    <input type=hidden name=schema value=$SCHEMA>
committable
    print "<p><table summary=\"Enter Commitment Table\" width=100% border=0 align=center cellspacing=10>\n";
    eval {
	print &doIssueTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
	print &doIssueSourceTable (cid => $commitmentid, dbh => $dbh, schema => $SCHEMA);
	print &doHeadTable (dbh => $dbh, schema => $SCHEMA, cid => $commitmentid, cidstring => $commitmentidstring);
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
	print "<tr><td><hr width=50%></td></tr>\n";
	print "<tr><td align=left><b><li>Rationale for Rework:</b><br>\n";
	print "(If there is a deficiency in the work performed, add description of the deficiency and click \"Resubmit for Rework\")<br>\n";
	print "<textarea name=resubmitrationale cols=$textareawidth rows=5></textarea></td></tr>\n";
        print "<tr><td><hr width=50%></td></tr>\n";
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
    print "</table></td></tr>\n";
    print "<tr><td><center>\n";
    print "<input type=button name=resubmitcommitment value=\"Resubmit for Rework\" title=\"Resubmit Commitment to the DOE Discipline Lead for further review.\" onclick=\"return(resubmit_commitment())\">\n";
    print "<input type=button name=saveandcomplete value=\"Close Commitment\" title=\"Close the commitment.\" onclick=\"return(pass_on())\">\n</center>\n";
    print "</form>\n</td></tr></table>\n<br><br><br><br>\n";
    print "</body>\n</html>\n";
    
    &oncs_disconnect($dbh);
    exit 1;
}  ######################  endif editcommitment  ################

# resubmit the commitment
##########################################
if ($cgiaction eq "resubmit_commitment") {
##########################################
    no strict 'refs';

    #control variables
    my $commitmentid = $cmscgi->param('commitmentid');
    my $activity;

    # boolean variables, should be 0 or -1 (false/true)

    # commitment variables
    my $resubmitrationale = $cmscgi->param('resubmitrationale');
    my $resubmitrationalesql = ($resubmitrationale) ? ":resubmitrationaleclob" : "NULL";
    my $comments = $cmscgi->param('commenttext');

    #status variable depends on choice
    my $nextstatusid = 12; # DOE Discipline Lead Rework

    #sql strings
    my $commitmentupdatesql = "UPDATE $SCHEMA.commitment
                             SET resubmitrationale = $resubmitrationalesql,
                             statusid = $nextstatusid,
                             updatedby = $usersid
                             WHERE commitmentid = $commitmentid";
    eval {
	my $csr;
	$activity = "Update Commitment";
	$csr = $dbh->prepare($commitmentupdatesql);
	if ($resubmitrationale) {
	    $csr->bind_param(":resubmitrationaleclob", $resubmitrationale, {ora_type => ORA_CLOB, ora_field => "resubmitrationale" });
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
        //-->
        </script>
pageerror
    }
    else {
	&log_activity($dbh, "F", $usersid, "Commitment ".&formatID2($commitmentid, 'C')." updated and resubmitted to the DOE Discipline Lead for further work.");
	my ($primarydiscipline, $siteid) = $dbh -> selectrow_array ("select primarydiscipline, siteid from $SCHEMA.commitment where commitmentid = $commitmentid");
	my $modls = $dbh -> prepare ("select distinct usersid from $SCHEMA.defaultdisciplinerole where disciplineid = $primarydiscipline and roleid = 2 and siteid = $siteid");
	$modls -> execute;
	while (my ($modlid) = $modls -> fetchrow_array) {
	    my $notification = &notifyUser(dbh => $dbh, schema => $SCHEMA, userID => $modlid);
	}   
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
}  #######################  endif resubmit_commitment  #################

# pass the commitment to the next user
##############################
if ($cgiaction eq "pass_on") {
##############################
    no strict 'refs';

    #control variables
    my $commitmentid =  $cmscgi->param('commitmentid');
    my $activity;

    # Find user info; Site id of the user is the same for the commitment
    my $siteid = lookup_single_value($dbh, "users", "siteid", $usersid);

    # commitment variables
    my $comments = $cmscgi->param('commenttext');

    #status variable depends on choice
    my $nextstatusid = 15; # Closure Letter/DOECMgr Final Response

    #sql strings
    my $commitmentupdatesql ="UPDATE $SCHEMA.commitment
                            SET resubmitrationale = NULL,
                            closeddate = SYSDATE,
                            statusid = $nextstatusid,
                            updatedby = $usersid
                            WHERE commitmentid = $commitmentid";
    eval {
	my $csr;
	$activity = "Update Commitment";
	my $csr = $dbh->prepare($commitmentupdatesql);
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
	my $logmessage = "Commitment ".&formatID2($commitmentid, 'C')." closed";
	my $logtitle = "Commitment Closed";
	&log_activity($dbh, 'F', $usersid, $logmessage);
	my $cmgrs = $dbh -> prepare ("select distinct usersid from $SCHEMA.defaultsiterole where roleid = 4 and siteid = $siteid");
	$cmgrs -> execute;
	while (my ($cmgrid) = $cmgrs -> fetchrow_array) {
	    my $notification = &notifyUser(dbh => $dbh, schema => $SCHEMA, userID => $cmgrid);
	}	
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
}  #########################  endif pass_on  ########################

