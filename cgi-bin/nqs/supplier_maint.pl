#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/dattam/intradev/rcs/qa/perl/RCS/supplier_maint.pl,v $
#
# $Revision: 1.14 $
#
# $Date: 2007/07/12 17:27:12 $
#
# $Author: dattam $
#
# $Locker:  $
#
# $Log: supplier_maint.pl,v $
# Revision 1.14  2007/07/12 17:27:12  dattam
# Modified code so that the Lead Lab(SNL) personnel having the right privilege can add or modify
# suppliers (CREQ00099)
#
# Revision 1.13  2005/07/13 15:25:35  starkeyj
# modified view_selected to add the BSC Suborganization Active checkbox
# modified modify_selected to include internal admin and surveillance admin privileges to the BSC_suborg checkbox
# modified add_selected to add the BSC Suborganization checkbox and added the insert statement to add the lab to the BSC Suborganization table when the BSC Suborganiztion checkbox is selected
#
# Revision 1.12  2005/07/12 15:19:57  dattam
# modify_selected and add_selected - added BSC_Suborganization check box.
# modify_supplier - added new supplier in the BSC_Suborganization table if the bscsuborg_active is checked.
#
# Revision 1.11  2002/10/09 23:01:55  johnsonc
# Included 'use strict' pragma in script.
#
# Revision 1.10  2002/10/08 22:51:35  starkeyj
# modified all functions to enforce 'use strict'
#
# Revision 1.9  2002/09/10 01:01:15  starkeyj
# modified privileges so BSC and OQA are separate - SCR 44
#
# Revision 1.8  2002/08/09 18:25:15  johnsonc
# Changed code to reflect new privileges added to the system.
#
# Revision 1.7  2002/01/03 22:03:25  johnsonc
# Fixed javascript error that occured in IE version 5.0
#
# Revision 1.6  2001/12/21 21:49:51  johnsonc
# Changed modify supplier logic so that the form submission is halted if the modified supplier already exists in the system.
#
# Revision 1.5  2001/12/15 00:51:54  johnsonc
# Added verification so that a new supplier cannot be added if the name is the same as an existing supplier in the system.
#
# Revision 1.4  2001/12/07 23:56:01  johnsonc
# Divided active and inactive suppliers on main screen. Format changes to screens sso that form elements fit on entire screen when viewed in a lower resolution monitor. Alert user when new supplier added or supplier is modified.
#
# Revision 1.3  2001/11/02 22:44:30  starkeyj
# added form validation and error and activity logs
#
# Revision 1.2  2001/10/22 17:58:03  starkeyj
# no change, user error with RCS
#
# Revision 1.1  2001/10/19 23:32:19  starkeyj
# Initial revision
#
#
# Revision: $
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
my $userid = $NQScgi->param('userid');
my $username = $NQScgi->param('username');
my $updatetable = $NQScgi->param('updatetable');
my $alertString;

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
      doSetTextImageLabel('Supplier Maintenance');
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
          if (isBlank(f.company.value) ) {
            msg2 += "You must enter the company name\\n"; 
          }    
          if (!(isBlank(f.city.value)) && f.state.selectedIndex == 0 && f.province.selectedIndex == 0) {
          	msg2 += "You have entered a city - you must also select a state or province\\n";
          }	
          if (arguments.length == 2 && msg2 == "") {
             var suppliers = arguments[1];
             var theSupplier = f.company.value.toLowerCase();
             for (var i = 0; i < suppliers.length; i++) {
            	 var thisSupplier = suppliers[i].toLowerCase();
            	 if (theSupplier == thisSupplier) {
            		 msg2 = f.company.value + ' is already in the system\\n';
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
     
     function checkDate(val,e) {
	     var valid = 1;
	  	if (val != '') {
	  		valid =  validateDate2(val);
	  	}
	  	if (!valid) {
	  		e.focus();
	  	}
     }

 	  function ViewSelected(action) {
 	     document.suppliermaint.action.value = action;
 	     document.suppliermaint.submit();
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
print "<form action=\"$NQSCGIDir/supplier_maint.pl\" method=post name=suppliermaint>\n"; #  onSubmit=\"return validate(this)\">\n";
print "<input name=updatetable type=hidden value=$updatetable>\n";
print "<input name=username type=hidden value=$username>\n";
print "<input name=userid type=hidden value=$userid>\n";
print "<input name=pagetitle type=hidden value=\"$pagetitle\">\n";

###############################
if ($cgiaction eq "add_supplier") {
###############################
    # print the sql which will update this table
    #$submitonly = 2;
	 my $company = 	$NQScgi->param('company');
	 my $address1 = $NQScgi->param('address1'); 
	 my $address2 = $NQScgi->param('address2');
	 my $city =    		$NQScgi->param('city');
	 my $state = $NQScgi->param('state');
	 #$zip = $NQScgi->param('zip');
	 my $province = $NQScgi->param('province');
	 #$country = $NQScgi->param('country');
	 #$f_zip = $NQScgi->param('f_zip');
	 #$areacode1 = $NQScgi->param('areacode1');
	 #$phone1 = $NQScgi->param('phone1');
	 #$extension = $NQScgi->param('extension');
	 #$areacode2 = $NQScgi->param('areacode2');
	 #$phone2 = $NQScgi->param('phone2');
	 #$areacode_fax = $NQScgi->param('areacode_fax');
	 #$fax = $NQScgi->param('fax');
	 my $qual_date = $NQScgi->param('qual_date');
	 my $next_due = $NQScgi->param('next_due');
	 #$cat_id = $NQScgi->param('cat_id');
	 my $external_active = $NQScgi->param('external_active') ? 'T' : 'F';
	 my $surveillance_active = $NQScgi->param('surveillance_active') ? 'T' : 'F';
	 my $bscsuborg_active = $NQScgi->param('bscsuborg_active') ? 'T' : 'F';
	 my $active =  ($external_active eq 'F' && $surveillance_active eq 'F' && $bscsuborg_active eq 'F') ? 'F' : 'T';
	 my $country = ($state ne "") ? "USA" : "CAN";
	 my $nextsupplierid;
	 my $companyid;
	 my $submit = "";
    
    $dbh->{AutoCommit} = 0;
	 $dbh->{RaiseError} = 1;
	 
    eval {
    	my $sqlstring = "SELECT id FROM $SCHEMA.qualified_supplier WHERE UPPER(company_name) = '" . uc($company) . "'";
		my $rc = $dbh->prepare($sqlstring);
		$rc->execute;
	 	$companyid = $rc->fetchrow_array;
	 	if (!(defined($companyid))) {
    		$nextsupplierid = get_maximum_id($dbh, 'qualified_supplier') + 1;
	 		$sqlstring = "INSERT INTO $SCHEMA.qualified_supplier (id,company_name,city, surveillance_active, active, ";
	 		$sqlstring .= "external_active, bscsuborg_active,address1,address2,state,province,country ";
	 		if ($qual_date) {$sqlstring .= ",qualified_date ";}
	 		if ($next_due) {$sqlstring .= ",next_audit_due_date ";} 
	 		$sqlstring .= ") ";
	 		$sqlstring .= "VALUES ($nextsupplierid, '$company', '$city', '$surveillance_active', '$active', ";
	 		$sqlstring .= "'$external_active', '$bscsuborg_active','$address1','$address2','$state','$province','$country' ";
	 		if ($qual_date) {$sqlstring .= ",to_date('$next_due','MM/DD/YYYY')  ";}
	 		if ($next_due) {$sqlstring .= ", to_date('$next_due','MM/DD/YYYY') ";}
	 		$sqlstring .= ")";
	 		$rc = $dbh->do($sqlstring);
	    	
	    	if ($bscsuborg_active eq 'T') {
	    		my ($suborgid) = $dbh->selectrow_array("SELECT max(id) FROM $SCHEMA.bsc_suborganizations");
	    		$sqlstring = "INSERT INTO $SCHEMA.bsc_suborganizations (id,orgid,suborg,active,labid) 
	    		VALUES ($suborgid + 1, 1, 'LAB','T',$nextsupplierid)";
	    		$rc = $dbh->do($sqlstring);
    		}
    	
	 	$alertString = "$company has been added as a qualified supplier.";
	 	$cgiaction = "query";
	 	 
	    }
	    else {
	    	$alertString = "$company is already in the system.";
	 		print "<input type=hidden name=companyid value='$companyid'>\n";
	 		print "<input type=hidden name=action value='modify_selected'>\n";
         $submit = "document.suppliermaint.submit();\n"; 
	 	 }
	 };
	 if ($@) {
		 $dbh->rollback;
		 &log_nqs_error($dbh,$schema,'T',$userid,"$username Error adding supplier $company, id $nextsupplierid.  $@");
		 $alertString = "An error occurred while adding $company to the system.";
	 }
	 elsif (!(defined($companyid))) {
		 $dbh->commit;
		 &log_nqs_activity($dbh,$schema,'F',$userid,"$username added company $company, id $nextsupplierid");
 	 }
	 print "<script language=\"JavaScript\">
		 <!--
			 alert('$alertString');
			 $submit;
		  -->
	    </script>";
} ##############  endif add supplier  ########################

##################################
if ($cgiaction eq "modify_supplier") {
##################################
    # print the sql which will update this table
    
    #$submitonly = 2;
    my $thiscompanyid = $NQScgi->param('thiscompanyid');
    my %supplierhash = get_supplier_info($dbh, $thiscompanyid);
    
    my $company = 	$NQScgi->param('company');
	 my $address1 = $NQScgi->param('address1'); 
	 my $address2 = $NQScgi->param('address2');
	 my $city =  $NQScgi->param('city');
	 my $state = $NQScgi->param('state');
	 #$zip = $NQScgi->param('zip');
	 my $province = $NQScgi->param('province');
	 #$country = $NQScgi->param('country');
	 #$f_zip = $NQScgi->param('f_zip');
	 #$areacode1 = $NQScgi->param('areacode1');
	 #$phone1 = $NQScgi->param('phone1');
	 #$extension = $NQScgi->param('extension');
	 #$areacode2 = $NQScgi->param('areacode2');
	 #$phone2 = $NQScgi->param('phone2');
	 #$areacode_fax = $NQScgi->param('areacode_fax');
	 #$fax = $NQScgi->param('fax');
	 my $qual_date = $NQScgi->param('qual_date');
	 my $next_due = $NQScgi->param('next_due');
	 #$cat_id = $NQScgi->param('cat_id');
	 my $external_active = $NQScgi->param('external_active') ? 'T' : 'F';
	 my $surveillance_active = $NQScgi->param('surveillance_active') ? 'T' : 'F';
	 my $bscsuborg_active = $NQScgi->param('bscsuborg_active') ? 'T' : 'F';
    	 my $isactive = ($external_active eq 'F' && $surveillance_active eq 'F' && $bscsuborg_active eq 'F' ) ? 'F' : 'T';
	 my $surveillance_checked = $supplierhash{'surveillanceactive'} eq 'T' ? " checked " : "";
	 my $external_checked = $supplierhash{'external_active'} eq 'T' ? " checked " : "";
	 my $bscsuborg_checked = $supplierhash{'bscsuborg_active'} eq 'T' ? " checked " : "";
	 my $country = ($state ne "") ? "USA" : "CAN";
    my $sqlstring = "SELECT id FROM $SCHEMA.qualified_supplier WHERE UPPER(company_name) = '" . uc($company) . "'";
    eval {
	 	my $rc = $dbh->prepare($sqlstring);
	 	$rc->execute;
	 	my $companyid = $rc->fetchrow_array;
    	$sqlstring = "UPDATE $SCHEMA.$updatetable 
                    SET company_name ='$company', city ='$city',
                    surveillance_active = '$surveillance_active', 
                    external_active = '$external_active',
                    bscsuborg_active = '$bscsuborg_active',
                    address1 = '$address1', address2 = '$address2',
                    state = '$state',province = '$province',country = '$country',active = '$isactive' ";
    
    	if ($qual_date) {$sqlstring .= ",qualified_date = to_date('$qual_date','MM/DD/YYYY') ";} 
    	if ($next_due) {$sqlstring .= ",next_audit_due_date = to_date('$next_due','MM/DD/YYYY') ";} 
    	$sqlstring .= "WHERE id=$thiscompanyid";
    	$dbh->{AutoCommit} = 0;
	 	$dbh->{RaiseError} = 1;
    	$rc = $dbh->do($sqlstring);
    	
    	my ($suborgtest) = $dbh->selectrow_array("SELECT id FROM $SCHEMA.bsc_suborganizations where labid = $thiscompanyid"); 		
    	if ($suborgtest)  {
    		$sqlstring = "UPDATE $SCHEMA.bsc_suborganizations 
                SET active = '$bscsuborg_active' where labid = $thiscompanyid";	
                $rc = $dbh->do($sqlstring);
    	}
    	elsif ($bscsuborg_active eq 'T') {
    		my ($suborgid) = $dbh->selectrow_array("SELECT max(id) FROM $SCHEMA.bsc_suborganizations");
    		$sqlstring = "INSERT INTO $SCHEMA.bsc_suborganizations (id,orgid,suborg,active,labid) 
    		VALUES ($suborgid + 1, 1, 'LAB','T',$thiscompanyid)";
    		$rc = $dbh->do($sqlstring);
    	}
    };
    if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error updating company $company, id $thiscompanyid.  $@");
		$alertString = "An error occurred while modifying $company in the system.";
	 }
	 else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username updated company $company, id $thiscompanyid");
		$alertString = "$company has been successfully modified.";
 	 }
  	 print "<script language=javascript type=text/javascript><!-- \n";
 	 print "  alert('$alertString')";
	 print " \n//--></script> \n";
    $cgiaction="query";
}  ###############  endif modify supplier  ####################

######################################
if ($cgiaction eq "modify_selected") {
######################################
	 $submitonly = 1;
    my $thiscompanyid = (defined($NQScgi->param('supplierselect'))) ? $NQScgi->param('supplierselect') : defined($NQScgi->param('companyid')) ? $NQScgi->param('companyid') : $NQScgi->param('availsupplierselect');
    #print STDERR "\ncompanyid -- $thiscompanyid \n";
    my %supplierhash = get_supplier_info($dbh, $thiscompanyid);
    
    # print the sql which will update this table
    my $company = $supplierhash{'company'};
    my $address1 = defined($supplierhash{'address1'}) ? $supplierhash{'address1'} : ""; 
    my $address2 = defined($supplierhash{'address2'}) ? $supplierhash{'address2'} : "";
    my $city = defined($supplierhash{'city'}) ? $supplierhash{'city'} : "";
    my $state = defined($supplierhash{'state'}) ? $supplierhash{'state'} : "";
    #$zip = $supplierhash{'zip'};
    my $province = defined($supplierhash{'province'}) ? $supplierhash{'province'} : '';
    my $country = $supplierhash{'country'};
    #$f_zip = $supplierhash{'f_zip'};
    #$areacode1 = $supplierhash{'areacode1'};
    #$phone1 = $supplierhash{'phone1'};
    #$extension = $supplierhash{'extension'};
    #$areacode2 = $supplierhash{'areacode2'};
    #$phone2 = $supplierhash{'phone2'};
    #$areacode_fax = $supplierhash{'areacode_fax'};
    #$fax = $supplierhash{'fax'};
    my $qual_date = defined($supplierhash{'qual_date'}) ? $supplierhash{'qual_date'} : "";
    my $next_due = defined($supplierhash{'next_due'}) ? $supplierhash{'next_due'} : "";
    #$cat_id = $supplierhash{'cat_id'};
    my $external_active = $supplierhash{'external_active'};
    my $surveillance_active = $supplierhash{'surveillanceactive'};
    my $bscsuborg_active = $supplierhash{'bscsuborg_active'}; 
    my $surveillance_checked = $supplierhash{'surveillanceactive'} eq 'T' ? " checked " : "";
    my $external_checked = $supplierhash{'external_active'} eq 'T' ? " checked " : "";
    my $bscsuborg_checked = $supplierhash{'bscsuborg_active'} eq 'T' ? " checked " : "";
	 
	 my ($survDisabled,$externalDisabled,$bscsuborgDisabled);
    if ($userprivhash{'Developer'} == 0 && $userprivhash{'OQA Surveillance Administration'} == 0 && $userprivhash{'SNL Surveillance Administration'} == 0 && $userprivhash{'BSC Surveillance Administration'} == 0) {
	 	$survDisabled = " disabled=true ";
	 }
	 else {
	 	$survDisabled = "";
	 }
	 if ($userprivhash{'Developer'} == 0 && $userprivhash{'OQA Supplier Administration'} == 0 && $userprivhash{'SNL Supplier Administration'} == 0 && $userprivhash{'BSC Supplier Administration'} == 0) {
	 	$externalDisabled = " disabled=true ";
	 }
	 else {
	 	$externalDisabled = "";
    }
    if ($userprivhash{'Developer'} == 0 && $userprivhash{'OQA Supplier Administration'} == 0 && $userprivhash{'SNL Supplier Administration'} == 0 && $userprivhash{'BSC Supplier Administration'} == 0
    	&& $userprivhash{'OQA Surveillance Administration'} == 0 && $userprivhash{'SNL Surveillance Administration'} == 0 && $userprivhash{'BSC Surveillance Administration'} == 0
    	&& $userprivhash{'OQA Internal Administration'} == 0 && $userprivhash{'SNL Internal Administration'} == 0 && $userprivhash{'BSC Internal Administration'} == 0)
    {
    	 	$bscsuborgDisabled = " disabled=true ";
    	 }
    	 else {
    	 	$bscsuborgDisabled = "";
    }
    my $sqlstring = "SELECT company_name FROM $SCHEMA.qualified_supplier WHERE id != $thiscompanyid";
    my $rc = $dbh->prepare($sqlstring);
    $rc->execute;
    print "<script language=\"JavaScript\" type=\"text/javascript\">";
    print "<!--\n";
    print "var suppliers = new Array();\n";
    my $i = 0;
	 while (my $name = $rc->fetchrow_array) {
	 	print "suppliers[$i] = '$name';\n";
	 	$i++;
	 }
    print "//-->\n";
    print "</script>\n";
    $rc->finish;    
    
    
    print <<modifyform;
    <input name=cgiaction type=hidden value="modify_supplier">
    <input type=hidden name=schema value=$SCHEMA><br>
    <table summary="modify supplier table" width="45%" border=0 align=center>
    <tr><td><b><li>Supplier ID:</b></td>
    <td><b>$thiscompanyid</b>
    <input name=thiscompanyid type=hidden value=$thiscompanyid>
    <input name=thiscompanyname type=hidden value=$company></td></tr>
    
    <tr><td width="40%"><b><li>Company Name:</b></td>
	 <td width=60%><input name=company type=text maxlength=80 size=35 value="$company"></td></tr>
	 <tr><td width="40%"><b><li>Address 1:</b></td>
	 <td width=60%><input name=address1 type=text maxlength=80 size=35 value="$address1"></td></tr>
	 <tr><td width="40%"><b><li>Address 2:</b></td>
	 <td width=60%><input name=address2 type=text maxlength=80 size=35 value="$address2"></td></tr>
	 <tr><td><b><li>City:</b></td>
	 <td nowrap><input name=city type=text maxlength=50 size=20 value="$city"></td><tr>
	 <tr><td nowrap><b><li>State:&nbsp;&nbsp;</b>
modifyform
	 &print_states("$state", "suppliermaint");

    #<tr><td width="40%"><b><li>Zip:</b></td>
	 #<td width=60%><input name=zip type=text maxlength=80 size=35 value="$zip"></td></tr>
	 #<tr><td width="40%"><b><li>Foreign Zip:</b></td>
	 #<td width=60%><input name=f_zip type=text maxlength=80 size=35 value="$f_zip"></td></tr>
	 #<tr><td width="40%"><b><li>Area Code 1:</b></td>
	 #<td width=60%><input name=areacode1 type=text maxlength=80 size=35 value="$areacode1"></td></tr>
	 #<tr><td width="40%"><b><li>Phone 1:</b></td>
	 #<td width=60%><input name=phone1 type=text maxlength=80 size=35 value="$phone1"></td></tr>
	 #<tr><td width="40%"><b><li>Extension:</b></td>
	 #<td width=60%><input name=extension type=text maxlength=80 size=35 value="$extension"></td></tr>
	 #<tr><td width="40%"><b><li>Area Code 2:</b></td>
	 #<td width=60%><input name=areacode2 type=text maxlength=80 size=35 value="$areacode2"></td></tr>
	 #<tr><td width="40%"><b><li>Phone 2:</b></td>
	 #<td width=60%><input name=phone2 type=text maxlength=80 size=35 value="$phone2"></td></tr>
	 #<tr><td width="40%"><b><li>Fax Area Code :</b></td>
	 #<td width=60%><input name=areacode_fax type=text maxlength=80 size=35 value="$areacode_fax"></td></tr>
	 #<tr><td width="40%"><b><li>Fax:</b></td>
	 #<td width=60%><input name=fax type=text maxlength=80 size=35 value="$fax"></td></tr>
	 #<tr><td width="40%"><b><li>Product Category:</b></td>
	 #<td width=60%><input name=cat_id type=text maxlength=80 size=35 value="$cat_id"></td></tr>
	 
	 print "&nbsp;&nbsp;&nbsp;</td><td nowrap><b>Province:&nbsp;&nbsp;</b>";
	 &print_provinces("$province", "suppliermaint");
    print <<modifyform2;
    </td>
    <tr><td><b><li>Qualified Date:</b>
    <td><input name=qual_date type=text maxlength=10 size=12 value="$qual_date" onBlur=validateDate2(value)></td></tr>
    <tr><td><b><li>Next Audit Due Date:</b></td>
    <td><input name=next_due type=text maxlength=10 size=12 value="$next_due" onBlur=validateDate2(value)></td></tr>
    <tr><td nowrap><b><li>Active for External Audits:</b>
    <input name=external_active type=checkbox value='T' $external_checked $externalDisabled></td>
    <td><b>Active for Surveillances:</b>
    <input name=surveillance_active type=checkbox value='T' $surveillance_checked $survDisabled></td></tr>
    <tr><td><b><li>BSC Suborganization:</b>
    <input name=bscsuborg_active type=checkbox value='T' $bscsuborg_checked $bscsuborgDisabled></td>
    <td>&nbsp</td></tr>
    
    </tr>
    
    </table>
modifyform2
    #print "<br>\n";
    print "<input name=action type=hidden value=modify_supplier>\n";
} ############## endif modify selected  #######################

###################################
if ($cgiaction eq "add_selected") {
###################################
    $submitonly = 1;
    my %supplierhash = get_lookup_values($dbh, 'qualified_supplier', 'company_name', 'id');
    my $extDisabled = ($userprivhash{'BSC Supplier Administration'} == 1 || $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'SNL Supplier Administration'} == 1 || $userprivhash{'Developer'} == 1) ? "" : "disabled=true";
    my $survDisabled = ($userprivhash{'BSC Surveillance Administration'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1 || $userprivhash{'Developer'} == 1) ? "" : "disabled=true";
    my $bscsuborgDisabled = ($userprivhash{'BSC Surveillance Administration'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1 || $userprivhash{'Developer'} == 1 ||
    $userprivhash{'BSC Internal Administration'} == 1 || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'SNL Internal Administration'} == 1 ||
    $userprivhash{'BSC Supplier Administration'} == 1 || $userprivhash{'SNL Supplier Administration'} == 1 || $userprivhash{'OQA Supplier Administration'} == 1 ) ? "" : "disabled=true";
    print <<addform;
    <input name=cgiaction type=hidden value="add_supplier"><br><br>
    <table summary="add supplier table" width="45%" border=0 align=center>
    <tr><td><b><li>Company Name:</b></td>
    <td><input name=company type=text maxlength=80 size=35></td></tr>
    <tr><td><b><li>Address 1:</b></td>
    <td><input name=address1 type=text maxlength=80 size=35></td></tr>
    <tr><td><b><li>Address 2:</b></td>
    <td><input name=address2 type=text maxlength=80 size=35></td></tr>
    <tr><td><b><li>City:</b></td>
    <td><input name=city type=text maxlength=50 size=20></td></tr>
    <tr><td nowrap><b><li>State:&nbsp;&nbsp;</b>
addform
	 &print_states('', "suppliermaint");
	 
	 #<td><input name=state type=text maxlength=80 size=35 value="$state"></td></tr> 
    #<tr><td width="40%"><b><li>Zip:</b></td>
    #<td width=60%><input name=zip type=text maxlength=80 size=35 value="$zip"></td></tr>
    #<tr><td width="40%"><b><li>Foreign Zip:</b></td>
    #<td width=60%><input name=f_zip type=text maxlength=80 size=35 value="$f_zip"></td></tr>
    #<tr><td width="40%"><b><li>Area Code 1:</b></td>
    #<td width=60%><input name=areacode1 type=text maxlength=80 size=35 value="$areacode1"></td></tr>
    #<tr><td width="40%"><b><li>Phone 1:</b></td>
    #<td width=60%><input name=phone1 type=text maxlength=80 size=35 value="$phone1"></td></tr>
    #<tr><td width="40%"><b><li>Extension:</b></td>
    #<td width=60%><input name=extension type=text maxlength=80 size=35 value="$extension"></td></tr>
    #<tr><td width="40%"><b><li>Area Code 2:</b></td>
    #<td width=60%><input name=areacode2 type=text maxlength=80 size=35 value="$areacode2"></td></tr>
    #<tr><td width="40%"><b><li>Phone 2:</b></td>
    #<td width=60%><input name=phone2 type=text maxlength=80 size=35 value="$phone2"></td></tr>
    #<tr><td width="40%"><b><li>Fax Area Code :</b></td>
    #<td width=60%><input name=areacode_fax type=text maxlength=80 size=35 value="$areacode_fax"></td></tr>
    #<tr><td width="40%"><b><li>Fax:</b></td>
    #<td width=60%><input name=fax type=text maxlength=80 size=35 value="$fax"></td></tr>
    #<tr><td width="40%"><b><li>Product Category:</b></td>
    #<td width=60%><input name=cat_id type=text maxlength=80 size=35 value="$cat_id"></td></tr>
    

	 print "&nbsp;&nbsp;&nbsp;</td><td nowrap><b>Province:&nbsp;&nbsp;</b>";
	 &print_provinces('', "suppliermaint");
	 
	 print <<addform2;
    </td>
    <tr><td><b><li>Qualified Date:</b>
    <td><input name=qual_date type=text maxlength=10 size=12 onBlur=validateDate2(value)></td></tr>
    <tr><td><b><li>Next Audit Due Date:</b></td>
    <td><input name=next_due type=text maxlength=10 size=12 onBlur=validateDate2(value)></td></tr>
    <tr><td nowrap><b><li>Active for External Audits:</b>
    <input name=external_active type=checkbox value='T' $extDisabled></td>
    <td><b>Active for Surveillances:</b>
    <input name=surveillance_active type=checkbox value='T' $survDisabled></td></tr>
    <tr><td nowrap><b><li>BSC Suborganization:</b>
    <input name=bscsuborg_active type=checkbox value='T' $bscsuborgDisabled></td>
    <td>&nbsp</td></tr>
    </table>
addform2
    print "<input name=action type=hidden value=add_supplier>\n";
}
######################################
if ($cgiaction eq "view_selected") {
######################################
	 $submitonly = 1;
    my $thiscompanyid = (defined($NQScgi->param('supplierselect'))) ? $NQScgi->param('supplierselect') : $NQScgi->param('availsupplierselect');
    my %supplierhash = get_supplier_info($dbh, $thiscompanyid);
    
    # print the sql which will update this table
    my $company = 	$supplierhash{'company'};
    my $address1 = defined($supplierhash{'address1'}) ? $supplierhash{'address1'} : "" ; 
    my $address2 = defined($supplierhash{'address2'}) ? $supplierhash{'address2'} : "";
    my $city =  defined($supplierhash{'city'}) ? $supplierhash{'city'} : "";
    my $state = defined($supplierhash{'state'}) ? $supplierhash{'state'} : "";
    #$zip = $supplierhash{'zip'};
    my $province = defined($supplierhash{'province'}) ? $supplierhash{'province'} : "";
    my $country = $supplierhash{'country'};
    #$f_zip = $supplierhash{'f_zip'};
    #$areacode1 = $supplierhash{'areacode1'};
    #$phone1 = $supplierhash{'phone1'};
    #$extension = $supplierhash{'extension'};
    #$areacode2 = $supplierhash{'areacode2'};
    #$phone2 = $supplierhash{'phone2'};
    #$areacode_fax = $supplierhash{'areacode_fax'};
    #$fax = $supplierhash{'fax'};
    my $qual_date = defined($supplierhash{'qual_date'}) ? $supplierhash{'qual_date'} : "";
    my $next_due = defined($supplierhash{'next_due'}) ? $supplierhash{'next_due'} : "";
    #$cat_id = $supplierhash{'cat_id'};
#    my $external_active = defined($supplierhash{'external_active'} ? ;
#	 my $surveillance_active = $supplierhash{'surveillance_active'};
	 
	          
    my $surveillance_checked = defined($supplierhash{'surveillance_active'}) && $supplierhash{'surveillance_active'} eq 'T' ? " checked " : " ";
    my $external_checked = defined($supplierhash{'external_active'}) && $supplierhash{'external_active'} eq 'T' ? " checked " : " ";
    my $bscsuborg_checked = defined($supplierhash{'bscsuborg_active'}) && $supplierhash{'bscsuborg_active'} eq 'T' ? " checked " : " ";
    
    
    print <<viewform;
    <input type=hidden name=schema value=$SCHEMA>
    <br>
    <table summary="modify supplier table" width="60%" cellpadding="2" border=0 align=center>
    <tr><td><b><li>Supplier ID:</b></td>
    <td><b>$thiscompanyid</b></td></tr>
       
    <tr><td valign="top"><b><li>Company Name:</b></td><td>$company</td></tr>
	 <tr><td valign="top"><b><li>Address 1:</b></td><td>$address1</td></tr>
	 <tr><td><b><li>Address 2:</b></td><td>$address2</td></tr>
	 <tr><td><b><li>City:</b></td><td>$city</td>
viewform
    if ($state ne "") {
	 	print "<tr><td><b><li>State:</b></td><td>$state</td></tr>\n";
	 }
	 else {
	 	print "<tr><td><b><li>Province:</b></td><td>$province</td></tr>\n";
	 }
	 print "<tr><td><b><li>Country:</b></td><td>$country</td></tr>\n";
    #<tr><td width="40%"><b><li>Zip:</b></td><td width=60%>$zip</td></tr>
    #<tr><td width="40%"><b><li>Foreign Zip:</b></td><td width=60%>$f_zip</td></tr>
	 #<tr><td width="40%"><b><li>Area Code 1:</b></td><td width=60%>$areacode1</td></tr>
	 #<tr><td width="40%"><b><li>Phone 1:</b></td><td width=60%>$phone1</td></tr>
	 #<tr><td width="40%"><b><li>Extension:</b></td><td width=60%>$extension</td></tr>
	 #<tr><td width="40%"><b><li>Area Code 2:</b></td><td width=60%>$areacode2</td></tr>
	 #<tr><td width="40%"><b><li>Phone 2:</b></td><td width=60%>$phone2</td></tr>
	 #<tr><td width="40%"><b><li>Fax Area Code :</b></td><td width=60%>$areacode_fax</td></tr>
	 #<tr><td width="40%"><b><li>Fax:</b></td><td width=60%>$fax</td></tr>
	 #<tr><td width="40%"><b><li>Product Category:</b></td><td width=60%>$cat_id</td></tr>
	 print <<viewform2;
	 <tr><td><b><li>Qualified Date:</b></td><td>$qual_date</td></tr>
	 <tr><td><b><li>Next Audit Due Date:</b></td><td>$next_due</td></tr>
	 <tr><td nowrap><b><li>Active for External Audits:</b>&nbsp;&nbsp;<input name=external_active type=checkbox value='T' disabled=true></td>
	 <td>&nbsp;&nbsp;<b>Active for Surveillances:</b>&nbsp;&nbsp;<input name=surveillance_active type=checkbox value='T' disabled=true></td></tr>
	 <tr><td nowrap><b><li>Active for BSC Suborganizations:</b>&nbsp;&nbsp;<input name=bscsuborg_active type=checkbox value='T' disabled=true></td>
	 <td>&nbsp;</td></tr>
    </table>
viewform2
    print "<br>\n";
} ############## endif view selected  #######################

############################
if ($cgiaction eq "query") {
############################
   $submitonly = 0;
   my %supplieractive = get_lookup_values($dbh, 'qualified_supplier', 'company_name', 'id', "active = 'T'");
   my %supplierinactive = get_lookup_values($dbh, 'qualified_supplier', 'company_name', 'id', "active = 'F'");
	my $suppliernamestring;
	my $action;
   if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'SNL Supplier Administration'} == 1 || $userprivhash{'BSC Supplier Administration'} == 1
      || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1 || $userprivhash{'BSC Surveillance Administration'} == 1) {
      $action = "modify_selected";
   }
   else {
   	$action = "view_selected";
   }
   
	print<<table;
<br>
<table cellpadding=5 align=center>
<tr>
<td align=center><b>Active suppliers</b></td>
</tr>
<tr>
<td align=center><select name=availsupplierselect size=5 ondblclick="ViewSelected('$action');" onClick="document.suppliermaint.supplierselect.selectedIndex = -1;">
table

   foreach my $key (sort { lc($a) cmp lc($b) } keys %supplieractive) {
		$suppliernamestring = $key;
		$suppliernamestring =~ s/;$%supplieractive{$key}//g;
		print "<option value=\"$supplieractive{$key}\">$suppliernamestring\n";
   }
   print "</select></td>\n<tr>\n<td align=center><b>Inactive suppliers</b></td></tr>\n";
   print "<tr>\n<td align=center><select name=supplierselect size=5 ondblclick=\"ViewSelected('$action');\" onClick=\"document.suppliermaint.availsupplierselect.selectedIndex = -1;\">\n";
   foreach my $key (sort { lc($a) cmp lc($b) } keys %supplierinactive) {
		$suppliernamestring = $key;
		$suppliernamestring =~ s/;$supplierinactive{$key}//g;
		print "<option value=\"$supplierinactive{$key}\">$suppliernamestring\n";
   }
   
print <<block;
</select>	
</td>
</tr>
</table>
<input name=action type=hidden value=''>
block
}
#disconnect from the database
&NQS_disconnect($dbh);


