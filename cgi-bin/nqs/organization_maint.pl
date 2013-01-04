#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/dattam/intradev/rcs/qa/perl/RCS/organization_maint.pl,v $
#
# $Revision: 1.14 $
#
# $Date: 2007/07/12 17:27:12 $
#
# $Author: dattam $
#
# $Locker:  $
#
# $Log: organization_maint.pl,v $
# Revision 1.14  2007/07/12 17:27:12  dattam
# Changed code so that Lead Lab(SNL) personnel having right privileges can add or modify organizations (CREQ00099)
#
# Revision 1.13  2005/07/12 16:12:05  starkeyj
# removed a print statement left over from debugging code
#
# Revision 1.12  2005/07/12 15:25:33  dattam
# new javascript function suborgvalidate added to validate the suborganization.
# add_suborganization, modify_suborganization, suborgmodify_selected, suborgadd_selected, suborgview_selected, suborg_query was added to add or modify a suborganization.
#
# Revision 1.11  2002/10/09 23:10:50  johnsonc
# Included 'use strict' pragma in script.
#
# Revision 1.10  2002/09/10 00:59:13  starkeyj
# modified privileges so OQA and BSC are separate - SCR 44
#
# Revision 1.9  2002/08/09 17:25:04  johnsonc
# Changed code to reflect new privileges added to the system.
#
# Revision 1.8  2002/01/03 21:58:59  johnsonc
# Fixed javascript error that occured in IE version 5.0
#
# Revision 1.7  2001/12/21 21:48:44  johnsonc
# Changed modify organization logic  so that the form submission is halted if the modified organization already exists in the system.
#
# Revision 1.6  2001/12/15 00:36:26  johnsonc
#  Added verification so that a new org cannot be added that has the same name or abbreviation as an existing organization.
#
# Revision 1.5  2001/12/07 23:57:47  johnsonc
#  Divided active and inactive orgs on main screen. Format changes to screens sso that form elements fit on entire screen when viewed in a lower resolution monitor.  Alert user when new org added or org is modified.
#
# Revision 1.4  2001/11/02 22:37:31  starkeyj
# added form verifications and activity and error logs
#
# Revision 1.3  2001/10/23 00:27:22  starkeyj
# changed user privs for editing audits
#
# Revision 1.2  2001/10/22 17:51:22  starkeyj
# no change, user error with RCS
#
# Revision 1.1  2001/10/19 23:32:19  starkeyj
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

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $NQScgi = new CGI;

my $SCHEMA = (defined($NQScgi->param("schema"))) ? $NQScgi->param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

# print content type header
print $NQScgi->header('text/html');

my $pagetitle = $NQScgi->param('pagetitle');
my $cgiaction = $NQScgi->param('action');
$cgiaction = ($cgiaction eq "") ? "query" : $cgiaction;
my $submitonly = 0;
my $userid = $NQScgi->param('userid');
my $username = $NQScgi->param('username');
my $updatetable = $NQScgi->param('updatetable');
my $internalDisabled;
my $surveillanceDisabled;




if ((!defined($userid)) || ($userid eq "") || (!defined($username)) || ($username eq "") || (!defined($pagetitle)) || ($pagetitle eq "") || (!defined($updatetable)) || ($updatetable eq "")) {
    print <<openloginpage;
    <script type="text/javascript">
    <!--
    parent.location='$NQSCGIDir/login.pl';
    //-->
    </script>
openloginpage
    exit 1;
}

#print html
print "<html>\n";
print "<head>\n";
print "<meta http-equiv=\"expires\" content=\"Fri, 12 May 1996 14:35:02 EST\">\n";
print "<title>$pagetitle Maintenanse</title>\n";

print <<testlabel1;
<!-- include external javascript code -->
<script src=$NQSJavaScriptPath/utilities.js></script>
<!--   <script src=/dcmm/prototype/javascript/dcmm-utilities.js></script> -->

    <script type="text/javascript">
    <!--
    var dosubmit = true;
    if (parent == self) {   // not in frames 
	location = '$NQSCGIDir/login.pl';
    }

    //-->
    </script>
  <script language="JavaScript" type="text/javascript">
  <!--
      doSetTextImageLabel('$pagetitle Maintenance');
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
  			 var f = arguments[0];
  			 
        if (f.length < 9) {

        	return true;
        }
        if (arguments.length == 3) {
           var org = arguments[1];
           var abbrev = arguments[2];
           var thisOrg = f.organization.value.toLowerCase();
           var thisAbbrev = f.abbr.value.toLowerCase();
           for (var i = 0; i < org.length; i++) {
              var theOrg = org[i].toLowerCase();
              var theAbbrev = abbrev[i].toLowerCase();
              if (thisOrg == theOrg || thisAbbrev == theAbbrev) {
            	  msg2 = f.organization.value + ' or ' + f.abbr.value + ' is already in the system\\n';
              }
           }
        }
        if (isBlank(f.organization.value) ) {
       	  msg2 = "You must enter an organization name\\n"; 
        }
        if (isBlank(f.abbr.value))  {
  			  msg2 = "You must enter an abbreviation for the organization\\n"; 
        }
       
               
       
                
     if (msg2) {
    	msg = "--------------------------------------------------------------\\n";
    	msg += "The form was not submitted because of the following error(s):\\n";
    	msg += "Please correct the error(s) and resubmit.\\n";
    	msg += "-------------------------------------------------------------\\n\\n";
    //	msg += " - The following required field(s) are empty: ";
    	msg += "       " + msg2 + "\\n";
    
    	alert(msg);
            return false;
     }
     else {
     	return true;
     }
   }


