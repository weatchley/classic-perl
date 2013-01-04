#!/usr/local/bin/newperl -w

use strict;
use integer;
use DBShared;
use DBI;
use DBD::Oracle qw(:ora_types);
use CGI;

    my $warn = $^W;
    $^W=0;
my $scrcgi = new CGI;
    $^W=$warn;
my $schema = (defined($scrcgi->param("schema"))) ? $scrcgi->param("schema") : $ENV{'SCHEMA'};
$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;

my $dbh = db_connect();

print $scrcgi->header('text/html');
print "<html>\n<head>\n";
print "<meta http-equiv=expires content=now>\n";
print "<title>Data dump</title>\n";
print "</head>\n";

print "<body background=#eeeeee text=#002299 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

$dbh -> {LongReadLen} = 10000;

my $csr;
my $count = 0;

my (@sections) = &getSections (dbh => $dbh, schema => $schema, where => "qardrevid = 13 and isdeleted = 'F'", orderby => "tocid, sorter, sectionid, subid, id");
my ($id, $type, $sectionid, $subid);
for (my $i = 1; $i <= $#sections; $i++) {
    $id = $sections[$i]{id};
    $type = $sections[$i]{types};
    $sectionid = $sections[$i]{sectionid};
    $subid = $sections[$i]{subid};

    print "ID: $id, SectionID/SubID: $sectionid/$subid, Current Type: $type<br>\n";


    my $colortypes = $dbh -> prepare ("select distinct s.typeid from qardmatrix m, sourcerequirement r, source s where m.qardsectionid = $id and m.sourcerequirementid = r.id and r.sourceid = s.id");
    $colortypes -> execute;
    my $colortypecount = 0;
    my $ct = 0;
    my $thect = 0;
    my $tmptype = "N";
    while (my ($ct) = $colortypes -> fetchrow_array) {
        $colortypecount++;
        $thect = $ct;
	print "CT: $ct, ";
    }
    $colortypes -> finish;
    if ($colortypecount == 1) {
        ($tmptype) = $dbh -> selectrow_array ("select abbrev from $schema.sourcetype where id = $thect");                 
    }
    elsif ($colortypecount > 1) {
        $tmptype = "M";
    }
    my ($fontopen, $fontclose) = ("", "");
    if ($tmptype ne $type) {
	$fontopen = "<font color=red>";
	$fontclose = "</font>";
    }
print "$fontopen New type: $tmptype$fontclose<br><br>\n";
#         my $prepsection = $dbh -> do ("update $schema.qardsection set types = '$tmptype' where id = $id");





}


print "<br><br>\n</body>\n</html>\n";
my $stat = db_disconnect($dbh);



