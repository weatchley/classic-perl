#!/usr/local/bin/newperl -w
#
# $Source $
#
# $Revision: 1.7 $
#
# $Date: 2002/10/23 22:10:19 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: trend_users.pl,v $
# Revision 1.7  2002/10/23 22:10:19  starkeyj
# modified to use 'use strict' pragma
#
# Revision 1.6  2002/04/08 21:14:49  starkeyj
# modified to make user login smoother
#
# Revision 1.5  2002/03/28 22:38:23  starkeyj
# modified for SCR 23 and 27 so administrator can enter, remove, and assign roles to trend users
#
# Revision 1.4  2001/11/20 14:46:35  starkeyj
# modified to change heder layout
#
# Revision 1.3  2001/07/25 20:01:14  starkeyj
# Modified javascript because of a typing error - mispelled isBlank function
#
# Revision 1.2  2001/07/09 14:26:44  starkeyj
# Updated to show title
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
#my $command = ((defined($DDTcgi->param('command'))) ? (($DDTcgi->param('command') gt " ") ? $DDTcgi->param('command') : "menu") : "menu");
my $cgiaction = defined($DDTcgi->param("cgiaction")) ? $DDTcgi->param("cgiaction") : "login";
my $password = defined($DDTcgi->param("password")) ? $DDTcgi->param("password") : "None";
my $idstr = "&username=$username&userid=$userid";
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
#my $form = "trend_users";
my $success = 0;
my $title = "Change Password";

print <<END_of_Multiline_Text;
Content-type: text/html