function suborgvalidate() {
          var msg = "";
          var msg2 = "";
  			 var f = arguments[0];
  		//	 
        if (f.length < 9) {

        	return true;
        }
        if (arguments.length == 3) {
           var suborg = arguments[1];
           var suborgabbrev = arguments[2];
           var thisSuborg = f.suborganization.value.toLowerCase();
           var thisAbbrev = f.abbr.value.toLowerCase();
           for (var i = 0; i < suborg.length; i++) {
              var theSuborg = suborg[i].toLowerCase();
              var theAbbrev = suborgabbrev[i].toLowerCase();
              if (thisSuborg == theSuborg || thisAbbrev == theAbbrev) {
            	  msg2 = f.suborganization.value + ' or ' + f.abbr.value + ' is already in the system\\n';
              }
           }
        }
        
       
       if (isBlank(f.suborganization.value) ) {
              	  msg2 = "You must enter a suborganization name\\n"; 
               }
               
       
        
       
                
     if (msg2) {
    	msg = "--------------------------------------------------------------\\n";
    	msg += "The form was not submitted because of the following error(s):\\n";
    	msg += "Please correct the error(s) and resubmit.\\n";
    	msg += "-------------------------------------------------------------\\n\\n";
    //	msg += " - The following required field(s) are empty: ";
    	msg += "       " + msg2 + "\\n";
    
    	alert(msg);
            return false;
     }
     else {
     	return true;
     }
   }
        

 	function ViewSelected(action) {
 	   document.orgmaint.action.value = action;
 	   document.orgmaint.submit();
 	}          
 	  
      //-->
</script>
testlabel1


print "</head>\n\n";
print "<body background=$NQSImagePath/background.gif text=$NQSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><CENTER>\n";

# connect to the oracle database and generate a database handle
my $dbh = NQS_connect();
my %userprivhash = &get_user_privs($dbh,$userid);
if ($userprivhash{'Developer'} == 0 && $userprivhash{'OQA Internal Administration'} == 0 && $userprivhash{'SNL Internal Administration'} == 0 && $userprivhash{'BSC Internal Administration'} == 0) {
	$internalDisabled = " disabled=true ";
}
else {
	$internalDisabled = " ";
}
if ($userprivhash{'Developer'} == 0 && $userprivhash{'OQA Surveillance Administration'} == 0 && $userprivhash{'SNL Surveillance Administration'} == 0 && $userprivhash{'BSC Surveillance Administration'} == 0) {
	$surveillanceDisabled = " disabled=true ";
}
else {
	$surveillanceDisabled = " ";
}

#print "<center><h1>$pagetitle Maintenance</h1></center>\n";
print "<form action=\"$NQSCGIDir/organization_maint.pl\" method=post name=orgmaint>\n"; #onSubmit=\"return validate(this)\">\n";
print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=username type=hidden value=$username>\n";
print "<input name=userid type=hidden value=$userid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";

