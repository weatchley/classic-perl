#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/www/gov.doe.ocrwm.ydappdev/rcs/qa/perl/RCS/audit.pl,v $
#
# $Revision: 1.26 $
#
# $Date: 2004/03/10 21:50:18 $
#
# $Author: starkeyj $
#
# $Locker: patelr $
#
# $Log: audit.pl,v $
# Revision 1.26  2004/03/10 21:50:18  starkeyj
# added report links to the audit summary screen and the audit detail page, added maintenance screen
# to edit the report links
#
# Revision 1.25  2004/02/19 20:48:58  starkeyj
# modified active_audit, writeFormTop, approval, view and browse to accomodate EM/RW audits
#
# Revision 1.24  2003/12/09 18:28:29  starkeyj
# modified subroutine 'approve' so approved external audits are a variable to accomodate a second approver
# and commented out the MailInternalSchedule and MailExternalSchedule calls (SCR 58)
#
# Revision 1.23  2003/10/08 22:17:07  starkeyj
# modified write ApproverTable to display OQA approver
#
# Revision 1.22  2003/10/01 15:59:29  starkeyj
# modified the cgiaction=approve, writeApproverTable, and approveAuditForm
# to combine the OQA and BSC internal audit schedule and have two apprvers for
# the external audits - SCR 54
#
# Revision 1.21  2003/09/22 20:34:32  starkeyj
# modified the following subroutines:
# writeFormTop - added OCRWM to issuedBy selection
# writeApproverTable - modified display string on the approver button
# approveAuditForm - combined BSC and OQA into one internal schedule table
# cgiaction eq view_audit - added edit privileges for OCRWM approvers
# selectFY - changed default to 2004
#
# Revision 1.20  2002/10/23 23:43:28  starkeyj
# modified approve schedule function so external audits will have issuedby_org_id selected and
# entered into new revision
#
# Revision 1.19  2002/10/01 23:03:30  starkeyj
# modified active audit screen to increase size of product field - defect
#
# Revision 1.18  2002/09/24 20:09:03  starkeyj
# bug fix - modified writeApproverTable fcn to pass the audit type to get_approver
#
# Revision 1.17  2002/09/10 23:50:39  starkeyj
# modified title to display 'Audit Schedule' - bug fix
#
# Revision 1.16  2002/09/10 00:54:49  starkeyj
# modified all functions so OQA and BSC have essentially separate systems - SCR 44
#
# Revision 1.15  2002/07/01 23:44:29  starkeyj
# modified browse audits procedure to not display external audits when no records exist - for SCR 43
#
# Revision 1.14  2002/04/02 17:32:43  starkeyj
# bug fix - modified to validate forecast date field
#
# Revision 1.13  2002/03/29 21:05:24  starkeyj
# bug fix - modified active audit screen so only internal admin can edit internal audits and external
# admin can edit external audits
#
# Revision 1.12  2002/03/29 20:34:22  starkeyj
# modified for SCR 34 - changed function so new audit can enter a begin date and it will take the record
# without a forecast date
#
# Revision 1.11  2002/03/28 18:39:07  starkeyj
# modified for SCR 11 - allowing the customer to add a new supplier from the audit screen
#
# Revision 1.10  2002/02/06 00:36:45  johnsonc
# Bug fix for delete function table name typo. Added additonal parameter to MailInternalSchedule and MailExternalSchedule function calls
#
# Revision 1.9  2001/11/27 17:22:30  starkeyj
# modified insert function to check for 'TBD' as team lead, added 0 to location and organization list in view audit fcn
#
# Revision 1.8  2001/11/27 15:30:04  starkeyj
# aesthetic changes - centering, font sizes, etc.
#
# Revision 1.7  2001/11/06 15:19:24  starkeyj
# cosmetic change - space added to top of 'view audit'
#
# Revision 1.6  2001/11/06 15:07:55  starkeyj
# changed update audit functions so qualified supplier variable is id and not text
#
# Revision 1.5  2001/11/05 13:42:47  starkeyj
# cosmetic changes - added spaces to some of the forms
#
# Revision 1.4  2001/11/02 22:07:53  starkeyj
# cosmetic changes - added spacing to top of audit displays, etc.
#
# Revision 1.3  2001/11/02 17:19:13  starkeyj
# added activity and error logging and form validation
#
# Revision 1.1  2001/10/19 23:25:56  starkeyj
# Initial revision
#
#
# Revision: $
#

use OQA_specific qw(:Functions);
use NQS_Header qw(:Constants);
use OQA_Utilities_Lib qw(:Functions);
use OQA_Widgets qw(:Functions);
use OQA_Reports_Lib qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);
use strict;
use CGI;
use Time::localtime;
use LWP::Simple;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $NQScgi = new CGI;
my $username = defined($NQScgi->param("username")) ? $NQScgi->param("username") : "GUEST";
my $userid = defined($NQScgi->param("userid")) ? $NQScgi->param("userid") : "None";
my $schema = defined($NQScgi->param("schema")) ? $NQScgi->param("schema") : "None";
my $Server = defined($NQScgi->param("server")) ? $NQScgi->param("server") : $NQSServer;
my $pagetitle = $NQScgi->param('pagetitle');
my $cgiaction = $NQScgi->param('cgiaction');
my $cgiaction2 = defined($NQScgi->param('cgiaction2')) ? $NQScgi->param('cgiaction2') : "none";
my $sched = defined($NQScgi->param('sched')) ? $NQScgi->param('sched') : 0 ;
my $fy = defined($NQScgi->param('fy')) ? $NQScgi->param('fy') : 50; 
my $table = defined($NQScgi->param('table')) ? $NQScgi->param('table') : "none";
my $id_type = defined($NQScgi->param('id_type')) ? $NQScgi->param('id_type') : '' ;
my $issuedTo = $NQScgi->param('issuedTo');
my $issuedBy = $NQScgi->param('issuedBy');
my $tag = defined($NQScgi->param('tag')) ? $NQScgi->param('tag') : "active";
my $seq = defined($NQScgi->param("seq")) ? $NQScgi->param("seq") : 0;
my $type = $NQScgi->param('type');
my @organizations;

my $dbh = &NQS_connect();
$dbh->{LongReadLen} = 1000001;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
my %userprivhash = &get_user_privs($dbh,$userid);

print <<END_of_Multiline_Text;
Content-type: text/html

<HTML>
<HEAD>
<script src=$NQSJavaScriptPath/utilities.js></script>
<Title>Audit Schedule</Title>
<!-- include external javascript code -->
<script src="$NQSJavaScriptPath/utilities.js"></script>
END_of_Multiline_Text
if ($cgiaction ne "nologin") {
	print <<OUT;
	<script type="text/javascript">
	<!--
		var dosubmit = true;
	   if (parent == self) {    // not in frames
			location = '$NQSCGIDir/login.pl'
	   }
	//-->
   </script>
OUT
}

print <<END_of_Multiline_Text;
<script language="JavaScript" type="text/javascript">
<!--
	doSetTextImageLabel('Audit');
//-->
</script>

<script language="JavaScript1.1">
<!--
function isBlank(s) {
	for (var i=0; i<s.length; i++) {
  		var c = s.charAt(i);
  		if ((c != ' ') && (c != '\\n') && (c != '\\t') ) {return false;}
	}
	return true;
}
  
