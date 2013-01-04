#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/dattam/intradev/rcs/qa/perl/RCS/location_maint.pl,v $
#
# $Revision: 1.13 $
#
# $Date: 2007/07/12 17:27:12 $
#
# $Author: dattam $
#
# $Locker:  $
#
# $Log: location_maint.pl,v $
# Revision 1.13  2007/07/12 17:27:12  dattam
# Modified code so that the Lead Lab(SNL) personnel having the right privilege can add or modify locations (CREQ00099)
#
# Revision 1.12  2002/10/09 23:00:28  johnsonc
# Included 'use strict' pragma in script.
#
# Revision 1.11  2002/09/10 00:58:34  starkeyj
# modified privileges so OQA and BSC are separate - SCR 44
#
# Revision 1.10  2002/08/09 17:14:33  johnsonc
# Changed code to reflect new privileges added to the system.
#
# Revision 1.9  2002/01/03 21:59:25  johnsonc
# Fixed javascript error that occured in IE version 5.0
#
# Revision 1.8  2001/12/21 21:47:46  johnsonc
# Changed modify location logic so that the form submission is halted if the  modified location already exists in the system.
#
# Revision 1.7  2001/12/15 01:09:44  johnsonc
# Added verfication so that a new location cannot be added if that location already is in the system
#
# Revision 1.6  2001/12/07 23:53:27  johnsonc
# Divided active and inactive locations on main screen. Changed state and province text boxes to select objects. Format changes to screens sso that form elements fit on entire screen when viewed in a lower resolution monitor.
#
# Revision 1.5  2001/11/20 16:10:31  starkeyj
# modified add function to check for a unique city-state-province violation and added
# a popup after add or update to show status of transaction (successful or error)
#
# Revision 1.4  2001/11/05 18:40:13  starkeyj
# modified form validation so a city and province can both be entered
#
# Revision 1.3  2001/11/05 16:25:16  starkeyj
# changed path for background image
#
# Revision 1.2  2001/11/02 22:17:59  starkeyj
# added form validation and activity and error logs
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
my $externalDisabled;
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
print "<title>$pagetitle Maintenance</title>\n";

