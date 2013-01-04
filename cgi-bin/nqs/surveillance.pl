#!/usr/local/bin/newperl -w
#
# $Source: /data/dev/rcs/nqs/perl/RCS/surveillance.pl,v $
#
# $Revision: 1.9 $
#
# $Date: 2002/09/10 22:57:56 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: surveillance.pl,v $
# Revision 1.9  2002/09/10 22:57:56  starkeyj
# modified title to say 'Surveillance Schedule' - bug fix
#
# Revision 1.8  2002/09/10 01:01:51  starkeyj
# modified format of surveillance ID and added an 'issued by' filed so BSC
# and OQA can generate separate surveillance schedules
#
# Revision 1.7  2002/05/17 19:20:46  starkeyj
# modified all surveillance schedule displays to reflect the new format for surveillance numbers
#
# Revision 1.6  2002/02/13 23:15:14  starkeyj
# modified the label 'Issued To' to be 'Issued By' in the view_surveillance and browse_surveillance functions (SCR 25)
#
# Revision 1.5  2002/01/16 21:07:31  starkeyj
# added functionality to enter a supplier as well as an organization for a surveillance
#
# Revision 1.4  2001/11/27 15:30:59  starkeyj
# aesthetic changes - colors, font sizes, centering, etc.
#
# Revision 1.3  2001/11/02 22:46:54  starkeyj
# added form validation and error and activity logs
#
# Revision 1.2  2001/10/22 17:59:32  starkeyj
# no change, user error with RCS
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

use DBI;
use DBD::Oracle qw(:ora_types);
use strict;
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
my $cgiaction = defined($NQScgi->param("cgiaction")) ? $NQScgi->param("cgiaction") : "Browse_Surveillances";


my $dbh = &NQS_connect();
$dbh->{LongReadLen} = 1000001;
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
my %userprivhash = &get_user_privs($dbh,$userid);
print <<END_of_Multiline_Text;
Content-type: text/html

<HTML>
<HEAD>
<script src=$NQSJavaScriptPath/utilities.js></script>
<Title>Surveillance Schedule</Title>
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
	doSetTextImageLabel('Surveillance');
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
function checkLength(val,e) {
	var maxlen;
	if (e.name == "status") {maxlen = 399;}
	else if (e.name == "scope") {maxlen = 999;}	
	var len = val.length;
	var diff = len - maxlen;
	if (diff > 0) {
		alert ("The text you have entered is " + diff + " characters too long.");
		e.focus();
	}
}
function checkDate(val,e) {
	var valid = 1;
	if (val != '') {valid =  validateDate2(val);}
	if (!valid) {e.focus();}
}
//-->
</script>
<script language="JavaScript1.1">
<!--
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
	document.$form.sid.value = id;
	submitForm('surveillance', command, id);
}
function submitActive (id, fy) { 
	document.$form.fy.value = fy;
	document.$form.id.value = id;
	submitForm('surveillance', 'active_surveillance', 0);
}
function submitView (id, fy) {   
	document.$form.fy.value = fy;
	document.$form.id.value = id;
	submitForm('surveillance', 'view_surveillance', 0);
}
function updateSurveillance (script, fy, id) {    
	document.$form.action = '$path' + script + '.pl';
	document.$form.cgiaction.value = 'update_surveillance';
	document.$form.fy.value = fy;
	document.$form.sid.value = id;
   document.$form.target = 'control';
	document.$form.submit();
}
function insertSurveillance (script, fy, id, f) {    
	var msg = "";
   var msg2 = "The following fields are required: \\n";
	if (f.issuedTo.value == 0) {msg += "- Issued To \\n";}
	if (!f.issuedBy[0].checked && !f.issuedBy[1].checked) {msg += "- Issued By \\n";}

	if (msg == "") {
		document.$form.action = '$path' + script + '.pl';
		document.$form.cgiaction.value = 'insert_surveillance';
		document.$form.fy.value = fy;
		document.$form.sid.value = id;
		document.$form.target = 'control';
		document.$form.submit();
	}
   else {
   	msg2 += msg;
   	alert (msg2);
   }
}
function deleteSurveillance (script, fy, id) {    
	document.$form.action = '$path' + script + '.pl';
	document.$form.cgiaction.value = 'delete_surveillance';
	document.$form.fy.value = fy;
	document.$form.sid.value = id;
   document.$form.target = 'control';
	document.$form.submit();
}

function locationWindow() {     
	window.open();
}
//-->
</script>
</HEAD>
<Body background=$NQSImagePath/background.gif text=#000099>
<center>
<form action="$NQSCGIDir/surveillance.pl" method=post name=surveillance>
<input type=hidden name=username value=$username>
<input type=hidden name=userid value=$userid>
<input type=hidden name=schema value=$schema>
<input type=hidden name=cgiaction value=$cgiaction>
END_of_Multiline_Text