# print html footers.
if ($submitonly == 0) {
		print "<br>\n";
	if ($userprivhash{'Developer'} == 1 || $userprivhash{'BSC Surveillance Administration'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1 
	   || $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'SNL Supplier Administration'} == 1 || $userprivhash{'BSC Supplier Administration'} == 1) {
    	print "<input name=add type=submit value=\"Add New Supplier\" title=\"Add New Qualified Supplier\" onclick=\"document.suppliermaint.action.value='add_selected'\">&nbsp;";
    	print "<input name=modify type=submit value=\"Modify Selected Supplier\" title=\"Modify the Selected Supplier's Record\" onclick=\"dosubmit=true; (document.suppliermaint.supplierselect.selectedIndex == -1 && document.suppliermaint.availsupplierselect.selectedIndex == -1) ? (alert(\'No Qualified Supplier Selected\') || (dosubmit = false)) : document.suppliermaint.action.value='modify_selected'; return(dosubmit)\">\n";
	}
	else {
		print "<input name=view type=submit value=\"View Selected Supplier\" title=\"View the Selected Qualified Supplier's Record\" onclick=\"dosubmit=true; (document.suppliermaint.supplierselect.selectedIndex == -1 && document.suppliermaint.availsupplierselect.selectedIndex == -1) ? (alert(\'No Qualified Supplier Selected\') || (dosubmit = false)) : document.suppliermaint.action.value='view_selected'; return(dosubmit)\">\n";
	}
#  print "<input name=privilege type=submit value=\"Assign Privileges/Roles\" title=\"Assign privileges or Roles to the selected user\" onclick=\"dosubmit=true; (document.usermaint.selecteduser.selectedIndex == -1) ? (alert(\'No Organization Selected\') || (dosubmit = false)) : document.uorgmaint.action.value='assign_privileges'; return(dosubmit)\">\n";
}
else {
	if ($userprivhash{'Developer'} == 1 || $userprivhash{'BSC Surveillance Administration'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1 
	|| $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'SNL Supplier Administration'} == 1 || $userprivhash{'BSC Supplier Administration'} == 1) {
	  if ($cgiaction eq "add_selected") {
    	  print "<br><input name=submit type=submit value=\"Submit Changes\" onClick=\"return validate(document.suppliermaint);\">\n";
     }
     else {
     	  print "<br><input name=submit type=submit value=\"Submit Changes\" onClick=\"return validate(document.suppliermaint, suppliers);\">\n";
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