print <<testlabel1;
<!-- include external javascript code -->
<script src=$NQSJavaScriptPath/utilities.js></script>


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
      doSetTextImageLabel('Location Maintenance');
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
      if (isBlank(f.city.value)) {
		   msg2 = "You must enter a city\\n"; 
		}
		else if (f.state.selectedIndex == 0 && f.province.selectedIndex == 0) {
		   msg2 = "You have entered a city - you must also select a state or province\\n"; 
		}
      else if (arguments.length == 3) {
         var cityArray = arguments[1];
         var stateArray = arguments[2];
         var theCity = f.city.value.toLowerCase();
         var theState = f.state.value.toLowerCase();
         for (var i = 0; i < stateArray.length; i++) {
            var thisCity = cityArray[i].toLowerCase();
            var thisState = stateArray[i].toLowerCase();
            if (theCity == thisCity && theState == thisState) {
            	msg2 = f.city.value + ' ' + f.state.value + ' is already a location\\n';
            }
         }
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

function KeyEvent(f, cityArray, stateArray) {
	if (event.keyCode == 13) {
		if (validate(f, cityArray, stateArray)) {
			event.returnValue = true;
		}
		else {
			event.returnValue = false;
		}
	}
}
	
function ViewSelected(action) {
 	document.locmaint.action.value = action;
 	document.locmaint.submit();
}
 	
 	
    //-->
</script>
testlabel1

print "</head>\n\n";
print "<body background=$NQSImagePath/background.gif text=$NQSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><CENTER>\n";

# connect to the oracle database and generate a database handle
my $dbh = NQS_connect();
my %userprivhash = &get_user_privs($dbh,$userid);
if ($userprivhash{'Developer'} == 0 && $userprivhash{'BSC Internal Administration'} == 0 && $userprivhash{'OQA Internal Administration'} == 0 && $userprivhash{'SNL Internal Administration'} == 0) {
	$internalDisabled = " disabled=true ";
}
else {
	$internalDisabled = " ";
}
if ($userprivhash{'Developer'} == 0 && $userprivhash{'OQA Supplier Administration'} == 0 
  && $userprivhash{'BSC Supplier Administration'} == 0 && $userprivhash{'SNL Supplier Administration'} == 0) {
	$externalDisabled = " disabled=true ";
}
else {
	$externalDisabled = " ";
}
if ($userprivhash{'Developer'} == 0 && $userprivhash{'OQA Surveillance Administration'} == 0 && $userprivhash{'SNL Surveillance Administration'} == 0 && $userprivhash{'BSC Surveillance Administration'} == 0) {
	$surveillanceDisabled = " disabled=true ";
}
else {
	$surveillanceDisabled = " ";
}
#print "<center><h1>$pagetitle Maintenance</h1></center>\n";
print "<form action=\"$NQSCGIDir/location_maint.pl\" method=post name=locmaint>\n"; # onSubmit=\"return validate(this)\">\n";
print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=username type=hidden value=$username>\n";
print "<input name=userid type=hidden value=$userid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";

###############################
if ($cgiaction eq "add_location") {
###############################
    #$nextusersid = get_next_id($dbh, $updatetable);
    my $city = (defined($NQScgi->param('city'))) ? $NQScgi->param('city') : '';
    $city =~ s/\'/\'\'/g;
    my $state = (defined($NQScgi->param('state'))) ? $NQScgi->param('state') : '';
    my $province = (defined($NQScgi->param('province'))) ? $NQScgi->param('province') : '';
    $province =~ s/\'/\'\'/g;
    #$country = (defined($NQScgi->param('country'))) ? $NQScgi->param('country') : '';
    #$country =~ s/\'/\'\'/g;
    my $country = ($state ne "") ? "USA" : "CAN";
    my $internal_active = $NQScgi->param('internal_active')  ? 'T' : 'F';
    my $external_active = $NQScgi->param('external_active')  ? 'T' : 'F';
    my $surveillance_active = $NQScgi->param('surveillance_active')  ? 'T' : 'F';
    my $active = ($internal_active eq 'F' && $external_active eq 'F' && $surveillance_active eq 'F') ? 'F' : 'T';
    my $id = &get_city_state($dbh,$SCHEMA,$city,$state,$province,$country);
    my $nextlocid;
    if ($id == 0) {
    	$dbh->{AutoCommit} = 0;
	 	$dbh->{RaiseError} = 1;
	 
	 	eval {
    		$nextlocid = get_maximum_id($dbh, $updatetable) + 1;
	 		my $sqlstring = "INSERT INTO $SCHEMA.locations (id,city,state,province,country,internal_active, external_active, surveillance_active, active) ";
	 		$sqlstring .= "VALUES ($nextlocid, upper('$city'), '$state',upper('$province'),'$country', '$internal_active', '$external_active', '$surveillance_active', '$active')";
	 		my $rc = $dbh->do($sqlstring);
	 	};
	 	if ($@) {
			$dbh->rollback;
			&log_nqs_error($dbh,$SCHEMA,'T',$userid,"$username Error adding location $city $state $province $country .  $@");
			print "<script language=javascript type=text/javascript><!-- \n";
			print "  alert(\"Error adding location\")";
	 		print " \n//--></script> \n";
	 	}
	 	else {
			$dbh->commit;
			&log_nqs_activity($dbh,$SCHEMA,'F',$userid,"$username added location $city $state $province $country, id $nextlocid");
 	 		print "<script language=javascript type=text/javascript><!-- \n";
			print "  alert('$city, $state $province $country has been added as a location.')";
	 		print " \n//--></script> \n";
 	 	}
	   #print "<br> ** $sqlstring \n";
    	$cgiaction="query";
    }
    else {
      print "<input type=hidden name=locid value=$id>\n";
      print "<input type=hidden name=action value=modify_selected>\n";
    	print "<script language=javascript type=text/javascript><!-- \n";
	 	print "  alert(\"That location already exists\");\n";
	 	print "	document.locmaint.submit();\n";
	 	print " \n//--></script> \n";
#    	$cgiaction = "modify_selected";
    }
} ##############  endif add location  ########################

##################################
if ($cgiaction eq "modify_location") {
##################################
    # print the sql which will update this table
    my $thislocid = $NQScgi->param('thislocid');
    my $city = $NQScgi->param('city');
	 $city =~ s/\'/\'\'/g;
	 my $state = $NQScgi->param('state');
	 my $province = $NQScgi->param('province');
	 $province =~ s/\'/\'\'/g;
	 #$country = $NQScgi->param('country');
	 #$country =~ s/\'/\'\'/g;
	 my $internal_active = $NQScgi->param('internal_active')  ? 'T' : 'F';
    my $external_active = $NQScgi->param('external_active')  ? 'T' : 'F';
    my $surveillance_active = $NQScgi->param('surveillance_active')  ? 'T' : 'F';
    my $country = ($state ne "") ? "USA" : "CAN";
    
    my $sqlstring = "UPDATE $SCHEMA.$updatetable 
                  SET city = upper('$city'), state = '$state',
                      province = upper('$province'), country = '$country',
                      internal_active = '$internal_active', external_active = '$external_active',
                      surveillance_active = '$surveillance_active'";
    
    if ($internal_active eq 'F' && $external_active eq 'F' && $surveillance_active eq 'F') {
    	 $sqlstring .= ", active = 'F' ";
    }
    else {
    	 $sqlstring .= ", active = 'T' ";
    }
    $sqlstring .= "WHERE id=$thislocid";
    #$id = &get_city_state($dbh,$SCHEMA,$city,$state,$province,$country);
    #if ($id == 0 || $id == $thislocid) {
	 $dbh->{AutoCommit} = 0;
	 $dbh->{RaiseError} = 1;
	 print "<!-- $sqlstring -->\n";
	 eval {
    	my $rc = $dbh->do($sqlstring);
    };
    
    if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$SCHEMA,'T',$userid,"$username Error updating location $city $state $province $country, id $thislocid  $@");
	 	print "<script language=javascript type=text/javascript><!-- \n";
	 	print "  alert(\"Error updating location\")";
	 	print " \n//--></script> \n";
	 }
	 else {
		$dbh->commit;
		&log_nqs_activity($dbh,$SCHEMA,'F',$userid,"$username updated location $city $state $province $country, id $thislocid");
 		print "<script language=javascript type=text/javascript><!-- \n";
		print "  alert('$city, $state $province $country has been successfully modified')";
	 	print " \n//--></script> \n";
 	 }
    $cgiaction="query";
   
   # }
   # elsif ($id != 0 && $id != $thislocid) {
	#	print "<script language=javascript type=text/javascript><!-- \n";
	#	print "  alert(\"The modified location already exists\")";
	#	print " \n//--></script> \n";
	#	$cgiaction = "query";	
 	# }
 	# else {
 	# 	print "<script language=javascript type=text/javascript><!-- \n";
	# 	print "  alert(\"Error updating location\")";
	# 	print " \n//--></script> \n";
	 	
	# 	$cgiaction="query";
 	# }
 	 
}  ###############  endif modify loc  ####################

