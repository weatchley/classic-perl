#!/usr/local/bin/newperl -w
#
# Utilties Menu for CMS
#
# $Source: /data/dev/rcs/cms/perl/RCS/utilities.pl,v $
# $Revision: 1.31 $
# $Date: 2003/01/03 22:06:16 $
# $Author: naydenoa $
# $Locker:  $
# $Log: utilities.pl,v $
# Revision 1.31  2003/01/03 22:06:16  naydenoa
# Corrected retrieval of CCBID for CR entry/browse
#
# Revision 1.30  2003/01/03 21:56:31  naydenoa
# Added link to DOE manager utility screen - CR00023
#
# Revision 1.29  2002/11/14 00:00:23  naydenoa
# Removed reference to SCCBUSER table - sccbid is retrieved from SCM through the USERS and USER_ROLES tables
#
# Checkpoint
#
# Revision 1.28  2002/10/04 22:31:38  naydenoa
# Added DB disconnect.
#
# Revision 1.27  2002/10/04 21:47:43  naydenoa
# Added "use strict"
#
# Revision 1.26  2002/06/25 17:14:46  naydenoa
# Uncommented email notification enable/disable feature.
#
# Revision 1.25  2002/04/23 22:56:20  naydenoa
# Took out link to e-notification.
#
# Revision 1.24  2002/04/23 21:41:06  naydenoa
# Added link to user activity log
#
# Revision 1.23  2002/04/12 23:41:01  naydenoa
# Checkpoint
#
# Revision 1.22  2002/01/04 16:52:21  naydenoa
# Added link to BSC manager maintenance.
#
# Revision 1.21  2001/11/15 23:58:01  naydenoa
# Added action update, added access to user and discipline entry for
# Lynn Weishaar to accommodate the new leads entry.
#
# Revision 1.20  2001/08/30 21:51:24  naydenoa
# Added access to SCR browse and entry.
#
# Revision 1.19  2001/07/30 20:36:31  naydenoa
# Checkpoint - possible SCR addition
#
# Revision 1.18  2001/05/11 22:51:14  naydenoa
# Added check for roles, removed references to privileges
#
# Revision 1.17  2001/04/04 21:11:35  naydenoa
# Made discipline addition accessible to developers only
#
# Revision 1.16  2001/03/20 22:57:43  naydenoa
# Took out usermaint variable
#
# Revision 1.15  2001/03/20 22:41:38  naydenoa
# Made user maintenance accessible only to developers
#
# Revision 1.14  2001/01/30 22:58:53  naydenoa
# Add link to historical association
#
# Revision 1.13  2000/12/21 21:31:43  naydenoa
# Added role maintenance link
#
# Revision 1.12  2000/12/19 21:49:24  naydenoa
# Added link to KTI report for developers only
#
# Revision 1.11  2000/11/06 18:13:26  naydenoa
# Rearranged utilities. Took out Product, WBS, Level of Commitment,
# Role, Site, Privilege, Status insert/update. Took out Default
# Role assignments for possible rewrite. These will be handled
# manually. Took out commitment update section -- handled in
# Entries and Updates section.
#
# Revision 1.10  2000/10/24 16:11:47  naydenoa
# Took out issuetype reference
#
# Revision 1.9  2000/10/23 18:23:53  naydenoa
# Added link to source entry screen
#
# Revision 1.8  2000/10/18 22:03:22  naydenoa
# Added link to response update screen
#
# Revision 1.7  2000/10/12 22:05:58  munroeb
# added log_activity and log_error links
#
# Revision 1.5  2000/10/10 20:42:41  naydenoa
# Added links to issue/source update, changed some wording
#
# Revision 1.4  2000/09/25 20:06:55  atchleyb
# changed the way that developers are tested for
#
# Revision 1.3  2000/09/21 21:41:25  atchleyb
# updated tile
#
# Revision 1.2  2000/09/19 19:01:45  atchleyb
# changed the change user function to goto home.pl
#
# Revision 1.1  2000/08/31 23:24:57  atchleyb
# Initial revision
#
#

# get all required libraries and modules
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use Tie::IxHash;
use strict;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $oncscgi = new CGI;

$SCHEMA = (defined($oncscgi->param("schema"))) ? $oncscgi->param("schema") : $SCHEMA;

# tell the browser that this is an html page using the header method
print $oncscgi->header('text/html');

my $command = ((defined($oncscgi->param('command'))) ? (($oncscgi->param('command') gt " ") ? $oncscgi->param('command') : "menu") : "menu");

print "<!-- $command -->\n";

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

my $username = $oncscgi->param('loginusername');
my $usersid = $oncscgi->param('loginusersid');
my $projectid = 2;
my $productid = 2;
my $idstr;

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

