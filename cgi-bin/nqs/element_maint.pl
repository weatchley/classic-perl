#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# $Source $
#
# $Revision: 1.4 $
#
# $Date: 2001/11/20 14:49:57 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: element_maint.pl,v $
# Revision 1.4  2001/11/20 14:49:57  starkeyj
# modfied color and title bar
#
# Revision 1.3  2001/07/09 15:43:27  starkeyj
# changed clear form javascript to reset groups to 0 instead of 1
#
# Revision 1.2  2001/07/09 14:27:52  starkeyj
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
if ($updatetable eq "qa_element") {$title = 'QA Element Maintenance';}
elsif ($updatetable eq "t_code") {$title = 'Trend Code Maintenance';}
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
	if ((e.type == "text") && (e.name != "element")) {
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
			document.$form.group.value = e.options[i].value;
			document.$form.element.value = e.options[i].value;
			var id = e.options[i].value;
			var str = e.options[i].text;
			var index = str.search(/-/i);
			document.$form.elementdesc.value = str.substr(index+2);		
		}
	if (table == 't_code') {
		document.$form.code.value = "";
		document.$form.description.value = "";
	}
	submitForm('element_maint', command, id);

}
function none () {
	submitForm('element_maint', command, id);
	
	
}
function populateCode (e) {
	for (var i=0;i<e.options.length;i++) 
		if (e.options[i].selected) {
			document.$form.code.value = e.options[i].value;
			var str = e.options[i].text;
			var index = str.search(/-/i);
			document.$form.description.value = str.substr(index+2);		
		}
	msg.style.visibility='hidden';			
}
function clear_element_form() {
	document.$form.group.value = 0;
	document.$form.element.value = "";
	document.$form.elementdesc.value = "";
	msg.style.visibility='hidden';	
}
function clear_code_form() {
	document.$form.codes.options.length = 0;
	document.$form.group.value = 0;
	document.$form.element.value = "";
	document.$form.elementdesc.value = "";
	document.$form.code.value = "";
	document.$form.description.value = "";
	msg.style.visibility='hidden';	
}
function exit() {
	submitForm('trend_home', 'menu','');

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

print "<form action=\"$NQSCGIDir/element_maint.pl\" method=post name=element_maint onSubmit=\"return validate(this)\">\n";
my $statusmsg = "";
my $errormsg ="";
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
if ($cgiaction eq "add_trend_code") {
##########################################
    # print the sql which will update this table
    my $code = $ddtcgi->param('code');
    $code =~ s/\'/\'\'/g;
    my $elemnt = $ddtcgi->param('element');
    $elemnt =~ s/\'/\'\'/g;
    my $description = $ddtcgi->param('description');
    $description =~ s/\'/\'\'/g;
    #my $isactive = 'T';
    my $element_count;
    my $code_count;
    
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
    
    my $elementstring = "select count(*) from $SCHEMA.qa_element where element = $elemnt ";
    eval {
    	my $sth = $dbh->prepare($elementstring); 
    	$sth->execute();
    	$element_count = $sth->fetchrow_array();
    };
    if ($@) {
    	$errormsg .= "(user $username) Add Trend Code - Error finding element \n";
        #&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Add Trend Code - Error finding element");
    }
    else { 
    	my $codestring = "select count(*) from $SCHEMA.t_code where code = $code ";
    	$codestring .= "and element = $elemnt ";
	eval {
    		my $sth2 = $dbh->prepare($codestring); 
    		$sth2->execute();
    		$code_count = $sth2->fetchrow_array();
    	};
    	if ($@) {
    		$errormsg .= "(user $username) Add Trend Code - Error finding code count \n";
    		#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Add Trend Code - Error finding code count");
    	}
    }
    if (!($@)) {
    	if ($element_count != 1) {
    		$statusmsg .= "QA Element is not valid.  The record was not added.<br>\n";
    	}
    	elsif ($code_count > 0 ) {
    		$statusmsg .= "This record already exists.  The record was not added.<br>\n";
    	}
    	elsif (($element_count == 1) && ($code_count == 0)) {
        	my $sqlstring = "INSERT INTO $SCHEMA.$updatetable 
                     (code, element,description) 
                     VALUES ('$code', '$elemnt', '$description')";
    		eval {
    			my $rc = $dbh->do($sqlstring);
    		};
    		if ($@) {
    			$errormsg .= "(user $username) Add Trend Code - Error adding trend code \n";
		    	#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Add Trend Code - Error adding trend code");
		    	$statusmsg .= "Error inserting Trend Code record.<br>\n";
		}
		else {
		    	$statusmsg .= "Record added successfully.<br>\n"; 
		    	&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username added trend code $code to element $elemnt");
		}
	}
    }
    else {$statusmsg .= "Error adding Trend Code record.<br>\n";}
    
    if ($@) {
    	$dbh->rollback;
    	&log_trend_error($dbh,$SCHEMA,'T',$userid,$errormsg);
    }
    else {
    	$dbh->commit;
    	#&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username added trend code $code to element $elemnt");
    }
    $cgiaction="query";
}

##########################################
if ($cgiaction eq "update_trend_code") {
##########################################
    # print the sql which will update this table
    my $code = $ddtcgi->param('code');
    $code =~ s/\'/\'\'/g;
    my $elemnt = $ddtcgi->param('element');
    $elemnt =~ s/\'/\'\'/g;
    my $description = $ddtcgi->param('description');
    $description =~ s/\'/\'\'/g;
    #my $isactive = 'T';
    my $code_count;
    
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    my $codestring = "select count(*) from $SCHEMA.t_code where code = $code ";
    $codestring .= "and element = $elemnt ";
    eval {
    	my $sth2 = $dbh->prepare($codestring); 
    	$sth2->execute();
    	$code_count = $sth2->fetchrow_array();
    };
    if (!($@)) {	
    	if ($code_count == 0) {
    		$statusmsg = "No record found to update.  The record was not updated.<br>\n";
    	}
    	elsif ($code_count == 1) {
    		my $sqlstring = "UPDATE $SCHEMA.$updatetable 
                         set description = '$description' 
                         WHERE code = $code and element = $elemnt";
        	eval {
        		my $rc = $dbh->do($sqlstring);
        	};
    		if ($@) {
    			$errormsg .= "(user $username) Update Trend Code - Error updating trend code \n";
		    	#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Update Trend Code - Error updating trend code");
		    	$statusmsg = "Error updating Trend Code record\n";
		}
		else {	
		        $statusmsg = "Record updated successfully.<br>\n";
		        &log_trend_activity($dbh,$SCHEMA,'F',$userid,"user $username updated trend code $code in element $elemnt");
		}
	}
    }
    else {$statusmsg .= "Error updating Trend Code record.\n";}
    
    if ($@) {
    	$dbh->rollback;
    	&log_trend_error($dbh,$SCHEMA,'T',$userid,$errormsg);
    }
    else {
    	$dbh->commit;
    	#&log_trend_activity($dbh,$SCHEMA,'F',$userid,"user $username updated trend code $code in element $elemnt");
    }
    $cgiaction="query";
}

##########################################
if ($cgiaction eq "delete_trend_code") {
##########################################
    # print the sql which will update this table
    my $code = $ddtcgi->param('code');
    $code =~ s/\'/\'\'/g;
    my $elemnt = $ddtcgi->param('element');
    $elemnt =~ s/\'/\'\'/g;
    my $description = $ddtcgi->param('description');
    $description =~ s/\'/\'\'/g;
    #my $isactive = 'T';
    my $doc_count;
    my $code_count;
    
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
    
    my $docstring = "select count(*) from $SCHEMA.t_doc_code where code = $code ";
    $docstring .= "and element = $elemnt ";
    eval {
    	my $sth = $dbh->prepare($docstring); 
    	$sth->execute();
    	$doc_count = $sth->fetchrow_array();
    };
    if ($@) {
    	$errormsg .= "(user $username) Delete Trend Code - Error finding code count \n";
        #&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Delete Trend Code - Error finding code count");
    }
    else { 
    	my $codestring = "select count(*) from $SCHEMA.t_code where code = $code ";
    	$codestring .= "and element = $elemnt ";
    	eval {
    		my $sth2 = $dbh->prepare($codestring); 
    		$sth2->execute();
    		$code_count = $sth2->fetchrow_array();
    	};
    	if ($@) {
    		$errormsg .= "(user $username) Delete Trend Code - Error finding code or element count \n";
    		#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Delete Trend Code - Error finding code or element count");
    	}
    }
    if (!($@)) {
    	if ($doc_count > 0) {
    		$statusmsg = "There are documents referencing this code and element combination.<br>\n";
    		$statusmsg .= "The documents must be deleted or updated before this record can be deleted.<br>\n"
    	}
   	 elsif ($code_count == 0) {
    		$statusmsg = "No record found to delete.  The record was not deleted.<br>\n";
    	}
    	elsif ($code_count == 1) {
    		my $sqlstring = "DELETE from $SCHEMA.$updatetable 
                         WHERE code = $code and element = $elemnt";
        	eval {
        		my $rc = $dbh->do($sqlstring);
        	};
    		if ($@) {
    			$errormsg .= "(user $username) Delete Trend Code - Error deleting trend code record \n";
			#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Delete Trend Code - Error deleting trend code record");
			$statusmsg .= "Error deleting Cause record.<br>\n";
		}
		else {
			$statusmsg .= "Record deleted successfully.<br>\n"; 
			&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username deleted trend code $code from element $elemnt");
		}
	}
    }
    else {$statusmsg .= "Error deleting Trend Code record.<br>\n";}
    
    if ($@) {
    	$dbh->rollback;
    	&log_trend_error($dbh,$SCHEMA,'T',$userid,$errormsg);
    }
    else {
    	$dbh->commit;
    	#&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username deleted trend code $code from element $elemnt");
    }
    $cgiaction="query";
}

##########################################
if ($cgiaction eq "add_element") {
##########################################
    my $elemnt = $ddtcgi->param('element');
    $elemnt =~ s/\'/\'\'/g;
    my $description = $ddtcgi->param('elementdesc');
    $description =~ s/\'/\'\'/g;
    #my $isactive = 'T';
    my $element_count;
    
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;
        
    my $elementstring = "select count(*) from $SCHEMA.qa_element where description = '$description' ";
    eval {
    	my $sth = $dbh->prepare($elementstring); 
    	$sth->execute();
    	$element_count = $sth->fetchrow_array();
    };
    if ($@) {
    	$errormsg .= "(user $username) Add Element - Error getting element description \n";
        #&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Add Element - Error getting element description");
        $statusmsg .= "Error adding Element.\n";
    }
    else {
    	if ($element_count > 0) {
    		$statusmsg .= "This description already exists.  The record was not added to the database.<br>\n";
    	}
    	elsif ($element_count == 0) {
    		eval {
    			$elemnt = get_max_id($dbh, $updatetable, "element") + 1;
    		};
    		if (!($@)) {
    			my $sqlstring = "INSERT INTO $SCHEMA.$updatetable 
                          	(element, description) 
                     		VALUES ($elemnt, '$description')";
        		eval {           
        			my $rc = $dbh->do($sqlstring);
        		};
                }        
		if ($@) {
			$errormsg .= "(user $username) Add Element - Error adding element \n";
		     	#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Add Element - Error adding element");
		     	$statusmsg .= "Error adding Cause Group record.<br>\n";
		}
		else {
		     	$statusmsg .= "Cause Group added successfully.<br>\n"; 
		     	&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username added element $description ");
		}
	}
    }
    
    if ($@) {
    	$dbh->rollback;
    	&log_trend_error($dbh,$SCHEMA,'T',$userid,$errormsg);
    }
    else {
    	$dbh->commit;
    	#&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username added element $description ");
    }
    $cgiaction="query";
}

##########################################
if ($cgiaction eq "update_element") {
##########################################
    my $elemnt = $ddtcgi->param('element');
    $elemnt =~ s/\'/\'\'/g;
    my $description = $ddtcgi->param('elementdesc');
    $description =~ s/\'/\'\'/g;
    #my $isactive = 'T';
    my $element_count;
    
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    my $elementstring = "select count(*) from $SCHEMA.qa_element where description = '$description' ";
    eval {
    	my $sth = $dbh->prepare($elementstring); 
    	$sth->execute();
    	$element_count = $sth->fetchrow_array();
    };
    if ($@) {
    	$errormsg .= "(user $username) Update Element - Error getting count for element description \n";
    	#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Update Element - Error getting count for element description");
    	$statusmsg .= "Error updating Element.<br>\n";
    }
    else {
    	if ($element_count > 0) {
		$statusmsg .= "This description already exists.  The record was not updated.<br>\n";
    	}
    	elsif ($element_count == 0) {
		my $sqlstring = "UPDATE $SCHEMA.$updatetable 
		      	set description = '$description'  
		 	WHERE element = $elemnt ";

		eval {
			my $rc = $dbh->do($sqlstring);
		};
		if ($@) {
			$errormsg .= "(user $username) Update Element - Error updating element \n";
			#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Update Element - Error updating element");
			$statusmsg .= "Error updating Element.<br>\n";
		}
		else {
			$statusmsg .= "Element updated successfully.<br>\n"; 
			&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username updated element $description ");
		}
    	}
    }
    
    if ($@) {
    	$dbh->rollback;
    	&log_trend_error($dbh,$SCHEMA,'T',$userid,$errormsg);
    }
    else {
    	$dbh->commit;
    	#&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username updated element $description ");
    }
    $cgiaction="query";
}

##########################################
if ($cgiaction eq "delete_element") {
##########################################
    my $elemnt = $ddtcgi->param('element');
    $elemnt =~ s/\'/\'\'/g;
    my $description = $ddtcgi->param('elementdesc');
    $description =~ s/\'/\'\'/g;
    #my $isactive = 'T';
    my $doc_count;
    my $code_count;
    
   $dbh->{AutoCommit} = 0;
   $dbh->{RaiseError} = 1;
   
   my $docstring = "select count(*) from $SCHEMA.t_doc_code where element = $elemnt ";
   eval {
   	my $sth = $dbh->prepare($docstring); 
   	$sth->execute();
  	my $doc_count = $sth->fetchrow_array();
   };
   if ($@) {
   	$errormsg .= "(user $username) Delete Element - Error getting element count \n";
       	#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Delete Element - Error getting element count");
        $statusmsg .= "Error updating Cause Group.<br>\n";
   }
   else {
   	my $codestring = "select count(*) from $SCHEMA.t_code where element = $elemnt ";
      	eval {
   		my $sth2 = $dbh->prepare($codestring); 
   		$sth2->execute();
   		my $code_count = $sth2->fetchrow_array();
   	};
	if ($@) {
		$errormsg .= "(user $username) Delete Element - Error getting element count \n";
	   	#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Delete Element - Error getting element count");
	       	$statusmsg .= "Error deleting Element.<br>\n";
	}
   	else {
   
   		if (($code_count > 0) || ($doc_count > 0)){
   			$statusmsg = "There are documents referencing this element.<br>\n";
			$statusmsg .= "The documents must be deleted or updated before this record can be deleted.<br>\n"
   		}
   		elsif (($code_count == 0) && ($doc_count == 0)){
   			my $sqlstring = "DELETE from $SCHEMA.$updatetable 
   		    		WHERE element = $elemnt ";
   
   			eval {
  	 			my $rc = $dbh->do($sqlstring);
  	 		};  
     			if ($@) {
     				$errormsg .= "(user $username) Delete Element - Error deleting element \n";
   				#&log_trend_error($dbh,$SCHEMA,'T',$userid,"(user $username) Delete Element - Error deleting element");
   				$statusmsg .= "Error deleting Element record.<br>\n";
   			}
   			else {
   				$statusmsg .= "Element deleted successfully.<br>\n"; 
   				&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username deleted element $elemnt ");
   			}
   		}
      	}
   }
   
   if ($@){
   	$dbh->rollback;
   	&log_trend_error($dbh,$SCHEMA,'T',$userid,$errormsg);
   }
   else {
   	$dbh->commit;
   	#&log_trend_activity($dbh,$SCHEMA,'T',$userid,"user $username deleted element $elemnt ");
   }
   $cgiaction="query";
}

############################
if ($cgiaction eq "query") {
############################
    my $elementid = (defined($ddtcgi->param('group'))) ? $ddtcgi->param('group') : "";
    my $elementdesc = (defined($ddtcgi->param('elementdesc'))) ? $ddtcgi->param('elementdesc') : "";
    my $code = (defined($ddtcgi->param('elementdesc'))) ? $ddtcgi->param('code') : "";
    my $description = (defined($ddtcgi->param('description'))) ? $ddtcgi->param('description') : "";
    my $element = (defined($ddtcgi->param('element'))) ? $ddtcgi->param('element') : "";

    my $codestring;
    tie my %codehash, "Tie::IxHash" ;
    tie my %grouphash, "Tie::IxHash" ;
    tie my %elementhash, "Tie::IxHash";
    my $groupstring;
    my $title;
    my $selection;
    my $paddedkey;
    my $codeid;
    
   
    if ($elementid) {
    	%elementhash = get_lookup_values($dbh, 't_code', 'code', "code || ' - ' || description", "element = $elementid order by code");
    }
    
    %grouphash = get_lookup_values($dbh, 'qa_element', 'element', 'description', "1 = 1 order by element");
    
    if ($updatetable eq "t_code") {
    	$title = "QA Elements and Trend Codes";
    	%codehash = get_lookup_values($dbh, $updatetable,"lpad(element,2,0) || code || '   - ' || description", "description", "1 = 1 order by element, code");
    }
    elsif ($updatetable eq "qa_element") {
    	$title = "Current QA Elements";
    	%codehash = get_lookup_values($dbh, $updatetable, "element || '  ' || description", "description","1 = 1 order by element" );
    }
    
    print<<queryformtop;
    <BR><BR>
    <input name=cgiaction type=hidden value=query>

queryformtop

    print "<table border=1 cellspacing=0 cellpadding=0 align=center width=60% bordercolor=#00008B>\n";
    print "<tr>\n";
   

    print "<td valign=top><br>\n";
    print "	<b>&nbsp;&nbsp;&nbsp;QA Elements:</b>&nbsp;&nbsp;&nbsp;\n";
    print "<select name=group title=\"Select the trend code\" size=1 onChange=temporary(this,'query','$updatetable')>\n"; 	

    foreach my $keys (keys %grouphash) {
	$paddedkey = lpadzero($keys,2);
	if ($keys == $elementid) {
		print "<option selected value=\"$keys\"> $paddedkey - $grouphash{$keys} </option>\n";
	}
	else {
		print "<option value=\"$keys\"> $paddedkey - $grouphash{$keys} </option>\n";
	}
    }
    print "</select><br><br>\n";
	
   if ($updatetable eq "t_code") {
	print "	<b>&nbsp;&nbsp;&nbsp;Trend Codes:</b>&nbsp;&nbsp;&nbsp;\n";
	print "<select name=codes title=\"Trend codes\" size=1 onChange=populateCode(this)>&nbsp;&nbsp;&nbsp;\n"; 	
	
	foreach my $keys (keys %elementhash) {
		print "<option value=\"$keys\"> $elementhash{$keys} </option>\n";
	}
	print "</select><br><br>\n";
	print "</td></tr></table><br>\n";
	print "<table border=0 align=center width=60%>\n";
	print "<tr><td>\n";
	print "	<b>QA Element:</b>\n";
	print "	&nbsp;<input name=element type=text maxlength=30 size=2 value='$element'>\n";
	print "	&nbsp;&nbsp;&nbsp;<b>Description:</b>\n";
    	print "	&nbsp;<input name=elementdesc type=text readonly maxlength=50 size=50 value='$elementdesc'><br>\n";
     	print "	<br>&nbsp;<b>Trend Code:</b>\n";
	print "	&nbsp;<input name=code type=text maxlength=30 size=2 value=$code>\n";
        print "	&nbsp;&nbsp;&nbsp;<b>Description:</b>\n";
    	print "	&nbsp;<input name=description type=text maxlength=50 size=50 value='$description'><br>\n";
    	print " </td>\n</tr>\n";
    	
    	print "<tr><td align=center><b><font color=red><span id=\"msg\"> $statusmsg </span></font></b><br>\n";
    	print "<input type=button onClick=clear_code_form() value=\" Clear \">\n";
    	print "&nbsp;&nbsp;&nbsp;<input name=add type=submit value=\"  Add  \" onclick=\"document.element_maint.cgiaction.value='add_trend_code'\">\n";
    	print "&nbsp;&nbsp;&nbsp;<input name=update type=submit value=\"Update\" onclick=\"document.element_maint.cgiaction.value='update_trend_code'\">\n";
    	print "&nbsp;&nbsp;&nbsp;<input name=delete type=submit value=\"Delete\" onclick=\"document.element_maint.cgiaction.value='delete_trend_code'\">\n";
    	print "&nbsp;&nbsp;&nbsp;<input  type=button value=\"  Exit  \" onClick=exit()>\n";
    	print "</td>\n";
    }
    elsif ($updatetable eq "qa_element") {
    	print "</td></tr></table><br>\n";
    	print "<table border=0 align=center width=60%>\n";
    	print "<tr><td>\n";
    	print "	<b>QA Element:</b>\n";
    	print "	&nbsp;<input name=element type=text maxlength=30 size=2 value='$element'>\n";
    	print "	&nbsp;&nbsp;&nbsp;<b>Description:</b>\n";
        print "	&nbsp;<input name=elementdesc type=text maxlength=50 size=50 value='$elementdesc'><br>\n";
     	
     	print " </td>\n</tr>\n";
    	
    	print "<tr><td align=center><b><font color=red><span id=\"msg\"> $statusmsg </span></font></b><br>\n";
    	print "<input type=button value=\" Clear \" onClick=clear_element_form()>\n";
    	print "&nbsp;&nbsp;&nbsp;<input name=add type=submit value=\"  Add  \" onclick=\"document.element_maint.cgiaction.value='add_element'\">\n";
    	print "&nbsp;&nbsp;&nbsp;<input name=update type=submit value=\"Update\" onclick=\"document.element_maint.cgiaction.value='update_element'\">\n";
    	print "&nbsp;&nbsp;&nbsp;<input name=delete type=submit value=\"Delete\" onclick=\"document.element_maint.cgiaction.value='delete_element'\">\n";
    	print "&nbsp;&nbsp;&nbsp;<input  type=button value=\"  Exit  \" onClick=exit()>\n";
    	print "</td>\n";
    }
    print "</tr>\n";
    print "<tr><td height=15></td></tr>\n";
    print "<tr>\n";
    print "<td valign=top align=center>\n";
    print "	<br><b>$title (reference)</b><br>\n";
    print "    <select name=element_maint readonly size=5>\n";
    foreach my $key (keys %codehash) {
	my $codestring = $key;
	print "<option value=\"$codehash{$key}\">$codestring\n";
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
