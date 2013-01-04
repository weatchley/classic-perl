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

my $urllocation;
my $command = (defined ($scrcgi -> param("command"))) ? $scrcgi -> param("command") : "write_request";
my $username = (defined($scrcgi->param("loginusername"))) ? $scrcgi->param("loginusername") : "";
my $password = (defined($scrcgi->param("password"))) ? $scrcgi->param("password") : "";
my $userid = (defined($scrcgi->param("loginusersid"))) ? $scrcgi->param("loginusersid") : "";
my $error = "";
my $dbh = db_connect();

print $scrcgi->header('text/html');
print "<html>\n<head>\n";
print "<meta http-equiv=expires content=now>\n";
print "<title>Data dump</title>\n";
print "</head>\n";

print "<body background=#eeeeee text=#002299 link=#0000ff vlink=#0000ff alink=#0000ff topmargin=0 leftmargin=0>\n";

=pod
#open (SOURCE, "prptransfertest") || die "cannot open file for reading: $!";
#while (<SOURCE>) {
#    my $thestring = "$_";
#    my $separator = "<#*#>";
#    my $endrecord = "<###>";
#    my $where = index ($thestring, $separator);
#    my $count = 0;
#    while ($where != -1 && $thestring ne "<#,#>\n" && $thestring ne "<###>\n"){
#	my $sourcedocid = substr ($thestring, 0, $where);
#	$count ++;
#
#	print "$count<br>\n";
#
#	print "Requirements document ID: $sourcedocid<br>\n";
#	$thestring = substr ($thestring, $where);
#	$thestring = substr ($thestring, 5);
#	$where = index ($thestring, $separator);
#	my $sectionid = substr ($thestring, 0, $where);
#	print "Source doc section ID: $sectionid<br>\n";
#
#        $thestring = substr ($thestring, $where);
#        $thestring = substr ($thestring, 5);
#        $where = index ($thestring, $separator);
#        my $requirementid = substr ($thestring, 0, $where);
##        $title = ($title) ? $title : " ";
#        print "Requirement ID: $requirementid<br>\n";
#
#	$thestring = substr ($thestring, $where);
#	$thestring = substr ($thestring, 5);
#	$where = index ($thestring, $endrecord);
#	my $text = substr ($thestring, 0, $where);
#        $text = ($text) ? $text : "";
#        $text =~ s/\n/\\n/g;
#        $text =~ s/'/''/g;
#	print "Section text: $text<br>\n";
#
##=pod
#	my $insertstr;
#	my $csr;
#
#        $insertstr = "insert into $schema.sourcerequirement (id, sourceid, sectionid, requirementid, text, dateentered, enteredby, lastupdated, updatedby) values ($schema.sourcerequirement_id_seq.nextval, $sourcedocid, '$sectionid', $requirementid, '$text', SYSDATE, 1005, SYSDATE, 1005)";
#	print "$insertstr<br><br>\n";
#	$csr = $dbh -> prepare ($insertstr);
#	$csr -> execute;
#    	$csr -> finish;
##=cut
#	$where = index ($thestring, $endrecord);
#	$thestring = substr ($thestring, $where);
#	$thestring = substr ($thestring, 5);
#	$where = index ($thestring, $separator);
#    }
#}
#close (SOURCE);
=cut
=pod
	my $csr;
open (SOURCE, "docmove") || die "cannot open file for reading: $!";
while (<SOURCE>) {
    my $thestring = "$_";
    my $separator = "\t";
    my $endrecord = "\n";
    my $where = index ($thestring, $separator);
    my $count = 0;
#    while ($where != -1 && $thestring ne "\neof") {
    while ($where != -1 && $thestring ne "\t\n" && $thestring ne "\n\n") {
	my $generatedid = substr ($thestring, 0, $where);
	$count ++;
	print "$count<br>\n";
	print "Generated ID: $generatedid<br>\n";

	$thestring = substr ($thestring, $where);
	$thestring = substr ($thestring, 1);
	$where = index ($thestring, $separator);
	my $sourcedocid = substr ($thestring, 0, $where);
	print "Source doc ID: $sourcedocid<br>\n";

	$thestring = substr ($thestring, $where);
	$thestring = substr ($thestring, 1);
	$where = index ($thestring, $separator);
	my $sectionid = substr ($thestring, 0, $where);
	print "Source doc section ID: $sectionid<br>\n";

        $thestring = substr ($thestring, $where);
        $thestring = substr ($thestring, 1);
        $where = index ($thestring, $separator);
        my $requirementid = substr ($thestring, 0, $where);
#        $title = ($title) ? $title : " ";
        print "Requirement ID: $requirementid<br>\n";

	$thestring = substr ($thestring, $where);
	$thestring = substr ($thestring, 1);
	$where = index ($thestring, $endrecord);
	my $text = substr ($thestring, 0, $where);
        $text = ($text) ? $text : "";
        $text =~ s/\n/\\n/g;
        $text =~ s/'/''/g;
	print "Section text: $text<br>\n";

	my $insertstr;
        $insertstr = "insert into $schema.sourcerequirement (id, sourceid, sectionid, requirementid, text, dateentered, enteredby, lastupdated, updatedby) values ($schema.sourcerequirement_id_seq.nextval, $sourcedocid, '$sectionid', $requirementid, '$text', SYSDATE, 1005, SYSDATE, 1005)";
	print "$insertstr<br><br>\n";
	$csr = $dbh -> prepare ($insertstr);
	$csr -> execute;

	$where = index ($thestring, $endrecord);
	$thestring = substr ($thestring, $where);
	$thestring = substr ($thestring, 1);
	$where = index ($thestring, $separator);
    }
}
    	$csr -> finish;