######################################
if ($cgiaction eq "modify_selected") {
######################################
	 my $thislocid;
    if (!(defined($NQScgi->param('locid')))) {
    	 $thislocid = (defined($NQScgi->param('availlocselect'))) ? $NQScgi->param('availlocselect') : $NQScgi->param('locselect');
    }
    else {
    	$thislocid = $NQScgi->param('locid');
    }
    $submitonly = 1;
    
    my %lochash = get_loc_info($dbh, $thislocid);
    
    # print the sql which will update this table
    #$city = 	$lochash{'city'};
    #$state =   $lochash{'state'};
    #$province = $lochash{'province'};
    #$USA = $lochash{'country'} eq 'USA' ? " checked " : " ";
    #$CA = $lochash{'country'} eq 'CAN' ? " checked " : " ";
    my $internal_checked = (defined($lochash{'internal_active'}) && $lochash{'internal_active'} eq 'T') ? " checked " : " ";
    my $external_checked = (defined($lochash{'external_active'}) && $lochash{'external_active'} eq 'T') ? " checked " : " ";
    my $surveillance_checked = (defined($lochash{'surveillance_active'}) &&  $lochash{'surveillance_active'} eq 'T') ? " checked " : " ";
    my $sqlstring = "SELECT city, state, province FROM $SCHEMA.locations WHERE id != $thislocid";
    my $rc = $dbh->prepare($sqlstring);
    $rc->execute;
    print "<script language=\"JavaScript\" type=\"text/javascript\">";
    print "<!--\n";
    print "var cityArray = new Array();\n";
    print "var stateArray = new Array();\n";
    my $i = 0;
	 while (my ($city, $state, $province) = $rc->fetchrow_array) {
	   if (defined($city)) {
	   	print "cityArray[$i] = '$city';\n";
	   }
	   else {	   	
	   	print "cityArray[$i] = '';\n";
	   }
	 	if (defined($state)) {
	 		print "stateArray[$i] = '$state';\n";
	 	}
	 	elsif (defined($province)) {
	 		print "stateArray[$i] = '$province';\n";	 	
	 	}
	 	else {
	 		print "stateArray[$i] = '';\n";
	 	}
	 	$i++;
	 }
	 $rc->finish;
    print "//-->\n";
    print "</script>\n";     
    $lochash{'city'} = (defined($lochash{'city'})) ? $lochash{'city'} : "";
    print <<modifyform;
    <center>
    <input name=cgiaction type=hidden value="modify_location">
    <input type=hidden name=schema value=$SCHEMA>
    <br><br>
    <table summary="modify location table" width="40%" border=0>
    <tr><td><b><li>Location ID:</b></td>
    <td><b>$thislocid</b>
    <input name=thislocid type=hidden value=$thislocid></td></tr>
    <tr><td align=left><b><li>City:</b></td>
    <td align=left><input name=city type=text maxlength=50 size=20 value="$lochash{'city'}" onKeypress="KeyEvent(document.locmaint, cityArray, stateArray);"></td></tr>
    <tr><td align=left><b><li>State:</b></td>
    <td align=left>
modifyform

	 $lochash{'state'} = (defined($lochash{'state'})) ? $lochash{'state'} : "";
    &print_states("$lochash{'state'}", "locmaint");
    
    print <<modifyform2;
    </td></tr>
    <tr><td align=left><b><li>Province:</b></td>
    <td align=left>
modifyform2

	 $lochash{'province'} = (defined($lochash{'province'})) ? $lochash{'province'} : "";
	 &print_provinces("$lochash{'province'}", "locmaint");
	 
	 print <<modifyform3;
    </td></tr>
	 <tr><td><b><li>Active for Internal Schedules:</b></td>
	 <td><input name=internal_active type=checkbox value='T' $internal_checked $internalDisabled></td></tr>
	 <tr><td><b><li>Active for External Schedules:</b></td>
    <td><input name=external_active type=checkbox value='T' $external_checked $externalDisabled></td></tr>
    <tr><td nowrap><b><li>Active for Surveillance Schedules:&nbsp;</b></td>
    <td><input name=surveillance_active type=checkbox value='T' $surveillance_checked $surveillanceDisabled></td></tr>
    </table>
    </center>
modifyform3

    print "<input name=action type=hidden value=modify_location>\n";
} ############## endif modify selected  #######################

