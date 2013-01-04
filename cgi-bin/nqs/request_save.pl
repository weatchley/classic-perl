#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/nqs/perl/RCS/request.pl,v $
#
# $Revision: 1.11 $
#
# $Date: 2002/09/10 23:48:43 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: request.pl,v $
# Revision 1.11  2002/09/10 23:48:43  starkeyj
# modified title to display 'Surveillance Request Schedule' - bug fix
#
# Revision 1.10  2002/09/10 00:59:42  starkeyj
# modified format of request ID and also format of link to surveillance generated
# from a request - SCR 44
#
# Revision 1.9  2002/03/28 23:14:44  starkeyj
# bug fix - added validation to requestor name field
#
# Revision 1.8  2002/01/16 21:06:33  starkeyj
# added functionality to enter a supplier as well as an organization on a surveillance request
#
# Revision 1.7  2001/12/03 21:12:56  starkeyj
# added 0 to location and organization list in get_org_locs function
#
# Revision 1.6  2001/11/27 15:32:00  starkeyj
# aesthetic changes - centering, font sizes, etc.
#
# Revision 1.5  2001/11/09 01:20:50  starkeyj
# took out alert messages i put in on last revision when testing
#
# Revision 1.4  2001/11/08 21:18:47  starkeyj
# javascript error on form validation - changed field value from fy to fy.value
#
# Revision 1.3  2001/11/02 22:42:09  starkeyj
# added form verification and activity and error logs
#
# Revision 1.2  2001/10/22 17:56:36  starkeyj
# no change, user error with RCS
#
# Revision 1.1  2001/10/19 23:32:19  starkeyj
# Initial revision
#
#
# Revision: $
#
 

use OQA_specific qw(:Functions);
use NQS_Header qw(:Constants);
use OQA_Utilities_Lib qw(:Functions);
use OQA_Widgets qw(:Functions);

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
my $userid = defined($NQScgi->param("userid")) ? $NQScgi->param("userid") : 0;
my $schema = defined($NQScgi->param("schema")) ? $NQScgi->param("schema") : "None";
my $Server = defined($NQScgi->param("server")) ? $NQScgi->param("server") : $NQSServer;
my $pagetitle = $NQScgi->param('pagetitle');
my $cgiaction = $NQScgi->param('cgiaction');

my $dbh = &NQS_connect();
#$userid = get_userid($dbh, $username);
my %userprivhash = &get_user_privs($dbh,$userid);

print <<END_of_Multiline_Text;
Content-type: text/html


<HTML>
<HEAD>

<script src=$NQSJavaScriptPath/utilities.js></script>
<Title>Surveillance Request Schedule</Title>

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
      doSetTextImageLabel('Surveillance Request');
  //-->
</script>

