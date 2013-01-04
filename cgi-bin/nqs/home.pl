#!/usr/local/bin/newperl -w
#
# $Source: /usr/local/homes/higashis/www/gov.doe.ocrwm.ydappdev/rcs/qa/perl/RCS/home.pl,v $
#
# $Revision: 1.25 $
#
# $Date: 2007/10/03 16:41:58 $
#
# $Author: dattam $
#
# $Locker: higashis $
#
# $Log: home.pl,v $
# Revision 1.25  2007/10/03 16:41:58  dattam
# sub doAuditSection modified not to show "View OCRWM Internal", "View SNL Internal", "View BSC Internal", View OQA Internal" for Internal Audits
#
# Revision 1.24  2007/09/26 18:01:37  dattam
# Sub doAuditSection modified not to show "View SNL External", "View BSC External", "view OQA External"  choices in the drop down list for Fiscal Year 2008
#
# Revision 1.23  2007/04/12 17:03:17  dattam
# Modified home screen to view SNL Audits and Surveillances.
# Sub do AuditSection, doSurveillanceSection modified to allow users to enter SNL audits and surveillances.
#
# Revision 1.22  2005/10/31 20:11:29  dattam
# Modified home screen to enter and browse asessments of type 'other'
#
# Revision 1.21  2004/10/21 18:44:34  starkeyj
# modified selection drop down to separate BSC and OQA external audits in doAuditSection
#
# Revision 1.20  2004/05/30 15:44:39  starkeyj
# removed link to approve audit schedule
#
# Revision 1.19  2004/04/07 16:02:34  starkeyj
# removed auditID from javascript function submitNewForm
#
# Revision 1.18  2004/04/07 14:56:57  starkeyj
# modified audit section to use new script to view and edit audits and to enter new audits
#
# Revision 1.17  2004/02/19 20:47:27  starkeyj
# added link to enter EM/RW audits and added selection to select box for browse
#
# Revision 1.16  2004/01/26 00:03:01  starkeyj
# added check for user privilege for link to enter condition reports
#
# Revision 1.15  2004/01/25 23:55:49  starkeyj
# added link to enter Condition Reports
#
# Revision 1.14  2004/01/13 13:41:51  starkeyj
# modified surveillance section to use new form for new surveillances and view surveillances
#
# Revision 1.13  2003/10/06 16:17:50  starkeyj
# modified soAuditSection - removed comment to allow access of approval link
#
# Revision 1.12  2003/09/24 19:25:47  starkeyj
# commented out the approval link temporarily so no audits can be approved until the approval
# process is defined for the combined OQA and BSC internal audit schedules
#
# Revision 1.11  2003/09/22 17:50:43  starkeyj
# modified subroutine doAuditSection to add OCRWM as a selection
# to the drop down, changed default year calculation for approval link
#
# Revision 1.10  2002/09/10 00:57:25  starkeyj
# modified privileges so OQA and BSC are separated and removed the 'Update' link - SCR 44
#
# Revision 1.9  2002/01/16 21:05:50  starkeyj
# added choice of internal or external to new surveillance entry
#
# Revision 1.8  2002/01/16 21:01:38  starkeyj
# error using RCS - no change
#
# Revision 1.6  2001/11/27 15:29:29  starkeyj
# aesthetic changes - centering, font sizes, etc.
#
# Revision 1.5  2001/11/05 17:01:46  starkeyj
# removed code calling Sections
#
# Revision 1.4  2001/11/05 16:28:16  starkeyj
# changed path for background image
#
# Revision 1.3  2001/11/02 22:14:53  starkeyj
# cosmetic changes - replaced section titles with text labels
#
# Revision 1.2  2001/10/22 17:12:16  starkeyj
# modified the privilege checked for approving an audit schedule
#
# Revision 1.1  2001/10/19 23:30:33  starkeyj
# Initial revision
#
#
# Revision: $
#
# 
use integer;
use strict;
use NQS_Header qw(:Constants);
use OQA_specific;
use OQA_Widgets qw(:Functions);
use OQA_Utilities_Lib qw(:Functions);

