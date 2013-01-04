#!/usr/local/bin/newperl
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
use integer;
use strict;
use DBI;
use CRD_Header qw(:Constants);
use DB_Utilities_Lib qw(:Functions);
use UI_Widgets qw(:Functions);
use DBD::Oracle qw(:ora_types);
use Carp;

my $dbh;
my $csr;
my $status;
my $sqlquery = "SELECT id,name FROM eis.bin ORDER BY name";
my @values;
my $comCount;
my $scrCount;

#$dbh = DBI->connect('dbi:Oracle:ydoracle','scott','5happy5', { RaiseError => 1, AutoCommit => 0 });
$dbh = &db_connect(server => 'ydoraprd.ymp.gov');

print "content-type: text/html\n\n";
print "<html><body>\n";
print "<h2>Bin Counts</h2>\n";

$csr = $dbh->prepare($sqlquery);
$status = $csr->execute;

print "<table><tr><td align=center>Comments/SCR's</td><td> &nbsp; &nbsp; &nbsp; </td><td align=center>ID</td><td> &nbsp; </td><td>Bin</td></tr>\n";
while (@values = $csr->fetchrow_array) {
    my ($id, $name) = @values;
    ($comCount) = $dbh->selectrow_array("SELECT count(*) FROM eis.comments WHERE bin=$id");
    ($scrCount) = $dbh->selectrow_array("SELECT count(*) FROM eis.summary_comment WHERE bin=$id");
    print "<tr><td align=center>" . ($comCount + $scrCount) . "</td><td>&nbsp;</td><td align=center>$id</td><td>&nbsp;</td><td>$name</td></tr>\n";
}
print "</table>\n";

$csr->finish;
&db_disconnect($dbh);

print "</body></html>\n";