############################
sub select_org_locs {
############################
	my ($sid,$fy) = @_;
	my @locresults = get_locations2($dbh,'surveillance',$sid,$fy);
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
    
	if (!$sid) {$sid = 0;}
	#if (!$fy) {$fy = 50;}
	my $orgstring = "select id, abbr from $schema.organizations  ";
	$orgstring .= "where surveillance_active = 'T' or id in (select organization_id ";
	$orgstring .= "from surveillance_org_loc where fiscal_year = $fy and surveillance_id = $sid) ";
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
		if (@$array_ref[3] ne 'USA' && @$array_ref[3] ne '' ) {$loc .=  @$array_ref[3];}
		$lochash{$loc} = @$array_ref[4] ;
	}
	print "<tr><td><table border=1 width=500 cellpadding=3 cellspacing=0 rules=none bordercolor=gray>\n";
	print "<tr><td align=left width=50%><b>Organizations</b></td><td align=left width=50%><b>Locations</b></td></tr>\n";
	if ($sid) {
		my $sqlstring = "select id, organization_id, location_id ";
		$sqlstring .= "from $schema.surveillance_org_loc ";
		$sqlstring .= "where fiscal_year = $fy and surveillance_id = $sid order by id ";

		my $csr = $dbh->prepare($sqlstring);
		$csr->execute;
	 	while (my @values = $csr->fetchrow_array) {
	 		$orgselect = "org" . $i ;
	 		$locselect = "loc" . $i ;
    		print "<tr><td width=100% align=left><select name=$orgselect size=1>\n";
    		print "<option value=0>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
			print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
			print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
			print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
    		foreach $key (keys %orghash) {
				if ($key == $values[1]){print "<option selected value=\"$key\">$orghash{$key}\n";}
	      	else {print "<option value=\"$key\">$orghash{$key}\n";}
    		}
    		print "</select></td>\n<td width=100%><select name=$locselect size=1>\n";
    		print "<option value=0>\n";
    		foreach $key (keys %lochash) {
				if ($lochash{$key} == $values[2]){print "<option selected value=\"$lochash{$key}\">$key\n";}
				else {print "<option value=\"$lochash{$key}\">$key\n";}
			}
    		print "</select></td></tr>\n";
    		$i++;
		}
	}
	for (my $j=$i;$j<4;$j++) {
		$orgselect = "org" . $j ;
		$locselect = "loc" . $j ;
		print "<tr><td width=100% align=left><select name=$orgselect size=1>\n";
		print "<option value=0>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
		print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
		print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
		print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
		foreach $key (keys %orghash) {print "<option value=\"$key\">$orghash{$key}\n";}
		print "</select></td>\n<td width=100%><select name=$locselect size=1>\n";
		print "<option value=0>\n";
		foreach $key (keys %lochash) {print "<option value=\"$lochash{$key}\">$key\n";}
		print "</select></td></tr>\n";
	}
	print "</table></td></tr>\n";
}
############################
sub select_supplier_locs {
############################
	my ($sid,$fy) = @_;
	my @locresults = get_locations2($dbh,'surveillance',$sid,$fy);
	tie my %supplierhash, "Tie::IxHash";
	tie my %lochash, "Tie::IxHash";
	tie my %selectedhash, "Tie::IxHash";
	my $key;
	my $loc;
	my $supplierselect;
	my $locselect;
	my $i=1;
	my $lookup;
	my $value;
	my @values;
    
	if (!$sid) {$sid = 0;}
	#if (!$fy) {$fy = 50;}
	my $supplierstring = "select id, company_name from $schema.qualified_supplier  ";
	$supplierstring .= "where surveillance_active = 'T' or id in (select supplier_id ";
	$supplierstring .= "from surveillance_org_loc where fiscal_year = $fy and surveillance_id = $sid) ";
	$supplierstring .= "order by company_name";

	my $csr = $dbh->prepare($supplierstring);
	$csr->execute;
	while (@values = $csr->fetchrow_array) {
		($lookup, $value) = @values;
		$supplierhash{$lookup} = $value;
	}  
	$csr->finish;

	foreach my $array_ref (@locresults) { 
		$loc = "";
		if (@$array_ref[0]) {$loc .= @$array_ref[0] . ', ';}
		if (@$array_ref[1]) {$loc .= @$array_ref[1] . ', ';}
		if (@$array_ref[2]) {$loc .= @$array_ref[2];}
		if (@$array_ref[3] ne 'USA' && @$array_ref[3] ne '' ) {$loc .=  @$array_ref[3];}
		$lochash{$loc} = @$array_ref[4] ;
	}
	print "<tr><td><table border=1 width=500 cellpadding=3 cellspacing=0 rules=none bordercolor=gray>\n";
	print "<tr><td align=left width=50%><b>Supplier</b></td><td align=left width=50%><b>Locations</b></td></tr>\n";
	if ($sid) {
		my $sqlstring = "select id, supplier_id, location_id ";
		$sqlstring .= "from $schema.surveillance_org_loc ";
		$sqlstring .= "where fiscal_year = $fy and surveillance_id = $sid order by id ";

		my $csr = $dbh->prepare($sqlstring);
		$csr->execute;

		while (my @values = $csr->fetchrow_array) {
	 		$locselect = "loc" . $i ;
	 		if ($i == 1) {
    			print "<tr><td width=100% align=left><select name=supplier size=1>\n";
    			print "<option value=0>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
				print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
				print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
				print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
    			foreach $key (keys %supplierhash) {
					if ($key == $values[1]){print "<option selected value=\"$key\">$supplierhash{$key}\n";}
	      		else {print "<option value=\"$key\">$supplierhash{$key}\n";}
    			}
    			print "</select></td>\n";
    		} 
    		else {print "<tr><td width=100% align=left>&nbsp;</td>\n";}
    		print "<td width=100%><select name=$locselect size=1>\n";
    		print "<option value=0>\n";
    		foreach $key (keys %lochash) {
				if ($lochash{$key} == $values[2]){print "<option selected value=\"$lochash{$key}\">$key\n";}
				else {print "<option value=\"$lochash{$key}\">$key\n";}
			}
    		print "</select></td></tr>\n";
    		$i++;
		}
	}
	if ($i == 1) {
		$locselect = "loc" . $i ;
		print "<tr><td width=100% align=left><select name=supplier size=1>\n";
		print "<option value=0>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
		print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
		print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
		print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
		foreach $key (keys %supplierhash) {print "<option value=\"$key\">$supplierhash{$key}\n";}
		print "</select></td>\n<td width=100%><select name=$locselect size=1>\n";
		print "<option value=0>\n";
		foreach $key (keys %lochash) {print "<option value=\"$lochash{$key}\">$key\n";}
		print "</select></td></tr>\n";
		$i++;
	}
	for (my $j=$i;$j<4;$j++) {
		$locselect = "loc" . $j ;
		print "<tr><td width=100% align=left>&nbsp;</td>\n";
		print "<td width=100%><select name=$locselect size=1>\n";
		print "<option value=0>\n";
		foreach $key (keys %lochash) {print "<option value=\"$lochash{$key}\">$key\n";}
		print "</select></td></tr>\n";
	}
	print "</table></td></tr>\n";
}
############################
sub selectIssuedto {
############################
	my ($issuedto) = @_;
	tie my %issuedTohash,  "Tie::IxHash";
	if (!($issuedto)) {$issuedto = 0;}
	%issuedTohash = get_lookup_values($dbh, "organizations", 'id', 'abbr', " issued_to_list = 'T' or id = $issuedto ");

	print "<select name=issuedTo size=1>\n";
	print "<option value=0>\n";
	foreach my $keys (keys %issuedTohash) {
		if ($keys eq $issuedto ){print "<option selected value=\"$keys\">$issuedTohash{$keys}\n";}
		else {print "<option value=\"$keys\">$issuedTohash{$keys}\n";}	
	}
}
############################
sub selectIssuedby {
############################
	my ($issuedby,$sid) = @_;
	my $disabled = $sid  ? ' disabled ' : '';
	tie my %issuedByhash,  "Tie::IxHash";
	if (!($issuedby)) {$issuedby = 0;}
	%issuedByhash = get_lookup_values($dbh, "organizations", 'id', 'abbr', " abbr in ('OQA','BSC') or id = $issuedby ");

	foreach my $orgid (keys %issuedByhash) {
		if ($orgid == $issuedby ){print "<input type=radio name=issuedBy checked $disabled value=\"$orgid\"><b>$issuedByhash{$orgid}</b>\n";}
		else {print "<input type=radio name=issuedBy $disabled value=\"$orgid\"><b>$issuedByhash{$orgid}</b>\n";}	
	}
}
############################
sub select_deficiencies {
############################
	my ($id,$fy) = @_;
	my $i=1;
	my $defnum;

	if ($id) {
		my $sqlstring = "select deficiency from $schema.surveillance_deficiencies ";
		$sqlstring .= "where fiscal_year = $fy and surveillance_id = $id order by id ";

		my $csr = $dbh->prepare($sqlstring);
		$csr->execute;
		while (my @values = $csr->fetchrow_array) {
			$defnum = "deficiency" . $i ;
			print "<input type=text name=$defnum size=80 maxlength=200 value='$values[0]'><br>\n";
			$i++;
		}
	}
	for (my $j=$i;$j<4;$j++) {
		$defnum = "deficiency" . $j ;
		print "<input type=text name=$defnum size=80 maxlength=200><br>\n";
	}
}
############################
sub selectTeamLead {
############################
	my ($lead) = @_;
	tie my %leadhash,  "Tie::IxHash";
	my $value;
	my $lookup;
	my @values;

	if (!$lead) {$lead = 0;}
	my $leadstring = "select u.id, firstname || ' ' || lastname from users u, user_privilege up, ";
	$leadstring .= "privilege p where  (p.privilege like '%Surveillance Lead' and p.id = up.privilege ";
	$leadstring .= "and u.id = up.userid) or u.id = $lead order by lastname, firstname ";

	my $csr = $dbh->prepare($leadstring);
	$csr->execute;
	while (@values = $csr->fetchrow_array) {
		($lookup, $value) = @values;
		$leadhash{$lookup} = $value;
	}
   $csr->finish;
    
	print "<select name=Lead title=\"TeamLeads\" size=1>\n"; 	
	print "<option selected value=0>TBD\n";
	foreach my $keys (keys %leadhash) {
		if ($keys eq $lead ){print "<option selected value=$keys>$leadhash{$keys}\n";}
		else {print "<option value=$keys>$leadhash{$keys}\n";}
	}
	print "</select>\n";
}
############################
sub writeLocations {
############################
	my ($id,$fy) = @_;
	tie my %selectedhash, "Tie::IxHash";
	my $select_table = "surveillance_org_loc";
	%selectedhash = get_lookup_values($dbh, $select_table . ", " .  $schema . ".locations", "initcap(city) || ', ' || state || initcap(province)", "locations.id", "surveillance_id = $id and fiscal_year = $fy and location_id = locations.id");
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
sub writeOrganizations {
############################
	my ($id,$fy) = @_;
	my %selectedhash;
	my $i = 1;
	%selectedhash = get_lookup_values($dbh, "surveillance_org_loc, " .  $schema . ".organizations", "abbr", "organizations.id", "surveillance_id = $id and fiscal_year = $fy and organization_id = organizations.id");
	foreach my $keys ( keys %selectedhash) {
		print "$keys";
		if ($i < (keys(%selectedhash))) {
			print ", ";
			$i++;
		}
	} 
}
############################
sub writeDeficiencies {
############################
	my ($id,$fy) = @_;
	my %selectedhash;
	my $i = 1;
	%selectedhash = get_lookup_values($dbh, "surveillance_deficiencies","deficiency", "id", "surveillance_id = $id and fiscal_year = $fy");
	foreach my $keys ( keys %selectedhash) {
		print "$keys";
		if ($i < (keys(%selectedhash))) {
			print "<br>";
			$i++;
		}
	} 
}
############################
sub writeSupplier {
############################
	my ($id,$fy) = @_;
	my %selectedhash;
	my $i = 1;
	%selectedhash = get_lookup_values($dbh, "surveillance_org_loc, " .  $schema . ".qualified_supplier", "company_name", "qualified_supplier.id", "surveillance_id = $id and fiscal_year = $fy and supplier_id = qualified_supplier.id");
	foreach my $keys ( keys %selectedhash) {
		print "$keys";
		if ($i < (keys(%selectedhash))) {
			print ", ";
			$i++;
		}
	} 
}
############################
sub selectFY {
############################
	my ($selected_yr) = @_;
	if ($selected_yr < 50) {$selected_yr += 2000;}
	else {$selected_yr += 1900;}
	my $def_yr;
	my $current_year = $dbh -> prepare ("select to_char(sysdate,'MM/YYYY') from dual");
	$current_year -> execute;
	my $mmyyyy = $current_year -> fetchrow_array;
	$current_year -> finish;
	my $mm = substr($mmyyyy,0,2);
	if ($mm > 9) {$def_yr = substr($mmyyyy,3) + 1;}
	else { $def_yr = substr($mmyyyy,3); }
	#if (!defined($selected_yr)) {$selected_yr = $def_yr;}
	if ($selected_yr == 50) {$selected_yr = substr($def_yr,3);}

	my $csr = $dbh -> prepare ("select fiscal_year from $schema.fiscal_year order by fiscal_year desc");
	$csr -> execute;
	print "&nbsp;<b>Fiscal Year:&nbsp;&nbsp;</b>\n";
	print "<select name=fy size=1 >\n";
	while (my @values = $csr -> fetchrow_array){
		my ($fy) = @values;
		if ($fy == $selected_yr ){print "<option selected value=$fy>$fy\n";}
		else {print "<option value=$fy>$fy\n";}
	}
	$csr -> finish;
	print "</select>\n";
}
############################
if ($cgiaction eq "browse_surveillances") {
############################
	my $selection = $NQScgi->param('surveillance_selection');
	my $fullyear = $NQScgi->param('fy3');
	my $fy = substr($fullyear,2);
	my $csr;
	my @values;
	my $title;
	my $col_display;
	my $display_num;
	my $display_yr;
	my $orgid = 0;
	my ($contact,$yr,$num,$elements,$lead,$scope,$members,$cancelled,$approved,$intext);
	my ($leadid,$completed,$start,$end,$issuedto,$issuedby,$seq,$surveillanceID,$orgname);
	my $issuedbystr = '';
	if ($selection eq 'OQA') {$issuedbystr = ' and issuedby_org_id = 28 ';}
	if ($selection eq 'BSC') {$issuedbystr = ' and issuedby_org_id = 1 ';}
	
	print "<br><table width=650 border=1 cellspacing=1 cellpadding=1>\n";
	my $sqlquery = "SELECT initial_contact, fiscal_year, id, elements, team_members, team_lead_id, ";
	$sqlquery .= "scope, to_char(approval_date,'MM/DD/YYYY'), cancelled, to_char(begin_date,'MM/DD/YYYY'), ";
	$sqlquery .= "to_char(end_date,'MM/DD/YYYY'), to_char(completion_date,'MM/DD/YYYY'), issuedto_org_id, issuedby_org_id, ";
	$sqlquery .= "surveillance_seq, int_ext FROM $schema.surveillance ";
	$sqlquery .= "where fiscal_year = $fy $issuedbystr order by issuedby_org_id, id";
	$csr = $dbh->prepare($sqlquery);
	$csr->execute;

	while (@values = $csr->fetchrow_array) {
		$contact = defined($values[0]) ? $values[0] : '';
		$yr = defined($values[1]) ? $values[1] : '';
		$num = defined($values[2]) ? $values[2] : '';
		$elements = defined($values[3]) ? $values[3] : '';
		$members = defined($values[4]) ? $values[4] : '';
		$leadid = defined($values[5]) ? $values[5] : 0;
		$scope = defined($values[6]) ? $values[6] : '&nbsp;';
		$approved = defined($values[7]) ? $values[7] : '';
		$cancelled = defined($values[8]) ? $values[8] : '';
		$start = defined($values[9]) ? $values[9] : '';
		$end = defined($values[10]) ? $values[10] : '';
		$completed = defined($values[11]) ? $values[11] : '';
		$issuedto = defined($values[12]) ? $values[12] : 0;
		$issuedby = defined($values[13]) ? $values[13] : 0;
		$seq = defined($values[14]) ? $values[14] : 0;
		$intext = defined($values[15]) ? $values[15] : 0;

		if ($issuedby != $orgid) {
			$orgname = lookup_single_value($dbh,$schema,'organizations','abbr'," $issuedby ");
			print "<tr  bgcolor=#B0C4DE><td colspan=4 align=center><b><font color=black>$orgname Surveillances</font></b></td><tr>\n";
			print "<tr  bgcolor=aliceblue><td nowrap><font color=black><b>Surveillance #</b></font></td>\n";
			print "<td><font color=black><b>&nbsp;Team Lead</b></font></td><td align=center><font color=black><b>Scope</b></font></td><td align=center><font color=black><b>Start Date</b></font></td></tr>\n";
			$orgid = $issuedby;
		}
		$surveillanceID = getSurvId($dbh,$issuedby,$issuedto,$intext,$fullyear,$seq);
		$display_yr = lpadzero($yr,2);
		if ($leadid != 0) {$lead = lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname",$leadid);}
		else {$lead = 'TBD';}
		my $issuedto_display = lookup_single_value($dbh,$schema,'organizations','abbr', $issuedto );
		if (!($issuedto_display)) {$issuedto_display = "###";}
		if ($cancelled) {$col_display = "Cancelled";}
		elsif ($start) {$col_display = substr($start,0,2) . ' / ' . substr($start,3,2) . ' / ' . substr($start,8);}
		else {$col_display = '';}
		print "<tr bgcolor=white><td nowrap><a href=javascript:submitView($num,$yr);>\n";
		if (($yr eq 2 && $num < 4) || ($yr > 50) || ($yr < 2)) {#this is odd, 
			$display_num = lpadzero($seq,3); #but the format changed after the third record of fy 2
			print "<font size=-1>$surveillanceID</font></a>\n";
		} 
		else {
			$display_num = lpadzero($seq,2);
			print "<font size=-1>$surveillanceID</font></a>\n";
		}
		print "</td><td nowrap><font size=-1>&nbsp; $lead &nbsp;</font></td><td><font size=-1>$scope</font></td><td nowrap align=center><font size=-1>$col_display &nbsp;</font></td></tr>\n";
	}
	$csr->finish;

	print "</table><br><br>\n";
	print "<input type=hidden name=id value=$num>\n";
	print "<input type=hidden name=yr value=$yr>\n";
	print "<input type=hidden name=fy value=$yr>\n";
	print "<input type=hidden name=fullyear value=$fullyear>\n";
}
############################
if ($cgiaction eq "active_surveillance") {
############################
	my $sid = defined($NQScgi->param("id")) ? $NQScgi->param("id") : 0 ;
	my $fy = defined($NQScgi->param("fy")) ? $NQScgi->param("fy") : 50 ;
	$fy = substr($fy,3) if (!$sid);
	my $fullyear;
	$fullyear = $fy + 2000 if ($fy < 50);
   $fullyear = $fy + 1900 if ($fy > 50);
	my $int_ext = defined($NQScgi->param("int_ext")) ? $NQScgi->param("int_ext") : 'active' ;
	my $csr;
	my $csr2;
	my $csr3;
	my @values;
	my @details;
	my @summary;
	my $display_num;
	my $display_yr = lpadzero($fy,2);
	my ($contact,$yr,$num,$lead,$scope,$members,$cancelled,$approved,$completed);
	my ($start,$end,$status,$elements,$issuedto,$leadid,$issuedby,$seq,$surveillanceID);
	my %issuedByhash = get_lookup_values($dbh, "organizations", 'id', 'abbr', " abbr in ('OQA','BSC') ");

	my $sqlquery = "SELECT initial_contact, fiscal_year, id, elements, team_members, team_lead_id, ";
	$sqlquery .= "scope, to_char(approval_date,'MM/DD/YYYY'), cancelled, to_char(begin_date,'MM/DD/YYYY'), ";
	$sqlquery .= "to_char(end_date,'MM/DD/YYYY'), to_char(completion_date,'MM/DD/YYYY'), ";
	$sqlquery .= "status, issuedto_org_id, int_ext, issuedby_org_id, surveillance_seq ";
	$sqlquery .= "FROM $schema.surveillance ";
	$sqlquery .= "where fiscal_year = $fy and id = $sid";
	$csr = $dbh->prepare($sqlquery);
	$csr->execute;
	@values = $csr->fetchrow_array;
  
  	$contact = defined($values[0]) ? $values[0] : '';
  	$yr = defined($values[1]) ? $values[1] : '';
  	$num = defined($values[2]) ? $values[2] : '';
  	$elements = defined($values[3]) ? $values[3] : '';
  	$members = defined($values[4]) ? $values[4] : '';
  	$leadid = defined($values[5]) ? $values[5] : 0;
  	$scope = defined($values[6]) ? $values[6] : '';
  	$approved = defined($values[7]) ? $values[7] : '';
  	$cancelled = defined($values[8]) ? $values[8] : '';
  	$start = defined($values[9]) ? $values[9] : '';
  	$end = defined($values[10]) ? $values[10] : '';
	$completed = defined($values[11]) ? $values[11] : '';
	$status = defined($values[12]) ? $values[12] : '';
   $issuedto = defined($values[13]) ? $values[13] : 0; 
   if ($int_ext eq 'active') {$int_ext = defined($values[14]) ? $values[14] : 'I';}
   $issuedby = defined($values[15]) ? $values[15] : 0; 
   $seq = defined($values[16]) ? $values[16] : 0; 
   print "<br><table width=650 border=0 cellspacing=1 cellpadding=1 align=center>\n";
   my $issuedto_display = lookup_single_value($dbh,$schema,'organizations','abbr', $issuedto );
 	print "<tr><td><table width=100% border=0 cellspacing=1 cellpadding=1>\n";
 	print "<tr><td align=left bgcolor=#CCEEFF nowrap><b><font color=black>Surveillance #:&nbsp;\n";
 	$surveillanceID = getSurvId($dbh,$issuedby,$issuedto,$int_ext,$fullyear,$seq);
 	if ($sid) {
 		#if (($yr eq 2 && $num < 4) || ($yr > 50) || ($yr < 2)) {#this is odd, 
		#	$display_num = lpadzero($seq,3); #but the format changed after the third record of fy 2
 		#	print "$issuedto_display-SR-$display_yr-$display_num </font></b></td>\n";
 		#}
 		#else {
		#	$display_num = lpadzero($seq,2);
		print "$surveillanceID ";
 		#}
 	}
 	print "</font></b></td>\n";
	print "<td align=left width=30%>&nbsp;";
	
	if ($sid) {
		print "<b>&nbsp;Fiscal Year:&nbsp;&nbsp;$fullyear</b>\n";
		print "<input type=hidden name=fy value=$fullyear>\n";
	}
 	else {selectFY($fy);}
 	print "</td>\n";
 	print "<td nowrap><b>Initial Contact:</b>&nbsp;<input type=text name=contact size=18 maxlength=50 value=\"$contact\">\n";
 	print "</td></tr>\n";
 	print "<tr><td align=left><b>Issued By:&nbsp;</b>";
 	&selectIssuedby($issuedby,$sid);
 	print "</td><td align=center nowrap><b>&nbsp;&nbsp;Issued To:&nbsp;</b>";
 	&selectIssuedto($issuedto);
 	print "</td><td colspan=2 align=right><b>Team Lead:&nbsp;</b>";
 	&selectTeamLead($leadid);
 	print "</td></tr>\n";
 	print "<tr><td align=left><b>Start:&nbsp;";
	print "<input type=text name=start size=14 maxlength=12 onBlur=checkDate(value,this) value=$start ></td>\n";
	print "<td align=left><b>&nbsp;&nbsp;End:</b>&nbsp;\n";
	print "<input type=text name=end size=14 maxlength=12 onBlur=checkDate(value,this) value=$end></td>\n";
	print "<td align=right><b>Completed:</b>&nbsp;";
	print "<input type=text name=completed size=14 maxlength=12  onBlur=checkDate(value,this) value=$completed></td></tr>\n";
	print "</td></tr>\n";
 	print "</table></td></tr>\n";
 	print "<tr><td align=center><table border=0 align=center>\n";
 	if ($int_ext eq 'I') {&select_org_locs($sid,$fy);}
  	else {&select_supplier_locs($sid,$fy);}
  	print "</table></td></tr>\n";
   print "<tr><td valign=top colspan=3>\n";
   print "<b>Surveillance Scope Detail:<br></b>\n";
   print "<textarea name=scope rows=3 cols=80 onBlur=checkLength(value,this);>$scope</textarea>\n";
   print "</td></tr>\n";
   print "</table>\n"; 
   print "<table border=0 cellspacing=1 cellpadding=1 width=650>\n"; 
   print "<tr><td align=left><b>Elements:</b></td><td>\n";
   print "<input type=text name=elements size=50 maxlength=50 value=\"$elements\"></td></tr>\n";
   print "<tr><td align=left valign=top><b>Deficiencies:</b></td><td>\n";
   &select_deficiencies($sid,$fy);
   print "</td></tr>\n";
	print "<tr><td valign=top>\n";
	print "<b>Status:</b></td><td>\n";
	print "<textarea name=status rows=3 cols=60  onBlur=checkLength(value,this);>$status</textarea>\n";
	print "</td></tr>\n";
	print "</table><br>\n";
	print "<input type=hidden name=fy value=$fy>\n";
	print "<input type=hidden name=int_ext value=$int_ext>\n";
	if ($sid) {
		print "<input type=button  onClick=updateSurveillance('surveillance',$fy,$sid); value=\" Save \">";
		print "&nbsp;&nbsp;<input type=button  onClick=deleteSurveillance('surveillance',$fy,$sid); value=\"Delete\" >\n";
	}
	else {
		print "<input type=button  onClick=insertSurveillance('surveillance',$fy,$sid,document.$form); value=\" Save \">";
	}
	print "<input type=hidden name=sid value=$sid>\n";
	print "<br><br>\n"
}
############################
if ($cgiaction eq "view_surveillance") {
############################
	my $sid = $NQScgi->param('id');
	my $fy = $NQScgi->param('fy');
	my $csr;
	my $csr2;
	my $csr3;
	my @values;
	my @details;
	my @summary;
	my $display_num;
	my $display_yr = lpadzero($fy,2);
	my ($contact,$yr,$num,$req_id,$lead,$scope,$members,$cancelled,$approved,$completed,$seq,$surveillanceID);
	my ($start,$end,$status,$elements,$issuedto,$leadid,$int_ext,$issuedby,$issuedto_display,$issuedby_display);
	
	print "<input type=hidden name=fy value=$fy>\n";    
	print "<input type=hidden name=id value=$sid>\n";
  
  	my $sqlquery = "SELECT initial_contact, fiscal_year, id, request_id, team_members, team_lead_id, ";
  	$sqlquery .= "scope, to_char(approval_date,'MM/DD/YYYY'), cancelled, to_char(begin_date,'MM/DD/YYYY'), ";
  	$sqlquery .= "to_char(end_date,'MM/DD/YYYY'), to_char(completion_date,'MM/DD/YYYY'), ";
  	$sqlquery .= "status, elements, issuedto_org_id, int_ext, issuedby_org_id, surveillance_seq ";
  	$sqlquery .= "FROM $schema.surveillance ";
  	$sqlquery .= "where fiscal_year = $fy and id = $sid";
  	
  	$csr = $dbh->prepare($sqlquery);
  	$csr->execute;
   @values = $csr->fetchrow_array;
  
  	$contact = defined($values[0]) ? $values[0] : '';
  	$yr = defined($values[1]) ? $values[1] : '';
  	$num = defined($values[2]) ? $values[2] : '';
  	$req_id = defined($values[3]) ? $values[3] : '';
  	$members = defined($values[4]) ? $values[4] : '';
  	$leadid = defined($values[5]) ? $values[5] : '';
  	$scope = defined($values[6]) ? $values[6] : '';
  	$approved = defined($values[7]) ? $values[7] : '';
  	$cancelled = defined($values[8]) ? $values[8] : '';
  	$start = defined($values[9]) ? $values[9] : '';
  	$end = defined($values[10]) ? $values[10] : '';
	$completed = defined($values[11]) ? $values[11] : '';
	$status = defined($values[12]) ? $values[12] : '';
	$elements = defined($values[13]) ? $values[13] : '';
	$issuedto = defined($values[14]) ? $values[14] : 0;
	$int_ext = defined($values[15]) ? $values[15] : 'I';
	$issuedby = defined($values[16]) ? $values[16] : 0;
	$seq = defined($values[17]) ? $values[17] : 0;
     
	if ($issuedto == 0) {$issuedto_display = 'TBD';}
	else {$issuedto_display = lookup_single_value($dbh,$schema,'organizations','abbr', $issuedto );}
	if ($issuedby == 0) {$issuedby_display = 'TBD';}
	else {$issuedby_display = lookup_single_value($dbh,$schema,'organizations','abbr', $issuedby );}
	my $fullyear = $yr > 50 ? $yr + 1900 : $yr + 2000;
	my $display_label = $int_ext eq 'I' ? "Organizations" : "Supplier";
	$lead = lookup_single_value($dbh,$schema,'users',"firstname || ' ' || lastname",$leadid);
	$surveillanceID = getSurvId($dbh,$issuedby,$issuedto,$int_ext,$fullyear,$seq);
  	print "<br><table width=650 border=0 cellspacing=4 cellpadding=1>\n";
  	print "<tr><td colspan=3 align=center><b><font color=black>\n";
	print "$surveillanceID </font></b></td><td></tr>\n";
 	print "<tr height=10></tr>\n";
 	print "<tr><td><b>Issued By: &nbsp;<font color=black>$issuedby_display</font></b></td>\n";
 	print "<td><b>Issued To: &nbsp;<font color=black>$issuedto_display</font></b></td>\n";
 	print "<td><b>Fiscal Year:&nbsp;<font color=black>$fullyear</font></b></td></tr>\n";
 	print "<tr><td valign=top><b>Start:&nbsp;<font color=black>$start</font></b></td>\n";
	print "<td valign=top><b>End:&nbsp;<font color=black>$end</font></b></td>\n";
   print "<td valign=top><b>Completed:&nbsp;<font color=black>$completed</font></b></td></tr>\n";
	print "<tr><td><b>Initial Contact:&nbsp;<font color=black>$contact</font></b></td>\n";
	print "<td colspan=2><b>Team Lead:&nbsp;<font color=black>$lead</font></b></td></tr>\n";
	print "<tr><td valign=top colspan=3><b>$display_label:&nbsp;&nbsp;<font color=black>";
 	if ($int_ext eq 'I') {&writeOrganizations($sid,$fy);}
  	else {&writeSupplier($sid,$fy);}
  	print "</font></b></td></tr>\n";
  	print "<tr><td valign=top colspan=3><b>Locations:&nbsp;&nbsp;<font color=black>";
  	&writeLocations($sid,$fy);
 	print "</font></b></td></tr>\n";
 	print "<tr><td valign=top colspan=3><b>Surveillance Scope Detail:&nbsp;&nbsp;<font color=black>$scope</font></b>\n";
   print "</td></tr>\n";
   print "<tr><td valign=top colspan=3><b>Elements:&nbsp;<font color=black>$elements<font></b></td></tr>\n";
   print "<tr><td valign=top colspan=3><b>Deficiencies:&nbsp;<font color=black>\n";
   &writeDeficiencies($sid,$fy);
   print "</font></b></td></tr>\n";
	print "<tr><td valign=top colspan=3>\n";
	print "<b>Status:&nbsp;&nbsp;<font color=black>$status</font></b>\n";
	print "</td></tr>\n";
	if ($userprivhash{'Developer'} == 1 || ($userprivhash{'OQA Surveillance Administration'} == 1 && $issuedby_display eq 'OQA') || ($userprivhash{'BSC Surveillance Administration'} == 1 && $issuedby_display eq 'BSC')
	 || (($userprivhash{'OQA Surveillance Lead'} == 1 || $userprivhash{'BSC Surveillance Lead'} == 1) && $leadid == $userid)) {
			print "<tr><td colspan=3 align=center><a href=javascript:submitActive($sid,$fy);>Edit</a></td></tr>\n";
	}
	print "</table><br><br><br>\n";
}
############################
if ($cgiaction eq "insert_surveillance") {
############################
	my $leadid = $NQScgi->param("Lead");
	my $issuedtoid = $NQScgi->param("issuedTo");
	my $issuedbyid = $NQScgi->param("issuedBy");
	my $team = $NQScgi->param("Team");
	$team =~ s/'/''/g;
	my $scope = $NQScgi->param("scope");
	$scope  =~ s/'/''/g;
	my $notes = $NQScgi->param("Status");
	$notes =~ s/'/''/g;
	my $fullyear = $NQScgi->param("fy");
	my $fy = substr($fullyear,2);
	my $contact = $NQScgi->param("contact");
	$contact =~ s/'/''/g;
	my $elements = $NQScgi->param("elements");
	my $start = $NQScgi->param("start");
	my $end = $NQScgi->param("end");
	my $completed = $NQScgi->param("completed");
	my $int_ext = $NQScgi->param("int_ext");
	my $supplier = defined($NQScgi->param("supplier")) ? $NQScgi->param("supplier") : 0;
	my $org1 = defined($NQScgi->param("org1")) ? $NQScgi->param("org1") : 0;
	my $org2 = defined($NQScgi->param("org2")) ? $NQScgi->param("org2") : 0;
	my $org3 = defined($NQScgi->param("org3")) ? $NQScgi->param("org3") : 0;
	my $loc1 = defined($NQScgi->param("loc1")) ? $NQScgi->param("loc1") : 0;
	my $loc2 = defined($NQScgi->param("loc2")) ? $NQScgi->param("loc2") : 0;
	my $loc3 = defined($NQScgi->param("loc3")) ? $NQScgi->param("loc3") : 0;
	my $deficiency1 = defined($NQScgi->param("deficiency1")) ? $NQScgi->param("deficiency1") : 0;
	my $deficiency2 = defined($NQScgi->param("deficiency2")) ? $NQScgi->param("deficiency2") : 0;
	my $deficiency3 = defined($NQScgi->param("deficiency3")) ? $NQScgi->param("deficiency3") : 0;
	my $sqlstring;
	my $sqlstring2;
	my $csr;
	my $csr2;
	my $csr3;
	my $csr4;
	my $insertstring;
	my $deficiencystring;
	my $i;
	my $org;
	my $loc;
	my $deficiency;
	my $start_field;
	my $start_data;
	my $end_field;
	my $end_data;
	my $completed_field;
	my $completed_data;
	my $msg;
	my @nextid;
	my $seq;
	my @nextseq;

	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	
   if ($completed ne '') {
		$completed_data = ", to_date('$completed','MM/DD/YYYY')";
		$completed_field = ", completion_date ";
	}
   else {
   	$completed_data = " ";
		$completed_field = " "; 
   }
	if ($start ne '') {
		$start_data = ", to_date('$start','MM/DD/YYYY')";
		$start_field = ", begin_date ";
	}
   else {
   	$start_data = " ";
		$start_field = " "; 
   }
   if ($end ne '') {
		$end_data = ", to_date('$end','MM/DD/YYYY')";
		$end_field = ", end_date ";
	}
	else {
		$end_data = " ";
		$end_field = " "; 
   }
   
		
   eval {
		$sqlstring = "select $schema.surveillance_" . $fy . "_seq.nextval from dual";
		$csr = $dbh->prepare($sqlstring);
		$csr->execute;
		@nextid=$csr->fetchrow_array;
		$csr->finish;

      my $seqstring = "select max(surveillance_seq) from $schema.surveillance ";
		$seqstring .= " where issuedby_org_id = $issuedbyid and fiscal_year = $fy ";
		
		$csr = $dbh->prepare($seqstring);
		$csr->execute;
		@nextseq=$csr->fetchrow_array;
		$csr->finish;
		
		if (!defined($nextseq[0])) {$seq = 1;}
		else {$seq = $nextseq[0] + 1;}
		
		$sqlstring2 = "insert into $schema.surveillance (id, fiscal_year, initial_contact, int_ext, surveillance_seq,  ";
		$sqlstring2 .= "issuedto_org_id, team_lead_id, approver_id, approval_date, issuedby_org_id, ";
		$sqlstring2 .= "team_members, scope, elements $end_field $start_field $completed_field) ";
		$sqlstring2 .= "values ($nextid[0], $fy, '$contact', '$int_ext', $seq, $issuedtoid, ";
		$sqlstring2 .= " $leadid, $userid, SYSDATE, $issuedbyid, '$team','$scope','$elements' $end_data $start_data $completed_data) ";
	
		$csr2 = $dbh->do($sqlstring2);

		if ($int_ext eq 'I') {
			for ($i=1;$i<4;$i++) {
				if ($i == 1) {$org = $org1; $loc = $loc1;}
				if ($i == 2) {$org = $org2; $loc = $loc2;}
				if ($i == 3) {$org = $org3; $loc = $loc3;}
				if (($org) || ($loc)) {
					if ($org == 0) {$org = 'NULL';}
					if ($loc == 0) {$loc = 'NULL';}
					$insertstring = "insert into $schema.surveillance_org_loc (id, surveillance_id, ";
					$insertstring .= "fiscal_year, organization_id, location_id) ";
					$insertstring .= "values ($i,$nextid[0],$fy,$org,$loc)";

					$csr3 = $dbh->do($insertstring);
				}
			}
		}
		else {
			for ($i=1;$i<4;$i++) {
				if ($i == 1) {$loc = $loc1;}
				if ($i == 2) {$loc = $loc2;}
				if ($i == 3) {$loc = $loc3;}
				if ($i == 1) {
					if ($loc == 0) {$loc = 'NULL';}
					$insertstring = "insert into $schema.surveillance_org_loc (id, surveillance_id, ";
					$insertstring .= "fiscal_year, supplier_id, location_id) ";
					$insertstring .= "values ($i,$nextid[0],$fy,$supplier,$loc)";
					
					$csr3 = $dbh->do($insertstring);
				}
				if (($i > 1) && ($loc)) {
					$insertstring = "insert into $schema.surveillance_org_loc (id, surveillance_id, ";
					$insertstring .= "fiscal_year, location_id) ";
					$insertstring .= "values ($i,$nextid[0],$fy,$loc)";

					$csr3 = $dbh->do($insertstring);
				}
			}
		}
		for ($i=1;$i<4;$i++) {
			if ($i == 1) {$deficiency = $deficiency1; }
			if ($i == 2) {$deficiency = $deficiency2; }
			if ($i == 3) {$deficiency = $deficiency3; }

			if ($deficiency) {
				$insertstring = "insert into $schema.surveillance_deficiencies (id, surveillance_id, ";
				$insertstring .= "fiscal_year,  deficiency, issuedto_org_id) ";
				$insertstring .= "values ($i,$nextid[0],$fy,'$deficiency',1)";
				my $csr6 = $dbh->do($insertstring);
			}
		}
	};
	if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error inserting surveillance $nextid[0] for fy $fy.  $@");
		$msg = "Error inserting surveillance - Surveillance was not inserted.";
	}
	else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username added surveillance $nextid[0] for fy $fy");
		$msg = "Surveillance inserted successfully";
   }
	print "<input type=hidden name=fy3 value=$fullyear>";  
	print <<browse2;
	<script language="JavaScript" type="text/javascript">
	<!--
		 alert ('$msg');
		 submitForm('surveillance','browse_surveillances',0);
	//-->
	</script>
browse2
}
############################
if ($cgiaction eq "update_surveillance") {
############################
	my $leadid = $NQScgi->param("Lead");
	my $issuedtoid = $NQScgi->param("issuedTo");
	my $issuedbyid = $NQScgi->param("issuedBy");
	my $team = $NQScgi->param("Team");
	$team =~ s/'/''/g;
	my $scope = $NQScgi->param("scope");
	$scope =~ s/'/''/g;
	my $fullyear = $NQScgi->param("fy");
	my $fy = substr($fullyear,2);
	my $id = $NQScgi->param("sid");
	my $contact = $NQScgi->param("contact");
	$contact =~ s/'/''/g;
	my $elements = $NQScgi->param("elements");
	my $start = $NQScgi->param("start");
	my $end = $NQScgi->param("end");
	my $completed = $NQScgi->param("completed");
	my $int_ext = $NQScgi->param("int_ext");
	my $status = $NQScgi->param("status");
	$status =~ s/'/''/g;
	my $supplier = defined($NQScgi->param("supplier")) ? $NQScgi->param("supplier") : 0;
	my $org1 = defined($NQScgi->param("org1")) ? $NQScgi->param("org1") : 0;
	my $org2 = defined($NQScgi->param("org2")) ? $NQScgi->param("org2") : 0;
	my $org3 = defined($NQScgi->param("org3")) ? $NQScgi->param("org3") : 0;
	my $loc1 = defined($NQScgi->param("loc1")) ? $NQScgi->param("loc1") : 0;
	my $loc2 = defined($NQScgi->param("loc2")) ? $NQScgi->param("loc2") : 0;
	my $loc3 = defined($NQScgi->param("loc3")) ? $NQScgi->param("loc3") : 0;
	my $deficiency1 = defined($NQScgi->param("deficiency1")) ? $NQScgi->param("deficiency1") : 0;
	my $deficiency2 = defined($NQScgi->param("deficiency2")) ? $NQScgi->param("deficiency2") : 0;
	my $deficiency3 = defined($NQScgi->param("deficiency3")) ? $NQScgi->param("deficiency3") : 0;
	my $sqlstring;
	my $sqlstring2;
	my $csr;
	my $csr2;
	my $csr3;
	my $csr4;
	my $csr5;
	my $csr6;
	my $insertstring;
	my $i;
	my $org;
	my $loc;
	my $deficiency;
	my $msg;
	
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;

	if ($start ne '') {$start = ",begin_date = to_date('$start','MM/DD/YYYY')";}
	else {$start = '' ; }
	if ($end ne '') {$end = ",end_date = to_date('$end','MM/DD/YYYY')";}
	else {$end = '' ; }
	if ($completed ne '') {$completed = ",completion_date = to_date('$completed','MM/DD/YYYY')";}
	else {$completed = '' ; }
   
	$sqlstring2 = "update $schema.surveillance  ";
	$sqlstring2 .= "set team_lead_id =  $leadid, issuedto_org_id = $issuedtoid, team_members = '$team', ";
	$sqlstring2 .= "scope = '$scope', elements = '$elements', status = '$status', initial_contact = '$contact' ";
	$sqlstring2 .= " $start $end $completed ";
	$sqlstring2 .= "where fiscal_year = $fy and id = $id ";

	eval {
		$csr2 = $dbh->do($sqlstring2);
		$csr3 = $dbh->do("delete from $schema.surveillance_org_loc where fiscal_year = $fy and surveillance_id = $id");
		if ($int_ext eq 'I') {
			for ($i=1;$i<4;$i++) {
				if ($i == 1) {$org = $org1; $loc = $loc1;}
				if ($i == 2) {$org = $org2; $loc = $loc2;}
				if ($i == 3) {$org = $org3; $loc = $loc3;}
				if (($org) || ($loc)) {
					if ($org == 0) {$org = 'NULL';}
					if ($loc == 0) {$loc = 'NULL';}

					$insertstring = "insert into $schema.surveillance_org_loc (id, surveillance_id, ";
					$insertstring .= "fiscal_year,  organization_id, location_id) ";
					$insertstring .= "values ($i,$id,$fy,$org,$loc)";
					$csr4 = $dbh->do($insertstring);
				}
			}
		}
		else {
			for ($i=1;$i<4;$i++) {
				if ($i == 1) {$loc = $loc1;}
				if ($i == 2) {$loc = $loc2;}
				if ($i == 3) {$loc = $loc3;}
				if ($i == 1) {
					$insertstring = "insert into $schema.surveillance_org_loc (id, surveillance_id, ";
					$insertstring .= "fiscal_year,  supplier_id, location_id) ";
					$insertstring .= "values ($i,$id,$fy,$supplier,$loc)";
					$csr4 = $dbh->do($insertstring);
				}
				if (($i > 1) && ($loc)) {
					$insertstring = "insert into $schema.surveillance_org_loc (id, surveillance_id, ";
					$insertstring .= "fiscal_year, location_id) ";
					$insertstring .= "values ($i,$id,$fy,$loc)";
					$csr4 = $dbh->do($insertstring);
				}
			}
		}
   	$csr5 = $dbh->do("delete from $schema.surveillance_deficiencies where fiscal_year = $fy and surveillance_id = $id");
		for ($i=1;$i<4;$i++) {
			if ($i == 1) {$deficiency = $deficiency1; }
			if ($i == 2) {$deficiency = $deficiency2; }
			if ($i == 3) {$deficiency = $deficiency3; }
			if ($deficiency) {
				$insertstring = "insert into $schema.surveillance_deficiencies (id, surveillance_id, ";
				$insertstring .= "fiscal_year,  deficiency, issuedto_org_id) ";
				$insertstring .= "values ($i,$id,$fy,'$deficiency',1)";
				$csr6 = $dbh->do($insertstring);
			}
		}
	};
	if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error updating surveillance $id for fy $fy.  $@");
		$msg = "Error updating surveillance - Surveillance was not updated.";
	}
	else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username updated surveillance $id for fy $fy");
		$msg = "Surveillance updated successfully";
   }
	print "<input type=hidden name=fy3 value=$fullyear>";
	      
	print <<browse;
	<script language="JavaScript" type="text/javascript">
	<!--
		 alert ('$msg');
		 submitForm('surveillance','browse_surveillances',0);
	//-->
	</script>