<script language="JavaScript1.1">
  <!--
   
  function checkDate(val,e) {
		var valid = 1;
		if (val != '') {
			valid =  validateDate2(val);
		}
		if (!valid) {
			e.focus();
		}
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
   //   var disapproved = false;
      var name = "";
	  	
     for (var i=0; i<f.length; i++) {
	  	var e = f.elements[i]; 
  	
// save - will be used when the approval process is added

//	  if (e.type == "radio") {
//	  	if ((!f.approval[0].checked) && (!f.approval[1].checked)) {	
//	  		empty_fields += "\\n     Approved/Disapproved";
//	  		i++;
//	  	}
	  	
//	  	else if (f.approval[1].checked) {	
//	  		disapproved = true;
//	  	}
	  	
//	  }
//else	  
	  if ((e.type == "text") || (e.type == "textarea") || (e.type == "select-one")) {
            if ((e.value == null) || (e.value == "") || (isBlank(e.value))) {
            	if (e.name == "requested") {
            		name = "Preferred Surveillance Date";
            	}
            	if (e.name == "reason") {
					   name = "Reason for Surveillance";
            	}
            	if (e.name == "requestor") {
					   name = "Requestor Name";
            	}
	       		empty_fields += "\\n     " + name;
	       		 continue;
            }
	  }
  }     
      if (!empty_fields) {
        submitRequest(f.fy.value);
     		//   return true;
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
   
  //-->
</script>
<script language=javascript><!--

function submitForm (script, command, id) {
   
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'workspace';
    document.$form.submit();
}
function prescreen (id, command) {                          
 
    submitForm('request', command, id);
}
function approve (id, command) {     

    submitForm('request', command, id);
}
function submitActive (id, fy) {     
	document.$form.fy.value = fy;
	document.$form.id.value = id;
	submitForm('request', 'approve_request', 0);
}
function submitView (id, fy, srid, sid) {   
	document.$form.fy.value = fy;
	document.$form.id.value = id;
	document.$form.requestid_display.value = srid;
	document.$form.surveillanceid_display.value = sid;
	submitForm('request', 'active_request', 0);
}
function updateRequest (script, fy2) {    
	document.$form.action = '$path' + script + '.pl';
	document.$form.cgiaction.value = 'update_request';
	document.$form.fy2.value = fy2;
	document.$form.target = 'control';
	document.$form.submit();
}
function deleteRequest (script, fy2) {    
	document.$form.action = '$path' + script + '.pl';
	document.$form.cgiaction.value = 'delete_request';
	document.$form.fy2.value = fy2;
	document.$form.target = 'control';
	document.$form.submit();
}
function submitRequest (fy) {
 	document.$form.action = '$path' +  'request.pl';
 	document.$form.cgiaction.value = 'add_request';
 	document.$form.fy.value = fy;
 //	document.$form.target = 'control';
 	document.$form.submit();
}
function assignSurveillance (script,rid,issuedto,issuedby,fy2) { 
	document.$form.action = '$path' + script + '.pl';
	document.$form.cgiaction.value = 'assign_surveillance';
	document.$form.rid.value = rid;
	document.$form.issuedto.value = issuedto;
	document.$form.issuedby.value = issuedby;
	document.$form.fy2.value = fy2;
   document.$form.target = 'workspace';
	document.$form.submit();
}
function show_int_ext (int_ext) {   
   if (int_ext == 'E') {
		orgs.style.display = 'none';
		supplier.style.display = 'block';
	}
	else {
		orgs.style.display = 'block';
		supplier.style.display = 'none';
	}
}
function requeryRequest (fy2) {    
   document.request.fy2.value = fy2;
	submitForm('request', 'browse_requests', 0);
}
function submitApproval () { 
alert ("submit Approval");
// document.$form.fy.value = fy;
// document.$form.id.value = id;
// submitForm('request', 'approve_request', 0);
}
function checkLength(val,e) {
	var maxlen;
	if (e.name == "reason") {
		maxlen = 399;
	}
	else if (e.name == "detail") {
		maxlen = 999;
	}
	var len = val.length;
	var diff = len - maxlen;
	if (diff > 0) {
		alert ("The text you have entered is " + diff + " characters too long.");
		e.focus();
	}
     
  }
function nextrecord(id) {
	if (id == 2) {
		record2.style.visibility='visible';	
	}
	if (id == 3) {
		record3.style.visibility='visible';	
	}

}
 

//-->
</script>

</HEAD>

<Body background=$NQSImagePath/background.gif text=#000099>
<center>
END_of_Multiline_Text

print <<FORM2;
	<form action="$NQSCGIDir/request.pl" method=post name=request onSubmit=\"return validate(this)\">
	<input type=hidden name=username value=$username>
	<input type=hidden name=userid value=$userid>
	<input type=hidden name=schema value=$schema>
	<input type=hidden name=cgiaction value=$cgiaction>


FORM2



############################
sub select_org_locs_dynamic {
############################
    my ($srid,$fy) = @_;
    my @locresults = get_locations($dbh);
    tie my %orghash, "Tie::IxHash";
    tie my %lochash, "Tie::IxHash";
    tie my %selectedhash, "Tie::IxHash";
    my $key;
    my $loc;
    my $orgselect;
    my $locselect;
    my $recordnum;
    my $spannum;
    my $spanstyle;
    my $i=1;
    
    %orghash = get_lookup_values($dbh, 'organizations', 'id', 'abbr');
    foreach my $array_ref (@locresults) { 
		 $loc = "";
		 if (@$array_ref[0]) {$loc .= @$array_ref[0] . ', ';}
		 if (@$array_ref[1]) {$loc .= @$array_ref[1] . ', ';}
		 if (@$array_ref[2]) {$loc .= @$array_ref[2];}
		 if (@$array_ref[3] ne 'USA' && @$array_ref[3] ne '' ) {$loc .=  @$array_ref[3];}
		 $lochash{$loc} = @$array_ref[4] ;
    }
	
	 my $sqlstring = "select id, organization_id, location_id ";
	 $sqlstring .= "from $schema.request_org_loc ";
	 $sqlstring .= "where fiscal_year = $fy and request_id = $srid order by id ";
	 
	 my $csr = $dbh->prepare($sqlstring);
	 $csr->execute;
	 
	 print "<tr><td><table border=0 width=100% align=center>\n";
	 print "<tr><td align=left width=45%><b>Organizations</b></td><td align=left width=45%><b>Locations</b></td><td>&nbsp;</td></tr>\n";
	 print "</table></td><tr>\n";
	 while (my @values = $csr->fetchrow_array) {
	 	$orgselect = "org" . $i ;
	 	$locselect = "loc" . $i ;
	 	$recordnum = "record" . $i ;
	 	$spannum = "span" . $i ;
	 	if ($i == 1) {$spanstyle= " Style=Visibility:visible; "; }
	 	else {$spanstyle= " Style=Visibility:hidden; "; }
	 	print "<tr><td><span id=\"$recordnum\" $spanstyle><table border=1 width=100% align=center>\n";
    	print "<tr><td width=45%><select name=$orgselect size=1>\n";
    	print "<option value=0>\n";
    	foreach $key (keys %orghash) {
			if ($key == $values[1]){
				print "<option selected value=\"$key\">$orghash{$key}\n";
			}
	      else {
				print "<option value=\"$key\">$orghash{$key}\n";
			}
    	}
    	print "</select></td>\n<td width=45%><select name=$locselect size=1>\n";
    	print "<option value=0>\n";
    	foreach $key (keys %lochash) {
			if ($lochash{$key} == $values[2]){
				print "<option selected value=\"$lochash{$key}\">$key\n";
			}
			else {
				print "<option value=\"$lochash{$key}\">$key\n";
			}
		}
    	print "</select></td>\n<td>";
    	$i++;
    	print "<input type=button onClick=nextrecord($i); value=\"+\"></td></tr>\n";
    	print "</table></span></td></tr>\n";
    }
    
    for (my $j=$i;$j<4;$j++) {
    	$orgselect = "org" . $j ;
		$locselect = "loc" . $j ;
		$recordnum = "record" . $j ;
		$spannum = "span" . $j ;
		print "<tr><td><span id=\"$recordnum\" Style=Visibility:hidden;><table border=1 width=100% align=center>\n";
		print "<tr><td width=45%><select name=$orgselect size=1>\n";
		print "<option value=0>\n";
		foreach $key (keys %orghash) {
			print "<option value=\"$key\">$orghash{$key}\n";
		}
		print "</select></td>\n<td width=45%><select name=$locselect size=1>\n";
		print "<option value=0>\n";
		foreach $key (keys %lochash) {
			print "<option value=\"$lochash{$key}\">$key\n";
		}
		print "</select></td>\n<td>";
		print "<input type=button onClick=nextrecord($j+1); value=\"+\"></td></tr>\n";
    	print "</table></span></td></tr>\n";
    }
    
}
############################
sub select_org_locs {
############################
    my ($srid,$fy,$disabled) = @_;
    my @locresults = get_locations2($dbh,'request',$srid,$fy);
    tie my %orghash, "Tie::IxHash";
    tie my %lochash, "Tie::IxHash";
    tie my %selectedhash, "Tie::IxHash";
    my $key;
    my $loc;
    my $orgselect;
    my $locselect;
    my $i=1;
    my $lookup;
	 my $value;
    my @values;
    
    if (!($fy)) {$fy = 50;}
	 if (!($srid)) {$srid = 0;}
	 
	 my $orgstring = "select id, abbr from $schema.organizations  ";
	 $orgstring .= "where surveillance_active = 'T' or id in (select organization_id ";
	 $orgstring .= "from request_org_loc where fiscal_year = $fy and request_id = $srid) ";
	 $orgstring .= "order by abbr";

	 my $csr = $dbh->prepare($orgstring);
	 # execute or run the query
	 $csr->execute;

	 while (@values = $csr->fetchrow_array) {
		($lookup, $value) = @values;
		$orghash{$lookup} = $value;
	 }  

	  # free up the generated 'cursor'
 	 $csr->finish;
 
 
    foreach my $array_ref (@locresults) { 
		 $loc = "";
		 if (@$array_ref[0]) {$loc .= @$array_ref[0] . ', ';}
		 if (@$array_ref[1]) {$loc .= @$array_ref[1] . ', ';}
		 if (@$array_ref[2]) {$loc .= @$array_ref[2];}
		 if (@$array_ref[3] ne 'USA' && @$array_ref[3] ne '' ) {$loc .=  @$array_ref[3];}
		 $lochash{$loc} = @$array_ref[4] ;
    }
	
	 
	 my $sqlstring = "select id, organization_id, location_id ";
	 $sqlstring .= "from $schema.request_org_loc ";
	 $sqlstring .= "where fiscal_year = $fy and request_id = $srid order by id ";
	 
	 my $csr2 = $dbh->prepare($sqlstring);
	 $csr2->execute;
	 
	 print "<tr><td><table border=1 width=100% align=center>\n";
	 print "<tr><td align=left width=50%><b>Organizations</b></td><td align=left width=50%><b>Locations</b></td></tr>\n";
	 print "</td></tr>\n";
	 while (my @values2 = $csr2->fetchrow_array) {
	 	$orgselect = "org" . $i ;
	 	$locselect = "loc" . $i ;
	 	#print "<tr><td><table border=1 width=100% align=center>\n";
    	print "<tr><td width=50%><select name=$orgselect size=1 $disabled>\n";
    	print "<option value=0>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
    	foreach $key (keys %orghash) {
			if (defined ($values2[1]) && $key == $values2[1]){
				print "<option selected value=\"$key\">$orghash{$key}\n";
			}
	      else {
				print "<option value=\"$key\">$orghash{$key}\n";
			}
    	}
    	print "</select></td>\n<td width=50%><select name=$locselect size=1 $disabled>\n";
    	print "<option value=0>\n";
    	foreach $key (keys %lochash) {
			if ($lochash{$key} == $values2[2]){
				print "<option selected value=\"$lochash{$key}\">$key\n";
			}
			else {
				print "<option value=\"$lochash{$key}\">$key\n";
			}
		}
    	print "</select></td></tr>\n";
    	#print "</table></td></tr>\n";
    	$i++;
    }
    
    for (my $j=$i;$j<4;$j++) {
    	$orgselect = "org" . $j ;
		$locselect = "loc" . $j ;
		#print "<tr><td><table border=1 width=90% align=center>\n";
		print "<tr><td width=50%><select name=$orgselect size=1 $disabled>\n";
		print "<option value=0>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
		foreach $key (keys %orghash) {
			print "<option value=\"$key\">$orghash{$key}\n";
		}
		print "</select></td>\n<td width=50%><select name=$locselect size=1 $disabled>\n";
		print "<option value=0>\n";
		foreach $key (keys %lochash) {
			print "<option value=\"$lochash{$key}\">$key\n";
		}
		print "</select></td></tr>\n";
    	#print "</table></td></tr>\n";
    }
    print "</table></td></tr>\n";
    
}
############################
sub select_supplier_locs {
############################
    my ($rid,$fy,$disabled) = @_;
    my @locresults = get_locations2($dbh,'request',$rid,$fy);
    tie my %supplierhash, "Tie::IxHash";
    tie my %lochash, "Tie::IxHash";
    tie my %selectedhash, "Tie::IxHash";
    my $key;
    my $supplierloc;
    my $supplierselect;
    my $locselect;
    my $i=1;
    my $lookup;
	 my $value;
    my @values;
    
    if (!$rid) {$rid = 0;}
    #if (!$fy) {$fy = 50;}
    my $supplierstring = "select id, company_name from $schema.qualified_supplier  ";
    $supplierstring .= "where surveillance_active = 'T' or id in (select supplier_id ";
    $supplierstring .= "from request_org_loc where fiscal_year = $fy and request_id = $rid) ";
    $supplierstring .= "order by company_name";

    my $csr = $dbh->prepare($supplierstring);
    # execute or run the query
    $csr->execute;

    while (@values = $csr->fetchrow_array) {
	 	($lookup, $value) = @values;
	 	$supplierhash{$lookup} = $value;
    }  

    # free up the generated 'cursor'
    $csr->finish;
    
    
    foreach my $array_ref (@locresults) { 
		 $supplierloc = "";
		 if (@$array_ref[0]) {$supplierloc .= @$array_ref[0] . ', ';}
		 if (@$array_ref[1]) {$supplierloc .= @$array_ref[1] . ', ';}
		 if (@$array_ref[2]) {$supplierloc .= @$array_ref[2];}
		 if (@$array_ref[3] ne 'USA' && @$array_ref[3] ne '' ) {$supplierloc .=  @$array_ref[3];}
		 $lochash{$supplierloc} = @$array_ref[4] ;
    }
	 print "<tr><td><table border=1 width=500 cellpadding=3 cellspacing=0 rules=none bordercolor=gray>\n";
	 print "<tr><td align=left width=50%><b>Supplier</b></td><td align=left width=50%><b>Locations</b></td></tr>\n";
	 if ($rid) {
	 	my $sqlstring = "select id, supplier_id, location_id ";
	 	$sqlstring .= "from $schema.request_org_loc ";
	 	$sqlstring .= "where fiscal_year = $fy and request_id = $rid order by id ";
	 
	 	my $csr = $dbh->prepare($sqlstring);
	 	$csr->execute;
	 
	 	while (my @values = $csr->fetchrow_array) {
	 		$locselect = "supplierloc" . $i ;
	 		if ($i == 1) {
    			print "<tr><td width=100% align=left><select name=supplier size=1 $disabled>\n";
    			print "<option value=0>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
				print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
				print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
				print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
    			foreach $key (keys %supplierhash) {
					if ($values[1] && $key == $values[1]){
						print "<option selected value=\"$key\">$supplierhash{$key}\n";
					}
	      		else {
						print "<option value=\"$key\">$supplierhash{$key}\n";
					}
    			}
    			print "</select></td>\n";
    		}
    		else {
    			print "<tr><td width=100% align=left>&nbsp;</td>\n";
    		}
    		print "<td width=100%><select name=$locselect size=1 $disabled>\n";
    		print "<option value=0>\n";
    		foreach $key (keys %lochash) {
				if (defined($values[2]) && $lochash{$key} == $values[2]){
					print "<option selected value=\"$lochash{$key}\">$key\n";
				}
				else {
					print "<option value=\"$lochash{$key}\">$key\n";
				}
			}
    		print "</select></td></tr>\n";
    		#print "</table></td></tr>\n";
    		$i++;
    	}
    }
    if ($i == 1) {
    	$locselect = "supplierloc" . $i ;
		print "<tr><td width=100% align=left><select name=supplier size=1 $disabled>\n";
		print "<option value=0>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
		print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
		print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
		print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
		foreach $key (keys %supplierhash) {
			print "<option value=\"$key\">$supplierhash{$key}\n";
		}
		print "</select></td>\n<td width=100%><select name=$locselect size=1 $disabled>\n";
		print "<option value=0>\n";
		foreach $key (keys %lochash) {
			print "<option value=\"$lochash{$key}\">$key\n";
		}
		print "</select></td></tr>\n";
		#print "</table></td></tr>\n";
		$i++;
    }
    for (my $j=$i;$j<4;$j++) {
		$locselect = "supplierloc" . $j ;
		#print "<tr><td><table border=1 width=100% align=center>\n";
		print "<tr><td width=100% align=left>&nbsp;</td>\n";
		print "<td width=100%><select name=$locselect size=1>\n";
		print "<option value=0>\n";
		foreach $key (keys %lochash) {
			print "<option value=\"$lochash{$key}\">$key\n";
		}
		print "</select></td></tr>\n";
    	#print "</table></td></tr>\n";
    }
    print "</table></td></tr>\n";
}

############################
sub selectIssuedto {
############################
	 my ($issuedto,$disabled) = @_;
    tie my %issuedTohash,  "Tie::IxHash";
    
    if (!($issuedto)) {$issuedto = 0;}
    %issuedTohash = get_lookup_values($dbh, "organizations", 'id', 'abbr', " performed_on_list = 'T' or id = $issuedto ");
    
    print "<select name=issuedTo size=1 $disabled>\n";
    print "<option value=0>\n";
    foreach my $keys (keys %issuedTohash) {
    if ($keys eq $issuedto ){
			print "<option selected value=$keys>$issuedTohash{$keys}\n";
    	}
    	else {
			print "<option value=$keys>$issuedTohash{$keys}\n";
    	}	
    }
	 print "</select>\n";
}
############################
sub selectIssuedby {
############################
	 my ($issuedby,$disabled) = @_;
    tie my %issuedByhash,  "Tie::IxHash";
    
    if (!($issuedby)) {$issuedby = 0;}
    %issuedByhash = get_lookup_values($dbh, "organizations", 'id', 'abbr', " abbr in ('BSC','OQA') or id = $issuedby ");
    
    print "<select name=issuedBy size=1 $disabled>\n";
    print "<option value=0>\n";
    foreach my $keys (keys %issuedByhash) {
    if ($keys eq $issuedby ){
			print "<option selected value=$keys>$issuedByhash{$keys}\n";
    	}
    	else {
			print "<option value=$keys>$issuedByhash{$keys}\n";
    	}	
    }
	 print "</select>\n";
} 
############################
sub selectQualifiedSuppliers {
############################
    #my ($id,$fy) = @_;
    tie my %orghash, "Tie::IxHash";;
    my $qsl_id = 0;
    my $key = '';
    
    
    %orghash = get_lookup_values($dbh, 'qualified_supplier', 'id', 'company_name');
   
    print "<tr>\n";
    print "<td valign=top nowrap><b>Supplier:</b>&nbsp;&nbsp;<select name=QualifedSupplier title=\"QualifiedSupplier\" size=1>\n"; 	
    foreach $key (keys %orghash) {
	#if ($key == $qsl_id){
	#	print "<option selected value=\"$key\">$orghash{$key}\n";
   #     }
    #    else {
		print "<option value=\"$key\">$orghash{$key}\n";
	#}
    }
    print "</select></td></tr>\n";
   #print "</tr>\n<tr><td colspan=4>Product or Service: &nbsp;&nbsp;<input name=product type=text maxlength=55 size=55></td></tr>\n";

}
############################
sub selectFY {
############################
	 my ($selected_fy,$disabled) = @_;
	 my $def_yr;
	 my $current_year = $dbh -> prepare ("select to_char(sysdate,'MM/YYYY') from dual");
	 $current_year -> execute;
	 my $mmyyyy = $current_year -> fetchrow_array;
	 $current_year -> finish;
	 my $mm = substr($mmyyyy,0,2);
	 if ($mm > 9) {
		$def_yr = substr($mmyyyy,3) + 1;
	 }
	 else { $def_yr = substr($mmyyyy,3); }
	 
	 if (!defined($selected_fy)) {$selected_fy = $def_yr;}
	 elsif ($selected_fy > 50) {$selected_fy += 1900;}
	 elsif ($selected_fy < 50) {$selected_fy += 2000;}
	 my $csr = $dbh -> prepare ("select fiscal_year from $schema.fiscal_year order by fiscal_year desc");
	 $csr -> execute;
	 print "&nbsp;&nbsp;&nbsp;<b>Fiscal Year:&nbsp;&nbsp;</b>\n";
	 print "<select name=fy size=1 $disabled>\n";
	 while (my @values = $csr -> fetchrow_array){
		my ($fy) = @values;
		if ($fy == $selected_fy ){
			print "<option selected value=$fy>$fy\n";
		}
		else {
			print "<option value=$fy>$fy\n";
      }
    }
	 $csr -> finish;
	 print "</select>\n";

}
############################
sub count_org_locs {
############################
	my ($srid,$fy) = @_;
	
	my $sqlstring = "select count(*) ";
	 $sqlstring .= "from $schema.request_org_loc ";
	 $sqlstring .= "where fiscal_year = $fy and request_id = $srid order by id ";

	 my $csr = $dbh->prepare($sqlstring);
	 $csr->execute;
	 my @values = $csr->fetchrow_array;
	 my $orgcount = $values[0];
	 
	 return($orgcount);	 
}
############################
sub get_org_locs {
############################
	my ($srid,$fy) = @_;
	my $orglist = "(0,";
	my $loclist = "(0,";
	my $supplierlist = "(0,";
	
	my $sqlstring = "select id, organization_id, location_id, supplier_id ";
	 $sqlstring .= "from $schema.request_org_loc ";
	 $sqlstring .= "where fiscal_year = $fy and request_id = $srid order by id ";
	 
	 my $csr = $dbh->prepare($sqlstring);
	 $csr->execute;
	 while (my @values = $csr->fetchrow_array) {
	   if ($values[1]) {$orglist .= $values[1] . ",";}
	 	if ($values[2]) {$loclist .= $values[2] . ",";}
	 	if ($values[3]) {$supplierlist .= $values[3] . ",";}
	 }
	 chop($orglist);
	 chop($loclist);
	 chop($supplierlist);
	 $orglist .= ")";
	 $loclist .= ")";
	 $supplierlist .= ")";
	 &getOrganizations($orglist);
	 &getSuppliers($supplierlist);
	 &getLocations($loclist);
	 
	 
}
############################
sub getOrganizations {
############################
    my ($orglist) = @_;
    my $first = 1;
    
    
    my @orglist = split  /,/, $orglist;
    my $sqlquery = "select abbr from $schema.organizations where id in $orglist";
    my $csr = $dbh->prepare($sqlquery);
	
	 $csr->execute;
	 #print "<tr><td><b>Organizations:&nbsp;<font color=black>\n";
	 
  	 while (my @values = $csr->fetchrow_array) {
  	 	if (!$first) {
	   	print ",&nbsp;&nbsp;";
  	   }
  	   else {
  	   	print "<font color=black size=-3>ORGANIZATIONS:&nbsp;</font><font size=-1>\n";
  	   }
		print "$values[0]";
		$first = 0;
    }
    print "</font>\n";
    #print "</font></b></td></tr>\n";
    
	# foreach my $org (@orglist) {
	#	print "<tr><td><b>Org:&nbsp;</b><font color=black>$org</font></td></tr>\n";
	# }
   
}
############################
sub getLocations {
############################
    my ($loclist) = @_;
	 my ($city,$state,$province,$country);
	 my @loclist = split  /,/, $loclist;
	 my $first = 1;
	 
    my $sqlquery = "select initcap(city), state, initcap(province), country from $schema.locations where id in $loclist";
    my $csr = $dbh->prepare($sqlquery);
	
	 $csr->execute;
	 #print "<tr><td><b>Locations:&nbsp;<font color=black>\n";
	 
  	 while (my @values = $csr->fetchrow_array) {
  	   #($city,$state,$province,$country) = @values;
  	   $city = defined($values[0]) ? $values[0] : '';
  	   $state = defined($values[1]) ? $values[1] : '';
  	   $province = defined($values[2]) ? $values[2] : '';
  	   $country = defined($values[3]) ? $values[3] : '';
  	   
  	   if (!$first) {
  	   	print ";&nbsp;&nbsp;";
  	   }
  	   else {
  	   	print "&nbsp;<font color=black size=-3>LOCATIONS:&nbsp;</font><font size=-1>\n";
  	   }
  	   if ($city) {
			print "$city,&nbsp;";
		}
		if ($state) {
			print "$state";
		}
		if ($province) {
			print "$province,&nbsp;";
		}
		if ($country eq 'CAN') {
			print "$country";
		}
		$first = 0;
    }
    print "</font>\n";
    #print "</font></b></td></tr>\n";
    
	# foreach my $loc (@loclist) {
	#	print "<tr><td><b>Location:&nbsp;</b><font color=black>$loc</font></td></tr>\n";
	# }
    
    
}
############################
sub getSuppliers {
############################
    my ($supplierlist) = @_;
 	 my @supplierlist = split  /,/, $supplierlist;
 	 my $first = 1;
 	 	 
    my $sqlquery = "select company_name from $schema.qualified_supplier where id in $supplierlist";
    my $csr = $dbh->prepare($sqlquery);
 	
 	 $csr->execute;
 	 
   	while (my @values = $csr->fetchrow_array) {
   	if (!$first) {
			print ",&nbsp;&nbsp;";
  	   }
  	   else {
  	   	print "<font color=black size=-3>SUPPLIER:&nbsp;</font><font size=-1>\n";
  	   }
 		print "$values[0]";
 		$first = 0;
    }
    print "</font>\n";
    
 	# foreach my $supplier (@supplierlist) {
 	#	print "<tr><td><b>Supplier:&nbsp;</b><font color=black>$supplier</font></td></tr>\n";
	# }
 
}

############################
if ($cgiaction eq "browse_requests") {
############################
    my $fullyear = $NQScgi->param('fy2');
    my $fy = substr($fullyear,2);
    my $csr;
    my @values;
    my $title;
    my $col_display;
    my $display_yr;
    my $display_num;
    my $request_id;
    my $display_org;
    my $reason_subject;
    my $issuedto_display;
    my ($yr,$num,$sid,$reason,$subject,$detail,$requestor,$disapproval,$requested,$approved);
    my ($issuedto,$int_ext,$issuedby,$requestID,$surveillanceID);
    
    print "<br><table width=700 border=1 cellspacing=1 cellpadding=1 align=center>\n";
    
    	my $sqlquery = "SELECT requestor, fiscal_year, id, surveillance_id, reason_for_request, ";
    	$sqlquery .= "subject_line, subject_detail, disapproval_rationale, to_char(request_date,'MM/DD/YYYY'), ";
    	$sqlquery .= "to_char(approval_date,'MM/DD/YYYY'), issuedto_org_id, int_ext, issuedby_org_id ";
    	$sqlquery .= "FROM $schema.surveillance_request ";
    	$sqlquery .= "where fiscal_year = $fy order by id ";

    	$csr = $dbh->prepare($sqlquery);
    	$csr->execute;
    	
    	print "<input type=hidden name=rid>\n";
    	print "<input type=hidden name=scope>\n";
    	print "<input type=hidden name=issuedto>\n";
    	print "<input type=hidden name=issuedby>\n";
    	print "<input type=hidden name=fy2>\n";
    	
    	#print "<tr><td colspan=4 align=center><font size= +1><b>Surveillance Requests</b></font></td></tr>\n";
      print "<tr  bgcolor=#B0C4DE><td align=center><font color=black><b>Request ID</b></font></td>\n";
      print "<td align=center><font color=black><b>Requestor</b></font></td><td align=center><font color=black><b>Date</b></font></td>\n";
      print "<td width=70% align=center><font color=black><b>Scope / Request Details</b></font></td></tr>\n";
    	while (@values = $csr->fetchrow_array) {
    	
			#($requestor,$yr,$num,$sid,$reason,$subject,$detail,$disapproval,$requested,$approved) = @values;
			$requestor = defined($values[0]) ? $values[0] : '';
			$yr = defined($values[1]) ? $values[1] : '';
			$num = defined($values[2]) ? $values[2] : '';
			$sid = defined($values[3]) ? $values[3] : '';
			$reason = defined($values[4]) ? $values[4] : '';
			$subject = defined($values[5]) ? $values[5] : '';
			$detail = defined($values[6]) ? $values[6] : '';
			$disapproval = defined($values[7]) ? $values[7] : '';
			$requested = defined($values[8]) ? $values[8] : '';
			$approved = defined($values[9]) ? $values[9] : '';
			$issuedto = defined($values[10]) ? $values[10] : 0;
			$int_ext = defined($values[11]) ? $values[11] : 'new';
			$issuedby = defined($values[12]) ? $values[12] : 0;

			$display_yr = lpadzero($yr,2);
			$display_num = lpadzero($num,2);
			if ($issuedto) {
				$issuedto_display = lookup_single_value($dbh,$schema,'organizations','abbr', $issuedto );
			}
			else {$issuedto_display = 'TBD';}
			my $orgcount = count_org_locs($num,$fy);
			
			$requestID = getSurvRequestId($dbh,$issuedby,$issuedto,$fullyear,$num); 
			$surveillanceID = '';
			if ($sid) {
		###**************issuedto vs issued by depends on format************###
				my $csr2 = $dbh->prepare("select o.abbr, s.surveillance_seq from $schema.organizations o, $schema.surveillance s where s.id = $sid and s.fiscal_year = $fy and s.issuedto_org_id = o.id ");
				$csr2->execute;
				my @value = $csr2->fetchrow_array;
				if (defined($value[0])) {$surveillanceID = getSurvId($dbh,$issuedby,$issuedto,$int_ext,$fullyear,$value[1]);}
			}
			print "<tr bgcolor=white><td nowrap valign=top align=center><a href=javascript:submitView($num,$yr,'$requestID','$surveillanceID');><font size=-1>$requestID</font></a>";
			#if ( (!$sid && $orgcount > 0 && $issuedto != 0 && $detail ne '') && (($userprivhash{'Developer'} == 1) || ($userprivhash{'Surveillance Schedule Approver'} == 1) 
			#   || ($userprivhash{'Surveillance Administration'} == 1))) {
			#   print "\n<br><input type=button onClick=assignSurveillance('request',$num,$issuedto,$yr); value=\"SID\">";
			#}
			print "</td>\n";
			print "<td nowrap valign=top align=center><font size=-1>$requestor &nbsp;</font></td><td nowrap valign=top><font size=-1>$requested &nbsp;</font></td>\n";
			#print "<td></td>\n";
			print "<td valign=top align=left><font size=-1>";
			#if ($disapproval) {$col_display = 'Disapproved';}
			#elsif ($sid) {
			if ($sid) {
				print "<font color=black size=-3>SURVEILLANCE ID:&nbsp;</font>";
				if ($surveillanceID eq '') {print "Surveillance ID assigned, no link to record found</font><br>\n";}
				else {print "<a href=\"$NQSCGIDir/surveillance.pl?userid=$userid&username=$username&schema=$schema&cgiaction=view_surveillance&id=$sid&fy=$fy\">$surveillanceID</font></a><br>\n";}
			}
			#elsif ($approved) {
			#	$col_display = 'Approved';
			#	print "$col_display<br>\n";
			#}
			#else {$col_display = 'Pending';
			#	print "$col_display<br>\n";
			#}

			
			#if ($userprivhash{'Developer'} == 1 || $userprivhash{'Surveillance Administration'} == 1) {
			#	print "<br><a href=javascript:submitActive();>Edit</a>\n";
			#}
			
			if ($orgcount) {
				&get_org_locs($num,$fy);
				print "<br>";
			}
			if ($disapproval) {
				print "<font color=black size=-1>Request Information:&nbsp;</font><font size=-1>$reason </font><br> \n";
				print "<font color=black size=-1>Disapproval Rationale:&nbsp;</font><font size=-1>$disapproval</font><br>\n";
			}
			if ($detail) {
				print "<font color=black size=-3>SUBJECT:&nbsp;</font><font size=-1>$detail &nbsp;</font>\n";
			}
			else {
				print "<font color=black size=-3>REQUEST:&nbsp;</font><font size=-1>$reason</font>\n";
			}
			if ( (!$sid && $orgcount > 0 && $issuedto != 0 && $issuedby != 0 && $detail ne '') && (($userprivhash{'Developer'} == 1) || 
			   ($userprivhash{'OQA Surveillance Schedule Approver'} == 1 || $userprivhash{'BSC Surveillance Schedule Approver'} == 1) 
					|| ($userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'BSC Surveillance Administration'} == 1))) {
					print "\n<br><input type=button onClick=assignSurveillance('request',$num,$issuedto,$issuedby,$yr); value=\"Assign Surveillance\">";
			}
			print "</td></tr>\n";
    	}
   
   	# free up the generated 'cursor'
    	$csr->finish;
    	print "</table><br><br>\n";

   
    print "<input type=hidden name=id value=$num>\n";
    print "<input type=hidden name=yr value=$yr>\n";
    print "<input type=hidden name=fy value=$fy>\n";
    print "<input type=hidden name=requestid_display>\n";
    print "<input type=hidden name=surveillanceid_display>\n";
    print "<input type=hidden name=fullyear value=$fullyear>\n";
    #print "<input type=hidden name=id value=$id>\n";
}

############################
elsif ($cgiaction eq "request_surveillance") {
############################
	my $def_fy = $NQScgi->param('def_yr');
	my ($day,$mon,$year);
	my $tm = localtime;
	($day,$mon,$year) = ($tm->mday, $tm->mon+1, $tm->year+1900);
	
	print "<table width=670 border=0 align=center>\n";
	if ($username ne "GUEST") {
		my $fullname = get_fullname($dbh, $schema, $userid);
		print "<tr><td align=left valign=top><br><b>Requestor:&nbsp;$fullname</b>\n";
		print "<input type=hidden name=requestor value=\"$fullname\"></td>\n";
	}
	else {
		print "<tr><td align=left valign=top><b>Requestor:&nbsp;</b><input name=requestor type=text maxlength=50 size=35></td>\n";
	}
	print "<td valign=bottom>";
	&selectFY(substr($def_fy,2),'');
	print "</td></tr>\n";
	print "<tr><td colspan=2><b>Preferred Surveillance Date:&nbsp;</b><input name=requested type=text maxlength=15 size=15 onBlur=checkDate(value,this)></td></tr>\n";
	#print "<td align=right><br><b>Request Date: $mon/$day/$year</b><br><br></td>\n";
	#print "</tr>\n";
	print "<tr height=12></tr>\n";
	print "<tr><td align=left valign=top><textarea name=reason rows=12 cols=40 onBlur=checkLength(value,this);></textarea></td>\n";
	print "<td align=left>";
	print "	<u><b>Reason for Surveillance</b></u><br>\n";
	print "	<indent>Please include the following information in the text box:<br>\n";
	print "	&nbsp;&nbsp;-&nbsp;Contact Name<br>\n";
	print "	&nbsp;&nbsp;-&nbsp;Contact Phone No.<br>\n";
	print "	&nbsp;&nbsp;-&nbsp;Reason for surveillance (please be brief)<br>\n";
	print "	&nbsp;&nbsp;-&nbsp;Organizations and/or Locations to be surveilled\n";
	print "	</td></tr>\n";
	print "</table>\n";
	print "<input type=hidden name=day value=$day>\n";
	print "<input type=hidden name=mon value=$mon>\n";
	print "<input type=hidden name=year value=$year>\n";
	print "<input type=hidden name=target value=control>\n";
	#print "<input type=hidden name=fy value=2002>\n";
	#print "<input type=hidden name=cgiaction value=add_request>\n";
	print "<br><input type=submit  value=\"Submit\" >\n";
}


############################
elsif ($cgiaction eq "view_request") {
############################
	my $srid = $NQScgi->param('id');
	my $fy = $NQScgi->param('fy');
	my ($day,$mon,$year);
	my $tm = localtime;
	($day,$mon,$year) = ($tm->mday, $tm->mon+1, $tm->year+1900);
	my ($requestor,$requested,$reason,$subjline,$detail,$approverid);
	my ($approvaldate,$sid,$rationale,$issuedto,$int_ext,$requestID,$issuedby);
	my $display_fy;
	
	my $sqlquery = "select requestor, to_char(request_date,'MM/DD/YYYY'), ";
	$sqlquery .= "reason_for_request, subject_line, subject_detail, approver_id, ";
	$sqlquery .= "approval_date, surveillance_id, disapproval_rationale, ";
	$sqlquery .= "issuedto_org_id, int_ext, issuedby_org_id ";
	$sqlquery .= "from $schema.surveillance_request ";
	$sqlquery .= "where id = $srid and fiscal_year = $fy ";
	
	#print "<br> ** $sqlstring ** \n";
	my $csr = $dbh->prepare($sqlquery);
	$csr->execute;
	my @values = $csr->fetchrow_array;

	$requestor = defined($values[0]) ? $values[0] : '';
	$requested = defined($values[1]) ? $values[1] : '';
	$reason = defined($values[2]) ? $values[2] : '';
	$subjline = defined($values[3]) ? $values[3] : '';
	$detail = defined($values[4]) ? $values[4] : '';
	$approverid = defined($values[5]) ? $values[5] : '';
	$approvaldate = defined($values[6]) ? $values[6] : '';
	$sid = defined($values[7]) ? $values[7] : '';
	$rationale = defined($values[8]) ? $values[8] : '';
	$issuedto = defined($values[9]) ? $values[9] : '';
	$int_ext = defined($values[10]) ? $values[10] : '';
	$issuedby = defined($values[11]) ? $values[11] : '';
	
	if ($fy < 50) {
		$display_fy = $fy + 2000;
	}
	else {
		$display_fy = $fy + 1900;
	}
	$requestID = getSurvRequestId($dbh,$$issuedby,$issuedto,$display_fy,$srid);
	my $issuedto_display = lookup_single_value($dbh,$schema,'organizations','abbr', $issuedto );
	print "<table width=670 border=0 cellspacing=1 cellpadding=1>\n";
	print "<tr><td><b>Requestor:&nbsp;<font color=black>$requestor</font></b></td></tr>\n";
	print "<tr><td><b>Request Date:&nbsp;<font color=black>$requested</font></b></td></tr>\n";
	print "<tr><td><b>Request:&nbsp;</b><font color=black>$reason</font></td></tr>\n";
	print "<tr><td><hr></td></tr>\n";
	print "<tr><td><b>Issued To:&nbsp;<font color=black>$issuedto_display</font>\n";
	print "&nbsp;&nbsp;&nbsp;Fiscal Year:&nbsp;<font color=black>$display_fy</font></b></td></tr>\n";
	print "<tr><td><b>Subject:&nbsp;<font color=black>$subjline</font></b></td></tr>\n";
	print "<tr><td><b>Subject detail:&nbsp;<font color=black>$detail</font></b></td></tr>\n";
	
	print "<tr><td><b>";
	&get_org_locs($srid,$fy);
	print "</b></td></tr>\n";

	if ($sid) {
		print "<tr><td><b>Approved:&nbsp;<font color=black>$approvaldate</font></b></td></tr>\n";
		print "<tr><td><b>Surveillance ID:&nbsp;<font color=black>$sid</font></b></td></tr>\n";
	}
	elsif ($rationale) {
		print "<tr><td><b>Disapproved:&nbsp;<font color=black>$approvaldate</font></b></td></tr>\n";
		print "<tr><td><b>Reason for Disapproval:&nbsp;<font color=black>$rationale</font></b></td></tr>\n";
	}
	elsif ($approvaldate) {
		print "<tr><td><b>Approved:&nbsp;<font color=black>$approvaldate</font></b></td></tr>\n";
	}
	else {
		print "<tr><td><b>Pending</font></b></td></tr>\n";
	}
	print "<tr><td><hr></td></tr>\n";
	print "</table>\n";
}

############################
elsif ($cgiaction eq "active_request") {
############################
	my $srid = $NQScgi->param('id');
	my $fy = $NQScgi->param('fy');
	my $requestid_display = $NQScgi->param('requestid_display');
	my $surveillanceid_display = $NQScgi->param('surveillanceid_display');
	my ($day,$mon,$year);
	my $tm = localtime;
	($day,$mon,$year) = ($tm->mday, $tm->mon+1, $tm->year+1900);
	my ($requestor,$requested,$reason,$subjline,$detail,$approverid,$issuedby);
	my ($approvaldate,$sid,$rationale,$issuedto,$int_ext,$supplier_spanstyle,$org_spanstyle);
	my $readonly;
	my $disabled;
	my $internal_checked;
	my $external_checked;
	my $requestID;
	my $fullyear;
	$fullyear = $fy + 2000 if ($fy < 50);
   $fullyear = $fy + 1900 if ($fy > 50);
	
	my $sqlquery = "select requestor, to_char(request_date,'MM/DD/YYYY'), ";
	$sqlquery .= "reason_for_request, subject_line, subject_detail, approver_id, ";
	$sqlquery .= "to_char(approval_date,'MM/DD/YYYY'), surveillance_id, disapproval_rationale, ";
	$sqlquery .= "issuedto_org_id, int_ext, issuedby_org_id ";
	$sqlquery .= "from $schema.surveillance_request ";
	$sqlquery .= "where id = $srid and fiscal_year = $fy ";
	
	#print "<br> ** $sqlstring ** \n";
	my $csr = $dbh->prepare($sqlquery);
	$csr->execute;
	my @values = $csr->fetchrow_array;

	$requestor = defined($values[0]) ? $values[0] : '';
	$requested = defined($values[1]) ? $values[1] : '';
	$reason = defined($values[2]) ? $values[2] : '';
	$subjline = defined($values[3]) ? $values[3] : '';
	$detail = defined($values[4]) ? $values[4] : '';
	$approverid = defined($values[5]) ? $values[5] : '';
	$approvaldate = defined($values[6]) ? $values[6] : '';
	$sid = defined($values[7]) ? $values[7] : 0;
	$rationale = defined($values[8]) ? $values[8] : '';
	$issuedto = defined($values[9]) ? $values[9] : '';
	$int_ext = defined($values[10]) ? $values[10] : 'new';
	$issuedby = defined($values[11]) ? $values[11] : '';
	
	if ($sid) {$readonly = 'readonly'; $disabled = 'disabled=true';}
	elsif ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1
	       || $userprivhash{'BSC Surveillance Administration'} == 1) {
		$readonly = '';
		$disabled = '';
	}
	else {$readonly = 'readonly'; $disabled = 'disabled=true';}
	
	if ($int_ext eq 'I' || $int_ext eq 'new') {
		$internal_checked = ' checked ';
		$external_checked = ' ';
	}
	else  {
		$internal_checked = ' ';
		$external_checked = ' checked ';
	}
	$requestID = getSurvRequestId($dbh,$issuedby,$issuedto,$fullyear,$srid);
	print "<br><table width=670 border=0 cellspacing=1 cellpadding=1>\n";
	print "<tr><td align=left bgcolor=#CCEEFF><b><font color=black>$requestid_display</font></b></td>\n";
	print "<td align=center><b>&nbsp;&nbsp;&nbsp;Requestor:&nbsp;<font color=black>$requestor</font></b></td>\n";
	print "<td align=right nowrap><b>Request Date:&nbsp;<font color=black>$requested</font></b></td></tr>\n";
	print "<tr><td colspan=3><b>Request:&nbsp;</b><font color=black>$reason</font></td></tr>\n";
	print "<tr><td colspan=3><hr></td></tr>\n";
	
	print "<tr><td nowrap><input type=radio name=int_ext value=I onClick=show_int_ext('I'); $internal_checked $disabled><b>Internal</b> &nbsp;\n";
	print "<input type=radio name=int_ext value=E onClick=show_int_ext('E'); $external_checked $disabled><b>External</b></td>\n";
	print "<td align=center nowrap><b>&nbsp;&nbsp;&nbsp;&nbsp;Issued By:&nbsp;</b>";
	&selectIssuedby($issuedby,$disabled);
	print "&nbsp;<b>Issued To:</b>&nbsp;";
	&selectIssuedto($issuedto,$disabled);
	print "</td>\n";
	print "<td align=right>";
	&selectFY($fy,$disabled);
	print "</td></tr>\n";
	
	print "<tr><td colspan=3><table border=0 cellspacing=1 cellpadding=1>\n";
	print "<tr><td align=center>";
	if ($int_ext eq 'I'|| $int_ext eq 'new') {
		$org_spanstyle = " Style=Display:block; ";
		$supplier_spanstyle = " Style=Display:none; ";
	}
	else {
		$org_spanstyle = " Style=Display:none; ";
		$supplier_spanstyle = " Style=Display:block; ";
	}
	print "<span id=\"orgs\" $org_spanstyle><table border=1 cellspacing=1 cellpadding=1>\n";
	&select_org_locs($srid,$fy,$disabled);
	print "</table></span>\n";
	print "<span id=\"supplier\" $supplier_spanstyle><table border=1 cellspacing=1 cellpadding=1>\n";
	&select_supplier_locs($srid,$fy,$disabled);
	print "</table></span></td></tr>\n";
	print "<tr><td colspan=3><table border=0 cellspacing=1 cellpadding=1>\n";
	print "<tr><td colspan=3 nowrap><b>Subject Line:</td><td><input type=text name=subjline maxlength=150 size=88  $readonly value='$subjline'></b></td></tr>\n";	
	print "<tr><td valign=top colspan=3 nowrap><b>Subject Detail:</td><td><textarea onBlur=checkLength(value,this); name=detail rows=3 cols=67 $readonly>$detail</textarea></b></td></tr>\n";
	print "</table></td></tr>\n";
	print "<tr height=10></tr>\n";
	#print "<tr><td align=center><br><input type=button onClick=submitSubject(); value=\"Save\"></td></tr>\n";

	#if ($approvaldate) {
	if ($sid) {
		#print "<tr><td><b>Approved:&nbsp;<font color=black>$approvaldate</font></b></td></tr>\n";
		print "<tr><td colspan=3><b>Surveillance ID:&nbsp;<font color=black>\n";
		if ($surveillanceid_display eq '') {print "Surveillance ID assigned, no link to record found.</font></b></td></tr>\n";}
		else {print "<a href=\"$NQSCGIDir/surveillance.pl?userid=$userid&username=$username&schema=$schema&cgiaction=view_surveillance&id=$sid&fy=$fy\">$surveillanceid_display</a></font></b></td></tr>\n";}
	}
	elsif ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1
	       || $userprivhash{'BSC Surveillance Administration'} == 1) {
		print "<tr><td align=center colspan=3><br><input type=button onClick=updateRequest('request',$fy); value=\"Save\">";
		print "&nbsp;&nbsp;<input type=button  onClick=deleteRequest('request',$fy); value=\"Delete\" ></td></tr>\n";
	}
		
	print "</table>\n";
	print "<input type=hidden name=srid value=$srid>\n";
	print "<input type=hidden name=fy2 value=$fy>\n";
	
	
}