function validate(f) {
	var msg = "";
	var empty_fields = "";
	var disapproved = false;

	for (var i=0; i<f.length; i++) {
   	var e = f.elements[i];
  		if (e.type == "radio") {
			if ((!f.approval[0].checked) && (!f.approval[1].checked)) {	
				empty_fields += "\\n     Approved/Disapproved";
				i++;
			}
			else if (f.approval[1].checked) {disapproved = true;}
  		}
	   else if ((e.type == "text") || (e.type == "textarea") || (e.type == "select-one")) {
			if ((e.value == null) || (e.value == "") || (isBlank(e.value))) {
				if ((e.name != "Rationale") || ( e.name == "Rationale" && (disapproved))) {
					empty_fields += "\\n     " + e.name;
					continue;
				}
         }
	 	}
	}
            
	if (!empty_fields) {return true;}
   else {
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
function submitForm (script, command, id) {
	document.$form.cgiaction.value = command;
	document.$form.action = '$path' + script + '.pl';
	document.$form.target = 'workspace';
	document.$form.submit();
}
function submitReportLink (script, command) {
	document.$form.cgiaction.value = command;
	document.$form.action = '$path' + script + '.pl';
	document.$form.target = 'control';
	document.$form.submit();
}
function reportWindow (reportid) {
	var reportlink = "http://ymln4.ymp.gov/Databases/bso/CorConSys.nsf/Correspondence%20Documents%2FBy%20Log%20Number/" + reportid + "?OpenDocument&ExpandSection=1#_Section1";
   	var myDate = new Date();
	var winName = myDate.getTime();
	document.$form.target = winName;
	var newwin = window.open("",winName);
	newwin.creator = self;
	document.$form.action = reportlink;
	$form.submit();
}
function availableIDs () {
	document.$form.action = '$path' + 'audit.pl';
	document.$form.cgiaction.value = 'available_IDs';
	document.$form.target = 'control';
	document.$form.submit();
}
function cancel (fy,table,num) {     
	document.$form.fy.value = fy;
	document.$form.table.value = table;
	document.$form.sid.value = num;
	document.$form.cgiaction.value = 'cancel_audit';
	document.$form.target = 'control';
	document.$form.action = '$path' + 'audit.pl';
	document.$form.submit();
}
function deleteAudit (fy,table,num) {     
	document.$form.fy.value = fy;
	document.$form.table.value = table;
	document.$form.sid.value = num;
	document.$form.cgiaction.value = 'delete_audit';
	document.$form.target = 'control';
	document.$form.action = '$path' + 'audit.pl';
	document.$form.submit();
}
function approve (form,fy,table,org) { 
	document.$form.fiscalyear.value = fy;
	document.$form.table.value = table;
	document.$form.org.value = org;
	document.$form.cgiaction.value = 'approve';
	document.$form.target = 'control';
	document.$form.action = '$path' + 'audit.pl';
	document.$form.submit();
}
function submitActive (table,fy,type,num) {   
	document.$form.fy.value = fy;
	document.$form.sched.value = num;
	document.$form.id_type.value = type;
	document.$form.table.value = table;
	submitForm('audit', 'active_audit', 0);
}
function addReport (table,fy,type,num,command,reportid) {   
	document.$form.fy.value = fy;
	document.$form.sched.value = num;
	document.$form.id_type.value = type;
	document.$form.table.value = table;
	document.$form.reportlink.value = reportid;
	submitForm('audit', command, 0);
}
function submitView (table,fy,type,num) {   
	document.$form.fy.value = fy;
	document.$form.sched.value = num;
	document.$form.id_type.value = type;
	document.$form.table.value = table;
	submitForm('audit', 'view_audit', 0);
}
function browse(fy,type) {
	document.$form.fy.value = fy;
	document.$form.table.value = type;
	document.$form.audit_type.value = type;
	document.$form.cgiaction.value = 'browse_audits';
	document.$form.action = '$path' + 'audit.pl';
	document.$form.target = 'workspace';
	document.$form.submit();
}
function checkDate(val,e) {
   var valid = 1;
   if (isBlank(val)) {val = 'mm/dd/yyyy';}
	if (val != 'mm/dd/yyyy') {valid =  validateDate2(val);}
	if (!valid) {e.focus();}
}
function checkForecastDate(val,e) {
   var valid = 1;
   var datestr;
   
   if (isBlank(val)) {val = 'mm/yyyy';}
   if (val != 'mm/yyyy') {
   	datestr = val.split("/");
   	if (datestr[0] == val) {
   		alert(datestr[0] + ' is not valid');
   		valid = 0;
   	}
   	else if (!(datestr[0] > 0 && datestr[0] < 13)) {
   		alert(datestr[0] + ' is not a valid month');
   		valid = 0;
   	}
   	else if (!(isnumeric(datestr[1]))) {
		   alert(datestr[1] + ' is not a valid year');
		   valid = 0;
   	}
   }
   if (!valid) {e.focus();}
}
function isnumeric(s) {
	if (s.length != 4) return false;
 	for(var i = 0; i < s.length; i++) {
	  var c = s.charAt(i);
	  if ((c < '0') || (c > '9')) return false;
	}
 	return true;
}
function submitNew(f,table) {  
   var msg = "";
   var msg2 = "The following fields are required: \\n";
   var type = 0;
   var i = f.auditType.length;
	if (f.issuedTo.value == 0 ) {msg += "- Issued To \\n";}
	if (f.issuedBy.length) {
		if (!f.issuedBy[0].checked && !f.issuedBy[1].checked) {msg += "- Issued By \\n";}
	}
	for (var i=0;i<f.auditType.length;i++) {
		if (f.auditType[i].checked) {type = 1;}	
	}
	
	if (!type) {msg += "- Audit Type \\n";}
	if ( (f.forecast.value == 'mm/yyyy' || isBlank(f.forecast.value))
	   && (f.Begindate.value == 'mm/dd/yyyy' || isBlank(f.Begindate.value)) )
	{msg += "- Forecast Date and/or Begin Date \\n";}
	
	if (table == "internal") {
		if (f.org1.value == 0 && f.loc1.value == 0 ) {msg += "- Organizations / Locations \\n";}
		if (f.issuedBy.length) {
			if (!f.issuedBy[0].checked && !f.issuedBy[1].checked ) {msg += "- Issued By Organization \\n";}
		}
	}
	if (table == "external") {
		if (f.QualifiedSupplier.value == 0 ) {msg += "- Supplier \\n";}
		if (f.loc1.value == 0 ) {msg += "- Locations \\n";}
	}
	if (isBlank(f.Scope.value) ) {msg += "- Scope \\n";}

	if (msg == "") {
	 	document.$form.cgiaction.value = 'insert_new_audit';
		document.$form.action = '$path' + 'audit.pl';
		document.$form.target = 'control';
	 	document.$form.submit();
   }
   else {
   	msg2 += msg;
   	alert (msg2);
   }
}
function submitUpdate (f,table) {
	var msg = "";
	var msg2 = "The following fields are required: \\n";
	var type = 0;
	var i = f.auditType.length;
	if (f.issuedTo.value == 0 ) {msg += "- Issued To \\n";}
	for (var i=0;i<f.auditType.length;i++) {
		if (f.auditType[i].checked) {type = 1;}	
	}
	if (!type) {msg += "- Audit Type \\n";}
	if ( (f.forecast.value == 'mm/yyyy' || isBlank(f.forecast.value))
		   && (f.Begindate.value == 'mm/dd/yyyy' || isBlank(f.Begindate.value)) )
	{msg += "- Forecast Date and/or Begin Date \\n";}
	
	if (table == "internal") {
		if (f.org1.value == 0 && f.loc1.value == 0 ) {msg += "- Organizations / Locations \\n";}
	}
	if (table == "external") {
		if (f.QualifiedSupplier.value == 0 ) {msg += "- Supplier \\n";}
		if (f.loc1.value == 0 ) {msg += "- Locations \\n";}
	}
	if (isBlank(f.Scope.value) ) {msg += "- Scope \\n";}

	if (msg == "") {
		document.$form.cgiaction.value = 'update_audit';
		document.$form.action = '$path' + 'audit.pl';
		document.$form.target = 'control';
		document.$form.submit();
	}
	else {
		msg2 += msg;
		alert (msg2);
   }
}
function new_supplier () {   
	newsupplier.style.display = 'block';
	parent.workspace.supplierbutton.style.display = 'none';
	parent.workspace.$form.external_active.checked = true;
	parent.workspace.$form.surveillance_active.checked = true;
}
function addNewSupplier() {
	var msg = "";
	if (document.$form.city.value == null || document.$form.city.value == "" || isBlank(document.$form.city.value)) {
		msg += " - You must enter a city\\n";
	}
	if ((document.$form.state.value == null || document.$form.state.value == "" || isBlank(document.$form.state.value))
	&& (document.$form.province.value == null || document.$form.province.value == "" || isBlank(document.$form.province.value))) {
		msg += " - You must select a state or a province\\n";
	}
	if (document.$form.newproduct.value == null || document.$form.newproduct.value == "" || isBlank(document.$form.newproduct.value)) {
		msg += " - You must enter the product or service\\n";
	}
	if (msg == "" ) {
		document.$form.cgiaction2.value = 'add_supplier';
		document.$form.action = '$path' + 'audit.pl';
		document.$form.target = 'control';
		document.$form.submit();
	}
	else { alert(msg); }
}
function populateSupplier(locid,supplierid) {
	var len = parent.workspace.$form.QualifiedSupplier.length;
	
	parent.workspace.$form.QualifiedSupplier.length = len + 1;
	parent.workspace.$form.QualifiedSupplier.options[len].value = supplierid;
	parent.workspace.$form.QualifiedSupplier.options[len].text = parent.workspace.$form.company.value;
	parent.workspace.$form.QualifiedSupplier.options[len].selected = true;
	parent.workspace.newsupplier.style.display = 'none';
	parent.workspace.supplierbutton.style.display = 'block';
	populate_locations2(locid);
}
function closeSupplierBlock() {
	clear_supplier();
	parent.workspace.newsupplier.style.display = 'none';
	parent.workspace.supplierbutton.style.display = 'block';
	//parent.workspace.$form.issuedTo.focus();
}
function hideBeforeBlock(yr) {
   if (yr > 2002) {
		parent.workspace.before.style.display = 'none';
		parent.workspace.after.style.display = 'block';
	}
	else {
		parent.workspace.before.style.display = 'block';
		parent.workspace.after.style.display = 'none';
	}
}
function populate_location() {
	document.$form.cgiaction2.value = 'populate_location';
	document.$form.action = '$path' + 'audit.pl';
	document.$form.target = 'control';
	document.$form.submit();
}
function populate_locations2(num) {
   var len = parent.workspace.audit.loc1.length;
   var i;
   var addit = 1;
   for (i = 0; i < len; i++) {
   	if (parent.workspace.audit.loc1.options[i].value == num) {
   		parent.workspace.audit.loc1.options[i].selected = true;
   		i = len;
   		addit = 0;
   	}
   }
   if (addit == 1) {
		parent.workspace.$form.loc1.length = len + 1;
		parent.workspace.$form.loc1.options[len - 1].value = num;
		if (!isBlank(parent.workspace.$form.city)) {
			parent.workspace.$form.loc1.options[len - 1].text = parent.workspace.$form.city.value + ', ' + parent.workspace.$form.state.value;
		}
		else {
			parent.workspace.$form.loc1.options[len - 1].text = parent.workspace.$form.city.value + ', ' + parent.workspace.$form.province.value;
		}
	 	parent.workspace.$form.loc1.options[len - 1].selected = true;
   }
   parent.workspace.$form.product.value = parent.workspace.$form.newproduct.value;
   clear_supplier();
}
function clear_supplier() {
	parent.workspace.$form.company.value = '';
	parent.workspace.$form.address1.value = '';
	parent.workspace.$form.address2.value = '';
	parent.workspace.$form.city.value = '';
	parent.workspace.$form.state.value = '';
	parent.workspace.$form.province.value = '';
	parent.workspace.$form.newproduct.value = '';
	parent.workspace.$form.external_active.checked = false;
	parent.workspace.$form.surveillance_active.checked = false;
	//parent.workspace.$form.issuedTo.focus();
}
function checkLength(val,e) {
	var maxlen;
	if (e.name == "Team") {
		maxlen = 199; 
	}
	else if (e.name == "Scope") {
		maxlen = 799;
	}
	else if (e.name == "Notes") {
		maxlen = 499;
	}
	else if (e.name == "addreportlink") {
		maxlen = 150;
	}
	var len = val.length;
	var diff = len - maxlen;
	if (diff > 0) {
		alert ("The text you have entered is " + diff + " characters too long.");
		e.focus();
	}
}
  //-->
</script>

END_of_Multiline_Text

print "</HEAD>\n";
print "<Body background=$NQSImagePath/background.gif text=#000099>\n";
print "<center>\n";
print "<form action=\"$NQSCGIDir/audit.pl\" method=post name=$form>\n";
print "<input type=hidden name=username value=$username>\n";
print "<input type=hidden name=userid value=$userid>\n";
print "<input type=hidden name=schema value=$schema>\n";
print "<input type=hidden name=tag value=$tag>\n";
print "<input type=hidden name=table value=$table>\n";
print "<input type=hidden name=yr value=$fy>\n";
print "<input type=hidden name=cgiaction value=$cgiaction>\n";
print "<input type=hidden name=cgiaction2>\n";
print "<input type=hidden name=reportlink>\n";
###################################################################################################################################
sub doProcedureLink {  # routine to get procedure link
###################################################################################################################################
    my %args = (
        procedureno => '',
        contents => '',
        @_,
    );
    my $output = "";
    #my $url = "http://ymlnweb1.ymp.gov/databases/proxy/opdd.nsf/Procedure/By+Document+Number/?searchview&query=$args{procedureno}";
#print STDERR "\n *** Procedure # $args{procedureno}, Link: $url ****\n\n";
    #my $pageContent = get($url);
    #$pageContent =~ s/\n//g;
    #my $linkStart = index(lc($pageContent), '<a href');
    #if ($linkStart > 0) {
    #    my $link = substr($pageContent, $linkStart, (index($pageContent, '>', $linkStart) - $linkStart));
    #    $link =~ s/\/data/http:\/\/ymlnweb1.ymp.gov\/data/;
    #    $output .= $link . " target=_blank>$args{contents}</a>\n";
    #    
    #} else {
    #    $output .= "<a href=\"javascript:alert('Procedure not found in DB');\">$args{contents}</a>\n";
    #}

    #$output .= "<a href=http://ymlnweb1.ymp.gov/databases/proxy/opdd.nsf/Procedure/By+Document+Number/$args{procedureno}?OpenDocument target=_new>$args{contents}</a>\n";
    #$output .= "<a href=\"javascript:alert('This will link to the Notes procedure');\">$args{contents}</a>\n";
    $output .= "<a href=\"javascript:displayExternalDocument('opdd','$args{procedureno}');\">$args{contents}</a>\n";

    return($output);
}
############################
sub get_org_locs {
############################
	my ($id,$fy,$table) = @_;
	my $sqlstring;
	my $csr;
	my @values;
	my $orglist = "(0,";
	my $loclist = "(0,";
	
	 if ($table eq 'internal') {
	 	$sqlstring = "select id, organization_id, location_id ";
	 	$sqlstring .= "from $schema.internal_audit_org_loc ";
	 	$sqlstring .= "where fiscal_year = $fy and revision = 0 and internal_audit_id = $id order by id ";
	 
	 	$csr = $dbh->prepare($sqlstring);
	 	$csr->execute;
	 	while (@values = $csr->fetchrow_array) {
	   	if ($values[1]) {$orglist .= $values[1] . ",";}
	 		if ($values[2]) {$loclist .= $values[2] . ",";}
	 	}
	 	chop($orglist);
	 	chop($loclist);
	 	$orglist .= ")";
	 	$loclist .= ")";
	 	&getOrganizations($orglist);
	 	&getLocations($loclist);
	 }
	 elsif ($table eq 'external') {
	 	$sqlstring = "select id, location_id ";
		$sqlstring .= "from $schema.external_audit_locations ";
		$sqlstring .= "where fiscal_year = $fy and revision = 0 and external_audit_id = $id order by id ";

		$csr = $dbh->prepare($sqlstring);
		$csr->execute;
		while (@values = $csr->fetchrow_array) {
			if ($values[1]) {$loclist .= $values[1] . ",";}
		}
		chop($loclist);
		$loclist .= ")";
	 	&getLocations($loclist);
	 }
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
	print "<tr><td colspan=4><b>Organizations:&nbsp;<font color=black>\n";
	while (my @values = $csr->fetchrow_array) {
		if (!$first) {print ",&nbsp;&nbsp;";}
		print "$values[0]";
		$first = 0;
	}
	print "</font></b></td></tr>\n";
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
	print "<tr><td colspan=4><b>Locations:&nbsp;<font color=black>\n";
	while (my @values = $csr->fetchrow_array) {
  	   $city = defined($values[0]) ? $values[0] : '';
  	   $state = defined($values[1]) ? $values[1] : '';
  	   $province = defined($values[2]) ? $values[2] : '';
  	   $country = defined($values[3]) ? $values[3] : '';
  	   
  	   if (!$first) {print ";&nbsp;&nbsp;";}
  	   if ($city) {print "$city,&nbsp;";}
		if ($state) {print "$state";}
		if ($province) {print "$province,&nbsp;";}
		if ($country ne 'USA') {print "$country";}
		$first = 0;
	}
	print "</font></b></td></tr>\n";
}
############################
sub selectFY {
############################
	my ($selected_yr) = @_;
	my $def_yr;
	my $current_year = $dbh -> prepare ("select to_char(sysdate,'MM/YYYY') from dual");
	$current_year -> execute;
	my $mmyyyy = $current_year -> fetchrow_array;
	$current_year -> finish;
	my $mm = substr($mmyyyy,0,2);
	if ($mm > 9) {$def_yr = substr($mmyyyy,3) + 1;}
	else { $def_yr = substr($mmyyyy,3); }
	if ($selected_yr == 50) {$selected_yr = substr($def_yr,3);}
	if ($selected_yr == 3 && $table eq 'internal') {$selected_yr = 4;} #kluge

	my $csr = $dbh -> prepare ("select fiscal_year from $schema.fiscal_year order by fiscal_year desc");
	$csr -> execute;
	print "<font size=-1><b>Fiscal Year:&nbsp;&nbsp;</b><br>&nbsp;&nbsp;\n";
	print "<select name=fy size=1 onChange=hideBeforeBlock(value);>\n";
	while (my @values = $csr -> fetchrow_array){
		my ($fy) = @values;
		if (substr($fy,2) == $selected_yr ){print "<option selected value=$fy>$fy\n";}
		else {print "<option value=$fy>$fy\n";}
	}
	$csr -> finish;
	print "</select>\n";
}
############################
sub select_org_locs {
############################
	my ($id,$fy) = @_;
	my @locresults = get_locations2($dbh,'internal',$id,$fy);
	tie my %orghash, "Tie::IxHash";
	tie my %lochash, "Tie::IxHash";
	tie my %selectedhash, "Tie::IxHash";
	my $key = 0;
	my $loc;
	my $orgselect;
	my $locselect;
	my $i=1;
	my $lookup;
	my $value;
	my @values;

	if (!$id) {$id = 0;}
	if (!$fy) {$fy = 50;}
	my $orgstring = "select id, abbr from $schema.organizations  ";
	$orgstring .= "where internal_active = 'T' or id in (select organization_id ";
	$orgstring .= "from internal_audit_org_loc where fiscal_year = $fy ";
	$orgstring .= "and revision = 0 and internal_audit_id = $id) ";
	$orgstring .= "order by abbr";

	my $csr = $dbh->prepare($orgstring);
	$csr->execute;
	while (@values = $csr->fetchrow_array) {
		($lookup, $value) = @values;
		$orghash{$lookup} = $value;
	}
	$csr->finish;

	foreach my $array_ref (@locresults) { 
		$loc = "";
		if (@$array_ref[0]) {$loc .= @$array_ref[0] . ', ';}
		if (@$array_ref[1]) {$loc .= @$array_ref[1] . ', ';}
		if (@$array_ref[2]) {$loc .= @$array_ref[2];}
		if (@$array_ref[3] && @$array_ref[3] ne 'USA' && @$array_ref[3] ne '' ) {$loc .=  @$array_ref[3];}
		$lochash{$loc} = @$array_ref[4] ;
	}
	print "<tr><td align=left width=50%><font size=-1><b>Organizations</b></td><td align=left width=50%><font size=-1><b>Locations</b></td></tr>\n";
	if ($id) {
	 	my $sqlstring = "select id, organization_id, location_id ";
	 	$sqlstring .= "from $schema.internal_audit_org_loc ";
	 	$sqlstring .= "where revision = 0 and internal_audit_id = $id and fiscal_year = $fy ";
	 	$sqlstring .= "order by id ";
	 
	 	my $csr = $dbh->prepare($sqlstring);
	 	$csr->execute;
	 	while (@values = $csr->fetchrow_array) {
	 		$orgselect = "org" . $i ;
	 		$locselect = "loc" . $i ;
    		print "<tr><td width=50%><select name=$orgselect size=1>\n";
    		print "<option value=0>\n";
    		foreach $key (keys %orghash) {
				if (defined($key) && defined($values[1]) && $key == $values[1]){print "<option selected value=\"$key\">$orghash{$key}\n";}
	      	else {print "<option value=\"$key\">$orghash{$key}\n";}
    		}
    		print "</select></td>\n<td width=50%><select name=$locselect size=1>\n";
    		print "<option value=0>\n";
    		foreach $key (keys %lochash) {
				if ($lochash{$key} == $values[2]){print "<option selected value=\"$lochash{$key}\">$key\n";}
				else {print "<option value=\"$lochash{$key}\">$key\n";}	
			}
    		print "</select></td></tr>\n";
    		$i++;
    	}
	}
	for (my $j=$i;$j<8;$j++) {
    	$orgselect = "org" . $j ;
		$locselect = "loc" . $j ;
		print "<tr><td width=50%><select name=$orgselect size=1>\n";
		print "<option value=0>\n";
		foreach $key (keys %orghash) {print "<option value=\"$key\">$orghash{$key}\n";}
		print "</select></td>\n<td width=50%><select name=$locselect size=1>\n";
		print "<option value=0>\n";
		foreach $key (keys %lochash) {print "<option value=\"$lochash{$key}\">$key\n";}
		print "</select></td></tr>\n";
	}
}
############################
sub select_locs {
############################
	my ($id,$fy) = @_;
	my @locresults = get_locations2($dbh,'external',$id,$fy);
	tie my %lochash, "Tie::IxHash";
	tie my %selectedhash, "Tie::IxHash";
	my $key;
	my $loc;
	my $locselect;
	my $i=1;

	foreach my $array_ref (@locresults) { 
		$loc = "";
		if (@$array_ref[0]) {$loc .= @$array_ref[0] . ', ';}
		if (@$array_ref[1]) {$loc .= @$array_ref[1] . ', ';}
		if (@$array_ref[2]) {$loc .= @$array_ref[2];}
		if (@$array_ref[3] && @$array_ref[3] ne 'USA' && @$array_ref[3] ne '' ) {$loc .=  @$array_ref[3];}
		$lochash{$loc} = @$array_ref[4] ;
	}
	print "<tr><td align=left valign=top><font size=-1><b>Locations</b></td></tr>\n";
	if ($id) {
		my $sqlstring = "select id, location_id ";
		$sqlstring .= "from $schema.external_audit_locations ";
		$sqlstring .= "where revision = 0 and fiscal_year = $fy and external_audit_id = $id order by id ";

		my $csr = $dbh->prepare($sqlstring);
		$csr->execute;
		while (my @values = $csr->fetchrow_array) {
			$locselect = "loc" . $i ;
			print "<tr><td><select name=$locselect size=1>\n";
			print "<option value=0>\n";
			foreach $key (keys %lochash) {
				if ($lochash{$key} == $values[1]){print "<option selected value=\"$lochash{$key}\">$key\n";}
				else {print "<option value=\"$lochash{$key}\">$key\n";}
			}
			print "</select></td></tr>\n";
			$i++;
		}
	}
	for (my $j=$i;$j<5;$j++) {
		$locselect = "loc" . $j ;
		print "<tr><td width=50%><select name=$locselect size=1>\n";
		print "<option value=0>\n";
		foreach $key (keys %lochash) {
			print "<option value=\"$lochash{$key}\">$key\n";
		}
		print "</select></td></tr>\n";
   }
}
############################
sub selectLocations {
############################
	my ($id,$fy) = @_;
	my @locresults = get_locations($dbh);
	my $loc;
	tie my %lochash, "Tie::IxHash";
	my %selectedhash;
	my $select_table;

	if ($table eq "internal") {$select_table = "internal_audit_org_loc";}
	elsif ($table eq "external") {$select_table = "external_audit_locations";}
	foreach my $array_ref (@locresults) { 
	 	$loc = "";
	 	if (@$array_ref[0]) {$loc .= @$array_ref[0] . ', ';}
	 	if (@$array_ref[1]) {$loc .= @$array_ref[1] . ', ';}
	 	if (@$array_ref[2]) {$loc .= @$array_ref[2];}
	 	if (@$array_ref[3] ne 'USA' && @$array_ref[3] ne '' ) {$loc .=  @$array_ref[3];}
	 	$lochash{$loc} = @$array_ref[4] ;
	}
	if ($id) {
    	%selectedhash = get_lookup_values($dbh, $select_table . ", " .  $schema . ".locations", "initcap(city) || ', ' || state", "locations.id", $table . "_audit_id = $id and fiscal_year = $fy and revision = 0 and location_id = locations.id");
   }
}
############################
sub writeLocations {
############################
	my ($id,$fy,$table) = @_;
	my %selectedhash;
	my $select_table;

	if ($table eq "internal") {$select_table = "internal_audit_org_loc";}
	elsif ($table eq "external") {$select_table = "external_audit_locations";}
	%selectedhash = get_lookup_values($dbh, $select_table . ", " .  $schema . ".locations", "initcap(city) || ', ' || state", "locations.id", $table . "_audit_id = $id and fiscal_year = $fy and revision = 0 and location_id = locations.id");
	my $i = 1; 
	foreach my $keys ( keys %selectedhash) {
	 	print "$keys";
	 	if ($i < (keys(%selectedhash))) {
	 		print "; ";
	 		$i++;
	 	}
   } 
}
############################
sub selectOrganizations {
############################
	my ($id,$fy,$table) = @_;
	my %orghash;
	my %selectedhash;

	if (!($id)) {%orghash = get_lookup_values($dbh, 'organizations', 'abbr', 'id');}
	else {
    	%orghash = get_lookup_values($dbh, 'organizations', 'abbr', 'id');
    	%selectedhash = get_lookup_values($dbh, "internal_audit_org_loc, " .  $schema . ".organizations", "abbr", "organizations.id", $table . "_audit_id = $id and fiscal_year = $fy and revision = 0 and organization_id = organizations.id");
   }
   print build_dual_select ("organizations","audit",\%orghash,\%selectedhash,"Organizations","Selected","1","10");
}
############################
sub writeOrganizations {
############################
	my ($id,$fy,$table) = @_;
	my %selectedhash;
	my $i = 1;
	%selectedhash = get_lookup_values($dbh, "internal_audit_org_loc, " .  $schema . ".organizations", "abbr", "organizations.id", $table . "_audit_id = $id and fiscal_year = $fy and revision = 0 and organization_id = organizations.id");
	foreach my $keys ( keys %selectedhash) {
 		print "$keys";
 		if ($i < (keys(%selectedhash))) {
			print ", ";
			$i++;
	 	}
   } 
}
############################
sub selectQualifiedSuppliers {
############################
	my ($id,$fy,$product) = @_;
	tie my %orghash, "Tie::IxHash";;
	my $qsl_id = 0;
	my $key = '';

	%orghash = get_lookup_values($dbh, 'qualified_supplier', 'id', 'company_name', " external_active = 'T' or id = $id");
	if ($id) {
    	$qsl_id = lookup_single_value($dbh,$schema,'external_audit','qualified_supplier_id'," $id and fiscal_year = $fy and revision = 0");
   }
	print "<tr><td colspan=3><font size=-1><b>Supplier:</b><br><select name=QualifiedSupplier title=\"QualifiedSupplier\" size=1 onChange=populate_location();>\n"; 	
	print "<option value=0>\n";
	foreach $key (keys %orghash) {
	 	if ($key == $id){print "<option selected value=$key>$orghash{$key}\n";}
    	else {print "<option value=$key>$orghash{$key}\n";}
	}
	print "</select></td>\n";
	if ($id) {print "<td>&nbsp;</td></tr>\n";}
	else {print "<td valign=bottom><span id=\"supplierbutton\" Style=Display:block; ><input type=button onClick=new_supplier(); value=\"Add New Supplier\"></span></td></tr>\n";}
	print "</tr>\n<tr><td colspan=3><font size=-1><b>Product or Service:</b>\n";
	print "<br><input name=product type=text maxlength=220 size=100 value='$product'></td></tr>\n";
}
############################
sub writeSupplier {
############################
	my ($id,$fy,$table) = @_;
	my $company_name = '';

	if ($id != 0) {
    	$company_name = lookup_single_value($dbh,$schema,'qualified_supplier','company_name'," $id ");
	}
	print "$company_name";
}
############################
sub selectTeam {
############################
	my ($leadid,$team,$table) = @_;
	my $priv;
	my @values;
	my $lookup;
	my $value;
	tie my %leadhash,  "Tie::IxHash";
	my $lead = lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname",$leadid);

	if (!$leadid) {$leadid = 0;}
	if ($table eq 'internal') {$priv = "Internal Lead";}
	else {$priv = "Supplier Lead";}
	my $leadstring = "select u.id, firstname || ' ' || lastname from users u, user_privilege up, ";
	$leadstring .= "privilege p where  (p.privilege like '%" . $priv . "' and p.id = up.privilege ";
	$leadstring .= "and u.id = up.userid) or u.id = $leadid order by lastname, firstname ";

	my $csr = $dbh->prepare($leadstring);
	$csr->execute;
	while (@values = $csr->fetchrow_array) {
	 	($lookup, $value) = @values;
		$leadhash{$lookup} = $value;
	}
	$csr->finish;

	print "<tr><td nowrap valign=top>&nbsp;&nbsp;<font size=-1><b>Team Lead:</b></td>\n";
	print "<td><select name=Lead title=\"TeamLeads\" size=1>\n"; 	
	print "<option selected value=0>TBD\n";
	foreach my $keys (keys %leadhash) {
    	if ($keys == $leadid){print "<option selected value=\"$keys\">$leadhash{$keys}\n";}
    	else {print "<option value=\"$keys\">$leadhash{$keys}\n";}
	}
	print "</select></td></tr>\n";
   print "<tr><td valign=top>&nbsp;&nbsp;<font size=-1><b>Team<br>&nbsp;&nbsp;Members:</b></td><td><textarea name=Team rows=4 cols=20  onBlur=checkLength(value,this);>$team</textarea><br>\n</td></tr>\n";
}
############################
sub add_supplier_form  {
############################
	print "<tr><td colspan=2><span id=\"newsupplier\" Style=Display:none; >\n";
	print <<addform;
	<table summary="add supplier table" bgcolor="#EEEEEE" width=600 border=1 align=center  rules=none cellspacing=0 bordercolor=gray>
	<tr><td colspan=2 align=center><font color=black><b>Enter New Supplier Information</b></td></tr>
	<tr><td colspan=2><br></td></tr>
	<tr><td><font color=black size=-1><b><li>Company Name:</b></td>
	<td><input name=company type=text maxlength=80 size=35></td></tr>
	<tr><td><font color=black size=-1><b><li>Address 1:</b></td>
	<td><input name=address1 type=text maxlength=80 size=35></td></tr>
	<tr><td><font color=black size=-1><b><li>Address 2:</b></td>
	<td><input name=address2 type=text maxlength=80 size=35></td></tr>
	<tr><td><font color=black size=-1><b><li>City:</b></td>
	<td><input name=city type=text maxlength=50 size=35></td></tr>
	<tr><td nowrap><font color=black size=-1><b><li>State:</b></td>\n<td>
addform
	&print_states('', "audit");
	print "</td></tr>\n<tr><td nowrap><font color=black size=-1><b><li>Province:</b></td>\n<td>";
	&print_provinces('', "audit");
	print <<addform2;
	</td></tr>
	<tr><td><font color=black size=-1><b><li>Product or Service:</b></td>
	<td><input name=newproduct type=text maxlength=50 size=35></td></tr>
	<tr><td nowrap><font color=black size=-1><b><li>Active for External Audits:</b></td>
	<td><input name=external_active type=checkbox value='T' checked></td></tr>
	<tr><td><font color=black size=-1><b><li>Active for Surveillances:</b></td>
	<td><input name=surveillance_active type=checkbox value='T' checked><br></td></tr>
	<tr><td colspan=2><br></td></tr>
	<tr><td align=center colspan=2><input type=button onClick=addNewSupplier(); value="Submit">
	&nbsp;&nbsp;&nbsp;<input type=button onClick=closeSupplierBlock(); value="Cancel">
	&nbsp;&nbsp;&nbsp;<input type=button onClick=clear_supplier(); value="Clear"><br><br></td></tr>
	</table>
	<input name=cityvalue type=hidden>
	<input name=statevalue type=hidden>
	<input name=provincevalue type=hidden>
addform2
   print "</span></td></tr>\n";
}
############################
sub writeApproverTable {
############################
	my ($type,$org,$table,$orgid,$fullyear,$remove) = @_;
	my ($auditCount,$assignedCount,$approvedCount,$approvedAssignedCount,$type2,$priv,$priv2);
	my $fiscalyear = substr($fullyear,2);
	my $max_rev = &get_max_revision($dbh,$schema,$fiscalyear,$type,$org);
	my $displayRevision;
	if (!($max_rev)) {
		$max_rev = 1;
		$displayRevision = '&nbsp;';
	}
	else {$displayRevision = $max_rev - 1;}	
	my $halfapproved = &checkApproval($dbh,$schema,$fiscalyear,$table);
	my @halfapprovedby = &checkApprover($dbh,$schema,$fiscalyear,substr($table,0,1));
	my ($bscapprover, $bscapproval_date,$oqaapprover, $oqaapproval_date) = @halfapprovedby;
	#print STDERR "\n -- $table -- $halfapproved -- \n";
	if ($table eq 'internal_audit') {
		$type2 = 'Internal';
		$priv = 'OQA Internal Schedule Approver';
		$priv2 = 'BSC Internal Schedule Approver';
		$auditCount = &get_audit_count($dbh,$schema,$table," fiscal_year = $fiscalyear and revision = 0 and issuedby_org_id = $orgid" );
		$assignedCount = &get_audit_count($dbh,$schema,$table," fiscal_year = $fiscalyear and revision = 0 and issuedby_org_id = $orgid and audit_seq != 0");
		$approvedCount = &get_audit_count($dbh,$schema,$table," fiscal_year = $fiscalyear and revision = $max_rev and issuedby_org_id = $orgid" );    
		$approvedAssignedCount = &get_audit_count($dbh,$schema,$table," fiscal_year = $fiscalyear and revision = $max_rev and audit_seq != 0 and issuedby_org_id = $orgid");
	}
	else {
		$type2 = 'External';
		$priv = 'Supplier Schedule Approver';
		$priv2 = '';
		$auditCount = &get_audit_count($dbh,$schema,$table," fiscal_year = $fiscalyear and revision = 0 " );
		$assignedCount = &get_audit_count($dbh,$schema,$table," fiscal_year = $fiscalyear and revision = 0 and audit_seq != 0");
		$approvedCount = &get_audit_count($dbh,$schema,$table," fiscal_year = $fiscalyear and revision = $max_rev " );    
		$approvedAssignedCount = &get_audit_count($dbh,$schema,$table," fiscal_year = $fiscalyear and revision = $max_rev and audit_seq != 0 ");
	}
	my @values = &get_approver($dbh,$schema,$fiscalyear,$max_rev,$org,substr($type2,0,1));
	my ($approver, $approval_date) = @values;
	if (!($approval_date)) {$approval_date = '&nbsp;';}
	if (!($approver)) {$approver = '&nbsp;';}
	
	@values = &get_approver2($dbh,$schema,$fiscalyear,$max_rev,$org,substr($type2,0,1));
	my ($approver2, $approval2_date) = @values;
	if (!($approval2_date)) {$approval2_date = '&nbsp;';}
	if (!($approver2)) {$approver2 = '&nbsp;';}

	print "<table border=1 cellspacing=1 cellpadding=1 bgcolor=#FFFFFF>\n";
	print "<tr height=25><td align=right>&nbsp;</td><td align=center><font size=-1><b>Approved</b></font></td><td align=center><font size=-1><b>Current</b></font></td></tr>\n";
	print "<tr height=25><td align=right><font size=-1><b>Revision:&nbsp;&nbsp;</b></font></td><td align=center><font size=-1><b>$displayRevision</b></font></td><td align=center><font size=-1><b>WIP</b></font></td></tr>\n";
	print "<tr height=25><td align=right><font size=-1><b>Audits:&nbsp;&nbsp;</b></font></td><td align=center><font size=-1><b>$approvedCount</b></font></td><td align=center><font size=-1><b>$auditCount</b></font></td></tr>\n";
	print "<tr height=25><td align=right><font size=-1><b>Assigned Numbers:&nbsp;&nbsp;&nbsp;</b></font></td><td align=center><font size=-1><b>$approvedAssignedCount</b></font></td><td align=center><font size=-1><b>$assignedCount</b></font></td></tr>\n";
	print "<tr><td align=right colspan=2><font size=-1><b>Last BSC Approver</b></font></td><td><b>&nbsp;&nbsp;$approver</b></td></tr>\n";
	#print "<tr><td align=right colspan=2><font size=-1><b>Date</b></font></td><td><font size=-1><b>&nbsp;&nbsp;$approval_date</b></font></td></tr>\n";
	print "<tr><td align=right colspan=2><font size=-1><b>Last OQA Approver</b></font></td><td><b>&nbsp;&nbsp;$approver2</b></td></tr>\n";
	print "<tr><td align=right colspan=2><font size=-1><b>Date</b></font></td><td><font size=-1><b>&nbsp;&nbsp;$approval2_date</b></font></td></tr>\n";
	print "<tr><td align=right colspan=4 height=10 bgcolor=#CCCCCC></tr>\n";
	if ($bscapprover) {
		print "<tr><td align=right colspan=2><font size=-1><b>Current BSC Approver</b></font></td><td><b>&nbsp;&nbsp;$bscapprover</b></td></tr>\n";
		print "<tr><td align=right colspan=2><font size=-1><b>Date</b></font></td><td><font size=-1><b>&nbsp;&nbsp;$bscapproval_date</b></font></td></tr>\n";
	}
	else {
		print "<tr><td align=right colspan=2><input type=button onClick=approve('audit',$fullyear,'$table','BSC'); value=\"BSC Approval\"></td><td>&nbsp;</td></tr>\n";
	}
	if ($oqaapprover) {
		print "<tr><td align=right colspan=2><font size=-1><b>Current OQA Approver</b></font></td><td><b>&nbsp;&nbsp;$oqaapprover</b></td></tr>\n";
		print "<tr><td align=right colspan=2><font size=-1><b>Date</b></font></td><td><font size=-1><b>&nbsp;&nbsp;$oqaapproval_date</b></font></td></tr>\n";
	}
	else {
		print "<tr><td align=right colspan=2><input type=button onClick=approve('audit',$fullyear,'$table','OQA'); value=\"OQA Approval\"></td><td>&nbsp;</td></tr>\n";
	}
	print "</table>\n";
	if ((!$remove) && ($userprivhash{'Developer'} == 1
		 || $userprivhash{$priv} == 1 || $userprivhash{$priv2} == 1) ) {
		#print "<br><input type=button onClick=approve('audit',$fullyear,'$type2','$org'); ";
		#print "value=\"   Approve $org\n$type2 Schedule\">\n";
	}
}	

############################
sub writeFormTop  {
############################
	my ($tag, $seq, $issuedToid, $issuedByid, $type, $forecast,$cancelled) = @_;
	my @type_array;
	my @newtype_array;
	tie my %issuedTohash,  "Tie::IxHash";
	tie my %issuedByhash,  "Tie::IxHash";
	my $display_fy = lpadzero($fy,2);
	my $display_seq;
	my $auditID; 
	my $issuedTo;
	my $issuedBy;
	my $title;
	my $displaytype;
   my $fiscalyear;
   my $disabled = $tag eq 'new' || $tag eq 'newem' ? '' : ' disabled ';
   
   $fiscalyear = $fy + 2000 if ($fy < 50);
   $fiscalyear = $fy + 1900 if ($fy > 50);
	if ($issuedToid) {$issuedTo = lookup_single_value($dbh,$schema,'organizations','abbr'," $issuedToid ");}
	else {$issuedToid = 0;}
	%issuedTohash = get_lookup_values($dbh, "organizations", 'id', 'abbr', " issued_to_list = 'T' or id = $issuedToid ");
	%issuedByhash = get_lookup_values($dbh, "organizations", 'id', 'abbr', " abbr in ('OQA','BSC','OCRWM', 'EM') ");
	#$audit_string = "$issuedTo-$id_type-$display_fy-";
   $title = "Issued To";
	if ($table eq "internal") {
   	@type_array = ("C","PB","P/PB","ALL");
   	@newtype_array = ("C","P");
    	%issuedTohash = get_lookup_values($dbh, "organizations", 'id', 'abbr', " issued_to_list = 'T' or id = $issuedToid ");
    	#$title = "Issued To";
    	$auditID = getInternalAuditId($dbh,$issuedByid,$issuedToid,$type,$fiscalyear,$seq);
	}
	elsif ($table eq "external") {
		@type_array = ("SA","SFE");
		%issuedTohash = get_lookup_values($dbh, "organizations", 'id', 'abbr', " performed_on_list = 'T' or id = $issuedToid ");
		#$title = "Performed By";
		$auditID = getExternalAuditId($dbh,$issuedByid,$issuedToid,$type,$fiscalyear,$seq);
	}
	if ($id_type eq 'P' || $id_type eq 'PB' || $id_type eq 'P/PB') {$displaytype = 'ARP';}
	elsif ($id_type eq 'ALL' || $id_type eq 'C') {$displaytype = 'ARC';}
	else {$displaytype = $id_type;}
	#$audit_string = "$issuedTo-$displaytype-$display_fy-";
	print "<br><table width=650 border=0 cellspacing=1 cellpadding=1>\n";
	if ($tag eq "new" || $tag eq "newem") {$display_fy = 50; } 
	elsif ($seq == 0) {
    	print "<tr><td valign=top colspan=4 align=center><font color=black><b>$auditID</b>&nbsp;\n";
    	print "<input type=text name=seq maxlength=2 size=3>\n";
    	print "<input type=hidden name=id_year value=$fy>\n";
    	print "<input type=button onClick=availableIDs(); value=\"Available IDs\"></td></tr>\n";
	}
	else {
    	$display_seq = lpadzero($seq,2);
    	print "<input type=hidden name=seq value=$seq>\n";
    	print "<tr><td valign=top colspan=4 align=center><font color=black><b>$auditID</b></td></tr>\n";
	}
	if ($cancelled eq 'Y') {
	 	print "<tr><td colspan=4 align=center><font color=red><b>Cancelled</b></font></td></tr>\n";
	}
	print "<tr height=12></tr>\n";
	print "<tr><td align=center><font size=-1><b>&nbsp;&nbsp;Issued By:<br>\n";
	if ($issuedByid && $table eq 'internal' && $issuedByid != 3){print "<input type=hidden name=issuedBy value=$issuedByid>$issuedByhash{$issuedByid}\n";}
	elsif ($table eq 'internal' && $tag eq "new") {print "<input type=hidden name=issuedBy value=24>OCRWM\n";}
	elsif ($table eq 'internal' && ($issuedByid == 3 || $tag eq "newem")) {print "<input type=hidden name=issuedBy value=3>EM/RW\n";}
	else {
		foreach my $orgid (keys %issuedByhash) {
			if ($orgid == $issuedByid && $orgid != 24){
				print "<input type=radio name=issuedBy checked $disabled value=\"$orgid\">$issuedByhash{$orgid}\n";
				if ($disabled eq  ' disabled ') {print "<input type=hidden name=issuedBy value=$orgid>\n";}
			}
			elsif ($orgid != 24) {print "<input type=radio name=issuedBy $disabled value=\"$orgid\">$issuedByhash{$orgid}\n";}	
		}
	}
	print "</td><td valign=top><font size=-1><b>$title:</b><br>\n";
	print "<select name=issuedTo size=1>\n";
	if ($tag eq "new" || $tag eq "newem") {print "<option value=0>\n";}
	foreach my $keys (keys %issuedTohash) {
    	if ($keys == $issuedToid ){print "<option selected value=\"$keys\">$issuedTohash{$keys}\n";}
    	else {print "<option value=\"$keys\">$issuedTohash{$keys}\n";}	
    }
    print "</td>\n";
    print "<td nowrap valign=top><font size=-1><b>Type:</b><br>";
    if ($tag eq 'new') {
    	if ($fiscalyear <= 2002) {print "<span id=\"before\" Style=Display:block; >\n";}
    	else {print "<span id=\"before\" Style=Display:none; >\n";}
    	foreach my $audit_type ( @type_array ) {
    		print "<input type=radio name=auditType value=$audit_type>";
    		if ($audit_type eq 'SA') {print "<b>Audit</b> &nbsp;\n";}
    		elsif ($audit_type eq 'SFE') {print "<b>Survey</b> &nbsp;\n";}
    		else {print "<b>$audit_type</b> &nbsp;\n";}
		}
		print "</span>\n"; 
		if ($fiscalyear <= 2002) {print "<span id=\"after\" Style=Display:none; >\n";}
		else  {print "<span id=\"after\" Style=Display:block; >\n";}
		if ($table eq 'internal') {@type_array = @newtype_array;}
		foreach my $audit_type ( @type_array ) {
			print "<input type=radio name=auditType value=$audit_type>";
			if ($audit_type eq 'SA') {print "<b>Audit</b> &nbsp;\n";}
			elsif ($audit_type eq 'SFE') {print "<b>Survey</b> &nbsp;\n";}
			else {print "<b>$audit_type</b> &nbsp;\n";}
		}
		print "</span>\n"; 
	}
	else {
	   if ($fiscalyear >=2003 && $table eq 'internal') {@type_array = @newtype_array;}
		foreach my $audit_type ( @type_array ) {
	    	if ($audit_type eq $type) {print "<input type=radio name=auditType value=$audit_type checked>\n";}
	    	else {print "<input type=radio name=auditType value=$audit_type>";}
	    	if ($audit_type eq 'SA') {print "<b>Audit</b> &nbsp;\n";}
	    	elsif ($audit_type eq 'SFE') {print "<b>Survey</b> &nbsp;\n";}
	    	else {print "<b>$audit_type</b> &nbsp;\n";}
		}
	}
	print "</td><td>";
	if ($disabled eq ' disabled ') {
		print "<font size=-1><b>Fiscal Year:&nbsp;&nbsp;<br>&nbsp;&nbsp;&nbsp;&nbsp;$fiscalyear</b></font>\n";
		print "<input type=hidden name=fy value=$fiscalyear>\n";
	}
	else {selectFY($display_fy);}
	print "</td></tr></table>\n";
}
############################
if ($cgiaction2 eq "populate_location") {
############################
	my $supplierid = $NQScgi->param('QualifiedSupplier');
	my $locationstring = &lookup_single_value($dbh,$schema,'qualified_supplier','upper(city || state || province)',$supplierid);
   my $locid = &get_value($dbh,'locations','id',"'$locationstring' = (city || state || province)");
	my $product = &get_value($dbh,'qualified_supplier','product'," id = $supplierid ");
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "var len = parent.workspace.audit.loc1.length;\n";
	print "var clear = 1;\n";
   print "var i;\n";
   print "for (i = 0; i < len; i++) {\n";
   print "	if (parent.workspace.audit.loc1.options[i].value == $locid) {\n";
   print "		parent.workspace.audit.loc1.options[i].selected = true;\n";
   print "		i = len;\n";
   print "		clear = 0;\n";
   print "	}\n";
   print "  if (clear == 1) {\n";
   print "		parent.workspace.audit.loc1.options[0].selected = true;\n";
   print "	}\n";
   print "}\n";
   if (defined($product)) {print "	parent.workspace.audit.product.value = '$product';\n";}
   else {print "	parent.workspace.audit.product.value = '';\n";}
	print "//-->\n";
	print "</script>\n";
}
############################
if ($cgiaction2 eq "add_supplier") {
############################
	my $address1 = $NQScgi->param('address1');
	my $address2 = $NQScgi->param('address2');
	my $city = $NQScgi->param('city');
	my $state = $NQScgi->param('state');
	my $province = $NQScgi->param('province');
	my $company = $NQScgi->param('company');
	my $product = $NQScgi->param('newproduct');
	my $external_active = ($NQScgi->param('external_active') eq 'T') ? 'T' : 'F';
	my $surveillance_active = ($NQScgi->param('surveillance_active') eq 'T') ? 'T' : 'F';
	my $active =  ($external_active eq 'F' && $surveillance_active eq 'F') ? 'F' : 'T';
	my $country = ($state ne "") ? "USA" : "CAN";
	my $locid;
	my $nextid;
	my $sqlstring;
	my $companyid;
	my $csr;
	my $csr2;
		    
   $dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	
	eval {
		$sqlstring = "SELECT id FROM $SCHEMA.qualified_supplier WHERE UPPER(company_name) = '" . uc($company) . "'";
		$csr = $dbh->prepare($sqlstring);
		$csr->execute;
		$companyid = $csr->fetchrow_array;
		if (!defined($companyid)) {
   		$nextid = &get_max_id($dbh,'qualified_supplier','id') + 1;
   		$sqlstring = "insert into $schema.qualified_supplier ";
			$sqlstring .= "(id,company_name,address1,address2,product,city,state,province,external_active,surveillance_active,active) ";
			$sqlstring .= "values ($nextid,'$company','$address1','$address2','$product','$city','$state','$province','$external_active','$surveillance_active','$active') ";
	 
			$csr2 = $dbh->prepare($sqlstring);
			$csr2->execute;	
   		$csr2 -> finish;
   
			$locid = &get_value($dbh,'locations','id',"upper('$city' || '$state' || '$province') = (city || state || province)");
   	}
   };
   if ($@) {
   	print STDERR "\n$@\n";
   }
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
	if (!defined($companyid)) {
		print "	 alert('Company $company has been addded to the system');\n";
		print "	 populateSupplier($locid,$nextid);\n";
	}
	else {
		print "	 alert('There is already a company called $company in the system');\n";
	}
	print "parent.workspace.$form.cgiaction2.value = '';\n";
	print "parent.workspace.$form.action = '$path' + 'audit.pl';\n";
	print "parent.workspace.$form.target = 'workspace';\n";
	print "//-->\n";
	print "</script>\n";
	$cgiaction2 = '';
}
############################
elsif ($cgiaction eq "browse_audits") {
############################
	my $audit_select = $NQScgi->param('audit_type');
	my $fullyear = $NQScgi->param('fy');
	my $fy = substr($fullyear,2);
	my $csr;
	my $csr2;
	my @values;
	my @values2;
	my $title;
	my $col_display;
	my $display_yr;
	my $display_seq;
	my $first = 1;
	my $currentid = 0;
	my $norecords = 1;
	my ($yr,$num,$seq,$scope,$typ,$leadid,$teamlead,$notes,$type,$issuedto,$issuedby,$cancelled);
	my ($issuedtoid,$issuedbyid,$table,$forecast,$begin,$end,$str,$issuedbystr,$auditID,$reportlink);
	if (length($audit_select) > 8) {
		$str = uc(substr($audit_select,9));
		$issuedbyid = get_value($dbh,'organizations'," id "," abbr = upper('$str')");
		$issuedbystr  = " and issuedby_org_id = $issuedbyid ";
	}
	print "<input type=hidden name=fy value=$fy>\n";
	print "<br><table width=750 border=1 cellspacing=1 cellpadding=1>\n";

	if (substr($audit_select,0,8) eq 'internal' || $audit_select eq 'all') {
	   $norecords = 1;
    	my $sqlquery = "SELECT audit_type, fiscal_year, id, audit_seq, scope, ";
    	$sqlquery .= " team_lead_id, notes, issuedto_org_id, cancelled, to_char(forecast_date,'MM/YYYY'), ";
    	$sqlquery .= "to_char(begin_date,'MM/DD/YYYY'), to_char(end_date,'MM/DD/YYYY'), issuedby_org_id, reportlink ";
    	$sqlquery .= "FROM $schema.internal_audit ";
    	$sqlquery .= "where fiscal_year = $fy and revision = 0 ";
    	if (defined($issuedbystr)) {$sqlquery .= "$issuedbystr ";}
    	$sqlquery .= "order by issuedby_org_id desc, to_char(begin_date,'YYYY/MM/DD') || to_char(forecast_date,'YYYY/MM/DD'), audit_seq, audit_type";

    	$csr = $dbh->prepare($sqlquery);
    	$csr->execute;
    	
    	while (@values = $csr->fetchrow_array) {
     		$typ = defined($values[0]) ? $values[0] : '';
     		$yr = defined($values[1]) ? $values[1] : '';
     		$num = defined($values[2]) ? $values[2] : '';
     		$seq = defined($values[3]) ? $values[3] : 0;
     		$scope = defined($values[4]) ? $values[4] : '';
     		$leadid = defined($values[5]) ? $values[5] : 0;
     		$notes = defined($values[6]) ? $values[6] : '';
     		$issuedtoid = defined($values[7]) ? $values[7] : '';
     		$cancelled = defined($values[8]) ? $values[8] : '';
     		$forecast = defined($values[9]) ? $values[9] : '';
     		$begin = defined($values[10]) ? $values[10] : '';
     		$end = defined($values[11]) ? $values[11] : '';
     		$issuedbyid = defined($values[12]) ? $values[12] : 0;
     		$reportlink = defined($values[13]) ? $values[13] : 0;

     		if ($begin eq 'mm/dd/yyyy') {$begin = '';}
     		if ($end eq 'mm/dd/yyyy') {$end = '';}

     		$display_yr = lpadzero($yr,2);
     		if ($cancelled) {$teamlead = 'N/A';}
     		elsif ($leadid != 0) {
				$teamlead = lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname "," $leadid ");
			}
			else {$teamlead = 'TBD';}
     		if ($issuedtoid) {
				$issuedto = lookup_single_value($dbh,$schema,'organizations','abbr'," $issuedtoid ");
    		}
    		else {$issuedto = '###';}
     		if ($typ eq 'P' || $typ eq 'PB' || $typ eq 'P/PB') {
				$type = 'ARP';
				$table = 'internal';
			}
			elsif ($typ eq 'ALL' || $typ eq 'C') {
				$type = 'ARC';
				$table = 'internal';
			}
     		$auditID = getInternalAuditId($dbh,$issuedbyid,$issuedtoid,$typ,$fullyear,$seq);
      	if ($cancelled) {$col_display = "Cancelled";}
      	elsif ($begin) {$col_display = substr($begin,0,2) . ' / ' . substr($begin,3,2) . ' / ' . substr($begin,6);}
      	elsif ($forecast) {$col_display = '' . substr($forecast,0,2) . ' / ' . substr($forecast,3);}
      	else {$col_display = '';}
     
     
     		if ($currentid != $issuedbyid) {
     			$str = get_value($dbh,'organizations'," abbr "," id = $issuedbyid ");  			
     			print "<tr  bgcolor=lightsteelblue><td colspan=4 align=center><b><font color=black>" . ($str eq "EM" ? "Audits Issued By EM/RW" : "Internal Audits Issued By $str") . "</font></b></td></tr>\n";
			   print "<tr  bgcolor=aliceblue><td align=center><b><font color=black>Audit Number</font></b></td><td nowrap><b><font color=black>Team Lead</font></b></td>\n";
      		print "<td align=center><b><font color=black>Scope</font></b></td><td align=center><b><font color=black>Start Date</font></b></td></tr>\n";
     			$currentid = $issuedbyid;
     		}
     		print "<tr  bgcolor=white><td nowrap><a href=javascript:submitView('$table',$fy,'$type',$num);><font size=-1>$auditID</font></a>\n";
     		print "</td><td><font size=-1>$teamlead &nbsp;</font></td><td><font size=-1 color=black>Organizations:&nbsp;</font><font size=-1>";
     		&writeOrganizations($num,$fy,$table);
     		print "</font><br><font size=-1 color=black>Locations:&nbsp;</font><font size=-1>";
     		&writeLocations($num,$fy,$table);
     		print "<br><a href=javascript:reportWindow('$reportlink');>View Report</a>\n" if ($reportlink);
     		print "</font></td><td nowrap align=center><font size=-1>$col_display &nbsp;</font></td></tr>\n";
     		$norecords = 0;
    	}
    	$csr->finish;
    	if ($norecords) {print "<tr><td colspan=4 align=center>No records found</td></tr>\n";}
	}
	$first = 1;
	if ($audit_select eq 'external' || $audit_select eq 'all') {
		my $sqlquery2 = "SELECT audit_type, fiscal_year, id, audit_seq, scope, ";
		$sqlquery2 .= " team_lead_id, notes, issuedto_org_id, cancelled, to_char(forecast_date,'MM/YYYY'), ";
		$sqlquery2 .= "to_char(begin_date,'MM/DD/YYYY'), to_char(end_date,'MM/DD/YYYY'), qualified_supplier_id, issuedby_org_id, reportlink "; 
		$sqlquery2 .= "FROM $schema.external_audit ";
		$sqlquery2 .= "where fiscal_year = $fy and revision = 0 ";
		$sqlquery2 .= "order by to_char(begin_date,'YYYY/MM/DD') || to_char(forecast_date,'YYYY/MM/DD'), audit_type, audit_seq";

		$csr2 = $dbh->prepare($sqlquery2);
		$csr2->execute;
	
		while (@values2 = $csr2->fetchrow_array) {
			$typ = defined($values2[0]) ? $values2[0] : '';
			$yr = defined($values2[1]) ? $values2[1] : '';
			$num = defined($values2[2]) ? $values2[2] : '';
			$seq = defined($values2[3]) ? $values2[3] : 0;
			$scope = defined($values2[4]) ? $values2[4] : '';
			$leadid = defined($values2[5]) ? $values2[5] : 0;
			$notes = defined($values2[6]) ? $values2[6] : '';
			$issuedtoid = defined($values2[7]) ? $values2[7] : 0;
			$cancelled = defined($values2[8]) ? $values2[8] : '';
			$forecast = defined($values2[9]) ? $values2[9] : '';
			$begin = defined($values2[10]) ? $values2[10] : '';
     		$end = defined($values2[11]) ? $values2[11] : '';
     		my $supplierid = defined($values2[12]) ? $values2[12] : 0;
     		$issuedbyid = defined($values2[13]) ? $values2[13] : 0;
     		$reportlink = defined($values2[14]) ? $values2[14] : 0;

     		$display_yr = lpadzero($yr,2);
     		if ($cancelled) {$teamlead = 'N/A';}
     		elsif($leadid != 0) {
				$teamlead = lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname "," $leadid ");
    		}
    		else {$teamlead = 'TBD';}
    		if ($issuedtoid) {
				$issuedto = lookup_single_value($dbh,$schema,'organizations','abbr'," $issuedtoid ");
			}
    		else {$issuedto = '###';}
			if ($typ eq 'SA' ) {
				$type = 'SA';
				$table = 'external';
			}
			else {
				$type = 'SFE';
				$table = 'external';
			}
		   $auditID = getExternalAuditId($dbh,$issuedbyid,$issuedtoid,$type,$fullyear,$seq);
			if ($cancelled) {$col_display = "Cancelled";}
      	elsif ($begin) {$col_display = substr($begin,0,2) . ' / ' . substr($begin,3,2) . ' / ' . substr($begin,6);}
      	elsif ($forecast) {$col_display = '' . substr($forecast,0,2) . ' / ' . substr($forecast,3);}
      	else {$col_display = '';}
      
      	if ($first) {
      		print "<tr  bgcolor=lightsteelblue><td colspan=4 align=center><b><font color=black>External Audits</font></b></td><tr>\n";
				print "<tr bgcolor=aliceblue><td align=center><b><font color=black>Audit Number</font></b></td><td nowrap><b><font color=black>Team Lead</font></b></td>\n";
      		print "<td align=center><b><font color=black>Scope</font></b></td><td align=center><b><font color=black>Start Date</font></b></td></tr>\n";
      		$first = 0;
      	}
			print "<tr  bgcolor=white><td nowrap><a href=javascript:submitView('$table',$fy,'$type',$num);><font size=-1>$auditID</font></a>\n";
			print "</td><td><font size=-1>$teamlead &nbsp;<font size=-1></td><td><font size=-1>";
		
			&writeSupplier($supplierid,$fy,'');
			print "<br><a href=javascript:reportWindow('$reportlink');>View Report</a>\n" if ($reportlink);
			print "</td><td nowrap align=center><font size=-1>$col_display &nbsp;</font></td></tr>\n";
			$norecords = 0;
		}
      $csr2->finish;
      if ($norecords) {print "<tr><td colspan=4 align=center>No records found</td></tr>\n";}
	}
	print "</table><br><br>\n";
	print "<input type=hidden name=sched >\n";
	print "<input type=hidden name=yr value=$yr>\n";
	print "<input type=hidden name=fullyear value=$fullyear>\n";
	print "<input type=hidden name=id_type value=$type>\n";
}
############################
elsif ($cgiaction eq "available_IDs") {
############################
   my $fy = $NQScgi->param('id_year');
   my $type = $NQScgi->param('auditType');
   my $auditorg = $NQScgi->param('issuedBy');
   my $i = 0;
   my @availableID;
   my $nextSequentialID;
   my @values;
   my $msg;
   my $msg2 = "";
   my $audittype;
   my $auditorgstr;
   
   if ($type eq 'C' || $type eq 'P' || $type eq 'PB' || $type eq 'P/PB' || $type eq 'ALL' ) {
   	$audittype = " ";
   	$auditorgstr = " and issuedby_org_id = $auditorg ";
   }
   elsif ($type eq 'SA'  ) {
   	$audittype = " and audit_type = 'SA' ";
   	$auditorgstr = "  ";
   }
   elsif ($type eq 'SFE'  ) {
   	$audittype = " and audit_type = 'SFE' ";
   	$auditorgstr = "  ";
   }
   
   my $sqlquery = "SELECT distinct audit_seq from " . $schema . "." . $table . "_audit where ";
   $sqlquery .= "fiscal_year = $fy and revision = 0  $audittype $auditorgstr and audit_seq != 0 order by audit_seq";

 	my $csr = $dbh->prepare($sqlquery);
   $csr->execute;
 	while (@values = $csr->fetchrow_array) {
   	$nextSequentialID = $values[0];
		$i++;
   	while ($i < $nextSequentialID) {
   		@availableID = @availableID + $i;
   		$msg .= " " . $i ;
   		$i++;
   	}
   }
   $nextSequentialID += 1;
   if ($msg) {
   	$msg2 .= "The following numbers have been skipped: ";
   	$msg2 .= $msg;
   }
   else {$msg2 .= "No sequence numbers have been skipped or deleted.";}
   $msg2 .= " \\nThe next sequential number is " . $nextSequentialID ;
   print "<script language=javascript><!--\n   alert('$msg2');\n//-->\n</script>\n";
}
############################
elsif ($cgiaction eq "active_audit") {
############################
	$fy = defined($NQScgi->param('year')) ? $NQScgi->param('year') :$NQScgi->param('fy');
	my $csr;
	my @values;
	my @details;
	my @summary;
	my $sqlstring; 
	my $select_table;
	my $display_fy;
	my ($seq,$type,$issuedto,$issuedby,$start,$end,$leadid,$plandetail,$notes);
	my ($issuedtoid,$issuedbyid,$cancelled,$forecast,$completed,$team,$product,$supplierid);

	if (defined($fy)) { $display_fy = lpadzero($fy,2); }
	else { $fy = 50; }
	if ($table eq 'internal') {$select_table = "internal_audit";}
	elsif ($table eq 'external') {$select_table = "external_audit";}
	else {$select_table = "undefined";}

	$sqlstring = "SELECT audit_seq, audit_type, issuedto_org_id, to_char(begin_date,'mm/dd/yyyy'), to_char(end_date,'mm/dd/yyyy'), ";
	$sqlstring .= "team_lead_id, scope, notes, cancelled, to_char(forecast_date,'mm/yyyy'), to_char(completion_date,'mm/dd/yyyy'), team_members, issuedby_org_id ";
	if ($table eq 'external') {$sqlstring .= ",qualified_supplier_id, product ";}
	$sqlstring .= "from $SCHEMA.$select_table ";
	$sqlstring .= "where fiscal_year = $fy and revision = 0 and id = $sched";
	if ($tag ne "new" && $tag ne "newem") {
    	$csr = $dbh->prepare($sqlstring);
    	$csr->execute;
    	@values = $csr->fetchrow_array;
	}

	$seq = defined($values[0]) ? $values[0] : 0;
	$type = defined($values[1]) ? $values[1] : '';
	$issuedtoid = defined($values[2]) ? $values[2] : 0;
	$start = defined($values[3]) ? $values[3] : 'mm/dd/yyyy';
	$end = defined($values[4]) ? $values[4] : 'mm/dd/yyyy';
	$leadid = defined($values[5]) ? $values[5] : 0;
	$plandetail = defined($values[6]) ? $values[6] : '';
	$notes = defined($values[7]) ? $values[7] : '';
	$cancelled = defined($values[8]) ? $values[8] : '';
	$forecast = defined($values[9]) ? $values[9] : 'mm/yyyy';
	$completed = defined($values[10]) ? $values[10] : 'mm/dd/yyyy';
	$team = defined($values[11]) ? $values[11] : '';
	$issuedbyid = defined($values[12]) ? $values[12] : 0;
	if ($table eq 'external') {
		$supplierid = defined($values[13]) ? $values[13] : 0;
		$product = defined($values[14]) ? $values[14] : '';
	}
	&writeFormTop($tag,$seq,$issuedtoid,$issuedbyid,$type,$forecast,$cancelled);
	print "<table width=650 border=0 cellspacing=1 cellpadding=1 bordercolor=red>\n";
	if ($table eq 'internal') {
    	print "<tr><td width=60% align=center>"; 
    	print "<table border=0 bordercolor=gray rules=none cellspacing=0 cellpadding=3>\n";
    	&select_org_locs($sched,$fy);
	}
	elsif ($table eq 'external') {
    	&selectQualifiedSuppliers($supplierid,$fy,$product);
    	print "<table border=0 bordercolor=green  cellspacing=0 cellpadding=3 width=650>\n";
    	&add_supplier_form;
    	print "<tr><td valign=top align=center>"; 
    	print "<table border=0 bordercolor=gray rules=none cellspacing=0 cellpadding=3>\n";
    	&select_locs($sched,$fy);
	}
	print "</table></td>\n<td valign=top align=center>";
	print "<table border=0 cellspacing=1 cellpadding=1>\n";
	print "<tr><td>&nbsp;&nbsp;<font size=-1><b>Forecast:</b></td><td><input name=forecast type=text maxlength=15 size=15 value=$forecast onBlur=checkForecastDate(value,this)></td></tr>\n";
	print "<tr><td nowrap>&nbsp;&nbsp;<font size=-1><b>Begin Date:</b></td><td><input name=Begindate type=text maxlength=15 size=15 value=$start onBlur=checkDate(value,this)></td></tr>\n";
	print "<tr><td>&nbsp;&nbsp;<font size=-1><b>End Date:</b></td><td><input name=Enddate type=text maxlength=15 size=15 value=$end onBlur=checkDate(value,this)></td></tr>\n";
	print "<tr><td>&nbsp;&nbsp;<font size=-1><b>Completed:</b></td><td><input name=Completiondate type=text maxlength=15 size=15 value=$completed onBlur=checkDate(value,this)></td></tr>\n";
	&selectTeam($leadid,$team,$table);
	print "</table>\n";
	print "</td></tr>\n</table>\n";
	print "<table width=60% align=center border=0 cellpadding=1 cellspacing=1>\n";
	print "<tr><td valign=top colspan=2>\n";
	print "<font size=-1><b>Audit Scope Detail:</b><br>\n";
	print "<textarea name=Scope rows=5 cols=80 onBlur=checkLength(value,this);>$plandetail</textarea><br>\n";
	print "</td></tr>\n";
	print "<tr><td valign=top colspan=2>\n";
	print "<font size=-1><b>Notes/Comments:</b><br>\n";
	print "<textarea name=Notes rows=3 cols=80 onBlur=checkLength(value,this);>$notes</textarea><br>\n";
	print "</td></tr>\n";
	print "</table><br>\n";
	print "<input type=hidden name=sid value=$sched>\n";
	print "<input type=hidden name=fy value=$fy>\n";
	print "<input type=hidden name=id_type value=$id_type>\n";
	if ($tag eq "new" || $tag eq "newem") {
		print "&nbsp;&nbsp;&nbsp;<input type=button onClick=submitNew(document.$form,'$table'); value=\"Submit\"><br>\n";
	} 
	else {
		print "&nbsp;&nbsp;&nbsp;<input type=button onClick=submitUpdate(document.$form,'$table'); value=\"Submit Changes\">\n" if ($cancelled ne 'Y');
		if ($cancelled ne 'Y' && $completed eq 'mm/dd/yyyy') {
			print "&nbsp;&nbsp;&nbsp;<input type=button onClick=cancel($fy,'$table',$sched) value=\"Cancel Audit\">";
		}
	}
	if ($tag ne "new" && $tag ne "newem") {
    	my $sqlquery = "SELECT max(revision) from $schema" . "." . $table . "_audit where fiscal_year = $fy and id = $sched";
	 	my $csr2 = $dbh->prepare($sqlquery);
	 	$csr2->execute;
	 	my @maxid=$csr2->fetchrow_array;
    	if ($maxid[0] == 0 && $completed eq 'mm/dd/yyyy') {
    		print "&nbsp;&nbsp;&nbsp;<input type=button onClick=deleteAudit($fy,'$table',$sched); value=\"Delete Audit\">\n";
    	}
	}
	print "<br><br>\n";
}
############################
elsif ($cgiaction eq "add_report" || $cgiaction eq "edit_report") {
############################
	$fy = defined($NQScgi->param('yr')) ? $NQScgi->param('yr') : $NQScgi->param('fy');
	my $header = defined($NQScgi->param('header')) ? $NQScgi->param('header') : '';
	my $sched = defined($NQScgi->param('sched')) ? $NQScgi->param('sched') : '';
	my $reportlink = defined($NQScgi->param('reportlink')) ? $NQScgi->param('reportlink') : '';
	
	print "<table border=0 cellspacing=1 cellpadding=1 width=75%>\n";
	print "<br><br>\n";
	print "<tr><td colspan=2 align=center><b>$header<br><br></b></td></tr>\n";
	print "<tr><td align=center><font size=-1><b>Correspondence Control Database - Document Log Number:</b></font></td></tr>\n";
	print "<tr><td align=center><input name=addreportlink type=text size=50% onBlur=checkLength(value,this) value=$reportlink></td></tr>\n";
	print "</table><br>\n";
	print "<input type=hidden name=sched value=$sched>\n";
	print "&nbsp;&nbsp;&nbsp;<input type=button onClick=submitReportLink('audit','insertreport') value=\"Submit\"><br>\n";
	
	print "<br><br>\n";
}

############################
elsif ($cgiaction eq "delete_report") {
############################
	$fy = defined($NQScgi->param('yr')) ? $NQScgi->param('yr') : $NQScgi->param('fy');
	my $header = defined($NQScgi->param('header')) ? $NQScgi->param('header') : '';
	my $sched = defined($NQScgi->param('sched')) ? $NQScgi->param('sched') : '';
	my $csr;
	my @values;
	my @details;
	my @summary;
	my $sqlstring; 
	my $select_table;
	my $display_fy;
	my ($seq,$type,$issuedto,$issuedby,$start,$end,$leadid,$plandetail,$notes);
	my ($issuedtoid,$issuedbyid,$cancelled,$forecast,$completed,$team,$product,$supplierid);

	print "<table border=0 cellspacing=1 cellpadding=1 width=75%>\n";
	print "<br><br>\n";
	print "<tr><td colspan=2 align=center><b>$header<br><br></b></td></tr>\n";
	print "<tr><td><font size=-1><b>Correspondence Control Database - Document Log Number:</b></font></td></tr>\n";
	print "<tr><td><input name=addreportlink type=text size= 100% onBlur=checkLength(value,this)></td></tr>\n";
	print "</table><br>\n";
	print "<input type=hidden name=sched value=$sched>\n";
	print "&nbsp;&nbsp;&nbsp;<input type=button onClick=submitReportLink('audit','insertreport') value=\"Submit\"><br>\n";
	
	print "<br><br>\n";
}
############################
elsif ($cgiaction eq "view_audit") {
############################
	my $table = $NQScgi->param('table');
	my $csr;
	my $csr2;
	my $csr3;
	my @values;
	my @details;
	my @summary;
	my $sqlstring;
	my $select_table;
	my $display_fy = lpadzero($fy,2);
	my $fiscalyear;
	my $teamlead;
	my $issuedto;
	my $supplierid;
	my $product;
	my $issuedby;
	my $issuedbyid;
	my $auditID;

	$fiscalyear = $fy + 2000 if ($fy < 50);
   	$fiscalyear = $fy + 1900 if ($fy > 50);
	if ($table eq 'internal') {$select_table = "internal_audit";}
	elsif ($table eq 'external') {$select_table = "external_audit";}
	else {$select_table = "undefined";}

	$sqlstring = "SELECT audit_seq, audit_type, issuedto_org_id, to_char(begin_date,'mm/dd/yyyy'), to_char(end_date,'mm/dd/yyyy'), ";
	$sqlstring .= "team_lead_id, scope, notes, cancelled, to_char(forecast_date,'mm/yyyy'), completion_date, team_members, issuedby_org_id, reportlink ";
	if ($table eq 'external') {$sqlstring .= ",qualified_supplier_id, product ";}
	$sqlstring .= "from $SCHEMA.$select_table ";
	$sqlstring .= "where fiscal_year = $fy and revision = 0 and id = $sched";

	$csr = $dbh->prepare($sqlstring);
	$csr->execute;
	@values = $csr->fetchrow_array;
	$csr->finish;

	my $seq = defined($values[0]) ? lpadzero($values[0],2) : 0;
	my $type = defined($values[1]) ? $values[1] : '';
	my $issuedtoid = defined($values[2]) ? $values[2] : '';
	my $start = defined($values[3]) ? $values[3] : '';
	my $end = defined($values[4]) ? $values[4] : '';
	my $leadid = defined($values[5]) ? $values[5] : 0;
	my $plandetail = defined($values[6]) ? $values[6] : '';
	my $notes = defined($values[7]) ? $values[7] : 'None';
	my $cancelled = defined($values[8]) ? $values[8] : '';
	my $forecast = defined($values[9]) ? $values[9] : '';
	my $completed = defined($values[10]) ? $values[10] : '';
	my $team = defined($values[11]) ? $values[11] : '';
	$issuedbyid = defined($values[12]) ? $values[12] : '';
	my $reportlink = defined($values[13]) ? $values[13] : '';
	if ($table eq 'internal') {$auditID = getInternalAuditId($dbh,$issuedbyid,$issuedtoid,$type,$fiscalyear,$seq);}
	elsif ($table eq 'external') {
		$supplierid = defined($values[14]) ? $values[14] : 0;
		$product = defined($values[15]) ? $values[15] : '';
		$auditID = getExternalAuditId($dbh,$issuedbyid,$issuedtoid,$type,$fiscalyear,$seq);
	}
	$teamlead = lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname "," $leadid ");
	if (!defined($teamlead)) {$teamlead = "TBD";}
	if ($cancelled) {$teamlead = 'N/A';}
	if ($issuedtoid) {$issuedto = lookup_single_value($dbh,$schema,'organizations','abbr'," $issuedtoid ");}
	else {$issuedto = '###';}
	if ($issuedbyid) {$issuedby = lookup_single_value($dbh,$schema,'organizations','abbr'," $issuedbyid ");}
	else {$issuedby = 'OQA';}
	print "<br><font color=black><b>$auditID";
	print "<table width=70% border=0 cellspacing=1 cellpadding=1>\n";
	print "<tr>\n <td valign=top>\n";
	print "  <b>Issued To:&nbsp;<font color=black>$issuedto</font></b></td>\n";
	print "<td valign=top><b>Issued By:&nbsp;<font color=black>" . ($issuedby eq "EM" ? "EM/RW" : "$issuedby") . "</font></b></td>\n";
	print "	<td valign=top><b>Team Lead:&nbsp;<font color=black>$teamlead</font></b><br>\n";
	print "   </td><td valign=top>\n";
	if ($cancelled) {print "&nbsp;<font color=red><b>Cancelled </b></font><br>\n";}
	elsif ($start) {
    	print "<b>Start Date:&nbsp;<font color=black>$start </font><br>\n";
    	if ($end) {print "End Date:&nbsp;&nbsp;<font color=black>$end</font></b>\n";}
	}
	else {print "<b>Forecast Date:&nbsp;<font color=black>$forecast</font></b><br>";}
	print "  </td></tr>\n";
	print "<tr>\n <td valign=top colspan=4>\n";
	if ($table eq 'external') {
		print "	<b>Qualified Supplier:<font color=black>\n";
		&writeSupplier($supplierid,$fy,$table);
		print "</font><br>Product: <font color=black>$product </font></b>\n";
	}
	print "</font></b></td></tr>\n";
	&get_org_locs($sched,$fy,$table);

	print "<tr>\n <td valign=top colspan=3>\n";
	print "  <b>Team Members:&nbsp;\n";
	print "<font color=black>$team</font></b><br>\n";
	print "  </td>\n</tr>\n";
	print "<tr>\n <td valign=top colspan=4>\n";
	print "  <b>Audit Scope Detail:&nbsp;\n";
	print "<font color=black>$plandetail</font></b><br>\n";
	print "  </td>\n</tr>\n";
	print "<tr>\n <td valign=top colspan=4>\n";
	print "  <b>Notes/Comments:&nbsp;\n";
	print "<font color=black>$notes</font></b><br>\n";
	print "  </td>\n</tr>\n";
	if ($reportlink) {
		print "<tr><td valign=top colspan=4><b>View Report</b><br>&nbsp;&nbsp;&nbsp;<a href=javascript:reportWindow('$reportlink');><img src=$NQSImagePath/report.gif></a><br><br></td></tr>\n";
		#print "<tr><td valign=top>View Report</td><td colspan=3 align=left><a href=http://ymln4.ymp.gov/Databases/bso/CorConSys.nsf/Correspondence%20Documents%2FBy%20Log%20Number/" . $reportlink . "?OpenDocument&ExpandSection=1#_Section1 target=new><img src=$NQSImagePath/report.gif></a></td></tr>\n";
	}
	print "<input type=hidden name=sched value=$sched>\n";
	print "<input type=hidden name=id_type value=$type>\n";
	print "<input type=hidden name=fy value=$fy>\n";
	print "<input type=hidden name=header value=$auditID>\n";

	if (($cancelled ne 'Y') && ($userprivhash{'Developer'} == 1 || 
	        ( (($userprivhash{'OQA Supplier Administration'} == 1 && $issuedby eq 'OQA') || ($userprivhash{'BSC Supplier Administration'} == 1 && $issuedby eq 'BSC')) && $table eq 'external') 
           || ((($userprivhash{'OQA Internal Administration'} == 1 && ($issuedby eq 'OQA' || $issuedby eq 'OCRWM')) || ($userprivhash{'BSC Internal Administration'} == 1 && ($issuedby eq 'BSC' || $issuedby eq 'OCRWM'))) && $table eq 'internal')
	        || (((($userprivhash{'OQA Internal Lead'} == 1 || $userprivhash{'BSC Internal Lead'} == 1) && $table eq 'internal') 
	        || (($userprivhash{'OQA Supplier Lead'} == 1 || $userprivhash{'BSC Supplier Lead'} == 1) && $table eq 'external'))  && $leadid == $userid))) {
	 	if ($reportlink) {
	 		print "<tr><td colspan=2 align=center><a href=javascript:addReport('$table',$fy,'$type',$sched,'edit_report','$reportlink');>Edit Report Log No.</a></td>\n";
	 	} else {
	 		print "<td colspan=2 align=center><a href=javascript:addReport('$table',$fy,'$type',$sched,'add_report','');>Add Report Log No.</a></td>\n";
	 	}
	 	print "<td colspan=2 align=center><a href=javascript:submitActive('$table',$fy,'$type',$sched);>Edit Audit</a></td></tr>\n";
	}
	
	print "</table><br>\n";   
}
############################
elsif ($cgiaction eq "approve_audit_form") {
############################
	my $displayyear = $NQScgi->param('fiscalyear');
	my $removeinternal = $NQScgi->param('removeinternal');
	my $removeexternal = $NQScgi->param('removeexternal');
	my $fiscalyear = substr($displayyear,2);
	my $def_yr;
	my $current_year = $dbh -> prepare ("select to_char(sysdate,'MM/YYYY') from dual");
	$current_year -> execute;
	my $mmyyyy = $current_year -> fetchrow_array;
	$current_year -> finish;
	my $mm = substr($mmyyyy,0,2);
	if ($mm > 9) {$def_yr = substr($mmyyyy,3) + 1;}
	else { $def_yr = substr($mmyyyy,3); }
	my $csr = $dbh -> prepare ("select fiscal_year from $schema.fiscal_year where fiscal_year >= 2004 order by fiscal_year desc");

	print "<br><font size=+1><b>Fiscal Year:&nbsp;&nbsp;$displayyear</b></font><br><br>\n";
	print "<table width=670 border=0 cellspacing=1 cellpadding=1 align=center>\n";
	print "<tr><td align=center bgcolor=#CCCCCC><b>OCRWM Internal Audits</b></td>\n";
	print "<td width=4%></td>\n<td align=center bgcolor=#CCCCCC><b>External Audits</b></td></tr>\n";
	print "<tr><td valign=top width=24% align=center>\n";	
	&writeApproverTable('I','OCRWM','internal_audit',24,$displayyear,$removeinternal);
	print "</td><td width=4%></td>\n<td valign=top width=24% align=center>\n";
	&writeApproverTable('E','OCRWM','external_audit',28,$displayyear,$removeexternal);
	#print "</td></tr>\n<tr><td colspan=2 align=center>\n";
	print "</td></tr>\n";
	#print "</table>\n";
	#print "</td></tr>\n";
	print "</table><br><br>\n";

	$csr -> execute;
	print "&nbsp;&nbsp;View Schedule for Fiscal Year&nbsp;&nbsp;\n";
	print "<select name=fiscalyear size=1 >\n";
	my $rows = 0;
	while (my @values = $csr -> fetchrow_array){
    		$rows++;
    		my ($fy) = @values;
    		if ($fy == $displayyear ){print "<option selected value=$fy>$fy\n";}
    		else {print "<option value=$fy>$fy\n";}
	}
	$csr -> finish;
	print "</select>\n";
	print "<input type=hidden name=revision>\n";	
	print "<input type=hidden name=org>\n";
	print "<input type=button onClick=submitForm('audit','approve_audit_form',0); value=\"Go\">\n<br><br><br>"; 
}
############################
elsif ($cgiaction eq "approve") {
############################
	my $sqlstring;
	my $sqlstring2;
	my $sqlstring3;
	my $sqlstring4;
	my $fullyear = $NQScgi->param('fiscalyear');
	my $fiscalyear = substr($fullyear,2);
	my $table = $NQScgi->param('table');
   my $org = $NQScgi->param('org');
   my $halfapproved = &checkApproval($dbh,$schema,$fiscalyear,$table);
   my $revision = &get_max_revision($dbh,$schema,$fiscalyear,substr($table,0,1),'OCRWM');
   if ($revision) {$revision = $revision + 1;}
   else {$revision = 1;}
   my $msg;
   my $orgid = 0;
   $dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;

   my $approver = $org eq 'BSC' ? 'approver' : 'approver2';
   my $approval_date = $org eq 'BSC' ? 'approval_date' : 'approval2_date';
   
   if ($table eq 'internal_audit') {
      $orgid = &get_value($dbh,'organizations','id'," abbr = '$org'");

		if (!$halfapproved) {
		   	$sqlstring = "INSERT INTO $schema.audit_revisions
					(fiscal_year, revision, audit_type, $approver, $approval_date, auditing_org)
			values ($fiscalyear, -1, 'I', '$username', trunc(sysdate), 'OCRWM')";
			
			$sqlstring2 = "INSERT INTO $schema.internal_audit
				(id, fiscal_year, revision, audit_seq, audit_type, 
				issuedto_org_id, team_lead_id, team_members, scope,
				forecast_date, cancelled, begin_date, end_date, 
				completion_date, notes, modified, issuedby_org_id)
				select  id, fiscal_year, -1, audit_seq, audit_type, 
				issuedto_org_id, team_lead_id, team_members, scope,
				forecast_date, cancelled, begin_date, end_date, 
				completion_date, notes, 'F', issuedby_org_id
				from $schema.internal_audit 
				where fiscal_year = $fiscalyear and revision = 0 and issuedby_org_id != 3 ";
				
			$sqlstring4 = "INSERT INTO $schema.internal_audit_org_loc
					(id, fiscal_year, revision, internal_audit_id, 
					location_id, organization_id)
					select id, fiscal_year, -1, internal_audit_id, 
					location_id, organization_id
					from $schema.internal_audit_org_loc 
					where fiscal_year = $fiscalyear and revision = 0 and internal_audit_id 
			in (select id from $schema.internal_audit where fiscal_year = $fiscalyear and revision = 0 and issuedby_org_id != 3) ";
		}
		else {
		   	$sqlstring = "UPDATE $schema.audit_revisions
					set revision = $revision, $approver = '$username',
					$approval_date = trunc(sysdate)
					WHERE revision = -1 AND fiscal_year = $fiscalyear 
					AND audit_type = 'I'";		
			
			$sqlstring2 = "UPDATE $schema.internal_audit
					set revision = $revision WHERE revision = -1 
					AND fiscal_year = $fiscalyear ";
					
			$sqlstring4 = "UPDATE $schema.internal_audit_org_loc
					set revision = $revision WHERE revision = -1 
					AND fiscal_year = $fiscalyear "; 
		}
		
	}
	elsif ($table eq 'external_audit') {
		if (!$halfapproved) {
			$sqlstring = "INSERT INTO $schema.audit_revisions
				(fiscal_year, revision, audit_type, $approver, $approval_date, auditing_org)
				values ($fiscalyear, -1, 'E', '$username', trunc(sysdate), 'OCRWM')";

			$sqlstring2 = "INSERT INTO $schema.external_audit
				(id, fiscal_year, revision, audit_seq, audit_type,
				qualified_supplier_id, issuedto_org_id, team_lead_id, team_members, scope,
				forecast_date, cancelled, begin_date, end_date, 
				completion_date, notes, issuedby_org_id)
				select  id, fiscal_year, -1, audit_seq, audit_type, 
				qualified_supplier_id, issuedto_org_id, team_lead_id, team_members, scope,
				forecast_date, cancelled, begin_date, end_date, 
				completion_date, notes, issuedby_org_id
				from $schema.external_audit 
				where fiscal_year = $fiscalyear and revision = 0";
			
			$sqlstring4 = "INSERT INTO $schema.external_audit_locations
				(id, fiscal_year, revision, external_audit_id, location_id)
				select id, fiscal_year, -1, external_audit_id, location_id
				from $schema.external_audit_locations 
				where fiscal_year = $fiscalyear and revision = 0";
		}
		else {
		   	$sqlstring = "UPDATE $schema.audit_revisions
					set revision = $revision, $approver = '$username',
					$approval_date = trunc(sysdate)
					WHERE revision = -1 AND fiscal_year = $fiscalyear 
					AND audit_type = 'E'";		
			
			$sqlstring2 = "UPDATE $schema.external_audit
					set revision = $revision WHERE revision = -1 
					AND fiscal_year = $fiscalyear ";
					
			$sqlstring4 = "UPDATE $schema.external_audit_locations
					set revision = $revision WHERE revision = -1 
					AND fiscal_year = $fiscalyear "; 		
		}
	}
	$sqlstring3 = "update $schema. " . $table . " set modified='F' where fiscal_year = $fiscalyear and revision = 0";
	if ($table eq 'internal_audit') {
		$sqlstring3 .= " and issuedby_org_id = $orgid ";
	}
	eval {
	
		my $csr = $dbh -> prepare ($sqlstring);
		$csr->execute;
   	$csr->finish;
   	my $disableString = ($table eq 'internal_audit') ? "alter table $schema.internal_audit_org_loc disable constraint internal_audit_fk" : "alter table $schema.external_audit_locations disable constraint external_audit_fk";
	my $csr5 = $dbh->do($disableString);
   	my $csr2 = $dbh->prepare($sqlstring2);
		$csr2->execute;	
   	$csr2 -> finish;

   	my $csr3 = $dbh->do($sqlstring3);

		my $csr4 = $dbh->prepare($sqlstring4);
		$csr4->execute;		
   	$csr4 -> finish;
   	my $enableString = ($table eq 'internal_audit') ? "alter table $schema.internal_audit_org_loc enable constraint internal_audit_fk" : "alter table $schema.external_audit_locations enable constraint external_audit_fk";
	my $csr6 = $dbh->do($enableString); 			
   	my $email = get_approver_email($dbh,$userid);

   	if ($halfapproved && $table eq 'internal_audit') {
   	   my $reportorg;
   		if ($org eq 'BSC') {$reportorg = 'BSCQA';}
   		else {$reportorg = $org;}
   		#&MailInternalSchedule($fullyear,'OCRWM',$schema,$dbh,$email, "TRUE");
   		print "<input type=hidden name=removeinternal value=1>\n";
   	}
   	elsif ($halfapproved && $table eq 'external_audit') {
   		#&MailExternalSchedule($fullyear,$schema,$dbh,$email, "TRUE");
   		print "<input type=hidden name=removeexternal value=1>\n";
   	}  
   };
   if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error approving $table $org audit schedule  for fy $fiscalyear. $@");
		$msg = "Error approving $table $org audit schedule - Schedule was not approved.";
	}
	else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username approved $table $org audit schedule for fy $fiscalyear ");
		$msg = "The schedule has been approved.\\n\\nA report has been mailed\\nto your current email address. ";
   }
	print "<input type=hidden name=fiscalyear value=$fullyear>\n";
	print "<input type=hidden name=revision>\n";	
	print "<script language=\"JavaScript\" type=\"text/javascript\">\n";
	print "<!--\n";
	print " 	submitForm('audit','approve_audit_form',0);\n";
	print "//-->\n";
	print "</script>\n";
	
}
############################
elsif ($cgiaction eq "insert_new_audit") {
############################
	my $supplierid = $NQScgi->param("QualifiedSupplier");
	my $leadid = $NQScgi->param("Lead");
	my $issuedtoid = $NQScgi->param("issuedTo");
	my $issuedbyid = $NQScgi->param("issuedBy");
	my $forecast = $NQScgi->param("forecast");
	my $begin = $NQScgi->param("Begindate");
	my $end = $NQScgi->param("Enddate");
	my $completed = $NQScgi->param("Completiondate");
	my $team = $NQScgi->param("Team");
	$team  =~ s/'/''/g;
	my $scope = $NQScgi->param("Scope");
	$scope  =~ s/'/''/g;
	my $notes = $NQScgi->param("Notes");
	$notes  =~ s/'/''/g;
	my $product = $NQScgi->param("product");
	$product  =~ s/'/''/g;
	
	my $type = $NQScgi->param("auditType");
	my $fullyear = $NQScgi->param("fy");
	my $fy = substr($fullyear,2);
	my $org1 = defined($NQScgi->param("org1")) ? $NQScgi->param("org1") : 0;
	my $org2 = defined($NQScgi->param("org2")) ? $NQScgi->param("org2") : 0;
	my $org3 = defined($NQScgi->param("org3")) ? $NQScgi->param("org3") : 0;
	my $org4 = defined($NQScgi->param("org4")) ? $NQScgi->param("org4") : 0;
	my $org5 = defined($NQScgi->param("org5")) ? $NQScgi->param("org5") : 0;
	my $org6 = defined($NQScgi->param("org6")) ? $NQScgi->param("org6") : 0;
	my $org7 = defined($NQScgi->param("org7")) ? $NQScgi->param("org7") : 0;
	my $loc1 = defined($NQScgi->param("loc1")) ? $NQScgi->param("loc1") : 0;
	my $loc2 = defined($NQScgi->param("loc2")) ? $NQScgi->param("loc2") : 0;
	my $loc3 = defined($NQScgi->param("loc3")) ? $NQScgi->param("loc3") : 0;
	my $loc4 = defined($NQScgi->param("loc4")) ? $NQScgi->param("loc4") : 0;
	my $loc5 = defined($NQScgi->param("loc5")) ? $NQScgi->param("loc5") : 0;
	my $loc6 = defined($NQScgi->param("loc6")) ? $NQScgi->param("loc6") : 0;
	my $loc7 = defined($NQScgi->param("loc7")) ? $NQScgi->param("loc7") : 0;
   my $sqlstring;
   my $sqlstring2;
   my $csr;
   my $csr2;
   my $csr3;
   my $field_name;
   my $field_name2;
   my $field_val;
   my $insertstring;
   my $i;
   my $org;
   my $loc;
   my $msg;
   my @nextid;
   my $lead;
   my $leadvalue;
   
   $dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	
   if ($forecast ne 'mm/yyyy') {
   	$forecast = substr($forecast,0,3) . '01/' . substr($forecast,3);
   	$forecast = "to_date('$forecast','MM/DD/YYYY'),";
   	$field_name2 = 'forecast_date,';
   }
   else {$forecast = '' ; $field_name2 = ''; }
   $sqlstring = "select $schema.audit_" . $fy . "_seq.nextval from dual";

	if ($begin ne 'mm/dd/yyyy') {$begin = "to_date('$begin','MM/DD/YYYY')";}
   else {$begin = 'NULL' ; }
   
   if ($end ne 'mm/dd/yyyy') {$end = "to_date('$end','MM/DD/YYYY')";}
   else {$end = 'NULL' ; }
   
   if ($completed ne 'mm/dd/yyyy') {$completed = "to_date('$completed','MM/DD/YYYY')";}
   else {$completed = 'NULL' ; }

   eval {
   	$csr = $dbh->prepare($sqlstring);
   	$csr->execute;
   	@nextid=$csr->fetchrow_array;
		$csr->finish;

     	if ($table eq 'external') {
   		$field_name = 'qualified_supplier_id, product, ';
   		$field_val = $supplierid . ", '$product' ,";
   	}
   	else {
   		$field_name = '';
   		$field_val = '';
   	}
  
      if ($leadid) {$lead = ",team_lead_id "; $leadvalue = "$leadid, ";}
      else {$lead = " "; $leadvalue = " ";}
   
   	$sqlstring2 = "insert into $schema.$table". "_audit (id, fiscal_year, revision, ";
   	$sqlstring2 .= "audit_seq, audit_type, $field_name issuedto_org_id, issuedby_org_id $lead , ";
   	$sqlstring2 .= "begin_date, end_date, completion_date, team_members, scope, ";
   	$sqlstring2 .= "$field_name2 notes, modified) ";
   	$sqlstring2 .= "values ($nextid[0], $fy, 0, 0, '$type', $field_val ";
   	$sqlstring2 .= "$issuedtoid, $issuedbyid, $leadvalue $begin,$end,$completed,'$team','$scope' ,$forecast '$notes', 'F') ";
print "\n<br>$sqlstring2<br>\n";   
   	$csr2 = $dbh->do($sqlstring2);

		for ($i=1;$i<8;$i++) {
			if ($i == 1) {$org = $org1; $loc = $loc1;}
			if ($i == 2) {$org = $org2; $loc = $loc2;}
			if ($i == 3) {$org = $org3; $loc = $loc3;}
			if ($i == 4) {$org = $org4; $loc = $loc4;}
			if ($i == 5) {$org = $org5; $loc = $loc5;}
			if ($i == 6) {$org = $org6; $loc = $loc6;}
			if ($i == 7) {$org = $org7; $loc = $loc7;}
	
	   	if (($org) || ($loc)) {
	   		if ($org == 0) {$org = 'NULL';}
				if ($loc == 0) {$loc = 'NULL';}
			
				if ($table eq 'external') {
					$insertstring = "insert into $schema.external_audit_locations (id, ";
					$insertstring .= "fiscal_year, revision, external_audit_id, location_id) ";
					$insertstring .= "values ($i,$fy,0,$nextid[0],$loc)";
				}
				else {
					$insertstring = "insert into $schema.internal_audit_org_loc (id, internal_audit_id, ";
					$insertstring .= "fiscal_year, revision, organization_id, location_id) ";
					$insertstring .= "values ($i,$nextid[0],$fy,0,$org,$loc)";
				}
				$csr3 = $dbh->do($insertstring);
			}
   	}
   };
   if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$sqlstring2 $username Error adding $table audit $nextid[0] for fy $fy. $@");
		$msg = "Error adding audit - Audit was not added.";
	}
	else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username added $table audit $nextid[0] for fy $fy");
		$msg = "Audit added successfully";
   }
   print "<input type=hidden name=fy value=$fy>\n";
   print <<homepage2;
		<script language="JavaScript" type="text/javascript">
		<!--
			alert ('$msg');
			parent.workspace.location="$NQSCGIDir/home.pl?userid=$userid&username=$username&schema=$schema&target=workspace";
		//-->
		</script>