use CGI qw(param);
use Tie::IxHash;
#use Sections;
use DBI;
use DBD::Oracle qw(:ora_types);

$| = 1;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $errorstr = "";

my $NQScgi = new CGI;
my $username = defined($NQScgi->param("username")) ? $NQScgi->param("username") : "GUEST";
my $userid = defined($NQScgi->param("userid")) ? $NQScgi->param("userid") : 0;
my $schema = defined($NQScgi->param("schema")) ? $NQScgi->param("schema") : "None";
my $Server = defined($NQScgi->param("server")) ? $NQScgi->param("server") : $NQSServer;
my $cgiaction = defined($NQScgi->param("cgiaction")) ? $NQScgi->param("cgiaction") : "none";
my $srid;
my $sid;


my $dbh = &NQS_connect();
my %userprivhash = &get_user_privs($dbh,$userid);
my $idstr = "&username=$username&userid=$userid";

#some of these will be removed -they are here temporarily
my ($list,$disclist,$statusid,$siteid,%counts,$command);


###############
sub doAuditSection {
###############
  my $entryBackground = '#ffc0ff';
  my $entryForeground = '#000099';
  eval {
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
	

	 my $csr = $dbh -> prepare ("select fiscal_year from $schema.fiscal_year order by fiscal_year desc");
	 $csr -> execute;
	 print "<tr><td>\n";
	 print "<table cellpadding=4 cellspacing=0 border=0 width=100%><ul>\n";
	 print "<tr><td><b><font color=black size=+1>Audits</font></b></td></tr>\n";
	 if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'SNL Internal Administration'} == 1
	      || $userprivhash{'BSC Internal Administration'} == 1)  {
		print "<tr><td><b><li><a href=\"./audit2.pl?userid=$userid&username=$username&schema=$schema&command=editAudit&table=internal&tag=new&fiscalyear=$def_yr\">Enter</a>" . &nbspaces(2) . "New Internal Audit</b></td></tr>\n";
	 }
	 if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Supplier Administration'} == 1 || $userprivhash{'SNL Supplier Administration'} == 1
	      || $userprivhash{'BSC Supplier Administration'} == 1) {	
		print "<tr><td><b><li><a href=\"./audit2.pl?userid=$userid&username=$username&schema=$schema&command=editAudit&table=external&tag=new&fiscalyear=$def_yr\">Enter</a>" . &nbspaces(2) . "New External Audit</b></td></tr>\n";
	 }
	 if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'SNL Internal Administration'} == 1
	      || $userprivhash{'BSC Internal Administration'} == 1)  {
		print "<tr><td><b><li><a href=\"./audit2.pl?userid=$userid&username=$username&schema=$schema&command=editAudit&table=internal&tag=newem&fiscalyear=$def_yr\">Enter</a>" . &nbspaces(2) . "New EM/RW Audit</b></td></tr>\n";
	 }
	
	# if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Internal Administration'} == 1) {
	# print "<tr><td><b><li><a href=\"./audit2.pl?userid=$userid&username=$username&schema=$schema&command=editAuditOther&table=internal&tag=new&fiscalyear=$def_yr\">Enter</a>" . &nbspaces(2) . "New Other Internal</b></td></tr>\n";
	 #}
	 #if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Supplier Administration'} == 1) {
	 #print "<tr><td><b><li><a href=\"./audit2.pl?userid=$userid&username=$username&schema=$schema&command=editAuditOther&table=external&tag=new&fiscalyear=$def_yr\">Enter</a>" . &nbspaces(2) . "New Other External</b></td></tr>\n";
	 #}
	 
	 print "<tr><td><b><li>View&nbsp;&nbsp;\n";
	 print "<select name=audit_selection size=1>\n";
	 print "<option value='internal'>All Internal\n";
	 if ($def_yr < 2008) {
	       print "<option value='internal_ocrwm'>OCRWM Internal\n";
	       print "<option value='internal_snl'>SNL Internal\n";
	       print "<option value='internal_bsc'>BSC Internal\n";
	       print "<option value='internal_oqa'>OQA Internal\n";
	 }
	 print "<option value='internal_em'>EM/RW\n";
	 print "<option value='external'>All External\n";
	 if ($def_yr < 2008) {
	       print "<option value='external_snl'>SNL External\n";
	       print "<option value='external_bsc'>BSC External\n";
	       print "<option value='external_oqa'>OQA External\n";
	 }
	 print "<option selected value='all'>All\n";
	 if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Internal Administration'} == 1 || $userprivhash{'OQA Supplier Administration'} == 1) {
	 	print "<option value='other'>Other\n";	
	 }
	 print "</select>\n";    
	 print "&nbsp;&nbsp;Audits for Fiscal Year&nbsp;&nbsp;</b>\n";
	 print "<select name=fy size=1 >\n";
	 my $rows = 0;
	 while (my @values = $csr -> fetchrow_array){
	 	$rows++;
	 	my ($fy) = @values;
	 	if ($fy == $def_yr ){
			print "<option selected value=$fy>$fy\n";
		}
		else {
			print "<option value=$fy>$fy\n";
		}
	 }
	 $csr -> finish;
	 print "</select>\n";
	 #print "<input type=button onClick=submitForm('audit','browse_audits',0); value=\"Go\"></td></tr>\n"; 
	 print "<input type=button onClick=submitForm('audit2','browse',0); value=\"Go\"></td></tr>\n"; 
	# print "<tr><td><b><li>Enter Other&nbsp;&nbsp;\n";
	 #print "<select name=int_ext size=1>\n";
	 #print "<option value='I'>Internal\n";
	# print "<option value='E'>External\n";
	# print "</select>&nbsp;Audit&nbsp;&nbsp;\n";
	# print "<input type=hidden name=tag value='new'>\n";
	# print "<input type=button onClick=submitForm('audit2','editAuditOther',0); value=\"Go\"></td></tr>\n"; 
	 print "</ul></table>\n</td></tr>\n<tr><td height=30> </td></tr>\n";	 
  };
}

