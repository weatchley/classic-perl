#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/qa/perl/RCS/users_maint.pl,v $
#
# $Revision: 1.13 $
#
# $Date: 2007/04/13 16:18:47 $
#
# $Author: dattam $
#
# $Locker: higashis $
#
# $Log: users_maint.pl,v $
# Revision 1.13  2007/04/13 16:18:47  dattam
# Added disabled SNL check box for modify_selected and add_selected
#
# Revision 1.12  2004/05/30 23:04:28  starkeyj
# removed password field from modify_selected form
#
# Revision 1.11  2002/10/09 23:03:51  johnsonc
# Modified supplier permissions section in script to prevent OQA and BSC supplier administrators from modifying each others  privileges.
#
# Revision 1.10  2002/10/08 18:24:57  starkeyj
# modified all functions to enforce the 'use strict'
#
# Revision 1.9  2002/09/09 21:25:51  johnsonc
# Added the extra privileges for BSC for the user maintenance screens (SCREQ00044).
#
# Revision 1.8  2002/04/18 20:35:08  johnsonc
# Changed logic in the modify user section. If a users lastname or firstname is modified a new user record is created.
#
# Revision 1.7  2002/01/03 21:57:23  johnsonc
# Fixed javascript error that occured in IE version 5.0
#
# Revision 1.6  2001/12/21 21:51:27  johnsonc
# Changed modify user logic so that the form submission is halted if the modified user already exists in the system.
#
# Revision 1.5  2001/12/15 00:34:34  johnsonc
# Added verification so that new user cannot be added if the name is the same
# as that of an existing user.
#
# Revision 1.4  2001/12/07 23:49:19  johnsonc
# Divided active and inactive users on main screen. Added code to check if a user that is being added is already in the system. Formaso that form elements fit on entire screen when viewed in a lower resolution monitor
#
# Revision 1.3  2001/11/05 16:24:16  starkeyj
# changed path for background image
#
# Revision 1.2  2001/11/02 22:54:00  starkeyj
# added form validation and activity and error logs
#
# Revision 1.1  2001/10/22 14:43:52  starkeyj
# Initial revision
#
#
# Revision: $
#
# 
 

use NQS_Header qw(:Constants);
use OQA_Widgets qw(:Functions);
use OQA_Utilities_Lib qw(:Functions);
use OQA_specific qw(:Functions);
use strict;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

my $NQScgi = new CGI;

my $schema = (defined($NQScgi->param("schema"))) ? $NQScgi->param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

# print content type header
print $NQScgi->header('text/html');

my $pagetitle = $NQScgi->param('pagetitle');
my $cgiaction = $NQScgi->param('action');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $currentUser = 1;
my $userid = $NQScgi->param('userid');
my $username = $NQScgi->param('username');
my $updatetable = $NQScgi->param('updatetable');
my $alertString;
my %userhash;

my $keydisplayname;
my $suboffsetANDlength;

#print html
print "<html>\n";
print "<head>\n";
print "<meta http-equiv=\"expires\" content=\"Fri, 12 May 1996 14:35:02 EST\">\n";
print "<title>$pagetitle Maintenance</title>\n";

print <<testlabel1;
<!-- include external javascript code -->
<script src=$NQSJavaScriptPath/utilities.js></script>
<!--   <script src=/dcmm/prototype/javascript/dcmm-utilities.js></script> -->

    <script type="text/javascript">
    <!--
    var dosubmit = true;
    if (parent == self) {   // not in frames 
	location = '$NQSCGIDir/login.pl'
    }

    //-->
    </script>
  <script language="JavaScript" type="text/javascript">
  <!--
      doSetTextImageLabel('User Maintenance');
  //-->
  </script>
  <script language="JavaScript1.1">
        <!--
         
        
        function isBlank(s) {
      	for (var i=0; i<s.length; i++) {
      	  var c = s.charAt(i);
      	  if ((c != ' ') && (c != '\\n') && (c != '\\t') ) {
      	  	return false;
      	  }
      	}
      	return true;
        }
        
        function validate() {
            var msg = "";
            var msg2 = "";
            //var valid = 1;
            var i;
            var f = arguments[0];
            
            if (f.length < 9) {
					//alert(f.length);
					return true;
            }
            if (arguments.length == 2) {
               var names = arguments[1];
            	var thisUser = f.firstname.value.toLowerCase() + ' ' + f.lastname.value.toLowerCase();
            	for (var i = 0; i < names.length; i++) {
            		var sysUser = names[i].toLowerCase();
            		if (thisUser == sysUser) {
            			msg2 += f.firstname.value + ' ' + f.lastname.value + ' is already a system user\\n';
            		}
            	}
            }
            var digits = "1234567890";
				for (i=0;i<7;i++) {
					if ((digits.indexOf(f.phonenumber.value.charAt(i))<0)  || f.phonenumber.value.length != 7) {
						//valid = 0;
						msg2 += "\\nThe phone number is not valid\\n";
						i = 8;
					}

				}

				for (i=0;i<3;i++) {
					if (digits.indexOf(f.areacode.value.charAt(i))<0  || f.areacode.value.length != 3) {
						//valid = 0;
						msg2 += "The area code is not valid\\n";
						i = 4;
					}
				
		      }
    
          
         	if (isBlank(f.lastname.value) ) {
         		msg2 += "You must enter a last name\\n"; 
         	}
         	if (isBlank(f.firstname.value))  {
    				msg2 += "You must enter a first name\\n"; 
            }
            if (isBlank(f.email.value) ) {
				   msg2 += "You must enter an email address\\n"; 
         	}
         
          
         
                  
       if (msg2) {
      	msg = "--------------------------------------------------------------\\n";
      	msg += "The form was not submitted because of the following error(s):\\n";
      	msg += "Please correct the error(s) and resubmit.\\n";
      	msg += "-------------------------------------------------------------\\n\\n";
      //	msg += " - The following required field(s) are empty: ";
      	msg += msg2 + "\\n";
      
      	alert(msg);
              return false;
       }
       else {
       	return true;
       }
     }

 	function ViewSelected(action) {
 	   document.usermaint.action.value = action;
 	   document.usermaint.submit();
 	}
  //-->
</script>
testlabel1

print "</head>\n\n";
print "<body background=$NQSImagePath/background.gif text=$NQSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><CENTER>\n";