close (SOURCE);
=cut

################  o414b  #################
=pod
	my $csr;
open (SOURCE, "o414b") || die "cannot open file for reading: $!";
while (<SOURCE>) {
    my $thestring = "$_";
    my $separator = "\n\n";
    my $endrecord = "\n\n\n";
    my $where = index ($thestring, $separator);
    my $count = 0;
#    while ($where != -1 && $thestring ne "\neof") {
    while ($where != -1 && $thestring ne "\n\n" && $thestring ne "\n\n\n") {
	my $generatedid = substr ($thestring, 0, $where);
	$count ++;
	print "$count<br>\n";
	print "Section ID: $generatedid<br>\n";

#	$thestring = substr ($thestring, $where);
#	$thestring = substr ($thestring, 1);
#	$where = index ($thestring, $separator);
#	my $sourcedocid = substr ($thestring, 0, $where);
#	print "Source doc ID: $sourcedocid<br>\n";

#	$thestring = substr ($thestring, $where);
#	$thestring = substr ($thestring, 1);
#	$where = index ($thestring, $separator);
#	my $sectionid = substr ($thestring, 0, $where);
#	print "Source doc section ID: $sectionid<br>\n";

#        $thestring = substr ($thestring, $where);
#        $thestring = substr ($thestring, 1);
#        $where = index ($thestring, $separator);
#        my $requirementid = substr ($thestring, 0, $where);
##        $title = ($title) ? $title : " ";
#        print "Requirement ID: $requirementid<br>\n";

	$thestring = substr ($thestring, $where);
	$thestring = substr ($thestring, 1);
	$where = index ($thestring, $endrecord);
	my $text = substr ($thestring, 0, $where);
        $text = ($text) ? $text : "";
        $text =~ s/\n/\\n/g;
        $text =~ s/'/''/g;
	print "Section text: $text<br>\n";

	my $insertstr;
        $insertstr = "insert into $schema.sourcerequirement (id, sourceid, sectionid, requirementid, text, dateentered, enteredby, lastupdated, updatedby) values ($schema.sourcerequirement_id_seq.nextval, 1, '$generatedid', 0, '$text', SYSDATE, 1005, SYSDATE, 1005)";
	print "$insertstr<br><br>\n";
#	$csr = $dbh -> prepare ($insertstr);
#	$csr -> execute;

	$where = index ($thestring, $endrecord);
	$thestring = substr ($thestring, $where);
	$thestring = substr ($thestring, 1);
	$where = index ($thestring, $separator);
    }
}
#    	$csr -> finish;
close (SOURCE);
=cut

################## o414c #######################

#=pod
my $csr;
open (SOURCE, "o414c") || die "cannot open file for reading: $!";
while (<SOURCE>) {
    my $thestring = "$_";
    my $separator = "\t";
    my $endrecord = "\n";
    my $where = index ($thestring, $separator);
    my $count = 0;
    while ($where != -1 && $thestring ne "\neof") {
	my $generatedid = substr ($thestring, 0, $where);
	$count ++;
	print "$count<br>\n";
	print "Section ID: $generatedid<br>\n";

	$thestring = substr ($thestring, $where);
	$thestring = substr ($thestring, 1);
	$where = index ($thestring, $separator);
	my $sourcedocid = substr ($thestring, 0, $where);
	print "Source doc ID: $sourcedocid<br>\n";

	$thestring = substr ($thestring, $where);
	$thestring = substr ($thestring, 1);
	$where = index ($thestring, $separator);
	my $sectionid = substr ($thestring, 0, $where);
	print "Source doc section ID: $sectionid<br>\n";

#        $thestring = substr ($thestring, $where);
#        $thestring = substr ($thestring, 1);
#        $where = index ($thestring, $separator);
#        my $requirementid = substr ($thestring, 0, $where);
##        $title = ($title) ? $title : " ";
#        print "Requirement ID: $requirementid<br>\n";

	$thestring = substr ($thestring, $where);
	$thestring = substr ($thestring, 1);
	$where = index ($thestring, $endrecord);
	my $text = substr ($thestring, 0, $where);
        $text = ($text) ? $text : "";
        $text =~ s/\n/\\n/g;
        $text =~ s/'/''/g;
	print "Section text: $text<br>\n";

	my $insertstr;
        $insertstr = "insert into $schema.sourcerequirement (id, sourceid, sectionid, requirementid, text, dateentered, enteredby, lastupdated, updatedby, isdeleted) values ($schema.sourcerequirement_id_seq.nextval, $sourcedocid, '$sectionid', 0, '$text', SYSDATE, 1005, SYSDATE, 1005, 'F')";
	print "$insertstr<br><br>\n";
	$csr = $dbh -> prepare ($insertstr);
	$csr -> execute;

	$where = index ($thestring, $endrecord);
	$thestring = substr ($thestring, $where);
	$thestring = substr ($thestring, 1);
	$where = index ($thestring, $separator);
    }
}
$csr -> finish;
close (SOURCE);
#=cut

print "<br><br>\n</body>\n</html>\n";
my $stat = db_disconnect($dbh);