###############################
if ($cgiaction eq "add_organization") {
###############################
    # print the sql which will update this table
    #$nextusersid = get_next_id($dbh, $updatetable);
    my $organization = $NQScgi->param('organization');
    $organization =~ s/\'/\'\'/g;
    my $abbr = $NQScgi->param('abbr');
    $abbr =~ s/\'/\'\'/g;
    my $internal_active = $NQScgi->param('internal_active')  ? 'T' : 'F';
    my $surveillance_active = $NQScgi->param('surveillanceactive')  ? 'T' : 'F';
    my $issuedTo_list = $NQScgi->param('issuedTo_list')  ? 'T' : 'F';
    my $performedOn_list = $NQScgi->param('perfromedOn_list')  ? 'T' : 'F';
    my $active = ($internal_active eq 'F' && $surveillance_active eq 'F' && $issuedTo_list eq 'F' && $performedOn_list eq 'F') ? 'F' : 'T';
    my $alertString = "";
    my $submit = "";
    my $orgid;
    $dbh->{AutoCommit} = 0;
	 $dbh->{RaiseError} = 1;
	
	 eval {
	 	my $sqlstring = "SELECT id FROM $SCHEMA.organizations WHERE UPPER(abbr) = '" . uc($abbr) . "'"
	 	              . " OR UPPER(organization) = '" . uc($organization) . "'";
		my $rc = $dbh->prepare($sqlstring);
		$rc->execute;
	 	$orgid = $rc->fetchrow_array;
	 	if (!(defined($orgid))) {
	 		my $nextorgid = get_maximum_id($dbh, $updatetable) + 1;
	 		$sqlstring = "INSERT INTO $SCHEMA.organizations (id,abbr,organization, internal_active, ";
	 		$sqlstring .= "issued_to_list, surveillance_active, performed_on_list, active) ";
	 		$sqlstring .= "VALUES ($nextorgid, '$abbr', '$organization', ";
	 		$sqlstring .= "'$internal_active', '$issuedTo_list','$surveillance_active', '$performedOn_list', '$active')";
	 		$rc = $dbh->do($sqlstring);
	 		$alertString = "$organization has been added as a organization.";
	 		$cgiaction = "query";
	 	}
	 	else {
	 		$alertString = "$organization or $abbr already exists in the system.";
	 		print "<input type=hidden name=action value=modify_selected>\n";
	 		print "<input type=hidden name=orgid value='$orgid'>\n";
         $submit = "document.orgmaint.submit();\n";                                       
	 	}
	 };
	 if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$SCHEMA,'T',$userid,"$username Error adding organization $organization.  $@");
		$alertString = "An error occurred while adding $organization or $abbr to the system.";
	 }
	 elsif (!(defined($orgid))) {
		$dbh->commit;
		&log_nqs_activity($dbh,$SCHEMA,'F',$userid,"$username added organization $organization");	
		#print "<br> ** $sqlstring \n";
	}
   print "<script language=\"JavaScript\">
			 <!--
			    alert('$alertString');
			    $submit
			  -->
			  </script>";
} ##############  endif add organization  ########################



###############################
if ($cgiaction eq "add_suborganization") {
###############################
    # print the sql which will update this table
    #$nextusersid = get_next_id($dbh, $updatetable);
    my $suborganization = $NQScgi->param('suborganization');
    $suborganization =~ s/\'/\'\'/g;
    my $suborgabbr = $NQScgi->param('suborgabbr');
    $suborgabbr =~ s/\'/\'\'/g;
    my $active = $NQScgi->param('active')  ? 'T' : 'F';
    my $alertString = "";
    my $submit = "";
    my $suborgid;
    $dbh->{AutoCommit} = 0;
	 $dbh->{RaiseError} = 1;
	
	 eval {
	 	my $sqlstring = "SELECT id FROM $SCHEMA.bsc_suborganizations WHERE UPPER(suborg_abbr) = '" . uc($suborgabbr) . "'"
	 	              . " OR UPPER(suborg) = '" . uc($suborganization) . "'";
	   print "<!-- $sqlstring -->\n";  
		my $rc = $dbh->prepare($sqlstring);
		$rc->execute;
	 	$suborgid = $rc->fetchrow_array;
	 	if (!(defined($suborgid))) {
	 		my $nextsuborgid = get_maximum_id($dbh, $updatetable) + 1;
	 		$sqlstring = "INSERT INTO $SCHEMA.bsc_suborganizations (id,orgid,suborg,suborg_abbr,active) ";
	 		$sqlstring .= "VALUES ($nextsuborgid,1, '$suborganization', '$suborgabbr', '$active') ";
	 		$rc = $dbh->do($sqlstring);
	 		$alertString = "$suborganization has been added as a BSC_suborganization.";
	 		$cgiaction = "suborg_query";
	 	}
	 	else {
	 		$alertString = "$suborganization or $suborgabbr already exists in the system.";
	 		print "<input type=hidden name=action value=suborgmodify_selected>\n";
	 		print "<input type=hidden name=suborgid value='$suborgid'>\n";
         $submit = "document.orgmaint.submit();\n";                                       
	 	}
	 };
	 if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$SCHEMA,'T',$userid,"$username Error adding suborganization $suborganization.  $@");
		$alertString = "An error occurred while adding $suborganization or $suborgabbr to the system.";
	 }
	 elsif (!(defined($suborgid))) {
		$dbh->commit;
		&log_nqs_activity($dbh,$SCHEMA,'F',$userid,"$username added suborganization $suborganization");	
		#print "<br> ** $sqlstring \n";
	}
   print "<script language=\"JavaScript\">
			 <!--
			    alert('$alertString');
			    $submit
			  -->
			  </script>";
} ##############  endif add organization  ########################



