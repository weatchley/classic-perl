#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# $Source $
#
# $Revision: 1.3 $
#
# $Date: 2001/11/20 14:50:21 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: cause_code_maint.pl,v $
# Revision 1.3  2001/11/20 14:50:21  starkeyj
# modified color and title bar
#
# Revision 1.2  2001/07/09 14:27:32  starkeyj
# updated to show title
#
# Revision 1.1  2001/07/06 23:04:03  starkeyj
# Initial revision
#
# 

use NQS_Header qw(:Constants);
use NQS_Utilities_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $ddtcgi = new CGI;

$SCHEMA = (defined($ddtcgi->param("schema"))) ? $ddtcgi->param("schema") : $SCHEMA;

# print content type header
print $ddtcgi->header('text/html');

my $pagetitle = $ddtcgi->param('pagetitle');
my $cgiaction = $ddtcgi->param('cgiaction');
my $username = $ddtcgi->param('username');
my $userid = $ddtcgi->param('userid');
my $cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $updatetable = $ddtcgi->param('updatetable');
my $title;
if ($updatetable eq "t_cause_group") {$title = 'Cause Group Maintenance';}
elsif ($updatetable eq "t_cause") {$title = 'Cause Code Maintenance';}
else {$title = 'Maintenance';}

#print html
print "<html>\n";
print "<head>\n";
print "<meta http-equiv=\"expires\" content=\"Fri, 12 May 1996 14:35:02 EST\">\n";
print "<title>$pagetitle Maintenance</title>\n";

print <<testlabel1;

<script language=javascript><!--

function submitForm (script, command, id) {

    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.submit();
}
function isBlank(s) {
    for (var i=0; i<s.length; i++) {
       var c = s.charAt(i);
       if ((c != ' ') && (c != '\\n') && (c != '\\t') ) {
	  return false;
       }
    }
    return true;
}
function validate(f) {
    var msg = "";
    var empty_fields = "";
      	
    for (var i=0; i<f.length; i++) {
	var e = f.elements[i];
	if ((e.type == "text") && (e.name != "group" )) {
	  if ((e.value == null) || (e.value == "") || (isBlank(e.value))) {
	    empty_fields += "\\n     " + e.name;
	    continue;
	  }
	}
    }
            
    if (!empty_fields) {
      return true;
    }
            
    if (empty_fields) {
	msg = "--------------------------------------------------------------\\n";
	msg += "The form was not submitted because of the following error(s):\\n";
	msg += "Please correct the error(s) and resubmit.\\n";
	msg += "-------------------------------------------------------------\\n\\n";
	msg += " - The following required field(s) are empty: ";
	msg += "       " + empty_fields + "\\n";

	alert(msg);
        return false;
    }
      
}
function temporary (e, command,table) {
	for (var i=0;i<e.options.length;i++) 
		if (e.options[i].selected) {
			document.$form.groupid.value = e.options[i].value;
			document.$form.group.value = e.options[i].value;
			var id = e.options[i].value;
			var str = e.options[i].text;
			var index = str.search(/-/i);
			document.$form.groupdesc.value = str.substr(index+2);		
		}
	if (table == 't_cause') {
		document.$form.cause.value = "";
		document.$form.description.value = "";
	}
	submitForm('cause_code_maint', command, id);

}
function none () {
	submitForm('cause_code_maint', command, id);
	
	
}
function populateCode (e) {
	for (var i=0;i<e.options.length;i++) 
		if (e.options[i].selected) {
			document.$form.cause.value = e.options[i].value;
			var str = e.options[i].text;
			var index = str.search(/-/i);
			document.$form.description.value = str.substr(index+2);		
		}
	msg.style.visibility='hidden';	
}
function clear_group_form() {
	document.$form.groupid.value = 0;
	document.$form.group.value = "";
	document.$form.groupdesc.value = "";
	msg.style.visibility='hidden';	
}
function clear_cause_form() {
	document.$form.causes.options.length = 0;
	document.$form.groupid.value = 0;
	document.$form.group.value = "";
	document.$form.groupdesc.value = "";
	document.$form.cause.value = "";
	document.$form.description.value = "";
	msg.style.visibility='hidden';	
}
function exit() {
	document.$form.cgiaction.value = 'menu';
	document.$form.action = '$path' + 'trend_home.pl';
	document.$form.submit();

}