###################################
if ($cgiaction eq "add_selected") {
###################################
    $submitonly = 1;
    print <<addform;
    <input name=cgiaction type=hidden value="add_location">
    <br><br>
    <table summary="modify location table" width="45%" border=0>
	 <tr><td><b><li>City:</b></td>
	 <td><input name=city type=text maxlength=50 size=20></td></tr>
	 <tr><td><b><li>State:</b></td>
	 <td align=left>
addform

    &print_states("","locmaint");
    print <<addform2;
    </td></tr>
	 <tr><td ><b><li>Province:</b></td>
	 <td>
addform2
    
    &print_provinces("","locmaint");
    print <<addform3;
	 </td></tr>
	 <tr><td><b><li>Active for Internal Schedules:</b></td>
	 <td><input name=internal_active type=checkbox value='T' $internalDisabled></td></tr>
	 <tr><td><b><li>Active for External Schedules:</b></td>
	 <td><input name=external_active type=checkbox value='T' $externalDisabled></td></tr>
    <tr><td nowrap><b><li>Active for Surveillance Schedules:&nbsp</b></td>
    <td><input name=surveillance_active type=checkbox value='T' $surveillanceDisabled></td></tr>
    </table>
addform3
    print "<input name=action type=hidden value=add_location>\n";
}
######################################
if ($cgiaction eq "view_selected") {
######################################
    my $thislocid = $NQScgi->param('availlocselect');
    $thislocid = (defined($NQScgi->param('locselect'))) ? $NQScgi->param('locselect') : $NQScgi->param('availlocselect');
    $submitonly = 1;
    
    my %lochash = get_loc_info($dbh, $thislocid);
    
    # print the sql which will update this table
    my $city = 	defined($lochash{'city'}) ? $lochash{'city'} : "";
    my $state =   defined($lochash{'state'}) ? $lochash{'state'} : "";
    my $province =   defined($lochash{'province'}) ? $lochash{'province'} : ""; 
    #$USA = $lochash{'country'} eq 'USA' ? "checked" : " ";
    #$CA = $lochash{'country'} eq 'CAN' ? "checked" : " ";
    my $country = $lochash{'country'};
    my $internal_checked = $lochash{'internal_active'} eq 'T' ? "checked" : "";
    my $external_checked = $lochash{'external_active'} eq 'T' ? "checked" : "";
    my $surveillance_checked = $lochash{'surveillance_active'} eq 'T' ? "checked" : "";
    
    print <<viewform;
    <input name=cgiaction type=hidden value="view_location">
    <input type=hidden name=schema value=$SCHEMA>
    <br><br>
    <table summary="view location table" width="40%" border=0>
    <tr><td><b><li>Location ID:</b></td><td><b>$thislocid</b></td></tr>
    <tr><td align=left><b><li>City:</b></td><td align=left>$city</td></tr>
viewform
    if ($state ne "") {
    	print "<tr><td align=left><b><li>State:</b></td><td align=left>$state</td></tr>\n";
    }
    else {
    	print "<tr><td align=left><b><li>Province:</b></td><td align=left>$province</td></tr>\n";
    }
    print <<viewform;
    <tr><td align=left><b><li>Country:</b></td><td align=left>$country</td></tr>
	 <tr><td><b><li>Active for Internal Schedules:</b></td>
	 <td><input name=internal_active type=checkbox value='T' $internal_checked disabled=true></td></tr>
	 <tr><td><b><li>Active for External Schedules:</b></td>
    <td><input name=external_active type=checkbox value='T' $external_checked disabled=true></td></tr>
    <tr><td nowrap><b><li>Active for Surveillance Schedules:&nbsp</b></td>
    <td><input name=surveillance_active type=checkbox value='T' $surveillance_checked disabled=true></td></tr>
    </table>
viewform
   # print "<br>\n";
} ############## endif view selected  #######################

