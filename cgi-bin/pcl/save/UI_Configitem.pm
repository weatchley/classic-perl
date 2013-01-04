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
package UI_Configitem;
use integer;
#use strict;
use SCM_Header qw(:Constants);
use UI_Widgets qw(:Functions);
use DB_scm qw(:Functions);
use CGI qw(param);
use Tie::IxHash;
use DBI;
use DBD::Oracle qw(:ora_types);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw (
   &checkinBody &checkoutBody &createItemBody &itemFormHeader &redirect
);
@EXPORT_OK = qw(
   &checkinBody &checkoutBody &createItemBody &itemFormHeader &redirect
);
%EXPORT_TAGS =( Functions => [qw(
   &checkinBody &checkoutBody &createItemBody &itemFormHeader &redirect
)]);

my $scmcgi = new CGI;
######################
sub itemFormHeader {
######################
   my ($userid,$username,$schema,$projectID) = @_;
	my $scmcgi = new CGI;
	#my $schema = (defined($scmcgi->param("schema"))) ? $scmcgi->param("schema") : $ENV{'SCHEMA'};
	#print STDERR "$schema\n";
	$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
	my $path = $1;
	my $form = $2;
	my $urllocation;
	
	my $error = "";

	my $outstring = $scmcgi->header('text/html');
	$outstring .= <<END_OF_BLOCK;
	<HTML>
	<HEAD>
	<Title>Software Configuration Management</Title>
	</HEAD>
	<center>
	<script language=javascript><!--
	function submitForm(script, command) {
		document.$form.command.value = command;
		document.$form.action = '$path' + script + '.pl';
		document.$form.target = 'main';
		document.$form.submit();
	}
	function submitFormCGIResults(script, command) {
		document.$form.command.value = command;
		document.$form.action = '$path' + script + '.pl';
		document.$form.target = 'cgiresults';
		document.$form.submit();
	}
	//-->
	</script>
	<Body text=#000099 background=$SCMImagePath/background.gif>
	<form name=$form method=post target=main action=$path$form.pl>
	<INPUT TYPE=HIDDEN NAME=userid VALUE=$userid>
	<INPUT TYPE=HIDDEN NAME=username VALUE=$username>
	<INPUT TYPE=HIDDEN NAME=schema VALUE=$schema>
	<INPUT TYPE=HIDDEN NAME=command>
	<INPUT TYPE=HIDDEN NAME=projectID VALUE=$projectID>
END_OF_BLOCK
    return($outstring);
}
#################
sub checkinBody {
#################
	my ($dbh,$projectID,$projectName,$userid,$username) = @_;
	my $text;
	my @len;
	my $filearrayLength;
	tie my %checkedOutFiles, "Tie::IxHash";
	%checkedOutFiles = &getConfigItems(dbh => $dbh, schema => 'SCM', userId => $userid, projectId => 4, option => 'CHECKEDOUT');
	@len = %checkedOutFiles;
	$filearrayLength = @len;
	if ($filearrayLength > 0) {
		$outstring .= <<END_OF_BLOCK;
		<table cellpadding=4 cellspacing=0 border=0 width=50%>
		<tr><td align=center colspan=2><font size=-1 color=black><b>Files checked out to $username for $projectName:</b></font></td></tr>
		<tr><td height=15 colspan=2></td></tr>
		<tr><td align=left valign=top><font size=-1><b>File:</b.</font></td>
		<td><select size=1 name=fileid>
END_OF_BLOCK
		foreach my $fileID (keys (%checkedOutFiles)) {
			$outstring .= "<option value=$fileID>$checkedOutFiles{$fileID}{'name'}&nbsp;&nbsp;&nbsp; version $checkedOutFiles{$fileID}{'majorVersion'}.$checkedOutFiles{$fileID}{'minorVersion'}\n";
		}	
		$outstring .= <<END_OF_BLOCK10;
		</select></td></tr>
		<tr><td align=left valign=top><font size=-1><b>Modification:</b></font></td>
			<td><textarea name=changes rows=4 cols=40></textarea></td></tr>
		<tr><td height=15 colspan=2></td></tr>
		<tr><td align=center colspan=2>
	  	<input type=button value="Check In Item" onClick=submitFormCGIResults('configitem','db_checkin_item');>
	  	</td></tr>
		</table><br>
END_OF_BLOCK10
	}
	else {
		$outstring .= "There are no files checked out to $username for $projectName ";
	}
	$outstring .= <<END_OF_BLOCK12;
	</form>
	</body>
	</center>
	</HTML>
END_OF_BLOCK12
	$outstring .=  &writeTitleBar(title => "Check In Configuration Item");
	return ($outstring);
}
#################
sub checkoutBody {
#################
	my ($dbh,$projectID) = @_;
	my $text;
	my @len;
	my $databaseLength;
	my $filearrayLength;
	tie my %writableFiles, "Tie::IxHash";
	tie my %databaseFiles, "Tie::IxHash";
	tie my %SCRlist, "Tie::IxHash";
	%writableFiles = &getConfigItems(dbh => $dbh, schema => 'SCM', projectId => $projectID, option => 'LATEST');
	%databaseFiles = &getConfigItems(dbh => $dbh, schema => 'SCM', projectId => $projectID, option => 'DATABASE');
	%SCRlist = &getSCR(dbh => $dbh, schema => 'SCM', projectId => $projectID, option => 'ACCEPTED');
	$outstring .= <<END_OF_BLOCK6;
	<table cellpadding=1 cellspacing=1 border=0 width=50%>
	<tr><td align=center colspan=2><font size=-1><b>Select the file(s) to be checked out:</b></font></td></tr>
	<tr><td height=5 colspan=2></td></tr>
END_OF_BLOCK6
	@len = %writableFiles;
	$filearrayLength = @len;
	if ($filearrayLength > 0) {
		$outstring .= "<tr><td align=right valign=top><font size=-1><b>File(s):</b></font></td>\n";
		$outstring .= "<td>&nbsp;&nbsp;&nbsp;<select size=10 multiple name=checkoutfiles>\n";
		foreach my $fileID (keys (%writableFiles)) {
			$outstring .= "<option value=$fileID>$writableFiles{$fileID}{'name'}&nbsp;&nbsp;&nbsp; version $writableFiles{$fileID}{'majorVersion'}.$writableFiles{$fileID}{'minorVersion'}\n";
		}
		$outstring .= "</select></td></tr>\n";
	}
	@len = %databaseFiles;
	$databaseLength = @len;
	if ($databaseLength > 0) {
		$outstring .= "<tr><td align=right valign=top><font size=-1><b>Database:</b></font></td>\n";
		$outstring .= "<td>&nbsp;&nbsp;&nbsp;<select size=1 name=databasefile>\n";
		if ($filearrayLength > 0) {$outstring .= "<option value=0>N/A\n";}
		foreach my $fileID (keys (%databaseFiles)) {
			$outstring .= "<option value=$fileID>$databaseFiles{$fileID}{'name'}&nbsp;&nbsp;&nbsp; version $databaseFiles{$fileID}{'majorVersion'}.$databaseFiles{$fileID}{'minorVersion'}\n";
		}
		$outstring .= "</select></td></tr>\n";
	}
	if ($databaseLength > 0 || $databaseLength > 0) {
		$outstring .= <<END_OF_BLOCK7;
		<tr><td height=10 colspan=2></td></tr>
		<tr><td valign=top align=right><font size=-1><b>Reason:</b></font></td>
		<td><input type=radio name=reason value=SCR checked><font size=-1><b>SCR:&nbsp;</b></font>
		<select size=1 name=scrlist>
		<option value=0>0 - Initial Version
END_OF_BLOCK7
		foreach my $scrID (keys (%SCRlist)) {
			$text = substr($SCRlist{$scrID}{'description'},0,35) . "...";
			$outstring .= "<option value=$scrID>$scrID - $text\n";
		}
		$outstring .= <<END_OF_BLOCK8;
		</select><br>
			<input type=radio name=reason value=IE><font size=-1><b>Internal Enhancement</b></font><br>
			<input type=radio name=reason value=bug><font size=-1><b>Problem Report</b></font></td></tr>
		<tr><td colspan=2 align=center><br><input type=button value="Check Out Items" onClick=submitFormCGIResults('configitem','db_checkout_item');></td></tr>
END_OF_BLOCK8
	}
	else {
		$outstring .= "<tr><td colspan=2 align=center><br>There are no configuration items available for checkout</td></tr>\n";
	}
	$outstring .= <<END_OF_BLOCK11;
	</table><br><br>
	</form>
	</body>
	</center>
	</HTML>
END_OF_BLOCK11
	$outstring .=  &writeTitleBar(title => "Check Out Configuration Item");
	return ($outstring);
}
#################
sub createItemBody {
#################
	my ($dbh) = @_;
	my %itemTypes = &getItemType(dbh => $dbh, schema => 'SCM');
	my %itemSources = &getItemSource(dbh => $dbh, schema => 'SCM');
	$outstring .= <<END_OF_BLOCK3;
	<br><font color=black size=-1><b>Enter New Item Information:</b></font><br><table cellpadding=4 cellspacing=0 border=0 width=50%>
	<tr><td align=center valign=top><font color=black size=-1><b>Item Name:</b></font></td>
		<td><input type=text name=itemname size=50></td></tr>
	<tr><td align=center valign=top><font color=black size=-1><b>Item Type:</b></font></td>
		<td><select size=1 name=type>
END_OF_BLOCK3
	foreach my $typeid (keys (%itemTypes)) {
		$outstring .= "<option value=$typeid>$itemTypes{$typeid}\n";
	}
	$outstring .= <<END_OF_BLOCK4;
	</select></td></tr>
	<tr><td align=center valign=top><font color=black size=-1><b>Item Source:</b></font></td>
	<td><select size=1 name=source>
END_OF_BLOCK4
	foreach my $sourceid (keys (%itemSources)) {
		$outstring .= "<option value=$sourceid>$itemSources{$sourceid}\n";
	}
$outstring .= <<END_OF_BLOCK5;
		</select></td>
		</td></tr>
	</table><br>
	<input type=button value=Submit onClick=submitFormCGIResults('configitem','db_create_item');>
	</form>
	</body>
	</center>
	</HTML>
END_OF_BLOCK5
	$outstring .=  &writeTitleBar(title => "Create Configuration Item");
	return ($outstring);
}
#################
sub redirect {
#################
	my ($command) = @_;
	$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
	my $path = $1;
	my $form = $2;
	my $actionline;
	my $msg;
	if ($command eq 'checkin') {
		$actionline = "document.$form.command.value = 'checkin_item';";
		$actionline .= "\ndocument.$form.action = '$path' + 'configitem.pl';";
		$msg = "Check-In Sucessful";
	}
	if ($command eq 'checkout') {
		$actionline = "document.$form.action = '$path' + 'home.pl';";
		$msg = "Check-Out Successful";
	}
	#my $outstring = $scmcgi->header('text/html');
	$outstring .= <<END_OF_BLOCK9;
	<HTML>
	<body>
	<form name=$form method=post target=main action=$path$form.pl>
	<script language=javascript><!--
		alert ('$msg');
		$actionline
		document.$form.submit();
	//-->
	</script>
	</form>
	</body>
	</html>
END_OF_BLOCK9
	return ($outstring);

}

