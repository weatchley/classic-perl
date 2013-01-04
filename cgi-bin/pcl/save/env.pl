#!/usr/local/bin/newperl -w

use CGI;
use strict;
my $key;
my $cgi = new CGI;
print $cgi->header('text/html');
print "<html>\n";
print "<head>\n";
print "</head>\n";
print "<body>\n";
print "<table>\n";
foreach $key (sort keys %ENV) {
	print "<tr><td>$key=$ENV{$key}</td></tr>\n";
}
print "</table>\n</body>\n</html>\n";