//-->
</script>

testlabel1
$pagetitle =~ s/_/ /g;
print "</head>\n\n";
print "<body bgcolor=#FFFFEO  text=$NQSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><CENTER>\n";
print "<hr><br>\n";
# connect to the oracle database and generate a database handle
my $dbh = trend_connect();
print "<form action=\"$NQSCGIDir/cause_code_maint.pl\" method=post name=cause_code_maint onSubmit=\"return validate(this)\">\n";
my $statusmsg = "";
my $errormsg .= "";
#print "<table border=0 cellspacing=0 cellpadding=0 width=750 align=center>\n";
#print "<tr><td align=center colspan=3><hr></td></tr>\n";
#print "<tr>\n";
#print "<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=1><tr><td align=center><font size=2 color=black>User:&nbsp;$username</font></td></tr></table></td>\n";
#print "<td align=center valign=center width=60%><font size=+1><B>$title</B></td>\n";
#print "<td align=center valign=center width=20%><table border=1 cellspacing=0 cellpadding=1><tr><td align=center><font size=2 color=black>DB:&nbsp;QA</font></td></tr></table></td>\n";
#print "</tr>\n";
#print "<tr><td align=center colspan=3><hr></td></tr>\n";
#print "</table>\n";
##########################################
if ($cgiaction eq "add_cause") {
##########################################
    # print the sql which will update this table
    my $cause = $ddtcgi->param('cause');
    $cause =~ s/\'/\'\'/g;
    my $group = $ddtcgi->param('group');
    $group =~ s/\'/\'\'/g;
    my $description = $ddtcgi->param('description');
    $description =~ s/\'/\'\'/g;
    #my $isactive = 'T';
    my $group_count;
    my $cause_count;

    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
    
    my $groupstring = "select count(*) from $SCHEMA.t_cause_group where cause_group = $group ";
    eval {
    	my $sth = $dbh->prepare($groupstring); 
    	$sth->execute();
    	$group_count = $sth->fetchrow_array();
    };
    if ($@) {
    	$errormsg .= "(user $username) Add Cause - Error finding cause group \n";
    	#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Add Cause - Error finding cause group");
    }
    else { 
    	my $causestring = "select count(*) from $SCHEMA.t_cause where cause = '$cause' ";
    	$causestring .= "and cause_group = $group ";
    	eval {
    		my $sth2 = $dbh->prepare($causestring); 
    		$sth2->execute();
    		$cause_count = $sth2->fetchrow_array();
    	};
    	if ($@) {
    		$errormsg .= "(user $username) Add Cause - Error finding cause group \n";
    		#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Add Cause - Error finding cause group");
    	}
    }
    if (!($@)) {
    	if ($group_count != 1) {
    		$statusmsg .= "Cause Group is not valid.  Record was not added.<br>\n";
    	}
    	elsif ($cause_count > 0 ) {$statusmsg .= "This record already exists.  Record was not added.<br>\n";}
    	elsif (($group_count == 1) && ($cause_count == 0)) {
    	
        	my $sqlstring = "INSERT INTO $SCHEMA.$updatetable 
                          (cause, cause_group,description) 
                     VALUES ('$cause', $group, '$description')";
        	eval {
    			my $rc = $dbh->do($sqlstring);
    		};
    		if ($@) {
    			$errormsg .= "(user $username) Add Cause - Error adding cause record \n";
    			#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Add Cause - Error adding cause record");
    			$statusmsg .= "Error inserting Cause record.<br>\n";
    		}
    		else {
    			$errormsg .= "user $username added cause $cause to cause group $group \n";
    			$statusmsg .= "Record added successfully.<br>\n"; 
    			&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username added cause $cause to cause group $group");
    		}
    	}
    }
    else {$statusmsg .= "Error adding Cause record.<br>\n";}
    
    if ($@) {
    	$dbh->rollback;
    	&log_trend_error($dbh,$SCHEMA,'T',$userid,$errormsg);
    }
    else {
    	$dbh->commit;
    	#&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username added cause $cause to cause group $group");
    }
    
    $cgiaction="query";
}

