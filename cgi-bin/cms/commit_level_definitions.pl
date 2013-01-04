#!/usr/local/bin/newperl -w

# Definitions Display screen for manager's report
#
# $Source: /data/dev/cirs/perl/RCS/commit_level_definitions.pl,v $
# $Revision: 1.5 $
# $Date: 2000/08/21 17:47:11 $
# $Author: atchleyb $
# $Locker:  $
# $Log: commit_level_definitions.pl,v $
# Revision 1.5  2000/08/21 17:47:11  atchleyb
# added check schema line
#
# Revision 1.4  2000/07/06 23:33:16  munroeb
# finished making mods to javascripts and html.
#
# Revision 1.3  2000/07/05 23:02:38  munroeb
# made changes to html and javascripts
#
# Revision 1.2  2000/05/18 23:12:11  zepedaj
# Added background image
# Changed blank.htm to blank.pl
# Cleaned up hardcoded paths
#
# Revision 1.1  2000/04/11 23:51:03  zepedaj
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

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $oncscgi = new CGI;

$SCHEMA = (defined($oncscgi->param("schema"))) ? $oncscgi->param("schema") : $SCHEMA;

# tell the browser that this is an html page using the header method
print $oncscgi->header('text/html');

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

# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

my %definitionshash = get_lookup_values($dbh, "commitmentlevel", "description", "definition");
print <<documentbody1;
<html>
<head>
<title>Level of Commitment Definitions</title>
</head>

<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>

<center><h1>Level of Commitment Definitions</h1></center>

<ul>
documentbody1
foreach my $key (sort keys %definitionshash)
  {
  print "  <li>$key - $definitionshash{$key}</li>\n";
  }
print <<documentbody2;
</ul>
<a href="javascript:close()">Close This Window</a>
</body>
</html>
documentbody2

&oncs_disconnect($dbh);

1;