browse
}
############################
if ($cgiaction eq "delete_surveillance") {
############################
	my $fullyear = $NQScgi->param("fy");
	my $fy = substr($fullyear,2);
	my $sid = $NQScgi->param("sid");
	my $msg;
	
	$dbh->{AutoCommit} = 0;
	$dbh->{RaiseError} = 1;
	
	eval {
		my $csr = $dbh->do("delete from $schema.surveillance_org_loc where fiscal_year = $fy and surveillance_id = $sid");
		my $csr2 = $dbh->do("delete from $schema.surveillance_deficiencies where fiscal_year = $fy and surveillance_id = $sid");
		my $csr3 = $dbh->do("delete from $schema.surveillance where fiscal_year = $fy and id = $sid");
	};
	if ($@) {
		$dbh->rollback;
		&log_nqs_error($dbh,$schema,'T',$userid,"$username Error deleting surveillance $sid for fy $fy.  $@");
		$msg = "Error deleting surveillance - Surveillance was not deleted.";
	}
	else {
		$dbh->commit;
		&log_nqs_activity($dbh,$schema,'F',$userid,"$username deleted surveillance $sid for fy $fy");
		$msg = "Surveillance deleted successfully";
   }
	print "<input type=hidden name=fy value=$fy>\n";
	print "<input type=hidden name=fy3 value=$fullyear>"; 
	print <<browse3;
	<script language="JavaScript" type="text/javascript">
	<!--
		 alert ('$msg');
		 submitForm('surveillance','browse_surveillances',0);
	//-->
	</script>
browse3
}
print<<queryformbottom;
</form>
</center>
</Body>
</HTML>
queryformbottom
&NQS_disconnect($dbh);
exit();