############################
if ($cgiaction eq "query") {
############################
   my @locresults = get_locations($dbh);
   my $loc;
   my %locactive;
   my %locinactive;
	my $locnamestring;
	my $action;
	
   if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'SNL Supplier Administration'} == 1 || $userprivhash{'BSC Supplier Administration'} == 1
      || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1 || $userprivhash{'BSC Surveillance Administration'} == 1 
      || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'SNL Internal Administration'} == 1 || $userprivhash{'BSC Internal Administration'} == 1) {
      $action = "modify_selected";
   }
   else {
   	$action = "view_selected";
   }
   
   foreach my $array_ref (@locresults) { 
      my $loc = "";
      if (@$array_ref[0]) {$loc .= @$array_ref[0] . ', ';}
      if (@$array_ref[1]) {$loc .= @$array_ref[1] . ', ';}
      if (@$array_ref[2]) {$loc .= @$array_ref[2];}
      if (defined(@$array_ref[3]) && @$array_ref[3] ne 'USA' && @$array_ref[3] ne '' ) {$loc .=  @$array_ref[3];}
      if (@$array_ref[5] eq 'T') {
      	$locactive{$loc} = @$array_ref[4];
      }
      else {
      	$locinactive{$loc} = @$array_ref[4];
      }
		#print "<option value=\"@$array_ref[4]\">$loc\n";
   }
   