# output page header
print <<pageheader;
<html>
<head>
<title>Utilities</title>
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>
<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) {    // not in frames
    location = '$ONCSCGIDir/login.pl';
}
doSetTextImageLabel('Utilities');

//function enterscr () {
//    var temptarget = document.$form.target;
//    var tempaction = document.$form.action;
//    var script = 'scrhome'; 
//    window.open ("", "scrwin", "height=350, width=750, status=no, toolbar=yes, scrollbars=yes");
//    document.$form.target = 'scrwin';
//    document.$form.action = '$SCMPath' + script + '.pl';
//    document.$form.cgiaction.value = 'write_request';
//    document.$form.submit();
//    document.$form.target = temptarget;
//    document.$form.action = tempaction;
//}

//-->
</script>
</head>
pageheader
$idstr = "&loginusername=$username&loginusersid=$usersid";

print <<maintmenustart;
<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>
<form name=$form method=post>
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
<input type=hidden name=schema value=$SCHEMA>
<input type=hidden name=type value=>

<SCRIPT LANGUAGE=JavaScript1.2>
function viewlog(logtype) {
    document.utilities.action = "$ONCSCGIDir/log.pl";
    document.utilities.type.value = logtype;
    document.utilities.method = "POST";
    document.utilities.submit();
}
</SCRIPT>

<table border=0 align=center><tr>
maintmenustart