homepage2
}
############################
elsif ($cgiaction eq "update_audit") {
############################
	my $supplierid = $NQScgi->param("QualifiedSupplier");
	my $leadid = $NQScgi->param("Lead");
	my $issuedtoid = $NQScgi->param("issuedTo");
	my $issuedbyid = $NQScgi->param("issuedBy");
	my $team = $NQScgi->param("Team");
	$team  =~ s/'/''/g;
	my $scope = $NQScgi->param("Scope");
	$scope  =~ s/'/''/g;
	my $notes = $NQScgi->param("Notes");
	$notes  =~ s/'/''/g;
	my $product = $NQScgi->param("product");
	$product  =~ s/'/''/g;
	my $type = $NQScgi->param("auditType");
	my $forecast = defined($NQScgi->param("forecast")) ? $NQScgi->param("forecast") : 'mm/yyyy';
	#print STDERR "\n~~ forecast date: $forecast ~~ \n"; 
	my $begin = $NQScgi->param("Begindate");
	my $end = $NQScgi->param("Enddate");
	my $completed = $NQScgi->param("Completiondate");
	my $fullyear = $NQScgi->param("fy");
	my $fy = substr($fullyear,2);
	my $id = $NQScgi->param("sid");
	my $org1 = defined($NQScgi->param("org1")) ? $NQScgi->param("org1") : 0;
	my $org2 = defined($NQScgi->param("org2")) ? $NQScgi->param("org2") : 0;
	my $org3 = defined($NQScgi->param("org3")) ? $NQScgi->param("org3") : 0;
	my $org4 = defined($NQScgi->param("org4")) ? $NQScgi->param("org4") : 0;
	my $org5 = defined($NQScgi->param("org5")) ? $NQScgi->param("org5") : 0;
	my $org6 = defined($NQScgi->param("org6")) ? $NQScgi->param("org6") : 0;
	my $org7 = defined($NQScgi->param("org7")) ? $NQScgi->param("org7") : 0;
	my $loc1 = defined($NQScgi->param("loc1")) ? $NQScgi->param("loc1") : 0;
	my $loc2 = defined($NQScgi->param("loc2")) ? $NQScgi->param("loc2") : 0;
	my $loc3 = defined($NQScgi->param("loc3")) ? $NQScgi->param("loc3") : 0;
	my $loc4 = defined($NQScgi->param("loc4")) ? $NQScgi->param("loc4") : 0;
	my $loc5 = defined($NQScgi->param("loc5")) ? $NQScgi->param("loc5") : 0;
	my $loc6 = defined($NQScgi->param("loc6")) ? $NQScgi->param("loc6") : 0;
	my $loc7 = defined($NQScgi->param("loc7")) ? $NQScgi->param("loc7") : 0;
   my $sqlstring;
   my $sqlstring2;
   my $csr;
   my $csr2;
   my $csr3;
   my $csr4;
	my $supplier;
	my $productstring;
   my $insertstring;
   my $i;
   my $org;
   my $loc;
   my $tablename;
   my $field;
   my $lead;
   my $issuedtoorg;
   my $issuedbyorg;
   my $msg;
   
   $dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	
	if ($seq eq '') {$seq = 0;}

   if ($table eq 'external') {
   	$supplier = ",qualified_supplier_id = $supplierid ";
   	$productstring = ",product = '$product' ";
   	$tablename = 'external_audit_locations';
   	$field = 'external_audit_id';
   }
   else {
   	$supplier = '';
   	$productstring = '';
   	$tablename = 'internal_audit_org_loc';
   	$field = 'internal_audit_id';
   }
   
   if ($forecast ne 'mm/yyyy') {
		$forecast = substr($forecast,0,3) . '01/' . substr($forecast,3);
		$forecast = ",forecast_date = to_date('$forecast','MM/DD/YYYY')";
	}
   else {$forecast = ",forecast_date = NULL "; }
   
   if ($begin ne 'mm/dd/yyyy') {$begin = ",begin_date = to_date('$begin','MM/DD/YYYY')";}
   else {$begin = ",begin_date = NULL ";}
   
   if ($end ne 'mm/dd/yyyy') {$end = ",end_date = to_date('$end','MM/DD/YYYY')";}
   else {$end = ",end_date = NULL ";}
   
   if ($completed ne 'mm/dd/yyyy') {$completed = ",completion_date = to_date('$completed','MM/DD/YYYY')";}
   else {$completed = ",completion_date = NULL ";}
   	
   if ($leadid) {$lead = ",team_lead_id = $leadid ";}
   else {$lead = ",team_lead_id = '' ";}

	if ($issuedtoid) {$issuedtoorg = ",issuedto_org_id = $issuedtoid ";}
   else {$issuedtoorg = '';}
   
   if ($issuedbyid && $table eq 'internal') {$issuedbyorg = ",issuedby_org_id = $issuedbyid ";}
   else {$issuedbyorg = '';}
   
   $sqlstring2 = "update $schema.$table". "_audit  ";
   $sqlstring2 .= "set team_members = '$team' $lead $issuedtoorg $issuedbyorg ";
   $sqlstring2 .= ",scope = '$scope', notes = '$notes', audit_type = '$type', audit_seq = $seq, modified = 'Y' ";
   $sqlstring2 .= " $forecast  $supplier $productstring $begin $end $completed ";
   $sqlstring2 .= "where fiscal_year = $fy and revision = 0 and id = $id ";
 # print STDERR "\n~~ $sqlstring2 ~~ \n"; 
   eval {
   	$csr2 = $dbh->do($sqlstring2);
   	$csr3 = $dbh->do("delete from $schema.$tablename where fiscal_year = $fy and revision = 0 and $field = $id");
		for ($i=1;$i<8;$i++) {
			if ($i == 1) {$org = $org1; $loc = $loc1;}
			if ($i == 2) {$org = $org2; $loc = $loc2;}
			if ($i == 3) {$org = $org3; $loc = $loc3;}
			if ($i == 4) {$org = $org4; $loc = $loc4;}
			if ($i == 5) {$org = $org5; $loc = $loc5;}
			if ($i == 6) {$org = $org6; $loc = $loc6;}
			if ($i == 7) {$org = $org7; $loc = $loc7;}
		
			if (($org) || ($loc)) {
				if ($org == 0) {$org = 'NULL';}
				if ($loc == 0) {$loc = 'NULL';}

				if ($table eq 'external') {
					$insertstring = "insert into $schema.external_audit_locations (id, ";
					$insertstring .= "fiscal_year, revision, external_audit_id, location_id) ";
					$insertstring .= "values ($i,$fy,0,$id,$loc)";
				}
				else {
					$insertstring = "insert into $schema.internal_audit_org_loc (id, internal_audit_id, ";
					$insertstring .= "fiscal_year, revision, organization_id, location_id) ";
					$insertstring .= "values ($i,$id,$fy,0,$org,$loc)";
				}
				print "\n$insertstring\n";
				$csr4 = $dbh->do($insertstring);
			}
   	}
   };
   if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error updating $table audit $id for fy $fy. $@");
		$msg = "Error updating audit - Audit was not updated.";
	}
	else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username updated $table audit $id for fy $fy");
		$msg = "Audit updated successfully";
   }
   print "<input type=hidden name=fy value=$fy>\n";
	print "<input type=hidden name=audit_type>\n";
   print <<browse;
   $cgiaction = "browse_audits";
		<script language="JavaScript" type="text/javascript">
		<!--
			 alert ('$msg');
			 // parent.workspace.location="$NQSCGIDir/audit.pl?userid=$userid&username=$username&schema=$schema&target=workspace&cgiaction=browse_audits&fy=$fullyear";
			 browse($fullyear,'$table');
		//-->
		</script>