print<<table;
<br>
<br>
<table cellpadding=5 align=center>
<tr>
<td align=center><b>Active locations</b></td>
<td align=center><b>Inactive locations</b></td>
<tr>
<td><select name=availlocselect size=5 ondblclick=\"ViewSelected('$action');\" onClick=\"document.locmaint.locselect.selectedIndex = -1;\">
table

   foreach my $key (sort { lc($a) cmp lc($b) } keys %locactive) {
		$locnamestring = $key;
		$locnamestring =~ s/;$locactive{$key}//g;
		print "<option value=\"$locactive{$key}\">$locnamestring\n";
   }
   print "</select></td>\n<td><select name=locselect size=5 ondblclick=\"ViewSelected('$action');\" onClick=\"document.locmaint.availlocselect.selectedIndex = -1;\">\n";
   
   foreach my $key (sort { lc($a) cmp lc($b) } keys %locinactive) {
		$locnamestring = $key;
		$locnamestring =~ s/;$locinactive{$key}//g;
		print "<option value=\"$locinactive{$key}\">$locnamestring\n";
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


# print html footers.
print "<br><br>\n";
if ($submitonly == 0) {
	if ($userprivhash{'Developer'} == 1 || $userprivhash{'BSC Internal Administration'} == 1 || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'SNL Internal Administration'} == 1
  	|| $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'SNL Supplier Administration'} == 1 || $userprivhash{'BSC Supplier Administration'} == 1 
  	|| $userprivhash{'BSC Surveillance Administration'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1) {
    	print "<input name=add type=submit value=\"Add New Location\" title=\"Add New Location\" onclick=\"document.locmaint.action.value='add_selected'; submit();\">\n";
    	print "<input name=modify type=submit value=\"Modify Selected Location\" title=\"Modify the Selected Locations's Record\" onclick=\"dosubmit=true; (document.locmaint.availlocselect.selectedIndex == -1 && document.locmaint.locselect.selectedIndex == -1) ? (alert(\'No Location Selected\') || (dosubmit = false)) : document.locmaint.action.value='modify_selected'; return(dosubmit)\">\n";
	#  print "<input name=privilege type=submit value=\"Assign Privileges/Roles\" title=\"Assign privileges or Roles to the selected user\" onclick=\"dosubmit=true; (document.usermaint.selecteduser.selectedIndex == -1) ? (alert(\'No Organization Selected\') || (dosubmit = false)) : document.uorgmaint.action.value='assign_privileges'; return(dosubmit)\">\n";
	}
	else {
		print "<input name=view type=submit value=\"View Selected Location\" title=\"View the Selected Locations's Record\" onclick=\"dosubmit=true; (document.locmaint.availlocselect.selectedIndex == -1 && document.locmaint.locselect.selectedIndex == -1) ? (alert(\'No Location Selected\') || (dosubmit = false)) : document.locmaint.action.value='view_selected'; return(dosubmit)\">\n";
	}
}
else {
	if ($userprivhash{'Developer'} == 1 || $userprivhash{'BSC Internal Administration'} == 1 || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'SNL Internal Administration'} == 1
  	|| $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'SNL Supplier Administration'} == 1 || $userprivhash{'BSC Supplier Administration'} == 1 
  	|| $userprivhash{'BSC Surveillance Administration'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1) {
  	   if ($cgiaction eq "add_selected") {
    		print "<input name=submit type=submit value=\"Submit Changes\" onClick=\"return validate(document.locmaint)\">\n";
    	}
    	else {
    		print "<input name=submit type=submit value=\"Submit Changes\" onClick=\"return validate(document.locmaint, cityArray, stateArray)\">\n";
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