# connect to the oracle database and generate a database handle
my $dbh = NQS_connect();
my %userprivhash = &get_user_privs($dbh,$userid);   
#print "<center><h1>$pagetitle Maintenance</h1></center>\n";
print "<form action=\"$NQSCGIDir/users_maint.pl\" method=post name=usermaint>\n"; # onSubmit=\"return validate(this)\">\n";
print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=username type=hidden value=$username>\n";
print "<input name=userid type=hidden value=$userid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";

###############################
if ($cgiaction eq "add_user") {
###############################
    # print the sql which will update this table
    #$nextusersid = get_next_id($dbh, $updatetable);
    my $lastname = $NQScgi->param('lastname');
    $lastname =~ s/\'/\'\'/g;
    my $firstname = $NQScgi->param('firstname');
    $firstname =~ s/\'/\'\'/g;
    my $areacode = $NQScgi->param('areacode');
    my $phonenumber = $NQScgi->param('phonenumber');
    my $extension = $NQScgi->param('extension');
    my $email = $NQScgi->param('email');
    $email =~ s/\'/\'\'/g;
    my $error = "";
    my $submit = "";
    my ($thisusername,$modifyid,$nextusersid);
    # generate username
    ###$thisusername = make_username($dbh, $lastname, $firstname); # old username generator
    if (length($lastname) > 7) {
		$thisusername = substr (uc($lastname), 0, 7) . substr(uc($firstname), 0, 1);
    } 
    else {
		$thisusername = uc($lastname) . substr(uc($firstname), 0, 1);
    }
    my @e_privilege = $NQScgi->param('e_priv');
	 my @i_privilege = $NQScgi->param('i_priv');
    my @s_privilege = $NQScgi->param('s_priv');
    my $isactive = (@e_privilege || @i_privilege || @s_privilege) ? 'T' : 'F';
    
    $dbh->{AutoCommit} = 0;
	 $dbh->{RaiseError} = 1;
	 
	 eval { 	
	 	my $sqlstring = "SELECT id FROM $SCHEMA.users WHERE UPPER(lastname) = '" . uc($lastname)
			 	 	 	 . "' AND UPPER(firstname) = '" . uc($firstname) . "'";
		my $rc = $dbh->prepare($sqlstring);
		$rc->execute;
	 	$modifyid = $rc->fetchrow_array;
	 	if (!(defined($modifyid))) {
	 		#$nextusersid = get_maximum_id($dbh, $updatetable) + 1;
	 		$sqlstring = "SELECT users_seq.NEXTVAL FROM dual";
	 		$rc = $dbh->prepare($sqlstring);
	 		$rc->execute;
	 		$nextusersid = $rc->fetchrow_array;
    		my $password = NQS_encrypt_password("password");
			#($NQScgi->param('password'));
    		#$siteid = $NQScgi->param('siteid');	
    		$sqlstring = "INSERT INTO $SCHEMA.$updatetable 
                    	 (id,lastname,firstname,areacode,phonenumber,
                      extension, email,username,password,isactive) 
                  	 VALUES ($nextusersid, '$lastname', '$firstname',
                      '$areacode', '$phonenumber', '$extension', '$email',
                      '$thisusername', '$password', '$isactive')";
       
       	
			# print "$sqlstring<br>\n";
			 print "<!-- $sqlstring -->\n";  
    		$rc = $dbh->do($sqlstring);
    		foreach my $priv (@e_privilege) {
  				$sqlstring = "INSERT INTO $SCHEMA.user_privilege (privilege,userid) VALUES ($priv, $nextusersid)";
      		$rc = $dbh->do($sqlstring);
    		}
 			foreach my $priv (@i_privilege) {
  				$sqlstring = "INSERT INTO $SCHEMA.user_privilege (privilege,userid) VALUES ($priv, $nextusersid)";
      		$rc = $dbh->do($sqlstring);
    		}
    		foreach my $priv (@s_privilege) {
	   		$sqlstring = "INSERT INTO $SCHEMA.user_privilege (privilege,userid) VALUES ($priv, $nextusersid)";
	   		$rc = $dbh->do($sqlstring);
    		}
    		$cgiaction = "query";
    		$alertString = "$firstname $lastname has been added as a system user.";
       }
       else {
       	print "<input type=hidden name=userselect value=$modifyid>\n";
       	print "<input type=hidden name=action value=modify_selected>\n";
       	$submit = "document.usermaint.submit();";
    		$alertString = "$firstname $lastname is already in the system.";
       }
	 };
    if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error adding user $firstname $lastname, id $nextusersid.  $@");
		$alertString = "An error occurred while attempting to add $firstname $lastname to the system."; 
	 }
	 elsif (!(defined($modifyid))) {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username added user $firstname $lastname, id $nextusersid");
		
 	 }
 	 $alertString =~ s/\'\'/\\'/g;
    print "<script language=\"JavaScript\">
			  <!--
				  alert('$alertString');
				  $submit
			  -->
		  	  </script>";   
} ##############  endif add user  ########################