###############
sub doSurveillanceSection {
###############
	my $entryBackground = '#ffc0ff';
	my $entryForeground = '#000099';
   eval {
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

		 my $csr = $dbh -> prepare ("select fiscal_year from $schema.fiscal_year order by fiscal_year desc");
		 $csr -> execute;
		 print "<tr><td>\n";
		 print "<table cellpadding=4 cellspacing=0 border=0 width=100%><ul>\n"; 
		 print "<tr><td><b><font color=black size=+1>Surveillance</font></b></td></tr>\n";
		
		# print "<tr><td><b><li><a href=\"./request.pl?userid=$userid&username=$username&schema=$schema&cgiaction=request_surveillance&def_yr=$def_yr\">Enter</a>" . &nbspaces(2) . "Surveillance Request</b></td></tr>\n";
		
		 if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1 || $userprivhash{'SNL Surveillance Administration'} == 1
		      || $userprivhash{'BSC Surveillance Administration'} == 1) {	
		   print "<tr><td><b><li>Enter New&nbsp;&nbsp;\n";
	  	   print "<select name=int_ext size=1>\n";
		   print "<option value='I'>Internal\n";
		   print "<option value='E'>External\n";
	      print "</select>&nbsp;Surveillance&nbsp;&nbsp;\n";   
	      print "<input type=button onClick=submitNewForm('surveillance2','editSurveillance',0); value=\"Go\"></td></tr>\n"; 
		 }
		 print "<tr><td><b><li>View&nbsp;&nbsp;\n";
		 print "<select name=surveillance_selection size=1>\n";
		 print "<option value='OQA'>OQA\n";
		 print "<option value='SNL'>LL\n";
		  print "<option value='MQA'>M&O\n";
		 print "<option value='BSC'>BSC\n";
		 print "<option selected value='all'>All\n";
	 	 print "</select>\n";    
		 print "&nbsp;Surveillances for Fiscal Year&nbsp;&nbsp;</b>\n";
		 print "<select name=fiscalyear size=1 >\n";
		 my $rows = 0;
		 while (my @values = $csr -> fetchrow_array){
			$rows++;
			my ($fy) = @values;
			if ($fy == $def_yr ){
				print "<option selected value=$fy>$fy\n";
			}
			else {
				print "<option value=$fy>$fy\n";
			}
		 }
		 $csr -> finish;
		 print "</select>\n";
		 print "<input type=button onClick=submitForm('surveillance2','browse',0); value=\"Go\"></td></tr>\n"; 

		# print "<tr><td><b><li>View Surveillance Requests for Fiscal Year&nbsp;&nbsp;</b>\n";
		#$csr -> execute;
		#print "<select name=fy2 size=1 >\n";
		# my $rows2 = 0;
		#while (my @values = $csr -> fetchrow_array){
		#$rows2++;
		#my ($fy) = @values;
		#if ($fy == $def_yr ){
		#		print "<option selected value=$fy>$fy\n";
		#}
		#	else {
		#		print "<option value=$fy>$fy\n";
		#	}
		 #}
		 #$csr -> finish;
		 #print "</select>\n";
		 #print "<input type=button onClick=submitForm('request','browse_requests',0); value=\"Go\"></td></tr>\n"; 
		 #if ($userprivhash{'Developer'} == 1 || $userprivhash{'OQA Surveillance Administration'} == 1
		 #     || $userprivhash{'BSC Surveillance Administration'} == 1) {	
		 #	print "<tr><td><b><li><a href=javascript:submitForm('conditionReports','createCondition')>Enter</a>" . &nbspaces(2) . "Condition Report</b></td></tr>\n";
		 #}
  };
}