browse
}
############################
elsif ($cgiaction eq "insertreport") {
############################
	my $table = $NQScgi->param("table");
	my $id = $NQScgi->param("sched");
	my $year = $NQScgi->param("yr");
	my $addreportlink = $NQScgi->param("addreportlink");
   my $sqlstring;
   my $csr;
   my $msg;
   
   $dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	
   $sqlstring = "update ". $table . "_audit set reportlink = '$addreportlink' where fiscal_year = $year ";
   $sqlstring .= " and revision = 0 and id = $id ";
   print STDERR "\n-- $sqlstring -- \n";
   eval {
   	$csr = $dbh->do($sqlstring);
   };
   if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error inserting report link for $table audit $id for fy $fy. $@");
		$msg = "Error inserting report link.";
	}
	else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username inserted report log number for $table audit $id for fy $fy");
		$msg = "Report Log Number inserted successfully.";
   }
   print "<input type=hidden name=fy value=$fy>\n";
	print <<browse;
	<script language="JavaScript" type="text/javascript">
	<!--
		 alert ('$msg');
		 parent.workspace.location="$NQSCGIDir/home.pl?userid=$userid&username=$username&schema=$schema&target=workspace";
	//-->
	</script>
browse
}

############################
elsif ($cgiaction eq "delete_audit") {
############################
	my $table = $NQScgi->param("table");
	my $id = $NQScgi->param("sid");
	my $fullyear = $NQScgi->param("fy");
	my $fy = substr($fullyear,2);
   my $sqlstring;
   my $csr;
   my $msg;
   
   $dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	
	eval {
   	if ($table eq 'internal') {
			$csr = $dbh->do("delete from $schema.internal_audit_org_loc where revision = 0 and internal_audit_id = $id and fiscal_year = $fy");
   	}	
   	elsif ($table eq 'external') {
			$csr = $dbh->do("delete from $schema.external_audit_locations where revision = 0 and external_audit_id = $id and fiscal_year = $fy");
   	}	
		my $csr2 = $dbh->do("delete from $schema" . "." . $table . "_audit where fiscal_year = $fy and revision = 0 and id = $id");
	};
 	if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error deleting $table audit $id for fy $fy. $@");
		$msg = "Error deleting audit - Audit was not deleted.";
	}
	else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username deleted $table audit $id for fy $fy");
		$msg = "Audit deleted successfully";
   }
	print "<input type=hidden name=fy value=$fy>\n";
	print <<browse;
	<script language="JavaScript" type="text/javascript">
	<!--
		alert ('$msg');
		parent.workspace.location="$NQSCGIDir/home.pl?userid=$userid&username=$username&schema=$schema&target=workspace";
	//-->
	</script>
