#!/usr/local/bin/newperl -w

use ONCS_Header qw(:Constants);
use ONCS_Widgets qw(:Functions);
use ONCS_Utilities_Lib qw(:Functions);
use ONCS_specific qw(:Functions);

use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;
use strict;

my $oncscgi = new CGI;

# tell the browser that this is an html page using the header method
print $oncscgi->header('text/html');

my $username = $oncscgi->param('loginusername');
my $usersid = $oncscgi->param('loginusersid');
if ((!defined($usersid)) || ($usersid eq "") || (!defined($username)) || ($username eq ""))
  {
  print <<openloginpage;
  <script type="text/javascript">
  <!-- 
  parent.location='/cgi-bin/oncs/oncs_user_login.pl';
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
<body>

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