##################################
if ($cgiaction eq "modify_organization") {
##################################
    # print the sql which will update this table
    my $thisorgid = $NQScgi->param('thisorgid');
    my $organization = $NQScgi->param('organization');
    $organization =~ s/\'/\'\'/g;
    my $abbr = $NQScgi->param('abbr');
    $abbr =~ s/\'/\'\'/g;
    my $internal_active = $NQScgi->param('internal_active')  ? 'T' : 'F';
	 my $surveillance_active = $NQScgi->param('surveillance_active')  ? 'T' : 'F';
	 my $issuedTo_list = $NQScgi->param('issuedTo_list')  ? 'T' : 'F';
    my $performedOn_list = $NQScgi->param('performedOn_list')  ? 'T' : 'F';
    my $active = ($internal_active eq 'F' && $surveillance_active eq 'F' && $issuedTo_list eq 'F' && $performedOn_list eq 'F') ? 'F' : 'T';
    my $alertString = "";
    $dbh->{AutoCommit} = 0;
	 $dbh->{RaiseError} = 1;
	 eval {
    	my $sqlstring = "UPDATE $SCHEMA.$updatetable 
                    SET organization ='$organization', abbr ='$abbr', active = '$active', 
                    internal_active = '$internal_active', issued_to_list = '$issuedTo_list',
                    surveillance_active = '$surveillance_active', performed_on_list = '$performedOn_list'
                    WHERE id=$thisorgid";
    	my $rc = $dbh->do($sqlstring);
    };
    if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$SCHEMA,'T',$userid,"$username Error updating organization $organization, id $thisorgid.  $@");
		$alertString = "An error occurred while modifying $organization or $abbr in the system.";
	 }
	 else {
		$dbh->commit;
		&log_nqs_activity($dbh,$SCHEMA,'F',$userid,"$username updated organization $organization, id $thisorgid");
		$alertString = "$organization has been successfully modified.";
	 }
    print "<script language=\"JavaScript\">
		  	  <!--
		  	 	    alert('$alertString');
		  	   -->
		  	  </script>";
    $cgiaction="query";
}  ###############  endif modify org  ####################

##################################
if ($cgiaction eq "modify_suborganization") {
##################################
    # print the sql which will update this table
    my $thissuborgid = $NQScgi->param('thissuborgid');
    my $suborganization = $NQScgi->param('suborganization');
    $suborganization =~ s/\'/\'\'/g;
    my $abbr = $NQScgi->param('abbr');
    $abbr =~ s/\'/\'\'/g;
    my $active = $NQScgi->param('active')  ? 'T' : 'F';
    my $alertString = "";
    $dbh->{AutoCommit} = 0;
	 $dbh->{RaiseError} = 1;
	 eval {
    	my $sqlstring = "UPDATE $SCHEMA.$updatetable 
                    SET suborg ='$suborganization', suborg_abbr ='$abbr', active = '$active' 
                    WHERE id=$thissuborgid";
    	my $rc = $dbh->do($sqlstring);
    };
    if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$SCHEMA,'T',$userid,"$username Error updating suborganization $suborganization, id $thissuborgid.  $@");
		$alertString = "An error occurred while modifying $suborganization or $abbr in the system.";
	 }
	 else {
		$dbh->commit;
		&log_nqs_activity($dbh,$SCHEMA,'F',$userid,"$username updated suborganization $suborganization, id $thissuborgid");
		$alertString = "$suborganization has been successfully modified.";
	 }
    print "<script language=\"JavaScript\">
		  	  <!--
		  	 	    alert('$alertString');
		  	   -->
		  	  </script>";
    $cgiaction="suborg_query";
}  ###############  endif modify suborg  ####################


