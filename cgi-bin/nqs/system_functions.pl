#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/qa/perl/RCS/system_functions.pl,v $
#
# $Revision: 1.5 $
#
# $Date: 2004/05/30 22:53:31 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: system_functions.pl,v $
# Revision 1.5  2004/05/30 22:53:31  starkeyj
# added doTestPassword and passwordGuidelines and modified all to incorporate the new security requirements
#
# Revision 1.3  2001/11/05 16:26:57  starkeyj
# changed background image path
#
# Revision 1.2  2001/11/02 22:49:13  starkeyj
# cosmetic changes - added spaces to top of form
#
# Revision 1.1  2001/10/19 23:32:19  starkeyj
# Initial revision
#
#
# Revision: $
#
# 

use OQA_specific qw(:Functions);
use NQS_Header qw(:Constants);
use OQA_Utilities_Lib qw(:Functions);
use OQA_Widgets qw(:Functions);
use DBPassword qw(:Functions); 

use DBI;
use DBD::Oracle qw(:ora_types);
use strict;
#use UI_Widgets qw(:Functions);
use CGI;
use Time::localtime;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $NQScgi = new CGI;
my $username = defined($NQScgi->param("username")) ? $NQScgi->param("username") : "GUEST";
my $userid = defined($NQScgi->param("userid")) ? $NQScgi->param("userid") : "None";
my $schema = defined($NQScgi->param("schema")) ? $NQScgi->param("schema") : "None";
my $cgiaction = defined($NQScgi->param("cgiaction")) ? $NQScgi->param("cgiaction") : "change_password";
#$cgiaction = '' ? 'wxyz' : $cgiaction;
my $Server = defined($NQScgi->param("server")) ? $NQScgi->param("server") : $NQSServer;
my $pagetitle = $NQScgi->param('pagetitle');
my $success = 0;
my $sqlquery;
my $csr;
my @values;
my @uservalues;
my $message;
my $dbh = &NQS_connect();
my $userQuery = $dbh->prepare("select u.id, u.username, u.lastname, u.firstname, u.location, u.organization from $schema.users u, $schema.user_privilege p where p.privilege = ? and u.id >= ? and u.id <= ? and u.id = p.userid and u.isactive = 'T' order by u.lastname, u.firstname");
sub writeUserTable {
   my %args = (
      privilege => 1,
      startID => 1,
      endID => 1000,
      titleBackground => '#cdecff',
      titleForeground => '#000099',
      align => 'center',
      @_,
   );
   &start_table(4, $args{align}, 140, 100, 120, 240);  # output discarded
   my $output = "<table width=600 cellpadding=4 cellspacing=0 border=1 align=$args{align}>";
   $output .= "<a name='$args{title}'></a>\n";
   $output .= &title_row($args{titleBackground}, $args{titleForeground}, $args{title});
   $output .= &add_header_row();
   $output .= &add_col() . "Name" . &add_col() . "Username" . &add_col() . "Location" . &add_col() . "Organization";
   $userQuery->bind_param(1, $args{privilege});
   $userQuery->bind_param(2, $args{startID});
   $userQuery->bind_param(3, $args{endID});
   $userQuery->execute;
   while (my @values = $userQuery->fetchrow_array) {
      my ($id, $username, $lastname, $firstname, $location, $organization) = @values;
      $output .= &add_row();
      $output .= &add_col_link("javascript:DisplayUser($id)") . &get_fullname($dbh, $schema, $id);
      $output .= &add_col() . $username . &add_col() . $location . &add_col() . $organization;
   }
   $userQuery->finish;
   $output .= &end_table() . "<br><b><a href=#top>Back to Top</a></b><br><br>\n";
   return ($output);
}
###################################################################################################################################
sub doTestPassword {  # routine to test if a password follows the rules
###################################################################################################################################
    my %args = (
        password => '',
        username => "dummytestusernamenotlikelytoeverbeused",
        minLength => 8,
        @_,
    );
    my $acceptable = "T";
    my @commonStrings = ("1234","abcd","qwert","asdfg","zxcvb","poiuy","lkjh","password");
    my $tempPassword;
    if (length($args{password}) < $args{minLength}) {$acceptable = 'F';} # must be minLength or longer
    if (index(uc($args{password}), uc($args{username})) >=0) {$acceptable = 'F';} # cannot include username
    if (index(uc($args{password}), uc(reverse($args{username}))) >=0) {$acceptable = 'F';} # cannot include reverse of username
    foreach my $val (@commonStrings) {
        if (index(uc($args{password}), uc($val)) >=0) {$acceptable = 'F';} # cannot include a common string
        if (index(uc($args{password}), uc(reverse($val))) >=0) {$acceptable = 'F';} # cannot include reverse of common string
    }
    if ($args{password} =~ /^\d|\d$/) {$acceptable = 'F';} # cannot start or end with a digit
    my $passCount = 0;
    # simple password rules
    if ($args{password} =~ /\d/) {$passCount++;} # does the password contain a digit
    if ($args{password} =~ /[A-Z]/) {$passCount++;} # does the password contain an upper case letter
    if ($args{password} =~ /[a-z]/) {$passCount++;} # does the password contain a lower case letter
    if ($args{password} =~ /\W/) {$passCount++;} # does the password contain a non alphanumeric character
    if ($passCount < 3) {$acceptable = 'F';} # must pass at least 3 of the simple password rules
    
    return($acceptable);
}
print <<END_of_Multiline_Text;
Content-type: text/html