if ($command eq 'menu') {
    my $sysadmin = does_user_have_role(dbh => $dbh, uid => $usersid, rid => 6);
    print "<td valign=top><br><ul>\n";
    print "<li><a href=\"$ONCSCGIDir/changepassword.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\">Change Your Password</a>\n";
    if ($sysadmin) {
	print "<li><b>View Logs:</b>&nbsp;&nbsp;<a href=\"javascript:viewlog(\'activity\');\">Activity</a>&nbsp;\n";
        print "<a href=\"javascript:viewlog(\'error\');\">Error</a></li>\n";
    }
    if ($usersid > 1000) {
        print "<li><a href=\"$ONCSCGIDir/kti.pl?schema=$SCHEMA&loginusersid=$usersid&loginusername=$username\">View KTI Report</a></li>\n";
        print "<li><a href=\"$ONCSCGIDir/utilities.pl?command=changeuser&schema=$SCHEMA&loginusersid=$usersid&loginusername=$username\">Become Another User</a></li>\n";
	print "<li><a href=$ONCSCGIDir/userlog.pl?schema=$SCHEMA&loginusersid=$usersid&loginusername=$username>User activity report</a>\n";
    }
#    my ($sccbid) = $dbh -> selectrow_array ("select u.id from scm.users u, scm.user_roles ur where u.username = '$username' and ur.projectid = $projectid and ur.roleid in (1,2,3,4) and u.id = ur.userid");
    my ($sccbid) = $dbh -> selectrow_array ("select sccbid from $SCHEMA.sccbuser where userid = $usersid");
    if ($sccbid) {
	print "<li><b>SCR:</b>&nbsp;&nbsp;<a href=$ONCSCGIDir/scrhome.pl?&schema=$SCHEMA&loginusersid=$usersid&loginusername=$username&sccbid=$sccbid>Enter</a>&nbsp;&nbsp;<a href=$ONCSCGIDir/scrbrowse.pl?&schema=$SCHEMA&loginusersid=$usersid&loginusername=$username&sccbid=$sccbid>Browse</a>";
    }
    print "</ul></td><td>&nbsp&nbsp&nbsp&nbsp</td>\n";
    print "<td valign=top><ul title=\"System Maintenance\">\n";
    if ($sysadmin) {
	print "<lh><b>System Maintenance</b>\n";
        print "<li><a href=\"$ONCSCGIDir/dcmm_maint.pl?action=query&updatetable=category&pagetitle=Category$idstr&schema=$SCHEMA\">Categories</a></li>\n";
        print "<li><a href=\"$ONCSCGIDir/dcmm_maint.pl?action=query&updatetable=keyword&pagetitle=Keyword$idstr&schema=$SCHEMA\">Keywords</a></li>\n";
        print "<li><a href=\"$ONCSCGIDir/organization_maint.pl?action=query&updatetable=organization&pagetitle=Organization$idstr&schema=$SCHEMA\">Organizations</a></li>\n";
	print "<li><a href=\"$ONCSCGIDir/role_maint.pl?action=query$idstr&schema=$SCHEMA\">Roles</a></li>\n";
    }
    if ($usersid > 1000 || $username eq "WEISHAAL") {
        print"<li><a href=\"$ONCSCGIDir/dcmm_maint.pl?action=query&updatetable=discipline&pagetitle=Discipline$idstr&schema=$SCHEMA\">Disciplines</a></li>\n";
        print "<li><a href=\"$ONCSCGIDir/users_maint.pl?action=query&updatetable=users&pagetitle=Users$idstr&schema=$SCHEMA\">Users</a></li>\n";
        print "<li><a href=\"$ONCSCGIDir/manmaint.pl?action=query&updatetable=responsiblemanager&pagetitle=Managers$idstr&schema=$SCHEMA&mgrtype=1\">BSC Responsible Managers</a></li>\n";
        print "<li><a href=\"$ONCSCGIDir/manmaint.pl?action=query&updatetable=responsiblemanager&pagetitle=Managers$idstr&schema=$SCHEMA&mgrtype=2\">DOE Responsible Managers</a></li>\n";
	print "<li><a href=\"$ONCSCGIDir/enotify.pl?schema=$SCHEMA&pagetitle='E-mail Notification'$idstr\">E-mail Notification</a></li>\n";
    }
    print "</ul></td><td>&nbsp&nbsp&nbsp&nbsp</td>\n";
    if ($sysadmin) {
	print "<td valign=top><ul title=\"Updates and Entries\">\n";
	print "<lh><b>Updates and Entries</b>\n";
	print "<li><a href=$ONCSCGIDir/issueupdate.pl?loginusersid=$usersid&loginusername=$username>Update Issue</a>\n";
	print "<li><a href=$ONCSCGIDir/newsource.pl?loginusersid=$usersid&loginusername=$username>Enter New Source Document</a>\n";
	print "<li><a href=$ONCSCGIDir/sourceupdate.pl?loginusersid=$usersid&loginusername=$username>Update Source Document</a>\n";
	print "<li><a href=$ONCSCGIDir/commitmentupdate.pl?loginusersid=$usersid&loginusername=$username>Update Commitment</a>\n";
        print "<li><a href=\"$ONCSCGIDir/DOECMgr_enterresponse.pl?loginusersid=$usersid&loginusername=$username\">Enter Response to Commitment</a></li>\n";
	print "<li><a href=$ONCSCGIDir/responseupdate.pl?loginusersid=$usersid&loginusername=$username>Update Response to Commitment</a>\n";
	print "<li><a href=\"$ONCSCGIDir/historicaladd.pl?loginusersid=$usersid&loginusername=$username\">Add Associated Historical Commitments</a></li>\n";
	print "<li><a href=\"$ONCSCGIDir/actionupdate.pl?loginusersid=$usersid&loginusername=$username\">Update Actions</a></li>\n";
#	print "<li><a href=\"$ONCSCGIDir/DOECMgr_changeduedate.pl?loginusersid=$usersid&loginusername=$username\">Change Commitment Due Dates</a></li>\n";
	print "</ul>\n";
    }
    print "</td>\n";
} 
elsif ($command eq "changeuser") {
    print "<table border=0 align=center><tr><td align=center>Select User to Become</td></tr>\n";
    
    tie my %userlist, "Tie::IxHash";
    print "<tr><td align=center>\n";
    %userlist = get_lookup_values($dbh,'users', 'usersid', "lastname || ', ' || firstname", "(1=1) ORDER BY username");
    print build_drop_box('newuserid', \%userlist, 0);
    print "</td></tr><tr><td align=center>\n";
    print "<input type=hidden name=command value=changeuser2>\n";
    print "</td></tr><tr><td align=center>\n";
    print "<input type=submit name=submitcu value=Submit>\n";
    print "</td></tr></table>\n";
} 
elsif ($command eq "changeuser2") {
    my $newusersid = $oncscgi->param('newuserid');
    my $newusername = get_value($dbh,$SCHEMA, 'users', 'username', "usersid=$newusersid");
    
    print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    print "<!--\n";
    print "    parent.header.oncs_page_header.loginusersid.value = $newusersid;\n";
    print "    parent.header.oncs_page_header.loginusername.value = '$newusername';\n";
    print "    parent.header.oncs_page_header.oldusersid.value = $usersid;\n";
    print "    parent.titlebar.location = '$ONCSCGIDir/title_bar.pl?loginusername=$newusername&loginusersid=$newusersid&schema=$SCHEMA';\n";
    print "    parent.workspace.location = '$ONCSCGIDir/home.pl?loginusername=$newusername&loginusersid=$newusersid&schema=$SCHEMA';\n";
    print "//-->\n";
    print "</script>\n";
}

print <<maintmenuend;
</tr></table>
</form>
</body>
</html>
maintmenuend

&oncs_disconnect($dbh);