##########################################
if ($cgiaction eq "update_cause") {
##########################################
    # print the sql which will update this table
    my $cause = $ddtcgi->param('cause');
    $cause =~ s/\'/\'\'/g;
    my $group = $ddtcgi->param('group');
    $group =~ s/\'/\'\'/g;
    my $description = $ddtcgi->param('description');
    $description =~ s/\'/\'\'/g;
    #my $isactive = 'T';
    my $cause_count;
    my $rc;
    
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
    
    my $causestring = "select count(*) from $SCHEMA.t_cause where cause = '$cause' ";
    $causestring .= "and cause_group = $group ";
    eval {
    	my $sth2 = $dbh->prepare($causestring); 
    	$sth2->execute();
    	$cause_count = $sth2->fetchrow_array();
    };
    if (!($@)) {
    	if ($cause_count == 0) {$statusmsg = "No record found to update.  Record was not updated.<br>\n";}
        elsif ($cause_count == 1) {
        	my $sqlstring = "UPDATE $SCHEMA.$updatetable 
                             set description = '$description' 
                             WHERE cause = '$cause' and cause_group = $group  ";
            	eval {
            		$rc = $dbh->do($sqlstring);
            	};
            	if ($@) {
            	    	$errormsg .= "(user $username) Update Cause - Error inserting cause \n";
    			#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Update Cause - Error inserting cause");
    			$statusmsg = "Error updating Cause record\n";
        	}
        	elsif ($rc eq '0E0') {
			$statusmsg .= "There is no record to update with Cause = $cause and Cause Group = $group.\n"; 
		}
            	else {	
            		$statusmsg = "Record updated successfully.<br>\n";
            		&log_trend_activity($dbh,$SCHEMA,'F',$userid,"user $username updated cause $cause in cause group $group");
            	}
    	}
    }
    else {$statusmsg .= "Error updating Cause record.\n";}
    
    if ($@) {
    	$dbh->rollback;
    	&log_trend_error($dbh,$SCHEMA,'T',$userid,$errormsg);
    }
    else {
    	$dbh->commit;
    	#&log_trend_activity($dbh,$SCHEMA,'F',$userid,"user $username updated cause $cause in cause group $group");
    }
    
    $cgiaction="query";
}