######################################
if ($cgiaction eq "modify_selected") {
######################################
	 my $thisorgid = defined($NQScgi->param('availorgselect')) ? $NQScgi->param('availorgselect') : defined($NQScgi->param('orgid')) ? $NQScgi->param('orgid') : $NQScgi->param('orgselect');
    $submitonly = 1;
    
    my %orghash = get_org_info($dbh, $thisorgid);
    
    # print the sql which will update this table
    my $organization = 	$orghash{'organization'};
    my $abbr =    		$orghash{'abbr'};
    my $internal_checked = $orghash{'internal_active'} eq 'T' ? " checked" : " ";
    my $issuedTo_checked = $orghash{'issuedTo_list'} eq 'T' ? " checked" : " ";
    my $surveillance_checked = $orghash{'surveillance_active'} eq 'T' ? " checked" : " ";
    my $performedOn_checked = $orghash{'performedOn_list'} eq 'T' ? " checked" : " ";
    my $sqlstring = "SELECT organization, abbr FROM $SCHEMA.organizations WHERE id != $thisorgid";
	 my $rc = $dbh->prepare($sqlstring);
	 $rc->execute;
    print "<script language=\"JavaScript\" type=\"text/javascript\">";
    print "<!--\n";
    print "var org = new Array();\n";
    print "var abbrev = new Array();\n";
    my $i = 0;
	 while (my ($org, $abbrev) = $rc->fetchrow_array) {
	 	print "org[$i] = '$org';\n";
	 	print "abbrev[$i] = '$abbrev';\n";	 
	   $i++;
	 }
    print "//-->\n";
    print "</script>\n";
    $rc->finish;
    #    <input name=thisorgname type=hidden value=$thisorgname></td></tr>

    print <<modifyform;
    <input name=cgiaction type=hidden value="modify_organization">
    <input type=hidden name=schema value=$SCHEMA>
    <br><br>
    <table summary="modify organization table" width="50%" border=0>
    <tr><td><b><li>Organization ID:</b></td>
    <td><b>$thisorgid</b>
    <input name=thisorgid type=hidden value=$thisorgid>
    <tr><td align=left><b><li>Organization:</b></td>
    <td align=left><input name=organization type=text maxlength=80 size=35 value="$organization" onload="focus()"></td></tr>
    <tr><td align=left nowrap><b><li>Organization Abbreviation:</b></td>
    <td align=left><input name=abbr type=text maxlength=10 size=10 value="$abbr"></td></tr>
	 <tr><td><b><li>Active for Internal Audits:</b></td>
	 <td><input name=internal_active type=checkbox value='T' $internal_checked $internalDisabled></td></tr>
    <tr><td><b><li>Add to 'Issued To' List:</b></td>
    <td><input name=issuedTo_list type=checkbox value='T' $issuedTo_checked $internalDisabled></td></tr>
    <tr><td><b><li>Active for Surveillances:</b></td>
	 <td><input name=surveillance_active type=checkbox value='T' $surveillance_checked  $surveillanceDisabled></td></tr>
	 <tr><td nowrap><b><li>Add to 'Performed On' List:</b></td>
    <td><input name=performedOn_list type=checkbox value='T' $performedOn_checked $surveillanceDisabled></td></tr>
    </table>
modifyform
    #print "<br>\n";
    print "<input name=action type=hidden value=modify_organization>\n";
} ############## endif modify selected  #######################



######################################
if ($cgiaction eq "suborgmodify_selected") {
######################################
	 my $thissuborgid = defined($NQScgi->param('availsuborgselect')) ? $NQScgi->param('availsuborgselect') : defined($NQScgi->param('suborgid')) ? $NQScgi->param('suborgid') : $NQScgi->param('suborgselect');
    $submitonly = 1;
    
      
    
    my %suborghash = get_suborg_info($dbh, $thissuborgid);
    
    # print the sql which will update this table
    my $suborganization = 	$suborghash{'suborg'};
    my $abbr =    		$suborghash{'suborg_abbr'};
    
       
    my $internal_checked = $suborghash{'active'} eq 'T' ? " checked" : " ";
    
    my $sqlstring = "SELECT suborg, suborg_abbr FROM $SCHEMA.bsc_suborganizations WHERE id != $thissuborgid";
	 my $rc = $dbh->prepare($sqlstring);
	 $rc->execute;
    print "<script language=\"JavaScript\" type=\"text/javascript\">";
    print "<!--\n";
    print "var suborg = new Array();\n";
    print "var abbrev = new Array();\n";
    my $i = 0;
	 while (my ($suborg, $abbrev) = $rc->fetchrow_array) {
	 	print "suborg[$i] = '$suborg';\n";
	 	print "abbrev[$i] = '$abbrev';\n";	 
	   $i++;
	 }
    print "//-->\n";
    print "</script>\n";
    $rc->finish;
    #    <input name=thisorgname type=hidden value=$thisorgname></td></tr>

    print <<modifyform;
    <input name=cgiaction type=hidden value="modify_suborganization">
    <input type=hidden name=schema value=$SCHEMA>
    <br><br>
    <table summary="modify suborganization table" width="50%" border=0>
    <tr><td><b><li>Suborganization ID:</b></td>
    <td><b>$thissuborgid</b>
    <input name=thissuborgid type=hidden value=$thissuborgid>
    <tr><td align=left><b><li>Suborganization:</b></td>
    <td align=left><input name=suborganization type=text maxlength=80 size=35 value="$suborganization" onload="focus()"></td></tr>
    <tr><td align=left nowrap><b><li>Suborganization Abbreviation:</b></td>
    <td align=left><input name=abbr type=text maxlength=10 size=10 value="$abbr"></td></tr>
	 <tr><td><b><li>Active</b></td>
	 <td><input name=active type=checkbox value='T' $internal_checked $internalDisabled></td></tr>
    </table>
modifyform
    #print "<br>\n";
    print "<input name=action type=hidden value=modify_suborganization>\n";
} ############## endif modify selected  #######################