##################################
if ($cgiaction eq "modify_user") {
##################################
    # print the sql which will update this table
    my $thisusersid = $NQScgi->param('thisusersid');
    my $lastname = $NQScgi->param('lastname');
    $lastname =~ s/\'/\'\'/g;
    my $firstname = $NQScgi->param('firstname');
    $firstname =~ s/\'/\'\'/g;
    my $areacode = $NQScgi->param('areacode');
    my $phonenumber = $NQScgi->param('phonenumber');
    my $extension = $NQScgi->param('extension');
    my $email = $NQScgi->param('email');
    $email =~ s/\'/\'\'/g;
    my $thisusername = $NQScgi->param('thisusername');
    $thisusername =~ s/'/\'\'/g;
    my $password = $NQScgi->param('password');
    my $siteid = $NQScgi->param('siteid');
    my $userIdHistory = $NQScgi->param('useridhistory');
    my @e_privilege = $NQScgi->param('e_priv');
    my @i_privilege = $NQScgi->param('i_priv');
    my @s_privilege = $NQScgi->param('s_priv');
    
    $dbh->{AutoCommit} = 0;
	 $dbh->{RaiseError} = 1;
	 
    eval {
    	if ($password ne $NQScgi->param('oldpassword')) {
	 		$password = NQS_encrypt_password($NQScgi->param('password'));
    	}
    	my $sqlstring = "SELECT firstname, lastname FROM $SCHEMA.users WHERE id = $thisusersid";
    	my $rc = $dbh->prepare($sqlstring);
    	$rc->execute;
    	my ($firstnameCheck, $lastnameCheck) = $rc->fetchrow_array;
    	
    	# Execute this code block if the first name or the lastname of a system user is modified
    	# We will actually insert a new record
    	if ($firstname ne $firstnameCheck || $lastname ne $lastnameCheck) {
	 		$sqlstring = "SELECT users_seq.NEXTVAL FROM dual";
	 		$rc = $dbh->prepare($sqlstring);
	 		$rc->execute;
	 		my $nextusersid = $rc->fetchrow_array;
    		if (length($lastname) > 7) {
				$thisusername = substr (uc($lastname), 0, 7) . substr(uc($firstname), 0, 1);
    		} 
    		else {
				$thisusername = uc($lastname) . substr(uc($firstname), 0, 1);
    		}
    		$sqlstring = "INSERT INTO $SCHEMA.$updatetable (id, firstname, lastname, areacode, phonenumber, extension, "
    					 .  "email, username, password, user_id_history, isactive) VALUES ($nextusersid, '$firstname', "
    					 .  "'$lastname', '$areacode', '$phonenumber', '$extension', '$email', '$thisusername', '$password', "
    					 .  "'$userIdHistory', ";	
    		if (@e_privilege || @i_privilege || @s_privilege) {
			   $sqlstring .= "'T')";
			}
			else {
			   $sqlstring .= "'F')";
      	}
      	$rc = $dbh->do($sqlstring);
      	my $userIdHistory .= (!(defined($userIdHistory)) || $userIdHistory eq "") ? "$thisusersid" : "";
      	$userIdHistory .= ",$nextusersid";
      	my @ids = split(/,/,$userIdHistory);
      	foreach my $id (@ids) {
    			$sqlstring = "UPDATE $SCHEMA.$updatetable " 
                    		 . "SET user_id_history = '$userIdHistory' "
                    	 	 . "WHERE id = $id"; 
            $rc = $dbh->do($sqlstring);
         }
         $sqlstring = "DELETE $SCHEMA.user_privilege WHERE userid=$thisusersid";
    		$rc = $dbh->do($sqlstring);
    		$sqlstring = "UPDATE $SCHEMA.$updatetable SET isactive='F' WHERE id=$thisusersid";
    		$rc = $dbh->do($sqlstring);
         $thisusersid = $nextusersid;
    	}
    	# Update the system users information
    	else {
    		$sqlstring = "UPDATE $SCHEMA.$updatetable 
                    	  SET lastname='$lastname', firstname='$firstname',
                    	  areacode='$areacode', phonenumber='$phonenumber', 
                    	  extension='$extension', email='$email', 
                    	  username='$thisusername', password='$password'";
      	if (@e_privilege || @i_privilege || @s_privilege) {
      		$sqlstring .= ", isactive='T' ";
      	}
      	else {
      		$sqlstring .= ", isactive='F' ";
      	}
      	$sqlstring .= "WHERE id=$thisusersid";
      	$rc = $dbh->do($sqlstring);
      	$sqlstring = "DELETE $SCHEMA.user_privilege WHERE userid=$thisusersid";
    		$rc = $dbh->do($sqlstring);
      }
    	foreach my $priv (@e_privilege) {
			$sqlstring = "INSERT INTO $SCHEMA.user_privilege (privilege,userid) VALUES ($priv, $thisusersid)";
			$rc = $dbh->do($sqlstring);
    	}
    	foreach my $priv (@i_privilege) {
			$sqlstring = "INSERT INTO $SCHEMA.user_privilege (privilege,userid) VALUES ($priv, $thisusersid)";
			$rc = $dbh->do($sqlstring);
    	}
    	foreach my $priv (@s_privilege) {
			$sqlstring = "INSERT INTO $SCHEMA.user_privilege (privilege,userid) VALUES ($priv, $thisusersid)";
			$rc = $dbh->do($sqlstring);
    	}
    };
     
    if ($@) {
		$dbh->rollback;
		print "<!-- $userid, $username modified user $firstname $lastname, id $thisusersid -->\n";
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error updating user $firstname $lastname, id $thisusersid.  $@");
		$alertString = "An error occurred while modifying $firstname $lastname.";
	 }
	 else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username modified user $firstname $lastname, id $thisusersid");
		$alertString = "$firstname $lastname has been successfully modified.";
 	 }
 	 $alertString =~ s/\'\'/\\'/g;
 	 print "<script language=\"JavaScript\">
 			  <!--
 		 	       alert('$alertString');
 		 	  -->
		 	  </script>";
    $cgiaction="query";
}  ###############  endif modify user  ####################