browse
}
############################
elsif ($cgiaction eq "cancel_audit") {
############################
	my $table = $NQScgi->param("table");
	my $id = $NQScgi->param("sid");
	my $fullyear = $NQScgi->param("fy");
	my $fy = substr($fullyear,2);
   my $sqlstring;
   my $csr;
   my $msg;
   
   $dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	
   $sqlstring = "update ". $table . "_audit set cancelled = 'Y' where fiscal_year = $fy ";
   $sqlstring .= " and revision = 0 and id = $id ";
   eval {
   	$csr = $dbh->do($sqlstring);
   };
   if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error cancelling $table audit $id for fy $fy. $@");
		$msg = "Error cancelling audit - Audit was not cancelled.";
	}
	else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username cancelled $table audit $id for fy $fy");
		$msg = "Audit cancelled successfully";
   }
   print "<input type=hidden name=fy value=$fy>\n";
	print <<browse;
	<script language="JavaScript" type="text/javascript">
	<!--
		 alert ('$msg');
		 parent.workspace.location="$NQSCGIDir/home.pl?userid=$userid&username=$username&schema=$schema&target=workspace";
	//-->
	</script>
browse
}
print<<queryformbottom;
</form>
</center>
</Body>
</HTML>
queryformbottom
&NQS_disconnect($dbh);
exit();