###################################
if ($cgiaction eq "add_selected") {
###################################
    $submitonly = 1;
    my %orghash = get_lookup_values($dbh, 'organizations', 'organization', 'id');
    
    print <<addform;
    <input name=cgiaction type=hidden value="add_organization">
    <br><br>
    <table summary="add user table" width="50%" border=0>
    <tr><td><b><li>Organization:</b></td>
    <td><input name=organization type=text maxlength=80 size=35></td></tr>
    <tr><td><b><li>Organization Abbreviation:</b></td>
    <td><input name=abbr type=text maxlength=10 size=10></td></tr>
    <tr><td><b><li>Active for Internal Audits:</b></td>
    <td><input name=internal_active type=checkbox value='T' $internalDisabled></td></tr>
    <tr><td><b><li>Add to 'Issued To' List:</b></td>
    <td><input name=issuedTo_list type=checkbox value='T' $internalDisabled></td></tr>
    <tr><td><b><li>Active for Surveillances:</b></td>
	 <td><input name=surveillance_active type=checkbox value='T'  $surveillanceDisabled></td></tr>
	 <tr><td><b><li>Add to 'Performed On' List:</b></td>
    <td><input name=performedOn_list type=checkbox value='T'  $surveillanceDisabled></td></tr>
    </table>
addform
    print "<input name=action type=hidden value=add_organization>\n";
}


###################################
if ($cgiaction eq "suborgadd_selected") {
###################################
    $submitonly = 1;
    my %orghash = get_lookup_values($dbh, 'bsc_suborganizations', 'suborg', 'id');
    
    print <<addform;
    <input name=cgiaction type=hidden value="add_suborganization">
    <br><br>
    <table summary="add user table" width="50%" border=0>
    <tr><td><b><li>Suborganization:</b></td>
    <td><input name=suborganization type=text maxlength=80 size=35></td></tr>
    <tr><td><b><li>Suborganization Abbreviation:</b></td>
    <td><input name=suborgabbr type=text maxlength=10 size=10></td></tr>
    <tr><td><b><li>Active:</b></td>
    <td><input name=active type=checkbox value='T' $internalDisabled></td></tr>
    </table>
addform
    print "<input name=action type=hidden value=add_suborganization>\n";
}


######################################
if ($cgiaction eq "view_selected") {
######################################
    my $thisorgid = defined($NQScgi->param('availorgselect')) ? $NQScgi->param('availorgselect') : $NQScgi->param('orgselect');
    $submitonly = 1;
    
     my %orghash = get_org_info($dbh, $thisorgid);
    
    # print the sql which will update this table
    my $organization = 	$orghash{'organization'};
    my $abbr =    		$orghash{'abbr'};
    my $internal_checked = $orghash{'internal_active'} eq 'T' ? " checked " : " ";
	 my $issuedTo_checked = $orghash{'issuedTo_list'} eq 'T' ? " checked " : " ";
	 my $surveillance_checked = $orghash{'surveillance_active'} eq 'T' ? " checked " : " ";
    my $performedOn_checked = $orghash{'performedOn_list'} eq 'T' ? " checked " : " ";
    
    print <<modifyform;
    <br><br>
    <table summary="view organization table" width="50%" cellpadding="2" border=0>
    <tr><td><b><li>Organization ID:</b></td>
    <td><b>$thisorgid</b></td></tr>
    <tr><td><b><li>Organization:</b></td><td nowrap align=left>$organization</td></tr>
    <tr><td><b><li>Organization Abbreviation:</b></td><td align=left>$abbr</td></tr>
	 <tr><td><b><li>Active for Internal Audits:</b></td>
	 <td><input name=internal_active type=checkbox value='T' $internal_checked  disabled=true></td></tr>
	 <tr><td><b><li>Add to 'Issued To' List:</b></td>
	 <td><input name=issuedTo_list type=checkbox value='T' $issuedTo_checked  disabled=true></td></tr>
	 <tr><td><b><li>Active for Surveillances:</b></td>
	 <td><input name=surveillance_active type=checkbox value='T' $surveillance_checked  disabled=true></td></tr>
	 <tr><td nowrap><b><li>Add to 'Performed On' List:</b></td>
    <td><input name=performedOn_list type=checkbox value='T' $performedOn_checked  disabled=true></td></tr>
    </table>
modifyform
    #print "<br>\n";
} ############## endif view selected  #######################