######################################
if ($cgiaction eq "modify_selected") {
######################################
    my $thisusersid = (defined($NQScgi->param('userselect'))) ? $NQScgi->param('userselect') : $NQScgi->param('availuserselect');
    #$thisusersid = (defined($modifyid)) ? $modifyid : "";
    $submitonly = 1;
    
    %userhash = get_user_info($dbh, $thisusersid);
    
    # print the sql which will update this table
    my $lastname =     $userhash{'lastname'};
    my $firstname =    $userhash{'firstname'};
    my $areacode =     defined($userhash{'areacode'}) ? $userhash{'areacode'} : "";
    my $phonenumber =  defined($userhash{'phonenumber'}) ? $userhash{'phonenumber'} : "";
    my $extension =    defined($userhash{'extension'}) ? $userhash{'extension'} : "";
    my $email =        defined($userhash{'email'}) ? $userhash{'email'} : "";
    my $thisusername = $userhash{'thisusername'};
    my $password =     $userhash{'password'};
 	 my $isactive =     $userhash{'isactive'};
    my $siteid =       $userhash{'siteid'};
#    $checkedifactive = ($isactive eq 'T') ? "checked" : " ";
    my $userIdHistory = defined($userhash{'user_id_history'}) ? $userhash{'user_id_history'} : "";
    print "<!-- $isactive -->\n";
    my @ids = split(/,/,$userIdHistory);
    my $historyDisabled = ((defined($userIdHistory) && $userIdHistory ne "") && @ids[@ids-1] != $thisusersid && (defined($isactive) && $isactive ne "T")) ? "disabled=true" : "";
    my $disabled;
    my %internalprivilegehash = get_lookup_values($dbh, 'privilege', 'privilege', 'id',"application = 'I'");
    my %externalprivilegehash = get_lookup_values($dbh, 'privilege', 'privilege', 'id',"application = 'E'");
    my %surveillanceprivilegehash = get_lookup_values($dbh, 'privilege', 'privilege', 'id',"application = 'S'");
    
    my %userprivilegehash = get_lookup_values($dbh, 'user_privilege', 'privilege', 'userid', "userid = $thisusersid");
    my $sqlstring = "SELECT firstname || ' ' || lastname FROM $SCHEMA.users WHERE id != $thisusersid";
	 my $rc = $dbh->prepare($sqlstring);
	 $rc->execute;
    print "<script language=\"JavaScript\" type=\"text/javascript\">";
    print "<!--\n";
    print "var names = new Array();\n";
    my $i = 0;
	 while (my $name = $rc->fetchrow_array) {
	 	$name =~ s/'/\\'/g;
	 	print "names[$i] = '$name';\n";
	 	$i++;
	 }
    print "//-->\n";
    print "</script>\n";
    $rc->finish;
    print <<modifyform;
    <input name=cgiaction type=hidden value="modify_user">
    <input type=hidden name=schema value=$SCHEMA>
    <br>
    <table summary="modify user table" width="720" border=0>
    <tr><td width="35%" align=left><b><li>User ID:</b></td>
    <td width="65%" align=left><b>$thisusername</b>
    <input name=thisusersid type=hidden value=$thisusersid>
    <input name=thisusername type=hidden value=$thisusername></td></tr>
    <tr><td align=left><b><li>First Name:</b></td>
    <td align=left><input name=firstname type=text maxlength=30 size=35 value="$firstname" $historyDisabled></td></tr>
    <tr><td align=left><b><li>Last Name:</b></td>
    <td align=left><input name=lastname type=text maxlength=30 size=35 value="$lastname" onload="focus()" $historyDisabled></td></tr>
    <tr><td align=left><b><li>Phone Number:</b></td>
    <td nowrap><b>Area Code:</b>&nbsp;&nbsp;
    (<input name=areacode type=text maxlength=3 size=5 value=$areacode $historyDisabled>)&nbsp;&nbsp;
    <b>Number:</b>&nbsp;&nbsp;
    <input name=phonenumber type=text maxlength=7 size=10 value=$phonenumber $historyDisabled>&nbsp;&nbsp;(no hyphen)&nbsp;&nbsp;
    <b>Extension:</b>&nbsp;&nbsp;
    <input name=extension type=text maxlength=5 size=8 value="$extension" $historyDisabled></td></tr>
    <tr><td align=left><b><li>Email Address:</b></td>
    <td align=left><input name=email type=text maxlength=75 size=80 value=$email $historyDisabled></td></tr>
    <tr><td colspan=2><td align=left><input name=password type=hidden maxlength=50 size=50 value=$password $historyDisabled>
    <input type=hidden name=oldpassword value=$password></td></tr>
    </table>
modifyform
	 if (defined($userIdHistory) && $userIdHistory ne "") {
	 	print "<table width=720 border=0 cellpadding=1 cellspacing=1 align=center>\n";
	 	print "<tr><td colspan=5><b><li>User Name History:</b></td></tr>\n";
	 	my $i = 1;
	 	print "<tr><td>&nbsp;&nbsp;&nbsp;</td><td>";
	 	foreach my $id (reverse @ids) {
	 	 	my $sqlstring = "SELECT firstname, lastname, isactive FROM $SCHEMA.users WHERE id = $id";
	 	 	$rc = $dbh->prepare($sqlstring);
	 	 	$rc->execute;
	 	 	my ($oldFirstName, $oldLastName, $isactive) = $rc->fetchrow_array;
	 	 	if ($i == 1 && (defined($isactive) && $isactive eq "T")) {
	 	 		print "<b>$oldFirstName $oldLastName (current active user name)</b>";
	 	 		$currentUser = 0 if ($thisusersid != $id);
	 	 	}
	 	 	else {
	 	 		print "$oldFirstName $oldLastName"
	 	 	}
	 	 	print ",&nbsp;" if ($i != @ids);
	 	 	print "</td></tr>\n" if ($i % 4 == 0);
	 	 	print "<tr><td>&nbsp;&nbsp;&nbsp;</td><td>" if ($i % 4 == 0 && $i != @ids);
	 	 	$i++;
	 	}
	 	print "</table>\n";
	 }
    print "<br>\n";
    #print "<select multiple name=privilegeselect title=\"Select the privileges for this user.\" size=10>\n";
    print "<table width=720 border=1 cellpadding=1 cellspacing=1 align=center rules=cols>\n";
    print "<tr><td nowrap valign=top>\n";
    print "<table border=0 cellpadding=1 cellspacing=1 align=left rules=none>\n";
    print "<tr><td colspan=2 valign=top><font color=black><b>External Audit Privileges</b></font></td></tr>\n";
    
    foreach my $key (sort keys %externalprivilegehash) {
	 	my $checkedoption = defined($userprivilegehash{$externalprivilegehash{$key}}) ? "checked" : "";
	   if (($userprivhash{'OQA Supplier Administration'} == 1 && (substr($key,0, 3) eq "OQA" || substr($key, 0, 8) eq "Supplier")) || $userprivhash{'Developer'} == 1) {
		   $disabled = "  ";
	   }
	   elsif (($userprivhash{'BSC Supplier Administration'} == 1 && (substr($key,0, 3) eq "BSC" || substr($key, 0, 8) eq "Supplier")) || $userprivhash{'Developer'} == 1) {
		   $disabled = "  ";	   
	   }
	   elsif (($userprivhash{'SNL Supplier Administration'} == 1 && (substr($key,0, 3) eq "SNL" || substr($key, 0, 8) eq "Supplier")) || $userprivhash{'Developer'} == 1) {
	   		   $disabled = "  ";	   
	   }
	   else {
	   		$disabled = "disabled=true";
	   }	   
	   if(substr($key,0, 3) eq "BSC"){
	   	$keydisplayname = $key;
	    $suboffsetANDlength = substr($keydisplayname,0, 3,"M&O");	
	   }elsif(substr($key,0, 2) eq "SN"){
	   	$keydisplayname = $key;
	    $suboffsetANDlength = substr($keydisplayname,0, 2," L");	
	   }else{
	   $keydisplayname = $key;
	   }	   
	 	print "<tr><td nowrap>$keydisplayname</td><td valign=top><input name=e_priv $disabled type=checkbox value=\"$externalprivilegehash{$key}\"  $checkedoption $historyDisabled></td></tr>\n";
    }
    print "</table></td>\n";
    #print "<td width=5></td>\n";
    print "<td nowrap valign=top><table border=0 cellpadding=1 cellspacing=1 align=left rules=none>\n";
    
    print "<tr><td colspan=2><font color=black><b>Internal Audit Privileges</b></font></td></tr>\n";
    foreach my $key (sort keys %internalprivilegehash) {
    	my $checkedoption = defined($userprivilegehash{$internalprivilegehash{$key}}) ? "checked" : "";
    	if (($userprivhash{'BSC Internal Administration'} == 1 && substr($key,0, 3) eq "BSC") || $userprivhash{'Developer'} == 1) {
    		$disabled = "";
    	}
    	elsif (($userprivhash{'OQA Internal Administration'} == 1 && substr($key,0, 3) eq "OQA") || $userprivhash{'Developer'} == 1) {
    		$disabled = "";
    	}
    	elsif (($userprivhash{'SNL Internal Administration'} == 1 && substr($key,0, 3) eq "SNL") || $userprivhash{'Developer'} == 1) {
	    		$disabled = "";
    	}
    	else { 
    		$disabled = "disabled=true"; 
    	}
    	if(substr($key,0, 3) eq "BSC"){
	   	$keydisplayname = $key;
	    $suboffsetANDlength = substr($keydisplayname,0, 3,"M&O");	
	   }elsif(substr($key,0, 2) eq "SN"){
	   	$keydisplayname = $key;
	    $suboffsetANDlength = substr($keydisplayname,0, 2," L");	
	   }else{
	   $keydisplayname = $key;
	   }	  
	   if($keydisplayname eq "M&O Internal Schedule Approver" || $keydisplayname eq " LL Internal Schedule Approver"){
	   print "<tr style='display:none;'><td nowrap>$keydisplayname</td><td valign=top><input name=i_priv type=checkbox value=\"$internalprivilegehash{$key}\" checked $historyDisabled></td></tr>\n";	
	   }else{
	 	print "<tr><td nowrap>$keydisplayname</td><td valign=top><input name=i_priv $disabled type=checkbox value=\"$internalprivilegehash{$key}\" $checkedoption $historyDisabled></td></tr>\n";
	   }
	 }
    print "</table></td>\n";
    #print "<td width=5></td>\n";
  	 print "<td nowrap valign=top><table border=0 cellpadding=1 cellspacing=1 align=left rules=none>\n";
    
    print "<tr><td colspan=2><font color=black><b>Surveillance Privileges</b></font></td></tr>\n";
    foreach my $key (sort keys %surveillanceprivilegehash) {
		my $checkedoption = defined($userprivilegehash{$surveillanceprivilegehash{$key}}) ? "checked" : "";
    	if (($userprivhash{'BSC Surveillance Administration'} == 1 && substr($key,0, 3) eq "BSC") || $userprivhash{'Developer'} == 1) {
    		$disabled = "";
    	}
    	elsif (($userprivhash{'OQA Surveillance Administration'} == 1 && substr($key,0, 3) eq "OQA") || $userprivhash{'Developer'} == 1) {
    		$disabled = "";
    	}
    	elsif (($userprivhash{'SNL Surveillance Administration'} == 1 && substr($key,0, 3) eq "SNL") || $userprivhash{'Developer'} == 1) {
	    		$disabled = "";
    	}
    	else { 
    		$disabled = "disabled=true"; 
    	}
    	if(substr($key,0, 3) eq "BSC"){
	   	$keydisplayname = $key;
	    $suboffsetANDlength = substr($keydisplayname,0, 3,"M&O");	
	   }elsif(substr($key,0, 2) eq "SN"){
	   	$keydisplayname = $key;
	    $suboffsetANDlength = substr($keydisplayname,0, 2," L");	
	   }else{
	   $keydisplayname = $key;
	   }	  
	    if($keydisplayname eq "M&O Surveillance Schedule Approver" || $keydisplayname eq " LL Surveillance Schedule Approver"){
	    print "<tr style='display:none;'><td nowrap>$keydisplayname</td><td valign=top><input name=s_priv type=checkbox value=\"$surveillanceprivilegehash{$key}\"  checked $historyDisabled></td></tr>\n";
	    }else{
	 	print "<tr><td nowrap>$keydisplayname</td><td valign=top><input name=s_priv type=checkbox $disabled value=\"$surveillanceprivilegehash{$key}\"  $checkedoption $historyDisabled></td></tr>\n";
	    }
	}
    print "</table></td></tr>\n";
    print "</table>\n";
    print "<input name=action type=hidden value=modify_user>\n";
    print "<input name=useridhistory type=hidden value='$userIdHistory'>\n";
} ############## endif modify selected  #######################

