#!/usr/local/bin/newperl
#
# $Source $
#
# $Revision: 1.7 $
#
# $Date: 2002/10/23 22:07:35 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: trend_home.pl,v $
# Revision 1.7  2002/10/23 22:07:35  starkeyj
# modified to add 'use strict' pragma
#
# Revision 1.6  2002/04/08 21:14:08  starkeyj
# modified for check of user privileges (took out hard coded values)
#
# Revision 1.5  2002/03/28 22:35:28  starkeyj
# modified for SCR 26 and 27, added a link to the functions to add and browse SCR's and administer user privs
#
# Revision 1.4  2001/11/20 14:46:35  starkeyj
# modified to change heder layout
#
# Revision 1.3  2001/07/09 14:28:27  starkeyj
# updated to show title
#
# Revision 1.2  2001/07/06 23:04:03  starkeyj
# Initial revision of Trend Analysis of Trend Analysis home page
#
#
use strict;
use NQS_Header qw(:Constants);
use NQS_Utilities_Lib qw(:Functions);
use CGI;

my $DDTcgi = new CGI;
my $username = defined($DDTcgi->param("username")) ? $DDTcgi->param("username") : "GUEST";
my $userid = defined($DDTcgi->param("userid")) ? $DDTcgi->param("userid") : "None";
my $schema = defined($DDTcgi->param("schema")) ? $DDTcgi->param("schema") : "NQS";
my $Server = defined($DDTcgi->param("server")) ? $DDTcgi->param("server") : $NQSServer;
my $command = ((defined($DDTcgi->param('command'))) ? (($DDTcgi->param('command') gt " ") ? $DDTcgi->param('command') : "menu") : "menu");
my $cgiaction = defined($DDTcgi->param("cgiaction")) ? $DDTcgi->param("cgiaction") : "menu";
my $idstr = "&username=$username&userid=$userid";
my $dbh = trend_connect();
my $userpriv = get_userpriv($dbh, $username);

print <<END_of_Multiline_Text;
Content-type: text/html

<HTML>
<HEAD>
<script src=$NQSJavaScriptPath/utilities.js></script>
<Title> Trend Analysis </Title>
</HEAD>
<Body bgcolor=#FFFFEO text=#000099>
<center>
<form name="trend_home" method=post>
<input type=hidden name=username value=$username>
<input type=hidden name=userid value=$userid>
<input type=hidden name=schema value=$schema>
<input type=hidden name=id value=0>
<script type="text/javascript">
<!--
var dosubmit = true;
if (parent == self) {    // not in frames
	location = '$NQSCGIDir/trend_frame.pl'
}
//-->
</script>
END_of_Multiline_Text
print "<hr width=80%><br>\n";
#print "<table border=0 cellspacing=0 cellpadding=0 width=650 align=center>\n";
#print "<tr><td align=center colspan=3><hr></td></tr>\n";
#print "<tr>\n";
#print "<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=1><tr><td align=center><font size=2 color=black>User:&nbsp;$username</font></td></tr></table></td>\n";
#print "<td align=center valign=center width=60%><font size=+1><B>Home</B></td>\n";
#print "<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=1><tr><td align=center><font size=2 color=black>DB:&nbsp;QA</font></td></tr></table></td>\n";
#print "</tr>\n";
#print "<tr><td align=center colspan=3><hr></td></tr>\n";
#print "</table>\n";
if ($cgiaction eq "menu") {
	print <<END_of_Menu;
	<table border=0 align=center>
	
	 <tr><td valign=top><ul><lh><b>Trend Analysis </b>
		<li><a href="$NQSCGIDir/trend_documents.pl?$idstr&schema=$SCHEMA">Edit Document Information</a></li>
		</ul>
	  </td></tr>

	  <tr><td valign=top><ul><lh><b>System Maintenance</b>
		<li><a href="$NQSCGIDir/cause_code_maint.pl?action=query&updatetable=t_cause&pagetitle=Cause_Code_Maintenance$idstr&schema=$SCHEMA">Cause Codes</a></li>
		<li><a href="$NQSCGIDir/cause_code_maint.pl?action=query&updatetable=t_cause_group&pagetitle=Cause_Code_Group_Maintenance$idstr&schema=$SCHEMA">Cause Code Groups</a></li>
		<li><a href="$NQSCGIDir/element_maint.pl?action=query&updatetable=qa_element&pagetitle=QA_Element_Maintenance$idstr&schema=$SCHEMA">Elements</a></li>
		<li><a href="$NQSCGIDir/element_maint.pl?action=query&updatetable=t_code&pagetitle=Trend_Code_Maintenance$idstr&schema=$SCHEMA">Trend Codes</a></li>
		</ul>
	  </td></tr>
	  <tr><td valign=top><ul><lh><b>User Functions</b>
		<li><a href="$NQSCGIDir/trend_users.pl?cgiaction=change_password&updatetable=users&pagetitle=trend_home$idstr&schema=$SCHEMA">Change Password</a></li>
		</ul>
	  </td></tr>
END_of_Menu
	if ($userpriv eq 'Administrator' ) { 
		print <<END_of_Menu2;
		<td valign=top><ul><lh><b>User Maintenance</b>
			<li><a href="$NQSCGIDir/trend_users.pl?cgiaction=reset_password&updatetable=t_user&pagetitle=Users$idstr&schema=$SCHEMA">Reset Password</a></li>
			<li><a href="$NQSCGIDir/trend_users.pl?cgiaction=user_query&updatetable=t_user&pagetitle=Users$idstr&schema=$SCHEMA">User Privileges</a></li>
			</ul>
		</td></tr><tr>

END_of_Menu2
	}
	#to be modified when SCCB users are more functional
	if ($userpriv eq 'Administrator' ) {
		print "<br><td valign=top><ul><lh><b>Software Change Requests</b>\n";
		print "<li><a href=\"$NQSCGIDir/scrhome.pl?$idstr&schema=$schema&app=Trend\">Software Change Request</a></li>\n";
		print "<li><a href=\"$NQSCGIDir/scrbrowse.pl?$idstr&schema=$schema&app=Trend\">Browse Software Change Requests</a></li>\n";
		print "</ul>";
	}
	print "</tr>\n";
	print "</table>\n";
}
&trend_disconnect($dbh);
print <<END;
</form>
</center>
</Body>
</HTML>
END