######################################
if ($cgiaction eq "suborgview_selected") {
######################################
    my $thissuborgid = defined($NQScgi->param('availsuborgselect')) ? $NQScgi->param('availsuborgselect') : $NQScgi->param('suborgselect');
    $submitonly = 1;
    
     my %suborghash = get_suborg_info($dbh, $thissuborgid);
    
    # print the sql which will update this table
    
    my $suborganization = 	$suborghash{'suborg'};
    my $abbr =    		$suborghash{'suborg_abbr'};
        
    my $internal_checked = $suborghash{'active'} eq 'T' ? " checked" : " ";
    
    print <<modifyform;
    <br><br>
    <table summary="view organization table" width="50%" cellpadding="2" border=0>
    <tr><td><b><li>Suborganization ID:</b></td>
    <td><b>$thissuborgid</b></td></tr>
    <tr><td><b><li>Suborganization:</b></td><td nowrap align=left>$suborganization</td></tr>
    <tr><td><b><li>Suborganization Abbreviation:</b></td><td align=left>$abbr</td></tr>
	 <tr><td><b><li>Active:</b></td>
	 <td><input name=internal_active type=checkbox value='T' $internal_checked  disabled=true></td></tr>
    </table>
modifyform
    #print "<br>\n";
} ############## endif view selected  #######################





############################
if ($cgiaction eq "query") {
############################
    my %orgactive = get_lookup_values($dbh, 'organizations', 'organization', 'id', "active = 'T'");
    my %orginactive = get_lookup_values($dbh, 'organizations', 'organization', 'id', "active = 'F'");
    my $action;
   if ($userprivhash{'Developer'} == 1 
      || $userprivhash{'BSC Surveillance Administration'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1
      || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'SNL Internal Administration'} == 1 || $userprivhash{'BSC Internal Administration'} == 1) {
      $action = "modify_selected";
   }
   else {
   	$action = "view_selected";
   }
   
	print<<table;
<br>
<table cellpadding=5 align=center>
<tr>
<td align=center><b>Active organizations</b></td>
</tr>
<tr>
<td align=center><select name=availorgselect size=5 ondblclick=\"ViewSelected('$action');\" onClick=\"document.orgmaint.orgselect.selectedIndex = -1;\">
table

   foreach my $key (sort { lc($a) cmp lc($b) } keys %orgactive) {
	  my $orgstring = $key;
	  $orgstring =~ s/;orgactive{$key}//g;
	  print "<option value=\"$orgactive{$key}\">$orgstring\n";
    }

   print "</select></td>\n<tr>\n<td align=center><b>Inactive organizations</b></td></tr>\n";
   print "<tr>\n<td align=center><select name=orgselect size=5 ondblclick=\"ViewSelected('$action');\" onClick=\"document.orgmaint.availorgselect.selectedIndex = -1;\">\n";
   foreach my $key (sort { lc($a) cmp lc($b) } keys %orginactive) {
		my $orgnamestring = $key;
		$orgnamestring =~ s/;$orginactive{$key}//g;
		print "<option value=\"$orginactive{$key}\">$orgnamestring\n";
   }
   
   print <<block;
</select>	
</td>
</tr>
</table>
<input name=action type=hidden value=''>
block


}

############################
if ($cgiaction eq "suborg_query") {
############################
    
    my %suborgactive = get_lookup_values($dbh, 'bsc_suborganizations', 'suborg', 'id', "active = 'T' and labid is null");
    my %suborginactive = get_lookup_values($dbh, 'bsc_suborganizations', 'suborg', 'id', "active = 'F' and labid is null");
    my $action;
   if ($userprivhash{'Developer'} == 1 
      || $userprivhash{'BSC Surveillance Administration'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1
      || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'SNL Internal Administration'} == 1 || $userprivhash{'BSC Internal Administration'} == 1) {
      $action = "suborgmodify_selected";
   }
   else {
   	$action = "suborgview_selected";
   }
   
	print<<table;
<br>
<table cellpadding=5 align=center>
<tr>
<td align=center><b>Active Suborganizations</b></td>
</tr>
<tr>
<td align=center><select name=availsuborgselect size=5 ondblclick=\"ViewSelected('$action');\" onClick=\"document.orgmaint.suborgselect.selectedIndex = -1;\">
table

   foreach my $key (sort { lc($a) cmp lc($b) } keys %suborgactive) {
	  my $suborgstring = $key;
	  $suborgstring =~ s/;suborgactive{$key}//g;
	  print "<option value=\"$suborgactive{$key}\">$suborgstring\n";
    }

   print "</select></td>\n<tr>\n<td align=center><b>Inactive Suborganizations</b></td></tr>\n";
   print "<tr>\n<td align=center><select name=suborgselect size=5 ondblclick=\"ViewSelected('$action');\" onClick=\"document.orgmaint.availsuborgselect.selectedIndex = -1;\">\n";
   foreach my $key (sort { lc($a) cmp lc($b) } keys %suborginactive) {
		my $suborgnamestring = $key;
		$suborgnamestring =~ s/;$suborginactive{$key}//g;
		print "<option value=\"$suborginactive{$key}\">$suborgnamestring\n";
   }
   
   print <<block;
</select>	
</td>
</tr>
<tr><td><br><i>To add a supplier to the BSC suborganization list, use the Supplier Maintenance form</i></td></tr>
</table>
<input name=action type=hidden value=''>
block


}