###################################
if ($cgiaction eq "add_selected") {
###################################
	 my $disabled = "";
    $submitonly = 1;
    my %externalprivilegehash = get_lookup_values($dbh, 'privilege', 'privilege', 'id',"application = 'E'");
    my %internalprivilegehash = get_lookup_values($dbh, 'privilege', 'privilege', 'id',"application = 'I'");
    my %surveillanceprivilegehash = get_lookup_values($dbh, 'privilege', 'privilege', 'id',"application = 'S'");
    
    print <<addform;
    <input name=cgiaction type=hidden value="add_user">
    <br><br>
    <table summary="add user table" width="720" border=0>
    <tr><td><b><li>First Name:</b></td>
    <td><input name=firstname type=text maxlength=30 size=35></td></tr>
    <tr><td width="20%"><b><li>Last Name:</b></td>
    <td width=80%><input name=lastname type=text maxlength=30 size=35></td></tr>
    <tr><td><b><li>Phone Number:</b></td>
    <td><b>Area Code:&nbsp;</b>
    (<input name=areacode type=text maxlength=3 size=5>)
    &nbsp;&nbsp;<b>Number:&nbsp;</b>
    <input name=phonenumber type=text maxlength=7 size=10>&nbsp;(no hyphen)
    &nbsp;&nbsp;<b>Extension:</b>
    &nbsp;<input name=extension type=text maxlength=5 size=8></td></tr>
    <tr><td><b><li>Email Address:</b></td>
    <td> <input name=email type=text maxlength=75 size=80></td></tr>
    <!-- tr><td><b><li>Password:</b></td>
    <td><input name=password type=password maxlength=50 size=50>
    <input type=hidden name=oldpassword></td></tr -->
    </table>
addform
    
    print "<br>\n<br>\n";
	 print "<table width=720 border=1 cellpadding=1 cellspacing=1 align=center rules=cols>\n";
  	 print "<tr><td valign=top>\n";
  	 print "<table border=0 cellpadding=1 cellspacing=1 align=left rules=none>\n";
  	 print "<tr><td colspan=2><font color=black><b>External Audit Privileges</b></font></td></tr>\n";
  	 if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'SNL Supplier Administration'} == 1 || $userprivhash{'BSC Supplier Administration'} == 1 ) {
	 	$disabled = "";
	 }
    else {$disabled = " disabled=true";}
    foreach my $key (sort keys %externalprivilegehash) {
		if (($userprivhash{'OQA Supplier Administration'} == 1 && (substr($key,0, 3) eq "OQA" || substr($key, 0, 8) eq "Supplier")) || $userprivhash{'Developer'} == 1) {
			$disabled = "  ";
		}
		elsif (($userprivhash{'BSC Supplier Administration'} == 1 && (substr($key,0, 3) eq "BSC" || substr($key, 0, 8) eq "Supplier")) || $userprivhash{'Developer'} == 1) {
			$disabled = "  ";	   
		}
		elsif (($userprivhash{'SNL Supplier Administration'} == 1 && (substr($key,0, 3) eq "SNL" || substr($key, 0, 8) eq "Supplier")) || $userprivhash{'Developer'} == 1) {
					$disabled = "  ";	   
		}
		else {$disabled = "disabled=true";}
		
		if(substr($key,0, 3) eq "BSC"){
	   	$keydisplayname = $key;
	    $suboffsetANDlength = substr($keydisplayname,0, 3,"M&O");	
	   }elsif(substr($key,0, 2) eq "SN"){
	   	$keydisplayname = $key;
	    $suboffsetANDlength = substr($keydisplayname,0, 2," L");	
	   }else{
	   $keydisplayname = $key;
	   }
	   
	 	print "<tr><td nowrap>$keydisplayname</td><td valign=top><input name=e_priv type=checkbox value=\"$externalprivilegehash{$key}\" $disabled></td></tr>\n";
  	 }
  	 print "</table></td>\n";
  	 #print "<td width=5></td>\n";
  	 print "<td><table border=0 cellpadding=1 cellspacing=1 align=left rules=none>\n";
  	 print "<tr><td colspan=2><font color=black><b>Internal Audit Privileges</b></font></td></tr>\n";
  	 foreach my $key (sort keys %internalprivilegehash) {
    	if (($userprivhash{'BSC Internal Administration'} == 1 && substr($key,0, 3) eq "BSC") || $userprivhash{'Developer'} == 1) {
    		$disabled = "";
    	}
    	elsif (($userprivhash{'OQA Internal Administration'} == 1 && substr($key,0, 3) eq "OQA") || $userprivhash{'Developer'} == 1) {
    		$disabled = "";
    	}
    	elsif (($userprivhash{'SNL Internal Administration'} == 1 && substr($key,0, 3) eq "SNL") || $userprivhash{'Developer'} == 1) {
	    		$disabled = "";
    	}
    	else { $disabled = "disabled=true"; }
    	    	
		if(substr($key,0, 3) eq "BSC"){
	   	$keydisplayname = $key;
	    $suboffsetANDlength = substr($keydisplayname,0, 3,"M&O");	
	   }elsif(substr($key,0, 2) eq "SN"){
	   	$keydisplayname = $key;
	    $suboffsetANDlength = substr($keydisplayname,0, 2," L");	
	   }else{
	   $keydisplayname = $key;
	   }
	    if($keydisplayname eq "M&O Internal Schedule Approver" || $keydisplayname eq " LL Internal Schedule Approver"){    	
	 	print "<tr style='display:none;'><td nowrap>$keydisplayname</td><td valign=top><input name=i_priv type=checkbox value=\"$internalprivilegehash{$key}\" checked></td></tr>\n";
	 	}else{
	 	print "<tr><td nowrap>$keydisplayname</td><td valign=top><input name=i_priv type=checkbox value=\"$internalprivilegehash{$key}\" $disabled></td></tr>\n";	
	 	}
  	 }
  	 print "</table></td>\n";
  	 #print "<td width=5></td>\n";
	 print "<td><table border=0 cellpadding=1 cellspacing=1 align=left rules=none>\n";
	 print "<td colspan=2><font color=black><b>Surveillance Privileges</b></font></td></tr>\n";
	 foreach my $key (sort keys %surveillanceprivilegehash) {
    	if (($userprivhash{'BSC Surveillance Administration'} == 1 && substr($key,0, 3) eq "BSC") || $userprivhash{'Developer'} == 1) {
    		$disabled = "";
    	}
    	elsif (($userprivhash{'OQA Surveillance Administration'} == 1 && substr($key,0, 3) eq "OQA") || $userprivhash{'Developer'} == 1) {
    		$disabled = "";
    	}
    	elsif (($userprivhash{'SNL Surveillance Administration'} == 1 && substr($key,0, 3) eq "SNL") || $userprivhash{'Developer'} == 1) {
	    		$disabled = "";
    	}
    	else { $disabled = "disabled=true"; }
    	    	 	
		if(substr($key,0, 3) eq "BSC"){
	   	$keydisplayname = $key;
	    $suboffsetANDlength = substr($keydisplayname,0, 3,"M&O");	
	   }elsif(substr($key,0, 2) eq "SN"){
	   	$keydisplayname = $key;
	    $suboffsetANDlength = substr($keydisplayname,0, 2," L");	
	   }else{
	   $keydisplayname = $key;
	   }
	     if($keydisplayname eq "M&O Surveillance Schedule Approver" || $keydisplayname eq " LL Surveillance Schedule Approver"){
	 		print "<tr style='display:none;'><td nowrap>$keydisplayname</td><td valign=top><input name=s_priv type=checkbox value=\"$surveillanceprivilegehash{$key}\" checked></td></tr>\n";
	     }else{
	     	print "<tr><td nowrap>$keydisplayname</td><td valign=top><input name=s_priv type=checkbox value=\"$surveillanceprivilegehash{$key}\" $disabled></td></tr>\n";
	     }
	 }
  	 print "</table></td></tr>\n";
    print "</table>\n";
    print "<input name=action type=hidden value=add_user>\n";
}
######################################
if ($cgiaction eq "view_selected") {
######################################
    my $thisusersid = (defined($NQScgi->param('userselect'))) ? $NQScgi->param('userselect') : $NQScgi->param('availuserselect');
    $submitonly = 1;
    
    %userhash = get_user_info($dbh, $thisusersid);
    
    # print the sql which will update this table
    my $lastname =     $userhash{'lastname'};
    my $firstname =    $userhash{'firstname'};
    my $areacode =     defined($userhash{'areacode'}) ? $userhash{'areacode'} : "";
    my $phonenumber =  defined($userhash{'phonenumber'}) ? $userhash{'phonenumber'} : "";
    my $extension =    defined($userhash{'extension'}) ? $userhash{'extension'} : "";
    my $email =        defined($userhash{'email'}) ? $userhash{'email'} : "";
    my $thisusername = $userhash{'thisusername'};
    my $password =     $userhash{'password'};
 	 my $isactive =     $userhash{'isactive'};
    my $siteid =       $userhash{'siteid'};
   # $checkedifactive = ($isactive eq 'T') ? "checked" : "";
    my $userIdHistory = defined($userhash{'user_id_history'}) ? $userhash{'user_id_history'} : "";
    my %internalprivilegehash = get_lookup_values($dbh, 'privilege', 'privilege', 'id',"application = 'I'");
    my %externalprivilegehash = get_lookup_values($dbh, 'privilege', 'privilege', 'id',"application = 'E'");
    my %surveillanceprivilegehash = get_lookup_values($dbh, 'privilege', 'privilege', 'id',"application = 'S'");
    
    my %userprivilegehash = get_lookup_values($dbh, 'user_privilege', 'privilege', 'userid', "userid = $thisusersid");
    
    print <<viewform;
    
    <br>
    <table summary="view user table" width="720" border=0>
    <tr><td width="25%" align=left><b><li>User ID:</b></td><td width="65%" align=left><b>$thisusername</b></td></tr>
    <tr><td align=left><b><li>First Name:</b></td><td align=left>$firstname</td></tr>
    <tr><td align=left><b><li>Last Name:</b></td><td align=left>$lastname</td></tr>
    <tr><td align=left><b><li>Phone Number:</b></td><td><b>Area Code:</b>&nbsp;&nbsp;
    ($areacode)&nbsp;&nbsp;
    <b>Number:</b>&nbsp;&nbsp;$phonenumber&nbsp;&nbsp;&nbsp;&nbsp;
    <b>Extension:</b>&nbsp;&nbsp;$extension</td></tr>
    <tr><td align=left><b><li>Email Address:</b></td><td align=left>$email</td></tr>
    </table>
viewform
	 if (defined($userIdHistory) && $userIdHistory ne "") {
	 	print "<table width=720 border=0 cellpadding=1 cellspacing=1 align=center>\n";
	 	print "<tr><td colspan=5><b><li>User Name History:</b></td></tr>\n";
	 	my $i = 1;
	 	print "<tr><td>&nbsp;&nbsp;&nbsp;</td><td>";
	 	my @ids = split(/,/,$userIdHistory);
	 	foreach my $id (reverse @ids) {
	 	 	my $sqlstring = "SELECT firstname, lastname, isactive FROM $SCHEMA.users WHERE id = $id";
	 	 	my $rc = $dbh->prepare($sqlstring);
	 	 	$rc->execute;
	 	 	my ($oldFirstName, $oldLastName, $isactive) = $rc->fetchrow_array;
	 	 	if ($i == 1 && (defined($isactive) && $isactive eq "T")) {
	 	 		print "<b>$oldFirstName $oldLastName (current active user name)</b>";
	 	 	}
	 	 	else {
	 	 		print "$oldFirstName $oldLastName"
	 	 	}
	 	 	print ",&nbsp;" if ($i != @ids);
	 	 	print "</td></tr>\n" if ($i % 4 == 0);
	 	 	print "<tr><td>&nbsp;&nbsp;&nbsp;</td><td>" if ($i % 4 == 0 && $i != @ids);
	 	 	$i++;
	 	}
	 	print "</table>\n";
	 }
    print "<br>\n";
    #print "<select multiple name=privilegeselect title=\"Select the privileges for this user.\" size=10>\n";
    print "<table width=720 border=1 cellpadding=1 cellspacing=1 align=center rules=cols>\n";
    print "<tr><td valign=top>\n";
    print "<table border=0 cellpadding=1 cellspacing=1 align=left>\n";
    print "<tr><td colspan=2><font color=black><b>External Audit Privileges</b></font></td></tr>\n";
    
    foreach my $key (sort keys %externalprivilegehash) {
	 	my $checkedoption = defined($userprivilegehash{$externalprivilegehash{$key}}) ? "checked" : "";
	 	
		print "<tr><td nowrap>$key</td><td><input name=e_priv type=checkbox value=\"$externalprivilegehash{$key}\" disabled=true $checkedoption></td></tr>\n";
    }
    print "</table></td>\n";
    #print "<td width=5></td>\n";
    print "<td><table border=0 cellpadding=1 cellspacing=1 align=left>\n";
    print "<tr><td colspan=2><font color=black><b>Internal Audit Privileges</b></font></td></tr>\n";
    foreach my $key (sort keys %internalprivilegehash) {
    	my $checkedoption = defined($userprivilegehash{$internalprivilegehash{$key}}) ? "checked" : "";
	 	print "<tr><td nowrap>$key</td><td><input name=i_priv type=checkbox value=\"$internalprivilegehash{$key}\" disabled=true $checkedoption></td></tr>\n";
    }
    print "</table></td>\n";
    #print "<td width=5></td>\n";
    print "<td><table border=0 cellpadding=1 cellspacing=1 align=left>\n";
    print "<tr><td colspan=2><font color=black><b>Surveillance Privileges</b></font></td></tr>\n";
    foreach my $key (sort keys %surveillanceprivilegehash) {
	 	my $checkedoption = defined($userprivilegehash{$surveillanceprivilegehash{$key}}) ? "checked" : "";
	 	print "<tr><td nowrap>$key</td><td><input name=s_priv type=checkbox value=\"$surveillanceprivilegehash{$key}\" disabled=true $checkedoption></td></tr>\n";
    }
    print "</table></td></tr>\n";
    print "</table>\n";
} ############## endif view selected  #######################