##########################################
if ($cgiaction eq "delete_cause") {
##########################################
    # print the sql which will update this table
    my $cause = $ddtcgi->param('cause');
    $cause =~ s/\'/\'\'/g;
    my $group = $ddtcgi->param('group');
    $group =~ s/\'/\'\'/g;
    my $description = $ddtcgi->param('description');
    $description =~ s/\'/\'\'/g;
    #my $isactive = 'T';
    my $doc_count;
    my $cause_count;
    my $rc;
    
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
    
    
    my $docstring = "select count(*) from $SCHEMA.t_doc_code where cause = '$cause' ";
    $docstring .= "and cause_group = $group ";
    eval {
    	my $sth = $dbh->prepare($docstring); 
    	$sth->execute();
    	$doc_count = $sth->fetchrow_array();
    };
    if ($@) {
    	$errormsg .= "(user $username) Delete Cause - Error finding cause or cause group in record \n";
        #&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Delete Cause - Error finding cause or cause group in record");
    }
    else { 
    	my $causestring = "select count(*) from $SCHEMA.t_cause where cause = '$cause' ";
        $causestring .= "and cause_group = $group ";
    
    	eval {
    		my $sth2 = $dbh->prepare($causestring); 
    		$sth2->execute();
    		$cause_count = $sth2->fetchrow_array();
    	};
    	if ($@) {
    		$errormsg .= "(user $username) Delete Cause - Error finding cause or cause group \n";
    		#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Delete Cause - Error finding cause or cause group");
    	}
    }
    if (!($@)) {
    	if ($doc_count > 0) {
    		$statusmsg = "There are documents referencing this cause and cause group combination.<br>\n";
    		$statusmsg .= "The documents must be deleted or updated before this record can be deleted.<br>\n"
    	}
    	elsif ($cause_count == 0) {
    		$statusmsg = "No record found to delete.  Record was not deleted.<br>\n";
    	}
    	elsif ($cause_count == 1) {
    		my $sqlstring = "DELETE from $SCHEMA.$updatetable 
                         WHERE cause = '$cause' and cause_group = $group ";
        	eval {
        		$rc = $dbh->do($sqlstring);
    		};
    		if ($@) {
    			$errormsg .= "(user $username) Delete Cause - Error deleting cause record \n";
		    	#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Delete Cause - Error deleting cause record");
		    	$statusmsg .= "Error deleting Cause record.<br>\n";
		}
		elsif ($rc eq '0E0') {
			$statusmsg .= "There is no record to delete with Cause = $cause and Cause Group = $group.\n"; 
		}
		else {
		    	$statusmsg .= "Record deleted successfully.<br>\n"; 
		    	&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username deleted cause $cause from cause group $group");
    		}
    	}
    }
    else {$statusmsg .= "Error deleting Cause record.<br>\n";}
    
    if ($@) {
    	$dbh->rollback;
    	&log_trend_error($dbh,$SCHEMA,'T',$userid,$errormsg);
    }
    else {
    	$dbh->commit;
    	#&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username deleted cause $cause from cause group $group");
    }
    
    $cgiaction="query";
}

##########################################
if ($cgiaction eq "add_causegroup") {
##########################################
    my $group = $ddtcgi->param('group');
    $group =~ s/\'/\'\'/g;
    my $description = $ddtcgi->param('groupdesc');
    $description =~ s/\'/\'\'/g;
    #my $isactive = 'T';
    my $group_count;
    my $groupid;
    
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
        
    my $groupstring = "select count(*) from $SCHEMA.t_cause_group where description = '$description' ";

    eval {
    	my $sth = $dbh->prepare($groupstring); 
    	$sth->execute();
    	$group_count = $sth->fetchrow_array();
    };
    if ($@) {
    	$errormsg .= "(user $username) Add Cause Group - Error getting cause group description \n";
    	#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Add Cause Group - Error getting cause group description");
    	$statusmsg .= "Error adding Cause Group.\n";
    }
    else {
    	if ($group_count > 0) {
    		$statusmsg .= "This description already exists.  The Record was not added to the database.<br>\n";
    	}
    	elsif ($group_count == 0) {
    		eval {
    			$groupid = get_max_id($dbh, $updatetable, "cause_group") + 1;
    		};
    		if (!($@)) {
    			my $sqlstring = "INSERT INTO $SCHEMA.$updatetable 
                          (cause_group, description) 
                     	VALUES ($groupid, '$description')";
                        
                        eval {
        			my $rc = $dbh->do($sqlstring);
        		};
        	}
        
                if ($@) {
                	$errormsg .= "(user $username) Add Cause Group - Error adding cause group \n";
		 	#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Add Cause Group - Error adding cause group");
		 	$statusmsg .= "Error adding Cause Group record.<br>\n";
		}
		else {
		 	$statusmsg .= "Cause Group added successfully.<br>\n"; 
		 	&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username added cause group $description ");
		}
    	}
    }
    
    if ($@) {
    	$dbh->rollback;
    	&log_trend_error($dbh,$SCHEMA,'T',$userid,$errormsg);
    }
    else {
    	$dbh->commit;
    	#&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username added cause group $description ");
    }
    
    $cgiaction="query";
}

