#!/usr/local/bin/newperl -w
#
#
# $Source $
#
# $Revision: 1.6 $
#
# $Date: 2002/10/23 22:08:00 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: trend_login.pl,v $
# Revision 1.6  2002/10/23 22:08:00  starkeyj
# modified to add 'use strict' pragma
#
# Revision 1.5  2002/04/08 21:17:02  starkeyj
# modified to make user login smotther
#
# Revision 1.4  2002/03/28 22:37:28  starkeyj
# modified for SCR 23 to select user privileges during login
#
# Revision 1.3  2001/11/20 14:46:35  starkeyj
# modified to change heder layout
#
# Revision 1.2  2001/07/09 14:28:09  starkeyj
# updated to show title
#
# 
#
#
use strict;
use NQS_Header qw(:Constants);
use NQS_Utilities_Lib qw(:Functions);
use CGI;
use DBI;

my $DDTcgi = new CGI;
my $username = defined($DDTcgi->param("username")) ? $DDTcgi->param("username") : "GUEST";
my $userid = defined($DDTcgi->param("userid")) ? $DDTcgi->param("userid") : 0;
my $schema = defined($DDTcgi->param("schema")) ? $DDTcgi->param("schema") : "NQS";
my $Server = defined($DDTcgi->param("server")) ? $DDTcgi->param("server") : $NQSServer;
my $command = ((defined($DDTcgi->param('command'))) ? (($DDTcgi->param('command') gt " ") ? $DDTcgi->param('command') : "menu") : "menu");
my $cgiaction = defined($DDTcgi->param("cgiaction")) ? $DDTcgi->param("cgiaction") : "login";
my $password = defined($DDTcgi->param("password")) ? $DDTcgi->param("password") : "None";
my $idstr = "&username=$username&userid=$userid";
my $urllocation = '';
my $error;
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

#my $form = $2;
#my $form="trend_login";
my $changePassword = 0;
my $script = "trend_login";


print <<END_of_Multiline_Text;
Content-type: text/html

<HTML>
<HEAD>
<script src=$NQSJavaScriptPath/utilities.js></script>
<Title>Data Deficiency Tracking</Title>
</HEAD>
<script language="JavaScript1.1"><!--
function submitForm (script, command) {
    document.trend_home.cgiaction.value = command;
    document.trend_home.action = '$path' + script + '.pl';
    document.$form.submit();
}
function show_menu() {
	document.$form.cgiaction.value = 'menu';
	document.$form.action = '$path' + 'trend_home.pl';
	document.$form.submit();
}
function goto_trend_docs() {
	document.$form.cgiaction.value = 'query';
	document.$form.target = 'workspace';
	document.$form.action = '$path' + 'trend_documents.pl';
	document.$form.submit();
}
function refresh_title() {
	document.$form.username.value = 'scott';
	document.$form.target='titlebar';
	document.$form.action = '$path' + 'title_bar.pl';
	document.$form.submit();
}
function verify_form(f) {
	var msg = "";
 	if (f.username.value == null || f.username.value == "" || isBlank(f.username.value)) {
		msg += "- You must enter a User Name \\n";
 	}
 	if (f.password.value == null || f.password.value == "" || isBlank(f.password.value)) {
		 msg += "- Password field cannot be blank.\\n";
 	}
  	if (msg != "") {
    alert (msg);
    return false;
  	}
  	return true;
}
function change_pwd(reason) {
	var msg = "";
 	if (document.$form.username.value == null || document.$form.username.value == "" || isBlank(document.$form.username.value)) {
		msg += "- You must enter a User Name \\n";
 	}
 	if (document.$form.password.value == null || document.$form.password.value == "" || isBlank(document.$form.password.value)) {
		 msg += "- Password field cannot be blank.\\n";
 	}
  	if (msg != "") {alert (msg);}
  	else {
  	   if (reason == 'default') {alert ("You  must change your password from the default password");}
		document.$form.cgiaction.value = 'change_password';
		document.$form.target = 'workspace';
		document.$form.action = '$path' + 'trend_users.pl';
		document.$form.submit();
	}
}
function change_pwd2() {
		document.$form.cgiaction.value = 'change_password';
		document.$form.submit();
}
function toUpper(element,s) {     	
   	s = s.toUpperCase();
   	element.value = s;
}
//-->
</script>
<script type="text/javascript">
<!--
var dosubmit = true;
if (parent == self) {    // not in frames
	location = '$NQSCGIDir/trend_frame.pl'
}
//-->
</script>
<body bgcolor=#FFFFEO text=#000099>
<center>
<form name=$form method=post onSubmit="return verify_form(this);" target=control>
END_of_Multiline_Text
print "<hr width=80%><br><br>\n";
#<table border=0 cellspacing=0 cellpadding=0 width=650 align=center>
#<tr><td align=center colspan=3><hr></td></tr>
#<tr>
#<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=1><tr><td align=center><font size=2 color=black>User:&nbsp;$username</font></td></tr></table></td>
#<td align=center valign=center width=60%><font size=+1><B>Login</B></font></td>
#<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=1><tr><td align=center><font size=2 color=black>DB:&nbsp;QA</font></td></tr></table></td>
#</tr>
#<tr><td align=center colspan=3><hr></td></tr>
#</table>