############################
if ($cgiaction eq "query") {
############################
    my %useractivehash = get_lookup_values($dbh, $updatetable, "lastname || ' ' || firstname", 'id', "isactive = 'T'");
    my %userinactivehash = get_lookup_values($dbh, $updatetable, "lastname || ' ' || firstname", 'id', "isactive = 'F'");
    #my %userhash = get_lookup_values($dbh, $updatetable, "lastname || ', ' || firstname || ';' || id", 'id');
    #print<<queryformtop;
    #<br><br>
    #<select name=selecteduser size=10>
#queryformtop
	my $action = "";
   if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'SNL Supplier Administration'} == 1 || $userprivhash{'BSC Supplier Administration'} == 1 
      || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1 || $userprivhash{'BSC Surveillance Administration'} == 1
      || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'SNL Internal Administration'} == 1 || $userprivhash{'BSC Internal Administration'} == 1) {
      $action = "modify_selected";
   }
   else {
		$action = "view_selected";
   }
   
   print<<table;
<br>
<br>
<table cellpadding=5 align=center>
<tr>
<td align=center><b>Active users</b></td>
<td align=center><b>Inactive users</b></td>
<tr>
<td><select name=availuserselect size=10 ondblclick="ViewSelected('$action');" onClick="document.usermaint.userselect.selectedIndex = -1;">
table

   foreach my $key (sort { lc($a) cmp lc($b) } keys %useractivehash) {
		my $usernamestring = $key;
		$usernamestring =~ s/;$useractivehash{$key}//g;
		$usernamestring =~ /(.*)\s(.*)/;
		print "<option value=\"$useractivehash{$key}\">$2 $1\n";
   }
   print "</select></td>\n<td><select name=userselect size=10 ondblclick=\"ViewSelected('$action');\" onClick=\"document.usermaint.availuserselect.selectedIndex = -1;\">\n";
   
   foreach my $key (sort { lc($a) cmp lc($b) } keys %userinactivehash) {
		my $usernamestring = $key;
		$usernamestring =~ s/;$userinactivehash{$key}//g;
		$usernamestring =~ /(.*)\s(.*)/;
		print "<option value=\"$userinactivehash{$key}\">$2 $1\n";
   }
   