##########################################
if ($cgiaction eq "update_causegroup") {
##########################################
    my $group = $ddtcgi->param('group');
    $group =~ s/\'/\'\'/g;
    my $description = $ddtcgi->param('groupdesc');
    $description =~ s/\'/\'\'/g;
    #my $isactive = 'T';
    my $group_count;
    my $idcount;
    my $rc;
    
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    my $groupstring = "select count(*) from $SCHEMA.t_cause_group where description = '$description' ";
    eval {
    	my $sth = $dbh->prepare($groupstring); 
    	$sth->execute();
    	$group_count = $sth->fetchrow_array();
    };
    if ($@) {
    	$errormsg .= "(user $username) Update Cause Group - Error getting cause group description \n";
    	#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Update Cause Group - Error getting cause group description");
    	$statusmsg .= "Error updating Cause Group.<br>\n";
    }
    else {
    	if ($group_count > 0) {
		$statusmsg .= "This description already exists.  The Record was not updated.<br>\n";
    	}
    	elsif ($group_count == 0) {
		my $sqlstring = "UPDATE $SCHEMA.$updatetable 
		      	set description = '$description'  
		 	WHERE cause_group = $group ";
		eval {
			$rc = $dbh->do($sqlstring);
		};
		if ($@) {
			$errormsg .= "(user $username) Update Cause Group - Error adding cause group \n";
			#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Update Cause Group - Error adding cause group");
			$statusmsg .= "Error updating Cause Group record.\n";
		}
		elsif ($rc eq '0E0') {
			$statusmsg .= "There is no Cause Group with ID $group.  No Record to update.\n"; 
		}
		else {
			$statusmsg .= "Cause Group updated successfully.\n"; 
			&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username updated cause group $description ");
		}
    	}
    }
    
    if ($@) {
    	$dbh->rollback;
    	&log_trend_error($dbh,$SCHEMA,'T',$userid,$errormsg);
    }
    else {
    	$dbh->commit;
    	#&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username updated cause group $description ");
    }
    
    $cgiaction="query";
}

##########################################
if ($cgiaction eq "delete_causegroup") {
##########################################
    my $group = $ddtcgi->param('group');
    $group =~ s/\'/\'\'/g;
    my $description = $ddtcgi->param('groupdesc');
    $description =~ s/\'/\'\'/g;
    #my $isactive = 'T';
    my $doc_count;
    my $cause_count;
    my $rc;
    
   $dbh->{AutoCommit} = 0;
   $dbh->{RaiseError} = 1;
   
   my $docstring = "select count(*) from $SCHEMA.t_doc_code where cause_group = $group ";
   
   eval {
   	my $sth = $dbh->prepare($docstring); 
   	$sth->execute();
  	$doc_count = $sth->fetchrow_array();
   };
   if ($@) {
   	$errormsg .= "(user $username) Delete Cause Group - Error getting cause group count \n";
       	#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Delete Cause Group - Error getting cause group count");
       	$statusmsg .= "Error updating Cause Group.\n";
   }
   else {
   	my $causestring = "select count(*) from $SCHEMA.t_cause where cause_group = $group ";
   
   	eval {
   		my $sth2 = $dbh->prepare($causestring); 
   		$sth2->execute();
   		$cause_count = $sth2->fetchrow_array();
   	};
   	if ($@) {
   		$errormsg .= "(user $username) Delete Cause Group - Error getting cause group count \n";
   		#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Delete Cause Group - Error getting cause group count");
       		$statusmsg .= "Error deleting Cause Group.<br>\n";
   	}
   	else {
   		if (($cause_count > 0) || ($doc_count > 0)){
   			$statusmsg = "There are documents referencing this cause group.<br>\n";
    			$statusmsg .= "The documents must be deleted or updated before this record can be deleted.\n";
   		}
  		elsif (($cause_count == 0) && ($doc_count == 0)){
   			my $sqlstring = "DELETE from $SCHEMA.$updatetable 
   		    	WHERE cause_group = $group ";
   
   			eval {
  	 			$rc = $dbh->do($sqlstring);
  			};	
  			if ($@) {
  				$errormsg .= "(user $username) Delete Cause Group - Error deleting cause group \n";
				#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Delete Cause Group - Error deleting cause group");
				$statusmsg .= "Error deleting Cause Group record.\n";
			}
			elsif ($rc eq '0E0') {
				$statusmsg .= "There is no Cause Group with ID $group.  No record to delete.\n"; 
			}
			else {
				$statusmsg .= "Cause Group deleted successfully.\n"; 
				&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username deleted cause group $description ");
			}
		}
   	}
   }
   if ($@) {
   	$dbh->rollback;
   	&log_trend_error($dbh,$SCHEMA,'T',$userid,$errormsg);
   }
   else {
   	$dbh->commit;
   	#&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username deleted cause group $description ");
   }
   
   $cgiaction="query";
}