if ($cgiaction eq "login") {
	print "<table border=0 cellpadding=6 cellspacing=3><tr><td><font size=4>Username:</font></td><td><input type=text name=username size=14 maxlength=8 onBlur=toUpper(this,value)></td></tr>\n";
	print "<tr><td><font size=4>Password:</font></td><td><input type=password name=password size=14 maxlength=15></td></tr>\n";
	print "<tr><td align=center colspan=2><input type=submit value=Login>\n";
	print "<br><br><input type=button  onClick=change_pwd2(); value=\"Change Password & Login \"></tr></table>\n";
	print "<input type=hidden name=cgiaction value=login_action>\n";
}
elsif ($cgiaction eq "login_action") {
	my $dbh = trend_connect();
	eval {
		my $status = &validate_trend_user($dbh, $schema, $username, $password);
		if ($status != 1) {
			print "<script language=javascript><!--\n";
			print "   alert(\"Invalid username and password or account is inactive\");\n";
			print "$form.submit();\n";
			print "//--></script>\n";
		} 
		else {
			$userid = &get_userid($dbh,$username);
	    	if (trend_encrypt_password($password) ne trend_encrypt_password($DefPassword)) {
				$urllocation = $path . "trend_home.pl?username=$username&userid=$userid&schema=$schema";
	    	} 
	    	else { # must change password from default password
				$urllocation = $path . "trend_home.pl?command=change_passwordform&username=$username&userid=$userid&schema=$schema&passwordflag=T";
				$changePassword = 1;
			}
      }
	};
	if ((!($error)) && ($userid != 0) && (!($@))) {
		&log_trend_activity ($dbh, $schema, 'F', $userid, "user $username logged in");
		print "<input type=hidden name=username value=$username>\n";
		print "<input type=hidden name=userid value=$userid>\n";
		print "<input type=hidden name=schema value=$schema>\n";
		print "<input type=hidden name=password value=password>\n";
		print "<input type=hidden name=cgiaction>\n";
		print "<script language=javascript><!--\n";
		if ($changePassword == 0) { print "  goto_trend_docs();\n"; }
		else { print "  change_pwd('default');\n"; }
		print "//--></script>\n";
	}
	else {
		&log_trend_error($dbh, $schema, 'T', 0, "Error processing login for $username");
		print "$form.submit();\n";
		print "//--></script>\n";
	}
	&trend_disconnect($dbh);
}
elsif ($cgiaction eq "change_password") {
	my $dbh = trend_connect();
	eval {
		my $status = &validate_trend_user($dbh, $schema, $username, $password);
		if ($status != 1) {
			print "<script language=javascript><!--\n";
			print "   alert(\"Invalid username and password or account is inactive\");\n";
			print "$form.submit();\n";
			print "//--></script>\n";
		} 
		else {
			$userid = &get_userid($dbh,$username);
			$urllocation = $path . "trend_home.pl?command=change_passwordform&username=$username&userid=$userid&schema=$schema&passwordflag=T";
			$changePassword = 1;
      }
	};
	if ((!($error)) && ($userid != 0) && (!($@))) {
		&log_trend_activity ($dbh, $schema, 'F', $userid, "user $username logged in");
		print "<input type=hidden name=username value=$username>\n";
		print "<input type=hidden name=userid value=$userid>\n";
		print "<input type=hidden name=schema value=$schema>\n";
		print "<input type=hidden name=password value=password>\n";
		print "<input type=hidden name=cgiaction>\n";
		print "<script language=javascript><!--\n";
		if ($changePassword == 0) { print "  goto_trend_docs();\n"; }
		else { print "  change_pwd('userchange');\n"; }
		print "//--></script>\n";
	}
	else {
		&log_trend_error($dbh, $schema, 'T', 0, "Error processing login for $username");
		print "$form.submit();\n";
		print "//--></script>\n";
	}
	&trend_disconnect($dbh);
}
print <<END;
</form>
</center>
</Body>
</HTML>
END


