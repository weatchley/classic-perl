#!/usr/local/bin/perl -w


$| = 1;

use CGI;
use strict;
use integer;
use SCM_Header qw(:Constants);
use DB_scm qw(:Functions);
use DBI;
use DBD::Oracle qw(:ora_types);

my $schema = $SCHEMA;

$ENV{SCRIPT_NAME} =~ m%(.*/)(.*)\..*$%;
my $path = $1;
my $form = $2;
my $dbh;

my $scmcgi = new CGI;

print $scmcgi->header('text/html');
print <<end;
<html>
<head>
<title>Document Move</title>
</head>
<body>
end

$dbh = db_connect();
$dbh->{LongTruncOk} = 1;   # specify whether to fetch whole text or truncated fraction
$dbh->{LongReadLen} = 10000000;
my $type = 11;
my $table = "template";
my $table2 = "template_version";
my $seq = "template_id";
my $seq2 = "template_version_id";
#my $type = 10;
#my $table = "procedure";
#my $table2 = "procedure_version";
#my $seq = "procedure_id";
#my $seq2 = "procedure_version_id";

my $sqlcode = "SELECT id, name,description FROM $schema.configuration_item WHERE type_id=$type ORDER BY description";
my $csr = $dbh->prepare($sqlcode);
eval {
$csr->execute;

    while(my ($oldid, $name, $description) = $csr->fetchrow_array) {
        my ($id) = $dbh->selectrow_array("SELECT $seq.nextval FROM dual");
        $description = $dbh->quote($description);
#print STDERR "$id, $name, $description\n\n";
        $dbh->do("INSERT INTO $schema.$table (id, name, description) VALUES ($id, '$name', $description)");
        $sqlcode = "SELECT major_version, minor_version, version_date, status_id, developer_id, change_description, " .
                 "locker_id, item_image, signed_image FROM $schema.item_version WHERE item_id=$oldid ORDER BY major_version, minor_version";
#print "$sqlcode<br><br>\n";
        my $csr2 = $dbh->prepare($sqlcode);
        $csr2->execute;
        while (my ($major_version, $minor_version, $version_date, $status_id, $developer_id, $change_description, $locker_id, $item_image, $signed_image) = $csr2->fetchrow_array) {
            my ($nextid) = $dbh->selectrow_array("SELECT $seq2.nextval FROM dual");
            $change_description = $dbh->quote($change_description);
            $sqlcode = "INSERT INTO $schema.$table2 (id, item_id, major_version, minor_version, version_date, status_id,";
            $sqlcode .= "developer_id, change_description, locker_id, item_image, signed_image) VALUES ($nextid, $id,";
            $sqlcode .= "$major_version, $minor_version, '$version_date', $status_id, $developer_id, $change_description, ";
            $sqlcode .= ((defined($locker_id)) ? "$locker_id" : "NULL") . ", :ii, " . ((defined($signed_image)) ? ":si" : "NULL") . ")";
#print "$sqlcode<br><br>\n";
            my $csr3 = $dbh->prepare($sqlcode);
            $csr3->bind_param(":ii", $item_image, { ora_type => ORA_BLOB, ora_field=>'item_image' });
            if (defined($signed_image)) {
                $csr3->bind_param(":si", $signed_image, { ora_type => ORA_BLOB, ora_field=>'signed_image' });
            }
            $csr3->execute;
            $csr3->finish;
        }
        $csr2->finish;
        if ($table eq "procedure") {
            $sqlcode = "SELECT userid,item_id, date_completed,major_version,minor_version,certificate FROM $schema.training WHERE item_id=$oldid";
            $csr2 = $dbh->prepare($sqlcode);
            $csr2->execute;
            while (my ($userid,$item_id, $date_completed,$major_version,$minor_version,$certificate) = $csr2->fetchrow_array) {
                my ($verID) = $dbh->selectrow_array("SELECT id FROM $schema.procedure_version WHERE item_id=$id AND major_version=$major_version AND minor_version=$minor_version");
                $sqlcode = "INSERT INTO $schema.procedure_training_completed (userid,procedureversion,datecompleted,certificate) VALUES ";
                $sqlcode .= "($userid,$verID,'$date_completed', :cert)";
                my $csr3 = $dbh->prepare($sqlcode);
                $csr3->bind_param(":cert", $certificate, { ora_type => ORA_BLOB, ora_field=>'certificate' });
                $csr3->execute;
                $csr3->finish;
                $dbh->commit;
            }
            $csr2->finish;
        }
    }
    $csr->finish;
    $dbh->commit;
    print "Done\n";
};
if ($@) {
    print "Error: $@\n";
}

print "</body>\n</html>\n";

&db_disconnect($dbh);
exit();

