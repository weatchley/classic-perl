#!/usr/local/bin/newperl
#
# CMS Standard Report Frames Script
#
# $Source: /data/dev/cirs/perl/RCS/report.pl,v $
# $Revision: 1.1 $
# $Date: 2001/03/21 18:43:14 $
# $Author: naydenoa $
# $Locker:  $
# $Log: report.pl,v $
# Revision 1.1  2001/03/21 18:43:14  naydenoa
# Initial revision
#
#

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $cmscgi = new CGI;

$SCHEMA = (defined($cmscgi->param("schema"))) ? $cmscgi->param("schema") : $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

# print content type header
print $cmscgi->header('text/html');

my $username = $cmscgi->param('loginusername');
my $usersid = $cmscgi->param('loginusersid');

if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq "")) {
  print <<openloginpage;
  <script type="text/javascript">
  <!--
  parent.location='$ONCSCGIDir/login.pl';
  //-->
  </script>
openloginpage
  exit 1;
}

#print top of page
print "<html>\n<head>\n";
print "<meta name=\"pragma\" content=\"no-cache\">\n";
print "<meta name=\"expires\" content=\"0\">\n";
print "<meta http-equiv=\"expires\" content=\"0\">\n";
print "<meta http-equiv=\"pragma\" content=\"no-cache\">\n";
print "<title>Standard Report</title>\n";

print "<script src=\"$ONCSJavaScriptPath/oncs-utilities.js\"></script>\n";
print "<script type=\"text/javascript\">\n<!--\n";
print "var dosubmit = true;\n";
print "if (parent == self) {\n";
print "      location = \'$ONCSCGIDir/login.pl\'\n";
print "}\n//-->\n</script>\n";
print "<script language=\"JavaScript\" type=\"text/javascript\">\n<!--\n";
print "doSetTextImageLabel(\'Standard Report\');\n//-->\n</script>\n";
print "</head>\n";

print <<frameset1;
<frameset rows=105,* frameborder=no frameborder=0 framespacing=0 noresize>
<frame src="$ONCSCGIDir/stdrep1.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA" name=stdrep1 noresize frameborder=no frameborder=0>
<frame src="$ONCSCGIDir/stdrep2.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA" name=stdrep2 noresize frameborder=no frameborder=0>
</frameset>
frameset1
print "</html>\n";
