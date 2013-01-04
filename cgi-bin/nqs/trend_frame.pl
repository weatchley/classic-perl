#!/usr/local/bin/newperl
# - !/usr/bin/perl
#
# $Source $
#
# $Revision: 1.4 $
#
# $Date: 2002/10/23 22:00:16 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: trend_frame.pl,v $
# Revision 1.4  2002/10/23 22:00:16  starkeyj
# modified to add 'use strict' pragma
#
# Revision 1.3  2002/03/28 22:31:22  starkeyj
# modified to remove the uninitialized variable warnings in the activity log
#
# Revision 1.2  2001/11/20 14:46:35  starkeyj
# modified to change header and title display for application
#
# Revision 1.1  2001/07/06 23:04:03  starkeyj
# Initial revision
#
# 
#
use strict;
use NQS_Header qw(:Constants);
use NQS_Utilities_Lib qw(:Functions);
use CGI;
use DBI;

my $DDTcgi = new CGI;
my $username = defined($DDTcgi->param("username")) ? $DDTcgi->param("username") : "GUEST";
my $userid = defined($DDTcgi->param("userid")) ? $DDTcgi->param("userid") : "None";
my $schema = defined($DDTcgi->param("schema")) ? $DDTcgi->param("schema") : $SCHEMA;
my $Server = defined($DDTcgi->param("server")) ? $DDTcgi->param("server") : $NQSServer;
my $command = ((defined($DDTcgi->param('command'))) ? (($DDTcgi->param('command') gt " ") ? $DDTcgi->param('command') : "menu") : "menu");
my $cgiaction = defined($DDTcgi->param("cgiaction")) ? $DDTcgi->param("cgiaction") : "login";
my $password = defined($DDTcgi->param("password")) ? $DDTcgi->param("password") : "None";
my $idstr = "&username=$username&userid=$userid";
my $path = $1;
#my $form = $2;
my $script;

print <<END_of_Multiline_Text;
Content-type: text/html

<HTML>
<HEAD>
<script src=$NQSJavaScriptPath/utilities.js></script>
<Title> Trend Analysis </Title>
</HEAD>
<center>

END_of_Multiline_Text

if ($username eq "GUEST") { 
	$script = "trend_login";
}
else {
	$script = "trend_documents";
}

print "<frameset rows=38,*,2 frameborder=no framespacing=0 >\n";
print "<frame src=$NQSCGIDir/trend_header.pl? name=header scrolling=no>\n";
print "<frame src=$NQSCGIDir/$script.pl? name=workspace scrolling=yes>\n";
print "<frame src=$NQSCGIDir/blank.pl? name=control scrolling=no>\n";
print "</frameset>\n";

print<<END;
</center>
</HTML>

END