<HTML>
<HEAD>
<!-- include external javascript code -->
<script src="$NQSJavaScriptPath/utilities.js"></script>

    <script type="text/javascript">
    <!--

    var dosubmit = true;
    if (parent == self) {    // not in frames
	location = '$NQSCGIDir/login.pl'
    }

    //-->
    </script>

  <script language="JavaScript" type="text/javascript">
  <!--
      doSetTextImageLabel('Password Maintenance');
  //-->
</script>
<script language="JavaScript1.1">
  <!--

function verify_form (f){
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
  document.$form.target = 'control';
  return true;
}
function submitForm (script, command, id) {
	 document.$form.cgiaction.value = command;
	 document.$form.target = 'workspace';
	 document.$form.action = '$path' + script + '.pl';
	 document.$form.submit();
}

function toUpper(element,s) {     	
   	s = s.toUpperCase();
   	element.value = s;
}

//-->
</script>


</HEAD>


<form name=$form onSubmit="return verify_form(this);" method=post>
<Body background=$NQSImagePath/background.gif text=#000099>
<center>
<input name=schema type=hidden value=$schema>
<input name=username type=hidden value=$username>
<input name=userid type=hidden value=$userid>

END_of_Multiline_Text
if ($cgiaction eq "change_password") {
      my $passwordGuidelines = "<b><ul>Password Guidelines<br>";
      $passwordGuidelines .= "<li>- 8 or more characters</li>";
      $passwordGuidelines .= "<li>- can not contain form of username (forward or reverse)</li>";
      $passwordGuidelines .= "<li>- can not use some common strings</li>";
      $passwordGuidelines .= "<li>- can not start or end with a digit</li>";
      $passwordGuidelines .= "<li>- must have three of the following four:<ul>";
      $passwordGuidelines .= "<li> - a special character</li>";
      $passwordGuidelines .= "<li> - a digit<br>";
      $passwordGuidelines .= "<li> - an uppercase letter</li>";
      $passwordGuidelines .= "<li> - a lowercase letter</li></ul></li>";
      $passwordGuidelines .= "<li>- can not reuse the last six passwords</li>";
      $passwordGuidelines .= "</ul></b>\n";     
            
      print "<center><br><br>\n";
      print "<table border=0 align=center valign=top width=600><tr><td align=center valign=top width=50%>\n";
      print "<font size=+1><b>User Name:</b></font><br><b>$username</b><br><br>\n";
      print "<b>Old Password:</b><br><input type=password name=oldpassword size=15 maxlength=15><br><br>\n";
      print "<b>New Password:</b><br><input type=password name=newpassword size=15 maxlength=15><br><br>\n";
      print "<b>Retype New Password:</b><br><input type=password name=newpassword2 size=15 maxlength=15><br><br>\n";
      print "<input type=hidden name=DefPassword value=$DefPassword>\n";
      print "<input type=submit name=submit value='Change Password'>\n";
      print "</td><td>&nbsp;</td><td valign=top width=50%>\n";
      print "$passwordGuidelines\n";
      print "</td></tr></table>\n";
      print "</center>\n";

      print "<input type=hidden name=cgiaction value=password_db_change>\n";
}
elsif ($cgiaction eq "password_db_change") {
        # process change password form ---------------------------------------------------------------------------------------------

    my $status = 0;
    my $oldpassword = $NQScgi->param("oldpassword");
    $oldpassword =~ s/'/''/g;
    my $newpassword = $NQScgi->param("newpassword");
    $newpassword =~ s/'/''/g;
    my $test_password;
        
   # $oldpassword = &NQS_encrypt_password(uc($oldpassword));
   # $newpassword = &NQS_encrypt_password(uc($newpassword));
    
#    $dbh->{AutoCommit} = 0;
#    $dbh->{RaiseError} = 1;
    print "<input type=hidden name=cgiaction>\n";    
    my $reusedPassword = &isReusedPassword(dbh => $dbh, schema => $SCHEMA, userID => $userid, password=>$newpassword);
    if (&doTestPassword(password => $newpassword, username => $username) eq 'T' && !$reusedPassword) {
        ($status) = &doProcessChangePassword(dbh => $dbh, schema => $SCHEMA, userID => $userid,oldpassword => $oldpassword,newpassword => $newpassword);
    } else {
        $status=-2;
    }
    
   # my $userName = getUserName(dbh=>$dbh, schema=>$SCHEMA, userID=>$userid);
    if ($status == 1) {
       #&logActivity (dbh => $args{dbh}, schema => $args{schema}, userID => $args{userID}, logMessage => "user $userName password changed", type => 2);
        #$message = "The password for user $userName has been Changed";
        #$output .= doAlertBox(text => "$message");
        print "<script language=javascript><!--\n";
        print "alert(\"The password for user $username has been Changed\");\n";
        print "   submitForm('home',0,0);\n";
        print "//--></script>\n";
    } elsif ($status == -2) {
        print "<script language=javascript><!--\n";
        print "alert(\"Password does not meet security requirements\");\n";
        print "//--></script>\n";
    } else {
        print "<script language=javascript><!--\n";
        print "alert(\"The old password is not correct\");\n";
        print "//--></script>\n";
    }
    &NQS_disconnect($dbh);
}
elsif ($cgiaction eq "reset_password") {
	print "<center>\n";
        print "\n";
        print "<br><br><font size=+1><b>User Name:</b><br><input type=username name=resetname size=15 maxlength=15><br><br>\n";
        print "<input type=submit name=submit value='Reset Password'>\n";
        print "</center>\n";
        print "<input type=hidden name=cgiaction value=password_db_reset>\n";
 }
 elsif ($cgiaction eq "password_db_reset") {
	my $resetname = $NQScgi->param("resetname");
        my $resetPassword = &NQS_encrypt_password(uc($DefPassword));
 	my $dbh = NQS_connect();
 	
        $dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;

        
	# change the password
	$sqlquery = "update $schema.users set password = '$resetPassword' where upper(username) = upper('$resetname')";
	eval {
	    $csr = $dbh->prepare($sqlquery);
	    $csr->execute;
	    $csr->finish;
	};
	if ($@) {
	    #&log_NQS_error($dbh, $schema, 'T', $userid, "Error resetting password for $username");
	}
	else {
		# verify that the password changed
		$sqlquery = "select password  from $schema.users where upper(username) = upper('$resetname')";
		eval {
	    		$csr = $dbh->prepare($sqlquery);
	    		$csr->execute;
	    		@values = $csr->fetchrow_array;
	    		$csr->finish;
		};
	
		if (($#values < 0) || ($resetPassword ne $values[0]) || $@) {
	    		$dbh->rollback;
	    		#&log_NQS_error($dbh, $schema, 'T', $userid,  "Error verifying password change.");
		} else {
	    		$dbh->commit;
	    		#&log_NQS_activity($dbh, $schema, 'F', 0,"user $username reset password for $resetname");
	    		#$urllocation = $path . "utilities.pl?username=$username&userid=$userid&schema=$schema";
	    		$success = 1;
        	}      
       }
      
       print "<input type=hidden name=cgiaction>\n";
       print "<script language=javascript><!--\n";
       if ($success) {print "alert (\"The password has been reset to the default password.\");\n";}
       else {print "alert (\"Error resetting password. The password has not been reset to the default password.\");\n";}
       print "//--></script>\n";
}
elsif ($cgiaction eq "displayuser") {
	  my $displayid = $NQScgi->param("id");
	  $sqlquery = "SELECT id,location,username,firstname,lastname,organization,areacode,phonenumber,extension,email,accesstype FROM $schema.users WHERE id = $displayid ORDER BY id";

	  eval {
			$csr = $dbh->prepare($sqlquery);
			$csr->execute;
			@values = $csr->fetchrow_array;
			$csr->finish;
	  };
	  if ($@) {
			$message = errorMessage($dbh,$username,$userid,$schema,"display user info.",$@);
			$message =~ s/\n/\\n/g;
	  }
	  if (defined(@values) && $#values >=0) {
			my $command = 'displayuserform';
			$uservalues[0][0] = 'User Information';
			$uservalues[1][0] ='<b>User ID:</b>' . &nbspaces(2);
			$uservalues[1][1] ='<b>' . $values[0] . '</b>';
			$uservalues[2][0] ='<b>Username:</b>' . &nbspaces(2);
			$uservalues[2][1] ='<b>' . $values[2] . '</b>';
			$uservalues[3][0] ='<b>Name:</b>' . &nbspaces(2);
			$uservalues[3][1] ="<b>$values[3] $values[4]</b>";
			#$uservalues[4][0] ='<b>Location:</b>' . &nbspaces(2);
			#$uservalues[4][1] ='<b>' . $values[1] . '</b>';
			#$uservalues[5][0] ='<b>Organization:</b>' . &nbspaces(2);
			#$uservalues[5][1] ='<b>' . $values[5] . '</b>';
			$uservalues[6][0] ='<b>Phone Number:</b>' . &nbspaces(2);
			my $ext = (!(defined($values[8])) || $values[8] eq "") ? "" : " ext. $values[8]";
			$uservalues[6][1] ="<b>($values[6]) " . substr($values[7],0,3) . "-" . substr($values[7],3,4) . "$ext</b>";
			$uservalues[7][0] ='<b>Email Address:</b>' . &nbspaces(2);
			$uservalues[7][1] ='<b>' . $values[9] . '</b>';
			$uservalues[9][0] ='<b>Privileges:</b>';
			$uservalues[9][1] ='<b>';
			$sqlquery = "SELECT priv.id,priv.privilege FROM $schema.user_privilege upriv, $schema.privilege priv WHERE (upriv.privilege=priv.id) AND (upriv.userid = $displayid)";

			eval {
				 $csr = $dbh->prepare($sqlquery);
				 $csr->execute;
				 while (@values = $csr->fetchrow_array) {
					  if ($values[0] > 1) {
							$uservalues[9][1] .= '<br>';
					  }
					  $uservalues[9][1] .= $values[1];
					  if ($values[0] < 0) {
							$uservalues[9][1] .= '<br>';
					  }
				 }
				 $uservalues[9][1] .='</b>';

				 $csr->finish;
			};
			print "<center><br><br>\n";
         print gen_table (\@uservalues);
         print "<br><br><a href=javascript:history.back()><b>Return to Previous Page</b></a>\n";
         print "</center>\n";
			if ($@) {
				 $message = errorMessage($dbh,$username,$userid,$schema,"display user privilege info.",$@);
				 $message =~ s/\n/\\n/g;
			}
	  } else {
			$message = "No user matches specified number of $displayid";
  }
}
&NQS_disconnect($dbh);   
print <<END;


</form>
</center>
</Body>
</HTML>

END

