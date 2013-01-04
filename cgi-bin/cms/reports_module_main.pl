#!/usr/local/bin/newperl -w
#
# Main page for Commitment Management System
#
# $Source: /data/dev/rcs/cms/perl/RCS/reports_module_main.pl,v $
# $Revision: 1.15 $
# $Date: 2003/01/03 16:55:40 $
# $Author: naydenoa $
# $Locker:  $
# $Log: reports_module_main.pl,v $
# Revision 1.15  2003/01/03 16:55:40  naydenoa
# Added a parameter passed to DOE LM report - CREQ00022
#
# Revision 1.14  2002/10/25 16:45:08  naydenoa
# Updated report headers
# Added link to DOE Licensing Manger report
# Enabled access to DOE Project Manager report as directed by Sheryl Morris
#
# Revision 1.13  2002/07/15 23:04:10  naydenoa
# Updated DOE Senior Manager report alert message.
#
# Revision 1.12  2002/07/15 21:52:58  naydenoa
# Disable DOE Senior Manager report pending data review.
#
# Revision 1.11  2002/07/15 21:26:54  naydenoa
# Check in for DOE Manager report test on development. Report is enabled.
#
# Revision 1.10  2002/04/12 23:43:49  naydenoa
# Checkpoint
# ,
#
# Revision 1.9  2001/12/18 21:21:58  naydenoa
# Added links to new BSC reports
#
# Revision 1.8  2001/03/21 18:46:54  naydenoa
# Changed Standard Report link to point to frames version
#
# Revision 1.7  2000/10/04 19:11:41  atchleyb
# added functions to use historical data
#
# Revision 1.6  2000/09/25 19:58:16  atchleyb
# removed commented out ref to removed report
#
# Revision 1.5  2000/09/23 00:43:33  mccartym
# format changes
#
# Revision 1.4  2000/09/21 21:34:37  atchleyb
# updated title
#
# Revision 1.3  2000/08/31 23:23:52  atchleyb
# check point
#
# Revision 1.2  2000/06/12 23:00:28  zepedaj
# Removed link to Executive Commitment Report
#
# Revision 1.1  2000/05/30 16:15:46  atchleyb
# Initial revision
#

# get all required libraries and modules
use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $oncscgi = new CGI;

# tell the browser that this is an html page using the header method
print $oncscgi->header('text/html');

$SCHEMA = (defined($oncscgi->param("schema"))) ? $oncscgi->param("schema") : $SCHEMA;

my $username = $oncscgi->param('loginusername');
my $usersid = $oncscgi->param('loginusersid');
if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq ""))
  {
  print <<openloginpage;
  <script type="text/javascript">
  <!--
  parent.location='$ONCSCGIDir/login.pl';
  //-->
  </script>
openloginpage
  exit 1;
  }

# output page header
print <<pageheader;
<html>
<head>
<meta name="pragma" content="no-cache">
<meta name="expires" content="0">
<meta http-equiv="expires" content="0">
<meta http-equiv="pragma" content="no-cache">
<title>Reports Module Menu</title>
<script src=$ONCSJavaScriptPath/oncs-utilities.js></script>

<script language="JavaScript" type="text/javascript">
<!--
if (parent == self) {
  location = '$ONCSCGIDir/login.pl';
}
doSetTextImageLabel('Reports');

function submitONCSForm(script, command, id) {
    document.params.cgiaction.value = command;
    document.params.reportname.value = id;
    document.params.loginusersid.value = 0;
    document.params.loginusersname.value = 'guest';
    document.params.action = 'http://intranet.ymp.gov/cgi-bin/oncs/' + script + '.pl';
    document.params.target = 'workspace';
    document.params.submit();
}

function historicalStandardReport() {
    doSetTextImageLabel('Standard Report - Historical Commitments');
    document.location = 'http://intranet.ymp.gov/cgi-bin/oncs/manager_report.pl?loginusername=guest&loginusersid=0';
}

function historicalCustomReport() {
    doSetTextImageLabel('Custom Report - Historical Commitments');
    document.location = 'http://intranet.ymp.gov/cgi-bin/oncs/ad_hoc_reports.pl?loginusername=guest&loginusersid=0';
}

function licensingMgrReport() {
    doSetTextImageLabel('DOE Licensing Manager Report');
    document.location = '$ONCSCGIDir/DOEMgr_report.pl?loginusername=$username&loginusersid=$usersid&schema=$SCHEMA&command=query';
}

//-->
</script>
</head>
pageheader

print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0><center>\n";
print "<table border=0><tr><td>\n";
print "<br><ul>\n";
print "<li><b><a href=\"$ONCSCGIDir/report.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\">Standard Report</a></b></li><br><br>\n";
print "<li><b><a href=\"$ONCSCGIDir/DOE_report.pl\" target=new>DOE Project Manager Report</a></b></li><br><br>\n";
#print "<li><b><a href=\"$ONCSCGIDir/DOEMgr_report.pl\" >DOE Licensing Manager Report</a></b></li><br><br>\n";
print "<li><b><a href=\"javascript:licensingMgrReport()\" >DOE Licensing Manager Report</a></b></li><br><br>\n";
print "<li><b><a href=\"$ONCSCGIDir/BSC_report.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\">BSC Responsible Manager/Supervisor Report</a></b></li><br><br>\n";
print "<li><b><a href=\"$ONCSCGIDir/BSC_summary_report.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\">BSC Senior Manager/Project Manager Summary Report</a></b></li><br><br>\n";
#print "<li><b><a href=\"http://intranet.ymp.gov/cgi-bin/oncs/manager_report.pl?loginusername=guest&loginusersid=0&reportname=managers\" target=workspace>Standard Report - Historical Commitments<br><br></a></b></li>\n";
print "<li><b><a href=\"javascript:historicalStandardReport()\">Standard Report - Historical Commitments<br><br></a></b></li>\n";
print "<li><b><a href=\"$ONCSCGIDir/ad_hoc_reports.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\">Custom Report</a></b></li><br><br>\n";
#print "<li><b><a href=\"http://intranet.ymp.gov/cgi-bin/oncs/ad_hoc_reports.pl?loginusername=guest&loginusersid=0\" target=workspace>Custom Report - Historical Commitments</a></b></li>\n";
print "<li><b><a href=\"javascript:historicalCustomReport()\">Custom Report - Historical Commitments</a></b></li>\n";
#print "<br><br><li><a href=\"$ONCSCGIDir/testdisplay.pl\">Test data transfer</a>\n";
print "</ul>\n";
print "</td></tr></table>\n";

print <<bodyend;
<form name=params method=post>
<input type=hidden name=loginusersid value=$usersid>
<input type=hidden name=loginusername value=$username>
<input type=hidden name=schema value=$SCHEMA>
<input type=hidden name=username value=guest>
<input type=hidden name=password value=guest>
<input type=hidden name=cgiaction value=''>
<input type=hidden name=reportname value=''>
</form>
</center>
</body>
</html>
bodyend
exit();