print <<END_of_Multiline_Text;
Content-type: text/html

<script language=javascript><!--

function submitForm (script, command, id) {
//alert(document.$form.audit_selection.value);
    document.$form.cgiaction.value = command;
    document.$form.command.value = command;
 //   document.$form.surveillance.value = id;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'workspace';
    document.$form.submit();
}
function submitFormOther (script, command, id, tag) {

    document.$form.cgiaction.value = command;
    document.$form.command.value = command;
    //document.$form.tag.value = tag;
 //   document.$form.surveillance.value = id;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'workspace';
    document.$form.submit();
}
function submitForm2 (script, command, id) {
    document.$form.cgiaction.value = command;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'control';
    document.$form.submit();
}
function submitNewForm (script, command, id) {
    document.$form.command.value = command;
   // document.$form.fiscalyear.value = 50;
    document.$form.survID.value = id;
    document.$form.action = '$path' + script + '.pl';
    document.$form.target = 'workspace';
    document.$form.submit();
}
function prescreen (id, command) {                          

    submitForm('request', command, id);
}

function approve (id, command) {     
    document.$form.srid.value = id;
    submitForm('request', command, id);
}
function surveillance (id, command) {     
    document.$form.sid.value = id;
    submitForm('surveillance', command, id);
}

//-->
</script>


<HTML>
<HEAD>
<script src=$NQSJavaScriptPath/utilities.js></script>
<Title>Data Deficiency Tracking</Title>
</HEAD>
<script language=javascript type=text/javascript><!--
	doSetTextImageLabel('Home');\n//-->
</script>

<Body background=$NQSImagePath/background.gif text=#000099>
<center>
<form name=home action=$path/$form.pl method=post>
<input type=hidden name=command>
<input type=hidden name=username value=$username>
<input type=hidden name=userid value=$userid>
<input type=hidden name=schema value=$schema>
<input type=hidden name=srid>
<input type=hidden name=sid>
<input type=hidden name=cgiaction>
<input type=hidden name=surveillance>
<input type=hidden name=survID>

END_of_Multiline_Text

print "<table cellpadding=0 cellspacing=0 border=0 align=center>\n";
print "<tr><td height=20 align=center> </td></tr>\n";
&doAuditSection;
&doSurveillanceSection;
print "</table>\n</form>\n</center>\n</font><br><br><br>\n\n";
print "</Body>\n";
print "</HTML>\n";

$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction 
$dbh->{LongReadLen} = 80;


&NQS_disconnect($dbh);
exit();