#print "<input name=add type=submit value=\"Add New $pagetitle\" title=\"Add New Organization\" onclick=\"document.orgmaint.action.value=  ($cgiaction eq 'query') ? 'add_selected' : 'suborgadd_selected'; submit();\">&nbsp;\n";

#disconnect from the database
&NQS_disconnect($dbh);


# print html footers.
print "<br>\n";
if ($submitonly == 0) {
	if ($userprivhash{'Developer'} == 1 || $userprivhash{'BSC Internal Administration'} == 1 || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'SNL Internal Administration'} == 1
	   || $userprivhash{'BSC Surveillance Administration'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1) {
	   if ($cgiaction eq "query") {
    	       print "<input name=add type=submit value=\"Add New $pagetitle\" title=\"Add New Organization\" onclick=\"document.orgmaint.action.value='add_selected'; submit();\">&nbsp;\n";
    	       print "<input name=modify type=submit value=\"Modify Selected $pagetitle\" title=\"Modify the Selected Organizations's Record\" onclick=\"dosubmit=true; (document.orgmaint.availorgselect.selectedIndex == -1 && document.orgmaint.orgselect.selectedIndex == -1) ? (alert(\'No Organization Selected\') || (dosubmit = false)) : document.orgmaint.action.value='modify_selected'; return(dosubmit)\">\n";
    	   }
    	   
    	    elsif ($cgiaction eq "suborg_query") 
    	   {
    	       print "<input name=add type=submit value=\"Add New $pagetitle\" title=\"Add New Organization\" onclick=\"document.orgmaint.action.value='suborgadd_selected'; submit();\">&nbsp;\n";
	       print "<input name=modify type=submit value=\"Modify Selected $pagetitle\" title=\"Modify the Selected Organizations's Record\" onclick=\"dosubmit=true; (document.orgmaint.availsuborgselect.selectedIndex == -1 && document.orgmaint.suborgselect.selectedIndex == -1) ? (alert(\'No Organization Selected\') || (dosubmit = false)) : document.orgmaint.action.value='suborgmodify_selected'; return(dosubmit)\">\n";
    	   }
	#  print "<input name=privilege type=submit value=\"Assign Privileges/Roles\" title=\"Assign privileges or Roles to the selected user\" onclick=\"dosubmit=true; (document.usermaint.selecteduser.selectedIndex == -1) ? (alert(\'No Organization Selected\') || (dosubmit = false)) : document.orgmaint.action.value='assign_privileges'; return(dosubmit)\">\n";
	}
	else {
		print "<input name=view type=submit value=\"View Selected Organization\" title=\"View the Selected Organizations's Record\" onclick=\"dosubmit=true; (document.orgmaint.availorgselect.selectedIndex == -1 && document.orgmaint.orgselect.selectedIndex == -1) ? (alert(\'No Organization Selected\') || (dosubmit = false)) : document.orgmaint.action.value='view_selected'; return(dosubmit)\">\n";
	}
}
else {
	if ($userprivhash{'Developer'} == 1 || $userprivhash{'BSC Internal Administration'} == 1 || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'SNL Internal Administration'} == 1
	   || $userprivhash{'BSC Surveillance Administration'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1) {
	   if ($cgiaction eq "add_selected") {
    		print "<input name=submit type=submit value=\"Submit Changes\"  onClick=\"return validate(document.orgmaint)\">";
    	}
    	elsif ($cgiaction eq "suborgadd_selected") {
    		print "<input name=submit type=submit value=\"Submit Changes\"  onClick=\"return suborgvalidate(document.orgmaint)\">";
    	}
    	
    	elsif ($cgiaction eq "suborgmodify_selected") {
	    		print "<input name=submit type=submit value=\"Submit Changes\"  onClick=\"return suborgvalidate(document.orgmaint)\">";
    	}
    	else {
    		print "<input name=submit type=submit value=\"Submit Changes\"  onClick=\"return validate(document.orgmaint, org, abbrev)\">";
    	}
   }
}
print "</form>\n";
# menu to return to the maintenance menu and the main screen
#print "<ul title=\"Link Menu\"><b>Link Menu</b>\n<li><a href=\"/dcmm/prototype/maintenance.htm\">Maintenance Screen</a></li>\n";
#print "<li><a href=\"/dcmm/prototype/home.htm\">Main Menu</a></li>\n";
#print "</ul><br><br>\n";

print "</CENTER><br><br><br><br></body>\n";
print "</html>\n";