############################
elsif ($cgiaction eq "add_request") {
############################
		  	
	my $fy2 = $NQScgi->param('fy');
	my $fy = substr($fy2,2);
	my $requestor = $NQScgi->param('requestor');
	my $requested = $NQScgi->param('requested');
	my $reason = $NQScgi->param('reason');
	$reason =~ s/'/''/g;
	my @nextid;
	my $msg;
	
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	eval {
		my $sqlstring = "select $schema.request_" . $fy . "_seq.nextval from dual";
		my $csr = $dbh->prepare($sqlstring);
		$csr->execute;
   	@nextid=$csr->fetchrow_array;

		my $insertstring = "insert into $schema.surveillance_request (id, fiscal_year, requestor, ";
		$insertstring .= "request_date, reason_for_request) ";
		$insertstring .= "values ($nextid[0],$fy,'$requestor',to_date('$requested','MM/DD/YYYY'),'$reason')";

		my $csr2 = $dbh->do($insertstring);
	};
	if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error adding request $nextid[0] for fy $fy2.  $@");
		$msg = "Error adding request - request was not added ";
	}
	else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username added request $nextid[0] for fy $fy");
		$msg = "Request added successfully";
	}
	#print "<br>** $insertstring ** \n";
	print "<input type=hidden name=fy2 value=$fy2>";
	print <<browse4;
			<script language="JavaScript" type="text/javascript">
			<!--
			    alert ('$msg');
		  		 submitForm('request','browse_requests',0);
		  	//-->
		  	</script>
