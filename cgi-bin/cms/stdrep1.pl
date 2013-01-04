#!/usr/local/bin/newperl
#
# CMS Standard Report Frame 1
#
# $Source: /data/dev/cirs/perl/RCS/stdrep1.pl,v $
# $Revision: 1.1 $
# $Date: 2001/03/21 18:44:20 $
# $Author: naydenoa $
# $Locker:  $
# $Log: stdrep1.pl,v $
# Revision 1.1  2001/03/21 18:44:20  naydenoa
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
# connect to the oracle database and generate a database handle
my $dbh = oncs_connect();

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
print "<title></title>\n";

print "<script src=\"$ONCSJavaScriptPath/oncs-utilities.js\"></script>\n";
print "<script type=\"text/javascript\">\n<!--\n";
print "var dosubmit = true;\n";
print "if (parent == self) {\n";
print "      location = \'$ONCSCGIDir/login.pl\'\n";
print "}\n//-->\n";
print "function DisplayDefinitions () {\n";
print "    var loc;\n";
print "    loc = \'$ONCSCGIDir/commit_level_definitions.pl?loginusersid=$usersid&loginusername=$username&schema=$SCHEMA\'\n";
print "    PopIt(loc, \'oncs_popup\');\n";
print "};\n";
print "function submitsort (sortvalue) {\n";
print "    // function changes the sort field and submits the form.\n";
print "    document.reportfilter.sortval.value = sortvalue;\n";
print "    document.reportfilter.submit ();\n";
print "};\n";

print "</script>\n";
print "</head>\n";

#Build Frameset for modifying roles with multiple picklists.
my %commitmentlevelhash = get_lookup_values($dbh, 'commitmentlevel', 'description', 'commitmentlevelid');
my $defaultfiltervalue = $commitmentlevelhash{"Regulatory Commitment"};

my $filtervalue = $cmscgi->param('commitmentlevel');
$filtervalue = ($filtervalue) ? $filtervalue : $defaultfiltervalue;

my $sortorder = $cmscgi->param('sortval');
$sortorder = (defined($sortorder)) ? $sortorder : 'issuedesc';
my $catsort='category';
#my $leadsort='lead';
my $comsort='commitment';
my $issort='issue';
my $statsort='status';
my $fullsort='fulfill';
my $doesort='doelead';
my $mosort='molead';

print "<body background=$ONCSBackground text=$ONCSFontColor link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";
print "<form name=reportfilter method=post action=\"$ONCSCGIDir/stdrep2.pl\" target=stdrep2>\n";
print "<input type=hidden name=loginusersid value=$usersid>\n";
print "<input type=hidden name=loginusername value=$username>\n";
print "<input type=hidden name=sortval value=''>\n";
print "<input type=hidden name=schema value=$SCHEMA>\n";
print "<input type=hidden name=option value=''>\n";
print "<input type=hidden name=theinterface value=''>\n";
print "<input type=hidden name=interfaceLevel value=''>\n";
print "<input type=hidden name=id value=''>\n<center>\n";
print "<input type=button value=Definitions name=btndefinitions onclick=\"DisplayDefinitions()\">\n&nbsp;\n";
print "<select name=commitmentlevel>\n";
print "<option value='-1'>All Commitments\n";
foreach my $key (sort keys %commitmentlevelhash) {
    my $selectedtext = ($commitmentlevelhash{$key} == $filtervalue) ? " selected" : "";
    print "<option value=\"$commitmentlevelhash{$key}\"$selectedtext>$key\n";
}
print "</select>\n";
print "<input type=submit value=Go name=submit_reportfilter></center><br>\n";
print "<table width=750 align=center cellpadding=3 cellspacing=0 border=1>";
print "<tr bgcolor=#daaada><td><font size=+1><b>Standard Report</b></font></td></tr>";
print "<tr bgcolor=#f0f0f0><td><table width=100% cellpadding=0 cellspacing=0>";
print "<tr bgcolor=#f0f0f0><td><font size=-1><b><a href=\"javascript:submitsort('$catsort');\">Category</a>" . nbspaces(18) . "<a href=\"javascript:submitsort('$issort');\">Issue</a>" . nbspaces(26) . "<a href=\"javascript:submitsort('$comsort');\">Commitment</a>" . nbspaces(17) . "<a href=\"javascript:submitsort('$statsort');\">Status</a>" . nbspaces(11) . "</font><font size=-2><a href=\"javascript:submitsort('$fullsort');\">Fulfillment Date</a></font><font size=-1>" . nbspaces(11) ."<a href=\"javascript:submitsort('$doesort');\">DOEL</a>" . nbspaces(19) ."<a href=\"javascript:submitsort('$mosort');\">BSCL</a>" . nbspaces(21) . "LL</td></tr></table></td></tr>";
print "</table>";

&oncs_disconnect($dbh);
print "</form>";
print "</body>\n";
print "</html>\n";


