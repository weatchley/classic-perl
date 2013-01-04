#!/usr/local/bin/perl -w

# CGI user login for the SCM
#
# $Source: /usr/local/www/gov.ymp.intradev/rcs/pcl/perl/RCS/login.pl,v $
#
# $Revision: 1.11 $
#
# $Date: 2009/01/14 22:41:58 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: login.pl,v $
# Revision 1.11  2009/01/14 22:41:58  atchleyb
# ACR0901_007 - Updated to create new path to system (login_new.pl) and to redirect login.pl to the new system (PCLWR)
#
# Revision 1.10  2003/11/28 21:27:10  starkeyj
# added section for 'command eq login' (SCR14)
#
# Revision 1.9  2003/02/03 19:58:05  atchleyb
# removed refs to SCM
#
# Revision 1.8  2003/01/27 19:37:02  atchleyb
# updated to use https
#
# Revision 1.7  2002/11/08 21:55:47  atchleyb
# updated to use UI_Widgets.pm
#
# Revision 1.6  2002/10/24 22:02:15  atchleyb
# seperated logic into BL, DB, and UI
#
# Revision 1.5  2002/10/21 22:22:26  atchleyb
# changed user_functions.pl to user.pl
#
# Revision 1.4  2002/10/01 16:18:38  atchleyb
# updated to reset cgiresults to blank after login
#
# Revision 1.3  2002/09/18 21:34:48  atchleyb
# fixed bug in calling the log activity funciton
#
# Revision 1.2  2002/09/18 01:15:03  mccartym
# changed system name in title
#
# Revision 1.1  2002/09/17 21:27:00  starkeyj
# Initial revision
#
#
#

$| = 1;

use strict;
use integer;
use SharedHeader qw(:Constants);
use UIShared qw(:Functions);
#use UILogin qw(:Functions);
#use DBLogin qw(:Functions);
#use UI_Widgets qw(:Functions);
#use UI_scm qw(:Functions);

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh;
#$dbh = &db_connect();
#my %settings = getInitialValues(dbh => $dbh);



###################################################################################################################################
###################################################################################################################################

###################################################################################################################################
#

###################################################################################################################################
    print &writeHTTPHeader();
    print &writeHTMLHead(title => "PCL");
    print "<script language=javascript><!--\n";
    print "    document.location='/pclwr/home.jsp';\n";
    print "//-->\n</script>\n";
    print &doEndPage;
###################################################################################################################################


exit();