browse4

}


############################
elsif ($cgiaction eq "update_request") {
############################
	my $srid = $NQScgi->param('srid');
   my $issuedtoid = $NQScgi->param("issuedTo");
   my $issuedbyid = $NQScgi->param("issuedBy");
	my $subject = $NQScgi->param("subjline");
	$subject =~ s/'/''/g;
	my $detail = $NQScgi->param("detail");
	$detail =~ s/'/''/g;
	my $int_ext = $NQScgi->param("int_ext");
	my $msg;
	
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	
	if (!($subject)) {$subject = '';}
	if (!($detail)) {$detail = '';}
	if (!($int_ext)) {$int_ext = '';}
	
	#my $forecast = $NQScgi->param("forecast");
	my $fy2 = $NQScgi->param("fy");
	
	my $fy = substr($fy2,2);
	my $id = $NQScgi->param("srid");
	my $supplier = defined($NQScgi->param("supplier")) ? $NQScgi->param("supplier") : 0;
	my $org1 = defined($NQScgi->param("org1")) ? $NQScgi->param("org1") : 0;
	my $org2 = defined($NQScgi->param("org2")) ? $NQScgi->param("org2") : 0;
	my $org3 = defined($NQScgi->param("org3")) ? $NQScgi->param("org3") : 0;
	my $loc1 = defined($NQScgi->param("loc1")) ? $NQScgi->param("loc1") : 0;
	my $loc2 = defined($NQScgi->param("loc2")) ? $NQScgi->param("loc2") : 0;
	my $loc3 = defined($NQScgi->param("loc3")) ? $NQScgi->param("loc3") : 0;
	my $supplierloc1 = defined($NQScgi->param("supplierloc1")) ? $NQScgi->param("supplierloc1") : 0;
	my $supplierloc2 = defined($NQScgi->param("supplierloc2")) ? $NQScgi->param("supplierloc2") : 0;
	my $supplierloc3 = defined($NQScgi->param("supplierloc3")) ? $NQScgi->param("supplierloc3") : 0;
	my $sqlstring;
	my $sqlstring2;
	my $csr;
	my $csr2;
	my $csr3;
	my $csr4;
	my $insertstring;
	my $i;
	my $org;
	my $loc;
	my $issuedto;
	my $issuedby;
	my $field;

	
	#if ($forecast ne 'mm/yyyy') {
	#	$forecast = substr($forecast,0,3) . '01/' . substr($forecast,3);
	#	$forecast = ",forecast_date = to_date('$forecast','MM/DD/YYYY')";

	#}
	#else {$forecast = '' ; }
	if ($issuedtoid) {$issuedto = ' issuedto_org_id = ' . $issuedtoid . ', ';}
	else {$issuedto = '';}
	if ($issuedbyid) {$issuedby = ' issuedby_org_id = ' . $issuedbyid . ', ';}
	else {$issuedby = '';}
	$sqlstring2 = "update $schema.surveillance_request  ";
	$sqlstring2 .= "set $issuedto $issuedby subject_line = '$subject', ";
	$sqlstring2 .= " subject_detail = '$detail' , ";
	$sqlstring2 .= " int_ext = '$int_ext' ";
	$sqlstring2 .= "where fiscal_year = $fy and id = $id ";

	eval {
		$csr2 = $dbh->do($sqlstring2);
		$csr3 = $dbh->do("delete from $schema.request_org_loc where fiscal_year = $fy and request_id = $id");
		if ($int_ext eq 'I') {
			for ($i=1;$i<4;$i++) {
				if ($i == 1) {$org = $org1; $loc = $loc1;}
				if ($i == 2) {$org = $org2; $loc = $loc2;}
				if ($i == 3) {$org = $org3; $loc = $loc3;}
		

				if (($org) || ($loc)) {
					if ($org == 0) {$org = 'NULL';}
					if ($loc == 0) {$loc = 'NULL';}
			
					$insertstring = "insert into $schema.request_org_loc (id, request_id, ";
					$insertstring .= "fiscal_year, organization_id, location_id) ";
					$insertstring .= "values ($i,$id,$fy,$org,$loc)";

					$csr4 = $dbh->do($insertstring);
	   		}
	 		}
	 	}
	 	else {
	 		for ($i=1;$i<4;$i++) {
				if ($i == 1) {$loc = $supplierloc1;}
				if ($i == 2) {$loc = $supplierloc2;}
				if ($i == 3) {$loc = $supplierloc3;}


				if ($i == 1) {
					if ($loc == 0) {$loc = 'NULL';}

					$insertstring = "insert into $schema.request_org_loc (id, request_id, ";
					$insertstring .= "fiscal_year, supplier_id, location_id) ";
					$insertstring .= "values ($i,$id,$fy,$supplier,$loc)";

					$csr4 = $dbh->do($insertstring);
				}
				if (($i > 1) && ($loc)) {

					$insertstring = "insert into $schema.request_org_loc (id, request_id, ";
					$insertstring .= "fiscal_year, location_id) ";
					$insertstring .= "values ($i,$id,$fy,$loc)";

					$csr4 = $dbh->do($insertstring);
				}
	 		}
	 	}
	 };
	 
	 if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error updating request $id for fy $fy.  $@");
	   $msg = "Error updating request - Request was not updated.";
	 }
	 else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username updated request $id for fy $fy");
	   $msg = "Request updated successfully";
	 }
	   
	#print "<br>~~ secondary update done! ~~\n"; 
   print "<input type=hidden name=fy2 value=$fy2>";
      
    	print <<browse;
		<script language="JavaScript" type="text/javascript">
		<!--
			 alert ('$msg');
	  		 submitForm('request','browse_requests',0);
	  	//-->
	  	</script>