############################
if ($cgiaction eq "query") {
############################
    my $groupid = (defined($ddtcgi->param('groupid'))) ? $ddtcgi->param('groupid') : "";
    my $groupdesc = (defined($ddtcgi->param('groupdesc'))) ? $ddtcgi->param('groupdesc') : "";
    my $cause = (defined($ddtcgi->param('cause'))) ? $ddtcgi->param('cause') : "";
    my $description = (defined($ddtcgi->param('description'))) ? $ddtcgi->param('description') : "";
    my $group = (defined($ddtcgi->param('group'))) ? $ddtcgi->param('group') : "";

    my $causestring;
    tie my %causehash, "Tie::IxHash" ;
    tie my %grouphash, "Tie::IxHash" ;
    tie my %refhash, "Tie::IxHash";
    my $groupstring;
    my $title;
    my $selection;
    my $paddedkey;
    my $causeid;
    
    if ($groupid) {
    	%causehash = get_lookup_values($dbh, 't_cause', 'cause', "cause || ' - ' || description", "cause_group = $groupid order by cause");
    }
    
    %grouphash = get_lookup_values($dbh, 't_cause_group', 'cause_group', 'description', "1 = 1 order by cause_group");
    
    if ($updatetable eq "t_cause") {
    	$title = "Cause Groups and Causes";
    	%refhash = get_lookup_values($dbh, $updatetable,"cause_group || cause || '   - ' || description", "description", "1 = 1 order by cause_group, cause");
    }
    elsif ($updatetable eq "t_cause_group") {
    	$title = "Current Cause Groups";
    	%refhash = get_lookup_values($dbh, $updatetable, "cause_group || '  ' || description", "description","1 = 1 order by cause_group" );
    }
    
    print<<queryformtop;
    <BR><BR>
    <input name=cgiaction type=hidden value=query>

queryformtop

    print "<table border=1 cellspacing=0 cellpadding=0 align=center width=60% bordercolor=#00008B>\n";
    print "<tr>\n";
   

    print "<td valign=top><br>\n";
    print "	<b>&nbsp;&nbsp;&nbsp;Cause Groups:</b>&nbsp;&nbsp;&nbsp;\n";
    print "<select name=groupid title=\"Select the trend code\" size=1 onChange=temporary(this,'query','$updatetable')>\n"; 	

    foreach my $keys (keys %grouphash) {
	#$paddedkey = lpadzero($keys,2);
	if ($keys == $groupid) {
		print "<option selected value=\"$keys\"> $keys - $grouphash{$keys} </option>\n";
	}
	else {
		print "<option value=\"$keys\"> $keys - $grouphash{$keys} </option>\n";
	}
    }
    print "</select><br><br>\n";
	
   if ($updatetable eq "t_cause") {
	print "	<b>&nbsp;&nbsp;&nbsp;Causes:</b>&nbsp;&nbsp;&nbsp;\n";
	print "<select name=causes title=\"Trend codes\" size=1 onChange=populateCode(this)>&nbsp;&nbsp;&nbsp;\n"; 	
	
	foreach my $keys (keys %causehash) {
		print "<option value=\"$keys\"> $causehash{$keys} </option>\n";
	}
	print "</select><br><br>\n";
	print "</td></tr></table><br>\n";
	print "<table border=0 align=center width=60%>\n";
	print "<tr><td>\n";
	print "	<b>Cause Code:</b>\n";
	print "	&nbsp;<input name=group type=text readonly maxlength=30 size=2 value=$group>\n";
	print "	&nbsp;&nbsp;&nbsp;<b>Description:</b>\n";
    	print "	&nbsp;<input name=groupdesc type=text readonly maxlength=50 size=50 value='$groupdesc'><br>\n";
     	print "	<br>&nbsp;<b>Cause:</b>\n";
	print "	&nbsp;<input name=cause type=text maxlength=30 size=2 value='$cause'>\n";
        print "	&nbsp;&nbsp;&nbsp;<b>Description:</b>\n";
    	print "	&nbsp;<input name=description type=text maxlength=50 size=50 value='$description'><br>\n";
    	print " </td>\n</tr>\n";
    	
    	print "<tr><td align=center><b><font color=red><span id=\"msg\"> $statusmsg </span> </font></b><br>\n";
    	print "<input type=button value=\" Clear \" onClick=clear_cause_form()>\n";
    	print "&nbsp;&nbsp;&nbsp;<input name=add type=submit value=\"  Add  \" onclick=\"document.cause_code_maint.cgiaction.value='add_cause'\">\n";
    	print "&nbsp;&nbsp;&nbsp;<input name=update type=submit value=\"Update\" onclick=\"document.cause_code_maint.cgiaction.value='update_cause'\">\n";
    	print "&nbsp;&nbsp;&nbsp;<input name=delete type=submit value=\"Delete\" onclick=\"document.cause_code_maint.cgiaction.value='delete_cause'\">\n";
    	print "&nbsp;&nbsp;&nbsp;<input  type=button value=\"  Exit  \" onClick=exit()>\n";
    	print "</td>\n";
    }
    elsif ($updatetable eq "t_cause_group") {
    	print "</td></tr></table><br>\n";
    	print "<table border=0 align=center width=60%>\n";
    	print "<tr><td>\n";
    	print "	<b>Cause Group:</b>\n";
    	print "	&nbsp;<input name=group type=text maxlength=30 size=2 value=$group>\n";
    	print "	&nbsp;&nbsp;&nbsp;<b>Description:</b>\n";
        print "	&nbsp;<input name=groupdesc type=text maxlength=50 size=50 value='$groupdesc'><br>\n";
     	
     	print " </td>\n</tr>\n";
    	
    	print "<tr><td align=center><b><font color=red><span id=\"msg\"> $statusmsg </span></font></b><br>\n";
    	print "<input type=button value=\" Clear \" onClick=clear_group_form()>\n";
    	print "&nbsp;&nbsp;&nbsp;<input name=add type=submit value=\"  Add  \" onclick=\"document.cause_code_maint.cgiaction.value='add_causegroup'\">\n";
    	print "&nbsp;&nbsp;&nbsp;<input name=update type=submit value=\"Update\" onclick=\"document.cause_code_maint.cgiaction.value='update_causegroup'\">\n";
    	print "&nbsp;&nbsp;&nbsp;<input name=delete type=submit value=\"Delete\" onclick=\"document.cause_code_maint.cgiaction.value='delete_causegroup'\">\n";
    	print "&nbsp;&nbsp;&nbsp;<input  type=button value=\"  Exit  \" onClick=exit()>\n";
    	print "</td>\n";
    }
    print "</tr>\n";
    print "<tr><td height=15></td></tr>\n";
    print "<tr>\n";
    print "<td valign=top align=center>\n";
    print "	<br><b>$title (reference)</b><br>\n";
    print "    <select name=cause_code_maint readonly size=5>\n";
    foreach my $key (keys %refhash) {
	my $refstring = $key;
	print "<option value=\"$refhash{$key}\" >$refstring\n";
    }
    print "	</select><br>\n";
    print "</td>\n";   
    print "</tr>\n";
    print "</table>\n";
    
    print <<queryformbottom;

    <br>
queryformbottom
}

print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=username type=hidden value=$username>\n";
print "<input name=userid type=hidden value=$userid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";

#disconnect from the database
&trend_disconnect($dbh);


# print html footers.
print "<br><br>\n";

print "</form>\n";
print "</CENTER></body>\n";
print "</html>\n";