print <<queryformbottom;
</td>
</select>
</table>
<input name=action type=hidden value=query>
<input name=usernum type=hidden value=''>
queryformbottom
   
}

#disconnect from the database
&NQS_disconnect($dbh);

$userhash{'user_id_history'} = defined($userhash{'user_id_history'}) ? $userhash{'user_id_history'} : "";
# print html footers.
print "<br>\n";
if ($submitonly == 0) {
	if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Internal Administration'} == 1  || $userprivhash{'SNL Internal Administration'} == 1  || $userprivhash{'BSC Internal Administration'} == 1
  		|| $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'SNL Supplier Administration'} == 1 || $userprivhash{'BSC Supplier Administration'} == 1 
  		|| $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1 || $userprivhash{'BSC Surveillance Administration'} == 1) {
  		print "<input name=add type=submit value=\"Add New User\" title=\"Add New User\" onclick=\"document.usermaint.action.value='add_selected'; submit();\">\n";
  		print "<input name=modify type=submit value=\"Modify Selected User\" title=\"Modify the Selected User's Record\" onclick=\"dosubmit=true; (document.usermaint.availuserselect.selectedIndex == -1 && document.usermaint.userselect.selectedIndex == -1) ? (alert(\'No User Selected\') || (dosubmit = false)) : document.usermaint.action.value='modify_selected'; return(dosubmit)\">\n";
	}
	elsif ($cgiaction ne 'view_selected') {
		print "<input name=view type=submit value=\"View Selected User\" title=\"View the Selected User's Record\" onclick=\"dosubmit=true; (document.usermaint.availuserselect.selectedIndex == -1 && document.usermaint.userselect.selectedIndex == -1) ? (alert(\'No User Selected\') || (dosubmit = false)) : document.usermaint.action.value='view_selected'; return(dosubmit)\">\n";
	}
}
else {
	 if (($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Internal Administration'} == 1  || $userprivhash{'SNL Internal Administration'} == 1  || $userprivhash{'BSC Internal Administration'} == 1
  		|| $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'SNL Supplier Administration'} == 1 || $userprivhash{'BSC Supplier Administration'} == 1
  		|| $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1 || $userprivhash{'BSC Surveillance Administration'} == 1) && $currentUser == 1) {
  		if ($cgiaction eq "add_selected") {
    		print "<input name=submit type=submit value=\"Submit Changes\"  onClick=\"return validate(document.usermaint)\">";
    	}
    	else {
    		print "<input name=submit type=submit value=\"Submit Changes\"  onClick=\"return validate(document.usermaint, names)\">";
  		}
    	print "<script language=\"JavaScript\" type=\"text/javascript\">";
    	print "<!--\n";
    	print "    function clearPrivList(list) {\n";
    	print "        for (var i =0; i <= list.length-1; i++) {\n";
    	print "            list.options[i].selected = false;\n";
    	print "        }\n";
    	print "    }\n";
    	print "      doSetTextImageLabel('Users Maintenance');\n";
    	print "//-->\n";
    	print "</script>\n";
	}
}
print "</form>\n";
print "</CENTER><br><br><br><br></body>\n";
print "</html>\n";