<HTML>
<HEAD>
<script src=$NQSJavaScriptPath/utilities.js></script>
<Title>Data Deficiency Tracking</Title>
<script language=javascript><!--
function verify_form (f) {
// javascript form verification routine
	var msg = "";
	if (f.cgiaction.value == 'password_db_change') {
		if (isBlank(f.oldpassword.value) || isBlank(f.newpassword.value) || isBlank(f.newpassword2.value)) {
			msg += "All form fields must be entered.\\n";
		}
		if (f.newpassword.value != f.newpassword2.value) {
			msg += "New password entries do not match.\\n";
		}
		if (f.oldpassword.value == f.newpassword.value) {
			msg += "Old password and New password can not be the same.\\n";
		}
		if (f.DefPassword.value.toUpperCase() == f.newpassword.value.toUpperCase()) {
			msg += "New password cannot be the default password.\\n";
		}
  } 
  if (msg != "") {
		alert (msg);
		return false;
	}
	return true;
}
function show_menu() {
	document.$form.cgiaction.value = 'menu';
	document.$form.target = 'workspace';
	document.$form.action = '$path' + 'trend_home.pl';
	document.$form.submit();
}
function goto_trend_docs() {
	document.$form.cgiaction.value = 'query';
	document.$form.target = 'workspace';
	document.$form.action = '$path' + 'trend_documents.pl';
	document.$form.submit();
}
function goto_login() {
	document.$form.cgiaction.value = 'login';
	document.$form.target = 'workspace';
	document.$form.action = '$path' + 'trend_login.pl';
	document.$form.submit();
}
function add_new() {
	//document.$form.cgiaction.value = 'add_user';
	document.$form.target = 'workspace';
	document.$form.action = '$path' + 'trend_users.pl';
	document.$form.submit();
}
function add_new_db() {
	var msg = "";
 	if (document.$form.lastname.value == null || document.$form.lastname.value == "" || isBlank(document.$form.lastname.value)) {
		msg += "- You must enter a Last Name \\n";
 	}
 	if (document.$form.firstname.value == null || document.$form.firstname.value == "" || isBlank(document.$form.firstname.value)) {
		 msg += "- You must enter a First Name.\\n";
 	}

  	if (msg != "") {
    alert (msg);
  	}
  	else {  
	document.$form.cgiaction.value = 'add_user_db';
	document.$form.target = 'control';
	document.$form.action = '$path' + 'trend_users.pl';
	document.$form.submit();
	}
}
function toUpper(element,s) {     	
   	s = s.toUpperCase();
   	element.value = s;
}
//-->
</script>
</HEAD>
<form name=trend_users onSubmit="return verify_form(this);" method=post>
<Body bgcolor=#FFFFEO text=#000099>
<center>
<input name=schema type=hidden value=$schema>
<input name=username type=hidden value=$username>
<input name=userid type=hidden value=$userid>
<hr width=80%><br>
END_of_Multiline_Text
#print "<table border=0 cellspacing=0 cellpadding=0 width=750 align=center>\n";
#print "<tr><td align=center colspan=3><hr></td></tr>\n";
#print "<tr>\n";
#print "<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=1><tr><td align=center><font size=2 color=black>User:&nbsp;$username</font></td></tr></table></td>\n";
#print "<td align=center valign=center width=60%><font size=+1><B>$title</B></td>\n";
#print "<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=1><tr><td align=center><font size=2 color=black>DB:&nbsp;QA</font></td></tr></table></td>\n";
#print "</tr>\n";
#print "<tr><td align=center colspan=3><hr></td></tr>\n";
#print "</table>\n";
my ($sqlquery,$csr,@values,$urllocation);
if ($cgiaction eq "change_password") {
	print "<script language=javascript><!--\n";
	print "document.$form.target = 'control';\n";
	print "//--></script>\n";
	print "<center>\n";
	print "\n";
	print "<font size=+1><b>User Name:</b></font><br><b>$username</b><br><br>\n";
	print "<b>Old Password:</b><br><input type=password name=oldpassword size=15 maxlength=15><br><br>\n";
	print "<b>New Password:</b><br><input type=password name=newpassword size=15 maxlength=15><br><br>\n";
	print "<b>Retype New Password:</b><br><input type=password name=newpassword2 size=15 maxlength=15><br><br>\n";
	print "<input type=hidden name=DefPassword value=$DefPassword>\n";
	print "<input type=submit name=submit value='Change Password'>\n";
	print "</center>\n";
	print "<input type=hidden name=cgiaction value=password_db_change>\n";
}
elsif ($cgiaction eq "password_db_change") {
   # process change password form ----------------------------------------------------------
	my $success = 0;
	my $oldpassword = $DDTcgi->param("oldpassword");
	$oldpassword =~ s/'/''/g;
	my $newpassword = $DDTcgi->param("newpassword");
	$newpassword =~ s/'/''/g;
	my $test_password;
	$oldpassword = &trend_encrypt_password(uc($oldpassword));
	$newpassword = &trend_encrypt_password(uc($newpassword));
 	my $dbh = trend_connect();
   $dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;

	$sqlquery = "select password  from $schema.t_user where upper(username) = upper('$username') and privilege != 'Inactive'";
	eval {
		$csr = $dbh->prepare($sqlquery);
		$csr->execute;
		@values = $csr->fetchrow_array;
		$csr->finish;
	};
	# check for error, should never occur
	if ($#values < 0 || $@) {
		print STDERR "~~1.  $@ ~~\n";
		&log_trend_error($dbh, $schema, 'T', $userid, "Error getting old password from DB.");
	} 
	else {
		($test_password) = @values;
		if ($test_password ne $oldpassword) {
			 &log_trend_error($dbh, $schema, 'F', $userid, "Incorrect old password, try again");
		} 
		else {
			 # change the password
			 $sqlquery = "update $schema.t_user set password = '$newpassword' where upper(username) = upper('$username')";
			 eval {
				  $csr = $dbh->prepare($sqlquery);
				  $csr->execute;
				  $csr->finish;
			 };
			 if ($@) {
				  &log_trend_error($dbh, $schema, 'T', $userid,  "Error changing password.");
				  print STDERR "\n~~ $sqlquery ~~\n";
			 }
			 else {
				# verify that the password changed
				$sqlquery = "select password  from $schema.t_user where upper(username) = upper('$username')";
				eval {
						$csr = $dbh->prepare($sqlquery);
						$csr->execute;
						@values = $csr->fetchrow_array;
						$csr->finish;
				};
			 }
			 if (($#values < 0) || ($newpassword ne $values[0]) || $@) {
			 	print STDERR "~~2. $@ ~~\n";
				  $dbh->rollback;
				  &log_trend_error($dbh, $schema, 'T', $userid, "Error verifying password change");
			 } else {
				  $dbh->commit;
				  &log_trend_activity ($dbh, $schema, 'F', $userid,"user $username password changed");
				  $urllocation = $path . "utilities.pl?username=$username&userid=$userid&schema=$schema";
				  $success = 1;

			}
		}
	}
	&trend_disconnect($dbh);
	if ($success) {
		print "<input type=hidden name=cgiaction value=menu>\n";
		print "<script language=javascript><!--\n";
		print "alert (\"The password was changed successfully.\");\n";
		print "goto_trend_docs();\n";
	}
	else {
		print "<script language=javascript><!--\n";
		print "alert (\"Error changing password. The password has not been changed.\");\n";
		#print "goto_login();\n";
	}
	print "//--></script>\n";
}
elsif ($cgiaction eq "reset_password") {
	print "<center>\n";
	print "\n";
	print "<font size=+1><b>User Name:</b><br><input type=username name=resetname size=15 maxlength=15><br><br>\n";
	print "<input type=submit name=submit value='Reset Password'>\n";
	print "</center>\n";
	print "<input type=hidden name=cgiaction value=password_db_reset>\n";
}
elsif ($cgiaction eq "password_db_reset") {
	my $resetname = $DDTcgi->param("resetname");
   my $resetPassword = &trend_encrypt_password(uc($DefPassword));
 	my $dbh = trend_connect();
 	
   $dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
        
	# change the password
	$sqlquery = "update $schema.t_user set password = '$resetPassword' where upper(username) = upper('$resetname')";
	eval {
	    $csr = $dbh->prepare($sqlquery);
	    $csr->execute;
	    $csr->finish;
	};
	if ($@) {
	    &log_trend_error($dbh, $schema, 'T', $userid, "Error resetting password for $username");
	}
	else {
		# verify that the password changed
		$sqlquery = "select password  from $schema.t_user where upper(username) = upper('$resetname')";
		eval {
	    		$csr = $dbh->prepare($sqlquery);
	    		$csr->execute;
	    		@values = $csr->fetchrow_array;
	    		$csr->finish;
		};
		if (($#values < 0) || ($resetPassword ne $values[0]) || $@) {
	    		$dbh->rollback;
	    		&log_trend_error($dbh, $schema, 'T', $userid,  "Error verifying password change.");
		} 
		else {
	    		$dbh->commit;
	    		&log_trend_activity($dbh, $schema, 'F', 0,"user $username reset password for $resetname");
	    		#$urllocation = $path . "utilities.pl?username=$username&userid=$userid&schema=$schema";
	    		$success = 1;
		}      
	}
	&trend_disconnect($dbh);
	print "<input type=hidden name=cgiaction value=menu>\n";
	print "<script language=javascript><!--\n";
	if ($success) {print "alert (\"The password has been reset to the default password.\");\n";}
	else {print "alert (\"Error resetting password. The password has not been reset to the default password.\");\n";}
	print "show_menu();\n";
	print "//--></script>\n";
}
elsif ($cgiaction eq "user_query") {
	my ($id,$username1,$lastname,$firstname,$priv);
	my $i = 1;
	my $dbh = trend_connect();
	my $sqlquery = "select id, username, firstname, lastname, privilege from ";
	$sqlquery .= "$schema.t_user order by lastname ";


	print "<br><table width=650 border=1 cellspacing=1 cellpadding=1>\n";
	print "<tr bgcolor=#dcdcdc><td><b>Username</b></td><td><b>User</b></td><td colspan=2><b>Privilege</b></td></tr>\n";

	my $csr = $dbh->prepare($sqlquery);
	$csr->execute;
	while (@values = $csr->fetchrow_array) {
		$id = defined($values[0]) ? $values[0] : 0;
		$username1 = defined($values[1]) ? $values[1] : '&nbsp;';
		$firstname = defined($values[2]) ? $values[2] : '&nbsp;';
		$lastname = defined($values[3]) ? $values[3] : '&nbsp;';
		$priv = defined($values[4]) ? $values[4] : 'none';
		print "<tr><td>$username1</td><td>$firstname $lastname</td><td>$priv</td><td><a href=\"$NQSCGIDir/trend_users.pl?cgiaction=modify_user&schema=$schema&id=$id&username=$username&userid=$userid\">Edit</a></td><tr>\n";
	}
	$csr->finish;
	&trend_disconnect($dbh);
	print "</table><br><br><br>\n";
	print "<input name=add type=button value=\"Add New User\" onclick=add_new()>\n";
	print "<input type=hidden name=cgiaction value=add_user>\n";
}   
elsif ($cgiaction eq "modify_user") {
	my $id = $DDTcgi->param("id");
	my $dbh = trend_connect();
	my $sqlquery = "select id, username, firstname, lastname, privilege from ";
	$sqlquery .= "$schema.t_user where id = $id ";

	my $csr = $dbh->prepare($sqlquery);
	$csr->execute;
	my @values = $csr->fetchrow_array;
	$csr->finish;

	$id = defined($values[0]) ? $values[0] : 0;
	my $username1 = defined($values[1]) ? $values[1] : '&nbsp;';
	my $firstname = defined($values[2]) ? $values[2] : '&nbsp;';
	my $lastname = defined($values[3]) ? $values[3] : '&nbsp;';
	my $priv = defined($values[4]) ? $values[4] : 'User';

	print "<br><br><br><table align=center width=600 border=0>\n";
	print "<tr><td width=35% align=left><b><li>User ID:</b></td><td width=65% align=left><b>$id</b></td></tr>\n";
	print "<tr><td align=left><b><li>User Name:</b></td><td align=left><b>$username1</b></td></tr>\n";
	print "<tr><td align=left><b><li>First Name:</b></td><td align=left><input name=firstname type=text maxlength=30 size=35 value=$firstname></td></tr>\n";
	print "<tr><td align=left><b><li>Last Name:</b></td><td align=left><input name=lastname type=text maxlength=30 size=35 value=$lastname></td></tr>\n";
	print "<tr><td align=left><b><li>Privilege:</b></td><td align=left><input type=radio name=priv value=Administrator ";

	if ($priv eq 'Administrator' ) {print " checked ";}
	print ">&nbsp;<b>Administrator</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=priv value=User ";
	if ($priv eq 'User' ) {print " checked ";}
	print ">&nbsp;<b>User</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=priv value=Inactive ";
	if ($priv eq 'Inactive' ) {print " checked ";}
	print ">&nbsp;<b>Inactive</b></td></tr>\n";
	print "</table>\n";
	print "<br><br><br><input type=submit value=Submit>\n";
	print "<input type=hidden name=cgiaction value=modify_user_db>\n";
	print "<input type=hidden name=id value=$id>\n";
	&trend_disconnect($dbh);
} 
elsif ($cgiaction eq "add_user") {
	print "<br><br><br><table align=center width=600 border=0>\n";
	print "<tr><td align=left><b><li>First Name:</b></td><td align=left><input name=firstname type=text maxlength=30 size=35></td></tr>\n";
	print "<tr><td align=left><b><li>Last Name:</b></td><td align=left><input name=lastname type=text maxlength=30 size=35></td></tr>\n";
	print "<tr><td align=left><b><li>Privilege:</b></td><td align=left><input type=radio name=priv value=Administrator>";
	print "&nbsp;<b>Administrator</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=priv value=User checked> ";
	print "&nbsp;<b>User</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=radio name=priv value=Inactive> ";
	print "&nbsp;<b>Inactive</b></td></tr>\n";
	print "</table>\n";
	print "<br><br><br><input type=button value=Submit onClick=add_new_db();>\n";
	print "<input type=hidden name=cgiaction>\n";
}   
###############################
elsif ($cgiaction eq "add_user_db") {
###############################
	print "<input type=hidden name=cgiaction>\n";
	my $lastname = $DDTcgi->param('lastname');
	$lastname =~ s/\'/\'\'/g;
	my $firstname = $DDTcgi->param('firstname');
	$firstname =~ s/\'/\'\'/g;
	my $privilege = $DDTcgi->param('priv');
	my $error = "";
	my ($username1,$nextusersid,$modifyid);
	my $alertstring;
	if (length($lastname) > 7) {$username1 = substr (uc($lastname), 0, 7) . substr(uc($firstname), 0, 1);} 
	else {$username1 = uc($lastname) . substr(uc($firstname), 0, 1);}
	my $dbh = trend_connect();
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	 
	eval { 	
		my $sqlstring = "SELECT id FROM $SCHEMA.t_user WHERE UPPER(lastname) = '" . uc($lastname)
					 . "' AND UPPER(firstname) = '" . uc($firstname) . "'";
		my $rc = $dbh->prepare($sqlstring);
		$rc->execute;
		my $modifyid = $rc->fetchrow_array;
		if (!(defined($modifyid))) {
			my $nextusersid = get_max_id($dbh, 't_user','id') + 1;
			my $password = trend_encrypt_password("password");

			$sqlstring = "INSERT INTO $SCHEMA.t_user
						 (id,lastname,firstname,username,password,privilege) 
						 VALUES ($nextusersid, '$lastname', '$firstname',
						 '$username1', '$password', '$privilege')";
			$rc = $dbh->do($sqlstring);
		}
	};
	if ($@) {
		$dbh->rollback;
		&log_trend_error($dbh,$schema,'T',$userid,"$username Error adding user $firstname $lastname, id $nextusersid.  $@");
		$alertstring = "An error occurred while attempting to add $firstname $lastname to the system."; 
		print "<script language=\"JavaScript\">
		<!--
			alert('$alertstring');
		-->
		</script>"; 
	}
	elsif (!(defined($modifyid))) {
		$dbh->commit;
		&log_trend_activity($dbh,$schema,'F',$userid,"$username added user $firstname $lastname, id $nextusersid");
		$alertstring = "$firstname $lastname has been added to the system."; 
		print "<script language=\"JavaScript\">
		<!--
			alert('$alertstring');
			show_menu();
		-->
		</script>"; 
	}
	&trend_disconnect($dbh);
} ##############  endif add user db ########################
###############################
elsif ($cgiaction eq "modify_user_db") {
###############################
	print "<input type=hidden name=cgiaction>\n";
	my $id = $DDTcgi->param('id');
	my $lastname = $DDTcgi->param('lastname');
	$lastname =~ s/\'/\'\'/g;
	my $firstname = $DDTcgi->param('firstname');
	$firstname =~ s/\'/\'\'/g;
	my $privilege = $DDTcgi->param('priv');
	my $error = "";
	my $alertString;

	my $dbh = trend_connect();
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	 
	eval { 	
		my $sqlstring = "update $SCHEMA.t_user 
	  		set lastname = '$lastname',
	  		firstname = '$firstname',
	  		privilege = '$privilege'
	  		where id = $id ";
		my $rc = $dbh->do($sqlstring);
	};
	if ($@) {
		$dbh->rollback;
		&log_trend_error($dbh,$schema,'T',$userid,"$username Error updating user $firstname $lastname, id $id.  $@");
		$alertString = "An error occurred while attempting to update $firstname $lastname in the system."; 
		print "<script language=\"JavaScript\">
		<!--
			alert('$alertString');
		-->
		</script>"; 
	}
	else {
		$dbh->commit;
		&log_trend_activity($dbh,$schema,'F',$userid,"$username modified user $firstname $lastname, id $id");
		$alertString = "$firstname $lastname has been modified in the system."; 
		print "<script language=\"JavaScript\">
		<!--
			alert('$alertString');
			show_menu();
		-->
		</script>"; 
	}
	&trend_disconnect($dbh);
}
print <<END;
</form>
</center>
</Body>
</HTML>
END