browse
}
############################
if ($cgiaction eq "delete_request") {
############################
	my $srid = $NQScgi->param('srid');
	my $fy2 = $NQScgi->param("fy");
	my $fy = substr($fy2,2);
	my $msg;
	
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	
	eval {
		my $csr = $dbh->do("delete from $schema.request_org_loc where fiscal_year = $fy and request_id = $srid");
		my $csr2 = $dbh->do("delete from $schema.surveillance_request where fiscal_year = $fy and id = $srid");
	};
	if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error deleting request $srid for fy $fy.  $@");
	   $msg = "Error deleting request - Request was not deleted";
	}
	else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username deleted request $srid for fy $fy");
		 $msg = "Request deleted successfully";
	}
	print "<input type=hidden name=fy2 value=$fy2>";
		      
	print <<browse3;
	<script language="JavaScript" type="text/javascript">
	<!--
		 alert ('$msg');
		 submitForm('request','browse_requests',0);
	//-->
	</script>
browse3
	
}
############################
if ($cgiaction eq "assign_surveillance") {
############################

	my $fy2 = $NQScgi->param('fy2');
	my $fy = lpadzero($fy2,2);
	my $rid = $NQScgi->param('rid');
	my $issuedto = $NQScgi->param('issuedto');
	my $issuedby = $NQScgi->param('issuedby');
	my $scope = $NQScgi->param('scope');
	$scope =~ s/'/''/g;
	my $int_ext = $NQScgi->param('int_ext');
	my $msg;
	my $seq;
	
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	
	my $sqlstring = "select $schema.surveillance_" . $fy . "_seq.nextval from dual";
	my $seqstring = "select max(surveillance_seq) from $schema.surveillance ";
	$seqstring .= " where issuedby_org_id = $issuedby and fiscal_year = $fy ";
			
   eval {
		my $csr = $dbh->prepare($sqlstring);
		$csr->execute;
   	my @nextid=$csr->fetchrow_array;
   	
		$csr = $dbh->prepare($seqstring);
		$csr->execute;
		my @nextseq=$csr->fetchrow_array;
			
		if (!defined($nextseq[0])) {$seq = 1;}
		else {$seq = $nextseq[0] + 1;}

		my $insertstring = "insert into surveillance (id, fiscal_year, issuedto_org_id, scope, int_ext, issuedby_org_id, surveillance_seq) ";
		$insertstring .= "select $nextid[0],$fy,$issuedto,subject_detail,int_ext,$issuedby, $seq from surveillance_request ";
		$insertstring .= "where id = $rid and fiscal_year = $fy ";
	
		my $csr2 = $dbh->do($insertstring);
	
		my $orginsert = "insert into surveillance_org_loc (id,surveillance_id,fiscal_year, ";
		$orginsert .= "location_id, organization_id, supplier_id) ";
		$orginsert .= "select id, $nextid[0], fiscal_year, location_id, organization_id, supplier_id ";
		$orginsert .= "from request_org_loc where request_id = $rid and fiscal_year = $fy ";
	
		my $csr3 = $dbh->do($orginsert);
	
		my $requpdate = "update surveillance_request  ";
		$requpdate .= "set surveillance_id = $nextid[0] ";
		$requpdate .= "where id = $rid and fiscal_year = $fy ";
		
		my $csr4 = $dbh->do($requpdate);
	};
	if ($@) {
	   $dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error assigning surveillance $rid for fy $fy.  $@");
		$msg = "Error assigning Surveillance ID - Surveillance ID was not assigned";
	}
	else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username assigned surveillance $rid for fy $fy");
	   $msg = "Surveillance ID assigned successfully";
	}
	if ($fy < 50 ) {$fy2 = $fy + 2000;}
	else  {$fy2 = $fy + 1900;}
   print "<input type=hidden name=fy2 value=$fy2>";
	print <<browse2;
			<script language="JavaScript" type="text/javascript">
			<!--
			    alert ('$msg');
				 submitForm('request','browse_requests',0);
			//-->
			</script>
browse2

    
}


print<<queryformbottom;

</form>
</center>
</Body>
</HTML>

queryformbottom

 &NQS_disconnect($dbh);
exit();