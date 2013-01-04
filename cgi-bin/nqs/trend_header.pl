#!/usr/local/bin/newperl -w
#
# $Source $
#
# $Revision: 1.3 $
#
# $Date: 2002/03/28 22:34:30 $
#
# $Author: starkeyj $
#
# $Locker:  $
#
# $Log: trend_header.pl,v $
# Revision 1.3  2002/03/28 22:34:30  starkeyj
# no change
#
# Revision 1.2  2001/11/20 14:46:35  starkeyj
# modified to change heder layout
#
# Revision 1.1  2001/07/06 23:04:03  starkeyj
# Initial revision
#
# 
#
use integer;
use strict;
use NQS_Header qw(:Constants);
use NQS_Utilities_Lib qw(:Functions);
#use UI_Widgets qw(:Functions);
use CGI;
my $DDTcgi = new CGI;
my $username = defined($DDTcgi->param("username")) ? $DDTcgi->param("username") : "GUEST";
my $userid = defined($DDTcgi->param("userid")) ? $DDTcgi->param("userid") : "None";
my $schema = defined($DDTcgi->param("schema")) ? $DDTcgi->param("schema") : "NQS";
my $Server = defined($DDTcgi->param("server")) ? $DDTcgi->param("server") : $NQSServer;
my $title = defined($DDTcgi->param("title")) ? $DDTcgi->param("title") : "None";





print "Content-type: text/html\n\n";
print "<html>\n";

print"<center><head><h2><font color=black>Trend Analysis</font></h2></head>\n";
print"<body bgcolor=#FFFFEO>\n";

print"</body>\n";
print "</center>\n";
print "</html>\n";

