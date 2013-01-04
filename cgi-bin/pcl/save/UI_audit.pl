#!/usr/local/bin/perl -w
#
# $Source$
#
# $Revision$
#
# $Date$
#
# $Author$
#
# $Locker$
#
# $Log$
#
#
#

use strict;
use integer;
use SCM_Header qw(:Constants);
use CGI qw(param);
use DB_Utilities_Lib qw(:Functions);
use UI_Widgets qw(:Functions);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

my $scmcgi = new CGI;
my $schema = (defined($scmcgi->param("schema"))) ? $scmcgi->param("schema") : $ENV{'SCHEMA'};
#print STDERR "$schema\n";
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $urllocation;
my $command = (defined ($scmcgi -> param("command"))) ? $scmcgi -> param("command") : "write_request";
my $username = (defined($scmcgi->param("username"))) ? $scmcgi->param("username") : "";
my $password = (defined($scmcgi->param("password"))) ? $scmcgi->param("password") : "";
my $userid = (defined($scmcgi->param("userid"))) ? $scmcgi->param("userid") : "";
my $error = "";
my $origschema = (defined($scmcgi->param("origschema"))) ? $scmcgi->param("origschema") : "SCM"; 


&checkLogin ($username, $userid, $schema);
my $dbh;
my $errorstr = "";

$dbh = &db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;

# tell the browser that this is an html page using the header method
print $scmcgi->header('text/html');

# build page
print <<END_OF_BLOCK;
	<HTML>
	<HEAD>
	<Title>Software Configuration Management</Title>
	</HEAD>
	<script language="JavaScript" type="text/javascript">
	<!--
	function runReport () {
		document.scm_audit.action = 'scm_audit_report.html';
		document.scm_audit.submit();
	}
	//-->
	</script>
	<center>
	<Body text=#000099 background=$SCMImagePath/background.gif>
	<form name=$form method=post target=main action=$path$form.pl>
	<table cellpadding=4 cellspacing=0 border=0 width=88%>
	<tr><td align=center><b>Baseline Audit</b></td></tr>
	<tr><td height=40></td></tr>
	<tr><td align=center><b>Select Baseline Project:&nbsp;&nbsp;
	<select name=project size=1>
	<option value='CMS'>CMS
	<option value='DMS'>DMS
	<option value='EIS'>EIS
	<option value='OPLOG'>OPLOG
	<option value='QA'>QA
	<option value='SCM'>SCM
	<option value='SR'>SR
	</select></td></tr>
	<tr><td align=center><b>Enter date to be audited:</b>
	<input type=text size=2 maxlength=2 name=mm value=04>/
	<input type=text size=2 maxlength=2 name=dd value=23>/
	<input type=text size=4 maxlength=4 name=yyyy value=2002></td></tr>
	<tr><td height=40></td></tr>
	<tr><td align=center><input type=button name=runreport value=Submit onClick=runReport();></td></tr>
	</table>
	</form>
	</body>
	</center>
</HTML>
END_OF_BLOCK
&db_disconnect($dbh);
exit();
